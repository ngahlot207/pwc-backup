@isTest
private class IncomeDetailsControllerTest {
    
     @testSetup
    static void setupTestData() {
       LoanAppl__c testLoanApp = new LoanAppl__c();
        insert testLoanApp;
 
        Applicant__c testApplicant=TestDataFactory.createSingleApplicant(false,testLoanApp.id);
        testApplicant.CustProfile__c = 'SELF EMPLOYED PROFESSIONAL';
        insert testApplicant;  
    }
    
    @isTest
    static void testGetSobjectDataWithMultipleChildRelation() {
        Test.startTest();
        Sobject result = incomeDetailsController.getSobjectDataWithMultipleChildRelation('SELECT Id FROM Applicant__c LIMIT 1');
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result should not be null');
       System.assertEquals('Applicant__c', result.getSObjectType().getDescribe().getName());
    }

    @isTest
    static void testGetSobjectDataWithMultipleChildRelationWithEmptyQuery() {
        Test.startTest();
        Sobject result = incomeDetailsController.getSobjectDataWithMultipleChildRelation('');
        Test.stopTest();
        System.assertEquals(null, result, 'Result should be null');
    }

}