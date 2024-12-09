public class PerfiosInitiateRequestWrapper {
    
    public Payload payload;
	public class Payload {
		public String loanAmount;	//100000
		public String loanDuration;	//24
		public String loanType;	//Home
		public String processingType;	//STATEMENT
		public String transactionCompleteCallbackUrl;	//https://example.com/callback
		public String txnId;	//fedfina_uniqueTxnId
		public String acceptancePolicy;	//atLeastOneTransactionInRange
		public String employmentType;	//Salaried
		public String institutionId; //22
        public String uploadingScannedStatements;	//false
		public String yearMonthFrom;	//2023-01
		public String yearMonthTo;	//2023-08
        
        public List<EmployerNames> employerNames;
		public String facility;	// OD,CC, NONE
		public String sanctionLimitFixed;	//true
		public String sanctionLimitFixedAmount;	//5000
		public List<VariableAmounts> sanctionLimitVariableAmounts;
		public List<VariableAmounts> drawingPowerVariableAmounts;
		public List<CompanyNames> companyNames;
		public List<SisterCompanyNames> sisterCompanyNames;
	
	}
    
    public class EmployerNames {
		public NamePattern namePattern;
	}
	public class NamePattern {
		public String pattern;	//fedfina
	}
	public class VariableAmounts {
		public VariableAmount variableAmount;
	}
	public class VariableAmount {
		public String amount;	//2000
	}
	public class CompanyNames {
		public NamePattern namePattern;
	}
	public class SisterCompanyNames {
		public NamePattern namePattern;
	}
    
	public static PerfiosInitiateRequestWrapper parse(String json){
		return (PerfiosInitiateRequestWrapper) System.JSON.deserialize(json, PerfiosInitiateRequestWrapper.class);
	}

}