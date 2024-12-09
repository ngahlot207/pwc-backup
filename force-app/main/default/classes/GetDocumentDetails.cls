public class GetDocumentDetails {
    @AuraEnabled
    public static DdData getDocumentData(String caseId) {
        List<DocDtl__c> documentDtlList = new List<DocDtl__c>();
        List<ContentDocumentLink> dduploaded = new List<ContentDocumentLink>();
        Map<String, ContentDocumentLink> contentDocLinkMap = new Map<String, ContentDocumentLink>();
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        DdData ddDta = new DdData();
        if (caseID != null) {
            system.debug('caseID ' + caseID);
            documentDtlList = [
                SELECT Id, DocSubTyp__c, DocTyp__c
                FROM DocDtl__c
                WHERE Case__c = :caseID
                LIMIT 1
            ];
        }
        if (documentDtlList != null && documentDtlList.size() > 0) {
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
                WHERE LinkedEntityId = :documentDtlList[0].id
            ];
        }
        if (dduploaded != null && dduploaded.size() > 0) {
            contentVersionList = [
                SELECT
                    Id,
                    VersionData,
                    FileType,
                    Title,
                    FileExtension,
                    ContentDocument.CreatedBy.Name,
                    ContentDocument.ContentSize,
                    CreatedDate,
                    ContentDocumentId,
                    ContentDocument.FileType
                FROM ContentVersion
                WHERE ContentDocumentId = :dduploaded[0].ContentDocumentId
            ];
        }
        if (documentDtlList != null && documentDtlList.size() > 0) {
            ddDta.documentId = documentDtlList[0].Id;
            ddDta.documentName = documentDtlList[0].DocSubTyp__c;
            ddDta.documentType = documentDtlList[0].DocTyp__c;
            ddDta.fileType = dduploaded[0].ContentDocument.FileType;
            ddDta.cdId = dduploaded[0].ContentDocumentId;
            ddDta.cvId = contentVersionList[0].Id;
            ddDta.cdlId = dduploaded[0].Id;
        }
        if (ddDta != null) {
            return ddDta;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static PreviewWrpr getFilePreviewData(String ddID) {
        List<ContentDocumentLink> dduploaded = new List<ContentDocumentLink>();
        Map<String, ContentDocumentLink> contentDocLinkMap = new Map<String, ContentDocumentLink>();
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        PreviewWrpr ddDta = new PreviewWrpr();
        if (ddID != null) {
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
                WHERE LinkedEntityId = :ddID
            ];
        }
        if (dduploaded != null && dduploaded.size() > 0) {
            contentVersionList = [
                SELECT
                    Id,
                    VersionData,
                    FileType,
                    Title,
                    FileExtension,
                    ContentDocument.CreatedBy.Name,
                    ContentDocument.ContentSize,
                    CreatedDate,
                    ContentDocumentId,
                    ContentDocument.FileType
                FROM ContentVersion
                WHERE ContentDocumentId = :dduploaded[0].ContentDocumentId
            ];
        }
        if (ddID != null) {
            ddDta.fileType = dduploaded[0].ContentDocument.FileType;
            ddDta.cvId = contentVersionList[0].Id;
            ddDta.cdId = dduploaded[0].ContentDocumentId;
            ddDta.cdlId = dduploaded[0].Id;
            ddDta.ddID = ddID;
        }
        if (ddDta != null) {
            return ddDta;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static list<PreviewWrpr> getFilePreviewDataList(String ddID) {
        List<ContentDocumentLink> dduploaded = new List<ContentDocumentLink>();
        Map<String, ContentDocumentLink> contentDocLinkMap = new Map<String, ContentDocumentLink>();
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        list<PreviewWrpr> ddDtaList = new List<PreviewWrpr>();
        list<string> ContentDocumentIdList = new List<string>();
        if (ddID != null) {
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
                WHERE LinkedEntityId = :ddID
            ];
            for (ContentDocumentLink dd : dduploaded) {
                ContentDocumentIdList.add(dd.ContentDocumentId);
            }
        }
        map<id, ContentVersion> contentVersionMap = new Map<id, ContentVersion>();
        if (dduploaded != null && dduploaded.size() > 0) {
            contentVersionList = [
                SELECT
                    Id,
                    VersionData,
                    FileType,
                    Title,
                    FileExtension,
                    ContentDocument.CreatedBy.Name,
                    ContentDocument.ContentSize,
                    CreatedDate,
                    ContentDocumentId,
                    ContentDocument.FileType
                FROM ContentVersion
                WHERE ContentDocumentId IN :ContentDocumentIdList
            ];
            for (ContentVersion cv : contentVersionList) {
                contentVersionMap.put(cv.ContentDocumentId, cv);
            }
        }
        if (ddID != null) {
            for (ContentDocumentLink dd : dduploaded) {
                PreviewWrpr ddDta = new PreviewWrpr();
                ddDta.fileType = dd.ContentDocument.FileType;
                ddDta.fileTitle = dd.ContentDocument.Title;

                ddDta.cvId = contentVersionMap.get(dd.ContentDocumentId).Id;
                ddDta.cdId = dd.ContentDocumentId;
                ddDta.cdlId = dd.Id;
                ddDtaList.add(ddDta);
            }
        }
        // if (ddDtaList.size() != 0) {
        //     return ddDtaList;
        // } else {
        //     return null;
        // }
        return ddDtaList;
    }
    public class DdData {
        @AuraEnabled
        public String documentId { get; set; }
        @AuraEnabled
        public String documentName { get; set; }
        @AuraEnabled
        public String documentType { get; set; }
        @AuraEnabled
        public String fileType { get; set; }
        @AuraEnabled
        public String cvId { get; set; }
        @AuraEnabled
        public String cdlId { get; set; }
        @AuraEnabled
        public String cdId { get; set; }
    }
    public class PreviewWrpr {
        @AuraEnabled
        public String fileType { get; set; }
        @AuraEnabled
        public String fileTitle { get; set; }
        @AuraEnabled
        public String cvId { get; set; }
        @AuraEnabled
        public String cdlId { get; set; }
        @AuraEnabled
        public String cdId { get; set; }
        @AuraEnabled
        public String ddID { get; set; }
    }
}