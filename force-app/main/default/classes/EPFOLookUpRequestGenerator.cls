public class EPFOLookUpRequestGenerator implements ICalloutRequestGenerator{
    
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        if(!msgs.isEmpty()){
            
            try{
                
                List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                Set<Id> applicantIds=new Set<Id>();
                
                for(IntgMsg__c intmsg:msgs){
                    
                    if(String.isNotblank(intmsg.RefId__c)){
                        applicantIds.add(intmsg.RefId__c);
                    }
                }
                
                if(!applicantIds.isEmpty()){
                    
                    Map<Id,Applicant__c> applicantMap =new Map<Id,Applicant__c>([Select Id,MobNumber__c from Applicant__c Where Id IN:applicantIds]);
                    
                    IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('EPF_UAN_Lookup');
                    
                    for(IntgMsg__c intmsg:msgs){
                        
                        if(applicantMap.containsKey(intmsg.RefId__c)){
                            
                            EPFOLookUpRequestWrapper.ClientData clientdata =new EPFOLookUpRequestWrapper.ClientData();
                            clientdata.caseId=intmsg.Integration_Message_Number__c;
                            
                            EPFOLookUpRequestWrapper request =new EPFOLookUpRequestWrapper();
                            request.consent=string.isNotblank(svc.StaticKey__c)?svc.StaticKey__c:'';
                            request.mobile=String.isNotblank(applicantMap.get(intmsg.RefId__c).MobNumber__c)?applicantMap.get(intmsg.RefId__c).MobNumber__c.replaceAll('[^0-9]', ''):'';
                            request.clientData=clientdata;
                            
                            IntgMsg__c integrationMessage =new IntgMsg__c();
                            integrationMessage.Id=intmsg.Id;
                            integrationMessage.Req__c=JSON.serialize(request);
                            integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                            updateIntMsgRecords.add(integrationMessage);
                        }
                    }
                }
                
                
                if(!updateIntMsgRecords.isEmpty()){
                    Update updateIntMsgRecords;
                }
                
            }catch(Exception ex){
                GlobalUtility.logMessage('Error', 'EPFOLookUpRequestGenerator class', 
                                         'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
    }
    
}