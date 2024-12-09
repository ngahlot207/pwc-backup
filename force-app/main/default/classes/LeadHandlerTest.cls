@isTest
private class LeadHandlerTest {
    
    @isTest
    static void testCreateLeadRecord() {
        // Create a test profile
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        // Check if a valid profile is found
        if (testProfile == null) {
            throw new System.AssertException('Test Profile not found. Make sure you have a Profile named "Standard User".');
        }
        
        // Create a unique username for the test user
        String uniqueUsername = 'testuser' + DateTime.now().getTime() + '@example.com';
        
        // Create a test user
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = uniqueUsername,
            IsActive = true,
            TimeZoneSidKey = 'America/New_York', // Required field
            LocaleSidKey = 'en_US', // Required field
            EmailEncodingKey = 'UTF-8', // Required field
            ProfileId = testProfile.Id, // Required field
            LanguageLocaleKey = 'en_US' // Required field
        );
        insert testUser;
        
        LeadCreateWrapper testWrapper = new LeadCreateWrapper();
        testWrapper.mobile = '1234567890';
        testWrapper.leadStatus = 'New';
        testWrapper.rmNameId = testUser.Id; // Use the Id of the test user
        testWrapper.lastName = 'TestLastName'; // Set the last name for the test
        testWrapper.companyChange = 'TestCompany';
        testWrapper.assessedIncomeProgramValue = true; // Set assessedIncomeProgramValue
        testWrapper.tenure = 12; // Set a tenure value
        testWrapper.doiValue = Date.today(); // Set a DOI value
        testWrapper.dob = Date.newInstance(1990, 1, 1); // Set a DOB value
         testWrapper.assessedIncomeProgramValue = false; 
         testWrapper.cityService=true;
        
       
        
        // Set other properties of testWrapper as needed
        
//        Test.startTest();
        String result = LeadHandler.createLeadRecord(testWrapper);
   //     Test.stopTest();
        
        // Assert the result or perform further validation
        System.assertNotEquals(null, result);
        
        // Verify that a lead was actually created or updated
        List<Lead> createdLeads = [SELECT Id FROM Lead WHERE Id = :result LIMIT 1];
        System.assertEquals(1, createdLeads.size());
        
        
    }
}