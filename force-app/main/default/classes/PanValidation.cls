public with sharing class PanValidation {

    @AuraEnabled(cacheable=true)
    public static boolean Validation(String ApplicantId){
         Boolean ValidationStatus = false;
        List<ApplKyc__c> applicantList = new List<ApplKyc__c>();
        applicantList = [select Id,CreatedDate,  Applicant__c, Pan__c, NameInPan__c, OCRStatus__c, ValidationStatus__c  from ApplKyc__c where Applicant__c =:ApplicantId AND Pan__c != null AND NameInPan__c !=null];
        
        if(applicantList.isEmpty()){
            ValidationStatus=true;
        }
        return ValidationStatus;          
        
      
        
    }
}