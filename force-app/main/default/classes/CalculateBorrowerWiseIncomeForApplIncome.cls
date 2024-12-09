public class CalculateBorrowerWiseIncomeForApplIncome implements TriggerAction.AfterInsert, TriggerAction.AfterDelete{

      public static void afterDelete( List<Applicant_Income__c> oldList) {
        CalculateBorrowerWiseIncome.calculateForApplicantIncome(oldList);
    }
    
      public static void afterInsert(List<Applicant_Income__c> newList) {
        CalculateBorrowerWiseIncome.calculateForApplicantIncome(newList);
    }
}