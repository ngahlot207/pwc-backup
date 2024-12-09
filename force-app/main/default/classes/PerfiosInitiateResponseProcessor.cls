public class PerfiosInitiateResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        
        for(IntgMsg__c integrationMessage : responses){
            if(integrationMessage.Svc__c != 'Initiate Transaction' && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE){
                throw new processException('Error! This is not the correct service'); 
            }
            
            try{
                PerfiosInitiateResponseWrapper responseWrapper = (PerfiosInitiateResponseWrapper) JSON.deserialize(integrationMessage.Resp__c.replace('transaction','perfiosTransaction'), PerfiosInitiateResponseWrapper.class); 
                if(responseWrapper != null){
                    if((responseWrapper.perfiosTransaction!=null) && String.isNotBlank(responseWrapper.perfiosTransaction.perfiosTransactionId)){
                        processSuccessResponse(integrationMessage,responseWrapper);
                    }
                    else{
                        processErrorResponse(integrationMessage,responseWrapper);
                    }
                }
            }
            //Exception Handling
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'PerfiosInitiateResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            } 
        }
        
    }
    
    public static void processSuccessResponse(IntgMsg__c integrationMessage,PerfiosInitiateResponseWrapper response){
        try{
            
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(integrationMessage.Resp__c);
            if(response!=null){
                List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
                String perfiosTransactionId = response.perfiosTransaction.perfiosTransactionId;
                
                ApplBanking__c appBank = new ApplBanking__c();
                appBank.Id = integrationMessage.ParentRefId__c;
                appBank.TransactionId__c = perfiosTransactionId;
                appBank.IntegrationStatus__c = 'Perfios Initiate Transaction: Success';
                appBank.IntegrationErrorMessage__c = '';
                
                if(appBank != null){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplBanking__c.SObjectType });
                    List<string> fieldNamesList = New List<string>{'TransactionId__c','IntegrationStatus__c','IntegrationErrorMessage__c'};
                    String sObjectName = 'ApplBanking__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(appBank);
                    uow.commitWork();
                }
                
                IntgMsg__c intmsg =new IntgMsg__c();
                intmsg.Name='Upload Files';
                intmsg.BU__c='HL / STL';
                intmsg.Status__c='New';
                intmsg.MStatus__c='Blank';
                intmsg.Svc__c='Upload Files';
                intmsg.IsActive__c=true;
                intmsg.RefId__c=integrationMessage.RefId__c;
                intmsg.RefObj__c=integrationMessage.RefObj__c;
                intmsg.ParentRefId__c=integrationMessage.ParentRefId__c;
                intmsg.ParentRefObj__c=integrationMessage.ParentRefObj__c;
                createRequestList.add(intmsg);
                
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
            
            
            if(integrationMessage.Trigger_Platform_Event__c){
                publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                platformWra.intId = integrationMessage.Id; 
                platformWra.recId = integrationMessage.ParentRefId__c;
                platformWra.ServiceName = integrationMessage.Svc__c ;
                platformWra.Status = integrationMessage.Status__c ;
                platformWra.success = True;
                publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
            }
            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }  
    }    
    
    public static void processErrorResponse(IntgMsg__c integrationMessage, PerfiosInitiateResponseWrapper responseWrapper){
        
        
        if(responseWrapper.Error!=null){
            ApplBanking__c appBank = new ApplBanking__c();
            appBank.Id = integrationMessage.ParentRefId__c;
            appBank.Initiate_Perfios_Status__c = 'Failure';
            appBank.IntegrationStatus__c = 'Perfios Initiate Transaction: Failure';
            appBank.IntegrationErrorMessage__c = String.isNotBlank(responseWrapper.Error.message)? 'Perfios Initiate Transaction: ' + responseWrapper.Error.message:'';
            
            if(appBank != null){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplBanking__c.SObjectType });
                List<string> fieldNamesList = New List<string>{'IntegrationStatus__c','IntegrationErrorMessage__c','Initiate_Perfios_Status__c'};
                    String sObjectName = 'ApplBanking__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(appBank);
                uow.commitWork();
            }
			            
        }
        
        if(integrationMessage.Trigger_Platform_Event__c){
            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
            platformWra.intId = integrationMessage.Id; 
            platformWra.recId = integrationMessage.ParentRefId__c;
            platformWra.ServiceName = integrationMessage.Svc__c ;
            platformWra.Status = integrationMessage.Status__c ;
            platformWra.success = False;
            platformWra.errorMessage = (responseWrapper.Error!=null && String.isNotBlank(responseWrapper.Error.message))? 'Perfios Initiate Transaction: '+responseWrapper.Error.message:'';
            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
        }
        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
        
    }
}