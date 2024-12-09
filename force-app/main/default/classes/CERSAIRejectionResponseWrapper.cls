public class CERSAIRejectionResponseWrapper {
	
    public String Name;	//CERSAI Rejection Callback
	public String Status;	//New
	public boolean Inbound;
	public boolean IsActive;
	public List<Request> Req;
	public class Request {
		public String ParentCompany;	//Fedbank Financial Services
		public String SourceSystem;	//Finnone
		public String SourceSystemCustomerCode;	//1007544
		public String BranchCode;	//
		public String CustomerCode;	//2708422
		public String FirstName;	//KALPANA
		public String MiddleName;	//TULSHIRAM
		public String LastName;	//PATIL
		public String Pan;	//IDMPP0887D
		public String AadhaarNo;	//XXXXXXXX
		public String Remarks;	//
		public String RecordStatus;	//Reject
		public String ResponseType;	//
		public String IdVerificationStatus;	//
		public String FIReferenceNo;	//3177918
		public String CKYCReferenceNo;	//0
		public String CKYCNumber;	//0
		public String BatchNumber;	//10004
		public String CreateDate;	//10/Jun/2024
		public String FileName;	//IN1368_IR003_10062024_V1.2_IRA005965_U10004
		public String SourceSystemSegment;	//
		public String BirthDate;	//01/Jan/1978
		public String WorkFlowStep;	//New Upload Rejection Rectification
		public String StepAddedon;	//10/Jun/2024
		public String PermanentPin;	//425113
		public String CorrespondenceGlobalPin;	//425113
		public String SourceSystemCustomerCreationDate;	//27/May/2024
		public String POI;	//
		public String POA;	//Aadhar Card
		public String CorrespondenceAddressProof;	//Aadhar Card
		public String AppRefNumberforImages;	//FEDDHUSTL0538308
		public String PreviousStep;	//S3-Awaiting New Record upload Response from CKYC
		public String PreviousRejectionByTW;	//EC136 Aadhar Card-3177308_tulshiram patil feddhustl05383308 ckyc_TWC.jpg  image name length exceeds 50 character
		public String TrackwizzAddedOn;	//28/May/2024
		public String MobileNumber;	//9309114550
		public String PincodeAndBirthYear;	//4251131978
		public String IsMinor;	//No
		public String SourceSystemChannel;	//
    }
}