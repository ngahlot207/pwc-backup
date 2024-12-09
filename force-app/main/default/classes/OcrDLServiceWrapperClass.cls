public class OcrDLServiceWrapperClass {
    
	public class Details {
		public Dob dob;
		public Dob dlNo;
		public Dob name;
	}

	public Integer statusCode;
	public String requestId;
	public List<Result> result;

	public class Dob {
		public String conf;
		public String value;
	}

	public class Result {
		public String type;
		public Details details;
	}	
    
    public static OcrDLServiceWrapperClass parse(String json) {
        return (OcrDLServiceWrapperClass) System.JSON.deserialize(json, OcrDLServiceWrapperClass.class );
    }
}