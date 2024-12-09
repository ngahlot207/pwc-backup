public class Trackwizz_CKYC_A63_RequestWrapper {

	public CustomerRelatedPartyCreateUpdateRequestClass CustomerRelatedPartyCreateUpdateRequest;
	
	public class CustomerRelatedPartyCreateUpdateRequestClass {
		public String ParentCompany;
		public String ApiToken;
		public RecordRequestDetailsClass RecordRequestDetails;
	}
	
	public class RecordRequestDetailsClass {
		public RecordRequestDetailClass RecordRequestDetail;
	}
	
	public class RecordRequestDetailClass {
		public String TransactionId;
		public String SourceSystemName;
		public String SourceSystemCustomerCode;
		public String IsSmallCustomer;
		public String EkycOTPBased;
		public String SourceSystemCustomerCreationDate;
		public String RecordIdentifier;
	    public SegmentsClass Segments;
	    public ProductSegmentsClass ProductSegments;
		public CustomerStatusClass CustomerStatus;
		public String CustomerType;
	    public String CustomerSubType;
		public String Prefix;
		public String FirstName;
		public String MiddleName;
		public String LastName;
		public String MaidenPrefix;
		public String MaidenFirstName;
		public String MaidenMiddleName;
		public String MaidenLastName;
		public String FatherPrefix;
		public String FatherFirstName;
		public String FatherMiddleName;
		public String FatherLastName;
		public String SpousePrefix;
		public String SpouseFirstName;
		public String SpouseMiddleName;
		public String SpouseLastName;
		public String MotherPrefix;
		public String MotherFirstName;
		public String MotherMiddleName;
		public String MotherLastName;
		public String Gender;
		public Integer FormSixty;
		public String KYCAttestationType;
		public String MaritalStatus;
		public EducationalQualificationDetailsClass EducationalQualificationDetails;
		public CitizenshipClass Citizenship;
		public String CountryOfResidence;
		public String OccupationType;
	    public ActivitySectorDetailsClass ActivitySectorDetails;
		public NatureOfBusinessClass NatureOfBusiness;
		public String NatureOfBusinessOther;
		public String DateofBirth;
		public EmailDetailsClass EmailDetails;
		public String KYCDateOfDeclaration;
		public String KYCPlaceOfDeclaration;
		public String KYCVerificationDate;
		public String KYCEmployeeName;
		public String KYCEmployeeDesignation;
		public String KYCVerificationBranch;
		public String KYCEmployeeCode;
		public AddressDetailsClass AddressDetails;
		public String PermanentAddressProof;
		public String CorrespondenceAddressProof;
		public String CommencementDate;
		public String PermanentAddressProofOthersValue;
		public Integer RelatedPersonCountForCKYC;
		public String CountryOfBirth;
		public String BirthCity;
		public TaxIdentificationDetailsClass TaxIdentificationDetails;
		public ContactDetailsClass ContactDetails;
		public IdentificationDetailsClass IdentificationDetails;
		public String ProofOfIDSubmitted;
		public Integer Minor;
		public String ApplicationRefNumber;
		public String HolderforImages;
		public String IntermediaryCode;
		public Integer Listed;
		public String Industry;
	    public NationalityClass Nationality;
	    public CountryofOperationClass CountryofOperation;
		public String RegulatoryAMLRisk;
		public String LastRiskReviewDate;
		public String NextRiskReviewDate;
		public IncomeDetailsClass IncomeDetails;
		public NetWorthDetailsClass NetWorthDetails;
		public String PEP;
		public PEPClassificationClass PEPClassification;
		public Integer AdverseMedia;
		public AdverseMediaClassificationClass AdverseMediaClassification;
		public String AdverseMediaDetails;
		public String InsiderInformation;
		public TagsClass Tags;
		public String FamilyCode;
		public String Channel;
		public String Links;
		public ReputationClassificationClass ReputationClassification;
		public RelationDetailsClass RelationDetails;
		public String IUPartyType;
		public Integer PropertyOwnerFlag;
		public ContactPersonDetailsClass ContactPersonDetails;
		public RMDetailsClass RMDetails;
		public ModuleApplicableClass ModuleApplicable;
		public ActivityEmployerDetailsClass ActivityEmployerDetails;
		public RegAMLSpecialCategoryDetailsClass RegAMLSpecialCategoryDetails;
	}
	
	public class SegmentsClass {
	  //public List<SegmentDetailClass> SegmentDetail;
	}
	
	public class SegmentDetailClass {
		public String Segment;
		public String StartDate;
		public String EndDate;
	}
	
	public class ProductSegmentsClass {
	  //public ProductSegmentDetailClass ProductSegmentDetail;
	}
	
	public class ProductSegmentDetailClass {
		public String ProductSegment;
		public String StartDate;
		public String EndDate;
		public Integer Quantity;
	}
	
	public class CustomerStatusClass {
		public StatusDetailClass StatusDetail;
	}
	
	public class StatusDetailClass {
		public String Status;
		public String EffectiveDate;
	}
	
	public class EducationalQualificationDetailsClass {
		public List<EducationalQualificationDetailClass> EducationalQualificationDetail;
	}
	
	public class EducationalQualificationDetailClass {
		public String EducationalQualification;
	}
	public class CitizenshipClass {
		public CountryDetailClass CountryDetail;
	}
	
	public class CountryDetailClass {
		public String Country;
	}
	
	public class ActivitySectorDetailsClass {
	  //public ActivitySectorDetailClass ActivitySectorDetail;
	}
	
	public class ActivitySectorDetailClass {
		public String ActivitySector;
	}
	
	public class NatureOfBusinessClass {
		//public NatureOfBusinessDetailClass NatureOfBusinessDetail;
	}
	
	/*
	public class NatureOfBusinessDetailClass {
		public String Business;
	}
	*/
	
	public class EmailDetailsClass {
		public List<EmailDetailClass> EmailDetail;
	}
	
	public class EmailDetailClass {
		public String EmailType;
		public String EmailId;
		public Integer Disabled;
	}
	
	public class AddressDetailsClass {
		public List<AddressDetailClass> AddressDetail;
	}
	
	public class AddressDetailClass {
		public String AddressType;
		public String PlotnoSurveynoHouseFlatno;
		public String AddressLine1;
		public String AddressLine2;
		public String AddressLine3;
		public String PinCode;
		public String City;
		public String Country;
        public String District;
		public String State;
	}
	
	public class TaxIdentificationDetailsClass {
	  //public TaxIdentificationDetailClass TaxIdentificationDetail;
	}
	
	public class TaxIdentificationDetailClass {
		public String TaxIdentificationNumber;
		public String Country;
		public String StartDate;
		public String EndDate;
	}
	
	public class ContactDetailsClass {
		public ContactDetailClass ContactDetail;
	}
	
	public class ContactDetailClass {
		public String ContactType;
		public String ISDCode;
		public String ContactNumber;
	    public Integer Disabled;
	}
	
	public class IdentificationDetailsClass {
		public List<IdentificationDetailClass> IdentificationDetail;
	}
	
	public class IdentificationDetailClass {
		public String IdType;
		public String IdNumber;
		public String ExpiryDate;
	}
	
	public class NationalityClass {
	  //public List<CountryDetailClass> CountryDetail;
	}
	/*
	public class CountryDetailClass {
	  public String Country;
	} 
	*/
    
    public class CountryofOperationClass {
        
    }
	public class IncomeDetailsClass {
	  //public IncomeDetailClass IncomeDetail;
	}
	
	public class IncomeDetailClass {
		public String Range;
		public String ExactIncome;
	  //public String Currency; reserved keyword
		public String EffectiveDate;
		public String Description;
		public ProofClass Proof;
	}
	
	public class ProofClass {
		public List<IncomeProofDetailClass> IncomeProofDetail;
	}
	
	public class IncomeProofDetailClass {
		public String IncomeProof;
	}
	
	public class NetWorthDetailsClass {
	  //public NetworthDetailClass NetworthDetail;
	}
	
	public class NetworthDetailClass {
		public String ExactIncome;
	  //public String Currency; reserved keyword
		public String EffectiveDate;
		public String Description;
	}
	
	public class PEPClassificationClass {
	  //public PEPClassificationDetailClass PEPClassificationDetail;
	}
	
	public class PEPClassificationDetailClass {
		public String Classification;
	}
	
	public class AdverseMediaClassificationClass {
	  //public AdverseMediaClassificationDetailClass AdverseMediaClassificationDetail;
	}
	
	public class AdverseMediaClassificationDetailClass {
		public String Classification;
	}
	
	public class TagsClass {
		public TagDetailClass TagDetail;
	}
	
	public class TagDetailClass {
		public String Tag;
	}
	
	public class ReputationClassificationClass {
	  //public ReputationClassificationDetailClass ReputationClassificationDetail;
	}
	
	public class ReputationClassificationDetailClass {
		public String Classification;
	}
	
	public class RelationDetailsClass {
		//public RelationDetailClass RelationDetail;
	}
	
	//To be given only if the customer is minor
	/*
	public class RelationDetailClass {
		public String RecordIdentifier;
		public String SourceSystemName;
		public String SourceSystemCustomerCode;
		public String Relation;
		public Decimal ShareHoldingPercentage;
		public String RelationStartDate;
	}
	*/
	
	public class ContactPersonDetailsClass {
	  //public ContactPersonDetailClass ContactPersonDetail;
	}
	
	public class ContactPersonDetailClass {
		public String FirstName;
		public String MiddleName;
		public String LastName;
		public String MobileISD;
		public String MobileNo;
		public String MobileISD2;
		public String MobileNo2;
		public String Designation;
		public String EmailId;
		public String EmailId2;
	}
	
	public class RMDetailsClass {
      //public RMDetailClass RMDetail;
	}
	
	public class RMDetailClass {
		public String UserCode;
		public String Type;
		public String FromDate;
		public String EndDate;
	}
	
	public class ModuleApplicableClass {
		public ModuleDetailClass ModuleDetail;
	}
	
	public class ModuleDetailClass {
		public String Module;
	}
	
	public class ActivityEmployerDetailsClass {
	  //public ActivityEmployerDetailClass ActivityEmployerDetail;
	}
	
	public class ActivityEmployerDetailClass {
		public String DesignationOthers;
		public String EmployerName;
		public String EmployerAddress;
		public String EmployerListed;
		public String EmployerOrganisationType;
		public String CurrentEmploymentInYears;
	}
	
	public class RegAMLSpecialCategoryDetailsClass {
	  //public RegAMLSpecialCategoryDetailClass RegAMLSpecialCategoryDetail;
	}
	
	public class RegAMLSpecialCategoryDetailClass {
		public String RegAMLSpecialCategory;
		public String StartDate;
		public String EndDate;
	}
    public Static Trackwizz_CKYC_A63_RequestWrapper praser(String json){
        return (Trackwizz_CKYC_A63_RequestWrapper) system.JSON.deserialize(json,Trackwizz_CKYC_A63_RequestWrapper.class);
    }
}