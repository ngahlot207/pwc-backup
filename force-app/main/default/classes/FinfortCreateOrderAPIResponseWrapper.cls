public class FinfortCreateOrderAPIResponseWrapper {
    
    public Integer statusCode;
    public Data data;
    public String msg;
    
    public class Data{
        public String ffOrderId;
        public String consent_link;
        public String orderStatus;
        
    }
    
}