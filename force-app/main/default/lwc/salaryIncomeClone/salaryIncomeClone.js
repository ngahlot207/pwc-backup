import { LightningElement, api, wire, track } from 'lwc';

//fetching object related information 
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import APPLICANT_INCOME from "@salesforce/schema/Applicant_Income__c";

export default class SalaryIncomeClone extends LightningElement {


    //public properties
    @api layoutSize;

    //HTML data properties
    @track cashSalaryData = [];
    @track bankCreditSalaryData = [];
    nextKey = 1;
    selectedIncomeType = '';
    showCashSalary = false;
    showBankCreditSalary = false;
    pastNumberofMonths = 3;
    pastThreeMonthsLabels = [];

    //Html static data
    cashSalaryHeaders = [
        { 'key': 1, 'columnName': 'SR NO' },
        { 'key': 2, 'columnName': 'Month' },
        { 'key': 3, 'columnName': 'Salary' }
    ];

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

    incomeTypeOptions = [
        { label: 'Cash Salary', value: 'cashSalary' },
        { label: 'Salary with Bank Credit', value: 'bankCreditSalary' }
    ];

    cashSalaryDataObj = { 'key': '', 'month': '', 'Salary__c': 0 };
    bankCreditsalaryDataObj = {
        'key': '', 'month': '', 'Gross_Salary_Rs__c': 0, 'Variable_Component__c': 0, 'LTA_Monthly__c': 0, 'Performance_Bonus_Monthly__c': 0,
        'Taxes__c': 0, 'Other_Deductions__c': 0, 'Net_Salary__c': 0, 'Bank_Credit_Date__c': '', 'remarks': '', 'Other_Salary_Component__c': 0
    };


    //wire methods to retrive information 

    @wire(getObjectInfo, { objectApiName: APPLICANT_INCOME })
    applicantIncomeInfo;


    //get set properties 
    get averageMonthlySalary() {
        const salaries = this.cashSalaryData.map((row) => parseFloat(row.Salary__c));
        return this.getAverageOfDataArray(salaries);
    }

    get averageGrossSalary() {
        const salaries = this.bankCreditSalaryData.map((row) => parseFloat(row.Gross_Salary_Rs__c));
        return this.getAverageOfDataArray(salaries);
    }

    get averageVariableCmp() {
        const salaries = this.bankCreditSalaryData.map((row) => parseFloat(row.Variable_Component__c));
        return this.getAverageOfDataArray(salaries);
    }

    get averageLTA() {
        const salaries = this.bankCreditSalaryData.map((row) => parseFloat(row.LTA_Monthly__c));
        return this.getAverageOfDataArray(salaries);
    }

    get averagePerformanceBonus() {
        const salaries = this.bankCreditSalaryData.map((row) => parseFloat(row.Performance_Bonus_Monthly__c));
        return this.getAverageOfDataArray(salaries);
    }

    get averageTaxes() {
        const salaries = this.bankCreditSalaryData.map((row) => parseFloat(row.Taxes__c));
        return this.getAverageOfDataArray(salaries);
    }

    get averageOtherDeduction() {
        const salaries = this.bankCreditSalaryData.map((row) => parseFloat(row.Other_Deductions__c));
        return this.getAverageOfDataArray(salaries);
    }

    get averageNetSalary() {
        const salaries = this.bankCreditSalaryData.map((row) => parseFloat(row.Net_Salary__c));
        return this.getAverageOfDataArray(salaries);
    }

    get averageOtherSalary() {
        const salaries = this.bankCreditSalaryData.map((row) => parseFloat(row.Other_Salary_Component__c));
        return this.getAverageOfDataArray(salaries);
    }

    getAverageOfDataArray(salaries) {
        const totalSalary = salaries.reduce((acc, salary) => acc + salary, 0);
        const average = salaries.length > 0 ? totalSalary / salaries.length : 0;
        return average.toFixed(2);
    }

    //Life cycle hooks
    connectedCallback() {
        this.formIntialMonthsLabels();
    }

    renderedCallback() {

    }

    disconnectedCallback() {

    }


    handleIncomeTypeChange(event) {
        let selectedValue = event.target.value;

        if (selectedValue) {
            this.selectedIncomeType = selectedValue;
            if (selectedValue === 'cashSalary') {
                this.showCashSalary = true;
                this.showBankCreditSalary = false;
                this.cashSalaryData = this.formIntialCashSalaryData(this.pastThreeMonthsLabels);
            }
            else {
                this.showCashSalary = false;
                this.showBankCreditSalary = true;
                this.bankCreditSalaryData = this.formIntialBankCreditSalaryData(this.pastThreeMonthsLabels);
            }
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

    formIntialCashSalaryData(pastMonthsLables) {
        let intialCashSalaryData = [];
        for (let i = 0; i < pastMonthsLables.length; i++) {
            let dataRow = Object.assign(this.cashSalaryDataObj);
            dataRow.key = i+1;
            dataRow.month = pastMonthsLables[i];
            /*let dataRow = {
                'key': i + 1,
                'month': pastMonthsLables[i],
                'Salary__c': 0
            };*/
            intialCashSalaryData.push(dataRow);
        }

        return intialCashSalaryData;
    }

    formIntialBankCreditSalaryData(pastMonthsLables) {
        let intialBankCreditSalaryData = [];
        for (let i = 0; i < pastMonthsLables.length; i++) {
            let dataRow = Object.assign(this.bankCreditsalaryDataObj);
            dataRow.key = i+1;
            dataRow.month = pastMonthsLables[i];
            /*let dataRow = {
                'key': i + 1,
                'month': pastMonthsLables[i],
                'Gross_Salary_Rs__c': 0,
                'Variable_Component__c': 0,
                'LTA_Monthly__c': 0,
                'Performance_Bonus_Monthly__c': 0,
                'Taxes__c': 0,
                'Other_Deductions__c': 0,
                'Net_Salary__c': 0,
                'Bank_Credit_Date__c': '',
                'remarks': '',
                'Other_Salary_Component__c': 0
            };*/
            intialBankCreditSalaryData.push(dataRow);
        }

        return intialBankCreditSalaryData;
    }

    handleAddRows() {
        if (this.showCashSalary) {
            let dataSize = this.cashSalaryData.length;
            let additionalMonthLabel = this.getAdditionalMonth(dataSize + 1);
            let newRow = Object.assign(this.cashSalaryDataObj);
            newRow.key = dataSize + 1;
            newRow.month = additionalMonthLabel;
            /*
            const newRow = {
                'key': dataSize + 1,
                'month': additionalMonthLabel,
                'Salary__c': 0
            }*/
            this.cashSalaryData = [... this.cashSalaryData, newRow];
        }
        else if (this.showBankCreditSalary) {
            let dataSize = this.bankCreditSalaryData.length;
            let additionalMonthLabel = this.getAdditionalMonth(dataSize + 1);
            let newRow = Object.assign(this.bankCreditsalaryDataObj);
            newRow.key = dataSize + 1;
            newRow.month = additionalMonthLabel;
            /*const newRow = {
                'key': dataSize + 1,
                'month': additionalMonthLabel,
                'Gross_Salary_Rs__c': 0,
                'Variable_Component__c': 0,
                'LTA_Monthly__c': 0,
                'Performance_Bonus_Monthly__c': 0,
                'Taxes__c': 0,
                'Other_Deductions__c': 0,
                'Net_Salary__c': 0,
                'Bank_Credit_Date__c': '',
                'remarks': '',
                'Other_Salary_Component__c': 0
            }*/
            this.bankCreditSalaryData = [... this.bankCreditSalaryData, newRow];
        }
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
            this.cashSalaryDataObj = [...this.cashSalaryData];
            console.log('cash Salary ' + this.cashSalaryData);
        }
        else if (this.showBankCreditSalary) {
            const rowIndex = parseInt(key) - 1;
            this.bankCreditSalaryData[rowIndex][field] = value;
        }
    }

    //Delete button event handler
    handleDeleteRow(event) {
        const { key } = event.currentTarget.dataset;
        if (this.showCashSalary) {
            const rowIndex = parseInt(key) - 1;
            this.cashSalaryData.splice(rowIndex, 1);
            this.cashSalaryData = [...this.cashSalaryData];
        }
        else if (this.showBankCreditSalary) {
            const rowIndex = parseInt(key) - 1;
            this.bankCreditSalaryData.splice(rowIndex, 1);
            this.bankCreditSalaryData = [...this.bankCreditSalaryData];
        }
    }
}