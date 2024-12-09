public class Fileuploadcttrl {

    @AuraEnabled
    public static List<ContentDocumentLink> fetchFiles(String recordId){
        return [SELECT LinkedEntityId,ContentDocumentId, ContentDocument.CreatedDate, ContentDocument.Title, ContentDocument.ContentSize, ContentDocument.FileType 
                FROM ContentDocumentLink  
                WHERE LinkedEntityId  =: recordId ];
    }
}