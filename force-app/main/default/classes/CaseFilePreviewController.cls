public without sharing class CaseFilePreviewController {
    @AuraEnabled
    Public static List<DocDetailWrapper> getContentDocumentId(List<String> documentDetailId){
        string queryMain;
        Set<Id> docDetailId = new Set<id>();
        Set<Id> contentDocumentId = new Set<Id>();
        List<DocDtl__c> appDocDetailList = new List<DocDtl__c>();
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        List<ContentDocumentLink> dduploaded = new List<ContentDocumentLink>();
        List<DocDetailWrapper> wrapper = new List<DocDetailWrapper>();
        Map<String, ContentDocumentLink> contentDocLinkMap = new Map<String, ContentDocumentLink>();
        Map<Id, Id> contentdocToVesionMap = new Map<Id, Id>();
        Map<Id, ContentVersion> contentdocToVesionMapTwo = new Map<Id, ContentVersion>();
        system.debug('documentDetailId:'+documentDetailId);
        
        queryMain = 'SELECT Id,name,DocTyp__c,MrkErr__c,Rmrk__c,Appl__c,OSV__c,FileAvalbl__c,DocSubTyp__c,DocCatgry__c,CreatedDate,DocMstr__r.AvlInFile__c,DocMstr__r.OSVReq__c FROM DocDtl__c where ID IN : documentDetailId ';
        
        queryMain = queryMain += ' WITH SECURITY_ENFORCED order by CreatedDate ';  
        system.debug('queryMain' + queryMain);
        appDocDetailList = Database.query(queryMain);
        system.debug('appDocDetailList' + appDocDetailList);
        
        for (DocDtl__c dd : appDocDetailList) {
            docDetailId.add(dd.id);
        }
        
        system.debug('docDetailId' + docDetailId);
        
        if (docDetailId != null && !docDetailId.isEmpty()) {
            system.debug('Inside If');
            dduploaded = [
                SELECT
                Id,
                LinkedEntityId,
                ContentDocumentId,
                ContentDocument.CreatedDate,
                ContentDocument.Title,
                ContentDocument.ContentSize,
                ContentDocument.FileType
                FROM ContentDocumentLink
                WHERE LinkedEntityId  IN: docDetailId
            ];
        }
        system.debug('dduploaded' + dduploaded);
        
        
        for (ContentDocumentLink cdLink : dduploaded) {
            contentDocLinkMap.put(cdLink.LinkedEntityId, cdLink);
        }
        
        system.debug('contentDocLinkMap:'+contentDocLinkMap);
        for (ContentDocumentLink cdl : dduploaded) {
            contentDocumentId.add(cdl.ContentDocumentId);
        }
        
        system.debug('contentDocumentId:'+contentDocumentId);
        
        contentVersionList = [SELECT Id,VersionData,FileType,Title,FileExtension,ContentDocument.CreatedBy.Name,ContentDocument.ContentSize,
                              CreatedDate,
                              ContentDocumentId,
                              ContentDocument.FileType
                              FROM ContentVersion
                              WHERE ContentDocumentId IN :contentDocumentId
                             ];
        
        system.debug('contentVersionList:'+contentVersionList);
        for (ContentVersion cv : contentVersionList) {
            contentdocToVesionMap.put(cv.ContentDocumentId, cv.Id);
            contentdocToVesionMapTwo.put(cv.ContentDocumentId,cv);
        }
         system.debug('contentdocToVesionMap:'+contentdocToVesionMap);
         system.debug('contentdocToVesionMapTwo:'+contentdocToVesionMapTwo);
        
        for (DocDtl__c dd : appDocDetailList) {
            ContentDocumentLink cdl = contentDocLinkMap.get(dd.id);
            system.debug('document link objct inside the loop:'+cdl);
            DocDetailWrapper wrpr = new DocDetailWrapper();
            if (cdl != null) {
                system.debug('Inside Wrapper If');
                wrpr.LinkedEntityId = cdl.LinkedEntityId;
                wrpr.cDFileType = cdl.ContentDocument.FileType;
                wrpr.cDId = cdl.ContentDocumentId;
                wrpr.cdlId = cdl.Id;
                // wrpr.blobData = EncodingUtil.base64Encode(contentdocToVesionMapTwo.get(cdl.ContentDocumentId).VersionData);
                wrpr.cvId = contentdocToVesionMap.get(cdl.ContentDocumentId);
            }
            wrpr.docDetName = dd.DocSubTyp__c;
            wrpr.docDetType = dd.DocTyp__c;
            datetime dateis = dd.CreatedDate;
            wrpr.cDcrtdDate = dateis.format('dd-MM-yyyy  HH:mm');
            wrpr.docId = dd.id;
            //wrpr.ocrStatus = dd.Applicant_KYC__r.OCRStatus__c;
            //wrpr.validationStatus = dd.Applicant_KYC__r.ValidationStatus__c;
            wrpr.osv = dd.OSV__c;
            wrpr.availableInFile = dd.FileAvalbl__c;
            wrpr.osvReq = dd.DocMstr__r.OSVReq__c;
            wrpr.avaiableInFileReq = dd.DocMstr__r.AvlInFile__c;
            //wrpr.appKycId = dd.Applicant_KYC__r.Id;
            wrpr.markForError = dd.MrkErr__c;
            wrpr.remarks = dd.Rmrk__c;
            wrapper.add(wrpr);
        }
        system.debug('wrapper' + wrapper);
        system.debug('wrapper' + wrapper.size());
        return wrapper;     
        
    }
    
    public class DocDetailWrapper {
        @AuraEnabled
        public Id LinkedEntityId { get; set; }
        @AuraEnabled
        public String docDetType { get; set; }
        @AuraEnabled
        public String docDetName { get; set; }
        @AuraEnabled
        public String cDFileType { get; set; }
        @AuraEnabled
        public String cDcrtdDate { get; set; }
        @AuraEnabled
        public String validationStatus { get; set; }
        @AuraEnabled
        public String ocrStatus { get; set; }
        @AuraEnabled
        public Boolean osv { get; set; }
        @AuraEnabled
        public String docId { get; set; }
        @AuraEnabled
        public String cDId { get; set; }
        @AuraEnabled
        public Boolean availableInFile { get; set; }
        @AuraEnabled
        public string cdlId { get; set; }
        @AuraEnabled
        public string cvId { get; set; }
        @AuraEnabled
        public Boolean osvReq { get; set; }
        @AuraEnabled
        public string appKycId { get; set; }
        @AuraEnabled
        public Boolean avaiableInFileReq { get; set; }
        @AuraEnabled
        public Boolean markForError { get; set; }
        @AuraEnabled
        public String remarks { get; set; }
        //  @AuraEnabled
        //   public String blobData { get; set; }
    }
    
    /*  if (category.size() > 0) {
queryMain = queryMain += ' AND DocCatgry__c in: category ';
if (docType.size() != 0) {
queryMain = queryMain += ' AND DocTyp__c in: docType  ';
if (subType.size() > 0) {
queryMain = queryMain += ' AND DocSubTyp__c in: subType ';
}
}
}*/
    
}