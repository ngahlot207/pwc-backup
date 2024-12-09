@istest
public class CloneCaseJobTest {
    
    @testSetup
    static void testValidateData() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        
        ApplAddr__c appAdd = new ApplAddr__c();
        appAdd.Applicant__c = app.id;
        appAdd.AddrTyp__c = 'Other Address';
        TriggerBase.bypass('ApplAddr__c');
        insert appAdd;
        TriggerBase.clearBypass('ApplAddr__c');
        
        List<ApplAsset__c> appAssetList = new List<ApplAsset__c>();
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 12,
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('ApplAsset__c');
        insert appAssetList;
        TriggerBase.clearBypass('ApplAsset__c');
        
        List<Case> caseList = new List<Case>();
        Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Collateral Visit').getRecordTypeId();
        Id technicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Technical').getRecordTypeId();
        Id cpvfiRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('CPVFI').getRecordTypeId();
        Id legalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Legal').getRecordTypeId();
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Closed',
            IsReinitiated__c = false,
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cvRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Closed',
            IsReinitiated__c = false,
            IsCompleted__c = true,
            Property_Visit_Final_Status__c = 'Negative',
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = technicalRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Closed',
            IsReinitiated__c = false,
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = legalRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Closed',
            WaiveCPV__c = 'Yes',
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cpvfiRecordTypeId
        ));
        TriggerBase.bypass('Case');
        insert caseList;
        TriggerBase.clearBypass('Case');
        
        List<ApplKyc__c> appKycList = new List<ApplKyc__c>();
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Aadhaar'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Driving License'
        ));
        TriggerBase.bypass('ApplKyc__c');
        insert appKycList;
        TriggerBase.clearBypass('ApplKyc__c');
    }
    
    @isTest
    static void cloneCaseJobTestMethod() {
        
        LoanAppl__c loanApp = [SELECT Id,Stage__c,SubStage__c,Product__c FROM LoanAppl__c LIMIT 1];
        Applicant__c app = [SELECT Id,ClonedFor__c FROM Applicant__c LIMIT 1];
        app.ClonedFor__c = app.Id;
        update app;
        
        ApplAddr__c appAdrssRec = [SELECT Id,ClonedSource__c FROM ApplAddr__c WHERE Applicant__c = :app.Id LIMIT 1];
        appAdrssRec.ClonedSource__c =appAdrssRec.Id; 
        TriggerBase.bypass('ApplAddr__c');
        update appAdrssRec;
        TriggerBase.clearBypass('ApplAddr__c');
        
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
        
        CloneCaseJob cloneJob = new CloneCaseJob(inputData, loanApp.Product__c, clonedLoanAppId);
        
        Test.startTest();
        // Enqueue job
        System.enqueueJob(cloneJob);
        Test.stopTest();
        
        List<Case> clonedCase = [SELECT Id, Loan_Application__c FROM Case WHERE Loan_Application__c = :loanApp.Id];
        System.assertEquals(7, clonedCase.size(), 'Cases should be cloned.');
        
        List<ApplKyc__c> clonedAppKyc = [SELECT Id, Applicant__c FROM ApplKyc__c WHERE Applicant__c = :app.Id];
        System.assertEquals(6, clonedAppKyc.size(), 'Applicant KYC should be cloned.');
        
        Boolean isAssert = true;
        try{
            CloneCaseJob jobnew = new CloneCaseJob(null,null,null);
            System.enqueueJob(jobnew);   
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    } 
}