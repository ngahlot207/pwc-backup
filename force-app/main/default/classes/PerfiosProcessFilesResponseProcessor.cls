public class PerfiosProcessFilesResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        Map<Id,PerfiosProcessFilesResponseWrapper> responseMap = new Map<Id,PerfiosProcessFilesResponseWrapper>();
        for(IntgMsg__c integrationMessage : responses){
            if(integrationMessage.Svc__c != 'Process Files' && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE){
                throw new processException('Error! This is not the correct service'); 
            }
            
            try{
                PerfiosProcessFilesResponseWrapper responseWrapper = (PerfiosProcessFilesResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, PerfiosProcessFilesResponseWrapper.class); 
                if(responseWrapper != null){
                    system.debug('integrationMessage.ParentRefId__c----------------->'+integrationMessage.ParentRefId__c);
                    if(integrationMessage.ParentRefId__c!=null){
                        responseMap.put(integrationMessage.ParentRefId__c,responseWrapper);
                    }
                }
            }
            //Exception Handling
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'PerfiosProcessFilesResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            } 
        }
        if(!responseMap.isEmpty()){
            processResponses(responses,responseMap);
        }
    }
    
    
    public static void processResponses(List<IntgMsg__c> responseList,Map<Id,PerfiosProcessFilesResponseWrapper> responseMap){
        
        if(!responseList.isEmpty()){
            Map<Id,ApplBanking__c> applBankMap = new Map<Id,ApplBanking__c>([Select Id,IntegrationStatus__c,IntegrationErrorMessage__c from ApplBanking__c where Id IN:responseMap.keySet()]);
            List<ApplBanking__c> appBankList = new List<ApplBanking__c>();
            List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
            List<ContentVersion> contentVersionList = new List<ContentVersion>();
            for(IntgMsg__c integrationMessage: responseList){
                if(responseMap.containsKey(integrationMessage.ParentRefId__c)){
                    PerfiosProcessFilesResponseWrapper response = responseMap.get(integrationMessage.ParentRefId__c);
                    if(response != null){
                        if(response.bankStatement!=null){
                           	Map<String,Object> requestMap = (Map<String,Object>) JSON.deserializeUntyped (integrationMessage.Req__c);
                            String contentVersionId = (String)((Map<String, Object>)requestMap.get('Header')).get('fileId');
                            if(contentVersionId!=null){
                                ContentVersion cv = new ContentVersion();
                                cv.Id = contentVersionId;
                                cv.PerfiosFileProcessed__c = TRUE;
                                contentVersionList.add(cv);
                            }
                            
                            Map<String,ContentDocumentLink> contentDocumentLinkMap = new Map<String,ContentDocumentLink>();
                            for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM ContentDocumentLink where LinkedEntityId =:integrationMessage.RefId__c]){
                                contentDocumentLinkMap.put(cdl.ContentDocumentId,cdl);  
                            }
                            List<ContentVersion> verDataList  = [SELECT Title,VersionData,ContentDocumentId,FileType,FileExtension,FileId__c,PerfiosFileUploaded__c FROM ContentVersion 
                                                                 where ContentDocumentId IN:contentDocumentLinkMap.keyset() AND PerfiosFileProcessed__c=FALSE AND ID <>:contentVersionId ORDER BY CreatedDate ASC LIMIT 1];
                            
                            if(verDataList!=null && !verDataList.isEmpty()){
                                IntgMsg__c intmsg =new IntgMsg__c();
                                intmsg.Name='Process Files';
                                intmsg.BU__c='HL / STL';
                                intmsg.Status__c='New';
                                intmsg.MStatus__c='Blank';
                                intmsg.Svc__c='Process Files';
                                intmsg.IsActive__c=true;
                                intmsg.RefId__c=integrationMessage.RefId__c;
                                intmsg.RefObj__c=integrationMessage.RefObj__c;
                                intmsg.ParentRefId__c=integrationMessage.ParentRefId__c;
                                intmsg.ParentRefObj__c=integrationMessage.ParentRefObj__c;
                                createRequestList.add(intmsg);
                            }
                            else{
                                ApplBanking__c appBank = new ApplBanking__c();
                                appBank.Id = integrationMessage.ParentRefId__c;
                                appBank.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios Process Files: Failure', 'Perfios Process Files: Success', applBankMap.get(integrationMessage.ParentRefId__c).IntegrationStatus__c, ';');
                                appBank.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios Process Files', '', applBankMap.get(integrationMessage.ParentRefId__c).IntegrationErrorMessage__c, ';');
                                appBankList.add(appBank);
                                
                                IntgMsg__c intmsg =new IntgMsg__c();
                                intmsg.Name='Report generation';
                                intmsg.BU__c='HL / STL';
                                intmsg.Status__c='New';
                                intmsg.MStatus__c='Blank';
                                intmsg.Svc__c='Report generation';
                                intmsg.IsActive__c=true;
                                intmsg.RefId__c=integrationMessage.RefId__c;
                                intmsg.RefObj__c=integrationMessage.RefObj__c;
                                intmsg.ParentRefId__c=integrationMessage.ParentRefId__c;
                                intmsg.ParentRefObj__c=integrationMessage.ParentRefObj__c;
                                createRequestList.add(intmsg);
                                
                                if(integrationMessage.Trigger_Platform_Event__c){
                                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                                    platformWra.intId = integrationMessage.Id; 
                                    platformWra.recId = integrationMessage.ParentRefId__c;
                                    platformWra.ServiceName = integrationMessage.Svc__c ;
                                    platformWra.Status = integrationMessage.Status__c ;
                                    platformWra.success = True;
                                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                                }
                            }    
                            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                        }
                        else{
                            String errorMessage ='';
                            List<String> errorMessages = new List<String>();
                            if(response.error!=null){
                                if(String.isNotBlank(response.error.message)){
                                    errorMessages.add(response.error.message);
                                }
                                if(!response.error.details.isEmpty()){
                                    for(PerfiosProcessFilesResponseWrapper.Details detail : response.error.details){
                                        if(detail.message!=null && String.isNotBlank(detail.message)){
                                            errorMessages.add(detail.message);
                                        }
                                    }
                                }
                            }
                            if(!errorMessages.isEmpty()){
                                errorMessage = String.join(errorMessages,';');
                            }
                            ApplBanking__c appBank = new ApplBanking__c();
                            appBank.Id = integrationMessage.ParentRefId__c;
                            appBank.Initiate_Perfios_Status__c = 'Failure';
                            appBank.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios Process Files: Success', 'Perfios Process Files: Failure', applBankMap.get(integrationMessage.ParentRefId__c).IntegrationStatus__c, ';');
                            appBank.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios Process Files', 'Perfios Process Files: ' + errorMessage, applBankMap.get(integrationMessage.ParentRefId__c).IntegrationErrorMessage__c, ';');
                            appBankList.add(appBank);
                            
                            if(integrationMessage.Trigger_Platform_Event__c){
                                publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                                platformWra.intId = integrationMessage.Id; 
                                platformWra.recId = integrationMessage.ParentRefId__c;
                                platformWra.ServiceName = integrationMessage.Svc__c ;
                                platformWra.Status = integrationMessage.Status__c ;
                                platformWra.success = False;
                                platformWra.errorMessage = errorMessage;
                                publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                            }
                            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                        }
                    }
                }
            }
            
            if(!contentVersionList.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ContentVersion.SObjectType });
                List<string> fieldNamesList = New List<string>{'PerfiosFileProcessed__c'};
                    String sObjectName = 'ContentVersion';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(contentVersionList);
                uow.commitWork();
            }
            
            if(!appBankList.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplBanking__c.SObjectType });
                    List<string> fieldNamesList = New List<string>{'IntegrationStatus__c','IntegrationErrorMessage__c','Initiate_Perfios_Status__c'};
                    String sObjectName = 'ApplBanking__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(appBankList);
                    uow.commitWork();
                }
            if(!createRequestList.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
                List<string> fieldNamesList = New List<string>{'Name','BU__c','RefId__c','Status__c','MStatus__c','RefObj__c','Svc__c','ApiVendor__c',
                    'IsActive__c','ParentRefId__c','ParentRefObj__c'};
                        String sObjectName = 'IntgMsg__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                uow.registerNew(createRequestList);
                uow.commitWork();
            }
        }
    }
}