public class KarzaElectricityBillResponseWrapper {
	public String statusCode;
	public String request_id;
	public ResultClass result;
	public ClientDataClass clientData;
	
	public class ResultClass {
		public String address;
		public String amount_payable;
		public String bill_amount;
		public String bill_due_date;
		public String bill_no;
		public String consumer_name;
		public String consumer_number;
		public String email_address;
		public String mobile_number;
		public String total_amount;
		public String bill_date;
		public String bill_issue_date;
	}
	
	public class ClientDataClass {
		public String caseId;
	}
}