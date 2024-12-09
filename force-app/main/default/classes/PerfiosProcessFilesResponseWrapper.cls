public class PerfiosProcessFilesResponseWrapper {
	
    public BankStatement bankStatement;
	public class BankStatement {
		public List<BankAccounts> bankAccounts;
	}
	public class BankAccounts {
		public String accountId;	//fec4b3f2fd9fec90e03de0f564a34c37417df2af
		public String accountNumber;	//XXXXXXXXXXXX0297
		public String accountType;	//Current
		public boolean complete;
		public Integer institutionId;	//30
		public List<String> missingMonths;//"2023-06"
	}
	public class MissingMonths {
	}
    
    
    public Error error;
	public class Error {
		public String code;	//CannotProcessFile
		public String message;	//We could not process the statement file uploaded by the Client
		public List<Details> details;
	}
	public class Details {
		public String code;	//E_STATEMENT_WRONG_FORMAT
		public String field;
		public String message;	//This statement contains images. Please upload again and select scanned images option.
		public String value;
	}
	
	public static PerfiosProcessFilesResponseWrapper parse(String json){
		return (PerfiosProcessFilesResponseWrapper) System.JSON.deserialize(json, PerfiosProcessFilesResponseWrapper.class);
	}
    
}