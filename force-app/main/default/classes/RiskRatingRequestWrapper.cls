public class RiskRatingRequestWrapper {

	//Main Object
	public RiskProfilingRequest RiskProfilingRequest;
	public class RiskProfilingRequest {
		public String ApiToken;	    //39475a23-6dd8-43db-8a31-e12dc969324c
		public String RequestId;	    //R2
		public String RiskCalculationFor;	    //2
		public String ParentCompany;	    //Fedbank
		public RecordRequestDetails RecordRequestDetails;
	}

	public class RecordRequestDetails {
		public List<RecordRequestDetail> RecordRequestDetail;
	}

	public class RecordRequestDetail {
		public String TransactionId;	    //T1
		public String RecordIdentifier;	    //RecordIdentifier
        public String SourceSystemName;
		public String ProposedAs;	    //1
		public Segments Segments;
		public String CustomerType;	    //CustomerType
		public String CustomerSubType;	    //CustomerSubType
		public String Prefix;	    //Prefix
		public String FirstName;	    //FirstName
		public String MiddleName;	    //MiddleName
		public String LastName;	    //LastName
		public String Gender;	    //Gender
		public String MaritalStatus;	    //MaritalStatus
		public Citizenship Citizenship;
		public String OccupationType;	    //OccupationType
		public NatureOfBusiness NatureOfBusiness;
		public String NatureOfBusinessOther;	    //NatureOfBusinessOther
		public String DateofBirth;	    //02-Jan-1980
		public EmailDetails EmailDetails;
		public AddressDetails AddressDetails;
		public String PermanentAddressProof;	    //PermanentAddressProof
		public String CountryOfBirth;	    //IN
		public String BirthCity;	    //HYD
		public TaxIdentificationDetails TaxIdentificationDetails;
		public ContactDetails ContactDetails;
		public IdentificationDetails IdentificationDetails;
		public String ProofOfIDSubmitted;	    //ProofOfIDSubmitted
		public Integer Minor;	    //0
		public ProductSegments ProductSegments;
		public String ApplicationRefNumber;	    //ApplicationRefNumber
		public String IntermediaryCode;	    //IntermediaryCode
		public Integer Listed;	    //1
		public String Industry;	    //Industry
		public Nationality Nationality;
		public CountryOfOperation CountryOfOperation;
		public Integer FinancialExposure;	    //12323
		public String IncomeRange;	    //IncomeRange
		public Integer ExactIncome;	    //500000
		public String IncomeCurrency;	    //INR
		public String IncomeEffectiveDate;	    //22-May-2018
		public String IncomeDescription;	    //IncomeDescription
		public String IncomeProof;	    //IncomeProof
		public Integer Networth;	    //5000000
		public String NetworthCurrency;	    //INR
		public String NetworthEffectiveDate;	    //22-May-2018
		public String NetworthDescription;	    //NetworthDescription
		public String NetworthProof;	    //NetworthProof
		public String PEP;	    //PEP
		public PEPClassification PEPClassification;
		public Integer AdverseMedia;	    //1
		public AdverseMediaClassification AdverseMediaClassification;
		public String AdverseMediaDetails;	    //AdverseMediaDetails
		public Tags Tags;
		public String Channel;	    //Channel
		public String Links;	    //Important Links
		public ReputationClassification ReputationClassification;
		public RelationDetails RelationDetails;
	}

	public class Segments {
		public SegmentDetail SegmentDetail;
	}

	public class SegmentDetail {
		public String Segment;	    //Retail
	}

	public class Citizenship {
		public CountryDetail CountryDetail;
	}

	public class CountryDetail {
		public String Country;	    //IN
	}

	public class NatureOfBusiness {
		public List<NatureOfBusinessDetail> NatureOfBusinessDetail;
	}

	public class NatureOfBusinessDetail {
		public String Business;	    //Business1
	}

	public class EmailDetails {
		public List<EmailDetail> EmailDetail;
	}

	public class EmailDetail {
		public String EmailType;	    //Personal
		public String EmailId;	    //EmailId
	}

	public class AddressDetails {
		public List<AddressDetail> AddressDetail;
	}

	public class AddressDetail {
		public String AddressType;	    //Permanent
		public String AddressLine1;	    //AddressLine1
		public String AddressLine2;	    //AddressLine2
		public String PinCode;	    //PinCode
		public String City;	    //City
		public String State;	    //MH
		public String Country;	    //IN
		public String District;	    //District
	}

	public class TaxIdentificationDetails {
		public TaxIdentificationDetail TaxIdentificationDetail;
	}

	public class TaxIdentificationDetail {
		public String TaxIdentificationNumber;	    //TaxIdentificationNumber1
		public String Country;	    //US
		public String StartDate;	    //01-Apr-2018
	}

	public class ContactDetails {
		public List<ContactDetail> ContactDetail;
	}

	public class ContactDetail {
		public String ContactType;	    //ContactType
		public String ISDCode;	    //ISDCode
		public String STDCode;	    //STDCode
		public String ContactNumber;	    //ContactNumber
	}

	public class IdentificationDetails {
		public List<IdentificationDetail> IdentificationDetail;
	}

	public class IdentificationDetail {
		public String IdType;	    //Pan
		public String IdNumber;	    //PanNumber
        public String ExpiryDate;
        public String Country;
	}

	public class ProductSegments {
		public ProductSegmentDetail ProductSegmentDetail;
	}

	public class ProductSegmentDetail {
		public String ProductSegment;	    //Segment
	}

	public class Nationality {
		public CountryDetail CountryDetail;
	}

	public class CountryOfOperation {
		public CountryDetail CountryDetail;
	}

	public class PEPClassification {
		public PEPClassificationDetail PEPClassificationDetail;
	}

	public class PEPClassificationDetail {
		public String Classification;	    //Classification
	}

	public class AdverseMediaClassification {
		public AdverseMediaClassificationDetail AdverseMediaClassificationDetail;
	}

	public class AdverseMediaClassificationDetail {
		public String Classification;	    //Classification
	}

	public class Tags {
		public TagDetail TagDetail;
	}

	public class TagDetail {
		public String Tag;	    //Tag
	}

	public class ReputationClassification {
		public ReputationClassificationDetail ReputationClassificationDetail;
	}

	public class ReputationClassificationDetail {
		public String Classification;	    //TW01
	}

	public class RelationDetails {
		public List<RelationDetail> RelationDetail;
	}

	public class RelationDetail {
		public String RecordIdentifier;	    //RecordIdentifier1
		public Integer Relation;	    //106
		public String RelationStartDate;	    //22-Jan-2019
	}
    
    public static RiskRatingRequestWrapper parse(String json){
        return (RiskRatingRequestWrapper) System.JSON.deserialize(json, RiskRatingRequestWrapper.class);
    }

}