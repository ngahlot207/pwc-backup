import { LightningElement, track, api,wire } from 'lwc';

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { formatDateFunction ,formattedDateTimeWithSeconds ,formattedDate } from 'c/dateUtility';
import getBorrowerDetails from '@salesforce/apex/ObligationDetailsSummaryController.getApplicantEmploymentDetail';
import { getRecord } from 'lightning/uiRecordApi';



export default class FinancialBorrowerEmployment extends LightningElement {


    //modified 
    @track pdDate
    @track borowerTypeName;
    @track listBorrowerDetails =[];
    @track DummylistBorrowerDetails =[];
    @api isBlPl=false;
    @api recordId;


    
      
        

    @wire(getBorrowerDetails,{ recordId: '$recordId'})
    wiredgetBorrowerDetails({ data, error }) {
       // console.log('Yesssssss-->');
        if (data) {
          //  console.log('dataYsssssss-->'+JSON.stringify(data));
            // this.listBorrowerDetails = data;
            this.listBorrowerDetails=data
            

            this.listBorrowerDetails.forEach(item => {
                    console.log(item);
                    if(item.pdDate){
                        console.log('pdDate item.pddate-->'+item.pdDate);
                        let dateTime1 = item.pdDate;
                        let formattedDate1 = formattedDateTimeWithSeconds(new Date(dateTime1));
                        let dateOfApp1 = `${formattedDate1}`;                      
                       
                        item = { ...item, pdDate: dateOfApp1 };                       
                        this.DummylistBorrowerDetails.push(item);
                    }
                    else{
                        this.DummylistBorrowerDetails.push(item); 
                    }

                 })
                 this.listBorrowerDetails=this.DummylistBorrowerDetails;
                 console.log('listBorrowerDetails 233-->'+JSON.stringify(this.listBorrowerDetails)); 
            
        } else if (error) {
            console.error('Error loading Borrower Details: ', error);
        }
    }
    // @api recordId; // = 'a08C4000005yfVKIAY';//'a08C4000005yfVKIAY';
    // @track queryParam = [];
    // @track params = {};
    // @track paramsAppl = {};
    // @track showSpinner = false;
    // @track columnsDataForTable = [
    //     {
    //         "label": "Borrower Name",
    //         "fieldName": "LoanApplicant__r.TabName__c",
    //         "type": "text",
    //         "Editable": false
    //     },
    //     {
    //         "label": "Type of Employment",
    //         "fieldName": "TypeOfOrganisation__c",
    //         "type": "text",
    //         "Editable": false
    //     },
    //     {
    //         "label": "Industry of main establishment/company",
    //         "fieldName": "MainRBIIndustry__c",
    //         "type": "text",
    //         "Editable": false
    //     },
    //     {
    //         "label": "Sub Industry of main establishment/company",
    //         "fieldName": "SubIndustry__r.Name",
    //         "type": "text",
    //         "Editable": false
    //     }
    // ];
    // @track isModalOpen = false;
    // //@track queryData = 'SELECT Name,TypeOfOrganisation__c,MainRBIIndustry__c,SubIndustry__c FROM ApplicantEmployment__c WHERE LoanApplicant__c =: recordId ';
    // @track queryData = 'Select LoanApplicant__r.TabName__c,Name,TypeOfOrganisation__c,MainRBIIndustry__c,SubIndustry__r.Name FROM ApplicantEmployment__c WHERE LoanApplicant__r.LoanAppln__c=: recordId '
    // connectedCallback() {
    //     let paramVal = [];
    //     paramVal.push({ key: 'recordId', value: this.recordId })
    //     this.queryParam = paramVal;
    //     console.log('map data:::', this.queryParam);
    //     this.params = {
    //         columnsData: this.columnsDataForTable,
    //         queryParams: this.queryParam,
    //         query: this.queryData
    //     }
    // }

    // handleIntialization() {
    //     this.isModalOpen = true;

    // }



    // handleCustomEvent(event) {
    //     this.isModalOpen = false;
    //     let spinnerValue = event.detail.spinner;
    //     if (spinnerValue) {
    //         this.showSpinner = true;
    //     } else {
    //         this.showSpinner = false;
    //     }
    //     let titleVal = event.detail.title;
    //     let variantVal = event.detail.variant;
    //     let messageVal = event.detail.message;
    //     console.log('val from return is', titleVal, 'variantVal', variantVal, 'messageVal', messageVal);
    //     if (titleVal && variantVal && messageVal) {
    //         const evt = new ShowToastEvent({
    //             title: titleVal,
    //             variant: variantVal,
    //             message: messageVal
    //         });
    //         this.dispatchEvent(evt);
    //     }
    // }
}