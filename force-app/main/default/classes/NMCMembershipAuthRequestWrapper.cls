public class NMCMembershipAuthRequestWrapper {

    public String registrationNo;	//2010103028
	public String yearOfReg;	//2010
	public String medicalCouncil;	//Maharashtra Medical Council
	public String consent;	//y
	public ClientData clientData;
	public class ClientData {
		public String caseId;	//123456
	}
	public static NMCMembershipAuthRequestWrapper parse(String json){
		return (NMCMembershipAuthRequestWrapper) System.JSON.deserialize(json, NMCMembershipAuthRequestWrapper.class);
	}
}