@isTest
public class LoanBoardingResponseWrapperTest {

    @isTest
    static void testParseMethod() {
        // Create sample JSON data to deserialize
        String sampleJSON = '{ "applicationID": "APP001", "unqRequestId": "12345", "errorcode": "ERR001", "errorDescription": "Sample Error" }';
        
        // Call the parse method
        LoanBoardingResponseWrapper parsedWrapper = LoanBoardingResponseWrapper.parse(sampleJSON);

        // Validate if the parsing was successful
        System.assertNotEquals(null, parsedWrapper);
        System.assertEquals('APP001', parsedWrapper.applicationID);
        System.assertEquals('12345', parsedWrapper.unqRequestId);
        System.assertEquals('ERR001', parsedWrapper.errorcode);
        System.assertEquals('Sample Error', parsedWrapper.errorDescription);
        // Add more assertions for other fields as needed
    }
}