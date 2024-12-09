public class FetchFileToMerge {
	/*@AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPdfFilesWithIdsAsBase64(string AccountId) {
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId =: AccountId
        ];
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink cdl : contentDocumentLinks) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }
        
        List<ContentVersion> contentVersions = [
            SELECT ContentDocumentId, VersionData, CreatedDate
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds AND FileType=: 'PDF'
            ORDER BY CreatedDate DESC
        ];
        Map<Id, List<ContentVersion>> documentVersionsMap = new Map<Id, List<ContentVersion>>();
        for (ContentVersion version : contentVersions) {
            if (!documentVersionsMap.containsKey(version.ContentDocumentId)) {
                documentVersionsMap.put(version.ContentDocumentId, new List<ContentVersion>());
            }
            documentVersionsMap.get(version.ContentDocumentId).add(version);
        }
        List<Map<String, String>> pdfFilesWithIds = new List<Map<String, String>>();
        List<ContentVersion> allVersionsForQuote = new List<ContentVersion>();
                    for (ContentDocumentLink link : contentDocumentLinks) {
                        if (link.LinkedEntityId == AccountId && documentVersionsMap.containsKey(link.ContentDocumentId)) {
                            system.debug('in533333');
                            allVersionsForQuote.addAll(documentVersionsMap.get(link.ContentDocumentId));
                        }
                    }
                    allVersionsForQuote.sort();
                    
                    for (ContentVersion version : allVersionsForQuote) {
                        Map<String, String> pdfData = new Map<String, String>();
                        pdfData.put('ContentDocumentId', version.ContentDocumentId);
                        system.debug('pdfData'+pdfData);
                        pdfData.put('Base64Data', EncodingUtil.base64Encode(version.VersionData));
                        system.debug('pdfData2'+pdfData);
                        pdfFilesWithIds.add(pdfData);
                    }
        system.debug('pdfFilesWithIds'+pdfFilesWithIds);
        return pdfFilesWithIds;
    }*/
     /*@AuraEnabled(cacheable=true)
    public static String getRecordsId(String accId) {
        List<Id> lsOfCont = new List<Id>();
        List<ContentDocumentLink> lsOfCDL = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:accId];
        String idString='';
        for(integer i=0;i<lsOfCDL.size();i++){
            if(i == lsOfCDL.size()-1){
                idString+= lsOfCDL[i].ContentDocumentId;
            }else{
                idString+= lsOfCDL[i].ContentDocumentId + ',';
            }
            
        }
        System.debug('IDs are '+idString);
        return idString;
    }*/
    /*@AuraEnabled
    public static List<String> getData(String accountId){
        System.debug('ID is '+accountId);
        Map<String,String> mapOfData = new Map<String,String>();
        List<ContentDocumentLink> lsOfCDL = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:accountId];
        List<Id> tempsId =new List<Id>();
        for(ContentDocumentLink tempLoop:lsOfCDL){
            tempsId.add(tempLoop.ContentDocumentId);
        }
        List<ContentVersion> lsOfCV = [SELECT Id,VersionData,FileExtension FROM ContentVersion WHERE ContentDocumentId=:tempsId and FileExtension='pdf'];
        List<String> lsOfFiles = new  List<String>();
        for(ContentVersion tempLoopCv :lsOfCV){
            lsOfFiles.add(EncodingUtil.base64Encode(tempLoopCv.VersionData));
            System.debug('File Extension is  '+tempLoopCv.FileExtension);
            if((''+tempLoopCv.FileExtension).toLowerCase() == 'pdf'){
               mapOfData.put(''+tempLoopCv.Id+','+'PDF',EncodingUtil.base64Encode(tempLoopCv.VersionData));    
            }else{
                 mapOfData.put(''+tempLoopCv.Id+','+'PDF',EncodingUtil.base64Encode(tempLoopCv.VersionData));
            }
               
        }
        return lsOfFiles; 
    }*/
    @AuraEnabled
    public static String getContentDocumentId(Id contentVersionId) {
        ContentVersion contentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];
        return contentVersion.ContentDocumentId;
    }
    @AuraEnabled
    public static List<String> getDocPdfData(List<String> docDetailIds){
        System.debug('docDetailIds '+docDetailIds);
        Map<String,String> mapOfData = new Map<String,String>();
        List<ContentDocumentLink> lsOfCDL = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:docDetailIds];
        List<Id> tempsId =new List<Id>();
        for(ContentDocumentLink tempLoop:lsOfCDL){
            System.debug('tempLoop '+tempLoop.LinkedEntityId);
            tempsId.add(tempLoop.ContentDocumentId);
        }
        List<ContentVersion> lsOfCV = [SELECT Id,VersionData,FileExtension FROM ContentVersion WHERE ContentDocumentId=:tempsId and FileExtension='pdf' ORDER BY CreatedDate DESC];
        List<String> lsOfFiles = new  List<String>();
        for(ContentVersion tempLoopCv :lsOfCV){
            lsOfFiles.add(EncodingUtil.base64Encode(tempLoopCv.VersionData));
            System.debug('File Extension is  '+tempLoopCv.FileExtension);
            if((''+tempLoopCv.FileExtension).toLowerCase() == 'pdf'){
               mapOfData.put(''+tempLoopCv.Id+','+'PDF',EncodingUtil.base64Encode(tempLoopCv.VersionData));    
            }else{
                 mapOfData.put(''+tempLoopCv.Id+','+'PDF',EncodingUtil.base64Encode(tempLoopCv.VersionData));
            }
               
        }
        return lsOfFiles; 
    }
     @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> fetchAllDocs(string lanId){
        LoanAppl__c loanAppRec=[select id,SchemeId__c from LoanAppl__c where Id=:lanId];
        boolean isBt=False;
        if(loanAppRec.SchemeId__c !=null){
            string schemenId=loanAppRec.SchemeId__c;
            List<SchMapping__c> schemenRec=[select id, IsBT__c from SchMapping__c where Id =: schemenId];
            isBt = schemenRec.size()>0 ? schemenRec[0].IsBT__c: false;
        }
        
        Map<String, List<String>> documentTypesAndNames = new Map<String, List<String>>();
        documentTypesAndNames.put('Sanction Letter & KFS Document', new List<String>{'Physical-Signed Sanction Letter & KFS Document'});
        documentTypesAndNames.put('Loan Agreement & Related Annexure', new List<String>{'Physical-Signed Loan Agreement & Related Annexures'});
        documentTypesAndNames.put('DPN Document', new List<String>{'Physical-Signed DPN Document'});
        //documentTypesAndNames.put('Interest Bearing Letter', new List<String>{'Physical-Signed Interest Bearing Letter'});
        if(isBt && isBt==true){
            documentTypesAndNames.put('BT Draft Part 1', new List<String>{'Physical-Signed BT Draft Part 1'});
        	documentTypesAndNames.put('BT Draft Part 2', new List<String>{'Physical-Signed BT Draft Part 2'});
        }
        documentTypesAndNames.put('NACH Form', new List<String>{'Physical-Signed NACH Form'});
        documentTypesAndNames.put('Application Form', new List<String>{'Physical-Signed Application Form'});
        return documentTypesAndNames;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> fetchAllDocsforStamp(string lanId){
        LoanAppl__c loanAppRec=[select id,SchemeId__c from LoanAppl__c where Id=:lanId];
        Map<String, List<String>> documentTypesAndNames = new Map<String, List<String>>();
        documentTypesAndNames.put('Loan Agreement', new List<String>{'Physical-Stamped Loan Agreement'});
        documentTypesAndNames.put('Declaration of Loan Agreement', new List<String>{'Physical-Stamped Declaration of Loan Agreement'});
        documentTypesAndNames.put('Power Of Attonrny', new List<String>{'Physical-Stamped Power Of Attonrny'});
        return documentTypesAndNames;
    }
    @AuraEnabled
    public static List<string> checkAllESignStampDoc(string lanId){
        List<string> errors=new List<string>();
        string queryMain;
        LoanAppl__c loanAppRec=[select id,SchemeId__c from LoanAppl__c where Id=:lanId];
        boolean isBt=False;
        if(loanAppRec.SchemeId__c !=null){
            string schemenId=loanAppRec.SchemeId__c;
            List<SchMapping__c> schemenRec=[select id, IsBT__c from SchMapping__c where Id =: schemenId];
            isBt = schemenRec.size()>0 ? schemenRec[0].IsBT__c: false;
        }
        list<string> listOfDoc= new list<string>();
        list<string> reqListOfDoc= new list<string>();
       list<DocDtl__c> allDocList= [select id, DocSubTyp__c, IsLatest__c,Appl__c, LAN__c from DocDtl__c where LAN__c  =:lanId and IsLatest__c=true and IsDeleted__c =false];
       for(DocDtl__c doc: allDocList){
        	listOfDoc.add(doc.DocSubTyp__c);
       }
        if (isBt && isBt == true) {
    // Use addAll() to add multiple items to reqListOfDoc
            reqListOfDoc.addAll(new List<String>{
                'Stamped Loan Agreement', 
                'Physical-Signed Loan Agreement & Related Annexures', 
                'Physical-Signed Sanction Letter & KFS Document', 
                'Physical-Signed DPN Document', 
                'Physical-Signed BT Draft Part 2', 
                'Physical-Signed BT Draft Part 1', 
                'Physical-Signed NACH Form', 
                'Physical-Signed Application Form'
            });
        } else {
            reqListOfDoc.addAll(new List<String>{
                'Stamped Loan Agreement', 
                'Physical-Signed Loan Agreement & Related Annexures', 
                'Physical-Signed Sanction Letter & KFS Document', 
                'Physical-Signed DPN Document', 
                'Physical-Signed NACH Form', 
                'Physical-Signed Application Form'
            });
        }
        for(string DocName: reqListOfDoc){
            if(!listOfDoc.contains(DocName)){
                errors.Add('Please Upload '+DocName);
            }
        }
       

        return errors;
    }
    /*
     Type__c  IN ('','Account Analysis') AND SubType__c  IN ('','Monthly Details') 
    */
}