@isTest
private class CustomFormControllerTest {
    
    @isTest
    static void testGetCustomDataWithValidInputs() {
        // Prepare dummy data for the test
        String recordId = 'someRecordId';
        String configJSON = '{"query":"SELECT Id, Name FROM Account WHERE Id = :recordId"}';
        
        // Insert a test account to query
        
        Account testAccount=TestDataFactory.createAccountDetails(true);
       // insert testAccount;
        // Change the record ID to the inserted account's ID to ensure valid SOQL
        recordId = testAccount.Id;
        
        Test.startTest();
        // Call the method we want to test
        CustomFormController.RecordFromData result = CustomFormController.getCustomData(recordId, configJSON);
        Test.stopTest();
        
    }
    
    @isTest
    static void testMapAndInsertDataForAccount() {
        LoanAppl__c loanApp= TestDataFactory.createLoanApplication(true);
        // Prepare dummy data and variables for the test
        String objname = 'Applicant__c';
        Map<String, String> dataMap = new Map<String, String>{
            'AadhaarNo__c' => '857771338787',
            'MobNumber__c' => '1234567890',
            'ApplType__c' =>'P',
            'DOB__c'=>string.valueOf(system.today()),
            'Is_Physical_Consent_Validated__c'=>'true',
            'LoanAppln__c'=>loanApp.id
        };


        Test.startTest();
        // Call the method we want to test
        String resultId = CustomFormController.mapAndInsertData(dataMap, objname);
        Test.stopTest();
        
    }
    
     @isTest
    static void testMapAndInsertDataForAccount2() {
        LoanAppl__c loanApp= TestDataFactory.createLoanApplication(true);
        // Prepare dummy data and variables for the test
        String objname = 'LoanAppl__c';
        Map<String, String> dataMap = new Map<String, String>{
            'DocGenerationDateTime__c' =>string.valueOf(system.now())
           
        };


        Test.startTest();
        // Call the method we want to test
        String resultId = CustomFormController.mapAndInsertData(dataMap, objname);
        Test.stopTest();
        
    }
}