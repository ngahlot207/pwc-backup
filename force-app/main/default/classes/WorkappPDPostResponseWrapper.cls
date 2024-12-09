public class WorkappPDPostResponseWrapper {

    public Integer entityId;
	public Integer productType;
	public String firstName;
	public Long mobileNumber;
	public String email;
	public Integer useCase;
	public List<Data> data;
	public Integer id;
	public String redirectionUrl;
	public String scpUrl;
	public boolean encrypted;
	public boolean guestInvitationRequired;
	public Integer groupId;
	public String redirectUrl;
	public String countryCode;
	public String domain;
	public String message;
	public Integer code;
	public String groupName;

	public class Data {
		public String key;
		public String value;
	}

	
	public static WorkappPDPostResponseWrapper parse(String json) {
		return (WorkappPDPostResponseWrapper) System.JSON.deserialize(json, WorkappPDPostResponseWrapper.class);
	}
    
}