public class RequestStampPaperWrapper {
    
    public String reference_id;	//xxxx
	public String content;	//xxxx
	public String first_party_name;	//xxxx
	public String second_party_name;	//xxxx
	public String duty_payer_phone_number;	//xxxx
	public String duty_payer_email_id;	//xxxx
	//public Boolean send_payment_link;	//xxxx
	//public Map<String,String> custom;
	public Address first_party_address;
	public Address second_party_address;
	public String stamp_amount;
	public String consideration_amount;	//xxxx
	public String stamp_state;	//xxxx
	public String stamp_type;	//xxxx
	public String surcharge;	//xx
	public String stamp_duty_paid_by;	//xxxx
	public String stamp_duty_payment_method;	//xxxx
	public String document_category;
	public String document_reference_no;	//xxxx
	public FirstPartyDetails first_party_details;
	public String first_party_phone_number;	//xxxx
	public SecondPartyDetails second_party_details;
	public String second_party_phone_number;	//xxxx
	public String first_party_authorized_person_name;	//xxxx
	public String second_party_authorized_person_name;	//xxxx
	public String authorized_person;	//xxxx
	public List<CoApplicants> co_applicants;
	public esbtrDetails esbtr_details;
	/*public class Custom {
		public String parameter_name;	//xxxxxxxx
	}*/
	Public class Address {
		public String street_address;	//xxxx
		public String locality;	//xxxx
		public String city;	//xxxx
		public String state;	//xxxx
		public String pincode;	//xxxx
		public String country;	//India
	}
	Public class FirstPartyDetails {
		public String date_of_birth;	//xxxx
		public String father_or_husband_name;	//xxxx
		public String first_party_entity_type;	//xxxx
		public String first_party_id_type;	//xxxx
		public String first_party_id_number;	//xxxx
	}
	Public class SecondPartyDetails {
		public String date_of_birth;	//xxxx
		public String father_or_husband_name;	//xxxx
		public String second_party_entity_type;	//xxxx
		public String second_party_id_type;	//xxxx
		public String second_party_id_number;	//xxxx
	}
	public class CoApplicants {
	}
	public class esbtrDetails {
		public String district;	//xxxx
		public String sub_registrar_office;	//xxxx
		public PropertyAddress property_address;
		public String property_area;	//xxxx
		public String property_area_unit;	//xxxx
	}
	public class PropertyAddress {
		public String addressline_1;	//xxxx:
		public String road;	//xxxx
		public String town_village;	//xxxx
		public String district;	//xxxx
		public String state;	//xxxx
		public String pincode;	//xxxx
	}
	

}