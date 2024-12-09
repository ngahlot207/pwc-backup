import { LightningElement, api, track } from 'lwc';

//Apex Methods
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import userId from '@salesforce/user/Id';
import formFactorPropertyName from "@salesforce/client/formFactor";

import Application_Query_Remarks_Not_Added_Error from '@salesforce/label/c.Application_Query_Remarks_Not_Added_Error';
import ApplicationQuery_Save_SuccessMessage from '@salesforce/label/c.ApplicationQuery_Save_SuccessMessage';
import Ops_Verification_Success_Message from '@salesforce/label/c.Ops_Verification_Success_Message';

import CURRENT_USER_ID from '@salesforce/user/Id';
export default class ShowQueryButton extends LightningElement {

    @track customLabel = {
        ApplicationQuery_Save_SuccessMessage,
        Application_Query_Remarks_Not_Added_Error,
        Ops_Verification_Success_Message
    }

    @api loanAppId = 'a08C4000008AqqRIAS';
    @api sectionName = 'Mandatory Post Sanction Documents';
    @api hasEditAccess = false;


    @track userIdNew = userId;
    @track userData = {};
    @track showSpinner = false;
    @track showModal = false;
    @track opsVerified = false;
    @track queryRemarks;
    enableInfiniteScrolling = true;
    enableBatchLoading = true;
    @track applicationQueryData = [];
    @track formFactor = formFactorPropertyName;
    @track desktopBoolean = false;
    @track phoneBolean = false;
    @track disableMode = false;
    @track opsQuery = false;
    @track showOpsQuery = false;
    connectedCallback() {
        console.log('formFactor is ', this.formFactor);

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
        this.getTeamHierarchyDetails();
        this.getLoanApplicationData();
        this.getLoanTatData(); //LAK-8619
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        }
        else {
            this.disableMode = false;
        }

        // this.disableMode = false;
    }

     //LAK-8619
     @track queryEnable = false;
     getLoanTatData(){
         //this.showSpinner  = true;
             let params = {
                 ParentObjectName: 'LoanTAT__c',
                 parentObjFields: ['Id', 'Stage__c','Sub_Stage__c'],
                 queryCriteria: ' where LoanApplication__c = \'' + this.loanAppId + '\''
             }
             getSobjectData({ params: params })
                 .then((result) => {
                     this.showSpinner = true;
                     console.log('Loan TAT Data is ', JSON.stringify(result));
                     let isOpsThere = false;
                     if (result.parentRecords) {
                         result.parentRecords.forEach(item => {
                             if (item.Stage__c && item.Stage__c === 'Post Sanction' && item.Sub_Stage__c && item.Sub_Stage__c === 'Ops Query') {
                                 isOpsThere = true;
                             }
                         })
                     }
                     if (isOpsThere) {
                         // if (this.col.type === "Query") {
                             // if (this.ndcId && this.loanStage === 'Post Sanction' && this.loanSubstage === 'Ops Query') {
                                 this.queryEnable = true;
                     } 
                 })
                 .catch((error) => {
                    // this.showSpinner = false;
                     console.log('Error In getting Loan TAT Data is ', error);
                     //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
                 });
         
     }
    get buttoncolor() {
        return this.showOpsQuery ? 'destructive' : 'success';
    }
    get disableMo() {
        return this.loanStage === 'Disbursement Initiation' && this.loanSubstage === 'DI Check' && this.ownerId == CURRENT_USER_ID && !this.opsQuery && this.loanStatus !== 'Cancelled' && this.loanStatus !== 'Hold' && this.loanStatus !== 'Rejected' && this.loanStatus !== 'BRE Reject' && this.loanStatus !== 'Final Reject' && this.loanStatus !== 'Finnone Pending' ? false : true;
    }
    get disableModeQue() {
        let queryRemBoolean;
        if (this.ndcId && ((this.loanStage === 'Post Sanction' && this.loanSubstage === 'Ops Query') || (this.loanStage == 'Disbursed' && this.loanSubstage === 'Additional Processing')) && this.showOpsQuery && !this.opsVerified && this.ownerId == CURRENT_USER_ID) {
            queryRemBoolean = false;
        } else if (this.ndcId && ((this.loanStage === 'Disbursement Initiation' || this.loanStage === 'Disbursed') && this.loanSubstage === 'DI Check') && !this.opsVerified && this.ownerId == CURRENT_USER_ID) {
            queryRemBoolean = false;
        } //LAK-8619
        else if(this.queryEnable && this.ndcId && this.loanStage === 'Post Sanction' && this.loanSubstage === 'Data Entry' && this.showOpsQuery && !this.opsVerified && this.ownerId == CURRENT_USER_ID){
            this.queryRemBoolean = true;
        }
        else {
            queryRemBoolean = true;
        }
        return queryRemBoolean;
        //  return ((this.loanStage === 'Disbursement Initiation' && this.loanSubstage === 'DI Check') || (this.loanStage === 'Post Sanction' && this.loanSubstage === 'Ops Query') || (this.loanStage == 'Disbursed' && (this.loanSubstage === 'DI Check' || this.loanSubstage === 'Additional Processing'))) && this.ownerId == CURRENT_USER_ID && !this.opsVerified ? false : true;
    }
    getTeamHierarchyDetails() {
        this.showSpinner = true;
        let params = {
            ParentObjectName: 'TeamHierarchy__c',
            parentObjFields: ['Id', 'Employee__c', 'Employee__r.Name', 'EmpRole__c'],
            queryCriteria: ' where Employee__c = \'' + this.userIdNew + '\''
        }

        getSobjectData({ params: params })
            .then((result) => {
                console.log('Team Hierarchy Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.userData = result.parentRecords[0];
                    this.getNdcRecord();
                }

            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Team Hierarchy Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    @track loanStage;
    @track loanStatus;
    @track loanSubstage;
    @track queryType;
    @track ownerId;
    getLoanApplicationData() {
        let params = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Id', 'Name', 'Stage__c', 'SubStage__c', 'OwnerId', 'Status__c'],
            queryCriteria: ' where Id = \'' + this.loanAppId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                this.showSpinner = true;
                console.log('Loan Application Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    console.log('ownerId is ', result.parentRecords[0].OwnerId, CURRENT_USER_ID);
                    this.ownerId = result.parentRecords[0].OwnerId;
                    this.loanStage = result.parentRecords[0].Stage__c;
                    this.loanStatus = result.parentRecords[0].Status__c;
                    this.loanSubstage = result.parentRecords[0].SubStage__c;
                }
                if (this.loanStage === 'Disbursement Initiation' && this.loanSubstage === 'DI Check') {
                    this.queryType = 'NDC Query';
                } else {
                    this.queryType = 'Response';
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Loan App Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    get showOps() {
        return (this.loanStage === 'Disbursement Initiation' || this.loanStage == 'Disbursed') && this.loanSubstage === 'DI Check' ? true : false;
    }
    getNdcRecord() {
        // this.showSpinner = true;
        let params = {
            ParentObjectName: 'NDC__c',
            parentObjFields: ['Id', 'OpsQuery__c', 'OpsVer__c', 'ShowOpsQuery__c'],
            queryCriteria: ' where LoanAppl__c = \'' + this.loanAppId + '\' AND ScreenNames__c = \'' + this.sectionName + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Ndc Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.ndcId = result.parentRecords[0].Id;
                    this.opsQuery = result.parentRecords[0].OpsQuery__c;
                    this.showOpsQuery = result.parentRecords[0].ShowOpsQuery__c;
                    this.opsVerified = result.parentRecords[0].OpsVer__c;
                    console.log('ndc id  is existed ', this.ndcId);
                    this.getApplicationQueryDetails(this.ndcId);
                } else {
                    this.createNdcRecord();
                }
            })
            .catch((error) => {
                this.showSpinner - false;
                console.log('Error In getting Ndc Record Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    createNdcRecord() {
        let obje = {
            sobjectType: "NDC__c",
            LoanAppl__c: this.loanAppId,
            ScreenNames__c: this.sectionName,
            OpsQuery__c: false
        }
        console.log('objec ', obje);
        let newArray = [];
        if (obje) {
            newArray.push(obje);
        }
        if (newArray) {
            console.log('new array is ', JSON.stringify(newArray));
            upsertSObjectRecord({ params: newArray })
                .then((result) => {
                    console.log('Ndc record', JSON.stringify(result));
                    this.ndcId = result[0].Id;
                    this.opsQuery = result[0].OpsQuery__c;
                    console.log('ndc id  is created ', this.ndcId);
                    this.getApplicationQueryDetails(this.ndcId);
                })
                .catch((error) => {
                    console.log('error ', JSON.stringify(error));
                    console.table(error);
                    this.showSpinner = false;
                });
        }
    }


    getApplicationQueryDetails(ndcId) {
        let params = {
            ParentObjectName: 'Application_Query__c',
            parentObjFields: ['Id', 'DateTime__c', 'Person_Name__c', 'QryTyp__c', 'Role__c', 'Remarks__c'],
            // queryCriteria: ` where LoanAppl__c = '${this.loanAppId}' ORDER BY Createddate DESC`
            queryCriteria: ' where NDC__c = \'' + ndcId + '\' ORDER BY Createddate DESC'
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('application query data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.applicationQueryData = result.parentRecords;
                }
                console.log('applicationQueryData is ', this.applicationQueryData);
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Application Query Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    handleNdcRemarks() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    handleField1Change(event) {
        console.log('remarks value is', event.target.value);
        this.queryRemarks = event.target.value;
    }


    handleSave() {
        this.showModal = false;
        this.showSpinner = true;
        let d = new Date();
        let newD = new Date(d.getTime());
        this.currentDateTime = newD.toISOString();
        console.log('currentDateTime===', this.currentDateTime);
        let isInputCorrect = this.validateForm();
        console.log('isInputCorrect ', isInputCorrect);
        if (isInputCorrect === true) {
            this.isModalOpen = false;
            let obje = {
                sobjectType: "Application_Query__c",
                DateTime__c: this.currentDateTime,
                Person_Name__c: this.userData.Employee__r.Name,
                QryTyp__c: this.queryType,
                Role__c: this.userData.EmpRole__c,
                Remarks__c: this.queryRemarks,
                NDC__c: this.ndcId
            }
            this.upsertDataMethod(obje);
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: this.customLabel.Application_Query_Remarks_Not_Added_Error,
                    variant: "error",
                    mode: "sticky"
                }),
            );
            this.showSpinner = false;
        }
    }
    upsertDataMethod(obje) {
        console.log('objec ', obje);
        let newArray = [];
        if (obje) {
            newArray.push(obje);
        }
        if (newArray) {
            console.log('new array is ', JSON.stringify(newArray));
            upsertSObjectRecord({ params: newArray })
                .then((result) => {
                    console.log('result after creating ndc record is=> ', result);
                    this.getNdcRecord();
                    // console.log('ndcRecordDet record in is ', ndcRecordDet);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: this.customLabel.ApplicationQuery_Save_SuccessMessage,
                            variant: "success",
                            mode: "sticky"
                        }),
                    );
                    this.queryRemarks = '';
                    // this.getApplicationQueryDetails();
                    this.updateAppQueryRec(result[0].Id)
                    this.showSpinner = false;
                })
                .catch((error) => {
                    console.log('error ', JSON.stringify(error));
                    console.table(error);
                    this.showSpinner = false;
                });
        }
    }

    updateAppQueryRec(appQuId) {
        this.showSpinner = true;
        let obje = {
            sobjectType: "Application_Query__c",
            Id: appQuId,
            QryTyp__c: this.loanStage === 'Disbursement Initiation' && this.loanSubstage === 'DI Check' ? 'NDC Query' : 'Response'
        }
        console.log('objec ', obje);
        let newArray = [];
        if (obje) {
            newArray.push(obje);
        }
        if (newArray) {
            console.log('new array is ', JSON.stringify(newArray));
            upsertSObjectRecord({ params: newArray })
                .then((result) => {
                    console.log('result after creating ndc record is=> ', result);

                    this.showSpinner = false;
                })
                .catch((error) => {
                    console.log('error in updating apploication query ', JSON.stringify(error));
                    console.table(error);
                    this.showSpinner = false;
                });
        }
    }
    updateAppQuery() {
        let obje = {
            sobjectType: "Application_Query__c",
            DateTime__c: this.currentDateTime,
            Person_Name__c: this.userData.Employee__r.Name,
            QryTyp__c: 'NDC Query',
            Role__c: this.userData.EmpRole__c,
            Remarks__c: this.queryRemarks,
            NDC__c: this.ndcId
        }
        console.log('objec ', obje);
        let newArray = [];
        if (obje) {
            newArray.push(obje);
        }
        if (newArray) {
            console.log('new array is ', JSON.stringify(newArray));
            upsertSObjectRecord({ params: newArray })
                .then((result) => {
                    console.log('result => ', result);
                    this.getNdcRecord();
                    // console.log('ndcRecordDet record in is ', ndcRecordDet);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: this.customLabel.ApplicationQuery_Save_SuccessMessage,
                            variant: "success",
                            mode: "sticky"
                        }),
                    );
                    this.queryRemarks = '';
                    // this.getApplicationQueryDetails();
                    this.showSpinner = false;
                })
                .catch((error) => {
                    console.log('error ', JSON.stringify(error));
                    console.table(error);
                    this.showSpinner = false;
                });
        }
    }

    handleValueChange(event) {
        //ops verification updated
        this.showSpinner = true;
        this.opsVerified = event.target.checked;
        console.log('this.opsVerified  ', this.opsVerified, event.target.checked);
        let obje = {
            sobjectType: "NDC__c",
            Id: this.ndcId,
            OpsVer__c: this.opsVerified
        }
        console.log('objec ', obje);
        let newArray = [];
        if (obje) {
            newArray.push(obje);
        }
        if (newArray) {
            console.log('new array is ', JSON.stringify(newArray));
            upsertSObjectRecord({ params: newArray })
                .then((result) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: this.customLabel.Ops_Verification_Success_Message,
                            variant: "success",
                            mode: "sticky"
                        }),
                    );
                    this.showSpinner = false;
                })
                .catch((error) => {
                    console.log('error ', JSON.stringify(error));
                    console.table(error);
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
    }
    validateForm() {
        let isValid = true;
        this.template.querySelectorAll('lightning-textarea').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed');
            } else {
                console.log('this.paymentType ', this.paymentType);
                console.log(' this.paymentGateWay ', this.paymentGateWay);
                isValid = false;
                // element.setCustomValidity('Please fill the valid value')
            }

        });
        return isValid;
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
        console.log('e', e);
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
            console.log('tableBodyTds', tableBodyTds);
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