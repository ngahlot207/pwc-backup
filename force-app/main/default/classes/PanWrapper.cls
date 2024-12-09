public class PanWrapper {

    
    public String consent;
	public String pan;
	public ClientData clientData;

	public class ClientData {
		public String caseId;
	}

	
	public static PanWrapper parse(String json) {
		return (PanWrapper) System.JSON.deserialize(json, PanWrapper.class);
	}
}