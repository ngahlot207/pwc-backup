public class IntOCRPanResponseWrapper {
    public String requestId; //4fcde3c9-825e-4927-9381-de9f23580d05
    public cls_result[] result;
    public Integer statusCode; //101
    public class cls_result {
        public cls_details details;
        public String type; //Pan
    }
    public class cls_details {
        public cls_date dateValue;
        public cls_dateOfIssue dateOfIssue;
        public cls_father father;
        public cls_name name;
        public cls_panNo panNo;
        public cls_qualityCheck qualityCheck;
    }
    public class cls_date {
        public String conf; //1
        public String value; //22/03/1994
    }
    public class cls_dateOfIssue {
        public String conf; //0
        public String value; //
    }
    public class cls_father {
        public String conf; //0.81
        public String value; //CHTTA RANJAN MOHAN
    }
    public class cls_name {
        public String conf; //1
        public String value; //ANUPAM MOHANTY
    }
    public class cls_panNo {
        public String conf; //1
        public String value; //CEEPM6433B
    }
    public class cls_qualityCheck {
        public String brightness; //52
        public String isBlackWhite; //no
        public String isBlur; //yes
        public String isCutCard; //no
    }
    public static IntOCRPanResponseWrapper parse(String json) {
        return (IntOCRPanResponseWrapper) System.JSON.deserialize(json, IntOCRPanResponseWrapper.class );
    }
}