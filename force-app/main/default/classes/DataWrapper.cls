public class DataWrapper {

    public String objApiName;	
	public String recordId;	
	public cls_Fieldvalues[] fieldvalues;
	class cls_Fieldvalues {
		public String fieldApiName;	
		public String fieldValue;	
	}
    
    public static DataWrapper parse(String json){
		return (DataWrapper) System.JSON.deserialize(json, DataWrapper.class);
	}
}