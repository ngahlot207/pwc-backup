import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { FlowNavigationNextEvent, FlowNavigationBackEvent, FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, publish, MessageContext, APPLICATION_SCOPE, unsubscribe } from 'lightning/messageService';
import mobValfailed from '@salesforce/resourceUrl/mobile_validation_failed';
import generateOTP from '@salesforce/apex/CreateLeadController.generateOTP';
import validateOtp from '@salesforce/apex/CreateLeadController.validateOtp';
import updateLeadDigitalVerified from '@salesforce/apex/verifyCoApplicantDetailsController.updateLeadDigitalVerified';
import updateLead from '@salesforce/apex/CreateLeadController.updateLead';
import updateMaxLimitReached from '@salesforce/apex/CreateLeadController.updateMaxLimitReached';
import isMobileNumberVerified from '@salesforce/apex/CreateLeadController.isMobileNumberVerified';
import getUploadedFilesError from '@salesforce/apex/CreateLeadController.getUploadedFiles';
import getUploadedFiles from '@salesforce/apex/CreateLeadController.getUploadedFilesUpdated';
import getLeadData from '@salesforce/apex/CreateLeadController.getLeadData';
import getLeadPhyData from '@salesforce/apex/CreateLeadController.getLeadPhyData';
import OTPTimer from '@salesforce/label/c.OTP_Timer';
import LinkTimer from '@salesforce/label/c.Link_Timer';
import noOfOtpAttempts from '@salesforce/label/c.CreateLead_OTP_noofAttempts';
import OTPRetryMessage from '@salesforce/label/c.LeadCapture_OTP_Retry_Message';
import OTPThreeTimesError from '@salesforce/label/c.LeadCapture_OTP_Threetimes';
import mobVerificationFailed from '@salesforce/label/c.CreateLead_OTP_MobileNotVerified';
import uploadOneFile from '@salesforce/label/c.LeadCapture_OTPValidation_Uploadonefile';
import MobileNumSuccess from '@salesforce/label/c.LeadCapture_OTP_MobileNoSuccess';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import RATIONALE_BEHIND from '@salesforce/schema/Lead.RationaleUsingPhyConsent__c';
import LEADDATAMC from '@salesforce/messageChannel/LeadDataMessageChannel__c';
import QUE_IMAGE from "@salesforce/resourceUrl/QuestionMarkImage";
import { getRecord, deleteRecord, getFieldValue } from "lightning/uiRecordApi";
import getSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords'
import fetchOrCreateDocumentMaster from '@salesforce/apex/verifyCoApplicantDetailsController.fetchOrCreateDocumentMaster';
import getLightningHostname from "@salesforce/apex/DomainNameProvider.getLightningHostname";
import getVisualforceDomain from "@salesforce/apex/DomainNameProvider.getVisualforceDomain";
import CURRENTUSERID from '@salesforce/user/Id';
import { RefreshEvent } from 'lightning/refresh';
import { refreshApex } from '@salesforce/apex';
import LeadOtp_ReqField_ErrorMessage from '@salesforce/label/c.LeadOtp_ReqField_ErrorMessage';
import LeadOtp_MobileNumber_ErrorMessage from '@salesforce/label/c.LeadOtp_MobileNumber_ErrorMessage';
import LeadOtp_Otp_ErrorMessage from '@salesforce/label/c.LeadOtp_Otp_ErrorMessage';
import LeadOtp_ValidateOtp_ErrorMessage from '@salesforce/label/c.LeadOtp_ValidateOtp_ErrorMessage';
import LeadOtp_FileSize_ErrorMessage from '@salesforce/label/c.LeadOtp_FileSize_ErrorMessage';
import LeadOtp_FileSize_ErrorMessage_BLPL from '@salesforce/label/c.LeadOtp_FileSize_ErrorMessage_BLPL'; 
import LeadOtp_UploadingFile_ErrorMessage from '@salesforce/label/c.LeadOtp_UploadingFile_ErrorMessage';
import LeadOtp_Has_SuccessMessage from '@salesforce/label/c.LeadOtp_Has_SuccessMessage';
import LeadOtp_Succ_SuccessMessage from '@salesforce/label/c.LeadOtp_Succ_SuccessMessage';
import LeadOtp_leadClouse_ErrorMessage from '@salesforce/label/c.LeadOtp_leadClouse_ErrorMessage';
import LeadOtp_FileType_ErrorMessage from '@salesforce/label/c.LeadOtp_FileType_ErrorMessage';
import LeadOtp_FileType_ErrorMessage_BLPL from '@salesforce/label/c.LeadOtp_FileType_ErrorMessage_BLPL';
import LeadOtp_Del_SuccessMessage from '@salesforce/label/c.LeadOtp_Del_SuccessMessage';
import checkDuplicateLead from '@salesforce/apex/LeadHandler.checkDuplicateLead';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import DuplicateLeadMessage from '@salesforce/label/c.Duplicate_Match_Found_on_Lead_Message';
import DuplicateMSG from '@salesforce/label/c.Duplicate_Match_Found_on_Lead_Message_BL_and_PL';
import FraudLeadMessage from '@salesforce/label/c.Fraud_Record_Found_on_Lead_Message';

// import CurrentUserId from '@salesforce/user/Id';

// const USER_FIELDS = ['Profile.Name','Name','Alias'];
import PRODUCT_FIELD from '@salesforce/schema/Lead.Product__c';
import DIGITAL_VERIFIED from '@salesforce/schema/Lead.Digital_Verified__c';
import checkDigitalVerified from '@salesforce/apex/CreateLeadController.checkDigitalVerified';
import checkDigitalVerifiedLead from '@salesforce/apex/verifyCoApplicantDetailsController.checkDigitalVerifiedLead';
import generateLink from '@salesforce/apex/CreateLeadController.generateLink';
//File upload size
const MAX_FILE_SIZE = 10485760; //in bytes 10 MB now
const MAX_FILE_SIZE1 = 26214400; //in bytes 25 MB now

export default class LeadOtpConsent extends NavigationMixin(LightningElement) {
    customLabel = {
        LeadOtp_ReqField_ErrorMessage,
        LeadOtp_MobileNumber_ErrorMessage,
        LeadOtp_Otp_ErrorMessage,
        LeadOtp_ValidateOtp_ErrorMessage,
        LeadOtp_FileSize_ErrorMessage,
        LeadOtp_FileSize_ErrorMessage_BLPL,
        LeadOtp_UploadingFile_ErrorMessage,
        LeadOtp_Has_SuccessMessage,
        LeadOtp_Succ_SuccessMessage,
        LeadOtp_leadClouse_ErrorMessage,
        LeadOtp_FileType_ErrorMessage,
        LeadOtp_FileType_ErrorMessage_BLPL,
        LeadOtp_Del_SuccessMessage,
        DuplicateLeadMessage,
        DuplicateMSG,
        FraudLeadMessage

    }
    // API properties
    @api isValid;
    @api mobileNumber;// ='9160092656';
    @api leadRecordId;//='00QC40000068MvyMAE';
    @api dispositionStatus;
    @api OTPPreviousValue = false;
    @api updatedMobileNumber;
    @api Var_Rationale_behind_Phy_Consent;
    @api Var_Rationale_Phy_Consnet_Other_Reason;
    @api VarRationaleValue;
    @api VarRationaleCommentsValue;
    @api pvCityVerified
    @api pvChannelVerified
    @api ChannelValue_Bkp
    @api CityValue_Bkp
    @api contentDocuments = [];


    @api digital;
    @api digitalValidated;

    //extra
    @api leadClosureValue
    @api contentVesrsionIds;
    @api contentVesrsions = [];
    @api productValue;
    @api digitalVerified;

    //Preview
    @track fileUrl;
    @track showModal = false;
    @track modalUrl = '';
    @track DSAUser
    // Tracked properties
    @track mobileNumberValue;
    @track rationaleValue;
    @track consentType;
    @track isShowModal = false;
    @track closureReason;
    @track showFiles = false;
    // @track userRoleId;
    // @track userProfileId;
    // @track currentUserId = CurrentUserId;
    // @track userName;
    // Label object
    label = {
        OTPRetryMessage,
        uploadOneFile,
        MobileNumSuccess,
        OTPThreeTimesError,
        noOfOtpAttempts,
        mobVerificationFailed
    };

    mobFailedImage = mobValfailed;
    image = QUE_IMAGE;

    // Accepted file formats for file upload
    acceptedFormats = ['.pdf', '.png', '.jpeg', '.jpg'];
    acceptedFormats1 = ['.pdf', '.jpeg', '.jpg'];
    @track lightningDomainName;
    @track vfUrl;
    @track documentDetailId;
    @track deleteMsg = `Do you want to delete the document?`;
    @track isModalOpen = false;
    @track docId;
    @track hasDocumentId = false;
    @track contVersDataList = []
    @track contentDocumentType;
    @track contentDocumentId;

    // Booleans for different conditions
    isMobile = false;
    isManual = false;
    isDigital = false;
    isDigitalValidated = false;
    isError = false;
    showConvertButton = false;
    @api otpVerified = false;
    @api isPhyConsentVerified = false;
    numberOfOTPAttempts = 0;
    errorMessage = '';
    otpGenerated;
    timeLeft = OTPTimer;
    timeLeftForLink = LinkTimer;
    disableSendOTP = false;
    disableSendLink = false;
    showValidateOTP = false;
    disableValidateOTP = true;
    isOTPValidated = false;
    isOTPNotValidated = false;
    showMobileNumber = false;
    showEnterOtp = false;
    intervalId;
    disablePhyConsent = false;
    disableMobileConsent = false;
    disableDigitalConsent = false;
    otpTimerValue;
    linkTimerValue;
    @track fileNames = [];
    otpflag;
    showRadiobtn;
    hidetimer = false;
    showComments = false;
    showAdditionalComments = false;
    commentsEntered;
    addCommentsEntered;
    disableConversionBtn = false;
    isRoleRMSM = false;
    leadStaus;

    get _showConvertButton() {
        return this.showConvertButton && this.isRoleRMSM;
    }

    // Wire methods
    @wire(MessageContext)
    context
    @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
    objectInfoLead;
    @wire(getPicklistValues, { recordTypeId: '$objectInfoLead.data.defaultRecordTypeId', fieldApiName: RATIONALE_BEHIND })
    RationalePicklistValues;

    @wire(getUploadedFiles, { recordId: '$leadRecordId' })
    wiredFiles(result) {
        this.wiredFilesList = result;
        if (result.data) {
            console.log('data--->' + result.data);
            //this.wiredFilesList = result.data;
            let tempFiles = []
            tempFiles = result.data.map(file => ({
                name: file.Title,
                size: file.ContentSize,
                cDId: file.Id,
                //FileExtension:file.FileType
              FileExtension:file.FileExtension

            }));
            this.fileNames = [...tempFiles];
            console.log('this.fileNames ' , this.fileNames);
            
            if (this.fileNames.length > 0) {
                // console.log('fileNames--->' + this.fileNames);
                // console.log('fileNames length--->' + this.fileNames.length);
                //this.otpVerified = true; 
            }
        } else if (result.error) {
            // Handle error
        }
    }

    /////////////////////////////////

    get product1new() {
        /*let a= getFieldValue(this.wiredProduct.data, PRODUCT_FIELD);
        return a == 'Home Loan' || a == 'Small Ticket LAP';*/
        return this.product1;
    }

    get product2new() {
        // let a= getFieldValue(this.wiredProduct.data, PRODUCT_FIELD);
        // return a == 'Business Loan' || a == 'Personal Loan';
        return this.product2;

    }

    @track product
    @track product1
    @track product2

    @wire(getRecord, { recordId: '$leadRecordId', fields: [PRODUCT_FIELD] })
    currentRecordInfo({ error, data }) {
        if (data) {
            //this.showSpinner = true;
            console.log('currentRecordInfo ', data);
            this.product = data.fields.Product__c.value;
            if (this.product && (this.product == 'Home Loan' || this.product == 'Small Ticket LAP' || this.product == 'Loan Against Property')) {
                this.product1 = true;
            } else if (this.product && (this.product == 'Business Loan' || this.product == 'Personal Loan')) {
                this.product2 = true;
            }
        } else if (error) {
            this.error = error;
            console.log('Error is ', this.error);
            //this.showSpinner = false;
        }

    }

    

    



    ///////////////////////////////

    // @wire(getRecord, { recordId: '$currentUserId', fields: USER_FIELDS })
    // wiredUser({ error, data }) {
    //     console.log('data from user---->'+JSON.stringify(data));
    //     if (data) {

    //         this.userRoleId = data.fields.UserRole.Name.value;
    //         this.userProfileId = data.fields.Profile.Name.value;
    //         this.userName = data.fields.Name.value;
    //     } else if (error) {
    //         // Handle error
    //         console.log('Error fetching user information', error);
    //     }
    // }

    @track previousMobileNumberValue = '';


    connectedCallback() {
        console.log('this.productValue ', this.productValue);
        if (this.productValue && (this.productValue == 'Home Loan' || this.productValue == 'Small Ticket LAP' || this.productValue == 'Loan Against Property')) {
            this.product1 = true;
        } else if (this.productValue && (this.productValue == 'Business Loan' || this.productValue == 'Personal Loan')) {
            this.product2 = true;
        }
        

        this.loadState();

        
        // this.isDigital = localStorage.getItem('isDigital') === 'true';
        // //this.isManual = localStorage.getItem('isManual') === 'true';
        // this.mobileNumberValue = localStorage.getItem('mobileNumberValue') || '';
        // this.isDigitalValidated = localStorage.getItem('isDigitalValidated') === 'true';
        
        // console.log('pvcity--' + this.pvCityVerified);
        // console.log('pvchannel--' + this.pvChannelVerified);
        // console.log('CityValue_Bkp in otp--' + this.CityValue_Bkp);
        // console.log('ChannelValue_Bkp in otp--' + this.ChannelValue_Bkp);
        // console.log('currentUserId--'+this.currentUserId);
        // console.log('User name:', this.userName);
        // console.log('User Role ID:', this.userRoleId);
        // console.log('User Profile ID:', this.userProfileId);
        // console.log('leadRecordId--->' + this.leadRecordId);
        // console.log('mobile--->' + this.mobileNumber);
        // console.log('dispositionStatus--->' + this.dispositionStatus);
        // console.log('OTPPreviousValue--->' + this.OTPPreviousValue);
        // console.log('OTPfieldValue--->' + this.OTPfieldValue);
        // console.log('other reason comments enterd--->' + this.Var_Rationale_Phy_Consnet_Other_Reason);
        // console.log('Rationale Phy consent--->' + this.Var_Rationale_behind_Phy_Consent);
        // console.log('other reason comments enterd-111-->' + this.VarRationaleCommentsValue);
        // console.log('Rationale Phy consent--222->' + this.VarRationaleValue);
        //TAB Comment Start
        // this.commentsEntered = this.VarRationaleCommentsValue;
        // this.rationaleValue = this.VarRationaleValue;
        // if (this.rationaleValue === 'Other Reasons') {
        //     console.log('connected rationaleValue-->' + this.rationaleValue);
        //     this.showComments = true;
        // } else {
        //     console.log('connected rationaleValue-->' + this.rationaleValue);
        //     this.showComments = false;
        // }
        //TAB comment end
        this.subscribeHandler();
        // Set mobile number value
        this.mobileNumberValue = this.mobileNumber;
        var recId = this.leadRecordId;
        // console.log('recId--->' + recId);
        // Call Apex method to check if the mobile number is verified
        isMobileNumberVerified({ mobileNUmber: this.mobileNumberValue, leadId: this.leadRecordId })
            .then(response => {
                console.log('response from isMobileNumberVerified' + response);
                this.otpVerified = response;
                if (this.otpVerified == true) {
                    this.showRadiobtn = false;
                    this.isMobile = true;
                    this.showMobileNumber = true;;
                    this.isOTPValidated = true;
                    this.disablePhyConsent = true;
                    this.disableSendOTP = true;
                    this.disableMobileConsent = true;
                    this.showConvertButton = true;
                }
            });
        // console.log('otpVerified--' + this.otpVerified);
        // console.log('isMobile--' + this.isMobile);
        // console.log('showMobileNumber--' + this.showMobileNumber);
        // console.log('isOTPValidated--' + this.isOTPValidated);
        // console.log('disablePhyConsent--' + this.disablePhyConsent);
        // console.log('disableSendOTP--' + this.disableSendOTP);

        /*getUploadedFiles({recordId:recId})
            .then(data =>{
                console.log('response from getUploadedFiles'+JSON.stringify(data));
                this.fileNames = data.map(file => ({
                    name: file.Title,
                    size: file.ContentSize,
                    cDId: file.Id
    
                }));
                if(this.fileNames.length>0){
                    console.log('fileNames--->'+this.fileNames);
                    console.log('fileNames length--->'+this.fileNames.length);
                    this.otpVerified = true;
                    this.isManual = true;
                    this.showConvertButton = true;
                    this.rationaleValue = this.VarRationaleValue;
                    console.log('checkbox value ##228--->', this.isManual);
                }
            });*/
        this.getUploadedFiles(recId);


        getLeadData({ recordId: recId })
            .then(data => {
                // console.log('response from getLeadData' + JSON.stringify(data));
                this.otpLimitReached = data.Is_OTP_Limit_Reached__c;
                // console.log('data.MobilePhone---' + data.MobilePhone);
                // console.log('this.mobileNumberValue---' + this.mobileNumberValue);
                if (data.MobilePhone == this.mobileNumberValue) {
                    console.log('Entered  if getLeadData ');
                    if (data.Is_OTP_Limit_Reached__c == true) {
                        this.isOTPNotValidated = true;
                        this.disableSendOTP = true;
                    } else if (data.OTP_Verified__c == true) {
                        // console.log('Entered  else if getLeadData ');
                        //this.isOTPValidated = true; //LAK-3680
                        this.disableSendOTP = true;
                    }
                }
            })
           // lak-7768
            getLeadPhyData({ recordId: recId })
            .then(data => {
                console.log('response from getLeadPHYData' + JSON.stringify(data));
                this.rationaleValue = data.RationaleUsingPhyConsent__c;
                console.log('rthis.rationaleValue getLeadPHYData' + this.rationaleValue);
                if (this.rationaleValue === 'Other Reasons') {
                    console.log('rationaleValue-->' + this.rationaleValue);
                    this.showComments = true;
                    this.commentsEntered=data.Comments__c
                } else {
                    this.showComments = false;
                }
            })    
        let parameter1 = {
            ParentObjectName: 'TeamHierarchy__c',
            ChildObjectRelName: null,
            parentObjFields: ['Id', 'Employee__c', 'EmpRole__c'],
            childObjFields: [],
            queryCriteria: ' where Employee__c  = \'' + CURRENTUSERID + '\' LIMIT 1'
        }

        getSobjDataWIthRelatedChilds({ params: parameter1 })
            .then(result => {
                // console.log('result of team TeamHierarchy:', JSON.stringify(result));
                if (result.parentRecord.EmpRole__c === 'RM' || result.parentRecord.EmpRole__c === 'SM') {
                    console.log('RM SM user');
                    this.isRoleRMSM = true;
                }
                else if(result.parentRecord.EmpRole__c === 'DSA'){
                    this.DSAUser = true;
                 console.log('DSA is logged');
                }

            })

        getVisualforceDomain({}).then((result) => {
            this.vfUrl = result;
        });

        getLightningHostname({}).then((result) => {
            this.lightningDomainName = result;
            // console.log("lightning page Domain Name ==>", this.lightningDomainName);
        });

        window.addEventListener(
            "message",
            this.handleUploadCallback.bind(this)
        );



        ////////
        //this.previousMobileNumberValue = this.mobileNumberValue;
        this.previousMobileNumberValue = localStorage.getItem(`previousMobileNumberValue_${this.leadRecordId}`) || '';

        // if (!this.previousMobileNumberValue) {
        //     this.previousMobileNumberValue = this.mobileNumberValue;
        // }

        console.log('this.mobilenumbervalueeeeee ', this.mobileNumberValue);
        console.log('this.previousnumbervalueeeeee ', this.previousMobileNumberValue);
        
        if (this.mobileNumberValue !== this.previousMobileNumberValue) {
            this.handleMobileNumberUpdate();
        }
        //this.handleMobileNumberUpdate();
        // if (this.mobileNumberValue !== this.previousMobileNumberValue) {
        //     this.handleMobileNumberUpdate();
        //     // Update the stored mobile number
        //     this.previousMobileNumberValue = this.mobileNumberValue;
        // }

        /////
    }

    handleMobileNumberUpdate() {
        // if (this.mobileNumberValue && this.previousMobileNumberValue) {
            console.log('this.mobilenumbervalueeeeee 1', this.mobileNumberValue);
            console.log('this.previousnumbervalueeeeee 1', this.previousMobileNumberValue);
        if (this.mobileNumberValue !== this.previousMobileNumberValue) {
            console.log('Mobile number has changed.');

            // Reset digital consent and related UI elements
            this.isDigitalValidated = false;
            this.successMessage = '';
            this.disableSendOTP = false;
            //this.disableMobile = true;

            // Update lead record to reset digital consent
            this.resetDigitalConsent();

            // Update previous mobile number value to the new one
            this.previousMobileNumberValue = this.mobileNumberValue;

            // Store the updated previousMobileNumberValue in local storage
            localStorage.setItem(`previousMobileNumberValue_${this.leadRecordId}`, this.previousMobileNumberValue);
            console.log('this.mobilenumbervalueeeeee 2', this.mobileNumberValue);
            console.log('this.previousnumbervalueeeeee 2', this.previousMobileNumberValue);
        }
    

        

        
        // else{
        //     console.log('this.mobilenumbervalueeeeee 2', this.mobileNumberValue);
        //     console.log('this.previousnumbervalueeeeee 2', this.previousMobileNumberValue);
        // }
    }

    resetDigitalConsent() {
        if (!this.leadRecordId) {
            console.log('No record ID provided.');
            return;
        }

        // Call Apex method to reset the digital consent
        updateLeadDigitalVerified({ leadId: this.leadRecordId })
            .then(() => {
                console.log('Lead digital consent has been reset.');
            })
            .catch(error => {
                console.error('Error resetting digital consent:', error);
            });
    }


    getUploadedFiles(recId) {
        getUploadedFiles({ recordId: recId })
            .then(data => {
                this.contentDocuments = data;
                // console.log('response from getUploadedFiles//306' + JSON.stringify(data));
                this.fileNames = data.map(file => ({
                    name: file.Title,
                    size: file.ContentSize,
                    cDId: file.Id,
                    fileExtension:file.FileExtension,
                  //  cvId: file.ContentDocumentId

                }));
                console.log('this.fileNames ' , this.fileNames);
                if (this.fileNames.length > 0) {
                        // console.log('fileNames--->' + this.fileNames);
                        // console.log('fileNames length--->' + this.fileNames.length);
                    // this.otpVerified = true; //Commented as part of LAK-3680 Bug
                    if (this.isOTPValidated === false) { //LAK-3680
                        this.isManual = true;
                    }
                    this.showConvertButton = true;
                    //tab COmment Start
                    // if (this.rationalValueBkp) {
                    //     this.rationaleValue = this.rationalValueBkp;
                    //     console.log(' uploaf dile rationaleValue-->' + this.rationaleValue);
                    // } else {
                    //     this.rationaleValue = this.VarRationaleValue;
                    //     console.log('uploaf dile rationaleValue-->' + this.rationaleValue);
                    // }
                    //tab comment end
                    // console.log('checkbox value ##228--->', this.isManual);
                }
            });
    }

////////////

loadState() {
    if (this.leadRecordId) {
    const savedState = localStorage.getItem(`pageState_${this.leadRecordId}`);
    //const savedState = localStorage.getItem('pageState');
    if (savedState) {
        const state = JSON.parse(savedState);
        this.isMobile = state.isMobile;
        this.isManual = state.isManual;
        this.isDigital = state.isDigital;
        this.showMobileNumber = state.showMobileNumber;
        this.disableMobileConsent = state.disableMobileConsent;
        this.disablePhyConsent = state.disablePhyConsent;
        this.disableDigitalConsent = state.disableDigitalConsent;
        this.disableSendLink = state.disableSendLink;
        this.disableSendOTP = state.disableSendOTP;
        this.disableValidateOTP = state.disableValidateOTP;
        this.isOTPValidated = state.isOTPValidated;
        this.errorMessage = state.errorMessage;
        this.successMessage = state.successMessage;
        this.isDigitalValidated = state.isDigitalValidated;
        this.isDigitalError = state.isDigitalError;
    }
}
}

saveState() {
    if (this.leadRecordId) {
    const state = {
        isMobile: this.isMobile,
        isManual: this.isManual,
        isDigital: this.isDigital,
        showMobileNumber: this.showMobileNumber,
        disableMobileConsent: this.disableMobileConsent,
        disablePhyConsent: this.disablePhyConsent,
        disableDigitalConsent: this.disableDigitalConsent,
        disableSendLink: this.disableSendLink,
        disableSendOTP: this.disableSendOTP,
        disableValidateOTP: this.disableValidateOTP,
        isOTPValidated: this.isOTPValidated,
        errorMessage: this.errorMessage,
        successMessage: this.successMessage,
        isDigitalValidated: this.isDigitalValidated,
        isDigitalError: this.isDigitalError
    };
    //localStorage.setItem('pageState', JSON.stringify(state));
    localStorage.setItem(`pageState_${this.leadRecordId}`, JSON.stringify(state));
    }
}



leadData;
@track successMessage;
@track showSpinner = false;
handleDigitalConsent() {

    if (!this.leadRecordId) {
        //this.successMessage = 'No record ID provided.';
        console.log('No record ID provided.');
        return;
    }

        // Call the Apex method imperatively
        checkDigitalVerifiedLead({ leadId: this.leadRecordId })
            .then(result => {
                this.leadData = result;
                this.checkDigitalVerified1(result);
            })
            .catch(error => {
                //this.successMessage = `Error fetching lead data: ${error.body.message}`;
                console.error('Error:', error);
            });

    
}


isDigitalError = false;

checkDigitalVerified1(lead) {
    if (lead && lead.Digital_Verified__c) {
        this.timerStart = false;
        this.isDigitalError = false;
        this.successMessage = 'Digital Consent taken!';
        this.isDigitalValidated = true;
        this.disableDigitalConsent = true;

        this.showRadiobtn = false;
        this.showMobileNumber = true;
        this.disablePhyConsent = true;
        this.disableSendLink = true;
    
        this.disableSendOTP = true;
        this.disableValidateOTP = true;
                    // this.disableMobileConsent = true;
        this.showConvertButton = true;
        
        //this.saveState();
        this.previousMobileNumberValue = this.mobileNumberValue;

    } else {
        
        this.isDigitalError = true;
        this.successMessage = 'Digital Consent is not taken yet!';
        //this.saveState();
    }
    this.saveState();
}



/////////////

    // This function handles the click event on radio buttons
    handleRadioClick(event) {
        // console.log('Entered into Radio button');
        this.errorMessage = ''
        const fieldName = event.currentTarget.dataset.field;
        if (fieldName != '' && fieldName != undefined) {
            this.showConvertButton = true;
        }
        if (fieldName === 'mobile' && this.disableMobileConsent === false) {
            this.isMobile = true;
            this.showMobileNumber = true;
            this.isManual = false;
        }
        if (fieldName === 'manual' && this.disablePhyConsent === false) {
            // console.log('diablephy--->' + this.disablePhyConsent);
            this.disableConversionBtn = false;
            if (this.isOTPValidated == false) {
                this.isManual = true;
                this.isMobile = false;
                this.isDigital = false;
            } else {
                this.errorMessage = 'Verification is already completed via OTP';
            }
        }

        if(fieldName === 'digital' && this.disableDigitalConsent === false){
            this.isDigital = true;
            this.isManual = false;
            this.showMobileNumber = true;
        }


        if (event.target.checked === true && fieldName === 'manual') {
            console.log('inside Radio Manually');
            this.checkDuplicateLeads('Manual');
        }

        this.saveState();
    }

    // This function starts a timer
    startTimer() {
        // console.log(this.numberOfOTPAttempts, 'this.num$$$$$$$$ttemptsthis.numberOfOTPAttempts');

        this.intervalId = setInterval(() => {
            if (this.timeLeft > 0) {
                this.hidetimer = false;
                var minutes = Math.floor(this.timeLeft / 60);
                var seconds = this.timeLeft % 60;
                minutes = String(minutes).padStart(2, '0');
                seconds = String(seconds).padStart(2, '0');
                this.otpTimerValue = minutes + ':' + seconds;
                this.timeLeft--;

            } else {
                this.otpTimerValue = '00' + ':' + '00';
                if (this.otpVerified == true) {
                    this.disableSendOTP = true;
                } else {
                    this.disableSendOTP = false;
                }
                this.showValidateOTP = false;
                clearInterval(this.intervalId);
                this.hidetimer = true;
            }
        }, 1000);
    }

    // This function starts a timer
    startTimerForLink() {
        // console.log(this.numberOfOTPAttempts, 'this.num$$$$$$$$ttemptsthis.numberOfOTPAttempts');

        this.intervalId = setInterval(() => {
            if (this.timeLeftForLink > 0) {
                this.hidetimer = false;
                var minutes = Math.floor(this.timeLeftForLink / 60);
                var seconds = this.timeLeftForLink % 60;
                minutes = String(minutes).padStart(2, '0');
                seconds = String(seconds).padStart(2, '0');
                this.otpTimerValue = minutes + ':' + seconds;
                this.timeLeftForLink--;

                this.disableMobile = true;
            } else {
                this.otpTimerValue = '00' + ':' + '00';
                if (this.otpVerified == true || this.isDigitalValidated == true) {
                    this.disableSendOTP = true;
                    this.disableMobile = true;
                } else {
                    this.disableSendOTP = false;
                    this.disableMobile = false;
                }
                this.showValidateOTP = false;
                clearInterval(this.intervalId);
                this.hidetimer = true;
                this.timerStart = false;
            }
        }, 1000);
    }

    ///Function to check wether the Duplicate Lead Exists 
   // checkDuplicateLeads(){
        //LAK-8814
        checkDuplicateLeads(verificationType){
        this.showSpinner = true;
        checkDuplicateLead({
            leadRecordID: this.leadRecordId, mobile:this.mobileNumberValue
        })
        .then((result) => {
                console.log('result', result)
                if (result && result === 'Referred to BBH') {
                    this.showToastMessage('Error', this.customLabel.DuplicateLeadMessage, 'error', 'sticky');
                    this.navigateToListView();
                }
                else if (result && result === 'Referred to RSM') {
                    this.showToastMessage('Error', this.customLabel.DuplicateMSG, 'error', 'sticky');
                    this.navigateToListView();
                    console.log('result123', result)
                }

                else if (result && result === 'Rejected') {
                    this.showToastMessage('Error', this.customLabel.FraudLeadMessage, 'error', 'sticky');
                    this.navigateToListView();
                }
                else{
					if(verificationType == 'OTP'){
						this.sendOTPService();
					}
				}
            this.showSpinner = false;
        })
        .catch((error) => {
                this.showSpinner = false;
            console.log('Error In checkDuplicateLead', error);
        });
    }

    @track taskId;

    // handleSendOTP(event) {
    //     this.checkDuplicateLeads();
    //     if (this.showEnterOtp == true) {
    //         let otpElement = this.template.querySelector('.enter-otp');
    //         otpElement.setCustomValidity('');
    //         otpElement.reportValidity();
    //     }
    //     console.log('Mobile Number-->' + this.mobileNumberValue);;
    //     if (this.mobileNumberValue == '' || this.mobileNumberValue == undefined) {
    //         this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('Please complete this field.');
    //         this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
    //         this.showToastMessage('Error', this.customLabel.LeadOtp_ReqField_ErrorMessage, 'error', 'sticky');
    //         return;
    //     } else if (this.validatePhoneNumber() === false) {
    //         this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('Please enter a valid mobile number');
    //         this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
    //         this.showToastMessage('Error', this.customLabel.LeadOtp_MobileNumber_ErrorMessage, 'error', 'sticky');
    //         return;
    //     }
    //     else {
    //         // console.log('handle send else block this.numberOfOTPAttempts---' + this.numberOfOTPAttempts);
    //         this.numberOfOTPAttempts = this.numberOfOTPAttempts + 1;
    //         if (this.numberOfOTPAttempts > noOfOtpAttempts) {
    //             this.disableSendOTP = true;
    //             this.showEnterOtp = false; //hiding validate OTP section 
    //             this.isOTPNotValidated = true;
    //             var leadData = {
    //                 Id: this.leadRecordId,
    //                 MobilePhone: this.mobileNumberValue
    //             };
    //             updateMaxLimitReached({ leadData: leadData }).then(response => {
    //                 // console.log('##response##' + response);
    //             })
    //             //this.disableMobileConsent = true;
    //             this.hidetimer = true;
    //             this.disableConversionBtn = true;
    //         } else {
    //             this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('');
    //             this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
    //             this.timeLeft = OTPTimer;
    //             this.showEnterOtp = true;
    //             this.disableSendOTP = true;
    //             this.showValidateOTP = true;
    //             this.disableValidateOTP = false;
    //             this.startTimer();
    //             generateOTP({ leadId: this.leadRecordId, mobileNumber: this.mobileNumberValue })
    //                 .then(response => {
    //                     // console.log('Response from generateOTP' + JSON.stringify(response));
    //                     if (response) {
    //                         this.otpGenerated = response[0];
    //                         this.taskId = response[0];
    //                     }
    //                 })
    //         }
    //     }
    // }


    //LAK-8814
    handleSendOTP(event) {
        this.checkDuplicateLeads('OTP');
    }

    //LAK-8814
    sendOTPService(){
            if (this.showEnterOtp == true) {
            let otpElement = this.template.querySelector('.enter-otp');
            otpElement.setCustomValidity('');
            otpElement.reportValidity();
        }
        console.log('Mobile Number-->' + this.mobileNumberValue);;
        if (this.mobileNumberValue == '' || this.mobileNumberValue == undefined) {
            this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('Please complete this field.');
            this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
            this.showToastMessage('Error', this.customLabel.LeadOtp_ReqField_ErrorMessage, 'error', 'sticky');
            return;
        } else if (this.validatePhoneNumber() === false) {
            this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('Please enter a valid mobile number');
            this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
            this.showToastMessage('Error', this.customLabel.LeadOtp_MobileNumber_ErrorMessage, 'error', 'sticky');
            return;
        }
        else {
            // console.log('handle send else block this.numberOfOTPAttempts---' + this.numberOfOTPAttempts);
            this.numberOfOTPAttempts = this.numberOfOTPAttempts + 1;
            if (this.numberOfOTPAttempts > noOfOtpAttempts) {
                this.disableSendOTP = true;
                this.showEnterOtp = false; //hiding validate OTP section 
                this.isOTPNotValidated = true;
                var leadData = {
                    Id: this.leadRecordId,
                    MobilePhone: this.mobileNumberValue
                };
                updateMaxLimitReached({ leadData: leadData }).then(response => {
                    // console.log('##response##' + response);
                })
                //this.disableMobileConsent = true;
                this.hidetimer = true;
                this.disableConversionBtn = true;
            } else {
                this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('');
                this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
                this.timeLeft = OTPTimer;
                this.showEnterOtp = true;
                this.disableSendOTP = true;
                this.showValidateOTP = true;
                this.disableValidateOTP = false;
                this.startTimer();
                generateOTP({ leadId: this.leadRecordId, mobileNumber: this.mobileNumberValue })
                    .then(response => {
                        // console.log('Response from generateOTP' + JSON.stringify(response));
                        if (response) {
                            this.otpGenerated = response[0];
                            this.taskId = response[0];
                        }
                    })
            }
        }
    }

    @track showSpinner = false;
    handleValidateOTP(event) {
        this.showSpinner = true;
        let otpElement = this.template.querySelector('.enter-otp');
        let optEntered = otpElement.value;
        this.consentType = 'OTP Consent';

        validateOtp({ taskId: this.taskId, otp: optEntered })
            .then(response => {
                // console.log('Response from validateOtp' + JSON.stringify(response));
                if (response) {
                    if (response == 'success') {
                        otpElement.setCustomValidity('');
                        this.otpVerified = true;
                        this.isOTPValidated = true;
                        this.showEnterOtp = false;
                        this.disablePhyConsent = true;
                        this.updatedMobileNumber = this.mobileNumberValue;
                        /*var leadData = {
                            Id: this.leadRecordId,
                            OTP_Verified__c: true,
                            RationaleUsingPhyConsent__c: '',
                            MobilePhone: this.mobileNumberValue,
                            Disposition_Status__c: this.dispositionStatus,
                            ConsentType__c: this.consentType
                        };
                        updateLead({ leadData: leadData }).then(response => {
                            // console.log('response from update Lead in Validate OTP' + JSON.stringify(response));
                            this.disableSendOTP = true;
                            this.disableValidateOTP = true;
                            // this.showSpinner = false;
                            // this.isOTPValidated = true;
                        });*/

                        // this.filenames.forEach((file) => {
                        //   console.log('file.cdId---' + file.cdId);
                        // });
                    } else {
                        otpElement.setCustomValidity('OTP Validation Failed. Kindly try again');
                        this.showToastMessage('Error', this.customLabel.LeadOtp_Otp_ErrorMessage, 'error', 'sticky');
                    }
                    otpElement.reportValidity();
                    this.showSpinner = false;

                }
            })
        // if (optEntered === this.otpGenerated) {


        // } else {

        // }

    }

    timerStart;
    disableMobile;

    @track taskId;
    handleSendLink(event) {
        this.checkDuplicateLeads();
        // if (this.showEnterOtp == true) {
        //     let otpElement = this.template.querySelector('.enter-otp');
        //     otpElement.setCustomValidity('');
        //     otpElement.reportValidity();
        // }
        // console.log('Mobile Number-->' + this.mobileNumberValue);;
        // if (this.mobileNumberValue == '' || this.mobileNumberValue == undefined) {
        //     this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('Please complete this field.');
        //     this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
        //     this.showToastMessage('Error', this.customLabel.LeadOtp_ReqField_ErrorMessage, 'error', 'sticky');
        //     return;
        // } else if (this.validatePhoneNumber() === false) {
        //     this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('Please enter a valid mobile number');
        //     this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
        //     this.showToastMessage('Error', this.customLabel.LeadOtp_MobileNumber_ErrorMessage, 'error', 'sticky');
        //     return;
        // }
        // else {
        //     // console.log('handle send else block this.numberOfOTPAttempts---' + this.numberOfOTPAttempts);
        //     this.numberOfOTPAttempts = this.numberOfOTPAttempts + 1;
        //     if (this.numberOfOTPAttempts > noOfOtpAttempts) {
        //         this.disableSendOTP = true;
        //         this.showEnterOtp = false; //hiding validate OTP section 
        //         this.isOTPNotValidated = true;
        //         var leadData = {
        //             Id: this.leadRecordId,
        //             MobilePhone: this.mobileNumberValue
        //         };
        //         updateMaxLimitReached({ leadData: leadData }).then(response => {
        //             // console.log('##response##' + response);
        //         })
        //         //this.disableMobileConsent = true;
        //         this.hidetimer = true;
        //         this.disableConversionBtn = true;
        //     } else {
                // this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('');
                // this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
                // this.timeLeft = OTPTimer;
                // this.showEnterOtp = true;
                // this.disableSendOTP = true;
                // this.showValidateOTP = true;
                // this.disableValidateOTP = false;
                // this.startTimer();
                this.timerStart = true;
                this.disableValidateOTP = false;

                this.timeLeftForLink = LinkTimer;
                //this.showEnterOtp = true;
                this.disableSendOTP = true;
                //this.showValidateOTP = true;
                this.disableMobile = true;
                
                this.startTimerForLink();
                generateLink({ leadId: this.leadRecordId, mobileNumber: this.mobileNumberValue })
                    .then(response => {
                        // console.log('Response from generateOTP' + JSON.stringify(response));
                        if (response) {
                            //this.otpGenerated = response[0];
                            this.taskId = response[0];
                            console.log('digital consent task id ', this.taskId);
                        }
                    })
            }
        //}
    //}

    // @track showSpinner = false;
    // handleDigitalConsent(event) {
    //     //this.showSpinner = true;
    //     //console.log('consent typeeee : ', this.consentType);
    //     //if(this.consentType = 'Digital Consent'){
    //     //if(this.digitalVerified = true){
    //     // if(DIGITAL_VERIFIED.fieldApiName == true){
    //     console.log('this.digitalVerifiedNewwwwww ', this.digitalVerifiedNew);
    //     if(this.digitalVerifiedNew == true){

    //         const evt = new ShowToastEvent(
    //             {
    //                 title: 'Success',
    //                 message: 'Terms and conditions accepted!',
    //                 variant: 'success',
    //             }
    //         );
    //         this.dispatchEvent(evt);
    //     }
    //     else{
    //         const evt = new ShowToastEvent(
    //             {
    //                 title: 'Error',
    //                 message: 'Error in accepting terms and conditions',
    //                 variant: 'error',
    //             }
    //         );
    //         this.dispatchEvent(evt);
    //     }

        

    // }

    handleRationale(event) {
        // console.log('rationaleValue-->' + event.target.value);
        this.rationaleValue = event.target.value;
        this.rationalValueBkp = this.rationaleValue;
        if (this.rationaleValue != '' || this.rationaleValue != undefined) {
            this.template.querySelector("lightning-combobox[data-id=rationaleInput]").setCustomValidity('');
            this.template.querySelector("lightning-combobox[data-id=rationaleInput]").reportValidity();
            if (this.rationaleValue === 'Other Reasons') {
                console.log('rationaleValue-->' + this.rationaleValue);
                this.showComments = true;
            } else {
                this.showComments = false;
            }
        }
    }
    handleMobileChange(event) {
        //this.otpVerified = false;
        this.numberOfOTPAttempts = 0;
        // console.log('Mobile Number change-->' + event.target.value);
        this.mobileNumberValue = event.target.value;
        // console.log('validatePhoneNumber--' + this.validatePhoneNumber());
        if (this.validatePhoneNumber() === false) {
            this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('Please enter a valid mobile number');
            this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
            this.disableSendOTP = true;
            return;
        } else if (this.validatePhoneNumber() === true) {
            this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('');
            this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
            this.disableSendOTP = false;
        }
    }
    onChangeComments(event) {
        // console.log('comments-->' + event.target.value);
        this.commentsEntered = event.target.value.toUpperCase();
        if (this.commentsEntered.trim().length < 1) {
            this.template.querySelector("lightning-input[data-id=commentsInput]").setCustomValidity('Please update comments when Other Reasons value is selected');
            this.template.querySelector("lightning-input[data-id=commentsInput]").reportValidity();
        } else {
            this.template.querySelector("lightning-input[data-id=commentsInput]").setCustomValidity('');
            this.template.querySelector("lightning-input[data-id=commentsInput]").reportValidity()
        }
        this.commentsEntered = this.commentsEntered.trim();
    }

    onChangeAdditionalComments(event) {
        // console.log('Additional comments-->' + event.target.value);
        this.addCommentsEntered = event.target.value;
        if (this.addCommentsEntered.trim().length < 1) {
            this.template.querySelector("lightning-input[data-id=addCommentsInput]").setCustomValidity('Please update additional comments when Other Lead Closure Reason value is selected');
            this.template.querySelector("lightning-input[data-id=addCommentsInput]").reportValidity();
        } else {
            this.template.querySelector("lightning-input[data-id=addCommentsInput]").setCustomValidity('');
            this.template.querySelector("lightning-input[data-id=addCommentsInput]").reportValidity()
        }
        this.addCommentsEntered = this.addCommentsEntered.trim();
    }

    handlePrevious() {
        this.OTPPreviousValue = true;
        // console.log('FlowAttributeChangeEvent mobileNumberValue--' + this.mobileNumberValue);
        // console.log('FlowAttributeChangeEvent rationaleValue--' + this.rationaleValue);
        // console.log('FlowAttributeChangeEvent commentsEntered--' + this.commentsEntered);
        // console.log('FlowAttributeChangeEvent city & channel--' + this.pvCityVerified + '----' + this.pvChannelVerified);
        // console.log('FlowAttributeChangeEvent city_Bkp & channel_Bkp--' + this.CityValue_Bkp + '----' + this.pvChannelVerChannelValue_Bkpified);
        this.dispatchEvent(new FlowAttributeChangeEvent('mobile', this.mobileNumberValue));
        this.dispatchEvent(new FlowAttributeChangeEvent('VarRationaleValue', this.rationaleValue));
        this.dispatchEvent(new FlowAttributeChangeEvent('VarRationaleCommentsValue', this.commentsEntered));
        this.dispatchEvent(new FlowAttributeChangeEvent('pvCityVerified', this.pvCityVerified));
        this.dispatchEvent(new FlowAttributeChangeEvent('pvChannelVerified', this.pvChannelVerified));
        this.dispatchEvent(new FlowAttributeChangeEvent('CityValue_Bkp', this.CityValue_Bkp));
        this.dispatchEvent(new FlowAttributeChangeEvent('ChannelValue_Bkp', this.ChannelValue_Bkp));
        // this.dispatchEvent(new FlowAttributeChangeEvent('valRationale',this.rationaleValue));
        // this.dispatchEvent(new FlowAttributeChangeEvent('valRationalComments',this.commentsEntered));
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }

    async handleNext() {
        // console.log('this.fileName size on convert btn--->' + this.fileNames.length);
        // console.log(this.mobileNumberValue + 'handle next event called' + this.updatedMobileNumber);
        if (this.isMobile == true) {//this.otpVerified ==false &&

            if (this.validatePhoneNumber() === false) {
                this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('Please enter a valid mobile number');
                this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
                return;
            }
            else if (this.isOTPValidated === false) {
                // console.log('isOTPValidated next event called' + this.isOTPValidated);
                this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('Please validate OTP');
                this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
                this.showToastMessage('Error', this.customLabel.LeadOtp_ValidateOtp_ErrorMessage, 'error', 'sticky');
                return;
            } else {
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            }

        }

        if (this.isDigital == true) {




            if (this.validatePhoneNumber() === false) {
                this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('Please enter a valid mobile number');
                this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
                return;
            }
            else if (this.isDigitalValidated === false) {

                //this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('Please take digital consent');
                this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
                this.showToastMessage('Error', 'Please take digital consent', 'error', 'sticky');
                return;
            } else {
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            }

        }

        if(this.isDigital === false && this.isManual === false){
            this.showToastMessage('Error', 'Please take digital or physical consent', 'error', 'sticky');
            return;
        }

        let isPhyConsent = false;
        // if (this.otpVerified == false && this.isManual == true) {
        if ((this.otpVerified == false || this.isDigitalValidated == false) && this.isManual == true) {

            if (this.rationaleValue == '' || this.rationaleValue == undefined) {
                this.template.querySelector("lightning-combobox[data-id=rationaleInput]").setCustomValidity('Please select the reason.');
                this.template.querySelector("lightning-combobox[data-id=rationaleInput]").reportValidity();
                return;
            } else if (this.rationaleValue == 'Other Reasons' && (this.commentsEntered == '' || this.commentsEntered == undefined)) {
                this.template.querySelector("lightning-input[data-id=commentsInput]").setCustomValidity('Please update comments when Other Reasons value is selected');
                this.template.querySelector("lightning-input[data-id=commentsInput]").reportValidity();
                return;
            }
            else if (this.fileNames.length == 0) {
                this.isError = true;
                return;
            }
            else {
                //LAK-3680 Start
                isPhyConsent = true;
                this.consentType = 'Physical Consent Upload';
                var leadData = {
                    Id: this.leadRecordId,
                    OTP_Verified__c: false,
                    Is_Physical_Consent_Validated__c: true,
                    MobilePhone: this.mobileNumberValue,
                    Disposition_Status__c: this.dispositionStatus,
                    ConsentType__c: this.consentType,
                    Comments__c: this.commentsEntered,
                    RationaleUsingPhyConsent__c: this.rationaleValue
                };
                await updateLead({ leadData: leadData }).then(response => {
                    // console.log('##response from update Lead when phy consent##' + response);
                    const navigateNextEvent = new FlowNavigationNextEvent();
                    this.dispatchEvent(navigateNextEvent);
                })

                //LAK-3680 End
            }
        }
        if (isPhyConsent == true) {
            if (this.rationaleValue == '' || this.rationaleValue == undefined) {
                this.template.querySelector("lightning-combobox[data-id=rationaleInput]").setCustomValidity('Please select the reason.');
                this.template.querySelector("lightning-combobox[data-id=rationaleInput]").reportValidity();
                return;
            } else if (this.rationaleValue == 'Other Reasons' && (this.commentsEntered == '' || this.commentsEntered == undefined)) {
                this.template.querySelector("lightning-input[data-id=commentsInput]").setCustomValidity('Please update comments when Other Reasons value is selected');
                this.template.querySelector("lightning-input[data-id=commentsInput]").reportValidity();
                return;
            }

            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }

        this.dispatchEvent(new RefreshEvent())
    }

    // handleUploadFinished(event) {
    //     let tempFileNames = this.fileNames;
    //     // Get the list of uploaded files
    //     const uploadedFiles = event.detail.files;
    //     const fileNames = [];
    //     console.log('No. of files uploaded : ' + JSON.stringify( uploadedFiles));
    //     if(uploadedFiles) {
    //         uploadedFiles.forEach(item=>{
    //             tempFileNames.push( {name:item.name,size:item.size,cDId:item.documentId} );
    //             console.log('item.name--'+item.name);
    //             console.log('item.size--'+item.size);
    //         });
    //         this.fileNames = [];
    //         this.fileNames = tempFileNames;
    //         this.isError = false;
    //     }
    //     console.log(JSON.stringify(this.fileNames),'fileNamesfileNames')
    // }

    @track fileData;
    @track fileName = '';
    @track documentDetaildId = '';
    openfileUpload(event) {
        // this.isManual = false;
        const file = event.target.files[0];
        let fileNameParts = event.detail.files[0].name.split('.');
        let extension = '.' + fileNameParts[fileNameParts.length - 1].toLowerCase();
        this.fileName = file.name;
        // this.isLoading = true;
        if (!this.acceptedFormats.includes(extension)) {
            this.showToastMessage('Error', this.customLabel.LeadOtp_FileType_ErrorMessage, 'error', 'sticky');
        }
        else if (file.size > MAX_FILE_SIZE) {
            this.showToastMessage(
                "Error!",
                this.customLabel.LeadOtp_FileSize_ErrorMessage,
                "error",
                "sticky"
            );
            // this.isLoading = false;

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
                    this.uploadFileLargeVf(this.leadRecordId);
                }
                catch (error) {
                    // console.log(JSON.stringify(error) + 'Error in creating list');
                }

            };
            reader.readAsDataURL(file);

            this.uploadFileAndShowToast(event);
        }

        setTimeout(() => {
            // this.isManual = true;
            // console.log('this.isManual after', this.isManual);
        }, 500);
    }

    openfileUpload1(event) {
        // this.isManual = false;
        const file = event.target.files[0];
        let fileNameParts = event.detail.files[0].name.split('.');
        let extension = '.' + fileNameParts[fileNameParts.length - 1].toLowerCase();
        this.fileName = file.name;
        // this.isLoading = true;
        if (!this.acceptedFormats1.includes(extension)) {
            this.showToastMessage('Error', this.customLabel.LeadOtp_FileType_ErrorMessage_BLPL, 'error', 'sticky');
        }
        else if (file.size > MAX_FILE_SIZE1) {
            this.showToastMessage(
                "Error!",
                this.customLabel.LeadOtp_FileSize_ErrorMessage_BLPL,
                "error",
                "sticky"
            );
            // this.isLoading = false;

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
                    this.uploadFileLargeVf(this.leadRecordId);
                }
                catch (error) {
                    // console.log(JSON.stringify(error) + 'Error in creating list');
                }

            };
            reader.readAsDataURL(file);

            this.uploadFileAndShowToast(event);
        }

        setTimeout(() => {
            // this.isManual = true;
            // console.log('this.isManual after', this.isManual);
        }, 500);
    }

    uploadFileLargeVf(leadRecordId) {
        try {
            this.template.querySelector("iframe").contentWindow.postMessage(
                JSON.parse(
                    JSON.stringify({
                        source: "lwc",
                        files: this.fileData,
                        parameters: leadRecordId,
                        lightningDomain: this.lightningDomainName
                    })
                ),
                this.vfUrl
            );
        }
        catch (error) {
            // console.log('Error while trying to process selected file' + error);
            this.showToastMessage(
                "Error!",
                this.customLabel.LeadOtp_UploadingFile_ErrorMessage,
                "error",
                "sticky"
            );
            // this.isLoading = false;
        }
    }

    uploadFileAndShowToast(event) {
        try {
            let tempFileNames = this.fileNames;
            // Get the list of uploaded files
            // const uploadedFiles = event.detail.files;
            const fileNames = [];
            console.log('No. of files uploaded : ');
            if (this.fileData) {
                // console.log('filedata----' + this.fileData);
                this.fileData.forEach(item => {
                    tempFileNames.push({ name: item.name, size: item.size, cDId: item.documentId });
                    console.log('item.name--' + item.name);
                    console.log('item.size--' + item.size);
                });
                this.fileNames = [];
                this.fileNames = tempFileNames;
                this.isError = false;
            }
            // console.log(JSON.stringify(this.fileNames), 'fileNamesfileNames')
        } catch (error) {
            console.error(error);
            this.showToastMessage(
                "Error!",
                this.customLabel.LeadOtp_UploadingFile_ErrorMessage,
                "error",
                "sticky"
            );
            // this.isLoading = false;
        }
    }


    handleUploadCallback(message) {
        console.log('Responve of vf Page ', message.data);

        if (message.data.source === "vf") {
            if (message.data.fileIdList != null || message.data.fileIdList.length > 0) {

                if (this.fileName.trim() != '') {
                    let title = `${this.fileName} uploaded successfully!!`;
                    this.showToastMessage('Success', title, 'success', 'sticky');
                }
                //refreshApex(this.wiredFilesList);
                this.getUploadedFiles(this.leadRecordId);
                this.consentType = 'Physical Consent Upload';
                var leadData = {
                    Id: this.leadRecordId,
                    //OTP_Verified__c:true,
                    MobilePhone: this.mobileNumberValue,
                    Disposition_Status__c: this.dispositionStatus,
                    ConsentType__c: this.consentType,
                    Comments__c: this.commentsEntered,
                    RationaleUsingPhyConsent__c: this.rationaleValue
                };
                updateLead({ leadData: leadData }).then(response => {
                    // console.log('##response from update Lead##' + response);
                })
            } else {
                this.showToastMessage(
                    "Error!",
                    this.customLabel.LeadOtp_UploadingFile_ErrorMessage,
                    "error",
                    "sticky"
                );
                // this.isLoading = false;
            }

        }
    }

    validatePhoneNumber() {
        //var regex = /^\d{10}$/;
        var regex = /[6,7,8,9]{1}[0-9]{9}/;
        return regex.test(this.mobileNumberValue);
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

    subscribeHandler() {
        // console.log('######subscriber called#########');
        subscribe(this.context, LEADDATAMC, (message) => { this.handleMessage(message) }, { scope: APPLICATION_SCOPE })
    }

    handleMessage(message) {
        console.log('######handleMessage called#########' + message.lmsData.value);
        if (message.lmsData.value === 'Close Lead') {
            this.isShowModal = true;
        }
    }

    closeModal() {
        this.isShowModal = false;
        this.resetForm();
    }

    closeConsentModal() {
        this.isModalOpen = false;
    }

    handleRemoveRecord(event) {
        // console.log("delete file called");
        // console.log("id is ==> " + this.docId);
        let cdToDelete = this.docId;
        let tempFileNames = this.fileNames;
        this.fileNames = [];
        const index = tempFileNames.findIndex(file => file.cDId === cdToDelete);
        // console.log("index###" + index);
        deleteRecord(cdToDelete)
            .then(() => {
                if (index !== -1) {
                    tempFileNames.splice(index, 1);
                    // console.log("fileNames###" + tempFileNames);
                    this.fileNames = tempFileNames;
                    if (this.fileNames.length == 0) {
                        this.otpVerified = false;
                    }
                    console.log('this.fileNames length-->' + this.fileNames.length);
                }
                const toastEvent = new ShowToastEvent({
                    title: "",
                    message: this.customLabel.LeadOtp_Del_SuccessMessage,
                    variant: "success"
                });
                this.dispatchEvent(toastEvent);
                this.dispatchEvent(new RefreshEvent());
            })
            .catch((error) => {
                console.log(
                    "Unable to delete record due to " + error.body.message
                );
            });
        this.isModalOpen = false
    }

    handleSubmit(event) {
        // console.log('Enterd Handle submit');
        event.preventDefault();
        const fields = event.detail.fields;
        if (this.closureReason) {
            fields.Disposition_Status__c = 'Lead closed'
        }
        console.log('fields--->' + fields);
        if (fields.Lead_Closure_Reason__c != '' && fields.Lead_Closure_Reason__c != undefined) {
            fields.Status = 'Closed';
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.leadRecordId,
                    objectApiName: 'Lead',
                    actionName: 'view'
                },
            });
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            this.showToastMessage('Success', this.customLabel.LeadOtp_Has_SuccessMessage + fields.Status + this.customLabel.LeadOtp_Succ_SuccessMessage, 'success', 'sticky');
        } else {
            console.log('Enterd into else submit');
            this.showToastMessage('Error', this.customLabel.LeadOtp_leadClouse_ErrorMessage, 'error', 'sticky');
        }
    }

    handlePicklistChange(event) {
        // console.log('####CR###' + event.target.value);
        this.closureReason = event.target.value;
        if (this.closureReason === 'Others') {
            this.showAdditionalComments = true;
        } else {
            this.showAdditionalComments = false;
        }
    }

    handleEnterOtp(event) {
        var charCode = (event.which) ? event.which : event.keyCode;
        console.log('charCode-->' + charCode);
        if ((charCode < 48 || charCode > 57)) {//charCode != 46 && charCode > 31 && 
            // console.log('entered if');
            if (event.preventDefault) {
                // console.log('entered if++++');
                event.preventDefault();
            } else {
                // console.log('entered if$$$$$');
                event.returnValue = false;
            }
        }
    }

    handleDrag(event) {
        if (event.dataTransfer.items) {
            for (let i = 0; i < event.dataTransfer.items.length; i++) {
                const item = event.dataTransfer.items[i];
                if (item.type && item.type.includes('pdf')) {
                    const file = item.getAsFile();
                    let nameSplit = file.name.split(".");
                    this.showToast('Error', this.customLabel.LeadOtp_FileType_ErrorMessage + ` ${nameSplit[(nameSplit.length - 1)]}`, 'error');
                }
            }
        }
    }
        handleDocumentView(event) {
        //console.log("view file called");
      // console.log("id is ==> " + event.currentTarget.dataset.id);
      console.log('this.fileNames ', this.fileNames);
    //   console.log('this.wiredFilesList ',this.wiredFilesList);
      
      
      let item = event.currentTarget.dataset; 
      this.contentDocumentId = item.id; 
      if(this.DSAUser!=true){
          console.log("file called 1");
        try {
            this[NavigationMixin.Navigate]({
                type: "standard__namedPage",
                attributes: {
                    pageName: "filePreview"
                },
                state: {
                      selectedRecordId: item.id
                  
                }
            });
        } catch (e) {
            console.error(e);
            console.error("e.name => " + e.name);
            console.error("e.message => " + e.message);
            console.error("e.stack => " + e.stack);
        }
          
          
      }
      else{

        this.filePreview(event)
      console.log("Preview file called");
      }
    }
      filePreview(event) {
       
      console.log("Preview file called");
      debugger;
      let item = event.currentTarget.dataset; 
      console.log("File Extension from dataset: ", item); 
      console.log("All dataset attributes FileExtension: ", event.currentTarget.dataset.fileExtension);
      console.log("File ID from dataset: ", item.id);
      console.log("File Extension from dataset: ", item.fileExtension);
      //  console.log("File view: ", item.cvId);
      this.contentDocumentId=item.id; 
      this.contentDocumentType=item.fileExtension;
        //this.cvId = item.cvId;
      console.log('contentDocumentId', this.contentDocumentId);
      console.log('contentDocumentType', this.contentDocumentType);
        console.log('Before setting showModal:', this.showModal);
        this.showModal = true;
        console.log('After setting showModal:', this.showModal);
}


//}
    handleCloseModalEvent(){
        this.showModal = false;
    }
    

    closeModal() {
        this.showModal = false;
        console.log('Close image:');
    }

    handleDocumentDelete(event) {
        this.docId = event.currentTarget.dataset.id;
        this.isModalOpen = true;
        console.log("Delete file called");
    }
    resetForm() {
        // Clear the form fields
        this.template.querySelectorAll('lightning-input-field').forEach((field) => {
            field.reset();
        });
        // Reset any other state variables or flags
        this.showAdditionalComments = false;
    }

    handleCancel() {
        this.navigateToListView();
    }

    navigateToListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Lead',
                actionName: 'list'
            },
        })
    }
}