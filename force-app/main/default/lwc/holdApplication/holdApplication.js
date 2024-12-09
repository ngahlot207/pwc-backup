import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import HoldReason from "@salesforce/schema/LoanAppl__c.Hold_Reason__c";
import AppStage from "@salesforce/schema/LoanAppl__c.Stage__c";
import AppSubstage from "@salesforce/schema/LoanAppl__c.SubStage__c";
import AddComments from "@salesforce/schema/LoanAppl__c.Additional_Comments__c";
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
// Custom labels
import HoldApplication_SuccessMessage from '@salesforce/label/c.HoldApplication_SuccessMessage';

export default class HoldApplication extends NavigationMixin(LightningElement) {
    label = {
        HoldApplication_SuccessMessage
    }
    @api recordId;
    @api objectApiName;
    @track showSpinner = true;
    @track userId = Id;
    @track currentDateTime;
    holdReason;
    addComents;
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


        // this.handleReset();
    }

    handleaddCommentValue(event) {
        this.addComp2 = event.target.value;
        console.log('addComp2:' + event.target.value);
    }
    //     handleInput(event) {        
    //     // Convert the entered value to uppercase

    //     const fieldName = event.target.fieldName;        
    //     const inputValue = event.target.value.toUpperCase();        
    //     // Set the uppercase value back to the input field

    //     this.template.querySelector(`[data-field-name="${fieldName}"]`).value = inputValue;   
    //   }
    //     handleReset(event) {
    //         const inputFields = this.template.querySelectorAll(
    //             'lightning-input-field'
    //         );
    //         if (inputFields) {
    //             inputFields.forEach(field => {
    //                 if (field.name === "Additional_Comments__c") {
    //                     field.reset();
    //                 }
    //             });
    //         }
    //     }

    updateCurrentDateTime() {
        let d = new Date();
        let newD = new Date(d.getTime());
        this.currentDateTime = newD.toISOString();
        console.log('currentDateTime===', this.currentDateTime);

    }


    @wire(getRecord, { recordId: '$recordId', fields: [HoldReason, AppStage, AppSubstage, AddComments] })
    currentRecordInfo({ error, data }) {
        if (data) {
            console.log('currentRecordInfo ', data);
            console.table(data);
            this.holdReason = data.fields.Hold_Reason__c.value;
            this.stage = data.fields.Stage__c.value;
            this.substage = data.fields.SubStage__c.value;
            this.addcomm = data.fields.Additional_Comments__c.value;

        } else if (error) {
            this.error = error;
        }
    }

    handleValueChange(event) {
        this.holdReason = event.target.value;
        if (this.holdReason == 'Others') {
            this.makeReasonRequired = true;
        }
        else {
            this.makeReasonRequired = false;
        }
    }

    // handeleCommentChange(event){
    //     this.addcomm = event.target.value;
    //     console.log('add com : '+event.target.value);
    // }

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
                    message: this.label.HoldApplication_SuccessMessage,
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
        this.showSpinner = false;
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
            fields['DecisionRmrks__c'] = this.holdReason;
            fields['AddationalComm__c'] = this.addComp2;
            fields['Decision_Type__c'] = 'UW Decision';
            fields['Decision__c'] = 'Hold';
            this.upsertUwDecision(fields);
            console.log('this.upsertUwDecision(fields)', fields);
        }
        else {
            let fields = {};
            fields['sobjectType'] = 'UWDecision__c';
            fields['LoanAppl__c'] = this.recordId;
            fields['DecisionDt__c'] = this.currentDateTime;
            fields['User__c'] = this.userId;
            fields['DecisionRmrks__c'] = this.holdReason;
            fields['AddationalComm__c'] = this.addComp2;
            fields['Decision_Type__c'] = 'Hold Decision';
            fields['Decision__c'] = 'Hold';
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
                    console.log('resultprinted ');
                    this.showSpinner = true;
                    this.createFeed();
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: this.label.HoldApplication_SuccessMessage,
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
                })
                .catch((error) => {
                    console.log('error in upserting uw decision ', JSON.stringify(error));
                    this.showSpinner = false;
                });
        }
    }
    createFeed() {
        console.log('Hold Resone:' + this.holdReason);
        console.log('Additional Comment:' + this.addComp2)
        if (this.addComp2 === undefined || this.addComp2 === '') {
            this.addComp2 = 'NA';
        }

        let fields = {};
        fields['sobjectType'] = 'FeedItem';
        fields['ParentId'] = this.recordId;
        fields['Body'] = 'Loan Application is on HOLD with Reason: ' + this.holdReason + ' and with Remarks: ' + this.addComp2;
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