public class ChequeOCRResponseWrapper {

    public String requestId;	//145ee733-99bb-4159-b832-ef
	public Result result;
	public Integer statusCode;	//101
	public ClientData clientData;
	
    public class Result {
		public String accNo;	//
		public String bank;	//
		public String chequeNo;	//
		public String ifsc;	//
		public String micr;	//
		public BankDetails bankDetails;
		public List<String> name;
	}
	
    public class BankDetails {
		public String address;	//
		public String branch;	//
		public String city;	//
		public String contact;	//
		public String district;	//
		public String state;	//
	}
	public class ClientData {
		public String caseId;	//123456
	}
	public static ChequeOCRResponseWrapper parse(String json){
		return (ChequeOCRResponseWrapper) System.JSON.deserialize(json, ChequeOCRResponseWrapper.class);
	}
    
}