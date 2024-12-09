import { LightningElement,track,api, wire  } from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
export default class LoanTatMatrix extends LightningElement {
    updatedColumns = [
        {
            label: 'TAT Name',
            fieldName: 'TATName__c',
            type: 'Picklist',
        },   
        {
            label: 'Time Spent In hrs',
            fieldName: 'TimeSpentInhrs__c',
            type: 'Number',
        },
        {
            label: 'TAT',
            fieldName: 'TAT__c',
            type: 'text',
        }
    ]

    @track _recordId
    @api get recordId() {
        return this._recordId;
    }
    @api loanAppId;
    set recordId(value) {
        this._recordId = value;
        this.setAttribute("recordId", value);
        this.handleRecordIdChange(value);
        console.log('setter method call');
    }
    @track error;a08C4000008V0lXIAS
    @track loanTatList = [];
    @track loanTatParams = {
        ParentObjectName: 'LoanTATMatrix__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id','TATName__c','TimeSpentInhrs__c','TAT__c','LoanApp__c'],
        childObjFields: [],
        queryCriteria: ''
        }   

        
       handleRecordIdChange() {
            let tempParams = this.loanTatParams;
            tempParams.queryCriteria = ' where LoanApp__c = \'' + this._recordId + '\' order by TAT__c ASC' ;
            this.loanTatParams = { ...tempParams };
        }

        @wire(getSobjectData,{params : '$loanTatParams'})
        floatingRateHandler({data,error}){
            if(data){
                console.log('DATA IN Loan Matrix ::::>>>>',JSON.stringify(data));
                let loanTat = []
                if(data.parentRecords){
                data.parentRecords.forEach(row => {
                let obj ={};
                if(row.TimeSpentInhrs__c != undefined){
                obj.TimeSpentInhrs__c = parseFloat(row.TimeSpentInhrs__c).toFixed(2);
                } 
                 obj.TATName__c = row.TATName__c;
                 obj.TAT__c = row.TAT__c;
                 loanTat.push(obj);
                });
                this.loanTatList = loanTat;
                console.log(' this.loanTatList:'+JSON.stringify(this.loanTatList));
                }
            }
            if(error){
                console.error(error);
                this.error = error;
            }
        }
}