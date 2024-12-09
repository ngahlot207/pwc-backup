public class PaytmChecksum {
    private IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Paytm');
    //private String iv = '@@@@&&&&####$$$$';
    private Integer BLOCK_SIZE = 16;

    public String encrypt(String input, String key) {
        
        Blob keyBlob = Blob.valueOf(key);
        Blob ivBlob = Blob.valueOf(svc.InitializationVector__c);
        Blob inputBlob = Blob.valueOf(input);

        // Manually generate an IV for CBC mode
        //Blob iv = Crypto.generateAesKey(128);

        Blob cipherText = Crypto.encrypt('AES128', keyBlob, ivBlob, inputBlob);
        return EncodingUtil.base64Encode(cipherText);
    }

    public String decrypt(String encrypted, String key) {
        Blob keyBlob = Blob.valueOf(key);
        Blob ivBlob = Blob.valueOf(svc.InitializationVector__c);
        Blob encryptedBlob = EncodingUtil.base64Decode(encrypted);

        Blob decryptedBlob = Crypto.decrypt('AES128', keyBlob, ivBlob, encryptedBlob);
        String decrypted = decryptedBlob.toString();
        return (decrypted);
    }


    public String generateSignature(String params, String key) {
        return generateSignatureByString(params, key);
    }

    public Boolean verifySignature(String params, String key, String checksum) {
        if (params.contains('CHECKSUMHASH')) {
            params.remove('CHECKSUMHASH');
        }
        return verifySignatureByString(params, key, checksum);
    }

    private String generateSignatureByString(String params, String key) {
        String salt = generateRandomString(4);
        return calculateChecksum(params, key, salt);
    }

    private Boolean verifySignatureByString(String params, String key, String checksum) {
        String paytmHash = decrypt(checksum, key);
        String salt = paytmHash.substring(paytmHash.length() - 4);
        return paytmHash == calculateHash(params, salt);
    }

    private String generateRandomString(Integer length) {
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randomString = '';
        for (Integer i = 0; i < length; i++) {
            Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randomString += chars.substring(randomIndex, randomIndex + 1);
        }
        return randomString;
    }
	@TestVisible
    private String getStringByParams(Map<String, String> params) {
        List<String> paramList = new List<String>();
        for (String key : new List<String>(params.keySet())) {
            String value = params.get(key);
            if (value != null && value.toLowerCase() != 'null') {
                paramList.add(value);
            }
        }
        return String.join(paramList, '|');
    }

    private String calculateHash(String params, String salt) {
        String finalString = params + '|' + salt;
        Blob hashBlob = Crypto.generateDigest('SHA-256', Blob.valueOf(finalString));
        String hashString = EncodingUtil.convertToHex(hashBlob) + salt;
        return hashString;
    }

    private String calculateChecksum(String params, String key, String salt) {
        String hashString = calculateHash(params, salt);
        return encrypt(hashString, key);
    }
}