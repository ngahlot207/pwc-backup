@isTest
public class CreateLoanTeamForCaseTest {
    @isTest
    public static void testAfterInsert(){
        Profile testProfile = [SELECT Id FROM profile WHERE Name = 'LOS Base User' LIMIT 1];
        User testUser = new User(LastName = 'test user 1', 
                                 Username = 'test.createLoanTeamforCase@example.com', 
                                 Email = 'test.1@example.com', 
                                 Alias = 'testu1', 
                                 TimeZoneSidKey = 'GMT', 
                                 LocaleSidKey = 'en_GB', 
                                 EmailEncodingKey = 'ISO-8859-1', 
                                 ProfileId = testProfile.Id, 
                                 LanguageLocaleKey = 'en_US'); 
        
        insert testUser;
        User testUser1 = new User(LastName = 'test user 2', 
                                  Username = 'test.createLoanTeam.LHM@example.com', 
                                  Email = 'test.UW@example.com', 
                                  Alias = 'testu1', 
                                  TimeZoneSidKey = 'GMT', 
                                  LocaleSidKey = 'en_GB', 
                                  EmailEncodingKey = 'ISO-8859-1', 
                                  ProfileId = testProfile.Id, 
                                  LanguageLocaleKey = 'en_US'); 
        insert testUser1;
        system.runAs(testUser){
            BankBrchMstr__c bnkbranch=TestDataFactory.TestDataBankBranchMaster(true);
            BankBrchMstr__c bnkbranch1=TestDataFactory.TestDataBankBranchMaster1(true);
            TeamHierarchy__c TH= testDataFactory.TestDataTeamHierarchy_nonSup(true,testUser.id,bnkbranch.Id);// RM Role
            TH.Emprole__c = 'LHM';
            update TH;
            
            TeamHierarchy__c TH1= testDataFactory.TestDataTeamHierarchy_nonSup1(true,testUser.id,bnkbranch.Id,TH.Id);// SM Role
            
            TH1.Emprole__c = 'RCUM';
            update TH1;
            TeamHierarchy__c TH3= testDataFactory.TestDataTeamHierarchy_CPA(true,testUser.id,bnkbranch.Id,TH.Id);// CPA Role
            
            TeamHierarchy__c TH2= testDataFactory.TestDataTeamHierarchy_UW(true,testUser1.id,bnkbranch1.Id,TH.Id);// UW Role
            
            LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;
            Account testAccount1 = new Account(Name = 'Test Account');
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            testAccount1.RecordTypeId = recordTypeId;
            insert testAccount1;
            Contact testContact = new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                AccountId = testAccount.Id,
                RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' LIMIT 1].Id,
                IsActive__c = true
            );
            insert testContact;
            Id recordTypeId1 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCU').getRecordTypeId();  
             Id recordTypeId2 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Legal').getRecordTypeId(); 
            
            Case c = new Case();
            c.Loan_Application__c = loanApp.Id;
            c.RecordTypeId =recordTypeId2;
            c.Status = 'New';
            insert c;
            
             Case c1 = new Case();
            c1.Loan_Application__c = loanApp.Id;
            c1.RecordTypeId =recordTypeId1;
            c1.Status = 'New';
            insert c1;
            
            List<Case> lstCase= new list<Case>();
            lstCase.add(c);
            lstCase.add(c1);
            CreateLoanTeamForCase.afterInsert(lstCase);
            
        }
        
    }
}