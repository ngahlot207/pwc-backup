public without sharing class ApplicantTotalIncomeUpdation implements TriggerAction.AfterUpdate{
    
    public static void afterUpdate(List<Applicant_Income__c> newList,List<Applicant_Income__c> oldList) {
        UpdateTotalAmountOnApplicantHandler.updateTotalAmountUpdate(newList,oldList); 
    }
}