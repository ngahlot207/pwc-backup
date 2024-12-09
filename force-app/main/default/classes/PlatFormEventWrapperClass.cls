public class PlatFormEventWrapperClass {
    
    public String Status{get; set;}
    public String ServiceName{get; set;}
    public String loanAppId{get; set;}
    public String appId{get; set;}
    
    public static PlatFormEventWrapperClass parse(String json) {
        return (PlatFormEventWrapperClass) System.JSON.deserialize(json, PlatFormEventWrapperClass.class );
    }
}