public class PanProfDetResponseWrapper {
    
    public Integer statuscode;	//101
	public String request_id;	//73cdbde2-80f7-11e7-8f0c-e7e769f70bd1
	public cls_result result;
	public cls_clientData clientData;
	public class cls_result {
		public String name;	//OMKAR MILIND SHIRHATTI
	}
	public class cls_clientData {
		public String caseId;	//123456
	}
	public static PanProfDetResponseWrapper parse(String json){
		return (PanProfDetResponseWrapper) System.JSON.deserialize(json, PanProfDetResponseWrapper.class);
	}

   /* //Wrapper class for PAN Profile (Detailed)
            
   public String requestId;
	public Result result;
	public Integer statusCode;

	public class Address {
		public String buildingName;
		public String locality;
		public String streetName;
		public String pinCode;
		public String city;
		public String state;
		public String country;
	}

	public class ProfileMatch {
		public String parameter;
		public Double matchScore;
		public Boolean matchResult;
	}

	public class AuthorizedSignatory {
		public String pan;
		public String name;
		public String firstName;
		public String middleName;
		public String lastName;
		public String gender;
		public Object aadhaarLinked;
		public String dob;
		public String mobileNo;
		public String emailId;
		public Address address;
	}

	public class Result {
		public String pan;
		public String name;
		public String firstName;
		public String middleName;
		public String lastName;
		public String gender;
		public Boolean aadhaarLinked;
		public Boolean aadhaarMatch;
		public String dob;
		public Address address;
		public Object mobileNo;
		public Object emailId;
		public List<ProfileMatch> profileMatch;
		public AuthorizedSignatory authorizedSignatory;
		public String status;
		public String issueDate;
		public Boolean isSalaried;
		public Boolean isDirector;
		public Boolean isSoleProp;
	}
     public static PanProfDetResponseWrapper parse(String json) {
        return (PanProfDetResponseWrapper) System.JSON.deserialize(json, PanProfDetResponseWrapper.class );
    }*/

}