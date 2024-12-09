import { LightningElement, api, track, wire } from 'lwc';

import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { createRecord } from "lightning/uiRecordApi";
import { formattedDateTimeWithoutSeconds } from 'c/dateUtility';
//Apex Methods
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';

import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, MessageContext } from 'lightning/messageService';

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import formFactorPropertyName from "@salesforce/client/formFactor";
import createDocumentDetail from "@salesforce/apex/DocumentDetailController.createDocumentDetail";
import generateDocument from "@salesforce/apex/GeneratePDFandAttachToLoanApplication.generateDocument";

import getSessionId from '@salesforce/apex/SessionUtil.getSessionId';
import { loadScript } from "lightning/platformResourceLoader";
import cometdlwc from "@salesforce/resourceUrl/cometd";
import Id from '@salesforce/user/Id';
// Custom labels
import CustomerConf_RepaymentAcc_ErrorMessage from '@salesforce/label/c.CustomerConf_RepaymentAcc_ErrorMessage';
import CustomerConf_Nach_ErrorMessage from '@salesforce/label/c.CustomerConf_Nach_ErrorMessage';
import CustomerConf_1stEmi_ErrorMessage from '@salesforce/label/c.CustomerConf_1stEmi_ErrorMessage';
import CustomerConf_SendEnach_ErrorMessage from '@salesforce/label/c.CustomerConf_SendEnach_ErrorMessage';
import CustomerConf_SendEnach_SuccessMessage from '@salesforce/label/c.CustomerConf_SendEnach_SuccessMessage';
import sanctionLetter from '@salesforce/label/c.Page_URL_Sanction_Letter';
import termSheet from '@salesforce/label/c.PageURLTermSheet';
import applicationFormForFedFina from '@salesforce/label/c.ApplicationFormForFedFina';
import getLoanAgreementURL from '@salesforce/label/c.getLoanAgreementURL';
import loanAgreementForPLAndBL from '@salesforce/label/c.loanAgreementForPLAndBL';
import adharConsentLetter from '@salesforce/label/c.adharConsentLetter';
import getKFSDocLink from '@salesforce/label/c.getKFSDocLink';
import PFDeductionLetterURL from '@salesforce/label/c.PFDeductionLetter';
import PreEmiDeductionLetterURL from '@salesforce/label/c.PreEmiDeductionLetterURL';
import InterestBearingLetterURL from '@salesforce/label/c.InterestBearingLetterURL';

import GetBTDraftLinkPart1 from '@salesforce/label/c.GetBTDraftLinkPart1';
import GetBTDraftLinkPart2 from '@salesforce/label/c.GetBTDraftLinkPart2';
import getDPNDocumentLink from '@salesforce/label/c.getDPNDocumentLink';
import EndUserLetter from '@salesforce/label/c.EndUserLetter';
import PageURLNACHForm from '@salesforce/label/c.PageURLNACHForm';
import sanctionLetterBT from '@salesforce/label/c.Page_URL_Sanction_LetterBTTopUp';
import CustomerConf_SelPaymentGateWay_ErrorMessage from '@salesforce/label/c.CustomerConf_SelPaymentGateWay_ErrorMessage';
import CustomerConf_SelPaymentType_ErrorMessage from '@salesforce/label/c.CustomerConf_SelPaymentType_ErrorMessage';
import CustomerConf_PaymentRec_ErrorMessage from '@salesforce/label/c.CustomerConf_PaymentRec_ErrorMessage';
import CustomerConf_PlatformEvent_ErrorMessage from '@salesforce/label/c.CustomerConf_PlatformEvent_ErrorMessage';
import CustomerConf_Integration_ErrorMessage from '@salesforce/label/c.CustomerConf_Integration_ErrorMessage';
import CustomerConf_Integration_SuccessMessage from '@salesforce/label/c.CustomerConf_Integration_SuccessMessage';
import CustomerConf_Appeal_ErrorMessage from '@salesforce/label/c.CustomerConf_Appeal_ErrorMessage';
import CustomerConf_pennyDrop_SuccessMessage from '@salesforce/label/c.CustomerConf_pennyDrop_SuccessMessage';
import CustomerConf_PennyDrop_ErrorMessage from '@salesforce/label/c.CustomerConf_PennyDrop_ErrorMessage';
import CustomerConf_Enach_SuccessMessage from '@salesforce/label/c.CustomerConf_Enach_SuccessMessage';
import CustomerConf_Enach_ErrorMessage from '@salesforce/label/c.CustomerConf_Enach_ErrorMessage';
import CustomerConf_ReqFields_ErrorMessage from '@salesforce/label/c.CustomerConf_ReqFields_ErrorMessage';
import CustomerConf_Save_SuccessMessage from '@salesforce/label/c.CustomerConf_Save_SuccessMessage';
import CustomerConf_Update_ErrorMessage from '@salesforce/label/c.CustomerConf_Update_ErrorMessage';
import CustomerConf_DocDetail_ErrorMessage from '@salesforce/label/c.CustomerConf_DocDetail_ErrorMessage';
import DeclarationOfLoanAgreement from '@salesforce/label/c.DeclarationOfLoanAgreement';
import PowerOfAttonrny from '@salesforce/label/c.PowerOfAttonrny';
import SignatureVerificationForm from '@salesforce/label/c.SignatureVerificationForm';
import DisbursalRequestForm from '@salesforce/label/c.DisbursalRequestForm';
import Bre_Rerun_Error_Message from '@salesforce/label/c.Bre_Rerun_Error_Message';
import BRETriggerFailedMessage from '@salesforce/label/c.BRETRIGGERFAILEDMESSAGE';
import BRETriggerMessage from '@salesforce/label/c.RUNBREBUTTONMESSAGE';
import getFilePreviewDataList from "@salesforce/apex/GetDocumentDetails.getFilePreviewDataList";

//imports
import * as HELPER from './parameters';
export default class CustomerConfirmation extends LightningElement {

    label = {
        sanctionLetter,
        BRETriggerFailedMessage,
        BRETriggerMessage,
        Bre_Rerun_Error_Message,
        sanctionLetterBT,
        termSheet,
        PageURLNACHForm,
        CustomerConf_RepaymentAcc_ErrorMessage,
        CustomerConf_Nach_ErrorMessage,
        CustomerConf_1stEmi_ErrorMessage,
        CustomerConf_SendEnach_ErrorMessage,
        CustomerConf_SendEnach_SuccessMessage,
        CustomerConf_SelPaymentGateWay_ErrorMessage,
        CustomerConf_SelPaymentType_ErrorMessage,
        CustomerConf_PaymentRec_ErrorMessage,
        CustomerConf_PlatformEvent_ErrorMessage,
        CustomerConf_Integration_SuccessMessage,
        CustomerConf_Integration_ErrorMessage,
        CustomerConf_Appeal_ErrorMessage,
        CustomerConf_pennyDrop_SuccessMessage,
        CustomerConf_PennyDrop_ErrorMessage,
        CustomerConf_Enach_SuccessMessage,
        CustomerConf_Enach_ErrorMessage,
        CustomerConf_ReqFields_ErrorMessage,
        CustomerConf_Save_SuccessMessage,
        CustomerConf_Update_ErrorMessage,
        CustomerConf_DocDetail_ErrorMessage,
        applicationFormForFedFina,
        EndUserLetter,
        getLoanAgreementURL,
        adharConsentLetter,
        InterestBearingLetterURL,
        PreEmiDeductionLetterURL,
        PFDeductionLetterURL,
        getKFSDocLink,
        GetBTDraftLinkPart1,
        GetBTDraftLinkPart2,
        getDPNDocumentLink,
        SignatureVerificationForm,
        DisbursalRequestForm,
        loanAgreementForPLAndBL,
        PowerOfAttonrny,
        DeclarationOfLoanAgreement

    };
    docType = ['Signature Verification Form','Aadhaar Consent', 'Disbursal Documents', 'Sanction Letter', 'NACH Form', 'Term Sheet', 'Application Form', 'Disbursal Documents', 'Sanction Letter & KFS Document', 'BT Draft', 'DPN Document'];
    subType = ['Signature Verification Form','Declaration of Loan Agreement','Power Of Attonrny','Loan Agreement', 'Aadhaar Consent', 'Sanction Letter', 'NACH Form', 'Term Sheet', 'Application Form', 'End Use Letter', 'Interest Bearing Letter', 'End Use, Pre EMI and PF Deduction Letter', 'PF Deduction Letter', 'Sanction Letter & KFS Document', 'BT Draft Part 2', 'BT Draft Part 1', 'DPN Document'];
    docCategory = ['KYC Documents', 'Sanction Letter', 'NACH Form', 'Term Sheet', 'Sanction Letter & KFS Document', 'BT Draft', 'System Generated Documents']
    @api hasEditAccess = false;
    @api layoutSize;
    @api channelName = "/event/IntRespEvent__e";

    @track preEmiTypeOptions = [
        { value: "Yes", label: "Yes" },
        { value: "No", label: "No" }
    ];
    @track preEmiTypVal;
    @track formFactor = formFactorPropertyName;
    @track desktopBoolean = false;
    @track phoneBolean = false;
    enableInfiniteScrolling = true;
    enableBatchLoading = true;
    @track isReadOnly = false;
    @track userId = Id;
    @track stage;
    @track subStage;
    @track pennyDrpDateTimeDisp;
    @track resultOfPennyDrop
    @track availableProcessOptions = [{ label: "Yes", value: "Yes", checked: false },
    { label: "No", value: "No", checked: false }];

    @track nameReturnedFromPDOptions = [{ label: "Yes", value: "Yes", checked: false },
    { label: "No", value: "No", checked: false }];

    @track showSpinner = false;
    cometdlib;
    @track timeout = 30000;// 30 sec timeout;
    @track disableIntiatePennyDrop = false;
    @track nachButtonVisible = false;
    @track repayAccVerDqata = [];
    @track repayAccData = []
    @track disableLmsUpdate = false;
    @track disableSendLinkToCustmer = false;
    @track disableLmsUpdateDis = false;
    @track disableSendLinkToCustmerDis = false;
    @track homeLoanRecordTypeId;
    @track remaPfDeductOptions = [];
    @track emiOptionsInTrache = [];
    @track customerAgreedOptions = [];
    @track paymentGateWayOptions = [];
    @track insurancePremToBeDedFromDisOptions = [];
    @track paymentTypeOptions = [];
    @track insurancePremToBeDedFromDisAmtValue = 'Y';
    @track showFormToEnterData = false;
    @track showFormToEnterDataDis = false;
    @track showAddPaymentButton = false;
    @track insAmt;
    @track paymentRecords = [];
    @track totdalPFAmt;
    @track emiOptTracnDisCase;
    @track pricingApprvalAppble;
    @track customerAgreedLoanTermsValue;
    @track showGenerateDocumentButton;
    @track showGenerateDocumentButtonNew;
    @track showBelowSection = false;
    @track remPfDeductFromDisAmtp;
    @track paymentType;
    @track showTra = false;
    @track showTraNew = false;
    @track loanApplicationRecord;
    @track paymentGateWay;
    @wire(getObjectInfo, { objectApiName: 'LoanAppl__c' })
    loanAppObjectInfo;
    @track paytmIntMsgId;
    @track lmsUpdateIntMsgId;
    @track eNachIntMsgId;
    @track pennyDropIntMsgId;
    chequeInterval;
    paymentId;
    @track firstEmiDate;

    @track paymentTypeDis;
    @track paymentGateWayDis;
    @track paymentRefNumberDis;
    @track transcStatusDis;
    @track paymentRefNumber;
    @track transcStatus;

    @track product;

    @track showTermSheet = false;

    @track updatedFields = [];
    _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);

    }

    @track sessionId;
    @track disableFormDownButton;
    @track DisLoanAggre;
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

    get showSanctionLetterList() {
        this.showGenerateDocumentButton
    }

    generatePicklist(data) {
        if (data.values) {
            return data.values.map(item => ({ label: item.label, value: item.value }))
        }
        return null;
    }

    @wire(getPicklistValuesByRecordType, {
        objectApiName: 'LoanAppl__c',
        recordTypeId: '$loanAppObjectInfo.data.defaultRecordTypeId',
    })
    loanAppPicklistHandler({ data, error }) {
        if (data) {
            console.log('data in loanAppPicklistHandler ', JSON.stringify(data));
            this.remaPfDeductOptions = [...this.generatePicklist(data.picklistFieldValues.RemPFDeductFromDisbursementAmount__c)]
            this.emiOptionsInTrache = [...this.generatePicklist(data.picklistFieldValues.EMIOptionsintranchedisbursementCase__c)]
            this.customerAgreedOptions = [...this.generatePicklist(data.picklistFieldValues.CustomerAgreedonTerms__c)]
            this.insurancePremToBeDedFromDisOptions = [...this.generatePicklist(data.picklistFieldValues.InsPremimtobededfromdisamt__c)];
            this.emiOptTracnDisCase = this.emiOptionsInTrache[0].value;
        }
        if (error) {
            console.error('error im getting picklist values are', error)
        }
    }

    @wire(getObjectInfo, { objectApiName: 'Payment__c' })
    objectInfo;

    @wire(getPicklistValuesByRecordType, {
        objectApiName: 'Payment__c',
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    })
    paymentPicklistHandler({ data, error }) {
        if (data) {
            console.log('data in paymentPicklistHandler', JSON.stringify(data));
            this.paymentTypeOptions = [...this.generatePicklist(data.picklistFieldValues.PaymentType__c)]
            this.paymentGateWayOptions = [...this.generatePicklist(data.picklistFieldValues.Payment_Gaterway__c)]
        }
        if (error) {
            console.error('error im getting picklist values are', error)
        }
    }
    @track repayAccId;

    connectedCallback() {
        this.disableIntiatePennyDrop = true;
        this.disableLmsUpdate = true;
        this.disableLmsUpdateDis = true;
        this.disableFormDownButton = true;
        this.DisLoanAggre = true;
        console.log('formFactor is ', this.formFactor);
        console.log('loanappId is ', this.loanAppId);
        console.log('loanappIdtwo is ', this._loanAppId);
        if (this.formFactor === "Large") {
            this.desktopBoolean = true;
            this.phoneBolean = false;
        } else if (this.formFactor === "Small") {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        } else {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        }
        console.log('layout data in com is ', this.layoutSize);
        debugger
        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }

        if (this.isReadOnly === true) {
            this.disableIntiatePennyDrop = true;
            this.disableLmsUpdate = true;
            this.disableLmsUpdateDis = true;
            this.disableSendLinkToCustmerDis = true;
            this.disableSendLinkToCustmer = true;
            this.disableFormDownButton = true;
            this.DisSignVerButton = true
        }
        this.getLoanAppData();
        this.scribeToMessageChannel();
        this.getInsuranceDetRational();
        this.getLoanAppealData();
        this.checkLoanAppleal();


    }
    @track showMultTracnch = false;
    @track preEmiTypeBool;
    @track disableMode;
    @track loanOwnerId;
    @track stageNew;
    @track subStage;
    @track disablePremityp = false;
    @track schemeID;
    @track isLanBT;
    @track RmOfLAN;
    @track checkDocFieldVal;
    @track showSignVerificaForm;
    getLoanAppData() {
        let paramsLoanApp = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Product__c','SignatureVerificationDocReq__c','Id', 'RM__c', 'AllDocRec__c', 'DocGenReRequired__c', 'SchemeId__c', 'Disbursal_Document_Required__c', 'App_Form_End_Use_Letter_Doc_Required__c', 'PreEmiType__c', 'ApproverName__c', 'RevisedPF__c', 'RevisedROI__c', 'PricingApprovalDate__c', 'Stage__c', 'SubStage__c', 'PricingApprovalApplicable__c', 'InsPremimtobededfromdisamt__c', 'DisbursalType__c', 'EMIOptionsintranchedisbursementCase__c', 'InsAmt__c', 'Total_PF_Amount__c', 'RemPFDeductFromDisbursementAmount__c', 'FirstEMIDate__c', 'Applicant__c', 'CustomerAgreedonTerms__c', 'OwnerId'],
            queryCriteria: ' where Id = \'' + this.loanAppId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Loan application data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.loanApplicationRecord = result.parentRecords[0];
                    this.totdalPFAmt = result.parentRecords[0].Total_PF_Amount__c;
                    this.insAmt = result.parentRecords[0].InsAmt__c;
                    this.remPfDeductFromDisAmtp = result.parentRecords[0].RemPFDeductFromDisbursementAmount__c;
                    this.customerAgreedLoanTermsValue = result.parentRecords[0].CustomerAgreedonTerms__c;
                    this.pricingApprvalAppble = result.parentRecords[0].PricingApprovalApplicable__c;
                    this.approverName = result.parentRecords[0].ApproverName__c;
                    this.revisedPf = result.parentRecords[0].RevisedPF__c;
                    this.revisedRoi = result.parentRecords[0].RevisedROI__c;
                    this.pricingApprovlDt = result.parentRecords[0].PricingApprovalDate__c;
                    this.loanOwnerId = result.parentRecords[0].OwnerId;
                    this.stageNew = result.parentRecords[0].Stage__c;
                    this.subStage = result.parentRecords[0].SubStage__c;
                    this.RmOfLAN = result.parentRecords[0].RM__c;
                    this.schemeID = result.parentRecords[0].SchemeId__c;
                    this.checkDocFieldVal = result.parentRecords[0].DocGenReRequired__c;
                    this.product = result.parentRecords[0].Product__c;
                    if (result.parentRecords[0].DisbursalType__c && result.parentRecords[0].DisbursalType__c == 'MULTIPLE') {
                        this.preEmiTypeBool = 'No';
                        this.preEmiTypVal = 'R';
                        this.disablePremityp = true;
                    } else {
                        if (result.parentRecords[0].PreEmiType__c && result.parentRecords[0].PreEmiType__c === 'C') {
                            this.preEmiTypeBool = 'Yes';
                        } else if (result.parentRecords[0].PreEmiType__c && result.parentRecords[0].PreEmiType__c === 'R') {
                            this.preEmiTypeBool = 'No';
                        }
                        this.disablePremityp = this.isReadOnly;
                    }

                    //For LAK-5262
                    //added for LAK-4257
                    if (this.loanApplicationRecord.Stage__c === 'Post Sanction') {
                        if (this.customerAgreedLoanTermsValue === 'Y') {
                            this.showGenerateDocumentButton = true;
                            this.showDocList = true;

                        } else {
                            this.showGenerateDocumentButton = false;
                        }
                    } else {
                        this.showGenerateDocumentButton = true;
                        this.showDocList = true;
                    }

                    if (this.customerAgreedLoanTermsValue === 'Y') {
                        this.showGenerateDocumentButtonNew = true;
                    } else {
                        this.showGenerateDocumentButtonNew = false;
                    }
                    //added for LAK-4257
                    if (this.insAmt == 0 || this.insAmt == null) {
                        this.disableSendLinkToCustmerDis = true;
                    }
                    if (this.totdalPFAmt == 0 || this.totdalPFAmt == null) {
                        this.disableSendLinkToCustmer = true;
                    }
                    console.log('this.insAmt ', this.insAmt);
                    console.log('this.totdalPFAmt ', this.totdalPFAmt);
                    if (result.parentRecords[0].DisbursalType__c && result.parentRecords[0].DisbursalType__c.toUpperCase() == 'MULTIPLE') {
                        this.showMultTracnch = true;
                    } else {
                        this.showMultTracnch = false;
                    }


                    this.firstEmiDate = result.parentRecords[0].FirstEMIDate__c;
                    if (this.remPfDeductFromDisAmtp) {

                        if (this.remPfDeductFromDisAmtp === 'No') {
                            this.showFormToEnterData = true;
                        } else {
                            this.showFormToEnterData = false;
                        }
                    }

                    if (this.stageNew == 'Post Sanction' && (this.subStage == 'Data Entry' || this.subStage == 'Data Entry Pool')) {
                        if (result.parentRecords[0].Disbursal_Document_Required__c == true) {
                            this.DisLoanAggre = this.isReadOnly === true ? true : false
                        } else {
                            this.DisLoanAggre = true
                        }
                        if (result.parentRecords[0].App_Form_End_Use_Letter_Doc_Required__c == true) {
                            this.disableFormDownButton = this.isReadOnly === true ? true : false
                        } else {
                            this.disableFormDownButton = true
                        }
                        if (result.parentRecords[0].SignatureVerificationDocReq__c == true) {
                            this.DisSignVerButton = this.isReadOnly === true ? true : false
                        } else {
                            this.DisSignVerButton = true
                        }
                        if(result.parentRecords[0].Product__c == 'Business Loan' || result.parentRecords[0].Product__c == 'Personal Loan'){
                            this.showSignVerificaForm=true
                        }

                    } else {
                        this.disableFormDownButton = true;
                        this.DisLoanAggre = true
                        this.DisSignVerButton = true
                    }
                }

                this.getSalesHierMetadat();
                this.getpaymentData();
                this.getSchemeData();
                this.insureDoc();
                this.insureDocGen();
                this.getBreData();
            })
            .catch((error) => {
                console.log('Error In getting loan app Data ', error);
            });
    }
    @track racRoi = 0;
    @track diffinRacRoiANDRevisedRoi = false;

    getBreData() {
        //SELECT Id,RAACROI__c  FROM BRE__c  where IsLatest__c = true AND EligibilityType__c =  'Application'   AND LoanAppl__c =:loanAppid Limit 1];
        let paramsBre = {
            ParentObjectName: 'BRE__c',
            parentObjFields: ['Id', 'RAACROI__c'],
            queryCriteria: ' where LoanAppl__c = \'' + this.loanAppId + '\' AND IsLatest__c = true AND EligibilityType__c =   \'' + 'Application' + '\' Limit 1'
        }
        console.log('getBreData paramsBre', paramsBre);

        getSobjectData({ params: paramsBre })
            .then((result) => {
                console.log('getBreData data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    //{"parentRecords":[{"Id":"a1wC4000000GIc5IAG","RAACROI__c":15.25}]}
                    if (result.parentRecords[0].RAACROI__c) {
                        this.racRoi = result.parentRecords[0].RAACROI__c;
                        if (this.racRoi == this.revisedRoi) {
                            this.diffinRacRoiANDRevisedRoi = false;
                        } else {
                            this.diffinRacRoiANDRevisedRoi = true;
                        }
                    }
                }
                console.log('diffinRacRoiANDRevisedRoi ', this.diffinRacRoiANDRevisedRoi);
            })
            .catch((error) => {
                console.log('Error In getting getBreData Data ', error);
            });
    }

    getSchemeData() {
        let schemenParam = {
            ParentObjectName: 'SchMapping__c',
            parentObjFields: ['Id', 'IsBT__c'],
            queryCriteria: ' where Id = \'' + this.schemeID + '\''
        }
        getSobjectData({ params: schemenParam })
            .then((result) => {
                console.log('SchemeneData', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.isLanBT = result.parentRecords[0].IsBT__c;
                }
                console.log('isLanBT' + this.isLanBT)
            })
            .catch((error) => {
                console.log('Error In getting payment data is ', error);
            });
    }

    getpaymentData() {
        let paymtParam = {
            ParentObjectName: 'Payment__c',
            parentObjFields: ['Id', 'Type__c', 'TransStatus__c ', 'PaymentRefNo__c', 'IntegrationStatus__c', 'FinnoneAppid__c', 'FinnoneChequeId__c', 'PaymentType__c', 'Payment_Gaterway__c', 'PaytmAPIStatus__c'],
            queryCriteria: ' where LoanAppl__c = \'' + this.loanAppId + '\' ORDER BY Createddate DESC'
        }
        getSobjectData({ params: paymtParam })
            .then((result) => {
                console.log('payement data is ## 188', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    result.parentRecords.forEach(item => {
                        if (item.Type__c === 'Charges') {
                            if (item.PaytmAPIStatus__c == 'Success') {
                                this.showTraNew = true;
                                if (item.PaymentType__c && !this.paymentType) {
                                    this.paymentType = item.PaymentType__c;
                                }
                                if (item.Payment_Gaterway__c && !this.paymentGateWay) {
                                    this.paymentGateWay = item.Payment_Gaterway__c;
                                }
                            }
                            if (item.TransStatus__c && item.TransStatus__c === 'Success') {
                                if (!this.paymentIdNew) {
                                    this.paymentIdNew = item.Id;
                                }
                                this.disableSendLinkToCustmer = true;
                                if (item.FinnoneChequeId__c || this.isReadOnly) {
                                    this.disableLmsUpdate = true;
                                } else {
                                    this.disableLmsUpdate = false;
                                }
                                if (item.PaymentType__c && !this.paymentType) {
                                    this.paymentType = item.PaymentType__c;
                                }
                                if (item.Payment_Gaterway__c && !this.paymentGateWay) {
                                    this.paymentGateWay = item.Payment_Gaterway__c;
                                }
                                if (item.PaymentRefNo__c) {
                                    this.paymentRefNumber = item.PaymentRefNo__c;
                                }
                                if (item.TransStatus__c) {
                                    this.transcStatus = item.TransStatus__c;
                                }
                            }
                        } else if (item.Type__c === 'Insurance') {
                            if (item.PaytmAPIStatus__c == 'Success') {
                                this.showTra = true;
                                if (item.PaymentType__c && !this.paymentTypeDis) {
                                    this.paymentTypeDis = item.PaymentType__c;
                                }
                                if (item.Payment_Gaterway__c && !this.paymentGateWayDis) {
                                    this.paymentGateWayDis = item.Payment_Gaterway__c;
                                }
                            }
                            if (item.TransStatus__c && item.TransStatus__c === 'Success') {
                                if (!this.paymentId) {
                                    this.paymentId = item.Id;
                                }
                                this.disableSendLinkToCustmerDis = true;
                                if (item.FinnoneChequeId__c) {
                                    this.disableLmsUpdateDis = true;
                                }
                                else {
                                    this.disableLmsUpdateDis = false;
                                }
                                if (item.PaymentType__c && !this.paymentTypeDis) {
                                    this.paymentTypeDis = item.PaymentType__c;
                                }
                                if (item.Payment_Gaterway__c && !this.paymentGateWayDis) {
                                    this.paymentGateWayDis = item.Payment_Gaterway__c;
                                }
                                if (item.TransStatus__c) {
                                    this.transcStatusDis = item.TransStatus__c;
                                }
                                if (item.PaymentRefNo__c) {
                                    this.paymentRefNumberDis = item.PaymentRefNo__c;
                                }
                            }
                        }
                    })
                }
                this.getActiveRepaymentAcc();
                console.log('disableSendLinkToCustmer in wire method ', this.disableSendLinkToCustmer);
            })
            .catch((error) => {
                console.log('Error In getting payment data is ', error);
            });
    }
    getActiveRepaymentAcc() {
        console.log('loanappId in getActiveRepaymentAcc method', this.loanAppId);
        let paramsLoanApp = {
            ParentObjectName: 'Repayment_Account__c',
            parentObjFields: ['Id', 'AccHolderName__c'],
            queryCriteria: ' where Is_Active__c = true AND Loan_Application__c = \'' + this.loanAppId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Repayment account data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.repayAccData = result.parentRecords[0];
                    console.log('this.repayAccData ', JSON.stringify(this.repayAccData));
                    this.getNachData();
                } else {
                    this.disableIntiatePennyDrop = true;
                }

            })
            .catch((error) => {
                console.log('Error In getting getActiveRepaymentAcc ', error);
            });
    }

    nachData = [];
    getNachData() {
        let paramsLoanApp = {
            ParentObjectName: 'NACH__c',
            parentObjFields: ['Id', 'LoanAppl__c', 'RepayAcc__c', 'eNACH_Registration_Status__c', 'eNACH_Rejection_Reasons__c', 'EnachResponseDateTime__c', 'EnachInitiationDateTime__c'],
            queryCriteria: ' where RepayAcc__c = \'' + this.repayAccData.Id + '\' AND LoanAppl__c = \'' + this.loanAppId + '\' AND IsActive__c = true ORDER BY createddate DESC'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Nach data is', JSON.stringify(result));
                if (result.parentRecords) {
                    this.nachData = result.parentRecords;
                }
                this.getRepayAccVerData();
            })
            .catch((error) => {
                console.log('Error In getting nach data ', error);
            });
    }

    getRepayAccVerData() {
        let paramsLoanApp = {
            ParentObjectName: 'RepayAccVerify__c',
            parentObjFields: ['Id', 'PennyDropStatus__c', 'ErrorMess__c', 'MatchwithAccHolderName__c', 'PennyDropDateTime__c', 'NameRetuFromPennyDrop__c', 'RepayAcc__r.AccHolderName__c', 'RepayAcc__r.Account_Number__c', 'RepayAcc__r.Applicant_Banking__r.Id', 'RepayAcc__r.Applicant_Banking__r.eNACH_feasible__c', 'RepayAcc__r.Applicant_Banking__r.eNACHFeasible__c', 'RepayAcc__r.Applicant_Banking__c'],
            queryCriteria: ' where RepayAcc__c = \'' + this.repayAccData.Id + '\' AND LoanAppl__c = \'' + this.loanAppId + '\' ORDER BY createddate DESC'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                if (result.parentRecords) {
                    console.log('Repayment Account Verification Records Count ', result.parentRecords.length);
                    if (result.parentRecords.length < 3) {
                        this.repayAccVerDqata = result.parentRecords;
                        this.repayAccVerifiLogic();
                    } else {
                        this.repayAccVerDqata = result.parentRecords;
                        this.disableIntiatePennyDrop = true;
                        this.repayAccVerifiLogic();
                    }
                } else {
                    this.disableIntiatePennyDrop = false;
                    if (this.isReadOnly === true) {
                        this.disableIntiatePennyDrop = true;
                        this.disableLmsUpdate = true;
                        this.disableLmsUpdateDis = true;
                        this.disableSendLinkToCustmerDis = true;
                        this.disableSendLinkToCustmer = true;
                        this.repayAccVerDqata.forEach(item => {
                            item.nachButtonVisible = true;
                            item.failureDisable = true;


                        });
                    }
                }

            })
            .catch((error) => {
                console.log('Error In getRepayAccVerData  ', error);
            });
    }
    repayAccVerifiLogic() {
        this.repayAccVerDqata.forEach(item => {
            if (item.MatchwithAccHolderName__c === 'Yes') {
                item.failureDisable = true;
            } else {
                item.failureDisable = false;
            }

            if (item.RepayAcc__r.Applicant_Banking__r && item.RepayAcc__r.Applicant_Banking__r.eNACHFeasible__c && item.RepayAcc__r.Applicant_Banking__r.eNACHFeasible__c === 'Yes' && (item.PennyDropStatus__c === 'Success' || (item.PennyDropStatus__c === 'Failure' && this.product === 'Business Loan'))){ //LAK-7441
                item.showEnach = true;
                item.nachButtonVisible = false;
            } else {
                item.showEnach = true;
                item.nachButtonVisible = true;
            }

            if (item.PennyDropStatus__c == 'Failure') {
                this.resultOfPennyDrop = 'Failure';
            }

            const dateTime1 = new Date(item.PennyDropDateTime__c);
            const formattedDate1 = formattedDateTimeWithoutSeconds(dateTime1);
            const dateOfIntiation1 = `${formattedDate1}`;
            item.PennyDropDateTime__c = dateOfIntiation1;

            console.log('result of Repayment Account Verification is===>>> ', JSON.stringify(this.repayAccVerDqata));
        })
        let count = 0;
        this.repayAccVerDqata.forEach(item => {
            if (item.PennyDropStatus__c === 'Success') {
                count++;
            } else if (item.PennyDropStatus__c === 'Failure') {
                item.errorDisable = true;
                count--;
            }
        })
        if (count > 0) {
            this.disableIntiatePennyDrop = true;
        } else {
            if (this.repayAccVerDqata.length < 3) {
                this.disableIntiatePennyDrop = false;
            } else {
                this.disableIntiatePennyDrop = true;
            }
        }
        //Added ite.eNACH_Registration_Status__c === 'Authentication pending at customer end' fro LAK-8109
        this.repayAccVerDqata.forEach(item => {
            this.nachData.forEach(ite => {
                if (ite.eNACH_Registration_Status__c === 'success' || ite.eNACH_Registration_Status__c === 'register_success' || ite.eNACH_Registration_Status__c === 'Authentication pending at customer end') {
                    item.nachButtonVisible = true;
                }
            })
        })

        if (this.isReadOnly == true) {
            this.disableIntiatePennyDrop = true;
            this.disableLmsUpdate = true;
            this.disableLmsUpdateDis = true;
            this.disableSendLinkToCustmerDis = true;
            this.disableSendLinkToCustmer = true;
            this.repayAccVerDqata.forEach(item => {
                item.nachButtonVisible = true;
                item.failureDisable = true;
            });
        }
    }

    @track salesHierNewArr = [];
    getSalesHierMetadat() {
        let salesLable = 'Sales';
        let paramsLoanApp = {
            ParentObjectName: 'SharingHierarchy__mdt',
            parentObjFields: ['Id', 'BrchRoleSharing__c', 'SupervisoreRoleSharing__c'],
            queryCriteria: ' where DeveloperName  = \'' + salesLable + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('sales hierarchy metadata is', JSON.stringify(result));
                if (result.parentRecords) {
                    let arrayFromString = result.parentRecords[0].BrchRoleSharing__c.split(',');
                    let arrayFromStringNew = result.parentRecords[0].SupervisoreRoleSharing__c.split(',');
                    let setFromArray = new Set([...arrayFromString, ...arrayFromStringNew]);
                    this.salesHierNewArr = Array.from(setFromArray);
                    console.log('this.salesHierNewArr', this.salesHierNewArr);
                    this.getTeamHierarchyData();
                }
            })
            .catch((error) => {
                console.log('Error In getting sales hierarchy details ', error);
            });
    }
    empName
    @track empRole = [];
    @track salesHier = ['RM', 'SM', 'BBH', 'RBH', 'ABH', 'DBH', 'CBO']
    @track showGenDoc = false;
    getTeamHierarchyData() {
        let paramsLoanApp = {
            ParentObjectName: 'TeamHierarchy__c',
            parentObjFields: ['Id', 'Employee__c', 'Employee__r.name', 'EmpRole__c'],
            queryCriteria: ' where Employee__c = \'' + this.userId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('team hierarchy data is', JSON.stringify(result));

                if (result.parentRecords) {
                    this.empRole = result.parentRecords[0].EmpRole__c;
                    this.empName = result.parentRecords[0].Employee__r.Name;
                }
                if (this.empRole) {
                    //LAK-8313
                    /*if (!this.salesHierNewArr.includes(this.empRole) && this.stageNew === 'Post Sanction') {
                        this.showGenDoc = true;
                    } else {
                        this.showGenDoc = false;
                    }*/
                    this.refreshDocTable();
                }

                //TermSheet LAK-161

                //if (this.empRole && !this.salesHierNewArr.includes(this.empRole) && this.stageNew === 'Soft Sanction') {
                if (this.empRole && this.stageNew === 'Soft Sanction') {
                    this.showTermSheet = true;
                    this.showGenDoc = false;
                }
                //else if (this.empRole  && this.stageNew === 'Post Sanction' && !this.salesHierNewArr.includes(this.empRole)) {
                else if (this.empRole && this.stageNew === 'Post Sanction') {
                    this.showGenDoc = true;
                    this.showTermSheet = false;

                }

                //For LAK-6197


                debugger


                if (this.checkDocFieldVal == true) {

                    this.disableMode = !this.hasEditAccess;
                } else {
                    this.disableMode = true;
                }

                //For LAK-6197
            })
            .catch((error) => {
                console.log('Error In getting team hierarchy details ', error);
            });
    }
    handleClick(event) {
        console.log('target name ', event.target.name);
        this.showSpinner = true;
        this.createRepayAccVer();
    }

    createRepayAccVer() {
        if (this.repayAccData) {
            const obje = {
                sobjectType: "RepayAccVerify__c",
                LoanAppl__c: this.loanAppId,
                RepayAcc__c: this.repayAccData ? this.repayAccData.Id : ''
            }
            let newArray = [];
            if (obje) {
                newArray.push(obje);
            }
            if (newArray) {
                upsertMultipleRecord({ params: newArray })
                    .then((result) => {
                        console.log('Result after creating Repayment Account Verification is ', JSON.stringify(result));
                        let fields = {};
                        fields.Name = 'ICICI PennyDrop';
                        fields.Status__c = 'New';
                        fields.Svc__c = 'ICICI PennyDrop';
                        fields.BU__c = 'HL / STL';
                        fields.IsActive__c = true;
                        fields.RefObj__c = 'RepayAccVerify__c';
                        fields.Trigger_Platform_Event__c = true;
                        fields.RefId__c = result[0].Id ? result[0].Id : '';
                        this.createIntMsg(fields, 'Penny Drop');
                    })
                    .catch((error) => {
                        this.showSpinner = false;
                        console.log('Error In creating Record', error);
                        this.showToast('Errpr', 'error', this.label.CustomerConf_RepaymentAcc_ErrorMessage);
                    });
            }
        } else {
            this.showSpinner = false;
            this.showToastMessage('Error', 'Please Add Repayment Account From Banking Details', 'Error', 'sticky');
        }
    }
    handleEnachbutton(event) {
        this.showSpinner = true;
        this.getNachDataNew();
        console.log('record id', event.target.dataset.id);
        console.log('app banking id ', event.target.dataset.appbankid);

    }

    nachDataNew = [];
    getNachDataNew() {
        let paramsLoanApp = {
            ParentObjectName: 'NACH__c',
            parentObjFields: ['Id', 'LoanAppl__c', 'RepayAcc__c', 'eNACH_Registration_Status__c', 'IsActive__c'],
            queryCriteria: ' where RepayAcc__c = \'' + this.repayAccData.Id + '\' AND LoanAppl__c = \'' + this.loanAppId + '\' AND IsActive__c = true ORDER BY createddate DESC'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Nach data is', JSON.stringify(result));
                if (result.parentRecords) {
                    this.nachDataNew = result.parentRecords;
                }
                this.updateNachRec();
            })
            .catch((error) => {
                console.log('Error In getting getActiveRepaymentAcc ', error);
            });
    }

    updateNachRec() {
        let isLatestFalseRecs = []
        isLatestFalseRecs = this.nachDataNew.map(record => {
            return { ...record, IsActive__c: false };
        });
        console.log('isLatestFalseRecs>>>>>' + JSON.stringify(isLatestFalseRecs))
        upsertMultipleRecord({ params: isLatestFalseRecs })
            .then(result => {
                this.createNach();
                console.log('After Updating Nach Records' + JSON.stringify(result));
            }).catch(error => {
                console.log('778' + error)
            })
    }
    createNach() {
        if (this.firstEmiDate) {
            let fields = {};
            fields.sobjectType = 'NACH__c';
            fields.LoanAppl__c = this.loanAppId;
            fields.RepayAcc__c = this.repayAccData.Id ? this.repayAccData.Id : '';
            fields.IsActive__c = true;
            fields.Mandate_Type__c = 'Enach';
            let newArray = [];
            if (fields) {
                newArray.push(fields);
            }
            if (newArray) {
                console.log('nach record ', JSON.stringify(newArray));
                upsertMultipleRecord({ params: newArray })
                    .then((result) => {
                        console.log('Result after creating Nach Record is ', JSON.stringify(result));
                        let fieldNach = {};
                        fieldNach.Name = 'mandate_create_form';
                        fieldNach.Status__c = 'New';
                        fieldNach.Svc__c = 'mandate_create_form';
                        fieldNach.BU__c = 'HL / STL';
                        fieldNach.IsActive__c = true;
                        fieldNach.RefObj__c = 'NACH__c';
                        fieldNach.RefId__c = result[0].Id ? result[0].Id : '';
                        this.createIntMsg(fieldNach, 'Enach');
                    })
                    .catch((error) => {
                        console.log('Error In creating Payment Record ', error);
                        this.showToast('Errpr', 'error', this.label.CustomerConf_Nach_ErrorMessage);
                    });
            }
        } else {
            this.showSpinner = false;
            this.showToast('Error', 'error', this.label.CustomerConf_1stEmi_ErrorMessage);
        }
    }
    handlePaymentChange(event) {
        console.log('value is ', event.target.value, 'name is', event.target.name);
        if (event.target.name === 'Payment_Gaterway__c') {
            this.paymentGateWay = event.target.value;
        } else if (event.target.name === 'PaymentType__c') {
            this.paymentType = event.target.value;
        }

    }

    handlePaymentChangeDisAmt(event) {
        console.log('value is ', event.target.value, 'name is', event.target.name);
        if (event.target.name === 'Payment_Gaterway__c') {
            this.paymentGateWayDis = event.target.value;
        } else if (event.target.name === 'PaymentType__c') {
            this.paymentTypeDis = event.target.value;
        }

    }

    handleSendLinkToCustomer() {
        if (this.paymentType) {
            if (this.paymentGateWay) {
                this.showSpinner = true;
                this.showTraNew = true;
                this.creatPayment();
            } else {
                this.showToast('Error', 'error', this.label.CustomerConf_SelPaymentGateWay_ErrorMessage);
            }
        } else {
            this.showToast('Error', 'error', this.label.CustomerConf_SelPaymentType_ErrorMessage);
        }
    }

    handleSendLinkToCustomerDis() {
        if (this.paymentTypeDis) {
            if (this.paymentGateWayDis) {
                this.showSpinner = true;
                this.showTra = true;
                this.creatPaymentDis();
            } else {
                this.showToast('Error', 'error', 'Please Select Payment GateWay');
            }
        } else {
            this.showToast('Error', 'error', 'Please Select Payment Type');
        }
    }

    creatPaymentDis() {
        let fields = {};
        fields.sobjectType = 'Payment__c';
        fields.LoanAppl__c = this.loanAppId;
        fields.PaymentType__c = this.paymentTypeDis;
        fields.Payment_Gaterway__c = this.paymentGateWayDis;
        fields.TransAmt__c = this.insAmt;
        fields.InstrumentAmt__c = this.insAmt;
        fields.Type__c = 'Insurance';
        let newArray = [];
        if (fields) {
            newArray.push(fields);
        }
        if (newArray) {
            console.log('payemnt record is ', JSON.stringify(newArray));
            upsertMultipleRecord({ params: newArray })
                .then((result) => {
                    console.log('Result after creating payment record is ', JSON.stringify(result));
                    this.paymentId = result[0].Id;
                    let fieldsInt = {};
                    fieldsInt.Name = 'Paytm';
                    fieldsInt.Status__c = 'New';
                    fieldsInt.Svc__c = 'Paytm';
                    fieldsInt.BU__c = 'HL / STL';
                    fieldsInt.IsActive__c = true;
                    fieldsInt.RefObj__c = 'Payment__c';
                    fieldsInt.RefId__c = result[0].Id;
                    this.createIntMsg(fieldsInt, 'paytm');
                })
                .catch((error) => {
                    console.log('Error In creating Payment Record ', error);
                    this.showSpinner = false;
                    this.showToast('Errpr', 'error', this.label.CustomerConf_PaymentRec_ErrorMessage);
                });
        }
    }

    @track paymentIdNew;
    creatPayment() {
        let fields = {};
        fields.sobjectType = 'Payment__c';
        fields.LoanAppl__c = this.loanAppId;
        fields.PaymentType__c = this.paymentType;
        fields.Payment_Gaterway__c = this.paymentGateWay;
        fields.TransAmt__c = this.totdalPFAmt;
        fields.InstrumentAmt__c = this.totdalPFAmt;
        fields.Type__c = 'Charges';
        let newArray = [];
        if (fields) {
            newArray.push(fields);
        }
        if (newArray) {
            console.log('payemnt record is ', JSON.stringify(newArray));
            upsertMultipleRecord({ params: newArray })
                .then((result) => {
                    //Added for Bill Desk Api
                    let serviceName;
                    if (this.paymentGateWay && this.paymentGateWay === 'Paytm') {
                        serviceName = 'Paytm';
                    } else if (this.paymentGateWay && this.paymentGateWay === 'Bill Desk') {
                        serviceName = 'Bill Desk';
                    }
                    //Endec changes for Bill Desk Api
                    console.log('Result after creating payment record is ', JSON.stringify(result));
                    this.paymentIdNew = result[0].Id;
                    let fieldsInt = {};
                    fieldsInt.Name = serviceName;
                    fieldsInt.Status__c = 'New';
                    fieldsInt.Svc__c = serviceName;
                    fieldsInt.BU__c = 'HL / STL';
                    fieldsInt.IsActive__c = true;
                    fieldsInt.RefObj__c = 'Payment__c';
                    fieldsInt.RefId__c = result[0].Id;
                    this.createIntMsgNew(fieldsInt, 'paytm');
                })
                .catch((error) => {
                    console.log('Error In creating Payment Record ', error);
                    this.showToast('Errpr', 'error', 'Error creating Payment record');
                });
        }
    }
    handleLmsUpdateDis() {
        if (this.paymentIdNew) {
            this.showSpinner = true;
            let fieldsInt = {};
            fieldsInt.Name = 'IMD CHARGES';
            fieldsInt.Status__c = 'New';
            fieldsInt.Svc__c = 'IMD';
            fieldsInt.BU__c = 'HL / STL';
            fieldsInt.IsActive__c = true;
            fieldsInt.RefObj__c = 'Payment__c';
            fieldsInt.RefId__c = this.paymentIdNew;
            fieldsInt.ParentRefObj__c = 'LoanAppl__c';
            fieldsInt.ParentRefId__c = this.loanAppId;
            this.createIntMsgNew(fieldsInt, 'Sequence API');
        }
    }
    @track paytmIntMsgIdDis;
    @track lmsUpdateIntMsgIdDis;
    createIntMsgNew(fieldsInt, name) {
        const recordInput = {
            apiName: 'IntgMsg__c',
            fields: fieldsInt
        };
        createRecord(recordInput).then((result) => {
            console.log('Paytm Integration Record Created ##405', result.id, result);
            if (name === 'paytm') {
                this.paytmIntMsgIdDis = result.id;
                this.startPollingNew('paytm');
            } else if (name === 'Sequence API') {
                this.lmsUpdateIntMsgIdDis = result.id;
                this.startPollingNew('Sequence API');
            }
        }).catch((error) => {
            this.showSpinner = false
            console.log('Error ##789', error);
            this.showToast('Errpr', 'error', this.label.CustomerConf_PlatformEvent_ErrorMessage);
        });
    }

    @track chequeIntervalNew;
    startPollingNew(name) {
        console.log('Polling has started ##875')
        this.chequeIntervalNew = setInterval(() => {
            this.getIntRecordNew(name);
        }, 5000);
    }

    getIntRecordNew(name) {
        let paramsLoanApp;
        if (name === 'paytm') {
            paramsLoanApp = {
                ParentObjectName: 'IntgMsg__c',
                parentObjFields: ['Id', 'Status__c', 'Name'],
                queryCriteria: ' where Id = \'' + this.paytmIntMsgIdDis + '\''
            }
        } else if (name === 'Sequence API') {
            paramsLoanApp = {
                ParentObjectName: 'IntgMsg__c',
                parentObjFields: ['Id', 'Status__c', 'Name'],
                queryCriteria: ' where Id = \'' + this.lmsUpdateIntMsgIdDis + '\''
            }
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Int Msg data is', JSON.stringify(result));
                if (result.parentRecords[0].Status__c === 'Responded' && result.parentRecords[0].Name === 'Paytm') {
                    this.disableSendLinkToCustmer = true;
                    clearInterval(this.chequeIntervalNew);
                    console.log('Cleared ##468')
                    this.getPaymentRecordDataNew();
                }
                if (result.parentRecords[0].Status__c === 'Exception' && result.parentRecords[0].Name === 'Paytm') {
                    this.disableSendLinkToCustmer = false;
                    this.disableLmsUpdate = true;
                    this.showSpinner = false;
                    this.showToast('Error', 'error', this.label.CustomerConf_Integration_ErrorMessage);
                    clearInterval(this.chequeIntervalNew);
                    console.log('Cleared ##468')
                }
                //Added for Bill Desk Api
                if (result.parentRecords[0].Status__c === 'Responded' && result.parentRecords[0].Name === 'Bill Desk') {
                    this.disableSendLinkToCustmer = true;
                    clearInterval(this.chequeIntervalNew);
                    console.log('Cleared ##468')
                    this.getPaymentRecordDataNew();
                }
                if (result.parentRecords[0].Status__c === 'Exception' && result.parentRecords[0].Name === 'Bill Desk') {
                    this.disableSendLinkToCustmer = false;
                    this.disableLmsUpdate = true;
                    this.showSpinner = false;
                    this.showToast('Error', 'error', this.label.CustomerConf_Integration_ErrorMessage);
                    clearInterval(this.chequeIntervalNew);
                    console.log('Cleared ##468')
                }
                //Endec changes for Bill Desk Api
                if (result.parentRecords[0].Status__c === 'Responded' && result.parentRecords[0].Name === 'IMD CHARGES') {
                    this.disableLmsUpdate = true;
                    this.showSpinner = false;
                    this.showToast('Success', 'success', 'Integration is Successful');
                    clearInterval(this.chequeIntervalNew);
                    console.log('Cleared ##473');
                }
                if (result.parentRecords[0].Status__c === 'Exception' && result.parentRecords[0].Name === 'IMD CHARGES') {
                    this.disableLmsUpdate = false;
                    this.showSpinner = false;
                    this.showToast('Error', 'error', 'Integration is failed, Please Retry Again');
                    clearInterval(this.chequeIntervalNew);
                    console.log('Cleared ##473');
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Int Msg Record ', error);
            });
    }
    getPaymentRecordDataNew() {
        let paramsLoanApp = {
            ParentObjectName: 'Payment__c',
            parentObjFields: ['Id', 'TransStatus__c', 'PaymentRefNo__c', 'PaytmAPIStatus__c', 'PaytmAPIMessage__c'],
            queryCriteria: ' where Id = \'' + this.paymentIdNew + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('payment data data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    if (result.parentRecords[0].PaytmAPIStatus__c == 'Success') {
                        this.showToast('Success', 'success', this.label.CustomerConf_Integration_SuccessMessage);
                        this.paymentRefNumber = result.parentRecords[0].PaymentRefNo__c;
                        this.transcStatus = result.parentRecords[0].TransStatus__c;
                        if (this.paymentRefNumber) {
                            this.disableLmsUpdate = false;
                        }
                    } else {
                        this.showToast('Error', 'error', result.parentRecords[0].PaytmAPIMessage__c);
                    }
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting payment Record ', error);
            });
    }

    handleLmsUpdate() {
        this.showSpinner = true;
        let fieldsInt = {};
        fieldsInt.Name = 'Sequence API';
        fieldsInt.Status__c = 'New';
        fieldsInt.Svc__c = 'Sequence API';
        fieldsInt.BU__c = 'HL / STL';
        fieldsInt.IsActive__c = true;
        fieldsInt.RefObj__c = 'Payment__c';
        fieldsInt.RefId__c = this.paymentId;
        this.createIntMsg(fieldsInt, 'Sequence API');
    }
    createIntMsg(fieldsInt, name) {
        const recordInput = {
            apiName: 'IntgMsg__c',
            fields: fieldsInt
        };
        createRecord(recordInput).then((result) => {
            console.log('Paytm Integration Record Created ##405', result.id, result);
            if (name === 'paytm') {
                this.paytmIntMsgId = result.id;
                this.startPolling('paytm');
            } else if (name === 'Sequence API') {
                this.lmsUpdateIntMsgId = result.id;
                this.startPolling('Sequence API');
            } else if (name === 'Enach') {
                this.eNachIntMsgId = result.id;
                this.startPolling('Enach');
            }
            else if (name === 'Penny Drop') {
                this.pennyDropIntMsgId = result.id;
                this.callSubscribePlatformEve();
            }
        }).catch((error) => {
            this.showSpinner = false
            console.log('Error ##789', error);
            this.showToast('Errpr', 'error', this.label.CustomerConf_PlatformEvent_ErrorMessage);
        });
    }

    startPolling(name) {
        console.log('Polling has started ##875')
        this.chequeInterval = setInterval(() => {
            this.getIntRecord(name);
        }, 5000);
    }

    getIntRecord(name) {
        let paramsLoanApp;
        if (name === 'paytm') {
            paramsLoanApp = {
                ParentObjectName: 'IntgMsg__c',
                parentObjFields: ['Id', 'Status__c', 'Name'],
                queryCriteria: ' where Id = \'' + this.paytmIntMsgId + '\''
            }
        } else if (name === 'Sequence API') {
            paramsLoanApp = {
                ParentObjectName: 'IntgMsg__c',
                parentObjFields: ['Id', 'Status__c', 'Name'],
                queryCriteria: ' where Id = \'' + this.lmsUpdateIntMsgId + '\''
            }
        } else if (name === 'Enach') {
            paramsLoanApp = {
                ParentObjectName: 'IntgMsg__c',
                parentObjFields: ['Id', 'Status__c', 'Name', 'APIStatus__c'],
                queryCriteria: ' where Id = \'' + this.eNachIntMsgId + '\''
            }
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Int Msg data is', JSON.stringify(result));
                if (result.parentRecords[0].Status__c === 'Responded' && result.parentRecords[0].Name === 'Paytm') {
                    this.disableSendLinkToCustmerDis = true;
                    this.showToast('Success', 'success', this.label.CustomerConf_Integration_SuccessMessage);
                    clearInterval(this.chequeInterval);
                    console.log('Cleared ##468')
                    this.getPaymentRecordData();
                }
                if (result.parentRecords[0].Status__c === 'Exception' && result.parentRecords[0].Name === 'Paytm') {
                    this.disableSendLinkToCustmerDis = false;
                    this.disableLmsUpdateDis = true;
                    this.showSpinner = false;
                    this.showToast('Error', 'error', this.label.CustomerConf_Integration_ErrorMessage);
                    clearInterval(this.chequeInterval);
                    console.log('Cleared ##468')
                }
                if (result.parentRecords[0].Status__c === 'Responded' && result.parentRecords[0].Name === 'Sequence API') {
                    this.disableLmsUpdate = true;
                    this.disableLmsUpdateDis = true;
                    this.showSpinner = false;
                    this.showToast('Success', 'success', 'Integration is Successful');
                    clearInterval(this.chequeInterval);
                    console.log('Cleared ##473');
                }
                if (result.parentRecords[0].Status__c === 'Exception' && result.parentRecords[0].Name === 'Sequence API') {
                    this.disableLmsUpdate = false;
                    this.disableLmsUpdateDis = false;
                    this.showSpinner = false;
                    this.showToast('Error', 'error', 'Integration is failed, Please Retry Again');
                    clearInterval(this.chequeInterval);
                    console.log('Cleared ##473');
                }
                if (result.parentRecords[0].Status__c === 'Responded' && result.parentRecords[0].Name === 'mandate_create_form') {
                    this.showSpinner = false;
                    this.getNachData();
                    this.showToast('Success', 'success', 'Integration is Successful');
                    if (result.parentRecords[0].APIStatus__c === 'Success'){
                        this.showToast('Success', 'success', this.label.CustomerConf_SendEnach_SuccessMessage);
                    }
                    else if (result.parentRecords[0].APIStatus__c === 'Failure'){
                        this.showToast('Error', 'error', this.label.CustomerConf_SendEnach_ErrorMessage);
                    }
                    clearInterval(this.chequeInterval);
                    console.log('Cleared ##473');
                }
                if (result.parentRecords[0].Status__c === 'Exception' && result.parentRecords[0].Name === 'mandate_create_form') {
                    this.showSpinner = false;
                    this.showToast('Error', 'error', 'Integration is failed, Please Retry Again');
                    clearInterval(this.chequeInterval);
                    console.log('Cleared ##473');
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Int Msg Record ', error);
            });
    }

    getPaymentRecordData() {
        let paramsLoanApp = {
            ParentObjectName: 'Payment__c',
            parentObjFields: ['Id', 'TransStatus__c', 'PaymentRefNo__c', 'PaytmAPIStatus__c', 'PaytmAPIMessage__c'],
            queryCriteria: ' where Id = \'' + this.paymentId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('payment data data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    if (result.parentRecords[0].PaytmAPIStatus__c == 'Success') {
                        this.showToast('Success', 'success', this.label.CustomerConf_Integration_SuccessMessage);
                        this.paymentRefNumberDis = result.parentRecords[0].PaymentRefNo__c;
                        this.transcStatusDis = result.parentRecords[0].TransStatus__c;
                        if (this.paymentRefNumberDis) {
                            this.disableLmsUpdateDis = false;
                        }
                    } else {
                        this.showToast('Error', 'error', result.parentRecords[0].PaytmAPIMessage__c);
                    }
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting payment Record ', error);
            });
    }

    handleLoanPickChange(event) {
        console.log(' value is #568===> ', event.target.value);
        if (event.target.name === 'RemPFDeductFromDisbursementAmount__c') {
            this.remPfDeductFromDisAmtp = event.target.value
            let val = event.target.value;
            if (val === 'No') {
                this.showFormToEnterData = true;
            } else {
                this.showFormToEnterData = false;
            }
            console.log('remPfDeductFromDisAmtp value is ', this.remPfDeductFromDisAmtp);
        }
        else if (event.target.name === 'EMIOptionsintranchedisbursementCase__c') {
            this.emiOptTracnDisCase = event.target.value
            console.log('emiOptTracnDisCase value is ', this.emiOptTracnDisCase);
        } else if (event.target.name === 'CustomerAgreedonTerms__c') {

            if (this.loanApplicationRecord.Stage__c == 'Post Sanction') {
                if (event.target.value === 'Y') {
                    this.showGenerateDocumentButton = true;
                } else {

                    this.showGenerateDocumentButton = false
                }
            }
            if (event.target.value === 'Y') {
                this.showGenerateDocumentButtonNew = true;
            } else {

                this.showGenerateDocumentButtonNew = false
            }
            this.customerAgreedLoanTermsValue = event.target.value;
        }

    }


    handlePreEmiTypeChange(event) {
        if (event.target.value == 'Yes') {
            this.preEmiTypVal = 'C';
        } else if (event.target.value == 'No') {
            this.preEmiTypVal = 'R';
        }
        console.log('Pre-EMI to be deducted from disbursement ', event.target.value);
        console.log('preEmiTypVal ', this.preEmiTypVal);
    }
    handlePicklistValues(event) {
        let val = event.detail.val;
        let selectedRecordId = event.detail.recordid;
        let nameVal = event.detail.nameVal;
        console.log('val is in dedupeverification ', val, 'selectedRecordId is ', selectedRecordId, ' name is ', nameVal);
        let obj = this.repayAccVerDqata.find(item => item.Id === selectedRecordId);
        if (obj) {
            console.log('obj is ', JSON.stringify(obj));
            obj[nameVal] = val;
            obj.isChanged = true;
            console.log('this.repayAccVerDqata ', JSON.stringify(this.repayAccVerDqata));
            if (val === 'Yes') {
                //LAK-7441
                obj.nachButtonVisible = false;
            } else if (val === 'No') {
                //LAK-7441
                obj.nachButtonVisible = true;
                this.showToastMessage('Error', this.label.CustomerConf_Appeal_ErrorMessage, 'Error', 'sticky')
            }
        }

    }
    showToast(titleVal, variantVal, messageVal) {
        const evt = new ShowToastEvent({
            title: titleVal,
            variant: variantVal,
            message: messageVal
        });
        this.dispatchEvent(evt);
    }
    callSubscribePlatformEve() {
        //Commnet platform event subscription temproroly
        this.handleSubscribe();
    }
    PEsubscription;
    @track noIntResponec = true;
    handleSubscribe() {
        const self = this;
        this.showSpinner = true;
        this.cometdlib = new window.org.cometd.CometD();
        console.log('cometdlib  value ', this.cometdlib);

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
            console.log('noIntResponec ', self.noIntResponec);
            self.noIntResponec = true;
            // self.startTimerForTimeout(tot);
            if (status.successful) {
                console.log('Successfully connected to server');
                self.PEsubscription = self.cometdlib.subscribe(self.channelName, (message) => {
                    console.log('subscribed to message!', JSON.stringify(message));
                    console.log(message.data.payload);
                    self.handlePlatformEventResponce(message.data.payload);

                },
                    (error) => {
                        this.showSpinner = false;
                        console.log('Error In Subscribing ', error);
                    }
                );
                console.log(window.location.protocol + '//' + window.location.hostname + '/cometd/50.0/',);
            } else {

                /// Cannot handshake with the server, alert user.
                console.error('Error in handshaking: ' + JSON.stringify(status));
                this.showSpinner = false;
            }
        });
        console.log('SUBSCRIPTION ENDED');
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

        }

    }

    handlePlatformEventResponce(payload) {
        console.log('responce From PlatformEvent ', payload);
        if (payload) {
            if (payload.SvcName__c === 'ICICI PennyDrop') {
                if (payload.IntMsgId__c === this.pennyDropIntMsgId && payload.Success__c) {
                    this.disableIntiatePennyDrop = true;
                    this.getNachData();
                    this.showSpinner = false;
                    this.showToast('Success', 'success', this.label.CustomerConf_pennyDrop_SuccessMessage);
                } else {
                    this.getNachData();
                    this.showSpinner = false;
                    this.showToast('Error', 'error', this.label.CustomerConf_PennyDrop_ErrorMessage);
                }
            } else if (payload.SvcName__c === 'Enach status') {
                if (payload.RecId__c === this.eNachIntMsgId && payload.Success__c) {
                    this.getNachData();
                    this.showSpinner = false;
                    this.showToast('Success', 'success', this.label.CustomerConf_Enach_SuccessMessage);
                } else {
                    this.showSpinner = false;
                    this.showToast('Error', 'error', this.label.CustomerConf_Enach_ErrorMessage);
                }
            }
            this.handleUnsubscribe();
        } else {
            this.showSpinner = false;
        }

    }



    handleIntializationPD(event) {
        //will come 
        console.log('value', event.target.value);
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
        console.log('values to save through Lms ', JSON.stringify(values));
        this.handlevSubmit(values.validateBeforeSave);

    }
    handlevSubmit(validate) {
        if (validate) {
            let valid = this.validateForm(); //LAK-7917
            console.log('valid ', valid);
            if (valid) { //LAK-7917
                this.showSpinner = true;
                this.getApplicantDetails('save');
            } else { //LAK-7917
                this.showToastMessage('Error', 'Required Fields are missing', 'Error', 'sticky'); //LAK-7917
            } //LAK-7917
        }
    }

    //Added for LAK-7917
    validateForm() {
        let isValid = true;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed');
            } else {
                isValid = false;
            }
        });

        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed');
            } else {
                console.log('this.paymentType ', this.paymentType);
                console.log(' this.paymentGateWay ', this.paymentGateWay);
                isValid = false;
            }

        });
        return isValid;
    }

    handleSave() {
        let newArray = [];
        this.updatedFields = [];
        let fields = {};
        fields.sobjectType = 'LoanAppl__c';
        fields.Id = this.loanAppId;
        fields.RemPFDeductFromDisbursementAmount__c = this.remPfDeductFromDisAmtp;
        if (this.showMultTracnch) {
            fields.EMIOptionsintranchedisbursementCase__c = this.emiOptTracnDisCase;
        }
        fields.CustomerAgreedonTerms__c = this.customerAgreedLoanTermsValue;
        fields.InsPremimtobededfromdisamt__c = this.insurancePremToBeDedFromDisAmtValue;
        fields.PreEmiType__c = this.preEmiTypVal;
        this.updatedFields.push(fields);
        console.log('this.updatedFields before adding table data ', JSON.stringify(this.updatedFields));
        let filterData = this.repayAccVerDqata.filter(item => item.isChanged === true);
        console.log('filterData is ', JSON.stringify(filterData));
        if (filterData) {
            //LAK-7956
            filterData.forEach(item => {
                delete item.PennyDropDateTime__c;
            });
            //LAK-7956
            console.log('filterData after is ', JSON.stringify(filterData));
            newArray = [...filterData, ...this.updatedFields];
        }
        if (newArray) {
            console.log('this.updatedFields ', JSON.stringify(newArray));
            upsertMultipleRecord({ params: newArray })
                .then((result) => {
                    console.log('Result after Updating Records is ', JSON.stringify(result));
                    this.showToast('Success', 'success', this.label.CustomerConf_Save_SuccessMessage);
                    this.getRepayAccVerData();
                    this.getLoanAppData();
                    this.updatedFields = [];
                    this.showSpinner = false;
                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log('Error In Updating Record', error);
                    this.showToast('Error', 'error', this.label.CustomerConf_Update_ErrorMessage);
                });
        }
    }



    //******************FOR HANDLING THE HORIZONTAL SCROLL OF TABLE MANUALLY******************//
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

    //******************************* RESIZABLE COLUMNS *************************************//
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
        console.log("handlemousedown._tableThColumn.tagName => ", this._tableThColumn.tagName);
        this._pageX = e.pageX;

        this._padding = this.paddingDiff(this._tableThColumn);

        this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
        console.log("handlemousedown._tableThColumn.tagName => ", this._tableThColumn.tagName);
    }

    handlemousemove(e) {
        console.log("mousemove._tableThColumn => ", this._tableThColumn);
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
    @track nachDocId;
    @track adharLetterIds = [];
    async handleGenerateDocuments(docCategory, docType, docSubType, status) {
        try {
            // this.showSpinner = true;

            const result = await createDocumentDetail({
                applicantId: this.loanApplicationRecord.Applicant__c,
                loanAppId: this.loanApplicationRecord.Id,
                docCategory: docCategory,
                docType: docType,
                docSubType: docSubType,
                availableInFile: false
            });

            console.log('createDocumentDetailRecord result ', result);
            this.DocumentDetaiId = result;

            console.log('createDocumentDetailRecord DocumentDetaiId ', this.DocumentDetaiId);
            console.log('createDocumentDetailRecord DocumentDetaiId ', this.DocumentDetaiId);
            let customlabel = ''
            if (docSubType == 'Power Of Attonrny' || docSubType == 'Declaration of Loan Agreement' || docSubType == 'Signature Verification Form' || docSubType == 'End Use Letter' || docSubType == 'Application Form' || docSubType == 'Loan Agreement' || docSubType == 'Aadhaar Consent' || docSubType == 'End Use, Pre EMI and PF Deduction Letter' || docSubType == 'PF Deduction Letter' || docSubType == 'Interest Bearing Letter' || docSubType == 'Sanction Letter & KFS Document' || docSubType == 'BT Draft Part 2' || docSubType == 'BT Draft Part 1' || docSubType == 'BT Draft Part 1' || docSubType == 'DPN Document') {
                customlabel = await this.getCustomLabelValueForForm(docSubType);
            }
            else {
                customlabel = await this.getCustomLabelValue(status);
            }
            //let customlabel = await this.getCustomLabelValue(status);
            //let pageUrl = '';

            /*if (docSubType == 'Aadhaar Consent') {
                pageUrl = customlabel + status;
                this.adharLetterIds.push(this.DocumentDetaiId)
            } else {
                pageUrl = customlabel + this.loanApplicationRecord.Id;
            }*/
            let pageUrl = customlabel + this.loanApplicationRecord.Id;
            console.log('pageUrlpageUrl' + pageUrl);
            const pdfData = {
                pageUrl: pageUrl,
                docDetailId: this.DocumentDetaiId,
                fileName: `${docType}.pdf`
            };
            console.log('afterurl')
            this.generateDocumentForSanc(pdfData, docCategory, docType, docSubType, this.DocumentDetaiId);
        } catch (err) {
            this.showToast("Error", "error", this.label.CustomerConf_DocDetail_ErrorMessage);
            console.log(" createDocumentDetailRecord error===", err);
        }
    }

    generateDocumentForSanc(pdfData, docCat, docTyp, docSubTyp, docId) {
        generateDocument({ wrapObj: pdfData })
            .then((result) => {
                this.showSpinner = false;
                if (result == 'success') {
                    console.log('insucessss' + docSubTyp)
                    this.forLatestDocDetailRecForSanc(docCat, docTyp, docSubTyp, docId);
                } else {
                    console.log(result);
                }
            })
            .catch((err) => {
                this.showToast("Error", "error", "Error occured in creation document detail For Sanction letter " + err);
                console.log(" createDocumentDetailRecord error for sanction letter ===", err);
            });
    }
    forLatestDocDetailRecForSanc(docCat, docTyp, docSubTyp, docId) {
        console.log('document details in forLatestDocDetailRec ###1456', docTyp, docCat, docSubTyp, docId);

        let listOfAllParent = [];
        let paramForIsLatest = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'Appl__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c'],
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this.loanApplicationRecord.Id + '\' AND Appl__c = \'' + this.loanApplicationRecord.Applicant__c + '\' AND DocCatgry__c = \'' + docCat + '\' AND DocTyp__c = \'' + docTyp + '\' AND DocSubTyp__c = \'' + docSubTyp + '\''
        }
        if (docSubTyp == 'Interest Bearing Letter') {
            paramForIsLatest.queryCriteria = ' where IsLatest__c = true AND LAN__c = \'' + this.loanApplicationRecord.Id + '\'  AND DocCatgry__c = \'System Generated Documents\' AND DocTyp__c = \'Disbursal Documents\' AND DocSubTyp__c = \'Interest Bearing Letter\''
        }
        getSobjectData({ params: paramForIsLatest })
            .then((result) => {
                console.log('islatestdata 13899999', docId);
                console.log('isLatestFalseRecs>>>>>' + JSON.stringify(result))
                if (result.parentRecords) {
                    listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
                    let oldRecords = []
                    if (docSubTyp == 'Aadhaar Consent') {
                        oldRecords = listOfAllParent.filter(record => !this.adharLetterIds.includes(record.Id));
                    } else {
                        oldRecords = listOfAllParent.filter(record => record.Id !== docId);
                    }
                    let isLatestFalseRecs = []
                    isLatestFalseRecs = oldRecords.map(record => {
                        return { ...record, IsLatest__c: false };
                    });
                    upsertMultipleRecord({ params: isLatestFalseRecs })
                        .then(result => {

                            if (docSubTyp == 'End Use Letter' || docSubTyp == 'Application Form' || docSubTyp == 'Loan Agreement' || docSubTyp == 'Aadhaar Consent' || docSubTyp == 'End Use, Pre EMI and PF Deduction Letter' || docSubTyp == 'PF Deduction Letter' || docSubTyp == 'Interest Bearing Letter' || docSubTyp == 'BT Draft Part 2' || docSubTyp == 'BT Draft Part 1' || docSubTyp == 'BT Draft Part 1' || docSubTyp == 'DPN Document' || docSubTyp == 'Declaration of Loan Agreement' || docSubTyp == 'Power Of Attonrny') {
                                this.showSpinner = false;
                                setTimeout(() => {
                                    this.refreshDocTable();
                                }, 600);
                            }
                            else if (this.stage && this.stage == 'Post Sanction') {
                                this.handleGenerateDocForNach();
                            }
                            else if (this.stageNew && this.stageNew == 'Soft Sanction') {
                                this.showSpinner = false;
                                this.refreshDocTable();
                            } else {
                                this.updateLoanAppDocGenDtTimeMethod();
                            }

                        }).catch(error => {

                        })
                } else {
                    if (this.stage && this.stage == 'Post Sanction') {
                        this.handleGenerateDocForNach();
                    } else {
                        this.updateLoanAppDocGenDtTimeMethod();
                    }
                }
            })
            .catch((error) => {
                console.log('Error In 1841 ', error);
            });
    }
    async handleGenerateDocForNach() {
        this.nachDocId = await this.createNachDocDtlRec();
        console.log('nachDocId ', this.nachDocId);
        let pageUrlNach = this.label.PageURLNACHForm + this.repayAccData.Id
        const pdfDataNach = {
            pageUrl: pageUrlNach,
            docDetailId: this.nachDocId,
            fileName: 'NACH Form.pdf'
        }
        this.generateDocumentForNach(pdfDataNach, 'NACH Form', 'NACH Form', 'NACH Form', this.nachDocId);
    }
    generateDocumentForNach(pdfData, docCat, docTyp, docSubTyp, docId) {
        generateDocument({ wrapObj: pdfData })
            .then((result) => {
                this.showSpinner = false;
                if (result == 'success') {
                    this.forLatestDocDetailRecForNach(docCat, docTyp, docSubTyp, docId);
                } else {
                    console.log(result);
                }
            })
            .catch((err) => {
                this.showToast("Error", "error", "Error occured in creation document detail " + err);
                console.log(" createDocumentDetailRecord error===", err);
            });
    }
    forLatestDocDetailRecForNach(docCat, docTyp, docSubTyp, docId) {
        console.log('document details in forLatestDocDetailRec ###1456', docTyp, docCat, docSubTyp, docId);
        let listOfAllParent = [];
        let paramForIsLatest = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'Appl__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c'],
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this.loanApplicationRecord.Id + '\' AND Appl__c = \'' + this.loanApplicationRecord.Applicant__c + '\' AND DocCatgry__c = \'' + docCat + '\' AND DocTyp__c = \'' + docTyp + '\' AND DocSubTyp__c = \'' + docSubTyp + '\''
        }
        getSobjectData({ params: paramForIsLatest })
            .then((result) => {
                console.log('islatestdata 13899999', docId);
                if (result.parentRecords) {
                    listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))

                    let oldRecords = []
                    oldRecords = listOfAllParent.filter(record => record.Id !== docId);
                    let isLatestFalseRecs = []
                    isLatestFalseRecs = oldRecords.map(record => {
                        return { ...record, IsLatest__c: false };
                    });
                    console.log('isLatestFalseRecs>>>>>' + JSON.stringify(isLatestFalseRecs))
                    upsertMultipleRecord({ params: isLatestFalseRecs })
                        .then(result => {
                            console.log('resultresultresultresultresult' + JSON.stringify(result));
                            if (docSubTyp == 'End Use Letter' || docSubTyp == 'Application Form' || docSubTyp == 'Loan Agreement' || docSubTyp == 'Power Of Attonrny' || docSubTyp == 'Declaration of Loan Agreement' || docSubTyp == 'Aadhaar Consent' || docSubTyp == 'End Use, Pre EMI and PF Deduction Letter' || docSubTyp == 'PF Deduction Letter' || docSubTyp == 'Interest Bearing Letter' || docSubTyp == 'BT Draft Part 2' || docSubTyp == 'BT Draft Part 1' || docSubTyp == 'BT Draft Part 1' || docSubTyp == 'DPN Document' ) {
                                this.refreshDocTable();
                            }
                            else if (this.stage && this.stage == 'Post Sanction') {
                                this.updateLoanAppDocGenDtTimeMethod();
                            } else {
                                this.refreshDocTable();
                            }

                        }).catch(error => {
                            console.log('778' + error);

                        })
                } else {
                    if (this.stage && this.stage == 'Post Sanction') {
                        this.updateLoanAppDocGenDtTimeMethod();
                    } else {
                        this.refreshDocTable();
                    }
                }
            })
            .catch((error) => {
                console.log('Error In getting 1961 ', error);
            });
    }
    createNachDocDtlRec() {
        return new Promise((resolve, reject) => {
            createDocumentDetail({ applicantId: this.loanApplicationRecord.Applicant__c, loanAppId: this.loanApplicationRecord.Id, docCategory: 'NACH Form', docType: 'NACH Form', docSubType: 'NACH Form', availableInFile: false })
                .then((result) => {
                    console.log('createDocumentDetailRecord result ', result);
                    let nachDocDtlId = result;
                    resolve(nachDocDtlId);
                })
                .catch((err) => {
                    this.showToast("Error", "error", this.label.CustomerConf_DocDetail_ErrorMessage);
                    console.log(" createDocumentDetailRecord error===", err);
                    reject(err);
                });
        });
    }

    saveLoanDetails(docCategory, docType, docSubType, status) {
        this.showSpinner = true;
        this.showDocList = false;
        //  this.handleGenerateDocuments(docCategory, docType, docSubType, status);
        console.log('saveLoanDetails' + saveLoanDetails)
        this.handleGenerateDocuments('System Generated Documents', 'Sanction Letter & KFS Document', 'Sanction Letter & KFS Document', '');
        this.updateLoanAppDocGenDtTimeMethod();


    }

    async getCustomLabelValue(status) {

        if (status === 'Soft Sanction') {
            return this.label.termSheet;
        }
        return this.label.sanctionLetter;

    }
    async getCustomLabelValueForForm(typeOfDoc) {

        if (typeOfDoc === 'Application Form') {
            return this.label.applicationFormForFedFina;
        } else if (typeOfDoc === 'End Use Letter') {
            return this.label.EndUserLetter;
        } else if (typeOfDoc === 'Aadhaar Consent') {
            return this.label.adharConsentLetter;
        } else if (typeOfDoc === 'Power Of Attonrny') {
            return this.label.PowerOfAttonrny;
        }
        else if (typeOfDoc === 'Declaration of Loan Agreement') {
            return this.label.DeclarationOfLoanAgreement;
        }
        else if (typeOfDoc === 'Loan Agreement') {
            if(this.showSignVerificaForm){
                return this.label.loanAgreementForPLAndBL;
            }else{
                return this.label.getLoanAgreementURL;
            }
        }
        else if (typeOfDoc === 'Interest Bearing Letter') {
            return this.label.InterestBearingLetterURL;
        } else if (typeOfDoc === 'PF Deduction Letter') {
            return this.label.PFDeductionLetterURL;
        } else if (typeOfDoc === 'End Use, Pre EMI and PF Deduction Letter') {
            return this.label.PreEmiDeductionLetterURL;
        } else if (typeOfDoc === 'Sanction Letter & KFS Document') {
            console.log('typeOfDoc' + typeOfDoc)
            return this.label.getKFSDocLink;
        } else if (typeOfDoc === 'BT Draft Part 2') {
            return this.label.GetBTDraftLinkPart2;
        } else if (typeOfDoc === 'BT Draft Part 1') {
            console.log('typeOfDoc' + typeOfDoc)
            return this.label.GetBTDraftLinkPart1;
        } else if (typeOfDoc === 'DPN Document') {
            console.log('typeOfDoc' + typeOfDoc)
            return this.label.getDPNDocumentLink;
        }else if (typeOfDoc === 'Signature Verification Form') {
            console.log('typeOfDoc' + typeOfDoc)
            return this.label.SignatureVerificationForm;
        }

        //return this.label.sanctionLetter;

    }
    updateLoanAppDocGenDtTimeMethod() {
        this.showSpinner = true;
        let d = new Date();
        let newD = new Date(d.getTime());
        let currentDateTime = newD.toISOString();
        let obje = {
            sobjectType: "LoanAppl__c",
            Id: this.loanApplicationRecord.Id,
            DocGenReRequired__c: false,
            Is_E_Sign_Physical_Done__c: false
        }
        if (this.stage && this.stage == 'Post Sanction') {
            obje.DocGenerationDateTime__c = currentDateTime;
        }
        let newArray = [];
        if (obje) {
            newArray.push(obje);
        }
        if (newArray) {
            upsertMultipleRecord({ params: newArray })
                .then((result) => {
                    this.showSpinner = false;
                    this.refreshDocTable();
                    this.UpdateStampedDocumFalse('Mandatory Post Sanction Documents', 'Sanction Letter & KFS Document', 'Physical-Signed Sanction Letter & KFS Document');
                    this.UpdateStampedDocumFalse('Mandatory Post Sanction Documents', 'NACH Form', 'Physical-Signed NACH Form');
                })
                .catch((error) => {
                    console.log('error ', JSON.stringify(error));
                    console.table(error);
                    this.showSpinner = false;
                });
        }
    }
    @track showDocList
    refreshDocTable() {
        this.showDocList = true;
        console.log('called refreshDoc' + this.showDocList);
    }


    handleDocumentDocuNew() {
        if (this.loanAppleanIsPending == false) {//LAK-9640
            if ( this.diffinRacRoiANDRevisedRoi ) { //this.roiPfInitiated == false && && this.roiPfApproved == false // LAK-10462
                this.showToastMessage('Error', 'Kindly raise Pricing Approval for revised ROI before generating documents ', 'Error', 'sticky');
                this.showSpinner = false;
                this.refreshDocTable();
            } else {
                this.getApplicantDetails('Document');
            }

        } else {
            this.showToastMessage('Error', 'Loan Term Negotiation Or ROI/PF pending ', 'Error', 'sticky');
            this.showSpinner = false;
            this.refreshDocTable();
        }


    }

    //TermSheet 
    handleTermSheet() {
        this.showDocList = false;
        this.showSpinner = true;
        this.handleGenerateDocuments('Term Sheet', 'Term Sheet', 'Term Sheet', 'Soft Sanction');

    }
    @track OTPConsent;
    @track appData = [];
    @track appIds = [];
    @track appKYCData = [];
    getApplicantDetails(val) {
        this.showSpinner = true;
        let consti = 'INDIVIDUAL';
        let appType = ['P', 'C', 'G'];
        let paramsLoanApp = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'InsRational__c', 'OTP_Verified__c', 'TabName__c', 'InsAvailable__c', 'LName__c', 'fName__c', 'ApplType__c', 'DOB__c', 'Relationship__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND ApplType__c  IN (\'' + appType.join('\', \'') + '\') AND Constitution__c = \'' + consti + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Applicant data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    console.log('Applicant data length is', result.parentRecords.length);
                    this.appData = result.parentRecords;
                    result.parentRecords.forEach(app => {
                        this.appIds.push(app.Id);
                    })
                }
                this.getInsuranceDetails(val);
                this.getApplicantKYCDetails(val);
            })
            .catch((error) => {
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: error.body.message,
                        variant: "error",
                        mode: "sticky"
                    }),
                );
            });
    }
    getApplicantKYCDetails(val) {
        console.log('getApplicantKYCDetails' + this.appIds)
        let keyDoc = 'Aadhaar';
        let keyDocStatus = 'Success';
        let paramsLoanAppKYC = {
            ParentObjectName: 'ApplKyc__c',
            parentObjFields: ['Id', 'Applicant__c', 'ValidationStatus__c', 'kycDoc__c'],
            queryCriteria: ' where  Applicant__c  IN (\'' + this.appIds.join('\', \'') + '\') AND kycDoc__c = \'' + keyDoc + '\' AND ValidationStatus__c != \'' + keyDocStatus + '\''
        }
        getSobjectData({ params: paramsLoanAppKYC })
            .then((result) => {
                this.appKYCData = [];
                console.log('Applicant KYC data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.appKYCData = result.parentRecords;
                }
            })
            .catch((error) => {

            });
    }


    @track insuranceData = [];
    getInsuranceDetails(val) {
        let paramsLoanApp = {
            ParentObjectName: 'Insurance__c',
            parentObjFields: ['Id', 'Plan_Name__c', 'SumAmount__c', 'PremiumAmount__c', 'PolicyTenute__c', 'InsProvider__c', 'InsType__c', 'Appl__r.TabName__c', 'Appl__r.Constitution__c', 'InsProvider__r.Name', 'SumInsuredType__c', 'isCoBorrNominee__c', 'Appl__c', 'Appl__r.fName__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND IsActive__c = true'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Insurance data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.insuranceData = result.parentRecords;
                }
                this.getApplicantAddrDetails(val);
            })
            .catch((error) => {
                console.log('Error In getting Applicant Address Data ', error);
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: error.body.message,
                        variant: "error",
                        mode: "sticky"
                    }),
                );
            });
    }


    @track applAddrsDet = []
    getApplicantAddrDetails(val) {
        let addrsType = ['Permanent Address']
        let paramsLoanApp = {
            ParentObjectName: 'ApplAddr__c',
            parentObjFields: ['Id', 'Applicant__c', 'AddrLine1__c', 'AddrLine2__c', 'City__c',
                'Pincode__c', 'State__c', 'LoanAppl__c', 'HouseNo__c', 'AddrTyp__c', 'MailAddr__c', 'Locality__c', 'StateId__c', 'PinId__c', 'CityId__c'],
            queryCriteria: ' where Applicant__c  IN (\'' + this.appIds.join('\', \'') + '\') AND AddrTyp__c  IN (\'' + addrsType.join('\', \'') + '\') AND AddrTyp__c != null'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Applicant Address data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.applAddrsDet = result.parentRecords;
                }
                this.getInsurancePartDetails(val);
            })
            .catch((error) => {
                console.log('Error In getting Applicant Address Data ', error);
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: error.body.message,
                        variant: "error",
                        mode: "sticky"
                    }),
                );
            });
    }


    @track insurancePartDetails = [];
    getInsurancePartDetails(val) {
        let partType = ['Nominee', 'Appointee'];
        let paramsLoanApp = {
            ParentObjectName: 'InsParti__c',
            parentObjFields: ['Id', 'Insurance__c', 'appointeeFor__c', 'LoanAppln__c', 'Appl__r.TabName__c', 'Appl__r.Id', 'LoanAppln__r.PricingApprovalApplicable__c', 'Appl__c', 'NomPercent__c', 'Appl__r.InsRational__c', 'Appl__r.InsAvailable__c', 'Parti__c', 'Appl__r.LName__c', 'Appl__r.fName__c', 'Appl__r.ApplType__c', 'Appl__r.DOB__c', 'Appl__r.Relationship__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND isActive__c = true AND Parti__c  IN (\'' + partType.join('\', \'') + '\')'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Insurance participant data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.insurancePartDetails = result.parentRecords;
                }
                this.checkvalidation(val);
            })
            .catch((error) => {
                console.log('Error In getting Insurance Participant Data ', error);
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: error.body.message,
                        variant: "error",
                        mode: "sticky"
                    }),
                );
            });
    }
    insuraDocPresent
    insureDoc() {
        const docSubTyp = 'Life Insurance documents'
        const docTyp = 'Life Insurance documents'
        const docCat = 'Insurance documents'
        console.log('+this.loanApplicationRecord.Applicant__c' + this.loanApplicationRecord.Applicant__c)
        let paramForInsu = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['id'],
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this.loanApplicationRecord.Id + '\' AND DocCatgry__c = \'' + docCat + '\' AND DocTyp__c = \'' + docTyp + '\' AND DocSubTyp__c = \'' + docSubTyp + '\''
        }
        getSobjectData({ params: paramForInsu })
            .then((result) => {
                if (result && result.parentRecords && result.parentRecords.length > 0) {
                    console.log('result.parentRecords[0].Id' + result.parentRecords[0].Id)
                    getFilePreviewDataList({ ddID: result.parentRecords[0].Id })
                        .then((res) => {
                            console.log('result from getFilePreviewData ', res);
                            this.insuraDocPresent = true;


                        })
                        .catch((err) => {
                            // this.showToast("Error", "error", "Error occured in dd " + err.message);
                            console.log(" getFilePreviewData error===", err);
                            this.insuraDocPresent = false;


                        });
                }

                /*if(result.parentRecords.length>0) {
                    this.insuraDocPresent=true;
                }else{
                    this.insuraDocPresent=false;
                }*/
            })
            .catch((error) => {
                console.log('Error In getting 2222 ', error);
            });
    }

    insuraDocPresentGen
    insureDocGen() {

        const docSubTyp = 'General Insurance documents'
        const docTyp = 'General Insurance documents'
        const docCat = 'Insurance documents'
        console.log('+this.loanApplicationRecord.Applicant__c' + this.loanApplicationRecord.Applicant__c)
        let paramForInsu = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['id'],
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this.loanApplicationRecord.Id + '\' AND DocCatgry__c = \'' + docCat + '\' AND DocTyp__c = \'' + docTyp + '\' AND DocSubTyp__c = \'' + docSubTyp + '\''
        }
        getSobjectData({ params: paramForInsu })
            .then((result) => {
                console.log('resultresult' + JSON.stringify(result))
                if (result && result.parentRecords && result.parentRecords.length > 0) {
                    getFilePreviewDataList({ ddID: result.parentRecords[0].Id })
                        .then((res) => {
                            console.log('result from getFilePreviewData ', res);
                            this.insuraDocPresentGen = true;


                        })
                        .catch((err) => {
                            // this.showToast("Error", "error", "Error occured in dd " + err.message);
                            this.insuraDocPresentGen = false;
                            console.log(" getFilePreviewData error===", err);


                        });
                }
            })
            .catch((error) => {
                console.log('Error In getting 2257 ', error);
            });
    }

    checkvalidation(val) {
        let count = 0;
        this.insureDoc()
        let lifeInsuranceAvailable = false; //LAK-5149
        let GenInsuranceAvailable = false;

        this.appData.forEach(ite => {
            console.log('this.appData' + this.appData.length)
            let insuranceDataNew = this.insuranceData.filter(itemm => itemm.Appl__c === ite.Id);
            console.log('insuranceDataNew' + insuranceDataNew.length)
            console.log('insuranceDataNew' + JSON.stringify(this.insuranceData))
            if (insuranceDataNew && insuranceDataNew.length > 0) {
                console.log('insuranceDataNew.length ', insuranceDataNew.length);
                let insCount = 0;
                insuranceDataNew.forEach(ite => {
                    if (ite.InsType__c === 'Life Insurance') {

                        lifeInsuranceAvailable = true;//LAK-5149

                        if (ite.isCoBorrNominee__c && ite.SumAmount__c && ite.PremiumAmount__c && ite.Plan_Name__c && ite.PolicyTenute__c && ite.SumInsuredType__c && ite.InsProvider__c && ite.InsProvider__r.Name && this.insuraDocPresent) {
                            let arr = this.insurancePartDetails.filter(it => it.Insurance__c === ite.Id && it.Parti__c == 'Nominee');
                            if (arr && arr.length > 0) {
                                let totalNomineePec = 0;
                                let checkNomineeCount = 0;
                                let appointeeCount = 0;
                                arr.forEach(ipart => {
                                    let nominneeFalg = false;
                                    totalNomineePec = totalNomineePec + ipart.NomPercent__c;
                                    let addObj = this.applAddrsDet.find(itemTwo => itemTwo.Applicant__c === ipart.Appl__r.Id);
                                    if (ipart.Appl__r && !ipart.Appl__r.Relationship__c && !ipart.Appl__r.Pincode__c && !ipart.Appl__r.DOB__c && !ipart.Appl__r.fName__c && !ipart.Appl__r.LName__c && ((addObj && !addObj.HouseNo__c && !addObj.AddrLine1__c && !addObj.AddrLine2__c && !addObj.StateId__c && !addObj.City__c) || !addObj)) {
                                        this.showToastMessage('Error', ite.Appl__r.TabName__c + ': Required Data Missing on Insurance Screen on ' + ite.InsType__c, 'Error', 'sticky');
                                        this.showSpinner = false;
                                    } else {
                                        nominneeFalg = true;
                                    }
                                    let appointDetails = this.insurancePartDetails.filter(itt => itt.appointeeFor__c === ipart.Id && itt.Parti__c == 'Appointee');

                                    if (appointDetails && appointDetails.length > 0) {
                                        appointDetails.forEach(ipartapp => {
                                            let addObjForAppoint = this.applAddrsDet.find(itemTwo => itemTwo.Applicant__c === ipartapp.Appl__r.Id);
                                            if (ipartapp.Appl__r && !ipartapp.Appl__r.Relationship__c && !ipartapp.Appl__r.Pincode__c && !ipartapp.Appl__r.DOB__c && !ipartapp.Appl__r.fName__c && !ipartapp.Appl__r.LName__c && ((addObjForAppoint && !addObjForAppoint.HouseNo__c && !addObjForAppoint.AddrLine1__c && !addObjForAppoint.AddrLine2__c && !addObjForAppoint.StateId__c && !addObjForAppoint.City__c) || !addObjForAppoint)) {
                                                this.showToastMessage('Error', ite.Appl__r.TabName__c + ': Required Data Missing on Insurance Screen on ' + ite.InsType__c, 'Error', 'sticky');
                                                this.showSpinner = false;
                                            } else {
                                                appointeeCount++;
                                            }
                                        })
                                    }
                                    if (appointDetails && appointDetails.length > 0) {
                                        if (appointeeCount === appointDetails.length) {
                                            if (nominneeFalg == true) {
                                                checkNomineeCount++;
                                            }
                                        }
                                    } else {
                                        if (nominneeFalg == true) {
                                            checkNomineeCount++;
                                        }
                                    }
                                })
                                if (totalNomineePec !== 100) {
                                    this.showToastMessage('Error', 'Nominee Percentage is not Equal to 100  in Insurance Screen on ' + ite.InsType__c, 'Error', 'sticky');
                                    this.showSpinner = false;
                                } else {
                                    if (checkNomineeCount === arr.length) {
                                        insCount++;
                                    }
                                }

                            } else {
                                this.showToastMessage('Error', ite.Appl__r.TabName__c + ' : Atleast One Nominee is Mandatory', 'Error', 'sticky');
                                this.showSpinner = false;
                            }
                        } else {
                            this.showToastMessage('Error', ite.Appl__r.TabName__c + ': Required Data Missing on Insurance Screen', 'Error', 'sticky');
                            this.showSpinner = false;
                        }
                    } else {
                        GenInsuranceAvailable = true;

                        if (ite.isCoBorrNominee__c && ite.SumAmount__c && ite.PremiumAmount__c && ite.PolicyTenute__c && ite.InsProvider__c && ite.InsProvider__r.Name && this.insuraDocPresentGen) {
                            let arr = this.insurancePartDetails.filter(it => it.Insurance__c === ite.Id && it.Parti__c == 'Nominee');

                            if (arr && arr.length > 0) {
                                let totalNomineePec = 0;
                                let checkNomineeCount = 0;
                                let appointeeCount = 0;
                                arr.forEach(ipart => {
                                    let nominneeFalg = false;
                                    totalNomineePec = totalNomineePec + ipart.NomPercent__c;
                                    let addObj = this.applAddrsDet.find(itemTwo => itemTwo.Applicant__c === ipart.Appl__r.Id);
                                    if (ipart.Appl__r && !ipart.Appl__r.Relationship__c && !ipart.Appl__r.DOB__c && !ipart.Appl__r.Pincode__c && !ipart.Appl__r.fName__c && !ipart.Appl__r.LName__c && ((addObj && !addObj.HouseNo__c && !addObj.AddrLine1__c && !addObj.AddrLine2__c && !addObj.StateId__c && !addObj.City__c) || !addObj)) {
                                        this.showToastMessage('Error', ite.Appl__r.TabName__c + ': Required Data Missing on Insurance Screen on ' + ite.InsType__c, 'Error', 'sticky');

                                        this.showSpinner = false;
                                    } else {
                                        nominneeFalg = true;
                                    }
                                    let appointDetails = this.insurancePartDetails.filter(itt => itt.appointeeFor__c === ipart.Id && itt.Parti__c == 'Appointee');

                                    if (appointDetails && appointDetails.length > 0) {
                                        appointDetails.forEach(ipartapp => {
                                            let addObjForAppoint = this.applAddrsDet.find(itemTwo => itemTwo.Applicant__c === ipartapp.Appl__r.Id);
                                            if (ipart.Appl__r && !ipartapp.Appl__r.Relationship__c && !ipartapp.Appl__r.DOB__c && !ipartapp.Appl__r.Pincode__c && !ipartapp.Appl__r.fName__c && !ipartapp.Appl__r.LName__c && ((addObjForAppoint && !addObjForAppoint.HouseNo__c && !addObjForAppoint.AddrLine1__c && !addObjForAppoint.AddrLine2__c && !addObjForAppoint.StateId__c && !addObjForAppoint.City__c) || !addObjForAppoint)) {
                                                this.showToastMessage('Error', ite.Appl__r.TabName__c + ': Required Data Missing on Insurance Screen on ' + ite.InsType__c, 'Error', 'sticky');
                                                this.showSpinner = false;
                                            } else {
                                                appointeeCount++;
                                            }
                                        })
                                    }
                                    if (appointDetails && appointDetails.length > 0) {
                                        if (appointeeCount === appointDetails.length) {
                                            if (nominneeFalg == true) {
                                                checkNomineeCount++;
                                            }
                                        }
                                    } else {
                                        if (nominneeFalg == true) {
                                            checkNomineeCount++;
                                        }
                                    }
                                })
                                if (totalNomineePec !== 100) {
                                    this.showToastMessage('Error', 'Nominee Percentage is not Equal to 100  in Insurance Screen on ' + ite.InsType__c, 'Error', 'sticky');
                                    this.showSpinner = false;
                                } else {
                                    if (checkNomineeCount === arr.length) {
                                        insCount++;
                                    }
                                }

                            } else {
                                this.showToastMessage('Error', ite.Appl__r.TabName__c + ' : Atleast One Nominee is Mandatory', 'Error', 'sticky');

                                this.showSpinner = false;
                            }
                        } else {
                            this.showToastMessage('Error', ite.Appl__r.TabName__c + ': Required Data Missing on Insurance Screen', 'Error', 'sticky');
                            this.showSpinner = false;
                        }

                    }
                    // }
                })
                if (insuranceDataNew.length === insCount) {
                    count++;
                }
            } else {

                if (ite.InsAvailable__c && ite.InsRational__c) {

                    count++;
                } else {
                    this.showToastMessage('Error', ite.TabName__c + ': Required Data Missing on Insurance Screen', 'Error', 'sticky');

                }
            }

            //LAK-5149
            if (!lifeInsuranceAvailable && insuranceDataNew.length > 0 && ite.InsType__c === 'Life Insurance') {
                this.showToastMessage('Error', 'Atleast One Life Insurance Should be added in Insurance Details', 'Error', 'sticky');
            } else if (!GenInsuranceAvailable && insuranceDataNew.length > 0 && ite.InsType__c === 'General Insurance') {
                this.showToastMessage('Error', 'Atleast One General Insurance Should be added in Insurance Details', 'Error', 'sticky');
            }
        });

        let customBool = true;
        if (this.stageNew && this.stageNew === 'Post Sanction' && this.customerAgreedLoanTermsValue && this.customerAgreedLoanTermsValue == 'Y') {
            if (this.remPfDeductFromDisAmtp && this.customerAgreedLoanTermsValue) {
                if (this.showIfTakenPolicy) {
                    if (this.insurancePremToBeDedFromDisAmtValue) {
                        customBool = true;
                    } else {
                        customBool = false;
                    }
                } else {
                    customBool = true;
                }

                if (this.showMultTracnch && !this.emiOptTracnDisCase) {
                    customBool = false;
                }
            } else {
                customBool = false;
                this.showSpinner = false;
            }
        } else {
            customBool = true;
        }
        //if (count === this.appData.length && lifeInsuranceAvailable) {
        if (count === this.appData.length) {
            if (customBool) {
                this.checkAnotherVaidation(val);
            } else {
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: 'Mandatory fields on Customer Confirmation is Missing',
                        variant: "error"
                    })
                );
            }

        } else {
            this.showSpinner = false;
        }
    }


    checkAnotherVaidation(val) {
        console.log('valvalvalval' + val)

        if (val == 'save') {
            this.handleSave();
        }
        //if (this.pricingApprvalAppble) {
        if (this.pricingApprvalAppble == 'Y') {

            this.checkLoanAppealValidation(val);

        } else {
            if (val == 'Document') {
                this.getLoanAppDataNew();
            }
            else if (this.listOfDocForGenerate.includes(val)) {
                this.allValidationsPassed = true;
                if (val == 'Aadhar Consent Letter') {
                    /*this.docSubTypeForForm = 'Aadhaar Consent';
                    this.docTypeForForm = 'Aadhaar Consent'
                    this.docCategoryForForm = 'KYC Documents';
                    if (this.appKYCData.length > 0) {
                        for (const appKYC of this.appKYCData) {
                            this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, appKYC.Applicant__c);
                        }
                    }*/
                } else if (val == 'loan agreement') {
                    this.docSubTypeForForm = 'Declaration of Loan Agreement';
                    this.docTypeForForm = 'Disbursal Documents'
                    this.docCategoryForForm = 'System Generated Documents';
                    this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                    this.handleGenerateDocuments('System Generated Documents', 'Disbursal Documents', 'Power Of Attonrny', 'Post Sanction');
                    this.handleGenerateDocuments('System Generated Documents', 'Disbursal Documents', 'Loan Agreement', 'Post Sanction');
                }
                else if (val == 'Pre Emi PF Deduc Letter') {

                    this.docSubTypeForForm = 'End Use, Pre EMI and PF Deduction Letter';
                    this.docTypeForForm = 'Disbursal Documents'
                    this.docCategoryForForm = 'System Generated Documents';
                    this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                } /*else if (val == 'PF Deduction') {
                    this.docSubTypeForForm = 'PF Deduction Letter';
                    this.docTypeForForm = 'Disbursal Documents'
                    this.docCategoryForForm = 'System Generated Documents';
                    this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                }*/ else if (val == 'Interest Bearing Letter') {
                    this.docSubTypeForForm = 'Interest Bearing Letter';
                    this.docTypeForForm = 'Disbursal Documents	'
                    this.docCategoryForForm = 'System Generated Documents';
                    this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                } else if (val == 'BTApplicationPart2') {
                    this.docSubTypeForForm = 'BT Draft Part 2';
                    this.docTypeForForm = 'BT Draft'
                    this.docCategoryForForm = 'BT Draft';
                    if (this.isLanBT == true && this.isLanBT) {
                        this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                    }

                } else if (val == 'BTApplicationPart1') {
                    this.docSubTypeForForm = 'BT Draft Part 1';
                    this.docTypeForForm = 'BT Draft'
                    this.docCategoryForForm = 'BT Draft';
                    if (this.isLanBT == true && this.isLanBT) {
                        this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                    }

                }
                else if (val == 'DPN Document') {
                    this.docSubTypeForForm = 'DPN Document';
                    this.docTypeForForm = 'DPN Document'
                    this.docCategoryForForm = 'System Generated Documents';
                    this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                   }
            }
        }
        // }

    }

    checkLoanAppealValidation(val) {
        this.checkLoanAppleal();
        if (this.loanAppleanIsPending == false) {
            if (val == 'Document') {
                this.getLoanAppDataNew();
            } else if (val == 'save') {
                this.handleSave();
            } else if (this.listOfDocForGenerate.includes(val)) {
                this.allValidationsPassed = true;
                if (val == 'Aadhar Consent Letter') {
                    /*this.docSubTypeForForm = 'Aadhaar Consent';
                    this.docTypeForForm = 'Aadhaar Consent'
                    this.docCategoryForForm = 'KYC Documents';
                    if (this.appKYCData.length > 0) {
                        for (const appKYC of this.appKYCData) {
                            this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, appKYC.Applicant__c);
                        }
                    }*/
                } else if (val == 'loan agreement') {
                    /*this.docSubTypeForForm = 'Loan Agreement';
                    this.docTypeForForm = 'Disbursal Documents'
                    this.docCategoryForForm = 'System Generated Documents';
                    this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');*/
                    this.docSubTypeForForm = 'Declaration of Loan Agreement';
                    this.docTypeForForm = 'Disbursal Documents'
                    this.docCategoryForForm = 'System Generated Documents';
                    this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                    this.handleGenerateDocuments('System Generated Documents', 'Disbursal Documents', 'Power Of Attonrny', 'Post Sanction');
                    this.handleGenerateDocuments('System Generated Documents', 'Disbursal Documents', 'Loan Agreement', 'Post Sanction');
                
                }
                else if (val == 'Pre Emi PF Deduc Letter') {

                    this.docSubTypeForForm = 'End Use, Pre EMI and PF Deduction Letter';
                    this.docTypeForForm = 'Disbursal Documents'
                    this.docCategoryForForm = 'System Generated Documents';
                    this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                }/* else if (val == 'PF Deduction') {
                    this.docSubTypeForForm = 'PF Deduction Letter';
                    this.docTypeForForm = 'Disbursal Documents'
                    this.docCategoryForForm = 'System Generated Documents';
                    this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                }*/ else if (val == 'Interest Bearing Letter') {
                    this.docSubTypeForForm = 'Interest Bearing Letter';
                    this.docTypeForForm = 'Disbursal Documents	'
                    this.docCategoryForForm = 'System Generated Documents';
                    this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                }
                else if (val == 'BTApplicationPart2') {
                    this.docSubTypeForForm = 'BT Draft Part 2';
                    this.docTypeForForm = 'BT Draft'
                    this.docCategoryForForm = 'BT Draft';
                    if (this.isLanBT == true && this.isLanBT) {
                        this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                    }
                } else if (val == 'BTApplicationPart1') {
                    this.docSubTypeForForm = 'BT Draft Part 1';
                    this.docTypeForForm = 'BT Draft'
                    this.docCategoryForForm = 'BT Draft';
                    if (this.isLanBT == true && this.isLanBT) {
                        this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                    }
                }
                else if (val == 'DPN Document') {
                    this.docSubTypeForForm = 'DPN Document';
                    this.docTypeForForm = 'DPN Document'
                    this.docCategoryForForm = 'System Generated Documents';
                    this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                    
                }


            }
        } else {
            this.showToastMessage('Error', 'Loan Term Negotiation Or ROI/PF pending ', 'Error', 'sticky');
            this.showSpinner = false;
        }

    }

    /* getPricingAprvalDocDet(val) {
         let docCat = 'Pricing Approval Document';
         let paramsLoanApp = {
             ParentObjectName: 'DocDtl__c',
             parentObjFields: ['Id'],
             queryCriteria: ' where LAN__c = \'' + this.loanAppId + '\' AND DocTyp__c = \'' + docCat + '\''
         }
         getSobjectData({ params: paramsLoanApp })
             .then((result) => {
                 console.log('Pricing Approval Document Data is', JSON.stringify(result));
                 if (result.parentRecords && result.parentRecords.length > 0) {
                     if (val == 'Document') {
                         this.getLoanAppDataNew();
                     } else if (val == 'save') {
                         this.handleSave();
                     } else if (this.listOfDocForGenerate.includes(val)) {
                         this.allValidationsPassed = true;
                         if (val == 'Aadhar Consent Letter') {
                             this.docSubTypeForForm = 'Aadhaar Consent';
                             this.docTypeForForm = 'Aadhaar Consent'
                             this.docCategoryForForm = 'KYC Documents';
                             if (this.appKYCData.length > 0) {
                                 for (const appKYC of this.appKYCData) {
                                     this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, appKYC.Applicant__c);
                                 }
                             }
                         } else if (val == 'loan agreement') {
                             this.docSubTypeForForm = 'Loan Agreement';
                             this.docTypeForForm = 'Disbursal Documents'
                             this.docCategoryForForm = 'Mandatory Post Sanction Documents';
                             this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                         }
                         else if (val == 'Pre Emi PF Deduc Letter') {
                             this.docSubTypeForForm = 'Pre Emi Deduction letter';
                             this.docTypeForForm = 'Disbursal Documents'
                             this.docCategoryForForm = 'Additional Post Sanction Documents';
                             this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                         } else if (val == 'PF Deduction') {
                             this.docSubTypeForForm = 'PF Deduction Letter';
                             this.docTypeForForm = 'Disbursal Documents'
                             this.docCategoryForForm = 'Mandatory Post Sanction Documents';
                             this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                         } else if (val == 'Interest Bearing Letter') {
                             this.docSubTypeForForm = 'Interest Bearing Letter';
                             this.docTypeForForm = 'Disbursal Documents	'
                             this.docCategoryForForm = 'Additional Post Sanction Documents	';
                             this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                         }
                         else if (val == 'BTApplicationPart2') {
                             this.docSubTypeForForm = 'BT Draft Part 2';
                             this.docTypeForForm = 'BT Draft'
                             this.docCategoryForForm = 'BT Draft';
                             if (this.isLanBT == true && this.isLanBT) {
                                 this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                             }
                         } else if (val == 'BTApplicationPart1') {
                             this.docSubTypeForForm = 'BT Draft Part 1';
                             this.docTypeForForm = 'BT Draft'
                             this.docCategoryForForm = 'BT Draft';
                             if (this.isLanBT == true && this.isLanBT) {
                                 this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                             }
                         }
                         else if (val == 'DPN Document') {
                             this.docSubTypeForForm = 'DPN Document';
                             this.docTypeForForm = 'DPN Document'
                             this.docCategoryForForm = 'Mandatory Post Sanction Documents';
                             this.handleGenerateDocuments(this.docCategoryForForm, this.docTypeForForm, this.docSubTypeForForm, 'Post Sanction');
                         }
 
 
                     }
                 } else {
                     this.showToastMessage('Error', 'Please Generate Pricing Approval Document', 'Error', 'sticky');
                     this.showSpinner = false;
                 }
             })
             .catch((error) => {
                 this.showSpinner = false;
                 console.log('Error In getting loan app Data New', error);
             });
     }*/

    getLoanAppDataNew() {
        let paramsLoanApp = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Id', 'DocGenReRequired__c', 'Stage__c', 'SubStage__c'],
            queryCriteria: ' where Id = \'' + this.loanAppId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Loan application data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.stage = result.parentRecords[0].Stage__c;
                    this.subStage = result.parentRecords[0].SubStage__c;
                    if (result.parentRecords[0].Stage__c === 'Post Sanction' || result.parentRecords[0].Stage__c === 'Soft Sanction') {

                        if (result.parentRecords[0].DocGenReRequired__c) {
                            this.createIntegrationMessage();
                        } else {
                            this.showToastMessage('Error', this.label.Bre_Rerun_Error_Message, 'Error', 'sticky');
                            this.showSpinner = false;
                        }
                    } else {
                        this.createIntegrationMessage();
                    }

                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting loan app Data New', error);
            });
    }
    @track intBRERecords = [];
    createIntegrationMessage() {
        let fieldsWo = {};
        fieldsWo['sobjectType'] = 'IntgMsg__c';
        fieldsWo['Name'] = 'Crif Auth Login';
        fieldsWo['BU__c'] = 'HL / STL';
        fieldsWo['IsActive__c'] = true;
        fieldsWo['Svc__c'] = 'Crif Auth Login';
        fieldsWo['Status__c'] = 'New';
        fieldsWo['Outbound__c'] = true;
        fieldsWo['RefObj__c'] = 'LoanAppl__c';
        fieldsWo['ApiVendor__c'] = 'Crif';
        fieldsWo['RefId__c'] = this.loanAppId;
        this.intBRERecords.push(fieldsWo);
        this.createIntRRecords(this.intBRERecords);
    }

    @track breIntMsgId = '';
    chequeBREInterval;
    createIntRRecords(intRecords) {
        this.showSpinner = true;
        upsertMultipleRecord({ params: intRecords })
            .then((result) => {
                this.intBRERecords = [];
                this.breIntMsgId = result[0].Id;
                this.startPollingForInt();
            })
            .catch((error) => {
                this.showToastMessage('Error', error.body.message, 'Error', 'sticky');
                console.log('Error In creating Record', error);
                this.showSpinner = false;
            });
    }

    startPollingForInt() {
        console.log('Polling has started ##875')
        this.chequeBREInterval = setInterval(() => {
            this.getIntBRERecord();
        }, 5000);
    }

    getIntBRERecord() {

        let paramsLoanApp = {
            ParentObjectName: 'IntgMsg__c',
            parentObjFields: ['Id', 'Status__c', 'Name', 'Resp__c', 'APIStatus__c', 'LoanAppln__r.Stage__c'],
            queryCriteria: ' where ParentRefId__c = \'' + this.breIntMsgId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                if (result.parentRecords) {
                    this.respPayload = result.parentRecords[0].Resp__c;

                    if (result.parentRecords[0].APIStatus__c === 'Success') {
                        this.showToastMessage('Success', this.label.BRETriggerMessage, 'Success', 'sticky')
                        clearInterval(this.chequeBREInterval);
                        if (result.parentRecords[0].LoanAppln__r.Stage__c === 'Soft Sanction') {

                            this.saveLoanDetails('Term Sheet', 'Term Sheet', 'Term Sheet', 'Soft Sanction');
                        } else {
                            this.saveLoanDetails('Sanction Letter', 'Sanction Letter', 'Sanction Letter', '');
                        }

                    }
                    if (result.parentRecords[0].APIStatus__c === 'Failure') {
                        this.showToastMessage('Error', this.label.BRETriggerFailedMessage + ': ' + result.parentRecords[0].Resp__c, 'Error', 'sticky')
                        clearInterval(this.chequeBREInterval);
                        this.showSpinner = false;

                    }
                }

            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Int Msg Record ', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
            });
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

    ///LAK-5855
    @track showIfTakenPolicy = true; // 
    getInsuranceDetRational() {//
        let paramsLoanApp = {
            ParentObjectName: 'Insurance__c',
            parentObjFields: ['Id', 'InsProvider__c', 'InsType__c', 'SumInsuredType__c', 'isCoBorrNominee__c', 'Appl__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND IsActive__c = true'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                let takenPolicy = false;
                if (result.parentRecords && result.parentRecords.length > 0) {
                    takenPolicy = true;

                }
                this.showIfTakenPolicy = takenPolicy;

            })
            .catch((error) => {
                console.log('Error In getting Applicant Address Data ', error);

            });
    }
    handleFormNdUseLetter() {
        this.showDocList = false;
        this.showSpinner = true;
        this.checkLoanAppleal();


        if (this.loanAppleanIsPending == false) {//LAK-9640
            if (this.roiPfInitiated == false && this.diffinRacRoiANDRevisedRoi && this.roiPfApproved == false) {
                this.showToastMessage('Error', 'Kindly raise Pricing Approval for revised ROI before generating documents ', 'Error', 'sticky');
                this.showSpinner = false;
                this.refreshDocTable();
            } else {
                //this.handleGenerateDocuments('System Generated Documents', 'Disbursal Documents', 'End Use Letter', 'Post Sanction');
                setTimeout(() => {
                    this.disableFormDownButton = true;
                    this.UpdateLoanAppliEndUseLetter('Application Form')
                    this.handleGenerateDocuments('System Generated Documents', 'Application Form', 'Application Form', 'Post Sanction');
                    this.showToastMessage('Success', 'Application Form Downloaded Successfully.', 'success', 'sticky');
                    this.refreshDocTable();
                    if (this.template.querySelector('c-uploded-document-display') != null) {
                        this.template.querySelector('c-uploded-document-display').handleFilesUploaded('');
                    }
                }, 5000);
            }

        } else {
            this.showToastMessage('Error', 'Loan Term Negotiation Or ROI/PF pending ', 'Error', 'sticky');
            this.showSpinner = false;
            this.refreshDocTable();
        }



        // if (this.loanAppleanIsPending == false) {
        //     this.disableFormDownButton = true;
        //     this.UpdateLoanAppliEndUseLetter()
        //     this.handleGenerateDocuments('System Generated Documents', 'Application Form', 'Application Form', 'Post Sanction');
        //     this.handleGenerateDocuments('System Generated Documents', 'Disbursal Documents', 'End Use Letter', 'Post Sanction');
        //     setTimeout(() => {
        //         this.showToastMessage('Success', 'Application Form and End Use Letter Downloaded Successfully.', 'success', 'sticky');
        //         this.refreshDocTable();
        //         if (this.template.querySelector('c-uploded-document-display') != null) {
        //             this.template.querySelector('c-uploded-document-display').handleFilesUploaded('');
        //         }
        //     }, 5000);
        // } else {
        //     this.showToastMessage('Error', 'Loan Term Negotiation Or ROI/PF pending ', 'Error', 'sticky');
        //     this.showSpinner = false;
        //     this.refreshDocTable();
        // }

        /*let paramForLoanAppe = {
            ParentObjectName: 'LoanAppeal__c',
            parentObjFields: ['Id', 'Status__c', 'LoanAppl__c', 'RecordType.Name'],
            queryCriteria: ' WHERE LoanAppl__c = \'' + this.loanAppId + '\'' +
                ' AND (Status__c = \'New\' OR Status__c = \'In Progress\')' +
                ' AND (RecordType.Name = \'Loan Term Negotiation\' OR RecordType.Name = \'Roi Pf Correction\')'
        };
        getSobjectData({ params: paramForLoanAppe })
            .then((result) => {
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.showSpinner = false;
                    this.loanAppleanIsPending = true
                } else {
                    this.loanAppleanIsPending = false
                    this.showSpinner = true;
                }
                if (this.loanAppleanIsPending == false) {
                    this.handleGenerateDocuments('Application Form', 'Application Form', 'Application Form', 'Post Sanction');
                    this.handleGenerateDocuments('Mandatory Post Sanction Documents', 'Disbursal Documents', 'End Use Letter', 'Post Sanction');
                    setTimeout(() => {
                        this.showToastMessage('Success', 'Application Form and End Use Letter Downloaded Successfully.', 'success', 'sticky');
                        this.refreshDocTable();
                    }, 4000);
                } else {
                    this.showToastMessage('Error', 'Loan Term Negotiation Or ROI/PF pending ', 'Error', 'sticky');
                    this.showSpinner = false;
                    this.refreshDocTable();
                }
            })
            .catch((error) => {
                this.loanAppleanIsPending = false
                this.showSpinner = false;
                console.log('Error In getting loan app Data New', error);
            });*/
    }
    UpdateLoanAppliEndUseLetter(updateFieldButton) {
        let obje={}
        if(updateFieldButton=='Application Form'){
            obje.sobjectType= "LoanAppl__c";
            obje.Id= this.loanApplicationRecord.Id;
            obje.App_Form_End_Use_Letter_Doc_Required__c= false;
            obje.Is_E_Sign_Physical_Done__c= false;
        }else if(updateFieldButton=='Application Form'){
            obje.sobjectType= "LoanAppl__c";
            obje.Id= this.loanApplicationRecord.Id;
            obje.SignatureVerificationDocReq__c= false;
        }
        /*let obje = {
            sobjectType: "LoanAppl__c",
            Id: this.loanApplicationRecord.Id,
            App_Form_End_Use_Letter_Doc_Required__c: false,
            Is_E_Sign_Physical_Done__c: false
        }*/
       console.log('objeobje>>>',obje)
        let newArray = [];
        if (obje) {
            newArray.push(obje);
        }
        if (newArray) {
            upsertMultipleRecord({ params: newArray })
                .then((result) => {
                    this.showSpinner = false;
                    this.refreshDocTable();
                })
                .catch((error) => {
                    this.showSpinner = false;
                });
        }
    }
    @track roiPfApproved = false;
    @track roiPfInitiated = false;
    @track loanAppleanIsPending = false;
    checkLoanAppleal() {

        let paramForLoanAppe = {
            ParentObjectName: 'LoanAppeal__c',
            parentObjFields: ['Id', 'Status__c', 'LoanAppl__c', 'RecordType.Name'],
            queryCriteria: ' WHERE LoanAppl__c = \'' + this.loanAppId + '\'' +
                ' AND (Status__c = \'New\' OR Status__c = \'In Progress\'  OR Status__c = \'Approve\')' +
                ' AND (RecordType.Name = \'Loan Term Negotiation\' OR RecordType.Name = \'Roi Pf Correction\')'
        };
        getSobjectData({ params: paramForLoanAppe })
            .then((result) => {
                if (result.parentRecords && result.parentRecords.length > 0) {
                    result.parentRecords.forEach(ele => {
                        if (ele.Status__c == 'Approve' && ele.RecordType.Name == 'Roi Pf Correction') {
                            this.roiPfApproved = true;
                        }
                        if (ele.RecordType.Name == 'Roi Pf Correction') {
                            this.roiPfInitiated = true;
                        }
                        if (ele.Status__c != 'Approve') {
                            this.loanAppleanIsPending = true;
                        }
                    });
                    this.showSpinner = false;

                } else {
                    this.loanAppleanIsPending = false;
                    // this.showSpinner = true;
                }

            })
            .catch((error) => {
                this.loanAppleanIsPending = false
                this.showSpinner = false;
                console.log('Error In getting loan app Data New', error);
            });

    }

    //@track listOfDocForGenerate = ['DPN Document', 'loan agreement', 'Pre Emi PF Deduc Letter', 'PF Deduction', 'Interest Bearing Letter', 'BTApplicationPart2', 'BTApplicationPart1'];
    @track listOfDocForGenerate = ['DPN Document', 'loan agreement', 'Pre Emi PF Deduc Letter', 'Interest Bearing Letter', 'BTApplicationPart2', 'BTApplicationPart1'];
    @track listForFalseDoc = ['Physical-Signed Loan Agreement & Related Annexures', 'Physical-Signed DPN Document', 'Physical-Signed BT Draft Part 2', 'Physical-Signed BT Draft Part 1', 'Loan Agreement & Related Annexures', 'Stamped Loan Agreement'];
    docSubTypeForForm;
    docTypeForForm
    docCategoryForForm
    allValidationsPassed
    loanAppeanIsPending = true;
    clickOnGenerateDoc;
    handleLoanAggrementDown() {
        this.showDocList = false;
        this.allValidationsPassed = false;
        this.checkLoanAppleal();
        // this.roiPfInitiated 
        //this.loanAppleanIsPending
        //this.diffinRacRoiANDRevisedRoi
        if (this.loanAppleanIsPending == false) {//LAK-9640
            if (this.roiPfInitiated == false && this.diffinRacRoiANDRevisedRoi && this.roiPfApproved == false) {
                this.showToastMessage('Error', 'Kindly raise Pricing Approval for revised ROI before generating documents ', 'Error', 'sticky');
                this.showSpinner = false;
                this.refreshDocTable();
            } else {
                //if (this.loanAppleanIsPending == false) {
                for (const val of this.listOfDocForGenerate) {
                    this.getApplicantDetails(val);

                }
                setTimeout(() => {
                    if (this.allValidationsPassed == true) {
                        this.DisLoanAggre = true
                        this.UpdateLoanAgreement();
                        for (const val of this.listForFalseDoc) {
                            if (val == 'Physical-Signed Loan Agreement & Related Annexures') {
                                this.UpdateStampedDocumFalse('Additional Post Sanction Documents', 'Loan Agreement & Related Annexure', val);
                            } else if (val == 'Physical-Signed DPN Document') {
                                this.UpdateStampedDocumFalse('Mandatory Post Sanction Documents', 'DPN Document', val);
                            } else if (val == 'Stamped Loan Agreement') {
                                this.UpdateStampedDocumFalse('Stamped Loan Agreement', 'Stamped Loan Agreement', val);
                            } else if (val == 'Loan Agreement & Related Annexures') {
                                this.UpdateStampedDocumFalse('Additional Post Sanction Documents', 'Loan Agreement & Related Annexure', val);
                            } else if (val == 'Physical-Signed BT Draft Part 1') {
                                this.UpdateStampedDocumFalse('Mandatory Post Sanction Documents', 'BT Draft Part 1', val);
                            } else if (val == 'Physical-Signed BT Draft Part 2') {
                                this.UpdateStampedDocumFalse('Mandatory Post Sanction Documents', 'BT Draft Part 2', val);
                            }
                        }

                        this.showToastMessage('Success', 'Documents Downloaded Successfully.', 'success', 'sticky');
                    }
                    this.refreshDocTable();
                    if (this.template.querySelector('c-uploded-document-display') != null) {
                        this.template.querySelector('c-uploded-document-display').handleFilesUploaded('');
                    }

                }, 8000);
                // } else {
                //     this.showToastMessage('Error', 'Loan Term Negotiation Or ROI/PF pending ', 'Error', 'sticky');
                //     this.showSpinner = false;
                //     this.refreshDocTable();

                // }
            }

        } else {
            this.showToastMessage('Error', 'Loan Term Negotiation Or ROI/PF pending ', 'Error', 'sticky');
            this.showSpinner = false;
            this.refreshDocTable();
        }
    }
    UpdateLoanAgreement() {
        let obje = {
            sobjectType: "LoanAppl__c",
            Id: this.loanApplicationRecord.Id,
            Disbursal_Document_Required__c: false,
            Is_E_Sign_Physical_Done__c: false,
            Is_E_Stamp_Done__c: false
        }
        let newArray = [];
        if (obje) {
            newArray.push(obje);
        }
        if (newArray) {
            upsertMultipleRecord({ params: newArray })
                .then((result) => {
                    this.showSpinner = false;
                    //this.DisLoanAggre = true
                    this.refreshDocTable();
                })
                .catch((error) => {
                    this.showSpinner = false;
                });
        }
    }

    getLoanAppealData() {
        let param = HELPER.getLoanAppealParam(this.loanAppId);
        getSobjectData({ params: param })
            .then((result) => {
                console.log('Result  == ', result);

            })
            .catch((error) => {

            })
    }
    UpdateStampedDocumFalse(docCat, docTyp, docSubTyp) {
        let listOfAllParent = [];
        let paramForIsLatest = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'Appl__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c'],
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this._loanAppId + '\' AND DocCatgry__c = \'' + docCat + '\' AND DocTyp__c = \'' + docTyp + '\' AND DocSubTyp__c = \'' + docSubTyp + '\''
        }
        getSobjectData({ params: paramForIsLatest })
            .then((result) => {
                console.log('isLatestFalseRecs>>>>>' + JSON.stringify(result))
                if (result.parentRecords) {
                    listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
                    let isLatestFalseRecs = []
                    isLatestFalseRecs = listOfAllParent.map(record => {
                        return { ...record, IsLatest__c: false };
                    });

                    upsertMultipleRecord({ params: isLatestFalseRecs })
                        .then(result => {
                            this.showEsignPhysicalDoc == true
                        }).catch(error => {
                            console.log('errorerrorerror', error);
                        })
                }

            })
            .catch((error) => {
                console.log('Error In 1841 ', error);
            });
    }
    @track DisSignVerButton;
    handleSignatureVerifiDown(){
        this.showDocList = false;
        this.showSpinner = true;
        this.checkLoanAppleal();


        if (this.loanAppleanIsPending == false) {//LAK-9640
            if (this.roiPfInitiated == false && this.diffinRacRoiANDRevisedRoi && this.roiPfApproved == false) {
                this.showToastMessage('Error', 'Kindly raise Pricing Approval for revised ROI before generating documents ', 'Error', 'sticky');
                this.showSpinner = false;
                this.refreshDocTable();
            } else {
                this.DisSignVerButton = true;
                this.UpdateLoanAppliEndUseLetter('Signature Verification')
                this.handleGenerateDocuments('System Generated Documents', 'Signature Verification Form', 'Signature Verification Form', 'Post Sanction');
                setTimeout(() => {
                    this.showToastMessage('Success', 'Signature Verification Form Generated Successfully.', 'success', 'sticky');
                    this.refreshDocTable();
                    if (this.template.querySelector('c-uploded-document-display') != null) {
                        this.template.querySelector('c-uploded-document-display').handleFilesUploaded('');
                    }
                }, 5000);
            }

        } else {
            this.showToastMessage('Error', 'Loan Term Negotiation Or ROI/PF pending ', 'Error', 'sticky');
            this.showSpinner = false;
            this.refreshDocTable();
        }
    }



}