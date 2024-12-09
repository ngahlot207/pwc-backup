import { LightningElement, track, wire, api } from "lwc";
import { createRecord,updateRecord} from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import CASE_OBJECT from "@salesforce/schema/Case";
import APPL_ASSET_OBJECT from "@salesforce/schema/ApplAsset__c";
import COMMENTS_OBJECT from "@salesforce/schema/Comments__c";

import REASON_FOR_CANCEL from "@salesforce/schema/Case.Reason_for_cancelation__c";
import REASON_FOR_REINITIATE from "@salesforce/schema/Case.Reason_for_reinitiated_FI__c";

import PROP_TYPE from "@salesforce/schema/ApplAsset__c.PropType__c";

import CASE_COMMENTS_FIELD from "@salesforce/schema/Comments__c.Case__c";
import REVIEW_COMMENT_FIELD from "@salesforce/schema/Comments__c.ReviewerComments__c";
import USER_FIELD from "@salesforce/schema/Comments__c.User__c";

import getSobjectData from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData";
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import cloneInProgPdTechCVDataMethod from "@salesforce/apex/CloneInProgPdTechCVDataController.cloneInProgPdTechCVDataMethod";
import calculatePropertyValuation from "@salesforce/apex/CasePropertyValuationController.calculatePropertyValuation";

import CASE_DOC_OBJECT from "@salesforce/schema/CaseDoc__c";
import CASE_FIELD from "@salesforce/schema/CaseDoc__c.Case__c";
import DOC_DET_FIELD from "@salesforce/schema/CaseDoc__c.DocDetail__c";
import getSobjectData1 from "@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType";
import upsertMultipleRecord from "@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord";
import getAgency from "@salesforce/apex/GetAgencyController.getAgency";
//import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
//import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
//import { RefreshEvent } from 'lightning/refresh';
import { formattedDateTimeWithoutSeconds } from 'c/dateUtility';
// Custom labels
import LOAN_AMT_Label from "@salesforce/label/c.LoanAmt";
import Technical_CaseStatus_ErrorMessage from '@salesforce/label/c.Technical_CaseStatus_ErrorMessage';
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
import LOSSAVEBUTTONDISABLE from "@salesforce/messageChannel/LosSaveButtonDisable__c";
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
export default class TechnicalPropertyDetails extends LightningElement {

  label = {
    LOAN_AMT_Label,
    Technical_CaseStatus_ErrorMessage,
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
  @track initiateTechnical;
  @track reInitiateTechnical;
  @track docList = [];
  @track showSpinner = false;
  @track currentUserId = Id;
   @track userRole;
  //label = { LOAN_AMT_Label };
  @api hasEditAccess;
  @track disableMode = false;
  @track disableAgency1;
  @track _currentTabId;
  @track colProp;
  @track propType;
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
  @track noOfCaseNeedToRaise;
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
  @track propOptions=[];
  @track clonedFor;
  agencyOptions = [];
  agencyOptions1 = [];
  agencyOptions2 = [];

  //@api cpvRecordTypeId;
  @track caseRecordsData = [];
 
  @track caseData;
  enableInfiniteScrolling = true;
  enableBatchLoading = true;

  @track renderCaseDetails = false;
  //@track showTechincal= false;
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
  @track disbursType
  subscription;

  @api get currentTabId() {
    return this._currentTabId;
  }
  set currentTabId(value) {
    this._currentTabId='';
    this._currentTabId = value;
    this.setAttribute("currentTabId", value);

    this.handleRecordIdChange(value);
    this.handleCaseQueryIdChange(value);
    //  this.handleCaseRecordIdChange(value);
    this.handleteamHierIdChange();
  }
  @track _loanAppId;
  @api get loanAppId() {
    return this._loanAppId;
  }
  set loanAppId(value) {
    this._loanAppId = value;
    this.setAttribute("loanAppId", value);
    this.handleLoanRecordIdChange();
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

  // sunscribeToMessageChannel() {
  //   this.subscription = subscribe(
  //     this.MessageContext,
  //     SaveProcessCalled,
  //     (values) => this.handleSaveThroughLms(values)
  //   );
  // }

  get agency2Visible() {
   // return this.loanAmount > this.label.LOAN_AMT_Label;
   return this.noOfCaseNeedToRaise > 1 && this.extraCaseToRaise <1 && this.agecnyFlag===true;
    
  }

  get disableInitiateTechnical(){
    return this.disableMode || this.disableInitiate;
  }

  get reviewOptions(){
    let opt=[];
    if(this.userRole !== 'THM'){
  opt=[{ label: 'Technical Hub Manager', value: 'Technical Hub Manager' },
       { label: 'Agency', value: 'Agency' }]
    }
  else{
    opt=[ { label: 'Agency', value: 'Agency' } ]
  }
    return opt;
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
 
  
  @track teamHierParam = {
    ParentObjectName: 'TeamHierarchy__c',
    ChildObjectRelName: '',
    parentObjFields: ['Id','EmpRole__c','Employee__c'],
    childObjFields: [],
    queryCriteria: ''
    }

  @track
  assetParams = {
    ParentObjectName: "ApplAsset__c",
    ChildObjectRelName: "",
    parentObjFields: [
      "Id",
      "Name",
      "Appl__c",
      "LoanAppln__c",
      "Appl__r.TabName__c",
      "FlatNo__c",
      "APFHouse_Flat_PlotNo__c",
      "AddrLn1__c",
      "AddrLn2__c",
      "City__c",
      "Pin_Code__c",
      "Appl__r.PhoneNumber__c",
      "Appl__r.MobNumber__c",
      "PropType__c",
      "PropSubType__c",
      "CityId__c",
      "PinId__c",
      "State__c",
      "Prop_Sub_TyId__c",
      "Remarks_for_Technical_Agency__c",
      'Prop_Owners__c',
      'Landmark__c',
      'AreaLocality__c',
      'NoOfCasesRaised__c',
      'ExtraCaseNeedToBeRaised__c',
      'TotalNoOfCasesNeedToRaised__c',
      'RerunRequired__c'
    ],
    childObjFields: [],
    queryCriteria: ""
  };

  
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
    queryCriteria: " where DocTyp__c ='" + this.filterCriteria + "'"
  };

  @track
  loanDetParams = {
    ParentObjectName: "LoanAppl__c",
    ChildObjectRelName: "",
    parentObjFields: ["Id", "ClonedFor__c","Name", "ReqLoanAmt__c","NoCasesNeedToRaised__c","OwnerId","Stage__c","SubStage__c","DisbursalType__c"],
    childObjFields: [],
    queryCriteria: ""
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
    console.log('handle value change called #322')
  }

  handleRecordIdChange() {
    let tempParams = this.assetParams;
    tempParams.queryCriteria =
      " where Id = '" + this._currentTabId + "' limit 1";
    this.assetParams = { ...tempParams };
  }


  // handleAgencyMapperIdChange() {
  //   let agencyType='Technical';
  //   let tempParams = this.agencyMapParams;
  //   tempParams.queryCriteria =
  //   //  " where LocationMaster__r.City__c = '" + this.city + "' AND AgencyType__c = ";
  //     ' where LocationMaster__r.City__c  = \'' + this.city + '\' AND AgencyType__c=\''+ agencyType+'\'' ;
  //   this.agencyMapParams = { ...tempParams };
  //   this.fetchAgecnyLocMapper();
  // }

  handleLoanRecordIdChange() {
    let tempParams = this.loanDetParams;
    tempParams.queryCriteria = " where Id = '" + this._loanAppId + "' limit 1";
    this.loanDetParams = { ...tempParams };
    this.fetchLoanDetails();
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
    console.log('childEvt in techncial component::::#434',childEvt );
    this.getCaseData();

}   


  connectedCallback() {
    this.activeSection = ["A"];
    
    if (this.hasEditAccess === false) {
      this.disableMode = true;
    }

    console.log("asset prop _applicantId", this._applicantId, this.hasEditAccess);
  
     this.fetchApplAsset();
    
    refreshApex(this.wiredData);
      refreshApex(this.wiredDataCaseQry);
      refreshApex(this.wiredApplAsset);
      refreshApex(this.wiredAgencyMapper);
   // this.sunscribeToMessageChannel();
  }

disconnectedCallback() {
    this.unsubscribeMC();
    releaseMessageContext(this.context);
}
unsubscribeMC() {
    unsubscribe(this.subscription);
    this.subscription = null;
}

  @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
  objInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$objInfo.data.defaultRecordTypeId",
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
    recordTypeId: "$objInfo.data.defaultRecordTypeId",
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
  generatePicklist(data) {
    return data.values.map((item) => ({
      label: item.label,
      value: item.value
    }));
  }

  handleteamHierIdChange() {
    let tempParams = this.teamHierParam;
    tempParams.queryCriteria = ' where Employee__c = \'' + this.currentUserId + '\' limit 1' ;
    this.teamHierParam = { ...tempParams };

}

  @wire(getSobjectData,{params : '$teamHierParam'})
  teamHierHandler({data,error}){
      if(data){
          if(data.parentRecords !== undefined ){
              this.userRole = data.parentRecords[0].EmpRole__c   
              if(this.userRole==='THM'){
                const payload = {
                  disableSaveButton: false
              };
              console.log(" Published Event>", JSON.stringify(payload));
              publish(this.MessageContext, LOSSAVEBUTTONDISABLE, payload);
              }
          }
                    
      }
      if(error){
          console.error('ERROR CASE DETAILS:::::::#499',error)
      }
  }


  @wire(getObjectInfo, { objectApiName: APPL_ASSET_OBJECT })
  objInfo1;

  @wire(getPicklistValues, {
    recordTypeId: "$objInfo1.data.defaultRecordTypeId",
    fieldApiName: PROP_TYPE
  })
  propertyTypeHandler({ data, error }) {
    if (data) {
      this.propOptions = [...this.generatePicklist(data)];
    }
    if (error) {
      console.log(error);
    }
  }

@track caseCounter=false;
@track count =0
  @track wiredData = {};
@track removeAgency2;
  @api getCaseData() {
    console.log("loanappId in Reintiate component", this.loanAppId);
    let recordType='Technical';
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
        'Property_Built_up_area_Sq_Ft__c',
        'Land_Area_Sq_Ft__c',
        'Built_up_area_Valuation_In_Rs__c',
        'Total_Valuation_Land_Valuation_B__c',
        'Land_Valuation_in_Rs__c',
        'Approx_Age_of_Property_in_Years__c',
        'Residual_Age_in_Years__c',
        'ReviewerComments__c',
        'ExpiryDate__c',
        'IsReinitiatedExpired__c',
        'HubManagerReview__c'


      ],

        queryCriteria:' where AccountId != null AND RecordType.DeveloperName = \''+recordType+ '\' AND ApplAssetId__c = \'' + this._currentTabId + '\'order by createdDate asc'
    };
    getSobjectData1({ params: paramsLoanApp }).then((result) => {
      this.caseData = result;
      this.caseRecordsData = [];
      this.fetchApplAsset();
      if (
        result.parentRecords !== undefined &&
        result.parentRecords.length > 0
      ) {
        result.parentRecords.forEach((item, index) => {
          if (item.Status === "Closed" || item.Status === "Cancelled") {
            item.isCanDis = true;
           
            // if (item.IsReinitiated__c === false) {
            //   item.isReinitDis = this.hasEditAccess===false?true:false;
            // } else {
            //   item.isReinitDis = this.hasEditAccess===false?true:true;
            // }
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
          // if( item.Status === 'New' || item.Status === 'In Progress' || item.Status === 'Query' || item.Status === 'Review Requested' || item.IsReinitiated__c === true){
          //     item.isReinitDis = true;
          //    }else{
          //     item.isReinitDis = this.hasEditAccess===true?false:true
          //    }
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

        //  if( item.Status === 'New' || item.Status === 'Cancelled'|| item.Status === 'Query'){
          
          if( item.Status === 'Closed'){
            this.count++
              //item.isReviewDis = this.hasEditAccess===true?false:true;
             }
             else{
              //item.isReviewDis = true;
             }
             if(this.count >= 2){
              this.caseCounter=true;
             }
             if(item.Status === 'Review Requested'){
              item.reviewReq = true;
             }else{
              item.reviewReq = false;
             }
             if(item.HubManagerReview__c === 'Technical Review'){
              item.legalReviewReq = true;
             }else{
              item.legalReviewReq = false;
             }
             if( item.Status === 'Closed' && item.HubManagerReview__c !== 'Technical Review'){
              item.isReviewDis = this.hasEditAccess===true?false:true;
             }
             else{
              item.isReviewDis = true;
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

  get caseId() {
    return `${this.caseRecordId}`;
  }
  get newAgencyOpts() {
    return `${this.newAgencyOptions}`;
  }
  get disableModeAgency1(){
    return this.disableMode || this.disableAgency1;
  }

  get showRerunVal(){
    return this.userRole !== 'CPA' ;
}

get disableRerun(){
    return this.rerunDisable;
}
handleRerunVal(){

  this.RerunValuation();
}

RerunValuation(){
  calculatePropertyValuation({applicantAssetId: this.assetId}).then((result) => {

   console.log("result TECHNICAL Rerun Valuation #627>>>>>", result);
   if(result !== null){
      this.rerunDisable=true;
      this.showToastMessage('Success',this.label.TechnicalRerunValSuccess,'success','sticky')
   }else{
      this.rerunDisable=true;
      console.log("result NULL in TECHNICAL Rerun Valuation #692>>>>>");
    //  this.showToastMessage('Error','Case Valuation is higher than Property Valuation','error','sticky')
   }
  
 })
 .catch((error) => {
   console.log("TECHNICAL Rerun Valuation #631", error);
 });
}

 
  @track wiredAgencyMapper;
  @track wiredPropertyAsset;


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
    getSobjectDataNonCacheable({params: this.loanDetParams}).then((result) => {
       // this.wiredDataCaseQry=result;
        console.log("result TECHNICAL PROP LOAN DETAILS #722>>>>>", result);
        if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
          this.loanAmount = result.parentRecords[0].ReqLoanAmt__c;
          this.noOfCaseNeedToRaise=result.parentRecords[0].NoCasesNeedToRaised__c;
          this.lanOwner = result.parentRecords[0].OwnerId;
          this.lanStage = result.parentRecords[0].Stage__c;
          this.lanSubStage = result.parentRecords[0].SubStage__c;
          this.disbursType= result.parentRecords[0].DisbursalType__c;
          this.clonedFor = result.parentRecords[0].ClonedFor__c;
          this.getCaseData();
        }
      })
      .catch((error) => {
        console.log("TECHNICAL PROP LOAN DETAILS #731", error);
      });
  }

get showCloneButton(){
  if(this.clonedFor){
    return true;
  }
  return false;
}
handleCloneMethod(){
  this.showSpinner = true;
        let inputData = {
          loanAppId: this._loanAppId,
          cloneFor: 'Technical',
          appAssetId: this.assetId
        }
        if(inputData){
          cloneInProgPdTechCVDataMethod({inputData: inputData}).then((result) => {
            // this.wiredDataCaseQry=result;
             console.log("result after cloning TECHNICAL DETAILS >>>>>", result);
             if(result && result === 'Success'){
              this.showToastMessage('Success','Technical Cases cloned Successfully','success','sticky')
             }else if(result && result === 'error'){
              this.showToastMessage('Error','No Technical Cases to clone','error','sticky')
             }
             this.showSpinner = false;
           })
           .catch((error) => {
            this.showSpinner = false;
             console.log("Error in cloning TECHNICAL DETAILS==>>>", error);
           });
        }else{
          this.showSpinner = false;
        }
 
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

@track wiredDataCaseQry={};
  fetchApplAsset() {
    getSobjectDataNonCacheable({params: this.assetParams}).then((result) => {
        if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
          this.assetId = result.parentRecords[0].Id;
  
         this.addLine1= result.parentRecords[0].AddrLn1__c;
          this.houseNo=result.parentRecords[0].FlatNo__c;
          this.addLine2=result.parentRecords[0].AddrLn2__c;
          this.propType=result.parentRecords[0].PropType__c;
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
          this.remarks = result.parentRecords[0].Remarks_for_Technical_Agency__c;
          this.propOwners = result.parentRecords[0].Prop_Owners__c;
          this.extraCaseToRaise=result.parentRecords[0].ExtraCaseNeedToBeRaised__c ? result.parentRecords[0].ExtraCaseNeedToBeRaised__c: 0;
          this.noOfCaseRaised=result.parentRecords[0].NoOfCasesRaised__c ? result.parentRecords[0].NoOfCasesRaised__c : 0;
          this.totalCaseRaised=result.parentRecords[0].TotalNoOfCasesNeedToRaised__c;
          this.rerunFlag=result.parentRecords[0].RerunRequired__c;

           
          if(this.totalCaseRaised - this.noOfCaseRaised  === 0){
            //1-1 = 0 initeateTechnicalButton Disabled
            if((this.currentUserId === this.lanOwner) && (this.lanStage === 'Disbursed' && (this.lanSubStage === 'Additional Processing' || this.lanSubStage === 'UW Approval')) && this.disbursType==='MULTIPLE' ){
              this.disableInitiate=false;
              this.disableMode=false;
              const payload = {
                disableSaveButton: false
            };
            console.log(" Published Event>", JSON.stringify(payload));
            publish(this.MessageContext, LOSSAVEBUTTONDISABLE, payload);
            
            }	else{
              this.disableInitiate=true;
            }
            
            }else if(this.totalCaseRaised - this.noOfCaseRaised === 2){
              this.agecnyFlag= true;
            
            }else if(this.totalCaseRaised - this.noOfCaseRaised === 1){
              this.agecnyFlag= false;
              if(this.caseCounter){
                this.checkInitiate=true;
              }
            }

          if(this.rerunFlag){
            this.rerunDisable=true;
          }
      
          if(this.city){
            let agencyType='Technical';
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
    let agencyType='Technical';
    let tempParams = this.agencyMapParams;
    tempParams.queryCriteria =
      ' where IsActive__c = true AND LocationMaster__r.City__c  = \'' + this.city + '\' AND AgencyType__c=\''+ agencyType+'\'' ;
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
  get showTechincal(){
    return this.renderCaseDetails;
  }

  handlebutton(event) {
    this.renderCaseDetails = false;
    console.log("dataname is ", event.target.dataset.name);
    let dataValue = event.target.dataset.name;
    if (dataValue === "View") {
      
      if(!this.caseRecordId){
        this.caseRecordId = event.target.dataset.caseid;
        console.log("caseRecordId ", this.caseRecordId);
        this.renderCaseDetails = true;
      }else {
        if(this.caseRecordId === event.target.dataset.caseid){
          this.renderCaseDetails = false;
          this.caseRecordId=null
        }else{
          this.caseRecordId = event.target.dataset.caseid;
          this.renderCaseDetails = true;
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
      this.noLabel = "No";
      this.yesLabel='Review';
      this.reviewSubmitLabel = "Yes";
      this.dataName = "review";
      this.statusOptions = this.reviewOptions;
      this.textAreaLabel = "Reviewed By";
    //  this.getcaseObjDetails(this.caseRecordId);
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
          this.getNewAgency();
          this.statusOptions = this.reIntiateOptions;
          this.textAreaLabel = "Reason for reinitiated FI";
          this.reInitiateTechnical = true;
          //this.showAgency = true;
        } else {
          this.showToastMessage('Error', this.label.Technical_CaseStatus_ErrorMessage, 'error', 'sticky');
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


  createComment(){
          let comtArr=[];
          const fields = {};
          fields[REVIEW_COMMENT_FIELD.fieldApiName] = this.reviewRemarks;
          fields[CASE_COMMENTS_FIELD.fieldApiName] = this.caseRecordId;
          fields[USER_FIELD.fieldApiName] = this.currentUserId;
          fields.sobjectType = "Comments__c";
          comtArr.push(fields);
          if(comtArr && comtArr.length>0){
            this.upsertCaseComment(comtArr);
          }

          // const recordInput = { apiName: COMMENTS_OBJECT.objectApiName, fields };
          // console.log("fields::::: #740", fields);
          // createRecord(recordInput)
          //         .then((result) => {
                               
          //         })
          //         .catch((error) => {
          //           console.log("CASE COMMENTS RESULT ERRO:::::1011", error);
                   
          //         });
          
  }

  upsertCaseComment(obj){
    if(obj){   
    console.log('Comments Records create ##2263', obj); 
    
    upsertMultipleRecord({ params: obj })
    .then(result => {     
        console.log('Comments Records create ##3367', result);
        let oldFields={};
        oldFields.sobjectType = "Case";
        oldFields.Id = this.caseRecordId;
        if(this.textAreaValue === 'Technical Hub Manager'){
          oldFields.HubManagerReview__c = 'Technical Review';
          }else{
            oldFields.Status = "Review Requested";
          }
        // oldFields.Status = 'Review Requested';
        oldFields.ReviewerComments__c = this.reviewRemarks;
        this.upsertDataMethod(oldFields);
        this.showToastMessage('Success', this.label.TechnicalCaseCommentSuccess, 'success', 'sticky');

        this.showSpinner=false;
        
    })
    .catch(error => {
      this.showSpinner = false;
      console.error('Line no RCU DETAILS ##2102', error)
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
      console.log(
        "data in  this.caseQrystatusOptions",
        this.caseQrystatusOptions
      );
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

// this might not be using need to check later
  handleSaveCaseQuery(){
    console.log("case query save called  #811",this.caseQryList);
    // if(this._currentTabId){
    //   console.log('Curr Tab ID---'+this._currentTabId);
    //   const fields = {}
    //   fields['Id'] = this._currentTabId;
    //   fields['Remarks_for_Technical_Agency__c'] = this.remarks;
    //   const recordInput = {fields}
    //   updateRecord(recordInput)
    //   .then(()=>{
    //     refreshApex(this.wiredPropertyAsset);
    //   })
    //   .catch(error=>{
    //       console.log('Error in update record---'+JSON.stringify(error));
    //   })
    // }
   
    upsertMultipleRecord({ params: this.caseQryList })
    .then((result) => {
      
       // this.showToastMessage('Success', this.label.Technical_CaseQueryUpdate_SuccessMessage, 'success', 'sticky');
        //this.dispatchEvent(evt);
        refreshApex(this.wiredDataCaseQry);
        //this.dispatchEvent(new RefreshEvent());

    })
    .catch((error) => {
  
      console.log("error occured in upsert #827", error);
      console.log("upsertDataMethod");
    });
    

  }

  // handleSaveThroughLms(values) {
  //   console.log(
  //     "values to save through Lms IN TECH PRO COMP #796 ",
  //     JSON.stringify(values)
  //   );

  //   this.handleSave(values.validateBeforeSave);
  // }

  // handleSave(validate) {
  //   if (validate) {
  //    // this.checkInitiate=false;
  //     let isInputCorrect = this.validateForm();

  //     console.log("IN TECH PROP COMP if false>>> #806", isInputCorrect);

  //     if (isInputCorrect === true) {
  //       this.handleSaveCaseQuery();
  //     } else {

  //      // this.showToastMessage('Error', this.label.Technical_ReqFields_ErrorMessage, 'error', 'sticky');
       
  //     }
  //   } else {
  //     this.handleSaveCaseQuery();
  //     console.log("IN TECH PROP COMP if IN ELSE METHOD>>> #838", );
  //  }
  // }

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
    this.docArr =[];
  }

  closeTecnicalModal() {
    this.initiateTechnical = false;
    this.reInitiateTechnical=false;
    this.caseReinitiated=false;
    this.docArr =[];
  }
 
  handleReviewModalYesClick(){
    this.checkInitiate=false;
    let isInputCorrect = this.validateForm();

    if (isInputCorrect === true) {
    this.showSpinner = true;   
    this.createComment();
    this.reviewModalOpen=false;
    this.showSpinner = false;
    } else {
      this.showSpinner = false;
      this.showToastMessage('Error', this.label.Technical_ReqFields_ErrorMessage, 'error', 'sticky');
     
    }
   
  }

  handleModalYesClick(event) {
    
    this.showSpinner = true;
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
        
          console.log('REUSLT IN TECHNCIAL #1324', JSON.stringify(result));
          
          if (this.yesLabel === "Re-Iniate") {
          
            this.showToastMessage('Success', this.label.Technical_ReInitiate_SuccessMessage, 'success', 'sticky');
          } 
          else if(this.yesLabel==='Review'){
            this.getCaseData();
            this.showToastMessage('Success', this.label.Technical_CaseStatusUpdated, 'success', 'sticky');
          }
          else if(this.yesLabel==='Cancel') {
            this.yesLabel='';
            this.getCaseData();
            this.showToastMessage('Success', this.label.Technical_Cancel_SuccessMessage, 'success', 'sticky');
          }else{
           // this.showToastMessage('Success', 'Applicant Asset updated successfully', 'success', 'sticky');
          }

          let child = this.template.querySelector('c-case-details');
          child.refreshDocTable();

          this.getCaseData();
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

@track checkInitiate=false;
  handleInitiate(event) {
   // this.checkInitiate=true;
   this.showSpinner=true;
   this.fetchAgecnyLocMapper();
    this.remarks='';
    console.log("HANDLE INdocDetParamsITIATE CALLED");
    this.docList=[]
    let tempParams = this.docDetParams;
    tempParams.queryCriteria =
    ' where LAN__c = \''+ this._loanAppId + '\' AND DocTyp__c = \'' + this.filterCriteria +'\' AND ApplAsset__r.Id = \''+ this._currentTabId + '\'';
    this.docDetParams = { ...tempParams };
    this.fetchDcoumentDetails();
    // this.docList = this.allData;
    // console.log('DATA IN DCOUMENT this.docList ::::>>>>',this.docList);
    //this.docDetParams.queryCriteria = ' where LAN__c = \'' + this._loanAppId + '\''
    this.initiateTechnical = true;
  }
@track caseReinitiated=false;
  handleReInitiate(event) {
  //  this.checkInitiate=true;
  this.fetchAgecnyLocMapper();
    this.remarks='';
    this.caseRecordId = event.target.dataset.caseid;
    this.caseStatus = event.target.dataset.status
    console.log("HANDLE INdocDetParamsITIATE CALLED",this.caseStatus);
    this.docList=[]
    let tempParams = this.docDetParams;
    tempParams.queryCriteria =
    ' where LAN__c = \''+ this._loanAppId + '\' AND DocTyp__c = \'' + this.filterCriteria +'\' AND ApplAsset__r.Id = \''+ this._currentTabId + '\'';
    this.docDetParams = { ...tempParams };
    this.fetchDcoumentDetails();
    this.caseReinitiated=true;
    this.reInitiateTechnical = true;
  }

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
    if (event.target.label === "Agency 2") {
      this.accId2 = event.target.value;
      const filteredData2 = this.accContactMap.find((obj) => {
        return (obj.label === this.accId2)
      });
      console.log('Agenct 2 contact',filteredData2);
      if(filteredData2 && filteredData2.value){
        this.contactId2=filteredData2.value;
      }
     
      if(this.accId1===this.accId2){
        this.showToastMessage('Error', this.label.TechnicalCaseSameAgencyError, 'error', 'sticky');
        this.accId1=''
      } 
     
    }
    if (event.target.label === "Remarks for Technical Agency") {
      this.remarks = event.target.value.toUpperCase();
     
    }

    if (event.target.label === "Reviewer Remarks") {
      this.reviewRemarks = event.target.value.toUpperCase();
     
    }

   
    this.caseWrp = event.target.value;
    console.log("caseWrp", this.caseWrp);
  }
@track showSpinnerModal=false;
  handleCase() { 
    this.showSpinnerModal = true;
    this.checkInitiate=false;
    this.createCase();
   
  }
  @track selectedRec;
  @track docArr = [];
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
        if (recordType.name === "Technical") {
          this.recordTypeId = key;
        }
        console.log("data.recordTypeId", key);
      }
    } else if (error) {
      console.error("Error fetching record type Id", error);
    }
  }

  


@track caseIDArray=[]
 
  createCase() {
    if (this.validateForm()) {
      this.showSpinnerModal = true;
      try {
    
        let tempArray = [];
        let caseObj = {};

      //  for (let i = 0; i < this.docArr.length; i++) {
          if(this.accId1){
            caseObj = {};
            caseObj.sobjectType = 'Case';
            caseObj.RecordTypeId = this.recordTypeId;
            caseObj.AccountId = this.accId1;
            caseObj.ContactId = this.contactId1;
            caseObj.Status = "New";
            caseObj.Origin = "Web";
            caseObj.Main_Applicant_Name__c = this.mainApp;
            caseObj.Loan_Application__c = this._loanAppId;
            caseObj.Applicant__c =this._applicantId; 
            caseObj.Property_Owner_s_as_per_Technical_Repo__c = this.propOwners;
            caseObj.Phone_No__c = this.appPhone;
            caseObj.ApplAssetId__c = this._currentTabId;
            caseObj.Remarks_for_Technical_Agency__c = this.remarks;
            caseObj.CityId__c = this.assetCityId;

            if(this.caseStatus === 'Closed'){
              caseObj.IsReinitiatedExpired__c = true;
            }

            if(this.caseReinitiated){
              let oldFields={}
              oldFields.Id = this.caseRecordId;
              oldFields.sobjectType= "Case";
              oldFields.IsReinitiated__c = true;
              tempArray.push(oldFields);
            }

            tempArray.push(caseObj);
            //fields[RECORD_TYPE_FIELD.fieldApiName] = 'LoanAppl__c';
            console.log("fields::::: #740", caseObj);
          }
          if(this.accId2){
            caseObj = {};
            caseObj.sobjectType = 'Case';
            caseObj.RecordTypeId = this.recordTypeId;
            caseObj.AccountId = this.accId2;
            caseObj.ContactId = this.contactId2;
            caseObj.Status = "New";
            caseObj.Origin = "Web";
            caseObj.Main_Applicant_Name__c = this.mainApp;
            caseObj.Loan_Application__c = this._loanAppId;
            caseObj.Applicant__c =this._applicantId; 
            caseObj.Property_Owner_s_as_per_Technical_Repo__c = this.propOwners;
            caseObj.Phone_No__c = this.appPhone;
            caseObj.ApplAssetId__c = this._currentTabId;
            caseObj.Remarks_for_Technical_Agency__c = this.remarks;
            caseObj.CityId__c = this.assetCityId;
            tempArray.push(caseObj);
            //fields[RECORD_TYPE_FIELD.fieldApiName] = 'LoanAppl__c';
            console.log("fields::::: #740", caseObj);
          }
           
       // }
            console.log('upsert data //1535 -', JSON.stringify(tempArray))

            upsertMultipleRecord({ params: tempArray })
                .then(result => {
                  this.initiateTechnical=false;
                  this.reInitiateTechnical=false;
                 
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
                    this.accId1='';
                    this.accId2='';
                    this.getCaseData();
                    this.createCaseDocument();
                   
                    
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
  console.log('::::::::1694::::::::this.noOfCaseNeedToRaise',this.noOfCaseNeedToRaise);
  fields.NoOfCasesRaised__c= this.noOfCaseNeedToRaise + this.extraCaseToRaise ;

  if(fields){
    this.upsertDataMethod(fields);
    console.log('::::::::1444::::::::',fields);
  }

}

  validateForm() {
    let isValid = true;
    // if(this.checkInitiate){
    //   if (this.docArr.length < 1) {
    //     isValid = false;
    //     this.showToastMessage('Error', this.label.Technical_Doc_ErrorMessage, 'error', 'sticky');
      
    //   }
    // }
   
    if(this.checkInitiate){
      isValid = false;
      this.showToastMessage('Error', this.label.TechnicalCaseInitiateErrorMsg, 'error', 'sticky');
    }
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

  createCaseDocument() {
    
   
    let caseDocDtl=[];
      this.docArr.forEach((item) => {
      this.caseIDArray.forEach(element=>{        
         const fields = {};
         fields.Case__c=element;
         fields.DocDetail__c=item;
         fields.sobjectType='CaseDoc__c'
         caseDocDtl.push(fields);
      // console.log("CASE DOCUMENT DOC_DET_FIELD:::::887", item);
      // const recordInput = { apiName: CASE_DOC_OBJECT.objectApiName, fields };
      // createRecord(recordInput)
      //   .then((result) => {
      //     console.log("CASE DOCUMENT RESULT:::::477", result);
      //     this.showToastMessage('Success', this.label.Technical_Doc_SuccessMessage, 'success', 'sticky');
       
      //   })
      //   .catch((error) => {
      //     console.log("CASE DOCUMENT RESULT ERRO:::::487", error);
         
      //   });

})
    });

    console.log('caseDocDtl:::::1638',caseDocDtl);
    if(caseDocDtl && caseDocDtl.length>0){
      this.upsertDataCaseDoc(caseDocDtl);
    }
  }

  upsertDataCaseDoc(obj){
    if(obj){   
    console.log('Case Document Detail Records create ##1649', obj); 
    
    upsertMultipleRecord({ params: obj })
    .then(result => {     
        console.log('Case Document Detail Records insert for Doc Dtl Technical Details ##1653', result);
        this.showToastMessage('Success', this.label.Technical_Doc_SuccessMessage, 'success', 'sticky');
        this.showSpinner=false;
        
    })
    .catch(error => {
      this.showSpinner = false;
      console.error('Line no TECHNICAL DETAILS ##1660', error)
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