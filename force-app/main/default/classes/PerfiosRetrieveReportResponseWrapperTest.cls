@isTest
public class PerfiosRetrieveReportResponseWrapperTest {

    @isTest
    static void testParseMethod() {
        // Define a sample JSON string to test parsing
        String sampleJson = '{"customerInfo":{"name":"Sample Company","address":"123 Main St"},"statementdetails":[{"fileName":"SampleFile.pdf","statementStatus":"VERIFIED","statementAccounts":[{"accountNo":"123456789","accountType":"Bank","xnsStartDate":"2022-01-01","xnsEndDate":"2022-12-31"}]}]}';

        // Call the parse method to deserialize the JSON string
        PerfiosRetrieveReportResponseWrapper responseWrapper = PerfiosRetrieveReportResponseWrapper.parse(sampleJson);

        // Assert statements to verify the deserialized object
        System.assertEquals('Sample Company', responseWrapper.customerInfo.name);
        System.assertEquals('SampleFile.pdf', responseWrapper.statementdetails[0].fileName);
        System.assertEquals('123456789', responseWrapper.statementdetails[0].statementAccounts[0].accountNo);
    }
}