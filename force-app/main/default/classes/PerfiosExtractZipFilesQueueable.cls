public class PerfiosExtractZipFilesQueueable implements Queueable {
    
    public Map<Id,IntgMsg__c> intgMsgMap;
    public Map<Id,Blob> responseZipFileMap;
    public PerfiosExtractZipFilesQueueable(Map<Id,IntgMsg__c> intgMsgMap, Map<Id,Blob> responseZipFileMap){
        this.intgMsgMap = intgMsgMap; 
        this.responseZipFileMap=responseZipFileMap;
    }
    public void execute(QueueableContext context) {
        try {
            Map<String, ContentVersion> contentVersionMap = new Map<String, ContentVersion>();
            
            if(!responseZipFileMap.isEmpty()){
                List<IntgMsg__c> responses = new List<IntgMsg__c>();
                Map<Id,PerfiosRetrieveReportResponseWrapper> responseMap = new Map<Id,PerfiosRetrieveReportResponseWrapper>();
                for(Id intgId : responseZipFileMap.keySet()){
                    
                    Zippex zip = new Zippex(responseZipFileMap.get(intgId));
                    
                    for (String fileName : zip.getFileNames()) {
                        
                        if(fileName.substringAfter('.')=='xlsx'){
                            
                            Blob fileData = zip.getFile(fileName);
                            ContentVersion cv = new ContentVersion();
                            cv.Title = fileName;
                            cv.PathOnClient = fileName;
                            cv.VersionData = fileData;
                            contentVersionMap.put(intgId +'-'+ fileName, cv);
                        }
                        
                        if(fileName.substringAfter('.')=='json'){
                            
                            Blob fileData = zip.getFile(fileName);
                            String jsonResponse = fileData.toString();
                            PerfiosRetrieveReportResponseWrapper response = (PerfiosRetrieveReportResponseWrapper) JSON.deserialize(jsonResponse, PerfiosRetrieveReportResponseWrapper.class);
                            
                            if(response!=null){
                                
                                if(intgMsgMap.containsKey(intgId) && intgMsgMap.get(intgId).ParentRefId__c!=null){
                                    
                                    responseMap.put(intgMsgMap.get(intgId).ParentRefId__c,response);
                                    responses.add(intgMsgMap.get(intgId));
                                }
                                
                            }
                        }
                    }    					
                }
                
                if(!contentVersionMap.isEmpty()){
                    insert contentVersionMap.Values();
                    createDocDtlWithContentDocumentLink(intgMsgMap,contentVersionMap);
                }
                if(!responses.isEmpty() && !responseMap.isEmpty()){
                    PerfiosRetrieveReportResponseProcessor.processResponses(responses,responseMap);
                }
                
            }
            
        } 
        catch (Exception e) {
            System.debug('Exception: ' + e.getMessage()+ ' line: ' + e.getLineNumber());
        }
    }
    
    private static void createDocDtlWithContentDocumentLink(Map<Id,IntgMsg__c> intgMsgMap, Map<String, ContentVersion> contentVersionMap){
        Map<Id, Id> idConDocMap = new Map<Id, Id>();
        Map<String,String> refIdMap = new Map<String,String>();
        List<ContentDocumentLink> ContentDocumentLinkList = new List<ContentDocumentLink>();
		Set<Id> applBankingIds = new Set<Id>();
		Map<Id,DocDtl__c>  appBankingdocDtlMap = new Map<Id,DocDtl__c>();
		Set<Id> existingRecordIds = new Set<Id>();
		Map<Id,Id> idDocDtlMap = new Map<Id,Id>();
		
		for(IntgMsg__c intgMsg: intgMsgMap.Values()){
			if(intgMsg.ParentRefId__c!=null){
				applBankingIds.add(intgMsg.ParentRefId__c);
			}
		}
		
		Map<Id,ApplBanking__c> applBankingMap = new Map<Id,ApplBanking__c>([Select Id,Appl__c,LoanAppl__c FROM ApplBanking__c WHERE ID IN:applBankingIds]);
		
        
        for(ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionMap.Values()]){
            idConDocMap.put(cv.Id, cv.ContentDocumentId);
        }
        
        for(String str : contentVersionMap.keyset()){
           	List<String> data = str.split('-');
            if(intgMsgMap.containsKey(data[0]) && intgMsgMap.get(data[0]).ParentRefId__c!=null && applBankingMap.containsKey(intgMsgMap.get(data[0]).ParentRefId__c)){
				
				ApplBanking__c applBank = applBankingMap.get(intgMsgMap.get(data[0]).ParentRefId__c);
				existingRecordIds.add(applBank.Id);
				
				DocDtl__c doc = new DocDtl__c();
                doc.Appl__c = applBank.Appl__c;
				doc.ApplBanking__c = applBank.Id;
                doc.LAN__c = applBank.LoanAppl__c;
                doc.DocCatgry__c = 'Perfios Report';
                doc.DocTyp__c = 'Perfios Report';
                doc.DocSubTyp__c = 'Perfios Report';
                doc.IsLatest__c = true;
                appBankingdocDtlMap.put(applBank.Id,doc);
				
			}
		}
        
        if(!existingRecordIds.isEmpty()){
            updateExistingResponse(existingRecordIds);
        }
        if(!appBankingdocDtlMap.isEmpty()){
            insert appBankingdocDtlMap.values();
        }
		
        for(DocDtl__c dtl : [Select ID,ApplBanking__c FROM DocDtl__c WHERE ID IN:appBankingdocDtlMap.values()]){
			idDocDtlMap.put(dtl.ApplBanking__c,dtl.Id);
		}
		
        for(String str : contentVersionMap.keyset()){
		
			List<String> data = str.split('-');
			
			ContentVersion contentVersion = contentVersionMap.get(str);
			ContentDocumentLink cdl = New ContentDocumentLink();
				
			cdl.LinkedEntityId = (intgMsgMap.containsKey(data[0]) && intgMsgMap.get(data[0]).ParentRefId__c!=null && idDocDtlMap.containsKey(intgMsgMap.get(data[0]).ParentRefId__c))  ? idDocDtlMap.get(intgMsgMap.get(data[0]).ParentRefId__c) :data[0];
			cdl.ContentDocumentId = idConDocMap.get(contentVersion.Id);
			cdl.shareType = 'V';
			ContentDocumentLinkList.add(cdl);
		
		}
		
        if(!ContentDocumentLinkList.isEmpty()){
            insert ContentDocumentLinkList;
        }
        
        
    }
    
    public static void updateExistingResponse(Set<Id> recordids){
        if(!recordids.isEmpty()){
            List<DocDtl__c> responses = new List<DocDtl__c>();
            for(DocDtl__c res : [Select ID,DocCatgry__c, DocTyp__c, DocSubTyp__c,ApplBanking__c,IsLatest__c FROM DocDtl__c WHERE ApplBanking__c IN:recordids AND DocCatgry__c='Perfios Report' AND IsLatest__c =true]){
                res.IsLatest__c=false;
                responses.add(res);
            }
            
            if(!responses.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { DocDtl__c.SObjectType });
                List<string> fieldNamesList = New List<string>{'IsLatest__c'};
                    String sObjectName = 'DocDtl__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(responses);
                uow.commitWork();
            }
        }
    }
}