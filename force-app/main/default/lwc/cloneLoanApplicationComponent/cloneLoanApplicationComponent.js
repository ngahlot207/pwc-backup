import { LightningElement, api, track, wire } from 'lwc';
//Apex Methods
import cloneLoanApp from '@salesforce/apex/CloneLoanAppController.cloneLoanApp';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import { getRecord } from 'lightning/uiRecordApi';

import AppStage from "@salesforce/schema/LoanAppl__c.Stage__c";
import AppSubStage from "@salesforce/schema/LoanAppl__c.SubStage__c";
import AppFileAcc from "@salesforce/schema/LoanAppl__c.FileAcceptance__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import Id from "@salesforce/user/Id";
import { NavigationMixin } from "lightning/navigation";
export default class CloneLoanApplicationComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;

    @track showSpinner = true;
    @track userId = Id;
    @track showRmSelect = false;
    @track noLabel = 'No';
    @track cloneReaOptions = [
        { value: "BT + Top Up", label: "BT + Top Up" },
        { value: "Top up", label: "Top up on existing Fedfina loan" },
        { value: "Different Property", label: "Different Property" },
        { value: "Other", label: "Other" }
    ];
    @track emprole = 'RM';
    get filterConditionForLookup() {
        return 'Employee__c != \'' + this.userId + '\' AND EmpRole__c = \'' + this.emprole + '\''
    }


    // = 'EmpRole__c IN(\'' + this.emprole + '\',\'' + this.chrole + '\',\'' + this.acmrole + '\',\'' + this.rcmrole + '\',\'' + this.zcmrole + '\',\'' + this.ncmrole + '\') ' + 'AND Employee__c != \'' + this.userId + '\''
    connectedCallback() {

        setTimeout(() => {
            this.showSpinner = false;
        }, 3000);
    }
    @track loanSubStage;
    @track loanFileAcc;
    @wire(getRecord, { recordId: '$recordId', fields: [AppStage, AppSubStage, AppFileAcc] })
    currentRecordInfo({ error, data }) {
        if (data) {
            this.showSpinner = true;
            console.log('currentRecordInfo ', data);
            this.loanStage = data.fields.Stage__c.value;
            this.loanSubStage = data.fields.SubStage__c.value;
            this.loanFileAcc = data.fields.FileAcceptance__c.value;
            console.log('stage', this.loanStage);
            if (this.loanStage) {
                // this.getInporgCase();
                this.getSalesHierMetadat();
            }
        } else if (error) {
            this.error = error;
            this.showSpinner = false;
        }

    }

    @track creditHierNewArr = [];
    @track opsHierNewArr = [];
    getSalesHierMetadat() {
        this.showSpinner = true;
        let develoeprNames = ['Credit'];
        let paramsLoanApp = {
            ParentObjectName: 'SharingHierarchy__mdt',
            parentObjFields: ['Id', 'BrchRoleSharing__c', 'SupervisoreRoleSharing__c', 'DeveloperName'],
            queryCriteria: ' where DeveloperName  IN (\'' + develoeprNames.join('\', \'') + '\')'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('credit and ops hierarchy metadata is', JSON.stringify(result));
                if (result.parentRecords) {
                    let credArr = result.parentRecords.find(item => item.DeveloperName === 'Credit');
                    // let opsArr = result.parentRecords.find(item => item.DeveloperName === 'Ops');
                    if (credArr) {
                        let arrayFromString = credArr.BrchRoleSharing__c.split(',');
                        let arrayFromStringNew = [];
                        if (credArr.SupervisoreRoleSharing__c) {
                            arrayFromStringNew = credArr.SupervisoreRoleSharing__c.split(',');
                        }
                        let setFromArray = new Set([...arrayFromString, ...arrayFromStringNew]);
                        this.creditHierNewArr = Array.from(setFromArray);
                        console.log('this.creditHierNewArr', this.creditHierNewArr);
                    }
                    // if (opsArr) {
                    //     let arrayFromStringOps = opsArr.BrchRoleSharing__c.split(',');
                    //     // let arrayFromStringNew = opsArr.SupervisoreRoleSharing__c.split(',');
                    //     let arrayFromStringNewOps = [];
                    //     if (opsArr.SupervisoreRoleSharing__c) {
                    //         arrayFromStringNewOps = opsArr.SupervisoreRoleSharing__c.split(',');
                    //     }
                    //     let setFromArrayOps = new Set([...arrayFromStringOps, ...arrayFromStringNewOps]);
                    //     this.opsHierNewArr = Array.from(setFromArrayOps);
                    //     console.log('this.opsHierNewArr', this.opsHierNewArr);
                    // }
                    this.getTeamHierarchyData();
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting sales hierarchy details ', error);
            });
    }
    @track pdStatus = false;
    getPdData() {
        let status = ['Initiated', 'In Progress'];
        let paramsLoanApp = {
            ParentObjectName: 'PD__c',
            parentObjFields: ['Id', 'PDStatus__c'],
            queryCriteria: ' WHERE LoanAppl__c = \'' + this.recordId + '\' AND PDStatus__c IN (\'' + status.join('\', \'') + '\')'
        };

        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Pd inprogress data is ', JSON.stringify(result.parentRecords));
                if (result.parentRecords) {
                    this.pdStatus = true;
                } else {
                    this.pdStatus = false;
                }
                this.getInporgCase();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting pd details ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    @track caseInpro = false;
    @track recordTypeName = [];
    @track recordTypeString;
    getInporgCase() {
        let status = ['In Progress', 'New', 'Initiated'];
        let recordTypes = ['Collateral Visit', 'CPVFI', 'Legal', 'RCU', 'Technical', 'TSR', 'Vetting', 'LIP Vendor case'];
        let paramsLoanApp = {
            ParentObjectName: 'Case',
            parentObjFields: ['Id', 'RecordType.Name', 'CVStatus__c', 'Status'],
            queryCriteria: ' WHERE RecordType.Name IN (\'' + recordTypes.join('\', \'') + '\') AND Loan_Application__c = \'' + this.recordId + '\' AND (CVStatus__c IN (\'' + status.join('\', \'') + '\') OR Status IN (\'' + status.join('\', \'') + '\'))'
        };

        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('case inprogress data is ', JSON.stringify(result.parentRecords));
                if (result.parentRecords || this.pdStatus) {
                    if (this.pdStatus) {
                        this.recordTypeName.push('PD');
                    }
                    if (result.parentRecords) {
                        result.parentRecords.forEach(item => {
                            this.recordTypeName.push(item.RecordType.Name);
                        });
                    }
                    this.caseInpro = true;
                    this.allowClone = false;
                    this.noMatchFound = true; //LAK-10215
                    this.showSpinner = false;
                } else {
                    this.caseInpro = false;
                    this.allowClone = true;
                    // this.getSalesHierMetadat();
                }
                if (this.recordTypeName && this.recordTypeName.length > 0) {
                    const uniqueRecordTypes = [...new Set(this.recordTypeName)];
                    this.recordTypeString = uniqueRecordTypes.join(',');
                }
                

            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting case details ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    @track empRole;
    @track allowClone = false;
    @track noMatchFound = false; //LAK-10215
    getTeamHierarchyData() {
        let paramsLoanApp = {
            ParentObjectName: 'TeamHierarchy__c',
            parentObjFields: ['Id', 'Employee__c', 'EmpRole__c'],
            queryCriteria: ' where Employee__c = \'' + this.userId + '\' ORDER BY LastModifiedDate DESC'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('team hierarchy data is', JSON.stringify(result.parentRecords));
                if (result.parentRecords) {
                    this.empRole = result.parentRecords[0].EmpRole__c;
                    console.log('empRole', this.empRole);
                }
                if (this.empRole) {
                    // removed this.loanStage && this.loanStage !== 'Disbursed' for LAK-9398
                    if (this.creditHierNewArr.includes(this.empRole)) {
                        // this.allowClone = true;
                        // this.getInporgCase();
                        this.getPdData();
                    } else {
                        this.noMatchFound = true; //LAK-10215
                        this.allowClone = false;
                    }
                }
                this.showSpinner = false;
                console.log('this.allowClone', this.allowClone);
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting team hierarchy details ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    @track cloneResValue;
    handleChange(event) {
        console.log('cloneResValue==>>>>> ', event.target.value)
        this.cloneResValue = event.target.value;
        if (this.cloneResValue === 'Top up' || this.cloneResValue === 'Different Property' || this.cloneResValue === 'Other') {
            this.showRmSelect = true;
        } else {
            this.showRmSelect = false;
        }
    }

    @track lookupId;
    handleLookupFieldChange(event) {
        if (event.detail) {
            this.lookupId = event.detail.id;
        }
    }

    handleCloneLoanApplication() {
        if (this.cloneResValue && this.cloneResValue === 'BT + Top Up') {
            this.callCloneLoanAppController();
        } else if (this.cloneResValue && this.cloneResValue !== 'BT + Top Up' && this.lookupId) {
            this.callCloneLoanAppController();
        } else {
            this.showToastMessage('Error', 'Select Input Data', 'error', 'sticky');
        }
    }
    @track showMsg = false;
    @track loanAppLink;
    @track clonedRecordId;
    callCloneLoanAppController() {
        this.showSpinner = true;
        let inputData = {
            recordId: this.recordId,
            userId: this.userId,
            rmSmId: this.lookupId,
            cloneReason: this.cloneResValue
        }
        cloneLoanApp({ inputData: inputData })
            .then((result) => {
                if (result && result != null) {
                    console.log('results is', result);
                    if (result.clonedRecordId) {
                        console.log('results is', result);
                        this.clonedRecordId = result.clonedRecordId;
                        this.loanAppUrl = '/lightning/r/LoanAppl__c/' + result.clonedRecordId + '/view';
                        this.loanAppLink = result.clonedLoanNumber;
                        this.noLabel = 'Ok';
                        this.allowClone = false;
                        this.showMsg = true;
                        this.showSpinner = false;
                        //this.showToastMessage('Success', 'Cloning of Loan Application is In Progress. New Loan Application Number is ' + result.clonedLoanNumber, 'success', 'sticky');
                    }
                } else {
                    this.showSpinner = false;
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.showToastMessage('Success', 'Cloning of Loan Application Failed', 'success', 'sticky');
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                if (error.body && error.body.message) {
                    console.log('Error In getting team hierarchy details ', error.body.message);
                    this.showToastMessage('Error', error.body.message, 'error', 'sticky');
                    //this.errorMessage = error.body.message;
                }
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
    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    noBtn() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    navigateToLoanApplication(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.clonedRecordId,
                objectApiName: 'LoanAppl__c',
                actionName: 'view'
            }
        });
    }

    // handleNottoProceed() {
    //     this.showSpinner = false;
    //     this.allowClone = false;
    //     this.caseInpro = false;
    // }
    handleYesButton() {
        this.allowClone = true;
        this.caseInpro = false;
    }
}