import { LightningElement,api, track } from 'lwc';

export default class ObligationsClosedLoan extends LightningElement {
    
    @api qdeStageVisible;
    @api allRecOfClosedApplObwithDetai;
    @api totalLoanAmountClosedLoan;
    @api totalCurrentOsClosedLoan;
    @api totalEmiClosedLoan;
    @api totalContinueObliClosedLoan;

   
    connectedCallback(){
        console.log('totalLoanAmountClosedLoan ==',this.totalLoanAmountClosedLoan)
    }

    get LoanAmountClosedLoan(){
        return this.totalLoanAmountClosedLoan
    }

    
    set LoanAmountClosedLoan(value) {
        this.setAttribute("LoanAmountClosedLoan", value);
    }

    // handlemousemove(e) {
    //     console.log('called event handlemousemove')
    //     if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
    //         this._diffX = e.pageX - this._pageX;

    //         this.template.querySelector("table").style.width = (this.template.querySelector("table") - (this._diffX)) + 'px';

    //         this._tableThColumn.style.width = (this._tableThWidth + this._diffX) + 'px';
    //         this._tableThInnerDiv.style.width = this._tableThColumn.style.width;

    //         let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
    //         let tableBodyRows = this.template.querySelectorAll("table tbody tr");
    //         let tableBodyTds = this.template.querySelectorAll("table tbody .dv-dynamic-width");
    //         tableBodyRows.forEach(row => {
    //             let rowTds = row.querySelectorAll(".dv-dynamic-width");
    //             rowTds.forEach((td, ind) => {
    //                 rowTds[ind].style.width = tableThs[ind].style.width;
    //             });
    //         });
    //     }
    // }
	
	// handledblclickresizable() {
    //     let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
    //     let tableBodyRows = this.template.querySelectorAll("table tbody tr");
    //     tableThs.forEach((th, ind) => {
    //         th.style.width = this._initWidths[ind];
    //         th.querySelector(".slds-cell-fixed").style.width = this._initWidths[ind];
    //     });
    //     tableBodyRows.forEach(row => {
    //         let rowTds = row.querySelectorAll(".dv-dynamic-width");
    //         rowTds.forEach((td, ind) => {
    //             rowTds[ind].style.width = this._initWidths[ind];
    //         });
    //     });
    // }
	
	// handlemousedown(e) {
    //     if (!this._initWidths) {
    //         this._initWidths = [];
    //         let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
    //         tableThs.forEach(th => {
    //             this._initWidths.push(th.style.width);
    //         });
    //     }

    //     this._tableThColumn = e.target.parentElement;
    //     this._tableThInnerDiv = e.target.parentElement;
    //     while (this._tableThColumn.tagName !== "TH") {
    //         this._tableThColumn = this._tableThColumn.parentNode;
    //     }
    //     while (!this._tableThInnerDiv.className.includes("slds-cell-fixed")) {
    //         this._tableThInnerDiv = this._tableThInnerDiv.parentNode;
    //     }
    //     this._pageX = e.pageX;

    //     this._padding = this.paddingDiff(this._tableThColumn);

    //     this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
    // }
	
	//  handlemouseup(e) {
    //     this._tableThColumn = undefined;
    //     this._tableThInnerDiv = undefined;
    //     this._pageX = undefined;
    //     this._tableThWidth = undefined;
    // }
	
	
    // tableOuterDivScrolled(event) {
    //     this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
    //     if (this._tableViewInnerDiv) {
    //         if (!this._tableViewInnerDivOffsetWidth || this._tableViewInnerDivOffsetWidth === 0) {
    //             this._tableViewInnerDivOffsetWidth = this._tableViewInnerDiv.offsetWidth;
    //         }
    //         this._tableViewInnerDiv.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth) + "px;" + this.tableBodyStyle;
    //     }

    //     this.tableScrolled(event);



    // }

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