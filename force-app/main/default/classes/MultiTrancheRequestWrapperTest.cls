@isTest
public class MultiTrancheRequestWrapperTest {

     @isTest
    static void testParseMethod() {
        // Create sample JSON data to deserialize
        String sampleJSON = '{'
    +'"LANNo": "FEDMUMSTL0503813"'+
 '}';
        
        // Call the parse method
        MultiTrancheRequestWrapper parsedWrapper = MultiTrancheRequestWrapper.parse(sampleJSON);

        // Validate if the parsing was successful
        System.assertNotEquals(null, parsedWrapper);
        
    }
}