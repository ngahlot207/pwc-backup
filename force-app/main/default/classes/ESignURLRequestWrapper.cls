public class ESignURLRequestWrapper {
    public String document_id;	//xxxx
	public String signer_id;	//xxxx
	public String return_url;	//xxxx
	public static ESignURLRequestWrapper parse(String json){
		return (ESignURLRequestWrapper) System.JSON.deserialize(json, ESignURLRequestWrapper.class);
	}

}