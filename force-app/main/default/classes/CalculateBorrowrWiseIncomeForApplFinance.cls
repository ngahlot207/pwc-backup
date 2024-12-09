public class CalculateBorrowrWiseIncomeForApplFinance implements TriggerAction.AfterDelete, TriggerAction.AfterInsert {
    
    
    public static void afterDelete( List<Applicant_Financial__c> oldList) {
        CalculateBorrowerWiseIncome.calculateForApplicantFinancial(oldList);
    }
    
    public static void afterInsert(List<Applicant_Financial__c> newList) {
        CalculateBorrowerWiseIncome.calculateForApplicantFinancial(newList);
    }
}