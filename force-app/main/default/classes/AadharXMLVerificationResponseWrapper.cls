public class AadharXMLVerificationResponseWrapper {

    public String status;	//success
	//public String message;	//xxxxxx xxxxxx
	public String reference_id;	//xxxxxxxxx
	public String transaction_id;	//xxxxxxxxxxxx
	public String response_time_stamp;	//YYYY-MM-DDTHH:mm:ss
    public String error;
    public String error_code;
	
    public static AadharXMLVerificationResponseWrapper parse(String json){
		return (AadharXMLVerificationResponseWrapper) System.JSON.deserialize(json, AadharXMLVerificationResponseWrapper.class);
	}
}