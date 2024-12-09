public class FinfortDeliveryReportResponseWrapper {
    
    public String lender_name;
    public String lender_referenceNumber;
    public String ffOrderId;
    public String borrower_pan;
    public String fileName;
    public String totalFileCount;
    public String currentFileCount;
    public String fileData;
    
    
    public class CallbackWrapper{
        
        public Integer code;
        public String lender_name;
        public String lender_referenceNumber;
        public String ffOrderId;
        public String borrower_pan;
        public String fileTransferStatus;
        public String fileName;
        public String failureReason;
    }
    
}