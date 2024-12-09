public with sharing class publishPlatFormeventControllerClass {

    public static void publishPlatFormeventmethod(platformEventWrapper platformWra){
        
        List<IntRespEvent__e> resEvents = new List<IntRespEvent__e>();
        
        IntRespEvent__e intevent=new IntRespEvent__e();
        intevent.IntMsgId__c = platformWra.intId;
        intevent.RecId__c = platformWra.recId;
        intevent.SvcName__c = platformWra.ServiceName;
        intevent.Success__c=platformWra.success;
        if(platformWra.intMsgRes !=null && !String.isEmpty(platformWra.intMsgRes)){
            intevent.IntMsg_Res__c = platformWra.intMsgRes;
        }
        
        if(platformWra.errorMessage !=null && !String.isEmpty(platformWra.errorMessage)){
            intevent.Error_Message__c=platformWra.errorMessage;
        }
        
        intevent.coutResp__c= JSON.serialize(platformWra);
        resEvents.add(intevent);
        
        
        system.debug('resEvents ==>'+resEvents);
        system.debug('RecId__c == >'+intevent.RecId__c);
        system.debug('Success__c == >'+intevent.Success__c);
        system.debug('coutResp__c == >'+intevent.coutResp__c);
        System.debug('IntMsg_Res__c ==>'+intevent.IntMsg_Res__c);
        //System.debug('after replace  :'+ String.valueOf(intevent.IntMsg_Res__c).replace('\\' ,''));
        
        List<Database.SaveResult> results = EventBus.publish(resEvents);
        system.debug('PlatForm Evnet Published');
        
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' + err.getStatusCode() );
                }
            }  
        }  
    }
  //Wrapper class which is using for sending information to lwc through platform event
    public class  platformEventWrapper{
        public String Status{get; set;}
        public String ServiceName{get; set;}
        public String intId{get; set;}
        public String appId{get; set;}
        public String recId{get; set;}
        public String errorMessage{get;set;}
        public boolean success{get;set;}
        public String intMsgRes {get;set;}
    }  
    
}