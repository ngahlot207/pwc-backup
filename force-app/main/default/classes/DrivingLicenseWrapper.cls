public class DrivingLicenseWrapper {

    public String requestId;    
    public cls_result result;
    public Integer statusCode;  
    public class cls_result {
        public String issueDate; 
        public String father;   
        public String name; 
        public String bloodGroup;   
        public String img;
        public String dob;  
        public String dlNumber; 
        public cls_validity validity;
        public cls_covDetails[] covDetails;
        public cls_address[] address;
        public String status;   
        public cls_statusDetails statusDetails;
        public cls_endorsementAndHazardousDetails endorsementAndHazardousDetails;
    }
    public class cls_validity {
        public String nonTransport; 
        public String transport;    
    }
    public class cls_covDetails {
        public String cov;  
        public String issueDate;    
    }
    public class cls_address {
        public String addressLine1; 
        public String state;    
        public String district; 
        public Integer pin; 
        public String completeAddress;  
        public String country;  
        public String type; 
    }
    public class cls_statusDetails {
        public String fromm;    
        public String to;   
        public String remarks;  
    }
    public class cls_endorsementAndHazardousDetails {
        public String initialIssuingOffice; 
        public String lastEndorsementDate;  
        public String lastEndorsedOffice;   
        public String endorsementReason;    
        public String hazardousValidTill;   
        public String hillValidTill;
    }
    public static DrivingLicenseWrapper parse(String json) {
        return (DrivingLicenseWrapper) System.JSON.deserialize(json, DrivingLicenseWrapper.class );
    }
}