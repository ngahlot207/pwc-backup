public class CrifAuthLoginRequestWrapper {
	public String userId;	//JWTUSER
	public String password;	//Admin@123
	public String domain;	//FEDFINA
	public String mode;	//STRATEGYONE
	public static CrifAuthLoginRequestWrapper parse(String json){
		return (CrifAuthLoginRequestWrapper) System.JSON.deserialize(json, CrifAuthLoginRequestWrapper.class);
	}
}