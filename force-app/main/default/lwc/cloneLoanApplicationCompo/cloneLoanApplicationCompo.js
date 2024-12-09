import { LightningElement, api, track, wire } from 'lwc';
//Apex Methods
import cloneLoanApp from '@salesforce/apex/CloneLoanAppController.cloneLoanApp';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import { getRecord } from 'lightning/uiRecordApi';

import AppStage from "@salesforce/schema/LoanAppl__c.Stage__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import Id from "@salesforce/user/Id";
import { NavigationMixin } from "lightning/navigation";
export default class CloneLoanApplicationCompo extends LightningElement {
    // @api recordId = 'a08C4000008YqVsIAK';
    @api hasEditAccess = false;
    @track recordId;
    @track isReadOnly = false;
    @track userId = Id;
    @track cloneResValue;
    @track emprole = 'RM';
    get filterConditionForLookup() {
        return 'Employee__c != \'' + this.userId + '\' AND EmpRole__c = \'' + this.emprole + '\''
    }

    @track cloneReaOptions = [
        { value: "BT + Top Up", label: "BT + Top Up" },
        { value: "Top up", label: "Top up on existing Fedfina loan" },
        { value: "Different Property", label: "Different Property" },
        { value: "Other", label: "Other" }
    ];

    @track showSpinnerNew = false;
    @track loanStage;

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
                    this.getTeamHierarchyData();
                }
            })
            .catch((error) => {
                this.showSpinnerNew = false;
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
                this.showSpinnerNew = false;
                console.log('Error In getting pd details ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    @track caseInpro = false;
    @track recordTypeName = [];
    @track recordTypeNameString;
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
                    this.recordTypeName = [...new Set(this.recordTypeName)];
                    this.recordTypeNameString = this.recordTypeName.join(', ');
                    console.log('recordTypeName ', this.recordTypeName);

                    this.caseInpro = true;
                    // this.allowClone = false;
                    this.showModal = false;
                    this.showSpinner = false;
                } else {
                    this.caseInpro = false;
                    this.showSpinner = false;

                    this.showloanAppNotFound = false;
                    this.showRemFields = true;
                    this.handle30DaysLogic();
                    // const createdDate = new Date(this.loanCreatedData);
                    // const currentDate = new Date();
                    // const diffTime = Math.abs(currentDate - createdDate);
                    // const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

                    // // Set a boolean to true if created date is greater than 30 days
                    // this.isCreatedDateGreaterThan30Days = diffDays > 30;
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting case details ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    @track empRole;
    @track allowClone = true;
    @track prodOptions;
    @track loggedInUSerCityId;
    getTeamHierarchyData() {
        let paramsLoanApp = {
            ParentObjectName: 'TeamHierarchy__c',
            parentObjFields: ['Id', 'Employee__c', 'EmpRole__c', 'Product_Type__c', 'EmpBrch__c'],
            queryCriteria: ' where Employee__c = \'' + this.userId + '\' ORDER BY LastModifiedDate DESC'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('team hierarchy data is', JSON.stringify(result.parentRecords));
                if (result.parentRecords) {
                    this.empRole = result.parentRecords[0].EmpRole__c;
                    console.log('empRole', this.empRole);
                    // this.loggedInUSerCityId = result.parentRecords[0].EmpBrch__c ? result.parentRecords[0].EmpBrch__c : '';
                    // if (result.parentRecords[0].Product_Type__c) {
                    //     const productTypes = result.parentRecords[0].Product_Type__c.split(';');

                    //     this.prodOptions = productTypes.map(type => {
                    //         return {
                    //             label: type.trim(),
                    //             value: type.trim()
                    //         };
                    //     });
                    // }
                }
                if (this.empRole) {
                    // removed this.loanStage && this.loanStage !== 'Disbursed' for LAK-9398
                    if (this.creditHierNewArr.includes(this.empRole)) {
                        // this.allowClone = true;
                        this.getPdData();
                    } else {
                        this.allowClone = false;
                        this.showSpinner = false;
                    }
                } else {
                    this.showSpinner = false;
                }
                // this.showSpinnerNew = false;
                console.log('this.allowClone', this.allowClone);
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting team hierarchy details ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    connectedCallback() {
        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }
        this.isReadOnly = false;
        // this.recordId = 'a08C4000008YqVsIAK';
        // this.getLoanData();
        // this.getLoggedInUserTHDetails();
    }
    @track isCreatedDateGreaterThan30Days = false;
    getLoanData() {
        this.showSpinnerNew = true;
        let paramsLoanApp = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Id', 'CreatedDate', 'LoginAcceptDate__c'],
            queryCriteria: ' WHERE Id = \'' + this.recordId + '\''
        };
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Loan App data is ', JSON.stringify(result.parentRecords));
                if (result.parentRecords && result.parentRecords.length > 0) {

                    const createdDate = new Date(result.parentRecords[0].LoginAcceptDate__c);

                    // Validate the created date
                    if (isNaN(createdDate.getTime())) {
                        console.error("Invalid date provided for loanCreatedData");
                        this.isCreatedDateGreaterThan30Days = false; // Set to false or handle as needed
                        return; // Exit if the date is invalid
                    }

                    const currentDate = new Date();
                    const diffTime = Math.abs(currentDate - createdDate);
                    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

                    // Set a boolean to true if the created date is greater than 30 days
                    this.isCreatedDateGreaterThan30Days = diffDays > 30;
                    // const createdDate = new Date(result.parentRecords[0].LoginAcceptDate__c);
                    // const currentDate = new Date();
                    // const diffTime = Math.abs(currentDate - createdDate);
                    // const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

                    // // Set a boolean to true if created date is greater than 30 days
                    // this.isCreatedDateGreaterThan30Days = diffDays > 30;
                }
                this.showSpinnerNew = false;
            })
            .catch((error) => {
                this.showSpinnerNew = false;
                console.log('Error in getting case details ', error);
            })

    }

    // getLoggedInUserTHDetails() {
    //     let paramsLoanApp = {
    //         ParentObjectName: 'TeamHierarchy__c',
    //         parentObjFields: ['Id', 'Employee__c', 'EmpRole__c'],
    //         queryCriteria: ' where Employee__c = \'' + this.userId + '\' ORDER BY LastModifiedDate DESC'
    //     }
    //     getSobjectData({ params: paramsLoanApp })
    //         .then((result) => {
    //             console.log('team hierarchy data is', JSON.stringify(result.parentRecords));
    //             if (result.parentRecords) {
    //                 this.empRole = result.parentRecords[0].EmpRole__c;
    //                 console.log('empRole', this.empRole);
    //             }
    //             if (this.empRole) {

    //             }
    //             this.showSpinner = false;
    //             console.log('this.allowClone', this.allowClone);
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getting team hierarchy details ', error);
    //             //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
    //         });
    // }

    @track showModal = false;

    @track lookupId;
    @track teamHierId;
    @track selectedDsaRm;
    @track enableBranch = true;
    handleLookupFieldChange(event) {
        console.log('Event detail after rm selection ', event.detail);
        this.showSpinner = true;
        if (event.detail) {
            this.enableBranch = false;
            this.productValue = '';
            this.branchValue = '';
            this.selectedDsaRm = event.detail.mainField;
            this.lookupId = event.detail.id;
            if (event.detail.record) {
                this.teamHierId = event.detail.record.Id;
            }
        }
        else {
            this.enableBranch = true;
        }
        if (this.teamHierId) {
            this.getRmTeamHierDetails();
        }
    }
    getRmTeamHierDetails() {
        let paramsLoanApp = {
            ParentObjectName: 'TeamHierarchy__c',
            parentObjFields: ['Id', 'Employee__c', 'EmpRole__c', 'Product_Type__c', 'EmpBrch__c'],
            queryCriteria: ' where Id = \'' + this.teamHierId + '\' ORDER BY LastModifiedDate DESC'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('team hierarchy data is', JSON.stringify(result.parentRecords));
                if (result.parentRecords) {
                    // this.loggedInUSerCityId = result.parentRecords[0].EmpBrch__c ? result.parentRecords[0].EmpBrch__c : '';
                    if (result.parentRecords[0].EmpBrch__c) {
                        this.loggedInUSerCityId = result.parentRecords[0].EmpBrch__c
                        this.getCityDetails();
                    }
                    // if (result.parentRecords[0].Product_Type__c) {
                    //     const productTypes = result.parentRecords[0].Product_Type__c.split(';');

                    //     this.prodOptions = productTypes.map(type => {
                    //         return {
                    //             label: type.trim(),
                    //             value: type.trim()
                    //         };
                    //     });
                    // }
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting team hierarchy details ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    @track picklistOptions = [];
    getCityDetails() {
        let paramsLoanApp = {
            ParentObjectName: 'LocBrchJn__c',
            parentObjFields: ['Id', 'Branch__r.Name', 'Branch__c'],
            queryCriteria: ' where Branch__c = \'' + this.loggedInUSerCityId + '\''
        };
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Location branch Junction data is', JSON.stringify(result.parentRecords));
                this.picklistOptions = []; // Initialize the picklist options array
                if (result.parentRecords) {
                    // Populate the picklist options
                    this.picklistOptions = result.parentRecords.map(record => {
                        return {
                            label: record.Branch__r.Name, // Display label
                            value: record.Branch__c       // Actual value to be used
                        };
                    });
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error in getting Location branch Junction details', error);
                // Handle error as needed
            });
    }

    get filterConditionForBranc() {
        // let returVal;
        // if (this.loggedInUserRole && this.loggedInUserRole === 'DSA') {
        //     returVal = ' Location__c = \'' + this.selectDSACityId + '\'';
        // } else {
        return ' Branch__c = \'' + this.loggedInUSerCityId + '\'';
        // }
        // return ' Location__c = \'' + this.selectDSACityId + '\'';
        // return returVal;
    }

    @track selectDSABranch;
    @track selectDSABranchId;
    handleBranchChange(event) {
        if (event.detail) {
            console.log('Event detail in Branch Change====> ', event.detail);
            this.selectDSABranch = event.detail.mainField;
            // this.locationBranJnId = event.detail.id;
            this.locationBranJnId = event.detail.record.Branch__c;
        }
    }

    @track loanNumber;
    @track showSpinner = false;
    @track showloanAppNotFound = false;
    @track showRemFields = false;
    @track loanCreatedData;
    handleValueChange(event) {
        this.showSpinner = true;
        this.loanNumber = event.target.value;
        if (this.loanNumber) {
            let paramsLoanApp = {
                ParentObjectName: 'LoanAppl__c',
                parentObjFields: ['Id', 'Applicant__c', 'Applicant__r.TabName__c', 'Product__c', 'RMSMName__r.Name', 'Status__c', 'Stage__c', 'SubStage__c', 'Finnone_Loan_Number__c', 'CreatedDate', 'Name', 'Branch__c', 'RMSMName__c', 'LoginAcceptDate__c'],
                queryCriteria: ' where (Finnone_Loan_Number__c = \'' + this.loanNumber + '\' OR Name = \'' + this.loanNumber + '\')'
            }
            getSobjectData({ params: paramsLoanApp })
                .then((result) => {
                    console.log('loan App Data is', JSON.stringify(result.parentRecords));
                    if (result.parentRecords && result.parentRecords.length > 0) {
                        if(result.parentRecords[0] && result.parentRecords[0].Stage__c&& result.parentRecords[0].Stage__c === 'QDE'){
                            this.showSpinner = false;
                            this.showToastMessage('Error', 'Loan Application cannot be cloned , Still it is in QDE Stage', 'error', 'sticky');
                        }else{
                            this.loanData = result.parentRecords[0];
                            this.recordId = result.parentRecords[0].Id;
                            this.loanCreatedData = result.parentRecords[0].LoginAcceptDate__c;
                            this.getSalesHierMetadat();
                        }
                    } else {
                        this.showRemFields = false;
                        this.showloanAppNotFound = true;
                        this.showSpinner = false;
                    }
                    // this.showSpinner = false;
                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log('Error In getting loan app details ', error);
                    //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
                });
        } else {
            this.showSpinner = false;
        }
    }


    @track productValue;
    @track branchValue;
    @track enableProduct = true;
    handleChange(event) {
        // console.log('cloneResValue==>>>>> ', event.target.value)
        // this.cloneResValue = event.target.value;

        let dataName = event.target.dataset.name;
        let val = event.target.value;
        if (dataName === 'Product') {
            this.productValue = val;
        } else if (dataName === 'Branch') {
            this.branchValue = val;
            this.getProDetails();
        } else if (dataName === 'Clone Reason') {
            this.cloneResValue = val;
        }
        console.log('productvalye is ', this.productValue);
        console.log('cloneResValue==>>>>> ', this.cloneResValue)

    }
    getProDetails() {
        let paramsLoanApp = {
            ParentObjectName: 'TeamHierarchy__c',
            parentObjFields: ['Id', ' Employee__c', 'EmpRole__c', 'Product_Type__c', 'EmpBrch__c'],
            queryCriteria: ' where Employee__c = \'' + this.lookupId + '\' AND EmpBrch__c = \'' + this.branchValue + '\''
        };

        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('team hierarchy data is', JSON.stringify(result.parentRecords));
                if (result.parentRecords) {
                    // Create a Set to collect unique product types
                    const uniqueProductTypes = new Set();

                    // Iterate over all records to collect product types
                    result.parentRecords.forEach(record => {
                        if (record.Product_Type__c) {
                            const productTypes = record.Product_Type__c.split(';');
                            productTypes.forEach(type => {
                                uniqueProductTypes.add(type.trim());
                            });
                        }
                    });

                    // Format the unique product types into options
                    this.prodOptions = Array.from(uniqueProductTypes).map(type => {
                        return {
                            label: type,
                            value: type
                        };
                    });
                }
                this.enableProduct = false;
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting team hierarchy details ', error);
            });
    }

    closeModal() {
        this.showModal = false;
        this.showSpinner = false;
    }

    closeCaseModal() {
        this.caseInpro = false;
    }
    handleCaseModal() {
        // this.showModal = true;
        this.showRemFields = true;
        this.showloanAppNotFound = false;
        this.caseInpro = false;
        this.handle30DaysLogic();
    }

    closeFalseModal() {
        this.allowClone = true;
    }

    handleNoButton() {
        this.showRemFields = false;
        this.showloanAppNotFound = false;
        this.lookupId = '';
        this.selectedDsaRm = '';
    }
    @track finaCheckedValue = false;
    @track bankingCheckedValue = false;
    @track incomeCheckedValue = false;
    handleCheckChange(event) {
        let dataName = event.target.dataset.name;
        let val = event.target.checked;
        if (dataName === 'Financials') {
            this.finaCheckedValue = val;
        } else if (dataName === 'Banking') {
            this.bankingCheckedValue = val;
        } else if (dataName === 'Income') {
            this.incomeCheckedValue = val;
        }
    }

    handle30DaysLogic() {
        const createdDate = new Date(this.loanCreatedData);

        // Validate the created date
        if (isNaN(createdDate.getTime())) {
            console.error("Invalid date provided for loanCreatedData");
            this.isCreatedDateGreaterThan30Days = false; // Set to false or handle as needed
            return; // Exit if the date is invalid
        }

        const currentDate = new Date();
        const diffTime = Math.abs(currentDate - createdDate);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

        // Set a boolean to true if the created date is greater than 30 days
        this.isCreatedDateGreaterThan30Days = diffDays > 30;
    }




    handleCloneLoanApplication() {
        if (this.cloneResValue) {
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
            cloneReason: this.cloneResValue,
            financial: this.finaCheckedValue,
            banking: this.bankingCheckedValue,
            income: this.incomeCheckedValue,
            branch: this.branchValue,
            product: this.productValue
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
                        // this.noLabel = 'Ok';
                        this.showRemFields = false;
                        this.showMsg = true;
                        this.showSpinner = false;
                        //this.showToastMessage('Success', 'Cloning of Loan Application is In Progress. New Loan Application Number is ' + result.clonedLoanNumber, 'success', 'sticky');
                    }
                } else {
                    this.showSpinner = false;
                    // this.dispatchEvent(new CloseActionScreenEvent());
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

    closeSuccssModal() {
        this.showMsg = false;
    }
}