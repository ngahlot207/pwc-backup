public class GenerateShortUrlAPIService implements ExternalService{
    
    public static void post(List<Id> Ids){
        
        List<IntgMsg__c> intgList = [Select Id, ApiVendor__c, Svc__c, Req__c from IntgMsg__c Where Id IN: Ids];
        if(!intgList.isEmpty()){
            for(IntgMsg__c intg: intgList){
                postSvc(intg.Id, intg.ApiVendor__c,intg.Svc__c,intg.Req__c);
                
            }
        }
    }
    
    @future(callout=true)
    public static void postSvc( String recordId, String apiVendor,String svcName, String payload ){
        
        try{
            
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            
            req.setEndpoint('callout:ShortURLAPI');
            req.setMethod('POST');
            req.setTimeout(30000);
            req.setBody(payload);
            
            res = http.send(req);
            
            
            
            IntgMsg__c intg = new IntgMsg__c();
            intg.Id = recordId;
            intg.Status__c = GlobalConstants.INT_MSG_Status_Responded;
            intg.MStatus__c= GlobalConstants.INT_MSG_MStatus_ACKNOWLEDGED;
            intg.Resp__c=(res!=null && res.getBody() !=null)?res.getBody():'';
            update intg;
            
            
        }catch(Exception ex){
            
            IntgMsg__c intg = new IntgMsg__c();
            intg.Id = recordId;
            intg.Status__c = GlobalConstants.INT_MSG_Status_EXCEPTION;
            update intg;
            
            GlobalUtility.logMessage('Error', 'GenerateShortUrlAPIService' + ex.getLineNumber(), 'postSvc', recordId, null, ex.getMessage() + ' Line: ' + ex.getLineNumber() , null, ex, null);
        }
        
    }
    
}