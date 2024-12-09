import { LightningElement, track, wire, api } from "lwc";
import { createRecord,updateRecord} from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import CASE_OBJECT from "@salesforce/schema/Case";
import APPL_ASSET_OBJECT from "@salesforce/schema/ApplAsset__c";
import COMMENTS_OBJECT from "@salesforce/schema/Comments__c";

import REASON_FOR_CANCEL from "@salesforce/schema/Case.Reason_for_cancelation__c";
import REASON_FOR_REINITIATE from "@salesforce/schema/Case.Reason_for_reinitiated_FI__c";

import CASE_COMMENTS_FIELD from "@salesforce/schema/Comments__c.Case__c";
import REVIEW_COMMENT_FIELD from "@salesforce/schema/Comments__c.ReviewerComments__c";
import USER_FIELD from "@salesforce/schema/Comments__c.User__c";

import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData'; 
import CASE_DOC_OBJECT from "@salesforce/schema/CaseDoc__c";
import CASE_FIELD from "@salesforce/schema/CaseDoc__c.Case__c";
import DOC_DET_FIELD from "@salesforce/schema/CaseDoc__c.DocDetail__c";
import getSobjectData1 from "@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType";
import upsertMultipleRecord from "@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord";
import getAgency from "@salesforce/apex/GetAgencyController.getAgency";
import { formattedDateTimeWithoutSeconds } from 'c/dateUtility';
// Custom labels
import LOAN_AMT_Label from "@salesforce/label/c.LoanAmt";
//import Technical_CaseStatus_ErrorMessage from '@salesforce/label/c.Technical_CaseStatus_ErrorMessage';
import Technical_CaseQueryUpdate_SuccessMessage from '@salesforce/label/c.Technical_CaseQueryUpdate_SuccessMessage';
import Technical_ReInitiate_SuccessMessage from '@salesforce/label/c.Technical_ReInitiate_SuccessMessage';
import Technical_ReqFields_ErrorMessage from '@salesforce/label/c.Technical_ReqFields_ErrorMessage';
import Technical_Cancel_SuccessMessage from '@salesforce/label/c.Technical_Cancel_SuccessMessage';
import Technical_CaseCreate_SuccessMessage from '@salesforce/label/c.Technical_CaseCreate_SuccessMessage';
import Technical_Doc_ErrorMessage from '@salesforce/label/c.Technical_Doc_ErrorMessage';
import Technical_Doc_SuccessMessage from '@salesforce/label/c.Technical_Doc_SuccessMessage';
import TechnicalCaseCommentSuccess from '@salesforce/label/c.TechnicalCaseCommentSuccess';
import Technical_CaseStatusUpdated from '@salesforce/label/c.Technical_CaseStatusUpdated';
import TechnicalCaseInitiateErrorMsg from '@salesforce/label/c.TechnicalCaseInitiateErrorMsg';
import TechnicalCaseSameAgencyError from '@salesforce/label/c.TechnicalCaseSameAgencyError';
import TechnicalRerunValSuccess from '@salesforce/label/c.TechnicalRerunValSuccess';
import TechnicalNoAgencyError from '@salesforce/label/c.TechnicalNoAgencyError';
//import getAllSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import {
  subscribe,
  publish,
  MessageContext,
  unsubscribe,
  releaseMessageContext,
  createMessageContext
} from "lightning/messageService";

import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import { refreshApex } from "@salesforce/apex";
import Id from "@salesforce/user/Id";
export default class LegalDetails extends LightningElement {

  label = {
    LOAN_AMT_Label,
   // Technical_CaseStatus_ErrorMessage,
    Technical_CaseQueryUpdate_SuccessMessage,
    Technical_ReInitiate_SuccessMessage,
    Technical_ReqFields_ErrorMessage,
    Technical_Cancel_SuccessMessage,
    Technical_CaseCreate_SuccessMessage,
    Technical_Doc_ErrorMessage,
    Technical_Doc_SuccessMessage,
    TechnicalCaseCommentSuccess,
    Technical_CaseStatusUpdated,
    TechnicalCaseInitiateErrorMsg,
    TechnicalCaseSameAgencyError,
    TechnicalRerunValSuccess,
    TechnicalNoAgencyError

  }
  @track disableInitiate=false;
  @track initiateLegal;
  @track reInitiateTechnical;
  @track docList = [];
  @track showSpinner = false;
  @track currentUserId = Id;
   @track userRole;
  @api hasEditAccess;
 // @track disableMode;
  @track disableAgency1;
  @track _currentTabId;
  @track colProp;
  @track appId;
  @track docArr = [];
  @track tsrType;
  @track yrType;
  @track prodType;
  @track brchName;
  @track collId;
  @track propIdentify;
  @track houseNo;
  @track addLine1;
  @track addLine2;
  @track landmark;
  @track area;
  @track state;
  @track pincode;
  @track mainApp;
  @track appPhone;
  @track appMob;
  @track assetId;
  @track propOwners;
  @track loanAmount;
  @track filterCriteria = "Property Papers";
  @track city;
  @track assetCityId;
  @track caseWrp = {};
  @track remarks;
  @track reviewRemarks;
  @track newCaseId;
  @track accId1;
  @track accId2;
  @track contactId1;
  @track contactId2;
  @track noOfCaseRaised;
  @track extraCaseToRaise;
  @track totalCaseRaised
  @track caseStatus;

  agencyOptions = [];
  agencyOptions1 = [];
  agencyOptions2 = [];

  //@api cpvRecordTypeId;
  @track caseRecordsData = [];
 
  @track caseData;
  enableInfiniteScrolling = true;
  enableBatchLoading = true;

  @track renderCaseDetails = false;
  @track showTSR= false;
  @track showLegal=false;
  @track caseRecordId;
  @track isReInitiateModalOpen = false;
  @track reviewModalOpen=false;
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
  @track caseQrystatusOptions = [];
  @track newAgencyOptions = [];
  @track caseQryList = [];
  @track newAgencyValue = "";
  @track activeSection = ["A", "B"];
  @track isReinitDis = false;
  @track rerunDisable=true;
  @track rerunFlag;
  @track lanOwner;
  @track lanStage;
  @track lanSubStage;
  @track propertyType;
  @track waiveReasonVal;
  @track waiveCaseFlag=false;


get prodOptions(){
  return [
    { label: 'Home Loan', value: 'Home Loan' },
    { label: 'Small Ticket LAP', value: 'Small Ticket LAP' },
    { label: 'Loan Against Property', value: 'Loan Against Property' }
];
}

get reviewOptions(){
  let opt=[];
  if(this.userRole !== 'LHM'){
opt=[{ label: 'Legal Hub Manager', value: 'Legal Hub Manager' },
     { label: 'Agency', value: 'Agency' }]
  }
else{
  opt=[ { label: 'Agency', value: 'Agency' } ]
}
  return opt;
}
get disableInit(){
  let disbale = false;
  if(this.prodType === 'Home Loan'){
    if(this.propIdentify !== 'Yes'){
      disbale= true;
    }
  } else if(this.prodType === 'Small Ticket LAP' || this.prodType === 'Loan Against Property'){
    if(this.lanStage === 'QDE'){
      disbale= true;
    }
  }
 return disbale
}

get reinitHide(){
  return this.userRole !== 'LHM';
}
  subscription;

  @api get currentTabId() {
    return this._currentTabId;
  }
  set currentTabId(value) {
    this._currentTabId='';
    this._currentTabId = value;
    this.setAttribute("currentTabId", value);

    this.fetchApplAsset(value);
    this.handleCaseQueryIdChange(value);
    this.handleteamHierIdChange()

  }
  @track _loanAppId;
  @api get loanAppId() {
    return this._loanAppId;
  }
  set loanAppId(value) {
    this._loanAppId = value;
    this.setAttribute("loanAppId", value);
    this.fetchLoanDetails();
  }
  @track _applicantId;
  @api get applicantId() {
    return this._applicantId;
  }
  set applicantId(value) {
    this._applicantId = value;
    this.setAttribute("applicantId", value);
  }

  @wire(MessageContext)
  MessageContext;

  sunscribeToMessageChannel() {
    this.subscription = subscribe(
      this.MessageContext,
      SaveProcessCalled,
      (values) => this.handleSaveThroughLms(values)
    );
  }



@track closedCaseDisableTsr;
  get disableInitiateLegal(){ 
    return this.disableMode || this.disableInit || this.closedCaseDisableTsr;
  }

  updatedColumns = [
    { label: "Document Type", fieldName: "DocTyp__c", type: "text" },
    { label: "Document Name", fieldName: "DocSubTyp__c", type: "text" },
    { label: "File Type", fieldName: "File_Type__c", type: "text" },
    {
      label: "Date & Time",
      fieldName: "CreatedDate",
      type: "date",
      typeAttributes: {
        day: "numeric",
        month: "short",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
        hour12: true
      }
    }
  ];
 
  
  
  @track
  docDetParams = {
    ParentObjectName: "DocDtl__c",
    ChildObjectRelName: "",
    parentObjFields: [
      "Id",
      "Name",
      "LAN__c",
      "DocTyp__c",
      "File_Type__c",
      "CreatedDate",
      "DocSubTyp__c",
      "ApplAsset__r.Id"
    ],
    childObjFields: [],
    queryCriteria: " where DocTyp__c ='" + this.filterCriteria + "'"  //update filterCriteria
  };




  @track
  agencyMapParams = {
    ParentObjectName: "AgncLocMap__c",
    ChildObjectRelName: "",
    parentObjFields: [
      "Id",
      "Name",
      "LocationMaster__r.City__c",
      "Account__r.Name",
      "Contact__c"
    ],
    childObjFields: [],
    queryCriteria: ""
  };

  @track
  caseQueryParams = {
    ParentObjectName: "Case_Query__c",
    ChildObjectRelName: "",
    parentObjFields: [
      "Id",
      "Case__r.ApplAssetId__c",
      "CaseNumber__c",
      "Query__c",
      "Raised_By__c",
      "Response__c",
      "Status__c"
    ],
    childObjFields: [],
    queryCriteria: " "
  };


  @api handleValueChangeChild(){
    console.log('handle value change called #330')
  }

  handleCaseQueryIdChange() {
    let tempParams = this.caseQueryParams;
    tempParams.queryCriteria =
      " where Case__r.ApplAssetId__c = '" +
      this._currentTabId +
      "' order by CreatedDate desc";
    this.caseQueryParams = { ...tempParams };
    this.fetchCaseQuery();
    console.log("caseQyery paaram:::::", this.caseQueryParams);

  }
  handleteamHierIdChange() {
    let tempParams = this.teamHierParam;
    tempParams.queryCriteria = ' where Employee__c = \'' + this.currentUserId + '\' limit 1' ;
    this.teamHierParam = { ...tempParams };

}
@track teamHierParam = {
  ParentObjectName: 'TeamHierarchy__c',
  ChildObjectRelName: '',
  parentObjFields: ['Id','EmpRole__c','Employee__c'],
  childObjFields: [],
  queryCriteria: ''
  }
  @wire(getSobjectData,{params : '$teamHierParam'})
  teamHierHandler({data,error}){
      if(data){
          console.log('DATA IN CASE DETAILS :::: #412>>>>',data);
          if(data.parentRecords !== undefined ){
              this.userRole = data.parentRecords[0].EmpRole__c
              console.log('DATA IN CASE DETAILS :::: #415>>>>',this.userRole);
          }
                    
      }
      if(error){
          console.error('ERROR CASE DETAILS:::::::#420',error)
      }
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
 

  @api handleValueSelect(event){
    let childEvt = event.detail;
    console.log('childEvt in TSR component::::#387',childEvt );
    this.deviationMstrId=event.detail.id;
    this.getCaseData();
    this.getWaivedCaseData();

}   

@track arrayDeviationInsert=[];

@api handleValueSelect2(event){
  let childEvt = event.detail;
  console.log('childEvt in TSR component::::#387',childEvt );
  //this.createDeviation(childEvt);
  this.arrayDeviationInsert=event.detail;
}

createDeviation(res) {
    if (this.validateForm()) {
        console.log('deviationObj true');
        this.showSpinnerModal = true;
        try {
            let tempArray = [];
            
            // Assuming event.detail is an array of objects
            res.forEach(item => {
                let fields = {
                    sobjectType: 'Deviation__c',
                    LoanAppln__c: this._loanAppId,
                    Devia_Desrp__c: item.Devia_Desrp__c, // Replace with actual field from event.detail
                    Mitigation__c: item.Mitigation__c, // Replace with actual field from event.detail
                    RemarksForInternalLegal__c: item.RemarksForInternalLegal__c,
                    DeviationMaster__c: item.masterId
                };
                tempArray.push(fields);
            });

            console.log('Insert data:', JSON.stringify(tempArray));

            
            upsertMultipleRecord({ params: tempArray })
                .then(result => {
                    //this.initiateLegal = false;
                    //this.reInitiateTechnical = false;
                    //let arr = [...result];
                    //let tempArr = []
                    console.log('Deviation Created Records:', result);
                    this.renderCaseDetails=false;
                    // arr.forEach(item => {
                    //     tempArr.push(item.Id)
                    // });
                    //this.caseIDArray = tempArr;
                    //console.log('Case Created Record case Id Array:', this.caseIDArray, tempArr);
                    if(this.userRole === 'LHM'){
                    this.showToastMessage('Success', 'The Deviation records Created', 'success', 'sticky');
                    }
                    this.renderCaseDetails=true;
                    this.refreshDocTable();
                    this.showSpinner = false;
                    this.showSpinnerModal = false;
                    refreshApex(this.wiredData);
                    this.getCaseData();
                    this.getWaivedCaseData();
                })
                .catch(error => {
                    this.showSpinner = false;
                    this.showSpinnerModal = false;
                    console.error('Error creating Deviation records:', error);
                });
        } catch (error) {
            this.showSpinner = false;
            this.showSpinnerModal = false;
            console.error('Final Error creating Deviation:', error);
        }
    } else {
        this.showSpinnerModal = false;
    }
}


get disableMode(){
  return !this.hasEditAccess;
}
  connectedCallback() {
    this.activeSection = ["A"];
     this.fetchApplAsset(); 
     this.sunscribeToMessageChannel();
     this.getCaseData();
     this.getWaivedCaseData();
  }

disconnectedCallback() {
    this.unsubscribeMC();
    releaseMessageContext(this.context);
}
unsubscribeMC() {
    unsubscribe(this.subscription);
    this.subscription = null;
}


@track waiverResOpt=[];
@wire(getPicklistValuesByRecordType, {
  objectApiName: CASE_OBJECT,
  recordTypeId: '$recordTypeId'})
  picklistHandlerforTSR({ data, error }){
  if(data){
    console.log('LEGAL WAIVER REASON 494::::',data)
      this.waiverResOpt=[...this.generatePicklist(data.picklistFieldValues.WaiverReason__c	)]  
      console.log('LEGAL WAIVER REASON 496',this.waiverResOpt)
  }   
  if (error) {
      console.error('error 274'+error)
  }
}

  @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
  objInfo;

  @wire(getPicklistValues, {
    recordTypeId: '$recordTypeId',
    fieldApiName: REASON_FOR_CANCEL
  })
  ReasonForCancelHandler({ data, error }) {
    if (data) {
      console.log("CANCEL PICKLIST DATA::::: #247", data);
      this.CancelOptions = [...this.generatePicklist(data)];
    }
    if (error) {
      console.log(error);
    }
  }

  
  @wire(getPicklistValues, {
    recordTypeId: "$objInfo1.data.defaultRecordTypeId",
    fieldApiName: REASON_FOR_REINITIATE
  })
  ReInitiateHandler({ data, error }) {
    if (data) {
      this.reIntiateOptions = [...this.generatePicklist(data)];
    }
    if (error) {
      console.log(error);
    }
  }


  @wire(getObjectInfo, { objectApiName: APPL_ASSET_OBJECT })
  objInfo2;
  @wire(getPicklistValuesByRecordType, {
    objectApiName: APPL_ASSET_OBJECT,
    recordTypeId: "$objInfo2.data.defaultRecordTypeId"
  })
  ApplAssetPicklistHandler({ data, error }) {
    if (data) {
      this.yrOptions = [...this.generatePicklist(data.picklistFieldValues.TSRECForNoYrs__c)];
      this.tsrOptions=[...this.generatePicklist(data.picklistFieldValues.IsTSRFiredToSameLegalVendor__c)];
    }
    if (error) {
      console.error("error im getting TSR picklist values are", error);
    }
  }


  @track allowDevUpdt;
  

  @api getCaseData() {
    console.log("loanappId in Reintiate component", this.loanAppId);
    let recordType='Legal';
    let paramsLoanApp = {
      ParentObjectName: "Case",
      parentObjFields: [
        "Id",
        "Address_Type__c",
        "Address_Line_2__c",
        "Address_Line_1__c",
        "ApplAddr__c",
        "CaseNumber",
        "AccountId",
        "ContactId",
        "ClosedDate",
        "ReportResult__c",
        "Old_Agency__r.Name",
        "Account.Name",
        "Contact.Name",
        "Status",
        "Remarks_for_Technical_Agency__c",
        "CityId__c",
        "Reason_for_reinitiated_FI__c",
        "Reason_for_cancelation__c",
        "Loan_Application__c",
        "Applicant__c",
        "IsReinitiated__c",
        'DateTimeInitiation__c',
        'Date_Time_of_Submission__c',
        'ReviewerComments__c',
        'ExpiryDate__c',
        'IsReinitiatedExpired__c',
        'TAT__c',
        'HubManagerReview__c',
        'AreThereAnyLegalDeviations__c',
        'FinalStatusTSRReportFromHLM__c'

      ],

        queryCriteria:' where AccountId != null AND RecordType.DeveloperName = \''+recordType+ '\' AND ApplAssetId__c = \'' + this._currentTabId + '\'order by createdDate asc'
    };
    getSobjectData1({ params: paramsLoanApp }).then((result) => {
      this.caseData = result;
      this.caseRecordsData = [];
      this.fetchApplAsset();
     // console.log('data found cases:',this.caseData);
      if (
        result.parentRecords !== undefined &&
        result.parentRecords.length > 0
      ) {
        this.closedCaseDisableTsr=true;
        result.parentRecords.forEach((item, index) => {
            console.log('item loop inside::',item);
          if (item.Status === "Closed" || item.Status === "Cancelled") {
            item.isCanDis = true;
          } else {
           // this.agecnyFlag=false;
            item.isCanDis = this.hasEditAccess===true?false:true
            
          }
          if(item.Status=== 'New' || item.Status==='In Progress'){
            this.disableAgency1=true;
            this.removeAgency2=item.Account.Name;
            console.log('this.removeAgency2::::',this.removeAgency2);
          }else{
            this.disableAgency1=false;
          }
  
          if((item.Status === 'Closed' && item.ExpiryDate__c < new Date().toJSON().slice(0, 10) && item.IsReinitiated__c === false) || (item.Status === 'Cancelled' && item.IsReinitiated__c === false)){
            if((this.currentUserId === this.lanOwner) && (this.lanStage === 'Post Sanction' && (this.lanSubStage === 'Data Entry' || this.lanSubStage === 'Ops Query')) ){
              item.isReinitDis = false;
            }else{
              item.isReinitDis = this.hasEditAccess===true?false:true;
            }
            
           }else{
            item.isReinitDis = true;
           }

           if(item.Status === 'Closed' && item.IsReinitiatedExpired__c === true){
              this.rerunDisable=false;
           }

     
          if( item.Status === 'Closed' && item.HubManagerReview__c !== 'Legal Review'){
              item.isReviewDis = this.hasEditAccess===true?false:true;
             }
             else{
              item.isReviewDis = true;
             }
          
             if(item.Status === 'Review Requested'){
              item.reviewReq = true;
             }else{
              item.reviewReq = false;
             }
             if(item.HubManagerReview__c === 'Legal Review'){
              item.legalReviewReq = true;
             }else{
              item.legalReviewReq = false;
             }

             console.log('item.AreThereAnyLegalDeviations__c =',item.AreThereAnyLegalDeviations__c)
             if(item.AreThereAnyLegalDeviations__c === 'Y'){
                this.allowDevUpdt = true;
             }

        });

        this.caseRecordsData = result.parentRecords;

       
        this.caseRecordsData.forEach(row1 => {
            const dateTime1 = new Date(row1.ClosedDate);
            const dateTime2 = new Date(row1.DateTimeInitiation__c);
            const formattedDate1 = formattedDateTimeWithoutSeconds(dateTime1); 
            const formattedDate2 = formattedDateTimeWithoutSeconds(dateTime2); 
            const dateOfIntiation1 = `${formattedDate1}`;
            const dateOfIntiation2 = `${formattedDate2}`;
            row1.ClosedDate = dateOfIntiation1;
            row1.initiationDate = dateOfIntiation2;
        });

      
      }
      if (result.error) {
        this.fetchApplAsset();
        console.error("case result getting error=", result.error);
      }
    });
  }

  @api getWaivedCaseData() {
    let recordType='Legal';
    let waiverCpv='Yes'
     let paramsWaiveCases = {
       ParentObjectName: "Case",
       parentObjFields: [
         "Id",
         "CaseNumber",
         "ApplAssetId__r.PropAddrs__c",
         "WaiverReason__c",
         "Loan_Application__c",
         "Applicant__c",
         "DateTimeInitiation__c",
         "ClosedDate",
         "Address_Type__c",
         'WaiveCPV__c',
         'RecordTypeId',
         'RecordType.Name',
         'Remarks_for_Technical_Agency__c'
       ],
       queryCriteria:
         ' where ApplAssetId__c = \'' + this._currentTabId + '\' AND  WaiveCPV__c =\''+ waiverCpv+'\'  AND RecordType.Name=\''+recordType+ '\''
         
     };
     getSobjectDataNonCacheable({ params: paramsWaiveCases }).then((result) => {
       this.caseData = result;
       if(result && result.parentRecords && result.parentRecords.length > 0){
        this.waiveCaseFlag=true;
          console.log("result of case details is", JSON.stringify(result));
          this.waivedCaseRecordsData = result.parentRecords;
          let tempArr=[];
          this.waivedCaseRecordsData.forEach(item => {

    
              const formattedDate1 = formattedDateTimeWithoutSeconds(new Date(item.ClosedDate)); 
              const formattedDate2 = formattedDateTimeWithoutSeconds(new Date(item.DateTimeInitiation__c)); 
              const dateOfIntiation1 = `${formattedDate1}`;
              const dateOfIntiation2 = `${formattedDate2}`;
              let obj ={}
              obj={...item,initiationDate : dateOfIntiation2}
              item = {...obj}
              tempArr.push(item);
          });
          this.waivedCaseRecordsData=[];
          this.waivedCaseRecordsData=[...tempArr];
            
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
  get disableModeAgency1(){
    return this.disableMode || this.disableAgency1;
  }



  fetchDcoumentDetails() {
    getSobjectDataNonCacheable({params: this.docDetParams}).then((result) => {
        if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
          this.docList = result.parentRecords;   
        
        }
      })
      .catch((error) => {
        console.log("TECHNICAL PROP DOCUMENT DETAILS #696", error);
      });
  }



  fetchLoanDetails() {
  let loanDetParams = {
      ParentObjectName: "LoanAppl__c",
      ChildObjectRelName: "",
      parentObjFields: ["Id", "Name", "ReqLoanAmt__c","OwnerId","Stage__c","SubStage__c"],
      childObjFields: [],
      queryCriteria: " where Id = '" + this._loanAppId + "' limit 1"
    };
    getSobjectDataNonCacheable({params: loanDetParams}).then((result) => {
       // this.wiredDataCaseQry=result;
        console.log("result TECHNICAL PROP LOAN DETAILS #722>>>>>", result);
        if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
          this.loanAmount = result.parentRecords[0].ReqLoanAmt__c;
          this.lanOwner = result.parentRecords[0].OwnerId;
          this.lanStage = result.parentRecords[0].Stage__c;
          this.lanSubStage = result.parentRecords[0].SubStage__c;
          this.getCaseData();
          this.getWaivedCaseData();
        }
      })
      .catch((error) => {
        console.log("TECHNICAL PROP LOAN DETAILS #731", error);
      });
  }



  refreshDocTable() {
        this.showSpinner = false;
        let child = this.template.querySelector('c-legal-case-details'); 
        child.fetchDeviationData();
    }


  fetchCaseQuery() {
    getSobjectDataNonCacheable({params: this.caseQueryParams}).then((result) => {
        if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
          this.caseQryList = result.parentRecords;
        }
      })
      .catch((error) => {
        console.log("TECHNICAL PROP CASE QUERIES #766", error);
      });
  }


  fetchApplAsset() {
   let assetParams = {
      ParentObjectName: "ApplAsset__c",
      ChildObjectRelName: "",
      parentObjFields: ["Id","Name","Appl__c","LoanAppln__c","LoanAppln__r.Name","LoanAppln__r.BrchName__c","LoanAppln__r.Product__c","Appl__r.TabName__c",
        "FlatNo__c","APFHouse_Flat_PlotNo__c","AddrLn1__c","AddrLn2__c","City__c","Pin_Code__c","Appl__r.PhoneNumber__c",
        "Appl__r.MobNumber__c","PropType__c","PropSubType__c","CityId__c","PinId__c","State__c","Prop_Sub_TyId__c",
        "Remarks_for_Technical_Agency__c",'Prop_Owners__c','Landmark__c','AreaLocality__c','PropIdentified__c',
      'TSRECForNoYrs__c','IsTSRFiredToSameLegalVendor__c' ],
      childObjFields: [],
      queryCriteria: " where Id = '" + this._currentTabId + "' limit 1"
    };
    getSobjectDataNonCacheable({params: assetParams}).then((result) => {
        if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
          this.assetId = result.parentRecords[0].Id;
  
         this.addLine1= result.parentRecords[0].AddrLn1__c;
          this.houseNo=result.parentRecords[0].FlatNo__c;
          this.addLine2=result.parentRecords[0].AddrLn2__c;
          this.appId=result.parentRecords[0].LoanAppln__r.Name;
         this.propertyType= result.parentRecords[0].PropType__c;
          this.collId=result.parentRecords[0].Name;
          this.propIdentify = result.parentRecords[0].PropIdentified__c;
          this.city= result.parentRecords[0].City__c;
          this.state=result.parentRecords[0].State__c;
          this.landmark=result.parentRecords[0].Landmark__c;
          this.area=result.parentRecords[0].AreaLocality__c;
          this.pincode=result.parentRecords[0].Pin_Code__c;
          this.mainApp = result.parentRecords[0].Appl__r.TabName__c;
          this.appMob = result.parentRecords[0].Appl__r.MobNumber__c;
          this.appPhone = result.parentRecords[0].Appl__r.PhoneNumber__c;
          this.city = result.parentRecords[0].City__c;
          this.assetCityId = result.parentRecords[0].CityId__c;
         // this.remarks = result.parentRecords[0].Remarks_for_Technical_Agency__c;
          this.propOwners = result.parentRecords[0].Prop_Owners__c;
          this.tsrType= result.parentRecords[0].IsTSRFiredToSameLegalVendor__c;
          this.yrType= result.parentRecords[0].TSRECForNoYrs__c;
          this.prodType=result.parentRecords[0].LoanAppln__r.Product__c;
          this.brchName= result.parentRecords[0].LoanAppln__r.BrchName__c;  
          
          if(this.city){
            let agencyType='Legal';
            let tempParams = this.agencyMapParams;
            tempParams.queryCriteria =
              ' where IsActive__c = true AND LocationMaster__r.City__c  = \'' + this.city + '\' AND AgencyType__c=\''+ agencyType+'\'' ;
            this.agencyMapParams = { ...tempParams };
            //this.handleAgencyMapperIdChange();
          
            
          }
        
        }
      })
      .catch((error) => {
        console.log("TECHNICAL PROP CASE QUERIES #527", error);
      });
  }

 

  

  generatePicklist(data) {
    return data.values.map((item) => ({
      label: item.label,
      value: item.value
    }));
  }

@track accContactMap=[];

 

  fetchAgecnyLocMapper() {
    let agencyType='Legal';
    let tempParams = this.agencyMapParams;
    tempParams.queryCriteria =
      ' where IsActive__c = true AND LocationMaster__r.City__c  = \'' + this.city + '\' AND AgencyType__c includes(\''+ agencyType+'\')' ;
    this.agencyMapParams = { ...tempParams };

    getSobjectDataNonCacheable({params: this.agencyMapParams}).then((result) => {
       // this.wiredDataCaseQry=result;
        console.log("result TECHNICAL PROP AGENCY MAPPERS #884>>>>>", result);
        if (result.parentRecords !== undefined) {
          result.parentRecords.forEach((item) => {
            if(item.Account__c && item.Account__r.Name && item.Account__r.Id){
  
              let opt = { label: item.Account__r.Name, value: item.Account__r.Id };
              this.agencyOptions = [...this.agencyOptions, opt];
              this.agencyOptions.sort(this.compareByLabel); //picklist sorting
  
              let opt1 = { label: item.Account__c, value: item.Contact__c };
  
              const labelExists1 = this.accContactMap.some(option => option.label === opt1.label);
              if (!labelExists1) {
                  this.accContactMap = [...this.accContactMap, opt1];
              }
              
              this.accContactMap.sort(this.compareByLabel); //picklist sorting
                           
            }         
          });
  
          const agencyOpt = this.agencyOptions.map(({ label }) => label);
          const filtered = this.agencyOptions.filter(({ label }, index) =>
          !agencyOpt.includes(label, index + 1));
          console.log('DATA IN filtered ::::>>>>',filtered);
          let finalArr=[]
          let tempOptions2 = [...filtered];
          tempOptions2.forEach(item=>{
            if(item.label !== this.removeAgency2){
              finalArr.push(item)
              //this.agencyOptions1.push(item)
            }
          })
          this.agencyOptions1 = [...finalArr];
          this.agencyOptions2=[...finalArr];
  
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

  handlebutton(event) {

    console.log("dataname is ", event.target.dataset.name);
    let dataValue = event.target.dataset.name;
    if (dataValue === "View") {
      console.log('this.caseRecordId ==>'+this.caseRecordId);
      console.log('event.target.dataset.caseid ='+event.target.dataset.caseid);
      if(!this.caseRecordId){
        this.caseRecordId = event.target.dataset.caseid;
        console.log("caseRecordId ", this.caseRecordId);
        this.renderCaseDetails = true;
        this.showLegal=true;
      }else {
        if(this.caseRecordId === event.target.dataset.caseid){
          this.renderCaseDetails = false;
          this.showLegal=false;
          this.caseRecordId=null
        }else{
          this.caseRecordId = event.target.dataset.caseid;
          this.renderCaseDetails = true;
          this.showLegal=true;

          console.log('this.caseRecordId final =>'+this.caseRecordId);
        }
      }
    }
    if (dataValue === "Re-Intiate") {
      this.caseRecordId = event.target.dataset.caseid;
      this.cityId = event.target.dataset.cityid;
      console.log("caseRecordId ", this.caseRecordId);
      console.log("city id is ", this.cityId);
      this.noLabel = "Cancel";
      this.yesLabel = "Re-Iniate";
      this.dataName = "Re-Initiate";
      this.getcaseObjDetails(this.caseRecordId);
    }
    if (dataValue === "Cancel") {
      this.checkInitiate=false;
      this.caseRecordId = event.target.dataset.caseid;
      console.log("caseRecordId ", this.caseRecordId);
      this.noLabel = "No";
      this.yesLabel = "Cancel";
      this.dataName = "CancelCase";
      this.statusOptions = this.CancelOptions;
      this.textAreaLabel = "Reason for cancelation";
      this.getcaseObjDetails(this.caseRecordId);
      this.isReInitiateModalOpen = true;
    }
    if (dataValue === "Review") {
      this.caseRecordId = event.target.dataset.caseid;
      console.log("caseRecordId ", this.caseRecordId);
      this.reviewRemarks='';
      this.statusOptions = this.reviewOptions;
      this.noLabel = "No";
      this.yesLabel='Review';
      this.reviewSubmitLabel = "Yes";
      this.dataName = "review";
    
      this.textAreaLabel = "Reviewed By";
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
          this.statusOptions = this.reIntiateOptions;
          this.textAreaLabel = "Reason for reinitiated FI";
          this.reInitiateTechnical = true;
          //this.showAgency = true;
        } else {
        //  this.showToastMessage('Error', this.label.Technical_CaseStatus_ErrorMessage, 'error', 'sticky');
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


    }
  }

  createComment(){
    //
    let comtArr=[];
    const fields = {};
    fields[REVIEW_COMMENT_FIELD.fieldApiName] = this.reviewRemarks;
    fields[CASE_COMMENTS_FIELD.fieldApiName] = this.caseRecordId;
    fields[USER_FIELD.fieldApiName] = this.currentUserId;
    fields.sobjectType = "Comments__c";
    comtArr.push(fields);
    if(comtArr && comtArr.length>0){
      this.upsertComments(comtArr);
    }
    //
          /*
          const fields = {};
          fields[REVIEW_COMMENT_FIELD.fieldApiName] = this.reviewRemarks;
          fields[CASE_COMMENTS_FIELD.fieldApiName] = this.caseRecordId;
          fields[USER_FIELD.fieldApiName] = this.currentUserId;

          const recordInput = { apiName: COMMENTS_OBJECT.objectApiName, fields };
          console.log("fields::::: #740", fields);
          */

         
          //
         /* createRecord(recordInput)
                  .then((result) => {
                  
                  let oldFields={};
                  oldFields.sobjectType = "Case";
                  oldFields.Id = this.caseRecordId;
                  oldFields.Status = 'Review Requested';
                  oldFields.ReviewerComments__c = this.reviewRemarks;
                  this.upsertDataMethod(oldFields);
                 
                    this.showToastMessage('Success', this.label.TechnicalCaseCommentSuccess, 'success', 'sticky');
                   
                  })
                  .catch((error) => {
                    console.log("CASE COMMENTS RESULT ERRO:::::1011", error);
                   
                  });*/
          
  }
  

  upsertComments(obj){
    if(obj){   
    console.log('Comments Records create ##991', obj); 
    
    upsertMultipleRecord({ params: obj })
    .then(result => {     
      console.log('Comments Records create ##995', result);
      let oldFields={};
      oldFields.sobjectType = "Case";
      oldFields.Id = this.caseRecordId;
      oldFields.Status = 'Review Requested';
      oldFields.ReviewerComments__c = this.reviewRemarks;
      this.upsertDataMethod(oldFields);
      this.showToastMessage('Success', this.label.TechnicalCaseCommentSuccess, 'success', 'sticky');
    
      this.showSpinner=false;
      
    })
    .catch(error => {
    this.showSpinner = false;
    console.error('Line no Legal DETAILS ##2102', error)
    })
    }
    }


  @wire(getObjectInfo, { objectApiName: "Case_Query__c" })
  objInfo1;
  @wire(getPicklistValuesByRecordType, {
    objectApiName: "Case_Query__c",
    recordTypeId: "$objInfo1.data.defaultRecordTypeId"
  })
  dedupePicklistHandler({ data, error }) {
    if (data) {
      console.log("data in PicklistHandler", JSON.stringify(data));
      this.caseQrystatusOptions = [
        ...this.generatePicklist(data.picklistFieldValues.Status__c)
      ];
    }
    if (error) {
      console.error("error im getting picklist values are", error);
    }
  }

  handleValueChange(event) {
    try {
      let currentIndex = event.target.dataset.index;
      let obj = { ...this.caseQryList[event.target.dataset.index] };

      obj[event.target.dataset.fieldName] = event.target.value;
      console.log("caseQryList ///1326", JSON.stringify(this.caseQryList));
      this.caseQryList = [...this.caseQryList];
      this.caseQryList[currentIndex] = obj;

      console.log("Records ///1326", JSON.stringify(obj));
    } catch (e) {
      console.error("Error1318", e);
    }
  }

  @track deviationMstrId;
   
   



  handlePicklistValues(event) {
    let currentIndex = event.detail.index;
    let fieldName = event.detail.fieldName;
    console.log("currentIndex is #780 ", currentIndex, event.detail);
    let obj = { ...this.caseQryList[currentIndex] };

    obj[fieldName] = event.detail.val;
    //console.log('caseQryList ///1326',JSON.stringify(this.caseQryList));
    this.caseQryList = [...this.caseQryList];
    this.caseQryList[currentIndex] = obj;

    console.log("Records Pikclist #788", JSON.stringify(obj));
  }


  //UPSERT APEX

  upsertCase(obj){
    if(obj){   
    console.log('Case Document Detail Records create ##1143', obj); 
    
    upsertMultipleRecord({ params: obj })
    .then(result => {     
        const selectedEvent = new CustomEvent("select", {
            detail: true
          });
            this.dispatchEvent(selectedEvent);
            this.getCaseData();
            this.showSpinner = false;
            this.showToastMessage('Success',this.label.CaseSaveSuccess,'success','sticky')
        
    })
    .catch(error => {
        this.showSpinner = false;
        console.log(" INSIDE UPDATE RECORD ERROR>>>", error, error.body.message);
        this.showToastMessage('Error',this.label.CaseQueryRequiredFieldError,'error','sticky')
    })
  }
}


//
// this might not be using need to check later

  // handleSaveCaseQuery(){
  //   console.log("case query save called  #811",this.caseQryList);
  //   if(this._currentTabId){
  //     console.log('Curr Tab ID---'+this._currentTabId);

  //     //
  //     let caseArr=[];
  //     this.caseWrp['Id'] = this._currentTabId;
  //     this.caseWrp['Remarks_for_Technical_Agency__c']=this.remarks ? this.remarks:'';
  //     this.caseWrp.sobjectType='Case';
  //     console.log(" this.caseWrp['Id']", JSON.stringify(this.caseWrp));

  //     caseArr.push(this.caseWrp);

  //     if(caseArr){
  //       this.upsertCase(caseArr);
  //     }

  //     //
  //     /*
  //     const fields = {}
  //     fields['Id'] = this._currentTabId;
  //     fields['Remarks_for_Technical_Agency__c'] = this.remarks ? this.remarks:'';
  //     const recordInput = {fields}
  //     updateRecord(recordInput)
  //     .then(()=>{
  //       refreshApex(this.wiredPropertyAsset);
  //     })
  //     .catch(error=>{
  //         console.log('Error in update record---'+JSON.stringify(error));
  //     })
  //     */


  //   }
   
  //   upsertMultipleRecord({ params: this.caseQryList })
  //   .then((result) => {
      
  //      // this.showToastMessage('Success', this.label.Technical_CaseQueryUpdate_SuccessMessage, 'success', 'sticky');
  //       //this.dispatchEvent(evt);
  //       refreshApex(this.wiredDataCaseQry);
  //       //this.dispatchEvent(new RefreshEvent());

  //   })
  //   .catch((error) => {
  
  //     console.log("error occured in upsert #827", error);
  //     console.log("upsertDataMethod");
  //   });
    

  // }

  handleSaveThroughLms(values) {
    console.log(
      "values to save through Lms IN TECH PRO COMP #796 ",
      JSON.stringify(values)
    );

    this.handleSave(values.validateBeforeSave);
  }

  // handleSave(validate) {

  //   console.log('legal detail save');
  //   if (validate) {
  //    // this.checkInitiate=false;
  //     let isInputCorrect = this.validateForm();
      
  //     console.log("IN TECH PROP COMP if false>>> #806", isInputCorrect);

  //     if (isInputCorrect === true) {
  //       this.updateApplicantAsset();
  //      // this.handleSaveCaseQuery();
  //     }
  //       //save deviation
  //      // this.createDeviation(this.arrayDeviationInsert);
  //     // } else {

  //     //   this.showToastMessage('Error', this.label.Technical_ReqFields_ErrorMessage, 'error', 'sticky');
       
  //     // }
  //   } else {
  //     //this.handleSaveCaseQuery();
  //     this.updateApplicantAsset();
  //     //save deviation
  //     //this.createDeviation(this.arrayDeviationInsert);
  //     console.log("IN TECH PROP COMP if IN ELSE METHOD>>> #838", );
  //  }
  // }


  //

  handleSave(validate) {
    if (validate) {
     // this.checkInitiate=false;
      let isInputCorrect = this.validateForm();

      console.log("IN TECH PROP COMP if false>>> #806", isInputCorrect);

      if (isInputCorrect === true) {
        this.updateApplicantAsset();
      //  this.handleSaveCaseQuery();
      } else {

        this.showToastMessage('Error', this.label.Technical_ReqFields_ErrorMessage, 'error', 'sticky');
       
      }
    } else {
     // this.handleSaveCaseQuery();
      this.updateApplicantAsset();
      console.log("IN TECH PROP COMP if IN ELSE METHOD>>> #838", );
   }
  }//

  handleNewAgencyChange(event) {
    this.newAgencyValue = event.target.value;
    console.log("newAgencyValue ", this.newAgencyValue);
    console.log("value is ", event.target.value);
  }
  handleTextAreaChange(event) {
    this.textAreaValue = event.target.value;
    let dtname = event.target.dataset.name;
    console.log("dataName ", dtname);
    console.log("textAreaValue ", this.textAreaValue);
  }
  closeModal() {
    this.isReInitiateModalOpen = false;
    this.showAgency = false;
    this.reviewModalOpen=false;
    this.checkInitiate=false;
    this.docArr =[];
    this.accId1='';
    this.accId2='';
    this.initlabel='';
    this.popUpHeader='';
    this.remarkLabel='';
  }

  closeTecnicalModal() {
    this.initiateLegal = false;
    this.reInitiateTechnical=false;
    this.caseReinitiated=false;
    this.docArr =[];
  }
 
  handleReviewModalYesClick(){
    this.checkInitiate=false;
    let isInputCorrect = this.validateForm();

    if (isInputCorrect === true) {
    this.showSpinner = true;
    this.handleModalYesClick();
    this.getcaseObjDetails(this.caseRecordId);
    this.reviewModalOpen=false;
    this.showSpinner = false;
    } else {
      this.showSpinner = false;
      this.showToastMessage('Error', this.label.Technical_ReqFields_ErrorMessage, 'error', 'sticky');
     
    }
   
  }

  handleModalYesClick(event) {
    
   // this.showSpinner = true;
    console.log("dataname is ", event.target.dataset.name);
    if (this.caseSingleRecordData) {
      console.log("came ", this.caseSingleRecordData);
      console.log("this.yesLabel ", this.yesLabel);
      let fields = {};
      let oldFields = {};
      // fields['sobjectType'] = 'Case';
      if (this.yesLabel === "Re-Iniate") {
        fields["sobjectType"] = "Case";
        // To update Old Case record
        oldFields["Id"] = this.caseSingleRecordData.Id;
        oldFields["sobjectType"] = "Case";
        oldFields["IsReinitiated__c"] = true;
      } else if (this.yesLabel === "Cancel") {

        let isInputCorrect = this.validateForm();

        console.log("IN TECH PROP COMP if false>>> #806", isInputCorrect);
  
        if (isInputCorrect === true) {
          fields["Id"] =
          this.caseSingleRecordData.Id != null
            ? this.caseSingleRecordData.Id
            : "";
        fields["Reason_for_cancelation__c"] = this.textAreaValue;
        fields["Status"] = "Cancelled";
        this.isReInitiateModalOpen = false;
        } else {
          this.showSpinner = false;
          this.showToastMessage('Error', this.label.Technical_ReqFields_ErrorMessage, 'error', 'sticky');
         
        }
      }
      else if(this.yesLabel === "Review"){
        let isInputCorrect = this.validateForm();
        if(isInputCorrect){
          fields.Id = this.caseSingleRecordData.Id != null ? this.caseSingleRecordData.Id : "";
          if(this.textAreaValue === 'Legal Hub Manager'){
            fields.HubManagerReview__c = 'Legal Review';
        }else{
          fields.Status = "Review Requested";
        }
        
        } 
        else {
          this.showSpinner = false;
          this.showToastMessage('Error', this.label.Technical_ReqFields_ErrorMessage, 'error', 'sticky');
         
        }
      }
      console.log("this.fields for updation is ", fields);
      if(fields || oldFields){
        this.showSpinner = true;
        this.upsertDataMethod(fields);
        this.upsertDataMethod(oldFields);
      }
     
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
        
          console.log('REUSLT IN TSR #1090', JSON.stringify(result));
          console.log('this.yesLabel ==',this.yesLabel);
          
          if (this.yesLabel === "Re-Iniate") {
          
            this.showToastMessage('Success', this.label.Technical_ReInitiate_SuccessMessage, 'success', 'sticky');
          } 
          else if(this.yesLabel==='Review'){
            this.getCaseData();
            this.reviewModalOpen=false;
            this.showToastMessage('Success', this.label.Technical_CaseStatusUpdated, 'success', 'sticky');
          }
          else if(this.yesLabel==='Cancel') {
            this.yesLabel='';
            this.getCaseData();
            this.showToastMessage('Success', this.label.Technical_Cancel_SuccessMessage, 'success', 'sticky');
          }else{
            //this.showToastMessage('Success', 'Applicant Asset updated successfully', 'success', 'sticky');
          }

          let child = this.template.querySelector('c-case-details');
          child.refreshDocTable();

          this.getCaseData();
          this.getWaivedCaseData();
          this.fetchApplAsset();
          this.textAreaValue = "";
          this.newAgencyValue = "";
          this.showSpinner = false;
          this.showAgency = false;
          this.docArr =[];
          this.showSpinner = false;
        })
        .catch((error) => {
          this.showSpinner = false;
          console.log("error occured in upsert", JSON.stringify(error));
          console.log("upsertDataMethod");
        });
    }
  }

  get legalInit(){
    return this.popUpHeader === 'Inititate Legal Case' ||  this.popUpHeader === 'Re-Inititate Legal Case';
  }

  get waivedCasesAvl(){
    return this.waiveCaseFlag;
  }
@track checkInitiate=false;
@track initlabel;
@track popUpHeader;
@track remarkLabel;

  handleInitiate(event) {
    
    this.showSpinner=true;
    this.fetchAgecnyLocMapper();
    this.remarks='';
    let tempParams = this.docDetParams;
    tempParams.queryCriteria =
    ' where LAN__c = \''+ this._loanAppId + '\' AND DocTyp__c = \'' + this.filterCriteria +'\' AND ApplAsset__r.Id = \''+ this._currentTabId + '\'';
    this.docDetParams = { ...tempParams };
    this.fetchDcoumentDetails();


    if(!this.waivedCasesAvl){
      this.waiveModal=true;
      this.checkInitiate=false;  
    let title = event.target.title;
    console.log('title::::::',title);
    this.initlabel = title;
    if(this.initlabel === 'Initiate Legal'){
      this.checkInitiate=true;
      this.waiveModal=false;
      this.popUpHeader = 'Inititate Legal Case'
      this.remarkLabel='Remarks for Legal Agency';
       this.docList=[]
       this.initiateLegal=true;
      
    }
  
    if(this.initlabel === 'Waive Legal'){
      this.checkInitiate=false; 
      this.waiveModal=false;
      this.popUpHeader = 'Waive Legal Case'
      // this.remarkLabel='Reason for Waive'
      this.initiateLegal=true;

    }

    if(this.initlabel === 'Re-Intiate'){
      this.checkInitiate=true;
      this.waiveModal=false;
       this.popUpHeader = 'Re-Inititate Legal Case'
      this.caseRecordId = event.target.dataset.caseid;
      this.caseStatus = event.target.dataset.status;
      this.caseReinitiated=true;
      this.initiateLegal=true;
    }
  }else{
    this.checkInitiate=true;
    let name = event.target.name;
    console.log('title::::::1340',name);
    this.initlabel = name;
    if(this.initlabel === 'Initiate Legal'){
      this.waiveModal=false;
      this.popUpHeader = 'Inititate Legal Case'
      this.remarkLabel='Remarks for Legal Agency';
       this.docList=[]
       this.initiateLegal=true;
      
    }

    if(this.initlabel === 'Re-Intiate'){
      this.waiveModal=false;
      this.popUpHeader = 'Re-Inititate Legal Case'
      this.caseRecordId = event.target.dataset.caseid;
      this.caseStatus = event.target.dataset.status;
      this.caseReinitiated=true;
      this.initiateLegal=true;
    }
   
  }
   
  }
@track caseReinitiated=false;


  handleInputChange(event) {
    if (event.target.label === "Agency 1") {
      this.accId1 = event.target.value;
      const filteredData = this.accContactMap.find((obj) => {
        return (obj.label === this.accId1)
      });
      console.log('Agecy 1 contact',filteredData);
      if(filteredData && filteredData.value){
        this.contactId1=filteredData.value;
      }
      
      if(this.accId1===this.accId2){
          this.showToastMessage('Error', this.label.TechnicalCaseSameAgencyError, 'error', 'sticky');
          this.accId2=''
        }       
    }

    if (event.target.label === "Is TSR fired to same legal Vendor") {
        this.tsrType = event.target.value;
       
      }

      if (event.target.label === "TSR/EC for no of Yrs.") {
        this.yrType = event.target.value;
       
      }

    if (event.target.label === "Remarks for Legal Agency") {
      this.remarks = event.target.value.toUpperCase();
     
    }

    if (event.target.label === "Reviewer Remarks") {
      this.reviewRemarks = event.target.value.toUpperCase();
     
    }

    if (event.target.label === "Waiver Reason") {
      this.waiveReasonVal = event.target.value;
     
    }
    this.caseWrp = event.target.value;
    console.log("caseWrp", this.caseWrp);
  }
@track showSpinnerModal=false;
  handleCase() { 

    this.showSpinnerModal = true;
    //this.checkInitiate=false;
    this.createCase();
   
  }
  @track selectedRec;
 
  handleRowSelected(event) {
    this.docArr =[];
    const selectedRows = event.detail.selectedRows;
    // Display that fieldName of the selected rows
    for (let i = 0; i < selectedRows.length; i++) {
      //alert("You selected: " + selectedRows[i].Id);
      console.log("SELECTED ROW ID IS #328::::::", selectedRows[i].Id);
      this.selectedRec = selectedRows[i].Id;
      console.log("this.selectedRec ROW ID IS #330::::::", this.selectedRec);

      this.docArr = [...this.docArr, selectedRows[i].Id];
      this.docArr = [
        ...this.docArr.filter(
          (item, index) => this.docArr.indexOf(item) === index
        )
      ];

      //console.log(removeDuplicates(arr));
      console.log("doc array:::::: #355", this.docArr);
    }
  }

  @track recordTypeId;
  @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
  getObjectInfo({ error, data }) {
    if (data) {
      console.log("DATA in RECORD TYPE ID IN TECHINCAL PROP DET #332", data);
      for (let key in data.recordTypeInfos) {
        let recordType = data.recordTypeInfos[key];
        console.log("recordTypeId.value>>>>>", recordType.name);
        if (recordType.name === "Legal") {
          this.recordTypeId = key;
        }
        console.log("data.recordTypeId in tsr details::::1270", this.recordTypeId);
      }
    } else if (error) {
      console.error("Error fetching record type Id", error);
    }
  }

  


@track caseIDArray=[]
 
  createCase() {
    if (this.validateForm()) {
      console.log('createCase true');
      this.showSpinnerModal = true;
      try {
    
        let tempArray = [];
        let caseObj = {};

            let fields = {};
            fields.sobjectType= 'Case';
            fields.Loan_Application__c = this._loanAppId;
            //fields.City__c = this.brchCode;
            fields.RecordTypeId = this.recordTypeId;
            fields.Remarks_regarding_the_case__c = this.remarks;
            fields.Status = 'New';
            fields.Origin = 'Web';
            fields.Branch_Name__c=this.brchName;    
            fields.ApplAssetId__c = this._currentTabId;
            //fields.Property_Type__c =this.propertyType;
             fields.Main_Applicant_Name__c = this.mainApp;
             fields.Loan_Application__c = this._loanAppId;
             fields.Applicant__c =this._applicantId; 
             fields.Property_owner_Names__c = this.propOwners;
             fields.Phone_No__c = this.appPhone;
             fields.Product_Type__c=this.prodType;
            fields.Address_Line_1__c= this.addLine1;
            fields.Address_Line_2__c=this.addLine2;
            fields.State__c=this.state;
            fields.Landmark__c=this.landmark;
            fields.Area_of_Locality__c=this.area;
            fields.Mobile_No__c=this.appMob;
            fields.FlatNo__c=this.houseNo;
            fields.Pincode__c=this.pincode;
            fields.City__c= this.city;   
            

            
          if(this.initlabel==='Initiate Legal' || this.initlabel==='Re-Intiate'){
            if(this.accId1){
              fields.AccountId = this.accId1;   
              fields.ContactId = this.contactId1;
              fields.Remarks_for_Technical_Agency__c = this.remarks;
               if(this.caseStatus === 'Closed'){
                fields.IsReinitiatedExpired__c = true;
              }
    
              if(this.caseReinitiated){
                let oldFields={}
                oldFields.Id = this.caseRecordId;
                oldFields.sobjectType= "Case";
                oldFields.IsReinitiated__c = true;
                tempArray.push(oldFields);
              }
    
              tempArray.push(fields);
              console.log("fields::::: #1382", fields);
            }
          }
              
           if(this.initlabel==='Waive Legal'){
            fields.WaiveCPV__c='Yes';
            fields.Remarks_for_Technical_Agency__c = this.waiveReasonVal;
            tempArray.push(fields);
          
            console.log("fields::::: #1390", fields);
    
           } 

           
            console.log('upsert data //1535 -', JSON.stringify(tempArray))

            upsertMultipleRecord({ params: tempArray })
                .then(result => {
                  this.initiateLegal=false;
                  this.reInitiateTechnical=false;
                  this.getWaivedCaseData();
                  let arr = [...result];
                  let tempArr=[]
                    console.log('Case Created Record Created ##1571', result);
                    arr.forEach(item=>{
                      tempArr.push(item.Id)
                    })
                    this.caseIDArray= tempArr
                    console.log('Case Created Record  case Id Array ##1538',  this.caseIDArray, tempArr);
                    this.updateApplicantAsset();
                    this.disableInitiate=true;
                    this.showToastMessage('Success', this.label.Technical_CaseCreate_SuccessMessage, 'success', 'sticky');
                    this.caseReinitiated=false;
                    this.checkInitiate=false;
                    this.showSpinner = false;
                    this.showSpinnerModal = false;
                  
                    refreshApex(this.wiredData);
                    this.docArr =[];
                    this.accId1='';
                    this.accId2='';
                    this.initlabel='';
                    this.popUpHeader='';
                    this.remarkLabel='';
                    this.getCaseData();
                    
                    this.createCaseDocument();
                    this.checkInitiate=false;
                   
                    
                })
                .catch(error => {
                  this.showSpinner = false;
                  this.showSpinnerModal = false;
                  this.checkInitiate=false;
                    console.error('Line no ##1577', error)
                })


    }
     catch (e) {
        console.error('Final Error #1582', e)
    }
    }else{
      this.showSpinnerModal = false;
    }
}
  
updateApplicantAsset(){
  let fields={}
  fields.sobjectType='ApplAsset__c';
  fields.Id=this.assetId;
  fields.IsTSRFiredToSameLegalVendor__c=this.tsrType;
  fields.TSRECForNoYrs__c=this.yrType;

  if(fields){
    this.upsertDataMethod(fields);
    console.log('::::::::1574::::::::',fields);
  }

}

upsertApplAssetData(obj){
  if(obj){   
    let newArry=[];
    newArry.push(obj);  
  upsertMultipleRecord({ params: newArry })
  .then(result => {     
      this.showSpinner=false;
      
  })
  .catch(error => {
    this.showSpinner = false;
    console.error('Line no APPLICANT ASSET IN Legal DETAILS ##1514', error)
  })
}
}

  /*
  validateForm() {
    let isValid = true;
    if(this.checkInitiate){
      isValid = false;
      this.showToastMessage('Error', this.label.TechnicalCaseInitiateErrorMsg, 'error', 'sticky');
    }
    this.template.querySelectorAll("lightning-combobox").forEach((element) => {
      if (element.reportValidity()) {

      } else {
        isValid = false;
       
      }
    });*/

    get checkdoc(){
    return this.checkInitiate ;
  }



  validateForm() {
    let isValid = true;
    console.log('this.checkdo==='+this.checkdoc);
    if(this.checkdoc){
      console.log('this.checkdoc ='+this.checkdoc);
      if (this.docArr.length < 1) {
        console.log('inside check this.docArr.length');
        isValid = false;
        this.showToastMessage('Error', this.label.Technical_Doc_ErrorMessage, 'error', 'sticky');
      
      }
    }

    this.template.querySelectorAll("lightning-input").forEach((element) => {
      console.log('inside check input' +element);
      if (element.reportValidity()) {
        //console.log('element passed lightning input');
      } else {
        isValid = false;
      }
    });
    this.template.querySelectorAll("lightning-textarea").forEach((element) => {

      console.log('inside check textarea' +element);
      if (element.reportValidity()) {
        //console.log('element passed lightning input');
      } else {
        isValid = false;
      }
    });
    this.template.querySelectorAll("lightning-combobox").forEach((element) => {
      if (element.reportValidity()) {
        //console.log('element passed combobox');
        //console.log('element if--'+element.value);
      } else {
        isValid = false;
        //console.log('element else--'+element.value);
      }
    });
    console.log('return this:'+isValid);
    return isValid;
  }

  createCaseDocument() {

    //
    let caseDocDtl=[];
    this.docArr.forEach((item) => {
    this.caseIDArray.forEach(element=>{        
       const fields = {};
       fields.Case__c=element;
       fields.DocDetail__c=item;
       fields.sobjectType='CaseDoc__c'
       caseDocDtl.push(fields);
      })
    });

    console.log('caseDocDtl:::::1647',caseDocDtl);
    if(caseDocDtl && caseDocDtl.length>0){
      this.upsertDataCaseDoc(caseDocDtl);
    }
  //

  /*
      const fields = {};
      this.docArr.forEach((item) => {
      this.caseIDArray.forEach(element=>{
      fields[CASE_FIELD.fieldApiName] = element;
      fields[DOC_DET_FIELD.fieldApiName] = item;


      console.log("CASE DOCUMENT DOC_DET_FIELD:::::887", item);
      const recordInput = { apiName: CASE_DOC_OBJECT.objectApiName, fields };
      createRecord(recordInput)
        .then((result) => {
          console.log("CASE DOCUMENT RESULT:::::477", result);
          this.showToastMessage('Success', this.label.Technical_Doc_SuccessMessage, 'success', 'sticky');
       
        })
        .catch((error) => {
          console.log("CASE DOCUMENT RESULT ERRO:::::487", error);
         
        });

      })
    });
    */


  }


  upsertDataCaseDoc(obj){
    if(obj){   
    console.log('Case Document IN TSR Detail Records create ##1663', obj); 
    
    upsertMultipleRecord({ params: obj })
    .then(result => {     
        console.log('Case Document Detail Records insert for Doc Dtl TSR Details ##1659', result);
        this.showToastMessage('Success', this.label.Technical_Doc_SuccessMessage, 'success', 'sticky');
        this.showSpinner=false;
        
    })
    .catch(error => {
      this.showSpinner = false;
      console.error('Line no Legal DETAILS ##1666', error)
    })
  }
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

  //******************************* RESIZABLE COLUMNS FOR CASE TABLE *************************************//
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
    console.log("mousemove._tableThColumn => ", this._tableThColumn);
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

  showToastMessage(title, message, variant, mode) {
    const evt = new ShowToastEvent({
        title,
        message,
        variant,
        mode
    });
    this.dispatchEvent(evt);
}


}