@isTest
public class MultiTrancheResponseWrapperTest {

    @isTest
    static void testParsing() {
        // Create a sample JSON string for testing
        

        String sampleJson ='{ "Data": [ { "CurrentPOS": "1290393.000", "CurrentOverdue": "0.000", "PendingEMIs": null, "DPD": "0", "Tranches": [{ "TranchID": "3", "Amount": "107250.00", "TranchDate": "2019-11-21T00:00:00", "Message": null, "CancelledDisbursals": "NO", "DisbursalStatus": "DISBURSED", "TotalDisbursalAmount": "0.000",'+
							'"ExcessAmount": "0.00000", "LoanTenure": "251" }]}], "status": 200, "message": "Success" }';

        // Parse the JSON string
        MultiTrancheResponseWrapper result = MultiTrancheResponseWrapper.parse(sampleJson);

        // Perform assertions based on your requirements
        System.assertEquals('107250.00', result.Data[0].Tranches[0].Amount);
        // Add more assertions as needed for other fields
    }
    
    
}