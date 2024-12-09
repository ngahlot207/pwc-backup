@isTest
private class ScreeningRequestGeneratorTest {

    @isTest
    static void testGenerate() {
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c appl = TestDataFactory.createSingleApplicant(true, loan.Id);
        
        // Create a test Integration Message record
        IntgMsg__c intgMsg = new IntgMsg__c(
            Svc__c = 'Screening API',
            ParentRefId__c = loan.Id,
            RefId__c = String.valueOf(appl.Id),
            Status__c = 'In Progress'
        );
        insert intgMsg;

        // Set up a mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the generate method
        Test.startTest();
        ScreeningRequestGenerator generator = new ScreeningRequestGenerator();
        generator.generate(new List<IntgMsg__c>{intgMsg}, 'Test Service', 'Test Process Type');
        Test.stopTest();

        System.assertEquals(GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS, intgMsg.Status__c);
    }

    // MockHttpResponseGenerator is a simple implementation of HttpCalloutMock for testing
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"ScreeningRequestData": {"ApiToken": "dummyToken"}}');
            return res;
        }
    }
}