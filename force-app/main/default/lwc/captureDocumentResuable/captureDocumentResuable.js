import { LightningElement, api, track, wire } from 'lwc';

export default class CaptureDocumentResuable extends LightningElement {
    @api recordId;
    @api loanAppId;
    @api hasEditAccess;
    @api applicantId;
    @api reqDocFlag;
    @api disableMode;
    @api documentCatagory;
    @api negotiationInitiated;
    @track showTable = true;
    @track productType = 'Home Loan';

    @api layoutSize;
    @api docTypeOption;


    @track docType;
    @track docName;
    @track isotherDocuments = true;
    @track showUpload = false;

    @track docType = '';
    @track docSubType = '';
    @track docCategory = 'Loan Term Negotiation Documents';
    @track negotiationInitiated = false;

    get docCate() {
        return 'Loan Term Negotiation Documents';
    }

    connectedCallback() {
        console.log(' cc logs ', this.loanAppId, '  ::  ', this.applicantId);


    }

    handleChange(event) {
        let id = event.target.dataset.id;
        let name = event.target.name;
        let value = event.target.value;
        if (name == 'DocumentType') {
            this.docType = event.target.value;

        } else if (name == 'DocumentName') {
            this.docName = event.target.value;
            if (this.docName != null) {
                this.showUpload = true;
            }
        }


    }
    fromUploadDocsContainer(event) {

        console.log('event after uplaoding is ', event.detail);

        let docIdToUpdate = event.detail.docDetailId;
        console.log('event after uplaoding  docDetailId is  ', docIdToUpdate);
        this.refreshDocTable();
        this.showSpinner = false;
        // if (this.appAsserId) {
        //     let obj = {
        //         sobjectType: "DocDtl__c",
        //         Id: docIdToUpdate,
        //         ApplAsset__c: this.appAsserId
        //     }
        //     this.upsertIntRecord(obj);
        //     // this.checkValidityOfDocument();
        // } else {
        //     this.refreshDocTable();
        // }


    }
    spinnerStatus(event) {
        console.log('spinnerStatus ', event);
        this.showSpinner = true;
    }
    refreshDocTable(usedFor) {

        let child = this.template.querySelector('c-show-negotiation-documents');
        child.handleFilesUploaded(usedFor);
    }
    passToParent(event) {
        let param = event;
        console.log('from DependentCombobox = ');

        const selectEvent = new CustomEvent('passtoparent', {
            detail: param
        });
        this.dispatchEvent(selectEvent);
    }
}