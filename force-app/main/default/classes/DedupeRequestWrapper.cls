public class DedupeRequestWrapper {
	
    public String aadharNumber;	//********4071
	public String passportno;	//
	public String ckycid;	//
	public String gender;	//F
	public String panno;	//CAQPP1734C
	public String emailId;	//
	public String mothermiddlename;	//
	public String motherlastname;	//
	public String customerMiddleName;	//
	public String motherfirstname;	//SEEMA
	public String customerLastName;	//
	public String id;	//
	public String dateofbirth;	//02-06-1988
	public String pincode;	//411036
	public String address1;	//house no 36 Pradhan Niwas Sambhaji chawk nr Sambaji chawk Keshav nagar mundhwa pune
	public String primarymobileno;	//9767817732
	public String drivinglicenseid;	//
	public String husbandorfathermiddlename;	//
	public String husbandorfatherlastname;	//
	public String voteridno;	//
	public String customerFirstName;	//VARSHA RAMESH PRADHAN
	public String appid;	//900946
	public String husbandorfatherfirstname;	//RAMESH JEENAR PRADHAN
	public String customerid;	//
	public String secondarymobileno;	//
	public String city;	//Mundhva AV P.O.
	public String uniqueRefNumber;	//638130950526839117
	public String source;	//LCODE
    public String constitution;
	
    public static DedupeRequestWrapper parse(String json){
		return (DedupeRequestWrapper) System.JSON.deserialize(json, DedupeRequestWrapper.class);
	}

}