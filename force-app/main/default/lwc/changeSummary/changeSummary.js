import { LightningElement, api, track, wire } from 'lwc';

//Apex Methods
import getRetriggerData from '@salesforce/apex/ChangeSummaryHandler.getRetriggerData';
import updateUwReviewedStatus from '@salesforce/apex/ChangeSummaryHandler.updateUwReviewedStatus';
import { formattedDateTimeWithoutSeconds } from 'c/dateUtility';
import formFactorPropertyName from "@salesforce/client/formFactor";
import Id from '@salesforce/user/Id';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';

export default class ChangeSummary extends LightningElement {

    @api loanAppId = 'a08C4000008PgU6IAK';
    //@api loanAppId;
    @api hasEditAccess;

    @track formFactor = formFactorPropertyName;
    @track desktopBoolean = false;
    @track phoneBolean = false;
    enableInfiniteScrolling = true;
    enableBatchLoading = true;
    @track changeSummaryData = [];

    @track isSelectAllChecked = false;
    
    // Handle the "Select All" checkbox change
    handleSelectAll(event) {
        const isChecked = event.target.checked;
        this.isSelectAllChecked = isChecked;

        // Update all rows based on "Select All" checkbox state
        this.changeSummaryData = this.changeSummaryData.map(record => {
            record.uwReviewed = isChecked; // Set each row's checkbox to match "Select All"
            return record;
        });

        // Loop through each row and call updateUwReviewedStatus individually
        this.changeSummaryData.forEach(record => {
            const retriggerUpsertAuditId = record.retriggerUpsertAuditId;
            this.updateSingleUwReviewedStatus(retriggerUpsertAuditId, this.loanAppId, isChecked);
        });

        console.log('All checkboxes updated:', this.isSelectAllChecked);
    }

    updateSingleUwReviewedStatus(retriggerUpsertAuditId, loanAppId, isChecked) {
        updateUwReviewedStatus({ retriggerUpsertAuditId, loanAppId, uwReviewed: isChecked })
            .then(() => {
                console.log('UW Reviewed status updated successfully for:', retriggerUpsertAuditId);
            })
            .catch((error) => {
                console.error('Error updating UW Reviewed status', error);
            });
    }

    
    handleUwReviewedChange(event) {
        const retriggerUpsertAuditId = event.target.dataset.auditId; // Assuming you've added a data-audit-id attribute
        const loanAppId = this.loanAppId; // Already available
        const isChecked = event.target.checked;
        console.log('r###retrigger id '+retriggerUpsertAuditId);
        console.log('checked '+isChecked);

    
        // Call Apex method to update UW Reviewed status
        updateUwReviewedStatus({ retriggerUpsertAuditId, loanAppId, uwReviewed: isChecked })
            .then(() => {
                // Handle success, like showing a toast message
                console.log('UW Reviewed status updated successfully');
            })
            .catch((error) => {
                // Handle error, like showing an error message
                console.error('Error updating UW Reviewed status', error);
            });
    }


    @track userId = Id;
    employeee;
    @track isDisabled = true;
    getUserRole() {
        let paramsLoanApp = {
            ParentObjectName: 'TeamHierarchy__c',
            parentObjFields: ['Id', 'EmpRole__c', 'Employee__c'],
            queryCriteria: ' where Employee__c = \'' + this.userId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('result is get Role ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.employeeRole = result.parentRecords[0].EmpRole__c;
                    this.employeee = result.parentRecords[0].Employee__c;
                    console.log('this.employeeRole is ', this.employeeRole);
                    console.log('this.user id is ',this.userId);
                    if (this.employeeRole == 'UW' || this.employeeRole == 'ACM' || this.employeeRole == 'RCM' || this.employeeRole == 'ZCM' || this.employeeRole == 'NCM' || this.employeeRole == 'CH') {
                        this.isDisabled = false;
                    }
                    
                }
            })
            .catch((error) => {

                //this.showSpinner = false;
                console.log("error occured in employeeRole", error);

            });
    }

    @track loanProductType;
    @track blPlView = false;

    getProductType() {
        let parameterLoanApplication = {
            ParentObjectName: 'LoanAppl__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'Product__c'],
            childObjFields: [],
            queryCriteria: ' where Id = \'' + this.loanAppId + '\''
        }

        getSobjectData({ params: parameterLoanApplication })
        .then((result) => {
            console.log('Loan Application Data of product:', JSON.stringify(result));

            if (result && result.parentRecords && result.parentRecords.length > 0) {
                let loanRecord = result.parentRecords[0]; // Get the first loan application record
                this.loanProductType = loanRecord.Product__c; // Store the Product__c value
                console.log('Product Type:', this.loanProductType);
                if(this.loanProductType == 'Business Loan' || this.loanProductType == 'Personal Loan'){
                    this.blPlView = true;
                }
            }

            if (result.error) {
                console.error('Error fetching Loan Application data:', result.error);
            }
        })
        .catch((error) => {
            console.error('Error fetching data:', error);
        });

        
    }



    



    //////////

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

        this.getChangeSummaryData();
        this.getUserRole();
        this.getProductType();


    }

    getChangeSummaryData() {
        getRetriggerData({ loanAppId: this.loanAppId })
            .then((result) => {
                console.log('Change Summary data', JSON.stringify(result));

                result.forEach(row1 => {
                const dateTime1 = new Date(row1.timeStamp);
                const formattedDate1 = formattedDateTimeWithoutSeconds(dateTime1); 
                const timeStampVal1 = `${formattedDate1}`;
                row1.timeStamp = timeStampVal1;

                

                });


                this.changeSummaryData = JSON.parse(JSON.stringify(result));
                //////
                // Initialize the checkbox state
            // this.changeSummaryData.forEach(record => {
            //     record.uwReviewed = false; // Initialize the checkbox to unchecked
            // });
            ////////
                console.log('changeSummaryData', this.changeSummaryData);
            })
            .catch((error) => {
                console.log('Error In getting payment data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
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