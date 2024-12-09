public class ESignDocumentUploadResponseWrapper {
	
    public String status;	//xxxx
	public String message;	//xxxx
	public String docket_id;	//xxxx
	public List<SignerInfo> signer_info;
	public List<Custom> custom;
	public String api_response_id;	//xxxx
	public String response_time_stamp;	//xxxx
    public String error;	//xxxx
	public String error_code;	//xxxx
	public class SignerInfo {
		public String signer_ref_id;	//xxxx
		public String signer_id;	//xxxx
		public String document_id;	//xxxx
	}
	public class Custom {
		public String document_id;	//xxxxxxx
		public String parameter_name;	//xxxxxx
	}
	public static ESignDocumentUploadResponseWrapper parse(String json){
		return (ESignDocumentUploadResponseWrapper) System.JSON.deserialize(json, ESignDocumentUploadResponseWrapper.class);
	}
}