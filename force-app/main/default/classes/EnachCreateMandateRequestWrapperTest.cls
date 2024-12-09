@isTest
public class EnachCreateMandateRequestWrapperTest {

    @isTest
    static void testParse() {
        // Test data setup
        String json = '{"customer_identifier":"12345","auth_mode":"OTP","mandate_type":"ONE_TIME","corporate_config_id":"789","notify_customer":true,' +
                      '"mandate_data":{"maximum_amount":"1000","instrument_type":"ELECTRONIC","first_collection_date":"2024-02-20",' +
                      '"is_recurring":false,"frequency":"ONCE","management_category":"CATEGORY_A","customer_name":"John Doe",' +
                      '"customer_account_number":"9876543210","destination_bank_id":"456","destination_bank_name":"Bank ABC",' +
                      '"customer_account_type":"SAVINGS"},"expire_in_days":"30"}';

        // Call the parse method
        EnachCreateMandateRequestWrapper result = EnachCreateMandateRequestWrapper.parse(json);

        // Add assertions based on the expected behavior of your code
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('12345', result.customer_identifier, 'Customer Identifier should match');
        System.assertEquals('OTP', result.auth_mode, 'Auth Mode should match');
        System.assertEquals('ONE_TIME', result.mandate_type, 'Mandate Type should match');
        // Add more assertions as needed
    }
}