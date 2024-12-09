import { LightningElement, track, api, wire } from 'lwc';
import createAppkycDd from "@salesforce/apex/DocumentDetailController.createAppkycDd";
import findRequiredDoc from "@salesforce/apex/DocumentDetailController.findRequiredDoc";
import checkDuplicateDoc from "@salesforce/apex/DocumentDetailController.checkDuplicateDoc";
import evaluateAllRequiredRecords from "@salesforce/apex/DocumentDetailController.evaluateAllRequiredRecords";
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getAssetPropType from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import addAppkycDd from "@salesforce/apex/DocumentDetailController.addAppkycDd";
import fetchId from "@salesforce/apex/FileUploadController.fetchId";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import updateData from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { createRecord, updateRecord } from "lightning/uiRecordApi";
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import ApplicantEmployment_OBJECT from '@salesforce/schema/ApplicantEmployment__c';
import URC_UAC_APPLICABILITY_FIELD from '@salesforce/schema/ApplicantEmployment__c.Select_applicability_for_URC_UAC__c';
import DESIGNATION_VALUE from '@salesforce/schema/ApplicantEmployment__c.DesignationValues__c';
import { loadScript } from "lightning/platformResourceLoader";
import cometdlwc from "@salesforce/resourceUrl/cometd";
import getSessionId from '@salesforce/apex/SessionUtil.getSessionId';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { LABELS } from './labels';
import { SCHEMA } from './schema';
import * as HELPER from './methods';

export default class DummyShoAndEstabishment extends LightningElement {

    @api applicantIdOnTabset = 'a0AC4000000ZxZtMAK';
    @api applicantId = 'a0AC4000000ZxZtMAK';
    @api loanAppId = 'a08C4000008YqVsIAK';
    @api productType = 'Home Loan';
    @api stage = 'QDE';
    @api subStage = 'RM Data Entry';
    @api documentCategory = ["KYC Documents", "PAN Documents"];
    @api layoutSize = {
        "large": "4",
        "medium": "6",
        "small": "12"
    };
    @api isPanKyc = false;
    convertToSingleImage = true;
    @api channelName = "/event/IntRespEvent__e";
    @api channelNameRet = "/event/RetriggerUpsertCreated__e";
    @api hasEditAccess;
    @track appKycId;
    @track documentDetId;
    @track documentCatagoeyMap;
    @track availableProcessOptions = [{ label: "PAN Manual", value: "PanManual", checked: false },
    { label: "PAN Upload", value: "PanUpload", checked: false }];
    @track appKycFieldVal = {};
    @track integratMsgId;
    @track helperText = '';
    selectedDocName;
    @track iconStatus = { success: false, failure: false, inProgress: false };
    @track selectedCheckbox;
    @track docName;
    @track docType;
    @track uploadedDocuments = [];
    @track referedDocLink;
    @track ispanManual = false;
    @track ispanUpload = false;
    @track docNameOption = [];
    @track docTypeOption = [];
    @track showUpload = false;
    @track showPassportInput = false;
    @track showDlInput = false;
    @track showVoterInput = false;
    @track showAadharInput = false;
    @track showValidateBtn = false;
    @track showUploadedRecord = false;
    @track showAddDoc = false;
    @track showSpinner = false;
    @track showManualValidation = false;
    @track manualValidationStarted = false;
    @track showPanStatusMsz = false;
    @track panStatus = { ocrStatus: "", validationStatus: "" };
    @track documentCategoryList = [];
    @track docNameList = [];
    @track docTypeList = [];
    @track panDocOptions = [];
    @track panDocvalue;
    @track showPanForm60 = false;
    @track showPan = false;
    @track showPanPicklist = false;
    @track showModelPopup = false;
    @track hideOtpValidate = false;
    @track desableUpload = false;
    @track disableAadharNo = false;
    @track showPPB = false;
    @track isPpbSameAsRegOffice = false;
    @track tempPanNo;
    @track otpTimerValue;
    @track numberOfOTPAttempts;
    @track showTimer = false;
    @track isOTPNotValidated = false;
    @track hidetimer = false;
    @track timeLeft = 600;
    @track otpGenerated = false;
    @track timeout = 90000;// 90 sec timeout;
    @track showPanStatusMsg = false;
    @track PanStatusMsg = '';
    @track statusIconval = '';
    @track aadharNo = '';
    @track sessionId;
    @track disableMode;
    @track subscription;
    @track PEsubscription;
    @wire(MessageContext)
    MessageContext;
    cometdlib;
    @track utilityBillDocList = ["Electricity Bill", "Telephone Bill", "Post-paid mobile phone bill", "Piped gas bill", "Water bill"];
    @track showUtilityBillDate = false;
    @track utilityBillDate;
    @track showEstablishmentDate = false;
    @track establishmentDate;
    @track urcUacVal;
    @track optonYN = [{ label: 'Yes', value: 'YES' }, { label: 'No', value: 'NO' }];
    @track employmentId;
    @track optonUrcUacApplicablity = [];
    @track urcUacApplicablityVal;
    @track optonDesignation = [];
    @track designationVal;
    @track employmentRecord;
    @track applicantRecord;

    @track typeOfBorrower;
    @track nprDocNo;
    @track showNPRDocNo = false;
    @track maskedAadhar = '';
    @track otpVal;
    @track noIntResponec = true;
    @track addDocEnabled = false;
    @track showKycValidSuccess = true;
    @track updateEmplON = false; //LAK-7421

    get showUrcUac() {
        if ((this.applicantRecord && (this.applicantRecord.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL' || this.applicantRecord.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL') && this.applicantRecord.Constitution__c !== 'INDIVIDUAL') || (this.employmentRecord && (this.applicantRecord && (this.applicantRecord.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL' || this.applicantRecord.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL') && this.employmentRecord.Proprietorship_firm_part_of_the_proposal__c === 'NO'))) { // && (this.employmentRecord.Proprietorship_firm_part_of_the_proposal__c && this.employmentRecord.Proprietorship_firm_part_of_the_proposal__c === 'No')
            return true;
        } else {
            return false;
        }
    }
    get showUrcUacApplicablity() {
        if ((this.employmentRecord && (this.employmentRecord.Is_URC_UAC_available__c === 'YES'))) {
            return true;
        } else {
            return false;
        }
    }
    showUdhyamBox = false
    //to show URC number column
    get showURCnumberBlock() {
        if ((this.employmentRecord && (this.employmentRecord.Is_URC_UAC_available__c === 'YES' && this.employmentRecord.Select_applicability_for_URC_UAC__c === 'UDYAM REGISTRATION NUMBER (URC)' && this.docName == 'Udyam Registration Certificate' && this.showUdhyamBox))) {
            return true;
        } else {
            return false;
        }
    }
    get showDesignation() {
        if ((this.applicantRecord && (this.applicantRecord.CustProfile__c && (this.applicantRecord.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL' || this.applicantRecord.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL')) && this.applicantRecord.Constitution__c && this.applicantRecord.Constitution__c === 'INDIVIDUAL')) {
            return true;
        } else {
            return false;
        }
    }
    get showIsProp() {
        if ((this.employmentRecord && (this.employmentRecord.DesignationValues__c && this.employmentRecord.DesignationValues__c === 'PROPRIETOR'))) {
            return true;
        } else {
            return false;
        }
    }
    get desableOnRunManual() {
        if (this.disableMode) {
            return true;
        } else {
            if (this.showManualValidation) {
                return true;
            } else {
                return false;
            }
        }
    }
    @wire(getSessionId)
    wiredSessionId({ error, data }) {
        if (data) {
            this.sessionId = data;
            loadScript(this, cometdlwc);
        } else if (error) {
            console.log('Error In getSessionId = ', error);
            this.sessionId = undefined;
        }
    }
    @wire(getObjectInfo, { objectApiName: ApplicantEmployment_OBJECT })
    ApplicantEmploymentobjInfo

    @wire(getPicklistValues, { recordTypeId: '$ApplicantEmploymentobjInfo.data.defaultRecordTypeId', fieldApiName: URC_UAC_APPLICABILITY_FIELD })
    applicabilityOptionsHandler({ data, error }) {
        if (data) {

            this.optonUrcUacApplicablity = [...this.generatePicklist(data)]
        }
        if (error) {
            console.log(error)
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$ApplicantEmploymentobjInfo.data.defaultRecordTypeId', fieldApiName: DESIGNATION_VALUE })
    designationOptionsHandler({ data, error }) {
        if (data) {

            this.optonDesignation = [...this.generatePicklist(data)]
        }
        if (error) {
            console.log(error)
        }
    }
    generatePicklist(data) {
        return data.values.map(item => ({ label: item.label, value: item.value }))
    }

    get majorAgeDate() {
        const today = new Date();
        const ageOf18 = new Date(today);
        ageOf18.setFullYear(today.getFullYear() - 18);
        return ageOf18.toISOString();
    }
    get todayDateValue() {
        const todaydate = new Date();
        return todaydate.toISOString();
    }
    //method to sort array of objects alphabetically
    compareByLabel(a, b) {
        const nameA = a.label.toUpperCase();
        const nameB = b.label.toUpperCase();
        if (nameA < nameB) {
            return -1;
        }
        if (nameA > nameB) {
            return 1;
        }
        return 0;
    }
    connectedCallback() {
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        } else {
            this.disableMode = false;
        }
        this.sunscribeToMessageChannel();

        if (this.applicantIdOnTabset) {
            this.applicantId = this.applicantIdOnTabset;
        }
        if (!this.applicantId || this.applicantId === 'new') {
            this.showToast("Error ", "error", LABELS.PanKycCheck_ApplicantVerf_ErrorMessage);
            return;
        }
        this.documentCategoryList = this.documentCategory;
        this.docNameList.push(this.docName);
        this.docTypeList = ['Identity Proof'];
        if (this.applicantId) {
            findRequiredDoc({ applicantId: this.applicantId, loanAppId: this.loanAppId, productType: this.productType, stage: this.stage, subStage: this.subStage })
                .then((result) => {
                    let catOptons = result['KYC Documents'];
                    if (result['PAN Documents'] && result['PAN Documents']['Form 60']) {
                        let panCatOptions = result['PAN Documents']['PAN'];
                        let form60 = result['PAN Documents']['Form 60'][0];
                        panCatOptions = [...panCatOptions, form60];

                        panCatOptions.forEach((child) => {
                            let panOpt = { label: child, value: child };
                            this.panDocOptions = [...this.panDocOptions, panOpt];
                            this.panDocOptions.sort(this.compareByLabel);

                        });
                        this.showPanPicklist = true;
                    } else {
                        this.showPan = true;
                        this.showPanPicklist = false;
                    }
                    this.documentCatagoeyMap = catOptons;
                    Object.keys(catOptons).forEach(key => {
                        let doc = { label: key, value: key };
                        this.docTypeOption = [...this.docTypeOption, doc];
                        this.docTypeOption.sort(this.compareByLabel);
                    });
                    this.showUploadedRecord = true;
                    let ev = { detail: { value: "PAN" } };
                    this.handlePanDocChange(ev);
                })
                .catch((err) => {

                    this.showToast("Error ", "error", err.message);
                })
                .finally(() => {
                });
        } else {

            this.showToast("Error ", "error", This.label.PanKycCheck_AddRecord_ErrorMessage);
        }
        //FOR LAK-3994
        this.getApplicantDetails();
        //FOR LAK-3994
    }
    //FOR LAK-3994
    getApplicantDetails() {
        this.showSpinner = true;
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'Name', 'Type_of_Borrower__c', 'CustProfile__c', 'Constitution__c', 'LoanAppln__r.Stage__c', 'LoanAppln__r.SubStage__c', 'LoanAppln__r.Product__c'], // added for LAK-3203
            queryCriteria: ' where Id = \'' + this.applicantId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {

                if (result.parentRecords && result.parentRecords.length > 0) {
                    let res = result.parentRecords;
                    this.typeOfBorrower = res[0].Type_of_Borrower__c;
                    this.getEmploymentDetail(res[0]);
                    this.stage = res[0].LoanAppln__r.Stage__c;
                    this.productType = res[0].LoanAppln__r.Product__c;
                    this.subStage = res[0].LoanAppln__r.SubStage__c;
                } else {
                    this.applicantRecord = { Id: null, Type_of_Borrower__c: '', CustProfile__c: '', Constitution__c: '' };
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Applicant Details is ', error);
            });
    }

    handleChangeUrc(event) {
        let name = event.target.name;
        let val = event.target.value;
        this.employmentRecord[name] = val;
        if (name === 'DesignationValues__c') {
            this.employmentRecord.Proprietorship_firm_part_of_the_proposal__c = '';
            this.employmentRecord.Is_URC_UAC_available__c = '';
            this.employmentRecord.Select_applicability_for_URC_UAC__c = '';
            this.employmentRecord.UdyamRegistrationNumber__c = '';
        }
        if (name === 'Proprietorship_firm_part_of_the_proposal__c') {
            this.employmentRecord.Is_URC_UAC_available__c = '';
            this.employmentRecord.Select_applicability_for_URC_UAC__c = '';
            this.employmentRecord.UdyamRegistrationNumber__c = '';
        }
        if (name === 'Is_URC_UAC_available__c') {
            this.employmentRecord.Select_applicability_for_URC_UAC__c = '';
            this.employmentRecord.UdyamRegistrationNumber__c = '';
        }
        if (name === 'Select_applicability_for_URC_UAC__c') {
            this.employmentRecord.UdyamRegistrationNumber__c = '';
            this.showUdhyamBox = true;
        }
        console.log('this.employmentRecord' + JSON.stringify(this.employmentRecord));

    }
    @track oldValOfUdyamReginNum;
    getEmploymentDetail(event) {
        let appRecVal = event;
        let params = {
            ParentObjectName: 'ApplicantEmployment__c ',
            parentObjFields: ['Id', 'UdyamRegistrationNumber__c', 'Is_URC_UAC_available__c', 'Select_applicability_for_URC_UAC__c', 'Proprietorship_firm_part_of_the_proposal__c', 'DesignationValues__c'],
            queryCriteria: ' where LoanApplicant__c = \'' + this.applicantId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {

                this.showSpinner = false;
                this.applicantRecord = appRecVal;
                this.employmentRecord = { Id: null, DesignationValues__c: '', Select_applicability_for_URC_UAC__c: '', Is_URC_UAC_available__c: '', Proprietorship_firm_part_of_the_proposal__c: '', UdyamRegistrationNumber__c: '' };
                if (result.parentRecords) {
                    let res = result.parentRecords;
                    if (res[0] && res[0].Id) {
                        this.employmentRecord = res[0];
                        this.oldValOfUdyamReginNum = res[0].UdyamRegistrationNumber__c;
                        console.log(' this.oldValOfUdyamReginNum' + this.oldValOfUdyamReginNum)

                    }
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Applicant Employment Details is ', error);
            });
    }
    //FOR LAK-3994
    handlePanDocChange(event) {
        this.panDocvalue = event.detail.value;

        if (this.panDocvalue === "Form 60") {
            if (this.uploadedDocuments.find((doc) => doc.docDetName == "Form 60")) {
                this.showToast("warning", "warning", LABELS.PanKycCheck_Form60_ErrorMessage);
                this.showPanForm60 = false;
                this.showPan = false;
            } else {
                if (this.uploadedDocuments.find((doc) => doc.docDetName == "PAN")) {
                    this.showToast("warning", "warning", LABELS.PanKycCheck_uploaded_ErrorMessage);
                    this.showPanForm60 = false;
                    this.showPan = false;
                } else {
                    this.isPanKyc = true;
                    this.showPanForm60 = true;
                    this.showPan = false;
                }
            }
        } else {
            let panDoc = this.uploadedDocuments.find((doc) => doc.docDetName == "PAN");
            if (panDoc) {
                if (panDoc.validationStatus && panDoc.validationStatus === 'Success') {
                    this.showToast("warning", "warning", LABELS.PanKycCheck_uploaded_ErrorMessage);
                } else {
                    this.showPanForm60 = false;
                    this.showPan = true;
                }
            } else {
                if (this.uploadedDocuments.find((doc) => doc.docDetName == "Form 60")) {
                    this.showToast("warning", "warning", LABELS.PanKycCheck_Form60_ErrorMessage);
                    this.showPanForm60 = false;
                    this.showPan = false;
                } else {
                    this.showPanForm60 = false;
                    this.showPan = true;
                }
            }
        }
    }
    handleSelectProcess(event) {
        this.showManualValidation = false;
        let val = event.target.value;
        for (let i = 0; i < this.availableProcessOptions.length; i++) {
            if (this.availableProcessOptions[i].checked == true) {
                this.availableProcessOptions[i].checked = false;
            }
        }
        for (let i = 0; i < this.availableProcessOptions.length; i++) {
            if (this.availableProcessOptions[i].value == val) {
                this.availableProcessOptions[i].checked = true;
            }
        }
        this.handlePanStatus(val)
    }
    handlePanStatus(val) {
        if (this.uploadedDocuments.find((doc) => doc.docDetName == "PAN")) {
            if (this.uploadedDocuments.find((doc) => doc.docDetType == "PAN" && this.uploadedDocuments.find((doc) => doc.docDetName == "PAN"))) {
                let forPan = this.uploadedDocuments.find((doc) => doc.docDetName == "PAN");
                if (forPan.validationStatus === "Success") {
                    this.ispanManual = false;
                    this.ispanUpload = false;
                    this.showPanStatusMsg = true;
                    this.PanStatusMsg = "  PAN Validated";
                    this.iconStatus = { success: true, failure: false, inProgress: false };// commented for enhancemet
                } else if (forPan.validationStatus !== "Success") {
                    if (val == "PanManual") {
                        this.ispanManual = true;
                        this.showManualValidation = false;
                        this.docType = '';
                        this.ispanUpload = false;
                        this.showPanStatusMsg = false;
                    } else if (val == "PanUpload") {
                        this.ispanManual = false;
                        this.ispanUpload = false;
                        this.showPanStatusMsg = true;
                        this.PanStatusMsg = "  PAN  Validation Pending";
                        if (forPan.validationStatus === "Failure") {
                            this.iconStatus = { success: false, failure: true, inProgress: false, addExistingPan: false };
                        } else {
                            this.iconStatus = { success: false, failure: false, inProgress: true, addExistingPan: false };
                        }
                    }
                }
            }
            else if (this.uploadedDocuments.find((doc) => doc.docDetType !== "PAN" && this.uploadedDocuments.find((doc) => doc.docDetName == "PAN"))) {
                this.showPanStatusMsg = false;
                let forPan = this.uploadedDocuments.find((doc) => doc.docDetName == "PAN");
                if (val == "PanManual") {
                    this.ispanManual = true;
                    this.ispanUpload = false;
                } else if (val == "PanUpload") {
                    this.ispanManual = false;
                    this.ispanUpload = false;
                    this.showPanStatusMsg = true;
                    this.PanStatusMsg = "";
                    this.iconStatus = { success: false, failure: false, inProgress: false, addExistingPan: true };
                }
            }
            else {
                this.ispanManual = false;
                this.ispanUpload = false;
                this.showPanStatusMsg = true;

                this.PanStatusMsg = "";
                this.iconStatus = { success: false, failure: false, inProgress: false, addExistingPan: false };
            }
        } else {
            this.showPanStatusMsg = false;
            if (val == "PanManual") {
                this.ispanManual = true;
                this.ispanUpload = false;
            } else if (val == "PanUpload") {
                this.ispanManual = false;
                this.ispanUpload = true;
                this.isPanKyc = true;
            }
        }
    }
    handlePPBChange(event) {
        let ppbChecked = event.target.checked;
        if (ppbChecked) {
            this.isPpbSameAsRegOffice = true;
        } else {
            this.isPpbSameAsRegOffice = false;
        }
    }
    handleChange(event) {
        let name = event.target.name;
        let val = event.target.value;
        this.showUtilityBillDate = false;
        this.showEstablishmentDate = false;
        this.showNPRDocNo = false;
        if (name === 'DocumentType') {
            this.docType = val;
            this.docName = '';
            let ppb = "Principal Place of Business - Address Proof";
            if (this.docType.toLowerCase() === ppb.toLowerCase()) {
                this.showPPB = true;
            } else {
                this.showPPB = false;
            }
            if (this.uploadedDocuments && (this.uploadedDocuments.find((doc) => doc.docDetType.toLowerCase() == this.docType.toLowerCase()))) {
                let strVal1 = "Constitution wise Mandatory KYC documents";
                let strVal2 = "Residence Address proof - Deemed OVD";
                if (this.docType.toLowerCase() !== strVal1.toLowerCase() && this.docType.toLowerCase() !== strVal2.toLowerCase()) {
                    this.docType = "";
                    this.docNameOption = [];
                    this.showUpload = false;
                    this.showToast("Error", "error", LABELS.PanKycCheck_DocUploaded_ErrorMessage);
                } else {
                    this.docNameOption = [];
                    this.documentCatagoeyMap[val].forEach(item => {
                        let doc = { label: item, value: item };
                        this.docNameOption = [...this.docNameOption, doc];
                        this.docNameOption.sort(this.compareByLabel);
                    });
                }
            } else {
                this.docNameOption = [];
                this.documentCatagoeyMap[val].forEach(item => {
                    let doc = { label: item, value: item };
                    this.docNameOption = [...this.docNameOption, doc];
                    this.docNameOption.sort(this.compareByLabel);
                });
            }
        }
        if (name === 'DocumentName') {
            this.docName = val;
            this.getHelperVariable(this.docName, this.docType);
            console.log('valvalvalvalval' + val)
            if (this.docName == 'Udyam Registration Certificate') {

            }


        }
        if (this.docNameOption.length > 0 && this.docName) {
            this.showUpload = true;
            this.isPanKyc = true;
            this.showAddDoc = false;
        } else {
            this.showUpload = false;
        }
        if (this.docType && this.docName) {
            let strVal1 = "Constitution wise Mandatory KYC documents";
            let strVal2 = "Residence Address proof - Deemed OVD";

            let strVal3 = "Principal Place of Business - Address Proof"
            let strVal4 = "Registered office - Address Proof"
            if (this.uploadedDocuments
                && (this.uploadedDocuments.find((doc) => doc.docDetType.toLowerCase() === this.docType.toLowerCase()
                    && doc.docDetName.toLowerCase() === this.docName.toLowerCase())
                )
            ) {
                this.showUpload = false;
                this.showToast("Error", "error", LABELS.PanKycCheck_DocalreadyUploaded_ErrorMessage);
            } else if (this.docType.toLowerCase() === strVal1.toLowerCase() || this.docType.toLowerCase() === strVal2.toLowerCase()) {
                if (this.utilityBillDocList.includes(this.docName)) {
                    if (this.docName === 'Electricity Bill') {
                        this.showUtilityBillDate = true;
                        this.showElectricityBill = true;
                        this.showUpload = true;

                    } else {
                        this.showElectricityBill = false
                        this.showUtilityBillDate = true;
                        this.showUpload = false;
                    }
                    // this.showUtilityBillDate = true;
                    // this.showUpload = false;
                } else {
                    this.showUpload = true;
                    this.isPanKyc = true;
                    this.handleButtonState();
                }
            } else if (this.docType.toLowerCase() === strVal3.toLowerCase() || this.docType.toLowerCase() === strVal4.toLowerCase()) {
                if (this.utilityBillDocList.includes(this.docName)) {
                    if (this.docName === 'Electricity Bill') {
                        // this.getAreaValues('Electricity Service Provider');
                        this.showUtilityBillDate = true;
                        this.showElectricityBill = true;
                        this.showUpload = false;

                    } else {
                        this.showElectricityBill = false
                        this.showUtilityBillDate = true;
                        this.showUpload = false;
                    }

                } else if (this.docName === "Shop and Establishment") {
                    this.getAreaValues('Shop & Establishment Area Code');
                    // this.showEstablishmentDate = true;
                    this.showUpload = false;
                } else {
                    this.showUpload = true;
                    this.isPanKyc = true;
                    this.handleButtonState();
                }
            } else if ((this.docType === 'Identity Proof' || this.docType === 'Residence Address proof - OVD') && this.docName === "Letter issued by the National Population Register") {
                this.showNPRDocNo = true;
                this.showUpload = false;
            }
            else if (this.uploadedDocuments.find((doc) => doc.docDetName.toLowerCase() === this.docName.toLowerCase())) {
                this.handleButtonState();
            } else {
                this.showUtilityBillDate = false;
                this.showEstablishmentDate = false;
                this.showNPRDocNo = false;
            }
        }
        this.showManualValidation = false;
    }

    @track shopEstAreCodeOptions = [];

    get filtercondition() {
        let type = 'Electricity Service Provider';
        return 'Type__c = \'' + type + '\'';
    }
    get filterconditionDist() {
        let type = 'Electricity Service Provider District';
        if (this.spValue != null) {
            return 'Type__c = \'' + type + '\'' + ' AND ScvProviderCode__c = \'' + this.spValue + '\'';
        } else {
            return '';
        }
    }
    handleLookupFieldChangeDist(event) {
        if (event.detail) {
            console.log('Event detail District ====> ', event.detail);
            this.billDist = event.detail.mainField;
        }
    }

    //@track spLabel;
    handleLookupFieldChange(event) {
        if (event.detail) {
            this.billDist = '';
            console.log('Event detail spLabel====> ', event.detail);
            let spId = event.detail.id;
            this.showBillDist = false;
            this.spLabel = event.detail.mainField;
            if (this.spLabel !== null) {
                if (this.spLabel == 'Others') {
                    this.consumerIdRequired = true;
                    this.showUpload = false;
                    this.isPanKyc = false;
                } else {
                    this.getSPCode(spId);
                    this.consumerIdRequired = false;
                    this.showUpload = true;
                    this.isPanKyc = true;
                }
            }
            console.log("spLabel>>>", this.spLabel);
        }
    }
    getSPCode(spId) {
        let paramsForApp = {
            ParentObjectName: 'MasterData__c',
            ChildObjectRelName: '',
            parentObjFields: ["Id", "Name", "SalesforceCode__c"],
            childObjFields: [],
            queryCriteria: ' where Id = \'' + spId + '\''
        }
        getAssetPropType({ params: paramsForApp })
            .then((res) => {
                if (res.parentRecords.length > 0) {
                    console.log('Selected SP Data is :: ', res.parentRecords);
                    this.spValue = res.parentRecords[0].SalesforceCode__c;
                    if (this.askForDistList.includes(this.spValue)) {
                        this.showBillDist = true;
                        //this.getSPCode(spId);
                        this.showUpload = true;
                    }
                }
            })
            .catch((err) => {
                console.log(" getSobjectDatawithRelatedRecords error fro getting getSPCode===", err);
            });
    }
    getAreaValues(type) {
        let paramsForApp = {
            ParentObjectName: 'MasterData__c',
            ChildObjectRelName: '',
            parentObjFields: ["Id", "Name", "SalesforceCode__c"],
            childObjFields: [],
            queryCriteria: ' where type__c = \'' + type + '\''
        }
        getAssetPropType({ params: paramsForApp })
            .then((res) => {
                if (res.parentRecords.length > 0) {
                    let options = [];
                    res.parentRecords.forEach(item => {
                        if (item.Name != 'Others') {
                            let step = {
                                label:
                                    item.Name,
                                value: item.SalesforceCode__c
                            };
                            //subStepsLocal.push(step);
                            options.push(step);
                        } else {
                            let step = {
                                label:
                                    item.Name,
                                value: item.Name
                            };
                            //subStepsLocal.push(step);
                            options.push(step);
                        }

                    })
                    if (type === 'Shop & Establishment Area Code') {
                        if (options && options.length > 0) {
                            this.shopEstAreCodeOptions = options;
                            this.showEstablishmentDate = true;
                            this.showUpload = false;
                        }
                        console.log('this.shopEstAreCodeOptions', this.shopEstAreCodeOptions);
                    }
                    else if (type === 'Electricity Service Provider') {
                        if (options && options.length > 0) {
                            this.spOptions = options;
                            this.showUtilityBillDate = true;
                            this.showElectricityBill = true;
                            this.showUpload = false;
                        }
                        console.log('this.shopEstAreCodeOptions', this.shopEstAreCodeOptions);
                    }

                }

            })
            .catch((err) => {
                this.showSpinner = false;
                this.showToast("Error", "error", err.message);
                console.log(" getSobjectDatawithRelatedRecords error fro getting area codes===", err);
            });
    }

    @track spValue;
    @track spLabel;
    @track spOptions;
    @track showElectricityBill = false;
    @track consumerIdRequired = false;
    @track consumerIdValue;
    @track billDist = '';
    @track showBillDist = false;
    @track askForDistList = ["JBVNL", "UPPCL"];
    handleInputChangeConsumerId(event) {
        this.consumerIdValue = event.target.value;
        if (this.consumerIdValue && this.consumerIdRequired && this.spValue != null) {


            this.isPanKyc = true;
            if (this.showBillDist && this.billDist != null) {
                this.showUpload = true;
            } else {
                this.showUpload = true;
            }
        }
    }

    handleSPChange(event) {
        this.spValue = event.target.value;
        this.showBillDist = false;
        if (this.askForDistList.includes(this.spValue)) {
            this.showBillDist = true;
        }
        if (this.spValue && this.spValue != 'Others') {
            this.consumerIdRequired = true;
            this.showUpload = false;
            this.isPanKyc = false;

        } else {
            this.consumerIdRequired = false;
            //this.showUpload = true;
            this.isPanKyc = true;
        }
        console.log('  electricity bill options ', this.spOptions, ' :: spValue is :', this.spValue, "  spLabel is  : ", this.spLabel);
    }



    @track shopAreaValue;
    @track showInpitParam = false;
    @track resgitrationValue;
    @track shopAreaCode;
    handleAreaChange(event) {
        this.shopAreaValue = event.target.value;
        if (this.shopAreaValue && this.shopAreaValue != 'Others') {
            this.showInpitParam = true;
            this.showUpload = false;
            this.isPanKyc = false;
        } else {
            this.showInpitParam = false;
            this.showUpload = true;
            this.isPanKyc = true;
        }
        if (this.shopAreaValue) {
            this.shopEstAreCodeOptions.forEach(item => {
                if (item.value === this.shopAreaValue) {
                    this.shopAreaCode = item.label;
                }
            })
        }
    }


    handleKeyPress(event) {
        const chatCode = event.charCode;
        console.log('chatCode', chatCode);
        if (!((chatCode >= 48 && chatCode <= 57) || (chatCode >= 65 && chatCode <= 90) || (chatCode >= 97 && chatCode <= 122))) {
            event.preventDefault();
        }
    }

    handleInputChangeEstablishmentDate(event) {//  https://fedfina.atlassian.net/browse/LAK-4748
        let val = event.target.value;
        if (event.target.name == 'UtilityBillDate__c') {
            // let dateVal = event.target.value;
            this.establishmentDate = val;
        } else if (event.target.name == 'Registration Number') {
            this.resgitrationValue = val.toUpperCase();
        }
        if (this.establishmentDate && this.resgitrationValue) {
            this.showUpload = true;
            this.isPanKyc = true;
        }

    }

    handleInputChangeNprNo(event) {
        let val = event.target.value.toUpperCase();
        this.nprDocNo = val;
        if (val) {
            this.showUpload = true;
            this.isPanKyc = true;
        } else {
            this.showUpload = false;
        }
    }
    get utilityBillMinDate() {
        // Set the minimum date to 60 days ago
        const minDate = new Date();
        minDate.setDate(minDate.getDate() - 60);
        return minDate.toISOString().split('T')[0];
    }
    get todayDateValueForUB() {
        const today = new Date();
        today.setDate(today.getDate() - 1);
        return today.toISOString().split('T')[0];
    }
    handleInputChangeUtilityBillDate(event) {
        let dateVal = event.target.value;
        const selectedDateObj = new Date(dateVal);
        const minDateObj = new Date(this.utilityBillMinDate);
        const maxDateObj = new Date(this.todayDateValueForUB);

        selectedDateObj.setHours(0, 0, 0, 0);
        minDateObj.setHours(0, 0, 0, 0);
        maxDateObj.setHours(0, 0, 0, 0);

        if (selectedDateObj >= minDateObj && selectedDateObj <= maxDateObj) {
            // Date is within the allowed range, show success toast
            if (this.addDocEnabled) {
                this.showAddDoc = true;
            } else {
                this.showUpload = true;
                this.isPanKyc = true;
            }
            this.utilityBillDate = dateVal;
        } else {
            // Date is outside the allowed range, show error toast
            this.showAddDoc = false;
            this.showUpload = false;
            this.utilityBillDate = null;
        }

    }


    getHelperVariable(docName, docType) {

        let docNamee = docName.replace(/'/g, "\\'");
        let params = {
            ParentObjectName: 'DocMstr__c',
            parentObjFields: ["Id", "AvlInFile__c", "DocHelpText__c"],

            queryCriteria: ' where DocTyp__c = \'' + docType + '\' AND DocSubTyp__c = \'' + docNamee + '\''
        };
        getSobjectDatawithRelatedRecords({ params: params })
            .then((res) => {
                let result = res.parentRecord;

                if (result && result.DocHelpText__c) {
                    this.helperText = result.DocHelpText__c;

                } else {
                    this.helperText = '';

                }
            })
            .catch((err) => {
                this.showToast("Error", "error", err.message);
                console.log(" getSobjectDatawithRelatedRecords error===", err);
            });

    }

    handleButtonState() {
        if (this.uploadedDocuments && this.docType && this.docName) {
            let searchDoc = this.uploadedDocuments.find((doc) => doc.docDetType.toLowerCase() == this.docType.toLowerCase());
            let strVal1 = "Constitution wise Mandatory KYC documents";
            let strVal2 = "Residence Address proof - Deemed OVD";
            if (searchDoc && searchDoc.docDetType.toLowerCase() !== strVal1.toLowerCase() && searchDoc.docDetType.toLowerCase() !== strVal2.toLowerCase()) {
                this.showUpload = false;
                this.showAddDoc = false;
            } else {
                searchDoc = this.uploadedDocuments.find((doc) => doc.docDetName.toLowerCase() == this.docName.toLowerCase());
                if (searchDoc) {
                    if (this.uploadedDocuments.find((doc) => doc.docDetType.toLowerCase() !== this.docType.toLowerCase())) {

                        this.showUpload = false;
                        if (this.utilityBillDocList.includes(this.docName)) {
                            this.showUtilityBillDate = true;
                            this.addDocEnabled = true;
                        } else {
                            this.showAddDoc = true;
                        }
                        let index = this.uploadedDocuments.findIndex((doc) => doc.docDetName.toLowerCase() == this.docName.toLowerCase());
                        this.referedDocLink = this.uploadedDocuments[index].LinkedEntityId;
                    }
                    else if (searchDoc.docDetType.toLowerCase() !== strVal1.toLowerCase() && searchDoc.docDetType.toLowerCase() !== strVal2.toLowerCase() && searchDoc.docDetType.toLowerCase() !== this.docType.toLowerCase()) {
                        this.showUpload = false;
                        this.showAddDoc = true;
                        let index = this.uploadedDocuments.findIndex((doc) => doc.docDetName.toLowerCase() == this.docName.toLowerCase());
                        this.referedDocLink = this.uploadedDocuments[index].LinkedEntityId;
                    }
                    else {
                        this.showUpload = false;
                        this.showAddDoc = false;
                    }

                } else {
                    this.showUpload = true;
                    this.showAddDoc = false;
                    this.isPanKyc = true;
                }
            }

        } else {
            console.log('not found this.docType, this.docName');
        }
    }
    @api reportValidity() {

        const isInputCorrect = [
            ...this.template.querySelectorAll("lightning-input")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        return isInputCorrect;
    }
    handleInputChangePan(event) {
        this.tempPanNo = '';
        let nm = event.target.name;
        let val = event.target.value.toUpperCase();
        if (nm === "Pan__c") {
            this.appKycFieldVal[nm] = val;
            this.tempPanNo = val;
        }
    }
    handleInputChangePassport(event) {
        let nm = event.target.name;
        let val = event.target.value;
        if (nm === "FileNo__c") {
            this.appKycFieldVal[nm] = val.toUpperCase();
        } else if (nm === "DtOfBirth__c") {
            this.appKycFieldVal[nm] = val;
        } else if (nm === "PassNo__c") {
            this.appKycFieldVal[nm] = val.toUpperCase();
        }
        else if (nm === "PassExpDt__c") {
            this.appKycFieldVal[nm] = val;
        }
    }
    handleInputChangeVoterId(event) {
        let nm = event.target.name;
        let val = event.target.value;
        if (nm === "VotIdEpicNo__c") {
            this.appKycFieldVal[nm] = val.toUpperCase();
        }
    }
    handleInputChangeDl(event) {
        let nm = event.target.name;
        let val = event.target.value;
        if (nm === "DtOfBirth__c") {
            this.appKycFieldVal[nm] = val;
        } else if (nm === "DLNo__c") {
            this.appKycFieldVal[nm] = val.toUpperCase();
        }
        else if (nm === "DLExpDt__c") {
            this.appKycFieldVal[nm] = val;
        }
    }
    handleInputChangeAadharNo(event) {
        let nm = event.target.name;
        let val = event.target.value;
        if (nm === "AadharNo__c") {
            this.appKycFieldVal[nm] = val;
            this.appKycFieldVal.AadharEncripted__c = val;
        }
        this.aadharNo = val;
        const isValid = /^(XXXXXXXX0000|\d{12})$/.test(val);
        if (!isValid) {
            event.target.setCustomValidity('Your entry does not match the allowed pattern.');
        }
        else {
            event.target.setCustomValidity('');
        }
        event.target.reportValidity();
    }
    handlePanValidateClick() {
        let panNo = this.appKycFieldVal["Pan__c"];
        let isInputCorrect = this.reportValidity();
        if (isInputCorrect === true) {
            checkDuplicateDoc({ loanId: this.loanAppId, appKycId: null, docId: panNo, docType: 'panValidate', applId: this.applicantId })
                .then((result) => {
                    if (result === true) {
                        this.showToast("error", "error", 'Duplicate Document Exists. Kindly Upload another Document');
                        this.stopSpinner();

                    } else {
                        this.validatePAN();
                    }
                })
                .catch((err) => {
                    console.log('Error in checkDuplicateDoMethod::::1528  ', JSON.stringify(err));
                })
                .finally(() => {
                });
        }
    }
    validatePAN() {
        let panNo = this.appKycFieldVal["Pan__c"];
        this.showSpinner = true;
        this.manualValidationStarted = true;
        let paramsForApp = {
            ParentObjectName: 'Applicant__c',
            ChildObjectRelName: '',
            parentObjFields: ["Id", "Constitution__c"],
            childObjFields: [],
            queryCriteria: ' where Id = \'' + this.applicantId + '\''
        }
        getAssetPropType({ params: paramsForApp })
            .then((res) => {
                if (res.parentRecords.length > 0) {
                    let result = res.parentRecords[0];
                    if (result && result.Constitution__c) {
                        let constitutionIs = result.Constitution__c;
                        let isPanValid = HELPER.checkPanValidity(panNo, constitutionIs);
                        if (isPanValid) {
                            if (!this.appKycId) {
                                this.createDocumentDetailRecord("PAN Documents", "PAN", "PAN");
                            } else {
                                this.createPANIntegrationMsg(this.appKycId, this.documentDetId);
                            }
                        }
                        else {
                            this.showSpinner = false;
                            this.showToast("Error", "error", LABELS.PanKycCheck_PanMatch_ErrorMessage);
                        }
                    }
                }
            })
            .catch((err) => {
                this.showSpinner = false;
                this.showToast("Error", "error", err.message);
                console.log(" getSobjectDatawithRelatedRecords error===", err);
            });
    }
    validateDocs(event) {
        let nm = event;
        this.showSpinner = true;
        this.manualValidationStarted = true;
        const appKycFields = {};
        const ingMsgFields = {};
        ingMsgFields[SCHEMA.BU.fieldApiName] = 'HL / STL';
        ingMsgFields[SCHEMA.IS_ACTIVE.fieldApiName] = true;
        ingMsgFields[SCHEMA.EXUC_TYPE.fieldApiName] = 'Async';
        ingMsgFields[SCHEMA.STATUS.fieldApiName] = 'New';
        ingMsgFields[SCHEMA.DOC_API.fieldApiName] = false;
        ingMsgFields[SCHEMA.OUTBOUND.fieldApiName] = true;
        ingMsgFields[SCHEMA.TRIGGER_PLATFORM_EVENT.fieldApiName] = true;
        ingMsgFields[SCHEMA.REF_OBJ.fieldApiName] = 'DocDtl__c';
        ingMsgFields[SCHEMA.REF_ID.fieldApiName] = this.documentDetId;
        ingMsgFields[SCHEMA.PARENT_REF_OBJ.fieldApiName] = "ApplKyc__c";
        ingMsgFields[SCHEMA.PARENT_REF_ID.fieldApiName] = this.appKycId;
        if (nm === "dlValidate") {
            this.callSubscribePlatformEve();
            let serviceName = "DL Authentication";
            ingMsgFields[SCHEMA.SVC.fieldApiName] = serviceName;
            ingMsgFields[SCHEMA.NAME.fieldApiName] = serviceName;
            appKycFields[SCHEMA.DL_NO.fieldApiName] = this.appKycFieldVal.DLNo__c;
            appKycFields[SCHEMA.DATE_OF_BIRTH.fieldApiName] = this.appKycFieldVal.DtOfBirth__c;
            appKycFields[SCHEMA.DL_EXP_DATE.fieldApiName] = this.appKycFieldVal.DLExpDt__c;
        }
        if (nm === "voterIdValidate") {
            this.callSubscribePlatformEve();
            let serviceName = "Voterid Verification";
            ingMsgFields[SCHEMA.SVC.fieldApiName] = serviceName;
            ingMsgFields[SCHEMA.NAME.fieldApiName] = serviceName;
            appKycFields[SCHEMA.VOTER_EPIC_NO.fieldApiName] = this.appKycFieldVal.VotIdEpicNo__c;
        }
        if (nm === "passportValidate") {
            this.callSubscribePlatformEve();
            let serviceName = "Passport Verification";
            ingMsgFields[SCHEMA.SVC.fieldApiName] = serviceName;
            ingMsgFields[SCHEMA.NAME.fieldApiName] = serviceName;
            appKycFields[SCHEMA.FILE_NO.fieldApiName] = this.appKycFieldVal.FileNo__c;
            appKycFields[SCHEMA.DATE_OF_BIRTH.fieldApiName] = this.appKycFieldVal.DtOfBirth__c;
            appKycFields[SCHEMA.PASS_NO.fieldApiName] = this.appKycFieldVal.PassNo__c;
            appKycFields[SCHEMA.PASS_EXP_DATE.fieldApiName] = this.appKycFieldVal.PassExpDt__c;
        }
        if (nm === "panValidate") {
            this.callSubscribePlatformEve();
            let serviceName = "Pan Validation";
            ingMsgFields[SCHEMA.SVC.fieldApiName] = serviceName;
            ingMsgFields[SCHEMA.NAME.fieldApiName] = serviceName;
            appKycFields[SCHEMA.PAN.fieldApiName] = this.appKycFieldVal.Pan__c;
        }
        if (nm === "aadharValidate") {
            this.startTimer();
            this.showSpinner = false;
            this.showModelPopup = true;
            this.otpVal = '';
            if (this.numberOfOTPAttempts < 3) {
                this.callSubscribePlatformEve();
                const appKycFields = {};
                let serviceName = "SFDC Aadhar XML Verification API";
                ingMsgFields[SCHEMA.SVC.fieldApiName] = serviceName;
                ingMsgFields[SCHEMA.NAME.fieldApiName] = serviceName;
                if (this.appKycFieldVal.AadharNo__c.startsWith('X')) {
                    appKycFields[SCHEMA.AADHAR.fieldApiName] = this.appKycFieldVal.AadharNo__c;
                }
                else {
                    appKycFields[SCHEMA.AADHAR.fieldApiName] = 'XXXXXXXX' + this.appKycFieldVal.AadharNo__c.substring(8);
                }
                appKycFields[SCHEMA.AADHAR_ENCRIPTED.fieldApiName] = this.appKycFieldVal.AadharEncripted__c;
                // dummy 
                appKycFields[SCHEMA.APP_KYC_ID.fieldApiName] = this.appKycId;
                const recordInput = {
                    fields: appKycFields
                };
                updateRecord(recordInput).then((record) => {
                })
                    .catch((err) => {
                        console.log(" Error applicant Kyc OTP Count NOT updated ", err.body.message);
                    })
            } else {
                console.log('max otp attemp reach ', this.numberOfOTPAttempts);
                this.hideOtpValidate = true;
                this.hidetimer = false;
                return;
            }
        } if (nm === "OTPAuthenticate") {
            if (!this.numberOfOTPAttempts) {
                this.numberOfOTPAttempts = 0;
            }
            if (this.otpVal.length === 6) {
                this.showSpinner = true;
                this.hideOtpValidate = true;
                console.log('OTPAuthenticate');
                let serviceName = "SFDC Aadhar OTP Verification";
                ingMsgFields[SCHEMA.SVC.fieldApiName] = serviceName;
                ingMsgFields[SCHEMA.NAME.fieldApiName] = serviceName;
                appKycFields[SCHEMA.OTP.fieldApiName] = this.otpVal;
                this.showValidateBtn = false;
                this.disableAadharNo = true;
                this.callSubscribePlatformEve();
                console.log('OTPAuthenticate 2');
            } else {
                this.showToast("Error", "error", LABELS.PanKycCheck_IncorrectOtp_ErrorMessage);
                if (this.numberOfOTPAttempts > 3) { } //sk
                this.showSpinner = false;
                return;
            }
        }
        if (nm === "UdyamValidate") {
            console.log('innnnbuttonclick' + this.appKycId)
            this.callSubscribePlatformEve();
            let serviceName = "Udyam Registration Check";
            ingMsgFields[SCHEMA.REF_OBJ.fieldApiName] = "ApplKyc__c";
            ingMsgFields[SCHEMA.REF_ID.fieldApiName] = this.appKycId;
            ingMsgFields[SCHEMA.PARENT_REF_OBJ.fieldApiName] = 'Applicant__c';
            ingMsgFields[SCHEMA.PARENT_REF_ID.fieldApiName] = this.applicantId;
            ingMsgFields[SCHEMA.SVC.fieldApiName] = '';
            ingMsgFields[SCHEMA.NAME.fieldApiName] = serviceName;
        }
        if (!this.appKycId) {
            this.showToast("Error", "error", LABELS.PanKycCheck_kycId_ErrorMessage);
            return;
        }
        appKycFields[SCHEMA.APP_KYC_ID.fieldApiName] = this.appKycId;
        console.log('before saveing  handleValidateClick ', ingMsgFields, appKycFields);
        this.updateAppKyc(appKycFields, ingMsgFields);
    }

    handleValidateClick(event) {
        let nm = event.target.name;
        let isInputCorrect = this.reportValidity();
        if (isInputCorrect === true) {
            let docId = ''
            switch (nm) {
                case "dlValidate":
                    docId = this.appKycFieldVal.DLNo__c;
                    break;
                case "voterIdValidate":
                    docId = this.appKycFieldVal.VotIdEpicNo__c;
                    break;
                case "passportValidate":
                    docId = this.appKycFieldVal.PassNo__c;
                    break;
                case "panValidate":
                    docId = this.appKycFieldVal.Pan__c;
                    break;
                case "aadharValidate":
                    docId = this.appKycFieldVal.AadharNo__c;
                    break;
                case "UdyamValidate":
                    docId = this.appKycFieldVal.UdyamRegistrationNumber__c;
                    break;
                default:
                    break;
            }
            checkDuplicateDoc({ loanId: this.loanAppId, appKycId: null, docId: docId, docType: nm, applId: this.applicantId })
                .then((result) => {
                    console.log('Check Duplicate method result:::1073', result);
                    if (result === true) {
                        this.showToast("error", "error", 'Duplicate Document Exists. Kindly Upload another Document');
                        this.stopSpinner();
                    } else {
                        this.validateDocs(nm);
                    }
                })
                .catch((err) => {
                    console.log('Error in checkDuplicatDoc::::1083  ', JSON.stringify(err));
                })
                .finally(() => {
                });
        }
        else {
            this.showSpinner = false;
            this.showToast("Error", "error", LABELS.PanKycCheck_ValidInput_ErrorMessage);
        }
    }
    updateAppKyc(fields, ingMsgFields) {
        const recordInput = {
            fields: fields
        };
        updateRecord(recordInput).then((record) => {
            this.createIntMsg(ingMsgFields);
        })
            .catch((err) => {
                this.showSpinner = false;
                console.log(" Error Updating  Applicant KYC ", err.body.message);
                this.showToast("Error ", "error", err.body.message);
            })
    }
    createIntMsg(ingMsgFields) {
        const recordInput = {
            apiName: SCHEMA.INTG_MSG.objectApiName,
            fields: ingMsgFields
        };
        createRecord(recordInput)
            .then((record) => {
                console.log('iiiiiiiiiiiiiiiii')
            })
            .catch((err) => {
                this.showSpinner = false;
                console.log(" Error in creating Integration msz ", JSON.stringify(err), err.body.message);
                this.showToast("Error ", "error", err.body.message);
            })
    }
    showManualInput(val) {
        if (val === "Passport") {
            this.showPassportInput = true;
            this.showValidateBtn = true;
            this.showVoterInput = false;
            this.showDlInput = false;
            this.showUdhyamBox = false;
        }
        else if (val === "Voter ID") {
            this.showVoterInput = true;
            this.showValidateBtn = true;
            this.showPassportInput = false;
            this.showDlInput = false;
            this.showUdhyamBox = false;
        }
        else if (val === "Driving license") {
            this.showDlInput = true;
            this.showValidateBtn = true;
            this.showPassportInput = false;
            this.showVoterInput = false;
            this.showUdhyamBox = false;
        }
        else if (val === "Aadhar") {
            this.showAadharInput = true;
            this.showValidateBtn = true;
            this.showPassportInput = false;
            this.showVoterInput = false;
            this.showUdhyamBox = false;
        } else if (val === "Udyam Registration Certificate") {
            this.showAadharInput = false;
            this.showValidateBtn = true;
            this.showPassportInput = false;
            this.showVoterInput = false;
            this.showUdhyamBox = true;
        }
        else {
            this.showDlInput = false;
            this.showPassportInput = false;
            this.showVoterInput = false;
            this.showValidateBtn = false;
            this.showUdhyamBox = false;
        }
    }
    handleAddDocClick(event) {
        this.showSpinner = true;
        this.showAddDoc = false;
        let name = event.target.name;
        //to check the status of doc if validated add doc otherwise show errormszif('0)
        let conditionForIntMsg = ['Passport', 'Voter ID', 'Driving license', 'PAN', 'Aadhaar'];
        let inList = conditionForIntMsg.find((doc) => doc === this.docName);
        if (inList) {
            fetchId({ applicantId: this.applicantId, category: this.documentCategory, docType: null, subType: this.docName })
                .then((result) => {
                    //commented for LAK-2970 
                    // let res = result.find((doc) => doc.docDetName === this.docName);
                    // if (res && res.validationStatus === "Success") {
                    //commented for LAK-2970
                    if (name === 'AddDocForPAN') {
                        let forPan = this.uploadedDocuments.find((doc) => (doc.docDetName == "PAN"));
                        if (forPan) {
                            let referedDocLink = forPan.LinkedEntityId;
                            this.addAppKycAndDD(this.applicantId, this.loanAppId, "PAN Documents", "PAN", "PAN", referedDocLink);
                        }
                    } else if (name === 'AddDocForOther') {
                        if (this.docType === 'DOB Proof') {
                            this.checkDobForDocTypeDob(this.uploadedDocuments.find((doc) => doc.docDetName == this.docName).appKycId);// LAK-5035
                        } else if (this.docType === 'Sign Proof' && this.docName === 'PAN') {
                            let forPan = this.uploadedDocuments.find((doc) => (doc.docDetName == "PAN"));
                            if (forPan && forPan.cDId) {
                                this.addAppKycAndDD(this.applicantId, this.loanAppId, "KYC Documents", this.docType, this.docName, this.referedDocLink);
                            } else {
                                this.showToast("Error", "error", LABELS.Please_Upload_Pan_For_Sign_Proof_ErrorMessage);
                                this.showSpinner = false;
                                this.showAddDoc = true;
                            }
                        } else {
                            this.addAppKycAndDD(this.applicantId, this.loanAppId, "KYC Documents", this.docType, this.docName, this.referedDocLink);
                        }
                    } else {
                        console.log('AddDocPan  name else', name);
                        this.showSpinner = false;
                        this.showAddDoc = true;
                    }
                    //commented for LAK-2970
                    // } else {
                    //     this.showToast("Error", "error", "Document is not Validated, Please Validate Document First");
                    //     this.showSpinner = false;
                    //     this.showAddDoc = true;
                    // }
                    //commented for LAK-2970
                })
                .catch((error) => {
                    this.showSpinner = false;
                    this.showAddDoc = true;
                    console.log("error occured in getOsvData", error);
                });
        } else {
            if (name === 'AddDocForPAN') {
                let forPan = this.uploadedDocuments.find((doc) => doc.docDetName == "PAN");
                if (forPan) {
                    let referedDocLink = forPan.LinkedEntityId;
                    this.addAppKycAndDD(this.applicantId, this.loanAppId, "PAN Documents", "PAN", "PAN", referedDocLink);
                }
            } else if (name === 'AddDocForOther') {
                this.addAppKycAndDD(this.applicantId, this.loanAppId, "KYC Documents", this.docType, this.docName, this.referedDocLink);
            } else {
                this.showSpinner = false;
                this.showAddDoc = true;
            }
        }
        // ends
    }
    checkDobForDocTypeDob(appKycId) {
        if (appKycId) {
            let params = {
                ParentObjectName: 'ApplKyc__c',
                parentObjFields: ["Id", "DtOfBirth__c", "ValidationStatus__c", "OCRStatus__c"],
                queryCriteria: ' where Id = \'' + appKycId + '\''
            };
            getSobjectDatawithRelatedRecords({ params: params })
                .then((res) => {
                    let result = res.parentRecord;
                    if (result && !result.DtOfBirth__c && (result.ValidationStatus__c === 'Success' || result.OCRStatus__c === 'Success')) {
                        this.showToast("Error", "error", LABELS.PanKycCheck_Dob_ErrorMessage);
                    } else {
                        this.addAppKycAndDD(this.applicantId, this.loanAppId, "KYC Documents", this.docType, this.docName, this.referedDocLink);
                    }
                    this.showSpinner = false;
                    this.showAddDoc = true;
                })
                .catch((err) => {
                    this.showToast("Error", "error", err.message);
                    console.log(" checkDobForDocTypeDob error===", err);
                    this.showSpinner = false;
                    this.showAddDoc = true;
                });
        }
    }
    addAppKycAndDD(applicantId, loanAppId, docCategory, docType, docName, referedDocLink) {
        addAppkycDd({ applicantId: applicantId, loanAppId: loanAppId, docCategory: docCategory, docType: docType, docSubType: docName, linkedEntityId: referedDocLink })
            .then((result) => {
                this.showSpinner = false;
                this.docName = '';
                this.docType = '';
                this.refreshDocTable("addAppKyc");
                if (result.docDetId && this.utilityBillDate && (this.utilityBillDocList.includes(this.docName))) {
                    const docDetail = {};
                    docDetail[SCHEMA.DocDet_ID.fieldApiName] = result.docDetId;
                    docDetail[SCHEMA.Utility_Bill_Date.fieldApiName] = this.utilityBillDate;
                    const recordInput = {
                        fields: docDetail
                    };
                    this.updateRecordMethod(recordInput, 'Utility Bill Date');
                }
            })
            .catch((err) => {
                this.showSpinner = false;
                this.showToast("Error", "error", err);
                console.log(" createDocumentDetailRecord error===", err);
            });
    }
    callDocAvailable(event) {
        if (event.detail) {
            this.uploadedDocuments = event.detail;
            let dataforPan = this.uploadedDocuments.find((doc) => doc.docDetName == "PAN" && doc.docDetType == "PAN");
            let ev = { target: { value: "PanUpload" } };
            if (this.availableProcessOptions.find((doc) => doc.checked == true)) {
                let val = this.availableProcessOptions.find((doc) => doc.checked == true).value;
                ev = { target: { value: val } }
            }
            if (dataforPan && (dataforPan.ocrStatus === "Failure" && dataforPan.validationStatus === "Failure")) {
                ev = { target: { value: "PanManual" } }
            } else if (dataforPan && ((!dataforPan.ocrStatus || dataforPan.ocrStatus === "Failure") && (dataforPan.validationStatus === "Success"))) {//forPan.ocrStatus === "Success" &&
                ev = { target: { value: "PanManual" } }// added for LAK-4740
            }
            else if (dataforPan && dataforPan.ocrStatus === "Failure") {
                ev = { target: { value: "PanManual" } }
            }
            else if (dataforPan && dataforPan.validationStatus === "Success") {
            } else {
                ev = { target: { value: "PanUpload" } }
            }
            this.handleSelectProcess(ev);
            this.showAddDoc = false;
            this.showUpload = false;
            this.stopchildSpinner();
            this.uploadedDocuments.forEach(element => {
                if (element.docDetName && (element.docDetName === "PAN" || element.docDetName === "Form 60")) {
                    if (element.docDetName === "PAN") {
                        this.panDocOptions
                    }
                    if (element.docDetName === "Form 60") {
                    }
                }
            });
        }
        if (event.usedIn) {// uf,osv,dd,cc,afc,
            if (event.usedIn === "dd" || event.usedIn === "ss") {
                this.docName = '';
                this.docType = '';

                this.docNameOption = [];
                console.log('uploadedDocuments 1', 'reset initiated');
            }
        } else {

        }
    }
    stopchildSpinner() {
        let child = this.template.querySelector('c-uploded-document-display');
        child.showSpinnerInChild(false);
    }
    fromUploadDocsContainer(event) {
        if (event) {
            let ev = event.detail;
            console.log('this.docType' + JSON.stringify(ev))
            if (ev.fileUploaded) {
                if (this.docType === 'Identity Proof') {//LAK-4829
                    const applicantRec = {};
                    applicantRec[SCHEMA.APPLICANT_ID.fieldApiName] = this.applicantId;
                    applicantRec[SCHEMA.APPLICANT_ID_PROOF_Type.fieldApiName] = this.docName;
                    const recordInput = {
                        fields: applicantRec
                    };
                    this.updateRecordMethod(recordInput, 'Update Applicant');
                }
                if (ev.appKycId && ev.docDetailId) {
                    if ((ev.docName === "Form 60" || this.utilityBillDocList.includes(ev.docName) || ev.docName === "Shop and Establishment")) {
                        console.log('ev.appKycId && ev.docDetailId not found ');
                        if (ev.docName === "Form 60") {
                            this.stopSpinner();
                            this.showPanForm60 = false;
                        }
                        if (ev.docName === 'Electricity Bill' && this.spValue != 'Others') {
                            let child = this.template.querySelector('c-pan-kyc-electricity-bill');
                            child.fromUploadDocsContainer(ev);
                            this.appKycId = ev.appKycId;
                            this.documentDetId = ev.docDetailId;
                            this.selectedDocName = ev.docName;
                            const appKyc = {};
                            appKyc[SCHEMA.APP_KYC_ID.fieldApiName] = ev.appKycId;
                            appKyc[SCHEMA.SVC_PROVIDER.fieldApiName] = this.spLabel;
                            appKyc[SCHEMA.SVC_PROVIDER_CODE.fieldApiName] = this.spValue;
                            appKyc[SCHEMA.CONSUMER_ID.fieldApiName] = this.consumerIdValue;
                            appKyc[SCHEMA.BILL_DIST.fieldApiName] = this.billDist;
                            const recordInput = {
                                fields: appKyc
                            };
                            //this.updateRecordMethodNew(recordInput, 'Electricity Bill Authentication', ev.appKycId, ev.docDetailId);
                            this.stopSpinner();
                        } else if (ev.docName === 'Electricity Bill' && this.spValue === 'Others') {
                            this.stopSpinner();
                        }
                        if (this.utilityBillDocList.includes(ev.docName)) {
                            this.stopSpinner();
                            const docDetail = {};
                            docDetail[SCHEMA.DocDet_ID.fieldApiName] = ev.docDetailId;
                            docDetail[SCHEMA.Utility_Bill_Date.fieldApiName] = this.utilityBillDate;
                            const recordInput = {
                                fields: docDetail
                            };
                            this.updateRecordMethod(recordInput, 'Utility Bill Date');
                        }
                        else if (ev.docName === "Shop and Establishment") {
                            if (this.shopAreaValue && this.shopAreaValue != 'Others') {
                                this.appKycId = ev.appKycId;
                                this.documentDetId = ev.docDetailId;
                                this.selectedDocName = ev.docName;
                                const appKyc = {};
                                appKyc[SCHEMA.APP_KYC_ID.fieldApiName] = ev.appKycId;
                                appKyc[SCHEMA.Date_Of_Expiry.fieldApiName] = this.establishmentDate;
                                appKyc[SCHEMA.AREA.fieldApiName] = this.shopAreaCode;
                                appKyc[SCHEMA.AREA_CODE.fieldApiName] = this.shopAreaValue;
                                appKyc[SCHEMA.REG_NUMBER.fieldApiName] = this.resgitrationValue;
                                const recordInput = {
                                    fields: appKyc
                                };
                                this.updateRecordMethodNew(recordInput, 'Shop_N_Establishment_Date_Api', ev.appKycId, ev.docDetailId);
                            } else {
                                this.showEstablishmentDate = false;
                                this.stopSpinner();
                            }
                            // const docDetail = {};
                            // docDetail[SCHEMA.DocDet_ID.fieldApiName] = ev.docDetailId;
                            // docDetail[SCHEMA.Shop_N_Establishment_Date.fieldApiName] = this.establishmentDate;
                            // const recordInput = {
                            //     fields: docDetail
                            // };
                            // this.updateRecordMethod(recordInput, 'Shop_N_Establishment_Date');

                        }
                    } else {
                        this.appKycId = ev.appKycId;
                        this.documentDetId = ev.docDetailId;
                        this.selectedDocName = ev.docName;
                        let conditionForIntMsg = ['Passport', 'Voter ID', 'Driving license', 'PAN', 'Aadhaar'];
                        let inList = conditionForIntMsg.find((doc) => doc === ev.docName);
                        if (inList) {
                            this.createIntegrationMsg(ev.appKycId, ev.docDetailId, "KYC OCR");
                        } else {
                            console.log('int msz not create dbz not under list ');
                            this.stopSpinner();
                        }
                        if (ev.docName === "Letter issued by the National Population Register") {
                            const appKyc = {};
                            appKyc[SCHEMA.APP_KYC_ID.fieldApiName] = ev.appKycId;
                            appKyc[SCHEMA.NPR_Number.fieldApiName] = this.nprDocNo;
                            const recordInput = {
                                fields: appKyc
                            };
                            this.updateRecordMethod(recordInput, 'NPR_Number');
                        }
                    }
                } else if (!ev.appKycId && ev.docDetailId) {
                    this.stopSpinner();
                }
                if (ev.docName == 'Udyam Registration Certificate') {
                    console.log('ev.docName' + ev.docName)
                    if (ev.appKycId && ev.docDetailId) {
                        console.log('ev.docName133333' + ev.docName)
                        if (this.employmentRecord.UdyamRegistrationNumber__c) {
                            console.log('ev.docName5467890' + ev.docName)
                            let fieldsOfIntMess = HELPER.integratinMsz(ev.appKycId, this.applicantId);
                            let ChildRecords = [];
                            let upsertData = {
                                parentRecord: fieldsOfIntMess,
                                ChildRecords: ChildRecords,
                                ParentFieldNameToUpdate: ''
                            }
                            console.log('record of message createddddd' + JSON.stringify(upsertData))
                            updateData({ upsertData: upsertData })
                                .then(result => {
                                    console.log('resultresultresultresultresult' + JSON.stringify(result))
                                    this.showToast("Success ", "success", 'Verifiying Udyam Registration Number.');
                                }).catch(error => {
                                    console.log(error);
                                })
                        } else {
                            console.log('udyam is not present')
                        }
                    }
                }
                console.log('if fileupload true last line ');
            } else {
                console.log('if fileupload false ');
                this.showToast("Error", "error", LABELS.PanKycCheck_FileUpload_ErrorMessage + ev.docName);
                this.stopSpinner();
            }
        }
    }
    updateRecordMethodNew(recordInput, msz, appKycId, docDtlId) {
        updateRecord(recordInput)
            .then((record) => {
                if (msz === 'Shop_N_Establishment_Date_Api') {
                    this.createIntegrationMsg(appKycId, docDtlId, "Shop And Establishment");
                }
                else if (msz === 'Electricity Bill Authentication') {
                    this.createIntegrationMsg(appKycId, docDtlId, "Electricity Bill Authentication");
                }
            })
            .catch((err) => {
                console.log(" Error In " + msz + " update", err.body.message);
            })
    }
    createDDforbusinessAddress() {
        this.createDocumentDetailRecord("PAN Documents", "PAN", "PAN");
    }
    createIntegrationMsg(appKycId, ddId, serviceName) {
        const fields = HELPER.createIntegrationMsg(appKycId, ddId, serviceName);
        console.log('fields in createIntegrationMsg', fields);
        //4. Prepare config object with object and field API names 
        const recordInput = {
            apiName: SCHEMA.INTG_MSG.objectApiName,
            fields: fields
        };
        //5. Invoke createRecord by passing the config object
        this.callSubscribePlatformEve();
        createRecord(recordInput).then((record) => {
            this.integratMsgId = record.id;
        });
    }
    callSubscribePlatformEve() {
        this.handleSubscribe();
        this.callSubscribePlatformEveForRet();

    }
    handleSubscribe() {
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        // Callback invoked whenever a new event message is received
        const self = this;
        this.cometdlib = new window.org.cometd.CometD();
        //Calling configure method of cometD class, to setup authentication which will be used in handshaking
        this.cometdlib.configure({
            url: window.location.protocol + '//' + window.location.hostname + '/cometd/50.0/',
            requestHeaders: { Authorization: 'OAuth ' + this.sessionId },
            appendMessageTypeToURL: false,
            logLevel: 'debug'
        });
        this.cometdlib.websocketEnabled = false;
        this.cometdlib.handshake(function (status) {
            let tot = 90000//self.timeout
            self.noIntResponec = true;
            self.startTimerForTimeout(tot);
            if (status.successful) {
                // Successfully connected to the server.
                // Now it is possible to subscribe or send messages
                console.log('Successfully connected to server');
                self.PEsubscription = self.cometdlib.subscribe(self.channelName, (message) => {
                    self.handlePlatformEventResponce(message.data.payload);
                },
                    (error) => {
                        console.log('Error In Subscribing ', error);
                    }
                );
                console.log(window.location.protocol + '//' + window.location.hostname + '/cometd/50.0/',);
            } else {
                /// Cannot handshake with the server, alert user.
                console.error('Error in handshaking: ' + JSON.stringify(status));
                self.stopSpinner();
            }
        });
        console.log('SUBSCRIPTION ENDED');
    }
    // In case you want to unsubscribe use this
    handleUnsubscribe() {
        if (this.PEsubscription) {
            //Unsubscribing Cometd
            this.noIntResponec = false;
            this.cometdlib.unsubscribe(this.PEsubscription, {}, (unsubResult) => {
                if (unsubResult.successful) {
                    console.log('unsubscription STARTED ');
                    //Disconnecting Cometd
                    this.cometdlib.disconnect((disResult) => {
                        if (disResult.successful) {
                            console.log('unsubscription SUCCESS');
                        }
                        else {
                            console.log('unsubscription ERROR ' + disResult);
                        }
                    });
                }
                else {
                    console.log('unsubscription FAILED ');
                }
            });
            this.PEsubscription = undefined;
        }
    }
    createIntMsgForVerification(appKyc, docDtl, docName, aadharMasking) {
        let serviceName = HELPER.retServideName(docName);
        this.createIntegrationMsg(appKyc, docDtl, serviceName);
    }
    checkDuplicateId() {
        return new Promise((resolve, reject) => {
            checkDuplicateDoc({ loanId: this.loanAppId, appKycId: this.appKycId, docId: null, docType: null, applId: null })
                .then((result) => {
                    resolve(result);
                })
                .catch((err) => {
                    reject(err);
                    console.log('Error in checkDuplicateDoc::::1601  ', JSON.stringify(err));
                })
                .finally(() => {
                    console.log('Error in checkDuplicateDoc::::1605  ');
                });
        });
    }
    async handlePlatformEventResponce(payload) {
        console.log('payload respo', payload);
        if (this.noIntResponec) {
            if (payload.RecId__c == this.appKycId && payload.Success__c) {
                // for success integration responce
                this.noIntResponec = false;
                if (payload.SvcName__c == "KYC OCR") {
                    let chkDup = await this.checkDuplicateId();
                    if (chkDup) {
                        this.showToast("error", "error", 'Duplicate Document Exists. Kindly Upload another Document');
                        this.stopSpinner();
                    } else {
                        this.showToast("success", "success", LABELS.PanKycCheck_OCR_SuccessMessage);
                        //Aadhar verification need to be implemented
                        //if (this.selectedDocName !== 'Aadhaar') {
                        if (this.docType === 'Identity Proof') {
                            let params = {
                                ParentObjectName: 'ApplKyc__c',
                                parentObjFields: ["Id", "kycDoc__c", "AadharNo__c", "KycDocNo__c", "NPRNumber__c"],
                                queryCriteria: ' where Id = \'' + this.appKycId + '\''
                            };
                            getSobjectDatawithRelatedRecords({ params: params })
                                .then((res) => {
                                    if (res && res.parentRecord.kycDoc__c) {
                                        const applicantRec = {};
                                        applicantRec[SCHEMA.APPLICANT_ID.fieldApiName] = this.applicantId;
                                        applicantRec[SCHEMA.APPLICANT_ID_PROOF_Type.fieldApiName] = this.docName;
                                        if (res.parentRecord.kycDoc__c === 'Aadhaar') {
                                            applicantRec[SCHEMA.APPLICANT_ID_PROOF_NO.fieldApiName] = res.parentRecord.AadharNo__c;
                                        } else if (res.parentRecord.kycDoc__c === 'Letter issued by the National Population Register') {
                                            applicantRec[SCHEMA.APPLICANT_ID_PROOF_NO.fieldApiName] = res.parentRecord.NPRNumber__c;
                                        } else {
                                            applicantRec[SCHEMA.APPLICANT_ID_PROOF_NO.fieldApiName] = res.parentRecord.KycDocNo__c;
                                        }
                                        const recordInput = {
                                            fields: applicantRec
                                        };
                                        this.updateRecordMethod(recordInput, 'Update Applicant');
                                    }
                                })
                                .catch(error => {
                                    console.log("get applicantKyc error  1849", error);
                                })
                        }
                        if (this.selectedDocName === "Passport") {
                            let params = {
                                ParentObjectName: 'ApplKyc__c',
                                parentObjFields: ["Id", "PassExpDt__c",],

                                queryCriteria: ' where Id = \'' + this.appKycId + '\''
                            };
                            getSobjectDatawithRelatedRecords({ params: params })
                                .then((res) => {
                                    if (res && res.parentRecord.PassExpDt__c) {
                                        // Convert the "PassExpDt__c" value to a Date object
                                        const expirationDate = new Date(res.parentRecord.PassExpDt__c);
                                        // Get the current date
                                        const currentDate = new Date();
                                        // Compare the two dates
                                        if (expirationDate > currentDate) {
                                            console.log("PassExpDt__c is a future date.");
                                            this.createIntMsgForVerification(this.appKycId, this.documentDetId, this.selectedDocName);
                                        } else if (expirationDate <= currentDate) {
                                            console.log("PassExpDt__c is a past date.");
                                            this.stopSpinner();
                                            this.showToast("Error", "error", LABELS.PanKycCheck_PassportExp_ErrorMessage);
                                        } else {
                                            console.log("PassExpDt__c is the current date.");
                                        }
                                    } else {
                                        this.stopSpinner();
                                        this.showToast("Error", "error", LABELS.PanKycCheck_ValidPassport_ErrorMessage);
                                    }
                                });
                        }
                        else if (this.selectedDocName === 'Aadhaar') {
                            this.createIntegrationMsg(this.appKycId, this.documentDetId, "SFDC Aadhar Masking");/// LAK-5783	
                        }
                        else {
                            this.createIntMsgForVerification(this.appKycId, this.documentDetId, this.selectedDocName);
                        }
                    }
                } else if (payload.SvcName__c == "SFDC Aadhar XML Verification API") {//to send the otp 
                    this.showToast("OTP Sent", "success", LABELS.PanKycCheck_OtpSent_SuccessMessage);
                    this.hideOtpValidate = false;//sk

                    this.showSpinner = false;
                    this.showManualValidation = true;
                    this.showAadharInput = true;
                    this.showUpload = false;
                    this.refreshDocTable("presp");
                    this.handleUnsubscribe();

                    // ne added for aadhar otp 21/10
                    //   if (clickedToCheck.docDetName === "Aadhar") {
                    console.log("clickedToCheck.docDetName Aadhar ");

                    let params = {
                        ParentObjectName: 'ApplKyc__c',
                        parentObjFields: ["Id", "AdhrVer__c", "OTP_Count__c", "ValidationStatus__c", "OTP__c", "AadharNo__c", "AadharEncripted__c"],

                        queryCriteria: ' where Id = \'' + this.appKycId + '\''
                    };
                    getSobjectDatawithRelatedRecords({ params: params })
                        .then((res) => {
                            console.log("get applicantKyc Records ", res);
                            this.showAadharInput = false
                            this.aadharNo = res.parentRecord.AadharEncripted__c;
                            this.appKycFieldVal.AadharNo__c = res.parentRecord.AadharNo__c;
                            this.appKycFieldVal.AadharEncripted__c = res.parentRecord.AadharEncripted__c;
                            this.numberOfOTPAttempts = (res.parentRecord.OTP_Count__c) ? res.parentRecord.OTP_Count__c : 0;
                            console.log("get applicantKyc masked ", this.aadharNo, this.appKycFieldVal.AadharNo__c);
                            this.showModelPopup = true;
                            this.startTimer();
                            this.showTimer = true;
                        })
                        .catch(error => {
                            console.log("get applicantKyc error ", error);
                        })
                    //end
                } else if (payload.SvcName__c == "SFDC Aadhar OTP Verification") {
                    this.showToast("success", "success", LABELS.PanKycCheck_OtpValidated_SuccessMessage);
                    console.log('SFDC Aadhar OTP Verification');
                    let params = {
                        ParentObjectName: 'ApplKyc__c',
                        parentObjFields: ["Id", "AdhrVer__c", "OTP_Count__c", "OCRStatus__c", "ValidationStatus__c", "OTP__c", "AadharNo__c", "AadharEncripted__c"],
                        queryCriteria: ' where Id = \'' + this.appKycId + '\''
                    };
                    getSobjectDatawithRelatedRecords({ params: params })
                        .then((res) => {
                            if (res.parentRecord.OCRStatus__c && res.parentRecord.OCRStatus__c === 'Success') {
                                this.handleUnsubscribe();

                            } else {
                                this.stopSpinner();// removed and added fromotpverification
                                this.refreshDocTable();
                                this.timeout = 0; // 6/2/24
                                this.handleUnsubscribe();
                            }
                        })
                        .catch(error => {
                            console.log("get applicantKyc error ", error);
                        })
                    this.showModelPopup = false;
                    this.hideOtpValidate = false;
                    // removed stop spinner
                    this.otpVal = '';
                    // this.resetValues();
                    this.stopSpinner();// removed and added fromotpverification
                    this.refreshDocTable();
                    this.timeout = 0;
                    this.handleUnsubscribe();
                    this.numberOfOTPAttempts = this.numberOfOTPAttempts + 1;
                    const appKycFields = {};
                    appKycFields[SCHEMA.APP_KYC_ID.fieldApiName] = this.appKycId;
                    appKycFields[SCHEMA.OTP_COUNT.fieldApiName] = this.numberOfOTPAttempts;
                    const recordInput = {
                        fields: appKycFields
                    };
                    this.updateRecordMethod(recordInput, 'OTP count'); //  to update applicant Kyc 
                } else if (payload.SvcName__c == "DL Authentication") {
                    this.showToast("success", "success", LABELS.PanKycCheck_DrivingLicnese_SuccessMessage);
                    this.stopSpinner();
                    this.resetValues();
                }
                else if (payload.SvcName__c == "SFDC Aadhar Masking") {
                    this.showToast("success", "success", LABELS.PanKycCheck_AadharMask_SuccessMessage);
                    let params = {
                        ParentObjectName: 'ApplKyc__c',
                        parentObjFields: ["Id", "AdhrVer__c", "AadharNo__c", "AadharEncripted__c"],
                        queryCriteria: ' where Id = \'' + this.appKycId + '\''
                    };
                    getSobjectDatawithRelatedRecords({ params: params })
                        .then((res) => {
                            let aadharPresent = false;
                            if (res.parentRecord) {
                                if (res.parentRecord.AadharNo__c) {
                                    aadharPresent = true;
                                }
                            }
                            if (aadharPresent) {
                                this.createIntMsgForVerification(this.appKycId, this.documentDetId, this.selectedDocName);
                            } else {
                                this.showToast("Error", "Error", 'Aadhaar details not retrieved from OCR');  //
                                this.stopSpinner();
                                this.timeout = 0;
                                this.refreshDocTable()
                                this.handleUnsubscribe();
                            }
                        })
                        .catch(error => {
                            console.log("get applicantKyc error ", error);
                        })
                } else if (payload.SvcName__c == "Shop And Establishment") {
                    // this.shopAreaValue = '';
                    // this.shopAreaCode = '';
                    this.showEstablishmentDate = false;
                    // this.resgitrationValue = '';
                    // this.establishmentDate = '';
                    this.showToast("success", "success", 'Api is Successful!');
                    this.stopSpinner();
                    this.resetValues();
                    this.handleUnsubscribe();
                }
                else if (payload.SvcName__c == "Electricity Bill Authentication") {
                    this.showElectricityBill = false;
                    this.showToast("success", "success", 'Electricity Bill Authentication Api is Successful!');
                    this.stopSpinner();
                    this.resetValues();
                    this.handleUnsubscribe();
                }
                else {
                    this.showToast("success", "success", LABELS.PanKycCheck_Validation_SuccessMessage);
                    this.stopSpinner();
                    this.resetValues();
                }
            } else if (payload.RecId__c == this.appKycId && !payload.Success__c) {
                this.noIntResponec = false;
                // for Failure integration responce
                if (payload.SvcName__c == "KYC OCR") {
                    if (payload.Error_Message__c == null) {
                        this.showToast("Error", "Error", LABELS.PanKycCheck_Response_ErrorMessage);
                    } else {
                        console.log(" KYC OCR", payload.Error_Message__c);
                        this.showToast("Error", "Error", LABELS.PanKycCheck_OcrFail_ErrorMessage + payload.Error_Message__c);
                    }
                    if (this.selectedDocName === 'Aadhaar') {
                        this.createIntegrationMsg(this.appKycId, this.documentDetId, "SFDC Aadhar Masking");
                    }/// LAK-5783	
                    else {
                        this.stopSpinner();
                    }
                }
                else if (payload.SvcName__c == "SFDC Aadhar XML Verification API") {
                    if (payload.Error_Message__c == null) {
                        this.showToast("Error", "Error", LABELS.PanKycCheck_SendingOtp_ErrorMessage);
                    } else {
                        console.log("  SFDC Aadhar XML Verification API", payload.Error_Message__c);
                        this.showToast("Error", "Error", LABELS.PanKycCheck_SendingOtp_ErrorMessage + payload.Error_Message__c);
                    }
                    this.stopSpinner();
                }
                else if (payload.SvcName__c == "SFDC Aadhar OTP Verification") {

                    this.stopSpinner();
                    console.log("Aadhar OTP Verification Error", payload.Error_Message__c);
                    if (payload.Error_Message__c == null) {

                        this.showToast("Error", "Error", LABELS.PanKycCheck_OtpVerf_ErrorMessage);
                    } else {
                        console.log("  SFDC Aadhar OTP Verification", payload.Error_Message__c);
                        this.showToast("Error", "Error", LABELS.PanKycCheck_OtpVerf_ErrorMessage + payload.Error_Message__c);
                    }
                    this.hideOtpValidate = false;///sk
                    this.otpVal = '';
                    // to update 
                    if (this.numberOfOTPAttempts < 3) {
                        this.numberOfOTPAttempts = this.numberOfOTPAttempts + 1;
                        const appKycFields = {};
                        appKycFields[SCHEMA.APP_KYC_ID.fieldApiName] = this.appKycId;
                        appKycFields[SCHEMA.OTP_COUNT.fieldApiName] = this.numberOfOTPAttempts;
                        const recordInput = {
                            fields: appKycFields
                        };
                        this.updateRecordMethod(recordInput, 'OTP count');
                        if (this.numberOfOTPAttempts == 3) {
                            this.hideOtpValidate = true;
                        } else {
                            this.hideOtpValidate = false;
                        }
                        //this.hideOtpValidate = false;
                    } else {
                        console.log('max otp attemp reach ', this.numberOfOTPAttempts);
                        this.hideOtpValidate = true;
                        this.timeLeft = 0;
                    }
                }
                else if (payload.SvcName__c == "Pan Validation") {
                    if (payload.Error_Message__c == null) {
                        this.showToast("Error", "Error", LABELS.PanKycCheck_PanValidate_ErrorMessage);
                    } else {
                        console.log("  Pan Validation", payload.Error_Message__c);
                        this.showToast("Error", "Error", payload.Error_Message__c);
                    }
                    console.log("Pan Validation Error", this.showSpinner);
                    if (this.showSpinner) {
                        this.showSpinner = false
                    } this.stopSpinner();

                } else if (payload.SvcName__c == "DL Authentication") {
                    if (payload.Error_Message__c == null) {
                        console.log("No response msg ", payload.Error_Message__c);
                        this.showToast("Error", "error", this.docName + "  ");
                    } else {
                        console.log("  DL Authentication", payload.Error_Message__c);
                        this.showToast("Error", "error", this.docName + "  " + payload.Error_Message__c);
                    }
                    if (this.showSpinner) {
                        this.showSpinner = false;
                    } this.stopSpinner();
                }
                else if (payload.SvcName__c == "Passport Verification") {

                    if (payload.Error_Message__c == null) {
                        console.log("No response msg ", payload.Error_Message__c);
                        this.showToast("Error", "error", this.docName + "  ");
                    } else {
                        console.log("  Passport Verification", payload.Error_Message__c);
                        this.showToast("Error", "error", this.docName + "  " + payload.Error_Message__c);
                    }
                    this.stopSpinner();
                }
                else if (payload.SvcName__c == "SFDC Aadhar Masking") {
                    if (payload.Error_Message__c == null) {
                        this.showToast("Error", "Error", LABELS.PanKycCheck_AadharMask_ErrorMessage);
                    } else {
                        console.log("  SFDC Aadhar Masking", payload.Error_Message__c);
                        this.showToast("Error", "Error", LABELS.PanKycCheck_AadharMask_ErrorMessage + payload.Error_Message__c);
                    }
                    let params = {
                        ParentObjectName: 'ApplKyc__c',
                        parentObjFields: ["Id", "kycDoc__c", "AadharNo__c", "KycDocNo__c"],
                        queryCriteria: ' where Id = \'' + this.appKycId + '\''
                    };
                    getSobjectDatawithRelatedRecords({ params: params })
                        .then((res) => {
                            let aadharNumberPresent = false;
                            if (res && res.parentRecord.kycDoc__c) {
                                const applicantRec = {};
                                applicantRec[SCHEMA.APPLICANT_ID.fieldApiName] = this.applicantId;
                                applicantRec[SCHEMA.APPLICANT_ID_PROOF_Type.fieldApiName] = this.docName;
                                if (res.parentRecord.kycDoc__c === 'Aadhaar') {
                                    applicantRec[SCHEMA.APPLICANT_ID_PROOF_NO.fieldApiName] = res.parentRecord.AadharNo__c;
                                }
                                if (res.parentRecord.AadharNo__c) {
                                    aadharNumberPresent = true;
                                    const recordInput = {
                                        fields: applicantRec
                                    };
                                    this.updateRecordMethod(recordInput, 'Update Applicant');
                                }
                            }
                            if (aadharNumberPresent) {
                                this.createIntMsgForVerification(this.appKycId, this.documentDetId, this.selectedDocName);
                                this.showModelPopup = true;
                                this.startTimer();
                                this.showTimer = true;
                            } else {
                                this.showToast("Error", "Error", 'Aadhaar number not retrieved from OCR');  //                            
                                this.timeout = 0;
                                this.refreshDocTable()
                                this.handleUnsubscribe();
                            }
                            this.stopSpinner();
                        })
                        .catch(error => {
                            console.log("get applicantKyc error  1849", error);
                        })
                } else if (payload.SvcName__c == "Shop And Establishment") {
                    this.showEstablishmentDate = false;

                    this.showToast("Error", "Error", 'Api is failure');
                    this.stopSpinner();
                    this.resetValues();
                    this.handleUnsubscribe();
                } else if (payload.SvcName__c == "Electricity Bill Authentication") {
                    this.showElectricityBill = true;
                    this.showToast("Error", "Error", 'Electricity Bill Authentication Api is failure');
                    this.stopSpinner();
                    this.resetValues();
                    this.handleUnsubscribe();
                }
                else {
                    console.log("OUSIDE CONDITION ERROR ", payload.Error_Message__c);
                    if (payload.Error_Message__c == null) {
                        console.log("No response msg ", payload.Error_Message__c);
                        this.showToast("Error", "error", this.docName + "  ");
                    } else {
                        console.log("  Passport Verification", payload.Error_Message__c);
                        this.showToast("Error", "error", this.docName + "  " + payload.Error_Message__c);
                    }
                    this.stopSpinner();
                }
            }
            this.manualValidationStarted = false;
        }
    }
    updateRecordMethod(recordInput, msz) {
        updateRecord(recordInput)
            .then((record) => {
                if (msz === 'Utility Bill Date') {
                    this.showUtilityBillDate = false;
                    this.utilityBillDate = null;
                    this.stopSpinner();
                } else if (msz === 'Shop_N_Establishment_Date') {
                    this.showEstablishmentDate = false;
                    this.establishmentDate = null;
                    this.stopSpinner();
                } else if (msz === 'NPR_Number') {
                    this.showNPRDocNo = false;
                    this.nprDocNo = null;
                    this.stopSpinner();
                }
            })
            .catch((err) => {
                console.log(" Error In " + msz + " update", err.body.message);
            })
    }
    resetValues() {
        this.showManualValidation = false;
        this.docName = '';
        this.docType = '';
        this.docNameOption = [];
    }
    refreshDocTable(usedFor) {
        let child = this.template.querySelector('c-uploded-document-display');
        child.handleFilesUploaded(usedFor);
    }
    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }
    @track retriggerClickedVal;
    handleForwardClicked(event) {
        this.appKycFieldVal = {};
        let clickedToCheck = event.detail.fileIterator.fileIterator;
        if (clickedToCheck) {
            this.docType = clickedToCheck.docDetType;
            this.docNameOption = [];
            console.log(' in this doc type ', clickedToCheck, this.docType, this.documentCatagoeyMap[this.docType]);
            this.appKycId = clickedToCheck.appKycId;
            this.documentDetId = clickedToCheck.docId;
            if (clickedToCheck.docDetName === "PAN") {
                let ev = { target: { value: "PanManual" } };
                this.handleSelectProcess(ev);
                this.showUdhyamBox = false;
            } else if (clickedToCheck.docDetName !== "PAN") {
                this.ispanManual = false;
                if (this.documentCatagoeyMap[this.docType]) {
                    this.documentCatagoeyMap[this.docType].forEach(item => {
                        if (item) {
                            let doc = { label: item, value: item };
                            this.docNameOption = [...this.docNameOption, doc];
                            this.docNameOption.sort(this.compareByLabel);
                        }
                    });
                    this.docName = clickedToCheck.docDetName;
                }
                this.showManualInput(clickedToCheck.docDetName);
                this.showManualValidation = true;
                this.showUpload = false;
                this.showAddDoc = false;
                if (clickedToCheck.docDetName === "Aadhaar") {
                    console.log("clickedToCheck.docDetName Aadhaar ");
                    this.showSpinner = true;
                    let params = {
                        ParentObjectName: 'ApplKyc__c',
                        parentObjFields: ["Id", "AdhrVer__c", "OTP_Count__c", "ValidationStatus__c", "OTP__c", "AadharNo__c", "AadharEncripted__c"],
                        queryCriteria: ' where Id = \'' + this.appKycId + '\''
                    };
                    getSobjectDataNonCacheable({ params: params })
                        .then((result) => {
                            if (result.parentRecords && result.parentRecords.length > 0) {
                                let res = result.parentRecords[0];
                                this.aadharNo = res.AadharNo__c;
                                if (res.OTP_Count__c) {
                                    this.numberOfOTPAttempts = res.OTP_Count__c;
                                } else {
                                    this.numberOfOTPAttempts = 0;
                                }
                                this.showAadharInput = false
                                this.showSpinner = false;
                                this.showValidateBtn = true;
                                this.disableAadharNo = false;
                                this.appKycFieldVal.AadharNo__c = this.aadharNo;
                                this.appKycFieldVal.AadharEncripted__c = res.AadharEncripted__c;
                                this.showAadharInput = true
                            }
                        })
                        .catch(error => {
                            console.log("get applicantKyc error ", error);
                        })
                } else if (clickedToCheck.docDetName === "Udyam Registration Certificate") {
                    this.showAadharInput = false
                    this.showSpinner = false;
                    this.showValidateBtn = true;
                    this.showUdhyamBox = true
                } else if (clickedToCheck.docDetName === "Electricity Bill") {
                    this.retriggerClickedVal = clickedToCheck;
                    this.utilityBillDate = clickedToCheck.cDUtilBillDate;
                    this.showUtilityBillDate = true;
                    this.showElectricityBill = true;
                    this.showUpload = true;
                }
                else {
                    this.showValidateBtn = true;
                    this.showUdhyamBox = false;
                }
            } else {
                this.showManualValidation = false;
                this.showValidateBtn = true;
            }
        }
    }
    maskNumber(number) {
        if (number) {
            const maskedDigits = 'X'.repeat(number.length - 4);
            const lastFourDigits = number.slice(-4);
            const maskedNo = maskedDigits + lastFourDigits;
            return maskedNo;
        } else {
            return number;
        }
    }
    handleOTPchange(event) {
        this.otpVal = event.target.value;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.showModelPopup = false;
        this.hideOtpValidate = false;//sk
        this.handleUnsubscribe();
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.showModelPopup = false;
        this.hideOtpValidate = false;//sk
    }
    startTimer() {
        this.timeLeft = 600;
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
                this.showTimer = false;
                this.otpTimerValue = '00' + ':' + '00';
                clearInterval(this.intervalId);
                this.hidetimer = true;
            }
        }, 1000);
    }
    sunscribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }
    handleSaveThroughLms(values) {
        if (this.hasEditAccess === false || this.disableMode === true) {
        } else {
            this.handleSave(values.validateBeforeSave);
        }
    }
    checkValidation() {
        let isValid = true
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed combobox');
            } else {
                isValid = false;
                console.log('element else--', element);
            }
        });
        return isValid;
    }
    allDocDetName;
    applKycIdForUdhaym;
    handleSave(event) {
        /*this.getOsvData(false);
        for(const record of this.uploadedDocuments){
            if(record.docDetName =='Udyam Registration Certificate'){
                this.applKycIdForUdhaym=record.appKycId
            }
        }*/
        if (event) {
            let valid = this.checkValidation();
            if (valid) {
                this.getOsvData();
            } else {
                this.showToast("Error ", "error", LABELS.OtherIncome_ReqFields_ErrorMessage);
                console.log('validation failed ');
            }
        } else {

            this.updateEmployment(false, true);
        }
    }
    getOsvData() {
        fetchId({ applicantId: this.applicantId, category: this.documentCategory, docType: null, subType: null })
            .then((result) => {
                console.log(" getOsvData  called result", result);
                this.uploadedDocuments = result;
                this.updateEmployment(true, false);
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log("error occured in getOsvData", error);
            });
    }
    //LAK-7421
    updateEmployment(checkDocValidation, showToast) {
        this.showSpinner = true;
        if (this.updateEmplON == false) {
            this.updateEmplON = true;
            let params = {
                ParentObjectName: 'ApplicantEmployment__c ',
                parentObjFields: ['Id'],
                queryCriteria: ' where LoanApplicant__c = \'' + this.applicantId + '\''
            }
            getSobjectData({ params: params })
                .then((result) => {
                    const obje = this.employmentRecord;
                    obje['sobjectType'] = "ApplicantEmployment__c";
                    obje['LoanApplicant__c'] = this.applicantId;

                    if (result.parentRecords) {
                        let res = result.parentRecords;
                        if (res[0] && res[0].Id) {
                            obje['Id'] = res[0].Id;
                        }
                    }
                    let newArray = [];
                    if (obje) {
                        newArray.push(obje);
                    }
                    if (newArray) {
                        upsertMultipleRecord({ params: newArray })
                            .then((result) => {
                                if (result) {
                                    this.employmentRecord.Id = result[0].Id;
                                }
                                if (checkDocValidation) {
                                    this.checkDocumentValidation();
                                } else {
                                    this.showSpinner = false;
                                }
                                this.getApplicantDetails();
                                this.updateEmplON = true;
                            })
                            .catch((error) => {
                                this.showSpinner = false;
                                console.log('Error In upserting  ApplicantEmployment Details is ', error);
                            });
                    }
                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log('Error In getting Applicant Employment Details is ', error);
                });
        }
    } //LAK-7421
    checkDocumentValidation() {
        let osvCheckedReq = this.uploadedDocuments.filter((doc) => doc.osvReq !== false);
        if (this.uploadedDocuments.length > 0) {
            let osvChecked = osvCheckedReq.filter((doc) => doc.osv !== true);

            if (osvChecked.length !== 0) {
                this.showToast("OSV uncheck Found  ", "error", LABELS.PanKycCheck_Osv_ErrorMessage);
                this.showSpinner = false;
            } else {
                let categoriesList = ["PAN Documents", "KYC Documents"];
                let dataforPan = this.uploadedDocuments.find((doc) => doc.docDetName == "PAN" && doc.docDetType == "PAN");
                //For LAk-3994
                let hasIdNoOnIdentityProof = this.uploadedDocuments.find((doc) => doc.docDetType == "Identity Proof" && doc.idNumberOnDoc && doc.idNumberOnDoc != null);
                if (!hasIdNoOnIdentityProof && this.applicantRecord.Constitution__c === 'INDIVIDUAL') {
                    this.showToast(" Error  ", "error", 'Please Upload Identity Proof With Id Number');

                }
                // new requirement
                if ((this.stage == "DDE" || this.stage == "UnderWriting") && this.applicantRecord.Constitution__c == 'INDIVIDUAL') {
                    let hasIdNumOnOvdDoc = this.uploadedDocuments.find((doc) => doc.docDetType == "Residence Address proof - OVD"); //&& doc.idNumberOnDoc && doc.idNumberOnDoc != null
                    if (hasIdNumOnOvdDoc && !hasIdNumOnOvdDoc.idNumberOnDoc && hasIdNumOnOvdDoc.idNumberOnDoc == null) {
                        this.showKycValidSuccess = false;
                        this.showToast(" Error  ", "error", LABELS.Documents_Id_Number_Is_Missing_For_OVD);
                    }
                }
                if (this.typeOfBorrower === 'Financial') {
                    //For LAk-3994
                    //LAN-4095 //added panInvalid condition 
                    if (dataforPan) {
                        if (dataforPan.panInvalid === false) {
                            this.evaluateAllRequiredRecords();
                        } else {
                            this.showToast("Error ", "error", LABELS.PanKycCheck_PanValidate_ErrorMessage);
                            this.showSpinner = false;
                        }
                    } else {
                        this.evaluateAllRequiredRecords();
                    }
                }
                //For LAk-3994
                else {
                    this.evaluateAllRequiredRecords();
                }
                //For LAk-3994
            }
        } else {
            this.showSpinner = false;
            this.showToast("Error ", "error", LABELS.PanKycCheck_UploadDoc_ErrorMessage);
        }
    }
    evaluateAllRequiredRecords() {
        let categoriesList = ["PAN Documents", "KYC Documents"];
        evaluateAllRequiredRecords({ applicantId: this.applicantId, loanAppId: this.loanAppId, productType: this.productType, stage: this.stage, subStage: this.subStage, categoriesList: categoriesList })
            .then((result) => {
                if (result) {
                    if (result.length !== 0) {
                        if (result) {
                            result.forEach(element => {
                                let res = element;
                                this.showToast(" Error  ", "error", LABELS.PanKycCheck_KycMissing_ErrorMessage + ' ' + res);
                            });
                        }
                    }
                }
                else {
                    if (this.showKycValidSuccess) {
                        this.showToast("Success ", "success", LABELS.PanKycCheck_KycValidate_SuccessMessage);
                    }
                    //Observation corner case == Please Upload Identity Proof With Id Number this error should be here 8/2/24 LAK-5549
                }

                this.showSpinner = false;
            })
            .catch((err) => {
                console.log(' Error in  checking vlidation of uploadeddocuments' + err.message);
                this.showToast("Error ", "error", err.message);
                this.showSpinner = false;
            })
            .finally(() => {
            });
    }
    stopSpinner() {
        console.log('stopSpinner called');
        this.showUpload = false;
        this.showUtilityBillDate = false;
        this.showSpinner = false;
        this.refreshDocTable("ss");
        this.handleUnsubscribe();
        let ev = { target: { value: "PanUpload" } };
        if (this.uploadedDocuments.find((doc) => doc.docDetName == "PAN")) {
            if (this.availableProcessOptions.find((doc) => doc.checked == true)) {
                let val = this.availableProcessOptions.find((doc) => doc.checked == true).value;
                ev = { target: { value: val } }
            }
        }
        this.handleSelectProcess(ev);
        console.log('stopSpinner called end');
    }
    getAppKycValidatedAfterTimeout() {
        if (this.appKycId) {
            let params = {
                ParentObjectName: 'ApplKyc__c',
                parentObjFields: ["Id", "OCRStatus__c", "ValidationStatus__c", "OCR_Error_Message__c", "Validation_Error_Message__c"],
                queryCriteria: ' where Id = \'' + this.appKycId + '\''
            };
            getSobjectDatawithRelatedRecords({ params: params })
                .then((res) => {
                    let result = res.parentRecord;
                    if (result) {
                        if (this.manualValidationStarted) {
                            if (result.ValidationStatus__c && result.ValidationStatus__c === "Success") {
                                this.showToast("Success", "Success", LABELS.PanKycCheck_Validation_SuccessMessage);

                            } else {
                                let resp = (result.Validation_Error_Message__c) ? result.Validation_Error_Message__c : '';
                                this.showToast("Error", "error", LABELS.PanKycCheck_Validation_ErrorMessage + resp);
                            }
                        } else {
                            if (result.OCRStatus__c && result.OCRStatus__c === "Success") {

                                this.showToast("Success", "Success", "OCR Success");
                                if (result.ValidationStatus__c && result.ValidationStatus__c === "Success") {
                                    this.showToast("Success", "Success", LABELS.PanKycCheck_Validation_SuccessMessage);

                                } else {
                                    let resp = (result.Validation_Error_Message__c) ? result.Validation_Error_Message__c : '';
                                    this.showToast("Error", "error", LABELS.PanKycCheck_Validation_ErrorMessage + resp);
                                }
                            } else {
                                let resp = (result.OCR_Error_Message__c) ? result.OCR_Error_Message__c : '';
                                console.log("  Failederror===");
                                this.showToast("Error", "error", LABELS.PanKycCheck_OcrFail_ErrorMessage + resp);
                            }
                        }
                        this.manualValidationStarted = false;
                    } else {
                    }
                })
                .catch((err) => {
                    this.showToast("Error", "error", err.message);
                    console.log(" getSobjectDatawithRelatedRecords error===", err.message);
                    this.manualValidationStarted = false;
                });
        }
    }
    spinnerStatus(event) {
        this.showSpinner = event.detail;
    }
    startTimerForTimeout(timeout) {
        setTimeout(() => { this.stopSpinnerForTimeOut(); }, timeout);
    }
    stopSpinnerForTimeOut() {
        if (this.noIntResponec) {
            this.noIntResponec = false;
            console.log('stopSpinnerForTimeOut called', this.timeout);
            this.showUpload = false;
            this.showSpinner = false;
            let ev = { target: { value: "PanUpload" } };
            if (this.uploadedDocuments.find((doc) => doc.docDetName == "PAN")) {
                if (this.availableProcessOptions.find((doc) => doc.checked == true)) {
                    let val = this.availableProcessOptions.find((doc) => doc.checked == true).value;
                    ev = { target: { value: val } }
                }
            }
            this.handleSelectProcess(ev);
            this.getAppKycValidatedAfterTimeout();
            this.refreshDocTable("ssTo");
            this.handleUnsubscribe();
            console.log('stopSpinnerForTimeOut called end');
        }
    }
    createDocumentDetailRecord(docCategory, doctype, docName) {
        createAppkycDd({ applicantId: this.applicantId, loanAppId: this.loanAppId, docCategory: docCategory, docType: doctype, docSubType: docName })
            .then((result) => {
                this.documentDetId = result.docDetId;
                this.appKycId = result.appKycId;
                this.createPANIntegrationMsg(result.appKycId, result.docDetId);
            })
            .catch((err) => {
                this.showToast("Error", "error", err);
                console.log(" createDocumentDetailRecord error===", err);
            });
    }
    createPANIntegrationMsg(appKycId, ddId) {
        const ingMsgFields = HELPER.createPANIngMsgFields(appKycId, ddId);
        const recordInput = {
            apiName: SCHEMA.INTG_MSG.objectApiName,
            fields: ingMsgFields
        };
        const appKycFields = {};
        appKycFields[SCHEMA.PAN.fieldApiName] = this.appKycFieldVal.Pan__c;
        appKycFields[SCHEMA.APP_KYC_ID.fieldApiName] = appKycId;
        this.updateAppKyc(appKycFields, ingMsgFields)
        this.callSubscribePlatformEve();
    }
    //Platform Event SubScription Part Implemented For Retrigger Changes
    callSubscribePlatformEveForRet() {
        //Commnet platform event subscription temproroly
        this.handleSubscribeRet();
    }
    PEsubscriptionRet;
    @track noIntResponecRet = true;
    cometdlibRet
    handleSubscribeRet() {
        const selfRet = this;
        this.cometdlibRet = new window.org.cometd.CometD();
        this.cometdlibRet.configure({
            url: window.location.protocol + '//' + window.location.hostname + '/cometd/50.0/',
            requestHeaders: { Authorization: 'OAuth ' + this.sessionId },
            appendMessageTypeToURL: false,
            logLevel: 'debug'
        });
        this.cometdlibRet.websocketEnabled = false;
        this.cometdlibRet.handshake(function (status) {
            selfRet.noIntResponecRet = true;
            if (status.successful) {
                console.log('Successfully connected to server Retrigger');
                selfRet.PEsubscriptionRet = selfRet.cometdlibRet.subscribe(selfRet.channelNameRet, (message) => {
                    selfRet.handlePlatformEventResponceRet(message.data.payload);
                },
                    (error) => {
                        console.log('Error In Subscribing FOR Retrigger ', error);
                    }
                );
            } else {
                console.error('Error in handshaking FOR Retrigger : ' + JSON.stringify(status));
            }
        });
    }
    handlePlatformEventResponceRet(payload) {
        if (payload) {
            if (payload.LoanAppId__c === this.loanAppId) {
                let arra = JSON.parse(payload.Mes__c);
                arra.forEach(item => {
                    this.showToast("Warning ", "warning", item);
                })
            }
            this.handleUnsubscribeRet();
        } else {
            this.handleUnsubscribeRet();
        }
    }
    handleUnsubscribeRet() {
        if (this.PEsubscriptionRet) {
            this.noIntResponecRet = false;
            this.cometdlibRet.unsubscribe(this.PEsubscriptionRet, {}, (unsubResult) => {
                if (unsubResult.successful) {
                    //Disconnecting Cometd
                    this.cometdlibRet.disconnect((disResult) => {
                        if (disResult.successful) {
                            console.log('unsubscription SUCCESS FOR Retrigger');
                        }
                        else {
                            this.showSpinner = false;
                        }
                    });
                }
                else {
                    this.showSpinner = false;
                }
            });
            this.showSpinner = false;
            this.PEsubscriptionRet = undefined;
        }
    }
    callPlateformEventFromChild() {
        console.log('called bu childmethod ');
        this.callSubscribePlatformEve();
    }
}