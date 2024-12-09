import { LightningElement, track, api, wire } from 'lwc';
import getDynamicTableDataList from '@salesforce/apex/DynamicLWCDataTableController.getWrapperOfSObjectFieldColumnActionValues';
import { refreshApex } from '@salesforce/apex';
import formFactorPropertyName from "@salesforce/client/formFactor";
export default class DynamicDatatable extends LightningElement {
    @track columnConfig;
    @track tableData;
    @track desktopBoolean = false;
    @track phoneBolean = false;
    @track wiredData = {};
    @track _paramsData;
    @track formFactor = formFactorPropertyName;

    @track showModalForFilePre;
    @track hasDocumentId;
    enableInfiniteScrolling = true;
    enableBatchLoading = true;
    @track documentDetailId;
    @track showModalForFilePre;
    @track hasDocumentId;
    // @api get paramsData() {
    //     return this._paramsData;
    // }
    // set paramsData(value) {
    //     this._paramsData = value;
    //     this.setAttribute("paramsData", value);

    // }

    @api paramsData;

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

    connectedCallback() {
        console.log('this.paramsData', this.paramsData);
        // refreshApex(this.wiredData);

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
        this.handleGettingData();
    }


    @api handleGettingData() {
        // this.columnConfig = {};
        // this.tableData;
        getDynamicTableDataList({ params: this.paramsData })
            .then((result) => {
                // console.log('result from dynamic Datatabele is ', JSON.stringify(result));
                // console.log('data for table is', JSON.stringify(result.));
                let sObjectRelatedFieldListValues = [];
                for (let row of result.lstDataTableData) {
                    const finalSobjectRow = {}
                    let rowIndexes = Object.keys(row);
                    rowIndexes.forEach((rowIndex) => {
                        const relatedFieldValue = row[rowIndex];
                        if (relatedFieldValue.constructor === Object) {
                            this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndex)
                        }
                        else {
                            finalSobjectRow[rowIndex] = relatedFieldValue;
                        }

                    });
                    sObjectRelatedFieldListValues.push(finalSobjectRow);
                }
                this.columnConfig = result;
                // this.columnConfig.tableTitle = 'Datatable Response Data';
                this.tableData = sObjectRelatedFieldListValues;

                console.log('sObjectRelatedFieldListValues is', JSON.stringify(sObjectRelatedFieldListValues));
                console.log('columnConfig is', JSON.stringify(this.columnConfig));
            })
            .catch((error) => {
                console.log("error occured in upsert", error);
                console.log("upsertDataMethod");
            });
    }

    _flattenTransformation = (fieldValue, finalSobjectRow, fieldName) => {
        let rowIndexes = Object.keys(fieldValue);
        rowIndexes.forEach((key) => {
            let finalKey = fieldName + '.' + key;
            finalSobjectRow[finalKey] = fieldValue[key];
        })
    }

    // renderedCallback() {
    //     refreshApex(this.wiredData);
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
        //console.log("mousemove._tableThColumn => ", this._tableThColumn);
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

    handleCloseModalEvent(event) {
        this.showModalForFilePre = false;
    }
    handleDocumentView(event) {
        console.log(event.detail);

        //console.log("id is ==> " + event.currentTarget.dataset.documentid);
        this.documentDetailId = event.detail;
        this.hasDocumentId = true;
        this.showModalForFilePre = true;

        
    }
}