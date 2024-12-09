public without sharing class EmailNotificationResponseProcessor implements IintMsgCalloutResponseProcessor{
	
    public static void process(List<IntgMsg__c> responses){
    	try{
            Set<Id> emailMessageIds = new Set<Id>();
            List<EmailMessage> emailMessageList = new List<EmailMessage>();
            for(IntgMsg__c integrationMessage : responses){
                emailMessageIds.add(integrationMessage.RefId__c);
                EmailMessage emailMessage = [Select Id, APIStatus__c, APIMessage__c, APIReferenceID__c From EmailMessage Where Id IN:emailMessageIds];
                EmailNotificationResponseWrapper response = (EmailNotificationResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, EmailNotificationResponseWrapper.class);
                if(response!=null){
                    if(response.Status!=null){
                        system.debug('response>> '+response);
                        emailMessage.APIMessage__c=response.Message;
                        emailMessage.APIReferenceID__c=response.Data[0].ReferenceID;
                    	if(Integer.valueOf(response.Status)==1){
                            emailMessage.APIStatus__c='Success';
                            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                    	}
                    	else{
                            emailMessage.APIStatus__c='Failure';
                            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                    	}
                        emailMessageList.add(emailMessage);
                    }
                }
            }
            if(emailMessageList.size()>0){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { EmailMessage.SObjectType });
                uow.registerDirty(emailMessageList);
                uow.commitWork();
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'EmailNotificationResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
}