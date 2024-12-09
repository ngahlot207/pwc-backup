import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fetchId from "@salesforce/apex/FileUploadController.fetchId";
import deleteDocRecord from '@salesforce/apex/DocumentDetailController.deleteDocDetWithCdl';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import UploadDocDisply_Del_SuccessMessage from '@salesforce/label/c.UploadDocDisply_Del_SuccessMessage';
export default class ShowNegotiationDocuments extends NavigationMixin(LightningElement) {
    customLabel = {
        UploadDocDisply_Del_SuccessMessage

    }
    @api applicantId;
    @api hasEditAccess;
    @api showDeleteIcon = false;
    @api category;
    @api title = "Uploaded Documents";

    enableInfiniteScrolling = true;
    enableBatchLoading = true;
    @track error;
    @track showModalForFilePre = false;

    @track type = [];
    @track subType = [];
    @track lstAllFiles = [];
    @track url;
    @track contDocId;
    @track cvId;
    @track contDocType
    @track url
    @track imageTypeFileUrl
    @track docuDltId = '';
    @track contentDocumentId = '069C4000001Y7PtIAK'
    @track disableMode;
    @track removeModalMessage = "Do you really want to delete this file.";
    get downloadUrl() {
        return `/sfc/servlet.shepherd/version/download/${this.contentDocumentId}`;
    }
    connectedCallback() {
        console.log('applicantId in show case document component ', this.applicantId);
        this.handleFilesUploaded();
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        } else {
            this.disableMode = false;
        }



    }
    @api handleFilesUploaded() {

        console.log(" handle file upload called applicantId:", this.applicantId, "category : ", this.category, " docType: ", this.type, " subType : ", this.subType);
        fetchId({ applicantId: this.applicantId, category: this.category, docType: this.type, subType: this.subType })
            .then((result) => {
                console.log('fetchId calss result ::', result);
                this.lstAllFiles = result;
                console.log(
                    "lstAllFiles before==>",
                    this.docType,
                    " -<-DT--  ",
                    this.applicantId,
                    "  --<-appid---",
                    JSON.stringify(this.lstAllFiles)
                );
                const allListData = new CustomEvent('alllistdata', {
                    detail: this.lstAllFiles
                });
                this.dispatchEvent(allListData);
                this.error = undefined;
                console.log(
                    "lstAllFiles ",
                    this.docType,
                    " -<-DT--  ",
                    this.applicantId,
                    "  --<-appid---",
                    JSON.stringify(this.lstAllFiles)
                );
            })
            .catch((error) => {
                this.error = error;
                this.lstAllFiles = undefined;
                console.log("error occured in fetchId", this.error);
                console.log("handlefileUploaded");
            });
    }



    // renderedCallback() {
    //     loadScript(this, downloadjs)
    //         .then(() => console.log('Loaded download.js'))
    //         .catch(error => console.log(error));
    // }

    handleDownload(event) {

        const salesforceBaseUrl = this.getSalesforceBaseUrl();
        console.log('Salesforce Base URL:', salesforceBaseUrl);

        this.docuDltId = event.currentTarget.dataset.documentid;
        let docName = event.currentTarget.dataset.documenname;
        this.contDocType = event.currentTarget.dataset.type;
        this.cvId = event.currentTarget.dataset.cvId;
        this.contDocId = event.currentTarget.dataset.id;
        this.blobData = event.target.dataset.blobdata;
        console.log('docuDltId ', event.currentTarget.dataset.documentid, 'docName ', event.currentTarget.dataset.documenname);


        let downloadContainer = this.template.querySelector('.download-container');
        let downloadUrl = salesforceBaseUrl + '/sfc/servlet.shepherd/document/download/' + encodeURIComponent(this.contDocId);
        // Use the NavigationMixin to open the PDF URL in a new tab
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: downloadUrl
            }
        });

        // let downloadUrl = salesforceBaseUrl + '/sfc/servlet.shepherd/version/download/' + this.contDocId;
        // let a = document.createElement('a');
        // a.href = downloadUrl;
        // a.target = '_blank';
        // a.download = docName + '.' + this.contDocType;
        // if (downloadContainer) {
        //     downloadContainer.appendChild(a);
        // }
        // if (a.click) {
        //     a.click();
        // }

        // downloadContainer.removeChild(a);

    }

    getSalesforceBaseUrl() {
        // Use window.location.origin to get the protocol, hostname, and port
        const { protocol, hostname, port } = window.location;

        // Construct the Salesforce base URL
        let baseUrl = `${protocol}//${hostname}`;

        // Check if the port is not the default HTTP/HTTPS port (80/443)
        if (port && !['80', '443'].includes(port)) {
            baseUrl += `:${port}`;
        }

        return baseUrl;
    }
    // blobData;
    // handleDownload(event) {
    //     this.docuDltId = event.currentTarget.dataset.documentid;
    //     let docName = event.currentTarget.dataset.documenname;
    //     this.contDocType = event.currentTarget.dataset.type;
    //     this.cvId = event.currentTarget.dataset.cvId;
    //     this.contDocId = event.currentTarget.dataset.id;
    //     this.blobData = event.target.dataset.blobdata;
    //     console.log('blobData value is ', this.blobData);

    //     console.log('docuDltId ', event.currentTarget.dataset.documentid, 'docName ', event.currentTarget.dataset.documenname);
    //     const blob = new Blob([this.blobData], { type: 'application/octet - stream' });

    //     // Create a temporary URL for the Blob
    //     const url = window.URL.createObjectURL(blob);

    //     // Create a link element and trigger a download
    //     const a = document.createElement('a');
    //     a.href = url;
    //     a.target = '_parent';
    //     a.download = docName + '.' + this.contDocType; // Set the desired file name
    //     a.click();

    //     // Clean up the temporary URL
    //     window.URL.revokeObjectURL(url);

    // }

    @api technical;
    @track _Technical = false;
    @track documentDetailId;
    @track hasDocumentId = false;

    handleDocumentView(event) {
        this._Technical = this.technical;
        if (this._Technical) {
            this.documentDetailId = event.currentTarget.dataset.documentid;
            this.showModalForFilePre = true;
            this.hasDocumentId = true;
            this.url = '/sfc/servlet.shepherd/document/download/' + this.contDocId;
            console.log('this.url' + this.url);
            console.log('documentid:', this.conDocId);

        } else {
            console.log("id is ==> " + event.currentTarget.dataset.id);
            console.log("id is ==> " + event.currentTarget.dataset.type);
            this.contDocId = event.currentTarget.dataset.id;
            this.contDocType = event.currentTarget.dataset.type;
            this.cvId = event.currentTarget.dataset.cvId;
            this.showModalForFilePre = true;

            console.log('newnew' + this.showModalForFilePre);
            this.url = '/sfc/servlet.shepherd/document/download/' + this.contDocId;

            //this.imageTypeFileUrl = 'https://fedbank--dev.sandbox.my.site.com/LOS/sfc/servlet.shepherd/version/renditionDownload%3Frendition=THUMB720BY480&versionId='+this.cvId
            console.log('this.url' + this.url);
        }


    }
    @track deleteModel = false;
    docIdToDelete;
    cdlIdToDelete;
    handleDelete(event) {
        console.log(event.target.dataset.id);
        let cdToDelete = event.currentTarget.dataset.id; // to delete individual file
        this.docIdToDelete = event.currentTarget.dataset.documentid;
        this.cdlIdToDelete = event.currentTarget.dataset.cdlid;
        // let param = event.target.dataset.fileIterator;
        this.deleteModel = true;
    }
    closeModal() {
        console.log('isModalOpen ', this.isModalOpen);
        this.deleteModel = false;
    }
    handleRemoveRecord() {
        console.log('cdlIdToDelete in popo yes', this.cdlIdToDelete);
        console.log('docIdToDelete in popo up yes ', this.docIdToDelete);
        this.deleteDocDet(this.docIdToDelete);

    }
    deleteDocDet(docIdToDelete) {
        console.log('docIdToDelete ', docIdToDelete)
        deleteDocRecord({ docDtlId: docIdToDelete })
            .then((result) => {
                console.log(result);
                this.showToast("Success", "success", this.customLabel.UploadDocDisply_Del_SuccessMessage, "sticky");
                console.log('showtoast')
                this.handleFilesUploaded();
            })
            .catch((error) => {


            });
        this.deleteModel = false;
    }
    showToast(title, variant, message, mode) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
            mode: mode
        });
        this.dispatchEvent(evt);
    }


    handleCloseModalEvent(event) {
        this._Technical = false;
        this.showModalForFilePre = false;
    }

    //******************FOR HANDLING THE HORIZONTAL SCROLL OF TABLE MANUALLY******************//
    tableOuterDivScrolled(event) {
        this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
        if (this._tableViewInnerDiv) {
            if (!this._tableViewInnerDivOffsetWidth || this._tableViewInnerDivOffsetWidth === 0) {
                this._tableViewInnerDivOffsetWidth = this._tableViewInnerDiv.offsetWidth;
            }
            this._tableViewInnerDiv.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth) + "px;" + this.tableBodyStyle;
        }
        this.tableScrolled(event);
    }

    tableScrolled(event) {
        if (this.enableInfiniteScrolling) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('showmorerecords', {
                    bubbles: true
                }));
            }
        }
        if (this.enableBatchLoading) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('shownextbatch', {
                    bubbles: true
                }));
            }
        }
    }
    //******************************* RESIZABLE COLUMNS *************************************//
    handlemouseup(e) {
        this._tableThColumn = undefined;
        this._tableThInnerDiv = undefined;
        this._pageX = undefined;
        this._tableThWidth = undefined;
    }

    handlemousedown(e) {
        if (!this._initWidths) {
            this._initWidths = [];
            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            tableThs.forEach(th => {
                this._initWidths.push(th.style.width);
            });
        }

        this._tableThColumn = e.target.parentElement;
        this._tableThInnerDiv = e.target.parentElement;
        while (this._tableThColumn.tagName !== "TH") {
            this._tableThColumn = this._tableThColumn.parentNode;
        }
        while (!this._tableThInnerDiv.className.includes("slds-cell-fixed")) {
            this._tableThInnerDiv = this._tableThInnerDiv.parentNode;
        }
        console.log("handlemousedown._tableThColumn.tagName => ", this._tableThColumn.tagName);
        this._pageX = e.pageX;

        this._padding = this.paddingDiff(this._tableThColumn);

        this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
        console.log("handlemousedown._tableThColumn.tagName => ", this._tableThColumn.tagName);
    }

    handlemousemove(e) {
        // console.log("mousemove._tableThColumn => ", this._tableThColumn);
        if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
            this._diffX = e.pageX - this._pageX;

            this.template.querySelector("table").style.width = (this.template.querySelector("table") - (this._diffX)) + 'px';

            this._tableThColumn.style.width = (this._tableThWidth + this._diffX) + 'px';
            this._tableThInnerDiv.style.width = this._tableThColumn.style.width;

            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            let tableBodyRows = this.template.querySelectorAll("table tbody tr");
            let tableBodyTds = this.template.querySelectorAll("table tbody .dv-dynamic-width");
            tableBodyRows.forEach(row => {
                let rowTds = row.querySelectorAll(".dv-dynamic-width");
                rowTds.forEach((td, ind) => {
                    rowTds[ind].style.width = tableThs[ind].style.width;
                });
            });
        }
    }

    handledblclickresizable() {
        let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
        let tableBodyRows = this.template.querySelectorAll("table tbody tr");
        tableThs.forEach((th, ind) => {
            th.style.width = this._initWidths[ind];
            th.querySelector(".slds-cell-fixed").style.width = this._initWidths[ind];
        });
        tableBodyRows.forEach(row => {
            let rowTds = row.querySelectorAll(".dv-dynamic-width");
            rowTds.forEach((td, ind) => {
                rowTds[ind].style.width = this._initWidths[ind];
            });
        });
    }

    paddingDiff(col) {

        if (this.getStyleVal(col, 'box-sizing') === 'border-box') {
            return 0;
        }

        this._padLeft = this.getStyleVal(col, 'padding-left');
        this._padRight = this.getStyleVal(col, 'padding-right');
        return (parseInt(this._padLeft, 10) + parseInt(this._padRight, 10));

    }

    getStyleVal(elm, css) {
        return (window.getComputedStyle(elm, null).getPropertyValue(css))
    }
}