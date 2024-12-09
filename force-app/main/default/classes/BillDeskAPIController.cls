public class BillDeskAPIController {
	
    public static IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('BillDesk');
    public static String getEncryptedPayload(String payload) {
        string encryptedPayload = getbase64EncodeJWSHeader() + '.' + getbase64EncodeJWSPayload(payload) + '.' + generateSignature(payload);
        return encryptedPayload;
    }
    
    public static string generateSignature(String payload) {
        String secretKey = svc.PrivateKey__c!=null ? svc.PrivateKey__c : '';
        String signingData = getbase64EncodeJWSHeader() + '.' + getbase64EncodeJWSPayload(payload);
        String signature = generateHmacSHA256Signature(signingData, secretKey);
        System.debug('Signature : ' + signature);
        return signature;
    }

    private static String generateHmacSHA256Signature(String input, String secretKey) {
        String algorithmName = svc.AlgorithmName__c!=null ? svc.AlgorithmName__c : '';
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(input), Blob.valueOf(secretKey));
        return EncodingUtil.base64Encode(hmacData);
    }
    
    public static string getbase64EncodeString(Blob input){
        return EncodingUtil.base64Encode(input);
    }
    
    public static string getbase64EncodeJWSHeader(){
        return getbase64EncodeString(Blob.valueOf(getJWSHeader()));
    }
    
    public static string getbase64EncodeJWSPayload(String payload){
        return getbase64EncodeString(Blob.valueOf(payload));
    }
    
    public static string getbase64DecodeResponse(string payload){
        
        String base64DecodeResponse;
        if(String.isNotBlank(payload)){
            List<String> response =payload.split('\\.');
            if(response!=null && response.size()>=2 && response[1]!=null){
                base64DecodeResponse= EncodingUtil.base64Decode(response[1]).tostring();
            }
        }
        return base64DecodeResponse;
    }
    
    public static string getJWSHeader(){
        JWSHeaderWrapper jwsHeader = new JWSHeaderWrapper();
        jwsHeader.alg = svc.OperationFlag__c!=null ? svc.OperationFlag__c : '';
        jwsHeader.clientid = svc.ApplicationId__c!=null ? svc.ApplicationId__c : '';
        
        return JSON.serialize(jwsHeader);
    }
     
    public Class RequestWrapper{
        public Map<String,String> Header;
        public String encrypted_Payload;
        
    }
    
    public Class JWSHeaderWrapper{
        public String alg; //HS256
        public String clientid; //mercclientid
    }
    
    public static String getepochTime(DateTime dateTimevalue){
        return dateTimevalue!=null ? String.valueOf(dateTimevalue.getTime()/1000) : null;
    }
    
}