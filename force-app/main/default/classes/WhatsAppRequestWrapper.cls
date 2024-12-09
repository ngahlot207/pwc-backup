public class WhatsAppRequestWrapper {

    public String userName;	//equence_test
	public String password;	//******
	public String channelId;	//WAP
	public WhatsAppEntity whatsAppEntity;
	public class WhatsAppEntity {
		public String whatsAppSourceAddress;	//9199xxxxxxxxx
		public String whatsAppDestinationAddress;	//919876xxxxxx
		public String templateId;	//01hheffw01j78wfyiy60bykxc3
		public List<String> variables;
		public MediaAttachment mediaAttachment;
		public List<String> payload;
		public String category;	//Marketing
	}
	public class MediaAttachment {
		public String type;	//IMAGE
		public String url;	//https://abc.com/someurl.jpeg
		public String fileName;	//anydocument_Name.pdf
		public String id;	//1122334455667788
	}
	
    
}