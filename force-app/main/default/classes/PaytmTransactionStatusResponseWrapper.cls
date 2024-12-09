public class PaytmTransactionStatusResponseWrapper {

    public Head head;
	public Body body;
	public class Head {
		public String responseTimestamp;	//1553496322922
		public String version;	//v1
		public String clientId;	//C11
		public String signature;	//xxxxx
	}
	public class Body {
		public ResultInfo resultInfo;
		public String txnId;	//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		public String bankTxnId;	//xxxxxxxxxxxxxxx
		public String orderId;	//xxxxxxx
		public String txnAmount;	//100.00
		public String txnType;	//SALE
		public String gatewayName;	//HDFC
		public String bankName;	//HSBC
		public String mid;	//xxxxxxxxxxxxxxxxxxxx
		public String paymentMode;	//CC
		public String refundAmt;	//100.00
		public String txnDate;	//2019-02-20 12:35:20.0
		public String authRefId;	//50112883
	}
	public class ResultInfo {
		public String resultStatus;	//TXN_SUCCESS
		public String resultCode;	//01
		public String resultMsg;	//Txn Success
	}
}