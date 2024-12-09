public class EmailRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){  
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
            new List<SObjectType> { IntgMsg__c.SObjectType }
        );
        //Creating a Set of Ids
        Set<Id> Ids = new Set<Id>();
        
        //Iterating over new Intgeration Message record Ids to add them into the above Set
        for(IntgMsg__c intMsg : msgs){ 
            Ids.add(intMsg.RefId__c);
        }
        
        //Fetching required fields to create Request Payload
        Map<Id,Applicant__c> appRecMap = new Map<Id,Applicant__c>([SELECT Id,EmailId__c FROM Applicant__c WHERE Id IN :Ids]);
        
        try{
            
            if(!msgs.isEmpty()){
                List<IntgMsg__c>UpdateIntgMsgList=New List<IntgMsg__c>();           
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Email_Verification');
                for(IntgMsg__c intMsg : msgs){
                    
                    if(appRecMap.containsKey(intMsg.RefId__c)){
                        
                        EmailRequestWrapper EmailDetails = new EmailRequestWrapper();
                        EmailDetails.email = appRecMap.get(intMsg.RefId__c).EmailId__c;
                        EmailDetails.version = svc.ApiVersion__c;
                        EmailRequestWrapper.ClientData cd = new EmailRequestWrapper.ClientData();
                        cd.caseId = intmsg.Integration_Message_Number__c;
                        EmailDetails.clientData=cd;
                        
                        IntgMsg__c intg = New IntgMsg__c();
                        intg.id = intMsg.id;
                        intg.Req__c = JSON.serialize(EmailDetails) ;
                        intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        UpdateIntgMsgList.add(intg);
                        
                    }     
                    
                }
                if(!UpdateIntgMsgList.isEmpty()){
                    List<string> fieldNamesList = New List<string>{'Req__c','Status__c'};               
                        String sObjectName = 'IntgMsg__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(UpdateIntgMsgList);
                    //update UpdateIntrecods;
                }
                uow.commitWork();
            }
        }
        catch(Exception ex){
            System.debug('error '+ex.getMessage());
            GlobalUtility.logMessage('Error', 'EmailRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
}