@istest
public class DomainNameProviderTest {
    @isTest
    Public Static Void domainNameProviderTestMethod(){
           UserRole r = [Select id,Name from UserRole WHERE Name = 'CEO'];
           List<User> lstUser = [SELECT ID,Name, Email FROM User WHERE ID =: UserInfo.getUserId()];
           User thisUser = [SELECT ID,UserRoleId  from USER Where ID =: UserInfo.getUserId()];
           thisUser.UserRoleId =  r.id;
           Update thisUser;
           User u1;
        
           System.runAs(thisUser){
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;
            Account testAccount1 = new Account(Name = 'Test Account');
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            testAccount1.RecordTypeId = recordTypeId;
            insert testAccount1;
            Contact testContact1 = new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                AccountId = testAccount1.Id,
                RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' LIMIT 1].Id,
                IsActive__c = true,
                StartDate__c = Date.today().addDays(-5),
                EndDate__c = Date.today().addDays(5)
            );
            insert testContact1;
            Profile p = [Select ID, Name from Profile Where Name = 'Agency Profile'];
        
            user u = New User(
                UserName = 'test_' + math.random() + '@test.com',
                FirstName = 'Test-First',
                LastName = 'Test-Last',
                Alias = 'test',
                email = 'test' + math.random() + '@test.com',
                CommunityNickName = string.valueOf(math.random()).substring(0,6),
                ProfileID = p.id,
                TimeZoneSidKey = 'America/New_York', 
                LocaleSidKey = 'en_US', 
                EmailEncodingKey = 'UTF-8', 
                LanguageLocaleKey = 'en_US',
                ContactID = testContact1.Id
                );
        	u.Role__c = 'mporw Partner Person Account';
        
            insert u;
        	System.runAs(u){
            DomainNameProvider.getLightningHostname();
            DomainNameProvider.getInstance();
            DomainNameProvider.getLightningDomain();
            DomainNameProvider.getVisualforceDomain();
    }
        
        
   }
    }
    //Standard User is used here for default condition 
    @isTest
    static void testDefaultDomainName() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            ProfileId = profile.Id,
            UserName = 'test_' + math.random() + '@test.com',
            FirstName = 'Test-First',
            LastName = 'Test-Last',
          	Alias = 'test',
            email = 'test' + math.random() + '@test.com',
            CommunityNickName = string.valueOf(math.random()).substring(0,6),
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        System.runAs(testUser) {
            DomainNameProvider.getLightningHostname();
            DomainNameProvider.getInstance();
            DomainNameProvider.getLightningDomain();
            DomainNameProvider.getVisualforceDomain();
        }
    }
    
      
}