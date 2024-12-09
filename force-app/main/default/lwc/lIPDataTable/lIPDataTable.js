import { LightningElement, api, track, wire } from "lwc";
import { createRecord} from "lightning/uiRecordApi";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import { formattedDateTimeWithoutSeconds } from 'c/dateUtility';
import CASE_OBJECT from "@salesforce/schema/Case";
import REASON_FOR_CANCEL from "@salesforce/schema/Case.Reason_for_cancelation__c";
import REASON_FOR_REINITIATE from "@salesforce/schema/Case.Reason_for_reinitiated_FI__c";

import COMMENTS_OBJECT from "@salesforce/schema/Comments__c";
import CASE_COMMENTS_FIELD from "@salesforce/schema/Comments__c.Case__c";
import REVIEW_COMMENT_FIELD from "@salesforce/schema/Comments__c.ReviewerComments__c";
import USER_FIELD from "@salesforce/schema/Comments__c.User__c";

//Apex Methods
import getSobjectData from "@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType";
import upsertMultipleRecord from "@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord";
import getAgency from "@salesforce/apex/GetAgencyController.getAgency";
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
//custom Labels
import CpvDatatableComment from '@salesforce/label/c.CpvDatatableComment';
import CpvDatatableCaseReInitiateSuccess from '@salesforce/label/c.CpvDatatableCaseReInitiateSuccess';
import CpvDatatableCaseReviewSuccess from '@salesforce/label/c.CpvDatatableCaseReviewSuccess';
import CpvDatatableCaseCancelSuccess from '@salesforce/label/c.CpvDatatableCaseCancelSuccess';
import CpvDatatableRequiredFields from '@salesforce/label/c.CpvDatatableRequiredFields';

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import formFactorPropertyName from "@salesforce/client/formFactor";
import Id from "@salesforce/user/Id";
export default class CpvDataTable extends LightningElement {

  label = {
    CpvDatatableComment,
    CpvDatatableCaseReInitiateSuccess,
    CpvDatatableCaseReviewSuccess,
    CpvDatatableCaseCancelSuccess,
    CpvDatatableRequiredFields

  }
  @api loanAppId;
  @api cpvRecordTypeId;
  @api hasEditAccess;

  @track currentUserId = Id;
  @track disableMode;
  @track showSpinner = false;
  @track showSpinnerModal=false;
  @track caseRecordsData = [];
  @track waivedCaseRecordsData=[];
  @track caseData;
  enableInfiniteScrolling = true;
  enableBatchLoading = true;
  @track desktopBoolean = false;
  @track phoneBolean = false;
  @track formFactor = formFactorPropertyName;
  @track renderCaseDetails = false;
  @track showCpvfi=false;
  @track caseRecordId;
  @track isReInitiateModalOpen = false;
  @track noLabel;
  @track yesLabel;
  @track dataName;
  @track cityId;
  @track textAreaLabel;
  @track textAreaValue;
  @track showAgency = false;
  @track newAgencyName = "";
  @track newAgencyId = "";
  @track caseSingleRecordData;
  @track CancelOptions = [];
  @track reIntiateOptions = [];
  @track statusOptions = [];
  @track newAgencyOptions = [];
  @track newAgencyValue = "";
  @track checkInitiate=false;

  @track lanOwner;
  @track lanStage;
  @track lanSubStage;
  //@track cancelDisable;
  @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
  objInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$objInfo.data.defaultRecordTypeId",
    fieldApiName: REASON_FOR_CANCEL
  })
  ReasonForCancelHandler({ data, error }) {
    if (data) {
      console.log(data);
      this.CancelOptions = [...this.generatePicklist(data)];
    }
    if (error) {
      console.log(error);
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$objInfo.data.defaultRecordTypeId",
    fieldApiName: REASON_FOR_REINITIATE
  })
  ReInitiateHandler({ data, error }) {
    if (data) {
      console.log(data);
      this.reIntiateOptions = [...this.generatePicklist(data)];
    }
    if (error) {
      console.log(error);
    }
  }
  generatePicklist(data) {
    return data.values.map((item) => ({
      label: item.label,
      value: item.value
    }));
  }

  get reviewModal(){
    return this.yesLabel === 'Review';
  }
  connectedCallback() {
    console.log("hasEditAccess:::::::: ", this.hasEditAccess);
    if (this.hasEditAccess === false) {
      this.disableMode = true;
    }
    console.log("loanAppId in Cpv Datatale component ", this.loanAppId);
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
    this.fetchLoanDetails();
    // this.getCaseData();
    this.getWaivedCaseData();
  }



  fetchLoanDetails() {
  let  loanDetParams = {
      ParentObjectName: "LoanAppl__c",
      ChildObjectRelName: "",
      parentObjFields: ["Id", "Name", "ReqLoanAmt__c","NoCasesNeedToRaised__c","OwnerId","Stage__c","SubStage__c"],
      childObjFields: [],
      queryCriteria: ""
    };
  
    getSobjectDataNonCacheable({params: loanDetParams}).then((result) => {
       // this.wiredDataCaseQry=result;
        console.log("result TECHNICAL PROP LOAN DETAILS #722>>>>>", result);
        if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
          // this.loanAmount = result.parentRecords[0].ReqLoanAmt__c;
          // this.noOfCaseNeedToRaise=result.parentRecords[0].NoCasesNeedToRaised__c;
          this.lanOwner = result.parentRecords[0].OwnerId;
          this.lanStage = result.parentRecords[0].Stage__c;
          this.lanSubStage = result.parentRecords[0].SubStage__c;
        
          this.getCaseData();
        }
      })
      .catch((error) => {
        console.log("TECHNICAL PROP LOAN DETAILS #731", error);
      });
  }

  @track typeOfBorrower = "Financial";
  @api getCaseData() {
   let recordType='LIP_Vendor_case';
   let waiverCpv='Yes'
    console.log("loanappId in Reintiate component", this.loanAppId);
    let paramsLoanApp = {
      ParentObjectName: "Case",
      parentObjFields: [
        "Id",
        "Phone_No__c",
        "Mobile_No__c",
        "Address_Type__c",
        "Address_Line_2__c",
        "Address_Line_1__c",
        "ApplAddr__c",
        "CaseNumber",
        "AccountId",
        "ContactId",
        'IsReinitiated__c',
        "Applicant__r.TabName__c",
        "Old_Agency__r.Name",
        "Account.Name",
        "Contact.Name",
        "Status",
        "ReportResult__c",
        "CityId__c",
        "Reason_for_reinitiated_FI__c",
        "Reason_for_cancelation__c",
        "Loan_Application__c",
        "Applicant__c",
        "CreatedDate",
        "ClosedDate",
        'WaiveCPV__c',
        'RecordTypeId',
        'RecordType.Name',
        'TAT__c',
        'ReviewerComments__c',
        'City__c',
        'ExpiryDate__c',
        'IsReinitiatedExpired__c'
      ],
      queryCriteria:
        ' where  Applicant__c != null AND Loan_Application__c = \'' + this.loanAppId + '\' Order by createdDate'
        
    };
    getSobjectData({ params: paramsLoanApp }).then((result) => {
      this.caseData = result;
      this.enableOverride=true;
      console.log("result of case details is", JSON.stringify(result));
      try {
        if (result.parentRecords && result.parentRecords.length > 0) {
          // this.caseRecordsData = result.parentRecords;
          result.parentRecords.forEach((item, index) => {
            if (item.Status === "Closed" || item.Status ==='Cancelled') {
              // if (item.IsReinitiated__c === false) {
              //   item.isReinitDis = this.hasEditAccess===false?true:false;
              // } else {
              //   item.isReinitDis = this.hasEditAccess===false?true:true;
              // }
              console.log('cancel',item.Reason_for_cancelation__c);
              if (item.Reason_for_cancelation__c === false) {
                item.isCanDis = this.hasEditAccess===false?true:false;
                console.log('iscancel',item.isCanDis);
            }else{
              item.isCanDis = this.hasEditAccess===false ? true : true;
            }
          }else{
            item.isCanDis = this.hasEditAccess===false?true:false;
          }

          if( (item.Status === 'Closed' && item.ExpiryDate__c < new Date().toJSON().slice(0, 10) && item.IsReinitiated__c === false) || (item.Status === 'Cancelled' && item.IsReinitiated__c === false)){
            if((this.currentUserId === this.lanOwner) && (this.lanStage === 'Post Sanction' && (this.lanSubStage === 'Data Entry' || this.lanSubStage === 'Ops Query')) ){
              item.isReinitDis = false;
            }else{
              item.isReinitDis = this.hasEditAccess===true?false:true;
            }
           }else{
            item.isReinitDis = true;
           }
          // if( item.Status === 'New' || item.Status === 'In Progress' || item.Status === 'Query' || item.Status === 'Review Requested' || item.IsReinitiated__c === true){
          //   item.isReinitDis = true
          //  }else{
          //   item.isReinitDis = false
          //  }
          if( item.Status === 'Closed'){
            item.isReviewDis = this.hasEditAccess===true?false:true;
           }
           else{
            item.isReviewDis = true;
           }
           if(item.Status === 'Review Requested'){
            item.reviewReq = true;
           } else if(item.Status ==='Cancelled'){
            item.cancelStatus=true;
            item.reviewReq = false;
           }
           else{
            item.reviewReq = false;
            item.cancelStatus=false;
           }
         
            
          });
          this.caseRecordsData = result.parentRecords;

          this.caseRecordsData.forEach(row1 => {
                const dateTime1 = new Date(row1.CreatedDate);
                const formattedDate1 = formattedDateTimeWithoutSeconds(dateTime1); 
                const createdDate1 = `${formattedDate1}`;
                row1.CreatedDate = createdDate1;

              
                const dateTime2 = new Date(row1.ClosedDate);
                const formattedDate2 = formattedDateTimeWithoutSeconds(dateTime2); 
                const ClosedDate2 = `${formattedDate2}`;
                row1.ClosedDate = ClosedDate2;

                });


        }
      } catch (e) {
        console.error("error 117", e);
      }
      if (result.error) {
        console.error("case result getting error=", result.error);
      }
    });
  }





  @api getWaivedCaseData() {
    let recordType='LIP_Vendor_case';
    let waiverCpv='Yes'
     console.log("loanappId in Reintiate component", this.loanAppId);
     let paramsLoanApp = {
       ParentObjectName: "Case",
       parentObjFields: [
         "Id",
         "Applicant__r.TabName__c",
         "WaiverReason__c",
         "Loan_Application__c",
         "Applicant__c",
         "CreatedDate",
         "Address_Type__c",
         'WaiveCPV__c',
         'RecordTypeId',
         'RecordType.Name'
       ],
       queryCriteria:
         ' where  Applicant__c != null AND Loan_Application__c = \'' + this.loanAppId + '\'  AND RecordType.Name=\''+recordType+ '\''
         
     };
     getSobjectData({ params: paramsLoanApp }).then((result) => {
       this.caseData = result;
       if(result && result.parentRecords && result.parentRecords.length > 0){
          console.log("result of case details is", JSON.stringify(result));
          this.waivedCaseRecordsData = result.parentRecords;
            
            this.waivedCaseRecordsData.forEach(row1 => {
              const dateTime1 = new Date(row1.CreatedDate);
              const formattedDate1 = formattedDateTimeWithoutSeconds(dateTime1); 
              const createdDate1 = `${formattedDate1}`;
              row1.CreatedDate = createdDate1;
            });
            
        }
       if (result.error) {
         console.error("case result getting error=", result.error);
       }
     });
   }
 
  get caseId() {
    return `${this.caseRecordId}`;
  }
  get newAgencyOpts() {
    return `${this.newAgencyOptions}`;
  }
  handlebutton(event) {
    console.log("dataname is ", event.target.dataset.name);
    let dataValue = event.target.dataset.name;
    if (dataValue === "View") {
      if(!this.caseRecordId){
        this.caseRecordId = event.target.dataset.caseid;
        console.log("caseRecordId ", this.caseRecordId);
        this.renderCaseDetails = true;
        this.showCpvfi=true;
      }else {
        if(this.caseRecordId === event.target.dataset.caseid){
          this.renderCaseDetails = false;
          this.showCpvfi=false;
          this.caseRecordId=null
        }else{
          this.caseRecordId = event.target.dataset.caseid;
          this.renderCaseDetails = true;
          this.showCpvfi=true;
        }
      }
    }
    if (dataValue === "Re-Intiate") {
      this.caseRecordId = event.target.dataset.caseid;
      this.cityId = event.target.dataset.cityid;
      this.cityName = event.target.dataset.cityname
      //this.newAgencyValue=this.caseSingleRecordData.AccountId;
      console.log("caseRecordId ", this.caseRecordId);
      console.log("city id is ", this.cityId,this.cityName);
      this.noLabel = "Cancel";
      this.yesLabel = "Re-Iniate";
      this.dataName = "Re-Initiate";
      this.getcaseObjDetails(this.caseRecordId);
    }
    if (dataValue === "Cancel") {
      this.caseRecordId = event.target.dataset.caseid;
      console.log("caseRecordId ", this.caseRecordId);
      this.noLabel = "No";
      this.yesLabel = "Yes";
      this.dataName = "CancelCase";
      this.statusOptions = this.CancelOptions;
      this.textAreaLabel = "Reason for cancelation";
      this.getcaseObjDetails(this.caseRecordId);
      this.isReInitiateModalOpen = true;
    }
    if (dataValue === "Review") {
      this.caseRecordId = event.target.dataset.caseid;
      console.log("caseRecordId ", this.caseRecordId);
      this.textAreaValue='';
      this.noLabel = "No";
      this.yesLabel='Review';
     // this.reviewSubmitLabel = "Yes";
      this.dataName = "Review";
      this.isReInitiateModalOpen = true;
    
      //this.textAreaLabel = "Review";
      this.getcaseObjDetails(this.caseRecordId);
      this.reviewModalOpen = true;
    }
  }

  getcaseObjDetails(caseId) {
    let obj = this.caseRecordsData.find((item) => item.Id === caseId);
    console.log("came into getcaseObjDetails");
    console.log("dataname in getcaseObjDetails", this.dataName);
    if (obj) {
      console.log("obj ", obj);
      this.caseSingleRecordData = obj;
      console.log("this.caseSingleRecordData ", this.caseSingleRecordData);
      if (this.dataName === "Re-Initiate") {
        //this.fetchAgecnyLocMapper();
        this.newAgencyValue=this.caseSingleRecordData.AccountId;
        if (!this.caseSingleRecordData.Reason_for_reinitiated_FI__c) {
          console.log("no value");
          this.textAreaValue = "";
        } else {
          console.log("value");
          this.textAreaValue =
            this.caseSingleRecordData.Reason_for_reinitiated_FI__c;
        }
        //Checking Case Status For Re-Initiate
        if (
          this.caseSingleRecordData.Status === "Closed" ||
          this.caseSingleRecordData.Status === "Cancelled"
        ) {
          this.getNewAgency();
          this.statusOptions = this.reIntiateOptions;
          this.textAreaLabel = "Reason for Reinitiation";
          this.isReInitiateModalOpen = true;
          this.showAgency = true;
          this.fetchAgecnyLocMapper();
        } else {
          const evt = new ShowToastEvent({
            title: "Error",
            variant: "error",
            message:
              "Your Current Case Status is not Closed Or Cancelled, So please change Your Case Status to Re-Intiate"
          });
          this.dispatchEvent(evt);
        }
      }
      if (this.dataName === "CancelCase") {
        if (!this.caseSingleRecordData.Reason_for_cancelation__c) {
          console.log("no value");
          this.textAreaValue = "";
        } else {
          console.log("no value");
          this.textAreaValue =
            this.caseSingleRecordData.Reason_for_cancelation__c;
        }
      }
      if (this.dataName === "Review") {
        if (!this.caseSingleRecordData.ReviewerComments__c) {
          console.log("no value");
          this.textAreaValue = "";
        } else {
          console.log("no value");
          this.textAreaValue =
            this.caseSingleRecordData.ReviewerComments__c;
        }
      }
    }
  }

  getNewAgency() {
    let cityId =
      this.caseSingleRecordData.CityId__c != null
        ? this.caseSingleRecordData.CityId__c
        : "";
    getAgency({ cityId: cityId })
      .then((result) => {
        console.log("result of agency details", result);
        this.newAgencyOptions = result;
        console.log(
          "type of newAgencyOptions are",
          typeof this.newAgencyOptions
        );
        console.log(
          "newAgencyOptions are",
          JSON.stringify(this.newAgencyOptions)
        );
      })
      .catch((error) => {
        // this.showSpinner = false;
        console.log("error occured in getAgency", error);
        console.log("getAgency");
      });
  }


  @track
  agencyMapParams = {
    ParentObjectName: "AgncLocMap__c",
    ChildObjectRelName: "",
    parentObjFields: ["Id","Name","LocationMaster__r.City__c","Account__r.Name","Contact__c" ],
    childObjFields: [],
    queryCriteria: ""
  };
@track agencyOptions=[];
@track agencyOptions1=[];
@track accContactMap=[];
  fetchAgecnyLocMapper() {
    let agencyType='CPVFI';
    let tempParams = this.agencyMapParams;
    tempParams.queryCriteria =
      ' where IsActive__c = true AND LocationMaster__r.City__c  = \'' + this.cityName + '\' AND AgencyType__c=\''+ agencyType+'\'' ;
    this.agencyMapParams = { ...tempParams };

    getSobjectDataNonCacheable({params: this.agencyMapParams}).then((result) => {
       // this.wiredDataCaseQry=result;
       this.accContactMap=[];
        console.log("result CPV DATATABLE PROP AGENCY MAPPERS #449>>>>>", result);
        if (result.parentRecords !== undefined) {
          result.parentRecords.forEach((item) => {
            if(item.Account__c && item.Account__r.Name && item.Account__r.Id){
  
              let opt = { label: item.Account__r.Name, value: item.Account__r.Id };
              this.agencyOptions = [...this.agencyOptions, opt];
              this.agencyOptions.sort(this.compareByLabel); //picklist sorting
  
              let opt1 = { label: item.Account__c, value: item.Contact__c };
  
              // const labelExists1 = this.accContactMap.some(option => option.label === opt1.label);
              // if (labelExists1) {
              //     this.accContactMap = [...this.accContactMap, opt1];
              // }
              this.accContactMap.push(opt1); 
              //= [...this.accContactMap, opt1];
              this.accContactMap.sort(this.compareByLabel); //picklist sorting
              console.log('DATA IN this.accContactMap 529::::>>>>',this.accContactMap);
                           
            }         
          });
  
          const agencyOpt = this.agencyOptions.map(({ label }) => label);
          const filtered = this.agencyOptions.filter(({ label }, index) =>
          !agencyOpt.includes(label, index + 1));
          console.log('DATA IN filtered ::::>>>>',filtered);
          let finalArr=[...filtered]
 
          this.agencyOptions1 = [...finalArr];
       
  
          this.showSpinner=false;
        }else{
          this.showSpinner=false;
          this.showToastMessage('Error',this.label.TechnicalNoAgencyError,'error','sticky')
        }
      })
      .catch((error) => {
        this.showSpinner=false;
        console.log("TECHNICAL PROP CASE QUERIES #527", error);
      });
  }

  //method to sort array of objects alphabetically
  compareByLabel(a, b) {
    const nameA = a.label.toUpperCase();
    const nameB = b.label.toUpperCase();

    if (nameA < nameB) {
        return -1;
    }
    if (nameA > nameB) {
        return 1;
    }
    return 0;
}
 
@track conId;
  handleNewAgencyChange(event) {
    this.newAgencyValue = event.target.value;
    const filteredData = this.accContactMap.find((obj) => {
      return (obj.label === this.newAgencyValue)
    });
    console.log('Agecy 1 contact',filteredData);
    if(filteredData && filteredData.value){
      this.conId=filteredData.value;
    }
    console.log("newAgencyValue ", this.newAgencyValue);
    console.log("value is ", event.target.value);
  }
  handleTextAreaChange(event) {
    if(this.yesLabel==='Review'){
      this.textAreaValue = event.target.value.toUpperCase();
    }else{
      this.textAreaValue = event.target.value;
      let dtname = event.target.dataset.name;
      console.log("dataName ", dtname);
      console.log("textAreaValue ", this.textAreaValue);
    }
   
  }
  closeModal() {
    this.isReInitiateModalOpen = false;
    this.showAgency = false;
    this.textAreaValue = "";
    this.newAgencyValue = "";
  }

  handleModalYesClick(event) {
   // this.isReInitiateModalOpen = false;
    this.showSpinnerModal = true;
    console.log("dataname is ", event.target.dataset.name);
    if (this.caseSingleRecordData) {
      console.log("came ", this.caseSingleRecordData);
      console.log("this.yesLabel ", this.yesLabel);
      let fields = {};
      let oldFields = {};
      // fields['sobjectType'] = 'Case';
      if (this.yesLabel === "Re-Iniate") {
        fields["sobjectType"] = "Case";
        fields["Reason_for_reinitiated_FI__c"] = this.textAreaValue
          ? this.textAreaValue
          : "";
        fields["Old_Agency__c"] = this.caseSingleRecordData.AccountId
          ? this.caseSingleRecordData.AccountId
          : "";
        fields.AccountId =this.newAgencyValue? this.newAgencyValue:this.caseSingleRecordData.AccountId;
        fields.ContactId = this.conId ? this.conId : this.caseSingleRecordData.ContactId;
        //fields['sobjectType'] = 'Case';
        fields["Applicant__c"] = this.caseSingleRecordData.Applicant__c
          ? this.caseSingleRecordData.Applicant__c
          : "";
        fields["ApplAddr__c"] = this.caseSingleRecordData.ApplAddr__c
          ? this.caseSingleRecordData.ApplAddr__c
          : "";
        fields["Loan_Application__c"] = this.caseSingleRecordData
          .Loan_Application__c
          ? this.caseSingleRecordData.Loan_Application__c
          : "";
        fields["Address_Line_1__c"] = this.caseSingleRecordData
          .Address_Line_1__c
          ? this.caseSingleRecordData.Address_Line_1__c
          : "";
        fields["Address_Line_2__c"] = this.caseSingleRecordData
          .Address_Line_2__c
          ? this.caseSingleRecordData.Address_Line_2__c
          : "";
        fields["Address_Type__c"] = this.caseSingleRecordData.Address_Type__c
          ? this.caseSingleRecordData.Address_Type__c
          : "";
        fields["Mobile_No__c"] = this.caseSingleRecordData.Mobile_No__c
          ? this.caseSingleRecordData.Mobile_No__c
          : "";
        fields["Phone_No__c"] = this.caseSingleRecordData.Phone_No__c
          ? this.caseSingleRecordData.Phone_No__c
          : "";
        fields["CityId__c"] = this.caseSingleRecordData.CityId__c
          ? this.caseSingleRecordData.CityId__c
          : "";
        fields["RecordTypeId"] = this.cpvRecordTypeId
          ? this.cpvRecordTypeId
          : "";
        fields["Status"] = "New";
        fields["Origin"] = "Web";
        fields["IsRouRobAllowd__c"] = false;
        if(this.caseSingleRecordData.Status === 'Closed' && this.caseSingleRecordData.ExpiryDate__c < new Date().toJSON().slice(0, 10)){
          fields["IsReinitiatedExpired__c"] = true;
         }

           // To update Old Case record
           oldFields["Id"] = this.caseSingleRecordData.Id;
           oldFields["sobjectType"] = "Case";
           oldFields["IsReinitiated__c"] = true;
          
      } else if(this.yesLabel === "Review"){
        let isInputCorrect = this.validateForm();

        if (isInputCorrect === true) {
       // this.showSpinner = true;
       fields["sobjectType"] = "Case";
        fields["Id"] =
        this.caseSingleRecordData.Id != null
          ? this.caseSingleRecordData.Id
          : "";
          fields["ReviewerComments__c"] = this.textAreaValue;
          fields["Status"] ='Review Requested';
          this.createComment();
       // this.reviewModalOpen=false;
        //this.showSpinnerModal = false;
        } else {
          this.showSpinnerModal = false;
          this.showToastMessage('Error', this.label.CpvDatatableRequiredFields, 'error', 'sticky');
         
        }

      }     
      
      else {
        let isInputCorrect = this.validateForm();
        if (isInputCorrect === true) {
          fields["Id"] =
          this.caseSingleRecordData.Id != null
            ? this.caseSingleRecordData.Id
            : "";
        fields["Reason_for_cancelation__c"] = this.textAreaValue;
        fields["Status"] = "Cancelled";
        }else{
          this.showSpinnerModal = false;
          this.showToastMessage('Error', this.label.CpvDatatableRequiredFields, 'error', 'sticky');
        }
       
      }
      console.log("this.fields for updation is ", fields, oldFields);
      if(fields || oldFields){
        //this.showSpinnerModal = true;
        this.upsertDataMethod(fields);
        this.upsertDataMethod(oldFields);
      }
      // if(Object.keys(fields).length > 0){
      //   this.upsertDataMethod(fields);
      // }
      // if(Object.keys(oldFields).length > 0){
      //   this.upsertDataMethod(oldFields);
      // }
     
    }
  }

  upsertDataMethod(obje) {
    let newArray = [];
    if (obje) {
      newArray.push(obje);
    }
    if (newArray) {
      console.log("new array is ", JSON.stringify(newArray));
      upsertMultipleRecord({ params: newArray })
        .then((result) => {
          if (this.yesLabel === "Re-Iniate") {
            this.showToastMessage('Success', this.label.CpvDatatableCaseReInitiateSuccess, 'success', 'sticky');
          } 
          else if (this.yesLabel === "Review") {
            this.showToastMessage('Success', this.label.CpvDatatableCaseReviewSuccess, 'success', 'sticky');
            } 
          else {
            this.showToastMessage('Success', this.label.CpvDatatableCaseCancelSuccess, 'success', 'sticky');
          }

          this.getCaseData();
          this.getWaivedCaseData();
          this.textAreaValue = "";
          this.newAgencyValue = "";
          this.showSpinnerModal=false;
          this.showSpinner = false;
          this.showAgency = false;
          this.isReInitiateModalOpen = false;
        })
        .catch((error) => {
          this.showSpinner = false;
          console.log("error occured in upsert", error);
          console.log("upsertDataMethod");
        });
    }
  }




  createComment(){
    const fields = {};
    fields[REVIEW_COMMENT_FIELD.fieldApiName] = this.textAreaValue;
    fields[CASE_COMMENTS_FIELD.fieldApiName] = this.caseRecordId;
    fields[USER_FIELD.fieldApiName] = this.currentUserId;

    const recordInput = { apiName: COMMENTS_OBJECT.objectApiName, fields };
    console.log("fields::::: #740", fields);
    createRecord(recordInput)
            .then((result) => {
              console.log("COMMENTS RESULT:::::1003", result);
             // refreshApex(this.wiredData);
            //  this.getCaseData();
            // let oldFields={};
            // oldFields.sobjectType = "Case";
            // oldFields.Id = this.caseRecordId;
            // oldFields.Status = 'Review Requested';
            // oldFields.ReviewerComments__c = this.reviewRemarks;
           // this.upsertDataMethod(oldFields);
           
              this.showToastMessage('Success', this.label.CpvDatatableComment, 'success', 'sticky');
             
            })
            .catch((error) => {
              console.log("CASE COMMENTS RESULT ERRO:::::1011", error);
             
            });
    
}


validateForm() {
  let isValid = true;
  // if(this.checkInitiate){
  //   if (this.docArr.length < 1) {
  //     isValid = false;
  //     this.showToastMessage('Error', this.label.Technical_Doc_ErrorMessage, 'error', 'sticky');
    
  //   }
  // }
 
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
    this.tableScrolled(event);
  }

  tableScrolled(event) {
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
    console.log(
      "handlemousedown._tableThColumn.tagName => ",
      this._tableThColumn.tagName
    );
    this._pageX = e.pageX;

    this._padding = this.paddingDiff(this._tableThColumn);

    this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
    console.log(
      "handlemousedown._tableThColumn.tagName => ",
      this._tableThColumn.tagName
    );
  }

  handlemousemove(e) {
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

  handledblclickresizable() {
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