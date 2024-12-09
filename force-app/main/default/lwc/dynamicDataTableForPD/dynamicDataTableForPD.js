import { LightningElement, track, api, wire } from 'lwc';
import getDynamicTableDataList from '@salesforce/apex/DynamicLWCDataTableController.getWrapperOfSObjectFieldColumnActionValues';
import { refreshApex } from '@salesforce/apex';
import formFactorPropertyName from "@salesforce/client/formFactor";
export default class DynamicDataTableForPD extends LightningElement {


    @api pdQuestion;
    @api hasEditAccess;

    @track columnConfig;
    @track tableData = [];
    @track desktopBoolean = false;
    @track phoneBolean = false;
    @track hideTable = false;
    @track wiredData = {};
    @track _paramsData;
    @track formFactor = formFactorPropertyName;
    @track reqFiedErrorMsz = false;
    enableInfiniteScrolling = true;
    enableBatchLoading = true;
    @api get paramsData() {
        return this._paramsData;
    }
    set paramsData(value) {
        this._paramsData = value;
        this.setAttribute("paramsData", value);

    }
    get tableTitle() {
        //  return this.tableConfig.type == "Number" ? true : false;
        if (this.pdQuestion && this.pdQuestion.quesTitle) {
            return this.pdQuestion.quesTitle;
        } else {
            return '';
        }

        //  return this.tableConfig.type == "Number" && !this.tableConfig.type ? true : false;
    }
    get disableMode() {
        if (this.hasEditAccess) {
            return false;
        } else {
            return true;
        }

    }

    // @wire(getDynamicTableDataList, { params: '$paramsData' })
    // wiredContacts(result) {
    //     this.wiredData = result;
    //     if (result.data) {
    //         console.log('data for table is', JSON.stringify(result.data));
    //         let sObjectRelatedFieldListValues = [];

    //         for (let row of result.data.lstDataTableData) {
    //             const finalSobjectRow = {}
    //             let rowIndexes = Object.keys(row);
    //             rowIndexes.forEach((rowIndex) => {
    //                 const relatedFieldValue = row[rowIndex];
    //                 if (relatedFieldValue.constructor === Object) {
    //                     this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndex)
    //                 }
    //                 else {
    //                     finalSobjectRow[rowIndex] = relatedFieldValue;
    //                 }

    //             });
    //             sObjectRelatedFieldListValues.push(finalSobjectRow);
    //         }
    //         this.columnConfig = result.data;
    //         // this.columnConfig.tableTitle = 'Datatable Response Data';
    //         this.tableData = sObjectRelatedFieldListValues;
    //     }
    //     else if (result.error) {
    //         this.error = result.error;
    //         console.log(this.error);
    //     }
    // }

    // _flattenTransformation = (fieldValue, finalSobjectRow, fieldName) => {
    //     let rowIndexes = Object.keys(fieldValue);
    //     rowIndexes.forEach((key) => {
    //         let finalKey = fieldName + '.' + key;
    //         finalSobjectRow[finalKey] = fieldValue[key];
    //     })
    // }
    @track tableColumns;

    connectedCallback() {
        console.log('pdQuestion in tablecomp', JSON.stringify(this.pdQuestion));
        if (this.pdQuestion.quesConfig) {
            let tableVal = JSON.parse(this.pdQuestion.quesConfig);
            console.log("pdQuestion in tablecomp in obj", JSON.parse(JSON.stringify(tableVal)));
            if (tableVal.data) {
                this.tableData = tableVal.data;
            }
            this.columnConfig = tableVal;


            // this.tableColumns = [
            //     { "fieldName": "IncomeType__c", "label": "Type" },
            //     { "fieldName": "OtherRevenueMonthly__c", "label": "Monthly Amount" }
            // ];
            //   this.tableColumns = tableVal.columns;


            // this.columnConfig = JSON.parse(JSON.stringify(cc))
        }

        if (!this.tableData) {
            this.handleAddRecord();
        }
        // this.tableData = [{ 'Id': 'a0oC40000007FwnIAE', "IncomeType__c": "Cash Salary", "OtherRevenueMonthly__c": "232323" }, { 'Id': 'a0oC40000007FwnI2E', "IncomeType__c": "Cash Salary", "OtherRevenueMonthly__c": "4343" }, { 'Id': 'a0oC40000007FwnI4E', "IncomeType__c": "Cash Salary", "OtherRevenueMonthly__c": "77777777" }];
        // (Applicant_Income__c:{Id=a0oC40000007FwnIAE, RecordTypeId=012C4000000XwWfIAK}, Applicant_Income__c:{Id=a0oC40000007FwoIAE, RecordTypeId=012C4000000XwWfIAK}, Applicant_Income__c:{Id=a0oC40000007FwpIAE, RecordTypeId=012C4000000XwWfIAK})

        //     "objectName": "Applicant_Income__c",
        //     "enableAddMore": true,
        //     "columns": [
        //         {
        //             "label": "Type",
        //             "fieldName": "IncomeType__c",
        //             "type": "Picklist",
        //             "Editable": true,
        //             "options": [
        //                 "Agricultural Income",
        //                 "Bank Credit Salary",
        //                 "Cash Salary",
        //                 "Cashflow Map",
        //                 "Pension Income",
        //                 "Other Income"
        //             ]
        //         },
        //         {
        //             "label": "Monthly Amount",
        //             "fieldName": "OtherRevenueMonthly__c",
        //             "type": "Number",
        //             "Editable": true
        //         }
        //     ]
        // }


        console.log('this.columnConfig', this.columnConfig);
        refreshApex(this.wiredData);
        if (this.formFactor == "Large") {
            this.desktopBoolean = true;
            this.phoneBolean = false;
        } else if (this.formFactor == "Small") {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        } else {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        }
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
    // below for table 
    // @track params = {};
    // @track paramsAppl = {};
    // @track columnsDataForTable = [
    //     {
    //         "label": "Sr No",
    //         "fieldName": "SrNo__c",
    //         "type": "text",
    //         "Editable": false
    //     },
    //     {
    //         "label": "Request time",
    //         "fieldName": "ReqTime__c",
    //         "type": "Date/Time",
    //         "Editable": false
    //     },
    //     {
    //         "label": "Response time",
    //         "fieldName": "ResTime__c",
    //         "type": "Date/Time",
    //         "Editable": false
    //     },
    //     {
    //         "label": "Hunter match status",
    //         "fieldName": "HunMatchSta__c",
    //         "type": "text",
    //         "Editable": false
    //     },
    //     {
    //         "label": "Hunter status where Match found",
    //         "fieldName": "HunStaWheMatFound__c",
    //         "type": "text",
    //         "Editable": false
    //     }
    // ];
    // @track isModalOpen = false;
    // @track queryData = 'SELECT SrNo__c,ReqTime__c,ResTime__c,HunMatchSta__c,HunStaWheMatFound__c,Id FROM HunterVer__c WHERE LoanAplcn__c =: loanAppId';
    // connectedCallback() {
    //     let paramVal = [];
    //     paramVal.push({ key: 'loanAppId', value: this.loanAppId });
    //     this.queryParam = paramVal;
    //     console.log('map data:::', this.queryParam);
    //     this.params = {
    //         columnsData: this.columnsDataForTable,
    //         queryParams: this.queryParam,
    //         query: this.queryData
    //     }
    // }

    @track addedRecCount = 0;
    handleAddRecord(event) {
        this.hideTable = true;
        //  this.
        // this.tableColumns
        // this.tableData
        console.log('old added tableData', this.tableData);
        let str = '';
        if (this.pdQuestion.respId) {
            str = this.pdQuestion.respId + this.addedRecCount;
        } else {
            str = 'tcount' + this.addedRecCount;
        }

        let blankRec = { "Id": str };
        this.columnConfig.columns.forEach(element => {
            blankRec[element.fieldName] = ''
        });

        this.tableData.push(blankRec);
        console.log('ne added tableData', this.tableData);
        this.hideTable = false;
        this.addedRecCount = this.addedRecCount + 1;
    }
    fromChildComp(event) {

        console.log('fromChildComp in dynamic data table', event.detail);

        let param = event.detail;
        this.tableData.forEach(element => {
            if (element.Id === param.Id && element.fieldName === param.fiel) {
                element[param.fieldName] = param.value;

            }

        });

        console.log('updated this.tableData', param, JSON.stringify(this.tableData));

        let changedValue = { respType: this.pdQuestion.respType, recordTypeId: this.pdQuestion.recordTypeId, objectName: this.columnConfig.objectName, tablevalue: param }
        const selectEvent = new CustomEvent('passtoparent', {
            detail: changedValue
        });
        this.dispatchEvent(selectEvent);
    }


    handleDelete(event) {
        let recordId = event.target.dataset.id;
        console.log('handleDelete ', recordId);
        // const findIndex = this.tableData.findIndex(a => a.Id === recordId);
        //this.tableData.slice(findIndex, 1);
        this.tableData = this.tableData.filter(obj => obj.Id !== recordId);
        //if (recordId.length == 18) {
        let param = { fieldName: 'IsDeleted', value: true, Id: recordId };
        let changedValue = { respType: this.pdQuestion.respType, recordTypeId: this.pdQuestion.recordTypeId, objectName: this.columnConfig.objectName, tablevalue: param }
        const selectEvent = new CustomEvent('passtoparent', {
            detail: changedValue
        });
        this.dispatchEvent(selectEvent);
        //}
    }

    @api reportValidity() {
        let isValid = true;

        if (this.pdQuestion.isReqPortal && this.tableData.length === 0) {
            isValid = false;
            this.reqFiedErrorMsz = true;
        } else {
            this.reqFiedErrorMsz = false;
        }

        this.template.querySelectorAll('c-dynamic-datatable-display-value-for-pd').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed lightning-textarea');
                console.log('element if--' + element.value);
            } else {
                isValid = false;
            }
        });
        return isValid;
    }
}