public class CrimeCheckCallbackResponseprocessor implements IintMsgCalloutResponseProcessor{
    
    public static void process(List<IntgMsg__c> responses){
        
        if(!responses.isEmpty()){
            
            Set<Id> intMsgIds =new Set<Id>();
            Map<Id,Id> ContentDocumentMap =new Map<Id,Id>();
            Map<Id,ContentVersion> ContentVersionMap =new Map<Id,ContentVersion>();
            Map<String,CrimeCheckCallbackResponseWrapper> successResponseMap = new Map<String,CrimeCheckCallbackResponseWrapper>();
            Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
            Map<Id,String> intgMsgRefIdsMap = new Map<Id,String>();
            
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
                        String jsonContent = EncodingUtil.urldecode(cvdata.VersionData.toString().substringAfter('='),'UTF-8');
                        
                        if(String.isNotblank(jsonContent)){
                            
                            CrimeCheckCallbackResponseWrapper res =(CrimeCheckCallbackResponseWrapper) JSON.deserialize(jsonContent,CrimeCheckCallbackResponseWrapper.class);
                            
                            if(res!=null && res.requestId!=null){
                                successResponseMap.put(String.valueof(res.requestId),res);
                                intgMsgRefIdsMap.put(intmsg.Id,String.valueof(res.requestId));
                            }
                        }
                        
                        
                    }catch(Exception ex){
                        GlobalUtility.logMessage('Error', 'CrimeCheckCallbackResponseprocessor',
                                                 'process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                        failureResponseMap.put(intmsg,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                    }
                }
            }
            
            if(!successResponseMap.isEmpty()){
                crimeCallbackSuccess(successResponseMap,intgMsgRefIdsMap);
            }
            
             if(!failureResponseMap.isEmpty()){
               crimeCallbackFailure(failureResponseMap);
            }
        }
        
    }
    //**********************************************************************************************************************************
    public static void crimeCallbackSuccess(Map<String,CrimeCheckCallbackResponseWrapper> successResp,Map<Id,String> intgMsgRefIdsMap){
        
        try{
           
            Map<String,APIVer__c> apiVerificationMap =new Map<String,APIVer__c>();
            Set<String> crimeCheckIds =new Set<String>();
            
            List<APIVer__c> apiVerList =new List<APIVer__c>();
            List<APIVerDtl__c> apiVerDtlList =new List<APIVerDtl__c>();
            List<IntgMsg__c> intmsgList =new List<IntgMsg__c>();
            Map<Integer,List<APIVerDtl__c>> apiVerDtlMap =new Map<Integer,List<APIVerDtl__c>>();
            
            for(APIVer__c apiVer:[Select id,RecordType.DeveloperName,CrimeCheckId__c,Appl__c,LoanAplcn__c,IsLatest__c from APIVer__c Where 
                                  RecordType.DeveloperName='CrimeCheck' AND CrimeCheckId__c IN:successResp.keySet() AND IsLatest__c=true]){
                                      
                                      apiVerificationMap.put(apiVer.CrimeCheckId__c,apiVer);
                                  }
            
            //Looping successResp
            for(String crimeID:successResp.keyset()){
                
                if(apiVerificationMap.containsKey(crimeID)){
                    
                    CrimeCheckCallbackResponseWrapper resp =successResp.get(crimeID);
                    APIVer__c apiVer =apiVerificationMap.get(crimeID);
                    apiVer.CrimeCheckCallbackStatus__c='Success';
                    
                    crimeCheckIds.add(crimeID);
                    
                    if(resp!=null){
                        
                        //Updating APIVer__c
                        if(String.isNotblank(resp.requestTime)){
                            apiVer.ReqTime__c=getDateTime(resp.requestTime);
                        }
                        
                        if(String.isNotblank(resp.responseTime)){
                            apiVer.ResTime__c=getDateTime(resp.responseTime);
                        }
                        
                        if(resp.crimewatch!=null && resp.crimewatch!=false){
                            apiVer.CrimeWtch__c=resp.crimewatch;
                        }
                        
                        if(string.isNotblank(resp.downloadLink)){
                            apiVer.DownloadLink__c=resp.downloadLink;
                        }
                        
                        if(string.isNotblank(resp.riskType)){
                            apiVer.RiskType__c=resp.riskType;
                        }
                        
                        if(string.isNotblank(resp.riskSummary)){
                            apiVer.RiskSum__c=resp.riskSummary;
                        }
                        
                        if(resp.numberOfCases!=null){
                            apiVer.numOfCases__c=resp.numberOfCases;
                        }
                        
                        if(string.isNotblank(resp.disclaimer)){
                            // apiVer.Disclaimer__c=resp.disclaimer;
                        }
                        
                        //Creating APIVerDtl__c for searchTerm
                        if(resp.searchTerm!=null){
                            
                            for(CrimeCheckCallbackResponseWrapper.SearchTerm serTerm:resp.searchTerm){
                                
                                APIVerDtl__c apiDtl =new APIVerDtl__c();
                                apiDtl.APIVerification__c=apiVer.Id;
                                apiDtl.Type__c='Crime Check SearchTerm';
                                
                                if(string.isNotblank(serTerm.companyName)){
                                    apiDtl.CmpName__c=serTerm.companyName;
                                }
                                
                                if(string.isNotblank(serTerm.ownerName)){
                                    apiDtl.OwnerName__c=serTerm.ownerName;
                                }
                                
                                if(string.isNotblank(serTerm.cinNumber)){
                                    apiDtl.CinNum__c=serTerm.cinNumber;
                                }
                                
                                if(string.isNotblank(serTerm.address)){
                                    apiDtl.Address__c=serTerm.address;
                                }
                                
                                if(string.isNotblank(serTerm.name)){
                                    apiDtl.Name__c=serTerm.name;
                                }
                                
                                if(string.isNotblank(serTerm.fatherName)){
                                    apiDtl.FatherName__c=serTerm.fatherName;
                                }
                                
                                if(string.isNotblank(serTerm.dob)){
                                    
                                    if(serTerm.dob.contains('/')){
                                        apiDtl.DOB__c=IntegrationUtility.getConvertedDate(serTerm.dob);
                                    }
                                    
                                    else if(serTerm.dob.contains('-')){
                                        apiDtl.DOB__c=IntegrationUtility.getConvertedDate2(serTerm.dob);
                                    }
                                    
                                }
                                
                                apiVerDtlList.add(apiDtl);
                            }
                        }
                        
                        //Creating APIVerDtl__c for caseDetails
                        if(resp.caseDetails!=null){
                            
                            for(CrimeCheckCallbackResponseWrapper.CaseDetails caseDeatils:resp.caseDetails){
                                
                                APIVerDtl__c apiDtl =new APIVerDtl__c();
                                apiDtl.APIVerification__c=apiVer.Id;
                                apiDtl.Type__c='Crime Check Case Details';
                                
                                if(caseDeatils.slNo!=null){
                                    apiDtl.SlNo__c=caseDeatils.slNo;
                                }
                                
                                if(String.isNotblank(caseDeatils.petitioner)){
                                    apiDtl.Petitioner__c=caseDeatils.petitioner;
                                }
                                
                                if(String.isNotblank(caseDeatils.respondent)){
                                    apiDtl.Respondent__c=caseDeatils.respondent;
                                }
                                
                                if(String.isNotblank(caseDeatils.cinNumber)){
                                    apiDtl.CinNum__c=caseDeatils.cinNumber;
                                }
                                
                                if(String.isNotblank(caseDeatils.caseTypeName)){
                                    apiDtl.CaseTypeName__c=caseDeatils.caseTypeName;
                                }
                                
                                if(String.isNotblank(caseDeatils.hearingDate)){
                                    apiDtl.HearingDt__c=IntegrationUtility.getConvertedDate(caseDeatils.hearingDate);
                                }
                                
                                if(String.isNotblank(caseDeatils.courtNumberAndJudge)){
                                    apiDtl.CourtNumJudge__c=caseDeatils.courtNumberAndJudge;
                                }
                                
                                if(String.isNotblank(caseDeatils.courtName)){
                                    apiDtl.CourtName__c=caseDeatils.courtName;
                                }
                                
                                if(String.isNotblank(caseDeatils.state)){
                                    apiDtl.State__c=caseDeatils.state;
                                }
                                
                                if(String.isNotblank(caseDeatils.district)){
                                    apiDtl.District__c=caseDeatils.district;
                                }
                                
                                if(String.isNotblank(caseDeatils.petitionerAddress)){
                                    apiDtl.PetitionerAdrs__c=caseDeatils.petitionerAddress;
                                }
                                
                                if(String.isNotblank(caseDeatils.respondentAddress)){
                                    apiDtl.RespondentAdrs__c=caseDeatils.respondentAddress;
                                }
                                
                                if(String.isNotblank(caseDeatils.caseNumber)){
                                    apiDtl.CaseNum__c=caseDeatils.caseNumber;
                                }
                                
                                if(String.isNotblank(caseDeatils.caseNo)){
                                    apiDtl.CaseNum__c=caseDeatils.caseNo;
                                }
                                
                                if(String.isNotblank(caseDeatils.caseYear)){
                                    apiDtl.CaseYear__c=caseDeatils.caseYear;
                                }
                                
                                if(String.isNotblank(caseDeatils.underAct)){
                                    apiDtl.UnderAct__c=caseDeatils.underAct;
                                }
                                
                                if(String.isNotblank(caseDeatils.section)){
                                    apiDtl.Section__c=caseDeatils.section;
                                }
                                
                                if(String.isNotblank(caseDeatils.underSection)){
                                    apiDtl.UnderSec__c=caseDeatils.underSection;
                                }
                                
                                if(String.isNotblank(caseDeatils.caseStatus)){
                                    apiDtl.CaseStatus__c=caseDeatils.caseStatus;
                                }
                                
                                if(String.isNotblank(caseDeatils.firLink)){
                                    apiDtl.FirLink__c=caseDeatils.firLink;
                                }
                                
                                if(String.isNotblank(caseDeatils.judgementLink)){
                                    apiDtl.JudgementLink__c=caseDeatils.judgementLink;
                                }
                                
                                if(String.isNotblank(caseDeatils.gfc_uniqueid)){
                                    apiDtl.GFCUniqueid__c=caseDeatils.gfc_uniqueid;
                                }
                                
                                if(String.isNotblank(caseDeatils.caseLink)){
                                    apiDtl.CaseLink__c=caseDeatils.caseLink;
                                }
                                
                                if(String.isNotblank(caseDeatils.caseType)){
                                    apiDtl.CaseType__c=caseDeatils.caseType;
                                }
                                
                                if(String.isNotblank(caseDeatils.natureOfDisposal)){
                                    apiDtl.NatureOfDisp__c=caseDeatils.natureOfDisposal;
                                }
                                
                                if(String.isNotblank(caseDeatils.riskType)){
                                    apiDtl.RiskType__c=caseDeatils.riskType;
                                }
                                
                                if(String.isNotblank(caseDeatils.riskSummary)){
                                    apiDtl.RiskSummary__c=caseDeatils.riskSummary;
                                }
                                
                                if(String.isNotblank(caseDeatils.severity)){
                                    apiDtl.Severity__c=caseDeatils.severity;
                                }
                                
                                if(String.isNotblank(caseDeatils.judgementSummary)){
                                    apiDtl.JudgementSummary__c=caseDeatils.judgementSummary;
                                }
                                
                                if(String.isNotblank(caseDeatils.caseRegDate)){
                                    apiDtl.CaseRegDt__c=IntegrationUtility.getConvertedDate3(caseDeatils.caseRegDate);
                                }
                                
                                if(String.isNotblank(caseDeatils.regNumber)){
                                    apiDtl.RegNum__c=caseDeatils.regNumber;
                                }
                                
                                if(String.isNotblank(caseDeatils.filingDate)){
                                    apiDtl.FilingDt__c=IntegrationUtility.getConvertedDate3(caseDeatils.filingDate);
                                }
                                
                                if(String.isNotblank(caseDeatils.filingNumber)){
                                    apiDtl.FilingNum__c=caseDeatils.filingNumber;
                                }
                                
                                if(String.isNotblank(caseDeatils.courtType)){
                                    apiDtl.CourtType__c=caseDeatils.courtType;
                                }
                                
                                if(String.isNotblank(caseDeatils.matchingAddress)){
                                    apiDtl.MatchingAdrs__c=caseDeatils.matchingAddress;
                                }
                                
                                if(String.isNotblank(caseDeatils.matchSummary)){
                                    apiDtl.MatchSum__c=caseDeatils.matchSummary;
                                }
                                
                                if(String.isNotblank(caseDeatils.caseDetailsLink)){
                                    apiDtl.CaseDetailLink__c=caseDeatils.caseDetailsLink;
                                }
                                
                                apiVerDtlList.add(apiDtl);
                                
                                //Creating APIVerDtl__c gfc_respondents
                                if(caseDeatils.gfc_respondents!=null){
                                    
                                    for(CrimeCheckCallbackResponseWrapper.GFCrespondents respondents:caseDeatils.gfc_respondents){
                                        
                                        APIVerDtl__c apiverDtl =new APIVerDtl__c();
                                        apiverDtl.APIVerification__c=apiVer.Id;
                                        apiverDtl.Type__c='Crime Check GFC Respondents';
                                        
                                        if(string.isNotBlank(respondents.name)){
                                            apiverDtl.Name__c=respondents.name;
                                        }
                                        
                                        if(string.isNotBlank(respondents.address)){
                                            apiverDtl.Address__c=respondents.address;
                                        }
                                        
                                        if(apiVerDtlMap.containsKey(caseDeatils.slNo)){
                                            apiVerDtlMap.get(caseDeatils.slNo).add(apiverDtl);
                                        }else{
                                            apiVerDtlMap.put(caseDeatils.slNo,new List<APIVerDtl__c>{apiverDtl});
                                        }
                                    }
                                }
                                
                                //Creating APIVerDtl__c gfc_petitioners
                                if(caseDeatils.gfc_petitioners!=null){
                                    
                                    for(CrimeCheckCallbackResponseWrapper.GFCrespondents petitioners:caseDeatils.gfc_petitioners){
                                        
                                        APIVerDtl__c apiverDtl =new APIVerDtl__c();
                                        apiverDtl.APIVerification__c=apiVer.Id;
                                        apiverDtl.Type__c='Crime Check GFC Petitioners';
                                        
                                        
                                        if(string.isNotBlank(petitioners.name)){
                                            apiverDtl.Name__c=petitioners.name;
                                        }
                                        
                                        if(string.isNotBlank(petitioners.address)){
                                            apiverDtl.Address__c=petitioners.address;
                                        }
                                        
                                        
                                        if(apiVerDtlMap.containsKey(caseDeatils.slNo)){
                                            apiVerDtlMap.get(caseDeatils.slNo).add(apiverDtl);
                                        }else{
                                            apiVerDtlMap.put(caseDeatils.slNo,new List<APIVerDtl__c>{apiverDtl});
                                        }
                                    }
                                }
                                
                                //Creating APIVerDtl__c caseFlow
                                if(caseDeatils.caseFlow!=null){
                                    
                                    for(CrimeCheckCallbackResponseWrapper.CaseFlow caseflow:caseDeatils.caseFlow){
                                        
                                        
                                        APIVerDtl__c apiverDtl =new APIVerDtl__c();
                                        apiverDtl.APIVerification__c=apiVer.Id;
                                        apiverDtl.Type__c='Crime Check Case Flow';
                                        
                                        if(string.isNotBlank(CaseFlow.Order)){
                                            apiverDtl.Order__c=CaseFlow.Order;
                                        }
                                        
                                        if(string.isNotBlank(CaseFlow.gfc_OrderType)){
                                            apiverDtl.OrderType__c=CaseFlow.gfc_OrderType;
                                        }
                                        
                                        if(string.isNotBlank(CaseFlow.orderDate)){
                                            apiverDtl.OrderDte__c=IntegrationUtility.getConvertedDate3(CaseFlow.orderDate);
                                        }
                                        
                                        if(string.isNotBlank(CaseFlow.orderLink)){
                                            apiverDtl.OrderLink__c=CaseFlow.orderLink;
                                        }
                                        
                                        if(string.isNotBlank(CaseFlow.elastic_id)){
                                            apiverDtl.ElasticId__c=CaseFlow.elastic_id;
                                        }
                                        
                                        if(string.isNotBlank(CaseFlow.index)){
                                            apiverDtl.Index__c=CaseFlow.index;
                                        }
                                        
                                        
                                        if(apiVerDtlMap.containsKey(caseDeatils.slNo)){
                                            apiVerDtlMap.get(caseDeatils.slNo).add(apiverDtl);
                                        }else{
                                            apiVerDtlMap.put(caseDeatils.slNo,new List<APIVerDtl__c>{apiverDtl});
                                        }
                                    }
                                }
                            }
                            
                            
                        }
                        apiVerList.add(apiVer);
                        
                    }
                }
            }
            
            //Looping intgMsgRefIdsMap
            for(Id intId:intgMsgRefIdsMap.keyset()){
                
                IntgMsg__c intmsg =new IntgMsg__c();
                intmsg.Id=intId;
                intmsg.Status__c = 'Processed';
                
                if(apiVerificationMap.containsKey(intgMsgRefIdsMap.get(intId))){
                    
                    if(apiVerificationMap.get(intgMsgRefIdsMap.get(intId)).LoanAplcn__c!=null){
                        intmsg.LoanAppln__c=apiVerificationMap.get(intgMsgRefIdsMap.get(intId)).LoanAplcn__c;
                    }
                    
                    if(apiVerificationMap.get(intgMsgRefIdsMap.get(intId)).Appl__c!=null){
                        intmsg.Appl__c=apiVerificationMap.get(intgMsgRefIdsMap.get(intId)).Appl__c;
                    }
                }
                intmsgList.add(intmsg);
            }
            
            //Creating IntgMsg to call PDF Report
            if(!crimeCheckIds.isEmpty()){
                
                for(String crimeIDs:crimeCheckIds){
                    
                    IntgMsg__c intmsg =new IntgMsg__c();
                    intmsg.Name='Crime Download Report';
                    intmsg.Status__c='New';
                    intmsg.MStatus__c='Blank';
                    intmsg.BU__c='HL / STL';
                    intmsg.RefId__c=crimeIDs;
                    intmsg.RefObj__c='APIVer__c';
                    intmsg.Svc__c='Crime Download Report';
                    intmsg.IsActive__c=true;
                    
                    intmsgList.add(intmsg);
                }
            }
            
            //Updating the APIVer__c
            if(!apiVerList.isEmpty()) {
                update apiVerList;
            }
            
             //Creating the APIVerDtl__c
            if(!apiVerDtlList.isEmpty()) {
                Insert apiVerDtlList;
            }
            
            //Checking apiVerDtlMap to make selflook up
            if(!apiVerDtlMap.isEmpty() && !apiVerDtlList.isEmpty() && !crimeCheckIds.isEmpty()){
                processAPIVerDtlMap(apiVerDtlMap,crimeCheckIds);
            }
            
            //Upserting the IntgMsg__c
            if(!intmsgList.isEmpty()) {
                
                upsert intmsgList;
            }
           
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrimeCheckCallbackResponseprocessor',
                                     'crimeCallbackSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
    }
    //******************************************************************************************************************************************
    public static void processAPIVerDtlMap(Map<Integer,List<APIVerDtl__c>> APIVerDtlMap,Set<String> crimeCheckIds){
        
        try{
            
            Map<Integer,APIVerDtl__c> VerDetailMap =new Map<Integer,APIVerDtl__c >();
            List<APIVerDtl__c> apiVerDtlList =new List<APIVerDtl__c>();
            
            for(APIVerDtl__c ver:[Select id,SlNo__c,APIVerification__r.IsLatest__c,APIVerification__r.CrimeCheckId__c from APIVerDtl__c Where SlNo__c IN:APIVerDtlMap.keyset() AND
                                 APIVerification__r.IsLatest__c=true AND APIVerification__r.CrimeCheckId__c IN:crimeCheckIds]){
                
                VerDetailMap.put(Integer.valueOf(ver.SlNo__c),ver);
            }
            
            for(Integer slno:APIVerDtlMap.keyset()){
                
                if(VerDetailMap.containsKey(slno)){
                    
                    APIVerDtl__c parentVerDtl =VerDetailMap.get(slno);
                        
                    List<APIVerDtl__c> apiVer=APIVerDtlMap.get(slno);
                    
                    if(apiVer!=null){
                        
                        for(APIVerDtl__c dtl:apiVer){
                            
                            dtl.ApiVerDetails__c=parentVerDtl.Id;
                            
                            apiVerDtlList.add(dtl);
                        }
                    }
                }
            }
            
            
            if(!apiVerDtlList.isEmpty()){
                Insert apiVerDtlList;
            }
            
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrimeCheckCallbackResponseprocessor',
                                     'processAPIVerDtlMap', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
    }
    //******************************************************************************************************************************************
    public static void crimeCallbackFailure(Map<IntgMsg__c,String> failureMap){
        
        try{
            
            List<IntgMsg__c> msgList =new List<IntgMsg__c>();
            
                
            for(IntgMsg__c msg:failureMap.keyset()){
                
                IntgMsg__c intmsg =new IntgMsg__c();
                intmsg.Id=msg.Id;
                intmsg.Resp__c=msg.Resp__c+'\n'+failureMap.get(msg);
                msgList.add(intmsg);
            }
            
            if(!msgList.isEmpty()){
               Update msgList; 
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrimeCheckCallbackResponseprocessor',
                                     'crimeCallbackFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
    }
    //**********************************************************************************************************************************
    Public Static DateTime getDateTime(string datetimeValue){
        
        DateTime datTie;
        
        try{
            
           
            // Split the string into date and time components
            List<String> parts = datetimeValue.split(' ');
            
            String datePart = parts[0];
            String timePart = parts[1] + ' ' + parts[2];
            
            // Split the date part into day, month, and year
            List<String> dateParts = datePart.split('/');
            Integer day = Integer.valueOf(dateParts[0]);
            Integer month = Integer.valueOf(dateParts[1]);
            Integer year = Integer.valueOf(dateParts[2]);
            
            // Parse the time part
            String[] timeParts = timePart.split(':');
            Integer hour = Integer.valueOf(timeParts[0]);
            Integer minute = Integer.valueOf(timeParts[1].substring(0, 2));
            String period = timeParts[1].substring(3);
            
            // Adjust hour based on AM/PM
            if (period == 'pm' && hour != 12) {
                hour += 12;
            } else if (period == 'am' && hour == 12) {
                hour = 0;
            }
            
            // Create Date and Time objects
            Date dt = Date.newInstance(year, month, day);
            Time tme = Time.newInstance(hour, minute, 0, 0);
            
            // Combine Date and Time into DateTime
            datTie = DateTime.newInstance(dt, tme);
            
           
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrimeCheckCallbackResponseprocessor',
                                     'getDateTime', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
        return datTie;
         
    }
}