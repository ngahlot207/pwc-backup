public class TestApexClass {
    
        public static Boolean collectAllContentDataFromLead(String applicantId,String loanAppId,String leadId){
		if(!String.isBlank(leadId)){
			List<ContentDocument> ContentDocumentListIds = new List<ContentDocument>();
			ContentDocumentListIds = [SELECT Id, LatestPublishedVersionId 
									  FROM ContentDocument where LatestPublishedVersionId in 
									  (select id from ContentVersion where ContentDocumentId = '069C4000002xBpVIAU'  
									  AND Document_Category__c IN('KYC Documents', 'PAN Documents')) 
									  order by createddate desc];
		    if(!ContentDocumentListIds.isEmpty()){
				Set<Id> contentDocumentSetIds = new Set<Id>();
				for(ContentDocument cd: ContentDocumentListIds){
					contentDocumentSetIds.add(cd.Id);
				}
				return createAndAttachDocumentDetail(contentDocumentSetIds, applicantId, loanAppId, leadId);
			}else{
				return false;
			}		
		}else{
			return false;
		}
    }
    public static Boolean createAndAttachDocumentDetail(Set<Id> contentDocIds, String applicantId,String loanAppId,string leadId){
		 Map<String, String> allInsertedData = new Map<String, String>();
		 String docCategory;
		 String docType;
		 String docSubType;
		 List<ContentVersion>  contList = new List<ContentVersion>();
		 contList = [SELECT ContentDocumentId, Document_Category__c, Document_Name__c, 
		             Document_Type__c, FirstPublishLocationId, Id FROM ContentVersion WHERE ContentDocumentId = '069C4000002xBpVIAU'];
		for(ContentVersion cv : contList){
			 docCategory = cv.Document_Category__c;
			 docType = cv.Document_Type__c;
			 docSubType = cv.Document_Name__c;
			 // Get matching applicant KYC records
			 List<ApplKyc__c> applKycList = new List<ApplKyc__c>();
			 applKycList = [SELECT Id, Applicant__c, kycDoc__c FROM ApplKyc__c WHERE Applicant__c = : applicantId AND kycDoc__c =: docSubType];
			 if(!applKycList.isEmpty()){ 
				 Map<String, String> hashMap = new Map<String, String>();
				 hashMap = createDocDetailAndAttchCV(applicantId,  loanAppId,  docCategory,  docType, docSubType,applKycList[0].id, cv.ContentDocumentId);
				 for(String key : hashMap.keySet()) {
					allInsertedData.put(key, hashMap.get(key));
				 }
			 }else{
				 String appKycId = createApplicantKyc(applicantId,docSubType);
				 if(!String.isEmpty(appKycId)){
					 Map<String, String> hashMap = new Map<String, String>();
					 hashMap = createDocDetailAndAttchCV(applicantId,  loanAppId,  docCategory,  docType, docSubType,appKycId, cv.ContentDocumentId);
					 for(String key : hashMap.keySet()) {
						allInsertedData.put(key, hashMap.get(key));
					 }
				 }
			 }
		}

		 if(allInsertedData.keySet().size() == contentDocIds.size()){
			 // Meaning for all the documents , a related Document Detail record has been created.
			 return true;
		 }else{
			 return false;
		 } 
	} 

	public static List<String> kycOcrList = new List<String>{'Passport','Aadhaar','Voter ID','Driving license','PAN','Letter issued by the National Population Register'};
 
    public static String createApplicantKyc (String applicantId,String docSubType){ 
	     ApplKyc__c appKyc = new ApplKyc__c();
		 if(kycOcrList != null && kycOcrList.contains(docSubType)){
			 appKyc.Applicant__c = applicantId;
			 appKyc.kycDoc__c = docSubType;
			 try{
                insert appKyc; 
			 }catch(Exception ex) {
                throw new AuraHandledException(ex.getMessage());
             }
		 }else if(docSubType !='Photograph' ){
            appKyc.Applicant__c = applicantId;
            appKyc.kycDoc__c = 'Other';
            appKyc.OtherDocName__c = docSubType;
            try{
                insert appKyc; 
            }
            catch(Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            }
        }
        return appKyc.Id;
	}
    public static Map<String, String> createDocDetailAndAttchCV (String applicantId, String loanAppId, String docCategory, String docType, String docSubType, String appKycId, String cdId){ 
	    Map<String, String> insertedData = new Map<String, String>();
	    List<DocMstr__c> docMstrList = [SELECT id,Catgry__c,DocSubTyp__c,DocTyp__c FROM DocMstr__c 
                                        WHERE Catgry__c =: docCategory AND DocTyp__c =: docType AND DocSubTyp__c =:docSubType WITH SECURITY_ENFORCED];
        DocDtl__c   dd  = new DocDtl__c ();
        dd.Appl__c = applicantId != null ? applicantId : null;
        dd.DocMstr__c = docMstrList != null && !docMstrList.isEmpty() ? docMstrList[0].id : null;
        dd.DocCatgry__c = docCategory != null ? docCategory : null ;
        dd.DocSubTyp__c = docSubType != null ? docSubType : null ;
        dd.DocTyp__c = docType != null ? docType : null ; 
        dd.LAN__c = loanAppId != null ? loanAppId : null ;
        dd.Applicant_KYC__c = appKycId!= null ? appKycId : null;
        try{
            insert dd;
            ContentVersion  cont =[SELECT ContentDocumentId,ContentLocation, FirstPublishLocationId, Id,PathOnClient, 
			                       Title,VersionData FROM ContentVersion WHERE ContentDocumentId = :cdId];
			ContentVersion newcont = new ContentVersion();
			newcont.Title  = cont.Title;
			newcont.ContentLocation  = cont.ContentLocation;
			newcont.PathOnClient  = cont.PathOnClient;
			newcont.VersionData = cont.VersionData;
			newcont.FirstPublishLocationId  = dd.Id;
			//newcont.Content_Document_Id__c = cdId;
			insert newcont;
			dd.Content_Document_Id__c = cdId;
			update dd;
			insertedData.put(dd.Id, newcont.Id);
			return insertedData;
        }
        catch(Exception ex) {
            system.debug('message is ' + ex.getmessage() + ' line number is ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
	}

}