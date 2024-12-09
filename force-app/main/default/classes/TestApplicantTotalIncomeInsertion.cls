@isTest
public class TestApplicantTotalIncomeInsertion {
    @testSetup
    static void createTestData() {
        
        LoanAppl__c loanApp = new LoanAppl__c();
        insert loanApp;
        
        // Create a test Applicant__c record
        Applicant__c applicant = new Applicant__c(
            MobNumber__c = '1234567890',
            CustProfile__c = 'SALARIED',
            Constitution__c = 'ASSOCIATION OF PERSONS',
            Type_of_Borrower__c = 'Financial',
            ApplType__c = 'P',
            LoanAppln__c=loanApp.Id
        );
        
        insert applicant;
        loanApp.Applicant__c=applicant.Id;
        update loanApp;
                
    }

    @isTest
    static void testAfterInsert() {
      
        
        List<Applicant_Income__c> applicantIncomeList = [SELECT Id FROM Applicant_Income__c];
        ApplicantTotalIncomeInsertion.afterInsert(applicantIncomeList);
       
    }
}