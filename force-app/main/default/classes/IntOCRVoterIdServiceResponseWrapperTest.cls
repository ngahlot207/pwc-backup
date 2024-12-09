@isTest
private class IntOCRVoterIdServiceResponseWrapperTest {

    @isTest
    static void testParseMethod() {
        // Positive test case
        String jsonResponse = '{"statusCode": 200, "requestId": "12345", "result": [{"type": "voterId", "details": {"Name": {"value": "S131820140050271"}}}]}';

        Test.startTest();
        IntOCRVoterIdServiceResponseWrapper responseWrapper = (IntOCRVoterIdServiceResponseWrapper)JSON.deserialize(jsonResponse, IntOCRVoterIdServiceResponseWrapper.class);
        Test.stopTest();

        System.assertEquals(200, responseWrapper.statusCode);
        System.assertEquals('12345', responseWrapper.requestId);
        System.assertEquals(1, responseWrapper.result.size());
        System.assertEquals('voterId', responseWrapper.result[0].type);
        System.assertEquals('S131820140050271', responseWrapper.result[0].details.name.value);
    }

    @isTest
    static void testParseMethodInvalidJson() {
        // Negative test case: Invalid JSON
        String invalidJsonResponse = 'Invalid JSON';

        Test.startTest();
        try {
            IntOCRVoterIdServiceResponseWrapper responseWrapper = (IntOCRVoterIdServiceResponseWrapper) JSON.deserialize(invalidJsonResponse, IntOCRVoterIdServiceResponseWrapper.class);
            // If the above line executes without throwing an exception, the assertion will fail below
            System.assert(false, 'Expected JSON parsing exception was not thrown');
        } catch (System.JSONException e) {
            // JSON parsing exception should be caught here
            System.assert(e.getMessage() != null && e.getMessage().contains('Unexpected character'));
        }
        Test.stopTest();
    }

    @isTest
    static void testParseMethodMissingFields() {
        // Negative test case: Missing essential fields in JSON
        String jsonResponseMissingFields = '{"statusCode": 200}';

        Test.startTest();
        IntOCRVoterIdServiceResponseWrapper responseWrapper = (IntOCRVoterIdServiceResponseWrapper)JSON.deserialize(jsonResponseMissingFields, IntOCRVoterIdServiceResponseWrapper.class);
        Test.stopTest();

        // Ensure that the response is null when essential fields are missing
        System.assert(responseWrapper != null);
    }

    @isTest
    static void testAddressSplit() {
        // Positive test case for AddressSplit
        IntOCRVoterIdServiceResponseWrapper.AddressSplit addressSplit = new IntOCRVoterIdServiceResponseWrapper.AddressSplit();
        addressSplit.city = 'City';
        addressSplit.district = 'District';
        addressSplit.pin = '123456';
        addressSplit.locality = 'Locality';
        addressSplit.line2 = 'Line2';
        addressSplit.line1 = 'Line1';
        addressSplit.state = 'State';
        addressSplit.street = 'Street';
        addressSplit.landmark = 'Landmark';
        addressSplit.houseNumber = '123';

        System.assertEquals('City', addressSplit.city);
        System.assertEquals('District', addressSplit.district);
        System.assertEquals('123456', addressSplit.pin);
        System.assertEquals('Locality', addressSplit.locality);
        System.assertEquals('Line2', addressSplit.line2);
        System.assertEquals('Line1', addressSplit.line1);
        System.assertEquals('State', addressSplit.state);
        System.assertEquals('Street', addressSplit.street);
        System.assertEquals('Landmark', addressSplit.landmark);
        System.assertEquals('123', addressSplit.houseNumber);
    }
    
    @isTest
    static void testParseMethod1() {
        // Test JSON string to simulate the input
        String jsonString = '{"statusCode": 200, "requestId": "12345", "result": [{"type": "voterId", "details": {"Name": {"value": "S131820140050271"}}}]}';

        Test.startTest();
        IntOCRVoterIdServiceResponseWrapper responseWrapper = IntOCRVoterIdServiceResponseWrapper.parse(jsonString);
        Test.stopTest();

        System.assertNotEquals(null, responseWrapper);

        System.assertEquals(200, responseWrapper.statusCode);
        System.assertEquals('12345', responseWrapper.requestId);
        System.assertNotEquals(null, responseWrapper.result);
        System.assertEquals(1, responseWrapper.result.size());

        IntOCRVoterIdServiceResponseWrapper.Details details = responseWrapper.result[0].details;
        System.assertNotEquals(null, details);
        System.assertEquals('S131820140050271', details.name.value);
    }

}