import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getNdcRequiredDoc from "@salesforce/apex/NdcController.getNdcRequiredDoc";
import createDocumentDetail from "@salesforce/apex/NdcController.createDocDetailwithApplicantAsset";
// Custom labels
import NdcuploadDoc_DocType_ErrorMessage from '@salesforce/label/c.NdcuploadDoc_DocType_ErrorMessage';
import NdcuploadDoc_Doc_SuccessMessage from '@salesforce/label/c.NdcuploadDoc_Doc_SuccessMessage';
import NdcuploadDoc_DocDetails_ErrorMessage from '@salesforce/label/c.NdcuploadDoc_DocDetails_ErrorMessage';
import NdcuploadDoc_Name_ErrorMessage from '@salesforce/label/c.NdcuploadDoc_Name_ErrorMessage';
import NdcuploadDoc_Type_ErrorMessage from '@salesforce/label/c.NdcuploadDoc_Type_ErrorMessage';

export default class NdcUploadDoc extends LightningElement {
    customLabel = {
        NdcuploadDoc_DocType_ErrorMessage,
        NdcuploadDoc_Doc_SuccessMessage,
        NdcuploadDoc_DocDetails_ErrorMessage,
        NdcuploadDoc_Name_ErrorMessage,
        NdcuploadDoc_Type_ErrorMessage

    }
    @api loanAppId = 'a08C40000083aTlIAI';
    @api appid = 'a0AC4000000HoGXMA0';
    @api docCategory = 'KYC Documents';
    @api appAssetId = 'a0ZC4000000FOejMAG';
    @api readOnly = false;
    @api layoutSize = {
        "large": "4",
        "medium": "6",
        "small": "12"
    }
    @api sectionName;

    @track docType;
    @track docName;
    @track catValue;
    @track totalResult;
    @track catgryDocs = [];
    @track docTypeOptionNew = [];
    typeWithCategory = new Map();
    @track docRecord = {};
    @track docNameOptionNew = [];
    @track DocumentDetaiId;
    @track avialeblInFileValue = false; //LAK-4916
    connectedCallback() {
        console.log('docCategory ', this.docCategory);
        console.log('appid ', this.appid);
        console.log('appAssetId ', this.appAssetId);
        console.log('appAssetId ', this.appAssetId);
        if (this.docCategory) {
            this.catgryDocs.push(this.docCategory);
        }
        this.getRequiredDoc();
    }
    get filtercondition() {
        return 'Catgry__c = \'' + this.docCategory + '\' AND Active__c = true';
    }

    handleLookupFieldChange(event) {
        if (event.detail) {
            console.log('Event detail====> ', event.detail);
            this.docType = event.detail.mainField;
            console.log("docType>>>", this.docType);
        }
    }
    get showAvaiInFile() {
        if (this.sectionName === 'Additional Post Sanction Documents' || this.sectionName === 'Property Documents') {
            return true;
        }
        return false;
    }
    get filterconditionForDocSubType() {
        return 'DocTyp__c = \'' + this.docType + '\' AND Active__c = true';
    }
    handleLookupFieldChangeForDocSubType(event) {
        if (event.detail) {
            console.log('Event detail====> ', event.detail);
            this.docName = event.detail.mainField;
            console.log("docName>>>", this.docName);
        }
    }
    getRequiredDoc() {
        if (this.catgryDocs.length > 0) {
            getNdcRequiredDoc({ docCategory: this.docCategory })
                .then((result) => {
                    console.log(
                        'result for options', result
                    );
                    console.log('keys of result ');
                    this.totalResult = result;
                    Object.keys(result).forEach(key => {
                        if (this.catgryDocs.includes(key)) {
                            Object.keys(result[key]).forEach(keyty => {
                                this.typeWithCategory.set(keyty, key);
                                let docc = { label: keyty, value: keyty };
                                this.docTypeOptionNew = [...this.docTypeOptionNew, docc];
                                this.docTypeOptionNew.sort(this.compareByLabel); //picklist sorting
                            });
                        }
                    });
                    console.log('docTypeOptionNew new is===> ', this.docTypeOptionNew);
                    console.log('typeWithCategory map ==> ', this.typeWithCategory);
                })
                .catch((err) => {
                    console.log('error while getNdcRequiredDoc', err);
                })
        }

    }

    handleValueChange(event) {
        this.avialeblInFileValue = event.target.checked;
        console.log('this.avialeblInFileValue ', this.avialeblInFileValue);
    }
    handleChange(event) {
        let name = event.target.name;
        let val = event.target.value;
        console.log('name', name, 'val', val);
        if (name === 'DocumentType') {
            this.docType = val;
            this.docName = '';
            this.docNameOptionNew = [];

            this.catValue = this.typeWithCategory.get(val);
            console.log('catValue', this.catValue);
            console.log('before loop', this.totalResult[this.catValue][val]);
            this.totalResult[this.catValue][val].forEach(item => {
                let docc = { label: item, value: item };
                this.docNameOptionNew = [...this.docNameOptionNew, docc];
                this.docNameOptionNew.sort(this.compareByLabel); //picklist sorting
            });
            console.log('docNameOptionNew ==>  ', this.docNameOptionNew);
            this.showUpload = false;
        }
        if (name === 'DocumentName') {
            this.docName = '';
            console.log('document name ', this.docName);
            if (this.docType) {
                this.docName = val;
            } else {
                this.showToast(
                    "Error!",
                    "error",
                    this.customLabel.NdcuploadDoc_DocType_ErrorMessage
                );
            }
        }
        this.fileName = "";
    }

    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(evt);
    }
    createDocumentDetailRecord() {
        // console.log('param to this methods is ' + param);
        this.showSpinner = true;
        if (this.docType) {
            if (this.docName) {
                this.showSpinner = true;
                console.log('createDocumentDetailRecord applicantId:', this.appid, "loanAppId: ", this.loanAppId, "docCategory:", this.docCategory, "docType:", this.docType, "docSubType:", this.docName, 'applicantAssetId ', this.appAssetId);
                createDocumentDetail({ applicantId: this.appid, loanAppId: this.loanAppId, docCategory: this.docCategory, docType: this.docType, docSubType: this.docName, applicantAssetId: this.appAssetId, avialeblInFileValue: this.avialeblInFileValue })
                    .then((result) => {
                        console.log('createDocumentDetailRecord result ', result);
                        this.docRecord = result;
                        this.DocumentDetaiId = result.Id;
                        console.log('inside upload hanlder');
                        this.showToast(
                            "Success",
                            "success",
                            this.customLabel.NdcuploadDoc_Doc_SuccessMessage
                        );
                        this.docName = "";
                        this.docType = "";
                        this.avialeblInFileValue = false;
                        this.showSpinner = false;

                        let val = {
                            "record": this.docRecord,
                            "sectionName": this.sectionName,
                            "appAssetId": this.appAssetId
                        }
                        const selectEvent = new CustomEvent('passtoparentupload', {
                            detail: val
                        });
                        this.dispatchEvent(selectEvent);
                    })
                    .catch((err) => {
                        this.docName = "";
                        this.docType = "";
                        this.showSpinner = false;
                        this.avialeblInFileValue = false;
                        this.showToast("Error", "error", err.body.message);
                        console.log("createDocumentDetailRecord error===", err);
                    });
            } else {
                this.showSpinner = false;
                this.showToast(
                    "Error!",
                    "error",
                    this.customLabel.NdcuploadDoc_Name_ErrorMessage
                );
            }
        } else {
            this.showSpinner = false;
            this.showToast(
                "Error!",
                "error",
                this.customLabel.NdcuploadDoc_Type_ErrorMessage
            );
        }

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
}