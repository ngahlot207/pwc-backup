public class ChequeOCRRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){ 
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {Attachment.SObjectType, IntgMsg__c.SObjectType });
        
        //Creating a Set of ids
        Set<Id> ids = new Set<Id>();
        set<id> dids=new set<id>();
        
        Map<Id,Id> intMsgDocMap = new Map<Id,ID>();
        
        //Iterating over new Intgeration Message record ids to add them into the above Set
        for(IntgMsg__c intMsg : msgs){ 
            dids.add(intMsg.RefId__c);
            ids.add(intMsg.ParentRefId__c);
            intMsgDocMap.put(intMsg.Id,intMsg.RefId__c);
        }
        
        List<Attachment> attachRequest = new List<Attachment>();
        //Fetching required fields to create Request Payload
        
        try{
            //If the List of new Integration Message records is not empty, then iterating over and assigning data to variables from Wrapper Class
            List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>(); 
            
            if(!msgs.isEmpty()){
                for(IntgMsg__c intMsg : msgs){
                    
                    ChequeOCRRequestWrapper request = new ChequeOCRRequestWrapper();
                    ChequeOCRRequestWrapper.ClientData cd = new ChequeOCRRequestWrapper.ClientData();
                    cd.caseId=GlobalUtility.getUniqueNumber();
                    
                    request.clientData =cd;
                    request.fileB64 = getFileBase64EncodeData(intMsgDocMap.get(intMsg.Id));
                    
                    string requestData= JSON.serialize(request);
                    
                    Attachment ocrReqAttachment = new Attachment();   
                    ocrReqAttachment.parentId = intMsg.id;            
                    ocrReqAttachment.Body = Blob.valueOf(requestData);            
                    ocrReqAttachment.Name = 'Request.txt';            
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
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch(Exception ex){
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'ChequeOCRRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    
    public static String getFileBase64EncodeData(Id docDtlId){
        
        ContentDocumentLink cdlList =  [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM
                                        ContentDocumentLink where LinkedEntityId =:docDtlId];
        
        ContentVersion verData = [SELECT VersionData,ContentDocumentId,FileType,FileExtension FROM ContentVersion 
                                  where ContentDocumentId = :cdlList.ContentDocumentId];
        
        String content = EncodingUtil.base64Encode(verData.VersionData);
        
        return content;
    }
}