@istest
public class CloneAppIncomeGStJobTest {
    
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
        
        ApplGST__c appGST = new ApplGST__c();
        appGST.Main_GSTIN__c = true;
        appGST.Applicant__c = app.id;
        TriggerBase.bypass('ApplGST__c');
        insert appGST;
        TriggerBase.clearBypass('ApplGST__c');
        
        Id AppIRecordTypeId1 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Agricultural Income').getRecordTypeId();
        
        
        List<Applicant_Income__c> applicantIncomeRecords = new List<Applicant_Income__c>{
            new Applicant_Income__c(Applicant__c = app.Id, RecordTypeId = AppIRecordTypeId1)
                };
                    TriggerBase.bypass('Applicant_Income__c');
        insert applicantIncomeRecords;
        TriggerBase.clearBypass('Applicant_Income__c');
    }
    
    @isTest
    static void clonePdDocDtlsJobMethod() {
        
        LoanAppl__c loanApp = [SELECT Id,Stage__c,SubStage__c,Product__c FROM LoanAppl__c LIMIT 1];
        Applicant__c app = [SELECT Id,ClonedFor__c FROM Applicant__c LIMIT 1];
        app.ClonedFor__c = app.Id;
        update app;
        
        PD__c pdsRecrd = [SELECT Id,ClonedSource__c FROM PD__c WHERE Appl__c = :app.Id AND PDStatus__c = 'Completed' LIMIT 1];
        pdsRecrd.ClonedSource__c =pdsRecrd.Id; 
        TriggerBase.bypass('PD__c');
        update pdsRecrd;
        TriggerBase.clearBypass('PD__c');
        
        ApplAsset__c appAsset = [SELECT Id,ClonedSource__c FROM ApplAsset__c WHERE Appl__c = :app.Id LIMIT 1];
        appAsset.ClonedSource__c =appAsset.Id; 
        TriggerBase.bypass('ApplAsset__c');
        update appAsset;
        TriggerBase.clearBypass('ApplAsset__c');
        // Set input data for the CloneLoanAppwrpr class
        CloneLoanAppController.CloneLoanAppwrpr inputData = new CloneLoanAppController.CloneLoanAppwrpr();
        inputData.recordId = loanApp.Id;
        inputData.userId = UserInfo.getUserId();
        inputData.cloneReason = 'BT + Top Up';
        
        LoanAppl__c loanAppp = [SELECT Id, Product__c FROM LoanAppl__c LIMIT 1];
        Id clonedLoanAppId = loanAppp.Id; // Simulate cloned loan application ID
        
        CloneAppIncomeGStJob cloneJob = new CloneAppIncomeGStJob(inputData, loanApp.Product__c, clonedLoanAppId);
        
        Test.startTest();
        // Enqueue job
        System.enqueueJob(cloneJob);
        Test.stopTest();
        
        List<ApplGST__c> clonedAppGsts = [SELECT Id, Applicant__c FROM ApplGST__c WHERE Applicant__c = :app.Id];
        System.assertEquals(2, clonedAppGsts.size(), 'Applicant GST should be cloned.');
        
        List<Applicant_Income__c> clonedAppincomes = [SELECT Id, Applicant__c FROM Applicant_Income__c WHERE Applicant__c = :app.Id];
        System.assertEquals(2, clonedAppincomes.size(), 'Applicant Income should be cloned.');
        
        Boolean isAssert = true;
        try{
            CloneAppIncomeGStJob jobnew = new CloneAppIncomeGStJob(null,null,null);
            System.enqueueJob(jobnew);   
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    } 
}