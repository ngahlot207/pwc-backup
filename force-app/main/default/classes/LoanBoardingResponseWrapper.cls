public class LoanBoardingResponseWrapper {
	public String applicationID;
	public String unqRequestId;
	public String errorcode;
	public String errorDescription;

	
	public static LoanBoardingResponseWrapper parse(String json) {
		return (LoanBoardingResponseWrapper) System.JSON.deserialize(json, LoanBoardingResponseWrapper.class);
	}
}