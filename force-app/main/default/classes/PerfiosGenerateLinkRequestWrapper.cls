public class PerfiosGenerateLinkRequestWrapper {
	public Payload payload;
	public class Payload {
		public String loanAmount;
		public String loanDuration;
		public String loanType;
		public String processingType;
		public String transactionCompleteCallbackUrl;
		public String txnId;
		public String acceptancePolicy;
		public String employmentType;
		public String institutionId;
        //public String uploadingScannedStatements;
		public String yearMonthFrom;
		public String yearMonthTo;
        //public String currencyValue;
        public String employerName;
        public String form26ASDOB; //YYYY-MM-DD
        public String idleUserCallbackTimeoutSeconds;
        public List<String> incomeTaxDocuments;
        public String maxVintageDays;
        public String productType;
        public String requireIdleUserCallback;
        public String returnUrl;
        public String sourceSystem;
        
        //public List<EmployerNames> employerNames;
		public String facility;
		public String sanctionLimitFixed;       
        public String sanctionLimitFixedAmount;
        //public String drawingPowerFixedAmount;
		public List<VariableAmounts> sanctionLimitVariableAmounts;
		public List<VariableAmounts> drawingPowerVariableAmounts;
		public List<CompanyNames> companyNames;
		public List<SisterCompanyNames> sisterCompanyNames;
        //public DataSources dataSources;
	
	}
    
    public class EmployerNames {
		public NamePattern namePattern;
	}
	public class NamePattern {
		public String pattern;
	}
	public class VariableAmounts {
		public VariableAmount variableAmount;
	}
	public class VariableAmount {
		public String amount;
	}
	public class CompanyNames {
		public NamePattern namePattern;
	}
	public class SisterCompanyNames {
		public NamePattern namePattern;
	}
    
    public class DataSources {
		public List<String> dataSource;
	}
    
	public static PerfiosGenerateLinkRequestWrapper parse(String json){
		return (PerfiosGenerateLinkRequestWrapper) System.JSON.deserialize(json, PerfiosGenerateLinkRequestWrapper.class);
	}
}