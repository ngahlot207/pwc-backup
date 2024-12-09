public class WorkappPDPostRequestWrapper { 

	public Integer entityId;	 
	public Integer productType;	 
	public String firstName;	  
	public String mobileNumber;	  
	public String countryCode;	 
	public String email;	
	public String statusUrl;	 
	public Integer useCase;	 
	public List<Data> data;
	public String userPhoto;	 
	public String employeeId;
	
	public class Data {
		public String key;
		public String value;
	}
    
}