public class ResultJson {

    public dataVal[] andList;
    
	public dataVal[] orList;
    
    public dataVal[] anyList;
    
    public String[] docTypeOrList;
    
	public class dataVal {
		public String docCategory;
		public String docType;	
		public String[] docSubType;
		public String osvRequired;	
	}
    
	public static ResultJson parse(String json){
		return (ResultJson) System.JSON.deserialize(json, ResultJson.class);
	}
}