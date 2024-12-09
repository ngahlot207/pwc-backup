public without sharing class KycOcrRequestGeneratorOld  {//implements ICalloutRequestGenerator
    
  /*  public void generate(List<IntgMsg__c> msgs, String service, String processType){  
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
            new List<SObjectType> { Attachment.SObjectType, IntgMsg__c.SObjectType }
        );
        
        try { 
            Set<Id> ids = new set<Id>();
            set<id> dids=new set<id>();
            Map<Id,ApplKyc__c> applKycMap = new Map<Id,ApplKyc__c>();
            //Iterating over new Intgeration Message record Ids to add them into the above List
            for(IntgMsg__c intMsg : msgs){ 
                dids.add(intMsg.RefId__c);
                ids.add(intMsg.ParentRefId__c);
            }

            for(ApplKyc__c appku : [SELECT Id,kycDoc__c FROM ApplKyc__c WHERE id IN :ids]){
            // dids.add(appku.Document_Detail__c);
             applKycMap.put(appku.Id,appku);   
            }
            //Fetching required fields to create Request Payload
            DocDtl__c docDetailRecord = getMapOfResponses(dids,msgs);
            system.debug('ids  ' +ids);
            system.debug(' DodDetailRecord  ==> ' +docDetailRecord);
            system.debug(' DodDetailRecord  ==> ' +docDetailRecord.id);  

            
            
           ContentDocumentLink cdlList = new ContentDocumentLink();
            
            //LAK-44 Changes to incorporate finding of ContentDocumentLink for both Lead Capture and RM Capture stage
            if(docDetailRecord.Is_Generated_from_Lead_Flow__c && docDetailRecord.Is_Ready_for_KYC_Validations__c && (docDetailRecord.Content_Document_Id__c !=null)){
                cdlList =  [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM
                                                 ContentDocumentLink where ContentDocumentId =:docDetailRecord.Content_Document_Id__c LIMIT 1];
            }else{
                cdlList =  [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM
                            ContentDocumentLink where LinkedEntityId =:docDetailRecord.id];
            }
            //LAK-44 Changes End
            
            //ContentDocumentLink cdlList =  [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM ContentDocumentLink where LinkedEntityId =:docDetailRecord.id];
            
            system.debug('ContentDocumentLink ==> '+cdlList);
            
            
            ContentVersion verData = [SELECT VersionData,ContentDocumentId,FileType,FileExtension FROM ContentVersion 
                                      where ContentDocumentId = :cdlList.ContentDocumentId];
            
            String contnt = EncodingUtil.base64Encode(verData.VersionData);
            
            //If the List of new Integration Message records is not empty, then iterating over and assigning data to variables from Wrapper Class
            List<IntgMsg__c> integrationMssages = new List<IntgMsg__c>(); 
            List<Attachment> attachRequest = new List<Attachment>();
            OCRDocumentAPIRequestWrapper requestWrapper = new OCRDocumentAPIRequestWrapper();
            
            for(IntgMsg__c intMsg : msgs){
                
                // Applicant__c appRec = intMsgMap.get(intMsg.RefId__c);
                OCRRequestWrapper request= new OCRRequestWrapper(contnt,false,false,true,'');
                 ClientData cd=new ClientData();
                 cd.caseId=GlobalUtility.getUniqueNumber();
                 request.clientData=cd;
                 request.docType= (applKycMap.containsKey(intMsg.ParentRefId__c) && applKycMap.get(intMsg.ParentRefId__c).kycDoc__c=='Driving License')?'dl':'';
                
                string requestData=request.getJSON();
             //   system.debug('requestData'+requestData + '/n' + 'intMsg ==>' +intMsg);
                
           //     requestData = requestWrapper.getWrapper(requestData,intMsg);
                
                Attachment ocrReqAttachment = new Attachment();   
                ocrReqAttachment.parentId = intMsg.id;            
                ocrReqAttachment.Body = Blob.valueOf(requestData);            
                ocrReqAttachment.Name = 'Request.txt';            
                ocrReqAttachment.ContentType = 'application/text';            
               attachRequest.add(ocrReqAttachment);
               system.debug('attachRequest '+attachRequest );
                IntgMsg__c integrationMssage = new IntgMsg__c();
                integrationMssage.Id = intMsg.Id;
              //  integrationMssage.Req__c=requestData;
                integrationMssage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                integrationMssages.add(integrationMssage);
                
            }      
            
            System.debug('integrationMssages: ' + integrationMssages);
            if(!attachRequest.isEmpty())
            {
                List<string> fieldNamesList = New List<string>{'ContentType','Name','Body','parentId'};
                    String sObjectName = 'Attachment';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                
                uow.registerNew(attachRequest);
            }
            if(!integrationMssages.isEmpty()){
                
                List<string> fieldNamesList = New List<string>{'Status__c','Req__C'};
                    String sObjectName = 'IntgMsg__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                system.debug('update integration message');
                uow.registerDirty(integrationMssages);
            }
            uow.commitWork();
        }
        
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'KycOcrRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    } 
    
    public DocDtl__c getMapOfResponses(Set<Id> ids, List<IntgMsg__c>msgs){
        
        List<DocDtl__c> appDocDetails = new List<DocDtl__c>();
        
        appDocDetails = [SELECT Id,DocTyp__c,Appl__c,DocMstr__r.DocSubTyp__c,Is_Ready_for_KYC_Validations__c, Is_Generated_from_Lead_Flow__c, 
                          Content_Document_Id__c FROM DocDtl__c Where id in : ids ];//AND DocTyp__c ='Identity Proof'
        
        system.debug('appDocDetails  ==>' +appDocDetails);
        
        Map<Id,Map<string,DocDtl__c>> intMsgMapWithApplDocDetail = new Map<Id,Map<string,DocDtl__c>>();
        
        for(DocDtl__c docc : appDocDetails){ 
            
            Map<String, DocDtl__c> appDocDetailMap = intMsgMapWithApplDocDetail.get(docc.id);
            
            if(appDocDetailMap == null) {
                appDocDetailMap = new Map<string,DocDtl__c>();
            }
            appDocDetailMap.put(docc.DocMstr__r.DocSubTyp__c,docc);
            system.debug('appDocDetailMap  ==>' +appDocDetailMap);
            intMsgMapWithApplDocDetail.put(docc.id,appDocDetailMap);
            
            //intMsgMap.put(docc.DocMstr__r.name,docc);
            system.debug('DocMstr details == > '+docc.DocMstr__r.DocSubTyp__c);
        }
        
        system.debug('intMsgMapWithApplDocDetail map result is:::::'+intMsgMapWithApplDocDetail);
        
        Map<string,DocDtl__c> intMsgMapForApp = new Map<string,DocDtl__c>();
        
        //LAK-44 changes
        DocDtl__c appDocDetailRecord = new DocDtl__c(); 
        appDocDetailRecord.id=appDocDetails[0].id;
        appDocDetailRecord.Is_Ready_for_KYC_Validations__c = appDocDetails[0].Is_Ready_for_KYC_Validations__c;
        appDocDetailRecord.Is_Generated_from_Lead_Flow__c = appDocDetails[0].Is_Generated_from_Lead_Flow__c;
        appDocDetailRecord.Content_Document_Id__c = appDocDetails[0].Content_Document_Id__c !=null ? appDocDetails[0].Content_Document_Id__c : null;
        for(IntgMsg__c intre : msgs){
            
            intMsgMapForApp = intMsgMapWithApplDocDetail.get(intre.RefId__c);
            
            system.debug('intMsgMapForApp for document detail record:::::'+intMsgMapForApp);
            System.debug('intre.Svc__c==='+intre.Svc__c);
            System.debug('intre.RefId__c==='+intre.RefId__c);
            if(intre.Svc__c == GlobalConstants.INT_CONFIG_SERVICE_KYC_OCR_AADHAR){
                
                appDocDetailRecord = intMsgMapForApp.get(GlobalConstants.INT_MSG_DOCMASTER_NAME_AADHAR);
                
            }else if(intre.Svc__c == GlobalConstants.INT_CONFIG_SERVICE_KYC_OCR_DL){
                
                appDocDetailRecord = intMsgMapForApp.get(GlobalConstants.INT_MSG_DOCMASTER_NAME_DRIVING_LICENSE);
                
            }else if(intre.Svc__c == GlobalConstants.INT_CONFIG_SERVICE_KYC_OCR_PASSPORT){
                
                appDocDetailRecord = intMsgMapForApp.get(GlobalConstants.INT_MSG_DOCMASTER_NAME_PASSPORT);
                
            }else if(intre.Svc__c == GlobalConstants.INT_CONFIG_SERVICE_KYC_OCR_VOTER_ID){
                
                appDocDetailRecord = intMsgMapForApp.get(GlobalConstants.INT_MSG_DOCMASTER_NAME_VOTER_ID);
                
            }else if(intre.Svc__c == GlobalConstants.INT_CONFIG_SERVICE_KYC_OCR_PAN){
                
                appDocDetailRecord = intMsgMapForApp.get(GlobalConstants.INT_MSG_DOCMASTER_NAME_PAN);
            }
        }
        system.debug('appDocDetailRecord==>'+appDocDetailRecord);
        
        if(appDocDetailRecord != null){
            
            return appDocDetailRecord; 
            
        }
        
        return null;
        
    }
    
    public class OCRRequestWrapper {  
        //Wrapper class
        //  public String fileB64;
        public String fileB64;
        public Boolean maskAadhaar;
        public Boolean hideAadhaar;
        public Boolean conf;
        public String docType;
        public ClientData clientData;
        
        
        public OCRRequestWrapper(String fileB64,boolean maska,boolean hideAadhaar,boolean con,string dtype){
            this.fileB64 = fileB64;
            this.maskAadhaar=maska;
             this.hideAadhaar=hideAadhaar;
             this.conf=con;
             this.docType=dtype;
        }   
        public String getJSON(){
            return JSON.serialize(this);
        }  
        
    }
    public class ClientData {
        String caseId;
    }
    public class docDetailRecordException extends Exception {
        
    }*/
}