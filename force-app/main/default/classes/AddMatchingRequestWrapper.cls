public class AddMatchingRequestWrapper {

    public class ClientData {
		public String caseId;
	}

	public String address1;
	public String address2;
	public ClientData clientData;

	
	public static AddMatchingRequestWrapper parse(String json) {
		return (AddMatchingRequestWrapper) System.JSON.deserialize(json, AddMatchingRequestWrapper.class);
	}
}