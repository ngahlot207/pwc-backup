@isTest
public class CaseUpdationTriggerHandlerTest {

    @isTest
    static void testBeforeInsertTriggerHandler() {
        
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'CEO' Limit 1];
        User adminUser = [Select Id, UserRoleId,IsActive From User Where Profile.Name='System Administrator' AND IsActive = true Limit 1];

        adminUser.UserRoleId = userRole.Id;
        update adminUser;
		
        System.runAs(adminUser){
            
            // Test data setup
            RecordType caseRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' LIMIT 1];
            LocMstr__c locMaster = new LocMstr__c(CityId__c = 'TestCityId');
            insert locMaster;
    
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;
            Account testAccount1 = new Account(Name = 'Test Account');
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            testAccount1.RecordTypeId = recordTypeId;
            insert testAccount1;
            BankBrchMstr__c bank = new BankBrchMstr__c();
            bank.City__c='Test City';
            insert bank;
    
            Contact testContact = new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                AccountId = testAccount.Id,
                RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' LIMIT 1].Id,
                IsActive__c = true
            );
            insert testContact;
            
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
        
            insert u;
            
            // Query the user to ensure the role has been assigned
            User queriedUser = [SELECT Id, UserRoleId FROM User WHERE Id = :u.Id LIMIT 1];
    
            AgncLocMap__c testAgncLocMap = new AgncLocMap__c(
                Account__c = testAccount1.Id, // Assign the created account's ID
                // Set other necessary fields
                IsActive__c = true,
                StartDate__c = Date.today().addDays(-1),
                EndDate__c = Date.today().addDays(1),
                BankBrchMst__c = bank.Id,
                LocationMaster__c=locMaster.Id,
                AgencyType__c = 'CPVFI'  
            );
            insert testAgncLocMap; 
            
			Id caseRecordType1 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CPVFI').getRecordTypeId();            
            Case testCase = new Case(
                Subject = 'Test Case',
                CityId__c = locMaster.Id, // Assign the created LocMstr__c record's ID
                RecordTypeId = caseRecordType1,
                IsRouRobAllowd__c = true
            );
            
            Case testCase1 = new Case(
                Subject = 'Test Case',
                CityId__c = locMaster.Id, // Assign the created LocMstr__c record's ID
                RecordTypeId = caseRecordType1, 
                IsRouRobAllowd__c = true
            );
    
            // Test execution 
            Test.startTest();               
            CaseUpdationTriggerHandler.BeforeInsert(new List<Case>{ testCase,testCase1 });
            Test.stopTest();
            
            system.debug('testCase ----'+testCase);
            
            // Assertions
            System.assertEquals(false, testCase.IsRouRobAllowd__c);
            System.assertEquals(false, testCase1.IsRouRobAllowd__c);
             
        }
    }
}