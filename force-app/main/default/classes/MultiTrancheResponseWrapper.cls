public class MultiTrancheResponseWrapper {
    public List<Data> Data;
    public String status;
    public String message;
    
    public class Tranches {
        public String TranchID;
        public String Amount;
        public String TranchDate;
        public String Message;
        public String CancelledDisbursals;
        public String DisbursalStatus;
        public String TotalDisbursalAmount;
        public String ExcessAmount;
        public String LoanTenure;
    }
    
    public class Data {
        public String CurrentPOS;
        public String CurrentOverdue;
        public String PendingEMIs;
        public String DPD;
        public List<Tranches> Tranches;
    }
    
    public static MultiTrancheResponseWrapper parse(String json){
        return (MultiTrancheResponseWrapper) System.JSON.deserialize(json, MultiTrancheResponseWrapper.class);
    }
}