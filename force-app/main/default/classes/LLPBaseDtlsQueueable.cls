public with sharing class LLPBaseDtlsQueueable implements Queueable{
    private String Jsonrespose;
    private Map<IntgMsg__c,LLPBaseDtlsResponseWrapper> successResponseMap;
    
    public LLPBaseDtlsQueueable(Map<IntgMsg__c,LLPBaseDtlsResponseWrapper> successResponseMap,String Jsonrespose){
        this.Jsonrespose=Jsonrespose;
        this.successResponseMap =successResponseMap;
    }
    
    public void execute(QueueableContext context){
        
        try{  
            if(successResponseMap!=null && !successResponseMap.isEmpty()){
                LLPBaseDtlsResponseWrapper res = (LLPBaseDtlsResponseWrapper) JSON.deserialize(Jsonrespose, LLPBaseDtlsResponseWrapper.class);
                
                if(res!=null)
            {

                if(res.metadata!=null && res.metadata.last_updated !=null){   
                    System.debug('res.metadata.last_updated :'+res);
                    LLPBaseDtlsResponseProcessor.processSuccess(successResponseMap); 
                }
                else if(res.message != null && !String.isBlank(res.message)){
                    System.debug('res.metadata.last_updated ='+res.message);
                    LLPBaseDtlsResponseProcessor.processFailure(res.message ,successResponseMap);
                }
            }

            }
        }
        catch(Exception ex){ //{"message":"Invalid PAN format"}

        System.debug('Exception LLPBaseDtlsQueueable::'+ex);
        System.debug('Exception LLPBaseDtlsQueueable::'+ex.getLineNumber());
        System.debug('Exception LLPBaseDtlsQueueable::'+ex.getMessage());
        }
    }
}