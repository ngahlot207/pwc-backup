public class CrimeCheckPdfReportResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    public static void process(List<IntgMsg__c> responses){
        
        if(!responses.isEmpty()){
            
            Set<Id> intMsgIds =new Set<Id>();
            Map<Id,Id> ContentDocumentMap =new Map<Id,Id>();
            Map<Id,ContentVersion> ContentVersionMap =new Map<Id,ContentVersion>();
            Map<IntgMsg__c,blob> pdfMap =new Map<IntgMsg__c,blob>();
            Map<IntgMsg__c,CrimeCheckPdfReportResponseWrapper> jsonMap =new Map<IntgMsg__c,CrimeCheckPdfReportResponseWrapper>();
            
            for(IntgMsg__c msg:responses){
                intMsgIds.add(msg.Id);
            }
            
            
            //Getting ContentDocumentId 
            for(ContentDocumentLink cdl:[SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:intMsgIds]){
                ContentDocumentMap.put(cdl.LinkedEntityId,cdl.ContentDocumentId);   
            }
            //Getting VersionData 
            for(ContentVersion cv:[SELECT Id, VersionData,FileType,ContentDocumentId FROM ContentVersion
                                   WHERE ContentDocumentId IN:ContentDocumentMap.values()]){
                                       ContentVersionMap.put(cv.ContentDocumentId,cv);
                                   }
            
            
            for(IntgMsg__c intmsg:responses){
                
                if(ContentDocumentMap.containskey(intMsg.id) && ContentVersionMap.containskey(ContentDocumentMap.get(intMsg.id))){
                    
                    try{
                        ContentVersion cvdata=ContentVersionMap.get(ContentDocumentMap.get(intMsg.id));
                        
                        if(cvdata.FileType.tolowercase()=='pdf'){
                            pdfMap.put(intmsg,cvdata.VersionData);
                        }
                        else if(cvdata.FileType.tolowercase()=='json'){
                            
                            String jsonContent=cvdata.VersionData.toString();
                            
                            CrimeCheckPdfReportResponseWrapper res =(CrimeCheckPdfReportResponseWrapper) JSON.deserialize(jsonContent,CrimeCheckPdfReportResponseWrapper.class); 
                            
                            if(res!=null){
                                jsonMap.put(intmsg,res);
                            }
                        }
                        
                    }catch(Exception ex){
                        GlobalUtility.logMessage('Error', 'CrimeCheckPdfReportResponseProcessor',
                                                 'process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                        
                    }
                }
            }
            
            if(!pdfMap.isEmpty()){
                processPdf(pdfMap);
            }
            if(!jsonMap.isEmpty()){
                processJson(jsonMap);
            }
        }
    }
    //**********************************************************************************************************************************************
    public static void processPdf(Map<IntgMsg__c,blob> pdfResp){
        
        try{
            
            Set<String> crimeRequestIds =new Set<String>();
            Map<String,APIVer__c> apiVerificationMap =new Map<String,APIVer__c>();
            List<APIVer__c> apiVerList =new List<APIVer__c>();
            
            List<ContentVersion> ContentVersionList =new List<ContentVersion>();
            List<IntgMsg__c> IntgMsgList =new List<IntgMsg__c>();
            
            
            for(IntgMsg__c intmsg:pdfResp.keyset()){
                
                if(String.isNotblank(intmsg.RefId__c)){
                    crimeRequestIds.add(intmsg.RefId__c);
                }
            }
            
            if(!crimeRequestIds.isEmpty()){
                
                for(APIVer__c apiVer:[Select id,RecordType.DeveloperName,CrimeCheckId__c,Appl__c,LoanAplcn__c,IsLatest__c from APIVer__c Where 
                                      RecordType.DeveloperName='CrimeCheck' AND CrimeCheckId__c IN:crimeRequestIds AND IsLatest__c=true]){//
                                          
                                          apiVerificationMap.put(apiVer.CrimeCheckId__c,apiVer);
                                      }
            }
            
            //Looping resposne
            for(IntgMsg__c intmsg:pdfResp.keyset()){
                
                if(String.isNotblank(intmsg.RefId__c) && apiVerificationMap.containsKey(intmsg.RefId__c) &&
                  pdfResp.get(intmsg)!=null){
                    
                    APIVer__c apiVer =apiVerificationMap.get(intmsg.RefId__c);
                    apiver.CrimeCheckPdfReportMsg__c='Success';
                    apiver.CrimeCheckPdfReportStatus__c='Success';
                    apiVerList.add(apiver);  
                      
                    ContentVersion contentVersion = new ContentVersion();
                    contentVersion.VersionData =pdfResp.get(intmsg);
                    contentVersion.Title = 'Crime Check Report';
                    contentVersion.PathOnClient = 'Crime Check Report.pdf';
                    contentVersion.FirstPublishLocationId = apiVer.Id;
                    ContentVersionList.add(contentVersion);
                      
                      IntgMsg__c msg =new IntgMsg__c();
                      msg.Id=intmsg.Id;
                      msg.LoanAppln__c=apiVer.LoanAplcn__c;
                      msg.Appl__c=apiVer.Appl__c;
                      IntgMsgList.add(msg);
                }
                
                APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Success');
            }
            
            if(!ContentVersionList.isEmpty()){
                insert ContentVersionList;
            }
            
            if(!apiVerList.isEmpty()){
                update apiVerList;
            }
            
            if(!IntgMsgList.isEmpty()){
                update IntgMsgList;
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrimeCheckPdfReportResponseProcessor class', 
                                     'processPdf', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    //**********************************************************************************************************************************************
    public static void processJson(Map<IntgMsg__c,CrimeCheckPdfReportResponseWrapper> jsonResp){
        
        try{
            
            Set<String> crimeRequestIds =new Set<String>();
            Map<String,APIVer__c> apiVerificationMap =new Map<String,APIVer__c>();
           
            List<APIVer__c> apiVerList =new List<APIVer__c>();
            List<IntgMsg__c> IntgMsgList =new List<IntgMsg__c>();
            
            for(IntgMsg__c intmsg:jsonResp.keyset()){
                
                if(String.isNotblank(intmsg.RefId__c)){
                    crimeRequestIds.add(intmsg.RefId__c);
                }
            }
             if(!crimeRequestIds.isEmpty()){
                
                for(APIVer__c apiVer:[Select id,RecordType.DeveloperName,CrimeCheckId__c,Appl__c,LoanAplcn__c,IsLatest__c from APIVer__c Where 
                                      RecordType.DeveloperName='CrimeCheck' AND CrimeCheckId__c IN:crimeRequestIds AND IsLatest__c=true]){
                                          
                                          apiVerificationMap.put(apiVer.CrimeCheckId__c,apiVer);
                                      }
            }
            
             //Looping resposne
            for(IntgMsg__c intmsg:jsonResp.keyset()){
                
                if(String.isNotblank(intmsg.RefId__c) && apiVerificationMap.containsKey(intmsg.RefId__c) &&
                   jsonResp.get(intmsg)!=null){
                       
                       APIVer__c apiVer =apiVerificationMap.get(intmsg.RefId__c);
                       
                       CrimeCheckPdfReportResponseWrapper res =jsonResp.get(intmsg);
                       
                       if(String.isNotblank(res.message)){
                             apiver.CrimeCheckPdfReportMsg__c=res.message;
                        }
                       apiver.CrimeCheckPdfReportStatus__c='Failure';
                       
                       apiVerList.add(apiVer);
                       
                       IntgMsg__c msg =new IntgMsg__c();
                       msg.Id=intmsg.Id;
                       msg.LoanAppln__c=apiVer.LoanAplcn__c;
                       msg.Appl__c=apiVer.Appl__c;
                       IntgMsgList.add(msg);
                   }
                
                APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
            }
            
            if(!apiVerList.isEmpty()){
                update apiVerList;
            }
            
            if(!IntgMsgList.isEmpty()){
                update IntgMsgList;
            }
            
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrimeCheckPdfReportResponseProcessor class', 
                                     'processJson', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
}