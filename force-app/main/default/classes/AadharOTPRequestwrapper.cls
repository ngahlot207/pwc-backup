public class AadharOTPRequestwrapper {
    
    
	public String reference_id;	//xxxx
	public String transaction_id;	//xxxx
	public String otp;	//xxxxxx
	public static AadharOTPRequestwrapper parse(String json){
		return (AadharOTPRequestwrapper) System.JSON.deserialize(json, AadharOTPRequestwrapper.class);
	}


}