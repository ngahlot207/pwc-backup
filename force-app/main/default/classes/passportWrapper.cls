public class passportWrapper {
    public String consent;
	public String fileNo;
	public String dob;
	public String passportNo;
	public String doi;
	public String name;
	public ClientData clientData;

	public class ClientData {
		public String caseId;
	}

	
	public static passportWrapper parse(String json) {
		return (passportWrapper) System.JSON.deserialize(json, passportWrapper.class);
	}

}