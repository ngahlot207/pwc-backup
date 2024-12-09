import { LightningElement, api, wire, track } from 'lwc';

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getLoanAppData from '@salesforce/apex/ObligationDetailsSummaryController.getLoanAppData';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import createDocumentDetail from "@salesforce/apex/DocumentDetailController.createDocumentDetail";
import generateDocument from "@salesforce/apex/GeneratePDFandAttachToLoanApplication.generateDocument";
import PageURLCAMReporrt from '@salesforce/label/c.PageURLCAMReporrt';
import BLPL_Page_URL_CAMReport from '@salesforce/label/c.BLPL_Page_URL_CAMReport';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getFilterRelRecordsWithOutCache from '@salesforce/apex/SObjectDynamicRecordProvider.getFilterRelRecordsWithOutCache';


export default class UWSummaryView extends LightningElement {

    @api recordId;
    @api hasEditAccess;

    label = {
        PageURLCAMReporrt,
        BLPL_Page_URL_CAMReport

    };
    @track isReadOnly = false;
    @track docType = 'CAM Report';
    @track docSubType = 'CAM Report';
    @track docCategory = 'CAM Report';
    @track showCAMReports = false;
    @track showSpinner = false;
    @track loanApplicationRecord = [];

    //@track recorddId='';
    @track activeSection = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O","P"];
    //LAK-7316 - Changes under BIL UW Summary
    @track isBLorPL = false;
    @track isHl = false;
    //console.log('recordId-->'+recordId);
    //this.recorddId = this.recordId;

    connectedCallback() {
        if (this.hasEditAccess === false) {
            this.isReadOnly = true;
        }
        console.log('Parent recordId-->' + this.recordId);
        this.FinancialApplicantData();
        this.getLoanAppData();
    }

    // @wire(getLoanAppData,{ recordId: '$recordId'})
    // wiredgetLoanAppData({ data, error }) {

    //     if (data) {

    //         this.loanApplicationRecord = data;
    //         console.log('loanApplicationRecord-->'+JSON.stringify(this.loanApplicationRecord));


    //     } else if (error) {
    //         console.error('Error loading Loan Application Data: ', error);
    //     }
    // }
    @track showGst = false;
    @track showFinState = false;
    FinancialApplicantData(){
        const appData = {
            ParentObjectName: 'Applicant__c ',
            ChildObjectRelName: 'Applicant_Employments__r',
            parentObjFields: ['Id', 'Type_of_Borrower__c','Constitution__c', 'FullName__c','LoanAppln__c'],
            childObjFields: ['Id','GST_Registered__c '],
            queryCriteria: ' where LoanAppln__c = \'' + this.recordId + '\' and Type_of_Borrower__c = \'Financial\' and Constitution__c != \'INDIVIDUAL\''
        }
        getFilterRelRecordsWithOutCache({params : appData})
     .then((result)=>{
        console.log('Wire Applicant statement----------->');
        console.log(result);
        this.applData = result;
        if(this.applData.parentRecord ){
            this.showFinState = true;
        }
        
        if(this.applData.ChildReords && this.applData.ChildReords.length > 0){
            this.applData.ChildReords.forEach((item)=>{
                if(item.GST_Registered__c && item.GST_Registered__c === 'YES'){
                    this.showGst = true;
                }
            })
        }
         
    } ).catch(error => {
        console.log(error);})
}


    getLoanAppData() {
        let paramsLoanApp = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Id', 'EMIOptionsintranchedisbursementCase__c', 'Total_PF_Amount__c', 'RemPFDeductFromDisbursementAmount__c', 'FirstEMIDate__c', 'Applicant__c', 'Product__c',''],
            queryCriteria: ' where Id = \'' + this.recordId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Loan application data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    //this.repayAccData = result.parentRecords;
                    this.loanApplicationRecord = { ...result.parentRecords[0] };
                    this.showCAMReports = true;
                    console.log('this.loanApplicationRecord-->' + JSON.stringify(this.loanApplicationRecord));
                    if(this.loanApplicationRecord.Product__c && (this.loanApplicationRecord.Product__c == 'Business Loan' || this.loanApplicationRecord.Product__c == 'Personal Loan')){
                        this.isBLorPL = true;
                    }
                    else if(this.loanApplicationRecord.Product__c && this.loanApplicationRecord.Product__c == 'Home Loan'){
                        this.isHl = true;
                    }
                }
                
            })
            .catch((error) => {
                console.log('Error In getting Loan Application Data ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    showToast(titleVal, variantVal, messageVal, mode) {
        const evt = new ShowToastEvent({
            title: titleVal,
            variant: variantVal,
            message: messageVal,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    handleGenerateDocuments() {
        this.showSpinner = true;
        // this.showDocList = false;
        this.showCAMReports = false;
        createDocumentDetail({ applicantId: this.loanApplicationRecord.Applicant__c, loanAppId: this.loanApplicationRecord.Id, docCategory: 'CAM Report', docType: 'CAM Report', docSubType: 'CAM Report', availableInFile: false })
            .then((result) => {
                console.log('createDocumentDetailRecord result ', result);
                this.DocumentDetaiId = result;
                console.log('createDocumentDetailRecord DocumentDetaiId ', this.DocumentDetaiId);

                //here we need to use correct label based on if condition
                //this.label.sanctionLetter;
                //this.label.sanctionLetterBT
                
                let pageUrl;
                if(this.isBLorPL == true){
                    pageUrl = this.label.BLPL_Page_URL_CAMReport + this.loanApplicationRecord.Id;
                }
                else{
                    pageUrl = this.label.PageURLCAMReporrt + this.loanApplicationRecord.Id;
}
                
                                const pdfData = {
                    pageUrl: pageUrl,
                    docDetailId: this.DocumentDetaiId,
                    fileName: 'CAM Report.pdf'
                }
                this.generateDocument(pdfData);
                //this.updateApplicantBanking();
                //this.fileUploadHandler();

            })
            .catch((err) => {
                this.showCAMReports = true;
                this.showSpinner = false;
                this.showToast("Error CAM", "error", err, "sticky");
                console.log(" createDocumentDetailRecord error===", err);
            });
    }

    generateDocument(pdfData) {
        generateDocument({ wrapObj: pdfData })
            .then((result) => {
                this.showSpinner = false;
                if (result == 'success') {
                    this.forLatestDocDetailRec();
                    // this.refreshDocTable();
                } else {
                    console.log(result);
                }
                //this.updateApplicantBanking();
                //this.fileUploadHandler();

            })
            .catch((err) => {
                this.showCAMReports = true;
                this.showToast("Error", "error", err, "sticky");
                console.log(" createDocumentDetailRecord error===", err);
            });
    }


    forLatestDocDetailRec() {
        var listOfAllParent = [];
        var paramForIsLatest = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'Appl__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c'],
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this.loanApplicationRecord.Id + '\' AND DocCatgry__c = \'CAM Report\' AND DocTyp__c = \'CAM Report\' AND DocSubTyp__c = \'CAM Report\''   //AND Appl__c = \'' + this.loanApplicationRecord.Applicant__c + '\'
        }
        getSobjectData({ params: paramForIsLatest })
            .then((result) => {
                console.log('islatestdata 13899999', this.DocumentDetaiId);
                if (result.parentRecords) {
                    listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
                }
                let oldRecords = []
                oldRecords = listOfAllParent.filter(record => record.Id !== this.DocumentDetaiId);
                //console.log('oldRecords>>>>>'+JSON.stringify(oldRecords))
                let isLatestFalseRecs = []
                isLatestFalseRecs = oldRecords.map(record => {
                    return { ...record, IsLatest__c: false };
                    return record;
                });
                let obj = {
                    Id: this.DocumentDetaiId,
                    NDCDataEntry__c: 'Completed'
                }
                isLatestFalseRecs.push(obj);
                console.log('isLatestFalseRecs>>>>>' + JSON.stringify(isLatestFalseRecs))
                upsertMultipleRecord({ params: isLatestFalseRecs })
                    .then(result => {
                        console.log('resultresultresultresultresult' + JSON.stringify(result));
                        this.refreshDocTable();
                        //this.showDocList = true;               

                    }).catch(error => {
                        console.log('778' + error)
                    })

            })
            .catch((error) => {
                console.log('Error In getting 13899999 ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    refreshDocTable() {
        this.showCAMReports = true;
    }
}