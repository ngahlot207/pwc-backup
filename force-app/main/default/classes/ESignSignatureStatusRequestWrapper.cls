public class ESignSignatureStatusRequestWrapper {
    
    public String document_id;	//xxxx
	public static ESignSignatureStatusRequestWrapper parse(String json){
		return (ESignSignatureStatusRequestWrapper) System.JSON.deserialize(json, ESignSignatureStatusRequestWrapper.class);
	}

}