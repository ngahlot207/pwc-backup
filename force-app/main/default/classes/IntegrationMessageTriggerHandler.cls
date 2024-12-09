public class IntegrationMessageTriggerHandler implements TriggerAction.AfterInsert{

    //In This method we are checking based on Status__c and IsActive__c 
    //and add to list and map based on the servNames and BUNames
    public static void AfterInsert(List<IntgMsg__c> newList){
        List<String>servNames = New List<String>();
        List<String>BUNames =New List<String>(); 
        Map<Id,IntgMsg__c>IntList=New Map<Id,IntgMsg__c>();
        List<IntgMsg__c> intMsgList = new List<IntgMsg__c>();
        for (IntgMsg__c inte : newList) {
            if (inte.Status__c == GlobalConstants.INT_MSG_STATUS_NEW && inte.IsActive__c && !inte.Inbound__c){
                
                servNames.add(inte.Svc__c);
                BUNames.add(inte.BU__c);
                IntList.put(inte.id,inte);
                system.debug('after insert Inside Kyc Class');
                system.debug('IntList == > ' +IntList);
            }
            if(inte.Inbound__c && inte.Status__c == GlobalConstants.INT_MSG_STATUS_NEW && inte.IsActive__c)
            {
               intMsgList.add(inte);
              // servNames.add(inte.Svc__c);
            }
        }
        // Here we are checking servNames ,BUNames and IntList empty or not
        // and we are calling IntegrationMessageRequestProcesser class   
        if(!servNames.isEmpty() && !BUNames.isEmpty() && !IntList.isEmpty()){
            system.debug('checking for intergration request processsor');
            IntegrationMessageRequestProcesser.requestProcesser(IntList,servNames,BUNames);    
        }
        if(!intMsgList.isEmpty())
        {
            IntegrationInboundprocessor.inboundProcess(intMsgList);
        }
    } 
}