public class ValidateEmpDtlsHandler implements TriggerAction.BeforeUpdate{
    
    public static void beforeUpdate(
        List<ApplicantEmployment__c> newList,
        List<ApplicantEmployment__c> oldList
    ) {
        updateEmpDetils(newList,oldList);
    }
    public static void updateEmpDetils(list<ApplicantEmployment__c> newList,List<ApplicantEmployment__c> oldList){
        Set<Id> appEmpIds = new Set<Id>();
        List<ApplicantEmployment__c> updateAppEmp = new List<ApplicantEmployment__c>();
        Map<Id, ApplicantEmployment__c> appEmpMap = new Map<Id, ApplicantEmployment__c>(oldList);
        
        for(ApplicantEmployment__c appEmp :newList){
            if(String.isNotBlank(appEmp.Proprietorship_firm_part_of_the_proposal__c) && appEmp.Proprietorship_firm_part_of_the_proposal__c == 'YES'){
                if((appEmpMap != null && appEmp.Proprietorship_firm_part_of_the_proposal__c != appEmpMap.get(appEmp.Id).Proprietorship_firm_part_of_the_proposal__c) || appEmpMap == null){
                    appEmp.Is_URC_UAC_available__c = String.isNotBlank(appEmp.Is_URC_UAC_available__c) ? null : appEmp.Is_URC_UAC_available__c;
                    appEmp.Select_applicability_for_URC_UAC__c = String.isNotBlank(appEmp.Select_applicability_for_URC_UAC__c) ? null : appEmp.Select_applicability_for_URC_UAC__c;
                    appEmp.UdyamRegistrationNumber__c = String.isNotBlank(appEmp.UdyamRegistrationNumber__c) && String.isNotBlank(appEmp.Select_applicability_for_URC_UAC__c) && appEmp.Select_applicability_for_URC_UAC__c == 'UDYAM REGISTRATION NUMBER (URC)' ? null : appEmp.UdyamRegistrationNumber__c;
                    appEmp.UdyamAssistCertificate__c = String.isNotBlank(appEmp.UdyamAssistCertificate__c) && String.isNotBlank(appEmp.Select_applicability_for_URC_UAC__c) && appEmp.Select_applicability_for_URC_UAC__c == 'UDYAM ASSIST CERTIFICATE (UAC)' ? null : appEmp.UdyamAssistCertificate__c;
                }
            }
        }  
    }  
}