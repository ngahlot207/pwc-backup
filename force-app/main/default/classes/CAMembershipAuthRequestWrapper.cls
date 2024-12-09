public class CAMembershipAuthRequestWrapper {
	
    public String membership_no;	//235400
	public boolean contactDetails;
	public String consent;	//y
	public ClientData clientData;
	public class ClientData {
		public String caseId;	//123456
	}
	public static CAMembershipAuthRequestWrapper parse(String json){
		return (CAMembershipAuthRequestWrapper) System.JSON.deserialize(json, CAMembershipAuthRequestWrapper.class);
	}
}