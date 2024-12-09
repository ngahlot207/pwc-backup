@isTest
public class HunterTokenResponseProcessorTest {
    @isTest
    static void testProcess() {
        
        List<IntgMsg__c> testResponseList = new List<IntgMsg__c>();
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        
        // Create a test response
        IntgMsg__c testResponse = new IntgMsg__c();
        testResponse.Name = 'Hunter Token';
        testResponse.RefId__c = appli.Id;
        testResponse.RefObj__c = 'Applicant__c';
        testResponse.Status__c = 'Responded';
        testResponse.MStatus__c = 'Acknowledged';
        testResponse.Svc__c = 'Hunter Token';
        testResponse.BU__c = 'HL / STL';
        testResponse.Resp__c = '{"issued_at":"1702464329","expires_in":"1800","token_type":"Bearer","access_token":"testaccesstoken","refresh_token":"testrefreshtoken"}';
        testResponseList.add(testResponse);
        
        // Insert the test response list
        insert testResponseList;

        // Call the process method with the test response
        Test.startTest();
        HunterTokenResponseProcessor.process(testResponseList);
        Test.stopTest();
 
    }
}