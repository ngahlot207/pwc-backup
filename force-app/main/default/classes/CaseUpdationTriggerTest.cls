@istest
public class CaseUpdationTriggerTest {
    
    @testsetup
    public static void insertCaseRecord(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        User us = TestDataFactory.UserData(true);
        BankBrchMstr__c B = TestDataFactory.TestDataBankBranchMaster(true);
        Applicant__c appli = TestDataFactory.createSingleApplicant(true,loanApp.Id);
    }
    
    
    
    @isTest
    public static void testBeforeInsert(){
        
        BankBrchMstr__c bankBrch = [SELECT Id FROM BankBrchMstr__c LIMIT 1];
        User userList = [SELECT Id FROM User WHERE Profile.Name = 'LOS Base User' AND IsActive = true LIMIT 1];
        Applicant__c appliList = [SELECT Id FROM Applicant__c LIMIT 1];
        LoanAppl__c loanAppList = [SELECT Id FROM LoanAppl__c LIMIT 1];
        
        LocMstr__c locMaster = new LocMstr__c(CityId__c = 'TestCityId');
        insert locMaster;
        
        Account acc = new Account(
            Name = 'Test_Account',
            OwnerId = userList.Id
        );
        insert acc;
        
        Id conRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agency Contact').getRecordTypeId();
        Contact con = new Contact(
            AccountId = acc.Id,
            LastName = 'Test_Contact',
            RecordTypeId = conRecordId,
            OwnerId = userList.Id,
            AgencyContactType__c = 'CPVFI',
            IsActive__c	= true,
            EndDate__c = System.today(),
            StartDate__c = System.today().addDays(-5)
        );
        insert con;
        
        AgncLocMap__c agncLoc = new AgncLocMap__c();
        agncLoc.LocationMaster__c = locMaster.Id;
        agncLoc.BankBrchMst__c = bankBrch.Id;
        agncLoc.OwnerId = userList.Id;
        agncLoc.Account__c = acc.Id;
        agncLoc.AgencyType__c = 'CPVFI';
        agncLoc.StartDate__c = System.today().addDays(-5);
        agncLoc.EndDate__c = System.today();
        agncLoc.IsActive__c = true;
        insert agncLoc;
        
        Id caseRecordId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CPVFI').getRecordTypeId();
        System.debug('caseRecordId'+caseRecordId);
        
        Case objCase = new Case();
        objCase.Status = 'Query';
        objCase.Origin = 'Email';
        objCase.Loan_Application__c = loanAppList.Id;
        objCase.IsRouRobAllowd__c = true;
        objCase.OwnerId = userList.Id;
        objCase.AccountId = acc.Id;
        objCase.Applicant__c = appliList.Id;
        objCase.CityId__c = 'TestCityId';
        objCase.RecordTypeId = caseRecordId;
        insert objCase;
        
        List<Case> caseList = new List<Case>{objCase};
            
            CaseUpdationTrigger.BeforeInsert(caseList);
    }
}