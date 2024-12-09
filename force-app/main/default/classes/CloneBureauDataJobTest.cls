@istest
public class CloneBureauDataJobTest {
    
    @testSetup
    static void testValidateData() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
       
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
        
        List<CM_BureauDispute__c> bureauDis = new List<CM_BureauDispute__c>();
        
        bureauDis.add(new CM_BureauDispute__c(
            BureauResponse__c = bureauResRecrds[0].Id,
            DispRem__c = 'Test'
        ));
        TriggerBase.bypass('CM_BureauDispute__c');
        insert bureauDis;
        TriggerBase.clearBypass('CM_BureauDispute__c');
        
        List<CM_EnquirySummary__c> enqSumm = new List<CM_EnquirySummary__c>(); 
        enqSumm.add(new CM_EnquirySummary__c(
            BureauResponse__c = bureauResRecrds[0].Id,
            Month2To3__c = 23
        ));
        TriggerBase.bypass('CM_EnquirySummary__c');
        insert enqSumm;
        TriggerBase.clearBypass('CM_EnquirySummary__c');
        
        List<CM_DerogatoryInfo__c> derogatories = new List<CM_DerogatoryInfo__c>(); 
        derogatories.add(new CM_DerogatoryInfo__c(
            BureauRes__c = bureauResRecrds[0].Id,
            DishonoredChq__c = 'Test'
        ));
        TriggerBase.bypass('CM_DerogatoryInfo__c');
        insert derogatories;
        TriggerBase.clearBypass('CM_DerogatoryInfo__c');
        
        List<CM_CreditProfileSummary__c> creditProSum = new List<CM_CreditProfileSummary__c>(); 
        creditProSum.add(new CM_CreditProfileSummary__c(
            BureauResponse__c = bureauResRecrds[0].Id,
            DelinquentBorr__c = 'Test'
        ));
        TriggerBase.bypass('CM_CreditProfileSummary__c');
        insert creditProSum;
        TriggerBase.clearBypass('CM_CreditProfileSummary__c');
        
        List<CM_OutstandingBalanceByCFAsset__c> oustBalSheet = new List<CM_OutstandingBalanceByCFAsset__c>(); 
        oustBalSheet.add(new CM_OutstandingBalanceByCFAsset__c(
            BureauResponse__c = bureauResRecrds[0].Id,
            OutstandingCount__c = 'Test'
        ));
        TriggerBase.bypass('CM_OutstandingBalanceByCFAsset__c');
        insert oustBalSheet;
        TriggerBase.clearBypass('CM_OutstandingBalanceByCFAsset__c');
        
        List<CM_BureauRelationShipDetail__c> bureauRelDetl = new List<CM_BureauRelationShipDetail__c>(); 
        bureauRelDetl.add(new CM_BureauRelationShipDetail__c(
            BureauResponse__c = bureauResRecrds[0].Id,
            BusCat__c = 'Test'
        ));
        TriggerBase.bypass('CM_BureauRelationShipDetail__c');
        insert bureauRelDetl;
        TriggerBase.clearBypass('CM_BureauRelationShipDetail__c');
        
        List<CM_Bureau_Child_Relation_Ship__c> bureauChildRelDetl = new List<CM_Bureau_Child_Relation_Ship__c>(); 
        bureauChildRelDetl.add(new CM_Bureau_Child_Relation_Ship__c(
            BureauRelationShip_Detail__c = bureauRelDetl[0].Id,
            Pan__c = 'ENUYT8786H'
        ));
        TriggerBase.bypass('CM_Bureau_Child_Relation_Ship__c');
        insert bureauChildRelDetl;
        TriggerBase.clearBypass('CM_Bureau_Child_Relation_Ship__c');
    }  
    
    @isTest
    static void cloneBureauDataJobTestMethod() {
        
        LoanAppl__c loanApp = [SELECT Id,Stage__c,SubStage__c,Product__c FROM LoanAppl__c LIMIT 1];
        Applicant__c app = [SELECT Id,ClonedFor__c FROM Applicant__c LIMIT 1];
        app.ClonedFor__c = app.Id;
        update app;
        
        LoanAppl__c loanAppp = [SELECT Id, Product__c FROM LoanAppl__c LIMIT 1];
        Id clonedLoanAppId = loanAppp.Id; // Simulate cloned loan application ID
        
        Bureau__c bureauRes = [SELECT Id,ClonedSource__c FROM Bureau__c WHERE Applicant__c = :app.Id LIMIT 1];
        bureauRes.ClonedSource__c =bureauRes.Id; 
        TriggerBase.bypass('Bureau__c');
        update bureauRes;
        TriggerBase.clearBypass('Bureau__c');
        
        
        // Set input data for the CloneLoanAppwrpr class
        CloneLoanAppController.CloneLoanAppwrpr inputData = new CloneLoanAppController.CloneLoanAppwrpr();
        inputData.recordId = loanApp.Id;
        inputData.userId = UserInfo.getUserId();
        inputData.cloneReason = 'BT + Top Up';
        
        
        CloneBureauDataJob cloneJob = new CloneBureauDataJob(inputData, loanApp.Id, clonedLoanAppId);
        
        Test.startTest();
        // Enqueue job
        System.enqueueJob(cloneJob);
        Test.stopTest();
        
        List<CM_EnquirySummary__c> clonedApplRegulatories = [SELECT Id, BureauResponse__c FROM CM_EnquirySummary__c WHERE BureauResponse__c = :bureauRes.Id];
        System.assertEquals(2, clonedApplRegulatories.size(), 'Enquiry Sumamries should be cloned.');
        
        Boolean isAssert = true;
        try{
            CloneBureauDataJob jobnew = new CloneBureauDataJob(null,null,null);
            System.enqueueJob(jobnew);   
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    } 
}