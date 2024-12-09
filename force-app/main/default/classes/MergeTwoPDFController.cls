public class MergeTwoPDFController {
    
public ContentVersion  conVersion  {
    get {
       // conDocument = [SELECT Id, VersionData, FileType FROM ContentVersion WHERE ContentDocument.Title = 'PDF_081108' AND IsLatest = true];
        conVersion  = [SELECT id,VersionData,Document_Name__c, ContentDocument.Id,  Document_Category__c, FileType FROM ContentVersion where  ContentDocument.Id='069C4000003EEivIAG'];
        
        return conVersion ;
    }
    private set;
}

public String pdfImgUrl {
    get {
        return '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId='+conVersion.Id;
        
        // return '/sfc/servlet.shepherd/version/download/' + conVersion.Id;
        
        // return EncodingUtil.base64Encode(conVersion.VersionData);
    }
}
}