import { LightningElement, api, track, wire } from 'lwc';
//Apex Methods
import getAssetPropType from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getSobjectDataWithoutCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjDtwithFltrRelatedRecordsWithoutCache';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
const verificationTypes = [
    { label: 'Successful', value: 'Successful' },
    { label: 'Failed', value: 'Failed' }
];
export default class ShowPanToGstDetails extends LightningElement {
    @api loanAppId = 'a08C4000007x0uSIAQ';
    @api hasEditAccess;
    @track userId = Id;
    @track disableReintiate = false;
    @track isReadOnly;
    @track panToGstData = [];
    @track appData = [];
    @track showModal = false;
    @track apVerAppIds = [];
    @track panToGstFailedData = [];
    @track intRecords = [];
    @track loanApplStage;
    enableInfiniteScrolling = true;
    enableBatchLoading = true;
    @track showSpinner = false;
    @track isUWStage = false;
    @track employeeRole;
    @track options = verificationTypes;


    connectedCallback() {

        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }
        this.isReadOnly = false;
        this.disableReintiate = this.isReadOnly;
        this.getUserRole();
        this.getApplicantsData();
    }
    // @track _loanAppId;
    // @api get loanAppId() {
    //     return this._loanAppId;
    // }
    // set loanAppId(value) {
    //     this._loanAppId = value;
    //     this.setAttribute("loanAppId", value);
    //     //this.handleRecordIdChange(value);
    // }

    getUserRole() {
        let paramsLoanApp = {
            ParentObjectName: 'TeamHierarchy__c',
            parentObjFields: ['Id', 'EmpRole__c', 'Employee__c'],
            queryCriteria: ' where Employee__c = \'' + this.userId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('result is get Role ', JSON.stringify(result));
                if (result) {
                    this.employeeRole = result[0].parentRecord.EmpRole__c;
                    console.log('result employeeRole ', JSON.stringify(this.employeeRole));
                    if (this.employeeRole === 'UW') {
                        this.isUWStage = true;
                    }
                }
            })
            .catch((error) => {

                this.showSpinner = false;
                console.log("error occured in employeeRole", error);

            });
    }


    // @wire(getRecord, { recordId: '$_loanAppId', fields: [LOAN_APPL_STAGE] })
    // StagePicklistValue({ data, error }) {
    //     if (data) {
    //         this.loanApplStage = data.fields.Stage__c.value ? data.fields.Stage__c.value : null;
    //         if(this.loanApplStage && this.loanApplStage === 'UnderWriting'){
    //             this.isUWStage = true;
    //         }
    //     }
    //     if (error) {
    //         console.log('Error in getting Loan Appl Stage',JSON.stringify(error));
    //     }
    // }

    showSaveButton = false;
    // getApplicantsData() {
    //     this.showSpinner = true;
    //     let params = {
    //         ParentObjectName: 'Applicant__c',
    //         parentObjFields: ['Id', 'FullName__c','CustProfile__c'],
    //         queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\''
    //     }
    //     getSobjectData({ params: params })
    //         .then((result) => {
    //             console.log('Applicants Data is ', JSON.stringify(result));
    //             if (result.parentRecords && result.parentRecords.length > 0) {
    //                 this.appData = result.parentRecords;
    //             }
    //             this.getProbeDetails();
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getApplicantsData Data is ', error);
    //         });
    // }
    getApplicantsData() {
        this.showSpinner = true;
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'FullName__c', 'CustProfile__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\''
        }
        getAssetPropType({ params: params })
            .then((result) => {
                console.log('Applicants Data is ', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.appData = result.parentRecords;
                }
                this.getProbeDetails();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Api Verification Data is ', error);
            });
    }
    parentRecords = [];
    childRecords = [];
    getProbeDetails() {
        this.parentRecords = [];
        this.childRecords = [];
        let isepfo = 'Employment';
        let params = {
            ParentObjectName: 'APIVer__c',
            ChildObjectRelName: 'API_Verification_Details__r',
            parentObjFields: ['Id', 'Appl__r.FullName__c', 'toLabel(Appl__r.ApplType__c)', 'Appl__r.MobNumber__c', 'Uan__c', 'Name__c', 'Name_Match_Score__c', 'FatherOrHusbandName__c', 'ContactMobNum__c', 'WrkExpInMnths__c', 'EPFOLookUpStatus__c', 'EPFOValidationStatus__c', 'IntegrationErrorMessage__c'],
            childObjFields: ['Id', 'StartMonthYear__c', 'LstMonthYear__c', 'EstablishmentName__c', 'Address__c', 'City__c', 'ExitReason__c', 'Status__c'],
            queryCriteria: ' where LoanAplcn__c = \'' + this.loanAppId + '\' AND RecordType.DeveloperName = \'' + isepfo + '\' AND IsLatest__c = true'
        }
        getSobjectDataWithoutCacheable({ params: params })
            .then((result) => {
                console.log('Api Verification Data is ', JSON.stringify(result));
                if (result) {
                    this.panToGstData = result;
                    this.panToGstData.forEach(record => {
                        // Store parent record
                        this.parentRecords.push(record.parentRecord);

                        // Store child records
                        if(record.ChildReords){
                            this.childRecords = this.childRecords.concat(record.ChildReords);
                        }
                        
                    });
                    console.log('parentRecords', JSON.stringify(this.parentRecords));
                    console.log('childRecords', JSON.stringify(this.childRecords));
                    if (this.parentRecords.size > 0) {
                        this.showSaveButton = true;
                    }
                    // this.parentRecords.forEach(item => {
                    //     if (item.Appl__c) {
                    //         this.apVerAppIds.push(item.Appl__c);
                    //     }
                    // })
                    // this.apVerAppIds = [...new Set(this.apVerAppIds)];
                }
                this.getApiRetriggerTrackerData();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Api Verification Data is ', error);
            });
    }

    // applIds = new Set();
    @track applIds = [];
    @track apiRetrgrTrcrData = [];
    getApiRetriggerTrackerData() {
        let apiName = 'EPF UAN Lookup';
        console.log('loanappId in Reintiate component', this.loanAppId);
        let paramsLoanApp = {
            ParentObjectName: 'APIRetriggerTracker__c',
            parentObjFields: ['Id', 'App__c','App__r.CustProfile__c', 'LoanApp__c', 'IsProcessed__c', 'App__r.TabName__c', 'App__r.Id','App__r.OTP_Verified__c', 'App__r.DigitalVerified__c'],
            queryCriteria: ' where IsProcessed__c = false AND LoanApp__c = \'' + this.loanAppId + '\' AND (App__r.OTP_Verified__c = true OR App__r.DigitalVerified__c = true) AND APIName__c = \'' + apiName + '\''
        }

        getAssetPropType({ params: paramsLoanApp })
            .then((result) => {
                console.log('apiRetrgrTrcrData in epfo', result);

                this.apiRetrgrTrcrData = [];
                if (result.parentRecords && result.parentRecords.length > 0) {
                    console.log('result.parentRecords', result.parentRecords.length);
                    result.parentRecords.forEach(item => {
                        if (item.App__c && item.App__r.CustProfile__c && item.App__r.CustProfile__c === 'SALARIED') {
                            this.apiRetrgrTrcrData.push(item.App__r.Id);
                        }
                        //this.apiRetrgrTrcrData.push(item.App__r.Id);
                        //this.applIds.add(item.App__r.Id);
                    })
                }
                this.getAppWithCallOutData();
                //this.getExpiApiData();
                console.log('disableReintiate in epfo', this.disableReintiate);
                // console.log('this.apiRetrgrTrcrData after in epfo', this.apiRetrgrTrcrData);
                if (result.error) {
                    console.error('apiRetrgrTrcrData result getting error=', result.error);
                }
            })
    }

    @track appDataDisplay = [];
    getAppWithCallOutData() {
        let apiName = ['EPF UAN Lookup', 'EPF UAN Validation'];
        let custProfile = 'SALARIED';
        let appTypes = ['P', 'C', 'G'];
        let paramsLoanApp = {
            ParentObjectName: 'Applicant__c',
            ChildObjectRelName: 'API_Callout_Trackers__r',
            parentObjFields: ['Id','CustProfile__c','OTP_Verified__c','DigitalVerified__c'],
            childObjFields: ['Id', 'LtstRespCode__c', 'APIName__c', 'Appl__r.Id', 'LAN__c'],
            queryCriteriaForChild: ' where LAN__c = \'' + this.loanAppId + '\' AND APIName__c IN (\'' + apiName.join('\', \'') + '\')',
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND CustProfile__c = \'' + custProfile + '\' AND (OTP_Verified__c = true OR DigitalVerified__c = true) AND ApplType__c  IN (\'' + appTypes.join('\', \'') + '\')'

        }
        getSobjectDataWithoutCacheable({ params: paramsLoanApp })
            .then((result) => {
                console.log('AppWithCallOutData in epfo', JSON.stringify(result));
                this.appDataDisplay = [];
                if (result && result.length > 0) {
                    result.forEach(item => {
                        if (item.ChildReords && item.ChildReords.length > 0) {
                            item.ChildReords.forEach(ite => {
                                if (ite.LtstRespCode__c != 'Success') {
                                    if (ite.Appl__c) {
                                        this.apiRetrgrTrcrData.push(ite.Appl__r.Id);
                                        //this.applIds.add(item.Appl__r.Id);
                                    }
                                }
                            })
                        } else {
                            this.apiRetrgrTrcrData.push(item.parentRecord.Id);
                        }
                    })
                }
                this.apiRetrgrTrcrData = [...new Set(this.apiRetrgrTrcrData)];
                this.applIds = [...this.apiRetrgrTrcrData];
                if (this.applIds.length === 0 || this.isReadOnly) {
                    this.disableReintiate = true;
                } else {
                    this.applIds.forEach(item => {
                        let obj = this.appData.find(it => it.Id === item);
                        if (obj && obj.CustProfile__c && obj.CustProfile__c === 'SALARIED') {
                            this.appDataDisplay.push(obj);
                        }
                    })
                }
                this.showSpinner = false;
                console.log('this.apiRetrgrTrcrData after second method in epfo', this.apiRetrgrTrcrData);
                console.log('this.appDataDisplay after second method in epfo', this.appDataDisplay);
                if (result.error) {
                    this.showSpinner = false;
                    console.error('apiRetrgrTrcrData result getting error=', result.error);
                }
            })
    }


    // checkReIntiateLogic() {
    //     if (this.parentRecords && this.parentRecords.length > 0) {
    //         this.parentRecords.forEach(app => {
    //             if (this.apVerAppIds && this.apVerAppIds.length > 0 && this.apVerAppIds.includes(app.Id)) {
    //                 let tempArr = this.parentRecords.filter(item => item.Appl__c === app.Id);
    //                 if (tempArr && tempArr.length > 0) {
    //                     tempArr.forEach(ite => {
    //                         if (ite.EPFOValidationStatus__c && ite.EPFOValidationStatus__c === 'Failure') {
    //                             this.appDataDisplay.push(app);
    //                         }
    //                         else if(ite.EPFOLookUpStatus__c && ite.EPFOLookUpStatus__c === 'Failure'){
    //                             this.appDataDisplay.push(app);
    //                         }
    //                     })
    //                 }
    //             } else {
    //                 this.appDataDisplay.push(app);
    //             }
    //         })
    //     }
    //     console.log('this.epfoData ', JSON.stringify(this.appDataDisplay));
    //     if (this.appDataDisplay && this.appDataDisplay.length > 0) {
    //         this.disableReintiate = false;
    //     } else {
    //         this.disableReintiate = true;
    //     }
    //     this.showSpinner = false;
    // }
    handleIntialization() {
        this.showModal = true;
    }
    handleRefreshClick() {
        this.showSpinner = true;
        setTimeout(() => {
            this.showSpinner = false;
            this.getApplicantsData();
        }, 6000);
        console.log('after');
    }

    handlevSubmit() {
        this.showSpinner = true;
        let filterdData = this.parentRecords;
        // if (filterdData && filterdData.length > 0) {
        //     filterdData.forEach(item => {
        //         delete item.ApplTyp__c;
        //     })
        // }
        console.log('filterdData is =========>', JSON.stringify(filterdData));
        upsertMultipleRecord({ params: filterdData })
            .then((result) => {
                console.log('Result after creating Int Msgs is ', JSON.stringify(result));
                this.showSpinner = false;
                this.showToastMessage('Success', 'Verification Data Saved Successful!', 'success', 'sticky');
                // this.dispatchEvent(evt);
                // this.getWatchOutDetails();
                // filterdData = [];

            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In creating Record', error);
                // this.fireCustomEvent("Error", "error", "Error occured in accepting File  " + error, false);
            });
    }

    handleClick(event) {
        console.log('record ', event.target.dataset.recordid);
        let selectedRecordId = event.target.dataset.recordid;
        console.log('value is', event.target.checked);
        console.log('All selected Records before ', this.apiRetrgrTrcrData);
        let val = event.target.checked;
        let recordData = {};
        let searchDoc = this.appDataDisplay.find((app) => app.Id === selectedRecordId);
        if (searchDoc) {
            console.log('searchDoc', searchDoc);
            //searchDoc = { ...searchDoc, selectCheckbox: val }
            searchDoc['selectCheckbox'] = val;
        }
        else {
            recordData['Id'] = selectedRecordId;
            recordData['selectCheckbox'] = val;
            this.appDataDisplay.push(recordData);
        }
        console.log('All selected Records', this.appDataDisplay);
    }
    closeModal() {
        this.showModal = false;
    }

    handleChange(event) {
        let val = event.target.value;
        let appRecordId = event.target.dataset.recordid;
        let nameVal = event.target.name;
        console.log('val is ', val, 'watchOutRecordId is ', appRecordId, ' name is ', nameVal);
        let obj = this.parentRecords.find(item => item.Id === appRecordId);
        if (obj) {
            console.log('obj is ', JSON.stringify(obj));
            obj[nameVal] = val;
            //this.callEnpaMethod();
        }

    }

    // intRecords = [];
    handleReIntialization() {
        this.showSpinner = true;
        this.showModal = false;
        console.log('handle reintialization called');
        let filteredData = this.appDataDisplay.filter(item => item.selectCheckbox === true);
        console.log('All filteredData Records', JSON.stringify(filteredData));
        if (filteredData.length > 0) {
            this.createIntegrationMsg(filteredData);
        } else {
            this.showSpinner = false;
            this.showToastMessage('Error', 'Please Select Applicant to Re-Initiate', 'Error', 'sticky')
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
    createIntegrationMsg(filteredData) {
        filteredData.forEach(item => {
            let fields = {};
            fields['sobjectType'] = 'IntgMsg__c';
            fields['Name'] = 'EPF UAN Lookup'; //serviceName;//'KYC OCR'
            fields['BU__c'] = 'HL / STL';
            fields['IsActive__c'] = true;
            fields['Svc__c'] = 'EPF UAN Lookup'; //serviceName;
            fields['ExecType__c'] = 'Async';
            fields['Status__c'] = 'New';
            fields['RefObj__c'] = 'Applicant__c';
            fields['RefId__c'] = item.Id;
            this.intRecords.push(fields);
        })
        console.log(JSON.stringify(this.intRecords));
        this.upsertIntRecord(this.intRecords);
    }

    intMsgIds = [];
    upsertIntRecord(intRecords) {
        console.log('int msgs records ', JSON.stringify(intRecords));
        upsertMultipleRecord({ params: intRecords })
            .then((result) => {
                console.log('Result after creating Int Msgs is ', JSON.stringify(result));
                result.forEach(item => {
                    this.intMsgIds.push(item.Id);
                })
                console.log('intMsgIds after creating Int Msgs is ', JSON.stringify(this.intMsgIds));
                console.log('before');
                setTimeout(() => {
                    this.showSpinner = false;
                    this.getApplicantsData();
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        variant: 'success',
                        message: 'Re-Initiated Successfully, Please Click on Refresh Button to See Details on Table'
                    });
                    this.dispatchEvent(evt);
                }, 6000);
                console.log('after');
                this.intRecords = [];
            })
            .catch((error) => {
                console.log('Error In creating Record', error);
                this.showSpinner = false;
                // this.fireCustomEvent("Error", "error", "Error occured in upsertMultipleRecord " + error, false);
            });
    }


    // handleReIntialization() {
    //     this.showModal = false;
    //     this.showSpinner = true;
    //     let filteredData = this.appDataDisplay;
    //     console.log('All filteredData Records', JSON.stringify(filteredData));
    //     if (filteredData.length > 0) {
    //         this.createIntMsg(filteredData);
    //     } else {
    //         this.showToastMessage('Error', 'Please Select Applicant to Re-Initiate', 'Error', 'sticky');
    //         this.showSpinner = false;
    //     }
    // }
    // @track serviceName = 'EPF UAN Lookup';
    // createIntMsg(appIds) {
    //     appIds.forEach(item => {
    //         let fields = {};
    //         fields['sobjectType'] = 'IntgMsg__c';
    //         fields['Name'] = this.serviceName;
    //         fields['BU__c'] = 'HL / STL';
    //         fields['IsActive__c'] = true;
    //         fields['Svc__c'] = this.serviceName;
    //         fields['Status__c'] = 'New';
    //         fields['Mresp__c'] = 'Blank';
    //         fields['RefObj__c'] = 'Applicant__c';
    //         fields['RefId__c'] = item.Appl__r.Id;
    //         // fields['RetriRatinal__c'] = item.RationalRemarks;
    //         this.intRecords.push(fields);
    //     })
    //     console.log('intRecords are', this.intRecords);
    //     this.upsertIntRecord(this.intRecords);
    // }
    // @track intMsgIds = [];
    // upsertIntRecord(intRecords) {
    //     console.log('int msgs records ', JSON.stringify(intRecords));
    //     upsertMultipleRecord({ params: intRecords })
    //         .then((result) => {
    //             console.log('Result after creating Int Msgs is ', JSON.stringify(result));
    //             result.forEach(item => {
    //                 this.intMsgIds.push(item.Id);
    //             })
    //             this.showToastMessage('Success', 'Re-Initiated Successfully, Please Click on Refresh Button to See Details on Table', 'Success', 'sticky')
    //             console.log('intMsgIds after creating Int Msgs is ', JSON.stringify(this.intMsgIds));
    //             this.intRecords = [];
    //             this.showSpinner = false;
    //         })
    //         .catch((error) => {
    //             console.log('Error In creating Record', error);
    //             this.showSpinner = false;
    //         });
    // }
    // showToastMessage(title, message, variant, mode) {
    //     const evt = new ShowToastEvent({
    //         title,
    //         message,
    //         variant,
    //         mode
    //     });
    //     this.dispatchEvent(evt);
    // }
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
}