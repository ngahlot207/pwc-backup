public class CrifAccessTokenResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    public static void process(List<IntgMsg__c> responses){ 
        try{
            
            List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
            for(IntgMsg__c integrationMessage : responses){
                try{
                    CrifAccessTokenResponseWrapper response = (CrifAccessTokenResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, CrifAccessTokenResponseWrapper.class); 
                    if(response != null && integrationMessage.RefId__c!=null){
                        if(!String.isBlank(response.access_token)){
                            IntgMsg__c intmsg = new IntgMsg__c();
                            intmsg.Name='Initiate Consent';
                            intmsg.Svc__c='Initiate Consent';
                            intmsg.BU__c='HL / STL';
                            intmsg.RefId__c=integrationMessage.RefId__c;
                            intmsg.Status__c='New';
                            intmsg.MStatus__c='Blank';
                            intmsg.RefObj__c='ApplBanking__c';
                            intmsg.IsActive__c=true;
                            intmsg.ParentRefId__c=integrationMessage.Id;
                            intmsg.ParentRefObj__c='IntgMsg__c';
                            createRequestList.add(intmsg);
                            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                        }
                        else if(!String.isBlank(response.errorCode)){
                            if(integrationMessage.Trigger_Platform_Event__c){
                                publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                                platformWra.intId = integrationMessage.Id; 
                                platformWra.recId = integrationMessage.ParentRefId__c;
                                platformWra.ServiceName = integrationMessage.Svc__c ;
                                platformWra.Status = integrationMessage.Status__c ;
                                platformWra.errorMessage = String.isNotBlank(response.errorMsg)?response.errorMsg:response.errorCode;
                                publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                            }
                            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                        }
                    }
                    
                }
                catch(Exception ex){
                    APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                }
            }
            
            if(!createRequestList.isEmpty()){
                insert createRequestList;
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifAccessTokenResponseProcessor class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        } 
    }
}