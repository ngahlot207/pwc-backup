import { LightningElement, track, api } from 'lwc';

//apex methods
import formFactorPropertyName from "@salesforce/client/formFactor";

export default class EnpaVerification extends LightningElement {
    @api enpaData = [];
    @api internalTopUpOptions = [];
    @api pddPendingOptions = [];
    @api loanLTVOptions = [];
    @api loanProposedLanOptions = [];
    @api isReadOnly = false;
    @track req = true;
    @api loantobeClosedInternally = []
    @track formFactor = formFactorPropertyName;
    @track desktopBoolean = false;
    @track phoneBolean = false;
    @track showEnpaData = false;
    @track enpaData = [];
    enableInfiniteScrolling = true;
    enableBatchLoading = true;

    connectedCallback() {

        console.log('formFactor is ', this.formFactor);
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
        //this.callEnpaMethod();
    }

    handleEnpaChange(event) {
        let val = event.target.value;
        let deduperRecordId = event.target.dataset.recordid;
        let nameVal = event.target.name;
        console.log('val is in enpa ', val, 'deduperRecordId is ', deduperRecordId, ' name is ', nameVal);
        let obj = this.enpaData.find(item => item.Id === deduperRecordId);
        if (obj) {
            console.log('obj is ', JSON.stringify(obj));
            obj[nameVal] = val;
            console.log('this.dedupeData ', JSON.stringify(this.dedupeData));
            this.callEnpaMethod();
        }
    }

    handlePicklistValues(event) {
        let val = event.detail.val;
        let deduperRecordId = event.detail.recordid;
        let nameVal = event.detail.nameVal;
        console.log('val is in enpaVerification ', val, 'enpaRecordId is ', deduperRecordId, ' name is ', nameVal);
        let selectEvent = new CustomEvent('enpadatachange', {
            detail: { recordid: deduperRecordId, val: val, nameVal: nameVal }
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
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
    @api validateForm() {
        let isValid = true
        this.template.querySelectorAll('c-hunter-displayvalue').forEach(element => {
            if (element.reportValidity()) {
                console.log('c-hunter-displayvalue');
                console.log('element if--' + element.value);
            } else {
                isValid = false;
                // element.setCustomValidity("Received Date can not be future date");
                console.log('element else--' + element.value);
            }
            // element.reportValidity("");
        });
        return isValid
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