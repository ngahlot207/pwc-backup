//export default class RcuDetails extends LightningElement {}
import { LightningElement, track, wire, api } from "lwc";
import { createRecord,updateRecord} from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import CASE_OBJECT from "@salesforce/schema/Case";

import COMMENTS_OBJECT from "@salesforce/schema/Comments__c";
import DOC_DETL_OBJECT from "@salesforce/schema/DocDtl__c";

import REASON_FOR_CANCEL from "@salesforce/schema/Case.Reason_for_cancelation__c";


import CASE_COMMENTS_FIELD from "@salesforce/schema/Comments__c.Case__c";
import REVIEW_COMMENT_FIELD from "@salesforce/schema/Comments__c.ReviewerComments__c";
import USER_FIELD from "@salesforce/schema/Comments__c.User__c";

import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData'; 

import getSobjectData1 from "@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType";
import upsertMultipleRecord from "@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord";
import getAllSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataWithoutCacheable';

import { formattedDateTimeWithoutSeconds } from 'c/dateUtility';
// Custom labels
import Technical_ReInitiate_SuccessMessage from '@salesforce/label/c.Technical_ReInitiate_SuccessMessage';
import Technical_ReqFields_ErrorMessage from '@salesforce/label/c.Technical_ReqFields_ErrorMessage';
import Technical_Cancel_SuccessMessage from '@salesforce/label/c.Technical_Cancel_SuccessMessage';
import Technical_Doc_ErrorMessage from '@salesforce/label/c.Technical_Doc_ErrorMessage';
import TechnicalCaseCommentSuccess from '@salesforce/label/c.TechnicalCaseCommentSuccess';
import Technical_CaseStatusUpdated from '@salesforce/label/c.Technical_CaseStatusUpdated';
import TechnicalCaseInitiateErrorMsg from '@salesforce/label/c.TechnicalCaseInitiateErrorMsg';
import RolesRCUManager from '@salesforce/label/c.RolesRCUManager';

import rcuDetailsVerifier from "./rcuDetailsVerifier.html";
import rcuDetails from "./rcuDetails.html";

//import getAllSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import {
  subscribe,
  publish,
  MessageContext,
  unsubscribe,
  releaseMessageContext
} from "lightning/messageService";

import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import { refreshApex } from "@salesforce/apex";
import Id from "@salesforce/user/Id";

export default class RcuDetails extends LightningElement {
  label = {
    Technical_ReInitiate_SuccessMessage,
    Technical_ReqFields_ErrorMessage,
    Technical_Cancel_SuccessMessage,
    Technical_Doc_ErrorMessage,
    TechnicalCaseCommentSuccess,
    Technical_CaseStatusUpdated,
    TechnicalCaseInitiateErrorMsg,
    RolesRCUManager

  }
  @track disableInitiate=false;
  @track initiateRcu;
  @track reInitiateTechnical;
  @track docList = [];
  @track delDocList=[];
  @track appList=[];
  @track rcuMangerRoles=[];
  @track showSpinner = false;
  @track currentUserId = Id;
   @track userRole;
   @track managerView;
  @api hasEditAccess;
  @track disableAgency1;
  @track _currentTabId;
  @track colProp;

 @track brchCode;
  @track branchName;
  @track branchCity;
  @track mainApp;
  @track loanAmount;
  @track loanRCUStatus;
  @track loanRCUStatusReason;
  @track filterCriteria = "Property Papers";
  @track city;

  @track caseWrp = {};
  @track remarks;
  @track reviewRemarks;
  @track finalRCURemark;
  @track newCaseId;
  //@track caseId; // For view Agency case Table
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

  @track loanRCUStatusOptions=[];
  @track loanRCUStatusReasonOptions=[];

  //@api cpvRecordTypeId;
  @track caseRecordsData = [];
  @track caseAgencyData=[];
 
  @track caseData;
  enableInfiniteScrolling = true;
  enableBatchLoading = true;

  @track renderCaseDetails = false;
  @track showTSR= false;
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
  @track lanProd;


  @track openCaseOwner;
  @track openCaseId;
  rcuStatOptions=[];
  vendorVerfOptions=[];


  @track selectedRec;
  @track docArr = [];
  @track showSpinnerModal=false;
  @track profCheckDocDtl=[];
  @track recordTypeId;

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

get rcuManager(){
  return this.managerView;
}

get initVerfRcuProfile(){
  return this.lanProd==='Business Loan' || this.lanProd ==='Personal Loan' || this.lanProd==='Loan Against Property'
}
  subscription;

  @api get currentTabId() {
    return this._currentTabId;
  }
  set currentTabId(value) {
    this._currentTabId='';
    this._currentTabId = value;
    this.setAttribute("currentTabId", value);
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
    this.fetchDcoumentDetails();
    this.fetchApplDetails();
    this.fetchDeldocDetails();
    this.getApplicaWithAddressDetails();
    this.getCaseData(value);
  }
  @track _applicantId;
  // @api get applicantId() {
  //   return this._applicantId;
  // }
  // set applicantId(value) {
  //   this._applicantId = value;
  //   this.setAttribute("applicantId", value);
   
  // }

  @api rcuUser;
   
  get hideChecbox(){
    return this.rcuUser===false;
  }

  showTemplateOne = true;
  render() {
    return this.rcuUser ? rcuDetailsVerifier : rcuDetails;
  }


  @wire(MessageContext)
  MessageContext;


  connectedCallback() {
        if(!this.hasEditAccess){
          this.disableMode=true
        }else{
          this.disableMode=false;
        }
   
    this.activeSection = ["A"];
   console.log('rcuUser id in RCU::::408',this._applicantId, this.rcuUser);
     this.sunscribeToMessageChannel();

     if (RolesRCUManager) {
      this.rcuMangerRoles = RolesRCUManager.split(',');
      console.log('Roles RCU Managers Array:263', this.rcuMangerRoles); // Log to verify
  }
  }

  sunscribeToMessageChannel() {
    this.subscription = subscribe(
      this.MessageContext,
      SaveProcessCalled,
      (values) => this.handleSaveThroughLms(values)
    );
  }



@track docDetailsAvl = true;
  get disableInitiateRCU(){
    return this.disableMode || this.docDetailsAvl;
  }

  get disableVerifierInitRCU(){
    return this.docDetailsAvl;
  }

  
/* -------------------CPA / UW View---------------- */
  
fetchLoanDetails() {
  let loanDetParams = {
      ParentObjectName: "LoanAppl__c",
      ChildObjectRelName: "",
      parentObjFields: ["Id", "Name", "ReqLoanAmt__c","OwnerId","Stage__c","SubStage__c","BrchCode__c","Product__c",
        "BrchName__c","ApplicantName__c","LANRCUStatus__c","FinalRCUManagerRemarks__c",'Applicant__c','FinalRCUStatusReason__c'],
      childObjFields: [],
      queryCriteria: " where Id = '" + this._loanAppId + "' limit 1"
    };
    getSobjectDataNonCacheable({params: loanDetParams}).then((result) => {
       // this.wiredDataCaseQry=result;
        console.log("result RCU LOAN DETAILS #841>>>>>", result);
        if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
          this.loanAmount = result.parentRecords[0].ReqLoanAmt__c;
          this._applicantId = result.parentRecords[0].Applicant__c;
          this.lanOwner = result.parentRecords[0].OwnerId;
          this.lanStage = result.parentRecords[0].Stage__c;
          this.lanSubStage = result.parentRecords[0].SubStage__c;
          this.brchCode= result.parentRecords[0].BrchCode__c;
          this.branchName=result.parentRecords[0].BrchName__c;
          this.lanProd =result.parentRecords[0].Product__c;
          this.mainApp = result.parentRecords[0].ApplicantName__c;
          this.loanRCUStatus = result.parentRecords[0].LANRCUStatus__c ? result.parentRecords[0].LANRCUStatus__c : 'PENDING';
          this.loanRCUStatusReason = result.parentRecords[0].FinalRCUStatusReason__c;
          this.finalRCURemark = result.parentRecords[0].FinalRCUManagerRemarks__c ? result.parentRecords[0].FinalRCUManagerRemarks__c : '';
          this.fetchDocumentMetadata(this.lanProd);
          if((this.currentUserId === this.lanOwner) && (this.lanStage === 'Disbursed' && (this.lanSubStage === 'Additional Processing' || this.lanSubStage === 'UW Approval')) ){
          //  this.disableInitiate=false;
            this.disableMode=false;
          
          }	else{
           // this.disableMode=true;
          }
          if(this.brchCode){
            this.getBranchCity()
          }
          this.getCaseData();
         
        }
      })
      .catch((error) => {
        console.log("RCU LOAN Details Error#856", error);
      });
  }
  getBranchCity(){
    let branchParams = {
      ParentObjectName: "BankBrchMstr__c",
      ChildObjectRelName: "",
      parentObjFields: ["Id","Name","BrchCode__c","LocationMaster__c","LocationMaster__r.City__c"],
      childObjFields: [],
      queryCriteria: ' where BrchCode__c = \''+ this.brchCode + '\''
    };
    getSobjectDataNonCacheable({params: branchParams}).then((result) => {
          console.log('result:::::getBrachCity 321',result);
        if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
          this.branchCity = result.parentRecords[0].LocationMaster__r.City__c;         
          console.log('result:::::this.branchCity 323',this.branchCity); 
        }
        this.showSpinner=false;
      })
      .catch((error) => {
        this.showSpinner=false;
        console.log("TECHNICAL PROP DOCUMENT DETAILS #696", error);
      });
  }

fetchApplDetails() {
  let applParams = {
      ParentObjectName: "Applicant__c",
      ChildObjectRelName: "",
      parentObjFields: [
        "Id","Name","LoanAppln__c","FullName__c","ApplType__c","RCUProfChecked__c","IsDeleted__c"
      ],
      childObjFields: [],
      queryCriteria: ' where LoanAppln__c = \''+ this._loanAppId + '\' AND RCUProfChecked__c != true AND IsDeleted__c != true'
    };

    getSobjectDataNonCacheable({params: applParams}).then((result) => {
      this.showSpinner=false;
        if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
          this.appList = result.parentRecords; 
          this.appList.forEach(i=>{
            if(i.ApplType__c==='P'){
              i.ApplType__c= 'PRIMARY';
          }
          if(i.ApplType__c==='C'){
              i.ApplType__c='CO-APPLICANT'
          }
          if(i.ApplType__c==='G'){
              i.ApplType__c='GUARANTOR'
          }
          if(i.ApplType__c==='N'){
              i.ApplType__c='NOMINEE'
          }
          if(i.ApplType__c==='A'){
              i.ApplType__c='APPOINTEE'
          }
          })
            
        }
      })
      .catch((error) => {
        this.showSpinner=false;
        console.log("TECHNICAL PROP DOCUMENT DETAILS #696", error);
      });
  }

@track metaList=[];
@track docCategary=[]
  fetchDocumentMetadata(lanProd) {
  let scrStageName='Verification'
    let metadataParams = {
        ParentObjectName: "DocDisplay__mdt",
        ChildObjectRelName: "",
        parentObjFields: [
          "Id","DocConfig__c","IsActive__c","Product_Type__c","ScrnName__c"
        ],
        childObjFields: [],
        queryCriteria: ' where Product_Type__c = \''+ lanProd + '\' AND IsActive__c = true AND ScrnName__c =\''+scrStageName+'\''
      };
  
      getSobjectDataNonCacheable({params: metadataParams}).then((result) => {
        this.showSpinner=false;
          if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
            this.metaList = result.parentRecords; 
            console.log("METADATA DOCUMENT DISPLAY #365", this.metaList);
              let docCat=JSON.parse(this.metaList[0].DocConfig__c);
              this.docCategary = docCat.DocCat;
              console.log("METADATA DOCUMENT docCategary #369", this.docCategary);
          }
        })
        .catch((error) => {
          this.showSpinner=false;
          console.log("METADATA DOCUMENT DISPLY #696", error);
        });
    }
@track mapChilds =new Map();
fetchDcoumentDetails() {
let  docDetParams = {
    ParentObjectName: "DocDtl__c",
    ChildObjectRelName: "ContentDocumentLinks",
    parentObjFields: [
      "Id","Name","LAN__c","DocTyp__c","File_Type__c","CreatedDate","DocSubTyp__c","ApplAsset__r.Id","RCUInitiated__c",
      'FileAvalbl__c','RM_Remarks__c','Appr_Actn__c','RCUFileStatus__c','SamplingRequied__c','DocValidStatus__c',
      'OpsVer__c','Appl__r.FullName__c','CreditReqSampling__c',"RCUProfChecked__c","RCUHoldDateTime__c","RCUUnHoldDateTime__c",
      "RCUInitiDateTime__c","RCURemarks__c","DocCatgry__c"
    ],
    childObjFields: ['ContentDocumentId'],
    queryCriteria: ' where LAN__c = \''+ this._loanAppId + '\' AND RCUInitiated__c = false AND IsDeleted__c != true AND DocTyp__c IN  (\''+this.docCategary.join('\', \'') + '\')'
  };

  getAllSobjectDatawithRelatedRecords({params: docDetParams}).then((result) => {
    this.showSpinner=false;
    console.log('CHild records in :::::385',result);
      if (result !== undefined && result.length > 0) {
       
        this.docDetailsAvl=false
        let tempArr = [];
        tempArr= result; 
        console.log('CHild records in :::::385', tempArr);
          if(!this.rcuUser){

              tempArr.forEach(row1 => {
                const dateTime1 = new Date(row1.parentRecord.ClosedDate);
                const dateTime2 = new Date(row1.parentRecord.CreatedDate);
                  const formattedDate1 = formattedDateTimeWithoutSeconds(dateTime1); 
                  const formattedDate2 = formattedDateTimeWithoutSeconds(dateTime2); 
                  const dateOfIntiation1 = `${formattedDate1}`;
                  const dateOfIntiation2 = `${formattedDate2}`;
                  row1.parentRecord.ClosedDate = dateOfIntiation1;
                  row1.parentRecord.CreatedDate = dateOfIntiation2;
                  this.docList.push(row1.parentRecord);

                    let key = row1.parentRecord.Id;
                    console.log('files from child is 33', key, this.mapChilds.get(key));
     
                   
                        // If the key doesn't exist, create a new list with the value
                        if(row1.ChildReords){
                          this.mapChilds.set(key,true);
                        }
                        else{
                          this.mapChilds.set(key,false);
                        }
                  
                    console.log('files from child is 415 ', this.mapChilds);
             
              });
              
              this.initializeData(this.docList);
          
          }
      }
    })
    .catch((error) => {
      this.showSpinner=false;
      console.log("TECHNICAL PROP DOCUMENT DETAILS #696", error);
    });
}

initializeData(docList) {
  this.docList = docList.map(item => {
      let ValidationStatus;
      let disSampReq;
      if (item.DocValidStatus__c === 'Success') {
          ValidationStatus=true
      } else if (item.DocValidStatus__c === 'Failure') {
          ValidationStatus=false;
      }
      if(item.CreditReqSampling__c){
        disSampReq=true;
      }
      return { ...item,ValidationStatus,disSampReq };
  });
  console.log('docList:::::738',this.docList);
}


fetchDeldocDetails() {
let  docDetParams = {
    ParentObjectName: "CaseDoc__c",
    ChildObjectRelName: "",
    parentObjFields: [
      "Id","DocDetail__r.Appl__r.FullName__c","Case__r.CaseNumber","DocDetail__r.DocTyp__c","DocDetail__r.DocSubTyp__c",
      "DocDetail__r.DocValidStatus__c","DocDetail__r.VendorVerification__c","DocDetail__r.RCUInitiDateTime__c",
      "DocDetail__r.RCUInitiated__c",'DocDetail__r.RCUHoldDateTime__c',
      'DocDetail__r.RCUFileStatus__c','DocDetail__r.RM_Remarks__c','DocDetail__r.RCURemarks__c',
      'DocDetail__r.File_Type__c','DocDetail__r.DelDateTime__c','DocDetail__r.DeletedBy__c',
      'DocDetail__r.IsDeleted__c','DocDetail__r.LAN__c'
    ],
    childObjFields: [],
    queryCriteria: ' where DocDetail__r.LAN__c = \''+ this._loanAppId + '\' AND DocDetail__r.RCUInitiated__c = true AND DocDetail__r.IsDeleted__c = true'
  };

  getSobjectDataNonCacheable({params: docDetParams}).then((result) => {
    console.log("RCU DELETED DOCUMENT DETAILS #480", result);
    this.showSpinner=false;
      if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
        console.log("RCU DELETED DOCUMENT DETAILS #480", result);
          if(!this.rcuUser){
         let arr = result.parentRecords.map(item => {
              return {
                  ...item,
                  'Applicant Name': item.DocDetail__r ? item.DocDetail__r.Appl__r.FullName__c : '',
                  'Document Type': item.DocDetail__r ? item.DocDetail__r.DocTyp__c : '',
                  'Document Name': item.DocDetail__r ? item.DocDetail__r.DocSubTyp__c : '',
                  'Validation Status': item.DocDetail__r ? item.DocDetail__r.DocValidStatus__c : '',
                  'Vendor Verification': item.DocDetail__r ? item.DocDetail__r.VendorVerification__c : '',
                  'RCU Initiation Date/Time': item.DocDetail__r ? item.DocDetail__r.RCUInitiDateTime__c : '',
                  'RCU Case ID': item.Case__r ? item.Case__r.CaseNumber : '',
                  'RCU Status': item.DocDetail__r ? item.DocDetail__r.RCUFileStatus__c : '',
                  'RCU Hold Date/Time': item.DocDetail__r ? item.DocDetail__r.RCUHoldDateTime__c : '',
                  'RCU Remarks': item.DocDetail__r ? item.DocDetail__r.RCURemarks__c : '',
                  'File Type': item.DocDetail__r ? item.DocDetail__r.File_Type__c : '',
                  'Deleted Date/Time': item.DocDetail__r ? item.DocDetail__r.DelDateTime__c : '',
                  'Deleted By': item.DocDetail__r ? item.DocDetail__r.DeletedBy__c : '',
                  'RM Remarks': item.DocDetail__r ? item.DocDetail__r.RM_Remarks__c : '',
              }
              })
              this.delDocList= arr;
              this.initializeDelData(this.delDocList);
          
          }
      }
    })
    .catch((error) => {
      this.showSpinner=false;
      console.log("RCU DELETED DOCUMENT DETAILS #505", error);
    });
}


rcuDeletedColumns = [
   
  { label: "Applicant Name", fieldName: "Applicant Name", type: "text" },
  { label: "Document Type", fieldName: "Document Type", type: "text" },
  { label: "Document Name", fieldName: "Document Name", type: "text" },
  { label: "Validation Status", cellAttributes: {alignment: 'center', iconName: { fieldName: 'iconName' },alternativeText: { fieldName: 'alternativeText' }}},
  { label: "Vendor Verification", fieldName: "Vendor Verification", type: "text" },
  { label: "RCU Initiation Date/Time", fieldName: "RCU Initiation Date/Time", type: "text" },
  { label: "RCU Case ID", fieldName: "RCU Case ID", type: "text" },
  { label: "RCU Status", fieldName: "RCU Status", type: "text" },
  { label: "RCU Hold Date/Time", fieldName: "RCU Hold Date/Time", type: "text" },
  { label: "RCU Remarks", fieldName: "RCU Remarks", type: "text" },
  { label: "File Type", fieldName: "File Type", type: "text" },
  { label: "Deleted Date/Time", fieldName: "Deleted Date/Time", type: "text" },
  { label: "Deleted By", fieldName: "Deleted By", type: "text" },
  { label: "RM Remarks", fieldName: "RM Remarks", type: "text" }

];

initializeDelData(delDocList) {
  this.delDocList = delDocList.map(item => {
      let iconName;
      let alternativeText;
      let ValidationStatus;
      if (item.DocDetail__r.DocValidStatus__c === 'Success') {
          iconName = 'action:approval';
          alternativeText = 'Success';
          ValidationStatus=true
      } else if (item.DocDetail__r.DocValidStatus__c === 'Failure') {
         iconName = 'action:close';
          alternativeText = 'Failure';
          ValidationStatus=false;
      }
      return { ...item, iconName, alternativeText,ValidationStatus };
  });
  console.log('docList:::::738',this.docList);
}

@track firstAgency;
@track firstRcuInitDate;
  @api getVerifierCaseData() {
    let recordType='RCU';
    let paramsLoanApp = {
      ParentObjectName: "Case",
      parentObjFields: [
        "Id","Address_Type__c","Address_Line_2__c","Address_Line_1__c","ApplAddr__c","CaseNumber","AccountId","ContactId",
        "ClosedDate","ReportResult__c","Old_Agency__r.Name","Account.Name","Contact.Name","Status","Remarks_for_Technical_Agency__c",
        "CityId__c","Reason_for_reinitiated_FI__c","Reason_for_cancelation__c","Loan_Application__c","Applicant__c",
        "IsReinitiated__c",'DateTimeInitiation__c','Date_Time_of_Submission__c','ReviewerComments__c','ExpiryDate__c',
        'IsReinitiatedExpired__c','TAT__c','HubManagerReview__c','OwnerId','Owner.Name','Final_RCU_status_Reason__c',
        'Remarks_regarding_the_case__c','CreatedDate'],

        queryCriteria:' where ContactId != null AND Loan_Application__c=\''+this._loanAppId+'\' AND RecordType.DeveloperName = \''+recordType+ '\' order by createdDate asc'
    };
    getSobjectData1({ params: paramsLoanApp }).then((result) => {
      console.log("getVerifierCaseData 565", result);
      this.showSpinner=false;
      if (
        result.parentRecords !== undefined &&
        result.parentRecords.length > 0
      ) {
        this.caseAgencyData = result.parentRecords;
        this.firstAgency=result.parentRecords[0].Account.Name;
        this.firstRcuInitDate=result.parentRecords[0].CreatedDate;
       console.log('result.parentRecords::::575',result.parentRecords);
    
        this.getVerifierCaseDataforClosedDate();
      }
      if (result.error) {
        this.showSpinner=false;
        console.error("case result getting error=", result.error);
      }
    });
  }

  @track lastRcuInitCloseDate;
  @track toatlTAT;
  @api getVerifierCaseDataforClosedDate() {
    let recordType='RCU';
    let paramsLoanApp = {
      ParentObjectName: "Case",
      parentObjFields: [
        "Id","CaseNumber","AccountId","ContactId","ClosedDate","Status","Loan_Application__c"
     ],

        queryCriteria:' where ContactId != null AND Loan_Application__c=\''+this._loanAppId+'\' AND RecordType.DeveloperName = \''+recordType+ '\' AND Status=\''+'Closed'+'\' order by LastModifiedDate DESC'
    };
    getSobjectData1({ params: paramsLoanApp }).then((result) => {
      console.log("result 636 Closed Cases", result);
      this.showSpinner=false;
      if (
        result.parentRecords !== undefined &&
        result.parentRecords.length > 0
      ) {
         let tempArr= result.parentRecords;
        this.lastRcuInitCloseDate=tempArr[0].ClosedDate;
       console.log('this.lastRcuInitCloseDate::::644',tempArr);
       if(this.firstRcuInitDate && this.lastRcuInitCloseDate){
        this.toatlTAT =this.calculateTimeDifference(this.firstRcuInitDate,this.lastRcuInitCloseDate);
       }
       
      }
      if (result.error) {
        this.showSpinner=false;
        console.error("case result getting error=", result.error);
      }
    });
  }



calculateTimeDifference(startDate, endDate) {
  // Parse the start and end dates if they are strings
  const start = new Date(startDate);
  const end = new Date(endDate);

  // Calculate the difference in milliseconds
  const diffInMs = Math.abs(end - start);

  // Convert milliseconds to days, hours, minutes, and seconds
  const diffInSeconds = Math.floor(diffInMs / 1000);
  const days = Math.floor(diffInSeconds / (60 * 60 * 24));
  const hours = Math.floor((diffInSeconds % (60 * 60 * 24)) / (60 * 60));
  const minutes = Math.floor((diffInSeconds % (60 * 60)) / 60);
  const seconds = diffInSeconds % 60;
  // Return the difference in the desired format
  return `${days}:${hours}:${minutes}:${seconds}`;
}


@track addrVerData=[];
@track addrVerCredit=[];
  @track appData=[];
  @track addrData=[];
    getApplicaWithAddressDetails() {
      let paramsData = {
          ParentObjectName: 'Applicant__c',
          ChildObjectRelName: 'Applicant_Addresses__r',
          parentObjFields: ['Id', 'LoanAppln__c', 'TabName__c','FullName__c', 'MobNumber__c', 'PhoneNumber__c',
             'Type_of_Borrower__c','ApplType__c','Constitution__c','CustProfile__c'],
          childObjFields: ['Id', 'FullAdrs__c', 'AddrTyp__c', 'City__c', 'CityId__c','RCUProfChecked__c','IsDeleted__c',
            'SamplingDateTime__c','RCUUnHoldDateTime__c','RCURemarks__c','RCUInitiDateTime__c','AgencyAssigned__c',
            'RCUFileStatus__c','AgencyDocStatus__c'],
          queryCriteria: '  where LoanAppln__c = \'' + this._loanAppId + '\''
      }
      // queryCriteria: '  where Type_of_Borrower__c = \'' + this.typeOfBorrower + '\' AND LoanAppln__c = \'' + this.loanAppId + '\''
      getAllSobjectDatawithRelatedRecords({ params: paramsData })
          .then((result) => {
              this.addrData=[];
              this.addrVerData=[];
              this.addrVerCredit=[];
              this.appData = result;
              console.log('result is', JSON.stringify(result));
              if (this.appData) {
                  this.appData.forEach(item => {
                      if (item.parentRecord) {
                          if (item.ChildReords) {
                              item.ChildReords.forEach(childitem => {
                                if(!childitem.RCUProfChecked__c && !childitem.IsDeleted__c){
                                  this.docDetailsAvl=false
                                  let obj = {};
                                  obj.appId = item.parentRecord.Id;
                                  obj.loanAppId = this._loanAppId;
                                  obj.appName = item.parentRecord.FullName__c;
                                  obj.appAdrrsId = childitem.Id;
                                  obj.appAddrType = childitem.AddrTyp__c;
                                  obj.RCUProfChecked__c = childitem.RCUProfChecked__c;
                                  obj.addrCity = childitem.City__c;
                                  obj.fullAddr=childitem.FullAdrs__c;
                                  obj.AgencyAssigned__c=childitem.AgencyAssigned__c;
                                  obj.IsDeleted__c=childitem.IsDeleted__c;
                                  obj.selectCheckbox = false;
                                  this.addrData.push(obj);
                                }
                              })
                          }
  
                      }
                  });
             
              }
              if (result.error) {
                  console.error('appl result getting error=', result.error);
              }
          })
  
  }
  

  get allCheck(){
    return this.initAll && this.initAllAddr;
  }
  @track docSelctArr=[]
  @track initAll;
  @track initAllAddr;
  handleCreditRCUClick(event){
    let val =event.target.checked;
    if(event.target.label==='Initiate RCU All'){
      this.initAll=val;
      this.initAllAddr=val;
      let tempArr=[]
      let tempAddArr=[];
      this.docSelctArr=[];      
      this.docList.forEach(item=>{
        let obj={...item,'RCUInitiated__c':true};
        tempArr.push(obj);
  
      })

      this.addrData.forEach(item=>{
        let obj={...item,'RCUProfChecked__c':true};
        tempAddArr.push(obj);
  
      })
      if(tempArr && tempArr.length>0){
        this.docList =[];
        this.docList=[...tempArr];

        this.docArr=[];
        this.docArr=[...tempArr];
        this.docSelctArr=[...tempArr];
      }
      if(tempAddArr && tempAddArr.length>0){
        this.addrData=[];
        this.addrData=[...tempAddArr]
        this.docSelctArr=[...tempAddArr];
      }
    }
           

            let docId = event.target.dataset.docid;
            let indexId = event.target.dataset.index;
            console.log('val 1674::::', val, 'docId ', docId,'indexId',indexId);
          
            if(event.target.label==='Initiate RCU'){
             
              console.log('this :::1684', JSON.stringify(this.docList))         
              let temp = this.docList[indexId];
              temp.RCUInitiated__c =val;
              this.docList[indexId] = {...temp};

              let tempArray = [...this.docList];
              tempArray[event.target.dataset.index] = this.docList[indexId];
              this.docList = [...tempArray];
              this.docArr=[...tempArray];
              if(this.addrData && this.addrData.length>0){
                this.docSelctArr=[...this.addrData,...tempArray];
              }else{
                this.docSelctArr=[...tempArray];
              }
              
              let allchecked=true
              this.docList.forEach(item=>{
                if(!item.RCUInitiated__c){
                  allchecked=false;
                }
              })
              if(allchecked){
                this.initAll=true
              }else{
                this.initAll=false;
              }
              
              // console.log('this.docList :::1495', JSON.stringify(this.docList))
            
          }

          if(event.target.label==='Sampling Required'){
            console.log('this :::1724', JSON.stringify(this.docList))    
            let temp = this.docList[indexId];
            temp.CreditReqSampling__c =val;
            this.docList[indexId] = {...temp};
            let tempArray = [...this.docList];
            tempArray[event.target.dataset.index] = this.docList[indexId];
            this.docList = [...tempArray];
            this.docArr=[...tempArray];
          }

          if(event.target.label==='Initiate Profile Check'){
            console.log('this :::1765', JSON.stringify(this.addrData))    
            let temp = this.addrData[indexId];
            temp.RCUProfChecked__c =val;
            this.addrData[indexId] = {...temp};
            let tempArray = [...this.addrData];
            tempArray[event.target.dataset.index] = this.addrData[indexId];
            this.addrData = [...tempArray];
            if(this.docArr && this.docArr.length>0){
              this.docSelctArr=[...this.docArr,...tempArray];
            }else{
              this.docSelctArr=[...tempArray];
            }
            let allchecked=true
            this.addrData.forEach(item=>{
              if(!item.RCUProfChecked__c){
                allchecked=false;
              }
            })
            if(allchecked){
              this.initAllAddr=true
            }else{
              this.initAllAddr=false;
            }
            console.log('this.addrData :::1773', JSON.stringify(this.addrData))
          }

         
          console.log('this.docList FINAL :::1777', JSON.stringify(this.docList),':::',this.docList.length)

  }


  verfColumns = [
    { label: 'Case Number', fieldName: 'CaseNumber' },
    { label: 'RCU Initiation Date', fieldName: 'initiationDate' },
    { label: 'RCU Sampler Name', fieldName: 'RCU Sampler Name' },
    { label: 'Case Status', fieldName: 'Status' },
    { label: 'Agency RCU Report Status', fieldName: 'AgcRCUReportStatus__c' },
    { label: 'Final RCU Status Reason', fieldName: 'Final_RCU_status_Reason__c' },
    {
      type: "button", label: 'Report PDF', initialWidth: 100, typeAttributes: {
          label: 'View Cases',
          name: 'View Cases',
          title: 'Edit',
          disabled: false,
          value: 'edit',
          iconPosition: 'left',
          iconName:'utility:cases',
          variant:'Success'
      }
  },
    { label: 'TAT', fieldName: 'TAT__c' },
    {
        type: "button", label: 'Action', initialWidth: 100, typeAttributes: {
            label: 'View',
            name: 'View',
            title: 'View',
            disabled: false,
            value: 'view',
            iconPosition: 'left',
            iconName:'utility:preview',
            variant:'Success'
        }
    },
   
];

callRowAction(event) {
 // this.caseRecordId='';
  const recId = event.detail.row.Id;
  const actionName = event.detail.action.name;
  console.log('recId::::879',recId);
  this.actionName = actionName
  if (actionName === 'View Cases') {
      this.handleAction(recId, actionName);
  }else if (actionName === 'View') {
    
      this.handleAction(recId,actionName);
  }
}

@track showCases=false;
@track renderDocDetails=false;
handleAction(recId,actionName){
  let dataValue=actionName;
  if (dataValue === "View") {
    // this.caseRecordId= recId;
    if(!this.caseRecordId){
      this.caseRecordId = recId;
      console.log("caseRecordId ", recId);
      this.fetchCaseDoc(this.caseRecordId);
      this.getAgencyCaseData(this.caseRecordId);
      this.renderDocDetails = true;
    }else {
      if(this.caseRecordId === recId){
        this.renderDocDetails = false;
        this.caseRecordId=null
        this.showSpinner=false;
      }else{
        this.caseRecordId='';
        this.caseRecordId = recId;
        this.fetchCaseDoc(this.caseRecordId);
        this.getAgencyCaseData(this.caseRecordId);
        this.renderDocDetails = true;
      }
    }
  }

  if (dataValue === "View Cases") {

    if(!this.caseRecordId){
      this.caseRecordId = recId;
      console.log("caseRecordId ", recId);
      this.getAgencyCaseData(this.caseRecordId);
      this.showCases = true;
    }else {
      if(this.caseRecordId === recId){
        this.showCases = false;
        this.caseRecordId=null
        this.showSpinner=false;
      }else{
        this.caseRecordId='';
        this.caseRecordId = recId;
        this.getAgencyCaseData(this.caseRecordId);
        this.showCases = true;
      }
    }
     
  }
}

/* -------------------RCU Verifier / Manager View---------------- */

@track accContactMap=[];
@track agencyCases=[];
@track  mapCaseDocs;
@track mapCaseAgency;
@track rcuStatusList=[];
@track agcStatOptions=[];
@track noRec=true;
@track noAddrRec=true;
@track appModalData=[];
@track caseRecords=[]

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
 

@track
agencyMapParams = {
  ParentObjectName: "AgncLocMap__c",
  ChildObjectRelName: "",
  parentObjFields: [
    "Id","Name","LocationMaster__r.City__c","Account__r.Name","Contact__c"],
  childObjFields: [],
  queryCriteria: ""
};



  fetchAgecnyLocMapper() {
    let agencyType='RCU';
    let tempParams = this.agencyMapParams;
    tempParams.queryCriteria =
      ' where IsActive__c = true AND LocationMaster__r.City__c  = \'' + this.branchCity + '\' AND AgencyType__c includes(\''+ agencyType+'\')' ;
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
          console.log('this.agencyOptions1 IN filtered ::::>>>>1001',this.agencyOptions1);
          this.showSpinner=false;
        }else{
          this.showSpinner=false;
          this.showToastMessage('Error','No Agency avaliable for this location','error','sticky')
        }
      })
      .catch((error) => {
        this.showSpinner=false;
        console.log("TECHNICAL PROP CASE QUERIES #527", error);
      });
  }

  @wire(getObjectInfo, { objectApiName: 'LoanAppl__c' })
  objInfo4;  
  @wire(getPicklistValuesByRecordType, {
    objectApiName: 'LoanAppl__c',
    recordTypeId: "$objInfo4.data.defaultRecordTypeId"
  })
  LoanAppPicklistHandler({ data, error }) {
    if (data) {
      console.log("data RCU for LoanAppl picklist values are", data);
      this.loanRCUStatusOptions = [...this.generatePicklist(data.picklistFieldValues.LANRCUStatus__c)];
      this.loanRCUStatusReasonOptions = [...this.generatePicklist(data.picklistFieldValues.FinalRCUStatusReason__c)];
      
    }
    if (error) {
      console.error("error im getting RCU for LoanAppl picklist values are", error);
    }
  }


  @wire(getObjectInfo, { objectApiName: DOC_DETL_OBJECT })
  objInfo3;  
  @wire(getPicklistValuesByRecordType, {
    objectApiName: DOC_DETL_OBJECT,
    recordTypeId: "$objInfo3.data.defaultRecordTypeId"
  })
  DocDtlPicklistHandler({ data, error }) {
    if (data) {
      this.rcuStatOptions = [...this.generatePicklist(data.picklistFieldValues.RCUFileStatus__c)];
      this.vendorVerfOptions=[...this.generatePicklist(data.picklistFieldValues.VendorVerification__c)];
      this.agcStatOptions=[...this.generatePicklist(data.picklistFieldValues.AgencyDocStatus__c)];
    }
    if (error) {
      console.error("error im getting TSR picklist values are", error);
    }
  }

  @track rcuLimitStatOptions=[
    { label: 'Sampled', value: 'Sampled' },
    { label: 'Hold', value: 'Hold' }
  ];
  
  @track rcuWaivOffStatOptions=[
    { label: 'Sampled', value: 'Sampled' },
    { label: 'Screened', value: 'Screened' },
    { label: 'Hold', value: 'Hold' },
    { label: 'Pending', value: 'Pending' }
  ];
  @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
  objInfo;

  @wire(getPicklistValues, {
    recordTypeId: '$recordTypeId',
    fieldApiName: REASON_FOR_CANCEL
  })
  ReasonForCancelHandler({ data, error }) {
    if (data) {
      this.CancelOptions = [...this.generatePicklist(data)];
    }
    if (error) {
      console.log(error);
    }
  }

@track caseRecCopy=[]
  @api getCaseData() {
    let recordType='RCU';
    let paramsLoanApp = {
      ParentObjectName: "Case",
      parentObjFields: [
        "Id","Address_Type__c","Address_Line_2__c","Address_Line_1__c","ApplAddr__c","CaseNumber","AccountId","ContactId",
        "ClosedDate","ReportResult__c","Old_Agency__r.Name","Account.Name","Contact.Name","Status","Remarks_for_Technical_Agency__c",
        "CityId__c","Reason_for_reinitiated_FI__c","Reason_for_cancelation__c","Loan_Application__c","Applicant__c",
        "IsReinitiated__c",'DateTimeInitiation__c','Date_Time_of_Submission__c','ReviewerComments__c','ExpiryDate__c',
        'IsReinitiatedExpired__c','TAT__c','HubManagerReview__c','OwnerId','Owner.Name','Final_RCU_status_Reason__c',
        'Remarks_regarding_the_case__c','AgcRCUReportStatus__c'],

        queryCriteria:' where AccountId = null AND Loan_Application__c=\''+this._loanAppId+'\' AND RecordType.DeveloperName = \''+recordType+ '\' order by createdDate asc'
    };
    getSobjectData1({ params: paramsLoanApp }).then((result) => {
      console.log("getCaseData method 837", result);
      this.showSpinner=false;
      this.caseData = result;
      this.caseRecordsData = [];
      if (
        result.parentRecords !== undefined &&
        result.parentRecords.length > 0
      ) {
        //this.docDetailsAvl=true;
        result.parentRecords.forEach((item, index) => {
          if (item.Status === "Closed" || item.Status === "Cancelled") {
            item.isCanDis = true;
          } else {
           // this.agecnyFlag=false;
            item.isCanDis = this.hasEditAccess===true?false:true
            
          }

        });

        this.caseRecordsData = result.parentRecords;
        let caseIds=[];
      
        this.caseRecordsData.forEach(row1 => {
          const dateTime1 = new Date(row1.ClosedDate);
          const dateTime2 = new Date(row1.DateTimeInitiation__c);
            const formattedDate1 = formattedDateTimeWithoutSeconds(dateTime1); 
            const formattedDate2 = formattedDateTimeWithoutSeconds(dateTime2); 
            const dateOfIntiation1 = `${formattedDate1}`;
            const dateOfIntiation2 = `${formattedDate2}`;
            row1.ClosedDate = dateOfIntiation1;
            row1.initiationDate = dateOfIntiation2;
            caseIds.push(row1.Id)
        });
        let arr=this.caseRecordsData.map(i => {
        return  {...i,   'RCU Sampler Name': i.Owner ? i.Owner.Name : '',
       }
       })
       this.caseRecordsData =[...arr];
        this.caseRecCopy = [...this.caseRecordsData];
        let element = this.caseRecCopy.pop();
        console.log('element:::::891',element);
        if(element.Status !== 'Closed'){
          this.openCaseOwner = element.Owner.Id
          this.openCaseId=element.Id;
          console.log('openCaseOwner:::::891',this.openCaseOwner);
        }
        console.log('case details on CPA / UW View::::892',this.caseRecordsData);
      this.getVerifierCaseData();
     
      if(this.rcuUser){
        this.getSampledDocs(caseIds);
        // this.getAgencyCaseName(caseIds);
      }
      
      }
      if (result.error) {
        this.showSpinner=false;
        console.error("case result getting error=", result.error);
      }
    });
  }


  @track verifCaseRecords=[];
  getSampledDocs(caseIds){
    let caseDocParams = {
      ParentObjectName: "CaseDoc__c",
      ChildObjectRelName: "",
      parentObjFields: ["Id", "Case__c", "DocDetail__c","DocDetail__r.RCUFileStatus__c","ApplAddr__c","Case__r.AccountId",
        "Case__r.Account.Name","Case__r.AgcRCUReportStatus__c"
      ],
      childObjFields: [],
      queryCriteria: ' where Case__c IN  (\''+caseIds.join('\', \'') + '\') '
    };
    let mapCaseDocs = new Map();
    getSobjectDataNonCacheable({params: caseDocParams}).then((result) => {
      this.showSpinner=false;
      if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
        console.log('case details on Verifier View in getSampledDocs:::921',result.parentRecords);
        let caseDocs = result.parentRecords;
        caseDocs.forEach(item=>{
          let key = item.Case__c;
          if (!mapCaseDocs.has(key)) {
           let statusList=[]
           if(item.DocDetail__c && item.DocDetail__r.RCUFileStatus__c ==='Sampled'){
            statusList.push(item)
           }
              mapCaseDocs.set(key, statusList);
          } else {
            const templist= mapCaseDocs.get(key)
            if(item.DocDetail__c && item.DocDetail__r.RCUFileStatus__c ==='Sampled'){
              templist.push(item)
             }
              mapCaseDocs.set(key, templist);
          } 
     
        })
        this.mapCaseDocs=mapCaseDocs;
        console.log('mapCaseDocs  is 550 ', this.mapCaseDocs);
        this.getAgencyCaseName(caseIds,mapCaseDocs);
     //  console.log('Object.keys(mapOfMonthWithTax):::::',Object.keys(this.mapCaseDocs));
    console.log('case details on verifier view  is 952 ', this.verifCaseRecords);
   
      }
    })
    .catch((error) => {
      this.showSpinner=false;
      
      console.log("TECHNICAL PROP CASE QUERIES #766", error);
    });
  }


  @track verifierColumns = [
    {
        label: 'Case No',
        fieldName: 'CaseNumber',
        type: 'text',
        editable: false
    },
    {
        label: 'RCU Initiation Date',
        fieldName: 'initiationDate',
        type: 'date',
        editable: false
    },
    {
        label: 'RCU Sampler Name',
        fieldName: 'RCU Sampler Name',
        type: 'text',
        editable: false
    },
    {
        label: 'RCU Agency Name',
        fieldName: 'agcList',
        type: 'text',
        editable: false
    },
    {
        label: 'Total No of Sampled Documents',
        fieldName: 'noOfDoc',
        type: 'number',
        editable: false
    },
    {
        label: 'RCU Case Status',
        fieldName: 'Status',
        type: 'text',
        editable: false
    },
    {
        label: 'Actions',
        type: 'button',
        typeAttributes: {
            label: 'View',
            name: 'View',
            variant: 'success'
        }
    },
    {
      label: 'Assignement',
      type: 'button',
      typeAttributes: {
          label: 'Agency Assignment',
          name: 'Agency Assignment',
          variant: 'success'
      }
  },
    {
        label: 'Agency RCU Report Status',
        fieldName: 'AgcRCUReportStatus__c',
        type: 'text',
        editable: false
    },
    {
        label: 'Report Date',
        fieldName: 'ClosedDate',
        type: 'date',
        typeAttributes: {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric'
        },
        editable: false
    },
    {
        label: 'TAT',
        fieldName: 'TAT__c',
        type: 'text',
        editable: false
    }
];

handleVerifierAction(event) {
  const actionName = event.detail.action.name;
  const row = event.detail.row;
  // Handle different actions based on the button clicked
  if (actionName === 'View') {
        this.handleVerifierView(row, actionName)
      console.log('View action on record:', row.Id, row);
  } else if (actionName === 'Agency Assignment') {
    this.handleVerifierView(row, actionName)
      console.log('Agency Assignment action on record:', row.Id);
  }
}
@track disableMode;
handleVerifierView(row,actionName) {
  this.actionName='';
  this.docIds=[];
  this.addrIds=[];
  this.viewDoc =false;
  let dataValue = actionName;
  this.actionName=actionName;
  this.showSpinner=true;
  this.viewCaseId= ''
  this.disableMode=false;
  if(row.Status==='Closed'){
    this.disableMode=true;
  }
  // To View Cases under RCU Verifiers
  if (dataValue === "View") {
    let caseid= row.Id;
    this.viewCaseId= caseid;
    // this.caseId= caseid;
    if(!this.caseRecordId){
      this.caseRecordId = row.Id;
      console.log("caseRecordId ", this.caseRecordId);
      this.fetchCaseDoc(this.caseRecordId);
      this.getAgencyCaseData(this.caseRecordId);
      this.renderCaseDetails = true;
    }else {
      if(this.caseRecordId === row.Id){
        this.renderCaseDetails = false;
        this.caseRecordId=null
        this.showSpinner=false;
      }else{
        this.caseRecordId='';
        this.caseRecordId = row.Id;
        this.fetchCaseDoc(this.caseRecordId);
        this.getAgencyCaseData(this.caseRecordId);
        this.renderCaseDetails = true;
      }
    }

     
  }

  // To assign Agencies under Agency Assigment button 
  if (dataValue === "Agency Assignment") {
    this.renderCaseDetails=false;
    let caseid= row.Id;
   // this.viewCaseId= caseid;
    console.log("caseid 1508", caseid);
    this.assignCaseId=caseid;
    this.fetchCaseDoc(caseid);
  }
  
}
  getAgencyCaseData(caseid) {
    console.log("loanappId in Reintiate component", this.loanAppId);
    let recordType='RCU';
    let paramsLoanApp = {
      ParentObjectName: "Case",
      parentObjFields: [
        "Id","CaseNumber","AccountId","ContactId","ClosedDate","ReportResult__c","Account.Name",
        "Contact.Name","Status","Remarks_for_Technical_Agency__c","Reason_for_cancelation__c",
        "Loan_Application__c","Applicant__c","IsReinitiated__c",'DateTimeInitiation__c',
        'Date_Time_of_Submission__c','ReviewerComments__c','ExpiryDate__c','IsReinitiatedExpired__c',
        'TAT__c','HubManagerReview__c','OwnerId','Owner.Name','Final_RCU_status_Reason__c',
        'Remarks_regarding_the_case__c','AgcRCUReportStatus__c'

      ],
        queryCriteria:' where Case__c =\'' +caseid+'\' AND RecordType.DeveloperName = \''+recordType+ '\' order by createdDate asc'
    };
    getSobjectData1({ params: paramsLoanApp }).then((result) => {
      this.showSpinner=false;
      console.log(' getAgencyCaseData method 959', result);
      this.caseData = result;
      this.agencyCases = [];
      this.agencyCases=this.caseData.parentRecords;
      console.log(' this.agencyCases 963', this.agencyCases);
      if(this.agencyCases && this.agencyCases.length>0){
        this.agencyCases.forEach(row1 => {
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

      console.log(' this.agencyCases 1096', this.agencyCases);
      if (result.error) {
        this.showSpinner=false;
        console.error("case result getting error=", result.error);
      }
    });
  }


 
  getAgencyCaseName(caseid,mapCaseDocs) {
    console.log("loanappId in Reintiate component", this.loanAppId);
    let recordType='RCU';
    let paramsLoanApp = {
      ParentObjectName: "Case",
      parentObjFields: [
        "Id","CaseNumber","AccountId","ContactId","Account.Name","Case__c"
      ],
        queryCriteria:' where Case__c In (\''+caseid.join('\', \'') + '\') AND RecordType.DeveloperName = \''+recordType+ '\' order by createdDate asc'
    };
    getSobjectData1({ params: paramsLoanApp }).then((result) => {
      this.showSpinner=false;
      console.log(' getAgencyCaseData method 1100', result);
     let agcCases=result.parentRecords;
      let mapCaseAgency= new Map();
      if(agcCases && agcCases.length>0){
        agcCases.forEach(item=>{
          let key = item.Case__c;
          if(!mapCaseAgency.has(key)){
            let agencyList=[];
            if(item.AccountId){
              agencyList.push(item.Account.Name);
             }
             mapCaseAgency.set(key, agencyList);
            } else {
              const acclist= mapCaseAgency.get(key)
              if(item.AccountId){
                acclist.push(item.Account.Name)
               }
               mapCaseAgency.set(key, acclist);
          }
        })
   
      }
      this.mapCaseDocs=mapCaseDocs;
      this.mapCaseAgency=mapCaseAgency;
      console.log('mapCaseAgency  is 1018 ', this.mapCaseAgency);
      console.log('caseRecordsData:::::944',this.caseRecordsData);
      let arr=this.caseRecordsData
      this.verifCaseRecords=[];
       arr.forEach(element=>{
         if(element.OwnerId === this.currentUserId){
           let obj={}
           const index = this.mapCaseDocs && this.mapCaseDocs.get(element.Id) ? this.mapCaseDocs.get(element.Id).length : 0;
           let temarr;
           temarr = this.getCommaSeparatedValues(this.mapCaseAgency,element.Id);
           let unqArr
           if(temarr){
           unqArr = [...new Set(temarr.split(','))].toString();
           }
           console.log('mapCaseAgency  is 1116 ', unqArr);
           obj = {...element, 'noOfDoc': index, 'agcList': unqArr}
           this.verifCaseRecords.push(obj);
        }
       
     let arr=this.verifCaseRecords.map(i => {
      return  {...i,   'RCU Sampler Name': i.Owner ? i.Owner.Name : '',
     }
     })
     console.log('this.verifCaseRecords  is 1412 ', this.verifCaseRecords);
       })
  
      if (result.error) {
        this.showSpinner=false;
        console.error("case result getting error=", result.error);
      }
    });
  }

  getCommaSeparatedValues(array, targetId) {
    for (let item of array) {
        let id = item[0];
        let values = item[1];
        if (id === targetId) {
            return values.join(',');
        }
    }
    return null;
}

 @track docDetParams = {
    ParentObjectName: "DocDtl__c",
    ChildObjectRelName: "",
    parentObjFields: [
      "Id","Name","LAN__c","DocTyp__c","File_Type__c","CreatedDate","DocSubTyp__c","ApplAsset__r.Id","Case__c",
      "RCUInitiated__c","Appl__r.FullName__c","ApplAsset__r.Name","ApplAsset__c","LAN__r.Name","RCUFileStatus__c",
      "AgencyAssigned__c","CreditReqSampling__c","DocValidStatus__c","RCUProfChecked__c","RCURemarks__c",
      "SampleTrigger__c","RCUHoldDateTime__c","RCUUnHoldDateTime__c","AgencyDocStatus__c",
      "RCUInitiDateTime__c","SamplingDateTime__c"
    ],
    childObjFields: [],
    queryCriteria: ' '
  };

  fetchDocDetlVerifier() { 
      getSobjectDataNonCacheable({params: this.docDetParams}).then((result) => {
        this.showSpinner=false;
        console.log("RCU Details DOCUMENT DETAILS #765", result);
          if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
            this.appModalData = result.parentRecords;   
            this.appModalData.forEach(i=>{
              if(i.CreditReqSampling__c){
                i.disRcuStat= true;
              }
              if(i.RCUFileStatus__c === 'Hold'){
                i.isRemarkReq=true
              }
              if(i.DocValidStatus__c === 'Success'){
                i.docValidated=true;
              }
            })       
            console.log("RCU Details DOCUMENT DETAILS #773", this.appModalData);
            this.appModalData.forEach(row1 => {
              const dateTime1 = new Date(row1.ClosedDate);
              const dateTime2 = new Date(row1.RCUInitiDateTime__c);
                const formattedDate1 = formattedDateTimeWithoutSeconds(dateTime1); 
                const formattedDate2 = formattedDateTimeWithoutSeconds(dateTime2); 
                const dateOfIntiation1 = `${formattedDate1}`;
                const dateOfIntiation2 = `${formattedDate2}`;
                row1.ClosedDate = dateOfIntiation1;
                row1.initiationDate = dateOfIntiation2;
            });
            this.initializeData1(this.appModalData);
          }

          
          this.prepareTableData();
          this.docIds=[];
          
        })
        .catch((error) => {
          this.showSpinner=false;
          console.log("RCU Details DOCUMENT DETAILS #594", error);
        });
    }

    initializeData1(docList) {
      this.appModalData = docList.map(item => {
          let ValidationStatus;
          if (item.DocValidStatus__c === 'Success') {
              ValidationStatus=true
          } else if (item.DocValidStatus__c === 'Failure') {
              ValidationStatus=false;
          }
          return { ...item,ValidationStatus };
      });
      console.log('docList:::::1048',this.docList);
  }


  prepareData(){
    let arr=this.appModalData.map(record => {
      return {
          ...record,
          // Include any additional processing if needed
      };
     })
  }
  @track rucInitcolumns = [
    {
      label: 'Document Name',
      fieldName: 'DocTyp__c',
      type: 'text',
      sortable: true,
      cellAttributes: {
          tooltip: { fieldName: 'DocTyp__c' }
      }
  },
  {
      label: 'Document Type',
      fieldName: 'DocSubTyp__c',
      type: 'text',
      sortable: true,
      cellAttributes: {
          tooltip: { fieldName: 'DocSubTyp__c' }
      }
  },
  {
      label: 'RCU Status',
      fieldName: 'RCUFileStatus__c',
      type: 'picklist',
      editable: false,
      typeAttributes: {
          placeholder: 'Select RCU Status',
          options: this.rcuStatusOptions,
          value: { fieldName: 'RCUFileStatus__c' },
          context: { fieldName: 'Id' },
          disabled: true, // Set to false if editing is allowed
          required: true
      },
      cellAttributes: {
          class: 'slds-m-bottom_medium'
      }
  },
  {
    label: 'RCU Hold Remarks',
    fieldName: 'RCURemarks__c',
    type: 'text',
    sortable: true,
    cellAttributes: {
        tooltip: { fieldName: 'RCURemarks__c' }
    }
},
  {
      label: 'Agency RCU Status',
      fieldName: 'AgencyDocStatus__c',
      type: 'picklist',
      editable: false,
      typeAttributes: {
          placeholder: 'Select Agency RCU Status',
          options: this.agencyRcuStatusOptions,
          value: { fieldName: 'AgencyDocStatus__c' },
          context: { fieldName: 'Id' },
          disabled: true, // Set to false if editing is allowed
          required: true
      },
      cellAttributes: {
          class: 'slds-m-bottom_medium'
      }
  },
  {
      type: 'button',
      typeAttributes: {
          label: 'View',
          name: 'view',
          title: 'View Document',
          variant: 'brand',
          disabled: false,
          value: 'view',
          iconPosition: 'left'
      }
  }
];

handleRcuInitAction(event) {
  const actionName = event.detail.action.name;
  const row = event.detail.row;

  switch (actionName) {
      case 'view':
          this.viewDocument(row);
          break;
      // Add more cases if there are additional row actions
      default:
          break;
  }
}

viewDocument(row) {
  // Access row data using row.<fieldName>
  const docId = row.Id;
  this.showSpinner=true;
  this.viewDoc =false;
  this.docId=null;
      this.docId = docId; // Set new document ID
      this.hasDocId = true;
    console.log("docId ", this.docId);

      // Optionally, you can use a setTimeout to simulate asynchronous behavior
      setTimeout(() => {
          this.viewDoc = true; // Show document preview
          this.showSpinner = false; // Hide spinner after a short delay
      }, 1000);

}

@track rcuProfCheckcolumns = [
  {
      label: 'Document Name',
      fieldName: 'appName',
      type: 'text',
      editable: false,
      cellAttributes: { alignment: 'left' }
  },
  {
      label: 'Address Type',
      fieldName: 'appAddrType',
      type: 'text',
      editable: false,
      cellAttributes: { alignment: 'left' }
  },
  {
      label: 'Full Address',
      fieldName: 'fullAddr',
      type: 'text',
      editable: false,
      cellAttributes: { alignment: 'left' }
  },
  {
      label: 'RCU Status',
      fieldName: 'RCUFileStatus__c',
      type: 'picklist',
      typeAttributes: {
          placeholder: 'Choose status',
          options: { fieldName: 'rcuStatOptions' },
          value: { fieldName: 'RCUFileStatus__c' },
          context: { fieldName: 'Id' },
          disabled: true
      }
  },
  {
    label: 'RCU Hold Remarks',
    fieldName: 'RCURemarks__c',
    type: 'text',
    sortable: true,
    cellAttributes: {
        tooltip: { fieldName: 'RCURemarks__c' }
    }
},
  {
      label: 'Agency RCU Status',
      fieldName: 'AgencyDocStatus__c',
      type: 'picklist',
      typeAttributes: {
          placeholder: 'Choose status',
          options: { fieldName: 'agcStatOptions' },
          value: { fieldName: 'AgencyDocStatus__c' },
          context: { fieldName: 'Id' },
          disabled: true,
          required: true
      }
  }
];
  handleViewDocument(event){
    this.showSpinner=true;
    this.viewDoc =false;
    this.docId=null;
    let dataValue = event.target.dataset.name;
   
    if (dataValue === "ViewDoc") {
        this.docId = event.target.dataset.docId; // Set new document ID
        this.hasDocId = true;
      console.log("docId ", this.docId);
  
        // Optionally, you can use a setTimeout to simulate asynchronous behavior
        setTimeout(() => {
            this.viewDoc = true; // Show document preview
            this.showSpinner = false; // Hide spinner after a short delay
        }, 1000);
  }
  }

  handleRCUbutton(event){
// To View Case Details under View Button of assigned case to Agencies
let dataValue = event.target.dataset.name;
if (dataValue === "ViewAgcCase") {
  this.showSpinner=false;
  let caseid= event.target.dataset.caseid;


}
if (dataValue === "Re-Intiate") {
  this.showSpinner=false;
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
  this.showSpinner=false;
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
  this.showSpinner=false;
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


  handleIntialization() {
      let isInputCorrect = this.validateForm();
      if(isInputCorrect){
      this.showSpinner = true;
      let filteredData = this.appModalData.filter(item => item.RCUInitiated__c === true);
      console.log('filteredData for case creation ', JSON.stringify(filteredData));
      filteredData.forEach(item => {
          let fields = {};
          fields.sobjectType = 'Case';
          fields.Applicant__c = item.appId != null ? item.appId : '';
          fields.ApplAddr__c = item.appAdrrsId != null ? item.appAdrrsId : '';
          fields.Loan_Application__c = item.loanAppId != null ? item.loanAppId : '';
          fields.City__c = item.addrCity != null ? item.addrCity : '';
          fields.RecordTypeId = this.recordTypeId;
          fields.Status = 'New';
          fields.Origin = 'Web';
          fields.AccountId = this.accId1;
          fields.ContactId = this.contactId1;
 
         // fields.Remarks_for_Technical_Agency__c=item.Remarks_for_Technical_Agency__c;

          this.caseRecords.push(fields);
      })
  }
      console.log('caseRecords ', JSON.stringify(this.caseRecords));
      if(this.caseRecords && this.caseRecords.length>0){
          upsertMultipleRecord({ params: this.caseRecords })
          .then((result) => {
              const evt = new ShowToastEvent({
                  title: 'Success',
                  variant: 'success',
                  message: 'RCU CASE ASSIGNED TO AGENCY'+ this.accLabel,
                  mode: 'sticky'
              });
              this.caseRecords = [];
              this.appModalData.forEach(item => {
                  item.selectCheckbox = false;
              });
              this.actionName='';
              this.accId1=''
              this.accLabel=''
              this.showSpinner = false;
              this.isModalOpen = false;
          })
          .catch((error) => {
              console.log('Error In creating Record', error);
              const evt = new ShowToastEvent({
                  title: 'Error',
                  variant: 'error',
                  message: error.body.message,
                  mode: 'sticky'
              });
              this.dispatchEvent(evt);
              this.showSpinner = false;
              this.isModalOpen = false;
              
          });
      }
      
      else{
          const evt = new ShowToastEvent({
              title: 'Error',
              variant: 'error',
              message: 'Please fill the required fields',
              mode: 'sticky'
          });
          this.dispatchEvent(evt);
          this.showSpinner = false;
      }    

  }

/* -------------------CASE QUERY---------------- */


  handleteamHierIdChange() {
    let tempParams = this.teamHierParam;
    tempParams.queryCriteria = ' where Employee__c = \'' + this.currentUserId + '\' limit 1' ;
    this.teamHierParam = { ...tempParams };
}

@track teamHierParam = {
  ParentObjectName: 'TeamHierarchy__c',
  ChildObjectRelName: '',
  parentObjFields: ['Id','EmpRole__c','Employee__c','Employee__r.Name','EmpLoc__c','EmpLoc__r.City__c'],
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
              if(this.rcuMangerRoles && this.rcuMangerRoles.length>0){
                this.rcuMangerRoles.forEach(i=>{
                  if(i===this.userRole){
                    this.managerView=true;
                  }
                })
              }
          }
                    
      }
      if(error){
          console.error('ERROR CASE DETAILS:::::::#420',error)
      }
  }




  @api handleValueSelect(event){
    let childEvt = event.detail;
    console.log('childEvt in TSR component::::#340',childEvt );
    this.getCaseData();

}   

// get disableMode(){
//   return !this.hasEditAccess;
// }



disconnectedCallback() {
    this.unsubscribeMC();
    releaseMessageContext(this.context);
}
unsubscribeMC() {
    unsubscribe(this.subscription);
    this.subscription = null;
}

  generatePicklist(data) {
    return data.values.map((item) => ({
      label: item.label,
      value: item.value
    }));
  }


get openPopupModal(){
  return this.caseAvl;
}
    checkCaseDetails(accountId){
      let recordType='RCU';
      let status='Closed'
      let paramsCase = {
        ParentObjectName: "Case",
        parentObjFields: [
          "Id","CaseNumber","AccountId","ContactId","ClosedDate","Account.Name",
          "Contact.Name","Status","Loan_Application__c", 'OwnerId','Owner.Name'  
        ],
          queryCriteria:' where Status != \''+status+'\' AND Loan_Application__c=\''+this._loanAppId+'\' AND AccountId =\'' +accountId+'\' AND RecordType.DeveloperName = \''+recordType+ '\' order by createdDate asc'
      };
      getSobjectData1({ params: paramsCase }).then((result) => {
        this.showSpinner=false;
        console.log(' CASES IN PROGRESS:::::603', result);
        if(result && result.parentRecords){
          this.reviewModalOpen=true;
        }
      
        if (result.error) {
          this.showSpinner=false;
          console.error("case result getting error=", result.error);
        }
      });
    }
  
  get caseId() {
    return `${this.caseRecordId}`;
  }

  get disableAgcAsgnBtn(){
    return  this.noRec && this.noAddrRec;
  }

@track actionName;
get sampleAction(){
return this.actionName==='Sample';
}

get assignAction(){
  return this.actionName==='Agency Assignment';
  }
get caseId(){
  let val=''
  if(this.caseRecordId){
    val = this.caseRecordId;
  }
  return val;
}

  @track checked = false;
  @track assignCaseId;
  @track viewCaseId;
  @track viewDoc;
  handlebutton(event) {
    this.actionName='';
    this.docIds=[];
    this.addrIds=[];
    this.viewDoc =false;
    console.log("dataname is ", event.target.dataset.name);
    let dataValue = event.target.dataset.name;
    this.actionName=event.target.dataset.name;
    this.showSpinner=true;
    // TO View Document in Sample and Assign Agency Button 
    this.viewCaseId= ''
    // To View Cases under RCU Verifiers
    if (dataValue === "View") {
      let caseid= event.target.dataset.caseid;
      this.viewCaseId= caseid;
      // this.caseId= caseid;
      if(!this.caseRecordId){
        this.caseRecordId = event.target.dataset.caseid;
        console.log("caseRecordId ", this.caseRecordId);
        this.fetchCaseDoc(this.caseRecordId);
        this.getAgencyCaseData(this.caseRecordId);
        this.renderCaseDetails = true;
      }else {
        if(this.caseRecordId === event.target.dataset.caseid){
          this.renderCaseDetails = false;
          this.caseRecordId=null
          this.showSpinner=false;
        }else{
          this.caseRecordId='';
          this.caseRecordId = event.target.dataset.caseid;
          this.fetchCaseDoc(this.caseRecordId);
          this.getAgencyCaseData(this.caseRecordId);
          this.renderCaseDetails = true;
        }
      }

       
    }
    // Tp show documents under RCU Verifiers in Sample Button
    if (dataValue === "Sample") {
      this.renderCaseDetails=false;
      let caseid= event.target.dataset.caseid;
      console.log("caseid 1508", caseid);
      this.fetchCaseDoc(caseid);

    }
    // To assign Agencies under Agency Assigment button 
    if (dataValue === "Agency Assignment") {
      this.renderCaseDetails=false;
      let caseid= event.target.dataset.caseid;
     // this.viewCaseId= caseid;
      console.log("caseid 1508", caseid);
      this.assignCaseId=caseid;
      this.fetchCaseDoc(caseid);
    }
    
  }


  handleCreditButton(event){
    this.actionName = 'View'
    let dataValue = event.target.dataset.name;
    if (dataValue === "View") {
      let caseid= event.target.dataset.caseid;
      // this.caseId= caseid;
      if(!this.caseRecordId){
        this.caseRecordId = event.target.dataset.caseid;
        console.log("caseRecordId ", caseid);
        this.fetchCaseDoc(this.caseRecordId);
        this.getAgencyCaseData(this.caseRecordId);
        this.renderDocDetails = true;
      }else {
        if(this.caseRecordId === event.target.dataset.caseid){
          this.renderDocDetails = false;
          this.caseRecordId=null
          this.showSpinner=false;
        }else{
          this.caseRecordId='';
          this.caseRecordId = event.target.dataset.caseid;
          this.fetchCaseDoc(this.caseRecordId);
          this.getAgencyCaseData(this.caseRecordId);
          this.renderDocDetails = true;
        }
      }
       
    }

    if (dataValue === "View Cases") {
      let caseid= event.target.dataset.caseid;
      // this.caseId= caseid;
      if(!this.caseRecordId){
        this.caseRecordId = event.target.dataset.caseid;
        console.log("caseRecordId ", caseid);
        this.getAgencyCaseData(this.caseRecordId);
        this.showCases = true;
      }else {
        if(this.caseRecordId === event.target.dataset.caseid){
          this.showCases = false;
          this.caseRecordId=null
          this.showSpinner=false;
        }else{
          this.caseRecordId='';
          this.caseRecordId = event.target.dataset.caseid;
          this.getAgencyCaseData(this.caseRecordId);
          this.showCases = true;
        }
      }
       
    }
  }

@track caseDocList=[]
@track docIds=[];
@track addrIds=[];
  fetchCaseDoc(caseid){
    let caseDocParams = {
      ParentObjectName: "CaseDoc__c",
      ChildObjectRelName: "",
      parentObjFields: ["Id", "Case__c", "DocDetail__c","ApplAddr__c"],
      childObjFields: [],
      queryCriteria: ' where Case__c = \''+ caseid + '\''
    };
    getSobjectDataNonCacheable({params: caseDocParams}).then((result) => {
      this.showSpinner=false;
      this.appModalData=[];
      this.addrVerData=[];
      this.addrVerCredit=[];
      this.addrIds=[];
      console.log('fetchCaseDoc result::::::1536',result);
      if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
        this.caseDocList = result.parentRecords;
        this.caseDocList.forEach((e)=>{
          if(e.DocDetail__c){
            this.docIds.push(e.DocDetail__c);
          }
          if(e.ApplAddr__c){
            this.addrIds.push(e.ApplAddr__c);
          }
          console.log('this.docIds:::::1495',this.docIds);
          console.log('this.addrIds:::::1496',this.addrIds);
        })
  //  if(this.docIds && this.docIds.length>0){
      if(this.actionName === 'View'){
        let tempParams = this.docDetParams;
        tempParams.queryCriteria =
        ' where ID IN (\''+this.docIds.join('\', \'') + '\')  AND RCUInitiated__c = true AND AgencyAssigned__c != true AND IsDeleted__c != true';
        this.docDetParams = { ...tempParams };
        this.fetchDocDetlVerifier();
        this.getRcuInitiatedProfile(this.appData);
      } 
      if(this.actionName ==='Agency Assignment'){
      let rcuStatus='Sampled'
      let tempParams = this.docDetParams;
      tempParams.queryCriteria =
        ' where ID IN (\''+this.docIds.join('\', \'') + '\') AND RCUInitiated__c = true AND RCUFileStatus__c =\''+rcuStatus+'\' AND AgencyAssigned__c != true AND IsDeleted__c != true';
      this.docDetParams = { ...tempParams };
      this.fetchDocDetlVerifier();
      this.getRcuInitProfAssig(this.appData);
      if(this.branchCity){
        this.fetchAgecnyLocMapper();        
      }
      }
     
      }
    })
    .catch((error) => {
      this.showSpinner=false;
      
      console.log("TECHNICAL PROP CASE QUERIES #766", error);
    });
  }

getRcuInitiatedProfile(appData){
  if (appData) {
    this.addrVerData=[];
    this.addrVerCredit=[]
    appData.forEach(item => {
     //   if (item.parentRecord) {
            if (item.ChildReords) {
                item.ChildReords.forEach(childitem => {
                 // if(childitem.RCUProfChecked__c && childitem.RCUFileStatus__c==='Sampled' && !childitem.AgencyAssigned__c){
                  if(childitem.RCUProfChecked__c && !childitem.IsDeleted__c && !childitem.AgencyAssigned__c){
                   let addrFlag= this.addrIds.find(i => i === childitem.Id)
             //       this.addrIds.forEach(i=>{
                      if(addrFlag){
                        let obj = {};
                        obj.appId = item.parentRecord.Id;
                        obj.loanAppId = this._loanAppId;
                        obj.appName = item.parentRecord.FullName__c;
                        obj.appAdrrsId = childitem.Id;
                        obj.appAddrType = childitem.AddrTyp__c;
                        obj.RCUProfChecked__c = childitem.RCUProfChecked__c;
                        obj.addrCity = childitem.City__c;
                        obj.fullAddr=childitem.FullAdrs__c;
                        obj.RCUFileStatus__c=childitem.RCUFileStatus__c;
                        obj.SampleTrigger__c=childitem.SampleTrigger__c;
                        obj.RCURemarks__c=childitem.RCURemarks__c;
                        obj.RCUInitiDateTime__c=childitem.RCUInitiDateTime__c;
                        obj.AgencyDocStatus__c=childitem.AgencyDocStatus__c;
                        const dateTime2 = new Date(childitem.RCUInitiDateTime__c);
                          const formattedDate2 = formattedDateTimeWithoutSeconds(dateTime2); 
                          const dateOfIntiation2 = `${formattedDate2}`;
                          obj.initiationDate = dateOfIntiation2;
                        this.addrVerData.push(obj);
                      }
                //    })
                  
                  }
                  if(childitem.RCUProfChecked__c){
                    this.addrIds.forEach(i=>{
                      if(i===childitem.Id){
                        let obj = {};
                        obj.appId = item.parentRecord.Id;
                        obj.loanAppId = this._loanAppId;
                        obj.appName = item.parentRecord.FullName__c;
                        obj.appAdrrsId = childitem.Id;
                        obj.appAddrType = childitem.AddrTyp__c;
                        obj.RCUProfChecked__c = childitem.RCUProfChecked__c;
                        obj.addrCity = childitem.City__c;
                        obj.fullAddr=childitem.FullAdrs__c;
                        obj.RCUFileStatus__c=childitem.RCUFileStatus__c;
                        obj.SampleTrigger__c=childitem.SampleTrigger__c;
                        obj.RCURemarks__c=childitem.RCURemarks__c;
                        obj.RCUInitiDateTime__c=childitem.RCUInitiDateTime__c;
                        obj.AgencyDocStatus__c=childitem.AgencyDocStatus__c;
                     
                        const dateTime2 = new Date(childitem.RCUInitiDateTime__c);
                          const formattedDate2 = formattedDateTimeWithoutSeconds(dateTime2); 
                          const dateOfIntiation2 = `${formattedDate2}`;
                          obj.initiationDate = dateOfIntiation2;
                        this.addrVerCredit.push(obj);
                      }
                    })
                  
                  }
                  console.log('this.addrVerData is 1607', this.addrVerData);
                  console.log('this.addrVerCredit is 2298', this.addrVerCredit);
                })
         //   }

        }
    });
}
}

getRcuInitProfAssig(appData){
  if (appData) {
   this.addrVerData=[];
    this.addrVerData=[];
    appData.forEach(item => {
        if (item.parentRecord) {
            if (item.ChildReords) {
                item.ChildReords.forEach(childitem => {
                  if(childitem.RCUProfChecked__c && childitem.RCUFileStatus__c==='Sampled' && !childitem.AgencyAssigned__c){
                    let addrFlag= this.addrIds.find(i => i === childitem.Id)
                //    this.addrIds.forEach(i=>{
                      if(addrFlag){
                        let obj = {};
                        obj.appId = item.parentRecord.Id;
                        obj.loanAppId = this._loanAppId;
                        obj.appName = item.parentRecord.FullName__c;
                        obj.appAdrrsId = childitem.Id;
                        obj.appAddrType = childitem.AddrTyp__c;
                        obj.RCUProfChecked__c = childitem.RCUProfChecked__c;
                        obj.addrCity = childitem.City__c;
                        obj.fullAddr=childitem.FullAdrs__c;
                        obj.RCUFileStatus__c=childitem.RCUFileStatus__c;
                        obj.SampleTrigger__c=childitem.SampleTrigger__c;
                        obj.RCURemarks__c=childitem.RCURemarks__c;
                        obj.RCUInitiDateTime__c=childitem.RCUInitiDateTime__c;
                        this.addrVerData.push(obj);
                      }
                  //  })
                  }
                })
            }
        }
    });

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
        if (
          this.caseSingleRecordData.Status === "Closed" ||
          this.caseSingleRecordData.Status === "Cancelled"
        ) {
          this.statusOptions = this.reIntiateOptions;
          this.textAreaLabel = "Reason for reinitiated FI";
          this.reInitiateTechnical = true;
        
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
  

  createComment(){
          let comtArr = [];
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
        oldFields.Status = 'Review Requested';
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
 

  handleSaveThroughLms(values) {
    console.log(
      "values to save through Lms IN TECH PRO COMP #796 ",
      JSON.stringify(values)
    );

    this.handleSave(values.validateBeforeSave);
  }

  handleSave(validate) {
    if (validate) {
      let isInputCorrect = this.validateForm();

      console.log("IN TECH PROP COMP if false>>> #806", isInputCorrect);

      if (isInputCorrect === true) {

      } else {

        this.showToastMessage('Error', this.label.Technical_ReqFields_ErrorMessage, 'error', 'sticky');
       
      }
    } else {
      console.log("IN TECH PROP COMP if IN ELSE METHOD>>> #838", );
   }
  }

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

  closeSplitDocModal(){
    this.viewDoc = false;
  }
  closeModal() {
    this.isReInitiateModalOpen = false;
    this.showAgency = false;
    this.reviewModalOpen=false;
    this.appModalData.forEach(item => {
      item['RCUInitiated__c'] = false;
  });

      this.addrData.forEach(item => {
        item['RCUProfChecked__c'] = false;
    });
    this.accId1='';
    this.accId2='';
    this.docArr =[];
    this.actionName='';
  }

  closeTecnicalModal() {
    this.initiateRcu = false;
    this.reInitiateTechnical=false;
    this.caseReinitiated=false;
    this.docArr =[];
    this.addrData=[];
    this.initAll=false;
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
          
          if (this.yesLabel === "Re-Iniate") {
          
            this.showToastMessage('Success', this.label.Technical_ReInitiate_SuccessMessage, 'success', 'sticky');
          } 
          else if(this.yesLabel==='Review'){
          
            this.reviewModalOpen=false;
            this.showToastMessage('Success', this.label.Technical_CaseStatusUpdated, 'success', 'sticky');
          }
          else if(this.yesLabel==='Cancel') {
            this.yesLabel='';
           
            this.showToastMessage('Success', this.label.Technical_Cancel_SuccessMessage, 'success', 'sticky');
          }else{
            //this.showToastMessage('Success', 'Applicant Asset updated successfully', 'success', 'sticky');
          }

          let child = this.template.querySelector('c-case-details');
          child.refreshDocTable();

          this.getCaseData();
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
  handleInitiate() {
  // this.showSpinner=true;
 //  this.fetchRcuUsers();
    this.remarks='';
    this.docList=[]
    this.fetchDcoumentDetails();
    this.getApplicaWithAddressDetails();
    this.initiateRcu = true;
  }
@track caseReinitiated=false;
  handleReInitiate(event) {
    this.remarks='';
    this.caseRecordId = event.target.dataset.caseid;
    this.caseStatus = event.target.dataset.status
    console.log("HANDLE INdocDetParamsITIATE CALLED",this.caseStatus);
    this.docList=[]
    this.fetchDcoumentDetails();
    this.caseReinitiated=true;
    this.reInitiateTechnical = true;
  }

  @track accLabel;
  handleInputChange(event) {
    if (event.target.label === "RCU Agency 1") {
      this.accId1 = event.target.value;
     // this.acc1Label=event.target.dataset.name;
     if(this.accId1){
        this.checkCaseDetails(this.accId1);
        this.noLabel = "No";
        this.reviewSubmitLabel = "Yes";
     }
     console.log('accContactMap:::::1280',this.accContactMap);
      const filteredData = this.accContactMap.find((obj) => {
        return (obj.label === this.accId1)
      });
      if(filteredData && filteredData.value){
        this.contactId1=filteredData.value;
      }
     const label= this.agencyOptions.find((e)=>{
       return e.value === this.accId1;
     })
     if(label){
      this.accLabel=label.label;
     }
   
      console.log('Agecy 1 contact',filteredData);
    
    }


    if (event.target.label === "Remarks for RCU Agency") {
      this.remarks = event.target.value.toUpperCase();
     
    }

    if (event.target.label === "Reviewer Remarks") {
      this.reviewRemarks = event.target.value.toUpperCase();
     
    }

   
    this.caseWrp = event.target.value;
    console.log("caseWrp", this.caseWrp);
  }

@track recSelected=false;
@track docDetArr=[];
  handleClick(event) {
    console.log('HANDLE CLICK IN RCU1340 ', JSON.stringify(event.target.dataset));
    let docid = event.target.dataset.docid;
    if(event.target.dataset.label==='RCU Status'){
      
      let indexId = event.target.dataset.index;
      let val = event.target.value;
      console.log('val ', val, 'docid ', docid,'indexId',indexId);

      let temp = this.appModalData[indexId];
      temp.RCUFileStatus__c=val;
      temp.isRemarkReq = val && val === 'Hold'  ? true : false;
      this.appModalData[indexId] = {...temp};      

     let tempArray = [...this.appModalData];
     tempArray[event.target.dataset.index] = this.appModalData[indexId];
     this.appModalData = [...tempArray];

      this.docDetArr=[...tempArray];
      
  }
  if(event.target.dataset.label==='Sample Trigger'){
      
    let indexId = event.target.dataset.index;
    let val = event.target.value.toUpperCase();
    console.log('val ', val, 'docid ', docid,'indexId',indexId);

    let temp = this.appModalData[indexId];
    temp.SampleTrigger__c=val;
    this.appModalData[indexId] = {...temp};      

   let tempArray = [...this.appModalData];
   tempArray[event.target.dataset.index] = this.appModalData[indexId];
   this.appModalData = [...tempArray];

    this.docDetArr=[...tempArray];
    
}

if(event.target.dataset.label==='RCU Hold Status'){
      
  let indexId = event.target.dataset.index;
  let val = event.target.value.toUpperCase();
  console.log('val ', val, 'docid ', docid,'indexId',indexId);

  let temp = this.appModalData[indexId];
  temp.RCURemarks__c=val;
  this.appModalData[indexId] = {...temp};      

 let tempArray = [...this.appModalData];
 tempArray[event.target.dataset.index] = this.appModalData[indexId];
 this.appModalData = [...tempArray];

  this.docDetArr=[...tempArray];
  
}
      console.log('this.docDetArr :::1338', JSON.stringify(this.docDetArr));

             
          if(event.target.dataset.label==='Initiate RCU'){
            console.log('this.appModalData :::1488', JSON.stringify(this.appModalData))
            let val =event.target.checked;
         
            let indexId = event.target.dataset.index; 
             
              let temp = this.appModalData[indexId];
              temp.selectCheckbox =val;
              this.appModalData[indexId] = {...temp};

              let tempArray = [...this.appModalData];
              tempArray[event.target.dataset.index] = this.appModalData[indexId];
              this.appModalData = [...tempArray];
              this.docArr=[...tempArray];
              this.noRec=true;
              this.docArr.forEach(element => {
                if(element.selectCheckbox){
                  this.noRec=false;
                }
               });
              console.log('this.appModalData :::1807', JSON.stringify(this.appModalData))
            
          }
         
          console.log('this.appModalData FINAL :::1811', JSON.stringify(this.appModalData),':::',this.appModalData.length)
}

handleProfCheckClick(event) {
  console.log('HANDLE CLICK IN RCU 2069 ', event.target.dataset);
  let addrid = event.target.dataset.docid;
  if(event.target.dataset.label==='RCU Status'){
    let indexId = event.target.dataset.index;
    let val = event.target.value;
    console.log('val ', val, 'addrid ', addrid,'indexId',indexId);

    let temp = this.addrVerData[indexId];
    temp.RCUFileStatus__c=val;
    temp.isRemarkReq = val && val === 'Hold'  ? true : false;
    this.addrVerData[indexId] = {...temp};      

   let tempArray = [...this.addrVerData];
   tempArray[event.target.dataset.index] = this.addrVerData[indexId];
   this.addrVerData = [...tempArray];
    
}
if(event.target.dataset.label==='Sample Trigger'){
    
  let indexId = event.target.dataset.index;
  let val = event.target.value.toUpperCase();
  console.log('val ', val, 'addrid ', addrid,'indexId',indexId);

  let temp = this.addrVerData[indexId];
  temp.SampleTrigger__c=val;
  this.addrVerData[indexId] = {...temp};      

 let tempArray = [...this.addrVerData];
 tempArray[event.target.dataset.index] = this.addrVerData[indexId];
 this.addrVerData = [...tempArray];  
}

if(event.target.dataset.label==='RCU Hold Status'){
    
let indexId = event.target.dataset.index;
let val = event.target.value.toUpperCase();
console.log('val ', val, 'addrid ', addrid,'addrid',indexId);

let temp = this.addrVerData[indexId];
temp.RCURemarks__c=val;
this.addrVerData[indexId] = {...temp};      

let tempArray = [...this.addrVerData];
tempArray[event.target.dataset.index] = this.addrVerData[indexId];
this.addrVerData = [...tempArray];

}
    console.log('this.docDetArr :::1338', JSON.stringify(this.docDetArr));

           
        if(event.target.dataset.label==='Initiate Profile RCU'){
          console.log('this.addrVerData :::1488', JSON.stringify(this.addrVerData))
          let val =event.target.checked;
       
          let indexId = event.target.dataset.index; 
           
            let temp = this.addrVerData[indexId];
            temp.selectCheckbox =val;
            this.addrVerData[indexId] = {...temp};

            let tempArray = [...this.addrVerData];
            tempArray[event.target.dataset.index] = this.addrVerData[indexId];
            this.addrVerData = [...tempArray];
            this.docArr=[...tempArray];
            this.noAddrRec=true;
            this.docArr.forEach(element => {
              if(element.selectCheckbox){
                this.noAddrRec=false;
              }
             });
            console.log('this.addrVerData :::2133', JSON.stringify(this.addrVerData))
          
        }
       
        console.log('this.addrVerData FINAL :::2137', this.addrVerData,':::',this.addrVerData.length)
}

@track allscreenDoc=true;
@track allscreenAddr=true;
@track docDtHold=false;
@track addrHold=false;
handleUpdate(){
  this.showSpinner=true;
  this.allscreenDoc=true;
  this.allscreenAddr=true;
  let isInputCorrect = this.validateForm();
  if (isInputCorrect) {

  let tempArr=[];
  if(this.docDetArr && this.docDetArr.length>0){
    this.docDetArr.forEach(i=>{
      delete i.ValidationStatus;
    })
   
    let caseDocArr=[];
    this.docDetArr.forEach(i=>{
      let obj ={}
      obj.Id= i.Id;
      obj.RCUFileStatus__c=i.RCUFileStatus__c;
      obj.SampleTrigger__c=i.SampleTrigger__c;
      obj.RCURemarks__c=i.RCURemarks__c;
      if(i.RCUFileStatus__c ==='Hold'){
        obj.RCUHoldDateTime__c=new Date().toISOString();
      }
      if(i.RCUFileStatus__c ==='Hold'){
        this.docDtHold=true;
      }
      if(i.RCUFileStatus__c !=='Screened'){
        this.allscreenDoc=false;
      }
      obj.SamplingDateTime__c= new Date().toISOString();
      obj.sobjectType='DocDtl__c';
      tempArr.push(obj);
    })
    console.log('docDetArr:::::1815',tempArr);
  }
  
    if(tempArr){
      this.upsertData(tempArr);
    }
    
  
    let tempAddrArr=[];

    if(this.addrVerData && this.addrVerData.length>0){
     
      this.addrVerData.forEach(i=>{
        let obj ={}
        obj.Id= i.appAdrrsId;
        obj.RCUFileStatus__c=i.RCUFileStatus__c;
        obj.SampleTrigger__c=i.SampleTrigger__c;
        obj.RCURemarks__c=i.RCURemarks__c;
        obj.sobjectType='ApplAddr__c';
        if(i.RCUFileStatus__c ==='Hold'){
          obj.RCUHoldDateTime__c=new Date().toISOString();
        }
        if(i.RCUFileStatus__c ==='Hold'){
          this.addrHold=true;
        }
        if(i.RCUFileStatus__c !=='Screened'){
          this.allscreenAddr=false;
        }
        obj.SamplingDateTime__c= new Date().toISOString();
        tempAddrArr.push(obj);
      })
    }
    if(tempAddrArr){
      console.log('tempAddrArr::::::2180',tempAddrArr);
      this.upsertData(tempAddrArr);
    }

    this.getCaseData();
  }else{
    this.showSpinner=false;
  }
  
}

@track caseRecId;
@track showReport=false;
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
getDocDetailId(caseid){
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
upsertCaseDocData(obj){
  if(obj){   
  console.log('Document Detail Records update ##1524', obj); 
  
  upsertMultipleRecord({ params: obj })
  .then(result => {     
      console.log('Document Detail Records update ##1508', result);
      this.showToastMessage('Success', 'Case Document Details Updated Successfully', 'success', 'sticky');
      this.showSpinner=false;
      
  })
  .catch(error => {
    this.showSpinner = false;
    console.error('Line no RCU DETAILS ##2102', error)
  })
}
}
  handleCase(){ 
   // let tempArr=[];
   let allDocCheck=true
   let filteredData=this.docList.filter(item => item.RCUInitiated__c === true);
    filteredData.forEach(item=>{
     let docAvl;
     docAvl= this.mapChilds.get(item.Id);
     console.log('docAvl::::2051',docAvl);
      if(!docAvl){
        allDocCheck=false;
        this.showToastMessage('Error','Please Upload File for Available in File Documents '+item.DocTyp__c +' : '+item.DocSubTyp__c ,'error','sticky');
      }
    })
    if(allDocCheck){
      this.showSpinnerModal = true;
      this.checkInitiate=false;
  
      this.createCase();
      //this.showSpinner=true;
    }
   
   
  }


  updateAppl(obj){
    if(obj){   
      console.log('Applicant Address Records update for Prof Check ##2285', obj); 
      
      upsertMultipleRecord({ params: obj })
      .then(result => {     
          console.log('Appliacant Records update ##2289', result);
          this.showToastMessage('Success', 'Applicant Address updated for Profile Check Successfully', 'success', 'sticky');
       
          this.showSpinner=false;
          
      })
      .catch(error => {
        this.showSpinner = false;
        console.error('Line no RCU DETAILS ##2297', error)
      })
    }
  }

  @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
  getObjectInfo({ error, data }) {
    if (data) {
      console.log("DATA in RECORD TYPE ID IN RCU Details #1308", data);
      for (let key in data.recordTypeInfos) {
        let recordType = data.recordTypeInfos[key];
        console.log("recordTypeId.value>>>>>", recordType.name);
        if (recordType.name === "RCU") {
          this.recordTypeId = key;
        }
        console.log("data.recordTypeId in tsr details::::1315", this.recordTypeId);
      }
    } else if (error) {
      console.error("Error fetching record type Id", error);
    }
  }



@track caseIDArray=[]
 
  createCase() {
    if (this.validateForm()) {
      this.showSpinner = true;
      try {
        let tempArray = [];
        let caseObj = {};

          if(this.accId1){
            caseObj = {};
            caseObj.sobjectType = 'Case';
            caseObj.RecordTypeId = this.recordTypeId;
            caseObj.AccountId = this.accId1;
            caseObj.ContactId = this.contactId1;
            caseObj.Status = "New";
            caseObj.Origin = "Web";
            caseObj.Product_Type__c=this.lanProd;
            caseObj.Main_Applicant_Name__c = this.mainApp;
            caseObj.Loan_Application__c = this._loanAppId;
            caseObj.Applicant__c =this._applicantId; 
    
            caseObj.RCUType__c = 'Fresh'
            caseObj.Branch_Name__c = this.branchName;
            caseObj.Remarks_for_Technical_Agency__c = this.remarks;
            caseObj.City__c = this.branchCity;
            caseObj.Case__c=this.assignCaseId;
           

            console.log("fields::::: #740", caseObj);
          }
          if(this.rcuUser){
            this.showSpinner = true;
            tempArray.push(caseObj);
            console.log("fields::::: #2035", caseObj);
          } else{
            if(this.openCaseId && this.openCaseOwner){
              this.caseIDArray=[];
              this.caseIDArray.push(this.openCaseId);
              this.createCaseDocument();
            }else{
              let fields = {};
              fields.sobjectType= 'Case';
              fields.Loan_Application__c = this._loanAppId;
              fields.City__c = this.brchCode;
              fields.RecordTypeId = this.recordTypeId;
              fields.Remarks_regarding_the_case__c = this.remarks;
              fields.Status = 'New';
              fields.Origin = 'Web';
              fields.Product_Type__c=this.lanProd;
              fields.Branch_Name__c = this.branchName;
              fields.Main_Applicant_Name__c = this.mainApp;
              fields.IsRouRobAllowd__c = true;
              tempArray.push(fields);
            }
            
          }        
           
            console.log('upsert data //1535 -', JSON.stringify(tempArray))

            upsertMultipleRecord({ params: tempArray })
                .then(result => {
                  this.initiateRcu=false;
                  this.reInitiateTechnical=false;
                 
                  let arr = [...result];
                  let tempArr=[]
                    console.log('Case Created Record Created ##1571', result);
                    arr.forEach(item=>{
                      tempArr.push(item.Id)
                    })
                    this.caseIDArray= tempArr
                    console.log('Case Created Record  case Id Array ##1538',  this.caseIDArray, tempArr);
                    //this.updateApplicantAsset();
                    this.disableInitiate=true;
                    if(this.accLabel){
                      this.showToastMessage('Success', 'RCU CASE ASSIGNED TO AGENCY:  '+this.accLabel, 'success', 'sticky');
                     // this.fetchCaseDoc(this.assignCaseId);
                     this.actionName='Sample';
                    }
                    else{
                      this.docSelctArr=[];
                      this.showToastMessage('Success', 'RCU CASE ASSIGNED TO Verifier  ', 'success', 'sticky');
                    }
                    this.caseReinitiated=false;
                    this.checkInitiate=false;
                    this.showSpinner = false;
                    this.showSpinnerModal = false;
                  
                  
                    refreshApex(this.wiredData);
                    
                    this.accId1='';
                    this.accId2='';
                    this.assignCaseId='';
                    this.getCaseData();
                    this.createCaseDocument();
                    let lanObj=[]
                    let obj ={}
                    obj.sobjectType='LoanAppl__c';
                    obj.Id=this._loanAppId;
                    obj.LANRCUStatus__c='';
                    obj.FinalRCUManagerRemarks__c='';
                    lanObj.push(obj);
                    this.UpdateLANStatus(lanObj);
                   
                    
                })
                .catch(error => {
                  this.showSpinner = false;
                  this.showSpinnerModal = false;
                  this.checkInitiate=false;
                  //this.showToastMessage('Error', error.body.pageErrors[0].message, 'error', 'sticky');
                    console.error('Line no ##1577', error)
                })


    }
     catch (e) {
        console.error('Final Error #1582', e)
    }
    }else{
      this.showSpinner = false;
      this.showSpinnerModal = false;
    }
}
  
get selectDoc(){
  return this.initiateRcu;
}
  validateForm() {
    let isValid = true;
    if(this.selectDoc){
      let filterArr= this.docSelctArr.filter(item => item.RCUInitiated__c === true || item.RCUProfChecked__c===true);
      console.log('filterArr::::::2625',filterArr);
      
      if (filterArr === undefined || (filterArr && filterArr.length < 1 )) {
        isValid = false;
        this.showToastMessage('Error', this.label.Technical_Doc_ErrorMessage, 'error', 'sticky');
      
      }
    }
   
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
    if(!this.rcuUser){
      this.template.querySelectorAll("lightning-textarea").forEach((element) => {
        if (element.reportValidity()) {
          //console.log('element passed lightning input');
        } else {
          isValid = false;
          this.showToastMessage('Error', 'Please Enter Remarks for RCU Agency', 'error', 'sticky');
        }
      });
      return isValid;
    }else{
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
   
  }

  createCaseDocument() {
    if(!this.rcuUser){
    // Create Case Document for RCU Initiate of Doc Dtl Check by CPA / UW User
     let objList=[];
     let arr=[];
     console.log('filteredData 2106::::::',this.docList);
     let tempArr = [...this.docList];
     let filteredData=tempArr.filter(item => item.RCUInitiated__c === true || item.RCUProfChecked__c===true);
     console.log('filteredData 2109::::::',filteredData);
        filteredData.forEach(e=>{   
            let obj ={}
            obj.sobjectType='DocDtl__c';
            obj.Id=e.Id;
            obj.RCUInitiated__c=true;
            obj.RCUInitiDateTime__c=new Date().toISOString();
            if(e.CreditReqSampling__c || e.RCUProfChecked__c){
              obj.RCUFileStatus__c='Sampled';
              obj.CreditReqSampling__c=e.CreditReqSampling__c;
            }           
            objList.push(obj);
            arr.push(e.Id);
            this.docArr=[...arr]; 

        })
        console.log('docArr:::::2127',this.docArr);
        if(objList){
          console.log('objList:::::1778',objList);
          this.upsertData(objList);
        }

       
        let caseDocDtl=[];
        this.docArr.forEach(item=>{
          const fields = {};
         // this.caseIDArray.forEach(element=>{
            fields.Case__c=this.caseIDArray[0];
            fields.DocDetail__c=item;
            fields.sobjectType='CaseDoc__c'
            caseDocDtl.push(fields);
        //  })
        })
        console.log('caseDocDtl:::::2398',caseDocDtl);
        if(caseDocDtl && caseDocDtl.length>0){
          this.upsertDataCaseDoc(caseDocDtl);
        }
   // Create Case Document for RCU Profile Check by CPA / UW User
        console.log('this.addrData::::2408',this.addrData);
        let filteredAddrData=this.addrData.filter(item => item.RCUProfChecked__c===true);
        console.log('filteredData 2397::::::',filteredAddrData);
        let tempApplArr=[];
        if(filteredAddrData && filteredAddrData.length>0){
          filteredAddrData.forEach(i=>{    
              let objApp={};
              objApp.sobjectType='ApplAddr__c';
              objApp.Id=i.appAdrrsId;
              objApp.RCUProfChecked__c=i.RCUProfChecked__c;
              objApp.RCUInitiated__c=i.RCUProfChecked__c;
              objApp.RCUInitiDateTime__c= new Date().toISOString();
              tempApplArr.push(objApp);
            
          })
        }
        if(tempApplArr && tempApplArr.length>0){
          this.updateAppl(tempApplArr);
        }

        let createCaseDoc=[];
        filteredAddrData.forEach(i=>{
          this.caseIDArray.forEach(c=>{
            let addrFields={}
            addrFields.Case__c=c;
            addrFields.ApplAddr__c=i.appAdrrsId;
            addrFields.sobjectType='CaseDoc__c'
            createCaseDoc.push(addrFields);
          })
        })
        console.log('createCaseDoc:::::2436',createCaseDoc);
        if(createCaseDoc && createCaseDoc.length>0){
          this.upsertDataCaseDoc(createCaseDoc);
        }
    }
    if(this.rcuUser){
      // Create Case Document for RCU Initiate of Doc Dtl Check by Verifier
      this.showSpinner = true;
      let filteredData = this.appModalData.filter(item => item.selectCheckbox === true);
      console.log('filteredData 2444::::::',filteredData);
      let objList=[];
      let arr=[];
        filteredData.forEach(e=>{          
           let obj ={}
           obj.sobjectType='DocDtl__c';
           obj.Id=e.Id;
           obj.AgencyAssigned__c=true;
           objList.push(obj);
 
           arr.push(e.Id);
           this.docArr=[...arr];
           console.log('this.docArr:::::2457',this.docArr);
         })
         if(objList && objList.length>0){
           console.log('objList:::::2460',objList);
           this.upsertData(objList);
           this.showSpinner = true;
         }
         console.log('this.docArr data :::::2464',this.docArr);
 
  //       this.docList.forEach((e)=>{
  //     if(e.RCUInitiated__c){
  //       let arr=[];
  //       delete e.ValidationStatus;
  //       arr.push(e.Id);

  //       this.docArr=[...arr];
  //       console.log('docArr:::::2069',this.docArr);

  //     }
  //  })

  let caseDocDtl=[];
  filteredData.forEach(item=>{
    this.caseIDArray.forEach(element=>{
      const fields = {};
      fields.Case__c=element;
      fields.DocDetail__c=item.Id;
      fields.sobjectType='CaseDoc__c'
      caseDocDtl.push(fields);
    })
  })
  console.log('caseDocDtl by verifier:::::2492',caseDocDtl);
  if(caseDocDtl && caseDocDtl.length>0){
    this.upsertDataCaseDoc(caseDocDtl);
  }

  // Create Case Document for RCU Profile Check by Verifier
  console.log('this.addrData by verifier::::2498',this.addrVerData);
  let filteredAddrData=this.addrVerData.filter(item => item.selectCheckbox===true);
  console.log('filteredData 2631 by verifier::::::',filteredAddrData);
  let tempApplArr=[];
  if(filteredAddrData && filteredAddrData.length>0){
    filteredAddrData.forEach(i=>{    
        let objApp={};
        objApp.sobjectType='ApplAddr__c';
        objApp.Id=i.appAdrrsId;
        // objApp.RCUProfChecked__c=i.RCUProfChecked__c;
        // objApp.RCUInitiated__c=i.RCUProfChecked__c;
        objApp.AgencyAssigned__c=true;
        tempApplArr.push(objApp);
      
    })
  }
  if(tempApplArr && tempApplArr.length>0){
    this.updateAppl(tempApplArr);
  }
  let createCaseDoc=[];

  filteredAddrData.forEach(i=>{
    this.caseIDArray.forEach(c=>{
      let addrFields={}
      addrFields.Case__c=c;
      addrFields.ApplAddr__c=i.appAdrrsId;
      addrFields.sobjectType='CaseDoc__c'
      createCaseDoc.push(addrFields);
    })
  })
  console.log('createCaseDoc by verifier:::::2509',createCaseDoc);
  if(createCaseDoc && createCaseDoc.length>0){
    this.upsertDataCaseDoc(createCaseDoc);
  }

      }



  }


  upsertData(obj){
    if(obj){   
    console.log('Document Detail Records update ##2508', obj); 
    
    upsertMultipleRecord({ params: obj })
    .then(result => {     
        console.log('Document Detail Records update ##2512', result);
        this.showToastMessage('Success', 'Document Details Updated Successfully', 'success', 'sticky');
        this.getApplicaWithAddressDetails();
        this.renderCaseDetails=false;
        // this.fetchCaseDoc(this.viewCaseId);
        // this.renderCaseDetails=true;

        if(this.allscreenDoc && this.allscreenAddr){
          let tempCaseArr=[]
          let objCas={};
          objCas.sobjectType='Case';
          objCas.Id=this.viewCaseId;
          objCas.Status = 'Closed';
          objCas.Final_RCU_status_Reason__c = 'Positive Case';
          objCas.Date_of_Report__c = new Date().toISOString();
          tempCaseArr.push(objCas);
          console.log('tempCaseArr:::::::2837',tempCaseArr);
          if(tempCaseArr){
            this.UpdateCaseStatus(tempCaseArr);
          }
        }else{
          let tempCaseArr=[];
          let objCas={};
          objCas.sobjectType='Case';
          objCas.Id=this.caseId;
          if(this.docDtHold || this.addrHold) {
             objCas.Status='Hold'
            }
            else{
              objCas.Status = 'In Progress';
            } 
          tempCaseArr.push(objCas);
          this.UpdateCaseStatus(tempCaseArr);
        }
       
        this.viewCaseId=''
        this.docDetArr=[];
        this.showSpinner=false;
        
    })
    .catch(error => {
      this.showSpinner = false;
      console.error('Line no RCU DETAILS ##2520', error)
    })
  }
  }

  
  upsertDataCase(obj){
    if(obj){   
    console.log('Case Records Update ##2891', obj); 
    upsertMultipleRecord({ params: obj })
    .then(result => {     
        console.log('Case Detail Records updated ##2895', result);
        this.showToastMessage('Success', 'Case Document Details Created Successfully', 'success', 'sticky');
        this.getCaseData();
        this.docDtHold=false;
        this.addrHold=false;
        this.showSpinner=false;
        
    })
    .catch(error => {
      this.showSpinner = false;
      console.error('Line no RCU DETAILS ##2538', error)
    })
  }
  }

  upsertDataCaseDoc(obj){
    if(obj){   
    console.log('Case Document Detail Records create ##2527', obj); 
    
    upsertMultipleRecord({ params: obj })
    .then(result => {     
        console.log('Case Document Detail Records insert for ApplAddr ##2531', result);
        this.showToastMessage('Success', 'Case Document Details Created Successfully', 'success', 'sticky');
        this.docDetArr=[];
        this.verifCaseRecords=[];
        this.getCaseData();
        this.showSpinner=false;
        location.reload();
    })
    .catch(error => {
      this.showSpinner = false;
      console.error('Line no RCU DETAILS ##2538', error)
    })
  }
  }

  UpdateLANStatus(obj){
    if(obj){   
      console.log('LAN Records update ##2977', obj); 
      
      upsertMultipleRecord({ params: obj })
      .then(result => {     
          console.log('Case Document Detail Records insert for ApplAddr ##2531', result);
          this.showToastMessage('Success', 'Loan Application RCU Status Reset Successfully', 'success', 'sticky');
          this.showSpinner=false;
          
      })
      .catch(error => {
        this.showSpinner = false;
        console.error('Line no RCU DETAILS ##2988', error)
      })
    }
  }

  @track agcrReportStatus='POSITIVE';
  UpdateCaseStatus(obj){
    if(obj){   
      console.log('Case Records update ##3419', obj); 
      
      upsertMultipleRecord({ params: obj })
      .then(result => {     
          console.log('Case Records update ##3423', result);
          this.showToastMessage('Success', 'Case Status Updated Successfully', 'success', 'sticky');
          this.getCaseData();
          this.getLoanParentCases(this._loanAppId);
          this.showSpinner=false;
          
      })
      .catch(error => {
        this.showSpinner = false;
        console.error('Line no RCU DETAILS ##3430', error)
      })
    }
  }

  @track LoanParentCases=[];
  getLoanParentCases(loanId){
    let recordType = 'RCU'
    let parameter = {
      ParentObjectName: "Case",
      ChildObjectRelName: "",
      parentObjFields: ['Id','RecordType.Name','CaseNumber','AgcRCUReportStatus__c','Case__c','AccountId','ContactId',
        'Loan_Application__c','Final_RCU_status_Reason__c'
      ],
      childObjFields: [],
      queryCriteria: ' where Loan_Application__c = \'' + loanId + '\' AND RecordType.DeveloperName = \''+recordType+ '\' AND AccountId = null AND ContactId =null order by ClosedDate DESC'
    };
  
    getSobjectDataNonCacheable({params: parameter}).then((result) => {
      this.showSpinner=false;
        if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
          this.LoanParentCases=result.parentRecords
          console.log('Case Detail this.LoanParentCases 559 :',this.LoanParentCases);
          let agencycStatus =this.getLoanParentRCUStatus();
          let finalStatusRsn =this.getParentRCUStatusRsn();
          console.log('Case Detail agencycStatusd 566 :',agencycStatus);
          let tempLanArr=[];
          let obj={};
          obj.sobjectType='LoanAppl__c';
          obj.Id=this._loanAppId;
          obj.LANRCUStatus__c = agencycStatus ? agencycStatus : this.agcrReportStatus;
          obj.FinalRCUStatusReason__c = finalStatusRsn ? finalStatusRsn : 'Positive Case';
          tempLanArr.push(obj);
          console.log('tempCaseArr:::::::573',tempLanArr);
          if(tempLanArr){
            this.UpdateLANStatus(tempLanArr);
          }
        }
      })
    .catch(error => {
        console.log('Error to Update LAN RCU STatus 580 on Vendor Portal : ',JSON.stringify(error));
    });
  }

  getLoanParentRCUStatus(){
    let agencycStatus=''
    let fraudCount = 0
    let negativeCount=0;
    let referCount=0;
    let pendingCount=0;
    let positiveCount=0;
    console.log(' this.LoanParentCases::::586', this.LoanParentCases);
    this.LoanParentCases.forEach(c=>{
      console.log(' this.c::::585', c.AgcRCUReportStatus__c);
      if(c.AgcRCUReportStatus__c === 'FRAUD'){
        fraudCount++;
      }
      else if(!(c.AgcRCUReportStatus__c === 'FRAUD') && c.AgcRCUReportStatus__c === 'NEGATIVE'){
        negativeCount++;
      }
      else if(!(c.AgcRCUReportStatus__c === 'FRAUD' && c.AgcRCUReportStatus__c === 'NEGATIVE') && c.AgcRCUReportStatus__c === 'REFER'){
        referCount++;
      }
      else if(!(c.AgcRCUReportStatus__c === 'FRAUD' && c.AgcRCUReportStatus__c === 'NEGATIVE' && c.AgcRCUReportStatus__c === 'REFER') && c.AgcRCUReportStatus__c === 'PENDING'){
        pendingCount++;
      }
      else if(!(c.AgcRCUReportStatus__c === 'FRAUD' && c.AgcRCUReportStatus__c === 'NEGATIVE' && c.AgcRCUReportStatus__c === 'REFER' && c.AgcRCUReportStatus__c === 'PENDING') && c.AgcRCUReportStatus__c === 'POSITIVE'){
        positiveCount++
      }
      })
      console.log('fraudCount::646',fraudCount, 'negativeCount::',negativeCount,  'referCount::',referCount,  'pendingCount::',pendingCount, 'positiveCount::',positiveCount);

      if(fraudCount > 0){
        agencycStatus = 'FRAUD';
        return agencycStatus;
      }else if(negativeCount > 0){
        agencycStatus = 'NEGATIVE';
        return agencycStatus;
      }else if(referCount > 0){
        agencycStatus = 'REFER';
        return agencycStatus;
      }else if(pendingCount > 0){
        agencycStatus = 'PENDING';
        return agencycStatus;
      }else if(positiveCount > 0){
        agencycStatus = 'POSITIVE';
        return agencycStatus;
      }
      return agencycStatus;
  }

  getParentRCUStatusRsn(){
    let finalStatusRsn=''
    this.LoanParentCases.forEach(c=>{
      console.log(' this.c::::3594', c.Final_RCU_status_Reason__c);
      if(c.AgcRCUReportStatus__c === 'FRAUD'){
        finalStatusRsn=c.Final_RCU_status_Reason__c;
      }
      else if(!(c.AgcRCUReportStatus__c === 'FRAUD') && c.AgcRCUReportStatus__c === 'NEGATIVE'){
        finalStatusRsn=c.Final_RCU_status_Reason__c;
      }
      else if(!(c.AgcRCUReportStatus__c === 'FRAUD' && c.AgcRCUReportStatus__c === 'NEGATIVE') && c.AgcRCUReportStatus__c === 'REFER'){
        finalStatusRsn=c.Final_RCU_status_Reason__c;
      }
      else if(!(c.AgcRCUReportStatus__c === 'FRAUD' && c.AgcRCUReportStatus__c === 'NEGATIVE' && c.AgcRCUReportStatus__c === 'REFER') && c.AgcRCUReportStatus__c === 'PENDING'){
        finalStatusRsn=c.Final_RCU_status_Reason__c;
      }
      else if(!(c.AgcRCUReportStatus__c === 'FRAUD' && c.AgcRCUReportStatus__c === 'NEGATIVE' && c.AgcRCUReportStatus__c === 'REFER' && c.AgcRCUReportStatus__c === 'PENDING') && c.AgcRCUReportStatus__c === 'POSITIVE'){
        finalStatusRsn=c.Final_RCU_status_Reason__c;
      }
      })
      return finalStatusRsn;
  }
  @track contVersDataList;
  @track hasDocId=true;
   handleCloseModalEvent() {
    this.showReport = false;
        this.viewDoc = false;
        
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