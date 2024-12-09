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
import CURRENTUSERID from '@salesforce/user/Id';
import { LABELS } from './labels';
import { SCHEMA } from './schema';
import * as HELPER from './methods';

export default class CapturePanAndKycCheck extends LightningElement {

    @api applicantIdOnTabset;
    @api applicantId;
    @api loanAppId;
    @api productType;
    @api stage = 'QDE';
    @api subStage = 'RM Data Entry';
    @api documentCategory = ["KYC Documents", "PAN Documents"];
    @api layoutSize;
    @api isPanKyc;
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
    @track showElectricityBill = false;
    @track retriggerClickedVal;
    @track updateChildEleBill;
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
    @track enableValidateBtn = false;
    @track showShopEstValidateBtn = false;

    @track teamHierParam = {
        ParentObjectName: 'TeamHierarchy__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'EmpRole__c', 'Employee__c'],
        childObjFields: [],
        queryCriteria: ' where Employee__c = \'' + CURRENTUSERID + '\' limit 1'
    }
    @track userRole;
    getTeamHier() {

        getSobjectData({ params: this.teamHierParam })
            .then((result) => {
                console.log('DATA IN getTeamHier >> ', result);
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.userRole = result.parentRecords[0].EmpRole__c

                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting TeamHierarchy__c Details is ', error);
            });
    }
    get isNotDSA() {
        if (this.userRole == 'DSA') {
            return false;
        } else {
            return true;
        }
    }



    get selfEmployedIndividual() {
        if ((this.applicantRecord && (this.applicantRecord.CustProfile__c && (this.applicantRecord.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL' || this.applicantRecord.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL')) && this.applicantRecord.Constitution__c && this.applicantRecord.Constitution__c === 'INDIVIDUAL')) {
            return true;
        } else {
            return false;
        }
    }
    get selfEmployed() {
        if ((this.applicantRecord && (this.applicantRecord.CustProfile__c && (this.applicantRecord.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL' || this.applicantRecord.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL')))) {
            return true;
        } else {
            return false;
        }
    }
    get selfEmployedNonIndividual() {
        if ((this.applicantRecord
            && (this.applicantRecord.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL' || this.applicantRecord.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL')
            && this.applicantRecord.Constitution__c !== 'INDIVIDUAL')
        ) { // && (this.employmentRecord.Proprietorship_firm_part_of_the_proposal__c && this.employmentRecord.Proprietorship_firm_part_of_the_proposal__c === 'No')
            return true;
        } else {
            return false;
        }
    }
    get ProprietorPartOfProposal() {
        if (
            this.employmentRecord
            && this.employmentRecord.Proprietorship_firm_part_of_the_proposal__c === 'NO') {
            return true;
        } else {
            return false;
        }
    }
    get isMsmeInBl() {
        if (this.employmentRecord
            && this.employmentRecord.IsMSME__c === 'YES' && this.isBL) {
            return true;
        } else {
            if (this.isBL) {
                return false;
            } else {
                return true;
            }

        }
    }
    get showUrcUacApplicablity() {
        if ((this.employmentRecord && (this.employmentRecord.Is_URC_UAC_available__c === 'YES'))) {
            return true;
        } else {
            return false;
        }
    }
    @track showUdhyamBox = false
    //to show URC number column
    get showURCnumberBlock() {
        if (this.employmentRecord && this.employmentRecord.Select_applicability_for_URC_UAC__c && this.employmentRecord.Select_applicability_for_URC_UAC__c === 'UDYAM REGISTRATION NUMBER (URC)') {
            this.showUdhyamBox = true;
        }
        if (((this.docName == 'Udyam Registration Certificate') && this.showAddDoc == false && !(this.uploadedDocuments && this.uploadedDocuments.find((doc) => doc.docDetType.toLowerCase() === this.docType.toLowerCase() && doc.docDetName.toLowerCase() === this.docName.toLowerCase())
        ))) { // LAK-10232 LAK-9172//this.employmentRecord.Is_URC_UAC_available__c === 'YES' && this.employmentRecord.Select_applicability_for_URC_UAC__c === 'UDYAM REGISTRATION NUMBER (URC)' &&  //&& this.showUdhyamBox
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
            console.log('this.optonUrcUacApplicablity', JSON.stringify(this.optonUrcUacApplicablity))
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
    async connectedCallback() {
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
            this.getApplicantDetails();
        } else {

            this.showToast("Error ", "error", This.label.PanKycCheck_AddRecord_ErrorMessage);
        }
        //FOR LAK-3994

        //FOR LAK-3994
        this.fetchGstDetails();
        this.getTeamHier();
        // const data = await fetchData();

    }
    get isBL() {
        return this.productType == 'Business Loan';
    }
    @track availableGstOption = [];
    @track hasAvailableGSTList = false;
    @track availableGSTrec = [];
    async fetchGstDetails() {
        try {
            let gstDetails = await HELPER.getGstDetails(this.applicantId);
            if (gstDetails) {
                this.availableGstOption = gstDetails.gstOpt;
                this.availableGSTrec = gstDetails.gstRecords;
            }


            if (this.availableGstOption && this.availableGstOption.length > 0) {
                this.hasAvailableGSTList = true;
            } else {
                this.hasAvailableGSTList = false;
            }
            console.log('gstDetails in parent component:', this.availableGstOption, this.hasAvailableGSTList);
            // Handle gstDetails here (e.g., update state or pass to other methods)
        } catch (error) {
            console.error('Error fetching GST details:', error);
            // Handle error (e.g., show an error message to the user)
        }
    }

    // Example of calling fetchGstDetails, assuming you are in an async context or using .then()


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
                this.getRequiredDocs();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Applicant Details is ', error);
            });
    }
    getRequiredDocs() {
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
                this.docTypeOption = [];
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
    }
    @track gstSelected;
    @track gstSelectedId;
    @track selectedGstRec;
    @track showValidateGSTBtn = false;
    handleInputChangeGstNo(event) {
        let val = event.detail.value;
        console.log('Gst On change ==', this.gstSelected, this.selectedGstRec);

        if (this.hasAvailableGSTList) {
            if (val) {
                this.availableGSTrec.forEach(ele => {
                    if (ele.Id == val) {
                        this.gstSelectedId = val;
                        this.gstSelected = ele.GSTIN__c;
                        if (!this.showValidateBtn) {
                            this.showUpload = true;
                        }


                    }
                });
                this.selectedGstRec = this.availableGSTrec.find((rec) => rec.Id == val)

            }
        } else {
            const gstPattern = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/;
            // Validate the input value
            if (gstPattern.test(val)) {
                // Input is valid
                console.log('GSTIN is valid');

                if (!this.showValidateBtn) {
                    this.showUpload = true;
                }
            } else {
                // Input is invalid
                console.log('GSTIN is NOT valid');
            }
            this.gstSelected = val;
        }
        console.log('Gst On change ==', this.gstSelected, this.selectedGstRec);
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
        if (name === 'UdyamRegistrationNumber__c') {
            console.log('urc no check Initiated');
            const pattern = /^UDYAM-[A-Z]{2}-\d{2}-\d{7}$/;

            if (!pattern.test(val)) {
                if (!this.showValidateBtn) {
                    this.showUpload = false;
                }
                console.error('urc no check Invalid Udyam Registration Number');
            } else {
                if (!this.showValidateBtn) {
                    this.showUpload = true;
                }
                console.log('urc no check Valid Udyam Registration Number');
            }
        }

        console.log('this.employmentRecord' + JSON.stringify(this.employmentRecord));
        this.updateEmplON = false; //LAK-7421
    }
    @track oldValOfUdyamReginNum;
    getEmploymentDetail(event) {
        let appRecVal = event;
        let params = {
            ParentObjectName: 'ApplicantEmployment__c ',
            parentObjFields: ['Id', 'UdyamRegistrationNumber__c', 'Is_URC_UAC_available__c', 'Select_applicability_for_URC_UAC__c', 'Proprietorship_firm_part_of_the_proposal__c', 'DesignationValues__c', 'IsMSME__c'],
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
                    //this.showToast("warning", "warning", LABELS.PanKycCheck_uploaded_ErrorMessage);
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
                this.appKycId = forPan.appKycId ? forPan.appKycId : null;

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
    resetVariable() {
        this.shopAreaValue = '';
        this.resgitrationValue = '';
        this.establishmentDate = '';
        this.gstSelected = null;
        this.gstSelectedId = null;
        this.selectedGstRec = null;

    }
    handleChange(event) {
        let name = event.target.name;
        let val = event.target.value;
        this.resetVariable();
        this.showUtilityBillDate = false;
        this.showEstablishmentDate = false;
        this.showNPRDocNo = false;
        this.showGstNo = false;
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
                if (this.docType.toLowerCase() !== strVal1.toLowerCase()) {//&& this.docType.toLowerCase() !== strVal2.toLowerCase()  for LAK-8923
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
            let strVal5 = "Udyam Assist Certificate"
            let strVal6 = "Udyam Registration Certificate"
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
                        this.showUpload = false;
                    } else {
                        this.showElectricityBill = false
                        this.showUtilityBillDate = true;
                        this.showUpload = false;
                    }
                    // this.showUtilityBillDate = true;
                    // this.showUpload = false;
                }
                else if ((this.docName.toLowerCase() === strVal5.toLowerCase() || this.docName.toLowerCase() === strVal6.toLowerCase())) {//LAK-9172
                    if (this.docName.toLowerCase() === strVal5.toLowerCase() && this.uploadedDocuments.find((doc) => doc.docDetName.toLowerCase() === strVal6.toLowerCase())) {
                        this.showUpload = false;
                        this.showURCNoInput = false;
                        this.showToast("Error", "error", strVal6 + ' is already uploaded please delete to Upload ');
                    } else if (this.docName.toLowerCase() === strVal6.toLowerCase() && this.uploadedDocuments.find((doc) => doc.docDetName.toLowerCase() === strVal5.toLowerCase())) {
                        this.showUpload = false;
                        this.showURCNoInput = false;
                        this.showToast("Error", "error", strVal5 + ' is already uploaded please delete to Upload ');
                    }
                }
                else {
                    this.showUpload = true;
                    this.isPanKyc = true;
                    this.handleButtonState();
                }
            } else if (this.docType.toLowerCase() === strVal3.toLowerCase() || this.docType.toLowerCase() === strVal4.toLowerCase()) {
                if (this.utilityBillDocList.includes(this.docName)) {
                    if (this.docName === 'Electricity Bill') {
                        this.showUtilityBillDate = true;
                        this.showElectricityBill = true;
                        this.showUpload = false;

                    } else {
                        this.showElectricityBill = false
                        this.showUtilityBillDate = true;
                        this.showUpload = false;
                    }
                    // this.showUtilityBillDate = true;
                    // this.showUpload = false;
                } else if (this.docName === "Shop and Establishment") {

                    this.getAreaValues('Shop & Establishment Area Code');
                    //  this.showEstablishmentDate = true;
                    this.showUpload = false;
                } else if (this.docName === 'GST certificate') {
                    this.showGstNo = true;
                    this.showUpload = false;
                    this.gstSelected = null;
                    this.gstSelectedId = null;
                    this.selectedGstRec = null;
                } else {
                    this.showUpload = true;
                    this.isPanKyc = true;
                    this.handleButtonState();
                }
            } else if ((this.docType === 'Identity Proof' || this.docType === 'Residence Address proof - OVD') && this.docName === "Letter issued by the National Population Register") {
                this.showNPRDocNo = true;
                this.showUpload = false;
            }
            else if (this.docType.toLowerCase() === strVal1.toLowerCase() && (this.docName.toLowerCase() === strVal5.toLowerCase() || this.docName.toLowerCase() === strVal6.toLowerCase())) {//LAK-9172
                // this.showNPRDocNo = true;
                // this.showUpload = false;
                ///test

                if (this.docName.toLowerCase() === strVal5.toLowerCase() && this.uploadedDocuments.find((doc) => doc.docDetName.toLowerCase() === strVal6.toLowerCase())) {
                    this.showUpload = false;
                    this.showToast("Error", "error", strVal6 + ' is already uploaded please delete to Upload ');
                } else if (this.docName.toLowerCase() === strVal6.toLowerCase() && this.uploadedDocuments.find((doc) => doc.docDetName.toLowerCase() === strVal5.toLowerCase())) {
                    this.showUpload = false;
                    this.showToast("Error", "error", strVal5 + ' is already uploaded please delete to Upload ');
                }
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
    handleInputChangeEstablishmentDate(event) {//  https://fedfina.atlassian.net/browse/LAK-4748
        let val = event.target.value;
        if (event.target.name == 'UtilityBillDate__c') {
            // let dateVal = event.target.value;
            this.establishmentDate = val;
        } else if (event.target.name == 'Registration Number') {
            this.resgitrationValue = val.toUpperCase();
        }
        if (this.resgitrationValue) { //if (this.establishmentDate && this.resgitrationValue)// LAK-8878
            if (this.showShopEstValidateBtn == false && this.showValidateBtn == false) {
                this.showUpload = true;
                this.isPanKyc = true;
            } else {
                this.showValidateBtn = true;
                this.showShopEstValidateBtn = false;
            }

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
            if (searchDoc && searchDoc.docDetType.toLowerCase() !== strVal1.toLowerCase()) { //&& searchDoc.docDetType.toLowerCase() !== strVal2.toLowerCase()  LAK-8923
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
                    else if (searchDoc.docDetType.toLowerCase() !== strVal1.toLowerCase() && searchDoc.docDetType.toLowerCase() !== this.docType.toLowerCase()) { //  && searchDoc.docDetType.toLowerCase() !== strVal2.toLowerCase()   LAK-8923
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
        console.log('appkycId for pan', this.appKycId);
        let appkycId = this.appKycId ? this.appKycId : null;
        if (isInputCorrect === true) {
            checkDuplicateDoc({ loanId: this.loanAppId, appKycId: appkycId, docId: panNo, docType: 'panValidate', applId: this.applicantId })
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
    validationForDocument;
    validateDocs(event) {
        let nm = event;
        this.validationForDocument = nm;
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
        if (nm === "ShopNEstValidate") {
            this.callSubscribePlatformEve();
            let serviceName = "Shop And Establishment";
            ingMsgFields[SCHEMA.SVC.fieldApiName] = serviceName;
            ingMsgFields[SCHEMA.NAME.fieldApiName] = serviceName;
            //  appKycFields[SCHEMA.DLExpDt__c.fieldApiName] = this.establishmentDate;// need to change field tem added DL_EXP_DATE
            appKycFields[SCHEMA.AREA.fieldApiName] = this.shopAreaCode;
            appKycFields[SCHEMA.AREA_CODE.fieldApiName] = this.shopAreaValue;
            appKycFields[SCHEMA.REG_NUMBER.fieldApiName] = this.resgitrationValue;
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
            this.updateEmployment(false, false);
            console.log('innnnbuttonclick' + this.appKycId)
            this.callSubscribePlatformEve();
            let serviceName = "Udyam Registration Check";
            ingMsgFields[SCHEMA.REF_OBJ.fieldApiName] = "ApplKyc__c";
            ingMsgFields[SCHEMA.REF_ID.fieldApiName] = this.appKycId;
            ingMsgFields[SCHEMA.PARENT_REF_OBJ.fieldApiName] = 'Applicant__c';
            ingMsgFields[SCHEMA.PARENT_REF_ID.fieldApiName] = this.applicantId;
            ingMsgFields[SCHEMA.SVC.fieldApiName] = serviceName;
            ingMsgFields[SCHEMA.NAME.fieldApiName] = serviceName;

        }
        if (nm === "GSTValidation") {

            console.log('innnnbuttonclick' + this.appKycId)
            this.callSubscribePlatformEve();
            let serviceName = "GSP GST Authentication";
            ingMsgFields[SCHEMA.REF_OBJ.fieldApiName] = "DocDtl__c";
            ingMsgFields[SCHEMA.REF_ID.fieldApiName] = this.docDetId;
            ingMsgFields[SCHEMA.PARENT_REF_OBJ.fieldApiName] = 'ApplKyc__c';
            ingMsgFields[SCHEMA.PARENT_REF_ID.fieldApiName] = this.appKycId;
            ingMsgFields[SCHEMA.SVC.fieldApiName] = serviceName;
            ingMsgFields[SCHEMA.NAME.fieldApiName] = serviceName;

            appKycFields[SCHEMA.GSTIN_Number.fieldApiName] = this.gstSelected;
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
        console.log('handleValidateClick ==', event.target.name)
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
                case "ShopNEstValidate":
                    docId = this.appKycFieldVal.RegNo__c;
                    break;
                case "GSTValidation":
                    if (this.gstSelected) {
                        docId = this.appKycFieldVal.GSTIN__c;
                        break;
                    } else {
                        this.showToast("error", "error", 'Please select GST No');
                        return;
                    }

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
                    this.stopSpinner();
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
        this.showSpinner = true;//
        const recordInput = {
            apiName: SCHEMA.INTG_MSG.objectApiName,
            fields: ingMsgFields
        };

        createRecord(recordInput)
            .then((record) => {
                console.log('iiiiiiiiiiiiiiiii')
                if (this.validationForDocument === 'UdyamValidate') {
                    //  this.updateEmployment(false, false);
                }
            })
            .catch((err) => {
                this.showSpinner = false;
                console.log(" Error in creating Integration msz ", JSON.stringify(err), err.body.message);
                this.showToast("Error ", "error", err.body.message);
            })
    }
    showManualInput(val) {
        this.showPassportInput = false;
        this.showValidateBtn = false;
        this.showVoterInput = false;
        this.showDlInput = false;
        this.showUdhyamBox = false;
        this.showAadharInput = false;
        this.showUtilityBillDate = false;
        this.showEstablishmentDate = false;
        this.showGstNo = false;
        if (val === "Passport") {
            this.showPassportInput = true;
            this.showValidateBtn = true;
        }
        else if (val === "Voter ID") {
            this.showVoterInput = true;
            this.showValidateBtn = true;
        }
        else if (val === "Driving license") {
            this.showDlInput = true;
            this.showValidateBtn = true;
        }
        else if (val === "Aadhar") {
            this.showAadharInput = true;
            this.showValidateBtn = true;
        } else if (val === "Udyam Registration Certificate") {
            this.showValidateBtn = true;
            this.showUdhyamBox = true;
        }
        else if (val === "Electricity Bill") {
            this.showUtilityBillDate = true;
        }
        else if (val === "Shop and Establishment") {
            // this.showEstablishmentDate = true;
            //  this.showValidateBtn = true;
        }
        else if (val === "GST certificate") {

            this.showGstNo = true;
        }
        else {
            this.showDlInput = false;
            this.showPassportInput = false;
            this.showVoterInput = false;
            this.showValidateBtn = false;
            this.showUdhyamBox = false;
            this.showUtilityBillDate = false;
            this.showEstablishmentDate = false;
            this.showGstNo = false;
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

            console.log('  this.uploadedDocuments ==   ', JSON.stringify(event.detail));
            this.uploadedDocuments = event.detail;
            let dataforPan = this.uploadedDocuments.find((doc) => doc.docDetName == "PAN" && doc.docDetType == "PAN");
            setTimeout(() => {
                this.fetchGstDetails();
            }, 2000);

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
            this.showGstNo = false;
            this.showValidateBtn = false;//------------------
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
    async fromUploadDocsContainer(event) {
        if (event) {
            let ev = event.detail;
            console.log('this.docType' + JSON.stringify(ev))
            // this.showUtilityBillDate = false;
            // this.showElectricityBill = false;
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
                    if ((ev.docName === "Form 60" || this.utilityBillDocList.includes(ev.docName))) {
                        console.log('ev.appKycId && ev.docDetailId not found ');
                        this.stopSpinner();
                        if (ev.docName === "Form 60") {
                            this.showPanForm60 = false;
                        }
                        if (ev.docName === 'Electricity Bill') {

                            this.appKycId = ev.appKycId;
                            this.documentDetId = ev.docDetailId;
                            this.selectedDocName = ev.docName;
                            // this.stopSpinner();
                            this.retriggerClickedVal = null;
                            this.updateChildEleBill = ev;
                            this.showUtilityBillDate = true;
                            this.showElectricityBill = true;

                            // setTimeout(() => {
                            let child = this.template.querySelector('c-pan-kyc-electricity-bill');
                            //child.createIntMsz = ev;
                            child.fromUploadDocsContainer(ev);
                            // }, 2000);


                        }
                        if (this.utilityBillDocList.includes(ev.docName)) {
                            const docDetail = {};
                            docDetail[SCHEMA.DocDet_ID.fieldApiName] = ev.docDetailId;
                            docDetail[SCHEMA.Utility_Bill_Date.fieldApiName] = this.utilityBillDate;
                            const recordInput = {
                                fields: docDetail
                            };
                            this.updateRecordMethod(recordInput, 'Utility Bill Date');
                        }

                    }
                    else if (ev.docName === "Shop and Establishment") {
                        // const docDetail = {};
                        // docDetail[SCHEMA.DocDet_ID.fieldApiName] = ev.docDetailId;
                        // docDetail[SCHEMA.Shop_N_Establishment_Date.fieldApiName] = this.establishmentDate;
                        // docDetail[SCHEMA.Shop_N_Establishment_Date.fieldApiName] = this.establishmentDate;
                        // const recordInput = {
                        //     fields: docDetail
                        // };
                        // this.updateRecordMethod(recordInput, 'Shop_N_Establishment_Date');
                        console.log('shop and est ');
                        if (this.shopAreaValue && this.shopAreaValue != 'Others') {
                            this.appKycId = ev.appKycId;
                            this.documentDetId = ev.docDetailId;
                            this.selectedDocName = ev.docName;
                            const appKyc = {};
                            appKyc[SCHEMA.APP_KYC_ID.fieldApiName] = ev.appKycId;
                            appKyc[SCHEMA.DL_EXP_DATE.fieldApiName] = this.establishmentDate;
                            appKyc[SCHEMA.AREA.fieldApiName] = this.shopAreaCode;
                            appKyc[SCHEMA.AREA_CODE.fieldApiName] = this.shopAreaValue;
                            appKyc[SCHEMA.REG_NUMBER.fieldApiName] = this.resgitrationValue;
                            const recordInput = {
                                fields: appKyc
                            };
                            this.callSubscribePlatformEve();
                            console.log('Subscribed 1491');
                            setTimeout(() => {
                                this.updateRecordMethodNew(recordInput, 'Shop_N_Establishment_Date_Api', ev.appKycId, ev.docDetailId);
                            }, 4000);

                        } else {
                            this.showEstablishmentDate = false;
                            this.stopSpinner();
                        }
                    } else if (ev.docName == 'Udyam Registration Certificate') {
                        console.log('ev.docName' + ev.docName)
                        if (ev.appKycId && ev.docDetailId) {
                            this.showSpinner = true;
                            this.appKycId = ev.appKycId;
                            this.documentDetId = ev.docDetailId;
                            this.callSubscribePlatformEve();
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
                                //this.showSpinner = true;
                                console.log('record of message createddddd' + JSON.stringify(upsertData))
                                this.updateEmployment(false, false);
                                setTimeout(() => {
                                    updateData({ upsertData: upsertData })
                                        .then(result => {
                                            console.log('resultresultresultresultresult' + JSON.stringify(result))
                                            this.showToast("Success ", "success", 'Verifiying Udyam Registration Number.');
                                            this.showSpinner = true;
                                        }).catch(error => {

                                            console.log(error);
                                        })
                                }, 4000);


                            } else {
                                console.log('udyam is not present')
                            }
                        }
                    } else if (ev.docName == "GST certificate") {
                        this.appKycId = ev.appKycId;
                        this.documentDetId = ev.docDetailId;
                        //
                        console.log('gst validation initiation', this.selectedGstRec);
                        if (this.hasAvailableGSTList && this.selectedGstRec && this.selectedGstRec.GSTAuthenticationStatus__c === 'Success') {
                            HELPER.updateApplicantKYC(this.applicantId, this.selectedGstRec, ev.appKycId, ev.docDetailId);
                            setTimeout(() => {
                                this.showToast("Success ", "success", 'GST Validated');

                                this.stopSpinner();
                            }, 3000);

                        } else {

                            this.callSubscribePlatformEve();
                            HELPER.updateAppKycCrtIntMsz(this.applicantId, this.gstSelected, ev.appKycId, ev.docDetailId);

                            this.showToast("Success ", "success", 'GST Validation Initiated ');




                        }
                    }
                    else {
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



                console.log('if fileupload true last line ');

            } else {
                console.log('if fileupload false ');
                this.showToast("Error", "error", LABELS.PanKycCheck_FileUpload_ErrorMessage + ev.docName);
                this.stopSpinner();
            }
        }
    }
    createDDforbusinessAddress() {
        this.createDocumentDetailRecord("PAN Documents", "PAN", "PAN");
    }

    createIntegrationMsg(appKycId, ddId, serviceName) {
        const fields = HELPER.createIntegrationMsg(appKycId, ddId, serviceName);
        //4. Prepare config object with object and field API names 
        const recordInput = {
            apiName: SCHEMA.INTG_MSG.objectApiName,
            fields: fields
        };

        //5. Invoke createRecord by passing the config object
        this.callSubscribePlatformEve();

        createRecord(recordInput).then((record) => {
            console.log('intMsz created ');
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
                }
                    ,
                    (error) => {
                        console.log('Error In Subscribing ', JSON.stringify(error));
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
        console.log('handlePlatformEventResponce', payload, payload.RecId__c, this.appKycId, payload.Success__c, payload.SvcName__c);
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
                } else if (payload.SvcName__c == "Electricity Bill Authentication") {
                    this.showElectricityBill = false;
                    this.showToast("success", "success", 'Electricity Bill Authentication Api is Successful!');
                    this.stopSpinner();
                    this.resetValues();
                    // this.handleUnsubscribe();
                }
                else if (payload.SvcName__c == "Udyam Registration Check") {
                    this.showToast("success", "success", 'Udyam Registration Check Api is Successful!');
                    this.stopSpinner();
                    this.resetValues();
                }
                else if (payload.SvcName__c == "Shop And Establishment") {
                    this.showToast("success", "success", 'Shop And Establishment Check Api is Successful!');
                    this.stopSpinner();
                    this.resetValues();
                    this.showEstablishmentDate = false;
                }
                else if (payload.SvcName__c == "GSP GST Authentication") {

                    this.showToast("success", "success", 'GSP GST Authentication Check Api is Successful!');
                    this.stopSpinner();
                    this.resetValues();

                }
                else {
                    this.showToast("success", "success", LABELS.PanKycCheck_Validation_SuccessMessage);
                    this.stopSpinner();
                    this.resetValues();

                }

            } else if (payload.RecId__c == this.appKycId && !payload.Success__c) {
                this.noIntResponec = false;
                if (payload.SvcName__c == "Udyam Registration Check") {
                    if (payload.Error_Message__c == null) {
                        this.showToast("Error", "Error", 'Udyam Registration Check Failed');
                    } else {
                        console.log(" Udyam Registration", payload.Error_Message__c);
                        this.showToast("Error", "Error", 'Udyam Registration Check Failed ' + payload.Error_Message__c);
                    }
                    this.stopSpinner();
                    this.resetValues();
                    return;
                }
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
                }
                else if (payload.SvcName__c == "Electricity Bill Authentication") {
                    this.showElectricityBill = true;
                    this.showToast("Error", "Error", 'Electricity Bill Authentication Api is failure');
                    this.stopSpinner();
                    this.resetValues();
                    // this.handleUnsubscribe();
                }
                else if (payload.SvcName__c == "Shop And Establishment") {
                    this.showElectricityBill = true;
                    this.showToast("Error", "Error", 'Shop And Establishment Check Api is failure');
                    this.stopSpinner();
                    this.resetValues();
                    this.showEstablishmentDate = false;
                    //this.handleUnsubscribe();
                }
                else if (payload.SvcName__c == "GSP GST Authentication") {

                    this.showToast("Error", "Error", 'GSP GST Authentication Check Api is failure');
                    this.stopSpinner();
                    this.resetValues();

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
        this.shopAreaValue = '';
        this.resgitrationValue = '';
        this.establishmentDate = '';
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

    handleForwardClicked(event) {
        this.appKycFieldVal = {};
        let clickedToCheck = event.detail.fileIterator.fileIterator;
        if (clickedToCheck) {
            this.docType = clickedToCheck.docDetType;
            this.docNameOption = [];
            console.log(' in this doc type ', this.docType, this.documentCatagoeyMap[this.docType]);
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
                    this.showUpload = false;
                    this.showManualInput(clickedToCheck.docDetName);
                }
                else if (this.docName === "Shop and Establishment") {
                    let params = {
                        ParentObjectName: 'ApplKyc__c',
                        parentObjFields: ["Id", "RegNo__c", "Area__c", "AreaCode__c"],
                        queryCriteria: ' where Id = \'' + this.appKycId + '\''
                    };
                    this.getAreaValues('Shop & Establishment Area Code');
                    getSobjectDataNonCacheable({ params: params })
                        .then((result) => {
                            if (result.parentRecords && result.parentRecords.length > 0) {
                                let res = result.parentRecords[0];
                                console.log('Shop & Establishment data == ', result.parentRecords);
                                let step = {
                                    label:
                                        res.Area__c,
                                    value: res.AreaCode__c
                                };
                                this.shopEstAreCodeOptions = this.shopEstAreCodeOptions ? this.shopEstAreCodeOptions : [step];
                                if (res.Area__c !== 'Other') {
                                    this.shopAreaValue = res.AreaCode__c;
                                    this.shopAreaCode = res.Area__c;
                                    this.resgitrationValue = res.RegNo__c;
                                    this.showEstablishmentDate = true;
                                    this.showInpitParam = true;
                                    this.showUpload = false;
                                } else {
                                    this.showUpload = false;
                                }

                                this.showShopEstValidateBtn = true
                                this.showValidateBtn = true;
                                // if (this.establishmentDate) { //https://fedfina.atlassian.net/browse/LAK-8878
                                //     this.showValidateBtn = true;
                                // }



                            }
                        })


                    //  this.showEstablishmentDate = true;
                    this.showUpload = false;
                }

                else if (this.docName === 'GST certificate') {
                    this.showGstNo = true;
                    //this.showUpload = false;
                    this.showValidateBtn = true;
                    this.gstSelected = null;
                    this.gstSelectedId = null;
                    this.selectedGstRec = null;
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
                /*  this.allDocDetName=[];
                   for(const record of this.uploadedDocuments){
                   this.allDocDetName.push(record.docDetName);
                   }*/
                //this.updateEmployment(true, false);

                /* if(!allDocDetName.includes('Udyam Registration Certificate') && this.showURCnumberBlock && this.selfEmpNonIndPropProp){
                      this.showToast("Error ", "error", 'please attach Udyam Assist Certificate for verify Udyam Registration Number.');
                      this.checkDocumentValidation();
                  }else{
                      this.updateEmployment(true, false);
                  }*/
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
                                console.log('upsertMultipleRecord for employment', result);
                                if (result) {
                                    this.employmentRecord.Id = result[0].Id;
                                }
                                this.validations(checkDocValidation);
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
        } else {
            this.validations(checkDocValidation);
        }
    } //LAK-7421

    validations(checkDocValidation) {
        if (checkDocValidation) {
            this.checkDocumentValidation();
        } else {
            this.showSpinner = false;
        }
        this.getApplicantDetails();
    }

    checkDocumentValidation() {

        let osvCheckedReq = this.uploadedDocuments.filter((doc) => doc.osvReq !== false);
        if (this.uploadedDocuments.length > 0) {
            let osvChecked = osvCheckedReq.filter((doc) => doc.osv !== true);

            if (osvChecked.length !== 0 && this.isNotDSA) {
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

                // LAK- 6007
                let dataforAadhar = this.uploadedDocuments.find((doc) => doc.docDetName == "Aadhaar");
                let dataforAadharConcent = this.uploadedDocuments.find((doc) => doc.docDetName == "Aadhaar Consent");

                if (dataforAadhar && (!dataforAadhar.validationStatus || dataforAadhar.validationStatus == 'Failure') && !dataforAadharConcent) {
                    this.showKycValidSuccess = false;
                    this.showToast(" Error  ", "error", 'Aadhaar Consent is Not Provided');
                } else {
                    this.evaluateAllRequiredRecords();
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
        this.showValidateBtn = false;
        this.showUtilityBillDate = false;
        this.showSpinner = false;
        this.refreshDocTable("ss");
        this.handleUnsubscribe();
        this.showGstNo = false;
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
                        this.showModelPopup = false;
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
        let serviceName = 'Pan Validation';
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

                        console.log('Error In Subscribing FOR Retrigger ', JSON.stringify(error));

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
    fromChildComp(event) {
        let ev = event.detail;
        console.log('called bu childmethod ', ev);

        if (ev.enableUpload) {
            this.showUpload = true;
        } else if (ev.disableUpload) {
            this.showUpload = false;
        } else if (ev.subscribePlatEve) {
            this.callSubscribePlatformEve();
        } else if (ev.startSpinner) {
            this.showSpinner = true;
        } else if (ev.stopSpinner) {
            this.showSpinner = fasle;
        }

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
                }

            })
            .catch((err) => {
                this.showSpinner = false;
                this.showToast("Error", "error", err.message);
                console.log(" getSobjectDatawithRelatedRecords error fro getting area codes===", err);
            });
    }
    @track shopEstAreCodeOptions = [];
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
    updateRecordMethodNew(recordInput, msz, appKycId, docDtlId) {
        updateRecord(recordInput)
            .then((record) => {
                console.log('AppKyc Updated ');
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
}