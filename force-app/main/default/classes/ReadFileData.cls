public with sharing class ReadFileData {
    @AuraEnabled
    public static String readFileFromRecord(String recordId) {
        ContentDocumentLink contentDocumentLink = [
            SELECT id, ContentDocumentId, ContentDocument.Description, 
            ContentDocument.Title, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = '0010o00002ZqJVY' 
            LIMIT 1
        ];

        ContentVersion cv = [
            SELECT VersionData 
            FROM ContentVersion 
            WHERE ContentDocumentId = :contentDocumentLink.ContentDocumentId 
            AND IsLatest = true
            LIMIT 1
        ];
        return EncodingUtil.base64Encode(cv.VersionData);
    }
}