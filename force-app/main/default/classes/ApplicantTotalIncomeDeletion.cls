public without sharing class ApplicantTotalIncomeDeletion implements TriggerAction.AfterDelete{
    
    public static void afterDelete(List<Applicant_Income__c> oldList) { 
        UpdateTotalAmountOnApplicantHandler.updateTotalAmountDelete(oldList);
    }
}