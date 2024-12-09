@isTest
public class HunterTokenRequestGeneratorTest {
    
    @isTest
    static void testGenerate() {
        // Create test data
        IntgMsg__c testIntgMsg = new IntgMsg__c(Status__c = 'In Progress');
        
        insert testIntgMsg;

        // Set up mock callout response
        Test.setMock(HttpCalloutMock.class, new HunterTokenRequestGeneratorMock());

        // Call the generate method in the test
        Test.startTest();
        HunterTokenRequestGenerator generator = new HunterTokenRequestGenerator();
        generator.generate(new List<IntgMsg__c>{testIntgMsg}, 'HunterService', 'ProcessType');
        Test.stopTest();

    }


// Mock HTTP callout class for generating a mock response

    public class HunterTokenRequestGeneratorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
       		res.setBody('{"access_token": "mockAccessToken", "expires_in": 3600, "token_type": "Bearer"}');
            res.setStatusCode(200);
           // res.setBody('{"ScreeningRequestData": {"ApiToken": "dummyToken"}}');
            return res;
        }
    }
}