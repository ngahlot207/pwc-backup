public class WorkAppCommonReqWrapper {
    
    public static IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Guest_Call');
    
    public Class RequestWrapper{
        public Map<String,String> Header;
        public String Payload;
    }
    
    public static String getepochTime(DateTime dateTimevalue){
        return dateTimevalue!=null ? String.valueOf(dateTimevalue.getTime()/1000) : null;
    }
    
    public class WorkappPDPostRequestWrapper{
    //POST
    public Integer entityId;	 
    public Integer productType;	 
    public String firstName;	  
    public String mobileNumber;	  
    public String countryCode;	 
    public String email;	
    public String statusUrl;	 
    public Integer useCase;	 
    public List<Data> data;
    public String userPhoto;	 
    public String employeeId;
    
   // Constructor to initialize nested list
   public WorkappPDPostRequestWrapper() {
    this.data = new List<Data>(); // Initialize 'data' list to avoid null pointer errors
   }
    
   
}

public class Data {
    public String key;
    public String value;
    
    public Data(String key, String value) {
        this.key = key;
        this.value = value;
    }

    public Data(){
        
    }
}

public static String getSignature(String path, String apiSecret) {
    String signature = null;
    // Use `Crypto` class for HMAC-SHA256 hashing in Apex.
    Blob hmac256 = Crypto.generateMac('HmacSHA256', Blob.valueOf(path), Blob.valueOf(apiSecret));
    // Convert the resulting hash to Base64 encoded string.
    signature = EncodingUtil.base64Encode(hmac256);
    return signature;
}

public static String getSignByMainLogic(Long passedDateTime) {

    String apiKey = svc.APIKey__c; //'cb8fedb939fe11ef9b7b0267c6221b81';
    String apiSecret = svc.APIToken__c ; //'LIGTiBlCBXQMSAhIaVmQWZZQBSFRSnVdfKYeDbkIIkPYOimdOQ';
    String apiTimePair = apiKey + ':' + String.valueOf(passedDateTime);
    System.debug('apiTimePair = ' + apiTimePair);
    String signature = getSignature(apiTimePair, apiSecret);
    System.debug('signature: ' + signature);
    return signature;
    
}

}