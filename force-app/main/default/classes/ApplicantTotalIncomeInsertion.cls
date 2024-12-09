public without sharing class ApplicantTotalIncomeInsertion implements TriggerAction.Afterinsert {
    
    public static void afterInsert(List<Applicant_Income__c> newList) {  
        UpdateTotalAmountOnApplicantHandler.updateTotalAmountInsert(newList);
    }
}