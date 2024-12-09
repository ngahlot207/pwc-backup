public class ScreeningResponseWrapper {
    
    public String Result;
    public String Message;
    public static ScreeningResponseWrapper parse(String json){
        return (ScreeningResponseWrapper) System.JSON.deserialize(json, ScreeningResponseWrapper.class);
    }
}