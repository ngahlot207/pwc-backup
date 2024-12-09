public class SequenceAPIRequestWrapper {
    
    Public String requestId;
    Public String sourceId;
    Public String errorDesc;
    Public String user;
    Public string password;
    public string applicantType;
    
    public Static SequenceAPIRequestWrapper praser(String json){
        return (SequenceAPIRequestWrapper) system.JSON.deserialize(json,SequenceAPIRequestWrapper.class);
    }

}