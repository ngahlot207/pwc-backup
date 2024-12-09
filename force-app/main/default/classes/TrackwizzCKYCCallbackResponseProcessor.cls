public class TrackwizzCKYCCallbackResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses){
        try{
            //fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
            //List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>();
            Map<String,CustomerNewCKYCStatusWrapper> custNewCKYCStatusResponseMap = new  Map<String,CustomerNewCKYCStatusWrapper>();
            Map<String,String> intgMsgRefIdsMap = new Map<String,String>();
            for(IntgMsg__c integrationMessage:responses){
                if(integrationMessage.Req__c!=null){
                    Map<String,CustomerNewCKYCStatusWrapper> responseMap = getCustomerCKYCStatusJsonFormat(integrationMessage.Req__c);
                    if(!responseMap.isEmpty()){
                        custNewCKYCStatusResponseMap.putAll(responseMap);
                        List<String> refIds = new List<String>(responseMap.keyset());
                        intgMsgRefIdsMap.put(integrationMessage.Id,refIds[0]);
                    }
                    /*IntgMsg__c intg=New IntgMsg__c();
                    intg.id=integrationMessage.Id;
                    intg.Status__c = 'Processed';
                    updateIntRecords.add(intg);*/
                }
            }
            if(!custNewCKYCStatusResponseMap.isEmpty()){
                processTrackwizzCKYCResponse(intgMsgRefIdsMap,custNewCKYCStatusResponseMap);
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
    
    public class CustomerNewCKYCStatusWrapper{
        public String TransactionId;	//123
        public String SourceSystemName;	//SourceSystemName1
        public String SourceSystemCustomerCode;	//SourceSystemCoustomerCode1
        public String StepCode;	//StepCode1
        public String StepName;	//StepName1
        public String StepCategory;	//StepCategory1
        public String CKYCID;	//CKYCID1
        public String CKYCAccountType;	//CKYCAccountType1
        public String CaseURL;	//CaseURL1
        public String CaseID;	//12345
    }
    
    public static TrackwizzCKYCCallbackResponseProcessor.CustomerNewCKYCStatusWrapper parse(String json){
        return (TrackwizzCKYCCallbackResponseProcessor.CustomerNewCKYCStatusWrapper) System.JSON.deserialize(json, TrackwizzCKYCCallbackResponseProcessor.CustomerNewCKYCStatusWrapper.class);
    }
    
    public static Map<String,CustomerNewCKYCStatusWrapper> getCustomerCKYCStatusJsonFormat(String strResp){
        Map<String,CustomerNewCKYCStatusWrapper> responseMap = new Map<String,CustomerNewCKYCStatusWrapper>();
        //String strResp1='<?xml version="1.0" encoding="utf-8"?><CustomerNewCKYCStatusRequest><RequestId>RequestId1</RequestId><APIToken>APIToken1</APIToken><CustomerNewCKYCStatusRequestDetails><CustomerNewCKYCStatusRequestDetail><TransactionId>123</TransactionId><SourceSystemName>SourceSystemName1</SourceSystemName><SourceSystemCoustomerCode>SourceSystemCoustomerCode1</SourceSystemCoustomerCode><StepCode>StepCode1</StepCode><StepName>StepName1</StepName><StepCategory>StepCategory1</StepCategory><CKYCID>CKYCID1</CKYCID><CKYCAccountType>CKYCAccountType1</CKYCAccountType><CaseURL>CaseURL1</CaseURL><CaseID>12345</CaseID></CustomerNewCKYCStatusRequestDetail><CustomerNewCKYCStatusRequestDetail><TransactionId>TransactionId2</TransactionId><SourceSystemName>SourceSystemName2</SourceSystemName><SourceSystemCoustomerCode>SourceSystemCoustomerCode2</SourceSystemCoustomerCode><StepCode>StepCode2</StepCode><StepName>StepName2</StepName><StepCategory>StepCategory2</StepCategory><CaseURL>CaseURL2</CaseURL><CaseID>1234</CaseID></CustomerNewCKYCStatusRequestDetail></CustomerNewCKYCStatusRequestDetails></CustomerNewCKYCStatusRequest>';
        Dom.Document doc = new Dom.Document();  
        doc.load(strResp);              
        Dom.XMLNode rootElement = doc.getRootElement(); 
        for (Dom.XMLNode childElement : rootElement.getChildElements()) {
            //root elements of each array
            for (Dom.XMLNode detailElement : childElement.getChildElements()){
                CustomerNewCKYCStatusWrapper response = new CustomerNewCKYCStatusWrapper();
                //childs elements of each array
                for (Dom.XMLNode detailElement1 : detailElement.getChildElements()){
                    //childs elements of each childs array
                    if(detailElement1.getName()=='TransactionId' && String.isNotBlank(detailElement1.getText())){
                        response.TransactionId = detailElement1.getText();
                    } 
                    if(detailElement1.getName()=='SourceSystemName' && String.isNotBlank(detailElement1.getText())){
                        response.SourceSystemName = detailElement1.getText();
                    }
                    if(detailElement1.getName()=='SourceSystemCustomerCode' && String.isNotBlank(detailElement1.getText())){
                        response.SourceSystemCustomerCode = detailElement1.getText();
                    } 
                    if(detailElement1.getName()=='StepCode' && String.isNotBlank(detailElement1.getText())){
                        response.StepCode = detailElement1.getText();
                    }
                    if(detailElement1.getName()=='StepName' && String.isNotBlank(detailElement1.getText())){
                        response.StepName = detailElement1.getText();
                    } 
                    if(detailElement1.getName()=='StepCategory' && String.isNotBlank(detailElement1.getText())){
                        response.StepCategory = detailElement1.getText();
                    }
                    if(detailElement1.getName()=='CKYCID' && String.isNotBlank(detailElement1.getText())){
                        response.CKYCID = detailElement1.getText();
                    } 
                    if(detailElement1.getName()=='CKYCAccountType' && String.isNotBlank(detailElement1.getText())){
                        response.CKYCAccountType = detailElement1.getText();
                    }
                    if(detailElement1.getName()=='CaseURL' && String.isNotBlank(detailElement1.getText())){
                        response.CaseURL = detailElement1.getText();
                    } 
                    if(detailElement1.getName()=='CaseID' && String.isNotBlank(detailElement1.getText())){
                        response.CaseID = detailElement1.getText();
                    }
                }
                responseMap.put(response.SourceSystemCustomerCode,response);
            }              
        }
        system.debug(responseMap);             
        return responseMap;
        
    }
    
    public static void processTrackwizzCKYCResponse(Map<String,String> intgMsgRefIdsMap,Map<String,CustomerNewCKYCStatusWrapper> responseMap){
        if(!responseMap.isEmpty()){
            try{
                Map<String,Applicant__c> applMap = new Map<String,Applicant__c>();
                List<Applicant__c> updateApplList = new List<Applicant__c>();
                List<IntgMsg__c> updateIntgMsgRecords = new List<IntgMsg__c>(); 
                for(Applicant__c appl : [SELECT Id,Name,IntegrationStatus__c,IntegrationErrorMessage__c,LoanAppln__c,LoanAppln__r.Stage__c,UCID__c,CKYC_API_Status__c,CKYC_Number__c FROM Applicant__c WHERE LoanAppln__r.Stage__c = 'Disbursed' AND CKYC_API_Status__c ='Success' AND CKYC_Number__c=null AND UCID__c IN:responseMap.keySet()]){
                    if(!applMap.containsKey(appl.UCID__c)){
                        applMap.put(appl.UCID__c,appl);
                    }
                }
                for(String  res : responseMap.keySet()){
                    if(applMap.containsKey(res)){
                        CustomerNewCKYCStatusWrapper response = responseMap.get(res);
                        if(response!=null && response.CKYCID!=null && String.isNotBlank(response.CKYCID)){
                            Applicant__c appl = new Applicant__c();
                            appl.Id = applMap.get(res).Id;
                            appl.CKYC_Number__c =response.CKYCID;
                            appl.IntegrationStatus__c = replaceAndUpdateString('CKYC Callback:', 'CKYC Callback: Success', applMap.get(res).IntegrationStatus__c, ';');
                            updateApplList.add(appl);
                        }
                    }
                }
                if(!intgMsgRefIdsMap.isEmpty()){
                    for(String intgMsgId : intgMsgRefIdsMap.keySet()){
                        IntgMsg__c intg = new IntgMsg__c();
                        intg.id =  intgMsgId;
                        intg.Status__c = 'Processed';
                        if(applMap.containskey(intgMsgRefIdsMap.get(intgMsgId))){
                            if(applMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppln__c!=null){
                                intg.LoanAppln__c = applMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppln__c;
                            }
                            if(applMap.get(intgMsgRefIdsMap.get(intgMsgId)).Id!=null){
                                intg.Appl__c = applMap.get(intgMsgRefIdsMap.get(intgMsgId)).Id;
                            }
                        }
                        updateIntgMsgRecords.add(intg);
                    }
                    
                }
                if(!updateApplList.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Applicant__c.SObjectType });  
                    List<string> fieldNamesList = New List<string>{'CKYC_Number__c'};
                        String sObjectName = 'Applicant__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateApplList);
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
            catch(exception ex){
                system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
            }
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