public class GSTPANRequestGenerator implements ICalloutRequestGenerator {
    public void generate(List<IntgMsg__c> msgs, String service, String processType) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType });
        
        Set<Id> applKycIds = new Set<Id>();
        Map<Id,ApplKyc__c> applKycMap = new Map<Id,ApplKyc__c>();
        Set<Id> applIds = new Set<Id>();
        Map<Id,Applicant__c> applicantMap = new Map<Id,Applicant__c>();

        for(IntgMsg__c intms : msgs) {
            if(String.isNotBlank(intms.RefId__c) && String.isNotBlank(intms.RefObj__c) && intms.RefObj__c == 'ApplKyc__c') {
                applKycIds.add(intms.RefId__c);
            }
            else if(String.isNotBlank(intms.RefId__c) && String.isNotBlank(intms.RefObj__c) && intms.RefObj__c == 'Applicant__c') {
                applIds.add(intms.RefId__c);
            }
        }
        
        try {
            applKycMap.putAll([SELECT Id, Pan__c FROM ApplKyc__c WHERE Id IN : applKycIds AND kycDoc__c != NULL AND kycDoc__c = 'Pan']);
            applicantMap.putAll([SELECT Id,PAN__c FROM Applicant__c WHERE Id IN : applIds]);
            
            if(!msgs.isEmpty()) {
                List<IntgMsg__c> updateIntrecods = new List<IntgMsg__c>();
                for(IntgMsg__c intMsg : msgs) {
                    
                    GSTPANRequestWrapper gstDat = new GSTPANRequestWrapper();
                    GSTPANRequestWrapper.ClientDataClass cd = new GSTPANRequestWrapper.ClientDataClass();

                    cd.caseId = intMsg.Integration_Message_Number__c;
                    gstDat.consent = GlobalConstants.CONSENT_Y;
                    gstDat.pan = intMsg.RefObj__c == 'ApplKyc__c' && applKycMap.containsKey(intMsg.RefId__c) ? applKycMap.get(intMsg.RefId__c).Pan__c : intMsg.RefObj__c == 'Applicant__c' && applicantMap.containsKey(intMsg.RefId__c) ? applicantMap.get(intMsg.RefId__c).PAN__c : '';
                    gstDat.clientData = cd;
					
					IntgMsg__c intg = new IntgMsg__c();
                    intg.Id = intMsg.Id;
                    intg.Req__c = JSON.serialize(gstDat); 
                    intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                    updateIntrecods.add(intg);
                }
				
				if(!updateIntrecods.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c', 'Status__c'};
                    Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntrecods);
                }
            }
			
			uow.commitWork();
        }
        catch(Exception ex){
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'GSTPANRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', NULL, NULL, ex.getMessage() + ' Line: ' + ex.getLineNumber(), NULL, ex, NULL);
        }
    }
}