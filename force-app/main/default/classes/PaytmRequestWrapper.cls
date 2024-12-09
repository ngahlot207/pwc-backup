public class PaytmRequestWrapper {
    
    public Head head;
    public Body body;
    
    public class Head {
        public String tokenType;	//AES
        public String signature;	//{signature}
    }
    
    public class Body {
        public String mid;	//{mid}
        public String linkType;	//FIXED
        public String linkDescription;	//Test Payment
        public String linkName;	//Test
        public String linkOrderId;
        public boolean singleTransactionOnly;
        public Double amount;	//1.01
        public String maxPaymentsAllowed;
        public String expiryDate;
    }
    
    public static PaytmRequestwrapper parse(String json){
        return (PaytmRequestwrapper) System.JSON.deserialize(json, PaytmRequestwrapper.class);
    }
}