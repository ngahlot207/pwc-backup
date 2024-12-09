public class EnachCreateMandateResponseWrapper {
	public String id;
	public String mandate_id;
	public String state;
	public String type;
	public Bank_Details bank_details;
	public String created_at;
	public String mode;
	public Service_Provider_Details service_provider_details;
    public String details;
	public String code;
	public String message;
	
	public class Bank_Details {
		public String shared_with_bank;
		public String bank_name;
		public String state;
	}
	
	public class Service_Provider_Details {
		public String service_provider_name;
		public String service_provider_utility_code;
	}
    
     public static EnachCreateMandateResponseWrapper parse(String json){
        return (EnachCreateMandateResponseWrapper) System.JSON.deserialize(json, EnachCreateMandateResponseWrapper.class);
    }
}