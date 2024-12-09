@isTest
public class IntegrationInboundprocessorTest {

    @isTest
    static void testInboundProcess() {
        // Positive test cases

        // Create sample IntgMsg__c records for different services
        List<IntgMsg__c> intMsgList = new List<IntgMsg__c>();

        // Add Enach service record
        IntgMsg__c enachIntMsg = new IntgMsg__c(
            Name = 'Enach Status Callback',
            Status__c = 'New'
        );
        intMsgList.add(enachIntMsg);

        // Add IMD service record
        IntgMsg__c imdIntMsg = new IntgMsg__c(
            Name = 'IMD Cheque status',
             Status__c = 'New'
        );
        intMsgList.add(imdIntMsg);
        
        // Add Finnone Callback service record
        IntgMsg__c finIntMsg = new IntgMsg__c(
            Name = 'Finnone Callback',
             Status__c = 'New'
        );
        intMsgList.add(finIntMsg);
        
        // Add OTCPDDStatusUpdate service record
        IntgMsg__c otpIntMsg = new IntgMsg__c(
            Name = 'OTCPDDStatusUpdate',
             Status__c = 'New'
        );
        intMsgList.add(otpIntMsg);
        
        // Add Perfios Callback service record
        IntgMsg__c perfiosIntMsg = new IntgMsg__c(
            Name = 'Perfios Callback',
             Status__c = 'New'
        );
        intMsgList.add(perfiosIntMsg);
        
        // Add Trackwizz CKYC Callback service record
        IntgMsg__c trackIntMsg = new IntgMsg__c(
            Name = 'Trackwizz CKYC Callback',
             Status__c = 'New'
        );
        intMsgList.add(trackIntMsg);
        
        // Add paytm service record
        IntgMsg__c paytmIntMsg = new IntgMsg__c(
            Name = 'Paytmcallback',
             Status__c = 'New'
        );
        intMsgList.add(paytmIntMsg);

        Test.startTest();
        IntegrationInboundprocessor.inboundProcess(intMsgList);
        Test.stopTest();
    }
}