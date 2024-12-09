import { LightningElement,track,api } from 'lwc';
import getAllSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords'
import getContentDocumentId from "@salesforce/apex/CaseFilePreviewController.getContentDocumentId";
import getUiTheme from "@salesforce/apex/UiThemeController.getUiTheme";
import formFactorPropertyName from "@salesforce/client/formFactor";
export default class CaseDocumentDisplay extends LightningElement {
 
@api recordId;
@track modeDis = true;
@track lstAllFiles= [];
@track themeType
@track formFactor = formFactorPropertyName;
 desktopBoolean = false;
 phoneBolean = false;
 showModalForFilePre;
 url;
 contDocId;
 cvId;
 showModalForFilePre;
 contDocType
 imageTypeFileUrl

connectedCallback(){
 getUiTheme()
    .then((result) => {
        console.log('result for theme is=>>>>>', result);
        this.themeType = result;
    })
    .catch((error) => {

    });

console.log("Form Factor Property Name ", this.formFactor);
console.log("formFactorPropertyName ", formFactorPropertyName);
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
 this.getCaseFile();
}

getCaseFile(){
console.log('recordId:',this.recordId);
let documentDetailIds = [];
let parameter = {
    ParentObjectName: 'CaseDoc__c',
    ChildObjectRelName: null,
    parentObjFields: ['Id','Case__c','DocDetail__c'],
    childObjFields: [],
    queryCriteria: ' where Case__c = \'' + this.recordId + '\''
  }
  getAllSobjectDatawithRelatedRecords({ params: parameter })
  .then(result => {
      console.log('Result:'+JSON.stringify(result));
      result.forEach(row => {
        if(row.parentRecord.DocDetail__c != undefined){
            documentDetailIds.push(row.parentRecord.DocDetail__c);
        }
       });
       console.log('documentDetailId:',documentDetailIds);
       this.getcontentversionList(documentDetailIds);
      })
  .catch(error => {
    console.log(error);
  });
}
//category: this.category, docType: this.type, subType: this.subType
getcontentversionList(documentDetailIds){
    getContentDocumentId({  documentDetailId: documentDetailIds })
    .then(result => {
        console.log('case file Preview controller wrapper class:'+JSON.stringify(result));
        this.lstAllFiles = result;
    })
    .catch(error => {
      console.log(error);
    });
}

handleDocumentView(event){
    this.contDocId = event.currentTarget.dataset.id;
    this.contDocType = event.currentTarget.dataset.type;
    this.cvId = event.currentTarget.dataset.cvId;
    this.showModalForFilePre = true;
    this.url = '/sfc/servlet.shepherd/document/download/' + this.contDocId;
    console.log('this.url' + this.url);
}

handleCloseModalEvent(event) {
    this.showModalForFilePre = false;
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


    handlemouseup(e) {
        this._tableThColumn = undefined;
        this._tableThInnerDiv = undefined;
        this._pageX = undefined;
        this._tableThWidth = undefined;
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