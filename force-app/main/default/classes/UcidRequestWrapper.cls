public class UcidRequestWrapper {

	public String aadharNumber;
	public String passportno;
	public String ckycid;
	public String gender;
	public String panno;
	public String emailId;
	public String mothermiddlename;
	public String motherlastname;
	public String customerMiddleName;
	public String motherfirstname;
	public String customerLastName;
	public String id;
	public String dateofbirth;
	public String pincode;
	public String address1;
	public String primarymobileno;
	public String drivinglicenseid;
	public String husbandorfathermiddlename;
	public String husbandorfatherlastname;
	public String voteridno;
	public String customerFirstName;
	public String appid;
	public String husbandorfatherfirstname;
	public String customerid;
	public String secondarymobileno;
	public String city;
	public String uniqueRefNumber;
	public String source;

	public static UcidRequestWrapper parse(String json) {
        return (UcidRequestWrapper) System.JSON.deserialize(json, UcidRequestWrapper.class );
    }

}