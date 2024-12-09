public class applicationQueryOpsChange implements TriggerAction.AfterInsert{
    
    public static void afterInsert(List<Application_Query__c> newList) {
        
        List<String> opsHierarchy = new List<String>{'AOM','BOM','ROM','ZOM','NOM'};
            List<String> cpaHierarchy = new List<String>{'CPA','UW','ACM','RCM','ZCM','NCM','CH'};
                Set<Id> cpaNdcIds = new Set<Id>();
        Set<Id> opsNdcIds = new Set<Id>();
        Set<Id> allNdcIds = new Set<Id>();
        List<NDC__c> updateNDcList = new List<NDC__c>();
        List<Application_Query__c> updateAppQueryList = new List<Application_Query__c>();
        
        for(Application_Query__c qrecord : newList){
            if(opsHierarchy.contains(qrecord.Role__c)){
                opsNdcIds.add(qrecord.NDC__c);
            }else if(cpaHierarchy.contains(qrecord.Role__c)){
                cpaNdcIds.add(qrecord.NDC__c);
            }
        }
        system.debug('opsNdcIds  '+ opsNdcIds);
        system.debug('cpaNdcIds  '+ cpaNdcIds);
        allNdcIds.addAll(opsNdcIds);
        allNdcIds.addAll(cpaNdcIds);
        system.debug('allNdcIds  '+ allNdcIds);
        
        if(allNdcIds != null && allNdcIds.size() > 0){
            List<NDC__c> ndcRecords = [SELECT id,OpsQuery__c,LastModifiedDate,(SELECT Id FROM Application_Queries__r WHERE QryTyp__c='NDC Query') FROM NDC__c WHERE Id IN :allNdcIds];  
            if(ndcRecords != null && ndcRecords.size() > 0){
                system.debug('ndcRecords  '+ ndcRecords);
                
                for(NDC__c ndc : ndcRecords){
                    NDC__c nd = new NDC__c();
                    nd.Id = ndc.Id;
                    if(opsNdcIds.contains(ndc.Id)){                                     
                        nd.OpsQuery__c = true; 
                    }else{
                        nd.OpsQuery__c = false; 
                        if(ndc.Application_Queries__r != null && ndc.Application_Queries__r.size() > 0){
                            for(Application_Query__c apq : ndc.Application_Queries__r){
                                Application_Query__c oneApq = new Application_Query__c();
                                oneApq.Id = apq.Id;
                                oneApq.Responded__c = true;
                                updateAppQueryList.add(oneApq);
                            }
                        }
                    }
                    updateNDcList.add(nd);
                }
            }
            if(updateNDcList != null && updateNDcList.size() > 0 ){
                update updateNDcList;
            } 
             if(updateAppQueryList != null && updateAppQueryList.size() > 0 ){
                update updateAppQueryList;
            } 
        }
    }
}