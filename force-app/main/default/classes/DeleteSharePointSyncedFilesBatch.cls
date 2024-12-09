public class DeleteSharePointSyncedFilesBatch implements Database.Batchable<sObject>, Schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        APIConfiguration__c SharePointConfig = APIConfiguration__c.getInstance('SharePoint');
        String query = 'Select Id, Type__c, SharePointFileSyncStatus__c, DocumentDetail__c,DocumentDetail__r.LAN__c, DocumentDetail__r.LAN__r.Stage__c,DocumentDetail__r.LAN__r.DisbursementDate__c, DocumentId__c  from DocDtlItem__c  where Type__c =\'SharePoint\' AND  IsFileDeleted__c = False AND SharePointFileSyncStatus__c =\'Success\' AND DocumentDetail__r.LAN__r.Stage__c =\'Disbursed\' AND DocumentDetail__r.LAN__r.DisbursementDate__c = N_DAYS_AGO:'+ Integer.ValueOf(SharePointConfig.Threshold__c) +'\'';
        //String query = 'Select Id, Type__c, SharePointFileSyncStatus__c, DocumentDetail__c,DocumentDetail__r.LAN__c, DocumentDetail__r.LAN__r.Stage__c,DocumentDetail__r.LAN__r.DisbursementDate__c, DocumentId__c  from DocDtlItem__c  where Type__c =\'SharePoint\' AND  IsFileDeleted__c = False AND SharePointFileSyncStatus__c =\'Success\'';
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext BC, List<DocDtlItem__c> scope) {
        try{
            if(!scope.isEmpty()){
                set<Id> documentIds = new set<Id>();
                Map<Id,DocDtlItem__c> updateMap = new Map<Id,DocDtlItem__c>();
                for(DocDtlItem__c docDtlItem: scope){
                    if(docDtlItem.DocumentId__c!=null){
                        documentIds.add(docDtlItem.DocumentId__c);
                    }
                }
                
                if(!documentIds.isEmpty()){
                    
                    
                    Map<Id,List<Id>> contentDocumentLinkMap = new Map<Id,List<Id>>();
                    Set<Id> docDtlIds = new Set<Id>();
                    Set<Id> multipleObjRealtedDocIds = new Set<Id>();
                    Set<Id> deleteDocumentIds = new Set<Id>();
                    for(ContentDocumentLink link : [SELECT Id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where ContentDocumentId IN : documentIds]){
                        if(Id.valueOf(link.LinkedEntityId).getSObjectType().getDescribe().getName().equalsIgnoreCase('DocDtl__c')){
                            docDtlIds.add(link.LinkedEntityId);
                            if(contentDocumentLinkMap.containsKey(link.ContentDocumentId)){
                                contentDocumentLinkMap.get(link.ContentDocumentId).add(link.LinkedEntityId);
                            }
                            else{
                                contentDocumentLinkMap.put(link.ContentDocumentId, new List<Id>{link.LinkedEntityId});
                            }
                        }
                        else if(!Id.valueOf(link.LinkedEntityId).getSObjectType().getDescribe().getName().equalsIgnoreCase('User')){
                            multipleObjRealtedDocIds.add(link.ContentDocumentId);
                        }
                    }
                    Map<Id,DocDtl__c> docDtlMap = new Map<Id,DocDtl__c>([SELECT Id,LAN__c, LAN__r.Stage__c, (SELECT Id FROM Document_Detail_Items__r WHERE SharePointFileSyncStatus__c <> 'Success' AND Type__c ='SharePoint' ) FROM DocDtl__c  WHERE ID IN :docDtlIds]);
                    System.debug('Scope' + scope.size());
                    for(DocDtlItem__c docDtlItem: scope){
                        system.debug('::::'+docDtlItem.DocumentId__c);
                        if(docDtlItem.DocumentId__c!=null && !multipleObjRealtedDocIds.contains(docDtlItem.DocumentId__c)){ 
                            if(contentDocumentLinkMap.containsKey(docDtlItem.DocumentId__c)){
                                System.debug('::'+ contentDocumentLinkMap.get(docDtlItem.DocumentId__c).size());
                                System.debug('::123'+ contentDocumentLinkMap.get(docDtlItem.DocumentId__c));
                                if(contentDocumentLinkMap.get(docDtlItem.DocumentId__c).size()==1){
                                    deleteDocumentIds.add(docDtlItem.DocumentId__c);
                                    docDtlItem.IsFileDeleted__c =True;
                                    updateMap.put(docDtlItem.Id,docDtlItem);
                                }
                                else if(contentDocumentLinkMap.get(docDtlItem.DocumentId__c).size()>1){
                                    for(Id docId : contentDocumentLinkMap.get(docDtlItem.DocumentId__c)){
                                        if(docDtlMap.containsKey(docId) && docDtlMap.get(docId).LAN__c !=null && docDtlMap.get(docId).LAN__r.Stage__c == 'Disbursed' && docDtlMap.get(docId).Document_Detail_Items__r.isEmpty()){
                                            system.debug(docDtlMap.get(docId).Document_Detail_Items__r.isEmpty());
                                            deleteDocumentIds.add(docDtlItem.DocumentId__c);
                                            updateMap.put(docDtlItem.Id,docDtlItem);
                                        }
                                        else{
                                            
                                            if(deleteDocumentIds.contains(docDtlItem.DocumentId__c)){
                                                system.debug('removed'+ '::::'+ docDtlItem.DocumentId__c );
                                                deleteDocumentIds.remove(docDtlItem.DocumentId__c);
                                            }
                                            if(updateMap.containsKey(docDtlItem.Id)){
                                                system.debug('removed from UpdateMap'+ '::::'+ docDtlItem.Id + ':::');
                                                updateMap.remove(docDtlItem.Id);
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if(!updateMap.isEmpty()){
                        system.debug('DocDtlItem Update Size' + updateMap.size());
                        update updateMap.values();
                    }
                    if(!deleteDocumentIds.isEmpty()){
                        List<ContentDocument> conDocList =[SELECT Id FROM ContentDocument where Id IN: deleteDocumentIds]; 
                        system.debug('Content Document Delete Size' + conDocList.size());
                        delete conDocList;
                    }
                    
                }
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'DeleteSharePointSyncedFilesBatch', 'execute', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    public void execute(SchedulableContext sc) {
        DeleteSharePointSyncedFilesBatch batch = new DeleteSharePointSyncedFilesBatch();
        Database.executeBatch(batch);
    }
    
    public void finish(Database.BatchableContext BC) {
    }
    
}