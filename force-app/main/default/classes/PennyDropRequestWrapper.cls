public class PennyDropRequestWrapper {
	
    public String user;	//pennyweb
	public String password;	//zqbAx8rZ0LvWMftg38eTatwjEANYAo/6
	public String requestId;	//jyJUpRC8EaIan7WI5QtYv011
	public String applicationId;	//586144
	public String sourceId;	//SFDC
	public String chequeStatus;	//S
	public String inFavourOf;	//AJIT
	public String productFlag;	//LAP
	public String schemeId;	//540
	public String branch;	//5
	public String ftMode;	//IM
	public String modeOfPayment;	//F
	public String receiptAmount;	//1
	public String receiptChannel;	//FEDBANK
	public String dealingBank;	//497
	public String drawnOn;	//485
	public String imdFlag;	//P
	public String bpType;	//LS
	public String bpId;	//
	public String receiptDate;	//02-OCT-2022
	public String chequeDate;	//01-OCT-2022
	public String utrNo;	//3526654646
	public String receiptNo;	//23155
	public String imdCustom2;	//Saurabh Rai
	public String imdCustom3;	//Saurabh Rai
	public String imdCustom4;	//FDRL0001001
	public String imdCustom5;	//10010200015128
	public String imdCustom6;	//Penny Drop Description
	public static PennyDropRequestWrapper parse(String json){
		return (PennyDropRequestWrapper) System.JSON.deserialize(json, PennyDropRequestWrapper.class);
	}
}