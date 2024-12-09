@isTest
public class IntOCRAdharServiceResponseWrapperTest {

    @isTest
    static void testParseMethod() {
        String jsonInput = '{"requestId": "123456", "result": [{"type": "Adhaar", "details": {"aadhaar": {"conf": "1", "isMasked": "false", "value": "123456789012"} } } ], "statusCode": 200}';
        
        // Call the parse method and verify the output
        Test.startTest();
        IntOCRAdharServiceResponseWrapper wrapper = IntOCRAdharServiceResponseWrapper.parse(jsonInput);
        Test.stopTest();
        
        // Perform assertions to verify the parsed response
        System.assertEquals('123456', wrapper.requestId);
        System.assertEquals(1, wrapper.result.size());
        System.assertEquals('Adhaar', wrapper.result[0].type);
        System.assertEquals('1', wrapper.result[0].details.aadhaar.conf);
        System.assertEquals('false', wrapper.result[0].details.aadhaar.isMasked);
        System.assertEquals('123456789012', wrapper.result[0].details.aadhaar.value);
        System.assertEquals(200, wrapper.statusCode);
    }


}