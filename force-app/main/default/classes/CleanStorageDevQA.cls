public class CleanStorageDevQA {
     @AuraEnabled
    public static void clearStorage(Id userId){
        List<ContentDocumentLink> ContentDocumentLinkList =[SELECT id,contentdocumentid,linkedentity.name,linkedentityid,linkedentity.type FROM
                                                            ContentDocumentLink WHERE linkedentityid in (SELECT id FROM User where id=:userId)];
        
        List<id> DocIdList = new List<id>();
        
        for(ContentDocumentLink cdl: ContentDocumentLinkList){
            DocIdList.add(cdl.contentdocumentid);
        }
        List<ContentDocument> ConDocList =[SELECT Id, CreatedBy.name, ContentSize, ParentId FROM ContentDocument where Id IN: DocIdList];
        delete ConDocList;
    }
    
}