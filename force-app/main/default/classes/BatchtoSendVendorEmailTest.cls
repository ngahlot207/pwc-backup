@isTest
public class BatchtoSendVendorEmailTest {
	 @isTest
    static void testBatchToSendVendorEmail(){
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@gmail.com'
        );
        insert testContact;

        User testUser = new User(
            FirstName = 'TestL',
            LastName = 'UserL',
            Email = 'testuserL@example.com',
            Alias = 'tuserL',
            Username = 'testuserL@example.com',
            CommunityNickname = 'tuserL',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id
        );
        insert testUser;

        List<Case> testCases = new List<Case>();
        for (Integer i = 0; i < 2; i++) {
            testCases.add(new Case(
                ContactId = testContact.Id,
                RecordType = new RecordType(Name = 'CPVFI')
            ));
        }
        insert testCases;

        Test.startTest();

        BatchtoSendVendorEmail batchJob = new BatchtoSendVendorEmail();
        Database.executeBatch(batchJob);

        Test.stopTest();
    }
}