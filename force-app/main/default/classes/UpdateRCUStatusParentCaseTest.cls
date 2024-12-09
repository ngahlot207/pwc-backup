@isTest
public class UpdateRCUStatusParentCaseTest {
    @testsetup
    public static void insertCaseRecord(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
              Profile testProfile = [SELECT Id FROM profile WHERE Name = 'LOS Base User' LIMIT 1];
        User testUser = new User(LastName = 'test user 1', 
                                 Username = 'test.createLoanTeam@example.com', 
                                 Email = 'test.1@example.com', 
                                 Alias = 'testu1', 
                                 TimeZoneSidKey = 'GMT', 
                                 LocaleSidKey = 'en_GB', 
                                 EmailEncodingKey = 'ISO-8859-1', 
                                 ProfileId = testProfile.Id, 
                                 LanguageLocaleKey = 'en_US'); 
        
        insert testUser;
        BankBrchMstr__c B = TestDataFactory.TestDataBankBranchMaster(true);
        Applicant__c appli = TestDataFactory.createSingleApplicant(true,loanApp.Id);
    }
    
    @isTest
    public static void testAfterUpdate(){
        User userList = [SELECT Id FROM User WHERE Profile.Name = 'LOS Base User' AND IsActive = true LIMIT 1];
        
        LoanAppl__c loan =TestDataFactory.createLoanApplication(true);
        Account acc = new Account(Name = 'Test_Account',OwnerId = userList.Id);
        insert acc;
        
        Id conRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agency Contact').getRecordTypeId();
        Contact con = new Contact(
            AccountId = acc.Id,
            LastName = 'Test_Contact',
            RecordTypeId = conRecordId,
            OwnerId = userList.Id,
            AgencyContactType__c = 'RCU',
            IsActive__c	= true,
            EndDate__c = System.today(),
            StartDate__c = System.today().addDays(-5)
        );
        insert con;
        Id caseRecordId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCU').getRecordTypeId();
        
        Case parentCase = new Case();
        parentCase.Status = 'New';
        parentCase.Origin = 'Email';
        parentCase.Loan_Application__c = loan.Id;
        parentCase.OwnerId = userList.Id;
        parentCase.CityId__c = 'TestCityId';
        parentCase.RecordTypeId = caseRecordId;
        insert parentCase;
        
        Case childCase = new Case();
        childCase.Status = 'New';
        childCase.Origin = 'Email';
        childCase.Loan_Application__c = loan.Id;
        childCase.Case__c=parentCase.Id;
        childCase.AccountId = acc.Id;
        childCase.ContactId=con.Id;
        childCase.CityId__c = 'TestCityId';
        childCase.RecordTypeId = caseRecordId;
        insert childCase;
          Test.startTest();
      	 Case updateChildCase =new Case();
        updateChildCase.Id=childCase.Id;
        updateChildCase.Date_of_Report__c=Date.parse('12/15/24');
        updateChildCase.AgcRCUReportStatus__c='Fraud';
        updateChildCase.Status='Closed';
        update updateChildCase;
        try{
            UpdateRCUStatusParentCase.afterUpdate(new List<Case>{updateChildCase},new List<Case>{childCase});
        }catch(exception e){
            system.debug('e::::'+e+'::::'+e.getLineNumber());
        }
        
         try{
         Case updateChildCase1 =new Case();
        updateChildCase1.Id=childCase.Id;
        updateChildCase1.Date_of_Report__c=Date.parse('12/15/24');
        updateChildCase1.AgcRCUReportStatus__c='Fraud';
        updateChildCase1.Status='Query';
        update updateChildCase1;
            UpdateRCUStatusParentCase.afterUpdate(new List<Case>{updateChildCase1},new List<Case>{childCase});
        }catch(exception e){
            system.debug('e::::'+e+'::::'+e.getLineNumber());
        }
        
        Test.stopTest();
    }
}