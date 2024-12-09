public class AddTrancheDisRequestWrapper {

	public class DisbursalDetail {
		public String applicationID;
		public String agreementNo;
		public String disbursalAmount;
		public String disbursalDate;
		public String disbusalDesc;
		public String principalRecoveryFlag;
		public String repaymentDate;
		public List<PaymentDetails> paymentDetails;
	}

	public class PaymentDetails {
		public String disbursalTo;
		public String amount;
		public String creditPeriod;
		public String paymentMode;
		public String ftMode;
		public String ifscCode;
		public String chequeDate;
		public String chequeNo;
		public String effectiveDate;
		public String accountNo;
		public String disbrsmntBank;
		public String createdBy;
		public String inFavourOf;
		public String remarks;
		public String city;
		public String bpID;
	}

	public String unqRequestId;
	public String sourceSystem;
	public String userId;
	public String password;
	public DisbursalDetail disbursalDetail;

	
	public static AddTrancheDisRequestWrapper parse(String json) {
		return (AddTrancheDisRequestWrapper) System.JSON.deserialize(json, AddTrancheDisRequestWrapper.class);
	}
}