@istest
public class FinancialSummaryController_Test {


    @testSetup
    public static void testFinancialSummaries(){
     
        
        LoanAppl__c loanAppl =TestDataFactory.createLoanApplication(true);
            
        Applicant__c applicant =TestDataFactory.createSingleApplicant(true,loanAppl.id);  
        
        
        Applicant_Financial__c applicantFinancial = new Applicant_Financial__c(Loan_Applicant__c = applicant.Id);
        insert applicantFinancial;
        
        // Creating and inserting Applicant_Financial_Summary__c record
        Applicant_Financial_Summary__c financialSummary = new Applicant_Financial_Summary__c(
            Applicant_Financial__c = applicantFinancial.Id,
            Liabilities__c = 1000.00,
            EBITDA__c = 5000.00,
            Financial_Year__c = '2023'
        );
        insert financialSummary; // Don't forget to insert the record
    }

    @isTest
    static void testGetFinancialSummaries() {
        
        
        List<Applicant_Financial_Summary__c> financialSummaries = [Select Id From Applicant_Financial_Summary__c ];
        
    }
}