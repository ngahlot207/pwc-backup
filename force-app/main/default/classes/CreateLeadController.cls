public with sharing class CreateLeadController {
    @AuraEnabled
    public static List<String> generateOTP(String leadId,string mobileNumber) {
        List<String> otp = new List<String>();
        List<String> taskIds = new List<String>();
        otp = GlobalUtility.getOTP();//callutility classmetod ();
        if(!otp.isEmpty()){
            List<SMS_Template_Details__mdt> smsTemplate = [select SMS_Template__c from SMS_Template_Details__mdt where Developername='Lead_OTP_Template'];
            string formattedText = smsTemplate[0].SMS_Template__c;
            string finalMsg = formattedText.replace('<<__OTP___>>',otp[0]);
            if(!smsTemplate.isEmpty()){
                Task taskRec = new Task();
                taskRec.MobNum__c = mobileNumber;
                taskRec.Type = 'SMS Task';
                taskRec.Subject = 'SMS Task';
                taskRec.whoId = leadId !=null ? leadId:'';
                taskRec.Description = finalMsg;
                taskRec.OTP__c = otp[0];
                taskRec.Status = 'Completed';
                insert taskRec;
                taskIds.add(taskRec.Id);
            }
            
            system.debug(otp+'ooooooooooooooooooooooooooo');
           // return otp;
            return taskIds;
        }
        return taskIds;
    }
    
    
    @AuraEnabled
    public static List<String> generateLink(String leadId,string mobileNumber) {
        List<String> otp = new List<String>();
        List<String> taskIds = new List<String>();
        otp = GlobalUtility.getOTP();//callutility classmetod ();
        if(!otp.isEmpty()){
        List<SMS_Template_Details__mdt> smsTemplate = [SELECT SMS_Template__c FROM SMS_Template_Details__mdt WHERE Developername = 'Lead_Digital_Template'];
        
        if (!smsTemplate.isEmpty()) {
            String formattedText = smsTemplate[0].SMS_Template__c;
            
            // Create a new Task record
            Task taskRec = new Task();
            taskRec.MobNum__c = mobileNumber;
            taskRec.Type = 'SMS Task';
            taskRec.Subject = 'SMS Task';
            taskRec.whoId = leadId != null ? leadId : '';
            taskRec.OTP__c = otp[0];
            taskRec.Status = 'Completed';
            
            // Insert the task record to generate a Task ID
            insert taskRec;
            taskIds.add(taskRec.Id);

            /////

            Site mySite = [select Id from Site where Name = 'LOSExternal'];
            SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite.Id];
            System.debug(mySiteDetail.SecureURL);
            String url = mySiteDetail.SecureURL +'/s/digital-consent?taskId=' + taskRec.Id;

            
            String finalMsg = formattedText.replace('<<____Bitly link_______>>', url)
                                            .replace('<<__OTP___>>',otp[0]);
            
            // Update the task record with the final message
            taskRec.Description = finalMsg;
            update taskRec;
        }
            // Log or return the task IDs as needed
            System.debug('Task IDs: ' + taskIds);
            return taskIds;
        
        }
    
    return taskIds;


    }

    @AuraEnabled
    public static Id getLeadIdByTask(Id taskId) {
        Task task = [SELECT whoId, WhatId FROM Task WHERE Id = :taskId LIMIT 1];
        return task.whoId;
    }

    @AuraEnabled
    public static String getProductByLead(String leadId) {
        Lead lead = [SELECT Id, Product__c FROM Lead WHERE Id = :leadId LIMIT 1];
        return lead.Product__c;
    }
    
    
    @AuraEnabled
    public static Lead updateLead(Lead leadData) {
        system.debug('leadData--'+leadData);
        system.debug('Disposition_Status__c--'+leadData.Disposition_Status__c);
        system.debug('Updated Mobile number ---'+leadData.MobilePhone);
        if(leadData.Disposition_Status__c!=null && leadData.Disposition_Status__c!=''){
            if(leadData.Disposition_Status__c == 'Customer not contactable' || leadData.Disposition_Status__c == 'Call back requested' || leadData.Disposition_Status__c == 'Details or documents awaited'){
                leadData.Status = 'In Progress';
            }else if(leadData.Disposition_Status__c =='Lead converted'){
                leadData.Status = 'Converted';
            }else if(leadData.Disposition_Status__c =='Lead closed'){
                leadData.Status = 'Closed';
            }else{
                leadData.Status = 'New';
            }
            try{
                leadData.Id = leadData.Id;
                //leadData.MobilePhone = leadData.MobilePhone;
                update leadData;
                system.debug('updated leadData--'+leadData+' leadData otp-- '+leadData.OTP_Verified__c);
            }catch(Exception e){
                System.debug('Error: Update Lead---'+e.getStackTraceString()+e.getMessage());
            }
        }
        return leadData;
    }
    
    @AuraEnabled
    public static Lead updateMaxLimitReached(Lead leadData) {
        system.debug('leadData -updateMaxLimitReached-'+leadData);
        leadData.Id = leadData.Id;
        leadData.Is_OTP_Limit_Reached__c = true;
        update leadData;
        return leadData;
    }
    
    @AuraEnabled
    public static Lead getLeadData(String recordId) {
        system.debug('recordId in getLeadData outside ---'+recordId);
        Lead lead;
        if(recordId!='' && recordId!= null){
            lead = [select id,MobilePhone,OTP_Verified__c,Is_OTP_Limit_Reached__c from lead where id=:recordId];
        }
        system.debug('lead in getLeadData ---'+lead);
        return lead;
    }
    
    @AuraEnabled
    public static boolean isMobileNumberVerified(string mobileNUmber, String leadId) {
        system.debug('leadId--'+leadId);
        boolean otpVerified= false;
        list<Lead> leadsList = [select MobilePhone,OTP_Verified__c from lead where id=:leadId];
        system.debug('leadsList--->'+leadsList);
        if(!leadsList.isEmpty() && mobileNUmber == leadsList[0].MobilePhone){ 
            otpVerified = leadsList[0].OTP_Verified__c;
        }
        return otpVerified;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getUploadedFiles(Id recordId) {
        system.debug('lead recordId in getUploadedFiles'+recordId);
        List<ContentDocument> ContentDocumentIds = [SELECT Id, Title, FileType,
                                                    ParentId,ContentSize,ContentAssetId, FileExtension,LatestPublishedVersionId  
                                                    FROM ContentDocument where LatestPublishedVersionId in 
                                                    (select id from ContentVersion where FirstPublishLocationId =: recordId ) 
                                                    order by createddate desc];
        system.debug('ContentDocumentIds---'+ContentDocumentIds);
        return ContentDocumentIds;
    }
    
   @AuraEnabled
    public static List<ContentDocument> getUploadedFilesUpdated(Id recordId) {
        system.debug('lead recordId in getUploadedFiles'+recordId);
        List<ContentDocument> ContentDocumentIds = [SELECT Id, Title, FileType,LatestPublishedVersion.Document_Category__c, LatestPublishedVersion.Document_Type__c, LatestPublishedVersion.Document_Name__c,
                                                    ParentId,ContentSize,ContentAssetId, FileExtension,LatestPublishedVersionId  
                                                    FROM ContentDocument where LatestPublishedVersionId in 
                                                    (select id from ContentVersion where FirstPublishLocationId =: recordId ) and LatestPublishedVersion.Document_Category__c=Null AND  LatestPublishedVersion.Document_Type__c=Null and LatestPublishedVersion.Document_Name__c=Null
                                                    order by createddate desc];
        system.debug('ContentDocumentIds---'+ContentDocumentIds);
        return ContentDocumentIds;
    }
    
    @AuraEnabled
    public static List<ContentVersion> getUploadedFilesByContentVersion(Id recordId) {
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        cvList = [select id, ContentDocumentId, ContentDocument.Title, ContentDocument.ContentSize, Document_Category__c, Document_Name__c, 
                  ContentDocument.FileType, FORMAT(ContentDocument.CreatedDate), Document_Type__c from ContentVersion where FirstPublishLocationId =: recordId and Document_Category__c!=Null and Document_Name__c!=Null and  Document_Type__c!=Null
                  ORDER BY CreatedDate DESC];
        return cvList;
    }
    @AuraEnabled
    public static Lead getLeadPhyData(String recordId) {
        system.debug('recordId in getLeadData outside ---'+recordId);
        Lead lead;
        if(recordId!='' && recordId!= null){
            lead = [select id,RationaleUsingPhyConsent__c,Comments__c from lead where id=:recordId];
        }
        system.debug('lead in getLeadData ---'+lead);
        return lead;
    }

    
    @AuraEnabled
    public static Lead checkDigitalVerified(String leadId) {
        if (leadId == null) {
            throw new AuraHandledException('Lead ID cannot be null.');
        }
        return [SELECT Id, Digital_Verified__c FROM Lead WHERE Id = :leadId LIMIT 1];
    }




     @AuraEnabled
     public static String validateOtp(String taskId,String otp) {
        String returnMsg = 'failure';
        List<Task> taskRecrds  = new List<Task>(); 
        List<Lead> leadRecords = new List<Lead>();
        if(taskId != null ){
             taskRecrds = [SELECT Id,OTP__c,WhoId,MobNum__c FROM Task WHERE Id=:taskId LIMIT 1];
            
        }
        if(!taskRecrds.isEmpty()){
            
            if(taskRecrds[0].OTP__c == otp){
                returnMsg = 'success';
                if(taskRecrds[0].WhoId != NULL){
                    Lead leadRec = new Lead();
                    leadRec.Id = taskRecrds[0].WhoId;
                    leadRec.MobilePhone = taskRecrds[0].MobNum__c;
                    leadRec.ConsentType__c = 'OTP Consent';
                    leadRec.OTP_Verified__c = true;

                    update leadRec;
                }
            }else{
                returnMsg = 'failure';
            }
        }
        return returnMsg;
    }
}