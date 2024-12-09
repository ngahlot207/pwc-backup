import { LightningElement, track, api, wire } from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import { formattedDateTimeWithSeconds } from 'c/dateUtility';

export default class ApiTriggerHistory extends LightningElement {

    apiColumns = [
        {
            label: 'Name of the Verification',
            fieldName: 'Name',
            type: 'text',

        },
        {
            label: `Applicant's Name`,
            fieldName: 'BorrowerName__c',
            type: 'text',

        },
        {
            label: 'Initiation Time',
            fieldName: 'ReqGenTime__c',
            type: 'text',
            typeAttributes: {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: true
            }

        },
        {
            label: 'Response Time',
            fieldName: 'RespGenTime__c',
            type: 'text',
            typeAttributes: {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: true
            }

        },
        {
            label: 'API Status',
            fieldName: 'APIStatus__c',
            type: 'text',
        },
        {
            label: 'Status',
            fieldName: 'Status__c',
            type: 'text',
        },
        {
            label: 'TAT (ms)',
            fieldName: 'TAT_ms__c',
            type: 'text',
        }
        , {
            label: 'Retrigger Rational',
            fieldName: 'RetriRatinal__c',
            type: 'text',
        },
        {
            label: 'User Name',
            fieldName: 'CreatedBy.Name',
            type: 'text',
        },
        {
            label: 'User Role',
            fieldName: 'UserNameRole__c',
            type: 'text',
        },
        {
            label: 'Actioned Date',
            fieldName: 'ActionedDate__c',
            type: 'text',
        }
    ];
    //CreatedBy.Name,RetriRatinal__c,UserNameRole__c,ActionedDate__c
    // Retrigger Rational, Username, User Role, Actioned Date
    @track _recordId
    @api get loanAppId() {
        return this._recordId;
    }
    //@api loanAppId;
    set loanAppId(value) {
        this._recordId = value;
        this.setAttribute("recordId", value);
        console.log('RecordId ##1 ::::>>>>', value);
        this.handleRecordIdChange(value);
    }

    @track error;
    @track apiList;
    @track apiHistoryParams = {
        ParentObjectName: 'IntgMsg__c',
        ChildObjectRelName: '',
        parentObjFields: ['id', 'Name', 'BorrowerName__c', 'LoanAppln__c', 'ReqGenTime__c', 'RespGenTime__c', 'APIStatus__c', 'Status__c', 'TAT_ms__c', 'CreatedBy.Name', 'RetriRatinal__c', 'UserNameRole__c', 'ActionedDate__c'],
        childObjFields: [],
        queryCriteria: ''
    }
    handleRecordIdChange() {
        this.apiList = [];
        let tempParams = this.apiHistoryParams;
        tempParams.queryCriteria = ' where LoanAppln__c = \'' + this._recordId + '\' order by ReqGenTime__c desc';
        this.apiHistoryParams = { ...tempParams };
        console.log('RecordId ::::>>>>', this._recordId);
    }

    @wire(getSobjectData, { params: '$apiHistoryParams' })
    floatingRateHandler({ data, error }) {
        if (data) {
            console.log('API HISTORY ::::>>>>', data);
            // this.apiList = data.parentRecords; 

            this.apiList = data.parentRecords.map(record => ({
                ...record,
                ReqGenTime__c: formattedDateTimeWithSeconds(new Date(record.ReqGenTime__c)),
                RespGenTime__c: formattedDateTimeWithSeconds(new Date(record.RespGenTime__c))


            }));


        }
        if (error) {
            console.error('###error occured');
            this.error = error;
        }
    }
}