public class ComCompreDtlsQueueable implements Queueable{
    private String Jsonrespose;
    private Map<IntgMsg__c,ComCompreDtlsResponseWrapper> successResponseMap;
    
    public ComCompreDtlsQueueable(Map<IntgMsg__c,ComCompreDtlsResponseWrapper> successResponseMap,String Jsonrespose){
        this.Jsonrespose=Jsonrespose;
        this.successResponseMap =successResponseMap;
    }
    
    public void execute(QueueableContext context){
        try{  
            if(successResponseMap!=null && !successResponseMap.isEmpty()){
                ComCompreDtlsResponseWrapper res = (ComCompreDtlsResponseWrapper) JSON.deserialize(Jsonrespose, ComCompreDtlsResponseWrapper.class);
                if(res!=null){
                if(res.metadata!=null && res.metadata.last_updated !=null){   
                    ComCompreDtlsResponseProcessor.processSuccess(successResponseMap); 
                }
                //{"message":"Invalid PAN format"}
                else if(res.message != null && !String.isBlank(res.message)){
                    System.debug('res.message =='+res.message);
                    ComCompreDtlsResponseProcessor.processFailure(res.message ,successResponseMap);
                }
                }
            }
        }
        catch(Exception ex){ 
            System.debug('Exception ComCompreDtlsQueueable::'+ex);

         }
    }
}