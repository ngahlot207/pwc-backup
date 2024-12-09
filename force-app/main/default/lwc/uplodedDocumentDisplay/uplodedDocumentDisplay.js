import { LightningElement, api, track, wire } from 'lwc';

import OSV from "@salesforce/schema/DocDtl__c.OSV__c";
import FILE_AVAILABLE from "@salesforce/schema/DocDtl__c.FileAvalbl__c";

import deleteDocDet from "@salesforce/apex/FileUploadController.deleteDocDetail";
import fetchId from "@salesforce/apex/FileUploadController.fetchId";
import getUiTheme from "@salesforce/apex/UiThemeController.getUiTheme";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import deleteDocRecord from '@salesforce/apex/DocumentDetailController.deleteDocDetWithCdl';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { deleteRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";


import communityUrl from '@salesforce/label/c.community_Url'
import formFactorPropertyName from "@salesforce/client/formFactor";

import { updateRecord, getRecord, getFieldValue } from "lightning/uiRecordApi";

//LMS Subscribe
import { subscribe, MessageContext } from 'lightning/messageService';
import SaveBtnChannel from "@salesforce/messageChannel/SaveBtnChannel__c";
// Custom labels
import UploadDocDisply_Del_SuccessMessage from '@salesforce/label/c.UploadDocDisply_Del_SuccessMessage';
import UploadDocDisply_Upload_SuccessMessage from '@salesforce/label/c.UploadDocDisply_Upload_SuccessMessage';
import UploadDocDisply_Remarks_SuccessMessage from '@salesforce/label/c.UploadDocDisply_Remarks_SuccessMessage';
import UploadDocDisply_OSV_ErrorMessage from '@salesforce/label/c.UploadDocDisply_OSV_ErrorMessage';
import UploadDocDisply_Remarks_ErrorMessage from '@salesforce/label/c.UploadDocDisply_Remarks_ErrorMessage';

export default class UplodedDocumentDisplay extends NavigationMixin(LightningElement) {

    customLabel = {
        UploadDocDisply_Del_SuccessMessage,
        UploadDocDisply_Upload_SuccessMessage,
        UploadDocDisply_Remarks_SuccessMessage,
        UploadDocDisply_OSV_ErrorMessage,
        UploadDocDisply_Remarks_ErrorMessage

    }
    
    @api type;// = ['Identity Proof'];
    @api subType = [];
    @api category;// = ['KYC Documents'];
    @api applicantId;// = 'a0AC4000000EYEjMAO';
    @api mode = false;
    @api disableRemarks = false;
    @track modeDis = true;
    @api isReadOnly;
    @api captureAllDocuments = false;
    @api disabled = false;
    @api isCpa = false;
    @api hideAvailiableInFile = false;
    @api hideMarkForError = false;
    @api hideUploadButton = false;
    @api hasEditAccess;
    @api showUtilityBillDate = false;
    @api showEstablishmentDate = false;
    @api showDocData = false;
    @track allowedFilFormat = -['.pdf', '.png', '.jpeg', '.jpg'];
    checkAllValue = false; //LAK-2764

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
    // @track removeModalMessage = "Do you want to delete the document ?";
    @track removeModalMessage = "Do you really want to delete this file";
    @track documentId;
    @track showUploadModal = false;
    @track showSpinnerChild = false;
    @track isReturnToRM = false;
    @track returnToRmMessage;
    @track cpahandlename;
    @track disableRemaPrelogin = false;
    //@track showSpinner =false;
    @api title = 'Uploaded Files';
    @track wiredLoanData = {};
    @track rmSMName;
    @api ispankycstep = false;
    @track fileAccDele;
    @track loanSubStageDel;
    @track loanStageDel;
    //LAK-3223
    @api isNotRm;

    paramsLoanApp = {
        ParentObjectName: 'LoanAppl__c',
        parentObjFields: ['RMSMName__c', 'SubStage__c', 'FileAcceptance__c', 'Stage__c'],
        queryCriteria: ' where id = \'' + this.loanAppId + '\''
    }

    handleRecordIdChange() {
        let paramLoanappTemp = this.paramsLoanApp;
        paramLoanappTemp.queryCriteria = ' where id = \'' + this.loanAppId + '\''
        this.paramsLoanApp = { ...paramLoanappTemp };
    }

    @wire(getSobjectDatawithRelatedRecords, { params: '$paramsLoanApp' })
    handleAppKyc(result) {
        this.wiredLoanData = result;
        if (result.data) {
            if (result.data.parentRecord) {
                this.rmSMName = result.data.parentRecord.RMSMName__c;
                this.loanStageDel = result.data.parentRecord.Stage__c;
                this.loanSubStageDel = result.data.parentRecord.SubStage__c;
                this.fileAccDele = result.data.parentRecord.FileAcceptance__c;
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
        debugger;
        if (this.hasEditAccess === false) {

            this.modeDis = true;
            this.disabled = true;
            this.isReadOnly = true;
            this.isCpa = true;

        }

        console.log('isReadOnly in display compoennt ', this.isReadOnly);
        console.log('checking disabledUpl', this.disabledUpl);

        getUiTheme()
            .then((result) => {
               
                this.themeType = result;
            })
            .catch((error) => {

            });
        
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
        this.handleFilesUploaded("cc");
    }
    get disableDeleteBu() {
        let tempBool;
        if (this.loanSubStageDel == 'Additional Data Entry' && this.loanStageDel == 'QDE') {
            if (this.fileAccDele) {
                tempBool = this.disabled;
            } else {
                tempBool = true;
            }
        } else {
            tempBool = this.disabled;
        }
        return tempBool;
    }
    @api handleFilesUploaded(useFor) {

        fetchId({ applicantId: this.applicantId, category: this.category, docType: this.type, subType: this.subType })
            .then((result) => {

                this.lstAllFiles = result;
                console.log('this.lstAllFiles',JSON.stringify(this.lstAllFiles))
                let checkOCVAll = true;
                if (this.lstAllFiles && this.lstAllFiles.length > 0) {

                    this.lstAllFiles.forEach(item => {
                        if (item.markForError == true) {
                            item['renderRemarks'] = false;
                        } else {
                            item['renderRemarks'] = true;
                        }

                        if (item.osv == false) {
                            checkOCVAll = false
                        }
                    })

                    ///LAK-5588
                    this.lstAllFiles.forEach(item => {
                        if(item.cDcrtdDate){
                        item.cDcrtdDate = this.dateAndTimeFormat(item.cDcrtdDate);
                        }
                    })
                    this.lstAllFiles.forEach(item => {
                        if(item.cDUtilBillDate){
                        item.cDUtilBillDate = this.dateFormat(item.cDUtilBillDate);
                        }
                    })

                    this.lstAllFiles.forEach(item => {
                        if(item.dobOnDoc){
                        item.dobOnDoc = this.dateFormat(item.dobOnDoc);
                        }
                    })

                    this.lstAllFiles.forEach(item => {
                        if(item.cDEstablishmentDate){
                        item.cDEstablishmentDate = this.dateFormat(item.cDEstablishmentDate);
                        }
                    })
                    
                    
                    ///LAK-5588

                    
                    let selectEvent = new CustomEvent('uploadeddoc', {
                        detail: this.lstAllFiles,
                        composed: true,
                        bubbles: true
                    });
                    selectEvent.usedIn = useFor;
                    // Fire the custom event
                    this.dispatchEvent(selectEvent);
                    this.error = undefined;
                    


                    
                }
                this.checkAllValue = checkOCVAll;
               
                this.showSpinnerChild = false;
                //added for Multiple File Upload
                // if (item.docCategory == 'KYC Documents' || item.docCategory == 'PAN Documents') {
                //     item['showupload'] = false;
                // } else {
                //     item['showupload'] = true;
                // }

                // detail:{fileList: this.lstAllFiles, spinnerStatue: false} 

            })
            .catch((error) => {
                this.error = error;
                this.lstAllFiles = undefined;
                this.showSpinnerChild = false;
                console.log("error occured in fetchId", this.error);
                console.log("handlefileUploaded");
            });
    }

    ///LAK-5588 Return Data and Time in DD-MMM-YYYY format
    dateAndTimeFormat(DateAndTimeValue){
        
        const [datePart, timePart, meridianPart] = DateAndTimeValue.split(' ');
        const [day, month, year] = datePart.split('-');
        const monthAbbreviation = new Date(Date.parse(`${month}/01/2000`)).toLocaleString('en-us', { month: 'short' });
        const formattedDate = `${day}-${monthAbbreviation}-${year} ${timePart} ${meridianPart}`;
        console.log(formattedDate);
        return formattedDate;
    }

    ///LAK-5588 Return Data in DD-MMM-YYYY format
    dateFormat(DateValue){
        
        const [day, month, year] = DateValue.split('-');
        const monthAbbreviation = new Date(Date.parse(`${month}/01/2000`)).toLocaleString('en-us', { month: 'short' });
        const formattedDate = `${day}-${monthAbbreviation}-${year}`;
        console.log(formattedDate);
        return formattedDate;
    }

    handleRemoveRecord() {
        
        this.showSpinnerChild = true;
        
        this.deleteDocDet(this.docIdToDelete);


    }
    closeModal() {
        console.log('isModalOpen ', this.isModalOpen);
        this.isModalOpen = false;
    }
    handleDocumentDelete(event) {
        let cdToDelete = event.currentTarget.dataset.id; // to delete individual file
        this.docIdToDelete = event.currentTarget.dataset.documentid;
        this.cdlIdToDelete = event.currentTarget.dataset.cdlid;
        // let param = event.target.dataset.fileIterator;
        let params = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'SanctionStage__c'],
            queryCriteria: ' where Id = \'' + this.docIdToDelete + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('result>> '+JSON.stringify(result));
                if(this.loanStageDel == 'QDE' || this.loanStageDel == 'DDE' || this.loanStageDel == 'UnderWriting'){
                    this.isModalOpen = true;
                } else{
                    if(result.parentRecords[0].SanctionStage__c == 'post sanction'){
                        this.isModalOpen = true;
                    }else{
                        this.isModalOpen = false;
                        let errorMessage = 'You cannot delete this file';
                        this.showToast("Error", "error", errorMessage, "sticky");
                    }
                }
            });
        


        console.log('handle document delete');

        console.log("delete Called");



    }

    deleteDocDet(docIdToDelete) {
        
        deleteDocRecord({ docDtlId: docIdToDelete })
            .then((result) => {
             
                this.showToast("Success", "success", this.customLabel.UploadDocDisply_Del_SuccessMessage, "stiky");
                

                this.handleFilesUploaded("dd");
            })
            .catch((error) => {
                window.console.log(
                    "Unable to delete document detail record " + error.body.message
                );
                this.showSpinnerChild = false;
            });
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
    @track documentDetailId;
    @track hasDocumentId;
    handleDocumentView(event) {
        debugger;
        this.contDocId = event.currentTarget.dataset.id;
        this.contDocType = event.currentTarget.dataset.type;
        this.cvId = event.currentTarget.dataset.cvId;
        this.documentDetailId = event.currentTarget.dataset.documentid
        this.hasDocumentId = true;
        this.showModalForFilePre = true;

        this.url = '/sfc/servlet.shepherd/document/download/' + this.contDocId;

    }



    openModal() {
        this.showModal = true;
    }

   

    handleOsvClick(event) {
        this.showSpinnerChild = true;
        let val = event.target.checked;
        let docDetId = event.currentTarget.dataset.documentid;
        try {
            let tempList = [];
            let firstBooleanCounter = true;
            let secondBooleanCounter = true;
            tempList = [...this.lstAllFiles];
            tempList.forEach(item => {
                if (item.docId === docDetId) {
                    item.osv = val;
                }
                if (item.osv == false) {
                    this.checkAllValue = false;
                    secondBooleanCounter = false;
                }
                if (item.osv == firstBooleanCounter && secondBooleanCounter) {
                    firstBooleanCounter == item.osv;
                    this.checkAllValue = firstBooleanCounter;
                }
            })
        } catch (error) {
            console.log('error==>' + error);
        }

        const docDetFields = {};
        docDetFields[OSV.fieldApiName] = val;
        docDetFields['Id'] = docDetId;
        const recordInput = {
            fields: docDetFields
        };
        updateRecord(recordInput).then((record) => {
            this.handleFilesUploaded("osv");
            
        })
            .catch(error => {
                this.showSpinnerChild = false;
                this.showToast("Error", "error", this.customLabel.UploadDocDisply_OSV_ErrorMessage, "sticky");
                console.log(error);

            })

    }

    handleForwardClicked(event) {
        debugger;
        let param = {
            fileIterator: event.detail
        }
        const selectEvent = new CustomEvent('click', {
            detail: param
        });
        console.log('>>>>>>>>>>>>>>>')
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
        this.showUploadModal = false;
        
        this.handleFilesUploaded("uf");
    }

    closeUploadModal() {
        this.showUploadModal = false;
    }


    handleAvailableFile(event) {
        this.showSpinnerChild = true;
        let val = event.target.checked;
        let docDetId = event.currentTarget.dataset.documentid;
        
        const docDetFields = {};
        docDetFields[FILE_AVAILABLE.fieldApiName] = val;
        docDetFields['Id'] = docDetId;
        const recordInput = {
            fields: docDetFields
        };
        updateRecord(recordInput).then((record) => {
            
        });
        this.handleFilesUploaded("afc");
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
            
            searchDoc['MrkErr__c'] = val;

        } else {
            addMArksForError['Id'] = docDetId;
            addMArksForError['MrkErr__c'] = val;
            this.childRecords.push(addMArksForError);
        }

       

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
        //LAK-3223
        let fieldName = event.currentTarget.dataset.id;
        console.log('remarks value ', val, event.target.value + ':::::::::::doc id', docDetId);
        let addRemarks = {};
        let searchDoc = this.childRecords.find((doc) => doc.Id == docDetId);
        if (fieldName === 'checkbox') {
            if (searchDoc) {
                searchDoc['Rmrk__c'] = val.toUpperCase();
                this.lstAllFiles.forEach(item => {
                    if (item.docId === docDetId) {
                        item.remarks = val.toUpperCase();
                    }
                })
            } else {
                addRemarks['Id'] = docDetId;
                addRemarks['Rmrk__c'] = val.toUpperCase();
                this.lstAllFiles.forEach(item => {
                    if (item.docId === docDetId) {
                        item.remarks = val.toUpperCase();
                    }
                })
                this.childRecords.push(addRemarks);
            }
        }
        else if (fieldName === 'rmRemarks') {
            let rmRemarStr = event.target.value;
            let rmRemarStrUpp = rmRemarStr.toUpperCase();

            if (searchDoc) {
                searchDoc['RM_Remarks__c'] = rmRemarStrUpp;
                this.lstAllFiles.forEach(item => {
                    if (item.docId === docDetId) {
                        item.rmRemarks = rmRemarStrUpp;
                    }
                })


            } else {
                addRemarks['Id'] = docDetId;
                addRemarks['RM_Remarks__c'] = rmRemarStrUpp;

                this.lstAllFiles.forEach(item => {
                    if (item.docId === docDetId) {
                        item.rmRemarks = rmRemarStrUpp;
                    }
                })

                this.childRecords.push(addRemarks);

            }
        }


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
    @api updateRemarks() {
        this.showSpinnerChild = true;


        if (this.childRecords.length > 0) {
            let parentRecord = {};
            parentRecord['Id'] = this.loanAppId;
            

            let upsertData = {
                parentRecord: parentRecord,
                ChildRecords: this.childRecords,
                ParentFieldNameToUpdate: ''
            }

            upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
                .then(result => {
                    this.showSpinnerChild = false;
                    this.childRecords = [];
                    this.showToast("Success", "success", this.customLabel.UploadDocDisply_Remarks_SuccessMessage, "sticky");
                }).catch(error => {
                    this.showSpinnerChild = false;
                    this.showToast("Error", "error", error.body.message, "sticky");
                    console.log(error);

                })
        }

        this.showSpinnerChild = false;



    }
    @api showSpinnerInChild(event) {
        this.showSpinnerChild = event;
    }
    

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
        console.log('735')
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
        this._pageX = e.pageX;

        this._padding = this.paddingDiff(this._tableThColumn);

        this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
    }

    handlemousemove(e) {
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

    // LAK-2764 - Select all rows
    handleSelectAll(event) {
        this.checkAllValue = event.target.checked;
        if (this.lstAllFiles.length) {
            this.showSpinnerChild = true;
            const isChecked = event.target.checked;
            console.log("inside handleSelectAll ==> " + isChecked);

            let selectedRows = this.template.querySelectorAll('lightning-input');
            for (let i = 0; i < selectedRows.length; i++) {
                if (selectedRows[i].type === 'checkbox') {
                    selectedRows[i].checked = event.target.checked;
                }
            }
            let tempRecs = [];
            this.lstAllFiles.forEach(item => {
                tempRecs.push({ Id: item.docId, sobjectType: 'DocDtl__c', OSV__c: event.target.checked });
            })
            if (tempRecs.length > 0) {
                upsertMultipleRecord({ params: tempRecs })
                    .then(result => {
                        let tempVar = true;
                        console.log('result==>' + result);
                        this.showSpinnerChild = false;
                    }).catch(error => {
                        console.log('error ==>>>' + error);
                    })
            }
        }

    }
}