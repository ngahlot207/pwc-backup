public without sharing class LeadDocumentUploadFromFlow {
        
    
    @InvocableMethod 
    public static void collectAllContentDataFromLead(list<list<String>> listOfParameters){
        system.debug('listOfParameters from flow tab'+listOfParameters);
        list<String> applicantIdlist = listOfParameters[0];
        list<String> loanAppIdlist = listOfParameters[0];
        list<String> leadIdlist = listOfParameters[0];
        list<String> booleanPhysicalConsent = listOfParameters[0];
        
        String loanAppId = loanAppIdlist[0];
        String applicantId = applicantIdlist[1];
        String leadId = leadIdlist[2];
        Boolean isPhysicalConsent = Boolean.valueOf(booleanPhysicalConsent[3]);
        
        
        
        if(!String.isBlank(leadId)){
            createAndAttachDocumentDetail(applicantId, loanAppId, leadId, isPhysicalConsent);
        }
    }
    
    public static void createAndAttachDocumentDetail(String applicantId,String loanAppId,string leadId, Boolean physicalConsent){
                
        List<ContentVersion>  contList = new List<ContentVersion>();
        contList = [SELECT ContentDocumentId, Document_Category__c, Document_Name__c, ContentLocation, PathOnClient, Title, VersionData, 
                    Document_Type__c, FirstPublishLocationId, Id FROM ContentVersion WHERE FirstPublishLocationId = :leadId ];
        
        system.debug('Pratap 1 '+contList);
        Map<string,list<string>> docMap= new Map<string,list<string>>();
        Map<String, ContentVersion> contentVersionMap= new Map<String, ContentVersion>();
        
        List<ApplKyc__c> appKycRecordList = new List<ApplKyc__c>();
        Map<String,String> appKycMap= new Map<String,String>();
        Map<String,String> docMstrMap= new Map<String,String>();
        List<DocDtl__c> docDtlRecordList = new List<DocDtl__c>();
        List<DocDtl__c> docDtlRecordListPhyConst = new List<DocDtl__c>();
        List<ContentVersion> newConVersList = new List<ContentVersion>();
        List<ContentDocumentLink > newConDocLinkList = new List<ContentDocumentLink >();
        List<IntgMsg__c> newIntgMsgList = new List<IntgMsg__c>();
        List<Id> physicalConsentContentDocIds = new List<Id>();
        
        for(ContentVersion cv : contList){
            if(cv.Document_Name__c == null && cv.Document_Category__c == null && cv.Document_Type__c == null && physicalConsent){
                physicalConsentContentDocIds.add(cv.ContentDocumentId);
            }else{
                list<string> allDataValue = new list<string>();
                allDataValue.add(cv.Document_Category__c);
                allDataValue.add(cv.Document_Type__c);
                allDataValue.add(cv.Document_Name__c);
                allDataValue.add(cv.ContentDocumentId);
                //docMap.put(cv.Document_Name__c , allDataValue);
                string allDatakey=cv.Document_Name__c+'-'+cv.Document_Type__c;
                docMap.put(allDatakey , allDataValue);
                contentVersionMap.put(cv.ContentDocumentId, cv);
            }
        }
        

        if(!physicalConsentContentDocIds.isEmpty()){
            for(Id phyDD : physicalConsentContentDocIds){
                DocDtl__c   dd  = new DocDtl__c ();
                dd.Appl__c = !String.isEmpty(applicantId) ? applicantId : null;
                dd.Content_Document_Id__c = phyDD;
                dd.DocCatgry__c = 'Verification Documents';
                dd.DocMstr__c = docMstrMap.containsKey('Physical Consent') ? docMstrMap.get('Physical Consent') : null;
                dd.DocSubTyp__c = 'Physical Consent Form';
                dd.DocTyp__c = 'Physical Consent Proof'; 
                dd.LAN__c = !String.isEmpty(loanAppId) ? loanAppId : null ;
                docDtlRecordListPhyConst.add(dd);
            }
        }
        
        for(string docsSubType :docMap.keyset()){
            String AppKycSubTypeValue=docsSubType.subString(0,docsSubType.indexof('-'));
            ApplKyc__c appKycHashRecord = formApplicantKYCRecord(applicantId,AppKycSubTypeValue);
            appKycRecordList.add(appKycHashRecord);
        }
        
        if(!appKycRecordList.isEmpty()){
            try{
                insert appKycRecordList; 
            }
            catch(Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            }
            for(ApplKyc__c app: appKycRecordList){
                // kycDoc__c will hold the Doc Sub Type value
               // appKycMap.put(app.kycDoc__c, app.Id);
                if(app.kycDoc__c!='Other'){
                    appKycMap.put(app.kycDoc__c, app.Id);
                }
                else{
                    appKycMap.put(app.OtherDocName__c, app.Id);
                }
            }
            
            List<DocMstr__c> docMstrList = [SELECT id,Catgry__c,DocSubTyp__c,DocTyp__c, Prod__c FROM DocMstr__c 
                                            WHERE Catgry__c != null AND DocSubTyp__c != null 
                                            //WITH SECURITY_ENFORCED 
                                            order by lastmodifieddate desc];
            system.debug('Pratap 1 docMstrList'+docMstrList);
            for(DocMstr__c dcM : docMstrList){
                if(!docMstrMap.containsKey(dcM.DocSubTyp__c)){
                    string ddkey=dcM.DocSubTyp__c+'-'+dcM.DocTyp__c;
                    //docMstrMap.put(dcM.DocSubTyp__c , dcM.Id);
                    docMstrMap.put(ddkey , dcM.Id);
                }
            }
            
                        
            for(String docsSubType :docMap.keyset()){
                List<string> docDataList = docMap.get(docsSubType);
                String AppKycSubType=docsSubType.subString(0,docsSubType.indexof('-'));
               // String appKyRecordId = appKycMap.get(docsSubType);
                String appKyRecordId = appKycMap.get(AppKycSubType);
                String docMstrRecordId = docMstrMap.get(docsSubType);
                system.debug('appKyRecordId'+appKyRecordId);
                 system.debug('docMstrRecordId'+docMstrRecordId);
                
                if(!String.isEmpty(appKyRecordId)){
                    DocDtl__c dd  = new DocDtl__c ();
                    dd.Appl__c = !String.isEmpty(applicantId) ? applicantId : null;
                    dd.DocMstr__c = !String.isEmpty(docMstrRecordId) ? docMstrRecordId : null;
                    dd.DocCatgry__c = !String.isEmpty(docDataList[0]) ? docDataList[0] : null ;
                    dd.DocTyp__c = !String.isEmpty(docDataList[1]) ? docDataList[1] : null ; 
                  //  dd.DocSubTyp__c = docsSubType != null ? docsSubType : null ;
                    dd.DocSubTyp__c = AppKycSubType != null ? AppKycSubType : null ;
                    dd.LAN__c = !String.isEmpty(loanAppId) ? loanAppId : null ;
                    dd.Applicant_KYC__c = !String.isEmpty(appKyRecordId) ? appKyRecordId : null;
                    dd.Is_Generated_from_Lead_Flow__c = true;
                    dd.Content_Document_Id__c = !String.isEmpty(docDataList[3]) ? docDataList[3] : null;
                    
                    //if(!String.isEmpty(docsSubType) && (docsSubType == 'Passport' || docsSubType == 'Voter ID' || docsSubType == 'Driving License' || docsSubType == 'PAN')){
                   if(!String.isEmpty(AppKycSubType) && (AppKycSubType == 'Passport' || AppKycSubType == 'Voter ID' || AppKycSubType == 'Driving License' || AppKycSubType == 'PAN')){
                            
                    dd.Is_Ready_for_KYC_Validations__c = true;
                    }
                    
                    docDtlRecordList.add(dd);
                }
                
            }
            system.debug('Pratap 1 docDtlRecordList'+docDtlRecordList);
            
            if(!docDtlRecordList.isEmpty()){
                try{
                    insert docDtlRecordList; 
                }
                catch(Exception ex) {
                    throw new AuraHandledException(ex.getMessage());
                }
                
                for(DocDtl__c ddRecord: docDtlRecordList){
                    ContentVersion newcont = new ContentVersion();
                    newcont.Title  = contentVersionMap.get(ddRecord.Content_Document_Id__c).Title;
                    newcont.ContentLocation  = contentVersionMap.get(ddRecord.Content_Document_Id__c).ContentLocation;
                    newcont.PathOnClient  = contentVersionMap.get(ddRecord.Content_Document_Id__c).PathOnClient;
                    newcont.VersionData = contentVersionMap.get(ddRecord.Content_Document_Id__c).VersionData;
                    newcont.FirstPublishLocationId  = ddRecord.Id;
                    newConVersList.add(newcont);
                    if(ddRecord.Is_Ready_for_KYC_Validations__c){
                        IntgMsg__c hasIntMsgData = formOCRIntegrationMessage('KYC OCR', ddRecord.Applicant_KYC__c, ddRecord.Id);
                        newIntgMsgList.add(hasIntMsgData);
                    }
                }
            }
            
            
            
            if(!newConVersList.isEmpty()){
                try{
                    insert newConVersList; 
                }
                catch(Exception ex) {
                    throw new AuraHandledException(ex.getMessage());
                }
            }
            
            
            if(!newIntgMsgList.isEmpty()){
                try{
                    insert newIntgMsgList; 
                }
                catch(Exception ex) {
                    throw new AuraHandledException(ex.getMessage());
                }
            }
            
        }
        
        if(!docDtlRecordListPhyConst.isEmpty()){
            try{
                insert docDtlRecordListPhyConst; 
            }
            catch(Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            }
            
            for(DocDtl__c ddRecordPhy: docDtlRecordListPhyConst){
                ContentDocumentLink cdL = new ContentDocumentLink();
                cdL.ContentDocumentId = ddRecordPhy.Content_Document_Id__c;
                cdL.LinkedEntityId = ddRecordPhy.Id;
                cdL.ShareType = 'V';
                cdL.Visibility = 'AllUsers';
                newConDocLinkList.add(cdL);
            }
            
            if(!newConDocLinkList.isEmpty()){
                try{
                    insert newConDocLinkList; 
                }
                catch(Exception ex) {
                    throw new AuraHandledException(ex.getMessage());
                }
            }
                        
        }        
    } 
    
    
    public static ApplKyc__c formApplicantKYCRecord (String applicantId,String docSubType){ 
        ApplKyc__c appKyc = new ApplKyc__c();
        if(!String.isEmpty(docSubType) && (docSubType =='Shop and Establishment'||docSubType == 'Electricity Bill' ||docSubType == 'Passport' || docSubType == 'Voter ID' || docSubType == 'Driving License' || docSubType == 'PAN' || docSubType == 'Letter issued by the National Population Register')){
            appKyc.Applicant__c = applicantId;
            appKyc.kycDoc__c = docSubType;
        }
        else{
            appKyc.Applicant__c = applicantId;
            appKyc.kycDoc__c = 'Other';
            appKyc.OtherDocName__c = docSubType;
        }
        return appKyc;
    }
    
    public static IntgMsg__c formOCRIntegrationMessage(String serviceName, String kycId, String ddId){
        IntgMsg__c im = new IntgMsg__c();
        im.Name = serviceName; 
        im.BU__c = 'HL / STL';
        im.IsActive__c = true;
        im.SVC__c = serviceName; 
        im.ExecType__c = 'Async';
        im.Status__c = 'New';
        im.DocApi__c = true;
        im.Outbound__c = true;
        im.Trigger_Platform_Event__c = true;
        im.RefObj__c = 'DocDtl__c';
        im.RefId__c = ddId;
        im.ParentRefObj__c = 'ApplKyc__c';
        im.ParentRefId__c = kycId;
        return im;
    }
}