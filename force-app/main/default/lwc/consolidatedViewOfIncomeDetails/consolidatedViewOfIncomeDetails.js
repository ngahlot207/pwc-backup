import { LightningElement, api, track, wire } from 'lwc';
import getPicklist from '@salesforce/apex/captureIncomeController.getPicklistValues';
import getApplicantRecordTypes from '@salesforce/apex/captureIncomeController.getApplicantIncomeRecordTypes';
import getApplicantData from '@salesforce/apex/captureIncomeController.getApplicantData';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import deleteIncomeTypeRecords from '@salesforce/apex/captureIncomeController.deleteIncomeTypeRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import APPLICANT_OBJECT from "@salesforce/schema/Applicant__c";

import ID_FIELD from "@salesforce/schema/Applicant__c.Id";
import INCOMETYPE_FIELD from "@salesforce/schema/Applicant__c.Income_Type_Selected__c";

import { updateRecord } from "lightning/uiRecordApi";

//LMS details
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, unsubscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';

import { refreshApex } from '@salesforce/apex';
// Custom labels
import IncomeDetails_Del_SuccessMessage from '@salesforce/label/c.IncomeDetails_Del_SuccessMessage';
import IncomeDetails_ErrorMessage from '@salesforce/label/c.IncomeDetails_ErrorMessage';

export default class ConsolidatedViewOfIncomeDetails extends LightningElement {
    @track activeSection = ["A", "B", "C", "D", "E","F","G","H","I","J"];
    label = {
        IncomeDetails_Del_SuccessMessage,
        IncomeDetails_ErrorMessage

    }

    //Accordian Section variables
    //@track  activeSectionName;
    // :::::::::::::::::::
    @api currentApplTab;
    @track _applicantIdOnTabset;
    @track applicantIdtemp;
    @api loanAppId;

    @api get applicantIdOnTabset() {
        return this._applicantIdOnTabset;
    }
    set applicantIdOnTabset(value) {
        this._applicantIdOnTabset = value;
       // this.applicantIdtemp = value;

    }
    //  @api applicantIdOnTabset;
    @api hasEditAccess;
    @api layoutSize;
    @track disableMode = false;
    @track incomeTypeArray = [];
    @track displayPicklist = [];
    @track wiredPicklistvalues=[];
    @track showSpinner = false;


    @track
    parameterApplicant = {
        ParentObjectName: 'Applicant__c',
        parentObjFields: ['Id', 'Income_Type_Selected__c'],
        queryCriteria: ' where id = \'' + this._applicantIdOnTabset + '\''
    }

    @track incomeTypeValue;


    @wire(MessageContext)
    MessageContext;

    get incomeTypeDisable() {
        if (this.hasEditAccess === true) {
            return false;
        } else {
            return true;
        }
    }

    @track isEligible = false;


    @wire(getPicklist, { applcntId: '$_applicantIdOnTabset' })
    wiredPicklistData(wiredResultPicklistData) {
        //console.log('Picklist Value ------------>', JSON.stringify(wiredResultPicklistData));
        let { error, data } = wiredResultPicklistData;
        this.wiredPicklistvalues = wiredResultPicklistData;
        if (data) {
            //this.displayPicklist=[];
            this.displayPicklist = Object.keys(data).map(key => ({ label: key, value: data[key] }));
            this.displayPicklist.sort(this.compareByLabel); //picklist sorting
            this.applicantIdtemp = null;
            this.applicantIdtemp = this._applicantIdOnTabset;
        }
    }

    @track wiredApplicantValue;
    @track applicntType;
    @track isApplicant = false;
    @wire(getApplicantData, { applicantId: '$_applicantIdOnTabset' })
    wiredApplicant(wiredApplicantData) {
        let { error, data } = wiredApplicantData;
        this.wiredApplicantValue = wiredApplicantData;
        if (data) {
            //console.log('All getApplicantData>>>>', data);
            if (data.Income_Type_Selected__c) {
                this.incomeTypeValue = data.Income_Type_Selected__c;
                //console.log('inside wire of getApplicantData ', this.incomeTypeValue);
            }

            if (data.ApplType__c && data.ApplType__c === 'P') {

                this.isApplicant = true;

            }

            if (data.CustProfile__c) {
                if (data.CustProfile__c === 'HOUSEWIFE' || data.CustProfile__c === 'OTHERS') {
                    this.isEligibleToView = false;
                } else {
                    this.isEligibleToView = true;
                }
            } else {
                this.isEligibleToView = false;
            }
        } else if (error) {
            console.log('error in getting applicant record type values ' + JSON.stringify(error));
        }
    }

    @track isEligibleToView = false;

    @track wiredApplicantRecordValues;

    @wire(getApplicantRecordTypes, { appId: '$applicantIdtemp' })
    wiredApplicantRecordTypes(wiredApplicantRecordData) {
        let { error, data } = wiredApplicantRecordData;
        this.wiredApplicantRecordValues = wiredApplicantRecordData;
        console.log('outside if referesh apex ::::::::');
        if (data ) {
            console.log('referesh apex ::::::::');
            console.log('getApplicantRecordTypes ::::::::', data);

            if (data && data.length === 0) {
                this.incomeTypeValue = '';
                this.incomeTypeArray = [];
            }
            
            if (data) {  ///!this.incomeTypeArray

                this.incomeTypeArray = [];
                //console.log('data----------------->' + JSON.stringify(data));
                console.log('this.displayPicklist getApplicantRecordTypes---------->' + JSON.stringify(this.displayPicklist));
                //var transformedArray = data.map(item => ({ [item]: true, uniqueId: [item] + this._applicantIdOnTabset }));
                if (this.displayPicklist.length > 0) {
                    data.forEach(item => {
                        let tempVar = this.displayPicklist.filter(eachitem => eachitem.value == item);
                       // console.log('tempVar-------------->' + JSON.stringify(tempVar));
                        if (tempVar.length > 0) {
                           // console.log('tempVar Inside if-------------->' + JSON.stringify(tempVar));
                            let itemObj = { [item]: true, uniqueId: [item] + this._applicantIdOnTabset }
                            this.incomeTypeArray.push(itemObj);
                        }
                    });
                }
                console.log('this.incomeTypeArray------------------->'+JSON.stringify(this.incomeTypeArray));



                //this.incomeTypeArray = transformedArray;
                //console.log('incomeTypeArray 124---------------->' + JSON.stringify(this.incomeTypeArray))
            }

        } else if (error) {
            console.log('error in getting applicant record type values ' + JSON.stringify(error));
        }
    }

    //method to sort array of objects alphabetically
  compareByLabel(a, b) {
    const nameA = a.label.toUpperCase();
    const nameB = b.label.toUpperCase();

    if (nameA < nameB) {
        return -1;
    }
    if (nameA > nameB) {
        return 1;
    }
    return 0;
}



    connectedCallback() {
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        }
        //console.log('OOOOOOOO In connected', this._applicantIdOnTabset, 'ActiveTab Id:::::::::', this.currentApplTab);
        this.scribeToMessageChannel();
        refreshApex(this.wiredPicklistvalues);
        refreshApex(this.wiredApplicantValue);
        refreshApex(this.wiredApplicantRecordValues);
    }



    renderedCallback() {
        refreshApex(this.wiredPicklistvalues);
        refreshApex(this.wiredApplicantValue);
        refreshApex(this.wiredApplicantRecordValues);
    }


    handleChange(event) {

        console.log('Selected value', event.detail.value);
        console.log('is income type array', JSON.stringify(this.incomeTypeArray));
        if(event.detail.value=='CashSal')
        {
            const matchedItemIndex = this.incomeTypeArray.findIndex(item => Object.keys(item)[0] === 'BankCrSal');

            if (matchedItemIndex !== -1) {
                // Item found in the array
                const existingValue = this.incomeTypeArray[matchedItemIndex]['BankCrSal'];
                if (existingValue === true) {
                    this.showToastMessage("Error", 'Salary with Bank Credit already Selected', "error", "sticky");
                    return;
                }
            }
        }
        else if(event.detail.value=='BankCrSal')
        {
            console.log('event.detail.value 222------------>'+event.detail.value);
            const matchedItemIndex = this.incomeTypeArray.findIndex(item => Object.keys(item)[0] === 'CashSal');

            if (matchedItemIndex !== -1) {
                // Item found in the array
                console.log('matchedItemIndex 227------------>'+matchedItemIndex);
                const existingValue = this.incomeTypeArray[matchedItemIndex]['CashSal'];
                console.log('existingValue------------>'+existingValue);
                if (existingValue === true) {
                    this.showToastMessage("Error", 'Cash Salary  already Selected', "error", "sticky");
                    return;
                }
            }

        }
        var selectedValue = event.detail.value;
        this.incomeTypeValue = event.detail.value;
        const isMatch = this.incomeTypeArray.some(item => Object.keys(item)[0] === selectedValue);
        console.log('is Match', isMatch);
        //console.log('isMatch>>>>>>>', isMatch, 'selected value>>>', this.incomeTypeValue, 'income Type Array>>>>>', this.incomeTypeArray);
        
        
        if (!isMatch) {
            this.incomeTypeArray.push({ [selectedValue]: true, uniqueId: selectedValue + this._applicantIdOnTabset });
        }
        else {
            // If there is a match, check if the existing value is true or false
            const matchedItemIndex = this.incomeTypeArray.findIndex(item => Object.keys(item)[0] === selectedValue);

            if (matchedItemIndex !== -1) {
                // Item found in the array
                const existingValue = this.incomeTypeArray[matchedItemIndex][selectedValue];

                if (existingValue === false) {
                    // If the existing value is false, update it to true
                    this.incomeTypeArray[matchedItemIndex][selectedValue] = true;

                    // Perform additional actions after updating the value
                    console.log('Existing value was false. Updated to true.');
                } else {
                    // Existing value is already true
                    console.log('Existing value is true.');
                }
            }
        }
        console.log('after else income type array', JSON.stringify(this.incomeTypeArray));

    }

    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }

    @track
    parameter = {
        ParentObjectName: 'RecordType  ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'DeveloperName', 'SobjectType'],
        childObjFields: [],
        queryCriteria: 'where SobjectType=\'' + 'Applicant_Income__c' + '\''
    }
    @track CashflowRecordTypeId;
    @track RentalwBankTypeId;
    @track Rental_woBankingRecordTypeId;
    @track PensionRecordTypeId;
    @track CashSalRecordTypeId;
    @track BankCrSalRecordTypeId;
    @track Other_IncomeRecordTypeId;
    @track Other_IncomeAnnualRecordTypeId;
    @track consultingIncomeRecordTypeId;
    @track AgriIncomeRecordTypeId;



    @wire(getSobjectData, { params: '$parameter' })
    handleRecordType(wiredResult) {
        //console.log('handleRecordType>>>>> line 190', wiredResult);
        let { error, data } = wiredResult;
        if (data) {
            //console.error('data recordtypes------------->', JSON.stringify(data));
            if (data.parentRecords.length > 0) {
                for (let i = 0; i < data.parentRecords.length; i++) {
                    if (data.parentRecords[i].DeveloperName == 'RentalwBank') {
                        this.RentalwBankTypeId = data.parentRecords[i].Id;
                    }
                    if (data.parentRecords[i].DeveloperName == 'Rental_woBanking') {
                        this.Rental_woBankingRecordTypeId = data.parentRecords[i].Id;
                    }
                    if (data.parentRecords[i].DeveloperName == 'Cashflow_Map') {
                        this.CashflowRecordTypeId = data.parentRecords[i].Id;
                    }
                    if (data.parentRecords[i].DeveloperName == 'AgriIncome') {
                        this.AgriIncomeRecordTypeId = data.parentRecords[i].Id;
                    }
                    if (data.parentRecords[i].DeveloperName == 'Pension') {
                        this.PensionRecordTypeId = data.parentRecords[i].Id;
                    }
                    if (data.parentRecords[i].DeveloperName == 'CashSal') {
                        this.CashSalRecordTypeId = data.parentRecords[i].Id;
                    }
                    if (data.parentRecords[i].DeveloperName == 'BankCrSal') {
                        this.BankCrSalRecordTypeId = data.parentRecords[i].Id;
                    }
                    if (data.parentRecords[i].DeveloperName == 'Other_Income') {
                        this.Other_IncomeRecordTypeId = data.parentRecords[i].Id;
                    }
                    if (data.parentRecords[i].DeveloperName == 'Other_Income_Annual') {
                        this.Other_IncomeAnnualRecordTypeId = data.parentRecords[i].Id;
                    }
                    if (data.parentRecords[i].DeveloperName == 'Consulting_Income') {
                        this.consultingIncomeRecordTypeId = data.parentRecords[i].Id;
                    }

                }

            }
        }
        else if (error) {
            console.error('Error ------------->', error);
        }

    }

    handleSaveThroughLms(values) {
        //console.log('Values!!! '+JSON.stringify(values));
        //console.log('Values!!!11 '+JSON.stringify(this.currentApplTab));
        //console.log('Values!!!22 '+JSON.stringify(this._applicantIdOnTabset));
        var lmsTabId;
        if (values && values.tabId) {
            lmsTabId = values.tabId;
        }
        //this.handleSave(values.validateBeforeSave, lmsTabId);
    }

    handleSave(validate, lmsTabId) {
        if (lmsTabId && this.currentApplTab && this._applicantIdOnTabset && lmsTabId === this.currentApplTab && lmsTabId === this._applicantIdOnTabset) {
            if (validate) {
                if (this.isEligibleToView === true) {
                    let isInputCorrect = this.validateForm();
                    if (isInputCorrect) {
                        this.handleUpsert(lmsTabId);
                    }
                }
            } else {
                if (this.isEligibleToView === true) {
                    this.handleUpsert(lmsTabId);
                }
            }
        } else {
            return;
        }


    }

    handleUpsert(tabApplicantId) {
        if (this.incomeTypeArray) {
            this.incomeTypeArray.forEach(item => {
                for (let key in item) {
                    if (item[key] === true && key != 'uniqueId') {
                        var dynamicUniqueId = key + this._applicantIdOnTabset;
                        if (this.currentApplTab === tabApplicantId) {

                            //console.log('dynamicUniqueId>>>>', dynamicUniqueId);
                            const activeCaptureDetails = this.template.querySelectorAll(`[data-uniqueid='${dynamicUniqueId}']`);

                            if (activeCaptureDetails) {

                                activeCaptureDetails.forEach(component => {
                                    component.handleUpsert();
                                });
                            }
                        }

                    }
                }

            });
            //console.log('this.incomeTypeArray268-------->' + JSON.stringify(this.incomeTypeArray));
            //update the applicant record as well
            if (this.currentApplTab === tabApplicantId) {
                if (this.incomeTypeValue) {
                    const fields = {};
                    fields[ID_FIELD.fieldApiName] = this._applicantIdOnTabset;
                    fields[INCOMETYPE_FIELD.fieldApiName] = this.incomeTypeValue;
                    const recordInput = {
                        fields: fields
                    };
                    updateRecord(recordInput).then((record) => {
                    });
                }
            }

        }
        this.refreshData();

    }

    // handleAfterdelete(){
    //     if (this.incomeTypeArray) {
    //         this.incomeTypeArray.forEach(item => {
    //             for (let key in item) {
    //                 if (item[key] === false && key != 'uniqueId') {
    //                     var dynamicUniqueId = key + this._applicantIdOnTabset;


    //                         //console.log('dynamicUniqueId>>>>', dynamicUniqueId);
    //                         const activeCaptureDetails = this.template.querySelectorAll(`[data-uniqueid='${dynamicUniqueId}']`);

    //                         if (activeCaptureDetails) {

    //                             activeCaptureDetails.forEach(component => {
    //                                 component.handleRefreshAllData();
    //                             });
    //                         }


    //                 }
    //             }

    //         });
    //     }

    // }

    @track hideConsolidateView  = false;
    handleViewDetails(){
        if(this.hideConsolidateView === false){
            this.hideConsolidateView = true;
        }
        else{
        this.hideConsolidateView = false;
    }
    }
    validateForm() {

        let isValid = false;

        var listofComponents = [];
        if (this.incomeTypeArray) {
            this.incomeTypeArray.forEach(item => {
                for (let key in item) {
                    if (item[key] === true && key != 'uniqueId') {
                        listofComponents.push(key);
                    }
                }
            });
        }


        for (let i = 0; i < listofComponents.length; i++) {
            if (listofComponents[i]) {
                if (listofComponents[i] === 'Pension') {
                    if (this.template.querySelectorAll("c-capture-pension-income-details")) {
                        var validatePensionIncome = this.template.querySelector("c-capture-pension-income-details").validateForm();
                        if (validatePensionIncome) {
                            isValid = true;
                        } else {
                            isValid = false;
                            //break;
                        }
                    }
                }
                if (listofComponents[i] === 'Rental_woBanking') {
                    if (this.template.querySelectorAll("c-capture-rental-income-without-banking")) {
                        var validateRentalIncomewoB = this.template.querySelector("c-capture-rental-income-without-banking").validateForm();
                        if (validateRentalIncomewoB) {
                            isValid = true;
                        } else {
                            isValid = false;
                            //break;
                        }
                    }
                }
                if (listofComponents[i] === 'RentalwBank') {
                    if (this.template.querySelectorAll("c-capture-rental-income-details")) {
                        var validateRentalIncome = this.template.querySelector("c-capture-rental-income-details").validateForm();
                        if (validateRentalIncome) {
                            isValid = true;
                        } else {
                            isValid = false;
                            //break;
                        }
                    }
                }
                if (listofComponents[i] === 'CashSal') {
                    if (this.template.querySelectorAll("c-capture-salary-income")) {
                        var SalaryIncome = this.template.querySelector("c-capture-salary-income").validateForm();
                        if (SalaryIncome) {
                            isValid = true;
                        } else {
                            isValid = false;
                            //break;
                        }
                    }
                }
                if (listofComponents[i] === 'Cashflow_Map') {
                    if (this.template.querySelectorAll("c-capture-cash-flow-computation-details")) {
                        var validateCashFlowMap = this.template.querySelector("c-capture-cash-flow-computation-details").validateForm();
                        if (validateCashFlowMap) {
                            isValid = true;
                        } else {
                            isValid = false;
                            //break;
                        }
                    }
                }
                if (listofComponents[i] === 'AgriIncome') {
                    if (this.template.querySelectorAll("c-capture-agriculture-income-details")) {
                        var validateAgriIncome = this.template.querySelector("c-capture-agriculture-income-details").validateForm();
                        if (validateAgriIncome) {
                            isValid = true;
                        } else {
                            isValid = false;
                            //break;
                        }
                    }
                }
                if (listofComponents[i] === 'BankCrSal') {
                    if (this.template.querySelectorAll("c-capture-bank-credit-salary")) {
                        var BankCreditSalaryIncome = this.template.querySelector("c-capture-bank-credit-salary").validateForm();
                        if (BankCreditSalaryIncome) {
                            isValid = true;
                        } else {
                            isValid = false;
                            //break;
                        }
                    }

                }
                if (listofComponents[i] === 'Other_Income') {
                    if (this.template.querySelectorAll("c-capture-other-income-details")) {
                        var validateOtherIncome = this.template.querySelector("c-capture-other-income-details").validateForm();
                        if (validateOtherIncome) {
                            isValid = true;
                        } else {
                            isValid = false;
                            //break;
                        }
                    }
                }

                if (listofComponents[i] === 'Other_Income_Annual') {
                    if (this.template.querySelectorAll("c-capture-other-income-annual-details")) {
                        var validateOtherIncome = this.template.querySelector("c-capture-other-income-annual-details").validateForm();
                        if (validateOtherIncome) {
                            isValid = true;
                        } else {
                            isValid = false;
                            //break;
                        }
                    }
                }

                if (listofComponents[i] === 'Consulting_Income') {
                    if (this.template.querySelectorAll("c-capture-consulting-income")) {
                        var validateOtherIncome = this.template.querySelector("c-capture-consulting-income").validateForm();
                        if (validateOtherIncome) {
                            isValid = true;
                        } else {
                            isValid = false;
                            //break;
                        }
                    }
                }

            }
        }

        return isValid;
    }

    // Logic added for delete confirmation pop up message DG 
    @track showDeleteConfirmation = false;
    @track recordDelId;
    @track selectedSectionId;

    deleteHandler(event) {
        this.showDeleteConfirmation = true;
        this.selectedSectionId = event.target.dataset.sectionid;

    }

    hideModalBox() {
        this.showDeleteConfirmation = false;
    }

    handleConfirmDelete() {
        this.deleteIncomeRecord(this.selectedSectionId);
        this.showDeleteConfirmation = false;
    }
    handleCancelDelete() {
        this.showDeleteConfirmation = false;
    }


    deleteIncomeRecord(selectedSection) {
        //var selectedSection = event.target.dataset.sectionid;
        this.showSpinner = true;
        deleteIncomeTypeRecords({ applicantId: this._applicantIdOnTabset, incomeType: selectedSection })
            .then(data => {
                if (data && data === true) {
                    this.showToastMessage("Success", this.label.IncomeDetails_Del_SuccessMessage, "success", "dismissible");

                    if (this.incomeTypeArray && selectedSection) {
                        const updatedData = this.incomeTypeArray.map(item => {
                            if (item.hasOwnProperty(selectedSection)) {
                                item[selectedSection] = false;
                            }
                            //console.log('item inside::',JSON.stringify(item));
                            return item;

                        });

                        //console.log('item outside::');
                        this.incomeTypeArray = updatedData;
                        //console.log('this.incomeTypeArray ::', JSON.stringify(this.incomeTypeArray));
                    }
                    if (selectedSection === this.incomeTypeValue) {
                        this.incomeTypeValue = '';
                    }
                    //console.log('selectedSection::',selectedSection);
                    this.refreshData();
                    //this.handleAfterdelete();
                    // if (this.template.querySelectorAll("c-capture-agriculture-income-details")) {
                    //     this.template.querySelector("c-capture-agriculture-income-details").handleDeleteRecord();
                    //     // if (validateOtherIncome) {
                    //     //     isValid = true;
                    //     // } 
                    // }

                    this.showSpinner = false;
                } else {
                    this.showSpinner = false;
                    this.showToastMessage("Error", this.label.IncomeDetails_ErrorMessage, "error", "dismissible");
                }
            })
            .catch(error => {
                console.log('Error Recoed !! ' + JSON.stringify(error));
                this.showSpinner = false;
                this.showToastMessage("Error", this.label.IncomeDetails_ErrorMessage, "error", "dismissible");
            });

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

    refreshData() {
        refreshApex(this.wiredPicklistvalues);
        refreshApex(this.wiredApplicantValue);
        refreshApex(this.wiredApplicantRecordValues);
    }

}