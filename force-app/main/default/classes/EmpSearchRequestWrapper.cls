public class EmpSearchRequestWrapper {
    public String employer;
	public String name;
	public String mobile;
	public String emailId;
	public String consent;
	public ClientData clientData;

	public class ClientData {
		public String caseId;
	}

	
	public static EmpSearchRequestWrapper parse(String json) {
		return (EmpSearchRequestWrapper) System.JSON.deserialize(json, EmpSearchRequestWrapper.class);
	}
}