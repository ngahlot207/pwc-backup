@isTest
public class PerfiosProcessFilesResponseWrapper_test {

    

    @isTest
    static void parse_ValidJson_ReturnsWrapperObject() {
        // Create test JSON data
        String jsonString = '{"bankStatement": {"bankAccounts": [{"accountId": "fec4b3f2fd9fec90e03de0f564a34c37417df2af","accountNumber": "XXXXXXXXXXXX0297","accountType": "Current","complete": true,"institutionId": 30,"missingMonths": ["2023-06"]}]},"error": {"code": "CannotProcessFile","message": "We could not process the statement file uploaded by the Client","details": [{"code": "E_STATEMENT_WRONG_FORMAT","field": null,"message": "This statement contains images. Please upload again and select scanned images option.","value": null}]}}';

        // Call the parse method from PerfiosProcessFilesResponseWrapper class
        PerfiosProcessFilesResponseWrapper result = PerfiosProcessFilesResponseWrapper.parse(jsonString);

       
    }
    
    
    
    
}