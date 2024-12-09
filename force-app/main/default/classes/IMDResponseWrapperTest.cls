@isTest
public class IMDResponseWrapperTest {

    @isTest
    static void testParseValidJson() {
        // Create a valid JSON string
        String validJson = '{"requestId":"uwhpcUUx0ixaJpBhxGnsjy","status":"SUCCESS","applicationId":"586371","chequeId":"691627","errorcode":"0000","errorDescription":null}';

        // Call the parse method
        IMDResponseWrapper response = IMDResponseWrapper.parse(validJson);

        // Verify the expected behavior, e.g., check parsed fields
        System.assertEquals('uwhpcUUx0ixaJpBhxGnsjy', response.requestId);
        System.assertEquals('SUCCESS', response.status);
        System.assertEquals('586371', response.applicationId);
        System.assertEquals('691627', response.chequeId);
        System.assertEquals('0000', response.errorcode);
    }

    @isTest
    static void testParseInvalidJson() {
        // Create an invalid JSON string (customize as needed)
        String invalidJson = '{"requestId":"uwhpcUUx0ixaJpBhxGnsjy","status":"SUCCESS","applicationId":"586371","chequeId":"691627","errorcode":"0000",}';

        // Call the parse method
        try {
            IMDResponseWrapper response = IMDResponseWrapper.parse(invalidJson);
            // If the method doesn't throw an exception, fail the test
            System.assert(false, 'Expected System.JSONException was not thrown');
        } catch (System.JSONException ex) {
           
        }

    }
}