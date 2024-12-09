public class Trackwizz_CKYC_A37_RequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType) {
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType,Attachment.SObjectType });
        
        try {
            if(!msgs.isEmpty()) {
                
                
                List<IntgMsg__c> updateIntrecods = new List<IntgMsg__c>();
                List<Attachment> insertAttachment = new List<Attachment>();
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('CKYC_ATTACHMENT');
                //Applicant Ids
                Set<Id> applIds = new Set<Id>();
                for(IntgMsg__c intMsgRec : msgs) {
                    applIds.add(intMsgRec.RefId__c);
                }
                
                
                Map<Id,List<DocDtl__c>> appDocDtlLMap = new Map<Id,List<DocDtl__c>>();
                Map<id,DocDtl__c> doclist =new Map<id,DocDtl__c>();
                for(DocDtl__c docDtl : [Select id,Appl__c,Appl__r.Constitution__c,DocSubTyp__c,Name,DocTyp__c,DocCatgry__c from DocDtl__c WHERE DocCatgry__c IN ('Photograph','PAN Documents','KYC Documents') AND DocTyp__c IN ('Photograph','PAN','Identity Proof','Residence Address proof - OVD','Principal Place of Business - Address Proof','Registered office - Address Proof')  AND Appl__c IN:applIds] ){
                    doclist.put(docDtl.Id,docDtl);
                    if(appDocDtlLMap.containsKey(docDtl.Appl__c)){
                        appDocDtlLMap.get(docDtl.Appl__c).add(docDtl);
                    }
                    else{
                        appDocDtlLMap.put(docDtl.Appl__c, new List<DocDtl__c>{docDtl});
                    }
                }
                
                
                
                /*set<Id> docid =new set<Id>();
                for(DocDtl__c dd:doclist){
                    docid.add(dd.id);
                }*/
                
                set<Id> condocid =new set<Id>();
                
                map<Id,ContentDocumentLink> ContentDocmap =new map<Id,ContentDocumentLink>();
                if(!doclist.isEmpty()){
                    for(ContentDocumentLink cdlList:[SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM
                                                     ContentDocumentLink where LinkedEntityId IN:doclist.keyset()]){
                                                         
                                                         ContentDocmap.put(cdlList.LinkedEntityId,cdlList);
                                                         condocid.add(cdlList.ContentDocumentId);                                
                                                     }
                }
                
                Map<Id,ContentVersion> VersionMap=new Map<Id,ContentVersion>();
                if(!condocid.isEmpty()){
                    for (ContentVersion converlist :[SELECT id,VersionData, ContentDocumentId, FileType, FileExtension
                                                     FROM ContentVersion  WHERE ContentDocumentId IN:condocid]){
                                                         VersionMap.put(converlist.ContentDocumentId, converlist);
                                                     }
                }
                
                for(IntgMsg__c intMsgRec : msgs){
                    
                    Trackwizz_CKYC_A37_RequestWrapper req =new Trackwizz_CKYC_A37_RequestWrapper();
                    
                    List<Trackwizz_CKYC_A37_RequestWrapper.ImageRequest> imgreqlist =new List<Trackwizz_CKYC_A37_RequestWrapper.ImageRequest>();
                    if(intMsgRec.RefId__c!=null && appDocDtlLMap.containsKey(intMsgRec.RefId__c)){
                        for(DocDtl__c dd: appDocDtlLMap.get(intMsgRec.RefId__c)){//doclist.values()
                            
                            if(ContentDocmap.containskey(dd.id)){
                                
                                ContentDocumentLink condoclink =ContentDocmap.get(dd.id);
                                
                                
                                if(VersionMap.containsKey(condoclink.ContentDocumentId)){
                                    
                                    ContentVersion cv=VersionMap.get(condoclink.ContentDocumentId);
                                    
                                    String contnt = EncodingUtil.base64Encode(cv.VersionData);
                                    
                                    Trackwizz_CKYC_A37_RequestWrapper.ImageRequest imgreq = new Trackwizz_CKYC_A37_RequestWrapper.ImageRequest();
                                    
                                    imgreq.ImageTransactionId=dd.Name;
                                    imgreq.AttachmentCode = TWEnumMap.containsKey(dd.DocSubTyp__c) ? TWEnumMap.get(dd.DocSubTyp__c) : dd.DocTyp__c=='Identity Proof' ? TWEnumMap.get('OthersPOICKYCInd') : (dd.DocTyp__c=='Residence Address proof - OVD' || dd.DocTyp__c=='Principal Place of Business - Address Proof' || dd.DocTyp__c=='Registered office - Address Proof') ? TWEnumMap.get('OthersPOACKYCInd') : dd.DocTyp__c=='Photograph' ? 'Photograph' :'';
                                    imgreq.AttachmentBlob=contnt;
                                    imgreq.ImageExtension='.'+cv.FileExtension;
                                    
                                    imgreqlist.add(imgreq);
                                }
                                
                            }
                            
                        }
                    } 
                    Trackwizz_CKYC_A37_RequestWrapper.ImageRequestDetailsClass imagereqdet =new Trackwizz_CKYC_A37_RequestWrapper.ImageRequestDetailsClass();
                    imagereqdet.ImageRequestDetail=imgreqlist;
                    
                    
                    
                    Trackwizz_CKYC_A37_RequestWrapper.CustomerRequestDetailClass CustReq =new Trackwizz_CKYC_A37_RequestWrapper.CustomerRequestDetailClass();
                    CustReq.TransactionId=GlobalUtility.getUniqueNumber();
                    CustReq.SourceSystemName=svc.SourceSystem__c;
                    CustReq.SourceSystemCustomerCode=GlobalConstants.SourceSystemCustomerCode;
                    CustReq.AppRefNumberOfImages='';
                    CustReq.HolderForImages='';
                    CustReq.ImageRequestDetails=imagereqdet;
                    
                     Trackwizz_CKYC_A37_RequestWrapper.CustomerRequest CustomerReqDet=new  Trackwizz_CKYC_A37_RequestWrapper.CustomerRequest();
                    CustomerReqDet.CustomerRequestDetail=CustReq;
                    
                    Trackwizz_CKYC_A37_RequestWrapper.RequestDataDetailClass RequestData=new  Trackwizz_CKYC_A37_RequestWrapper.RequestDataDetailClass();
                    RequestData.CustomerRequestDetails=CustomerReqDet;
                     
                    Trackwizz_CKYC_A37_RequestWrapper.A37ImageIntegrationRequestClass A37ImageInte =new Trackwizz_CKYC_A37_RequestWrapper.A37ImageIntegrationRequestClass();
                    A37ImageInte.ApiToken=svc.APIToken__c;
                    A37ImageInte.RequestId=GlobalUtility.getUniqueNumber();
                    A37ImageInte.RequestDataDetail=RequestData;
                    
                    req.A37ImageIntegrationRequest=A37ImageInte;
                    
                    
                    
                        Attachment att = new Attachment();
                        att.ParentId = intMsgRec.Id;
                        att.Body = Blob.valueOf(JSON.serialize(req));
                        att.Name = 'request.txt';
                        insertAttachment.add(att);
                    
                        IntgMsg__c intg = New IntgMsg__c();
                        intg.Id = intMsgRec.Id;
                        intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntrecods.add(intg);
                    
                }
                if(!insertAttachment.isEmpty()) {
                    String sObjectName = 'Attachment';
                    List<String> fieldNamesList = new List<String>{ 'ParentId','Body','Name' };
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                    uow.registerNew(insertAttachment);
                }
                
                if(!updateIntrecods.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{ 'Req__c','Status__c' };
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntrecods);
                }
                 uow.commitWork();
            }
        }
        catch(Exception ex) {
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'Trackwizz_CKYC_A37_RequestGenerator' + ex.getLineNumber(), 'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }

    private static Map<String,String> TWEnumMap = new Map<String,String> {

            'Aadhaar'=>'AadharCard',
            'PAN'=>'PAN',
            'Driving license'=>'DrivingLicence',
            'Passport'=>'Passport',
            'Voter ID'=>'VoterId',
            'Certificate/ registration document issued by competent authorities'=>'EmployerHouseLetter',
            'Electricity Bill'=>'Utilitybill2m',
            'GST certificate'=>'Utilitybill2m',
            'Piped gas bill'=>'Utilitybill2m',
            'Post-paid mobile phone bill'=>'Utilitybill2m',
            'Telephone Bill'=>'Utilitybill2m',
            'Shop and Establishment'=>'EmployerHouseLetter',
            'Water bill'=>'Utilitybill2m',
            'OthersPOICKYCInd'=> 'OthersPOICKYCInd',
            'OthersPOACKYCInd'=> 'OthersPOACKYCInd'   

        };

}