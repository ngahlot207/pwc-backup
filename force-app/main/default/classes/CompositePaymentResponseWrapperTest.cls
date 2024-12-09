@isTest
public class CompositePaymentResponseWrapperTest {

    @isTest
    static void testParse() {
        // Create a sample JSON string for testing
        String json = '{"ActCode": "123", "Response": "Success", "BankRRN": "456", "BeneName": "John Doe", "success": "true", "TransRefNo": "789", "errorCode": "E001", "description": "Error Description"}';

        // Call the parse method
        CompositePaymentResponseWrapper result = CompositePaymentResponseWrapper.parse(json);

        // Add assertions to verify the parsed values
        System.assertEquals('123', result.ActCode, 'ActCode should match');
        System.assertEquals('Success', result.Response, 'Response should match');
        System.assertEquals('456', result.BankRRN, 'BankRRN should match');
        System.assertEquals('John Doe', result.BeneName, 'BeneName should match');
        System.assertEquals('true', result.success, 'Success should match');
        System.assertEquals('789', result.TransRefNo, 'TransRefNo should match');
        System.assertEquals('E001', result.errorCode, 'ErrorCode should match');
        System.assertEquals('Error Description', result.description, 'Description should match');
    }
}