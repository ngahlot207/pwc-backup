import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord, updateRecord, deleteRecord } from "lightning/uiRecordApi";
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import APPLICANT_SUCCESS_Label from '@salesforce/label/c.ApplicantCapture_SuccessMessage';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

//Apex methods
import getSobjectDataWithMultipleChildRelation from '@salesforce/apex/incomeDetailsController.getSobjectDataWithMultipleChildRelation';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import deleteIncomeRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';

// Custom labels
import AgriIncome_Address_ErrorMessage from '@salesforce/label/c.AgriIncome_Address_ErrorMessage';
import AgriIncome_Year_ErrorMessage from '@salesforce/label/c.AgriIncome_Year_ErrorMessage';
import AgriIncome_Del_SuccessMessage from '@salesforce/label/c.AgriIncome_Del_SuccessMessage';
import AgriIncome_ReqFields_ErrorMessage from '@salesforce/label/c.AgriIncome_ReqFields_ErrorMessage';
import AgriIncome_2Years_ErrorMessage from '@salesforce/label/c.AgriIncome_2Years_ErrorMessage';
import AgriIncome_Save_SuccessMessage from '@salesforce/label/c.AgriIncome_Save_SuccessMessage';

export default class ConsolidatedAgricultureIncome extends LightningElement {

    label = {
        AgriIncome_Address_ErrorMessage,
        AgriIncome_Year_ErrorMessage,
        AgriIncome_Del_SuccessMessage,
        AgriIncome_ReqFields_ErrorMessage,
        AgriIncome_2Years_ErrorMessage,
        AgriIncome_Save_SuccessMessage

    }

    @api isSelected;
    @api layoutSize;
    @api hasEditAccess;
    @api recordId;
    @api applicantIdOnTabset;
    @api incomeType = 'Agricultural Income';


    @track recTypeId;
    @track applicantDetails;
    @track addressOptions = [];
    @track addressTypeOptions = [];
    @track monthOptions = [];
    @track yearOptions = [];
    @track averageYearlyIncome;
    @track averageMonthlyIncome;
    @track properties = [];
    @track disableMode;
    @track showSpinner = false;

    @track _recordTypeName;
    @api get recordTypeName() {
        return this._recordTypeName;
    }
    set recordTypeName(value) {

        this._recordTypeName = value;
        this.setAttribute("recordTypeName", value);

        this.handlerecordTypeNameChange(value);
    }


    @track _applicantId;
    @api get applicantId() {
        return this._applicantId;
    }
    set applicantId(value) {
        this._applicantId = value;
        this.setAttribute("applicantId", value);
        this.handleRecordAppIdChange(value)
        this.handleAddrRecordChange(value);
    }

    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
    }

    handlerecordTypeNameChange(event) {
        this.recTypeId = this._recordTypeName;
        this.handleAddrRecordChange();
    }

    handleAddrRecordChange(event) {
        let tempParams = this.Incomeparams;
        tempParams.queryCriteria = ' where Applicant__c = \'' + this._applicantId + '\'' + ' AND Applicant__c!=null AND RecordTypeId = \'' + this.recTypeId + '\''
        this.Incomeparams = { ...tempParams };
    }

    handleRecordAppIdChange(value) {
        let tempParams = this.parameter;
        tempParams.queryCriteria = 'WHERE Applicant__c=\'' + this._applicantId + '\'' + ' AND Applicant__c!=null AND Applicant__r.ApplType__c IN (\'' + 'P' + '\'' + ',\'' + 'C' + '\'' + ')'
        this.parameter = { ...tempParams };
    }
    @track
    parameter = {
        ParentObjectName: 'ApplAddr__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'AddrLine1__c', 'AddrLine2__c', 'City__c', 'Country__c', 'Pincode__c', 'State__c', 'AddrTyp__c'],
        childObjFields: [],
        queryCriteria: 'WHERE Applicant__c=\'' + this._applicantId + '\'' + ' AND Applicant__c!=null AND Applicant__r.ApplType__c IN (\'' + 'P' + '\'' + ',\'' + 'C' + '\'' + ')'
    }      

    get formCombinedQueryData(){
        if(this._applicantId && this.recTypeId){
            var combinedQuery = 'SELECT Id, AverageMonthlyAgricultureIncome__c, ' +
                            '(SELECT Id, AddrLine1__c, AddrLine2__c, City__c, Country__c, Pincode__c, State__c, LoanAppl__r.FileAcceptDate__c, AddrTyp__c FROM Applicant_Addresses__r), ' +
                            '(SELECT Id, Index__c, Address__c, Agricultural_Income_Year__c, ' +
                            'Applicant__c, RecordTypeId, Agricultural_Yearly_Income__c, ' +
                            'Address_Type__c, Other_Address__c FROM Applicant_Income__r WHERE RecordTypeId=\''+this.recTypeId + '\') ' +
                            'FROM Applicant__c ' +
                            'WHERE Id = \'' + this._applicantId + '\'';   

            return combinedQuery;
        }else{
            return '';
        }
    }

    
    @track
    Incomeparams = {
        ParentObjectName: 'Applicant_Income__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Address__c', 'Agricultural_Income_Year__c', 'Agricultural_Yearly_Income__c', 'Applicant__c', 'Address_Type__c', 'Other_Address__c', 'Applicant__r.AverageMonthlyAgricultureIncome__c'],
        childObjFields: [],
        queryCriteria: ' where Applicant__c = \'' + this._applicantId + '\'' + ' AND Applicant__c!=null AND RecordTypeId = \'' + this.recTypeId + '\''
    }     


    get displayAgricultureIncome() {

        return (this.incomeType == "Agricultural Income") ? true : false;
    }


    @track applicantAllData;
    @wire(getSobjectDataWithMultipleChildRelation, {query : '$formCombinedQueryData'})
    handleMultipleResponse(wiredResultAllData){
        let { error, data } = wiredResultAllData;
        this.applicantAllData = wiredResultAllData;
        if (data) {
            this.handleAddressData(data);
            this.formIntialYearsLabels();
        } else if (error) {

            console.error('Error Team ------------->', error);
        }
    }

    handleAddressData(data){
        this.addressTypeOptions = [];
        if(data.Applicant_Addresses__r  && data.Applicant_Addresses__r.length > 0){
            for (let i = 0; i < data.Applicant_Addresses__r.length; i++) {
                if(data.Applicant_Addresses__r[i].AddrTyp__c){
                    let addressTypeValue = { label: data.Applicant_Addresses__r[i].AddrTyp__c, value: data.Applicant_Addresses__r[i].AddrTyp__c, addressType: data.Applicant_Addresses__r[i].AddrTyp__c};

                    this.addressTypeOptions.push(addressTypeValue);
                }
                
                const addressParts = [
                    data.Applicant_Addresses__r[i].AddrLine1__c,
                    data.Applicant_Addresses__r[i].AddrLine2__c,
                    data.Applicant_Addresses__r[i].City__c,
                    data.Applicant_Addresses__r[i].Pincode__c
                ];
        
                const address = addressParts.filter(part => part).join(',');
                if (address) {
                        this.addressOptions.push({ label: address, value: data.Applicant_Addresses__r[i].Id, addressType: (data.Applicant_Addresses__r[i].AddrTyp__c ? data.Applicant_Addresses__r[i].AddrTyp__c: '')});
                    
                }
            }

        }else{
            this.showToastMessage("Warning", this.label.AgriIncome_Address_ErrorMessage, "warning", "dismissible");
        }

        if(this.addressTypeOptions.length === 0){
            var otherAddressType ={label: 'Other Address', value: 'Other Address', "addressType": "Other Address"};
            this.addressTypeOptions.push(otherAddressType);
         
        }else{
            const otherAddressExists = this.addressTypeOptions.some(option => option.label === 'Other Address');
            if (!otherAddressExists) {
                this.addressTypeOptions.push({"label": "Other Address", "value": "Other Address", "addressType": "Other Address"});
            }
        }

        if(this.addressTypeOptions && this.addressTypeOptions.length>0){
            if(data.Applicant_Income__r){
                this.actualIncomeData = data.Applicant_Income__r;
                this.handleIncomeData(this.actualIncomeData);
            }
            
        }
    }


    @wire(MessageContext)
    MessageContext;



    @track actualIncomeData;
    @track applicantIncomeData = {};

    @track yearSelected = false;
    addAddressHandler() {
        let additionalYearLabel = this.getAdditionalYear();

        if (this.properties.length >= 1) {
            if(this.yearSelected === true){
            if (this.properties[0].Address_Type__c == 'Other Address') {

                this.properties.push({
                    Index__c: this.properties.length + 1,
                    Address__c: this.properties[0].Address__c ? this.properties[0].Address__c : '',
                    Agricultural_Income_Year__c: additionalYearLabel,
                    Agricultural_Yearly_Income__c: '',
                    sobjectType: 'Applicant_Income__c',
                    RecordTypeId: this.recTypeId,
                    Address_Type__c: this.properties[0].Address_Type__c ? this.properties[0].Address_Type__c : '',
                    Other_Address__c: this.properties[0].Other_Address__c ? this.properties[0].Other_Address__c : '',
                    showOtherAddress: true,
                    disableAddress: true,
                    disableAddressType: true,
                    disableOtherAddress:true,
                    disableIncomeYear:true
                });

            } else {
                this.properties.push({
                    Index__c: this.properties.length + 1,
                    Address__c: this.properties[0].Address__c ? this.properties[0].Address__c : '',
                    Agricultural_Income_Year__c: additionalYearLabel,
                    Agricultural_Yearly_Income__c: '',
                    sobjectType: 'Applicant_Income__c',
                    RecordTypeId: this.recTypeId,
                    Address_Type__c: this.properties[0].Address_Type__c ? this.properties[0].Address_Type__c : '',
                    Other_Address__c: this.properties[0].Other_Address__c ? this.properties[0].Other_Address__c : '',
                    showOtherAddress: false,
                    disableAddress: true,
                    disableAddressType: true,
                    disableIncomeYear:true,
                    disableOtherAddress:false
                });
            }}else{
                this.showToastMessage("Error",this.label.AgriIncome_Year_ErrorMessage, "error", "dismissible");
            }
        } else {
            this.properties.push({
                Index__c: this.properties.length + 1,
                Address__c: '',
                Agricultural_Income_Year__c: additionalYearLabel,
                Agricultural_Yearly_Income__c: '',
                sobjectType: 'Applicant_Income__c',
                RecordTypeId: this.recTypeId,
                Address_Type__c: '',
                Other_Address__c: '',
                showOtherAddress: false,
                disableAddress: true,
                disableAddressType: false,
                disableOtherAddress:false,
                disableIncomeYear : false
            });
        }
    }

    getAdditionalYear() {
        if (this.properties.length > 0) {
            //const currentYear = new Date().getFullYear()
            let yearLabel = '';
            let lastSelectedYear = '';

            lastSelectedYear = this.properties[this.properties.length - 1].Agricultural_Income_Year__c ? this.properties[this.properties.length - 1].Agricultural_Income_Year__c : '';
            if (lastSelectedYear != '') {
                yearLabel = (lastSelectedYear - 1).toString();

                let yearPresent = this.pastTwoYearsLabels.filter(item =>
                    (item.label == yearLabel));

                if (yearPresent.length <= 0) {
                    this.pastTwoYearsLabels.push({ label: yearLabel, value: yearLabel });
                }

            }
            return yearLabel;   
        }

    }

    handleIncomeData(actualIncomeData) {

        let count = 1;
        if (this.actualIncomeData && this.actualIncomeData.length > 0 ) {
            this.properties = [];
            this.actualIncomeData.forEach(newItem => {
                let newObj = {
                    Index__c: this.properties.length + 1,
                    Id: newItem.Id,
                    Address_Type__c: newItem.Address_Type__c ? newItem.Address_Type__c : '',
                    Address__c: newItem.Address__c ? newItem.Address__c : '',
                    Other_Address__c: newItem.Other_Address__c ? newItem.Other_Address__c : '',
                    Agricultural_Income_Year__c: newItem.Agricultural_Income_Year__c ? newItem.Agricultural_Income_Year__c.toString() : '',
                    Agricultural_Yearly_Income__c: newItem.Agricultural_Yearly_Income__c ? newItem.Agricultural_Yearly_Income__c.toString() : '',
                    showOtherAddress: false,
                    disableAddress: true,
                    disableAddressType: false,
                    disableIncomeYear: false,
                    disableOtherAddress:true
                };
                if (count == 1) {
                    newObj.disableAddressType = false;
                    newObj.disableIncomeYear = false;
                    if(newItem.Address_Type__c === 'Other Address')
                    {
                        newObj.disableOtherAddress=false;
                    }
                }
                else {
                    newObj.disableAddressType = true;
                    newObj.disableIncomeYear = true;
                }

                if ((newItem.Address_Type__c && newItem.Address_Type__c === 'Other Address')) {
                    newObj.showOtherAddress = true;
                    newObj.disableAddress = false;
                } else {
                    newObj.showOtherAddress = false;
                    newObj.disableAddress = true;
                }

                this.properties.push(newObj);
                this.calculateAverageIncome();
                count++;
            });

            if(this.actualIncomeData[0].Agricultural_Income_Year__c !== undefined){
                this.yearSelected = true;
            }else{
                this.yearSelected = false;
            }

        }
        // else{
        //     this.addAddressHandler();
        // }
        this.index++;

    }

    get showDeleteAction() {
        return this.properties.length > 0;
    }


    @track showDeleteConfirmation = false;
    @track recordDelId;
    @track accessKeyForDeletion;
    deleteHandler(event) {
        this.showDeleteConfirmation = true;

        this.recordDelId = this.properties[event.target.accessKey - 1].Id;
        this.accessKeyForDeletion = event.target.accessKey;
    }

    hideModalBox() {
        this.showDeleteConfirmation = false;
    }

    handleConfirmDelete() {
        this.handleDeleteAction();
        this.showDeleteConfirmation = false;
    }
    handleCancelDelete() {
        this.showDeleteConfirmation = false;
    }


    handleDeleteAction(event) {

        if (this.recordDelId) {

            let deleteRecord = [
                {
                    Id: this.recordDelId,
                    sobjectType: 'Applicant_Income__c'
                }
            ]
            deleteIncomeRecord({ rcrds: deleteRecord })
            .then(result => {
               this.showToastMessage("Success", this.label.AgriIncome_Del_SuccessMessage, "success", "dismissible");
               this.showDeleteConfirmation = false;
               
            })
            .catch(error => {
                
                this.showToastMessage("Error In handleDeleteAction ", error.body.message, "error", "sticky");
                this.showDeleteConfirmation = false;
            })
        }
        else {
            this.showToastMessage("Success", this.label.AgriIncome_Del_SuccessMessage, "success", "dismissible");
            this.showDeleteConfirmation = false;
        }

        if (this.properties.length >= 1) {
            this.properties.splice(this.accessKeyForDeletion - 1, 1);

            for (let i = 0; i < this.properties.length; i++) {
                this.properties[i].Index__c = i + 1;
            }
            this.calculateAverageIncome();

        }
    }


    inputChangeHandler(event) {
        if (event.target.dataset.fieldname == "Agricultural_Yearly_Income__c") {
            this.properties[event.target.dataset.fieldname] = event.target.value;
            this.properties[event.target.accessKey - 1].Agricultural_Yearly_Income__c = event.target.value;
            this.calculateAverageIncome();
        }   

        if (event.target.dataset.fieldname == "Agricultural_Income_Year__c") {
            this.properties[event.target.dataset.fieldname] = event.target.value;
            this.properties[event.target.accessKey - 1].Agricultural_Income_Year__c = event.target.value;
            if(event.target.value !== null ){
                this.yearSelected = true;
            }
            let selectedYear = event.target.value;
            this.resetYearOptions(selectedYear);

        }

        if (event.target.dataset.fieldname == "Address_Type__c") {
            this.properties[event.target.dataset.fieldname] = event.target.value;
            this.properties[event.target.accessKey - 1].Address_Type__c = event.target.value;
            if (event.target.value) {
                if (event.target.value === 'Other Address') {
                    this.properties[event.target.accessKey - 1].showOtherAddress = true;
                    this.properties[event.target.accessKey - 1].disableAddress = false;
                    this.properties[event.target.accessKey - 1].disableOtherAddress = false;
                    this.properties["Address__c"] = null;
                    this.properties[event.target.accessKey - 1].Address__c = null;
                    this.updateOtherAddressOnProperties();
                } else {
                    this.properties["Other_Address__c"] = null;
                    this.properties[event.target.accessKey - 1].Other_Address__c = null;
                    this.properties[event.target.accessKey - 1].showOtherAddress = false;
                    this.properties[event.target.accessKey - 1].disableAddress = true;
                    for (var i = 0; i < this.addressOptions.length; i++) {
                        if (this.addressOptions[i].addressType === event.target.value) {
                            this.properties["Address__c"] = this.addressOptions[i].value;
                            this.properties[event.target.accessKey - 1].Address__c = this.addressOptions[i].value;
                            break;
                        }
                    }
                    this.updateAddressOnProperties();
                }
            }
        }

        if (event.target.dataset.fieldname == "Other_Address__c") {
            this.properties[event.target.dataset.fieldname] = event.target.value;
            this.properties[event.target.accessKey - 1].Other_Address__c = event.target.value;
            this.updateOtherAddressOnProperties();
        }
    }

    resetYearOptions(selectedYear){  
        if(selectedYear && this.properties && this.properties.length > 0){
        for(let i=1;i<this.properties.length;i++)
        {
            this.properties[i].Agricultural_Income_Year__c = selectedYear-i;
        }}
    }

    updateOtherAddressOnProperties()
    {
        for(let i=0;i<this.properties.length;i++)
        {
            this.properties[i].Other_Address__c=null;

        }
    }

    updateAddressOnProperties()
    {
        for(let i=1;i<this.properties.length;i++)
        {
            this.properties[i].Other_Address__c=null;
            this.properties[i].showOtherAddress = false;
            this.properties[i].disableAddress = true;
            this.properties[i].Address__c = this.properties[0].Address__c;
            this.properties[i].Address_Type__c = this.properties[0].Address_Type__c;
        }
    }

    updateOtherAddressOnProperties()
    {
        for(let i=0;i<this.properties.length;i++)
        {
            this.properties[i].Other_Address__c=this.properties[0].Other_Address__c;
            this.properties[i].showOtherAddress = true;
            this.properties[i].disableAddress = false;
            this.properties[i].Address__c = null;
            this.properties[i].Address_Type__c = this.properties[0].Address_Type__c;
        }
    }

    calculateAverageIncome() {
        let totalIncome = 0;
        this.averageYearlyIncome = 0;
        this.averageMonthlyIncome = 0;

        if (this.properties.length < 1) {
            this.averageYearlyIncome = 0;
            this.averageMonthlyIncome = 0;
        } else {

            for (let i = 0; i < this.properties.length; i++) {
                let yearlyIncome = 0;
                let value = parseInt(this.properties[i].Agricultural_Yearly_Income__c);
                if (!isNaN(value)) {
                    yearlyIncome = value;
                } else {
                    yearlyIncome = 0;
                }
                totalIncome = totalIncome + yearlyIncome;
            }

            this.averageYearlyIncome = (totalIncome / this.properties.length).toFixed(2);
            this.averageMonthlyIncome = (this.averageYearlyIncome / 12).toFixed(2);
        }
    }

    @api handleDeleteRecord(){
        this.handleRefreshData();
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

    pastNumberofMonths = 1; 
    pastTwoYearsLabels = [];

    connectedCallback() {
        this.handleRefreshData();
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        }
        else {
            this.disableMode = false;
        }
    }

    disconnectedCallback() {
        this.handleRefreshData();
    }

    renderedCallback() {
        this.handleRefreshData();     
    }

    handleRefreshData() {
        refreshApex(this.applicantAllData);     
    }

    formIntialYearsLabels() {
        let currentYear = new Date().getFullYear();
        let yearRange = 2;

        for (let i = 0; i < yearRange; i++) {
            const year = (currentYear - i).toString();
            const isYearExists = this.pastTwoYearsLabels.some(item => item.value === year);
                
            if (!isYearExists) {
                    this.pastTwoYearsLabels.push({ label: year, value: year });
                }
        }
    }

    @api validateForm() {
        let isValid = true
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if (element.reportValidity()) {
            } else {
                isValid = false;
                this.showToastMessage("Error",this.label.AgriIncome_ReqFields_ErrorMessage, "error", "dismissible");
            }
        });

        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
            } else {
                isValid = false;
                this.showToastMessage("Error",this.label.AgriIncome_ReqFields_ErrorMessage, "error", "dismissible");
            }
        });

        if (this.properties.length < 2) {
            isValid = false;
            this.showToastMessage("Error",this.label.AgriIncome_2Years_ErrorMessage, "error", "dismissible");
        } else {

        }

        // if (this.properties.length > 1) {
        //     const addressTypeCountMap = {};
        //     this.properties.forEach((item) => {
        //         const addressType = item.Address_Type__c;
        //         if (addressType != 'Other Address') {
        //             if (addressTypeCountMap[addressType]) {
        //                 isValid = false;
        //                 this.showToastMessage("Error", 'Multiple Records with same address and address type not allowed.', "error", "dismissible");
        //             } else {
        //                 addressTypeCountMap[addressType] = 1;
        //             }
        //         }
        //     })
        // }
        return isValid;
    }

    isEmptyObject(obj) {
        return Object.keys(obj).length === 0;
    }

    @api handleUpsert() {
        if (this.properties.length > 0 && this.isSelected == true) {
            this.showSpinner = true;
            this.applicantDetails = {
                LoanAppl__c: this.loanAppId,
                Id: this.applicantId,
                sobjectType: 'Applicant__c',
                AverageMonthlyAgricultureIncome__c : this.averageMonthlyIncome ? this.averageMonthlyIncome : 0
            };

            var valueUpdate;
            if (this.properties && this.properties.length > 0) {
                valueUpdate = this.properties;
                valueUpdate = valueUpdate.map(item => {
                    const { showOtherAddress, disableAddress,disableAddressType,disableOtherAddress,disableIncomeYear, ...rest } = item;
                    return rest;
                });
            }

            let upsertData = {
                parentRecord: this.applicantDetails,
                ChildRecords: valueUpdate,
                ParentFieldNameToUpdate: 'Applicant__c'
            }

            upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
                .then(result => {
                    this.showToastMessage("Success", this.label.AgriIncome_Save_SuccessMessage, "success", "dismissible");
                    this.showSpinner = false;
                    this.handleRefreshData();
                })
                .catch(error => {
                   
                    console.log('upsert error -', JSON.stringify(error))
                    this.showToastMessage("Error In Upsert Record ", error.body.message, "error", "sticky");
                    this.showSpinner = false;
                })
        }else{
            this.showToastMessage("Error", 'Agriculture Income Details Not Available to Save', "error", "dismissible");
            this.showSpinner = false;
        }
    }
}