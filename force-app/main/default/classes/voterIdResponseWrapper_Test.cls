@isTest
public class voterIdResponseWrapper_Test {


    @isTest
    static void testParseMethod() {
        // Create a sample JSON string to represent different scenarios
        String sampleJson = '{"requestId":"12345","result":{"name":"John Doe","gender":"Male","district":"XYZ","acName":"ABC","state":"PQR","epicNo":"56789"},"statusCode":200,"clientData":{"caseId":"98765"}}';
        
        // Call the parse method with the sample JSON
        voterIdResponseWrapper result = voterIdResponseWrapper.parse(sampleJson);

      
    }

  
}