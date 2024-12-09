public with sharing class PanValidationCheck {
   
    public static List<string> getPanValidationStatus(string loanAppId){
        try {
            Boolean validationStatus = false;
            // Map<ID, Applicant__c> appMap = new Map<ID, Applicant__c>([SELECT Id ,TabName__c FROM Applicant__c 
            //                                                           WHERE  
            //                                                           LoanAppln__c  =: loanAppId AND (ApplType__c ='P' 
            //                                                                                           OR   ApplType__c ='C') ]);
            // system.debug('appMap' + appMap + appMap.keySet());
            
            // List<ApplKyc__c> applicantKycList = new List<ApplKyc__c>();
            // applicantKycList = [SELECT Id,CreatedDate,  Applicant__c, Pan__c, NameInPan__c,
            //                     OCRStatus__c, ValidationStatus__c,PanIvalid__c
            //                     FROM ApplKyc__c
            //                     WHERE Applicant__c IN :  appMap.keySet()
            //                     AND Pan__c != null
            //                    ];
             List<DocDtl__c> docDtlList = new List<DocDtl__c>();
             docDtlList = [SELECT Id,Appl__c,Appl__r.TabName__c,Applicant_KYC__r.PanIvalid__c FROM DocDtl__c 
                               WHERE  Applicant_KYC__r.Pan__c != null AND DocTyp__c ='PAN' AND Applicant_KYC__r.PanIvalid__c = true
                                AND LAN__c  =: loanAppId AND (Appl__r.ApplType__c ='P' OR Appl__r.ApplType__c ='C')]; 

                              Set<string> validationFailedFor = new Set<string>();
                              if(docDtlList.size() > 0){
                                for(DocDtl__c docDtl : docDtlList){
                                    validationFailedFor.add(docDtl.Appl__r.TabName__c); 
                                }
                               }   
            // AND Pan__c != null AND NameInPan__c !=null
            // 
            // system.debug('applicantKycList' + applicantKycList );   
            // if(applicantKycList.isEmpty()){
            //     for (Applicant__c appKyc : appMap.values()) {
            //        validationFailedFor.add(appKyc.TabName__c); 
            //     }
            // }else{
            //     for (ApplKyc__c appKyc : applicantKycList) {
            //         system.debug('appKyc'+ appKyc);
            //         if( appKyc.PanIvalid__c == true){
            //             validationFailedFor.add(appMap.get(appKyc.Applicant__c).TabName__c); 
            //         }
            //     }
            // }
            // if(validationFailedFor != null && validationFailedFor.size() > 0){
                 List<string> validationFailedForNew = new List<string>(validationFailedFor);
            // }
            
            return validationFailedForNew;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}