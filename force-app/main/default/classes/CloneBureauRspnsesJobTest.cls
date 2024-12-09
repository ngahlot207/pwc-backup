@istest
public class CloneBureauRspnsesJobTest {
    
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
        
        Id conBureRecordTypeId = Schema.SObjectType.Bureau__c.getRecordTypeInfosByName()
            .get('Consumer Bureau').getRecordTypeId();
        Id commBureRecordTypeId = Schema.SObjectType.Bureau__c.getRecordTypeInfosByName()
            .get('Commercial Bureau').getRecordTypeId();
        List<Bureau__c> bureauResRecrds = new List<Bureau__c>();
        bureauResRecrds.add(new Bureau__c(
            Applicant__c = app.Id,
            Message__c = 'Test',
            RecordTypeId = conBureRecordTypeId
        ));
        bureauResRecrds.add(new Bureau__c(
            Applicant__c = app.Id,
            Message__c = 'Test2',
            RecordTypeId = commBureRecordTypeId
        ));
        TriggerBase.bypass('Bureau__c');
        insert bureauResRecrds;
        TriggerBase.clearBypass('Bureau__c');
        
        List<BureauRespDtl__c> bureauResDtlRecrds = new List<BureauRespDtl__c>();
        
        bureauResDtlRecrds.add(new BureauRespDtl__c(
            Applicant__c = app.Id,
            Message__c = 'Test'
        ));
        TriggerBase.bypass('BureauRespDtl__c');
        insert bureauResDtlRecrds;
        TriggerBase.clearBypass('BureauRespDtl__c');
        
        List<ApplObligation__c> appOblRecrds = new List<ApplObligation__c>();
        
        appOblRecrds.add(new ApplObligation__c(
            Applicant__c = app.Id,
            FinancierName__c = 'NOT DISCLOSED'
        ));
        TriggerBase.bypass('ApplObligation__c');
        insert appOblRecrds;
        TriggerBase.clearBypass('ApplObligation__c');
        
        List<Applicant_Obligation_detail__c> appOblDtlRecrds = new List<Applicant_Obligation_detail__c>();
        
        appOblDtlRecrds.add(new Applicant_Obligation_detail__c(
            BureauRespDtl__c = bureauResDtlRecrds[0].Id
        ));
        TriggerBase.bypass('Applicant_Obligation_detail__c');
        insert appOblDtlRecrds;
        TriggerBase.clearBypass('Applicant_Obligation_detail__c');
    }
    
    @isTest
    static void cloneBureauRspnsesJobTestMethod() {
        
        LoanAppl__c loanApp = [SELECT Id,Stage__c,SubStage__c,Product__c FROM LoanAppl__c LIMIT 1];
        Applicant__c app = [SELECT Id,ClonedFor__c FROM Applicant__c LIMIT 1];
        app.ClonedFor__c = app.Id;
        update app;
        
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
        
        LoanAppl__c loanAppp = [SELECT Id, Product__c FROM LoanAppl__c LIMIT 1];
        Id clonedLoanAppId = loanAppp.Id; // Simulate cloned loan application ID
        
        CloneBureauRspnsesJob cloneJob = new CloneBureauRspnsesJob(inputData, loanApp.Product__c, clonedLoanAppId);
        
        Test.startTest();
        // Enqueue job
        System.enqueueJob(cloneJob);
        Test.stopTest();
        
        List<Bureau__c> clonedBureauRes = [SELECT Id, Applicant__c FROM Bureau__c WHERE Applicant__c = :app.Id];
        System.assertEquals(4, clonedBureauRes.size(), 'Bureau Responses should be cloned.');
        
        
        List<BureauRespDtl__c> clonedBureauResDtl = [SELECT Id, Applicant__c FROM BureauRespDtl__c WHERE Applicant__c = :app.Id];
        System.assertEquals(2, clonedBureauResDtl.size(), 'Bureau Responses Detail should be cloned.');
        
        List<ApplObligation__c> clonedAppOblig = [SELECT Id, Applicant__c FROM ApplObligation__c WHERE Applicant__c = :app.Id];
        System.assertEquals(2, clonedAppOblig.size(), 'Applicant Obligation Detail should be cloned.');
        Boolean isAssert = true;
        try{
            CloneBureauRspnsesJob jobnew = new CloneBureauRspnsesJob(null,null,null);
            System.enqueueJob(jobnew);   
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    } 
}