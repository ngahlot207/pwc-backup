public class IMDRequestWrapper {

    public String sourceId;	//SFDC
	public String reason;	//
	public String approvalCode;	//
	public String ftMode;	//OT
	public String city;	//600
	public String modeOfPayment;	//F
	public String chequeStatus;	//R
	public String inFavourOf;	//ICICI BANK LTD
	public String cashAc;	//
	public String cardCategory;	//
	public String schemeId;	//529
	public String chequeNumber;	//
	public String branch;	//4
	public String cardNo;	//
	public String expiryDate;	//
	public String receiptAmount;	//5900
	public String password;	//zqbAx8rZ0LvWMftg38eTatwjEANYAo/6
	public String receiptChannel;	//
	public String requestId;	//uwhpcUUx0ixaJpBhxGnsjx
	public String imdFlag;	//Y
	public String agency;	//
	public String bpType;	//LS
	public String cardHolderName;	//
	public String requestedForFlag;	//
	public String bpId;	//
	public String payableAt;	//
	public String receiptDate;	//06-NOV-2022
	public String imdCustom4;	//ASZPP4427B
	public String imdCustom3;	//NO:15 CUDDALORE ROAD PAVACHOOR VILLAGE MADURANTAKAM NEAR TENPLE MADHURANTHAGAM CHENNAI 603112 TAMILNADU India
	public String homeBranch;	//
	public String productFlag;	//LAP
	public String imdCustom2;	//SRI RENUKAMBAL AGENCIES
	public String transactionCode;	//1
	public String imdCustom1;	//9
	public String allocationType;	//
	public String imdCustom7;	//1002733
	public String chequeDate;	//05-NOV-2022
	public String imdCustom6;	//PURUSHOTHAMANV.PURUSHOTHV1@GMAIL.COM
	public String drawnOn;	//229
	public String imdCustom5;	//9840018858
	public String utrNo;	//21324151617
	public String chargeId;	//56
	public String receiptNo;	//
	public String dealingBank;	//11
	public String applicationId;	//586371
	public String loanNumber;	//
	public String user;	//imdweb
	
    public static IMDRequestWrapper parse(String json){
		return (IMDRequestWrapper) System.JSON.deserialize(json, IMDRequestWrapper.class);
	}
}