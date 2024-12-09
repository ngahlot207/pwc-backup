public class BillDeskRequestWrapper {
	
    public String mercid;	//BDUATV2K06
	public String orderid;	//orderNewTest4
	public String amount;	//100.00
	public String order_date;	//2024-09-05T3:55:00+05:30
	public String currencyCode;	//356
	public String ru;	//https://fedbank--dev.sandbox.my.salesforce-sites.com/BilldeskRedirectPage
	public AdditionalInfo additional_info;
	public String itemcode;	//DIRECT
	public Device device;
	public class AdditionalInfo {
		public String additional_info1;	//NA
		public String additional_info2;	//NA
	}
	public class Device {
		public String init_channel;	//internet
		public String ip;	//187.118.227.185
		public String user_agent;	//Mozilla/5.0(WindowsNT10.0;WOW64;rv:51.0)Gecko/20100101Firefox/51.0
		public String accept_header;	//text/html
		public String browser_tz;	//-330
		public String browser_color_depth;	//32
		public String browser_java_enabled;	//false
		public String browser_screen_height;	//601
		public String browser_screen_width;	//657
		public String browser_language;	//en-US
		public String browser_javascript_enabled;	//true
	}
}