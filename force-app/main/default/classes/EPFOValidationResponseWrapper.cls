public class EPFOValidationResponseWrapper {
    
    public string requestId;
    public integer statusCode;
    public string error;
    public Result result;
    public ClientData clientData;
    
    
    public class Result{
        Public List<Employers> employers;
        Public PersonalDetails personalDetails;
        Public Summary summary;
        Public String remark;
    }
    
    public class Employers{
        
        public string startMonthYear;
        public string lastMonthYear;
        public string establishmentId;
        public string establishmentName;
        public string memberId;
        public string exitReason;
        public string status;
        public Address address;
    }
    
    public class Address{
        public string city;
        public string state;
        public string pincode;
        public string district;
        public string address;
    }
    
    public class PersonalDetails{
        Public String name;
        Public String fatherOrHusbandName;
        Public String aadhaarVerificationStatus;
        Public String bankAccountStatus;
        Public String panVerificationStatus;
        Public String contactNo;
    }
    
    public class Summary{
        Public Integer minimumWorkExperienceInMonths;
        Public LastEmployer lastEmployer;
    }
    
    public class LastEmployer{
        Public String employerName;
        Public String startMonthYear;
        Public String lastMonthYear;
        Public Integer vintageInMonths;
    }
    public class ClientData{
        public string caseId;
    }
    
}