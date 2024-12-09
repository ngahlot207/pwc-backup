public class EmailMessageBatchHandler implements Queueable, Database.Allowscallouts {
	public static final String EMAIL_MSG_NAME = 'Email Notification';
    public static final String INTEGRATION_MSG_STATUS_INPROGRESS = 'In Progress';
    public static final String EMAIL_MSG_BU_TYPE = 'HL / STL';
    public static final String EMAIL_MSG_SVC_NAME = 'Email Notification';
    public static final String EMAIL_MSG_VNDR_NAME = 'Fedfina';
    public static final Boolean BOOLEAN_FALSE = false;
    private List<IntgMsg__c> intMsgList;
    
    public EmailMessageBatchHandler(List<IntgMsg__c> intMsgList){
        this.intMsgList=intMsgList;
    }
    public static void handleEmailMessage(List<EmailMessage> emailMsgList){
        try{
            List<IntgMsg__c> intMsgList = new List<IntgMsg__c>();
        	for(EmailMessage msg : emailMsgList){
                if(msg.BulkEmail__c){
                   	Id recordId = msg.Id;
                	String sObjectname = recordId.getSObjectType().getDescribe().getName();
            		IntgMsg__c intMsg = new IntgMsg__c();
            		intMsg.Name = EMAIL_MSG_NAME;
            		intMsg.BU__c = EMAIL_MSG_BU_TYPE;
            		intMsg.RefId__c = recordId;
            		intMsg.Status__c = INTEGRATION_MSG_STATUS_INPROGRESS;
            		intMsg.RefObj__c = sObjectname;
                    intMsg.ApiVendor__c = EMAIL_MSG_VNDR_NAME;
            		intMsg.Svc__c = EMAIL_MSG_SVC_NAME;
            		intMsg.IsActive__c = BOOLEAN_FALSE;
                    intMsg.Req__c=JSON.serialize(EmailNotificationRequestGenerator.generateRequestBody(intMsg));
            		intMsgList.add(intMsg); 
                    system.debug('intMsgList>> '+intMsgList);
                }
        	}
            if(!intMsgList.isEmpty()){
            	insert intMsgList;
        	}
            System.enqueueJob(new EmailMessageBatchHandler(intMsgList));
        }
        catch(Exception ex){
            System.debug('Exception>> '+ex.getLineNumber()+' '+ex.getMessage());
        	GlobalUtility.logMessage('Error', 'EmailMessageBatchHandler class', 
                                     'handleEmailMessage', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    
    public void execute(QueueableContext context){
        try{
            if(!intMsgList.isEmpty()){
                system.debug('intMsgList in execute>> '+intMsgList);
                List<IntgMsg__c> updatedIntMsgList = new List<IntgMsg__c>();
                for(IntgMsg__c intMsg : intMsgList){
                   if(String.isNotBlank(intMsg.Req__c)) {
                    Http http = new Http();
                   	HttpRequest req = new HttpRequest();
                    req.setEndpoint('callout:APIGateway');
                    req.setMethod('POST');
                    req.setHeader('APIVendor', intMsg.ApiVendor__c);
                    req.setHeader('APIname', intMsg.Svc__c);
                 	req.setHeader('RecordID', intMsg.Id);
                    req.setBody(intMsg.Req__c);
                    req.setTimeout(30000);
                        
                    HttpResponse res = http.send(req);
                    system.debug('res>> '+res);
                    intMsg.Mresp__c=res.getBody();
                    intMsg.MStatus__c=GlobalConstants.INT_MSG_MStatus_ACKNOWLEDGED;
                    updatedIntMsgList.add(intMsg);
                    System.debug('StatusCode==' + res.getStatusCode());
                    System.debug('Response==' + res.getBody()); 
                }
                system.debug('updatedIntMsgList>> '+updatedIntMsgList);
               }
                if(!updatedIntMsgList.isEmpty()){
                    update updatedIntMsgList;
                }
            }
        }
        catch(Exception ex){
            System.debug('Exception>> '+ex.getLineNumber()+' '+ex.getMessage());
        	GlobalUtility.logMessage('Error', 'EmailMessageBatchHandler class', 
                                     'emailNotificationCallout', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
}