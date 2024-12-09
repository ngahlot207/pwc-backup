public class KarzaElectricityBillRequestWrapper {
	public String consumer_id;
	public String service_provider;
	public String district;
	public String consent;
	public ClientDataClass clientData;
	
	public class ClientDataClass {
		public String caseId;
	}
}