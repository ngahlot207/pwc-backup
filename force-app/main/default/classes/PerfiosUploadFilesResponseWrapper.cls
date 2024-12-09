public class PerfiosUploadFilesResponseWrapper {
	public File file;
	public class File {
		public String fileId;	//a630965628c9f551d12b14cb365cf77e264cd91d
	}
    
    public Error error;
	public class Error {
		public String code;	//BadParameter
		public String message;	//Signature is required but missing
	}
    
    public static PerfiosUploadFilesResponseWrapper parse(String json) {
        return (PerfiosUploadFilesResponseWrapper) System.JSON.deserialize(json, PerfiosUploadFilesResponseWrapper.class );
    }
}