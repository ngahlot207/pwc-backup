public class PennyDropResponseWrappper {
	
    public String requestId;	//uwhpcUUx0ixaJpBhxGnsjy
	public String status;	//SUCCESS
	public String applicationId;	//586371
	public String chequeId;	//691627
	public String errorcode;	//0000
    public String errorDescription; //
	
    public static PennyDropResponseWrappper parse(String json){
		return (PennyDropResponseWrappper) System.JSON.deserialize(json, PennyDropResponseWrappper.class);
	}
    
}