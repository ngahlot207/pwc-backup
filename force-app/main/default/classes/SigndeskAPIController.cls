public class SigndeskAPIController {
    private static IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('SFDC_Aadhar_XML_Verification_API');
    public class EncryptedResponse{
        public string status;
        public string encrypted_response;  
        public string ErrorCode;
		public string ErrorMsg;
    }
    
    public class EncryptedRequest{
        public string enc_mode;
        public string symmetric_mode;
        public string api_data;
        public boolean is_encrypted;
       
    }
    
    public static String getEncryptedRequest(String request){
        Blob key = Blob.valueof(svc.PrivateKey__c);//'InpEW75s9taLul1YsNKso5KkHYjRtxzN'
        Blob data = Blob.valueOf(request);
        Blob encrypted = Crypto.encryptWithManagedIV('AES256', key, data);
        string encryptedData = EncodingUtil.base64Encode (encrypted);
        EncryptedRequest encryptedRequest = new EncryptedRequest();
        encryptedRequest.enc_mode='symmetric';
        encryptedRequest.symmetric_mode='cbc';
        encryptedRequest.api_data=encryptedData;
        encryptedRequest.is_encrypted=true;
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