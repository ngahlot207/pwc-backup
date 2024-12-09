public class AddMatchingResponseWrapper {

    public class ClientData {
		public String caseId;
	}

	public class Address1 {
		public String building;
		public Integer pin;
		public String district;
		public String floor;
		public String house;
		public String locality;
		public String state;
		public String complex;
		public String untagged;
		public String careOf;
		public String street;
	}

	public String requestId;
	public Result result;
	public Integer statusCode;
	public ClientData clientData;

	public class Result {
		public Double score;
		public Boolean match;
		public Address1 address1;
		public Address1 address2;
	}

	
	public static AddMatchingResponseWrapper parse(String json) {
		return (AddMatchingResponseWrapper) System.JSON.deserialize(json, AddMatchingResponseWrapper.class);
	}
}