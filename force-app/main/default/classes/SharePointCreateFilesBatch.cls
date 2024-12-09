public class SharePointCreateFilesBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {//a08C4000008YsEKIA0
        
        //return Database.getQueryLocator([SELECT Id,DocCatgry__c, DocTyp__c, DocSubTyp__c, LAN__c,LAN__r.Name  FROM DocDtl__c WHERE LAN__r.Stage__c ='Disbursed' and LAN__r.SharePointFolderStatus__c = 'Success' AND IsProcessed__c=false]);
        return Database.getQueryLocator([SELECT Id,DocCatgry__c, DocTyp__c, DocSubTyp__c, LAN__c,LAN__r.Name  FROM DocDtl__c WHERE LAN__c='a08C4000008YsEKIA0' AND IsProcessed__c=false]);
    }
    
    public void execute(Database.BatchableContext BC, List<DocDtl__c> scope) {
       
        try{
            List<SObject> recordToInsertList = new List<SObject>();
            Map<Id, DocDtl__c> docDtlMap = new Map<Id, DocDtl__c>(scope);
            
            Map<Id,Id> contentDocLinkMap = new Map<Id,Id>();
            Map<Id,ContentDocumentLink> contentDocumentLinkMap = new Map<Id,ContentDocumentLink>();
            Map<Id,contentVersion> contentVersionMap = new Map<Id,contentVersion>();
            Set<Id> contentDocIds = new Set<Id>();
            Map<Id, DocDtl__c> updateDocDtlMap = new Map<Id, DocDtl__c>();
            
            APIConfiguration__c SharePointConfig = APIConfiguration__c.getInstance('SharePoint');
            for(ContentDocumentLink contentDocLink : [SELECT Id,ContentDocumentId,LinkedEntityId  FROM ContentDocumentLink WHERE LinkedEntityId  IN:docDtlMap.keyset()]){
                contentDocIds.add(contentDocLink.ContentDocumentId);
                contentDocumentLinkMap.put(contentDocLink.Id,contentDocLink);
            }
            
            for(ContentVersion ver : [SELECT Id,VersionData,ContentDocumentId,CreatedDate,Title,FileExtension,ContentSize FROM ContentVersion WHERE ContentDocumentId IN:contentDocIds]){
                Decimal fileSize = ver.ContentSize/(1024 *1024);
                if(fileSize.setScale(2, RoundingMode.HALF_UP)  <= SharePointConfig.MaxSize__c){
                    contentVersionMap.put(ver.ContentDocumentId,ver);
                }
                
            }
            
            
            if(contentDocumentLinkMap!=null && !contentDocumentLinkMap.isEmpty()){
                //List<ContentVersion> contentVersionList = new List<ContentVersion>();
                //List<DocDtlItem__c> docDtlItemList = new List<DocDtlItem__c>();
                
                for(ContentDocumentLink contentDocLink : contentDocumentLinkMap.values()){
                    if(contentVersionMap.containsKey(contentDocLink.ContentDocumentId) && docDtlMap.containsKey(contentDocLink.LinkedEntityId)){
                        ContentVersion ver = contentVersionMap.get(contentDocLink.ContentDocumentId);
                        String fileName = (docDtlMap.get(contentDocLink.LinkedEntityId).DocTyp__c + '_' + ver.Title.substringBefore('.') + '_' + String.valueOf(DateTime.newInstance(ver.CreatedDate.year(), ver.CreatedDate.month(), ver.CreatedDate.day(),ver.CreatedDate.hour(),ver.CreatedDate.minute(),ver.CreatedDate.second()).format('YYYY-MM-dd_HH-mm-ss')) + '.' + ver.FileExtension.toLowerCase()).replaceAll(' ','_');
                        String folderName = docDtlMap.get(contentDocLink.LinkedEntityId).LAN__r.Name;
                        SObject record = SharePointAPI.createFile(ver.VersionData, folderName, fileName, new DocDtlItem__c(DocumentDetail__c = contentDocLink.LinkedEntityId, DocumentId__c = contentDocLink.ContentDocumentId,Type__c = 'SharePoint',FileName__c = fileName));
                        recordToInsertList.add(record);
                        
                        if(!updateDocDtlMap.containsKey(contentDocLink.LinkedEntityId)){
                            updateDocDtlMap.put(contentDocLink.LinkedEntityId,new DocDtl__c(Id=contentDocLink.LinkedEntityId,IsProcessed__c=true));
                        }
                    }
                }
                
                if(!recordToInsertList.isEmpty()){
                    insert recordToInsertList;
                }
                
                if(!updateDocDtlMap.isEmpty()){
                    Update updateDocDtlMap.values();
                }
            }	            
            
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'SharePointCreateFilesBatch', 'execute', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    
    public void execute(SchedulableContext sc) {
        SharePointCreateFilesBatch batch = new SharePointCreateFilesBatch();
        Database.executeBatch(batch,50);
    }
    public void finish(Database.BatchableContext BC) {
    }
}