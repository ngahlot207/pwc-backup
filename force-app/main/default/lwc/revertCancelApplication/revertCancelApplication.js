import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import AppRevertCancelReason from "@salesforce/schema/LoanAppl__c.Revert_Cancel_Reason__c";
import AppStage from "@salesforce/schema/LoanAppl__c.Stage__c";
import AppSubstage from "@salesforce/schema/LoanAppl__c.SubStage__c";
import AddComments from "@salesforce/schema/LoanAppl__c.Additional_Comments__c";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
// Custom labels
import RevertCancel_SuccessMessage from '@salesforce/label/c.RevertCancel_SuccessMessage';

export default class RevertCancelApplication extends NavigationMixin(LightningElement) {
    label = {
        RevertCancel_SuccessMessage

    }
    @api recordId;
    @api objectApiName;
    @track showSpinner = true;
    @track userId = Id;
    @track currentDateTime;
    revertcancelReason;
    stage;
    substage;
    addcomm;
    addComp2;
    makeReasonRequired = false;

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
    @wire(getRecord, { recordId: '$recordId', fields: [AppRevertCancelReason, AppStage, AppSubstage, AddComments] })
    currentRecordInfo({ error, data }) {
        if (data) {
            console.log('currentRecordInfo ', data);
            console.table(data);
            this.revertcancelReason = data.fields.Revert_Cancel_Reason__c.value;
            this.stage = data.fields.Stage__c.value;
            this.substage = data.fields.SubStage__c.value;
            this.addcomm = data.fields.Additional_Comments__c.value;

        } else if (error) {
            this.error = error;
        }
    }

    handleValueChange(event) {
        this.AppRevertCancelReason = event.target.value;
        if (this.AppRevertCancelReason == 'Others') {
            this.makeReasonRequired = true;
        }
        else {
            this.makeReasonRequired = false;
        }
    }
    @track statusVal;
    cancelStatus = 'Cancelled';
    getStatus() {
        let paramsLoanApp = {
            ParentObjectName: 'LoanTAT__c',
            parentObjFields: ['Id', 'Status__c'],
            queryCriteria: ' where Status__c != \'' + this.cancelStatus + '\' AND LoanApplication__c = \'' + this.recordId + '\'order by LastModifiedDate desc'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('result is get status ', JSON.stringify(result));
                this.statusVal = result.parentRecords[0].Status__c;
                console.log('statusVal===>', this.statusVal);
                let obje = {
                    Id: this.recordId,
                    Status__c: this.statusVal
                }
                this.upsertLoanRecord(obje);
                console.log('resultprinted  in getStatus');

            })
            .catch((error) => {

                this.showSpinner = false;
                console.log("error occured in getting prevStatus", error);

            });

    }
    handleSuccess(e) {
        this.showSpinner = true;
        this.createUWDecesionRecord();

    }
    handleaddCommentValue(event) {
        this.addComp2 = event.target.value;
        console.log('addComp2:' + event.target.value);
    }


    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    arr = [];
    createUWDecesionRecord() {
        if (this.stage == 'UnderWriting' && this.substage == 'Credit Appraisal') {
            let fields = {};
            fields['sobjectType'] = 'UWDecision__c';
            fields['LoanAppl__c'] = this.recordId;
            fields['DecisionDt__c'] = this.currentDateTime;
            fields['User__c'] = this.userId;
            fields['DecisionRmrks__c'] = this.AppRevertCancelReason;
            fields['AddationalComm__c'] = this.addComp2;
            fields['Decision_Type__c'] = 'UW Decision';
            fields['Decision__c'] = 'Revert Cancel Application';
            this.upsertUwDecision(fields);
            console.log('this.upsertUwDecision(fields)', fields);
        }
        else {
            let fields = {};
            fields['sobjectType'] = 'UWDecision__c';
            fields['LoanAppl__c'] = this.recordId;
            fields['DecisionDt__c'] = this.currentDateTime;
            fields['User__c'] = this.userId;
            fields['DecisionRmrks__c'] = this.AppRevertCancelReason;
            fields['AddationalComm__c'] = this.addComp2;
            fields['Decision_Type__c'] = 'Revert Cancel Decision';
            fields['Decision__c'] = 'Revert Cancel Application';
            this.upsertUwDecision(fields);
        }

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
                    this.getStatus();
                    this.createFeed();

                })
                .catch((error) => {
                    console.log('error in upserting uw decision ', JSON.stringify(error));

                });
        }
    }
    upsertLoanRecord(obj) {
        let newAr = [];
        if (obj) {
            newAr.push(obj);
        }
        if (newAr.length > 0) {
            console.log('new array is ', JSON.stringify(newAr));
            upsertSObjectRecord({ params: newAr })
                .then((result) => {

                    console.log('resultprinted LAN');
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: this.label.RevertCancel_SuccessMessage,
                            variant: 'success'
                        })
                    );

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
                    console.log('error in upserting LAN ', JSON.stringify(error));

                });
        }
    }
    createFeed() {
        if (this.addComp2 === undefined || this.addComp2 === '') {
            this.addComp2 = 'NA';
        }

        let fields = {};
        fields['sobjectType'] = 'FeedItem';
        fields['ParentId'] = this.recordId;
        fields['Body'] = 'Loan Application is Reverted with Reason: ' + this.AppRevertCancelReason + ' and with Remarks: ' + this.addComp2;
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

                });
        }
    }

}