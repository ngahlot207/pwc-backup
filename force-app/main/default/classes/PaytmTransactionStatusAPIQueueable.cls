public class PaytmTransactionStatusAPIQueueable implements Queueable, Database.AllowsCallouts{
    
    private List<IntgMsg__c> intgMsgList;
    
    public PaytmTransactionStatusAPIQueueable(List<IntgMsg__c> intgMsgList) {
        this.intgMsgList = intgMsgList;
    }
    
    public void execute(QueueableContext context) {
        try {
            if (!intgMsgList.isEmpty()) {
                
                List<IntgMsg__c> updatedIntMsgList = new List<IntgMsg__c>();
                
                for (IntgMsg__c intmsg : intgMsgList) {
                    
                    try {
                        
                        if (String.isNotBlank(intmsg.Req__c)) {
                            
                            HttpRequest req = new HttpRequest();
                            req.setEndpoint('callout:APIGateway');
                            req.setMethod('POST');
                            req.setHeader('APIVendor', intmsg.ApiVendor__c);
                            req.setHeader('APIname', intmsg.Svc__c);
                            req.setHeader('RecordID', intmsg.Id);
                            req.setBody(intmsg.Req__c);
                            req.setTimeout(30000);
                            
                            Http http = new Http();
                            HttpResponse res = http.send(req);
                            
                            System.debug('StatusCode==' + res.getStatusCode());
                            System.debug('Response==' + res.getBody());
                            
                            intmsg.MStatus__c = GlobalConstants.INT_MSG_MStatus_ACKNOWLEDGED;
                            intmsg.Mresp__c = res.getBody();
                            updatedIntMsgList.add(intmsg);
                        }
                    } catch (Exception ex) {
                        GlobalUtility.logMessage('Error', 'PaytmTransactionStatusAPIQueueable', 
                                                 'execute API callout', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                    }
                }
                
                if (!updatedIntMsgList.isEmpty()) {
                    update updatedIntMsgList;
                }
            }
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'PaytmTransactionStatusAPIQueueable', 'execute', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
}