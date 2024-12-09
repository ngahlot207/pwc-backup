public class EmailMessageTriggerHandler implements TriggerAction.AfterInsert{
	public static final String EMAIL_MSG_NAME = 'Email Notification';
    public static final String EMAIL_MSG_STATUS = 'New';
    public static final String EMAIL_MSG_BU_TYPE = 'HL / STL';
    public static final String EMAIL_MSG_SVC_NAME = 'Email Notification';
    public static final Boolean BOOLEAN_TRUE = true;
    
    public static void AfterInsert(List<EmailMessage> emailMsgList){
        try{
            system.debug('emailMsgList>> '+emailMsgList);
        	List<IntgMsg__c> intMsgList = new List<IntgMsg__c>();
        	for(EmailMessage msg : emailMsgList){
                if(!msg.BulkEmail__c){
                   	Id recordId = msg.Id;
                	String sObjectname = recordId.getSObjectType().getDescribe().getName();
            		IntgMsg__c intMsg = new IntgMsg__c();
            		intMsg.Name = EMAIL_MSG_NAME;
            		intMsg.BU__c = EMAIL_MSG_BU_TYPE;
            		intMsg.RefId__c = recordId;
            		intMsg.Status__c = EMAIL_MSG_STATUS;
            		intMsg.RefObj__c = sObjectname;
            		intMsg.Svc__c = EMAIL_MSG_SVC_NAME;
            		intMsg.IsActive__c = BOOLEAN_TRUE;
            		intMsgList.add(intMsg); 
                }
        	}
        	system.debug('intMsgList>> '+intMsgList);
        	if(!intMsgList.isEmpty()){
            	insert intMsgList;
        	}
        }
        catch(Exception ex){
            System.debug('Exception>> '+ex.getLineNumber()+' '+ex.getMessage());
        	GlobalUtility.logMessage('Error', 'EmailMessageTriggerHandler class', 
                                     'AfterInsert', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
}