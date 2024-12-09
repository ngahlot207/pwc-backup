public class APIGatewayServiceQueueable implements Queueable,Database.AllowsCallouts {
    
    // Define member variables to hold parameters
    public String recordId;
    
    // Constructor to initialize the parameters
    public APIGatewayServiceQueueable(String recordId) {
        this.recordId = recordId;
    }
    
    public void execute(QueueableContext context) {
        
        List<IntgMsg__c> intgList = [Select Id, ApiVendor__c, Svc__c, Req__c from IntgMsg__c Where Id =:recordId LIMIT 1];
        if(intgList!=null && !intgList.isEmpty()){
            APIGatewayService.performAPICallout(intgList[0].Id, intgList[0].ApiVendor__c,intgList[0].Svc__c,intgList[0].Req__c);
        }    
    }
    
}