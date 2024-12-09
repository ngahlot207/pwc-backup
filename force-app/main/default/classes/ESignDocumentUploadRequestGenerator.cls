public class ESignDocumentUploadRequestGenerator implements ICalloutRequestGenerator {
    
    public void generate(List<IntgMsg__c> msgs,String service, String processType) {
    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType>{ IntgMsg__c.SObjectType } );
        
        if(!msgs.isempty()){
            
            set<Id> refIds = new set<Id>();
            set<Id> loanApplIds = new set<Id>();
            Map<Id,Id> contentDocumentLinkMap = new Map<Id,Id>();
            Map<Id,ContentVersion> contentDocumentMap = new Map<Id,ContentVersion>();
            Map<Id,List<Applicant__c>> applMap = new Map<Id,List<Applicant__c>>();
            //Map<Id,DocDtl__c> docDtlMap = new Map<Id,DocDtl__c>();
            List<Attachment> attachmentRecords = new List<Attachment>();
            List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
            
            try{
                for(IntgMsg__c intMsg :msgs){
                    refIds.add(intMsg.RefId__c);
                    loanApplIds.add(intMsg.ParentRefId__c);
                }
                
                
                /*for(DocDtl__c doc : [SELECT Id,DocTyp__c,LAN__c,LAN__r.Name FROM DocDtl__c WHERE ID IN:refIds]){
                    loanApplIds.add(doc.LAN__c);
                }*/
                
                for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM ContentDocumentLink where LinkedEntityId IN: refIds]){
                    contentDocumentLinkMap.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
                }
                
                for(ContentVersion verData: [SELECT Id,Title,VersionData,ContentDocumentId,FileType,FileExtension FROM ContentVersion WHERE ContentDocumentId IN:contentDocumentLinkMap.keyset() ORDER BY CreatedDate DESC]){
                    if(contentDocumentLinkMap.containsKey(verData.ContentDocumentId) && !contentDocumentMap.containsKey(contentDocumentLinkMap.get(verData.ContentDocumentId))){
                        contentDocumentMap.put(contentDocumentLinkMap.get(verData.ContentDocumentId),verData);
                    }
                }
                
                for(Applicant__c appl: [Select Id,LoanAppln__c,Constitution__c,ApplType__c,Name, FullName__c,EmailId__c,MobNumber__c,Gender__c, DOB__c,AadhaarNo__c from Applicant__c  WHERE ApplType__c IN('P','C') AND LoanAppln__c IN:loanApplIds ORDER BY ApplType__c,CreatedDate]){
                    if(applMap.containsKey(appl.LoanAppln__c)){
                        applMap.get(appl.LoanAppln__c).add(appl);
                    }
                    else{
                        applMap.put(appl.LoanAppln__c,new List<Applicant__c>{appl});
                    }
                }
                
                for(IntgMsg__c intMsg :msgs){
                    
                    if(intMsg.RefId__c!=null && contentDocumentMap.containsKey(intMsg.RefId__c)){
                      
                        ESignDocumentUploadRequestWrapper request = new ESignDocumentUploadRequestWrapper();
                        request.reference_id = intMsg.Integration_Message_Number__c;
                        request.docket_title = 'Documents'; // need to check
                        request.description_in_invitation = false;
                        request.docket_description = '';
                        request.remarks = '';
                        
                        request.enable_email_notification = false;
                        request.enable_organisation_seal = false;
                        //request.expiry_date ='';
                        
                        List<ESignDocumentUploadRequestWrapper.Documents> documents = new List<ESignDocumentUploadRequestWrapper.Documents>();
                        
                        ESignDocumentUploadRequestWrapper.Documents document = new ESignDocumentUploadRequestWrapper.Documents();
                        document.reference_doc_id = contentDocumentMap.get(intMsg.RefId__c).Id;
                        document.content_type = contentDocumentMap.get(intMsg.RefId__c).FileExtension;
                        document.return_url = '';
                        document.content = EncodingUtil.base64Encode(contentDocumentMap.get(intMsg.RefId__c).VersionData);
                        document.signature_sequence = 'parallel';//sequential
                        
                        /*ESignDocumentUploadRequestWrapper.CustomParameter  custom = new ESignDocumentUploadRequestWrapper.CustomParameter();
                        custom.parameter_name = '';
                        document.custom_parameter = custom;
                        */
                        documents.add(document);
                        request.documents = documents;
                        
                        List<ESignDocumentUploadRequestWrapper.SignersInfo> signersInfo = new List<ESignDocumentUploadRequestWrapper.SignersInfo>();
                        if(applMap.containsKey(intMsg.ParentRefId__c) && !applMap.get(intMsg.ParentRefId__c).isEmpty()){
                            for(Applicant__c appl : applMap.get(intMsg.ParentRefId__c)){
                                ESignDocumentUploadRequestWrapper.SignersInfo signerInfo = new ESignDocumentUploadRequestWrapper.SignersInfo();
                            }
                        }
                        
                        /*ESignDocumentUploadRequestWrapper.WidgetConfiguration  widgetConfiguration = new ESignDocumentUploadRequestWrapper.WidgetConfiguration();
                        widgetConfiguration.widget_title = '';
                        widgetConfiguration.background_color =  '';
                        widgetConfiguration.button_color = '';
                        widgetConfiguration.button_font_color = '';
                        widgetConfiguration.font_family = '';
                        widgetConfiguration.esign_with_otp_button_text = '';
                        widgetConfiguration.esign_with_biometric_button_text = '';
                        widgetConfiguration.user_instruction = '';
                        widgetConfiguration.remark_field_label = '';
                        widgetConfiguration.usb_signature_title = '';
                        
                        request.widget_configuration = widgetConfiguration;*/
                        
                        Attachment att = new Attachment();
                        att.ParentId = intmsg.Id;
                        att.Body = Blob.valueof(JSON.serialize(request));
                        att.Name = 'request.txt';
                        attachmentRecords.add(att);
                        
                        IntgMsg__c integrationMessage =new IntgMsg__c();
                        integrationMessage.Id=intmsg.Id;
                        integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntMsgRecords.add(integrationMessage);
                    }
                    
                    
                    
                }
                
                if(!attachmentRecords.isEmpty()){
                    insert attachmentRecords;
                }
                if(!updateIntMsgRecords.isEmpty()) {
                    update updateIntMsgRecords;
                }
               
                
            }
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'ESignDocumentUploadRequestGenerator class', 
                                         'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
    
    }
    
    /*public static String getTestEsignDocuments(String FileId, String recordId){
        
        ContentDocumentLink cdlList =  [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM
                                        ContentDocumentLink where LinkedEntityId =:FileId ORDER BY SystemModstamp DESC  LIMIT 1 ];
        
        ContentVersion verData = [SELECT VersionData,ContentDocumentId,FileType,FileExtension FROM ContentVersion 
                                  where ContentDocumentId = :cdlList.ContentDocumentId];
        
        system.debug('::::::::::::::::::');
        //String testFileBase64Data = EncodingUtil.base64Encode(verData.VersionData);
        system.debug('1:::::::::::::::::::');
        ESignDocumentUploadRequestWrapper request = new ESignDocumentUploadRequestWrapper();
        request.reference_id = 'xxxx';
        request.docket_title = 'xxxx';
        request.remarks = 'xxxx';
        request.enable_email_notification = false;
        
        
        List<ESignDocumentUploadRequestWrapper.Documents> documents = new List<ESignDocumentUploadRequestWrapper.Documents>();
        
        for(integer i=0;i<1;i++){
            ESignDocumentUploadRequestWrapper.Documents document = new ESignDocumentUploadRequestWrapper.Documents();
            document.reference_doc_id = verData.Id;
            document.content_type = 'pdf';
            document.return_url = 'xxxx';
			document.content = '';//EncodingUtil.base64Encode(verData.VersionData);
            document.signature_sequence = 'xxxx';
            ESignDocumentUploadRequestWrapper.CustomParameter  custom = new ESignDocumentUploadRequestWrapper.CustomParameter();
            custom.parameter_name = 'xxxx';
            document.custom_parameter = custom;
            
            documents.add(document);
        }
        
        request.documents = documents;
        ESignDocumentUploadRequestWrapper.WidgetConfiguration  widgetConfiguration = new ESignDocumentUploadRequestWrapper.WidgetConfiguration();
        widgetConfiguration.widget_title = 'xxxx';
        widgetConfiguration.background_color =  'xxxx';
        widgetConfiguration.button_color = 'xxxx';
        widgetConfiguration.button_font_color = 'xxxx';
        widgetConfiguration.font_family = 'xxxx';
        widgetConfiguration.esign_with_otp_button_text = 'xxxx';
        widgetConfiguration.esign_with_biometric_button_text = 'xxxx';
        widgetConfiguration.user_instruction = 'xxxx';
        widgetConfiguration.remark_field_label = 'xxxx';
        widgetConfiguration.usb_signature_title = 'xxxx';
    
        
        request.widget_configuration = widgetConfiguration;
        
        List<ESignDocumentUploadRequestWrapper.SignersInfo> signersInfo = new List<ESignDocumentUploadRequestWrapper.SignersInfo>();
        
        ESignDocumentUploadRequestWrapper.SignersInfo signerInfo = new ESignDocumentUploadRequestWrapper.SignersInfo();
        
        signerInfo.document_to_be_signed = 'xxxx';
        
        ESignDocumentUploadRequestWrapper.SignerPosition signerPosition = new ESignDocumentUploadRequestWrapper.SignerPosition();
        signerPosition.appearance = 'xxxx';
        
        signerInfo.signer_position = signerPosition;
        
        signerInfo.signer_ref_id = 'xxxx';
        signerInfo.signer_email = 'xxxx';
        signerInfo.signer_name = 'xxxx';
        signerInfo.sequence = 'xxxx';
        signerInfo.page_number = 'xxxx';
        signerInfo.esign_type = 'xxxx';
        signerInfo.signer_mobile = 'xxxx';
        
        ESignDocumentUploadRequestWrapper.SignerValidationInputs signerValidationInputs = new ESignDocumentUploadRequestWrapper.SignerValidationInputs();
        
        signerValidationInputs.year_of_birth = 'xxxx';
        signerValidationInputs.gender = 'xxxx';
        signerValidationInputs.name_as_per_aadhaar = 'xxxx';
        signerValidationInputs.last_four_digits_of_aadhaar = 'xxxx';
        
        signerInfo.signer_validation_inputs = signerValidationInputs;
        
        signerInfo.signature_type = 'xxxx';
        signerInfo.access_type = 'xxxx';
        
        signersInfo.add(signerInfo);
        
        request.signers_info = signersInfo;
        
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.VersionData = Blob.valueOf(JSON.serialize(request));
        contentVersion.Title = 'Request';
        contentVersion.PathOnClient = 'Request.json';
        //insert contentVersion;
        
        system.debug('contentVersion'+contentVersion);
        
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1].ContentDocumentId;
        
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.ContentDocumentId = contentDocumentId;
        contentLink.LinkedEntityId=recordId;
        contentLink.ShareType = 'V';
        //insert contentLink;
        return JSON.serialize(request);
    }*/
    
}