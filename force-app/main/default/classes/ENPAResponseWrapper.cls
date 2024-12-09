public class ENPAResponseWrapper {
	public List<Data> Data;
	public Integer status;	//1
	public String message;	//Success
	public class Data {
		public String CustomerID;	//891524
		public String LAN;	//FEDGL03940004822
		public String UCIC;	//12784057
		public String CustomerName;	//ANAND BABURAO RATHOD
		public String AUM;	//201800.00
		public String AUF;	//201800.00
		public String DisbursementDate;	//2022-09-05
        public String DPD;	//0
		public String NPA_DATE;
        public String Product;	//Lcode
		public String SecuritizationFlg;	//N
		public String Tenure;	//
		public String LINKED_UCIC;	//Linked-12784057
		public String FinalAssetClass;	//STD
		public String TotalProvisionWithoutVarAmount;	//809.89
		public String TotalProvisionWithVarAmount;	//809.89
		public String LoanAmount;	//201800.0
        public String UCID_Level_DPD;

		//New Fields
		public String FRAUD_FLAG;	//External 
		public String Writeoff_Flag;	 // Y
		public String Writeoff_Date;	 //30-SEP-2024
        public String Settled; // Y
		public String Settled_Date; //30-SEP-2024

	}
	
	public static ENPAResponseWrapper parse(String json){
		return (ENPAResponseWrapper) System.JSON.deserialize(json, ENPAResponseWrapper.class);
	}
}