public class MultiTrancheRequestWrapper {

    public String LANNo;
    
    public static MultiTrancheRequestWrapper parse(String json) {
		return (MultiTrancheRequestWrapper) System.JSON.deserialize(json, MultiTrancheRequestWrapper.class);
	}
    
}