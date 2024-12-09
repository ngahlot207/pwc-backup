@isTest
private class SanctionControllerTest {
    @isTest
    private static void testUpsertSanctionConditions() {
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        Sanction_Conditions_Master__c sc = TestDataFactory.createsanctionmaster(true);
       Applicant__c appl= TestDataFactory.createSingleApplicant(true,la.id);
		DocMstr__c docMst = TestDataFactory.createDocumentMaster(true,'');
        docMst.DocTyp__c = 'Manual Sanction';
        docMst.Catgry__c = 'Sanction Condition Documents';
        update docMst;
        // Test data preparation
        Sanction_Conditions__c testRecord = new Sanction_Conditions__c();
            testRecord.Remarks__c = 'Test Remarks';
            testRecord.Loan_Application__c= la.id;
            testRecord.Sanction_Con_Master__c = sc.id;
            testRecord.Condition__c = docMst.id;
        insert testRecord;
        DocDtl__c docRec = new DocDtl__c();
        docRec.SancCond__c=testRecord.Id;
        docRec.LAN__c=la.Id;
        docRec.Appl__c=appl.Id;
        insert docRec;
        List<Sanction_Conditions__c> testRecords = new List<Sanction_Conditions__c>{testRecord};

        // Call the method to test
        System.Test.startTest();
        String result = SanctionController.upsertSanctionConditions(testRecords);
        SanctionController.getRelatedRecords(la.id);
        SanctionController.deleteRecord(testRecord.Id);
        System.Test.stopTest();
    }
}