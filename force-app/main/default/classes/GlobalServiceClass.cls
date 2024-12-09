Global class GlobalServiceClass {
    public static Map<String,string> responseMap = new  Map<String,string>();
    public static final String[] serviceNames = new String[]{'Customer ACK Request', 'Customer Issue Request'};
        @AuraEnabled
        global static Map<String,String> CreateIntegrationRequest(string applicantId){
            system.debug('applicantId###'+applicantId);
            List<ApplKyc__c> applicantRecs = [SELECT Id,Applicant__c,Pan__c,Applicant__r.FName__c, Applicant__r.LName__c,
                                              Applicant__r.DOB__c, Applicant__r.MobNumber__c,createddate  from ApplKyc__c
                                              where Applicant__c =:applicantId order by LastModifiedDate desc limit 1];
            if(!applicantRecs.isempty()){
                for(ApplKyc__c applicant :applicantRecs){
                    String missingDetails = '';
                    if (applicant.Applicant__r.FName__c == null || applicant.Applicant__r.LName__c == null || 
                        applicant.Applicant__r.DOB__c == null || applicant.Pan__c == null || 
                        applicant.Applicant__r.MobNumber__c == null){
                            if (applicant.Applicant__r.FName__c == null) {
                                missingDetails += 'First Name, ';
                            }
                            if (applicant.Applicant__r.LName__c == null) {
                                missingDetails += 'Last Name, ';
                            }
                            if (applicant.Applicant__r.DOB__c == null) {
                                missingDetails += 'Date of Birth, ';
                            }
                            if (applicant.Pan__c == null) {
                                missingDetails += 'PAN Number, ';
                            }
                            if (applicant.Applicant__r.MobNumber__c == null) {
                                missingDetails += 'Mobile Number, ';
                            }
                            missingDetails = missingDetails.subString(0, missingDetails.length() - 2);
                            String toastMessage = missingDetails + ' not present for the Applicant.';
                            system.debug('ToastMessage## '+toastMessage);
                            responseMap.put('error',toastMessage);
                        }else{
                            insertDedupeIntegrationMessage(applicant);
                        }   
                } 
            }
            
            for(string key:responseMap.keyset()){
                system.debug('key## '+key);
            }
            return responseMap;
        }
    
    private static void insertDedupeIntegrationMessage(ApplKyc__c applicant) {
        IntgMsg__c  dedupeIntegrationMessage = new IntgMsg__c ();
        dedupeIntegrationMessage.Name = 'Dedupe';
        dedupeIntegrationMessage.BU__c = 'HL / STL';
        dedupeIntegrationMessage.RefId__c = applicant.Applicant__c;
        dedupeIntegrationMessage.Status__c = 'New';
        dedupeIntegrationMessage.RefObj__c = 'Applicant__c';
        dedupeIntegrationMessage.Svc__c  = 'Dedupe';
        dedupeIntegrationMessage.ApiVendor__c = 'Datalake';
        try {
            Database.SaveResult result = Database.insert(dedupeIntegrationMessage,false);
            system.debug('##result'+result);
            if(result!= null){
                if(result.isSuccess()){
                    System.debug('dedupeIntegrationMessage id--'+dedupeIntegrationMessage.Id);
                    if(dedupeIntegrationMessage.Id != null){
                        responseMap.put('Dedupe',string.valueOf(dedupeIntegrationMessage.Id));
                        insertBureauIntegrationMessages(applicant);
                    }
                }
                else{
                    for(Database.Error err : result.getErrors()) {
                        responseMap.put('dedupe failed',err.getMessage());
                        System.debug(LoggingLevel.ERROR, err.getMessage());
                    }
                }
            }
        } catch (Exception e) {
            system.debug('Some error occurred while creating Dedupe Integration Message. Please try again.'+e.getstacktracestring()+e.getmessage());
        }
    }
    
    private static void insertBureauIntegrationMessages(ApplKyc__c applicant) {
        Savepoint sp;
        IntgMsg__c bureauIntegrationMessage;
        Integer index = 0;
        for (String serviceName : serviceNames) {
            bureauIntegrationMessage = new IntgMsg__c();
            index++;
            bureauIntegrationMessage.Name = serviceName;
            bureauIntegrationMessage.RefId__c = applicant.Applicant__c;
            bureauIntegrationMessage.Status__c = 'New';
            bureauIntegrationMessage.BU__c = 'HL / STL';
            bureauIntegrationMessage.RefObj__c = 'Applicant__c';
            bureauIntegrationMessage.Svc__c = serviceName;
            bureauIntegrationMessage.ApiVendor__c = 'Lentra';
            try {
                if(index==1){
                    sp = Database.setSavepoint();
                }
                insert bureauIntegrationMessage;
                system.debug('bureauIntegrationMessage Id--'+bureauIntegrationMessage.Id);
                if(bureauIntegrationMessage.Id != null){
                    responseMap.put(serviceName,string.valueOf(bureauIntegrationMessage.Id));
                }
            } catch (Exception ex) {
                for (String serviceAPIName : serviceNames) {
                    responseMap.remove(serviceAPIName);
                }
                Database.rollback(sp);
                system.debug('Exception occurred while creating Bureau Integration Message. Please try again.'+ex.getstacktracestring()+ex.getmessage());
                throw new AuraHandledException(ex.getMessage());
            }
        }
    }
}