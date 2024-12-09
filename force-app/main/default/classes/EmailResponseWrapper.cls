public class EmailResponseWrapper {

    public Result result;
	public String request_id;	//656d2f52-6722-416c-9085-ae6f4d757934
	public String statuscode;	//101
	public ClientData clientData;
	public class Result {
		public Meta meta;
		public Data data;
	}
	public class Meta {
		public Params params;
	}
	public class Params {
		public String email;	//khaja.m@karza.in
	}
	public class Data {
		public boolean disposable;
		public boolean webmail;
		public String result;	//valid
		public boolean acceptAll;
		public boolean smtpCheck;
		public boolean regexp;
		public boolean mxRecords;
		public String email;	//khaja.m@karza.in
		public boolean smtpServer;
		public boolean isBlocked;
		public String reason;	//user_exist
	}
	public class ClientData {
		public String caseId;	//123456
	}
    
    public  Integer status; //400,
    public String error; //Bad Request
    
	public static EmailResponseWrapper parse(String json){
		return (EmailResponseWrapper) System.JSON.deserialize(json, EmailResponseWrapper.class);
	}

}