public class FileUploadCoApplicant {
    
    public static String businessUnit ='Home Loan';
    public static String documentType = 'Physical Consent Proof';
    public static String productType = 'Home Loan';
    
    /*
   * @method uploadFile() 
   * @desc Creates a content version from a given file's base64 and name
   * 
   * @param {String} base64 - base64 string that represents the file
   * @param {String} filename - full file name with extension, i.e. 'products.csv'
   * @param {String} recordId - Id of the record you want to attach this file to
   * 
   * @return {ContentVersion} - returns the created ContentDocumentLink Id if the
   *   upload was successful, otherwise returns null
   */
   @AuraEnabled
  public static String uploadFile(String base64, String filename, String loanAppId, String applicantId) {
        ContentVersion cv = createContentVersion(base64, filename);
        String documentDetaildId = fetchOrCreateDocumentMaster(loanAppId, applicantId);
        if(String.isNotBlank(documentDetaildId)){
          ContentDocumentLink cdl = createContentLink(cv.Id, documentDetaildId);
            return cdl.Id;
        }else{
            return null;
        }
  }
    
    
    public static String fetchOrCreateDocumentMaster(String masterId, String childId){
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
  /*
   * @method createContentVersion() [private]
   * @desc Creates a content version from a given file's base64 and name
   * 
   * @param {String} base64 - base64 string that represents the file
   * @param {String} filename - full file name with extension, i.e. 'products.csv'
   * 
   * @return {ContentVersion} - returns the newly created ContentVersion, or null
   *   if there was an error inserting the record
   */
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

   /*
   * @method createContentLink() [private]
   * @desc Creates a content link for a given ContentVersion and record
   * 
   * @param {String} contentVersionId - Id of the ContentVersion of the file
   * @param {String} recordId - Id of the record you want to attach this file to
   * 
   * @return {ContentDocumentLink} - returns the newly created ContentDocumentLink, 
   *   or null if there was an error inserting the record
   */
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
        Map<ID,String> mapIdTitle = new Map<ID,String>();
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        Map<Id, DocDtl__c> docDetailMap = new Map<Id, DocDtl__c>([SELECT Id FROM DocDtl__c WHERE Appl__c  =:applicantId AND Lan__c =:loanAppId]);
                
        if (!docDetailMap.keySet().isEmpty()) {
            List<ID> fileIDs = new List<ID>();
            
            for (ContentDocumentLink docLink : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :docDetailMap.keySet()]) {
                fileIDs.add(docLink.ContentDocumentId);
            }
            
            for (ContentVersion docLink : [SELECT ContentDocumentId, FileExtension, Title, ContentSize FROM ContentVersion WHERE ContentDocumentId IN :fileIDs ORDER BY CreatedDate DESC]) {
                mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
                contentVersionList.add(docLink);
            }
        }
        
        //return mapIdTitle;
        return contentVersionList;
        // System.debug('map of record '+mapIdTitle);
    }
    
    
   
    
    //delete
                                                       
   @AuraEnabled
    public static String deleteFileRecord(String deleteRecordId){
        //String contentVersionId = [Select Id, ContentDocumentId from ContentVersion where ID =:deleteRecordId LIMIT 1].ContentDocumentId;
        if(String.isNotBlank(deleteRecordId)){
            ContentDocument cd = new ContentDocument(Id=deleteRecordId);
            delete cd;
            return'SUCCESS';
        }else{
             return'FAILURE';
        }
    }
    
}