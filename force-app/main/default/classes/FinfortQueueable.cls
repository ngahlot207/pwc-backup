public class FinfortQueueable implements Queueable{
    
    private IntgMsg__c intmsg;
    private string jsonresponse;
    
    Public FinfortQueueable(IntgMsg__c intmsg,String jsonresponse){
        this.intmsg =intmsg;
        this.jsonresponse =jsonresponse;
    }
    
    public void execute(QueueableContext context) {
        
        Map<IntgMsg__c,FinfortOrderDeliveryResponseWrapper> successResponseMap = new Map<IntgMsg__c,FinfortOrderDeliveryResponseWrapper>();
        Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
        
        try{
            
            FinfortOrderDeliveryResponseWrapper resp = (FinfortOrderDeliveryResponseWrapper) JSON.deserialize(jsonresponse.replace('Other_Non_Current_Assets_(Security_Deposits)','Other_Non_Current_Assets_Security_Deposits').replace('Share_Capital_or_Partner\'s_Capital','Share_Capital_or_Partners_Capital').replace('header_info','headerInfo').replace('order_number','ffOrderNumber').replace('lender_ref_number','lenderRefNumber'),FinfortOrderDeliveryResponseWrapper.class);
            
            if(resp!=null){
                successResponseMap.put(intmsg,resp);
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'FinfortOrderDeliveryResponseProcessor class',
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            failureResponseMap.put(intmsg,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
        }
        
        
        if(!successResponseMap.isEmpty()){
            FinfortOrderDeliveryResponseProcessor.processSuccess(successResponseMap);
        }
        
        if(!failureResponseMap.isEmpty()){
            FinfortOrderDeliveryResponseProcessor.processFailure(failureResponseMap);
        }
        
        
    }
    
}