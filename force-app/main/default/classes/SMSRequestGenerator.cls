public class SMSRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){ 
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
            new List<SObjectType> { IntgMsg__c.SObjectType }
        );
        //Creating a List of Ids
        set<Id> Ids = new set<Id>();
        
        //Iterating over new Intgeration Message record Ids to add them into the above List
        for(IntgMsg__c intMsg : msgs){ 
            Ids.add(intMsg.RefId__c);
        }
        
        
        
        //Fetching required fields to create Request Payload
        Map<Id,Task> taskRecMap = new Map<Id,Task>([SELECT Id,MobNum__c,OTP__c,Description FROM Task WHERE RecordType.DeveloperName = 'SMS' AND ID IN:Ids]);
        
        String countrycode = '91';
        String msgtype = 'text';
        
        try{
            
            List<IntgMsg__c> updateIntMsgList=New List<IntgMsg__c>(); 
            
            if(!msgs.isEmpty()){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('SMS');
                for(IntgMsg__c intMsg : msgs){
                    
                    msgtype = taskRecMap.get(intMsg.RefId__c).OTP__c !=null ? GlobalConstants.MsgtypeOTP : GlobalConstants.MsgtypeText;
                    String message= taskRecMap.get(intMsg.RefId__c).Description;
                    String mobileNumber = taskRecMap.get(intMsg.RefId__c).MobNum__c.Right(10);
                    String encodedMsg = EncodingUtil.urlEncode(message, 'UTF-8');
        			//String endpoint= 'https://www.msg2all.com/TRANSAPI/sendsms.jsp?login=' + loginId + '&passwd=' + password + '&version=' + version + '&msisdn='+ countrycode + mobileNumber + '&msg_type=' + msgtype + '&msg=' + encodedMsg + '&sender_id=' + senderId;
                    String endpoint= 'callout:IkontelSMSAPI?login=' + svc.Username__c + '&passwd=' + svc.Password__c + '&version=' + svc.ApiVersion__c + '&msisdn='+ GlobalConstants.CountryCode + mobileNumber + '&msg_type=' + msgtype + '&msg=' + encodedMsg + '&sender_id=' + svc.SenderId__c;
                    
                    IntgMsg__c intg=New IntgMsg__c();
                    intg.id=intMsg.id;
                    intg.Req__c = endpoint;
                    intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                    updateIntMsgList.add(intg);
                }
                
            }
            if(!updateIntMsgList.isEmpty()){
                List<string> fieldNamesList = New List<string>{'Req__c','Status__c'};    
                String sObjectName = 'IntgMsg__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(updateIntMsgList);
                
            }
            uow.commitWork();
        }
        
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'SMSRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
}