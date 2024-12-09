public class CommercialIssueResponseWrapper {
    public String STATUS;
    public String ACKNOWLEDGEMENT_ID;
    public List<FINISHED> FINISHED;
    public List<Reject> REJECT;
    
    
    public class FINISHED {
        public String STATUS;	//BUREAU-ERROR
        public String PRODUCT;	//CCIR
        public JSONRESPONSEOBJECT JSONRESPONSEOBJECT;
        public String BUREAU;	//CIBIL
        public List<Integer> PDF_REPORT;
    }
    public class JSONRESPONSEOBJECT {
        public responseReport responseReport;
    }
    public class responseReport {
        public ReportHeaderRec reportHeaderRec;
        public List<reportIssuesVec> reportIssuesVec;
        public EnquiryInformationRec enquiryInformationRec; 
        public ProductSec productSec; 
    }
    
    public class ReportHeaderRec {
        public String reportOrderedBy; 
        public String memberReferenceNumber; 
        public String inquiryPurpose; 
        public String reportOrderDate; 
        public String daysPasswordToExpire; 
        public String reportOrderNumber; 
        public String memberDetails; 
        public String applicationReferenceNumber; 
    }
    public class reportIssuesVec {
        public String code;	//1011
        public String description;	//The specified Enquiry Type is Invalid.
        public String message;	//Invalid Enquiry Type
    }
    public class EnquiryInformationRec {
        public String borrowerName; 
        public String tin; 
        public String dateOfRegistration; 
        public String cin; 
        public String pan; 
        public String crn; 
		public String addressCount;
		public AddressVec addressVec; 
    }
    
    public class  AddressVec{
        public List<Address> address;  
    }
    
    public class Address {
        public String city; 
        public String pinCode; 
        public String state; 
        public String addressLine; 
    }
    
    public class ProductSec {
        public RelationshipDetailsVec relationshipDetailsVec;
        public EnquiryDetailsInLast24MonthVec enquiryDetailsInLast24MonthVec;
        public DerogatoryInformationSec derogatoryInformationSec;
        public LocationDetailsSec locationDetailsSec; 
        public SuitFiledVec suitFiledVec;
        public BorrowerProfileSec borrowerProfileSec;
        public RankSec rankSec;
        public SuitFiledVec creditFacilityDetailsasBorrowerSecVec;
        public CreditFacilitiesSummary creditFacilitiesSummary; 
        public EnquirySummarySec enquirySummarySec; 
        public CreditProfileSummarySec creditProfileSummarySec;
        public SuitFiledVec creditRatingSummaryVec; 
		public SuitFiledVec creditFacilityDetailsasGuarantorVec;
        public OustandingBalanceByCFAndAssetClasificationSec oustandingBalanceByCFAndAssetClasificationSec;  
		public creditVisionSec creditVisionSec;
    }
    


    public class RelationshipDetailsVec {
        public RelationshipDispute relationshipDispute; 
		public List<relationshipDetails> relationshipDetails;
        public String message;
    }
    
    public class RelationshipDispute {
        public String disputeRemarks; 
        public String disputeRemarksDate;
    }

	public class relationshipDetails{
		public relationshipInformation relationshipInformation;
		public BorrwerIDDetailsVec borrwerIDDetailsVec;
		public BorrwerAddressContactDetails borrwerAddressContactDetails;
		public string relationshipHeader;

	}

	public class relationshipInformation{
		public string dateOfIncorporation;
		public string relatedType;
		public string businessIndustryType;
		public string classOfActivity1;
		public string name;
		public string businessCategory;
		public string percentageOfControl;
		public string relationship;

	}
    
    
    public class EnquiryDetailsInLast24MonthVec {
		public RelationshipDispute enquiriesDispute;
		public List<EnquiryDetailsInLast24Month> enquiryDetailsInLast24Month; 
		public String message; 

		
	}
    
    
    public class EnquiryDetailsInLast24Month {
		public String enquiryPurpose; 
		public String creditLender;
		public String enquiryDt;
		public String enquiryAmt;

		
	}
    public class DerogatoryInformationSec {
		public String messageOfRelatedParties;
		public String messageOfRelatedPartiesOutsideInstitution; 
		public String messageOfGuarantedParties;
		public DerogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec; 
		public DerogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec derogatoryInformationBorrower; 
		public String messageOfRelatedPartiesYourInstitution; 
		public String messageOfBorrowerYourInstitution;
		public String messageOfBorrowerOutsideInstitution; 
		public String message; 
		public String messageOfBorrower; 

		
	}
    
    
    public class DerogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec {
		public Total total;
		public Total yourInstitution;
		public Total outsideInstitution;

	
	}
    public class Total {
		public Settled settled;
		public Settled writtenOff;
		public Settled invoked;
        public Settled suitFilled; 
		public Settled overdueCF; 
        public String dishonoredCheque;
		public String wilfulDefault; 
		 

		
	}
    public class Settled {
		public String amt; 
		public String numberOfSuitFiled; 

		
	}
    
    public class LocationDetailsSec {
		public String message;
		public String faxNumber;
		public String contactNumber;
		public locationInformationVec locationInformationVec;
		public RelationshipDispute locationDispute; 
		

		
	}
    
    public class locationInformationVec{

        public List<locationInformation> locationInformation;

	}
   

	public class locationInformation{
        
		public String numberOfInstitutions;
		public String address;
		public String lastReportedDate;
		public String firstReportedDate;
		public String borrowerOfficeLocationType;
	}


 public class SuitFiledVec {
		public String message;

		public List<borrowerDelinquencyReportedOnRSOrGSOftheBorrowerIn24Months> borrowerDelinquencyReportedOnRSOrGSOftheBorrowerIn24Months;

		public List<creditFacilityDetailsasBorrowerSec> creditFacilityDetailsasBorrowerSec;

		
	}

	public class creditFacilityDetailsasBorrowerSec{
        public string message;
		public creditFacilityCurrentDetailsVec creditFacilityCurrentDetailsVec;
		public creditFacilityOverdueDetailsVec creditFacilityOverdueDetailsVec;
		public CFHistoryforACOrDPDupto24MonthsVec CFHistoryforACOrDPDupto24MonthsVec;
		public creditFacilitySecurityDetailsVec creditFacilitySecurityDetailsVec;
		public creditFacilityGuarantorDetailsVec creditFacilityGuarantorDetailsVec;
		public chequeDishounouredDuetoInsufficientFunds chequeDishounouredDuetoInsufficientFunds;


	}

	public class creditFacilityCurrentDetailsVec{

           public creditFacilityCurrentDetails creditFacilityCurrentDetails;
		   
	}

	public class creditFacilityCurrentDetails{
		public string statusDate;
		public string cfSerialNumber;
		public string lastReportedDate;
		public string cfType;
		public string derivative;
		public string cfMember;
		public string accountNumber;
		public string assetClassificationDaysPastDueDpd;
		public string status;

		public amount amount;
		public RelationshipDispute creditFacilityDispute;
		public otherDetails otherDetails;
		public dates dates;
	}

	public class amount{
         
		public string drawingPower;
		public string overdue;
		public string lastRepaid;
		public string settled;
		public string installmentAmt;
		public string highCredit;
		public string writtenOFF;
		public string sanctionedAmt;
		//public string currency;
		public string outstandingBalance;
	}

	public class otherDetails{

		public string repaymentFrequency;
		public string tenure;
		public string assetBasedSecurityCoverage;
		public string guaranteeCoverage;
		public string restructingReason;
	}
   
	public class dates{
		public string sanctionedDt;
		public string loanExpiryDt;
		public string loanRenewalDt;

	}

 public class creditFacilityOverdueDetailsVec{
	public string message;

	public creditFacilityOverdueDetails creditFacilityOverdueDetails;
 }


public class creditFacilityOverdueDetails{
	public string DPD1To30Amt;
	public string DPD31To60Amt;
	public string DPD61T090Amt;
	public string DPD91To180Amt;
	public string DPDabove180Amt;
	
}

public class CFHistoryforACOrDPDupto24MonthsVec{
   public List<CFHistoryforACOrDPDupto24Months> CFHistoryforACOrDPDupto24Months;
}

public class CFHistoryforACOrDPDupto24Months{
    public string month;
	public string ACorDPD;
	public string OSAmount;
}
public class creditFacilitySecurityDetailsVec{
	public list<creditFacilitySecurityDetails> creditFacilitySecurityDetails;
	public string message;
}

public class creditFacilitySecurityDetails{
	public string relatedType;
	public string lastReportedDt;
	//public string currency;
	public string classification;
	public string value;
	public string validationDt;
	
}

public class creditFacilityGuarantorDetailsVec{
	public string message;
	public List<creditFacilityGuarantorDetails> creditFacilityGuarantorDetails;
	
}

public class creditFacilityGuarantorDetails{

	public guarantorAddressContactDetails guarantorAddressContactDetails;
	public guarantorDetailsBorrwerIDDetailsVec guarantorDetailsBorrwerIDDetailsVec;
	public guarantorDetails guarantorDetails;

}

public class guarantorAddressContactDetails{
	public string address;
	

}
public class guarantorDetailsBorrwerIDDetailsVec{
	public string lastReportedDate;
	public List<guarantorIDDetails> guarantorIDDetails;

}

public class guarantorIDDetails{
	public string pan;
}

public class guarantorDetails{
	public string relatedType;
	public string name;

}




public class chequeDishounouredDuetoInsufficientFunds{
	public string message;
}

public class creditVisionSec{
	public List<creditVision> creditVision;
}

public class creditVision{
	public string creditVisionDesc;
	public integer creditVisionValue;
	public string creditVisionName;
}





    
    public class BorrowerProfileSec {
		public BorrwerIDDetailsVec borrwerIDDetailsVec; 
		public RelationshipDispute borrowerDispute;
		public BorrwerDetails borrwerDetails; 
		public BorrwerAddressContactDetails borrwerAddressContactDetails; 
		public BorrowerDelinquencyReportedOnBorrower borrowerDelinquencyReportedOnBorrower; 
		public SuitFiledVec borrowerDelinquencyReportedOnRSOrGSOftheBorrowerIn24MonthsVec; 

		
	}
    public class BorrwerIDDetailsVec {
		public String lastReportedDate;
		public List<BorrwerIDDetails> borrwerIDDetails;

		
	}
    
    public class BorrwerIDDetails {
		public String cin;
		public String pan; 

		
	}
    
    public class BorrwerDetails {
		public String dateOfIncorporation; 
		public String businessIndustryType; 
		public String year; 
		public String name;
		public String businessCategory;
		public ClassOfActivityVec classOfActivityVec;
		public String borrowersLegalConstitution; 
		public String salesFigure;
		public String numberOfEmployees; 

		
	}

    public class ClassOfActivityVec {
		public List<String> classOfActivity; 

		
	}
    public class BorrwerAddressContactDetails {
		public String address;
		public String telephoneNumber; 
		public String mobileNumber; 
		public String faxNumber;

		
	}
    public class BorrowerDelinquencyReportedOnBorrower {
		public YourInstitution yourInstitution;
		public YourInstitution outsideInstitution; 

		
	}
    public class YourInstitution {
		public String current; 
		public String last24Months;

		
	}
	public class borrowerDelinquencyReportedOnRSOrGSOftheBorrowerIn24Months{
		public String wcOutstanding;
		public String tlCount;
		public String fxOutstanding;
		public String tlOutstanding;
		public String nfCount;
		public String fxCount;
		public String wcCount;
		public String nfOutstanding;
		public String detail;
		public String relationship;
	}
    public class RankSec {
		public List<RankVec> rankVec; 
		public String message;

		
	}
    public class RankVec {
		public String exclusionReason; 
		public String rankName; 
		public String rankValue; 

		
	}
    public class CreditFacilitiesSummary {
		public CountOfCreditFacilities countOfCreditFacilities;

		
	}
    public class CountOfCreditFacilities {
		public NoOfCreditGrantors noOfCreditGrantors; 
		public NoOfCreditGrantors noOfCreditFacilities; 

		
	}
    public class NoOfCreditGrantors {
		public String yourBank; 
		public String total; 
		public String others; 

		
	}
    public class EnquirySummarySec {
		public EnquiryOutsideInstitution enquiryOutsideInstitution; 
		public EnquiryOutsideInstitution enquiryYourInstitution; 
		public String message;
		public EnquiryOutsideInstitution enquiryTotal;

		
	}
    
    public class EnquiryOutsideInstitution {
		public NoOfEnquiries noOfEnquiries;

		
	}
    
    public class NoOfEnquiries {
		public String month2To3;
		public String month4To6;
		public String month1; 
		public String total; 
		public String month12To24; 
		public String mostRecentDate;
		public String greaterthan24Month;
		public String month7To12;

		
	}
    

    public class CreditProfileSummarySec {
		public Total_Z total;
		public YourInstitution_Z yourInstitution; 
		public OutsideInstitution outsideInstitution; 

		
	}

    public class Total_Z {
		public String latestCFOpenedDate; 
		public String totalOutstanding; 
		public String totalCF; 
		public String delinquentOutstanding;
		public String delinquentCF;
		public String openCF; 
		public String totalLenders;

		
	}

    public class YourInstitution_Z {
		public String latestCFOpenedDate; 
		public TotalOutstanding totalOutstanding;
		public TotalOutstanding totalCF; 
		public TotalOutstanding delinquentOutstanding; 
		public String message; 
		public TotalOutstanding delinquentCF; 
		public String openCF;
		public String totalLenders;

		
	}

public class TotalOutstanding {
		public String borrowerPercentage;
		public String borrower; 
		public String guarantor; 
		public String guarantorPercentage;

		
	}

    public class OutsideInstitution {
		public YourInstitution_Z outsideTotal; 
		public String message;
		public YourInstitution_Z otherPublicSectorBanks;
		public YourInstitution_Z otherPrivateForeignBanks;
		public YourInstitution_Z NBFCOthers;

		
	}
    public class OustandingBalanceByCFAndAssetClasificationSec {
		public YourInstitution_Y yourInstitution; 
		public String message; 
		public YourInstitution_Y outsideInstitution; 

		
	}

    public class YourInstitution_Y {
		public Total_Y total; 
		public TermLoan termLoan; 
		public TermLoan workingCapital;
		public TermLoan forex;
		public TermLoan nonFunded;

		
	}

    public class Total_Y {
		public NONSTDVec NONSTDVec; 
		public STDVec STDVec; 

		
	}

    public class NONSTDVec {
		public Sub sub; 
		public Sub loss;
		public Sub DPD91To180; 
		public Sub dbt; 

		
	}

    public class STDVec {
		public Sub DPD61To90;
		public Sub DPD1To30;
		public Sub DPD0;
		public Sub DPD31To60; 

		
	}
    public class TermLoan {
		public NONSTDVec NONSTDVec; 
		public Sub total; 
		public STDVec STDVec;

		
	}

    public class Sub {
		public String count;
		public String value; 

		
	}

public class Reject{
        public String STATUS;
        public String PRODUCT;
        public String BUREAU;
        public list<error> ERRORS;
    }
    public class error {
        public String CODE;
        public String DESCRIPTION;
    }	
    public static CommercialIssueResponseWrapper parse(String json){
        return (CommercialIssueResponseWrapper) System.JSON.deserialize(json, CommercialIssueResponseWrapper.class);
    }
    
    
}