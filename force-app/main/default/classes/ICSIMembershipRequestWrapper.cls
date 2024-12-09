public class ICSIMembershipRequestWrapper {

    public String consent;	//<<Y/N>>
	public String membershipNo;	//A4567
	public String cpNo;	//
	public ClientData clientData;
	public class ClientData {
		public String caseId;	//123456
	}
	public static ICSIMembershipRequestWrapper parse(String json){
		return (ICSIMembershipRequestWrapper) System.JSON.deserialize(json, ICSIMembershipRequestWrapper.class);
	}
}