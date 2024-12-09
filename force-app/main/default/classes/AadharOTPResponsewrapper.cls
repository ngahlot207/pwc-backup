public class AadharOTPResponsewrapper {
	public String status;	//success
	public String reference_id;	//xxxxxxxx
	public String transaction_id;	//xxxxxx
	public String message;	//xxxxxxxx
	public String response_time_stamp;	//YYYY-MM-DDTHH:MM:SS
	public Result result;
    public String error;
    public String error_code;
	
    public class Result {
		public ValidatedData validated_data;
	}
	public class ValidatedData {
		public String full_name;	//xxxx
		public String aadhaar_number;	//xxxx
		public String dob;	//YYYY-MM-DD
		public String gender;	//xxxx
		public Address address;
		public boolean face_status;
		public String face_score;	//xxxx
		public String zip;	//xxxxxx
		public String profile_image;	//base64 image data
		public boolean has_image;
		public String raw_xml;	//xxxx
		public String zip_data;	//xxxx
		public String care_of;	//xxxx
		public String share_code;	//xxxx
		public boolean mobile_verified;
		public String reference_id;	//xxxx
		public AadhaarPDF aadhaar_pdf;
	}
	public class Address {
		public String country;	//xxxx
		public String dist;	//xxxx
		public String state;	//xxxx
		public String po;	//xxxx
		public String loc;	//xxxx
		public String vtc;	//xxxx
		public String subdist;	//xxxx
		public String street;	//xxxx
		public String house;	//xxxx
		public String landmark;	//
	}
	public class AadhaarPDF {
	}
    
	public static AadharOTPResponsewrapper parse(String json){
		return (AadharOTPResponsewrapper) System.JSON.deserialize(json, AadharOTPResponsewrapper.class);
	}
}