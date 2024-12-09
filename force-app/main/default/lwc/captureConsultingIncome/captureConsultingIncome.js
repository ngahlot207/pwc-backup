import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord, updateRecord, deleteRecord } from "lightning/uiRecordApi";
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import { refreshApex } from '@salesforce/apex';

//Apex methods
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import deleteIncomeRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';

//Custom labels
import ConsultingIncome_Save_SuccessMessage from '@salesforce/label/c.ConsultingIncome_Save_SuccessMessage';
import OtherIncome_ReqFields_ErrorMessage from '@salesforce/label/c.OtherIncome_ReqFields_ErrorMessage';
import ConsultingIncome_6months_ErrorMessage from '@salesforce/label/c.ConsultingIncome_6months_ErrorMessage';
import RentalIncWithoutBank_FileAccptdate_ErrorMessage from '@salesforce/label/c.RentalIncWithoutBank_FileAccptdate_ErrorMessage';
import Consulting_Income_Details_Deleted_Success from '@salesforce/label/c.Consulting_Income_Details_Deleted_Success';

export default class CaptureConsultingIncome extends LightningElement {
    label = {
        ConsultingIncome_Save_SuccessMessage,
        OtherIncome_ReqFields_ErrorMessage,
        ConsultingIncome_6months_ErrorMessage,
        RentalIncWithoutBank_FileAccptdate_ErrorMessage,
        Consulting_Income_Details_Deleted_Success
    }
 
    @api isSelected;
    @api layoutSize;
    @api hasEditAccess;
    @api recordId;
    // @api applicantId;

    @api applicantIdOnTabset;
    @api incomeType = 'Consulting Income';

    @track recTypeId;
    // @track applicantIdTest = 'a0AC4000000FtYrMAK';
    // loanAppI = 'a08C4000006g6LhIAI'
    @track applicantDetails;

    @track monthOptions = [];
    @track index = 0;
    @track averageMonthlyOtherIncome;
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

        this.handleAddrRecordChange(value);
    }

    handlerecordTypeNameChange(event) {
        console.log('this._recordTypeName------------->' + this._recordTypeName);
        this.recTypeId = this._recordTypeName;
        this.handleAddrRecordChange();
    }

    handleAddrRecordChange(event) {
        let tempParams = this.Incomeparams;
        tempParams.queryCriteria = ' where Applicant__c = \'' + this._applicantId + '\'' + ' AND Applicant__c!=null AND RecordTypeId = \'' + this.recTypeId + '\''
        this.Incomeparams = { ...tempParams };
    }


    @track
    Incomeparams = {
        ParentObjectName: 'Applicant_Income__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Index__c', 'Month__c', 'Monthly_Other_Income__c', 'Remark__c', 'Income_Head__c', 'Applicant__r.Average_Other_Income__c'],
        childObjFields: [],
        queryCriteria: ' where Applicant__c = \'' + this._applicantId + '\'' + ' AND Applicant__c!=null AND RecordTypeId = \'' + this.recTypeId + '\''
    }



    @wire(MessageContext)
    MessageContext;

    @track actualIncomeData;
    @track wiredData = {};
    @wire(getSobjectData, { params: '$Incomeparams' })
    handleIncomeResponse(wiredResult) {

        let { error, data } = wiredResult;
        this.wiredData = wiredResult;
        if (data) {
            this.actualIncomeData = data.parentRecords;
            this.handleIncomeData();
            console.log('in wire result OTHER iNCOME' + JSON.stringify(wiredResult));
            //console.log('in wire property' + JSON.stringify(this.actualIncomeData));                         
            // console.log('this.properties.length ;;;',this.properties.length);
            // console.log('properties in for loopc------------->',JSON.stringify(this.properties));

        } else if (error) {
            console.error('Error Team ------------->', error);
        }
        console.log('this.properties.length ;;;', this.properties.length);
        console.log('properties in for loopc------------->', JSON.stringify(this.properties));
        console.log('Wired Data ##303', JSON.stringify(this.wiredData))
        // this.wrapObj = this.wiredData;
        console.log('Wrap Data!! ', JSON.stringify(this.wrapObj));

    }

    handleIncomeData() {
        let count = 1;
        if (this.actualIncomeData && this.actualIncomeData.length > 0) {
            this.properties = [];
            this.actualIncomeData.forEach(newItem => {
                let newObj = {
                    Index__c: this.properties.length + 1,
                    Id: newItem.Id,
                    Remark__c: newItem.Remark__c ? newItem.Remark__c : '',
                    Month__c: newItem.Month__c ? newItem.Month__c.toString() : '',
                    Monthly_Other_Income__c: newItem.Monthly_Other_Income__c ? newItem.Monthly_Other_Income__c.toString() : '',
                    Income_Head__c: newItem.Income_Head__c ? newItem.Income_Head__c.toString() : '',
                    isDisabled : false
                };
                if(count == 1 && this.disableMode === false){
                    newObj.isDisabled = false;
                }else{
                    newObj.isDisabled = true;
                }
                if(count==this.actualIncomeData.length)
                {
                    this.year = '20' + newItem.Month__c.toString().split(" - ")[1];
                }
                this.properties.push(newObj);
                this.calculateAverageIncome();
                console.log('in wire index result' + JSON.stringify(this.properties.Index__c));
                count++;
            });

        }
        else {
            console.log('this.month1Options', JSON.stringify(this.month1Options));
            if (this.month1Options.length > 0) {
                console.log('inside wire');
                this.formIntialMonthsLabels();
                let intialCashSalaryData = this.formIntialCashSalaryData(this.month1Options);
                this.properties = intialCashSalaryData;
            }

        }
        console.log('this property', JSON.stringify(this.properties));
        this.index++;

    }


    monthOptions = [];
    month1Options = [];
    month2Options = [];
    month3Options = [];
    @track labelmonth1;

    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        this.handleRecordAppIdChange(value);
    }

    handleRecordAppIdChange(value) {
        let tempParams = this.parameterApplication;
        tempParams.queryCriteria = 'WHERE Id=\'' + this._loanAppId + '\''
        this.parameterApplication = { ...tempParams };
    }


    @track parameterApplication = {
        ParentObjectName: 'LoanAppl__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'FileAcceptDate__c'],
        childObjFields: [],
        queryCriteria: 'WHERE Id=\'' + this._loanAppId + '\''
    }

    getMonthName(monthNumber) {
        const monthNames = [
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
        ];

        // Adjust monthNumber since arrays are zero-based
        const adjustedMonthNumber = monthNumber - 1;

        return monthNames[adjustedMonthNumber];
    }
    getMonthNumber(monthName) {
        const monthNames = [
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
        ];

        const normalizedMonthName = monthName.trim();

        const monthNumber = monthNames.indexOf(normalizedMonthName) + 1;
        return monthNumber;

    }

    @track applicationData;
    @track noFileAcceptance = false;

    @wire(getSobjectData, { params: '$parameterApplication' })
    handleApplicationResponse(wiredDataApplication) {
        let { error, data } = wiredDataApplication;
        this.applicationData = wiredDataApplication;
        this.noFileAcceptance = false;

        console.log('applicationData', JSON.stringify(this.applicationData));
        if (error) {
            console.error('Error ------------->', error);
            return;
        }

        if (!data || !data.parentRecords || data.parentRecords.length === 0) {

            this.noFileAcceptance = true;
            //this.showToastMessage("Error", this.label.RentalIncWithoutBank_FileAccptdate_ErrorMessage, "error", "dismissible");
            return;
        }

        let dateFile = data.parentRecords[0].FileAcceptDate__c;
        console.log('dateFile', dateFile);
        if (!dateFile) {
            this.noFileAcceptance = true;
            //this.showToastMessage("Error", this.label.RentalIncWithoutBank_FileAccptdate_ErrorMessage, "error", "dismissible");
            return;
        }

        const monthOptions = [];
        const currentDate = new Date();
        var currentMonth = new Date(currentDate).getMonth();
        var currentYear = new Date(currentDate).getFullYear();
        console.log('currentMonth', currentMonth);
        console.log('currentYear', currentYear);
        const date = new Date();
        let count=0;
        for (let i = currentMonth+1; i > currentMonth - 6; i--) {
            console.log('I am I----------->' + i);
            if (i > 0) {
                monthOptions[i] = { name: this.getMonthName(i) + ' - ' + currentYear.toString().slice(-2), number: i };
                count++;
                if (!this.month1Options.some(eachmonth => eachmonth.label === this.getMonthName(i))) {
                    this.month1Options.push({ label: this.getMonthName(i) + ' - ' + currentYear.toString().slice(-2), value: this.getMonthName(i) + ' - ' + currentYear.toString().slice(-2) });
                }
            }
            else {
                    currentMonth = 12;
                    i = currentMonth;
                    currentYear = currentYear - 1;
                    monthOptions[i] = { name: this.getMonthName(i) + ' - ' + currentYear.toString().slice(-2), number: i };
                    count++;
                    if (!this.month1Options.some(eachmonth => eachmonth.label === this.getMonthName(i))) {
                        this.month1Options.push({ label: this.getMonthName(i) + ' - ' + currentYear.toString().slice(-2), value: this.getMonthName(i) + ' - ' + currentYear.toString().slice(-2) });
                    }
                
            }
            console.log('count------------>'+count);
            if(count==3)
            {
                break;
            }
        }

        this.year = currentYear;
        this.month1Options = this.month1Options.filter(element => element !== null);
        this.monthOptions = monthOptions.filter(element => element !== null);

        if (this.labelmonth1 == null || this.labelmonth1 == '' || this.labelmonth1 == undefined) {
            console.log('month1Options[0].value-------------->' + this.month1Options[0].value);
            this.labelmonth1 = this.month1Options[0].value;

        }
        let tempIncome = this.Incomeparams;
        this.Incomeparams = { ...tempIncome };

        console.log('month Options[0].value-------------->' + JSON.stringify(this.monthOptions));
        console.log('month1 Options[0].value-------------->' + JSON.stringify(this.month1Options));

        //     if(this.month1Options && this.month1Options != undefined){
        //         console.log('inside wire');
        //     this.formIntialMonthsLabels();
        //     let intialCashSalaryData = this.formIntialCashSalaryData(this.pastThreeMonthsLabels);
        //     this.properties = intialCashSalaryData;
        // }
    }

    @track isFirstMonth = true;
    addMonthHandler() {

        let dataSize = this.properties.length;
        let additionalMonthLabel = this.getAdditionalMonth(dataSize + 1);

        this.properties.push({
            Index__c: this.properties.length + 1,
            Month__c: additionalMonthLabel,
            Remark__c: '',
            Monthly_Other_Income__c: '',
            Income_Head__c: '',
            RecordTypeId: this.recTypeId,
            sobjectType: 'Applicant_Income__c',
            isDisabled: true

        });

    }
    @track date123 = new Date();
    @track year //= this.date123.getFullYear();
    getAdditionalMonth(additionalMonth) {
        if (additionalMonth) {
            //const date = new Date();
            //let tempmonth = this.monthOptions.filter(eachmonth => eachmonth.name == this.properties[this.properties.length - 1].Month__c);
            console.log('this.properties[this.properties.length - 1].Month__c.split(" - ")[0]--------->' + this.properties[this.properties.length - 1].Month__c.split(" - ")[0]);

            let monthtemp = this.getMonthNumber(this.properties[this.properties.length - 1].Month__c.split(" - ")[0]);
            console.log('monthtemp------------>' + monthtemp);
            let monthNumber = monthtemp - 1;

            if (monthtemp === 1) {
                monthNumber = 12; // Reset to January
                this.year--; // Decrement the year
            }

            //console.log('tempmonth[0].month------------>' + this.getMonthName(monthNumber));
            //console.log('tempmonth[0].number------------>' + tempmonth[0].number);

            let monthLabel = this.getMonthName(monthNumber) + ' - ' + this.year.toString().slice(-2);
            // this.month1Options.push({ label: monthLabel, value: monthLabel });
            // this.monthOptions.push({ name: monthLabel, number: monthNumber });
            // console.log('example------------>' + this.getMonthName(1));
            return monthLabel;
        }

    }
    get showDeleteAction() {
        return this.properties.length > 6;
    }

    // Logic added for delete confirmation pop up message DG 
    @track showDeleteConfirmation = false;
    @track recordDelId;
    @track accessKeyForDeletion;
    deleteHandler(event) {
        // if (this.disableMode) {
        //     return;
        // }
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

        // if (this.recordDelId) {
        //     deleteRecord(this.recordDelId)
        //         .then(() => {
        //             this.showToastMessage("Success", this.label.ConsultingIncome_Save_SuccessMessage, "success", "dismissible");
        //             refreshApex(this.wiredData);
        //         });
        // }
        if (this.recordDelId) {

            let deleteRecord = [
                {
                    Id: this.recordDelId,
                    sobjectType: 'Applicant_Income__c'
                }
            ]
            deleteIncomeRecord({ rcrds: deleteRecord })
            .then(result => {
               console.log('Delete result----------->'+JSON.stringify(result));
               this.showToastMessage("Success", this.label.Consulting_Income_Details_Deleted_Success, "success", "dismissible");
               this.showDeleteConfirmation = false;
               refreshApex(this.wiredData);
            })
            .catch(error => {
                console.log('Delete Error----------->'+JSON.stringify(error));
                this.showToastMessage("Error In handleDeleteAction ", error.body.message, "error", "sticky");
                this.showDeleteConfirmation = false;
            })
        }
        else {
            this.showToastMessage("Success", this.label.Consulting_Income_Details_Deleted_Success, "success", "dismissible");
            this.showDeleteConfirmation = false;
        }

        if (this.properties.length >= 1) {
            this.properties.splice(this.accessKeyForDeletion - 1, 1);

            for (let i = 0; i < this.properties.length; i++) {
                this.properties[i].Index__c = i + 1;
            }
            console.log('deleted properties:::: after delete', JSON.stringify(this.properties));

            this.calculateAverageIncome();
        }
    }


    inputChangeHandler(event) {
        console.log('Inside Input Change Handler:: ', event.target.value);
        if (event.target.dataset.fieldname == "Monthly_Other_Income__c") {
            // console.log('Inside Input Change Handler:: pension crredited ', event.target.value);
            this.properties[event.target.dataset.fieldname] = event.target.value;
            this.properties[event.target.accessKey - 1].Monthly_Other_Income__c = event.target.value;
            this.calculateAverageIncome();
        }


        if (event.target.dataset.fieldname == "Month__c") {
            this.properties[event.target.dataset.fieldname] = event.target.value;
            this.properties[event.target.accessKey - 1].Month__c = event.target.value;
            
            this.year = '20' + event.target.value.split(" - ")[1];
            let tempmonth = this.getMonthNumber(event.target.value.split(" - ")[0]);
            this.setAllMonths(tempmonth);
            


        }

        if (event.target.dataset.fieldname == "Income_Head__c") {
            this.properties[event.target.dataset.fieldname] = event.target.value;
            this.properties[event.target.accessKey - 1].Income_Head__c = event.target.value;

            if (event.target.dataset.fieldtype === 'string') {
                let strVal = event.target.value;
                this.properties[event.target.accessKey - 1].Income_Head__c = strVal.toUpperCase();
            }
        }

        if (event.target.dataset.fieldname == "Remark__c") {
            this.properties[event.target.accessKey - 1].Remark__c = event.target.value;
        }

    }

    setAllMonths(tempmonth) {
        console.log('tempmonth 395------------>' + tempmonth);
        
        let storemonth = [];
        let count = 0;
        for (let i = 1; i < this.properties.length; i++) {
            console.log('tempmonth------------>' + (tempmonth - 1));
            console.log('i-------------->' + i);
            console.log('this.getMonthName(tempmonth[0].number - 1)-------------->' + this.getMonthName(tempmonth - 1));

            if ((tempmonth - 1) > 0) {
                this.properties[i].Month__c = this.getMonthName(tempmonth - 1) + ' - ' + this.year.toString().slice(-2);
                //storemonth.push(this.getMonthName(tempmonth- 1) + ' - ' + this.year.toString().slice(-2));

            }
            else {
                this.year--;
                tempmonth = 13;
                this.properties[i].Month__c = this.getMonthName(tempmonth - 1) + ' - ' + this.year.toString().slice(-2);
            }
            tempmonth = (tempmonth - 1);
        }
        console.log('storemonth------------>' + storemonth);

    }




    calculateAverageIncome() {
        console.log('Inside calculateAverageIncome');
        let totalIncome = 0;
        this.averageMonthlyOtherIncome = 0;
        if (this.properties.length < 1) {
            this.averageMonthlyOtherIncome = 0;
            console.log('Inside property length check');
        } else {

            for (let i = 0; i < this.properties.length; i++) {
                let monthlyIncome = 0;
                let value = parseInt(this.properties[i].Monthly_Other_Income__c);
                if (!isNaN(value)) {
                    monthlyIncome = value;
                } else {
                    monthlyIncome = 0;
                }
                totalIncome = totalIncome + monthlyIncome;
            }

            this.averageMonthlyOtherIncome = (totalIncome / this.properties.length).toFixed(2);
            console.log('In else block average monthly icome', this.averageMonthlyOtherIncome);
        }



    }
    showToastMessage(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }

    pastNumberofMonths = 3;
    pastThreeMonthsLabels = [];

    connectedCallback() {
        console.log('this.month1Options in connec', this.month1Options.length);

        //     if(this.month1Options != undefined){
        //         console.log('this.month');
        //     this.formIntialMonthsLabels();
        //     let intialCashSalaryData = this.formIntialCashSalaryData(this.pastThreeMonthsLabels);
        //     this.properties = intialCashSalaryData;
        // }

        refreshApex(this.wiredData);
        //this.populateMonthOptions();



        if (this.hasEditAccess === false) {
            this.disableMode = true;
        }
        else {
            this.disableMode = false;
        }

    }
    disconnectedCallback() {
        refreshApex(this.wiredData);

    }

    formIntialMonthsLabels() {
        for (let i = 1; i <= this.pastNumberofMonths; i++) {
            const date = new Date();
            date.setMonth(date.getMonth() - i);
            let monthLabel = date.toLocaleString('default', { month: 'long' }) + ' - ' + date.getFullYear().toString().slice(-2);
            this.pastThreeMonthsLabels.push(monthLabel);


        }
        console.log('pastThreeMonthsLabels::', this.pastThreeMonthsLabels);
    }

    formIntialCashSalaryData(month1Options) {
        let intialCashSalaryData = [];
        for (let i = 0; i < 6; i++) {

            let dataRow = Object.assign({}, this.cashSalaryDataObj);
            // dataRow.key = i + 1;
            dataRow['isDisabled'] = ((i == 0 && this.disableMode === false) ? false : true);
            dataRow['Month__c'] = this.month1Options[i].value;
            dataRow['Monthly_Other_Income__c'] = '';
            dataRow['Income_Head__c'] = '';
            dataRow['Remark__c'] = '';
            dataRow['RecordTypeId'] = this.recTypeId;
            dataRow['sobjectType'] = 'Applicant_Income__c';
            dataRow['Index__c'] = i + 1,

                intialCashSalaryData.push(dataRow);

        }

        return intialCashSalaryData;
    }
    // populateMonthOptions() {
    //         const currentDate = new Date();
    //         const currentYear = currentDate.getFullYear();
    //         const currentMonth = currentDate.getMonth();

    //         const months = [
    //             'January', 'February', 'March', 'April', 'May', 'June',
    //             'July', 'August', 'September', 'October', 'November', 'December'
    //         ];

    //         const monthOptions = [];
    //         console.log('populateMonthOptions ------------->');
    //         // Loop from the last month to the current month of the current year
    //         for (let i = currentMonth - 1; i >= 0; i--) {
    //             const monthLabel = `${months[i]}-${currentYear}`;
    //             monthOptions.push({ label: monthLabel, value: monthLabel });
    //             console.log('monthLabel 42------------->', monthLabel);
    //         }

    //         this.monthOptions = monthOptions;
    //         console.log('monthOptions 46------------->', this.monthOptions);

    //     }

    @api validateForm() {
        console.log('child other income validateForm');
        let isValid = true

        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if (element.reportValidity()) {
                //console.log('element passed combobox');
                //console.log('element if--'+element.value);
            } else {
                isValid = false;
                this.showToastMessage("Error", this.label.OtherIncome_ReqFields_ErrorMessage, "error", "dismissible");
                //console.log('element else--'+element.value);
            }
        });

        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
                //console.log('element passed lightning input');
            } else {
                isValid = false;
                this.showToastMessage("Error", this.label.OtherIncome_ReqFields_ErrorMessage, "error", "dismissible");
            }
        });
        if (this.properties.length < 6) {
            isValid = false;
            this.showToastMessage("Error", this.label.ConsultingIncome_6months_ErrorMessage, "error", "dismissible");
        } else {

        }
        return isValid;
    }


    @api handleUpsert() {
        if (this.properties.length > 0 && this.isSelected === true) {
            this.showSpinner = true;

            this.applicantDetails = {
                LoanAppl__c: this.loanAppId,
                Id: this.applicantId,
                sobjectType: 'Applicant__c'
            };

            console.log('this.applicantDetails Other after-------->' + JSON.stringify(this.applicantDetails));
            var parentApplicant;
            parentApplicant = { ...this.applicantDetails };
            parentApplicant.Average_Other_Income__c = this.averageMonthlyOtherIncome ? this.averageMonthlyOtherIncome : 0;


            let upsertData = {
                parentRecord: parentApplicant,
                ChildRecords: this.properties,
                ParentFieldNameToUpdate: 'Applicant__c'
            }
            console.log('upsertData 334-', JSON.stringify(upsertData));
            upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
                .then(result => {
                    this.showToastMessage("Success", this.label.ConsultingIncome_Save_SuccessMessage, "success", "dismissible");
                    refreshApex(this.wiredData);
                    this.showSpinner = false;
                 
                })
                .catch(error => {
                    console.error(error)
                    console.log('upsert error -', JSON.stringify(error));
                    this.showToastMessage("Error In Upsert Record ", error.body.message, "error", "sticky");
                    this.showSpinner = false;
                })
        }else{
            this.showToastMessage("Error", 'Consulting Income Details Not Available to Save', "error", "dismissible");
            this.showSpinner = false;
        }
    }

}