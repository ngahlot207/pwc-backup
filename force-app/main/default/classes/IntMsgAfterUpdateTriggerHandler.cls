public class IntMsgAfterUpdateTriggerHandler implements TriggerAction.Afterupdate{
    
    //In afterUpdate method , we are processing the trigger.oldmap and trigger.newmap values 
    //and storing records in map when Status is Responded
    
    public static void afterUpdate(List<IntgMsg__c> newList,List<IntgMsg__c> oldList){
        
        //Map to store Trigger.OldMap
        Map<Id,IntgMsg__c>OldRecordsMap=New Map<Id,IntgMsg__c>(oldList);
        
        
        List<String>servNames = New List<String>();
        
        List<String>BUNames =New List<String>(); 
        
        Map<Id,IntgMsg__c>IntList=New Map<Id,IntgMsg__c>();
        Map<Id,IntgMsg__c> inBoundIntgMsgList = new Map<Id,IntgMsg__c>();
        for (IntgMsg__c inte : newList) {
            
            if (inte.Status__c == GlobalConstants.INT_MSG_Status_Responded && inte.Status__c!= OldRecordsMap.get(inte.id).Status__c){//
                
                servNames.add(inte.Svc__c);
                BUNames.add(inte.BU__c);
                if(inte.Inbound__c){
                    inBoundIntgMsgList.put(inte.id,inte);
                }
                else{
                    IntList.put(inte.id,inte);
                }
                
                
            }
        }
        //checking whenther IntList empty or not
        if(!IntList.isEmpty()){
            IntegrationMessageResponseProcesser.responseProcesser(IntList,servNames,BUNames);
        }
        if(!inBoundIntgMsgList.isEmpty()){
            IntegrationMessageCallbackProcesser.responseProcesser(inBoundIntgMsgList,servNames,BUNames);
        }
    }  
}