public class ApplicantAfterDelete implements TriggerAction.BeforeDelete{
    
    public static void beforeDelete(List<Applicant__c> applicantOldList){
        List<ApplBanking__c> lstApplicantBanking = new List<ApplBanking__c>();
        Map<Id,Applicant__c> mapOfApploicantBanking = new Map<Id,Applicant__c>(applicantOldList);
        
          lstApplicantBanking = [SELECT ID,Appl__c from ApplBanking__c WHERE Appl__c IN : mapOfApploicantBanking.keySet()];
          system.debug('lstApplicantBanking:'+lstApplicantBanking);
        if(!lstApplicantBanking.isEmpty()){
            delete lstApplicantBanking;
        }
    }  
}