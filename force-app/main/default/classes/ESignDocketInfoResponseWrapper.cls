public class ESignDocketInfoResponseWrapper {

    public String status;	//success
	public String error;	//NA
	public String error_code;	//NA
	public String message;	//docket_info
    public String docket_id;	//xxxx
	public String document_id;	//xxxx
	public List<DocketInfo> docket_Info;
	public class DocketInfo {
		public String content;	//<base-64-content>
		public String content_type;	//pdf
		public String document_id;	//xxxx
	}
	public static ESignDocketInfoResponseWrapper parse(String json){
		return (ESignDocketInfoResponseWrapper) System.JSON.deserialize(json, ESignDocketInfoResponseWrapper.class);
	}
}