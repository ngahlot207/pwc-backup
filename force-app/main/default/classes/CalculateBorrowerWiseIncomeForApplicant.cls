public class CalculateBorrowerWiseIncomeForApplicant implements TriggerAction.AfterUpdate {
    
    public static void afterUpdate(List<Applicant__c> newList, List<Applicant__c> oldList) {
        Map<Id,Applicant__c> oldMap=new Map<Id,Applicant__c>(oldList);
        CalculateBorrowerWiseIncome.calculateForApplicant(newList,oldMap);
    }    
}