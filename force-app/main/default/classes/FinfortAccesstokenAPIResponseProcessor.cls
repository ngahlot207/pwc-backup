public class FinfortAccesstokenAPIResponseProcessor implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses) {
        
        if(!responses.isEmpty()){
            
            Map<IntgMsg__c,FinfortAccesstokenAPIResponseWrapper> successResponseMap = new Map<IntgMsg__c,FinfortAccesstokenAPIResponseWrapper>();
            Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
            
            for(IntgMsg__c intmsg :responses){
                
                if(String.isNotblank(intmsg.Resp__c)){
                    
                    try{
                        
                        FinfortAccesstokenAPIResponseWrapper  res =(FinfortAccesstokenAPIResponseWrapper) JSON.deserialize(intmsg.Resp__c,FinfortAccesstokenAPIResponseWrapper.class);
                        
                        if(res!=null && res.statusCode==1){
                            successResponseMap.put(intmsg,res);
                        }
                        else if(res!=null && res.statusCode!=1 && string.isNotblank(res.msg)){
                            failureResponseMap.put(intmsg,res.msg);
                        }
                        
                    }catch(Exception ex){
                        GlobalUtility.logMessage('Error', 'FinfortAccesstokenAPIResponseProcessor class', 
                                                 'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                        failureResponseMap.put(intmsg,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                    }
                    
                }
            }
            
            if(!successResponseMap.isEmpty()){
                processSuccess(successResponseMap);
            }
            
            if(!failureResponseMap.isEmpty()){
                processFailure(failureResponseMap);
            }
        }
    }
    //******************************************************************************************************************************************
    public static void processSuccess(Map<IntgMsg__c,FinfortAccesstokenAPIResponseWrapper> successResp){
        
        try{
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
            
            List<IntgMsg__c> intMsgRecsToInsert = new List<IntgMsg__c>();
            
            //Looping MapKeyset
            for(IntgMsg__c intmsg:successResp.keyset()){
                
                IntgMsg__c intMsgRec = new IntgMsg__c();
                intMsgRec.Name = (String.isNotblank(intmsg.Svc__c) && intmsg.Svc__c=='FinFort Auth Token - GST')?'Create Order - GST':'Create Order - ITR';
                intMsgRec.BU__c = 'HL / STL';
                intMsgRec.Status__c = GlobalConstants.INT_MSG_STATUS_NEW;
                intMsgRec.MStatus__c = GlobalConstants.INT_MSG_MStatus_BLANK;
                intMsgRec.Svc__c = (String.isNotblank(intmsg.Svc__c) && intmsg.Svc__c=='FinFort Auth Token - GST')?'Create Order - GST':'Create Order - ITR';
                intMsgRec.RefId__c = intmsg.RefId__c;
                intMsgRec.RefObj__c = 'Applicant__c';
                intMsgRec.ParentRefId__c =intmsg.Id;
                intMsgRec.ParentRefObj__c = 'IntgMsg__c';
                intMsgRec.IsActive__c = TRUE;
                intMsgRecsToInsert.add(intMsgRec);
                
                
                if(intmsg.Trigger_Platform_Event__c){
                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                    platformWra.intId = intmsg.Id; 
                    platformWra.recId = intmsg.RefId__c;
                    platformWra.ServiceName = intmsg.Svc__c ;
                    platformWra.Status = intmsg.Status__c ;
                    platformWra.success=true;
                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                }
                APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Success');
                
            }
            
            
            //Inserting the IntgMsg
            if(!intMsgRecsToInsert.isEmpty()) {
                String sObjectName = 'IntgMsg__c';
                List<String> fieldNamesList = new List<String>{'Name','BU__c','Status__c','MStatus__c','Svc__c','RefId__c','RefObj__c',
                    'ParentRefId__c','ParentRefObj__c','IsActive__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerNew(intMsgRecsToInsert);
            }
            uow.commitWork();
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortAccesstokenAPIResponseProcessor', 
                                     'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    
    //******************************************************************************************************************************************
    public static void processFailure(Map<IntgMsg__c,String> failureResp){
        
        try{
            
            for(IntgMsg__c intmsg:failureResp.keyset()){
                
                
                if(intmsg.Trigger_Platform_Event__c){
                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                    platformWra.intId = intmsg.Id; 
                    platformWra.recId = intmsg.RefId__c;
                    platformWra.ServiceName = intmsg.Svc__c ;
                    platformWra.Status = intmsg.Status__c ;
                    platformWra.errorMessage=failureResp.get(intmsg);
                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                } 
                APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
                
            }
            
            
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortAccesstokenAPIResponseProcessor', 
                                     'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
}