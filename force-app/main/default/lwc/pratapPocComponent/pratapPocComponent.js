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

// Standard Libraries
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




export default class PratapPocComponent extends LightningElement {
    @track activeSection = ["A", "B", "C", "D"];
    @track showSpinner = false;
    @track loanApplicationData;
    @track showDocList = true;
    @track showDisburDetTable = false;

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
        SplitDisb_Del_SuccesMessage
    }
    @track genDM = "Please fill tranche details and related split disbursement records.";
    @track disbursementMemoType = ['Disbursement Memo'];
    @track disbursementMemoSubType = ['Disbursement Memo'];
    @track disbursementMemoCategory = ['Disbursement Memo'];


    //@api hasEditAccess;
    @track hasEditAccess = true;
    @api layoutSize;


    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        this.handleLoanApplRecords(value);
        //this.getLoanAppData();
    }

    get productOptions() {
        return [
            { label: 'Home Loan', value: 'Home Loan' },
            { label: 'Small Ticket LAP', value: 'Small Ticket LAP' }
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
        }
    }




    @track
    loanApplparams = {
        ParentObjectName: 'LoanAppl__c',
        ChildObjectRelName: 'Applicants__r',
        parentObjFields: ['Id', 'Name', 'FirstEMIDate__c', 'Product__c','CustomerName__c', 'Stage__c', 'SubStage__c', 'ProductSubType__c', 'DisbursalType__c', 
                          'SchmCode__c', 'Loan_Tenure_Months__c', 'SanLoanAmt__c', 'TotalLoanAmtInclInsurance__c', 'PendingDisbursalAmount__c', 'Total_PF_Amount__c',
                          'TotalLoanAmountIncCharges__c', 'OwnerId','EMIOptionsintranchedisbursementCase__c', 'RemPFDeductFromDisbursementAmount__c','Applicant__c'],
        childObjFields: ['FName__c', 'LName__c', 'LoanAppln__c', 'CompanyName__c', 'Constitution__c', 'ApplType__c'],
        queryCriteria: ' where Id = \'' + this._loanAppId + '\''
    }

    @track
    disburParams = {
        ParentObjectName: 'Disbursement__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'ApplicationID__c', 'Loan_Appli__c', 'Product__c', 'Appl_Name__c', 'Loan_Tenu__c', 'Scheme__c', 'Total_Disb_Amt__c', 'Disbur_To__c', 'No_of_Disbur__c', 'Princ_Rec_on__c', 'Princ_Start_Date__c', 'Disbur_No__c', 'Disbur_Desrp__c', 'Date_of_Disbur__c', 'Disbur_Status__c', 'Pend_Disbur_Amt__c','Index__c','DisbrDiscription__c'],
        childObjFields: [],
        queryCriteria: ' where Loan_Appli__c = \'' + this._loanAppId + '\''
    }


    handleLoanApplRecords(value) {
        let tempParams = this.loanApplparams;
        tempParams.queryCriteria = ' where Id = \'' + this._loanAppId + '\''
        this.loanApplparams = { ...tempParams };

        let tempPar = this.disburParams;
        tempPar.queryCriteria = ' where Loan_Appli__c = \'' + this._loanAppId + '\''
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
    //@track disblCreateTranButton = true;
    @track showPrincipleFields = false;
    @track loanPrincipalStartDate;
    @track loanNo;


    /* Get Loan Application Details */

    @track _wiredLoanApplData;

    @wire(getSobjectDatawithRelatedRecords, { params: '$loanApplparams' })
    handleLoanApplResponse(result) {
        const { data, error } = result;
        this._wiredLoanApplData = result;
        this.loanApplicationData = {};
        this.showDocList = false;
        if (data) {
            if (result.data) {
                console.log('Loan Data ', JSON.stringify(result.data.parentRecord));
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

    processComponentVariables(recordData){
        if(recordData.DisbursalType__c){
            this.loanDisbursalType = recordData.DisbursalType__c;

            if(this.loanDisbursalType === 'SINGLE'){
                //this.disblCreateTranButton = true;
                this.showPrincipleFields = false;
            }else if(this.loanDisbursalType === 'MULTIPLE'){
                //this.disblCreateTranButton = false;
                this.showPrincipleFields = true;
            }
        }
        this.loanPrincipalStartDate = recordData.FirstEMIDate__c ? recordData.FirstEMIDate__c : new Date();
        this.loanProduct = recordData.Product__c ? recordData.Product__c : null;
        this.loanScheme = recordData.SchmCode__c ? recordData.SchmCode__c : null;
        this.loanTenure = recordData.Loan_Tenure_Months__c ? recordData.Loan_Tenure_Months__c : null;
        this.loanPendingDisbAmt = recordData.PendingDisbursalAmount__c ? recordData.PendingDisbursalAmount__c : null;
        this.loanAmtIncCharges = recordData.TotalLoanAmountIncCharges__c ? recordData.TotalLoanAmountIncCharges__c : null;
        this.loanNo = recordData.Name;
        this.loanPrimaryApplicant = recordData.Applicant__c;
        this.lanOwnerId = recordData.OwnerId;
        this.showDocList = true;
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
        console.log('Disbursement Data-1-------->',JSON.stringify(data));
        if(data) {
            if(data.parentRecords && data.parentRecords.length > 0){                
                for (let i = 0; i < data.parentRecords.length; i++) {
                    var jsonDataDisbursement = {
                        "Id": data.parentRecords[i].Id,
                        "Name": data.parentRecords[i].Name,
                        "Loan_Appli__c": data.parentRecords[i].Loan_Appli__c ? data.parentRecords[i].Loan_Appli__c : null,
                        "Total_Disb_Amt__c": data.parentRecords[i].Total_Disb_Amt__c ? data.parentRecords[i].Total_Disb_Amt__c : null,
                        "Disbur_To__c": data.parentRecords[i].Disbur_To__c ? data.parentRecords[i].Disbur_To__c : null,
                        "Princ_Rec_on__c": data.parentRecords[i].Princ_Rec_on__c ? data.parentRecords[i].Princ_Rec_on__c : null,
                        "Princ_Start_Date__c": data.parentRecords[i].Princ_Start_Date__c ? data.parentRecords[i].Princ_Start_Date__c : null,
                        "Disbur_Status__c": data.parentRecords[i].Disbur_Status__c ? data.parentRecords[i].Disbur_Status__c : null,
                        "Index__c": data.parentRecords[i].Index__c ? data.parentRecords[i].Index__c : null,
                        "DisbrDiscription__c": data.parentRecords[i].DisbrDiscription__c ? data.parentRecords[i].DisbrDiscription__c : null,
                        "Date_of_Disbur__c": data.parentRecords[i].Date_of_Disbur__c ? data.parentRecords[i].Date_of_Disbur__c : null
                    }
                    this.disbursmentData.push(jsonDataDisbursement);
                }
                this.showDisburDetTable = true;
                this.countOfDisbursementRecords = data.parentRecords.length;
                this.maxClickCount = this.countOfDisbursementRecords + 1;
            }else{
                this.showDisburDetTable = false;
            } 
            this.disbursalDataLoaded = true;
            this.showOnUIProcessor();
        }else
        if(error){
            console.log('Error getting data', error);
        }
    }

    showOnUIProcessor(){
        if(this.loanApplicationData && this.loanApplicationData.DisbursalType__c && this.disbursalDataLoaded === true){
            if(this.loanApplicationData.DisbursalType__c === 'SINGLE'){
                this.showPrincipleFields = false;
                if(this.disbursmentDataCount > 0){
                    // Pratap
                    const minValue = Math.min(...this.disbursmentData.map(item => item.Index__c));
                    for(var i =0; i<this.disbursmentData.length; i++){
                        if(this.disbursmentData[i].Index__c == minValue){
                            this.disbursmentData[i].showOnUI = true;
                        }else{
                            this.disbursmentData[i].showOnUI = false;
                        }
                    }
                }else{
                    this.disbursmentData = [];
                    var disbursementRecord = {
                        'Loan_Appli__c': this._loanAppId,
                        'Princ_Start_Date__c': this.loanPrincipalStartDate ? this.loanPrincipalStartDate : null,
                        'Index__c': 1,
                        'DisbrDiscription__c': 'TRANCHE-1',
                        'Total_Disb_Amt__c': null,
                        'Disbur_Status__c': null,
                        'Disbur_To__c': null,
                        'Princ_Rec_on__c': null,
                        'Date_of_Disbur__c': null,
                        'showOnUI' : true
                    };
                    this.disbursmentData.push(disbursementRecord);
                    this.showDisburDetTable = true;
                }
            }else if(this.loanApplicationData.DisbursalType__c === 'MULTIPLE'){
                this.showPrincipleFields = true;
                if(this.disbursmentDataCount > 0){
                    for(var i =0; i<this.disbursmentData.length; i++){
                        this.disbursmentData[i].showOnUI = true;
                    }
                    if(this.disbursmentDataCount == 1){
                        var disbursementRecordDummy2 = {
                            'Loan_Appli__c': this._loanAppId,
                            'Princ_Start_Date__c': this.loanPrincipalStartDate ? this.loanPrincipalStartDate : null,
                            'Index__c': 2,
                            'DisbrDiscription__c': 'TRANCHE-2',
                            'Total_Disb_Amt__c': null,
                            'Disbur_Status__c': null,
                            'Disbur_To__c': null,
                            'Princ_Rec_on__c': null,
                            'Date_of_Disbur__c': null,
                            'showOnUI' : true
                        }
                        this.disbursmentData.push(disbursementRecordDummy2);
                    }
                }else{
                    for(var i=0; i<2; i++){
                        var disbursementRecordDummy = {
                            'Loan_Appli__c': this._loanAppId,
                            'Princ_Start_Date__c': this.loanPrincipalStartDate ? this.loanPrincipalStartDate : null,
                            'Index__c': i+1,
                            'DisbrDiscription__c': 'TRANCHE-'+(i+1),
                            'Total_Disb_Amt__c': null,
                            'Disbur_Status__c': null,
                            'Disbur_To__c': null,
                            'Princ_Rec_on__c': null,
                            'Date_of_Disbur__c': null,
                            'showOnUI' : true
                        }
                        this.disbursmentData.push(disbursementRecordDummy);
                    }
                    this.showDisburDetTable = true;
                }
            }
            this.calculateDisbursalAmountHandler(false);
        }
        //console.log('Disbursement Data-Final-------->',JSON.stringify(this.disbursmentData));
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
        this.handleRefreshAllData();
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
        console.log('values', JSON.stringify(values));
        this.handleSave(values.validateBeforeSave);
    }

    handleSave(validate) {
        let isDisbursementDetailsCorrect = this.calculateDisbursalAmountHandler(true);
        if(isDisbursementDetailsCorrect == false){
            return;
        }else{
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
                    if(uniqueIdVariable.length>0){
                        this.splitDisbursementCalculatorProcessor(uniqueIdVariable);
                    }else{
                        this.handleUpsertData();               
                    }
                } else {
                    this.showToastMessage('Error', this.customLabel.Trachy_ReqFields_ErrorMessage, 'error', 'sticky');
                }
            }
            else {
                if(uniqueIdVariable.length>0){
                    this.splitDisbursementCalculatorProcessor(uniqueIdVariable);
                }else{
                    this.handleUpsertData();               
                }
            }
        }
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
                }
            })
            if(errorIsCount == 0){
                this.handleUpsertData(); 
            }else{
                this.showSpinner = false;
            }
        })
        .catch(error =>{
            this.showSpinner = false;
        });
    }

    handleUpsertData() {
        var disbursementArrayData = [];
        var disbursementArrayDataDelete = [];
        if(this.disbursmentData && this.disbursmentData.length > 0) {
            this.showSpinner = true;
            var loanApplicationUpsertData = {
                Id: this._loanAppId,
                sobjectType: 'LoanAppl__c',
                DisbursalType__c : this.loanApplicationData.DisbursalType__c ? this.loanApplicationData.DisbursalType__c : null
            }

            // Pratap
            for(var i=0; i<this.disbursmentData.length; i++){
                if(this.disbursmentData[i].showOnUI === true){
                    var disbursementObjectData = {
                        Loan_Appli__c: this._loanAppId,
                        Princ_Start_Date__c: this.disbursmentData[i].Princ_Start_Date__c ? this.disbursmentData[i].Princ_Start_Date__c : null,
                        Index__c: this.disbursmentData[i].Index__c ? this.disbursmentData[i].Index__c : null,
                        DisbrDiscription__c: this.disbursmentData[i].DisbrDiscription__c ? this.disbursmentData[i].DisbrDiscription__c : null,
                        Total_Disb_Amt__c: this.disbursmentData[i].Total_Disb_Amt__c ? this.disbursmentData[i].Total_Disb_Amt__c : null,
                        Disbur_Status__c: this.disbursmentData[i].Disbur_Status__c ? this.disbursmentData[i].Disbur_Status__c : null,
                        Disbur_To__c: this.disbursmentData[i].Disbur_To__c ? this.disbursmentData[i].Disbur_To__c : null,
                        Princ_Rec_on__c: this.disbursmentData[i].Princ_Rec_on__c ? this.disbursmentData[i].Princ_Rec_on__c : null,
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
                    this.showSpinner = false;
                    this.showToastMessage("Success", 'Disbursement and Loan Application Details saved successfully.', "success", "sticky");
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
                //console.log('Document Detail Record Id!! ', this.DocumentDetaiId);
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
            this.showToastMessage('Errpr', this.customLabel.DisbMemoRdError, 'error', 'sticky');
            this.showSpinner = false;
         }
 
     }

    generateDocument(pdfData) {
        generateDocument({ wrapObj: pdfData })
        .then((result) => {
            this.showSpinner = false;
            if (result == 'success') {
                this.refreshDocTable();
            }else{
                console.log(result);
            }
        })
        .catch((err) => {
            this.showSpinner = false;
            console.log(err);
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

    get tableWidth(){
        if(this.showPrincipleFields === true){
            return 'maxWidth';
        }else{
            return 'minWidth';
        }
    }

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
                this.disbursmentData[event.target.accessKey - 1].Total_Disb_Amt__c = event.target.value;
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
            }

            if (event.target.dataset.fieldname == "Princ_Rec_on__c") { 
                this.disbursmentData[event.target.accessKey - 1].Princ_Rec_on__c = event.target.value;
                this.populateDisbursalStatusDisbChange(event.target.accessKey - 1);   
            }

        }else if(currentDataSet && currentDataSet.objectname && currentDataSet.objectname == 'LoanAppl__c'){
            if (currentDataSet.name == 'DisbursalType__c'){
                
                this.loanApplicationData = {...this.loanApplicationData};
                this.loanApplicationData.DisbursalType__c =  event.target.value; 
                this.populateDisbursalStatusLoanAppChange();
                this.showOnUIProcessor();
            }
        }
        this.calculateDisbursalAmountHandler(false);
        //console.log('On change data !!!!!!! '+JSON.stringify(this.disbursmentData));
    }

    @track disableSplitButton = false;

    calculateDisbursalAmountHandler(validateCondition){
        // Pratap
        this.disableSplitButton = false;
        const totalRunTimeDisbursalAmount = this.disbursmentData.reduce((total, data) => {
            const disbursalAmount = (data.showOnUI ===true) ? (parseInt(data.Total_Disb_Amt__c) || 0) : 0;
            return total + disbursalAmount;
        }, 0);
        
        if(!this.loanAmtIncCharges){
            this.showToastMessage('Error', 'Loan Disbursement Amount missing, please correct the details.', 'error', 'sticky');
            this.disableSplitButton = true;
            if(validateCondition === true){
                return false;
            }
        }else if(totalRunTimeDisbursalAmount > this.loanAmtIncCharges){
            this.showToastMessage('Error', 'Sum of Disbursement Amount(s) cannot be greater than Loan Disbursement Amount.', 'error', 'sticky');
            this.disableSplitButton = true;
            if(validateCondition === true){
                return false;
            }
        }
        if(this.loanApplicationData && this.loanAmtIncCharges){
            this.loanApplicationData = {...this.loanApplicationData};
            this.loanApplicationData.PendingDisbursalAmount__c = (this.loanAmtIncCharges - totalRunTimeDisbursalAmount);
        }
    }



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
                }else{
                    this.disbursmentData[tempAccessKey].Disbur_Status__c = null;
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

            // if (this.disbursmentDataCount > 1 && this.disbursmentData.some(record => (record.Disbur_Status__c === 'INITIATED' || record.Disbur_Status__c === 'DISBURSED'))) {
            //     this.showToastMessage('Error', 'Not allowed to change Disbursal Type when one of the Tranches is initiated to Finnone for disbursal.', 'error', 'sticky');
            //     return false;
            // }
        } else {
            return true;
        }
    } 

    get disblCreateTranButton(){
        if(this.loanApplicationData && this.loanApplicationData.DisbursalType__c && this.loanApplicationData.DisbursalType__c === 'MULTIPLE'){
            var sumdisbursementAmounts = this.disbursmentData.reduce((total, record) => {
                const disbursedataAmount = parseFloat(record.Total_Disb_Amt__c) || 0;
                return total + disbursedataAmount;
            }, 0);

            if (sumdisbursementAmounts >= this.loanAmtIncCharges) {
                return true;
            }else{
                return false;
            }
        }else if(this.loanApplicationData && this.loanApplicationData.DisbursalType__c && this.loanApplicationData.DisbursalType__c === 'SINGLE'){
            return true;
        }else{
            return true;
        }
    }

    @track showSplitDisbursModal = false;
    @track parentDisbursmentId;

    splitDisbursmentHandler(event){
        this.showSplitDisbursModal = false;
        this.parentDisbursmentId = undefined;
        var currentIndex = event.target.dataset.id;
        if(event.target.dataset){
            if(event.target.dataset.disbursmentid){
                this.showSplitDisbursModal = true;
                this.parentDisbursmentId = event.target.dataset.disbursmentid;
            }else{
                this.showSpinner = true;
                this.showSplitDisbursModal = false;
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
                    if(disburseRuntimeData){
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
                            currentIndex = undefined;
                        }).catch(error => {
                            this.showToastMessage('Error', 'Unexpected error occurred. Please try again!! ', 'error', 'sticky');
                            this.showSpinner = false;
                        })
                    }
                }
            }
        }
    }

    @track showInitiateTranchButton = false;

    hideModalBox(){
        this.parentDisbursmentId = undefined;
        this.showSplitDisbursModal = false;
    }

    @track showonUICount = 0;

    get disbursementTableUIVisibilty(){
        this.showonUICount = 0;
        if(this.disbursmentData && this.disbursmentData.length > 0){
            //Pratap
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
                'Princ_Start_Date__c': this.loanPrincipalStartDate ? this.loanPrincipalStartDate : null,
                'Index__c': maxIndex !== -1 ? (maxIndex + 1): 1,
                'DisbrDiscription__c': 'TRANCHE-'+ (maxIndex + 1),
                'Total_Disb_Amt__c': null,
                'Disbur_Status__c': null,
                'Disbur_To__c': null,
                'Princ_Rec_on__c': null,
                'Date_of_Disbur__c': null,
                'showOnUI' : true
            })
        }else{
            this.disbursmentData.push({
                'Loan_Appli__c': this._loanAppId,
                'Princ_Start_Date__c': this.loanPrincipalStartDate ? this.loanPrincipalStartDate : null,
                'Index__c': 1,
                'DisbrDiscription__c': 'TRANCHE-1',
                'Total_Disb_Amt__c': null,
                'Disbur_Status__c': null,
                'Disbur_To__c': null,
                'Princ_Rec_on__c': null,
                'Date_of_Disbur__c': null,
                'showOnUI' : true
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
        this.calculateDisbursalAmountHandler(false);
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
}