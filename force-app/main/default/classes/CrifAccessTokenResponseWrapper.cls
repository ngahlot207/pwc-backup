public class CrifAccessTokenResponseWrapper {

    public String timestamp;	//2024-08-02T11:37:06.104+00:00
	public String errorCode;	//UNAUTHORIZED
	public String errorMsg;	//Invalid username or password.
	public String access_token;
	public String expires_in;	//1800
	public String token_type;	//Bearer
	public static CrifAccessTokenResponseWrapper parse(String json){
		return (CrifAccessTokenResponseWrapper) System.JSON.deserialize(json, CrifAccessTokenResponseWrapper.class);
	}
    
}