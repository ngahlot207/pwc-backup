@isTest
public class IMDCallbackResponseProcessorTest {
    
    @isTest
    static void testPositiveCase() {
        IntgMsg__c testIntgMsg = new IntgMsg__c(Req__c = '{"sourceID":"SFDC","bounceReasonID":"null","realizationDate":"15-FEB-2024","bounceReasonDesc":"null","requestID":"123456","agreementID":"123456","chequeStatus":"CLEARED","failureDate":"null","remarks":""}',Status__c ='New');
        insert testIntgMsg;
        
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        insert new ApplIMD__c(FinnoneChequeId__c = '123',FinnoneRequestId__c='123456',LoanAppln__c = loan.Id);

        // Call the process method
        Test.startTest();
        IMDCallbackResponseProcessor.process(new List<IntgMsg__c>{ testIntgMsg });
        Test.stopTest();

        // Verify that the IntgMsg__c record is updated
        testIntgMsg = [SELECT Id, Status__c FROM IntgMsg__c WHERE Id = :testIntgMsg.Id];
        System.assertEquals('Processed', testIntgMsg.Status__c, 'Status should be updated to Processed');
    }

    @isTest
    static void testNegativeCase() {
        IntgMsg__c testIntgMsg = new IntgMsg__c(Status__c ='New');
        insert testIntgMsg;

        // Call the process method
        Test.startTest();  
        try {
            IMDCallbackResponseProcessor.process(new List<IntgMsg__c>{ testIntgMsg });
        } catch (Exception e) {
            // Expecting an exception due to the blank Req__c field
            System.assertNotEquals(null, e.getMessage(), 'An exception should be thrown');
        }
        Test.stopTest();

        // Verify that the IntgMsg__c record is not updated
        testIntgMsg = [SELECT Id, Status__c FROM IntgMsg__c WHERE Id = :testIntgMsg.Id]; 
        System.assertEquals('New', testIntgMsg.Status__c, 'Status should remain new');
    }

}