@isTest
public class AddTrancheDisResponseWrapperTest {

    @isTest
    static void testParsing() {
        // Create a sample JSON string for testing
        
        String sampleJson ='{"disbursalDetail":{"applicationID":"588310","errorcode":"DWS0001","errorDescription":"Disbursal Amount for this tranche exceeds available disbursal amount."},"unqRequestId":"729317327"}';
        
        // Parse the JSON string
        AddTrancheDisResponseWrapper result = AddTrancheDisResponseWrapper.parse(sampleJson);

        // Perform assertions based on your requirements
        System.assertEquals('588310', result.disbursalDetail.applicationID);
        // Add more assertions as needed for other fields
    }
    
}