public class CrimeCheckCallbackResponseWrapper {
    
    public string status;
    public Long requestId;
    public string requestTime;
    public string responseTime;
    public boolean crimewatch;
    public string downloadLink;
    public string riskType;
    public string riskSummary;
    public integer numberOfCases;
    public string disclaimer;
    public List<SearchTerm> searchTerm;
    public List<CaseDetails> caseDetails;
    
    public class SearchTerm{
        public string companyName;
        public string ownerName;
        public string cinNumber;
        public string address;
        public string name;
        public string fatherName;
        public string dob;
    }
    
    public class CaseDetails{
        public integer slNo;
        public string petitioner;
        public string respondent;
        public string cinNumber;
        public string caseTypeName;
        public string hearingDate;
        public string courtNumberAndJudge;
        public string courtName;
        public string state;
        public string district;
        public string petitionerAddress;
        public string respondentAddress;
        public string caseNumber;
        public string caseNo;
        public string caseYear;
        public string underAct;
        public string section;
        public string underSection;
        public string caseStatus;
        public string firLink;
        public string judgementLink;
        public string gfc_uniqueid;
        public string caseLink;
        public string caseType;
        public string natureOfDisposal;
        public string riskType;
        public string riskSummary;
        public string severity;
        public string judgementSummary;
        public string caseRegDate;
        public string regNumber;
        public string filingDate;
        public string filingNumber;
        public string courtType;
        public string matchingAddress;
        public string matchSummary;
        public string caseDetailsLink;
        public GFCordersdata gfc_orders_data;
        public List<GFCrespondents> gfc_respondents;
        public List<GFCrespondents> gfc_petitioners;
        public List<CaseFlow> caseFlow;
    }
    
    public class GFCordersdata{
        public List<Petitioners> petitioners;
        public List<Respondents> respondents;
    }
    
    public class Petitioners{
        
    }
    
    public class Respondents{
        
    }
    
    public class GFCrespondents{
        public string name;
        public string address;
    }
    
    public class CaseFlow{
        public string Order;
        public string gfc_OrderType;
        public string orderDate;
        public string orderLink;
        public string elastic_id;
        public string index;
    }
    
}