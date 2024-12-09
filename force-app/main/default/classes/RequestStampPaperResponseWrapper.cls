public class RequestStampPaperResponseWrapper {
	public String status;	//success
	public String content;	//Stamped Pdf Content in Base64
	public String transaction_id;	//xxxx
	public String reference_id;	//xxxx
	public String error;	//NA
	public String error_code;	//NA
	public String stamp_paper_number;	//xxxx
	public String qr_code_details;	//xxxx
	public String order_id;	//xxxx
	public String stamp_duty_amount;	//xxxx
	public String requested_amount;	//xxxx
	public String consumed_at;	//xxxx
	public String message;	//xxxx
	public static RequestStampPaperResponseWrapper parse(String json){
		return (RequestStampPaperResponseWrapper) System.JSON.deserialize(json, RequestStampPaperResponseWrapper.class);
	}

}