public without sharing class CommunicationMatrixEmailNotification {
    
    @invocableMethod(label='Email Notification method' description='Send email notifications')
    public static void sendEmailCommunication(list<inputVariables> emailDetails){
        string templateId = emailDetails.get(0).emailTemplateId;
  		list<String> recipientIDList = emailDetails.get(0).userId;
  	    list<string> reciepientEmailAddressList = emailDetails.get(0).emailAddress;
        list<string> ccreciepientEmailAddressList = emailDetails.get(0).ccemailAddress;
  		string recipientType = emailDetails.get(0).typeOfRecipient;
  		String relatedID = emailDetails.get(0).loanApplicationID;
        sendEmail(templateId,recipientIDList,reciepientEmailAddressList,ccreciepientEmailAddressList,relatedID,recipientType);
       
    }
    
    @AuraEnabled
     public static void sendEmail(string templateId, list<String> recipientIDList,  list<string> reciepientEmailAddressList, list<string> ccreciepientEmailAddressList,String relatedID, String recipientType){
         system.debug('recipientIDList:'+recipientIDList);
         system.debug('recipientIDList:'+recipientType);
         Id recordId = (Id) relatedID;
         String sObjectType = recordId.getSObjectType().getDescribe().getName();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:system.label.orgWideEmail];
        String oweaAddress = owea.get(0).Id;
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
        //list<string> reciepientEmailAddresslist = new list<String>();
        if (recipientType == 'user') {
            Messaging.SingleEmailMessage mail;
            string recipientId;
            for (string recipientIds: recipientIDList) {
            //recipientId = recipientIDList[0];
                recipientId = recipientIds;
            }
            if(String.isNotBlank(recipientId)){
              	mail = Messaging.renderStoredEmailTemplate(templateId, recipientId, relatedID);  
            }
            
            
            if(owea!=null){
                mail.setOrgWideEmailAddressId(oweaAddress);
                mail.setTargetObjectId(recipientId);
                mail.setSubject(mail.getSubject());
                mail.setHtmlBody(mail.getHtmlBody());
                mail.setSaveAsActivity(false);
                mail.setWhatId(relatedID);
                mail.setToAddresses(reciepientEmailAddressList);
                if (ccreciepientEmailAddressList != null) {
                    mail.setCCAddresses(ccreciepientEmailAddressList);
                }
                mails.add(mail);
            }
            
            
        } else if (recipientType == 'Applicant') {
            String recipientId;
            /*for (string recipientIds: recipientIDList) {
            //recipientId = recipientIDList[0];
                recipientId = recipientIds;
            }*/
           
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId, recipientId, relatedID);
           // Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId, recipientId, relatedID);
            //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           
            
            if(owea!=null){
                mail.setTemplateID(templateId);
                mail.setOrgWideEmailAddressId(oweaAddress);
                mail.setTargetObjectId(recipientId);
                mail.setSubject(mail.getSubject());
                mail.setHtmlBody(mail.getHtmlBody());
                mail.setSaveAsActivity(false);
                mail.settoAddresses(reciepientEmailAddressList);
                mails.add(mail);
        	}
            
        }
        if (!mails.isempty()) {
           
            system.debug('Mail Body:'+mails);
            if(sObjectType != null && sObjectType == 'Lead'){
                Messaging.sendEmail(mails);
            }
            
            if(sObjectType != null && sObjectType != 'Lead'){
                createEmailMesaage(mails);
            }
        }
       
       }
    
    
    Public static void createEmailMesaage(List<Messaging.SingleEmailMessage> lstEmail){
       system.debug('lstEmail:'+lstEmail);
     
        List<EmailMessage> lstEmailMess = new List<EmailMessage>();
        for(Messaging.SingleEmailMessage mess : lstEmail){
            
            EmailMessage emailMess = new EmailMessage();
            system.debug('Enter');
            emailMess.ToAddress = String.join(mess.getToAddresses(), ', '); 
            system.debug('To Address');
            if(mess.getCcAddresses() != null){
               emailMess.CcAddress = String.join(mess.getCcAddresses(), ', ');  
            }
           
            system.debug('CC Address');
           
            emailMess.HtmlBody = mess.getHtmlBody();
            emailMess.Subject = mess.getSubject();
            emailMess.Status = '3';
            if(mess.getWhatId() != null){
            emailMess.RelatedToId = mess.getWhatId(); 
            }
           
            lstEmailMess.add(emailMess);
        }
        
        if(!lstEmailMess.isEmpty() && lstEmailMess != null) {
           Insert lstEmailMess;
        }
        
    }

    public static void notifyUsers(Set<String> recipientsIds, String targetId, string title, string body) {

        // Get the Id for our custom notification type
        // CustomNotificationType notificationType = 
        //     [SELECT Id, DeveloperName 
        //      FROM CustomNotificationType 
        //      WHERE DeveloperName='Loan_Appeal_Notification'];
         STring notificationTypeId = System.Label.notificationTypeId;
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle(title);
        notification.setBody(body);

        // Set the notification type and target
        notification.setNotificationTypeId(notificationTypeId);
        notification.setTargetId(targetId);
        
        // Actually send the notification
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static void sendEmailNew(String oweaAddress, String targetObjId, String title,String body, String whatId ,list<string> reciepientEmailAddressList){
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mailAs = new Messaging.SingleEmailMessage ();
        mailAs.setOrgWideEmailAddressId(oweaAddress);
        mailAs.setTargetObjectId(targetObjId);
        mailAs.setSubject(title);
        mailAs.setHtmlBody(body);
        mailAs.setSaveAsActivity(false);
        mailAs.setWhatId(whatId);
        mailAs.setToAddresses(reciepientEmailAddressList);
        mails.add(mailAs);

        if (!mails.isempty()) {          
            system.debug('Mail Body:'+mails);                        
            Messaging.sendEmail(mails);
            mails.clear();
        }
    }
    
    public class inputVariables {
        @invocableVariable
        public String emailTemplateId;
        @invocableVariable
        public string loanApplicationID;
        @invocableVariable
        public list<String> emailAddress;
        @invocableVariable
        public list<String> ccemailAddress;
        @invocableVariable
        public list<string> userId;
        @invocableVariable
        public string typeOfRecipient;
    }

}