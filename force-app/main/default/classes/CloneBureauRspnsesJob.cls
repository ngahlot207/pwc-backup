public class CloneBureauRspnsesJob implements Queueable, Database.AllowsCallouts {
  private CloneLoanAppController.CloneLoanAppwrpr inputdata;
  private String loanProduct;
  private Id clonedLoanAppId;

  public CloneBureauRspnsesJob(
    CloneLoanAppController.CloneLoanAppwrpr inputdata,
    String loanProduct,
    Id clonedLoanAppId
  ) {
    this.inputdata = inputdata;
    this.loanProduct = loanProduct;
    this.clonedLoanAppId = clonedLoanAppId;
  }

  public void execute(QueueableContext context) {
    try {
      Map<Id, Id> appWithOldIdMap = new Map<Id, Id>();
      Map<Id, Id> appWithOldIdMapNew = new Map<Id, Id>();
      Map<Id, Id> docDtlWithOldIdMap = new Map<Id, Id>();
      Map<Id, Id> bureauWithOldIdMap = new Map<Id, Id>();
      Map<Id, Id> bureauResDtlWithOldIdMap = new Map<Id, Id>();

      List<SObject> recordsToClone = new List<SObject>();
      //LAK-9375
      LoanAppl__c loanApp = [SELECT Id, Product__c, Stage__c, SubStage__c,LoginAcceptDate__c FROM LoanAppl__c WHERE Id = :inputdata.recordId LIMIT 1];
      Date todayDate = Date.today();
      Boolean loginAccData = true;
      Date comparisonDate = todayDate.addDays(-30);
      if (loanApp.LoginAcceptDate__c != null && loanApp.LoginAcceptDate__c <= comparisonDate) {
        loginAccData = false;
      }

      List<Applicant__c> applicants = [
        SELECT
          Id,
          ClonedFor__c,
          (SELECT Id, ClonedSource__c FROM Applicant_Document_Details__r)
        FROM Applicant__c
        WHERE LoanAppln__c = :clonedLoanAppId AND ApplType__c IN ('P', 'C', 'G')
      ];

      if (!applicants.isEmpty()) {
        for (Applicant__c applicant : applicants) {
          appWithOldIdMap.put(applicant.ClonedFor__c, applicant.Id);
          appWithOldIdMapNew.put(applicant.Id, applicant.ClonedFor__c);
          if (!applicant.Applicant_Document_Details__r.isEmpty()) {
            for (DocDtl__c docDtl : applicant.Applicant_Document_Details__r) {
              docDtlWithOldIdMap.put(docDtl.ClonedSource__c, docDtl.Id);
            }
          }
        }
      }

      if (
        !appWithOldIdMap.keyset().isEmpty() && inputData.cloneReason != null
      ) {
        CloneMetadataUtility.CloneMtdUtilityWrpr returnDat = CloneMetadataUtility.getCloneStatus(
          'Bureau',
          inputData.cloneReason
        );
        List<String> products = returnDat.productType.split(':');
        if (
          returnDat.cloneStatus != null &&
          returnDat.cloneStatus == 'Yes' &&
          products.contains(loanProduct) && loginAccData == true
        ) {
          Set<Id> applicantIds = appWithOldIdMap.keyset();
          String applicantIdsString =
            '(\'' +
            String.join(new List<Id>(applicantIds), '\',\'') +
            '\')';

          String bureauQuery =
            'SELECT ' +
            returnDat.fields +
            ' FROM Bureau__c WHERE Applicant__c IN ' +
            applicantIdsString +
            ' AND RecordType.Name IN (\'Consumer Bureau\', \'Commercial Bureau\')';
          system.debug('bureauQuery ==>> ' + bureauQuery);
          List<Bureau__c> bureauResponses = Database.query(bureauQuery);

          if (!bureauResponses.isEmpty()) {
            for (Bureau__c bureauResp : bureauResponses) {
              Bureau__c clonedBureauResp = bureauResp.clone(
                false,
                true,
                false,
                false
              );
              clonedBureauResp.Applicant__c = bureauResp.Applicant__c != null
                ? appWithOldIdMap.get(bureauResp.Applicant__c)
                : null;
              clonedBureauResp.DocDetail__c = bureauResp.DocDetail__c != null
                ? appWithOldIdMap.get(bureauResp.DocDetail__c)
                : null;
              clonedBureauResp.LoanApp__c = clonedLoanAppId;
              clonedBureauResp.ClonedSource__c = bureauResp.Id;
              recordsToClone.add(clonedBureauResp);
            }
          }
          if (!recordsToClone.isEmpty()) {
            insert recordsToClone;

            for (Integer i = 0; i < recordsToClone.size(); i++) {
              bureauWithOldIdMap.put(
                bureauResponses[i].Id,
                recordsToClone[i].Id
              );
            }
            recordsToClone.clear();
          }
          //recordsToClone.clear();

          List<BureauRespDtl__c> bureauRespDtls = [
            SELECT
              Id,
              RecordTypeId,
              Applicant__c,
              Bureau__c,
              CloseDate__c,
              ConsiderObligation__c,
              CurrentOs__c,
              DisbursalDate__c,
              EMISource__c,
              EMI__c,
              BounceInLast12Months__c,
              FinancierNameID__c,
              FinancierName__c,
              LoanAmount__c,
              LoanApplication__c,
              PayHis1__c,
              LoanName__c,
              MaxDPDLst12month__c,
              MaxDPDLst3month__c,
              MaxDPDLst6month__c,
              NatureOfLoan__c,
              NoEMIPaid__c,
              Overdues__c,
              RepayAc__c,
              RepaymentBankID__c,
              Repayment_Bank__c,
              Source__c,
              TenureLeft__c,
              Tenure__c,
              Treatment__c,
              DateReportedCert__c,
              PaymentEndDate__c,
              PaymentStartDate__c,
              LastPayment__c,
              ActPayAmt__c,
              PrsnlDis__c,
              IsLatest__c,
              Ever90__c,
              BounceInLast18Months__c,
              TotalBouncesInRTR__c,
              EMIClearanceDate__c,
              LoanCapacity__c,
              PayHis2__c,
              Cashlmt__c,
              CreditLmt__c,
              ROI__c,
              Value_of_col__c,
              StatusDate__c,
              CFSeriNum__c,
              LstRepDte__c,
              CFType__c,
              Derivative__c,
              CFMember__c,
              AccNum__c,
              AstClassDysPstDueDpd__c,
              Status__c,
              DrawingPow__c,
              HighCredit__c,
              InstalAmt__c,
              LastRepaid__c,
              OutstandingBal__c,
              SanctionedAmt__c,
              Settled__c,
              WrittenOFF__c,
              RepayFreq__c,
              AstBasedSecCov__c,
              GuaranteeCov__c,
              RestructingRes__c,
              SanctionedDt__c,
              loanExpiryDt__c,
              loanRenewalDt__c,
              Message__c,
              DPD1To30Amt__c,
              DPD31To60Amt__c,
              DPD61T090Amt__c,
              DPD91To180Amt__c,
              DPDabove180Amt__c,
              RelatedType__c,
              ValidationDate__c,
              Classification__c,
              value__c,
              NatureOfLoanID__c,
              CrdFacType__c,
              CrdFaciAgainst__c,
              Remarks__c
            FROM BureauRespDtl__c
            WHERE Applicant__c IN :appWithOldIdMap.keyset()
          ];
          if (!bureauRespDtls.isEmpty()) {
            for (BureauRespDtl__c bureauResDtl : bureauRespDtls) {
              BureauRespDtl__c clonedBureauResDtl = bureauResDtl.clone(
                false,
                true,
                false,
                false
              );
              clonedBureauResDtl.Applicant__c = bureauResDtl.Applicant__c !=
                null
                ? appWithOldIdMap.get(bureauResDtl.Applicant__c)
                : null;
              clonedBureauResDtl.Bureau__c = bureauResDtl.Bureau__c != null
                ? bureauWithOldIdMap.get(bureauResDtl.Bureau__c)
                : null;
              clonedBureauResDtl.LoanApplication__c = clonedLoanAppId;
              clonedBureauResDtl.ClonedSource__c = bureauResDtl.Id;
              recordsToClone.add(clonedBureauResDtl);
            }
          }
          if (!recordsToClone.isEmpty()) {
            insert recordsToClone;
            for (Integer i = 0; i < recordsToClone.size(); i++) {
              bureauResDtlWithOldIdMap.put(
                bureauRespDtls[i].Id,
                recordsToClone[i].Id
              );
            }
          }
          recordsToClone.clear();
          if (!Test.isRunningTest()) {
            System.enqueueJob(
              new CloneBureauDataJob(
                inputdata,
                inputdata.recordId,
                clonedLoanAppId
              )
            );
          }
        }else{
          if (!Test.isRunningTest()) {
            // Calling Batch Class to Clone Documents
            CloneDocDtlAttachments batchJob = new CloneDocDtlAttachments(
              inputdata,
              inputdata.recordId,
              clonedLoanAppId,
              appWithOldIdMapNew
            );
            Database.executeBatch(batchJob);
          }
        }

       CloneMetadataUtility.CloneMtdUtilityWrpr returnData = CloneMetadataUtility.getCloneStatus(
          'ApplObligation',
          inputData.cloneReason
        );
        List<String> productsObl = returnData.productType.split(':');
        if (
          returnData.cloneStatus != null &&
          returnData.cloneStatus == 'Yes' &&
          productsObl.contains(loanProduct)
        ) {
       /*    Set<Id> appIds = appWithOldIdMap.keyset();
          String appIdsString =
            '(\'' +
            String.join(new List<Id>(appIds), '\',\'') +
            '\')';
          String appObligatioQuery =
            'SELECT ' +
            returnData.fields +
            ' FROM ApplObligation__c WHERE Applicant__c IN ' +
            appIdsString;
          system.debug('appObligatioQuery ==>> ' + appObligatioQuery);
          List<ApplObligation__c> appObligations = Database.query(
            appObligatioQuery
          );

          if (!appObligations.isEmpty()) {
            for (ApplObligation__c appObligation : appObligations) {
              ApplObligation__c clonedAppObligation = appObligation.clone(
                false,
                true,
                false,
                false
              );
              clonedAppObligation.Applicant__c = appObligation.Applicant__c !=
                null
                ? appWithOldIdMap.get(appObligation.Applicant__c)
                : null;
              clonedAppObligation.Bureau__c = appObligation.Bureau__c != null
                ? bureauWithOldIdMap.get(appObligation.Bureau__c)
                : null;
              clonedAppObligation.LoanApplication__c = clonedLoanAppId;
              clonedAppObligation.ClonedSource__c = appObligation.Id;
              recordsToClone.add(clonedAppObligation);
            }
          }*/
          if (!bureauResDtlWithOldIdMap.keyset().isEmpty()) {
            List<Applicant_Obligation_detail__c> appObligationDtls = [
              SELECT
                Id,
                EMI_Clearance_Date_IdentifierTest__c,
                EMI_Clearance_Date_Identifier__c,
                EMI_Clearance_Date__c,
                BureauRespDtl__c
              FROM Applicant_Obligation_detail__c
              WHERE BureauRespDtl__c IN :bureauResDtlWithOldIdMap.keyset()
            ];
            if (!appObligationDtls.isEmpty()) {
              for (
                Applicant_Obligation_detail__c appObligDtl : appObligationDtls
              ) {
                Applicant_Obligation_detail__c clonedAppObligationDtl = appObligDtl.clone(
                  false,
                  true,
                  false,
                  false
                );
                clonedAppObligationDtl.BureauRespDtl__c = appObligDtl.BureauRespDtl__c !=
                  null
                  ? bureauResDtlWithOldIdMap.get(appObligDtl.BureauRespDtl__c)
                  : null;
                clonedAppObligationDtl.ClonedSource__c = appObligDtl.Id;
                recordsToClone.add(clonedAppObligationDtl);
              }
            }
          }
          if (!recordsToClone.isEmpty()) {
            insert recordsToClone;
          }
          recordsToClone.clear();
        }
      }
    } catch (Exception e) {
      if (clonedLoanAppId != null) {
        CloneRollbackHanlder.rollbackClonedloanApp(clonedLoanAppId);
      }
      GlobalUtility.logMessage(
        'Error',
        'CloneBureauRspnsesJob',
        'Process',
        null,
        null,
        e.getMessage() + ' line ' + e.getLineNumber(),
        null,
        e,
        null
      );
    }
  }
}