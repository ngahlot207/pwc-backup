@isTest
public class ApplicantTotalIncomeDeletionTest {

    @testSetup
    static void setupTestData() {
         // Create a test Loan Application record
        LoanAppl__c loanRecord = new LoanAppl__c(Stage__c = 'QDE');
        insert loanRecord;

        // Create a test Applicant record related to the Loan Application 
        Applicant__c applicant = new Applicant__c(FName__c = 'Test Applicant', LoanAppln__c = loanRecord.Id);
        insert applicant;

        // Create a test Applicant Income record related to the Applicant
        Applicant_Income__c incomeRecord = new Applicant_Income__c(
            Applicant__c = applicant.Id,
            // Set the appropriate RecordTypeId based on your Record Type label
            
            Month1_Rental_Credited_Amount__c = 2000,
            Month2_Rental_Credited_Amount__c = 3000,
            Month3_Rental_Credited_Amount__c = 2500,
            Salary__c = 5000, // Set the salary or other relevant fields as needed
            Net_Salary__c = 3500, // Sample net salary
            Other_Salary_Component__c = 1000, // Sample other salary component
            Monthly_Pension_Credited__c = 1200, // Sample pension
            Monthly_Other_Income__c = 500 // Sample other income
        );
        insert incomeRecord;
        
    }

    @isTest
    static void testAfterDelete() {
        // Call the afterDelete trigger action method
       
        List<Applicant_Income__c> applicantIncomeList = [SELECT Id, Applicant__c FROM Applicant_Income__c];
        ApplicantTotalIncomeDeletion.afterDelete(applicantIncomeList);
   

    }
}