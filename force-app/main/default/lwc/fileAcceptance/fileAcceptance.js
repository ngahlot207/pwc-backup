import { LightningElement, api, track, wire } from 'lwc';

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
export default class FileAcceptance extends LightningElement {
    // @api recordId;
    @track returnToRmMessage = "Are you sure, You want to complete the File Acceptance?";
    @track isFileAcceptance = false;
    @track showSpinnerChild = false;
    @track cpaSubmStatus = '';
    @track wiredLoanData = {};

    _recordId;
    @api get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        this.setAttribute("recordId", value);
        this.handleRecordIdChange(value);
    }

    paramsLoanApp = {
        ParentObjectName: 'LoanAppl__c',
        parentObjFields: ['CPASubSt__c'],
        queryCriteria: ' where id = \'' + this.recordId + '\''
    }

    handleRecordIdChange() {
        let paramLoanappTemp = this.paramsLoanApp;
        paramLoanappTemp.queryCriteria = ' where id = \'' + this.recordId + '\''
        this.paramsLoanApp = { ...paramLoanappTemp };
    }

    @wire(getSobjectDatawithRelatedRecords, { params: '$paramsLoanApp' })
    handleAppKyc(result) {
        this.wiredLoanData = result;
        if (result.data) {
            console.log('Loan app data=', result.data);
            if (result.data.parentRecord) {
                //  this.loanAppId = result.data.parentRecord.Id;
                this.cpaSubmStatus = result.data.parentRecord.CPASubSt__c;
            }

        }
        if (result.error) {
            console.error('Loan app error=', result.error);
        }
    }
    connectedCallback() {
        this.isFileAcceptance = true;
    }

    closeModalCPA() {
        this.isFileAcceptance = false;
        this.fireCustomEvent(null, null, null);
    }
    changeSubstagetoPloginQu() {
        // this.isFileAcceptance = false;
        this.showSpinnerChild = true;
        this.spinnerEvent(true);
        let loanAppFields = {};
        loanAppFields['Id'] = this.recordId;
        loanAppFields['FileAcceptance__c'] = true;
        let dt = new Date().toISOString().substring(0, 10);
        console.log('current date ISO is===>>>>>>>', dt);
        loanAppFields['FileAcceptDate__c'] = dt;
        if (this.cpaSubmStatus !== 'FTNR') {
            loanAppFields['CPASubSt__c'] = 'FTR';
        }


        let upsertDataFile = {
            parentRecord: loanAppFields,
            ChildRecords: null,
            ParentFieldNameToUpdate: ''
        }
        console.log('upsertData ==>', JSON.stringify(upsertDataFile));

        upsertSobjDataWIthRelatedChilds({ upsertData: upsertDataFile })
            .then(result => {
                this.showSpinnerChild = false;
                this.fireCustomEvent("Success", "success", "Files Accepted Successfully!");
            }).catch(error => {
                this.showSpinnerChild = false;
                this.fireCustomEvent("Error", "error", "Error occured in accepting File  " + error.message);
                console.log(error);
            })

    }

    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(evt);
    }

    fireCustomEvent(title, vart, msg) {
        const selectEvent = new CustomEvent('click', {
            detail: { title: title, variant: vart, message: msg, from: "fileacceptance" }
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }

    spinnerEvent(val) {
        const selectEvent = new CustomEvent('spinner', {
            detail: val
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }
}