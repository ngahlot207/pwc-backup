public class CompositePaymentResponseWrapper {
	
    public String ActCode;
	public String Response;
	public String BankRRN;
	public String BeneName;
	public String success;
	public String TransRefNo;
    public String errorCode;
    public String description;

	
	public static CompositePaymentResponseWrapper parse(String json) {
		return (CompositePaymentResponseWrapper) System.JSON.deserialize(json, CompositePaymentResponseWrapper.class);
	}
}