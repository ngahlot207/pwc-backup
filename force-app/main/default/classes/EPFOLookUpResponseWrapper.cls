public class EPFOLookUpResponseWrapper {
    
    public Result result;
    public string request_id;
    public string statuscode;
    
    public class Result{
        public List<String> uan;
    }
    
    public class clientData{
        public string caseId;
    }

}