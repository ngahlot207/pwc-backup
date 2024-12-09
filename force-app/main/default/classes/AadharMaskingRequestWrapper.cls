public class AadharMaskingRequestWrapper {
    
    public string uid;
    public string slk;
    public string rrn;
    public string env;
    public string lat;
    public string lon;
    public string devid;
    public string refr;
    public string sertype;
    public string ver;
    public string txnmode;
    public string file;

    public static AadharMaskingRequestWrapper parser(string json){
        return (AadharMaskingRequestWrapper) System.JSON.deserialize(json, AadharMaskingRequestWrapper.class);
    }
}