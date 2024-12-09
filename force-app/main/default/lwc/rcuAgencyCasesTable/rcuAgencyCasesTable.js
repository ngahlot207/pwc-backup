import { LightningElement,track, wire, api } from 'lwc';
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { createRecord,updateRecord} from "lightning/uiRecordApi";

import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import upsertMultipleRecord from "@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord";

import COMMENTS_OBJECT from "@salesforce/schema/Comments__c";

import CASE_COMMENTS_FIELD from "@salesforce/schema/Comments__c.Case__c";
import REVIEW_COMMENT_FIELD from "@salesforce/schema/Comments__c.ReviewerComments__c";
import USER_FIELD from "@salesforce/schema/Comments__c.User__c";

import Id from "@salesforce/user/Id";
import { formattedDateTimeWithoutSeconds } from 'c/dateUtility';

export default class RcuAgencyCasesTable extends LightningElement {

@track _caseId;
@api get caseId() {
    return this._caseId;
}
set caseId(value) {
    this._caseId = value;
    this.setAttribute("loanAppId", value);
    this.handleCaseIdChange();
   
}
@track docId;
    @track agencyCases=[];
    @track caseData=[];
    @track reviewRemarks;
    @track wireData=[];

@track showSpinner=false;
connectedCallback(){
    console.log('getAgencyCaseData::::in agency case table',this.caseId);
}

    handleCaseIdChange() {
        let recordType='RCU';
        let tempParams = this.paramsCase;
        tempParams.queryCriteria = ' where Case__c =\'' +this._caseId+'\' AND RecordType.DeveloperName = \''+recordType+ '\' order by createdDate asc' ;
        this.paramsCase = { ...tempParams };

    }
    @track paramsCase = {
        ParentObjectName: 'Case',
        ChildObjectRelName: '',
        parentObjFields:[
                    "Id","CaseNumber","AccountId","ContactId","ClosedDate","ReportResult__c","Account.Name",
                    "Contact.Name","Status","Remarks_for_Technical_Agency__c","Reason_for_cancelation__c",
                    "Loan_Application__c","Applicant__c","IsReinitiated__c",'DateTimeInitiation__c',
                    'Date_Time_of_Submission__c','ReviewerComments__c','ExpiryDate__c','IsReinitiatedExpired__c',
                    'TAT__c','HubManagerReview__c','OwnerId','Owner.Name','Final_RCU_status_Reason__c',
                    'Remarks_regarding_the_case__c','AgcRCUReportStatus__c'
            
                  ],
        childObjFields: [],
        queryCriteria: ''
        }

    @wire(getSobjectData,{params : '$paramsCase'})
    caseRecordHandler(result){
      console.log('caseRecordHandler::::',result);
      this.wireData=result;
        if(result.data){
            this.agencyCases = [];
            console.log('DATA IN CASE DETAILS :::: #83>>>>',result.data);
            if(result.data.parentRecords !== undefined ){
               let tempArr = result.data.parentRecords;
                let obj={};
                if(tempArr && tempArr.length>0){
                    tempArr.forEach(item => {
                      // if(item.Status === 'Closed' || item.Status === 'Review Requested'){
                      //   item.isReviewDis = true;
                      // }
                              const dateTime2 = new Date(item.DateTimeInitiation__c);
                                const formattedDate2 = formattedDateTimeWithoutSeconds(dateTime2); 
                                const dateOfIntiation2 = `${formattedDate2}`;
                                obj={...item,'initiationDate':dateOfIntiation2,
                                  isReviewDis :  item.Status === 'Closed' || item.Status === 'Review Requested' ? true : false}
                                this.agencyCases.push(obj)
                              });
                          }
                          console.log('agencyCases IN CASE DETAILS :::: #70>>>>',this.agencyCases);
                          this.showSpinner=false;
            }
                      
        }
        if(result.error){
            this.showSpinner=false;
            console.error('ERROR CASE DETAILS:::::::#420',result.error)
        }
    }


    @track caseRecId;
    @track showReport=false;
    @track reviewModalOpen=false;
    handleDocumentView(event) {
      let caseid = event.currentTarget.dataset.caseid
      this.caseRecId = caseid
         console.log("this.caseRecId ==> " + this.caseRecId);
         this.getDocDetailId(this.caseRecId)
       
         setTimeout(() => {
          this.showReport = true; // Show document preview
          this.showSpinner = false; // Hide spinner after a short delay
      }, 1000);    
    

 }
 handleReviewModalYesClick(){
  let isInputCorrect = this.validateForm();

  if (isInputCorrect === true) {
  this.showSpinner = true;
  this.createComment();
  this.reviewModalOpen=false;
  this.showSpinner = false;
  } else {
    this.showSpinner = false;
   
  }
 
}
handleInputChange(event){
this.reviewRemarks = event.target.value.toUpperCase();
}

createComment(){
  const fields = {};
  fields[REVIEW_COMMENT_FIELD.fieldApiName] = this.reviewRemarks;
  fields[CASE_COMMENTS_FIELD.fieldApiName] = this.caseRecordId;
  fields[USER_FIELD.fieldApiName] = Id;

  const recordInput = { apiName: COMMENTS_OBJECT.objectApiName, fields };
  console.log("fields::::: #740", fields);
  createRecord(recordInput)
          .then((result) => {
          let oldFields={};
          oldFields.sobjectType = "Case";
          oldFields.Id = this.caseRecordId;
          oldFields.Status = 'Review Requested';
          oldFields.ReviewerComments__c = this.reviewRemarks;
          this.upsertDataMethod(oldFields);
          this.showToastMessage('Success', 'Review Requested Successfully', 'success', 'sticky');
           
          })
          .catch((error) => {
            console.log("CASE COMMENTS RESULT ERRO:::::1011", error);
           
          });
  
}
@track textAreaValue;
upsertDataMethod(obje) {
  let newArray = [];
  if (obje) {
    newArray.push(obje);
  }
  if (newArray) {
    console.log("new array is in RCU Manager ", newArray);
    upsertMultipleRecord({ params: newArray })
      .then((result) => {
        console.log('REUSLT IN RCU Manager #158', JSON.stringify(result));
        
        // if (this.yesLabel === "Re-Iniate") {
        
        //   this.showToastMessage('Success', this.label.Technical_ReInitiate_SuccessMessage, 'success', 'sticky');
        // } 
        //else
         if(this.yesLabel==='Review'){
    
          this.showToastMessage('Success', 'Case Status Updated Succssfully', 'success', 'sticky');
        }
        // else if(this.yesLabel==='Cancel') {
        //   this.yesLabel='';
   
        //   this.showToastMessage('Success', this.label.Technical_Cancel_SuccessMessage, 'success', 'sticky');
        // }else{
        //  // this.showToastMessage('Success', 'Applicant Asset updated successfully', 'success', 'sticky');
        // }

        this.textAreaValue = "";
        refreshApex(wireData);
        this.showSpinner = false;
      })
      .catch((error) => {
        this.showSpinner = false;
        console.log("error occured in upsert in RCU Manager 183", error);
      });
  }
}
 getDocDetailId(caseid){;
  let docCat ='Case Documents'
  let docType='RCU Verification'
  let docParams = {
    ParentObjectName: "DocDtl__c",
    ChildObjectRelName: "",
    parentObjFields: ["Id", "Case__c", "DocCatgry__c","DocTyp__c"
],
    childObjFields: [],
    queryCriteria: ' where Case__c = \''+ caseid + '\' AND DocCatgry__c =\''+ docCat +'\' AND DocTyp__c =\''+ docType +'\' order by createdDate DESC'
  };
  getSobjectDataNonCacheable({params: docParams}).then((result) => {
    
    console.log('result:::::::107',result);
    if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
      console.log("Doc dtl id 109 ==> ", result.parentRecords);
      this.docId = result.parentRecords[0].Id;
      
    }
  })
  .catch((error) => {
    console.log("RCU AGENCIES VENDOR PORTAL ERROR #766", error);
  });
 }

 @track hasDocId=true;
  handleCloseModalEvent() {
       this.showReport = false;
       this.docId='';

   }

   closeModal() {
    this.reviewModalOpen=false;

  }
  @track caseRecordId;
    handlebutton(event){
      let dataValue= event.target.label;
      if (dataValue === "Review") {
        this.caseRecordId = event.target.dataset.caseid;
        console.log("caseRecordId ", this.caseRecordId);
        this.reviewRemarks='';
        this.noLabel = "No";
        this.yesLabel='Review';
        this.reviewSubmitLabel = "Yes";
        this.dataName = "review";
      
        //this.textAreaLabel = "Review";
      //  this.getcaseObjDetails(this.caseRecordId);
        this.reviewModalOpen = true;
      }
    }

    validateForm() {
      let isValid = true;
  
      this.template.querySelectorAll("lightning-combobox").forEach((element) => {
        if (element.reportValidity()) {
          //console.log('element passed combobox');
          //console.log('element if--'+element.value);
        } else {
          isValid = false;
          //console.log('element else--'+element.value);
        }
      });
  
      this.template.querySelectorAll("lightning-input").forEach((element) => {
        if (element.reportValidity()) {
          //console.log('element passed lightning input');
        } else {
          isValid = false;
        }
      });
  
        this.template.querySelectorAll("lightning-textarea").forEach((element) => {
          if (element.reportValidity()) {
            //console.log('element passed lightning input');
          } else {
            isValid = false;
            this.showToastMessage('Error', 'Please fill the required fields', 'error', 'sticky');
          }
        });
        return isValid;
      
     
    }
  
    showToastMessage(title, message, variant, mode) {
      const evt = new ShowToastEvent({
          title,
          message,
          variant,
          mode
      });
      this.dispatchEvent(evt);
    }

     //******************FOR HANDLING THE HORIZONTAL SCROLL OF TABLE MANUALLY******************//
    tableOuterDivScrolled(event) {
      this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
      if (this._tableViewInnerDiv) {
        if (
          !this._tableViewInnerDivOffsetWidth ||
          this._tableViewInnerDivOffsetWidth === 0
        ) {
          this._tableViewInnerDivOffsetWidth =
            this._tableViewInnerDiv.offsetWidth;
        }
        this._tableViewInnerDiv.style =
          "width:" +
          (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth) +
          "px;" +
          this.tableBodyStyle;
      }
      this.tableScrolled1(event);
    }
  
    tableScrolled1(event) {
      if (this.enableInfiniteScrolling) {
        if (
          event.target.scrollTop + event.target.offsetHeight >=
          event.target.scrollHeight
        ) {
          this.dispatchEvent(
            new CustomEvent("showmorerecords", {
              bubbles: true
            })
          );
        }
      }
      if (this.enableBatchLoading) {
        if (
          event.target.scrollTop + event.target.offsetHeight >=
          event.target.scrollHeight
        ) {
          this.dispatchEvent(
            new CustomEvent("shownextbatch", {
              bubbles: true
            })
          );
        }
      }
    }

  //******************************* RESIZABLE COLUMNS FOR CASE TABLE *************************************//
  handlemouseup1(e) {
    this._tableThColumn = undefined;
    this._tableThInnerDiv = undefined;
    this._pageX = undefined;
    this._tableThWidth = undefined;
  }

  handlemousedown1(e) {
    if (!this._initWidths) {
      this._initWidths = [];
      let tableThs = this.template.querySelectorAll(
        "table thead .dv-dynamic-width"
      );
      tableThs.forEach((th) => {
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
    // console.log(
    //   "handlemousedown._tableThColumn.tagName => ",
    //   this._tableThColumn.tagName
    // );
    this._pageX = e.pageX;

    this._padding = this.paddingDiff(this._tableThColumn);

    this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
    console.log(
      "handlemousedown._tableThColumn.tagName => ",
      this._tableThColumn.tagName
    );
  }

  handlemousemove1(e) {
   // console.log("mousemove._tableThColumn => ", this._tableThColumn);
    if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
      this._diffX = e.pageX - this._pageX;

      this.template.querySelector("table").style.width =
        this.template.querySelector("table") - this._diffX + "px";

      this._tableThColumn.style.width = this._tableThWidth + this._diffX + "px";
      this._tableThInnerDiv.style.width = this._tableThColumn.style.width;

      let tableThs = this.template.querySelectorAll(
        "table thead .dv-dynamic-width"
      );
      let tableBodyRows = this.template.querySelectorAll("table tbody tr");
      let tableBodyTds = this.template.querySelectorAll(
        "table tbody .dv-dynamic-width"
      );
      tableBodyRows.forEach((row) => {
        let rowTds = row.querySelectorAll(".dv-dynamic-width");
        rowTds.forEach((td, ind) => {
          rowTds[ind].style.width = tableThs[ind].style.width;
        });
      });
    }
  }

  handledblclickresizable1() {
    let tableThs = this.template.querySelectorAll(
      "table thead .dv-dynamic-width"
    );
    let tableBodyRows = this.template.querySelectorAll("table tbody tr");
    tableThs.forEach((th, ind) => {
      th.style.width = this._initWidths[ind];
      th.querySelector(".slds-cell-fixed").style.width = this._initWidths[ind];
    });
    tableBodyRows.forEach((row) => {
      let rowTds = row.querySelectorAll(".dv-dynamic-width");
      rowTds.forEach((td, ind) => {
        rowTds[ind].style.width = this._initWidths[ind];
      });
    });
  }
  paddingDiff(col) {
    if (this.getStyleVal(col, "box-sizing") === "border-box") {
      return 0;
    }

    this._padLeft = this.getStyleVal(col, "padding-left");
    this._padRight = this.getStyleVal(col, "padding-right");
    return parseInt(this._padLeft, 10) + parseInt(this._padRight, 10);
  }

  getStyleVal(elm, css) {
    return window.getComputedStyle(elm, null).getPropertyValue(css);
  }

}