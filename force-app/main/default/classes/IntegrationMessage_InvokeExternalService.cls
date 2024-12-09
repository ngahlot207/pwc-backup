public class IntegrationMessage_InvokeExternalService implements TriggerAction.Afterupdate {
    
    public void Afterupdate(List<IntgMsg__c> newList,List<IntgMsg__c> oldList) {
        
        //Map to store Trigger.OldMap
        Map<Id,IntgMsg__c>OldRecordsMap=New Map<Id,IntgMsg__c>(oldList);
        
        List<IntgMsg__c> intgMsgList = new List<IntgMsg__c>();
        Set<String>services = new Set<String>();
        Set<String>businessUnits = new Set<String>();
        
        for (IntgMsg__c intg : newList) {
            system.debug('active ==>' +  intg.IsActive__c);
             system.debug('DocumentAPI ==>' +  intg.DocApi__c);
            system.debug('status ==>' +  intg.Status__c);
            if ( intg.Status__c == GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS && intg.Status__c != OldRecordsMap.get(intg.id).Status__c ) {
                intgMsgList.add(intg);
                services.add(intg.Svc__c);
                businessUnits.add(intg.BU__c);
                system.debug('inside');
            }
            
        }
        
        if (!intgMsgList.isEmpty()) {
            system.debug('outside');
            this.invokeExternalService(intgMsgList,services,businessUnits);
            system.debug('outside2');
        }
    }
    
    
    private void invokeExternalService(List<IntgMsg__c> intgMsgList,Set<String> services, Set<String> businessUnits) {
        try{
            
            Map<String,List<Id>> serviceIntgMsgIdsMap = new Map<String,List<Id>>();
            Map<String,Type> serviceTypeMaps = new Map<String,Type>();
            List<IntgConfig__mdt>intConfigmdt = [SELECT Id,BU__c,Svc__c,ExtSvcCls__c FROM IntgConfig__mdt WHERE Svc__c IN: services  AND BU__c IN:businessUnits AND IsActive__c=true];
             Type request;
            List<Id> intMsgIdsList=new list<Id>();
            for (IntgConfig__mdt medat : intConfigmdt){
                
                request = Type.forname(medat.ExtSvcCls__c);
                if(serviceTypeMaps.get(medat.BU__c+'-'+medat.Svc__c) == null)
                    serviceTypeMaps.put(medat.BU__c+'-'+medat.Svc__c,request);
            }  
            
            for(IntgMsg__c inte : intgMsgList){
                
                String serviceValue = inte.BU__c+'-'+inte.Svc__c ;
                
                if(serviceIntgMsgIdsMap.get(serviceValue) != null){
                    
                    intMsgIdsList = serviceIntgMsgIdsMap.get(serviceValue);
                    intMsgIdsList.add(inte.id);
                    
                }else{
                    
                 //   List<Id> intMsgIdsList = new  List<Id>();
                    intMsgIdsList.add(inte.id);
                    serviceIntgMsgIdsMap.put(serviceValue,intMsgIdsList);
                    
                }
            }
            if(intMsgIdsList.size()>0)
            {
                 UseExtSrcMoc__c mc = UseExtSrcMoc__c.getOrgDefaults();
                if(!(mc.Use_Mock__c)){
                    ExternalService scv=(ExternalService) request.newInstance(); 
                    scv.post(intMsgIdsList);
                }
                else{
                    // MulesoftExternalServiceMock scv=new MulesoftExternalServiceMock(); 
                    ExternalServiceMock.postMock(intMsgIdsList);
                }
            }
         /*   for(String key : serviceIntgMsgIdsMap.keySet()){
                
                List<Id> intMsgIdsList  = serviceIntgMsgIdsMap.get(key);
              //  Type request = serviceTypeMaps.get(key);
                
                UseExtSrcMoc__c mc = UseExtSrcMoc__c.getOrgDefaults();
                
                if(!(mc.Use_Mock__c)){
                    
                ExternalService scv=(ExternalService) request.newInstance(); 
                    scv.post(intMsgIdsList);
                }
                else{
                    // MulesoftExternalServiceMock scv=new MulesoftExternalServiceMock(); 
                    ExternalServiceMock.postMock(intMsgIdsList);
                }
                
            }*/
        } catch(Exception ex){
            
            system.debug('::::Exception Message::::'+ex.getMessage());
            system.debug('::::Exception Line Number::::'+ex.getLineNumber());
        }
        
    }
}