public class ScreeningWachoutRequestGenerator implements ICalloutRequestGenerator {
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
        
        try {
            
            List<Id> Ids =new List<Id>();
            for(IntgMsg__c intMsg : msgs){ 
                Ids.add(intMsg.RefId__c);//appliant id
            }
            
            Map<Id,ApplKyc__c> appKycMap = new Map<Id,ApplKyc__c>();
            for(ApplKyc__c applkyc : [SELECT Id, Applicant__c, Applicant__r.Constitution__c, Pan__c, Name__c, kycDoc__c FROM ApplKyc__c WHERE Applicant__c IN:Ids AND kycDoc__c = 'Pan']){
                appKycMap.put(applkyc.Applicant__c,applkyc);
            }
            
            List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
            
            for (IntgMsg__c intMsg : msgs) {
                String requestBody = '';
                
                if(appKycMap.containsKey(intMsg.RefId__c)){
                    ApplKyc__c applKycRec = appKycMap.get(intMsg.RefId__c);
                    if (applKycRec != null) {
                        requestBody += (applKycRec.Name__c != null ? applKycRec.Name__c : '') + '|';
                        requestBody += (applKycRec.Applicant__r.Constitution__c == 'INDIVIDUAL' ? 'P' : 'C') + '|';
                        requestBody += '|' + (applKycRec.Pan__c != null ? applKycRec.Pan__c : '') + '|';
                        requestBody += GlobalUtility.getUniqueNumber() + '|||';
                    } 
                }
                else {
                    requestBody = '|||||||';
                }
                
                if (String.isNotBlank(requestBody)) {
                    IntgMsg__c integrationMessage = new IntgMsg__c();
                    integrationMessage.Id = intMsg.Id;
                    integrationMessage.Req__c = requestBody;
                    integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                    updateIntMsgRecords.add(integrationMessage);
                }
                
            }
            if (!updateIntMsgRecords.isEmpty()) {
                String sObjectName = 'IntgMsg__c';
                List<String> fieldNamesList = new List<String>{'Req__c', 'Status__c'};
                    Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType, fieldNamesList);
                uow.registerDirty(updateIntMsgRecords);
                uow.commitWork();
            }
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'ScreeningWachoutRequestGenerator class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
}