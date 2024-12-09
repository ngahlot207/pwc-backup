public class HRMSQueueable implements Queueable {
    
    private String Jsonrespose;
    
    public HRMSQueueable(String Jsonrespose){
        this.Jsonrespose=Jsonrespose;
    }
    
    public void execute(QueueableContext context){
        
        try{
            if(String.isNotblank(Jsonrespose)){
                HRMSAPIResponseWrapper res = (HRMSAPIResponseWrapper) JSON.deserialize(Jsonrespose, HRMSAPIResponseWrapper.class);
                
                if(res.status==1 || res.message.tolowercase()=='success'){
                    HRMSAPIResponseProcessor.processSuccessResponse(res); 
                }
                else if(res.status!=1 && res.message.tolowercase()!='success'){
                    HRMSAPIResponseProcessor.processFailureResponse(res.message);
                }
            }
        }
        catch(Exception ex){
             HRMSAPIResponseProcessor.processFailureResponse(IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
        }
    }
    
}