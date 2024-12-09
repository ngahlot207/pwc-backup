public class PerfiosAAConsentCallbackRespProcessor {

    public Static void process(List<IntgMsg__c> responses){
        try{
            Map<String,ConsentResonseWrapper> responseMap = new Map<String,ConsentResonseWrapper>();
            Map<String,String> intgMsgRefIdsMap = new Map<String,String>();
            
            for(IntgMsg__c integrationMessage : responses){
                if(integrationMessage.Req__c!=null){
                    try{
                        ConsentResonseWrapper response = (ConsentResonseWrapper) JSON.deserialize(integrationMessage.Req__c,ConsentResonseWrapper.class);
                        if(response!=null && response.txnId!=null && String.isNotBlank(response.txnId)){
                            responseMap.put(response.txnId, response);
                            intgMsgRefIdsMap.put(integrationMessage.Id,response.txnId);
                        }
                        
                    }
                    catch(exception ex){
                        system.debug('Error line number: ' + ex.getLineNumber() + 'Error Message: '+ ex.getMessage());
                    }
                }
            }
            
            if(!responseMap.isEmpty()){
                processResponse(intgMsgRefIdsMap,responseMap);
            }
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }  
    }
    
    public static void processResponse(Map<String,String> intgMsgRefIdsMap,Map<String,ConsentResonseWrapper> responseMap){
        try{
            if(responseMap!=null){
                List<Applicant__c> applicantList = new List<Applicant__c>();
                Map<String,Applicant__c> applicantMap = new Map<String,Applicant__c> ();
                for(Applicant__c appl : [SELECT Id,LoanAppln__c,TransactionId__c,IntegrationStatus__c,IntegrationErrorMessage__c FROM Applicant__c WHERE TransactionId__c IN:responseMap.keySet()]){
                    applicantMap.put(appl.TransactionId__c,appl);
                	
                    if(responseMap.containsKey(appl.TransactionId__c)){
                        ConsentResonseWrapper response = responseMap.get(appl.TransactionId__c);
                        if(response!=null && response.consentStatus!=null){
                            Applicant__c app = new Applicant__c();
                            app.Id = appl.Id;
                            if( response.consentStatus.equalsIgnoreCase('READY')){
                                app.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios AA Consent Notification', 'Perfios AA Consent Notification: Success', appl.IntegrationStatus__c, ';');
                                app.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios AA Consent Notification', '', appl.IntegrationErrorMessage__c, ';');
                            }
                            else{
                                app.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios AA Consent Notification', 'Perfios AA Consent Notification: Failure', appl.IntegrationStatus__c, ';');
                                app.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios AA Consent Notification','Perfios AA Consent Notification: ' + response.consentStatus , appl.IntegrationErrorMessage__c, ';');
                                app.Perfios_AA_Status__c = 'Failure';
                            }
                            applicantList.add(app);
                        }
                    }
                
                }
                if(!applicantList.isEmpty()){
                    update applicantList;
                }
                if(!intgMsgRefIdsMap.isEmpty()){
                    List<IntgMsg__c> updateIntgMsgRecords = new List<IntgMsg__c>();
                    for(String intgMsgId : intgMsgRefIdsMap.keySet()){
                        IntgMsg__c intg = new IntgMsg__c();
                        intg.id =  intgMsgId;
                        intg.Status__c = 'Processed';
                        if(applicantMap.containskey(intgMsgRefIdsMap.get(intgMsgId))){
                            intg.Appl__c = applicantMap.get(intgMsgRefIdsMap.get(intgMsgId)).Id;
                            if(applicantMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppln__c!=null){
                                intg.LoanAppln__c = applicantMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppln__c;
                            }
                        }
                        updateIntgMsgRecords.add(intg);
                    }
                    if(!updateIntgMsgRecords.isEmpty()){
                        update updateIntgMsgRecords;
                    }
                }
            }
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }  
    }
    
    public class ConsentResonseWrapper{
        public String txnId;	//62faea57813240299b75260d5e16fca8
        public String consentStatus;	//READY
        public List<Accounts> accounts;
        public String userId;	//NzAxOTY4OTI0N0BhbnVtYXRp
    }
    public class Accounts {
        public String fiType;	//DEPOSIT
        public String fipId;	//ACME-FIP
        public String accType;	//SAVINGS
        public String linkRefNumber;	//5f104eb9-8ca9-4ef1-b9ad-117e2c7434a9
        public String maskedAccNumber;	//XXXXXXXX9648
    }
}