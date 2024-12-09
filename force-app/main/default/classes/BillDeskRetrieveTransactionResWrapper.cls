public class BillDeskRetrieveTransactionResWrapper {
    
    public AdditionalInfo additional_info;
	public String amount;	//2.00
	public String auth_status;	//0300
	public String bank_ref_no;	//327166758420
	public String bankid;	//789
	public String charge_amount;	//2.00
	public String currencyCode;	//356
	public String discount;	//0.00
	public String itemcode;	//DIRECT
	public String mercid;	//BDMERCID
	public String objectid;	//transaction
	public String orderid;	//ORDERID280920230002
	public String payment_category;	//10
	public String payment_method_type;	//upi
	public String ru;	//https://www.merchanturl.com/response.jsp
	public String surcharge;	//0.00
	public String transaction_date;	//2023-09-28T12:35:58+05:30
	public String transaction_error_code;	//TRS0000
	public String transaction_error_desc;	//Transaction Successful
	public String transaction_error_type;	//success
	public String transactionid;	//Z7891420832874
	public String txn_process_type;	//qr
    
    public Integer status;	//500
	public String error_type;	//api_processing_error
	public String error_code;	//GNAPE0001
	public String message;	//Internal server error
	public class AdditionalInfo {
		public String additional_info1;	//Details1
		public String additional_info2;	//Details2
	}
    
    
    public static BillDeskRetrieveTransactionResWrapper parse(String json){
		return (BillDeskRetrieveTransactionResWrapper) System.JSON.deserialize(json, BillDeskRetrieveTransactionResWrapper.class);
	}

}