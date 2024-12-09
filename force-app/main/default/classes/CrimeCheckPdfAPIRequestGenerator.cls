public class CrimeCheckPdfAPIRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        if(!msgs.isempty()){
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
            List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
            
            try{
                
                for(IntgMsg__c intmsg:msgs){
                    
                    if(string.isNotblank(intmsg.RefId__c)){
                        
                        IntgMsg__c msg =new IntgMsg__c();
                        msg.Id=intmsg.Id;
                        //msg.Req__c='callout:APIGateway/'+msg.RefId__c+'/';
                        msg.Req__c=intmsg.RefId__c;
                        msg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntMsgRecords.add(msg);
                    }
                }
                
                if(!updateIntMsgRecords.isEmpty()){
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntMsgRecords);
                    
                }
                uow.commitWork();
            }catch(Exception ex){
                GlobalUtility.logMessage('Error', 'CrimeCheckPdfAPIRequestGenerator class', 
                                         'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
    }
    
}