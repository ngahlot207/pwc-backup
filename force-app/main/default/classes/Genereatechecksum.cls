public class Genereatechecksum {
    
    
    public static void genereatechecksum()
    {
        String apiKey = 'M@SObVs5FXw6dlLJ';
        PaytmChecksum paytmChecksum = new PaytmChecksum();
        
        String params = '{"mid":"FEDBAN72272366692608","linkType":"FIXED","amount":"100.00","linkDescription":"Test Payment","linkName":"Test"}';

        system.debug('paramsssssssss'+params);
        String signature = PaytmChecksum.generateSignature(params, apiKey);
        System.debug('Generated Signature: ' + signature);
        
        Boolean verify = PaytmChecksum.verifySignature(params, apiKey, signature);
        if (verify) {
            System.debug('Signature is valid.');
        } else {
            System.debug('Signature is NOT valid.');
        }
        
    }
  

}