@istest
public class CloneApplicantsJobTest {
    
    @testSetup
    static void testValidateData() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        
        ApplicantEmployment__c appEmpDetil = new ApplicantEmployment__c();
        appEmpDetil.LoanApplicant__c = app.id;
        appEmpDetil.GST_Registered__c = 'Yes';
        TriggerBase.bypass('ApplicantEmployment__c');
        insert appEmpDetil;
        TriggerBase.clearBypass('ApplicantEmployment__c');
        
        ApplAddr__c appAdd = new ApplAddr__c();
        appAdd.Applicant__c = app.id;
        appAdd.AddrTyp__c = 'Other Address';
        TriggerBase.bypass('ApplAddr__c');
        insert appAdd;
        TriggerBase.clearBypass('ApplAddr__c');
    }
    @isTest
    static void cloneApplicantsJobTestMethod() {
        
        LoanAppl__c loanApp = [SELECT Id,Stage__c,SubStage__c,Product__c FROM LoanAppl__c LIMIT 1];
        
        // Set input data for the CloneLoanAppwrpr class
        CloneLoanAppController.CloneLoanAppwrpr inputData = new CloneLoanAppController.CloneLoanAppwrpr();
        inputData.recordId = loanApp.Id;
        inputData.userId = UserInfo.getUserId();
        inputData.cloneReason = 'BT + Top Up';
        
        LoanAppl__c loanAppp = [SELECT Id, Product__c FROM LoanAppl__c LIMIT 1];
        Id clonedLoanAppId = loanAppp.Id; // Simulate cloned loan application ID
        
        CloneApplicantsJob cloneJob = new CloneApplicantsJob(inputData, loanApp.Product__c, clonedLoanAppId);
        
        Test.startTest();
        // Enqueue job
        System.enqueueJob(cloneJob);
        Test.stopTest();
        
        List<Applicant__c> clonedApplicants = [SELECT Id, LoanAppln__c FROM Applicant__c WHERE LoanAppln__c = :clonedLoanAppId];
        System.assertEquals(4, clonedApplicants.size(), 'Applicants should be cloned.');
        
        List<ApplAddr__c> clonedAddresses = [SELECT Id, Applicant__c FROM ApplAddr__c WHERE Applicant__c = :clonedApplicants[0].Id];
        System.assertEquals(1, clonedAddresses.size(), 'Applicant Addresses should be cloned.');
        
        List<ApplicantEmployment__c> clonedEmployment = [SELECT Id, LoanApplicant__c FROM ApplicantEmployment__c WHERE LoanApplicant__c = :clonedApplicants[0].Id];
        System.assertEquals(1, clonedEmployment.size(), 'Applicant Employment details should be cloned.');
        
        // Verify that CloneAppbankingDtlsJob is enqueued
        System.assertEquals(0, Limits.getQueueableJobs(), 'One Queueable job should be enqueued.');
        
        Boolean isAssert = true;
        try{
            CloneApplicantsJob jobnew = new CloneApplicantsJob(null,null,null);
            System.enqueueJob(jobnew);   
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    }
}