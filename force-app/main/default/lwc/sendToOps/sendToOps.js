import { LightningElement, api, track } from 'lwc';

import Stage from '@salesforce/schema/LoanAppl__c.Stage__c';
import subStage from '@salesforce/schema/LoanAppl__c.SubStage__c';
import OwnerId from '@salesforce/schema/LoanAppl__c.OwnerId';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import generateDocument from "@salesforce/apex/GeneratePDFandAttachToLoanApplication.generateDocument";
import createDocumentDetail from "@salesforce/apex/DocumentDetailController.createDocumentDetail";
import ndcDocumentCheck from "@salesforce/apex/DocumentCheckController.ndcDocumentCheck";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import checkExpiry from '@salesforce/apex/VerificationExpiryController.checkExpiry';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getValidationReport from "@salesforce/apex/ValidateRequiredFieldsAndDoc.getValidationReport";
import getSobjectDataWithoutCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjDtwithFltrRelatedRecordsWithoutCache';
import validateData from '@salesforce/apex/SendToOpsValidations.validateData';
// Custom labels
import Send_to_Oops_BRE_Error_Message from '@salesforce/label/c.Send_to_Oops_BRE_Error_Message';
import Send_To_Oops_Succes_Message from '@salesforce/label/c.Send_To_Oops_Succes_Message';
import send_to_ops_decoument_appro_error from '@salesforce/label/c.send_to_ops_decoument_appro_error';
import send_to_ops_deviation_appro_error from '@salesforce/label/c.send_to_ops_deviation_appro_error';
import PageURLDisbusementMemo from '@salesforce/label/c.PageURLDisbusementMemo';
import PageURLCAMReporrt from '@salesforce/label/c.PageURLCAMReporrt';
export default class SendToOps extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @track showSpinner = true;
    loanApplicationQueueId;
    arr = [];
    connectedCallback() {

        setTimeout(() => {
            this.showSpinner = false;
        }, 2000);

        let grpName = 'Ops Pool';
        let type = 'Queue';
        let params = {
            ParentObjectName: 'Group',
            parentObjFields: ["Id", "Name"],

            queryCriteria: ' where name = \'' + grpName + '\' AND Type = \'' + type + '\''
        };
        console.log("params", params);
        getSobjectDatawithRelatedRecords({ params: params })
            .then((res) => {

                this.loanApplicationQueueId = res.parentRecord.Id;

            })
        console.log('loanApplicationQueueId ', this.loanApplicationQueueId);
    }

    handleSuccess(e) {
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Loan Application Sent For OPS Verification Successfully!',
                variant: 'success'
            })

        );
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: this.recordId,
        //         actionName: 'view'
        //     },
        // });
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "LoanAppl__c",
                actionName: "list"
            },
            // state: {
            //     filterName: "Recent" 
            // }
        });
    }

    @track loanStage;
    // @track devLwddDtlId;
    getLoanAppData() {
        this.showSpinner = true;
        let paramsLoanApp = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Id', 'Stage__c', 'SubStage__c', 'Product__c'],
            queryCriteria: ' Where Id = \'' + this.recordId + '\''
            // queryCriteria: ' where LAN__c = \'' + this.recordId + '\' AND APIName__c = \'' + apiName + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Document Detail Data is', JSON.stringify(result));
                // let docApproved = true;
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.loanStage = result.parentRecords[0].Stage__c;
                }
                this.validateSendtoOps();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Loan Application data is ', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }
    // getRcuCase() {
    //     this.showSpinner = true;
    //     let recordTypeName = 'RCU';
    //     let paramsLoanApp = {
    //         ParentObjectName: 'Case',
    //         parentObjFields: ['Id', 'Loan_Application__c', 'Status', 'ReportResult__c'],
    //         queryCriteria: ' Where Loan_Application__c = \'' + this.recordId + '\' AND RecordType.Name = \'' + recordTypeName + '\''
    //     }
    //     getSobjectData({ params: paramsLoanApp })
    //         .then((result) => {
    //             console.log('Rcu Case Data', JSON.stringify(result));
    //             if (result.parentRecords && result.parentRecords.length > 0) {
    //                 this.caseData = result.parentRecords;
    //             }
    //             this.getPostSancDevData();
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getting RCU Cases is ', error);
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error',
    //                     message: error.body.message,
    //                     variant: 'error',
    //                     mode: 'sticky'
    //                 })
    //             );
    //             this.dispatchEvent(new CloseActionScreenEvent());
    //         });
    // }
    // @track postSanDevBool = true;
    // getPostSancDevData() {
    //     let devCat = 'Post Sanction Auto Deviation';
    //     let paramsLoanApp = {
    //         ParentObjectName: 'Deviation__c',
    //         parentObjFields: ['Id', 'DeviationCategory__c', 'LoanAppln__c', 'Deviation__c'],
    //         queryCriteria: ' Where LoanAppln__c = \'' + this.recordId + '\' AND DeviationCategory__c = \'' + devCat + '\' AND Deviation__c = \'' + this.devLwddDtlId + '\''
    //     }
    //     getSobjectData({ params: paramsLoanApp })
    //         .then((result) => {
    //             console.log('Post Sanction Auto Deviation Data is', JSON.stringify(result));
    //             if (this.caseData && this.caseData.length > 0 && this.caseData[0].ReportResult__c == 'Pending') {
    //                 if (!result.parentRecords) {
    //                     this.postSanDevBool = false;
    //                 }
    //             }
    //             this.checkDocumentDetailsApp();
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getting Post Sanction Auto Deviations is ', error);
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error',
    //                     message: error.body.message,
    //                     variant: 'error',
    //                     mode: 'sticky'
    //                 })
    //             );
    //             this.dispatchEvent(new CloseActionScreenEvent());
    //         });
    // }
    // @track docApproved = true;
    // checkDocumentDetailsApp() {
    //     this.showSpinner = true;
    //     let docCat = ['Additional Post Sanction Documents', 'Mandatory Post Sanction Documents', 'Property Documents'];
    //     let docStatus = ['OTC', 'PDD', 'Waiver'];
    //     let paramsLoanApp = {
    //         ParentObjectName: 'DocDtl__c',
    //         parentObjFields: ['Id', 'DocTyp__c', 'Appr_Actn__c', 'Criticality__c', 'DocStatus__c', 'DevLvl__c', 'AppvdRmrks__c'],
    //         queryCriteria: ' Where LAN__c = \'' + this.recordId + '\' AND DocCatgry__c  IN (\'' + docCat.join('\', \'') + '\') AND DocStatus__c  IN (\'' + docStatus.join('\', \'') + '\')'
    //         // queryCriteria: ' where LAN__c = \'' + this.recordId + '\' AND APIName__c = \'' + apiName + '\''
    //     }
    //     getSobjectData({ params: paramsLoanApp })
    //         .then((result) => {
    //             console.log('Document Detail Data is', JSON.stringify(result));
    //             // let docApproved = true;
    //             if (result.parentRecords && result.parentRecords.length > 0) {
    //                 result.parentRecords.forEach(item => {
    //                     if (item.Appr_Actn__c != 'Approved') {
    //                         this.docApproved = false;
    //                     }
    //                 });
    //                 this.checkDevRec();
    //                 // if (this.docApproved) {
    //                 // } else {
    //                 //     this.dispatchEvent(
    //                 //         new ShowToastEvent({
    //                 //             title: 'Error',
    //                 //             message: 'All the Documents Needs to be approved by UW before sending it to the Ops',
    //                 //             variant: 'error',
    //                 //             mode: 'sticky'
    //                 //         })
    //                 //     );
    //                 //     this.dispatchEvent(new CloseActionScreenEvent());
    //                 // }
    //             } else {
    //                 this.checkDevRec();
    //             }
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getting Document Detail data is ', error);
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error',
    //                     message: error.body.message,
    //                     variant: 'error',
    //                     mode: 'sticky'
    //                 })
    //             );
    //             this.dispatchEvent(new CloseActionScreenEvent());
    //         });

    // }
    // @track devApproved = true;
    // checkDevRec() {
    //     this.showSpinner = true;
    //     let devCat = ['Legal', 'Post Sanction Auto Deviation', 'Disbursal'];
    //     let paramsLoanApp = {
    //         ParentObjectName: 'Deviation__c',
    //         parentObjFields: ['Id', 'Devia_Desrp__c', 'Appr_Remarks__c', 'Appr_Actn__c', 'Mitigation__c', 'DeviationCategory__c', 'IntLegalRem__c'],
    //         queryCriteria: ' Where LoanAppln__c = \'' + this.recordId + '\' AND DeviationCategory__c  IN (\'' + devCat.join('\', \'') + '\') order by DeviationCategory__c'
    //         // queryCriteria: ' where LAN__c = \'' + this.recordId + '\' AND APIName__c = \'' + apiName + '\''
    //     }
    //     getSobjectData({ params: paramsLoanApp })
    //         .then((result) => {
    //             console.log('Deviation Data is', JSON.stringify(result));
    //             // let DevApproved = true;
    //             if (result.parentRecords && result.parentRecords.length > 0) {
    //                 result.parentRecords.forEach(item => {
    //                     if (item.Appr_Actn__c != 'Approved') {
    //                         this.devApproved = false;
    //                     }
    //                 });
    //                 // this.getValidationReport();
    //                 // this.checkNdcData();
    //                 this.getDisbursementDet();
    //                 // if (this.devApproved) {
    //                 // } else {
    //                 //     this.dispatchEvent(
    //                 //         new ShowToastEvent({
    //                 //             title: 'Error',
    //                 //             message: 'All the Deviations Needs to be approved by UW before sending it to the Ops',
    //                 //             variant: 'error',
    //                 //             mode: 'sticky'
    //                 //         })
    //                 //     );
    //                 //     this.dispatchEvent(new CloseActionScreenEvent());
    //                 // }
    //             } else {
    //                 // this.getValidationReport();
    //                 // this.checkNdcData();
    //                 this.getDisbursementDet();
    //             }
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getting Deviation data is ', error);
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error',
    //                     message: error.body.message,
    //                     variant: 'error',
    //                     mode: 'sticky'
    //                 })
    //             );
    //             this.dispatchEvent(new CloseActionScreenEvent());
    //         });

    // }

    // @track disbursementBool = true;
    // getDisbursementDet() {
    //     let paramsLoanApp = {
    //         ParentObjectName: 'Disbursement__c',
    //         ChildObjectRelName: 'Split_Disbursements__r',
    //         parentObjFields: ['Id',
    //             'ApplicationID__c',
    //             'Appl_Name__c',
    //             'Product__c',
    //             'Scheme__c',
    //             'Loan_Tenu__c',
    //             'Total_Disb_Amt__c',
    //             'Disbur_To__c',
    //             'No_of_Disbur__c',
    //             'Princ_Rec_on__c',
    //             'Princ_Start_Date__c',
    //             'Disbur_No__c',
    //             'Disbur_Desrp__c',
    //             'Date_of_Disbur__c',
    //             'DisbrDiscription__c',
    //             'Disbur_Status__c',
    //             'Loan_Appli__c',
    //             'Loan_Appli__r.DisbursalType__c',
    //             'Pend_Disbur_Amt__c'],
    //         childObjFields: ['Id',
    //             'Disbur_To__c',
    //             'Split_Cheque_Amt__c',
    //             'Date_of_Disbur__c',
    //             'Custo_Name__c',
    //             'Pay_Mode__c',
    //             'Penny_Drop_Nm_Sta__c',
    //             'Fund_Transf_Mode__c',
    //             'Cheq_DD_Date__c',
    //             'Cheq_DD_No__c',
    //             'Effec_Date__c',
    //             'Fedbank_Acc_Nm__c',
    //             'Payable_At__c',
    //             'Fedbank_Acc_No__c',
    //             'Cheq_Favor_Dets__c',
    //             'Remarks__c',
    //             'Cheq_Favor_Acc_No__c',
    //             'Benef_Nm_of_Penny_Drop__c',
    //             'DisburseRela__c',
    //             'Payment_to__c',
    //             'RefId__c',
    //             'ResponseReason__c',
    //             'OpsVer__c',
    //             'DisburseAmt__c'],
    //         queryCriteriaForChild: '',
    //         queryCriteria: ' where Loan_Appli__c = \'' + this.recordId + '\''
    //     }
    //     getSobjectDataWithoutCacheable({ params: paramsLoanApp })
    //         .then((result) => {
    //             console.log('Disbursement Details are', JSON.stringify(result));
    //             if (result && result.length > 0) {
    //                 result.forEach(item => {
    //                     if (item.parentRecord.Total_Disb_Amt__c &&
    //                         item.parentRecord.Disbur_To__c &&
    //                         ((item.parentRecord.Princ_Rec_on__c &&
    //                             item.parentRecord.Princ_Start_Date__c && item.parentRecord.Loan_Appli__c && item.parentRecord.Loan_Appli__r.DisbursalType__c && item.parentRecord.Loan_Appli__r.DisbursalType__c == 'MULTIPLE') || (item.parentRecord.Loan_Appli__c && item.parentRecord.Loan_Appli__r.DisbursalType__c && item.parentRecord.Loan_Appli__r.DisbursalType__c == 'SINGLE')) &&
    //                         item.parentRecord.Date_of_Disbur__c &&
    //                         item.parentRecord.DisbrDiscription__c) {
    //                         if (item.parentRecord.DisbrDiscription__c === 'TRANCHE-1') {
    //                             if (item.ChildReords && item.ChildReords.length > 0) {
    //                                 item.ChildReords.forEach(ite => {
    //                                     if (!ite.Pay_Mode__c ||
    //                                         !ite.Disbur_To__c ||
    //                                         !ite.Split_Cheque_Amt__c == null ||
    //                                         !ite.Fedbank_Acc_Nm__c ||
    //                                         !ite.Payable_At__c) {
    //                                         this.disbursementBool = false;
    //                                     } else {
    //                                         if ((ite.Pay_Mode__c == 'Cheque' || ite.Pay_Mode__c == 'Draft') && (!ite.Cheq_DD_Date__c || !ite.Cheq_DD_No__c)) {
    //                                             this.disbursementBool = false;
    //                                             return;
    //                                         }
    //                                     }
    //                                 })
    //                             } else {
    //                                 this.disbursementBool = false;
    //                                 return;
    //                             }
    //                         }
    //                     } else {
    //                         this.disbursementBool = false;
    //                         return;
    //                     }
    //                 })
    //             }
    //             this.checkDisbAmountVald();
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('getting disbursement detail error= ', error);
    //             //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
    //         });
    // }

    // @track checkDisbAmountBool = true;
    // @track checkDisbSplitPresent = true;
    // @track checkDisbAmtEqual = true;
    // checkDisbAmountVald() {
    //     let paramDisbSplitDisb = {
    //         ParentObjectName: 'Disbursement__c',
    //         ChildObjectRelName: 'Split_Disbursements__r',
    //         parentObjFields: ['Id', 'Split_Disbursement_s_Amount__c', 'Total_Disb_Amt__c', 'DisbrDiscription__c', 'Loan_Appli__r.DisbursedAmount__c', 'Loan_Appli__r.Final_Loan_Disbursal_Amount__c'],
    //         childObjFields: ['Id'],
    //         queryCriteria: ' where Loan_Appli__c = \'' + this.recordId + '\''
    //     }

    //     getSobjectDataWithoutCacheable({ params: paramDisbSplitDisb })
    //         .then((result) => {
    //             console.log('Disb Data to Check Amount is Align------------->', JSON.stringify(result));
    //             var dataReceivedForDisbSplitDisb = result;
    //             if (dataReceivedForDisbSplitDisb) {
    //                 dataReceivedForDisbSplitDisb.forEach(item => {
    //                     if (item && item.parentRecord && item.parentRecord.Loan_Appli__r.DisbursedAmount__c != item.parentRecord.Loan_Appli__r.Final_Loan_Disbursal_Amount__c) {
    //                         this.checkDisbAmtEqual = false;
    //                         return;
    //                     } else
    //                         if (item && item.parentRecord && item.parentRecord.Split_Disbursements__r &&
    //                             "Split_Disbursement_s_Amount__c" in item.parentRecord) {
    //                             const splitSumAmount = item.parentRecord.Split_Disbursement_s_Amount__c;
    //                             const disbAmount = item.parentRecord.Total_Disb_Amt__c ? item.parentRecord.Total_Disb_Amt__c : 0;
    //                             if (splitSumAmount != disbAmount) {
    //                                 this.checkDisbAmountBool = false;
    //                                 return;
    //                             }
    //                         } else
    //                             if (item && item.parentRecord && item.parentRecord.DisbrDiscription__c === 'TRANCHE-1' && !item.parentRecord.Split_Disbursements__r) {
    //                                 this.checkDisbSplitPresent = false;
    //                                 return;
    //                             }
    //                 })
    //             }
    //             this.checkPdcValidation();
    //         })
    //         .catch(error => {
    //             this.showSpinner = false;
    //             console.log('Error in Disb Amount Validation Method: ', JSON.stringify(error));
    //         });
    // }


    // @track pdcFieldsBool = true;
    // @track spdcNotBlank = true;
    // @track spdcCheQuerCount = true;
    // checkPdcValidation() {
    //     this.showSpinner = true;
    //     let pdcType = 'SPDC';
    //     let paramsLoanApp = {
    //         ParentObjectName: 'PDC__c',
    //         parentObjFields: ['Id', 'Loan_Application__c', 'Cheque_Amount__c', 'Cheque_Number_To__c', 'Cheque_Number_From__c', 'No_of_Cheques__c', 'Cheque_Purpose__c', 'Account_No__c', 'MICR_Code__c'],
    //         queryCriteria: ' Where Loan_Application__c = \'' + this.recordId + '\' AND PDC_Type__c = \'' + pdcType + '\' AND Repayment_Account__r.Is_Active__c = true'
    //     }
    //     getSobjectData({ params: paramsLoanApp })
    //         .then((result) => {
    //             console.log('Pdc Data is', JSON.stringify(result));
    //             let count = 0;
    //             if (result.parentRecords && result.parentRecords.length > 0) {
    //                 result.parentRecords.forEach(item => {
    //                     if (item.No_of_Cheques__c) {
    //                         count = count + item.No_of_Cheques__c;
    //                     }
    //                     if (!item.Cheque_Number_To__c || !item.Cheque_Number_From__c || !item.Cheque_Amount__c || !item.Cheque_Purpose__c || !item.Account_No__c || !item.MICR_Code__c) {
    //                         this.pdcFieldsBool = false;
    //                         return;
    //                     }
    //                 });
    //                 if (count < 3) {
    //                     this.spdcCheQuerCount = false;
    //                 }
    //                 // this.checkNdcData();
    //             } else {
    //                 this.spdcNotBlank = false;
    //             }
    //             this.checkNdcData();
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getting Deviation data is ', error);
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error',
    //                     message: error.body.message,
    //                     variant: 'error',
    //                     mode: 'sticky'
    //                 })
    //             );
    //             this.dispatchEvent(new CloseActionScreenEvent());
    //         });
    // }


    // @track ndcQueryExists = false;
    // @track screenNames = new Set();
    // @track sectionNames = new Set();
    // checkNdcData() {
    //     this.showSpinner = true;
    //     let paramsLoanApp = {
    //         ParentObjectName: 'NDC__c',
    //         parentObjFields: ['Id', 'OpsQuery__c', 'ScreenNames__c', 'NDC_Section__c'],
    //         queryCriteria: ' Where LoanAppl__c = \'' + this.recordId + '\' AND IsInvalid__c = false'
    //     }
    //     getSobjectData({ params: paramsLoanApp })
    //         .then((result) => {
    //             console.log('Ndc Data is', JSON.stringify(result));
    //             // let DevApproved = true;
    //             if (result.parentRecords && result.parentRecords.length > 0) {
    //                 result.parentRecords.forEach(item => {
    //                     if (item.OpsQuery__c) {
    //                         if (item.ScreenNames__c) {
    //                             this.screenNames.add(item.ScreenNames__c);
    //                         } else if (item.NDC_Section__c) {
    //                             this.sectionNames.add(item.NDC_Section__c);
    //                         }
    //                     }
    //                 });
    //                 this.ndcDocumentCheckMethod();
    //             } else {

    //                 this.ndcDocumentCheckMethod();
    //             }
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getting Deviation data is ', error);
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error',
    //                     message: error.body.message,
    //                     variant: 'error',
    //                     mode: 'sticky'
    //                 })
    //             );
    //             this.dispatchEvent(new CloseActionScreenEvent());
    //         });
    // }

    // @track ndcDocCheck = [];
    // ndcDocumentCheckMethod() {
    //     this.showSpinner = true;
    //     ndcDocumentCheck({ loanAppId: this.recordId })
    //         .then((result) => {
    //             console.log('Ndc doc check data is', JSON.stringify(result));
    //             if (result && result.length > 0) {
    //                 this.ndcDocCheck = result;
    //                 console.log('ndc doc check ', this.ndcDocCheck);
    //                 console.log('ndc doc length ', this.ndcDocCheck.length);
    //                 this.getVerificationExpDet();
    //             } else {
    //                 this.getVerificationExpDet();
    //             }
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getting ndcDocumentCheck data is ', error);
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error',
    //                     message: error.body.message,
    //                     variant: 'error',
    //                     mode: 'sticky'
    //                 })
    //             );
    //             this.dispatchEvent(new CloseActionScreenEvent());
    //         });
    // }

    // @track expDetails = []
    // getVerificationExpDet() {
    //     checkExpiry({ loanApplicationId: this.recordId })
    //         .then((result) => {
    //             console.log('VerificationExpiry Details', JSON.stringify(result));
    //             // let DevApproved = true;
    //             if (result && result.length > 0) {
    //                 this.expDetails = result;
    //                 this.getValidationReport();
    //             } else {
    //                 this.getValidationReport();
    //             }
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getting checkExpiry is ', error);
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error',
    //                     message: error.body.message,
    //                     variant: 'error',
    //                     mode: 'sticky'
    //                 })
    //             );
    //             this.dispatchEvent(new CloseActionScreenEvent());
    //         });
    // }
    // getValidationReport() {
    //     console.log("inside if DDE CPA Data Entry");
    //     console.log("this.expDetails.length", this.expDetails.length);
    //     getValidationReport({ loanAppId: this.recordId })
    //         .then((result) => {
    //             console.log('resp of validation  ', JSON.stringify(result));
    //             let positiveResp = true;
    //             result.forEach(res => {
    //                 console.log('res.validated false  ', JSON.stringify(res));
    //                 if (res.validated === false) {
    //                     positiveResp = false;
    //                     console.log("Inside if validated");
    //                     let resp = res.applicantName + ' : ' + res.errorMessage;
    //                     // this.dispatchEvent(
    //                     //     new ShowToastEvent({
    //                     //         title: 'Error',
    //                     //         message: resp,
    //                     //         variant: 'error',
    //                     //         mode: 'sticky'
    //                     //     })
    //                     // );
    //                     this.ShowToastEventMe('Error', resp, 'error', 'sticky');
    //                     this.showSpinner = false;
    //                 }
    //             })
    //             if (positiveResp && this.devApproved && this.docApproved && this.expDetails.length == 0 && this.ndcDocCheck.length == 0 && this.sectionNames.size == 0 && this.screenNames.size == 0 && this.disbursementBool && this.pdcFieldsBool && this.spdcCheQuerCount && this.spdcNotBlank && this.checkDisbAmountBool && this.checkDisbSplitPresent && this.checkDisbAmtEqual && this.postSanDevBool) {
    //                 this.handleSendToOps();
    //                 console.log('resp of validation  Positive ');
    //             }
    //             if (this.expDetails.length > 0) {
    //                 let str = ' ';
    //                 this.expDetails.forEach(item => {
    //                     // this.dispatchEvent(
    //                     //     new ShowToastEvent({
    //                     //         title: 'Error',
    //                     //         message: item,
    //                     //         variant: 'error',
    //                     //         mode: 'sticky'
    //                     //     })
    //                     // );verification expired :
    //                     str = str + item + ',';
    //                 })
    //                 if (str.endsWith(',')) {
    //                     str = str.slice(0, -1);
    //                 }
    //                 this.ShowToastEventMe('Error', 'Verification Expired for ' + str, 'error', 'sticky');
    //             }
    //             if (this.devApproved == false) {
    //                 // this.dispatchEvent(
    //                 //     new ShowToastEvent({
    //                 //         title: 'Error',
    //                 //         message: send_to_ops_deviation_appro_error,
    //                 //         variant: 'error',
    //                 //         mode: 'sticky'
    //                 //     })
    //                 // );
    //                 this.ShowToastEventMe('Error', send_to_ops_deviation_appro_error, 'error', 'sticky');
    //                 // this.dispatchEvent(new CloseActionScreenEvent());
    //             }
    //             if (this.disbursementBool == false) {
    //                 this.ShowToastEventMe('Error', 'Tranche and Multi Tranche details has to be mandatorily filled. Atleast one Split Disbursal row has to be there.', 'error', 'sticky');
    //             }

    //             if (this.checkDisbSplitPresent == false) {
    //                 this.ShowToastEventMe('Error', 'Split Disbursement(s) missing for TRANCHE-1. Please provide Split Disbursement Details', 'error', 'sticky');
    //             }

    //             if (this.checkDisbAmountBool == false) {
    //                 this.ShowToastEventMe('Error', 'Sum of Split Disbursement(s) Amount is not aligned with Disbursement Amount. Please provide correct details.', 'error', 'sticky');
    //             }

    //             if (this.checkDisbAmtEqual == false) {
    //                 this.ShowToastEventMe('Error', 'Sum of Disbursement Amount mismatched with Loan Disbursal Amount.', 'error', 'sticky');
    //             }
    //             // if (this.ndcQueryExists) {
    //             //     this.ShowToastEventMe('Error', 'Please respond on query before sending the application back to Ops', 'error', 'sticky');
    //             // }
    //             if (this.screenNames && this.screenNames.size > 0) {
    //                 let strr = Array.from(this.screenNames).join(',');
    //                 console.log('Screen Names are '.strr);
    //                 this.ShowToastEventMe('Error', 'Please respond on Query Before Sending the Application back to Ops : (' + strr + ')', 'error', 'sticky');
    //             }
    //             if (this.sectionNames && this.sectionNames.size > 0) {
    //                 let str = Array.from(this.sectionNames).join(',');
    //                 console.log('Section Names Are '.str);
    //                 this.ShowToastEventMe('Error', 'Please respond on Query Before Sending the Application back to Ops : (' + str + ')', 'error', 'sticky');
    //             }
    //             if (this.ndcDocCheck && this.ndcDocCheck.length > 0) {
    //                 this.ndcDocCheck.forEach(item => {
    //                     this.ShowToastEventMe('Error', item.docCategry + ' : Please Upload Document For ' + item.docDetName + ' on Ndc Screen.', 'error', 'sticky');
    //                 })
    //             }
    //             if (this.docApproved == false) {
    //                 this.ShowToastEventMe('Error', send_to_ops_decoument_appro_error, 'error', 'sticky');
    //                 // this.dispatchEvent(
    //                 //     new ShowToastEvent({
    //                 //         title: 'Error',
    //                 //         message: send_to_ops_decoument_appro_error,
    //                 //         variant: 'error',
    //                 //         mode: 'sticky'
    //                 //     })
    //                 // );
    //                 // this.dispatchEvent(new CloseActionScreenEvent());
    //             }
    //             if (this.pdcFieldsBool == false) {
    //                 this.ShowToastEventMe('Error', 'Please provide all required information for SPDC on Repayment Screen.', 'error', 'sticky');
    //             }
    //             if (!this.postSanDevBool) {
    //                 this.ShowToastEventMe('Error', 'RCU status is Pending. Kindly add applicable deviation', 'error', 'sticky');
    //             }
    //             if (this.spdcCheQuerCount == false) {
    //                 this.ShowToastEventMe('Error', 'Atleast 3 No Of Cheques should be in SPDC', 'error', 'sticky');
    //             }
    //             if (this.spdcNotBlank == false) {
    //                 this.ShowToastEventMe('Error', 'Atleast 1 SPDC record should be there on Repayment Screen', 'error', 'sticky');
    //             }
    //             this.showSpinner = false;
    //             // if () {
    //             //     // this.fireCustomEvent("", "", "");
    //             //     console.log('resp of validation  negitive ');
    //             //     this.showSpinner = false;
    //             //     // this.dispatchEvent(new CloseActionScreenEvent());
    //             // }
    //             console.log('resp of validation   last line ');
    //         })
    //         .catch((err) => {
    //             console.log(" Error occured in getValidationReport   ", err);
    //             this.showSpinner = false;
    //             // this.dispatchEvent(
    //             //     new ShowToastEvent({
    //             //         title: 'Error',
    //             //         message: err.body.message,
    //             //         variant: 'error',
    //             //         mode: 'sticky'
    //             //     })
    //             // );
    //             this.ShowToastEventMe('Error', err.body.message, 'error', 'sticky');
    //             this.dispatchEvent(new CloseActionScreenEvent());
    //         });
    // }
    // handleSendToOps() {
    //     //this.dispatchEvent(new CloseActionScreenEvent());
    //     // this.showSpinner = true;
    //     console.log('loanappId in Savebtn component', this.recordId);
    //     let apiName = 'Crif Auth Login';
    //     let paramsLoanApp = {
    //         ParentObjectName: 'APICoutTrckr__c',
    //         parentObjFields: ['Id', 'LtstRespCode__c', 'IsInvalid__c'],
    //         queryCriteria: ' where LAN__c = \'' + this.recordId + '\' AND APIName__c = \'' + apiName + '\''
    //     }
    //     getSobjectData({ params: paramsLoanApp })
    //         .then((result) => {
    //             console.log('api callout tracker data is', JSON.stringify(result));
    //             if (result.parentRecords && result.parentRecords.length > 0) {
    //                 if (result.parentRecords[0].IsInvalid__c) {
    //                     this.showSpinner = false;
    //                     // this.dispatchEvent(
    //                     //     new ShowToastEvent({
    //                     //         title: 'Error',
    //                     //         message: Send_to_Oops_BRE_Error_Message,
    //                     //         variant: 'error',
    //                     //         mode: 'sticky'
    //                     //     })
    //                     // );
    //                     this.ShowToastEventMe('Error', Send_to_Oops_BRE_Error_Message, 'error', 'sticky');
    //                     this.dispatchEvent(new CloseActionScreenEvent());
    //                 } else {
    //                     this.updateLoanApplicationDetails();
    //                 }
    //             } else {
    //                 this.showSpinner = false;
    //                 // this.dispatchEvent(
    //                 //     new ShowToastEvent({
    //                 //         title: 'Error',
    //                 //         message: Send_to_Oops_BRE_Error_Message,
    //                 //         variant: 'error',
    //                 //         mode: 'sticky'
    //                 //     })
    //                 // );
    //                 this.ShowToastEventMe('Error', Send_to_Oops_BRE_Error_Message, 'error', 'sticky');
    //                 this.dispatchEvent(new CloseActionScreenEvent());
    //             }
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getting api callout tracker data is ', error);
    //             // this.dispatchEvent(
    //             //     new ShowToastEvent({
    //             //         title: 'Error',
    //             //         message: error.body.message,
    //             //         variant: 'error',
    //             //         mode: 'sticky'
    //             //     })
    //             // );
    //             this.ShowToastEventMe('Error', error.body.message, 'error', 'sticky');
    //             this.dispatchEvent(new CloseActionScreenEvent());
    //         });

    // }
    validateSendtoOps() {
        validateData({ loanId: this.recordId })
            .then((result) => {
                console.log('result after calling validateData method ', result);
                if (result && result.length > 0) {
                    this.showSpinner = false;
                    result.forEach(item => {
                        // this.showToastMessage("Error", item, 'error', 'sticky');
                        this.ShowToastEventMe('Error', item, 'error', 'sticky');
                    })
                    this.dispatchEvent(new CloseActionScreenEvent());
                } else {
                    this.updateLoanApplicationDetails();
                }
            })
            .catch((error) => {
                console.log("error occured in validateData", error);

            });
    }
    updateLoanApplicationDetails() {
        let upsertObjectParams = {
            parentRecord: {},
            ChildRecords: [],
            ParentFieldNameToUpdate: ''
        };
        upsertObjectParams.parentRecord.sobjectType = 'LoanAppl__c';
        upsertObjectParams.parentRecord.Id = this.recordId;
        if (this.loanStage == 'Post Sanction') {
            upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Disbursement Initiation';
        } else {
            upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Disbursed';
        }
        upsertObjectParams.parentRecord[subStage.fieldApiName] = 'DI Pool';
        upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.loanApplicationQueueId;
        console.log('upsertObjectParams:', upsertObjectParams);
        upsertSobjDataWIthRelatedChilds({ upsertData: upsertObjectParams })
            .then((result) => {
                console.log('success');
                console.log('result:', JSON.stringify(result));
                console.log('result:', result.parentRecord.Id);
                this.showSpinner = false;
                this.getLoanApplicationData();
                this.dispatchEvent(new CloseActionScreenEvent());
                // const event = new ShowToastEvent({
                //     title: 'Success!',
                //     message: Send_To_Oops_Succes_Message,
                //     variant: 'success',
                //     mode: 'sticky'
                // });
                // this.dispatchEvent(event);
                this.ShowToastEventMe('Success!', Send_To_Oops_Succes_Message, 'success', 'sticky');
                this[NavigationMixin.Navigate]({
                    type: "standard__objectPage",
                    attributes: {
                        objectApiName: "LoanAppl__c",
                        actionName: "list"
                    }
                });

            })
            .catch(error => {
                this.showSpinner = false;
                // this.dispatchEvent(
                //     new ShowToastEvent({
                //         title: 'Error',
                //         message: error.body.message,
                //         variant: 'error',
                //         mode: 'sticky'
                //     })
                // );
                this.ShowToastEventMe('Error', error.body.message, 'error', 'sticky');
                this.dispatchEvent(new CloseActionScreenEvent());
                console.log('error while updating record:' + JSON.stringify(error));

            });
    }
    @track loanApplicationRecord;
    getLoanApplicationData() {
        let paramsLoanApp = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Id', 'Applicant__c'],
            queryCriteria: ' where Id = \'' + this.recordId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Loan App Data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.loanApplicationRecord = result.parentRecords[0];
                    this.handleGenerateDocuments();
                    this.handleGenerateDocumentCam();
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting loan app data is ', error);

            });
    }
    @track DocumentDetaiId;
    async handleGenerateDocuments() {
        try {
            // this.showSpinner = true;
            const result = await createDocumentDetail({
                applicantId: this.loanApplicationRecord.Applicant__c,
                loanAppId: this.loanApplicationRecord.Id,
                docCategory: 'Disbursement Memo',
                docType: 'Disbursement Memo',
                docSubType: 'Disbursement Memo',
                availableInFile: false
            });

            console.log('createDocumentDetailRecord result ', result);
            this.DocumentDetaiId = result;
            console.log('createDocumentDetailRecord DocumentDetaiId ', this.DocumentDetaiId);

            let pageUrl = PageURLDisbusementMemo + this.loanApplicationRecord.Id;

            const pdfData = {
                pageUrl: pageUrl,
                docDetailId: this.DocumentDetaiId,
                fileName: 'Disbursement Memo.pdf'
            };

            this.generateDocument(pdfData, 'Disbursement Memo', 'Disbursement Memo', 'Disbursement Memo', this.DocumentDetaiId);
            // this.updateApplicantBanking();
            // this.fileUploadHandler();
        } catch (err) {
            this.showSpinner = false;
            console.log(" createDocumentDetailRecord error===", err);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: err.body.message,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
            this.dispatchEvent(new CloseActionScreenEvent());


        }
    }

    @track DocumentDetaiIdCam;
    async handleGenerateDocumentCam() {
        try {
            // this.showSpinner = true;
            const result = await createDocumentDetail({
                applicantId: this.loanApplicationRecord.Applicant__c,
                loanAppId: this.loanApplicationRecord.Id,
                docCategory: 'CAM Report',
                docType: 'CAM Report',
                docSubType: 'CAM Report',
                availableInFile: false
            });

            console.log('createDocumentDetailRecord result ', result);
            this.DocumentDetaiIdCam = result;
            console.log('createDocumentDetailRecord DocumentDetaiId ', this.DocumentDetaiIdCam);

            let pageUrl = PageURLCAMReporrt + this.loanApplicationRecord.Id;

            const pdfData = {
                pageUrl: pageUrl,
                docDetailId: this.DocumentDetaiIdCam,
                fileName: 'CAM Report.pdf'
            };

            this.generateDocumentCam(pdfData, 'CAM Report', 'CAM Report', 'CAM Report', this.DocumentDetaiIdCam);
            // this.updateApplicantBanking();
            // this.fileUploadHandler();
        } catch (err) {
            this.showSpinner = false;
            console.log(" createDocumentDetailRecord error in Cam===", err);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: err.body.message,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
            this.dispatchEvent(new CloseActionScreenEvent());


        }
    }

    generateDocumentCam(pdfData, docCat, docTyp, docSubTyp, docId) {
        generateDocument({ wrapObj: pdfData })
            .then((result) => {
                if (result == 'success') {
                    this.forLatestDocDetailRecCam(docCat, docTyp, docSubTyp, docId);
                    // this.refreshDocTable();
                } else {
                    console.log('error in generating Document', result);
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.showSpinner = false;
                }
                //this.updateApplicantBanking();
                //this.fileUploadHandler();
            })
            .catch((err) => {
                this.showSpinner = false;
                console.log(" createDocumentDetailRecord error===", err);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: err.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
                console.log(" createDocumentDetailRecord error===", err);
            });
    }

    forLatestDocDetailRecCam(docCat, docTyp, docSubTyp, docId) {
        console.log('document details in forLatestDocDetailRec ###1456', docTyp, docCat, docSubTyp, docId);
        let listOfAllParent = [];
        let paramForIsLatest = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'Appl__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c', 'AppvdRmrks__c'],
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this.loanApplicationRecord.Id + '\' AND Appl__c = \'' + this.loanApplicationRecord.Applicant__c + '\' AND DocCatgry__c = \'' + docCat + '\' AND DocTyp__c = \'' + docTyp + '\' AND DocSubTyp__c = \'' + docSubTyp + '\''
        }
        getSobjectData({ params: paramForIsLatest })
            .then((result) => {
                console.log('islatestdata 13899999', docId);
                if (result.parentRecords) {
                    listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
                }
                let oldRecords = []
                oldRecords = listOfAllParent.filter(record => record.Id !== docId);
                //console.log('oldRecords>>>>>'+JSON.stringify(oldRecords))
                let isLatestFalseRecs = []
                isLatestFalseRecs = oldRecords.map(record => {
                    return { ...record, IsLatest__c: false };
                });
                let obj = {
                    Id: docId,
                    NDCDataEntry__c: 'Completed',
                    AppvdRmrks__c: isLatestFalseRecs && isLatestFalseRecs.length > 0 ? isLatestFalseRecs[0].AppvdRmrks__c : ''
                }
                isLatestFalseRecs.push(obj);
                console.log('isLatestFalseRecs>>>>>' + JSON.stringify(isLatestFalseRecs))
                upsertMultipleRecord({ params: isLatestFalseRecs })
                    .then(result => {
                        // this.updateLoanApplicationDetails();
                        console.log('result ' + JSON.stringify(result));
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
                        this.dispatchEvent(new CloseActionScreenEvent());
                        console.log('778' + error)
                    })
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log(" createDocumentDetailRecord error===", error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
                console.log('Error In getting Document Details  ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    generateDocument(pdfData, docCat, docTyp, docSubTyp, docId) {
        generateDocument({ wrapObj: pdfData })
            .then((result) => {
                if (result == 'success') {
                    this.forLatestDocDetailRec(docCat, docTyp, docSubTyp, docId);
                    // this.refreshDocTable();
                } else {
                    console.log('error in generating Document', result);
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.showSpinner = false;
                }
                //this.updateApplicantBanking();
                //this.fileUploadHandler();
            })
            .catch((err) => {
                this.showSpinner = false;
                console.log(" createDocumentDetailRecord error===", err);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: err.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
                console.log(" createDocumentDetailRecord error===", err);
            });
    }
    forLatestDocDetailRec(docCat, docTyp, docSubTyp, docId) {
        console.log('document details in forLatestDocDetailRec ###1456', docTyp, docCat, docSubTyp, docId);
        let listOfAllParent = [];
        let paramForIsLatest = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'AppvdRmrks__c', 'Appl__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c'],
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this.loanApplicationRecord.Id + '\' AND Appl__c = \'' + this.loanApplicationRecord.Applicant__c + '\' AND DocCatgry__c = \'' + docCat + '\' AND DocTyp__c = \'' + docTyp + '\' AND DocSubTyp__c = \'' + docSubTyp + '\''
        }
        getSobjectData({ params: paramForIsLatest })
            .then((result) => {
                console.log('islatestdata 13899999', docId);
                if (result.parentRecords) {
                    listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
                }
                let oldRecords = []
                oldRecords = listOfAllParent.filter(record => record.Id !== docId);
                //console.log('oldRecords>>>>>'+JSON.stringify(oldRecords))
                let isLatestFalseRecs = []
                isLatestFalseRecs = oldRecords.map(record => {
                    return { ...record, IsLatest__c: false };
                });
                let obj = {
                    Id: docId,
                    AppvdRmrks__c: isLatestFalseRecs && isLatestFalseRecs.length > 0 ? isLatestFalseRecs[0].AppvdRmrks__c : ''
                }
                isLatestFalseRecs.push(obj);
                console.log('isLatestFalseRecs>>>>>' + JSON.stringify(isLatestFalseRecs))
                upsertMultipleRecord({ params: isLatestFalseRecs })
                    .then(result => {
                        // this.updateLoanApplicationDetails();
                        console.log('result ' + JSON.stringify(result));
                    }).catch(error => {
                        this.showSpinner = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Error While updating DM Records',
                                variant: 'error',
                                mode: 'sticky'
                            })
                        );
                        this.dispatchEvent(new CloseActionScreenEvent());
                        console.log('778' + error)
                    })

            })
            .catch((error) => {
                this.showSpinner = false;
                console.log(" createDocumentDetailRecord error===", error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error Occured while getting latest Disbursement Memo',
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
                console.log('Error In getting Document Details  ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    ShowToastEventMe(title, message, variant, mode) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: mode
            })
        );
    }
    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    noBtn() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}