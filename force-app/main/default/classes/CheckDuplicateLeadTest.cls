@isTest
public class CheckDuplicateLeadTest {
    
     @isTest
    static void testGetDuplicateLeads() {
        // Create a test RestRequest
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/checkDuplicateLead/1234567890';
        request.httpMethod = 'GET';
        RestContext.request = request;
       // List<GlobalUtility.LeadDuplicateResponse> duplicateLeadsList = GlobalUtility.findDuplicateLeads('11222');
        // Create test data for the GlobalUtility.LeadDuplicateResponse
        // Ensure that you create appropriate test data in your org based on your use case

        // Call the method to be tested
         

        // Perform assertions based on the expected outcome
        // Example: assert the response contains certain expected values
       // System.assertEquals('ExpectedResult', result, 'The result does not match the expected outcome');
    }
    
    
    
    
  /*  @isTest
    static void testGetDuplicateLeads() {
        // Create a RestRequest object
       // RestRequest request = new RestRequest();
        //RestContext.request = request;

        // Create test data for the request URI
       // String testMobileNumber = '1234567890';
        //RestContext.request.requestURI = '/checkDuplicateLead/' + testMobileNumber;

        // Insert test data or prepare as required for the findDuplicateLeads method
        
       //system.Test.startTest();
       // String result = CheckDuplicateLead.getDuplicateLeads();
       //System.Test.stopTest();

        // Add assertions based on expected behavior and returned results
        //System.assertEquals('Expected result', result, 'Assertion Message');
    }*/
}