@istest
public class ClonePdDocDtlsJobTest {
    
    @testSetup
    static void testValidateData() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
       List<PD__c> pdList = new List<PD__c>();
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = true,
            PDStatus__c = 'Completed',
            Result__c = 'Negative',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = true,
            PDStatus__c = 'Completed',
            Result__c = 'Positive',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        TriggerBase.bypass('PD__c');
        insert pdList;
        TriggerBase.clearBypass('PD__c'); 
        
        List<ApplAsset__c> appAssetList = new List<ApplAsset__c>();
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 12,
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('ApplAsset__c');
        insert appAssetList;
        TriggerBase.clearBypass('ApplAsset__c');   
    }
    @isTest
    static void clonePdDocDtlsJobMethod() {
        
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
  
        ClonePdDocDtlsJob cloneJob = new ClonePdDocDtlsJob(inputData, loanApp.Product__c, clonedLoanAppId);
        
        Test.startTest();
        // Enqueue job
        System.enqueueJob(cloneJob);
        Test.stopTest();
        
        List<PD__c> clonedPds = [SELECT Id, Appl__c FROM PD__c WHERE Appl__c = :app.Id AND PDStatus__c = 'Completed'];
        System.assertEquals(4, clonedPds.size(), 'PD should be cloned.');
        
        List<ApplAsset__c> cloneAppAssets = [SELECT Id, Appl__c FROM ApplAsset__c WHERE Appl__c = :app.Id];
        System.assertEquals(2, cloneAppAssets.size(), 'Applicant Asset should be cloned.');
        
        Boolean isAssert = true;
        try{
            ClonePdDocDtlsJob jobnew = new ClonePdDocDtlsJob(null,null,null);
            System.enqueueJob(jobnew);   
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    } 
}