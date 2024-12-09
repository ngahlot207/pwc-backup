public with sharing class SecurityDel {
    
    /*
key length depends of ALGORITHM_NAME! 
In case, it uses AES128 so we need to use 16 bytes key.
*/	/*
  
    public static final String MY_KEY = 'MIIE7jCCAtagAwIBAgIIWmFBujLqylAwDQYJKoZIhvcNAQEMBQAwFTETMBEGA1UEAwwKcnNhX2Fw'+
        'aWtleTAeFw0xODEwMzAwNDQ3MThaFw0yMzEwMjkwNDQ3MThaMBUxEzARBgNVBAMMCnJzYV9hcGlr'+
        'ZXkwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCwjBVK1CLppIwsFm7e+Fp85Hk1Mw2n'+
        '5Nc/DKT/pWhpJB8OdlpJA9iF23hrxfbXkrBfCkgvV4Ek4fY1byOnkA7hZq4dYTASCAm89oLwWDNm'+
        '0OGNh7E6T7/JoNtjtT0Gh8lJTvpUgHFGg3tiYCScAqul+fS6Rc8+5THk3L9zLzme6eqjkzwBx/ZV'+
        'XBIZlAwFkVKbfLFg51LiVoOUz6zXD7nAsMyNhKAgybvqulV07eGzafZ1IBgzpcw5qo0PAd1mTqfy'+
        'U+CK9hVeNPPspT16qQWd5xa+fa6BEjuGCumVnFLTbSTRAF5h3QAfvMlkpLdejlXJwvTVQ79Zg5C8'+
        'Hu/yWB7tOJBncIKue7KSpwn+vkMws79wpAB5mL4tD3kVCDf2Og7wbtt87v5rcazxF7eZFbsADzHV'+
        'oSftdkw5S7iXgh82/CHbRXhzPfG8Zd2v1ksW+Bfnn3czEIMGOSJrKfMbyCYtVMihoi0/L6SHA7++'+
        'N9aRrQvfK9PeXnlHgf8pErGUdpjnwdV0tu5atSgf/iBuRgVgUL6t6MFbnBsTQUmZYiQRcsqxOVdy'+
        'yfp4DOLgFHGJ1D/isgR/ypalIXMmhuK8GdZ7hukEDX2Dc3js8OkPnFLq6Ps4NIGESfbZSeyINoZX'+
        '5GGxdgD/GpokKMHr5bsI3TQujCvzuxShPhUArzCs6TgPmwIDAQABo0IwQDAdBgNVHQ4EFgQUyNoW'+
        'eeLVSzVybz7gcZnZlj01cv4wHwYDVR0jBBgwFoAUyNoWeeLVSzVybz7gcZnZlj01cv4wDQYJKoZI'+
        'hvcNAQEMBQADggIBADuwEh31OI66oSMB6a79Pd6WSqiyD2NBskdRF7st7CRP5vqeH4P/4srNFAqC'+
        '9CjsOmXmSpZFckYQ4zgtqnVQBY7jQlCuSHmg8/Lr1qIzRsMvQmhvp6DJ+bEfQgqcJ+a6tR9cH6hD'+
        'VahoMZDEpt3J0fIp30z+O7wJ03K6q5Di/rNey6Ac3GoZwlCi8OFCTmwihcn56I+ssxAqzlq53hzO'+
        'iBLLmcMTrWSJWePPkYEhrbBxywg1qJRRGWwkfr1dbRZ22umLHU0R/QdK+jQtqyzghqJpd3T/lHzK'+
        'uzAsa0s1R+qMqurKu6mulcLp/XmZpY+Fm4T0WRXzcZBf9trkCSO2Z3VvkCTeGu/WAi3UQpx4HfGr'+
        'x02m/h8CHCPPO+PKYthpvSR+0jmiVBaaBo029UG0i2oYBTckng2sy0fx0E+rHnR7pk5Worv8BMm5'+
        'sewPUkDDJMZhLtm/bd/VxlI/b56vEA7HvupSWzc7xXV8lZOHVEUAotrlXz+Je2MkEEQIDnYUOYhw'+
        '78yFMJJddK9tJVRy8tr8I2j6Zi62jQp/Zltq5JOwpOw/9poovd9wgeRBjuFnscoR/YWrNdPjsjpJ'+
        'g/CCb6mthz4R2Mu4enD1YghW7w5darrlUHaYAk+SnwWhMwDwZWWfrVNeEaNq/t/gRm/Ljy+Of3lA'+
        'nztA1PrT4bk1KvZX'; 
  */
    public static final String MY_KEY ='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';  
    public static final String MY_IV = '1234567890123456'; //it always will be 16 bytes
    public static final String ALGORITHM_NAME = 'AES128';
    
    public static Blob encrypt(String valueToEncrypt){
        Blob key = Blob.valueOf(MY_KEY);
        Blob iv = Blob.valueOf(MY_IV);
        //
        //EncodingUtil.base64Decode()
        //
        Blob data = Blob.valueOf(valueToEncrypt);
       // return Crypto.encrypt(ALGORITHM_NAME, key, iv, data);
        //Blob encryptedData = Crypto.encryptWithManagedIV('AES256', key, data);
        return Crypto.encryptWithManagedIV('AES256', key, data);
        
    }
    
    
    
    
    
    
    public static Blob decrypt(Blob encryptedData){
        Blob key = Blob.valueOf(MY_KEY);
        Blob iv = Blob.valueOf(MY_IV);
        return Crypto.decrypt(ALGORITHM_NAME, key, iv, encryptedData);
    }
    
}