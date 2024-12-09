import { LightningElement, api, wire, track } from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';

import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
// Custom labels
import DocDispatch_ScheduledDate_ErrorMessage from '@salesforce/label/c.DocDispatch_ScheduledDate_ErrorMessage';

export default class DocumentDispatch extends LightningElement {
    label ={
        DocDispatch_ScheduledDate_ErrorMessage
    }
    @api loanAppId;
    @api hasEditAccess = false;
    @api layoutSize = {
        "large": "4",
        "medium": "6",
        "small": "12"
    }

    @track isReadOnly = false;
    @track disTypeOptions = [];
    @track courierNameOptions = [];
    @track obj = {
        CourierComName__c: '',
        CPARemarks__c: '',
        DateofDispatch__c: '',
        DateofReceiptbyOps__c: '',
        DisType__c: '',
        OperationRem__c: '',
        PODNum__c: ''
    }

    @wire(getObjectInfo, { objectApiName: 'DocDispatch__c' })
    objectInfo;

    @wire(getPicklistValuesByRecordType, {
        objectApiName: 'DocDispatch__c',
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    })
    paymentPicklistHandler({ data, error }) {
        if (data) {
            console.log('data in paymentPicklistHandler', JSON.stringify(data));
            this.disTypeOptions = [...this.generatePicklist(data.picklistFieldValues.DisType__c)]
            this.courierNameOptions = [...this.generatePicklist(data.picklistFieldValues.CourierComName__c)]
        }
        if (error) {
            console.error('error im getting picklist values are', error)
        }
    }
    generatePicklist(data) {
        if (data.values) {
            return data.values.map(item => ({ label: item.label, value: item.value }))
        }
        return null;
    }

    connectedCallback() {
        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }
        this.isReadOnly = false;
        this.getDocumentDispatchDet();
    }

    getDocumentDispatchDet() {
        let params = {
            ParentObjectName: 'DocDispatch__c',
            parentObjFields: ['Id', 'CourierComName__c', 'CPARemarks__c', 'DateofDispatch__c', 'DateofReceiptbyOps__c', 'DisType__c', 'OperationRem__c', 'PODNum__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this.userIdNew + '\''
        }

        getSobjectData({ params: params })
            .then((result) => {
                console.log('Team Hierarchy Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.obj.CourierComName__c = result.parentRecords[0].CourierComName__c ? result.parentRecords[0].CourierComName__c : '';
                    this.obj.CPARemarks__c = result.parentRecords[0].CPARemarks__c ? result.parentRecords[0].CPARemarks__c : '';
                    this.obj.DateofDispatch__c = result.parentRecords[0].DateofDispatch__c ? result.parentRecords[0].DateofDispatch__c : '';
                    this.obj.DateofReceiptbyOps__c = result.parentRecords[0].DateofReceiptbyOps__c ? result.parentRecords[0].DateofReceiptbyOps__c : '';
                    this.obj.DisType__c = result.parentRecords[0].DisType__c ? result.parentRecords[0].DisType__c : '';
                    this.obj.OperationRem__c = result.parentRecords[0].OperationRem__c ? result.parentRecords[0].OperationRem__c : '';
                    this.obj.PODNum__c = result.parentRecords[0].PODNum__c ? result.parentRecords[0].PODNum__c : '';
                }

            })
            .catch((error) => {
                console.log('Error In getting Team Hierarchy Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    handlChange(event) {
        let name = event.target.name;
        let val = event.target.value;
        if (name === 'DateofDispatch__c') {
            const dt = new Date();
            dt.setDate(dt.getDate() - 3);
            const selecteddate = new Date(val);
            console.log('yesterday => ' + dt + ' selected date =>' + val)
            console.log('condition => ' + selecteddate < dt)
            if (selecteddate <= dt) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Warning",
                        message: this.label.DocDispatch_ScheduledDate_ErrorMessage,
                        variant: "error",
                    }),
                );
            }
        }
        if (name && val) {
            this.obj.name = val;
            console.log('obj is ', this.obj);
        }
    }

    // validateDate() {

    //     const dt = new Date();
    //     dt.setDate(dt.getDate() - 4);
    //     const selecteddate = new Date(this.ScheduledDateValue);
    //     console.log('yesterday => ' + dt + ' selected date =>' + this.ScheduledDateValue)
    //     console.log('condition => ' + selecteddate < dt)
    //     if (selecteddate <= dt) {
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: "Warning",
    //                 message: "Scheduled Date should be greater than today",
    //                 variant: "error",
    //             }),
    //         );
    //         console.log('in if');
    //         return false;
    //     }
    //     else {
    //         console.log('in else');
    //         return true;
    //     }

    // }
}