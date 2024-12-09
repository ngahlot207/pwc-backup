public class AadharMaskingResponseWrapper {
        public String respcode; 
        public String respdesc;
        public String txnid;
        public String rrn;
        public String refr;
        public String file;
        public String txnmode;
        public String timespan;
        public String aadhaars;
    
    public static AadharMaskingResponseWrapper praser(string json){
        return (AadharMaskingResponseWrapper) system.json.deserialize(json,AadharMaskingResponseWrapper.class);
    }
        

}