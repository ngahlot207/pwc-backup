public with sharing class LlpCompreDtlsQueueable implements Queueable{
    private String Jsonrespose;
    private Map<IntgMsg__c,LlpCompreDtlsResponseWrapper> successResponseMap;
    
    public LlpCompreDtlsQueueable(Map<IntgMsg__c,LlpCompreDtlsResponseWrapper> successResponseMap,String Jsonrespose){
        this.Jsonrespose=Jsonrespose;
        this.successResponseMap =successResponseMap;
    }
    
    public void execute(QueueableContext context){
        
        try{  
            if(successResponseMap!=null && !successResponseMap.isEmpty()){

                
                LlpCompreDtlsResponseWrapper res = (LlpCompreDtlsResponseWrapper) JSON.deserialize(Jsonrespose, LlpCompreDtlsResponseWrapper.class);
                if(res!=null)
            {
                if(res.metadata!=null && res.metadata.last_updated !=null){   
                    LlpCompreDtlsResponseProcessor.processSuccess(successResponseMap); 
                }
                //{"message":"Invalid PAN format"}
                else if(res.message != null && !String.isBlank(res.message)){
                    LlpCompreDtlsResponseProcessor.processFailure(res.message ,successResponseMap);
                }

            }

            }
        }
        catch(Exception ex){ 
             System.debug('Exception LlpCompreDtlsQueueable::'+ex);
         }
    }
}