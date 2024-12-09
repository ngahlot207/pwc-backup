@isTest
public class CalcBorwerWiseIncomeForApplIncTest {

    @isTest
    static void testAfterDelete() {
        // Create test data
        LoanAppl__c testLoanApp = new LoanAppl__c(AssessedIncAppln__c = true);
        insert testLoanApp;
        
        Applicant__c testApplicant=TestDataFactory.createSingleApplicant(false,testLoanApp.id);
        testApplicant.CustProfile__c = 'SELF EMPLOYED PROFESSIONAL';
        testApplicant.LatestyearforwhichITRisavailable__c ='ITR Not Available';
        insert testApplicant;
        List<Applicant_Income__c> applicantIncomeRecords = new List<Applicant_Income__c>{
            new Applicant_Income__c(Applicant__c = testApplicant.Id)
                };
                    insert applicantIncomeRecords;

        Test.startTest();

        // Perform the delete operation (assuming you have deleted some records)
        delete applicantIncomeRecords;

        Test.stopTest();

        // Perform assertions if necessary
        // Add your assertions here
    }

    @isTest
    static void testAfterInsert() {
        // Create test data
        // 
        Test.startTest();
        LoanAppl__c testLoanApp = new LoanAppl__c(AssessedIncAppln__c = true);
        insert testLoanApp;
        
        Applicant__c testApplicant=TestDataFactory.createSingleApplicant(false,testLoanApp.id);
        testApplicant.CustProfile__c = 'SELF EMPLOYED PROFESSIONAL';
        testApplicant.LatestyearforwhichITRisavailable__c ='ITR Not Available';
        insert testApplicant;
        List<Applicant_Income__c> applicantIncomeRecords = new List<Applicant_Income__c>{
            new Applicant_Income__c(Applicant__c = testApplicant.Id)
                };
                    insert applicantIncomeRecords;


        // Perform the insert operation

        Test.stopTest();

        // Perform assertions if necessary
        // Add your assertions here
    }
}