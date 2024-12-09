public class PennyDropResponseProcessor implements IintMsgCalloutResponseProcessor{
    public static void process(List<IntgMsg__c> responses) {
        
        for(IntgMsg__c integrationMessage : responses){
            
            try{
                PennyDropResponseWrappper res =(PennyDropResponseWrappper) JSON.deserialize(integrationMessage.Resp__c, PennyDropResponseWrappper.class);
                
                if(res.status=='SUCCESS' && res.chequeId!=null){
                    
                    PennyDropSuccess(res,integrationMessage.RefId__c,integrationMessage.RefObj__c);
                    APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                }
                else if(res.status!='SUCCESS'){
                    PennyDropFailure(res,integrationMessage.RefId__c,integrationMessage.RefObj__c);
                    APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                }
            }
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'PennyDropResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
    }
    //******************************************************************************************************************
    public static void PennyDropSuccess(PennyDropResponseWrappper response,Id refid, String refObject){
        
        fflib_SObjectUnitOfWork uow; 
        if(refObject=='RepayAccVerify__c'){
            uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {RepayAccVerify__c.SObjectType });
        }
        else if(refObject=='Split_Disbur__c'){
            uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {Split_Disbur__c.SObjectType });
        }
        
        List<SObject> updatelist =new List<SObject>();
        try{
            if(response!=null && refId!=null && refObject!=null){
                
                SObject record = (SObject) Type.forName(refObject).newInstance();
                record.Id = refid;
                
                if(!string.isblank(response.chequeId)){
                    record.put('ChequeId__c',response.chequeId);
                }
                record.put('IntegrationStatus__c','Success');
                record.put('ErrorMess__c','');
                updatelist.add(record);
            }
            if(updatelist!=null){
                List<string> fieldNamesList = New List<string>{'ChequeId__c','IntegrationStatus__c','ErrorMess__c'};
                    String sObjectName = refObject;
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                uow.registerDirty(updatelist);
            }
            uow.commitWork();
			
        } 
        catch(Exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }
    }  
    //******************************************************************************************************************
    public static void PennyDropFailure(PennyDropResponseWrappper response,Id refid, String refObject){
        
        fflib_SObjectUnitOfWork uow; 
        if(refObject=='RepayAccVerify__c'){
            uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {RepayAccVerify__c.SObjectType });
        }
        else if(refObject=='Split_Disbur__c'){
            uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {Split_Disbur__c.SObjectType });
        }
        
        List<SObject> updatelist =new List<SObject>();
        try{
            if(response!=null && refId!=null && refObject!=null){
                
                SObject record = (SObject) Type.forName(refObject).newInstance();
                record.Id = refid;
                
                if(!string.isblank(response.errorDescription)){
                    record.put('ErrorMess__c',response.errorDescription);
                }
                record.put('IntegrationStatus__c','Failure');
                
                updatelist.add(record);
            }
            if(updatelist!=null){
                List<string> fieldNamesList = New List<string>{'ErrorMess__c','IntegrationStatus__c'};
                    String sObjectName = refObject;
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                uow.registerDirty(updatelist);
            }
            uow.commitWork();
            
        } 
        catch(Exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }
    }  
}