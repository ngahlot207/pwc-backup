import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import AppRejReason from "@salesforce/schema/LoanAppl__c.RejectReason__c";

import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
//custom label
import Reject_SuccessMessage from '@salesforce/label/c.Reject_SuccessMessage';

export default class RejectApplication extends NavigationMixin(LightningElement) {
    @api recordId;
    @track userId = Id;
    @api objectApiName;
    @track currentDateTime;
    @track showSpinner = true;
    reasonId;
    rejectReason;
    isvalid;
    @api hasEditAccess;
    reasonforReject;

    @wire(getRecord, { recordId: '$recordId', fields: [AppRejReason] })
    currentRecordInfo({ error, data }) {
        if (data) {
            console.log('currentRecordInfo ', data);
            console.table(data);
            this.rejectReason = data.fields.RejectReason__c.value;

        } else if (error) {
            this.error = error;
        }
    }

    connectedCallback() {
        this.updateCurrentDateTime();
        setTimeout(() => {
            this.showSpinner = false;
        }, 4000);
    }

    updateCurrentDateTime() {
        let d = new Date();
        let newD = new Date(d.getTime());
        this.currentDateTime = newD.toISOString();
        console.log('currentDateTime===', this.currentDateTime);

    }

    handleReasonFieldChange(event) {
        if (event.detail) {
        
            console.log('Event detail after ', event.detail);
            this.reasonId = event.detail.id;
            this.reasonforReject= event.detail.Reason__c;
            console.log("reasonId>>>", this.reasonforReject);
            this.getRejectReasonMstr();
        }
    }
    getRejectReasonMstr() {
        let paramsLoanApp = {
            ParentObjectName: 'ReasonMstr__c',
            parentObjFields: ['Id', 'Reason__c'],
            queryCriteria: ' where Id = \'' + this.reasonId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('result is get reason ', JSON.stringify(result));
                this.reason = result.parentRecords[0].Reason__c;
                console.log('reason===>', this.reason);
            })
            .catch((error) => {

                this.showSpinner = false;
                console.log("error occured in getting Reason", error);

            });

    }
    noBtn() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    handleInputChange(event) {
        this.decRemarks = event.detail.value.toUpperCase();
    }
    handleValueChange(event) {
        this.rejectReason = event.target.value;
    }
    handleSubmit() {
        this.showSpinner = true;
        if (!this.validateForm()) {
            this.showSpinner = false;
            return;

        }
        // if(this.decRemarks == '' || this.decRemarks == null || this.reason == null || this.reason == '' || this.reasonId == null || this.reasonId == '' || !this.checkValidityLookup()){
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: "Error",
        //             message: 'Please fill the details',
        //             variant: "error",
        //             mode: "sticky"
        //         }),
        //     );
        // }
        else {
            console.log('this.reasonforReject'+this.reasonforReject)
            const obje = {
                sobjectType: "LoanAppl__c",
                Id: this.recordId,
                Status__c: 'Rejected',
                RejectReason__c:this.reason
            }
            this.upsertDataMethod(obje);
        }
    }
    upsertDataMethod(obje) {
        console.log('objec ', obje);
        console.table(obje);
        let newArray = [];
        if (obje) {
            newArray.push(obje);
        }
        if (newArray) {
            console.log('new array is ', JSON.stringify(newArray));
            upsertSObjectRecord({ params: newArray })
                .then((result) => {

                    // this.refreshPage = result;
                    console.log('result => ', result);
                    // this.showToastMessage('Success', 'Loan Application Rejected Successfully', 'success', 'sticky');
                    this.createUWDecesionRecord();

                    // setTimeout(() => {
                    //     location.reload();
                    // }, 1000);
                })
                .catch((error) => {
                    console.log('error ', JSON.stringify(error));
                    console.table(error);
                    this.showToastMessage('Error', 'error', 'error', 'Sticky');

                    this.showSpinner = false;
                });
        }
    }

    arr = [];
    createUWDecesionRecord() {
        let fields = {};
        fields['sobjectType'] = 'UWDecision__c';
        fields['LoanAppl__c'] = this.recordId;
        fields['DecisionDt__c'] = this.currentDateTime;
        fields['Date_Time__c'] = this.currentDateTime;
        fields['User__c'] = this.userId;
        fields['DecisionRmrks__c'] = this.reason;
        fields['AddationalComm__c'] = this.decRemarks ? this.decRemarks : '';
        fields['Decision_Type__c'] = 'UW Decision';
        fields['Decision__c'] = 'Rejected';
        this.upsertUwDecision(fields);
        console.log('this.upsertUwDecision(fields)', fields);


    }

    upsertUwDecision(obj) {
        let newArr = [];
        if (obj) {
            newArr.push(obj);
        }
        if (newArr.length > 0) {
            console.log('new array is ', JSON.stringify(newArr));
            upsertSObjectRecord({ params: newArr })
                .then((result) => {
                    this.showSpinner = true;
                    console.log('resultprinted ');
                    this.createFeed();
                    this.showToastMessage('Success', Reject_SuccessMessage, 'success', 'sticky');
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recordId,
                            actionName: 'view'
                        },
                    });
                    setTimeout(() => {
                        location.reload();
                    }, 2000);
                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log('error in upserting decision ', JSON.stringify(error));

                });
        }
    }
    showToastMessage(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
            mode
        });
        this.dispatchEvent(evt);
    }
    checkValidityLookup() {
        let isInputCorrect = true;
        let allChilds = this.template.querySelectorAll("c-custom-lookup");
        console.log("custom lookup allChilds>>>", allChilds);
        allChilds.forEach((child) => {
            console.log("custom lookup child>>>", child);
            console.log("custom lookup validity custom lookup >>>", isInputCorrect);
            if (!child.checkValidityLookup()) {
                child.checkValidityLookup();
                isInputCorrect = false;
                console.log("custom lookup validity if false>>>", isInputCorrect);
            }
        });
        return isInputCorrect;
    }
    validateForm() {
        let isValid = true
        this.template.querySelectorAll('lightning-textarea').forEach(element => {
            if (element.reportValidity()) {
            } else {
                isValid = false;
            }
        });
        if (!this.checkValidityLookup()) {
            isValid = false;
        }
        if (isValid === false) {
        }
        return isValid;
    }
    createFeed() {
        let fields = {};
        fields['sobjectType'] = 'FeedItem';
        fields['ParentId'] = this.recordId;
        fields['Body'] = 'Loan Application Rejected with Reason: ' + this.reason + ' and with Remarks: ' + this.decRemarks;
        this.upsertFeed(fields);

    }

    upsertFeed(obj) {
        let newArr = [];
        if (obj) {
            newArr.push(obj);
        }
        if (newArr.length > 0) {
            console.log('new array is ', JSON.stringify(newArr));
            upsertSObjectRecord({ params: newArr })
                .then((result) => {
                })
                .catch((error) => {
                    console.log('error in creating feed ', JSON.stringify(error));
                    this.showSpinner = false;
                });
        }
    }
}