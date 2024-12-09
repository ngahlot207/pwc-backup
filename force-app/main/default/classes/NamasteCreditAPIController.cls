public class NamasteCreditAPIController {
	private static IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('');
    
    public class EncryptedRequest{
        public string EncryptedRequestPayload;
    }
    
    public static String getEncryptedRequest(String request){
        Blob key = Blob.valueof(svc.PrivateKey__c); // Tiwm5beODRVLmyL+TksJlw==4hsvfjai;
        Blob data = Blob.valueOf(request);
        Blob encrypted = Crypto.encryptWithManagedIV('AES256', key, data);
        string encryptedData = EncodingUtil.base64Encode (encrypted);
        EncryptedRequest encryptedRequest = new EncryptedRequest();
        encryptedRequest.EncryptedRequestPayload=encryptedData;
        return JSON.serialize(encryptedRequest);
    }
    
    public static String getDecryptedResponse(String encryptedResponse){
        Blob key = Blob.valueof(svc.PrivateKey__c);//'InpEW75s9taLul1YsNKso5KkHYjRtxzN'
        Blob data = EncodingUtil.base64Decode(encryptedResponse);
        Blob decrypted = Crypto.decryptWithManagedIV('AES256', key, data);
        String decryptedData = decrypted.toString();
        return decryptedData;
    }
}