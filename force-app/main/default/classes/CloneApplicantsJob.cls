public class CloneApplicantsJob implements Queueable, Database.AllowsCallouts {
  private CloneLoanAppController.CloneLoanAppwrpr inputData;
  private String loanProduct;
  private Id clonedLoanAppId;

  public CloneApplicantsJob(
    CloneLoanAppController.CloneLoanAppwrpr inputData,
    String loanProduct,
    Id clonedLoanAppId
  ) {
    this.inputData = inputData;
    this.loanProduct = loanProduct;
    this.clonedLoanAppId = clonedLoanAppId;
  }

  public void execute(QueueableContext context) {
    try {
      if (inputData.cloneReason != null) {
        CloneMetadataUtility.CloneMtdUtilityWrpr returnDat = CloneMetadataUtility.getCloneStatus(
          'Applicant',
          inputData.cloneReason
        );
        List<String> products = returnDat.productType.split(':');
        if (
          returnDat.cloneStatus != null &&
          returnDat.cloneStatus == 'Yes' &&
          products.contains(loanProduct)
        ) {
          String appQuery =
            'SELECT ' +
            returnDat.fields +
            ' FROM Applicant__c WHERE LoanAppln__c = \'' +
            inputData.recordId +
            '\' AND ApplType__c IN (\'P\', \'C\', \'G\')';

          system.debug('appQuery ==>> ' + appQuery);
          List<Applicant__c> applicants = Database.query(appQuery);
          if (!applicants.isEmpty()) {
            List<Applicant__c> recordsToClone = new List<Applicant__c>();
            List<Sobject> recordsToCloneNew = new List<SObject>();
            // List<SObject> recordsToCloneAppAddrs = new List<SObject>();
            Map<Id, Id> applicantIdMap = new Map<Id, Id>();

            for (Applicant__c applicant : applicants) {
              Applicant__c clonedApplicant = applicant.clone(
                false,
                true,
                false,
                false
              );
              clonedApplicant.LoanAppln__c = clonedLoanAppId;
              if (inputData.cloneReason == 'Top up') {
                clonedApplicant.LatestyearforwhichITRisavailable__c = null;
                clonedApplicant.Provisional_Financials_Available__c = null;
              }
              clonedApplicant.ClonedFor__c = applicant.Id;
              recordsToClone.add(clonedApplicant);
            }
            TriggerActionFlow.bypass('Create_Applicant_COnsent_History');
            insert recordsToClone;
            TriggerActionFlow.clearBypass('Create_Applicant_COnsent_History');

            for (Integer i = 0; i < recordsToClone.size(); i++) {
              applicantIdMap.put(applicants[i].Id, recordsToClone[i].Id);
            }

            Id primaryApplicantId;
            for (Applicant__c cloneApp : recordsToClone) {
              if (cloneApp.ApplType__c == 'P') {
                primaryApplicantId = cloneApp.Id;
              }
            }
            LoanAppl__c loanApp = new LoanAppl__c();
            loanApp.Id = clonedLoanAppId;
            loanApp.Applicant__c = primaryApplicantId;
            MetadataTriggerHandler.bypass('LoanTATHandler'); //LAK-8409
            update loanApp;
            MetadataTriggerHandler.clearBypass('LoanTATHandler'); //LAK-8409

            recordsToClone.clear();
            CloneMetadataUtility.CloneMtdUtilityWrpr returnDatMobileCon = CloneMetadataUtility.getCloneStatus(
              'Mobileconsent',
              inputData.cloneReason
            );
            List<String> productsMobileCon = returnDatMobileCon.productType.split(
              ':'
            );
            if (
              returnDatMobileCon.cloneStatus != null &&
              returnDatMobileCon.cloneStatus == 'Yes' &&
              productsMobileCon.contains(loanProduct)
            ) {
              String consentTye = 'OTP Consent';
              String MobileConQuery =
                'SELECT ' +
                returnDatMobileCon.fields +
                ' FROM ApplConsentHis__c WHERE LoanAppln__c = \'' +
                inputData.recordId +
                '\' AND Consent_Type__c = \'' +
                consentTye +
                '\'';

              system.debug('MobileConQuery ==>> ' + MobileConQuery);
              List<ApplConsentHis__c> mobileConRecords = Database.query(
                MobileConQuery
              );
              if (!mobileConRecords.isEmpty()) {
                for (ApplConsentHis__c applConsent : mobileConRecords) {
                  ApplConsentHis__c clonedApplConsent = applConsent.clone(
                    false,
                    true,
                    false,
                    false
                  );
                  clonedApplConsent.Appl__c = applConsent.Appl__c != null
                    ? applicantIdMap.get(applConsent.Appl__c)
                    : null;
                  clonedApplConsent.LoanAppln__c = clonedLoanAppId;
                  recordsToCloneNew.add(clonedApplConsent);
                }
              }
            }
            if (!applicantIdMap.isEmpty()) {
              List<ApplAddr__c> appAddrs = [
                SELECT
                  Id,
                  Applicant__c,
                  AddrLine1__c,
                  AddrLine2__c,
                  City__c,
                  Country__c,
                  Pincode__c,
                  Sm_as_Per_Adr__c,
                  State__c,
                  LoanAppl__c,
                  HouseNo__c,
                  Locality__c,
                  OwnType__c,
                  DisFrmSrcBrnh__c,
                  DisFrmFFBrnh__c,
                  Nearest_Fedfina_Branch__c,
                  AddrTyp__c,
                  MailAddr__c,
                  Landmark__c,
                  AddrStability__c,
                  CityId__c,
                  PinId__c,
                  StateId__c,
                  Negative_Caution_Area__c,
                  StabAtAddressYr__c,
                  StabAtAddressMnth__c,
                  NearestFedBrnchID__c,
                  Same_as_Principal_place_for_business__c,
                  isPerSameAsResi_ADD__c,
                  GSTIndex__c,
                  RCUInitiated__c,
                  ClonedSource__c,
                  RCUProfChecked__c,
                  IsDeleted__c,
                  DelDateTime__c,
                  DeletedBy__c,
                  SampleTrigger__c,
                  RCURemarks__c,
                  SamplingDateTime__c,
                  RCUHoldDateTime__c,
                  RCUUnHoldDateTime__c,
                  AgencyAssigned__c,
                  RCUInitiDateTime__c,
                  RCUFileStatus__c,
                  AgencyDocStatus__c,
                  User__c,
                  OverrideByRCUManager__c
                FROM ApplAddr__c
                WHERE Applicant__c IN :applicantIdMap.keySet()
              ];

              if (!appAddrs.isEmpty()) {
                for (ApplAddr__c applAddr : appAddrs) {
                  ApplAddr__c clonedApplAddr = applAddr.clone(
                    false,
                    true,
                    false,
                    false
                  );
                  clonedApplAddr.Applicant__c = applAddr.Applicant__c != null
                    ? applicantIdMap.get(applAddr.Applicant__c)
                    : null;
                  clonedApplAddr.LoanAppl__c = clonedLoanAppId;
                  clonedApplAddr.ClonedSource__c = applAddr.Id;
                  recordsToCloneNew.add(clonedApplAddr);
                }
              }

              CloneMetadataUtility.CloneMtdUtilityWrpr returnDatAppEmp = CloneMetadataUtility.getCloneStatus(
                'ApplicantEmployment',
                inputData.cloneReason
              );
              List<String> productsEmp = returnDatAppEmp.productType.split(':');
              if (
                returnDatAppEmp.cloneStatus != null &&
                returnDatAppEmp.cloneStatus == 'Yes' &&
                productsEmp.contains(loanProduct)
              ) {
                Set<Id> applicantIds = applicantIdMap.keyset();
                String applicantIdsString =
                  '(\'' +
                  String.join(new List<Id>(applicantIds), '\',\'') +
                  '\')';
                String appEmpQuery =
                  'SELECT ' +
                  returnDatAppEmp.fields +
                  ' FROM ApplicantEmployment__c WHERE LoanApplicant__c IN ' +
                  applicantIdsString;

                system.debug('appEmpQuery ==>> ' + appEmpQuery);
                List<ApplicantEmployment__c> appEmplDtls = Database.query(
                  appEmpQuery
                );

                if (!appEmplDtls.isEmpty()) {
                  for (ApplicantEmployment__c employment : appEmplDtls) {
                    ApplicantEmployment__c clonedEmployment = employment.clone(
                      false,
                      true,
                      false,
                      false
                    );
                    clonedEmployment.LoanApplicant__c = employment.LoanApplicant__c !=
                      null
                      ? applicantIdMap.get(employment.LoanApplicant__c)
                      : null;
                    clonedEmployment.ClonedSource__c = employment.Id;
                    recordsToCloneNew.add(clonedEmployment);
                  }
                }
              }
              //insert recordsToCloneAppAddrs;
            }
            if (!recordsToCloneNew.isEmpty()) {
              insert recordsToCloneNew;
            }
          }
        }
      }
      // Enqueue the CloneAppbankingDtlsJob after cloning the Loan Application
      System.enqueueJob(
        new CloneAppbankingDtlsJob(inputData, loanProduct, clonedLoanAppId)
      );
    } catch (Exception e) {
      if (clonedLoanAppId != null) {
        CloneRollbackHanlder.rollbackClonedloanApp(clonedLoanAppId);
      }
      GlobalUtility.logMessage(
        'Error',
        'CloneApplicantsJob',
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