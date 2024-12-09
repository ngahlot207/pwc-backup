public class IntOCRPassportResponseWrapper {

    public class Details {
		public PassportNum passportNum;
		public PassportNum givenName;
		public PassportNum surname;
		public PassportNum gender;
		public PassportNum dob;
		public PassportNum placeOfBirth;
		public PassportNum countryCode;
		public PassportNum nationality;
		public PassportNum placeOfIssue;
		public PassportNum doi;
		public PassportNum doe;
		public PassportNum type;
		public Mrz mrz;
        
        public PassportNum father;
        public PassportNum mother;
        public PassportNum spouse;
        public PassportNum address;
        public PassportNum pin;
        public PassportNum oldPassportNum;
        public PassportNum oldDoi;
        public PassportNum fileNum;
        public AddressSplit addressSplit;
        
        
	}

	public Integer statusCode;
	public String requestId;
	public List<Result> result;

	public class PassportNum {
		public String value;
		public String conf;
	}

	public class Mrz {
		public String line2;
		public String line1;
		public String conf;
	}

	public class Result {
		public String type;
		public Details details;
	}
    
    
    public class AddressSplit{
        public String city;
        public String district;
        public String pin;
        public String locality;
        public String line2;
        public String line1;
        public String state;
        public String street;
        public String landmark;
        public String houseNumber;
    }
    
	public static IntOCRPassportResponseWrapper parse(String json) {
        return (IntOCRPassportResponseWrapper) System.JSON.deserialize(json, IntOCRPassportResponseWrapper.class );
    }
}