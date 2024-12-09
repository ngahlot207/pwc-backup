public class ComBaseDtlsResponseWrapper {  

	public class Lei {
		public String number_Z {get;set;} // in json: number
		public String status {get;set;} 
    }
	
	public class Company {
		public Double authorized_capital {get;set;} 
		public String cin {get;set;} 
		public String efiling_status {get;set;} 
		public String incorporation_date {get;set;} 
		public String legal_name {get;set;} 
		public Double paid_up_capital {get;set;} 
		public Double sum_of_charges {get;set;} 
		public String active_compliance {get;set;} 
		public Registered_address registered_address {get;set;} 
		public String classification {get;set;} 
		public String status {get;set;} 
		public String last_agm_date {get;set;} 
		public String last_filing_date {get;set;} 
		public String email {get;set;} 
		public Lei lei {get;set;} 

	}
	
	public Metadata metadata {get;set;} 
	public Data data {get;set;} 
	public String message {get;set;} 

	
	
	public class Open_charges {
		public Integer id {get;set;} 
		public String date_Z {get;set;} // in json: date
		public String holder_name {get;set;} 
		public Double amount {get;set;} 
		public String type {get;set;} 

	}
	
	public class Address {
		public String address_line1 {get;set;} 
		public String address_line2 {get;set;} 
		public String city {get;set;} 
		public String pincode {get;set;} 
		public String state {get;set;} 
		public String country {get;set;} 

	}
	
	public class Authorized_signatories {
		public String pan {get;set;} 
		public String din {get;set;} 
		public String name {get;set;} 
		public String designation {get;set;} 
		public String din_status {get;set;} 
		public String gender {get;set;} 
		public String date_of_birth {get;set;} 
		public Integer age {get;set;} 
		public String date_of_appointment {get;set;} 
		public String date_of_appointment_for_current_designation {get;set;} 
		public String date_of_cessation {get;set;} 
		public String nationality {get;set;} 
		public Address address {get;set;} 

	}
	
	public class Metadata {
		public String api_version {get;set;} 
		public String last_updated {get;set;} 

	}
	
	public class Data {
		public Company company {get;set;} 
		public List<Open_charges> open_charges {get;set;} 
		public List<Authorized_signatories> authorized_signatories {get;set;} 
}
	
	public class Registered_address {
		public String full_address {get;set;} 
		public String address_line1 {get;set;} 
		public String address_line2 {get;set;} 
		public String city {get;set;} 
		public String pincode {get;set;} 
		public String state {get;set;} 

	}
	

}