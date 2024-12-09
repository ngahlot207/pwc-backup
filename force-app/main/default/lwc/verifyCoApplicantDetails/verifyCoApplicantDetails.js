import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValuesByRecordType, getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
//Apex methods
import getLoanApplData from '@salesforce/apex/verifyCoApplicantDetailsController.getLoanApplData';
import getCoApplicantData from '@salesforce/apex/verifyCoApplicantDetailsController.getCoApplicantData';
import upsertCoApplicantRecord from '@salesforce/apex/verifyCoApplicantDetailsController.upsertCoApplicantRecord';
import upsertRecord from '@salesforce/apex/verifyCoApplicantDetailsController.upsertRecord';
import getCoApplicantMobData from '@salesforce/apex/verifyCoApplicantDetailsController.getCoApplicantMobData';
import getRelatedFilesByRecordId from '@salesforce/apex/verifyCoApplicantDetailsController.getRelatedFilesByRecordId';
import deleteFileRecord from '@salesforce/apex/verifyCoApplicantDetailsController.deleteFileRecord';
import uploadFile from '@salesforce/apex/verifyCoApplicantDetailsController.uploadFile';
import updateMaxLimitReached from '@salesforce/apex/verifyCoApplicantDetailsController.updateMaxLimitReached';
import generateOTP from '@salesforce/apex/verifyCoApplicantDetailsController.generateOTP';
import validateOtp from '@salesforce/apex/CreateLeadController.validateOtp';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import evaluateAllRequiredRecords from "@salesforce/apex/DocumentDetailController.evaluateAllRequiredRecords";
import fetchOrCreateDocumentMaster from '@salesforce/apex/verifyCoApplicantDetailsController.fetchOrCreateDocumentMaster';
import getLightningHostname from "@salesforce/apex/DomainNameProvider.getLightningHostname";
import getVisualforceDomain from "@salesforce/apex/DomainNameProvider.getVisualforceDomain";
import checkPanNoStatus from "@salesforce/apex/DocumentDetailController.checkPanNoStatus";
import { updateRecord, deleteRecord } from "lightning/uiRecordApi";
import DOCDETAILCONTENTDOCUMENTID_FIELD from "@salesforce/schema/DocDtl__c.Content_Document_Id__c";
import DOCDETAILID_FIELD from "@salesforce/schema/DocDtl__c.Id";
import CoApplMobNoSAmeAsAppl from '@salesforce/label/c.CoAppl_Mob_No_Same_As_Appl';
import SameMobNoForMultCoAppl from '@salesforce/label/c.SameMobNoForMultCoAppl';
import noOfOtpAttempts from '@salesforce/label/c.CreateLead_OTP_noofAttempts';
import SentOTPSuccess from '@salesforce/label/c.OTP_Sent_Success';
import OTPTimerCoApplicant from '@salesforce/label/c.OTPTimerCoApplicant';
import OTPRetryMessage from '@salesforce/label/c.LeadCapture_OTP_Retry_Message';
import OTPThreeTimesError from '@salesforce/label/c.LeadCapture_OTP_Threetimes';
import mobVerificationFailed from '@salesforce/label/c.CreateLead_OTP_MobileNotVerified';
import uploadOneFile from '@salesforce/label/c.LeadCapture_OTPValidation_Uploadonefile';
import MobileNumSuccess from '@salesforce/label/c.LeadCapture_OTP_MobileNoSuccess';
import ALL_FIELDS_Label from '@salesforce/label/c.LeadCapture_BasicDetails_RequiredFieldsValidation';
import APPLICANT_SUCCESS_Label from '@salesforce/label/c.ApplicantCapture_SuccessMessage';
import ApplicantCapture_Format_ErrorMessage from '@salesforce/label/c.ApplicantCapture_Format_ErrorMessage';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import mobValfailed from '@salesforce/resourceUrl/mobile_validation_failed';
import getUiTheme from "@salesforce/apex/UiThemeController.getUiTheme";
import LightningModal from 'lightning/modal';


import communityUrl from '@salesforce/label/c.community_Url'
//JS file to trim string inputs
import { trimFunction } from 'c/reusableStringTrimComp';

//Message channel section
import { publish, subscribe, unsubscribe, createMessageContext, releaseMessageContext } from 'lightning/messageService';
import RECORDCREATE from "@salesforce/messageChannel/RecordCreate__c";

//LMS details
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";

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
export default class VerifyCoApplicantDetails extends NavigationMixin(LightningElement) {

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
        CoAppl_Uploading_ErrorMessage

    }
    showPhysicalConsent = false;
    showMobileOtpConsent = false;
    //previouspattern =  ^[6-9]\d{9}$

    wiredData;
    @api layoutSize;
    @api hasEditAccess;
    @track helpText = "Please fill other mandatory details first before adding Mobile Number";
    @track disableMode;
    @api isVerified = false;

    @api recordId;
    @api applicantId;
    @api loanAppId;
    @api applicantIdOnTabset;
    @track fileUploaded = false;
    @track otpSentSuccess = false;
    @track disabledMobOtpCon = false;
    @track isLoading = false;
    indexFile;

    @track rationaleValue;
    commentsEntered;
    showComments = false;
    isPhyConsentValidated;


    //new additions 
    showConsent = false;
    isMobile = false;
    @track isManual = false;
    showMobileNumber = false;
    errorMessage = '';
    isOTPValidated = false;
    @track mobileNumberValue;

    disabledConstitution = false;
    disabledTypeOfBorrower = false;
    isIndividual = true;
    @track originalMobileNumber;
    @track applType;

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

    @track applicantTypeOptionsModified = []
    @track customerProfileOptions = []
    @track constitutionOptions = []
    @track BorrowerOptions = []

    @track wrapObj = {
        MobNumber__c: "",
        ApplType__c: "C",
        Constitution__c: "",
        CustProfile__c: "",
        Type_of_Borrower__c: "",
        KeyManName__c: "",
        CompanyName__c: "",
        FName__c: "",
        MName__c: "",
        LName__c: "",
        ConsentType__c: "",
        RationaleUsingPhyConsent__c: "",
        Comments__c: ""
    };

    //file upload properties
    acceptedFormats = ['.pdf', '.png', '.jpeg', '.jpg'];
    @track lightningDomainName;
    @track vfUrl;
    @track documentDetailId;


    loanApplData = null; // Initialize with null
    disbledMobileOTP = false;

    @track primaryApplicantMobNumber;
    @track primariAppMobileVerified; //LAK-3667
    @track showNameSection = false;
    @track isSameNumberAsApplicant = false;
    @track mobCoApplChck;
    @track isSameNumberAsCoApplicant = false;
    @track isSameNumberForGuarantor = false;
    @track isSameMobNoAsAppl = false;
    wiredMobDataDetail;

    subscription = null;
    context = createMessageContext();
    @track existingMobNo = [];




    @wire(getLoanApplData, { recordid: '$recordId' })
    wiredLoanApplData({ error, data }) {
        if (data) {
            // This data is used to understand whether there is a Primary Applicant to the Loan Application, and the mobile number of the applicant
            this.loanApplData = data;
            if (data.Applicant__r && data.Applicant__r.MobNumber__c) {
                this.primaryApplicantMobNumber = data.Applicant__r.MobNumber__c;
                this.primariAppMobileVerified = data.Applicant__r.OTP_Verified__c;
                console.log('this.primariAppMobileVerified', this.primariAppMobileVerified);
            }
            this.checkMobileCondition();
        } else if (error) {
            this.showToastMessage("Error", this.customLabel.CoAppl_PrimaryAppl_ErrorMessage, "error", "sticky");
        }
    }



    @track showMatchingMobileMessage = true;

    @wire(getCoApplicantData, { recordid: '$applicantIdOnTabset' })
    wiredCoApplicantData(wiredResult) {
        let { error, data } = wiredResult;
        this.wiredData = wiredResult;
        this.showMatchingMobileMessage = true;
        //this.mobCoApplChck = '';
        if (data) {
            this.isSameNumberAsApplicant = false;
            this.showNameSection = false;
            const fieldsToUpdate = ["CustProfile__c", "Constitution__c", "Type_of_Borrower__c", "ApplType__c", "MobNumber__c", "Id", "OTP_Verified__c", 'FName__c', 'MName__c', 'LName__c', 'KeyManName__c', 'CompanyName__c', 'LoanAppln__c', 'Is_Physical_Consent_Validated__c', 'Comments__c', 'RationaleUsingPhyConsent__c', 'ConsentType__c'];
            fieldsToUpdate.forEach(field => {
                if (data[field]) {
                    this.wrapObj[field] = data[field];
                    if (field === "MobNumber__c") {
                        //this.show_PhysicalConsent = data[field];
                    }
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
                            this.isMobile = false;
                            this.isDigital = false;
                            this.mobileOptionSelected = false;
                        } else if (data[field] === 'Digital Consent') {
                            this.isDigital = true;
                            this.isManual = false;
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

                    if (field === 'ApplType__c' && data[field] && this.wrapObj['ApplType__c'] === 'G' && this.wrapObj['Type_of_Borrower__c'] === 'Non Financial') {
                        this.disabledTypeOfBorrower = true;
                    }

                }
            });
            if (!this.wrapObj.LoanAppln__c) {
                this.wrapObj.LoanAppln__c = this.loanAppId ? this.loanAppId : null;
            }

            if (data.Is_OTP_Limit_Reached__c === true && data.OTP_Verified__c === false) {
                this.isOTPNotValidated = true;
                this.disableSendOTP = true;
                // To disable mobile num field after failed otp verfictn And To show verfictn Failed ==== DG 
                this.disableMobileNumber = true;
                //this.isMobile = true; //Commeneted as part of LAK-2650
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

            // to show template if applicant mob no same as coapplicant
            //Added this.primariAppMobileVerified for LAK-3667 by Vishnu
            if (this.primaryApplicantMobNumber && this.primaryApplicantMobNumber === this.wrapObj.MobNumber__c && this.primariAppMobileVerified) {
                this.isSameNumberAsApplicant = true;
                this.isSameMobNoAsAppl = true;
            } else {
                this.isSameNumberAsApplicant = false;
            }

            if (data.OTP_Verified__c === true) {
                console.log('Inside block!!!');
                this.isOTPValidated = true;
                //Added this.primariAppMobileVerified For LAK-3667 by Vishnu
                if (this.primaryApplicantMobNumber && this.primaryApplicantMobNumber === this.wrapObj.MobNumber__c && this.primariAppMobileVerified) {
                    this.showPhysicalConsent = true;
                    this.isMobile = false;
                    this.isManual = false;
                    this.isSameNumberAsApplicant = true;
                    this.isSameNumberAsCoApplicant = false;
                    console.log('isSameMobNoAsAppl ', this.isSameMobNoAsAppl);
                    this.isSameMobNoAsAppl = true;
                } else {
                    this.disableMobileNumber = true;
                    this.isSameNumberAsApplicant = false;
                    this.isOTPValidated = true;
                    this.disableSendOTP = true;
                    this.isMobile = true;
                    this.showMobileNumber = true;
                    this.showEnterOtp = false;
                    this.disabledMobOtpCon = true;
                }
            }
            if (data.DigitalVerified__c === true) {
                this.isOTPValidated = true;
                this.digitalConsentDone = true
                if (this.primaryApplicantMobNumber && this.primaryApplicantMobNumber === this.wrapObj.MobNumber__c && this.primariAppMobileVerified) {
                    this.showPhysicalConsent = true;
                    this.isDigital = false;
                    this.isManual = false;
                    this.isSameNumberAsApplicant = true;
                    this.isSameNumberAsCoApplicant = false;
                    this.isSameMobNoAsAppl = true;
                } else {
                    this.disableMobileNumber = true;
                    this.isSameNumberAsApplicant = false;
                    this.isOTPValidated = true;
                    this.digitalConsentDone = true
                    this.disableSendOTP = true;
                    this.isDigital = true;
                    //this.isManual = false;
                    this.showMobileNumber = true;
                    this.showEnterOtp = false;
                    this.disabledMobOtpCon = true;
                }
            }
            if (data.Is_Physical_Consent_Validated__c === true) {
                this.physicalConsentUploaded = true;
                this.showMatchingMobileMessage = false;

            } else {
                console.log('ELSE CONDITIONNNNNNN');
                this.physicalConsentUploaded = false;
                this.showMatchingMobileMessage = true;
            }

            if (data.CustProfile__c === 'HOUSEWIFE' || data.CustProfile__c === 'OTHERS') {
                this.disabledConstitution = true;
                this.disabledTypeOfBorrower = true;
                this.wrapObj.Constitution__c = 'INDIVIDUAL';
                this.wrapObj.Type_of_Borrower__c = 'Non Financial'
            }

            this.checkMobileCondition();
            this.showSpinner = false;
        }
        //LAK-8469 
        if (error) {
            this.showSpinner = false;
            console.error('Error in wiredCoApplicantData ', error);
        }
    }

    @wire(getCoApplicantMobData, { mobNumber: '$mobCoApplChck', recordid: '$applicantIdOnTabset', loanAppId: '$recordId' })
    wiredCoApplicantMobData(wiredMobData) {
        let { error, data } = wiredMobData;
        this.wiredMobDataDetail = wiredMobData;
        if (data) {
            if (data.MobNumber__c !== null && data.OTP_Verified__c === true) {
                this.isSameNumberAsCoApplicant = true;
            } else {
                this.isSameNumberAsCoApplicant = false;
            }
        }
        if (error) {
            this.isSameNumberAsCoApplicant = false
        }
    }

    @track filesPresent;
    @track filesList = [];

    wiredResult;

    @wire(getRelatedFilesByRecordId, { loanAppId: '$loanAppId', applicantId: '$applicantIdOnTabset' })
    wiredResult1(result) {
        this.wiredResult = result;
        this.filesList = [];
        if (result.data) {
            this.filesPresent = true;
            this.isPhyConsentValidated = true;
            this.fileUploaded = true;
            var index = 0;
            result.data.forEach(record => {

                const customKeyRecord = {};
                customKeyRecord.Id = record.ContentDocumentId;
                customKeyRecord.Title = record.Title;
                customKeyRecord.ContentSize = record.ContentSize;
                customKeyRecord.FileExtension = record.FileExtension;
                customKeyRecord.index = index;
                this.filesList.push(customKeyRecord);
                index++;
            });
            if (result.error) {
                this.filesPresent = false;
            }
        } else {
            this.filesPresent = false;
        }

    }

    @track controlShowPhysicalConsent = false;

    get show_consent() {
        return this.isSameMobNoAsAppl === false && this.isSameNumberAsCoApplicant === false;
    }

    get show_PhysicalConsent() {
        return this.isSameMobNoAsAppl === true || this.isSameNumberAsCoApplicant === true;
    }

    checkMobileCondition() {
        //Added this.primariAppMobileVerified for LAK-3667 by Vishnu
        if (this.wrapObj.MobNumber__c && this.primaryApplicantMobNumber && (this.wrapObj.MobNumber__c === this.primaryApplicantMobNumber) && this.primariAppMobileVerified) {
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
            if (this.existingMobNo.includes(this.mobileNumberValue) && this.applType === 'G') {// LAK-4769 Shek
                this.showMatchingMobileMessage = true;
                this.isSameNumberForGuarantor = true;
                this.showConsent = false;
                this.isMobile = false;
                this.isManual = false;
                this.isDigital = false;
                this.mobileNumberValue = undefined;
            } else {
                this.showConsent = true;
                this.showPhysicalConsent = true;
                this.showMobileOtpConsent = true;
                this.isVerified = false;
            }


        } else {
            this.showConsent = false;
            this.isMobile = false;
            this.isManual = false;
            this.isDigital = false;
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

    @track rationaleOptions = [];

    @wire(getPicklistValuesByRecordType, {
        objectApiName: APPLICANT_OBJECT,
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    })
    picklistHandler({ data, error }) {
        if (data) {
            this.constitutionOptions = [...this.generatePicklist(data.picklistFieldValues.Constitution__c)]
            this.BorrowerOptions = [...this.generatePicklist(data.picklistFieldValues.Type_of_Borrower__c)]
            let customerProfileAllOptions = [...this.generatePicklist(data.picklistFieldValues.CustProfile__c)];
            let tempArrayCustProfile = [];
            for (let i = 0; i < customerProfileAllOptions.length; i++) {

                if (customerProfileVisibleOptions.indexOf(customerProfileAllOptions[i].label) > -1) {
                    tempArrayCustProfile.push(customerProfileAllOptions[i]);
                }

            }
            this.customerProfileOptions = [...tempArrayCustProfile];

            let applicantTypeOptions = [...this.generatePicklist(data.picklistFieldValues.ApplType__c)];
            this.applicantTypeOptionsModified = applicantTypeOptions.filter(option => {
                return (option.label !== 'APPLICANT' && option.label !== 'APPOINTEE' && option.label !== 'NOMINEE');

            });

            if (data.picklistFieldValues && data.picklistFieldValues.RationaleUsingPhyConsent__c) {
                this.rationaleOptions = [...this.generatePicklist(data.picklistFieldValues.RationaleUsingPhyConsent__c)];
            }
        }
        if (error) {
            console.error(error)
        }
    }

    @track themeType;


    connectedCallback() {
        if (this.hasEditAccess === false) {
            this.disableMode = true;
            this.disabledConstitution = true;
            this.disabledTypeOfBorrower = true;
            this.disableMobileNumber = true;
            this.disabledMobOtpCon = true;
            this.disableSendOTP = true;
            this.disableValidateOTP = true;
        }
        this.scribeToMessageChannel();
        this.getUIThemeDetails();
        this.fetchLoanDetails();
        this.fetchAllApplDet();
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
        if (values.tabId && values.tabId === this.applicantIdOnTabset) {
            this.handleSave(values.validateBeforeSave, false);
        }
    }

    handleSave(validate, isFileUploadCondition) {
        if (validate) {
            let isInputCorrect = this.checkValidity();
            if (isInputCorrect === true) {
                if (this.isOTPValidated === true || this.physicalConsentUploaded === true) {
                    if (this.physicalConsentUploaded === true) {
                        this.wrapObj.Is_Physical_Consent_Validated__c = true;
                    }
                    this.handleUpsert(isFileUploadCondition);
                } else {
                    this.showToastMessage('Error', this.customLabel.CoAppl_Otp_ErrorMessage, 'error', 'sticky');
                }
            } else {
                this.showToastMessage('Error', this.label.ALL_FIELDS_Label, 'error', 'sticky');
            }
        } else {
            if (this.isSameNumberForGuarantor) {
                this.showToastMessage('Error', 'Mobile Number already used, Please provide another mobile number', 'error', 'sticky');
            } else {
                this.handleUpsert(isFileUploadCondition);
            }

        }
    }

    handleUpsert(isFileUploadCondition) {
        this.showSpinner = true;
        if (!this.wrapObj.LoanAppln__c) {
            this.wrapObj.LoanAppln__c = this.loanAppId ? this.loanAppId : null;
        }
        if (this.wrapObj) {
            upsertRecord({ recordData: this.wrapObj })
                .then(data => {
                    if (isFileUploadCondition === false) {
                        this.checkPanNoAccConstitution();// adde  For LAK-7603
                        //   this.showToastMessage('Success', this.customLabel.VerApplicant_Appl_SuccessMessage , 'success', 'sticky');// removed  For LAK-7603
                    }

                    if (data.Id) {
                        this.wrapObj.Id = data.Id;

                        //if ((data.FName__c || data.LName__c) || data.CompanyName__c) { //LAK-8469 -commented
                        this.publishMC(data.Id);
                        //}
                    }
                    refreshApex(this.wiredData);
                })
                .catch(error => {
                    this.showToastMessage('Error', this.customLabel.CoAppl_ErrorMessage, 'error', 'sticky');
                    this.showSpinner = false;
                })
        } else {
            this.showToastMessage('Error', this.customLabel.CoAppl_ErrorMessage, 'error', 'sticky');
            this.showSpinner = false;
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
                            this.showSpinner = false;
                        } else {
                            this.showSpinner = false;
                            this.showToastMessage('Success', this.customLabel.CoAppl_PrimaryAppl_SuccessMessage, 'success', 'sticky');
                        }
                    }
                })
                .catch(error => {
                    this.showSpinner = false;
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
        refreshApex(this.wiredData);
    }

    //generate picklist from values 
    generatePicklist(data) {
        return data.values.map(item => ({ "label": item.label, "value": item.value }))
    }


    inputChangeHandler(event) {
        if (event.target.dataset.type === 'string') {
            let strVal = event.target.value;
            this.wrapObj[event.target.dataset.fieldname] = strVal.toUpperCase();
        } else {
            this.wrapObj[event.target.dataset.fieldname] = event.target.value;
        }
        if (event.target.value === 'SALARIED') {
            this.disabledConstitution = true;
            this.disabledTypeOfBorrower = false;
            this.wrapObj.Constitution__c = 'INDIVIDUAL';
            this.wrapObj.Type_of_Borrower__c = ''
        }

        if (event.target.value === 'SELF EMPLOYED PROFESSIONAL') {
            this.disabledConstitution = false;
            this.disabledTypeOfBorrower = false;
            this.wrapObj.Constitution__c = '';
            this.wrapObj.Type_of_Borrower__c = ''
        }

        if (event.target.value === 'SELF EMPLOYED NON PROFESSIONAL') {
            this.disabledConstitution = false;
            this.disabledTypeOfBorrower = false;
            this.wrapObj.Constitution__c = '';
            this.wrapObj.Type_of_Borrower__c = ''
        }

        if (event.target.value === 'HOUSEWIFE') {
            this.disabledConstitution = true;
            this.disabledTypeOfBorrower = true;
            this.wrapObj.Constitution__c = 'INDIVIDUAL';
            this.wrapObj.Type_of_Borrower__c = 'Non Financial'
        }
        if (event.target.value === 'OTHERS') {
            this.disabledConstitution = true;
            this.disabledTypeOfBorrower = true;
            this.wrapObj.Constitution__c = 'INDIVIDUAL';
            this.wrapObj.Type_of_Borrower__c = 'Non Financial'
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
            this.wrapObj.FName__c = null;
            this.wrapObj.MName__c = null;
            this.wrapObj.LName__c = null;
        } else {
            this.showNameSection = false;
            this.wrapObj.CompanyName__c = null;
            this.wrapObj.KeyManName__c = null;
            this.wrapObj.FName__c = null;
            this.wrapObj.MName__c = null;
            this.wrapObj.LName__c = null;
        }

        if (event.target.dataset.fieldname === "MobNumber__c") {
            this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('');
            this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
            this.numberOfOTPAttempts = 0;
            this.showEnterOtp = false;
            this.disableSendOTP = false;
            this.mobileOptionSelected = true;
            this.disableValidateOTP = true;
            this.isVerified = false;
            let mobileNum = event.target.value;
            this.wrapObj[event.target.dataset.fieldname] = mobileNum;
            this.mobileNumberValue = mobileNum;
            this.isOTPValidated = false;
            this.isSameNumberAsCoApplicant = false;
            this.isSameMobNoAsAppl = false;
            this.isSameNumberAsApplicant = false;
            this.isSameNumberForGuarantor = false;
            if (this.existingMobNo.includes(mobileNum) && this.applType === 'G') {// LAK-4769 Shek
                this.showMatchingMobileMessage = true;
                this.isSameNumberForGuarantor = true;
                this.showConsent = false;
                this.isMobile = false;
                this.isDigital = false;
                this.isManual = false;
                this.mobileNumberValue = undefined;
            }
            if (mobileNum.length === 10 && this.validatePhoneNumber() === true) {
                console.log('In Moble Change cond');
                this.mobCoApplChck = null;
                this.mobCoApplChck = this.mobileNumberValue;
                console.log('this.mobCoApplChck ', this.mobCoApplChck);
                //Controlling
                //this.show_PhysicalConsent = this.mobileNumberValue;
                this.controlShowPhysicalConsent = false;
                var checkValidScreen = this.checkValidity();
                if (checkValidScreen === false) {
                    this.mobileNumberValue = undefined;
                    this.wrapObj.MobNumber__c = null;
                    this.showToastMessage("Error", this.customLabel.CoAppl_ReqField_ErrorMessage, "error", "sticky");
                } else {
                    this.isSameNumberAsApplicant = false;
                    this.showConsent = true;
                    if (this.originalMobileNumber && this.originalMobileNumber === mobileNum && this.isOTPNotValidated === true) {
                        this.disableSendOTP = true;
                    }
                    //Added this.primariAppMobileVerified For LAK-3667 by Vishnu
                    else if (this.primaryApplicantMobNumber && this.primaryApplicantMobNumber === mobileNum && this.primariAppMobileVerified) {
                        this.wrapObj.OTP_Verified__c = false;
                        this.showPhysicalConsent = true;
                        this.showMobileOtpConsent = false;
                        this.isSameNumberAsApplicant = true;
                        this.isSameNumberAsCoApplicant = false;
                        this.isSameMobNoAsAppl = true;
                    }
                    else {
                        this.showPhysicalConsent = true;
                        this.showMobileOtpConsent = true;
                        this.isVerified = false;
                        this.isSameMobNoAsAppl = false;
                    }
                    this.wrapObj.LoanAppln__c = this.loanAppId ? this.loanAppId : null;
                    upsertCoApplicantRecord({ recordData: this.wrapObj })
                        .then(data => {
                            if (data.Id) {
                                this.wrapObj.Id = data.Id;
                                this.publishMC(data.Id);

                            }
                            refreshApex(this.wiredData);
                        }).catch(error => {
                            console.log('Error occured ' + JSON.stringify(error));
                        })
                }
            }
            else {
                this.showConsent = false;
                this.isMobile = false;
                this.isDigital = false;
                this.isManual = false;
                this.mobileNumberValue = undefined;
            }
        }
        if (event.target.dataset.fieldname === "ApplType__c") {
            this.applType = event.target.value;
            this.isSameNumberForGuarantor = false;
            //this.showConsent = true;//LAK-4769 Shek
            if (this.applType === 'G') {
                this.wrapObj['Type_of_Borrower__c'] = "Non Financial";
                this.disabledTypeOfBorrower = true;
                if (this.existingMobNo.includes(this.wrapObj['MobNumber__c'])) {// LAK-4769 LAK-4769 Shek
                    this.isSameNumberForGuarantor = true;
                    this.isSameMobNoAsAppl = false;
                    this.isSameNumberAsCoApplicant = false;
                    this.showConsent = false;
                    this.isMobile = false;
                    this.isDigital = false;
                    this.isManual = false;
                    this.mobileNumberValue = undefined;
                } else {

                }
            }
            else {
                this.checkMobileCondition();
                this.disabledTypeOfBorrower = false;
            }
        }
    }


    blurHandler(event) {
        if (event.target.dataset.type === 'string') {
            let strVal = event.target.value;
            this.wrapObj[event.target.dataset.fieldname] = trimFunction(strVal)
        }
    }

    handleRecordIdChange() {
        let tempParams = this.params;
        tempParams.queryCriteria = ' where id = \'' + this.recordId + '\'';
        this.params = { ...tempParams };
    }

    @track mobileOptionSelected = true;
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
        }
        if (fieldName === 'manual') {
            this.consentType = 'Physical Consent Upload';
            if (this.isOTPValidated === false || this.isSameMobNoAsAppl === true) {
                this.isManual = true;
                this.isMobile = false;
                this.isDigital = false;
                this.mobileOptionSelected = false;
            } else {
                this.showToastMessage('Success', this.customLabel.CoAppl_Verf_SuccessMessage, 'success', 'sticky');
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
        //var regex = /^\d{10}$/;
        var regex = /[6,7,8,9]{1}[0-9]{9}/;
        return regex.test(this.mobileNumberValue);
    }

    handleMobileChange(event) {
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

    @track disableSendOTP = false;
    @track numberOfOTPAttempts = 0;
    @track showEnterOtp = false;
    @track isOTPNotValidated = false;
    @track hidetimer = false;
    @track timeLeft = OTPTimerCoApplicant;
    @track showValidateOTP = false;
    @track disableValidateOTP = true;
    @track otpGenerated;
    @track disableUploadFiles = false;

    @track taskId;
    handleSendOTP(event) {
        this.otpGenerated = undefined;
        if (this.validatePhoneNumber() === false) {
            this.disableSendOTP = true
        } else if (this.validatePhoneNumber() === true) {
            this.disableSendOTP = false;
        }

        if (this.showEnterOtp === true) {
            let otpElement = this.template.querySelector('.enter-otp');
            otpElement.setCustomValidity('');
            otpElement.reportValidity();
        }

        if (this.mobileNumberValue === '' || this.mobileNumberValue === undefined) {
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
                this.showEnterOtp = false; //hiding validate OTP section 
                this.isOTPNotValidated = true;
                this.disableMobileNumber = true;
                var coApplicantData = {
                    Id: this.wrapObj.Id,
                    MobNumber__c: this.mobileNumberValue
                };
                updateMaxLimitReached({ coAppRecord: coApplicantData }).then(response => {
                    refreshApex(this.wiredData);
                })
                this.hidetimer = true;
            } else {
                this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('');
                this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
                this.timeLeft = OTPTimerCoApplicant;
                //this.timeLeft = 15;
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

    @track consentType;
    handleEnterOtp(event) {
        var charCode = (event.which) ? event.which : event.keyCode;
        if ((charCode < 48 || charCode > 57)) {//charCode != 46 && charCode > 31 && 
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
        //this.consentType = 'OTP Consent';
        validateOtp({ taskId: this.taskId, otp: optEntered })
            .then(response => {
                if (response) {
                    if (response === 'success') {
                        otpElement.setCustomValidity('');
                        this.wrapObj.OTP_Verified__c = true;
                        this.isOTPValidated = true;
                        this.showEnterOtp = false;
                        this.isOTPNotValidated = false;
                        this.otpSentSuccess = false;
                        this.isPhyConsentValidated = false;
                        let coApplicantData = {
                            Id: this.wrapObj.Id,
                            OTP_Verified__c: true,
                            MobNumber__c: this.mobileNumberValue,
                            ConsentType__c: this.consentType,
                            LoanAppln__c: this.loanAppId,
                            ApplType__c: this.wrapObj.ApplType__c,
                            Constitution__c: this.wrapObj.Constitution__c,
                            CustProfile__c: this.wrapObj.CustProfile__c,
                            Type_of_Borrower__c: this.wrapObj.Type_of_Borrower__c,
                            KeyManName__c: this.wrapObj.KeyManName__c,
                            CompanyName__c: this.wrapObj.CompanyName__c,
                            FName__c: this.wrapObj.FName__c,
                            MName__c: this.wrapObj.MName__c,
                            LName__c: this.wrapObj.LName__c,
                            Is_Physical_Consent_Validated__c: this.isPhyConsentValidated
                        };

                        upsertCoApplicantRecord({ recordData: coApplicantData })
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

    @track intervalId;
    otpTimerValue;
    @track disableMobileNumber = false;
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

    previewHandler(event) {
        if (this.themeType === 'Theme4d') {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    selectedRecordId: event.target.dataset.id
                }
            })
        } else {
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: communityUrl + '/s/contentdocument/' + event.target.dataset.id
                },
                state: {
                    selectedRecordId: event.target.dataset.id
                }
            });
        }
    }

    showDeleteConfirmation = false;
    deleteRecordId;
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
                    this.physicalConsentUploaded = false;
                    if (this.filesList && this.filesList.length <= 1) {
                        this.wrapObj.Is_Physical_Consent_Validated__c = false;
                        this.handleUpsert();
                    }
                    refreshApex(this.wiredResult);
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



    @track fileData;
    @track fileName = '';
    @track documentDetaildId = '';
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
                            this.showToastMessage('Success', 'File Uploaded Successfully !!', 'success', 'sticky');
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
        if (this.commentsEntered === '' || this.commentsEntered === undefined) {
            this.template.querySelector("lightning-input[data-id=commentsInput]").setCustomValidity('Please update comments when Other Reasons value is selected');
            this.template.querySelector("lightning-input[data-id=commentsInput]").reportValidity();
            return;
        } else {
            this.template.querySelector("lightning-input[data-id=commentsInput]").setCustomValidity('');
            this.template.querySelector("lightning-input[data-id=commentsInput]").reportValidity()
            this.wrapObj.Comments__c = this.commentsEntered;
        }
    }

    // LAK-6086 Paresh
    @track productType;
    @track disableKycCheck = false;
    get disableKyc() {
        return this.disableMode || this.disableKycCheck;
    }

    get borrType() {
        return this.disableKyc || this.disabledTypeOfBorrower;
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
            queryCriteria: " where Applicant__c = '" + this.applicantIdOnTabset + "'"
        };

        getSobjectDataNonCacheable({ params: appKycParams }).then((result) => {
            if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
                console.log('Result in Verify App::::1360', result);
                this.evaluateAllRequiredRecords();
            }
        })
            .catch((error) => {
                console.log("Verify Applicant LOAN DETAILS #1365", error);
            });

    }
    fetchAllApplDet() {
        let appKycParams = {
            ParentObjectName: "Applicant__c",
            ChildObjectRelName: "",
            parentObjFields: ["Id", "MobNumber__c", "ApplType__c"],
            childObjFields: [],
            queryCriteria: " where LoanAppln__c = '" + this.loanAppId + "'"
        };

        getSobjectDataNonCacheable({ params: appKycParams }).then((result) => {
            console.log('RESULT 1365: ', result);
            let existingMobNoLoc = [];
            if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
                let res = result.parentRecords;
                res.forEach(ele => {
                    if (ele.MobNumber__c != null && ele.Id != this.applicantIdOnTabset && (ele.ApplType__c == 'P' || ele.ApplType__c == 'C')) {
                        existingMobNoLoc.push(ele.MobNumber__c);
                    }
                });
                this.existingMobNo = existingMobNoLoc;
                console.log('Exinting Mob no List :: ', this.existingMobNo);
            }
        })
            .catch((error) => {
                console.log("Verify Applicant LOAN DETAILS #1365", error);
            });

    }

    fetchLoanDetails() {
        let loanDetParams = {
            ParentObjectName: "LoanAppl__c",
            ChildObjectRelName: "",
            parentObjFields: ["Id", "Name", "Product__c", "Stage__c", "SubStage__c"],
            childObjFields: [],
            queryCriteria: " where Id = '" + this.loanAppId + "' limit 1"
        };

        getSobjectDataNonCacheable({ params: loanDetParams }).then((result) => {

            if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
                this.productType = result.parentRecords[0].Product__c;
                if (this.productType == 'Business Loan' || this.productType == 'Personal Loan') {
                    this.productTypeBLPL = true;
                } else {
                    this.productTypeBLPL = false;
                }
                if (this.applicantIdOnTabset !== 'new') {
                    this.fetchApplKyc();
                }

            }
        })
            .catch((error) => {
                console.log("Verify Co-Applicant LOAN DETAILS #1398", error);
            });
    }

    evaluateAllRequiredRecords() {
        let categoriesList = ["PAN Documents", "KYC Documents"];
        evaluateAllRequiredRecords({ applicantId: this.applicantIdOnTabset, loanAppId: this.loanAppId, productType: this.productType, stage: this.stage, subStage: this.subStage, categoriesList: categoriesList })
            .then((result) => {
                if (result) {
                    this.disableKycCheck = false;
                    console.log('Result in Verify App::::1408', result);
                } else {
                    this.disableKycCheck = true;
                }

            })
            .catch((err) => {
                console.log(' Error in  checking vlidation of uploadeddocuments 1415' + err.message);
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
        debugger
        generateLink({ AppliId: this.applicantIdOnTabset, mobileNumber: this.mobileNumberValue })
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
    isDigital
    digitalConsentDone
    otpSentSuccess
    handleDigitalConsent() {
        this.isPhyConsentValidated = false
        if (!this.applicantIdOnTabset) {
            console.log('No record ID provided.');
            return;
        } checkDigitalVerified({ AppliId: this.applicantIdOnTabset })
            .then(result => {
                this.ApplicantData = result;
                this.checkDigitalVerified1(result);
            })
            .catch(error => {
                console.error('Error:', error);
            });


    }
    digitalConsentDone
    checkDigitalVerified1(Applicant) {
        if (Applicant && Applicant.DigitalVerified__c) {
            this.timerStart = false
            this.disableSendOTP = true;
            this.digitalConsentDone = true;
            this.mobileOptionSelected == true
            this.otpSentSuccess = false
            refreshApex(this.wiredData);
            let ApplicantData = {
                Id: this.applicantIdOnTabset,
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
            // this.otpSentSuccess=false
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



}