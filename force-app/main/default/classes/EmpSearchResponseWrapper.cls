public class EmpSearchResponseWrapper {

	public class NameLookup {
		public String organizationName {get;set;} 
		public List<EpfHistory> epfHistory {get;set;} 
		public List<EstInfo> estInfo {get;set;} 
		public List<Matches> matches {get;set;} 
		public Boolean isNameExact {get;set;} 
		public Boolean isEmployed {get;set;} 
		public Boolean isRecent {get;set;} 
		public Boolean isNameUnique {get;set;} 
		public String employeeName {get;set;} 

		
	}
	
	public class Uan {
		public String uan {get;set;} 
		public List<Employer> employer {get;set;} 

		
	}
	
	public class Email {
		public Data data {get;set;} 
		public Whois whois {get;set;} 
		public String nameConfidence {get;set;} 

		
	}
	
	public Result result {get;set;} 
	public String request_id {get;set;} 
	public String status_code {get;set;} // in json: status-code
	public ClientData clientData {get;set;} 

	
	
	public class EstInfo {
		public String address {get;set;} 
		public String contactNo {get;set;} 
		public String emailId {get;set;} 
		public String estId {get;set;} 

		
	}
	
	public class Matches {
		public String name {get;set;} 
		public Integer confidence {get;set;} 
		public String estId {get;set;} 
		//public EpfHistory_Z epfHistory {get;set;} 
		public Map<String,Boolean> epfHistory;

		
	}
	
	public class Employer {
		public String name {get;set;} 
		public String memberId {get;set;} 
		public Object settled {get;set;} 
		public Boolean isNameUnique {get;set;} 
		public String matchName {get;set;} 
		public String lastMonth {get;set;} 
		public Boolean isRecent {get;set;} 
		public Boolean isNameExact {get;set;} 
		public Boolean isEmployed {get;set;} 
		public Integer nameConfidence {get;set;} 
		public Decimal emplrScore {get;set;} 
		public Boolean uanNameMatch {get;set;} 

		
	}
	
	public class Registrant {
		public String name {get;set;} 
		public String organization {get;set;} 
		public String street {get;set;} 
		public String city {get;set;} 
		public String postal {get;set;} 
		public String country {get;set;} 
		public String phone {get;set;} 
		public String fax {get;set;} 
		public String email {get;set;} 
		public String stateprovince {get;set;} 

		
	}
	
	public class Data {
		public Boolean disposable {get;set;} 
		public Boolean webmail {get;set;} 
		public String result {get;set;} 
		public Boolean acceptAll {get;set;} 
		public Boolean smtpCheck {get;set;} 
		public Boolean regexp {get;set;} 
		public Boolean mxRecords {get;set;} 
		public String email {get;set;} 

		
	}
	
	public class EpfHistory_Z {
		public Boolean APR_22 {get;set;} // in json: APR-22
		public Boolean MAR_22 {get;set;} // in json: MAR-22
		public Boolean FEB_22 {get;set;} // in json: FEB-22

		
	}
	
	public class Result {
		public List<Uan> uan {get;set;} 
		public Email email {get;set;} 
		public NameLookup nameLookup {get;set;} 

		
	}
	
	public class Whois {
		public String creationDate {get;set;} 
		public String updateDate {get;set;} 
		public String expirationDate {get;set;} 
		public Registrant registrant {get;set;} 

		
	}
	
	public class EpfHistory {
		public Integer totalAmount {get;set;} 
		public Integer totalMembers {get;set;} 
		public String formatted_wage_month {get;set;} 
		public String wageMonth {get;set;} 

		
	}
	
	public class ClientData {
		public String caseId {get;set;} 

		
	}
	

}