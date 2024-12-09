public class ArchitectAuthenticationRequestWrapper {

    public String regNo;	//CA/1975/00022
	public String consent;	//Y
	public ClientData clientData;
	public class ClientData {
		public String caseId;	//123456
	}
	public static ArchitectAuthenticationRequestWrapper parse(String json){
		return (ArchitectAuthenticationRequestWrapper) System.JSON.deserialize(json, ArchitectAuthenticationRequestWrapper.class);
	}
}