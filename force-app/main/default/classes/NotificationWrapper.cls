public without sharing class NotificationWrapper {
	@auraEnabled public string targetId{get;set;}
    @auraEnabled public Set<String> recipientIds{get;set;}
    @auraEnabled public string title{get;set;}
    @auraEnabled public string body{get;set;}
    @auraEnabled public string recipientType{get;set;}
    @auraEnabled public Set<string> recipientEmails{get;set;}
    @auraEnabled public List<string> ccReciepientEmails{get;set;}
    @auraEnabled public String notificationType{get;set;}
    @auraEnabled public String templateId{get;set;}
    
    public static NotificationWrapper prepareNotificationData(string targetId1,Set<String> recipientIds1,string title1,string body1,string recipientType1,Set<string> recipientEmails1,List<string> ccReciepientEmails1,String notificationType1,String templateId1){
        NotificationWrapper wrap = new NotificationWrapper();
        if(notificationType1 == 'Bell'){
            wrap.targetId = targetId1;
            wrap.recipientIds = recipientIds1;
            wrap.title = title1;
            wrap.body = body1;
            wrap.notificationType = 'Bell';
        }else if(notificationType1 == 'Email'){
            wrap.targetId = targetId1;
            wrap.recipientIds = recipientIds1;
            wrap.title = title1;
            wrap.body = body1;
            wrap.ccReciepientEmails = ccReciepientEmails1;
            wrap.recipientEmails = recipientEmails1;
            wrap.templateId = templateId1;
            wrap.notificationType = 'Email';
            wrap.recipientType = recipientType1;
        }
        return wrap;
    }
    
    
}