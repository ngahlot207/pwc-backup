public class AadharVaultResponseProcessor implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses){ 
        
        for(IntgMsg__c integrationMessage : responses){
            
            try{
                
                AadharVaultResponseWrapper res=(AadharVaultResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, AadharVaultResponseWrapper.class);
                
                if(res!=null){
                    if(res.RESPONSE.STATUS=='1'|| res.RESPONSE.STATUS=='0'){
                        DataVault(res,integrationMessage.RefId__c,integrationMessage);
                        
                    }
                    
                }
            }
            //Exception Handling
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'AadharVaultResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            } 
            
        }
    }
    
    //************************************************************************************************************************************//	
    public static void DataVault(AadharVaultResponseWrapper res,Id referenceid,IntgMsg__c integrationMessage){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplKyc__c.SObjectType });
        
        try{
            Boolean isSuccess;
            if(res!=null){
                ApplKyc__c updateRec=New ApplKyc__c();
                updateRec.id=referenceid;
                
                if(res.RESPONSE.STATUS=='1' && !string.isBlank(res.RESPONSE.UUID)){
                    updateRec.UUID__c=res.RESPONSE.UUID;
                    updateRec.AadharEncripted__c=null;
                    isSuccess=true;
                }
                
                if(res.RESPONSE.STATUS=='0'){
                    updateRec.UUID_Error__c=res.RESPONSE.ERRORMSG;
                    isSuccess=false;
                }
                
                if(updateRec!=null){
                    List<string> fieldNamesList = New List<string>{'UUID__c','UUID_Error__c'};
                        String sObjectName = 'ApplKyc__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                    uow.registerDirty(updateRec);
                }
            }
            uow.commitWork(); 
            if(isSuccess){
                APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
            }
            else{
                APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
            }
            
        }
        catch(Exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }
        
    }
    
}