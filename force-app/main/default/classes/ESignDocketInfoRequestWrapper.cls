public class ESignDocketInfoRequestWrapper {
	
    public String docket_id;	//xxxx
	public String document_id;	//xxxx
	public static ESignDocketInfoRequestWrapper parse(String json){
		return (ESignDocketInfoRequestWrapper) System.JSON.deserialize(json, ESignDocketInfoRequestWrapper.class);
	}
}