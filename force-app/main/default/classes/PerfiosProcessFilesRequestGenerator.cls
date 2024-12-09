public class PerfiosProcessFilesRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){  
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
        
        try{
            if(!msgs.isempty()){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Perfios_Process_Files');
                List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>();
                
                Set<Id> refIds = new Set<Id>();
                //Set<Id> docIds = new Set<Id>();
                
                for (IntgMsg__c intMsg : msgs) {
                    refIds.add(intMsg.ParentRefId__c);
                    //docIds.add(intMsg.RefId__c);
                }
                
                Map<Id, ApplBanking__c> applBankingMap = new Map<Id, ApplBanking__c>([select Id,FileType__c,Is_Statement_password_protected__c,Password__c,TransactionId__c from ApplBanking__c where Id IN:refIds]);
                //Map<Id,DocDtl__c> docDtlMap = new Map<Id,DocDtl__c>([Select Id,FileId__c from DocDtl__c WHERE Id IN:docIds]);
                              
                for(IntgMsg__c intmsg:msgs){
                    if(applBankingMap.containskey(intmsg.ParentRefId__c)){
                        ApplBanking__c applBanking = applBankingMap.get(intmsg.ParentRefId__c);
                        //DocDtl__c docDtl = docDtlMap.get(intmsg.RefId__c);
                        
                        Map<String,ContentDocumentLink> contentDocumentLinkMap = new Map<String,ContentDocumentLink>();
                        for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM ContentDocumentLink where LinkedEntityId =:intmsg.RefId__c]){
                            contentDocumentLinkMap.put(cdl.ContentDocumentId,cdl);  
                        }
                        List<ContentVersion> verDataList  = [SELECT Title,VersionData,ContentDocumentId,FileType,FileExtension,FileId__c,PerfiosFileUploaded__c FROM ContentVersion 
                                                             where ContentDocumentId IN:contentDocumentLinkMap.keyset() AND PerfiosFileProcessed__c=FALSE ORDER BY CreatedDate ASC LIMIT 1];
                        
                        if(verDataList!=null && !verDataList.isEmpty()){
                            PerfiosProcessFilesRequestWrapper request = new PerfiosProcessFilesRequestWrapper();
                            PerfiosProcessFilesRequestWrapper.Payload payload = new PerfiosProcessFilesRequestWrapper.Payload();
                            
                            payload.fileId = verDataList[0].FileId__c!=null ? verDataList[0].FileId__c : '';
                            payload.password = applBanking.Is_Statement_password_protected__c=='Yes'?  applBanking.Password__c: '';
                            //payload.institutionId = applBanking.FileType__c=='Scanned Documents'? '' : '';
                            request.payload = payload;
                            
                            
                            String method ='POST';
                            String requestDate= String.valueOf(system.now().format('yyyyMMdd\'T\'HHmmss\'Z\''));
                            String url =svc.URL__c.replace('<<__TransactionId__>>',applBanking.TransactionId__c);//'/KuberaVault/api/v3/organisations/fedfina/transactions/'+applBanking.TransactionId__c+'/bank-statements';
                            
                            String requestpayload = JSON.serialize(request);
                            string signature = PerfiosAPIController.generateSignature(method,URL,'',requestpayload, requestDate);
                            
                            
                            PerfiosAPIController.RequestWrapper perfioRequest = new PerfiosAPIController.RequestWrapper();
                            perfioRequest.Payload=request;
                            PerfiosAPIController.Header header = new PerfiosAPIController.Header();
                            header.perfioRequestDate = requestDate;
                            header.perfiosAlgorithm = svc.AlgorithmName__c;//'PERFIOS1-RSA-SHA256';
                            header.sha256Content = PerfiosAPIController.getSHA256Content(requestpayload);
                            header.perfioSignature = signature;
                            header.perfiosSignedHeaders = svc.SignedHeaders__c;//'host;x-perfios-content-sha256;x-perfios-date';
                            header.transactionID = applBanking.TransactionId__c;
                            header.fileId = verDataList[0].Id;
                            perfioRequest.Header = header;
                            
                            IntgMsg__c integrationMessage =new IntgMsg__c();
                            integrationMessage.Id=intmsg.Id;
                            integrationMessage.Req__c=JSON.serialize(perfioRequest);
                            integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                            updateIntRecords.add(integrationMessage);
                        }    
                    }
                    
                }
                if(!updateIntRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntRecords);
                }
                uow.commitWork();
            }
            
            
        }
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch(Exception ex){
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'PerfiosProcessFilesRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    public class PerfiosProcessFilesException extends Exception {
        
    }
}