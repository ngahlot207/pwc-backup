public class ENPARequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){  
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
        
        try{
            if(!msgs.isempty()){
                List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>();
                
                //Set<Id> refIds = new Set<Id>();
                Set<Id> applicantIds = new Set<Id>();
                Set<Id> dedupeResponseIds = new Set<Id>();
                for (IntgMsg__c intMsg : msgs) {
                    if(String.isNotBlank(intMsg.RefId__c) && String.isNotBlank(intMsg.RefObj__c) && intMsg.RefObj__c == 'Applicant__c'){
                        applicantIds.add(intMsg.RefId__c);
                    }
                    else if(String.isNotBlank(intMsg.RefId__c) && String.isNotBlank(intMsg.RefObj__c) && intMsg.RefObj__c == 'DedupeResponse__c'){
                        dedupeResponseIds.add(intMsg.RefId__c);
                    }
                    //refIds.add(intMsg.RefId__c);
                }
                
                Map<Id, Applicant__c> applicantMap = new Map<Id, Applicant__c>([select id,UCID__c from Applicant__c where Id IN:applicantIds]);
                Map<Id, DedupeResponse__c> dedupeResponseMap = new Map<Id, DedupeResponse__c>([SELECT Id, UCID__c FROM DedupeResponse__c WHERE Id IN:dedupeResponseIds]);
                for(IntgMsg__c intmsg:msgs){
                    if( (intMsg.RefObj__c == 'Applicant__c'&& applicantMap.containskey(intmsg.RefId__c)) || ( intMsg.RefObj__c == 'DedupeResponse__c' && dedupeResponseMap.containskey(intmsg.RefId__c))){
                        
                        Applicant__c appli=applicantMap.get(intmsg.RefId__c);
                        
                        ENPARequestWrapper request =new ENPARequestWrapper();
                        request.UCIC = intMsg.RefObj__c == 'Applicant__c'? applicantMap.get(intmsg.RefId__c).UCID__c : intMsg.RefObj__c == 'DedupeResponse__c'? dedupeResponseMap.get(intmsg.RefId__c).UCID__c : ''; 
                        
                        
                        IntgMsg__c integrationMessage =new IntgMsg__c();
                        integrationMessage.Id=intmsg.Id;
                        integrationMessage.Req__c=JSON.serialize(request);
                        integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntRecords.add(integrationMessage);
                        
                    }
                }
                if(!updateIntRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntRecords);
                }
                uow.commitWork();
            }
            
            
        }
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch(Exception ex){
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'ENPARequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    public class ENPARequestGeneratorException extends Exception {
        
    }
    
}