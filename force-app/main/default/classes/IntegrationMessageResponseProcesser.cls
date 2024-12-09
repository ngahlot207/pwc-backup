public class IntegrationMessageResponseProcesser {
    
    //In responseProcesser method , we are receiving Integration Message List and service list and business unit list and  
    //Bulikifying the data to get Request Generator class name based on service name and business unit 
    public static void responseProcesser(Map<Id,IntgMsg__c>IntList,List<String>SERVICE_LST,List<String>BU_LST){
        try{
            List<IntgConfig__mdt>intConfigmdt = [SELECT Id,	Response_Generator_Class__c,Svc__c,BU__c FROM IntgConfig__mdt WHERE Svc__c IN: SERVICE_LST AND BU__c IN:BU_LST ]; 
            
            List<IntgMsg__c>IntRecord = New List<IntgMsg__c>();
            
            Map<String,List<IntgMsg__c>> buServiceMsgMap = new Map<String,List<IntgMsg__c>>();
            
            Map<String,Type> buServiceTypeMaps = new Map<String,Type>();
            
            for (IntgConfig__mdt medat : intConfigmdt){
                
                Type response = Type.forname(medat.Response_Generator_Class__c);
                
                system.debug(' Response_Generator_Class  ' + medat.Response_Generator_Class__c);
                
                if(buServiceTypeMaps.get(medat.BU__c+'-'+medat.Svc__c) == null){
                    
                    buServiceTypeMaps.put(medat.BU__c+'-'+medat.Svc__c,response);
                    
                }  
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
            for(String buSerKeuy : buServiceMsgMap.keySet()){
                
                system.debug('buSerKeuy'+buSerKeuy);
                
                List<IntgMsg__c> intMsgList  = buServiceMsgMap.get(buSerKeuy);
                String[] data = buSerKeuy.split('-');
                String businessUnit = data[0];
                String service = data[1];
                
                Type response = buServiceTypeMaps.get(buSerKeuy);
                
                try{
                    //generating the instance for IintMsgCalloutResponseProcessor and calling it dynamically 
                    
                    IintMsgCalloutResponseProcessor objInf=(IintMsgCalloutResponseProcessor) response.newInstance(); 
                    
                    objInf.process(intMsgList);
                    
                }
                //Exception Handling
                catch(Exception ex){
                    GlobalUtility.logMessage('Error', 'IntegrationMessageResponseProcesser', 
                                             'responseProcesser', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                }
            }
        } 
        //Exception Handling
        catch(Exception ex){
             system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
            GlobalUtility.logMessage('Error', 'IntegrationMessageResponseProcesser', 
                                     'responseProcesser', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
    } 
}