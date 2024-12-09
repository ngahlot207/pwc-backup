public class DedupeResponseWrapper {
	
    public List<NegativeList> negativeList;
	public String success;	//true
	public String requestId;	//1886c02b-3df6-4afd-87ad-88cad4b10c82
	public List<Customers> customers;
	public String message;	//Record matched successfully
    public String msg;
	public String ucid;	//12994715
	
    public class NegativeList {
        public String passportno;
        public String pincode;
        public String address;
        public String aadharNumber;
        public String voteridno;
        public String primarymobileno;
        public String city;
        public String panno;
        public String secondarymobileno;
        public Long id;
        public String customername;
        public String drivinglicenseid;
        public String file_name;
        public String negative_reasons;
	}
	
    public class Customers {
		public String passportno;	//
		public String ckycid;	//
		public String constitution;	//
		public String gender;	//F
		public String city;	//Mundhva AV P.O.
		public String panno;	//CAQPP1734C
		public String emailId;	//
		public String source;	//LCODE
		public String mothermiddlename;	//
		public String motherlastname;	//
		public String customerMiddleName;	//
		public String motherfirstname;	//SEEMA
		public String customerLastName;	//
		public Long id;	//1693913474609210000
		public String uniqueRefNumber;	//638130950526839117
		public String dateofbirth;	//02-06-1988
		public String pincode;	//411036
		public String risk_category;	//
		public String address;	//house no 36 Pradhan Niwas Sambhaji chawk nr Sambaji chawk Keshav nagar mundhwa pune
		public String primarymobileno;	//9767817732
		public String drivinglicenseid;	//
		public String husbandorfathermiddlename;	//
		public String husbandorfatherlastname;	//
		public String aadharNumber;	//********4071
		public String voteridno;	//
		public String customerFirstName;	//VARSHA RAMESH PRADHAN
		public String husbandorfatherfirstname;	//RAMESH JEENAR PRADHAN
		public String appid;	//900946
		public String customerid;	//
		public String secondarymobileno;	//
        public MatchingCr matchingCr;
	}
    
    public class MatchingCr {
		public List<AdditionalInformation> additionalInformation;
		public String DRIVINGLICENCE;	//0%
		public String VOTERID;	//0%
		public String AADHAR;	//0%
		public OtherCriteria OTHER_CRITERIA;
		public String PAN;	//100%
		public String PASSPORT;	//0%
	}
    public class AdditionalInformation {
        public String dpdString;	//0
        public String mob;	//6
        public String loanType;	//GOLD LOAN
        public String loanDisbDate;	//2023-01-30 00:00:00.0
        public String bounce;	//
        public String currentOutstanding;	//0
        public String existingFedfinaTenure;	//12
        public String source;	//LCODE
        public String customerName;	//
        public String loanAmount;	//46500
        public String rejectReason; //OVER LEVERAGED
        public String customerId;	//1041086
        public String loanStatus;	//CLOSED
        public String lan;	//1006700003193
        public String dpd;
        public String applicationId;	//230067109
        public String securitizationFlag;	//N
        public String applicationDate;	//2023-01-30 00:00:00.0
    }
	public class OtherCriteria {
        public String firstName;	//(80-100)%
		public String lastName;	//(80-100)%
		public String gender;	//100%
		public String dateOfBirth;	//100%
		public String primaryMobileNo;	//100%
		public String email;	//100%
	}

	
    public static DedupeResponseWrapper parse(String json){
		return (DedupeResponseWrapper) System.JSON.deserialize(json, DedupeResponseWrapper.class);
	}
    
}