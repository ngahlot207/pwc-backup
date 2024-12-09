public class EmailNotificationResponseWrapper {
	
    public List<Data> Data;
    public Integer Status; 			//1
    public string Message;			//Success
    public class Data{
        public string ReferenceID; 	//189338
    }
    
    public static EmailNotificationResponseWrapper parse(String json){
        return (EmailNotificationResponseWrapper) System.JSON.deserialize(json, EmailNotificationResponseWrapper.class);
    }
}