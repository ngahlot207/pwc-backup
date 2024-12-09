public class GSTPANResponseWrapper {
	public Integer statusCode;
	public String requestId;
	public List<Result> result;
	public ClientDataclass clientData;
    
    public  Integer status; //400,
    public String error; //Bad Request
	
	public class Result {
		public String emailId;
		public String applicationStatus;
		public String mobNum;
		public String pan;
		public String gstinRefId;
		public String regType;
		public String authStatus;
		public String gstinId;
		public String registrationName;
		public String tinNumber;
	}
	
	public class ClientDataclass {
		public String caseId;
	}
}