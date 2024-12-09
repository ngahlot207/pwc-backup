public class CloneAppbankingDtlsJob implements Queueable, Database.AllowsCallouts {
  private CloneLoanAppController.CloneLoanAppwrpr inputData;
  private String loanProduct;
  private Id clonedLoanAppId;

  public CloneAppbankingDtlsJob(
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
        
        LoanAppl__c loanApp = [SELECT Id, Product__c, Stage__c, SubStage__c,LoginAcceptDate__c FROM LoanAppl__c WHERE Id = :inputdata.recordId LIMIT 1];
        Date todayDate = Date.today();
        Boolean loginAccData = true;
        Date comparisonDate = todayDate.addDays(-30);
        if (loanApp.LoginAcceptDate__c != null && loanApp.LoginAcceptDate__c <= comparisonDate) {
          loginAccData = false;
        }
        
      if (inputData.cloneReason != null) {
        CloneMetadataUtility.CloneMtdUtilityWrpr returnDat = CloneMetadataUtility.getCloneStatus(
          'ApplBanking',
          inputData.cloneReason
        );
        Boolean repaymentExists = false; //LAK-9944
        Boolean nachExists = false;
        Boolean pdcExists = false; //LAK-9944
        List<String> products = returnDat.productType.split(':');

        if (
         (loginAccData == true && returnDat.cloneStatus != null &&
          returnDat.cloneStatus == 'Yes' &&
          products.contains(loanProduct)) || (inputData.banking == true && loginAccData == false)
        ) {
          String appBankingQuery =
            'SELECT ' +
            returnDat.fields +
            ' FROM ApplBanking__c WHERE LoanAppl__c = \'' +
            inputData.recordId +
            '\'';
          System.debug('appBankingQuery ==>> ' + appBankingQuery);

          List<ApplBanking__c> applBankings = Database.query(appBankingQuery);

          Map<Id, Id> appWithOldIdMap = new Map<Id, Id>();
          List<SObject> recordsToClone = new List<SObject>();
          Map<Id, Id> appBankWithOldIdMap = new Map<Id, Id>();
          Map<Id, Id> repayAccWithOldIdMap = new Map<Id, Id>();

          List<Applicant__c> applicants = [
            SELECT Id, ClonedFor__c
            FROM Applicant__c
            WHERE
              LoanAppln__c = :clonedLoanAppId
              AND ApplType__c IN ('P', 'C', 'G')
          ];

          if (!applicants.isEmpty()) {
            for (Applicant__c applicant : applicants) {
              appWithOldIdMap.put(applicant.ClonedFor__c, applicant.Id);
            }
          }

          if (!applBankings.isEmpty()) {
            for (ApplBanking__c appBanking : applBankings) {
              ApplBanking__c clonedAppBanking = appBanking.clone(
                false,
                true,
                false,
                false
              );
              clonedAppBanking.Appl__c = appBanking.Appl__c != null
                ? appWithOldIdMap.get(appBanking.Appl__c)
                : null;
                if(clonedAppBanking.Repayment_bank_A_c__c != null && clonedAppBanking.Repayment_bank_A_c__c == 'Yes'){
                  repaymentExists = true;
                }
              clonedAppBanking.LoanAppl__c = clonedLoanAppId;
              clonedAppBanking.ClonedSource__c = appBanking.Id;
              recordsToClone.add(clonedAppBanking);
            }
          }

          // Insert cloned applicants and update map with new IDs
          insert recordsToClone;

          for (Integer i = 0; i < recordsToClone.size(); i++) {
            appBankWithOldIdMap.put(applBankings[i].Id, recordsToClone[i].Id);
          }
          recordsToClone.clear();

          if(inputData.recordId != null && repaymentExists == true){
            List<Repayment_Account__c> repaymAccounts = [SELECT Id,Loan_Application__c, Account_Number__c, Applicant_Banking__c, Bank_Branch__c, Bank_Name__c, Deactivate_Date__c, IFSC_Code__c, Is_Active__c, 
                                                               MICR_Code__c, Repayment_Mode__c, SameASRepayment__c, AccHolderName__c, Pending_Cheques__c, Debit_Type__c, Feasible__c, Type__c, Is_Verified__c 
                                                               FROM Repayment_Account__c WHERE Loan_Application__c =: inputData.recordId AND Is_Active__c = true];
                if(!repaymAccounts.isEmpty()){
                  for (Repayment_Account__c repAcc : repaymAccounts) {
                    Repayment_Account__c clonedRepAcc = repAcc.clone(
                      false,
                      true,
                      false,
                      false
                    );
                    clonedRepAcc.Loan_Application__c = clonedLoanAppId;
                    clonedRepAcc.Applicant_Banking__c = repAcc.Applicant_Banking__c !=
                  null
                  ? appBankWithOldIdMap.get(repAcc.Applicant_Banking__c)
                  : null;
                  if(clonedRepAcc.Repayment_Mode__c != null && clonedRepAcc.Repayment_Mode__c == 'PDC'){
                  pdcExists = true;
                   }else if(clonedRepAcc.Repayment_Mode__c != null && clonedRepAcc.Repayment_Mode__c == 'NACH'){
                   nachExists = true;
                   }
                    recordsToClone.add(clonedRepAcc);
                  }

                  // Insert cloned applicants and update map with new IDs
          insert recordsToClone;

          for (Integer i = 0; i < recordsToClone.size(); i++) {
            repayAccWithOldIdMap.put(repaymAccounts[i].Id, recordsToClone[i].Id);
          }
          recordsToClone.clear();
                }
              //LAK-9944
                if(pdcExists == true){
                  List<PDC__c> pdcRecrds = [SELECT Id,Loan_Application__c, Repayment_Account__c, PDC_Type__c, Cheque_Number_From__c, Cheque_Number_To__c, No_of_Cheques__c, Cheque_Purpose__c, Cheque_Amount__c, Cheque_Available_EMI__c, Pending_Cheque__c, Account_No__c, MICR_Code__c, Bank_Name__c, Bank_Branch__c, IFSC_Code__c, Same_As_Repayment_Account__c, MICRCodeID__c, Cheque_Purpose_PDC__c  FROM PDC__c WHERE Loan_Application__c =: inputData.recordId];
                  if(!pdcRecrds.isEmpty()){
                    for (PDC__c pdc : pdcRecrds) {
                      PDC__c clonedPdc = pdc.clone(
                        false,
                        true,
                        false,
                        false
                      );
                      clonedPdc.Loan_Application__c = clonedLoanAppId;
                      clonedPdc.Repayment_Account__c = pdc.Repayment_Account__c != null ? repayAccWithOldIdMap.get(pdc.Repayment_Account__c) : null;
                      recordsToClone.add(clonedPdc);
                    }
                  }
                }

                if(nachExists == true){
                    List<PDC__c> pdcRecrds = [SELECT Id,Loan_Application__c, Repayment_Account__c, PDC_Type__c, Cheque_Number_From__c, Cheque_Number_To__c, No_of_Cheques__c, Cheque_Purpose__c, Cheque_Amount__c, Cheque_Available_EMI__c, Pending_Cheque__c, Account_No__c, MICR_Code__c, Bank_Name__c, Bank_Branch__c, IFSC_Code__c, Same_As_Repayment_Account__c, MICRCodeID__c, Cheque_Purpose_PDC__c  FROM PDC__c WHERE Loan_Application__c =: inputData.recordId AND PDC_Type__c ='SPDC'];
                  if(!pdcRecrds.isEmpty()){
                    for (PDC__c pdc : pdcRecrds) {
                      PDC__c clonedPdc = pdc.clone(
                        false,
                        true,
                        false,
                        false
                      );
                      clonedPdc.Loan_Application__c = clonedLoanAppId;
                      clonedPdc.Repayment_Account__c = pdc.Repayment_Account__c != null ? repayAccWithOldIdMap.get(pdc.Repayment_Account__c) : null;
                      recordsToClone.add(clonedPdc);
                    }
                  }
                    
                  List<NACH__c> nachRecrds = [SELECT Id,Mandate_Type__c,LoanAppl__c,IsActive__c,RepayAcc__c FROM NACH__c WHERE LoanAppl__c =: inputData.recordId AND IsActive__c = true];
                  if(!nachRecrds.isEmpty()){
                    for (NACH__c nach : nachRecrds) {
                      NACH__c clonedNach = nach.clone(
                        false,
                        true,
                        false,
                        false
                      );
                      clonedNach.LoanAppl__c = clonedLoanAppId;
                      clonedNach.RepayAcc__c = nach.RepayAcc__c != null ? repayAccWithOldIdMap.get(nach.RepayAcc__c) : null;
                      recordsToClone.add(clonedNach);
                    }
                  }
                }
          }
          if (!appBankWithOldIdMap.keySet().isEmpty()) {
            List<ApplBankDetail__c> applBankingsDtls = [
              SELECT
                Id,
                ApplBanking__c,
                Month__c,
                Year__c,
                ValueSummationCredit__c,
                ValueSummationDebit__c,
                CountofCredit__c,
                CountofDebit__c,
                InwardReturnsCount__c,
                OutwardReturnsCount__c,
                StopPaymentCount__c,
                MinBalanceCharges__c,
                BalanceAt_1st__c,
                BalanceAt_5th__c,
                BalanceAt_10th__c,
                BalanceAt_15th__c,
                BalanceAt_20th__c,
                BalanceAt_25th__c,
                AverageBankBalance__c,
                Utilization__c,
                MonthlyLimit__c,
                DailyABBBalance__c
              FROM ApplBankDetail__c
              WHERE ApplBanking__c IN :appBankWithOldIdMap.keySet()
            ];

            if (!applBankingsDtls.isEmpty()) {
              for (ApplBankDetail__c appBankingDtl : applBankingsDtls) {
                ApplBankDetail__c clonedAppBankingDtl = appBankingDtl.clone(
                  false,
                  true,
                  false,
                  false
                );
                clonedAppBankingDtl.ApplBanking__c = appBankingDtl.ApplBanking__c !=
                  null
                  ? appBankWithOldIdMap.get(appBankingDtl.ApplBanking__c)
                  : null;
                recordsToClone.add(clonedAppBankingDtl);
              }
            }
          }
          if (!recordsToClone.isEmpty()) {
            insert recordsToClone;
          }
        }
      }
      if(!Test.isRunningTest()){
        System.enqueueJob(
            new CloneAppFinancialsJob(inputData, loanProduct, clonedLoanAppId)
          );
      }
      //}
    } catch (Exception e) {
        if (clonedLoanAppId != null) {
            CloneRollbackHanlder.rollbackClonedloanApp(clonedLoanAppId);
          }
      GlobalUtility.logMessage(
        'Error',
        'CloneAppbankingDtlsJob',
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