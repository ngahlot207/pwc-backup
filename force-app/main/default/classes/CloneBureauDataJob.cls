public class CloneBureauDataJob implements Queueable, Database.AllowsCallouts {
  private CloneLoanAppController.CloneLoanAppwrpr inputdata;
  private Id originalLoanAppId;
  private Id clonedLoanAppId;

  public CloneBureauDataJob(
    CloneLoanAppController.CloneLoanAppwrpr inputdata,
    Id originalLoanAppId,
    Id clonedLoanAppId
  ) {
    this.inputdata = inputdata;
    this.originalLoanAppId = originalLoanAppId;
    this.clonedLoanAppId = clonedLoanAppId;
  }

  public void execute(QueueableContext context) {
    try {
      Map<Id, Id> appWithOldIdMap = new Map<Id, Id>();
      Map<Id, Id> bureauOldIdMap = new Map<Id, Id>();
      Map<Id, Id> bureaurelDtlOldIdMap = new Map<Id, Id>();
      List<SObject> recordsToClone = new List<SObject>();

      List<Applicant__c> applicants = [
        SELECT
          Id,
          ClonedFor__c,
          (
            SELECT Id, ClonedSource__c
            FROM Bureau_Responses__r
            WHERE RecordType.Name IN ('Consumer Bureau', 'Commercial Bureau')
          )
        FROM Applicant__c
        WHERE LoanAppln__c = :clonedLoanAppId AND ApplType__c IN ('P', 'C', 'G')
      ];
      if (!applicants.isEmpty()) {
        for (Applicant__c applicant : applicants) {
          appWithOldIdMap.put(applicant.ClonedFor__c, applicant.Id);
          if (!applicant.Bureau_Responses__r.isEmpty()) {
            for (Bureau__c bureau : applicant.Bureau_Responses__r) {
              bureauOldIdMap.put(bureau.ClonedSource__c, bureau.Id);
            }
          }
        }
      }
      if (!bureauOldIdMap.keyset().isEmpty()) {
        List<Bureau__c> bureaurespnses = [
          SELECT
            Id,
            (
              SELECT Id, DispRem__c, DispRemDte__c, BureauResponse__c, Type__c
              FROM Bureau_Disputes__r
            ),
            (
              SELECT
                Id,
                BureauResponse__c,
                EnquiryType__c,
                Month2To3__c,
                Month4To6__c,
                month1__c,
                Total__c,
                Month12To24__c,
                MostRctDte__c,
                Greater24Month__c,
                Month7To12__c,
                Message__c
              FROM EnquirySummarys__r
            ),
            (
              SELECT
                Id,
                BureauRes__c,
                Institution__c,
                Type__c,
                Amt__c,
                NbrSuitFiled__c,
                DishonoredChq__c,
                WilfulDft__c,
                DerogatoryInfoParty__c
              FROM DerogatoryInfos__r
            ),
            (
              SELECT
                Id,
                BureauResponse__c,
                LstCFOpenedDte__c,
                TotalOutstanding__c,
                TotalCF__c,
                DelinquentOutstanding__c,
                Delinquent_CF__c,
                Open_CF__c,
                TotalLenders__c,
                Guarantor__c,
                GuarantorPer__c,
                TotalBorrowerPer__c,
                TotalBorrower__c,
                TotalGuarantor__c,
                TotalGuarantorPer__c,
                Message__c,
                TotalCFborper__c,
                TotalCFBorrower__c,
                TotalCFGuarantor__c,
                TotalCFGuarPer__c,
                DelinquentBorrPer__c,
                DelinquentBorr__c,
                DelinquentGuarantorPerc__c,
                DelinquentGuarantor__c,
                DelinquentCFBorrPer__c,
                DelinquentCFBorr__c,
                DelinquentCFGuarantor__c,
                DelinquentCFGuarantorPer__c,
                Outside_Institution__c
              FROM CreditProfileSummarys__r
            ),
            (
              SELECT
                Id,
                BureauResponse__c,
                Outstanding_Balance_Entity__c,
                OutstandBalCat__c,
                OutstandiBalVecType__c,
                BalanceType__c,
                OutstandingCount__c,
                OutstandingValue__c,
                Message__c
              FROM Outstanding_Balance_By_CF_Assets__r
            )
          FROM Bureau__c
          WHERE Id IN :bureauOldIdMap.keyset()
        ];
        if (!bureaurespnses.isEmpty()) {
          for (Bureau__c bureau : bureaurespnses) {
            if (!bureau.Bureau_Disputes__r.isEmpty()) {
              for (CM_BureauDispute__c bDispute : bureau.Bureau_Disputes__r) {
                CM_BureauDispute__c clonedbDispute = bDispute.clone(
                  false,
                  true,
                  false,
                  false
                );
                clonedbDispute.BureauResponse__c = bDispute.BureauResponse__c !=
                  null
                  ? bureauOldIdMap.get(bDispute.BureauResponse__c)
                  : null;
                recordsToClone.add(clonedbDispute);
              }
            }
            if (!bureau.EnquirySummarys__r.isEmpty()) {
              for (
                CM_EnquirySummary__c enquireSum : bureau.EnquirySummarys__r
              ) {
                CM_EnquirySummary__c clonedEnquireSum = enquireSum.clone(
                  false,
                  true,
                  false,
                  false
                );
                clonedEnquireSum.BureauResponse__c = enquireSum.BureauResponse__c !=
                  null
                  ? bureauOldIdMap.get(enquireSum.BureauResponse__c)
                  : null;
                recordsToClone.add(clonedEnquireSum);
              }
            }
            if (!bureau.DerogatoryInfos__r.isEmpty()) {
              for (
                CM_DerogatoryInfo__c buraDerogary : bureau.DerogatoryInfos__r
              ) {
                CM_DerogatoryInfo__c clonedBuraDerogary = buraDerogary.clone(
                  false,
                  true,
                  false,
                  false
                );
                clonedBuraDerogary.BureauRes__c = buraDerogary.BureauRes__c !=
                  null
                  ? bureauOldIdMap.get(buraDerogary.BureauRes__c)
                  : null;
                recordsToClone.add(clonedBuraDerogary);
              }
            }
            if (!bureau.CreditProfileSummarys__r.isEmpty()) {
              for (
                CM_CreditProfileSummary__c creditProSummary : bureau.CreditProfileSummarys__r
              ) {
                CM_CreditProfileSummary__c clonedCreditProSummary = creditProSummary.clone(
                  false,
                  true,
                  false,
                  false
                );
                clonedCreditProSummary.BureauResponse__c = creditProSummary.BureauResponse__c !=
                  null
                  ? bureauOldIdMap.get(creditProSummary.BureauResponse__c)
                  : null;
                recordsToClone.add(clonedCreditProSummary);
              }
            }
            if (!bureau.Outstanding_Balance_By_CF_Assets__r.isEmpty()) {
              for (
                CM_OutstandingBalanceByCFAsset__c outBalByCfAss : bureau.Outstanding_Balance_By_CF_Assets__r
              ) {
                CM_OutstandingBalanceByCFAsset__c clonedOutBalByCfAss = outBalByCfAss.clone(
                  false,
                  true,
                  false,
                  false
                );
                clonedOutBalByCfAss.BureauResponse__c = outBalByCfAss.BureauResponse__c !=
                  null
                  ? bureauOldIdMap.get(outBalByCfAss.BureauResponse__c)
                  : null;
                recordsToClone.add(clonedOutBalByCfAss);
              }
            }
          }
        }
        if (!recordsToClone.isEmpty()) {
          insert recordsToClone;
        }
        recordsToClone.clear();

        List<CM_BureauRelationShipDetail__c> bureauRelDtls = [
          SELECT
            Id,
            BureauResponse__c,
            Dtencorp__c,
            RelatedType__c,
            BusIndType__c,
            ClsAct__c,
            Name__c,
            BusCat__c,
            PerCon__c,
            Relationship__c,
            LstRprtDte__c,
            RelHeader__c,
            Address__c,
            TeleNum__c,
            MobNum__c,
            AckId__c
          FROM CM_BureauRelationShipDetail__c
          WHERE BureauResponse__c IN :bureauOldIdMap.keyset()
        ];
        if (!bureauRelDtls.isEmpty()) {
          for (CM_BureauRelationShipDetail__c buraRel : bureauRelDtls) {
            CM_BureauRelationShipDetail__c clonedBuraRel = buraRel.clone(
              false,
              true,
              false,
              false
            );
            clonedBuraRel.BureauResponse__c = buraRel.BureauResponse__c != null
              ? bureauOldIdMap.get(buraRel.BureauResponse__c)
              : null;
            recordsToClone.add(clonedBuraRel);
          }
        }
        if (!recordsToClone.isEmpty()) {
          insert recordsToClone;

          for (Integer i = 0; i < recordsToClone.size(); i++) {
            // if (bureauRelDtlSaveResults[i].isSuccess()) {
            bureaurelDtlOldIdMap.put(bureauRelDtls[i].Id, recordsToClone[i].Id);
            // }
          }
        }
        recordsToClone.clear();

        if (!bureaurelDtlOldIdMap.keyset().isEmpty()) {
          List<CM_Bureau_Child_Relation_Ship__c> bureaChildRelShips = [
            SELECT Id, BureauRelationShip_Detail__c, Pan__c
            FROM CM_Bureau_Child_Relation_Ship__c
            WHERE BureauRelationShip_Detail__c IN :bureaurelDtlOldIdMap.keyset()
          ];
          if (!bureaChildRelShips.isEmpty()) {
            for (
              CM_Bureau_Child_Relation_Ship__c bureaChildRelShip : bureaChildRelShips
            ) {
              CM_Bureau_Child_Relation_Ship__c clonedBureaChildRelShip = bureaChildRelShip.clone(
                false,
                true,
                false,
                false
              );
              clonedBureaChildRelShip.BureauRelationShip_Detail__c = bureaChildRelShip.BureauRelationShip_Detail__c !=
                null
                ? bureaurelDtlOldIdMap.get(
                    bureaChildRelShip.BureauRelationShip_Detail__c
                  )
                : null;
              recordsToClone.add(clonedBureaChildRelShip);
            }
          }
        }
        if (!recordsToClone.isEmpty()) {
          insert recordsToClone;
        }
        recordsToClone.clear();
      }
      if (!Test.isRunningTest()) {
        System.enqueueJob(
          new CloneBureauDataTwoJob(
            inputdata,
            originalLoanAppId,
            clonedLoanAppId
          )
        );
      }
    } catch (Exception e) {
      if (clonedLoanAppId != null) {
        CloneRollbackHanlder.rollbackClonedloanApp(clonedLoanAppId);
      }
      GlobalUtility.logMessage(
        'Error',
        'CloneBureauDataJob',
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