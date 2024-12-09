public class CKYCAPIService implements Externalservice{
    
   public static void post(List<id> ids){
       
       if(!ids.isempty()){
           
           for(IntgMsg__c intmsg:[Select id,ApiVendor__c,Svc__c, Req__c from IntgMsg__c where Id IN:ids]){
               
               APIGatewayService.postSvc(intmsg.Id);
           }
       }
        
    }

}