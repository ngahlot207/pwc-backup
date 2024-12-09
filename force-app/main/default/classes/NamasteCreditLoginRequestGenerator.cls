public class NamasteCreditLoginRequestGenerator implements ICalloutRequestGenerator{
    
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        if(!msgs.isEmpty()){
            
            
            try{
                
                List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                
                for(IntgMsg__c intmsg:msgs){
                    
                    Map<String,String> requestMap =new Map<String,String>();
                    
                    requestMap.put('email','fedfinatest@namastecredit.com');
                    requestMap.put('password','TestFedfina@123');
                    requestMap.put('white_label_id','2548e38e6ee3e0126f1d18c50daaab6f');
                    
                    IntgMsg__c integrationMessage =new IntgMsg__c();
                    integrationMessage.Id=intmsg.Id;
                    integrationMessage.Req__c=NamasteCreditAPIController.getEncryptedRequest(JSON.serialize(requestMap));
                    integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                    updateIntMsgRecords.add(integrationMessage);
                }
                
                if(!updateIntMsgRecords.isEmpty()){
                    Update updateIntMsgRecords;
                }
                
            }catch(Exception ex){
                GlobalUtility.logMessage('Error', 'NamasteCreditLoginRequestGenerator class', 
                                         'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            
        }
    }
    
}