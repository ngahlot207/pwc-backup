public class SMSWrapper {
    
    public class Response{
        public Result result;
    }
    public class Result {
        public String req_id;
        public String msisdn;
        public Status status;
    }
    public class Status {
        public String statusCode;
    }
    
    public static SMSWrapper parse(String json) {
        return (SMSWrapper) System.JSON.deserialize(json, SMSWrapper.class );
    }
}