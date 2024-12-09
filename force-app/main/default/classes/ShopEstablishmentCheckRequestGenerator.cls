public class ShopEstablishmentCheckRequestGenerator implements ICalloutRequestGenerator {
    public void generate(List<IntgMsg__c> msgs, String service, String processType) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType });
        
        Set<Id> applKycIds = new Set<Id>();
        Map<Id,ApplKyc__c> appRecMap = new Map<Id,ApplKyc__c>();
        
        for(IntgMsg__c intms : msgs) {
            if(String.isNotBlank(intms.ParentRefId__c) && String.isNotBlank(intms.ParentRefObj__c) && intms.ParentRefObj__c == 'ApplKyc__c') {
                applKycIds.add(intms.ParentRefId__c);
            }
        }
        
        try {
            appRecMap.putAll([SELECT Id, RegNo__c, AreaCode__c FROM ApplKyc__c WHERE Id IN : applKycIds]);
            
            if(!msgs.isEmpty()) {
                List<IntgMsg__c> updateIntrecods = new List<IntgMsg__c>();
                
                for(IntgMsg__c intMsg : msgs) {
                    ApplKyc__c applRec = appRecMap.get(intMsg.ParentRefId__c);
                    
                    ShopAndEstablishmentCheckRequestWrapper shopEstData = new ShopAndEstablishmentCheckRequestWrapper();
                    ShopAndEstablishmentCheckRequestWrapper.ClientDataClass cd = new ShopAndEstablishmentCheckRequestWrapper.ClientDataClass();
                    
                    cd.caseId = intMsg.Integration_Message_Number__c;
                    shopEstData.consent = GlobalConstants.CONSENT_Y;
                    shopEstData.regNo = applRec.RegNo__c ?? '';
                    shopEstData.pdfRequired = false;
                    shopEstData.areaCode = applRec.AreaCode__c ?? '';
                    shopEstData.clientData = cd;
                    
                    IntgMsg__c intg = new IntgMsg__c();
                    intg.Id = intMsg.Id;
                    intg.Req__c = JSON.serialize(shopEstData); 
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
        catch(Exception ex) {
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'ShopEstablishmentCheckRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', NULL, NULL, ex.getMessage() + ' Line: ' + ex.getLineNumber(), NULL, ex, NULL);
        }
    }
}