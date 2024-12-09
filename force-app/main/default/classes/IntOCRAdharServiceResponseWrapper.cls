public class IntOCRAdharServiceResponseWrapper {
    
    public class Aadhaar {
        public String conf;
        public String isMasked;
        public String value;
    }
    
    public class Details {
        public Aadhaar aadhaar;
        public Address address;
        public AddressSplit addressSplit;
        public Data father;
        public Data husband;
        public ImageUrl imageUrl;
        public Address name;
        public Address pin;
        public ImageUrl qr;
        public QualityCheck qualityCheck;
        public Data dob;
        public Data gender;
        public Data mother;
    }
    
    public String requestId;
    public List<Result> result;
    public Integer statusCode;
    
    public class Address {
        public String conf;
        public String value;
    }
    
    public class AddressSplit {
        public String careOf;
        public String city;
        public String district;
        public String houseNumber;
        public String landmark;
        public String line1;
        public String line2;
        public String locality;
        public String pin;
        public String state;
        public String street;
    }
    
    public class ImageUrl {
        public String value;
    }
    
    public class Data {
        public String conf;
        public String value;
    }
    
    public class QualityCheck {
        public String brightness;
        public String isBlackWhite;
        public String isBlur;
        public String isCutCard;
    }
    
    public class Result {
        public Details details;
        public String type;
    }
    public static IntOCRAdharServiceResponseWrapper parse(String json) {
        return (IntOCRAdharServiceResponseWrapper) System.JSON.deserialize(json, IntOCRAdharServiceResponseWrapper.class );
    }
    
}