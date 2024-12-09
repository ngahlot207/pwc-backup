public class CompositePaymentRequestWrapper {
    
    public String localTxnDtTime;	//20230123152219
	public String beneAccNo;	//50100242035033
	public String beneIFSC;	//HDFC0001265
	public String amount;	//1
	public String tranRefNo;	//230123152149032
	public String paymentRef;	//230123152149032
	public String senderName;	//NARAYAN PUNDLIK GAWADE
	public String mobile;	//8369265704
	public String retailerCode;	//rcode
	public String passCode;	//cd5cd91514e343568613260edcbdba40
	public String bcID;	//IBCFED01286
	public String crpId;	//FEDBANKF30032017
	public String crpUsr;	//SOUGATAR
	public String aggrId;	//CUST0946
    
	public static CompositePaymentRequestWrapper parse(String json){
		return (CompositePaymentRequestWrapper) System.JSON.deserialize(json, CompositePaymentRequestWrapper.class);
	}

}