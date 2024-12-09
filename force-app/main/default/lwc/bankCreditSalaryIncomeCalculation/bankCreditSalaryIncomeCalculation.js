import { LightningElement, api, wire, track } from 'lwc';

//apex methods import to fetch data
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';


//Object inof 
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import APPLICANT_INCOME_OBJECT from "@salesforce/schema/Applicant_Income__c";
import { deleteRecord } from 'lightning/uiRecordApi';


import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Custom labels
import SalaryIncome_RowDelete_SuccessMessage from '@salesforce/label/c.SalaryIncome_RowDelete_SuccessMessage';
import SalaryIncome_RowDelete_ErrorMessage from '@salesforce/label/c.SalaryIncome_RowDelete_ErrorMessage';
import SalaryIncome_Save_SuccessMessage from '@salesforce/label/c.SalaryIncome_Save_SuccessMessage';
import SalaryIncome_ReqField_ErrorMessage from '@salesforce/label/c.SalaryIncome_ReqField_ErrorMessage';

export default class BankCreditSalaryIncomeCalculation extends LightningElement {

    label ={
        SalaryIncome_RowDelete_SuccessMessage,
        SalaryIncome_RowDelete_ErrorMessage,
        SalaryIncome_Save_SuccessMessage,
        SalaryIncome_ReqField_ErrorMessage
    }
    //public properties
    @api layoutSize;
    @api hasEditAccess;
    @api recordId;
    @api applicantId;
    @api loanAppId;
    @api applicantIdOnTabset = 'a0AC4000000Gg05MAC';
    @api incomeType = 'Bank Credit Salary';
    @api isSelected;


    @track bankCreditSalaryData = [];
    @track applicantRecord;

    applicantIncomeInfo;
    pastNumberofMonths = 3;
    pastThreeMonthsLabels = [];


    bankCreditSalaryHeaders = [
        { 'key': 1, 'columnName': 'Salary Months' },
        { 'key': 2, 'columnName': 'Gross Salary Rs' },
        { 'key': 3, 'columnName': 'Variable Component' },
        { 'key': 4, 'columnName': 'LTA Monthly' },
        { 'key': 5, 'columnName': 'Performance Bonus Monthly' },
        { 'key': 6, 'columnName': 'Taxes' },
        { 'key': 7, 'columnName': 'Other Deductions' },
        { 'key': 8, 'columnName': 'Net Salary' },
        { 'key': 9, 'columnName': 'Bank Credit Date' },
        { 'key': 10, 'columnName': 'Remarks' },
        { 'key': 11, 'columnName': 'Other Salary Component (outside payslip)' }

    ];

    applicantIncomeFields = ['Id', 'Month__c', 'Gross_Salary_Rs__c', 'Variable_Component__c', 'LTA_Monthly__c', 'Performance_Bonus_Monthly__c',
        'Taxes__c', 'Other_Deductions__c', 'Net_Salary__c', 'Bank_Credit_Date__c', 'Other_Salary_Component__c'];

    bankCreditsalaryDataObj = {
        Id: '', key: '', Month__c: '', Gross_Salary_Rs__c: '', Variable_Component__c: '', LTA_Monthly__c: '', Performance_Bonus_Monthly__c: '',
        Taxes__c: '', Other_Deductions__c: '', Net_Salary__c: '', Bank_Credit_Date__c: '', Remark__c: '', Other_Salary_Component__c: ''
    };


    //Getter setter 
    get showBankCreditSalary() {
        return (this.incomeType == "Bank Credit Salary") ? true : false;
    }

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
        return average.toFixed(2);
    }

    get showDeleteAction() {
        return this.bankCreditSalaryData.length > 3;
    }


    get bankCreditSalaryRTId() {
        if (this.applicantIncomeObjMetadata) {
            const recordTypesInfos = this.applicantIncomeObjMetadata.data.recordTypeInfos;
            return Object.keys(recordTypesInfos).find((recordType) => recordTypesInfos[recordType].name === "Bank Credit Salary");
        }
    }
    //wire methods to get data
    @wire(getObjectInfo, { objectApiName: APPLICANT_INCOME_OBJECT })
    applicantIncomeObjMetadata


    //parameters to get data from apex
    get parameterApplicantIncome() {
        let params = {
            ParentObjectName: 'Applicant_Income__c',
            parentObjFields: this.applicantIncomeFields,
            queryCriteria: ' WHERE Applicant__c = \'' + this.applicantIdOnTabset + '\'' + ' AND RecordTypeId = \'' + this.bankCreditSalaryRTId + '\''
        }
        return params;
    }

    @wire(getSobjectData, { params: '$parameterApplicantIncome' })
    creditSalaryDetails(returnData) {
        this.applicantIncomeInfo = returnData;
        let { data, error } = returnData;
        if (data) {
            if (data.parentRecords && data.parentRecords.length > 0) {
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
                    })
                    idx++;
                    this.bankCreditSalaryData.push(newDataObj);
                })
            }
        }
        else if (error) {
            console.log('Error occured in fetching income details ' + error);
        }
    }

    get paramsApplicant() {
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id'],
            queryCriteria: ' WHERE Id = \'' + this.applicantIdOnTabset + '\''
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


    //Life cycle hooks
    connectedCallback() {
        this.formIntialMonthsLabels();
        let intialBankCashSalaryData = this.formIntialBankCreditSalaryData(this.pastThreeMonthsLabels);
        this.bankCreditSalaryData = intialBankCashSalaryData;
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        }
        else {
            this.disableMode = false;
        }
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
        let intialBankCreditSalaryData = [];
        for (let i = 0; i < pastMonthsLables.length; i++) {
            let dataRow = Object.assign({}, this.bankCreditsalaryDataObj);
            dataRow.key = i + 1;
            dataRow['Month__c'] = pastMonthsLables[i];
            intialBankCreditSalaryData.push(dataRow);
        }

        return intialBankCreditSalaryData;
    }

    handleAddRows() {
        let dataSize = this.bankCreditSalaryData.length;
        let additionalMonthLabel = this.getAdditionalMonth(dataSize + 1);
        let newRow = Object.assign({}, this.bankCreditsalaryDataObj);
        newRow.key = dataSize + 1;
        newRow['Month__c'] = additionalMonthLabel;
        this.bankCreditSalaryData = [... this.bankCreditSalaryData, newRow];
    }

    getAdditionalMonth(additionalMonth) {
        if (this.showBankCreditSalary) {
            const date = new Date();
            date.setMonth(date.getMonth() - additionalMonth);
            let monthLabel = date.toLocaleString('default', { month: 'long' }) + ' - ' + date.getFullYear().toString().slice(-2);
            return monthLabel;
        }

    }

    handleInputChange(event) {
        const { key, field } = event.currentTarget.dataset;
        const value = event.target.value;
        if (this.showBankCreditSalary) {
            try {
                const rowIndex = parseInt(key) - 1;
                this.bankCreditSalaryData[rowIndex][field] = value;
                this.bankCreditSalaryData = [...this.bankCreditSalaryData];
            }
            catch (Exp) {
                console.log('Error ' + exp);
            }
        }
    }


    handleDeleteRow(event) {
        const { key } = event.currentTarget.dataset;
        const rowIndex = parseInt(key) - 1;
        let currRowData = this.bankCreditSalaryData[rowIndex];


        if (currRowData.Id) {
            deleteRecord(currRowData.Id).then(() => {
                this.bankCreditSalaryData.splice(rowIndex, 1);
                this.bankCreditSalaryData = [...this.bankCreditSalaryData];
                refreshApex(this.applicantIncomeInfo);
                
                this.showToastMessage('Success', currRowData.Month__c +  this.label.SalaryIncome_RowDelete_SuccessMessage, 'success', 'dismisssible');
            }).catch(error => {

                this.showToastMessage('Error', currRowData.Month__c + this.label.AddDeviation_Description_ErrorMessage, 'error', 'dismisssible');
            })
        }
        else {
            this.bankCreditSalaryData.splice(rowIndex, 1);
            this.bankCreditSalaryData = [...this.bankCreditSalaryData];
            this.showToastMessage('Success', currRowData.Month__c + this.label.SalaryIncome_RowDelete_SuccessMessage, 'success', 'dismisssible');
        }

        this.showToastMessage('Success', currRowData.Month__c +  this.label.SalaryIncome_RowDelete_SuccessMessage, 'success', 'dismisssible');
    }

    @api
    handleUpsert(event) {

        this.isSelected = true;
        if (this.isSelected === true) {
        let isDataValid = this.validateForm();
        if (!isDataValid) {
            this.showToastMessage('Error', this.label.SalaryIncome_ReqField_ErrorMessage, 'error', 'dismissable');
            return;
        }

        let dataToUpsert = this.processDataToUpsert().filter(record => {
            if (record) {
                return record;
            }
        });

        let upsertData = {
            parentRecord: this.applicantRecord[0],
            ChildRecords: dataToUpsert,
            ParentFieldNameToUpdate: 'Applicant__c'
        };

        upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
            .then(result => {
                this.showToastMessage('Success', this.label.SalaryIncome_Save_SuccessMessage, 'success', 'dismissible');
                console.log('upsert success 341-', JSON.stringify(result))
                console.log('upsert success 338-', JSON.stringify(upsertData));
            })
            .catch(error => {
                console.error(error)
                console.log('upsert error -', JSON.stringify(error))
            })
        }
    }

    @api
    validateForm() {
        let isValid = true;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if ((!element.value) && element.dataset.field != 'Remark__c') {
                element.setCustomValidity('Complete this field.');
                isValid = false;
            }
            else {
                element.setCustomValidity('');
            }
            element.reportValidity();
        });
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
            title,
            message,
            variant,
            mode
        });
        this.dispatchEvent(evt);
    }

}