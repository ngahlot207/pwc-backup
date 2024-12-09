public class BillDeskResponseWrapper {

    public String objectid;	//order
    public String orderid;	//IM00000201521728633001943
    public String bdorderid;	//OASL19XUERO3ZM
    public String mercid;	//BDUATV2K06
    public String order_date;	//2024-10-11T13:20:01+05:30
    public String amount;	//2360
    public String currencyCode;	//356
    public String ru;	//https://fedbank--dev.sandbox.my.salesforce-sites.com/BilldeskRedirectPage
    public AdditionalInfo additional_info;
    public String itemcode;	//DIRECT
    public String createdon;	//2024-10-11T13:20:59+05:30
    public String next_step;	//redirect
    public List<Links> links;
    public String status;	
    public String error_type;	//duplicate_request_error
    public String error_code;	//GNDRE0001
    public String message;	//Duplicate request error
    public class AdditionalInfo {
        public String additional_info1;	//NA
        public String additional_info2;	//NA
        public String additional_info3;	//NA
        public String additional_info4;	//NA
        public String additional_info5;	//NA
        public String additional_info6;	//NA
        public String additional_info7;	//NA
        public String additional_info8;	//NA
        public String additional_info9;	//NA
        public String additional_info10;	//NA
    }
    public class Links {
        public String href;	//https://pguatweb.billdesk.io/pgtxnsimulator/v1_2/embeddedsdk
		public String rel;	//redirect
		public String method;	//POST
		public Parameters parameters;
		public String valid_date;	//2024-10-11T18:20:59+05:30
		public Headers headers;
    }
    public class Parameters {
        public String mercid;	//BDUATV2K06
		public String bdorderid;	//OASL19XUERO3ZM
		public String rdata;	//7dfa51b31c6666e7d6ef10f652de8f0c4cc79c2d08eda5c243183824f2a1350e1aa477545bce2a5cb15fe9c69bc1abc387cef55492feef0170ece0e0f20db3c25d.4145535f55415431
    } 
    public class Headers {
        public String authorization;	//OToken 286e55fc148202c460a88707b2685b3e9334d3f564a5ab0b0f5a9c90d8fa5585fe52e7bf50201cb5bebe639330a7e3058cf6abaa1696573cdd6589502d9c03387668a7a96614289ae8873f9b28dda84d35d6a9a8b52d82cae318ea5c0e879ab888c43434a521eebb9c4caf53c395bf744989d82e1babf48cb3481adb112a2d1e5cdd3fd1fcb96b34574123afa5863d88d2c804e6ae9a38eb082755.4145535f55415431
    }
	
    public static BillDeskResponseWrapper parse(String json){
		return (BillDeskResponseWrapper) System.JSON.deserialize(json, BillDeskResponseWrapper.class);
	}
}