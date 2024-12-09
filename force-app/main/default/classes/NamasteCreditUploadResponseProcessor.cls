public class NamasteCreditUploadResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    public static void process(List<IntgMsg__c> responses){
        Set<Id> refIds = new Set<Id>();
        Set<Id> parentRefIds = new Set<Id>();
        Set<Id> contentVersionIds = new Set<Id>();
        Map<Id,Id> contentDocumentLinkMap = new Map<Id,Id>();
        Map<Id,ContentVersion> contentDocumentMap = new Map<Id,ContentVersion>();
        List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
        
        for(IntgMsg__c intMsg : responses){
            refIds.add(intMsg.RefId__c);
            parentRefIds.add(intMsg.ParentRefId__c);
            if(String.isNotBlank(intMsg.Upsert_Record_Ids__c)){
                List<Id> ids = intMsg.Upsert_Record_Ids__c.split(',');
                contentVersionIds.addAll(ids);
            }
        }
        
        for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM ContentDocumentLink where LinkedEntityId IN: refIds]){
            contentDocumentLinkMap.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
        }
        
        for(ContentVersion verData: [SELECT Title,VersionData,ContentDocumentId,FileType,FileExtension,PerfiosFileUploaded__c FROM ContentVersion WHERE ContentDocumentId IN:contentDocumentLinkMap.keyset() AND Id NOT IN:contentVersionIds ORDER BY CreatedDate ASC]){
            if(contentDocumentLinkMap.containsKey(verData.ContentDocumentId) && !contentDocumentMap.containsKey(contentDocumentLinkMap.get(verData.ContentDocumentId))){
                contentDocumentMap.put(contentDocumentLinkMap.get(verData.ContentDocumentId),verData);
            }
        }
        
        for(IntgMsg__c integrationMessage: responses){
            if(integrationMessage.ParentRefId__c!=null && integrationMessage.RefId__c!=null ){
                if(contentDocumentMap.containsKey(integrationMessage.RefId__c)){
                    IntgMsg__c intmsg =new IntgMsg__c();
                    intmsg.Name='';
                    intmsg.BU__c='HL / STL';
                    intmsg.Status__c='New';
                    intmsg.MStatus__c='Blank';
                    intmsg.Svc__c='';
                    intmsg.IsActive__c=true;
                    intmsg.RefId__c=integrationMessage.RefId__c;
                    intmsg.RefObj__c=integrationMessage.RefObj__c;
                    intmsg.ParentRefId__c=integrationMessage.ParentRefId__c;
                    intmsg.ParentRefObj__c=integrationMessage.ParentRefObj__c;
                    intmsg.Upsert_Record_Ids__c = integrationMessage.Upsert_Record_Ids__c;
                    createRequestList.add(intmsg);
                }
                else{
                    
                    IntgMsg__c intmsg =new IntgMsg__c();
                    intmsg.Name='';
                    intmsg.BU__c='HL / STL';
                    intmsg.Status__c='New';
                    intmsg.MStatus__c='Blank';
                    intmsg.Svc__c='';
                    intmsg.IsActive__c=true;
                    intmsg.RefId__c=integrationMessage.RefId__c;
                    intmsg.RefObj__c=integrationMessage.RefObj__c;
                    intmsg.ParentRefId__c=integrationMessage.ParentRefId__c;
                    intmsg.ParentRefObj__c=integrationMessage.ParentRefObj__c;
                    intmsg.Upsert_Record_Ids__c = integrationMessage.Upsert_Record_Ids__c;
                    createRequestList.add(intmsg);
                    
                }
            }
        }
        
    }

}