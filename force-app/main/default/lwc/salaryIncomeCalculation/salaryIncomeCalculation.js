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
import SalaryIncomeCal_Del_SuccessMessage from '@salesforce/label/c.SalaryIncomeCal_Del_SuccessMessage';
import SalaryIncomeCal_Del_ErrorMessage from '@salesforce/label/c.SalaryIncomeCal_Del_ErrorMessage';
import SalaryIncomeCal_ReqFields_ErrorMessage from '@salesforce/label/c.SalaryIncomeCal_ReqFields_ErrorMessage';
import SalaryIncomeCal_Save_SuccessMessage from '@salesforce/label/c.SalaryIncomeCal_Save_SuccessMessage';

export default class SalaryIncomeCalculation extends LightningElement {
    customLabel = {
        SalaryIncomeCal_Del_SuccessMessage,
        SalaryIncomeCal_Del_ErrorMessage,
        SalaryIncomeCal_ReqFields_ErrorMessage,
        SalaryIncomeCal_Save_SuccessMessage

    }
    //public properties
    @api layoutSize;
    @api hasEditAccess;
    @api recordId;
    @api applicantId;
    @api loanAppId;
    @api applicantIdOnTabset = 'a0AC4000000Gg05MAC';
    @api incomeType = 'Cash Salary';
    @api isSelected;

    //HTML data properties
    @track cashSalaryData = [];
    @track applicantRecord;

    applicantIncomeInfo;
    pastNumberofMonths = 3;
    pastThreeMonthsLabels = [];

    //Html static data
    cashSalaryHeaders = [
        { 'key': 1, 'columnName': 'SR NO', 'columnKey': 'srNo' },
        { 'key': 2, 'columnName': 'Month', 'columnKey': 'month' },
        { 'key': 3, 'columnName': 'Salary', 'columnKey': 'salary' }
    ];

    applicantIncomeFields = ['Id', 'Month__c', 'Salary__c'];

    cashSalaryDataObj = { Id: '', key: '', Month__c: '', Salary__c: '' };


    //get set properties 

    get showCashSalary() {
        return (this.incomeType == "Cash Salary") ? true : false;
    }

    get averageMonthlySalary() {
        const salaries = this.cashSalaryData.map((row) => parseFloat(row.Salary__c) || 0);
        return this.getAverageOfDataArray(salaries);
    }

    getAverageOfDataArray(salaries) {
        const totalSalary = salaries.reduce((acc, salary) => acc + salary, 0);
        const average = salaries.length > 0 ? totalSalary / salaries.length : 0;
        return average.toFixed(2);
    }

    get showDeleteAction() {
        return this.cashSalaryData.length > 3;
    }


    get cashSalaryRTId() {
        if (this.applicantIncomeObjMetadata) {
            const recordTypesInfos = this.applicantIncomeObjMetadata.data.recordTypeInfos;
            return Object.keys(recordTypesInfos).find((recordType) => recordTypesInfos[recordType].name === "Cash Salary");
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
            queryCriteria: ' WHERE Applicant__c = \'' + this.applicantIdOnTabset + '\'' + ' AND RecordTypeId = \'' + this.cashSalaryRTId + '\''
        }
        return params;
    }

    @wire(getSobjectData, { params: '$parameterApplicantIncome' })
    creditSalaryDetails(returnData) {
        this.applicantIncomeInfo = returnData;
        let { data, error } = returnData;
        if (data) {
            if (data.parentRecords && data.parentRecords.length > 0) {
                this.cashSalaryData = [];
                let idx = 1;
                data.parentRecords.forEach(item => {
                    let newDataObj = Object.assign({}, this.cashSalaryDataObj);
                    Object.keys(this.cashSalaryDataObj).forEach(key => {
                        if (key === "key") {
                            newDataObj[key] = idx;
                        }
                        else {
                            newDataObj[key] = item[key] ? item[key] : 0;
                        }
                    })
                    idx++;
                    this.cashSalaryData.push(newDataObj);
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
        let intialCashSalaryData = this.formIntialCashSalaryData(this.pastThreeMonthsLabels);
        this.cashSalaryData = intialCashSalaryData;
    }

    renderedCallback() {
        const srColumn = this.template.querySelector('th[data-field="srNo"]');
        if (srColumn) {
            srColumn.classList.add('slds-size_1-of-6');
        }
    }

    disconnectedCallback() {

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
        let intialCashSalaryData = [];
        for (let i = 0; i < pastMonthsLables.length; i++) {
            let dataRow = Object.assign({}, this.cashSalaryDataObj);
            dataRow.key = i + 1;
            dataRow['Month__c'] = pastMonthsLables[i];
            intialCashSalaryData.push(dataRow);
        }

        return intialCashSalaryData;
    }



    handleAddRows() {
        let dataSize = this.cashSalaryData.length;
        let additionalMonthLabel = this.getAdditionalMonth(dataSize + 1);
        let newRow = Object.assign({}, this.cashSalaryDataObj);
        newRow.key = dataSize + 1;
        newRow['Month__c'] = additionalMonthLabel;
        this.cashSalaryData = [... this.cashSalaryData, newRow];
    }

    getAdditionalMonth(additionalMonth) {
        const date = new Date();
        date.setMonth(date.getMonth() - additionalMonth);
        let monthLabel = date.toLocaleString('default', { month: 'long' }) + ' - ' + date.getFullYear().toString().slice(-2);
        return monthLabel;
    }

    //
    handleInputChange(event) {
        const { key, field } = event.currentTarget.dataset;
        const value = event.target.value;
        if (this.showCashSalary) {
            const rowIndex = parseInt(key) - 1;
            this.cashSalaryData[rowIndex][field] = value;
            this.cashSalaryData = [...this.cashSalaryData];
        }
    }

    //Delete button event handler
    handleDeleteRow(event) {
        const { key } = event.currentTarget.dataset;
        if (this.showCashSalary) {
            const rowIndex = parseInt(key) - 1;
            let currRowData = this.cashSalaryData[rowIndex];
            if (currRowData.Id) {
                deleteRecord(currRowData.Id).then(() => {
                    this.cashSalaryData.splice(rowIndex, 1);
                    this.cashSalaryData = [...this.cashSalaryData];
                    refreshApex(this.applicantIncomeInfo);
                    this.showToastMessage('Success', currRowData.Month__c +this.customLabel.SalaryIncomeCal_Del_SuccessMessage, 'success', 'dismisssible');
                }).catch(error => {
                    this.showToastMessage('Error occured', currRowData.Month__c + this.customLabel.SalaryIncomeCal_Del_ErrorMessage, 'error', 'dismisssible');
                })
            }
            else {
                this.cashSalaryData.splice(rowIndex, 1);
                this.cashSalaryData = [...this.cashSalaryData];
                this.showToastMessage('Success', currRowData.Month__c + this.customLabel.SalaryIncomeCal_Del_SuccessMessage, 'success', 'dismisssible');
            }


        }
    }

    @api
    handleUpsert(event) {

        this.isSelected = true;
        if (this.isSelected === true) {
            let isDataValid = this.validateForm();
            if (!isDataValid) {
                this.showToastMessage('Fields Required', this.customLabel.SalaryIncomeCal_ReqFields_ErrorMessage, 'error', 'dismisssible');
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
                    this.showToastMessage('Success', this.customLabel.SalaryIncomeCal_Save_SuccessMessage, 'success', 'dismissible');
                    refreshApex(this.applicantIncomeInfo);
                    console.log('upsert success 341-', JSON.stringify(result))
                    console.log('upsert success 338-', JSON.stringify(upsertData));
                })
                .catch(error => {
                    console.error(error)
                    console.log('upsert error -', JSON.stringify(error))
                });
        }

    }

    @api
    validateForm() {
        let isValid = true;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if ((!element.value)) {
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
            title,
            message,
            variant,
            mode
        });
        this.dispatchEvent(evt);
    }
}