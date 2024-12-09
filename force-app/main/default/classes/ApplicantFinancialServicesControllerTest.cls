@isTest
public class ApplicantFinancialServicesControllerTest { 
    @isTest
    public static void testGetFinancialSummaries(){
        
       LoanAppl__c loandata= TestDataFactory.createLoanApplication(true);
        Applicant__c applicant=TestDataFactory.createSingleApplicant(true,loandata.id);
        
        
      //  Applicant_Financial__c applicantFinancial = new Applicant_Financial__c(Loan_Applicant__c = applicant.Id);
      //  insert applicantFinancial;
        
        Applicant_Financial__c applicantFinancial2 = new Applicant_Financial__c(Loan_Applicant__c = applicant.Id);
        insert applicantFinancial2;
        
        Applicant_Financial_Summary__c financialSummary = new Applicant_Financial_Summary__c(
            Applicant_Financial__c = applicantFinancial2.Id,
            Liabilities__c = 1000.00,
            EBITDA__c = 5000.00,
            Financial_Year__c = '2023'
        );
        insert financialSummary;
        
        
        List<Applicant_Financial_Summary__c> result = new List<Applicant_Financial_Summary__c>();
        result = ApplicantFinancialServicesController.getFinancialSummaries();
        
     
   
      
    }
    
    @isTest
    public static void testGetFinancialSummaries2(){
        
        LoanAppl__c loanAppl = new LoanAppl__c(BrchName__c = 'Bhagalpur');
        insert loanAppl;
        
        Applicant__c applicant = new Applicant__c(LoanAppln__c = loanAppl.Id);
        insert applicant;
        
        Applicant_Financial__c applicantFinancial = new Applicant_Financial__c(Loan_Applicant__c = applicant.Id);
        insert applicantFinancial;
        
        Applicant_Financial_Summary__c financialSummary = new Applicant_Financial_Summary__c(
            Applicant_Financial__c = applicantFinancial.Id,
            Liabilities__c = 1000.00,
            EBITDA__c = 5000.00,
            Financial_Year__c = '2023'
        );
        insert financialSummary;
        
        List<Applicant_Financial_Summary__c> result = new List<Applicant_Financial_Summary__c>();
        result = ApplicantFinancialServicesController.getFinancialSummaries();
    }
}