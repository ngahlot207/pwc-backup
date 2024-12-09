public class EnachStatusResponseWrapper {
		public List<String> entities;
		public Payload payload;
		public String created_at;
		public String id;
		public String event;
		
		public class Payload {
			public Api_Mandate api_mandate;
		}
		
		public class Api_Mandate {
			public String txn_timestamp;
			public String txn_reject_reason;
			public String umrn;
			public String auth_sub_mode;
			public String txn_reject_code;
			public String current_status;
			public String message_id;
			public String id;
			public String npci_txn_id;
			public Others others;
			public String tags;
		}
		
		public class Others {
			public String scheme_ref_number;
			public String customer_ref_number;
		}
    
     public static EnachStatusResponseWrapper parse(String json){
        return (EnachStatusResponseWrapper) System.JSON.deserialize(json, EnachStatusResponseWrapper.class);
    }
	}