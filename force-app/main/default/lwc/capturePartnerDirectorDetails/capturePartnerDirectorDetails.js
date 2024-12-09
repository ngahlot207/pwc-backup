import { LightningElement, api, wire, track } from 'lwc';

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, MessageContext } from 'lightning/messageService';
import { getRecord } from "lightning/uiRecordApi";
import { refreshApex } from '@salesforce/apex';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataWithoutCacheable';
import insertApplicantrelationData from '@salesforce/apex/captureDirectorPartnerDetails.insertApplicantrelationData';
import deleteLoanApplRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import CustProfile from '@salesforce/schema/Applicant__c.CustProfile__c';
import TypeofBorrower from '@salesforce/schema/Applicant__c.Type_of_Borrower__c';
import Constitution from '@salesforce/schema/Applicant__c.Constitution__c';
import ApplType from '@salesforce/schema/Applicant__c.ApplType__c';

const APPLICANTFIELDS = [CustProfile, TypeofBorrower, Constitution,ApplType];

export default class ObligationBankingDetails extends LightningElement {


    @track _loanApplicantId;
    @track dirPartappData;
    @track appData =[];
    @api hasEditAccess;
    @track _recordId;
    @track showDeleteConfirmation = false;
    @track applNameOptions=[];
    dobErrorMessage;
    //@track disbleAddButton = true;

    @api get loanAppId() {
        return this._loanApplicantId;
    }
    @track isApplicant = false;
    @track notIndvi = true;

    set loanAppId(value) {
        this._loanApplicantId = value;
        this.setAttribute("loanAppId", value);
        //console.log('this._loanApplicantId '+this._loanApplicantId)  
    }

    @api get recordId() {
        return this._recordId;
    }

    set recordId(value) {
        this._recordId = value;
        //console.log('this._recordId '+this._recordId)  
    }


    @track childRecords;
    getNetworkCompaniesDetails() {
        this.parentRecords = [];
        this.childRecords = [];
        let params = {
            
            ParentObjectName: 'APIVerDtl__c',
            parentObjFields: ['Id','APIVerification__r.Appl__r.FullName__c', 'Din__c', 'CompLegalName__c', 'CinNum__c', 'CompCin__c', 'FilingsStatus__c', 'CompActCompliance__c','CompIncorpDate__c','CompDesignation__c','CompDateAppoint__c','CompDateAppointCurrentDesig__c','CompDateCessation__c'],
            queryCriteria: ' where Type__c =\'Network Companies\' AND APIVerification__r.IsLatest__c =true AND APIVerification__r.Appl__c = \'' + this.recordId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                this.childRecords = result;
                //console.log('Api Verification Data is ', JSON.stringify(result));
                            })

            .catch((error) => {
                this.showSpinner = false;
                console.error('Error In getting Api Verification Data is ', error);
            });
    }

    @track parentRecords;
    @track childRecordsLoanRel;
    //@track localData;
    @track applicantRelationDetails =[];
    @track applicantRelation =[];
    @track appType;
    getDirectorPartnerDetails(){
        this.applicantRelationDetails = [];
        
        if(this.constitution === 'PRIVATE LIMITED COMPANY' || this.constitution === 'PUBLIC LIMITED COMPANY'){
            this.appType = 'D';
        }
        else if(this.constitution === 'LIMITED LIABILITY PARTNERSHIP' || this.constitution === 'PARTNERSHIP'){
            this.appType = 'PR';
        }
        let paramsforAppl = {
            ParentObjectName: 'LoanApplRelationship__c',
            parentObjFields: ['Id','Loan_Applicant__c','Designation__c','Din__c','DinStatus__c','Dsc_Status__c','DateOfAppointment__c','DateOfCessation__c','Related_Person__r.LoanAppln__c', 'Related_Person__r.Part_of_Loan_Propos__c', 'Related_Person__r.FName__c','Related_Person__r.PAN__c','Related_Person__r.DOB__c','Related_Person__r.Gender__c','Related_Person__r.Father_Name__c','Related_Person__r.DataSource__c'],
            queryCriteria: ' where Loan_Applicant__c = \'' + this.recordId + '\' AND Related_Person__r.ApplType__c =  \'' + this.appType + '\''
        }

        getSobjectData({ params: paramsforAppl })
        .then((result) => {

            for (let index = 0; index < result.length; index++) {
                const res = result[index];
                if (res) {
                    let localData = {
                        Id: res.parentRecord.Id ? res.parentRecord.Id : '',
                        Loan_Applicant: res.parentRecord.Loan_Applicant__c ? res.parentRecord.Loan_Applicant__c : '',
                        Designation: res.parentRecord.Designation__c ? res.parentRecord.Designation__c.toUpperCase() : '',
                        Din: res.parentRecord.Din__c ? res.parentRecord.Din__c : '',
                        DinStatus: res.parentRecord.DinStatus__c ? res.parentRecord.DinStatus__c : '',
                        DateOfAppointment: res.parentRecord.DateOfAppointment__c ? res.parentRecord.DateOfAppointment__c : '',
                        DateOfCessation: res.parentRecord.DateOfCessation__c ? res.parentRecord.DateOfCessation__c : '',
                        Dsc_Status: res.parentRecord.Dsc_Status__c ? res.parentRecord.Dsc_Status__c : '',
                        Related_PersonId: res.parentRecord.Related_Person__c ? res.parentRecord.Related_Person__c : '',
                        Related_Person: {
                        LoanAppln: res.parentRecord.Related_Person__r && res.parentRecord.Related_Person__r.LoanAppln__c ? res.parentRecord.Related_Person__r.LoanAppln__c : '',
                        Part_of_Loan_Propos: res.parentRecord.Related_Person__r && res.parentRecord.Related_Person__r.Part_of_Loan_Propos__c ? res.parentRecord.Related_Person__r.Part_of_Loan_Propos__c : '',
                        FName: res.parentRecord.Related_Person__r && res.parentRecord.Related_Person__r.FName__c ? res.parentRecord.Related_Person__r.FName__c : '',
                        PAN: res.parentRecord.Related_Person__r && res.parentRecord.Related_Person__r.PAN__c ? res.parentRecord.Related_Person__r.PAN__c : '',
                        DOB: res.parentRecord.Related_Person__r && res.parentRecord.Related_Person__r.DOB__c ? res.parentRecord.Related_Person__r.DOB__c : '',
                        Gender: res.parentRecord.Related_Person__r && res.parentRecord.Related_Person__r.Gender__c ? res.parentRecord.Related_Person__r.Gender__c : '',
                        Father_Name: res.parentRecord.Related_Person__r && res.parentRecord.Related_Person__r.Father_Name__c ? res.parentRecord.Related_Person__r.Father_Name__c : '',
                        DataSource: res.parentRecord.Related_Person__r && res.parentRecord.Related_Person__r.DataSource__c ? res.parentRecord.Related_Person__r.DataSource__c : '',
                        Id: res.parentRecord.Related_Person__r && res.parentRecord.Related_Person__r.Id ? res.parentRecord.Related_Person__r.Id : '',
                        isAPI: res.parentRecord.Related_Person__r && res.parentRecord.Related_Person__r.DataSource__c && res.parentRecord.Related_Person__r.DataSource__c === 'API' ? true : false,
                    },
                    isLoanPropos: res.parentRecord.Related_Person__r && res.parentRecord.Related_Person__r.Part_of_Loan_Propos__c && res.parentRecord.Related_Person__r.Part_of_Loan_Propos__c === 'YES' && res.parentRecord.Related_Person__r.DataSource__c && res.parentRecord.Related_Person__r.DataSource__c != 'API' ? true : false,
                }
                this.applicantRelationDetails.push(localData);
            }
            }
            console.log('this.applicantRelationDetails Data is ', JSON.stringify(this.applicantRelationDetails));
            //console.log('paramsforAppl Data is ', JSON.stringify(result));
            this.showSpinner = false;
        })
        .catch((error) => {
            this.showSpinner = false;
            console.error('Error In paramsforAppl Data is ', JSON.stringify(error));
        });
    }


    getApplicantsData() {
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'FullName__c','PAN__c', 'DOB__c','Gender__c','Father_Name__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND ApplType__c IN (\'P\',\'C\',\'G\') AND Constitution__c IN (\'INDIVIDUAL\')'
        }
        getSobjectData({ params: params })
            .then((result) => {
                //console.log('Applicants Data is ', JSON.stringify(result));
                for(let i=0; i<result.length; i++){
                    if(result[i].parentRecord){
                    this.appData.push(result[i].parentRecord);
                }
            }
            this.appData = this.appData.filter(appl => String(appl.Id) !== this.recordId);
            this.applNameOptions = this.appData.map(item => {
                return { label: item.FullName__c, value: item.FullName__c };
            });
            //console.log('applNameOptions Data is ', JSON.stringify(this.applNameOptions));
                //this.applicantRelationDetails = [];
                //this.getDirectorPartnerDetails();
                this.getNetworkCompaniesDetails();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.error('Error In getApplicantsData Data is ', error);
            });
    }

    partOfLoanProposalPicklist = [
        { label: 'YES', value: 'YES' },
        { label: 'NO', value: 'NO' }
    ];

    genderPicklist = [
        { label: 'MALE', value: 'M' },
        { label: 'FEMALE', value: 'F' }
    ];

    designationPicklist = [
        { label: 'DIRECTOR', value: 'DIRECTOR' },
        { label: 'PARTNER', value: 'PARTNER' },
        { label: 'SHAREHOLDER', value: 'SHAREHOLDER' },
        { label: 'KARTA', value: 'KARTA' },
        { label: 'CO-PARCENER', value: 'CO-PARCENER' },
        { label: 'TRUSTEE', value: 'TRUSTEE' }
    ];
    @track recordDelId;
    @track accessKeyForDeletion;
    @track recodID;
    deleteHandler(event) {
        // if (this.disableMode) {
        //     return;
        // }
        this.showDeleteConfirmation = true;
    
        // this.recordDelId = this.applicantRelationDetails[event.target.accessKey - 1].Id;
        // this.accessKeyForDeletion = event.target.accessKey;

        this.recordDelId = event.target.dataset.id;
        this.recodID = event.target.dataset.id;
    }
    hideModalBox(){
        this.showDeleteConfirmation = false;
    }
    
    handleConfirmDelete() {
        this.handleDeleteAction();
        this.showDeleteConfirmation = false;
    }
    handleCancelDelete() {
        this.showDeleteConfirmation = false;
    }
    handleDeleteAction(){
        this.applicantRelationDetails = this.applicantRelationDetails.filter(director => String(director.Id) !== this.recodID);
    if (this.recordDelId.length>5) {
        let deleteRecord = [
            {
                Id: this.recordDelId,
                //sobjectType: 'Applicant_Income__c'
            }
        ]
        deleteLoanApplRecord({ rcrds: deleteRecord })
        .then(result => {
           //console.log('Delete result----------->'+JSON.stringify(result));
           this.dispatchEvent(
            new ShowToastEvent({
                title: "Success",
                message: 'Record Deleted successfully.',
                variant: "success",
                mode: 'sticky'
            }))
           this.showDeleteConfirmation = false;
           this.getDirectorPartnerDetails();
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: 'Error in handleDeleteAction'+error.body.message,
                    variant: "error",
                    mode: 'sticky'
                }))
            
            //this.showToastMessage("Error in handleDeleteAction", error.body.message, "error", "sticky");
            this.showDeleteConfirmation = false;
        })
    }
    else {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Success",
                message: 'Record Deleted successfully.',
                variant: "success",
                mode: 'sticky'
            }))
        this.showDeleteConfirmation = false;
    }
}  

@track wiredDataApplicant = [];
@track appliData;
@track borrower;
@track custProfile;
@track constitution;
@track mainApplType;
@track isApplicant;
@wire(getRecord, { recordId: '$recordId', fields: APPLICANTFIELDS })
applicantData(wiredResultApplicant) {
    let { error, data } = wiredResultApplicant;
    this.wiredDataApplicant = wiredResultApplicant;
    this.appliData={}
    if (error) {
        console.error('Error fetching applicant data:', error);
    } else if (data) {
        this.appliData=data
        //console.log('appliData',JSON.stringify(this.appliData));
        this.borrower = data.fields.Type_of_Borrower__c.value;
        this.custProfile = data.fields.CustProfile__c.value;
        this.constitution = data.fields.Constitution__c.value;
        this.mainApplType = data.fields.ApplType__c.value;
        if(this.constitution === 'PRIVATE LIMITED COMPANY' || this.constitution === 'PUBLIC LIMITED COMPANY' || this.constitution === 'LIMITED LIABILITY PARTNERSHIP' || this.constitution === 'PARTNERSHIP' ){
           this.notIndvi = false;
        }
        if(this.mainApplType === 'P'){
            this.isApplicant = true;
        }
        else{
            this.isApplicant = false;
        }

        this.getDirectorPartnerDetails();
    }
}


    @track directors = [];
    @track draftValues = [];


    isApiSource(director) {
        return director.Related_Person.DataSource === 'API';
    }

    get disbleAddButton(){
        return !this.hasEditAccess;
    }

    connectedCallback(){
        console.log('this.loanAppId:: ',this.loanAppId)
        this.scribeToMessageChannel();
        this.getApplicantsData();
        //this.getDirectorPartnerDetails();
        refreshApex(this.wiredDataApplicant);
    }

    renderedCallback(){
        refreshApex(this.wiredDataApplicant);
    }

    @wire(MessageContext)
    MessageContext;
    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }
    handleSaveThroughLms(values) {
        this.handleSaveV(values.validateBeforeSave);

    }

    handleSaveV(validate) {
        //this.showSpinner = true;
        if (validate) {
            
            //this.handleSaveData();
            let isInputCorrect = this.validateForm();
            if (isInputCorrect === true) {
                //} else {
                this.handleSaveData();
                }
            else {
                this.errorMessage();
            }
        } else {
            this.handleSaveData();
        }

    }

    validateForm() {
            const isInputCorrect1 = [
                ...this.template.querySelectorAll("lightning-input"),
                ...this.template.querySelectorAll("lightning-combobox")
            ].reduce((validSoFar, inputField) => {
    
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
    
            return isInputCorrect1;
            
        }

    errorMessage() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Error",
                message: 'Please fill in all required fields.',
                variant: "error",
                mode: 'sticky'
            }))
    }

    handleSaveData(){
        //this.showSpinner = true;
        if(this.applicantRelationDetails.length > 0){
            let duplicates = []; 
            let panMap = new Map();  // To store occurrences of PANs
            this.applicantRelationDetails.forEach(record => {
                const pan = record.Related_Person.PAN;
                if (pan) {
                    if (panMap.has(pan)) {
                        // If PAN already exists, it's a duplicate
                        duplicates.push(pan);
                    } else {
                        // Store PAN in the map
                        panMap.set(pan, true);
                    }
                }
            });
            if (duplicates.length > 0) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: 'Duplicate PAN found please enter unique PAN for each Partner/Director',
                        variant: "error",
                        mode: 'sticky'
                    }))
                }
                else{
        insertApplicantrelationData({ jsonData: JSON.stringify(this.applicantRelationDetails) })
                            .then(result => {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: "Success",
                                        message: 'Director/Partner details saved successfully.',
                                        variant: "success",
                                        mode: 'sticky'
                                    }))
                                this.getDirectorPartnerDetails();
                            })
                            .catch(error => {
                                this.showSpinner = false;
                                console.error('Error In handleFinancialGSTSave ' + JSON.stringify(error));
                            })
                        }
                    }
                        else{
                            this.showSpinner = false;
                        }
    }
 

    handleAddRow() {
        let DesigType;
        if(this.appType === 'PR'){
            DesigType = 'PARTNER'
        }
        else{
            DesigType = 'DIRECTOR'
        }
        const newDirector =   {
            "Loan_Applicant": this.recordId,
            "Id": 'new'+this.applicantRelationDetails.length,
            "Designation": DesigType,
            "Din": "",
            "DinStatus": "",
            "DateOfAppointment": "",
            "DateOfCessation": "",
            "Dsc_Status": "",
            "Related_PersonId": "",
            "Related_Person": {
              "LoanAppln": this.loanAppId,
              "ApplType": this.appType,
              "Part_of_Loan_Propos": "",
              "FName": "",
              "PAN": "",
              "DOB": "",
              "Gender": "",
              "Father_Name": "",
              "DataSource": "Manual"
            }
          }
        this.applicantRelationDetails = [...this.applicantRelationDetails, newDirector];
        //console.log('Insert this.applicantRelationDetails: ', JSON.stringify(this.applicantRelationDetails))
    }



    handleDelete(event) {
        const recordId = event.target.dataset.id;
        this.applicantRelationDetails = this.applicantRelationDetails.filter(director => String(director.Id) !== recordId);
    }


    handleSave(event) {
        const updatedFields = event.detail.draftValues;
        this.directors = this.directors.map(director => {
            const updatedDirector = updatedFields.find(item => item.id === director.id);
            return updatedDirector ? { ...director, ...updatedDirector } : director;
        });

        // Clear draft values
        this.draftValues = [];

        // Show success message
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Records Updated Successfully',
                variant: 'success'
            })
        );
    }


    validateDOB(dob) {
        const date = new Date(dob);
        if (isNaN(date.getTime())) {
            return false; // Invalid date format
        }
        const currentDate = new Date();
        const minDate = new Date();
        minDate.setFullYear(minDate.getFullYear() - 18);

        if (date > currentDate || date > minDate) {
            return false; // Date of birth is in the future or less than 18 years old
        }
        return true;
    }

    is_dobError;
    dobErrorMessage;
    dob;
    handleInputChange(event) {
    
        const id = event.target.dataset.id;
        const field = event.target.dataset.field; 
        const value = event.target.value;



        this.applicantRelationDetails = this.applicantRelationDetails.map(director => {
            if (director.Id === String(id)) {
                const updatedDirector = { ...director };
                const fields = field.split('.');
                let currentObject = updatedDirector;
                for (let i = 0; i < fields.length - 1; i++) {
                    if (!currentObject[fields[i]]) {
                        currentObject[fields[i]] = {}; 
                    }
                    currentObject = currentObject[fields[i]];
                }
    
                // Set the value
                currentObject[fields[fields.length - 1]] = value.toUpperCase();
    
                return updatedDirector;
            }
            return director;
        });


        if (event.target.dataset.fieldtype === 'string') {
            let strVal = event.target.value;
            
            this.applicantRelationDetails = this.applicantRelationDetails.map(director => {
                if (director.Id === String(event.target.dataset.id)) {
                    return { ...director, [event.target.dataset.field]: strVal.toUpperCase() }; 
                }
                return director; 
            });
        }        


        if(event.target.dataset.field == "Related_Person.FName"){
                this.applicantRelationDetails = this.applicantRelationDetails.map(record => {
                    if (record.Id === String(id) && record.isLoanPropos === true) {
                        let choosenData = [];
                        choosenData = this.appData.filter(data => data.FullName__c === String(event.target.value));
                        if(choosenData.length > 0){
                        let newFName = choosenData[0].FullName__c;
                        let PANNo = choosenData[0].PAN__c;
                        let GenderNam = choosenData[0].Gender__c;
                        let FatherName = choosenData[0].Father_Name__c;
                        let DOBNo = choosenData[0].DOB__c;
                        return {
                            ...record,
                            Related_Person: {
                                ...record.Related_Person,
                                FName: newFName,
                                PAN: PANNo, 
                                Gender: GenderNam, 
                                Father_Name: FatherName, 
                                DOB: DOBNo 
                            }
                        };
                    }
                }
                    return record;
                });
            }
    
        if(event.target.dataset.field == "Related_Person.Part_of_Loan_Propos"){
            if(event.target.value == 'YES'){
                this.applicantRelationDetails = this.applicantRelationDetails.map(record => {
                    if (record.Id === String(id) && record.Related_Person.DataSource != 'API') {
                        return { ...record, isLoanPropos: true };
                    }
                    return record;
                });
            }
            else{
                this.applicantRelationDetails = this.applicantRelationDetails.map(record => {
                    if (record.Id === String(id)) {
                        return { ...record, isLoanPropos: false };
                    }
                    return record;
                });
            }
        }
    
        console.log('Inside handleInputChange data: ', JSON.stringify(this.applicantRelationDetails));
    }
    
//******************************* RESIZABLE COLUMNS *************************************//
handlemouseup(e) {
    this._tableThColumn = undefined;
    this._tableThInnerDiv = undefined;
    this._pageX = undefined;
    this._tableThWidth = undefined;
}

handlemousedown(e) {
    if (!this._initWidths) {
        this._initWidths = [];
        let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
        tableThs.forEach(th => {
            this._initWidths.push(th.style.width);
        });
    }

    this._tableThColumn = e.target.parentElement;
    this._tableThInnerDiv = e.target.parentElement;
    while (this._tableThColumn.tagName !== "TH") {
        this._tableThColumn = this._tableThColumn.parentNode;
    }
    while (!this._tableThInnerDiv.className.includes("slds-cell-fixed")) {
        this._tableThInnerDiv = this._tableThInnerDiv.parentNode;
    }
    this._pageX = e.pageX;

    this._padding = this.paddingDiff(this._tableThColumn);

    this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
}

handlemousemove(e) {
    if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
        this._diffX = e.pageX - this._pageX;

        this.template.querySelector("table").style.width = (this.template.querySelector("table") - (this._diffX)) + 'px';

        this._tableThColumn.style.width = (this._tableThWidth + this._diffX) + 'px';
        this._tableThInnerDiv.style.width = this._tableThColumn.style.width;

        let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
        let tableBodyRows = this.template.querySelectorAll("table tbody tr");
        let tableBodyTds = this.template.querySelectorAll("table tbody .dv-dynamic-width");
        tableBodyRows.forEach(row => {
            let rowTds = row.querySelectorAll(".dv-dynamic-width");
            rowTds.forEach((td, ind) => {
                rowTds[ind].style.width = tableThs[ind].style.width;
            });
        });
    }
}

handledblclickresizable() {
    let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
    let tableBodyRows = this.template.querySelectorAll("table tbody tr");
    tableThs.forEach((th, ind) => {
        th.style.width = this._initWidths[ind];
        th.querySelector(".slds-cell-fixed").style.width = this._initWidths[ind];
    });
    tableBodyRows.forEach(row => {
        let rowTds = row.querySelectorAll(".dv-dynamic-width");
        rowTds.forEach((td, ind) => {
            rowTds[ind].style.width = this._initWidths[ind];
        });
    });
}

paddingDiff(col) {

    if (this.getStyleVal(col, 'box-sizing') === 'border-box') {
        return 0;
    }

    this._padLeft = this.getStyleVal(col, 'padding-left');
    this._padRight = this.getStyleVal(col, 'padding-right');
    return (parseInt(this._padLeft, 10) + parseInt(this._padRight, 10));

}

getStyleVal(elm, css) {
    return (window.getComputedStyle(elm, null).getPropertyValue(css))
}
}