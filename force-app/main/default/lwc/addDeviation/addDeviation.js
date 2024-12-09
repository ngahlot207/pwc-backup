import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
// Custom labels
import AddDeviation_Description_ErrorMessage from '@salesforce/label/c.AddDeviation_Description_ErrorMessage';
import AddDeviation_ErrorMessage from '@salesforce/label/c.AddDeviation_ErrorMessage';
import AddDeviation_SuccessMessage from '@salesforce/label/c.AddDeviation_SuccessMessage';



export default class AddDeviation extends LightningElement {
    @api deviationCategory = 'Legal';
    @api readOnly = false;
    @api loanAppId = 'a08C4000007WjlxIAC';
    @api product = 'Home Loan';
    @api layoutSize = {
        "large": "4",
        "medium": "6",
        "small": "12"
    }
    @api sectionName;

    label = {
        AddDeviation_Description_ErrorMessage,
        AddDeviation_ErrorMessage,
        AddDeviation_SuccessMessage
    }

    @track showSpinner = false;
    @track filterConditionForLookup;
    @track devMstrId;
    @track devMstrName;
    get filtercondition() {
        return 'Deviation_Category__c = \'' + this.deviationCategory + '\' AND (LWDD_NPM_Prod__c = \'' + this.product + '\' OR LWDD_NPM_Prod__c = NULL) AND IsActive__c = true';
    }
    connectedCallback() {
        // console.log('deviationCategory ', this.deviationCategory);
        // this.filterConditionForLookup = ' Deviation_Category__c = \'' + this.deviationCategory + '\'';
        // console.log('filterConditionForLookup ', this.filterConditionForLookup);
    }

    handleLookupFieldChange(event) {
        if (event.detail) {
            console.log('Event detail====> ', event.detail);
            this.devMstrId = event.detail.id;
            this.devMstrName = event.detail.mainField;
            console.log("devMstrId>>>", this.devMstrId, this.devMstrName);
        }
    }

    handleDeviationCreation() {
        if (this.devMstrId) {
            this.showSpinner = true;
            let params = {
                ParentObjectName: 'DeviaMstr__c',
                parentObjFields: ['Id', 'LWDD_Prio_N__c', 'LWDD_Devi_Desc__c', 'Devia_Desc_Text__c', 'LWDD_Dev_DTL_Id__c'],
                queryCriteria: ' where Id = \'' + this.devMstrId + '\''
            }
            getSobjectData({ params: params })
                .then((result) => {
                    console.log('Deviation master Data  is ', JSON.stringify(result));
                    if (result.parentRecords) {
                        let lwddPriNumber = result.parentRecords[0].LWDD_Prio_N__c;

                        const obje = {
                            sobjectType: "Deviation__c",
                            // Name: this.devMstrId,
                            Req_Apprv_Level__c: lwddPriNumber,
                            LoanAppln__c: this.loanAppId,
                            DeviationMaster__c: this.devMstrId,
                            Deviation__c: result.parentRecords[0].LWDD_Dev_DTL_Id__c ? result.parentRecords[0].LWDD_Dev_DTL_Id__c : '',
                            Devia_Desrp__c: result.parentRecords[0].Devia_Desc_Text__c ? result.parentRecords[0].Devia_Desc_Text__c : ''
                        }
                        console.table(obje);
                        this.upsertDataMethod(obje);
                    }
                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log('Error In getting Document Detail Data is ', error);
                    //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
                });
        } else {
            this.showToastMessage('Error', this.label.AddDeviation_Description_ErrorMessage, 'error', 'sticky');
            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         title: "Error",
            //         message: "Select Description ",
            //         variant: "error",
            //     }),

            // );
        }
    }

    getDeviationRecord() {
        if (this.devMstrId) {
            this.showSpinner = true;
            let params = {
                ParentObjectName: 'Deviation__c',
                parentObjFields: ['Id', 'Name'],
                queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND DeviationMaster__c = \'' + this.devMstrId + '\''
            }
            getSobjectData({ params: params })
                .then((result) => {
                    console.log('Deviation Data is ', JSON.stringify(result));
                    if (result.parentRecords) {
                        this.showSpinner = false;
                        this.devMstrId = '';
                        this.showToastMessage('Error', this.devMstrName + ' Deviation Already Exists', 'error', 'sticky');
                    } else {
                        this.handleDeviationCreation();
                    }
                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log('Error In getting Deviation Data is ', error);
                    //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
                });
        } else {
            this.showToastMessage('Error', this.label.AddDeviation_Description_ErrorMessage, 'error', 'sticky');
        }
    }

    devRecord = {};
    upsertDataMethod(obje) {
        console.log('objec ', obje);
        let newArray = [];
        if (obje) {
            newArray.push(obje);
        }
        if (newArray) {
            console.log('new array is ', JSON.stringify(newArray));
            upsertSObjectRecord({ params: newArray })
                .then((result) => {
                    this.devRecord = result;
                    console.log('result => ', result);
                    this.showSpinner = false;
                    this.devMstrId = '';
                    this.showToastMessage('Success', this.label.AddDeviation_SuccessMessage, 'success', 'sticky');

                    // this.dispatchEvent(
                    //     new ShowToastEvent({
                    //         title: "Success",
                    //         message: "Added Record ",
                    //         variant: "success",
                    //     }),

                    // );

                    let val = {
                        "record": this.devRecord,
                        "sectionName": this.sectionName
                    }
                    const selectEvent = new CustomEvent('passtoparent', {
                        detail: val
                    });
                    this.dispatchEvent(selectEvent);
                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log('error ', JSON.stringify(error));
                    this.showToastMessage('Error', this.label.AddDeviation_ErrorMessage, 'error', 'sticky');
                    // this.dispatchEvent(

                    //     new ShowToastEvent({
                    //         title: "Error while Adding the record",
                    //         message: error.body.message,
                    //         variant: "error",
                    //     }),
                    // );
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
}