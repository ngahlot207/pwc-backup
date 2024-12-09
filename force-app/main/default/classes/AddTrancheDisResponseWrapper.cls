public class AddTrancheDisResponseWrapper {
	public DisbursalDetail disbursalDetail;
	public String unqRequestId;
	public String errorcode;
	public String errorDescription;
    
	public class DisbursalDetail {
		public String applicationID;
		public String errorcode;
		public String errorDescription;
	}
    
     public static AddTrancheDisResponseWrapper parse(String json){ 
        return (AddTrancheDisResponseWrapper) System.JSON.deserialize(json, AddTrancheDisResponseWrapper.class);
    }

}