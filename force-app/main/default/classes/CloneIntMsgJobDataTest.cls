@istest
public class CloneIntMsgJobDataTest {
    
    @testSetup
    static void testValidateData() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Voter Id'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'Application Form',
            DocTyp__c = 'Application Form',
            Appl__c = app.id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Application Form'
        ));
        TriggerBase.bypass('DocDtl__c');
        insert docDtlList;
        TriggerBase.clearBypass('DocDtl__c');
        
        Id watchoutRecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByName()
            .get('Watchout').getRecordTypeId();
        Id screeningRecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByName()
            .get('Screening').getRecordTypeId();
        Id shopEstaRecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByName()
            .get('Shop & Establishment').getRecordTypeId();
        List<APIVer__c> apiVerList = new List<APIVer__c>();
        apiVerList.add(new APIVer__c(
            Appl__c = app.id,
            AdditionalAddr__c = 'test',
            LoanAplcn__c =loanApp.Id,
            RecordTypeId = watchoutRecordTypeId,
            IsLatest__c = true
        ));
        apiVerList.add(new APIVer__c(
            Appl__c = app.id,
            AdditionalAddr__c = 'test',
            IsLatest__c = true,
            LoanAplcn__c =loanApp.Id,
            RecordTypeId = screeningRecordTypeId
        ));
        TriggerBase.bypass('APIVer__c');
        insert apiVerList;
        TriggerBase.clearBypass('APIVer__c');
        
        APIVer__c shopEst = new APIVer__c();
        shopEst.Appl__c = app.id;
        shopEst.AdditionalAddr__c = 'test';
        shopEst.IsLatest__c = true;
        shopEst.LoanAplcn__c =loanApp.Id;
        shopEst.RecordTypeId = shopEstaRecordTypeId;
        TriggerBase.bypass('APIVer__c');
        insert shopEst;
        TriggerBase.clearBypass('APIVer__c');
        
        APIVerDtl__c apiVerDtl = new APIVerDtl__c();
        apiVerDtl.APIVerification__c = shopEst.id;
        apiVerDtl.AddrLine2__c = 'test';
        TriggerBase.bypass('APIVerDtl__c');
        insert apiVerDtl;
        TriggerBase.clearBypass('APIVerDtl__c');
        
        List<HunterVer__c> hunterVerList = new List<HunterVer__c>();
        hunterVerList.add(new HunterVer__c(
            Appl__c = app.id,
            HunStaWheMatFound__c = 'test',
            IsLatest__c = true,
            LoanAplcn__c = loanApp.Id
        ));
        TriggerBase.bypass('HunterVer__c');
        insert hunterVerList;
        TriggerBase.clearBypass('HunterVer__c');
    }
    
    @isTest
    static void cloneInstMsgDataTestMethod() {
        
        LoanAppl__c loanApp = [SELECT Id,Stage__c,SubStage__c,Product__c FROM LoanAppl__c LIMIT 1];
        Applicant__c app = [SELECT Id,ClonedFor__c FROM Applicant__c LIMIT 1];
        app.ClonedFor__c = app.Id;
        update app;
        
        LoanAppl__c loanAppp = [SELECT Id, Product__c FROM LoanAppl__c LIMIT 1];
        Id clonedLoanAppId = loanAppp.Id; // Simulate cloned loan application ID
        
        DocDtl__c appDocDtls = [SELECT Id,ClonedSource__c FROM DocDtl__c WHERE Appl__c = :app.Id LIMIT 1];
        appDocDtls.ClonedSource__c =appDocDtls.Id; 
        TriggerBase.bypass('DocDtl__c');
        update appDocDtls;
        TriggerBase.clearBypass('DocDtl__c');
        
        // Set input data for the CloneLoanAppwrpr class
        CloneLoanAppController.CloneLoanAppwrpr inputData = new CloneLoanAppController.CloneLoanAppwrpr();
        inputData.recordId = loanApp.Id;
        inputData.userId = UserInfo.getUserId();
        inputData.cloneReason = 'BT + Top Up';
        
        
        CloneIntMsgJobData cloneJob = new CloneIntMsgJobData(inputData, loanApp.Product__c, clonedLoanAppId);
        
        Test.startTest();
        // Enqueue job
        System.enqueueJob(cloneJob);
        Test.stopTest();
        
        List<APIVer__c> clonedApplVers = [SELECT Id, Appl__c FROM APIVer__c WHERE Appl__c = :app.Id];
        System.assertEquals(6, clonedApplVers.size(), 'Applicant Verifications should be cloned.');
        
        Boolean isAssert = true;
        try{
            CloneIntMsgJobData jobnew = new CloneIntMsgJobData(null,null,null);
            System.enqueueJob(jobnew);   
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    } 
}