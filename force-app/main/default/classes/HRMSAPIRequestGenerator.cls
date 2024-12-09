public class HRMSAPIRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
        
        
        try{
            if(!msgs.isempty()){
                
                List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                
                for(IntgMsg__c intmsg:msgs){
                    
                    Map<String,object> request =new Map<String,object>();
                    request.put('emp_code','00000');
                    IntgMsg__c integrationMessage =new IntgMsg__c();
                    integrationMessage.Id=intmsg.Id;
                    integrationMessage.Req__c=JSON.serialize(request);
                    integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                    updateIntMsgRecords.add(integrationMessage);
                }
                
                
                if(!updateIntMsgRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntMsgRecords);
                }
                
                uow.commitWork();
            }
        }
        catch(Exception ex){
                     GlobalUtility.logMessage('Error', 'HRMSAPIRequestGenerator class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                }
    }
}