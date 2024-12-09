public class AadharMaskingResponseProcessor implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses) {
        
        
        
        List<Id> ids = new List<Id>();
        List<Id> refid = new List<Id>();
        
        for (IntgMsg__c integrationMessage : responses) {
            ids.add(integrationMessage.Id);
            refid.add(integrationMessage.RefId__c);
        }
        
        //this soql is used to identify the attachement of integrationMessage
        
        ContentDocumentLink cdlList = [SELECT ContentDocumentId FROM ContentDocumentLink
                                       WHERE LinkedEntityId = :ids
                                       AND ContentDocument.Title = 'response.json' LIMIT 1];
        
        ContentVersion contentVersion = [SELECT Id, VersionData,FileType FROM ContentVersion
                                         WHERE ContentDocumentId = :cdlList.ContentDocumentId LIMIT 1];
        
        
        //this soql is used to identify the FileType of Document Detail
        
       // ContentDocumentLink doclist = [SELECT ContentDocumentId FROM ContentDocumentLink
         //                              WHERE LinkedEntityId = :refid LIMIT 1];
        
       // ContentVersion docVersion = [SELECT Id, VersionData,FileType FROM ContentVersion
                      //               WHERE ContentDocumentId = :doclist.ContentDocumentId LIMIT 1];
        
        
        if (contentVersion != null) {
            
            //string FileType=docVersion.FileType;
            
            String jsonContent = contentVersion.VersionData.toString();
            
            for (IntgMsg__c integrationMessage : responses) {
                try {
                    AadharMaskingResponseWrapper res = (AadharMaskingResponseWrapper) JSON.deserialize(jsonContent, AadharMaskingResponseWrapper.class);
                    
                    
                    if (res != null && res.respcode == '200' && res.respdesc == 'Success') {// 
                        attachJsonfile(res.file, integrationMessage.RefId__c,integrationMessage.ParentRefId__c, integrationMessage);
                        
                        if(responses[0].Trigger_Platform_Event__c){
                            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                            platformWra.intId = responses[0].Id; 
                            platformWra.recId = responses[0].ParentRefId__c;
                            platformWra.ServiceName = responses[0].Svc__c ;
                            platformWra.Status = responses[0].Status__c ;
                            platformWra.success=true;
                            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                        } 
                    }
                    
                    if(res!=null && res.respcode != '200' && res.respdesc!='Success'){
                        MaskingFailure(res,integrationMessage.ParentRefId__c,integrationMessage);
                        
                        if(responses[0].Trigger_Platform_Event__c){
                            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                            platformWra.intId = responses[0].Id; 
                            platformWra.recId = responses[0].ParentRefId__c;
                            platformWra.ServiceName = responses[0].Svc__c ;
                            platformWra.Status = responses[0].Status__c ;
                            platformWra.errorMessage=res.respdesc;
                            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                        } 
                    }
                } catch (Exception ex) {
                    GlobalUtility.logMessage('Error', 'AadharMaskingResponseProcessor class', 
                                             'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                }
            }
        }
    }
    //*******************************************************************************************************************************//
    
    public static void attachJsonfile(String imageBlob, Id docId,Id appkycId, IntgMsg__c integrationMessage) {
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {ApplKyc__c.SObjectType });
        
        List<ContentDocumentLink> ContentDocumentLinkRequest = new List<ContentDocumentLink>();
        List<ApplKyc__c> appkyclist =new List<ApplKyc__c>();
        
        //this soql is used to identify the FileType of Document Detail
        
        ContentDocumentLink doclist = [SELECT ContentDocumentId FROM ContentDocumentLink
                                       WHERE LinkedEntityId = :docId LIMIT 1];
        
        ContentVersion docVersion = [SELECT Id, VersionData,FileType FROM ContentVersion
                                     WHERE ContentDocumentId = :doclist.ContentDocumentId LIMIT 1];
        
        string FileType=docVersion.FileType;
       
        if(docVersion!=null){
            delete doclist;
        }
        
        try {
            if (imageBlob != null) {
                ContentVersion newContentVersion = new ContentVersion();
                
                newContentVersion.Title = 'Masked Aadhar';
                
                if(FileType=='JPG' || FileType=='JPEG'){
                    newContentVersion.PathOnClient = 'MaskedAadhar.JPEG'; 
                }
                else if(FileType=='PDF'){
                    newContentVersion.PathOnClient = 'MaskedAadhar.PDF';
                }
                else if(FileType=='PNG'){
                    newContentVersion.PathOnClient = 'MaskedAadhar.PNG';
                }
                newContentVersion.VersionData = EncodingUtil.base64Decode(imageBlob);
               
                insert newContentVersion;
                
                Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:newContentVersion.Id].ContentDocumentId;
                ContentDocumentLink newContentLink = new ContentDocumentLink();
                newContentLink.ContentDocumentId = conDocId;
                newContentLink.LinkedEntityId = docId; 
                newContentLink.ShareType = 'V';
                ContentDocumentLinkRequest.add(newContentLink);
                
                ApplKyc__c appkyc=new ApplKyc__c();
                appkyc.Id=appkycId;
                appkyc.AadharMasked__c=True;
                appkyc.AadharMaskingError__c='';
                appkyclist.add(appkyc);
            }
            
            if(ContentDocumentLinkRequest.size()>0){
                insert ContentDocumentLinkRequest;
            }
            if (!appkyclist.isEmpty()) {
                List<string> fieldNamesList = new List<string>{'AadharMasked__c','AadharMaskingError__c'};
                    String sObjectName = 'ApplKyc__c';
                Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType, fieldNamesList);
                uow.registerDirty(appkyclist);
                
            }
            uow.commitWork();
            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
            
            
        } catch (Exception ex) {
            System.debug('error message and line number ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    //****************************************************************************************************************************
    public static void MaskingFailure(AadharMaskingResponseWrapper res,Id appkycId, IntgMsg__c integrationMessage) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {ApplKyc__c.SObjectType });
        
        List<ApplKyc__c> appkyclist =new List<ApplKyc__c>();
        try{
            if(appkycId!=null){
                ApplKyc__c appkyc=new ApplKyc__c();
                appkyc.Id=appkycId;
                appkyc.AadharMaskingError__c=res.respdesc;
                appkyclist.add(appkyc);
            }
            if (!appkyclist.isEmpty()) {
                List<string> fieldNamesList = new List<string>{'AadharMaskingError__c'};
                    String sObjectName = 'ApplKyc__c';
                Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType, fieldNamesList);
                uow.registerDirty(appkyclist);
                
            }
            uow.commitWork();
            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
            
        }catch (Exception ex) {
            System.debug('error message and line number ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
        
    }
}