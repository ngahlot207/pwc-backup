public class MasterDataSyncAPIService implements ExternalService {
    
    @future(callout=true)
    public static void postSvc( String recordId, String apiVendor,String svcName, String payload ){
        try{
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            req.setMethod('POST');
            req.setEndpoint('callout:MasterDataSync');
            req.setBody(payload);
            req.setTimeout(30000);
            res = http.send(req);
            System.debug('::::::StatusCode::::::'+res.getStatusCode());
            System.debug('::::::Response::::::' + res.getBody());  
            
            IntgMsg__c intg = new IntgMsg__c();
            intg.Id = recordId;
            intg.Status__c = GlobalConstants.INT_MSG_Status_Responded;
            intg.Resp__c = res.getBody();
            intg.ExecType__c = 'Async';
            update intg;
        }
        catch(Exception ex){
            
            IntgMsg__c intg = new IntgMsg__c();
            intg.Id = recordId;
            intg.Status__c = GlobalConstants.INT_MSG_Status_EXCEPTION;
            update intg;
            GlobalUtility.logMessage('Error', 'MasterDataSyncAPIService' + ex.getLineNumber(), 'postSvc', recordId, null, ex.getMessage() + ' Line: ' + ex.getLineNumber() , null, ex, null);
        }
    }
    
    public static void post(List<Id> Ids){
        
        List<IntgMsg__c> intgList = [Select Id, ApiVendor__c, Svc__c, Req__c from IntgMsg__c Where Id IN: Ids];
        if(!intgList.isEmpty()){
            //for(IntgMsg__c intg: intgList){
                //postSvc(intg.Id, intg.ApiVendor__c,intg.Svc__c,intg.Req__c);
                //System.enqueueJob(new MasterDataSyncAPIServiceQueueable(intg.Id, intg.ApiVendor__c,intg.Svc__c,intg.Req__c)); 
                
            //}
            System.enqueueJob(new MasterDataSyncAPIServiceQueueable(intgList));
        }
    }

}