public class BureauPdfQueueable implements Queueable {
    
    
    private String jsonString;
    Private String Apiidentifier;
    Private IntgMsg__c response;
    
    public BureauPdfQueueable(String jsonString,IntgMsg__c response,String Apiidentifier) {
        
        this.jsonString = jsonString;
        this.Apiidentifier = Apiidentifier;
        this.response = response;
    }
    
    public void execute(QueueableContext context){
        
        try{
            if(Apiidentifier=='Consumer API'){
               
               string jsonStr=jsonString.replace('JSON-RESPONSE-OBJECT','JSONResponseObject');
               ConsumerIssueResponseWrapper res  = (ConsumerIssueResponseWrapper) JSON.deserialize(jsonStr, ConsumerIssueResponseWrapper.class);
               
                 if (res.STATUS == 'COMPLETED') {
                    
                    if (res.FINISHED != null && !res.FINISHED.isEmpty()) {
                        
                        if (res.FINISHED[0].STATUS == 'SUCCESS') {
                            ConsumerIssueResponseProcessor.BureauSuccess(response.RefId__c,res);
                            BureauConsumerPdfQueueable queueableInstance = new BureauConsumerPdfQueueable(jsonString,response.RefId__c);
                            System.enqueueJob(queueableInstance);
                            APICalloutTracker.update_ApiTrackerWithIntMsg(response.Id,response.Svc__c, response.RefId__c, 'Success');
                            
                        } else if (res.FINISHED[0].STATUS == 'BUREAU-ERROR') {
                            ConsumerIssueResponseProcessor.BureauError(jsonString,response.RefId__c);
                            APICalloutTracker.update_ApiTrackerWithIntMsg(response.Id,response.Svc__c, response.RefId__c, 'Failure');
                        }
                    }
                    
                    if (res.REJECT != null && !res.REJECT.isEmpty() && res.REJECT[0].STATUS == 'ERROR') {
                        ConsumerIssueResponseProcessor.BureauReject(res,response.RefId__c);
                        APICalloutTracker.update_ApiTrackerWithIntMsg(response.Id,response.Svc__c, response.RefId__c, 'Failure');
                    }
                    
                    if(res.REJECT != null && !res.REJECT.isEmpty() && res.REJECT[0].STATUS == 'DL-QUEUE'){
                        ConsumerIssueResponseProcessor.BureauDLQUEUE(res,response.RefId__c);
                        APICalloutTracker.update_ApiTrackerWithIntMsg(response.Id,response.Svc__c, response.RefId__c, 'Failure');
                    }
                }
                
               else if(res.STATUS == 'IN-PROCESS'){
                    ConsumerIssueResponseProcessor.BureauInProgress(response.RefId__c,response);
                }
                
                else{
                    APICalloutTracker.update_ApiTrackerWithIntMsg(response.Id,response.Svc__c, response.RefId__c, 'Failure');
                }
                
            }
            //*********************************************************************************************************************************** 
            if(Apiidentifier=='Commercial API'){
                
                //CommercialIssueResponseWrapper res = (CommercialIssueResponseWrapper) JSON.deserialize(jsonString.replace('JSON-RESPONSE-OBJECT','JSONResponseObject').replace('PDF REPORT','PDF_REPORT').replace('ACKNOWLEDGEMENT-ID','ACKNOWLEDGEMENT_ID'), CommercialIssueResponseWrapper.class);
                string aa=jsonString.replace('JSON-RESPONSE-OBJECT','JSONResponseObject');
                string bb=aa.replace('PDF REPORT','PDF_REPORT');
                string cc=bb.replace('ACKNOWLEDGEMENT-ID','ACKNOWLEDGEMENT_ID');
                
                CommercialIssueResponseWrapper res = (CommercialIssueResponseWrapper) JSON.deserialize(cc, CommercialIssueResponseWrapper.class);
                
                
                if (res.STATUS == 'COMPLETED') { 
                    
                    if (res.FINISHED != null && !res.FINISHED.isEmpty()) {
                        
                        if (res.FINISHED[0].STATUS == 'SUCCESS') {
                            
                            CommercialIssueResponseProcessor.BureauSuccess(response.RefId__c,res);
                            APICalloutTracker.update_ApiTrackerWithIntMsg(response.Id,response.Svc__c, response.RefId__c, 'Success');
                            /*if(res.FINISHED[0].PDF_REPORT!=null){

// BureauCommercialPdfQueueable queueableInstance = new BureauCommercialPdfQueueable(res.FINISHED[0].PDF_REPORT,response.RefId__c);
// System.enqueueJob(queueableInstance);

}*/
                            
                        } else if (res.FINISHED[0].STATUS == 'BUREAU-ERROR') {
                            CommercialIssueResponseProcessor.BureauError(jsonString,response.RefId__c);
                            APICalloutTracker.update_ApiTrackerWithIntMsg(response.Id,response.Svc__c, response.RefId__c, 'Failure');
                        }
                    }
                    
                    if (res.REJECT != null && !res.REJECT.isEmpty() && res.REJECT[0].STATUS == 'ERROR') {
                        CommercialIssueResponseProcessor.BureauReject(res,response.RefId__c);
                        APICalloutTracker.update_ApiTrackerWithIntMsg(response.Id,response.Svc__c, response.RefId__c, 'Failure');
                        
                    }
                    
                    if(res.REJECT != null && !res.REJECT.isEmpty() && res.REJECT[0].STATUS == 'DL-QUEUE'){
                        CommercialIssueResponseProcessor.BureauDLQUEUE(res,response.RefId__c);
                        APICalloutTracker.update_ApiTrackerWithIntMsg(response.Id,response.Svc__c, response.RefId__c, 'Failure');
                    }
                }
                else if(res.STATUS == 'IN-PROCESS'){
                    CommercialIssueResponseProcessor.BureauInProgress(response.RefId__c,response);
                }
                
                else{
                   APICalloutTracker.update_ApiTrackerWithIntMsg(response.Id,response.Svc__c, response.RefId__c, 'Failure'); 
                }
                
                
            }
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'BureauPdfQueueable class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
            APICalloutTracker.update_ApiTrackerWithIntMsg(response.Id,response.Svc__c, response.RefId__c, 'Failure');
        }
        
        
    }
    
}