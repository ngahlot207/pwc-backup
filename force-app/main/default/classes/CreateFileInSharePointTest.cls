@isTest
public class CreateFileInSharePointTest {
    private static Boolean calloutMade = false;
    
    @isTest
    static void testCreateFiles() {
        // Prepare test data
        Blob fileData = Blob.valueOf('Test file content');
        String folderName = 'TestFolder';
        String fileName = 'TestFile.txt';
        
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call the method to be tested
        Test.startTest();
        CreateFileInSharePoint.createFiles(fileData, folderName, fileName);
        Test.stopTest();
        
        // Add an assertion based on the boolean flag to indirectly check if the callout was made
        System.assert(calloutMade, 'Callout was not made');
    }
    
    // Create a mock response generator implementing HttpCalloutMock
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement the respond method to provide a mock response
        public HTTPResponse respond(HTTPRequest req) {
            // Set the flag to true when the callout is made
            calloutMade = true;
            
            // Create a mock HTTPResponse
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('Mock response body');
            return res;
        }
    }
}