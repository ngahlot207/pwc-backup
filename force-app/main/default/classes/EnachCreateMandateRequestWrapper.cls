public class EnachCreateMandateRequestWrapper {
    public String customer_identifier;
    public String auth_mode;
    public String mandate_type;
    public String corporate_config_id;
    public Boolean notify_customer;
    public Mandate_Data mandate_data;
    public String expire_in_days;
    
    public class Mandate_Data {
        public String maximum_amount;
        public String instrument_type;
        public String first_collection_date;
        public Boolean is_recurring;
        public String frequency;
        public String management_category;
        public String customer_name;
        public String customer_account_number;
        public String destination_bank_id;
        public String destination_bank_name;
        public String customer_account_type;
        //public String customer_ref_number;
        //public String scheme_ref_number;
    }
    
    public static EnachCreateMandateRequestWrapper parse(String json){
        return (EnachCreateMandateRequestWrapper) System.JSON.deserialize(json, EnachCreateMandateRequestWrapper.class);
    }
}