@isTest
public class ApplicantTotalIncomeUpdationTest {
    
    @isTest
    static void testUpdateTotalAmount() {
        LoanAppl__c loanRecord = new LoanAppl__c(Stage__C = 'QDE');
        insert loanRecord;
        
        Applicant__c applicant = new Applicant__c(FNAME__c = 'Test Applicant');
        applicant.LoanAppln__c = loanRecord.Id;
        insert applicant;
        
        String cashSalaryRecordType = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Cash Salary').getRecordTypeId();
        
        Applicant_Income__c income1 = new Applicant_Income__c(
            Applicant__c = applicant.Id,
            RecordTypeId = cashSalaryRecordType,
            Salary__c = 5000
        );
        
        Applicant_Income__c income2 = new Applicant_Income__c(
            Applicant__c = applicant.Id,
            RecordTypeId = cashSalaryRecordType,
            Month1_Rental_Credited_Amount__c = 2000,
            Month2_Rental_Credited_Amount__c = 3000,
            Month3_Rental_Credited_Amount__c = 2500
        );
        insert new List<Applicant_Income__c> {income1, income2};
            
        ApplicantTotalIncomeUpdation.afterUpdate(new List<Applicant_Income__c> {income1, income2}, new List<Applicant_Income__c>()); 
    } 
}