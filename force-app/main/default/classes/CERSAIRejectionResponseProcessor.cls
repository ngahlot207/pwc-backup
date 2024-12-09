public class CERSAIRejectionResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    public static void process(List<IntgMsg__c> responses){
        if(!responses.isEmpty()){
            
            Set<Id> intMsgIds =new Set<Id>();
            Map<Id,Id> ContentDocumentMap =new Map<Id,Id>();
            Map<Id,ContentVersion> ContentVersionMap =new Map<Id,ContentVersion>();
            Map<String,CERSAIRejectionResponseWrapper.Request> resposneMap =new Map<String,CERSAIRejectionResponseWrapper.Request>();
            List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>(); 
            for(IntgMsg__c msg:responses){
                intMsgIds.add(msg.Id);
            }
            
            //Getting ContentDocumentId 
            for(ContentDocumentLink cdl:[SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:intMsgIds AND 
                                         ContentDocument.Title = 'response.json']){
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
                        
                        CERSAIRejectionResponseWrapper response = (CERSAIRejectionResponseWrapper) JSON.deserialize(cvdata.VersionData.toString().replace('__c',''),CERSAIRejectionResponseWrapper.class);
                        
                        if(response!=null && response.Req!=null && !response.Req.isEmpty()){
                            for(CERSAIRejectionResponseWrapper.Request request : response.Req){
                                if(request.SourceSystemCustomerCode!=null && String.isNotblank(request.SourceSystemCustomerCode)){
                                    if(!resposneMap.containsKey(request.SourceSystemCustomerCode)){
                                        resposneMap.put(request.SourceSystemCustomerCode,request);
                                    }
                                }
                            }
                        }
                    }
                    catch(Exception ex){
                        GlobalUtility.logMessage('Error', 'CERSAIRejectionResponseProcessor',
                                                 'process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                    }
                    
                    IntgMsg__c intg=New IntgMsg__c();
                    intg.id=intmsg.Id;
                    intg.Status__c = 'Processed';
                    updateIntRecords.add(intg);
                }
                
                
            }
            
            
            if(!updateIntRecords.isEmpty()){
                update updateIntRecords;
            }
            if(!resposneMap.isEmpty()){
                processResponses(resposneMap);
            }   
        }
        
    }
    
    public static Void processResponses(Map<String,CERSAIRejectionResponseWrapper.Request> responseMap){
        
        try{
            
            Map<String,Applicant__c> applicantMap =new Map<String,Applicant__c>();
            List<Applicant__c> applist =new List<Applicant__c>();
            for(Applicant__c app:[SELECT id,UCID__c,LoanAppln__c,IntegrationStatus__c,IntegrationErrorMessage__c FROM Applicant__c WHERE LoanAppln__r.Stage__c = 'Disbursed' AND CKYC_API_Status__c ='Success'  AND CKYC_Number__c=null AND UCID__c IN:responseMap.keySet()]){
                
                if(!applicantMap.containsKey(app.UCID__c)){
                    applicantMap.put(app.UCID__c,app);
                }
                
            }
            
            for(String key : responseMap.keySet()){
                if(responseMap.containsKey(key) && applicantMap.containskey(key)){
                    CERSAIRejectionResponseWrapper.Request response = responseMap.get(key);
                    Applicant__c app =new Applicant__c();
                    app.Id=applicantMap.get(key).Id;
                    app.IntegrationStatus__c = replaceAndUpdateString('CERSAI Rejection Callback:', 'CERSAI Rejection Callback: Failure',applicantMap.get(key).IntegrationStatus__c, ';');
                    app.IntegrationErrorMessage__c = replaceAndUpdateString('CERSAI Rejection Callback:', 'CERSAI Rejection Callback: ' + (response.Remarks!=null && String.isNotBlank(response.Remarks) ? response.Remarks : response.PreviousRejectionByTW!=null ? response.PreviousRejectionByTW : ''),applicantMap.get(key).IntegrationErrorMessage__c, ';');
                    app.CKYC_API_Status__c = 'Failure';
                    app.CKYC_API_ErrorMessage__c = (response.Remarks!=null && String.isNotBlank(response.Remarks) ? response.Remarks : response.PreviousRejectionByTW!=null ? response.PreviousRejectionByTW : '');
                    applist.add(app);
                }
                
            }
            if(!applist.isEmpty()){
                Update applist;
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'TrackwizzResponseprocessor',
                                     'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    } 
    
    public static string replaceAndUpdateString(String toRemove, String toAdd,String actualString,String splitIdentifier){
        String updatedString;
        List<String> updatedStringList = new List<String>();
        if(String.isNotBlank(actualString)){
            List<String> existingStringList = actualString.split(splitIdentifier);
            system.debug(existingStringList);
            if(!existingStringList.isEmpty()){
                for(string value : existingStringList){
                    if(!value.contains(toRemove)){
                        updatedStringList.add(value);
                    }
                }
            }
        }	
        if(String.isNotBlank(toAdd)){
            updatedStringList.add(toAdd);
        }
        
        updatedString= String.join(updatedStringList,splitIdentifier).removeStart(splitIdentifier).removeEnd(splitIdentifier);
        system.debug(updatedString);
        return updatedString; 
    }
}