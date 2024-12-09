public class passportResponseWrapper {
    
    public cls_result result;
    public String requestId;    //f3de6c55-6c0f-11e9-bf8e-610d4b51e956
    public Integer statusCode;  //101
    public cls_clientData clientData;
    public class cls_result {
        public cls_passportNumber passportNumber;
        public String applicationDate;  //14/05/2018
        public String typeOfApplication;    //Tatkaal
        public cls_dateOfIssue dateOfIssue;
        public cls_name name;
    }
    public class cls_passportNumber {
        public String passportNumberFromSource; //S3733862
        public boolean passportNumberMatch;
    }
    public class cls_dateOfIssue {
        public String dispatchedOnFromSource;   //14/05/2018
        public boolean dateOfIssueMatch;
    }
    public class cls_name {
        public String nameScore;   //1
        public boolean nameMatch;
        public String surnameFromPassport;  //SHIRHATTI
        public String nameFromPassport; //OMKAR MILIND
    }
    public class cls_clientData {
        public String caseId;   //123456
    }
    public static passportResponseWrapper parse(String json){
        return (passportResponseWrapper) System.JSON.deserialize(json, passportResponseWrapper.class);
    }
}