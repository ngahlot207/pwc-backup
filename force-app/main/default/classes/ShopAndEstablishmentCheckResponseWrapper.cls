public class ShopAndEstablishmentCheckResponseWrapper {
	public String requestId;
	public ResultClass result;
	public Integer statusCode;
    public Integer status;
    public string error;
	public ClientDataClass clientData;
	
	public class ResultClass {
		public String category;
		public String status;
		public String ownerName;
		public String entityName;
		public String registrationDate;
		public String validTo;
		public String contact;
		public String commenceDate;
		public String totalWorkers;
		public String fathersNameOfOccupier;
		public String natureOfBusiness;
		public String address;
		public String validFrom;
		public String email;
		public String websiteUrl;
		public String applicantName;
	}
	
	public class ClientDataClass {
		public String caseId;
	}
}