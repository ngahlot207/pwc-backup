public class HunterResponseWrapper {
    
    public ResponseHeader responseHeader;
    public ClientResponsePayload clientResponsePayload;
    public OriginalRequestData originalRequestData;
    
    public class ResponseHeader {
        public String requestType;	//HunterOnly
        public String clientReferenceId;	//XXXX
        public String expRequestId;	//RB000000286330
        public String messageTime;	//2022-12-30T15:48:55Z
        public OverallResponse overallResponse;
        public String responseCode;	//R0201
        public String responseType;	//INFO
        public String responseMessage;	//Workflow Complete.
        public String tenantID;	//XXXX
    }
    
    public class OverallResponse {
        public String decision;	//NODECISION
        public String decisionText;	//No Decision
        public List<String> decisionReasons;
        public List<RecommendedNextActions> recommendedNextActions;
        public List<SpareObjects> spareObjects;
    }
    
    public class RecommendedNextActions {
    }
    
    public class SpareObjects {
    }
    
    public class ClientResponsePayload {
        public List<OrchestrationDecisions> orchestrationDecisions;
        public List<DecisionElements> decisionElements;
    }
    
    public class OrchestrationDecisions {
        public String sequenceId;	//1
        public String decisionSource;	//
        public String decision;	//
        public List<String> decisionReasons;
        public Integer score;	//0
        public String decisionText;	//
        public String nextAction;	//Continue
        public String decisionTime;	//2023-02-10T05:52:04Z
    }
    
    public class DecisionReasons {
        
    }
    
    public class DecisionElements {
        public String serviceName;	//Hunter
        public Integer normalizedScore;	//0
        public Integer score;	//90
        public String appReference;	//Testing_UAT_10022023
        public List<Rules> rules;
        public List<WarningsErrors> warningsErrors;
        public OtherData otherData;
        public List<Matches> matches;
        public List<Scores> scores;
    }
    
    public class Rules {
        public List<Rule> rule;
        public Integer totalRuleCount;	//3
    }
    
    public class WarningsErrors {
        public String responseType;	//WARNING
        public String responseCode;	//102009
        public String responseMessage;	//Match schemes not used
    }
    
    public class OtherData {
        public Response response;
    }
    
    public class Response {
        public MatchSummary matchSummary;
        public ErrorWarnings errorWarnings;
    }
    
    public class MatchSummary {
        public String totalMatchScore;	//90
        public Rules rules;
        public MatchSchemes matchSchemes;
        public SubmissionScores submissionScores;
        public Integer matches;	//1
    }
    
    public class Rule {
        public String ruleID;	//XXXX_VEL_MOB
        public Integer score;	//30
        public Integer ruleCount;	//3
    }
    
    public class MatchSchemes {
        public List<Scheme> scheme;
        public Integer schemeCount;	//1
    }
    
    public class Scheme {
        public Integer schemeID;	//627
        public Integer score;	//90
    }
    
    public class SubmissionScores {
        public List<ScoreType> scoreType;
        public Integer scoreCount;	//1
    }
    
    public class ScoreType {
        public List<ScoreValue> scoreValue;
        public String name;	//SCSS
        public Integer valueCount;	//1
    }
    
    public class ScoreValue {
        public Integer value;	//1036
        public String currentVersion;	//TRUE
    }
    
    public class ErrorWarnings {
        public Errors errors;
        public warnings warnings;
    }
    
    public class Errors {
        public List<error> error;
        public Integer errorCount;	//0
    }
    
    public class Error {
    }
    
    public class Warnings {
        public List<Warning> warning;
        public Integer warningCount;	//1
    }
    
    public class Warning {
        //public String number;	//102009
        public String message;	//Match schemes not used
        public Values values;
    }
    
    public class Values {
        public List<String> value;
    }
    
    public class Matches {
        public String name;	//627
        public String value;	//90
    }
    
    public class Scores {
        public String name;	//SCSS
        public Integer score;	//1036
        public String type;	//SCSS
    }
    
    public class OriginalRequestData {
        public String source;	//WEB
        public List<Contacts> contacts;
        public Application application;
    }
    
    public class Contacts {
        public String id;	//APPLICANT_1
        public Person person;
        public Organization organization;
        public List<Addresses> addresses;
        public List<Telephones> telephones;
        public List<IdentityDocuments> identityDocuments;
        public List<EmploymentHistory> employmentHistory;
        public List<Incomes> incomes;
    }
    
    public class Person {
        public String typeOfPerson;	//MAIN_APPLICANT
        public PersonDetails personDetails;
        public List<Names> names;
    }
    
    public class PersonDetails {
        public String dateOfBirth;	//1991-03-25
        public String yearOfBirth;	//1991
        public String age;	//31
        public String gender;	//MALE
        public String occupancyStatus;	//
        public String maritalStatus;	//
        public String qualificationType;	//
    }
    
    public class Names {
        public String id;	//MAINAPPNAME_1
        public String type;	//CURRENT
        public String title;	//
        public String firstName;	//RAGHU
        public String middleNames;	//RAM
        public String initials;	//NSB
        public String surName;	//KRISHNA
    }
    
    public class Organization {
    }
    
    public class Addresses {
    }
    
    public class Telephones {
        public String id;	//MAINAPPLICANTTELEPHONE_1
        //public String number;	//+919573123777
        public String type;	//MOBILE
        public String areaCode;	//
        public String internationalCode;	//91
        public String phoneIdentifier;	//MOBILE
    }
    
    public class IdentityDocuments {
        public String id;	//MAINAPPLICANTDOCUMENTS_1
        public String documentNumber;	//CFUPB1036C
        public String documentType;	//PAN CARD
    }
    
    public class EmploymentHistory {
    }
    
    public class Incomes {
    }
    
    public class Application {
        public String originalRequestTime;	//2022-12-30T15:48:55Z
        public String type;	//CREDIT
        public String status;	//UNKNOWN
        public ProductDetails productDetails;
        public List<Applicants> applicants;
        public String messageTime;	//2022-12-30T15:48:55Z
    }
    
    public class ProductDetails {
        public String productType;	//LOAN
        public ProductAmount productAmount;
        public String purposeOfLoan;	//
        public String productCode;	//PL_FNT
        public String loanReference;	//
    }
    
    public class ProductAmount {
    }
    
    public class Applicants {
        public String id;	//APPLICANTS_1
        public String contactId;	//APPLICANT_1
        public String type;	//INDIVIDUAL
        public String applicantType;	//MAIN_APPLICANT
    }

	public List<cls_errors> errors;
	public boolean success;
	public class cls_errors {
		public String errorType;	//Unauthorized
		public String message;	//Access token is invalid
	}
    
    public static HunterResponseWrapper parse(String json){
        return (HunterResponseWrapper) System.JSON.deserialize(json, HunterResponseWrapper.class);
    }
}