public class CAMembershipAuthResponseWrapper {
	
    public Result result;
	public String request_id;	//c79e9c4a-1f17-4c45-a1ec-3a0f8243c889
	public String statuscode;	//101
	public ClientData clientData;
	public class Result {
		public String name;	//RAMACHANDRAN P
		public String address;	//D NO 29/3 ARUL JOTHI COMPLEX 2ND FLOOR NO 16 BINNY MAIN ROAD TIRUPUR 641601
		public String gender;	//M
		public String AssociateYear;	//A2014
		public String Qualification;	//B.COM
		public String COPStatus;	//FULL TIME
		public String FellowYear;	//F2019
		public String memberStatus;
		public String mobileNo;	//
		public String email;	//
	}
	public class ClientData {
		public String caseId;	//123456
	}
    
    public  Integer status; //400,
    public String error; //Bad Request
    
	public static CAMembershipAuthResponseWrapper parse(String json){
		return (CAMembershipAuthResponseWrapper) System.JSON.deserialize(json, CAMembershipAuthResponseWrapper.class);
	}
}