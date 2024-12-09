import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFilePreviewDataList from "@salesforce/apex/GetDocumentDetails.getFilePreviewDataList";
import deleteDocRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';

export default class UploadFileAndPreview extends LightningElement {

    @api pdQuestion;
    @api hasEditAccess;
    @api layoutSize;
    @api disabled;

    @api filetype;
    @api allowMultipleFile;
    @api maxFileSize;
    @api docDetailId;



    get disablepFileUpload() {
        if (this.hasEditAccess) {
            return false;
        }
        else {
            return true;
        }
    };

    get acceptedFormats() {
        if (filetype) {
            return filetype;
        }
        else {
            return [".jpg", ".jpeg", ".pdf"];
        }
    }


    // @track acceptedFormats = [".jpg", ".jpeg", ".pdf"]; //JSON.parse(this.pdQuestion.fileConfig).FileType;  // [".jpg", ".jpeg", ".pdf"];

    @track fileUploadMsz = "Maximum File Size should be 5Mb. Allowed File Types are   ";
    // @track alowMultiple = true// JSON.parse(this.pdQuestion.fileConfig).AllowMultipleFile; //true;
    @track disablepForFile = true;

    @track showPreNdeleteIcon = false;

    @track showUploadIcon = false;


    @track showModalForFilePre = false;
    @track showUploadModal = false;
    @track uploadedDocDetail;
    @track url;
    @track removeModalMessage = "Do you want to delete the document ?";
    @track showSpinner = false;
    @track isModalOpen = false;
    @track borderColorClass = 'black-border';// 'red-border';
    get isRequired() {
        return this.pdQuestion.isReqPortal;
    }
    connectedCallback() {
        let fileSizeMsz = ' 5 ';
        if (this.maxFileSize) {
            fileSizeMsz = this.maxFileSize / 1048576;
        }
        if (this.acceptedFormats) {
            this.fileUploadMsz = "Maximum File Size should be " + fileSizeMsz + "Mb . Allowed File Types are   " + this.acceptedFormats.join(' , ');
        } else {
            this.fileUploadMsz = "Maximum File Size should be " + fileSizeMsz + "Mb . Allowed File Types are   " + '.jpg , .jpeg, .pdf';
        }


        console.log('in DynamicFileUploadForPD is ', this.pdQuestion, this.pdQuestion.docDetailId);
        if (this.pdQuestion.docDetailId) {
            this.getUploadedFileData();
        } else {
            this.showUploadIcon = true;
            this.showPreNdeleteIcon = false;

        }
    }
    getUploadedFileData() {
        getFilePreviewDataList({ ddID: this.pdQuestion.docDetailId })
            .then((res) => {
                console.log('result from getFilePreviewData ', res);
                if (res) {
                    this.showUploadIcon = false;
                    this.showPreNdeleteIcon = true;

                } else {
                    this.showUploadIcon = true;
                    this.showPreNdeleteIcon = false;

                }
                this.uploadedDocDetail = res;
                //this.disablepFileUpload = false;
            })
            .catch((err) => {
                // this.showToast("Error", "error", "Error occured in dd " + err.message);
                console.log(" getFilePreviewData error===", err);
                this.showUploadIcon = true;
                this.showPreNdeleteIcon = false;

            });
    }
    deleteFile(event) {
        let name = event.target.name
        console.log('handle delete called', name);
        this.fileDelDet = name;
        this.isModalOpen = true;
    }
    @track filePrevDet;
    @track fileDelDet;
    filePreview(event) {
        let name = event.target.name
        console.log('clecked for preview ', name);

        this.filePrevDet = name;

        this.showModalForFilePre = true;
        this.url = '/sfc/servlet.shepherd/document/download/' + name.cdId;// this.uploadedDocDetail.cdId;//this.contDocId
        console.log('this.url' + this.url);

    }
    handleUploadFinished(event) {
        console.log('handleUploadFinished ', event);
        //const uploadedFiles = event.detail.files;
        this.showUploadModal = false;
        //this.disablepFileUpload = true;
        this.showToast("Success", "success", "Document Uploaded Successfully");
        this.getUploadedFileData();
    }
    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(evt);
    }
    handleCloseModalEvent(event) {
        this.showModalForFilePre = false;
    }
    closeModal() {
        console.log('isModalOpen ', this.isModalOpen);
        this.isModalOpen = false;
    }
    handleRemoveRecord() {
        console.log('delete started ', JSON.stringify(this.fileDelDet));
        this.showSpinner = true;
        if (this.fileDelDet.cdlId) {
            let recList = [];
            let cldRecord = {};
            cldRecord['Id'] = this.fileDelDet.cdlId;
            recList.push(cldRecord);
            console.log('delete started ', JSON.stringify(recList));
            deleteDocRecord({ rcrds: recList })
                // .then((result) => {
                .then((result) => {
                    this.getUploadedFileData();
                    this.showSpinner = false;
                    this.isModalOpen = false;
                    console.log('delete result ', JSON.stringify(result));
                })
                .catch((error) => {
                    this.isModalOpen = false;
                    this.showSpinner = false;
                    this.showToast("Error", "error", "Unable To delete File" + err.message);
                });
        } else {
            this.showSpinner = false;
        }
    }

    handleFileUpload(event) {

        this.showUploadModal = true;
    }
    closeUploadModal() {
        this.showUploadModal = false;
    }
    @api reportValidity() {

        let isValid = true
        if (this.isRequired && this.uploadedDocDetail == null) {
            isValid = false;
            this.borderColorClass = 'red-border';
            console.log('this.borderColorClass', this.borderColorClass);
        }
        return isValid;
    }
    fileUploadFinish(event) {
        console.log('fileUploadFinish', event.detail);
        this.showUploadModal = false;
        this.getUploadedFileData();
        let changedValue = { respType: this.pdQuestion.respType, pdQuestion: this.pdQuestion };
        const selectEvent = new CustomEvent('passtoparent', {
            detail: changedValue
        });
        this.dispatchEvent(selectEvent);
    }


}