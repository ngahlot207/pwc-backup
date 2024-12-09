public class ShopAndEstablishmentCheckRequestWrapper {
	public String regNo;
	public Boolean pdfRequired;
	public String areaCode;
	public String consent;
	public ClientDataClass clientData;
	
	public class ClientDataClass {
		public String caseId;
	}
}