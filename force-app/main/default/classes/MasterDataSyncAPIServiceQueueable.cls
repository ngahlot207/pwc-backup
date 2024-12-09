public class MasterDataSyncAPIServiceQueueable implements Queueable,Database.AllowsCallouts{
    // Define member variables to hold parameters
    public String recordId;
    public String apiVendor;
    public String svcName;
    public String payload;
    public List<IntgMsg__c> intgMsgList;
    // Constructor to initialize the parameters
    public MasterDataSyncAPIServiceQueueable(/*String recordId, String apiVendor,String svcName, String payload */ List<IntgMsg__c> intgMsgList) {
        //this.recordId = recordId;
        //this.apiVendor = apiVendor;
        //this.svcName = svcName;
        //this.payload = payload;
        this.intgMsgList = intgMsgList;
    }
    
    public void execute(QueueableContext context) {
        if(!intgMsgList.isEmpty()){
            List<IntgMsg__c> updateIntgMsgList = new List<IntgMsg__c>();
            for(IntgMsg__c intgmsg: intgMsgList){
                try{
                    HttpRequest req = new HttpRequest();
                    HttpResponse res = new HttpResponse();
                    Http http = new Http();
                    req.setMethod('POST');
                    req.setEndpoint('callout:MasterDataSync');
                    req.setBody(intgmsg.Req__c);
                    req.setTimeout(30000);
                    res = http.send(req);
                    System.debug('::::::StatusCode::::::'+res.getStatusCode());
                    System.debug('::::::Response::::::' + res.getBody());  
                    
                    IntgMsg__c intg = new IntgMsg__c();
                    intg.Id = intgmsg.id;//recordId;
                    intg.Status__c = GlobalConstants.INT_MSG_Status_Responded;
                    intg.Resp__c = res.getBody();
                    intg.ExecType__c = 'Async';
                    updateIntgMsgList.add(intg);
                }
                catch(Exception ex){
                    
                    IntgMsg__c intg = new IntgMsg__c();
                    intg.Id = intgmsg.id;//recordId;
                    intg.Status__c = GlobalConstants.INT_MSG_Status_EXCEPTION;
                    updateIntgMsgList.add(intg);
                    //GlobalUtility.logMessage('Error', 'MasterDataSyncAPIServiceQueueable' + ex.getLineNumber(), 'postSvc', recordId, null, ex.getMessage() + ' Line: ' + ex.getLineNumber() , null, ex, null);
                    System.debug(ex.getMessage() + ' line ' + ex.getLineNumber());
                }
            }
            if(!updateIntgMsgList.isEmpty()){
                update updateIntgMsgList;
            }
        }
        /*try{
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
        GlobalUtility.logMessage('Error', 'MasterDataSyncAPIServiceQueueable' + ex.getLineNumber(), 'postSvc', recordId, null, ex.getMessage() + ' Line: ' + ex.getLineNumber() , null, ex, null);
        }
        */
        
    }
}