import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isAssessedIncomeProgram_Field from '@salesforce/schema/LoanAppl__c.AssesIncomeAppl__c';
import APPLICANT_Income_OBJECT from '@salesforce/schema/Applicant_Income__c';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import Nature_Of_Business_Of_Applicant_FIELD from '@salesforce/schema/Applicant_Income__c.Nature_Of_Business_of_Applicant__c';
// import Nature_Of_Business_Of_Applicant_FIELD from '@salesforce/schema/Applicant_Income__c';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';


import { createRecord } from 'lightning/uiRecordApi';

import { refreshApex } from '@salesforce/apex';
import Longitude from '@salesforce/schema/Lead.Longitude';

//Custom Labels
import CashFlow_Value_Population_Msg from '@salesforce/label/c.CashFlow_Value_Population_Msg';
import CashFlow_InputZero_ErrorMessage from '@salesforce/label/c.CashFlow_InputZero_ErrorMessage';
import CashFlow_InputNegative_ErrorMessage from '@salesforce/label/c.CashFlow_InputNegative_ErrorMessage';
import CashFlow_WokingDays_ErrorMessage from '@salesforce/label/c.CashFlow_WokingDays_ErrorMessage';
import CashFlow_IncomeDetails_SuccessMessage from '@salesforce/label/c.CashFlow_IncomeDetails_SuccessMessage';
import CashFlow_ReqFields_ErrorMessage from '@salesforce/label/c.CashFlow_ReqFields_ErrorMessage';
import CashFlow_UpdateRec_ErrorMessage from '@salesforce/label/c.CashFlow_UpdateRec_ErrorMessage';
import CashFlow_AppIncomeDetails_SuccessMessage from '@salesforce/label/c.CashFlow_AppIncomeDetails_SuccessMessage';


export default class CaptureCashFlowComputationDetails extends LightningElement {

    label = {
        CashFlow_Value_Population_Msg,
        CashFlow_InputZero_ErrorMessage,
        CashFlow_InputNegative_ErrorMessage,
        CashFlow_WokingDays_ErrorMessage,
        CashFlow_IncomeDetails_SuccessMessage,
        CashFlow_ReqFields_ErrorMessage,
        CashFlow_UpdateRec_ErrorMessage,
        CashFlow_AppIncomeDetails_SuccessMessage
    }

    @track natureOfBusinessOptions = [];
    @track selectedNatureOfbusinessValue;
    @track wiredDataOfApplType;
    @track _applicantIncomeDataId = undefined;
    @track wiredDataApplIncome;
    @track wiredIncomeDataIncome;
    @track ResultLoanAss;
    @track recordTypeIdForCashFlow;
    @api hasEditAccess;
    @api layoutSize;
    @api isSelected;
    @track isReadOnly = false;
    @track applicantRecord;

    get applicantIncomeDataId() {
        return this._applicantIncomeDataId;
    }
    set applicantIncomeDataId(value) {
        this._applicantIncomeDataId = value;
    }


    @track _recordTypeName;
    @api get recordTypeName() {
        return this._recordTypeName;
    }
    set recordTypeName(value) {

        this._recordTypeName = value;
        this.setAttribute("recordTypeName", value);

        this.handlerecordTypeNameChange(value);
    }

    handlerecordTypeNameChange() {
        this.recordTypeIdForCashFlow = this._recordTypeName;
        // this.handleAddrRecordChange();
    }


    @track applicantDetails = {
        LoanAppl__c: this._loanAppId,
        Id: this._applicantId,
        sobjectType: 'Applicant__c'
    };

    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        this.handleRecordLoanFieldsChange(value);
        // this.handleRecordAppIdChange(value);
    }



    @track _applicantId;
    @api get applicantId() {
        return this._applicantId;
    }
    set applicantId(value) {
        this._applicantId = value;
        this.setAttribute("applicantId", value);

        this.handleRecordApplIncomeIdChange(value);
        this.handleApplEmploymentbusinessValueChange(value);
        this.handleRecordApplIncomedataChange(value);

    }

    @track wiredDataLoanApplication;
    @track isOtherRevenueAvailabe = false;
    @track wrapApplIncomeObj = {}
    @api incomeType = "Cash flow Computation"
    @track tradingOrManufacturingCondition = true;
    @track serviceCondition;

    @track natureOfBsnessTradeOrManf;
    @track natureOfBsnessService;
    //removed zeros
    @track totalInflowAmount;
    @track MonthlyTotalDays;
    @track netCashProfitOrLoss;
    @track monthlyTotalIncome;

    @track normalDaysTotalMonthly;
    @track PeakDaysTotalMonthly;
    @track ServicesRevenueTotal;
    @track OtherRevenueTotal;
    @track totalCostOfMATERIALS;
    @track totalDetailsOfExpenses;
    @track approxMarginINBsness = 0 + "%";

    @track dailyIncomeForNormalDays;
    @track noOfWorkingDaysForNormalDays;
    @track dailyIncomeForPeakDays;
    @track noOfWorkingDaysForPeakDays;

    // service days variables
    @track serviceDaysTotalMonthly;
    @track dailyIncomeserviceDays;
    @track noOfWorkingDaysForserviceDays;

    @track dailyIncomeForServiceOthersDays;
    @track noOfWorkingForserviceOthersDays;
    @track OthersServiceDaysTotalMonthly;
    //removed zeros
    // Remark variables 
    @track remarksOfTotalExpensesValue;
    @track remarksOfOperatingActivityValue;
    @track otherRevenueRemarkvalue;
    @track natureOfBusinessValues;
    //Applicant Employment object variables

    @track dummyParams = false;

    connectedCallback() {
        if (this.hasEditAccess === false) {
            this.isReadOnly = true;
        }
        this.handleRefreshAllData();
    }


    @track EmploymentDataId;


    get displayCashflowComputationLayout() {
        return ((this.assesIncomeAppl == 'YES' && this.assesIncomeAppl != null) || (this.incomeType == "Cash flow Computation")) ? true : false;
    }

    @wire(MessageContext)
    MessageContext;

    @track
    LoanParams = {
        ParentObjectName: 'LoanAppl__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'AssesIncomeAppl__c'],
        childObjFields: [],
        queryCriteria: ''
    }

    handleRecordLoanFieldsChange() {
        let tempParams = this.LoanParams;
        tempParams.queryCriteria = ' where id = \'' + this._loanAppId + '\'';
        this.parameter = { ...tempParams };
    }

    @wire(getSobjectData, { params: '$LoanParams' })
    handleLoanAssIncomeResponse(wiredResultLoanAss) {
        this.ResultLoanAss = wiredResultLoanAss;
        let { error, data } = wiredResultLoanAss;
        if (data) {
            let result = data;
            let LoanData = result;
            if (LoanData && LoanData.parentRecords != undefined) {
                this.assesIncomeAppl = data.parentRecords[0].AssesIncomeAppl__c ? data.parentRecords[0].AssesIncomeAppl__c : '';
            }
        }
        if (error) {
            console.error('Error', error);
        }
    }

    @track EmploymentnatureOfBusinessValue;



    @track ApplEmpoymentparameter = {
        ParentObjectName: 'Applicant__c',
        ChildObjectRelName: 'Applicant_Employments__r',
        parentObjFields: ['Id', 'Constitution__c', 'CustProfile__c'],
        childObjFields: ['Id', 'Name', 'NatureOfBusinessCorporate__c', 'NatureOfBusinessIndividual__c'],
        queryCriteria: ''
    }

    @track wiredDataOfApplEmployment;

    @wire(getSobjectDatawithRelatedRecords, { params: '$ApplEmpoymentparameter' })
    handleResponseForEmployment(wiredResultApplEmp) {
        let { error, data } = wiredResultApplEmp;
        this.wiredDataOfApplEmployment = wiredResultApplEmp;
        if (data) {
            let result = data;
            let employmentData = result;
            var applicantConstitution;
            var appCustProfile;
            if (employmentData && employmentData.parentRecord) {
                applicantConstitution = employmentData.parentRecord.Constitution__c ? employmentData.parentRecord.Constitution__c : undefined;
                appCustProfile = employmentData.parentRecord.CustProfile__c ? employmentData.parentRecord.CustProfile__c : undefined;
            }

            if (employmentData && employmentData.ChildReords != undefined) {
                let EmploymentDataId = employmentData.ChildReords[0].Id;
                if (applicantConstitution && appCustProfile && (appCustProfile === 'SELF EMPLOYED PROFESSIONAL' || appCustProfile === 'SELF EMPLOYED NON PROFESSIONAL') && applicantConstitution != 'INDIVIDUAL') {
                    this.EmploymentnatureOfBusinessValue = employmentData.ChildReords[0].NatureOfBusinessCorporate__c ? employmentData.ChildReords[0].NatureOfBusinessCorporate__c : '';
                } else if (applicantConstitution && appCustProfile && (applicantConstitution === 'INDIVIDUAL' || appCustProfile === 'SALARIED')) {
                    this.EmploymentnatureOfBusinessValue = employmentData.ChildReords[0].NatureOfBusinessIndividual__c ? employmentData.ChildReords[0].NatureOfBusinessIndividual__c : '';
                }

                if (this.EmploymentnatureOfBusinessValue == 'T') {

                    this.natureOfBusinessValues = 'Trading';
                    this.wrapApplIncomeObj.Nature_Of_Business_of_Applicant__c = this.natureOfBusinessValues;
                    this.tradingOrManufacturingCondition = true;
                    this.serviceCondition = false;

                }
                //LAK-3330
                if (this.EmploymentnatureOfBusinessValue == 'M') {

                    this.natureOfBusinessValues = 'Manufacturing';
                    this.wrapApplIncomeObj.Nature_Of_Business_of_Applicant__c = this.natureOfBusinessValues;
                    this.tradingOrManufacturingCondition = true;
                    this.serviceCondition = false;

                }
                //LAK-3330
                if (this.EmploymentnatureOfBusinessValue == 'S') {

                    this.natureOfBusinessValues = 'Services';
                    this.wrapApplIncomeObj.Nature_Of_Business_of_Applicant__c = this.natureOfBusinessValues;

                    this.tradingOrManufacturingCondition = false;
                    this.serviceCondition = true;
                }
            }

            if (this.natureOfBusinessValues) {
                this.processCashFlowData();
            }
        } else if (error) {
            console.error('Error:', error);
        }
    }

    @track isLoadedParamOne = false;
    @track isLoadedParamTwo = false;

    processCashFlowData() {
        this.isLoadedParamOne = false;
        if (this.natureOfBusinessValues && this.natureOfBusinessValues == 'Trading' || this.natureOfBusinessValues == 'Manufacturing') {
            this.serviceCondition = false;
            this.tradingOrManufacturingCondition = true;
            if (this.filteredCashFlowRecords && this.filteredCashFlowRecords.length > 0) {
                this._applicantIncomeDataId = this.filteredCashFlowRecords[0].Id;
                this.wrapApplIncomeObj.Id = this._applicantIncomeDataId;
                this.dailyIncomeForNormalDays = this.filteredCashFlowRecords[0].Normal_Days_sales_Receipts_Daily__c ? this.filteredCashFlowRecords[0].Normal_Days_sales_Receipts_Daily__c : 0;
                this.noOfWorkingDaysForNormalDays = this.filteredCashFlowRecords[0].Normal_Days_sales_Days_Working__c ? this.filteredCashFlowRecords[0].Normal_Days_sales_Days_Working__c : 0;

                this.normalDaysTotalMonthly = parseInt(this.dailyIncomeForNormalDays) * parseInt(this.noOfWorkingDaysForNormalDays);
                this.wrapApplIncomeObj.Normal_Days_sales_Receipts_Monthly__c = this.normalDaysTotalMonthly;
                //this.normalDaysTotalMonthly = this.filteredCashFlowRecords[0].Normal_Days_sales_Receipts_Monthly__c ? this.filteredCashFlowRecords[0].Normal_Days_sales_Receipts_Monthly__c : null;

                this.dailyIncomeForPeakDays = this.filteredCashFlowRecords[0].Peak_Days_sales_Receipts_Daily__c ? this.filteredCashFlowRecords[0].Peak_Days_sales_Receipts_Daily__c : 0;
                this.noOfWorkingDaysForPeakDays = this.filteredCashFlowRecords[0].Peak_Days_sales_Receipts_Days_Working__c ? this.filteredCashFlowRecords[0].Peak_Days_sales_Receipts_Days_Working__c : 0;

                this.PeakDaysTotalMonthly = parseInt(this.dailyIncomeForPeakDays) * parseInt(this.noOfWorkingDaysForPeakDays);
                this.wrapApplIncomeObj.Peak_Days_sales_Receipts_Receipts_Monthl__c = this.PeakDaysTotalMonthly;
                //this.PeakDaysTotalMonthly = this.filteredCashFlowRecords[0].Peak_Days_sales_Receipts_Receipts_Monthl__c ? this.filteredCashFlowRecords[0].Peak_Days_sales_Receipts_Receipts_Monthl__c : null;

                this.ServicesRevenueTotal = this.filteredCashFlowRecords[0].ServicesRevenueMonthly__c ? this.filteredCashFlowRecords[0].ServicesRevenueMonthly__c : 0;
                this.OtherRevenueTotal = this.filteredCashFlowRecords[0].OtherRevenueMonthly__c ? this.filteredCashFlowRecords[0].OtherRevenueMonthly__c :0;
                this.totalCostOfMATERIALS = this.filteredCashFlowRecords[0].Monthly_Purchases_Cost_Of_Materials__c ? this.filteredCashFlowRecords[0].Monthly_Purchases_Cost_Of_Materials__c : 0;
                this.totalDetailsOfExpenses = this.filteredCashFlowRecords[0].Total_Expense_of_operations_Or_Business__c ? this.filteredCashFlowRecords[0].Total_Expense_of_operations_Or_Business__c : 0;

                if (this.noOfWorkingDaysForNormalDays != null && this.noOfWorkingDaysForPeakDays != null) {
                    this.MonthlyTotalDays = parseInt(this.noOfWorkingDaysForNormalDays) + parseInt(this.noOfWorkingDaysForPeakDays);
                }
                if (this.normalDaysTotalMonthly != null && this.PeakDaysTotalMonthly != null) {
                    this.monthlyTotalIncome = parseInt(this.normalDaysTotalMonthly) + parseInt(this.PeakDaysTotalMonthly);
                }
                
                if(this.OtherRevenueTotal !== 0){
                    this.isOtherRevenueAvailabe = true;
                }
    
                this.totalInflowAmount = parseInt(this.normalDaysTotalMonthly) + parseInt(this.PeakDaysTotalMonthly) + parseInt(this.ServicesRevenueTotal)  + ((this.OtherRevenueTotal && this.OtherRevenueTotal!=null) ? parseInt(this.OtherRevenueTotal) : 0);            
                this.wrapApplIncomeObj.Operating_Activity_Receipts__c = this.totalInflowAmount;
                this.wrapApplIncomeObj.Total_Inflow_From_Operations__c = this.totalInflowAmount;
    
                
                this.netCashProfitOrLoss = parseInt(this.totalInflowAmount) - parseInt(this.totalCostOfMATERIALS) - parseInt(this.totalDetailsOfExpenses);
                if (this.totalInflowAmount != 0 &&this.totalInflowAmount !=null) {
                    this.approxMarginINBsness = `${((this.netCashProfitOrLoss / this.totalInflowAmount) * 100).toFixed(2)} % `;
                }
                this.wrapApplIncomeObj.NET_CASH_PROFIT_LOSS__c = this.netCashProfitOrLoss;
                this.wrapApplIncomeObj.APPROXIMATE_MARGIN_IN_THE_BUSINESS__c = this.approxMarginINBsness;
                this.isLoadedParamOne = true;
            }
            
        }

        if (this.natureOfBusinessValues && this.natureOfBusinessValues == 'Services') {
            this.serviceCondition = true;
            this.tradingOrManufacturingCondition = false;
            if (this.filteredCashFlowRecords && this.filteredCashFlowRecords.length > 0) {

                this._applicantIncomeDataId = this.filteredCashFlowRecords[0].Id;
                this.dailyIncomeserviceDays = this.filteredCashFlowRecords[0].ReceiptsPerDayDaily__c ? this.filteredCashFlowRecords[0].ReceiptsPerDayDaily__c : 0;
                this.noOfWorkingDaysForserviceDays = this.filteredCashFlowRecords[0].ReceiptsPerDayDaysWorking__c ? this.filteredCashFlowRecords[0].ReceiptsPerDayDaysWorking__c : 0;
                //this.serviceDaysTotalMonthly = this.filteredCashFlowRecords[0].ReceiptsPerDayMonthly__c ? this.filteredCashFlowRecords[0].ReceiptsPerDayMonthly__c : 0;

                this.serviceDaysTotalMonthly = parseInt(this.dailyIncomeserviceDays) * parseInt(this.noOfWorkingDaysForserviceDays);
                this.wrapApplIncomeObj.ReceiptsPerDayMonthly__c = this.serviceDaysTotalMonthly;

                this.dailyIncomeForServiceOthersDays = this.filteredCashFlowRecords[0].OtherDayDaily__c ? this.filteredCashFlowRecords[0].OtherDayDaily__c : 0;
                this.noOfWorkingForserviceOthersDays = this.filteredCashFlowRecords[0].OthersDaysWorking__c ? this.filteredCashFlowRecords[0].OthersDaysWorking__c : 0;
                //this.OthersServiceDaysTotalMonthly = this.filteredCashFlowRecords[0].OthersDayMonthly__c ? this.filteredCashFlowRecords[0].OthersDayMonthly__c : 0;

                this.OthersServiceDaysTotalMonthly = parseInt(this.dailyIncomeForServiceOthersDays) * parseInt(this.noOfWorkingForserviceOthersDays);
                this.wrapApplIncomeObj.OthersDayMonthly__c = this.OthersServiceDaysTotalMonthly;

                this.ServicesRevenueTotal = this.filteredCashFlowRecords[0].ServicesRevenueMonthly__c ? this.filteredCashFlowRecords[0].ServicesRevenueMonthly__c : 0;
                this.OtherRevenueTotal = this.filteredCashFlowRecords[0].OtherRevenueMonthly__c ? this.filteredCashFlowRecords[0].OtherRevenueMonthly__c :0;
                this.totalCostOfMATERIALS = this.filteredCashFlowRecords[0].Monthly_Purchases_Cost_Of_Materials__c ? this.filteredCashFlowRecords[0].Monthly_Purchases_Cost_Of_Materials__c : 0;
                this.totalDetailsOfExpenses = this.filteredCashFlowRecords[0].Total_Expense_of_operations_Or_Business__c ? this.filteredCashFlowRecords[0].Total_Expense_of_operations_Or_Business__c : 0;

                if (this.noOfWorkingDaysForserviceDays != null && this.noOfWorkingForserviceOthersDays != null) {
                    this.MonthlyTotalDays = parseInt(this.noOfWorkingDaysForserviceDays) + parseInt(this.noOfWorkingForserviceOthersDays);
                }
    
                if (this.serviceDaysTotalMonthly != null && this.OthersServiceDaysTotalMonthly != null) {
                    this.monthlyTotalIncome = parseInt(this.serviceDaysTotalMonthly) + parseInt(this.OthersServiceDaysTotalMonthly);
                }
                
                
                if(this.OtherRevenueTotal!==0){
                    this.isOtherRevenueAvailabe = true;
                }
    
                this.totalInflowAmount = parseInt(this.serviceDaysTotalMonthly) + parseInt(this.OthersServiceDaysTotalMonthly) + parseInt(this.ServicesRevenueTotal) + ((this.OtherRevenueTotal && this.OtherRevenueTotal!=null) ? parseInt(this.OtherRevenueTotal) : 0);
                this.wrapApplIncomeObj.Operating_Activity_Receipts__c = this.totalInflowAmount;
                this.wrapApplIncomeObj.Total_Inflow_From_Operations__c = this.totalInflowAmount;
    
                
                this.netCashProfitOrLoss = parseInt(this.totalInflowAmount) - parseInt(this.totalCostOfMATERIALS) - parseInt(this.totalDetailsOfExpenses);
                if (this.totalInflowAmount != 0 &&this.totalInflowAmount !=null) {
                    this.approxMarginINBsness = `${((this.netCashProfitOrLoss / this.totalInflowAmount) * 100).toFixed(2)} % `;
                }
                this.wrapApplIncomeObj.NET_CASH_PROFIT_LOSS__c = this.netCashProfitOrLoss;
                this.wrapApplIncomeObj.APPROXIMATE_MARGIN_IN_THE_BUSINESS__c = this.approxMarginINBsness;
                this.isLoadedParamOne = true;
                
            }

            
        }
    }

    handleApplEmploymentbusinessValueChange() {
        let tempParams = this.ApplEmpoymentparameter;
        tempParams.queryCriteria = ' where id = \'' + this._applicantId + '\'';
        this.ApplEmpoymentparameter = { ...tempParams };

    }

    handlenatureOfBusinessChange(event) {

        this.selectedNatureOfbusinessValue = event.target.value;
        this.wrapApplIncomeObj[event.target.dataset.name] = this.selectedNatureOfbusinessValue;
        if (event.target.value == 'Trading') {
            this.tradingOrManufacturingCondition = true;
            this.serviceCondition = false;
        }
        //LAK-3330
        if (event.target.value == 'Manufacturing') {
            this.tradingOrManufacturingCondition = true;
            this.serviceCondition = false;
        }
        //LAK-3330
        if (event.target.value == 'Services') {
            this.serviceCondition = true;
            this.tradingOrManufacturingCondition = false;
        }
        if (this.selectedNatureOfbusinessValue !== this.natureOfBusinessValues) {

        }
        else {

        }
    }

    generatePicklist(data) {
        return data.values.map(item => ({ label: item.label, value: item.value }))
    }
    @wire(getObjectInfo, { objectApiName: APPLICANT_Income_OBJECT })
    objInfo

    @wire(getPicklistValues, { recordTypeId: '$recordTypeIdForCashFlow', fieldApiName: Nature_Of_Business_Of_Applicant_FIELD })
    natureOfBusinessPicklistHandler({ data, error }) {
        if (data) {
            this.natureOfBusinessOptions = [...this.generatePicklist(data)]
        }
        if (error) {
            console.log(error)
        }
    }

    @track
    parameter = {
        ParentObjectName: 'Applicant__c',
        ChildObjectRelName: 'Applicant_Income__r',
        parentObjFields: ['Id'],
        childObjFields: ['Id', 'Name'],
        queryCriteria: ''
    }

    handleRecordApplIncomeIdChange() {
        let tempParams = this.parameter;
        tempParams.queryCriteria = ' where id = \'' + this._applicantId + '\'';
        this.parameter = { ...tempParams };

    }

    @wire(getSobjectDatawithRelatedRecords, { params: '$parameter' })
    handleResponseForApplIncome(wiredResultAppl) {
        let { error, data } = wiredResultAppl;
        this.wiredDataOfApplType = wiredResultAppl;
        if (data) {
            let result = data;
            let applIncomeData = result;
            if (applIncomeData && applIncomeData.ChildReords != undefined) {
                this._applicantIncomeDataId = applIncomeData.ChildReords[0].Id;
            }

        } else if (error) {
            console.error('Error:', error);
        }
    }

    @track
    ApplIncomefields = {
        ParentObjectName: 'Applicant__c',
        ChildObjectRelName: 'Applicant_Income__r',
        parentObjFields: ['Id'],
        childObjFields: ['Id', 'Operating_Activity_Receipts__c', 'Normal_Days_sales_Receipts_Daily__c', 'Normal_Days_sales_Days_Working__c', 'Normal_Days_sales_Receipts_Monthly__c', 'Peak_Days_sales_Receipts_Daily__c', 'Peak_Days_sales_Receipts_Days_Working__c', 'Peak_Days_sales_Receipts_Receipts_Monthl__c', 'OtherDayDaily__c', 'OthersDaysWorking__c', 'OthersDayMonthly__c', 'ReceiptsPerDayDaily__c', 'ReceiptsPerDayDaysWorking__c', 'ReceiptsPerDayMonthly__c', 'ServicesRevenueMonthly__c', 'OtherRevenueMonthly__c', 'Total_Inflow_From_Operations__c', 'Monthly_Purchases_Cost_Of_Materials__c', 'Total_Expense_of_operations_Or_Business__c', 'Nature_Of_Business_of_Applicant__c', 'Cash_Flow_Remarks__c', 'Remark__c', 'LastModifiedDate', 'RecordTypeId'],
        queryCriteria: ''
    }


    @track
    ApplEmploymentfields = {
        ParentObjectName: 'ApplicantEmployment__c',
        ChildObjectRelName: null,
        parentObjFields: ['Id', 'NatureOfBusinessIndividual__c', 'NatureOfBusinessCorporate__c', 'LoanApplicant__c'],
        childObjFields: null,
        queryCriteria: ''
    }

    handleRecordApplIncomedataChange() {
        let tempParams = this.ApplIncomefields;
        tempParams.queryCriteria = ' where id = \'' + this._applicantId + '\'';
        this.ApplIncomefields = { ...tempParams };

    }




    @track filteredCashFlowRecords = [];
    @wire(getSobjectDatawithRelatedRecords, { params: '$ApplIncomefields' })
    handleResponseApplIncome(wiredResultApplIncome) {
        this.wiredDataApplIncome = wiredResultApplIncome;
        let { error, data } = wiredResultApplIncome;
        let result = data;
        let IncomeData = result;
        let filteredRecords = [];
        this.filteredCashFlowRecords = [];
        this.isLoadedParamTwo = false;
        if (IncomeData && IncomeData.ChildReords != undefined) {
            for (let record of IncomeData.ChildReords) {
                if (record.RecordTypeId === this.recordTypeIdForCashFlow) {
                    filteredRecords.push(record);
                    this.filteredCashFlowRecords.push(record);
                }
            }
        }

        console.log('filteredRecords==>', JSON.stringify(filteredRecords));
        if (data) {
            this.applicantRecord = data.parentRecords;
            if (filteredRecords && filteredRecords.length > 0) {
                this._applicantIncomeDataId = filteredRecords[0].Id;
                this.wrapApplIncomeObj.Id = this._applicantIncomeDataId;
                this.remarksOfOperatingActivityValue = filteredRecords[0].Cash_Flow_Remarks__c ? filteredRecords[0].Cash_Flow_Remarks__c : '';
                this.otherRevenueRemarkvalue = filteredRecords[0].Remark__c ? filteredRecords[0].Remark__c : '';
                if (!this.natureOfBusinessValues) {
                    this.natureOfBusinessValues = filteredRecords[0].Nature_Of_Business_of_Applicant__c ? filteredRecords[0].Nature_Of_Business_of_Applicant__c : '';
                }
                
                
            }


            if (this.natureOfBusinessValues == 'Trading' || this.natureOfBusinessValues == 'Manufacturing') {
                this.serviceCondition = false;
                this.tradingOrManufacturingCondition = true;
                if (filteredRecords && filteredRecords.length > 0) {

                    this._applicantIncomeDataId = filteredRecords[0].Id;
                    this.dailyIncomeForNormalDays = filteredRecords[0].Normal_Days_sales_Receipts_Daily__c ? filteredRecords[0].Normal_Days_sales_Receipts_Daily__c : 0;
                    this.noOfWorkingDaysForNormalDays = filteredRecords[0].Normal_Days_sales_Days_Working__c ? filteredRecords[0].Normal_Days_sales_Days_Working__c : 0;

                    this.normalDaysTotalMonthly = parseInt(this.dailyIncomeForNormalDays) * parseInt(this.noOfWorkingDaysForNormalDays);
                    this.wrapApplIncomeObj.Normal_Days_sales_Receipts_Monthly__c = this.normalDaysTotalMonthly;
                    //this.normalDaysTotalMonthly = filteredRecords[0].Normal_Days_sales_Receipts_Monthly__c ? filteredRecords[0].Normal_Days_sales_Receipts_Monthly__c : null;

                    this.dailyIncomeForPeakDays = filteredRecords[0].Peak_Days_sales_Receipts_Daily__c ? filteredRecords[0].Peak_Days_sales_Receipts_Daily__c : 0;
                    this.noOfWorkingDaysForPeakDays = filteredRecords[0].Peak_Days_sales_Receipts_Days_Working__c ? filteredRecords[0].Peak_Days_sales_Receipts_Days_Working__c : 0;

                    this.PeakDaysTotalMonthly = parseInt(this.dailyIncomeForPeakDays) * parseInt(this.noOfWorkingDaysForPeakDays);
                    this.wrapApplIncomeObj.Peak_Days_sales_Receipts_Receipts_Monthl__c = this.PeakDaysTotalMonthly;
                    //this.PeakDaysTotalMonthly = filteredRecords[0].Peak_Days_sales_Receipts_Receipts_Monthl__c ? filteredRecords[0].Peak_Days_sales_Receipts_Receipts_Monthl__c : null;

                    this.ServicesRevenueTotal = filteredRecords[0].ServicesRevenueMonthly__c ? filteredRecords[0].ServicesRevenueMonthly__c : 0;
                    this.OtherRevenueTotal = filteredRecords[0].OtherRevenueMonthly__c ? filteredRecords[0].OtherRevenueMonthly__c :0;
                    
                    if(this.OtherRevenueTotal!==0){
                        this.isOtherRevenueAvailabe = true;
                    }

                    this.totalInflowAmount = parseInt(this.normalDaysTotalMonthly) + parseInt(this.PeakDaysTotalMonthly) + parseInt(this.ServicesRevenueTotal)  + ((this.OtherRevenueTotal && this.OtherRevenueTotal!=null) ? parseInt(this.OtherRevenueTotal) : 0);
                    this.wrapApplIncomeObj.Operating_Activity_Receipts__c = this.totalInflowAmount;
                    this.wrapApplIncomeObj.Total_Inflow_From_Operations__c = this.totalInflowAmount;

                    this.totalCostOfMATERIALS = filteredRecords[0].Monthly_Purchases_Cost_Of_Materials__c ? filteredRecords[0].Monthly_Purchases_Cost_Of_Materials__c : 0;
                    this.totalDetailsOfExpenses = filteredRecords[0].Total_Expense_of_operations_Or_Business__c ? filteredRecords[0].Total_Expense_of_operations_Or_Business__c : 0;


                    if (this.noOfWorkingDaysForNormalDays != null && this.noOfWorkingDaysForPeakDays != null) {
                        this.MonthlyTotalDays = parseInt(this.noOfWorkingDaysForNormalDays) + parseInt(this.noOfWorkingDaysForPeakDays);
    
                    }
                    if (this.normalDaysTotalMonthly != null && this.PeakDaysTotalMonthly != null) {
                        this.monthlyTotalIncome = parseInt(this.normalDaysTotalMonthly) + parseInt(this.PeakDaysTotalMonthly);
    
                    }
    
                    
                    this.netCashProfitOrLoss = parseInt(this.totalInflowAmount) - parseInt(this.totalCostOfMATERIALS) - parseInt(this.totalDetailsOfExpenses);
                    if (this.totalInflowAmount != 0 &&this.totalInflowAmount !=null) {
                        this.approxMarginINBsness = `${((this.netCashProfitOrLoss / this.totalInflowAmount) * 100).toFixed(2)} % `;
                    }
                    this.wrapApplIncomeObj.NET_CASH_PROFIT_LOSS__c = this.netCashProfitOrLoss;
                    this.wrapApplIncomeObj.APPROXIMATE_MARGIN_IN_THE_BUSINESS__c = this.approxMarginINBsness;
                    this.isLoadedParamTwo = true;
                }
                
            }

            if (this.natureOfBusinessValues == 'Services') {
                this.serviceCondition = true;
                this.tradingOrManufacturingCondition = false;
                if (filteredRecords && filteredRecords.length > 0) {
                    this._applicantIncomeDataId = filteredRecords[0].Id;
                    this.dailyIncomeserviceDays = filteredRecords[0].ReceiptsPerDayDaily__c ? filteredRecords[0].ReceiptsPerDayDaily__c : 0;
                    this.noOfWorkingDaysForserviceDays = filteredRecords[0].ReceiptsPerDayDaysWorking__c ? filteredRecords[0].ReceiptsPerDayDaysWorking__c : 0;
                    //this.serviceDaysTotalMonthly = filteredRecords[0].ReceiptsPerDayMonthly__c ? filteredRecords[0].ReceiptsPerDayMonthly__c : null;
                    this.serviceDaysTotalMonthly = parseInt(this.dailyIncomeserviceDays) * parseInt(this.noOfWorkingDaysForserviceDays);
                    this.wrapApplIncomeObj.ReceiptsPerDayMonthly__c = this.serviceDaysTotalMonthly;

                    this.dailyIncomeForServiceOthersDays = filteredRecords[0].OtherDayDaily__c ? filteredRecords[0].OtherDayDaily__c : 0;
                    this.noOfWorkingForserviceOthersDays = filteredRecords[0].OthersDaysWorking__c ? filteredRecords[0].OthersDaysWorking__c : 0;
                    //this.OthersServiceDaysTotalMonthly = filteredRecords[0].OthersDayMonthly__c ? filteredRecords[0].OthersDayMonthly__c : 0;
                    this.OthersServiceDaysTotalMonthly = parseInt(this.dailyIncomeForServiceOthersDays) * parseInt(this.noOfWorkingForserviceOthersDays);
                    this.wrapApplIncomeObj.OthersDayMonthly__c = this.OthersServiceDaysTotalMonthly;


                    this.ServicesRevenueTotal = filteredRecords[0].ServicesRevenueMonthly__c ? filteredRecords[0].ServicesRevenueMonthly__c : 0;
                    this.OtherRevenueTotal = filteredRecords[0].OtherRevenueMonthly__c ? filteredRecords[0].OtherRevenueMonthly__c :0;
                    this.totalCostOfMATERIALS = filteredRecords[0].Monthly_Purchases_Cost_Of_Materials__c ? filteredRecords[0].Monthly_Purchases_Cost_Of_Materials__c : 0;
                    this.totalDetailsOfExpenses = filteredRecords[0].Total_Expense_of_operations_Or_Business__c ? filteredRecords[0].Total_Expense_of_operations_Or_Business__c : 0;


                    if(this.OtherRevenueTotal!==0){
                        this.isOtherRevenueAvailabe = true;
                    }
    
    
                    this.totalInflowAmount = parseInt(this.serviceDaysTotalMonthly) + parseInt(this.OthersServiceDaysTotalMonthly) + parseInt(this.ServicesRevenueTotal) + ((this.OtherRevenueTotal && this.OtherRevenueTotal!=null) ? parseInt(this.OtherRevenueTotal) : 0);
                    this.wrapApplIncomeObj.Operating_Activity_Receipts__c = this.totalInflowAmount;
                    this.wrapApplIncomeObj.Total_Inflow_From_Operations__c = this.totalInflowAmount;
    
                    if (this.noOfWorkingDaysForserviceDays != null && this.noOfWorkingForserviceOthersDays != null) {
                        this.MonthlyTotalDays = parseInt(this.noOfWorkingDaysForserviceDays) + parseInt(this.noOfWorkingForserviceOthersDays);
                    }
    
                    if (this.serviceDaysTotalMonthly != null && this.OthersServiceDaysTotalMonthly != null) {
                        this.monthlyTotalIncome = parseInt(this.serviceDaysTotalMonthly) + parseInt(this.OthersServiceDaysTotalMonthly);
                    }
    
                    
                    this.netCashProfitOrLoss = parseInt(this.totalInflowAmount) - parseInt(this.totalCostOfMATERIALS) - parseInt(this.totalDetailsOfExpenses);
                    if (this.totalInflowAmount != 0 &&this.totalInflowAmount !=null) {
                        this.approxMarginINBsness = `${((this.netCashProfitOrLoss / this.totalInflowAmount) * 100).toFixed(2)} % `;
                    }
                    this.wrapApplIncomeObj.NET_CASH_PROFIT_LOSS__c = this.netCashProfitOrLoss;
                    this.wrapApplIncomeObj.APPROXIMATE_MARGIN_IN_THE_BUSINESS__c = this.approxMarginINBsness;
                    this.isLoadedParamTwo = true;
                    
                }

                
                
            }

        } else if (error) {
            this.error = error;

        }
    }


    handleDaysAndIncomeChange(event) {
        try {
            this.wrapApplIncomeObj[event.target.dataset.name] = event.target.value;
        } catch (error) {
        }
        if (event.target.label == "RemarksOfOperatingActivity") {
            this.remarksOfOperatingActivityValue = event.target.value.toUpperCase();
            this.wrapApplIncomeObj[event.target.dataset.name] = this.remarksOfOperatingActivityValue;
        }
        if (event.target.label == "otherRevenueRemarks") {
            this.otherRevenueRemarkvalue = event.target.value.toUpperCase();
            this.wrapApplIncomeObj[event.target.dataset.name] = this.otherRevenueRemarkvalue;
        }
        if (event.target.label == "a") {
            let value = parseInt(event.target.value);
            if (!isNaN(value)) {
                this.dailyIncomeForNormalDays = value;
            } else {
                this.dailyIncomeForNormalDays = 0;
            }
        }

        if (event.target.label == "b") {
            let value = parseInt(event.target.value);
            if (!isNaN(value)) {
                this.noOfWorkingDaysForNormalDays = value;
            } else {
                this.noOfWorkingDaysForNormalDays = 0;
            }
        }


        if (event.target.label == "c") {
            let value = parseInt(event.target.value);
            if (!isNaN(value)) {
                this.dailyIncomeForPeakDays = value;
            } else {
                this.dailyIncomeForPeakDays = 0;
            }
        }
        if (event.target.label == "d") {
            let value = parseInt(event.target.value);
            if (!isNaN(value)) {
                this.noOfWorkingDaysForPeakDays = value;
            } else {
                this.noOfWorkingDaysForPeakDays = 0;
            }
        }
        if (event.target.label == "serviceReceiptIncomeField") {
            let value = parseInt(event.target.value);
            if (!isNaN(value)) {
                this.dailyIncomeserviceDays = value;
            } else {
                this.dailyIncomeserviceDays = 0;
            }
        }
        if (event.target.label == "serviceReceiptDaysField") {
            let value = parseInt(event.target.value);
            if (!isNaN(value)) {
                this.noOfWorkingDaysForserviceDays = value;
            } else {
                this.noOfWorkingDaysForserviceDays = 0;
            }
        }

        if (event.target.label == "serviceOthersIncomeField") {
            let value = parseInt(event.target.value);
            if (!isNaN(value)) {
                this.dailyIncomeForServiceOthersDays = value;
            } else {
                this.dailyIncomeForServiceOthersDays = 0;
            }
        }
        if (event.target.label == "serviceOthersDaysField") {
            let value = parseInt(event.target.value);
            if (!isNaN(value)) {
                this.noOfWorkingForserviceOthersDays = value;
            } else {
                this.noOfWorkingForserviceOthersDays = 0;
            }
        }

        if (event.target.label == "e") {
            let value = parseInt(event.target.value);
            if (!isNaN(value)) {
                this.ServicesRevenueTotal = value;
            } else {
                this.ServicesRevenueTotal = 0;
            }
        }

        if (event.target.label == "f") {
            this.isOtherRevenueAvailabe = true;
            let value = parseInt(event.target.value);
            if (!isNaN(value)) {
                this.OtherRevenueTotal = value;
            } else {
                this.OtherRevenueTotal = 0;
            }
        }

        if (event.target.label == "g") {
            let value = parseInt(event.target.value);
            if (!isNaN(value)) {
                this.totalCostOfMATERIALS = value;
            } else {
                this.totalCostOfMATERIALS = 0;
            }
        }

        if (event.target.label == "h") {
            let value = parseInt(event.target.value);
            if (!isNaN(value)) {
                this.totalDetailsOfExpenses = value;
            } else {
                this.totalDetailsOfExpenses = 0;
            }
        }

        if (this.serviceCondition == true) {
            this.serviceDaysTotalMonthly = parseInt(this.dailyIncomeserviceDays) * parseInt(this.noOfWorkingDaysForserviceDays);
            this.wrapApplIncomeObj.ReceiptsPerDayMonthly__c = this.serviceDaysTotalMonthly.toString();
            this.OthersServiceDaysTotalMonthly = parseInt(this.dailyIncomeForServiceOthersDays) * parseInt(this.noOfWorkingForserviceOthersDays);
            this.wrapApplIncomeObj.OthersDayMonthly__c = this.OthersServiceDaysTotalMonthly.toString();
            this.totalInflowAmount = parseInt(this.serviceDaysTotalMonthly) + parseInt(this.OthersServiceDaysTotalMonthly) + parseInt(this.ServicesRevenueTotal) + parseInt(this.OtherRevenueTotal);
            this.wrapApplIncomeObj.Operating_Activity_Receipts__c = this.totalInflowAmount.toString();
            this.wrapApplIncomeObj.Total_Inflow_From_Operations__c = this.totalInflowAmount.toString();

            this.MonthlyTotalDays = parseInt(this.noOfWorkingDaysForserviceDays) + parseInt(this.noOfWorkingForserviceOthersDays);
            this.monthlyTotalIncome = parseInt(this.serviceDaysTotalMonthly) + parseInt(this.OthersServiceDaysTotalMonthly);
        }


        if (this.tradingOrManufacturingCondition == true) {
            this.normalDaysTotalMonthly = parseInt(this.dailyIncomeForNormalDays) * parseInt(this.noOfWorkingDaysForNormalDays);
            this.PeakDaysTotalMonthly = parseInt(this.dailyIncomeForPeakDays) * parseInt(this.noOfWorkingDaysForPeakDays);
            this.totalInflowAmount = parseInt(this.normalDaysTotalMonthly) + parseInt(this.PeakDaysTotalMonthly) + parseInt(this.ServicesRevenueTotal) + parseInt(this.OtherRevenueTotal);
            this.MonthlyTotalDays = parseInt(this.noOfWorkingDaysForNormalDays) + parseInt(this.noOfWorkingDaysForPeakDays);
            this.monthlyTotalIncome = parseInt(this.normalDaysTotalMonthly) + parseInt(this.PeakDaysTotalMonthly);

            this.wrapApplIncomeObj.Normal_Days_sales_Receipts_Monthly__c = this.normalDaysTotalMonthly.toString();
            this.wrapApplIncomeObj.Peak_Days_sales_Receipts_Receipts_Monthl__c = this.PeakDaysTotalMonthly.toString();
            this.wrapApplIncomeObj.Operating_Activity_Receipts__c = this.totalInflowAmount.toString();
            this.wrapApplIncomeObj.Total_Inflow_From_Operations__c = this.totalInflowAmount.toString();

        }


        this.netCashProfitOrLoss = parseInt(this.totalInflowAmount) - parseInt(this.totalCostOfMATERIALS) - parseInt(this.totalDetailsOfExpenses);
        this.wrapApplIncomeObj.NET_CASH_PROFIT_LOSS__c = this.netCashProfitOrLoss.toString();

        if (this.totalInflowAmount != 0) {
            const marginPercentage = (this.netCashProfitOrLoss / this.totalInflowAmount) * 100;
            if (!isNaN(marginPercentage)) {
                this.approxMarginINBsness = marginPercentage.toFixed(2);
                this.wrapApplIncomeObj.APPROXIMATE_MARGIN_IN_THE_BUSINESS__c = marginPercentage.toFixed(2);
            } else {
                this.approxMarginINBsness = '0 %';
                this.wrapApplIncomeObj.APPROXIMATE_MARGIN_IN_THE_BUSINESS__c = '0';
            }
        } else if (this.totalInflowAmount == 0 && this.netCashProfitOrLoss == 0) {
            this.approxMarginINBsness = `0 %`;
        } else {
            this.approxMarginINBsness = `0 %`;
        }
    }



    @api validateForm() {
        let isValid = true;

        if (this.MonthlyTotalDays > 31) {
            isValid = false;
            this.showToastMessage('Error', this.label.CashFlow_WokingDays_ErrorMessage, 'error', 'sticky');
        }
        if (this.netCashProfitOrLoss < 0) {
            isValid = false;
            this.showToastMessage('Error', this.label.CashFlow_InputNegative_ErrorMessage, 'error', 'sticky');
        }

        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if (element.reportValidity()) {
            } else {
                isValid = false;
                this.showToastMessage('Error', this.label.CashFlow_ReqFields_ErrorMessage, 'error', 'sticky');

            }
        });

        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
            } else {
                isValid = false;
                this.showToastMessage('Error', this.label.CashFlow_ReqFields_ErrorMessage, 'error', 'sticky');
            }
        });
        return isValid;
    }

    @track showSpinner = false;

    @api handleUpsert() {
        this.showSpinner = true;
        if (this._applicantIncomeDataId != undefined) {
            this.wrapApplIncomeObj.Id = this._applicantIncomeDataId;

            for (let key in this.wrapApplIncomeObj) {
                if (this.wrapApplIncomeObj[key] === "NaN") {
                    this.wrapApplIncomeObj[key] = "0";
                }
            }

            this.wrapApplIncomeObj.Nature_Of_Business_of_Applicant__c = this.natureOfBusinessValues;

            let upsertData = {
                parentRecord: this.wrapApplIncomeObj,
                ChildRecords: [],
                ParentFieldNameToUpdate: 'Applicant_Income__c'
            }

            console.log('upsertData::>>', JSON.stringify(upsertData));
            upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
            .then(result => {
                this.showToastMessage('Success', this.label.CashFlow_IncomeDetails_SuccessMessage, 'success', 'sticky');
                this.showSpinner = false;
                this.handleRefreshAllData();
            })
            .catch(error => {
                console.error(error)
                console.log('upsert error -', JSON.stringify(error))
                this.showToastMessage('Error', this.label.CashFlow_UpdateRec_ErrorMessage, 'error', 'sticky');
                this.showSpinner = false;
            })
        }

        else if (this._applicantIncomeDataId == undefined) {
            this.wrapApplIncomeObj.Applicant__c = this._applicantId;
            this.wrapApplIncomeObj.RecordTypeId = this.recordTypeIdForCashFlow;

            for (let key in this.wrapApplIncomeObj) {
                if (this.wrapApplIncomeObj[key] === "NaN") {
                    this.wrapApplIncomeObj[key] = "0";
                }
            }

            

            
            let tempRecs = [];
            if(this.wrapApplIncomeObj){
                var currentData = this.wrapApplIncomeObj;
                currentData.sobjectType = 'Applicant_Income__c';
                tempRecs.push(currentData);
            }


            if (tempRecs.length > 0){
                upsertMultipleRecord({ params: tempRecs })
                .then(result => {
                    this.showSpinner = false;
                    this.showToastMessage('Success', this.label.CashFlow_AppIncomeDetails_SuccessMessage, 'success', 'sticky');
                    this.handleRefreshAllData();
                }).catch(error => {
                    console.log('error while create record', JSON.stringify(error));
                    this.showSpinner = false;
                    this.showToastMessage('Error', this.label.CashFlow_UpdateRec_ErrorMessage, 'error', 'sticky');
                })
            }

            // const fields = this.wrapApplIncomeObj;
            // const recordInput = {
            //     apiName: APPLICANT_Income_OBJECT.objectApiName,
            //     fields: fields
            // };

            // createRecord(recordInput)
            // .then((result) => {
            //     this.showSpinner = false;
            //     this.showToastMessage('Success', this.label.CashFlow_AppIncomeDetails_SuccessMessage, 'success', 'sticky');
            //     this.handleRefreshAllData();
            // })
            // .catch((error) => {
            //     console.log('error while create record', JSON.stringify(error));
            //     this.showSpinner = false;
            //     this.showToastMessage('Error', this.label.CashFlow_UpdateRec_ErrorMessage, 'error', 'sticky');
            // });
        }
    }


    handleRefreshAllData() {
        refreshApex(this.wiredDataOfApplType);
        refreshApex(this.ResultLoanAss);
        refreshApex(this.wiredDataApplIncome);
        refreshApex(this.wiredDataOfApplEmployment);
    }

    @track dummyUpdate = false;

    renderedCallback() {
        this.handleRefreshAllData();
        if((this.isLoadedParamOne === true || this.isLoadedParamTwo === true) && this.wrapApplIncomeObj && this.wrapApplIncomeObj.Id && this.dummyUpdate === false){
            this.dummyUpdateHandler();
            this.dummyUpdate = true;
        }
    }

    dummyUpdateHandler(){
        let upsertDataDummy = {
            parentRecord: this.wrapApplIncomeObj,
            ChildRecords: [],
            ParentFieldNameToUpdate: 'Applicant_Income__c'
        }
        upsertSobjDataWIthRelatedChilds({ upsertData: upsertDataDummy })
        .then(result => {
            this.handleRefreshAllData();
        })
        .catch(error => {
            console.log('upsert error -', JSON.stringify(error));
        })
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