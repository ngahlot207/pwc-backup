public class HunterCallbackResponseProcessor {
    public static void process(List<IntgMsg__c> responses) {
        try{
            Map<String,HunterResponeWrapper> hunterResponseMap = new  Map<String,HunterResponeWrapper>();
            Map<String,String> intgMsgRefMap = new Map<String,String>();
            for(IntgMsg__c integrationMessage:responses){
                if(integrationMessage.Req__c!=null){
                    HunterResponeWrapper response = getJsonResponseFormat(integrationMessage.Req__c);
                    if(response.identifer!=null){
                        hunterResponseMap.put(response.identifer,response);
                        intgMsgRefMap.put(integrationMessage.Id,response.identifer);
                    }
                }
            }
            
            if(!hunterResponseMap.isEmpty()){
                processHunterCallbackResponse(hunterResponseMap,intgMsgRefMap);
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'HunterCallbackResponseProcessor class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    public static void processHunterCallbackResponse(Map<String,HunterResponeWrapper> hunterResponseMap, Map<String,String> intgMsgRefMap){
        if(!hunterResponseMap.isEmpty()){
            try{
               Map<String, List<HunterVer__c>> hunterVerMap = new Map<String, List<HunterVer__c>>();
                List<HunterVer__c> updateHunterVerList = new List<HunterVer__c>();
                List<IntgMsg__c> updateIntgMsgRecords = new List<IntgMsg__c>(); 
                for(HunterVer__c ver : [SELECT Id,ClientReferenceId__c, LoanAplcn__c, LoanAplcn__r.Applicant__c,IsLatest__c FROM HunterVer__c WHERE  ClientReferenceId__c IN:hunterResponseMap.keySet() AND IsLatest__c = True ORDER BY CreatedDate DESC]){
                    if (!hunterVerMap.containsKey(ver.ClientReferenceId__c)) {
                        hunterVerMap.put(ver.ClientReferenceId__c, new List<HunterVer__c>());
                    }
                    hunterVerMap.get(ver.ClientReferenceId__c).add(ver);
                }
                
                for(String  key : hunterResponseMap.keySet()){
                    if (hunterVerMap.containsKey(key)) {
                        HunterResponeWrapper response = hunterResponseMap.get(key);
                        List<HunterVer__c> hunterVerList = hunterVerMap.get(key);
                        
                        for (HunterVer__c hunterVer : hunterVerList) {
                            // Create a new HunterVer__c record with updated information
                          //  HunterVer__c hunterVer = new HunterVer__c();
                           // hunterVer.Id = hunterVer.Id;
                            hunterVer.WorkStatusChangeDate__c = response.workStatusChangeDate;
                            hunterVer.WorkStatusType__c = response.workStatusType;   
                            hunterVer.WorkStatusDescription__c = response.workStatusDescription;
                            hunterVer.FraudStatusChangeDate__c = response.fraudStatusChangeDate;
                            hunterVer.FraudStatusType__c = response.fraudStatusType;
                            hunterVer.FraudStatusDescription__c = response.fraudStatusDescription;  
                            
                            updateHunterVerList.add(hunterVer);
                        }
                    }
                }
                
                if(!intgMsgRefMap.isEmpty()){
                    for(String intgMsgId : intgMsgRefMap.keySet()){
                        IntgMsg__c intg = new IntgMsg__c();
                        intg.id =  intgMsgId;
                        intg.Status__c = 'Processed';
                        
                        if(hunterVerMap.containsKey(intgMsgRefMap.get(intgMsgId))){
                             List<HunterVer__c> hunterVerList = hunterVerMap.get(intgMsgRefMap.get(intgMsgId));
                            for (HunterVer__c hunterVer : hunterVerList) {
                                if (hunterVer.LoanAplcn__c != null) {
                                    intg.LoanAppln__c = hunterVer.LoanAplcn__c;
                                    if (hunterVer.LoanAplcn__r.Applicant__c != null) {
                                        intg.Appl__c = hunterVer.LoanAplcn__r.Applicant__c;
                                    }
                                }
                            }
                        }
                            
                        updateIntgMsgRecords.add(intg);
                    }
                }
                
                if(!updateHunterVerList.isEmpty()){
                    update updateHunterVerList;
                }
                if(!updateIntgMsgRecords.isEmpty()){
                    update updateIntgMsgRecords;
                }
            }
            catch(exception ex){
                system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
            }
        }
    }
    
    public static DateTime getDateTime(String stringDateTime){
        DateTime dt; 
        try{
            dt = DateTime.valueOf(stringDateTime);
        }
        catch(exception ex){
            
        }
		return dt;
    }
    
    public static HunterResponeWrapper getJsonResponseFormat(String strResp){
        
        HunterResponeWrapper response = new HunterResponeWrapper();
        //String strResp1= '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><impl:getNotification xmlns:impl="https://uat-api.fedfina.com/sandbox/dev/hunterCallback"><NotificationInput><Hunter2Notification xmlns="http://www.mclsoftware.co.uk"><NotificationType>WorkStatus</NotificationType><Message><WorkStatusNotification><SubmissionNotificationNo>8536155</SubmissionNotificationNo><DateEventRaised>2024-09-14T00:26:33+01:00</DateEventRaised><SubmissionIdentifer>Fedfina_L0000003852</SubmissionIdentifer><VersionNo>1</VersionNo><DateOfSubmission>2024-08-24T00:00:00+01:00</DateOfSubmission><WorkStatusChangeDate>2024-09-14T00:26:33+01:00</WorkStatusChangeDate><WorkStatusType>1</WorkStatusType><WorkStatusDescription>Discard</WorkStatusDescription><FraudStatusChangeDate>2024-09-14T00:26:33+01:00</FraudStatusChangeDate><FraudStatusType>1</FraudStatusType><FraudStatusDescription>Clear</FraudStatusDescription></WorkStatusNotification></Message></Hunter2Notification></NotificationInput></impl:getNotification></soap:Body></soap:Envelope>';
        Dom.Document doc = new Dom.Document();  
        doc.load(strResp);              
        Dom.XMLNode rootElement = doc.getRootElement(); 
        for ( Dom.XMLNode childElement : rootElement.getChildElements() ) {
            for (Dom.XMLNode detailElement : childElement.getChildElements()){
                for (Dom.XMLNode detailElement1 : detailElement.getChildElements()){
                    for (Dom.XMLNode detailElement2 : detailElement1.getChildElements()){
                        for (Dom.XMLNode detailElement3 : detailElement2.getChildElements()){
                            for (Dom.XMLNode detailElement4 : detailElement3.getChildElements()){
                                for (Dom.XMLNode detailElement5 : detailElement4.getChildElements()){
                                    system.debug(detailElement5.getName() + '-' + detailElement5.getText());
                                    if(detailElement5.getName()=='SubmissionIdentifer' && String.isNotBlank(detailElement5.getText())){
                                        response.identifer = detailElement5.getText();
                                    }
                                    if(detailElement5.getName()=='WorkStatusChangeDate' && String.isNotBlank(detailElement5.getText())){
                                        response.workStatusChangeDate = getDateTime(detailElement5.getText().substringBefore('+').replace('T', ' '));
                                    }
                                    if(detailElement5.getName()=='WorkStatusType' && String.isNotBlank(detailElement5.getText())){
                                        response.workStatusType = detailElement5.getText();
                                    }
                                    if(detailElement5.getName()=='WorkStatusDescription' && String.isNotBlank(detailElement5.getText())){
                                        response.workStatusDescription = detailElement5.getText();
                                    }
                                    if(detailElement5.getName()=='FraudStatusChangeDate' && String.isNotBlank(detailElement5.getText())){
                                        response.fraudStatusChangeDate = getDateTime(detailElement5.getText().substringBefore('+').replace('T', ' '));
                                    }
                                    if(detailElement5.getName()=='FraudStatusType' && String.isNotBlank(detailElement5.getText())){
                                        response.fraudStatusType = detailElement5.getText();
                                    }
                                    if(detailElement5.getName()=='FraudStatusDescription' && String.isNotBlank(detailElement5.getText())){
                                        response.fraudStatusDescription = detailElement5.getText();
                                    }
                                }
                            }
                        }
                    }
                }
            } 
        }

        return response;
    }
    
    public class HunterResponeWrapper{
        public String identifer;
        public DateTime workStatusChangeDate;
        public String workStatusType;
        public String workStatusDescription;
        public DateTime fraudStatusChangeDate;
        public String fraudStatusType;
        public String fraudStatusDescription;
    }
}