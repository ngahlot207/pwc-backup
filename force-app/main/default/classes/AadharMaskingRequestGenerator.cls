public class AadharMaskingRequestGenerator implements ICalloutRequestGenerator {
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType,Attachment.SObjectType });
        
       
        Map<Id,Id> intMsgDocMap = new Map<Id,ID>();
        
        for(IntgMsg__c intMsg : msgs){ 
            intMsgDocMap.put(intMsg.Id,intMsg.RefId__c);
        }
        List<Attachment> attachRequest = new List<Attachment>();
        
        try{
            List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>(); 
            
            if(!msgs.isEmpty()){
                
                for(IntgMsg__c intMsg : msgs){
                    
                    AadharMaskingRequestWrapper request = new AadharMaskingRequestWrapper();
                    request.uid=system.label.Aadhar_Masking_Uid;
                    request.slk=system.label.Aadhar_Masking_Slk;
                    request.rrn=system.label.Aadhar_Masking_Rrn;
                    request.env=system.label.Aadhar_Masking_Env;
                    request.lat=GlobalConstants.Lat;
                    request.lon=GlobalConstants.Lon;
                    request.devid='';
                    request.refr='';
                    request.sertype=system.label.Aadhar_Masking_Sertype;
                    request.ver=system.label.Aadhar_Masking_Ver;
                    request.txnmode=system.label.Aadhar_Masking_txnmode;
                    request.file=getFileBase64EncodeData(intMsgDocMap.get(intMsg.Id));
                                        
                    string requestData= JSON.serialize(request);
                    
                    Attachment ocrReqAttachment = new Attachment();   
                    ocrReqAttachment.parentId = intMsg.id;            
                    ocrReqAttachment.Body = Blob.valueOf(requestData);            
                    ocrReqAttachment.Name = 'Request.json';            
                    ocrReqAttachment.ContentType = 'application/text';            
                    attachRequest.add(ocrReqAttachment);
                    
                    IntgMsg__c integrationMessage = new IntgMsg__c();
                    integrationMessage.Id = intMsg.Id;
                    integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                    updateIntMsgRecords.add(integrationMessage);
                    
                    
                }
                if(!attachRequest.isEmpty()){
                    List<string> fieldNamesList = New List<string>{'ContentType','Name','Body','parentId'};
                        String sObjectName = 'Attachment';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                    uow.registerNew(attachRequest);
                }
                if(!updateIntMsgRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntMsgRecords);
                }
                
            }            
            uow.commitWork();
            
            
            
            
            
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'AadharMaskingRequestGenerator class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        
    }
   //*********************************************************************************************************************//
    public static String getFileBase64EncodeData(Id docDtlId){
        
        ContentDocumentLink cdlList =  [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM
                                        ContentDocumentLink where LinkedEntityId =:docDtlId];
        
        ContentVersion verData = [SELECT VersionData,ContentDocumentId,FileType,FileExtension FROM ContentVersion 
                                  where ContentDocumentId = :cdlList.ContentDocumentId];
        
        String content = EncodingUtil.base64Encode(verData.VersionData);
        
        return content;
    }
    
     
}