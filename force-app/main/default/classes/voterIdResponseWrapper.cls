public class voterIdResponseWrapper {

   public String requestId;
	public Result result;
	public Integer statusCode;
	public ClientData clientData;

	public class Result {
		public String name;
		public String rlnName;
		public String rlnType;
		public String gender;
		public String district;
		public String acName;
		public String pcName;
		public String state;
		public String epicNo;
		public String dob;
		public String age;
		public String partNo;
		public String slNoInPart;
		public String psName;
		public String partName;
		public String lastUpdate;
		public String psLatLong;
		public String rlnNameV1;
		public String rlnNameV2;
		public String rlnNameV3;
		public String sectionNo;
		public String id;
		public String nameV1;
		public String nameV2;
		public String nameV3;
		public String acNo;
		public String stCode;
		public String houseNo;
		public String pin;
	}

	public class ClientData {
		public String caseId;
	}
    
    public static voterIdResponseWrapper parse(String json) {
        return (voterIdResponseWrapper) System.JSON.deserialize(json, voterIdResponseWrapper.class );
    }
}