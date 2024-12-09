public class RequestStampPaperRequestGenerator implements ICalloutRequestGenerator {
    
    public void generate(List<IntgMsg__c> msgs,String service, String processType) {
        if(!msgs.isempty()){
            try{
                Set<Id> refIds =new Set<Id>();
                Map<Id,Id> contentDocumentLinkMap = new Map<Id,Id>();
                Map<Id,ContentVersion> contentDocumentMap = new Map<Id,ContentVersion>();
                List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                List<Attachment> attachmentRecords = new List<Attachment>();
                for(IntgMsg__c intMsg :msgs){
                    if(String.isnotBlank(intMsg.RefId__c)){
                        refIds.add(intMsg.RefId__c);
                    }
                }
                Map<Id,DocDtl__c> docDtlMap = new Map<Id,DocDtl__c>([SELECT Id,Name, Appl__c,Appl__r.FullName__c FROM DocDtl__c WHERE ID IN:refIds]);
                
                for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM ContentDocumentLink where LinkedEntityId IN: refIds]){
                    contentDocumentLinkMap.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
                }
                
                for(ContentVersion verData: [SELECT Id,Title,VersionData,ContentDocumentId,FileType,FileExtension FROM ContentVersion WHERE ContentDocumentId IN:contentDocumentLinkMap.keyset() ORDER BY CreatedDate DESC]){
                    if(contentDocumentLinkMap.containsKey(verData.ContentDocumentId) && !contentDocumentMap.containsKey(contentDocumentLinkMap.get(verData.ContentDocumentId))){
                        contentDocumentMap.put(contentDocumentLinkMap.get(verData.ContentDocumentId),verData);
                    }
                }
               
                for(IntgMsg__c intMsg :msgs){
                    if(docDtlMap.containsKey(intMsg.RefId__c) && contentDocumentMap.containsKey(intMsg.RefId__c)){
                        RequestStampPaperWrapper requestPayload = new RequestStampPaperWrapper();
                        requestPayload.reference_id = intMsg.Integration_Message_Number__c;
                        requestPayload.content = '';//EncodingUtil.base64Encode(contentDocumentMap.get(intMsg.RefId__c).VersionData);
                        requestPayload.first_party_name = '';//Need Mapping
                        requestPayload.second_party_name = docDtlMap.get(intMsg.RefId__c).Appl__r.FullName__c;
                        requestPayload.duty_payer_phone_number = '';
                        requestPayload.duty_payer_email_id = '';
                        
                        RequestStampPaperWrapper.Address firstPartyAddress = new RequestStampPaperWrapper.Address();
                        firstPartyAddress.street_address = '';
						firstPartyAddress.locality = '';
						firstPartyAddress.city = '';
						firstPartyAddress.state = '';
						firstPartyAddress.pincode = '';
						firstPartyAddress.country = '';
                        requestPayload.first_party_address = firstPartyAddress;
                        
                        RequestStampPaperWrapper.Address secondPartyAddress = new RequestStampPaperWrapper.Address();
                        secondPartyAddress.street_address = '';
						secondPartyAddress.locality = '';
						secondPartyAddress.city = '';
						secondPartyAddress.state = '';
						secondPartyAddress.pincode = '';
						secondPartyAddress.country = '';
                        requestPayload.second_party_address = secondPartyAddress;
                        
                        requestPayload.stamp_amount = '';
                        requestPayload.consideration_amount = '';
                        
                        requestPayload.stamp_state = '';
                        requestPayload.stamp_type = 'SHCIL';
                        requestPayload.surcharge = '';
                        requestPayload.stamp_duty_paid_by = 'First Party';
                        requestPayload.stamp_duty_payment_method = 'Wallet';
                        
                        requestPayload.document_category = '';
                        requestPayload.document_reference_no = docDtlMap.get(intMsg.RefId__c).Name;
                        
                        RequestStampPaperWrapper.FirstPartyDetails  firstPartyDetails= new RequestStampPaperWrapper.FirstPartyDetails();
                        firstPartyDetails.first_party_entity_type = '';
                        firstPartyDetails.first_party_id_type = '';
                        firstPartyDetails.first_party_id_number = '';
                        requestPayload.first_party_details = firstPartyDetails;
                        requestPayload.first_party_phone_number = '';
                        
                        RequestStampPaperWrapper.SecondPartyDetails  secondPartyDetails= new RequestStampPaperWrapper.SecondPartyDetails();
                        secondPartyDetails.second_party_entity_type = '';
                        secondPartyDetails.second_party_id_type = '';
                        secondPartyDetails.second_party_id_number = '';
                        secondPartyDetails.date_of_birth = '';
                        secondPartyDetails.father_or_husband_name = '';
                        requestPayload.second_party_details = secondPartyDetails;
                        requestPayload.second_party_phone_number = ''; 
                        
                        Attachment att = new Attachment();
                        att.ParentId = intmsg.Id;
                        att.Body = Blob.valueof(JSON.serialize(requestPayload,true));
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
                GlobalUtility.logMessage('Error', 'RequestStampPaperRequestGenerator class', 
                                         'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
    }
}