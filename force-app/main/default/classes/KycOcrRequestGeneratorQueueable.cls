public class KycOcrRequestGeneratorQueueable implements Queueable{
    
    Private List<IntgMsg__c>  msgs;
    private Map<Id,ContentVersion> contentDocumentMap;
    private Map<Id,ApplKyc__c> applKycMap;
    
    
    public KycOcrRequestGeneratorQueueable(List<IntgMsg__c> msgs,Map<Id,ContentVersion> contentDocumentMap,Map<Id,ApplKyc__c> applKycMap){
        this.msgs=msgs;
        this.contentDocumentMap=contentDocumentMap;
        this.applKycMap=applKycMap;
    }
    
    public void execute(QueueableContext context) {
        
        try{
            List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>();
            List<Attachment> attachmentRecords = new List<Attachment>();
            
            for(IntgMsg__c intMsg : msgs){
                if(intMsg.RefId__c!=null && contentDocumentMap.containsKey(intMsg.RefId__c) && intMsg.ParentRefId__c!=null && applKycMap.containsKey(intMsg.ParentRefId__c)){
                    OCRDocumentAPIRequestWrapper requestWrapper = new OCRDocumentAPIRequestWrapper();
                    OCRRequestWrapper request= new OCRRequestWrapper(EncodingUtil.base64Encode(contentDocumentMap.get(intMsg.RefId__c).VersionData),false,false,true,'');
                    ClientData cd=new ClientData();
                    cd.caseId=intMsg.Integration_Message_Number__c;
                    request.clientData=cd;
                    request.docType= applKycMap.get(intMsg.ParentRefId__c).kycDoc__c=='Driving License'?'dl':'';
                    
                    Attachment ocrReqAttachment = new Attachment();   
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
            
            if(!attachmentRecords.isEmpty()){
                Insert attachmentRecords;
            }
            
            if(!updateIntRecords.isEmpty()){
                Update updateIntRecords;
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'KycOcrRequestGeneratorQueueable' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    
    
    public class OCRRequestWrapper {  
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
}