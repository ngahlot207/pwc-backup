public class LLPBaseDtlsResponseWrapper{
	public cls_metadata metadata;
	public cls_data data;
	public String message;
    
	public class cls_metadata {
		public String api_version;	//string
		public String last_updated;	//2024-07-01
	}
	public class cls_data {
		public cls_llp llp;
		public cls_open_charges[] open_charges;
		public cls_directors[] directors;
	}
	public class cls_llp {
		public String llpin;	//string
		public String legal_name;	//string
		public String efiling_status;	//ACTIVE
		public String incorporation_date;	//2024-07-01
		public Double sum_of_charges;	//0
		public Double total_obligation_of_contribution;	//0
		public cls_registered_address registered_address;
		public String classification;	//Limited Liability Partnership
		public String last_financial_reporting_date;	//2024-07-01
		public String last_annual_returns_filed_date;	//2024-07-01
		public String email;	//string
		public cls_lei lei;
	}
	public class cls_registered_address {
		public String full_address;	//string
		public String address_line1;	//string
		public String address_line2;	//string
		public String city;	//string
		public String pincode;	//string
		public String state;	//string
	}
	public class cls_lei {
		public String number_Z;	//string
		public String status;	//string
	}
	public class cls_open_charges {
		public Integer id;	//0
		public String date_Z;	//2024-07-01
		public String holder_name;	//string
		public Double amount;	//0
		public String type;	//Creation
	}
	public class cls_directors {
		public String din;	//string
		public String pan;	//string
		public String name;	//string
		public String designation;	//Director
		public String din_status;	//string
		public String gender;	//string
		public String date_of_birth;	//2024-07-01
		public Integer age;	//0
		public String date_of_appointment;	//2024-07-01
		public String date_of_appointment_for_current_designation;	//2024-07-01
		public String date_of_cessation;	//2024-07-01
		public String nationality;	//string
		public cls_address address;
	}
	public class cls_address {
		public String address_line1;	//string
		public String address_line2;	//string
		public String city;	//string
		public String pincode;	//string
		public String state;	//string
		public String country;	//string
	}
	

	
}