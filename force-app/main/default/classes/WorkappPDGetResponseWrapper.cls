public class WorkappPDGetResponseWrapper {
    
	public class Agent {
		public String username {get;set;} 
		public String name {get;set;}
	}
	
	public String firstName {get;set;} 
	public Long mobileNumber {get;set;} 
	public String email {get;set;} 
	public List<Data> data {get;set;} 
	public Agent agent {get;set;} 
	public Integer id {get;set;} 
	public String scpUrl {get;set;} 
	public List<VideoCalls> videoCalls {get;set;} 
	public List<Documents> documents {get;set;}

	public Integer code {get;set;}
	public String message {get;set;}
	
	public class Documents {
		public Integer id {get;set;} 
		public String url {get;set;} 
		public String fileName {get;set;} 
		public String fileSize {get;set;} 
		public String createdDate {get;set;} 
		public String documentType {get;set;} 
		public Double similarityWithUserPhoto {get;set;} 
		
	}
	
	public class Data {
		public String key {get;set;} 
		public String value {get;set;} 

		
	}
	
	public class VideoCalls {
		public String time_Z {get;set;} // in json: time
		public String customerVideoRecording {get;set;} 
		public String agentVideoRecording {get;set;} 
		public String duration {get;set;} 
		public String fileSize {get;set;} 
		public String meetingId {get;set;} 
		
	}
	

}