import { LightningElement, api, track, wire } from 'lwc';

import OSV from "@salesforce/schema/DocDtl__c.OSV__c";
import FILE_AVAILABLE from "@salesforce/schema/DocDtl__c.FileAvalbl__c";

import deleteDocDet from "@salesforce/apex/FileUploadController.deleteDocDetail";
import fetchId from "@salesforce/apex/FileUploadController.fetchId";
import getUiTheme from "@salesforce/apex/UiThemeController.getUiTheme";
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { deleteRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";

import communityUrl from '@salesforce/label/c.community_Url'
import formFactorPropertyName from "@salesforce/client/formFactor";

import { updateRecord } from "lightning/uiRecordApi";

//LMS Subscribe
import { subscribe, MessageContext } from 'lightning/messageService';
import SaveBtnChannel from "@salesforce/messageChannel/SaveBtnChannel__c";
// Custom labels
import UploadDocDisply_Del_SuccessMessage from '@salesforce/label/c.UploadDocDisply_Del_SuccessMessage';
import UploadDocDisply_Upload_SuccessMessage from '@salesforce/label/c.UploadDocDisply_Upload_SuccessMessage';
import UploadDocDisply_Remarks_SuccessMessage from '@salesforce/label/c.UploadDocDisply_Remarks_SuccessMessage';
import UploadDocDisply_Remarks_ErrorMessage from '@salesforce/label/c.UploadDocDisply_Remarks_ErrorMessage';

export default class UplodedDocumentDisplay extends NavigationMixin(LightningElement) {
    customLabel = {
        UploadDocDisply_Del_SuccessMessage,
        UploadDocDisply_Upload_SuccessMessage,
        UploadDocDisply_Remarks_SuccessMessage,
        UploadDocDisply_Remarks_ErrorMessage

    }

    @api type;// = ['Identity Proof'];
    @api subType = [];
    @api category;// = ['KYC Documents'];
    @api applicantId;// = 'a0AC4000000EYEjMAO';
    @api mode = false; z
    @track modeDis = true;
    @api isReadOnly;
    @api captureAllDocuments = false;
    @api disabled;
    @api isCpa = false;
    @track allowedFilFormat = -['.pdf', '.png', '.jpeg', '.jpg'];
    @track selectedRecordIds = [];//LAK-2764
    @api records;

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpeg', '.jpg'];
    }

    @track _loanAppId;

    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        this.handleRecordIdChange(value);
    }


    @track lstAllFiles = [];
    @track formFactor = formFactorPropertyName;
    desktopBoolean = false;
    phoneBolean = false;
    @track themeType
    @track isModalOpen = false;
    @track docIdToDelete;
    @track cdlIdToDelete;
    @track removeModalMessage = "Do you want to delete the document ?";
    @track documentId;
    @track showUploadModal = false;
    @track showSpinnerChild = false;
    @track isReturnToRM = false;
    @track returnToRmMessage;
    @track cpahandlename;
    @track disableRemaPrelogin = false;
    // @track showSpinner =false;

    @track wiredLoanData = {};
    @track rmSMName;
    @track
    paramsLoanApp = {
        ParentObjectName: 'LoanAppl__c',
        parentObjFields: ['RMSMName__c', 'SubStage__c'],
        queryCriteria: ' where id = \'' + this.loanAppId + '\''
    }
    /*fixedWidth = "width:15rem";//LAK-2571
     enableInfiniteScrolling = true; //LAK-2571
    enableBatchLoading = true; //LAK-2571
    _tableThColumn;
    _tableThInnerDiv;
    _pageX;
    _tableThWidth;
    _initWidths; */

    handleRecordIdChange() {
        let paramLoanappTemp = this.paramsLoanApp;
        paramLoanappTemp.queryCriteria = ' where id = \'' + this.loanAppId + '\''
        this.paramsLoanApp = { ...paramLoanappTemp };
    }

    @wire(getSobjectDatawithRelatedRecords, { params: '$paramsLoanApp' })
    handleAppKyc(result) {
        this.wiredLoanData = result;
        if (result.data) {
            console.log('Loan app data=', result.data);
            if (result.data.parentRecord) {
                //  this.loanAppId = result.data.parentRecord.Id;
                this.rmSMName = result.data.parentRecord.RMSMName__c;
                if (result.data.parentRecord.SubStage__c == 'Pre login Query') {
                    this.disableRemaPrelogin = true;
                } else {
                    this.disableRemaPrelogin = false;
                }
            }

        }
        if (result.error) {
            console.error('Loan app error=', result.error);
        }
    }
    connectedCallback() {
        // this.sunscribeToMessageChannel();
        console.log('isReadOnly in display compoennt ', this.isReadOnly);
   
        getUiTheme()
            .then((result) => {
                console.log('result for theme is=>>>>>', result);
                this.themeType = result;
            })
            .catch((error) => {

            });
        console.log("Form Factor Property Name ", this.formFactor);
        console.log("formFactorPropertyName ", formFactorPropertyName);
        if (this.formFactor == "Large") {
            this.desktopBoolean = true;
            this.phoneBolean = false;
        } else if (this.formFactor == "Small") {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        } else {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        }
        this.handleFilesUploaded();
    }
    @api handleFilesUploaded() {

        console.log(" handle file upload called applicantId:", this.applicantId, "category : ", this.category, " docType: ", this.type, " subType : ", this.subType);
        fetchId({ applicantId: this.applicantId, category: this.category, docType: this.type, subType: this.subType })
            .then((result) => {
                console.log('fetchId class result ::', result);
                //this.lstAllFiles = result;
                this.lstAllFiles = [{avaiableInFileReq:true,availableInFile:false,cDcrtdDate:"25-09-2023  16:58",cDFileType:"PDF",cDId:"069C4000001QmwTIAS",cdlId:"06AC4000001Sb2UMAS",cvId:"068C4000001RXybIAG",docDetName:"Electricity Bill",docDetType:"Residence Address proof - Deemed OVD",docId:"a0YC4000000H28fMAC",LinkedEntityId:"a0YC4000000H28fMAC",markForError:false,osv:true,osvReq:true,renderRemarks:true,},
                {avaiableInFileReq:true,"availableInFile":false,cDcrtdDate:"03-10-2023  18:49",cDFileType:"PDF",cDId:"069C4000001W8ujIAC",cdlId:"06AC4000001Y0ZiMAK",cvId:"068C4000001WumTIAS",docDetName:"Property or Municipal tax receipt",docDetType:"Residence Address proof - Deemed OVD",docId:"a0YC4000000HM7NMAW",LinkedEntityId:"a0YC4000000HM7NMAW",markForError:false,osv:false,osvReq:true,renderRemarks:true}];

                this.lstAllFiles.forEach(item => {
                    if (item.markForError == true) {
                        item['renderRemarks'] = false;
                    } else {
                        item['renderRemarks'] = true;
                    }
                })
                console.log(
                    "lstAllFiles before==>",
                    this.docType,
                    " -<-DT--  ",
                    this.applicantId,
                    "  --<-appid---",
                    JSON.stringify(this.lstAllFiles)
                );
                // detail:{fileList: this.lstAllFiles, spinnerStatue: false} 
                let selectEvent = new CustomEvent('uploadeddoc', {
                    detail: this.lstAllFiles
                });
                // Fire the custom event
                this.dispatchEvent(selectEvent);
                this.error = undefined;
                //this.handleSpinner();
                //  this.showSpinnerChild = false;

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



    handleRemoveRecord() {
        console.log('cdlIdToDelete in popo yes', this.cdlIdToDelete);
        console.log('docIdToDelete in popo up yes ', this.docIdToDelete);
        this.showSpinner = true;
        if (this.cdlIdToDelete) {
            deleteRecord(this.cdlIdToDelete)
                .then(() => {
                    this.deleteDocDet(this.docIdToDelete);
                    const toastEvent = new ShowToastEvent({

                        message: this.customLabel.UploadDocDisply_Del_SuccessMessage,
                        variant: "success"
                    });
                    this.dispatchEvent(toastEvent);
                    this.lstAllFiles = [];
                    this.showSpinner = false;
                    // this.handleFilesUploaded();
                })
                .catch((error) => {
                    this.showSpinner = false;
                    window.console.log(
                        "Unable to delete record due to " + error.body.message
                    );
                });
        } else {
            this.deleteDocDet(this.docIdToDelete);
            const toastEvent = new ShowToastEvent({

                message: this.customLabel.UploadDocDisply_Del_SuccessMessage,
                variant: "success"
            });
            this.dispatchEvent(toastEvent);
            this.showSpinner = false;
        }

    }
    closeModal() {
        console.log('isModalOpen ', this.isModalOpen);
        this.isModalOpen = false;
    }
    handleDocumentDelete(event) {

        console.log(event.target.dataset.id);
        let cdToDelete = event.currentTarget.dataset.id; // to delete individual file
        this.docIdToDelete = event.currentTarget.dataset.documentid;
        this.cdlIdToDelete = event.currentTarget.dataset.cdlid;
        // let param = event.target.dataset.fileIterator;
        this.isModalOpen = true;
        console.log("dd to delete " + this.cdlIdToDelete);


        // const result = await LightningConfirm.open({
        //     message: 'Do you want to delete the document ?',
        //     variant: 'headerless',
        //     label: 'Do you want to delete the document ?',
        // });
        // console.log('result from confirm is', result);
        // if (!result) {
        //     return;
        // }
        console.log('handle document delete');

        console.log("deelte Called");


        // if (cdlIdToDelete) {
        //     deleteRecord(cdlIdToDelete)
        //         .then(() => {
        //             this.deleteDocDet(docIdToDelete);
        //             const toastEvent = new ShowToastEvent({
        //                 title: "Record Deleted",
        //                 message: "Record deleted successfully",
        //                 variant: "success"
        //             });
        //             this.dispatchEvent(toastEvent);
        //             this.lstAllFiles = [];
        //             // this.handleFilesUploaded();
        //         })
        //         .catch((error) => {
        //             window.console.log(
        //                 "Unable to delete record due to " + error.body.message
        //             );
        //         });
        // } else {
        //     this.deleteDocDet(docIdToDelete);
        //     const toastEvent = new ShowToastEvent({
        //         title: "Record Deleted",
        //         message: "Record deleted successfully",
        //         variant: "success"
        //     });
        //     this.dispatchEvent(toastEvent);

        // }


        // console.log('param after delete ', JSON.stringify(param));
        // const selectEvent = new CustomEvent('click', {
        //     detail: param
        // });
        // this.dispatchEvent(selectEvent);

    }

    deleteDocDet(docIdToDelete) {
        console.log('docIdToDelete ', docIdToDelete)
        deleteDocDet({ docId: docIdToDelete })
            .then((result) => {
                console.log(result);
                this.handleFilesUploaded();
            })
            .catch((error) => { });
        this.isModalOpen = false;
    }


    showModal = false;
    showFrame = false;
    url;
    contDocId;
    cvId;
    showModalForFilePre;
    contDocType
    url
    imageTypeFileUrl
    handleDocumentView(event) {
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
        /*console.log('communityUrl ', communityUrl);
        if (this.themeType == 'Theme4d') {
            console.log('inside salesforce');
            this[NavigationMixin.Navigate]({
                type: "standard__namedPage",
                attributes: {
                    pageName: "filePreview"
                },
                state: {
                    selectedRecordId: this.contDocId
                }
            });
        } else {
            console.log('inside portal', communityUrl + 'LOS/s/contentdocument/' + this.contDocId);
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    //"https://los-accelerator-dev-ed.develop.my.site.com/s/contentdocument/"
                    url: communityUrl + 'LOS/s/contentdocument/' + this.contDocId
                    //url: communityUrl + 'LOS/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + this.cvId
                },
                state: {
                    selectedRecordId: this.contDocId
                }
            });
        }*/
    }




    //showModal = false;

    openModal() {
        this.showModal = true;
    }

    // closeModal() {
    //     this.showModal = false;
    // }



    handleOsvClick(event) {
        this.showSpinnerChild = true;
        let val = event.target.checked;
        let docDetId = event.currentTarget.dataset.documentid;
        console.log('value and document detail id is===>>>>>>', docDetId, val)

        const docDetFields = {};
        docDetFields[OSV.fieldApiName] = val;
        docDetFields['Id'] = docDetId;
        const recordInput = {
            fields: docDetFields
        };
        updateRecord(recordInput).then((record) => {
            console.log(" document detail record updated ", record);
            this.handleFilesUploaded();
        });

    }

    handleForwardClicked(event) {
        console.log('fileIterator in parent', event.detail)
        let param = {
            fileIterator: event.detail
        }
        console.log('param in parent', param)
        const selectEvent = new CustomEvent('click', {
            detail: param
        });
        this.dispatchEvent(selectEvent);
    }

    handleCloseModalEvent(event) {
        this.showModalForFilePre = false;
    }


    handleFileUpload(event) {
        this.documentId = event.currentTarget.dataset.documentid;

        this.showUploadModal = true;
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.showUploadModal = false;
        const evt = new ShowToastEvent({
            title: 'Success',
            variant: 'success',
            message: this.customLabel.UploadDocDisply_Upload_SuccessMessage
        });
        this.dispatchEvent(evt);
        this.handleFilesUploaded();



    }

    closeUploadModal() {
        this.showUploadModal = false;
    }


    handleAvailableFile(event) {
        this.showSpinnerChild = true;
        let val = event.target.checked;
        let docDetId = event.currentTarget.dataset.documentid;
        console.log('value and document detail id is===>>>>>>', docDetId, val)

        const docDetFields = {};
        docDetFields[FILE_AVAILABLE.fieldApiName] = val;
        docDetFields['Id'] = docDetId;
        const recordInput = {
            fields: docDetFields
        };
        updateRecord(recordInput).then((record) => {
            console.log(" document detail record updated ", record);
        });
        this.handleFilesUploaded();
    }

    childRecords = [];
    hanldeMarkForError(event) {
        if (this.formFactor == "Large") {
            this.desktopBoolean = false;
        } else if (this.formFactor == "Small") {
            this.phoneBolean = false;
        } else {
            this.phoneBolean = false;
        }

        this.showSpinnerChild = true;
        let val = event.target.checked;
        let docDetId = event.currentTarget.dataset.documentid;

        console.log('mark for error checked or not ==> ', val, event.target.checked);

        let addMArksForError = {};

        let searchDoc = this.childRecords.find((doc) => doc.Id == docDetId);
        if (searchDoc) {
            console.log('searchDoc', searchDoc);
            searchDoc['MrkErr__c'] = val;

        } else {
            addMArksForError['Id'] = docDetId;
            addMArksForError['MrkErr__c'] = val;
            this.childRecords.push(addMArksForError);
        }

        console.log('childRecords ', JSON.stringify(this.childRecords));


        this.lstAllFiles.forEach(item => {
            if (item.docId === docDetId) {
                item.renderRemarks = !val;
            }
        })
        this.showSpinnerChild = false;
        if (this.formFactor == "Large") {
            this.desktopBoolean = true;
        } else if (this.formFactor == "Small") {
            this.phoneBolean = true;
        } else {
            this.phoneBolean = true;
        }
    }
    handleRemarks(event) {
        let val = event.target.value;
        let docDetId = event.currentTarget.dataset.documentid;
        console.log('remarks value ', val, event.target.value + ':::::::::::doc id', docDetId);
        let addRemarks = {};
        let searchDoc = this.childRecords.find((doc) => doc.Id == docDetId);
        if (searchDoc) {
            searchDoc['Rmrk__c'] = val;

        } else {
            addRemarks['Id'] = docDetId;
            addRemarks['Rmrk__c'] = val;
            this.childRecords.push(addRemarks);
        }

        console.log('childRecords ', JSON.stringify(this.childRecords));
    }



    // get rmMsg() {
    //     return this.returnToRmMessage ? this.returnToRmMessage : '';
    // }
    // get rmName() {
    //     return this.cpahandlename ? this.cpahandlename : '';
    // }
    // closeModalCPA() {
    //     console.log('close modal cpa called');
    //     this.isReturnToRM = false;
    // }


    // @api handleReturntoRm() {
    //     this.showSpinnerChild = true;
    //     this.cpahandlename = 'Return to RM';
    //     this.returnToRmMessage = "Do you want to return this Application to RM?";
    //     this.showSpinnerChild = false;
    //     this.isReturnToRM = true;

    // }
    // @api handleFileAcceptance() {
    //     this.showSpinnerChild = true;
    //     this.cpahandlename = 'File Acceptance';
    //     this.returnToRmMessage = "Are You Sure, You Want to File Acceptance ?   ";
    //     this.showSpinnerChild = false;
    //     this.isReturnToRM = true;
    // }

    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(evt);
    }
    @api updateRemarks() {
        this.showSpinnerChild = true;

        let parentRecord = {};
        parentRecord['Id'] = this.loanAppId;
        // parentRecord.sobjectType = 'LoanAppl__c';
        // parentRecord['SubStage__c'] = 'Pre login Query';
        // parentRecord['OwnerId'] = this.rmSMName ? this.rmSMName : '';
        // parentRecord['CPASubSt__c'] = 'FTNR';

        let upsertData = {
            parentRecord: parentRecord,
            ChildRecords: this.childRecords,
            ParentFieldNameToUpdate: ''
        }
        console.log('upsertData ==>', JSON.stringify(upsertData));

        upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
            .then(result => {
                this.showSpinnerChild = false;
                this.showToast("Success", "success", this.customLabel.UploadDocDisply_Remarks_SuccessMessage);
            }).catch(error => {
                this.showSpinnerChild = false;
                this.showToast("Error", "error",  error.body.message);
                console.log(error);

            })
    }
    @api showSpinnerInChild(event) {
        console.log('called by parent showSpinner', event);
        this.showSpinnerChild = event;
    }

// LAK-2764 - Select all rows
/*handleSelectAll(event) {
    let selectedRows = this.template.querySelectorAll('lightning-input');
    for(let i = 0; i < selectedRows.length; i++) {
        if(selectedRows[i].type === 'checkbox') {
            selectedRows[i].checked = event.target.checked;
        }
    }
}*/
// LAK-2764 - Select all rows
    handleSelectAll(event) {
        //this.showSpinnerChild = true;
        //let val = event.target.checked;
        let selectedRows = this.template.querySelectorAll('lightning-input');
        for (let i = 0; i < selectedRows.length; i++) {
            if (selectedRows[i].type === 'checkbox') {
                selectedRows[i].checked = event.target.checked;
            }
        }
    }

    checkboxHandler(event) {
        const recordId = event.currentTarget.dataset.id;
        const isChecked = event.target.checked;
        console.log("inside handleSelectAll ==> " + isChecked);
        if(isChecked){
            this.selectedRecordIds.push(recordId);
        }
        else{
            this.selectedRecordIds = this.selectedRecordIds.filter(id => id !== recordId);
        }
        this.updateRecordField(recordId, isChecked);
        console.log("updateRecordField ==> " + recordId);
        console.log("selectedRecordIds ==> " + event.target.checked);
    }
        /* this.selectedRows = [];
        const isChecked = event.target.checked;
        const checkboxes = this.template.querySelectorAll('input[type="checkbox"][data-row-checkbox]');
        checkboxes.forEach(checkbox => {
            if(isChecked){
                this.selectedRows.push(checkbox.value);
            }
        });*/
    
    //LAK-2764
    async updateRecordField(recordId, isChecked){
        const fields = {};
        fields['Id'] = recordId;
        fields[OSV.fieldApiName] = isChecked;

        const recordInput = {fields};

        try{
            await updateRecord(recordInput);
        }catch(error){}
    }
    // changeSubstagetoPloginQu(event) {
    //     this.showSpinnerChild = true;
    //     this.isReturnToRM = false;
    //     let name = event.target.dataset.name;
    //     if (name == 'Return to RM') {
    //         console.log('rmSMName==>>>>>>>', this.rmSMName);
    //         // this.childRecords.forEach(item => {
    //         //     item['sobjectType'] = 'DocDtl__c';
    //         // })
    //         let parentRecord = {};
    //         parentRecord['Id'] = this.loanAppId;
    //         parentRecord.sobjectType = 'LoanAppl__c';
    //         parentRecord['SubStage__c'] = 'Pre login Query';
    //         parentRecord['OwnerId'] = this.rmSMName ? this.rmSMName : '';
    //         parentRecord['CPASubSt__c'] = 'FTNR';

    //         let upsertData = {
    //             parentRecord: parentRecord,
    //             ChildRecords: null,
    //             ParentFieldNameToUpdate: ''
    //         }
    //         console.log('upsertData ==>', JSON.stringify(upsertData));

    //         upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
    //             .then(result => {
    //                 this.showSpinnerChild = false;
    //                 this.showToast("Success", "success", "Loan Submitted to RM Successfully");
    //             }).catch(error => {
    //                 this.showSpinnerChild = false;
    //                 this.showToast("Error", "error", "Error occured in Updating Owner  " + error.message);
    //                 console.log(error);
    //             })
    //     }
    //     if (name == 'File Acceptance') {
    //         this.showSpinnerChild = true;

    //         let loanAppFields = {};
    //         loanAppFields['Id'] = this.loanAppId;
    //         loanAppFields['FileAcceptance__c'] = true;
    //         let dt = new Date().toISOString().substring(0, 10);
    //         console.log('current date ISO is===>>>>>>>', dt);
    //         loanAppFields['FileAcceptDate__c'] = dt;

    //         let upsertDataFile = {
    //             parentRecord: loanAppFields,
    //             ChildRecords: null,
    //             ParentFieldNameToUpdate: ''
    //         }
    //         console.log('upsertData ==>', JSON.stringify(upsertDataFile));

    //         upsertSobjDataWIthRelatedChilds({ upsertData: upsertDataFile })
    //             .then(result => {
    //                 this.showSpinnerChild = false;
    //                 this.showToast("Success", "success", "Files Accepted Successfully!");
    //             }).catch(error => {
    //                 this.showSpinnerChild = false;
    //                 this.showToast("Error", "error", "Error occured in accepting File  " + error.message);
    //                 console.log(error);
    //             })
    //     }
    // }

    //LAK-2571
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
        console.log("mousemove._tableThColumn => ", this._tableThColumn);
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

    /* handleSelectAll(event){
        this.selectedRows
        const isChecked = event.target.checked;
        const checkboxes = this.template.querySelectorAll('input[type="checkbox"][data-row-checkbox]');
        checkboxes.forEach(checkbox =>{
            checkbox.checked = isChecked;
        })
    } */
}