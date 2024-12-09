public class IMDResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        
        for(IntgMsg__c integrationMessage : responses){
            
            if(integrationMessage.Svc__c != 'IMD'
               && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE){
                   throw new processException('Error! This is not the correct service'); 
               }
            try{
                IMDResponseWrapper responseWrapper = (IMDResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, IMDResponseWrapper.class); 
                IMDRequestWrapper requestWrapper = (IMDRequestWrapper) JSON.deserialize(integrationMessage.Req__c, IMDRequestWrapper.class);
                //check if responseWrapper is empty or not                
                if(responseWrapper != null){
                    
                    if(responseWrapper.errorcode=='0000'){
                        updateSuccess(responseWrapper,integrationMessage.RefId__c,integrationMessage,requestWrapper.requestId,integrationMessage.RefObj__c);
                        if(integrationMessage.Trigger_Platform_Event__c){
                            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                            platformWra.intId = integrationMessage.Id; 
                            platformWra.recId = integrationMessage.ParentRefId__c;
                            platformWra.ServiceName = integrationMessage.Svc__c ;
                            platformWra.Status = integrationMessage.Status__c ;
                            platformWra.success=true;
                            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                        }
                    }
                    if(responseWrapper.errorcode!='0000'){
                        updateFailure(responseWrapper,integrationMessage.RefId__c,integrationMessage,requestWrapper.requestId,integrationMessage.RefObj__c);
                        if(integrationMessage.Trigger_Platform_Event__c){
                            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                            platformWra.intId = integrationMessage.Id; 
                            platformWra.recId = integrationMessage.RefId__c;
                            platformWra.ServiceName = integrationMessage.Svc__c ;
                            platformWra.Status = integrationMessage.Status__c ;
                            platformWra.errorMessage=responseWrapper.errorDescription;
                            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                        }
                    }
                }
            }
            //Exception Handling
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'IMDResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            } 
        }
    }
    
    
    public static void updateSuccess(IMDResponseWrapper responseWrapper,Id referenceId,IntgMsg__c integrationMessage,String requestId,string refobj){
        
        fflib_SObjectUnitOfWork uow;  
        
        if(refobj!=null && refobj=='ApplIMD__c'){
            uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {ApplIMD__c.SObjectType });
        }
        
        else if(refobj!=null && refobj=='Payment__c'){
            uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {Payment__c.SObjectType });
        }
        
        List<SObject> updateRequest = new List<SObject>();
        
        try{
            if(responseWrapper!=null && referenceId!=null && requestId!=null && refobj!=null){
                
                SObject record = (SObject) Type.forName(refobj).newInstance();
                record.Id = referenceId;
                
                if(String.isNotBlank(requestId)){
                    record.put('FinnoneRequestId__c', requestId);
                }
                
                if(!String.isBlank(responseWrapper.chequeId)){
                    record.put('FinnoneChequeId__c',responseWrapper.chequeId);
                }
                
                record.put('IntegrationStatus__c', 'Success');
                record.put('ErrorMessage__c', '');
                updateRequest.add(record);
            }
            
            if(updateRequest != null){
                List<string> fieldNamesList = New List<string>{'FinnoneChequeId__c','IntegrationStatus__c','ErrorMessage__c','FinnoneRequestId__c'};
                    String sObjectName = refobj;
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(updateRequest);
            }
        }
        catch(Exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }
        uow.commitWork();
        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
    }
    
    
    public static void updateFailure(IMDResponseWrapper responseWrapper,Id referenceId,IntgMsg__c integrationMessage,String requestId,string refobj){
        
        fflib_SObjectUnitOfWork uow;  
        
        if(refobj!=null && refobj=='ApplIMD__c'){
            uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {ApplIMD__c.SObjectType });
        }
        
        else if(refobj!=null && refobj=='Payment__c'){
            uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {Payment__c.SObjectType });
        }
        
        List<SObject> updateRequest = new List<SObject>();
        
        try{
            if(responseWrapper!=null && referenceId!=null && requestId!=null && refobj!=null){
                
                SObject record = (SObject) Type.forName(refobj).newInstance();
                record.Id = referenceId;
                
                if(String.isNotBlank(requestId)){
                    //record.put('FinnoneRequestId__c', requestId); //
                }
                
                 if(String.isNotBlank(responseWrapper.errorDescription)){
                record.put('ErrorMessage__c', responseWrapper.errorDescription);
                 }
                 
                record.put('FinnoneChequeId__c','');
                record.put('IntegrationStatus__c', 'Failure');
                
                updateRequest.add(record);
            }
            
            if(updateRequest != null){
                List<string> fieldNamesList = New List<string>{'FinnoneChequeId__c','IntegrationStatus__c','ErrorMessage__c','FinnoneRequestId__c'};
                    String sObjectName = refobj;
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(updateRequest);
            }
        }
        catch(Exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }
        uow.commitWork();
       APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
    }        
      
}