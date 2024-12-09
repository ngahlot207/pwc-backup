public class DocumentCheckController {
  @AuraEnabled
  public static List<DocDetailWrapper> ndcDocumentCheck(String loanAppId) {
    List<DocDtl__c> docDtlList = new List<DocDtl__c>();
    Set<Id> docIds = new Set<Id>();
    List<ContentDocumentLink> dduploaded = new List<ContentDocumentLink>();
    List<DocDetailWrapper> resWrperList = new List<DocDetailWrapper>();
    List<NDC__c> ndcRecords = new List<NDC__c>();
    String ndcType;
    ndcRecords = [
      SELECT Id, Name, NDC_Type__c, DocDtl__c
      FROM NDC__c
      WHERE LoanAppl__c = :loanAppId AND IsInvalid__c = FALSE
    ];

    Set<Id> ndcDocDtlIds = new Set<Id>();
    if (ndcRecords != null && ndcRecords.size() > 0) {
      for (NDC__c ndcc : ndcRecords) {
        if (ndcc.DocDtl__c != null) {
          ndcDocDtlIds.add(ndcc.DocDtl__c);
        }
        if (ndcc.NDC_Type__c != null) {
          ndcType = ndcc.NDC_Type__c;
        }
      }
    }
    //AND IsLatest__c = true added for LAK-9041
    docDtlList = [
      SELECT
        Id,
        DocStatus__c,
        FileAvalbl__c,
        DocSubTyp__c,
        DocTyp__c,
        DocCatgry__c
      FROM DocDtl__c
      WHERE
        LAN__c = :loanAppId
        AND Id IN :ndcDocDtlIds
        AND (DocStatus__c = 'Received'
        OR DocStatus__c = 'Completed'
        OR (DocTyp__c ='Application Form' AND DocCatgry__c = 'System Generated Documents' AND IsLatest__c = true))
    ];
    if (docDtlList != null && docDtlList.size() > 0) {
      for (DocDtl__c docDtl : docDtlList) {
        docIds.add(docDtl.Id);
      }
    }
    if (docIds != null && docIds.size() > 0) {
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
        WHERE LinkedEntityId IN :docIds
      ];
    }
    Map<String, String> docDtlWithDoc = new Map<String, String>();
    Set<Id> contentDocumentId = new Set<Id>();
    for (ContentDocumentLink cdl : dduploaded) {
      contentDocumentId.add(cdl.ContentDocumentId);
      docDtlWithDoc.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
    }
    if (docDtlList != null && docDtlList.size() > 0) {
      for (DocDtl__c docDtl : docDtlList) {
        if (
          docDtl.DocCatgry__c != null &&
          (docDtl.DocCatgry__c != 'Property Documents' &&
          docDtl.DocCatgry__c != 'Additional Post Sanction Documents') ||
          ((docDtl.DocCatgry__c == 'Property Documents' ||
          docDtl.DocCatgry__c == 'Additional Post Sanction Documents') &&
          docDtl.FileAvalbl__c == false)
        ) {
          String contnrDocId = docDtlWithDoc.get(docDtl.Id);
          if (contnrDocId == null) {
            DocDetailWrapper docWrp = new DocDetailWrapper();
            docWrp.docCategry = docDtl.DocCatgry__c;
            docWrp.docDetType = docDtl.DocTyp__c;
            docWrp.docDetName = docDtl.DocSubTyp__c;
            resWrperList.add(docWrp);
          }
        }
      }
    }
    if (
      resWrperList != null &&
      resWrperList.size() > 0 &&
      ndcType == 'Scan Based Disbursement'
    ) {
      return resWrperList;
    }
    return null;
  }
  //wrapper  decleration
  public class DocDetailWrapper {
    @AuraEnabled
    public String docCategry { get; set; }
    @AuraEnabled
    public String docDetType { get; set; }
    @AuraEnabled
    public String docDetName { get; set; }
  }
}