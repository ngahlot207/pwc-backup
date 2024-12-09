import { LightningElement, track, api, wire } from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import processDefunctRecordsFinancial from '@salesforce/apex/FinancialRecordProcessor.processDefunctRecordsFinancial';

import { refreshApex } from '@salesforce/apex';
import { createRecord, updateRecord, deleteRecord } from "lightning/uiRecordApi";
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import TYPES_OF_ACCOUNTS from '@salesforce/schema/Applicant_Financial_Summary__c.Type_of_Accounts__c';
import Applicant_Financial_Summary_OBJECT from '@salesforce/schema/Applicant_Financial_Summary__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Custom labels
import ProfitLoss_Save_SuccessMessage from '@salesforce/label/c.ProfitLoss_Save_SuccessMessage';
import ProfitLoss_Date_ErrorMessage from '@salesforce/label/c.ProfitLoss_Date_ErrorMessage';
import ProfitLoss_PreviousFyDate_ErrorMessage from '@salesforce/label/c.ProfitLoss_PreviousFyDate_ErrorMessage';
import ProfitLoss_CurrentFyDate_ErrorMessage from '@salesforce/label/c.ProfitLoss_CurrentFyDate_ErrorMessage';

export default class CaptureProfitAndLossDetails extends LightningElement {
    customLabel = {
        ProfitLoss_Save_SuccessMessage,
        ProfitLoss_Date_ErrorMessage,
        ProfitLoss_PreviousFyDate_ErrorMessage,
        ProfitLoss_CurrentFyDate_ErrorMessage
    }
    @track callBREMethod = false;
    @api layoutSize;
    @api hasEditAccess;
    @track d = new Date();
    @track mincurrentyear;
    @track maxcurrentyear;
    @track minprivousYear;
    @track maxprivousYear;
    @track minprovisionalYear;
    @track maxprovisionalYear;
    @track provisionalFinancialSelection = false;

    @track provisionalPicklistOptions = [{ label: 'Provisional', value: 'Provisional' }];
    @track _applicantId;
    @track selectedYear = '';
    @track hasProvisionalId = false;
    @track disableMode = false;
    @track _currentBlock;

    @track _provisionalOption;
    @track _provisionalYear;
    @track showSpinner = false;

    @api get provisionalOption() {
        return this._provisionalOption;
    }
    set provisionalOption(value) {
        this._provisionalOption = value;
        this.setAttribute("provisionalOption", value);
        this.checkProvisionalOptionValue();
        this.checkMinMaxProvisionalYear();
    }

    @api get provisionalYear() {
        return this._provisionalYear;
    }
    set provisionalYear(value) {
        this._provisionalYear = value;
        this.setAttribute("provisionalYear", value);
        this.checkProvisionalOptionValue();
        this.checkMinMaxProvisionalYear();
    }

    checkProvisionalOptionValue() {
        if (this._provisionalYear && this._provisionalOption && this._provisionalOption === 'Yes') {
            this.provisionalFinancialYearSelectionValue = true;
            this.selectedYear = this._provisionalYear;
            this.handleApplicantIdChange(null);
        } else {
            this.provisionalFinancialYearSelectionValue = false;
            this.selectedYear = undefined;
        }
    }

    @api get applicantId() {
        return this._applicantId;
    }
    set applicantId(value) {
        this._applicantId = value;
        this.setAttribute("applicantId", value);
        this.handleApplicantIdChange(value);
    }

    @api get currentBlock() {
        return this._currentBlock;
    }

    set currentBlock(value) {
        this._currentBlock = value;
        this.setAttribute('currentBlock', value);
        this.handleApplicantIdChange(value)
    }

    connectedCallback() {
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        }
        console.log('this.incrementdecrement'+JSON.stringify(this.incrementdecrement))
    }
    handleApplicantIdChange(value) {
        let tempParams = this.financialParams;
        tempParams.queryCriteria = ' where Loan_Applicant__c = \'' + this._applicantId + '\'' + ' AND RecordTypeId = \'' + this.recTypeId + '\''
        this.financialParams = { ...tempParams };
    }
    
    @track provisionalFinancialYearSelectionValue = false;
    
    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
    }
    
    @track _recordTypeId;
    @api get recordTypeId() {
        return this._recordTypeId;
    }
    set recordTypeId(value) {
        this._recordTypeId = value;
        this.setAttribute("recordTypeId", value);
        this.handlerecordTypeNameChange(value);
    }
    @track recTypeId;
    handlerecordTypeNameChange(event) {
        this.recTypeId = this._recordTypeId;
        this.handleApplicantIdChange();
    }

    @track wrapObj1 = {}; 

    @track wrapObj2 = {};

    @track wrapObj3 = {};

    @track incrementdecrement = {
        'Total_Sales__c': '0',
        'Other_Operating_Income_IncomeIncidental__c': '0',
        'Non_Operating_Income__c': '0',
        'Non_Business_Income__c': '0',
        'Opening_Stock__c': '0',
        'Closing_Stock__c': '0',
        'Purchases__c': '0',
        'Direct_Expenses__c': '0',
        'Gross_Profit__c': '0',
        'Office_Administrative_Expenses__c': '0',
        'Other_Indirect_Expenses__c': '0',
        'Non_Operating_Expenses_FxLoss_AssetLoss__c': '0',
        'Salary_to_Partner_Directors__c': '0',
        'EBITDA__c': '0',
        'Interest_on_Term_Loans__c': '0',
        'Interest_on_CC_OD_limits__c': '0',
        'Interest_on_Partner_Capital__c': '0',
        'Profit_Before_Depreciation_and_Tax_PBDT__c': '0',
        'Depreciation__c': '0',
        'Profit_Before_Tax__c': '0',
        'Taxes__c': '0',
        'PAT__c': '0',
    }
    @track incrementdecrement1 = {
        'Total_Sales__c': '0',
        'Other_Operating_Income_IncomeIncidental__c': '0',
        'Non_Operating_Income__c': '0',
        'Non_Business_Income__c': '0',
        'Opening_Stock__c': '0',
        'Closing_Stock__c': '0',
        'Purchases__c': '0',
        'Direct_Expenses__c': '0',
        'Gross_Profit__c': '0',
        'Office_Administrative_Expenses__c': '0',
        'Other_Indirect_Expenses__c': '0',
        'Non_Operating_Expenses_FxLoss_AssetLoss__c': '0',
        'Salary_to_Partner_Directors__c': '0',
        'EBITDA__c': '0',
        'Interest_on_Term_Loans__c': '0',
        'Interest_on_CC_OD_limits__c': '0',
        'Interest_on_Partner_Capital__c': '0',
        'Profit_Before_Depreciation_and_Tax_PBDT__c': '0',
        'Depreciation__c': '0',
        'Profit_Before_Tax__c': '0',
        'Taxes__c': '0',
        'PAT__c': '0',
    }
    @wire(getObjectInfo, { objectApiName: Applicant_Financial_Summary_OBJECT })
    objectInfo;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: TYPES_OF_ACCOUNTS })
    TypesofAccountPicklistValues;
    @track
    financialParams = {
        ParentObjectName: 'Applicant_Financial__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'Income_Documents__c', 'Loan_Applicant__c', 'RecordTypeId'],
        childObjFields: [],
        queryCriteria: ' where Loan_Applicant__c = \'' + this._applicantId + '\'' + ' AND RecordTypeId = \'' + this.recTypeId + '\''
    }
    @track actualFinancialData;

    @track financialRecordId;
    @wire(getSobjectData, { params: '$financialParams' })
    handleFinancialResponse(wiredResultIncome) {
        let { error, data } = wiredResultIncome;
        this.actualFinancialData = wiredResultIncome;
        if (data) {
            this.createEmptyWrapObj();
            console.log('inactualFinancialData')
            if (data.parentRecords && data.parentRecords.length > 0) {
                this.financialRecordId = data.parentRecords[0].Id;
                if (data.parentRecords[0].Id) {
                    this.financialRecordId = data.parentRecords[0].Id;
                    let tempParams = this.summaryParams;
                    tempParams.queryCriteria = ' where Applicant_Financial__c = \'' + this.financialRecordId + '\''
                    this.summaryParams = { ...tempParams };
                    this.getFinancialSummaryRecord();
                }
            }
            else {
                this.createApplicantFinancialRecord();
            }
        } else if (error) {
            this.showToastMessage("Error in handleFinancialResponse", error.body.message, "error", "sticky");
        }
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
    renderedCallback() {
        refreshApex(this.actualFinancialData);
    }

    createApplicantFinancialRecord() {
        this.showSpinner = true;
        let financialDetails = {
            Loan_Applicant__c: this._applicantId,
            sobjectType: 'Applicant_Financial__c',
            RecordTypeId: this.recTypeId
        };
        let upsertData = {
            parentRecord: financialDetails,
            ChildRecords: [],
            ParentFieldNameToUpdate: 'Applicant_Financial__c'
        }
        upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
        .then(result => {
            if (result) {
                if (result.parentRecord) {
                    this.financialRecordId = result.parentRecord.Id;
                }
            }
            this.showSpinner = false;
        })
        .catch(error => {
            this.showToastMessage("Error in createApplicantFinancialRecord", error.body.message, "error", "sticky");
            this.showSpinner = false;
        })
    }


    @track summaryParams = {
        ParentObjectName: 'Applicant_Financial_Summary__c ',
        ChildObjectRelName: null,
        parentObjFields: ['Id','ExportSalesOutOfAboveSalesRemark__c','ExportSalesOutOfAboveSales__c','Income_addition_u_s_40_a_2_b__c','Tax_on_the_above_inc_for_Addition__c','Net_inc_con_for_Eligibility_for_add_Inc__c', 'Type_of_Accounts__c', 'Financial_Year__c', 'Date_of_Filing_ITR__c', 'Total_Sales__c', 'Other_Operating_Income_IncomeIncidental__c', 'Non_Operating_Income__c', 'Non_Business_Income__c', 'Opening_Stock__c', 'Closing_Stock__c', 'Purchases__c', 'Direct_Expenses__c', 'Gross_Profit__c', 'Office_Administrative_Expenses__c', 'Other_Indirect_Expenses__c', 'Non_Operating_Expenses_FxLoss_AssetLoss__c', 'Salary_to_Partner_Directors__c', 'EBITDA__c', 'Interest_on_Term_Loans__c', 'Interest_on_CC_OD_limits__c', 'Interest_on_Partner_Capital__c', 'Profit_Before_Depreciation_and_Tax_PBDT__c', 'Depreciation__c', 'Profit_Before_Tax__c', 'Taxes__c', 'PAT__c', 'Director_Partners_remuneration_Interest__c', 'Tax_on_Above_Income__c', 'Net_Income_Considered_for_Eligibility__c', 'Applicant_Financial__c', 'Total_Sales_Remark__c', 'Other_Operating_Income_Remark__c', 'Non_Operating_Income_Remark__c', 'Non_Business_Income_Remark__c', 'Opening_Stock_Remark__c', 'Closing_Stock_Remark__c', 'Purchases_Remark__c', 'Direct_Expenses_Remark__c', 'Gross_Profit_Remark__c', 'Office_Administrative_Expenses_Remark__c', 'Other_Indirect_Expenses_Remark__c', 'Non_Operating_Expenses_Remark__c', 'Salary_to_Partner_Directors_Remark__c', 'EBITDA_Remark__c', 'Interest_on_Term_Loans_Remark__c', 'Interest_on_CC_OD_limits_Remark__c', 'Interest_on_Partner_Capital_Remark__c', 'Profit_Before_Depreciation_PBDT_Remark__c', 'Depreciation_Remark__c', 'Profit_Before_Tax_Remark__c', 'Taxes_Remark__c', 'PAT_Remark__c', 'Comments_on_Profit_Loss__c', 'ITR_Filing_Gap_Days__c'],
        childObjFields: [],
        queryCriteria: ' where Applicant_Financial__c = \'' + this.financialRecordId + '\''
    }

    get privousYear() {
        if (this._currentBlock) {
            let [previousfirstPart, previoussecondPart] = this._currentBlock.split('-');
            previousfirstPart = parseInt(previousfirstPart);
            previoussecondPart = parseInt(previoussecondPart);
            const previousYear = `${previousfirstPart - 1}-${previoussecondPart - 1}`;
            this.minprivousYear = (previoussecondPart - 1) + '-04' + '-01';
            var todayDate = new Date();
            var yearValue = (todayDate.getFullYear());
            var monthValue = String(todayDate.getMonth() + 1).padStart(2, '0'); 
            var dayValue = String(todayDate.getDate()).padStart(2, '0');
            const formattedDate = `${yearValue}-${monthValue}-${dayValue}`;
            this.maxprivousYear = formattedDate;

            return previousYear;
        } else {
            return null;
        }
    }

    get currentYear() {
        if (this._currentBlock) {
            let [currentfirstPart, currentsecondPart] = this._currentBlock.split('-');
            currentfirstPart = parseInt(currentfirstPart);
            currentsecondPart = parseInt(currentsecondPart);
            const financialYear = `${currentfirstPart}-${currentsecondPart}`;
            this.mincurrentyear = currentsecondPart + '-04' + '-01';
            var todayDate = new Date();
            var yearValue = (todayDate.getFullYear());
            var monthValue = String(todayDate.getMonth() + 1).padStart(2, '0'); 
            var dayValue = String(todayDate.getDate()).padStart(2, '0');
            const formattedDate = `${yearValue}-${monthValue}-${dayValue}`;
            this.maxcurrentyear = formattedDate;
            return financialYear;
        } else {
            return null;
        }
    }

    checkMinMaxProvisionalYear() {
        if (this._provisionalYear) {
            let [upcomingfirstPart, upcomingsecondPart] = this._provisionalYear.split('-');
            upcomingfirstPart = parseInt(upcomingfirstPart);
            upcomingsecondPart = parseInt(upcomingsecondPart);
            const upcomingFinancialYear = `${(upcomingfirstPart + 1)}-${(upcomingsecondPart + 1)}`;
            this.minprovisionalYear = (upcomingsecondPart + 1) + '-04' + '-01';
            this.maxprovisionalYear = (upcomingsecondPart + 1) + '-12' + '-31';
            return upcomingFinancialYear;
        } else {
            return null;
        }
    }


    getFinancialSummaryRecord() {
        getSobjectDataNonCacheable({ params: this.summaryParams })
        .then(result => {
            if (result) {
                if (result.parentRecords) {
                    console.log('result.parentRecordsresult.parentRecords'+JSON.stringify(result.parentRecords))
                    this.financialRecordProcessor(result.parentRecords);
                }
            }
        })
        .catch(error => {
            this.showToastMessage("Error in getFinancialSummaryRecord ", error.body.message, "error", "sticky");
        })
    }

    createEmptyWrapObj() {
        const commonFields = {
            'Type_of_Accounts__c': '',
            'Date_of_Filing_ITR__c': '',
            'Total_Sales__c': '0',
            'Other_Operating_Income_IncomeIncidental__c': '0',
            'ExportSalesOutOfAboveSales__c': '0',
            'Non_Operating_Income__c': '0',
            'Non_Business_Income__c': '0',
            'Opening_Stock__c': '0',
            'Closing_Stock__c': '0',
            'Purchases__c': '0',
            'Direct_Expenses__c': '0',
            'Gross_Profit__c': '0',
            'Office_Administrative_Expenses__c': '0',
            'Other_Indirect_Expenses__c': '0',
            'Non_Operating_Expenses_FxLoss_AssetLoss__c': '0',
            'Salary_to_Partner_Directors__c': '0',
            'EBITDA__c': '0',
            'Interest_on_Term_Loans__c': '0',
            'Interest_on_CC_OD_limits__c': '0',
            'Interest_on_Partner_Capital__c': '0',
            'Profit_Before_Depreciation_and_Tax_PBDT__c': '0',
            'Depreciation__c': '0',
            'Profit_Before_Tax__c': '0',
            'Taxes__c': '0',
            'PAT__c': '0',
            'Director_Partners_remuneration_Interest__c': '0',
            'Tax_on_Above_Income__c': '0',
            'Net_Income_Considered_for_Eligibility__c': '0',
            'Income_addition_u_s_40_a_2_b__c': '0',
            'Tax_on_the_above_inc_for_Addition__c': '0',
            'Net_inc_con_for_Eligibility_for_add_Inc__c': '0',
            'Applicant_Financial__c': this.financialRecordId,
            'sobjectType': 'Applicant_Financial_Summary__c',
            'Total_Sales_Remark__c': '',
            'Other_Operating_Income_Remark__c': '',
            'ExportSalesOutOfAboveSalesRemark__c': '',
            'Non_Operating_Income_Remark__c': '',
            'Non_Business_Income_Remark__c': '',
            'Opening_Stock_Remark__c': '',
            'Closing_Stock_Remark__c': '',
            'Purchases_Remark__c': '',
            'Direct_Expenses_Remark__c': '',
            'Gross_Profit_Remark__c': '',
            'Office_Administrative_Expenses_Remark__c': '',
            'Other_Indirect_Expenses_Remark__c': '',
            'Non_Operating_Expenses_Remark__c': '',
            'Salary_to_Partner_Directors_Remark__c': '',
            'EBITDA_Remark__c': '',
            'Interest_on_Term_Loans_Remark__c': '',
            'Interest_on_CC_OD_limits_Remark__c': '',
            'Interest_on_Partner_Capital_Remark__c': '',
            'Profit_Before_Depreciation_PBDT_Remark__c': '',
            'Depreciation_Remark__c': '',
            'Profit_Before_Tax_Remark__c': '',
            'Taxes_Remark__c': '',
            'PAT_Remark__c': '',
            'Comments_on_Profit_Loss__c': '',
            'Previous_Financial_Year__c': false,
            'Current_Financial_Year__c': false,
            'Provisional_Financial_Year__c': false
        };
    
        this.wrapObj1 = { ...commonFields, 'Financial_Year__c': this.privousYear, 'Previous_Financial_Year__c': true};
        this.wrapObj2 = { ...commonFields, 'Financial_Year__c': this.currentYear, 'Current_Financial_Year__c': true, 'ITR_Filing_Gap_Days__c': '0'};
        this.wrapObj3 = { ...commonFields, 'Financial_Year__c': this._provisionalYear, 'Type_of_Accounts__c': 'Provisional', 'Provisional_Financial_Year__c': true};
    }
    

    financialRecordProcessor(financialDataProcess) {
        //this.createEmptyWrapObj();
        if (financialDataProcess) {
            let calculatePercent = false;
            if (financialDataProcess.length > 0) {
                financialDataProcess.forEach(newItem => {
                    let year1 = this.privousYear;
                    let year2 = this.currentYear;
                    let year3 = this._provisionalYear;

                    if (newItem.Financial_Year__c == year1) {
                        this.wrapObj1.Financial_Year__c = newItem.Financial_Year__c;
                        this.wrapObj1.Id = newItem.Id;
                        this.wrapObj1.Type_of_Accounts__c = newItem.Type_of_Accounts__c ? newItem.Type_of_Accounts__c : '';
                        this.wrapObj1.Date_of_Filing_ITR__c = newItem.Date_of_Filing_ITR__c ? newItem.Date_of_Filing_ITR__c : '';
                        this.wrapObj1.Total_Sales__c = newItem.Total_Sales__c ? newItem.Total_Sales__c : '0';
                        this.wrapObj1.Other_Operating_Income_IncomeIncidental__c = newItem.Other_Operating_Income_IncomeIncidental__c ? newItem.Other_Operating_Income_IncomeIncidental__c : '0';
                        this.wrapObj1.ExportSalesOutOfAboveSales__c = newItem.ExportSalesOutOfAboveSales__c ? newItem.ExportSalesOutOfAboveSales__c : '0';
                        this.wrapObj1.Non_Operating_Income__c = newItem.Non_Operating_Income__c ? newItem.Non_Operating_Income__c : '0';
                        this.wrapObj1.Non_Business_Income__c = newItem.Non_Business_Income__c ? newItem.Non_Business_Income__c : '0';
                        this.wrapObj1.Opening_Stock__c = newItem.Opening_Stock__c ? newItem.Opening_Stock__c : '0';
                        this.wrapObj1.Closing_Stock__c = newItem.Closing_Stock__c ? newItem.Closing_Stock__c : '0';
                        this.wrapObj1.Purchases__c = newItem.Purchases__c ? newItem.Purchases__c : '0';
                        this.wrapObj1.Direct_Expenses__c = newItem.Direct_Expenses__c ? newItem.Direct_Expenses__c : '0';
                        this.wrapObj1.Gross_Profit__c = newItem.Gross_Profit__c ? newItem.Gross_Profit__c : '0';
                        this.wrapObj1.Office_Administrative_Expenses__c = newItem.Office_Administrative_Expenses__c ? newItem.Office_Administrative_Expenses__c : '0';
                        this.wrapObj1.Other_Indirect_Expenses__c = newItem.Other_Indirect_Expenses__c ? newItem.Other_Indirect_Expenses__c : '0';
                        this.wrapObj1.Non_Operating_Expenses_FxLoss_AssetLoss__c = newItem.Non_Operating_Expenses_FxLoss_AssetLoss__c ? newItem.Non_Operating_Expenses_FxLoss_AssetLoss__c : '0';
                        this.wrapObj1.Salary_to_Partner_Directors__c = newItem.Salary_to_Partner_Directors__c ? newItem.Salary_to_Partner_Directors__c : '0';
                        this.wrapObj1.EBITDA__c = newItem.EBITDA__c ? newItem.EBITDA__c : '0';
                        this.wrapObj1.Interest_on_Term_Loans__c = newItem.Interest_on_Term_Loans__c ? newItem.Interest_on_Term_Loans__c : '0';
                        this.wrapObj1.Interest_on_CC_OD_limits__c = newItem.Interest_on_CC_OD_limits__c ? newItem.Interest_on_CC_OD_limits__c : '0';
                        this.wrapObj1.Interest_on_Partner_Capital__c = newItem.Interest_on_Partner_Capital__c ? newItem.Interest_on_Partner_Capital__c : '0';
                        this.wrapObj1.Profit_Before_Depreciation_and_Tax_PBDT__c = newItem.Profit_Before_Depreciation_and_Tax_PBDT__c ? newItem.Profit_Before_Depreciation_and_Tax_PBDT__c : '0';
                        this.wrapObj1.Depreciation__c = newItem.Depreciation__c ? newItem.Depreciation__c : '0';
                        this.wrapObj1.Profit_Before_Tax__c = newItem.Profit_Before_Tax__c ? newItem.Profit_Before_Tax__c : '0';
                        this.wrapObj1.Taxes__c = newItem.Taxes__c ? newItem.Taxes__c : '0';
                        this.wrapObj1.PAT__c = newItem.PAT__c ? newItem.PAT__c : '0';
                        this.wrapObj1.Director_Partners_remuneration_Interest__c = newItem.Director_Partners_remuneration_Interest__c ? newItem.Director_Partners_remuneration_Interest__c : '0';
                        this.wrapObj1.Tax_on_Above_Income__c = newItem.Tax_on_Above_Income__c ? newItem.Tax_on_Above_Income__c : '0';
                        this.wrapObj1.Net_Income_Considered_for_Eligibility__c = newItem.Net_Income_Considered_for_Eligibility__c ? newItem.Net_Income_Considered_for_Eligibility__c : '0';
                        
                        this.wrapObj1.Income_addition_u_s_40_a_2_b__c = newItem.Income_addition_u_s_40_a_2_b__c ? newItem.Income_addition_u_s_40_a_2_b__c : '0';
                        this.wrapObj1.Tax_on_the_above_inc_for_Addition__c = newItem.Tax_on_the_above_inc_for_Addition__c ? newItem.Tax_on_the_above_inc_for_Addition__c : '0';
                        this.wrapObj1.Net_inc_con_for_Eligibility_for_add_Inc__c = newItem.Net_inc_con_for_Eligibility_for_add_Inc__c ? newItem.Net_inc_con_for_Eligibility_for_add_Inc__c : '0';
                        
                        this.wrapObj1.Applicant_Financial__c = newItem.Applicant_Financial__c;
                        // Replace 'Field_Name__c' and 'Field_Name_Remark__c' with the actual field names
                        this.wrapObj1.Total_Sales_Remark__c = newItem.Total_Sales_Remark__c ? newItem.Total_Sales_Remark__c : '';
                        this.wrapObj1.Other_Operating_Income_Remark__c = newItem.Other_Operating_Income_Remark__c ? newItem.Other_Operating_Income_Remark__c : '';
                        this.wrapObj1.ExportSalesOutOfAboveSalesRemark__c = newItem.ExportSalesOutOfAboveSalesRemark__c ? newItem.ExportSalesOutOfAboveSalesRemark__c : '';
                        this.wrapObj1.Non_Operating_Income_Remark__c = newItem.Non_Operating_Income_Remark__c ? newItem.Non_Operating_Income_Remark__c : '';
                        this.wrapObj1.Non_Business_Income_Remark__c = newItem.Non_Business_Income_Remark__c ? newItem.Non_Business_Income_Remark__c : '';
                        this.wrapObj1.Opening_Stock_Remark__c = newItem.Opening_Stock_Remark__c ? newItem.Opening_Stock_Remark__c : '';
                        this.wrapObj1.Closing_Stock_Remark__c = newItem.Closing_Stock_Remark__c ? newItem.Closing_Stock_Remark__c : '';
                        this.wrapObj1.Purchases_Remark__c = newItem.Purchases_Remark__c ? newItem.Purchases_Remark__c : '';
                        this.wrapObj1.Direct_Expenses_Remark__c = newItem.Direct_Expenses_Remark__c ? newItem.Direct_Expenses_Remark__c : '';
                        this.wrapObj1.Gross_Profit_Remark__c = newItem.Gross_Profit_Remark__c ? newItem.Gross_Profit_Remark__c : '';
                        this.wrapObj1.Office_Administrative_Expenses_Remark__c = newItem.Office_Administrative_Expenses_Remark__c ? newItem.Office_Administrative_Expenses_Remark__c : '';
                        this.wrapObj1.Other_Indirect_Expenses_Remark__c = newItem.Other_Indirect_Expenses_Remark__c ? newItem.Other_Indirect_Expenses_Remark__c : '';
                        this.wrapObj1.Non_Operating_Expenses_Remark__c = newItem.Non_Operating_Expenses_Remark__c ? newItem.Non_Operating_Expenses_Remark__c : '';
                        this.wrapObj1.Salary_to_Partner_Directors_Remark__c = newItem.Salary_to_Partner_Directors_Remark__c ? newItem.Salary_to_Partner_Directors_Remark__c : '';
                        this.wrapObj1.EBITDA_Remark__c = newItem.EBITDA_Remark__c ? newItem.EBITDA_Remark__c : '';
                        this.wrapObj1.Interest_on_Term_Loans_Remark__c = newItem.Interest_on_Term_Loans_Remark__c ? newItem.Interest_on_Term_Loans_Remark__c : '';
                        this.wrapObj1.Interest_on_CC_OD_limits_Remark__c = newItem.Interest_on_CC_OD_limits_Remark__c ? newItem.Interest_on_CC_OD_limits_Remark__c : '';
                        this.wrapObj1.Interest_on_Partner_Capital_Remark__c = newItem.Interest_on_Partner_Capital_Remark__c ? newItem.Interest_on_Partner_Capital_Remark__c : '';
                        this.wrapObj1.Profit_Before_Depreciation_PBDT_Remark__c = newItem.Profit_Before_Depreciation_PBDT_Remark__c ? newItem.Profit_Before_Depreciation_PBDT_Remark__c : '';
                        this.wrapObj1.Depreciation_Remark__c = newItem.Depreciation_Remark__c ? newItem.Depreciation_Remark__c : '';
                        this.wrapObj1.Profit_Before_Tax_Remark__c = newItem.Profit_Before_Tax_Remark__c ? newItem.Profit_Before_Tax_Remark__c : '';
                        this.wrapObj1.Taxes_Remark__c = newItem.Taxes_Remark__c ? newItem.Taxes_Remark__c : '';
                        this.wrapObj1.PAT_Remark__c = newItem.PAT_Remark__c ? newItem.PAT_Remark__c : '';
                        this.wrapObj1.Comments_on_Profit_Loss__c = newItem.Comments_on_Profit_Loss__c ? newItem.Comments_on_Profit_Loss__c : '';

                        this.wrapObj1.Previous_Financial_Year__c = true;
                        this.wrapObj1.Current_Financial_Year__c = false;
                        this.wrapObj1.Provisional_Financial_Year__c = false;

                        calculatePercent = true;
                    }
                    if (newItem.Financial_Year__c == year2) {
                        this.wrapObj2.Financial_Year__c = newItem.Financial_Year__c;
                        this.wrapObj2.Id = newItem.Id;
                        this.wrapObj2.Type_of_Accounts__c = newItem.Type_of_Accounts__c ? newItem.Type_of_Accounts__c : '';
                        this.wrapObj2.Date_of_Filing_ITR__c = newItem.Date_of_Filing_ITR__c ? newItem.Date_of_Filing_ITR__c : '';
                        this.wrapObj2.Total_Sales__c = newItem.Total_Sales__c ? newItem.Total_Sales__c : '0';
                        this.wrapObj2.Other_Operating_Income_IncomeIncidental__c = newItem.Other_Operating_Income_IncomeIncidental__c ? newItem.Other_Operating_Income_IncomeIncidental__c : '0';
                        this.wrapObj2.ExportSalesOutOfAboveSales__c = newItem.ExportSalesOutOfAboveSales__c ? newItem.ExportSalesOutOfAboveSales__c : '0';
                        this.wrapObj2.Non_Operating_Income__c = newItem.Non_Operating_Income__c ? newItem.Non_Operating_Income__c : '0';
                        this.wrapObj2.Non_Business_Income__c = newItem.Non_Business_Income__c ? newItem.Non_Business_Income__c : '0';
                        this.wrapObj2.Opening_Stock__c = newItem.Opening_Stock__c ? newItem.Opening_Stock__c : '0';
                        this.wrapObj2.Closing_Stock__c = newItem.Closing_Stock__c ? newItem.Closing_Stock__c : '0';
                        this.wrapObj2.Purchases__c = newItem.Purchases__c ? newItem.Purchases__c : '0';
                        this.wrapObj2.Direct_Expenses__c = newItem.Direct_Expenses__c ? newItem.Direct_Expenses__c : '0';
                        this.wrapObj2.Gross_Profit__c = newItem.Gross_Profit__c ? newItem.Gross_Profit__c : '0';
                        this.wrapObj2.Office_Administrative_Expenses__c = newItem.Office_Administrative_Expenses__c ? newItem.Office_Administrative_Expenses__c : '0';
                        this.wrapObj2.Other_Indirect_Expenses__c = newItem.Other_Indirect_Expenses__c ? newItem.Other_Indirect_Expenses__c : '0';
                        this.wrapObj2.Non_Operating_Expenses_FxLoss_AssetLoss__c = newItem.Non_Operating_Expenses_FxLoss_AssetLoss__c ? newItem.Non_Operating_Expenses_FxLoss_AssetLoss__c : '0';
                        this.wrapObj2.Salary_to_Partner_Directors__c = newItem.Salary_to_Partner_Directors__c ? newItem.Salary_to_Partner_Directors__c : '0';
                        this.wrapObj2.EBITDA__c = newItem.EBITDA__c ? newItem.EBITDA__c : '0';
                        this.wrapObj2.Interest_on_Term_Loans__c = newItem.Interest_on_Term_Loans__c ? newItem.Interest_on_Term_Loans__c : '0';
                        this.wrapObj2.Interest_on_CC_OD_limits__c = newItem.Interest_on_CC_OD_limits__c ? newItem.Interest_on_CC_OD_limits__c : '0';
                        this.wrapObj2.Interest_on_Partner_Capital__c = newItem.Interest_on_Partner_Capital__c ? newItem.Interest_on_Partner_Capital__c : '0';
                        this.wrapObj2.Profit_Before_Depreciation_and_Tax_PBDT__c = newItem.Profit_Before_Depreciation_and_Tax_PBDT__c ? newItem.Profit_Before_Depreciation_and_Tax_PBDT__c : '0';
                        this.wrapObj2.Depreciation__c = newItem.Depreciation__c ? newItem.Depreciation__c : '0';
                        this.wrapObj2.Profit_Before_Tax__c = newItem.Profit_Before_Tax__c ? newItem.Profit_Before_Tax__c : '0';
                        this.wrapObj2.Taxes__c = newItem.Taxes__c ? newItem.Taxes__c : '0';
                        this.wrapObj2.PAT__c = newItem.PAT__c ? newItem.PAT__c : '0';
                        this.wrapObj2.Director_Partners_remuneration_Interest__c = newItem.Director_Partners_remuneration_Interest__c ? newItem.Director_Partners_remuneration_Interest__c : '0';
                        this.wrapObj2.Tax_on_Above_Income__c = newItem.Tax_on_Above_Income__c ? newItem.Tax_on_Above_Income__c : '0';
                        this.wrapObj2.Net_Income_Considered_for_Eligibility__c = newItem.Net_Income_Considered_for_Eligibility__c ? newItem.Net_Income_Considered_for_Eligibility__c : '0';
                        
                        this.wrapObj2.Income_addition_u_s_40_a_2_b__c = newItem.Income_addition_u_s_40_a_2_b__c ? newItem.Income_addition_u_s_40_a_2_b__c : '0';
                        this.wrapObj2.Tax_on_the_above_inc_for_Addition__c = newItem.Tax_on_the_above_inc_for_Addition__c ? newItem.Tax_on_the_above_inc_for_Addition__c : '0';
                        this.wrapObj2.Net_inc_con_for_Eligibility_for_add_Inc__c = newItem.Net_inc_con_for_Eligibility_for_add_Inc__c ? newItem.Net_inc_con_for_Eligibility_for_add_Inc__c : '0';
                        
                        
                        // Replace 'Field_Name__c' and 'Field_Name_Remark__c' with the actual field names
                        this.wrapObj2.Total_Sales_Remark__c = newItem.Total_Sales_Remark__c ? newItem.Total_Sales_Remark__c : '';
                        this.wrapObj2.Other_Operating_Income_Remark__c = newItem.Other_Operating_Income_Remark__c ? newItem.Other_Operating_Income_Remark__c : '';
                        this.wrapObj2.ExportSalesOutOfAboveSalesRemark__c = newItem.ExportSalesOutOfAboveSalesRemark__c ? newItem.ExportSalesOutOfAboveSalesRemark__c : '';
                        this.wrapObj2.Non_Operating_Income_Remark__c = newItem.Non_Operating_Income_Remark__c ? newItem.Non_Operating_Income_Remark__c : '';
                        this.wrapObj2.Non_Business_Income_Remark__c = newItem.Non_Business_Income_Remark__c ? newItem.Non_Business_Income_Remark__c : '';
                        this.wrapObj2.Opening_Stock_Remark__c = newItem.Opening_Stock_Remark__c ? newItem.Opening_Stock_Remark__c : '';
                        this.wrapObj2.Closing_Stock_Remark__c = newItem.Closing_Stock_Remark__c ? newItem.Closing_Stock_Remark__c : '';
                        this.wrapObj2.Purchases_Remark__c = newItem.Purchases_Remark__c ? newItem.Purchases_Remark__c : '';
                        this.wrapObj2.Direct_Expenses_Remark__c = newItem.Direct_Expenses_Remark__c ? newItem.Direct_Expenses_Remark__c : '';
                        this.wrapObj2.Gross_Profit_Remark__c = newItem.Gross_Profit_Remark__c ? newItem.Gross_Profit_Remark__c : '';
                        this.wrapObj2.Office_Administrative_Expenses_Remark__c = newItem.Office_Administrative_Expenses_Remark__c ? newItem.Office_Administrative_Expenses_Remark__c : '';
                        this.wrapObj2.Other_Indirect_Expenses_Remark__c = newItem.Other_Indirect_Expenses_Remark__c ? newItem.Other_Indirect_Expenses_Remark__c : '';
                        this.wrapObj2.Non_Operating_Expenses_Remark__c = newItem.Non_Operating_Expenses_Remark__c ? newItem.Non_Operating_Expenses_Remark__c : '';
                        this.wrapObj2.Salary_to_Partner_Directors_Remark__c = newItem.Salary_to_Partner_Directors_Remark__c ? newItem.Salary_to_Partner_Directors_Remark__c : '';
                        this.wrapObj2.EBITDA_Remark__c = newItem.EBITDA_Remark__c ? newItem.EBITDA_Remark__c : '';
                        this.wrapObj2.Interest_on_Term_Loans_Remark__c = newItem.Interest_on_Term_Loans_Remark__c ? newItem.Interest_on_Term_Loans_Remark__c : '';
                        this.wrapObj2.Interest_on_CC_OD_limits_Remark__c = newItem.Interest_on_CC_OD_limits_Remark__c ? newItem.Interest_on_CC_OD_limits_Remark__c : '';
                        this.wrapObj2.Interest_on_Partner_Capital_Remark__c = newItem.Interest_on_Partner_Capital_Remark__c ? newItem.Interest_on_Partner_Capital_Remark__c : '';
                        this.wrapObj2.Profit_Before_Depreciation_PBDT_Remark__c = newItem.Profit_Before_Depreciation_PBDT_Remark__c ? newItem.Profit_Before_Depreciation_PBDT_Remark__c : '';
                        this.wrapObj2.Depreciation_Remark__c = newItem.Depreciation_Remark__c ? newItem.Depreciation_Remark__c : '';
                        this.wrapObj2.Profit_Before_Tax_Remark__c = newItem.Profit_Before_Tax_Remark__c ? newItem.Profit_Before_Tax_Remark__c : '';
                        this.wrapObj2.Taxes_Remark__c = newItem.Taxes_Remark__c ? newItem.Taxes_Remark__c : '';
                        this.wrapObj2.PAT_Remark__c = newItem.PAT_Remark__c ? newItem.PAT_Remark__c : '';
                        this.wrapObj2.Comments_on_Profit_Loss__c = newItem.Comments_on_Profit_Loss__c ? newItem.Comments_on_Profit_Loss__c : '';
                        this.wrapObj2.ITR_Filing_Gap_Days__c = newItem.ITR_Filing_Gap_Days__c ? newItem.ITR_Filing_Gap_Days__c : '0';

                        this.wrapObj2.Previous_Financial_Year__c = false;
                        this.wrapObj2.Current_Financial_Year__c = true;
                        this.wrapObj2.Provisional_Financial_Year__c = false;

                        calculatePercent = true;
                    }
                    if (newItem.Financial_Year__c == year3) {
                        this.hasProvisionalId = true;
                        this.wrapObj3.Financial_Year__c = newItem.Financial_Year__c;
                        this.wrapObj3.Id = newItem.Id;
                        this.wrapObj3.Type_of_Accounts__c = newItem.Type_of_Accounts__c ? newItem.Type_of_Accounts__c : '';
                        this.wrapObj3.Date_of_Filing_ITR__c = newItem.Date_of_Filing_ITR__c ? newItem.Date_of_Filing_ITR__c : '';
                        this.wrapObj3.Total_Sales__c = newItem.Total_Sales__c ? newItem.Total_Sales__c : '0';
                        this.wrapObj3.Other_Operating_Income_IncomeIncidental__c = newItem.Other_Operating_Income_IncomeIncidental__c ? newItem.Other_Operating_Income_IncomeIncidental__c : '0';
                        this.wrapObj3.ExportSalesOutOfAboveSales__c = newItem.ExportSalesOutOfAboveSales__c ? newItem.ExportSalesOutOfAboveSales__c : '0';
                        this.wrapObj3.Non_Operating_Income__c = newItem.Non_Operating_Income__c ? newItem.Non_Operating_Income__c : '0';
                        this.wrapObj3.Non_Business_Income__c = newItem.Non_Business_Income__c ? newItem.Non_Business_Income__c : '0';
                        this.wrapObj3.Opening_Stock__c = newItem.Opening_Stock__c ? newItem.Opening_Stock__c : '0';
                        this.wrapObj3.Closing_Stock__c = newItem.Closing_Stock__c ? newItem.Closing_Stock__c : '0';
                        this.wrapObj3.Purchases__c = newItem.Purchases__c ? newItem.Purchases__c : '0';
                        this.wrapObj3.Direct_Expenses__c = newItem.Direct_Expenses__c ? newItem.Direct_Expenses__c : '0';
                        this.wrapObj3.Gross_Profit__c = newItem.Gross_Profit__c ? newItem.Gross_Profit__c : '0';
                        this.wrapObj3.Office_Administrative_Expenses__c = newItem.Office_Administrative_Expenses__c ? newItem.Office_Administrative_Expenses__c : '0';
                        this.wrapObj3.Other_Indirect_Expenses__c = newItem.Other_Indirect_Expenses__c ? newItem.Other_Indirect_Expenses__c : '0';
                        this.wrapObj3.Non_Operating_Expenses_FxLoss_AssetLoss__c = newItem.Non_Operating_Expenses_FxLoss_AssetLoss__c ? newItem.Non_Operating_Expenses_FxLoss_AssetLoss__c : '0';
                        this.wrapObj3.Salary_to_Partner_Directors__c = newItem.Salary_to_Partner_Directors__c ? newItem.Salary_to_Partner_Directors__c : '0';
                        this.wrapObj3.EBITDA__c = newItem.EBITDA__c ? newItem.EBITDA__c : '0';
                        this.wrapObj3.Interest_on_Term_Loans__c = newItem.Interest_on_Term_Loans__c ? newItem.Interest_on_Term_Loans__c : '0';
                        this.wrapObj3.Interest_on_CC_OD_limits__c = newItem.Interest_on_CC_OD_limits__c ? newItem.Interest_on_CC_OD_limits__c : '0';
                        this.wrapObj3.Interest_on_Partner_Capital__c = newItem.Interest_on_Partner_Capital__c ? newItem.Interest_on_Partner_Capital__c : '0';
                        this.wrapObj3.Profit_Before_Depreciation_and_Tax_PBDT__c = newItem.Profit_Before_Depreciation_and_Tax_PBDT__c ? newItem.Profit_Before_Depreciation_and_Tax_PBDT__c : '0';
                        this.wrapObj3.Depreciation__c = newItem.Depreciation__c ? newItem.Depreciation__c : '0';
                        this.wrapObj3.Profit_Before_Tax__c = newItem.Profit_Before_Tax__c ? newItem.Profit_Before_Tax__c : '0';
                        this.wrapObj3.Taxes__c = newItem.Taxes__c ? newItem.Taxes__c : '0';
                        this.wrapObj3.PAT__c = newItem.PAT__c ? newItem.PAT__c : '0';
                        this.wrapObj3.Director_Partners_remuneration_Interest__c = newItem.Director_Partners_remuneration_Interest__c ? newItem.Director_Partners_remuneration_Interest__c : '0';
                        this.wrapObj3.Tax_on_Above_Income__c = newItem.Tax_on_Above_Income__c ? newItem.Tax_on_Above_Income__c : '0';
                        this.wrapObj3.Net_Income_Considered_for_Eligibility__c = newItem.Net_Income_Considered_for_Eligibility__c ? newItem.Net_Income_Considered_for_Eligibility__c : '0';
                        
                        this.wrapObj3.Income_addition_u_s_40_a_2_b__c = newItem.Income_addition_u_s_40_a_2_b__c ? newItem.Income_addition_u_s_40_a_2_b__c : '0';
                        this.wrapObj3.Tax_on_the_above_inc_for_Addition__c = newItem.Tax_on_the_above_inc_for_Addition__c ? newItem.Tax_on_the_above_inc_for_Addition__c : '0';
                        this.wrapObj3.Net_inc_con_for_Eligibility_for_add_Inc__c = newItem.Net_inc_con_for_Eligibility_for_add_Inc__c ? newItem.Net_inc_con_for_Eligibility_for_add_Inc__c : '0';
                        
                        
                        // Replace 'Field_Name__c' and 'Field_Name_Remark__c' with the actual field names
                        this.wrapObj3.Total_Sales_Remark__c = newItem.Total_Sales_Remark__c ? newItem.Total_Sales_Remark__c : '';
                        this.wrapObj3.Other_Operating_Income_Remark__c = newItem.Other_Operating_Income_Remark__c ? newItem.Other_Operating_Income_Remark__c : '';
                        this.wrapObj3.ExportSalesOutOfAboveSalesRemark__c = newItem.ExportSalesOutOfAboveSalesRemark__c ? newItem.ExportSalesOutOfAboveSalesRemark__c : '';
                        this.wrapObj3.Non_Operating_Income_Remark__c = newItem.Non_Operating_Income_Remark__c ? newItem.Non_Operating_Income_Remark__c : '';
                        this.wrapObj3.Non_Business_Income_Remark__c = newItem.Non_Business_Income_Remark__c ? newItem.Non_Business_Income_Remark__c : '';
                        this.wrapObj3.Opening_Stock_Remark__c = newItem.Opening_Stock_Remark__c ? newItem.Opening_Stock_Remark__c : '';
                        this.wrapObj3.Closing_Stock_Remark__c = newItem.Closing_Stock_Remark__c ? newItem.Closing_Stock_Remark__c : '';
                        this.wrapObj3.Purchases_Remark__c = newItem.Purchases_Remark__c ? newItem.Purchases_Remark__c : '';
                        this.wrapObj3.Direct_Expenses_Remark__c = newItem.Direct_Expenses_Remark__c ? newItem.Direct_Expenses_Remark__c : '';
                        this.wrapObj3.Gross_Profit_Remark__c = newItem.Gross_Profit_Remark__c ? newItem.Gross_Profit_Remark__c : '';
                        this.wrapObj3.Office_Administrative_Expenses_Remark__c = newItem.Office_Administrative_Expenses_Remark__c ? newItem.Office_Administrative_Expenses_Remark__c : '';
                        this.wrapObj3.Other_Indirect_Expenses_Remark__c = newItem.Other_Indirect_Expenses_Remark__c ? newItem.Other_Indirect_Expenses_Remark__c : '';
                        this.wrapObj3.Non_Operating_Expenses_Remark__c = newItem.Non_Operating_Expenses_Remark__c ? newItem.Non_Operating_Expenses_Remark__c : '';
                        this.wrapObj3.Salary_to_Partner_Directors_Remark__c = newItem.Salary_to_Partner_Directors_Remark__c ? newItem.Salary_to_Partner_Directors_Remark__c : '';
                        this.wrapObj3.EBITDA_Remark__c = newItem.EBITDA_Remark__c ? newItem.EBITDA_Remark__c : '';
                        this.wrapObj3.Interest_on_Term_Loans_Remark__c = newItem.Interest_on_Term_Loans_Remark__c ? newItem.Interest_on_Term_Loans_Remark__c : '';
                        this.wrapObj3.Interest_on_CC_OD_limits_Remark__c = newItem.Interest_on_CC_OD_limits_Remark__c ? newItem.Interest_on_CC_OD_limits_Remark__c : '';
                        this.wrapObj3.Interest_on_Partner_Capital_Remark__c = newItem.Interest_on_Partner_Capital_Remark__c ? newItem.Interest_on_Partner_Capital_Remark__c : '';
                        this.wrapObj3.Profit_Before_Depreciation_PBDT_Remark__c = newItem.Profit_Before_Depreciation_PBDT_Remark__c ? newItem.Profit_Before_Depreciation_PBDT_Remark__c : '';
                        this.wrapObj3.Depreciation_Remark__c = newItem.Depreciation_Remark__c ? newItem.Depreciation_Remark__c : '';
                        this.wrapObj3.Profit_Before_Tax_Remark__c = newItem.Profit_Before_Tax_Remark__c ? newItem.Profit_Before_Tax_Remark__c : '';
                        this.wrapObj3.Taxes_Remark__c = newItem.Taxes_Remark__c ? newItem.Taxes_Remark__c : '';
                        this.wrapObj3.PAT_Remark__c = newItem.PAT_Remark__c ? newItem.PAT_Remark__c : '';
                        this.wrapObj3.Comments_on_Profit_Loss__c = newItem.Comments_on_Profit_Loss__c ? newItem.Comments_on_Profit_Loss__c : '';

                        this.wrapObj3.Previous_Financial_Year__c = false;
                        this.wrapObj3.Current_Financial_Year__c = false;
                        this.wrapObj3.Provisional_Financial_Year__c = true;

                        calculatePercent = true;
                    }
                })
            }
            if (calculatePercent) {
                this.incrementdecrement1.Total_Sales__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Total_Sales__c, this.wrapObj3.Total_Sales__c);
                this.incrementdecrement1.Other_Operating_Income_IncomeIncidental__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Other_Operating_Income_IncomeIncidental__c, this.wrapObj3.Other_Operating_Income_IncomeIncidental__c);
                this.incrementdecrement1.ExportSalesOutOfAboveSales__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.ExportSalesOutOfAboveSales__c, this.wrapObj3.ExportSalesOutOfAboveSales__c);
                this.incrementdecrement1.Non_Business_Income__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Non_Business_Income__c, this.wrapObj3.Non_Business_Income__c);
                this.incrementdecrement1.Opening_Stock__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Opening_Stock__c, this.wrapObj3.Opening_Stock__c);
                this.incrementdecrement1.Closing_Stock__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Closing_Stock__c, this.wrapObj3.Closing_Stock__c);
                this.incrementdecrement1.Purchases__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Purchases__c, this.wrapObj3.Purchases__c);
                this.incrementdecrement1.Direct_Expenses__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Direct_Expenses__c, this.wrapObj3.Direct_Expenses__c);
                this.incrementdecrement1.Office_Administrative_Expenses__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Office_Administrative_Expenses__c, this.wrapObj3.Office_Administrative_Expenses__c);
                this.incrementdecrement1.Other_Indirect_Expenses__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Other_Indirect_Expenses__c, this.wrapObj3.Other_Indirect_Expenses__c);
                this.incrementdecrement1.Non_Operating_Expenses_FxLoss_AssetLoss__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Non_Operating_Expenses_FxLoss_AssetLoss__c, this.wrapObj3.Non_Operating_Expenses_FxLoss_AssetLoss__c);
                this.incrementdecrement1.Salary_to_Partner_Directors__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Salary_to_Partner_Directors__c, this.wrapObj3.Salary_to_Partner_Directors__c);
                this.incrementdecrement1.Interest_on_Term_Loans__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Interest_on_Term_Loans__c, this.wrapObj3.Interest_on_Term_Loans__c);
                this.incrementdecrement1.Interest_on_CC_OD_limits__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Interest_on_CC_OD_limits__c, this.wrapObj3.Interest_on_CC_OD_limits__c);
                this.incrementdecrement1.Interest_on_Partner_Capital__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Interest_on_Partner_Capital__c, this.wrapObj3.Interest_on_Partner_Capital__c);
                this.incrementdecrement1.Depreciation__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Depreciation__c, this.wrapObj3.Depreciation__c);
                this.incrementdecrement1.Taxes__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Taxes__c, this.wrapObj3.Taxes__c);
                this.incrementdecrement.Total_Sales__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Total_Sales__c, this.wrapObj2.Total_Sales__c);
                this.incrementdecrement.Other_Operating_Income_IncomeIncidental__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Other_Operating_Income_IncomeIncidental__c, this.wrapObj2.Other_Operating_Income_IncomeIncidental__c);

                this.incrementdecrement.Non_Business_Income__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Non_Business_Income__c, this.wrapObj2.Non_Business_Income__c);
                this.incrementdecrement.Opening_Stock__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Opening_Stock__c, this.wrapObj2.Opening_Stock__c);
                this.incrementdecrement.Closing_Stock__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Closing_Stock__c, this.wrapObj2.Closing_Stock__c);
                this.incrementdecrement.Purchases__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Purchases__c, this.wrapObj2.Purchases__c);
                this.incrementdecrement.Direct_Expenses__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Direct_Expenses__c, this.wrapObj2.Direct_Expenses__c);
                this.incrementdecrement.Office_Administrative_Expenses__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Office_Administrative_Expenses__c, this.wrapObj2.Office_Administrative_Expenses__c);
                this.incrementdecrement.Other_Indirect_Expenses__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Other_Indirect_Expenses__c, this.wrapObj2.Other_Indirect_Expenses__c);
                this.incrementdecrement.Non_Operating_Expenses_FxLoss_AssetLoss__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Non_Operating_Expenses_FxLoss_AssetLoss__c, this.wrapObj2.Non_Operating_Expenses_FxLoss_AssetLoss__c);
                this.incrementdecrement.Salary_to_Partner_Directors__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Salary_to_Partner_Directors__c, this.wrapObj2.Salary_to_Partner_Directors__c);
                this.incrementdecrement.Interest_on_Term_Loans__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Interest_on_Term_Loans__c, this.wrapObj2.Interest_on_Term_Loans__c);
                this.incrementdecrement.Interest_on_CC_OD_limits__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Interest_on_CC_OD_limits__c, this.wrapObj2.Interest_on_CC_OD_limits__c);
                this.incrementdecrement.Interest_on_Partner_Capital__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Interest_on_Partner_Capital__c, this.wrapObj2.Interest_on_Partner_Capital__c);
                this.incrementdecrement.Depreciation__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Depreciation__c, this.wrapObj2.Depreciation__c);
                this.incrementdecrement.Taxes__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Taxes__c, this.wrapObj2.Taxes__c);
                this.incrementdecrement.ExportSalesOutOfAboveSales__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.ExportSalesOutOfAboveSales__c, this.wrapObj2.ExportSalesOutOfAboveSales__c);
                
                this.calculateGrossProfit1();
                this.calculateGrossProfit2();
                this.calculateGrossProfit3();
            }
            this.checkDateValueIssue();
        }
    }


    @api handleUpsert() {

        this.showSpinner = true;

        if (this.hasProvisionalId == true && this.provisionalFinancialYearSelectionValue == false) {
            const recordDelId = this.wrapObj3.Id;
            if (recordDelId) {
                deleteRecord(recordDelId)
                .then(() => {
                    this.wrapObj3 = {
                        'Financial_Year__c': this._provisionalYear,
                        'Type_of_Accounts__c': '',
                        'Date_of_Filing_ITR__c': '',
                        'Total_Sales__c': '0',
                        'Other_Operating_Income_IncomeIncidental__c': '0',
                        'ExportSalesOutOfAboveSales__c': '0',
                        'Non_Operating_Income__c': '0',
                        'Non_Business_Income__c': '0',
                        'Opening_Stock__c': '0',
                        'Closing_Stock__c': '0',
                        'Purchases__c': '0',
                        'Direct_Expenses__c': '0',
                        'Gross_Profit__c': '0',
                        'Office_Administrative_Expenses__c': '0',
                        'Other_Indirect_Expenses__c': '0',
                        'Non_Operating_Expenses_FxLoss_AssetLoss__c': '0',
                        'Salary_to_Partner_Directors__c': '0',
                        'EBITDA__c': '0',
                        'Interest_on_Term_Loans__c': '0',
                        'Interest_on_CC_OD_limits__c': '0',
                        'Interest_on_Partner_Capital__c': '0',
                        'Profit_Before_Depreciation_and_Tax_PBDT__c': '0',
                        'Depreciation__c': '0',
                        'Profit_Before_Tax__c': '0',
                        'Taxes__c': '0',
                        'PAT__c': '0',
                        'Director_Partners_remuneration_Interest__c': '0',
                        'Tax_on_Above_Income__c': '0',
                        'Net_Income_Considered_for_Eligibility__c': '0',
                        'Income_addition_u_s_40_a_2_b__c': '0',
                        'Tax_on_the_above_inc_for_Addition__c': '0',
                        'Net_inc_con_for_Eligibility_for_add_Inc__c': '0',
                        'Applicant_Financial__c': this.financialRecordId,
                        'sobjectType': 'Applicant_Financial_Summary__c',
                        'Total_Sales_Remark__c': '',
                        'Other_Operating_Income_Remark__c': '',
                        'ExportSalesOutOfAboveSalesRemark__c': '',
                        'Non_Operating_Income_Remark__c': '',
                        'Non_Business_Income_Remark__c': '',
                        'Opening_Stock_Remark__c': '',
                        'Closing_Stock_Remark__c': '',
                        'Purchases_Remark__c': '',
                        'Direct_Expenses_Remark__c': '',
                        'Gross_Profit_Remark__c': '',
                        'Office_Administrative_Expenses_Remark__c': '',
                        'Other_Indirect_Expenses_Remark__c': '',
                        'Non_Operating_Expenses_Remark__c': '',
                        'Salary_to_Partner_Directors_Remark__c': '',
                        'EBITDA_Remark__c': '',
                        'Interest_on_Term_Loans_Remark__c': '',
                        'Interest_on_CC_OD_limits_Remark__c': '',
                        'Interest_on_Partner_Capital_Remark__c': '',
                        'Profit_Before_Depreciation_PBDT_Remark__c': '',
                        'Depreciation_Remark__c': '',
                        'Profit_Before_Tax_Remark__c': '',
                        'Taxes_Remark__c': '',
                        'PAT_Remark__c': '',
                        'Comments_on_Profit_Loss__c': '',
                        'Previous_Financial_Year__c': false,
                        'Current_Financial_Year__c': false,
                        'Provisional_Financial_Year__c': true

                    }
                });
            }
        }
        let profitlossList = [];
        

        if (this.wrapObj1 && !this.wrapObj1.Applicant_Financial__c) {
            this.wrapObj1.Applicant_Financial__c = this.financialRecordId;
        }
        if (this.wrapObj2 && !this.wrapObj2.Applicant_Financial__c) {
            this.wrapObj2.Applicant_Financial__c = this.financialRecordId;
        }
        if (this.provisionalFinancialYearSelectionValue == true && this.wrapObj3 && !this.wrapObj3.Applicant_Financial__c) {
            this.wrapObj3.Applicant_Financial__c = this.financialRecordId;
        }

        if (this.wrapObj1) {
            this.wrapObj1.Financial_Year__c = this.privousYear;
            this.wrapObj1.sobjectType = 'Applicant_Financial_Summary__c';
        }
        if (this.wrapObj2) {
            this.wrapObj2.Financial_Year__c = this.currentYear;
            this.wrapObj2.sobjectType = 'Applicant_Financial_Summary__c';
        }
        if (this.provisionalFinancialYearSelectionValue == true && this.wrapObj3) {
            this.wrapObj3.Financial_Year__c = this._provisionalYear;
            this.wrapObj3.sobjectType = 'Applicant_Financial_Summary__c';
        }

        profitlossList.push(this.wrapObj1);
        profitlossList.push(this.wrapObj2);
        console.log('this.wrapObj2this.wrapObj2'+JSON.stringify(this.wrapObj2))
        console.log('this.wrapObj1wrapObj1'+JSON.stringify(this.wrapObj1))
        if (this.provisionalFinancialYearSelectionValue == true) {
            profitlossList.push(this.wrapObj3);
        }

        let details = {
            Id: this.financialRecordId,
            sobjectType: 'Applicant_Financial__c'
        };
        let upsertData = {
            parentRecord: details,
            ChildRecords: profitlossList,
            ParentFieldNameToUpdate: 'Applicant_Financial__c'
        }

        upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
        .then(result => {
            this.wrapObj1.Id = result.ChildReords[0].Id;
            this.wrapObj2.Id = result.ChildReords[1].Id;
            if (this.provisionalFinancialYearSelectionValue == true) {
                this.wrapObj3.Id = result.ChildReords[2].Id;
            }
            this.deleteAdditionalRecords(this.privousYear, this.currentYear, this._provisionalOption, this._provisionalYear);
        })
        .catch(error => {
            this.showToastMessage("Error in handleUpsert", error.body.message, "error", "sticky");
            this.showSpinner = false;
        })
    }

    deleteAdditionalRecords(previousYear, currentFinYear, provisonalAvailable, provisionalYear){
        processDefunctRecordsFinancial({ previousFinYear: previousYear, currentFinYear: currentFinYear, provisionalAvailable : provisonalAvailable, provisionalYear : provisionalYear, applicantId: this._applicantId})
        .then(result => {
            this.showToastMessage("Success", this.customLabel.ProfitLoss_Save_SuccessMessage, "success", "sticky");
            this.showSpinner = false;
            this.template.querySelector('c-bre-eligibility-computation').propertyMethod();
            this.template.querySelector('c-bre-eligibility-computation').refreshBREData();
            this.callBREMethod = true;
            this.handleRefreshAllData();
            this.updateAnnualTurnOver();
        }).catch(error => {
            this.showToastMessage("Error in handleUpsert", error.body.message, "error", "sticky");
            this.showSpinner = false;
        })
    }

    @api handleRefreshAllData() {
        if (this.financialRecordId) {
            this.getFinancialSummaryRecord();
        } else {
            refreshApex(this.actualFinancialData);
        }
    }


    fireCustomEvent() {
        console.log('infireCustomEvent')
        const intimateParentChange = new CustomEvent('parentapplicantupdate', {
            detail: 'Data Changed'
        });
        this.dispatchEvent(intimateParentChange);
    }

    updateAnnualTurnOver() {
        let details;

        var latestYearValue;
        if (this._provisionalOption && this._provisionalOption === 'No') {
            latestYearValue = '';
        } else if (this._provisionalOption && this._provisionalOption === 'Yes') {
            latestYearValue = this._provisionalYear;
        } else {
            latestYearValue = '';
        }

        let tempRecs = [];

        var applicantDataSObject = {};
        applicantDataSObject.Id = this._applicantId;
        applicantDataSObject.sobjectType = 'Applicant__c';
        applicantDataSObject.Annual_Turnover__c = this.wrapObj2.Total_Sales__c;
        applicantDataSObject.PAT__c = this.wrapObj2.PAT__c;
        applicantDataSObject.LatestyearforwhichITRisavailable__c = this._currentBlock;
        applicantDataSObject.Provisional_Financials_Available__c = this._provisionalOption ? this._provisionalOption : '';
        applicantDataSObject.Provisional_Financials_Year__c = latestYearValue;
        tempRecs.push(applicantDataSObject);
        console.log('tempRecstempRecs'+JSON.stringify(tempRecs))
        if (tempRecs && tempRecs.length > 0) {
            upsertMultipleRecord({ params: tempRecs })
            .then(result => {
                console.log('updateAnnualTurnOverbeforeevent')
                this.fireCustomEvent();
                console.log('updateAnnualTurnOverAfterevent')
            }).catch(error => {
                this.showToastMessage("Error in updateAnnualTurnOver", error.body.message, "error", "sticky");
            })
        }

    }

    @api validateForm() {
        let returnvariable=true;
        this.template.querySelectorAll('lightning-input').forEach(element => {
        if (element.reportValidity()) {
        } 
        else {
            this.showToastMessage("Error", "Please fill all the required fields", "error", "dismissible");
            returnvariable=false;
        }
        });
        if ((this.currentYearDateIssue && this.currentYearDateIssue === true)) {
            this.showToastMessage("Error", this.customLabel.ProfitLoss_CurrentFyDate_ErrorMessage, "error", "sticky");
            returnvariable=false;
        }
        if ((this.previousYearDateIssue && this.previousYearDateIssue === true)) {
            this.showToastMessage("Error", this.customLabel.ProfitLoss_PreviousFyDate_ErrorMessage, "error", "sticky");
            returnvariable=false;
        }
        return returnvariable;
    }

    handleinputchange(event) {
        if (event.target.dataset.fieldname == 'Total_Sales__1') {
            this.wrapObj1.Total_Sales__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Total_Sales__c, this.wrapObj2.Total_Sales__c);
            this.incrementdecrement.Total_Sales__c = p;
            this.calculateGrossProfit1();
        }
        if (event.target.dataset.fieldname == 'Total_Sales__2') {
            this.wrapObj2.Total_Sales__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Total_Sales__c, this.wrapObj2.Total_Sales__c);
            this.incrementdecrement.Total_Sales__c = p;
            let p1 = this.calculateIncrementDecrementPercentage(this.wrapObj2.Total_Sales__c, this.wrapObj3.Total_Sales__c);
            this.incrementdecrement1.Total_Sales__c = p1;
            this.calculateGrossProfit2();
        }
        if (event.target.dataset.fieldname == 'Date_of_Filing_ITR_Financial_Year_1__1') {
            this.wrapObj1.Date_of_Filing_ITR_Financial_Year_1__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Date_of_Filing_ITR_Financial_Year_1__2') {
            this.wrapObj2.Date_of_Filing_ITR_Financial_Year_1__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Type_of_Accounts__1') {
            this.wrapObj1.Type_of_Accounts__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Type_of_Accounts__2') {
            this.wrapObj2.Type_of_Accounts__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Date_of_Filing_ITR__1') {
            this.wrapObj1.Date_of_Filing_ITR__c = event.target.value;
            this.getITR_Filing_Gap_Days();
            this.checkDateValueIssue();
        }
        if (event.target.dataset.fieldname == 'Date_of_Filing_ITR__2') {
            this.wrapObj2.Date_of_Filing_ITR__c = event.target.value;
            this.getITR_Filing_Gap_Days();
            this.checkDateValueIssue();
        }
        if (event.target.dataset.fieldname == 'Other_Operating_Income_IncomeIncidental__1') {
            this.wrapObj1.Other_Operating_Income_IncomeIncidental__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Other_Operating_Income_IncomeIncidental__c, this.wrapObj2.Other_Operating_Income_IncomeIncidental__c);
            this.incrementdecrement.Other_Operating_Income_IncomeIncidental__c = p;
            this.calculateGrossProfit1();
        }
        if (event.target.dataset.fieldname == 'Other_Operating_Income_IncomeIncidental__2') {
            this.wrapObj2.Other_Operating_Income_IncomeIncidental__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Other_Operating_Income_IncomeIncidental__c, this.wrapObj2.Other_Operating_Income_IncomeIncidental__c);
            this.incrementdecrement.Other_Operating_Income_IncomeIncidental__c = p;
            let p1 = this.calculateIncrementDecrementPercentage(this.wrapObj2.Other_Operating_Income_IncomeIncidental__c, this.wrapObj3.Other_Operating_Income_IncomeIncidental__c);
            this.incrementdecrement1.Other_Operating_Income_IncomeIncidental__c = p1;
            this.calculateGrossProfit2();
        }
        // add Export Sales (out of Total Sales) in table
        if (event.target.dataset.fieldname == 'ExportSalesOutOfAboveSales__1') {
            this.wrapObj1.ExportSalesOutOfAboveSales__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.ExportSalesOutOfAboveSales__c, this.wrapObj2.ExportSalesOutOfAboveSales__c);
            this.incrementdecrement.ExportSalesOutOfAboveSales__c = p;
            //this.calculateGrossProfit1();
        }
        if (event.target.dataset.fieldname == 'ExportSalesOutOfAboveSales__2') {
            this.wrapObj2.ExportSalesOutOfAboveSales__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.ExportSalesOutOfAboveSales__c, this.wrapObj2.ExportSalesOutOfAboveSales__c);
            this.incrementdecrement.ExportSalesOutOfAboveSales__c = p;
            let p1 = this.calculateIncrementDecrementPercentage(this.wrapObj2.ExportSalesOutOfAboveSales__c, this.wrapObj3.ExportSalesOutOfAboveSales__c);
            this.incrementdecrement1.ExportSalesOutOfAboveSales__c = p1;
           // this.calculateGrossProfit2();
        }
        if (event.target.dataset.fieldname == 'ExportSalesOutOfAboveSales__3') {
            this.wrapObj3.ExportSalesOutOfAboveSales__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.ExportSalesOutOfAboveSales__c, this.wrapObj3.ExportSalesOutOfAboveSales__c);
            this.incrementdecrement1.ExportSalesOutOfAboveSales__c = p;
            this.calculateGrossProfit3();
        }

        //end

        if (event.target.dataset.fieldname == 'Non_Operating_Income__1') {
            this.wrapObj1.Non_Operating_Income__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Non_Operating_Income__2') {
            this.wrapObj2.Non_Operating_Income__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Non_Business_Income__1') {
            this.wrapObj1.Non_Business_Income__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Non_Business_Income__c, this.wrapObj2.Non_Business_Income__c);
            this.incrementdecrement.Non_Business_Income__c = p;
            this.calculateProfitBeforeDeprecition1();
        }
        if (event.target.dataset.fieldname == 'Non_Business_Income__2') {
            this.wrapObj2.Non_Business_Income__c =  (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Non_Business_Income__c, this.wrapObj2.Non_Business_Income__c);
            this.incrementdecrement.Non_Business_Income__c = p;
            let p1 = this.calculateIncrementDecrementPercentage(this.wrapObj2.Non_Business_Income__c, this.wrapObj3.Non_Business_Income__c);
            this.incrementdecrement1.Non_Business_Income__c = p1;
            this.calculateProfitBeforeDeprecition2();
        }
        if (event.target.dataset.fieldname == 'Opening_Stock__1') {
            this.wrapObj1.Opening_Stock__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Opening_Stock__c, this.wrapObj2.Opening_Stock__c);
            this.incrementdecrement.Opening_Stock__c = p;
            this.calculateGrossProfit1();
        }
        if (event.target.dataset.fieldname == 'Opening_Stock__2') {
            this.wrapObj2.Opening_Stock__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Opening_Stock__c, this.wrapObj2.Opening_Stock__c);
            this.incrementdecrement.Opening_Stock__c = p;
            let p1 = this.calculateIncrementDecrementPercentage(this.wrapObj2.Opening_Stock__c, this.wrapObj3.Opening_Stock__c);
            this.incrementdecrement1.Opening_Stock__c = p1;
            this.calculateGrossProfit2();
        }
        if (event.target.dataset.fieldname == 'Closing_Stock__1') {
            this.wrapObj1.Closing_Stock__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Closing_Stock__c, this.wrapObj2.Closing_Stock__c);
            this.incrementdecrement.Closing_Stock__c = p;
            this.calculateGrossProfit1();
        }
        if (event.target.dataset.fieldname == 'Closing_Stock__2') {
            this.wrapObj2.Closing_Stock__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Closing_Stock__c, this.wrapObj2.Closing_Stock__c);
            this.incrementdecrement.Closing_Stock__c = p;
            let p1 = this.calculateIncrementDecrementPercentage(this.wrapObj2.Closing_Stock__c, this.wrapObj3.Closing_Stock__c);
            this.incrementdecrement1.Closing_Stock__c = p1;
            this.calculateGrossProfit2();
        }
        if (event.target.dataset.fieldname == 'Purchases__1') {
            this.wrapObj1.Purchases__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Purchases__c, this.wrapObj2.Purchases__c);
            this.incrementdecrement.Purchases__c = p;
            this.calculateGrossProfit1();
        }
        if (event.target.dataset.fieldname == 'Purchases__2') {
            this.wrapObj2.Purchases__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Purchases__c, this.wrapObj2.Purchases__c);
            this.incrementdecrement.Purchases__c = p;
            let p1 = this.calculateIncrementDecrementPercentage(this.wrapObj2.Purchases__c, this.wrapObj3.Purchases__c);
            this.incrementdecrement1.Purchases__c = p1;
            this.calculateGrossProfit2();
        }
        if (event.target.dataset.fieldname == 'Direct_Expenses__1') {
            this.wrapObj1.Direct_Expenses__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Direct_Expenses__c, this.wrapObj2.Direct_Expenses__c);
            this.incrementdecrement.Direct_Expenses__c = p;
            this.calculateGrossProfit1();
        }
        if (event.target.dataset.fieldname == 'Direct_Expenses__2') {
            this.wrapObj2.Direct_Expenses__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Direct_Expenses__c, this.wrapObj2.Direct_Expenses__c);
            this.incrementdecrement.Direct_Expenses__c = p;
            let p1 = this.calculateIncrementDecrementPercentage(this.wrapObj2.Direct_Expenses__c, this.wrapObj3.Direct_Expenses__c);
            this.incrementdecrement1.Direct_Expenses__c = p1;
            this.calculateGrossProfit2();
        }
        if (event.target.dataset.fieldname == 'Gross_Profit__1') {
            this.wrapObj1.Gross_Profit__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Gross_Profit__2') {
            this.wrapObj2.Gross_Profit__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Office_Administrative_Expenses__1') {
            this.wrapObj1.Office_Administrative_Expenses__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Office_Administrative_Expenses__c, this.wrapObj2.Office_Administrative_Expenses__c);
            this.incrementdecrement.Office_Administrative_Expenses__c = p;
            this.calculatEBITDA1();
        }
        if (event.target.dataset.fieldname == 'Office_Administrative_Expenses__2') {
            this.wrapObj2.Office_Administrative_Expenses__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Office_Administrative_Expenses__c, this.wrapObj2.Office_Administrative_Expenses__c);
            this.incrementdecrement.Office_Administrative_Expenses__c = p;
            let p1 = this.calculateIncrementDecrementPercentage(this.wrapObj2.Office_Administrative_Expenses__c, this.wrapObj3.Office_Administrative_Expenses__c);
            this.incrementdecrement1.Office_Administrative_Expenses__c = p1;
            this.calculatEBITDA2();
        }
        if (event.target.dataset.fieldname == 'Other_Indirect_Expenses__1') {
            this.wrapObj1.Other_Indirect_Expenses__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Other_Indirect_Expenses__c, this.wrapObj2.Other_Indirect_Expenses__c);
            this.incrementdecrement.Other_Indirect_Expenses__c = p;
            this.calculatEBITDA1();
        }
        if (event.target.dataset.fieldname == 'Other_Indirect_Expenses__2') {
            this.wrapObj2.Other_Indirect_Expenses__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Other_Indirect_Expenses__c, this.wrapObj2.Other_Indirect_Expenses__c);
            this.incrementdecrement.Other_Indirect_Expenses__c = p;
            let p1 = this.calculateIncrementDecrementPercentage(this.wrapObj2.Other_Indirect_Expenses__c, this.wrapObj3.Other_Indirect_Expenses__c);
            this.incrementdecrement1.Other_Indirect_Expenses__c = p1;
            this.calculatEBITDA2();
        }
        if (event.target.dataset.fieldname == 'Non_Operating_Expenses_FxLoss_AssetLoss__1') {
            this.wrapObj1.Non_Operating_Expenses_FxLoss_AssetLoss__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Non_Operating_Expenses_FxLoss_AssetLoss__c, this.wrapObj2.Non_Operating_Expenses_FxLoss_AssetLoss__c);
            this.incrementdecrement.Non_Operating_Expenses_FxLoss_AssetLoss__c = p;
            this.calculateProfitBeforeDeprecition1();
        }
        if (event.target.dataset.fieldname == 'Non_Operating_Expenses_FxLoss_AssetLoss__2') {
            this.wrapObj2.Non_Operating_Expenses_FxLoss_AssetLoss__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Non_Operating_Expenses_FxLoss_AssetLoss__c, this.wrapObj2.Non_Operating_Expenses_FxLoss_AssetLoss__c);
            this.incrementdecrement.Non_Operating_Expenses_FxLoss_AssetLoss__c = p;
            let p1 = this.calculateIncrementDecrementPercentage(this.wrapObj2.Non_Operating_Expenses_FxLoss_AssetLoss__c, this.wrapObj3.Non_Operating_Expenses_FxLoss_AssetLoss__c);
            this.incrementdecrement1.Non_Operating_Expenses_FxLoss_AssetLoss__c = p1;
            this.calculateProfitBeforeDeprecition2();
        }
        if (event.target.dataset.fieldname == 'Salary_to_Partner_Directors__1') {
            this.wrapObj1.Salary_to_Partner_Directors__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Salary_to_Partner_Directors__c, this.wrapObj2.Salary_to_Partner_Directors__c);
            this.incrementdecrement.Salary_to_Partner_Directors__c = p;
            this.calculatEBITDA1();
        }
        if (event.target.dataset.fieldname == 'Salary_to_Partner_Directors__2') {
            this.wrapObj2.Salary_to_Partner_Directors__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Salary_to_Partner_Directors__c, this.wrapObj2.Salary_to_Partner_Directors__c);
            this.incrementdecrement.Salary_to_Partner_Directors__c = p;
            let p1 = this.calculateIncrementDecrementPercentage(this.wrapObj2.Salary_to_Partner_Directors__c, this.wrapObj3.Salary_to_Partner_Directors__c);
            this.incrementdecrement1.Salary_to_Partner_Directors__c = p1;
            this.calculatEBITDA2();
        }
        if (event.target.dataset.fieldname == 'EBITDA__c') {
            this.wrapObj1.EBITDA__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'EBITDA__c') {
            this.wrapObj2.EBITDA__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Interest_on_Term_Loans__1') {
            this.wrapObj1.Interest_on_Term_Loans__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Interest_on_Term_Loans__c, this.wrapObj2.Interest_on_Term_Loans__c);
            this.incrementdecrement.Interest_on_Term_Loans__c = p;
            this.calculateProfitBeforeDeprecition1();
        }
        if (event.target.dataset.fieldname == 'Interest_on_Term_Loans__2') {
            this.wrapObj2.Interest_on_Term_Loans__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Interest_on_Term_Loans__c, this.wrapObj2.Interest_on_Term_Loans__c);
            this.incrementdecrement.Interest_on_Term_Loans__c = p;
            let p1 = this.calculateIncrementDecrementPercentage(this.wrapObj2.Interest_on_Term_Loans__c, this.wrapObj3.Interest_on_Term_Loans__c);
            this.incrementdecrement1.Interest_on_Term_Loans__c = p1;
            this.calculateProfitBeforeDeprecition2();
        }
        if (event.target.dataset.fieldname == 'Interest_on_CC_OD_limits__1') {
            this.wrapObj1.Interest_on_CC_OD_limits__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Interest_on_CC_OD_limits__c, this.wrapObj2.Interest_on_CC_OD_limits__c);
            this.incrementdecrement.Interest_on_CC_OD_limits__c = p;
            this.calculateProfitBeforeDeprecition1();
        }
        if (event.target.dataset.fieldname == 'Interest_on_CC_OD_limits__2') {
            this.wrapObj2.Interest_on_CC_OD_limits__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Interest_on_CC_OD_limits__c, this.wrapObj2.Interest_on_CC_OD_limits__c);
            this.incrementdecrement.Interest_on_CC_OD_limits__c = p;
            let p1 = this.calculateIncrementDecrementPercentage(this.wrapObj2.Interest_on_CC_OD_limits__c, this.wrapObj3.Interest_on_CC_OD_limits__c);
            this.incrementdecrement1.Interest_on_CC_OD_limits__c = p1;
            this.calculateProfitBeforeDeprecition2();
        }
        if (event.target.dataset.fieldname == 'Interest_on_Partner_Capital__1') {
            this.wrapObj1.Interest_on_Partner_Capital__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Interest_on_Partner_Capital__c, this.wrapObj2.Interest_on_Partner_Capital__c);
            this.incrementdecrement.Interest_on_Partner_Capital__c = p;
            this.calculateProfitBeforeDeprecition1();
        }
        if (event.target.dataset.fieldname == 'Interest_on_Partner_Capital__2') {
            this.wrapObj2.Interest_on_Partner_Capital__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Interest_on_Partner_Capital__c, this.wrapObj2.Interest_on_Partner_Capital__c);
            this.incrementdecrement.Interest_on_Partner_Capital__c = p;
            let p1 = this.calculateIncrementDecrementPercentage(this.wrapObj2.Interest_on_Partner_Capital__c, this.wrapObj3.Interest_on_Partner_Capital__c);
            this.incrementdecrement1.Interest_on_Partner_Capital__c = p1;
            this.calculateProfitBeforeDeprecition2();
        }
        if (event.target.dataset.fieldname == 'Profit_Before_Depreciation_and_Tax_PBDT__1') {
            this.wrapObj1.Profit_Before_Depreciation_and_Tax_PBDT__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Profit_Before_Depreciation_and_Tax_PBDT__2') {
            this.wrapObj2.Profit_Before_Depreciation_and_Tax_PBDT__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Depreciation__1') {
            this.wrapObj1.Depreciation__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Depreciation__c, this.wrapObj2.Depreciation__c);
            this.incrementdecrement.Depreciation__c = p;
            this.calculatePBT1();
        }
        if (event.target.dataset.fieldname == 'Depreciation__2') {
            this.wrapObj2.Depreciation__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Depreciation__c, this.wrapObj2.Depreciation__c);
            this.incrementdecrement.Depreciation__c = p;
            let p1 = this.calculateIncrementDecrementPercentage(this.wrapObj2.Depreciation__c, this.wrapObj3.Depreciation__c);
            this.incrementdecrement1.Depreciation__c = p1;
            this.calculatePBT2();
        }
        if (event.target.dataset.fieldname == 'Profit_Before_Tax__1') {
            this.wrapObj1.Profit_Before_Tax__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Profit_Before_Tax__2') {
            this.wrapObj2.Profit_Before_Tax__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Taxes__1') {
            this.wrapObj1.Taxes__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Taxes__c, this.wrapObj2.Taxes__c);
            this.incrementdecrement.Taxes__c = p;
            this.calculatePAT1();
        }
        if (event.target.dataset.fieldname == 'Taxes__2') {
            this.wrapObj2.Taxes__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Taxes__c, this.wrapObj2.Taxes__c);
            this.incrementdecrement.Taxes__c = p;
            let p1 = this.calculateIncrementDecrementPercentage(this.wrapObj2.Taxes__c, this.wrapObj3.Taxes__c);
            this.incrementdecrement1.Taxes__c = p1;
            this.calculatePAT2();
        }
        if (event.target.dataset.fieldname == 'PAT__1') {
            this.wrapObj1.PAT__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'PAT__2') {
            this.wrapObj2.PAT__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Director_Partners_remuneration_Interest__1') {
            this.wrapObj1.Director_Partners_remuneration_Interest__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            this.calculateNetEligibility1();
        }
        if (event.target.dataset.fieldname == 'Director_Partners_remuneration_Interest__2') {
            this.wrapObj2.Director_Partners_remuneration_Interest__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            this.calculateNetEligibility2();
        }
        if (event.target.dataset.fieldname == 'Tax_on_Above_Income__1') {
            this.wrapObj1.Tax_on_Above_Income__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            this.calculateNetEligibility1();
        }
        if (event.target.dataset.fieldname == 'Tax_on_Above_Income__2') {
            this.wrapObj2.Tax_on_Above_Income__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            this.calculateNetEligibility2();
        }
        if (event.target.dataset.fieldname == 'Net_Income_Considered_for_Eligibility__1') {
            this.wrapObj1.Net_Income_Considered_for_Eligibility__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Net_Income_Considered_for_Eligibility__2') {
            this.wrapObj2.Net_Income_Considered_for_Eligibility__c = event.target.value;
        }
        //to calculate and cature value for Income addition u/s 40(a)(2)(b)
        if (event.target.dataset.fieldname == 'Income_addition_u_s_40_a_2_b__1') {
            this.wrapObj1.Income_addition_u_s_40_a_2_b__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            this.calculateNetIncomeAddition1();
        }
        if (event.target.dataset.fieldname == 'Income_addition_u_s_40_a_2_b__2') {
            this.wrapObj2.Income_addition_u_s_40_a_2_b__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            this.calculateNetIncomeAddition2();
        }
        if (event.target.dataset.fieldname == 'Tax_on_the_above_inc_for_Addition__1') {
            this.wrapObj1.Tax_on_the_above_inc_for_Addition__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            this.calculateNetIncomeAddition1();
        }
        if (event.target.dataset.fieldname == 'Tax_on_the_above_inc_for_Addition__2') {
            this.wrapObj2.Tax_on_the_above_inc_for_Addition__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            this.calculateNetIncomeAddition2();
        }
        if (event.target.dataset.fieldname == 'Net_inc_con_for_Eligibility_for_add_Inc__1') {
            this.wrapObj1.Net_inc_con_for_Eligibility_for_add_Inc__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Net_inc_con_for_Eligibility_for_add_Inc__2') {
            this.wrapObj2.Net_inc_con_for_Eligibility_for_add_Inc__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Income_addition_u_s_40_a_2_b__3') {
            this.wrapObj3.Income_addition_u_s_40_a_2_b__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            this.calculateNetIncomeAddition3();
        }
        if (event.target.dataset.fieldname == 'Tax_on_the_above_inc_for_Addition__3') {
            this.wrapObj3.Tax_on_the_above_inc_for_Addition__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            this.calculateNetIncomeAddition3();
        }
        if (event.target.dataset.fieldname == 'Net_inc_con_for_Eligibility_for_add_Inc__3') {
            this.wrapObj3.Net_inc_con_for_Eligibility_for_add_Inc__c = event.target.value;

        }


        //end here



        if (event.target.dataset.fieldname == 'Total_Sales__3') {
            this.wrapObj3.Total_Sales__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Total_Sales__c, this.wrapObj3.Total_Sales__c);
            this.incrementdecrement1.Total_Sales__c = p;
            this.calculateGrossProfit3();
        }
        if (event.target.dataset.fieldname == 'Type_of_Accounts__3') {
            this.wrapObj3.Type_of_Accounts__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Date_of_Filing_ITR__3') {
            this.wrapObj3.Date_of_Filing_ITR__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Other_Operating_Income_IncomeIncidental__3') {
            this.wrapObj3.Other_Operating_Income_IncomeIncidental__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Other_Operating_Income_IncomeIncidental__c, this.wrapObj3.Other_Operating_Income_IncomeIncidental__c);
            this.incrementdecrement1.Other_Operating_Income_IncomeIncidental__c = p;
            this.calculateGrossProfit3();
        }
        if (event.target.dataset.fieldname == 'Non_Operating_Income__3') {
            this.wrapObj3.Non_Operating_Income__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Non_Business_Income__3') {
            this.wrapObj3.Non_Business_Income__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Non_Business_Income__c, this.wrapObj3.Non_Business_Income__c);
            this.incrementdecrement1.Non_Business_Income__c = p;
            this.calculateProfitBeforeDeprecition3();
        }
        if (event.target.dataset.fieldname == 'Opening_Stock__3') {
            this.wrapObj3.Opening_Stock__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Opening_Stock__c, this.wrapObj3.Opening_Stock__c);
            this.incrementdecrement1.Opening_Stock__c = p;
            this.calculateGrossProfit3();
        }
        if (event.target.dataset.fieldname == 'Closing_Stock__3') {
            this.wrapObj3.Closing_Stock__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Closing_Stock__c, this.wrapObj3.Closing_Stock__c);
            this.incrementdecrement1.Closing_Stock__c = p;
            this.calculateGrossProfit3();
        }
        if (event.target.dataset.fieldname == 'Purchases__3') {
            this.wrapObj3.Purchases__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Purchases__c, this.wrapObj3.Purchases__c);
            this.incrementdecrement1.Purchases__c = p;
            this.calculateGrossProfit3();
        }
        if (event.target.dataset.fieldname == 'Direct_Expenses__3') {
            this.wrapObj3.Direct_Expenses__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Direct_Expenses__c, this.wrapObj3.Direct_Expenses__c);
            this.incrementdecrement1.Direct_Expenses__c = p;
            this.calculateGrossProfit3();
        }
        if (event.target.dataset.fieldname == 'Gross_Profit__3') {
            this.wrapObj3.Gross_Profit__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Office_Administrative_Expenses__3') {
            this.wrapObj3.Office_Administrative_Expenses__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Office_Administrative_Expenses__c, this.wrapObj3.Office_Administrative_Expenses__c);
            this.incrementdecrement1.Office_Administrative_Expenses__c = p;
            this.calculatEBITDA3();
        }
        if (event.target.dataset.fieldname == 'Other_Indirect_Expenses__3') {
            this.wrapObj3.Other_Indirect_Expenses__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Other_Indirect_Expenses__c, this.wrapObj3.Other_Indirect_Expenses__c);
            this.incrementdecrement1.Other_Indirect_Expenses__c = p;
            this.calculatEBITDA3();
        }
        if (event.target.dataset.fieldname == 'Non_Operating_Expenses_FxLoss_AssetLoss__3') {
            this.wrapObj3.Non_Operating_Expenses_FxLoss_AssetLoss__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Non_Operating_Expenses_FxLoss_AssetLoss__c, this.wrapObj3.Non_Operating_Expenses_FxLoss_AssetLoss__c);
            this.incrementdecrement1.Non_Operating_Expenses_FxLoss_AssetLoss__c = p;
            this.calculateProfitBeforeDeprecition3();
        }
        if (event.target.dataset.fieldname == 'Salary_to_Partner_Directors__3') {
            this.wrapObj3.Salary_to_Partner_Directors__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Salary_to_Partner_Directors__c, this.wrapObj3.Salary_to_Partner_Directors__c);
            this.incrementdecrement1.Salary_to_Partner_Directors__c = p;
            this.calculatEBITDA3();
        }
        if (event.target.dataset.fieldname == 'EBITDA__3') {
            this.wrapObj3.EBITDA__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Interest_on_Term_Loans__3') {
            this.wrapObj3.Interest_on_Term_Loans__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Interest_on_Term_Loans__c, this.wrapObj3.Interest_on_Term_Loans__c);
            this.incrementdecrement1.Interest_on_Term_Loans__c = p;
            this.calculateProfitBeforeDeprecition3();
        }
        if (event.target.dataset.fieldname == 'Interest_on_CC_OD_limits__3') {
            this.wrapObj3.Interest_on_CC_OD_limits__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Interest_on_CC_OD_limits__c, this.wrapObj3.Interest_on_CC_OD_limits__c);
            this.incrementdecrement1.Interest_on_CC_OD_limits__c = p;
            this.calculateProfitBeforeDeprecition3();
        }
        if (event.target.dataset.fieldname == 'Interest_on_Partner_Capital__3') {
            this.wrapObj3.Interest_on_Partner_Capital__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Interest_on_Partner_Capital__c, this.wrapObj3.Interest_on_Partner_Capital__c);
            this.incrementdecrement1.Interest_on_Partner_Capital__c = p;
            this.calculateProfitBeforeDeprecition3();
        }
        if (event.target.dataset.fieldname == 'Profit_Before_Depreciation_and_Tax_PBDT__3') {
            this.wrapObj3.Profit_Before_Depreciation_and_Tax_PBDT__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Depreciation__3') {
            this.wrapObj3.Depreciation__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Depreciation__c, this.wrapObj3.Depreciation__c);
            this.incrementdecrement1.Depreciation__c = p;
            this.calculatePBT3();
        }
        if (event.target.dataset.fieldname == 'Profit_Before_Tax__3') {
            this.wrapObj3.Profit_Before_Tax__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Taxes__3') {
            this.wrapObj3.Taxes__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Taxes__c, this.wrapObj3.Taxes__c);
            this.incrementdecrement1.Taxes__c = p;
            this.calculatePAT3();
        }
        if (event.target.dataset.fieldname == 'PAT__3') {
            this.wrapObj3.PAT__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Director_Partners_remuneration_Interest__3') {
            this.wrapObj3.Director_Partners_remuneration_Interest__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            this.calculateNetEligibility3();
        }
        if (event.target.dataset.fieldname == 'Tax_on_Above_Income__3') {
            this.wrapObj3.Tax_on_Above_Income__c = (event.target.value && event.target.value > 0) ? event.target.value : '0';
            this.calculateNetEligibility3();
        }
        if (event.target.dataset.fieldname == 'Net_Income_Considered_for_Eligibility__3') {
            this.wrapObj3.Net_Income_Considered_for_Eligibility__c = event.target.value;

        }
        if (event.target.dataset.fieldname == 'Total_Sales_Remark__c') {
            this.wrapObj2.Total_Sales_Remark__c = event.target.value;
            this.wrapObj1.Total_Sales_Remark__c = event.target.value;
            this.wrapObj3.Total_Sales_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Other_Operating_Income_Remark__c') {
            this.wrapObj2.Other_Operating_Income_Remark__c = event.target.value;
            this.wrapObj1.Other_Operating_Income_Remark__c = event.target.value;
            this.wrapObj3.Other_Operating_Income_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'ExportSalesOutOfAboveSalesRemark__c') {
            this.wrapObj2.ExportSalesOutOfAboveSalesRemark__c = event.target.value;
            this.wrapObj1.ExportSalesOutOfAboveSalesRemark__c = event.target.value;
            this.wrapObj3.ExportSalesOutOfAboveSalesRemark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Non_Operating_Income_Remark__c') {
            this.wrapObj2.Non_Operating_Income_Remark__c = event.target.value;
            this.wrapObj1.Non_Operating_Income_Remark__c = event.target.value;
            this.wrapObj3.Non_Operating_Income_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Non_Business_Income_Remark__c') {
            this.wrapObj2.Non_Business_Income_Remark__c = event.target.value;
            this.wrapObj1.Non_Business_Income_Remark__c = event.target.value;
            this.wrapObj3.Non_Business_Income_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Opening_Stock_Remark__c') {
            this.wrapObj2.Opening_Stock_Remark__c = event.target.value;
            this.wrapObj1.Opening_Stock_Remark__c = event.target.value;
            this.wrapObj3.Opening_Stock_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Closing_Stock_Remark__c') {
            this.wrapObj2.Closing_Stock_Remark__c = event.target.value;
            this.wrapObj1.Closing_Stock_Remark__c = event.target.value;
            this.wrapObj3.Closing_Stock_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Purchases_Remark__c') {
            this.wrapObj2.Purchases_Remark__c = event.target.value;
            this.wrapObj1.Purchases_Remark__c = event.target.value;
            this.wrapObj3.Purchases_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Direct_Expenses_Remark__c') {
            this.wrapObj2.Direct_Expenses_Remark__c = event.target.value;
            this.wrapObj1.Direct_Expenses_Remark__c = event.target.value;
            this.wrapObj3.Direct_Expenses_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Gross_Profit_Remark__c') {
            this.wrapObj2.Gross_Profit_Remark__c = event.target.value;
            this.wrapObj1.Gross_Profit_Remark__c = event.target.value;
            this.wrapObj3.Gross_Profit_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Office_Administrative_Expenses_Remark__c') {
            this.wrapObj2.Office_Administrative_Expenses_Remark__c = event.target.value;
            this.wrapObj1.Office_Administrative_Expenses_Remark__c = event.target.value;
            this.wrapObj3.Office_Administrative_Expenses_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Other_Indirect_Expenses_Remark__c') {
            this.wrapObj2.Other_Indirect_Expenses_Remark__c = event.target.value;
            this.wrapObj1.Other_Indirect_Expenses_Remark__c = event.target.value;
            this.wrapObj3.Other_Indirect_Expenses_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Non_Operating_Expenses_Remark__c') {
            this.wrapObj2.Non_Operating_Expenses_Remark__c = event.target.value;
            this.wrapObj1.Non_Operating_Expenses_Remark__c = event.target.value;
            this.wrapObj3.Non_Operating_Expenses_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Salary_to_Partner_Directors_Remark__c') {
            this.wrapObj2.Salary_to_Partner_Directors_Remark__c = event.target.value;
            this.wrapObj1.Salary_to_Partner_Directors_Remark__c = event.target.value;
            this.wrapObj3.Salary_to_Partner_Directors_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'EBITDA_Remark__c') {
            this.wrapObj2.EBITDA_Remark__c = event.target.value;
            this.wrapObj1.EBITDA_Remark__c = event.target.value;
            this.wrapObj3.EBITDA_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Interest_on_Term_Loans_Remark__c') {
            this.wrapObj2.Interest_on_Term_Loans_Remark__c = event.target.value;
            this.wrapObj1.Interest_on_Term_Loans_Remark__c = event.target.value;
            this.wrapObj3.Interest_on_Term_Loans_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Interest_on_CC_OD_limits_Remark__c') {
            this.wrapObj2.Interest_on_CC_OD_limits_Remark__c = event.target.value;
            this.wrapObj1.Interest_on_CC_OD_limits_Remark__c = event.target.value;
            this.wrapObj3.Interest_on_CC_OD_limits_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Interest_on_Partner_Capital_Remark__c') {
            this.wrapObj2.Interest_on_Partner_Capital_Remark__c = event.target.value;
            this.wrapObj1.Interest_on_Partner_Capital_Remark__c = event.target.value;
            this.wrapObj3.Interest_on_Partner_Capital_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Profit_Before_Depreciation_PBDT_Remark__c') {
            this.wrapObj2.Profit_Before_Depreciation_PBDT_Remark__c = event.target.value;
            this.wrapObj1.Profit_Before_Depreciation_PBDT_Remark__c = event.target.value;
            this.wrapObj3.Profit_Before_Depreciation_PBDT_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Depreciation_Remark__c') {
            this.wrapObj2.Depreciation_Remark__c = event.target.value;
            this.wrapObj1.Depreciation_Remark__c = event.target.value;
            this.wrapObj3.Depreciation_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Profit_Before_Tax_Remark__c') {
            this.wrapObj2.Profit_Before_Tax_Remark__c = event.target.value;
            this.wrapObj1.Profit_Before_Tax_Remark__c = event.target.value;
            this.wrapObj3.Profit_Before_Tax_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Taxes_Remark__c') {
            this.wrapObj2.Taxes_Remark__c = event.target.value;
            this.wrapObj1.Taxes_Remark__c = event.target.value;
            this.wrapObj3.Taxes_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'PAT_Remark__c') {
            this.wrapObj2.PAT_Remark__c = event.target.value;
            this.wrapObj1.PAT_Remark__c = event.target.value;
            this.wrapObj3.PAT_Remark__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Comments_on_Profit_Loss__c') {
            this.wrapObj2.Comments_on_Profit_Loss__c = event.target.value;
            this.wrapObj1.Comments_on_Profit_Loss__c = event.target.value;
            this.wrapObj3.Comments_on_Profit_Loss__c = event.target.value;
        }
    }
    calculateGrossProfit1() {
        let grossTotal = 0;
        grossTotal = parseFloat(this.wrapObj1.Total_Sales__c) + parseFloat(this.wrapObj1.Other_Operating_Income_IncomeIncidental__c) - (parseFloat(this.wrapObj1.Opening_Stock__c) + parseFloat(this.wrapObj1.Purchases__c) + parseFloat(this.wrapObj1.Direct_Expenses__c) - parseFloat(this.wrapObj1.Closing_Stock__c));
        this.wrapObj1.Gross_Profit__c = grossTotal.toFixed(2);
        let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Gross_Profit__c, this.wrapObj2.Gross_Profit__c);
        this.incrementdecrement.Gross_Profit__c = p;
        this.calculatEBITDA1();
        this.getITR_Filing_Gap_Days();

    }
    calculateGrossProfit2() {
        let grossTotal = 0;
        grossTotal = parseFloat(this.wrapObj2.Total_Sales__c) + parseFloat(this.wrapObj2.Other_Operating_Income_IncomeIncidental__c) - (parseFloat(this.wrapObj2.Opening_Stock__c) + parseFloat(this.wrapObj2.Purchases__c) + parseFloat(this.wrapObj2.Direct_Expenses__c) - parseFloat(this.wrapObj2.Closing_Stock__c));
        this.wrapObj2.Gross_Profit__c = grossTotal.toFixed(2);
        let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Gross_Profit__c, this.wrapObj2.Gross_Profit__c);
        this.incrementdecrement.Gross_Profit__c = p;
        this.calculatEBITDA2();
        this.getITR_Filing_Gap_Days();
        this.calculateGrossProfit3();
    }
    calculateGrossProfit3() {
        let grossTotal = 0;
        grossTotal = parseFloat(this.wrapObj3.Total_Sales__c) + parseFloat(this.wrapObj3.Other_Operating_Income_IncomeIncidental__c) - (parseFloat(this.wrapObj3.Opening_Stock__c) + parseFloat(this.wrapObj3.Purchases__c) + parseFloat(this.wrapObj3.Direct_Expenses__c) - parseFloat(this.wrapObj3.Closing_Stock__c));
        this.wrapObj3.Gross_Profit__c = grossTotal.toFixed(2);
        let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Gross_Profit__c, this.wrapObj3.Gross_Profit__c);
        this.incrementdecrement1.Gross_Profit__c = p;
        this.getITR_Filing_Gap_Days();

        this.calculatEBITDA3();
    }
    calculatEBITDA1() {
        let ebitda = 0;
        ebitda = parseFloat(this.wrapObj1.Gross_Profit__c) - parseFloat(this.wrapObj1.Office_Administrative_Expenses__c) - parseFloat(this.wrapObj1.Other_Indirect_Expenses__c) - parseFloat(this.wrapObj1.Salary_to_Partner_Directors__c);
        this.wrapObj1.EBITDA__c = ebitda.toFixed(2);
        let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.EBITDA__c, this.wrapObj2.EBITDA__c);
        this.incrementdecrement.EBITDA__c = p;
        this.calculateProfitBeforeDeprecition1();
    }
    calculatEBITDA2() {
        let ebitda = 0;
        ebitda = parseFloat(this.wrapObj2.Gross_Profit__c) - parseFloat(this.wrapObj2.Office_Administrative_Expenses__c) - parseFloat(this.wrapObj2.Other_Indirect_Expenses__c) - parseFloat(this.wrapObj2.Salary_to_Partner_Directors__c);
        this.wrapObj2.EBITDA__c = ebitda.toFixed(2);
        let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.EBITDA__c, this.wrapObj2.EBITDA__c);
        this.incrementdecrement.EBITDA__c = p;
        this.calculateProfitBeforeDeprecition2();
        this.calculatEBITDA3();
    }
    calculatEBITDA3() {
        let ebitda = 0;
        ebitda = parseFloat(this.wrapObj3.Gross_Profit__c) - parseFloat(this.wrapObj3.Office_Administrative_Expenses__c) - parseFloat(this.wrapObj3.Other_Indirect_Expenses__c) - parseFloat(this.wrapObj3.Salary_to_Partner_Directors__c);
        this.wrapObj3.EBITDA__c = ebitda.toFixed(2);
        let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.EBITDA__c, this.wrapObj3.EBITDA__c);
        this.incrementdecrement1.EBITDA__c = p;
        this.calculateProfitBeforeDeprecition3();
    }
    calculateProfitBeforeDeprecition1() {
        let profit = 0;
        profit = parseFloat(this.wrapObj1.EBITDA__c) - parseFloat(this.wrapObj1.Interest_on_Term_Loans__c) - parseFloat(this.wrapObj1.Interest_on_CC_OD_limits__c) - parseFloat(this.wrapObj1.Interest_on_Partner_Capital__c) - parseFloat(this.wrapObj1.Non_Operating_Expenses_FxLoss_AssetLoss__c) + parseFloat(this.wrapObj1.Non_Business_Income__c);
        this.wrapObj1.Profit_Before_Depreciation_and_Tax_PBDT__c = profit.toFixed(2);
        let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Profit_Before_Depreciation_and_Tax_PBDT__c, this.wrapObj2.Profit_Before_Depreciation_and_Tax_PBDT__c);
        this.incrementdecrement.Profit_Before_Depreciation_and_Tax_PBDT__c = p;
        this.calculatePBT1();
    }
    calculateProfitBeforeDeprecition2() {
        let profit = 0;
        profit = parseFloat(this.wrapObj2.EBITDA__c) - parseFloat(this.wrapObj2.Interest_on_Term_Loans__c) - parseFloat(this.wrapObj2.Interest_on_CC_OD_limits__c) - parseFloat(this.wrapObj2.Interest_on_Partner_Capital__c) - parseFloat(this.wrapObj2.Non_Operating_Expenses_FxLoss_AssetLoss__c) + parseFloat(this.wrapObj2.Non_Business_Income__c);
        this.wrapObj2.Profit_Before_Depreciation_and_Tax_PBDT__c = profit.toFixed(2);
        let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Profit_Before_Depreciation_and_Tax_PBDT__c, this.wrapObj2.Profit_Before_Depreciation_and_Tax_PBDT__c);
        this.incrementdecrement.Profit_Before_Depreciation_and_Tax_PBDT__c = p;
        this.calculatePBT2();
        this.calculateProfitBeforeDeprecition3();
    }
    calculateProfitBeforeDeprecition3() {
        let profit = 0;
        profit = parseFloat(this.wrapObj3.EBITDA__c) - parseFloat(this.wrapObj3.Interest_on_Term_Loans__c) - parseFloat(this.wrapObj3.Interest_on_CC_OD_limits__c) - parseFloat(this.wrapObj3.Interest_on_Partner_Capital__c) - parseFloat(this.wrapObj3.Non_Operating_Expenses_FxLoss_AssetLoss__c) + parseFloat(this.wrapObj3.Non_Business_Income__c);
        this.wrapObj3.Profit_Before_Depreciation_and_Tax_PBDT__c = profit.toFixed(2);
        let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Profit_Before_Depreciation_and_Tax_PBDT__c, this.wrapObj3.Profit_Before_Depreciation_and_Tax_PBDT__c);
        this.incrementdecrement1.Profit_Before_Depreciation_and_Tax_PBDT__c = p;


        this.calculatePBT3();
    }
    calculatePBT1() {
        let pbt = 0;
        pbt = parseFloat(this.wrapObj1.Profit_Before_Depreciation_and_Tax_PBDT__c) - parseFloat(this.wrapObj1.Depreciation__c);
        this.wrapObj1.Profit_Before_Tax__c = pbt.toFixed(2);
        let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Profit_Before_Tax__c, this.wrapObj2.Profit_Before_Tax__c);
        this.incrementdecrement.Profit_Before_Tax__c = p;
        this.calculatePAT1();

    }
    calculatePBT2() {
        let pbt = 0;
        pbt = parseFloat(this.wrapObj2.Profit_Before_Depreciation_and_Tax_PBDT__c) - parseFloat(this.wrapObj2.Depreciation__c);
        this.wrapObj2.Profit_Before_Tax__c = pbt.toFixed(2);
        let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.Profit_Before_Tax__c, this.wrapObj2.Profit_Before_Tax__c);
        this.incrementdecrement.Profit_Before_Tax__c = p;
        this.calculatePAT2();
        this.calculatePBT3();
    }
    calculatePBT3() {
        let pbt = 0;
        pbt = parseFloat(this.wrapObj3.Profit_Before_Depreciation_and_Tax_PBDT__c) - parseFloat(this.wrapObj3.Depreciation__c);
        this.wrapObj3.Profit_Before_Tax__c = pbt.toFixed(2);
        let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.Profit_Before_Tax__c, this.wrapObj3.Profit_Before_Tax__c);
        this.incrementdecrement1.Profit_Before_Tax__c = p;
        this.calculatePAT3();
    }
    calculatePAT1() {
        let pat = 0;
        pat = parseFloat(this.wrapObj1.Profit_Before_Tax__c) - parseFloat(this.wrapObj1.Taxes__c);
        this.wrapObj1.PAT__c = pat.toFixed(2);
        let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.PAT__c, this.wrapObj2.PAT__c);
        this.incrementdecrement.PAT__c = p;
        this.calculateNetEligibility1();
        this.calculateNetEligibility2();
        
    }
    calculatePAT2() {
        let pat = 0;
        pat = parseFloat(this.wrapObj2.Profit_Before_Tax__c) - parseFloat(this.wrapObj2.Taxes__c);
        this.wrapObj2.PAT__c = pat.toFixed(2);
        let p = this.calculateIncrementDecrementPercentage(this.wrapObj1.PAT__c, this.wrapObj2.PAT__c);
        this.incrementdecrement.PAT__c = p;
        this.calculateNetEligibility1();
        this.calculateNetEligibility2();
        this.calculatePAT3();
        
    }
    calculatePAT3() {
        let pat = 0;
        pat = parseFloat(this.wrapObj3.Profit_Before_Tax__c) - parseFloat(this.wrapObj3.Taxes__c);
        this.wrapObj3.PAT__c = pat.toFixed(2);
        let p = this.calculateIncrementDecrementPercentage(this.wrapObj2.PAT__c, this.wrapObj3.PAT__c);
        this.incrementdecrement1.PAT__c = p;
        this.calculateNetEligibility3();
    }
    calculateIncrementDecrementPercentage(x, y) {
        let per = ((parseFloat(y) - parseFloat(x)) / parseFloat(x));
        if (per != Infinity) {
            return parseFloat(per);
        }
        else {
            return 0;
        }
    }
    calculateNetEligibility1() {
        let egl = 0
        egl = parseFloat(this.wrapObj1.Director_Partners_remuneration_Interest__c) - parseFloat(this.wrapObj1.Tax_on_Above_Income__c);
        this.wrapObj1.Net_Income_Considered_for_Eligibility__c = egl.toFixed(2);
        this.calculateNetIncomeAddition2();
        this.calculateNetIncomeAddition1();
    }
    calculateNetEligibility2() {
        let egl = 0
        egl = parseFloat(this.wrapObj2.Director_Partners_remuneration_Interest__c) - parseFloat(this.wrapObj2.Tax_on_Above_Income__c);
        this.wrapObj2.Net_Income_Considered_for_Eligibility__c = egl.toFixed(2);
    }

    calculateNetEligibility3() {
        let egl = 0
        egl = parseFloat(this.wrapObj3.Director_Partners_remuneration_Interest__c) - parseFloat(this.wrapObj3.Tax_on_Above_Income__c);
        this.wrapObj3.Net_Income_Considered_for_Eligibility__c = egl.toFixed(2);
        this.calculateNetIncomeAddition3();
    }

    //to get Income addition u/s 40(a)(2)(b) start

    calculateNetIncomeAddition1() {
        let egl = 0
        egl = parseFloat(this.wrapObj1.Income_addition_u_s_40_a_2_b__c) - parseFloat(this.wrapObj1.Tax_on_the_above_inc_for_Addition__c);
        this.wrapObj1.Net_inc_con_for_Eligibility_for_add_Inc__c = egl.toFixed(2);
    }
    calculateNetIncomeAddition2() {
        let egl = 0
        egl = parseFloat(this.wrapObj2.Income_addition_u_s_40_a_2_b__c) - parseFloat(this.wrapObj2.Tax_on_the_above_inc_for_Addition__c);
        this.wrapObj2.Net_inc_con_for_Eligibility_for_add_Inc__c = egl.toFixed(2);
    }

    calculateNetIncomeAddition3() {
        let egl = 0
        egl = parseFloat(this.wrapObj3.Income_addition_u_s_40_a_2_b__c) - parseFloat(this.wrapObj3.Tax_on_the_above_inc_for_Addition__c);
        this.wrapObj3.Net_inc_con_for_Eligibility_for_add_Inc__c = egl.toFixed(2);
    }
    
    //LAK-3739
    //daysDifference = 0

    @track currentYearDateIssue = false;
    @track previousYearDateIssue = false;


    checkDateValueIssue() {
        const todayDate = new Date();
        const currentYearDate = this.wrapObj2.Date_of_Filing_ITR__c ? new Date(this.wrapObj2.Date_of_Filing_ITR__c) : null;
        const previousYearDate = this.wrapObj1.Date_of_Filing_ITR__c ? new Date(this.wrapObj1.Date_of_Filing_ITR__c) : null;
        this.currentYearDateIssue = currentYearDate ? (currentYearDate > todayDate || currentYearDate < new Date(this.mincurrentyear)) : false;
        this.previousYearDateIssue = previousYearDate ? (previousYearDate > todayDate || previousYearDate < new Date(this.minprivousYear)) : false;
    }


    getITR_Filing_Gap_Days() {
        if (this.wrapObj1.Date_of_Filing_ITR__c && this.wrapObj2.Date_of_Filing_ITR__c) {
            const startDateObj = new Date(this.wrapObj1.Date_of_Filing_ITR__c);
            const endDateObj = new Date(this.wrapObj2.Date_of_Filing_ITR__c);
            const timeDifference = Math.abs(endDateObj - startDateObj);
            this.wrapObj2.ITR_Filing_Gap_Days__c = Math.ceil(timeDifference / (1000 * 3600 * 24)).toString();
        }else{
            this.wrapObj2.ITR_Filing_Gap_Days__c = '0';
        }
    }
    //upload and download manual profit and balance sheet lak-119
    /*@track showUploadComp;
    @track openPopuP;
    handleUploadExcelSheet(){
        console.log('inhandleUploadExcelSheet')
        this.showUploadComp=true
        this.openPopuP=true
        

    }
    handleDownExcelOfFinan(){
        this.showUploadComp=true
        this.openPopuP=false
        setTimeout(() => {
            if(this.template.querySelector('c-financial-sheet-upload-nd-download') != null){
               console.log('inside Download file'+ this.template.querySelector('c-financial-sheet-upload-nd-download'))
                this.template.querySelector('c-financial-sheet-upload-nd-download').downloadExcelFile();
            }
        }, 1000);

    }
    hideModalBox(event){
        this.showUploadComp=false;
        console.log('inhideModalBox')
       refreshApex(this.actualFinancialData);
       this.getFinancialSummaryRecord();
        this.fireCustomEvent();
    }*/
}