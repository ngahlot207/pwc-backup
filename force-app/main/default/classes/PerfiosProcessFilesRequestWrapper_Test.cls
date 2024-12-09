@isTest
public class PerfiosProcessFilesRequestWrapper_Test {
    
    


    @isTest
    static void parse_ValidJson_ReturnsWrapperObject() {
        // Create test JSON data
        String jsonString = '{"payload": {"fileId": "09133d7543de5df7f610ec28c1a334d39f61306c","password": "topSecret!"}}';

        // Call the parse method from PerfiosProcessFilesRequestWrapper class
        PerfiosProcessFilesRequestWrapper result = PerfiosProcessFilesRequestWrapper.parse(jsonString);

        // Verify that the result is not null
        System.assertNotEquals(null, result);
        // Add more assertions here to validate the parsed data if needed
    }
}