public class PaytmResponseWrapper {
	
    public Head head;
	public Body body;
	
    public class Head {
		public String version;
		public String timestamp;	//1566994462639
		public String channelId;
		public String tokenType;	//AES
		public String clientId;
	}
	
	public class Body {
		public String linkId;	//5861
		public String linkType;	//FIXED
		public String longUrl;	//https://securegw-stage.paytm.in/link/PAYMENTLINKNAME/LL_5861
		public String shortUrl;	//https://paytm.me/ID-PBo7
		public String expiryDate;	//27/08/2020 17:44:22
		public boolean isActive;
		public String merchantHtml;	//
		public String createdDate;	//28/08/2019 17:44:22
		public List<NotificationDetails> notificationDetails;
		public ResultInfo resultInfo;
        public String linkOrderId;
	}
	
    public class NotificationDetails {
        public String customerName;
        public String contact;
        public String notifyStatus;
        public String timestamp;
	}
	
    public class ResultInfo {
		public String resultStatus;	//SUCCESS
		public String resultCode;	//200
		public String resultMessage;	//Payment link is created successfully
	}
	
    public static PaytmResponsewrapper parse(String json){
		return (PaytmResponsewrapper) System.JSON.deserialize(json, PaytmResponsewrapper.class);
	}
}