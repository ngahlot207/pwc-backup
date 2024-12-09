public class HunterRequestWrapper {
    
    public Header header;
    public Payload payload;
    
    public class Header {
        public String tenantId;	//IN24CEZZ
        public String requestType;	//HunterOnly
        public String clientReferenceId;	//FEDFINA_14092023_001
        public String expRequestId;	//
        public String messageTime;	//2023-04-27T05:01:36Z
        public Options options;
    }
    
    public class Options {
    }
    
    public class Payload {
        public String source;
        public List<Contacts> contacts;
        public Application application;
    }
    
    public class Contacts {
        public String id;	//MAINAPPLICANT_1
        public Person person;
        public Organization organization;
		public List<Addresses> addresses;
		public List<Telephones> telephones;
        public List<IdentityDocuments> identityDocuments;
        public List<EmploymentHistory> employmentHistory;
		public List<Incomes> incomes;
    }
    
    public class Person {
        public String typeOfPerson;	//APPLICANT
        public PersonDetails personDetails;
        public List<Names> names;
    }
    public class PersonDetails {
        public String dateOfBirth;	//
        public String mothersFullName;	//
        public String fathersFullName;	//
    }
    
    public class Names {
        public String id;	//MAINAPPLICANT_NAME_1
        public String type;	//CURRENT
        public String firstName;	//DUMMY
        public String middleNames;	//
        public String surName;	//ONLINE
    }
    
    public class Organization {
	}
	
    public class Addresses {
        public String id;	//ADDRESS_1
        //public String indicator;	//
        public String addressType;	//
        public String buildingName;	//
        public String street;	//
        public String street2;	//
        public String locality;	//
        public String country;	//
        public String postal;	//
        public String postTown;
        public String stateProvinceCode;	//
        public String countryCode;	//INDIA
	}
	
    public class Telephones {
		public String id;	//MAINAPPLICANTTELEPHONE_1
		public String numberVar;	//+919573123777
		public String type;	//MOBILE
		public String areaCode;	
	  //public String internationalCode;	//91
	  //public String phoneIdentifier;	
	}
    
    public class IdentityDocuments {
        public String id;	//MAINAPPLICANT_IDPROOF_1
        public String documentType;	//PAN CARD
        public String documentNumber;	//FORM16
    }
    
    public class EmploymentHistory {
	}
	
    public class Incomes {
	}
    
    public class Application {
        public ProductDetails productDetails;
      //public String type;
        public String originalRequestTime;	//2023-04-27T05:01:36Z
        public List<Applicants> applicants;
    }
    public class ProductDetails {
        public String productType;
        public String productCode;	//IND_LAP
    }
    public class Applicants {
        public String id;	//MAINAPPLICANT_11
        public String contactId;	//MAINAPPLICANT_1
      //public String type;
        public String applicantType;	//MAIN_APPLICANT
    }
    
    public static HunterRequestWrapper parse(String json){
        return (HunterRequestWrapper) System.JSON.deserialize(json, HunterRequestWrapper.class);
    }
}