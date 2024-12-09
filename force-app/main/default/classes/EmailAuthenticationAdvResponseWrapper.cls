public class EmailAuthenticationAdvResponseWrapper {
    
    public Result result;
    public string request_id;
    public string statuscode;
    public ClientData clientData;
    
    public class Result{
        public AdditionalInfo additional_info;
        public Data data;
        public ResultSummary result_summary;
    }
    
    public class AdditionalInfo{
        public CompanyInfo company_info;
        public List<UsrAndIndividualMatch> individual_match;
        public SpamRecord spam_record;
        public WhoIsInfo whois_info;
    }
    
    public class CompanyInfo{
        public  List<OrgMatch> org_domain_match;
        public  List<OrgMatch> org_email_match;
        public  List<UsrAndIndividualMatch> usr_director_match;
    }
    
    public class OrgMatch{
        public string domain;
        public Boolean match;
        public string org_name;
        public List<string> source;
        public string company_email;
    }
    
   /* public class OrgEmailMatch{
        public string company_email;
        public Boolean match;
        public string org_name;
        public List<string> source; 
    }*/
    
    public class UsrAndIndividualMatch{
        public string name;
        public Boolean match;
        public string org_name;
        public Double score; 
    }
    
  /*  public class IndividualMatch{
        public string name;
        public Boolean match;
        public Integer score;
    }*/
    
    public class SpamRecord{
        public Boolean spam_email;
        public Integer report_count;
        public Boolean ip_blacklist;
    }
    
    Public class WhoIsInfo{
        public Decimal age_year;
        public string creation_date;
        public string expiration_date;
        public string update_date;
        public Boolean expired;
        public List<WhoIsEmailMatch> whois_email_domain_match;
        public List<WhoIsEmailMatch> whois_email_match;
        public List<WhoIsIndvAndOrgName> whois_indv_name;
        public List<WhoIsIndvAndOrgName> whois_org_name;
    }
    
    public class WhoIsEmailMatch{
        public string domain;
        public Boolean match;
        public string company_email;
    }
    
    /*public class WhoIsEmailMatch{
        public string company_email;
        public Boolean match;
    }*/
    public class WhoIsIndvAndOrgName{
        public string name;
        public string org_name;
        public Boolean match;
        public double score;
    }
   /* public class WhoIsOrgName{
        public string org_name;
        public Boolean match;
        public double score;
    }*/
    
    
    public class Data{
        public Boolean disposable;
        public Boolean webmail;
        public string result;
        public Boolean accept_all;
        public Boolean smtp_check;
        public Boolean regexp;
        public Boolean mx_records;
        public string email;
        public Boolean smtp_server;
        public Boolean is_blocked;
        public string reason;
        public Boolean generic_email;
    }
    
    
    
    public class ResultSummary{
        public Boolean email_valid;
        public Boolean org_domain_match;
        public Boolean indv_flag;
        public string overall_result;
    }
    
    public class ClientData{
        public string caseId;
    }
}