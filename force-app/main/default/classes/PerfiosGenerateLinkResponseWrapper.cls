public class PerfiosGenerateLinkResponseWrapper {

    
    public TransactionLink transactionLink;
	public class TransactionLink {
		public String expires;	//2024-08-02 14:33 Asia/Kolkata
		public String perfiosTransactionId;
		public String url;
	}
    
    
    public Error error;
	public class Error {
		public String code;	//BadParameter
		public String message;	//Request did not validate
		public List<Details> details;
	}
	public class Details {
		public String code;	//ILLEGAL_FIELD_VALUE
		public String field;	//maxVintageDays
		public String message;	//must be null
		public String value;
	}
	public static PerfiosGenerateLinkResponseWrapper parse(String json){
		return (PerfiosGenerateLinkResponseWrapper) System.JSON.deserialize(json, PerfiosGenerateLinkResponseWrapper.class);
	}
}