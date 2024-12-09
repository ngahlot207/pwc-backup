public class FinfortDeliveryReportResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    public static void process(List<IntgMsg__c> responses) {
        
        
        if(!responses.isEmpty()){
            
            Set<Id> intmsgIds =new Set<Id>();
            Map<Id,Id> ContentDocumentMap =new Map<Id,Id>();
            Map<Id,ContentVersion> ContentVersionMap =new Map<Id,ContentVersion>();
            Map<IntgMsg__c,FinfortDeliveryReportResponseWrapper> successResponseMap = new Map<IntgMsg__c,FinfortDeliveryReportResponseWrapper>();
            Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
            
            
            //Getting All IntgMsg__c Ids
            for(IntgMsg__c msg :responses){
                
                intmsgIds.add(msg.Id);
            }
            
            
            if(!intmsgIds.isEmpty()){
                
                //Getting ContentDocumentId
                for(ContentDocumentLink cdl:[SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:intmsgIds AND 
                                             ContentDocument.Title = 'response.json']){
                    ContentDocumentMap.put(cdl.LinkedEntityId,cdl.ContentDocumentId);
                }
                //Getting VersionData
                for(ContentVersion cv:[SELECT Id, VersionData,FileType,ContentDocumentId FROM ContentVersion
                                       WHERE ContentDocumentId IN:ContentDocumentMap.values()]){
                    ContentVersionMap.put(cv.ContentDocumentId,cv);
                }
            }
            
            for(IntgMsg__c intmsg :responses){
                
                if(ContentDocumentMap.containsKey(intmsg.Id) && ContentVersionMap.containsKey(ContentDocumentMap.get(intmsg.Id))){
                    
                    ContentVersion cv =ContentVersionMap.get(ContentDocumentMap.get(intmsg.Id));
                    
                    
                    if(cv!=null){
                        
                        string jsonstring=cv.VersionData.toString();
                        
                        if(String.isNotblank(jsonstring)){
                            
                            try{
                                
                                FinfortDeliveryReportResponseWrapper resp = (FinfortDeliveryReportResponseWrapper) JSON.deserialize(jsonstring,FinfortDeliveryReportResponseWrapper.class);
                                
                                //Success
                                if(resp!=null){
                                    
                                    successResponseMap.put(intmsg,resp);
                                }
                                
                            }catch(Exception ex){
                                GlobalUtility.logMessage('Error', 'FinfortDeliveryReportResponseProcessor class',
                                'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                                failureResponseMap.put(intmsg,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                            }
                        }
                    }
                }
            }
            
            
            if(!successResponseMap.isEmpty()){
                processSuccess(successResponseMap);
            }
            
            if(!failureResponseMap.isEmpty()){
                processFailure(failureResponseMap);
            }
        }
        
        
    }
    
    //********************************************************************************************************************************************
    public static void processSuccess(Map<IntgMsg__c, FinfortDeliveryReportResponseWrapper> successResp) {
        
        try {
            
            Set<String> finFortOrderId =new Set<String>();
            Map<String,Applicant_Financial__c> applicantFinancialMap =new Map<String,Applicant_Financial__c>();
            List<DocDtl__c> docDetailList =new List<DocDtl__c>();
            Map<String,Map<String,Id>> docDetailIdMap =new Map<String,Map<String,Id>>();
            List<IntgMsg__c> intMsgList = new List<IntgMsg__c>();
            List<ContentVersion> contentVersionList = new List<ContentVersion>();
            
            //Getting FinFort Order Id
            for(FinfortDeliveryReportResponseWrapper resp:successResp.values()){
                
                if(String.isNotBlank(resp.ffOrderId)){
                    finFortOrderId.add(resp.ffOrderId);
                }
            }
            
            //Getting Applicant Financial based on FinFort Order Id
            if(!finFortOrderId.isEmpty()){
                
                for(Applicant_Financial__c fin:[Select Id,FinFortOrderId__c,Loan_Applicant__c,IsLatest__c from Applicant_Financial__c 
                                                Where FinFortOrderId__c IN:finFortOrderId AND IsLatest__c=true order by CreatedDate ASC]){
                    
                    if(!applicantFinancialMap.containsKey(fin.FinFortOrderId__c)){
                        applicantFinancialMap.put(fin.FinFortOrderId__c,fin);
                    }
                    
                }
                
            }
            
            
            //Creating Documnet detail
            for(IntgMsg__c msg:successResp.keyset()){
                
                FinfortDeliveryReportResponseWrapper response = successResp.get(msg);
                
                if(response!=null && string.isNotblank(response.ffOrderId) &&
                applicantFinancialMap.containsKey(response.ffOrderId)){
                    
                    DocDtl__c  doc =new DocDtl__c();
                    doc.Applicant_Financial__c=applicantFinancialMap.get(response.ffOrderId).Id;
                    doc.Appl__c=applicantFinancialMap.get(response.ffOrderId).Loan_Applicant__c;
                    doc.LAN__c=applicantFinancialMap.get(response.ffOrderId).Loan_Application__c;
                    doc.DocName__c=string.isNotBlank(response.fileName)?response.fileName:'';
                    docDetailList.add(doc);
                }
            }
            
            
            if(!docDetailList.isEmpty()){
                
                Insert docDetailList;
                
                //SOQL to fetch the Inserted DocDtl__c
                for(DocDtl__c dtl:[Select Id,Applicant_Financial__r.FinFortOrderId__c,DocName__c
                                   from DocDtl__c WHERE Id IN:docDetailList]){
                    
                    if(docDetailIdMap.containsKey(dtl.Applicant_Financial__r.FinFortOrderId__c)){
                        docDetailIdMap.get(dtl.Applicant_Financial__r.FinFortOrderId__c).put(dtl.DocName__c,dtl.Id);
                    }else {
                        docDetailIdMap.put(dtl.Applicant_Financial__r.FinFortOrderId__c,new Map<String,Id>{dtl.DocName__c=>dtl.Id});
                    }
                }
                
                //processing response
                for (IntgMsg__c msg : successResp.keySet()) {
                    
                    FinfortDeliveryReportResponseWrapper response = successResp.get(msg);
                    FinfortDeliveryReportResponseWrapper.CallbackWrapper calWrap = new FinfortDeliveryReportResponseWrapper.CallbackWrapper();
                    
                    if(response!=null && string.isNotblank(response.ffOrderId) && String.isNotBlank(response.fileData) &&
                       docDetailIdMap.containsKey(response.ffOrderId) && 
                       docDetailIdMap.get(response.ffOrderId).containsKey(response.fileName)){
                        
                        try{
                            
                            //Decode fileData
                            ContentVersion contentVersion = new ContentVersion();
                            contentVersion.VersionData = EncodingUtil.base64Decode(response.fileData);
                            contentVersion.Title = response.fileName;
                            contentVersion.PathOnClient = response.fileName;
                            contentVersion.FirstPublishLocationId = docDetailIdMap.get(response.ffOrderId).get(response.fileName);
                            contentVersionList.add(contentVersion);
                            
                            // Constructing Callback Response JSON
                            calWrap.code = 200;
                            calWrap.lender_name = String.isNotBlank(response.lender_name) ? response.lender_name : '';
                            calWrap.lender_referenceNumber = String.isNotBlank(response.lender_referenceNumber) ? response.lender_referenceNumber : '';
                            calWrap.ffOrderId = String.isNotBlank(response.ffOrderId) ? response.ffOrderId : '';
                            calWrap.borrower_pan = String.isNotBlank(response.borrower_pan) ? response.borrower_pan : '';
                            calWrap.fileName = response.fileName;
                            calWrap.fileTransferStatus = 'Success';
                            calWrap.failureReason = 'NA';
                        }catch (Exception ex) {
                            // Handle decoding failure
                            calWrap.code = 400;
                            calWrap.lender_name = String.isNotBlank(response.lender_name) ? response.lender_name : '';
                            calWrap.lender_referenceNumber = String.isNotBlank(response.lender_referenceNumber) ? response.lender_referenceNumber : '';
                            calWrap.ffOrderId = String.isNotBlank(response.ffOrderId) ? response.ffOrderId : '';
                            calWrap.borrower_pan = String.isNotBlank(response.borrower_pan) ? response.borrower_pan : '';
                            calWrap.fileName = response.fileName;
                            calWrap.fileTransferStatus = 'Failure';
                            calWrap.failureReason = 'Invalid Base64 data: ' + ex.getMessage();
                        }
                        
                    }
                    else {
                        // Constructing Callback Response JSON for missing fileData
                        calWrap.code = 400;
                        calWrap.lender_name = String.isNotBlank(response.lender_name) ? response.lender_name : '';
                        calWrap.lender_referenceNumber = String.isNotBlank(response.lender_referenceNumber) ? response.lender_referenceNumber : '';
                        calWrap.ffOrderId = String.isNotBlank(response.ffOrderId) ? response.ffOrderId : '';
                        calWrap.borrower_pan = String.isNotBlank(response.borrower_pan) ? response.borrower_pan : '';
                        calWrap.fileName = response.fileName;
                        calWrap.fileTransferStatus = 'Failure';
                        calWrap.failureReason = 'File Not Received';
                    }
                    
                    // Updating IntgMsg__c
                    if (calWrap != null) {
                        IntgMsg__c intmsg = new IntgMsg__c();
                        intmsg.Id = msg.Id;
                        intmsg.Resp__c = JSON.serialize(calWrap);
                        intmsg.Status__c = 'Processed';
                        intMsgList.add(intmsg);
                    }
                    
                    
                }
                
                if (!intMsgList.isEmpty()) {
                    update intMsgList;
                }
                
                if (!contentVersionList.isEmpty()) {
                    insert contentVersionList;
                }
                
            }
            
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortDeliveryReportResponseProcessor Class',
            'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    //********************************************************************************************************************************************
    public static void processFailure(Map<IntgMsg__c,String> failureResp){
        
        
        try{
            
            List<IntgMsg__c> intMsgList =new List<IntgMsg__c>();
            
            for(IntgMsg__c msg:failureResp.keyset()){
                
                FinfortDeliveryReportResponseWrapper.CallbackWrapper callWrap =new FinfortDeliveryReportResponseWrapper.CallbackWrapper();
                
                //constructing Callback Resposne JSON
                
                callWrap.code=400;
                callWrap.lender_name='fedfina';
                //callWrap.lender_referenceNumber='';
                //callWrap.ffOrderId='';
                //callWrap.borrower_pan='';
                //callWrap.fileName=cv.Title;
                callWrap.fileTransferStatus='Failure';
                callWrap.failureReason=failureResp.get(msg);
                
                //Updating IntgMsg__c
                if(callWrap!=null){
                    
                    IntgMsg__c intmsg =new IntgMsg__c();
                    intmsg.Id=msg.Id;
                    intmsg.Resp__c=JSON.serialize(callWrap);
                    intmsg.Status__c='Processed';
                    intMsgList.add(intmsg);
                }
            }
            
            if(!intMsgList.isEmpty()) {
                Update intMsgList;
            }
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortDeliveryReportResponseProcessor Class',
            'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
}