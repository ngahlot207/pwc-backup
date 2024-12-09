public class OCRVoterIdWrapperClass{
	public String consent;
	public String epicNo;
	public ClientData clientData;

	public class ClientData {
		public String caseId;
	}

	
	public static OCRVoterIdWrapperClass parse(String json) {
		return (OCRVoterIdWrapperClass) System.JSON.deserialize(json, OCRVoterIdWrapperClass.class);
	}

    }