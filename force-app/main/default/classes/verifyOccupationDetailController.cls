public with sharing class verifyOccupationDetailController {
    @AuraEnabled(cacheable = true)
    public static  Map<string,List<Applicant__c>> allApplicantsData(string loanApplicationId){
        List<Applicant__c> applicantList = [select id,FName__c,CustProfile__c,ApplType__c from Applicant__c where LoanAppln__c =:loanApplicationId AND 
        (CustProfile__c='SELF EMPLOYED PROFESSIONAL' OR CustProfile__c='SELF EMPLOYED NON PROFESSIONAL' OR CustProfile__c='SALARIED') AND
        (ApplType__c ='P' OR ApplType__c ='C' OR ApplType__c ='G') ];
        Map<string,List<Applicant__c>> ApplicantMap = new Map<string,List<Applicant__c>>();
        for(Applicant__c app:applicantList){
            if(ApplicantMap.containsKey(app.CustProfile__c)){
                List<Applicant__c> appList = ApplicantMap.get(app.CustProfile__c);
                appList.add(app);
                ApplicantMap.put(app.CustProfile__c,appList);
            }else{
                ApplicantMap.put(app.CustProfile__c,new List<Applicant__c>{app});
            }
        }
        return ApplicantMap;
    }

   
    
    @AuraEnabled
    public static List<verificationWrapper> getVerificationData(string loanApplicationId){
        List<verificationWrapper> verificationWrapperList= new List<verificationWrapper>();
        Map<string,List<APIVer__c>> VerificationMap= new Map<string,List<APIVer__c>>();
        List<APIVer__c> verificationRecords = [select Id,recordType.Name,Prof_Qualification_Check__c,Document_Detail_Id__c,Document_Detail_Id__r.Content_Document_Id__c,Appl__r.FName__c,Verification_Status__c from APIVer__c where LoanAplcn__c =: loanApplicationId];
       // return verificationRecords;
       for(APIVer__c rec:verificationRecords){
        if(VerificationMap.containsKey(rec.RecordType.Name)){
            List<APIVer__c> tempList=VerificationMap.get(rec.RecordType.Name);
            tempList.add(rec);
            VerificationMap.put(rec.RecordType.Name,tempList);
        }else{
            VerificationMap.put(rec.RecordType.Name,New List<APIVer__c>{rec});
        }
       }
       if(VerificationMap.size()>0){
        for(string key:VerificationMap.keyset()){
            verificationWrapper wrapRec = new verificationWrapper();
            List<verificationWrapper.verificationRecord> tempList = new List<verificationWrapper.verificationRecord>();
            wrapRec.recordTypeName = key;
            wrapRec.showProfQuaCheck = false;
                    wrapRec.showVerStatus = true;
                    if(key =='Qualification Check'){
                        wrapRec.showProfQuaCheck = true;
                    }
                    if(key =='Probe42'){
                        wrapRec.showVerStatus = false;
                    }
            if(VerificationMap.get(key)!=null){
                for(APIVer__c ver:VerificationMap.get(key)){
                    verificationWrapper.verificationRecord verWrapRec = new verificationWrapper.verificationRecord();
                    verWrapRec.applicantName = ver.Appl__r.FName__c;
                    verWrapRec.applicantId = ver.Appl__c;
                    verWrapRec.verificationStatus = ver.Verification_Status__c;
                    verWrapRec.verificationId = ver.Id;
                    verWrapRec.cdlId = ver.Document_Detail_Id__r.Content_Document_Id__c;
                    verWrapRec.docDetailId = ver.Document_Detail_Id__c;
                    verWrapRec.ProfQuaStatus = ver.Prof_Qualification_Check__c;
                    tempList.add(verWrapRec);
                }
                wrapRec.verificationList = tempList;
            }
            verificationWrapperList.add(wrapRec);
        }
       }
       return verificationWrapperList;
    }
}