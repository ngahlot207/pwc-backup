public class AadharVaultResponseWrapper {
    public Response RESPONSE;
    public class Response{
        public string STATUS;
        public string UUID;
        public string ERRORMSG;
        
        
    }
    
    public static AadharVaultResponseWrapper parser(string json){
        return (AadharVaultResponseWrapper) System.JSON.deserialize(json, AadharVaultResponseWrapper.class);
    }

}