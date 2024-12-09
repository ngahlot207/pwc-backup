public class EmailWrapper {

	public String email;
	public String version;
	public ClientData clientData;

	public class ClientData {
		public String caseId;
	}

	
	public static EmailWrapper parse(String json) {
		return (EmailWrapper) System.JSON.deserialize(json, EmailWrapper.class);
	}
}