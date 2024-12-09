public class ChequeOCRRequestWrapper {
    
    public String fileB64;	//base64 value
    public ClientData clientData;
    
    public class ClientData {
        public String caseId;	//123456
    }
   
    public static ChequeOCRRequestWrapper parse(String json){
        return (ChequeOCRRequestWrapper) System.JSON.deserialize(json, ChequeOCRRequestWrapper.class);
    }
    
    
}