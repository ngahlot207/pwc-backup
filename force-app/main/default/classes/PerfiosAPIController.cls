public class PerfiosAPIController {
    public static IntgSvcMgmt__mdt svc = [Select Id,Svc__c, BU__c, ApiVendor__c, IsActive__c, Domain__c, PrivateKey__c, PublicKey__c, AlgorithmName__c, URL__c, CallbackURL__c,SignedHeaders__c from IntgSvcMgmt__mdt where DeveloperName ='Perfios_Initiate_Transaction' LIMIT 1];//IntgSvcMgmt__mdt.getInstance('Perfios_Initiate_Transaction');
    //public static String privateKey ='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';
    //public static String publicKey ='MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAoU7SdpZH0OTifVU5IgCAvsbEBF6y4+iDwX6wzx4ylq49HQWA1bDLiJNRrPm8BIbbpcbEOctqUtshKN+YYGtdfC0HS3Om5vHzUcaJCCbFNdqzSj01ta/C+bHYBcKUqDN5JQ0h4jspiw2MFlUUwdIFiP7ahbB51YoC9DWejr+ZCmaY9oP9Pw+oQ+FuJf+fxq8kf2GjHZ+d9ampUDN/11rRucM4wZrMJxK+WpjwTILxJltvy4U4ffBYdbA6ZBFhPEXBYkMO+FjMJuxfA3675JJLVuAUl5Ey6IZPJsOl96WQSV485ADyL3zn/jmfZTVkGySLPU1JPOKKyBQiyja+6Jr9/XfLt6GJMoun1cUxa3v7HYdSNo+n8FFaPjh52HlituICfv+qa9t7T0Suu8vjG4gsQVMrIglhbd5MAg8cwTSIL5m52EbwojUtvxxpLz2XzG73/ppibwLQ1APvY3+QFnIc2gY8umnG7TWGK5CDOgHZP7yXHc0oYznygX2vXd1T9Qmi0leSm7h7b9c6Aee3mWlcp11JcDj9Fk8M6aczYHzC+1rmffnCd21OJ1vJhmvWyWaKvaKGRKaSjJEhUN4Q3xXlhU8vggQhdNIq/O6dKWoTzmiZrSnkimLK3RsVXsjeBzJA9VgV89aLv74XX6Ip7rL78MZ8Qv0rGokSZPHSgj5tcPMCAwEAAQ==';
    public static String privateKey = svc.PrivateKey__c;
    public static String publicKey = svc.PublicKey__c;
    public static String signedHeaders = svc.SignedHeaders__c;
    /*public static String privateKey = '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\r\n';*/
    
    public static final String BOUNDARY = '----FormBoundary4Amf13kZd';
    public static final String EXTRABOUNDARY = '--' + BOUNDARY;
    
    public static String Host = svc.Domain__c;//'demo.perfios.com'; 
    public static String perfiosAlgorithmName = svc.AlgorithmName__c;	
    public static String getSHA256Content(String data){
        
        Blob targetBlob = Blob.valueOf(data);
        Blob payloadhash = Crypto.generateDigest('SHA-256', targetBlob);
        String result = EncodingUtil.convertToHex(payloadhash);//.toLowerCase();
        return result;
    }
    
    public static String generateSignature(String method, String url, String urlQuery,String payload, String requestDate) {
        system.debug('::::::'+payload);
        System.debug(':::'+privatekey);
        String sha256Payload=getSHA256Content(Payload);
        String headers = 'host:'+Host+'\n' 
            + 'x-perfios-content-sha256:'+sha256Payload+'\n'
            + 'x-perfios-date:'+requestDate+ '\n'
            + signedHeaders;
        system.debug('Request Date:\n' + requestDate);
        system.debug('sha256Payload:\n'+ sha256Payload);
        
        
        //Creating a Conanical Request
        String CanonicalRequest=method+'\n'
            + url+'\n'
            + urlQuery+'\n'
            + headers+'\n' 
            + sha256Payload;
        System.debug('CanonicalRequest:\n'+CanonicalRequest);
        System.debug('CanonicalRequestSHA256:\n'+getSHA256Content(CanonicalRequest));
        
        //Creating a String to sign using Conanical Request
        String StringToSign = perfiosAlgorithmName + '\n'
            + requestDate + '\n'
            + getSHA256Content(CanonicalRequest);
        System.debug('StringToSign:\n'+StringToSign);
        
        
        //Create a checksum using String to sign
        String Checksum=getSHA256Content(StringToSign);
        System.debug('Checksum:\n'+Checksum);
        
        //Encryption the String to sign using RSA private key
        String algorithmName = 'RSA-SHA256';
        Blob key = EncodingUtil.base64Decode(privateKey); //Blob.valueOf(privateKey);
        Blob input = Blob.valueOf(checksum);//EncodingUtil.convertFromHex(checksum);//Blob.valueOf(checksum);//EncodingUtil.convertFromHex(checksum);
        Blob sign = Crypto.sign(algorithmName, input, key);
        String Signature =EncodingUtil.convertToHex(sign).toLowerCase();
        
        system.debug('Signature: '+ Signature);
        return Signature;
        
    }
    
    public static string GetContentType() {
        return 'multipart/form-data; boundary=' + BOUNDARY;
        
    }
    
    public static Blob multiPartFormDataBody(Blob file, String contentType, String filename, Map<String, String> metadataMap) {
        contentType = contentType == '' ? 'application/octet-stream' : contentType;
        String bodyStartHex = EncodingUtil.convertToHex(Blob.valueOf(EXTRABOUNDARY + '\r\nContent-Disposition: form-data; name=\"file\"; filename="' + filename + '"\r\nContent-Type: ' + contentType + '\r\n\r\n'));
        String bodyEndHex = EncodingUtil.convertToHex(Blob.valueOf(EXTRABOUNDARY + '--\r\n'));
        
        bodyStartHex += EncodingUtil.convertToHex(file);
        if (metadataMap != null && metadataMap.size() != 0) {
            String formElements = '\r\n';
            for (String key : metadataMap.keySet()) {
                formElements += EXTRABOUNDARY + '\r\nContent-Disposition: form-data; name=\"' + key + '\"\r\n\r\n' + metadataMap.get(key) + '\r\n';
            }
            bodyStartHex += EncodingUtil.convertToHex(Blob.valueOf(formElements));
        } else {
            bodyEndHex = EncodingUtil.convertToHex(Blob.valueOf('\r\n' + EXTRABOUNDARY + '--'));
        }
        return EncodingUtil.convertFromHex(bodyStartHex + bodyEndHex);
    }
    
    public static string replaceAndUpdateString(String toRemove, String toAdd,String actualString,String splitIdentifier){
        String updatedString;
        List<String> updatedStringList = new List<String>();
        if(String.isNotBlank(actualString)){
            List<String> existingStringList = actualString.split(splitIdentifier);
            system.debug(existingStringList);
            if(!existingStringList.isEmpty()){
                for(string value : existingStringList){
                    if(!value.contains(toRemove)){
                        updatedStringList.add(value);
                    }
                }
            }
        }	
        if(String.isNotBlank(toAdd)){
            updatedStringList.add(toAdd);
        }
        
        updatedString= String.join(updatedStringList,splitIdentifier).removeStart(splitIdentifier).removeEnd(splitIdentifier);
        system.debug(updatedString);
        return updatedString; 
    }
    
    public Class RequestWrapper{
        public Header Header;
        public Object Payload;
        
    } 
    public class Header {
        public String transactionID;
        public String fileId;
        public String sha256Content;
        public String perfiosAlgorithm; //PERFIOS1-RSA-SHA256
        public String perfioRequestDate;
        public String perfioSignature;
        public String perfiosSignedHeaders;	//host;x-perfios-content-sha256;x-perfios-date
        public String reportTypes;
    }    
    
}