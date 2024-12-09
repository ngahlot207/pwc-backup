import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import initiateCollateralVisit from '@salesforce/apex/CollateralVisitController.initiateCollateralVisit'
import retrieveCV from '@salesforce/apex/CollateralVisitController.retrieveCV'
import getAssetPropType from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import { RefreshEvent } from 'lightning/refresh';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import { publish, subscribe, MessageContext } from "lightning/messageService";
import LOSSAVEBUTTONDISABLE from "@salesforce/messageChannel/LosSaveButtonDisable__c";
// Custom labels
import CollateralVisit_ScheduledDate_ErrorMessage from '@salesforce/label/c.CollateralVisit_ScheduledDate_ErrorMessage';
import CollateralVisit_Initiate_SuccessMessage from '@salesforce/label/c.CollateralVisit_Initiate_SuccessMessage';
import CollateralVisit_PassingData_ErrorMessage from '@salesforce/label/c.CollateralVisit_PassingData_ErrorMessage';
import getSobjectDat from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import cloneInProgPdTechCVDataMethod from "@salesforce/apex/CloneInProgPdTechCVDataController.cloneInProgPdTechCVDataMethod";


export default class CaptureCollateralVisit extends LightningElement {
    label = {
        CollateralVisit_ScheduledDate_ErrorMessage,
        CollateralVisit_Initiate_SuccessMessage,
        CollateralVisit_PassingData_ErrorMessage

    }
    @track userId = Id;
    @api hasEditAccess;
    @api layoutSize;
    @track _currentTabId;
    @track tabDefaultValue;
    @track cvRecordTypeId;
    @track showCaseTabs = true;
    @track isShowModal = false;
    @track showSpinner = false;
    @track isReadOnly = false;
    @track isDisableforCV = false;
    TypeOfPDOptions = [];
    TypeOfPDValue;
    ScheduledDateValue;
    lookupId;
    @track retvalue = true;
    @track isModalOpen = false;
    @track filterCondn = "  (EmpRole__c ='UW' OR  EmpRole__c='ACM' OR EmpRole__c='RCM' OR EmpRole__c='CM' OR EmpRole__c='NCM' OR EmpRole__c='CH') ";
    @track removeModalMessage = 'Do you want to Withdraw the CV ?';
    @track isDisableWithdraw = false;
    // filterCon = 'EmpRole__c IN(\'' + this.emprole + '\',\'' + this.chrole + '\',\'' + this.acmrole + '\',\'' + this.rcmrole + '\',\'' + this.zcmrole + '\',\'' + this.ncmrole + '\') ' + 'AND Employee__c != \'' + this.userId + '\''
    // emprole = 'UW';
    // acmrole = 'ACM';
    // rcmrole = 'RCM';
    // zcmrole = 'ZCM';
    // ncmrole = 'NCM';
    // chrole = 'CH';
    @api get currentTabId() {
        return this._currentTabId;

    }
    @wire(MessageContext)
    MessageContext;
    set currentTabId(value) {
        this._currentTabId = value;
        this.setAttribute("currentTabId", value);
    }

    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
    }
    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;

    }

    set applicantId(value) {
        this._applicantId = value;
        this.setAttribute("applicantId", value);
    }
    @track _applicantId;
    @api get applicantId() {
        return this._applicantId;
    }

    connectedCallback() {
        this.getUserRole();

        if (this.hasEditAccess === false) {
            this.isReadOnly = true;
            this.isDisableforCV = true
            this.isDisableWithdraw = true;

        }
        console.log('current tabset id', this._currentTabId);
        console.log('this._applicantId====>', this._applicantId);
        console.log('this._loanAppId====>', this._loanAppId);

        setTimeout(() => {
            this.showSpinner = false;
        }, 2000);
        this.getAllCases();
        if (this._loanAppId) {
            this.getLoanData();
        }
    }

    @track clonedFor;
    getLoanData() {
        let params = {
            ParentObjectName: 'LoanAppl__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'ClonedFor__c', 'BrchCode__c', 'Product__c'],
            childObjFields: [],
            queryCriteria: ' where Id = \'' + this._loanAppId + '\''
        }
        getAssetPropType({ params: params })
            .then((res) => {
                let result = res.parentRecords;
                console.log('loan Details is', result);

                if (result && result.length > 0) {
                    this.clonedFor = result[0].ClonedFor__c;
                }
                let branchCode = result[0].BrchCode__c;
                let productType = result[0].Product__c;
                if (branchCode) {// LAK-9798
                    this.filterCondn = this.filterCondn + " AND (EmpBrch__r.BrchCode__c = '" + branchCode + "')";
                }
                if (productType) {// LAK-9798
                    this.filterCondn = this.filterCondn + " AND ( Product_Type__c includes ('" + productType + "'))";
                }
                console.log('filterCondn', this.filterCondn);
            })
            .catch((err) => {
                //this.showToast("Error", "error", "Error occured in geting getAllCases " + err.message);
                console.log(" loan data getting error===", err);
            });
    }
    showModalBox() {
        this.getcvCloseCases();
        //this.isShowModal = true;
    }

    removeCV() {

        this.isModalOpen = true;
    }

    closeModal() {
        console.log('isModalOpen ', this.isModalOpen);
        this.isModalOpen = false;
    }

    hideModalBox() {
        this.isShowModal = false;
        this.showSpinner = false;
    }
    validateDate() {

        const yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);
        const selecteddate = new Date(this.ScheduledDateValue);
        console.log('yesterday => ' + yesterday + ' selected date =>' + this.ScheduledDateValue)
        console.log('condition => ' + selecteddate < yesterday)
        if (selecteddate <= yesterday) {
            this.showToastMessage('Error', this.label.CollateralVisit_ScheduledDate_ErrorMessage, 'error', 'dismissable');

            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         title: "Warning",
            //         message: "Scheduled Date should be greater than today",
            //         variant: "error",
            //     }),
            // );
            console.log('in if');
            return false;
        }
        else {
            console.log('in else');
            return true;
        }

    }

    get showCloneButton() {
        if (this.clonedFor) {
            return true;
        }
        return false;
    }
    handleCloneMethod() {
        this.showSpinner = true;
        let inputData = {
            loanAppId: this._loanAppId,
            cloneFor: 'CV',
            appAssetId: ''
        }
        if (inputData) {
            cloneInProgPdTechCVDataMethod({ inputData: inputData }).then((result) => {
                // this.wiredDataCaseQry=result;
                console.log("result after cloning CV DETAILS >>>>>", result);
                if (result && result === 'Success') {
                    this.showToastMessage('Success', 'CV cloned Successfully', 'success', 'sticky');
                } else if (result && result === 'error') {
                    this.showToastMessage('Error', 'No CV to clone', 'error', 'sticky');
                }
                this.showSpinner = false;
            })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log("Error in cloning CV DETAILS==>>>", error);
                });
        } else {
            this.showSpinner = false;
        }

    }

    handleScheduledDateChange(event) {
        this.ScheduledDateValue = event.detail.value;
    }
    // renderedCallback() {

    //     this.getUserLevel();
    // }
    // getUserLevel() {
    //     let paramsLoanApp = {
    //         ParentObjectName: 'TeamHierarchy__c',
    //         parentObjFields: ['Id', 'Emplevel__c'],
    //         queryCriteria: ' where EmpRole__c = \'' + this.lookupId + '\''
    //     }
    //     getSobjectData({ params: paramsLoanApp })
    //         .then((result) => {
    //             console.log('result is get level ', JSON.stringify(result));
    //             if (result.parentRecords) {
    //                 this.employeeLevel = result.parentRecords[0].EmpLevel__c;
    //                 console.log('this.employeeLevel is ', this.employeeLevel);
    //             }
    //         })
    //         .catch((error) => {

    //             this.showSpinner = false;
    //             console.log("error occured in getlevel", error);

    //         });
    // }

    handleLookupFieldChange(event) {

        this.lookupId = event.detail;

        let lookupIds = this.lookupId.id;
        console.log("lookupId>>>", lookupIds);
        this.lookupId = lookupIds;

    }
    @track dataToPass;
    handleCreateCV() {
        console.log('button clicked');
        console.log(this.ScheduledDateValue + ' ' + this.lookupId);
        if (this.retvalue === true) {
            if ((this.ScheduledDateValue != undefined || this.ScheduledDateValue != null) && (this.lookupId != undefined || this.lookupId != null)) {
                console.log('(this.validateDate() => ', this.validateDate());
                if (this.validateDate()) {

                    this.showSpinner = true;

                    // let paramsCase = {
                    //     ParentObjectName: 'Case',
                    //     parentObjFields: ['Id'],
                    //     queryCriteria: ' where Loan_Application__c	 = \'' + this._loanAppId + '\' AND IsCompleted__c = false order BY createdDate'
                    // }
                    // getSobjectDat({ params: paramsCase })
                    //     .then((result) => {
                    //         let count = 0;
                    //         console.log('CV Case data is', JSON.stringify(result));
                    //         let initiatecv = true;
                    //         if (result && result.length > 0) {
                    //             initiatecv = false;
                    //                         }

                    //     })
                    //     .catch((error) => {
                    //         console.log('Error In getting CV Case Data ', error);
                    //     });

                    // if(initiatecv){
                    this.dataToPass = {
                        loanAppId: this._loanAppId,
                        applicantId: this._currentTabId,
                        schdDate: this.ScheduledDateValue,
                        assigndTo: this.lookupId

                    };
                    console.log('where data to pass', this.dataToPass);
                    initiateCollateralVisit({ req: this.dataToPass })
                        .then(result => {
                            console.log('Data:', JSON.stringify(result));
                            this.showToastMessage('Success', this.label.CollateralVisit_Initiate_SuccessMessage, 'success', 'Sticky');
                            this.getAllCases();

                            this.dispatchEvent(new RefreshEvent());
                            this.isShowModal = false;
                            this.showSpinner = false;
                            this.ScheduledDateValue = null;
                            this.lookupId = null;



                        }).catch(error => {
                            console.log('error occored here');
                            console.log(error);
                            this.error = error;
                            this.showToastMessage('Error', this.label.CollateralVisit_PassingData_ErrorMessage, 'error', 'Sticky');
                            this.showSpinner = false;
                        });
                }

            }
        }
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: "You Don't have Authority to initiate CV",
                    variant: "error",
                    mode: 'sticky'
                }),
            );
            this.isShowModal = false;
            this.showSpinner = false;
        }
    }


    //case Starts

    @track caseTabset = [];
    @track refreshTabset = false;
    @track showCaseComponent = false;
    @track CVQuesResponse;

    handleRemoveRecord() {
        console.log('removeCV clicked', this.tabDefaultValue);
        const loanAppFields = {};
        this.showSpinner = true;

        loanAppFields['Id'] = this.tabDefaultValue;
        loanAppFields['CVStatus__c'] = 'Withdrawn';

        let upsertDataFile = {
            parentRecord: loanAppFields,
            ChildRecords: null,
            ParentFieldNameToUpdate: ''
        }
        console.log('upsertData ==>', JSON.stringify(upsertDataFile));

        let params = {
            ParentObjectName: 'Case',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'IsCompleted__c'],
            childObjFields: [],
            queryCriteria: ' where Id = \'' + this.tabDefaultValue + '\' ORDER BY CreatedDate'
        }
        getAssetPropType({ params: params })
            .then((res) => {
                let result = res.parentRecords[0];
                if (result.IsCompleted__c) {
                    //     this.dispatchEvent(
                    //         new ShowToastEvent({
                    //             title: "Error",
                    //             message: 'Can not Withdraw CV, This CV is Completed',
                    //             variant: "error",
                    //             mode: 'sticky'
                    //         }),
                    //     );
                    this.isModalOpen = false;
                    this.showSpinner = false;
                } else {
                    upsertSobjDataWIthRelatedChilds({ upsertData: upsertDataFile })
                        .then(result => {
                            console.log(" PD removed  ", result);
                            this.getAllCases();
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: "Success",
                                    message: 'CV Removed SuccessFully',
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
                            console.log(" Error occured === ", error);
                            this.showSpinner = false;
                        })
                }
            })
            .catch(error => {
                this.isModalOpen = false;
                this.showSpinner = false;
                console.log(" Error occured in getting Case=== ", error);
            })

    }

    getAllCases() {
        let params = {
            ParentObjectName: 'Case',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'CaseNumber', 'IsCompleted__c', 'ApplAssetId__c', 'Assigned_To__c', 'RecordType.Name'],
            childObjFields: [],
            queryCriteria: ' where ApplAssetId__c = \'' + this._currentTabId + '\' AND CVStatus__c != \'Withdrawn\' AND RecordType.Name = \'Collateral Visit\' order by createdDate asc '


        }
        getAssetPropType({ params: params })
            .then((res) => {
                this.caseTabset = [];
                let result = res.parentRecords;
                // let resultNew = res.parentRecords;
                // console.log('result from getAllCases is ', res, resultNew, resultNew.length);
                // if (resultNew.length > 0) {
                //     result = resultNew.filter(item => item.RecordType.Name == 'Collateral Visit')
                // }
                console.log('result from getAllCases is result is', result);

                if (result && result.length > 0) {

                    this.cvDetail = result;
                    this.showCaseTabs = false;
                    console.log('result after length ', result.length);
                    result.forEach(item => {
                        let tabOpt = { label: item.CaseNumber, value: item.Id, showTab: false, isCompleted: item.IsCompleted__c, assigndTo: item.Assigned_To__c };
                        this.caseTabset.push(tabOpt);
                    })
                    this.tabDefaultValue = this.caseTabset[0].value;
                    console.log('this.caseTabset[0].assignedUser', this.caseTabset[0].assignedUser);
                    console.log('this.userId', this.userId);
                    // if(this.caseTabset[0].assignedUser === this.userId){  
                    //     this.hasEditAccess = false;
                    // }
                    // else{
                    //     this.hasEditAccess = true;   
                    // }
                    if (this.hasEditAccess) {
                        this.isDisableWithdraw = this.caseTabset[0].isCompleted;
                    } else {
                        this.isDisableWithdraw = true;
                    }

                    this.caseTabset[0].showTab = true;

                    this.refreshTabset = true;
                    this.showCaseTabs = true;
                    //  this.isDisableWithdraw = this.hasEditAccess == false ? true : false;
                } else {

                    //  this.isDisableWithdraw = this.hasEditAccess == false ? true : true;
                }


            })
            .catch((err) => {
                //this.showToast("Error", "error", "Error occured in geting getAllCases " + err.message);
                console.log(" getSobjectDatawithRelatedRecords getAllCases error===", err);
            });

    }
    handleActive(event) {
        console.log('handleActive', event.target.label, event.target.value, JSON.stringify(this.caseTabset));
        this.tabDefaultValue = event.target.value;
        this.showCaseComponent = false;
        this.caseTabset.forEach(element => {
            if (element.value == this.tabDefaultValue) {
                element.showTab = true;

                if (element.assigndTo == this.userId && !element.isCompleted) {
                    //triggerLMS
                    const payload = {
                        disableSaveButton: false,
                        assignedTo: element.assigndTo
                        //LAK-8799
                    };
                    console.log(" Published Event>", JSON.stringify(payload));
                    publish(this.MessageContext, LOSSAVEBUTTONDISABLE, payload);
                } else {
                    const payload = {
                        disableSaveButton: true
                    };
                    console.log(" Published Event>", JSON.stringify(payload));
                    publish(this.MessageContext, LOSSAVEBUTTONDISABLE, payload);
                }
                if (this.hasEditAccess) {
                    this.isDisableWithdraw = element.isCompleted;
                    console.log('element.assigndTo', element.assigndTo)

                } else {
                    this.isDisableWithdraw = true;


                }

            } else {
                element.showTab = false;
            }
        });
        // retrieveCV({ cvId: this.tabDefaultValue })
        //     .then((res) => {
        //         let resp;
        //         if (res.length > 0) {
        //             resp = res.filter(item => item.sectionTitle != null)
        //             console.log("retrieveCV resp  ", resp);
        //             this.CVQuesResponse = resp;
        //             this.showCaseComponent = true;
        //         }

        //     })
        //     .catch((err) => {
        //         this.showCaseComponent = false;
        //         //this.showToast("Error", "error", "Error occured in geting getAllCases " + err.message);
        //         console.log(" retrieveCV  error===", err);
        //     });

        this.showCaseComponent = true;

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

    @track recordtypeNane = 'Collateral Visit';
    getcvCloseCases() {
        let paramsCase = {
            ParentObjectName: 'Case',
            parentObjFields: ['Id'],
            queryCriteria: ' where Loan_Application__c	 = \'' + this._loanAppId + '\' AND RecordType.Name = \'' + this.recordtypeNane + '\' AND ApplAssetId__c = \'' + this._currentTabId + '\' AND IsCompleted__c = false AND CVStatus__c != \'Withdrawn\' order BY createdDate'
        }
        getSobjectDat({ params: paramsCase })
            .then((result) => {
                console.log('CV Case data is', JSON.stringify(result));

                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: "Kindly Complete In Progress CV before creating new CV",
                            variant: "error",
                            mode: 'sticky'
                        }),
                    );
                }
                else {
                    this.isShowModal = true;
                }

            })
            .catch((error) => {
                console.log('Error In getting CV Case Data ', error);
            });
    }
    employeee;
    @track isCPAUser = false;
    getUserRole() {
        let paramsLoanApp = {
            ParentObjectName: 'TeamHierarchy__c',
            parentObjFields: ['Id', 'EmpRole__c', 'Employee__c'],
            queryCriteria: ' where Employee__c = \'' + this.userId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('result is get Role ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.employeeRole = result.parentRecords[0].EmpRole__c;
                    this.employeee = result.parentRecords[0].Employee__c;
                    console.log('this.employeeRole is ', this.employeeRole);
                    if (this.employeeRole == 'UW' || this.employeeRole == 'ACM' || this.employeeRole == 'RCM' || this.employeeRole == 'ZCM' || this.employeeRole == 'NCM' || this.employeeRole == 'CH') {
                    }
                    else {
                        this.hasEditAccess = false;
                        this.isCPAUser = true;
                        this.isReadOnly = true;
                        this.isDisableWithdraw = true;
                        this.isDisableforCV = true;

                    }
                }
            })
            .catch((error) => {

                this.showSpinner = false;
                console.log("error occured in employeeRole", error);

            });
    }

    fromChildComp(event) {
        console.log('refresh from child' + event.detail);
        let val = event.detail;
        if (this.hasEditAccess) {
            if (val == 'Completed') {
                this.isDisableWithdraw = true;
            }
            else {
                this.isDisableWithdraw = false;
            }
        }
        this.dispatchEvent(new RefreshEvent());
    }

}