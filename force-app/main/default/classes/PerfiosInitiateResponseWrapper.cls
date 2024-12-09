public class PerfiosInitiateResponseWrapper {

    public PerfiosTransaction perfiosTransaction;
	public class PerfiosTransaction {
		public String perfiosTransactionId;	//CBRZ1697718264591
	}
    
    public Error error;
	public class Error {
		public String code;	//BadParameter
		public String message;	//Signature is required but missing
	}
	public static PerfiosInitiateResponseWrapper parse(String json){
		return (PerfiosInitiateResponseWrapper) System.JSON.deserialize(json, PerfiosInitiateResponseWrapper.class);
	}
}