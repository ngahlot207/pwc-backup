public class ClearStorageClass {
    public static void clearStorageUsages(String userName) {
        //    ClearStorageClass.clearStorageUsages('userName');
        // Query to fetch ContentDocumentLinks associated with users matching the username pattern
        String query = 'SELECT Id, ContentDocumentId, LinkedEntity.Name, LinkedEntityId, LinkedEntity.Type FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM User WHERE Name LIKE \'%' + userName + '%\')';
        
        // Execute the query
        List<ContentDocumentLink> contentDocumentLinks = Database.query(query);
        
        // Extract document IDs from the ContentDocumentLinks
        Set<Id> docIdSet = new Set<Id>();
        for (ContentDocumentLink cdl : contentDocumentLinks) {
            docIdSet.add(cdl.ContentDocumentId);
        }
        
        // Query to fetch ContentDocuments by their IDs
        query = 'SELECT Id, CreatedBy.Name, ContentSize, ParentId FROM ContentDocument WHERE Id IN :docIdSet';
        
        // Execute the query
        List<ContentDocument> contentDocuments = Database.query(query);
        
        // Delete the ContentDocuments
        try {
            delete contentDocuments;
             // System.debug('Successfully deleted ' + contentDocuments);
           integer totalSize =1;
            for(ContentDocument cd : contentDocuments ){
              
                totalSize = totalSize + cd.ContentSize;
                 
            }
            System.debug('Successfully deleted ' + contentDocuments.size() + ' ContentDocuments.'+totalSize + 'byte in kb ' + totalSize/1024);
        } catch (exception dbe) {
            System.debug('Error deleting ContentDocuments: ' + dbe.getMessage());
        }
    }
}