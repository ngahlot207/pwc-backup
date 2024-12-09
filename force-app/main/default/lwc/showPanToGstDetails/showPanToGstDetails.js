import { LightningElement, api, track, wire } from 'lwc';
//Apex Methods
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class ShowPanToGstDetails extends LightningElement {
    @api loanAppId = 'a08C4000007x0uSIAQ';
    @api hasEditAccess;

    @track disableReintiate = false;
    @track isReadOnly;
    @track panToGstData = [];
    @track appData = [];
    @track showModal = false;
    @track apVerAppIds = [];
    @track panToGstFailedData = [];
    @track intRecords = [];
    enableInfiniteScrolling = true;
    enableBatchLoading = true;
    @track showSpinner = false;

    connectedCallback() {
        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }
        this.isReadOnly = false;
        this.disableReintiate = this.isReadOnly;
        this.getApplicantsData();
    }
    getApplicantsData() {
        this.appData =[];
        this.showSpinner = true;
        let typeOfBorrow = 'Financial'
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'FullName__c','Type_of_Borrower__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND Type_of_Borrower__c = \'' + typeOfBorrow + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Applicants Data is :: 43', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.appData = result.parentRecords;
                }
                this.getPantoGstDetails();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Api Verification Data is is :: 43', JSON.stringify(error));
            });
    }
    getPantoGstDetails() {
        let isGST = 'GST';
        let params = {
            ParentObjectName: 'APIVer__c',
            parentObjFields: ['Id', 'Invalid__c', 'Appl__c', 'Appl__r.FullName__c', 'toLabel(Appl__r.ApplType__c)', 'Appl__r.Constitution__c', 'Appl__r.PAN__c', 'IntegrationStatus__c', 'GSTIN__c', 'GSTIN_RefId__c', 'GSTIN_Status__c', 'ConstBuisnessGST__c', 'LegalNameOfBusiness_GST_Certificate__c', 'TradeName_GST_Certificate__c', 'DateOfRegistration__c', 'IntegrationErrorMessage__c', 'Verification_Status__c','CancellationDt__c','Name_Match_Score__c','Address__c'],
            queryCriteria: ' where LoanAplcn__c = \'' + this.loanAppId + '\' AND RecordType.Name = \'' + isGST + '\' AND Invalid__c = false'
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Api Verification Data is ', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.panToGstData = result.parentRecords;
                    result.parentRecords.forEach(item => {
                        if (item.Appl__c) {
                            this.apVerAppIds.push(item.Appl__c);
                        }
                    })
                    this.apVerAppIds = [...new Set(this.apVerAppIds)];
                }
                this.checkReIntiateLogic();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Api Verification Data is ', error);
            });
    }
    @track appDataDisplay = [];
    checkReIntiateLogic() {
        this.appDataDisplay = [];
        if (this.appData && this.appData.length > 0) {
            this.appData.forEach(app => {
                if (this.apVerAppIds && this.apVerAppIds.length > 0 && this.apVerAppIds.includes(app.Id)) {
                    let tempArr = this.panToGstData.filter(item => item.Appl__c === app.Id);
                    if (tempArr && tempArr.length > 0) {
                        tempArr.forEach(ite => {
                            if (ite.IntegrationStatus__c && ite.IntegrationStatus__c === 'Failure') {
                                this.appDataDisplay.push(app);
                            }
                        })
                    }
                } else {
                    this.appDataDisplay.push(app);
                }
            })
        }
        console.log('this.appDataDisplay===>', this.appDataDisplay);
        if (this.appDataDisplay && this.appDataDisplay.length > 0) {
            this.disableReintiate = false;
        } else {
            this.disableReintiate = true;
        }
        this.showSpinner = false;
    }
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

    handleClick(event) {
        console.log('record ', event.target.dataset.recordid);
        let selectedRecordId = event.target.dataset.recordid;
        console.log('value is', event.target.checked);
        console.log('All selected Records before ', this.appDataDisplay);
        let val = event.target.checked;
        let recordData = {};
        let searchDoc = this.appDataDisplay.find((doc) => doc.Id === selectedRecordId);
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

    handleReIntialization() {
        this.showModal = false;
        this.showSpinner = true;
        let filteredData = this.appDataDisplay.filter(item => item.selectCheckbox === true);
        console.log('All filteredData Records', JSON.stringify(filteredData));
        if (filteredData.length > 0) {
            this.createIntMsg(filteredData);
        } else {
            this.showToastMessage('Error', 'Please Select Applicant to Re-Initiate', 'Error', 'sticky');
            this.showSpinner = false;
        }
    }
    @track serviceName = 'GST Search Basis PAN';
    createIntMsg(appIds) {
        appIds.forEach(item => {
            let fields = {};
            fields['sobjectType'] = 'IntgMsg__c';
            fields['Name'] = this.serviceName;
            fields['BU__c'] = 'HL / STL';
            fields['IsActive__c'] = true;
            fields['Svc__c'] = this.serviceName;
            fields['ExecType__c'] = 'Async';
            fields['Status__c'] = 'New';
            fields['Mresp__c'] = 'Blank';
            fields['Outbound__c'] = true;
            fields['Trigger_Platform_Event__c'] = false;
            fields['RefObj__c'] = 'Applicant__c';
            fields['RefId__c'] = item.Id;
            fields['ParentRefObj__c'] = "LoanAppl__c";
            fields['ParentRefId__c'] = this.loanAppId;
            // fields['RetriRatinal__c'] = item.RationalRemarks;
            this.intRecords.push(fields);
        })
        console.log('intRecords are', this.intRecords);
        this.upsertIntRecord(this.intRecords);
    }
    @track intMsgIds = [];
    upsertIntRecord(intRecords) {
        console.log('int msgs records ', JSON.stringify(intRecords));
        upsertMultipleRecord({ params: intRecords })
            .then((result) => {
                console.log('Result after creating Int Msgs is ', JSON.stringify(result));
                result.forEach(item => {
                    this.intMsgIds.push(item.Id);
                })
                this.showToastMessage('Success', 'Re-Initiated Successfully, Please Click on Refresh Button to See Details on Table', 'Success', 'sticky')
                console.log('intMsgIds after creating Int Msgs is ', JSON.stringify(this.intMsgIds));
                this.intRecords = [];
                this.showSpinner = false;
            })
            .catch((error) => {
                console.log('Error In creating Record', error);
                this.showSpinner = false;
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