public class SequenceAPIResponseProcessor implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses) {
        
        //for(IntgMsg__c integrationMessage : responses){
            
            try{
                SequenceAPIResponseWrapper res=(SequenceAPIResponseWrapper) JSON.deserialize(responses[0].Resp__c, SequenceAPIResponseWrapper.class);
                
                if(res.status=='success'){
                     
                    FinoneSuccess(res,responses[0].RefId__c,responses[0].RefObj__c);
                     if(responses[0].Trigger_Platform_Event__c){
                        publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                        platformWra.intId = responses[0].Id; 
                        platformWra.recId = responses[0].RefId__c;
                        platformWra.ServiceName = responses[0].Svc__c ;
                        platformWra.Status = responses[0].Status__c ;
                        platformWra.success=true;
                        publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                      } 
                	  APICalloutTracker.update_ApiTrackerWithIntMsg(responses[0].Id,responses[0].Svc__c, responses[0].RefId__c, 'Success');
                  

                }
                
                if(res.status!='success'){
                    FinoneFailure(res,responses[0].RefId__c,responses[0].RefObj__c);
                    if(responses[0].Trigger_Platform_Event__c){
                        publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                        platformWra.intId = responses[0].Id; 
                        platformWra.recId = responses[0].RefId__c;
                        platformWra.ServiceName = responses[0].Svc__c ;
                        platformWra.Status = responses[0].Status__c ;
                        platformWra.errorMessage=res.errorDescription;
                        publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                      } 
					APICalloutTracker.update_ApiTrackerWithIntMsg(responses[0].Id,responses[0].Svc__c, responses[0].RefId__c, 'Failure');
                       

                }
                
            }
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'SequenceAPIResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
       // }
        
    }
    
//**********************************************************************************************************************************//
    public static void FinoneSuccess(SequenceAPIResponseWrapper res,Id refid,string objectName){
        
        fflib_SObjectUnitOfWork uow;
        
        if(objectName!=null && objectName=='LoanAppl__c'){
            uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {LoanAppl__c.SObjectType });
        }
        else if(objectName!=null && objectName=='Payment__c'){
            uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {Payment__c.SObjectType });
        }
        
      List<SObject> updateRequest = new List<SObject>();
        try{
            if(res!=null && objectName!=null && refid!=null){
                SObject record = (SObject) Type.forName(objectName).newInstance();
                record.Id = refid;
                
                if(!String.isBlank(res.appId)){
                    record.put('FinnoneAppid__c', res.appId);
                }
                record.put('IntegrationStatus__c', 'Success');
                record.put('ErrorMessage__c', '');
                updateRequest.add(record);
                
            }
                
            /*if(!updateRequest.isempty()){
                update updateRequest;
            }*/
                
            if(updateRequest!=null){
                List<string> fieldNamesList = New List<string>{'FinnoneAppid__c','IntegrationStatus__c','ErrorMessage__c'};
                    String sObjectName = objectName;
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                uow.registerDirty(updateRequest);
            }
            uow.commitWork();
            
        }
        catch(Exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }
        
    }
 //**********************************************************************************************************************************//
    public static void FinoneFailure(SequenceAPIResponseWrapper res,Id refid,string objectName){
        
        fflib_SObjectUnitOfWork uow;
        
        if(objectName!=null && objectName=='LoanAppl__c'){
            uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {LoanAppl__c.SObjectType });
        }
        else if(objectName!=null && objectName=='Payment__c'){
            uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {Payment__c.SObjectType });
        }
        
        List<SObject> updateRequest = new List<SObject>();
        try{
            if(res!=null && objectName!=null && refid!=null){
                SObject record = (SObject) Type.forName(objectName).newInstance();
                record.Id = refid;
                
                if(!String.isBlank(res.errorDescription)){
                    record.put('ErrorMessage__c', res.errorDescription);
                }
                record.put('IntegrationStatus__c', 'Failure');
                updateRequest.add(record);
                
            }
            /*if(!updateRequest.isempty()){
                update updateRequest;
            } */
            
            if(updateRequest!=null){
                List<string> fieldNamesList = New List<string>{'ErrorMessage__c','IntegrationStatus__c'};
                    String sObjectName = objectName;
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                uow.registerDirty(updateRequest);
            }
             uow.commitWork();
            
        }
        catch(Exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }
    }
}