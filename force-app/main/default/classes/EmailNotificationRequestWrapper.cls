public class EmailNotificationRequestWrapper {

    public String alertType; 		//EMAIL
    public String parentType; 		//SFDC
    public Integer isAttachment; 	//1
    public String parentID; 		//L0012345
    public Integer priority; 		//1
    public Message message;
    public String saveToSentItems; 	//true
    public class message{
        public String subject; 		//43514-CIBIL Related
        public Body body;
        public List<Recipient> toRecipients;
        public List<Recipient> ccRecipients;
        public List<Recipient> bccRecipients;
        public List<Attachment> attachments;
    }
    public class body{
        public String contentType; 	//html
    	public String content; 		//<p>new mail<br></p>
    }
    public class Recipient{
        public EmailAddress emailAddress;
    }
    public class EmailAddress{
        public String address; 		//20447@fedfina.com
    }
    public class Attachment{
        public String name; 		//New Text Document.txt
        public String contentType;	//text/plain
        public String contentBytes;
    }
    
    public static EmailNotificationRequestWrapper parse(String json){
        return (EmailNotificationRequestWrapper) System.JSON.deserialize(json, EmailNotificationRequestWrapper.class);
    }  
}