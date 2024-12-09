public class WhatsAppResponseWrapper {
    public List<Response> response;
    public Integer errorCode;	//408
    public String message;	//User details not found
    public String status;	//Failed
    public class Response {
        public String destination;	//919999999999
        public String mrid;	//3410181032443027196
        public String status;	//submitted
    }
    public static WhatsAppResponseWrapper parse(String json){
        return (WhatsAppResponseWrapper) System.JSON.deserialize(json, WhatsAppResponseWrapper.class);
    }
}