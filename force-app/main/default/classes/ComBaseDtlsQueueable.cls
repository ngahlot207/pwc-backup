public class ComBaseDtlsQueueable implements Queueable{
    private String Jsonrespose;
    private Map<IntgMsg__c,ComBaseDtlsResponseWrapper> successResponseMap;
    
    public ComBaseDtlsQueueable(Map<IntgMsg__c,ComBaseDtlsResponseWrapper> successResponseMap,String Jsonrespose){
        this.Jsonrespose=Jsonrespose;
        this.successResponseMap =successResponseMap;
    }
    
    public void execute(QueueableContext context){
        
        try{  
            if(successResponseMap!=null && !successResponseMap.isEmpty()){

                
                ComBaseDtlsResponseWrapper res = (ComBaseDtlsResponseWrapper) JSON.deserialize(Jsonrespose, ComBaseDtlsResponseWrapper.class);
                if(res!=null){

                    if(res.metadata!=null && res.metadata.last_updated !=null){   
                    ComBaseDtlsResponseProcessor.processSuccess(successResponseMap); 
                }
                else if(res.message != null && !String.isBlank(res.message)){
                    System.debug('failure res :'+res.message);
                    ComBaseDtlsResponseProcessor.processFailure(res.message ,successResponseMap);
                }

                }
                

                

            }
        }
        catch(Exception ex){ //{"message":"Invalid PAN format"}
        System.debug('Exception at ComBaseDtlsQueueable :'+ex);
         }
    }
}