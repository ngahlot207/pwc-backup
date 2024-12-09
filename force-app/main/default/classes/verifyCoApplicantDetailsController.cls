public without sharing class verifyCoApplicantDetailsController {
    
    public static String businessUnit ='Home Loan';
    public static String documentType = 'Physical Consent Proof';
    public static String productType = 'Home Loan';
    
    
    @AuraEnabled(cacheable=true)
    public static LoanAppl__c getLoanApplData(String recordid){
        System.debug('recordid'+recordid);
        List<LoanAppl__c> loanApplList = new List<LoanAppl__c>();
        loanApplList = [SELECT Id,Applicant__r.MobNumber__c, Applicant__r.CustProfile__c, Applicant__r.Constitution__c, Applicant__r.Type_of_Borrower__c, Applicant__r.ApplType__c,Applicant__r.ConsentType__c,Applicant__r.OTP_Verified__c FROM LoanAppl__c WHERE Id=:recordid AND Applicant__r.ApplType__c = 'P'];
        if(loanApplList.size() >0){
            return loanApplList[0];
        }else{
            return null;
        }
    }
    
    
    
    @AuraEnabled(cacheable=true)
    public static LoanAppl__c getLoanApplDatawithChaild(String recordid){
        System.debug('recordid'+recordid);
        List<LoanAppl__c> loanApplListtes = new List<LoanAppl__c>();
        //loanApplListtes = [SELECT Id,(SELECT id,ApplType__c,(SELECT Id,MailAddr__c FROM Applicant_Addresses__r) FROM Applicants__r where ApplType__c = 'P' ) FROM LoanAppl__c WHERE Id=:recordid ];
        if(loanApplListtes.size() >0){
            return loanApplListtes[0];
        }else{
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,Boolean> getAllApplicantsData(String recordid){
        System.debug('recordid'+recordid);
        Map<String, Boolean> mobileNumbersMap = new Map<String, Boolean>();
        List<Applicant__c> applicantsList = new List<Applicant__c>();
        applicantsList = [SELECT Id,MobNumber__c,ApplType__c, OTP_Verified__c, Is_OTP_Limit_Reached__c,LoanAppln__c FROM Applicant__c WHERE LoanAppln__c=:recordid AND MobNumber__c !=null AND ApplType__c IN('P','G','C')];
        if(!applicantsList.isEmpty()){
            for(Applicant__c app: applicantsList){
                if(!mobileNumbersMap.containsKey(app.MobNumber__c)){
                    mobileNumbersMap.put(app.MobNumber__c, app.OTP_Verified__c);
                }
            }
            return mobileNumbersMap;
        }else{
            return null;
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static Applicant__c getCoApplicantData(String recordid){
        system.debug('recordid--'+recordid);
        List<Applicant__c> coApplicantList = new List<Applicant__c>();
        coApplicantList = [SELECT Id,DigitalVerified__c,ProfQual__c,EmailIDverificationStatus__c,CustProfile__c, Constitution__c, Type_of_Borrower__c, ApplType__c, MobNumber__c, OTP_Verified__c, Is_OTP_Limit_Reached__c, FNAME__c, LNAME__c, MNAME__c,KeyManName__c,CompanyName__c, LoanAppln__c, Is_Physical_Consent_Validated__c,Comments__c,RationaleUsingPhyConsent__c,ConsentType__c  FROM Applicant__c WHERE Id=:recordid];

        if(coApplicantList.size() >0){
            system.debug('coApplicantList--'+coApplicantList[0]);
            
            return coApplicantList[0];
        }else{
            return null;
        }     
    }
    
    @AuraEnabled(cacheable=true)
    public static Applicant__c getCoApplicantMobData(String mobNumber, String recordid, String loanAppId){
        List<Applicant__c> coApplicantList = new List<Applicant__c>();
        system.debug('mobNumber------->'+mobNumber);
        coApplicantList = [SELECT Id, MobNumber__c, OTP_Verified__c, Is_OTP_Limit_Reached__c, FNAME__c, LNAME__c FROM Applicant__c WHERE MobNumber__c !=null AND MobNumber__c=:mobNumber  AND ApplType__c IN('G','C') AND OTP_Verified__c = true AND Id !=:recordid AND LoanAppln__c =:loanAppId];
        if(coApplicantList.size() >0){
            return coApplicantList[0];
        }else{
            return null;
        }     
    }
    
    @AuraEnabled
    public static Applicant__c upsertCoApplicantRecord(Applicant__c recordData){
        Applicant__c appL = new Applicant__c();
        appL.Id = recordData.Id !=null ? recordData.Id : null;
        if(recordData.MobNumber__c!=null){
            appL.MobNumber__c = recordData.MobNumber__c;
        }
        if(recordData.ApplType__c!=null){
            appL.ApplType__c = recordData.ApplType__c;
        }
        if(recordData.Constitution__c!=null){
            appL.Constitution__c = recordData.Constitution__c;
        }
        if(recordData.CustProfile__c!=null){
            appL.CustProfile__c = recordData.CustProfile__c;
        }
        if(recordData.Type_of_Borrower__c!=null){
            appL.Type_of_Borrower__c = recordData.Type_of_Borrower__c;
        }
        if(recordData.OTP_Verified__c!=null){
            appL.OTP_Verified__c = recordData.OTP_Verified__c;
        }
        if(recordData.ConsentType__c!=null){
            appL.ConsentType__c = recordData.ConsentType__c;       
        }
        if(recordData.LoanAppln__c!=null){
            appL.LoanAppln__c = recordData.LoanAppln__c;       
        }
        if(recordData.LoanAppln__c!=null){
            appL.LoanAppln__c = recordData.LoanAppln__c;       
        }
        appL.FNAME__c = recordData.FNAME__c;       
        appL.LNAME__c = recordData.LNAME__c;       
        appL.MName__c = recordData.MName__c;     
        appL.KeyManName__c = recordData.KeyManName__c;   
        appL.CompanyName__c = recordData.CompanyName__c;   
        system.debug('upsertCoApplicantRecord APPL--->'+appL);
        if(appL!=null){
            upsert appL;
        }
        return appL;
    }
    

    @AuraEnabled
    public static void uploadFile(String documentDetailId, String filename, String loanAppId, String applicantId) { 

        try{
            if(String.isNotBlank(documentDetailId)){            
            Applicant__c appL = new Applicant__c(Id=applicantId, ConsentType__c ='Physical Consent Upload', Is_Physical_Consent_Validated__c = true);
            upsert appL;
            }
        }
        catch(Exception exp){
            throw new AuraHandledException('Error on apex while uploading doc ' + exp.getMessage()); 
        }
        
    }
    
    @AuraEnabled
    public static String fetchOrCreateDocumentMaster(String masterId, String childId){ //loan & Appl
         try{
            List<DocMstr__c> docMasterList = new List<DocMstr__c>();
            String documentDetailId ='';
            docMasterList = [Select Id, Bu__c, DocType__c, Prod__c from DocMstr__c 
                            where Bu__c=:businessUnit AND DocType__c=:documentType AND Prod__c=:productType LIMIT 1];
            
            if(!docMasterList.isEmpty()){
                documentDetailId = createDocumentDetail(docMasterList[0].Id, masterId, childId);
            }else{
                DocMstr__c docMaster = new DocMstr__c();
                docMaster.OSVReq__c = false;
                docMaster.Catgry__c    = 'Other Documents';
                docMaster.DocSubTyp__c = 'Physical Consent';
                docMaster.Bu__c = 'Home Loan';
                docMaster.DocType__c = 'Physical Consent Proof';
                // docMaster.Prod__c ='Home Loan';
                docMasterList.add(docMaster);
                insert docMasterList;
                documentDetailId = createDocumentDetail(docMasterList[0].Id, masterId, childId);
            }
            return documentDetailId;
         }
          catch(Exception exp){
            throw new AuraHandledException('Error on apex while uploading doc ' + exp.getMessage()); 
        }

    }
    
    @AuraEnabled
    public static String createDocumentDetail(String docMaster, String loanAppId, String applicantId) {
        String documentDetailRecordId = '';
        DocDtl__c documentDetail = new DocDtl__c();
        documentDetail.Appl__c = applicantId; 
        documentDetail.DocCatgry__c = 'Verification Documents';
        documentDetail.DocSubTyp__c = 'Physical Consent Form';
        documentDetail.DocTyp__c = 'Physical Consent Proof';
        documentDetail.DocMstr__c = docMaster; 
        documentDetail.LAN__c = loanAppId; 
        
        try {
            insert documentDetail;
            documentDetailRecordId = documentDetail.Id;
        } catch(DmlException e) {
        }  
        
        return documentDetailRecordId;
        
    }
    @testVisible
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    @testVisible
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getRelatedFilesByRecordId(String loanAppId, String applicantId) {
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        Map<Id, DocDtl__c> docDetailMap = new Map<Id, DocDtl__c>([SELECT Id, DocCatgry__c, DocSubTyp__c,DocTyp__c  
                                                                  FROM DocDtl__c WHERE Appl__c  =:applicantId AND Lan__c =:loanAppId 
                                                                  AND (DocTyp__c ='Physical Consent Proof' OR DocSubTyp__c = 'Physical Consent Form')]);
        
        if (!docDetailMap.keySet().isEmpty()) {
            List<ID> fileIDs = new List<ID>();
            
            for (ContentDocumentLink docLink : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :docDetailMap.keySet()]) {
                fileIDs.add(docLink.ContentDocumentId);
            }
            
            for (ContentVersion docLink : [SELECT Id,ContentDocumentId, FileExtension, Title, ContentSize FROM ContentVersion WHERE ContentDocumentId IN :fileIDs ORDER BY CreatedDate DESC]) {
                contentVersionList.add(docLink);
            }
        }
        return contentVersionList;
    }
    
    @AuraEnabled
    public static DocDtl__c getDocDetailId(String loanAppId, String applicantId,string contentDocId) {
        List<String> cids = contentDocId.split(',');
        List<DocDtl__c> DocDetailList = [SELECT Id, DocCatgry__c, DocSubTyp__c,DocTyp__c  
        FROM DocDtl__c WHERE Appl__c  =:applicantId AND Lan__c =:loanAppId 
        AND (DocTyp__c ='Physical Consent Proof' OR DocSubTyp__c = 'Physical Consent Form') AND Content_Document_Id__c IN: cids];
        if(!DocDetailList.isEmpty()){
            return DocDetailList[0];
        }
        return null;
    }
    
    @AuraEnabled
    public static String deleteFileRecord(String deleteRecordId){
        List<DocDtl__c> docDetailList; 
        if(String.isNotBlank(deleteRecordId)){
            List<ContentVersion> cvs= [SELECT Id,ContentDocumentId  FROM ContentVersion WHERE ContentDocumentId =:deleteRecordId];
            system.debug('cvs--'+cvs);
        if(!cvs.isEmpty()){
            docDetailList= [SELECT Id FROM DocDtl__c where Content_Document_Id__c =:cvs[0].Id];
        }
        if(!docDetailList.isEmpty()){
                for(DocDtl__c dd:docDetailList){
                    delete dd;
                }
        }
        ContentDocument cd = new ContentDocument(Id=deleteRecordId);
        delete cd;
        system.debug('Content doc--'+cd);
            return'SUCCESS';
        }else{
            return'FAILURE';
        }
    }
        
    @AuraEnabled
    public static Applicant__c updateMaxLimitReached(Applicant__c coAppRecord) {
        coAppRecord.Id = coAppRecord.Id;
        coAppRecord.Is_OTP_Limit_Reached__c = true;
        update coAppRecord;
        return coAppRecord;
    }
    
    @AuraEnabled
    public static List<String> generateOTP(String recordId,string mobileNumber) {
        List<String> otp = new List<String>();
        List<String> taskIds = new List<String>();
        otp = GlobalUtility.getOTP();
        if(!otp.isEmpty()){
            List<SMS_Template_Details__mdt> smsTemplate = [select SMS_Template__c from SMS_Template_Details__mdt where Developername='Lead_OTP_Template'];
            string formattedText = smsTemplate[0].SMS_Template__c;
            string finalMsg = formattedText.replace('<<__OTP___>>',otp[0]);
            if(!smsTemplate.isEmpty()){
                Task taskRec = new Task();
                taskRec.MobNum__c = mobileNumber;
                taskRec.Type = 'SMS Task';
                taskRec.Subject = 'SMS Task';
                //taskRec.whoId = recordId !=null ? recordId:''; 
                taskRec.Description = finalMsg;
                taskRec.OTP__c = otp[0];
                taskRec.Status = 'Completed';
                insert taskRec;
                taskIds.add(taskRec.Id);
            }
            return taskIds;
        }
        return taskIds;
    }
    
    @AuraEnabled
    public static Applicant__c upsertRecord(Applicant__c recordData){
        if(recordData!=null){
            upsert recordData;
        }
        return recordData;
    }
    @AuraEnabled
    public static List<String> generateLink(String AppliId,string mobileNumber) {
        //system.debug()
        List<String> taskIds = new List<String>();
    
    
        List<SMS_Template_Details__mdt> smsTemplate = [SELECT SMS_Template__c FROM SMS_Template_Details__mdt WHERE Developername = 'Applicant_Digital_Template'];
        RecordType smsRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Task' AND Name = 'SMS' LIMIT 1];
        if (!smsTemplate.isEmpty()) {
            String formattedText = smsTemplate[0].SMS_Template__c;
            
            // Create a new Task record
            Task taskRec = new Task();
            taskRec.RecordTypeId = smsRecordType.Id;
            taskRec.MobNum__c = mobileNumber;
            taskRec.Type = 'SMS Task';
            taskRec.Subject = 'SMS Task';
            taskRec.WhatId = AppliId != null ? AppliId : '';
            //taskRec.WhoId = AppliId != null ? AppliId : '';
            taskRec.Status = 'Completed';

            
            // Insert the task record to generate a Task ID
            insert taskRec;
            taskIds.add(taskRec.Id);
            Site mySite = [select Id from Site where Name = 'LOSExternal'];
            SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite.Id];
            System.debug(mySiteDetail.SecureURL);
            String url = mySiteDetail.SecureURL +'/s/digital-consent?taskId=' + taskRec.Id;
            //String url = 'https://fedbank--dev.sandbox.my.site.com/LOSExternal/s/digital-consent?taskId=' + taskRec.Id;
            
            // Replace placeholder in the SMS template with the URL
            //String finalMsg = formattedText.replace('<<__OTP___>>', url);
            String finalMsg = formattedText.replace('<<____Bitly link_______>>', url);
            
            // Update the task record with the final message
            taskRec.Description = finalMsg;
            update taskRec;
            IntgMsg__c intmsg=new IntgMsg__c();
            intmsg.Name='SMS';
            intmsg.BU__c='HL / STL';
            intmsg.Status__c='New';
            intmsg.MStatus__c='Blank';
            intmsg.Svc__c='SMS';
            intmsg.IsActive__c=true;
            intmsg.RefId__c=taskRec.Id;
            intmsg.RefObj__c='Task';
            insert intmsg;
            
            // Log or return the task IDs as needed
            System.debug('Task IDs: ' + taskIds);
            return taskIds;
        }
    
    
    return taskIds;


    }
    @AuraEnabled
    public static Id getApplicantIdByTask(string taskId) {
        system.debug('taskId'+taskId);
        Task task = [SELECT whoId,WhatId FROM Task WHERE Id = :taskId LIMIT 1];
        return task.WhatId;
    }
    @AuraEnabled
    public static Applicant__c checkDigitalVerified(String AppliId) {
        if (AppliId == null) {
            throw new AuraHandledException('AppliId ID cannot be null.');
        }
        return [SELECT Id, DigitalVerified__c FROM Applicant__c WHERE Id = :AppliId LIMIT 1];
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
    public static boolean getLeadById(String leadId) {
        System.debug('Fetching Lead with ID: ' + leadId);
        Lead lead = [SELECT Id, Digital_Verified__c FROM Lead WHERE Id = :leadId LIMIT 1];
        System.debug('lead digital verified: ' + lead.Digital_Verified__c);
        return lead.Digital_Verified__c;
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
                
            }else{
                returnMsg = 'failure';
            }
        }
        return returnMsg;
    }

    @AuraEnabled
    public static boolean updateDigitalOtpConsent(string recordId) {
        system.debug('recordInput'+recordId);
        Id recordId1=recordId;
        boolean recordUpdate=false;
        Schema.SObjectType sobjectType = recordId1.getSObjectType();
		String sobjectName = sobjectType.getDescribe().getName();
        if(sObjectName=='Lead'){
            lead leRec=new lead(Id=recordId1, Digital_Verified__c=true, Digital_Consent_Date_Time__c=system.now(), ConsentType__c='Digital Consent');
            update leRec;
            recordUpdate=true;
        }else if(sObjectName=='Applicant__c'){
            Applicant__c appRec=new Applicant__c(Id=recordId1, DigitalVerified__c=true, ConsentType__c='Digital Consent');
        	update appRec;
            recordUpdate=true;
        }
        return recordUpdate;
    }

    @AuraEnabled
    public static boolean updateApplicantDigitalVerified(string applicantId) {
        system.debug('recordInput'+applicantId);
        boolean recordUpdate=false;
        Applicant__c appRec=new Applicant__c(Id=applicantId, DigitalVerified__c=true, ConsentType__c='Digital Consent');
        update appRec;
        recordUpdate=true;
        
        return recordUpdate;
    }


    @AuraEnabled
    public static Lead checkDigitalVerifiedLead(String leadId) {
        if (leadId == null) {
            throw new AuraHandledException('Lead ID cannot be null.');
        }
        return [SELECT Id, Digital_Verified__c FROM Lead WHERE Id = :leadId LIMIT 1];
    }

    @AuraEnabled
    public static boolean updateLeadDigitalVerified(string leadId) {
        
        
        boolean recordUpdate=false;
        
            lead leRec=new lead(Id=leadId, Digital_Verified__c=false, Digital_Consent_Date_Time__c=null, ConsentType__c='');
            update leRec;
            recordUpdate=true;
        
        return recordUpdate;
    }

   
}