public class NamasteCreditCaseCreatResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    public static void process(List<IntgMsg__c> responses) {
        
        if(!responses.isEmpty()){
            
            Map<IntgMsg__c,NamasteCreditCaseCreatResponseWrapper> successResponseMap = new Map<IntgMsg__c,NamasteCreditCaseCreatResponseWrapper>();
            Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
            
            
            for(IntgMsg__c intmsg:responses){
                
                try{
                    
                    if(String.isnotBlank(intmsg.Resp__c)){
                        
                         NamasteCreditCaseCreatResponseWrapper  res =(NamasteCreditCaseCreatResponseWrapper) JSON.deserialize(intmsg.Resp__c,NamasteCreditCaseCreatResponseWrapper.class);
                    
                        
                        //Success
                        if(res!=null && string.isNotblank(res.DES_CODE) && res.DES_CODE=='NC08'){
                            successResponseMap.Put(intmsg,res);
                        }
                    
                       //Failure
                        if(res!=null && string.isNotblank(res.DES_CODE) && res.DES_CODE!='NC08' &&  String.isNotblank(res.message)){
                            failureResponseMap.Put(intmsg,res.message);
                        }
                    }
                    
                }catch(Exception ex){
                    GlobalUtility.logMessage('Error', 'NamasteCreditCaseCreatResponseProcessor class', 
                                             'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                    failureResponseMap.put(intmsg,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                }
            }
            
        }
    }
    
}