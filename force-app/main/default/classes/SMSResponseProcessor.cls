public class SMSResponseProcessor implements IintMsgCalloutResponseProcessor{
	
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        
        //Processing all responses
        for(IntgMsg__c integrationMessage : responses){
            if(integrationMessage.Svc__c != 'SMS'){
                throw new processException('Error! This is not the correct service'); 
            }
            try{
                if(integrationMessage.Resp__c != null){
                //parse response
                SMSWrapper.Response responseWrapper = (SMSWrapper.Response) JSON.deserialize(integrationMessage.Resp__c, SMSWrapper.Response.class); 
                    
                //check if responseWrapper is empty or not
                if(responseWrapper != null){
                    //Note : Waiting for fields Information which need to be updated 
                    system.debug('responseWrapper '+ responseWrapper);
                    system.debug('responseWrapper get Request Id ' +  responseWrapper.result.req_id);
                    
                    //publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                    //platformWra.appId = integrationMessage.RefId__c;
                    //platformWra.ServiceName = integrationMessage.Svc__c ;
                    //platformWra.Status = integrationMessage.Status__c ;
                    //platformWra.intId = integrationMessage.Id ; 
                    //publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                    
                    if(responseWrapper.result != null && responseWrapper.result.status != null && String.isNotBlank(responseWrapper.result.status.statusCode)){
                        if(responseWrapper.result.status.statusCode =='0'){
                            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                        }
                        else{
                            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                        }
                    }
                    
                    
                } 
                }else{
                    throw new SMSException('Response payload is null'); 
                }
            }
            //Exception Handling
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'SMSResponseProcessor', 'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }  
            
        }       
    } 
    
    
    public class SMSException extends exception{
        
    }

}