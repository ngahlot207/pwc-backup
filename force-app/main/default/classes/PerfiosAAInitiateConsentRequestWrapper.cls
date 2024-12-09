public class PerfiosAAInitiateConsentRequestWrapper {

    public String profileId;	//default_lending_profile
	public String userId;	//{{encoded_userId}}
	public List<String> fipIds;
	public String txnId;	//{{$guid}}
	public List<String> accType;
	public List<String> fiTypes;
	public String startDate;	//2021-02-05
	public String endDate;	//2021-07-24
	public Callback callback;
	public List<PassThroughParams> passThroughParams;
	public String returnUrl;	//https://www.acmebank.com
	public String customerUniqueId;	//wer2312434
	public OptionalParams optionalParams;
	public AdditionalParams additionalParams;
	public class Callback {
		public boolean includeTxnStatus;
	}
	public class PassThroughParams {
		public Data data;
		public String target;	//INSIGHTS
	}
	public class Data {
		public String facility;	//NONE
		public String loanType;	//Personal Loan
		public String loanAmount;	//100000
		public String todAllowed;	//false
		public String yearMonthTo;	//2021-06
		public String employerName;	//PROPERTY CONSULTANTS PVT LTD
		public String loanDuration;	//12
		public String yearMonthFrom;	//2021-01
		public String processingType;	//STATEMENT
		public String acceptancePolicy;	//atLeastOneTransactionInRange
        public String employmentType;
		public String uploadingScannedStatements;	//false
	}
	public class OptionalParams {
		public String consentNotification;	//https://webhook.site/consent
		public String dataNotification;	//https://webhook.site/data
		public String reportNotification;	//https://webhook.site/report
	}
	public class AdditionalParams {
		public String routingURL;	//https://www.acmebank.com/
		public String sourceSystem;	//acme
	}
    
}