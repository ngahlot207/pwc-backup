public class ScreeningRequestWrapper {
    public ScreeningRequestData ScreeningRequestData;
    public class ScreeningRequestData {
        public String ApiToken;	//39475a23-6dd8-43db-8a31-e12dc969324c
        public Records Records;
    }
    public class Records {
        public List<Record> Record;
    }
    public class Record {
        public Integer RequestId;	//123457
        public String RecordIdentifier;	//TestRec1
        public String ApplicationFormNumber;	//AppForm1
        public String BranchName;	//B1
        public String RegionId;	//Reg1
        public String SystemName;	//Support1
        public String ParentCompany;	//Fedfina
        public Products Products;
        public String FirstName;	//First Name
        public String MiddleName;	//Middle Name
        public String LastName;	//Last Name
        public String CustomerCategory;	//IND
        public String Gender;	//M
        public String Pan;	//AAAAA1234A
        public String Din;	//DIN124
        public String Cin;	//U1234P2007PLC546789
        public String DateOfBirth;	//15-Jul-1986
        public String PlaceOfBirth;	//
        public String CountryOfBirth;	//
        public String Nationality;	//IND
        public Citizenships Citizenships;
        public String Passport;	//D1234
        public String DrivingLicenceNumber;	//MH-1220050000188
        public String CorrespondenceAddress1;	//Everest Bldg
        public String CorrespondenceAddress2;	//C Wing,,
        public String CorrespondenceAddress3;	//Senapati Bapat Marg ,Lower Parel
        public String CorrespondenceAddressCity;	//Mumbai
        public String CorrespondenceAddressState;	//Maharastra
        public String CorrespondenceAddressCountry;	//IND
        public Integer CorrespondenceAddressPin;	//400013
        public String PermanentAddress1;	//Everest Bldg
        public String PermanentAddress2;	//C Wing,,
        public String PermanentAddress3;	//Senapati Bapat Marg ,Lower Parel
        public String PermanentAddressCity;	//Mumbai
        public String PermanentAddressState;	//Maharastra
        public String PermanentAddressCountry;	//IN
        public Integer PermanentAddressPin;	//400013
        public String PEP;	//NotAPEP
        public String Occupation;	//SE
        public RMDetails RMDetails;
        public String CreateAlert;	//Yes
        public String ScreeningCategory;	//Initial Screening Master
    }
    public class Products {
        public String Product;	//BSE_CASH
    }
    public class Citizenships {
        public List<String> Citizenship;
    }
    
    public class RMDetails {
        public RMDetail RMDetail;
    }
    public class RMDetail {
        public Integer UserCode;	//404
        public String Type;	//BM
        public String FromDate;	//20-Jan-2019
    }
    public static ScreeningRequestWrapper parse(String json){
        return (ScreeningRequestWrapper) System.JSON.deserialize(json, ScreeningRequestWrapper.class);
    }
}