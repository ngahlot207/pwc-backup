public class TrackwizzCallbackResponseProcessor {
    
    
    public Static void process(List<IntgMsg__c> responses){
        try{
            //fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
            //List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>(); 
            //Map<String,ScreeningResponseWrapper> screeningResponseMap=new  Map<String,ScreeningResponseWrapper>();
            Map<String,RiskRatingWrapper> riskRatingResponseMap=new  Map<String,RiskRatingWrapper>();
            //Map<Id,String> riskRatingResponseMap = new Map<Id,String>();
            Map<String,String> intgMsgRefIdsMap = new Map<String,String>();
            for(IntgMsg__c integrationMessage:responses){
                if(integrationMessage.Req__c!=null){
                    if(!isScreeningResponse(integrationMessage.Req__c)){
                        Map<String,RiskRatingWrapper> responseMap = getRiskRatingJsonFormat(integrationMessage.Req__c);
                        if(!responseMap.isEmpty()){
                            riskRatingResponseMap.putAll(responseMap);
                            List<String> refIds = new List<String>(responseMap.keyset());
                            intgMsgRefIdsMap.put(integrationMessage.Id,refIds[0]);
                        }
                    }
                    /*IntgMsg__c intg=New IntgMsg__c();
                    intg.id=integrationMessage.Id;
                    intg.Status__c = 'Processed';
                    updateIntRecords.add(intg);*/
                }
            }
            if(!riskRatingResponseMap.isEmpty()){
                processRiskRatingResponse(intgMsgRefIdsMap,riskRatingResponseMap);
            }
            /*if(!updateIntRecords.isEmpty()) {
                String sObjectName = 'IntgMsg__c';
                List<String> fieldNamesList = new List<String>{'Status__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(updateIntRecords);
            }
            uow.commitWork();*/
            
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        } 
    }
    
    public static boolean isScreeningResponse(string value){
        try
        {
            TrackwizzCallbackResponseProcessor.ScreeningResponseWrapper json = TrackwizzCallbackResponseProcessor.ScreeningResponseWrapper.parse(value);
            return true;
        }
        catch(Exception ex)
        {
            return false;
        }
    }
    
    public static void processRiskRatingResponse(Map<String,String> intgMsgRefIdsMap,Map<String,RiskRatingWrapper> responseMap){
        if(!responseMap.isEmpty()){
            Map<String,APIVer__c> apiVerMap = new Map<String,APIVer__c>();
            List<APIVer__c> apiVerList = new List<APIVer__c>();
            List<IntgMsg__c> updateIntgMsgRecords = new List<IntgMsg__c>(); 
            for(APIVer__c ver : [Select Id,IsLatest__c,Appl__r.Name,Appl__c,LoanAplcn__c FROM APIVer__c WHERE IsLatest__c=True AND Appl__r.Name IN :responseMap.keySet() AND RecordType.Name='Risk Rating']){
                apiVerMap.put(ver.Appl__r.Name,ver);
            }

            for(String  res : responseMap.keySet()){
                if(apiVerMap.containsKey(res)){
                    RiskRatingWrapper response = responseMap.get(res);
                    if(response!=null){
                        APIVer__c apVer= new APIVer__c(); 
                        apVer.Id = apiVerMap.get(res).Id;
                        apVer.Risk_Rating_Final__c = response.Risk;
                        apVer.Risk_Rating_Decision__c='Call back is not required :'+response.Risk;
                        apVer.Risk_Rating_System__c = response.Risk;
                        apiVerList.add(apVer);
                    }
                    
                    
                }
            } 
            if(!intgMsgRefIdsMap.isEmpty()){
                    for(String intgMsgId : intgMsgRefIdsMap.keySet()){
                        IntgMsg__c intg = new IntgMsg__c();
                        intg.id =  intgMsgId;
                        intg.Status__c = 'Processed';
                        if(apiVerMap.containskey(intgMsgRefIdsMap.get(intgMsgId))){
                            if(apiVerMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAplcn__c!=null){
                                intg.LoanAppln__c = apiVerMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAplcn__c;
                            }
                            /*if(apiVerMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppln__r.Appl__c!=null){
                                intg.Appl__c = apiVerMap.get(intgMsgRefIdsMap.get(intgMsgId)).Appl__c;
                            }*/
                        }
                        updateIntgMsgRecords.add(intg);
                    }
                    
                }
            if(!apiVerList.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { APIVer__c.SObjectType });  
                List<string> fieldNamesList = New List<string>{'Risk_Rating_Final__c','Risk_Rating_Decision__c','Risk_Rating_System__c'};
                    String sObjectName = 'APIVer__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(apiVerList);
                uow.commitWork();
            }
            if(updateIntgMsgRecords!=null && !updateIntgMsgRecords.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });  
                String sObjectName = 'IntgMsg__c';
                List<String> fieldNamesList = new List<String>{'Status__c','LoanAppln__c','Appl__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(updateIntgMsgRecords);
                uow.commitWork();
            }
        }
        
    }
    public class ScreeningResponseWrapper{
        public String apiToken;	//ApiToken
        public String requestId;	//a94e7144-c1ea-450a-8525-3ad9fa63c556
        public String parentCompany;	//TSS
        public String sourceSystem;	//Finacle
        public List<ScreeningCaseRequestTransactions> screeningCaseRequestTransactions;
    }
    public class ScreeningCaseRequestTransactions{
        public String transactionId;	//f9d1e6a6-05ff-4075-a690-babbbe543c12
        public String recordIdentifier;
        public Integer caseId;	//1
        public String caseUrl;	//www.google.com/1
        public String finalDecision;	//AcceptBusiness
        public String pepCode;	//NotAPEP
        public String pepClassificationCode;	//CORPE 3
        public String adverseMediaClassificationCode;	//16
        public String reputationalClassificationCode;	//TW02
        public String Pep;	//Not A PEP
        public String pepClassification;	//UBO / AP is domestic PEP,Foreign PEP, CURRENT OR FORMER MP, MLA OR MLC
        public String adverseMediaClassification;	//Economic Offence Wing (EOW), Corruption
        public String reputationalClassification;	//Regulatory Enforcement, Other Bodies
        public String finalRemarks;
        public String approvedOn;	//25-May-2021 12:09
        public String approvedBy;	//Nate Johnson
    }
    public static TrackwizzCallbackResponseProcessor.ScreeningResponseWrapper parse(String json){
        return (TrackwizzCallbackResponseProcessor.ScreeningResponseWrapper) System.JSON.deserialize(json, TrackwizzCallbackResponseProcessor.ScreeningResponseWrapper.class);
    }
    
    public static Map<String,RiskRatingWrapper> getRiskRatingJsonFormat(String strResp){
        Map<String,RiskRatingWrapper> responseMap = new Map<String,RiskRatingWrapper>();
        //String strResp='<?xml version="1.0" encoding="utf-16"?><CustomerLevelRiskRatingStatusRequest xmlns:xsd="http://www.w3.org/2001/XMLSchema"xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><RequestId>c4ed528c-a026-445c-a1d9-eb94b4fd01b7</RequestId><ApiToken>8d557611-6e73-4d86-ab74-614a70048743</ApiToken><ParentCompany>TSSCPL</ParentCompany><SourceSystem>Finacle</SourceSystem><CustomerRequestDetails><CustomerRequestDetail><TransactionId>03905d94-41e6-4734-9fb1-e6ab0b1d0240</TransactionId><RecordIdentifier>DHFHFIIO656L566</RecordIdentifier><CustomerSegmentDetails><CustomerSegmentDetail><CustomerSegment>Retail</CustomerSegment><StartDate>09-Oct-2020</StartDate><EndDate /></CustomerSegmentDetail></CustomerSegmentDetails><FinalDecision>Accept Business</FinalDecision><Risk>High</Risk><NextReviewDate>27-Jun-2020</NextReviewDate><ReviewCompletionDate>11-Jun-2021</ReviewCompletionDate><ApprovedRiskSetBy>Nisarg Mehta</ApprovedRiskSetBy><ApprovedRiskRemarks>Approved</ApprovedRiskRemarks><CaseUrl>http://appprod1:44321/crm/crmmenu/menu#/riskrating/actionable/edit/RiskRatingF989/3344</CaseUrl><CaseId>3344</CaseId></CustomerRequestDetail><CustomerRequestDetail><TransactionId>03905d94-41e6-4734-9fb1-e6ab0b1d0240</TransactionId><RecordIdentifier>DHFHFIIO656L565</RecordIdentifier><CustomerSegmentDetails><CustomerSegmentDetail><CustomerSegment>Retail</CustomerSegment><StartDate>09-Oct-2020</StartDate><EndDate /></CustomerSegmentDetail></CustomerSegmentDetails><FinalDecision>Accept Business</FinalDecision><Risk>High</Risk><NextReviewDate>27-Jun-2020</NextReviewDate><ReviewCompletionDate>11-Jun-2021</ReviewCompletionDate><ApprovedRiskSetBy>Nisarg Mehta</ApprovedRiskSetBy><ApprovedRiskRemarks>Approved</ApprovedRiskRemarks><CaseUrl>http://appprod1:44321/crm/crmmenu/menu#/riskrating/actionable/edit/RiskRatingF989/3344</CaseUrl><CaseId>3344</CaseId></CustomerRequestDetail></CustomerRequestDetails></CustomerLevelRiskRatingStatusRequest>';
        Dom.Document doc = new Dom.Document();  
        doc.load(strResp);              
        Dom.XMLNode rootElement = doc.getRootElement(); 
        
        for (Dom.XMLNode childElement : rootElement.getChildElements()) {
            for (Dom.XMLNode detailElement : childElement.getChildElements()){
                RiskRatingWrapper response = new RiskRatingWrapper();
                for (Dom.XMLNode detailElement1 : detailElement.getChildElements()){
                    //childs elements of each childs array
                    system.debug('::::::::'+detailElement1.getName()+':::::::::::'+detailElement1.getText());
                    if(detailElement1.getName()=='RecordIdentifier' && String.isNotBlank(detailElement1.getText())){
                        response.RecordIdentifier = detailElement1.getText();
                    } 
                    if(detailElement1.getName()=='FinalDecision' && String.isNotBlank(detailElement1.getText())){
                        response.FinalDecision = detailElement1.getText();
                    }
                    if(detailElement1.getName()=='Risk' && String.isNotBlank(detailElement1.getText())){
                        response.Risk = detailElement1.getText();
                    } 
                    if(detailElement1.getName()=='NextReviewDate' && String.isNotBlank(detailElement1.getText())){
                        response.NextReviewDate = detailElement1.getText();
                    }
                    if(detailElement1.getName()=='ReviewCompletionDate' && String.isNotBlank(detailElement1.getText())){
                        response.ReviewCompletionDate = detailElement1.getText();
                    } 
                    if(detailElement1.getName()=='ApprovedRiskSetBy' && String.isNotBlank(detailElement1.getText())){
                        response.ApprovedRiskSetBy = detailElement1.getText();
                    }
                    if(detailElement1.getName()=='ApprovedRiskRemarks' && String.isNotBlank(detailElement1.getText())){
                        response.ApprovedRiskRemarks = detailElement1.getText();
                    } 
                    if(detailElement1.getName()=='CaseUrl' && String.isNotBlank(detailElement1.getText())){
                        response.CaseUrl = detailElement1.getText();
                    }
                    if(detailElement1.getName()=='CaseId' && String.isNotBlank(detailElement1.getText())){
                        response.CaseId = detailElement1.getText();
                    }
                }
                responseMap.put(response.RecordIdentifier,response);
            }              
        }
        
        system.debug(responseMap.size());             
        
        return responseMap;
    }
	
    public class RiskRatingWrapper{
        public String TransactionId;	//03905d94-41e6-4734-9fb1-e6ab0b1d0240
        public String RecordIdentifier;	//DHFHFIIO656L565
        public CustomerSegmentDetails CustomerSegmentDetails;
        public String FinalDecision;	//Accept Business
        public String Risk;	//High
        public String NextReviewDate;	//27-Jun-2020
        public String ReviewCompletionDate;	//11-Jun-2021
        public String ApprovedRiskSetBy;	//Nisarg Mehta
        public String ApprovedRiskRemarks;	//Approved
        public String CaseUrl;	//http://appprod1:44321/crm/crmmenu/menu#/riskrating/actionable/edit/RiskRatingF989/3344
        public String CaseId;	//3344
    } 
    public class CustomerSegmentDetails{
        public CustomerSegmentDetail CustomerSegmentDetail;
    }
    public class CustomerSegmentDetail{
        public String CustomerSegment;	//Retail
		public String StartDate;	//09-Oct-2020
		public String EndDate;	//
    }
}