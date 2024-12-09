@istest
public class CloneBureauDataThreeJobTest {
    
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
        
        List<CM_Person_Entity_Detail__c> persEntyDtl = new List<CM_Person_Entity_Detail__c>(); 
        persEntyDtl.add(new CM_Person_Entity_Detail__c(
            BureauResponse__c = bureauResRecrds[0].Id,
            Address__c = 'Test'
        ));
        TriggerBase.bypass('CM_Person_Entity_Detail__c');
        insert persEntyDtl;
        TriggerBase.clearBypass('CM_Person_Entity_Detail__c');
        
        List<CM_Person_Entity_Class_Activity__c> persEntClsAct = new List<CM_Person_Entity_Class_Activity__c	>();
        
        persEntClsAct.add(new CM_Person_Entity_Class_Activity__c(
            PersonEntity_Detail__c = persEntyDtl[0].Id,
            ClsActivityResponse__c = 'Test'
        ));
        TriggerBase.bypass('CM_Person_Entity_Class_Activity__c');
        insert persEntClsAct;
        TriggerBase.clearBypass('CM_Person_Entity_Class_Activity__c');
        
        List<CM_Person_Entity_ID_Detail__c> persEntIdDtls = new List<CM_Person_Entity_ID_Detail__c	>();
        
        persEntIdDtls.add(new CM_Person_Entity_ID_Detail__c(
            PersonEntity_Detail__c = persEntyDtl[0].Id,
            CIN__c = 'FGHJ8677BN'
        ));
        TriggerBase.bypass('CM_Person_Entity_ID_Detail__c');
        insert persEntIdDtls;
        TriggerBase.clearBypass('CM_Person_Entity_ID_Detail__c');
        
        List<CM_Borrower_Delinquency__c> borrDelqncy = new List<CM_Borrower_Delinquency__c	>();
        
        borrDelqncy.add(new CM_Borrower_Delinquency__c(
            PersonEntityDetail__c = persEntyDtl[0].Id,
            Relationship__c = 'Cousin'
        ));
        TriggerBase.bypass('CM_Borrower_Delinquency__c');
        insert borrDelqncy;
        TriggerBase.clearBypass('CM_Borrower_Delinquency__c');
        
        
        List<CM_LocationDetail__c> locaDtl = new List<CM_LocationDetail__c>(); 
        locaDtl.add(new CM_LocationDetail__c(
            BureauResponse__c = bureauResRecrds[0].Id,
            Message__c = 'test'
        ));
        TriggerBase.bypass('CM_LocationDetail__c');
        insert locaDtl;
        TriggerBase.clearBypass('CM_LocationDetail__c');
        
        List<CM_LocationInfo__c> locaInfo = new List<CM_LocationInfo__c>(); 
        locaInfo.add(new CM_LocationInfo__c(
            LocationDetail__c = locaDtl[0].Id,
            Address__c = 'test'
        ));
        TriggerBase.bypass('CM_LocationInfo__c');
        insert locaInfo;
        TriggerBase.clearBypass('CM_LocationInfo__c');
    }
    
    @isTest
    static void cloneBureauDataThreeJobTestMethod() {
        
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
        
        
        CloneBureauDataThreeJob cloneJob = new CloneBureauDataThreeJob(inputData, loanApp.Id, clonedLoanAppId);
        
        Test.startTest();
        // Enqueue job
        System.enqueueJob(cloneJob);
        Test.stopTest();
        
        List<CM_Person_Entity_Detail__c> clonedPersEntDtls = [SELECT Id, BureauResponse__c FROM CM_Person_Entity_Detail__c WHERE BureauResponse__c = :bureauRes.Id];
        System.assertEquals(2, clonedPersEntDtls.size(), 'Person Entity Details should be cloned.');
        
        Boolean isAssert = true;
        try{
            CloneBureauDataThreeJob jobnew = new CloneBureauDataThreeJob(null,null,null);
            System.enqueueJob(jobnew);   
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    } 
}