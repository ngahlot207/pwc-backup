@isTest
public class CalculateBorrowrWiseIncomeForApplFinTest {
    
    @isTest
    static void testAfterDelete() {
       
        LoanAppl__c testLoanApp = new LoanAppl__c();
        insert testLoanApp;
 
        Applicant__c testApplicant=TestDataFactory.createSingleApplicant(false,testLoanApp.id);
        insert testApplicant; 
        
        Applicant_Financial__c applicantFinancialList = new Applicant_Financial__c();
       
        applicantFinancialList.Loan_Applicant__c = testApplicant.Id;
        insert applicantFinancialList;
        
        // Delete records
        Test.startTest();
        delete applicantFinancialList;
        Test.stopTest();
     
    }
    
    @isTest
    static void testAfterInsert() {
        // Create test data
        List<Applicant_Financial__c> applicantFinancialList = new List<Applicant_Financial__c>();
        
  
        Test.startTest();
        insert applicantFinancialList;
        Test.stopTest();
    
    }
}