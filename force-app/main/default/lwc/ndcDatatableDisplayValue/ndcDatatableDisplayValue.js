import { LightningElement, api, track } from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import getFilePreviewDataList from "@salesforce/apex/GetDocumentDetails.getFilePreviewDataList";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { format } from 'c/formatUtils';
// Custom labels
import NdcDataTable_Otc_ErrorMessage from '@salesforce/label/c.NdcDataTable_Otc_ErrorMessage';

export default class NdcDatatableDisplayValue extends LightningElement {
    customLabel = {
        NdcDataTable_Otc_ErrorMessage
    }
    @api queryEnable;
    @api recordData = {};
    // @api fieldName;
    // @api type;
    // @api label;
    // @api editable;
    @api readOnly = false;
    @api readOnlyNew = false;
    @api sectionName;
    @api saveData;
    @api col;
    @api employeRole;
    @api isCpaUser;
    @api isOpsUser;
    @api allDocsReceived;
    // @api opsVerifcation;
    @api ndcId;
    @api opsQuery;
    @api showOpsQuery;
    @api sobjectType;
    @api loanStage;
    @api loanSubstage;
    @api appAssetId;
    @api finnoneSubmitDate;
    @track _sectionName;

    @track disPhyFileRec;
    @track disPhyFileSend;
    // @api get sectionName() {
    //     if (this.col.type == 'preview') {
    //         this.getDocDetToPreview();
    //     }
    //     return this._sectionName;
    // }
    // set sectionName(value) {
    //     this._sectionName = value;
    //     this.setAttribute("sectionName", value);
    // }


    @track uploadedDocDetail = {};
    @track showUploadModal = false;
    @track cdId;
    @track cvId;
    @track url;
    @track fileType;
    @track queryRemBoolean = false;
    @track disableOopsVer = false;
    @track hasError = false;
    @track dateFieldValue;
    ndcCreatedDate;
    get fieldValue() {
        let fieldval;
        const myArray = this.col.fieldName.split(".");
        console.log('fieldName length ', myArray.length);

        if (myArray.length === 1) {
            console.log('fieldName', JSON.stringify(myArray));
            console.log('myArray[0]', myArray[0])
            if (myArray[0] === 'Date_of_Disbur__c' || myArray[0] === 'InstrumentDt__c') {
                //fieldval = this.recordData[myArray[0]];
                console.log('this.recordData[myArray[0]', this.recordData[myArray[0]])
                fieldval = this.dateFormat(this.recordData[myArray[0]]);

            }
            else if(myArray[0] === 'TransDt__c'){
                let dateTimeValue = this.recordData[myArray[0]];
    
                // Split the DateTime string to get only the date part
                if (dateTimeValue && dateTimeValue.includes('T')) {
                    const dateOnly = dateTimeValue.split('T')[0]; // Extract the date part before 'T'
                    console.log('Date extracted from DateTime:', dateOnly);
                    fieldval = this.dateFormat(dateOnly);
                } 
            }
            else {
                fieldval = this.recordData[myArray[0]];
            }
        } else if (myArray.length === 2) {
            if (this.recordData[myArray[0]]) {
                fieldval = this.recordData[myArray[0]][myArray[1]];
                console.log('myArray[2]', this.recordData[myArray[0]][myArray[1]])
            }
        }
        else if (myArray.length === 3) {
            if (this.recordData[myArray[0]][myArray[1]]) {
                fieldval = this.recordData[myArray[0]][myArray[1]][myArray[2]];
                console.log('myArray[3]', this.recordData[myArray[0]][myArray[1]])
            }
        }
        return fieldval;
    }

    get recordId() {
        return this.recordData.Id;
    }
    get disableRead() {
        if (this.recordData['OpsVer__c'] || this.readOnly) {
            return true;
        }
        return false;
    }


    ///LAK-5588 Return Data in DD-MMM-YYYY format
    dateFormat(DateValue) {
        if (DateValue) {
            const [year, month, day] = DateValue.split('-');
            const monthAbbreviation = new Date(Date.parse(`${month}/01/2000`)).toLocaleString('en-us', { month: 'short' });
            const formattedDate = `${day}-${monthAbbreviation}-${year}`;
            console.log(formattedDate);
            return formattedDate;
        }

    }

    get disableChecbox() {
        //Start added for LAK-6245
        if (this.col.fieldName === 'PhyFileSend__c' && this.loanStage === 'Disbursed' && (this.loanSubstage === 'Additional Processing' || this.loanSubstage === 'DI Check') && !this.isOpsUser && this.isCpaUser && !this.readOnlyNew && !this.allDocsReceived) {
            if (this.disPhyFileSend) {
                return true;
            }
            return false;
        } else if (this.col.fieldName === 'PhyFileSend__c' && this.loanStage === 'Disbursed' && (this.loanSubstage === 'Additional Processing' || this.loanSubstage === 'DI Check') && !this.isOpsUser && this.isCpaUser && !this.readOnlyNew && this.allDocsReceived) {
            if (this.disPhyFileSend) {
                return true;
            }
            return false;
        } else if (this.col.fieldName === 'PhyFileSend__c' && this.loanStage === 'Disbursed' && (this.loanSubstage === 'Additional Processing' || this.loanSubstage === 'DI Check') && this.isOpsUser && !this.isCpaUser) {
            return true;
        } else if (this.recordData['OpsVer__c'] || this.readOnly) {
            return true;
        }
        //End added for LAK-6245
        return false;
    }

    // get disableNdcQuery() {
    //     let tempBoo = false;
    //     if (this.loanStage == 'Disbursement Initiation') {
    //         if (this.readOnly) {
    //             tempBoo = true;
    //         } else {
    //             tempBoo = this.opsQuery;
    //         }
    //     } else if (this.loanStage == 'Post Sanction') {
    //         tempBoo = this.readOnly;
    //     }
    //     return tempBoo;
    // }
    get formCls() {
        if (this.hasError) {
            return 'slds-form-element slds-has-error';
        } else {
            return 'slds-form-element';
        }
    }

    get requiredvalue() {
        return this.col.Required;
    }
    get stringBoolean() {
        return this.col.type.toLowerCase() === "text" ? true : false;
    }
    get numberBoolean() {
        return this.col.type === "currency" || this.col.type === "Number" ? true : false;
    }
    get phoneBoolean() {
        return this.col.type === "phone" ? true : false;
    }
    get datetimeBoolean() {
        return this.col.type === "Date/Time" || this.col.type === "Date" ? true : false;
    }

    get emailBooelan() {
        return this.col.type === "email" ? true : false;
    }
    get checkBoxBoolean() {
        return this.col.type.toLowerCase() === "checkbox" && this.col.fieldName !== 'OpsVer__c' && this.col.fieldName !== 'FileAvalbl__c' ? true : false;
    }
    //Start LAK-4916
    get avalFilBoolean() {
        return this.col.type.toLowerCase() === "checkbox" && this.col.fieldName === 'FileAvalbl__c' ? true : false;
    }
    //End LAK-4916
    get oopsVeriBoolean() {
        return this.col.type.toLowerCase() === "checkbox" && this.col.fieldName === 'OpsVer__c' ? true : false;
    }

    // get opsVerBoolean() {
    //     return this.col.type === "Checkbox" && this.col.label === 'Ops Verification' ? true : false;
    // }

    get textAreaBoolean() {
        return this.col.type.toLowerCase() === 'textarea' ? true : false;
    }

    get nullBoolean() {
        return this.col.type === null ? true : false;
    }
    @track previewBoolean = false;

    // get updateUploadedDocDetail() {
    //     this.getDocDetToPreview();
    // }
    // get previewBoolean() {
    //     // if (this.col.type === 'preview') {
    //     //     this.getDocDetToPreview();
    //     // }
    //     return this.col.type === 'preview' ? true : false;
    // }
    // options = [];
    get picklistBoolean() {


        return this.col.type.toLowerCase() === "picklist" ? true : false;
    }
    get options() {
        let opt = [];
        if (this.col.type.toLowerCase() === "picklist" && this.col.options) {
            let arr = JSON.parse(JSON.stringify(this.col.options));
            let obj2 = {
                label: 'Please Choose...',
                disabled: true,
                selected: this.fieldValue ? false : true,
                hidden: true,
                value: ''
            }
            opt.push(obj2);
            arr.forEach(item => {
                let obj = {};
                if (item === this.fieldValue) {
                    obj.label = item;
                    obj.value = item;
                    obj.selected = true;
                } else {
                    obj.label = item;
                    obj.value = item;
                    obj.selected = false;
                }
                opt.push(obj);
            })
        }
        return opt;
    }

    get isDisabled() {
        if ((this.recordData['DocStatus__c'] == 'OTC' || this.recordData['DocStatus__c'] == 'PDD') && this.col.fieldName == 'ReceivedDt__c' && (this.loanStage == 'Post Sanction' || this.loanStage == 'Disbursement Initiation' || this.loanStage == 'Disbursed')) {
            return true;
        }
        //LAK-8690
         else if (this.recordData['DocStatus__c'] === 'Waiver' && this.col.fieldName === 'TargetDt__c' && (this.loanStage === 'Post Sanction' || this.loanStage === 'Disbursement Initiation' || this.loanStage === 'Disbursed')) {
            return true;
        }
        //LAK-8690
        else if ((this.recordData['DocStatus__c'] == 'OTC' || this.recordData['DocStatus__c'] == 'PDD') && this.col.fieldName == 'TargetDt__c' && (this.loanStage != 'Post Sanction' && this.loanStage != 'Disbursement Initiation' && this.loanStage != 'Disbursed')) {
            return true;
        } else if ((this.recordData['DocStatus__c'] == 'OTC' || this.recordData['DocStatus__c'] == 'PDD') && this.col.fieldName == 'ReceivedDt__c' && (this.loanStage != 'Post Sanction' || this.loanStage != 'Disbursement Initiation') && !this.recordData['OpsVer__c'] && !this.readOnly) {
            return false;
        }
        else if ((this.recordData['Catgry__c'] == 'OTC' || this.recordData['Catgry__c'] == 'PDD') && this.loanStage == 'Disbursed' && this.col.fieldName == 'ReceivedDt__c' && !this.recordData['OpsVer__c'] && !this.readOnly) {
            return false;
        }
        else if ((this.recordData['DocStatus__c'] == 'Completed' || this.recordData['DocStatus__c'] == 'Received') && this.col.fieldName == 'TargetDt__c' && (this.loanStage == 'Post Sanction' || this.loanStage == 'Disbursed')) {
            return true;
        }
        else if (this.readOnly || this.recordData['OpsVer__c']) {
            return true;
        }
        return false;
    }
    get isDisabledPicklist() {
        if (((this.recordData['Catgry__c'] == 'OTC' || this.recordData['Catgry__c'] == 'PDD') && this.loanStage == 'Disbursed' && this.col.fieldName == 'DocStatus__c') && !this.recordData['OpsVer__c'] && !this.readOnly) {
            return false;
        }
        //Start added for LAK-6245
        else if (this.col.fieldName === 'PhyFileRec__c' && this.loanStage === 'Disbursed' && (this.loanSubstage === 'Additional Processing' || this.loanSubstage === 'DI Check') && this.isOpsUser && !this.isCpaUser && !this.readOnlyNew && !this.allDocsReceived && this.recordData.PhyFileSend__c) {
            if (this.disPhyFileRec) {
                return true;
            }
            return false;
        } else if (this.col.fieldName === 'PhyFileRec__c' && this.loanStage === 'Disbursed' && (this.loanSubstage === 'Additional Processing' || this.loanSubstage === 'DI Check') && this.isOpsUser && !this.isCpaUser && !this.readOnlyNew && (this.allDocsReceived || !this.recordData.PhyFileSend__c)) {
            return true;
        } else if (this.col.fieldName === 'PhyFileRec__c' && this.loanStage === 'Disbursed' && (this.loanSubstage === 'Additional Processing' || this.loanSubstage === 'DI Check') && !this.isOpsUser && this.isCpaUser) {
            return true;
        }
        //End added for LAK-6245
        else if (this.readOnly || this.recordData['OpsVer__c']) {
            return true;
        }
        return false;
    }
    get quryColor() {
        let ret;
        if (this.showOpsQuery) {
            ret = 'destructive';
        } else {
            ret = 'success';
        }
        return ret;
    }
    get disableOpsCheck() {
        let disableOopsVer = false;
        if (this.col.type.toLowerCase() === "checkbox" && this.col.fieldName === 'OpsVer__c') {
            // || this.loanStage == 'Disbursed'
            if (this.loanStage === 'Disbursement Initiation' && this.loanSubstage === 'DI Check' && !this.readOnlyNew && !this.opsQuery) {
                disableOopsVer = false;
            } 
            else if(this.loanStage === 'Disbursed' && this.loanSubstage === 'DI Check' && this.isOpsUser && this.ndcCreatedDate > this.finnoneSubmitDate){
                disableOopsVer = false;
            } // LAK-9387
            else {
                disableOopsVer = true;
            }
        }
        return disableOopsVer;
    }
    get disableQuer() {
        let temBool = false;
        if (this.loanStage === 'Disbursement Initiation' && this.loanSubstage === 'DI Check' && (this.readOnlyNew || this.opsQuery)) {
            temBool = true;
        } else {
            temBool = this.readOnlyNew;
        }
        return temBool;
        // return this.readOnlyNew || this.opsQuery ? true : false;
    }

    @track queryRemBooleanfalse = false;
    // get returnQueryRemBoolean() {
    //     // let queryRemBooleann = false;
    //     if (this.col.type === "Query") {
    //         if (this.ndcId && ((this.loanStage === 'Disbursement Initiation' && this.loanSubstage === 'DI Check') || (this.loanStage === 'Post Sanction' && this.loanSubstage === 'Ops Query')) && !this.recordData['OpsVer__c']) {
    //             this.queryRemBoolean = true;
    //         } else {
    //             this.queryRemBooleanfalse = true;
    //         }
    //     }
    //     return null;
    // }
    @track showSpinner = false;


    // @track quryColor = 'success';
    connectedCallback() {
        if (this.sectionName === 'Legal Deviations') {
            // console.log('record Data in display ', this.recordData);
            console.log('record Data in display ', this.col);
            console.log('this.ndcId ', this.ndcId);
        }
        if (this.col.type === "Query") {
            // if (this.ndcId && ((this.loanStage === 'Disbursement Initiation' && this.loanSubstage === 'DI Check') || (this.loanStage === 'Post Sanction' && this.loanSubstage === 'Ops Query') || (this.loanStage == 'Disbursed' && (this.loanSubstage === 'DI Check' || this.loanSubstage === 'Additional Processing'))) && !this.recordData['OpsVer__c']) {
            //     this.queryRemBoolean = true;
            // } else {
            //     this.queryRemBooleanfalse = true;
            // }

            if (this.ndcId && ((this.loanStage === 'Post Sanction' && this.loanSubstage === 'Ops Query') || (this.loanStage == 'Disbursed' && this.loanSubstage === 'Additional Processing')) && this.showOpsQuery && !this.recordData['OpsVer__c']) {
                this.queryRemBoolean = true;
            } else if (this.ndcId && ((this.loanStage === 'Disbursement Initiation' || this.loanStage === 'Disbursed') && this.loanSubstage === 'DI Check') && !this.recordData['OpsVer__c']) {
                this.queryRemBoolean = true;
            }
            //LAK-8619
            else if(this.queryEnable && this.ndcId && this.loanStage === 'Post Sanction' && this.loanSubstage === 'Data Entry' && this.showOpsQuery && !this.recordData['OpsVer__c']){
                this.queryRemBoolean = true;
            } else {
                this.queryRemBooleanfalse = true;
            }
        }
        if (this.col.type.toLowerCase() === "checkbox" && this.col.fieldName === 'OpsVer__c') {
            if ((this.loanStage === 'Disbursement Initiation' || this.loanStage == 'Disbursed') && this.loanSubstage === 'DI Check' && !this.readOnlyNew && !this.opsQuery) {
                this.disableOopsVer = false;
            } else {
                this.disableOopsVer = true;
            }
        }

        if (this.col.type === 'preview') {
            this.previewBoolean = true;
            this.getDocDetToPreview();
        }
        // if (this.ndcId) {
        //     this.getNdcRecData();
        // }
        // else{

        // }
        //LAK-7533
        if (this.col.fieldName === 'PhyFileSend__c' && this.loanStage === 'Disbursed' && (this.loanSubstage === 'Additional Processing' || this.loanSubstage === 'DI Check') && this.recordData.PhyFileRec__c === 'Received') {
            this.disPhyFileSend = true;
        } else if (this.col.fieldName === 'PhyFileSend__c' && this.loanStage === 'Disbursed' && (this.loanSubstage === 'Additional Processing' || this.loanSubstage === 'DI Check') && this.recordData.PhyFileSend__c && this.recordData.PhyFileRec__c !== 'Query') {
            this.disPhyFileSend = true;
        } else if (this.col.fieldName === 'PhyFileSend__c' && this.loanStage === 'Disbursed' && (this.loanSubstage === 'Additional Processing' || this.loanSubstage === 'DI Check') && (this.recordData.PhyFileSend__c || this.recordData.PhyFileRec__c === 'Query' || !this.recordData.PhyFileRec__c)) {
            this.disPhyFileSend = false;
        }

        if (this.col.fieldName === 'PhyFileRec__c' && this.loanStage === 'Disbursed' && (this.loanSubstage === 'Additional Processing' || this.loanSubstage === 'DI Check') && (this.recordData.PhyFileRec__c === 'Received')) {
            this.disPhyFileRec = true;
        } else if (this.col.fieldName === 'PhyFileRec__c' && this.loanStage === 'Disbursed' && (this.loanSubstage === 'Additional Processing' || this.loanSubstage === 'DI Check') && (this.recordData.PhyFileRec__c === 'Query' || !this.recordData.PhyFileRec__c)) {
            this.disPhyFileRec = false;
        }
        //LAK-7533
        if(this.loanStage === 'Disbursed' && this.loanSubstage === 'DI Check'){
            this.getNdcRecord();
        }
        console.log('this.finnoneSubmitDate>> '+this.finnoneSubmitDate);
    }
    //LAK-9387
    getNdcRecord(){
        let params = {
            ParentObjectName: 'NDC__c',
            parentObjFields: ['Id','Name','CreatedDate'],
            queryCriteria: ' where Id = \'' + this.ndcId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Ndc Data  is ', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.ndcCreatedDate = result.parentRecords[0].CreatedDate;
                    console.log('this.ndcCreatedDate>> '+this.ndcCreatedDate);
                }
            }).catch((error) => {
                console.log('Error In getting Ndc Data is ', error);
            });
    }

    // getNdcRecData() {
    //     this.showSpinner = true;
    //     let params = {
    //         ParentObjectName: 'NDC__c',
    //         parentObjFields: ['Id', 'OpsQuery__c'],
    //         queryCriteria: ' where Id = \'' + this.ndcId + '\''
    //     }
    //     getSobjectData({ params: params })
    //         .then((result) => {
    //             console.log('Ndc Data  is ', JSON.stringify(result));
    //             if (result.parentRecords && result.parentRecords.length > 0) {
    //                 this.ndcQuery = result.parentRecords[0].OpsQuery__c;
    //             }
    //             if (this.ndcQuery || this.readOnly) {
    //                 this.disableNdcQuery = true;
    //             } else {
    //                 this.disableNdcQuery = false;
    //             }
    //             this.showSpinner = false;

    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getting Ndc Data is ', error);
    //         });
    // }

    handleNdcRemarks(event) {
        let ndcIdValu = event.target.dataset.ndcId;
        let val = {
            "ndcId": ndcIdValu,
        }
        console.log('this.ndcId' + ndcIdValu);
        const selectEvent = new CustomEvent('ndcrecord', {
            detail: val
        });
        this.dispatchEvent(selectEvent);
    }
    docDtlId = '';
    @api getDocDetToPreview() {
        this.uploadedDocDetail = {};
        let fieldVal = '';
        const myArray = this.col.fieldName.split(".");
        // console.log(myArray.length);
        // if (myArray.length === 1) {
        //     fieldVal = this.recordData[myArray[0]];
        // } else if (myArray.length === 2) {
        //     fieldVal = this.recordData[myArray[0]][myArray[1]];
        // }
        // else if (myArray.length === 3) {
        //     fieldVal = this.recordData[myArray[0]][myArray[1]][myArray[2]];
        // }
        if (myArray.length === 1) {
            fieldVal = this.recordData[myArray[0]];
        } else if (myArray.length === 2) {
            if (this.recordData[myArray[0]]) {
                fieldVal = this.recordData[myArray[0]][myArray[1]];
            }
        }
        else if (myArray.length === 3) {
            if (this.recordData[myArray[0]][myArray[1]]) {
                fieldVal = this.recordData[myArray[0]][myArray[1]][myArray[2]];
                console.log('fieldVal ', fieldVal);
            }
        }
        // console.log('this.fieldValu ', fieldVal);
        if (fieldVal) {
            this.docDtlId = fieldVal;
            this.showSpinner = true;
            getFilePreviewDataList({ ddID: this.docDtlId })
                .then((result) => {
                    // console.log('result from getFilePreviewData ', result);
                    if (result) {
                        this.showUploadIcon = false;
                    } else {
                        this.showUploadIcon = true;
                    }
                    this.uploadedDocDetail = result ? result[0] : {};
                    this.showSpinner = false;
                })

                .catch((err) => {
                    this.showSpinner = false;
                    console.log(" getFilePreviewData error===", err);
                    this.showUploadIcon = true;

                });
        }
    }

    disconnectedCallback() {
        // if (this.col.type === 'preview') {
        //     this.getDocDetToPreview();
        // }
        console.log('disconnected callback called');
    }

    handleDocumentView(event) {
        this.cdId = event.target.dataset.cdid;
        this.cvId = event.target.dataset.cvid;
        this.fileType = event.target.dataset.filetype;
        let docId = event.target.dataset.docid;
        //this.showModalForFilePre = true;
        this.url = '/sfc/servlet.shepherd/document/download/' + this.cdId;// this.uploadedDocDetail.cdId;//this.contDocId

        let val = {
            "cvId": this.cvId,
            "cdId": this.cdId,
            "fileType": this.fileType,
            "url": this.url,
            "docId": docId
        }
        console.log('this.url' + this.url);
        console.log('this.cvid  ' + this.cvId, 'fileType ', this.fileType, 'this.cdId ', this.cdId);
        const selectEvent = new CustomEvent('previ', {
            detail: val
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
        console.log('this.url' + this.url);
        console.log('this.cvid  ' + this.cvId, 'fileType ', this.fileType, 'this.cdId ', this.cdId);

    }

    handleValueChange(event) {
        let val;
        if (this.col.type.toLowerCase() === "checkbox") {
            val = event.target.checked;
        } else {
            val = event.target.value;
        }
        // if (val) {
        let fieldNames = [];
        console.log('record data in child before is', this.recordData);
        console.log('record data in child before is', this.sectionName, 'fieldname', this.col.fieldName, 'record id ', this.recordId, 'this.sobjectype ', this.sobjectType, 'this.ndc id ', this.ndcId);
        let tempObj = { ...this.recordData };

        // this.sectionName === 'Property Documents' || this.sectionName === 'Mandatory Post Sanction Documents' || this.sectionName === 'Case Conditions') && 
        if (this.col.fieldName === 'DocStatus__c') {

            // //For LAK-5983
            // if (event.target.value == 'OTC' || event.target.value == 'PDD') {
            //     tempObj['ReceivedDt__c'] = '';
            // } else if (event.target.value == 'Received' || event.target.value == 'Completed') {
            //     tempObj['TargetDt__c'] = '';
            // }
            // //For LAK-5983

            this.showSpinner = true;
            let params = {
                ParentObjectName: 'DocDtl__c',
                parentObjFields: ['Id', 'DocMstrCri__c', 'Waiver__c', 'OTC__c', 'PDD__c', 'DocMstrCri__r.OTC__c', 'DocMstrCri__r.PDD__c', 'DocMstrCri__r.Waiver__c'],
                queryCriteria: ' where Id = \'' + this.recordId + '\''
            }
            getSobjectData({ params: params })
                .then((result) => {
                    console.log('Document Data  is ', JSON.stringify(result));
                    if (result.parentRecords) {
                        if (val === 'OTC') {
                            if (result.parentRecords[0].OTC__c) {
                                // this.datetimeBoolean = false;
                                tempObj[this.col.fieldName] = val;
                                tempObj.sobjectType = this.sobjectType;
                                tempObj.ReceivedDt__c = '';
                                tempObj.DevLvl__c = result.parentRecords[0].OTC__c;
                                fieldNames.push(this.col.fieldName, 'DevLvl__c', 'ReceivedDt__c');
                                this.fireCustomEvent(tempObj, fieldNames, this.sectionName, this.appAssetId,this.col.type);
                                this.showSpinner = false;
                                // this.datetimeBoolean = true;
                            } else {
                                tempObj[this.col.fieldName] = '';
                                tempObj.DevLvl__c = null;
                                // fieldNames.push(this.col.fieldName);
                                fieldNames.push(this.col.fieldName, 'DevLvl__c');
                                this.fireCustomEvent(tempObj, fieldNames, this.sectionName, this.appAssetId,this.col.type);
                                //add error
                                this.showSpinner = false;
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: "Error",
                                        message: format(this.customLabel.NdcDataTable_Otc_ErrorMessage, 'OTC'),
                                        variant: "error",
                                        mode: 'sticky'
                                    })
                                );
                            }
                        } else if (val === 'PDD') {
                            if (result.parentRecords[0].PDD__c) {
                                // this.datetimeBoolean = false;
                                // this.recordData.DevLvl__c = result.parentRecords[0].DocMstrCri__r.PDD__c;
                                tempObj[this.col.fieldName] = val;
                                tempObj.sobjectType = this.sobjectType;
                                tempObj.ReceivedDt__c = '';
                                tempObj.DevLvl__c = result.parentRecords[0].PDD__c;
                                fieldNames.push(this.col.fieldName, 'DevLvl__c', 'ReceivedDt__c');
                                this.fireCustomEvent(tempObj, fieldNames, this.sectionName, this.appAssetId,this.col.type);
                                this.showSpinner = false;
                                // this.datetimeBoolean = true;
                            } else {
                                tempObj[this.col.fieldName] = '';
                                tempObj.DevLvl__c = null;
                                // fieldNames.push(this.col.fieldName);
                                fieldNames.push(this.col.fieldName, 'DevLvl__c');
                                this.fireCustomEvent(tempObj, fieldNames, this.sectionName, this.appAssetId,this.col.type);
                                this.showSpinner = false;
                                //add error
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: "Error",
                                        message: format(this.customLabel.NdcDataTable_Otc_ErrorMessage, 'PDD'),
                                        variant: "error",
                                        mode: 'sticky'
                                    })
                                );
                            }
                        }
                        else if (val === 'Waiver') {
                            if (result.parentRecords[0].Waiver__c) {
                                tempObj[this.col.fieldName] = val;
                                tempObj.sobjectType = this.sobjectType;
                                tempObj.DevLvl__c = result.parentRecords[0].Waiver__c;
                                fieldNames.push(this.col.fieldName, 'DevLvl__c');
                                this.fireCustomEvent(tempObj, fieldNames, this.sectionName, this.appAssetId,this.col.type);
                                this.showSpinner = false;
                            } else {
                                tempObj[this.col.fieldName] = '';
                                tempObj.DevLvl__c = null;
                                // fieldNames.push(this.col.fieldName);
                                fieldNames.push(this.col.fieldName, 'DevLvl__c');
                                this.fireCustomEvent(tempObj, fieldNames, this.sectionName, this.appAssetId,this.col.type);
                                this.showSpinner = false;
                                //add error
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: "Error",
                                        message: format(this.customLabel.NdcDataTable_Otc_ErrorMessage, 'Waiver'),
                                        variant: "error",
                                        mode: 'sticky'
                                    })
                                );
                            }
                        } else {
                            // this.datetimeBoolean = false;
                            tempObj.DevLvl__c = null;
                            tempObj[this.col.fieldName] = val;
                            tempObj.TargetDt__c = '';
                            tempObj.sobjectType = this.sobjectType;
                            fieldNames.push(this.col.fieldName, 'DevLvl__c');
                            fieldNames.push('TargetDt__c');
                            this.fireCustomEvent(tempObj, fieldNames, this.sectionName, this.appAssetId,this.col.type);
                            this.showSpinner = false;
                            // this.datetimeBoolean = true;
                        }
                    }

                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log('Error In getting Document Detail Data is ', error);
                });

        } else {
            // if (this.col.fieldName == 'TargetDt__c' && new Date(val) < new Date()) {
            //     event.preventDefault();
            // } else {
            fieldNames.push(this.col.fieldName);
            tempObj[this.col.fieldName] = val;
            tempObj.sobjectType = this.sobjectType;
            this.fireCustomEvent(tempObj, fieldNames, this.sectionName, this.appAssetId,this.col.type);
            // }
        }
        // }
    }

    fileUploadFinish(event) {
        console.log('fileUploadFinish', event.detail);
        this.showUploadModal = false;
    }
//added colType for LAK-9175
    fireCustomEvent(tempObj, fieldNames, sectionName, appAssetId,colType) {

        let valuesToPass = {
            "record": tempObj,
            "recordId": this.recordId,
            // "opsVerifcation": this.opsVerifcation ? this.opsVerifcation : false,
            "ndcId": this.ndcId ? this.ndcId : '',
            "fieldNames": fieldNames,
            "sectionName": sectionName,
            "appAssetId": appAssetId,
            "colType" : colType
        }
        const selectEvent = new CustomEvent('passsavedata', {
            detail: valuesToPass
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }

    handleFileUpload() {
        let valuesToPass = {
            "recordId": this.recordId,
            "sectionName": this.sectionName,
            "appAssetId": this.appAssetId
        }
        const selectEvent = new CustomEvent('uploaddoc', {
            detail: valuesToPass
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }

    @api reportValidity() {
        if (this.sectionName == 'Additional Post Sanction Documents') {
            console.log('col==', JSON.stringify(this.col));
        }
        let isValid = true

        // this.template.querySelectorAll('lightning-combobox').forEach(element => {
        //     if (element.reportValidity()) {
        //         console.log('element passed combobox');
        //         console.log('element if--' + element.value);
        //     } else {
        //         isValid = false;
        //         console.log('element else--' , element.value);
        //     }
        // });

        this.template.querySelectorAll('lightning-input').forEach(element => {

            // if (this.col.fieldName == 'ReceivedDt__c') {
            //     if (!this.recordData['ReceivedDt__c'] && this.recordData['DocStatus__c'] == 'Received') {
            //         element.setCustomValidity("Received Date is required");
            //     } else if (new Date(this.recordData['ReceivedDt__c']) > new Date()) {
            //         element.setCustomValidity("Received Date can not be future date");
            //     } else {
            //         element.setCustomValidity("");
            //     }
            // }

            //For LAK-4840
            if (this.loanStage == 'Post Sanction' || this.loanStage == 'Disbursement Initiation') {
                if (this.col.fieldName == 'ReceivedDt__c') {
                    if (!this.recordData['ReceivedDt__c'] && (this.recordData['DocStatus__c'] == 'Completed' || this.recordData['DocStatus__c'] == 'Received')) {
                        element.setCustomValidity("Received Date is required");
                    } else if (new Date(this.recordData['ReceivedDt__c']) > new Date()) {
                        element.setCustomValidity("Received Date can not be future date");
                    } else {
                        element.setCustomValidity("");
                    }
                }
                if (this.col.fieldName == 'TargetDt__c' && (this.recordData['DocStatus__c'] == 'OTC' || this.recordData['DocStatus__c'] == 'PDD')) {
                    if (!this.recordData['TargetDt__c']) {
                        element.setCustomValidity("Target Date is required");
                    } else if (new Date(this.recordData['TargetDt__c']) < new Date()) {
                        element.setCustomValidity("Target Date should be future date");
                    } else {
                        element.setCustomValidity("");
                    }
                }
            }
            //For LAK-4840

            if (this.loanStage == 'Disbursed') {
                if (this.col.fieldName == 'ReceivedDt__c') {
                    if (!this.recordData['ReceivedDt__c'] && (this.recordData['DocStatus__c'] == 'Completed' || this.recordData['DocStatus__c'] == 'Received')) {
                        element.setCustomValidity("Received Date is required");
                    } else if (new Date(this.recordData['ReceivedDt__c']) > new Date()) {
                        element.setCustomValidity("Received Date can not be future date");
                    } else {
                        element.setCustomValidity("");
                    }
                }
            }
            //For LAK-4919
            if (this.col.fieldName == 'TargetDt__c' && this.recordData['TargetDt__c']) {
                if (new Date(this.recordData['TargetDt__c']) < new Date()) {
                    element.setCustomValidity("Target Date should be future date");
                } else {
                    element.setCustomValidity("");
                }
            }
            //For LAK-4919

            if (this.col.fieldName == 'ReceivedDt__c' && this.recordData['ReceivedDt__c']) {
                if (new Date(this.recordData['ReceivedDt__c']) > new Date()) {
                    element.setCustomValidity("Received Date can not be future date");
                } else {
                    element.setCustomValidity("");
                }
            }

            if (element.reportValidity()) {
                console.log('element passed lightning input');
                console.log('element if--', element.value);
            } else {
                isValid = false;
            }
        });
        this.template.querySelectorAll('lightning-textarea').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed lightning input');
                console.log('element if--', element.value);
            } else {
                isValid = false;
            }
        });
        // this.template.querySelectorAll('select').forEach(element => {
        //     if (element.reportValidity()) {
        //         console.log('element passed lightning input');
        //         console.log('element value--', element.value);
        //         // Reset custom validity if it was previously set
        //         element.setCustomValidity('');
        //     } else {
        //         // Set a custom error message to highlight the invalid field
        //         element.setCustomValidity('This field is required.');
        //         isValid = false;
        //     }
        // });

        // // Trigger the reportValidity again to show the custom error messages
        // this.template.querySelectorAll('select').forEach(element => {
        //     element.reportValidity();
        // });

        this.template.querySelectorAll('select').forEach(element => {
            if (this.col.fieldName == 'DocStatus__c') {
                if (!this.recordData['DocStatus__c']) {
                    this.hasError = true;
                    isValid = false;
                } else {
                    this.hasError = false;
                }
            }
        });
        this.template.querySelectorAll('select').forEach(element => {
            if (this.col.fieldName == 'OriDoc__c') {
                if (!this.recordData['OriDoc__c']) {
                    this.hasError = true;
                    isValid = false;
                } else {
                    this.hasError = false;
                }
            }
        });
        this.template.querySelectorAll('select').forEach(element => {
            if (this.col.fieldName == 'NDCDataEntry__c') {
                if (!this.recordData['NDCDataEntry__c']) {
                    this.hasError = true;
                    isValid = false;
                } else {
                    this.hasError = false;
                }
            }
        });
        return isValid;
    }

    handleDocumentDelete() {
        let valuesToPass = {
            "recordId": this.recordId,
            "sectionName": this.sectionName,
            "appAssetId": this.appAssetId,
            "cdlId": this.uploadedDocDetail.cdlId
        }
        const selectEvent = new CustomEvent('deletedoc', {
            detail: valuesToPass
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }



    handleKeyPress(event) {
        if (this.col.fieldName === 'Rmrk__c') {
             var remarkFieldValue = ''
            var clipboardData = event.clipboardData;
            if(clipboardData){
                var remarkFieldValue = clipboardData.getData('Text');
            }
            
            //const chatCode = event.charCode;
            const inputField = event.target;

            if ((inputField && inputField.value && inputField.value.length >= 200 )|| (remarkFieldValue &&remarkFieldValue.length>=200)) {
                // Display error message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: 'More than 200 characters not allowed',
                        variant: "error",
                        mode: 'sticky'
                    })
                );
                // console.error('More than 200 characters not allowed');
                // Prevent further input
                event.preventDefault();
                return;
            }

            // console.log('chatCode', chatCode);
            // if (!((chatCode >= 48 && chatCode <= 57) || (chatCode >= 65 && chatCode <= 90) || (chatCode >= 97 && chatCode <= 122))) {
            //     event.preventDefault();
            // }
        }
    }

}