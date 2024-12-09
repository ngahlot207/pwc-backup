public class AddressSplitAPIResponseWrapper {
    
    public String request_id;
    public String statuscode;//status-code
    public Result result;
    public ClientData clientData;
    
    public class Result{
        public String Building;
        public String City;
        public String Pin;
        public String District;
        public String Floor;
        public String House;
        public String locality;
        public String State;
        public String Complex;
        public String Landmark;
        public String Untagged;
       // public String CO;//C/O
        public String Street;
    }
    
     public class ClientData{
        public String caseId;
    }
}