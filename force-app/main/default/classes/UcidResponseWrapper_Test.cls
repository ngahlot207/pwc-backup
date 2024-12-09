@isTest
public class UcidResponseWrapper_Test {

  
    @isTest
     static void testUcidResponseWrapperParsing() {
        // Create a sample JSON string for testing
        String jsonString = '{"code": 200, "requestId": "e0a2a8e7-a1db-49d9-8eb7-9d3339fc71ad", "success": "true", "message": "Record matched successfully", "ucid": "13006101"}';

        // Call the parse method from UcidResponseWrapper class
        UcidResponseWrapper.parse(jsonString);
	

       
    }

   
}