@istest
public class CloneAppbankingDtlsJobTest {
    
    @testSetup
    static void testValidateData() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        List<ApplBanking__c> appbankingList = new List<ApplBanking__c>();
        appbankingList.add(new ApplBanking__c(
            MICR_Code__c = '400240077',
            Repayment_bank_A_c__c = 'Yes',
            LoanAppl__c = loanApp.Id,
            Name_of_the_Primary_Account_Holder_s__c = 'TEST',
            AccountType__c = 'CURRENT',
            AC_No__c = '123456789',
            BankName__c = 'ICICI Bank',
            Appl__c = app.Id
        ));
        TriggerBase.bypass('ApplBanking__c');
        insert appbankingList;
        TriggerBase.clearBypass('ApplBanking__c');
        List<ApplBankDetail__c> appbankingDtlList = new List<ApplBankDetail__c>();
        
        appbankingDtlList.add(new ApplBankDetail__c(
            AverageBankBalance__c = 1000,
            BalanceAt_10th__c = null,
            BalanceAt_15th__c = 200.90,
            BalanceAt_20th__c = 200.90,
            BalanceAt_5th__c = 2000.00,
            BalanceAt_25th__c =100.00,
            BalanceAt_1st__c =100.00,
            CountofCredit__c = 10,
            CountofDebit__c =10,
            DailyABBBalance__c = 12.00,
            InwardReturnsCount__c =10,
            MinBalanceCharges__c = 'Y',
            OutwardReturnsCount__c = 23,
            StopPaymentCount__c = 12,
            ValueSummationDebit__c = 12,
            ValueSummationCredit__c = 12,
            ApplBanking__c = appbankingList[0].Id
        ));
        
        TriggerBase.bypass('ApplBankDetail__c');
        insert appbankingDtlList;
        TriggerBase.clearBypass('ApplBankDetail__c');
    }
    
    @isTest
    static void cloneAppbankingDtlsJobTestMethod() {
        
        LoanAppl__c loanApp = [SELECT Id,Stage__c,SubStage__c,Product__c FROM LoanAppl__c LIMIT 1];
        
        // Set input data for the CloneLoanAppwrpr class
        CloneLoanAppController.CloneLoanAppwrpr inputData = new CloneLoanAppController.CloneLoanAppwrpr();
        inputData.recordId = loanApp.Id;
        inputData.userId = UserInfo.getUserId();
        inputData.cloneReason = 'BT + Top Up';
        
        LoanAppl__c loanAppp = [SELECT Id, Product__c FROM LoanAppl__c LIMIT 1];
        Id clonedLoanAppId = loanAppp.Id; // Simulate cloned loan application ID
        
        CloneAppbankingDtlsJob cloneJob = new CloneAppbankingDtlsJob(inputData, loanApp.Product__c, clonedLoanAppId);
        
        Test.startTest();
        // Enqueue job
        System.enqueueJob(cloneJob);
        Test.stopTest();
        
        List<ApplBanking__c> clonedBankRecrds = [SELECT Id, LoanAppl__c FROM ApplBanking__c WHERE LoanAppl__c = :clonedLoanAppId];
        System.assertEquals(2, clonedBankRecrds.size(), 'Applicant Banking should be cloned.');
        
        List<ApplBankDetail__c> clonedAppBakDtls = [SELECT Id, ApplBanking__c FROM ApplBankDetail__c WHERE ApplBanking__c = :clonedBankRecrds[0].Id];
        System.assertEquals(1, clonedAppBakDtls.size(), 'Applicant Banking Detail should be cloned.');
        
        Boolean isAssert = true;
        try{
            CloneAppbankingDtlsJob jobnew = new CloneAppbankingDtlsJob(null,null,null);
            System.enqueueJob(jobnew);   
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    }
}