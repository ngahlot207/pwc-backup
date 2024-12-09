public class IntOCRVoterIdServiceResponseWrapper {

    	public class Details {
		public Name name;
		public Name dob;
		public Name doc;
		public Name age;
		public Name voterid;
		public Name relation;
		public Name gender;
        
        public Name address;
        public Name pin;
        public AddressSplit addressSplit;    
	}

	public Integer statusCode;
	public String requestId;
	public List<Result> result;

	public class Name {
		public String value;
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
    
	public static IntOCRVoterIdServiceResponseWrapper parse(String json) {
        return (IntOCRVoterIdServiceResponseWrapper) System.JSON.deserialize(json, IntOCRVoterIdServiceResponseWrapper.class );
    }
}