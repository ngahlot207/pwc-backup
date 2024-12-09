public class RequestStampPaperResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    public static void process(List<IntgMsg__c> responses){ 
        Map<IntgMsg__c,RequestStampPaperResponseWrapper> successResponseMap = new Map<IntgMsg__c,RequestStampPaperResponseWrapper>();
        Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
        for(IntgMsg__c integrationMessage : responses){
            try{
                RequestStampPaperResponseWrapper response = (RequestStampPaperResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, RequestStampPaperResponseWrapper.class);
                if(response!=null){
                    if(response.status.equalsIgnoreCase('success')){
                        
                    }
                    else{
                        failureResponseMap.put(integrationMessage, (response.message!=null && String.isNotBlank(response.message)) ? response.message : (response.error!=null && String.isNotBlank(response.error)) ? response.error : (response.error_code!=null && String.isNotBlank(response.error_code)) ? response.error_code : '');
                    }
                }
            }
            
            catch(Exception ex){
                
                failureResponseMap.put(integrationMessage,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                GlobalUtility.logMessage('Error', 'RequestStampPaperResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                
            }
        }
    }
}