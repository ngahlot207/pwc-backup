public class IntegrationMessageRequestProcesser {
    
    // In requestProcesser we are calling custom metadata IntgConfig__mdt ,IntgSvcMgmt__mdt
    // Here we are checking based on the service and business unit
    //Creating a List and map to bulkify code
    public static void requestProcesser(Map<Id,IntgMsg__c>IntList, List<String>SERVICE_LST,List<String>BU_LST){
        try{
            
            List<IntgConfig__mdt>intConfigmdt = [SELECT Id,ReqGenCls__c,Svc__c,BU__c,IsActive__c FROM IntgConfig__mdt WHERE Svc__c IN: SERVICE_LST   AND BU__c IN:BU_LST ]; 
            List<IntgSvcMgmt__mdt>IntgSvcmdt = [SELECT Id,Svc__c,ApiVendor__c,ApiVersion__c,BU__c FROM IntgSvcMgmt__mdt WHERE Svc__c IN: SERVICE_LST   AND BU__c IN:BU_LST];
            system.debug('intConfigmdt:::'+intConfigmdt);//gives new Integration Message record Id
            system.debug('IntgSvcmdt:::'+IntgSvcmdt);
            List<IntgMsg__c>IntRecord = New List<IntgMsg__c>();
            Map<String,List<IntgMsg__c>> buServiceMsgMap = new Map<String,List<IntgMsg__c>>();
            Map<String,Type> buServiceTypeMaps = new Map<String,Type>();
            Map<String, IntgSvcMgmt__mdt> buServiceMap = new Map<String,IntgSvcMgmt__mdt>();
            IntRecord= IntList.values();
            //Iterating over new Intgeration metadata record to get ReqGenCls__c class
            for (IntgConfig__mdt medat : intConfigmdt){
                Type request = Type.forname(medat.ReqGenCls__c);
                system.debug('request:::'+medat.ReqGenCls__c);
                if(buServiceTypeMaps.get(medat.BU__c+'-'+medat.Svc__c) == null)
                    buServiceTypeMaps.put(medat.BU__c+'-'+medat.Svc__c,request);
            }  
            for(IntgMsg__c inte : IntList.values()){
                String buServiceValue = inte.BU__c+'-'+inte.Svc__c ;
                if(buServiceMsgMap.get(buServiceValue) != null){
                    List<IntgMsg__c> intMsgList = buServiceMsgMap.get(buServiceValue);
                    intMsgList.add(inte);
                }else{
                    List<IntgMsg__c> intMsgList = new  List<IntgMsg__c>();
                    intMsgList.add(inte);
                    buServiceMsgMap.put(buServiceValue,intMsgList);
                }
            }
            
            for(IntgSvcMgmt__mdt Intgmdt : IntgSvcmdt ){
                if(buServiceMap.get(Intgmdt.BU__c+'-'+Intgmdt.Svc__c) == null)
                    buServiceMap.put(Intgmdt.BU__c+'-'+Intgmdt.Svc__c,Intgmdt); 
            }
            
            for(String buSerKeuy : buServiceMsgMap.keySet()){
                List<IntgMsg__c> intMsgList  = buServiceMsgMap.get(buSerKeuy);
                String[] data = buSerKeuy.split('-');
                String businessUnit = data[0];
                String service = data[1];
                Type request = buServiceTypeMaps.get(buSerKeuy);
                // Handiling the exceptions using try catch 
                try{
                    //Here we are calling the interface class which is ICalloutRequestGeneratorclass and 
                    //calling dynamically and generate the newInstance
                    system.debug('intMsgList ' +intMsgList);
                    system.debug('buServiceMap ' +buServiceMap);
                    updateApiDetails(intMsgList, buServiceMap);
                    ICalloutRequestGenerator objInf=(ICalloutRequestGenerator) request.newInstance(); 
                    objInf.generate(intMsgList,service,businessUnit);    
                } catch(Exception ex){
                    
                    GlobalUtility.logMessage('Error', 'IntegrationMessageRequestProcesser line ', 
                                             'requestProcesser', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                }
                
            }
        } catch(Exception ex){
            
            GlobalUtility.logMessage('Error', 'IntegrationMessageRequestProcesser line ', 
                                     'requestProcesser', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
    }
    // In this method appending IntgMsg__c values to  IntgSvcMgmt__mdt  record values 
    //  based on the service and business unit
    public static void updateApiDetails(List<IntgMsg__c> intMsgList,  Map<String, IntgSvcMgmt__mdt> intmdt){
         fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
            new List<SObjectType> { IntgMsg__c.SObjectType }
        );
        List<IntgMsg__c>intMsgUpdate=New List<IntgMsg__c>();
        
        List<string> fieldNamesList = New List<string>{'ApiVersion__c','ApiVendor__c'};
            
            String sObjectName = 'IntgMsg__c';
        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
        fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
        
        for(IntgMsg__c ob : intMsgList){
            IntgSvcMgmt__mdt mt = intmdt.get(ob.BU__c+'-'+ob.Svc__c);
            
            if(mt != null){
                IntgMsg__c intmsgs=new IntgMsg__c();
                intmsgs.Id=ob.Id;
                intmsgs.ApiVersion__c =mt.ApiVersion__c ;
                intmsgs.ApiVendor__c =mt.ApiVendor__c;
                intMsgUpdate.add(intmsgs);
                system.debug('after updating version and vendor name');
            }
        }
        uow.registerDirty(intMsgUpdate);
        //update intMsgUpdate;
        uow.commitWork();
    }
    
    public class requestException extends Exception {
        
    }
}