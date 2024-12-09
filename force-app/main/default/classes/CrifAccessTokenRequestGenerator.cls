public class CrifAccessTokenRequestGenerator implements ICalloutRequestGenerator{
	public void generate(List<IntgMsg__c> msgs, String service, String processType){ 
        
        try{
            List<IntgMsg__c>updateIntMsgList=New List<IntgMsg__c>(); 
            
            if(!msgs.isEmpty()){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('');
                for(IntgMsg__c intMsg : msgs){
                    
                    if(intMsg.RefId__c!=null){
                        CrifAccessTokenRequestWrapper requestBody = new CrifAccessTokenRequestWrapper();
                        requestBody.userName = svc.Username__c;
                        requestBody.password = svc.Password__c;
                        IntgMsg__c intg=New IntgMsg__c();
                        intg.id=intMsg.id;
                        intg.Req__c = JSON.serialize(requestBody);
                        intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntMsgList.add(intg);
                    }
                }
                
                if(!updateIntMsgList.isEmpty()){
                    update updateIntMsgList;
                }
            }
           
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifAccessTokenRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    
}