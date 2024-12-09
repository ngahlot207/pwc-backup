public class GSPGSTRequestGenerator implements ICalloutRequestGenerator {
    public void generate(List<IntgMsg__c> msgs, String service, String processType) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType });
        
        Set<Id> applGSTIds = new Set<Id>();
        Set<Id> applKycIds = new Set<Id>();
        Map<Id,ApplGST__c> appGSTMap = new Map<Id,ApplGST__c>();
        Map<Id,ApplKyc__c> appKYCMap = new Map<Id,ApplKyc__c>();
        
        for(IntgMsg__c intms : msgs) {
            if(String.isNotBlank(intms.RefId__c) && String.isNotBlank(intms.RefObj__c) && intms.RefObj__c == 'ApplGST__c') {
                applGSTIds.add(intms.RefId__c);
            }
            if(String.isNotBlank(intms.ParentRefId__c) && String.isNotBlank(intms.ParentRefObj__c) && intms.ParentRefObj__c == 'ApplKyc__c'){
                applKycIds.add(intms.ParentRefId__c);
            }
        }
        
        try {
            appGSTMap.putAll([SELECT Id, GSTIN__c FROM ApplGST__c WHERE Id IN : applGSTIds]);
            appKYCMap.putAll([SELECT Id, GSTIN__c FROM ApplKyc__c WHERE Id IN : applKycIds]);
            if(!msgs.isEmpty()) {
                List<IntgMsg__c> updateIntrecods = new List<IntgMsg__c>();
                for(IntgMsg__c intMsg : msgs) {
                    
                    GSPGSTRequestWrapper gstData = new GSPGSTRequestWrapper();
                    GSPGSTRequestWrapper.ClientDataClass cd = new GSPGSTRequestWrapper.ClientDataClass();

                    cd.caseId = intMsg.Integration_Message_Number__c;
                    gstData.consent = GlobalConstants.CONSENT_Y;
                    
                    if(intMsg.RefObj__c == 'ApplGST__c'){
                         gstData.gstin = appGSTMap.containsKey(intMsg.RefId__c) && appGSTMap.get(intMsg.RefId__c).GSTIN__c!=null ? appGSTMap.get(intMsg.RefId__c).GSTIN__c : '';
                    }
                    else if(intMsg.ParentRefObj__c == 'ApplKyc__c'){
                        gstData.gstin = appKYCMap.containsKey(intMsg.ParentRefId__c) && appKYCMap.get(intMsg.ParentRefId__c).GSTIN__c!=null ? appKYCMap.get(intMsg.ParentRefId__c).GSTIN__c : '';
                    }
                    
                    gstData.addressSplit = TRUE;
                    gstData.clientData = cd;
					
					IntgMsg__c intg = new IntgMsg__c();
                    intg.Id = intMsg.Id;
                    intg.Req__c = JSON.serialize(gstData); 
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
            GlobalUtility.logMessage('Error', 'GSPGSTRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', NULL, NULL, ex.getMessage() + ' Line: ' + ex.getLineNumber(), NULL, ex, NULL);
        }
    }
}