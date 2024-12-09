import { LightningElement, api, track } from 'lwc';

//Apex Methods
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import userId from '@salesforce/user/Id';
import formFactorPropertyName from "@salesforce/client/formFactor";
// Custom labels
import ApplicationQuery_Hierarchy_ErrorMessage from '@salesforce/label/c.ApplicationQuery_Hierarchy_ErrorMessage';
import ApplicationQuery_Query_ErrorMessage from '@salesforce/label/c.ApplicationQuery_Query_ErrorMessage';
import ApplicationQuery_Save_SuccessMessage from '@salesforce/label/c.ApplicationQuery_Save_SuccessMessage';
import ApplicationQuery_Update_ErrorMessage from '@salesforce/label/c.ApplicationQuery_Update_ErrorMessage';

export default class ShowApplicationQueryDetails extends LightningElement {
    customLabel = {
        ApplicationQuery_Hierarchy_ErrorMessage,
        ApplicationQuery_Query_ErrorMessage,
        ApplicationQuery_Save_SuccessMessage,
        ApplicationQuery_Update_ErrorMessage

    }

    @api ndcId = 'a1TC40000005sHVMAY';
    @api isModalOpenApi = false;
    @api loanStage;
    @api loanSubstage;
    @track queryType;

    @track isModalOpen = false;
    @track userIdNew = userId;
    @track userData = {};
    @track queryRemarks;
    @track formFactor = formFactorPropertyName;
    @track desktopBoolean = false;
    @track phoneBolean = false;
    enableInfiniteScrolling = true;
    enableBatchLoading = true;
    @track applicationQueryData = [];
    @track currentDateTime;
    @track showSpinner = false;


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
        console.log('user id is ', this.userIdNew);
        this.getTeamHierarchyDetails();
        // this.getLoanApplicationData();
        if ((this.loanStage === 'Disbursement Initiation' || this.loanStage === 'Disbursed') && this.loanSubstage === 'DI Check') {
            this.queryType = 'NDC Query';
        } else {
            this.queryType = 'Response';
        }
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
                    this.getApplicationQueryDetails();
                }

            })
            .catch((error) => {
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: this.customLabel.ApplicationQuery_Hierarchy_ErrorMessage,
                        variant: "error",
                        mode: "sticky"
                    }),
                );
                console.log('Error In getting Team Hierarchy Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    getApplicationQueryDetails() {

        let params = {
            ParentObjectName: 'Application_Query__c',
            parentObjFields: ['Id', 'DateTime__c', 'Person_Name__c', 'QryTyp__c', 'Role__c', 'Remarks__c'],
            // queryCriteria: ` where LoanAppl__c = '${this.loanAppId}' ORDER BY Createddate DESC`
            queryCriteria: ' where NDC__c = \'' + this.ndcId + '\' ORDER BY Createddate DESC'
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('application query data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.applicationQueryData = result.parentRecords;
                    this.isModalOpen = this.isModalOpenApi;
                } else {
                    this.isModalOpen = this.isModalOpenApi;
                }
                console.log('applicationQueryData is ', this.applicationQueryData);

            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: this.customLabel.ApplicationQuery_Query_ErrorMessage,
                        variant: "error",
                        mode: "sticky"
                    }),
                );
                console.log('Error In getting payment data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    handlepopUp() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
        let val = {
            "closed": true
        }
        const selectEvent = new CustomEvent('passtoparent', {
            detail: val
        });
        this.dispatchEvent(selectEvent);
    }
    handleField1Change(event) {
        console.log('remarks value is', event.target.value);
        this.queryRemarks = event.target.value;
    }
    handleSave() {
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
                QryTyp__c: this.queryType,
                Person_Name__c: this.userData.Employee__r.Name,
                Role__c: this.userData.EmpRole__c,
                Remarks__c: this.queryRemarks,
                NDC__c: this.ndcId

            }
            this.upsertDataMethod(obje);
        } else {
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
                    console.log('result => ', result);
                    this.getNdcrecord();
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

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.customLabel.ApplicationQuery_Update_ErrorMessage,
                            message: error.body.message,
                            variant: "error",
                            mode: "sticky"
                        }),
                    );
                    this.showSpinner = false;
                });
        }
    }

    @track ndcRecord = {};
    getNdcrecord() {
        let params = {
            ParentObjectName: 'NDC__c',
            parentObjFields: ['Id', 'NDC_Type__c', 'OpsQuery__c', 'NDC_Section__c', 'ShowOpsQuery__c'],
            queryCriteria: ' where Id = \'' + this.ndcId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Ndc Recordd Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.ndcRecord = result.parentRecords[0];
                }

                const selectEvent = new CustomEvent('queryadd', {
                    detail: this.ndcRecord
                });
                this.dispatchEvent(selectEvent);
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;

                console.log('Error In getting Ndc records Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    validateForm() {
        let isValid = true;
        // this.template.querySelectorAll('lightning-input').forEach(element => {
        //     if (element.reportValidity()) {
        //         console.log('element passed');
        //     } else {
        //         isValid = false;
        //         // element.setCustomValidity('Please fill the valid value')
        //     }
        // });

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