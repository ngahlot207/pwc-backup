public class ESignURLResponseWrapper {
    
    public String status;	//success
	public String esign_url;	//xxxx
	public String error;	//NA
	public String error_code;	//NA
	public static ESignURLResponseWrapper parse(String json){
		return (ESignURLResponseWrapper) System.JSON.deserialize(json, ESignURLResponseWrapper.class);
	}

}