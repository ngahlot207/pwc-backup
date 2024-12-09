@isTest
public class PaytmChecksumTest {
	@isTest
    public static void testGetPanValiStatus(){
        /*PaytmChecksum payChec= new PaytmChecksum();
        string encSt=payChec.encrypt('Test','1234234567890987');
        system.debug('encSt'+encSt); */
        PaytmChecksum paytmChecksum = new PaytmChecksum();
        String input = 'HelloWorld';
    	String key = '1234234567890987';
    	String encryptedValue = paytmChecksum.encrypt(input, key);
    	System.assertEquals(true, !String.isEmpty(encryptedValue), 'Encryption failed');
    	String decryptedValue = paytmChecksum.decrypt(encryptedValue, key);
    	System.assertEquals(input, decryptedValue, 'Decryption failed');
    }
    @isTest
	static void testSignatureGenerationVerification() {
        PaytmChecksum paytmChecksum = new PaytmChecksum();
        String params = 'param1=value1&param2=value2';
        String key = '1234234567890987';
        String signature = paytmChecksum.generateSignature(params, key);
        System.assertEquals(true, !String.isEmpty(signature), 'Signature generation failed');
        Boolean isSignatureValid = paytmChecksum.verifySignature(params, key, signature);
        System.assertEquals(true, isSignatureValid, 'Signature verification failed');
	}
    
    @isTest
	static void testStringByParams() {
        PaytmChecksum paytmChecksum = new PaytmChecksum();
        Map<String, String> params = new Map<String, String>{
            'param1' => 'value1',
            'param2' => 'value2'
        };
        String resultString = paytmChecksum.getStringByParams(params);
        System.assertEquals('value1|value2', resultString, 'String by params failed');
	}
}