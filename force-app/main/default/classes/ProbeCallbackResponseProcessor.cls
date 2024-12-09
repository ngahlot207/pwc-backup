public class ProbeCallbackResponseProcessor {
    public static void process(List<IntgMsg__c> responses) {
        try {
            Map<String, ProbeCallbackResponseWrapper> jsonResponseMap = new Map<String, ProbeCallbackResponseWrapper>();
            Map<String, String> intgMsgRefIdsMap = new Map<String, String>();

            for (IntgMsg__c integrationMessage : responses) {
                if (integrationMessage.Req__c != null) {
                    ProbeCallbackResponseWrapper res = (ProbeCallbackResponseWrapper) JSON.deserialize(integrationMessage.Req__c, ProbeCallbackResponseWrapper.class);
                    if (res != null && String.isNotBlank(res.request_id) && String.isNotBlank(res.status)) {
                        jsonResponseMap.put(res.request_id, res);
                        intgMsgRefIdsMap.put(integrationMessage.Id, res.request_id);
                    }
                }
            }

            if (!jsonResponseMap.isEmpty()) {
                List<APIVer__c> apiVersions = [
                    SELECT Id, UpdReqId__c, Appl__r.LoanAppln__c, Appl__c, UpdateApiType__c 
                    FROM APIVer__c 
                    WHERE UpdReqId__c IN :jsonResponseMap.keySet() 
                    AND IsLatest__c = true 
                    AND (UpdateApiType__c = 'Update Company Comprehensive details' OR UpdateApiType__c = 'Update LLP Comprehensive details')
                ];

                for (APIVer__c apiVer : apiVersions) {
                    ProbeCallbackResponseWrapper response = jsonResponseMap.get(apiVer.UpdReqId__c);
                    if (response != null && response.status == 'FULFILLED') {
                        if (apiVer.UpdateApiType__c == 'Update Company Comprehensive details') {
                            probeCallbackSuccess(intgMsgRefIdsMap, response, 'Company', apiVer.Appl__c, apiVer.Appl__r.LoanAppln__c);
                        } else if (apiVer.UpdateApiType__c == 'Update LLP Comprehensive details') {
                            probeCallbackSuccess(intgMsgRefIdsMap, response, 'LLP', apiVer.Appl__c, apiVer.Appl__r.LoanAppln__c);
                        }
                    }
                }
            }
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'ProbeCallbackResponseProcessor', 'process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }

    public static void probeCallbackSuccess(Map<String, String> intgMsgRefIdsMap, ProbeCallbackResponseWrapper response, String createIntgMsgFor, Id applicantId, Id loanAppId) {
        try {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {APIVer__c.SObjectType, IntgMsg__c.SObjectType});

            List<IntgMsg__c> updateIntgMsgRecords = new List<IntgMsg__c>();
            List<IntgMsg__c> insertIntgMsgRecords = new List<IntgMsg__c>();

            if (!intgMsgRefIdsMap.isEmpty() && applicantId != null && loanAppId != null) {
                for (String intgMsgId : intgMsgRefIdsMap.keySet()) {
                    IntgMsg__c intgMsg = new IntgMsg__c(
                        Id = intgMsgId,
                        Status__c = 'Processed',
                        Appl__c = applicantId,
                        LoanAppln__c = loanAppId
                    );
                    updateIntgMsgRecords.add(intgMsg);
                }
            }

            if (createIntgMsgFor != null && applicantId != null) {
                IntgMsg__c newIntgMsg = new IntgMsg__c(
                    BU__c = 'HL / STL',
                    RefId__c = applicantId,
                    Status__c = 'New',
                    MStatus__c = 'Blank',
                    RefObj__c = 'Applicant__c',
                    IsActive__c = true
                );

                if (createIntgMsgFor == 'Company') {
                    newIntgMsg.Name = 'Company Comprehensive Details';
                    newIntgMsg.Svc__c = 'Company Comprehensive Details';
                } else if (createIntgMsgFor == 'LLP') {
                    newIntgMsg.Name = 'LLP Comprehensive Details';
                    newIntgMsg.Svc__c = 'LLP Comprehensive Details';
                }

                insertIntgMsgRecords.add(newIntgMsg);
            }

            if(updateIntgMsgRecords!=null && !updateIntgMsgRecords.isEmpty()){
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Status__c','Appl__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntgMsgRecords);
                    uow.commitWork();
            }

            if(insertIntgMsgRecords!=null && !insertIntgMsgRecords.isEmpty()){
            List<String> fieldNamesList = new List<String>{
                    'Name', 'BU__c','RefId__c','Status__c','MStatus__c','RefObj__c','Svc__c','IsActive__c' };
            String sObjectName = 'IntgMsg__c';
            Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
            fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
            uow.registerNew(insertIntgMsgRecords);
            uow.commitWork();
            }

            
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'ProbeCallbackResponseProcessor', 'probeCallbackSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
}