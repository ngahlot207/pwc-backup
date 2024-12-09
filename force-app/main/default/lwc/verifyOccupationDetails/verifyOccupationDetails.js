import { LightningElement, track, api, wire } from 'lwc';
import allApplicantsData from '@salesforce/apex/verifyOccupationDetailController.allApplicantsData';
import getVerificationData from '@salesforce/apex/verifyOccupationDetailController.getVerificationData';
import { deleteRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import API_VERIFICATION_OBJECT from '@salesforce/schema/APIVer__c';
import VERIFICATION_STATUS from '@salesforce/schema/APIVer__c.Verification_Status__c';
import PROF_QUA_CHECK from '@salesforce/schema/APIVer__c.Prof_Qualification_Check__c';
import APPLICANT_ID from '@salesforce/schema/APIVer__c.Appl__c';
import DOC_DETAIL_ID from '@salesforce/schema/APIVer__c.Document_Detail_Id__c';
import LOAN_APP_ID from '@salesforce/schema/APIVer__c.LoanAplcn__c';
import { publish, subscribe, unsubscribe, createMessageContext, releaseMessageContext } from 'lightning/messageService';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";

const verificationTypes = [
    { label: 'Udyam', value: 'Udyam Verification' },
    { label: 'GST', value: 'GSTIN Verification' },
    { label: 'Qualification Check', value: 'Qualification Check' },
    { label: 'Probe42', value: 'Probe 42' },
    { label: 'Official Email', value: 'Official Email Verification' },
    { label: 'Shop & Establishment', value: 'Shop and Establishment Verification' },
    { label: 'EPFO', value: 'EPFO' }
];

export default class VerifyOccupationDetails extends LightningElement {

    @api loanAppId;
    @api hasEditAccess;

    @track _loanAppId;

    @track recordTypeId;
    @track recordTypeName;

    rtis;
    applicantId;
    accordianData = [];
    openVerficationModal = false;
    borrowers = [];
    selectedBorrower;
    verificationPicklistValues;
    profQuaCheckPicklistValues;
    isProfQuaCheck = false;
    borrowerData = {};
    documentName = 'Verification';
    documentType = 'Occupation'
    docCategory = 'Verification Documents';
    verificationRecords = [];
    showVerificationStatus = false;
    showFileUpload = false;
    verStatusLabel = null;
    showFilePreview = false;
    documentDetailId;
    hasDocumentId;
    hideUploadButton = false;
    hideAttachButton = false;
    filteredVerTypes = [];
    finalVerificationRecords = [];
    verIdonTableUpload;
    isReadOnly;
    files = [];
    context = createMessageContext();




    // @wire(allApplicantsData, { loanApplicationId: '$loanAppId' })
    fetchApplicantsData() {//LAK-10188
        allApplicantsData({ loanApplicationId: this.loanAppId })
            .then(result => {
                console.log('allApplicantsData : ' + JSON.stringify(result));


                this.handleResponse(result);
            })
            .catch(error => {
                console.error('Error fetching applicants data:', error);
            });
    }
    handleResponse(result) {
        // this.wiredData = result;
        if (result) {
            console.log('Initial Data Recied in Occupation!! ' + JSON.stringify(result));
            let isSEP = false;
            let isSENP = false;
            let isSalaried = false;
            for (let ele in result) {
                if (ele === 'SELF EMPLOYED PROFESSIONAL') {
                    isSEP = true;
                }
                if (ele === 'SELF EMPLOYED NON PROFESSIONAL') {
                    isSENP = true;
                }
                if (ele === 'SALARIED') {
                    isSalaried = true;
                }
                let elements = result[ele];
                if (elements) {
                    elements.forEach(element => {
                        if (element.FName__c != null) {
                            this.borrowers.push({ label: element.FName__c, value: element.Id });
                        }
                    })
                }
            }
            if (isSEP) {
                this.filteredVerTypes.push('Udyam');
                this.filteredVerTypes.push('GST');
                this.filteredVerTypes.push('Qualification Check');
                this.filteredVerTypes.push('Probe42');
                this.filteredVerTypes.push('Shop & Establishment');

            } else if (isSENP) {
                this.filteredVerTypes.push('Udyam');
                this.filteredVerTypes.push('GST');
                this.filteredVerTypes.push('Probe42');
                this.filteredVerTypes.push('Shop & Establishment');
            }
            if (isSalaried) {
                this.filteredVerTypes.push('Qualification Check');
                this.filteredVerTypes.push('Probe42');
                //this.filteredVerTypes.push('EPFO')
            }
            this.filteredVerTypes.push('EPFO')
            //this.filteredVerTypes.push('Probe42');
            this.filteredVerTypes.push('Official Email');
            this.filteredVerTypes = [...new Set(this.filteredVerTypes)];
        }
        this.getVerificationRecords(); //LAK - 10188
    }

    @wire(getObjectInfo, { objectApiName: API_VERIFICATION_OBJECT })
    wiredObjectInfo(result) {
        if (result.data) {
            console.log('Result.data---' + JSON.stringify(result.data));
            this.rtis = result.data.recordTypeInfos;
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeId',
        fieldApiName: VERIFICATION_STATUS
    })
    verificationPicklistValues({ data }) {
        if (data) {
            this.verificationPicklistValues = data.values;
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeId',
        fieldApiName: PROF_QUA_CHECK
    })
    profQuaCheckPicklistValues({ data }) {
        if (data) {
            this.profQuaCheckPicklistValues = data.values;
        }
    }


    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.context,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }

    handleSaveThroughLms(values) {

        this.handleSave();
    }

    handleSave() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Verification Details Saved Successfully',
                variant: 'Success',
                mode: 'sticky'
            }),
        );
    }

    connectedCallback() {
        console.log(' occupation detail loanAppId = ', this.loanAppId, '  hasEditAccess =  ', this.hasEditAccess);


        this.isReadOnly = this.hasEditAccess === true ? false : true;
        this.scribeToMessageChannel();
        this.fetchApplicantsData();

    }

    handleAddMore(event) {
        this.borrowerData = {}
        this.openVerficationModal = true;
        this.isProfQuaCheck = false;
        this.hideAttachButton = true;
        if (event.currentTarget.dataset.id === 'Udyam Verification') {
            this.verStatusLabel = 'Udyam Verification Status';
            this.showFileUpload = true;
            this.showVerificationStatus = true;
            this.recordTypeName = 'Udyam';
            this.recordTypeId = Object.keys(this.rtis).find((rti) => this.rtis[rti].name === this.recordTypeName);
            this.borrowerData.recordTypeName = event.currentTarget.dataset.id;

        } else if (event.currentTarget.dataset.id === 'GSTIN Verification') {
            this.verStatusLabel = 'GST Verification Status';
            this.showFileUpload = true;
            this.showVerificationStatus = true;
            this.recordTypeName = 'GST';
            this.recordTypeId = Object.keys(this.rtis).find((rti) => this.rtis[rti].name === this.recordTypeName);
            this.borrowerData.recordTypeName = event.currentTarget.dataset.id;
        } else if (event.currentTarget.dataset.id === 'Qualification Check') {
            this.isProfQuaCheck = true;
            this.verStatusLabel = 'Professional Qualification Check Status';
            this.showFileUpload = true;
            this.showVerificationStatus = true;
            this.recordTypeName = 'Qualification Check';
            this.recordTypeId = Object.keys(this.rtis).find((rti) => this.rtis[rti].name === this.recordTypeName);
            this.borrowerData.recordTypeName = event.currentTarget.dataset.id;
        } else if (event.currentTarget.dataset.id === 'Probe 42') {
            this.verStatusLabel = 'Probe 42 Verification Status';
            this.showFileUpload = true;
            this.showVerificationStatus = true;
            this.recordTypeName = 'Probe42';
            this.recordTypeId = Object.keys(this.rtis).find((rti) => this.rtis[rti].name === this.recordTypeName);
            this.borrowerData.recordTypeName = event.currentTarget.dataset.id;
        }
        else if (event.currentTarget.dataset.id === 'EPFO') {
            this.verStatusLabel = 'EPFO';
            this.showFileUpload = true;
            this.showVerificationStatus = true;
            this.recordTypeName = 'EPFO';
            this.recordTypeId = Object.keys(this.rtis).find((rti) => this.rtis[rti].name === this.recordTypeName);
            this.borrowerData.recordTypeName = event.currentTarget.dataset.id;
        } else if (event.currentTarget.dataset.id === 'Official Email Verification') {
            this.verStatusLabel = 'Official Email Verification Status';
            this.showFileUpload = true;
            this.showVerificationStatus = true;
            this.recordTypeName = 'Official Email';
            this.recordTypeId = Object.keys(this.rtis).find((rti) => this.rtis[rti].name === this.recordTypeName);
            this.borrowerData.recordTypeName = event.currentTarget.dataset.id;
        }
    }

    inputchangeHandler(event) {
        let fieldName = event.target.dataset.field;
        let fieldValue = event.target.value;
        this.borrowerData[fieldName] = fieldValue;
        if (fieldName === 'borrowerName') {
            this.applicantId = fieldValue;
        }
    }

    handleDocUploadResp(event) {
        let fileUploadData = event.detail;
        this.borrowerData['docDetailId'] = fileUploadData.docDetailId;
        console.log('Docdetailid--' + fileUploadData.docDetailId);
        const fields = {};
        fields['Id'] = this.verIdonTableUpload;
        fields[DOC_DETAIL_ID.fieldApiName] = fileUploadData.docDetailId;
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.getVerificationRecords();
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error updating record",
                        message: error.body.message,
                        variant: "error",
                        mode: 'sticky'
                    }),
                );
            });
    }

    handleCancel() {
        this.openVerficationModal = false;
    }

    isValidInput(inputList) {
        const isValid = [...inputList].reduce((valid, inputField) => {
            inputField.reportValidity();
            return valid && inputField.checkValidity();
        }, true);
        return isValid;
    }

    async handleSubmit() {
        let isValid = true;
        const inputList = this.template.querySelectorAll('.slds-input-required')
        if (!this.isValidInput(inputList)) {
            isValid = false;
            return;
        }
        if (this.finalVerificationRecords) {
            for (let i = 0; i < this.finalVerificationRecords.length; i++) {
            }
            this.finalVerificationRecords.forEach((item) => {
                if (item.recordTypeName === this.borrowerData.recordTypeName) {
                    let verList = item.verificationList;
                    verList.forEach(subElement => {
                        if (subElement.applicantId === this.borrowerData.borrowerName) {
                            isValid = false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Borrower is already added for ' + item.recordTypeName,
                                    variant: 'error',
                                    mode: 'sticky'
                                }),
                            );
                        }
                    })
                }
            })
        }
        if (isValid === false) {
            return;
        }
        const fields = {};
        fields['RecordTypeId'] = this.recordTypeId;
        fields[APPLICANT_ID.fieldApiName] = this.borrowerData.borrowerName;
        fields[VERIFICATION_STATUS.fieldApiName] = this.borrowerData.verificationStatus;
        fields[DOC_DETAIL_ID.fieldApiName] = this.borrowerData.docDetailId;
        fields[LOAN_APP_ID.fieldApiName] = this.loanAppId;
        if (this.borrowerData.prof != undefined) {
            fields[PROF_QUA_CHECK.fieldApiName] = this.borrowerData.prof;
        }
        let recordInput = { apiName: API_VERIFICATION_OBJECT.objectApiName, fields };
        await createRecord(recordInput)
            .then(verification => {
                this.verIdonTableUpload = verification.id;
                if (this.template.querySelector('c-upload-docs-reusable-component') != '' && this.template.querySelector('c-upload-docs-reusable-component') != null && typeof this.template.querySelector('c-upload-docs-reusable-component') !== 'undefined') {
                    if (this.files.length > 0) {
                        this.template.querySelector('c-upload-docs-reusable-component').handleUpload();
                    } else {
                        this.getVerificationRecords();
                    }
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'API Verification created',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            })
            .finally(() => {

            })
    }

    getVerificationRecords() {
        this.verificationRecords = [];
        let verificationRecordTypes = [];
        this.finalVerificationRecords = [];
        getVerificationData({ loanApplicationId: this.loanAppId })
            .then(result => {
                if (result) {
                    console.log('getVerificationData', result);
                    console.log('filteredVerTypes ', this.filteredVerTypes);
                    result.forEach(item => {
                        this.openVerficationModal = false;

                        verificationTypes.forEach(type => {
                            const verificationRec = {};
                            if (type.label === item.recordTypeName && this.filteredVerTypes.includes(type.label)) {
                                console.log(' type.label ', type.label);
                                verificationRec.recordTypeName = type.value;
                                verificationRec.showProfQuaCheck = item.showProfQuaCheck;
                                verificationRec.showVerStatus = item.showVerStatus;
                                verificationRecordTypes.push(type.label);
                                verificationRec.verStatusLabel = type.label + ' Verification Status';
                                verificationRec.verificationList = item.verificationList;

                                if (type.label == 'Udyam') {
                                    verificationRec.udyamVerification = true;
                                } else if (type.label == 'GST') {
                                    verificationRec.gstInVer = true;//LAK-622
                                }
                                else if (type.label == 'Shop & Establishment') {
                                    verificationRec.shopAndEst = true;
                                }
                                else if (type.label == 'Probe42') {
                                    verificationRec.prob42 = true;
                                }
                                else if (type.label == 'EPFO') {
                                    verificationRec.epfoVer = true;
                                }
                                else if (type.label == 'Official Email') {
                                    verificationRec.emailVerDet = true;
                                }
                                else if (type.label == 'Qualification Check') {
                                    verificationRec.qualificationCheck = true;
                                }
                                this.verificationRecords.push(verificationRec);
                            }
                        })
                        console.log('verificationTypes  :  ', this.verificationRecords);
                    })
                    if (this.borrowers.length > 0 && this.verificationRecords.length > 0) {
                        this.finalVerificationRecords = [...this.verificationRecords];
                    } else if (this.filteredVerTypes.length == 0) {
                        this.verificationRecords.forEach(item => {
                            if (item.recordTypeName === 'Official Email') {
                                this.finalVerificationRecords.push(item);
                                verificationRecordTypes.push(verificationRec.recordTypeName);
                            }
                        })
                    }
                    let remainingRecordTypes = this.filteredVerTypes.filter(val => !verificationRecordTypes.includes(val));
                    if (remainingRecordTypes) {
                        let recType = '';
                        remainingRecordTypes.forEach(item => {
                            verificationTypes.forEach(type => {
                                if (type.label === item) {
                                    recType = type.value;
                                }
                            })

                            const verificationRec = {}
                            if (recType === 'Qualification Check') {
                                verificationRec.showProfQuaCheck = true;
                                verificationRec.showVerStatus = true;
                            }

                            verificationRec.recordTypeName = recType;
                            verificationRec.verificationList = [];
                            if (verificationRec.recordTypeName == 'Udyam Verification') {
                                verificationRec.udyamVerification = true;
                            }
                            if (verificationRec.recordTypeName == 'Shop and Establishment Verification') {
                                if (this.borrowers) {
                                    verificationRec.shopAndEst = true;
                                }

                            }

                            if (verificationRec.recordTypeName === 'Probe 42') {
                                //verificationRec.showProfQuaCheck = false;
                                //verificationRec.showVerStatus = false;
                                verificationRec.prob42 = true;
                            }
                            //For LAK-622
                            if (verificationRec.recordTypeName === 'GSTIN Verification') {
                                verificationRec.gstInVer = true;

                            } if (verificationRec.recordTypeName === 'EPFO') {
                                verificationRec.epfoVer = true;
                            }
                            //LAK-517
                            if (verificationRec.recordTypeName === 'Official Email Verification') {
                                verificationRec.emailVerDet = true;
                            }
                            // LAK-223
                            if (verificationRec.recordTypeName === 'Qualification Check') {
                                verificationRec.qualificationCheck = true;
                            }
                            //LAK-622
                            this.verificationRecords.push(verificationRec);
                            console.log('this.finalVerificationRecords 0: ', this.verificationRecords);
                        })
                        this.finalVerificationRecords = [...this.verificationRecords];
                        console.log('this.finalVerificationRecords 1: ', this.finalVerificationRecords);

                    }
                }
            })
    }


    handleVerificationDelete(event) {
        let verifcationId = event.currentTarget.dataset.id;
        deleteRecord(verifcationId)
            .then(() => {
                this.getVerificationRecords();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Record deleted",
                        variant: "success",
                    }),
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }

    handleDocumentView(event) {
        this.hasDocumentId = true;
        this.showFilePreview = true;
        this.documentDetailId = event.currentTarget.dataset.id;
    }

    handleCloseModalEvent() {
        this.showFilePreview = false;
    }

    showFileUploadInTable = false;
    handleFileUpload(event) {
        this.verIdonTableUpload = event.target.dataset.id;
        this.applicantId = event.target.dataset.field;
        this.showFileUploadInTable = true;
        this.hideAttachButton = false;
    }

    handleCancelFileUpload() {
        this.showFileUploadInTable = false;
    }

    onFileUpload(event) {
        this.files = event.detail.fileList;
        console.log('this.files---' + JSON.stringify(this.files));
    }
}