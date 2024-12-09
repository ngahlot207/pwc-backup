public class EPFOValidationRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        if(!msgs.isEmpty()){
            
            try{
                
                List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('EPF_UAN_Validation');
                
                for(IntgMsg__c intmsg:msgs){
                    
                    if(String.isNotblank(intmsg.ParentRefId__c)){
                        
                        EPFOValidationRequestWrapper.ClientData clientdata =new EPFOValidationRequestWrapper.ClientData();
                        clientdata.caseId=intmsg.Integration_Message_Number__c;
                        
                        EPFOValidationRequestWrapper request =new EPFOValidationRequestWrapper();
                        request.uan=intmsg.ParentRefId__c;
                        request.consent=string.isNotblank(svc.StaticKey__c)?svc.StaticKey__c:'';
                        request.clientData=clientdata;
                        
                        IntgMsg__c integrationMessage =new IntgMsg__c();
                        integrationMessage.Id=intmsg.Id;
                        integrationMessage.Req__c=JSON.serialize(request);
                        integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntMsgRecords.add(integrationMessage);
                    }
                    
                }
                
                if(!updateIntMsgRecords.isEmpty()){
                    Update updateIntMsgRecords;
                }    
                
            }catch(Exception ex){
                GlobalUtility.logMessage('Error', 'EPFOValidationRequestGenerator class', 
                                         'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
    }
    
}