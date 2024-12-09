public class GlobalConstants {
    
    //DOCUMENT MASTER DOCUMENT TYPE VALUE
    public static final String INT_MSG_DOCMASTER_NAME_AADHAR='AADHAR';
    public static final String INT_MSG_DOCMASTER_NAME_DRIVING_LICENSE='DRIVING LICENCE';
    public static final String INT_MSG_DOCMASTER_NAME_PASSPORT='PASSPORT';
    public static final String INT_MSG_DOCMASTER_NAME_VOTER_ID='VOTER ID';
    public static final String INT_MSG_DOCMASTER_NAME_PAN='PAN';
    
    //Boolean Values 
    public static final BOOLEAN INT_MSG_ISACTIVE = True;
    public static final BOOLEAN INT_MSG_DOCUMENT_API = True;
    public static final BOOLEAN INT_MSG_DOCUMENT_API_FALSE = false;
    public static final BOOLEAN INT_MSG_ISSUCCESS = true;
    
    //Applicant Types  Global Constants
    public static final String Applicant_TYPE = 'Applicant';
    public static final String CO_APPLICANT_TYPE= 'Co-Applicant'; 
    
    //Integration message Object Global Constants
    public static final String INT_MSG_STATUS_NEW = 'New';
    public static final String INTEGRATION_MSG_STATUS_INPROGRESS = 'In Progress'; 
    public static final String INT_MSG_BU_TYPE = 'HL / STL';
    public static final String INT_MSG_BU_TYPE_HUNTER  = 'HL / STL';
    
    public static final String INT_MSG_MStatus_RESPONSE_RECEIVED = 'Response Received';
    public static final String INT_MSG_Status_Responded = 'Responded';
    public static final String INT_MSG_MStatus_ACKNOWLEDGED = 'Acknowledged';
    public static final String INT_MSG_MStatus_BLANK = 'Blank';
    
    public static final String INT_CONFIG_SERVICE_PAN_PROFILE_DETAILED = 'Pan Validation';
    public static final String INT_CONFIG_SERVICE_COMPOSITE_API = 'ICICI PennyDrop';
    public static final String INT_CONFIG_SERVICE_RISK_RATING = 'Risk API';
    public static final String INT_CONFIG_SERVICE_PASSPORT_VERIFICATION = 'Passport Verification';
    public static final String INT_CONFIG_SERVICE_VOTER_ID_AUTHENTICATION = 'Voterid Verification';
    public static final String INT_CONFIG_SERVICE_AADHAR_VERIFICATION = 'AADHAR VERIFICATION';
    public static final String INT_CONFIG_SERVICE_DRIVERS_LICENSE_AUTHENTICATION = 'DL Authentication';
    public static final String INT_CONFIG_SERVICE_RC_AUTHETICATION = 'RC-AUTHENTICATION';
    public static final String INT_CONFIG_SERVICE_PAN_SERVICE = 'Pan authentication';
    public static final String INT_CONFIG_SERVICE_KYC_OCR = 'KYC OCR';
    public static final String INT_CONFIG_SERVICE_KYC_OCR_AADHAR = 'KYC AADHAR';
    public static final String INT_CONFIG_SERVICE_KYC_OCR_PASSPORT= 'PASSPORT(KYC OCR)';
    public static final String INT_CONFIG_SERVICE_KYC_OCR_PAN= 'PAN(KYC OCR)';
    public static final String INT_CONFIG_SERVICE_KYC_OCR_DL = 'DRIVING LICENSE(KYC OCR)';
    public static final String INT_CONFIG_SERVICE_KYC_OCR_VOTER_ID = 'VOTER ID(KYC OCR)';
    public static final String INT_CONFIG_SERVICE_IFSC_CODE_CHECK= 'IFSC CODE CHECK';
    public static final String INT_CONFIG_SERVICE_BANK_AC_VERIFICATION= 'BANK AC VERIFICATION';
    public static final String INT_CONFIG_SERVICE_CKYC_DOWNLOAD = 'CKYC_DOWNLOAD';
    public static final String INT_CONFIG_SERVICE_HUNTER_TOKEN_SERVICE = 'Hunter Token';
    public static final String INT_CONFIG_SERVICE_HUNTER_API_SERVICE = 'Hunter API';
    public static final String INT_CONFIG_SERVICE_LOAN_BOARDING_API_SERVICE = 'Loan Boarding';
    public static final String CONSENT_Y = 'Y';
    public static final String INT_MSG_Status_EXCEPTION = 'Exception';
    public static final String INT_ADD_TR_DIS_SVC ='Additonal Disbursal';
    public static final String INT_MULTI_TRANCHE ='Get Multi Tranch';
    public static final String INT_CONFIG_SERVICE_ELECTRICITY_BILL_AUTHENTICATION = 'Electricity Bill Authentication';
    public static final String INT_CONFIG_GST_SEARCH_BASIS_PAN = 'GST Search Basis PAN'; 
    public static final String INT_CONFIG_GSP_GST_AUTHENTICATION = 'GSP GST Authentication'; 
    
    //Roles for user
    public static final String USER_ROLE_DSA = 'DSA';
    public static final String USER_ROLE_CPA = 'CPA';
    public static final String USER_ROLE_CPV = 'CPV';
    public static final String USER_ROLE_UNDERWRITER = 'Underwriter';
    
    //Loan Application SubStages Picklist Values
    public static final String LOANAPP_SUBSTAGE_APPLICANT_DETAILS = 'Applicant Details';
    public static final String LOANAPP_SUBSTAGE_KYC_DETAILS = 'KYC Details';
    public static final String LOANAPP_SUBSTAGE_BANK_DETAILS = 'Bank Details';
    public static final String LOANAPP_SUBSTAGE_CO_APPLICANT_DETAILS = 'Co-Applicant Details';
    public static final String LOANAPP_SUBSTAGE_EMPLOYMENT_DETAILS = 'Employment Details';
    public static final String LOANAPP_SUBSTAGE_PAN_VERIFICATION = 'PAN Verification';
    public static final String LOANAPP_SUBSTAGE_ADDRESS_DETAILS = 'Address Details';
    public static final String LOANAPP_SUBSTAGE_PRODUCTT_DETAILS = 'Product Details';
    public static final String LOANAPP_SUBSTAGE_DEDUPE = 'Dedupe';
    public static final String LOANAPP_SUBSTAGE_DOCUMENT_UPLOAD = 'Document Upload';
    
    //Loan Application Stages picklist values
    public static final String LOANAPP_STAGE_LEAD_CAPTURE = 'Lead Capture';
    public static final String LOANAPP_STAGE_DATA_CAPTURE = 'Data Capture';
    public static final String LOANAPP_STAGE_VERIFICATION = 'Verification';
    public static final String LOANAPP_STAGE_UNDERWRITER = 'Underwriter';
    public static final String LOANAPP_STAGE_SANCTION = 'Sanction';
    
    //Loan Application Verification Stage picklist values
    public static final String LOANAPP_VERF_STG_CPA = 'CPA';
    public static final String LOANAPP_VERF_STG_CPV = 'CPV';
    
    //Case Record Type Names and Verification Type values
    public static final String CASE_RESIDENCE_CPV = 'Residence CPV';
    public static final String CASE_OFFICE_CPV = 'Office CPV';
    public static final String CASE_RESIDENCE_CPV_VERIFICATION = 'Residence CPV';
    public static final String CASE_OFFICE_CPV_VERIFICATION = 'Office CPV';
    
    //Applicant Address Type picklist Values
    public static final String ADDRESS_TYPE_PERMANENT = 'Permanent';
    public static final String ADDRESS_TYPE_OFFICE = 'Office Address';
    
    //Agency Locaton Mapper agencyType picklist Values AND Business unit values
    public static final String AGENCY_TYPE_CPV = 'CPV';
    public static final String AGENCYLOCMAP_BU_TYPE_VEHICLE_LOAN = 'Vehicle Loan';
    
    //Contact agencycontactType picklist Values AND Business unit values
    public static final String AGENCY_CONTACT_TYPE_CPV = 'CPV';
    public static final String CONTACT_BU_TYPE_VEHICLE_LOAN = 'Vehicle Loan'; 
    public static final String CONTACT_AGENCY_RECORD_TYPE = 'Agency';
    
    //LoanApplication (LoanAppl__c ) (LnSubStage__c )field  picklist Val
    public static final String LN_SUB_STG_UNDERWRITER_PENDING = 'Underwriting Pending';
    public static final String LN_SUB_STG_CRDT_HOLD = 'Credit Hold'; 
    public static final String LN_SUB_STG_REJECT = 'Reject';
    public static final String LN_SUB_STG_CANCEL = 'Cancel';
    public static final String LN_SUB_STG_FORWORD = 'Forward'; 
    public static final String LN_SUB_STG_RET_TO_CPA = 'Return to CPA';
    public static final String LN_SUB_STG_RET_TO_SALES = 'Return to Sales Team';
    
    //Picklist values for Inprogress,Success,Failure
    public static final String MSG_SUCCESS = 'Success';
    public static final String MSG_INPROGRESS= 'Inprogress';
    public static final String MSG_FAILURE = 'Failure';
    public static final String General_Message_KYCOCR='Uploaded document is not same as selected documnet on KYC';
    
    
    //Values for Sharing Hierarchy Metadata
    public static final String Sharing_Mdt_Sales = 'Sales__c';
    public static final String Sharing_Mft_Credit= 'Credit__c';
    public static final String Sharing_Mdt_Ops = 'Ops__c';
    public static final String Sharing_Mdt_UWGroup = 'UWGroup__c';
    public static final String Sharing_Mdt_OpsUser = 'OpsUser__c';
    public static final String Sharing_Mdt_CPAUser = 'CPAUser__c';
    public static final String Sharing_Mdt_HubManager = 'HubManager__c';
    public static final String Sharing_Mdt_RcuManager = 'RCUManager__c';
    public static final String Sharing_Mdt_VendorCPA = 'VendorCPA__c';
    
    //Karza error code
    public static final Integer karza_Status_101=101;
    public static final Integer karza_Status_102=102;
    public static final Integer karza_Status_103=103;
    public static final Integer karza_Status_104=104;
    public static final Integer karza_Status_105=105;
    public static final Integer karza_Status_106=106;
    public static final Integer karza_Status_107=107;
    public static final Integer karza_Status_108=108;
    public static final Integer karza_Status_109=109;
    
    //Enach Integration Comstants
    public static final String INT_CONFIG_SERVICE_MANDATE_CREATE_FORM_SERVICE = 'mandate_create_form';  
    public static final String MANDATE_CREATE_FORM_SERVICE_RESPONSE_STATE_PARTIAL = 'Authentication pending at customer end';
    public static final String ENACH_AUTH_MODE = 'api';
    public static final String ENACH_MANDATE_TYPE = 'create';
    public static final String ENACH_CORPORATE_CONFIG_ID = 'TSE210907145432984BYVA178CURG81K';//'TSE220331154331585EJS7NQVMYHOFM7'  
    public static final Boolean ENACH_NOTIFY_CUSTOMER = true;
    public static final String ENACH_EXPIRE_IN_DAYS = '15';
    public static final String ENACH_INSTRUMENT_TYPE = 'debit';
    public static final Boolean ENACH_IS_RECOCURRING = true;
    public static final String ENACH_FREQUENCY = 'Monthly';   
    public static final String ENACH_MANAGEMENT_CATEGORY = 'L001';
    public static final String ENACH_ACCOUNT_TYPE_SAVINGS = 'Savings';
    public static final String ENACH_ACCOUNT_TYPE_CURRENT = 'Current';
    public static final String ENACH_ACCOUNT_TYPE_CC = 'CC';
    public static final String ENACH_ACCOUNT_TYPE_OTHER = 'Other';
    
    //verification expiry metadata
    public static final String Verification_Name_Legal = 'Legal Report';   
    public static final String Verification_Name_Watchout = 'Watchout';
    public static final String Verification_Name_TSR = 'TSR Report';
    public static final String Verification_Name_Technical = 'Technical Report';
    public static final String Verification_Name_Sanction_Letter = 'Sanction Letter';   
    public static final String Verification_Name_PD = 'PD';
    public static final String Verification_Name_Hunter = 'Hunter';
    public static final String Verification_Name_Dedupe = 'Dedupe';
    public static final String Verification_Name_CPV = 'CPV Report';
    public static final String Verification_Name_Collateral = 'Collateral Visit';
    public static final String Verification_Name_Bureau = 'Bureau';
    public static final String Verification_Name_Electricity_Bill = 'Electricity Bill';  
    
    //Aadhar Vault Constant
    Public Static final String RRN='2';
    
    //SMS Constant
    Public Static final String CountryCode = '91';
    Public Static final String MsgtypeOTP = 'OTP';
    Public Static final String MsgtypeText = 'text';
    
    //Aadhar Masking Constant
    Public Static final String Lat = '0.0';
    Public Static final String Lon = '0.0';
    
    //Trackwizz_CKYC_A63 Constant
    Public Static final String IsSmallCustomer = '0';
    Public Static final String EkycOTPBased = '0';
    Public Static final String Status = 'Active';
    Public Static final String MotherPrefix='Mrs';
    Public Static final String FatherPrefix='Mr';
    Public Static final Integer KYCAttestationType=1;
    Public Static final String Country='IN';
    Public Static final String EmailType = 'Personal';
    Public Static final String EmailType_Work = 'Work';
    Public Static final String AddressType = 'Permanent';
    Public Static final String AddressType_Correspondence = 'Correspondence';
    Public Static final String PermanentCKYCAddressType = '1';
    Public Static final String CorrespondenceCKYCAddressType = '1';
    Public Static final String ContactType = 'Personal';
    Public Static final String ISDCode = '91';
    Public Static final String Tag = 'RiskRating';
    Public Static final Integer ShareHoldingPercentage=1;
    Public Static final Integer PropertyOwnerFlag = 0;
    Public Static final String Module = 'CKYC';
    
    //Trackwizz_CKYC_A37 Constant
    Public Static final String SourceSystemCustomerCode = 'SFDC';
    
    //CrifAuthLoginRequestGenerator Constant
    Public Static final String Mode = 'STRATEGYONE';
    
    //EmailRequestGenerator Constant
    Public Static final String version = '2';
    
    //Hunter Constant
    Public Static final String tenantId = 'IN24CEZZ';
    Public Static final String requestType = 'HunterOnly';
    Public Static final String clientReferenceId = 'Fedfina_';
    Public Static final String types = 'CURRENT';
    Public Static final String Mobtype = 'MOBILE';
    Public Static final String CountryName = 'IND';
    Public Static final String productCode = 'IND_LAP';
    Public Static final String productType = 'LOAN';
    Public Static final String source = 'WEB';
    
    //CompositePayment Constant
    Public Static final String retailerCode='rcode';
    Public Static final String amount='1';

    //Workapps API constants
    Public Static final String INT_CONFIG_SERVICE_WORKAPPS_GET_API_SERVICE='Guest Call Details';
    Public Static final String INT_CONFIG_SERVICE_WORKAPPS_POST_API_SERVICE='Guest Call';

    
    //IMDRequestGenerator Constant
    Public Static final String chequeStatus = 'R';
    Public Static final String imdFlag = 'Y';
    Public Static final String bpType = 'LS';
    Public Static final String transactionCode = '1';
    Public Static final String InFavourOf = 'Fedbank Financial Service Limited';
    Public Static final String chargeId = '56';
    
    //PaytmRequestGenerator Constant
    Public Static final String linkType='FIXED';
    Public Static final String tokenType ='AES';
    
    //RiskRatingRequestGenerator Constant
    Public Static final String Contact_Type='TW03';//GlobalConstants.
    
    //Aadhaar Consent Constants
    Public Static final String AadhaarVariable = 'Aadhaar';
    Public Static final String AadhaarValidatedVariable = 'Success';
    Public Static final String AadhaarConsentVariable = 'Aadhaar Consent';
    Public Static final String AadhaarConsentError = 'Aadhaar Consent is Not Provided';
    
    //Waiver Document Constants
    Public Static final String WaiverDocumentType = 'Interest waiver';
    Public Static final String WaiverDocumentError = 'Interest waiver document is not provided.';
    
    //ScreeningRequestGenerator Constant
    Public Static final String Nationality = 'IND';
    Public Static final String ScreeningCategory = 'Initial Screening Master';
    
    //UdyamVerificationAPIRequestGenerator Constants
    public static final String yesValue = 'Y';
    public static final String noValue = 'N';
    
    //Karza error code description 
    public static final Map<Integer, String> karza_Status_Code_OCR_Description = new Map<Integer, String>{
        101 => 'Successful OCR',
        102 => 'No KYC Document identified',
        103 => 'Image Format Not Supported OR Size Exceeds 6MB',
        104 => 'N/A', 
        105 => 'N/A',
        106 => 'N/A',
        107 => 'N/A',
        108 => 'N/A',
        109 => 'N/A'
    };
                
    //Karza error code description 
    public static final Map<Integer, String> karza_Status_Code_Authn_Description = new Map<Integer, String>{
        101 => 'Valid Authentication',
        102 => 'Please enter valid data',//'Invalid ID number or combination of inputs',
        103 => 'No records found for the given ID or combination of inputs',
        104 => 'Max retries exceeded', 
        105 => 'Missing Consent',
        106 => 'Multiple Records Exist',
        107 => 'Not Supported',
        108 => 'Internal Resource Unavailable',
        109 => 'Too many records Found',
        503=>'Service Unavailable'
    };
          
    //CPARoles Constant

    public static List<String> CPARoles = new List<String>{'CPA', 'UW', 'VCPA', 'QCPA'};

}