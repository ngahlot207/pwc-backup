import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';

// fields for  PD__c
import PD_OBJECT from '@salesforce/schema/PD__c';
import PDTYPE_FIELD from '@salesforce/schema/PD__c.PdTyp__c';

// fields for  LoanAppl__c
import sanLoanAmount from "@salesforce/schema/LoanAppl__c.SanLoanAmt__c";
import productType from "@salesforce/schema/LoanAppl__c.Product__c";
import requestedLoanAmount from "@salesforce/schema/LoanAppl__c.ReqLoanAmt__c";
import loanStatus from "@salesforce/schema/LoanAppl__c.Status__c";
import loanSubStage from "@salesforce/schema/LoanAppl__c.SubStage__c";
import loanStage from "@salesforce/schema/LoanAppl__c.Stage__c";
import OwnerId from "@salesforce/schema/LoanAppl__c.OwnerId";
import BrchCode from "@salesforce/schema/LoanAppl__c.BrchCode__c";
import clonedForID from "@salesforce/schema/LoanAppl__c.ClonedFor__c";
import city from "@salesforce/schema/LoanAppl__c.City__c";

// Custom labels
import InitiatePD_ScheduledDate_ErrorMessage from '@salesforce/label/c.InitiatePD_ScheduledDate_ErrorMessage';
import InitiatePD_Initiate_SuccessMessage from '@salesforce/label/c.InitiatePD_Initiate_SuccessMessage';
import InitiatePD_PassingData_ErrorMessage from '@salesforce/label/c.InitiatePD_PassingData_ErrorMessage';
import InitiatePD_Authority_ErrorMessage from '@salesforce/label/c.InitiatePD_Authority_ErrorMessage';
import InitiatePD_ReqFields_ErrorMessage from '@salesforce/label/c.InitiatePD_ReqFields_ErrorMessage';
import RemovePD_Removed_SuccessMessage from '@salesforce/label/c.RemovePD_Removed_SuccessMessage';
import BL_Pd_Type from '@salesforce/label/c.BL_PL_PD_Type';
import HL_Pd_Type from '@salesforce/label/c.HL_STLAP_PD_Type';

//Apex callouts
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getAssetPropType from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import fetchRecords from "@salesforce/apex/PDController.initiatePD";
import cloneInProgPdTechCVDataMethod from "@salesforce/apex/CloneInProgPdTechCVDataController.cloneInProgPdTechCVDataMethod";
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";

export default class InitiatePD extends LightningElement {
    customLabel = {
        InitiatePD_ScheduledDate_ErrorMessage,
        InitiatePD_Initiate_SuccessMessage,
        RemovePD_Removed_SuccessMessage,
        InitiatePD_PassingData_ErrorMessage,
        InitiatePD_Authority_ErrorMessage,
        InitiatePD_ReqFields_ErrorMessage,


    }
    @api loanAppId;
    @api applicantId;
    @api hasEditAccess;
    @api layoutSize;
    @track userId = Id;
    @track hasEditAccessForPd = false;
    @track isReadOnlyForPD = true;
    @track isShowModal = false;
    @track showSpinner = false;
    @track showPdTabs = true;
    @track hideInitatePd = true;
    @track pdDetail = [];
    @track isReadOnly = false;


    get TypeOfPDOptions() {
        let types = [];
        if (this.isBL) {
            BL_Pd_Type.split(',').forEach(element => {
                types.push({ label: element, value: element })
            });
            return types;
        } else {
            HL_Pd_Type.split(',').forEach(element => {
                types.push({ label: element, value: element })
            });
            return types;
        }
    }
    //= [];
    TypeOfPDValue;
    ScheduledDateValue;
    lookupId;
    @track pdDetailsList = [];
    @track pdTabset = [];
    @track refreshTabset = false;
    @track tabDefaultValue;
    @track showPdComp = false;
    @track rqstLoanAmt;

    @track isReadOnlyInitiatePd = true;
    @track isReadOnlyWithdrawPd = true;
    @track branchCode;
    @track isPdEditable = false;
    @track productType;
    @track city;
    @track pdAssignedTo; //LAK-7654
    @track clonedFor;
    @track filterCondition = " (EmpRole__c ='UW' OR  EmpRole__c='ACM' OR EmpRole__c='RCM' OR EmpRole__c='ZCM' OR EmpRole__c='NCM' OR EmpRole__c='CH')";
    agencyType = 'RCU';
    get filterConditionAgency() {
        return '(IsActive__c = true AND LocationMaster__r.City__c  = \'' + this.city + '\' AND AgencyType__c includes(\'' + this.agencyType + '\'))';//  " (EmpRole__c ='ZRCUM' )"; // assign agency roles from TH 
    }

    @wire(getRecord, { recordId: '$loanAppId', fields: [sanLoanAmount, requestedLoanAmount, loanStage, loanSubStage, OwnerId, BrchCode, loanStatus, productType, city, clonedForID] })
    currentRecordInfo({ error, data }) {
        if (data) {
            console.log('currentRecordInfo ', data);
            this.SanLoanAmt = data.fields.SanLoanAmt__c.value;
            this.rqstLoanAmt = data.fields.ReqLoanAmt__c.value;
            this.productType = data.fields.Product__c.value;
            this.clonedFor = data.fields.ClonedFor__c.value;
            this.city = data.fields.City__c.value;
            if (this.productType == 'Business Loan') {
                this.getApplicantAddress();
            }
            console.log('this.SanLoanAmt ===', this.SanLoanAmt);
            if ((data.fields.SubStage__c.value === 'Credit Appraisal'
                && data.fields.Stage__c.value === 'UnderWriting'
                && data.fields.OwnerId.value === this.userId)
                && (data.fields.Status__c.value != 'Cancelled'
                    && data.fields.Status__c.value != 'Hold'
                    && data.fields.Status__c.value != 'Rejected')) {
                this.isReadOnlyInitiatePd = false;
                this.isReadOnlyWithdrawPd = false;
                this.isPdEditable = true;

            }
            this.branchCode = data.fields.BrchCode__c.value;
            if (this.branchCode) {
                //   this.filterCondition = this.filterCondition + " AND (BranchCode__c = " + this.branchCode + ")";
            }
            this.getAllPd(false);
        } else if (error) {
            this.error = error;
        }
    }
    connectedCallback() {
        this.showMainComp = true;
        if (this.hasEditAccess === false) {
            // this.hasEditAccessForPd = false;
            this.isReadOnly = true;
            // this.isReadOnlyForPD = true;
        }


        setTimeout(() => {
            this.showSpinner = false;
            this.fetchAgecnyLocMapper();
        }, 2000);
        //this.getAllPd(false);
        console.log('applicantId on id initation ', this.applicantId);
    }

    @track showMainComp = false;
    disconnectedCallback() {
        //console.log('disconnectedCallback  called');
        // this.unsubscribeMC();
        this.showMainComp = false;
    }

    @wire(getObjectInfo, { objectApiName: PD_OBJECT })
    objectInfo;

    // @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PDTYPE_FIELD })
    // StatusPicklistValues({ error, data }) {
    //     if (data) {
    //         this.TypeOfPDOptions = data.values.map(item => ({
    //             label: item.label,
    //             value: item.value
    //         }));

    //     } else if (error) {
    //         console.error('Error fetching object info', error);
    //     }
    // }

    get showCloneButton() {
        if (this.clonedFor) {
            return true;
        }
        return false;
    }
    handleCloneMethod() {
        this.showSpinner = true;
        let inputData = {
            loanAppId: this.loanAppId,
            cloneFor: 'PD',
            appAssetId: ''
        }
        if (inputData) {
            cloneInProgPdTechCVDataMethod({ inputData: inputData }).then((result) => {
                // this.wiredDataCaseQry=result;
                console.log("result after cloning PD DETAILS >>>>>", result);
                if (result && result === 'Success') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: 'PD cloned Successfully',
                            variant: "success",
                            mode: 'sticky'
                        }),
                    );
                    // this.showToastMessage('Success','PD cloned Successfully','success','sticky')
                } else if (result && result === 'error') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: 'No PD to clone',
                            variant: "error",
                            mode: 'sticky'
                        }),
                    );
                    // this.showToastMessage('Error','No PD to clone','error','sticky')
                }
                this.showSpinner = false;
            })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log("Error in cloning PD DETAILS==>>>", error);
                });
        } else {
            this.showSpinner = false;
        }

    }


    showModalBox() {
        this.isShowModal = true;
        //this.showSpinner = true;

    }

    hideModalBox() {
        this.isShowModal = false;
        this.showSpinner = false;
        this.lookupId = null;
        this.schdDate = null;
        this.addressOfPD = null;
        this.TypeOfPDValue = '';
    }
    validateDate() {

        const yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);
        const selecteddate = new Date(this.ScheduledDateValue);
        console.log('yesterday => ' + yesterday + ' selected date =>' + this.ScheduledDateValue)
        console.log('condition => ' + selecteddate < yesterday)
        if (selecteddate <= yesterday) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Warning",
                    message: this.customLabel.InitiatePD_ScheduledDate_ErrorMessage,
                    variant: "error",
                    mode: 'sticky'
                }),
            );
            console.log('in if');
            return false;
        }
        else {
            console.log('in else');
            return true;
        }

    }
    handleTypeOfPDChange(event) {
        this.TypeOfPDValue = event.detail.value;
    }
    handleScheduledDateChange(event) {
        console.log("handleScheduledDateChange", event.detail.value);
        this.ScheduledDateValue = event.detail.value;
    }
    handleLookupFieldChange(event) {


        let detail = event.detail;

        let lookupIds = detail.id;
        console.log("lookupId>>>", lookupIds);
        this.lookupId = lookupIds;
        this.getSPDDuser();
    }
    handleAgencyChange(event) {
        this.lookupId = event.detail.value;
        console.log('Selected Agency:', this.selectedAgency);
        //this.getSPDDuser();
        this.retval = true;

    }
    @track retval = false;
    getSPDDuser() {
        let paramsLoanApp = {
            ParentObjectName: 'SPDD_Approval_Config__c',
            parentObjFields: ['Id', 'Emp__c', 'PD_Amt__c'],
            queryCriteria: ' where Emp__c = \'' + this.lookupId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('result is get emp ', JSON.stringify(result));
                this.emp = result.parentRecords[0].Emp__c;
                this.sacamt = result.parentRecords[0].PD_Amt__c;
                console.log('sacamt===>', this.sacamt);
                console.log('emp===>', this.emp);
                if (this.sacamt >= this.rqstLoanAmt) {
                    this.retval = true;
                } else {
                    this.retval = false;
                }
            })
            .catch((error) => {
                console.log("error occured in getting user", error);
            });
    }

    handleBeforeInitiatePd() {

    }
    handleCreatePD() {
        console.log('button clicked');
        console.log(this.TypeOfPDValue + ' ' + this.ScheduledDateValue + ' ' + this.lookupId);
        if ((this.TypeOfPDValue != undefined || this.TypeOfPDValue != null) && (this.ScheduledDateValue != undefined || this.ScheduledDateValue != null) && (this.lookupId != undefined || this.lookupId != null)) {
            console.log('(this.validateDate() => ', this.validateDate());
            if (this.validateDate()) {
                if (this.retval) {
                    console.log('method called');
                    //this.handleBeforeInitiatePd();
                    this.showSpinner = true;

                    // check  is there any pd with  respective type is there without completing it 

                    let financialBorrower = 'Financial'
                    let params = {
                        ParentObjectName: 'PD__c',
                        ChildObjectRelName: '',
                        parentObjFields: ['Id', 'PDStatus__c', 'PdTyp__c', 'Appl__c', "IsCompleted__c", "Appl__r.CustProfile__c", "Appl__r.Type_of_Borrower__c", "AsgnTo__r.Id", " AsgnTo__r.name"],
                        childObjFields: [],
                        //  queryCriteria: ' where Appl__c = \'' + 'a0AC4000000G11lMAC' + '\''// 
                        // queryCriteria: ' where Appl__c = \'' + this.applicantId + '\'' // 'a0AC4000000G11lMAC'
                        queryCriteria: ' where Appl__c = \'' + this.applicantId + '\'  AND Appl__r.Type_of_Borrower__c = \'' + financialBorrower + '\' AND PdTyp__c = \'' + this.TypeOfPDValue + '\' AND IsCompleted__c = false  AND PDStatus__c != \'Withdrawn\'  ORDER BY CreatedDate'
                    }//'\' AND PDStatus__c = \'' + pdStatusVal + '\' AND IsCompleted__c = false  AND PdTyp__c = \'' + this.TypeOfPDValue +
                    getAssetPropType({ params: params })
                        .then((res) => {

                            let result = res.parentRecords;
                            console.log('handleBeforeInitiatePd', res, result);
                            let initiatePd = true;
                            if (result && result.length > 0) {
                                result.forEach(element => {
                                    if ((element.PDStatus__c === 'Initiated' || element.PDStatus__c === 'In Progress') && element.IsCompleted__c == false) {
                                        initiatePd = false;
                                    }
                                });

                            }
                            if (initiatePd) {

                                var dataToPass = {
                                    loanAppId: this.loanAppId,
                                    applicantId: this.applicantId,
                                    pdMode: this.TypeOfPDValue,
                                    schdDate: this.ScheduledDateValue,
                                    assigndTo: this.lookupId,
                                    addressId: this.addressOfPD,
                                    vendorAccId: this.lookupId,
                                    isDoneByVendor: this.externalAgencyAssignment

                                };
                                console.log('where data to pass', dataToPass);
                                fetchRecords({ req: dataToPass })
                                    .then(result => {
                                        console.log('Data:' + JSON.stringify(result));
                                        //this.getAllPd(true);
                                        let tabOpt = { label: result.PdTyp__c, value: result.Id };
                                        // this.pdTabset.forEach(item => {
                                        //     item.showTab = false;
                                        // });
                                        this.pdTabset.push(tabOpt);
                                        //this.tabDefaultValue = result.Id;
                                        this.getAllPd(true);
                                        this.dispatchEvent(
                                            new ShowToastEvent({
                                                title: "Success",
                                                message: this.customLabel.InitiatePD_Initiate_SuccessMessage,
                                                variant: "success",
                                                mode: 'sticky'
                                            }),
                                        );
                                        this.isShowModal = false;
                                        this.showSpinner = false;
                                        this.TypeOfPDValue = null;
                                        this.ScheduledDateValue = null;
                                        this.lookupId = null;
                                        this.addressOfPD = null;

                                    }).catch(error => {
                                        console.log('error occored here');
                                        console.log(error);
                                        this.error = error;
                                        this.dispatchEvent(
                                            new ShowToastEvent({
                                                title: "Error",
                                                message: this.customLabel.InitiatePD_PassingData_ErrorMessage,
                                                variant: "error",
                                                mode: 'sticky'
                                            }),
                                        );
                                        this.showSpinner = false;
                                    });
                            } else {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: "Error",
                                        message: "Kindly Complete/Withdraw the In Progress PD before creating new PD of same type",// this.customLabel.InitiatePD_Initiate_SuccessMessage,
                                        variant: "error",
                                        mode: 'sticky'
                                    }),
                                );
                                this.isShowModal = false;
                                this.showSpinner = false;
                                this.TypeOfPDValue = null;
                                this.ScheduledDateValue = null;
                                this.lookupId = null;
                                this.addressOfPD = null;
                            }

                        })
                        .catch(error => {
                            console.log('error occored here in  getting PD__c ', error);
                            console.log(error);
                            this.showSpinner = false;
                            // this.error = error;
                            // this.dispatchEvent(
                            //     new ShowToastEvent({
                            //         title: "Error",
                            //         message: this.customLabel.InitiatePD_PassingData_ErrorMessage,
                            //         variant: "error",
                            //     }),
                            // );
                            // this.showSpinner = false;
                        });

                    //eld




                }
                else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error ",
                            message: this.customLabel.InitiatePD_Authority_ErrorMessage,
                            variant: "error",
                            mode: 'sticky'
                        }),
                    );
                }
            }
        }
        else {
            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Warning",
                    message: this.customLabel.InitiatePD_ReqFields_ErrorMessage,
                    variant: "error",
                    mode: 'sticky'
                }),
            );
        }


    }

    getAllPd(newCreated) {
        let pdStatusVal = 'Withdrawn';
        let params = {
            ParentObjectName: 'PD__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'PDStatus__c', "IsCompleted__c", 'PdTyp__c', 'Appl__c', "Appl__r.CustProfile__c", "AsgnTo__r.Id", " AsgnTo__r.name"],
            childObjFields: [],
            //  queryCriteria: ' where Appl__c = \'' + 'a0AC4000000G11lMAC' + '\''// 
            // queryCriteria: ' where Appl__c = \'' + this.applicantId + '\'' // 'a0AC4000000G11lMAC'
            queryCriteria: ' where Appl__c = \'' + this.applicantId + '\' AND PDStatus__c != \'' + pdStatusVal + '\' ORDER BY CreatedDate'
        }

        getAssetPropType({ params: params })
            .then((res) => {
                let result = res.parentRecords;
                console.log('result after length ', result, result.length);
                //console.log('result from getAllPd is ', this.userId, res, result, result.length);
                this.pdDetailsList = result;
                this.pdTabset = [];
                this.pdDetail = []
                //this.tabDefaultValue = null;
                if (result && result.length > 0) {
                    this.refreshTabset = false;
                    this.pdDetail = result;
                    let allTabs = [];
                    let deffTabNo = 0;

                    if (newCreated) {
                        deffTabNo = result.length - 1;
                        this.tabDefaultValue = result[deffTabNo].Id;
                    }
                    this.pdTabset = [];
                    if (!this.tabDefaultValue) {
                        this.tabDefaultValue = result[deffTabNo].Id
                    }
                    result.forEach((item) => {
                        let tabOpt = { label: item.PdTyp__c, value: item.Id };
                        console.log('deffTabNo', item.value == this.tabDefaultValue, tabOpt.value, this.tabDefaultValue);

                        if (tabOpt.value == this.tabDefaultValue) {
                            tabOpt.showTab = true;
                            console.log(' deffTabNo = ', result.findIndex(obj => obj.Id === item.Id));
                            deffTabNo = result.findIndex(obj => obj.Id === item.Id);

                        } else {
                            tabOpt.showTab = false;
                        }
                        allTabs.push(tabOpt);
                    })
                    this.pdTabset = allTabs;
                    console.log('result after length ', result, result.length, deffTabNo);

                    this.refreshTabset = true;
                    let eve = { target: { label: result[deffTabNo].PdTyp__c, value: this.tabDefaultValue } };
                    this.handleActive(eve);

                    if (result[0].Appl__r.CustProfile__c === "SALARIED" ||
                        result[0].Appl__r.CustProfile__c === "SELF EMPLOYED PROFESSIONAL" ||
                        result[0].Appl__r.CustProfile__c === "SELF EMPLOYED NON PROFESSIONAL") {
                        this.hideInitatePd = false;
                        this.showMainComp = true;
                    } else {
                        this.showInitatePd = true;
                        this.showMainComp = false;

                    }
                    console.log('check editable', this.tabDefaultValue, result[deffTabNo].Id, result[deffTabNo].AsgnTo__c, this.userId, result[deffTabNo].IsCompleted__c, this.isPdEditable);
                    if (this.tabDefaultValue && this.tabDefaultValue === result[deffTabNo].Id && result[deffTabNo].AsgnTo__c === this.userId && result[deffTabNo].IsCompleted__c === false && this.isPdEditable) {
                        this.isReadOnlyForPD = false;
                        this.hasEditAccessForPd = true;

                        // if (this.hasEditAccess === false) {
                        //     this.hasEditAccessForPd = false;
                        //     this.isReadOnlyForPD = true;
                        // } else {
                        //     this.isReadOnlyForPD = false;
                        //     this.hasEditAccessForPd = true;
                        // }

                    } else {
                        this.isReadOnlyForPD = true;
                        this.hasEditAccessForPd = false;
                        // if (this.hasEditAccess === false) {
                        //     this.hasEditAccessForPd = false;
                        //     this.isReadOnlyForPD = true;
                        // } else {
                        //     this.isReadOnlyForPD = true;
                        //     this.hasEditAccessForPd = false;
                        // }

                    }


                    // result.
                    // result.forEach(element => {
                    //     if (element.Id === this.tabDefaultValue && result.AsgnTo__c === this.userId ) {
                    //         this.isReadOnly = 
                    //     }
                    // });
                } else {
                    this.isReadOnlyWithdrawPd = true;
                    this.hasEditAccessForPd = false;
                }


            })
            .catch((err) => {
                //this.showToast("Error", "error", "Error occured in geting getAllPd " + err.message);
                console.log(" getSobjectDatawithRelatedRecords getAllPd error===", err);
            });

    }
    handleActive(event) {
        this.showPdComp = false;
        console.log('handleActive', event.target.label, event.target.value, this.pdDetailsList);
        this.tabDefaultValue = event.target.value;
        this.pdTabset.forEach(element => {
            if (element.value == this.tabDefaultValue) {
                element.showTab = true;
            } else {
                element.showTab = false;
            }
        });

        let pdDetail = this.pdDetailsList.find((doc) => doc.Id == this.tabDefaultValue);
        if (pdDetail && pdDetail.AsgnTo__c === this.userId) {
            this.pdAssignedTo = pdDetail.AsgnTo__c;
            this.isReadOnlyForPD = false;

            if (pdDetail.IsCompleted__c) {
                this.hasEditAccessForPd = false;
            } else {
                this.hasEditAccessForPd = true;
            }


            // if (this.hasEditAccess === false) {
            //     this.hasEditAccessForPd = false;
            //     this.isReadOnlyForPD = true;
            // } else {
            //     this.isReadOnlyForPD = false;
            //     this.hasEditAccessForPd = true;
            // }

        } else {
            this.isReadOnlyForPD = true;
            this.hasEditAccessForPd = false;

            // if (this.hasEditAccess === false) {
            //     this.hasEditAccessForPd = false;
            //     this.isReadOnlyForPD = true;
            // } else {
            //     this.isReadOnlyForPD = true;
            //     this.hasEditAccessForPd = false;
            // }

        }
        if (pdDetail && pdDetail.IsCompleted__c) {
            this.isReadOnlyWithdrawPd = true;
        } else {
            this.isReadOnlyWithdrawPd = false;
        }
        this.showPdComp = true;
    }
    removePd() {
        this.isModalOpen = true;

    }
    @track isModalOpen = false;
    @track removeModalMessage = 'Do you want to Withdraw the PD ?';
    closeModal() {
        console.log('isModalOpen ', this.isModalOpen);
        this.isModalOpen = false;
    }
    handleRemoveRecord() {
        console.log('removePd clicked', this.tabDefaultValue);
        const loanAppFields = {};
        this.showSpinner = true;

        loanAppFields['Id'] = this.tabDefaultValue;
        loanAppFields['PDStatus__c'] = 'Withdrawn';

        let upsertDataFile = {
            parentRecord: loanAppFields,
            ChildRecords: null,
            ParentFieldNameToUpdate: ''
        }
        console.log('upsertData ==>', JSON.stringify(upsertDataFile));

        let params = {
            ParentObjectName: 'PD__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'PDStatus__c', 'PdTyp__c', 'Appl__c', "IsCompleted__c", "Appl__r.CustProfile__c", "Appl__r.Type_of_Borrower__c", "AsgnTo__r.Id", " AsgnTo__r.name"],
            childObjFields: [],
            //  queryCriteria: ' where Appl__c = \'' + 'a0AC4000000G11lMAC' + '\''// 
            // queryCriteria: ' where Appl__c = \'' + this.applicantId + '\'' // 'a0AC4000000G11lMAC'
            queryCriteria: ' where Id = \'' + this.tabDefaultValue + '\' ORDER BY CreatedDate'
        }//'\' AND PDStatus__c = \'' + pdStatusVal + '\' AND IsCompleted__c = false  AND PdTyp__c = \'' + this.TypeOfPDValue +
        getAssetPropType({ params: params })
            .then((res) => {
                let result = res.parentRecords[0];
                if (result.IsCompleted__c) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: 'Can not Withdraw PD, This PD is Completed',
                            variant: "error",
                            mode: 'sticky'
                        }),
                    );
                    this.isModalOpen = false;
                    this.showSpinner = false;
                } else {
                    upsertSobjDataWIthRelatedChilds({ upsertData: upsertDataFile })
                        .then(result => {
                            console.log(" PD removed  ", result);
                            this.getAllPd(true);
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: "Success",
                                    message: this.customLabel.RemovePD_Removed_SuccessMessage,
                                    variant: "success",
                                    mode: 'sticky'
                                }),
                            );
                            this.isModalOpen = false;
                            this.showSpinner = false;
                            //this.showToast("Success", "success", "PD removed Successfully");

                        }).catch(error => {
                            this.isModalOpen = false;
                            //  this.showToast("Error", "error", "Error occured in Updating LoanApplication  " + error.message);
                            console.log(" Error occured in Updating LoanApplication === ", error);
                            this.showSpinner = false;
                        })
                }
            })
            .catch(error => {
                this.isModalOpen = false;
                this.showSpinner = false;
                //  this.showToast("Error", "error", "Error occured in Updating LoanApplication  " + error.message);
                console.log(" Error occured in getting Pd__c=== ", error);
                // this.showSpinner = false;
            })

    }

    reloadPd(event) {
        let val = JSON.parse(JSON.stringify(event.detail));
        console.log('reloadPd from PdComponent', val);
        this.getAllPd(false);

    }
    get isBL() {
        if (this.productType == 'Business Loan') {

            return true;
        } else {
            return false;
        }


    }
    @track externalAgencyAssignment = false;
    @track assignmentType = 'Internal';
    agenctAssignmentType = [{ label: 'Internal', value: 'Internal' }, { label: 'External', value: 'External' }]
    handleAgenctAssignmentChange(event) {
        this.assignmentType = event.detail.value;
        console.log('assignmentType', this.assignmentType);
        if (this.assignmentType == 'External') {
            this.externalAgencyAssignment = true;
        } else if (this.assignmentType == 'Internal') {
            this.externalAgencyAssignment = false;
        }
    }
    @track applicantAddressPickList = [];
    getApplicantAddress() {

        //select ID, FullAdrs__c, LoanAppl__c, Applicant__c  from ApplAddr__c where LoanAppl__c ='a08C400000BmJDMIA3' AND  Applicant__r.ApplType__c ='P'
        let params = {
            ParentObjectName: 'ApplAddr__c',
            ChildObjectRelName: '',
            parentObjFields: ['ID', 'FullAdrs__c', 'LoanAppl__c', 'Applicant__c', 'AddrTyp__c'],
            childObjFields: [],
            queryCriteria: ' where LoanAppl__c = \'' + this.loanAppId + '\' AND Applicant__r.ApplType__c = \'' + 'P' + '\' ORDER BY CreatedDate'
        }


        getAssetPropType({ params: params })
            .then((res) => {
                let result = res.parentRecords;
                console.log('  Applicant Address 11', params, res);
                if (result) {
                    this.applicantAddressPickList = [];
                    console.log('  Applicant Address', result);
                    result.forEach(ele => {
                        let val = { label: ele.AddrTyp__c, value: ele.Id }
                        this.applicantAddressPickList.push(val);
                    });

                }
                console.log('  Applicant Address', this.applicantAddressPickList);
            })
            .catch(error => {

                //  this.showToast("Error", "error", "Error occured in Updating LoanApplication  " + error.message);
                console.log(" Error occured in getting FullAdrs__c=== ", error);
                // this.showSpinner = false;
            })
    }
    @track addressOfPD;
    handleAddressOfPDChange(event) {

        this.addressOfPD = event.detail.value;
        console.log('  this.addressOfPD ', this.addressOfPD);

    }
    @track
    agencyMapParams = {
        ParentObjectName: "AgncLocMap__c",
        ChildObjectRelName: "",
        parentObjFields: [
            "Id",
            "Name",
            "LocationMaster__r.City__c",
            "Account__c",
            "Account__r.Name",
            "Contact__c"
        ],
        childObjFields: [],
        queryCriteria: ""
    };
    externalAgencyList = [];
    fetchAgecnyLocMapper() {
        if (this.isBL) {
            let agencyType = 'RCU';//'TSR';
            let tempParams = this.agencyMapParams;
            tempParams.queryCriteria =
                ' where IsActive__c = true AND LocationMaster__r.City__c  = \'' + this.city + '\' AND AgencyType__c includes(\'' + agencyType + '\')';
            this.agencyMapParams = { ...tempParams };

            getSobjectDataNonCacheable({ params: this.agencyMapParams }).then((result) => {
                // this.wiredDataCaseQry=result;
                console.log(" fetchAgecnyLocMapper Agency List>>>>>", result);
                let contactList = [];
                if (result.parentRecords !== undefined) {
                    result.parentRecords.forEach((item) => {
                        if (item.Contact__c) {
                            contactList.push(item.Contact__c);
                        }
                        if (item.Account__c && item.Account__r.Name && item.Account__r.Id) {
                            this.externalAgencyList = [];
                            let opt = { label: item.Account__r.Name, value: item.Account__r.Id };
                            this.externalAgencyList = [...this.externalAgencyList, opt];
                            //  this.externalAgencyList.sort(label); //picklist sorting

                            // let opt1 = { label: item.Account__c, value: item.Contact__c };

                            // const labelExists1 = this.accContactMap.some(option => option.label === opt1.label);
                            // if (!labelExists1) {
                            //     this.accContactMap = [...this.accContactMap, opt1];
                            // }

                            // this.accContactMap.sort(this.compareByLabel); //picklist sorting

                        }
                    });

                    if (contactList.length > 0) {
                        let parameter = {
                            ParentObjectName: 'User',
                            ChildObjectRelName: null,
                            parentObjFields: ['Id', 'Name', 'ContactId', 'AccountId'],
                            childObjFields: [],
                            queryCriteria: ' where ContactId IN (\'' + contactList.join('\', \'') + '\')'
                            //WHERE ID IN (\''+this._idsForSvinJointCa.join('\', \'') + '\')'
                        }
                        console.log(" fetchAgecnyLocMapper agency Contact Params >>>>>", parameter);
                        //select Id,  Name,  ContactId, AccountId from User  where ContactId in ('003C4000008oaV7IAI','003C4000008oaV8IAI')
                        //Get NonCacheable data. If Case status is cloasd. User will not able to delete the document. without page refresh this will work
                        getSobjectDataNonCacheable({ params: parameter })
                            .then((reg) => {
                                console.log(" fetchAgecnyLocMapper Agency user List>>>>>", reg);
                            })
                            .catch(err => {
                                console.log('Error while fetchAgecnyLocMapper user:', JSON.stringify(err));
                            });
                    }

                    this.showSpinner = false;
                } else {
                    this.showSpinner = false;
                    //  this.showToastMessage('Error', '', 'error', 'sticky')
                }
            })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log("Error infetchAgecnyLocMapper ", error);
                });
        }

    }

}