public class PerfiosGenerateReportResponseWrapper {
    public Success success;
    
    public class Success {
    }
    
    
    public Error error;
	public class Error {
		public String code;	//BadParameter
		public String message;	//Signature is required but missing
	}
    public static PerfiosGenerateReportResponseWrapper parse(String json){
		return (PerfiosGenerateReportResponseWrapper) System.JSON.deserialize(json, PerfiosGenerateReportResponseWrapper.class);
	}
}