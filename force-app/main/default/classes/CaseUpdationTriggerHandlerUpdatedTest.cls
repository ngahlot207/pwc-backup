@isTest
public class CaseUpdationTriggerHandlerUpdatedTest {

    /*
    @isTest
    static void testBeforeInsert() { 

        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(LastName = 'Test Contact', AccountId = testAccount.Id);
        insert testContact;

        Id cpvFiRTRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CPVFI').getRecordTypeId();

        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c appl = TestDataFactory.createSingleApplicant(true,loan.Id);

        Case testCase = new Case( 
            IsRouRobAllowd__c = true,
            Subject = 'Test Case',
            RecordTypeId = cpvFiRTRecordTypeId, 
            Applicant__c = appl.Id,
            Loan_Application__c = loan.id            
        );

        Test.startTest();
        CaseUpdationTriggerHandler.BeforeInsert(new List<Case>{testCase});
        Test.stopTest();
    }

*/

}