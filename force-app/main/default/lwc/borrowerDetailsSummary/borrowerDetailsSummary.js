import { LightningElement, track, api,wire } from 'lwc';

import getBorrowerDetails from '@salesforce/apex/ObligationDetailsSummaryController.getBorrowerDetails';

export default class BorrowerDetailsSummary extends LightningElement {

    //modified 
    @track borowerTypeName;
    @track listBorrowerDetails =[];
    @api recordId;
    @track isBLorPL = false;
    @wire(getBorrowerDetails,{ recordId: '$recordId'})
    wiredgetBorrowerDetails({ data, error }) {
       // console.log('Yesssssss-->');
        if (data) {
          //  console.log('dataYsssssss-->'+JSON.stringify(data));
            this.listBorrowerDetails = data;
            console.log('listBorrowerDetails-->'+JSON.stringify(this.listBorrowerDetails));
            if(this.listBorrowerDetails[0].applicantListForBorrowerWrapper.LoanAppln__r.Product__c && 
                (this.listBorrowerDetails[0].applicantListForBorrowerWrapper.LoanAppln__r.Product__c  == 'Business Loan' || 
                this.listBorrowerDetails[0].applicantListForBorrowerWrapper.LoanAppln__r.Product__c  == 'Personal Loan')){
                    this.isBLorPL = true;
                }
            
        } else if (error) {
            console.error('Error loading Borrower Details: ', error);
        }
    }
    

   /* @api recordId;//= 'a08C4000005yfVKIAY';
    @track queryParam = [];
    @track params = {};
    @track paramsAppl = {};
    @track showSpinner = false;
    @track columnsDataForTable = [
        {
            "label": "Borrower Name",
            "fieldName": "TabName__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Borrower Type",
            "fieldName": "ApplType__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Customer Segment",
            "fieldName": "CustProfile__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Constitution",
            "fieldName": "Constitution__c",
            "type": "boolean",
            "Editable": false
        },
        {
            "label": "Gender",
            "fieldName": "Gender__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Relationship with applicant",
            "fieldName": "Relationship__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Age",
            "fieldName": "Age__c",
            "type": "Number",
            "Editable": false
        }
    ];
    @track isModalOpen = false;
    @track queryData = 'SELECT TabName__c,ApplType__c,CustProfile__c,Constitution__c,Gender__c,Relationship__c,Age__c, FROM Applicant__c WHERE LoanAppln__c =: recordId ';
    connectedCallback() {
        let paramVal = [];
        paramVal.push({ key: 'recordId', value: this.recordId })
        this.queryParam = paramVal;
        console.log('map data:::', this.queryParam);
        this.params = {
            columnsData: this.columnsDataForTable,
            queryParams: this.queryParam,
            query: this.queryData
        }
    }

    handleIntialization() {
        this.isModalOpen = true;

    }



    handleCustomEvent(event) {
        this.isModalOpen = false;
        let spinnerValue = event.detail.spinner;
        if (spinnerValue) {
            this.showSpinner = true;
        } else {
            this.showSpinner = false;
        }
        let titleVal = event.detail.title;
        let variantVal = event.detail.variant;
        let messageVal = event.detail.message;
        console.log('val from return is', titleVal, 'variantVal', variantVal, 'messageVal', messageVal);
        if (titleVal && variantVal && messageVal) {
            const evt = new ShowToastEvent({
                title: titleVal,
                variant: variantVal,
                message: messageVal
            });
            this.dispatchEvent(evt);
        }
    }*/
}