@isTest
public class EnachCreateMandateResponseProcessorTest {
    
    @isTest
    static void testProcess_Success() {
        // Test data setup
        IntgMsg__c integrationMessage = new IntgMsg__c();
        integrationMessage.Svc__c = 'mandate_create_form'; 
        integrationMessage.BU__c = 'HL / STL'; 
        integrationMessage.Resp__c = '{"mandate_id":"MockId", "state":"MockState"}'; 
        integrationMessage.Status__c = 'Responded'; 
        integrationMessage.RefObj__c = 'NACH__c'; 
        insert integrationMessage;
        
     
        IntgMsg__c integrationMessage1 = new IntgMsg__c();
        integrationMessage1.Svc__c = 'mandate_create_form'; 
        integrationMessage1.BU__c = 'HL / STL'; 
        integrationMessage1.Resp__c = '{"details":"EX240124195658871DOK","code":"REQUEST_VALIDATION_FAILED","message":"Invalid request for api mandate: Invalid IFSC or MICR code for Destination bank. Both collection amount and maximum amount can not be null. One of either has to be non null. "}'; 
        integrationMessage1.Status__c = 'Responded'; 
        integrationMessage1.RefObj__c = 'NACH__c'; 
        insert integrationMessage1;
        
        // Call the method to be tested
        Test.startTest();
        EnachCreateMandateResponseProcessor.process(new List<IntgMsg__c>{integrationMessage});
        EnachCreateMandateResponseProcessor.process(new List<IntgMsg__c>{integrationMessage1});
        Test.stopTest();
    }
    
    
}