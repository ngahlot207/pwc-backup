public class KarzaErrorResponseController{
    
    public class KarzaErrorResponseWrapper {
        public String requestId;
        public Integer status;
        public String error;
        public ClientData clientData;
    }
    public class ClientData {
        public String caseId;
    }
    public static KarzaErrorResponseWrapper parse(String json){
        return (KarzaErrorResponseWrapper) System.JSON.deserialize(json, KarzaErrorResponseWrapper.class);
    }
    
    public static string getErrorMessage(IntgMsg__c integrationMessage){
        String errorMessage;
        KarzaErrorResponseWrapper responseError= (KarzaErrorResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, KarzaErrorResponseWrapper.class); 
        if(responseError.status!=null){
            if(!String.isBlank(responseError.error)){
                errorMessage=responseError.error;
            }
            
        }
        return errorMessage;
    }
}