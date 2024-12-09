import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValuesByRecordType, getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
//Apex methods
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import getApplicantData from '@salesforce/apex/verifyCoApplicantDetailsController.getCoApplicantData';
import upsertApplicantRecord from '@salesforce/apex/verifyCoApplicantDetailsController.upsertCoApplicantRecord';
import upsertRecord from '@salesforce/apex/verifyCoApplicantDetailsController.upsertRecord';
import getRelatedFilesByRecordId from '@salesforce/apex/verifyCoApplicantDetailsController.getRelatedFilesByRecordId';
import getDocDetailId from '@salesforce/apex/verifyCoApplicantDetailsController.getDocDetailId';
import deleteFileRecord from '@salesforce/apex/verifyCoApplicantDetailsController.deleteFileRecord';
import uploadFile from '@salesforce/apex/verifyCoApplicantDetailsController.uploadFile';
import updateMaxLimitReached from '@salesforce/apex/verifyCoApplicantDetailsController.updateMaxLimitReached';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import evaluateAllRequiredRecords from "@salesforce/apex/DocumentDetailController.evaluateAllRequiredRecords";
import checkPanNoStatus from "@salesforce/apex/DocumentDetailController.checkPanNoStatus";
import generateOTP from '@salesforce/apex/verifyCoApplicantDetailsController.generateOTP';
import updateApplicantDigitalVerified from '@salesforce/apex/verifyCoApplicantDetailsController.updateApplicantDigitalVerified';
import getLeadById from '@salesforce/apex/verifyCoApplicantDetailsController.getLeadById';
import validateOtp from '@salesforce/apex/CreateLeadController.validateOtp';
import fetchOrCreateDocumentMaster from '@salesforce/apex/verifyCoApplicantDetailsController.fetchOrCreateDocumentMaster';
import getLightningHostname from "@salesforce/apex/DomainNameProvider.getLightningHostname";
import getVisualforceDomain from "@salesforce/apex/DomainNameProvider.getVisualforceDomain";
import { updateRecord } from "lightning/uiRecordApi";
import DOCDETAILCONTENTDOCUMENTID_FIELD from "@salesforce/schema/DocDtl__c.Content_Document_Id__c";
import DOCDETAILID_FIELD from "@salesforce/schema/DocDtl__c.Id";
import CoApplMobNoSAmeAsAppl from '@salesforce/label/c.CoAppl_Mob_No_Same_As_Appl';
import SameMobNoForMultCoAppl from '@salesforce/label/c.SameMobNoForMultCoAppl';
import noOfOtpAttempts from '@salesforce/label/c.CreateLead_OTP_noofAttempts';
import SentOTPSuccess from '@salesforce/label/c.OTP_Sent_Success';
import OTPTimerApplicant from '@salesforce/label/c.OTPTimerCoApplicant';
import OTPRetryMessage from '@salesforce/label/c.LeadCapture_OTP_Retry_Message';
import OTPThreeTimesError from '@salesforce/label/c.LeadCapture_OTP_Threetimes';
import mobVerificationFailed from '@salesforce/label/c.CreateLead_OTP_MobileNotVerified';
import uploadOneFile from '@salesforce/label/c.LeadCapture_OTPValidation_Uploadonefile';
import MobileNumSuccess from '@salesforce/label/c.LeadCapture_OTP_MobileNoSuccess';
import ALL_FIELDS_Label from '@salesforce/label/c.LeadCapture_BasicDetails_RequiredFieldsValidation';
import APPLICANT_SUCCESS_Label from '@salesforce/label/c.ApplicantCapture_SuccessMessage';
import VerApplicant_Appl_SuccessMessage from '@salesforce/label/c.VerApplicant_Appl_SuccessMessage';
import ApplicantCapture_Format_ErrorMessage from '@salesforce/label/c.ApplicantCapture_Format_ErrorMessage';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import mobValfailed from '@salesforce/resourceUrl/mobile_validation_failed';
import getUiTheme from "@salesforce/apex/UiThemeController.getUiTheme";
import DIGITAL_VERIFIED from '@salesforce/schema/Lead.Digital_Verified__c';

//Message channel section
import { publish, subscribe, unsubscribe, createMessageContext, releaseMessageContext } from 'lightning/messageService';
import RECORDCREATE from "@salesforce/messageChannel/RecordCreate__c";

//LMS details
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";

import { trimFunction } from 'c/reusableStringTrimComp';
import { getRecord, deleteRecord, getFieldValue } from "lightning/uiRecordApi";

//File upload size
const MAX_FILE_SIZE = 10485760; //in bytes 10 MB now

// Applicant object
import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';
import RATIONALE_BEHIND from '@salesforce/schema/Applicant__c.RationaleUsingPhyConsent__c';
import CoApplicantMobileFormatError from '@salesforce/label/c.CoApplicantMobileFormatError';
const customerProfileVisibleOptions = ["SALARIED", "SELF EMPLOYED NON PROFESSIONAL", "SELF EMPLOYED PROFESSIONAL", "HOUSEWIFE", "OTHERS"];
// Custom labels
import CoAppl_PrimaryAppl_ErrorMessage from '@salesforce/label/c.CoAppl_PrimaryAppl_ErrorMessage';
import CoAppl_Otp_ErrorMessage from '@salesforce/label/c.CoAppl_Otp_ErrorMessage';
import CoAppl_PrimaryAppl_SuccessMessage from '@salesforce/label/c.CoAppl_PrimaryAppl_SuccessMessage';
import CoAppl_ErrorMessage from '@salesforce/label/c.CoAppl_ErrorMessage';
import CoAppl_ReqField_ErrorMessage from '@salesforce/label/c.CoAppl_ReqField_ErrorMessage';
import CoAppl_Verf_SuccessMessage from '@salesforce/label/c.CoAppl_Verf_SuccessMessage';
import CoAppl_Del_SuccessMessage from '@salesforce/label/c.CoAppl_Del_SuccessMessage';
import CoAppl_FileSize_ErrorMessage from '@salesforce/label/c.CoAppl_FileSize_ErrorMessage';
import CoAppl_DocDetail_ErrorMessage from '@salesforce/label/c.CoAppl_DocDetail_ErrorMessage';
import CoAppl_Uploading_ErrorMessage from '@salesforce/label/c.CoAppl_Uploading_ErrorMessage';


import generateLink from '@salesforce/apex/verifyCoApplicantDetailsController.generateLink';
import checkDigitalVerified from '@salesforce/apex/verifyCoApplicantDetailsController.checkDigitalVerified';
import { RefreshEvent } from 'lightning/refresh';

export default class VerifyApplicantDetails extends NavigationMixin(LightningElement) {

    customLabel = {
        CoAppl_PrimaryAppl_ErrorMessage,
        CoAppl_Otp_ErrorMessage,
        CoAppl_PrimaryAppl_SuccessMessage,
        CoAppl_ErrorMessage,
        CoAppl_ReqField_ErrorMessage,
        CoAppl_Verf_SuccessMessage,
        CoAppl_Del_SuccessMessage,
        CoAppl_FileSize_ErrorMessage,
        CoAppl_DocDetail_ErrorMessage,
        CoAppl_Uploading_ErrorMessage,
        VerApplicant_Appl_SuccessMessage
    }

    acceptedFormats = ['.pdf', '.png', '.jpeg', '.jpg'];

    @api layoutSize;
    @api hasEditAccess = 'true';
    @api isVerified = false;
    @api recordId;
    @api loanAppId;
    @api applicantIdOnTabset;

    @track fileUploaded = false;
    @track otpSentSuccess = false;
    @track disabledMobOtpCon = false;
    @track isLoading = false;
    @track rationaleValue;
    @track isManual = false;
    @track mobileNumberValue;
    @track originalMobileNumber;
    @track applType;
    @track applicantType = 'APPLICANT';
    @track isOtpConsentDone = false;
    @track helpText = "Please fill other mandatory details first before adding Mobile Number";
    @track disableMode = false;
    @track lightningDomainName;
    @track vfUrl;
    @track documentDetailId;
    @track primaryApplicantMobNumber;
    @track showNameSection = false;
    @track mobCoApplChck;
    @track isSameMobNoAsAppl = false;
    @track showMatchingMobileMessage = true;
    @track filesPresent;
    @track controlShowPhysicalConsent = false;
    @track themeType;
    @track mobileOptionSelected = true;
    @track disableSendOTP = false;
    @track numberOfOTPAttempts = 0;
    @track showEnterOtp = false;
    @track isOTPNotValidated = false;
    @track hidetimer = false;
    @track timeLeft = OTPTimerApplicant;
    @track showValidateOTP = false;
    @track disableValidateOTP = true;
    @track digitalConsentDone = false;
    @track otpGenerated;
    @track disableUploadFiles = false;
    @track consentType;
    @track disableMobileNumber = false;
    @track intervalId;
    @track fileData;
    @track fileName = '';
    @track documentDetaildId = '';
    @track applicantTypeOptionsModified = [];
    @track customerProfileOptions = [];
    @track constitutionOptions = [];
    @track filesList = [];
    @track rationaleOptions = [];
    otpTimerValue;
    @track wiredResult;
    indexFile;
    commentsEntered;
    showComments = false;
    isPhyConsentValidated;
    showConsent = false;
    @track isMobile = false;
    showMobileNumber = false;
    errorMessage = '';
    isOTPValidated = false;
    disabledConstitution = false;
    disabledTypeOfBorrower = false;
    isIndividual = true;
    otpVerifiedMap = new Map();
    isMobileNumChanged = false;
    showPhysicalConsent = false;
    showMobileOtpConsent = false;
    loanApplData = null;
    disbledMobileOTP = false;
    wiredMobDataDetail;
    subscription = null;
    @track wiredData;
    showDeleteConfirmation = false;
    deleteRecordId;

    @track _applicantId;
    @api get applicantId() {
        return this._applicantId;
    }
    set applicantId(value) {
        this._applicantId = value;
        this.setAttribute("applicantId", value);
        this.handleRecordIdChange(value);
    }

    label = {
        OTPRetryMessage,
        uploadOneFile,
        MobileNumSuccess,
        OTPThreeTimesError,
        noOfOtpAttempts,
        mobVerificationFailed,
        CoApplicantMobileFormatError,
        ALL_FIELDS_Label,
        APPLICANT_SUCCESS_Label,
        ApplicantCapture_Format_ErrorMessage,
        SentOTPSuccess,
        CoApplMobNoSAmeAsAppl,
        SameMobNoForMultCoAppl
    };
    mobFailedImage = mobValfailed;

    @track wrapObj = {
        MobNumber__c: "",
        ApplType__c: "",
        Constitution__c: "",
        CustProfile__c: "",
        KeyManName__c: "",
        CompanyName__c: "",
        FName__c: "",
        MName__c: "",
        LName__c: "",
        ConsentType__c: "",
        RationaleUsingPhyConsent__c: "",
        Comments__c: ""
    };

    context = createMessageContext();

    @track
    params = {
        ParentObjectName: 'Applicant__c',
        parentObjFields: ['Id', 'LoanAppln__r.Product__c', 'DigitalVerified__c', 'ConsentType__c', 'RationaleUsingPhyConsent__c', 'CustProfile__c', 'Constitution__c', 'Title__c', 'FName__c', 'MName__c', 'LName__c', 'DOB__c', 'Age__c', 'Gender__c', 'MthrMdnName__c', 'Father_Name__c', 'ApplType__c',
            'MariStatus__c', 'Nationality__c', 'Religion__c', 'EduQual__c', 'ProfQual__c', 'MediCouncl__c', 'MobNumber__c', 'OTP_Verified__c', 'Is_Physical_Consent_Validated__c', 'EmailId__c', 'RegistrationNumber__c', 'YearOfRegistration__c', 'Listed_Unlisted__c', 'Partnership_registration_no__c',
            'PhoneNumber__c', 'CKYC_Number__c', 'SpName__c', 'CompanyName__c', 'DOI__c', 'KeyManName__c', 'InceptionYears__c', 'CIN__c', 'LLPIN__c', 'MembershipNumber__c', 'Relationship__c', 'Category__c', 'Whether_partnership_is_registered__c', 'LoanAppln__c', 'PAN__c', 'Politically_Exposed_Person__c',
            'Customer_Profile_Categorisation__c', 'Customer_Profile_Selection_Id__c', 'ID_proof_type__c', 'ID_Number__c', 'LEI_Number__c', 'Residential_Status__c', 'Guarantor_is_bringing_in_SPDC__c', 'isPerSameAsResi_ADD__c', 'Comments__c']
    }

    @wire(getApplicantData, { recordid: '$applicantId' })
    wiredApplicantData(wiredResult) {
        let { error, data } = wiredResult;
        this.wiredData = wiredResult;
        this.showMatchingMobileMessage = true;
        console.log('this.wiredData :', JSON.stringify(this.wiredData));
        if (data) {
            this.showNameSection = false;
            const fieldsToUpdate = ["DigitalVerified__c", "CustProfile__c", "Constitution__c", "ApplType__c", "MobNumber__c", "Id", "OTP_Verified__c", 'FName__c', 'MName__c', 'LName__c', 'KeyManName__c', 'CompanyName__c', 'LoanAppln__c', 'Is_Physical_Consent_Validated__c', 'Comments__c', 'RationaleUsingPhyConsent__c', 'ConsentType__c'];
            fieldsToUpdate.forEach(field => {
                if (data[field]) {
                    this.wrapObj[field] = data[field];
                    if (field === "RationaleUsingPhyConsent__c") {
                        if (data[field] === 'Other Reasons') {
                            this.showComments = true;
                        } else {
                            this.showComments = false;
                        }
                    }
                    if (field === "ConsentType__c") {
                        if (data[field] === 'OTP Consent') {
                            this.isMobile = true;
                            this.showMobileNumber = true;
                            this.isManual = false;
                            this.mobileOptionSelected = true;

                        } else if (data[field] === 'Physical Consent Upload') {
                            this.isManual = true;
                            this.isDigital = false;
                            this.isMobile = false;
                            this.mobileOptionSelected = false;
                        } else if (data[field] === 'Digital Consent') {
                            this.isDigital = true;
                            this.isManual = false;
                            this.showMobileNumber = true; //??
                            this.mobileOptionSelected = true;
                        }
                    }
                    if (field === 'Constitution__c' && data[field]) {
                        this.showNameSection = true;
                        if (data[field] === 'INDIVIDUAL') {
                            this.isIndividual = true;
                        } else {
                            this.isIndividual = false;
                        }
                    } else if (field === 'Constitution__c' && !data[field]) {
                        this.showNameSection = false;
                    }
                }
            });
            if (!this.wrapObj.LoanAppln__c) {
                this.wrapObj.LoanAppln__c = this.loanAppId ? this.loanAppId : null;
            }

            if (data.Is_OTP_Limit_Reached__c === true && data.OTP_Verified__c === false) {
                this.isOTPNotValidated = true;
                this.disableSendOTP = true;
                this.disableMobileNumber = true;
                this.showMobileNumber = true;
                this.showEnterOtp = false
            }
            if (data.MobNumber__c) {
                this.originalMobileNumber = data.MobNumber__c;
                this.mobCoApplChck = data.MobNumber__c;
            }
            if (data.ApplType__c) {
                this.applType = data.ApplType__c;
            }
            if (data.CustProfile__c && (data.CustProfile__c === 'SALARIED' || data.CustProfile__c === 'HOUSEWIFE' || data.CustProfile__c === 'OTHERS')) {
                this.disabledConstitution = true;
            }
            if (data.OTP_Verified__c === true) {
                this.isOTPValidated = true;
                if (this.primaryApplicantMobNumber && this.primaryApplicantMobNumber === this.wrapObj.MobNumber__c) {
                    this.showPhysicalConsent = true;
                    this.isMobile = false;
                    this.isManual = false;
                    this.isSameMobNoAsAppl = true;
                } else {
                    this.disableMobileNumber = true;
                    this.isOTPValidated = true;
                    this.disableSendOTP = true;
                    this.isMobile = true;
                    this.isManual = false;
                    this.showMobileNumber = true;
                    this.showEnterOtp = false;
                }
            }
            if (data.DigitalVerified__c === true) {
                this.isOTPValidated = true;
                this.digitalConsentDone = true;
                console.log('digitalConsentDone:', this.digitalConsentDone);
                if (this.primaryApplicantMobNumber && this.primaryApplicantMobNumber === this.wrapObj.MobNumber__c) {
                    this.showPhysicalConsent = true;
                    this.isDigital = false;
                    this.isManual = false;
                    this.isSameMobNoAsAppl = true;
                } else {
                    this.disableMobileNumber = true;
                    this.isOTPValidated = true;
                    this.digitalConsentDone = true;
                    console.log('digitalConsentDone:', this.digitalConsentDone);
                    this.disableSendOTP = true;
                    this.isDigital = true;
                    this.isManual = false;
                    this.showMobileNumber = true;
                    this.showEnterOtp = false;
                }
            }
            if (data.Is_Physical_Consent_Validated__c === true) {
                this.physicalConsentUploaded = true;
                this.showMatchingMobileMessage = false;


            } else {
                this.physicalConsentUploaded = false;
                this.showMatchingMobileMessage = true;

            }
            if (data.CustProfile__c === 'HOUSEWIFE' || data.CustProfile__c === 'OTHERS') {
                this.disabledConstitution = true;
                this.wrapObj.Constitution__c = 'INDIVIDUAL';
            }
            this.checkMobileCondition();
        }
    }

    @wire(getRelatedFilesByRecordId, { loanAppId: '$loanAppId', applicantId: '$applicantId' })//$applicantIdOnTabset
    uploadedFileResponse(result) {
        this.wiredResult = result;
        this.filesList = [];
        if (result.data) {
            var index = 0;
            result.data.forEach(record => {
                const customKeyRecord = {};
                customKeyRecord.Id = record.ContentDocumentId;
                customKeyRecord.Title = record.Title;
                customKeyRecord.ContentSize = record.ContentSize;
                customKeyRecord.FileExtension = record.FileExtension;
                customKeyRecord.index = index;
                customKeyRecord.cid = record.Id;
                this.filesList.push(customKeyRecord);
                index++;
            });

            if (this.filesList && this.filesList.length > 0) {
                this.physicalConsentUploaded = true;
                this.isPhyConsentValidated = true;
                this.fileUploaded = true;
                this.wrapObj.Is_Physical_Consent_Validated__c = true;

                if (this.wrapObj && this.wrapObj.Is_Physical_Consent_Validated__c === false && this.wrapObj.OTP_Verified__c == true) {
                    this.isMobile = true;
                    this.physicalConsentUploaded = false;
                    this.isManual = false;
                    this.filesPresent = false;
                    this.mobileOptionSelected = true;
                    this.disableSendOTP = true;
                    this.isOTPValidated = true;
                } else if (this.wrapObj && this.wrapObj.Is_Physical_Consent_Validated__c === false && this.wrapObj.DigitalVerified__c == true) {
                    this.isDigital = true;
                    this.physicalConsentUploaded = false;
                    this.isManual = false;
                    this.filesPresent = false;
                    this.mobileOptionSelected = true;
                    this.disableSendOTP = true;
                    this.isOTPValidated = true;
                    this.digitalConsentDone = true
                    console.log('digitalConsentDone:', this.digitalConsentDone);
                }
                else if (this.wrapObj && this.wrapObj.Is_Physical_Consent_Validated__c === true && this.wrapObj.OTP_Verified__c == false && ((this.wrapObj.LoanAppln__r.Product__c == 'Home Loan' || this.wrapObj.LoanAppln__r.Product__c == 'Small Ticket LAP'))) {
                    this.physicalConsentUploaded = true;
                    this.isMobile = false;
                    this.isManual = true;
                    this.filesPresent = true;
                    this.mobileOptionSelected = false;
                    this.isOTPValidated = false;
                }
                else if (this.wrapObj && this.wrapObj.Is_Physical_Consent_Validated__c === true && this.wrapObj.DigitalVerified__c == false && ((this.wrapObj.LoanAppln__r.Product__c == 'Business Loan' || this.wrapObj.LoanAppln__r.Product__c == 'Personal Loan'))) {
                    this.physicalConsentUploaded = true;
                    this.isDigital = false;
                    this.isManual = true;
                    this.filesPresent = true;
                    this.mobileOptionSelected = false;
                    this.isOTPValidated = false;
                    this.digitalConsentDone == false;
                    console.log('digitalConsentDone:', this.digitalConsentDone);
                }
                else {
                    if (this.wrapObj && this.wrapObj.Is_Physical_Consent_Validated__c === true && this.wrapObj.OTP_Verified__c == true && (this.wrapObj.LoanAppln__r.Product__c == 'Home Loan' || this.wrapObj.LoanAppln__r.Product__c == 'Small Ticket LAP')) {
                        this.isMobile = true;
                        this.isManual = false;
                        this.physicalConsentUploaded = false;
                        this.filesPresent = false;
                        this.mobileOptionSelected = true;
                        this.disableSendOTP = true;
                        this.isOTPValidated = true;
                    } else if (this.wrapObj && this.wrapObj.Is_Physical_Consent_Validated__c === true && this.wrapObj.OTP_Verified__c == true && (this.wrapObj.LoanAppln__r.Product__c == 'Business Loan' || this.wrapObj.LoanAppln__r.Product__c == 'Personal Loan')) {
                        this.isDigital = true;
                        this.isManual = false;
                        this.physicalConsentUploaded = false;
                        this.filesPresent = false;
                        this.mobileOptionSelected = true;
                        this.disableSendOTP = true;
                        this.isOTPValidated = true;
                        this.digitalConsentDone == true;
                        console.log('digitalConsentDone:', this.digitalConsentDone);
                    }
                    else {
                        if (this.wrapObj && this.wrapObj.Is_Physical_Consent_Validated__c === false
                            && this.wrapObj.OTP_Verified__c === false && this.wrapObj.DigitalVerified__c === false && this.filesList && this.filesList.length > 0) {
                            this.isManual = true;
                            this.isMobile = false;
                            this.Digital = false;
                            this.filesPresent = true;
                            this.mobileOptionSelected = false;
                            this.isOTPValidated == false;
                            this.digitalConsentDone == false;
                            console.log('digitalConsentDone:', this.digitalConsentDone);
                        }
                    }

                }

            } else {
                this.wrapObj.Is_Physical_Consent_Validated__c = false;
                this.physicalConsentUploaded = false;
            }
            if (result.error) {
                console.log(result.error);
                this.filesPresent = false;
            }
        } else {
            this.filesPresent = false;
        }
    }

    checkMobileCondition() {
        if (this.wrapObj.MobNumber__c && this.primaryApplicantMobNumber && (this.wrapObj.MobNumber__c === this.primaryApplicantMobNumber)) {
            this.wrapObj.OTP_Verified__c = false;
            this.wrapObj.DigitalVerified__c = false;
            this.isVerified = true;
            this.showConsent = true;
            this.showMobileOtpConsent = false;
            this.isSameMobNoAsAppl = true;
            this.showPhysicalConsent = true;
            this.mobileNumberValue = this.primaryApplicantMobNumber;
            this.isMobile = false;
            this.isDigital = false;
        } else if (this.wrapObj.MobNumber__c && this.wrapObj.MobNumber__c.length === 10) {
            this.mobileNumberValue = this.wrapObj.MobNumber__c;
            this.showConsent = true;
            this.showPhysicalConsent = true;
            this.showMobileOtpConsent = true;
            this.isVerified = false;
        } else {
            this.showConsent = false;
            this.isMobile = false;
            this.isDigital = false;
            this.isManual = false;
            this.mobileNumberValue = undefined;
        }
    }
    // Getter to determine whether to show the radio group
    get showRadioGroup() {
        return this.loanApplData && this.loanApplData.Applicant__r && this.loanApplData.Applicant__r.PhoneNumber__c === 'wrapObj.MobNumber__c';
    }
    mobilemobileMessageMismatchError = this.label.CoApplicantMobileFormatError;
    messageMismatchError = this.label.ApplicantCapture_Format_ErrorMessage;

    @wire(getObjectInfo, { objectApiName: APPLICANT_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: RATIONALE_BEHIND })
    RationalePicklistValues;

    @wire(getPicklistValuesByRecordType, {
        objectApiName: APPLICANT_OBJECT,
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    })
    picklistHandler({ data, error }) {
        if (data) {
            this.constitutionOptions = [...this.generatePicklist(data.picklistFieldValues.Constitution__c)]
            let customerProfileAllOptions = [...this.generatePicklist(data.picklistFieldValues.CustProfile__c)];
            let tempArrayCustProfile = [];
            for (let i = 0; i < customerProfileAllOptions.length; i++) {
                if (customerProfileVisibleOptions.indexOf(customerProfileAllOptions[i].label) > -1) {
                    tempArrayCustProfile.push(customerProfileAllOptions[i]);
                }
            }
            this.customerProfileOptions = tempArrayCustProfile.filter(item => (item.label != 'HOUSEWIFE') && (item.label != 'OTHERS'));  //[...tempArrayCustProfile];
            let applicantTypeOptions = [...this.generatePicklist(data.picklistFieldValues.ApplType__c)];
            this.applicantTypeOptionsModified = applicantTypeOptions.filter(option => {
                return option.label !== 'APPLICANT';
            });
            if (data.picklistFieldValues && data.picklistFieldValues.RationaleUsingPhyConsent__c) {
                this.rationaleOptions = [...this.generatePicklist(data.picklistFieldValues.RationaleUsingPhyConsent__c)];
            }
        }
        if (error) {
            console.error(error)
        }
    }

    @track leadDigitalVerified = false;



    @wire(getRecord, { recordId: '$leadId', fields: [DIGITAL_VERIFIED] })
    currentRecordInfo({ error, data }) {
        if (data) {

            console.log('currentRecordInfo ', data);
            this.leadDigitalVerified = data.fields.Digital_Verified__c.value;
            console.log('this.digital verified lead ', this.leadDigitalVerified);

            if (this.leadDigitalVerified) {
                this.digitalConsentDone = true;
                this.disableSendOTP = true;
                this.updateApplicantDigitalVerified();
            }

        } else if (error) {
            this.error = error;
            console.log('Error is ', this.error);

        }

    }

    updateApplicantDigitalVerified() {
        // Logic to update the digital verified status on the applicant
        updateApplicantDigitalVerified({ applicantId: this._applicantId })
            .then(() => {
                refreshApex(this.wiredResult);
                console.log('Applicant digital verified status updated successfully.');
            })
            .catch(error => {
                console.error('Error updating applicant:', error);
            });
    }

    connectedCallback() {
        if (this.hasEditAccess === false) {
            this.disableMode = true;
            this.disabledConstitution = true;
            this.disableMobileNumber = true;
            this.disabledMobOtpCon = true;
            this.disableSendOTP = true;
            this.disableValidateOTP = true;
        }
        this.scribeToMessageChannel();
        this.getUIThemeDetails();
        this.fetchLoanDetails();
        //this.fetchLeadDetails();
        //this.fetchLeadDetails1();

        getVisualforceDomain({}).then((result) => {
            this.vfUrl = result;
        });

        getLightningHostname({}).then((result) => {
            this.lightningDomainName = result;
        });
        window.addEventListener(
            "message",
            this.handleUploadCallback.bind(this)
        );
        console.log('disablesendotp', this.disableSendOTP);
    }

    renderedCallback() {
        if (this.disableMode) {
            let fileDeletes = this.template.querySelectorAll('lightning-icon[title="Delete"]');
            fileDeletes.forEach(item => {
                item.variant = "";
            })
        }
        else {
            let fileDeletes = this.template.querySelectorAll('lightning-icon[title="Delete"]');
            fileDeletes.forEach(item => {
                item.variant = "error";
            })
        }
        refreshApex(this.wiredData);
    }

    getUIThemeDetails() {
        getUiTheme()
            .then((result) => {
                this.themeType = result;
            })
            .catch((error) => {
            });
    }

    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.context,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }

    handleSaveThroughLms(values) {
        this.handleSave(values.validateBeforeSave, false);
    }

    handleSave(validate, isFileUploadCondition) {
        if (validate) {
            let isInputCorrect = this.checkValidity();
            if (isInputCorrect === true) {
                if (this.filesList && this.filesList.length > 0) {
                    this.physicalConsentUploaded = true;
                }
                if (this.isOTPValidated === true) {// || this.physicalConsentUploaded === true
                    this.handleUpsert(isFileUploadCondition);
                } else if (this.physicalConsentUploaded !== undefined && this.physicalConsentUploaded === true) {// && this.isNewFileUpload === true
                    this.handleUpsert(isFileUploadCondition);
                } else {
                    this.showToastMessage('Error', this.customLabel.CoAppl_Otp_ErrorMessage, 'error', 'sticky');
                }
            } else {
                this.showToastMessage('Error', this.label.ALL_FIELDS_Label, 'error', 'sticky');
            }
        } else {
            this.handleUpsert(isFileUploadCondition);
        }
    }

    handleUpsert(isFileUploadCondition) {
        if (!this.wrapObj.LoanAppln__c) {
            this.wrapObj.LoanAppln__c = this.loanAppId ? this.loanAppId : null;
        }

        if (this.physicalConsentUploaded === true) {
            this.wrapObj.Is_Physical_Consent_Validated__c = true;
            this.wrapObj.ConsentType__c = 'Physical Consent Upload';
        } else if (this.isOTPValidated === true) {
            this.wrapObj.Is_Physical_Consent_Validated__c = false;
            this.wrapObj.ConsentType__c = 'OTP Consent';
            this.wrapObj.OTP_Verified__c = true;
        }
        if (this.wrapObj) {
            upsertRecord({ recordData: this.wrapObj })
                .then(data => {
                    if (isFileUploadCondition === false) {
                        this.checkPanNoAccConstitution();// adde  For LAK-7603
                        //   this.showToastMessage('Success', this.customLabel.VerApplicant_Appl_SuccessMessage, 'success', 'sticky');// removed  For LAK-7603
                    }

                    if (data.Id) {
                        this.wrapObj.Id = data.Id;
                        if ((data.FName__c || data.LName__c) || data.CompanyName__c) {
                            this.publishMC(data.Id);
                        }
                    }
                    refreshApex(this.wiredData);
                })
                .catch(error => {
                    this.showToastMessage('Error', this.customLabel.CoAppl_ErrorMessage, 'error', 'sticky');
                })
        } else {
            this.showToastMessage('Error', this.customLabel.CoAppl_ErrorMessage, 'error', 'sticky');
        }
    }
    //// adde  For LAK-7603
    checkPanNoAccConstitution() {
        let ApplicantData = {
            Id: this.wrapObj.Id,
        };
        let appList = [];
        appList.push(ApplicantData);
        if (appList[0].Id != null) {
            checkPanNoStatus({ newList: appList })
                .then(data => {
                    if (data) {
                        const subDocList = Object.entries(data).map(([subDocName, subDocValues]) => {
                            return { subDocName, subDocValues };
                        });
                        if (subDocList.length > 0) {
                            subDocList.forEach(element => {
                                this.showToastMessage('Error', element.subDocName + ' : ' + element.subDocValues, 'error', 'sticky');
                            });
                        } else {
                            this.showToastMessage('Success', this.customLabel.VerApplicant_Appl_SuccessMessage, 'success', 'sticky');
                        }
                    }
                })
                .catch(error => {
                    this.showToastMessage('Error', 'Error in validating rec', 'error', 'sticky');
                })
        }
    }// adde  For LAK-7603

    publishMC(recordId) {
        const messageChannelMessage = {
            recordId: recordId,
            message: "Co Applicant Created"
        };
        publish(this.context, RECORDCREATE, messageChannelMessage);
    }
    unsubscribeMC() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    disconnectedCallback() {
        this.unsubscribeMC();
        releaseMessageContext(this.context);
    }

    //generate picklist from values 
    generatePicklist(data) {
        return data.values.map(item => ({ "label": item.label, "value": item.value }))
    }

    editApplicantDetails(inputVal) {
        this.showConsent = true;
        this.show_consent = true;
        this.mobileNumberValue = this.wrapObj.MobNumber__c;
        if (inputVal === 'SALARIED') {
            this.disabledConstitution = true;
            this.wrapObj.Constitution__c = 'INDIVIDUAL';
        }
        if (inputVal === 'SELF EMPLOYED PROFESSIONAL') {
            this.disabledConstitution = false;
            this.wrapObj.Constitution__c = '';
        }
        if (inputVal === 'SELF EMPLOYED NON PROFESSIONAL') {
            this.disabledConstitution = false;
            this.wrapObj.Constitution__c = '';
        }
        if (inputVal === 'HOUSEWIFE') {
            this.disabledConstitution = true;
            this.wrapObj.Constitution__c = 'INDIVIDUAL';
        }
        if (inputVal === 'OTHERS') {
            this.disabledConstitution = true;
            this.wrapObj.Constitution__c = 'INDIVIDUAL';
        }
        if (this.wrapObj.Constitution__c && this.wrapObj.Constitution__c === 'INDIVIDUAL') {
            this.showNameSection = true;
            this.isIndividual = true;
            this.wrapObj.CompanyName__c = null;
            this.wrapObj.KeyManName__c = null;
        }
        else if (this.wrapObj.Constitution__c && this.wrapObj.Constitution__c != 'INDIVIDUAL') {
            this.showNameSection = true;
            this.isIndividual = false;
        } else {
            this.showNameSection = false;
        }
    }

    inputChangeHandler(event) {
        if (event.target.dataset.type === 'string') {
            let strVal = event.target.value;
            this.wrapObj[event.target.dataset.fieldname] = strVal.toUpperCase();
        } else if (event.target.dataset.fieldname !== "MobNumber__c") {
            this.wrapObj[event.target.dataset.fieldname] = event.target.value;
        }
        let inputVal = event.target.value;
        this.editApplicantDetails(inputVal);
        if (event.target.dataset.fieldname === "MobNumber__c") {
            this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('');
            this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
            this.numberOfOTPAttempts = 0;
            this.isMobileNumChanged = true;
            this.isOTPNotValidated = false;
            this.showEnterOtp = false;
            this.disableSendOTP = false;
            this.disableValidateOTP = true;
            this.isVerified = false;
            let mobileNum = event.target.value;
            this.wrapObj['Is_OTP_Limit_Reached__c'] = false;
            this.wrapObj['OTP_Verified__c'] = false;
            this.mobileNumberValue = event.target.value;
            this.isOTPValidated = false;
            this.isSameMobNoAsAppl = false;
            this.mobileOptionSelected = true;
            this.isManual = false;
            this.isMobile = true;
            this.isDigital = true;
            this.showMobileNumber = true;
            this.otpSentSuccess = false;
            if (mobileNum.length === 10 && this.validatePhoneNumber() === true) {
                this.mobCoApplChck = null;
                this.mobCoApplChck = this.mobileNumberValue;
                this.controlShowPhysicalConsent = false;

                this.wrapObj.MobNumber__c = this.mobileNumberValue;
                this.showConsent = true;
                if (this.originalMobileNumber && this.originalMobileNumber === mobileNum && this.isOTPNotValidated === true) {
                    this.disableSendOTP = true;
                }
                else if (this.primaryApplicantMobNumber && this.primaryApplicantMobNumber === mobileNum) {
                    this.wrapObj.OTP_Verified__c = false;
                    this.showPhysicalConsent = true;
                    this.showMobileOtpConsent = false;
                    this.isSameMobNoAsAppl = true;
                }
                else {
                    this.showPhysicalConsent = true;
                    this.showMobileOtpConsent = true;
                    this.isVerified = false;
                    this.isSameMobNoAsAppl = false;
                }
                if (this.otpVerifiedMap && this.otpVerifiedMap[this.mobileNumberValue] === true) {
                    if (this.productTypeBLPL) {
                        this.wrapObj['OTP_Verified__c'] = true;
                    } else {
                        this.wrapObj['DigitalVerified__c'] = true;
                    }

                    this.isOTPValidated = true;
                    this.digitalConsentDone = true;
                    this.disabledMobOtpCon = true;
                    this.isMobile = true;
                    this.isDigital = true;
                } else {
                    if (this.productTypeBLPL) {
                        this.wrapObj['OTP_Verified__c'] = false;
                    } else {
                        this.wrapObj['DigitalVerified__c'] = false;
                    }
                    console.log('Inside elseeee');
                    this.isOTPValidated = false;
                    this.disabledMobOtpCon = false;
                    this.isMobile = true;
                    this.isDigital = true;
                }
                this.wrapObj.LoanAppln__c = this.loanAppId ? this.loanAppId : null;

            }
            else {
                this.showConsent = false;
                this.isMobile = false;
                this.isManual = false;
                this.isDigital = false;
                this.mobileNumberValue = undefined;
            }
        }
    }

    handleRecordIdChange() {
        let tempParams = this.params;
        tempParams.queryCriteria = ' where id = \'' + this._applicantId + '\'';
        this.params = { ...tempParams };
    }
    isDigital
    handleRadioClick(event) {
        this.errorMessage = ''
        const fieldName = event.currentTarget.dataset.field;

        if (fieldName === 'mobile') {
            this.isMobile = true;
            this.showMobileNumber = true;
            this.isManual = false;
            this.mobileOptionSelected = true;
            this.consentType = 'OTP Consent';
            this.isPhyConsentValidated = false;
            this.physicalConsentUploaded = false
        }
        if (fieldName === 'manual') {
            this.filesPresent = true;
            this.consentType = 'Physical Consent Upload';
            if (this.isOTPValidated === false || this.isSameMobNoAsAppl === true) {
                this.isManual = true;
                this.isDigital = false;
                this.isMobile = false;
                this.mobileOptionSelected = false;
            } else {
                this.showToastMessage('Success', this.customLabel.CoAppl_Verf_SuccessMessage, 'success', 'sticky');
                this.isMobile = true;
                this.isManual = false;
                this.isDigital = true;
                this.mobileOptionSelected = true;
            }
        }
        if (fieldName === 'Digital') {
            this.isDigital = true;
            this.showMobileNumber = true;
            this.isManual = false;
            this.mobileOptionSelected = true;
            this.consentType = 'Digital Consent';
            this.isPhyConsentValidated = false;
            this.physicalConsentUploaded = false
        }
    }

    validatePhoneNumber() {
        var regex = /[6,7,8,9]{1}[0-9]{9}/;
        return regex.test(this.mobileNumberValue);
    }

    handleMobileChange(event) {
        this.isOtpConsentDone = false;
        this.numberOfOTPAttempts = 0;
        this.mobileNumberValue = event.target.value;
        if (this.validatePhoneNumber() === false) {
            this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('Please enter a valid mobile number');
            this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
            this.disableSendOTP = true
            return;
        } else if (this.validatePhoneNumber() === true) {
            this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('');
            this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity()
            this.disableSendOTP = false;
        }
    }

    showToastMessage(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
            mode
        });
        this.dispatchEvent(evt);
    }
    @track taskId;
    handleSendOTP(event) {
        this.otpGenerated = undefined;
        if (this.validatePhoneNumber() === false) {
            this.disableSendOTP = true
        } else if (this.validatePhoneNumber() === true) {
            this.disableSendOTP = false;
        }
        if (this.showEnterOtp == true) {
            let otpElement = this.template.querySelector('.enter-otp');
            otpElement.setCustomValidity('');
            otpElement.reportValidity();
        }
        if (this.mobileNumberValue == '' || this.mobileNumberValue == undefined) {
            this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('Please complete this field.');
            this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
            return;
        } else if (this.validatePhoneNumber() === false) {
            this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity(this.mobileMessageMismatchError);
            this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
            return;
        }
        else {
            this.numberOfOTPAttempts = this.numberOfOTPAttempts + 1;
            if (this.numberOfOTPAttempts > noOfOtpAttempts) {
                this.disableSendOTP = true;
                this.showEnterOtp = false;
                this.isOTPNotValidated = true;
                this.disableMobileNumber = true;
                var ApplicantData = {
                    Id: this.wrapObj.Id
                };
                updateMaxLimitReached({ coAppRecord: ApplicantData }).then(response => {
                    refreshApex(this.wiredData);
                })
                this.hidetimer = true;
            } else {
                this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('');
                this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
                this.timeLeft = OTPTimerApplicant;
                this.showEnterOtp = true;
                this.disableSendOTP = true;
                this.disableValidateOTP = false;
                this.startTimer();
                generateOTP({ recordId: this.wrapObj.Id, mobileNumber: this.mobileNumberValue })
                    .then(response => {
                        if (response) {
                            this.otpGenerated = response[0];
                            this.taskId = response[0];
                            this.otpSentSuccess = true;
                        }
                    })
            }
        }
    }

    checkValidity() {
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        const isComboboxCorrect = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        return (isInputsCorrect === true && isComboboxCorrect === true) ? true : false;
    }

    handleEnterOtp(event) {
        var charCode = (event.which) ? event.which : event.keyCode;
        if ((charCode < 48 || charCode > 57)) {
            if (event.preventDefault) {
                event.preventDefault();
            } else {
                event.returnValue = false;
            }
        }
    }

    @track showSpinner = false;
    handleValidateOTP(event) {
        this.showSpinner = true;
        this.isOTPValidated = false;
        let otpElement = this.template.querySelector('.enter-otp');
        let optEntered = otpElement.value;

        validateOtp({ taskId: this.taskId, otp: optEntered })
            .then(response => {
                if (response) {
                    if (response === 'success') {
                        otpElement.setCustomValidity('');
                        this.wrapObj.OTP_Verified__c = true;
                        this.otpVerifiedMap[this.mobileNumberValue] = true;
                        this.isOTPValidated = true;
                        this.showEnterOtp = false;
                        this.isOTPNotValidated = false;
                        this.otpSentSuccess = false;
                        this.isPhyConsentValidated = false;
                        this.filesPresent = false;
                        this.isManual = false;
                        this.disableMobileNumber = true;
                        this.mobileOptionSelected = true;
                        let ApplicantData = {
                            Id: this.wrapObj.Id,
                            OTP_Verified__c: true,
                            MobNumber__c: this.mobileNumberValue,
                            ConsentType__c: this.consentType,
                            LoanAppln__c: this.loanAppId,
                            ApplType__c: this.wrapObj.ApplType__c,
                            Constitution__c: this.wrapObj.Constitution__c,
                            CustProfile__c: this.wrapObj.CustProfile__c,
                            KeyManName__c: this.wrapObj.KeyManName__c,
                            CompanyName__c: this.wrapObj.CompanyName__c,
                            FName__c: this.wrapObj.FName__c,
                            MName__c: this.wrapObj.MName__c,
                            LName__c: this.wrapObj.LName__c,
                            Is_Physical_Consent_Validated__c: this.isPhyConsentValidated
                        };

                        upsertApplicantRecord({ recordData: ApplicantData })
                            .then(response => {
                                this.disableSendOTP = true;
                                this.disableValidateOTP = true;
                                refreshApex(this.wiredData);
                            })
                    } else {
                        otpElement.setCustomValidity('OTP Validation Failed. Kindly try again');
                        this.isOTPValidated = false;
                    }
                    otpElement.reportValidity();
                    this.showSpinner = false;
                }
            })
    }

    startTimer() {
        this.intervalId = setInterval(() => {
            if (this.timeLeft > 0) {
                this.disableMobileNumber = true;
                this.hidetimer = false;
                var minutes = Math.floor(this.timeLeft / 60);
                var seconds = this.timeLeft % 60;
                minutes = String(minutes).padStart(2, '0');
                seconds = String(seconds).padStart(2, '0');
                this.otpTimerValue = minutes + ':' + seconds;
                this.timeLeft--;
            } else {
                this.disableMobileNumber = false;
                this.otpSentSuccess = false;
                this.otpTimerValue = '00' + ':' + '00';
                if (this.wrapObj.OTP_Verified__c === true) {
                    this.disableSendOTP = true;
                    this.disableMobileNumber = true;
                } else {
                    this.disableSendOTP = false;
                }
                this.showValidateOTP = false;
                clearInterval(this.intervalId);
                this.hidetimer = true;
            }
        }, 1000);
    }
    hasDocumentId;
    showModalForFilePre = false;
    previewHandler(event) {
        let conDocId = event.currentTarget.dataset.id;
        let cvid = event.currentTarget.dataset.cid;
        let conDocIds = conDocId + ',' + cvid;
        getDocDetailId({ loanAppId: this.loanAppId, applicantId: this.applicantId, contentDocId: conDocIds })
            .then(result => {
                if (result !== null) {
                    this.documentDetailId = result.Id;
                }
            }).catch(error => {
            }).finally(() => {
                this.showModalForFilePre = true;
                this.hasDocumentId = true;
            })

    }

    handleCloseModalEvent() {
        this.showModalForFilePre = false;
    }
    deleteHandler(event) {
        if (this.disableMode) {
            return;
        }
        this.showDeleteConfirmation = true;
        this.deleteRecordId = event.target.dataset.id;
    }

    hideModalBox() {
        this.showDeleteConfirmation = false;
    }

    handleConfirmDelete() {
        this.deleteFiles();
        this.showDeleteConfirmation = false;
    }
    handleCancelDelete() {
        this.showDeleteConfirmation = false;
    }

    deleteFiles() {
        if (this.deleteRecordId) {
            deleteFileRecord({ deleteRecordId: this.deleteRecordId })
                .then(respons => {
                    if (respons === 'SUCCESS') {
                        this.wrapObj.Is_Physical_Consent_Validated__c = false;
                        this.physicalConsentUploaded = false;
                        this.handleUpsert();
                    }
                    refreshApex(this.wiredResult);
                    if (this.filesList && this.filesList.length < 1) {
                        this.wrapObj.Is_Physical_Consent_Validated__c = false;
                        this.physicalConsentUploaded = false;

                    }

                    this.showToastMessage("Success", this.customLabel.CoAppl_Del_SuccessMessage, "success", "sticky");
                })
                .catch((error) => {
                    this.showToastMessage("Error", error.body.message, "error", "sticky");
                });
        } else {
            this.showToastMessage("Error", error.body.message, "error", "sticky");
        }
        this.deleteRecordId = '';
    }

    openfileUpload(event) {
        this.isManual = false;
        const file = event.target.files[0];
        let fileNameParts = event.detail.files[0].name.split('.');
        let extension = '.' + fileNameParts[fileNameParts.length - 1].toLowerCase();
        this.fileName = file.name;
        this.isLoading = true;
        if (!this.acceptedFormats.includes(extension)) {
            this.showToastMessage('File format not supported.', '', 'error', 'sticky');
        }
        else if (file.size > MAX_FILE_SIZE) {
            this.showToastMessage(
                "Error!",
                this.customLabel.CoAppl_FileSize_ErrorMessage,
                "error",
                "sticky"
            );
            this.isLoading = false;
        }
        else {
            let reader = new FileReader();
            reader.onload = () => {
                try {
                    this.fileData = new Array();
                    let fileContents = reader.result.split(",")[1];
                    this.fileData.length = 0;
                    this.fileData = [{
                        'fileName': file.name + "  ",
                        'fileContent': fileContents
                    }];
                }
                catch (error) {
                    console.log(JSON.stringify(error) + 'Error in creating list');
                }
            };
            reader.readAsDataURL(file);
            this.getDocDetailId(this.loanAppId, this.applicantIdOnTabset);
        }

        setTimeout(() => {
            this.isManual = true;
            console.log('this.isManual after', this.isManual);
        }, 500);
    }

    uploadFileLargeVf(docDetailId) {
        try {
            this.template.querySelector("iframe").contentWindow.postMessage(
                JSON.parse(
                    JSON.stringify({
                        source: "lwc",
                        files: this.fileData,
                        parameters: docDetailId,
                        lightningDomain: this.lightningDomainName
                    })
                ),
                this.vfUrl
            );
        }
        catch (error) {
            console.log('Error while trying to process selected file' + error);
            this.showToastMessage(
                "Error!",
                this.customLabel.CoAppl_Uploading_ErrorMessage,
                "error",
                "sticky"
            );
            this.isLoading = false;
        }
    }

    getDocDetailId(loanAppId, applicationId) {
        try {
            fetchOrCreateDocumentMaster({ masterId: loanAppId, childId: applicationId }).then(data => {
                this.documentDetailId = data;
                return data;
            }).then(data => {
                this.uploadFileLargeVf(data);
                this.uploadFileAndShowToast();
            }).catch(error => {
                this.showToastMessage(
                    "Error!",
                    this.customLabel.CoAppl_DocDetail_ErrorMessage,
                    "error",
                    "sticky"
                );
                this.isLoading = false;
            })
        }
        catch (error) {
            Console.log('Error in getDocDetailsId ' + error);
        }

    }

    handleUploadCallback(message) {
        if (message.data.source === "vf") {
            if (message.data.fileIdList != null || message.data.fileIdList.length > 0) {
                const fields = {};
                fields[DOCDETAILID_FIELD.fieldApiName] = this.documentDetailId;
                fields[DOCDETAILCONTENTDOCUMENTID_FIELD.fieldApiName] = message.data.fileIdList[0];
                const recordInput = { fields };
                updateRecord(recordInput)
                    .then(() => {
                        if (this.fileName.trim() !== '') {
                            // let title = `${this.fileName} uploaded successfully!!`;
                            this.showToastMessage('Success', 'File uploaded successfully!!', 'success', 'sticky');
                        }
                        refreshApex(this.wiredResult);

                    })
                    .catch(error => {
                        this.showToastMessage(
                            "Error!",
                            this.customLabel.CoAppl_Uploading_ErrorMessage,
                            "error",
                            "sticky"
                        );
                        console.log(error);
                    });

            } else {
                this.showToastMessage(
                    "Error!",
                    this.customLabel.CoAppl_Uploading_ErrorMessage,
                    "error",
                    "sticky"
                );
                this.isLoading = false;
            }
        }
    }

    async uploadFileAndShowToast() {
        try {
            //this.isNewFileUpload = true;
            await uploadFile({ documentDetailId: this.documentDetailId, filename: this.fileName, loanAppId: this.loanAppId, applicantId: this.applicantIdOnTabset }).then(() => {
                this.physicalConsentUploaded = true;
                this.wrapObj.ConsentType__c = this.consentType;
                this.handleSave(true, true);
                this.isLoading = false;
                refreshApex(this.wiredResult);
                this.fileUploaded = true;
                this.fileData = null;
            }).catch(error => {
                console.log(JSON.stringify(error));
                this.showToastMessage(
                    "Error!",
                    this.customLabel.CoAppl_Uploading_ErrorMessage,
                    "error",
                    "sticky"
                );
                this.isLoading = false;
            });

        } catch (error) {
            console.error(error);
            this.showToastMessage(
                "Error!",
                this.customLabel.CoAppl_Uploading_ErrorMessage,
                "error",
                "sticky"
            );
            this.isLoading = false;
        }
    }

    handleRationale(event) {
        this.rationaleValue = event.target.value;
        this.rationalValueBkp = this.rationaleValue;
        if (this.rationaleValue !== '' || this.rationaleValue !== undefined) {
            this.template.querySelector("lightning-combobox[data-id=rationaleInput]").setCustomValidity('');
            this.template.querySelector("lightning-combobox[data-id=rationaleInput]").reportValidity();
            this.wrapObj.RationaleUsingPhyConsent__c = this.rationaleValue;
            if (this.rationaleValue === 'Other Reasons') {
                this.showComments = true;
            } else {
                this.wrapObj.Comments__c = '';
                this.showComments = false;
            }
        }
    }

    onChangeComments(event) {
        this.commentsEntered = event.target.value;
        if (this.commentsEntered == '' || this.commentsEntered == undefined) {
            this.template.querySelector("lightning-input[data-id=commentsInput]").setCustomValidity('Please update comments when Other Reasons value is selected');
            this.template.querySelector("lightning-input[data-id=commentsInput]").reportValidity();
            return;
        } else {
            this.template.querySelector("lightning-input[data-id=commentsInput]").setCustomValidity('');
            this.template.querySelector("lightning-input[data-id=commentsInput]").reportValidity()
            this.wrapObj.Comments__c = this.commentsEntered;
        }
    }

    @wire(getSobjectDatawithRelatedRecords, { params: '$params' })
    handleResponse(result) {
        this.isCoApplicant = false;
        this.wiredData = result
        this.mailingAddCounter = 0;
        if (result.data) {
            this.wrapObj = { ...result.data.parentRecord, Age__c: this.getNumber(result.data.parentRecord.DOB__c), InceptionYears__c: this.getNumber(result.data.parentRecord.DOI__c), Nationality__c: 'INDIA' }
            if (this.wrapObj && this.wrapObj.OTP_Verified__c == true) {
                this.disableMobileNumber = true;
                this.isOtpConsentDone = true;
                this.isOTPValidated = true;
                this.otpVerifiedMap = new Map();
                this.otpVerifiedMap[this.wrapObj.MobNumber__c] = true;
                this.mobileOptionSelected = true;
                this.isMobile = true;
                this.isManual = false;
                this.wrapObj.ConsentType__c = 'OTP Consent';
            } else if (this.wrapObj && this.wrapObj.DigitalVerified__c == true) {
                this.disableMobileNumber = true;
                this.isOtpConsentDone = true;
                this.isOTPValidated = true;
                this.otpVerifiedMap = new Map();
                this.otpVerifiedMap[this.wrapObj.MobNumber__c] = true;
                this.mobileOptionSelected = true;
                this.Digital = true;
                this.isManual = false;
                this.wrapObj.ConsentType__c = 'Digital Consent';
                this.disableSendOTP = true;

            } else { }
            if (this.mobileNumberValue !== undefined && (this.mobileNumberValue !== this.wrapObj.MobNumber__c) && this.wrapObj.OTP_Verified__c === false && (this.wrapObj.LoanAppln__r.Product__c == 'Home Loan' || this.wrapObj.LoanAppln__r.Product__c == 'Small Ticket LAP')) {
                this.disableMobileNumber = false;
                this.wrapObj.ConsentType__c = '';
                this.showMobileNumber = false;
                this.isOTPValidated = false;
                this.isMobile = false;
                this.disableSendOTP = false;

            }
            if (this.mobileNumberValue !== undefined && (this.mobileNumberValue !== this.wrapObj.MobNumber__c) && this.wrapObj.DigitalVerified__c === false && (this.wrapObj.LoanAppln__r.Product__c == 'Business Loan' || this.wrapObj.LoanAppln__r.Product__c == 'Personal Loan')) {
                this.disableMobileNumber = false;
                this.wrapObj.ConsentType__c = '';
                this.showMobileNumber = false;
                this.isOTPValidated = false;
                this.digitalConsentDone = false;
                this.isDigital = false;
                this.disableSendOTP = false;

            }
            if (this.wrapObj.ConsentType__c === 'OTP Consent') {
                this.isMobile = true;
                this.isManual = false;
                this.showMobileNumber = true;
                this.disableMobileNumber = true;

            } else if (this.wrapObj.ConsentType__c === 'Physical Consent Upload') {// && this.isMobileNumChanged == false
                this.isMobile = false;
                this.isManual = true;
                this.isDigital = false;
                this.filesPresent = true;
                this.mobileOptionSelected = false;
            } else if (this.wrapObj.ConsentType__c === '') {
                this.isMobile = true;
                this.isDigital = true;
                this.isManual = false;
                this.showMobileNumber = true;
                this.disableMobileNumber = false;
            } else if (this.wrapObj.ConsentType__c === 'OTP Consent') {
                this.isDigital = true;
                this.isManual = false;
                this.showMobileNumber = true;
                this.disableMobileNumber = true;
            }

            if (this.physicalConsentUploaded === true) {
                this.isMobile = false;
                this.isManual = true;
                this.isDigital = false;

            }

            if (this.wrapObj && this.wrapObj.Is_Physical_Consent_Validated__c === false && this.wrapObj.OTP_Verified__c == true) {
                this.isMobile = true;
                this.physicalConsentUploaded = false;
                this.isManual = false;
                this.filesPresent = false;
                this.mobileOptionSelected = true;
                this.disableSendOTP = true;
                this.isOTPValidated = true;
            } else if (this.wrapObj && this.wrapObj.Is_Physical_Consent_Validated__c === true && this.wrapObj.OTP_Verified__c == false && (this.wrapObj.LoanAppln__r.Product__c == 'Home Loan' || this.wrapObj.LoanAppln__r.Product__c == 'Small Ticket LAP')) {
                this.physicalConsentUploaded = true;
                this.isMobile = false;
                this.isManual = true;
                this.filesPresent = true;
                this.mobileOptionSelected = false;
                this.isOTPValidated == false;
            } else if (this.wrapObj && this.wrapObj.Is_Physical_Consent_Validated__c === true && this.wrapObj.DigitalVerified__c == false && (this.wrapObj.LoanAppln__r.Product__c == 'Business Loan' || this.wrapObj.LoanAppln__r.Product__c == 'Personal Loan')) {
                this.physicalConsentUploaded = true;
                this.isDigital = false;
                this.isManual = true;
                this.filesPresent = true;
                this.mobileOptionSelected = false;
                this.isOTPValidated == false;
                this.digitalConsentDone == false;
            }
            else
                if (this.wrapObj && this.wrapObj.Is_Physical_Consent_Validated__c === true && (this.wrapObj.OTP_Verified__c == true || this.wrapObj.DigitalVerified__c == true)) {
                    this.isMobile = true;
                    this.isDigital = true;
                    this.isManual = false;
                    this.physicalConsentUploaded = false;
                    this.filesPresent = false;
                    this.mobileOptionSelected = true;
                    this.disableSendOTP = true;
                    this.isOTPValidated = true;
                    this.digitalConsentDone == true;

                } else
                    if (this.wrapObj && this.wrapObj.Is_Physical_Consent_Validated__c === false
                        && this.wrapObj.OTP_Verified__c === false && this.wrapObj.DigitalVerified__c === false && this.filesList && this.filesList.length > 0) {
                        this.isMobile = false;
                        this.isDigital = false;
                        this.isManual = true;
                        this.filesPresent = true;
                        this.mobileOptionSelected = false;
                        this.isOTPValidated == false;
                        this.digitalConsentDone == false;

                    }




            if (result.data.parentRecord && result.data.parentRecord.ApplType__c) {
                this.mobileNumberValue = result.data.parentRecord.MobNumber__c;
                this.dob = result.data.parentRecord.DOB__c;
                this.gender = result.data.parentRecord.Gender__c;
                this.fathername = result.data.parentRecord.Father_Name__c;
                if (result.data.parentRecord.ApplType__c === 'P') {
                    this.applicantType = 'APPLICANT';
                    this.wrapObj.ApplType__c = 'P';
                    this.checkApplicant = true;
                    this.checkCoApplicant = false;
                }

                if (this.wrapObj.Customer_Profile_Selection_Id__c) {
                    this.selectedRecordId = this.wrapObj.Customer_Profile_Selection_Id__c;
                }
            }
            if (result.error) {
                console.error(result.error);
            }
        }
    }

    getNumber(value) {
        var millis = Date.now() - new Date(value).getTime()
        var age = new Date(millis)
        return Math.abs(age.getUTCFullYear() - 1970)
    }

    blurHandler(event) {
        if (event.target.dataset.type === 'string') {
            let strVal = event.target.value;
            this.wrapObj[event.target.dataset.fieldname] = trimFunction(strVal)
        }
    }
    // LAK-6086 Paresh
    @track productType;
    @track disableKycCheck = false;
    get disableKyc() {
        return !this.hasEditAccess || this.disableKycCheck;
    }

    get disableConsti() {
        return this.disableKyc || this.disabledConstitution;
    }

    fetchApplKyc() {
        let appKycParams = {
            ParentObjectName: "ApplKyc__c",
            ChildObjectRelName: "",
            parentObjFields: ["Id", "Applicant__c"],
            childObjFields: [],
            queryCriteria: " where Applicant__c = '" + this._applicantId + "'"
        };

        getSobjectDataNonCacheable({ params: appKycParams }).then((result) => {
            if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
                this.evaluateAllRequiredRecords();
            }
        })
            .catch((error) => {
                console.log("Verify Applicant LOAN DETAILS #1365", error);
            });

    }

    @track productTypeBLPL
    @track leadId
    fetchLoanDetails() {
        let loanDetParams = {
            ParentObjectName: "LoanAppl__c",
            ChildObjectRelName: "",
            parentObjFields: ["Id", "Name", "Product__c", "Stage__c", "SubStage__c", "Lead__c"],
            childObjFields: [],
            queryCriteria: " where Id = '" + this.loanAppId + "' limit 1"
        };

        getSobjectDataNonCacheable({ params: loanDetParams }).then((result) => {
            if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
                this.productType = result.parentRecords[0].Product__c;
                this.leadId = result.parentRecords[0].Lead__c != null ? result.parentRecords[0].Lead__c : null;
                console.log('Lead idddd: ', this.leadId);
                if (this.productType == 'Business Loan' || this.productType == 'Personal Loan') {
                    this.productTypeBLPL = true;
                } else {
                    this.productTypeBLPL = false;
                }
                this.fetchApplKyc();
            }
        })
            .catch((error) => {
                console.log("Verify Applicant LOAN DETAILS #1480", error);
            });
    }

    evaluateAllRequiredRecords() {
        let categoriesList = ["PAN Documents", "KYC Documents"];
        evaluateAllRequiredRecords({ applicantId: this._applicantId, loanAppId: this.loanAppId, productType: this.productType, stage: this.stage, subStage: this.subStage, categoriesList: categoriesList })
            .then((result) => {
                console.log('Result in Verify App::::1373', result);
                if (result) {
                    this.disableKycCheck = false;
                } else {
                    this.disableKycCheck = true;
                }

            })
            .catch((err) => {
                console.log(' Error in  checking vlidation of uploadeddocuments 1381' + err.message);
            })
            .finally(() => {
            });
    }
    timerStart;
    handleSendLink(event) {
        this.timerStart = true;
        this.disableValidateOTP = false;
        this.disableSendOTP = true

        this.startTimerForLink();
        generateLink({ AppliId: this._applicantId, mobileNumber: this.mobileNumberValue })
            .then(response => {
                console.log('Response from generateOTP' + JSON.stringify(response));
                this.otpSentSuccess = true
                if (response) {
                    this.taskId = response[0];
                    console.log('digital consent task id ', this.taskId);
                }
            })
    }
    ApplicantData;
    isDigitalError
    successMessage
    showConvertButton
    isDigitalValidated
    disableDigitalConsent
    disableSendLink
    handleDigitalConsent() {
        this.isPhyConsentValidated = false
        if (!this._applicantId) {
            console.log('No record ID provided.');
            return;
        } checkDigitalVerified({ AppliId: this._applicantId })
            .then(result => {
                this.ApplicantData = result;
                this.checkDigitalVerified1(result);
            })
            .catch(error => {
                console.error('Error:', error);
            });


    }
    checkDigitalVerified1(Applicant) {
        if (Applicant && Applicant.DigitalVerified__c) {
            this.timerStart = false
            this.disableSendOTP = true;
            this.digitalConsentDone = true;
            this.mobileOptionSelected == true
            this.otpSentSuccess = false
            refreshApex(this.wiredData);
            let ApplicantData = {
                Id: this.wrapObj.Id,
                MobNumber__c: this.mobileNumberValue,
                ConsentType__c: 'Digital Consent',
                LoanAppln__c: this.loanAppId,
                ApplType__c: this.wrapObj.ApplType__c,
                Constitution__c: this.wrapObj.Constitution__c,
                CustProfile__c: this.wrapObj.CustProfile__c,
                KeyManName__c: this.wrapObj.KeyManName__c,
                CompanyName__c: this.wrapObj.CompanyName__c,
                FName__c: this.wrapObj.FName__c,
                MName__c: this.wrapObj.MName__c,
                LName__c: this.wrapObj.LName__c,
                Is_Physical_Consent_Validated__c: this.isPhyConsentValidated,
                OTP_Verified__c: isOTPValidated
            };
            console.log('ApplicantData' + ApplicantData)

            upsertApplicantRecord({ recordData: ApplicantData })
                .then(response => {
                    this.disableSendOTP = true;
                    this.disableValidateOTP = true;
                    refreshApex(this.wiredData);
                })

        } else {
            // this.otpSentSuccess=true
            this.isDigitalError = true;
            this.successMessage = 'Digital Consent is not taken yet!';
            //this.saveState();
        }
        // this.saveState();
    }
    startTimerForLink() {
        this.timeLeft = 120;
        this.intervalId = setInterval(() => {
            if (this.timeLeft > 0) {
                this.disableMobileNumber = true;
                this.hidetimer = false;
                var minutes = Math.floor(this.timeLeft / 60);
                var seconds = this.timeLeft % 60;
                minutes = String(minutes).padStart(2, '0');
                seconds = String(seconds).padStart(2, '0');
                this.otpTimerValue = minutes + ':' + seconds;
                this.timeLeft--;
            } else {
                this.disableMobileNumber = false;
                this.otpSentSuccess = false;
                this.otpTimerValue = '00' + ':' + '00';
                if (this.wrapObj.OTP_Verified__c === true || this.wrapObj.DigitalVerified__c === true) {
                    this.disableSendOTP = true;
                    this.disableMobileNumber = true;
                }
                else {
                    this.disableSendOTP = false;
                    this.disableValidateOTP = true
                }
                this.showValidateOTP = false;
                clearInterval(this.intervalId);
                this.hidetimer = true;
                this.timerStart = false;
            }
        }, 1000);
    }
    handleRefreshClick() {
        this.handleDigitalConsent()
    }
    /*
   getRecordByIdUsingMap() {
        const recordMap = new Map(this.records.map(record => [record.Id, record]));
        return recordMap.get(this.recordId);
    }

    */


}