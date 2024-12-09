import { LightningElement, api, track, wire } from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import Id from '@salesforce/user/Id';
export default class ApprovalTrayDataTable extends LightningElement {
    @track userId = Id;
    @api approvalTableData;
    @api disable = false;
    @api showDivTable = false;
    @api showDocTable = false;
    @api showDisDivTable = false;
    @api showSplitDisTable = false;
    @api tableTitle = 'Table Data';
    @track docApprovaActOptins;
    @track divApprovaActOptins;
    @track displayData = [];


    @wire(getObjectInfo, { objectApiName: 'DocDtl__c' })
    docObjectInfo;

    @wire(getPicklistValuesByRecordType, {
        objectApiName: 'DocDtl__c',
        recordTypeId: '$docObjectInfo.data.defaultRecordTypeId',
    })
    docAppActnsPicklistHandler({ data, error }) {
        if (data) {
            console.log('data in paymentPicklistHandler', JSON.stringify(data));
            this.docApprovaActOptins = [...this.generatePicklist(data.picklistFieldValues.Appr_Actn__c)];
            console.log('this.docApprovaActOptins::::==>>>', this.docApprovaActOptins);
        }
        if (error) {
            console.error('error im getting picklist values are', error)
        }
    }
    generatePicklist(data) {
        if (data.values) {
            return data.values.map(item => ({ label: item.label, value: item.value }))
        }
        return null;
    }

    @wire(getObjectInfo, { objectApiName: 'Deviation__c' })
    divObjectInfo;

    @wire(getPicklistValuesByRecordType, {
        objectApiName: 'Deviation__c',
        recordTypeId: '$divObjectInfo.data.defaultRecordTypeId',
    })
    divAppActnsPicklistHandler({ data, error }) {
        if (data) {
            console.log('data in paymentPicklistHandler', JSON.stringify(data));
            this.divApprovaActOptins = [...this.generatePicklist(data.picklistFieldValues.Appr_Actn__c)];
            console.log('this.divApprovaActOptins::::==>>>', this.divApprovaActOptins);
        }
        if (error) {
            console.error('error im getting picklist values are', error)
        }
    }

    connectedCallback() {
        if (this.showDocTable && this.approvalTableData) {
            let docIds = [];
            console.log('this.approvalTableData ::::>>>>', this.approvalTableData);
            this.approvalTableData.forEach(item => {
                docIds.push(item.Id);
            })
            this.getContentDoc(docIds);
        }
        console.log('showDivTable', this.showDivTable);
        console.log('showDocTable', this.showDocTable);
        console.log('showDisDivTable', this.showDisDivTable);
        console.log('approvalTableData', JSON.stringify(this.approvalTableData));
        if ((this.showDivTable || this.showDisDivTable || this.showSplitDisTable) && this.approvalTableData) {
            this.displayData = JSON.parse(JSON.stringify(this.approvalTableData));
            this.displayData = this.displayData.map((item, index) => {
                return { ...item, incrementedIndex: index + 1 };
            });
        }
    }

    handlePicklistValues(event) {
        console.log('event ', event.detail);
        console.log('this.displayData ', this.displayData);
        let currentIndex = event.detail.index;
        let obj = { ...this.displayData[event.detail.index] };
        
        obj[event.detail.nameVal] = event.detail.val;
        obj.isDirty = true;

        this.displayData = [...this.displayData];
        this.displayData[currentIndex] = obj;

        const selectedEvent = new CustomEvent("select", {
            detail: { recordid: event.detail.recordid, fieldname: event.detail.nameVal, val: event.detail.val }
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);
        console.log('this.displayData ', this.displayData);
    }
    handleChange(event) {
        console.log('event ', event.target.value);
        let val = event.target.value.toUpperCase();  // Convert the input value to uppercase
        let currentIndex = event.target.dataset.index;
        let obj = { ...this.displayData[event.target.dataset.index] };

        obj[event.target.dataset.name] = val;
        obj.isDirty = true;

        this.displayData = [...this.displayData];
        this.displayData[currentIndex] = obj;

        const selectedEvent = new CustomEvent("select", {
            detail: { recordid: event.target.dataset.recordid, fieldname: event.target.dataset.name, val: val }
        });
        // Dispatching the custom event
        this.dispatchEvent(selectedEvent);
        console.log('this.displayData ', this.displayData);
    }
    @track documentId;
    @track showfile = false;
    @track hasDocumentId = false;
    handleDocumentView(event) {
        this.documentId = event.target.dataset.recordid;
        this.showfile = true;
        this.hasDocumentId = true;
    }
    handleCloseModalEvent(event) {
        this.showfile = false;

    }

    @api reportValidity() {
        let isValid = true
        // this.template.querySelectorAll('c-hunter-displayvalue').forEach(element => {
        //     if (element.reportValidity()) {
        //         console.log('c-hunter-displayvalue');
        //         console.log('element if--' + element.value);
        //     } else {
        //         isValid = false;
        //         console.log('element else--' + element.value);
        //     }
        // });
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed lightning input');
                console.log('element if--', element.value);
            } else {
                isValid = false;
            }
        });
        this.template.querySelectorAll('lightning-textarea').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed lightning-textarea');
                console.log('element if--', element.value);
            } else {
                isValid = false;
            }
        });
        return isValid;
    }

    @api reportValidityOps() {
        let isValid = true
        this.template.querySelectorAll('c-approval-tray-display-value').forEach(element => {
            if (element.reportValidity()) {
                console.log('c-approval-tray-display-value');
                console.log('element if--' + element.value);
            } else {
                isValid = false;
                console.log('element else--' + element.value);
            }
        });
        return isValid;
    }
    getContentDoc(docIds) {
        let docrecords = [];
        docrecords = JSON.parse(JSON.stringify(this.approvalTableData));
        let linkEntiryIds = [];
        let params = {
            ParentObjectName: 'ContentDocumentLink',
            ChildObjectRelName: '',
            parentObjFields: ['ContentDocumentId', 'LinkedEntityId'],
            childObjFields: [],
            queryCriteria: ' where LinkedEntityId  IN (\'' + docIds.join('\', \'') + '\')'
        }
        getSobjectData({ params: params })
            .then((data) => {
                if (data.parentRecords) {
                    data.parentRecords.forEach(item => {
                        if (item.LinkedEntityId) {
                            linkEntiryIds.push(item.LinkedEntityId);
                        }
                    });
                    docIds.forEach(ite => {
                        if (linkEntiryIds && Array.from(linkEntiryIds).includes(ite)) {
                            let docRec = docrecords.find(item => item.Id === ite);
                            if (docRec) {
                                docRec.isDocAvailable = true;
                            }
                        } else {
                            let docRec = docrecords.find(item => item.Id === ite);
                            if (docRec) {
                                docRec.isDocAvailable = false;
                            }
                        }
                    })
                } else {
                    docrecords = docrecords.map(docRec => ({
                        ...docRec,
                        isDocAvailable: false
                    }));
                }
                this.displayData = [...docrecords];
                this.displayData = this.displayData.map((item, index) => {
                    return { ...item, incrementedIndex: index + 1 };
                });
                console.log('this.displayData ', this.displayData);
                // this.showSpinner = false;
            })
            .catch(error => {
                console.log('Errorured in docs preview:- ' + error);
                // this.showSpinner = false;
            });
    }
    enableInfiniteScrolling = true;
    enableBatchLoading = true;

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