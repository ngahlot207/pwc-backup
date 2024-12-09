public class CommercialACKResponseWrapper {
public String STATUS;
    public Integer ACKNOWLEDGEMENT_ID;
    public HeaderInfo HEADER;
    public List<ErrorInfo> ERRORS;
    

    public class ErrorInfo {
        public String CODE;
        public String DESCRIPTION;
    }
    
    public class HeaderInfo {
        public String CUST_ID;
        public String APPLICATION_ID;
        public String RESPONSE_TYPE;
        public String REQUEST_RECEIVED_TIME;
    }
    public Static CommercialACKResponseWrapper praser(String json){
        return (CommercialACKResponseWrapper) system.JSON.deserialize(json,CommercialACKResponseWrapper.class);
    }
}