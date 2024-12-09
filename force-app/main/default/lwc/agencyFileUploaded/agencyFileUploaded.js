import { LightningElement,track,api } from 'lwc';
import getUiTheme from "@salesforce/apex/UiThemeController.getUiTheme";
import formFactorPropertyName from "@salesforce/client/formFactor";
import fetchId from "@salesforce/apex/FileUploadController.fetchId";
import deleteDocDet from "@salesforce/apex/FileUploadController.deleteDocDetail";
import deleteDocRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import getSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords'
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAllSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords'
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds'
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";

export default class AgencyFileUploaded extends LightningElement {

@api recordId;
@track modeDis = true;
@track lstAllFiles= [];
@track themeType
@track formFactor = formFactorPropertyName;
@api subType = [];
@track category = [];
@track docIdToDelete;
@track cdlIdToDelete;
@track isModalOpen;
@track removeModalMessage = "Do you want to delete the document ?";
@api disabled;
@track  type = [];
@track hasDocumentId;
@track statusFlag;
@track cdToDelete;
@track ContentVersionIdList = [];
 desktopBoolean = false;
 phoneBolean = false;
 showModalForFilePre;
 url;
 contDocId;
 cvId;
 showModalForFilePre;
 contDocType;
 imageTypeFileUrl;
 documentDetailId;
 reportCount;
_cdToDelete;
_docIdToDelete;
_cdlIdToDelete;

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
this.initialize(this.recordId);
}

//Get Case record with record Type
initialize(caseId){
let parameter = {
    ParentObjectName: 'Case',
    ChildObjectRelName: null,
    parentObjFields: ['Id','RecordType.Name','Loan_Application__c','Applicant__c','Product_Type__c','Loan_Application__r.Applicant__c','ReportCount__c'],
    childObjFields: [],
    queryCriteria: ' where id = \'' + caseId + '\''
}

getSobjDataWIthRelatedChilds({ params: parameter })
.then(result => {
    if(result.parentRecord.Id !== undefined && result.parentRecord.RecordType.Name === 'CPVFI'){
        console.log('Case record Type Name :'+JSON.stringify(result.parentRecord.RecordType.Name));
        let documentType = [];
        this.reportCount = result.parentRecord.ReportCount__c;
        documentType.push('CPV Documents');
        this.getcontentversionList(documentType);
        console.log('documentType:',documentType);
    }
    else if(result.parentRecord.Id !== undefined && result.parentRecord.RecordType.Name === 'Technical'){
    console.log('Case record Type Name :'+JSON.stringify(result.parentRecord.RecordType.Name));
    let documentType = [];
    this.reportCount = result.parentRecord.ReportCount__c;
    documentType.push('Technical Verification Documents');
    this.getcontentversionList(documentType);
    console.log('documentType:',documentType);
    } else if(result.parentRecord.Id !== undefined && result.parentRecord.RecordType.Name === 'TSR'){
        console.log('Case record Type Name :'+JSON.stringify(result.parentRecord.RecordType.Name));
        let documentType = [];
        this.reportCount = result.parentRecord.ReportCount__c;
        documentType.push('TSR Verification');
        this.getcontentversionList(documentType);
        console.log('documentType:',documentType);
    } else if(result.parentRecord.Id !== undefined && result.parentRecord.RecordType.Name === 'Vetting'){
        console.log('Case record Type Name :'+JSON.stringify(result.parentRecord.RecordType.Name));
        let documentType = [];
        this.reportCount = result.parentRecord.ReportCount__c;
        documentType.push('Vetting Verification');
        this.getcontentversionList(documentType);
        console.log('documentType:',documentType);
    } else if(result.parentRecord.Id !== undefined && result.parentRecord.RecordType.Name === 'Legal'){
        console.log('Case record Type Name :'+JSON.stringify(result.parentRecord.RecordType.Name));
        let documentType = [];
        this.reportCount = result.parentRecord.ReportCount__c;
        documentType.push('Legal Verification');
        this.getcontentversionList(documentType);
        console.log('documentType:',documentType);
    }
    else if(result.parentRecord.Id !== undefined && result.parentRecord.RecordType.Name === 'LIP Vendor case'){
        console.log('Case record Type Name :'+JSON.stringify(result.parentRecord.RecordType.Name));
        let documentType = [];
        this.reportCount = result.parentRecord.ReportCount__c;
        documentType.push('LIP Documents');
        this.getcontentversionList(documentType);
        console.log('documentType:',documentType);
    }
    
})
.catch(error => {
    console.log('INTLIZE error : ',JSON.stringify(error));
});
}


//Get Case Realted document detail record and content version List
getcontentversionList(documentType){
    console.log('documentType in content version:',documentType)
        this.type = documentType;
        this.category = ['Case Documents'];
    fetchId({ applicantId: this.recordId, category: this.category, docType: this.type, subType: this.subType})
    .then(result => {
        console.log('Result of new class:'+JSON.stringify(result));
        this.lstAllFiles = result;
    })
    .catch(error => {
        console.log(error);
    });
}

//File Preview
handleDocumentView(event){
    this.documentDetailId = event.currentTarget.dataset.documentid;
    console.log('this.documentDetailId:'+this.documentDetailId);
    this.contDocId = event.currentTarget.dataset.id;
    this.contDocType = event.currentTarget.dataset.type;
    this.cvId = event.currentTarget.dataset.cvId;
    this.showModalForFilePre = true;
    this.hasDocumentId = true;
    this.url = '/sfc/servlet.shepherd/document/download/' + this.contDocId;
    console.log('this.url' + this.url);
}

//Closed Model Popup After event dispatch event Value;
handleCloseModalEvent(event) {
    this.showModalForFilePre = false;
}
   
//Document delete method
    handleDocumentDelete(event) {
        this.cdToDelete = event.currentTarget.dataset.id;
        this.docIdToDelete = event.currentTarget.dataset.documentid;
        this.cdlIdToDelete = event.currentTarget.dataset.cdlid;

        let parameter = {
            ParentObjectName: 'Case',
            ChildObjectRelName: null,
            parentObjFields: ['Id','Status'],
            childObjFields: [],
            queryCriteria: ' where id = \'' + this.recordId + '\''
            }
           //Get NonCacheable data. If Case status is cloasd. User will not able to delete the document. without page refresh this will work
            getSobjectDataNonCacheable({params: parameter}).then((result) => {
                    console.log("Agency File Upload No cacheble record", JSON.stringify(result.parentRecords));
                    if (result.parentRecords !== undefined && result.parentRecords.length > 0 && result.parentRecords[0].Status != 'Closed') {
                    console.log('Not Closed Flag');
                    console.log('cdToDelete:'+this.cdToDelete);
                    console.log('docIdToDelete:'+this.docIdToDelete);
                    console.log('cdlIdToDelete:'+this.cdlIdToDelete);
                    this.handleDocumentDelete1( this.cdToDelete, this.docIdToDelete, this.cdlIdToDelete );
                    
                    }
                    else if(result.parentRecords[0].Status === 'Closed'){
                    console.log(' Closed Flag');
                    this.showToast("error", "error", "Case status is closed. You can't delete this report.");
                    }
                    }).catch((error) => {
                        console.log("Agency File Uploaded Error", JSON.stringify(error));
                      });
        
                    }


//Delete document Method
    handleDocumentDelete1(cdToDelete_, docIdToDelete_, cdlIdToDelete_){
        console.log('_cdToDelete:'+cdToDelete_)
        console.log('_docIdToDelete:'+docIdToDelete_)
        console.log('_cdlIdToDelete:'+cdlIdToDelete_)
        this.isModalOpen = true;
        let cdToDelete =cdToDelete_; // to delete individual file
        this._docIdToDelete = docIdToDelete_;
        this._cdlIdToDelete = cdlIdToDelete_;

        if(this._cdlIdToDelete != undefined){
            this.getContentcontentDocumentLink(this.docIdToDelete);
            }
    }

    closeModal() {
        console.log('isModalOpen ', this.isModalOpen);
        this.isModalOpen = false;
    }


   //Get document detail realted all content document link Id;
    getContentcontentDocumentLink(docDetailId){
        let contentDocLinkId = [];
        let parameter = {
            ParentObjectName: 'ContentDocumentLink',
            ChildObjectRelName: null,
            parentObjFields: ['Id'],
            childObjFields: [],
            queryCriteria: ' where LinkedEntityId = \'' + docDetailId + '\''
            }

            getAllSobjectDatawithRelatedRecords({ params: parameter })
            .then(result => {
            console.log('Content documentLink List:'+JSON.stringify(result));
            result.forEach(row => {
            if(row.parentRecord.Id != undefined){
                contentDocLinkId.push({Id: row.parentRecord.Id});
            }
        });

            this.ContentVersionIdList = contentDocLinkId;
            console.log('content documentLink versionId:',JSON.stringify(this.ContentVersionIdList));
            console.log('content documentLink length:',this.ContentVersionIdList.length);
    })
    .catch(error => {
    console.log('Error while content version:',JSON.stringify(error));
    });
}


// Delete the content document link record
        handleRemoveRecord() {
        console.log('cdlIdToDelete in popo yes', this.cdlIdToDelete);
        console.log('docIdToDelete in popo up yes ', this.docIdToDelete);
        console.log('content version list while deleting:'+JSON.stringify(this.ContentVersionIdList));
        this.showSpinnerChild = true;
        if (this.ContentVersionIdList.length > 0) {
            let recList = [];
            this.ContentVersionIdList.forEach(rowId => {
            let cldRecord = {};
            cldRecord['sobjectType'] = 'ContentDocumentLink';
            cldRecord['Id'] = rowId.Id;
            recList.push(cldRecord);
            });
            console.log('recList:',JSON.stringify(recList));
            deleteDocRecord({ rcrds: recList })
                .then((result) => {
                    this.deleteDocDet(this.docIdToDelete);
                    this.showSpinner = false;
                })
                .catch((error) => {
                    this.showSpinnerChild = false;
                    window.console.log(
                        "Unable to delete record due to " + error.body.message
                    );
                });
        } else {
            this.deleteDocDet(this.docIdToDelete);
            this.showSpinner = false;
        }

    }


//Delete document detail
    deleteDocDet(docIdToDelete) {
        console.log('docIdToDelete ', docIdToDelete)
        deleteDocDet({ docId: docIdToDelete })
            .then((result) => {
                console.log(result);
                this.showToast("Success", "success", "Document Deleted Successfully  ");
                this.getnonchacheablCaseRecord();
            })

            .catch((error) => {
                window.console.log(
                    "Unable to delete document detail record " + error.body.message
                );
                this.showSpinnerChild = false;
            });
                this.isModalOpen = false;
    }

    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }


//get nonchaable case record. due to maintain the report count.
    getnonchacheablCaseRecord(){
        let parameter = {
            ParentObjectName: 'Case',
            ChildObjectRelName: null,
            parentObjFields: ['Id','ReportCount__c','Status'],
            childObjFields: [],
            queryCriteria: ' where id = \'' + this.recordId + '\''
            }

            getSobjectDataNonCacheable({params: parameter}).then((result) => {
                    console.log("result TECHNICAL PROP DOCUMENT DETAILS #688>>>>>", JSON.stringify(result.parentRecords));
                    if (result.parentRecords !== undefined && result.parentRecords.length > 0 && result.parentRecords[0].ReportCount__c != undefined && result.parentRecords[0].Status != 'Closed') {
                    console.log('Inside if');
                    this.updatecaseRecord( result.parentRecords[0].ReportCount__c);
                    }
                  
                
                    })
        
                .catch((error) => {
                    console.log("Update case record error #696", error);
                });
        
        }

//Update case the report count on the case
        updatecaseRecord(reportCount){
        console.log('reportCount:'+reportCount);
        let upsertObjectParams = {
            parentRecord : {},
            ChildRecords : [],
            ParentFieldNameToUpdate : ''
            };
            
            console.log('report count 1:'+ this.reportCount);
            upsertObjectParams.parentRecord.sobjectType = 'Case';
            upsertObjectParams.parentRecord.Id = this.recordId;
        
            if(reportCount != undefined){
            upsertObjectParams.parentRecord.ReportCount__c = reportCount - 1;
            }
            else if(reportCount < 1){
                upsertObjectParams.parentRecord.ReportCount__c = 0;
            }
            
            console.log('report count OBJ:'+ upsertObjectParams.parentRecord.ReportCount__c);
            
            upsertSobjDataWIthRelatedChilds({upsertData:upsertObjectParams})
            .then((result) => {
                console.log('Updated Case report date :'+JSON.stringify(result));
                this.latestData();
            })
            .catch((error) => {
                this.error = error;
                console.log('Error while Update case record:',JSON.stringify(error));
            });

        }

//After delete record. Refresh the table.
    latestData(){
        return fetchId({ applicantId: this.recordId, category: this.category, docType: this.type, subType: this.subType})
            .then(result => {
                this.lstAllFiles = result;
            })
            .catch(error => {
            console.log(error);
            });
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

    @api handleValueSelect(event){
        let childEvt = event.detail;
        console.log('childEvt case agency report::::#440',childEvt );
        this.latestData();
    
    } 
    }



    /*handleRemoveRecord() {
        console.log('cdlIdToDelete in popo yes', this.cdlIdToDelete);
        console.log('docIdToDelete in popo up yes ', this.docIdToDelete);
        this.showSpinnerChild = true;
        if (this.cdlIdToDelete) {
            let recList = [];
            let cldRecord = {};
            cldRecord['Id'] = this.cdlIdToDelete;
            recList.push(cldRecord);

            deleteDocRecord({ rcrds: recList })
                // .then((result) => {
                .then((result) => {
                    this.deleteDocDet(this.docIdToDelete);
                    // this.lstAllFiles = [];
                    this.showSpinner = false;
                })
                .catch((error) => {
                    this.showSpinnerChild = false;
                    window.console.log(
                        "Unable to delete record due to " + error.body.message
                    );
                });
        } else {
            this.deleteDocDet(this.docIdToDelete);
            this.showSpinner = false;
        }

    }*/