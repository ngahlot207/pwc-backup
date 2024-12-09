public class CrifAuthLoginResponseWrapper {
	public String access_token;	//eyJhbGciOiJIUzM4NCJ9.eyJpc3MiOiJDUklGIiwic3ViIjoiSldUVVNFUiIsImlhdCI6MTY5NjQwNjM4MSwiZXhwIjoxNjk2NDM1MTgxLCJpZCI6MTg4LCJyb2xlIjoiUk9MRV9BUFBMSUNBVElPTiIsInBvd2VyTWFuYWdlciI6ZmFsc2UsImNsaWVudFZlcnNpb24iOiI3LjEuMjguMjMwNyIsImFjdGl2ZVNlc3Npb25JZCI6NDY0fQ.q_d_7wBwN161VsUnIvU8X-yVuwvRajGN7lG0V3O4Ddv-je9TqGlkr5yjZPhMYwpe
	public String token_type;	//Bearer
	public Integer expires_in;	//28800
    public String timestamp;	//2023-10-04T10:01:59.403+02:00
	public Integer status;	//401
	public String error;	//Unauthorized
	//public String exception;	//
	public String message;	//No message available
	public String path;	///api/auth/login
	public String reason;	//LOGIN
	public String code;	//INVALID_CREDENTIALS
    
	public static CrifAuthLoginResponseWrapper parse(String json){
		return (CrifAuthLoginResponseWrapper) System.JSON.deserialize(json, CrifAuthLoginResponseWrapper.class);
	}
}