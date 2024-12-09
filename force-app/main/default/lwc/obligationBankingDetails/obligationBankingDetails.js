import { LightningElement, api, wire, track } from 'lwc';
import fetchRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import fetchSingleObject from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import insertMultipleRecord from '@salesforce/apex/ObligatoryDtls.insertMultipleRecord';
import upsertManualRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleParentsWithMultipleChilds';
import { updateRecord, deleteRecord } from "lightning/uiRecordApi";
import getData from '@salesforce/apex/SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords';
import upsertParentChildRec from '@salesforce/apex/ObligatoryDtls.upsertParentChildRec';
import getIdMapForSfdcMstrObjs from '@salesforce/apex/ObligatoryDtls.getIdMapForSfdcMstrObjs';
import getIdMapForBalTranFinancier from '@salesforce/apex/ObligatoryDtls.getIdMapForBalTranFinancier';

import SheetJS1 from '@salesforce/resourceUrl/SheetJS1';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable'
import getDatawithoutCache from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataWithoutCacheable';
import getSobjectDatawithFilterRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithFilterRelatedRecords';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, MessageContext } from 'lightning/messageService';
import deleteAllRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import { refreshApex } from '@salesforce/apex';
import TREATMENT from '@salesforce/schema/BureauRespDtl__c.Treatment__c';
import LOANCAPACITY from '@salesforce/schema/BureauRespDtl__c.LoanCapacity__c';
import ApplObligation from '@salesforce/schema/BureauRespDtl__c';
// Custom labels
import ObligationBanking_EmiDate_ErrroMessage from '@salesforce/label/c.ObligationBanking_EmiDate_ErrroMessage';
import ObligationBanking_Update_SuccessMessage from '@salesforce/label/c.ObligationBanking_Update_SuccessMessage';
import ObligationBanking_ReqFields_ErrorMessage from '@salesforce/label/c.ObligationBanking_ReqFields_ErrorMessage';
import ObligationBanking_value_ErrorMessage from '@salesforce/label/c.ObligationBanking_value_ErrorMessage';
import ObligationBanking_Del_SuccessMessage from '@salesforce/label/c.ObligationBanking_Del_SuccessMessage';
import ObligationBanking_RTRDateMes_ErrorMessage from '@salesforce/label/c.ObligationBanking_RTRDateMes_ErrorMessage';
import ObligationBanking_LoginAccDate_ErrorMessage from '@salesforce/label/c.ObligationBanking_LoginAccDate_ErrorMessage';
import ObligationBanking_closeDate_error from '@salesforce/label/c.ObligationBanking_closeDate_error';
const DELAY = 500;
import formFactorPropertyName from "@salesforce/client/formFactor";
import LOGIN_DATE from "@salesforce/schema/LoanAppl__c.LoginMonthAndYear__c";
import ADD_ANOTHER_LOAN from "@salesforce/schema/LoanAppl__c.Add_Another_Loan__c";
import LOAN_APP_ID from "@salesforce/schema/LoanAppl__c.Id";
export default class ObligationBankingDetails extends LightningElement {

    customLabel = {
        ObligationBanking_EmiDate_ErrroMessage,
        ObligationBanking_Update_SuccessMessage,
        ObligationBanking_ReqFields_ErrorMessage,
        ObligationBanking_value_ErrorMessage,
        ObligationBanking_Del_SuccessMessage,
        ObligationBanking_RTRDateMes_ErrorMessage,
        ObligationBanking_LoginAccDate_ErrorMessage,
        ObligationBanking_closeDate_error
    }
    //mobile view
    desktopBoolean = false;
    phoneBolean = false;
    @track formFactor = formFactorPropertyName;
    @api title = 'Obligation Details';

    //end
    loginAccepatnceDate;
    @track _wiredAppObliResponse;
    loanAppRec;
    loanStage;
    loanSubstage;
    loanStatus;
    QDEStageVisible = false;
    manualTenureValue;
    appObligaRecs;
    appObligaList;
    RTConsumerId;
    RTCommercialId;
    @track showSpinner;
    @track allRecOfApplObwithDetai;
    @track allRecOfClosedApplObwithDetai;
    BruRecord;
    @track _wiredBruData;
    @track _wiredAppName;
    @track _wiredmdtData;
    @track _wiredRTData;
    @track _wiredStageName;
    @track _wiredManualData;
    @track BRURecords = []
    @track AppNameList = []
    @track mdtNameList = []
    @track newBlankListOfAppObliRec = [];
    @track FinalManualList = []
    newManualrecord
    applIdfromName = [];

    @track obligArr = []
    @track obligArr_s = []
    @api isReadOnly;
    @track disableMode;
    @track isRequiredRTR = false;
    @api hasEditAccess;

    @track NatureOfLoanValue;
    searchResults
    selectedSearchResult
    @track delayTimeout;
    preventClosingOfSerachPanel = false;

    @api layoutSize;
    @track requiredFlag = false;
    required = true;


    @track sortedColumn;
    @track sortedDirection = "asc";
    handleSort(event) {
        console.log("column is", event.currentTarget.dataset.column);
        console.log("Object is", event.currentTarget.dataset.object);


        this.sortData(event.currentTarget.dataset.column, event.currentTarget.dataset.object);
    }

    sortData(sortColumnName, objectName) {
        if (this.sortedColumn === sortColumnName) {
            this.sortedDirection =
                this.sortedDirection === "asc" ? "desc" : "asc";
        } else {
            this.sortedDirection = "asc";
        }
        this.template.querySelectorAll('lightning-icon').forEach(ele => {
            if (ele) {
                if (ele.dataset.column == sortColumnName) {
                    if (ele.iconName === 'utility:arrowup') {
                        ele.iconName = 'utility:arrowdown';
                    } else {
                        ele.iconName = 'utility:arrowup';
                    }
                }
            }
        });

        let isReverse = this.sortedDirection === "asc" ? 1 : -1;

        this.sortedColumn = sortColumnName;

        if (objectName == 'allRecOfApplObwithDetai') {
            let shortingdata = JSON.parse(JSON.stringify(this.allRecOfApplObwithDetai));
            this.allRecOfApplObwithDetai = [];
            console.log('shortingdata is ', shortingdata);
            let shortedData = JSON.parse(JSON.stringify(shortingdata)
            ).sort((a, b) => {
                a = a[sortColumnName] ? a[sortColumnName].toLowerCase() : "";
                b = b[sortColumnName] ? b[sortColumnName].toLowerCase() : "";

                console.log("return", a > b ? 1 * isReverse : -1 * isReverse);
                return a > b ? 1 * isReverse : -1 * isReverse;
            });
            console.log('shortedData is ', shortedData);
            this.allRecOfApplObwithDetai = this.resetIndex(shortedData);
        } else if (objectName == 'newBlankListOfAppObliRec') {
            let shortingdata = JSON.parse(JSON.stringify(this.newBlankListOfAppObliRec));
            let shortedData = shortingdata.sort((a, b) => {
                a = a[sortColumnName] ? a[sortColumnName].toLowerCase() : "";
                b = b[sortColumnName] ? b[sortColumnName].toLowerCase() : "";

                console.log("return", a > b ? 1 * isReverse : -1 * isReverse);
                return a > b ? 1 * isReverse : -1 * isReverse;
            });
            this.newBlankListOfAppObliRec = this.resetIndex(shortedData);
        }

        // console.log("this.recordsToDisplay", this.newBlankListOfAppObliRec);
    }
    resetIndex(data) {
        if (data.length > 0) {
            let localData = [];
            for (let i = 0; i < data.length; i++) {
                let element = data[i];
                element.index = i + 1;
                localData.push(element);
            }
            return localData;
        }
        return [];
    }


    TreatmentOptions = []
    LoanCapacityOptions = []
    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        this.handleRecordIdChange(value);
    }

    get optionsEmiSource() {
        return [
            { label: 'Bureau', value: 'Bureau' },
            { label: 'Estimated', value: 'Estimated' },
        ];
    }
    ConsumerProduct = ['Auto Loan', 'Housing Loan', 'Property Loan', 'Loan Against Shares/Securities', 'Personal Loan', 'Consumer Loan', 'Education Loan', 'Loan to Professional', 'Leasing', 'Overdraft', 'Two-wheeler Loan', 'Loan Against Bank Deposits', 'Commercial Vehicle Loan', 'GECL Loan Secured', 'GECL Loan Unsecured', 'Used Car Loan', 'Construction Equipment Loan', 'Tractor Loan', 'Loan on Credit Card', 'Mudra Loans – Shishu / Kishor / Tarun', 'Microfinance – Business Loan', 'Microfinance – Personal Loan', 'Microfinance – Housing Loan', 'Microfinance – Other', 'P2P Personal Loan', 'P2P Auto Loan', 'P2P Education Loan', 'Business Loan – Secured', 'Business Loan – General', 'Business Loan – Priority Sector – Small Business', 'Business Loan – Priority Sector – Agriculture', 'Business Loan – Priority Sector – Others', 'Business Loan - Unsecured', 'Others', 'Other']
    CommercialProduct = ['Cash credit', 'Overdraft', 'Demand loan', 'Medium term loan (period above 1 year and up to 3 years)', 'Long term loan (period above 3 years)', 'Lease finance', 'Hire purchase', 'Commercial vehicle loan', 'Equipment financing (construction office medical)', 'Unsecured business loan', 'Short term loan (less than 1 year)', 'Auto Loan', 'Property Loan', 'Gold Loan', 'HealthCare Finance', 'Infrastructure Finance', 'GECL Loan', 'Others', 'Other'];
    handleRecordIdChange() {
        let tempParamManual = this.manualparams;
        tempParamManual.queryCriteria = ' where LoanApplication__c= \'' + this.loanAppId + '\' AND Source__c = \'Manual\' AND (RecordType.name = \'Consumer Obligation\' OR RecordType.name = \'Commercial Obligation\' ) AND Applicant__r.Type_of_Borrower__c=\'Financial\'';
        this.manualparams = { ...tempParamManual };

        let tempParamsApp = this.AppNameParam;
        tempParamsApp.queryCriteria = ' where id = \'' + this.loanAppId + '\'';
        this.AppNameParam = { ...tempParamsApp };



        let tempParamsAppDummy = this.AppNameDetailsParam;
        tempParamsAppDummy.queryCriteria = ' where LoanAppln__c= \'' + this._loanAppId + '\' AND Type_of_Borrower__c = \'Financial\'';
        this.AppNameDetailsParam = { ...tempParamsAppDummy };

        let tempLoanStageParams = this.LoanStageParam;
        tempLoanStageParams.queryCriteria = ' where id = \'' + this.loanAppId + '\'';
        this.LoanStageParam = { ...tempLoanStageParams };

        let tempParamsBru = this.paramsBru;
        tempParamsBru.queryCriteria = ' where LoanApp__c= \'' + this.loanAppId + '\' AND IsLatest__c = true';
        this.paramsBru = { ...tempParamsBru };

        this.handleAppObligDetails(null);

    }

    @track paramsSys = {
        ParentObjectName: 'LoanAppl__c',
        ChildObjectRelName: 'BureauRespDtl__r',
        parentObjFields: ['Id', 'Stage__c', 'SubStage__c', 'LoginAcceptDate__c'],
        childObjFields: ['Id', 'Remarks__c', 'Applicant__c', 'Bureau__c', 'CloseDate__c', 'ConsiderObligation__c', 'CurrentOs__c', 'DisbursalDate__c', 'EMISource__c', 'EMI__c', 'Ever90__c', 'FinancierNameID__c', 'FinancierName__c', 'LoanAmount__c', 'LoanApplication__c', 'LoanCapacity__c', 'LoanName__c', 'MaxDPDLst12month__c', 'MaxDPDLst3month__c', 'MaxDPDLst6month__c', 'NatureOfLoan__c', 'NoEMIPaid__c', 'Overdues__c', 'RepayAc__c', 'RepaymentBankID__c', 'Repayment_Bank__c', 'Source__c', 'TenureLeft__c', 'Tenure__c', 'Treatment__c'],
        queryCriteria: ' where id = \'' + this.loanAppId + '\''

    }

    @track AppNameDetailsParam = {
        ParentObjectName: 'Applicant__c',
        parentObjFields: ['Id', 'FullName__c', 'Constitution__c', 'LoanAppln__c'],
        childObjFields: [],
        //LAK-6279 financial applicant filter added
        queryCriteria: ' where LoanAppln__c= \'' + this._loanAppId + '\' AND Type_of_Borrower__c = \'Financial\''
    }

    @track AppNameParam = {
        ParentObjectName: 'LoanAppl__c',
        ChildObjectRelName: 'Applicants__r',
        parentObjFields: ['Id'],
        childObjFields: ['Id', 'FullName__c','ApplType__c', 'Constitution__c'],
        queryCriteria: ' where Id= \'' + this.loanAppId + '\''

    }

    @track mdtParam = {
        ParentObjectName: 'MultiBureau_Response_Master__mdt',
        parentObjFields: ['Loan_Type__c'],
        queryCriteria: ''

    }

    @track LoanStageParam = {
        ParentObjectName: 'LoanAppl__c',
        parentObjFields: ['Id','Name', 'Stage__c', 'Add_Another_Loan__c','Status__c' ,'LoginMonthAndYear__c', 'SubStage__c', 'LoginAcceptDate__c', 'BonceBTloanSesingless12mths__c', 'BonceBTloanSesingtreql12mths__c', 'BonceBTloanSesingtreql18mths__c', 'SchmCode__c'],
        queryCriteria: ' where Id= \'' + this.loanAppId + '\''

    }

    @track RTParam = {
        ParentObjectName: 'RecordType',
        parentObjFields: ['Id', 'Name', 'DeveloperName', 'SobjectType'],
        queryCriteria: ' where SobjectType = \'BureauRespDtl__c\' AND (DeveloperName = \'Consumer_Obligation\' OR DeveloperName = \'Commercial_Obligation\')'
    }
    @wire(fetchSingleObject, { params: '$RTParam' })
    RTData(wiredRTData) {
        const { data, error } = wiredRTData;
        this._wiredRTData = wiredRTData;
        if (data) {
            let RTData1 = JSON.parse(JSON.stringify(data.parentRecords));
            for (var i = 0; i < RTData1.length; i++) {
                if (RTData1[i].DeveloperName == 'Consumer_Obligation') {
                    this.RTConsumerId = RTData1[i].Id;
                }
                if (RTData1[i].DeveloperName == 'Commercial_Obligation') {
                    this.RTCommercialId = RTData1[i].Id;
                }

            }


        } else if (error) {
            console.log(error);
        }

    }


    //fetching third records
    @track manualparams = {
        ParentObjectName: 'BureauRespDtl__c',
        ChildObjectRelName: 'Applicant_Obligation_detail__r',
        parentObjFields: ['Id', 'Remarks__c', 'Source__c', 'EMIClearanceDate__c', 'BounceInLast12Months__c', 'BounceInLast18Months__c', 'TotalBouncesInRTR__c', 'RepaymentBankID__c', 'FinancierNameID__c', 'LoanName__c', 'EMISource__c', 'NatureOfLoan__c', 'NatureOfLoanID__c', 'FinancierName__c', 'LoanCapacity__c', 'ConsiderObligation__c', 'RepayAc__c', 'Treatment__c', 'NoEMIPaid__c', 'LoanAmount__c', 'Ever90__c', 'MaxDPDLst12month__c', 'MaxDPDLst6month__c', 'Overdues__c', 'MaxDPDLst3month__c', 'TenureLeft__c', 'Tenure__c', 'Applicant__c', 'Applicant__r.Type_of_Borrower__c', 'LoanApplication__c', 'Bureau__c', 'CloseDate__c', 'DisbursalDate__c', 'CurrentOs__c', 'Repayment_Bank__c', 'EMI__c','CreatedDate'],
        childObjFields: ['Id', 'BureauRespDtl__c','BureauRespDtl__r.Applicant__r.FullName__c','EMI_Clearance_Date_IdentifierTest__c', 'EMI_Clearance_Date_Identifier__c', 'EMI_Clearance_Date__c', 'BureauRespDtl__r.id'],
        //LAK-6279 financial applicant filter added
        queryCriteria: ' where LoanApplication__c= \'' + this.loanAppId + '\' AND Source__c = \'Manual\' AND (RecordType.name = \'Consumer Obligation\' OR RecordType.name = \'Commercial Obligation\') AND Applicant__r.Type_of_Borrower__c=\'Financial\''

    }

    @wire(getData, { params: '$manualparams' })
    ManualData(wiredManualData) {

        const { data, error } = wiredManualData;
        this._wiredManualData = wiredManualData;
        if (data) {

            this.newManualrecord = JSON.parse(JSON.stringify(data));
            //    this.newBureau='Yes';
            //         this.showNewBureauTable=true;
            

            this.newManualrecord = this.newManualrecord.map((record, index) => {
                return { ...record, index: index + 1, isDirty: false };
            });

            var parentId;

            for (const record of this.newManualrecord) {

                parentId = record.parentRecord.Id;

                if (record.ChildReords && record.ChildReords != undefined) {
                    record.ChildReords = this.handleListChild(record.ChildReords, parentId);
                } else {
                    record.ChildReords = this.handleListChildnew(record.ChildReords, parentId);
                }

            }
            let tempManualArr = [...this.newManualrecord]
            this.newBlankListOfAppObliRec = JSON.parse(JSON.stringify(tempManualArr));

            this.newBlankListOfAppObliRec = tempManualArr;


            this.totalLoanAmount_m = 0;
            this.totalCurrentOS_m = 0;
            this.totalEMI_m = 0;

            this.totalLoanAmountObligate_m = 0;
            this.totalCurrentOSObligate_m = 0;
            this.totalEMIObligate_m = 0;

            this.totalContinueObli_m = 0;
            this.obligArr = [];
            //adding total for manual table
            for (const record of this.newBlankListOfAppObliRec) {
                this.totalLoanAmount_m += record.parentRecord.LoanAmount__c == '' || record.parentRecord.LoanAmount__c == null || record.parentRecord.LoanAmount__c == undefined ? Number(0) : Number(record.parentRecord.LoanAmount__c);
                this.totalCurrentOS_m += record.parentRecord.CurrentOs__c == '' || record.parentRecord.CurrentOs__c == null || record.parentRecord.CurrentOs__c == undefined ? Number(0) : Number(record.parentRecord.CurrentOs__c);
                this.totalEMI_m += record.parentRecord.EMI__c == '' || record.parentRecord.EMI__c == null || record.parentRecord.EMI__c == undefined ? Number(0) : Number(record.parentRecord.EMI__c);


                if (record.parentRecord.Treatment__c == 'To continue - Obligate') {
                    this.totalLoanAmountObligate_m += record.parentRecord.LoanAmount__c == '' || record.parentRecord.LoanAmount__c == null || record.parentRecord.LoanAmount__c == undefined ? Number(0) : Number(record.parentRecord.LoanAmount__c);
                    this.totalCurrentOSObligate_m += record.parentRecord.CurrentOs__c == '' || record.parentRecord.CurrentOs__c == null || record.parentRecord.CurrentOs__c == undefined ? Number(0) : Number(record.parentRecord.CurrentOs__c);
                    this.totalEMIObligate_m += record.parentRecord.EMI__c == '' || record.parentRecord.EMI__c == null || record.parentRecord.EMI__c == undefined ? Number(0) : Number(record.parentRecord.EMI__c);

                    this.obligArr.push(record);
                }
                this.totalContinueObli_m = this.obligArr.length
            }
            this.oldListnewBlankListOfAppObliRec = JSON.parse(JSON.stringify(this.newBlankListOfAppObliRec));

        } else if (error) {
            console.log('Error manual :', error);
        }

    }


    @track paramsBru = {

        ParentObjectName: 'Bureau__c',
        parentObjFields: ['Id', 'LoanApp__c', 'Applicant__r.Total_Live_Loan__c', 'Applicant__r.FullName__c', 'Source__c', 'name', 'Score__c', 'Totalliveloan__c', 'Totalloanexposure__c', 'Totalsecuredloan__c', 'Totalunsecuredloan__c', 'Totalcreditcardoutstanding__c', 'Totaloanoverdue__c', 'Totalcreditcardoverdue__c', 'MaxcurrentDPDLiveFacilities__c', 'MaxDPDlast12months__c', 'TotalEnquiries__c', 'Report_date__c', 'IsLatest__c', 'Trigger_Type__c', 'TotalEnquirieslast30day__c'],
        queryCriteria: ' where LoanApp__c= \'' + this.loanAppId + '\' AND IsLatest__c = true'

    }


    //end of bureau

    renderedCallback() {
        refreshApex(this._wiredStageName);
    }

    @wire(getObjectInfo, { objectApiName: ApplObligation })
    objInfo

    generatePicklist(data) {
        return data.values.map(item => ({ label: item.label, value: item.value }))
    }

    @wire(getPicklistValues, { recordTypeId: '$objInfo.data.defaultRecordTypeId', fieldApiName: TREATMENT })
    TreatmentHandler({ data, error }) {
        if (data) {
            this.TreatmentOptions = [...this.generatePicklist(data)]
        }
        if (error) {
            console.log(JSON.stringify(error));
        }
    }

    get blankTreatmentOptions() {
        // Copy of TreatmentOptions with a blank option added
        return [
            { label: '', value: '' }, // This is the blank option
            ...this.TreatmentOptions // Spread the rest of the options
        ];
    }

    @wire(getPicklistValues, { recordTypeId: '$objInfo.data.defaultRecordTypeId', fieldApiName: LOANCAPACITY })
    TLoanCapacityHandler({ data, error }) {
        if (data) {
            this.LoanCapacityOptions = [...this.generatePicklist(data)]
        }
        if (error) {

            console.log(JSON.stringify(error));
        }
    }
    //stage of loan

    @track _loanDateRtr ;
    @track _loanAppName ;

    get loanDateRtr(){
        return this._loanDateRtr;
    }

    get loanAppName(){
        return this._loanAppName;
    }


    get disableDownloadMcaRec(){

        console.log('return value as boolean :',this.isLoginDatePresent)
        console.log('return value as loan date:',this.loanDateRtr)
        console.log('loan status',this.loanStatus)
        if(this.loanStage && this.loanStatus && (this.loanStage == 'QDE'||this.loanStatus == 'Hold'|| this.loanStatus == 'Cancelled')){
            return true;
        }
        else if(this.hasEditAccess && !this.hasEditAccess){
            return true;
        }
        else{
            return false;
        }
    }

    

    @track showDateColumn;
    @track BonceBTless12mths;
    @track BonceBTeql12mths;
    @track BonceBTeql18mths;
    @track SchmCode;
    @track showBounchBTFields = false;
    @track isLoginDatePresent=false;
    @wire(getData, { params: '$LoanStageParam' })
    StageName(wiredStageName) {
        const { data, error } = wiredStageName;
        this._wiredStageName = wiredStageName;
        let tempName = []
        let valueStage
        if (data) {
            valueStage = JSON.parse(JSON.stringify(data));
            if (valueStage.length > 0) {
                if(valueStage[0].parentRecord.LoginAcceptDate__c){
                    this.isLoginDatePresent=true;
                }
                this.loginAccepatnceDate = valueStage[0].parentRecord.LoginAcceptDate__c;
                this.BonceBTless12mths = valueStage[0].parentRecord.BonceBTloanSesingless12mths__c;
                this.BonceBTeql12mths = valueStage[0].parentRecord.BonceBTloanSesingtreql12mths__c;
                this.BonceBTeql18mths = valueStage[0].parentRecord.BonceBTloanSesingtreql18mths__c;
                this.SchmCode = valueStage[0].parentRecord.SchmCode__c;
                this.newBureau = valueStage[0].parentRecord.Add_Another_Loan__c;
                if (this.newBureau == 'Yes') {
                    this.showNewBureauTable = true;
                }
                if (typeof valueStage[0].parentRecord.LoginMonthAndYear__c !== 'undefined') {
                    this.showDateColumn = true;
                    var loginMonthNdYear = valueStage[0].parentRecord.LoginMonthAndYear__c;
                    this._loanDateRtr= valueStage[0].parentRecord.LoginMonthAndYear__c;
                    this._loanAppName = valueStage[0].parentRecord.Name;
                    setTimeout(() => {
                        this.handleMonthAndYearHeaderWihRec(loginMonthNdYear);
                        this.handleMonYearForNewList(loginMonthNdYear);
                        setTimeout(() => {
                            this.oldListnewBlankListOfAppObliRec = JSON.parse(JSON.stringify(this.newBlankListOfAppObliRec));
                        }, 300);


                    }, 1000);

                } else {
                    this.showDateColumn = false;
                }
                this.loanStage = valueStage[0].parentRecord.Stage__c;
                this.loanSubstage = valueStage[0].parentRecord.SubStage__c;
                this.loanStatus = valueStage[0].parentRecord.Status__c;
                if (this.loanStage == 'QDE' && (this.loanSubstage == 'RM Data Entry' || this.loanSubstage == 'Pre Login Query' || this.loanSubstage == 'Pre login Query')) {
                    this.QDEStageVisible = true;
                }
                if (typeof valueStage[0].parentRecord.SchmCode__c !== 'undefined' && this.SchmCode.includes("BT") && this.loanStage !== 'QDE') {
                    this.showBounchBTFields = true;
                }
                else {
                    this.showBounchBTFields = false;
                }
            }

        }

        else if (error) {
            console.log(error);
        }

    }
    @track tempArrAppConst = []


    @track _wiredAppNameDetail;
    @track applObligationArr;

    @wire(getData, { params: '$AppNameDetailsParam' })
    ApplicantNameDetail(wiredAppNameDetailsData) {
        const { data, error } = wiredAppNameDetailsData;
        this._wiredAppNameDetail = wiredAppNameDetailsData;
        let applObligation =[];
        if (data) {

            let AppNameListVariable = data.map(item => ({
                label: item.parentRecord.FullName__c,
                value: item.parentRecord.Id
            }));

            this.AppNameList = [...AppNameListVariable];
            data.forEach(item => {
                let tempAppConst = {};
                tempAppConst.Id=item.parentRecord.Id;
                tempAppConst.FullName__c = item.parentRecord.FullName__c;
                tempAppConst.Constitution__c = item.parentRecord.Constitution__c;
                this.tempArrAppConst.push(tempAppConst);
                applObligation.push(tempAppConst.FullName__c);
            });
        } else if (error) {
            console.log(error);
        }

        this.applObligationArr= applObligation;

    }

    get getApplObligationArr(){
        return this.applObligationArr;
    }


    @track _primaryApplicantId;
  @api get applicantId() {
    return this._primaryApplicantId;
  }
  set applicantId(value) {
    this._primaryApplicantId = value;
    this.setAttribute("applicantId", value);

    this.handleAddrRecordChange(value);
  }

  handleAddrRecordChange(event) {
    // let tempParams = this.appAddrParam;
    // tempParams.queryCriteria =
    //   "  where Applicant__c = '" + this._applicantId + "'";
    // this.appAddrParam = { ...tempParams };

    let tempParamsApp = this.AppNameParam;
    tempParamsApp.queryCriteria = ' where id = \'' + this.loanAppId + '\'';
    this.AppNameParam = { ...tempParamsApp };
  }

    @track  res=[];
    @track _wiredAppNametype;
    @track primaryApplicantId;
    @wire(getData, { params: '$AppNameParam' })
    ApplicantNameDetailType(wiredAppNameDetailsDatatype) {
        const { data, error } = wiredAppNameDetailsDatatype;
        this._wiredAppNametype = wiredAppNameDetailsDatatype;

        if (data) {            
            console.log('primary appln data ',JSON.stringify(data[0].ChildReords))
            
            if (data[0].ChildReords && data[0].ChildReords != undefined) {
               
                this.res = JSON.parse(JSON.stringify(data[0].ChildReords));
               
            console.log('primary appln data res',this.res)
            for (var i = 0; i < this.res.length; i++) {
                if(this.res[i].ApplType__c=='P'){
                    this.primaryApplicantId=this.res[i].Id;
                    console.log('primary appln data id',this.primaryApplicantId)
                }
            }
        }
        } else if (error) {
            console.log(error);
        }

    }
    get AppNameListValue() {
        return this.AppNameList;
    }

    //end
    //nature of loan
    @wire(fetchSingleObject, { params: '$mdtParam' })
    mdtData(wiredmdtData) {
        const { data, error } = wiredmdtData;
        this._wiredmdtData = wiredmdtData;

        if (data) {

            this.mdtNames = JSON.parse(JSON.stringify(data.parentRecords));
            console.log('got meta data :',this.mdtNames)
            let temparray = []
            for (var i = 0; i < this.mdtNames.length; i++) {

                let mdtnameObj = { label: "", value: "" }
                mdtnameObj.label = this.mdtNames[i].Loan_Type__c;
                mdtnameObj.value = this.mdtNames[i].Loan_Type__c;
                temparray.push(mdtnameObj);

            }
            this.mdtNameList = [...temparray];
        }

        if (error) {
            console.log(error);
        }

    }

    get LoanTypeValue() {

        return this.mdtNameList;
    }
    //end

    @wire(fetchRecords, { params: '$paramsSys' })
    BureauResponse(wiredAppObliResponse) {
        const { data, error } = wiredAppObliResponse;
        this._wiredAppObliResponse = wiredAppObliResponse;
        if (data) {
            this.loanAppRec = JSON.parse(JSON.stringify(data.parentRecord));
            this.loginAccepatnceDate = this.loanAppRec.LoginAcceptDate__c;

            if (data.ChildReords && data.ChildReords != undefined) {
                //this.isRequiredRTR = true; 
                this.appObligaRecs = JSON.parse(JSON.stringify(data.ChildReords));
                this.appObligaList = this.appObligaRecs.map((record, index) => {
                    return { ...record, index: index + 1 };
                });
                var appObligDetailIds = [];
                for (const record of this.appObligaList) {
                    appObligDetailIds.push(record.Id);
                }
                this.handleAppObligDetails(appObligDetailIds)
            } else {
                this.appObligaRecs = [];
                this.appObligaList = [];
                //this.isRequiredRTR = false; 
            }
        } else if (error) {
            console.log('error' + error);
                    }
    }
    listOfallRecOfApplObwithDetai = [];
    listOfClosedLoanRecObwithDetai = [];
    @track parentIdForObliga1;

    handleAppObligDetails(listOfAppOblDetaIds) {
        const mapOfAppBankIdWithDetail = new Map();
        //adding let params
        let currentDate = new Date().toISOString().substring(0, 10);

        let noOfemiCal
        let params = {
            ParentObjectName: 'BureauRespDtl__c',
            ChildObjectRelName: 'Applicant_Obligation_detail__r',
            parentObjFields: ['Id', 'Remarks__c', 'Source__c', 'Applicant__r.FullName__c','CreatedDate', 'Applicant__r.Type_of_Borrower__c', 'EMIClearanceDate__c', 'BounceInLast12Months__c', 'BounceInLast18Months__c', 'TotalBouncesInRTR__c', 'Repayment_Bank__c', 'RepaymentBankID__c', 'LoanName__c', 'EMISource__c', 'NatureOfLoan__c', 'FinancierName__c', 'LoanCapacity__c', 'ConsiderObligation__c', 'RepayAc__c', 'Treatment__c', 'NoEMIPaid__c', 'LoanAmount__c', 'Ever90__c', 'MaxDPDLst12month__c', 'MaxDPDLst6month__c', 'Overdues__c', 'MaxDPDLst3month__c', 'TenureLeft__c', 'Tenure__c', 'Applicant__c', 'LoanApplication__c', 'Bureau__c', 'CloseDate__c', 'DisbursalDate__c', 'CurrentOs__c', 'EMI__c', 'Status__c', 'FinancierNameID__c'],
            childObjFields: ['Id', 'EMI_Clearance_Date_IdentifierTest__c', 'BureauRespDtl__c', 'EMI_Clearance_Date_Identifier__c', 'EMI_Clearance_Date__c', 'BureauRespDtl__r.id'],
            queryCriteria: ' WHERE LoanApplication__c = \'' + this._loanAppId + '\' AND Source__c != \'Manual\' AND ((RecordType.name = \'Consumer Obligation\' AND NatureOfLoan__c IN  (\'' + this.ConsumerProduct.join('\', \'') + '\'))OR (RecordType.name = \'Commercial Obligation\' AND  CrdFacType__c = \'Current\' AND NatureOfLoan__c IN  (\'' + this.CommercialProduct.join('\', \'') + '\'))) AND Applicant__r.Type_of_Borrower__c=\'Financial\''
            //LAK-6279 financial applicant filter added in above query

        }

        console.log('params ==',params)
        // getData({ params: params })
        getDatawithoutCache({ params: params })
            .then((data) => {
                let tempArr = [];
                let Arr = []
                let arrClosedLoans = [] //Closed Loans
                this.allRecOfApplObwithDetai = JSON.parse(JSON.stringify(data));
                tempArr = JSON.parse(JSON.stringify(data));

                for (var i = 0; i < tempArr.length; i++) {
                    let CloseDate__c = tempArr[i].parentRecord.CloseDate__c;
                    let Treatment=tempArr[i].parentRecord.Treatment__c;
                    let obligCreatedDate = tempArr[i].parentRecord.CreatedDate;
                    let c1 = new Date(obligCreatedDate).getFullYear() - new Date(CloseDate__c).getFullYear();
                    let c2 = (new Date(obligCreatedDate).getMonth() - new Date(CloseDate__c).getMonth());
                    let closeCal = (((c1) * 12) + (c2));
                    if (closeCal <= 12 || CloseDate__c == undefined ) {
                        // Arr.push(tempArr[i])
                        if (CloseDate__c != undefined || Treatment=='Already closed') {
                            tempArr[i].parentRecord.iscloseRequired = false;
                        }
                        else {
                            if(Treatment=='Already closed'){
                                tempArr[i].parentRecord.iscloseRequired = false;
                            }
                            tempArr[i].parentRecord.iscloseRequired = true;
                        }
                        Arr.push(tempArr[i])
                        console.log('isclose wire', tempArr[i].parentRecord.iscloseRequired);
                    }
                    else {
                        
                        arrClosedLoans.push(tempArr[i]);
                    }
                   
                }
                console.log('Arr closedate required working', Arr);
                this.allRecOfApplObwithDetai = [...Arr];
                this.allRecOfApplObwithDetai = this.allRecOfApplObwithDetai.map((record, index) => {
                    return { ...record, index: index + 1 };
                });

                this.allRecOfClosedApplObwithDetai = [...arrClosedLoans]
                this.allRecOfClosedApplObwithDetai = this.allRecOfClosedApplObwithDetai.map((record, index) => {
                    return { ...record, index: index + 1 };
                });


                var parentId;

                for (const record of this.allRecOfApplObwithDetai) {

                    parentId = record.parentRecord.Id;
                    this.parentIdForObliga = record.parentRecord.Id;


                    if (record.ChildReords && record.ChildReords != undefined) {
                        record.ChildReords = this.handleListChild(record.ChildReords, parentId);
                    } else {
                        record.ChildReords = this.handleListChildnew(record.ChildReords, parentId);
                    }

                }


                var parentId1;
                for (const record of this.allRecOfClosedApplObwithDetai) {

                    parentId1 = record.parentRecord.Id;
                    this.parentIdForObliga1 = record.parentRecord.Id;


                    if (record.ChildReords && record.ChildReords != undefined) {
                        record.ChildReords = this.handleListChild(record.ChildReords, parentId1);
                    } else {
                        record.ChildReords = this.handleListChildnew(record.ChildReords, parentId1);
                    }

                }


                
                this.handleCalculation();
                this.handleCalculationClosedLoan();
                this.listOfallRecOfApplObwithDetai = JSON.parse(JSON.stringify(this.allRecOfApplObwithDetai));
                this.listOfClosedLoanRecObwithDetai = JSON.parse(JSON.stringify(this.allRecOfClosedApplObwithDetai));

            })
            .catch(error => {
                console.log('Errorured:- ' + JSON.stringify(error));
            });


        console.log('Arr closedate required this', this.allRecOfApplObwithDetai);

    }


    monthList = ['Month0', 'Month1', 'Month2', 'Month3', 'Month4', 'Month5', 'Month6', 'Month7', 'Month8', 'Month9', 'Month10', 'Month11', 'Month12']
    handleListChild(listOfAllChildReco, parentId) {
        const mapOfmonthWithRec = {};
        for (let i = 0; i < listOfAllChildReco.length; i++) {
            let record = listOfAllChildReco[i];
            let emiIdentifier = record.EMI_Clearance_Date_Identifier__c;
            if (emiIdentifier && emiIdentifier !== "") {
                mapOfmonthWithRec[emiIdentifier] = record;
            }
        }
        var newListOfChilds = [];
        for (const record of this.monthList) {
            if (mapOfmonthWithRec.hasOwnProperty(record)) {
                newListOfChilds.push(mapOfmonthWithRec[record]);
            } else {
                let temp = { "BureauRespDtl__c": parentId, "EMI_Clearance_Date_Identifier__c": record, "EMI_Clearance_Date__c": "", "EMI_Clearance_Date_IdentifierTest__c": "" };
                newListOfChilds.push(temp);
            }
        }
        listOfAllChildReco = newListOfChilds;
        return listOfAllChildReco;
    }

    handleListChildnew(listOfAllChildReco, parentId) {
        const mapOfmonthWithRec = {};
        var newListOfChilds = [];
        for (const record of this.monthList) {
            if (mapOfmonthWithRec.hasOwnProperty(record)) {
                newListOfChilds.push(mapOfmonthWithRec[record]);
            } else {
                let temp = { "BureauRespDtl__c": parentId, "EMI_Clearance_Date_Identifier__c": record, "EMI_Clearance_Date__c": "", "EMI_Clearance_Date_IdentifierTest__c": "" };
                newListOfChilds.push(temp);
            }
        }
        listOfAllChildReco = newListOfChilds;
        return listOfAllChildReco;
    }


    totalLoanCapacity = 0;
    totalLoanAmount = 0 
    totalCurrentOS = 0
    totalEMI = 0;

    //Closed Loans
    totalLoanCapacityClosedL = 0;
    totalLoanAmountClosedL = 0 
    totalCurrentOSClosedL = 0
    totalEMIClosedL = 0;


    grandCurrentOS = 0
    grandLoanAmount = 0;
    grandEMI = 0;
    grandObligatory = 0;


    totalLoanAmount_m = 0
    totalEMI_m = 0;
    totalRepayAc = 0;
    totalCurrentOS_m = 0;

    //Closed Loans

    @track closedLoanActiveSection = [''] //Closed Loans Summary
    totalLoanAmountClosedL_m = 0
    totalEMIClosedL_m = 0;
    totalRepayAcClosedL = 0;
    totalCurrentOSClosedL_m = 0;

    totalLoanAmountObligate = 0;
    totalCurrentOSObligate = 0;
    totalEMIObligate = 0;

    totalLoanAmountObligate_m = 0;
    totalCurrentOSObligate_m = 0;
    totalEMIObligate_m = 0;

    totalContinueObli = 0;
    totalContinueObli_m = 0;

    get LoanAmountCal() {
        return this.grandLoanAmount = this.totalLoanAmountObligate_m + this.totalLoanAmountObligate;

    }
    get OSAmountCal() {
        return this.grandCurrentOS = this.totalCurrentOSObligate_m + this.totalCurrentOSObligate;

    }
    get EMICal() {
        return this.grandEMI = this.totalEMIObligate_m + this.totalEMIObligate;
    }
    get ObligCal() {
        return this.grandObligatory = this.totalContinueObli_m + this.totalContinueObli;


    }
    handleCalculation() {

        var ContinueObliList = [];
        for (const record of this.allRecOfApplObwithDetai) {
            if (record.parentRecord.Treatment__c == 'To continue - Obligate') {
                record.parentRecord.ConsiderObligation__c = 'Yes';
                ContinueObliList.push(record);
            } else {
                record.parentRecord.ConsiderObligation__c = 'No';
            }

            this.totalContinueObli = ContinueObliList.length
        }
        for (const record of this.allRecOfApplObwithDetai) {
            this.totalLoanAmount += record.parentRecord.LoanAmount__c == '' || record.parentRecord.LoanAmount__c == null || record.parentRecord.LoanAmount__c == undefined ? Number(0) : Number(record.parentRecord.LoanAmount__c);
            this.totalCurrentOS += record.parentRecord.CurrentOs__c == '' || record.parentRecord.CurrentOs__c == null || record.parentRecord.CurrentOs__c == undefined ? Number(0) : Number(record.parentRecord.CurrentOs__c);
            this.totalEMI += record.parentRecord.EMI__c == '' || record.parentRecord.EMI__c == null || record.parentRecord.EMI__c == undefined ? Number(0) : Number(record.parentRecord.EMI__c);
            this.totalRepayAc += record.parentRecord.RepayAc__c == '' || record.parentRecord.RepayAc__c == null || record.parentRecord.RepayAc__c == undefined ? Number(0) : Number(record.parentRecord.RepayAc__c);

            if (record.parentRecord.Treatment__c == 'To continue - Obligate') {
                this.obligArr_s.push(record);
                this.totalLoanAmountObligate += record.parentRecord.LoanAmount__c == '' || record.parentRecord.LoanAmount__c == null || record.parentRecord.LoanAmount__c == undefined ? Number(0) : Number(record.parentRecord.LoanAmount__c);
                this.totalCurrentOSObligate += record.parentRecord.CurrentOs__c == '' || record.parentRecord.CurrentOs__c == null || record.parentRecord.CurrentOs__c == undefined ? Number(0) : Number(record.parentRecord.CurrentOs__c);
                this.totalEMIObligate += record.parentRecord.EMI__c == '' || record.parentRecord.EMI__c == null || record.parentRecord.EMI__c == undefined ? Number(0) : Number(record.parentRecord.EMI__c);

            }


            this.totalContinueObli = this.obligArr_s.length

        }
    }

    //Calculation for closed loans

    handleCalculationClosedLoan() {
        
        var ContinueObliList1 = [];
        for (const record of this.allRecOfClosedApplObwithDetai) {
            
            this.totalLoanAmountClosedL += record.parentRecord.LoanAmount__c == '' || record.parentRecord.LoanAmount__c == null || record.parentRecord.LoanAmount__c == undefined ? Number(0) : Number(record.parentRecord.LoanAmount__c);
            this.totalCurrentOSClosedL += record.parentRecord.CurrentOs__c == '' || record.parentRecord.CurrentOs__c == null || record.parentRecord.CurrentOs__c == undefined ? Number(0) : Number(record.parentRecord.CurrentOs__c);
            this.totalEMIClosedL += record.parentRecord.EMI__c == '' || record.parentRecord.EMI__c == null || record.parentRecord.EMI__c == undefined ? Number(0) : Number(record.parentRecord.EMI__c);
            this.totalRepayAcClosedL += record.parentRecord.RepayAc__c == '' || record.parentRecord.RepayAc__c == null || record.parentRecord.RepayAc__c == undefined ? Number(0) : Number(record.parentRecord.RepayAc__c);

        }
    }

    rowIndex;
    cloumnIndex;
    handleRowClick(event) {
        const rowIndex = event.currentTarget.dataset.rowIndex;
        this.rowIndex = rowIndex;

    }
    handleColumnClick(event) {
        this.cloumnIndex = event.currentTarget.dataset.cloumnIndex;
    }
    handleLoginAceptanceDate(event) {
        let newDate = event.target.value;
        const date1 = new Date(newDate);
        var oldDate = this.loginAccepatnceDate
        const date2 = new Date(this.loginAccepatnceDate);
        const monthMap = { 0: 'January', 1: 'February', 2: 'March', 3: 'April', 4: 'May', 5: 'June', 6: 'July', 7: 'August', 8: 'September', 9: 'October', 10: 'November', 11: 'December', };
        const monthName = monthMap[date2.getMonth()];
        if (date1.getMonth() !== date2.getMonth()) {

            this.showToast("Error!", "error", this.customLabel.ObligationBanking_EmiDate_ErrroMessage + monthName, "sticky");
            this.loginAccepatnceDate = oldDate
        } else {
            let obligatoryDetails = this.newBlankListOfAppObliRec[event.target.dataset.index]
            obligatoryDetails.parentRecord[event.target.dataset.field] = event.target.value;
            obligatoryDetails.isDirty = true;
            this.newBlankListOfAppObliRec[event.target.dataset.index] = obligatoryDetails;
        }
    }

    showToast(title, variant, message, mode) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    handleDateChange(event) {

        if (event.target.value > 31 && event.target.value < 1) {
            this.showToast("Error!", "error", "can be between 1 to 31.", "sticky");
        } else {
            let parentIndex = event.target.dataset.parentIndex;
            let childIndex = event.target.dataset.cloumnIndex;
            let parentRecord = this.allRecOfApplObwithDetai[parentIndex];
            let childRecords = parentRecord.ChildReords[childIndex];
            let fieldName = event.target.dataset.field;
            childRecords[fieldName] = event.target.value;
        }


    }

    handleManualDateChange(event) {

        let parentIndex = event.target.dataset.parentIndex;
        let childIndex = event.target.dataset.cloumnIndex;
        let parentRecord = this.newBlankListOfAppObliRec[parentIndex];
        let childRecords = parentRecord.ChildReords[childIndex];
        let fieldName = event.target.dataset.field;
        childRecords[fieldName] = event.target.value;
        this.newBlankListOfAppObliRec[parentIndex].isDirty = true;


    }
    @track maxDate;
    
    async connectedCallback() {

        await loadScript(this, SheetJS1); // load the library
       
        //await loadData()
        this.version = XLSX.version;
        console.log('version: '+this.version);  

        if (this.hasEditAccess === false) {
            this.disableMode = true;
        }
        this.scribeToMessageChannel();

        if (this.formFactor == "Large") {
            this.desktopBoolean = true;
            this.phoneBolean = false;
        } else if (this.formFactor == "Small") {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        } else {

            this.desktopBoolean = false;
            this.phoneBolean = true;
        }
        refreshApex(this._wiredStageName);
        const today = new Date();
        this.maxDate = this.formatDateForInput(today);
    }

    formatDateForInput(date) {
        const year = date.getFullYear();
        const month = ('0' + (date.getMonth() + 1)).slice(-2);
        const day = ('0' + date.getDate()).slice(-2);
        return `${year}-${month}-${day}`;
    }
    @wire(MessageContext)
    MessageContext;
    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }
    handleSaveThroughLms(values) {

        this.handleSaveV(values.validateBeforeSave);

    }

    validateForm() {
        let isValid = true

        //LAK-7705
        /////////
        const allRecOfApplObwithDetaiSize = this.allRecOfApplObwithDetai.length; 
        const latestRTRMonthInput = this.template.querySelector('lightning-input[data-id="startDate"]'); 
        const latestRTRMonthValue = latestRTRMonthInput ? latestRTRMonthInput.value : ''; 
        const newBlankListOfAppObliRecSize = this.newBlankListOfAppObliRec.length; 

        //LAK-9942
        if ((allRecOfApplObwithDetaiSize || newBlankListOfAppObliRecSize) > 0 && !latestRTRMonthValue && ! this.QDEStageVisible) {
            isValid = false;
            
            if (latestRTRMonthInput) {
                latestRTRMonthInput.setCustomValidity('Please fill the Latest RTR Month');
                //latestRTRMonthInput.reportValidity(); 
            }
        }
        else {
            
            if (latestRTRMonthInput) {
                latestRTRMonthInput.setCustomValidity('');
            }
        }
        
        if (latestRTRMonthInput) {
            latestRTRMonthInput.reportValidity();
        }

        ///////

        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {

            } else {
                isValid = false;
                //element.setCustomValidity('Please fill the valid value')
            }


        });
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if (element.reportValidity()) {

            } else {
                isValid = false;
                element.setCustomValidity('Please fill the valid value')
            }

        });

        let customValidate = this.checkValidityLookup();


        return isValid && customValidate
    }
    handleSaveV(validate) {
        if (validate) {
            let isInputCorrect = this.validateForm();


            if (isInputCorrect === true) {
                this.handleSave();

            } else {
                this.errorMessage();
            }
        } else {
            this.handleSave();
        }

    }

    filteredRec = [];
    handleSaveBounceBT() {
        let fields = {};
        fields = {
            Id: this.loanAppId,
            BonceBTloanSesingless12mths__c: this.BonceBTless12mths,
            BonceBTloanSesingtreql12mths__c: this.BonceBTeql12mths,
            BonceBTloanSesingtreql18mths__c: this.BonceBTeql18mths
        }
        this.filteredRec = [fields];
        if (this.filteredRec) {
            upsertMultipleRecord({
                params: this.filteredRec
            })
                .then(result => {
                    refreshApex(this._wiredStageName);
                }).catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: error.body.message,
                            variant: 'error',
                            mode: 'sticky'
                        })

                    );
                })
        }
    }
    handleSave(event) {
        this.handleSaveBounceBT();
        let DataRecords = [];
        let DataRecordObj = {};
        let ChildRecordObj = {};
        for (var i = 0; i < this.newBlankListOfAppObliRec.length; i++) {

            if (this.newBlankListOfAppObliRec[i].isDirty != false) {


                DataRecordObj = {};
                ChildRecordObj = {};

                DataRecordObj.parentRecord = this.newBlankListOfAppObliRec[i].parentRecord;
                DataRecordObj.parentRecord.sobjectType = 'BureauRespDtl__c';


                let ChildRecordArr = [];
                for (var j = 0; j < this.newBlankListOfAppObliRec[i].ChildReords.length; j++) {
                    ChildRecordObj = this.newBlankListOfAppObliRec[i].ChildReords[j];
                    ChildRecordObj.sobjectType = 'Applicant_Obligation_detail__c';
                    ChildRecordArr.push(ChildRecordObj);
                }

                DataRecordObj.ChildRecords = ChildRecordArr;
                DataRecordObj.ParentFieldNameToUpdate = 'BureauRespDtl__c';

                DataRecords.push(DataRecordObj);
            }



        }


        upsertManualRecord({ upsertData: DataRecords })
            .then(result => {

                this.showMessage();
                refreshApex(this._wiredManualData);


            }).catch(error => {
                console.log('739' + JSON.stringify(error));
            })

        let params = []
        this.allRecOfApplObwithDetai = this.allRecOfApplObwithDetai.map(record => {
            if (record.parentRecord) {
                record.ChildReords = record.ChildReords.filter(childRecord =>
                    childRecord.EMI_Clearance_Date__c !== "" || !childRecord.isDummy
                );
            }
            return record;

        });

        var parentList = [];
        var childList = [];
        this.allRecOfApplObwithDetai.forEach(record => {
            parentList.push(record.parentRecord);

            if (record.hasOwnProperty('ChildReords')) {
                childList = childList.concat(record.ChildReords);
            }

        });
        upsertMultipleRecord({ params: parentList })
            .then(result => {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: this.customLabel.ObligationBanking_Update_SuccessMessage,
                        variant: "success",
                        mode: 'sticky'
                    })
                );

            }).catch(error => {
                console.log('778' + error)
            })


        const newList = childList.map(item => {
            const newItem = { ...item };
            delete newItem.Applicant_Obligation__r;
            delete newItem.isDummy;
            return newItem;
        });
        var recordsWithId = [];
        var recordsWithoutId = [];
        newList.forEach(record => {
            if (record.Id) {
                recordsWithId.push(record);
            } else {
                recordsWithoutId.push(record);
            }

        });
        if (recordsWithId.length > 0) {
            upsertMultipleRecord({ params: recordsWithId })
                .then(result => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: this.customLabel.ObligationBanking_Update_SuccessMessage,
                            variant: "success",
                            mode: 'sticky'
                        })
                    );

                }).catch(error => {

                    console.log('811' + error)
                })
        }
        if (recordsWithoutId.length > 0) {
            insertMultipleRecord({ params: recordsWithoutId })
                .then(result => {

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: this.customLabel.ObligationBanking_Update_SuccessMessage,
                            variant: "success",
                            mode: 'sticky'
                        })
                    );

                }).catch(error => {

                    console.log('835' + error)
                })
        }
        this.liveLoanCal()
        this.updateLoanAppRec();
        this.deleteExtraMonthRec();
        this.listOfallRecOfApplObwithDetai = JSON.parse(JSON.stringify(this.allRecOfApplObwithDetai));
        refreshApex(this._wiredManualData);


    }
    deleteExtraMonthRec() {
        var listOfRecWithId = [];
        if (this.listForDelete.length > 0) {
            for (const record of this.listForDelete) {
                if (typeof record.Id !== 'undefined' && record.Id) {

                    listOfRecWithId.push(record)
                }
            }

        }
        if (this.listForDeleteforNewList.length > 0) {
            for (const record of this.listForDeleteforNewList) {
                if (typeof record.Id !== 'undefined' && record.Id) {

                    listOfRecWithId.push(record)
                }
            }

        }
        const newList = listOfRecWithId.map(item => {
            const newItem = { ...item };
            return newItem;
        })
        deleteAllRecord({ rcrds: newList })
            .then(result => {

            })
            .catch(error => {
                console.error(error);
            });

    }
    updateLoanAppRec() {
        const fields = {};
        fields[LOAN_APP_ID.fieldApiName] = this.loanAppId;
        fields[LOGIN_DATE.fieldApiName] = this.monthAndYearvalue;
        fields[ADD_ANOTHER_LOAN.fieldApiName] = this.newBureau
        const recordInput = { fields };
        updateRecord(recordInput)
            .then((result) => {


            })
            .catch(error => {
            });

    }

    showMessage() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Success",
                message: this.customLabel.ObligationBanking_Update_SuccessMessage,
                variant: "success",
                mode: 'sticky'
            }))
    }

    errorMessage() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Error",
                message: this.customLabel.ObligationBanking_ReqFields_ErrorMessage,
                variant: "error",
                mode: 'sticky'
            }))
    }



    @track newBureau;
    showNewBureauTable = false;

    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }



    handleNewBureauAddition(event) {
        const inputBox = event.currentTarget;

        inputBox.setCustomValidity('');
        inputBox.reportValidity();
        this.newBureau = event.target.value;
        if (this.newBureau == 'Yes') {
            this.showNewBureauTable = true;
            //this.isRequiredRTR = true; 
            if (this.newManualrecord && this.newManualrecord != undefined && this.newManualrecord.length != 0) {


                let tempManualArr = [...this.newManualrecord]
                this.newBlankListOfAppObliRec = JSON.parse(JSON.stringify(tempManualArr));
                this.newBlankListOfAppObliRec = tempManualArr;
                this.oldListnewBlankListOfAppObliRec = tempManualArr;

                this.FinalManualList = JSON.stringify(this.newBlankListOfAppObliRec);


            }
            else {
                // this.handleAddNewRows();

                if (this.newBlankListOfAppObliRec.length == 0) {
                    this.handleAddLoan();
                }
            }

        } else {
            if(this.newBlankListOfAppObliRec.length != 0){
                this.newBureau = 'Yes';
                event.target.value = 'Yes';
                event.preventDefault();
                this.showToast("Error!", "error", "Please delete the Manual Obligations before changing the field to No", "sticky");
            }
            else {
                //this.isRequiredRTR = false; 
                this.showNewBureauTable = false;
            }
        }
    }
    handleAddNewRows() {

        const newRec = {
            "ChildReords": [
                {
                    "BureauRespDtl__c": "",
                    "EMI_Clearance_Date_Identifier__c": "Month0",
                    "EMI_Clearance_Date__c": "",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c'
                },
                {
                    "BureauRespDtl__c": "",
                    "EMI_Clearance_Date_Identifier__c": "Month1",
                    "EMI_Clearance_Date__c": "",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c'
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month2",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "EMI_Clearance_Date__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c'
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month3",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "EMI_Clearance_Date__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c'
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month4",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "EMI_Clearance_Date__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c'
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month5",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "EMI_Clearance_Date__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c'
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month6",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "EMI_Clearance_Date__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c'
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month7",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "EMI_Clearance_Date__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c'
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month8",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "EMI_Clearance_Date__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c'
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month9",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "EMI_Clearance_Date__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c'
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month10",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "EMI_Clearance_Date__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c'
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month11",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "EMI_Clearance_Date__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c'
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month12",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "EMI_Clearance_Date__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c'
                },

            ],
            "parentRecord": {
                "Source__c": "",
                "LoanName__c": "",
                "EMISource__c": "",
                "NatureOfLoan__c": "",
                "FinancierName__c": "",
                "LoanCapacity__c": "",
                "ConsiderObligation__c": "",
                "RepayAc__c": "",
                "Treatment__c": "",
                "NoEMIPaid__c": "",
                "LoanAmount__c": "",
                "Ever90__c": "",
                "MaxDPDLst12month__c": "",
                "MaxDPDLst6month__c": "",
                "Overdues__c": "",
                "MaxDPDLst3month__c": "",
                "TenureLeft__c": "",
                "Tenure__c": "",
                "Applicant__c": "",
                "LoanApplication__c": this.loanAppId,
                "CloseDate__c": "",
                "DisbursalDate__c": "",
                "CurrentOs__c": "",
                "EMI__c": "",
                "RecordTypeId": "",
                "EMIClearanceDate__c": "",
                "sobjectType": 'BureauRespDtl__c',


            },

            "isDirty": false,

            "ParentFieldApiNameToUpdate": "BureauRespDtl__c"

        }

        var testList = [];

        testList.push(newRec);

        this.newBlankListOfAppObliRec = testList;

        this.newBlankListOfAppObliRec = this.newBlankListOfAppObliRec.map((record, index) => {
            return { ...record, index: index + 1 };
        });
        this.oldListnewBlankListOfAppObliRec = this.newBlankListOfAppObliRec;

    }
    handleNewDataRec() {

    }

    validateNegative = false;
    handleBounceData(event) {

        const inputBox = event.currentTarget;

        inputBox.setCustomValidity('');
        inputBox.reportValidity();

        let tempArr = this.allRecOfApplObwithDetai[event.target.dataset.index];

        const positiveNumberPattern = /^[0-9]\d*$/;
        if (event.target.dataset.field == 'BounceInLast18Months__c' || event.target.dataset.field == 'BounceInLast12Months__c' || event.target.dataset.field == 'TotalBouncesInRTR__c' || event.target.dataset.field == 'CurrentOs__c' || event.target.dataset.field == 'EMI__c' || event.target.dataset.field == 'RepayAc__c' || event.target.dataset.field == 'Overdues__c' || event.target.dataset.field == 'TenureLeft__c') {
            if (!positiveNumberPattern.test(event.target.value)) {

                this.showToast("Error!", "error", this.customLabel.ObligationBanking_value_ErrorMessage, "sticky");
            } else {

                tempArr.parentRecord[event.target.dataset.field] = event.target.value;
                this.allRecOfApplObwithDetai[event.target.dataset.index] = tempArr;
                this.totalCurrentOS = 0;
                this.totalEMI = 0;
                this.totalCurrentOSObligate = 0;
                this.totalEMIObligate = 0;
                for (const record of this.allRecOfApplObwithDetai) {

                    this.totalCurrentOS += record.parentRecord.CurrentOs__c == '' || record.parentRecord.CurrentOs__c == null || record.parentRecord.CurrentOs__c == undefined ? Number(0) : Number(record.parentRecord.CurrentOs__c);
                    this.totalEMI += record.parentRecord.EMI__c == '' || record.parentRecord.EMI__c == null || record.parentRecord.EMI__c == undefined ? Number(0) : Number(record.parentRecord.EMI__c);

                    if (record.parentRecord.Treatment__c == 'To continue - Obligate') {

                        this.totalCurrentOSObligate += record.parentRecord.CurrentOs__c == '' || record.parentRecord.CurrentOs__c == null || record.parentRecord.CurrentOs__c == undefined ? Number(0) : Number(record.parentRecord.CurrentOs__c);
                        this.totalEMIObligate += record.parentRecord.EMI__c == '' || record.parentRecord.EMI__c == null || record.parentRecord.EMI__c == undefined ? Number(0) : Number(record.parentRecord.EMI__c);

                    }

                }

            }
        }
        else if (event.target.dataset.field == 'Tenure__c' || event.target.dataset.field == 'NoEMIPaid__c') {
            if (!positiveNumberPattern.test(event.target.value)) {

                this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.TenureLeft__c = ''

                this.showToast("Error!", "error", this.customLabel.ObligationBanking_value_ErrorMessage, "sticky");
            } else {
                if (event.target.value >= 0) {
                    if (event.target.dataset.field == 'Tenure__c') {
                        this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.Tenure__c = event.target.value;

                    }
                    if (event.target.dataset.field == 'NoEMIPaid__c') {
                        this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.NoEMIPaid__c = event.target.value;
                    }

                    this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.TenureLeft__c = this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.Tenure__c - this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.NoEMIPaid__c;
                }


            }
        }


        else {

            tempArr.parentRecord[event.target.dataset.field] = event.target.value;
            this.allRecOfApplObwithDetai[event.target.dataset.index] = tempArr;
            if (event.target.dataset.field == 'CloseDate__c') {
                let closeDate = event.target.value;
                let obligCreatedDate = tempArr.parentRecord.CreatedDate;
                    let c1 = new Date(obligCreatedDate).getFullYear() - new Date(closeDate).getFullYear();
                    let c2 = (new Date(obligCreatedDate).getMonth() - new Date(closeDate).getMonth());
                    let closeCal = (((c1) * 12) + (c2));
                if(closeCal <= 12){
                    console.log('1234tab')
                    if (this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.CloseDate__c != undefined) {
                        this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.iscloseRequired = false;
                    }
                    console.log('this.allRecOfApplObwithDetai', JSON.stringify(this.allRecOfApplObwithDetai))
                }
                else{
                    tempArr.parentRecord[event.target.dataset.field] = '';
                    this.allRecOfApplObwithDetai[event.target.dataset.index] = tempArr;
                    event.preventDefault();
                    this.showToast("Error!", "error", this.customLabel.ObligationBanking_closeDate_error, "sticky");

                }
            }

        }

    }


    handleBounceBTLoan(event) {
        if (event.target.dataset.field == 'BonceBTloanSesingless12mths__c') {
            this.BonceBTless12mths = event.target.value;
        }
        if (event.target.dataset.field == 'BonceBTloanSesingtreql12mths__c') {
            this.BonceBTeql12mths = event.target.value;
        }
        if (event.target.dataset.field == 'BonceBTloanSesingtreql18mths__c') {
            this.BonceBTeql18mths = event.target.value;
        }
    }


    dataId
    handleInputChange(event) {

        const inputBox = event.currentTarget;
        inputBox.setCustomValidity('');
        inputBox.reportValidity();


        let obligatoryDetails = this.newBlankListOfAppObliRec[event.target.dataset.index]
        const positiveNumberPattern = /^[0-9]\d*$/;
        if (event.target.dataset.field == 'BounceInLast18Months__c' || event.target.dataset.field == 'BounceInLast12Months__c' || event.target.dataset.field == 'TotalBouncesInRTR__c'
            || event.target.dataset.field == 'LoanAmount__c' || event.target.dataset.field == 'CurrentOs__c' || event.target.dataset.field == 'EMI__c' || event.target.dataset.field == 'NoEMIPaid__c' || event.target.dataset.field == 'TenureLeft__c') {
            if (!positiveNumberPattern.test(event.target.value)) {
                this.showToast("Error!", "error", this.customLabel.ObligationBanking_value_ErrorMessage, "sticky");


            } else {

                obligatoryDetails.parentRecord[event.target.dataset.field] = event.target.value;
                obligatoryDetails.isDirty = true;

                this.newBlankListOfAppObliRec[event.target.dataset.index] = obligatoryDetails;

                this.totalLoanAmount_m = 0;
                this.totalCurrentOS_m = 0;
                this.totalEMI_m = 0;
                this.totalContinueObli_m = 0;

                this.totalLoanAmountObligate_m = 0;
                this.totalCurrentOSObligate_m = 0;
                this.totalEMIObligate_m = 0;

                if (event.target.dataset.field == 'LoanAmount__c' || event.target.dataset.field == 'CurrentOs__c' || event.target.dataset.field == 'EMI__c') {


                    for (const record of this.newBlankListOfAppObliRec) {
                        this.totalLoanAmount_m += record.parentRecord.LoanAmount__c == '' || record.parentRecord.LoanAmount__c == null || record.parentRecord.LoanAmount__c == undefined ? Number(0) : Number(record.parentRecord.LoanAmount__c);
                        this.totalCurrentOS_m += record.parentRecord.CurrentOs__c == '' || record.parentRecord.CurrentOs__c == null || record.parentRecord.CurrentOs__c == undefined ? Number(0) : Number(record.parentRecord.CurrentOs__c);
                        this.totalEMI_m += record.parentRecord.EMI__c == '' || record.parentRecord.EMI__c == null || record.parentRecord.EMI__c == undefined ? Number(0) : Number(record.parentRecord.EMI__c);

                        if (record.parentRecord.Treatment__c == 'To continue - Obligate') {
                            this.totalLoanAmountObligate_m += record.parentRecord.LoanAmount__c == '' || record.parentRecord.LoanAmount__c == null || record.parentRecord.LoanAmount__c == undefined ? Number(0) : Number(record.parentRecord.LoanAmount__c);
                            this.totalCurrentOSObligate_m += record.parentRecord.CurrentOs__c == '' || record.parentRecord.CurrentOs__c == null || record.parentRecord.CurrentOs__c == undefined ? Number(0) : Number(record.parentRecord.CurrentOs__c);
                            this.totalEMIObligate_m += record.parentRecord.EMI__c == '' || record.parentRecord.EMI__c == null || record.parentRecord.EMI__c == undefined ? Number(0) : Number(record.parentRecord.EMI__c);
                        }


                    }
                }
            }
        }
        if (event.target.dataset.field == 'DisbursalDate__c') {
            obligatoryDetails.parentRecord[event.target.dataset.field] = event.target.value;
            obligatoryDetails.isDirty = true;
            let DisbursalDate = event.target.value;
            let currentDate = new Date().toISOString().substring(0, 10);
            if (DisbursalDate > currentDate) {
                this.showToast("Error!", "error", 'Disbursal Date should not be future date', "sticky");
                const items = this.template.querySelectorAll('[data-id="DisbursalDateId"]');
                if (items.length > 0) {
                    const firstItem = items[event.target.dataset.index];
                    firstItem.value = '';
                }
            }
            else {

                let d1 = new Date(currentDate).getFullYear() - new Date(DisbursalDate).getFullYear();
                let d2 = (new Date(currentDate).getMonth() - new Date(DisbursalDate).getMonth());

                let MonthCal = (((d1) * 12) + (d2))

                obligatoryDetails.isDirty = true;
                obligatoryDetails.parentRecord.NoEMIPaid__c = MonthCal
                this.newBlankListOfAppObliRec[event.target.dataset.index] = obligatoryDetails;

                if (obligatoryDetails.parentRecord.Tenure__c >= 0 & obligatoryDetails.parentRecord.Tenure__c != '') {
                    obligatoryDetails.parentRecord.TenureLeft__c = obligatoryDetails.parentRecord.Tenure__c - obligatoryDetails.parentRecord.NoEMIPaid__c;
                    this.newBlankListOfAppObliRec[event.target.dataset.index] = obligatoryDetails;

                }
            }


        }
        if (event.target.dataset.field == 'Tenure__c' || event.target.dataset.field == 'NoEMIPaid__c') {
            if (!positiveNumberPattern.test(event.target.value)) {

                this.showToast("Error!", "error", this.customLabel.ObligationBanking_value_ErrorMessage, "sticky");
            } else {
                obligatoryDetails.parentRecord[event.target.dataset.field] = event.target.value;
                obligatoryDetails.isDirty = true;

                obligatoryDetails.parentRecord.TenureLeft__c = obligatoryDetails.parentRecord.Tenure__c - obligatoryDetails.parentRecord.NoEMIPaid__c;
                this.newBlankListOfAppObliRec[event.target.dataset.index] = obligatoryDetails;

            }
        }

        else {
            obligatoryDetails.parentRecord[event.target.dataset.field] = event.target.value;
            obligatoryDetails.isDirty = true;
            this.newBlankListOfAppObliRec[event.target.dataset.index] = obligatoryDetails;
        }



    }

    handleAddLoan(event) {
        let addRec = {
            "ChildReords": [
                {
                    "BureauRespDtl__c": "",
                    "EMI_Clearance_Date_Identifier__c": "Month0",
                    "EMI_Clearance_Date__c": "",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c',
                },
                {
                    "BureauRespDtl__c": "",
                    "EMI_Clearance_Date_Identifier__c": "Month1",
                    "EMI_Clearance_Date__c": "",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c',
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month2",
                    "EMI_Clearance_Date__c": "",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c',
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month3",
                    "EMI_Clearance_Date__c": "",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c',
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month4",
                    "EMI_Clearance_Date__c": "",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c',
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month5",
                    "EMI_Clearance_Date__c": "",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c',
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month6",
                    "EMI_Clearance_Date__c": "",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c',
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month7",
                    "EMI_Clearance_Date__c": "",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c',
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month8",
                    "EMI_Clearance_Date__c": "",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c',
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month9",
                    "EMI_Clearance_Date__c": "",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c',
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month10",
                    "EMI_Clearance_Date__c": "",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c',
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month11",
                    "EMI_Clearance_Date__c": "",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c',
                },
                {
                    "BureauRespDtl__c": "",

                    "EMI_Clearance_Date_Identifier__c": "Month12",
                    "EMI_Clearance_Date__c": "",
                    "EMI_Clearance_Date_IdentifierTest__c": "",
                    "sobjectType": 'Applicant_Obligation_detail__c',

                }
            ],
            "parentRecord": {
                "Source__c": "Manual",
                "LoanName__c": "",
                "EMISource__c": "",
                "NatureOfLoan__c": "",
                "FinancierName__c": "",
                "LoanCapacity__c": "",
                "ConsiderObligation__c": "",
                "RepayAc__c": "",
                "Treatment__c": "",
                "NoEMIPaid__c": "",
                "LoanAmount__c": "",
                "Ever90__c": "",
                "MaxDPDLst12month__c": "",
                "MaxDPDLst6month__c": "",
                "Overdues__c": "",
                "MaxDPDLst3month__c": "",
                "TenureLeft__c": "",
                "Tenure__c": "",
                "Applicant__c": "",
                "LoanApplication__c": this.loanAppId,
                "CloseDate__c": "",
                "DisbursalDate__c": "",
                "CurrentOs__c": "",
                "EMI__c": "",
                "RecordTypeId": "",
                "sobjectType": 'BureauRespDtl__c',
                "BounceInLast12Months__c": "",
                "BounceInLast18Months__c": "",
                "TotalBouncesInRTR__c": "",


            },
            "index": "",
            "isDirty": false,
            "ParentFieldApiNameToUpdate": "BureauRespDtl__c"
        }

        let tempArrRec = [...this.newBlankListOfAppObliRec];
        tempArrRec.push(addRec);
        this.newBlankListOfAppObliRec = [...tempArrRec];
        this.oldListnewBlankListOfAppObliRec = this.newBlankListOfAppObliRec;
        if (typeof this.monthAndYearvalue !== 'undefined') {
            this.handleMonYearForNewList(this.monthAndYearvalue);
        }

    }


    handleValueSelect(event) {
        this.lookupRec = event.detail;
        let lookupId = this.lookupRec.id;
        let lookupAPIName = this.lookupRec.lookupFieldAPIName;
        const outputObj = { [lookupAPIName]: lookupId };
        if (event.target.fieldName === 'FinancierName__c') {

            this.allRecOfApplObwithDetai[event.target.index].parentRecord.FinancierName__c = this.lookupRec.mainField;
            this.allRecOfApplObwithDetai[event.target.index].parentRecord.FinancierNameID__c = lookupId;



        }
        if (event.target.fieldName === 'Repayment_Bank__c') {

            this.allRecOfApplObwithDetai[event.target.index].parentRecord.Repayment_Bank__c = this.lookupRec.mainField;
            this.allRecOfApplObwithDetai[event.target.index].parentRecord.RepaymentBankID__c = lookupId;



        }


    }


    handleSystemDateChange(event) {


        let fieldName = event.target.dataset.field;

        let monthEntered = event.target.value.slice(5, 7);
        const monthMap = { 0: 'January', 1: 'February', 2: 'March', 3: 'April', 4: 'May', 5: 'June', 6: 'July', 7: 'August', 8: 'September', 9: 'October', 10: 'November', 11: 'December', };
        let LoginMonth = this.loginAccepatnceDate.slice(5, 7);
        const date2 = new Date(this.loginAccepatnceDate);
        const monthName = monthMap[date2.getMonth()];


        if (monthEntered != LoginMonth) {
            this.showToast("Error!", "error", this.customLabel.ObligationBanking_EmiDate_ErrroMessage + monthName + " month", "sticky");
        }
        else {

            this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.EMIClearanceDate__c = event.target.value;
        }

    }

    ///c/handle manual
    handleValuemanualSelect(event) {
        this.lookupRec = event.detail;
        let lookupId = this.lookupRec.id;
        let lookupAPIName = this.lookupRec.lookupFieldAPIName;
        const outputObj = { [lookupAPIName]: lookupId };
        if (event.target.fieldName === 'FinancierName__c') {

            this.newBlankListOfAppObliRec[event.target.index].parentRecord.FinancierName__c = this.lookupRec.mainField;
            this.newBlankListOfAppObliRec[event.target.index].parentRecord.FinancierNameID__c = lookupId;


        }
        if (event.target.fieldName === 'Repayment_Bank__c') {

            this.newBlankListOfAppObliRec[event.target.index].parentRecord.Repayment_Bank__c = this.lookupRec.mainField;
            this.newBlankListOfAppObliRec[event.target.index].parentRecord.RepaymentBankID__c = lookupId;

        }
        if (event.target.fieldName === 'Loan_Type__c') {

            this.newBlankListOfAppObliRec[event.target.index].parentRecord.NatureOfLoan__c = this.lookupRec.mainField;
            this.newBlankListOfAppObliRec[event.target.index].parentRecord.NatureOfLoanID__c = lookupId;

        }


        this.newBlankListOfAppObliRec[event.target.index].isDirty = true;

    }

    //end
    HandleValueChange(event) {

        const inputBox = event.currentTarget;
        inputBox.setCustomValidity('');
        inputBox.reportValidity();

        let tempArr = this.allRecOfApplObwithDetai[event.target.dataset.index];
        if (event.target.value == 'Already closed') {

            this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.iscloseRequired = false;


        }
        else{
            if(this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.CloseDate__c!=undefined)
            {
                this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.iscloseRequired = false;
            }
            else{
                this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.iscloseRequired = true;;
            }
        }

        if (event.target.value == 'To continue - Obligate') {

            this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.ConsiderObligation__c = 'Yes';

            this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.Treatment__c = event.target.value;

        }
        if (event.target.value != 'To continue - Obligate') {

            this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.ConsiderObligation__c = 'No';

            this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.Treatment__c = event.target.value;

        }


        this.obligArr_s = [];
        this.totalLoanAmountObligate = 0;
        this.totalCurrentOSObligate = 0;
        this.totalEMIObligate = 0;
        for (const record of this.allRecOfApplObwithDetai) {
            if (record.parentRecord.Treatment__c == 'To continue - Obligate') {

                this.totalLoanAmountObligate += record.parentRecord.LoanAmount__c == '' || record.parentRecord.LoanAmount__c == null || record.parentRecord.LoanAmount__c == undefined ? Number(0) : Number(record.parentRecord.LoanAmount__c);
                this.totalCurrentOSObligate += record.parentRecord.CurrentOs__c == '' || record.parentRecord.CurrentOs__c == null || record.parentRecord.CurrentOs__c == undefined ? Number(0) : Number(record.parentRecord.CurrentOs__c);
                this.totalEMIObligate += record.parentRecord.EMI__c == '' || record.parentRecord.EMI__c == null || record.parentRecord.EMI__c == undefined ? Number(0) : Number(record.parentRecord.EMI__c);
                this.obligArr_s.push(record);
            }

        }
        this.totalContinueObli = this.obligArr_s.length


    }

    HandleValue(event) {


        const inputBox = event.currentTarget;

        inputBox.setCustomValidity('');
        inputBox.reportValidity();

        let tempArry = this.newBlankListOfAppObliRec[event.target.dataset.index];
        this.newBlankListOfAppObliRec[event.target.dataset.index].isDirty = true;

        if (event.target.dataset.name == 'Treatment__c') {
            this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.Treatment__c = event.target.value;

            if (event.target.value == 'To continue - Obligate') {
                this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.ConsiderObligation__c = 'Yes';

            }
            if (event.target.value != 'To continue - Obligate') {
                this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.ConsiderObligation__c = 'No';

            }
            this.obligArr = [];
            this.totalLoanAmountObligate_m = 0;
            this.totalCurrentOSObligate_m = 0;
            this.totalEMIObligate_m = 0;
            for (const record of this.newBlankListOfAppObliRec) {
                if (record.parentRecord.Treatment__c == 'To continue - Obligate') {

                    this.totalLoanAmountObligate_m += record.parentRecord.LoanAmount__c == '' || record.parentRecord.LoanAmount__c == null || record.parentRecord.LoanAmount__c == undefined ? Number(0) : Number(record.parentRecord.LoanAmount__c);
                    this.totalCurrentOSObligate_m += record.parentRecord.CurrentOs__c == '' || record.parentRecord.CurrentOs__c == null || record.parentRecord.CurrentOs__c == undefined ? Number(0) : Number(record.parentRecord.CurrentOs__c);
                    this.totalEMIObligate_m += record.parentRecord.EMI__c == '' || record.parentRecord.EMI__c == null || record.parentRecord.EMI__c == undefined ? Number(0) : Number(record.parentRecord.EMI__c);
                    this.obligArr.push(record);
                }

            }
            this.totalContinueObli_m = this.obligArr.length
        }



        if (event.target.dataset.name == 'LoanName__c') {

            this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.Applicant__c = event.target.value;



            let Aid = this.AppNameList.find(opt => opt.value === this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.Applicant__c).label;

            this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.LoanName__c = Aid;


            for (let i = 0; i < this.tempArrAppConst.length; i++) {
                if (this.tempArrAppConst[i].FullName__c == Aid) {
                    if (this.tempArrAppConst[i].Constitution__c == 'INDIVIDUAL') {
                        this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.RecordTypeId = this.RTConsumerId;

                    }
                    else {
                        this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.RecordTypeId = this.RTCommercialId;

                    }
                }
            }


        }



        if (event.target.dataset.name == 'LoanCapacity__c') {
            this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.LoanCapacity__c = event.target.value;

        }


    }

    //delete spdc records
    @track isModalOpen = false;
    @track removeModalMessage = "Do you really want to delete this Record.";
    @track deleteRecordId;
    @track indexToDeleteModal;
    isCloseModal() {
        this.isModalOpen = false;
    }

    handleDelete(event) {
        this.deleteRecordId = this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.Id;
        this.indexToDeleteModal = event.target.dataset.index;

        this.isModalOpen = true;
    }
    handleRemoveRecord() {

        if (this.deleteRecordId == undefined) {
            this.newBlankListOfAppObliRec.splice(this.indexToDeleteModal, 1);
            this.totalLoanAmount_m = 0;
            this.totalCurrentOS_m = 0;
            this.totalEMI_m = 0;
            this.totalContinueObli_m = 0;
            this.obligArr = [];
            for (const record of this.newBlankListOfAppObliRec) {

                this.totalLoanAmount_m += record.parentRecord.LoanAmount__c == '' || record.parentRecord.LoanAmount__c == null || record.parentRecord.LoanAmount__c == undefined ? Number(0) : Number(record.parentRecord.LoanAmount__c);
                this.totalCurrentOS_m += record.parentRecord.CurrentOs__c == '' || record.parentRecord.CurrentOs__c == null || record.parentRecord.CurrentOs__c == undefined ? Number(0) : Number(record.parentRecord.CurrentOs__c);
                this.totalEMI_m += record.parentRecord.EMI__c == '' || record.parentRecord.EMI__c == null || record.parentRecord.EMI__c == undefined ? Number(0) : Number(record.parentRecord.EMI__c);
                if (record.parentRecord.Treatment__c == 'To continue - Obligate') {

                    this.obligArr.push(record);
                }
                this.totalContinueObli_m = this.obligArr.length


            }
            this.isModalOpen = false;
        }
        else {
            deleteRecord(this.deleteRecordId)
                .then(result => {
                    refreshApex(this._wiredManualData);


                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: this.customLabel.ObligationBanking_Del_SuccessMessage,
                            variant: 'success',
                            mode: 'sticky'
                        })
                    );
                    this.isModalOpen = false;
                })
                .catch(error => {
                    console.log(error);
                });
        }

    }

    checkValidityLookup() {
        let isInputCorrect = true;
        let allChilds = this.template.querySelectorAll("c-custom-lookup");
        allChilds.forEach((child) => {
            if (!child.checkValidityLookup()) {
                child.checkValidityLookup();
                isInputCorrect = false;
            }
        });
        return isInputCorrect;
    }

    totalLiveLoan = 0
    loancountArr = []
    liveLoanCal() {

        let TotalLoanrecords = JSON.parse(JSON.stringify(this.allRecOfApplObwithDetai.concat(this.newBlankListOfAppObliRec)))
        let sum
        let mapOfCount = new Map();
        for (var i = 0; i < TotalLoanrecords.length; i++) {

            if (TotalLoanrecords[i].parentRecord.Treatment__c == "To continue - Obligate") {
                let sum = 1
                if (mapOfCount.has(TotalLoanrecords[i].parentRecord.Applicant__c)) {
                    sum = mapOfCount.get(TotalLoanrecords[i].parentRecord.Applicant__c) + 1
                    mapOfCount.set(TotalLoanrecords[i].parentRecord.Applicant__c, sum);
                }
                else {
                    mapOfCount.set(TotalLoanrecords[i].parentRecord.Applicant__c, sum);
                }
            }
        }
        let RARecord = []

        mapOfCount.forEach(function (value, key) {
            let RecordObj = {}
            RecordObj.Id = key;
            RecordObj.Total_Live_Loan__c = value;
            RARecord.push(RecordObj)
        })
        upsertMultipleRecord({ params: RARecord })
            .then(result => {

                refreshApex(this._wiredBruData);
            }).catch(error => {
                console.log(error);
            })

    }


    tableOuterDivScrolled(event) {
        this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
        if (this._tableViewInnerDiv) {
            if (!this._tableViewInnerDivOffsetWidth || this._tableViewInnerDivOffsetWidth === 0) {
                this._tableViewInnerDivOffsetWidth = this._tableViewInnerDiv.offsetWidth;
            }
            this._tableViewInnerDiv.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth) + "px;" + this.tableBodyStyle;
        }

        this.tableScrolled(event);



    }

    tableScrolled(event) {
        if (this.enableInfiniteScrolling) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('showmorerecords', {
                    bubbles: true
                }));
            }
        }
        if (this.enableBatchLoading) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('shownextbatch', {
                    bubbles: true
                }));
            }
        }
    }






    handlemouseup(e) {
        this._tableThColumn = undefined;
        this._tableThInnerDiv = undefined;
        this._pageX = undefined;
        this._tableThWidth = undefined;
    }

    handlemousedown(e) {
        if (!this._initWidths) {
            this._initWidths = [];
            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            tableThs.forEach(th => {
                this._initWidths.push(th.style.width);
            });
        }

        this._tableThColumn = e.target.parentElement;
        this._tableThInnerDiv = e.target.parentElement;
        while (this._tableThColumn.tagName !== "TH") {
            this._tableThColumn = this._tableThColumn.parentNode;
        }
        while (!this._tableThInnerDiv.className.includes("slds-cell-fixed")) {
            this._tableThInnerDiv = this._tableThInnerDiv.parentNode;
        }
        this._pageX = e.pageX;

        this._padding = this.paddingDiff(this._tableThColumn);

        this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
    }

    handlemousemove(e) {
        if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
            this._diffX = e.pageX - this._pageX;

            this.template.querySelector("table").style.width = (this.template.querySelector("table") - (this._diffX)) + 'px';

            this._tableThColumn.style.width = (this._tableThWidth + this._diffX) + 'px';
            this._tableThInnerDiv.style.width = this._tableThColumn.style.width;

            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            let tableBodyRows = this.template.querySelectorAll("table tbody tr");
            let tableBodyTds = this.template.querySelectorAll("table tbody .dv-dynamic-width");
            tableBodyRows.forEach(row => {
                let rowTds = row.querySelectorAll(".dv-dynamic-width");
                rowTds.forEach((td, ind) => {
                    rowTds[ind].style.width = tableThs[ind].style.width;
                });
            });
        }
    }

    handledblclickresizable() {
        let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
        let tableBodyRows = this.template.querySelectorAll("table tbody tr");
        tableThs.forEach((th, ind) => {
            th.style.width = this._initWidths[ind];
            th.querySelector(".slds-cell-fixed").style.width = this._initWidths[ind];
        });
        tableBodyRows.forEach(row => {
            let rowTds = row.querySelectorAll(".dv-dynamic-width");
            rowTds.forEach((td, ind) => {
                rowTds[ind].style.width = this._initWidths[ind];
            });
        });
    }

    paddingDiff(col) {

        if (this.getStyleVal(col, 'box-sizing') === 'border-box') {
            return 0;
        }

        this._padLeft = this.getStyleVal(col, 'padding-left');
        this._padRight = this.getStyleVal(col, 'padding-right');
        return (parseInt(this._padLeft, 10) + parseInt(this._padRight, 10));

    }

    getStyleVal(elm, css) {
        return (window.getComputedStyle(elm, null).getPropertyValue(css))
    }
    monthAndYearvalue;
    arrMonYear = [];
    listForDelete;
    listforUI = [];
    objForEmiDates
    handleMonthAndVal(event) {
        var newMonthAndYearval = event.target.value; 

        const dateObj = new Date(event.target.value).toISOString().split('T')[0]
        if (this.loginAccepatnceDate) {
            if (this.loginAccepatnceDate < dateObj) {
                this.showToast("Error", "error", this.customLabel.ObligationBanking_RTRDateMes_ErrorMessage, "sticky");
                this.monthAndYearvalu = "";
                this.template.querySelector('[data-id="startDate"]').value = '';
            } else {
                this.showDateColumn = true
                this.handleMonthAndYearHeaderWihRec(newMonthAndYearval);
                if (this.newBlankListOfAppObliRec.length > 0) {
                    this.handleMonYearForNewList(newMonthAndYearval);
                }
            }


        } else {
            this.showToast("Error", "error", this.customLabel.ObligationBanking_LoginAccDate_ErrorMessage, "sticky");
        }




    }
    startDateMonthAndYearvalue;
    handleMonthAndYearHeaderWihRec(MonthAndYearval) {

        for (let i = 0; i < this.allRecOfApplObwithDetai.length; i++) {
            if (this.allRecOfApplObwithDetai[i].ChildReords && this.allRecOfApplObwithDetai[i].ChildReords != undefined) {
                this.allRecOfApplObwithDetai[i].ChildReords = JSON.parse(JSON.stringify(this.listOfallRecOfApplObwithDetai[i].ChildReords));
            }
        }

        this.monthAndYearvalue = MonthAndYearval;  

        if (this.monthAndYearvalue != 'undefined' && this.monthAndYearvalue != '' && this.monthAndYearvalue != null) {
            const dateObj = new Date(this.monthAndYearvalue);
            const fileAccDay = dateObj.getDate();
            const firstFullyear = dateObj.getFullYear();
            const fileAccMonth = dateObj.getMonth();
            dateObj.setFullYear(dateObj.getFullYear() - 1);
            let oneYearLessDate = dateObj.toISOString().slice(0, 10);
            const newDate = new Date(MonthAndYearval);
            let dateArray = [];
            this.listforUI = []
            const monthMap = { 0: 'January', 1: 'February', 2: 'March', 3: 'April', 4: 'May', 5: 'June', 6: 'July', 7: 'August', 8: 'September', 9: 'October', 10: 'November', 11: 'December', };
            var newdatee = monthMap[newDate.getMonth()] + '-' + newDate.getFullYear()

            var datefornew = this.convertToDateFormat(newdatee)

            const dateObj1 = new Date(datefornew);
            for (let i = 0; i <= 12; i++) {
                const iMonthBeforeDate = new Date(dateObj1);
                iMonthBeforeDate.setMonth(fileAccMonth - (i));
                dateArray.push(iMonthBeforeDate);
            }

            var arrMonYear = [];
            for (let i = 0; i < dateArray.length; i++) {
                const getYear = this.convertToDate(dateArray[i]);
                arrMonYear.push(monthMap[dateArray[i].getMonth()] + '-' + getYear.getFullYear());
                this.arrMonYear = arrMonYear;
            }
            var listoUpdate = this.arrMonYear;

            var newList = listoUpdate.map(item => {
                const [month, year] = item.split('-');

                var newval = month.substring(0, 3).toUpperCase() + '-' + year;
                this.listforUI.push(newval)
            });


            var objOfRecWithMonYear = {};
            var ListOfobjOfRecWithMonYear = [];
            for (const record of this.allRecOfApplObwithDetai) {
                if (record.ChildReords && record.ChildReords != undefined) {

                    for (let i = 0; i < record.ChildReords.length; i++) {
                        if (typeof record.ChildReords[i].EMI_Clearance_Date__c !== 'undefined' && record.ChildReords[i].EMI_Clearance_Date__c) {

                        } else {

                            record.ChildReords[i].EMI_Clearance_Date__c = this.convertToDateFormat(this.arrMonYear[i]);

                        }
                    }

                } else {

                }
            }
            var listForDelete = [];
            for (const record of this.allRecOfApplObwithDetai) {
                if (record.ChildReords && record.ChildReords != undefined) {

                    for (const chilRec of record.ChildReords) {
                        const date = new Date(chilRec.EMI_Clearance_Date__c);

                        const datenew = this.convertToDate(date);

                        const monthNameYearKey = monthMap[datenew.getMonth()] + '-' + datenew.getFullYear();
                        var newarray = this.arrMonYear;

                        if (!newarray.includes(monthNameYearKey)) {
                            listForDelete.push(chilRec);

                        } else {

                        }
                        this.listForDelete = listForDelete;
                        if (!objOfRecWithMonYear[monthNameYearKey]) {
                            objOfRecWithMonYear[monthNameYearKey] = [];
                        }
                        objOfRecWithMonYear[monthNameYearKey].push(chilRec);

                    }
                    ListOfobjOfRecWithMonYear.push(objOfRecWithMonYear);

                } else {

                }
            }

            const idsToRemove = listForDelete.map(record => record.EMI_Clearance_Date_Identifier__c);

            for (let i = 0; i < this.allRecOfApplObwithDetai.length; i++) {

                if (this.allRecOfApplObwithDetai[i].ChildReords && this.allRecOfApplObwithDetai[i].ChildReords != undefined) {

                    var listoFRec = [];
                    for (const chilRec of this.allRecOfApplObwithDetai[i].ChildReords) {
                        if (!idsToRemove.includes(chilRec.EMI_Clearance_Date_Identifier__c)) {
                            listoFRec.push(chilRec);
                        } else {

                        }
                    }
                    this.allRecOfApplObwithDetai[i].ChildReords = listoFRec;

                }
            }


            for (let i = 0; i < this.allRecOfApplObwithDetai.length; i++) {
                var listToadd = [];
                this.parentIdForObliga = this.allRecOfApplObwithDetai[i].parentRecord.Id;
                for (let j = 0; j < this.arrMonYear.length; j++) {
                    if (this.allRecOfApplObwithDetai[i].ChildReords && this.allRecOfApplObwithDetai[i].ChildReords != undefined) {

                        if (ListOfobjOfRecWithMonYear[i][this.arrMonYear[j]] && typeof ListOfobjOfRecWithMonYear[i][this.arrMonYear[j]] !== 'undefined') {
                            this.allRecOfApplObwithDetai[i].ChildReords[j].EMI_Clearance_Date_Identifier__c = "Month" + j;
                            this.allRecOfApplObwithDetai[i].ChildReords[j].EMI_Clearance_Date__c = this.convertToDateFormat(this.arrMonYear[j]);
                        } else {

                            let temp = { "BureauRespDtl__c": this.parentIdForObliga, "EMI_Clearance_Date_Identifier__c": "Month" + j, "EMI_Clearance_Date__c": this.convertToDateFormat(this.arrMonYear[j]) };
                            this.allRecOfApplObwithDetai[i].ChildReords.unshift(temp)
                        }
                    }
                }
                this.allRecOfApplObwithDetai[i].ChildReords = this.allRecOfApplObwithDetai[i].ChildReords.sort((a, b) => new Date(b.EMI_Clearance_Date__c) - new Date(a.EMI_Clearance_Date__c));


            }


        } else {

        }
    }

    listForDeleteforNewList = []
    oldListnewBlankListOfAppObliRec = [];
    handleMonYearForNewList(MonthAndYearval) {

        for (let i = 0; i < this.newBlankListOfAppObliRec.length; i++) {
            if (this.newBlankListOfAppObliRec[i].ChildReords && this.newBlankListOfAppObliRec[i].ChildReords != undefined) {
                this.newBlankListOfAppObliRec[i].ChildReords = JSON.parse(JSON.stringify(this.oldListnewBlankListOfAppObliRec[i].ChildReords));
            }
        }
        this.monthAndYearvalue = MonthAndYearval;
        if (this.monthAndYearvalue != 'undefined' && this.monthAndYearvalue != '' && this.monthAndYearvalue != null) {

            var objOfRecWithMonYear = {};
            var ListOfobjOfRecWithMonYear = [];
            const monthMap = { 0: 'January', 1: 'February', 2: 'March', 3: 'April', 4: 'May', 5: 'June', 6: 'July', 7: 'August', 8: 'September', 9: 'October', 10: 'November', 11: 'December', };
            for (const record of this.newBlankListOfAppObliRec) {
                if (record.ChildReords && record.ChildReords != undefined) {

                    for (let i = 0; i < record.ChildReords.length; i++) {
                        if (typeof record.ChildReords[i].EMI_Clearance_Date__c !== 'undefined' && record.ChildReords[i].EMI_Clearance_Date__c) {

                        } else {

                            record.ChildReords[i].EMI_Clearance_Date__c = this.convertToDateFormat(this.arrMonYear[i]);

                        }
                    }

                } else {

                }
            }
            var listForDelete = [];
            var listofRec = []
            for (const record of this.newBlankListOfAppObliRec) {
                if (record.ChildReords && record.ChildReords != undefined) {
                    for (const chilRec of record.ChildReords) {
                        const date = new Date(chilRec.EMI_Clearance_Date__c);
                        const datenew = this.convertToDate(date);

                        const monthNameYearKey = monthMap[datenew.getMonth()] + '-' + datenew.getFullYear();
                        var newarray = this.arrMonYear;


                        if (!newarray.includes(monthNameYearKey)) {
                            listForDelete.push(chilRec);

                        } else {


                        }
                        this.listForDeleteforNewList = listForDelete;
                        if (!objOfRecWithMonYear[monthNameYearKey]) {
                            objOfRecWithMonYear[monthNameYearKey] = [];
                        }
                        objOfRecWithMonYear[monthNameYearKey].push(chilRec);

                    }
                    ListOfobjOfRecWithMonYear.push(objOfRecWithMonYear);

                } else {

                }
            }
            const idsToRemove = listForDelete.map(record => record.EMI_Clearance_Date_Identifier__c);

            for (let i = 0; i < this.newBlankListOfAppObliRec.length; i++) {

                if (this.newBlankListOfAppObliRec[i].ChildReords && this.newBlankListOfAppObliRec[i].ChildReords != undefined) {

                    var listoFNotRec = [];
                    for (const chilRec of this.newBlankListOfAppObliRec[i].ChildReords) {
                        if (!idsToRemove.includes(chilRec.EMI_Clearance_Date_Identifier__c)) {
                            listoFNotRec.push(chilRec);
                        } else {

                        }
                    }
                    this.newBlankListOfAppObliRec[i].ChildReords = listoFNotRec;

                }
            }

            for (let i = 0; i < this.newBlankListOfAppObliRec.length; i++) {
                var listToadd = [];
                this.parentIdForObliga = this.newBlankListOfAppObliRec[i].parentRecord.Id;
                for (let j = 0; j < this.arrMonYear.length; j++) {
                    if (this.newBlankListOfAppObliRec[i].ChildReords && this.newBlankListOfAppObliRec[i].ChildReords != undefined) {

                        if (ListOfobjOfRecWithMonYear[i][this.arrMonYear[j]] && typeof ListOfobjOfRecWithMonYear[i][this.arrMonYear[j]] !== 'undefined') {
                            this.newBlankListOfAppObliRec[i].ChildReords[j].EMI_Clearance_Date_Identifier__c = "Month" + j;
                            this.newBlankListOfAppObliRec[i].ChildReords[j].EMI_Clearance_Date__c = this.convertToDateFormat(this.arrMonYear[j]);
                        } else {
                            let temp = { "BureauRespDtl__c": this.parentIdForObliga, "EMI_Clearance_Date_Identifier__c": "Month" + j, "EMI_Clearance_Date__c": this.convertToDateFormat(this.arrMonYear[j]) };
                            this.newBlankListOfAppObliRec[i].ChildReords.unshift(temp)
                        }
                    }
                }
                this.newBlankListOfAppObliRec[i].ChildReords = this.newBlankListOfAppObliRec[i].ChildReords.sort((a, b) => new Date(b.EMI_Clearance_Date__c) - new Date(a.EMI_Clearance_Date__c));

            }


        } else {

        }
    }
    convertToDateFormat(monthYear) {
        const [year, month] = monthYear.split('-');
        const dateObject = new Date(`${year}-${month}-10`);
        var formattedDate = this.convertToDate(dateObject)
        return formattedDate;

    }
    convertToDate(str) {
        var date = new Date(str)
        return date;
    }

    //lak-7282
    @track stageN = "obligationDetails"
    @track stageOfLAN="QDE"
    @track docId
    @track propIden = true;
    @track _isObligation=true;
    // @track _fileFormat=[".jpeg", ".jpg", ".pdf",".xlsx"];
    @track _fileFormat=[".xlsx"];
    handleValidDocument(event) {

        if (event.detail) {
        this.docId = event.detail
        }
    }


  //Excel Data Logic //LAK-9373
   @track dataMap =[];

    async idMapForBanks(strFinName , strRepayBankName) {

    let bankNamesList = [];
    let bankNamesListFin = [];

    if (this.newBlankListOfAppObliRec) {
        this.newBlankListOfAppObliRec.forEach(rec => {
            if (rec.parentRecord.FinancierName__c) {
                bankNamesListFin.push(rec.parentRecord.FinancierName__c.toUpperCase());
                bankNamesListFin.push('OTHER NBFC');
                bankNamesListFin.push(strFinName);
            }
            if (rec.parentRecord.Repayment_Bank__c) {
                bankNamesList.push(rec.parentRecord.Repayment_Bank__c.toUpperCase());
                bankNamesList.push('OTHERS');  
                bankNamesList.push(strRepayBankName);  
            }
        });
        
    }

    if (this.allRecOfApplObwithDetai) {
        this.allRecOfApplObwithDetai.forEach(rec => {
            if (rec.parentRecord.FinancierName__c) {
                bankNamesListFin.push(rec.parentRecord.FinancierName__c.toUpperCase());
                bankNamesListFin.push('OTHER NBFC');
                bankNamesListFin.push(strFinName);
            }
            if (rec.parentRecord.Repayment_Bank__c) {
                bankNamesList.push(rec.parentRecord.Repayment_Bank__c.toUpperCase());
                bankNamesList.push('OTHERS');  
                bankNamesList.push(strRepayBankName);  
            }
        });
    }

    try {
        const result = await getIdMapForSfdcMstrObjs({ bankNames: bankNamesList });
        let bankArray = Object.keys(result).map(bankName => ({
            BankName: bankName,
            Id: result[bankName]
        }));

        const result1 = await getIdMapForBalTranFinancier({ bankNames: bankNamesListFin });
        let bankArray1 = Object.keys(result1).map(bankName => ({
            BankName: bankName,
            Id: result1[bankName]
        }));
        let combinedArray = [...bankArray, ...bankArray1];
        
        return combinedArray;

    } catch (error) {
        console.error('Error fetching bank data:', error);
        return [];
    }
}

  @track childRecordsMca = [];
  @track parentRecordsMca = [];
  @track allData1=[];


    handleExcelDownFileseconbutton(){
        if(this.loanDateRtr && this.isLoginDatePresent){
        let finalArrayRec=[]
        //console.log('loanDateRtr ==',this.loanDateRtr) //2023-11-03
       // console.log('array of fin banks ::',this.getFinBankArray);
        const loanDateRtr1 = String(this.loanDateRtr);
        const dateObj = new Date(loanDateRtr1);
        const month = dateObj.getMonth();
        const year = dateObj.getFullYear();
        console.log(`Month: ${month}, Year: ${year}`);
    
        let arrMon= this.getLast12Months(month,year);
        arrMon.push('Id Parent')
        let countSrNo=0;
        
        //console.log('this.newBlankListOfAppObliRec ==',this.newBlankListOfAppObliRec) 
        if(this.allRecOfApplObwithDetai !=='undefined' && this.allRecOfApplObwithDetai)
        {
        const listAutoRecords= this.getMappedArrayForTable(this.allRecOfApplObwithDetai,countSrNo,'Auto');
        if(listAutoRecords){
            listAutoRecords.forEach(ele=>{
                finalArrayRec.push(ele);
            })
            countSrNo=listAutoRecords.length;
        }

        
        console.log('listAutoRecords done')
        } 
        if(this.newBlankListOfAppObliRec !=='undefined' && this.newBlankListOfAppObliRec){
            const listManualRecords= this.getMappedArrayForTable(this.newBlankListOfAppObliRec,countSrNo,'Manual');
            
            if(listManualRecords){
                listManualRecords.forEach(elem=>{
                    finalArrayRec.push(elem);
                })
            }
            console.log('manual done')

        }

        const headers = ["Sr.No.","Source","Nature of loan","Name of Borrower","Loan Capacity","Financier Name","Disbursal date","Close date","Loan Amount","Current O/s","EMI source","EMI","Tenure","No of EMI paid","Tenure Left","Treatment","Consider for Obligation","Repayment Bank","Repayment A/c Number","Overdues","Max DPD in last 3 months","Max DPD in last 6 months","Max DPD in last 12 months","Ever 90+","Status","Remarks","Bounce in last 12 months","Bounce in last 18 months","Total Bounces in RTR"];
        const newHeaders = headers.concat(arrMon);

        const sheetData = [newHeaders, ...finalArrayRec];
        const worksheet = XLSX.utils.aoa_to_sheet(sheetData);  
        
        const firstDataRow = 2; // Assuming the first row is the header
        const lastDataRow = firstDataRow + finalArrayRec.length; // Last row number with data

        
        const totalRow = lastDataRow + 1;

        worksheet['!cols'] = [
            { wch: 15 },   
            { wch: 15 },   
            { wch: 15 },   
            { wch: 15 },   
            { wch: 15 },   
            { wch: 15 }
        ];

        //XLSX.utils.sheet_set_array_formula(worksheet, `I${totalRow}`, `SUM(I${firstDataRow}:I${lastDataRow})`); // Loan Amount Total
        //XLSX.utils.sheet_set_array_formula(worksheet, `J${totalRow}`, `SUM(J${firstDataRow}:J${lastDataRow})`); // Current O/s Total
        //XLSX.utils.sheet_set_array_formula(worksheet, `L${totalRow}`, `SUM(L${firstDataRow}:L${lastDataRow})`); // EMI Total
        // Set count for Treatment column
        //XLSX.utils.sheet_set_array_formula(worksheet, `P${totalRow}`, `COUNTA(P${firstDataRow}:P${lastDataRow})`); // Treatment count
        //worksheet[`A${totalRow}`] = { t: 's', v: 'Total' };

        const workbook = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(workbook, worksheet, "Obligation Details");

        // XLSX.writeFile(workbook, 'Obligation_Details_'+this.loanAppName+'.xlsx');//Loan App Number
        // this.showToast("Success", "success", "The file titled "+"Obligation_Details_"+this.loanAppName+".xlsx" +" was successfully downloaded." , "sticky" );
        
        //console.log('this.getRepayBankArray ::',this.getRepayBankArray)
        // Sheet 2: Applicants
        let applicantsData = [["Applicant Name"], ...this.getApplObligationArr.map(item => [item])];//["Financial Bank Name",...this.getFinBankArray];//this.getApplicantsData(); // You need to implement this to get your applicants data
        const worksheet2 = XLSX.utils.aoa_to_sheet(applicantsData);
        worksheet2['!cols'] = [
            { wch: 50 }
        ];
        XLSX.utils.book_append_sheet(workbook, worksheet2, "Applicants");

        // Sheet 3: Repayment Banks
        let repaymentBanksData =[["Repayment Banks"], ...this.getRepayBankArray.map(item => [item])];   //this.getRepaymentBanksData(); // Implement this to get repayment banks data
        
        const worksheet3 = XLSX.utils.aoa_to_sheet(repaymentBanksData);
        worksheet3['!cols'] = [
            { wch: 100 }
        ];
        XLSX.utils.book_append_sheet(workbook, worksheet3, "Repayment Banks");

        // Sheet 4: Financier Banks
        let financierBanksData = [["Financier Name Data"], ...this.getFinBankArray.map(item => [item])];

        const worksheet4 = XLSX.utils.aoa_to_sheet(financierBanksData);
        worksheet4['!cols'] = [
            { wch: 100 }
        ];
        XLSX.utils.book_append_sheet(workbook, worksheet4, "Financier Name");

        // Save and download the workbook
        XLSX.writeFile(workbook, this.loanAppName +'_Obligation_Details.xlsx');
        this.showToast("Success", "success", "The file titled 'Obligation_Details_" + this.loanAppName + ".xlsx' was successfully downloaded.", "sticky");

        }else{
            this.showToast("Error!", "error", 'Please Enter the Latest RTR Month First', "sticky");
        }
        }



    getMappedArrayForTable(listOfRecords,countRec,typeOfRecord){

        let allDataArray =[];
        let parentRecsTempArr=[];
        console.log('loanDateRtr ==',this.loanDateRtr) //2023-11-03
        const loanDateRtr1 = String(this.loanDateRtr);
        const dateObj = new Date(loanDateRtr1);
        const month = dateObj.getMonth();
        const year = dateObj.getFullYear();
        console.log(`Month: ${month}, Year: ${year}`);
    
        let arrMon= this.getLast12Months(month,year);
            
        if(listOfRecords !=='undefined' && listOfRecords)
        {
            listOfRecords.forEach((record, index) => {
            const { ChildReords, parentRecord } = record || {};
    
            if (ChildReords && parentRecord) {
                console.log(`Processing record ${index + 1}`);
                    parentRecsTempArr.push(parentRecord);
                // Process child records and push them into the childRecordsMca array
                const processedChildRecords = ChildReords.map(child => ({
                    ...child,
                    ParentRecord: parentRecord // Attach parent record to each child
                }));
    
                this.childRecordsMca.push(processedChildRecords);
                    console.log('This.parentRecordsMca ==> ',parentRecsTempArr)
            } else {
                console.error(`ChildReords or parentRecord is undefined for record ${index + 1}`);
            }
        });

            parentRecsTempArr.forEach((rec,index) => {
                let tempArray = [];
                if (rec) {
                if(countRec != 0){
                    tempArray.push(index+1+countRec);
                }else{
                    tempArray.push(index+1);
                }    
                
                tempArray.push(rec.Source__c || ''); // Source
                tempArray.push(rec.NatureOfLoan__c || ''); // Nature of loan
                tempArray.push(rec.Applicant__r.FullName__c ? rec.Applicant__r.FullName__c : '');
                tempArray.push(rec.LoanCapacity__c || ''); // Loan Capacity

                if(rec.FinancierName__c && rec.FinancierNameID__c){
                    tempArray.push(rec.FinancierName__c || ''); // Financier Name
                }else{
                    tempArray.push('')
                }

                 console.log('date DisbursalDate__c :',rec.DisbursalDate__c) 
                 console.log('date closed :',rec.CloseDate__c)  
                 
                 
                if (rec.DisbursalDate__c && this.isValidDate(rec.DisbursalDate__c)) {
                    let dateResult = this.formatDateToDDMMYYYY(rec.DisbursalDate__c);
                    tempArray.push(dateResult);
                } else {
                    tempArray.push(''); // Blank if invalid or empty date
                }

                if (rec.CloseDate__c && this.isValidDate(rec.CloseDate__c)) {
                    let dateResult1 = this.formatDateToDDMMYYYY(rec.CloseDate__c);
                    tempArray.push(dateResult1);
                } else {
                    tempArray.push(''); // Blank if invalid or empty date
                }

                
                tempArray.push(rec.LoanAmount__c || ''); // Loan Amount

                if (rec.CurrentOs__c !== undefined && rec.CurrentOs__c !== null) {
                // Convert to a string to ensure leading zeros are retained in Excel
                tempArray.push(rec.CurrentOs__c.toString());
                } else {
                    tempArray.push(''); // Empty string if the field is null or undefined
                }

                tempArray.push(rec.EMISource__c || ''); // EMI source
                tempArray.push(rec.EMI__c || ''); // EMI

                if (rec.Tenure__c !== undefined && rec.Tenure__c !== null) {
                tempArray.push(rec.Tenure__c.toString());
                } else {
                    tempArray.push(''); 
                }

                if (rec.NoEMIPaid__c !== undefined && rec.NoEMIPaid__c !== null) {
                tempArray.push(rec.NoEMIPaid__c.toString());
                } else {
                    tempArray.push(''); 
                }

                if (rec.TenureLeft__c !== undefined && rec.TenureLeft__c !== null) {
                tempArray.push(rec.TenureLeft__c.toString());
                } else {
                    tempArray.push(''); 
                }

                
                tempArray.push(rec.Treatment__c || ''); // Treatment
                tempArray.push(rec.ConsiderObligation__c || ''); // Consider for Obligation

                if(rec.Repayment_Bank__c && rec.RepaymentBankID__c){
                    tempArray.push(rec.Repayment_Bank__c || ''); // Repayment Bank
                }else{
                    tempArray.push('')
                }

                tempArray.push(parseFloat(rec.RepayAc__c) || '')

                tempArray.push(rec.Overdues__c || ''); // Overdues
                
                
                
                if (rec.MaxDPDLst3month__c !== undefined && rec.MaxDPDLst3month__c !== null) {
                    // Convert to a string to ensure leading zeros are retained in Excel
                tempArray.push(rec.MaxDPDLst3month__c.toString());
                } else {
                    tempArray.push(''); // Empty string if the field is null or undefined
                }

                if (rec.MaxDPDLst6month__c !== undefined && rec.MaxDPDLst6month__c !== null) {
                // Convert to a string to ensure leading zeros are retained in Excel
                tempArray.push(rec.MaxDPDLst6month__c.toString());
                } else {
                    tempArray.push(''); // Empty string if the field is null or undefined
                }

                if (rec.MaxDPDLst12month__c !== undefined && rec.MaxDPDLst12month__c !== null) {
                // Convert to a string to ensure leading zeros are retained in Excel
                tempArray.push(rec.MaxDPDLst12month__c.toString());
                } else {
                    tempArray.push(''); // Empty string if the field is null or undefined
                }
                
                tempArray.push(rec.Ever90__c || ''); // Ever 90+
                tempArray.push(rec.Status__c || ''); // Status
                tempArray.push(rec.Remarks__c || ''); // Remarks
                

                if (rec.BounceInLast12Months__c !== undefined && rec.BounceInLast12Months__c !== null) {
                // Convert to a string to ensure leading zeros are retained in Excel
                tempArray.push(rec.BounceInLast12Months__c.toString());
                } else {
                    tempArray.push(''); // Empty string if the field is null or undefined
                }


                if (rec.BounceInLast18Months__c !== undefined && rec.BounceInLast18Months__c !== null) {
                    // Convert to a string to ensure leading zeros are retained in Excel
                tempArray.push(rec.BounceInLast18Months__c.toString());
                } else {
                    tempArray.push(''); // Empty string if the field is null or undefined
                }

                if (rec.TotalBouncesInRTR__c !== undefined && rec.TotalBouncesInRTR__c !== null) {
                // Convert to a string to ensure leading zeros are retained in Excel
                tempArray.push(rec.TotalBouncesInRTR__c.toString());
                } else {
                    tempArray.push(''); // Empty string if the field is null or undefined
                }


                const monthValues = {
                    Month0: '',
                    Month1: '',
                    Month2: '',
                    Month3: '',
                    Month4: '',
                    Month5: '',
                    Month6: '',
                    Month7: '',
                    Month8: '',
                    Month9: '',
                    Month10: '',
                    Month11: '',
                    Month12: ''
                };

                if(typeOfRecord === 'Auto'){
                    console.log('rec.Applicant_Obligation_detail__r Auto :',rec.Applicant_Obligation_detail__r)
                    if(rec.Applicant_Obligation_detail__r){
                        if(rec.Applicant_Obligation_detail__r.length === 26){
                            const limitedRecords = rec.Applicant_Obligation_detail__r.slice(0, 13);
                            limitedRecords.forEach((recs) => {
                                tempArray.push(recs.EMI_Clearance_Date_IdentifierTest__c || ''); // Add child details or empty string
                            });
                        }else if(rec.Applicant_Obligation_detail__r.length === 13)
                        {
                            const limitedRecords = rec.Applicant_Obligation_detail__r;
                            limitedRecords.forEach((recs) => {
                            tempArray.push(recs.EMI_Clearance_Date_IdentifierTest__c || ''); // Add child details or empty string
                        });
                        }else
                        {
                            // console.log('Different Size Auto records')
                            // rec.Applicant_Obligation_detail__r.forEach((recs) => {
                            //     tempArray.push(recs.EMI_Clearance_Date_IdentifierTest__c || ''); // Add child details or empty string
                            // });

                            rec.Applicant_Obligation_detail__r.forEach((recs) => {
                                const identifier = String(recs.EMI_Clearance_Date_Identifier__c).trim();
                                const testValue = recs.EMI_Clearance_Date_IdentifierTest__c;
                        
                                // Only add values for recognized months
                                if (identifier in monthValues) {
                                    monthValues[identifier] = testValue || ''; // If testValue is falsy, assign an empty string
                                }
                            });

                            for (let month in monthValues) {
                                tempArray.push(monthValues[month]);
                            }
                        }
                    }
                    else{
                        arrMon.forEach(() => tempArray.push(''));
                    }
                }
                else{
                    console.log('else length arr :',rec.Applicant_Obligation_detail__r.length)
                    console.log('else length arr start:',rec.Applicant_Obligation_detail__r)
                    if (rec.Applicant_Obligation_detail__r) {
                        if(rec.Applicant_Obligation_detail__r.length === 13){
                            rec.Applicant_Obligation_detail__r.forEach((recs) => {
                                console.log('recs EMI_Clearance_Date_Identifier__c with length 13 =',recs.EMI_Clearance_Date_Identifier__c)
                                tempArray.push(recs.EMI_Clearance_Date_IdentifierTest__c || ''); // Add child details or empty string
                            });
                        }
                        else{
                            rec.Applicant_Obligation_detail__r.forEach((recs) => {
                                const identifier = String(recs.EMI_Clearance_Date_Identifier__c).trim();
                                const testValue = recs.EMI_Clearance_Date_IdentifierTest__c;
                        
                                // Only add values for recognized months
                                if (identifier in monthValues) {
                                    monthValues[identifier] = testValue || ''; // If testValue is falsy, assign an empty string
                                }
                            });

                            for (let month in monthValues) {
                                tempArray.push(monthValues[month]);
                            }
                        }
                    } else {
                        arrMon.forEach(() => tempArray.push(''));
                    }
                }
                
                  //Pushing parent Id to Update 
                  console.log('Id fro Parent ::',rec.Id)
                  //tempArray.push(rec.Id);
                  tempArray.push(rec.Id || '');
                  allDataArray.push(tempArray);
                }
              });
              
        console.log('Excel allDataArray ==',allDataArray);
        return allDataArray;
    }
    else{
        this.showToast("Error", "error", 'There are no records for Download',"sticky");
    }
    }


    isValidDate(dateString) {
        const date = new Date(dateString);
        return !isNaN(date.getTime()); // Returns true if valid, false if invalid
    }

    isExcelSerialNumber(input) {
        // Check if input is a number and falls within a reasonable range of Excel serial numbers
        return !isNaN(input) && input >= 1 && input <= 2958465; // Max value corresponds to year 9999
    }
    
    isValidDateString(dateStr) {
        // Check if the string matches the DD/MM/YYYY pattern
        const datePattern = /^(\d{2})\/(\d{2})\/(\d{4})$/;
        return datePattern.test(dateStr);
    }
    

    excelSerialToJSDate(serial) {
        const excelEpochStart = new Date(1900, 0, 1); // January 1, 1900
    
        // Adjust for Excel's leap year bug (adding a non-existent Feb 29, 1900)
        let offsetSerial = serial;
        if (serial >= 60) {
            offsetSerial -= 1; // Subtract 1 day for dates after Feb 28, 1900
        }
    
        const jsDate = new Date(excelEpochStart.getTime() + (offsetSerial - 1) * 24 * 60 * 60 * 1000);
    
        // Format date to YYYY-MM-DD (Salesforce format)
        const year = jsDate.getFullYear();
        const month = String(jsDate.getMonth() + 1).padStart(2, '0'); // Month is zero-indexed
        const day = String(jsDate.getDate()).padStart(2, '0');
    
        return `${year}-${month}-${day}`;
    }
    
    
    convertToSalesforceDate(input) {
        // Check if the input is a valid Excel serial number
        if (this.isExcelSerialNumber(input)) {
            return this.excelSerialToJSDate(Number(input));
        }
    
        // Check if the input is a valid date string in DD/MM/YYYY format
        if (this.isValidDateString(input)) {
                if(input){
                    if (input.includes('/')) {
                        console.log('slash');
                        const [day, month, year] = input.split('/');
                        return `${year}-${month}-${day}`; // Format as YYYY-MM-DD
                        
                    } else if (input.includes('-')) {
                        console.log('dash');
                        const [day, month, year] = input.split('-');//17/02/2024
                        return `${year}-${month}-${day}`; // Format as YYYY-MM-DD
                    } else {
                        console.log('Neither slash nor dash found');
                    }

                }
            }

        return '';
    }


    convertToSalesforceDateClosedDate(closeDate) {
        // If the closeDate is a number, assume it's an Excel serial number
        if (typeof closeDate === 'number') {
            // Convert Excel serial date to a JavaScript date
            const excelBaseDate = new Date(Date.UTC(1900, 0, 1)); // Use UTC to avoid timezone issues
            const actualDate = new Date(excelBaseDate.getTime() + (closeDate - 2) * 86400000); // Subtract 2 for Excel's leap year bug
            
            // Return the date in Salesforce compatible format (YYYY-MM-DD)
            return actualDate.toISOString().split('T')[0];
        }
        
        // If the closeDate is a string, assume it's already a valid date string in a supported format
        if (typeof closeDate === 'string') {
            // Try to parse it as a date in UTC
            const parsedDate = new Date(Date.parse(closeDate + 'T00:00:00Z')); // Force UTC
            if (!isNaN(parsedDate)) {
                // Return the date in Salesforce compatible format (YYYY-MM-DD)
                return parsedDate.toISOString().split('T')[0];
            } else {
                throw new Error('Invalid date string format');
            }
        }
    
        // If it's not a valid number or string, throw an error
        throw new Error('Invalid date type');
    }
    
    


    getLast12Months(monthData,yearData) {
        
        const monthMap = {0: 'JAN',
            1: 'FEB',
            2: 'MAR',
            3: 'APR',
            4: 'MAY',
            5: 'JUN',
            6: 'JUL',
            7: 'AUG',
            8: 'SEP',
            9: 'OCT',
            10: 'NOV',
            11: 'DEC'
        };
        const months = [];
        for (let i = 0; i < 13; i++) {
            const formattedMonth = monthMap[monthData];
            months.unshift(`${formattedMonth}-${yearData}`);  // Add to the start of the array
            
            // Move to the previous month
            monthData--;
            if (monthData < 0) {
                monthData = 11;
                yearData--;
            }
        }
        
        return months.reverse(); // To have the most recent month first
    }

    @track showPopForManBnk;
    @track uploadedFiles=[];
    @track acceptedFormats = ['.xls', '.xlsx'];

    @track wrapBankObj={};

    showUploadExcelFile(){
        console.log('this.loanDateRtr ==',this.loanDateRtr)
        console.log('this.isLoginDatePresent==',this.isLoginDatePresent)
        if( this.loanDateRtr && this.isLoginDatePresent){
            this.showPopForManBnk=true;
            
        }else{
            this.showToast("Error!", "error", 'Please Enter the Latest RTR Month First', "sticky");
        }
    }

    hideManualUplModalBox(){
        this.showPopForManBnk=false;
        this.uploadedFiles='';
    }

    handleUploadFinished(event){
        this.uploadedFiles = event.detail.files;
        const file=this.uploadedFiles[0]
        const fileType = '.' + file.name.split('.').pop();
       
        if(fileType=='.xls' ||fileType=='.xlsx'){
           
        }else{
            this.showToast("Error!", "error","You can only upload excel format type file."); 
            this.uploadedFiles=[];
        }
    }

    handleFileRemove(){
        this.uploadedFiles=''
    }

    async handleExcelUpload(){
         if(this.uploadedFiles.length > 0) {   
             this.ExcelToJSON(this.uploadedFiles[0]);
         }else{
             this.showToast("Error!", "error","please select File First.");
         }

         this.uploadedFiles=''
     }



     @track wrapBankObjList=[];

     async ExcelToJSON(file){
        this.showSpinner=true;
        let errorMessages = [];
        if (file) {
            const reader = new FileReader();
            reader.onload =async () => {
            const workbook = XLSX.read(reader.result, { type: 'binary' });
            const sheetName = workbook.SheetNames[0]; // Assuming the first sheet
            const sheet = workbook.Sheets[sheetName];
            const jsonData = XLSX.utils.sheet_to_row_object_array(sheet);
            console.log('jsonData'+JSON.stringify(jsonData)); // Output JSON data to console
            var data = JSON.stringify(jsonData);
            const records = JSON.parse(data);
            let parentInsertObj={}; 
            const loanDateRtr1 = String(this.loanDateRtr);
            const dateObj = new Date(loanDateRtr1);
            const month = dateObj.getMonth();
            const year = dateObj.getFullYear();
            console.log(`Month: ${month}, Year: ${year}`);
            let arrMon= this.getLast12Months(month,year);let parentRecords = [];  // To collect all parent records
            let childRecords = [];   // To collect all child records
            let parentCounter = 0;   // Counter for parent records
            let childCounter = 0; 

            for (let i = 0; i < records.length; i++) 
            {
                let rec = records[i];
                if(rec){
                let childInsertObjs = [];
                console.log('inside for loop ==')
                let parentInsertObj = {};
                let strFin = rec['Financier Name'] ? rec['Financier Name'] :'Not Available';
                let strRepay = rec['Repayment Bank'] ? rec['Repayment Bank'] :'Not Available';
                const bankDataArray = await this.idMapForBanks(strFin,strRepay);
                parentInsertObj.Remarks__c=rec['Remarks']

                let sourceArr= ['Consumer CIBIL','Consumer CRIF','Consumer Equifax','Consumer Experian','Manual','Commercial CIBIL','Commercial CRIF','Commercial Equifax','Commercial Experian'];
               
                if (rec['Source'] && !sourceArr.includes(rec['Source'])) {
                    errorMessages.push(`Please enter a valid Source Name: ${rec['Source']}`);
                }
                
                if(this.tempArrAppConst){
                this.tempArrAppConst.forEach(item=>{
                    if(rec['Name of Borrower'] && rec['Name of Borrower'] === item.FullName__c){
                        parentInsertObj.Applicant__c= item.Id;
                    }
                })
                }

                if(parentInsertObj.Applicant__c){
                    console.log('Applicant__c Id is :',parentInsertObj.Applicant__c)
                }else{
                    parentInsertObj.Applicant__c= this.applicantId ? this.applicantId : ''; //Primary Id
                }
                
                parentInsertObj.BounceInLast12Months__c=rec['Bounce in last 12 months']
                parentInsertObj.BounceInLast18Months__c=rec['Bounce in last 18 months']
                
                if(rec['Source'] && rec['Source']==='Manual'){
                    parentInsertObj.NatureOfLoan__c=rec['Nature of loan'];
                }
                
                if(rec['Nature of loan'] && this.mdtNames && rec['Source'] && rec['Source']==='Manual'){
                    
                    let strNatureLoan = rec['Nature of loan'].replace(/[^a-zA-Z ]/g, "").replaceAll("  "," ")
                    this.mdtNames.forEach(recA => {
                        let strNatureLoanMeta = recA.Loan_Type__c.replace(/[^a-zA-Z ]/g, "").replaceAll("  "," ")
                        if(strNatureLoanMeta === strNatureLoan){
                            parentInsertObj.NatureOfLoanID__c=recA.Id;
                        }
                    })
                }

                if (rec['Financier Name'] && !this.getFinBankArray.includes(rec['Financier Name'])) {
                    errorMessages.push(`Please enter a valid Financier Name: ${rec['Financier Name']}`);
                } else {
                    parentInsertObj.FinancierName__c = rec['Financier Name'] ? rec['Financier Name'].toUpperCase() : 'OTHER NBFC';
                }

                //close date logic
                const closeDate = rec['Close date'];
               
                console.log('closeDate =====',closeDate)
                if (closeDate && (typeof closeDate === 'string' || typeof closeDate === 'number')) {
                    const datePattern = /^(0[1-9]|[12][0-9]|3[01])[-\/](0[1-9]|1[0-2])[-\/](\d{4})$/;
                
                    if (typeof closeDate === 'string') {
                        // Check for valid date string format
                        if (datePattern.test(closeDate)) {
                            try {
                                const parts = closeDate.split(/[-\/]/);
                                const day = parseInt(parts[0], 10);
                                const month = parseInt(parts[1], 10);
                                const year = parseInt(parts[2], 10);
                
                                const isValidDate = (month === 2 && day <= 29 && ((year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0))) ||
                                                    (month === 4 || month === 6 || month === 9 || month === 11 ? day <= 30 : day <= 31);
                
                                if (isValidDate) {
                                    parentInsertObj.CloseDate__c = this.convertToSalesforceDateClosedDate(closeDate);
                                    console.log('Converted close date:', parentInsertObj.CloseDate__c);
                                } else {
                                    throw new Error('Invalid date');
                                }
                            } catch (error) {
                                console.error('Error processing close date:', error);
                                parentInsertObj.CloseDate__c = '';
                            }
                        } else {
                            // Invalid date format
                            console.log('Invalid date format:', closeDate);
                            parentInsertObj.CloseDate__c = '';
                            errorMessages.push(`Please enter a valid Close date format (DD/MM/YYYY or DD-MM-YYYY): ${closeDate}`);
                        }
                    } else if (typeof closeDate === 'number') {
                        // Assume it's an Excel date serial number
                        try {
                            parentInsertObj.CloseDate__c = this.convertFromExcelDate(closeDate);
                            console.log('Converted Excel close date:', parentInsertObj.CloseDate__c);
                        } catch (error) {
                            console.error('Error processing Excel close date:', error);
                            parentInsertObj.CloseDate__c = '';
                        }
                    } else {
                        parentInsertObj.CloseDate__c = '';
                        console.log('Invalid or missing close date:', closeDate);
                    }
                } else {
                    parentInsertObj.CloseDate__c = '';
                    console.log('Invalid or missing close date:', closeDate);
                }
                
                
                
                //Disbursal date logic
                if (rec['Source'] === 'Manual') {
                    const disbDate = rec['Disbursal date'];
                    
                    if (disbDate && (typeof disbDate === 'string' || typeof disbDate === 'number')) {
                        const datePattern = /^(0[1-9]|[12][0-9]|3[01])[-\/](0[1-9]|1[0-2])[-\/](\d{4})$/; // Matches DD/MM/YYYY or DD-MM-YYYY
                
                        if (datePattern.test(disbDate)) {
                            try {
                                parentInsertObj.DisbursalDate__c =  this.convertToSalesforceDate(disbDate); // this.convertToSalesforceDateClosedDate(disbDate);
                                console.log('Converted Disbursal date:', parentInsertObj.DisbursalDate__c);
                            } catch (error) {
                                console.error('Error processing Disbursal date:', error);
                                parentInsertObj.DisbursalDate__c = '';
                               // this.showToast("Error", "error", 'Error processing Disbursal date', "sticky");
                            }
                        } else if (typeof disbDate === 'number') {
                            // If Disbursal date is a number, assume it's an Excel date serial number
                            try {
                                parentInsertObj.DisbursalDate__c = this.convertFromExcelDate(disbDate);
                                console.log('Converted Excel Disbursal date:', parentInsertObj.DisbursalDate__c);
                            } catch (error) {
                                console.error('Error processing Excel Disbursal date:', error);
                                parentInsertObj.DisbursalDate__c = '';
                               // this.showToast("Error", "error", 'Error processing Excel Disbursal date', "sticky");
                            }
                        } else {
                            // Invalid date format
                            parentInsertObj.DisbursalDate__c = '';
                            errorMessages.push(`Please enter a valid Disbursal Date format (DD/MM/YYYY or DD-MM-YYYY): ${disbDate}`);
                        }
                    } else {
                        // If the Disbursal date is invalid or missing, set it to an empty string
                        parentInsertObj.DisbursalDate__c = '';
                        console.log('Invalid or missing Disbursal date:', disbDate);
                    }
                }
                
                if(rec['Treatment']){
                    if(rec['Treatment'] === 'To continue - Obligate'){
                        parentInsertObj.ConsiderObligation__c='Yes'
                    }else{
                        parentInsertObj.ConsiderObligation__c='No'
                    }
                    
                }



                parentInsertObj.Overdues__c=rec['Overdues'] 
                
                let repaymentAccount = rec['Repayment A/c Number'];


                if (repaymentAccount && !isNaN(repaymentAccount)) {
                    if(repaymentAccount <0 ){
                        errorMessages.push('Repayment A/c Number cannot be negative');
                    }else{
                        let strRepAcc = parseFloat(repaymentAccount);
                        parentInsertObj.RepayAc__c = String(strRepAcc);
                    }
                }else {
                    // If repaymentAccount is blank or contains non-numeric characters, set it as an empty string
                    parentInsertObj.RepayAc__c = '';
                    console.error('Repayment A/c Number contains non-numeric characters');
                }


                const arrTreatment =['Already closed','BT loan','Duplicate loan','EMI paid by else','Less than 12 EMI left','To be closed','To continue - Obligate'];
                console.log('rec[Treatment] ===',rec['Treatment'])
                console.log('rec[Treatment] == condition is ::',arrTreatment.includes(rec['Treatment']))
                if(rec['Treatment']){
                    if(arrTreatment.includes(rec['Treatment'])){
                        parentInsertObj.Treatment__c=rec['Treatment'];
                    }else{
                        console.log('treatment invalid as :',rec['Treatment'])
                        errorMessages.push(`Please enter correct Treatment option: ${rec['Treatment']}`);
                    }
                }else{
                    console.log('Treatment option is empty');
                }


                
                parentInsertObj.NoEMIPaid__c=rec['No of EMI paid']
                parentInsertObj.LoanAmount__c=rec['Loan Amount']
                parentInsertObj.TenureLeft__c=rec['Tenure Left']
                parentInsertObj.EMISource__c=rec['EMI source']  
                parentInsertObj.Tenure__c=rec['Tenure']
                parentInsertObj.LoanApplication__c=this.loanAppId;
                parentInsertObj.CurrentOs__c=rec['Current O/s']


                if(rec['Repayment Bank'] && this.getRepayBankArray.includes(rec['Repayment Bank'])){
                    parentInsertObj.Repayment_Bank__c=rec['Repayment Bank'] ?rec['Repayment Bank'].toUpperCase():'OTHERS';
                }else{
                    errorMessages.push(`Please enter correct valid Repayment Bank name: ${rec['Repayment Bank']}`);
                }
                
                parentInsertObj.EMI__c=rec['EMI']

                //LAK-10443
                if(rec['Max DPD in last 3 months'] && (isNaN(rec['Max DPD in last 3 months']) || parseFloat(rec['Max DPD in last 3 months']) <0)){
                    errorMessages.push(`Please enter a Positive value for Max DPD in last 3 months : ${rec['Max DPD in last 3 months']}`);
                }

                if(rec['Max DPD in last 6 months'] && (isNaN(rec['Max DPD in last 6 months']) || parseFloat(rec['Max DPD in last 6 months']) <0)){
                    errorMessages.push(`Please enter a Positive value for Max DPD in last 6 months : ${rec['Max DPD in last 6 months']}`);
                }

                if(rec['Max DPD in last 12 months'] && (isNaN(rec['Max DPD in last 12 months']) || parseFloat(rec['Max DPD in last 12 months']) <0)){
                    errorMessages.push(`Please enter a Positive value for Max DPD in last 12 months : ${rec['Max DPD in last 12 months']}`);
                }
                
                parentInsertObj.Ever90__c=rec['Ever 90+']
                parentInsertObj.Status__c=rec['Status']
                parentInsertObj.TotalBouncesInRTR__c=rec['Total Bounces in RTR']
                parentInsertObj.Id= rec['Id Parent']
                parentInsertObj.IdParent__c = 'Parent_' + parentCounter; 
                parentRecords.push(parentInsertObj);
                
                //Child 
                console.log('Assign parent Id as :',rec['Id Parent']);
                let idForParentB=  rec['Id Parent'];  
                console.log('Assign parent Id as 1 :',idForParentB); 
                    for (let i = 0; i < arrMon.length; i++) {
                        if (arrMon[i] in rec) {
                            let childObj = {
                                EMI_Clearance_Date_Identifier__c: 'Month' + i,
                                EMI_Clearance_Date_IdentifierTest__c: String(rec[arrMon[i]]),
                                BureauRespDtl__c : idForParentB ? idForParentB: '',
                                IdChildsParent__c : parentInsertObj.IdParent__c,
                               // IdSelf: 'Child_' + childCounter
                            };
                            childCounter++; // Increment the child counter
                            childInsertObjs.push(childObj);
                        }
                    }

            childRecords = childRecords.concat(childInsertObjs);
            parentCounter++;
            console.log('end loop ')
            }
        }
        //For Loop End
        

        // Show error messages if any
        if (errorMessages.length > 0) {
            for (const message of errorMessages) {
                this.showToast("Error", "error", message, "sticky");
            }
            this.showSpinner = false;
            return;
        } else {
            // Proceed with record upsert if no errors
            upsertParentChildRec({ parentRecords : parentRecords ,childRecords: childRecords , loanAppId :this.loanAppId})
                .then(result => {

                    this.handleAppObligDetails('test');
                    console.log('result ::',result)
                    this.showToast("Success", "success", result , "sticky" );
                    this.showSpinner=false;
                    
                    this.showPopForManBnk=false;
                    refreshApex(this._wiredManualData)
                    .then(() => {
                        console.log('Manual data refreshed successfully');
                    })
                    .catch(error => {
                        console.error('Error refreshing manual data:', error);
                    });
                    
                }).catch(error => {
                    let errorMessage = error.body ? error.body.message : 'Unknown error';
                    console.log('Error Found Obligation ::',errorMessage);
                    this.showToast("Error", "error", errorMessage, "sticky");
                    console.log('Error Found Obligation ::' + JSON.stringify(error));
                    this.showSpinner=false;
                    this.showPopForManBnk=false;

                    refreshApex(this._wiredManualData)
                    .then(() => {
                        console.log('Manual data refreshed successfully');
                    })
                    .catch(error => {
                        console.error('Error refreshing manual data:', error);
                    });
                    this.handleAppObligDetails('test');

                })
        }
        };
        reader.readAsBinaryString(file);
        }
        }
     /*
     async ExcelToJSON(file){
        this.showSpinner=true;
        if (file) {
            const reader = new FileReader();
            reader.onload =async () => {
            const workbook = XLSX.read(reader.result, { type: 'binary' });
            const sheetName = workbook.SheetNames[0]; // Assuming the first sheet
            const sheet = workbook.Sheets[sheetName];
            const jsonData = XLSX.utils.sheet_to_row_object_array(sheet);
            console.log('jsonData'+JSON.stringify(jsonData)); // Output JSON data to console
            var data = JSON.stringify(jsonData);
            const records = JSON.parse(data);
            let parentInsertObj={}; 
            const loanDateRtr1 = String(this.loanDateRtr);
            const dateObj = new Date(loanDateRtr1);
            const month = dateObj.getMonth();
            const year = dateObj.getFullYear();
            console.log(`Month: ${month}, Year: ${year}`);
            let arrMon= this.getLast12Months(month,year);let parentRecords = [];  // To collect all parent records
            let childRecords = [];   // To collect all child records
            let parentCounter = 0;   // Counter for parent records
            let childCounter = 0; 

            for (let i = 0; i < records.length; i++) 
            {
                let rec = records[i];
                if(rec){
                let childInsertObjs = [];
                console.log('inside for loop ==')

                let parentInsertObj = {};
                
                let strFin = rec['Financier Name'] ? rec['Financier Name'] :'Not Available';
                let strRepay = rec['Repayment Bank'] ? rec['Repayment Bank'] :'Not Available';


                const bankDataArray = await this.idMapForBanks(strFin,strRepay);
                
                //console.log('Bank data received:', bankDataArray);
                /* bankDataArray.forEach(bank => {
                console.log(`Bank Name: ${bank.BankName}, Id: ${bank.Id}`);
                if(bank.BankName === rec['Repayment Bank']){
                    idRepaym=bank.Id;
                }
                if(bank.BankName === rec['Financier Name']){
                    idFinbank=bank.Id;
                }
                if(bank.BankName=== 'OTHERS'){
                    
                    idRepayOth=bank.Id;
                }
                if(bank.BankName==='OTHER NBFC'){
                    idFinOth=bank.Id;
                }});  */
/*
                parentInsertObj.Remarks__c=rec['Remarks']

                //LAK-10428 
                // if(rec['Source'] && rec['Source'] === 'Manual'){
                //     parentInsertObj.Source__c =rec['Source']
                // }  

                let sourceArr= ['Consumer CIBIL','Consumer CRIF','Consumer Equifax','Consumer Experian','Manual','Commercial CIBIL','Commercial CRIF','Commercial Equifax','Commercial Experian'];
               
                if (rec['Source'] && !sourceArr.includes(rec['Source'])) {
                    this.showToast("Error", "error", 'Please enter a valid Source Name: ' + rec['Source'], "sticky");
                    this.showSpinner = false;
                    return;
                }


                if(this.tempArrAppConst){
                this.tempArrAppConst.forEach(item=>{
                    if(rec['Name of Borrower'] && rec['Name of Borrower'] === item.FullName__c){
                        parentInsertObj.Applicant__c= item.Id;
                    }
                })
                }
                if(parentInsertObj.Applicant__c){
                    console.log('Applicant__c Id is :',parentInsertObj.Applicant__c)
                }else{
                    parentInsertObj.Applicant__c= this.applicantId ? this.applicantId : ''; //Primary Id
                }

                parentInsertObj.BounceInLast12Months__c=rec['Bounce in last 12 months']
                parentInsertObj.BounceInLast18Months__c=rec['Bounce in last 18 months']



                if(rec['Source'] && rec['Source']==='Manual'){
                    parentInsertObj.NatureOfLoan__c=rec['Nature of loan'];
                }
                

                
                if(rec['Nature of loan'] && this.mdtNames && rec['Source'] && rec['Source']==='Manual'){
                    
                    let strNatureLoan = rec['Nature of loan'].replace(/[^a-zA-Z ]/g, "").replaceAll("  "," ")
                    this.mdtNames.forEach(recA => {
                        let strNatureLoanMeta = recA.Loan_Type__c.replace(/[^a-zA-Z ]/g, "").replaceAll("  "," ")
                        if(strNatureLoanMeta === strNatureLoan){
                            console.log('assign value as :',recA.Id)
                            parentInsertObj.NatureOfLoanID__c=recA.Id;
                        }
                    })
                }

                if(rec['Financier Name'] && this.getFinBankArray.includes(rec['Financier Name'])){
                    parentInsertObj.FinancierName__c=rec['Financier Name'] ? rec['Financier Name'].toUpperCase() :'OTHER NBFC';
                }else{
                    this.showToast("Error", "error", 'Please enter valid Financier Name : '+rec['Financier Name'], "sticky");
                    this.showSpinner =false;
                    return;
                }
                */
                //Commenting as per LAK-10393
                /*if(rec['Loan Capacity'] && rec['Source'] && rec['Source']==='Manual'){
                    parentInsertObj.LoanCapacity__c=rec['Loan Capacity']
                }*/

                //close date logic
              //  const closeDate = rec['Close date'];
               
               
                /*
                if (closeDate && (typeof closeDate === 'string' || typeof closeDate === 'number')) {
                const datePattern = /^(0[1-9]|[12][0-9]|3[01])[-\/](0[1-9]|1[0-2])[-\/](\d{4})$/; // Matches DD/MM/YYYY or DD-MM-YYYY
                if (datePattern.test(closeDate)) {
                    try {
                        // Convert the close date from the format DD/MM/YYYY or DD-MM-YYYY
                        parentInsertObj.CloseDate__c = this.convertToSalesforceDateClosedDate(closeDate);
                        console.log('Converted close date:', parentInsertObj.CloseDate__c);
                    } catch (error) {
                        console.error('Error processing close date:', error);
                        parentInsertObj.CloseDate__c = '';
                       // this.showToast("Error", "error", 'Error processing close date', "sticky");
                    }
                } else if (typeof closeDate === 'number') {
                    // If closeDate is a number, assume it's an Excel date serial number
                    try {
                        const excelDate = closeDate;
                        parentInsertObj.CloseDate__c = this.convertFromExcelDate(excelDate);
                        console.log('Converted Excel close date:', parentInsertObj.CloseDate__c);
                    } catch (error) {
                        console.error('Error processing Excel close date:', error);
                        parentInsertObj.CloseDate__c = '';
                      //  this.showToast("Error", "error", 'Error processing Excel close date', "sticky");
                    }
                } else {
                    // Invalid date format
                    parentInsertObj.CloseDate__c = '';
                    console.log('Invalid date format:', closeDate);
                    this.showToast("Error", "error", 'Please enter a valid Close date format (DD/MM/YYYY or DD-MM-YYYY)', "sticky");
                    this.showSpinner = false;
                    return;
                }
                } else {
                    parentInsertObj.CloseDate__c = '';
                    console.log('Invalid or missing close date:', closeDate);
                }*/
/*
                console.log('closeDate =====',closeDate)
                if (closeDate && (typeof closeDate === 'string' || typeof closeDate === 'number')) {
                    const datePattern = /^(0[1-9]|[12][0-9]|3[01])[-\/](0[1-9]|1[0-2])[-\/](\d{4})$/;
                
                    if (typeof closeDate === 'string') {
                        // Check for valid date string format
                        if (datePattern.test(closeDate)) {
                            try {
                                const parts = closeDate.split(/[-\/]/);
                                const day = parseInt(parts[0], 10);
                                const month = parseInt(parts[1], 10);
                                const year = parseInt(parts[2], 10);
                
                                const isValidDate = (month === 2 && day <= 29 && ((year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0))) ||
                                                    (month === 4 || month === 6 || month === 9 || month === 11 ? day <= 30 : day <= 31);
                
                                if (isValidDate) {
                                    parentInsertObj.CloseDate__c = this.convertToSalesforceDateClosedDate(closeDate);
                                    console.log('Converted close date:', parentInsertObj.CloseDate__c);
                                } else {
                                    throw new Error('Invalid date');
                                }
                            } catch (error) {
                                console.error('Error processing close date:', error);
                                parentInsertObj.CloseDate__c = '';
                            }
                        } else {
                            // Invalid date format
                            console.log('Invalid date format:', closeDate);
                            this.showToast("Error", "error", 'Please enter a valid Close date format (DD/MM/YYYY or DD-MM-YYYY)', "sticky");
                            parentInsertObj.CloseDate__c = '';
                            this.showSpinner = false;
                            return;
                        }
                    } else if (typeof closeDate === 'number') {
                        // Assume it's an Excel date serial number
                        try {
                            parentInsertObj.CloseDate__c = this.convertFromExcelDate(closeDate);
                            console.log('Converted Excel close date:', parentInsertObj.CloseDate__c);
                        } catch (error) {
                            console.error('Error processing Excel close date:', error);
                            parentInsertObj.CloseDate__c = '';
                        }
                    } else {
                        parentInsertObj.CloseDate__c = '';
                        console.log('Invalid or missing close date:', closeDate);
                    }
                } else {
                    parentInsertObj.CloseDate__c = '';
                    console.log('Invalid or missing close date:', closeDate);
                }
                
                
                
                //Disbursal date logic
                if (rec['Source'] === 'Manual') {
                    const disbDate = rec['Disbursal date'];
                    
                    if (disbDate && (typeof disbDate === 'string' || typeof disbDate === 'number')) {
                        const datePattern = /^(0[1-9]|[12][0-9]|3[01])[-\/](0[1-9]|1[0-2])[-\/](\d{4})$/; // Matches DD/MM/YYYY or DD-MM-YYYY
                
                        if (datePattern.test(disbDate)) {
                            try {
                                parentInsertObj.DisbursalDate__c =  this.convertToSalesforceDate(disbDate); // this.convertToSalesforceDateClosedDate(disbDate);
                                console.log('Converted Disbursal date:', parentInsertObj.DisbursalDate__c);
                            } catch (error) {
                                console.error('Error processing Disbursal date:', error);
                                parentInsertObj.DisbursalDate__c = '';
                               // this.showToast("Error", "error", 'Error processing Disbursal date', "sticky");
                            }
                        } else if (typeof disbDate === 'number') {
                            // If Disbursal date is a number, assume it's an Excel date serial number
                            try {
                                parentInsertObj.DisbursalDate__c = this.convertFromExcelDate(disbDate);
                                console.log('Converted Excel Disbursal date:', parentInsertObj.DisbursalDate__c);
                            } catch (error) {
                                console.error('Error processing Excel Disbursal date:', error);
                                parentInsertObj.DisbursalDate__c = '';
                               // this.showToast("Error", "error", 'Error processing Excel Disbursal date', "sticky");
                            }
                        } else {
                            // Invalid date format
                            parentInsertObj.DisbursalDate__c = '';
                            console.log('Invalid date format:', disbDate);
                            this.showToast("Error", "error", 'Please enter a valid Disbursal Date format (DD/MM/YYYY or DD-MM-YYYY)', "sticky");
                            this.showSpinner = false;
                            return;
                        }
                    } else {
                        // If the Disbursal date is invalid or missing, set it to an empty string
                        parentInsertObj.DisbursalDate__c = '';
                        console.log('Invalid or missing Disbursal date:', disbDate);
                    }
                }
                
                if(rec['Treatment']){
                    if(rec['Treatment'] === 'To continue - Obligate'){
                        parentInsertObj.ConsiderObligation__c='Yes'
                    }else{
                        parentInsertObj.ConsiderObligation__c='No'
                    }
                    
                }



                parentInsertObj.Overdues__c=rec['Overdues'] 
                
                let repaymentAccount = rec['Repayment A/c Number'];


                if (repaymentAccount && !isNaN(repaymentAccount)) {
                    if(repaymentAccount <0 ){
                        this.showToast("Error", "error", 'Repayment A/c Number cannot be negative', "sticky");
                    }else{
                        let strRepAcc = parseFloat(repaymentAccount);
                        parentInsertObj.RepayAc__c = String(strRepAcc);
                    }
                }else {
                    // If repaymentAccount is blank or contains non-numeric characters, set it as an empty string
                    parentInsertObj.RepayAc__c = '';
                    console.error('Repayment A/c Number contains non-numeric characters');
                }


                const arrTreatment =['Already closed','BT loan','Duplicate loan','EMI paid by else','Less than 12 EMI left','To be closed','To continue - Obligate'];
                console.log('rec[Treatment] ===',rec['Treatment'])
                console.log('rec[Treatment] == condition is ::',arrTreatment.includes(rec['Treatment']))
                if(rec['Treatment']){
                    if(arrTreatment.includes(rec['Treatment'])){
                        parentInsertObj.Treatment__c=rec['Treatment'];
                    }else{
                        console.log('treatment invalid as :',rec['Treatment'])
                        this.showToast("Error!", "error", "Please enter correct Treatment option", "sticky");
                        this.showSpinner =false;
                        return;
                    }
                }else{
                    console.log('Treatment option is empty');
                }


                
                parentInsertObj.NoEMIPaid__c=rec['No of EMI paid']
                parentInsertObj.LoanAmount__c=rec['Loan Amount']
                parentInsertObj.TenureLeft__c=rec['Tenure Left']
                parentInsertObj.EMISource__c=rec['EMI source']  
                parentInsertObj.Tenure__c=rec['Tenure']
               // parentInsertObj.Applicant__c= rec['Applicant__c'];
                parentInsertObj.LoanApplication__c=this.loanAppId;
                parentInsertObj.CurrentOs__c=rec['Current O/s']


                if(rec['Repayment Bank'] && this.getRepayBankArray.includes(rec['Repayment Bank'])){
                    parentInsertObj.Repayment_Bank__c=rec['Repayment Bank'] ?rec['Repayment Bank'].toUpperCase():'OTHERS';
                }else{
                    this.showToast("Error!", "error", "Please enter correct valid Repayment Bank name", "sticky"); 
                    this.showSpinner =false;
                    return;
                }
                



                parentInsertObj.EMI__c=rec['EMI']

                //LAK-10443
                if(rec['Max DPD in last 3 months'] && (isNaN(rec['Max DPD in last 3 months']) || parseFloat(rec['Max DPD in last 3 months']) <0)){
                    this.showToast("Error!", "error", "Please enter a Positive value for Max DPD in last 3 months :"+rec['Max DPD in last 3 months'], "sticky"); 
                    this.showSpinner =false;
                    return;
                }

                if(rec['Max DPD in last 6 months'] && (isNaN(rec['Max DPD in last 6 months']) || parseFloat(rec['Max DPD in last 6 months']) <0)){
                    this.showToast("Error!", "error", "Please enter a Positive value for Max DPD in last 6 months : "+rec['Max DPD in last 6 months'], "sticky"); 
                    this.showSpinner =false;
                    return;
                }

                if(rec['Max DPD in last 12 months'] && (isNaN(rec['Max DPD in last 12 months']) || parseFloat(rec['Max DPD in last 12 months']) <0)){
                    this.showToast("Error!", "error", "Please enter a Positive value for Max DPD in last 12 months : "+rec['Max DPD in last 12 months'], "sticky"); 
                    this.showSpinner =false;
                    return;
                }

                // parentInsertObj.MaxDPDLst3month__c=rec['Max DPD in last 3 months']
                // parentInsertObj.MaxDPDLst6month__c=rec['Max DPD in last 6 months']
                // parentInsertObj.MaxDPDLst12month__c=rec['Max DPD in last 12 months']


                parentInsertObj.Ever90__c=rec['Ever 90+']
                parentInsertObj.Status__c=rec['Status']
                parentInsertObj.TotalBouncesInRTR__c=rec['Total Bounces in RTR']
                parentInsertObj.Id= rec['Id Parent']
                parentInsertObj.IdParent__c = 'Parent_' + parentCounter; 
                parentRecords.push(parentInsertObj);
                
                //Child 
                console.log('Assign parent Id as :',rec['Id Parent']);
                let idForParentB=  rec['Id Parent'];  
                console.log('Assign parent Id as 1 :',idForParentB); 
                    for (let i = 0; i < arrMon.length; i++) {
                        if (arrMon[i] in rec) {
                            let childObj = {
                                EMI_Clearance_Date_Identifier__c: 'Month' + i,
                                EMI_Clearance_Date_IdentifierTest__c: String(rec[arrMon[i]]),
                                BureauRespDtl__c : idForParentB ? idForParentB: '',
                                IdChildsParent__c : parentInsertObj.IdParent__c,
                               // IdSelf: 'Child_' + childCounter
                            };
                            childCounter++; // Increment the child counter
                            childInsertObjs.push(childObj);
                        }
                    }

            childRecords = childRecords.concat(childInsertObjs);
            parentCounter++;
            console.log('end loop ')
            }
        }
        //For Loop End
         
           upsertParentChildRec({ parentRecords : parentRecords ,childRecords: childRecords , loanAppId :this.loanAppId})
                .then(result => {

                    this.handleAppObligDetails('test');
                    console.log('result ::',result)
                    this.showToast("Success", "success", result , "sticky" );
                    this.showSpinner=false;
                    
                    this.showPopForManBnk=false;
                    refreshApex(this._wiredManualData)
                    .then(() => {
                        console.log('Manual data refreshed successfully');
                    })
                    .catch(error => {
                        console.error('Error refreshing manual data:', error);
                    });
                    
                    */
                    /*
                    refreshApex(this._wiredAppObliResponse)
                    .then(() => {
                        console.log('App obligation data refreshed successfully');
                       // window.location.reload();
                    })
                    .catch(error => {
                        console.error('Error refreshing app obligation data:', error);
                       // window.location.reload();
                    });
                    */
               /* }).catch(error => {

                    let errorMessage = error.body ? error.body.message : 'Unknown error';
                    console.log('Error Found Obligation ::',errorMessage);
                    this.showToast("Error", "error", errorMessage, "sticky");
                    console.log('Error Found Obligation ::' + JSON.stringify(error));
                    this.showSpinner=false;
                    this.showPopForManBnk=false;

                    refreshApex(this._wiredManualData)
                    .then(() => {
                        console.log('Manual data refreshed successfully');
                    })
                    .catch(error => {
                        console.error('Error refreshing manual data:', error);
                    });
                    this.handleAppObligDetails('test');

                })
                
             };
            reader.readAsBinaryString(file);
            
        }
        }*/

        getAllFinancierBanksData(){
            getSobjectDataNonCacheable()
        }

        @track repaymentParam = {
            ParentObjectName: 'SFDCBANKMaster__c',
            parentObjFields: ['Id', 'Name', 'BankName__c', 'BankCode__c'], 
            queryCriteria: ' where BankName__c !=null'
        }

        @track financiersParam  = {
            ParentObjectName: 'BalTranFinancier__c',
            parentObjFields: ['Id', 'Name', 'CRIFCode__c'],
            queryCriteria: ' where Name !=null'
        }

        @track _wiredFinanciersData;
        @track _wiredRepayData;

        @track finBankArray=[];
        @track repayBankArray=[];

        get getFinBankArray(){
            return this.finBankArray;
        }

        get getRepayBankArray(){
            return this.repayBankArray;
        }
        
        @wire(fetchSingleObject, { params: '$repaymentParam' })
        repaymentBankData(wiredRepayData) {
        const { data, error } = wiredRepayData;
        this._wiredRepayData = wiredRepayData;
        if (data) {
            let repayData1 = JSON.parse(JSON.stringify(data.parentRecords));
            //this.repayBankArray=repayData1;
            console.log('repayData1 ==',repayData1)
            let excelRepayData =[];
            for (var i = 0; i < repayData1.length; i++) {
                let recFin = repayData1[i];
                if(recFin.Id && recFin.BankName__c){
                    excelRepayData.push(recFin.BankName__c)
                }
            }

            this.repayBankArray=excelRepayData;
           
        } else if (error) {
            console.log(error);
        }

    }

    @wire(fetchSingleObject, { params: '$financiersParam' })
        finBankData(wiredFinanciersData) {
        const { data, error } = wiredFinanciersData;
        this._wiredFinanciersData = wiredFinanciersData;
        if (data) {
            let financiersData1 = JSON.parse(JSON.stringify(data.parentRecords));
            let excelFinData =[];
            for (var i = 0; i < financiersData1.length; i++) {
                let recFin = financiersData1[i];
                let objFin ={};
                if(recFin.Id && recFin.Name){
                    excelFinData.push(recFin.Name)
                }
            }
            this.finBankArray=excelFinData;
        } else if (error) {
            console.log(error);
        }

    }


    formatDateToDDMMYYYY(dateString) {
        if(dateString){
        const dateObj = new Date(dateString);
        const day = String(dateObj.getDate()).padStart(2, '0');
        const month = String(dateObj.getMonth() + 1).padStart(2, '0');
        const year = dateObj.getFullYear();
        return `${day}/${month}/${year}`;
        }else{
            return '';
        }
    }

    convertFromExcelDate(excelDate) {
        return new Date((excelDate - 25569) * 86400 * 1000).toISOString().split('T')[0]; // Format YYYY-MM-DD
    }
    //End Excel Changes

}