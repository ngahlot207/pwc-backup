public class UdyamVerificationAPIResponseWrapper {
    
    public string requestId;
    public integer statusCode;
    public Result result;
    public ClientData clientData;
    
    public class Result{
        public string udyamRegistrationNo;
        public string dateOfRegistration;
        public string interestedInTreds;
        public string interestedInGem;
        public Profile profile;
        public BankDetails bankDetails;
        public EmploymentDetails employmentDetails;
        public Financials financials;
        public List<BranchDetails> branchDetails;
        public OfficialAddress officialAddress;
        public List<Industry> industry;
        public List<EnterpriseType> enterpriseType;
        public string pdfData;
    }
    
    public class Profile{
        public string name;
        public string majorActivity;
        public string organizationType;
        public string ownerName;
        public string pan;
        public string previousITRStatus;
        public string itrType;
        public string gstnStatus;
        public string mobile;
        public string emailId;
        public string socialCategory;
        public string gender;
        public string speciallyAbled;
        public string dateOfIncorporation;
        public string dateOfCommencement;
    }
    
    public class BankDetails{
        public string bank;
        public string ifsc;
        public string acNo;
    }
    
    public class EmploymentDetails{
        public string male;
        public string female;
        public string others;
        public string total;
    }
    
    public class Financials{
        public string financialYear; 
        public Details details;
    }
    
    public class Details{
        public string wdvPme; 
        public string exclusion; 
        public string netInvestmentInPme; 
        public string totalTurnover; 
        public string exportTurnover; 
        public string netTurnover; 
    }
    
    public class BranchDetails{
        public string name;
        public string flat;
        public string premises;
        public string village;
        public string block;
        public string road;
        public string city;
        public string state;
        public string pincode;
        public string district;
    }
    
    public class OfficialAddress{
        public string flat;
        public string premises;
        public string village;
        public string block;
        public string road;
        public string city;
        public string state;
        public string pincode;
        public string district;
        public string email;
        public string mobile;
    }
    
    public class Industry{
        public string industry;
        public string subSector;
        public string activityDescription;
        public string industryCode;
        public string subSectorCode;
        public string nicCode;
        public string activity;
    }
    
    public class EnterpriseType{
        public string classificationYear;
        public string enterpriseType;
        public string classificationDate;
    }
    
    public class ClientData{
        public string caseId;
    }
}