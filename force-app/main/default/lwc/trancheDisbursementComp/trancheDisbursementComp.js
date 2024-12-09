import { LightningElement, track, api, wire } from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';

import deleteIncomeRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getSobjectDat from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import generateDocument from "@salesforce/apex/GeneratePDFandAttachToLoanApplication.generateDocument";
import createDocumentDetail from "@salesforce/apex/DocumentDetailController.createDocumentDetail";
import disbursementMemo from '@salesforce/label/c.PageURLDisbusementMemo';
import { getObjectInfo, getPicklistValues, getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import UserId from "@salesforce/user/Id";

const userId = UserId;


import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const columns = [
    { label: 'Application Id', fieldName: 'ApplicationID__c' },
    { label: 'Disbursal Number', fieldName: 'Disbur_No__c' },
    { label: 'Date Of Disbursement', fieldName: 'Date_of_Disbur__c' },
    {
        label: 'View',
        type: 'button',
        typeAttributes: {
            label: 'View',
            title: 'View',
            variant: 'base',
            iconName: 'utility:preview',
            alternativeText: 'View',
            editable: true
        }
    }
];

const splitDisForColumns = [
    { label: 'Split Disbursal Number', fieldName: 'Name' },
    // { label: 'Disbursal Number', fieldName: 'Name' },
    { label: 'Date Of Disbursement', fieldName: 'Date_of_Disbur__c' },
    {
        label: 'View',
        type: 'button',
        typeAttributes: {
            label: 'View',
            title: 'View',
            variant: 'base',
            iconName: 'utility:preview',
            alternativeText: 'View'
        }
    }
];


//For Disbursement
import DISBUR_OBJ from '@salesforce/schema/Disbursement__c';
import MAST_DATA_OBJ from "@salesforce/schema/MasterData__c";
import DISB_TO_FIELD from "@salesforce/schema/Disbursement__c.Disbur_To__c";
import SP_DIS_PAY_TO from '@salesforce/schema/Split_Disbur__c.Payment_to__c';
import LA_OBJECT from "@salesforce/schema/LoanAppl__c";


//For Split Disbursement
import SP_DISBUR_OBJ from '@salesforce/schema/Split_Disbur__c';


// LMS
import { subscribe, publish, MessageContext, unsubscribe, releaseMessageContext, createMessageContext } from 'lightning/messageService';
import { getRecord, createRecord, updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";

import { refreshApex } from '@salesforce/apex';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';

//Plarform Event & Integration
import cometdlwc from "@salesforce/resourceUrl/cometd";
import getSessionId from '@salesforce/apex/SessionUtil.getSessionId';
import { loadScript } from "lightning/platformResourceLoader";
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


import AccType from "@salesforce/schema/MasterData__c.Type__c";
const typeField = [
    AccType
]

export default class TrancheDisbursementComp extends LightningElement {

    @track showPrincipleFields = false;
    @track showSpinner=false;
    @track disblCrateTranButton = true;
    @track priciplStartDate='';
    @track loanApplicationData;
    @track fedBankTy = "CashBank Account";
    @track splitDisbButton= true;
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

    @track disburDetailsArr=[];
    @track disbTypeOptions=[];
    @track dataOfDisbur = [];
    @track dataOfSplitDisb = []
    @track columns = [...columns];
    @track columnsForSplitDis = [...splitDisForColumns];

    @track disburDetails = false;
    @track splitDisburDetails = false;
    @track disburmentDet;
    @track splitDisId;
    @api recordId;
    @api channelName = "/event/IntRespEvent__e";
    @track sessionId;
    cometdlib;
    @track subscription;
    @track PEsubscription;
    @track activeSection = ["A", "B", "C"];
    @track isDisbSplit = false;
    @track princReldFields = false
    @track isPendTotalDisbAmt = false

    //New Section
    disbursementMemoType = ['Disbursement Memo'];
    disbursementMemoSubType = ['Disbursement Memo'];
    disbursementMemoCategory = ['Disbursement Memo'];
    @track showDocList = true;
    @track isLoading = false;


    @track
    loanApplparams = {
        ParentObjectName: 'LoanAppl__c',
        ChildObjectRelName: 'Applicants__r',
        parentObjFields: ['Id', 'Name', 'FirstEMIDate__c', 'Product__c','CustomerName__c', 'Stage__c', 'SubStage__c', 'ProductSubType__c', 'DisbursalType__c', 'SchmCode__c', 'Loan_Tenure_Months__c', 'SanLoanAmt__c', 'TotalLoanAmtInclInsurance__c', 'PendingDisbursalAmount__c', 'Total_PF_Amount__c', 'TotalLoanAmountIncCharges__c', 'OwnerId'],
        childObjFields: ['FName__c', 'LName__c', 'LoanAppln__c', 'CompanyName__c', 'Constitution__c', 'ApplType__c'],
        queryCriteria: ''
    }

    @track _loanAppId
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);

        this.handleLoanApplRecords(value);
        this.getLoanAppData();
    }
    @api layoutSize;
    @api hasEditAccess;

    handleLoanApplRecords(value) {
        let tempParams = this.loanApplparams;
        tempParams.queryCriteria = ' where Id = \'' + this._loanAppId + '\''
        this.loanApplparams = { ...tempParams };

        let tempPar = this.disburParams;
        tempPar.queryCriteria = ' where Loan_Appli__c = \'' + this._loanAppId + '\''
        this.disburParams = { ...tempPar }
    }


    // @track _splitDisburParams
    // get splitDisburParams() {
    //     return this._splitDisburParams;
    // }
    @track
    splitParams = {
        ParentObjectName: 'Split_Disbur__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'DisburseRela__c', 'Disbur_To__c', 'Split_Cheque_Amt__c', 'Date_of_Disbur__c', 'Custo_Name__c', 'Pay_Mode__c', 'Penny_Drop_Nm_Sta__c', 'Fund_Transf_Mode__c', 'IFSC_Detail__c', 'Cheq_DD_Date__c', 'Cheq_DD_No__c', 'Fedbank_Acc_Nm__c', 'Effec_Date__c', 'Payable_At__c', 'Fedbank_Acc_No__c', 'Cheq_Favor_Dets__c', 'Remarks__c', 'Cheq_Favor_Acc_No__c', 'Benef_Nm_of_Penny_Drop__c', 'Payment_to__c', 'CashBankAccountId__c', 'Pay_City_Id__c'],
        childObjFields: [],
        queryCriteria: ''
    }

    @track
    splitDisburParams = {
        ParentObjectName: 'Split_Disbur__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'DisburseRela__c', 'Disbur_To__c', 'Split_Cheque_Amt__c', 'Date_of_Disbur__c', 'Custo_Name__c', 'Pay_Mode__c', 'Penny_Drop_Nm_Sta__c', 'Fund_Transf_Mode__c', 'IFSC_Detail__c', 'Cheq_DD_Date__c', 'Cheq_DD_No__c', 'Fedbank_Acc_Nm__c', 'Effec_Date__c', 'Payable_At__c', 'Fedbank_Acc_No__c', 'Cheq_Favor_Dets__c', 'Remarks__c', 'Cheq_Favor_Acc_No__c', 'Benef_Nm_of_Penny_Drop__c', 'Payment_to__c', 'CashBankAccountId__c', 'Pay_City_Id__c'],
        childObjFields: [],
        queryCriteria: ' where DisburseRela__c = \'' + this.disbRowId + '\''
    }

    @track
    disburParams = {
        ParentObjectName: 'Disbursement__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'ApplicationID__c', 'Loan_Appli__c', 'Product__c', 'Appl_Name__c', 'Loan_Tenu__c', 'Scheme__c', 'Total_Disb_Amt__c', 'Disbur_To__c', 'No_of_Disbur__c', 'Princ_Rec_on__c', 'Princ_Start_Date__c', 'Disbur_No__c', 'Disbur_Desrp__c', 'Date_of_Disbur__c', 'Disbur_Status__c', 'Pend_Disbur_Amt__c','Index__c','DisbrDiscription__c'],
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
        parentObjFields: ['Id', 'Name', 'LoanAppl__c', 'RepayAcc__c', 'PennyDropStatus__c'],
        childObjFields: [],
        queryCriteria: ''
    }


    @track disburTy
    @track numberOfRec
    @track wrapDisburObj = {}
    @track wrapSplitDisbObj = []
    @track isDisbFavor = false
    @track pendDisbAmt

    @track mode = false;
    // get disbCreTranch() {
    //     return this.hasEditAccess === false || this.disburTy === "Single";
    // }
    @track modeForSplit = false
    @track initiPennDropBu = false
    @track pennyDropIntMsgId;

    @track _wiredLoanApplData
    @track isDisbDisbAmt = true;
    @track loanNo
    @track totalDisAmtFrLoan

    @track disburseId = []
    @track _wiredDisburData
    @track disbursmentData = []


    // @track splitDisData = {}
    @track splitDisData = []

    @track disburRelnId
    @track disableMode;
    @track disbDisbMemo = true
    @track queryData = 'SELECT Id FROM Case WHERE Loan_Application__c =: loanAppId';
    @track _wiredSplitDisbData = []


    @track newDisburId
    @api objectApiName = 'Disbursement__c';
    @track splitDisb = 'Split_Disbur__c'

    @track disbRowId
    @track onRowDusburData;

    @track splitDisRowId
    @track applBankId;
    @track repayAccId
    @track currDate
    @track fundTransMode
    @track genDM = "Please fill tranche details and related split disbursement records.";


    generatePicklist(data) {
        return data.values.map((item) => ({
            label: item.label,
            value: item.value
        }));
    }

    @wire(getObjectInfo, { objectApiName: DISBUR_OBJ })
    objInfo;

    @wire(getPicklistValues, {
        recordTypeId: "$objInfo.data.defaultRecordTypeId",
        fieldApiName: DISB_TO_FIELD
    })
    propertyIndentiPicklistHandler({ data, error }) {
        if (data) {
            this.disburToOptForDisb = [...this.generatePicklist(data)];
        }
        if (error) {
            console.log("error ", error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$objInfo.data.defaultRecordTypeId",
        fieldApiName: SP_DIS_PAY_TO
    })
    propertyIndentiPicklistHandler({ data, error }) {
        if (data) {
            this.payToOption = [...this.generatePicklist(data)];
        }
        if (error) {
            console.log("error ", error);
        }
    }

    @wire(getPicklistValuesByRecordType, {
        objectApiName: DISBUR_OBJ,
        recordTypeId: "$objInfo.data.defaultRecordTypeId"
    })
    picklistHandler({ data, error }) {
        if (data) {
            //console.log(data)
            this.disburToOptForDisb = [
                ...this.generatePicklist(
                    data.picklistFieldValues.Disbur_To__c
                )
            ];
        }
    }

   
    @wire(getPicklistValuesByRecordType, {
        objectApiName: LA_OBJECT,
        recordTypeId: "$objInfo.data.defaultRecordTypeId"
    })  loanApplPicklistHandler({ data, error }) {
        if (data) {
    this.disbTypeOptions = [
        ...this.generatePicklist(data.picklistFieldValues.DisbursalType__c)
      ];  }
    }

    get productOption() {
        return [
            { label: 'Home Loan', value: 'Home Loan' },
            { label: 'Small Ticket LAP', value: 'Small Ticket LAP' },
            { label: 'Loan Against Property', value: 'Loan Against Property' },
        ];
    }


    get disburToOption() {
        return [
            { label: 'Customer', value: 'Customer' },
            { label: 'Builder', value: 'Builder' },
            { label: 'Seller', value: 'Seller' },
            { label: 'Architect', value: 'Architect' },
            { label: 'Insurance Company', value: 'Insurance Company' }
        ];
    }

    get princRecOption() {
        return [
            { label: 'Amount Disbursed till Date', value: 'Amount Disbursed till Date' },
            { label: 'Amount Financed', value: 'Amount Financed' }
        ];
    }

    get disburDesrOption() {
        return [
            { label: 'Tranche 1', value: 'Tranche 1' },
            { label: 'Tranche 2', value: 'Tranche 2' },
            { label: 'Tranche 3', value: 'Tranche 3' },
            { label: 'Tranche 4', value: 'Tranche 4' },
            { label: 'Tranche 5', value: 'Tranche 5' },
            { label: 'Tranche 6', value: 'Tranche 6' },
            { label: 'Tranche 7', value: 'Tranche 7' },
            { label: 'Tranche 8', value: 'Tranche 8' },
            { label: 'Tranche 9', value: 'Tranche 9' },
            { label: 'Tranche 10', value: 'Tranche 10' },
            { label: 'Tranche 11', value: 'Tranche 11' },
            { label: 'Tranche 12', value: 'Tranche 12' },
            { label: 'Tranche 13', value: 'Tranche 13' },
            { label: 'Tranche 14', value: 'Tranche 14' },
            { label: 'Tranche 15', value: 'Tranche 15' }

        ];
    }

    get disbNoOptions() {
        return [
            { label: '1', value: '1' },
            { label: '2', value: '2' },
            { label: '3', value: '3' },
            { label: '4', value: '4' },
            { label: '5', value: '5' },
            { label: '6', value: '6' },
            { label: '7', value: '7' },
            { label: '8', value: '8' },
            { label: '9', value: '9' },
            { label: '10', value: '10' },
            { label: '11', value: '11' },
            { label: '12', value: '12' },
            { label: '13', value: '13' },
            { label: '14', value: '14' },
            { label: '15', value: '15' }
        ];
    }

    get disburStatOption() {
        return [
            { label: 'Entered', value: 'Entered' },
            { label: 'Disbursed', value: 'Disbursed' },
            { label: 'Initiated', value: 'Initiated' }
        ];
    }

    get payModeOption() {
        return [
            { label: 'Cheque', value: 'Cheque' },
            { label: 'Draft', value: 'Draft' },
            { label: 'Funds Transfer', value: 'Funds Transfer' }
        ];
    }

    get pennyDropStaOption() {
        return [
            { label: 'SUCCESS', value: 'SUCCESS' },
            { label: 'FAILURE', value: 'FAILURE' }
        ];
    }

    get fundTransModeOption() {
        return [
            { label: 'IMPS', value: 'IMPS' },
            { label: 'Internal Transfer', value: 'Internal Transfer' },
            { label: 'NEFT', value: 'NEFT' },
            { label: 'RTGS', value: 'RTGS' }
        ];
    }

    // get payToOption() {
    //     return [
    //         { label: 'Repayment Account', value: 'Repayment Account' },
    //         { label: 'Third Party Account', value: 'Third Party Account' }
    //     ];
    // }

    @wire(MessageContext)
    MessageContext;

    @wire(getSessionId)
    wiredSessionId({ error, data }) {
        if (data) {
            console.log('session Id=', data);
            this.sessionId = data;
            loadScript(this, cometdlwc);
        } else if (error) {
            console.log('Error In getSessionId = ', error);
            this.sessionId = undefined;
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

    @track dynamicErrorMessage = '';
    @track showError = false;
    addRow() {
        // this.dataOfSplitDisb = []
        //temp above line for checking
        this.disburDetails = true
        this.isDisbSplit = true
        if (this.disburTy !== undefined && this.pendDisbAmt !== undefined && this.wrapDisburObj.Total_Disb_Amt__c !== undefined) {
            if (this.disburTy === "Multiple" && (this.pendDisbAmt > this.wrapDisburObj.Total_Disb_Amt__c)) {
                this.dynamicErrorMessage = 'Total Disbursal Amount should be more than Pending Disbursal Amount.';
                this.showError = true;
                this.setValidity(true);
            }


        }
        if (this.disburTy === "Multiple" && this.countOfDisbNo !== undefined) {
            if (this.countOfDisbNo < this.maxClickCount) {
                this.countOfDisbNo += 1
                console.log('count of add button', this.countOfDisbNo);
                this.wrapDisburObj.Disbur_No__c = String(this.countOfDisbNo)
                let disburNo = String(this.countOfDisbNo)
                if (disburNo === "1") {
                    this.wrapDisburObj.Disbur_Desrp__c = "Tranche 1"
                } else if (disburNo === "2") {
                    this.wrapDisburObj.Disbur_Desrp__c = "Tranche 2"
                } else if (disburNo === "3") {
                    this.wrapDisburObj.Disbur_Desrp__c = "Tranche 3"
                } else if (disburNo === "4") {
                    this.wrapDisburObj.Disbur_Desrp__c = "Tranche 4"
                } else if (disburNo === "5") {
                    this.wrapDisburObj.Disbur_Desrp__c = "Tranche 5"
                } else if (disburNo === "6") {
                    this.wrapDisburObj.Disbur_Desrp__c = "Tranche 6"
                } else if (disburNo === "7") {
                    this.wrapDisburObj.Disbur_Desrp__c = "Tranche 7"
                } else if (disburNo === "8") {
                    this.wrapDisburObj.Disbur_Desrp__c = "Tranche 8"
                } else if (disburNo === "9") {
                    this.wrapDisburObj.Disbur_Desrp__c = "Tranche 9"
                } else if (disburNo === "10") {
                    this.wrapDisburObj.Disbur_Desrp__c = "Tranche 10"
                } else if (disburNo === "11") {
                    this.wrapDisburObj.Disbur_Desrp__c = "Tranche 11"
                } else if (disburNo === "12") {
                    this.wrapDisburObj.Disbur_Desrp__c = "Tranche 12"
                } else if (disburNo === "13") {
                    this.wrapDisburObj.Disbur_Desrp__c = "Tranche 13"
                } else if (disburNo === "14") {
                    this.wrapDisburObj.Disbur_Desrp__c = "Tranche 14"
                } else if (disburNo === "15") {
                    this.wrapDisburObj.Disbur_Desrp__c = "Tranche 15"
                }
            }
        }
    }

    setValidity(isValid) {
        const inputField = this.template.querySelector('lightning-input');
        if (inputField) {
            console.log('input field', inputField);
            inputField.reportValidity();
            inputField.setCustomValidity(isValid ? '' : this.dynamicErrorMessage);
        }
    }

    intiatePennyDrop(event) {
        console.log('target name ', event.target.name);
        this.initiPennyDrop();
    }

    initiPennyDrop() {
        const obje = {
            sobjectType: "Split_Disbur__c",
            DisburseRela__c: this.disbRowId
            // RepayAcc__c: this.repayAccData ? this.repayAccData.Id : ''
        }
        let newArray = [];
        if (obje) {
            newArray.push(obje);
        }
        if (newArray) {
            upsertMultipleRecord({ params: newArray })
                .then((result) => {
                    console.log('Result after creating Split Disbursement is ', JSON.stringify(result));
                    // this.createIntegrationMessageForPennyDrop(result[0].Id);
                    let fields = {};
                    // fields.sobjectType = 'IntgMsg__c';
                    fields.Name = 'Pennydrop';
                    fields.Status__c = 'New';
                    fields.Svc__c = 'Pennydrop';
                    fields.BU__c = 'HL / STL';
                    fields.IsActive__c = true;
                    fields.RefObj__c = 'Split_Disbur__c';
                    fields.RefId__c = result[0].Id ? result[0].Id : '';
                    fields.Trigger_Platform_Event__c = true
                    this.createIntMsg(fields, 'Penny Drop');
                })
                .catch((error) => {
                    console.log('Error In creating Record', error);
                    this.showToast('Errpr', this.customLabel.Trachy_AccVerf_ErrorMessage, 'error', 'sticky');
                });
        }
    }

    createIntMsg(fieldsInt, name) {
        const recordInput = {
            apiName: 'IntgMsg__c',
            fields: fieldsInt
        };
        console.log('integration msg ', recordInput);
        createRecord(recordInput).then((result) => {
            console.log('Penny drop Integration Record Created ##405', result.id, result);
            if (name === 'Penny Drop') {
                this.pennyDropIntMsgId = result.id;
                this.callSubscribePlatformEve();
            }
        }).catch((error) => {
            console.log('Error ##789', error);
            this.showToastMessage('Errpr', this.customLabel.Trachy_Int_ErrorMessage, 'error', 'sticky');
            // this.showToastMessage('Error creating Integration record', error.body.message, 'error', 'dismissable')
        });
    }

    callSubscribePlatformEve() {
        //Commnet platform event subscription temproroly
        this.handleSubscribe();
    }
    handleSubscribe() {
        const self = this;
        this.cometdlib = new window.org.cometd.CometD();
        console.log('cometdlib  value ', JSON.stringify(this.cometdlib));

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
            // console.log('noIntResponec ', self.noIntResponec);
            self.noIntResponec = true;
            // self.startTimerForTimeout(tot);
            if (status.successful) {
                console.log('Successfully connected to server');
                self.PEsubscription = self.cometdlib.subscribe(self.channelName, (message) => {
                    console.log('subscribed to message!', JSON.stringify(message));
                    console.log(message.data.payload);
                    self.handlePlatformEventResponce(message.data.payload);

                }
                    ,
                    (error) => {
                        console.log('Error In Subscribing ', error);
                    }
                );
                console.log(window.location.protocol + '//' + window.location.hostname + '/cometd/50.0/',);
            } else {
                console.error('Error in handshaking: ' + JSON.stringify(status));
            }
        });
        console.log('SUBSCRIPTION ENDED');
    }

    handlePlatformEventResponce(payload) {
        console.log('responce From PlatformEvent ', payload);
        if (payload) {
            if (payload.SvcName__c === 'Pennydrop') {
                if (payload.RecId__c === this.pennyDropIntMsgId && payload.Success__c) {
                    this.disableIntiatePennyDrop = true;
                    this.getNachData();
                    this.showToastMessage('Success', this.customLabel.Technical_PannyDrop_SuccessMessage, 'success', 'sticky');
                } else {
                    this.showToastMessage('Error', this.customLabel.Trachy_Pennydrop_ErrorMessage, 'error', 'sticky');
                }
            }
        }
    }

    @track addNewSplit
    @track numberOfRec = 0;

    addSplitDisbur(event) {
        this.addNewSplit = event.target.label
        console.log('length of add split row', this.addNewSplit.length);
        this.splitDisburDetails = true

        //change 14 nov
        this.isDisbSplit = true
        let newIndex = this.wrapSplitDisbObj.length + 1;
        // this.numberOfRec = this.wrapSplitDisbObj.length + 1;
        console.log("numberOfRec", this.numberOfRec);
        let myNewElement = {
            Disbur_To__c: "Customer",
            Payment_to__c: "",
            index: newIndex,
            // Id: this.numberOfRec,
            Split_Cheque_Amt__c: "",
            Date_of_Disbur__c: "",
            Custo_Name__c: this.wrapSplitDisbObj.Custo_Name__c,
            Pay_Mode__c: "",
            Penny_Drop_Nm_Sta__c: "",
            Fund_Transf_Mode__c: "",
            IFSC_Detail__c: "",
            Cheq_DD_Date__c: "",
            Cheq_DD_No__c: "000000",
            Fedbank_Acc_Nm__c: "",
            CashBankAccountId__c: "",
            Effec_Date__c: "",
            Payable_At__c: "MUMBAI",
            Fedbank_Acc_No__c: "",
            Cheq_Favor_Dets__c: "",
            Remarks__c: "",
            Cheq_Favor_Acc_No__c: "",
            Benef_Nm_of_Penny_Drop__c: ""
        };
        console.log("myNewElement++++++ = ", myNewElement);
        let spliDis = [...this.wrapSplitDisbObj, myNewElement];
        console.log('new index', newIndex);
        this.wrapSplitDisbObj = spliDis;

        if (this.disbRowId) {
            this.splitDisburParams.queryCriteria = ' where DisburseRela__c = \'' + this.disbRowId + '\''
            getSobjectData({ params: this.splitDisburParams })
                .then((result) => {
                    console.log('splitDisbur in split amt', result);
                    if (result.parentRecords) {
                        this.totalOfSpliChqAmt = 0
                        result.parentRecords.forEach((element) => {
                            this.splitChAmt.push({
                                value: element.Split_Cheque_Amt__c
                            });
                        });
                        this.totalOfSpliChqAmt = this.splitChAmt.reduce((total, record) => {
                            return total + record.value;
                        }, 0);
                    }
                }
                )
        }
    }

    @track totPfAmt
    @track pendDisAmt
    @track totalDisForDisb
    @track loanAmtIncChar
    @track lanOwnerId
    @wire(getSobjectDatawithRelatedRecords, { params: '$loanApplparams' })
    handleLoanApplResponse(result) {
        const { data, error } = result;
        this._wiredLoanApplData = result;

        console.log('data from loan Appl', data);
        if (data) {
            if (result.data) {
                console.log('parent record from loan Appl ', JSON.stringify(result.data.parentRecord));
                let loanRd = result.data.parentRecord
                this.loanApplicationData = result.data.parentRecord;
                console.log('loanRd', loanRd, 'loanRd.DisbursalType__c', loanRd.DisbursalType__c);
                // this.wrapDisburObj.Total_Disb_Amt__c = loanRd.PendingDisbursalAmount__c
                // console.log('this.wrapDisburObj.Total_Disb_Amt__c', this.wrapDisburObj.Total_Disb_Amt__c);
                //this.loanApplDetails.DisbursalType__c = loanRd.DisbursalType__c;
                // this.loanApplDetails.Product__c = loanRd.Product__c;
                // this.loanApplDetails.SchmCode__c = loanRd.SchmCode__c;
                // this.loanApplDetails.Loan_Tenure_Months__c = loanRd.Loan_Tenure_Months__c;
                // this.loanApplDetails.PendingDisbursalAmount__c = loanRd.PendingDisbursalAmount__c;
                if(loanRd.DisbursalType__c){

                    this.wrapDisburObj.DisbursalType__c = loanRd.DisbursalType__c;
                    if(this.wrapDisburObj.DisbursalType__c == 'Single' || (this.disbursType && this.disbursType == 'Single')){
                        this.disblCrateTranButton = true;
                        this.showPrincipleFields = false;
                    }else if(this.wrapDisburObj.DisbursalType__c == 'Multiple'){
                        this.disblCrateTranButton = false;
                        this.showPrincipleFields = true;
                    }
                   
                }
                if(loanRd.FirstEMIDate__c){
                    this.priciplStartDate = loanRd.FirstEMIDate__c;
                }
                console.log('this.priciplStartDate---------->',this.priciplStartDate);
                this.disburTy = loanRd.DisbursalType__c
                this.wrapDisburObj.Product__c = loanRd.Product__c
                this.wrapDisburObj.Scheme__c = loanRd.SchmCode__c
                this.wrapDisburObj.Loan_Tenu__c = loanRd.Loan_Tenure_Months__c
                // this.totalDisAmtFrLoan = loanRd.TotalLoanAmtInclInsurance__c
                // this.totPfAmt = loanRd.Total_PF_Amount__c
                this.pendDisAmt = loanRd.PendingDisbursalAmount__c
                this.loanAmtIncChar = loanRd.TotalLoanAmountIncCharges__c
                // this.totalDisForDisb = this.totPfAmt + this.totalDisAmtFrLoan
                this.loanNo = loanRd.Name
                // this.wrapSplitDisbObj.Disbur_To__c = "Customer"
                this.wrapDisburObj.Disbur_To__c = "Customer"
                // this.wrapSplitDisbObj.Cheq_DD_No__c = "000000"
                this.lanOwnerId = loanRd.OwnerId

                if (this.hasEditAccess === false) {
                    if (this.lanOwnerId) {
                        if (this.lanOwnerId == userId) {
                            this.disbDisbMemo = false
                        } else {
                            this.disbDisbMemo = true
                        }
                    }
                }
                console.log('data populate from Loan Appln', this.wrapDisburObj);
                console.log('disbur type ', this.disburTy);
                if (this.disburTy === "Single") {
                   
                    this.isDisbDisbAmt = true
                    this.wrapDisburObj.No_of_Disbur__c = 1
                    this.wrapDisburObj.Total_Disb_Amt__c = this.loanAmtIncChar
                    this.wrapDisburObj.Loan_Tenu__c = loanRd.Loan_Tenure_Months__c
                    console.log('total dis amt ===', this.wrapDisburObj.Total_Disb_Amt__c);
                    this.wrapDisburObj.Disbur_No__c = "1"
                    this.wrapDisburObj.Disbur_Desrp__c = "Tranche 1"
                    if (this.dataOfDisbur !== undefined) {
                        if (this.dataOfDisbur.length >= 1) {
                            this.mode = true;
                        }
                        console.log('length og disbu record', this.dataOfDisbur.length);
                    }
                } else {
                    this.wrapDisburObj.Total_Disb_Amt__c = this.loanAmtIncChar
                    this.wrapDisburObj.No_of_Disbur__c = 1
                    console.log('data of dissbursal ===', this.dataOfDisbur);
                    if (this.dataOfDisbur === undefined) {
                        this.wrapDisburObj.Disbur_No__c = "1"
                        this.wrapDisburObj.Disbur_Desrp__c = "Tranche 1"
                    }
                    this.mode = false;
                    //this.isDisbDisbAmt = false
                    this.princReldFields = true
                    this.isPendTotalDisbAmt = true
                    this.wrapDisburObj.Pend_Disbur_Amt__c = loanRd.PendingDisbursalAmount__c
                    this.pendDisbAmt = loanRd.PendingDisbursalAmount__c
                    console.log('dgsfht trht', this.pendDisbAmt);
                    console.log('pending disb amount', this.wrapDisburObj.Pend_Disbur_Amt__c);

                }

                console.log('child records ===', result.data.ChildReords);
                console.log('data childrecords', data.ChildReords);
                if (result.data.ChildReords) {
                    result.data.ChildReords.forEach(data1 => {
                        if (data1.Constitution__c === 'INDIVIDUAL' && data1.ApplType__c === 'P') {
                            console.log('applicant type ', data1.ApplType__c);
                            if (data1.FName__c === null) {
                                this.wrapDisburObj.Appl_Name__c = data1.LName__c; 
                                this.wrapSplitDisbObj.Custo_Name__c = data1.LName__c;
                                // this.dataId = data1.Id;
                            } else if (data1.FName__c !== null) {
                                this.wrapDisburObj.Appl_Name__c = `${data1.FName__c} ${data1.LName__c}`;
                                this.wrapSplitDisbObj.Custo_Name__c = `${data1.FName__c} ${data1.LName__c}`;
                                // this.dataId = data1.Id;
                            }
                            console.log('Customer name in if', this.wrapSplitDisbObj.Custo_Name__c);

                        } else if (data1.Constitution__c !== 'INDIVIDUAL' && data1.ApplType__c === 'P') {
                            this.wrapDisburObj.Appl_Name__c = data1.CompanyName__c;
                            this.wrapSplitDisbObj.Custo_Name__c = data1.CompanyName__c;
                            console.log('company name', data1.CompanyName__c);

                            console.log('Customer name in else', this.wrapSplitDisbObj.Custo_Name__c);
                            // this.dataId = data1.Id;
                        }

                    });
                }
            } else if (error) {
                console.log('Error from loanApplparams', error);
            }
        }
    }

    @track countOfDisbNo
    @track maxClickCount
    @track disbsId

    @wire(getSobjectData, { params: '$disburParams' })
    handleDisbursementResponse(result) {
        const { data, error } = result;
        this._wiredDisburData = result
        console.log('handleDisbursementResponse--------->',JSON.stringify(result));
        //console.log('data from disbursement', data);
        if (data) {
            if (result.data) {
                if(data.parentRecords && data.parentRecords.length > 0){
               // console.log('parent record from disbursement ', result.data.parentRecords);
                this.disbursmentData = [];
                this.dataOfDisbur = result.data.parentRecords;
                this.disbsId = this.dataOfDisbur[0].Id

                // if (this.disburTy === "Single") {
                //     this.wrapDisburObj.Total_Disb_Amt__c = this.dataOfDisbur[0].Total_Disb_Amt__c
                //     console.log('754', this.wrapDisburObj.Total_Disb_Amt__c);
                //     this.wrapDisburObj.Total_Disb_Amt__c = ""
                // }
                if (this.dataOfDisbur) {
                    for (let i = 0; i < this.dataOfDisbur.length; i++) {
                        this.disbursmentData.push(this.dataOfDisbur[i]);
                    }
                }
                // if (this.dataOfDisbur && this.disburTy === "Single") {
                //     console.log('disbursa ty', this.disburTy);
                //     for (let i = 0; i < this.dataOfDisbur.length; i++) {
                //         // this.dataOfDisbur[i].Total_Disb_Amt__c = "";
                //         this.disbursmentData.push(this.dataOfDisbur[i]);
                //     }
                // }

                if (this.dataOfDisbur !== undefined) {
                    console.log('count of disb no', this.dataOfDisbur.length);
                    this.countOfDisbNo = this.dataOfDisbur.length
                    this.maxClickCount = this.countOfDisbNo + 1
                }

                let tempParams = this.loanApplparams;
                tempParams.queryCriteria = ' where Id = \'' + this._loanAppId + '\''
                this.loanApplparams = { ...tempParams };
                if (this.disbsId) {
                    console.log('disbs Id ', this.disbsId);
                    this.splitParams.queryCriteria = ' where DisburseRela__c = \'' + this.disbsId + '\''
                    getSobjectData({ params: this.splitParams })
                        .then((result) => {
                            console.log('splitDisbur in split amt', result);
                            if (result.parentRecords) {
                                if (result.parentRecords) {
                                    console.log('parent record from splitDisburParams ', result.parentRecords);
                                    if (this.hasEditAccess !== undefined) {
                                        if (this.hasEditAccess === true || this.hasEditAccess === false) {
                                            if (this.lanOwnerId) {
                                                if (this.lanOwnerId == userId) {
                                                    this.disbDisbMemo = false
                                                } else {
                                                    this.disbDisbMemo = true
                                                }
                                            }

                                        }
                                    }
                                }
                            }
                        }
                        )
                        .catch(error => {
                            console.log('error print', error);
                            console.error(error)
                        })
                }
                this.dataOfSplitDisb = []
                if (this.disbRowId) {
                    console.log('disb row id', this.disbRowId);
                    this.splitDisburParams.queryCriteria = ' where DisburseRela__c = \'' + this.disbRowId + '\''
                }

            } }else if (error) {
                console.log('Error from disburParams', error);
            }
        }else
        if(error){
            console.log('Error getting data', error);
        }
    }


    @wire(getSobjectData, { params: '$splitDisburParams' })
    handleSplitDisbursementResponse(result) {
        const { data, error } = result;
        this._wiredSplitDisbData = result;
        console.log('data from splitDisburParams', result);
        if (data) {
            if (result.data) {
                console.log('parent record from disbursement ', result.data.parentRecords);

                if (result.data.parentRecords) {
                    if (result.data.parentRecords) {
                        console.log('parent record from split Disbur Params ', result.data.parentRecords);
                        this.dataOfSplitDisb = result.data.parentRecords;
                        if (this.hasEditAccess !== undefined) {
                            if (this.hasEditAccess === true || this.hasEditAccess === false) {
                                if (this.lanOwnerId) {
                                    if (this.lanOwnerId == userId) {
                                        console.log('if DM', this.disbDisbMemo);
                                        this.disbDisbMemo = false
                                    } else {
                                        console.log('else DM', this.disbDisbMemo);
                                        this.disbDisbMemo = true
                                    }
                                }

                            }
                        }
                    }
                    // this.isDisbSplit = true
                    // this.splitDisData = result.parentRecords;

                    // this.splitDisburDetails = true
                }
            }
        } else {
            // this.splitDisburDetails = false
        }

    }

  

    renderedCallback() {
       
       // refreshApex(this._wiredSplitDisbData);
      // refreshApex(this._wiredDisburseDetails);
       
    }

    connectedCallback() {
        console.log('Connected Callback');
        console.log('loan app d ', this.loanAppId);
        console.log('this.hasEditAccess', this.hasEditAccess);
        const defaultCustomerValue = this.disburToOption.length > 0 ? this.disburToOption[0].value : null;
        console.log('default vaue ', defaultCustomerValue);
        this.wrapSplitDisbObj = this.wrapSplitDisbObj.map(obj => ({
            ...obj,
            Disbur_To__c: this.disburToOption.length > 0 ? this.disburToOption[0].value : null
        }));
        console.log('customer vlaue', this.wrapSplitDisbObj);
        if (this.hasEditAccess === false) {
            this.disableMode = true
            this.isDisbFavor = true
            this.mode = true
            this.modeForSplit = true
            this.isDisbDisbAmt = true
        }
        else {
            this.disableMode = false;
            // this.disbDisbMemo = false

        }

        this.scribeToMessageChannel();
    }

    reportValidity() {
        let isValid = true
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed combobox');
                console.log('element if--' + element.value);
            } else {
                isValid = false;
                console.log('element else--' + element.value);
            }
        });

        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed lightning input');
            } else {
                isValid = false;
            }
        });
        return isValid;
    }

    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }


    handleSaveThroughLms(values) {
        console.log('values', values);
        this.handleSave(values.validateBeforeSave);
    }

    handleSave(validate) {
        if (validate) {
            console.log('validate', validate);
            let isInputCorrect = this.reportValidity();

            if (isInputCorrect === true && this.showError === false) {
                console.log('wrap splitDisData', this.wrapSplitDisbObj);
                this.handleUpsertForDisb();
                //this.handleUpsert();
               

            } else {
                this.showToastMessage('Error', this.customLabel.Trachy_ReqFields_ErrorMessage, 'error', 'sticky');
            }
        }
        else {
            this.handleUpsertForDisb();
            //this.handleUpsert();
            //this.handleUpsertForSplitDis();
            //this.showToastMessage('Success', this.customLabel.Trachy_Save_SuccessMessage, 'success', 'sticky')
        }

    }

    handleUpsert() {
        console.log('disbursement');
        if (this.isLoading == false) {
            this.isLoading = true;
            let dateObj = new Date();
            let month = String(dateObj.getMonth() + 1)
                .padStart(2, '0');
            let day = String(dateObj.getDate())
                .padStart(2, '0');
            let year = dateObj.getFullYear();
            this.currDate = year + '-' + month + '-' + day;

            // if (this.pricStartDate < this.currDate) {
            //     this.showToastMessage('Error', this.customLabel.Trachy_Date_ErrorMessage, 'error', 'sticky');
            //     this.wrapDisburObj.Princ_Start_Date__c = "";
            // } else {
            //     this.wrapDisburObj.Princ_Start_Date__c = event.target.value;
            // }
            console.log('length of disburs. records', this.wrapDisburObj);
            console.log('null check', this.wrapDisburObj.Id);
            //in case of Multiple disb type
            // if (this.wrapDisburObj.Id === undefined && this.countOfDisbNo === undefined) {

            if (this._loanAppId) {
                this.wrapDisburObj.ApplicationID__c = this.loanNo
                console.log('this.loanNo', this.loanNo);
                this.wrapDisburObj.Loan_Appli__c = this._loanAppId;
                var fields = this.wrapDisburObj
                console.log('field print ', fields);
                if (this.disburTy === "Multiple" && (fields.Princ_Start_Date__c < this.currDate)) {
                    this.showToastMessage('Error', this.customLabel.Trachy_Date_ErrorMessage, 'error', 'sticky');
                } else {
                    const recordInput = {
                        apiName: DISBUR_OBJ.objectApiName,
                        fields: fields
                    };
                    console.log('record input', recordInput);
                    createRecord(recordInput)
                        .then(result => {
                            console.log('result print after saving disbursement records ', result);
                            this.showToastMessage('Success!!', this.customLabel.Trachy_RecordCreate_SuccessMessage, 'success', 'sticky');
                            this.newDisburId = result.id
                            refreshApex(this._wiredLoanApplData);
                            refreshApex(this._wiredDisburData);
                            // setTimeout(() => {
                            //     this.isLoading = false;
                            // }, 2000);

                            if (this.wrapSplitDisbObj.length !== 0) {
                                this.handleUpsertForSplitDis();
                            }
                            this.disburDetails = false;
                            this.isLoading = false;

                        })
                        .catch(error => {
                            console.log(error);
                            // this.showToastMessage('Error!!', error.body.message, 'error', 'sticky');
                            // setTimeout(() => {
                            //     this.isLoading = false;
                            // }, 2000);
                            this.isLoading = false;

                        });
                }
            }

            if (this.wrapDisburObj.Id !== null || this.wrapDisburObj.Id !== undefined && this.disbRowId !== undefined && this.wrapDisburObj.length !== 0) {

                this.wrapDisburObj.Id = this.disbRowId
                delete this.wrapDisburObj.Name
                delete this.wrapDisburObj.Loan_Appli__c
                var fields = this.wrapDisburObj;
                if (this.disburTy === "Multiple" && (fields.Princ_Start_Date__c < this.currDate)) {
                    this.showToastMessage('Error', this.customLabel.Trachy_Date_ErrorMessage, 'error', 'sticky');
                } else if (this.disbRowId && this.disburTy === "Multiple" && (this.compPendDisbAmt < fields.Total_Disb_Amt__c)) {
                    console.log('1004', this.compPendDisbAmt);
                    this.showError = true;
                    this.dynamicErrorMessage = 'Total Disbursal Amount should not be more than Pending Disbursal Amount.';
                    this.setValidity(true);
                } else if (this.disbRowId === undefined && this.disburTy === "Multiple" && (this.pendDisbAmt < this.wrapDisburObj.Total_Disb_Amt__c)) {
                    console.log('1016', this.pendDisbAmt);
                    this.showError = true;
                    this.dynamicErrorMessage = 'Total Disbursal Amount should not be more than Pending Disbursal Amount.';
                    this.setValidity(true);
                } else {
                    const recordInputToUpd = { fields };
                    console.log('recordInputToUpd for disbursement obj', recordInputToUpd);
                    updateRecord(recordInputToUpd)
                        .then(result => {
                            this.newDisburId = result.id
                            if (this.splitDisRowId === undefined) {
                                this.showToastMessage('Success!!', this.customLabel.Trachy_Upsert_SuccessMessage, 'success', 'sticky');
                                console.log('update disbur toast msg');
                            }
                            if (this.wrapSplitDisbObj.length !== 0) {
                                this.handleUpsertForSplitDis();
                            }
                            refreshApex(this._wiredLoanApplData);
                            refreshApex(this._wiredDisburData);
                            // setTimeout(() => {
                            //     this.isLoading = false;
                            // }, 2000);
                            this.disburDetails = false;
                            this.isLoading = false;

                        })
                        .catch(error => {
                            console.log(error);
                            this.showToastMessage('Error!!', error.body.message, 'error', 'sticky');
                            // setTimeout(() => {
                            //     this.isLoading = false;
                            // }, 2000);
                            this.isLoading = false;
                        });
                }
            }
        }
    }


    @track splitDisRec = [];
    @track disbReln

    handleUpsertForSplitDis() {

        console.log('create record split ==');
        if (this.isLoading == false) {
            this.isLoading = true;
            if (this.wrapSplitDisbObj.Id === null || this.wrapSplitDisbObj.Id === undefined) {
                console.log('onchnage value of cheq amout', this.onchToTOfSplChqAmt, 'total disb amt', this.wrapSplitDisbObj.Total_Disb_Amt__c);
                if (this.onchToTOfSplChqAmt > this.wrapDisburObj.Total_Disb_Amt__c) {
                    this.showToastMessage('Error', this.customLabel.Trachy_SplChqAmt_ErrorMessage, 'error', 'sticky');
                } else if (this.oldTotalDisbAmt < this.onchToTOfSplChqAmt) {
                    this.showToastMessage('Error', this.customLabel.Trachy_SplChqAmt_ErrorMessage, 'error', 'sticky');
                } else {
                    this.splitDisRec = [];
                    for (var i = 0; i < this.wrapSplitDisbObj.length; i++) {
                        let childRecord = {};
                        var splitDis = this.wrapSplitDisbObj[i];

                        childRecord.Disbur_To__c = splitDis.Disbur_To__c;
                        childRecord.Payment_to__c = splitDis.Payment_to__c;
                        childRecord.Split_Cheque_Amt__c = splitDis.Split_Cheque_Amt__c;
                        childRecord.Date_of_Disbur__c = splitDis.Date_of_Disbur__c
                        childRecord.Custo_Name__c = splitDis.Custo_Name__c;
                        childRecord.Pay_Mode__c = splitDis.Pay_Mode__c;
                        childRecord.Penny_Drop_Nm_Sta__c = splitDis.Penny_Drop_Nm_Sta__c;
                        childRecord.Fund_Transf_Mode__c = splitDis.Fund_Transf_Mode__c;
                        childRecord.IFSC_Detail__c = splitDis.IFSC_Detail__c;
                        childRecord.Cheq_DD_Date__c = splitDis.Cheq_DD_Date__c;
                        childRecord.Cheq_DD_No__c = splitDis.Cheq_DD_No__c;
                        childRecord.Fedbank_Acc_Nm__c = splitDis.Fedbank_Acc_Nm__c;
                        childRecord.CashBankAccountId__c = splitDis.CashBankAccountId__c;
                        childRecord.Pay_City_Id__c = splitDis.Pay_City_Id__c;
                        childRecord.Effec_Date__c = splitDis.Effec_Date__c;
                        childRecord.Payable_At__c = splitDis.Payable_At__c;

                        childRecord.Fedbank_Acc_No__c = splitDis.Fedbank_Acc_No__c;
                        childRecord.Cheq_Favor_Dets__c = splitDis.Cheq_Favor_Dets__c;
                        childRecord.Remarks__c = splitDis.Remarks__c;
                        childRecord.Cheq_Favor_Acc_No__c = splitDis.Cheq_Favor_Acc_No__c;
                        childRecord.Benef_Nm_of_Penny_Drop__c = splitDis.Benef_Nm_of_Penny_Drop__c;

                        childRecord.sobjectType = 'Split_Disbur__c';
                        if (this.disbRowId === undefined && this.addNewSplit !== undefined) {
                            childRecord.DisburseRela__c = this.newDisburId
                        } else {
                            childRecord.DisburseRela__c = this.disbRowId;
                        }
                        if (splitDis.Id) {
                            childRecord.Id = splitDis.Id;
                        }
                        delete splitDis.delete;
                        console.log('child records split disbu. ', childRecord);

                        this.splitDisRec.push(childRecord);
                        console.log('splitDisRec record', this.splitDisRec);

                    }
                    // upsertSObjectRecord({ params: this.splitDisRec })
                    //     .then(result => {
                    //         console.log('result ====', result);
                    //         this.disbReln = result[0].DisburseRela__c;
                    //         console.log('disb relation id', this.disbReln);

                    //         if (this.disbReln) {
                    //             return new Promise(resolve => setTimeout(resolve, 2000)); 
                    //         }
                    //     })
                    //     .then(() => {
                    //         this.splitDisburParams.queryCriteria = ' where DisburseRela__c = \'' + this.disbReln + '\'';
                    //         console.log('data refresh of split', this.splitDisburParams.queryCriteria);
                    //         this.splitDisburParams = { ...this.splitDisburParams };
                    //         return refreshApex(this._wiredSplitDisbData);
                    //     })
                    //     .then(() => {
                    //         this.dispatchEvent(
                    //             new ShowToastEvent({
                    //                 title: 'Success',
                    //                 message: 'Record updated successfully!',
                    //                 variant: 'success',
                    //             })
                    //         );
                    //     })
                    //     .catch(error => {
                    //         console.error('Error during upsert:', error);
                    //         this.dispatchEvent(
                    //             new ShowToastEvent({
                    //                 title: 'Error',
                    //                 message: 'An error occurred: ' + error.body.message,
                    //                 variant: 'error',
                    //             })
                    //         );
                    //     });


                    upsertSObjectRecord({ params: this.splitDisRec })
                        .then(result => {
                            console.log('result ====', result);
                            let disbReln = result[0].DisburseRela__c
                            console.log('disb relation id', disbReln);
                            // this.splitDisData = []
                            if (disbReln) {
                                this.splitDisburParams.queryCriteria = ' where DisburseRela__c = \'' + disbReln + '\''
                                console.log('data refresh of split', this.splitDisburParams.queryCriteria);
                                this.splitDisburParams = { ...this.splitDisburParams };
                            }
                            refreshApex(this._wiredSplitDisbData);
                            this.showToastMessage('Success!!', this.customLabel.Trachy_Update_SuccessMessage, 'success', 'sticky');
                            this.isDisbSplit = false
                            // refreshApex(this._wiredDisburData);
                            // refreshApex(this._wiredSplitDisbData);
                            // setTimeout(() => {
                            //     this.isLoading = false;
                            // }, 2000);
                            this.isLoading = false;
                            this.isDisbSplit = true
                        })

                        // getSobjectData({ params: this.splitDisburParams })
                        //     .then((result) => {
                        //         console.log('splitDisbur in split amt', result);
                        //         if (result.parentRecords) {
                        //             if (result.parentRecords) {
                        //                 console.log('parent record from splitDisburParams ', result.parentRecords);
                        //                 this.isDisbSplit = true
                        //                 this.dataOfSplitDisb = result.parentRecords;
                        //             }
                        //         }
                        //     }
                        //     )
                        .catch(error => {
                            console.log('error print deviation', error);
                            console.error(error)
                            // setTimeout(() => {
                            //     this.isLoading = false;
                            // }, 2000);
                            this.isLoading = false;

                        })

                }


            }

            /* date 09 Dec
            if (this.wrapSplitDisbObj.Id !== null || this.wrapSplitDisbObj.Id !== undefined && this.splitDisRowId !== undefined) {
                console.log('wrapSplit Id check for update', this.wrapSplitDisbObj.Id, this.splitDisRowId);
                this.wrapSplitDisbObj.Id = this.splitDisRowId
                const fields = this.wrapSplitDisbObj;
                // fields[SP_DISBUR_ID.fieldApiName] = this.wrapSplitDisbObj.Id;
                const recordInputToUpd = { fields };
                delete this.wrapSplitDisbObj.Name
                delete this.wrapSplitDisbObj.DisburseRela__c
         
                updateRecord(recordInputToUpd)
                    .then(() => {
                        refreshApex(this._wiredSplitDisbData);
                        setTimeout(() => {
                            this.isLoading = false;
                        }, 2000);
                        this.showToastMessage('Success!!', this.customLabel.Trachy_Update_SuccessMessage, 'success', 'sticky');
                        // Display fresh data in the form
                    })
                    .catch(error => {
                        this.showToastMessage('Error!!', error.body.message, 'error', 'sticky');
                        setTimeout(() => {
                            this.isLoading = false;
                        }, 2000);
                    });
            }
        */
        }
    }

    handleSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        // fields.LastName = 'My Custom Last Name'; // modify a field
        this.template.querySelector('lightning-record-form').submit(fields);
    }
    handleSubmitForSplitDisb(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-form').submit(fields);
    }

    @track myNewElement
    @track oldTotalDisbAmt
    @track compPendDisbAmt

    callRowAction(event) {
        try {
            console.log('event detail row', event.detail.row);
            this.onRowDusburData = event.detail.row
            // console.log('discursal ID ', this.disbursId.Id);
            // this.disbRowId = ''
            const rowId = event.detail.row.Id;
            this.disbRowId = event.detail.row.Id;

            console.log('rowId', rowId);
            // this.contDocId = event.detail.row;
            this.disburDetails = true;
            // this.isDisbSplit = true
            console.log('data of dibursement', this.disbursmentData);
            // if (this.mode === true && this.disburTy === "Single") {
            //     console.log('total disbursal amt print ==', this.totalDisForDisb);
            //     this.wrapDisburObj.Total_Disb_Amt__c = ""
            //     this.wrapDisburObj.Total_Disb_Amt__c = this.totalDisForDisb
            //     console.log('total amt when single', this.wrapDisburObj.Total_Disb_Amt__c);
            // }
            this.compPendDisbAmt = this.disbursmentData[0].Pend_Disbur_Amt__c

            if (this.disbursmentData.length === 1) {
                this.oldTotalDisbAmt = this.disbursmentData[0].Total_Disb_Amt__c
            }
            console.log('total dis amt change', this.onRowDusburData);
            /*
            if (this.disburTy === "Single" && this.pendDisAmt !== undefined) {
                const rowIndex = this.disbursmentData.findIndex(row => row.Id === rowId);
        
                if (rowIndex !== -1) {
                    // Update Total_Disb_Amt__c for the found row
                    this.disbursmentData[rowIndex].Total_Disb_Amt__c = this.pendDisAmt;
                }
                // this.onRowDusburData.Total_Disb_Amt__c = this.pendDisAmt
                console.log('total dis amt pending ==', this.onRowDusburData.Total_Disb_Amt__c);
            }
            */

            if (this.onRowDusburData != undefined) {
                this.wrapDisburObj = { ...this.onRowDusburData }
                if (this.onRowDusburData.Disbur_No__c) {
                    this.wrapDisburObj.Disbur_No__c = this.onRowDusburData.Disbur_No__c.toString()
                    console.log('call row action', this.wrapDisburObj);
                }
                if (this.disburTy === "Single" && this.loanAmtIncChar !== undefined) {
                    console.log('pending disbt', this.loanAmtIncChar);
                    this.wrapDisburObj.Total_Disb_Amt__c = this.loanAmtIncChar
                }
            }

            if (this.disbRowId) {
                console.log('row Id', this.disbRowId);
                // let tempPar = this.splitDisburParams;
                this.splitDisburParams.queryCriteria = ' where DisburseRela__c = \'' + this.disbRowId + '\''
                // tempPar.splitDisburParams = ' where DisburseRela__c = \'' + this.disbRowId + '\''
                // this.splitDisburParams = { ...tempPar }

                console.log('this.splitDisburParams query crit', this.splitDisburParams);
                getSobjectData({ params: this.splitDisburParams })
                    .then((result) => {
                        const { data, error } = result;
                        // this._wiredSplitDisbData = result;
                        // refreshApex(this._wiredSplitDisbData)
                        // this._wiredSplitDisbData = data
                        console.log('data from splitDisburParams', result);
                        this.isDisbSplit = true

                        if (result.parentRecords) {
                            if (result.parentRecords) {
                                console.log('parent record from splitDisburParams ', result.parentRecords);
                                this.isDisbSplit = true
                                this.dataOfSplitDisb = result.parentRecords;
                                // this.splitDisData = result.parentRecords;
                                console.log('old split chq amt', result.parentRecords[0].Split_Cheque_Amt__c);
                                this.oldSplChqAmt = result.parentRecords[0].Split_Cheque_Amt__c
                                if (result.parentRecords !== undefined) {
                                    result.parentRecords.forEach(spl => {
                                        this.myNewElement = {
                                            Id: spl.Id,
                                            DisburseRela__c: spl.DisburseRela__c || '',
                                            Disbur_To__c: spl.Disbur_To__c || '',
                                            Split_Cheque_Amt__c: spl.Split_Cheque_Amt__c || '',
                                            Date_of_Disbur__c: spl.Date_of_Disbur__c || '',
                                            Custo_Name__c: spl.Custo_Name__c || '',
                                            Pay_Mode__c: spl.Pay_Mode__c || '',
                                            Penny_Drop_Nm_Sta__c: spl.Penny_Drop_Nm_Sta__c || '',
                                            Fund_Transf_Mode__c: spl.Fund_Transf_Mode__c || '',
                                            IFSC_Detail__c: spl.IFSC_Detail__c || '',
                                            Cheq_DD_Date__c: spl.Cheq_DD_Date__c || '',
                                            Cheq_DD_No__c: spl.Cheq_DD_No__c || '',
                                            Fedbank_Acc_Nm__c: spl.Fedbank_Acc_Nm__c || '',
                                            CashBankAccountId__c: spl.CashBankAccountId__c || '',
                                            Pay_City_Id__c: spl.Pay_City_Id__c || '',
                                            Effec_Date__c: spl.Effec_Date__c || '',
                                            Payable_At__c: spl.Payable_At__c || '',
                                            Fedbank_Acc_No__c: spl.Fedbank_Acc_No__c || '',
                                            Cheq_Favor_Dets__c: spl.Cheq_Favor_Dets__c || '',
                                            Remarks__c: spl.Remarks__c || '',
                                            Cheq_Favor_Acc_No__c: spl.Cheq_Favor_Acc_No__c || '',
                                            Benef_Nm_of_Penny_Drop__c: spl.Benef_Nm_of_Penny_Drop__c || '',
                                            Payment_to__c: spl.Payment_to__c || '',
                                            isDisbFavor: false,
                                            disableMode: false,
                                            delete: false
                                        };
                                        this.splitDisData.push(this.myNewElement)
                                        console.log('my elements this.splitDisData', this.splitDisData);

                                    });
                                }
                                // this.splitDisburDetails = true
                            }
                        } else {
                            this.splitDisburDetails = false
                        }
                    }
                    )
            }


        } catch (e) {
            console.error(e);
            console.error('e.message => ' + e.message);
        }
    }

    @track pricStartDate
    @track splitDisbRowData
    @track index
    @track splitDisbRecord = []
    @track clickCount = 0
    callRowActionForSplit(event) {
        // this.splitDisId = '';
        // this.index = event.target.index

        this.clickCount++
        this.wrapSplitDisbObj = []
        console.log('dataOfSplitDisb from row action', this.splitDisData);
        this.isDisbSplit = true
        this.splitDisbRowData = event.detail.row
        // this.clickCount.push(event.detail.row);

        this.splitDisRowId = event.detail.row.Id;

        // const rowIndex = this.clickCount.findIndex(record => record.Id === this.splitDisRowId);
        // console.log('rowIndex', rowIndex);

        // Store the row number or index
        // let countOfRow = 0
        // countOfRow = rowIndex + 1;
        // countOfRow++
        console.log('clickCount', this.clickCount);

        let splDisRecord = [];

        console.log(' this.splitDisRowId', this.splitDisRowId);
        this.splitDisburDetails = true
        console.log('split disbur. query ', this.splitDisData);
        // this.splitDisData.push(this.isDisbFavor);
        // console.log('added disable varia split disbur. query ', this.splitDisData);

        for (let i = 0; i < this.splitDisData.length; i++) {
            const element = this.splitDisData[i];


            if (this.splitDisRowId === element.Id) {
                console.log('id match', element);
                // let splitRd = element;
                // this.splitDisData.push(splitRd);

                // Adding the condition for approvedby disable property
                if (this.splitDisData[i].Payment_to__c !== undefined &&
                    this.splitDisData[i].Payment_to__c === 'Repayment Account') {
                    console.log('has edit access', this.hasEditAccess);
                    element.isDisbFavor = this.hasEditAccess === false ? true : false;
                }
                if (this.hasEditAccess !== undefined) {
                    element.disableMode = this.hasEditAccess === false ? true : false;
                    element.delete = this.hasEditAccess === false ? true : false;
                    element.isDisbFavor = this.hasEditAccess === false ? true : false;
                }
                splDisRecord.push(this.splitDisData[i]);

            }
        }

        this.wrapSplitDisbObj = [...splDisRecord];
        console.log('wrop obje of split ', this.wrapSplitDisbObj);
        /*
        if (this.splitDisData !== undefined) {
            
            this.splitDisData.forEach(element => {
                if (this.splitDisRowId === element.Id) {
                    console.log('id match', element);
                    let splitRd = element
                    splDisRecord.push(splitRd)
    
                }
            });
            this.wrapSplitDisbObj = [...splDisRecord]
            
            console.log('this.wrapSplitDisbObj', this.wrapSplitDisbObj);
            console.log('this.splitDisbRowData.Payment_to__c', this.splitDisbRowData.Payment_to__c);
            if (this.splitDisbRowData.Payment_to__c === 'Repayment Account') {
                // this.wrapSplitDisbObj[this.index].isDisbFavor = true;
                this.isDisbFavor = true
                // this.wrapSplitDisbObj = this.isDisbFavor
            }
    
        } 
        */

    }

    get filterCondnChannel() {
        if (this.fedBankTy === "CashBank Account")
            return ("Type__c=" + "'" + this.fedBankTy + "'");
    }

    handleValueSelect(event) {
        this.lookupRec = event.detail;
        console.log('event detaisl of fedbank account name', event.detail);
        console.log('event only', event);
        this.index = event.target.index
        // const index = event.target.dataset.index;

        // if (event.target.label === "Fedbank Account Name") {
        //     let tempArray = [...this.wrapSplitDisbObj];
        //     let tempObj = { ...tempArray[index] };
        //     tempObj.Fedbank_Acc_Nm__c = this.lookupRec.mainField;
        //     tempArray[index] = tempObj;
        //     this.wrapSplitDisbObj = [...tempArray];
        //     // obj.Fed_Acc_Nm_Id__c = this.lookupRec.id;
        //     console.log('fedban acc', this.wrapSplitDisbObj);
        // }
        if (event.target.fieldName === 'Fedbank_Acc_Nm__c') {
            console.log('lookup Rec', this.lookupRec);
            this.wrapSplitDisbObj[this.index].Fedbank_Acc_Nm__c = this.lookupRec.mainField;
            this.wrapSplitDisbObj[this.index].CashBankAccountId__c = this.lookupRec.id;
        } else if (event.target.fieldName === 'Payable_At__c') {
            console.log('payable lookup Rec', this.lookupRec);
            this.wrapSplitDisbObj[this.index].Payable_At__c = this.lookupRec.mainField;
            this.wrapSplitDisbObj[this.index].Pay_City_Id__c = this.lookupRec.id;
        }
    }

    @track totalDibAmtValue
    @track showDisburDetTable =false;
    handleInputChange(event) {
        try {
            if (event.target.dataset.type === 'string') {
                let strVal = event.target.value;
                this.wrapDisburObj[event.target.dataset.name] = strVal.toUpperCase();
            } else {
                this.wrapDisburObj[event.target.dataset.name] = event.target.value;
                console.log('select value ', event.target.value);
            }

        } catch (e) {
            console.log(e);
        }


        let dateObj = new Date();
        let month = String(dateObj.getMonth() + 1)
            .padStart(2, '0');
        let day = String(dateObj.getDate())
            .padStart(2, '0');
        let year = dateObj.getFullYear();
        this.currDate = year + '-' + month + '-' + day;
        console.log('current date', this.currDate);

        if (event.target.dataset.name === 'Total_Disb_Amt__c') {
            this.wrapDisburObj.Total_Disb_Amt__c = event.target.value;
            this.totalDibAmtValue = event.target.value
            console.log('total disb amt in onchange', this.wrapDisburObj.Total_Disb_Amt__c);
            // console.log('disbursement type ', this.disburTy, this.totalDisAmtFrLoan);
            // if (this.disburTy === "Multiple" && (this.totalDisAmtFrLoan < this.wrapDisburObj.Total_Disb_Amt__c)) {
            //     console.log('error msg inside if ');
            //     this.showToastMessage('Error', this.customLabel.Trachy_DisbursalAmt_ErrorMessage, 'error', 'sticky');
            // }
            console.log('compa Pend Disb Amt ==', this.compPendDisbAmt);
            console.log('disb row id', this.disbRowId);
            if (this.disbRowId) {
                console.log('1433', this.disbRowId);
                if (this.disburTy === "Multiple" && (this.compPendDisbAmt < this.wrapDisburObj.Total_Disb_Amt__c)) {
                    console.log('when comapre pend amt', this.compPendDisbAmt);
                    this.showError = true;
                    this.dynamicErrorMessage = 'Total Disbursal Amount should not be more than Pending Disbursal Amount.';
                    this.setValidity(true);

                } else if (this.compPendDisbAmt > this.wrapDisburObj.Total_Disb_Amt__c) {
                    console.log('1441');
                    this.dynamicErrorMessage = '';
                    this.showError = false;
                    this.setValidity(false);
                }
            } else {
                console.log('print disbut id');
                if (this.disburTy === "Multiple" && (this.pendDisbAmt < this.wrapDisburObj.Total_Disb_Amt__c)) {
                    console.log('when comapre total disb and pend amt', this.pendDisbAmt);
                    this.showError = true;
                    this.dynamicErrorMessage = 'Total Disbursal Amount should not be more than Pending Disbursal Amount.';
                    this.setValidity(true);

                } else if (this.pendDisbAmt > this.wrapDisburObj.Total_Disb_Amt__c) {
                    this.dynamicErrorMessage = '';
                    this.showError = false;
                    this.setValidity(false);
                }
            }
        } else if (event.target.dataset.name === 'Princ_Start_Date__c') {
            console.log('princ start date');
            this.pricStartDate = event.target.value;
            console.log('Principle Start Date', this.pricStartDate);
            if (this.pricStartDate < this.currDate) {
                this.showToastMessage('Error', this.customLabel.Trachy_Date_ErrorMessage, 'error', 'sticky');
                this.wrapDisburObj.Princ_Start_Date__c = "";
            } else {
                this.wrapDisburObj.Princ_Start_Date__c = event.target.value;
            }
        }
    }

    // ======================================================================================================

    @track _wiredDisburseDetails=[];
    @track actualDisbursData = [];
    @wire(getSobjectData, { params: '$disburParams' })
    handleDisbursementRespTable(result) {
        const { data, error } = result;
        this._wiredDisburseDetails = result
        console.log('paramters pass in handleDisbursementRespTable', this.disburParams);
        console.log('data from handleDisbursementRespTable', data);
        if (data) {
            if (data.parentRecords) {
               
                this.actualDisbursData = data.parentRecords;
                this.handleDisburseData(); 

            } else if (error) {
                console.log('Error from disburParams', error);
            }
        }
    }

    handleDisburseData(){

        if (this.actualDisbursData && this.actualDisbursData.length > 0) {
            this.splitDisbButton = true;
            this.showDisburDetTable = true;
            this.disburDetailsArr = [];
            this.actualDisbursData.forEach(newItem => {
                let tempIndex = this.disburDetailsArr.length + 1;
                let newObj = {
                    Id: newItem.Id,
                    Index__c: tempIndex,
                    Disbur_Status__c: newItem.Disbur_Status__c ? newItem.Disbur_Status__c : '',
                    DisbrDiscription__c: 'TRANCHE-'+tempIndex,
                    Total_Disb_Amt__c: newItem.Total_Disb_Amt__c ? newItem.Total_Disb_Amt__c : '',
                    Date_of_Disbur__c: newItem.Date_of_Disbur__c ? newItem.Date_of_Disbur__c : '',
                    Disbur_To__c:newItem.Disbur_To__c ? newItem.Disbur_To__c : '',
                    Princ_Rec_on__c:newItem.Princ_Rec_on__c ? newItem.Princ_Rec_on__c : '',
                    Princ_Start_Date__c:newItem.Princ_Start_Date__c ? newItem.Princ_Start_Date__c : ''
                };
              
                this.disburDetailsArr.push(newObj);
                console.log('disbur Details Arr', JSON.stringify(this.disburDetailsArr));
              
            });
        }
        
    }

    addTrancheHandler(){

        let numberOfTranch = this.disburDetailsArr.length + 1;
        this.disburDetailsArr.push({
            Index__c: this.disburDetailsArr.length + 1,
            Disbur_Status__c: '',
            DisbrDiscription__c: 'TRANCHE-'+numberOfTranch,
            Total_Disb_Amt__c: '',
            Date_of_Disbur__c: '',
            Disbur_To__c:'',
            Princ_Rec_on__c:'',
            Princ_Start_Date__c: this.priciplStartDate,
            sobjectType: 'Disbursement__c'     
        });
        this.showDisburDetTable = true;
      
    }

    @track disbursType;
   
    inputChangeHandler(event) {
        console.log('Inside Input change handler --------->',event.target.value);
        if (event.target.dataset.name === 'DisbursalType__c') {
            this.showDisburDetTable = true;   
            this.disbursType = event.target.value;
         if(event.target.value == 'Single'){  
                   
            let numberOfTranch = this.disburDetailsArr.length + 1;
                console.log('this.disburDetailsArr.length---->',this.disburDetailsArr.length);
                if( this.disburDetailsArr && this.disburDetailsArr.length <= 0){
                    console.log('Inside If---->');
                    this.disburDetailsArr.push({
                    Index__c: this.disburDetailsArr.length + 1,
                    Disbur_Status__c: '',
                    DisbrDiscription__c: 'TRANCHE-'+numberOfTranch,
                    Total_Disb_Amt__c: this.loanAmtIncChar,
                    Date_of_Disbur__c: '',
                    Disbur_To__c: '',
                    Princ_Rec_on__c:'',
                    Princ_Start_Date__c: this.priciplStartDate,
                    sobjectType: 'Disbursement__c'     
                });
               
            }else{
                console.log('Inside Else---->');
                console.log('this.actualDisbursData---->', JSON.stringify(this.actualDisbursData));
                //this.disburDetailsArr = [];
                if (this.actualDisbursData && this.actualDisbursData.length > 0) {
                    console.log('Inside actualDisbursData---->');
                    this.showDisburDetTable = true;
                    this.disburDetailsArr = [];
                    let tempDeleteRec = [];
                    this.actualDisbursData.forEach(newItem => {
                        console.log('newItem.DisbrDiscription__c--->',newItem.DisbrDiscription__c);
                        if(newItem.DisbrDiscription__c == 'TRANCHE-1'){
                            let newObj = {
                                Id: newItem.Id,
                                Index__c: newItem.Index__c ? newItem.Index__c : '',
                                Disbur_Status__c: newItem.Disbur_Status__c ? newItem.Disbur_Status__c : '',
                                DisbrDiscription__c: newItem.DisbrDiscription__c ? newItem.DisbrDiscription__c : '',
                                Total_Disb_Amt__c: newItem.Total_Disb_Amt__c ? newItem.Total_Disb_Amt__c : '',
                                Date_of_Disbur__c: newItem.Date_of_Disbur__c ? newItem.Date_of_Disbur__c : '',
                                Disbur_To__c:newItem.Disbur_To__c ? newItem.Disbur_To__c : '',
                                Princ_Rec_on__c:newItem.Princ_Rec_on__c ? newItem.Princ_Rec_on__c : '',
                                Princ_Start_Date__c:newItem.Princ_Start_Date__c ? newItem.Princ_Start_Date__c : ''

                            };
                          
                            this.disburDetailsArr.push(newObj); 
                        }else{

                            if(newItem.Id){
                               let tempDeleteObj =  {
                                    Id: newItem.Id,
                                    sobjectType: 'Disbursement__c'
                                }
                                tempDeleteRec.push(tempDeleteObj);
                            }
                            
                        }
            
                    });

                    if(tempDeleteRec.length > 0){
                        this.deleteMultipleRec(tempDeleteRec);
                    }
                    console.log('Disburs det arr outside for--->',JSON.stringify(this.disburDetailsArr));

                }else{
                    this.disburDetailsArr=[];
                    if( this.disburDetailsArr && this.disburDetailsArr.length == 0){
                        console.log('Inside If---->');
                        let numberOfTranchForSingle = this.disburDetailsArr.length + 1;
                        this.disburDetailsArr.push({
                        Index__c: this.disburDetailsArr.length + 1,
                        Disbur_Status__c: '',
                        DisbrDiscription__c: 'TRANCHE-'+numberOfTranchForSingle,
                        Total_Disb_Amt__c: this.loanAmtIncChar,
                        Date_of_Disbur__c: '',
                        Disbur_To__c: '',
                        Princ_Rec_on__c:'',
                        Princ_Start_Date__c: this.priciplStartDate,
                        sobjectType: 'Disbursement__c'     
                    });
                    }
                }
            }
                 
            this.showPrincipleFields = false;
            this.disblCrateTranButton = true;

            }else{
                if(event.target.value == 'Multiple'){   
                    
                    console.log('Inside Else this.disburDetailsArr.length---->',this.disburDetailsArr.length);
                if( this.disburDetailsArr && this.disburDetailsArr.length == 0){
                console.log('Inside If in multiple---->');
                this.disburDetailsArr = [];
                for(let i=1; i < 3; i++ ){
                    let numberOfTranchForMult = this.disburDetailsArr.length + 1;
                    this.disburDetailsArr.push({
                        Index__c: this.disburDetailsArr.length + 1,
                        Disbur_Status__c: '',
                        DisbrDiscription__c: 'TRANCHE-'+numberOfTranchForMult,
                        Total_Disb_Amt__c: '',
                        Date_of_Disbur__c: '',
                        Disbur_To__c:'',
                        Princ_Rec_on__c:'',
                        Princ_Start_Date__c: this.priciplStartDate,
                        sobjectType: 'Disbursement__c'
            
                    });
                
                  
                }
              
                }else{
                    console.log('Inside Else---->');
                    console.log('this.actualDisbursData---->', JSON.stringify(this.actualDisbursData));
                    this.disburDetailsArr = [];
                    if (this.actualDisbursData && this.actualDisbursData.length > 0) {
                        console.log('Inside actualDisbursData---->');
                        this.showDisburDetTable = true;
                
                        this.actualDisbursData.forEach(newItem => {
                            console.log('newItem.DisbrDiscription__c--->',newItem.DisbrDiscription__c);
                            if(newItem.DisbrDiscription__c == 'TRANCHE-1'){
                                let newObj = {
                                    Id: newItem.Id,
                                    Index__c: newItem.Index__c ? newItem.Index__c : '',
                                    Disbur_Status__c: newItem.Disbur_Status__c ? newItem.Disbur_Status__c : '',
                                    DisbrDiscription__c: newItem.DisbrDiscription__c ? newItem.DisbrDiscription__c : '',
                                    Total_Disb_Amt__c: newItem.Total_Disb_Amt__c ? newItem.Total_Disb_Amt__c : '',
                                    Date_of_Disbur__c: newItem.Date_of_Disbur__c ? newItem.Date_of_Disbur__c : '',
                                    Disbur_To__c:newItem.Disbur_To__c ? newItem.Disbur_To__c : '',
                                    Princ_Rec_on__c:newItem.Princ_Rec_on__c ? newItem.Princ_Rec_on__c : '',
                                    Princ_Start_Date__c:newItem.Princ_Start_Date__c ? newItem.Princ_Start_Date__c : ''
    
                                };
                                this.disburDetailsArr.push(newObj); 
                            }
                               
                        });

                        if(this.disburDetailsArr.length <= 1){
                            let numberOfTranchForMult1 = this.disburDetailsArr.length + 1;
                            this.disburDetailsArr.push({
                                Index__c: this.disburDetailsArr.length + 1,
                                Disbur_Status__c: '',
                                DisbrDiscription__c: 'TRANCHE-'+numberOfTranchForMult1,
                                Total_Disb_Amt__c: '',
                                Date_of_Disbur__c: '',
                                Disbur_To__c:'',
                                Princ_Rec_on__c:'',
                                Princ_Start_Date__c: this.priciplStartDate,
                                sobjectType: 'Disbursement__c'
                    
                            });
                        }
                       


                    }  else   {
                    this.disburDetailsArr = [];
                    if( this.disburDetailsArr && this.disburDetailsArr.length == 0){
                        console.log('Inside If in multiple---->');
                        this.disburDetailsArr = [];
                        for(let i=1; i < 3; i++ ){
                            let numberOfTranchForMult = this.disburDetailsArr.length + 1;
                            this.disburDetailsArr.push({
                                Index__c: this.disburDetailsArr.length + 1,
                                Disbur_Status__c: '',
                                DisbrDiscription__c: 'TRANCHE-'+numberOfTranchForMult,
                                Total_Disb_Amt__c: '',
                                Date_of_Disbur__c: '',
                                Disbur_To__c:'',
                                Princ_Rec_on__c:'',
                                Princ_Start_Date__c: this.priciplStartDate,
                                sobjectType: 'Disbursement__c'
                    
                            });
                           
                          
                        }
                      
                        }}
                }

                this.showPrincipleFields = true;
                this.showDisburDetTable = true;
                this.disblCrateTranButton = false;
            }
                
               
            }
        }

       
        console.log('Inside Input Change Handler::::', event.target.value);
        console.log('accessKey::::', event.target.accessKey);
        if (event.target.dataset.fieldname == "Disbur_Status__c") {
            this.disburDetailsArr[event.target.accessKey - 1].Disbur_Status__c = event.target.value;
          
        }


        if (event.target.dataset.fieldname == "Date_of_Disbur__c") {            
            this.disburDetailsArr[event.target.accessKey - 1].Date_of_Disbur__c = event.target.value;    
        }

        
        if (event.target.dataset.fieldname == "Total_Disb_Amt__c") {    
            this.disburDetailsArr[event.target.accessKey - 1].Total_Disb_Amt__c = event.target.value; 
            this.populateDisbursalStatus(event.target.accessKey-1);    
        }

        if (event.target.dataset.fieldname == "DisbrDiscription__c") { 
            this.disburDetailsArr[event.target.accessKey - 1].DisbrDiscription__c = event.target.value;  
        }

        if (event.target.dataset.fieldname == "Disbur_To__c") { 
            this.disburDetailsArr[event.target.accessKey - 1].Disbur_To__c = event.target.value;  
           this.populateDisbursalStatus(event.target.accessKey - 1);   
        }

        if (event.target.dataset.fieldname == "Princ_Start_Date__c") { 
            this.disburDetailsArr[event.target.accessKey - 1].Princ_Start_Date__c = event.target.value;  
              
        }

        if (event.target.dataset.fieldname == "Princ_Rec_on__c") { 
            this.disburDetailsArr[event.target.accessKey - 1].Princ_Rec_on__c = event.target.value;  
            this.populateDisbursalStatus(event.target.accessKey - 1);   
        }

        }

        get deleteAction(){
            let showDeleteAction = false;
            //console.log('this.disbursType-------->', this.disbursType);
            console.log('this disburDetailsArr length-------->', this.disburDetailsArr.length);
            if(this.disburDetailsArr.length > 2){
                showDeleteAction = true;
            }else{
                showDeleteAction = false;
            }
            return showDeleteAction;
        }

        get prncStartDateVisibl(){
            if(this.disburDetailsArr.length > 0 ){
                for(let i = 0; i < this.disburDetailsArr.length; i++){
                    if( this.disburDetailsArr[i].Disbur_Status__c == 'Disbursed' ){
                    return true;
            }
            }
        }}

        @track disabledFlag = false;
        handleChildData(event){
            console.log('event---------------->',event.detail);
            if(event.detail != null){
                this.disabledFlag = event.detail;
            }
            console.log('disabledFlag---------------->',this.disabledFlag);
        }
    

        populateDisbursalStatus(accessKey){
            let tempAccessKey = accessKey;
            console.log('Inside populateDisbursalStatus accessKey', tempAccessKey);
           
            if( this.disburDetailsArr[tempAccessKey].Disbur_To__c !== '' 
                   && this.disburDetailsArr[tempAccessKey].Total_Disb_Amt__c   !== ''    
                   && this.disburDetailsArr[tempAccessKey].Princ_Rec_on__c   !== ''       
               )
                {
                   console.log('Inside If disburDetailsArr ');
                   this.disburDetailsArr[tempAccessKey].Disbur_Status__c = 'Entered';
                }else{
                    console.log('Inside Else disburDetailsArr ');
                    this.disburDetailsArr[tempAccessKey].Disbur_Status__c = '';
                }

        }


        @track loanApplDetails={};
        handleUpsertForDisb() {
            console.log('Inside Upsert method-------->' + this.disburDetailsArr.length);
            if (this.disburDetailsArr.length > 0) {
                this.showSpinner = true;
    
                this.loanApplDetails = {
                    Id: this._loanAppId,
                    sobjectType: 'LoanAppl__c',
                    DisbursalType__c: this.disbursType
                    
                };
    
                console.log('this.applicantDetails Other after-------->' + JSON.stringify(this.loanApplDetails));
                var parentLoanAppl;
                parentLoanAppl = { ...this.loanApplDetails };
    
                let upsertData = {
                    parentRecord: parentLoanAppl,
                    ChildRecords: this.disburDetailsArr,
                    ParentFieldNameToUpdate: 'Loan_Appli__c'
                }
                console.log('upsertData 334-', JSON.stringify(upsertData));
                upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
                    .then(result => {
                        this.showToastMessage("Success", 'Disbursement Details Saved Successfully', "success", "sticky");
                        refreshApex(this._wiredDisburseDetails);
                        refreshApex(this._wiredLoanApplData);
                        this.showSpinner = false;
                     
                    })
                    .catch(error => {
                        console.error(error)
                        console.log('upsert error -', JSON.stringify(error));
                        this.showToastMessage("Error In Upsert Record ", error.body.message, "error", "sticky");
                        this.showSpinner = false;
                    })
            }else{
                this.showToastMessage("Error", 'Disbursement Details Not Available to Save', "error", "sticky");
                this.showSpinner = false;
            }
        }

        createDisbursmentRec(accessKeyForCreateRec){ 

            if(this.disburDetailsArr && this.disburDetailsArr.length > 0){         
                var disburmntRecord = this.disburDetailsArr.filter(item => item.Index__c == accessKeyForCreateRec);
            }
            
            if(disburmntRecord.length > 0) {
                this.showSpinner = true;
                let loanApplDetails = {
                    Id: this._loanAppId,
                    sobjectType: 'LoanAppl__c',
                    DisbursalType__c: this.disbursType
                };
    
                //console.log('this.applicantDetails Other after-------->' + JSON.stringify(this.loanApplDetails));
                var parentLoanAppl;
                parentLoanAppl = { ...loanApplDetails };
    
                let upsertData = {
                    parentRecord: parentLoanAppl,
                    ChildRecords: disburmntRecord,
                    ParentFieldNameToUpdate: 'Loan_Appli__c'
                }
                console.log('upsertData 334-', JSON.stringify(upsertData));
                upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
                    .then(result => {               
                        console.log('result ------------------>', JSON.stringify(result));
                        if(result && result.ChildReords && result.ChildReords.length>0)
                        {           
                            this.disbursmentId=result.ChildReords[0].Id;
                            this.showSplitDisbursModal = true; 
                            refreshApex(this._wiredDisburseDetails);
                        }
                        this.showSpinner = false;
                        this.showToastMessage("Success", 'Disbursement Details Saved Successfully', "success", "sticky");
                    })
                    .catch(error => {
                        console.log('upsert error --------------------->', JSON.stringify(error));
                        this.showSpinner = false;
                        
                    })
               }else{
                        this.showSpinner = false;
            }
        }

        
        deleteMultipleRec(deleteRecObj){
            console.log('deleteRecObj----------->'+JSON.stringify(deleteRecObj));
            if(deleteRecObj){
                this.showSpinner = true;
                deleteIncomeRecord({ rcrds: deleteRecObj })
                .then(result => {
                   console.log('Delete result----------->'+JSON.stringify(result));
                   this.showSpinner = false;
                   refreshApex(this._wiredDisburseDetails);
                   refreshApex(this._wiredLoanApplData);
                })
                .catch(error => {
                    this.showSpinner = false;
                 console.log('error in delete--------->', JSON.stringify(error));
                
                })
            }else{
                    this.showSpinner = false;
            }
           

        }

    
     


        @track showDeleteConfirmation = false;
        @track recordDelId;
        @track accessKeyForDeletion;
        deleteHandler(event) {
            console.log('Inside deleteHandler');

            this.showDeleteConfirmation = true;
    
            this.recordDelId = this.disburDetailsArr[event.target.accessKey - 1].Id;
            this.accessKeyForDeletion = event.target.accessKey;
      }
    
        hideModalBox() {
            this.showDeleteConfirmation = false;
     }
    
        handleConfirmDelete() {
            console.log('Inside handleConfirmDelete');
            this.handleRecordDeletion();
            this.showDeleteConfirmation = false;
     }
        handleCancelDelete() {
            this.showDeleteConfirmation = false;
    }


      handleRecordDeletion() {
        console.log('Inside handleDeleteAction');
        if (this.recordDelId) {
           
            console.log('Inside If In delete handler');
            let deleteRecord = [
                {
                    Id: this.recordDelId,
                    sobjectType: 'Disbursement__c'
                }
            ]

            deleteIncomeRecord({ rcrds: deleteRecord })
            .then(result => {
               console.log('Delete result----------->'+JSON.stringify(result));
             
               this.showToastMessage("Success", 'Disbursement Record Deleted Successfully', "success", "sticky");
               this.showDeleteConfirmation = false;
              
            })
            .catch(error => {
                console.log('Delete Error----------->'+JSON.stringify(error));
            
                this.showToastMessage("Error In handleDeleteAction ", error.body.message, "error", "sticky");
                this.showDeleteConfirmation = false;
               
            })
        }
        else {
            console.log('Inside Else In delete handler');
          
            this.showToastMessage("Success", 'Disbursement Record Deleted Successfully', "success", "sticky");
            this.showDeleteConfirmation = false;
           
        }

        if (this.disburDetailsArr.length >= 1) {
            this.disburDetailsArr.splice(this.accessKeyForDeletion - 1, 1);

            for (let i = 0; i < this.disburDetailsArr.length; i++) {
                this.disburDetailsArr[i].Index__c = i + 1;
            }
            console.log('deleted disburDetailsArr:::: after delete', JSON.stringify(this.disburDetailsArr));

            
        }
    }

  
    @track disbursmentId;
    @track showSplitDisbursModal = false;
    splitDisbursmentHandler(event){
        this.disbursmentId = event.target.disbursmentid;
        let accessKeyForCreateRec =  event.target.accessKey;
        if(this.disbursmentId){
            this.showSplitDisbursModal = true;
        }else{
            this.createDisbursmentRec(accessKeyForCreateRec);
         
        }
        //console.log('Disbursment ID-------------->'+event.target.disbursmentid);
        
    }

    
    backButtonHandler(){
        if (this.template.querySelectorAll("c-split-disbursment-details-comp")) {
            this.template.querySelector("c-split-disbursment-details-comp").showTableHandler();
        }
    }
    
    saveAsDraftHandler(){
        if (this.template.querySelectorAll("c-split-disbursment-details-comp")) {
            this.template.querySelector("c-split-disbursment-details-comp").handleUpsert();
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
                    //break;
                }
            }    

            if(isValid == true){
                if (this.template.querySelectorAll("c-split-disbursment-details-comp")) {
                    this.template.querySelector("c-split-disbursment-details-comp").handleUpsert();
                }
            }
      
    }


    showModalBox() {  
        this.showSplitDisbursModal = true;
    }

    hideModalBox() {  
        this.showSplitDisbursModal = false;
    }


    @track totalOfSpliChqAmt = []
    @track splitChAmt = []
    @track onchToTOfSplChqAmt
    @track getSplitChAmtRecoId = []
    @track getSplitChAmt = []
    @track disbTo
    @track paymentTo
    handleSplitInputChange(event) {
        try {
            // this.wrapSplitDisbObj[event.target.dataset.name] = event.target.value;
            console.log('handle CHange print', event.target.dataset.index);
            this.index = event.target.dataset.index;
            const index = event.target.dataset.index;
            const fieldName = event.target.dataset.name;
            const value = event.target.value;
            this.inputValue = event.target.value;
            console.log('index', event.target.dataset.index);
            let tempArray = [...this.wrapSplitDisbObj];
            let tempObj = { ...tempArray[index] };
            if (event.target.dataset.type === 'string') {
                let strVal = event.target.value;
                this.inputValue = strVal.toUpperCase();
                console.log('upper case value', value);
            }
            tempObj[fieldName] = this.inputValue;
            // tempObj[fieldName] = event.target.value;
            tempArray[index] = tempObj;
            this.wrapSplitDisbObj = [...tempArray];
            console.log('this.wrapSplitDisbObj common', this.wrapSplitDisbObj);

            let dateObj = new Date();
            let month = String(dateObj.getMonth() + 1)
                .padStart(2, '0');
            let day = String(dateObj.getDate())
                .padStart(2, '0');
            let year = dateObj.getFullYear();
            this.currDate = year + '-' + month + '-' + day;
            console.log('current date', this.currDate);

            if (fieldName === 'Payment_to__c') {
                console.log('payment to');
                let tempArray = [...this.wrapSplitDisbObj];
                let tempObj = { ...tempArray[index] };
                tempObj.Payment_to__c = value;
                tempArray[index] = tempObj;
                this.wrapSplitDisbObj = [...tempArray];
                console.log('this.wrapSplitDisbObj', this.wrapSplitDisbObj);
                this.paymentTo = value
                let paymTo = value;
                if (paymTo === "Repayment Account") {
                    console.log('repayment account ');
                    console.log('has edit access', this.hasEditAccess);
                    this.wrapSplitDisbObj[index].isDisbFavor = true;
                    this.initiPennDropBu = false
                    this.repayAccParams.queryCriteria = ' where Is_Active__c = true AND Loan_Application__c = \'' + this._loanAppId + '\''
                    console.log('repay account query', this.repayAccParams.queryCriteria);
                    getSobjectData({ params: this.repayAccParams })
                        .then((result) => {
                            console.log(' result from repay account ', result);
                            if (result) {
                                if (result.parentRecords) {
                                    console.log('applicant banking data', result.parentRecords[0].Applicant_Banking__c);
                                    this.applBankId = result.parentRecords[0].Applicant_Banking__c;
                                    this.repayAccId = result.parentRecords[0].Id;
                                    console.log('value print from repay account', this.applBankId, this.repayAccId);
                                    // console.log('acc no', result.parentRecords.Account_Number__c);
                                    // console.log('acc honlder name', result.parentRecords.AccHolderName__c);
                                }
                            }

                            this.applBankingDetails();
                            this.repayAccVerifi();
                        })



                } else if (paymTo === "Third Party Account") {
                    this.wrapSplitDisbObj[index].isDisbFavor = false;
                    if (this.disbTo !== "Insurance Company") {
                        this.initiPennDropBu = true
                    }
                } else if (paymTo === "Insurance Partner") {
                    this.initiPennDropBu = false
                }

            } else if (fieldName === 'Date_of_Disbur__c') {
                let tempArray = [...this.wrapSplitDisbObj];
                let tempObj = { ...tempArray[index] };
                tempObj.Date_of_Disbur__c = value;
                tempArray[index] = tempObj;
                this.wrapSplitDisbObj = [...tempArray];
                // this.wrapSplitDisbObj[index].Date_of_Disbur__c = value

                let selectedDate = value

                if (selectedDate < this.currDate) {
                    console.log('select date print');
                    this.showToastMessage('Error', this.customLabel.Trachy_Date_ErrorMessage, 'error', 'sticky');

                }

            } else if (fieldName === 'Disbur_To__c') {
                let tempArray = [...this.wrapSplitDisbObj];
                let tempObj = { ...tempArray[index] };
                tempObj.Disbur_To__c = value;
                tempArray[index] = tempObj;
                this.wrapSplitDisbObj = [...tempArray];
                this.disbTo = value
                if (this.paymentTo === "Third Party Account" && this.disbTo === "Insurance Company") {
                    this.initiPennDropBu = false
                } else if (this.paymentTo === "Third Party Account" && this.disbTo !== "Insurance Company") {
                    this.initiPennDropBu = true
                }

            } else if (fieldName === 'Cheq_DD_Date__c') {
                let tempArray = [...this.wrapSplitDisbObj];
                let tempObj = { ...tempArray[index] };
                tempObj.Cheq_DD_Date__c = value;
                tempArray[index] = tempObj;
                this.wrapSplitDisbObj = [...tempArray];
                // this.wrapSplitDisbObj[index].Cheq_DD_Date__c = value

                let cheqDDDate = value;
                if (cheqDDDate < this.currDate) {
                    console.log('select DD date print');
                    this.showToastMessage('Error', this.customLabel.Trachy_Date_ErrorMessage, 'error', 'sticky');

                }
            } else if (fieldName === 'Effec_Date__c') {
                let tempArray = [...this.wrapSplitDisbObj];
                let tempObj = { ...tempArray[index] };
                tempObj.Effec_Date__c = value;
                tempArray[index] = tempObj;
                this.wrapSplitDisbObj = [...tempArray];
                // this.wrapSplitDisbObj[index].Effec_Date__c = value

                let effecDate = value;
                if (effecDate < this.currDate) {
                    console.log('select effective date print');
                    this.showToastMessage('Error', this.customLabel.Trachy_Date_ErrorMessage, 'error', 'sticky');

                }
            } else if (fieldName === 'Pay_Mode__c') {
                let tempArray = [...this.wrapSplitDisbObj];
                let tempObj = { ...tempArray[index] };
                tempObj.Pay_Mode__c = value;
                tempArray[index] = tempObj;
                this.wrapSplitDisbObj = [...tempArray];
                console.log('this.wrapSplitDisbObj', this.wrapSplitDisbObj);
                let paymode = value;
                console.log('paymode ', paymode);
                if (paymode === "Funds Transfer") {
                    this.fundTransMode = true
                } else {
                    this.fundTransMode = false
                }
            } else if (fieldName === 'Split_Cheque_Amt__c') {
                this.onchToTOfSplChqAmt = 0
                let tempArray = [...this.wrapSplitDisbObj];
                let tempObj = { ...tempArray[index] };
                tempObj.Split_Cheque_Amt__c = value;
                tempArray[index] = tempObj;
                this.wrapSplitDisbObj = [...tempArray];
                let splChqeAmt = parseFloat(value) || 0;
                this.onchToTOfSplChqAmt = splChqeAmt
                if (this.disbRowId) {
                    this.splitDisburParams.queryCriteria = ' where DisburseRela__c = \'' + this.disbRowId + '\''
                    getSobjectData({ params: this.splitDisburParams })
                        .then((result) => {
                            console.log('splitDisbur in split amt', result);
                            if (result.parentRecords) {
                                this.getSplitChAmt = []
                                this.onchToTOfSplChqAmt = 0

                                result.parentRecords.forEach((element) => {
                                    this.getSplitChAmt.push({
                                        Id: element.Id,
                                        value: element.Split_Cheque_Amt__c
                                    });
                                });

                                const indexOfRecordToUpdate = this.getSplitChAmt.findIndex(record => {
                                    return record.Id === this.splitDisRowId;
                                });
                                if (indexOfRecordToUpdate !== -1) {
                                    this.getSplitChAmt[indexOfRecordToUpdate].value = splChqeAmt;
                                } else {
                                    this.getSplitChAmt.push({ Id: result.parentRecords[index].Id, value: splChqeAmt });
                                }

                                this.onchToTOfSplChqAmt = this.getSplitChAmt.reduce((total, record) => {
                                    return total + record.value;
                                }, 0);
                            }
                            if (this.onchToTOfSplChqAmt !== undefined && this.disbRowId !== undefined) {
                                console.log('onchange value of split amount', this.onchToTOfSplChqAmt);
                                // if (splChqeAmt !== undefined && this.onchToTOfSplChqAmt !== undefined) {
                                //     console.log('on change split amsount', splChqeAmt);
                                //     let addn = this.onchToTOfSplChqAmt + splChqeAmt
                                //     console.log('addition of on', addn);
                                //     console.log('total disb amt if ', this.wrapDisburObj.Total_Disb_Amt__c);
                                //     if (addn > this.wrapDisburObj.Total_Disb_Amt__c) {
                                //         this.showToastMessage('Error', this.customLabel.Trachy_SplChqAmt_ErrorMessage, 'error', 'sticky');
                                //     }
                                // } else 
                                if (this.onchToTOfSplChqAmt) {
                                    let addn = this.onchToTOfSplChqAmt
                                    console.log('total disb amt else', this.wrapDisburObj.Total_Disb_Amt__c);
                                    if (addn > this.wrapDisburObj.Total_Disb_Amt__c) {
                                        this.showToastMessage('Error', this.customLabel.Trachy_SplChqAmt_ErrorMessage, 'error', 'sticky');
                                    }
                                }

                            }
                        }
                        )
                }
                // if (this.totalOfSpliChqAmt !== undefined && splChqeAmt !== undefined && this.splitDisRowId === undefined) {
                //     let addn = this.totalOfSpliChqAmt + splChqeAmt
                //     console.log('addition of onchange amount and old amount', addn);
                //     console.log('total disb amount print', this.wrapDisburObj.Total_Disb_Amt__c);
                //     if (addn > this.wrapDisburObj.Total_Disb_Amt__c) {
                //         console.log('print addn ==', addn, 'total cmt', this.wrapDisburObj.Total_Disb_Amt__c);
                //         this.showToastMessage('Error', this.customLabel.Trachy_SplChqAmt_ErrorMessage, 'error', 'sticky');
                //     }
                // }
                if (this.totalOfSpliChqAmt !== undefined && splChqeAmt !== undefined && this.splitDisRowId === undefined) {
                    let addn = this.onchToTOfSplChqAmt
                    console.log('abhis1', this.onchToTOfSplChqAmt, 'abih2 ', splChqeAmt);
                    console.log('total amt ======', this.totalDibAmtValue);
                    console.log('addn ==+++', addn)
                    if (addn > this.totalDibAmtValue) {
                        this.showToastMessage('Error', this.customLabel.Trachy_SplChqAmt_ErrorMessage, 'error', 'sticky');
                    }
                }
            }

        } catch (error) {
            console.log('handle input error', error);
            console.error('e.message => ' + error.message);

        }

    }

    applBankingDetails() {
        console.log('applBankId', this.applBankId);
        if (this.applBankId !== undefined) {
            this.applBankParams.queryCriteria = ' where Id = \'' + this.applBankId + '\''

            getSobjectData({ params: this.applBankParams })
                .then((result) => {
                    console.log(' result from applicant banking ', result);
                    // let tempArray = [...this.wrapSplitDisbObj];
                    // let tempObj = { ...tempArray[index] };
                    // tempObj.Date_of_Disbur__c = value;
                    // tempArray[index] = tempObj;
                    // this.wrapSplitDisbObj = [...tempArray];
                    if (result.parentRecords) {
                        this.wrapSplitDisbObj[this.index].Cheq_Favor_Dets__c = result.parentRecords[0].Name_of_the_Primary_Account_Holder_s__c;
                        this.wrapSplitDisbObj[this.index].Cheq_Favor_Acc_No__c = result.parentRecords[0].AC_No__c;
                        this.wrapSplitDisbObj[this.index].IFSC_Detail__c = result.parentRecords[0].IFSC_Code__c
                    }
                })
        }
    }

    repayAccVerifi() {
        console.log('repay Id ', this.repayAccId);
        if (this.repayAccId !== undefined) {
            this.repayAccVeriParams.queryCriteria = ' where LoanAppl__c = \'' + this._loanAppId + '\' AND RepayAcc__c = \'' + this.repayAccId + '\''
            console.log('repay account verify query', this.repayAccVeriParams.queryCriteria);
            getSobjectData({ params: this.repayAccVeriParams })
                .then((result) => {
                    console.log(' result from repay account verify  ', result);
                    if (result.parentRecords) {
                        if (result.parentRecords[0].PennyDropStatus__c !== undefined && result.parentRecords[0].NameRetuFromPennyDrop__c !== undefined) {
                            this.wrapSplitDisbObj[this.index].Penny_Drop_Nm_Sta__c = result.parentRecords[0].PennyDropStatus__c;
                            this.wrapSplitDisbObj[this.index].Benef_Nm_of_Penny_Drop__c = result.parentRecords[0].NameRetuFromPennyDrop__c;
                        }
                    }

                })
        }
    }


    @track loanApplicationRecord = [];

    @track DocumentDetaiId

    handleGenerateDocuments() {
       // this.showSpinner = true;
        this.showDocList = false;
        if (this.dataOfDisbur.length !== 0) {
            createDocumentDetail({ applicantId: this.loanApplicationRecord.Applicant__c, loanAppId: this.loanApplicationRecord.Id, docCategory: 'Disbursement Memo', docType: 'Disbursement Memo', docSubType: 'Disbursement Memo', availableInFile: false })
                .then((result) => {
                    console.log('createDocumentDetailRecord result ', result);
                    this.DocumentDetaiId = result;
                    console.log('createDocumentDetailRecord DocumentDetaiId ', this.DocumentDetaiId);

                    let pageUrl = this.customLabel.disbursementMemo + this.loanApplicationRecord.Id;
                    // window.location.open(pageUrl);
                    const pdfData = {
                        pageUrl: pageUrl,
                        docDetailId: this.DocumentDetaiId,
                        fileName: 'Disbursement Memo.pdf'
                    }
                    this.generateDocument(pdfData);

                })
                .catch((err) => {
                    // this.showToast("Error", err, "error", sticky);
                    console.log(" createDocumentDetailRecord error===", err);
                });
        } else {
            this.showToastMessage('Errpr', this.customLabel.DisbMemoRdError, 'error', 'sticky');
        }

    }

    getLoanAppData() {
        this.showDocList = false;
        let paramsLoanApp = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Id', 'EMIOptionsintranchedisbursementCase__c', 'Total_PF_Amount__c', 'RemPFDeductFromDisbursementAmount__c', 'FirstEMIDate__c', 'Applicant__c', ''],
            queryCriteria: ' where Id = \'' + this._loanAppId + '\' '
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Loan application data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    //this.repayAccData = result.parentRecords;
                    this.loanApplicationRecord = { ...result.parentRecords[0] };
                    // this.showCAMReports = true;
                    this.showDocList = true;
                    console.log('this.loanApplicationRecord-->' + JSON.stringify(this.loanApplicationRecord));
                }

            })
            .catch((error) => {
                console.log('Error In getting Loan Application Data ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    generateDocument(pdfData) {
        generateDocument({ wrapObj: pdfData })
            .then((result) => {
                this.showSpinner = false;
                if (result == 'success') {
                    // this.refreshDocTable();
                    this.forLatestDocDetailRec();
                } else {
                    console.log(result);
                }

            })
            .catch((err) => {
                // this.showToast("Error", err, "error", "sticky");
                console.log(" createDocumentDetailRecord error===", err);
            });
    }
    forLatestDocDetailRec() {
        let docCat = 'Disbursement Memo';
        let listOfAllParent = [];
        let paramForIsLatest = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'Appl__c', 'AppvdRmrks__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c'],
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this.loanApplicationRecord.Id + '\' AND Appl__c = \'' + this.loanApplicationRecord.Applicant__c + '\' AND DocCatgry__c = \'' + docCat + '\' AND DocTyp__c = \'' + docCat + '\' AND DocSubTyp__c = \'' + docCat + '\''
        }
        getSobjectDat({ params: paramForIsLatest })
            .then((result) => {
                if (result.parentRecords) {
                    listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
                }
                let oldRecords = []
                oldRecords = listOfAllParent.filter(record => record.Id !== this.DocumentDetaiId);
                let isLatestFalseRecs = []
                isLatestFalseRecs = oldRecords.map(record => {
                    return { ...record, IsLatest__c: false };
                });
                let obj = {
                    Id: this.DocumentDetaiId,
                    AppvdRmrks__c: isLatestFalseRecs && isLatestFalseRecs.length > 0 ? isLatestFalseRecs[0].AppvdRmrks__c : ''
                }
                isLatestFalseRecs.push(obj);
                upsertSObjectRecord({ params: isLatestFalseRecs })
                    .then(result => {
                        this.refreshDocTable();
                        console.log('result ' + JSON.stringify(result));
                    }).catch(error => {
                        this.showSpinner = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Error while getting Latest DM Records',
                                variant: 'error',
                                mode: 'sticky'
                            })
                        );
                        console.log('778' + error)
                    })
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log(" Getting doc dtl data error===", error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error while getting Latest DM Records',
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                console.log('Error In getting Document Details  ', error);
            });
    }

    refreshDocTable() {
        this.showDocList = true;
        this.showSpinner = false;
    }

    @track isModalOpen = false;
    @track deleteRecId
    @track removeModalMessage = 'Do you want to delete?';

    handleDeleteAction(event) {
        this.isModalOpen = true;
        // this.wrapSplitDisbObj.splice(event.currentTarget.dataset.index, 1);
        this.deleteRecId = event.target.dataset.id;
        console.log("deleteRecId", this.deleteRecId);
        // if (deleteRecId.length == 18) {
        //     console.log("delete initated");
        //     this.handleDeleteRecId(deleteRecId);
        // }
    }

    handleRemoveRecord(event) {
        if (this.deleteRecId) {
            if (this.deleteRecId.length == 18) {
                this.wrapSplitDisbObj.splice(event.currentTarget.dataset.index, 1);
                this.handleDeleteRecId(this.deleteRecId);
            }
        } else {
            this.wrapSplitDisbObj.splice(event.currentTarget.dataset.index, 1);
            this.isModalOpen = false;
        }
    }
    closeModal(event) {
        this.isModalOpen = false;
    }

    handleDeleteRecId(delRecId) {
        console.log("deleteRec ", delRecId);
        deleteRecord(delRecId).then((result) => {
            this.showToastMessage('Success', this.customLabel.SplitDisb_Del_SuccesMessage, 'success', 'sticky')
            // refreshApex(this._wiredSplitDisbData);
            // refreshApex(this._wiredLoanApplData);
            console.log('delete result', result);
            refreshApex(this._wiredDisburData);
            if (this.disbRowId) {

                this.splitDisburParams.queryCriteria = ' where DisburseRela__c = \'' + this.disbRowId + '\''
                console.log('data refresh after delete', this.splitDisburParams.queryCriteria);
                this.splitDisburParams = { ...this.splitDisburParams };
            }
            refreshApex(this._wiredSplitDisbData);
            // console.log('disb row id =', this.disbRowId);
            // if (this.disbRowId) {
            //     this.splitDisburParams.queryCriteria = ' where DisburseRela__c = \'' + this.disbRowId + '\''
            //     refreshApex(this._wiredSplitDisbData);

            // }
            this.isModalOpen = false;
        }).catch((error) => {
            this.isModalOpen = false;
            console.log('Errror !! ' + JSON.stringify(error));
            this.showToast("Error deleting record", "error", error.body.message);

        });
    }
}