import { LightningElement, api, wire, track } from 'lwc';

//apex methods import to fetch data
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import deleteRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';


//Object inof 
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import APPLICANT_INCOME_OBJECT from "@salesforce/schema/Applicant_Income__c";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import LOGIN_ACCEPTANCE_DATE_FIELD from "@salesforce/schema/LoanAppl__c.LoginAcceptDate__c";


import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Custom labels 
import BankCreditSalary_Deduction_ErrorMessage from '@salesforce/label/c.BankCreditSalary_Deduction_ErrorMessage';
import BankCreditSalary_Del_SuccessMessage from '@salesforce/label/c.BankCreditSalary_Del_SuccessMessage';
import BankCreditSalary_Del_ErrorMessage from '@salesforce/label/c.BankCreditSalary_Del_ErrorMessage';
import BankCreditSalary_Save_SuccessMessage from '@salesforce/label/c.BankCreditSalary_Save_SuccessMessage';
import BankCreditSalary_Save_ErrorMessage from '@salesforce/label/c.BankCreditSalary_Save_ErrorMessage';
import RentalIncWithoutBank_FileAccptdate_ErrorMessage from '@salesforce/label/c.RentalIncWithoutBank_FileAccptdate_ErrorMessage';

export default class ConsolidatedBankCredit extends LightningElement {

    label = {
        BankCreditSalary_Deduction_ErrorMessage,
        BankCreditSalary_Del_SuccessMessage,
        BankCreditSalary_Del_ErrorMessage,
        BankCreditSalary_Save_SuccessMessage,
        BankCreditSalary_Save_ErrorMessage,
        RentalIncWithoutBank_FileAccptdate_ErrorMessage
    }

    // eligibility consideration column variable
    @track eliWrapObj = {};
    //public properties
    @api layoutSize;
    @api hasEditAccess;
    @api recordId;
    @track showSpinner = false;
    @track _applicantId;
    @api get applicantId() {
        return this._applicantId;
    }
    set applicantId(value) {
        this._applicantId = value;
        this.setAttribute("applicantId", value);

        this.handleAddrRecordChange(value);
        this.handleBRESalaryRecordChange(value);
    }

    @api get recordTypeName() {
        return this._recordTypeName;
    }
    set recordTypeName(value) {

        this._recordTypeName = value;
        this.setAttribute("recordTypeName", value);

        this.handlerecordTypeNameChange(value);
    }

    // @api loanAppId;
    @api applicantIdOnTabset;
    @api isSelected;


    @track bankCreditSalaryData = [];
    @track applicantRecord;

    applicantIncomeInfo;
    pastNumberofMonths = 3;
    pastThreeMonthsLabels = [];


    bankCreditSalaryHeaders = [
        { 'key': 1, 'columnName': 'Salary Months', 'style': "" },
        { 'key': 2, 'columnName': 'Gross Salary (Rs)', 'required': true, 'style': "min-width: 12rem;display:flex;" },
        { 'key': 3, 'columnName': 'Variable Component (Rs)', 'required': true, 'style': "min-width: 12rem;display:flex;" },
        { 'key': 4, 'columnName': 'LTA (Monthly) (Rs)', 'required': true, 'style': "min-width: 12rem;display:flex;" },
        { 'key': 5, 'columnName': 'Performance Bonus (Monthly) (Rs)', 'required': true, 'style': "min-width: 12rem;display:flex;" },
        { 'key': 6, 'columnName': 'Taxes (Rs)', 'required': true, 'style': "min-width: 12rem;display:flex;" },
        { 'key': 7, 'columnName': 'Other Deductions (Rs)', 'required': true, 'style': "min-width: 12rem;display:flex;" },
        { 'key': 8, 'columnName': 'Net Salary (Rs)', 'required': true, 'style': "min-width: 12rem;display:flex;" },
        { 'key': 11, 'columnName': 'Other Salary Component (outside payslip) (Rs)', 'required': true, 'style': "min-width: 12rem;display:flex;" }

    ];

    applicantIncomeFields = ['Id', 'Month__c', 'Gross_Salary_Rs__c', 'Variable_Component__c', 'LTA_Monthly__c', 'Performance_Bonus_Monthly__c',
        'Taxes__c', 'Other_Deductions__c', 'Net_Salary__c', 'Bank_Credit_Date__c', 'Other_Salary_Component__c', 'Remark__c'];

    bankCreditsalaryDataObj = {
        Id: '', key: '', Month__c: '', Gross_Salary_Rs__c: '', Variable_Component__c: '', LTA_Monthly__c: '', Performance_Bonus_Monthly__c: '',
        Taxes__c: '', Other_Deductions__c: '', Net_Salary__c: '', Bank_Credit_Date__c: '', Remark__c: '', Other_Salary_Component__c: ''
    };


    //Getter setter 
    get averageGrossSalary() {
        const salaries = this.bankCreditSalaryData.map((row) => parseFloat(row.Gross_Salary_Rs__c) || 0);
        return this.getAverageOfDataArray(salaries);
    }

    get averageVariableCmp() {
        const salaries = this.bankCreditSalaryData.map((row) => parseFloat(row.Variable_Component__c) || 0);
        return this.getAverageOfDataArray(salaries);
    }

    get averageLTA() {
        const salaries = this.bankCreditSalaryData.map((row) => parseFloat(row.LTA_Monthly__c) || 0);
        return this.getAverageOfDataArray(salaries);
    }

    get averagePerformanceBonus() {
        const salaries = this.bankCreditSalaryData.map((row) => parseFloat(row.Performance_Bonus_Monthly__c) || 0);
        return this.getAverageOfDataArray(salaries);
    }

    get averageTaxes() {
        const salaries = this.bankCreditSalaryData.map((row) => parseFloat(row.Taxes__c) || 0);
        return this.getAverageOfDataArray(salaries);
    }

    get averageOtherDeduction() {
        const salaries = this.bankCreditSalaryData.map((row) => parseFloat(row.Other_Deductions__c) || 0);
        return this.getAverageOfDataArray(salaries);
    }

    get averageNetSalary() {
        const salaries = this.bankCreditSalaryData.map((row) => parseFloat(row.Net_Salary__c) || 0);
        return this.getAverageOfDataArray(salaries);
    }

    get averageOtherSalary() {
        const salaries = this.bankCreditSalaryData.map((row) => parseFloat(row.Other_Salary_Component__c) || 0);
        return this.getAverageOfDataArray(salaries);
    }

    getAverageOfDataArray(salaries) {
        const totalSalary = salaries.reduce((acc, salary) => acc + salary, 0);
        const average = salaries.length > 0 ? totalSalary / salaries.length : 0;
        if (average === 0) {
            return '';
        }
        else {
            return average.toFixed(2);
        }

    }

    get showDeleteAction() {
        return this.bankCreditSalaryData.length > 3;
    }


    get bankCreditSalaryRTId() {
        if (this.applicantIncomeObjMetadata && this.applicantIncomeObjMetadata.data && this.applicantIncomeObjMetadata.data.recordTypeInfos) {
            const recordTypesInfos = this.applicantIncomeObjMetadata.data.recordTypeInfos;
            return Object.keys(recordTypesInfos).find((recordType) => recordTypesInfos[recordType].name === "Bank Credit Salary");
        }
    }
    //wire methods to get data
    @wire(getObjectInfo, { objectApiName: APPLICANT_INCOME_OBJECT })
    applicantIncomeObjMetadata

    @wire(getRecord, {
        recordId: '$loanAppId',
        fields: [LOGIN_ACCEPTANCE_DATE_FIELD]
    })
    loanAppRecordInfo;

    get loginAccptDate() {
        return getFieldValue(this.loanAppRecordInfo.data, LOGIN_ACCEPTANCE_DATE_FIELD);
    }

    // get maxDateRange() {
    //     let currDate = new Date();
    //     currDate.setMonth(currDate.getMonth() + 1);
    //     let maxDate = currDate.getFullYear() + '-' + currDate.getMonth() + '-' + currDate.getDate();
    //     return maxDate;
    // }
    ///
    get maxDateRange() {
        const currentDate = new Date();
        const currentDateTimeString = currentDate;

        return currentDateTimeString;
    }
    ///

    get minDateRange() {
        let maxDate = new Date(this.loginAccptDate);
        console.log('maxDate', maxDate);
        maxDate.setFullYear(maxDate.getFullYear() - 1);
        maxDate.setMonth(maxDate.getMonth() + 1);
        let minDate = maxDate.getFullYear() + '-' + maxDate.getMonth() + '-' + maxDate.getDate();
        console.log('minDate', minDate);
        return minDate;
    }

    //parameters to get data from apex

    handleAddrRecordChange(event) {
        let recordTypeTemp = this.applicantIncomeObjMetadata;
        this.applicantIncomeObjMetadata = { ...recordTypeTemp };
        let tempParams = this.parameterApplicantIncome;
        tempParams.queryCriteria = ' WHERE Applicant__c = \'' + this._applicantId + '\'' + ' AND RecordTypeId = \'' + this.recTypeId + '\''
        this.parameterApplicantIncome = { ...tempParams };
    }

    @track parameterApplicantIncome = {
        ParentObjectName: 'Applicant_Income__c',
        parentObjFields: this.applicantIncomeFields,
        queryCriteria: ' WHERE Applicant__c = \'' + this._applicantId + '\'' + ' AND RecordTypeId = \'' + this.recTypeId + '\''
    }

    handlerecordTypeNameChange(event) {
        console.log('this._recordTypeName------------->' + this._recordTypeName);
        this.recTypeId = this._recordTypeName;
        this.handleAddrRecordChange();
    }

    // get parameterApplicantIncome() {
    //     let params = {
    //         ParentObjectName: 'Applicant_Income__c',
    //         parentObjFields: this.applicantIncomeFields,
    //         queryCriteria: ' WHERE Applicant__c = \'' + this.applicantId + '\'' + ' AND RecordTypeId = \'' + this.bankCreditSalaryRTId + '\''
    //     }
    //     return params;
    // }

    @wire(getSobjectData, { params: '$parameterApplicantIncome' })
    creditSalaryDetails(returnData) {
        this.applicantIncomeInfo = returnData;
        let { data, error } = returnData;
        if (data) {
            if (data.parentRecords && data.parentRecords != undefined) {
                this.bankCreditSalaryData = [];
                let idx = 1;
                data.parentRecords.forEach(item => {
                    let newDataObj = Object.assign({}, this.bankCreditsalaryDataObj);
                    Object.keys(this.bankCreditsalaryDataObj).forEach(key => {
                        if (key === "key") {
                            newDataObj[key] = idx;
                        }
                        else if (key === "Bank_Credit_Date__c" || key === "Remark__c") {
                            newDataObj[key] = item[key] ? item[key] : '';
                        }
                        else {
                            newDataObj[key] = item[key] ? item[key] : 0;
                        }
                        if (idx == 1) {
                            newDataObj.isDisabled = this.disableMode === true ? true : false;
                        }
                        else {
                            newDataObj.isDisabled =  true ;
                        }
                        if (idx == data.parentRecords.length) {
                            this.year = '20' + newDataObj.Month__c.toString().split(" - ")[1];
                        }
                    })
                    idx++;
                    this.bankCreditSalaryData.push(newDataObj);
                })
                //this.sortSalaryMonths(this.bankCreditSalaryData);
            }
            else {
                console.log('this.month1Options------>', JSON.stringify(this.month1Options));
                if (this.month1Options.length > 0) {
                    this.formIntialMonthsLabels();
                    let intialBankCashSalaryData = this.formIntialBankCreditSalaryData(this.pastThreeMonthsLabels);
                    this.bankCreditSalaryData = intialBankCashSalaryData;
                }
            }
        }
        else if (error) {
            console.log('Error occured in fetching income details ' + error);
        }
    }

    sortSalaryMonths(displayData) {
        let months = displayData.map(item => item.Month__c);
        months.sort((a, b) => {
            const monthOrder = ['December', 'November', 'October', 'September', 'August', 'July', 'June', 'May', 'April', 'March', 'February', 'January'];
            let monthA = a.split('-')[0].trim();
            let yearA = a.split('-')[1].trim();
            let monthB = b.split('-')[0].trim();
            let yearB = b.split('-')[1].trim();
            if (yearA > yearB) {
                return -1;
            }
            else {
                return monthOrder.indexOf(monthA) - monthOrder.indexOf(monthB);
            }
        });
        displayData.sort((a, b) => {
            return months.indexOf(a.Month__c) - months.indexOf(b.Month__c);
        })
    }

    get paramsApplicant() {
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'Average_Net_Salary__c', 'Average_Monthly_Gross_Salary__c'],
            queryCriteria: ' WHERE Id = \'' + this.applicantId + '\''
        }
        return params;
    }

    @wire(getSobjectData, { params: '$paramsApplicant' })
    applicantInfo(retunData) {
        let { data, error } = retunData;
        if (data) {
            this.applicantRecord = data.parentRecords;
        }
        else if (error) {
            console.log('Error occured in fetching Appilcant details ' + error);
        }
    }



    monthOptions = [];
    @track month1Options = [];
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

        if (!data || !data.parentRecords || data.parentRecords === undefined) {

            this.noFileAcceptance = true;
            this.showToastMessage("Error", this.label.RentalIncWithoutBank_FileAccptdate_ErrorMessage, "error", "dismissible");
            return;
        }

        let dateFile = data.parentRecords[0].FileAcceptDate__c;
        console.log('dateFile', dateFile);
        if (!dateFile) {
            this.noFileAcceptance = true;
            this.showToastMessage("Error", this.label.RentalIncWithoutBank_FileAccptdate_ErrorMessage, "error", "dismissible");
            return;
        }

        const monthOptions = [];
        var currentMonth = new Date(dateFile).getMonth();
        var currentYear = new Date(dateFile).getFullYear();
        console.log('currentMonth', currentMonth);
        console.log('currentYear', currentYear);
        const date = new Date();
        let count = 0;
        for (let i = currentMonth+1; i > currentMonth - 3; i--) {
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
            console.log('count------------>' + count);
            if (count == 4) {
                break;
            }
        }

        this.month1Options = this.month1Options.filter(element => element !== null);
        this.monthOptions = monthOptions.filter(element => element !== null);

        // if (this.labelmonth1 == null || this.labelmonth1 == '' || this.labelmonth1 == undefined) {
        //     console.log('month1Options[0].value-------------->' + this.month1Options[0].value);
        //     this.labelmonth1 = this.month1Options[0].value;

        // }
        let tempIncome = this.parameterApplicantIncome;
        this.parameterApplicantIncome = { ...tempIncome };

        console.log('applilicant id-------------->' + this.applicantId);
        console.log('month Options[0].value-------------->' + JSON.stringify(this.monthOptions));
        console.log('month1 Options[0].value-------------->' + JSON.stringify(this.month1Options));


        //     if(this.month1Options && this.month1Options != undefined){
        //         console.log('inside wire');
        //     this.formIntialMonthsLabels();
        //     let intialCashSalaryData = this.formIntialCashSalaryData(this.pastThreeMonthsLabels);
        //     this.properties = intialCashSalaryData;
        // }
    }

    //Life cycle hooks
    connectedCallback() {
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        }
        else {
            this.disableMode = false;
        }
        // this.formIntialMonthsLabels();
        // let intialBankCashSalaryData = this.formIntialBankCreditSalaryData(this.pastThreeMonthsLabels);
        // this.bankCreditSalaryData = intialBankCashSalaryData;
    }

    disconnectedCallback() {
        refreshApex(this.applicantIncomeInfo);

    }

    formIntialMonthsLabels() {
        for (let i = 1; i <= this.pastNumberofMonths; i++) {
            const date = new Date();
            date.setMonth(date.getMonth() - i);
            let monthLabel = date.toLocaleString('default', { month: 'long' }) + ' - ' + date.getFullYear().toString().slice(-2);
            this.pastThreeMonthsLabels.push(monthLabel);
        }
    }

    formIntialBankCreditSalaryData(pastMonthsLables) {
        console.log('month1 Options value');
        console.log('month1 Options[0].value------>' + this.month1Options[0].value);

        let intialBankCreditSalaryData = [];
        if (this.month1Options.length > 0) {
            for (let i = 0; i < pastMonthsLables.length; i++) {
                console.log('i========> ', i);
                let dataRow = Object.assign({}, this.bankCreditsalaryDataObj);
                dataRow.key = i + 1;
                dataRow['isDisabled'] = (i == 0 ? (this.disableMode === true ? true : false) : true);
                dataRow['Month__c'] = this.month1Options[i].value;
                intialBankCreditSalaryData.push(dataRow);
            }
        }
        return intialBankCreditSalaryData;
    }

    handleAddRows() {
        let dataSize = this.bankCreditSalaryData.length;
        let additionalMonthLabel = this.getAdditionalMonth(dataSize + 1);
        let newRow = Object.assign({}, this.bankCreditsalaryDataObj);
        newRow.key = dataSize + 1;
        newRow['isDisabled'] = true;
        newRow['Month__c'] = additionalMonthLabel;
        this.bankCreditSalaryData = [... this.bankCreditSalaryData, newRow];
    }

    @track date123 = new Date();
    @track year = this.date123.getFullYear();
    getAdditionalMonth(additionalMonth) {
        //const date = new Date();
        //let tempmonth = this.monthOptions.filter(eachmonth => eachmonth.name == this.properties[this.properties.length - 1].Month__c);
        console.log('this.properties[this.properties.length - 1].Month__c.split(" - ")[0]--------->');
        let monthtemp = this.getMonthNumber(this.bankCreditSalaryData[this.bankCreditSalaryData.length - 1].Month__c.split(" - ")[0]);
        console.log('monthtemp------------>' + monthtemp);
        let monthNumber = monthtemp - 1;

        this.year = '20' + this.bankCreditSalaryData[this.bankCreditSalaryData.length - 1].Month__c.split(" - ")[1];
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

    handleInputChange(event) {
        const { key, field } = event.currentTarget.dataset;
        let value = event.target.value;
        const rowIndex = parseInt(key) - 1;
        if (field != "Month__c") {

            //Required field validation
            let currElement = this.template.querySelector(`lightning-input[data-key="${key}"][data-field="${field}"]`);
            if (!currElement.value && currElement.dataset.field != 'Remark__c') {
                currElement.setCustomValidity('Complete this field.');
            }
            else {
                currElement.setCustomValidity('');
            }

            //switch on field for appropriate actions
            switch (field) {
                case 'Bank_Credit_Date__c':
                    this.validateBankCreditDate(rowIndex, value, currElement);
            }
        }
        try {
            console.log('outside if')
            if (event.target.dataset.fieldname == "Month__c") {
                this.bankCreditSalaryData[rowIndex][field] = value;
                this.year = '20' + event.target.value.split(" - ")[1];
                let tempmonth = this.getMonthNumber(event.target.value.split(" - ")[0]);
                this.setAllMonths(tempmonth);

            }

            this.bankCreditSalaryData[rowIndex][field] = value;
            
            if (event.target.dataset.field == "Remark__c" && value) {
                let strVal = event.target.value;
                this.bankCreditSalaryData[rowIndex][field] = strVal.toUpperCase();
            }

            if (parseInt(this.bankCreditSalaryData[rowIndex].Gross_Salary_Rs__c) >= 0 && parseInt(this.bankCreditSalaryData[rowIndex].Taxes__c) >= 0 && parseInt(this.bankCreditSalaryData[rowIndex].Other_Deductions__c) >= 0) {
                if (this.validateSalaryInput(rowIndex)) {
                    this.bankCreditSalaryData[rowIndex].Net_Salary__c = this.bankCreditSalaryData[rowIndex].Gross_Salary_Rs__c - this.bankCreditSalaryData[rowIndex].Taxes__c - this.bankCreditSalaryData[rowIndex].Other_Deductions__c;
                }
            }
            this.bankCreditSalaryData = [...this.bankCreditSalaryData];

        }
        catch (Exp) {
            console.log('Error ' + Exp);
        }
    }


    setAllMonths(tempmonth) {
        console.log('tempmonth 395------------>' + tempmonth);

        let storemonth = [];
        let count = 0;
        for (let i = 1; i < this.bankCreditSalaryData.length; i++) {
            console.log('tempmonth------------>' + (tempmonth - 1));
            console.log('i-------------->' + i);
            console.log('this.getMonthName(tempmonth[0].number - 1)-------------->' + this.getMonthName(tempmonth - 1));

            if ((tempmonth - 1) > 0) {
                this.bankCreditSalaryData[i].Month__c = this.getMonthName(tempmonth - 1) + ' - ' + this.year.toString().slice(-2);
                //storemonth.push(this.getMonthName(tempmonth- 1) + ' - ' + this.year.toString().slice(-2));

            }
            else {
                this.year--;
                tempmonth = 13;
                this.bankCreditSalaryData[i].Month__c = this.getMonthName(tempmonth - 1) + ' - ' + this.year.toString().slice(-2);
            }
            tempmonth = (tempmonth - 1);
        }
        console.log('storemonth------------>' + storemonth);

    }


    validateSalaryInput(rowIndex) {
        let isSalaryInputValid = false;
        if (rowIndex >= 0) {
            if ((parseInt(this.bankCreditSalaryData[rowIndex].Taxes__c) + parseInt(this.bankCreditSalaryData[rowIndex].Other_Deductions__c)) > parseInt(this.bankCreditSalaryData[rowIndex].Gross_Salary_Rs__c)) {
                this.showToastMessage('Error', this.label.BankCreditSalary_Deduction_ErrorMessage, 'error', 'sticky');
                isSalaryInputValid = false;
            }
            else {
                isSalaryInputValid = true;
            }
        }
        else {
            for (let i = 0; i < this.bankCreditSalaryData.length; i++) {
                let item = this.bankCreditSalaryData[i];
                if ((parseInt(item.Taxes__c) + parseInt(item.Other_Deductions__c)) > parseInt(item.Gross_Salary_Rs__c)) {
                    this.showToastMessage('Error', this.label.BankCreditSalary_Deduction_ErrorMessage, 'error', 'sticky');
                    isSalaryInputValid = false;
                    return isSalaryInputValid;
                }
                else {
                    isSalaryInputValid = true;
                }
            }
        }

        return isSalaryInputValid;
    }

    validateBankCreditDate(rowIndex, selectedDate, currElement) {
        console.log('maxDateRange', this.maxDateRange);
        console.log('minDateRange', this.minDateRange);
        let curRowMonth = this.bankCreditSalaryData[rowIndex].Month__c.split('-')[0].trim();
        let curRowYear = this.bankCreditSalaryData[rowIndex].Month__c.split('-')[1].trim();
        let acceptMinDate = new Date(`${curRowMonth} 01, ${curRowYear}`);
        console.log('new Date(selectedDate)', new Date(selectedDate));
        if (new Date(selectedDate) >= acceptMinDate && new Date(selectedDate) <= new Date(this.maxDateRange)) {
            currElement.setCustomValidity('');
        }
        else {
            currElement.setCustomValidity('Date out of range');
        }
        currElement.reportValidity();
    }


    handleDeleteRow(event) {
        const { key } = event.currentTarget.dataset;
        const rowIndex = parseInt(key) - 1;
        let currRowData = this.bankCreditSalaryData[rowIndex];
        let dataToDelete = [];
        dataToDelete.push(currRowData);

        if (currRowData.Id) {
            deleteRecord({ rcrds: dataToDelete }).then(() => {
                this.bankCreditSalaryData.splice(rowIndex, 1);
                this.bankCreditSalaryData = [...this.bankCreditSalaryData];
                refreshApex(this.applicantIncomeInfo);
                this.showToastMessage('Success', currRowData.Month__c + this.label.BankCreditSalary_Del_SuccessMessage, 'success', 'sticky');
            }).catch(error => {
                this.showToastMessage('Error occured', currRowData.Month__c + this.label.BankCreditSalary_Del_ErrorMessage, 'error', 'sticky');
            })
        }
        else {
            this.bankCreditSalaryData.splice(rowIndex, 1);
            this.bankCreditSalaryData = [...this.bankCreditSalaryData];
            this.showToastMessage('Success', currRowData.Month__c + this.label.BankCreditSalary_Del_SuccessMessage, 'success', 'sticky');
        }

    }

    @api
    handleUpsert(event) {
        this.showSpinner = true;
        this.isSelected = true;
        if (this.isSelected === true) {
            //let isDataValid = this.validateForm();
            let isSalaryInputValid = this.validateSalaryInput(-1);
            // if (!isDataValid) {
            //     return;
            // }
            if (!isSalaryInputValid) {
                return;
            }

            let dataToUpsert = this.processDataToUpsert().filter(record => {
                if (record) {
                    return record;
                }
            });

            var parentApplicant;
            parentApplicant = { ...this.applicantRecord[0] };
            parentApplicant.Average_Monthly_Gross_Salary__c = this.averageGrossSalary ? this.averageGrossSalary : 0;
            parentApplicant.Average_Net_Salary__c = this.averageNetSalary ? this.averageNetSalary : 0;


            let upsertData = {
                parentRecord: parentApplicant,
                ChildRecords: dataToUpsert,
                ParentFieldNameToUpdate: 'Applicant__c'
            };


            upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
                .then(result => {
                    this.showToastMessage('Success', this.label.BankCreditSalary_Save_SuccessMessage, 'success', 'dismissible');
                    refreshApex(this.applicantIncomeInfo);
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.error(error)
                    console.log('upsert error -', JSON.stringify(error))
                    this.showSpinner = false;
                })
        }
    }

    @api
    validateForm() {
        let isValid = true;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.ariaLabel !== 'averages' && !element.value && element.dataset.field != 'Remark__c') {
                element.setCustomValidity('Complete this field.');
                isValid = false;
                element.reportValidity();
            }
            else if (!element.validity.valid) {
                isValid = false;
                element.reportValidity();
            }
            else {
                element.setCustomValidity('');
            }

        });

        if (!isValid) {
            this.showToastMessage('Fields Required', this.label.BankCreditSalary_Save_ErrorMessage, 'error', 'sticky');
        }
        return isValid;
    }

    processDataToUpsert() {
        const dataToUpsert = this.bankCreditSalaryData.map(item => {
            let currObj = Object.assign({}, item);
            delete currObj.key;
            if (!currObj.Id) {
                delete currObj.Id;
            }
            currObj.sobjectType = 'Applicant_Income__c';
            currObj.RecordTypeId = this.bankCreditSalaryRTId;
            currObj.Total_Net_Salary__c = this.averageNetSalary;
            currObj.Total_Other_Salary_Component__c = this.averageOtherSalary;
            return currObj;
        });

        return dataToUpsert;
    }


    showToastMessage(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    //This code is for BRE Eligibility- salary with Bank credit calculation
    @track SalaryEligibilityType = 'Applicant';
    @track islatestTrue = true;
    //   this._applicantId 
    //   @track applic ='a0AC4000000JaB3MAK';// 'a0AC4000000Gq13MAC'
    @track
    salaryparameter = {
        ParentObjectName: 'BRE_Eligibility__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'GrossSalMon__c', 'VarComMon__c', 'AnulbenLTA_Mon__c', 'BREValue__c', 'PrfBonMon__c', 'Type__c', 'TaxMon__c', 'OtrDedMon__c', 'IncomeProgram__c', 'Consideration__c', 'Applicant__c', 'LoanApp__c', 'IsLatest__c'],
        childObjFields: [],
        queryCriteria: ''
    }
    //   select id,GrossSalMon__c,VarComMon__c,AnulbenLTA_Mon__c,PrfBonMon__c,TaxMon__c,OtrDedMon__c,IncomeProgram__c,Islatest__c  from BRE_Eligibility__c Where IncomeProgram__c='Salaried Eligibility Consideration (%)' AND Islatest__c=true
    //Applicant_Financial__r.RecordType.Name='Profit & Loss' AND Applicant_Financial__r.Loan_Applicant__c='a0AC4000000DwqzMAC'
    //select id,EligIncome__c, Eligibilityper__c,IncomeProgram__c,Type__c,Applicant__c,LoanApp__c from BRE_Eligibility__c where Type__c='Applicant' AND Applicant__c !=null
    handleBRESalaryRecordChange() {
        let tempParams = this.salaryparameter;
        tempParams.queryCriteria = 'WHERE Applicant__c=\'' + this._applicantId + '\' AND Type__c=\'' + this.SalaryEligibilityType + '\'AND IsLatest__c=' + this.islatestTrue;
        this.salaryparameter = { ...tempParams };
        //  FROM Applicant_Financial_Summary__c Where Applicant_Financial__r.RecordType.Name='Profit & Loss' AND Applicant_Financial__r.Loan_Applicant__r.LoanAppln__c
    }

    @wire(getSobjectData, { params: '$salaryparameter' })
    handleBREResponse(wiredResultBRE) {
        let { error, data } = wiredResultBRE;
        if (data) {
            console.log('bre  salary data>>>>>>>>>', data);


            //  iterable.find((item) => {

            //  })

            //console.log('data.parentRecords.lenght>>>',data.parentRecords.length);
            if (data && data.parentRecords != undefined) {
                let salariedCount = 0;
                let salariedCountIncome = 0;
                let salariedConsideration = data.parentRecords;

                console.log('salariedConsideration>>>>', salariedConsideration);
                salariedConsideration.forEach(element => {
                    if (element.IncomeProgram__c == 'Salaried Eligibility Consideration (%)' && salariedCount < 1) {
                        //     console.log('inside zeroth insdec');
                        //  newobj =('element>>>>>>',element)
                        salariedCount++;


                        this.eliWrapObj.eliConsGrossSalMon = element.GrossSalMon__c != null ? element.GrossSalMon__c : 0;
                        this.eliWrapObj.eliConVarComMon__c = element.VarComMon__c != null ? element.VarComMon__c : 0;
                        this.eliWrapObj.eliConAnulbenLTA_Mon__c = element.AnulbenLTA_Mon__c != null ? element.AnulbenLTA_Mon__c : 0;
                        this.eliWrapObj.eliConPrfBonMon__c = element.PrfBonMon__c != null ? element.PrfBonMon__c : 0;
                        this.eliWrapObj.eliConTaxMon__c = element.TaxMon__c != null ? element.TaxMon__c : 0;
                        this.eliWrapObj.eliConOtrDedMon__c = element.OtrDedMon__c != null ? element.OtrDedMon__c : 0;
                    }
                    if (element.IncomeProgram__c == 'Salaried Eligible income (₹)' && salariedCountIncome < 1) {
                        salariedCountIncome++;
                        this.eliWrapObj.eliIncmGrossSalMon = element.GrossSalMon__c != null ? element.GrossSalMon__c : 0;
                        this.eliWrapObj.eliIncmVarComMon__c = element.VarComMon__c != null ? element.VarComMon__c : 0;
                        this.eliWrapObj.eliIncmAnulbenLTA_Mon__c = element.AnulbenLTA_Mon__c != null ? element.AnulbenLTA_Mon__c : 0;
                        this.eliWrapObj.eliIncmPrfBonMon__c = element.PrfBonMon__c != null ? element.PrfBonMon__c : 0;
                        this.eliWrapObj.eliIncmTaxMon__c = element.TaxMon__c != null ? element.TaxMon__c : 0;
                        this.eliWrapObj.eliIncmOtrDedMon__c = element.OtrDedMon__c != null ? element.OtrDedMon__c : 0;
                    }
                    if (element.IncomeProgram__c == 'Gross Eligible Salary with Bank Credit') {
                        this.eliWrapObj.grossSalaryWithBank = element.BREValue__c;
                    }
                    if (element.IncomeProgram__c == 'Net Eligible Salary with Bank Credit') {
                        this.eliWrapObj.netSalaryWithBank = element.BREValue__c;
                    }
                });
            }
            //   console.log('found>>>>>>>>>',found);
            console.log('this.eliWrapObj>>>>>>>>', this.eliWrapObj);

        } else if (error) {
            console.error('Error BRE data ------------->', error);
        }
    }

}