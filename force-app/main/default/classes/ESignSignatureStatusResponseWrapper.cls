public class ESignSignatureStatusResponseWrapper {
    
    public String status;	//success
	public List<SignerInfo> signer_info;
	public String error;	//xxxx
	public String error_code;	//xxxx
	public class SignerInfo {
		public String signer_id;	//xxxx
		public String signature_sequence;	//xxxx
		public String status;	//xxxx
	}
	public static ESignSignatureStatusResponseWrapper parse(String json){
		return (ESignSignatureStatusResponseWrapper) System.JSON.deserialize(json, ESignSignatureStatusResponseWrapper.class);
	}

}