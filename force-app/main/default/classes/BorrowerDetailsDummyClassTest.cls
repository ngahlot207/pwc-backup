@isTest
public class BorrowerDetailsDummyClassTest {
    
  @isTest
    static void testParseMethod() {
        // Define a sample JSON string to test parsing
        String sampleJson = '{"customerInfo":{"name":"Sample Company","address":"123 Main St"},"statementdetails":[{"fileName":"SampleFile.pdf","statementStatus":"VERIFIED","statementAccounts":[{"accountNo":"123456789","accountType":"Bank","xnsStartDate":"2022-01-01","xnsEndDate":"2022-12-31"}]}]}';

        // Call the parse method to deserialize the JSON string
        BorrowerDetailsDummyClass responseWrapper = BorrowerDetailsDummyClass.parse(sampleJson);   
    }
}