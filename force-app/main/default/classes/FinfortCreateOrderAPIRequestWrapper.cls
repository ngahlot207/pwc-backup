public class FinfortCreateOrderAPIRequestWrapper {
    
    public string request;
    public Param param;
    
    public class Param{
        
        public LenderInfo lenderInfo;
        public RequestorInfo requestorInfo;
        public BorrowerInfo borrowerInfo;
        public DataRelatedInfo dataRelatedInfo;
        public OrderInfo orderInfo;
        public OtherInfo otherInfo;
        //public List<WebhookUrls> webhook_urls;
        
    }
    
    public class LenderInfo{
         public string lender_referenceNumber;
         public string lender_source;
         public string lender_name;
    }
    
    public class RequestorInfo{
        public string requestor_division;
        public string requestor_branch;
        public string requestor_name;
        public string requestor_email;
        public string requestor_phone;
    }
    
    public class BorrowerInfo{
        public string borrower_name;
        public string borrower_DOIB;
        public string borrower_pan;
        public string borrower_email;
        public string borrower_phone;
        public string borrower_language;
        public string borrower_state;
        public string borrower_country;
        public string borrower_street;
        public string borrower_city;
        public string borrower_pincode;
       // public string borrower_additional_email;
        //public string borrower_additional_mobile;
       // public string borrower_additional_info;
        public string borrower_cinLlpin;
    }
    
    public class DataRelatedInfo{
        public List<String> itrInfo;
        public List<String> gstInfo;
    }
    
    public class OrderInfo{
        public string product_name;
        public string assistanceBy;
    }
    
    public class OtherInfo{
        public boolean send_consent_borrower;
        //public string redirect_url_success;
        //public string redirect_url_fail;
        //public string client_ref_details;
    }
    
   /* public class WebhookUrls{
        public string webhook_url;
        public string key_name;
        public string key_value;
    }*/

}