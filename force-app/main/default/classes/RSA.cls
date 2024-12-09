public class RSA {

    private Key key;
    // Hex digits
    private static final String DIGITS = '0123456789abcdef';
    private static final Decimal HEX_BASE = 16;

    public abstract class Key {
        private String modulus;
        public Key(String modulus) {
            this.modulus = modulus;
        }
    }
    
    public virtual class PublicKey extends Key {
        private String exponent;
        public PublicKey(String modulus, String exponent) {
            super(modulus);
            this.exponent = exponent;
        }
    }
    
    public class PrivateKey extends PublicKey {
        private String privateExponent;
        public PrivateKey(String modulus, String privateExponent) {
            super(modulus, null);
            this.privateExponent = privateExponent;
        }
        
        public PrivateKey(String modulus, String exponent, String privateExponent) {
            super(modulus, exponent);
            this.privateExponent = privateExponent;
        }
    }
    
    
    public RSA(Key key) {
        this.key = key;
    }
    
    public String encrypt(String input) {
        PublicKey publicKey = (PublicKey)this.key;
        return modPow(input, publicKey.modulus, publicKey.exponent);
    }
    
    public String decrypt(String input) {
        PrivateKey privateKey = (PrivateKey)this.key;
        return modPow(input, privateKey.modulus, privateKey.privateExponent);
    }
    
    public String modPow(String input, String modulus, String exponent) {
        
        Blob mod = EncodingUtil.base64Decode(modulus);
        Blob exp = EncodingUtil.base64Decode(exponent);

        // Pad password.nonce
        Blob pn = Blob.valueOf(String.fromCharArray(pkcs1Pad2(input, mod.size() - 1)));

        Decimal modDec = hexToDecimal(EncodingUtil.convertToHex(mod));
        Decimal expDec = hexToDecimal(EncodingUtil.convertToHex(exp));
        Decimal pnDec = hexToDecimal(EncodingUtil.convertToHex(pn));

        // Calcluate padded^exp % mod and convert to hex
        Decimal result = modPow(pnDec, expDec, modDec);
        String hexResult = decimalToHex(result);
        // If length is uneven, add an extra 0
        if ((hexResult.length() & 1) == 1) {
            hexResult = '0' + hexResult;
        }

        // Generate the data to be encrypted.
        Blob encodedData = EncodingUtil.convertFromHex(hexResult);
        return EncodingUtil.base64Encode(encodedData);
    }

    @testVisible
    private static Decimal hexToDecimal(String hex) {
        Decimal result = 0;
        integer length = hex.length();
        integer i = 0;
        while(i < length) {
            integer hexByte = DIGITS.indexOf(hex.substring(i, i + 1).toLowerCase());
            i++;
            result += hexByte * HEX_BASE.pow(length - i);
        }
        return result;
    }

    @testVisible
    private static String decimalToHex(Decimal d) {
        String hex = '';
        while (d > 0) {
            Decimal digit = modulus(d, HEX_BASE); // rightmost digit
            hex = DIGITS.substring(digit.intValue(), digit.intValue() + 1) + hex; // string concatenation
            d = d.divide(16, 0, RoundingMode.FLOOR);
        }
        return hex;
    }

    // base^exp % mod
    @testVisible
    private static Decimal modPow(Decimal base, Decimal exp, Decimal mod) {
        if (base < 1 || exp < 0 || mod < 1) {
            return -1;
        }

        Decimal result = 1;
        while (exp > 0) {
           if ((exp.longValue() & 1) == 1) {
               result = modulus((result * base), mod);
           }
           base = modulus((base * base), mod);
           exp = exp.divide(2, 0, RoundingMode.FLOOR);
        }
        return result;
    }

    // dividend % divisor
    @testVisible
    private static Decimal modulus(Decimal dividend, Decimal divisor) {
        Decimal d = dividend.divide(divisor, 0, RoundingMode.FLOOR);
        return dividend - (d * divisor);
    }

    // Pad using PKCS#1 v.2. See https://en.wikipedia.org/wiki/PKCS_1
    // s = String to pad
    // n = bytes to fill must be bigger than s.length()
    @testVisible
    private static List<integer> pkcs1Pad2(String s, integer n) {
        // Byte array
        List<integer> ba = new List<integer>();
        // Fill array with zeros to get the right size
        for(integer i = 0; i < n; i++) {
            ba.add(0);
        }
        integer i = s.length() - 1;
        while(i >= 0 && n > 0) {
            ba.set(--n, s.charAt(i--));
        }
        ba.set(--n, 0);
        while(n > 2) { // random non-zero pad
            // Since the array is converted to a string, choose integers that corresponds
            // to a proper char code see http://www.asciitable.com
            integer rnd = Math.round(Math.random() * (127 - 32) + 32);
            ba.set(--n, rnd);
        }
        ba.set(--n, 2);
        ba.set(--n, 0);
        return ba;
    }

}