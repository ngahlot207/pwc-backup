@isTest
private class RegulatoryHandlerTest {
    
    // Utility method to create a test RegulatoryCreateWrapper object
    private static RegulatoryCreateWrapper createWrapper() {
        RegulatoryCreateWrapper wrapObj= new RegulatoryCreateWrapper();
            wrapObj.IsBorowrOrRelFFDir = 'true';
            wrapObj.CharDiscrmtn = 'Sample Discrimination';
            wrapObj.DealngIndstry = 'Sample Industry';
            wrapObj.Desgntn = 'Sample Designation';
            wrapObj.FundInESGPol = 'Sample Fund in ESG Policy';
            wrapObj.FFDirRelIntrstAsPart = 'Sample Interest as Partner';
            wrapObj.FFDirRelIntrstAsSH = 'Sample Interest as Shareholder';
            wrapObj.DirName = 'Sample Director Name';
            wrapObj.Reltnshp = 'Sample Relationship';
        return wrapObj;
    }
    

    @isTest
    static void testCreateRegulatoryRecordSuccess() {
        // Set up test data
        RegulatoryCreateWrapper wrapObj = createWrapper();

        Test.startTest();
        // Call the method we want to test
        String resultId = RegulatoryHandler.createRegulatoryRecord(wrapObj);
        Test.stopTest();

        // Verify behavior
        ApplRegltry__c[] createdRecords = [SELECT Id, IsBorowrOrRelFFDir__c FROM ApplRegltry__c WHERE Id = :resultId];
    }

    @isTest
    static void testCreateRegulatoryRecordFailure() {
        // Create wrapper with invalid data (simulate failure)
        RegulatoryCreateWrapper wrapObj = createWrapper();
        wrapObj.DirName = ''; // Assuming this is a required field that will cause an exception if empty

        String expectedError = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
        
        Test.startTest();
        // Call the method and expect an exception
        try {
            String resultId = RegulatoryHandler.createRegulatoryRecord(wrapObj);
        } catch (Exception e) {
            System.assert(e.getMessage().contains(expectedError), 'The exception should contain the expected error message.');
        }
        Test.stopTest();
    }
}