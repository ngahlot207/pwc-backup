@isTest
public class TrackwizzCKYCCallbackResponseProcTest{

    @isTest
    static void testProcess() {
        // Create test data
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loan.Id);
        DocMstr__c dm =  TestDataFactory.DocumentMasterData(true);
        applicant.CKYC_Number__c = 'CKYCID1';
        upsert applicant;
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String jsonResponse = '{"apiToken": "ApiToken","requestId":"a94e7144-c1ea-450a-8525-3ad9fa63c556","parentCompany": "TSS","sourceSystem": "Finacle","screeningCaseRequestTransactions": [{ "transactionId": "f9d1e6a6-05ff-4075-a690-babbbe543c12", "recordIdentifier": null,"caseId": 1, "caseUrl": "www.google.com/1", "finalDecision": "AcceptBusiness", "pepCode": "NotAPEP","pepClassificationCode": "CORPE 3", "adverseMediaClassificationCode": "16", "reputationalClassificationCode": "TW02","Pep": "Not A PEP", "pepClassification": "UBO / AP is domestic PEP,Foreign PEP, CURRENT OR FORMER MP, MLA OR MLC", "adverseMediaClassification": "Economic Offence Wing (EOW), Corruption","reputationalClassification": "Regulatory Enforcement, Other Bodies", "finalRemarks": null, "approvedOn": "25-May-2021 12:09","approvedBy": "Nate Johnson"}]}';
        IntgMsg__c integrationMessage = new IntgMsg__c(
            Appl__c = applicant.Id,
            Svc__c = 'CKYC API',
            Req__c = jsonResponse,
            Status__c = 'New'
        );
        insert integrationMessage;
		    Applicant__c appl = new Applicant__c();
        	List<Applicant__c> updateApplList = new List<Applicant__c>();
                            appl.Id = applicant.id;
                            appl.CKYC_Number__c ='CKYCID1';
                            updateApplList.add(appl);
        
        // Call the process method
        Test.startTest();
        TrackwizzCKYCCallbackResponseProcessor.process(new List<IntgMsg__c>{ integrationMessage });
        Test.stopTest();

        // Verify the expected behavior
        Applicant__c updatedApplicant = [SELECT Id, CKYC_Number__c FROM Applicant__c WHERE Id = :applicant.Id LIMIT 1];
        System.assertNotEquals(null, updatedApplicant);
        System.assertEquals('CKYCID1', updatedApplicant.CKYC_Number__c);
    }

    @isTest
    static void testGetCustomerCKYCStatusJsonFormat() {
        // Create test data
        String xmlResponse = '<?xml version="1.0" encoding="utf-8"?><CustomerNewCKYCStatusRequest><RequestId>RequestId1</RequestId><APIToken>APIToken1</APIToken><CustomerNewCKYCStatusRequestDetails><CustomerNewCKYCStatusRequestDetail><TransactionId>123</TransactionId><SourceSystemName>SourceSystemName1</SourceSystemName><SourceSystemCoustomerCode>SourceSystemCoustomerCode1</SourceSystemCoustomerCode><StepCode>StepCode1</StepCode><StepName>StepName1</StepName><StepCategory>StepCategory1</StepCategory><CKYCID>CKYCID1</CKYCID><CKYCAccountType>CKYCAccountType1</CKYCAccountType><CaseURL>CaseURL1</CaseURL><CaseID>12345</CaseID></CustomerNewCKYCStatusRequestDetail></CustomerNewCKYCStatusRequestDetails></CustomerNewCKYCStatusRequest>';

        // Call the getCustomerCKYCStatusJsonFormat method
        Map<String, TrackwizzCKYCCallbackResponseProcessor.CustomerNewCKYCStatusWrapper> responseMap = TrackwizzCKYCCallbackResponseProcessor.getCustomerCKYCStatusJsonFormat(xmlResponse);

        // Verify the expected behavior
        System.assertNotEquals(null, responseMap);
        System.assertEquals(1, responseMap.size());
        TrackwizzCKYCCallbackResponseProcessor.CustomerNewCKYCStatusWrapper response = responseMap.values()[0];
        System.assertEquals('123', response.TransactionId);
        System.assertEquals('SourceSystemName1', response.SourceSystemName);
        System.assertEquals('SourceSystemCoustomerCode1', response.SourceSystemCoustomerCode);
        // Add more assertions for other fields
    }

    @isTest
    static void testProcessTrackwizzCKYCResponse() {
        // Create test data
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loan.Id);
        applicant.CKYC_Number__c = 'CKYCID1';
        upsert applicant;

        TrackwizzCKYCCallbackResponseProcessor.CustomerNewCKYCStatusWrapper response = new TrackwizzCKYCCallbackResponseProcessor.CustomerNewCKYCStatusWrapper();
        response.TransactionId = '123';
        response.SourceSystemName = 'SourceSystemName1';
        response.SourceSystemCoustomerCode = 'SourceSystemCoustomerCode1';
        response.StepCode = 'StepCode1';
        response.StepName = 'StepName1';
        response.StepCategory = 'StepCategory1';
        response.CKYCID = 'CKYCID1';
        response.CKYCAccountType = 'CKYCAccountType1';
        response.CaseURL = 'CaseURL1';
        response.CaseID = '12345';

        Map<String, TrackwizzCKYCCallbackResponseProcessor.CustomerNewCKYCStatusWrapper> responseMap = new Map<String, TrackwizzCKYCCallbackResponseProcessor.CustomerNewCKYCStatusWrapper>();
        responseMap.put(response.TransactionId, response);

        // Call the processTrackwizzCKYCResponse method
        Test.startTest();
        //TrackwizzCKYCCallbackResponseProcessor.processTrackwizzCKYCResponse(responseMap);
        Test.stopTest();

        // Verify the expected behavior
        Applicant__c updatedApplicant = [SELECT Id, CKYC_Number__c FROM Applicant__c WHERE Id = :applicant.Id LIMIT 1];
        System.assertNotEquals(null, updatedApplicant);
        System.assertEquals('CKYCID1', updatedApplicant.CKYC_Number__c);
    }
        private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Create a mock response with status code 200
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"response": "Mock Response"}');
            return res;
        }
    }
}