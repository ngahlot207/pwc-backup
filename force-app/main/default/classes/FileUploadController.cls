public without sharing class FileUploadController {
  public static List<String> kycOcrList = new List<String>{
    'Passport',
    'Aadhaar',
    'Voter ID',
    'Driving license',
    'PAN',
    'Letter issued by the National Population Register'
  };
  //to get uploaded files on document Detail  obj related to applicant and loan application
  @AuraEnabled
  public static List<DocDetailWrapper> fetchId(
    String applicantId,
    List<String> category,
    list<string> docType,
    List<String> subType
  ) {
    string queryMain;
    Id sampleid = applicantId;
    string empRole;
    Id userId = UserInfo.getUserId();
      
   Profile pfile = [Select Name from Profile where Id =: userinfo.getProfileid()];
      if(pfile.Name != 'Agency Profile' && pfile.Name != 'DSA'){
         empRole = [
        SELECT
        Id,
        Product_Type__c,
        IsActive__c,
        Employee__c,
        EmpLevel__c,
        EmpRole__c
      FROM TeamHierarchy__c
      WHERE Employee__c = :userId
      LIMIT 1
    ]
    .EmpRole__c;
      }  
    

    system.debug(sampleid.getsobjecttype().getDescribe().getName());
    system.debug('applicantId ' + applicantId + 'subType' + subType);
    // List<DocDtl__c> docDetailList = new List<DocDtl__c>();
    List<DocDtl__c> appDocDetailList = new List<DocDtl__c>();
    if (sampleid.getsobjecttype().getDescribe().getName() == 'Applicant__c') {
      queryMain = 'SELECT Id,name,DocTyp__c,DocValidStatus__c,MrkErr__c,Rmrk__c,RM_Remarks__c,Appl__c,OSV__c,FileAvalbl__c,DocSubTyp__c,DocCatgry__c,CreatedDate,UtilityBillDate__c,ShopAndEstablishmentDate__c,Applicant_KYC__r.Id,Applicant_KYC__r.PanIvalid__c,Applicant_KYC__r.ValidationStatus__c,DocMstr__r.AvlInFile__c,DocMstr__r.OSVReq__c,Applicant_KYC__r.OCRStatus__c , Applicant_KYC__r.NPRNumber__c, Applicant_KYC__r.Name__c,Applicant_KYC__r.DtOfBirth__c,Applicant_KYC__r.NameInAdhr__c,Applicant_KYC__r.AadharNo__c,Applicant_KYC__r.PassNo__c,Applicant_KYC__r.NameInPan__c,Applicant_KYC__r.Pan__c,Applicant_KYC__r.DLNo__c,Applicant_KYC__r.VotIdEpicNo__c,Applicant_KYC__r.URC_Number__c, Applicant_KYC__r.GSTIN__c FROM DocDtl__c where Appl__c =: applicantId AND IsLatest__c=true AND IsDeleted__c != true';//// LAK-162
    } else if (sampleid.getsobjecttype().getDescribe().getName() == 'Case') {
      queryMain = 'SELECT Id,name,DocTyp__c,DocValidStatus__c,MrkErr__c,Rmrk__c,RM_Remarks__c,Appl__c,OSV__c,FileAvalbl__c,DocSubTyp__c,DocCatgry__c,CreatedDate,UtilityBillDate__c,ShopAndEstablishmentDate__c,Applicant_KYC__r.Id,Applicant_KYC__r.PanIvalid__c,Applicant_KYC__r.ValidationStatus__c,DocMstr__r.AvlInFile__c,DocMstr__r.OSVReq__c,Applicant_KYC__r.OCRStatus__c,Applicant_KYC__r.DtOfBirth__C,Applicant_KYC__r.Name__c FROM DocDtl__c where Case__c =: applicantId AND IsLatest__c=true AND IsDeleted__c != true';//// LAK-162
    } 
      else if (
      sampleid.getsobjecttype().getDescribe().getName() == 'ApplAsset__c'
    ) {
      queryMain = 'SELECT Id,name,DocTyp__c,DocValidStatus__c,MrkErr__c,Rmrk__c,RM_Remarks__c,Appl__c,OSV__c,FileAvalbl__c,DocSubTyp__c,DocCatgry__c,CreatedDate,UtilityBillDate__c,ShopAndEstablishmentDate__c,Applicant_KYC__r.Id,Applicant_KYC__r.PanIvalid__c,Applicant_KYC__r.ValidationStatus__c,DocMstr__r.AvlInFile__c,DocMstr__r.OSVReq__c,Applicant_KYC__r.OCRStatus__c,Applicant_KYC__r.DtOfBirth__C,Applicant_KYC__r.Name__c FROM DocDtl__c where ApplAsset__c =: applicantId AND IsLatest__c=true AND IsDeleted__c != true';//// LAK-162
    }
    else if (
      sampleid.getsobjecttype().getDescribe().getName() == 'LoanAppl__c'
    ) {
      queryMain = 'SELECT Id,name,DocTyp__c,DocValidStatus__c,MrkErr__c,Rmrk__c,RM_Remarks__c,Appl__c,OSV__c,FileAvalbl__c,DocSubTyp__c,DocCatgry__c,CreatedDate,UtilityBillDate__c,ShopAndEstablishmentDate__c,Applicant_KYC__r.Id,Applicant_KYC__r.PanIvalid__c,Applicant_KYC__r.ValidationStatus__c,DocMstr__r.AvlInFile__c,DocMstr__r.OSVReq__c,Applicant_KYC__r.OCRStatus__c,Applicant_KYC__r.DtOfBirth__C,Applicant_KYC__r.Name__c,Applicant_KYC__r.NameInAdhr__c,Applicant_KYC__r.AadharNo__c,LAN__c FROM DocDtl__c where LAN__c =: applicantId AND IsLatest__c=true AND IsDeleted__c != true';//// LAK-162
    }
    else if (
      sampleid.getsobjecttype().getDescribe().getName() == 'LoanAppeal__c'
    ) {
      queryMain ='SELECT Id,name,DocTyp__c,DocValidStatus__c,MrkErr__c,Rmrk__c,RM_Remarks__c,Appl__c,OSV__c,FileAvalbl__c,DocSubTyp__c,DocCatgry__c,CreatedDate,UtilityBillDate__c,ShopAndEstablishmentDate__c,Applicant_KYC__r.Id,Applicant_KYC__r.PanIvalid__c,Applicant_KYC__r.ValidationStatus__c,DocMstr__r.AvlInFile__c,DocMstr__r.OSVReq__c,Applicant_KYC__r.OCRStatus__c , Applicant_KYC__r.NPRNumber__c, Applicant_KYC__r.Name__c,Applicant_KYC__r.DtOfBirth__c,Applicant_KYC__r.NameInAdhr__c,Applicant_KYC__r.AadharNo__c,Applicant_KYC__r.PassNo__c,Applicant_KYC__r.NameInPan__c,Applicant_KYC__r.Pan__c,Applicant_KYC__r.DLNo__c,Applicant_KYC__r.VotIdEpicNo__c,Applicant_KYC__r.URC_Number__c, Applicant_KYC__r.GSTIN__c FROM DocDtl__c where ReferenceId__c =: applicantId AND IsLatest__c=true AND IsDeleted__c != true';
      
    }


    if (category.size() > 0) {
      queryMain = queryMain += ' AND DocCatgry__c in: category ';
      if (docType.size() != 0) {
        queryMain = queryMain += ' AND DocTyp__c in: docType  ';
        if (subType.size() > 0) {
          queryMain = queryMain += ' AND DocSubTyp__c in: subType ';
        }
      }
    }
    queryMain = queryMain += ' order by CreatedDate DESC';
    system.debug('queryMain' + queryMain);
    appDocDetailList = Database.query(queryMain);

    system.debug('appDocDetailList' + appDocDetailList);
    Set<Id> docDetailId = new Set<id>();

    for (DocDtl__c dd : appDocDetailList) {
      docDetailId.add(dd.id);
    }

    List<ContentDocumentLink> dduploaded = new List<ContentDocumentLink>();
    if (docDetailId != null && !docDetailId.isEmpty()) {
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
        WHERE LinkedEntityId IN :docDetailId
        WITH SECURITY_ENFORCED
      ];
    }
    list<DocDetailWrapper> wrapper = new List<DocDetailWrapper>();
    Map<String, ContentDocumentLink> contentDocLinkMap = new Map<String, ContentDocumentLink>();

    for (ContentDocumentLink cdLink : dduploaded) {
      contentDocLinkMap.put(cdLink.LinkedEntityId, cdLink);
    }
    Set<Id> contentDocumentId = new Set<Id>();
    for (ContentDocumentLink cdl : dduploaded) {
      contentDocumentId.add(cdl.ContentDocumentId);
    }

    List<ContentVersion> contentVersionList = [
      SELECT
        Id,
        FileType,
        Title,
        FileExtension,
        ContentDocument.CreatedBy.Name,
        ContentDocument.ContentSize,
        CreatedDate,
        ContentDocumentId,
        ContentDocument.FileType
      FROM ContentVersion
      WHERE ContentDocumentId IN :contentDocumentId
    ];
    Map<Id, Id> contentdocToVesionMap = new Map<Id, Id>();
    Map<Id, ContentVersion> contentdocToVesionMapTwo = new Map<Id, ContentVersion>();
    for (ContentVersion cv : contentVersionList) {
      contentdocToVesionMap.put(cv.ContentDocumentId, cv.Id);
      contentdocToVesionMapTwo.put(cv.ContentDocumentId, cv);
    }
    for (DocDtl__c dd : appDocDetailList) {
        if (dd.DocCatgry__c != 'Bureau Report' || (dd.DocCatgry__c == 'Bureau Report' && empRole != 'RM' && empRole != 'SM')){
            ContentDocumentLink cdl = contentDocLinkMap.get(dd.id);
            DocDetailWrapper wrpr = new DocDetailWrapper();
            if (cdl != null) {
              wrpr.LinkedEntityId = cdl.LinkedEntityId;
              wrpr.cDFileType = cdl.ContentDocument.FileType;
              wrpr.cDId = cdl.ContentDocumentId;
              wrpr.cdlId = cdl.Id;
              // wrpr.blobData = EncodingUtil.base64Encode(contentdocToVesionMapTwo.get(cdl.ContentDocumentId).VersionData);
              wrpr.cvId = contentdocToVesionMap.get(cdl.ContentDocumentId);
            }
            wrpr.docDetName = dd.DocSubTyp__c;
            if (dd.Applicant_KYC__r.DtOfBirth__c != null) {
              DateTime dateTimeValue = DateTime.newInstance(
                dd.Applicant_KYC__r.DtOfBirth__c,
                Time.newInstance(0, 0, 0, 0)
              );
              wrpr.dobOnDoc = dateTimeValue.format('dd-MM-yyyy');
            }
            if (dd.Applicant_KYC__r.Name__c != null) {
              wrpr.nameOnDoc = dd.Applicant_KYC__r.Name__c;
            }
            if (dd.DocSubTyp__c == 'Aadhaar') {
              if (dd.Applicant_KYC__r.NameInAdhr__c != null) {
                wrpr.nameOnDoc = dd.Applicant_KYC__r.NameInAdhr__c;
              }
              if (dd.Applicant_KYC__r.AadharNo__c != null) {
                wrpr.idNumberOnDoc = dd.Applicant_KYC__r.AadharNo__c;
              }
            } else if (dd.DocSubTyp__c == 'Passport') {
              if (dd.Applicant_KYC__r.PassNo__c != null) {
                wrpr.idNumberOnDoc = dd.Applicant_KYC__r.PassNo__c;
              }
            } else if (dd.DocSubTyp__c == 'PAN') {
              if (dd.Applicant_KYC__r.NameInPan__c != null) {
                wrpr.nameOnDoc = dd.Applicant_KYC__r.NameInPan__c;
              }
              if (dd.Applicant_KYC__r.Pan__c != null) {
                wrpr.idNumberOnDoc = dd.Applicant_KYC__r.Pan__c;
              }
            } else if (dd.DocSubTyp__c == 'Driving license') {
              if (dd.Applicant_KYC__r.DLNo__c != null) {
                wrpr.idNumberOnDoc = dd.Applicant_KYC__r.DLNo__c;
              }
            } else if (dd.DocSubTyp__c == 'Voter ID') {
              if (dd.Applicant_KYC__r.VotIdEpicNo__c != null) {
                wrpr.idNumberOnDoc = dd.Applicant_KYC__r.VotIdEpicNo__c;
              }
            } else if (
              dd.DocSubTyp__c == 'Letter issued by the National Population Register'
            ) {
              if (dd.Applicant_KYC__r.NPRNumber__c != null) {
                wrpr.idNumberOnDoc = dd.Applicant_KYC__r.NPRNumber__c;
              }
              wrpr.nameOnDoc = '';
            } else if (
              dd.DocSubTyp__c == 'Udyam Registration Certificate'
            ) {
              if (dd.Applicant_KYC__r.URC_Number__c != null) {
                wrpr.idNumberOnDoc = dd.Applicant_KYC__r.URC_Number__c;
              }
             
            } else if (
              dd.DocSubTyp__c == 'GST certificate'
            ) {
              if (dd.Applicant_KYC__r.GSTIN__c != null) {
                wrpr.idNumberOnDoc = dd.Applicant_KYC__r.GSTIN__c;
              }
             
            }

      
            wrpr.docCategory = dd.DocCatgry__c;
            wrpr.docDetType = dd.DocTyp__c;
            datetime dateis = dd.CreatedDate;
            wrpr.cDcrtdDate = dateis.format('dd-MM-yyyy hh:mm aa');
      
            if (dd.UtilityBillDate__c != null) {
              DateTime dateTimeValue = DateTime.newInstance(
                dd.UtilityBillDate__c,
                Time.newInstance(0, 0, 0, 0)
              );
              wrpr.cDUtilBillDate = dateTimeValue.format('dd-MM-yyyy');
            }
            if (dd.ShopAndEstablishmentDate__c != null) {
              DateTime dateTimeValue = DateTime.newInstance(
                dd.ShopAndEstablishmentDate__c,
                Time.newInstance(0, 0, 0, 0)
              );
              wrpr.cDEstablishmentDate = dateTimeValue.format('dd-MM-yyyy');
            }
            wrpr.docId = dd.id;
            wrpr.ocrStatus = dd.Applicant_KYC__r.OCRStatus__c;
            wrpr.panInvalid = dd.Applicant_KYC__r.PanIvalid__c;
            wrpr.validationStatus = dd.DocValidStatus__c;
            wrpr.osv = dd.OSV__c;
            wrpr.availableInFile = dd.FileAvalbl__c;
            wrpr.osvReq = dd.DocMstr__r.OSVReq__c;
            //LAK-4747
            // docDetType == '' && cdl != null ? false :
            wrpr.avaiableInFileReq = cdl != null ? false : dd.DocMstr__r.AvlInFile__c;
            wrpr.appKycId = dd.Applicant_KYC__r.Id;
            wrpr.markForError = dd.MrkErr__c;
            wrpr.remarks = dd.Rmrk__c;
            //LAK-3223
            wrpr.rmRemarks = dd.RM_Remarks__c;
            wrapper.add(wrpr);
        }  
    }
    system.debug('wrapper' + wrapper);
    return wrapper;
  }

  @AuraEnabled
  public static string deleteDocDetail(String docId) {
    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
      new List<SObjectType>{ ApplKyc__c.SObjectType, DocDtl__c.SObjectType }
    );

    List<ContentDocumentLink> cdlist = [
      SELECT Id, LinkedEntityId, ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :docId
    ];
    if (cdlist.size() == 0) {
      List<DocDtl__c> newDoc = [
        SELECT Id, DocMstr__c, Applicant_KYC__r.Id
        FROM DocDtl__c
        WHERE id = :docId
        WITH SECURITY_ENFORCED
      ];
      list<ApplKyc__c> appKycList = new List<ApplKyc__c>();
      string appKycId = newDoc[0].Applicant_KYC__r.Id;
      List<DocDtl__c> existingDoc = [
        SELECT Id, DocMstr__c, Applicant_KYC__r.Id
        FROM DocDtl__c
        WHERE Applicant_KYC__r.Id = :appKycId
        WITH SECURITY_ENFORCED
      ];

      if (existingDoc.size() == 1) {
        uow.registerDeleted(newDoc[0].Applicant_KYC__r);
      }

      uow.registerDeleted(newDoc);
    }
    uow.commitWork();
    return 'document detail deleted';
  }

  //wrapper  decleration
  public class DocDetailWrapper {
    @AuraEnabled
    public Id LinkedEntityId { get; set; }
    @AuraEnabled
    public String docDetType { get; set; }
    @AuraEnabled
    public String docDetName { get; set; }
    //Added for Multiple Doc Upload
    @AuraEnabled
    public String docCategory { get; set; }
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
    //LAK-3223
    @AuraEnabled
    public String rmRemarks { get; set; }
    //LAK-4095
    @AuraEnabled
    public Boolean panInvalid { get; set; }
    @AuraEnabled
    public string cDUtilBillDate { get; set; }
    @AuraEnabled
    public string cDEstablishmentDate { get; set; }

    @AuraEnabled
    public string idNumberOnDoc { get; set; }
    @AuraEnabled
    public string nameOnDoc { get; set; }
    @AuraEnabled
    public string dobOnDoc { get; set; }
    //  @AuraEnabled
    //   public String blobData { get; set; }
  }
}