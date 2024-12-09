public class LODDetailsController {

     @AuraEnabled(cacheable=true)
    public static List<getLODDetailsWrapper> getLODDetails(String recordId) {
        try {
            List<getLODDetailsWrapper> LODwrapperData = new List<getLODDetailsWrapper>();
            list<DocDtl__c>  listLOD = [select id,DocDes__c, Rmrk__c,DocSubTyp__c,OriDoc__c, Originals__c, DocCatgry__c, DocStatus__c from DocDtl__c where LAN__c=:recordId and DocStatus__c IN ('Received', 'Completed') and DocCatgry__c='Property Documents'];
            if (listLOD.size()>0) {
               // return listDecisionSummary;
                for(DocDtl__c Docdtl: listLOD){
                    
                    getLODDetailsWrapper getWrapperData = new getLODDetailsWrapper();
                    //getWrapperData.Description=Docdtl.DocSubTyp__c;
                    
                    /* if(Docdtl.Rmrk__c !=null){
                        getWrapperData.Description=Docdtl.Rmrk__c;
                    }else{
                        getWrapperData.Description=Docdtl.DocSubTyp__c; 
                    }  */ 
                   /* if(Docdtl.Originals__c ==true){
                        getWrapperData.OriginalPhoto = 'Original';
                    }else{
                        getWrapperData.OriginalPhoto = 'Photocopy'; 
                    }   */
                     getWrapperData.DocName=Docdtl.DocSubTyp__c;
                     getWrapperData.Description=Docdtl.Rmrk__c;
                    getWrapperData.OriginalPhoto=Docdtl.OriDoc__c;
                     getWrapperData.Status=Docdtl.DocStatus__c;
                    LODwrapperData.add(getWrapperData);
                }
            }
            else {
                return null;
            }
            system.debug('LODwrapperData'+LODwrapperData);
            return LODwrapperData;
        }
        Catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Applicant__c getAppDetails(String recordId) {
     Applicant__c  App=[Select id,FullName__c,ApplType__c,EmailId__c,LoanAppln__r.Finnone_Loan_Number__c from Applicant__c where LoanAppln__c=:recordId AND (ApplType__c='P') limit 1];
    	 string ApplicantId=App.id;
        return App;
    }     
    
    @AuraEnabled(cacheable=true)
    public static string getTemplate() {
     EmailTemplate em=[select id,Name,DeveloperName  from EmailTemplate where DeveloperName ='LOD_Email'];
    	 string TemplateID=em.id;
        return TemplateID;
    }  
    
     @AuraEnabled(cacheable=true)
    public static User getUserInfo() {
        return [SELECT Id, Name, Email, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
    }
    public class getLODDetailsWrapper{
        @AuraEnabled
        public String DocName {get;set;}
        @AuraEnabled
        public String Description {get;set;}
        @AuraEnabled
        public String OriginalPhoto {get;set;}        
        @AuraEnabled
        public String Status {get;set;}
       
        
    }
}