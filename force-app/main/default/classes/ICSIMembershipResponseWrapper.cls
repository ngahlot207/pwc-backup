public class ICSIMembershipResponseWrapper {

    public String requestId;	//da9d73c8-4a52-4c5a-a02c-99a1f97379c5
	public List<Result> result;
	public Integer statusCode;	//101
	public ClientData clientData;
	public class Result {
		public String organization;	//COCHIN MINERALS & RUTILE LTD.
		public String city;	//ALUVA
		public String designation;	//CHIEF GEN MANAGER(FIN)&CO SECY
		public String benevolentMember;
		public String phone;
		public String membershipNumber;	//A4567
		public String cpNumber;	//0
		public String address;	//P.B. NO.73,,VIII / 224,MARKET ROAD,Kerala,ERNAKULAM,ALUVA,683101
		public String mobile;	//9447021114
		public String email;	//SKUMARPAI@GMAIL.COM
		public String memberName;	//CS P SURESHKUMAR
		public String memberImage;	//base 64 format
	}
	public class ClientData {
		public String caseId;	//123456
	}
	public static ICSIMembershipResponseWrapper parse(String json){
		return (ICSIMembershipResponseWrapper) System.JSON.deserialize(json, ICSIMembershipResponseWrapper.class);
	}
}