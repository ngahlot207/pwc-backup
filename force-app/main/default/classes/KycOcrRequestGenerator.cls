public class KycOcrRequestGenerator implements ICalloutRequestGenerator {
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){  
        if(!msgs.isempty()){
            try { 
                
                Set<Id> refIds = new set<Id>();
                set<id> parentRefIds=new set<id>();
                Map<Id,ApplKyc__c> applKycMap = new Map<Id,ApplKyc__c>();
                Map<Id,Id> contentDocumentLinkMap = new Map<Id,Id>();
                Map<Id,ContentVersion> contentDocumentMap = new Map<Id,ContentVersion>();
                List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>();
                List<Attachment> attachmentRecords = new List<Attachment>();
                
                for(IntgMsg__c intMsg : msgs){ 
                    refIds.add(intMsg.RefId__c);
                    parentRefIds.add(intMsg.ParentRefId__c);
                }
                
                for(ApplKyc__c appku : [SELECT Id,kycDoc__c FROM ApplKyc__c WHERE id IN :parentRefIds]){
                    applKycMap.put(appku.Id,appku);   
                }
                Map<Id,DocDtl__c> docDtlMap = new Map<Id,DocDtl__c>([SELECT Id,DocTyp__c,Appl__c,DocMstr__r.DocSubTyp__c,Is_Ready_for_KYC_Validations__c, Is_Generated_from_Lead_Flow__c, 
                                                                     Content_Document_Id__c FROM DocDtl__c Where Id in :refIds]);
                
                
                for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM ContentDocumentLink where LinkedEntityId IN: refIds]){
                    contentDocumentLinkMap.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
                }
                
                for(ContentVersion verData: [SELECT Title,VersionData,ContentDocumentId,FileType,FileExtension FROM ContentVersion WHERE ContentDocumentId IN:contentDocumentLinkMap.keyset() ORDER BY CreatedDate DESC]){
                    if(contentDocumentLinkMap.containsKey(verData.ContentDocumentId) && !contentDocumentMap.containsKey(contentDocumentLinkMap.get(verData.ContentDocumentId))){
                        contentDocumentMap.put(contentDocumentLinkMap.get(verData.ContentDocumentId),verData);
                    }
                }
                
                KycOcrRequestGeneratorQueueable kycOcrQueable =new KycOcrRequestGeneratorQueueable(msgs,contentDocumentMap,applKycMap);
                        system.enqueueJob(kycOcrQueable);  
               /* for(IntgMsg__c intMsg : msgs){
                    if(intMsg.RefId__c!=null && contentDocumentMap.containsKey(intMsg.RefId__c) && intMsg.ParentRefId__c!=null && applKycMap.containsKey(intMsg.ParentRefId__c)){
                        OCRDocumentAPIRequestWrapper requestWrapper = new OCRDocumentAPIRequestWrapper();
                        OCRRequestWrapper request= new OCRRequestWrapper(EncodingUtil.base64Encode(contentDocumentMap.get(intMsg.RefId__c).VersionData),false,false,true,'');
                        ClientData cd=new ClientData();
                        cd.caseId=intMsg.Integration_Message_Number__c;
                        request.clientData=cd;
                        request.docType= applKycMap.get(intMsg.ParentRefId__c).kycDoc__c=='Driving License'?'dl':'';
                        
                      /*  Attachment ocrReqAttachment = new Attachment();   
                        ocrReqAttachment.parentId = intMsg.id;            
                        ocrReqAttachment.Body = Blob.valueOf(request.getJSON());            
                        ocrReqAttachment.Name = 'Request.txt';            
                        ocrReqAttachment.ContentType = 'application/text';            
                        attachmentRecords.add(ocrReqAttachment);
                        
                        IntgMsg__c integrationMssage = new IntgMsg__c();
                        integrationMssage.Id = intMsg.Id;
                        integrationMssage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntRecords.add(integrationMssage);
                         
                    }
                }
                
               /* if(!attachmentRecords.isEmpty()){
                    Insert attachmentRecords;
                }
                
                if(!updateIntRecords.isEmpty()){
                    Update updateIntRecords;
                }*/
                
            }
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'KycOcrRequestGenerator' + ex.getLineNumber(), 
                                         'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
            }
            
            
            
        }
    }

    /*public class OCRRequestWrapper {  
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
    }*/
    
}