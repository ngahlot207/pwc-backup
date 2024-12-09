import { LightningElement, api, track, wire } from 'lwc';

import { getObjectInfo, getPicklistValues, getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import DISBUR_OBJ from '@salesforce/schema/Disbursement__c';
import SPLT_DISBRS_OBJECT from '@salesforce/schema/Split_Disbur__c';
import CURRENT_USER_ID from "@salesforce/user/Id";

import getSobjectDataWithoutCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjDtwithFltrRelatedRecordsWithoutCache';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import deleteIncomeRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import Trachy_SplChqAmt_ErrorMessage from '@salesforce/label/c.Trachy_SplChqAmt_ErrorMessage';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import { getRecord, createRecord, updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import Trachy_Int_ErrorMessage from '@salesforce/label/c.Trachy_Int_ErrorMessage';

import Trachy_Date_ErrorMessage from '@salesforce/label/c.Trachy_Date_ErrorMessage';

//Plarform Event & Integration
import cometdlwc from "@salesforce/resourceUrl/cometd";
import getSessionId from '@salesforce/apex/SessionUtil.getSessionId';
import { loadScript } from "lightning/platformResourceLoader";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { refreshApex } from '@salesforce/apex';
export default class SplitDisbursmentDetailsComp extends LightningElement {

    customLabel = {
        Trachy_SplChqAmt_ErrorMessage,
        Trachy_Int_ErrorMessage,
        Trachy_Date_ErrorMessage
    }

    @api showTable = false;
    @track showSpinner;
    @track fundTransMode
    @track fedBankTy = "CashBank Account";

    @api layoutSize;
    @api hasEditAccess;
    @track splitDisbWrapObj = {
        sobjectType: 'Split_Disbur__c'
    };
    @track splitDisbursDetailArr = [];

    @track isReqChequeDetails

    @track _loanApplicationData;

    @api get loanApplicationData() {
        return this._loanApplicationData;

    }
    set loanApplicationData(value) {
        this._loanApplicationData = value;
        this.setAttribute("loanApplicationData", value);
        this.handleLoanDetails(value);
    }

    @track loanApplSubStage;
    @track loanApplStage;
    @track disableMode;
    @track isBlPl = false;
    handleLoanDetails(value) {
      
    }


    @track _disbursmentId;
    @api get disbursmentId() {
        return this._disbursmentId;

    }
    set disbursmentId(value) {
        this._disbursmentId = value;
        this.setAttribute("disbursmentId", value);
        this.handleDisbursmentIdChange(value);
    }
    handleDisbursmentIdChange(event) {
        let tempParams = this.splitDisburParams;
        tempParams.queryCriteria = ' where Id = \'' + this._disbursmentId + '\'';
        this.splitDisburParams = { ...tempParams };
    }


    @track _loanAppId
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
    }


    @track repayAccNumb;
    @track repayIFSCCode;
    @track TypeOfAcc = 'SPLIT DISBURSEMENT ACCOUNT';

    @track
    repayAccParForPenDrop = {
        ParentObjectName: 'Repayment_Account__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'Loan_Application__c', 'Applicant_Banking__c', 'Is_Active__c', 'IFSC_Code__c', 'Account_Number__c', 'Type__c', 'Is_Verified__c'],
        childObjFields: [],
        queryCriteria: ' WHERE Account_Number__c=\'' + this.repayAccNumb + '\' AND IFSC_Code__c=\'' + this.repayIFSCCode + '\' AND Loan_Application__c=\'' + this.loanAppId + '\' AND Type__c=\'' + this.TypeOfAcc + '\' AND Is_Verified__c > 0'
    }

    @track
    splitDisburParams = {
        ParentObjectName: 'Disbursement__c',
        ChildObjectRelName: 'Split_Disbursements__r',
        parentObjFields: ['Id', 'Total_Disb_Amt__c', 'Loan_Appli__c', 'Disbur_To__c', 'Disbur_Status__c', 'Disbur_Desrp__c', 'Date_of_Disbur__c'],
        childObjFields: ['Id', 'Index__c', 'Name', 'Disbur_To__c', 'Split_Cheque_Amt__c', 'Date_of_Disbur__c', 'Custo_Name__c', 'Pay_Mode__c', 'Penny_Drop_Nm_Sta__c', 'Fund_Transf_Mode__c', 'IFSC_Detail__c', 'Cheq_DD_Date__c', 'Cheq_DD_No__c', 'Fedbank_Acc_Nm__c', 'InsurancePartner__c','Effec_Date__c', 'Payable_At__c', 'Fedbank_Acc_No__c', 'Cheq_Favor_Dets__c', 'Remarks__c', 'Cheq_Favor_Acc_No__c', 'Benef_Nm_of_Penny_Drop__c', 'Payment_to__c', 'CashBankAccountId__c', 'Pay_City_Id__c'],
        queryCriteria: ' where Id = \'' + this.disbursmentId + '\''
    }

    @track
    splitParams = {
        ParentObjectName: 'Split_Disbur__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'DisburseRela__c', 'Disbur_To__c', 'Split_Cheque_Amt__c', 'Date_of_Disbur__c', 'Custo_Name__c', 'Pay_Mode__c', 'Penny_Drop_Nm_Sta__c', 'Fund_Transf_Mode__c', 'IFSC_Detail__c', 'Cheq_DD_Date__c', 'Cheq_DD_No__c', 'Fedbank_Acc_Nm__c','InsurancePartner__c', 'Effec_Date__c', 'Payable_At__c', 'Fedbank_Acc_No__c', 'Cheq_Favor_Dets__c', 'Remarks__c', 'Cheq_Favor_Acc_No__c', 'Benef_Nm_of_Penny_Drop__c', 'Payment_to__c', 'CashBankAccountId__c', 'Pay_City_Id__c'],
        childObjFields: [],
        queryCriteria: ''
    }

    @track
    masterDataParams = {
        ParentObjectName: 'MasterData__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'Type__c', 'FinnoneCode__c', 'BankAcNum__c'],
        childObjFields: [],
        queryCriteria: ''
    }

    @track
    repayAccParams = {
        ParentObjectName: 'Repayment_Account__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'Loan_Application__c', 'Applicant_Banking__c', 'Is_Active__c', 'IFSC_Code__c', 'Account_Number__c'],
        childObjFields: [],
        queryCriteria: ''
    }

    @track
    applBankParams = {
        ParentObjectName: 'ApplBanking__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'Appl__c', 'LoanAppl__c', 'Name_of_the_Primary_Account_Holder_s__c', 'AC_No__c', 'IFSC_Code__c'],
        childObjFields: [],
        queryCriteria: ''
    }

    @track
    repayAccVeriParams = {
        ParentObjectName: 'RepayAccVerify__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'LoanAppl__c', 'RepayAcc__c', 'PennyDropStatus__c', 'NameRetuFromPennyDrop__c'],
        childObjFields: [],
        queryCriteria: ''
    }

    @track paymentTo;
    @track isReqForFundTrans;
    @track disbTo;
    @track repayAccId;
    @track applBankId;
    @track isDisbBankDet = false
    @track notReqForInsPartn = false
    @track disbDDDetails = false
    @track isInsPart = false;
    // @wire(MessageContext)
    // MessageContext;

    @track sessionId;
    @wire(getSessionId)
    wiredSessionId({ error, data }) {
        if (data) {
            this.sessionId = data;
            loadScript(this, cometdlwc);
        } else if (error) {
            console.log('Error In getSessionId = ', error);
            this.sessionId = undefined;
        }
    }

    @track currDate

    connectedCallback() {
        if (this.hasEditAccess === false) {
            this.disableMode = true
            this.isDisbBankDet = true
            this.disbDDDetails = true
        }
        else {
            this.disableMode = false;
        }

            if(this._loanApplicationData){      
            this.loanApplStage = this._loanApplicationData.Stage__c ? this._loanApplicationData.Stage__c : null;
            this.loanApplSubStage = this._loanApplicationData.SubStage__c ? this._loanApplicationData.SubStage__c : null;
            this.product = this._loanApplicationData.Product__c ? this._loanApplicationData.Product__c : null;

            if(this.product === 'Business Loan' || this.product === 'Personal Loan'){
                this.isBlPl = true;
            } 
            if(this.loanApplStage && this.loanApplSubStage && (this.loanApplStage === 'Post Sanction' && (this.loanApplSubStage === 'Data Entry' || this.loanApplSubStage === 'Ops Query')) || (this.loanApplStage === 'Disbursed' && this.loanApplSubStage === 'Additional Processing')){
                this.disableMode = false;
            }else{
                this.disableMode = true;
            }

            if(this._loanApplicationData.IsLoanApplCancelled__c === true){
                this.disableMode = true;
            }
        }

    }

  

    inputChangeHandler(event) {

        if (event.target.dataset.type === 'string') {
            let strVal = event.target.value;
            this.splitDisbWrapObj[event.target.dataset.name] = strVal.toUpperCase();
        } else {
            this.splitDisbWrapObj[event.target.dataset.name] = event.target.value;
        }



        let dateObj = new Date();
        let month = String(dateObj.getMonth() + 1)
            .padStart(2, '0');
        let day = String(dateObj.getDate())
            .padStart(2, '0');
        let year = dateObj.getFullYear();
        this.currDate = year + '-' + month + '-' + day;

        if (event.target.dataset.name === 'Payment_to__c') {
            this.paymentTo = event.target.value;
            this.isInsPart = false;
            if (event.target.value === "Repayment Account") {
                this.notReqForInsPartn = true
                this.initiPennDropBu = false
                this.isDisbBankDet = true
                this.repayAccParams.queryCriteria = ' where Is_Active__c = true AND Loan_Application__c = \'' + this._loanAppId + '\''
                getSobjectData({ params: this.repayAccParams })
                    .then((result) => {
                        console.log(' result from repay account ', result);
                        if (result) {
                            if (result.parentRecords) {      
                                this.applBankId = result.parentRecords[0].Applicant_Banking__c;
                                this.repayAccId = result.parentRecords[0].Id;
                              
                            }
                        }

                        this.applBankingDetails();
                        this.repayAccVerifi();
                    })

            } else if (event.target.value === "Third Party Account") {
                this.pennyDropInitButton = false;
                this.notReqForInsPartn = true
                this.isDisbBankDet = false
                this.splitDisbWrapObj.Cheq_Favor_Dets__c = '';
                this.splitDisbWrapObj.Cheq_Favor_Acc_No__c = '';
                this.splitDisbWrapObj.IFSC_Detail__c = '';
                this.splitDisbWrapObj.Penny_Drop_Nm_Sta__c = '';
                this.splitDisbWrapObj.Benef_Nm_of_Penny_Drop__c = '';
                this.isInsPart = false;
                if (this.disbTo !== "Insurance Company") {
                    this.initiPennDropBu = true
                }
            } else if (event.target.value === "Insurance Partner") {
                this.notReqForInsPartn = false
                this.isDisbBankDet = false
                this.initiPennDropBu = false
                this.splitDisbWrapObj.Cheq_Favor_Dets__c = '';
                this.splitDisbWrapObj.Cheq_Favor_Acc_No__c = '';
                this.splitDisbWrapObj.IFSC_Detail__c = '';
                this.splitDisbWrapObj.Penny_Drop_Nm_Sta__c = '';
                this.splitDisbWrapObj.Benef_Nm_of_Penny_Drop__c = '';
                this.splitDisbWrapObj.InsurancePartner__c = '';
                this.isInsPart = true;
                this.isDisbBankDet = this.isBlPl ? true: false;
            }
        }
        if (event.target.dataset.name === 'Pay_Mode__c') {
            if (event.target.value === "Funds Transfer") {
                this.isReqChequeDetails = true;
                this.fundTransMode = true
                this.isReqForFundTrans = true
                //this.disbDDDetails = true
            } else {
                this.isReqChequeDetails = true;
                this.fundTransMode = false
                this.isReqForFundTrans = false
                this.disbDDDetails = false
            }
        }
        if (event.target.dataset.name === 'Disbur_To__c') {
            this.disbTo = event.target.value;
            if (this.paymentTo === "Third Party Account" && event.target.value === "Insurance Company") {
                this.initiPennDropBu = false
            } else if (this.paymentTo === "Third Party Account" && event.target.value !== "Insurance Company") {
                this.initiPennDropBu = true
            }
        }
        if (event.target.dataset.name === 'Date_of_Disbur__c') {
            let selectedDate = event.target.value;

            if (selectedDate < this.currDate) {
                this.showToastMessage('Error', 'Date cannot be in past.', 'error', 'sticky');

            }
        }
        if (event.target.dataset.name === 'Cheq_DD_Date__c') {
            let selectedDate = event.target.value;

            if (selectedDate < this.currDate) {
                this.showToastMessage('Error', 'Date cannot be in past.', 'error', 'sticky');

            }
        }
        if (event.target.dataset.name === 'Effec_Date__c') {
            let selectedDate = event.target.value;

            if (selectedDate < this.currDate) {
                this.showToastMessage('Error', 'Date cannot be in past.', 'error', 'sticky');
            }
        }

        if (event.target.dataset.name === 'Cheq_Favor_Acc_No__c') {
            let enteredAccNumber = event.target.value;
            if (enteredAccNumber && enteredAccNumber.length > 8) {
               this.repaymentAccountHandler();
            }
        }

        if (event.target.dataset.name === 'IFSC_Detail__c') {
            let enteredIFSCcode = event.target.value;
            if (enteredIFSCcode && enteredIFSCcode.length > 10) {
               this.repaymentAccountHandler();
            }
        }

        if (event.target.dataset.name === 'Split_Cheque_Amt__c') {
            let tempAmount = event.target.value;
            this.splitDisbWrapObj.Split_Cheque_Amt__c = tempAmount;
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
                        this.splitDisbWrapObj.Split_Cheque_Amt__c = Number(str[0]);
                     }else
                     if(numres >= .50){
                        this.splitDisbWrapObj.Split_Cheque_Amt__c = Number(str[0])+1;
                     }else{
                        this.splitDisbWrapObj.Split_Cheque_Amt__c = tempAmount;
                     }
                }
                
            }
        }

    }

    applBankingDetails() {
        if (this.applBankId !== undefined) {
            this.applBankParams.queryCriteria = ' where Id = \'' + this.applBankId + '\''

            getSobjectData({ params: this.applBankParams })
                .then((result) => {

                    if (result.parentRecords) {
                        this.splitDisbWrapObj.Cheq_Favor_Dets__c = result.parentRecords[0].Name_of_the_Primary_Account_Holder_s__c;
                        this.splitDisbWrapObj.Cheq_Favor_Acc_No__c = result.parentRecords[0].AC_No__c;
                        this.splitDisbWrapObj.IFSC_Detail__c = result.parentRecords[0].IFSC_Code__c
                    }
                })
        }
    }

    repayAccVerifi() {
        if (this.repayAccId !== undefined) {
            this.repayAccVeriParams.queryCriteria = ' where LoanAppl__c = \'' + this._loanAppId + '\' AND RepayAcc__c = \'' + this.repayAccId + '\''
            // AND Is_Active__c = true
            getSobjectData({ params: this.repayAccVeriParams })
                .then((result) => {
                    if (result.parentRecords) {
                        if (result.parentRecords[0].PennyDropStatus__c !== undefined && result.parentRecords[0].NameRetuFromPennyDrop__c !== undefined) {
                            this.splitDisbWrapObj.Penny_Drop_Nm_Sta__c = result.parentRecords[0].PennyDropStatus__c;
                            this.splitDisbWrapObj.Benef_Nm_of_Penny_Drop__c = result.parentRecords[0].NameRetuFromPennyDrop__c;
                        }
                    }

                })
        }
    }

 
    @track pennyDropInitButton = false;
    repaymentAccountHandler(){

        this.pennyDropInitButton = false;
        if(this.splitDisbWrapObj && this.splitDisbWrapObj.Cheq_Favor_Acc_No__c != null &&  this.splitDisbWrapObj.IFSC_Detail__c != null) {        
            this.repayAccNumb = this.splitDisbWrapObj.Cheq_Favor_Acc_No__c;
            this.repayIFSCCode = this.splitDisbWrapObj.IFSC_Detail__c ;
        }

        if(this.repayAccNumb != null && this.repayIFSCCode != null){

            var repayAccParForPenDrop = {
                ParentObjectName: 'Repayment_Account__c',
                ChildObjectRelName: '',
                parentObjFields: ['Id', 'Name', 'Loan_Application__c', 'Applicant_Banking__c', 'Is_Active__c', 'IFSC_Code__c', 'Account_Number__c', 'Type__c', 'Is_Verified__c'],
                childObjFields: [],
                queryCriteria: ' WHERE Account_Number__c=\'' + this.repayAccNumb + '\' AND IFSC_Code__c=\'' + this.repayIFSCCode + '\' AND Loan_Application__c=\'' + this._loanAppId + '\' AND Type__c=\'' + this.TypeOfAcc + '\' AND Is_Verified__c > 0'
    
            }  
        }
       
        if(repayAccParForPenDrop && repayAccParForPenDrop != null){
            getSobjectDataNonCacheable({params: repayAccParForPenDrop})
            .then((result) => { 
                if(result){        
               console.log("Repayment account result----------->", JSON.stringify(result));          
                if (result.parentRecords && result.parentRecords.length > 0) {
                    if(result.parentRecords[0].Id){
                        this.pennyDropInitButton = true;
                        this.splitDisbWrapObj.Penny_Drop_Nm_Sta__c = 'SUCCESS';
                        this.showToastMessage("Success", 'Penny Drop already completed for mentioned IFSC Detail & Favoring Account Number.', "success", "sticky");
                    }
                }else{
                    if(this.splitDisbWrapObj && this.splitDisbWrapObj.Penny_Drop_Nm_Sta__c 
                        && this.splitDisbWrapObj.Penny_Drop_Nm_Sta__c != 'FAILURE'){
                        this.splitDisbWrapObj.Penny_Drop_Nm_Sta__c = '';
                    }
                  
                }} 
                }).catch((error) => {
                    console.log("Repayment Record Error------------->", JSON.stringify(error));
                });
       
                }

      
    }


    handleValueSelect(event) {
        this.lookupRec = event.detail;
        if (event.target.fieldName === 'Fedbank_Acc_Nm__c') {
            this.splitDisbWrapObj.Fedbank_Acc_Nm__c = this.lookupRec.mainField;
            this.splitDisbWrapObj.CashBankAccountId__c = this.lookupRec.id;

            if (this.splitDisbWrapObj.Fedbank_Acc_Nm__c !== undefined) {

                this.masterDataParams.queryCriteria =
                    " where Name = '" +
                    this.splitDisbWrapObj.Fedbank_Acc_Nm__c +
                    "' AND Type__c = '" +
                    this.fedBankTy +
                    "'";

                getSobjectDataNonCacheable({ params: this.masterDataParams }).then((data) => {
                    if (data) {
                        if (data.parentRecords) {
                            this.splitDisbWrapObj.Fedbank_Acc_No__c = data.parentRecords[0].BankAcNum__c;
                        }
                    }
                });

            }
            //     }
            //   } else if (error) {
            //     console.error("Error", error);
            //   }
            // });

        } else if (event.target.fieldName === 'Payable_At__c') {
            this.splitDisbWrapObj.Payable_At__c = this.lookupRec.mainField;
            this.splitDisbWrapObj.Pay_City_Id__c = this.lookupRec.id;
        }
        //LAK-7443 - BIL - Single Tranche Disbursement
        else if(event.target.fieldName == 'InsurancePartner__c'){
            this.splitDisbWrapObj.InsurancePartner__c = this.lookupRec.id;
            this.splitDisbWrapObj.Cheq_Favor_Dets__c = this.lookupRec.mainField;
            this.splitDisbWrapObj.Cheq_Favor_Acc_No__c = this.lookupRec.record.Ins_Bene_Acc_No__c;
            this.splitDisbWrapObj.IFSC_Detail__c = this.lookupRec.record.Insurnace_IFSC__c;
        }
    }

    get filterCondnChannel() {
        if (this.fedBankTy === "CashBank Account")
            return ("Type__c=" + "'" + this.fedBankTy + "'");
    }

//LAK-7443 - BIL - Single Tranche Disbursement
    get filterCondnInsPartner(){
        let insPartType = 'Insurance Partner';
        let bussLoan = 'Business Loan'
        return ("Type__c=" + "'" + insPartType + "' AND Product__c includes (" + "'" + this.product + "')" );
    }

    get showInsPartner(){
        return this.isInsPart && this.isBlPl;
    }

    get showTableVisbl() {
        return this.showTable;
    }

    fireCustomEventToParent() {
        this.dispatchEvent(new CustomEvent('handlesplitevent', { detail: this.showTable }));
    }

    //@track showTableVisbl = false;

 
    @track dateOfDisbursement;
    @track effectiveDate;
    @track wiredSplitDisbursData;
    @track actualSplitDisbursData;
    @track actualDisbursmentData;
    @track totalDisbAmt;
    @wire(getSobjectDatawithRelatedRecords, { params: '$splitDisburParams' })
    handleSplitResponse(wiredResult) {
        let { error, data } = wiredResult;
        this.wiredSplitDisbursData = wiredResult;
        console.log('Wired data------------>', JSON.stringify(this.wiredSplitDisbursData));

        if (data) {
            if (data.ChildReords && data.ChildReords.length > 0) {
                this.actualSplitDisbursData = data.ChildReords;
                this.handleSplitDisburseData();
            } else {
                this.addSpltDisbursmntHandler();
            }

            if (data.parentRecord && data.parentRecord != null) {
                this.dateOfDisbursement = data.parentRecord.Date_of_Disbur__c;       
                this.totalDisbAmt = data.parentRecord.Total_Disb_Amt__c;
                this.actualDisbursmentData = data.parentRecord;
                this.splitDisbWrapObj.Date_of_Disbur__c = this.dateOfDisbursement;
                
                if(data.parentRecord.Date_of_Disbur__c){
                    this.effectiveDate = data.parentRecord.Date_of_Disbur__c;
                    this.splitDisbWrapObj.Effec_Date__c = this.effectiveDate;
                }

                if(data.parentRecord.Disbur_Status__c && (data.parentRecord.Disbur_Status__c === 'DISBURSED' || data.parentRecord.Disbur_Status__c === 'INITIATED' || this.disableMode === true)){
                   this.disableMode = true;
                   this.isDisbBankDet = true;
                   this.disbDDDetails = true;
                }else if(this.userRole === 'BOM' || this.userRole === 'AOM' || this.userRole === 'ROM' || this.userRole === 'ZOM' || this.userRole === 'NOM' || this.userRole === 'CBO'){
                    this.disableMode = true;
                }
                else{
                    this.disableMode = false;
                }
               
            }

        } else if (error) {
            console.error('Error  ------------->', JSON.stringify(error));
        }
    }


    handleSplitDisburseData() {
        if (this.actualSplitDisbursData && this.actualSplitDisbursData.length > 0) {
            //this.showTable = true;
            this.fireCustomEventToParent();
            this.compareSplitAmtNTotalDisbAmt();
            this.splitDisbursDetailArr = [];
            this.actualSplitDisbursData.forEach(newItem => {
                let numberOfTranch = this.splitDisbursDetailArr.length + 1;
                let newObj = {
                    Id: newItem.Id,
                    Index__c: numberOfTranch,
                    Custo_Name__c: newItem.Custo_Name__c ? newItem.Custo_Name__c : '',
                    Date_of_Disbur__c: newItem.Date_of_Disbur__c ? newItem.Date_of_Disbur__c : '',
                    Disbur_To__c: newItem.Disbur_To__c ? newItem.Disbur_To__c : '',
                    Pay_City_Id__c: newItem.Pay_City_Id__c ? newItem.Pay_City_Id__c : '',
                    CashBankAccountId__c: newItem.CashBankAccountId__c ? newItem.CashBankAccountId__c : '',
                    Payment_to__c: newItem.Payment_to__c ? newItem.Payment_to__c : '',
                    Benef_Nm_of_Penny_Drop__c: newItem.Benef_Nm_of_Penny_Drop__c ? newItem.Benef_Nm_of_Penny_Drop__c : '',
                    Cheq_Favor_Acc_No__c: newItem.Cheq_Favor_Acc_No__c ? newItem.Cheq_Favor_Acc_No__c : '',
                    Cheq_Favor_Dets__c: newItem.Cheq_Favor_Dets__c ? newItem.Cheq_Favor_Dets__c : '',
                    Fedbank_Acc_No__c: newItem.Fedbank_Acc_No__c ? newItem.Fedbank_Acc_No__c : '',
                    Payable_At__c: newItem.Payable_At__c ? newItem.Payable_At__c : '',
                    Effec_Date__c: newItem.Effec_Date__c ? newItem.Effec_Date__c : '',
                    Fedbank_Acc_Nm__c: newItem.Fedbank_Acc_Nm__c ? newItem.Fedbank_Acc_Nm__c : '',
                    InsurancePartner__c: newItem.InsurancePartner__c ? newItem.InsurancePartner__c : '',
                    Cheq_DD_No__c: newItem.Cheq_DD_No__c ? newItem.Cheq_DD_No__c : '',
                    Cheq_DD_Date__c: newItem.Cheq_DD_Date__c ? newItem.Cheq_DD_Date__c : '',
                    IFSC_Detail__c: newItem.IFSC_Detail__c ? newItem.IFSC_Detail__c : '',
                    Fund_Transf_Mode__c: newItem.Fund_Transf_Mode__c ? newItem.Fund_Transf_Mode__c : '',
                    Penny_Drop_Nm_Sta__c: newItem.Penny_Drop_Nm_Sta__c ? newItem.Penny_Drop_Nm_Sta__c : '',
                    Pay_Mode__c: newItem.Pay_Mode__c ? newItem.Pay_Mode__c : '',
                    Custo_Name__c: newItem.Custo_Name__c ? newItem.Custo_Name__c : '',
                    Date_of_Disbur__c: newItem.Date_of_Disbur__c ? newItem.Date_of_Disbur__c : '',
                    Split_Cheque_Amt__c: newItem.Split_Cheque_Amt__c ? newItem.Split_Cheque_Amt__c : '',
                    Remarks__c: newItem.Remarks__c ? newItem.Remarks__c : '',
                };

                this.splitDisbursDetailArr.push(newObj);
            });
        }
        if (this.splitDisbursDetailArr && this.splitDisbursDetailArr.length  > 0  && this.pennyDropStatus === true) {
            const currentSplitData = this.splitDisbursDetailArr.find(item => item.Id == this.insertedSplitId);
            this.splitDisbWrapObj = {...currentSplitData};
            this.pennyDropStatus = false;
            this.insertedSplitId = undefined;           
        }
    }

    addSpltDisbursmntHandler() {
        this.pennyDropInitButton = false;

        this.splitDisbWrapObj = {
            sobjectType: 'Split_Disbur__c',
        };
 
        this.splitDisbWrapObj.Cheq_DD_No__c = '000000';
        this.splitDisbWrapObj.Disbur_To__c = 'Customer';
        this.splitDisbWrapObj.Pay_City_Id__c = '12';
        this.splitDisbWrapObj.Payable_At__c = 'MUMBAI';

        if(this.dateOfDisbursement){
            this.splitDisbWrapObj.Date_of_Disbur__c = this.dateOfDisbursement;
        }

        if( this.effectiveDate){
            this.splitDisbWrapObj.Effec_Date__c = this.effectiveDate;
        }
            
        if (this._loanApplicationData && this._loanApplicationData.CustomerName__c) {
            this.splitDisbWrapObj.Custo_Name__c = this._loanApplicationData.CustomerName__c;
        }

        this.showTable = false;
        this.fireCustomEventToParent();
    }

    @track
    parameterforTeam = {
        ParentObjectName: 'TeamHierarchy__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'EmpRole__c '],
        childObjFields: [],
        queryCriteria: 'WHERE Employee__c=\'' + CURRENT_USER_ID + '\'' + 'ORDER BY LastModifiedDate DESC'
    }

    @track userRole;
    @wire(getSobjectData, { params: '$parameterforTeam' })
    handleResponseTeamHierarchy(wiredResultTeam) {
        let { error, data } = wiredResultTeam;
        if (data) {
            if (data.parentRecords.length > 0) {
                let userTeamRole = data.parentRecords[0].EmpRole__c;
                if (userTeamRole) {
                    this.userRole = userTeamRole;
                    if(userTeamRole === 'BOM' || userTeamRole === 'AOM' || userTeamRole === 'ROM' || userTeamRole === 'ZOM' || userTeamRole === 'NOM' || userTeamRole === 'CBO'){
                        this.disableMode = true;
                    }
                }
            }
        } else if (error) {
            console.error('Error ------------->', error);
        }
    }

    @track payToValue
    viewSplitDisbHandler(event) {
        this.splitDisbWrapObj = this.splitDisbursDetailArr[event.target.accessKey - 1];
        this.splitDisbWrapObj.Date_of_Disbur__c = this.dateOfDisbursement ? this.dateOfDisbursement : null;
        this.splitDisbWrapObj.Effec_Date__c = this.effectiveDate ?  this.effectiveDate : null;
        this.payToValue = this.splitDisbWrapObj.Payment_to__c;
        this.isInsPart = this.payToValue === 'Insurance Partner' ? true : false;
        console.log('split Disb WrapObj----------------->', JSON.stringify(this.splitDisbWrapObj));

        if (this.splitDisbWrapObj.Pay_Mode__c === "Funds Transfer") {
            this.isReqChequeDetails = true
            this.fundTransMode = true
            this.isReqForFundTrans = true
            //this.disbDDDetails = true
        } else {
            this.isReqChequeDetails = true
            this.fundTransMode = false
            this.isReqForFundTrans = false
            this.disbDDDetails = this.disableMode === true ? true : false;
        }

        if (this.payToValue && this.payToValue === 'Repayment Account') {
            this.isDisbBankDet = true
        } else {
            this.isDisbBankDet = this.disableMode === true ? true : false;
        }

        if(this.isBlPl && this.payToValue === 'Insurance Partner'){
            this.isDisbBankDet = true;
        }
        else{
            this.isDisbBankDet = this.disableMode === true ? true : false;
        }

        this.splitDisbWrapObj.Pay_City_Id__c = '12';
        this.splitDisbWrapObj.Payable_At__c = 'MUMBAI';
        this.splitDisbWrapObj.Disbur_To__c = 'Customer';

        if (this.splitDisbWrapObj.Payment_to__c && this.splitDisbWrapObj.Payment_to__c === 'Third Party Account') {
            // this.isDisbBankDet = true
        } 
       

        if(this.splitDisbWrapObj && this.splitDisbWrapObj.Cheq_Favor_Acc_No__c != null &&  this.splitDisbWrapObj.IFSC_Detail__c != null) {
            this.repaymentAccountHandler();
           
        }
  
        this.showTable = false;
        this.fireCustomEventToParent();
       
    }


    @api validateForm() {
        var isInputCorrect = [
            ...this.template.querySelectorAll("lightning-input"),
            ...this.template.querySelectorAll("lightning-combobox")
        ].reduce((validSoFar, inputField) => {

            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        if (!this.checkCustomLookupValidity()) {
            isInputCorrect = false;
        }
        if (isInputCorrect === false) {
            this.showToastMessage("Error", 'Please fill all required fields', "error", "dismissible");
        }

        return isInputCorrect;
    }

    
    checkCustomLookupValidity() {
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


    @track disbursmentDetails;
    @api handleUpsert() {
        if (this._disbursmentId) {
            if (this.splitDisbWrapObj && this.showTable == false) {
                this.showSpinner = true;

                this.disbursmentDetails = {
                    Id: this._disbursmentId,
                    Loan_Appli__c: this._loanAppId,
                    sobjectType: 'Disbursement__c'

                };
                var parentDisbDetails;
                parentDisbDetails = { ...this.disbursmentDetails };

                var tempSplitDisbursArr = [];
                var childDisbDetails = [];
                tempSplitDisbursArr.push(this.splitDisbWrapObj);
                childDisbDetails = [...tempSplitDisbursArr];

                let upsertData = {
                    parentRecord: parentDisbDetails,
                    ChildRecords: childDisbDetails,
                    ParentFieldNameToUpdate: 'DisburseRela__c'
                }
                console.log('upsertData 334-', JSON.stringify(upsertData));
                upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
                    .then(result => {
                        this.showToastMessage("Success", 'Split Disbursement Details Saved Successfully', "success", "sticky");
                        this.showTable = true;
                        this.fireCustomEventToParent();
                        this.compareSplitAmtNTotalDisbAmt();
                        refreshApex(this.wiredSplitDisbursData);
                        this.showSpinner = false;

                    })
                    .catch(error => {
                        console.error(error)
                        console.log('upsert error -', JSON.stringify(error));
                        this.showToastMessage("Error In Upsert Record ", error.body.message, "error", "sticky");
                        this.showSpinner = false;
                    })
            } else {
                this.showToastMessage("Error", 'Split Disbursement Details Not Available to Save', "error", "sticky");
                this.showSpinner = false;
            }
        } else {
            this.showToastMessage("Error", 'Disbursement Record Not Found', "error", "sticky");
        }
    }

    renderedCallback() {
         refreshApex(this.wiredSplitDisbursData);
    }


    @track totalOfSpliChqAmt = []
    @track splitChAmt = [];
    compareSplitAmtNTotalDisbAmt() {
        if (this.showTable === true) {
            this.splitParams.queryCriteria = ' where DisburseRela__c = \'' + this._disbursmentId + '\''
            getSobjectDataNonCacheable({ params: this.splitParams })
                .then((result) => {
                    if (result.parentRecords) {
                        // this.totalOfSpliChqAmt = 0
                        // result.parentRecords.forEach((element) => {
                        //     this.splitChAmt.push({
                        //         value: element.Split_Cheque_Amt__c
                        //     });
                        // });
                        // this.totalOfSpliChqAmt = this.splitChAmt.reduce((total, record) => {
                        //     return total + record.value;
                        // }, 0);
                        // console.log('total split amt', this.totalOfSpliChqAmt);
                        let sumByParent = {};

                        result.parentRecords.forEach(element => {
                            if (element.Split_Cheque_Amt__c) {
                                // Ensure Split_Cheque_Amt__c is not null or undefined
                                let sum = sumByParent[element.Id] || 0;
                                sum += element.Split_Cheque_Amt__c;
                                sumByParent[element.Id] = sum;
                            }
                        });
                        let overallSum = 0;
                        Object.values(sumByParent).forEach(sum => {
                            overallSum += sum;
                        });
                
                        if (this.totalDisbAmt !== overallSum) {
                         
                            this.showToastMessage('Error', this.customLabel.Trachy_SplChqAmt_ErrorMessage, 'error', 'sticky');
                        }
                    }
                }
                )
        }
    }


    @track showDeleteConfirmation = false;
    @track recordDelId;
    @track accessKeyForDeletion;
    deleteHandler(event) {
        this.showDeleteConfirmation = true;
        this.recordDelId = this.splitDisbursDetailArr[event.target.accessKey - 1].Id;
        this.accessKeyForDeletion = event.target.accessKey;
    }

    hideModalBox() {
        this.showDeleteConfirmation = false;
    }

    handleConfirmDelete() {
        this.handleRecordDeletion();
        this.showDeleteConfirmation = false;
    }
    handleCancelDelete() {
        this.showDeleteConfirmation = false;
    }


    handleRecordDeletion() {
        if (this.recordDelId) {
            this.showSpinner = true;
            let deleteRecord = [
                {
                    Id: this.recordDelId,
                    sobjectType: 'Split_Disbur__c'
                }
            ]
            deleteIncomeRecord({ rcrds: deleteRecord })
                .then(result => {
                    this.showSpinner = false;
                    this.showToastMessage("Success", 'Split Disbursement Record Deleted Successfully', "success", "sticky");
                    refreshApex(this.wiredSplitDisbursData);
                    this.showDeleteConfirmation = false;

                })
                .catch(error => {
                    console.log('Delete Error----------->' + JSON.stringify(error));
                    this.showSpinner = false;
                    this.showToastMessage("Error In handleDeleteAction ", error.body.message, "error", "sticky");
                    this.showDeleteConfirmation = false;
                })
        }
        else {
            this.showSpinner = false;
            this.showToastMessage("Success", 'Split Disbursement Record Deleted Successfully', "success", "sticky");
            this.showDeleteConfirmation = false;
        }

        if (this.splitDisbursDetailArr.length >= 1) {
            this.splitDisbursDetailArr.splice(this.accessKeyForDeletion - 1, 1);

            for (let i = 0; i < this.splitDisbursDetailArr.length; i++) {
                this.splitDisbursDetailArr[i].Index__c = i + 1;
            }

        }
    }


    @api showTableHandler() {
        this.showTable = true;
        this.compareSplitAmtNTotalDisbAmt();
    }

    get todaysDate() {
        var dateObj1 = new Date();
        let month = String(dateObj1.getMonth() + 1).padStart(2, '0');
        let day = String(dateObj1.getDate()).padStart(2, '0');
        let year = dateObj1.getFullYear();
        var currDate = year + '-' + month + '-' + day;
        return currDate;
    }

    generatePicklist(data) {
        if (data) {
            return data.values.map(item => ({ "label": item.label, "value": item.value }))
        }
    }

    @track initiPennDropBu = false

    @track disburToOption = [];
    @track payToOption = [];
    @track payModeOption = [];
    @track pennyDropStaOption = [];
    @track fundTransModeOption = [];

    @wire(getObjectInfo, { objectApiName: SPLT_DISBRS_OBJECT })
    objectInfo

    @wire(getPicklistValuesByRecordType, {
        objectApiName: SPLT_DISBRS_OBJECT,
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    }) picklistHandler({ data, error }) {
        if (data) {
            this.disburToOption = [...this.generatePicklist(data.picklistFieldValues.Disbur_To__c)];
            this.payToOption = [...this.generatePicklist(data.picklistFieldValues.Payment_to__c)];
            this.payModeOption = [...this.generatePicklist(data.picklistFieldValues.Pay_Mode__c)];
            this.pennyDropStaOption = [...this.generatePicklist(data.picklistFieldValues.Penny_Drop_Nm_Sta__c)];
            this.fundTransModeOption = [...this.generatePicklist(data.picklistFieldValues.Fund_Transf_Mode__c)];
            // let tempParams = this.splitDisburParams;
            // tempParams.queryCriteria = ' where Id = \'' + this._disbursmentId + '\'';
            // this.splitDisburParams = { ...tempParams };
        }


        if (error) {
            console.error(error)
        }
    }

    get disableInitPenDropButtn(){
          if((this.splitDisbWrapObj && this.splitDisbWrapObj.Penny_Drop_Nm_Sta__c ==='SUCCESS')
           || (this.pennyDropInitButton === true || this.disableMode === true )){
              return true;
          }
    }


    get reqFavringAccNumber(){

        if(this.splitDisbWrapObj && this.splitDisbWrapObj.Payment_to__c){
                if(this.splitDisbWrapObj.Pay_Mode__c && this.splitDisbWrapObj.Pay_Mode__c == "Funds Transfer"){
                    return true;
                }
           
        }
    }

    get initiPennDropButton(){

        if(this.splitDisbWrapObj && this.splitDisbWrapObj.Payment_to__c && this.splitDisbWrapObj.Payment_to__c == "Third Party Account" 
        && this.splitDisbWrapObj.Pay_Mode__c && this.splitDisbWrapObj.Pay_Mode__c == "Funds Transfer"){
            return true;
        }
    }

    get requiredIFSCDetails(){

        if(this.splitDisbWrapObj && this.splitDisbWrapObj.Payment_to__c){
            if(this.splitDisbWrapObj.Pay_Mode__c && this.splitDisbWrapObj.Pay_Mode__c == "Funds Transfer"){
                return true;
            }else{
                return false;
            }
       
    }
        // if(this.splitDisbWrapObj && this.splitDisbWrapObj.Payment_to__c && this.splitDisbWrapObj.Payment_to__c == "Third Party Account"){
        //     return true;
        // }
    }
    
    // isReqChequeDetails
  
    

    intiatePennyDrop(event) {
        var splitDisbursementRecordId;
        if (event.target.dataset.recordid) {
            splitDisbursementRecordId = event.target.dataset.recordid;
        }
        // var validateEnteredData = this.validateForm();
        // if(validateEnteredData){

        // }
        let validateDetails = this.validateForm();
        this.initiPennyDrop(splitDisbursementRecordId);
    }


    @track insertedSplitId;
    initiPennyDrop(splitDisbursementRecordId) {
        this.showSpinner = true;
        let newArray = [];
        let fields = {};
        fields.Name = 'ICICI PennyDrop';
        fields.Status__c = 'New';
        fields.Svc__c = 'ICICI PennyDrop';
        fields.BU__c = 'HL / STL';
        fields.IsActive__c = true;
        fields.RefObj__c = 'Split_Disbur__c';
        fields.Trigger_Platform_Event__c = true


        if(this.splitDisbWrapObj){
            if(this.disbursmentId){
                this.splitDisbWrapObj.DisburseRela__c = this.disbursmentId;
                newArray.push(this.splitDisbWrapObj); 
            }
              
        }

        let validateDetails = this.validateForm();
        if (newArray && newArray.length > 0 && validateDetails) {
            upsertMultipleRecord({ params: newArray })
                .then((result) => {        
                    this.insertedSplitId = result[0].Id;
                    this.splitDisbWrapObj = { ...this.splitDisbWrapObj };
                    this.splitDisbWrapObj.Id = this.insertedSplitId;
                    fields.RefId__c = result[0].Id ? result[0].Id : '';
                    if(fields.RefId__c ){
                        this.createIntMsg(fields, 'Penny Drop');
                    }
                   

                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log('Error In Saving Record', JSON.stringify(error));
                    this.showToastMessage('Error', 'An unexpected error occurred. Please try again.', 'error', 'sticky');
                });

                
        }else{
            this.showSpinner = false;
        }
       
        
    }

    @track pennyDropIntMsgId;

    createIntMsg(fieldsInt, name) {
        const recordInput = {
            apiName: 'IntgMsg__c',
            fields: fieldsInt
        };
        createRecord(recordInput)
            .then((result) => {
                console.log('Result data!! ' + JSON.stringify(result));
                if (name === 'Penny Drop') {
                    this.pennyDropIntMsgId = result.id;
                    this.callSubscribePlatformEve();
                }
            }).catch((error) => {
                this.showSpinner = false;
                console.log('Error data!! ' + JSON.stringify(error));
                this.showToastMessage('Error', 'An unexpected error occurred. Please try again.', 'error', 'sticky');
                //this.showToastMessage('Error', this.customLabel.Trachy_Int_ErrorMessage, 'error', 'sticky');
            });
    }

    callSubscribePlatformEve() {
        //Commnet platform event subscription temproroly
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
                   
                    this.showSpinner = false;
                    console.log('Error In Subscribing', JSON.stringify(error));
                    this.showTable = false;
                  
                }
                );
                console.log(window.location.protocol + '//' + window.location.hostname + '/cometd/50.0/',);
            } else {
                this.handleUnsubscribe();
                this.showSpinner = false;
                this.showToastMessage('Error', 'An unexpected error occurred. Please try again.', 'error', 'sticky');
                console.error('Error in handshaking: ' + JSON.stringify(status));
            }
        });
        
    }


    @track disableIntiatePennyDrop = false;
    @track pennyDropStatus = false;
    handlePlatformEventResponce(payload) {
        console.log('responce From PlatformEvent ', JSON.stringify(payload));
        if (payload) {
            if (payload.SvcName__c === 'ICICI PennyDrop' && payload.IntMsgId__c && (payload.IntMsgId__c === this.pennyDropIntMsgId)) {
                if (payload.Success__c === true) {
                    console.log('Success')
                    this.disableIntiatePennyDrop = true;           
                    this.pennyDropStatus = true;
                    refreshApex(this.wiredSplitDisbursData);
                    this.showToastMessage('Success', 'Transaction Successful.', 'success', 'sticky');
                    this.showTable = false;
                    this.showSpinner = false;
                    this.handleUnsubscribe();
                    
                } else {
                    console.log('Failure')
                    this.pennyDropStatus = true;
                    refreshApex(this.wiredSplitDisbursData);
                    this.showTable = false;
                    this.showSpinner = false;
                    this.showToastMessage('Error', payload.Error_Message__c, 'error', 'sticky');  
                    this.handleUnsubscribe();
                    
                }
            }
        }
    }

    handleUnsubscribe() {
        console.log('unsubscription 0', this.PEsubscription);
        if (this.PEsubscription) {
            //Unsubscribing Cometd
            this.noIntResponec = false;
            this.cometdlib.unsubscribe(this.PEsubscription, {}, (unsubResult) => {

                if (unsubResult.successful) {
                    console.log('unsubscription STARTED ');
                    //Disconnecting Cometd
                    this.cometdlib.disconnect((disResult) => {
                        if (disResult.successful) {
                            this.showSpinner = false;
                            console.log('unsubscription SUCCESS');
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
            this.showSpinner = false;
            this.PEsubscription = undefined;

        }else{
            this.showSpinner = false;
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
}