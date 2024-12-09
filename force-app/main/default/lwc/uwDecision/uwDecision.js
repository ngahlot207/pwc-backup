import { LightningElement, track, wire, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getRecord , createRecord} from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import UserNameFIELD from '@salesforce/schema/User.Name';
import UserIDFIELD from '@salesforce/schema/User.Id';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';
import getSobjectDat from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import getValidationReport from "@salesforce/apex/ValidateRequiredFieldsAndDoc.getValidationReport";
import validateData from "@salesforce/apex/UWApprovalValidation.validateData";
import getRetriggerData from '@salesforce/apex/ChangeSummaryHandler.getRetriggerData';

// Custom labels
import UwDecision_ReqFields_ErrorMessage from '@salesforce/label/c.UwDecision_ReqFields_ErrorMessage';
import UwDecision_Approve_ErrorMessage from '@salesforce/label/c.UwDecision_Approve_ErrorMessage';
import UwDecision_Update_SuccessMessage from '@salesforce/label/c.UwDecision_Update_SuccessMessage';
import UwDecision_Deviation_ErrorMessage from '@salesforce/label/c.UwDecision_Deviation_ErrorMessage';
import UwDecision_PropDetails_ErrorMessage from '@salesforce/label/c.UwDecision_PropDetails_ErrorMessage';
import UwDecision_PD_ErrorMessage from '@salesforce/label/c.UwDecision_PD_ErrorMessage';
import UwDecision_TechCase_ErrorMessage from '@salesforce/label/c.UwDecision_TechCase_ErrorMessage';
import UwDecision_NegativPD_ErrorMessage from '@salesforce/label/c.UwDecision_NegativPD_ErrorMessage';
import UwDecision_DevReject_ErrorMessage from '@salesforce/label/c.UwDecision_DevReject_ErrorMessage';
import UwDecision_Repayment_ErrorMessage from '@salesforce/label/c.UwDecision_Repayment_ErrorMessage';
import UwDecision_Eligibility_ErrorMessage from '@salesforce/label/c.UwDecision_Eligibility_ErrorMessage';
import Sequence_API_Success_Message from '@salesforce/label/c.Sequence_API_Success_Message';

//Integration Message Obj Fields Refernces
import INTEGRATION_MSG_OBJECT from "@salesforce/schema/IntgMsg__c";
import REFERENCE_ID_FIELD from "@salesforce/schema/IntgMsg__c.RefId__c";
import REFERENCE_OBJ_API_FIELD from "@salesforce/schema/IntgMsg__c.RefObj__c";
import INTEGRATION_MSG_NAME_FIELD from "@salesforce/schema/IntgMsg__c.Name";
import BU_FIELD from "@salesforce/schema/IntgMsg__c.BU__c";
import SERVICE_NAME_FIELD from "@salesforce/schema/IntgMsg__c.Svc__c";
import IS_ACTIVE_FIELD from "@salesforce/schema/IntgMsg__c.IsActive__c";
import STATUS_FIELD from "@salesforce/schema/IntgMsg__c.Status__c";


export default class UWDecision extends NavigationMixin(LightningElement) {
    customLabel = {
        UwDecision_ReqFields_ErrorMessage,
        UwDecision_Approve_ErrorMessage,
        UwDecision_Update_SuccessMessage,
        UwDecision_Deviation_ErrorMessage,
        UwDecision_PropDetails_ErrorMessage,
        UwDecision_PD_ErrorMessage,
        UwDecision_TechCase_ErrorMessage,
        UwDecision_NegativPD_ErrorMessage,
        UwDecision_DevReject_ErrorMessage,
        UwDecision_Repayment_ErrorMessage,
        UwDecision_Eligibility_ErrorMessage,
        Sequence_API_Success_Message
    }
    @api recordId;
    @api hasEditAccess;
    @track userId = Id;
    @track currentUserName;
    @track SanLoanAmt;
    @track currentDateTime;
    @track decRemarks;
    @track RecoComment1;
    @track RecoComment2;
    @track RecoComment3;
    @track RecoComment4;
    @track desableSubmit = true;
    @track isReadOnly = false;
    @track loanApplicationQueueId;
    @track employeeLevel = '';
    @track refreshPage = {};
    @track forwardAppNdSoft = false;
    @track retval = false;
    @track chargeval;
    arr = [];
    devLevel;
    chargeCode = '500131';
    caseRecordTypes = [];
    notInForwardState = true;
    loanApplicationName;
    currentUserId;
    Decisionvalue;
    lookupId;
    reasonId;
    retUser;
    emprole;
    isvalid;
    filterConditionForLookup;
    forward = false;
    reject = false;
    Approve = false;
    returnTo = false;
    softApprove = false;
    trueOnRejection = false;
    trueOnForward = false;
    showSpinner = false;
    saveSubscription = null;
    homeLone = 'Home Loan';
    stLAP = 'Small Ticket LAP';
    LAP = 'Loan Against Property';
    decType = [];
    divdevLevel;
    acmrole;
    rcmrole;
    zcmrole;
    ncmrole;
    chrole;


    // get currentUserInfo
    @wire(getRecord, { recordId: Id, fields: [UserNameFIELD, UserIDFIELD] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
            this.currentUserId = data.fields.id;
        } else if (error) {
            this.error = error;
        }
    }

    @track productType;
    @track stage;
    @track finAppId;
    // Method to get the Loan Application Data
    getLoanAppData() {
        return new Promise((resolve, reject) => {
            let paramsLoanApp = {
                ParentObjectName: 'LoanAppl__c',
                parentObjFields: ['Id', 'Product__c', 'Stage__c', 'SubStage__c', 'Decision_Value__c', 'SanLoanAmt__c', 'Loan_Tenure_Months__c', 'InsAmt__c', 'FirstApprovalDate__c', 'PrsnldetailsofPromotrs__c', 'BDApplicantCoapp__c', 'IncomerelateComm__c', 'AddationalComm__c', 'FinnoneAppid__c'],
                queryCriteria: ' where Id = \'' + this.recordId + '\' '
            }
            getSobjectDat({ params: paramsLoanApp })
                .then((result) => {
                    let arr = [];
                    if (result.parentRecords && result.parentRecords.length > 0) {
                        this.loanApplicationRecord = { ...result.parentRecords[0] };
                        resolve(this.loanApplicationRecord);
                        this.productType = this.loanApplicationRecord.Product__c;
                        this.stage = this.loanApplicationRecord.Stage__c;
                        this.finAppId = this.loanApplicationRecord.FinnoneAppid__c;
                        if(this.productType === 'Home Loan' || this.productType == 'Small Ticket LAP'){
                            if (this.loanApplicationRecord.Stage__c == "UnderWriting" && (this.loanApplicationRecord.Decision_Value__c != "Forward for Approve" && this.loanApplicationRecord.Decision_Value__c != "Forward for Review" && this.loanApplicationRecord.Decision_Value__c != "Forward for Soft Approval")) {
                                let arr2 = [
                                    { value: "Approve", label: "Approve" },
                                    { value: "Soft Approve", label: "Soft Approve" },
                                    { value: "Forward for Soft Approval", label: "Forward for Soft Approval" },
                                    { value: "Forward for Approve", label: "Forward for Approve" },
                                    { value: "Forward for Review", label: "Forward for Review" },
                                    { value: "Return to CPA", label: "Return to CPA" },

                                ]

                                arr = [...arr2, ...arr];
                                this.decType = [];
                                this.decType = [...arr, ...this.decType];
                            }

                            if (this.loanApplicationRecord.Decision_Value__c == "Forward for Review") {
                                let arr2 = [
                                    { value: "Forward for Approve", label: "Forward for Approve" },
                                    // { value: "Forward for Soft Approval", label: "Forward for Soft Approval" },//LAK-8548 
                                    { value: "Forward for Review", label: "Forward for Review" },
                                    { value: "Return to CPA", label: "Return to CPA" },
                                    { value: "Send Back to UW", label: "Send Back to UW" } //LAK-6473
                                ]

                                arr = [...arr2, ...arr];
                                this.decType = [];
                                this.decType = [...arr, ...this.decType];
                            }

                            if (this.loanApplicationRecord.Decision_Value__c == "Forward for Soft Approval" && this.loanApplicationRecord.Stage__c == "UnderWriting") {
                                let arr2 = [
                                    { value: "Soft Approve", label: "Soft Approve" },
                                    { value: "Forward for Approve", label: "Forward for Approve" },
                                    { value: "Forward for Soft Approval", label: "Forward for Soft Approval" },
                                    { value: "Forward for Review", label: "Forward for Review" },
                                    { value: "Return to CPA", label: "Return to CPA" },
                                    { value: "Send Back to UW", label: "Send Back to UW" } //LAK-6473
                                ]

                                arr = [...arr2, ...arr];
                                this.decType = [];
                                this.decType = [...arr, ...this.decType];
                            }

                            if (this.loanApplicationRecord.Decision_Value__c == "Forward for Approve" && this.loanApplicationRecord.Stage__c == "UnderWriting") {
                                let arr2 = [
                                    { value: "Approve", label: "Approve" },
                                    { value: "Soft Approve", label: "Soft Approve" },
                                    { value: "Forward for Approve", label: "Forward for Approve" },
                                    { value: "Forward for Soft Approval", label: "Forward for Soft Approval" },
                                    { value: "Forward for Review", label: "Forward for Review" },
                                    { value: "Return to CPA", label: "Return to CPA" },
                                    { value: "Send Back to UW", label: "Send Back to UW" } //LAK-6473
                                ]

                                arr = [...arr2, ...arr];
                                this.decType = [];
                                this.decType = [...arr, ...this.decType];
                            }


                            if (this.loanApplicationRecord.Decision_Value__c == "Forward for Approve" && this.loanApplicationRecord.Stage__c == "Soft Sanction") {
                                let arr2 = [
                                    { value: "Approve", label: "Approve" },
                                    { value: "Forward for Approve", label: "Forward for Approve" },
                                    { value: "Forward for Review", label: "Forward for Review" },
                                    { value: "Return to CPA", label: "Return to CPA" },
                                    { value: "Send Back to UW", label: "Send Back to UW" } //LAK-6473
                                ]

                                arr = [...arr2, ...arr];
                                this.decType = [];
                                this.decType = [...arr, ...this.decType];
                            }


                            //This is for Soft Saction Stage
                            if ((this.loanApplicationRecord.Decision_Value__c != "Forward for Approve" && this.loanApplicationRecord.Decision_Value__c != "Forward for Review" && this.loanApplicationRecord.Decision_Value__c != "Forward for Soft Approval") && this.loanApplicationRecord.Stage__c == "Soft Sanction") {
                                let arr2 = [
                                    { value: "Approve", label: "Approve" },
                                    { value: "Forward for Approve", label: "Forward for Approve" },
                                    { value: "Forward for Review", label: "Forward for Review" },
                                    { value: "Return to CPA", label: "Return to CPA" },
                                ]

                                arr = [...arr2, ...arr];
                                this.decType = [];
                                this.decType = [...arr, ...this.decType];
                            }
                        }
                        //LAK-7332 UW Decision for BIL
                        else if(this.productType == 'Business Loan' || this.productType == 'Personal Loan'){
                            if (this.loanApplicationRecord.Stage__c == "UnderWriting" && (this.loanApplicationRecord.Decision_Value__c != "Forward for Approve" && this.loanApplicationRecord.Decision_Value__c != "Forward for Review" )) {
                                let arr2 = [
                                    { value: "Approve", label: "Approve" },
                                    { value: "Forward for Approve", label: "Forward for Approve" },
                                    { value: "Forward for Review", label: "Forward for Review" },
                                    { value: "Return to CPA", label: "Return to CPA" },

                                ]

                                arr = [...arr2, ...arr];
                                this.decType = [];
                                this.decType = [...arr, ...this.decType];
                            }

                            if (this.loanApplicationRecord.Decision_Value__c == "Forward for Review") {
                                let arr2 = [
                                    { value: "Forward for Approve", label: "Forward for Approve" }, 
                                    { value: "Forward for Review", label: "Forward for Review" },
                                    { value: "Return to CPA", label: "Return to CPA" },
                                    { value: "Send Back to UW", label: "Send Back to UW" } //LAK-6473
                                ]

                                arr = [...arr2, ...arr];
                                this.decType = [];
                                this.decType = [...arr, ...this.decType];
                            }

                           

                            if (this.loanApplicationRecord.Decision_Value__c == "Forward for Approve" && this.loanApplicationRecord.Stage__c == "UnderWriting") {
                                let arr2 = [
                                    { value: "Approve", label: "Approve" },
                                    { value: "Forward for Approve", label: "Forward for Approve" },
                                    { value: "Forward for Review", label: "Forward for Review" },
                                    { value: "Return to CPA", label: "Return to CPA" },
                                    { value: "Send Back to UW", label: "Send Back to UW" } //LAK-6473
                                ]

                                arr = [...arr2, ...arr];
                                this.decType = [];
                                this.decType = [...arr, ...this.decType];
                            }


                            
                        } 


                        if (typeof this.loanApplicationRecord.PrsnldetailsofPromotrs__c !== 'undefined') {
                            this.RecoComment1 = this.loanApplicationRecord.PrsnldetailsofPromotrs__c.toUpperCase();
                        }
                        if (typeof this.loanApplicationRecord.BDApplicantCoapp__c !== 'undefined') {
                            this.RecoComment2 = this.loanApplicationRecord.BDApplicantCoapp__c.toUpperCase();
                        }
                        if (typeof this.loanApplicationRecord.IncomerelateComm__c !== 'undefined') {
                            this.RecoComment3 = this.loanApplicationRecord.IncomerelateComm__c.toUpperCase();
                        }
                        if (typeof this.loanApplicationRecord.AddationalComm__c !== 'undefined') {
                            this.RecoComment4 = this.loanApplicationRecord.AddationalComm__c.toUpperCase();
                        }
                    }

                })
                .catch((error) => {
                    reject(error);
                });
        });
    }
    connectedCallback() {
        this.getLoanAppData();
        this.getSPDDuser();
        this.updateCurrentDateTime();
        // this.areAllUwVerifiedChecked();

        if (this.hasEditAccess === false) {
            this.isReadOnly = true;
            this.desableSubmit = true;
        }

        setTimeout(() => {
            this.showSpinner = false;
        }, 2000);

        let grpName = 'CPA POOL';
        let type = 'Queue';
        let params = {
            ParentObjectName: 'Group',
            parentObjFields: ["Id", "Name"],

            queryCriteria: ' where name = \'' + grpName + '\' AND Type = \'' + type + '\''
        };
        getSobjectDatawithRelatedRecords({ params: params })
            .then((res) => {

                this.loanApplicationQueueId = res.parentRecord.Id;

            })
    }


    // Method to get the Deviation Level of deviation records
    getDivDevLevel() {
        return new Promise((resolve, reject) => {
            let paramsLoanApp = {
                ParentObjectName: 'Deviation__c',
                parentObjFields: ['Id', 'Req_Apprv_Level__c', 'Appr_Actn__c'],
                queryCriteria: ' where LoanAppln__c = \'' + this.recordId + '\' AND (Dev_Type__c =\'Manual\' OR (Dev_Type__c =\'System\' AND Status__c=\'Active\'))'
            };


            getSobjectDat({ params: paramsLoanApp })
                .then((result) => {
                    let count = 0;
                    if (result?.parentRecords?.length != undefined && result?.parentRecords?.length > 0) {
                        result.parentRecords.forEach(element => {
                            if (element.Appr_Actn__c !== "Rejected") { count++ }
                        });

                        this.divdevLevel = result.parentRecords[0].Req_Apprv_Level__c;
                        console.log('this.divdevLevel', this.divdevLevel);

                        if (count === result.parentRecords.length) {
                            if (this.devLevel >= this.divdevLevel) {
                                this.retval2 = true;
                                this.rejectVal = true;
                            } else {
                                this.retval2 = false;
                            }
                        } else {
                            this.rejectVal = false;
                        }

                        resolve(this.rejectVal);
                    } else {
                        this.retval2 = true;
                        resolve(this.retval2);
                        this.rejectVal = true;
                        resolve(this.rejectVal);
                    }
                })
                .catch((error) => {
                    reject(error);
                });
        });
    }

    // Method to get the SPDD user record
    getSPDDuser() {
        let paramsLoanApp = {
            ParentObjectName: 'SPDD_Approval_Config__c',
            parentObjFields: ['Id', 'Emp__c', 'Sanction_Amt__c', 'Dev_Level__c'],
            queryCriteria: ' where Product__c INCLUDES(\'' + this.homeLone + '\',\'' + this.LAP + '\',\'' + this.stLAP + '\') '
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {

                result.parentRecords.forEach(element => {
                    if (element.Emp__c == this.lookupId) {
                        this.employeeLevel = element.Dev_Level__c;
                    }
                });

            })
            .catch((error) => {
            });
    }

    handleLookupFieldChange(event) {
        if (event.detail) {
            this.lookupId = event.detail.id;
            this.allAppl = [];
            this.getSPDDuser();
        }
    }

    get employeeLevelToRender() {
        if (this.lookupId) {
            return this.employeeLevel ? this.employeeLevel : '';
        }
        return '';
    }

    handleInputChange(event) {
        this.decRemarks = event.detail.value.toUpperCase();;
    }

    handleRecoInputChange(event) {

        let valu = event.detail.value.toUpperCase();;
        let val = event.target.dataset.name;
        if (val == "id1") {
            this.RecoComment1 = valu;
        } else if (val == "id2") {
            this.RecoComment2 = valu;
        } else if (val == "id3") {
            this.RecoComment3 = valu;
        } else if (val == "id4") {
            this.RecoComment4 = valu;
        }
    }
    // Method to get the Current Date and Time
    updateCurrentDateTime() {
        let d = new Date();
        let newD = new Date(d.getTime());
        this.currentDateTime = newD.toISOString();

    }

    handleChange(event) {
        this.rejectRsn = '';
        this.Decisionvalue = event.detail.value;
        this.updateCurrentDateTime();

        if (this.Decisionvalue == "Forward for Review" || this.Decisionvalue == "Forward for Soft Approval" || this.Decisionvalue == "Forward for Approve") {
            this.forward = true;
            this.Approve = false;
            this.returnTo = false;
            this.softApprove = false;
            this.desableSubmit = false;
            this.notInForwardState = false;
            this.trueOnForward = true;
            this.forwardAppNdSoft = true;
            this.emprole = 'UW';
            this.acmrole = 'ACM';
            this.rcmrole = 'RCM';
            this.zcmrole = 'ZCM';
            this.ncmrole = 'NCM';
            this.chrole = 'CH';
            this.filterConditionForLookup = 'EmpRole__c IN(\'' + this.emprole + '\',\'' + this.chrole + '\',\'' + this.acmrole + '\',\'' + this.rcmrole + '\',\'' + this.zcmrole + '\',\'' + this.ncmrole + '\') ' + 'AND Employee__c != \'' + this.userId + '\''
        } else if (this.Decisionvalue == "Approve") {
            this.forward = false;
            this.Approve = true;
            this.returnTo = false;
            this.softApprove = false;
            this.desableSubmit = false;
            this.notInForwardState = true;
            this.trueOnForward = true;
            this.forwardAppNdSoft = true;
        }
        else if (this.Decisionvalue == "Soft Approve") {
            this.forward = false;
            this.Approve = false;
            this.returnTo = false;
            this.softApprove = true;
            this.desableSubmit = false;
            this.notInForwardState = true;
            this.trueOnForward = true;
            this.forwardAppNdSoft = true;

        } else if (this.Decisionvalue == "Return to CPA") {
            this.forward = false;
            this.Approve = false;
            this.returnTo = true;
            this.softApprove = false;
            this.desableSubmit = false;
            this.notInForwardState = true;
            this.trueOnForward = false;
            this.forwardAppNdSoft = false;
        }
        //LAK-6473
        else if (this.Decisionvalue == "Send Back to UW") {
            this.forward = true;
            this.Approve = false;
            this.returnTo = false;
            this.softApprove = false;
            this.desableSubmit = false;
            this.notInForwardState = false;
            this.trueOnForward = true;
            this.forwardAppNdSoft = true;
            this.emprole = 'UW';
            this.filterConditionForLookup = 'EmpRole__c IN(\'' + this.emprole + '\') ' + 'AND Employee__c != \'' + this.userId + '\''

        }
    }

    @track changeSummaryData = [];

    // areAllUwVerifiedChecked() {
        //     getRetriggerData({ loanAppId: this.recordId })
            //         .then((result) => {
                //             //console.log('Change Summary data', JSON.stringify(result));

                //             result.forEach(row1 => {
                

                //             });


                //             this.changeSummaryData = JSON.parse(JSON.stringify(result));
                
                //             console.log('changeSummaryData', this.changeSummaryData);
            //         })
            //         .catch((error) => {
                //             console.log('Error In getting change summary data is ', error);
                
            //         });
        
            //         const changeSummaryRecords = this.changeSummaryData; // Assuming this.changeSummaryData holds the data
    
            //         // Loop through all the records and check if any of the UW Verified checkboxes is unchecked
            //         for (let i = 0; i < changeSummaryRecords.length; i++) {
                //             if (!changeSummaryRecords[i].uwReviewed) {
                    //                 return false; // Return false as soon as we find an unchecked checkbox
                //             }
    //         }

            //         // If all checkboxes are checked, return true
            //         return true;


    // }


    handleSubmit() {
        this.isvalid = true;

        
        // if ((this.stage == 'UnderWriting' || this.stage == 'Post Sanction') && (this.productType == 'Business Loan' || this.productType == 'Personal Loan') && (this.Decisionvalue == 'Approve' || this.Decisionvalue == 'Soft Approve' || this.Decisionvalue == 'Forward for Approve' || this.Decisionvalue == 'Forward for Soft Approval') && !this.areAllUwVerifiedChecked()) {
            //     this.isvalid = false;
            //     this.showToastMessage("Error", "Please select all UW Verified checkboxes on change summary", "error", "sticky");
            
        // }

        if (this.Decisionvalue == 'Soft Approve' && (!this.validateForm())) {
            this.isvalid = false;
            this.showToastMessage("Error", this.customLabel.UwDecision_ReqFields_ErrorMessage, "error", "sticky");

        } else if (this.Decisionvalue == 'Approve' && (!this.validateForm())) {
            this.isvalid = false;
            this.showToastMessage("Error", this.customLabel.UwDecision_ReqFields_ErrorMessage, "error", "sticky");

        }
        else if (this.Decisionvalue == 'Return to CPA' && (!this.validateForm())) {
            this.isvalid = false;
            this.showToastMessage("Error", this.customLabel.UwDecision_ReqFields_ErrorMessage, "error", "sticky");
        }
        //LAK-6473
        else if ((this.Decisionvalue == 'Forward for Review' || this.Decisionvalue == 'Forward for Soft Approval' || this.Decisionvalue == 'Forward for Approve' || this.Decisionvalue == 'Send Back to UW') && ((!this.validateForm()) || (!this.checkValidityLookup()))) {
            this.isvalid = false;
            this.showToastMessage("Error", this.customLabel.UwDecision_ReqFields_ErrorMessage, "error", "sticky");

        }

        if (this.isvalid) {
            this.positiveResp = true;
            if (this.Decisionvalue == 'Approve') {
                const obje = {
                    sobjectType: "LoanAppl__c",
                    Id: this.recordId,
                    Stage__c: 'Post Sanction',
                    SubStage__c: 'Data Entry Pool',
                    OwnerId: this.loanApplicationQueueId,
                    Status__c: 'approved',
                    LatestSanctionDate__c: this.currentDateTime,
                    PrsnldetailsofPromotrs__c: this.RecoComment1,
                    BDApplicantCoapp__c: this.RecoComment2,
                    IncomerelateComm__c: this.RecoComment3,
                    AddationalComm__c: this.RecoComment4,
                    Decision_Value__c: this.Decisionvalue
                }

                validateData({ decision: this.Decisionvalue, loanId: this.recordId })
                    .then((result) => {
                        if (result.length > 0) {
                            this.positiveResp = false;
                            result.forEach((res) => {
                                this.showToastMessage("Error", res, "error", "sticky");
                            });
                        }
                        if (this.positiveResp == true) {
                            this.upsertDataMethod(obje);
                            // this.updateDeviationData();
                        }
                    })
                    .catch((error) => {
                    });

            }
            else if (this.Decisionvalue == 'Soft Approve') {
                const obje = {
                    sobjectType: "LoanAppl__c",
                    Id: this.recordId,
                    Stage__c: 'Soft Sanction',
                    SubStage__c: 'Additional Data Entry Pool',
                    OwnerId: this.loanApplicationQueueId,
                    Status__c: 'Soft Approved',
                    LatestSanctionDate__c: this.currentDateTime,
                    PrsnldetailsofPromotrs__c: this.RecoComment1,
                    BDApplicantCoapp__c: this.RecoComment2,
                    IncomerelateComm__c: this.RecoComment3,
                    AddationalComm__c: this.RecoComment4,
                    Decision_Value__c: this.Decisionvalue
                }
                validateData({ decision: this.Decisionvalue, loanId: this.recordId })
                    .then((result) => {
                        if (result.length > 0) {
                            result.forEach((res) => {
                                this.showToastMessage("Error", res, "error", "sticky");
                            });
                        } else {
                            this.upsertDataMethod(obje);
                            // this.updateDeviationData();
                        }
                    })
                    .catch((error) => {
                    });
            }
            else if (this.Decisionvalue == 'Return to CPA') {
                const obje = {
                    sobjectType: "LoanAppl__c",
                    Id: this.recordId,
                    Stage__c: 'DDE',
                    SubStage__c: 'Query Pool',
                    OwnerId: this.loanApplicationQueueId,
                    Decision_Value__c: this.Decisionvalue
                }
                this.upsertDataMethod(obje);

            }
            else if (this.Decisionvalue == 'Forward for Review') {

                /*     findDuplicateDocs({loanId: this.recordId})
                     .then((result) => {
                         console.log('Hi i am in findDuplicateDocs');
                         if (result.length > 0) {
                          console.log('result of duplicate doc',result);   
                            
                         }
         
                     })
                     .catch((error) => {
                     }); */

                const obje = {
                    sobjectType: "LoanAppl__c",
                    Id: this.recordId,
                    OwnerId: this.lookupId,
                    PrsnldetailsofPromotrs__c: this.RecoComment1,
                    BDApplicantCoapp__c: this.RecoComment2,
                    IncomerelateComm__c: this.RecoComment3,
                    AddationalComm__c: this.RecoComment4,
                    Decision_Value__c: this.Decisionvalue
                }
                validateData({ decision: this.Decisionvalue, loanId: this.recordId })
                    .then((result) => {
                        if (result.length > 0) {
                            result.forEach((res) => {
                                this.showToastMessage("Error", res, "error", "sticky");

                            });
                        } else {
                            this.upsertDataMethod(obje);
                        }
                    })
                    .catch((error) => {
                    });
            }
            else if (this.Decisionvalue == 'Forward for Soft Approval') {

                const obje = {
                    sobjectType: "LoanAppl__c",
                    Id: this.recordId,
                    OwnerId: this.lookupId,
                    PrsnldetailsofPromotrs__c: this.RecoComment1,
                    BDApplicantCoapp__c: this.RecoComment2,
                    IncomerelateComm__c: this.RecoComment3,
                    AddationalComm__c: this.RecoComment4,
                    Decision_Value__c: this.Decisionvalue
                }
                validateData({ decision: this.Decisionvalue, loanId: this.recordId })
                    .then((result) => {
                        if (result.length > 0) {
                            result.forEach((res) => {
                                this.showToastMessage("Error", res, "error", "sticky");

                            });
                        } else {
                            this.upsertDataMethod(obje);
                        }
                    })
                    .catch((error) => {
                    });
            }
            else if (this.Decisionvalue == 'Forward for Approve') {

                const obje = {
                    sobjectType: "LoanAppl__c",
                    Id: this.recordId,
                    OwnerId: this.lookupId,
                    PrsnldetailsofPromotrs__c: this.RecoComment1,
                    BDApplicantCoapp__c: this.RecoComment2,
                    IncomerelateComm__c: this.RecoComment3,
                    AddationalComm__c: this.RecoComment4,
                    Decision_Value__c: this.Decisionvalue
                }
                validateData({ decision: this.Decisionvalue, loanId: this.recordId })
                    .then((result) => {
                        if (result.length > 0) {
                            result.forEach((res) => {
                                this.showToastMessage("Error", res, "error", "sticky");

                            });
                        } else {
                            this.upsertDataMethod(obje);
                        }
                    })
                    .catch((error) => {
                    });
            }
            //LAK-6473
            else if (this.Decisionvalue == 'Send Back to UW') {

                const obje = {
                    sobjectType: "LoanAppl__c",
                    Id: this.recordId,
                    OwnerId: this.lookupId,
                    PrsnldetailsofPromotrs__c: this.RecoComment1,
                    BDApplicantCoapp__c: this.RecoComment2,
                    IncomerelateComm__c: this.RecoComment3,
                    AddationalComm__c: this.RecoComment4,
                    Decision_Value__c: this.Decisionvalue
                }
                validateData({ decision: this.Decisionvalue, loanId: this.recordId })
                    .then((result) => {
                        if (result.length > 0) {
                            result.forEach((res) => {
                                this.showToastMessage("Error", res, "error", "sticky");

                            });
                        } else {
                            this.upsertDataMethod(obje);
                        }
                    })
                    .catch((error) => {
                    });
            }
            const obj = {
                sobjectType: "LoanAppl__c",
                Id: this.recordId,
                PrsnldetailsofPromotrs__c: this.RecoComment1,
                BDApplicantCoapp__c: this.RecoComment2,
                IncomerelateComm__c: this.RecoComment3,
                AddationalComm__c: this.RecoComment4,

            }
            this.upsertLan(obj);
        }
        let returnvariable = this.isvalid;
        return returnvariable;



    }


    updateDeviationData() {
        let manual = 'Manual';
        let syst = 'System';
        let callId = 5;
        let paramsLoanApp = {
            ParentObjectName: 'Deviation__c',
            parentObjFields: ['Id', 'Appr_Actn__c', 'Apprv_By__c', 'Approved_Date__c'],
            //queryCriteria: ' where LoanAppln__c  = \'' + this.recordId + '\' AND ( Dev_Type__c  = \'' + manual + '\' OR (Dev_Type__c  = \'' + syst + '\' AND  Status__c=\'Active\' AND CallId__c  != \'' + callId + '\'))'
            queryCriteria: ' where LoanAppln__c  = \'' + this.recordId + '\' AND ( Dev_Type__c  = \'' + manual + '\' OR (Dev_Type__c  = \'' + syst + '\' AND  Status__c=\'Active\' AND CallId__c  !=  '+ callId +' ))'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                if (result.parentRecords && result.parentRecords.length > 0) {
                    let d = new Date();
                    let newD = new Date(d.getTime());
                    let currentDateTime = newD.toISOString();
                    let arr = result.parentRecords;
                    arr.forEach(item => {
                        item.Appr_Actn__c = 'Approved';
                        item.Apprv_By__c = this.userId;
                        item.Approved_Date__c = currentDateTime;
                        item.AppStage__c = this.loanApplicationRecord.Stage__c;
                        item.ApprSubStage__c = this.loanApplicationRecord.SubStage__c;
                    })
                    this.upsertDeviDataMethod(arr);
                }
            })
            .catch((error) => {
                console.log('error occured ', error);
            });
    }
    
    upsertDeviDataMethod(newArray) {
        if (newArray) {
            upsertSObjectRecord({ params: newArray })
                .then((result) => {
                    if(this.finAppId == null || this.finAppId == undefined){
                        this.sequence_apiCall();
                    }
                    this.showToastMessage("Success", this.customLabel.UwDecision_Update_SuccessMessage, "success", "sticky");
                    this.dispatchEvent(new RefreshEvent());
                    this.navigateToListView();
                    console.log('result updated');
                })
                .catch((error) => {
                    console.log('error in updating', error);
                });
        }
    }

    //LAK-7332 UW Decision for BIL
    @track intMsgId = '';
    sequence_apiCall() {
        const fields = {};

        fields[INTEGRATION_MSG_NAME_FIELD.fieldApiName] = 'Sequence API';
        fields[STATUS_FIELD.fieldApiName] = 'New';
        fields[SERVICE_NAME_FIELD.fieldApiName] = 'Sequence API';
        fields[BU_FIELD.fieldApiName] = 'HL / STL';
        fields[IS_ACTIVE_FIELD.fieldApiName] = true;
        fields[REFERENCE_ID_FIELD.fieldApiName] = this.recordId;
        fields[REFERENCE_OBJ_API_FIELD.fieldApiName] = 'LoanAppl__c';
    
        const recordInput = {
            apiName: INTEGRATION_MSG_OBJECT.objectApiName,
            fields: fields
        };

        createRecord(recordInput).then((result) => {
            this.intMsgId = result.id
            this.startPolling();
        })
        .catch((error) => {
            console.log('Error ##990', error)
            this.showSpinner = false
            this.showToastMessage('Error creating Integration record', error.body.message, 'error', 'sticky')
        });

    }
    @track counter ;
    @track chequeInterval;
    startPolling() {
        this.counter = 0;
        this.chequeInterval = setInterval(() => {
            this.counter += 5;
            this.waitForChequeResponse();
        }, 5000);
    }
    waitForChequeResponse() {
        try {
            this.getLoanAppData();
            if (this.counter === 60 && !this.finAppId) {
                this.showToastMessage('Error', this.customLabel.Sequence_API_Success_Message, 'error', 'sticky');
                this.showSpinner = false
                clearInterval(this.chequeInterval);

            }
            //this.showSpinner = false
        } catch (e) {
            console.log(e);
        }

    }

    // Method to get First Approved date
    getApprovedDate() {
        if (this.Decisionvalue == 'Approve' || this.Decisionvalue == 'Soft Approve') {
            if (this.loanApplicationRecord.FirstApprovalDate__c == null || this.loanApplicationRecord.FirstApprovalDate__c == '' || this.loanApplicationRecord.FirstApprovalDate__c == undefined) {
                const obj = {
                    sobjectType: "LoanAppl__c",
                    Id: this.recordId,
                    FirstApprovalDate__c: this.currentDateTime
                }
                this.upsertApprovedDate(obj);
                this.fetchAPIVerficationRec();
            }

        }

    }
    upsertDataMethod(obje) {
        this.showSpinner = true;
        this.createUWDecesionRecord();
        let newArray = [];
        if (obje) {
            newArray.push(obje);
        }
        if (newArray) {
            upsertSObjectRecord({ params: newArray })
                .then((result) => {
                    this.refreshPage = result;
                    if (this.Decisionvalue && (this.Decisionvalue == 'Approve' || this.Decisionvalue == 'Soft Approve')) {
                        this.updateDeviationData();
                    } else {
                        this.showToastMessage("Success", this.customLabel.UwDecision_Update_SuccessMessage, "success", "sticky");
                        this.dispatchEvent(new RefreshEvent());
                        this.navigateToListView();
                    }
                })
                .catch((error) => {
                    this.isvalid = false;
                    this.showToastMessage("Error", "Error while Submitting the LAN", "error", "sticky");
                    this.showSpinner = false;
                });
        }
    }

    //Method to Create New UW Decision Record
    createUWDecesionRecord() {
        let fields = {};
        fields['sobjectType'] = 'UWDecision__c';
        fields['LoanAppl__c'] = this.recordId;
        if (this.Decisionvalue == 'Approve') {
            fields['Decision__c'] = 'Approved';
        } else if (this.Decisionvalue == 'Soft Approve') {
            fields['Decision__c'] = 'Soft Approved';
        } else if (this.Decisionvalue == 'Forward for Review') {
            fields['Decision__c'] = 'Forward for Review';
        } else if (this.Decisionvalue == 'Forward for Soft Approval') {
            fields['Decision__c'] = 'Forward for Soft Approval';
        } else if (this.Decisionvalue == 'Forward for Approve') {
            fields['Decision__c'] = 'Forward for Approve';
        }
        else if (this.Decisionvalue == 'Send Back to UW') {
            fields['Decision__c'] == 'Send Back to UW'; //LAK-6473
        }
        else if (this.Decisionvalue == 'Return to CPA') {
            fields['Decision__c'] = '';
        }
        else if (this.Decisionvalue == 'Reject') {
            fields['Decision__c'] = 'Rejected';
        }

        fields['DecisionDt__c'] = this.currentDateTime;
        fields['User__c'] = this.userId;
        fields['DecisionRmrks__c'] = this.decRemarks ? this.decRemarks : '';
        fields['PrsnldetailsofPromotrs__c'] = this.RecoComment1;
        fields['BDApplicantCoapp__c'] = this.RecoComment2;
        fields['IncomerelateComm__c'] = this.RecoComment3;
        fields['AddationalComm__c'] = this.RecoComment4;
        fields['Decision_Type__c'] = 'UW Decision';
        this.upsertUwDecision(fields);
    }

    upsertUwDecision(obj) {
        let newArr = [];
        if (obj) {
            newArr.push(obj);
        }
        if (newArr.length > 0) {
            upsertSObjectRecord({ params: newArr })
                .then((result) => {
                    this.getApprovedDate();
                    if (this.Decisionvalue == 'Approve' || this.Decisionvalue == 'Soft Approve') {
                        this.getCharge();
                    }
                    else if (this.Decisionvalue == 'Return to CPA') {
                        this.createFeed();
                    }
                })
                .catch((error) => {

                });
        }
    }
    //LAK-9154 -START
    fetchAPIVerficationRec() {
            
        let getApiVeriRecs = {
            ParentObjectName: 'APIVer__c',
            parentObjFields: ['Id'],
            queryCriteria: ' where LoanAplcn__c= \'' + this.recordId + '\' AND RecordType.DeveloperName = \'CrimeCheck\' AND IsLatest__c  = True'
        }
        getSobjectDat({ params: getApiVeriRecs })
            .then((result) => {
                console.log('Crime Records result',JSON.stringify(result));
                if (result.parentRecords) {
                    console.log('Crime Records Found');
                }
                else{
                    console.log('No Crime Records Found');
                    this.getApplicantIds();
                }
            })
            .catch((error) => {
                console.log('Error In Crime Records Found', error);
            });


        }
    appIds=[];
    appData;
    intRecords=[];
    getApplicantIds() {
        let paramsLoanApp = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id','Constitution__c', 'Name', 'IntegrationStatus__c', 'UCID__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this.recordId + '\''
        }
        console.log('test####');
        getSobjectDat({ params: paramsLoanApp })
            .then((result) => {
                this.appData = result;
                console.log('result is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    result.parentRecords.forEach(item => {
                        this.appIds.push(item);
                        
                    })
    
                    this.createIntForLitigation();
                    console.log('this.appRecordsData after', JSON.stringify(this.appIds));
                }
                if (result.error) {
                    console.error('appl result getting error=', result.error);
                }
            })
        }

        createIntForLitigation() {
            this.appIds.forEach(item => {
                let fieldsWo = {};
                fieldsWo['sobjectType'] = 'IntgMsg__c';
                fieldsWo['Name'] =  item.Constitution__c == 'INDIVIDUAL' || item.Constitution__c == 'PROPERITORSHIP' ? 'Crime Add Report API - Individual': 'Crime Add Report API - Company'; //serviceName;//'KYC OCR'
                fieldsWo['BU__c'] = 'HL / STL';
                fieldsWo['IsActive__c'] = true;
                fieldsWo['Svc__c'] = item.Constitution__c == 'INDIVIDUAL' || item.Constitution__c == 'PROPERITORSHIP' ? 'Crime Add Report API - Individual': 'Crime Add Report API - Company';
                fieldsWo['RefObj__c'] = 'Applicant__c';
                fieldsWo['RefId__c'] = item.Id;
                fieldsWo['Status__c'] = 'New';
                fieldsWo['ApiVendor__c'] = 'CrimeCheck';
                fieldsWo['TriggerType__c'] = 'System';
                this.intRecords.push(fieldsWo);
            })
            this.upsertIntRecord(this.intRecords);
        }

        upsertIntRecord(intRecords) {
            console.log('int msgs records ', JSON.stringify(intRecords));
            upsertSObjectRecord({ params: intRecords })
                .then((result) => {
                    console.log('###upsertMultipleRecord###'+result);
                    this.fireCustomEvent("Hunter:", "success", "Litigation Integration Initiated Successfully!");//LAK-3368
                  })
                .catch((error) => {
                    console.log('Error In creating Record', error);
                });
        }
        //LAK-9154 - END

    navigateToListView() {
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "LoanAppl__c",
                actionName: "list"
            },
            state: {

                filterName: "Recent"
            }
        });
    }
    positiveResp;
    getValidationReport(obje) {
        getValidationReport({ loanAppId: this.recordId })
            .then((result) => {
                result.forEach(res => {
                    if (res.validated === false) {
                        this.positiveResp = false;
                        let resp = res.applicantName + ' : ' + res.errorMessage;
                        this.showToastMessage("Error", resp, "error", "sticky");
                    }
                })
            })
            .catch((err) => {
                this.showSpinner = false;
                this.showToastMessage("Error", err.body.message, "error", "sticky");

            });

    }
    // Method to Validate the Lookup Fields
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
    upsertCharge(obj) {
        let newArr = [];
        if (obj) {
            newArr.push(obj);
        }
        if (newArr.length > 0) {
            upsertSObjectRecord({ params: newArr })
                .then((result) => {
                })
                .catch((error) => {
                });
        }
    }

    // Method to Create Post on Chatter
    createFeed() {
        let fields = {};
        fields['sobjectType'] = 'FeedItem';
        fields['ParentId'] = this.recordId;
        fields['Body'] = 'Loan Application Returned to CPA with Remarks: ' + this.decRemarks;
        this.upsertFeed(fields);

    }
    upsertFeed(obj) {
        let newArr = [];
        if (obj) {
            newArr.push(obj);
        }
        if (newArr.length > 0) {
            upsertSObjectRecord({ params: newArr })
                .then((result) => {
                })
                .catch((error) => {

                });
        }
    }

    // Method to get the charge code
    getCharge() {
        let paramsLoanApp = {
            ParentObjectName: 'LonaApplCharges__c',
            parentObjFields: ['Id', 'ChargeCodeID__c'],
            queryCriteria: ' where LoanApplication__c  = \'' + this.recordId + '\' AND ChargeCodeDesID__c  = \'' + this.chargeCode + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {

                if (result.parentRecords && result.parentRecords.length > 0) {
                }
            })
            .catch((error) => {
            });
    }
    @api validateForm() {
        let isValid = true
        this.template.querySelectorAll('lightning-textarea').forEach(element => {
            if (element.reportValidity()) {
            } else {
                isValid = false;
            }
        });
        return isValid;

    }
    upsertApprovedDate(obj) {
        let newArr = [];
        if (obj) {
            newArr.push(obj);
        }
        if (newArr.length > 0) {
            upsertSObjectRecord({ params: newArr })
                .then((result) => {
                })
                .catch((error) => {

                });
        }
    }

    upsertLan(obj) {
        let newArr = [];
        if (obj) {
            newArr.push(obj);
        }
        if (newArr.length > 0) {
            upsertSObjectRecord({ params: newArr })
                .then((result) => {
                })
                .catch((error) => {

                });
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