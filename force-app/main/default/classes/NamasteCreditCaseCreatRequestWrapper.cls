public class NamasteCreditCaseCreatRequestWrapper {

    public businessDetails Business_details;
    public loanDetails loan_details;
    
    
    public class businessDetails{
        public string business_name;
        public integer business_type;
    }
    
    public class loanDetails{
        public string loan_product_id;
        public string white_label_id;
        public string application_no;
    }
}