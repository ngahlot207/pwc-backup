public without sharing class DocumentDetailController {
    
    public static List<String> kycOcrList = new List<String>{'Passport','Aadhaar','Voter ID','Driving license','PAN','Letter issued by the National Population Register','Udyam Registration Certificate','Shop and Establishment','Electricity Bill'};
        
        @AuraEnabled
        public static Map<String,Map<String,List<String>>> findRequiredDoc(String applicantId,String loanAppId,String productType,String stage,String subStage){
            try{
                Map<String,Map<String,List<String>>>  retVal = DocumentEngine.fetchAllRequiredDocs(applicantId,loanAppId,productType,stage,subStage);
                system.debug('retVal' + retVal);
                return retVal;
            }
            catch(Exception ex) {
                system.debug('message is '+ ex.getMessage() + ' Line: ' + ex.getLineNumber());
                GlobalUtility.logMessage(
                    'Error',
                    'class name :: DocumentDetailController and method names is :: findRequiredDoc' +
                    ex.getLineNumber(),
                    'Generate',
                    null,
                    null,
                    ex.getMessage() + ' Line: ' + ex.getLineNumber(),
                    null,
                    ex,
                    null
                );
                throw new AuraHandledException(ex.getMessage());
            }
            
            
        }
    @AuraEnabled
    
    public static string  createDocumentDetail(String applicantId, String loanAppId, string docCategory, string docType,string docSubType,Boolean availableInFile){
        String DocId = createDocDetailwithApplicantAsset( applicantId,  loanAppId,  docCategory,  docType, docSubType, availableInFile,null);
        return DocId;
    }
    
    
    
    @AuraEnabled
    public static string  createDocDetailwithApplicantAsset(String applicantId, String loanAppId, string docCategory, string docType,string docSubType,Boolean availableInFile,String applicantAssetId){
        system.debug('createDocDetailwithApplicantAsset>>');
        List<DocMstr__c> docMstrList = new List<DocMstr__c> ();  
        if(docType == 'Other Income Documents' || docType == 'Additional documents'){ 
            docMstrList = [SELECT id,Catgry__c,DocSubTyp__c,DocTyp__c FROM DocMstr__c 
                           WHERE Catgry__c =: docCategory AND DocTyp__c =: docType WITH SECURITY_ENFORCED];
        }else{ 
            docMstrList = [SELECT id,Catgry__c,DocSubTyp__c,DocTyp__c FROM DocMstr__c 
                           WHERE Catgry__c =: docCategory AND DocTyp__c =: docType AND DocSubTyp__c =:docSubType WITH SECURITY_ENFORCED];
        }
        LoanAppl__c loanRecord = [SELECT Id, Stage__c FROM LoanAppl__c WHERE Id =: loanAppId WITH SECURITY_ENFORCED];
        system.debug('docMstrList#50'+docMstrList);
        DocDtl__c   dd  = new DocDtl__c ();   
        dd.Appl__c = applicantId != null ? applicantId : null;   
        dd.DocMstr__c = docMstrList != null && !docMstrList.isEmpty() ? docMstrList[0].id : null;   
        dd.DocCatgry__c = docCategory != null ? docCategory : null ;   
        dd.DocSubTyp__c = docSubType != null ? docSubType : null ;   
        dd.DocTyp__c = docType != null ? docType : null ;   
        dd.LAN__c = loanAppId != null ? loanAppId : null ;   
        if(applicantAssetId != null && applicantAssetId != ''){   
            dd.ApplAsset__c = applicantAssetId;  
        } 
        dd.FileAvalbl__c = availableInFile ; 
        dd.SanctionStage__c = (loanRecord.Stage__c == 'QDE' || loanRecord.Stage__c == 'DDE' || loanRecord.Stage__c == 'UnderWriting' ) ? 'pre sanction' : 'post sanction';
        // if(loanRecord.Stage__c === 'QDE' || loanRecord.Stage__c === 'DDE' || loanRecord.Stage__c === 'UnderWriting' ){
        //     dd.SanctionStage__c='pre sanction';
        // }
        try{
            insert dd;
            return dd.id;
        }
        catch(Exception ex) {
            system.debug('ex#67'+ ex.getMessage()+'ex line number'+ ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }  
    }
    
    @AuraEnabled
    public static String createApplicantKyc(String applicantId,String docSubType){   
        ApplKyc__c appKyc = new ApplKyc__c();
        if(kycOcrList.contains(docSubType)){
            appKyc.Applicant__c = applicantId;
            appKyc.kycDoc__c = docSubType;
            try{
                insert appKyc; 
                
            }
            catch(Exception ex) {
                system.debug('message is ' + ex.getmessage() + ' line number is ' + ex.getLineNumber());
                throw new AuraHandledException(ex.getMessage());
            }
        }
        else if(docSubType !='Photograph' ){
            appKyc.Applicant__c = applicantId;
            appKyc.kycDoc__c = 'Other';
            appKyc.OtherDocName__c = docSubType;
            try{
                insert appKyc; 
                
            }
            catch(Exception ex) {
                system.debug('message is ' + ex.getmessage() + ' line number is ' + ex.getLineNumber());
                throw new AuraHandledException(ex.getMessage());
            }
        }
        return appKyc.Id;
    }
    @AuraEnabled
    public static string  createDocDetail(String applicantId, String loanAppId, string docCategory, string docType,string docSubType,Boolean availableInFile,String appKycId){
        system.debug('createDocDetail');
        LoanAppl__c loanRecord = [SELECT Id, Stage__c FROM LoanAppl__c WHERE Id =: loanAppId WITH SECURITY_ENFORCED];
        List<DocMstr__c> docMstrList = [SELECT id,Catgry__c,DocSubTyp__c,DocTyp__c FROM DocMstr__c 
                                        WHERE Catgry__c =: docCategory AND DocTyp__c =: docType AND DocSubTyp__c =:docSubType WITH SECURITY_ENFORCED];
        DocDtl__c   dd  = new DocDtl__c ();
        dd.Appl__c = applicantId != null ? applicantId : null;
        dd.DocMstr__c = docMstrList != null && !docMstrList.isEmpty() ? docMstrList[0].id : null;
        dd.DocCatgry__c = docCategory != null ? docCategory : null ;
        dd.DocSubTyp__c = docSubType != null ? docSubType : null ;
        dd.DocTyp__c = docType != null ? docType : null ; 
        dd.LAN__c = loanAppId != null ? loanAppId : null ;
        dd.FileAvalbl__c = availableInFile ;
        dd.Applicant_KYC__c = appKycId!= null ? appKycId : null;
        dd.SanctionStage__c = (loanRecord.Stage__c == 'QDE' || loanRecord.Stage__c == 'DDE' || loanRecord.Stage__c == 'UnderWriting' ) ? 'pre sanction' : 'post sanction';
        try{
            insert dd;
            return dd.id;
        }
        catch(Exception ex) {
            system.debug('message is ' + ex.getmessage() + ' line number is ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }  
    
    @AuraEnabled
    public static resultWrp createAppkycDd(String applicantId,String loanAppId,string docCategory, string docType,string docSubType){
        String ddId = null;
        resultWrp wrp = new resultWrp();
        try{
            List<ApplKyc__c> applKycList = [SELECT Id, Applicant__c, kycDoc__c FROM ApplKyc__c WHERE Applicant__c = : applicantId AND kycDoc__c =: docSubType];
            if(applKycList != null && !applKycList.isEmpty()){ 
                ddId = createDocDetail(applicantId,  loanAppId,  docCategory,  docType, docSubType, false,applKycList[0].id);
                wrp.appKycId = applKycList[0].id;
            }else{
                String appKycId = createApplicantKyc(applicantId,docSubType);
                wrp.appKycId = appKycId;
                ddId = createDocDetail(applicantId,  loanAppId,  docCategory,  docType, docSubType, false,appKycId);
            }
            wrp.docDetId = ddId;
            
            
        }catch(exception e){
            system.debug('error message is ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return wrp;
    } 
    
    @AuraEnabled
    public static resultWrp addAppkycDd(String applicantId,String loanAppId,string docCategory, string docType,string docSubType,string linkedEntityId){
        String ddId = null;
        resultWrp wrp = new resultWrp();
        try{
            List<ApplKyc__c> applKycList = [SELECT Id, Applicant__c, kycDoc__c
                                            FROM ApplKyc__c 
                                            WHERE Applicant__c = : applicantId 
                                            AND kycDoc__c =: docSubType];
            if(applKycList != null && !applKycList.isEmpty()){ 
                ddId = createDocDetail(applicantId,  loanAppId,  docCategory,  docType, docSubType, false,applKycList[0].id);
                wrp.appKycId = applKycList[0].id;
            }else{
                String appKycId = createApplicantKyc(applicantId,docSubType);
                wrp.appKycId = appKycId;
                ddId = createDocDetail(applicantId,  loanAppId,  docCategory,  docType, docSubType, false,appKycId);
            }
            
            List<ContentDocumentLink> dduploaded = new List<ContentDocumentLink>();
            if(linkedEntityId != null){
                dduploaded = [SELECT LinkedEntityId,ContentDocumentId
                              FROM ContentDocumentLink  
                              WHERE LinkedEntityId  =:linkedEntityId WITH SECURITY_ENFORCED];
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = dduploaded[0].ContentDocumentId;
                cdl.LinkedEntityId= ddId;// document detail id of new record
                cdl.ShareType='V';
                insert cdl;
            }
            
            
            wrp.docDetId = ddId;
            
            
        }catch(exception e){
            system.debug('error message is ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return wrp;
    } 
    @AuraEnabled
    public static List<String> evaluateAllRequiredRecords(String applicantId,String loanAppId,String productType,String stage,String subStage,List<String> categoriesList){
        try {
            // Map<String,List<String>> resMap = new  Map<String,List<String>>();
            DocumentEngine docEng = new DocumentEngine(loanAppId);
            list<string> res =  new list<string>();
            system.debug(' documentEngine Input vall  ' + applicantId+' :: '+loanAppId+' :: '+ productType+' :: '+ stage+' :: '+subStage+' :: '+ categoriesList);
            List<String> errors = DocumentEngineController.evalAllRequiredDocs(docEng,applicantId,loanAppId,productType,stage,subStage,categoriesList);
            list<Applicant__c> appList =  new list<Applicant__c>();
            Applicant__c app =  new Applicant__c();
            app.Id = applicantId;
            appList.add(app);
            Map<string, string > panError  = checkPanNoStatus(appList);
            
            if(!panError.isEmpty()){
                for (string err : panError.values()) {
                    errors.add(err);
                }
            }
            //   integer num = 0;
            //   for(string err : errors){
            
            //     List<string> errorList = new List<string>();
            //     errorList.add(err);
            //     resMap.put('neww ERROR ' + num,errorList);
            //     num++;
            //   } 
            // resMap= DocumentEngine.evalAllRequiredDocsAdd(applicantId, loanAppId, productType, stage, subStage, categoriesList);
            system.debug(' documentEngine Result ' + errors);
            return errors;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void deleteDocDetWithCdl(String docDtlId){
        try {
            List<DocDtl__c> documentDtlList = new List<DocDtl__c> ();
            List<ContentDocumentLink> dduploaded = new List<ContentDocumentLink>();
            List<sObject> sObjectsToDelete = new List<sObject>(); 
            if(docDtlId != null){
                documentDtlList = [SELECT Id,DocSubTyp__c,DocTyp__c,Applicant_KYC__r.Id,IsDeleted__c, DeletedBy__c, DelDateTime__c,RCUInitiated__c FROM DocDtl__c where Id =: docDtlId LIMIT 1];// LAK-162
                //sObjectsToDelete.add(documentDtlList[0]);
            }
            if (docDtlId != null) {
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
                    WHERE LinkedEntityId =:docDtlId
                ];
            }
            for (ContentDocumentLink cdLink : dduploaded) {
                //  contentDocLinkMap.put(cdLink.LinkedEntityId, cdLink);
                sObjectsToDelete.add(cdLink);
            }
            if(sObjectsToDelete != null && sObjectsToDelete.size() > 0){
                system.debug('sObjectsToDelete ' + sObjectsToDelete);
                system.debug('sObjectsToDelete size is '+ sObjectsToDelete.size());
                delete sObjectsToDelete;
            } 
            
            if(documentDtlList[0].Applicant_KYC__r != null && documentDtlList[0].Applicant_KYC__r.size() > 0){    
                List<DocDtl__c> documentDtlListNew = [SELECT Id,DocSubTyp__c,DocTyp__c,Applicant_KYC__r.Id , IsDeleted__c, DeletedBy__c, DelDateTime__c,RCUInitiated__c FROM DocDtl__c where Applicant_KYC__r.Id =: documentDtlList[0].Applicant_KYC__r.Id ]; 
                if(documentDtlListNew != null && documentDtlListNew.size() == 1){ // LAK-162
                   if(documentDtlListNew[0].RCUInitiated__c != true){
                    delete documentDtlList[0].Applicant_KYC__r;
                   }else{
                    documentDtlList[0].IsDeleted__c = true;
                    documentDtlList[0].DelDateTime__c = system.now();
                    documentDtlList[0].DeletedBy__c = UserInfo.getUserName();
                    update documentDtlList[0];
                   }
                    
                }       // LAK-162  
            } 
            if(documentDtlList != null && documentDtlList.size() > 0){
                updateApplicant(documentDtlList);// to delete   docId And Doc name from Applicant
      
                    if(documentDtlList[0].RCUInitiated__c != true){// LAK-162
                     delete documentDtlList[0];
                    }else{
                     documentDtlList[0].IsDeleted__c = true;
                     documentDtlList[0].DelDateTime__c = system.now();
                     documentDtlList[0].DeletedBy__c =UserInfo.getUserName();
                     update documentDtlList[0];
                    } // LAK-162
                     
                  
              //  delete documentDtlList[0];
            }
        } catch (Exception e) {
            system.debug(e.getMessage()+e.getLineNumber());
            throw new AuraHandledException('DELET DOCUMENT METHOD:::'+e.getMessage()+e.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static void deleteDocDetWithCdlToNdc(String docDtlId){
        try {
            List<ContentDocumentLink> dduploaded = new List<ContentDocumentLink>();
            List<sObject> sObjectsToDelete = new List<sObject>(); 
            if (docDtlId != null) {
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
                    WHERE LinkedEntityId =:docDtlId
                ];
            }
            for (ContentDocumentLink cdLink : dduploaded) {
                //  contentDocLinkMap.put(cdLink.LinkedEntityId, cdLink);
                sObjectsToDelete.add(cdLink);
            }
            if(sObjectsToDelete != null && sObjectsToDelete.size() > 0){
                system.debug('sObjectsToDelete ' + sObjectsToDelete);
                system.debug('sObjectsToDelete size is '+ sObjectsToDelete.size());
                delete sObjectsToDelete;
            }        
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static void  updateApplicant(list<DocDtl__c> ddList){
        try {
            set<Id>  ddSet = new set<Id>();
            map<Id,Applicant__c> applicantMap = new  map<Id,Applicant__c>();  
            list<Applicant__c>  appList = new list<Applicant__c>();
            if(!ddList.isEmpty()){
                for(DocDtl__c doc: ddList){ 
                    ddset.add(doc.Id);              
                }
            }  
           
            if(ddset.size()>0){             
                for(DocDtl__c ddt : [SELECT id ,DocTyp__c,DocSubTyp__c,  Appl__c, Appl__r.ID_Number__c, Appl__r.ID_proof_type__c,Appl__r.PAN__c  from DocDtl__c where  Id IN: ddset AND (DocTyp__c ='Identity Proof' OR DocSubTyp__c  ='PAN'  )]){
                    Applicant__c  applicant = new Applicant__c();  
                    applicant.Id = ddt.Appl__c;
                    if(ddt.DocTyp__c =='Identity Proof'){
                        applicant.Id = ddt.Appl__c;
                        applicant.ID_Number__c ='';
                        applicant.ID_proof_type__c ='';
                        
                    }  
                    if(ddt.DocSubTyp__c  =='PAN'){
                        System.debug('clearing PAN Number ' + ddt.Appl__c + ddt.Appl__r.PAN__c);
                        DocumentDetailController.deleteAppGstAndApiVerf(ddt.Appl__c , ddt.Appl__r.PAN__c);// https://fedfina.atlassian.net/browse/LAK-9296
                        applicant.PAN__c ='';
                    }              
                    appList.add(applicant);     
                }
                if(appList.size()>0){
                    Update appList;           
                }   
            } 
         
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static void deleteAppGstAndApiVerf(string appId, string panNo){
        //SELECT Id, Applicant__c,  Pan__c  FROM ApplGST__c  WHERE Pan__c !=null  AND Applicant__c := 
        System.debug( 'appId == '+  appId +'  panNo ==  '  +  panNo);
        List<ApplGST__c> appGstList = new List<ApplGST__c>();
        appGstList = [SELECT Id, Applicant__c,  Pan__c  FROM ApplGST__c  WHERE Pan__c !=null AND  Pan__c =: panNo AND Applicant__c =: appId ];
        if(appGstList.size()>0){
            delete appGstList;
        }
        List<APIVer__c> apiVerList = new List<APIVer__c>();
        apiVerList = [SELECT Id, RecordTypeId, RecordType.name ,Pan__c, IsLatest__c,Appl__c  FROM APIVer__c  WHERE RecordType.Name = 'GST' AND IsLatest__c =true  AND Appl__c =:appId AND Pan__c != null AND Pan__c =: panNo ];
        List<APIVer__c> apiVerListToUpdate = new List<APIVer__c>();
        if(apiVerList.size()>0){       
           for (APIVer__c apiVer : apiVerList) {
                apiVer.IsLatest__c = false;
                apiVerListToUpdate.add(apiVer);
           }        
          update apiVerListToUpdate; 
        }
    }
    
    @AuraEnabled
    public static boolean checkDuplicateDoc(string loanId ,string appKycId, string docId, string docType, string applId){
        system.debug('aadharValidate::::'+docType +'ap.AadharNo__c:::'+'DOC ID::::'+docId+'docType:::::'+docType);
        boolean duplicateExist = false;
        try{
            if(loanId != null){
                map<Id,ApplKyc__c> appKycMap=new map<Id,ApplKyc__c>([SELECT id, AadharNo__c, Pan__c, VotIdEpicNo__c, DLNo__c, PassNo__c,AadharEncripted__c,KycDocNo__c,
                                                                     kycDoc__c,Applicant__r.LoanAppln__c,Applicant__r.Constitution__c,
                                                                     (SELECT id,Name,DocTyp__c, DocSubTyp__c, RCUInitiated__c, isDeleted__c FROM Document_Details__r  WHERE IsDeleted__c = false) 
                                                                     FROM ApplKyc__c
                                                                     where Applicant__r.LoanAppln__c =:loanId]);
                system.debug('appKycMap:'+appKycMap);
                list<ApplicantEmployment__c> applEmpList = [select id,LoanApplicant__c,DesignationValues__c from ApplicantEmployment__c where LoanApplicant__r.LoanAppln__c =:loanId AND DesignationValues__c != null];
                Map<Id,ApplicantEmployment__c > appEmplMap = new Map<Id,ApplicantEmployment__c>();   
                string constitutionOld;
                string constitutionNew;
                string designationOld;
                string designationNew;
                if(!applEmpList.isEmpty()){
                    for(ApplicantEmployment__c appEmp : applEmpList){
                        appEmplMap.put(appEmp.LoanApplicant__c,appEmp);
                    } 
                }
                
                if(appKycId != null && docId == null){          
                    if(!appKycMap.isEmpty()){
                        for(ApplKyc__c ap : appKycMap.values()){
                            if(appKycMap.get(appKycId).kycDoc__c != 'Aadhaar'){
                                system.debug('Enter In addhr');
                                if(setChar(ap.KycDocNo__c) == setChar(appKycMap.get(appKycId).KycDocNo__c) && ap.Id != appKycId){
                                    system.debug('appKycMap::::346'+appKycMap+'appKycMap.get(appKycId).kycDoc__c'+appKycMap.get(appKycId).kycDoc__c);
                                    if(appKycMap.get(appKycId).kycDoc__c == 'Pan'){
                                        constitutionOld= ap.Applicant__r.Constitution__c;
                                        constitutionNew = appKycMap.get(appKycId).Applicant__r.Constitution__c;
                                        
                                        if(appEmplMap.get(ap.Applicant__c) != null){
                                            designationOld = appEmplMap.get(ap.Applicant__c).DesignationValues__c;
                                        }
                                        
                                        if(appEmplMap.get(appKycMap.get(appKycId).Applicant__c) != null){
                                            designationNew = appEmplMap.get(appKycMap.get(appKycId).Applicant__c).DesignationValues__c;
                                        }
                                        boolean checkdes= checkDesignation(appKycMap.get(appKycId),appKycId,constitutionOld,constitutionNew,designationOld,designationNew);
                                        return checkdes;
                                        
                                    }else{
                                        handleDuplicate(appKycMap.get(appKycId),appKycId);
                                        return true;
                                    }
                                    
                                    
                                }
                            }
                            else if(ap.AadharEncripted__c != null && ap.AadharEncripted__c == appKycMap.get(appKycId).AadharEncripted__c && ap.Id != appKycId){
                                handleDuplicate(appKycMap.get(appKycId),appKycId);
                                return true;
                            }
                            
                        }
                        
                    }                
                }
                else if(docId != null && appKycId == null && applId != null){
                    list<Applicant__c> appList =[select id,Constitution__c from Applicant__c where id =:applId limit 1];
                    list<ApplicantEmployment__c> empList = [select id,LoanApplicant__c,DesignationValues__c from ApplicantEmployment__c where LoanApplicant__c =:applId AND DesignationValues__c != null];
                    if(!appKycMap.isEmpty()){
                        for(ApplKyc__c ap : appKycMap.values()){
                            if(docType != 'aadharValidate'){
                                if(setChar(ap.KycDocNo__c) == setChar(docId)){
                                    if(docType == 'panValidate'){
                                        constitutionOld= ap.Applicant__r.Constitution__c;
                                        if(!appList.isEmpty()){
                                            constitutionNew = appList[0].Constitution__c;
                                        }                                       
                                        
                                        if(appEmplMap.get(ap.Applicant__c) != null){
                                            designationOld = appEmplMap.get(ap.Applicant__c).DesignationValues__c;
                                        }
                                        
                                        if(!empList.isEmpty()){
                                            designationNew = empList[0].DesignationValues__c;
                                        }
                                        boolean checkdes= checkDesignation(appKycMap.get(appKycId),appKycId,constitutionOld,constitutionNew,designationOld,designationNew);
                                        return checkdes;
                                    }else{
                                        return true;
                                    }
                                    
                                }
                                
                            }else if(ap.AadharEncripted__c == docId){
                                return true;
                            }
                            
                        }  
                    }   
                }
            } 
            
            return false;
        }catch(exception e){
            system.debug('Error'+e.getmessage());
            throw new AuraHandledException(e.getMessage()+e.getLineNumber());
        }
    }
    
    public static boolean checkDesignation(ApplKyc__c ap,string appKycId,string constitutionOld, string constitutionNew, string designationOld, string designationNew){
        if(constitutionOld == 'INDIVIDUAL' &&  constitutionNew == 'INDIVIDUAL'  ){
            if(designationOld == null && designationNew == null){
                if(appKycId !=null){
                    handleDuplicate(ap,appKycId);
                }
                return true;
            }else if(designationOld != 'PROPRIETOR' && designationNew != 'PROPRIETOR'){
                if(appKycId !=null){
                    handleDuplicate(ap,appKycId);
                }
                return true;
            }else if(designationOld == null && designationNew != 'PROPRIETOR'){
                if(appKycId !=null){
                    handleDuplicate(ap,appKycId);
                }
                return true;
            }else if(designationOld != 'PROPRIETOR' && designationNew == null){
                if(appKycId !=null){
                    handleDuplicate(ap,appKycId);
                }
                return true;
            }
            
        } 
        
        return false;
    }
    private static void handleDuplicate(ApplKyc__c ap, Id appKycId){
        if(ap.Document_Details__r[0].Id != null){
            deleteDocDetWithCdl(ap.Document_Details__r[0].Id);
            
        }
        
    }
    public static string setChar(string character){
        String pattern = '[^a-zA-Z0-9]'; // Allow letters and digits
        string result = null;
        if(character != null){
            result= character.replaceAll(pattern, '');
        }
        return result;
    }
    
    public static list <ValidateRequiredFieldsAndDoc.Responce> findDuplicateDocs(string loanId) {
        list <ValidateRequiredFieldsAndDoc.Responce> respObjList = new list <ValidateRequiredFieldsAndDoc.Responce>();
        list<ApplKyc__c> appKycList=new list<ApplKyc__c>([select id, AadharNo__c,Applicant__r.FullName__c, Pan__c, VotIdEpicNo__c, DLNo__c, PassNo__c,AadharEncripted__c,KycDocNo__c,kycDoc__c,Applicant__r.LoanAppln__c
                                                          from ApplKyc__c  where Applicant__r.LoanAppln__c =:loanId]);
        Map<String, Map<id,Applicant__c >> duplicateUsersMap = new Map<String, Map<id,Applicant__c >>();   
        Map<id,Applicant__c > appMap = new Map<id,Applicant__c>([SELECT id,FullName__c, Constitution__c  FROM Applicant__c WHERE LoanAppln__c =:loanId]);   
        
        list<ApplicantEmployment__c> applEmpList = [select id,LoanApplicant__c,DesignationValues__c from ApplicantEmployment__c where LoanApplicant__r.LoanAppln__c =:loanId];
        Map<Id,ApplicantEmployment__c > appEmplMap = new Map<Id,ApplicantEmployment__c>();   
        
        
        for(ApplicantEmployment__c appEmp : applEmpList){
            appEmplMap.put(appEmp.LoanApplicant__c,appEmp);
        }
        for (ApplKyc__c a : appKycList) {
            String docNo;
            String doctype = a.kycDoc__c;
            String user = a.Applicant__r.FullName__c;
            Applicant__c applicantRec = appMap.get(a.Applicant__c);
            if(doctype == 'Aadhaar'){
                docNo = a.AadharEncripted__c;
            }
            else if (docType == 'Pan' || docType == 'Driving License' || docType == 'Passport' || docType == 'Voter Id'){
                docNo = setChar(a.KycDocNo__c);
            } 
            
            string adharNo = a.AadharNo__c;
            String key;
            if(doctype != null  && docNo != null){
                key = doctype + '-' + docNo;
            }
            
            if(key != null){
                if (!duplicateUsersMap.containsKey(key)) {
                    duplicateUsersMap.put(key, new Map<id,Applicant__c >());
                }
                
                Map<id,Applicant__c > users = duplicateUsersMap.get(key);
                users.put(applicantRec.id,applicantRec);
                //users.add(user);
            }
        }
        
        // Filter out entries with only one user
        for (String key : duplicateUsersMap.keySet()) {
            Map<id,Applicant__c > users = duplicateUsersMap.get(key);
            if (users.size() > 1) {
                ValidateRequiredFieldsAndDoc.Responce respObj = new ValidateRequiredFieldsAndDoc.Responce();             
                respObj.validated = false;
                respObj.missingDoc = true;
                respObj.errorMessage='Found Duplicate Documents for Applicants ';
                string applNames = '';
                boolean hasProp = false;
                integer prpCont = 0;
                integer indCont = 0;
                for(Applicant__c u : users.values() ){
                    if(key.contains('Pan')){
                        if(u.Constitution__c == 'PROPERITORSHIP'){
                            prpCont ++;
                        } else if(u.Constitution__c == 'INDIVIDUAL' && appEmplMap.get(u.Id).DesignationValues__c != 'PROPRIETOR'){                     
                            indCont ++;
                            applNames=applNames + ' : '+ u.FullName__c;
                        }
                    }else{
                        applNames=applNames + ' : '+ u.FullName__c;
                    }
                }
                if(indCont >1 ){
                    hasProp = false;
                }else if(indCont < 2 && prpCont >0){
                    hasProp = true;
                }
                respObj.missingValue = applNames;
                if(key.contains('Aadhaar')){
                    respObj.applicantName = 'AADHAR';                
                    respObjList.add(respObj);              
                } else if(key.contains('Pan')){
                    respObj.applicantName = key;
                    if( !hasProp){
                        respObjList.add(respObj);
                    }
                }else{
                    respObj.applicantName = key;
                    respObjList.add(respObj);                
                }         
            }
        }
        return respObjList;
    }
   
    
    @AuraEnabled
    public static  Map<string, string > checkPanNoStatus(List<Applicant__c> newList){
        Map<Id, Applicant__c> appMap = new Map<Id, Applicant__c>(newList);
        List<DocDtl__c > docDtlList = new List<DocDtl__c >();
        Map<id, DocDtl__c> docDtDeleteMap = new Map<id, DocDtl__c>();
        //  Map<id, ApplKyc__c > appKycUpdateMap = new Map<id, ApplKyc__c >();
        //list<ApplKyc__c> appKycList = new list<ApplKyc__c> ();
        list<string> panResList = new list<string>();
        Map<string, string > panResMap = new Map<string, string >();
        docDtlList = [SELECT Id, Appl__c,DocCatgry__c,DocTyp__c,
                      DocSubTyp__c, Appl__r.Constitution__c,Appl__r.TabName__c,Applicant_KYC__c,Applicant_KYC__r.id,  Applicant_KYC__r.Pan__c,
                      Applicant_KYC__r.OCRStatus__c, Applicant_KYC__r.ValidationStatus__c 
                      FROM DocDtl__c WHERE Appl__c IN:appMap.keyset() AND DocSubTyp__c ='PAN'];
        if(!docDtlList.isEmpty()){
            for (DocDtl__c dd : docDtlList) {
                
                if (dd.Appl__r.Constitution__c !=null && dd.Applicant_KYC__r.Pan__c != null && dd.Applicant_KYC__r.ValidationStatus__c =='Success' ) {
                    string constitutionIs = dd.Appl__r.Constitution__c;
                    
                    string panStatus = dd.Applicant_KYC__r.Pan__c.substring(3, 4).toUpperCase();
                    if ((panStatus == 'P' && (constitutionIs == 'INDIVIDUAL' || constitutionIs == 'PROPERITORSHIP')) ||
                        (panStatus == 'C' && (constitutionIs == 'PRIVATE LIMITED COMPANY' || constitutionIs == 'PUBLIC LIMITED COMPANY')) ||
                        (panStatus == 'H' && constitutionIs == 'HUF') ||
                        (panStatus == 'A' && (constitutionIs == 'ASSOCIATION OF PERSONS' || constitutionIs == 'SOCIETY')) ||
                        (panStatus == 'F' && (constitutionIs == 'LIMITED LIABILITY PARTNERSHIP' || constitutionIs == 'PARTNERSHIP')) ||
                        (panStatus == 'T' && constitutionIs == 'TRUST')
                       ) {
                           // matchig
                           System.debug('PAN MATCHING :: ' );
                       }
                    else {
                        panResMap.put(dd.Appl__r.TabName__c,'PAN Constitution is not matching with PAN number, Please upload new PAN');
                        //panResList.add('Pan Constitution Not Matching');
                        //     System.debug('PAN NOT MATCHING :: ' );
                        //     ApplKyc__c appKyc = new ApplKyc__c();
                        //     appKyc.Id = dd.Applicant_KYC__c;
                        //     appKyc.ValidationStatus__c = 'Failure';
                        //   //  appKycList.add(appKyc);
                        //     appKycUpdateMap.put(appKyc.Id,appKyc);
                        //    // docDtDeleteMap.put(dd.Id,dd);
                        //    // appKycDeleteMap.put(dd.Applicant_KYC__r.id,dd.Applicant_KYC__c);
                        //  //  not Matching Delete DocDtl__c AND Applicant_KYC__r
                    }
                }
            }
            // if(!appKycUpdateMap.isEmpty()){
            // System.debug('Update AppKyc :: '+appKycUpdateMap.values() );
            // update appKycUpdateMap.values();
            // }
            //  return panResList;
            // if(!docDtDeleteMap.isEmpty()){
            //     List<ContentDocumentLink> deleteCDList = new List<ContentDocumentLink>();
            //     deleteCDList = [
            //         SELECT
            //         Id,
            //         LinkedEntityId,
            //         ContentDocumentId,
            //         ContentDocument.CreatedDate,
            //         ContentDocument.Title,
            //         ContentDocument.ContentSize,
            //         ContentDocument.FileType
            //         FROM ContentDocumentLink
            //         WHERE LinkedEntityId IN: docDtDeleteMap.keySet()
            //     ];
            //     if(!deleteCDList.isEmpty()){
            //         delete deleteCDList;
            //         // for (ContentDocumentLink cdLink : deleteCDList) {
            //         //     //  contentDocLinkMap.put(cdLink.LinkedEntityId, cdLink);
            //         //     sObjectsToDelete.add(cdLink);
            //         // }
            //     }
            //     if(!appKycDeleteMap.isEmpty()){
            //         delete
            //     }
            // }
        }  
        return panResMap;            
    }
    
    
    public class resultWrp {
        @AuraEnabled
        public String appKycId{get;set;}
        @AuraEnabled
        public String docDetId{get;set;}
    }
    
}