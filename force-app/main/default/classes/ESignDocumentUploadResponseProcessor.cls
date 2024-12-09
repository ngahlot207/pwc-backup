public class ESignDocumentUploadResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    public static void process(List<IntgMsg__c> responses){ 
    	
        Map<IntgMsg__c,ESignDocumentUploadResponseWrapper> successResponseMap = new Map<IntgMsg__c,ESignDocumentUploadResponseWrapper>();
        Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
        Set<Id> refIds = new Set<Id>();
        
        
        for(IntgMsg__c integrationMessage : responses){
            
            try{
                ESignDocumentUploadResponseWrapper response = (ESignDocumentUploadResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, ESignDocumentUploadResponseWrapper.class);
                if(response!=null && response.status !=null && response.status.equalsIgnoreCase('success')){
                    successResponseMap.put(integrationMessage,response);
                    refIds.add(integrationMessage.ParentRefId__c);
                }
                else{
                    failureResponseMap.put(integrationMessage,(response.error!=null && String.isNotBlank(response.error) ? response.error : response.error_code));
                }
            }
            catch(Exception ex){
                
                failureResponseMap.put(integrationMessage,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                GlobalUtility.logMessage('Error', 'ESignDocumentUploadResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                
            }
        }
        
        if(!successResponseMap.isEmpty()){
            //processSuccess
        }
        if(!failureResponseMap.isEmpty()){
            //processFailure
        }
    }
    
    public static void processSuccess(Set<Id> refIds, Map<IntgMsg__c,ESignDocumentUploadResponseWrapper> successResponseMap){
        
        if(refIds!=null && successResponseMap!=null){
            Map<String,Applicant__c> applMap = new Map<String,Applicant__c>();
            List<DocDtl__c> updateDocDtlList = new List<DocDtl__c>();
            List<DocDtlItem__c> docDtlItemList = new List<DocDtlItem__c>();
            Set<Id> existingApplicantIds = new Set<Id>();
            for(Applicant__c appl: [Select Id,LoanAppln__c,Constitution__c,ApplType__c,Name, FullName__c,EmailId__c,MobNumber__c,Gender__c, DOB__c,AadhaarNo__c from Applicant__c  WHERE ApplType__c IN('P','C') AND LoanAppln__c IN:refIds]){
                if(!applMap.containsKey(appl.Name)){
                    applMap.put(appl.Name,appl);
                }
            }
            
            for(IntgMsg__c intMsg : successResponseMap.keySet()){
                ESignDocumentUploadResponseWrapper response = successResponseMap.get(intMsg);
                
                if(response!=null){
                    DocDtl__c docDtl = new DocDtl__c();
                    docDtl.Id = intMsg.RefId__c;
                    docDtl.DocketId__c = response.docket_id!=null && String.isNotBlank(response.docket_id) ? response.docket_id:'';
                    updateDocDtlList.add(docDtl);
                    
                    if(response.signer_info!=null && !response.signer_info.isEmpty()){
                        for(ESignDocumentUploadResponseWrapper.SignerInfo signer: response.signer_info){
                            if(signer.signer_ref_id!=null && applMap.containsKey(signer.signer_ref_id)){
                                existingApplicantIds.add(applMap.get(signer.signer_ref_id).Id);
                                DocDtlItem__c docDtlItem = new DocDtlItem__c();
                                docDtlItem.DocumentDetail__c = intMsg.RefId__c;
                                docDtlItem.Type__c = 'E-Sign';
                                docDtlItem.Applicant__c = applMap.get(signer.signer_ref_id).Id;
                                docDtlItem.DocumentId__c = signer.document_id;
                                docDtlItem.SignerId__c = signer.signer_id;
                                docDtlItem.IsLatest__c = true;
                                docDtlItemList.add(docDtlItem);
                            }
                        }
                    }
                }
            }
            
            if(!existingApplicantIds.isEmpty()){
                List<DocDtlItem__c> existingAPIVerList = [Select Id,IsLatest__c,Applicant__c FROM DocDtlItem__c WHERE IsLatest__c=True AND Applicant__c IN :existingApplicantIds AND Type__c ='E-Sign'];
                if(!existingAPIVerList.isEmpty()){
                    IntegrationUtility.updateBooleanFlag(existingAPIVerList, 'IsLatest__c', false);
                }
            }
            if(!updateDocDtlList.isEmpty()){
                update updateDocDtlList;
            }
            if(!docDtlItemList.isEmpty()){
                insert docDtlItemList;
            }
        }
        
    }
    
}