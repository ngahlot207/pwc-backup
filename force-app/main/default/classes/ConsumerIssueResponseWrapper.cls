public class ConsumerIssueResponseWrapper {
    public String STATUS;
    public Integer ACKNOWLEDGEMENT_ID;
    public List<Finished> FINISHED;
    public List<Reject> REJECT;
    public MergedResponse MERGED_RESPONSE_OBJECT;
      
    
    public class MergedResponse {
        public String issuedDate;
        public String totalNumEnquiries;
        public String totalNumCreditLines;
        public BureauFeeds bureauFeeds;
        Public List<activeTradelines> activeTradelines;
        Public List<pastEnquiry> pastEnquiry;
    }
    
    public class BureauFeeds {
        public List<CibilScore> cibilScore;
    }
    public class CibilScore {
        public String score;
        public List<String> scoringFactor;
        public String referenceNumber;
        public String scoreType;
        public String status;
    }
    
    public class activeTradelines{
        public string suitFiled;
        public string paymentHistory;
        public string accountOpenDate;
        public string creditInstitution;
        public string reportedDate;
        public string lastPaymentDate;
        public string lastPaymentAmount;
        public string monthlyInstallmentAmount;
        public string tenure;
        public string creditLimit;
        public string interestRate;
        public string writeOff;
        public string overdueAmount;
        public string accountType;
        public string currentBalance;//
        public string active;//
        public string paymentHistoryEndDate;
        public string accountNumber;
        public List<string> paymentHistoryArr;
        public string paymentHistoryStartDate;
        public string assetClassHistory;
        public string ownership;
        public List<month> month;
        public string paymentHistoryStartDateTemp;
        public string settlementAmount;
        public string secured;
        public string sanctionedAmount;
        public string reportedBureaus;
        public string bureauName;
    }
    
    public class pastEnquiry{
        
        public string amount;
        public string bureuReported;
        public string enquiryDate;
        public string enqConvBySameInstFlag;
        public string enqConvertedFlag;
        public string enquiryReason;
        public string enquiryBy;
        
    }
    public class month{
        public string suitFiledStatus;
         public string assetClassificationStatus;
         public string paymentStatus;
         public string key;
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
    
    public class Finished {
        public Integer TRACKING_ID;
        public String BUREAU_STRING;
        public String STATUS;
        public String PRODUCT;
        public JSONResponseObject JSONResponseObject;
        public String BUREAU;
        public String HTML_REPORT;
        public List<Integer> PDF_REPORT;
        //public string ENCODEDSTRING;
    }
    
    public class JSONResponseObject {
        public List<ScoreList> scoreList;
        public List<EmploymentList> employmentList;
        public List<AddressList> addressList;
        public List<AccountList> accountList;
        public name name;
        public innerheader header;
        public List<PhoneList> phoneList;
        public List<EnquiryList> enquiryList;
        public List<IdList> idList;
        public List<errorDomainList> errorDomainList;
   }
    
    Public class errorDomainList{
        public String errorDescription;
        public String errorCategory;
        public String errorCode;
    }
    
    public class AddressList {
        public String addressCategory;
        public String pinCode;
        public String dateReported;
        public String addressLine1;
        public String addressLine2;
        public String stateCode;
        public String addressLine3;
        public String addressLine4;
        Public String enrichedThroughtEnquiry;
        Public String residenceCode;
        Public String addressLine5;
    }
    
    public class AccountList {
        public String dateReportedAndCertified;
        public String dateOpenedOrDisbursed;
        public String accountType;
        public String currentBalance;
        public String paymentHistoryEndDate;
        public String paymentHistoryStartDate;
        public String ownershipIndicator;
        public String emiAmount;
        public String paymentFrequence;
        public String paymentHistory1;
        public String paymentHistory2;
        public String reportingMemberShortName;
        public String repaymentTenure;
        public String dateOfLastPayment;
        public String highCreditOrSanctionedAmount;
        public String valueOfCollateral;
        public String dateClosed;
        public String rateOfInterest;
        public String typeOfCollateral;
        public String actualPaymentAmount;
        public string creditLimit;
        public string cashLimit;
        public string overdueAmount;
        //Changes Realted BRE New Request
        public string writtenOffAmountPrincipal;
        public string settlementAmount;
        public string suitFiledOrWilfulDefault;
        public string writtenOffAmountTotal;
        public string writtenOffAndSettledStatus;

    }
    Public class name {
        public String name3;	
        public String gender;	
        public String dob;	
        public String name2;	
        public String name1;	
    }
    Public class innerheader {
        public String memberReferenceNumber;	
        public String timeProceed;	
        public String enquiryMemberUserID;	
        public String dateProceed;	
        public String subjectReturnCode;	
        public String version;	
        public String enquiryControlNumber;	
    }
    public class ScoreList {
        public String score;
        public String reasonCode2;
        public String reasonCode1;
        public String scoreCardVersion;
        public String scoreCardName;
        public String scoreDate;
        public String scoreName;
    }
    
    public class EmploymentList {
        public String occupationCode;
        public String accountType;
        public String dateReported;
    }
    
    public class PhoneList {
        public String telephoneNumber;
        public String telephoneType;
        public String enrichEnquiryForPhone;
    }
    
    public class EnquiryList {
        public String enquiryPurpose;
        public String dateReported;
        public String reportingMemberShortName;
        public String enquiryAmount;
    }
    
    public class IdList {
        public String expiryDate;
        public String idType;
        public String idValue;
    }
    
    
    public static ConsumerIssueResponseWrapper parse(String json){
        return (ConsumerIssueResponseWrapper) System.JSON.deserialize(json, ConsumerIssueResponseWrapper.class);
    }
}