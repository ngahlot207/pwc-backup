@isTest
public class PaytmRequestGeneratorTest {

    @isTest
    static void testGenerate() {
        // Test data setup
       LoanAppl__c loanApp=TestDataFactory.createLoanApplication(true);
       // Applicant__c appl=TestDataFactory.createSingleApplicant(true,loanApp.Id);
      //	  List<IntgMsg__c> IntgMsgData=TestDataFactory.createIntegrationMessage(true,appl.Id);
        
        ApplIMD__c applIMD = TestDataFactory.createApplIMD(loanApp.id);
        Payment__c payment = TestDataFactory.createPayment(loanApp.id);
        
        IntgMsg__c intgMsg1 = TestDataFactory.createIntgMsg(applIMD.Id, 'ApplIMD__c');
        IntgMsg__c intgMsg2 = TestDataFactory.createIntgMsg(payment.Id, 'Payment__c');

        // Test the generate method
        Test.startTest();
        PaytmRequestGenerator paytmGenerator = new PaytmRequestGenerator();
        paytmGenerator.generate(new List<IntgMsg__c>{intgMsg1, intgMsg2}, 'Service', 'ProcessType');
        Test.stopTest();

        // Verify the generated data
        IntgMsg__c updatedIntgMsg1 = [SELECT Id, Req__c, Status__c FROM IntgMsg__c WHERE Id = :intgMsg1.Id LIMIT 1];
        IntgMsg__c updatedIntgMsg2 = [SELECT Id, Req__c, Status__c FROM IntgMsg__c WHERE Id = :intgMsg2.Id LIMIT 1];

        System.assertNotEquals(null, updatedIntgMsg1.Req__c);
        System.assertEquals(GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS, updatedIntgMsg1.Status__c);

        System.assertNotEquals(null, updatedIntgMsg2.Req__c);
        System.assertEquals(GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS, updatedIntgMsg2.Status__c);
    }
}