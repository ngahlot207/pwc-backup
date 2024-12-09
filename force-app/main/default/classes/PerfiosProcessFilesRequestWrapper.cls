public class PerfiosProcessFilesRequestWrapper {

    public Payload payload;
	public class Payload {
		public String fileId;	//09133d7543de5df7f610ec28c1a334d39f61306c
        //public String institutionId; //22
		public String password;	//topSecret!
	}
	public static PerfiosProcessFilesRequestWrapper parse(String json){
		return (PerfiosProcessFilesRequestWrapper) System.JSON.deserialize(json, PerfiosProcessFilesRequestWrapper.class);
	}

}