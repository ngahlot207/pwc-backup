public class EmailRequestWrapper {

	public String email;
	public String version;
	public ClientData clientData;

	public class ClientData {
		public String caseId;
	}

	
	public static EmailRequestWrapper parse(String json) {
		return (EmailRequestWrapper) System.JSON.deserialize(json, EmailRequestWrapper.class);
	}
}