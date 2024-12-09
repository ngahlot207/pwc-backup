public class SharePointCreateFileRetryBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([Select Id,Type__c, SharePointFileSyncStatus__c, FileName__c, FileRelativeUrl__c, DocumentDetail__c, DocumentDetail__r.LAN__c,DocumentDetail__r.LAN__r.Name, DocumentDetail__r.LAN__r.Stage__c, SharePointFileUploadStartDate__c, SharePointFileUploadEndDate__c, DocumentId__c, IsFileDeleted__c from DocDtlItem__c  WHERE Type__c ='SharePoint' AND SharePointFileSyncStatus__c ='Failure' ]);
        
    }
    
    public void execute(Database.BatchableContext BC, List<DocDtlItem__c> scope) {
        
        try{
            if(!scope.isEmpty()){
                List<Sobject> updateSObjectList =new List<Sobject>();
                List<Exception> exceptionList = new List<Exception>();
                Set<Id> contentDocIds = new Set<Id>();
                Map<Id,contentVersion> contentVersionMap = new Map<Id,contentVersion>();
                APIConfiguration__c SharePointConfig = APIConfiguration__c.getInstance('SharePoint');
                for(DocDtlItem__c item : scope){
                    contentDocIds.add(item.DocumentId__c);
                }
                if(!contentDocIds.isEmpty()){
                    for(ContentVersion ver : [SELECT Id,VersionData,ContentDocumentId,CreatedDate,Title,FileExtension,ContentSize FROM ContentVersion WHERE ContentDocumentId IN:contentDocIds]){
                        Decimal fileSize = ver.ContentSize/(1024 *1024);
                        if(fileSize.setScale(2, RoundingMode.HALF_UP)  <= SharePointConfig.MaxSize__c){
                            contentVersionMap.put(ver.ContentDocumentId,ver);
                        }
					}
                }
                for(DocDtlItem__c item : scope){
                    if(item.DocumentDetail__r.LAN__c!=null && contentVersionMap.containsKey(item.DocumentId__c)){
                        SObject record = SharePointAPI.createFile(contentVersionMap.get(item.DocumentId__c).VersionData, item.DocumentDetail__r.LAN__r.Name, item.FileName__c, new DocDtlItem__c(Id =item.Id,Type__c = 'SharePoint'));
                        updateSObjectList.add(record);
                    }
                }
                
                if(!updateSObjectList.isEmpty()){
                    update updateSObjectList;
                }
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'SharePointCreateFileRetryBatch', 'execute', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    
    public void execute(SchedulableContext sc) {
        SharePointCreateFileRetryBatch batch = new SharePointCreateFileRetryBatch();
        Database.executeBatch(batch,50);
    }
    public void finish(Database.BatchableContext BC) {
    }
    
}