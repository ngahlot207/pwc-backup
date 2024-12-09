public class FinfortAccesstokenAPIRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
        
        if(!msgs.isEmpty()){
            
            try{
                
                List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                Map<String,APIConfiguration__c> APICrdMap = APIConfiguration__c.getAll();
                
                //Looping IntgMsg__c
                for(IntgMsg__c intmsg :msgs){
                    
                    
                    FinfortAccesstokenAPIRequestWrapper.Params par =new FinfortAccesstokenAPIRequestWrapper.Params();
                    par.emailId=APICrdMap!=null?APICrdMap.get('Finfort Access Token').Email__c:'';
                    par.password=APICrdMap!=null?APICrdMap.get('Finfort Access Token').Password__c:'';
                    
                    FinfortAccesstokenAPIRequestWrapper request =new FinfortAccesstokenAPIRequestWrapper();
                    request.request=APICrdMap!=null?APICrdMap.get('Finfort Access Token').RequestType__c:'';
                    request.param=par;
                    
                    
                    IntgMsg__c integrationMessage =new IntgMsg__c();
                    integrationMessage.Id=intmsg.Id;
                    integrationMessage.Req__c=JSON.serialize(request);
                    integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                    updateIntMsgRecords.add(integrationMessage);
                    
                }
                
                
                //Updating the IntgMsg
                if(!updateIntMsgRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntMsgRecords);
                }
                uow.commitWork();
                
            }catch(Exception ex){
                GlobalUtility.logMessage('Error', 'FinfortAccesstokenAPIRequestGenerator class', 
                                         'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
    }
    
}