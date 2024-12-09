public class ArchitectAuthenticationResponseWrapper {

    public String requestId;	//50624c63-ea43-48a0-8bab-208602fcebc1
	public Result result;
	public Integer statusCode;	//101
	public ClientData clientData;
	public class Result {
		public String name;	//Mr. Kumar 
		public String registrationNumber;	//CA/1975/00022
		public String validUpto;	//2017-12-31
		public String qualification;	//G.D.Arch.
		public String address;	//C-3, KRISHNA NAGAR-I, TONK ROAD, LAL KOTHI,, Jaipur , RAJASTHAN -  123456
		public String mobileNumber;	//9921912347
		public String emailId;	//abcd@rediffmail.com
		public String disciplinaryAction;	//No
		public Integer pin;	//123456
		public String state;	//RAJASTHAN
		public String district;	//JAIPUR
		public String city;	//KRISHNA NAGAR
		public String location;	//C - 3TONK ROAD1 , LAL KOTHI
	}
	public class ClientData {
		public String caseId;	//123456
	}
    
    public  Integer status; //400,
    public String error; //Bad Request
    
	public static ArchitectAuthenticationResponseWrapper parse(String json){
		return (ArchitectAuthenticationResponseWrapper) System.JSON.deserialize(json, ArchitectAuthenticationResponseWrapper.class);
	}
}