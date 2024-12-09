public class ENPARequestWrapper {
	public String UCIC;	//12784057
	public static ENPARequestWrapper parse(String json){
		return (ENPARequestWrapper) System.JSON.deserialize(json, ENPARequestWrapper.class);
	}
}