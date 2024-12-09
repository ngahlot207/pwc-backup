import { LightningElement, api, wire, track } from 'lwc';


//apex methods import to fetch data
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import deleteRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';


//Object inof 
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import APPLICANT_INCOME_OBJECT from "@salesforce/schema/Applicant_Income__c";

import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Custom labels
import CaptureIncomeSalary_Del_SuccessMessage from '@salesforce/label/c.CaptureIncomeSalary_Del_SuccessMessage';
import CaptureIncomeSalary_Del_ErrorMessage from '@salesforce/label/c.CaptureIncomeSalary_Del_ErrorMessage';
import CaptureIncomeSalary_ReqFields_ErrorMessage from '@salesforce/label/c.CaptureIncomeSalary_ReqFields_ErrorMessage';
import CaptureIncomeSalary_Save_SuccessMessage from '@salesforce/label/c.CaptureIncomeSalary_Save_SuccessMessage';
import RentalIncWithoutBank_FileAccptdate_ErrorMessage from '@salesforce/label/c.RentalIncWithoutBank_FileAccptdate_ErrorMessage';

export default class ConsolidatedSalaryIncome extends LightningElement {
    label = {
        CaptureIncomeSalary_Del_SuccessMessage,
        CaptureIncomeSalary_Del_ErrorMessage,
        CaptureIncomeSalary_ReqFields_ErrorMessage,
        CaptureIncomeSalary_Save_SuccessMessage,
        RentalIncWithoutBank_FileAccptdate_ErrorMessage

    }

    //public properties
    @api layoutSize;
    @api hasEditAccess;
    @api recordId;
    //@api applicantId;
    //@api loanAppId;
    @api applicantIdOnTabset;
    @api isSelected;

    //HTML data properties
    @track cashSalaryData = [];
    @track applicantRecord;
    @track recTypeId;
    applicantIncomeInfo;
    pastNumberofMonths = 3;
    pastThreeMonthsLabels = [];

    @track showSpinner = false;
    @track _applicantId;
    @api get applicantId() {
        return this._applicantId;
    }
    set applicantId(value) {
        this._applicantId = value;
        this.setAttribute("applicantId", value);

        this.handleAddrRecordChange(value);
    }

    @api get recordTypeName() {
        return this._recordTypeName;
    }
    set recordTypeName(value) {

        this._recordTypeName = value;
        this.setAttribute("recordTypeName", value);

        this.handlerecordTypeNameChange(value);
    }

    //Html static data
    cashSalaryHeaders = [
        { 'key': 1, 'columnName': 'SR NO', 'columnKey': 'srNo', 'style': "width:1rem" },
        { 'key': 2, 'columnName': 'Month', 'columnKey': 'month' },
        { 'key': 3, 'columnName': 'Salary (Rs)', 'columnKey': 'salary', 'required': true }
    ];

    applicantIncomeFields = ['Id', 'Month__c', 'Salary__c'];

    cashSalaryDataObj = { Id: '', key: '', Month__c: '', Salary__c: '', isDisabled: '' };


    //get set properties 

    get averageMonthlySalary() {
        const salaries = this.cashSalaryData.map((row) => parseFloat(row.Salary__c) || 0);
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
        return this.cashSalaryData.length > 3;
    }


    get cashSalaryRTId() {
        if (this.applicantIncomeObjMetadata && this.applicantIncomeObjMetadata.data && this.applicantIncomeObjMetadata.data.recordTypeInfos) {
            const recordTypesInfos = this.applicantIncomeObjMetadata.data.recordTypeInfos;
            return Object.keys(recordTypesInfos).find((recordType) => recordTypesInfos[recordType].name === "Cash Salary");
        }
    }

    //wire methods to get data
    @wire(getObjectInfo, { objectApiName: APPLICANT_INCOME_OBJECT })
    applicantIncomeObjMetadata

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

    @wire(getSobjectData, { params: '$parameterApplicantIncome' })
    creditSalaryDetails(returnData) {
        this.applicantIncomeInfo = returnData;
        let { data, error } = returnData;
        console.log('outside wire', JSON.stringify(data));
        if (data) {
            console.log('inside wire', JSON.stringify(data));
            if (data.parentRecords && data.parentRecords.length > 0) {
                this.cashSalaryData = [];
                let idx = 1;

                data.parentRecords.forEach(item => {
                    console.log('inside for', item);
                    let newDataObj = Object.assign({}, this.cashSalaryDataObj);
                    Object.keys(this.cashSalaryDataObj).forEach(key => {
                        console.log('inside for for', key);
                        if (key === "key") {
                            newDataObj[key] = idx;
                        }
                        else {
                            newDataObj[key] = item[key] ? item[key] : 0;
                        }
                        if (idx == 1) {
                            newDataObj.isDisabled = false;
                        }
                        else {
                            newDataObj.isDisabled = true;
                        }
                        if (idx == data.parentRecords.length) {
                            this.year = '20' + newDataObj.Month__c.toString().split(" - ")[1];
                        }
                    })
                    idx++;
                    console.log('newDataObj---------->' + JSON.stringify(newDataObj));
                    this.cashSalaryData.push(newDataObj);
                })
                //this.sortSalaryMonths(this.cashSalaryData);
            }
            else {
                console.log('this.month1Options------>', JSON.stringify(this.month1Options));
                if (this.month1Options.length > 0) {
                    this.formIntialMonthsLabels();
                    let intialCashSalaryData = this.formIntialCashSalaryData(this.pastThreeMonthsLabels);
                    this.cashSalaryData = intialCashSalaryData;
                }
            }
        }
        else {
            if (error) {
                console.log('params', this.parameterApplicantIncome);
                console.log('Error occured in fetching income details ' + JSON.stringify(error));
            }

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
        console.log('cash salary    applicantId ' + this.applicantId);
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'Average_Monthly_Cash_Salary__c'],
            queryCriteria: ' WHERE Id = \'' + this.applicantId + '\''
        }
        return params;
    }

    @wire(getSobjectData, { params: '$paramsApplicant' })
    applicantInfo(retunData) {
        let { data, error } = retunData;
        console.log('Cash Salary Dataa Receieved!!! ' + JSON.stringify(retunData));
        if (data) {
            this.applicantRecord = data.parentRecords;
        }
        else if (error) {
            console.log('Error occured in fetching Appilcant details ' + JSON.stringify(error));
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

        if (!data || !data.parentRecords || data.parentRecords.length === 0) {

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
        let count=0;
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
            console.log('count------------>'+count);
            if(count==4)
            {
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
        // this.formIntialMonthsLabels();
        // let intialCashSalaryData = this.formIntialCashSalaryData(this.pastThreeMonthsLabels);
        // this.cashSalaryData = intialCashSalaryData;
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        }
        else {
            this.disableMode = false;
        }
    }

    renderedCallback() {
        const srColumn = this.template.querySelector('th[data-field="srNo"]');
        if (srColumn) {
            srColumn.classList.add('slds-size_1-of-6');
        }
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

    formIntialCashSalaryData(pastMonthsLables) {
        console.log('month1 Options value');
        console.log('month1 Options[0].value------>' + this.month1Options[0].value);
        let intialCashSalaryData = [];

        if (this.month1Options.length > 0) {
            for (let i = 0; i < 3; i++) {
                console.log('i========> ', i);
                let dataRow = Object.assign({}, this.cashSalaryDataObj);
                dataRow['isDisabled'] = (i == 0 ? false : true);
                dataRow.key = i + 1;
                dataRow['Month__c'] = this.month1Options[i].value;
                intialCashSalaryData.push(dataRow);
            }
        }

        return intialCashSalaryData;
    }



    handleAddRows() {
        let dataSize = this.cashSalaryData.length;
        console.log('add');
        let additionalMonthLabel = this.getAdditionalMonth(dataSize + 1);

        let newRow = Object.assign({}, this.cashSalaryDataObj);
        newRow.key = dataSize + 1;
        newRow['isDisabled'] = true;
        newRow['Month__c'] = additionalMonthLabel;
        this.cashSalaryData = [... this.cashSalaryData, newRow];
    }

    @track date123 = new Date();
    @track year = this.date123.getFullYear();
    getAdditionalMonth(additionalMonth) {

        //const date = new Date();
        //let tempmonth = this.monthOptions.filter(eachmonth => eachmonth.name == this.properties[this.properties.length - 1].Month__c);
        console.log('this.properties[this.properties.length - 1].Month__c.split(" - ")[0]--------->');
        let monthtemp = this.getMonthNumber(this.cashSalaryData[this.cashSalaryData.length - 1].Month__c.split(" - ")[0]);
        console.log('monthtemp------------>' + monthtemp);
        let monthNumber = monthtemp - 1;

        this.year = '20' + this.cashSalaryData[this.cashSalaryData.length - 1].Month__c.split(" - ")[1];
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

    //
    handleInputChange(event) {
        const { key, field } = event.currentTarget.dataset;
        const value = event.target.value;
        const rowIndex = parseInt(key) - 1;



        try {
            if (event.target.dataset.fieldname == "Month__c") {
                console.log('inside')
                this.cashSalaryData[rowIndex][field] = value;
                console.log('inside 2', event.target.value);
                this.year = '20' + event.target.value.split(" - ")[1];
                let tempmonth = this.getMonthNumber(event.target.value.split(" - ")[0]);
                this.setAllMonths(tempmonth);

            }


            this.cashSalaryData[rowIndex][field] = value;
            this.cashSalaryData = [...this.cashSalaryData];
        }
        catch (Exp) {
            console.log('Error ' + Exp);
        }
    }


    setAllMonths(tempmonth) {
        console.log('tempmonth 395------------>' + tempmonth);

        let storemonth = [];
        let count = 0;
        for (let i = 1; i < this.cashSalaryData.length; i++) {
            console.log('tempmonth------------>' + (tempmonth - 1));
            console.log('i-------------->' + i);
            console.log('this.getMonthName(tempmonth[0].number - 1)-------------->' + this.getMonthName(tempmonth - 1));

            if ((tempmonth - 1) > 0) {
                this.cashSalaryData[i].Month__c = this.getMonthName(tempmonth - 1) + ' - ' + this.year.toString().slice(-2);
                //storemonth.push(this.getMonthName(tempmonth- 1) + ' - ' + this.year.toString().slice(-2));

            }
            else {
                this.year--;
                tempmonth = 13;
                this.cashSalaryData[i].Month__c = this.getMonthName(tempmonth - 1) + ' - ' + this.year.toString().slice(-2);
            }
            tempmonth = (tempmonth - 1);
        }
        console.log('storemonth------------>' + storemonth);

    }

    //Delete button event handler
    handleDeleteRow(event) {
        const { key } = event.currentTarget.dataset;
        const rowIndex = parseInt(key) - 1;
        let currRowData = this.cashSalaryData[rowIndex];
        let dataToDelete = [];
        dataToDelete.push(currRowData);
        
        if (currRowData.Id) {
            deleteRecord({rcrds :dataToDelete}).then(() => {
                this.cashSalaryData.splice(rowIndex, 1);
                this.cashSalaryData = [...this.cashSalaryData];
                refreshApex(this.applicantIncomeInfo);
                this.showToastMessage('Success', currRowData.Month__c + this.label.CaptureIncomeSalary_Del_SuccessMessage, 'success', 'sticky');
            }).catch(error => {
                this.showToastMessage('Error occured', currRowData.Month__c + this.label.CaptureIncomeSalary_Del_ErrorMessage, 'error', 'sticky');
            })
        }
        else {
            this.cashSalaryData.splice(rowIndex, 1);
            this.cashSalaryData = [...this.cashSalaryData];
            this.showToastMessage('Success', currRowData.Month__c + this.label.CaptureIncomeSalary_Del_SuccessMessage, 'success', 'sticky');
        }

    }

    @api
    handleUpsert(event) {
        this.showSpinner=true;
        console.log('Upsert Check point 1');
        this.isSelected = true;
        if (this.isSelected === true) {

            console.log('Upsert Check point 2');
            let dataToUpsert = this.processDataToUpsert().filter(record => {
                if (record) {
                    return record;
                }
            });

            // var parentApplicant;
            // parentApplicant = { ...this.applicantRecord[0] };
            // parentApplicant.Average_Monthly_Cash_Salary__c = this.averageMonthlySalary;

            let applicantDetails = {
                LoanAppl__c: this.loanAppId,
                Id: this.applicantId,
                Average_Monthly_Cash_Salary__c : this.averageMonthlySalary,
                sobjectType: 'Applicant__c'
            };


            let upsertData = {
                parentRecord: applicantDetails,
                ChildRecords: dataToUpsert,
                ParentFieldNameToUpdate: 'Applicant__c'
            };

            upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
                .then(result => {
                    this.showToastMessage('Success', this.label.CaptureIncomeSalary_Save_SuccessMessage, 'success', 'sticky');
                    refreshApex(this.applicantIncomeInfo);
                    console.log('upsert success 341-', JSON.stringify(result))
                    console.log('upsert success 338-', JSON.stringify(upsertData));
                    this.showSpinner=false;
                })
                .catch(error => {
                    console.error(error)
                    console.log('upsert error -', JSON.stringify(error))
                    this.showSpinner=false;
                });
        }

    }

    @api
    validateForm() {
        let isValid = true;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if ((!element.value)) {
                //element.setCustomValidity('Complete this field.');
                isValid = false;
            }
            else if (!element.validity.valid) {
                isValid = false;
            }
            else {
                element.setCustomValidity('');
            }
            element.reportValidity();
        });

        if (!isValid) {
            this.showToastMessage('Fields Required', this.label.CaptureIncomeSalary_ReqFields_ErrorMessage, 'error', 'sticky');
            return;
        }
        return isValid;
    }

    processDataToUpsert() {
        const dataToUpsert = this.cashSalaryData.map(item => {
            let currObj = Object.assign({}, item);
            delete currObj.key;
            if (!currObj.Id) {
                delete currObj.Id;
            }
            currObj.sobjectType = 'Applicant_Income__c';
            currObj.RecordTypeId = this.cashSalaryRTId;
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
}