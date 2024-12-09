@isTest
private class IMDControllerTest {
    
    @isTest
    static void testValidateAmount() {
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        loan.IMDAmount__c = 1000;
        update loan;
        
        ApplIMD__c testIMD = new ApplIMD__c(
            LoanAppln__c = loan.Id,
            IMDAmt__c = 1000,
            InstrumentAmt__c = 1000,
            PaymentMode__c = 'Payment Gateway'
        );
        
        Test.startTest();
        IMDController.validateAmount(new List<ApplIMD__c>{testIMD} ,loan);
        Test.stopTest();
        
        testIMD = [SELECT Id,IMDAmt__c FROM ApplIMD__c WHERE Id = :testIMD.Id];
        System.assertEquals(1000, testIMD.IMDAmt__c);
    } 
    @isTest
    static void testValidateAmount_Exception() {
        LoanAppl__c testLoan = TestDataFactory.createLoanApplication(true);
        testLoan.IMDAmount__c = 2000;
        update testLoan;
        
        ApplIMD__c testIMD = new ApplIMD__c(
            LoanAppln__c = testLoan.Id,
            IMDAmt__c = 1000,
            InstrumentAmt__c = 1000,
            PaymentMode__c = 'Payment Gateway'
        );
        
        Test.startTest();

        try {
            IMDController.validateAmount(new List<ApplIMD__c>{testIMD} ,testLoan );
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
}