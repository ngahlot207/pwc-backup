public class SequenceAPIRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
        
        try{
                List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                if(!msgs.isempty()){
                    for(IntgMsg__c intmsg:msgs){
                
                    SequenceAPIRequestWrapper request=new SequenceAPIRequestWrapper();
                    request.requestId=GlobalUtility.getUniqueNumber();
                    request.sourceId=system.label.Sequence_API_sourceId;
                    request.errorDesc='';//
                    request.user=system.label.Sequence_API_User;
                    request.password=system.label.Sequence_API_Password;
                    request.applicantType='';
                    
                        system.debug('request---'+JSON.serialize(request));
                    
                    IntgMsg__c integrationMessage =new IntgMsg__c();
                    integrationMessage.Id=intmsg.Id;
                    integrationMessage.Req__c=JSON.serialize(request);
                    integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                    updateIntMsgRecords.add(integrationMessage);
                   
                }
                    system.debug('updateIntMsgRecords---'+updateIntMsgRecords);
                    
                    if(!updateIntMsgRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntMsgRecords);
                }
                    
                }
                 uow.commitWork();
                
            }
                catch(Exception ex){
                     GlobalUtility.logMessage('Error', 'SequenceAPIRequestGenerator class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                }
         
    }
    
    
}