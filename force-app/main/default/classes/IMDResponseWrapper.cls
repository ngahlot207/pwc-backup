public class IMDResponseWrapper {
	
    public String requestId;	//uwhpcUUx0ixaJpBhxGnsjy
	public String status;	//SUCCESS
	public String applicationId;	//586371
	public String chequeId;	//691627
	public String errorcode;	//0000
    public String errorDescription; //
	
    public static IMDResponseWrapper parse(String json){
		return (IMDResponseWrapper) System.JSON.deserialize(json, IMDResponseWrapper.class);
	}
}