public with sharing class FinancialFileUploadClass {
    public FinancialFileUploadClass() {
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ApplGST__c> getGSTINValue(String applicantId) {
        List<ApplGST__c> gstRec = new List<ApplGST__c>();
        gstRec = [select Id, GSTIN__c, GSTIN_Status__c, Applicant__c from ApplGST__c where Applicant__c=:applicantId];
        return gstRec;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getRecordTypeValue(String RecName) {
        Id recordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByName().get(RecName).getRecordTypeId();
        return String.valueOf(recordTypeId);
    }
    
    @AuraEnabled(cacheable=true)
    public static  List<DocumentWrapper> getRelatedFilesByRecordIdWire(String loanAppId, String applicantId, Boolean isITRTab, String docDetIdITR) {
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        List<DocumentWrapper> wrapper = new List<DocumentWrapper>();
        List<DocDtl__c> appDocDetailList = new List<DocDtl__c>();
        
        Set<String> docTypeSet = new Set<String>();
        Schema.DescribeFieldResult fieldResult;
        
        if(!isITRTab){
            fieldResult = ApplGST__c.Income_Documents__c.getDescribe();
        }else{
            fieldResult = Applicant_Financial__c.Income_Documents__c.getDescribe();
        }
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            docTypeSet.add(pickListVal.getLabel());
        }
        
        if(!docTypeSet.isEmpty()){
            if(!isITRTab){
                appDocDetailList = [SELECT Id, DocCatgry__c, DocSubTyp__c,DocTyp__c, File_Type__c, IsLatest__c, CreatedDate,FileAvalbl__c
                                    FROM DocDtl__c WHERE Appl__c  =:applicantId AND Lan__c =:loanAppId 
                                    AND DocCatgry__c ='Income Documents' AND IsLatest__c=true 
                                    AND DocTyp__c IN ('Financials - P&L and BL', 'GST Returns') 
                                    AND DocSubTyp__c IN :docTypeSet];
            }else{
                Applicant__c applicant = [Select Id, CustProfile__c from Applicant__c where Id=:applicantId];
                if(applicant.CustProfile__c !=null && applicant.CustProfile__c !='SALARIED'){
                    appDocDetailList = [SELECT Id, DocCatgry__c, DocSubTyp__c,DocTyp__c, File_Type__c, IsLatest__c, CreatedDate ,FileAvalbl__c
                                        FROM DocDtl__c WHERE Appl__c  =:applicantId AND Lan__c =:loanAppId 
                                        AND DocCatgry__c ='Income Documents' AND IsLatest__c=true 
                                        AND DocTyp__c IN ('Income Documents', 'Income Tax Returns') 
                                        AND DocSubTyp__c IN :docTypeSet];
                }else if(applicant.CustProfile__c !=null && applicant.CustProfile__c =='SALARIED'){
                    appDocDetailList = [SELECT Id, DocCatgry__c, DocSubTyp__c,DocTyp__c, File_Type__c, IsLatest__c, CreatedDate,FileAvalbl__c
                                        FROM DocDtl__c WHERE Appl__c  =:applicantId AND Lan__c =:loanAppId 
                                        AND DocCatgry__c ='Income Documents' AND IsLatest__c=true 
                                        AND DocTyp__c IN ('Income Documents','Income Tax Returns') 
                                        AND DocSubTyp__c IN :docTypeSet];
                }
                
            }
            
            Set<Id> docDetailIdSet = new Set<id>();
            
            for (DocDtl__c dd : appDocDetailList) {
                docDetailIdSet.add(dd.Id);
            }
            
            List<ContentDocumentLink> dduploaded = new List<ContentDocumentLink>();
            if (docDetailIdSet != null && !docDetailIdSet.isEmpty()) {
                dduploaded = [SELECT Id,LinkedEntityId,ContentDocumentId,ContentDocument.CreatedDate, 
                              ContentDocument.Title,ContentDocument.ContentSize,ContentDocument.FileType 
                              FROM ContentDocumentLink WHERE LinkedEntityId IN :docDetailIdSet WITH SECURITY_ENFORCED];
            }
            
            Map<String, ContentDocumentLink> contentDocLinkMap = new Map<String, ContentDocumentLink>();
            
            for (ContentDocumentLink cdLink : dduploaded) {
                contentDocLinkMap.put(cdLink.LinkedEntityId, cdLink);
            }
            
            Set<Id> contentDocumentIdSet = new Set<Id>();
            for (ContentDocumentLink cdl : dduploaded) {
                contentDocumentIdSet.add(cdl.ContentDocumentId);
            }
            
            contentVersionList = [SELECT Id, VersionData, FileType, Title, FileExtension, 
                                  ContentDocument.CreatedBy.Name, ContentDocument.ContentSize, CreatedDate, 
                                  ContentDocumentId, ContentDocument.FileType FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIdSet
                                 ];
            
            Map<Id, Id> contentdocToVesionMap = new Map<Id, Id>();
            for (ContentVersion cv : contentVersionList) {
                contentdocToVesionMap.put(cv.ContentDocumentId, cv.Id);
            }
            
            for (DocDtl__c dd : appDocDetailList){
                ContentDocumentLink cdl = contentDocLinkMap.get(dd.id);
                if (cdl != null) {
                    DocumentWrapper wrpr = new DocumentWrapper();
                    datetime dateis = dd.CreatedDate;
                    wrpr.cDcrtdDate = dateis.format('dd-MM-yyyy  hh:mm a');
                    wrpr.LinkedEntityId = cdl.LinkedEntityId;
                    wrpr.fileExtension = cdl.ContentDocument.FileType;
                    wrpr.cDId = cdl.ContentDocumentId;
                    wrpr.cdlId = cdl.Id;
                    wrpr.cvId = contentdocToVesionMap.get(cdl.ContentDocumentId);
                    wrpr.docId = cdl.LinkedEntityId;
                    wrpr.fileType = dd.DocTyp__c;
                    wrpr.incomeDocumentType = dd.DocSubTyp__c;
                    wrpr.FileAvalbl=dd.FileAvalbl__c;
                    wrapper.add(wrpr); 
                }else{
                    DocumentWrapper wrpr = new DocumentWrapper();
                    datetime dateis = dd.CreatedDate;
                    wrpr.cDcrtdDate = dateis.format('dd-MM-yyyy  hh:mm a');
                    wrpr.LinkedEntityId = null;
                    wrpr.fileExtension = null;
                    wrpr.cDId = null;
                    wrpr.cdlId = null;
                    wrpr.cvId = null;
                    wrpr.docId = dd.Id;
                    wrpr.fileType = dd.DocTyp__c;
                    wrpr.incomeDocumentType = dd.DocSubTyp__c;
                    wrpr.FileAvalbl=dd.FileAvalbl__c;
                    wrapper.add(wrpr); 
                }
                
            }
        }
        return wrapper;
    }

    ///LAK-8843
    @AuraEnabled
    public static List<DocDtl__c> getFinancialDocumentDetails(String loanAppId, String applicantId){

        List<DocDtl__c> docFileList = new List<DocDtl__c>();
        List<DocDtl__c> docList = [SELECT Id, DocCatgry__c, DocSubTyp__c, DocTyp__c, File_Type__c, IsLatest__c, CreatedDate, FileAvalbl__c
                                    FROM DocDtl__c 
                                    WHERE Appl__c = :applicantId 
                                    AND Lan__c = :loanAppId 
                                    AND DocCatgry__c = 'Income Documents' 
                                    AND IsLatest__c = true 
                                    AND (DocSubTyp__c = 'Latest year Financials - P&L and BS' OR DocSubTyp__c = 'Provisional Financials - P&L and BS' OR DocSubTyp__c = 'Previous year Financials - P&L and BS')
                                    AND DocTyp__c IN ('Financials - P&L and BL')];
        
        // Use addAll method to add all records from docList to docFileList
        docFileList.addAll(docList);
        
        return docFileList;
        
    }
    
    
    
    
    @AuraEnabled(cacheable=true)
    public static  List<DocumentWrapper> getRelatedFilesFinancialByRecordIdWire(String loanAppId, String applicantId, String docDetailId) {
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        
        List<DocumentWrapper> wrapper = new List<DocumentWrapper>();
        
        List<DocDtl__c> appDocDetailList = new List<DocDtl__c>();
        appDocDetailList = [SELECT Id, DocCatgry__c, DocSubTyp__c,DocTyp__c, File_Type__c, IsLatest__c, CreatedDate ,FileAvalbl__c
                            FROM DocDtl__c WHERE Appl__c  =:applicantId AND Lan__c =:loanAppId 
                            AND DocCatgry__c ='Income Documents' AND IsLatest__c=true AND 
                            DocTyp__c = 'Financials - P&L and BL' 
                            AND DocSubTyp__c IN ('Latest year Financials - P&L and BS','Previous year Financials - P&L and BS','Provisional Financials - P&L and BS')];
        
        Set<Id> docDetailIdSet = new Set<id>();
        
        for (DocDtl__c dd : appDocDetailList) {
            docDetailIdSet.add(dd.Id);
        }
        
        List<ContentDocumentLink> dduploaded = new List<ContentDocumentLink>();
        if (docDetailIdSet != null && !docDetailIdSet.isEmpty()) {
            dduploaded = [SELECT Id,LinkedEntityId,ContentDocumentId,ContentDocument.CreatedDate, 
                          ContentDocument.Title,ContentDocument.ContentSize,ContentDocument.FileType 
                          FROM ContentDocumentLink WHERE LinkedEntityId IN :docDetailIdSet WITH SECURITY_ENFORCED
                         ];
        }
        
        Map<String, ContentDocumentLink> contentDocLinkMap = new Map<String, ContentDocumentLink>();
        
        for (ContentDocumentLink cdLink : dduploaded) {
            contentDocLinkMap.put(cdLink.LinkedEntityId, cdLink);
        }
        
        Set<Id> contentDocumentIdSet = new Set<Id>();
        for (ContentDocumentLink cdl : dduploaded) {
            contentDocumentIdSet.add(cdl.ContentDocumentId);
        }
        
        contentVersionList = [SELECT Id, VersionData, FileType, Title, FileExtension, 
                              ContentDocument.CreatedBy.Name, ContentDocument.ContentSize, CreatedDate, 
                              ContentDocumentId, ContentDocument.FileType FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIdSet
                             ];
        
        Map<Id, Id> contentdocToVesionMap = new Map<Id, Id>();
        for (ContentVersion cv : contentVersionList) {
            contentdocToVesionMap.put(cv.ContentDocumentId, cv.Id);
        }
        
        for (DocDtl__c dd : appDocDetailList){
            ContentDocumentLink cdl = contentDocLinkMap.get(dd.id);
            if (cdl != null) {
                DocumentWrapper wrpr = new DocumentWrapper();
                datetime dateis = dd.CreatedDate;
                wrpr.cDcrtdDate = dateis.format('dd-MM-yyyy  hh:mm a');
                wrpr.LinkedEntityId = cdl.LinkedEntityId;
                wrpr.fileExtension = cdl.ContentDocument.FileType;
                wrpr.cDId = cdl.ContentDocumentId;
                wrpr.cdlId = cdl.Id;
                wrpr.cvId = contentdocToVesionMap.get(cdl.ContentDocumentId);
                wrpr.docId = cdl.LinkedEntityId;
                wrpr.fileType = dd.File_Type__c;
                wrpr.incomeDocumentType = dd.DocSubTyp__c;
                wrpr.FileAvalbl=dd.FileAvalbl__c;
                wrapper.add(wrpr); 
            }else{
                DocumentWrapper wrpr = new DocumentWrapper();
                datetime dateis = dd.CreatedDate;
                wrpr.cDcrtdDate = dateis.format('dd-MM-yyyy  hh:mm a');
                wrpr.LinkedEntityId = null;
                wrpr.fileExtension = null;
                wrpr.cDId = null;
                wrpr.cdlId = null;
                wrpr.cvId = null;
                wrpr.docId = dd.Id;
                wrpr.fileType = dd.File_Type__c;
                wrpr.incomeDocumentType = dd.DocSubTyp__c;
                wrpr.FileAvalbl=dd.FileAvalbl__c;
                wrapper.add(wrpr); 
            }
            
        }
        return wrapper;
    }
    
    
    
    @AuraEnabled
    public static List<DocumentWrapper> getRelatedFilesByRecordId(String loanAppId, String applicantId, Boolean isITRTab) {
        Map<String, String> contentVersionMap = new Map<String, String>();
        
        Set<String> docTypeSet = new Set<String>();
        Schema.DescribeFieldResult fieldResult;
        if(!isITRTab){
            fieldResult = ApplGST__c.Income_Documents__c.getDescribe();
        }else{
            fieldResult = Applicant_Financial__c.Income_Documents__c.getDescribe();
        }
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            docTypeSet.add(pickListVal.getLabel());
        }
        
        List<DocumentWrapper> wrapper = new List<DocumentWrapper>();
        
        if(!docTypeSet.isEmpty()){
            Map<Id, DocDtl__c> docDetailMap = new Map<Id, DocDtl__c>([SELECT Id, DocCatgry__c, DocSubTyp__c,DocTyp__c, File_Type__c  
                                                                      FROM DocDtl__c WHERE Appl__c  =:applicantId AND Lan__c =:loanAppId 
                                                                      AND DocCatgry__c ='Income Documents' AND 
                                                                      (DocTyp__c IN:docTypeSet OR DocSubTyp__c IN: docTypeSet)]);
            if (!docDetailMap.keySet().isEmpty()) {
                List<ID> fileIDs = new List<ID>();
                
                
                for (ContentDocumentLink docLink : [SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :docDetailMap.keySet()]) {
                    fileIDs.add(docLink.ContentDocumentId);
                }
                
                for (ContentVersion cv : [SELECT Id, ContentDocumentId, FileExtension, Title, ContentSize FROM ContentVersion WHERE ContentDocumentId IN :fileIDs ORDER BY CreatedDate DESC]) {   
                    if(!contentVersionMap.containsKey(cv.ContentDocumentId)){
                        contentVersionMap.put(cv.ContentDocumentId, cv.Id);
                    }
                }
                for (ContentDocumentLink docLink : [SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :docDetailMap.keySet()]) {
                    DocumentWrapper wrpr = new DocumentWrapper();
                    wrpr.LinkedEntityId = docLink.LinkedEntityId;
                    wrpr.fileExtension = docLink.ContentDocument.FileType;
                    wrpr.fileType = docDetailMap.get(docLink.LinkedEntityId).File_Type__c;
                    wrpr.cDId = docLink.ContentDocumentId;
                    wrpr.cdlId = docLink.Id;
                    wrpr.docId = docLink.LinkedEntityId;
                    wrpr.cvId = contentVersionMap.get(docLink.ContentDocumentId);
                    wrpr.incomeDocumentType = docDetailMap.get(docLink.LinkedEntityId).DocSubTyp__c;
                    wrpr.documentName = docLink.ContentDocument.Title;
                    wrapper.add(wrpr);
                }
                
            }
        }
        return wrapper;
    }
    
    //wrapper  decleration
    public class DocumentWrapper {
        @AuraEnabled
        public Id LinkedEntityId { get; set; }
        @AuraEnabled
        public String incomeDocumentType { get; set; }
        @AuraEnabled
        public String documentName { get; set; }
        @AuraEnabled
        public String fileType { get; set; }
        @AuraEnabled
        public String fileExtension { get; set; }
        @AuraEnabled
        public String  documentType { get; set; }
        @AuraEnabled
        public String docId { get; set; }
        @AuraEnabled
        public String cDId { get; set; }
        @AuraEnabled
        public string cdlId { get; set; }
        @AuraEnabled
        public string cvId { get; set; }
        @AuraEnabled
        public String cDcrtdDate { get; set; }
        @AuraEnabled
        public boolean FileAvalbl { get; set; }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String ApplId, String LoanAppId) {
        List<Applicant__c> applicants= [SELECT CustProfile__c,Constitution__c,Type_of_Borrower__c  FROM Applicant__c WHERE Id = :ApplId];
        List<LoanAppl__c> LoanApp = [SELECT AssesIncomeAppl__c from LoanAppl__c where id=:LoanAppId];
        String custProfile;
        String constitution;
        String borrower;
        if(!applicants.isEmpty()){
            custProfile = applicants[0].CustProfile__c;
            constitution = applicants[0].Constitution__c;
            borrower = applicants[0].Type_of_Borrower__c;
        }
        
        List<String> picklistValues = new List<String>();
        List<String> updatedPicklistValues = new List<String>();
        
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('Applicant_Financial__c').getDescribe().fields.getMap().get('Income_Documents__c').getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistValues.add(entry.getLabel());
        }
        if(custProfile!=null && constitution!=null && borrower!=null ){
            if(custProfile == 'SELF EMPLOYED PROFESSIONAL'  && constitution == 'INDIVIDUAL' && borrower == 'Non Financial'){
                if(!LoanApp.isEmpty() && LoanApp[0].AssesIncomeAppl__c =='No'){
                    for (Integer i =0; i<picklistValues.size(); i++) {
                        if (picklistValues[i] != 'Latest Year Form 16') {
                            updatedPicklistValues.add(picklistValues[i]);
                        }
                    }
                    return updatedPicklistValues;
                }
            }
            if(custProfile == 'SELF EMPLOYED NON PROFESSIONAL' && constitution != 'INDIVIDUAL' && borrower =='Financial'){
                if(!LoanApp.isEmpty() && LoanApp[0].AssesIncomeAppl__c =='No'){
                    for (Integer i =0; i<picklistValues.size(); i++) {
                        if (picklistValues[i] != 'Latest Year Form 16') {
                            updatedPicklistValues.add(picklistValues[i]);
                        }
                    }
                    return updatedPicklistValues;
                }
            }
        }
        return picklistValues;
    }
    
    @AuraEnabled
    public static String deleteFileRecord(String docIdToDelete){
        List<DocDtl__c> docDetailList; 
        if(String.isNotBlank(docIdToDelete)){
            List<ContentVersion> cvs= [SELECT Id,ContentDocumentId  FROM ContentVersion WHERE ContentDocumentId =:docIdToDelete];
            if(!cvs.isEmpty()){
                docDetailList= [SELECT Id FROM DocDtl__c where Content_Document_Id__c =:cvs[0].Id];
            }
            if(!docDetailList.isEmpty()){
                for(DocDtl__c dd:docDetailList){
                    delete dd;
                }
            }
            ContentDocument cd = new ContentDocument(Id=docIdToDelete);
            delete cd;
            return'SUCCESS';
        }else{
            return'FAILURE';
        }
    } 
}