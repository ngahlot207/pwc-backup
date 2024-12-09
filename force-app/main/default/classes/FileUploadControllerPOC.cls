public class FileUploadControllerPOC {
    
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getUploadedFiles(String masterId){
        List<DocDtl__c> appDocDetailList = new List<DocDtl__c>();
        appDocDetailList = [Select Id, Appl__c from DocDtl__c where Appl__c=:masterId];
        return null;
    }

}