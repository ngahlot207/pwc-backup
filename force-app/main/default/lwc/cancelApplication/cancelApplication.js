import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import AppCancelReason from "@salesforce/schema/LoanAppl__c.Cancel_Reason__c";
import AppStage from "@salesforce/schema/LoanAppl__c.Stage__c";
import AppSubstage from "@salesforce/schema/LoanAppl__c.SubStage__c";
import AddComments from "@salesforce/schema/LoanAppl__c.Additional_Comments__c";
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
// Custom labels
import CancelLoanApp_ErrorMessage from '@salesforce/label/c.CancelLoanApp_ErrorMessage';

export default class CancelApplication extends NavigationMixin(LightningElement) {
    label = {
        CancelLoanApp_ErrorMessage
    }

    @api recordId;
    @track userId = Id;
    @api objectApiName;
    @track currentDateTime;
    @track showSpinner = true;
    cancelReason;
    stage;
    substage;
    addcomm;
    addComp2;
    makeReasonRequired = false;
    @api hasEditAccess;

    @wire(getRecord, { recordId: '$recordId', fields: [AppCancelReason, AppStage, AppSubstage, AddComments] })
    currentRecordInfo({ error, data }) {
        if (data) {
            console.log('currentRecordInfo ', data);
            console.table(data);
            // this.cancelReason = data.fields.Cancel_Reason__c.value;
            this.stage = data.fields.Stage__c.value;
            this.substage = data.fields.SubStage__c.value;
            this.addcomm = data.fields.Additional_Comments__c.value;


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
    handleaddCommentValue(event) {
        this.addComp2 = event.target.value;
        console.log('addComp2:' + event.target.value);
    }
    handleValueChange(event) {
        this.CancelReason = event.target.value;
        if (this.CancelReason == 'Others') {
            this.makeReasonRequired = true;
        }
        else {
            this.makeReasonRequired = false;
        }
    }
    handleSuccess(e) {
        this.showSpinner = true;
        if (this.stage == 'UnderWriting' && this.substage == 'Credit Appraisal') {
            this.createUWDecesionRecord();
        }
        else {
            this.createFeed();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: this.label.CancelLoanApp_ErrorMessage,
                    variant: 'success',
                    mode: 'sticky'
                })
            );
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    actionName: 'view'
                },
            });
        }

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
            fields['DecisionRmrks__c'] = this.CancelReason;
            fields['AddationalComm__c'] = this.addComp2;
            fields['Decision_Type__c'] = 'UW Decision';
            fields['Decision__c'] = 'Cancelled';
            this.upsertUwDecision(fields);
            console.log('this.upsertUwDecision(fields)', fields);
        }
        else {
            let fields = {};
            fields['sobjectType'] = 'UWDecision__c';
            fields['LoanAppl__c'] = this.recordId;
            fields['DecisionDt__c'] = this.currentDateTime;
            fields['User__c'] = this.userId;
            fields['DecisionRmrks__c'] = this.CancelReason;
            fields['AddationalComm__c'] = this.addComp2;
            fields['Decision_Type__c'] = 'Cancel Decision';
            fields['Decision__c'] = 'Cancelled';
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
            console.log('array size', newArr.length);
            upsertSObjectRecord({ params: newArr })
                .then((result) => {
                    this.showSpinner = true;
                    this.createFeed();
                    console.log('resultprinted ');
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.showToastMessage('Success', this.label.CancelLoanApp_ErrorMessage, 'success', 'sticky');

                    // this.dispatchEvent(
                    //     new ShowToastEvent({
                    //         title: 'Success',
                    //         message: 'Loan application has been cancelled successfully',
                    //         variant: 'success'
                    //     })
                    // );
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recordId,
                            actionName: 'view'
                        },
                    });
                })
                .catch((error) => {
                    console.log('error in upserting uw decision ', JSON.stringify(error));
                    this.showSpinner = false;

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
    createFeed() {
        console.log('cancelReason', this.CancelReason);
        if(this.CancelReason){
            this.CancelReason=this.CancelReason.toUpperCase()
        }
        
        if (this.addComp2 === undefined || this.addComp2 === '') {
            this.addComp2 = 'NA';
        }
        if(this.addComp2){
            this.addComp2=this.addComp2.toUpperCase()
        }
        let fields = {};
        fields['sobjectType'] = 'FeedItem';
        fields['ParentId'] = this.recordId;
        fields['Body'] = 'Loan Application Cancelled with Reason: ' + this.CancelReason + ' and with Remarks: ' + this.addComp2;
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