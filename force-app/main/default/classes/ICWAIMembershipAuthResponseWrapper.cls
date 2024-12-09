public class ICWAIMembershipAuthResponseWrapper {
	
    public Integer statuscode;	//101
	public String request_id;	//73cdbde2-80f7-11e7-8f0c-e7e769f70bd1
	public cls_result result;
	public cls_clientData clientData;
	class cls_result {
		public String MemshipDt;	//18/12/1994
		public String Chapter;	//W.I.R.C. OF ICWAI
		public String Retired;	//N
		public String dob;	//21/10/1957
		public String Mname;	//
		public String ProtFirmName;	//Richard Correa & Co.
		public String ValidUpDt;	//31/03/2017
		public String MemCategory;	//F
		public String Fname;	//Richard
		public String gender;	//M
		public String SrName;	//Correa
		public String EffectiveDt;	//01/06/1998
		public String MemRegion;	//WESTERN
		public String CrtEmployer;	//
		public String FirmEftDt;	//
		public String CancellationDt;	//
	}
	class cls_clientData {
		public String caseId;	//123456
	}
	public static ICWAIMembershipAuthResponseWrapper parse(String json){
		return (ICWAIMembershipAuthResponseWrapper) System.JSON.deserialize(json, ICWAIMembershipAuthResponseWrapper.class);
	}
}