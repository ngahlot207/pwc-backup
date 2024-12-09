public class EmailNotificationRequestGenerator implements ICalloutRequestGenerator{
    public static final String alertType = 'EMAIL';
    public static final String parentType = 'SFDC';
    public static final String booleanTrue = 'true';
    public static final String INTEGRATION_MSG_STATUS_INPROGRESS = 'In Progress';
	
    public static void generate(List<IntgMsg__c> msgs,String service, String processType) {
        try{
            if(!msgs.isempty()){
            	List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                for(IntgMsg__c msg : msgs){
                    EmailNotificationRequestWrapper requestBody = generateRequestBody(msg);
            		IntgMsg__c integrationMessage = new IntgMsg__c();
            		integrationMessage.Id=msg.Id;
            		integrationMessage.Req__c=JSON.serialize(requestBody);
            		integrationMessage.Status__c=INTEGRATION_MSG_STATUS_INPROGRESS;
            		updateIntMsgRecords.add(integrationMessage);
                }
                if(!updateIntMsgRecords.isEmpty()){
                    update updateIntMsgRecords;
                }
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'EmailNotificationRequestGenerator class', 
                                     'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    public static EmailNotificationRequestWrapper generateRequestBody(IntgMsg__c intMsg){
        try{
            EmailNotificationRequestWrapper requestBody = new EmailNotificationRequestWrapper();
            if(intMsg!=null){
                Set<Id> emailMessageIds = new Set<Id>();
                if(String.isnotBlank(intMsg.RefId__c)){
                    emailMessageIds.add(intMsg.RefId__c);
                }
                
                Map<Id, EmailMessage> emailMessageMap = new Map<Id, EmailMessage>([Select Id, HasAttachment, Priority__c, Subject, HtmlBody, TextBody, ToAddress, CcAddress, BccAddress From EmailMessage Where Id IN:emailMessageIds]);
                
                if(emailMessageMap.containsKey(intMsg.RefId__c)){
                    EmailNotificationRequestWrapper.Message message = new EmailNotificationRequestWrapper.Message();
                    EmailNotificationRequestWrapper.Body body = new EmailNotificationRequestWrapper.Body();                        
                    List<EmailNotificationRequestWrapper.Recipient> toRecipientList = new List<EmailNotificationRequestWrapper.Recipient>();
                    List<EmailNotificationRequestWrapper.Recipient> ccRecipientList = new List<EmailNotificationRequestWrapper.Recipient>();
                    List<EmailNotificationRequestWrapper.Recipient> bccRecipientList = new List<EmailNotificationRequestWrapper.Recipient>();
                    EmailNotificationRequestWrapper.Attachment attachments = new EmailNotificationRequestWrapper.Attachment();
                    List<EmailNotificationRequestWrapper.Attachment> attachmentsList = new List<EmailNotificationRequestWrapper.Attachment>();
                        
                    requestBody.alertType = alertType;
                    requestBody.parentType = parentType;
				    requestBody.isAttachment = emailMessageMap.get(intMsg.RefId__c).HasAttachment==true ? 1 : 0;
                    requestBody.parentID = emailMessageMap.get(intMsg.RefId__c).Id;
                        
                    if(emailMessageMap.get(intMsg.RefId__c).Priority__c == 'Delay'){
                       requestBody.priority = 2;
                    }else{
                        requestBody.priority = 1;
					}
                        
                    message.subject = emailMessageMap.get(intMsg.RefId__c).Subject!=null ? emailMessageMap.get(intMsg.RefId__c).Subject : '';
                    requestBody.message = message;
                        
                    body.contentType = emailMessageMap.get(intMsg.RefId__c).HtmlBody!=null ? 'html' : 'text';
                    body.content = emailMessageMap.get(intMsg.RefId__c).HtmlBody!=null ? emailMessageMap.get(intMsg.RefId__c).HtmlBody : emailMessageMap.get(intMsg.RefId__c).TextBody;
                    requestBody.message.body = body;
                        
                    String toAddress = emailMessageMap.get(intMsg.RefId__c).ToAddress!=null ? emailMessageMap.get(intMsg.RefId__c).ToAddress : '';
                    List<String> toAddressList = new List<String>();
                    if(emailMessageMap.get(intMsg.RefId__c).ToAddress!=null){
                        toAddressList = toAddress.split(';');
                    }
                    for(String item : toAddressList){
                        EmailNotificationRequestWrapper.EmailAddress emailAddress = new EmailNotificationRequestWrapper.EmailAddress();
                        EmailNotificationRequestWrapper.Recipient recipient = new EmailNotificationRequestWrapper.Recipient();
                        emailAddress.address = item.trim();
                        recipient.emailAddress = emailAddress;
                        toRecipientList.add(recipient);
                    }
                    requestBody.message.toRecipients = toRecipientList;
                        
                    String ccAddress = emailMessageMap.get(intMsg.RefId__c).CcAddress!=null ? emailMessageMap.get(intMsg.RefId__c).CcAddress : '';
                    List<String> ccAddressList = new List<String>();
                    if(emailMessageMap.get(intMsg.RefId__c).CcAddress!=null){
                        ccAddressList = ccAddress.split(';');
                    }
                    for(String item : ccAddressList){
                        EmailNotificationRequestWrapper.EmailAddress emailAddress = new EmailNotificationRequestWrapper.EmailAddress();
                        EmailNotificationRequestWrapper.Recipient recipient = new EmailNotificationRequestWrapper.Recipient();
                        emailAddress.address = item.trim();
                        recipient.emailAddress = emailAddress;
                        ccRecipientList.add(recipient);
                    }
                    requestBody.message.ccRecipients = ccRecipientList;
                        
                    String bccAddress = emailMessageMap.get(intMsg.RefId__c).BccAddress!=null ? emailMessageMap.get(intMsg.RefId__c).BccAddress : '';
                    List<String> bccAddressList = new List<String>();
                    if(emailMessageMap.get(intMsg.RefId__c).BccAddress!=null){
                       bccAddressList = bccAddress.split(';');
                    }
                    for(String item : bccAddressList){
                        EmailNotificationRequestWrapper.EmailAddress emailAddress = new EmailNotificationRequestWrapper.EmailAddress();
                        EmailNotificationRequestWrapper.Recipient recipient = new EmailNotificationRequestWrapper.Recipient();
                        emailAddress.address = item.trim();
                       	recipient.emailAddress = emailAddress;
                        bccRecipientList.add(recipient);
                    }
                    requestBody.message.bccRecipients = bccRecipientList;
                        
                    if(emailMessageMap.get(intMsg.RefId__c).HasAttachment==true){
                        attachments.name='';
                        attachments.contentType='';
                        attachments.contentBytes='';
                        attachmentsList.add(attachments);
                    }
                    requestBody.message.attachments = attachmentsList;
                    requestBody.saveToSentItems = booleanTrue;
                }
            }
           	return requestBody;
       	}
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'EmailNotificationRequestGenerator class', 
                                         'generateRequestBody', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            return null;
        } 
    }
}