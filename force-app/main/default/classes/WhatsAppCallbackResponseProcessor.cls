public class WhatsAppCallbackResponseProcessor {

    
    public class WhatsAppCallbackResponseWrapper{
        public Notify Notify;
    }
    
    public class Notify {
		public Integer id;	//121180984415574
		public String msgStream;	//OUTBOUND
		public String msgType;	//TEMPLATE_MESSAGE
		public String sessionId;	//0
		public Values Values;
		public Status Status;
		public Message Message;
		public Map<String,String> CustomData;
	}
	public class Values {
		public String display_phone_number;	//911234567890
		public String phone_number;	//9186xxxxxxxx
	}
	public class Status {
		public String id;	//1234567891234567890
		public String type;	//Marketing
		public String status;	//DELIVERED
		public Errors errors;
		public Integer recipient_id;	//0
		public Integer timestamp;	//1721733362556
	}
	public class Errors {
		public Integer code;	//0
		public String title;	//Message Delivered
		public String details;	//Message Delivered
	}
	public class Message {
		public String type;	// video
		public MessageData text;
		public Integer timestamp;	//1721733362556
	}
	public class MessageData {
		public String caption;	//sunrise
		public String mime_type;	//video/mp4
		public String filename;	//
		public Integer id;	//1274862173480271
	}
	
    public static WhatsAppCallbackResponseWrapper parse(String json){
		return (WhatsAppCallbackResponseWrapper) System.JSON.deserialize(json, WhatsAppCallbackResponseWrapper.class);
	}
}