import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getLoanApplData from '@salesforce/apex/verifyCoApplicantDetailsController.getLoanApplData';
import getCoApplicantData from '@salesforce/apex/verifyCoApplicantDetailsController.getCoApplicantData';
import upsertCoApplicantRecord from '@salesforce/apex/verifyCoApplicantDetailsController.upsertCoApplicantRecord';
import getRelatedFilesByRecordId from '@salesforce/apex/verifyCoApplicantDetailsController.getRelatedFilesByRecordId';
import deleteFileRecord from '@salesforce/apex/verifyCoApplicantDetailsController.deleteFileRecord';
import uploadFile from '@salesforce/apex/verifyCoApplicantDetailsController.uploadFile';
import updateMaxLimitReached from '@salesforce/apex/verifyCoApplicantDetailsController.updateMaxLimitReached';
import generateOTP from '@salesforce/apex/verifyCoApplicantDetailsController.generateOTP';
import noOfOtpAttempts from '@salesforce/label/c.CreateLead_OTP_noofAttempts';
import SentOTPSuccess from '@salesforce/label/c.OTP_Sent_Success';
import OTPTimer from '@salesforce/label/c.OTP_Timer';
import OTPTimerCoApplicant from '@salesforce/label/c.OTPTimerCoApplicant';
import OTPRetryMessage from '@salesforce/label/c.LeadCapture_OTP_Retry_Message';
import OTPThreeTimesError from '@salesforce/label/c.LeadCapture_OTP_Threetimes';
import mobVerificationFailed from '@salesforce/label/c.CreateLead_OTP_MobileNotVerified';
import uploadOneFile from '@salesforce/label/c.LeadCapture_OTPValidation_Uploadonefile';
import MobileNumSuccess from '@salesforce/label/c.LeadCapture_OTP_MobileNoSuccess';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import mobValfailed from '@salesforce/resourceUrl/mobile_validation_failed'; 

//Message channel section
import { publish, unsubscribe, createMessageContext, releaseMessageContext } from 'lightning/messageService';
import RECORDCREATE from "@salesforce/messageChannel/RecordCreate__c";

//LMS details
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";



// Applicant object
import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';
import CoApplicantMobileFormatError from '@salesforce/label/c.CoApplicantMobileFormatError';
const customerProfileVisibleOptions = ["SALARIED", "SELF EMPLOYED NON PROFESSIONAL", "SELF EMPLOYED PROFESSIONAL", "HOUSEWIFE", "OTHERS"];

export default class VerifyCoApplicantDetailsClone extends LightningElement {

    
    showPhysicalConsent = false;
    showMobileOtpConsent = false;
    //previouspattern =  ^[6-9]\d{9}$

    @track wiredData = {};
    @api layoutSize = {small:12,medium:6,large:4};



    @api isVerified = false;

    @api recordId;
    @api applicantId = 'a0AC4000000Fv4PMAS';
    @api loanAppId = 'a08C4000006Na91IAC';
    @api applicantIdOnTabset = 'a0AC4000000Fv4PMAS';
    @track fileUploaded = false;

    //new additions 
    showConsent = false;
    isMobile = false;
    isManual = false;
    showMobileNumber = false;
    errorMessage = '';
    isOTPValidated = false;
    mobileNumberValue;

    disabledConstitution = true;
    disabledTypeOfBorrower = false;
    isIndividual = true;

    label = {
        OTPRetryMessage,
        uploadOneFile,
        MobileNumSuccess,
        OTPThreeTimesError,
        noOfOtpAttempts,
        mobVerificationFailed,
        CoApplicantMobileFormatError,
        SentOTPSuccess
    };
    mobFailedImage = mobValfailed;


    //array properties
    // @track applicantTypeOptions = []
    @track applicantTypeOptionsModified = []
    @track customerProfileOptions = []
    @track constitutionOptions = []
    @track BorrowerOptions = []

    @track wrapObj = {
        MobNumber__c: "",
        ApplType__c: "",
        Constitution__c: "",
        CustProfile__c: "",
        Type_of_Borrower__c: "",
        KeyManName__c: "",
        CompanyName__c: "",
        FName__c: "",
        MName__c: "",
        LName__c: ""



    };

    acceptedFormats = ['.pdf', '.png', '.jpeg', '.jpg'];




    loanApplData = null; // Initialize with null
    disbledMobileOTP = false;

    @track primaryApplicantMobNumber;
    @track showNameSection = false;

    subscription = null;
    context = createMessageContext();


    @wire(getLoanApplData, { recordid: '$recordId' })
    wiredLoanApplData({ error, data }) {
        if (data) {
            // This data is used to understand whether there is a Primary Applicant to the Loan Application, and the mobile number of the applicant
            this.loanApplData = data;
            console.log('Applicant Data!! '+JSON.stringify(this.loanApplData));
            if (data.Applicant__r && data.Applicant__r.MobNumber__c) {
                this.primaryApplicantMobNumber = data.Applicant__r.MobNumber__c;
            }
            this.checkMobileCondition();
        }else if(error){
            this.showToastMessage("Error", 'Primary Applicant details not tagged to the selected Loan Application. Please check the Loan Application record!!', "error", "dismissible");
            console.log('Error !! '+this.recordId);
        }
    }

    @track originalMobileNumber;

    @wire(getCoApplicantData, { recordid: '$applicantIdOnTabset' })
    wiredCoApplicantData({ error, data }) {
        if (data) {
            console.log('Co-Applicant Data Received '+JSON.stringify(data));
            this.wiredData = data;
            this.showNameSection = false;
            const fieldsToUpdate = ["CustProfile__c", "Constitution__c", "Type_of_Borrower__c", "ApplType__c", "MobNumber__c", "Id", "OTP_Verified__c", 'FName__c', 'MName__c', 'LName__c', 'KeyManName__c', 'CompanyName__c'];
            fieldsToUpdate.forEach(field => {
                if (data[field]) {
                    this.wrapObj[field] = data[field];
                    if (field === 'Constitution__c' && data[field]) {
                        this.showNameSection = true;
                        if(data[field] === 'INDIVIDUAL'){
                            this.isIndividual = true;
                        }else{
                            this.isIndividual = false;
                        }
                    }else if(field === 'Constitution__c' && !data[field]){
                        this.showNameSection = false;
                    }
                }
            });
            if(data.Is_OTP_Limit_Reached__c === true && data.OTP_Verified__c === false){
                this.isOTPNotValidated = true;
                this.disableSendOTP = true;
                this.disableMobileNumber = true;
                // To disable mobile num field after failed otp verfictn And To show verfictn Failed ==== DG            
                this.isMobile = true;
                this.showMobileNumber = true;
                this.showEnterOtp = false
                
            }
            if(data.MobNumber__c){
                this.originalMobileNumber = data.MobNumber__c;
            }
            // To disable mobile number field after successful otp Verification verification symbol ==== DG
            if(data.OTP_Verified__c === true){
                this.disableMobileNumber = true;
                this.isVerified = true;
                this.isOTPValidated = true;
                this.disableSendOTP = true;
                this.isVerified = true;
                console.log( 'Mob Verification :: '+ this.isVerified );
                this.isMobile = true;
                this.showMobileNumber = true;
                this.showEnterOtp = false

            }
           

            this.checkMobileCondition();
        }
    }

    @track filesPresent = false;
    @track filesList = [];

    wiredResult;

    @wire(getRelatedFilesByRecordId, { loanAppId: '$loanAppId', applicantId: '$applicantIdOnTabset' })
    wiredResult(result) {
        this.wiredResult = result;
        this.filesList = [];
        if (result.data) {
            console.log("wire:", JSON.stringify(result.data));
            this.filesPresent = true;
            result.data.forEach(record => {
                const customKeyRecord = {};
                customKeyRecord.Id = record.ContentDocumentId;
                customKeyRecord.Title = record.Title;
                customKeyRecord.ContentSize = record.ContentSize;
                customKeyRecord.FileExtension = record.FileExtension;
                this.filesList.push(customKeyRecord);
            });
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
            this.wrapObj.OTP_Verified__c = true;
            this.isVerified = true;
            this.showConsent = true;
            this.showMobileOtpConsent = false;
            this.showPhysicalConsent = true;
        } else if (this.wrapObj.MobNumber__c && this.wrapObj.MobNumber__c.length == 10) {
            this.mobileNumberValue = this.wrapObj.MobNumber__c;
            this.showConsent = true;
            this.showPhysicalConsent = true;
            this.showMobileOtpConsent = true;
            this.isVerified = false;
        } else {
            this.showConsent = false;
            this.isMobile = false;
            this.isManual = false;
            this.mobileNumberValue = undefined;
        }
    }


    // Getter to determine whether to show the radio group
    get showRadioGroup() {
        return this.loanApplData && this.loanApplData.Applicant__r && this.loanApplData.Applicant__r.PhoneNumber__c === 'wrapObj.MobNumber__c';
    }



    messageMismatchError = this.label.CoApplicantMobileFormatError;
    @wire(getObjectInfo, { objectApiName: APPLICANT_OBJECT })
    objectInfo
    @wire(getPicklistValuesByRecordType, {
        objectApiName: APPLICANT_OBJECT,
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    })
    picklistHandler({ data, error }) {
        if (data) {
            this.constitutionOptions = [...this.generatePicklist(data.picklistFieldValues.Constitution__c)]
            this.BorrowerOptions = [...this.generatePicklist(data.picklistFieldValues.Type_of_Borrower__c)]
            //this.handleRemoveOption();
            //logic for customer profile picklist
            let customerProfileAllOptions = [...this.generatePicklist(data.picklistFieldValues.CustProfile__c)];
            let tempArrayCustProfile = [];
            for (let i = 0; i < customerProfileAllOptions.length; i++) {

                if (customerProfileVisibleOptions.indexOf(customerProfileAllOptions[i].label) > -1) {
                    tempArrayCustProfile.push(customerProfileAllOptions[i]);
                }

            }
            this.customerProfileOptions = [...tempArrayCustProfile];

            //logic for Modified applicantTypeOptions
            let applicantTypeOptions = [...this.generatePicklist(data.picklistFieldValues.ApplType__c)];
            this.applicantTypeOptionsModified = applicantTypeOptions.filter(option => {
                console.log('Options  :: ' + JSON.stringify(option.label));
                return option.label !== 'APPLICANT';

            });
            console.log('ApplicantTypeOptionsModified  :: ' + this.applicantTypeOptionsModified);
        }
        if (error) {
            console.error(error)
        }
    }

    // handleRemoveOption(){
    //    this.applicantTypeOptionsModified = this.applicantTypeOptions.filter(option => {
    //     console.log('Options  :: '+ JSON.stringify(option.label) );
    //     return option.label !== 'APPLICANT';

    // });     

    //     console.log('ApplicantTypeOptionsModified  :: '+ this.applicantTypeOptionsModified );
    // }


    connectedCallback() {
        console.log('Applicant Id on Tabset! ' + this.applicantIdOnTabset + ' @@Record Id !! '+this.recordId + ' @@Loan Id !! '+this.loanAppId);
        //this.handleSubscribe();
        //this.scribeToMessageChannel();

        
    }

    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );

    }

    handleSaveThroughLms(values) {
        //console.log('values to save through Lms ', JSON.stringify(values));
        this.handleSave(values.validateBeforeSave);

    }

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


    inputChangeHandler(event) {
        this.wrapObj[event.target.dataset.fieldname] = event.target.value;
        if (event.target.dataset.fieldname == "CustProfile__c") { }
        if (event.target.value == 'SALARIED') {
            this.disabledConstitution = true;
            this.disabledTypeOfBorrower = false;
            this.wrapObj.Constitution__c = 'INDIVIDUAL';
            this.wrapObj.Type_of_Borrower__c = ''
        }

        if (event.target.dataset.fieldname == "CustProfile__c") { }
        this.wrapObj[event.target.dataset.fieldname] = event.target.value;
        if (event.target.value == 'SELF EMPLOYED PROFESSIONAL') {
            this.disabledConstitution = false;
            this.disabledTypeOfBorrower = false;
            this.wrapObj.Constitution__c = '';
            this.wrapObj.Type_of_Borrower__c = ''
        }

        if (event.target.dataset.fieldname == "CustProfile__c") { }
        this.wrapObj[event.target.dataset.fieldname] = event.target.value;
        if (event.target.value == 'SELF EMPLOYED NON PROFESSIONAL') {
            this.disabledConstitution = false;
            this.disabledTypeOfBorrower = false;
            this.wrapObj.Constitution__c = '';
            this.wrapObj.Type_of_Borrower__c = ''
        }

        if (event.target.dataset.fieldname == "CustProfile__c") { }
        this.wrapObj[event.target.dataset.fieldname] = event.target.value;
        if (event.target.value == 'HOUSEWIFE') {
            this.disabledConstitution = true;
            this.disabledTypeOfBorrower = true;
            this.wrapObj.Constitution__c = 'INDIVIDUAL';
            this.wrapObj.Type_of_Borrower__c = 'Non Financial'
        }
        if (event.target.dataset.fieldname == "CustProfile__c") { }
        this.wrapObj[event.target.dataset.fieldname] = event.target.value;
        if (event.target.value == 'OTHERS') {
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
        else if(this.wrapObj.Constitution__c && this.wrapObj.Constitution__c != 'INDIVIDUAL') {
            this.showNameSection = true;
            this.isIndividual = false;
            this.wrapObj.FName__c = null;
            this.wrapObj.MName__c = null;
            this.wrapObj.LName__c = null;
        }else{
            this.showNameSection = false;
            this.wrapObj.CompanyName__c = null;
            this.wrapObj.KeyManName__c = null;
            this.wrapObj.FName__c = null;
            this.wrapObj.MName__c = null;
            this.wrapObj.LName__c = null;
        }

        if (event.target.dataset.fieldname == "MobNumber__c") {
            this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('');
            this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
            this.numberOfOTPAttempts = 0;
            this.showEnterOtp = false;
            this.disableSendOTP = false;
            this.disableValidateOTP = true;
            this.isVerified = false;
            let mobileNum = event.target.value;
            this.wrapObj[event.target.dataset.fieldname] = mobileNum;
            this.mobileNumberValue = mobileNum;
            this.isOTPValidated = false;
            if (mobileNum.length == 10 && this.validatePhoneNumber() === true) {
                var checkValidScreen = this.checkValidity();
                if(checkValidScreen === false){
                    this.mobileNumberValue = undefined;
                    this.wrapObj.MobNumber__c = null;
                    this.showToastMessage("Error", 'Please fill other mandatory fields first.', "error", "dismissible");
                }else{
                    this.showConsent = true;
                    if(this.originalMobileNumber && this.originalMobileNumber === mobileNum && this.isOTPNotValidated === true){
                        this.disableSendOTP = true;
                    }
                    else if (this.primaryApplicantMobNumber && this.primaryApplicantMobNumber === mobileNum) {
                        this.isVerified = true;
                        this.wrapObj.OTP_Verified__c = true;
                        this.showPhysicalConsent = true;
                        this.showMobileOtpConsent = false;
                    }
                    else {
                        this.wrapObj.OTP_Verified__c = false;
                        this.showPhysicalConsent = true;
                        this.showMobileOtpConsent = true;
                        this.isVerified = false;
                    }
                    this.wrapObj.LoanAppln__c = this.loanAppId ? this.loanAppId : null;
                    console.log('CoApplicant Record!! '+JSON.stringify(this.wrapObj));
                    upsertCoApplicantRecord({ recordData: this.wrapObj })
                    .then(data => {
                        if (data.Id) {
                            this.wrapObj.Id = data.Id;
                            this.publishMC(data.Id);
                        }
                    }).catch(error => {
                        console.log('Error occured ' + JSON.stringify(error));
                    })
                }
            }
            else {
                this.showConsent = false;
                this.isMobile = false;
                this.isManual = false;
                this.mobileNumberValue = undefined;
            }
        }

        

    }



    handleRecordIdChange() {
        let tempParams = this.params;
        tempParams.queryCriteria = ' where id = \'' + this.recordId + '\'';
        this.params = { ...tempParams };

    }

    @track mobileOptionSelected = false;

    handleRadioClick(event) {
        this.errorMessage = ''
        const fieldName = event.currentTarget.dataset.field;
        if (fieldName === 'mobile') {
            this.isMobile = true;
            this.showMobileNumber = true;
            this.isManual = false;
            this.mobileOptionSelected = true;
        }
        if (fieldName === 'manual') {
            if (this.isOTPValidated == false) {
                this.isManual = true;
                this.isMobile = false;
                this.mobileOptionSelected = false;
            } else {
                this.showToastMessage('Success', 'Verification is already completed via OTP', 'success', 'dismissible');
            }
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
    upsertCoApplicants() {
        if (this.wrapObj.MobNumber__c && this.wrapObj.ApplType__c && this.wrapObj.Constitution__c && this.wrapObj.CustProfile__c && this.wrapObj.Type_of_Borrower__c) {
            const coApplicantRecords = JSON.stringify(this.wrapObj);
            upsertCoApplicants({ coApplicantRecordsStr: coApplicantRecords, loanAppId: this.recordId }).then(data => {
            }).catch(error => {
                console.log('Error occured ' + JSON.stringify(error));
            })
        }

    }
    
    @track otpSentSuccess = false;
    @track disableSendOTP = false;
    @track numberOfOTPAttempts = 0;
    @track showEnterOtp = false;
    @track isOTPNotValidated = false;
    @track hidetimer = false;
    //@track timeLeft = OTPTimer;
    @track timeLeft = 15;
    @track showValidateOTP = false;
    @track disableValidateOTP = true;
    @track otpGenerated;


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
            this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity(this.messageMismatchError);
            this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
            return;
        }
        else {
            this.numberOfOTPAttempts = this.numberOfOTPAttempts + 1;
            if (this.numberOfOTPAttempts > noOfOtpAttempts) {
                this.disableSendOTP = true;
                this.showEnterOtp = false; //hiding validate OTP section 
                this.isOTPNotValidated = true;
                var coApplicantData = {
                    Id: this.wrapObj.Id,
                    MobNumber__c: this.mobileNumberValue
                };
                updateMaxLimitReached({ coAppRecord: coApplicantData }).then(response => {
                })
                this.hidetimer = true;
            } else {
                this.template.querySelector("lightning-input[data-id=mobileInput]").setCustomValidity('');
                this.template.querySelector("lightning-input[data-id=mobileInput]").reportValidity();
                //this.timeLeft = OTPTimer;
                this.timeLeft = 15;
                this.showEnterOtp = true;
                console.log('No Of Attempts :: ' + this.showEnterOtp);
                this.disableSendOTP = true; //Disable SenD OTP Button After 3 Tries ==== DG
                this.disableValidateOTP = false;
                this.startTimer();
                generateOTP({ recordId: this.wrapObj.Id, mobileNumber: this.mobileNumberValue })
                .then(response => {
                    console.log('Response from generateOTP ' + JSON.stringify(response));
                    if (response) {
                        this.otpGenerated = response[0];
                        this.otpSentSuccess = true; // sent OTP Successfully message ==== DG 
                    }
                })
            }
        }
    }

    checkValidity(){
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

        return (isInputsCorrect === true && isComboboxCorrect === true ) ? true : false;
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

    handleValidateOTP(event) {
        this.isOTPValidated = false;
        let otpElement = this.template.querySelector('.enter-otp');
        let optEntered = otpElement.value;
        this.consentType = 'OTP Consent';
        if (optEntered === this.otpGenerated) {
            otpElement.setCustomValidity('');
            this.wrapObj.OTP_Verified__c = true;
            this.isOTPValidated = true;
            this.disableMobileNumber = true;

            // Verification failed message disappear as well mobile verified   ==== DG
            this.isVerified = true;
            this.isOTPNotValidated = false;
            this.otpSentSuccess = false;

            this.showEnterOtp = false;
            var coApplicantData = {
                Id: this.wrapObj.Id,
                OTP_Verified__c: true,
                MobilePhone: this.mobileNumberValue,
                ConsentType__c: this.consentType,
                LoanAppln__c: this.loanAppId
            };
            upsertCoApplicantRecord({ recordData: coApplicantData })
                .then(response => {
                    this.disableSendOTP = true;
                    this.disableValidateOTP = true;
                })
        } else {
            otpElement.setCustomValidity('OTP Validation Failed. Kindly try again');
            this.isOTPValidated = false;
        }
        otpElement.reportValidity();
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
                this.disableValidateOTP = true;
                
                //Disappear Enter OTP field As well sent Otp message ==== DG 
                //this.showEnterOtp = true;
                this.otpSentSuccess = false;
                console.log('Timer Logic End :: '+ this.showEnterOtp );

                this.otpTimerValue = '00' + ':' + '00';
                if (this.wrapObj.OTP_Verified__c === true) {
                    this.disableSendOTP = true;
                    // To disable mobile num field after  ==== DG
                    this.disableMobileNumber = true;
                    this.isVerified = true;
                    
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
        console.log(event.target.dataset.id);
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: event.target.dataset.id
            }
        })
    }

    deleteHandler(event) {
        console.log(event.target.dataset.id);
        var deleteRecordId = event.target.dataset.id;
        if (deleteRecordId) {
            deleteFileRecord({ deleteRecordId: deleteRecordId })
                .then(respons => {
                    console.log('Response received!! ' + respons);
                    refreshApex(this.wiredResult);
                    this.showToastMessage("Success", 'File deleted', "success", "dismissible");
                })
                .catch((error) => {
                    this.showToastMessage("Error", error.body.message, "error", "dismissible");
                });
        } else {
            this.showToastMessage("Error", error.body.message, "error", "dismissible");
        }

    }

    @track fileData;
    openfileUpload(event) {
        const file = event.target.files[0];
        let fileNameParts = event.detail.files[0].name.split('.');
        let extension = '.' + fileNameParts[fileNameParts.length - 1].toLowerCase();
        if (!this.acceptedFormats.includes(extension)) {
            this.showToastMessage('File format not supported.', '', 'error', 'dismissible');
        } else {
            var reader = new FileReader();
            reader.onload = async () => {
                var base64 = reader.result.split(',')[1];
                this.fileData = {
                    'filename': file.name,
                    'base64': base64,
                    'loanAppId': this.loanAppId,
                    'applicantId': this.applicantIdOnTabset
                };
                await this.uploadFileAndShowToast(); // Call the method using await
                this.fileUploaded = true;

            };
            reader.readAsDataURL(file);
        }
    }

    async uploadFileAndShowToast() {
        const { base64, filename, loanAppId, applicantId } = this.fileData;
        try {
            await uploadFile({ base64, filename, loanAppId, applicantId });
            let title = `${filename} uploaded successfully!!`;
            this.showToastMessage('File Uploaded', title, 'success', 'dismissible');
            refreshApex(this.wiredResult);
            this.fileData = null;
        } catch (error) {
            console.error(error);
        }
    }
}