public class PaytmTransactionStatusRequestWrapper {

    public Body body;
	public Head head;
	public class Body {
		public String mid;	//mid
		public String orderId;	//order-id
	}
	public class Head {
		public String signature;	//{signature}
	}
	
}