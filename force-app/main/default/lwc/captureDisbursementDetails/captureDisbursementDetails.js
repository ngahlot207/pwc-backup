import { LightningElement, track, wire, api } from 'lwc';

// Apex
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import createDocumentDetail from "@salesforce/apex/DocumentDetailController.createDocumentDetail";
import generateDocument from "@salesforce/apex/GeneratePDFandAttachToLoanApplication.generateDocument";
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import deleteRecords from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getSobjectDataWithoutCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjDtwithFltrRelatedRecordsWithoutCache';
import getSessionId from '@salesforce/apex/SessionUtil.getSessionId';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';

// Standard Libraries
import { getRecord, createRecord, updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import cometdlwc from "@salesforce/resourceUrl/cometd";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from "lightning/platformResourceLoader";
import { subscribe, publish, MessageContext, unsubscribe, releaseMessageContext, createMessageContext } from 'lightning/messageService';

// LDS
import { getObjectInfo, getPicklistValues, getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import UserId from "@salesforce/user/Id";
const userId = UserId;

// Object and Fields
import DISBUR_OBJ from '@salesforce/schema/Disbursement__c';
import LA_OBJ from "@salesforce/schema/LoanAppl__c";
import CURRENT_USER_ID from "@salesforce/user/Id";

// Platform Event
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";

// Custom labels
import Trachy_Pennydrop_ErrorMessage from '@salesforce/label/c.Trachy_Pennydrop_ErrorMessage';
import Trachy_ReqFields_ErrorMessage from '@salesforce/label/c.Trachy_ReqFields_ErrorMessage';
import Trachy_Save_SuccessMessage from '@salesforce/label/c.Trachy_Save_SuccessMessage';
import Trachy_RecordCreate_SuccessMessage from '@salesforce/label/c.Trachy_RecordCreate_SuccessMessage';
import Trachy_Upsert_SuccessMessage from '@salesforce/label/c.Trachy_Upsert_SuccessMessage';
import Trachy_Update_SuccessMessage from '@salesforce/label/c.Trachy_Update_SuccessMessage';
import Trachy_DisbursalAmt_ErrorMessage from '@salesforce/label/c.Trachy_DisbursalAmt_ErrorMessage';
import Trachy_Date_ErrorMessage from '@salesforce/label/c.Trachy_Date_ErrorMessage';
import Trachy_AccVerf_ErrorMessage from '@salesforce/label/c.Trachy_AccVerf_ErrorMessage';
import Trachy_Int_ErrorMessage from '@salesforce/label/c.Trachy_Int_ErrorMessage';
import Technical_PannyDrop_SuccessMessage from '@salesforce/label/c.Technical_PannyDrop_SuccessMessage';
import Trachy_SplChqAmt_ErrorMessage from '@salesforce/label/c.Trachy_SplChqAmt_ErrorMessage';
import SplitDisb_Del_SuccesMessage from '@salesforce/label/c.Deviation_Del_SuccesMessage';
import DisbMemoRdError from '@salesforce/label/c.DisbMemoRdError';
import disbursementMemo from '@salesforce/label/c.PageURLDisbusementMemo';
import GetTrancheDetails_SuccessMessage from '@salesforce/label/c.GetTrancheDetails_SuccessMessage';
import CancelledLoanAppl_ErrorMessage from '@salesforce/label/c.CancelledLoanAppl_ErrorMessage';
import InitiateTrancheNote from '@salesforce/label/c.InitiateTrancheNote';

export default class CaptureDisbursementDetails extends LightningElement {
    @track activeSection = ["A", "B", "C", "D"];
    @track showSpinner = false;
    @track loanApplicationData;
    @track showDocList = true;
    @track showDisburDetTable = false;
    @track loanApplSubStage;
    @track loanApplStage;
    countOpsVer = 0;
    sectionNames = new Set();

    customLabel = {
        Trachy_AccVerf_ErrorMessage,
        Trachy_Int_ErrorMessage,
        Trachy_Pennydrop_ErrorMessage,
        Technical_PannyDrop_SuccessMessage,
        Trachy_ReqFields_ErrorMessage,
        Trachy_Save_SuccessMessage,
        Trachy_RecordCreate_SuccessMessage,
        Trachy_Upsert_SuccessMessage,
        Trachy_Update_SuccessMessage,
        Trachy_DisbursalAmt_ErrorMessage,
        Trachy_Date_ErrorMessage,
        Trachy_SplChqAmt_ErrorMessage,
        disbursementMemo,
        DisbMemoRdError,
        SplitDisb_Del_SuccesMessage,
        GetTrancheDetails_SuccessMessage,
        CancelledLoanAppl_ErrorMessage,
        InitiateTrancheNote
    }
    @track genDM = "Please fill tranche details and related split disbursement records.";
    @track disbursementMemoType = ['Disbursement Memo'];
    @track disbursementMemoSubType = ['Disbursement Memo'];
    @track disbursementMemoCategory = ['Disbursement Memo'];

    @api hasEditAccess;
    @api layoutSize;
   
    @track currentUserId = CURRENT_USER_ID;

    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        this.handleLoanApplRecords(value);
    }

    get productOptions() {
        return [
            { label: 'Home Loan', value: 'Home Loan' },
            { label: 'Small Ticket LAP', value: 'Small Ticket LAP' },
            { label: 'Loan Against Property', value: 'Loan Against Property' },
            { label: 'Personal Loan', value: 'Personal Loan'},
            { label: 'Business Loan', value: 'Business Loan'}
        ];
    }

    @wire(MessageContext)
    MessageContext;

    @track sessionId;

    @wire(getSessionId)
    wiredSessionId({ error, data }) {
        if (data) {
            this.sessionId = data;
            loadScript(this, cometdlwc);
        } else if (error) {
            this.sessionId = undefined;
            console.log('Error In getSessionId = ', error);
        }
    }

    @track
    loanApplparams = {
        ParentObjectName: 'LoanAppl__c',
        ChildObjectRelName: 'Applicants__r',
        parentObjFields: ['Id', 'Name', 'FirstEMIDate__c', 'Product__c','CustomerName__c', 'Stage__c', 'SubStage__c', 'ProductSubType__c', 'DisbursalType__c', 
                          'SchmCode__c', 'Loan_Tenure_Months__c', 'SanLoanAmt__c', 'TotalLoanAmtInclInsurance__c', 'PendingDisbursalAmount__c', 'Total_PF_Amount__c',
                          'TotalLoanAmountIncCharges__c', 'OwnerId','EMIOptionsintranchedisbursementCase__c', 'RemPFDeductFromDisbursementAmount__c','Applicant__c',
                           'Final_Loan_Disbursal_Amount__c', 'PreEmiType__c', 'IsLoanApplCancelled__c', 'Status__c', 'Adjusted_Charge_68__c'],
        childObjFields: ['FName__c', 'LName__c', 'LoanAppln__c', 'CompanyName__c', 'Constitution__c', 'ApplType__c'],
        queryCriteria: ' where Id = \'' + this._loanAppId + '\''
    }

    @track
    disburParams = {
        ParentObjectName: 'Disbursement__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'ApplicationID__c', 'Loan_Appli__c', 'Product__c', 'Appl_Name__c', 'Loan_Tenu__c', 'Scheme__c', 'Loan_Appli__r.Final_Loan_Disbursal_Amount__c',  
                            'Total_Disb_Amt__c', 'Disbur_To__c', 'No_of_Disbur__c', 'Princ_Rec_on__c', 'Princ_Start_Date__c', 'Disbur_No__c', 'Finnone_Tranche_Disbursed_Amount__c', 
                            'Disbur_Desrp__c', 'Date_of_Disbur__c', 'Disbur_Status__c', 'Pend_Disbur_Amt__c','Index__c','DisbrDiscription__c','Split_Disbursement_Count__c', 'Loan_Appli__r.IsLoanApplCancelled__c', 'Loan_Appli__r.Stage__c', 'Loan_Appli__r.SubStage__c'],
        childObjFields: [],
        queryCriteria: ' where Loan_Appli__c = \'' + this._loanAppId + '\' ORDER BY Index__c ASC '
    }

    handleLoanApplRecords(value) {
        let tempParams = this.loanApplparams;
        tempParams.queryCriteria = ' where Id = \'' + this._loanAppId + '\''
        this.loanApplparams = { ...tempParams };

        let tempPar = this.disburParams;
        tempPar.queryCriteria = ' where Loan_Appli__c = \'' + this._loanAppId + '\' ORDER BY Index__c ASC '
        this.disburParams = { ...tempPar }
    }

    @track totPfAmt;
    @track loanPendingDisbAmt;
    @track totalDisForDisb;
    @track loanAmtIncCharges;
    @track lanOwnerId;
    @track loanProduct;
    @track loanScheme;
    @track loanTenure;
    @track loanApplicantName;
    @track loanPrimaryApplicant;
    @track loanDisbursalType;
    @track showPrincipleFields = false;
    @track loanPrincipalStartDate;
    @track loanNo;
    @track isSaveFunCalled = false;
    @track _wiredLoanApplData;

    @wire(getSobjectDatawithRelatedRecords, { params: '$loanApplparams' })
    handleLoanApplResponse(result) {
        const { data, error } = result;
        this._wiredLoanApplData = result;
        this.loanApplicationData = {};
        this.showDocList = false;
        if (data) {
            if (result.data) {
                this.loanApplicationData = result.data.parentRecord;
                this.processComponentVariables(this.loanApplicationData);
                if (result.data.ChildReords) {
                    this.processComponentChildVariables(result.data.ChildReords);
                }              
                this.showOnUIProcessor();
            } else if (error) {
                console.log('Error from loanApplparams', error);
            }
        }
    }

    @track preEMIAmtToBeDeducted;
    @track loanApplStatus;
    @track isLoanApplCancel;
    @track adjustedCharge68;
    processComponentVariables(recordData){
        if(recordData.DisbursalType__c){
            this.loanDisbursalType = recordData.DisbursalType__c;
            if(this.loanDisbursalType === 'SINGLE'){
                this.showPrincipleFields = false;
            }else if(this.loanDisbursalType === 'MULTIPLE'){
                this.showPrincipleFields = true;
            }
        }

        this.adjustedCharge68 = recordData.Adjusted_Charge_68__c ? recordData.Adjusted_Charge_68__c : 0;
        this.loanPrincipalStartDate = recordData.FirstEMIDate__c ? recordData.FirstEMIDate__c : new Date();
        this.loanProduct = recordData.Product__c ? recordData.Product__c : null;
        this.loanScheme = recordData.SchmCode__c ? recordData.SchmCode__c : null;
        this.loanTenure = recordData.Loan_Tenure_Months__c ? recordData.Loan_Tenure_Months__c : null;
        this.loanPendingDisbAmt = recordData.PendingDisbursalAmount__c ? recordData.PendingDisbursalAmount__c : null;
        this.loanAmtIncCharges = recordData.Final_Loan_Disbursal_Amount__c ? recordData.Final_Loan_Disbursal_Amount__c : null;
        this.loanNo = recordData.Name;
        this.loanPrimaryApplicant = recordData.Applicant__c;
        this.lanOwnerId = recordData.OwnerId;
        this.showDocList = true;
        this.loanApplStage = recordData.Stage__c ? recordData.Stage__c : null;
        this.loanApplSubStage = recordData.SubStage__c ? recordData.SubStage__c : null;
        this.preEMITypeValue = recordData.PreEmiType__c ? recordData.PreEmiType__c : null;
        this.loanApplStatus = recordData.Status__c ? recordData.Status__c : null;
        this.isLoanApplCancel = recordData.IsLoanApplCancelled__c ? recordData.IsLoanApplCancelled__c : null;
        this.loanApplOwnerId = recordData.OwnerId ? recordData.OwnerId : null;
        this.processAccessVariables();
    }

    processComponentChildVariables(recordDataChild){
        recordDataChild.forEach(applicantRecord => {
            if (applicantRecord.Constitution__c && applicantRecord.Constitution__c === 'INDIVIDUAL' && applicantRecord.ApplType__c && applicantRecord.ApplType__c === 'P') {
                this.loanApplicantName = applicantRecord.FName__c ? applicantRecord.LName__c ? `${applicantRecord.FName__c} ${applicantRecord.LName__c}` : applicantRecord.FName__c : applicantRecord.LName__c;
            } else if (applicantRecord.Constitution__c !== 'INDIVIDUAL' && applicantRecord.ApplType__c === 'P') {
                this.loanApplicantName = applicantRecord.CompanyName__c;
            }
        });
    }

    @track disbDisbMemo = true;

    processAccessVariables(){
        if (this.hasEditAccess === false) {
            if (this.lanOwnerId) {
                if (this.lanOwnerId == userId) {
                    this.disbDisbMemo = false
                } else {
                    this.disbDisbMemo = true
                }
            }
        }
    }

    /* Get Disbursement details */
    @track _wiredDisburData;
    @track disbursmentData = [];
    @track countOfDisbursementRecords;
    @track disbursalDataLoaded = false;

    @wire(getSobjectData, { params: '$disburParams'})
    handleDisbursementResponse(result) {
        const { data, error } = result;
        this._wiredDisburData = result;
        this.disbursmentData = [];
        this.disbursalDataLoaded = false;
        if(data){
            if(data.parentRecords && data.parentRecords.length > 0){                
                for (let i = 0; i < data.parentRecords.length; i++) {
                    var jsonDataDisbursement = {
                        "Id": data.parentRecords[i].Id,
                        "Name": data.parentRecords[i].Name,
                        "Loan_Appli__c": data.parentRecords[i].Loan_Appli__c ? data.parentRecords[i].Loan_Appli__c : null,
                        "Total_Disb_Amt__c": data.parentRecords[i].Total_Disb_Amt__c ? data.parentRecords[i].Total_Disb_Amt__c : null,
                        "Disbur_To__c": 'CUSTOMER',
                        "Princ_Rec_on__c": 'AMOUNT DISBURSED TILL DATE',
                        "Princ_Start_Date__c": data.parentRecords[i].Princ_Start_Date__c ? data.parentRecords[i].Princ_Start_Date__c : null,
                        "Disbur_Status__c": data.parentRecords[i].Disbur_Status__c ? data.parentRecords[i].Disbur_Status__c : null,
                        "Index__c": data.parentRecords[i].Index__c ? data.parentRecords[i].Index__c : null,
                        "Disbur_No__c" : data.parentRecords[i].Index__c ? data.parentRecords[i].Index__c : null,
                        "DisbrDiscription__c": data.parentRecords[i].DisbrDiscription__c ? data.parentRecords[i].DisbrDiscription__c : null,
                        "Date_of_Disbur__c": data.parentRecords[i].Date_of_Disbur__c ? data.parentRecords[i].Date_of_Disbur__c : null,
                        "Finnone_Tranche_Disbursed_Amount__c": data.parentRecords[i].Finnone_Tranche_Disbursed_Amount__c ? data.parentRecords[i].Finnone_Tranche_Disbursed_Amount__c : null,
                        "CountOfSplitRecords": data.parentRecords[i].Split_Disbursement_Count__c ? data.parentRecords[i].Split_Disbursement_Count__c : 0,
                        'disableInitTranch' :  (this.disableMode === true) ? true : (data.parentRecords[i].Disbur_Status__c) && (data.parentRecords[i].Disbur_Status__c == 'INITIATED' || data.parentRecords[i].Disbur_Status__c == 'DISBURSED') ? true : false,
                        'showInitiateButton': false
                    }
                    this.disbursmentData.push(jsonDataDisbursement);
                    console.log('disbursmentData>> '+JSON.stringify(this.disbursmentData));
                }
                  
                this.showDisburDetTable = true;
                this.countOfDisbursementRecords = data.parentRecords.length;
                this.maxClickCount = this.countOfDisbursementRecords + 1;            
               
            }else{
                this.showDisburDetTable = false;
            } 

            this.isDisbTypeChange = false;
            this.disbursalDataLoaded = true;
            this.showOnUIProcessor();
            
        }else if(error){
            console.log('Error getting data', error);
        }
    }

    showInitiateButtonFunction(calledFromInputChangeHandler){
        let disbursedFound = false;
        let initiateButtonFound = false;

        for (let i = 0; i <  this.disbursmentData.length; i++) {
            const processRecord =  this.disbursmentData[i];
            processRecord.showInitiateButton = false;
     
            if (!disbursedFound) {
                if (processRecord.Disbur_Status__c === "DISBURSED"  || processRecord.Disbur_Status__c === "PARTIALLY DISBURSED" || processRecord.Disbur_Status__c === "INITIATED") {
                    disbursedFound = true;
                    continue; // Move to the next record
                }
            } else if (!initiateButtonFound && calledFromInputChangeHandler) {
                if ((processRecord.Disbur_Status__c === "ENTERED" || processRecord.Disbur_Status__c === "INTEGRATION FAILURE") &&  processRecord.CountOfSplitRecords > 0 ) {
                    processRecord.showInitiateButton = true;
                    initiateButtonFound = true; // Set flag to indicate initiation button found
                } else {
                    processRecord.showInitiateButton = false;
                }
            }
            if (disbursedFound && initiateButtonFound) {
                break;
            }
        }
    }

    showOnUIProcessor(){
        if(this.loanApplicationData && this.loanApplicationData.DisbursalType__c && this.disbursalDataLoaded === true){
            if(this.loanApplicationData.DisbursalType__c === 'SINGLE'){
                this.showPrincipleFields = false;
                if(this.disbursmentDataCount > 0){           
                    const minValue = Math.min(...this.disbursmentData.map(item => item.Index__c));
                    this.disbursmentData.forEach(item => {
                        item.showOnUI = item.Index__c == minValue;
                        item.Date_of_Disbur__c = (item.Index__c == minValue && this.isDisbTypeChange == true) ? (this.todaysDate) : (item.Date_of_Disbur__c ? item.Date_of_Disbur__c : this.isSaveFunCalled == false ? this.todaysDate : null ) ;
                    });
                    this.isDisbTypeChange = false;
                }else{
                   
                    this.disbursmentData = [];
                    var disbursementRecord = {
                        'Loan_Appli__c': this._loanAppId,
                        'Princ_Start_Date__c': null,
                        'Index__c': 1,
                        'Disbur_No__c': 1,
                        'DisbrDiscription__c': 'TRANCHE-1',
                        'Total_Disb_Amt__c': null,
                        'Disbur_Status__c': null,
                        'Disbur_To__c': 'CUSTOMER',
                        'Princ_Rec_on__c': 'AMOUNT DISBURSED TILL DATE',
                        'Date_of_Disbur__c': this.todaysDate,
                        'Finnone_Tranche_Disbursed_Amount__c':null,
                        'showOnUI' : true,
                        'showInitiateButton': false,
                        'disableInitTranch' : (this.disableMode === true) ? true : false
                    };
                    this.disbursmentData.push(disbursementRecord);
                    this.showDisburDetTable = true;
                }
            }else if(this.loanApplicationData.DisbursalType__c === 'MULTIPLE'){
                this.showPrincipleFields = true;
                if(this.disbursmentDataCount > 0){
                    const minValue = Math.min(...this.disbursmentData.map(item => item.Index__c));
                    for(var i =0; i<this.disbursmentData.length; i++){
                        this.disbursmentData[i].showOnUI = true;
                        this.disbursmentData[i].Date_of_Disbur__c = (this.disbursmentData[i].Index__c === minValue && this.isDisbTypeChange === true) ? (this.todaysDate) : (this.disbursmentData[i].Date_of_Disbur__c ? this.disbursmentData[i].Date_of_Disbur__c : this.isSaveFunCalled == false && this.disbursmentData[i].Index__c === minValue ? this.todaysDate : null ) ;
                    
                    }
                    this.isDisbTypeChange = false;
                    
                    if(this.disbursmentDataCount == 1){
                        var disbursementRecordDummy2 = {
                            'Loan_Appli__c': this._loanAppId,
                            'Princ_Start_Date__c': null,
                            'Index__c': 2,
                            'Disbur_No__c': 2,
                            'DisbrDiscription__c': 'TRANCHE-2',
                            'Total_Disb_Amt__c': null,
                            'Finnone_Tranche_Disbursed_Amount__c':null,
                            'Disbur_Status__c': null,
                            'Disbur_To__c': 'CUSTOMER',
                            'Princ_Rec_on__c': 'AMOUNT DISBURSED TILL DATE',
                            'Date_of_Disbur__c': null,
                            'showOnUI' : true,
                            'disableInitTranch' : (this.disableMode === true) ? true : false
                            
                        }
                        this.disbursmentData.push(disbursementRecordDummy2);
                    }
                }else{
                    for(var i=0; i<2; i++){
                        var disbursementRecordDummy = {
                            'Loan_Appli__c': this._loanAppId,
                            'Princ_Start_Date__c': null,
                            'Index__c': i+1,
                            'Disbur_No__c': i+1,
                            'DisbrDiscription__c': 'TRANCHE-'+(i+1),
                            'Total_Disb_Amt__c': null,
                            'Finnone_Tranche_Disbursed_Amount__c':null,
                            'Disbur_Status__c': null,
                            'Disbur_To__c': 'CUSTOMER',
                            'Princ_Rec_on__c': 'AMOUNT DISBURSED TILL DATE',
                            'Date_of_Disbur__c': i === 0 ? this.todaysDate : null,
                            'showOnUI' : true,
                            'disableInitTranch' : (this.disableMode === true) ? true : false
                            
                        }
                        this.disbursmentData.push(disbursementRecordDummy);
                    }
                    this.showDisburDetTable = true;
                }
            }
            this.showInitiateButtonFunction(true);
            this.calculateDisbursalAmountHandler(false, false);
        }
    }

    @track disburToOptForDisb;

    @wire(getObjectInfo, { objectApiName: DISBUR_OBJ })
    objInfoDisbursement;

    @wire(getObjectInfo, { objectApiName: LA_OBJ })
    objInfoLoanApplication;

    @wire(getPicklistValuesByRecordType, {objectApiName: DISBUR_OBJ,recordTypeId: "$objInfoDisbursement.data.defaultRecordTypeId"})
    disbursedToPicklistHandler({ data, error }) {
        if (data) {
            this.disburToOptForDisb = [...this.generatePicklist(data.picklistFieldValues.Disbur_To__c)];
        }
    }

    @track princRecOptions;

    @wire(getPicklistValuesByRecordType, {objectApiName: DISBUR_OBJ,recordTypeId: "$objInfoDisbursement.data.defaultRecordTypeId"})
    prinRecOnPicklistHandler({ data, error }) {
        if (data) {
            this.princRecOptions = [...this.generatePicklist(data.picklistFieldValues.Princ_Rec_on__c)];
        }
    }

    @track disburStatOptions;

    @wire(getPicklistValuesByRecordType, {objectApiName: DISBUR_OBJ,recordTypeId: "$objInfoDisbursement.data.defaultRecordTypeId"})
    disbursedStatPicklistHandler({ data, error }) {
        if (data) {
            this.disburStatOptions = [...this.generatePicklist(data.picklistFieldValues.Disbur_Status__c)];
        }
    }

    @track disbTypeOptions;

    @wire(getPicklistValuesByRecordType, {objectApiName: LA_OBJ, recordTypeId: "$objInfoLoanApplication.data.defaultRecordTypeId"})  
    loanApplDisbursalTypePicklistHandler({ data, error }) {
        if (data) {
            this.disbTypeOptions = [...this.generatePicklist(data.picklistFieldValues.DisbursalType__c)];  
        }
    }

    get showInitiateTranchColm(){
        if(this.loanApplStage && this.loanApplSubStage && (this.loanApplStage === 'Disbursed' && this.loanApplSubStage === 'DI Check')){
            return true;
        }else{
            return false;
        }
    }

    get showGetStatusButton(){
        if(this.loanApplStage && this.loanApplSubStage && (this.loanApplStage === 'Disbursed' && this.loanApplSubStage === 'Additional Processing')){
            return true;
        }else{
            return false;
        }
    }

    generatePicklist(data) {
        return data.values.map((item) => ({
            label: item.label,
            value: item.value
        }));
    }

    @track disableMode = false;

    connectedCallback() {
        if(this.hasEditAccess === false) {
            this.disableMode = true;
            this.disableSplitButton = true;
        }
        else {
            this.disableMode = false;
            this.disableSplitButton = false;
        }
        this.scribeToMessageChannel();
        if(this._loanAppId){
            let tempParamsDisbursement = this.disburParams;
            tempParamsDisbursement.queryCriteria = ' where Loan_Appli__c = \'' + this._loanAppId + '\' ORDER BY Index__c ASC ';
            this.disburParams = { ...tempParamsDisbursement };
            this.getNonCachedData();
        }
    }

    renderedCallback(){
        this.handleRefreshAllData();
    }
  
    @track subscription;

    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }

    handleSaveThroughLms(values) {
        this.handleSave(values.validateBeforeSave);
    }

    handleSave(validate) {
        this.isSaveFunCalled = true;
        let isDisbursementDetailsCorrect;
        var uniqueIdVariable = [];
        if(this.disbursmentData && this.disbursmentData.length > 0){
            const idVariable = this.disbursmentData.filter(item => item.Id && item.showOnUI).map(item => item.Id);
            if(idVariable.length > 0){
                uniqueIdVariable = [...new Set(idVariable)];
            }
        }
        
        if(validate) {
            let isInputCorrect = this.reportValidity();
            if (isInputCorrect === true) {
                if(this.loanApplicationData && this.loanApplicationData.DisbursalType__c && this.loanApplicationData.DisbursalType__c === 'SINGLE'){
                    const totalRunTimeDisbursalAmountSingle = this.disbursmentData.reduce((total, data) => {
                        const disbursalAmountSingle = (data.showOnUI ===true) ? (parseFloat(data.Total_Disb_Amt__c) || 0) : 0;
                        return total + disbursalAmountSingle;
                    }, 0);

                    if(totalRunTimeDisbursalAmountSingle != this.loanAmtIncCharges){
                        this.showToastMessage('Error', 'For SINGLE Disbursal Type, Disbursement Amount should be equal to Loan Disbursal Amount.', 'error', 'sticky');
                        isDisbursementDetailsCorrect = false;
                    }
                }else{
                    isDisbursementDetailsCorrect = this.calculateDisbursalAmountHandler(true, true);
                }
                if(isDisbursementDetailsCorrect == false){
                    return;
                }else{
                    if(uniqueIdVariable.length > 0){
                        if(this.previousDateHandler(true, undefined)){  
                            this.splitDisbursementCalculatorProcessor(uniqueIdVariable);
                        }
                    }else{ 
                        if(this.previousDateHandler(true, undefined)){                 
                            this.handleUpsertData(false, false);               
                        }
                    }
                }
            } else {
                this.showToastMessage('Error', this.customLabel.Trachy_ReqFields_ErrorMessage, 'error', 'sticky');
            }
        }
        else {
            this.handleUpsertData(false, false);
        }
    }

    getNonCachedData(){
        getSobjectDataNonCacheable({ params: this.disburParams })
        .then(result => {
            if (result) {
                if (result.parentRecords && result.parentRecords.length > 0) {  
                    let totalRunTimeDisbursalAmountNonCache = 0;
                    let finalLoanDisbursalAmountNonCache = undefined;
                    let loanAppStatus = false;
                    let loanApplStage;
                    let loanApplSubStage;
                    var dataNonCache = result;
                    dataNonCache.parentRecords.forEach(record => {
                        if(record && ((record.Disbur_Status__c && record.Disbur_Status__c != 'CANCELLED') || !record.Disbur_Status__c)){
                        totalRunTimeDisbursalAmountNonCache += record.Finnone_Tranche_Disbursed_Amount__c ? parseFloat(record.Finnone_Tranche_Disbursed_Amount__c) : record.Total_Disb_Amt__c ? parseFloat(record.Total_Disb_Amt__c) : 0;
                       }
                        if(record.Loan_Appli__r && record.Loan_Appli__r.Final_Loan_Disbursal_Amount__c) {
                            finalLoanDisbursalAmountNonCache = record.Loan_Appli__r.Final_Loan_Disbursal_Amount__c ? record.Loan_Appli__r.Final_Loan_Disbursal_Amount__c : undefined;
                            loanAppStatus = record.Loan_Appli__r.IsLoanApplCancelled__c ? record.Loan_Appli__r.IsLoanApplCancelled__c : false;
                            loanApplStage = record.Loan_Appli__r.Stage__c ? record.Loan_Appli__r.Stage__c : null;
                            loanApplSubStage = record.Loan_Appli__r.SubStage__c ? record.Loan_Appli__r.SubStage__c : null;
                        }
                    });
                    if(!finalLoanDisbursalAmountNonCache){
                        this.showToastMessage('Error', 'Loan Disbursement Amount missing, please correct the details.', 'error', 'sticky');
                    }else if(totalRunTimeDisbursalAmountNonCache > finalLoanDisbursalAmountNonCache){
                        this.showToastMessage('Error', 'Sum of Disbursement Amount(s) cannot be greater than Loan Disbursement Amount.', 'error', 'sticky');
                    }

                if(loanAppStatus){
                        this.showToastMessage('Error', this.customLabel.CancelledLoanAppl_ErrorMessage, 'error', 'sticky');
                        this.disableMode = true;
                }else if(this.hasEditAccess === false){
                        this.disableMode = true;
                    }else
                    if(loanApplStage && loanApplSubStage && ((loanApplStage === 'Post Sanction') && (loanApplSubStage === 'Data Entry' || loanApplSubStage === 'Ops Query')) || ((loanApplStage === 'Disbursed') && loanApplSubStage === 'Additional Processing')){
                        this.disableMode = false;
                       
                    }else{
                        this.disableMode = true;
                    } 
                }
            }
        })
        .catch(error => {
            console.log('Error!! '+JSON.stringify(error));
        })
    }

    splitDisbursementCalculatorProcessor(disbursementRecordIds){
        this.showSpinner = true;
        let paramDisbSplitDisb = {
            ParentObjectName: 'Disbursement__c',
            ChildObjectRelName: 'Split_Disbursements__r',
            parentObjFields: ['Id', 'Split_Disbursement_s_Amount__c', 'Total_Disb_Amt__c', 'DisbrDiscription__c'],
            childObjFields: ['Id'],
            queryCriteria: ' Where Id  IN (\'' + disbursementRecordIds.join('\', \'') + '\') ',
        }

        getSobjectDataWithoutCacheable({ params: paramDisbSplitDisb })
        .then((result) => {
            var errorIsCount = 0;
            var dataReceivedForDisbSplitDisb = result;
            dataReceivedForDisbSplitDisb.forEach(item => {  
                if(item.parentRecord && item.parentRecord.Split_Disbursements__r && 
                    "Split_Disbursement_s_Amount__c" in item.parentRecord)
                {
                     
                    const splitSumAmount = item.parentRecord.Split_Disbursement_s_Amount__c;
                    const disbAmount = item.parentRecord.Total_Disb_Amt__c ? item.parentRecord.Total_Disb_Amt__c : 0;
                    if(splitSumAmount != disbAmount){
                        errorIsCount = errorIsCount + 1;
                        var errorText = 'Sum of Split Disbursement(s) Amount is not aligned with Disbursement Amount for '+item.parentRecord.DisbrDiscription__c+'. Please provide correct details.';
                        this.showToastMessage('Error',errorText,'error','sticky');
                    }
                }else if(item.parentRecord && item.parentRecord.DisbrDiscription__c === 'TRANCHE-1' && !item.parentRecord.Split_Disbursements__r){
                    errorIsCount = errorIsCount + 1;
                    var errorTextNoSplit = 'Split Disbursement(s) missing for '+item.parentRecord.DisbrDiscription__c+'. Please provide Split Disbursement Details';
                    this.showToastMessage('Error',errorTextNoSplit,'error','sticky');
                }
            })
            if(errorIsCount == 0){
                this.handleUpsertData(false, false); 
                
            }else{
                this.showSpinner = false;
            }
        })
        .catch(error =>{
            this.showSpinner = false;
        });
    }


    handleUpsertGenericData(recordData, objectName){
        this.showSpinner = true;
        if(recordData && recordData.length > 0){
            upsertMultipleRecord({ params: recordData })
            .then(result => {
                this.handleRefreshAllData();
                this.showSpinner = false;
                if(objectName === 'LoanApplication'){

                }
                if(result && result[0].IsLoanApplCancelled__c && result[0].IsLoanApplCancelled__c === true){
                    this.disableMode = true;
                }

                if(result && result[0].Stage__c && result[0].Stage__c === 'Disbursed' && result[0].SubStage__c
                 && (result[0].SubStage__c === 'Additional Processing Pool' || result[0].SubStage__c === 'Completed')){
                     location.reload(); 
                }
            
            }).catch(error => {
                console.log('upsert error -', JSON.stringify(error));
                this.showSpinner = false;
                this.showToastMessage("Error","Unexpected error occurred. Please try again. ", error.body.message, "error", "sticky");
            })
        }else{
            this.showSpinner = false;
        }
    }

    handleUpsertData(disbStatusUpdate, functionCalledPostSuccess) {
        var disbursementArrayData = [];
        var disbursementArrayDataDelete = [];
        if(this.disbursmentData && this.disbursmentData.length > 0) {
            this.showSpinner = true;
            var loanApplicationUpsertData = {
                Id: this._loanAppId,
                sobjectType: 'LoanAppl__c',
                DisbursalType__c : this.loanApplicationData.DisbursalType__c ? this.loanApplicationData.DisbursalType__c : null,
                PreEmiType__c : this.preEMITypeValue ? this.preEMITypeValue : null
            }
            console.log('loanApplicationUpsertData-------------->',loanApplicationUpsertData);
            for(var i=0; i<this.disbursmentData.length; i++){
                if(this.disbursmentData[i].showOnUI === true){
                    var disbursementObjectData = {
                        Loan_Appli__c: this._loanAppId,
                        Princ_Start_Date__c: this.disbursmentData[i].Princ_Start_Date__c ? this.disbursmentData[i].Princ_Start_Date__c : null,
                        Index__c: this.disbursmentData[i].Index__c ? this.disbursmentData[i].Index__c : null,
                        Disbur_No__c : this.disbursmentData[i].Index__c ? this.disbursmentData[i].Index__c : null,
                        DisbrDiscription__c: this.disbursmentData[i].DisbrDiscription__c ? this.disbursmentData[i].DisbrDiscription__c : null,
                        Total_Disb_Amt__c: this.disbursmentData[i].Total_Disb_Amt__c ? this.disbursmentData[i].Total_Disb_Amt__c : null,
                        Finnone_Tranche_Disbursed_Amount__c: this.disbursmentData[i].Finnone_Tranche_Disbursed_Amount__c ? this.disbursmentData[i].Finnone_Tranche_Disbursed_Amount__c : null,
                        Disbur_Status__c: this.disbursmentData[i].Disbur_Status__c ? this.disbursmentData[i].Disbur_Status__c : null,
                        Disbur_To__c: 'CUSTOMER',
                        Princ_Rec_on__c: 'AMOUNT DISBURSED TILL DATE',
                        Date_of_Disbur__c: this.disbursmentData[i].Date_of_Disbur__c ? this.disbursmentData[i].Date_of_Disbur__c : null,
                        sobjectType: 'Disbursement__c'
                    }
                    if(this.disbursmentData[i].Id){
                        disbursementObjectData.Id = this.disbursmentData[i].Id;
                    }
                    disbursementArrayData.push(disbursementObjectData);
                }else{
                    if(this.disbursmentData[i].Id){
                        var disbursementObjectDataDelete = {
                            Id: this.disbursmentData[i].Id,
                            sobjectType: 'Disbursement__c'
                        }
                        disbursementArrayDataDelete.push(disbursementObjectDataDelete);
                    }
                }
            }

            let upsertData = {
                parentRecord: loanApplicationUpsertData,
                ChildRecords: disbursementArrayData,
                ParentFieldNameToUpdate: 'Loan_Appli__c'
            }
            upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
            .then(result => {                
                if(disbursementArrayDataDelete && disbursementArrayDataDelete.length > 0){
                    this.handleDeleteRecords(disbursementArrayDataDelete);
                }else{
                    this.handleRefreshAllData();
                    if(functionCalledPostSuccess === false){
                        this.showSpinner = false;
                    }
                    if(!disbStatusUpdate){
                        this.showToastMessage("Success", 'Disbursement and Loan Application Details saved successfully.', "success", "sticky");
                    }else{
                     
                    }    
                }
                if(result && result.parentRecord && result.parentRecord.IsLoanApplCancelled__c && result.parentRecord.IsLoanApplCancelled__c === true){
                    this.disableMode = true;
                }            
            })
            .catch(error => {
                console.log('upsert error -', JSON.stringify(error));
                this.showSpinner = false;
                this.showToastMessage("Error","Unexpected error occurred. Please try again. ", error.body.message, "error", "sticky");
            })
        }else{
            this.showSpinner = false;
            this.showToastMessage("Error", 'Disbursement Details Not Available to Save', "error", "sticky");
        }
    }

    handleDeleteRecords(dataDelete){
        deleteRecords({ rcrds: dataDelete })
        .then(result => {
            this.handleRefreshAllData();
            this.showSpinner = false;
            this.showToastMessage("Success", 'Disbursement and Loan Application Details saved successfully.', "success", "sticky");
        })
        .catch(error => {
            console.log('upsert error -', JSON.stringify(error));
            this.showSpinner = false;
            this.showToastMessage("Error","Unexpected error occurred. Please try again. ", error.body.message, "error", "sticky");
        })

    }

    @api reportValidity() {
        const isInputCorrect = [
            ...this.template.querySelectorAll("lightning-input"),
            ...this.template.querySelectorAll("lightning-combobox")
        ].reduce((validSoFar, inputField) => {

            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        if(isInputCorrect && isInputCorrect === false){
        }
        return isInputCorrect;
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

    previousDateHandler(isProgDateRequired, disbRecordId){
        let isDateOrderCorrect = true;
        if(this.disbursmentData && this.disbursmentData.length > 0) {
            // Progressive date logic
            if (this.loanApplicationData && this.loanApplicationData.DisbursalType__c && this.loanApplicationData.DisbursalType__c === 'MULTIPLE' ) {
                const hasBlankDate = this.disbursmentData.some(record => !record.Date_of_Disbur__c);
                if (hasBlankDate) {
                    if(disbRecordId != undefined) {
                        let disbRecordsWithtoCheckDate = this.disbursmentData.filter(record => record.Id == disbRecordId);
                        if(disbRecordsWithtoCheckDate[0].Date_of_Disbur__c == null && isProgDateRequired === false){
                            this.showToastMessage('Error', 'Some of the Disbursal Dates are missing, Please fill correct details', 'error', 'sticky');
                            this.showSpinner = false;
                            isDateOrderCorrect = false;
                        }
                    }
                }else {
                    if ( isProgDateRequired === true) {
                        this.disbursmentData.sort((a, b) => a.Date_of_Disbur__c - b.Date_of_Disbur__c);
                        for (let i = 1; i < this.disbursmentData.length; i++) {          
                            const currentDate = new Date(this.disbursmentData[i].Date_of_Disbur__c);
                            const previousDate = new Date(this.disbursmentData[i - 1].Date_of_Disbur__c);
                            if (currentDate <= previousDate) {
                                isDateOrderCorrect = false;
                                break;
                            }
                        }
                        if (!isDateOrderCorrect) {
                            this.showSpinner = false;
                            this.showToastMessage('Error', 'Disbursal Dates are not in progressive order, Please fill correct details', 'error', 'sticky');
                        } 
                    }
                }
                const hasPrncipleStartDateBlank = this.disbursmentData.some(record => !record.Princ_Start_Date__c);
                if(hasPrncipleStartDateBlank){

                } else {
                    if ( isProgDateRequired === true) {
                        const principleStartDate = this.disbursmentData[0].Princ_Start_Date__c ? this.disbursmentData[0].Princ_Start_Date__c : null;
                        const disbursementDate = this.disbursmentData[this.disbursmentData.length-1].Date_of_Disbur__c ? this.disbursmentData[this.disbursmentData.length-1].Date_of_Disbur__c : null;

                        const uniqueDates = new Set(this.disbursmentData.map(record => record.Princ_Start_Date__c));
                        
                        let formattedDate;
                        if(disbursementDate){
                            let dateString = disbursementDate;
                            // Parse the date string
                            let dateParts = dateString.split('-');
                            let year = dateParts[0];
                            let month = dateParts[1];
                            let day = dateParts[2];
                            // Format the date as 'DD-MM-YYYY'
                            formattedDate = `${day}-${month}-${year}`;
                        }
                            
                        if (uniqueDates.size > 1 || principleStartDate < disbursementDate) {
                            isDateOrderCorrect = false;
                            this.showSpinner = false;
                            const errorMessage = `All Principal Start Dates should be same and has to be after ${formattedDate} (Date of Disbursement).`
                            this.showToastMessage('Error', errorMessage, 'error', 'sticky');
                            
                        }                           
                    }
                }
            } 
            if(this.loanApplicationData && this.loanApplicationData.DisbursalType__c && this.loanApplicationData.DisbursalType__c === 'SINGLE' && isProgDateRequired === false) {

                const hasBlankDate = this.disbursmentData.some(record => !record.Date_of_Disbur__c);
                if (hasBlankDate) {
                    this.showToastMessage('Error', 'Date of Disbursement is missing, Please fill correct details', 'error', 'sticky');
                    this.showSpinner = false;
                    isDateOrderCorrect = false;
                }
            }
        } else {
            this.showSpinner = false;
            isDateOrderCorrect = false;
            this.showToastMessage('Info', 'Disbursment Details are Not Available', 'info');
        }
        return isDateOrderCorrect;
    }

    @track dynamicErrorMessage = '';

    setValidity(isValid) {
        const inputField = this.template.querySelector('lightning-input');
        if (inputField) {
            inputField.reportValidity();
            inputField.setCustomValidity(isValid ? '' : this.dynamicErrorMessage);
        }
    }

    @track DocumentDetaiId;

    generateDocumentHandler() {
        this.showSpinner = true;
        this.showDocList = false;
        if(this.disbursmentData && this.disbursmentData.length > 0) {
            createDocumentDetail({ applicantId: this.loanPrimaryApplicant, loanAppId: this._loanAppId, docCategory: 'Disbursement Memo', docType: 'Disbursement Memo', docSubType: 'Disbursement Memo', availableInFile: false })
            .then((result) => {
                this.DocumentDetaiId = result;
                let pageUrl = this.customLabel.disbursementMemo + this._loanAppId;
                const pdfData = {
                    pageUrl: pageUrl,
                    docDetailId: this.DocumentDetaiId,
                    fileName: 'Disbursement Memo.pdf'
                }
                this.generateDocument(pdfData);

            })
            .catch((err) => {
                this.showSpinner = false;
                console.log(" createDocumentDetailRecord error===", err);
            });
        }else{
            this.showToastMessage('Error', this.customLabel.DisbMemoRdError, 'error', 'sticky');
            this.showSpinner = false;
         }
 
     }

    generateDocument(pdfData) {
        generateDocument({ wrapObj: pdfData })
        .then((result) => {
            this.showSpinner = false;
            if (result == 'success') {
                this.forLatestDocDetailRec(this.disbursementMemoCategory[0], this.disbursementMemoType[0], this.disbursementMemoSubType[0], this.DocumentDetaiId);
                
            }else{
              
            }
        })
        .catch((err) => {
            this.showSpinner = false;
            console.log(err);
        });
    }
    forLatestDocDetailRec(docCat, docTyp, docSubTyp, docId) {
        let listOfAllParent = [];
        let paramForIsLatest = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'Appl__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c','AppvdRmrks__c'],
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this._loanAppId + '\' AND Appl__c = \'' + this.loanPrimaryApplicant + '\' AND DocCatgry__c = \'' + docCat + '\' AND DocTyp__c = \'' + docTyp + '\' AND DocSubTyp__c = \'' + docSubTyp + '\''
        }
        getSobjectData({ params: paramForIsLatest })
            .then((result) => {
                if (result.parentRecords) {
                    listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
                }
                let oldRecords = []
                oldRecords = listOfAllParent.filter(record => record.Id !== docId);
                let isLatestFalseRecs = []
                isLatestFalseRecs = oldRecords.map(record => {
                    return { ...record, IsLatest__c: false };
                });
                //Added for LAK-8647
                let obj = {
                    Id: docId,
                    AppvdRmrks__c: isLatestFalseRecs && isLatestFalseRecs.length > 0 ? isLatestFalseRecs[0].AppvdRmrks__c : ''
                }
                isLatestFalseRecs.push(obj);
                upsertMultipleRecord({ params: isLatestFalseRecs })
                    .then(result => {
                       
                        this.refreshDocTable();
                      
                    }).catch(error => {
                        this.showSpinner = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: error.body.message,
                                variant: 'error',
                                mode: 'sticky'
                            })
                        );
                      
                        console.log('778' + error)
                    })

            })
            .catch((error) => {
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: (error.body && error.body.message) ? error.body.message : '',
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                console.log('Error In getting Document Details  ', error);
               
            });
    }

    refreshDocTable() {
        this.showSpinner = false;
        this.showDocList = true;
    }

    get deleteAction(){
        if(this.disbursmentData && this.disbursmentData.length > 2){
            return true;
        }else{
            return false;
        }
    }

    get splitDisbButton(){
        if(this.disbursmentData && this.disbursmentData.length > 0){
            return true;
        }else{
            return false;
        }
    }

    get disbursmentDataCount(){
        if(this.disbursmentData && this.disbursmentData.length > 0){
            return this.disbursmentData.length;
        }else{
            return 0;
        }
    }

    // get disbursmentMemoDisabled() {
    //     return !(this.disbursmentData && this.disbursmentData.some(item => item.Id && (item.showOnUI && item.CountOfSplitRecords > 0)) && this.lanOwnerId && this.lanOwnerId == this.currentUserId);
    // }

    get disbursmentMemoDisabled(){
        let disableFlag = false;
        if(this.loanApplSubStage && this.loanApplStage && this.loanApplStage === 'Disbursed' && (this.loanApplSubStage === 'Completed' )){
            disableFlag = true;
        }
        else if(this.loanApplSubStage && this.loanApplStage && this.loanApplStage === 'Disbursed' &&  this.loanApplSubStage === 'Additional Processing'){
            if(this.loanApplicationData.DisbursalType__c==='MULTIPLE'){
                disableFlag = false;
            }
            else{
                disableFlag = true;
            }
        }
        
        else{
            if(this.disbursmentData && this.disbursmentData.length > 0){
               let disableDisbMemo = this.disbursmentData.some(item => item.Id && (item.showOnUI && item.CountOfSplitRecords > 0)) && this.lanOwnerId && this.lanOwnerId == this.currentUserId;
               if(!disableDisbMemo){
                disableFlag = true;
               }
            }else{
                disableFlag = true;
            }
        }
        return disableFlag;     
    }

    get tableWidth(){
        if(this.showPrincipleFields === true){
            return 'maxWidth';
        }else{
            return 'minWidth';
        }
    }

    get disableInitiateTranch(){
        if(this.lanOwnerId && this.currentUserId && this.lanOwnerId == this.currentUserId){
           return false;
        }else{
            return true;
        }
    }

    get disableDisbursalType(){
        if((this.disableMode === true) || (this.loanApplStage && this.loanApplStage === 'Disbursed') || (this.loanProduct === 'Business Loan' || this.loanProduct === 'Personal Loan')){
            return true;
        }else{
            return false;
        }
    }

    @track isDisbTypeChange = false;
    @track preEMITypeValue;
    inputChangeHandler(event) {
       
        var currentDataSet = event.target.dataset;

        if(currentDataSet && currentDataSet.objectname && currentDataSet.objectname == 'Disbursement__c'){
            if (event.target.dataset.fieldname == "Disbur_Status__c") {
                this.disbursmentData[event.target.accessKey - 1].Disbur_Status__c = event.target.value;
            }

            if (event.target.dataset.fieldname == "Date_of_Disbur__c") {            
                this.disbursmentData[event.target.accessKey - 1].Date_of_Disbur__c = event.target.value;
                this.populateDisbursalStatusDisbChange(event.target.accessKey - 1);
            }
        
            if(event.target.dataset.fieldname == "Total_Disb_Amt__c") { 
                var tempAmount = event.target.value;    
                this.disbursmentData[event.target.accessKey - 1].Total_Disb_Amt__c = tempAmount;
                    
                    if(tempAmount){
                        var tempNumb= tempAmount.toString();
                        var str;
                        var numres;
                        if(tempNumb){
                            str= tempNumb.split(".");
                        }
                        if(str){
                            numres= Number("."+str[1]);
                        }
                        
                        if(numres){
                            if(numres < .50){
                                this.disbursmentData[event.target.accessKey - 1].Total_Disb_Amt__c = Number(str[0]);
                            }else if(numres >= .50){
                                this.disbursmentData[event.target.accessKey - 1].Total_Disb_Amt__c = Number(str[0])+1;
                            }else{
                                this.disbursmentData[event.target.accessKey - 1].Total_Disb_Amt__c = tempAmount;
                            }
                        }
                        
                    }
                this.populateDisbursalStatusDisbChange(event.target.accessKey - 1);    
            }

            if (event.target.dataset.fieldname == "DisbrDiscription__c") { 
                this.disbursmentData[event.target.accessKey - 1].DisbrDiscription__c = event.target.value;
            }

            if (event.target.dataset.fieldname == "Disbur_To__c") { 
                this.disbursmentData[event.target.accessKey - 1].Disbur_To__c = event.target.value;
                this.populateDisbursalStatusDisbChange(event.target.accessKey - 1);   
            }

            if (event.target.dataset.fieldname == "Princ_Start_Date__c") { 
                this.disbursmentData[event.target.accessKey - 1].Princ_Start_Date__c = event.target.value;
                this.updatePrincplDateOnDisbrsmentData(event.target.accessKey - 1);
                this.populateDisbursalStatusDisbChange(event.target.accessKey - 1);     
            }

            if (event.target.dataset.fieldname == "Princ_Rec_on__c") { 
                this.disbursmentData[event.target.accessKey - 1].Princ_Rec_on__c = event.target.value;
                this.populateDisbursalStatusDisbChange(event.target.accessKey - 1);   
            }

        }else if(currentDataSet && currentDataSet.objectname && currentDataSet.objectname == 'LoanAppl__c'){
            if (currentDataSet.name == 'DisbursalType__c'){
           
                this.loanApplicationData = {...this.loanApplicationData};
                this.loanApplicationData.DisbursalType__c =  event.target.value; 
                this.isDisbTypeChange = true;
                this.populateDisbursalStatusLoanAppChange();
                this.showOnUIProcessor();

                if(event.target.value === 'MULTIPLE'){
                    this.preEMITypeValue = 'R';       
                }
            }
        }
        this.calculateDisbursalAmountHandler(false, true);
    }



    @track disableSplitButton = false;

    calculateDisbursalAmountHandler(validateCondition, showToastMessageCond){
     
        this.disableSplitButton = false;
        const totalRunTimeDisbursalAmount = this.disbursmentData.reduce((total, data) => {
            if( data && ((data.Disbur_Status__c && data.Disbur_Status__c != 'CANCELLED') || !data.Disbur_Status__c)){   
            const disbursalAmount = (data.showOnUI ===true && data.Finnone_Tranche_Disbursed_Amount__c) ? (parseFloat(data.Finnone_Tranche_Disbursed_Amount__c) || 0) : (data.showOnUI ===true && !data.Finnone_Tranche_Disbursed_Amount__c) ? (parseFloat(data.Total_Disb_Amt__c) || 0) : 0;
            return total + disbursalAmount;
        } else {
            return total;
        }
        }, 0);

        if(!this.loanAmtIncCharges){
            if(showToastMessageCond === true){
                this.showToastMessage('Error', 'Loan Disbursement Amount missing, please correct the details.', 'error', 'sticky');
            }
            this.disableSplitButton = true;
            if(validateCondition === true){
                return false;
            }
        }else if(totalRunTimeDisbursalAmount > this.loanAmtIncCharges){   
            if(showToastMessageCond === true){
                this.showToastMessage('Error', 'Sum of Disbursement Amount(s) cannot be greater than Loan Disbursement Amount.', 'error', 'sticky');
            }      
            this.disableSplitButton = true;
            if(validateCondition === true){
                return false;
            }
        }

        if(this.loanApplicationData && this.loanAmtIncCharges){
            this.loanApplicationData = {...this.loanApplicationData};
            this.loanApplicationData.PendingDisbursalAmount__c = (this.loanAmtIncCharges - totalRunTimeDisbursalAmount);
        }

        if(this.loanApplicationData.PendingDisbursalAmount__c != 0){
            if(showToastMessageCond === true && validateCondition === true){
                this.showToastMessage('Error', 'Pending Loan Disbursal Amount not equal to zero. Please provide appropriate tranche details.', 'error', 'sticky');
            }      
            if(validateCondition === true){
                return false;
            }
        }
    }

    @track tempShowInt;
    populateDisbursalStatusDisbChange(accessKey){
        let tempAccessKey = accessKey;
        var statusCheck = 'DISBURSED INITIATED';
        
        if(!statusCheck.includes(this.disbursmentData[tempAccessKey].Disbur_Status__c)){
            if(this.loanApplicationData && this.loanApplicationData.DisbursalType__c === 'MULTIPLE'){
                if(this.disbursmentData[tempAccessKey].Disbur_To__c && 
                    this.disbursmentData[tempAccessKey].Total_Disb_Amt__c && 
                    this.disbursmentData[tempAccessKey].Princ_Rec_on__c && 
                    this.disbursmentData[tempAccessKey].Princ_Start_Date__c &&
                    this.disbursmentData[tempAccessKey].Date_of_Disbur__c)
                {
                    this.disbursmentData[tempAccessKey].Disbur_Status__c = 'ENTERED';
                    if((this.tempShowInt || this.disbursmentData[tempAccessKey].showInitiateButton)){
                        this.showInitiateButtonFunction(true);                  
                    }else{                     
                    }
                }else{
                    this.disbursmentData[tempAccessKey].Disbur_Status__c = null;                   
                    if( this.disbursmentData[tempAccessKey].Disbur_Status__c === null && this.disbursmentData[tempAccessKey].showInitiateButton){
                        this.tempShowInt = true;
                       this.showInitiateButtonFunction(false);
                    }
                }
            }else if(this.loanApplicationData && this.loanApplicationData.DisbursalType__c === 'SINGLE'){
                if(this.disbursmentData[tempAccessKey].Disbur_To__c && 
                    this.disbursmentData[tempAccessKey].Total_Disb_Amt__c && 
                    this.disbursmentData[tempAccessKey].Date_of_Disbur__c)
                {
                    this.disbursmentData[tempAccessKey].Disbur_Status__c = 'ENTERED';

                }else{
                    this.disbursmentData[tempAccessKey].Disbur_Status__c = null;
                }
            }
        }
    }

    populateDisbursalStatusLoanAppChange(){
        var statusCheckLoanApp = 'DISBURSED INITIATED';
        for(var i=0; i<this.disbursmentData.length; i++){
            if(!statusCheckLoanApp.includes(this.disbursmentData[i].Disbur_Status__c)){
                if(this.loanApplicationData && this.loanApplicationData.DisbursalType__c === 'MULTIPLE'){
                    if(this.disbursmentData[i].Disbur_To__c && 
                        this.disbursmentData[i].Total_Disb_Amt__c && 
                        this.disbursmentData[i].Princ_Rec_on__c && 
                        this.disbursmentData[i].Princ_Start_Date__c &&
                        this.disbursmentData[i].Date_of_Disbur__c)
                    {
                        this.disbursmentData[i].Disbur_Status__c = 'ENTERED';
                    }else{
                        this.disbursmentData[i].Disbur_Status__c = null;
                    }
                }else if(this.loanApplicationData && this.loanApplicationData.DisbursalType__c === 'SINGLE'){
                    if(this.disbursmentData[i].Disbur_To__c && 
                        this.disbursmentData[i].Total_Disb_Amt__c && 
                        this.disbursmentData[i].Date_of_Disbur__c)
                    {
                        this.disbursmentData[i].Disbur_Status__c = 'ENTERED';
                    }else{
                        this.disbursmentData[i].Disbur_Status__c = null;
                    }
                }
            }
        }
    }

    formValidationResult(switchCase) {
        if (!this.loanAmtIncCharges) {
            this.showToastMessage('Error', 'Loan Disbursal Amount missing. Not allowed to proceed.', 'error', 'sticky');
            return false;
        }
        if (this.disbursmentDataCount > 0) {
            const sumdisbursementAmount = this.disbursmentData.reduce((total, record) => {
                return total + (record.Total_Disb_Amt__c || 0);
            }, 0);

            if (sumdisbursementAmount >= this.loanAmtIncCharges) {
                this.showToastMessage('Error', 'Tranche amount exceeds Loan Disbursal Amount. Not allowed to proceed.', 'error', 'sticky');
                return false;
            }
        } else {
            return true;
        }
    } 

    updatePrincplDateOnDisbrsmentData(accessKey){
      let tempAccessKey = accessKey;
      if(tempAccessKey != null && this.disbursmentData && this.disbursmentData.length > 0){
        for(let i=0; i<this.disbursmentData.length; i++)
        {
            this.disbursmentData[i].Princ_Start_Date__c =  this.disbursmentData[tempAccessKey].Princ_Start_Date__c;
        }
      }
    }

    get disblCreateTranButton(){
        if(this.loanApplicationData && this.loanApplicationData.DisbursalType__c && this.loanApplicationData.DisbursalType__c === 'MULTIPLE'){
            var sumdisbursementAmounts = this.disbursmentData.reduce((total, record) => {
                // const disbursedataAmount = parseFloat(record.Total_Disb_Amt__c) || 0;
                if(record && ((record.Disbur_Status__c && record.Disbur_Status__c != 'CANCELLED') || !record.Disbur_Status__c)){
                const disbursedataAmount = record.Finnone_Tranche_Disbursed_Amount__c ? parseFloat(record.Finnone_Tranche_Disbursed_Amount__c) : record.Total_Disb_Amt__c ? parseFloat(record.Total_Disb_Amt__c) : 0;
                return total + disbursedataAmount;
            }else{
                return total;
            }
            }, 0);

            if ((sumdisbursementAmounts >= this.loanAmtIncCharges) || (this.disableMode === true)) {
                return true;
            }else{
                return false;
            }
        }else if((this.loanApplicationData && this.loanApplicationData.DisbursalType__c && this.loanApplicationData.DisbursalType__c === 'SINGLE') || (this.disableMode === true)){
            return true;
        }else{
            return true;
        }
    }

    get todaysDate() {
        var dateObj1 = new Date();
        let month = String(dateObj1.getMonth() + 1).padStart(2, '0');
        let day = String(dateObj1.getDate()).padStart(2, '0');
        let year = dateObj1.getFullYear();
        var currDate = year + '-' + month + '-' + day;
        return currDate;
    }
 
    @track showSplitDisbursModal = false;
    @track parentDisbursmentId;
    @track showTable;
    splitDisbursmentHandler(event){
        let currentDisbRecordId;
        this.showSplitDisbursModal = false;
        this.showTable = false;
        this.parentDisbursmentId = undefined;
        var currentIndex = event.target.dataset.id;
        if(event.target.dataset){
            if(event.target.dataset.disbursmentid){
                currentDisbRecordId = event.target.dataset.disbursmentid
                this.showSpinner = true;
                this.showSplitDisbursModal = false;
                this.showTable = false;
                var disburseRuntimeDataWithId = [];
                if(this.disbursmentData && this.disbursmentData.length > 0){
                    for(var i=0; i<this.disbursmentData.length; i++){
                        if(this.disbursmentData[i].Id == event.target.dataset.disbursmentid){
                            var dummyData = this.disbursmentData[i];
                            dummyData.sobjectType = 'Disbursement__c';
                            disburseRuntimeDataWithId.push(dummyData);
                            break;
                        }
                    }
                    var parentLoanApplRecord = {};
                    parentLoanApplRecord.Id = this._loanAppId;
                    parentLoanApplRecord.DisbursalType__c = this.loanApplicationData.DisbursalType__c ? this.loanApplicationData.DisbursalType__c : null;
                    parentLoanApplRecord.sobjectType = 'LoanAppl__c';
                    disburseRuntimeDataWithId.push(parentLoanApplRecord);
                    if(disburseRuntimeDataWithId &&  this.previousDateHandler(false, currentDisbRecordId)){
                        upsertMultipleRecord({ params: disburseRuntimeDataWithId})
                        .then(result => {
                            var resultReceivedWithId = result;
                            this.parentDisbursmentId = resultReceivedWithId[0].Id;
                            this.showSpinner = false;
                            this.showSplitDisbursModal = true;
                            this.showTable = true;
                            currentIndex = undefined;

                            if(this.parentDisbursmentId != undefined){
                                this.principleStartDateHandler(this.parentDisbursmentId);
                            }
                        }).catch(error => {
                            this.showToastMessage('Error', 'Unexpected error occurred. Please try again!! ', 'error', 'sticky');
                            this.showSpinner = false;
                        })
                    }
                }
            }else{
                this.showSpinner = true;
                this.showSplitDisbursModal = false;
                this.showTable = false;
                var disburseRuntimeData = [];
                if(this.disbursmentData && this.disbursmentData.length > 0){
                    for(var i=0; i<this.disbursmentData.length; i++){
                        if(this.disbursmentData[i].Index__c == event.target.dataset.id){
                            var dummyData = this.disbursmentData[i];
                            dummyData.sobjectType = 'Disbursement__c';
                            disburseRuntimeData.push(dummyData);
                            break;
                        }
                    }
                    var parentLoanApplRecord1 = {};
                    parentLoanApplRecord1.Id = this._loanAppId;
                    parentLoanApplRecord1.DisbursalType__c = this.loanApplicationData.DisbursalType__c ? this.loanApplicationData.DisbursalType__c : null;
                    parentLoanApplRecord1.sobjectType = 'LoanAppl__c';
                    disburseRuntimeData.push(parentLoanApplRecord1);
                    if(disburseRuntimeData &&  this.previousDateHandler(false, currentDisbRecordId)){
                        upsertMultipleRecord({ params: disburseRuntimeData})
                        .then(result => {
                            var resultReceived = result;
                            for(var i=0; i<this.disbursmentData.length; i++){
                                if(this.disbursmentData[i].Index__c == currentIndex){
                                    this.disbursmentData[i].Id = resultReceived[0].Id;
                                    break;
                                }
                            }
                            this.parentDisbursmentId = resultReceived[0].Id;
                            this.showSpinner = false;
                            this.showSplitDisbursModal = true;
                            this.showTable = true;
                            currentIndex = undefined;

                            if(this.parentDisbursmentId != undefined){
                                this.principleStartDateHandler(this.parentDisbursmentId);
                            }
                            
                           
                        }).catch(error => {
                            this.showToastMessage('Error', 'Unexpected error occurred. Please try again!! ', 'error', 'sticky');
                            this.showSpinner = false;
                        })
                    }
                }
            }
            if(this.disbursmentData && this.disbursmentData.length > 0){
                this.disableSaveButton = this.disbursmentData[event.target.accessKey - 1].Disbur_Status__c 
                                        && (this.disbursmentData[event.target.accessKey - 1].Disbur_Status__c === 'INITIATED' 
                                        || this.disbursmentData[event.target.accessKey - 1].Disbur_Status__c === 'DISBURSED' 
                                        || this.disableMode === true) ? true : false
            }
        }
    }

    @track showInitiateTranchButton = true;
    principleStartDateHandler(disbRecordId){
        let prncplStartDateSet;
        if (disbRecordId && this.disbursmentData && this.disbursmentData.length  > 0 ) {
            const disbursementRecord = this.disbursmentData.find(record => record.Id === disbRecordId);
            if (disbursementRecord) {          
                prncplStartDateSet = disbursementRecord.Princ_Start_Date__c;  
                let disbRecordsWithId = this.disbursmentData.filter(record => record.Id != null);
                if(disbRecordsWithId){
                    for(let i=0; i< disbRecordsWithId.length; i++)
                        {
                            disbRecordsWithId[i].Princ_Start_Date__c =  prncplStartDateSet;
                        }
                        this.disbursmentData = disbRecordsWithId;

                        if(this.disbursmentData && this.disbursmentData.length > 0){
                            this.handleUpsertData(true, false);
                        }
                }
            } 
        }
    }

    hideModalBox(){
        this.parentDisbursmentId = undefined;
        this.showSplitDisbursModal = false;
    }

    @track showonUICount = 0;

    get disbursementTableUIVisibilty(){
        this.showonUICount = 0;
        if(this.disbursmentData && this.disbursmentData.length > 0){
            for(var i=0; i<this.disbursmentData.length; i++){
                if(this.disbursmentData[i].showOnUI && this.disbursmentData[i].showOnUI === true){
                    this.showonUICount = this.showonUICount + 1;
                }
            }
            if(this.showonUICount > 0){
                return true;
            }else{
                return false;
            }
        }else{
            return false;
        }
    }

    get initiateButtonlabel(){
        if(this.loanApplStage && this.loanApplSubStage && (this.loanApplStage === 'Disbursed' && this.loanApplSubStage === 'DI Check')){
            return 'Initiate';
        }else
            if(this.loanApplStage && this.loanApplSubStage && (this.loanApplStage === 'Disbursed' && this.loanApplSubStage === 'Additional Processing')){
                return 'Fetch';
            }  
    }

    addTrancheHandler(){
        if(this.disbursmentData && this.disbursmentData.length > 0){
            let maxIndex = -1;
            this.disbursmentData.forEach(record =>{
                if(record.showOnUI == true && record.Index__c > maxIndex){
                    maxIndex = record.Index__c;
                }
            });
            this.disbursmentData.push({
                'Loan_Appli__c': this._loanAppId,
                'Princ_Start_Date__c': null,
                'Index__c': maxIndex !== -1 ? (maxIndex + 1): 1,
                'Disbur_No__c': maxIndex !== -1 ? (maxIndex + 1): 1,
                'DisbrDiscription__c': 'TRANCHE-'+ (maxIndex + 1),
                'Total_Disb_Amt__c': null,
                'Finnone_Tranche_Disbursed_Amount__c':null,
                'Disbur_Status__c': null,
                'Disbur_To__c': 'CUSTOMER',
                'Princ_Rec_on__c': 'AMOUNT DISBURSED TILL DATE',
                'Date_of_Disbur__c': null,
                'showOnUI' : true,
                'showInitiateButton': false
            })
        }else{
            this.disbursmentData.push({
                'Loan_Appli__c': this._loanAppId,
                'Princ_Start_Date__c': null,
                'Index__c': 1,
                'Disbur_No__c': 1,
                'DisbrDiscription__c': 'TRANCHE-1',
                'Total_Disb_Amt__c': null,
                'Finnone_Tranche_Disbursed_Amount__c':null,
                'Disbur_Status__c': null,
                'Disbur_To__c': 'CUSTOMER',
                'Princ_Rec_on__c': 'AMOUNT DISBURSED TILL DATE',
                'Date_of_Disbur__c': null,
                'showOnUI' : true,
                'showInitiateButton': false
            });
        }
        this.disbursmentData.sort((a, b) => a.Index__c - b.Index__c);
        this.showDisburDetTable = true;
    }

    @track showDeleteConfirmation = false;
    @track recordDelId;
    @track accessKeyForDeletion;

    deleteHandler(event) {
        this.showDeleteConfirmation = true;
        this.recordDelId = this.disbursmentData[event.target.accessKey - 1].Id ? this.disbursmentData[event.target.accessKey - 1].Id : null;
        this.accessKeyForDeletion = event.target.accessKey;
    }

    handleCancelDelete(){
        this.showDeleteConfirmation = false;
        this.recordDelId = null;
        this.accessKeyForDeletion = null;
    }

    handleConfirmDelete() {
        this.showSpinner = true;
        this.showDeleteConfirmation = false;
        this.handleRecordDeletion();
    }

    handleRecordDeletion() {
        if(this.recordDelId && this.recordDelId !=null) {
            let deleteRecord = [
                {
                    Id: this.recordDelId,
                    sobjectType: 'Disbursement__c'
                }
            ]

            deleteRecords({ rcrds: deleteRecord })
            .then(result => {
                this.showToastMessage("Success", 'Disbursement Record Deleted Successfully', "success", "sticky");
                this.showDeleteConfirmation = false;
                this.recordDelId = null;
                this.spliceDisbursementArrayProcessor();
                this.showSpinner = false;
            })
            .catch(error => {
                console.log('Delete Error----------->'+JSON.stringify(error));
                this.showToastMessage("Error", "Unexpected error occurred please try again.", error.body.message, "error", "sticky");
                this.showDeleteConfirmation = false;
                this.showSpinner = false;
            })
        }else {        
            this.showToastMessage("Success", 'Disbursement Record Deleted Successfully.', "success", "sticky");
            this.showDeleteConfirmation = false;
            this.recordDelId = null;
            this.spliceDisbursementArrayProcessor();
            this.showSpinner = false;
        }
    }

    spliceDisbursementArrayProcessor(){
        if(this.disbursmentData && this.disbursmentData.length > 0) {
            this.disbursmentData.splice(this.accessKeyForDeletion - 1, 1); 
            this.accessKeyForDeletion = null;           
            this.showSpinner = false;
        }else{
            this.showSpinner = false;
        }
        this.calculateDisbursalAmountHandler(false, true);
    }

    handleRefreshAllData(){
        refreshApex(this._wiredDisburData);
        refreshApex(this._wiredLoanApplData);
    }

    @track disabledFlag = true;
    handleChildData(event){
        if(event.detail != null){
            this.disabledFlag = event.detail;
        }
    }

    backButtonHandler(){
        if (this.template.querySelectorAll("c-split-disbursment-details-comp")) {
            this.template.querySelector("c-split-disbursment-details-comp").showTableHandler();
            this.disabledFlag = true;
        }
    }

    handleSplitDisbSave(){
        let isValid = false;
        if (this.template.querySelectorAll("c-split-disbursment-details-comp")) {
            var validateSplitDisbDetails = this.template.querySelector("c-split-disbursment-details-comp").validateForm();
            if (validateSplitDisbDetails) {
                isValid = true;
            } else {
                isValid = false;
            }
        }    
        if(isValid == true){
            if (this.template.querySelectorAll("c-split-disbursment-details-comp")) {
                this.template.querySelector("c-split-disbursment-details-comp").handleUpsert();
            }
        }
    }
    @track disbursementRecordId;
    @track accessKeyForDisbStatus;
    initiateTrancheHandler(event) {
        this.showSpinner = true;
      
        if (this.disbursmentData[event.target.accessKey - 1].Id) {
            this.disbursementRecordId = this.disbursmentData[event.target.accessKey - 1].Id;
   
            this.accessKeyForDisbStatus = event.target.accessKey;
        }
        let params = {
            ParentObjectName: 'NDC__c',
            parentObjFields: ['Id', 'OpsVer__c', 'NDC_Section__c'],
            queryCriteria: ' where LoanAppl__c = \'' + this._loanAppId + '\' AND IsInvalid__c = false'
        }
        getSobjectData({ params: params })
            .then((result) => {
                if (result.parentRecords) {
                    result.parentRecords.forEach(item => {
                        if(item.OpsVer__c){
                            this.countOpsVer++;
                        }else {
                            if (item.NDC_Section__c) {
                                this.sectionNames.add(item.NDC_Section__c);
                            }
                        }
                    })
                    if(this.countOpsVer != result.parentRecords.length){
                        this.showSpinner = false;
                        if (this.sectionNames && this.sectionNames.size > 0) {
                            let strr = Array.from(this.sectionNames).join(',');
                            let errorText = 'Ops Verification Required (' + strr + ')';
                            this.showToastMessage('Error',errorText,'error','sticky');
                        }// LAK-9387
                    }
                    else{
                        let paramDisbSplitDisb = {
                            ParentObjectName: 'Disbursement__c',
                            ChildObjectRelName: 'Split_Disbursements__r',
                            parentObjFields: ['Id', 'Split_Disbursement_s_Amount__c', 'Total_Disb_Amt__c', 'DisbrDiscription__c', 'Finnone_Tranche_Disbursed_Amount__c'],
                            childObjFields: ['Id'],
                            queryCriteria: ' where Id = \'' + this.disbursementRecordId + '\'',
                            
                        }             
                        getSobjectDataWithoutCacheable({ params: paramDisbSplitDisb })
                        .then((result) => {
                        if(result){
                            var dataReceivedForDisbSplitDisb = result;
                            dataReceivedForDisbSplitDisb.forEach(item => {
                                if(item.parentRecord && item.parentRecord.Split_Disbursements__r && 
                                    "Split_Disbursement_s_Amount__c" in item.parentRecord)
                                {
                                    const splitSumAmount = item.parentRecord.Split_Disbursement_s_Amount__c;
                                    const disbAmount = item.parentRecord.Total_Disb_Amt__c ? item.parentRecord.Total_Disb_Amt__c : 0;
                                    this.totalDisbAmount = item.parentRecord.Total_Disb_Amt__c ? item.parentRecord.Total_Disb_Amt__c : 0;     
                                    if(splitSumAmount != disbAmount){
                                  
                                        var errorText = 'Sum of Split Disbursement(s) Amount is not aligned with Disbursement Amount for '+item.parentRecord.DisbrDiscription__c+'. Please provide correct details.';
                                        this.showToastMessage('Error',errorText,'error','sticky');
                                        this.showSpinner = false;
                                    }else{
                                        this.initiTrancheHandler();
                                    }              
                               }else if(item.parentRecord && !item.parentRecord.Split_Disbursements__r){    
                                   
                                var errorTextNoSplit = 'Split Disbursement(s) missing for '+item.parentRecord.DisbrDiscription__c+'. Please provide Split Disbursement Details';
                                this.showToastMessage('Error',errorTextNoSplit,'error','sticky');
                                this.showSpinner = false;
                            }else{
                                this.initiTrancheHandler();
                            }
                            })
                        }
                        })
                        .catch(error =>{
                            this.showToastMessage('Error', 'An unexpected error occurred. Please try again.', 'error', 'sticky');
                            console.log('Error In showInitTranButtHandler---------->',JSON.stringify(error));
                            this.showSpinner = false;
                          
                        });
                    }
                }
            }).catch((error) => {
                console.log('Error In getting Ndc Data ', error.message);
            });
    }

    @track insertedSplitId;
    initiTrancheHandler() {
        this.showSpinner = true;
        let fields = {};
        fields.Name = 'Get Multi Tranch';
        fields.Status__c = 'New';
        fields.Svc__c = 'Get Multi Tranch';
        fields.BU__c = 'HL / STL';
        fields.IsActive__c = true;
        fields.RefObj__c = 'LoanAppl__c';
        fields.Trigger_Platform_Event__c = true
        fields.RefId__c = this._loanAppId ? this._loanAppId : '';
        if(fields){
            this.createIntMsgForGetTranchAPI(fields, 'Get Multi Tranch');
        }
    }

    @track getMultTranchIntMsgId;

    createIntMsgForGetTranchAPI(fieldsInt, name) {
        const recordInput = {
            apiName: 'IntgMsg__c',
            fields: fieldsInt
        };
        createRecord(recordInput)
            .then((result) => {
                if (name === 'Get Multi Tranch') {
                    this.getMultTranchIntMsgId = result.id;
                    this.callSubscribePlatformEve();
                }
            }).catch((error) => {
                this.showSpinner = false;
                console.log('Error data!! ' + JSON.stringify(error));
                this.showToastMessage('Error', 'An unexpected error occurred. Please try again.', 'error', 'sticky');
              
            });
    }

    callSubscribePlatformEve() {
        this.handleSubscribe(); 
    }

    cometdlib;
    @track PEsubscription;
    @api channelName = "/event/IntRespEvent__e";

    @track noIntResponec = true;
    handleSubscribe() {
        const self = this;
        this.cometdlib = new window.org.cometd.CometD();

        //Calling configure method of cometD class, to setup authentication which will be used in handshaking
        this.cometdlib.configure({
            url: window.location.protocol + '//' + window.location.hostname + '/cometd/50.0/',
            requestHeaders: { Authorization: 'OAuth ' + this.sessionId },
            appendMessageTypeToURL: false,
            logLevel: 'debug'
        });

        this.cometdlib.websocketEnabled = false;
        this.cometdlib.handshake(function (status) {
            // let tot = self.timeout
            self.noIntResponec = true;
            // self.startTimerForTimeout(tot);
            if (status.successful) {
               
                self.PEsubscription = self.cometdlib.subscribe(self.channelName, (message) => {
                    console.log(message.data.payload);
                    self.handlePlatformEventResponce(message.data.payload);
                },
                 (error) => {
                    console.log('Error In Subscribing', JSON.stringify(error));
                }
                );
            } else {
                this.handleUnsubscribe();
                this.showSpinner = false;
                this.showToastMessage('Error', 'An unexpected error occurred. Please try again.', 'error', 'sticky');
                console.error('Error in handshaking: ' + JSON.stringify(status));
            }
        });
    }

    @track unsubPlatEvtSucces = false;
    @track isGetRespSuccessful = false;
    @track disbAmtEqualCurrentPOS = false;
    @track hideSpinnerInUnsubscrb = false;
    @track currentPOSAmount;
    @track isGetAPIFailed = false;
    handlePlatformEventResponce(payload) {  
        console.log('Responce From PlatformEvent------->', (JSON.stringify(payload)));
        if (payload) {
            if (payload.SvcName__c === 'Get Multi Tranch' && payload.IntMsgId__c && (payload.IntMsgId__c === this.getMultTranchIntMsgId)) {
                this.unsubPlatEvtSucces = false; 
                if (payload.Success__c === true) {
                    let tranchData = [];
                    if(payload.IntMsg_Res__c){
                        let intMessageResp =JSON.parse(JSON.stringify(payload.IntMsg_Res__c));                       
                        if(intMessageResp != null){
                            var parsedData = JSON.parse(intMessageResp);
                            //Access the CurrentPOS value
                            if(parsedData && parsedData.Data[0].LoanStatus){
                                if(parsedData.Data[0].LoanStatus === 'X'){
                                    this.loanApplStatus = 'Cancelled';
                                    this.isLoanApplCancelled = true;
                                    this.handleUnsubscribe();
                                    this.showSpinner = false;
                                    this.showToastMessage('Error', this.customLabel.CancelledLoanAppl_ErrorMessage, 'error', 'sticky'); 
                                    if(this.loanApplStatus && this.isLoanApplCancelled){
                                        var tempRecord1 = [];
                                        var loanAppData = {
                                            Id: this._loanAppId,
                                            sobjectType: 'LoanAppl__c',
                                            Status__c : this.loanApplStatus ? this.loanApplStatus : null,
                                            IsLoanApplCancelled__c : this.isLoanApplCancelled ? this.isLoanApplCancelled : null
                                        }
                                        tempRecord1.push(loanAppData);
                                        this.handleUpsertGenericData(tempRecord1, 'LoanApplication');
                                    }
                                   
                                }else if (parsedData.Data[0].LoanStatus === 'C'){
                                    this.loanApplStatus = 'Closed';
                                    this.handleUnsubscribe();
                                    this.showSpinner = false;
                                    if(this.loanApplStatus){
                                        var tempRecord2 = [];
                                        var loanAppData1 = {
                                            Id: this._loanAppId,
                                            sobjectType: 'LoanAppl__c',
                                            Status__c : this.loanApplStatus ? this.loanApplStatus : null
                                        }
                                        tempRecord2.push(loanAppData1);
                                        this.handleUpsertGenericData(tempRecord2, 'LoanApplication');
                                    }
                                }else if (parsedData.Data[0].LoanStatus === 'A'){  
                                                
                                 if(parsedData.Data[0].Tranches && parsedData.Data[0].Tranches.length > 0){
                                    this.isGetRespSuccessful = true;  
                                    
                                    for(let i=0; i < parsedData.Data[0].Tranches.length; i++ ){
                                        tranchData.push(parsedData.Data[0].Tranches[i]);
                                    }                           
                           
                                    let totalDisbursalAmount = 0;    
                                    totalDisbursalAmount = parseFloat(tranchData[0].TotalDisbursalAmount) ? parseFloat(tranchData[0].TotalDisbursalAmount) : 0;
                                    let totalAmount = 0;  
                                    this.finalAmountToBeDisbursed = totalDisbursalAmount ? totalDisbursalAmount : 0;

                              if(tranchData && tranchData.length > 0){
                                       
                                    tranchData.forEach(tranche => {
                                            if(tranche.DisbursalStatus == 'DISBURSED' || tranche.DisbursalStatus == 'PARTIALLY DISBURSED'){
                                                totalAmount += parseFloat(tranche.Amount); 
                                                this.disbursedAmount = totalAmount ? totalAmount : 0;
                                            }
                                                        
                                    });
                                
                                    if(totalDisbursalAmount && totalAmount){
                                        this.currentPOSAmount = totalDisbursalAmount - totalAmount;
                                    }
                                                           
                                    function sortTranchesByTranchID(tranchData) {
                                        return tranchData.sort((a, b) => parseInt(a.TranchID) - parseInt(b.TranchID));
                                    } 
                    
                                        const sortedTranches = sortTranchesByTranchID(tranchData);
                                        if(sortedTranches && sortedTranches.length > 0 
                                           && this.disbursmentData && this.disbursmentData.length > 0){ 
                                        
                                          for(let i=0; i< sortedTranches.length; i++){
                                             if(i < this.disbursmentData.length ){                       
                                                if(sortedTranches[i].DisbursalStatus && (sortedTranches[i].DisbursalStatus === 'DISBURSED' || sortedTranches[i].DisbursalStatus === 'PARTIALLY DISBURSED') ){
                                                    if(this.disbursmentData[i].Index__c && (parseInt(this.disbursmentData[i].Index__c) === 1)){
                                                        this.disbursmentData[i].Finnone_Tranche_Disbursed_Amount__c = sortedTranches[i].Amount - parseInt(this.adjustedCharge68);  
                                                    }else{
                                                        this.disbursmentData[i].Finnone_Tranche_Disbursed_Amount__c = sortedTranches[i].Amount; 
                                                    }
                                                                                
                                                }else
                                                if(sortedTranches[i].DisbursalStatus && (sortedTranches[i].DisbursalStatus === 'CANCELLED')){
                                                    this.disbursmentData[i].Finnone_Tranche_Disbursed_Amount__c = 0; 
                                                }

                                                this.disbursmentData[i].Disbur_Status__c = sortedTranches[i].DisbursalStatus ? sortedTranches[i].DisbursalStatus : 'ENTERED';            
                                           }           
                                        }
                                        
                                        if(this.disbursmentData && this.disbursmentData.length > 0){         
                                            this.handleUpsertData(true, true);                   
                                        } 
                                    }
                                    
                                }
                        }
                        else{
                            this.isGetRespSuccessful = false; 
                            this.showToastMessage('Error', 'For initiated disbursement tranches are missing', 'error', 'sticky'); 
                            this.handleUnsubscribe();
                            this.showSpinner = false;
                        }
                                                
                        }
                        
                        if(this.currentPOSAmount && this.totalDisbAmount && (this.totalDisbAmount <= this.currentPOSAmount)){  
                            this.disbAmtEqualCurrentPOS = true;
                            this.handleUnsubscribe();
                        }else{
                            this.disbAmtEqualCurrentPOS = false;
                            this.handleUnsubscribe();
                        }
                    }
                }
                            
                }else{
                    this.handleUnsubscribe();
                    this.showToastMessage('Error', 'An unexpected error occurred. Please try again.', 'error', 'sticky');
                    this.showSpinner = false;
                }    
                   
                } else {                                   
                    if(payload && payload.Error_Message__c && payload.Error_Message__c !== 'Success'){
                         this.showToastMessage('Error', payload.Error_Message__c, 'error', 'sticky');              
                         if(this.accessKeyForDisbStatus){
                            this.disbursmentData[this.accessKeyForDisbStatus-1].Disbur_Status__c = 'INTEGRATION FAILURE';

                            if(this.disbursmentData[this.accessKeyForDisbStatus-1].Disbur_Status__c == 'INTEGRATION FAILURE'){
                                let disbStatusUpdate = true;
                                this.handleUpsertData(disbStatusUpdate, false);                   
                             }  
                         }  
                         this.isGetAPIFailed = true;
                    }                    
                    this.handleUnsubscribe();  
                    this.showSpinner = false;             
                }
            }
            else 
            if(payload && payload.SvcName__c && payload.SvcName__c === 'Additional Tranche Disbursal' && payload.IntMsgId__c && (payload.IntMsgId__c === this.postTranchIntMsgId)){
                this.unsubPlatEvtSucces = true;
                console.log('Additional Tranche Disbursal Responce From PlatformEvent------->', JSON.stringify(payload));
                if (payload.Success__c === true) {
                    this.showToastMessage('Success', 'Transaction Successful.', 'success', 'sticky');           
                    this.handleUnsubscribe();
                    this.updateLoanApplStageSubstage();         
                    this.showSpinner = false;                
                } else {
                    if(payload && payload.Error_Message__c){
                        this.showToastMessage('Error', payload.Error_Message__c, 'error', 'sticky'); 
                    }
                   
                    this.handleRefreshAllData(); 
                    this.handleUnsubscribe();
                    this.showSpinner = false;
               }

            }
        }else{
            this.handleUnsubscribe();
            this.showToastMessage('Error', 'An unexpected error occurred. Please try again.', 'error', 'sticky');
            this.showSpinner = false;
        }
    }


    createIntgMsgForPostTrancheDisb(){
        
        if(this.loanApplStage && this.loanApplSubStage && (this.loanApplStage === 'Disbursed' && this.loanApplSubStage === 'DI Check')){
            this.createIntgMsgForPostTranch();
        }               
    }

        @track postTranchIntMsgId;
        createIntgMsgForPostTranch(){
            let fields = {};
            fields.Name = 'Additional Tranche Disbursal';
            fields.Status__c = 'New';
            fields.Svc__c = 'Additional Tranche Disbursal';
            fields.BU__c = 'HL / STL';
            fields.IsActive__c = true;
            fields.RefObj__c = 'Disbursement__c';
            fields.Trigger_Platform_Event__c = true
            fields.RefId__c = this.disbursementRecordId ?  this.disbursementRecordId : '';
            fields.ParentRefObj__c = 'LoanAppl__c';
            fields.ParentRefId__c = this._loanAppId ? this._loanAppId : '';

                if(fields){
                    this.createIntMsgForPostTranchAPI(fields, 'Additional Tranche Disbursal');
                }
        }

       createIntMsgForPostTranchAPI(fieldsToCreateIntMsg, name){
        
            let recordInput = {
                apiName: 'IntgMsg__c',
                fields: fieldsToCreateIntMsg
            };
   
            if(recordInput){ 
            createRecord(recordInput)
                .then((result) => {
                    
                    this.unsubPlatEvtSucces = true;
                    console.log('Post Tranche Int Msg Result data!! ' + JSON.stringify(result));
                    if (name === 'Additional Tranche Disbursal') {
                        this.postTranchIntMsgId = result.id;
                        this.callSubscribePlatformEve();
                    }
                }).catch((error) => {
                    this.showSpinner = false;
                    console.log('Error data!! ' + JSON.stringify(error));
                    this.showToastMessage('Error', 'An unexpected error occurred. Please try again.', 'error', 'sticky');
                
                });
            }else{
                this.showSpinner = false;
                this.showToastMessage('Error', 'An unexpected error occurred. Please try again.', 'error', 'sticky');
            }
            
        }

     handleUnsubscribe() {
        console.log('unsubscription 0', this.PEsubscription);
        if (this.PEsubscription) {
            //Unsubscribing Cometd
            this.noIntResponec = false;
            this.cometdlib.unsubscribe(this.PEsubscription, {}, (unsubResult) => {

                if (unsubResult.successful) {
                          
                    //Disconnecting Cometd
                    this.cometdlib.disconnect((disResult) => {
                        if (disResult.successful) {  
                            console.log('Inside Unsubscribe Success');   
                            this.multiTranchePostProcessor(); 
                             //this.showSpinner = false;                                         
                        }
                        else {
                            this.showSpinner = false;
                            console.log('unsubscription ERROR ' + disResult);
                        }
                    });
                }
                else {
                    this.showSpinner = false;
                    console.log('unsubscription FAILED ');
                }
            });

            console.log('Inside Unsubscribe')
            //this.showSpinner = false;
            this.PEsubscription = undefined;

        }else{
            this.showSpinner = false;
        }

    }

    async multiTranchePostProcessor(){
        console.log('Inside multiTranchePostProcessor');

         if(!this.unsubPlatEvtSucces && this.isGetRespSuccessful && this.loanApplStage && this.loanApplStage === 'Disbursed' && this.loanApplSubStage && this.loanApplSubStage === 'DI Check'){
                if(this.disbAmtEqualCurrentPOS){     
                    this.createIntgMsgForPostTrancheDisb();
                    
                }else{
                    let errormessage = 'Pending disbursal amount recieved from Finnone is: '+this.currentPOSAmount+'. And Initiated Disbursement Amount is '+this.totalDisbAmount+ '. You are not allowed to proceed. Please fill correct details.'
                    this.showToastMessage('Error', errormessage, 'error', 'sticky');
                    this.showSpinner = false;
                }
        }
        else   
        if(!this.unsubPlatEvtSucces && this.isGetRespSuccessful && this.loanApplStage && this.loanApplStage === 'Disbursed' && this.loanApplSubStage && this.loanApplSubStage === 'Additional Processing'){
                this.showSpinner = false;
                this.showToastMessage('Success', this.customLabel.GetTrancheDetails_SuccessMessage, 'success', 'sticky'); 
        }
        else
        {
                this.showSpinner = false;
        }

    }

    @track loanApplOwnerId;
    @track updateLoanAppl = false;
    @track disbursedAmount;
    @track finalAmountToBeDisbursed;
    @track disbStatusUpdateToInit = false;
    @track disbStatusUpdateToDibursed = false; 

        updateLoanApplStageSubstage(){
            if(this.loanApplicationData && this.loanApplicationData.DisbursalType__c && this.loanApplicationData.DisbursalType__c === 'MULTIPLE'){                
            let paramDisbSplitDisb = {
                    ParentObjectName: 'Disbursement__c',
                    ChildObjectRelName: 'Split_Disbursements__r',
                    parentObjFields: ['Id', 'Disbur_Status__c'],
                    childObjFields: ['Id'],
                    queryCriteria: ' where Id = \'' + this.disbursementRecordId + '\'',    
                }   

                getSobjectDataWithoutCacheable({ params: paramDisbSplitDisb })
                .then((result) => {
                if(result){            
                        if(result[0].parentRecord && result[0].parentRecord.Disbur_Status__c && result[0].parentRecord.Disbur_Status__c === 'INITIATED')
                        {
                            this.disbStatusUpdateToInit = true;
                            this.getDisbursalStatus();

                        }else if(result[0].parentRecord && result[0].parentRecord.Disbur_Status__c && result[0].parentRecord.Disbur_Status__c === 'DISBURSED') {
                            this.disbStatusUpdateToDibursed = true;
                            this.getDisbursalStatus();
                        }       
                }
                })
                .catch(error =>{
                    this.showToastMessage('Error', 'An unexpected error occurred. Please try again.', 'error', 'sticky');
                    console.log('Error In updateLoanApplStageSubstage---------->',JSON.stringify(error));
                    this.showSpinner = false;
                  
                });       
                  
          } 

    }
    
        getDisbursalStatus(){   
            let lastTranche = false;
            let totalTranchsAmount =  this.disbursedAmount + this.totalDisbAmount;
            let pendingAmount = this.finalAmountToBeDisbursed - totalTranchsAmount;

            console.log('finalAmountToBeDisbursed##'+this.finalAmountToBeDisbursed+ ' totalTranchsAmount##'+totalTranchsAmount);
            if(pendingAmount === 0){
                lastTranche = true;   
            }else{
                lastTranche = false; 
            }
          
             if(this.disbursmentData && this.disbursmentData.length > 0){  
                function sortDataByTranchID(disbursmentData) {          
                    return disbursmentData.sort((a, b) => parseInt(a.Index__c) - parseInt(b.Index__c));           
                } 
    
                let sortedDisbrData = sortDataByTranchID(this.disbursmentData);
                
                    if(sortedDisbrData){
                        sortedDisbrData.forEach((record, index) => {
                        if (index > 0 && lastTranche === false && this.disbStatusUpdateToInit === true) {
                            this.updateLoanAppl = true;
                            return;
                        }
        
                    });
                }
           }

            if(this.updateLoanAppl === true ){        
                    let queueName = 'CPA Pool'; 
                    this.getQueueSalesforceId(queueName); 
            }

            //Changes Done Under New requirement(Vishnu)
            if(lastTranche === true && this.disbStatusUpdateToDibursed === true){ 
                    let queueName = 'System Queue';
                    this.getQueueSalesforceId(queueName);                  
            }

    }
    
          

          @track isNewLoanOwnerIdSet;
          @track queueSalesforceId;
          getQueueSalesforceId(queueName){
                this.queueSalesforceId = null;
                let QueueName = queueName;
                let loanOwnerId;
                    let QueueType = 'Queue'
                    let paramsToGetQueueId = {
                        ParentObjectName: 'Group',
                        parentObjFields: ['Id', 'Name', 'Type'],
                        queryCriteria: ' where Name = \'' + QueueName + '\' AND Type = \'' + QueueType + '\''
                    }

                    getSobjectData({ params: paramsToGetQueueId })
                    .then((result) => {
                        if (result.parentRecords && result.parentRecords.length > 0) {
                            this.queueSalesforceId = result.parentRecords[0].Id;

                            if(this.queueSalesforceId ){
                            if(result.parentRecords[0].Name && result.parentRecords[0].Name === 'CPA Pool'){
                                this.loanApplStage = 'Disbursed';
                                this.loanApplSubStage = 'Additional Processing Pool';
                                this.loanApplStatus = 'Partially Disbursed';
                
                                if(this.loanApplStage && this.loanApplSubStage && this.loanApplStatus){
                            
                                    if(this.queueSalesforceId){
                                        var tempRecord2 = [];
                                        var loanAppData2 = {
                                            Id: this._loanAppId,
                                            sobjectType: 'LoanAppl__c',
                                            Stage__c : this.loanApplStage ? this.loanApplStage : null,
                                            SubStage__c :  this.loanApplSubStage ?  this.loanApplSubStage : null,
                                            OwnerId : this.queueSalesforceId ? this.queueSalesforceId : null,
                                            Status__c : this.loanApplStatus ? this.loanApplStatus : null
        
                                        }
                                     
                                        tempRecord2.push(loanAppData2);
                                        this.handleUpsertGenericData(tempRecord2, 'LoanApplication');
                                    }
                                   
                                }
                            }
                            //Changes Done Under New requirement(Vishnu)
                            else  
                             if(result.parentRecords[0].Name && result.parentRecords[0].Name === 'System Queue'){
                                //LAK-8805 Jayesh
                               this.loanApplStage = 'Disbursed';
                               this.loanApplSubStage = 'Completed';
                                this.loanApplStatus = 'Fully Disbursed';

                                 if(this.loanApplStatus && this.loanApplStage && this.loanApplSubStage){   //this.loanApplStage && this.loanApplSubStage &&
                               
                                    if(this.queueSalesforceId){
                                        var tempRecord3 = [];
                                        var loanAppData3 = {
                                            Id: this._loanAppId,
                                            sobjectType: 'LoanAppl__c',
                                            Stage__c : this.loanApplStage ? this.loanApplStage : null,
                                            SubStage__c :  this.loanApplSubStage ?  this.loanApplSubStage : null,
                                            OwnerId : this.queueSalesforceId ? this.queueSalesforceId : null,
                                            Status__c : this.loanApplStatus ? this.loanApplStatus : null
        
                                        }                
                                        tempRecord3.push(loanAppData3);
                                        this.handleUpsertGenericData(tempRecord3, 'LoanApplication');
                                    }
                                }
                            }
                        }
                    }
                    })
                    .catch((error) => {
                        this.handleRefreshAllData();
                        this.showSpinner = false;

                        console.log("Error In updateLoanApplStageSubstage --------->", JSON.stringify(error));
                        this.showToastMessage('Error', 'An unexpected error occurred. Please try again.', 'error', 'sticky');
                    });


                }


    
    get showInitiateTrancheNote(){
        const checkCondition = this.disbursmentData.some(item => (item.showInitiateButton && item.showInitiateButton === true));
        if(checkCondition === false && this.showInitiateTranchColm === true && this.showDisburDetTable === true){
            return this.customLabel.InitiateTrancheNote;
        }else{
            return undefined;
        }
    }
       
}