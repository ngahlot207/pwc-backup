@isTest

private class KarzaErrorResponseControllerTest {
	@isTest
	static void testParse() {
		String json = '{"requestId":"12345","status":500,"error":"Internal Server Error","clientData":{"caseId":"67890"}}';
		KarzaErrorResponseController.KarzaErrorResponseWrapper result = KarzaErrorResponseController.parse(json);
		System.assertEquals('12345', result.requestId);
		System.assertEquals(500, result.status);
		System.assertEquals('Internal Server Error', result.error);
		System.assertEquals('67890', result.clientData.caseId);
	}
	@isTest
	static void testGetErrorMessage() {
        IntgMsg__c integrationMessage = new IntgMsg__c(Resp__c = '{"requestId":"12345","status":400,"error":"Bad Request","clientData":{"caseId":"67890"}}');
        Test.startTest();
        String errorMessage = KarzaErrorResponseController.getErrorMessage(integrationMessage);
        Test.stopTest();
        System.assertEquals('Bad Request', errorMessage);

  }

}