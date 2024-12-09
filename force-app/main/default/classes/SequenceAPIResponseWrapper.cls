public class SequenceAPIResponseWrapper {
    Public String requestId;
    Public String status;
    Public String appId;
    Public String applicantType;
    Public string responseDateTime;
    public string errorDescription;
    
    public Static SequenceAPIResponseWrapper praser(String json){
        return (SequenceAPIResponseWrapper) system.JSON.deserialize(json,SequenceAPIResponseWrapper.class);
    }

}