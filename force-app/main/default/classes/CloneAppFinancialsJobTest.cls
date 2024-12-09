@istest
public class CloneAppFinancialsJobTest {
    
    @testSetup
    static void testValidateData() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        
        Id applicantFinancialRecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByName()
            .get('Profit & Loss').getRecordTypeId();
        
        Id applicantFinancialGSTRecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByName()
            .get('GST').getRecordTypeId();
        Id applicantFinancialBSRecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByName()
            .get('Balance Sheet').getRecordTypeId();
        List<Applicant_Financial__c> appFinList = new List<Applicant_Financial__c>();
        appFinList.add(new Applicant_Financial__c(
            Loan_Applicant__c = app.id,
            RecordTypeId = applicantFinancialRecordTypeId
        ));
        appFinList.add(new Applicant_Financial__c(
            Loan_Applicant__c = app.id,
            RecordTypeId = applicantFinancialGSTRecordTypeId
        ));
        appFinList.add(new Applicant_Financial__c(
            Loan_Applicant__c = app.id,
            RecordTypeId = applicantFinancialBSRecordTypeId
        ));
        TriggerBase.bypass('Applicant_Financial__c');
        insert appFinList;
        TriggerBase.clearBypass('Applicant_Financial__c');
        
        Applicant_Financial_Summary__c varAppFinSum = New Applicant_Financial_Summary__c();
        varAppFinSum.Type_of_Accounts__c = 'Audited';
        //varAppFinSum.Date_of_Filing_ITR__c = Date.parse('12/27/2024');
        varAppFinSum.Date_of_Filing_ITR__c = Date.newInstance(2024,12,27);
        varAppFinSum.Applicant_Financial__c = appFinList[0].Id;
        TriggerBase.bypass('Applicant_Financial_Summary__c');
        insert varAppFinSum;
        TriggerBase.clearBypass('Applicant_Financial_Summary__c');
        
    }
    
    @isTest
    static void cloneAppFinancialsJobTestMethod() {
        
        LoanAppl__c loanApp = [SELECT Id,Stage__c,SubStage__c,Product__c FROM LoanAppl__c LIMIT 1];
         Applicant__c app = [SELECT Id,ClonedFor__c FROM Applicant__c LIMIT 1];
        app.ClonedFor__c = app.Id;
        update app;
        // Set input data for the CloneLoanAppwrpr class
        CloneLoanAppController.CloneLoanAppwrpr inputData = new CloneLoanAppController.CloneLoanAppwrpr();
        inputData.recordId = loanApp.Id;
        inputData.userId = UserInfo.getUserId();
        inputData.cloneReason = 'BT + Top Up';
        
        LoanAppl__c loanAppp = [SELECT Id, Product__c FROM LoanAppl__c LIMIT 1];
        Id clonedLoanAppId = loanAppp.Id; // Simulate cloned loan application ID
  
        CloneAppFinancialsJob cloneJob = new CloneAppFinancialsJob(inputData, loanApp.Product__c, clonedLoanAppId);
        
        Test.startTest();
        // Enqueue job
        System.enqueueJob(cloneJob);
        Test.stopTest();
        
        List<Applicant_Financial__c> clonedAppFinRecrds = [SELECT Id, Loan_Applicant__c FROM Applicant_Financial__c WHERE Loan_Applicant__c = :app.Id];
        System.assertEquals(6, clonedAppFinRecrds.size(), 'Applicant Financials should be cloned.');
        
        List<Applicant_Financial_Summary__c> clonedAppFinSummaries = [SELECT Id, Applicant_Financial__c FROM Applicant_Financial_Summary__c WHERE Applicant_Financial__c = :clonedAppFinRecrds[0].Id];
        System.assertEquals(1, clonedAppFinSummaries.size(), 'Applicant Financial Summary should be cloned.');
        
        Boolean isAssert = true;
        try{
            CloneAppFinancialsJob jobnew = new CloneAppFinancialsJob(null,null,null);
            System.enqueueJob(jobnew);   
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    }
}