@isTest
public class SMSWrapperTest {
    @isTest
    static void testSMSWrapperDeserialization() {
        
        String jsonResponse = '{"result":{"req_id":"123", "msisdn":"9876543210", "status":{"statusCode":"0"}}}';
        Test.startTest();
        
        try {
            SMSWrapper.Response responseWrapper = (SMSWrapper.Response) JSON.deserialize(jsonResponse, SMSWrapper.Response.class);
            // Add assertions for the deserialized values
            
            System.assertEquals('123', responseWrapper.result.req_id, 'req_id should be "123"');
            
            System.assertEquals('9876543210', responseWrapper.result.msisdn, 'msisdn should be "9876543210"');
            
            System.assertEquals('0', responseWrapper.result.status.statusCode, 'statusCode should be "0"');
            
        } catch (Exception e) {
            System.assert(false, 'Exception not expected: ' + e.getMessage());
        }
        Test.stopTest();
    }
}