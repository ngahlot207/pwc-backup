public class NamasteCreditUploadRequestGenerator implements ICalloutRequestGenerator {
    
    public void generate(List<IntgMsg__c> msgs,String service, String processType) {
        if(!msgs.isempty()){
            Set<Id> refIds = new Set<Id>();
            Set<Id> parentRefIds = new Set<Id>();
            Set<Id> contentVersionIds = new Set<Id>();
            Map<Id,Id> contentDocumentLinkMap = new Map<Id,Id>();
            Map<Id,ContentVersion> contentDocumentMap = new Map<Id,ContentVersion>();
            List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>();
            List<Attachment> attachmentRecords = new List<Attachment>();
        
            try{
                for (IntgMsg__c intMsg : msgs) {
                    refIds.add(intMsg.RefId__c);
                    parentRefIds.add(intMsg.ParentRefId__c);
                    if(String.isNotBlank(intMsg.Upsert_Record_Ids__c)){
                        List<Id> ids = intMsg.Upsert_Record_Ids__c.split(',');
                        contentVersionIds.addAll(ids);
                    }
                }
                
                Map<Id,DocDtl__c> docDtlMap = new Map<Id,DocDtl__c>([Select ID,Appl__r.Constitution__c FROM DocDtl__c WHERE ID IN:refIds]);
                Map<Id,Applicant_Financial__c> appFinancialMap = new Map<Id,Applicant_Financial__c>([Select ID FROM Applicant_Financial__c WHERE ID IN:parentRefIds]);
                
                for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM ContentDocumentLink where LinkedEntityId IN: refIds]){
                    contentDocumentLinkMap.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
                }
                
                for(ContentVersion verData: [SELECT Title,VersionData,ContentDocumentId,FileType,FileExtension,PerfiosFileUploaded__c FROM ContentVersion WHERE ContentDocumentId IN:contentDocumentLinkMap.keyset() AND Id NOT IN:contentVersionIds ORDER BY CreatedDate ASC]){
                    if(contentDocumentLinkMap.containsKey(verData.ContentDocumentId) && !contentDocumentMap.containsKey(contentDocumentLinkMap.get(verData.ContentDocumentId))){
                        contentDocumentMap.put(contentDocumentLinkMap.get(verData.ContentDocumentId),verData);
                    }
                }
                
                for(IntgMsg__c intmsg:msgs){
                    if(appFinancialMap.containsKey(intmsg.ParentRefId__c) && docDtlMap.containsKey(intmsg.RefId__c) && contentDocumentMap.containsKey(intmsg.RefId__c)){
                        
                        NamasteCreditUploadRequestWrapper requestPayload = new NamasteCreditUploadRequestWrapper();
                        requestPayload.document = EncodingUtil.base64Encode(contentDocumentMap.get(intmsg.RefId__c).VersionData);
                        requestPayload.filename=contentDocumentMap.get(intmsg.RefId__c).Title+'.'+contentDocumentMap.get(intmsg.RefId__c).FileExtension;
                        requestPayload.doc_type_id=(String.isNotblank(docDtlMap.get(intmsg.RefId__c).Appl__r.Constitution__c) && businessTypeMap.containsKey(docDtlMap.get(intmsg.RefId__c).Appl__r.Constitution__c))?businessTypeMap.get(docDtlMap.get(intmsg.RefId__c).Appl__r.Constitution__c):0;
                        requestPayload.white_label_id='2548e38e6ee3e0126f1d18c50daaab6f';//2548e38e6ee3e0126f1d18c50daaab6f
                        requestPayload.case_id='';
                        
                       
                        Attachment att = new Attachment();
                        att.ParentId = intmsg.Id;
                        att.Body = blob.valueof(NamasteCreditAPIController.getEncryptedRequest(JSON.serialize(requestPayload)));
                        att.Name = 'request.txt';
                        attachmentRecords.add(att);
                        
                        IntgMsg__c integrationMessage =new IntgMsg__c();
                        integrationMessage.Id=intmsg.Id;
                        integrationMessage.Upsert_Record_Ids__c = String.isNotBlank(intmsg.Upsert_Record_Ids__c) ? intmsg.Upsert_Record_Ids__c+ ',' + contentDocumentMap.get(intmsg.RefId__c).Id : contentDocumentMap.get(intmsg.RefId__c).Id;
                        integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntRecords.add(integrationMessage);
                        
                    }
                }
                
                
                if(!attachmentRecords.isEmpty()){
                    Insert attachmentRecords;
                }
                
                if(!updateIntRecords.isEmpty()){
                    Update updateIntRecords;
                }
                
                
            }
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'NamasteCreditUploadRequestGenerator class', 
                                         'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
    }
 //******************************************************************************************************************************
    Public Static Map<String,Integer> businessTypeMap =new Map<String,Integer>{
        
        'ASSOCIATION OF PERSONS'=>11,
            'HUF'=>20,
            'INDIVIDUAL'=>7,
            'LIMITED LIABILITY PARTNERSHIP'=>14,
            'PARTNERSHIP'=>14,
            'PRIVATE LIMITED COMPANY'=>4,
            'PROPERITORSHIP'=>1,
            'PUBLIC LIMITED COMPANY'=>5,
            'SOCIETY'=>10,
            'TRUST'=>9
            
            };
}