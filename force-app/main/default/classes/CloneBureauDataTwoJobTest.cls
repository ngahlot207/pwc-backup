@istest
public class CloneBureauDataTwoJobTest {

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
        
         List<CM_CreditVision__c> credVers = new List<CM_CreditVision__c>();
        
        credVers.add(new CM_CreditVision__c(
            BureauResponse__c = bureauResRecrds[0].Id,
            Value__c = 'Test'
        ));
        TriggerBase.bypass('CM_CreditVision__c');
        insert credVers;
        TriggerBase.clearBypass('CM_CreditVision__c');
        
        List<CM_CreditRating__c> credRat = new List<CM_CreditRating__c>(); 
        credRat.add(new CM_CreditRating__c(
            BureauResponse__c = bureauResRecrds[0].Id,
            Message__c = 'Test'
        ));
        TriggerBase.bypass('CM_CreditRating__c');
        insert credRat;
        TriggerBase.clearBypass('CM_CreditRating__c');
        
        List<Rank__c> ranks = new List<Rank__c>(); 
        ranks.add(new Rank__c(
            BureauResponse__c = bureauResRecrds[0].Id,
            ExclusionRes__c = 'Test'
        ));
        TriggerBase.bypass('Rank__c');
        insert ranks;
        TriggerBase.clearBypass('Rank__c');
        
        List<CM_EnquiryDetail__c> enquiryDtl = new List<CM_EnquiryDetail__c>(); 
        enquiryDtl.add(new CM_EnquiryDetail__c(
            BureauResponse__c = bureauResRecrds[0].Id,
            CrdLender__c = 'Test'
        ));
        TriggerBase.bypass('CM_EnquiryDetail__c');
        insert enquiryDtl;
        TriggerBase.clearBypass('CM_EnquiryDetail__c');
        
        List<CM_CreditHistoryForACorDPD__c> credHis = new List<CM_CreditHistoryForACorDPD__c>(); 
        credHis.add(new CM_CreditHistoryForACorDPD__c(
            BureauResponse__c = bureauResRecrds[0].Id,
            ACorDPD__c = 'Test'
        ));
        TriggerBase.bypass('CM_CreditHistoryForACorDPD__c');
        insert credHis;
        TriggerBase.clearBypass('CM_CreditHistoryForACorDPD__c'); 
    }
    
     @isTest
    static void cloneBureauDataTwoJobTestMethod() {
        
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
        
        
        CloneBureauDataTwoJob cloneJob = new CloneBureauDataTwoJob(inputData, loanApp.Id, clonedLoanAppId);
        
        Test.startTest();
        // Enqueue job
        System.enqueueJob(cloneJob);
        Test.stopTest();
        
        List<CM_CreditHistoryForACorDPD__c> clonedApplRegulatorieCredHisAcorDPD = [SELECT Id, BureauResponse__c FROM CM_CreditHistoryForACorDPD__c WHERE BureauResponse__c = :bureauRes.Id];
        System.assertEquals(2, clonedApplRegulatorieCredHisAcorDPD.size(), 'Credit History For Ac or DPD should be cloned.');
        
       CloneBureauDataTwoJob jobneww = new CloneBureauDataTwoJob(null,null,null);
            System.enqueueJob(jobneww);   
        
        Boolean isAssert = true;
        try{
            CloneBureauDataTwoJob jobnew = new CloneBureauDataTwoJob(null,null,null);
            System.enqueueJob(jobnew);   
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    } 
}