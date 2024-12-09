public class UcidResponseWrapper {
   public cls_negativeList[] negativeList;
	public Integer code;	//200
	public String requestId;	//e0a2a8e7-a1db-49d9-8eb7-9d3339fc71ad
	public String success;	//true
	public cls_customers[] customers;
	public String message;	//Record matched successfully
    public String msg;
	public String ucid;	//13006101
	class cls_negativeList {
	}
	class cls_customers {
		public String passportno;	//
		public String ckycid;	//
		public String constitution;	//
		public String gender;	//F
		public String city;	//
		public String panno;	//12324567890
		public String emailId;	//
		public String source;	//LCODE
		public String mothermiddlename;	//
		public String motherlastname;	//
		public String customerMiddleName;	//
		public String motherfirstname;	//SEEMA
		public Long id;	//1699850805774260000
		public String uniqueRefNumber;	//12345876541
		public String dateofbirth;	//
		public String pincode;	//411036
		public String risk_category;	//
		public String primarymobileno;	//
		public String address1;	//
		public String customerLastname;	//
		public String drivinglicenseid;	//
		public String husbandorfathermiddlename;	//
		public String husbandorfatherlastname;	//
		public String aadharNumber;	//
		public String voteridno;	//
		public String customerFirstName;	//Test
		public String husbandorfatherfirstname;	//Test
		public String appid;	//1234
		public String customerid;	//
		public String secondarymobileno;	//
	}
	public static UcidResponseWrapper parse(String json){
		return (UcidResponseWrapper) System.JSON.deserialize(json, UcidResponseWrapper.class);
	}

}