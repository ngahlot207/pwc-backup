public class ICWAIMembershipAuthRequestWrapper {

    public String consent;	//Y
	public String membership_no;	//14530
	public ClientData clientData;
	public class ClientData {
		public String caseId;	//123456
	}
	public static ICWAIMembershipAuthRequestWrapper parse(String json){
		return (ICWAIMembershipAuthRequestWrapper) System.JSON.deserialize(json, ICWAIMembershipAuthRequestWrapper.class);
	}
}