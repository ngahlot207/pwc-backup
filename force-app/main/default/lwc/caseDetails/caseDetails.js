import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue, getFieldDisplayValue } from 'lightning/uiRecordApi';
import getSobjectDatawithRelatedRecords from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData'; 
import { getObjectInfo, getPicklistValues,getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { subscribe, publish, MessageContext } from 'lightning/messageService';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord,updateRecord } from "lightning/uiRecordApi";
import upsertMultipleRecord from "@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord";
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";

import CASE_OBJECT from '@salesforce/schema/Case';
// CPVFI TEMPLATE FIELDS
import FI_AGENCY from '@salesforce/schema/Case.Account.Name';
import APPLICANT from '@salesforce/schema/Case.Applicant__c';
import ADDRESS_TYPE from '@salesforce/schema/Case.Address_Type__c';
import ADDL_APPL_NAME from '@salesforce/schema/Case.Additional_Co_applicant_Guarantor_Name__c';
import ADDRESS_LINE_1 from '@salesforce/schema/Case.Address_Line_1__c';
import ADDRESS_LINE_2 from '@salesforce/schema/Case.Address_Line_2__c';
import PHONE from '@salesforce/schema/Case.PhoneNoOfBorrower__c';
import STATUS from '@salesforce/schema/Case.Status';
import MOBILE from '@salesforce/schema/Case.Mobile_No__c';
import PRODUCT_TYPE from '@salesforce/schema/Case.Product_Type__c';
import FI_INITIATE_DATE from '@salesforce/schema/Case.DateTimeInitiation__c';
import BRANCH from '@salesforce/schema/Case.Branch_Name__c';
import REPORT_DATE from '@salesforce/schema/Case.Date_of_Report__c';
import DETAILS_BORROWER from '@salesforce/schema/Case.Details_of_the_borrowers_have_been_confi__c';
import MARITAL_STATUS from '@salesforce/schema/Case.Martial_Status__c';
import COMPLETE_ADD from '@salesforce/schema/Case.Is_the_address_complete_and_easily_Trace__c';
import BUSINESS_EMP_NAME from '@salesforce/schema/Case.Name_of_the_Business_Employer__c';
import NEGATIVE_AREA from '@salesforce/schema/Case.Negative_Area__c';
import PROPERTY_TYPE from '@salesforce/schema/Case.Property_Type__c';
import NEIGHBOUR_REF_CHK from '@salesforce/schema/Case.Neighbour_Reference_Check__c';
import FED_BRNC_DIST from '@salesforce/schema/Case.Distance_from_Fedfina_Branch__c';
import DEDUPE_NEGATIVE from '@salesforce/schema/Case.Dedupe_for_Negative_Database__c';
import NEGATIVE_DATABASE from '@salesforce/schema/Case.Negative_Database_Result__c';
import ADVERSE_REMARKS from '@salesforce/schema/Case.Adverse_Remarks_of_Dedupe__c';
import OVERRIDE_BY_FEDFINA from '@salesforce/schema/Case.OverrideByFedFina__c';

//import TAT_FI_REPORT from '@salesforce/schema/Case.TAT_of_FI_Report__c';
import NEG_REPORT_REASON from '@salesforce/schema/Case.Negative_Report_reason__c';
import CASE_REMARKS from '@salesforce/schema/Case.Remarks_regarding_the_case__c';
import FINAL_VERF_STATUS from '@salesforce/schema/Case.Final_Status_of_Field_Verification_by_un__c';
import MITIGANT_STATUS from '@salesforce/schema/Case.Mitigant_for_Change_in_Status__c';
// TECHNICAL TEMPLATE FIELDS

import LAND_AREA from '@salesforce/schema/Case.Land_Area_Sq_Ft__c';
import LAND_VALUE from '@salesforce/schema/Case.Land_Valuation_in_Rs__c';
import PROPERTY_AREA from '@salesforce/schema/Case.Property_Built_up_area_Sq_Ft__c';
import PROPRTY_VALUE from '@salesforce/schema/Case.Built_up_area_Valuation_In_Rs__c';
import RESI_AGE from '@salesforce/schema/Case.Residual_Age_in_Years__c';
import RECONST_COST from '@salesforce/schema/Case.Property_Reconstruction_Cost__c';
import TOTAL_VALUE from '@salesforce/schema/Case.Total_Valuation_Land_Valuation_B__c';
import STAGE_COMLE_PERCENT from '@salesforce/schema/Case.Stage_of_Construction__c';
import RECOMMEND_VALUER from '@salesforce/schema/Case.Recommended_by_Technical_Valuer__c';
import PROP_AGE from '@salesforce/schema/Case.Approx_Age_of_Property_in_Years__c';
import PLOT_AGRI_PICK from '@salesforce/schema/Case.Plot_is_non_agricultural__c';
import APPROV_LAYOPT_PICK from '@salesforce/schema/Case.Approved_Plan_OC_available__c';
import PROP_USAGE_PICK from '@salesforce/schema/Case.PropertyUsage__c';
import REPORT_PICK from '@salesforce/schema/Case.ReportResult__c';
import EXPIRY_DATE from '@salesforce/schema/Case.ExpiryDate__c';
import IS_REINIT_EXP from '@salesforce/schema/Case.IsReinitiatedExpired__c';
import PHOTO_COUNT from '@salesforce/schema/Case.PhotoCount__c';
import REPORT_COUNT from '@salesforce/schema/Case.ReportCount__c';

import CASE_DOC_OBJECT from '@salesforce/schema/CaseDoc__c';
import CASE_FIELD from '@salesforce/schema/CaseDoc__c.Case__c';
import DOC_DET_FIELD from '@salesforce/schema/CaseDoc__c.DocDetail__c';

import CaseQueryUpdateSuccess from '@salesforce/label/c.CaseQueryUpdateSuccess';
import CaseDocCreateSuccess from '@salesforce/label/c.CaseDocCreateSuccess';
import CaseQueryUpdateError from '@salesforce/label/c.CaseQueryUpdateError';
import CaseSaveSuccess from '@salesforce/label/c.CaseSaveSuccess';
import CaseQueryRequiredFieldError from '@salesforce/label/c.CaseQueryRequiredFieldError';

import CaseDetailsCpvfiPhotoError from '@salesforce/label/c.CaseDetailsCpvfiPhotoError';
import CaseDetailsPhotoError from '@salesforce/label/c.CaseDetailsPhotoError';
import CaseDetailsReportError from '@salesforce/label/c.CaseDetailsReportError';
import CaseDetailsReportPhotoError from '@salesforce/label/c.CaseDetailsReportPhotoError';
import CaseDetailsRequiredFieldError from '@salesforce/label/c.CaseDetailsRequiredFieldError';
import CaseDetailsTechPhotoError from '@salesforce/label/c.CaseDetailsTechPhotoError';
import Id from "@salesforce/user/Id";

import { refreshApex } from '@salesforce/apex'; 

import { CPARoles } from 'c/globalConstant';

const fields =[FI_AGENCY,APPLICANT,PHONE,MOBILE,FI_INITIATE_DATE,BRANCH,REPORT_DATE,COMPLETE_ADD,BUSINESS_EMP_NAME,NEGATIVE_AREA,PROPERTY_TYPE,
    NEIGHBOUR_REF_CHK,FED_BRNC_DIST,DEDUPE_NEGATIVE,NEGATIVE_DATABASE,ADVERSE_REMARKS,NEG_REPORT_REASON,
CASE_REMARKS,FINAL_VERF_STATUS,MITIGANT_STATUS,PRODUCT_TYPE,DETAILS_BORROWER,ADDRESS_TYPE,ADDRESS_LINE_1,ADDRESS_LINE_2,STATUS,
LAND_AREA,LAND_VALUE,PROPERTY_AREA,RESI_AGE,PROPRTY_VALUE,RECONST_COST,TOTAL_VALUE,PROP_AGE,PLOT_AGRI_PICK,APPROV_LAYOPT_PICK,
PROP_USAGE_PICK,REPORT_PICK,STAGE_COMLE_PERCENT,RECOMMEND_VALUER,OVERRIDE_BY_FEDFINA,ADDL_APPL_NAME, MARITAL_STATUS,EXPIRY_DATE,IS_REINIT_EXP,
PHOTO_COUNT,REPORT_COUNT];

export default class CaseDetails extends LightningElement {

    label = {
        CaseQueryUpdateSuccess,
        CaseDocCreateSuccess,
        CaseQueryUpdateError,
        CaseSaveSuccess,
        CaseQueryRequiredFieldError,
        CaseDetailsCpvfiPhotoError,
        CaseDetailsPhotoError,
        CaseDetailsReportError,
        CaseDetailsReportPhotoError,
        CaseDetailsRequiredFieldError,
        CaseDetailsTechPhotoError
    };
    
   // @api caseId = '500C40000063gvKIAQ';
   @api technical;
   @api cpvfi;
   @api tsr;
   @api vetting;
   @api legal;
   @api hasEditAccess;

   @track currentUserId = Id;
   @track userRole;
   //  recordTypeName = 'CPVFI'; // Pass the Record Type Name from the parent component
    @track cpvRecordTypeId;
    @track tsrRecordTypeId;
    @track vettingRecordTypeId;
    @track accountName;
    @track appName;
    @track appPhone;
    @track address;
    @track filterCriteria = 'Property Papers';
    
    @track caseWrp = {}
    @track caseQryWrp={}
    @track mandtory = false;
    @track caseQryList=[] ;
    @track caseDocList=[];
    @track commentQryList=[];

    borrowerOptions=[];
    addOwnerOptions=[]
    maritalOptions=[];
    neighbourOptions=[];
    negReportOptions=[];
    isAddressAccesOptions= [];
    productTypeOptions= [];
    dedupeOptions = [];
    negativeAreaOptions= [];
    propertyTypeOptions = [];
    negativeDatabaseOptions = [];
    finalStatusOptions = [];
    mitigantStatusOptions=[];

    propAgriOptions=[];
    approveLayoutOptions=[];
    propUsageOptions=[];
    reportResultOptions=[];

    reportStatusOptions=[];
    reportVettingOpt=[];
    tsrVerOptions=[];
    titleOptions=[];
    finalStatusTSROptions=[];
    finalStatusHLMOptions=[];

    
    @wire(MessageContext)
    MessageContext;
    @track activeSection = ["A", "B","C"];
    @track _recordId
    @track status;
    @track lanBrchCode;
    @track hubManagerReview;
    @track expryDate;
    @track isRenitExp;
    @track caseQryId;
    @track wiredData;
    @track wiredCaseData;
    @track dateTimeInitiation;
    @track totalLandValue;
    @track documentDetailId;
    @track reportDate;
    @track statusReport;
  @track photoCount;
  @track reportCount;
  @track showDeleteIcon=false;
  //@track disabled;
  @track uploadDoc = true;

get enableOverride(){
    return this.hasEditAccess=== false || this.status === 'Closed' || this.status === 'Cancelled' || this.caseWrp.OverrideByFedFina__c=== false || this.userRole ==='LHM';
}
get showOverride(){
    return this.userRole !=='LHM';
}
get enableDocUpload(){
    let x = true;
    if(this.userRole === 'LHM'){
        x =true;
    }else if(!this.uploadDoc){
       x=false;
    }
    return x;
}

  
get disableMitigant(){
    return this.hasEditAccess === false || this.status !== 'Closed';
}
get disabled(){
    return this.hasEditAccess === false || this.status === 'Closed' || this.status === 'Cancelled' || this.userRole === 'LHM' ;
}
//LAK-9771 In absence of LHM or THM updated code 
get disbaleHubManager(){
    let val;
    if(this.lhmList && this.lhmList.length>0){
        val= !this.hasEditAccess || this.hubManagerReview === 'Legal Approved' || this.userRole !== 'LHM' || this.status !=='Closed';
    }else if(this.lhmList.length === 0 && this.uwList && this.uwList.length>0){
        val= !this.hasEditAccess || this.hubManagerReview === 'Legal Approved' || this.userRole !== 'UW' || this.status !=='Closed';
     }else if(this.lhmList.length === 0 && this.uwList.length===0 && this.acmList.length>0){
        val= !this.hasEditAccess || this.hubManagerReview === 'Legal Approved' || this.userRole !== 'ACM' || this.status !=='Closed';
    }
    return val;
   // return this.hasEditAccess === false || this.hubManagerReview === 'Legal Approved' || this.userRole !== 'LHM' || this.status !=='Closed';
}
//LAK-9771 In absence of LHM or THM updated code 
get disbaleHubTechManager(){
    let val;
    if(this.thmList && this.thmList.length>0){
        val= this.hubManagerReview === 'Technical Approved' || this.userRole !== 'THM' || this.status !=='Closed';
    }else if(this.thmList.length === 0 && this.uwList && this.uwList.length>0){
        val= !this.hasEditAccess || this.hubManagerReview === 'Technical Approved' || this.userRole !== 'UW' || this.status !=='Closed';
     }else if(this.thmList.length === 0 && this.uwList.length===0 && this.acmList.length>0){
        val= !this.hasEditAccess || this.hubManagerReview === 'Technical Approved' || this.userRole !== 'ACM' || this.status !=='Closed';
    }
    return val;
    // return this.hubManagerReview === 'Technical Approved' || this.userRole !== 'THM' || this.status !=='Closed';
}

get showCpvfi(){
    return this.cpvfi;
}
get showTechincal(){
    return this.technical;
}

get showTSR(){
    return this.tsr;
}

get showVetting(){
    return this.vetting;
}

get showLegal(){
    return this.legal;
}

    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        this.handleCaseDocIdChange();
       
    }


    @api get caseId() {
        return this._recordId;
    }
  
    set caseId(value) {
        this._recordId = value;
        this.setAttribute("recordId", value);
        this.handleCaseDataIdChange(value);
       this.handleRecordIdChange(value);
       this.handleCaseQueryIdChange(value);
       this.handleCaseCommentQueryIdChange(value);
       this.handleteamHierIdChange(value);
    }

    get negativeDedupe(){
        return this.caseWrp.Dedupe_for_Negative_Database__c === 'Yes';
    }
    
    get negDataResult(){
        return this.caseWrp.Negative_Database_Result__c === 'Match Found'
    }

    get addType(){
        return this.caseWrp.Address_Type__c === 'Residence Address' || this.caseWrp.Address_Type__c === 'Permanent Address' || this.caseWrp.Address_Type__c === 'Residence Cum office';
    }

    get disableForCPA(){
        return this.hasEditAccess === false || this.userRole==='CPA' || this.status !== 'Closed'; //LAK-9244
    }

    get negativeResult(){
        return this.caseWrp.ReportResult__c === 'Negative';
    }
   
   get showFinalStatus(){
    return this.statusReport === 'Final';
   }

   get showQryDesc(){
    return this.statusReport === 'Query';
   }
    updatedColumns = [
        {   label: 'Case Number', fieldName: 'CaseNumber__c', type: 'text',},   
        {   label: 'Query', fieldName: 'Query__c', type: 'text',  },
        {   label: 'Response', fieldName: 'Response__c', type: 'text', editable : true},
        {   label: 'Status', fieldName: 'Status__c', type: 'text', editable : true},       
        ];

        caseDocColumns = [
            {   label: 'Document Type', fieldName: 'DocTyp__c', type: 'text',},   
            {   label: 'Document Name', fieldName: 'DocSubTyp__c', type: 'text', },
            {   label: 'File Type', fieldName: 'File_Type__c', type: 'text',},
            {   label: 'Date & Time',fieldName: 'CreatedDate',
                type: 'date', 
                typeAttributes: {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: true
              },
                
            },
            
           
            ];


            commentsColumns = [
                {   label: 'Comment Number', fieldName: 'Name', type: 'text', },
                {   label: 'Reviewer Comments', fieldName: 'ReviewerComments__c',type: 'text',},
                {   label: 'Case', fieldName: 'CaseNumber__c', type: 'text',},
                {   label: 'User', fieldName: 'UserName__c', type: 'text',},
                {   label: 'Created Date', fieldName: 'CreatedDate', type: 'date',
                    typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true
                  },
          
                },
          
                ];
    
    renderedCallback(){
        refreshApex(this.wiredData);
    }
    connectedCallback(){
        // if (this.hasEditAccess === false) {
        //     this.disabled = true;
        //   }
        this.activeSection = ["A","B"];
        this.sunscribeToMessageChannel();
    }
    handleteamHierIdChange() {
        let tempParams = this.teamHierParam;
        tempParams.queryCriteria = ' where Employee__c = \'' + this.currentUserId + '\' limit 1' ;
        this.teamHierParam = { ...tempParams };

    }

    handleRecordIdChange() {
        let tempParams = this.caseDetails;
        tempParams.queryCriteria = ' where Id = \'' + this._recordId + '\' limit 1' ;
        this.caseDetails = { ...tempParams };
        this.getCaseData();
    }

    handleCaseQueryIdChange() {
        let tempParams = this.caseQueryParams;
        tempParams.queryCriteria = ' where Case__c = \'' + this._recordId + '\' order by CreatedDate desc' ;
        this.caseQueryParams = { ...tempParams };

    }

    handleCaseDocIdChange() {
        let tempParams = this.docDetParams;
        tempParams.queryCriteria = ' where LAN__c = \'' + this._loanAppId + '\' AND DocTyp__c =\''+this.filterCriteria+ '\'' ;
       // tempParams.queryCriteria = ' where LAN__c = \'' + this._loanAppId + '\'' ;
        this.docDetParams = { ...tempParams };

    }

    handleCaseCommentQueryIdChange(){
        let tempParams = this.commentsQueryParams;
        tempParams.queryCriteria = ' where Case__c = \'' + this._recordId + '\' order by CreatedDate desc' ;
        this.commentsQueryParams = { ...tempParams };

    }

    handleCaseDataIdChange(){
        let tempParams = this.caseData;
        tempParams.queryCriteria = ' where Id = \'' + this._recordId + '\' limit 1' ;
        this.caseData = { ...tempParams };


    }
    @track teamHierParam = {
        ParentObjectName: 'TeamHierarchy__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id','EmpRole__c','Employee__c'],
        childObjFields: [],
        queryCriteria: ''
        }

    @track caseDetails = {
        ParentObjectName: 'Case',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Account.Name', 'Applicant__r.TabName__c','Applicant__r.PhoneNumber__c',
            'Loan_Application__r.Name', 'caseNumber','CreatedDate','Property_Owner_s_as_per_Technical_Repo__c',
            'Applicant__r.FullName__c','Loan_Application__r.BrchCode__c'],
        childObjFields: [],
        queryCriteria: ''
        }

        @track
    caseQueryParams = {
        ParentObjectName: 'Case_Query__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Case__c','CaseNumber__c', 'Query__c','Raised_By__c','Response__c','Status__c','Case__r.Status' ],
        childObjFields: [],
        queryCriteria: ' '
    }

    @track
    docDetParams = {
        ParentObjectName: 'DocDtl__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'LAN__c','DocTyp__c','File_Type__c','CreatedDate','DocSubTyp__c','ApplAsset__r.Id' ],
        childObjFields: [],
        queryCriteria: ' '
    }

    @track
  commentsQueryParams = {
    ParentObjectName: "Comments__c",
    ChildObjectRelName: "",
    parentObjFields: [
      "Id",
      "CaseNumber__c",
      "Name",
      "ReviewerComments__c",
      "User__c",
      "Case__c",
      "UserName__c"
    ],
    childObjFields: [],
    queryCriteria: " "
  };

        sunscribeToMessageChannel() {
            this.subscription = subscribe(
                this.MessageContext,
                SaveProcessCalled,
                (values) => this.handleSaveThroughLms(values)
            );
    
        }
      
        get requiredFlag(){
            return this.mandtory;
        }

        @track
        caseData = {
          ParentObjectName: "Case",
          ChildObjectRelName: "",
          parentObjFields: ["Id", "Address_Type__c",'AddressOwnership__c', "Additional_Co_applicant_Guarantor_Name__c",
          'Mobile_No__c','Product_Type__c','Branch_Name__c','Status','ExpiryDate__c','IsReinitiatedExpired__c',
          'DateTimeInitiation__c','Dedupe_for_Negative_Database__c','Date_of_Report__c','Negative_Database_Result__c',
          'Details_of_the_borrowers_have_been_confi__c','Martial_Status__c','Is_the_address_complete_and_easily_Trace__c',
          'Name_of_the_Business_Employer__c','Distance_from_Fedfina_Branch__c','Negative_Area__c','Property_Type__c',
          'Adverse_Remarks_of_Dedupe__c','Negative_Report_reason__c','Remarks_regarding_the_case__c',
          'Final_Status_of_Field_Verification_by_un__c','Mitigant_for_Change_in_Status__c','Address_Line_1__c',
          'Address_Line_2__c','OverrideByFedFina__c','Land_Area_Sq_Ft__c','Land_Valuation_in_Rs__c',
          'Property_Built_up_area_Sq_Ft__c','Residual_Age_in_Years__c','Built_up_area_Valuation_In_Rs__c',
          'Property_Reconstruction_Cost__c','Total_Valuation_Land_Valuation_B__c','Approx_Age_of_Property_in_Years__c',
          'Stage_of_Construction__c','Recommended_by_Technical_Valuer__c','Approved_Plan_OC_available__c',
          'Plot_is_non_agricultural__c','Neighbour_Reference_Check__c','PropertyUsage__c','ReportResult__c',
          'PhotoCount__c','ReportCount__c','TSRVerification__c','IsTheTitleClearNdMarketable__c',
          'TSR_EC_for_no_of_Yrs__c','Query_description__c','DetailsSearchReport__c','Final_Remarks__c','FinalStatusTSRReportFromHLM__c',
          'FinalStatusOfTSR__c','QueryRevert__c','HubManagerReview__c','Property_owner_Names__c'],
          childObjFields: [],
          queryCriteria: "  "
        };

getCaseData(){
     getSobjectDataNonCacheable({params: this.caseData}).then((result) => {
        console.log("CASE Details RESULT #397:::", result);
        if(result.parentRecords[0] !== undefined){
            this.caseWrp.Address_Type__c = result.parentRecords[0].Address_Type__c ? result.parentRecords[0].Address_Type__c : '';
            // this.caseWrp.PhoneNoOfBorrower__c = result.parentRecords[0].PhoneNoOfBorrower__c ? result.parentRecords[0].PhoneNoOfBorrower__c : '';
            this.caseWrp.Additional_Co_applicant_Guarantor_Name__c = result.parentRecords[0].Additional_Co_applicant_Guarantor_Name__c ? result.parentRecords[0].Additional_Co_applicant_Guarantor_Name__c : '';
             this.caseWrp.Mobile_No__c = result.parentRecords[0].Mobile_No__c ? result.parentRecords[0].Mobile_No__c : '';
             this.caseWrp.Product_Type__c = result.parentRecords[0].Product_Type__c ? result.parentRecords[0].Product_Type__c : '';
             this.caseWrp.Branch_Name__c = result.parentRecords[0].Branch_Name__c ? result.parentRecords[0].Branch_Name__c : '';
             this.status = result.parentRecords[0].Status ? result.parentRecords[0].Status : '';
             this.expryDate = result.parentRecords[0].ExpiryDate__c ? result.parentRecords[0].ExpiryDate__c : '';
             this.isRenitExp = result.parentRecords[0].IsReinitiatedExpired__c ? result.parentRecords[0].IsReinitiatedExpired__c : '';
 
             this.dateTimeInitiation= result.parentRecords[0].DateTimeInitiation__c;
             this.caseWrp.Dedupe_for_Negative_Database__c = result.parentRecords[0].Dedupe_for_Negative_Database__c ? result.parentRecords[0].Dedupe_for_Negative_Database__c : '';
             this.caseWrp.AddressOwnership__c = result.parentRecords[0].AddressOwnership__c ? result.parentRecords[0].AddressOwnership__c : '';
           //  this.caseWrp.Date_of_Report__c = result.parentRecords[0].Date_of_Report__c ? result.parentRecords[0].Date_of_Report__c : '';
           this.reportDate = result.parentRecords[0].Date_of_Report__c
             this.caseWrp.Negative_Database_Result__c = result.parentRecords[0].Negative_Database_Result__c ? result.parentRecords[0].Negative_Database_Result__c : '';
             this.caseWrp.Details_of_the_borrowers_have_been_confi__c = result.parentRecords[0].Details_of_the_borrowers_have_been_confi__c ? result.parentRecords[0].Details_of_the_borrowers_have_been_confi__c : '';
             this.caseWrp.Martial_Status__c = result.parentRecords[0].Martial_Status__c ? result.parentRecords[0].Martial_Status__c : '';
             
             this.caseWrp.Is_the_address_complete_and_easily_Trace__c = result.parentRecords[0].Is_the_address_complete_and_easily_Trace__c ? result.parentRecords[0].Is_the_address_complete_and_easily_Trace__c : '';
             this.caseWrp.Name_of_the_Business_Employer__c = result.parentRecords[0].Name_of_the_Business_Employer__c ? result.parentRecords[0].Name_of_the_Business_Employer__c : '';
             this.caseWrp.Negative_Area__c = result.parentRecords[0].Negative_Area__c ? result.parentRecords[0].Negative_Area__c : '';
             this.caseWrp.Property_Type__c = result.parentRecords[0].Property_Type__c ? result.parentRecords[0].Property_Type__c : '';
             this.caseWrp.Neighbour_Reference_Check__c = result.parentRecords[0].Neighbour_Reference_Check__c ? result.parentRecords[0].Neighbour_Reference_Check__c : '';
             this.caseWrp.Distance_from_Fedfina_Branch__c = result.parentRecords[0].Distance_from_Fedfina_Branch__c ? result.parentRecords[0].Distance_from_Fedfina_Branch__c : '';;
             this.caseWrp.Adverse_Remarks_of_Dedupe__c = result.parentRecords[0].Adverse_Remarks_of_Dedupe__c ? result.parentRecords[0].Adverse_Remarks_of_Dedupe__c : '';
            // this.caseWrp.TAT_of_FI_Report__c = result.parentRecords[0].TAT_of_FI_Report__c ? result.parentRecords[0].TAT_of_FI_Report__c :false ;
             this.caseWrp.Negative_Report_reason__c = result.parentRecords[0].Negative_Report_reason__c ? result.parentRecords[0].Negative_Report_reason__c :'' ;
             this.caseWrp.Remarks_regarding_the_case__c = result.parentRecords[0].Remarks_regarding_the_case__c ? result.parentRecords[0].Remarks_regarding_the_case__c : '';
             this.caseWrp.Final_Status_of_Field_Verification_by_un__c = result.parentRecords[0].Final_Status_of_Field_Verification_by_un__c ? result.parentRecords[0].Final_Status_of_Field_Verification_by_un__c :'' ;
             this.caseWrp.Mitigant_for_Change_in_Status__c = result.parentRecords[0].Mitigant_for_Change_in_Status__c ? result.parentRecords[0].Mitigant_for_Change_in_Status__c :'' ;
            
            this.address = result.parentRecords[0].Address_Line_1__c + ',' + result.parentRecords[0].Address_Line_2__c;
 
            this.caseWrp.OverrideByFedFina__c = result.parentRecords[0].OverrideByFedFina__c ? result.parentRecords[0].OverrideByFedFina__c :false ;
            // TECHNICAL FIELDS DISPALY
 
            this.caseWrp.Land_Area_Sq_Ft__c = result.parentRecords[0].Land_Area_Sq_Ft__c ? result.parentRecords[0].Land_Area_Sq_Ft__c : '';
            this.caseWrp.Land_Valuation_in_Rs__c = result.parentRecords[0].Land_Valuation_in_Rs__c;
            this.caseWrp.Property_Built_up_area_Sq_Ft__c = result.parentRecords[0].Property_Built_up_area_Sq_Ft__c ? result.parentRecords[0].Property_Built_up_area_Sq_Ft__c :'' ;
            this.caseWrp.Residual_Age_in_Years__c = result.parentRecords[0].Residual_Age_in_Years__c ? result.parentRecords[0].Residual_Age_in_Years__c :'' ;
            this.caseWrp.Built_up_area_Valuation_In_Rs__c = result.parentRecords[0].Built_up_area_Valuation_In_Rs__c;
            this.caseWrp.Property_Reconstruction_Cost__c = result.parentRecords[0].Property_Reconstruction_Cost__c;
            this.totalLandValue = result.parentRecords[0].Total_Valuation_Land_Valuation_B__c;
            this.caseWrp.Approx_Age_of_Property_in_Years__c = result.parentRecords[0].Approx_Age_of_Property_in_Years__c ? result.parentRecords[0].Approx_Age_of_Property_in_Years__c :'' ;
            this.caseWrp.Stage_of_Construction__c = result.parentRecords[0].Stage_of_Construction__c;
            this.caseWrp.Recommended_by_Technical_Valuer__c = result.parentRecords[0].Recommended_by_Technical_Valuer__c;
           
            this.caseWrp.Approved_Plan_OC_available__c = result.parentRecords[0].Approved_Plan_OC_available__c ? result.parentRecords[0].Approved_Plan_OC_available__c :'' ;
            this.caseWrp.Plot_is_non_agricultural__c = result.parentRecords[0].Plot_is_non_agricultural__c ? result.parentRecords[0].Plot_is_non_agricultural__c : '';
            this.caseWrp.PropertyUsage__c = result.parentRecords[0].PropertyUsage__c ? result.parentRecords[0].PropertyUsage__c :'' ;
            this.caseWrp.ReportResult__c = result.parentRecords[0].ReportResult__c ? result.parentRecords[0].ReportResult__c :'' ;
 
            // TSR FIELDS
            this.hubManagerReview=result.parentRecords[0].HubManagerReview__c;
            this.statusReport=result.parentRecords[0].ReportResult__c;
            this.caseWrp.TSRVerification__c = result.parentRecords[0].TSRVerification__c ? result.parentRecords[0].TSRVerification__c : '';
            this.caseWrp.IsTheTitleClearNdMarketable__c = result.parentRecords[0].IsTheTitleClearNdMarketable__c ? result.parentRecords[0].IsTheTitleClearNdMarketable__c :'' ;
            this.caseWrp.Final_Remarks__c = result.parentRecords[0].Final_Remarks__c ? result.parentRecords[0].Final_Remarks__c :'' ;
            this.caseWrp.Query_description__c = result.parentRecords[0].Query_description__c ? result.parentRecords[0].Query_description__c :'' ;
            this.caseWrp.DetailsSearchReport__c= result.parentRecords[0].DetailsSearchReport__c ? result.parentRecords[0].DetailsSearchReport__c :'' ;
            this.caseWrp.QueryRevert__c = result.parentRecords[0].QueryRevert__c ? result.parentRecords[0].QueryRevert__c :'' ;
            this.caseWrp.FinalStatusTSRReportFromHLM__c = result.parentRecords[0].FinalStatusTSRReportFromHLM__c ? result.parentRecords[0].FinalStatusTSRReportFromHLM__c :'' ;
            this.caseWrp.FinalStatusOfTSR__c= result.parentRecords[0].FinalStatusOfTSR__c ? result.parentRecords[0].FinalStatusOfTSR__c :'' ;
            this.propOwners = result.parentRecords[0].Property_owner_Names__c;
            //   this.reportCount = result.parentRecords[0].ReportCount__c;
        //   this.photoCount = result.parentRecords[0].PhotoCount__c

          if(this.caseWrp.OverrideByFedFina__c){
                        this.uploadDoc=false;
                       }else{
                        this.uploadDoc=true;
                       }
        }          
         })
         .catch((error) => {
           console.log("CASE DOCUMENT COUNT ERROR #463", error);
         });

}
    

@track creditRoles=['CPA','UW','ACM','RCM','ZCM','NCM','CH'];
    @wire(getSobjectData,{params : '$teamHierParam'})
    teamHierHandler({data,error}){
        if(data){
            console.log('DATA IN CASE DETAILS :::: #412>>>>',data);
            if(data.parentRecords !== undefined ){
                this.userRole = data.parentRecords[0].EmpRole__c
                console.log('DATA IN CASE DETAILS :::: #415>>>>',this.userRole);
                if(this.creditRoles && this.creditRoles.length>0){
                    this.creditRoles.forEach(i=>{
                      if(i===this.userRole){
                        this.showDeleteIcon=true;
                      }
                    })
                  }
            }
                      
        }
        if(error){
            console.error('ERROR CASE DETAILS:::::::#420',error)
        }
    }
@track loanNumber;
@track propOwners;
    @wire(getSobjectData,{params : '$caseDetails'})
    caseRecordHandler({data,error}){
        if(data){
            console.log('DATA IN CASE DETAILS :::: #243>>>>',data);
            if(data.parentRecords !== undefined ){
                this.accountName = data.parentRecords[0].Account !== undefined ?  data.parentRecords[0].Account.Name : '' ;
                if(data.parentRecords[0].Applicant__c && data.parentRecords[0].Applicant__r !== undefined){
                    this.appName = data.parentRecords[0].Applicant__r.FullName__c !== undefined ? data.parentRecords[0].Applicant__r.FullName__c:'';
                    this.appPhone = data.parentRecords[0].Applicant__r.PhoneNumber__c;
                }
              
               this.loanNumber=data.parentRecords[0].Loan_Application__r.Name;
               this.lanBrchCode=data.parentRecords[0].Loan_Application__r.BrchCode__c;
               //LAK-9771 In absence of LHM or THM updated code 
               if(this.lanBrchCode){
                this.fetchTeamDetails();
               }
            }
                      
        }
        if(error){
            console.error('ERROR CASE DETAILS:::::::#262',error)
        }
    }

    // @track caseStatus;
  
    @wire(getSobjectData,{params : '$caseQueryParams'})
    caseQueryRecordHandler(result){
       console.log('DATA IN CASE Query DETAILS #421 ::::>>>>',result);
        this.wiredData = result;
        this.caseQryList=[];
        if(result.data){
            let arr=[];
           
            if(result.data.parentRecords !== undefined ){
                arr= result.data.parentRecords;
                arr.forEach(item=>{
                    console.log('DATA IN CASE Query ITEM #428 ::::>>>>',JSON.stringify(item));
                    let obj={};
                   // this.caseQryId = result.data.parentRecords.Id
                   obj.sobjectType = 'Case_Query__c';
                   obj.Case__c=item.Case__c;
                   obj.Id= item.Id;
                   obj.CaseNumber__c= item.CaseNumber__c;
                   obj.Query__c= item.Query__c;
                   obj.Response__c=item.Response__c;
                   obj.Status__c=item.Status__c;
                   obj.caseStatus = item.Case__r.Status;
                    if(obj.caseStatus !== undefined && obj.caseStatus === 'Closed'){
                        obj.disableCaseQry=true;
                        console.log('DATA IN CASE Query DETAILS #431 ::::>>>>',obj.disableCaseQry);
                    }else{
                        obj.disableCaseQry=false;
                    }
                   
                    this.caseQryList.push(obj);  
                })
                              
                // this.caseStatus= result.data.parentRecords[0].Case__r.Status;
               
                console.log('DATA IN CASE Query DETAILS #447 ::::>>>>',this.caseQryList);
             
            }
          
            
        }
        if(result.error){
            console.error('ERROR IN CASE DETAILS::::::# 282',result.error)
        }
    }

@wire(getSobjectData,{params : '$docDetParams'})
documentDetailHandler({data,error}){
    if(data){
        //console.log('DATA IN DCOUMENT DETAILS IN CASE DETAILS #280::::>>>>',data);
         this.caseDocList = data.parentRecords;
        // console.log('DATA IN DCOUMENT this.docList ::::>>>>',this.docList);
        
    }
    if(error){
        console.error('ERROR CASE DETAILS:::::::#295',error);
    }
}

    generatePicklist(data) {
        return data.values.map(item => ({ label: item.label, value: item.value }))
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    getObjectInfo({ error, data }) {
        if (data) {
            //console.log('DATA in RECORD TYPE ID', data);
            for (let key in data.recordTypeInfos) {
                let recordType = data.recordTypeInfos[key];
                console.log("recordType.value>>>>>", recordType.name);
                if (recordType.name === 'CPVFI') {
                    this.cpvRecordTypeId = key;
                } else if(recordType.name === 'TSR'){
                    this.tsrRecordTypeId=key;
                } else if(recordType.name === 'Vetting'){
                    this.vettingRecordTypeId=key;
                }
                console.log('data.cpvRecordTypeId', key);
            }
           
        } else if (error) {
            console.error('ERROR CASE DETAILS:::::::#318', error);
        }
    }

    @wire(getSobjectData, { params: "$commentsQueryParams" })
    commentsQueryRecordHandler({ data, error }) {
      this.wiredDataCaseQry=data;
      if (data) {
        //console.log('DATA IN CASE Query DETAILS #261 ::::>>>>',data);
        if (data.parentRecords !== undefined) {
          this.commentQryList = data.parentRecords;
  
          console.log(
            "DATA IN COMMMENTS Query DETAILS #710 ::::>>>>",
            this.commentQryList
          );
        }
      }
      if (error) {
        console.error("ERROR IN CASE COMMENTS HANDLER::::::#716", error);
      }
    }
    
   
   @api handleValueSelect(event){
        let childEvt = event.detail;
        console.log('childEvt::::#476',childEvt );
        this.refreshDocTable();
        this.getCaseDocCount();

    }   
   @api refreshDocTable() {
    this.showSpinner = false;
    let child = this.template.querySelector('c-show-case-document');
    child.handleFilesUploaded();

}

    @wire(getPicklistValuesByRecordType, {
        objectApiName: CASE_OBJECT,
        recordTypeId: '$cpvRecordTypeId',
    })
    picklistHandler({ data, error }) {
        if (data) {         
            this.borrowerOptions = [...this.generatePicklist(data.picklistFieldValues.Details_of_the_borrowers_have_been_confi__c)]
            this.maritalOptions=[...this.generatePicklist(data.picklistFieldValues.Martial_Status__c)]
            this.addOwnerOptions=[...this.generatePicklist(data.picklistFieldValues.AddressOwnership__c)]
            this.neighbourOptions = [...this.generatePicklist(data.picklistFieldValues.Neighbour_Reference_Check__c)]
            this.negReportOptions = [...this.generatePicklist(data.picklistFieldValues.Negative_Report_reason__c)]           
            this.isAddressAccesOptions = [...this.generatePicklist(data.picklistFieldValues.Is_the_address_complete_and_easily_Trace__c)]
            this.productTypeOptions = [...this.generatePicklist(data.picklistFieldValues.Product_Type__c)]
            this.dedupeOptions = [...this.generatePicklist(data.picklistFieldValues.Dedupe_for_Negative_Database__c)]
            this.negativeAreaOptions = [...this.generatePicklist(data.picklistFieldValues.Negative_Area__c)]
            this.propertyTypeOptions = [...this.generatePicklist(data.picklistFieldValues.Property_Type__c)]
            this.negativeDatabaseOptions = [...this.generatePicklist(data.picklistFieldValues.Negative_Database_Result__c)]
            this.finalStatusOptions = [...this.generatePicklist(data.picklistFieldValues.Final_Status_of_Field_Verification_by_un__c)]
            //this.mitigantStatusOptions = [...this.generatePicklist(data.picklistFieldValues.Mitigant_for_Change_in_Status__c)]
            this.propAgriOptions=[...this.generatePicklist(data.picklistFieldValues.Plot_is_non_agricultural__c)]
            this.approveLayoutOptions=[...this.generatePicklist(data.picklistFieldValues.Approved_Plan_OC_available__c)]
            this.propUsageOptions=[...this.generatePicklist(data.picklistFieldValues.PropertyUsage__c)]
            this.reportResultOptions=[...this.generatePicklist(data.picklistFieldValues.ReportResult__c)]
        }

        if (error) {
            console.error('ERROR CASE DETAILS:::::::#344',error)
        }

    }

    @wire(getPicklistValuesByRecordType, {
        objectApiName: CASE_OBJECT,
        recordTypeId: '$tsrRecordTypeId',
    })
    tsrPicklistHandler({ data, error }) {
        if (data) {         
            this.reportStatusOptions=[...this.generatePicklist(data.picklistFieldValues.ReportResult__c)]
        
            this.titleOptions=[...this.generatePicklist(data.picklistFieldValues.IsTheTitleClearNdMarketable__c)]
            this.finalStatusHLMOptions=[...this.generatePicklist(data.picklistFieldValues.FinalStatusTSRReportFromHLM__c)]
            this.finalStatusTSROptions=[...this.generatePicklist(data.picklistFieldValues.FinalStatusOfTSR__c)]
        }

        if (error) {
            console.error('ERROR CASE DETAILS:::::::#744',error)
        }
    }

    @wire(getPicklistValuesByRecordType, {
        objectApiName: CASE_OBJECT,
        recordTypeId: '$vettingRecordTypeId',
    })
    vettingPicklistHandler({ data, error }) {
        if (data) {         
            this.reportVettingOpt=[...this.generatePicklist(data.picklistFieldValues.ReportResult__c)]
            this.tsrVerOptions=[...this.generatePicklist(data.picklistFieldValues.TSRVerification__c)]
        
        }

        if (error) {
            console.error('ERROR CASE DETAILS:::::::#744',error)
        }
    }
    @wire(getObjectInfo, { objectApiName: 'Case_Query__c' })
    objInfo1;
    @wire(getPicklistValuesByRecordType, {
      objectApiName: 'Case_Query__c',
      recordTypeId: '$objInfo1.data.defaultRecordTypeId',
  })
  dedupePicklistHandler({ data, error }) {
      if (data) {
         // console.log('data in PicklistHandler', JSON.stringify(data));
          this.caseQrystatusOptions = [...this.generatePicklist(data.picklistFieldValues.Status__c)]
         // console.log('data in  this.caseQrystatusOptions',  this.caseQrystatusOptions);
      }
      if (error) {
          console.error('ERROR CASE DETAILS:::::::#361', error)
      }
  }
  

handleInputChange(event){
   

     if (event.target.type === "checkbox") {
       
        if (event.target.checked) {
          this.caseWrp[event.target.dataset.name] = true;
          this.uploadDoc=false;
        } else {
          this.caseWrp[event.target.dataset.name] = false;
          this.uploadDoc=true;
        }
      } 
      else if(event.target.type === 'text'){
        this.caseWrp[event.target.dataset.name] = event.target.value.toUpperCase();
      }
      else if(event.target.type === 'textarea'){
        this.caseWrp[event.target.dataset.name] = event.target.value.toUpperCase();
      }
else{
    this.caseWrp[event.target.dataset.name] = event.target.value;
    if(event.target.dataset.name === 'Final_Status_of_Field_Verification_by_un__c'){
        this.caseWrp[event.target.dataset.name] = event.target.value;
        if(event.target.value){
        this.mandtory = true;
        } 
        else{
         this.mandtory = false
        }
     }
     if(event.target.dataset.name ==='ReportResult__c'){
        this.statusReport = event.target.value;
     }

}
    
  
}


handleValueChange(event) {
    try {
      let currentIndex = event.target.dataset.index;
      let obj = { ...this.caseQryList[event.target.dataset.index] };

      obj[event.target.dataset.fieldName] = event.target.value;
    //  console.log("caseQryList ///1326", JSON.stringify(this.caseQryList));
      this.caseQryList = [...this.caseQryList];
      this.caseQryList[currentIndex] = obj;

    } catch (e) {
      console.error("'ERROR CASE DETAILS:::::::#398", e);
    }
  }

  handlePicklistValues(event) {
    let currentIndex = event.detail.index;
    let fieldName = event.detail.fieldName;
  //  console.log("currentIndex is #780 ", currentIndex, event.detail);
    let obj = { ...this.caseQryList[currentIndex] };

    obj[fieldName] = event.detail.val;
    this.caseQryList = [...this.caseQryList];
    this.caseQryList[currentIndex] = obj;

  }

handleSaveCaseQuery(){
  //  console.log("case query save called  #811",this.caseQryList);
  if(this.caseQryList && this.caseQryList.length>0){
        this.caseQryList.forEach(item=>{
          delete  item.disableCaseQry;
        })

        console.log('THIS CASEQRYLIST::::::655',JSON.stringify(this.caseQryList));
        upsertMultipleRecord({ params: this.caseQryList })
        .then((result) => {
          //console.log("result occured in upsert #816", result);
          this.ShowToastMessage('Success',this.label.CaseQueryUpdateSuccess,'success','dismissable')
            refreshApex(this.wiredCaseData);
            refreshApex(this.wiredDataCaseQry);
    
        })
        .catch((error) => {
      
          console.log('ERROR CASE DETAILS:::::::#432', error);
          //console.log("upsertDataMethod");
        });
        
  } 
 

  }

handleSaveThroughLms(values) {
   
    this.handleSave(values.validateBeforeSave);
 

}

@track selectedRec;
@track docArr = [];
handleRowSelected(event) {
    const selectedRows = event.detail.selectedRows;
    // Display that fieldName of the selected rows
    for (let i = 0; i < selectedRows.length; i++){
       
        this.selectedRec = selectedRows[i].Id;
        this.docArr = [...this.docArr,selectedRows[i].Id];
        this.docArr = [... this.docArr.filter((item, 
            index) => this.docArr.indexOf(item) === index)
        ]


    }
}


handleAttch(){
this.createCaseDocument();

}

createCaseDocument() {
    //console.log('this.caseId ROW ID IS #412::::::',this._recordId);
    let caseDocDtl=[];
    this.docArr.forEach(item=>{
        const fields = {};
        fields[CASE_FIELD.fieldApiName] = this._recordId;
        fields[DOC_DET_FIELD.fieldApiName] = item;
        fields.sobjectType='CaseDoc__c'
        caseDocDtl.push(fields);
        // const recordInput = { apiName: CASE_DOC_OBJECT.objectApiName, fields };
        // createRecord(recordInput)
        //     .then(result => {
        //        // console.log('CASE DOCUMENT RESULT:::::421',result);
        //         this.ShowToastMessage('Success',this.label.CaseDocCreateSuccess,'success','sticky')
                   
        //     })
        //     .catch(error => {
        //         console.log('CASE DOCUMENT RESULT ERRO:::::510',error);
        
        //     });
    })
   
    console.log('caseDocDtl:::::1638',caseDocDtl);
    if(caseDocDtl && caseDocDtl.length>0){
      this.upsertDataCaseDoc(caseDocDtl);
    }
    }

upsertDataCaseDoc(obj){
        if(obj){   
        console.log('Case Document Detail Records create ##951', obj); 
        
        upsertMultipleRecord({ params: obj })
        .then(result => {     
            console.log('Case Document Detail Records insert for Doc Dtl Case Details ##955', result);
            this.ShowToastMessage('Success',this.label.CaseDocCreateSuccess,'success','sticky')
            this.showSpinner=false;
            
        })
        .catch(error => {
          this.showSpinner = false;
          console.error('Line no CASE DETAILS ##962', error)
        })
      }
}

//   draftValues = [];

//   async handleSaveDataTable(event) {
//     // Convert datatable draft values into record objects
//     const records = event.detail.draftValues.slice().map((draftValue) => {
//       const fields = Object.assign({}, draftValue);
//       return { fields };
//     });

//     // Clear all datatable draft values
//     this.draftValues = [];

//     try {
//       // Update all records in parallel thanks to the UI API
//       const recordUpdatePromises = records.map((record) => updateRecord(record));
//       await Promise.all(recordUpdatePromises);

//       // Report success with a toast
//     //  this.ShowToastMessage('Success',this.label.CaseQueryUpdateSuccess,'success','dismissable')
     
//       //refreshApex(this.wiredData);

//       // Display fresh data in the datatable
//       refreshApex(this.wiredData);
//     } catch (error) {
//         this.ShowToastMessage('Error',this.label.CaseQueryUpdateError,'error','sticky')
     
//     }
// }
@track showSpinner=false;
@track isInputCorrect=false;
handleSave(validate) {
    if (validate) {
      let parameter = {
        ParentObjectName: 'Case',
        ChildObjectRelName: null,
        parentObjFields: ['Id','ReportCount__c','PhotoCount__c','Status'],
        childObjFields: [],
        queryCriteria: ' where id = \'' + this._recordId + '\' limit 1'
        }
        getSobjectDataNonCacheable({params: parameter})
        .then((result) => {
            console.log("Error photo and report count 992", JSON.stringify(result));
            // if(result.parentRecords !== undefined){

              this.photoCount = result.parentRecords[0] && result.parentRecords[0].PhotoCount__c ? result.parentRecords[0].PhotoCount__c : 0;
              this.reportCount = result.parentRecords[0] && result.parentRecords[0].ReportCount__c ? result.parentRecords[0].ReportCount__c: 0;
        
           // }

            this.isInputCorrect = this.validateForm();
            if (this.isInputCorrect === true) {
                if(this.tsr === true || this.vetting === true || this.legal === true){
                    if(this.userRole ==='LHM'){
                        this.caseWrp.Status = 'Closed';
                        this.caseWrp.HubManagerReview__c= 'Legal Approved';
                        this.updateRec();
                        this.handleSaveCaseQuery();
                    }else{
                        if(!(this.status === 'Cancelled' || this.status === 'Closed') && this.reportCount > 0 && this.caseWrp.OverrideByFedFina__c === true){
                            this.caseWrp.Status = 'Closed';
                            this.caseWrp.HubManagerReview__c= 'Legal Review';
                            this.updateRec();
                            //LAK-9771 In absence of LHM or THM updated code 
                        }else if(this.status === 'Closed' && this.caseWrp.OverrideByFedFina__c === true && this.lhmList.length === 0){
                            this.caseWrp.Status = 'Closed';
                            this.caseWrp.HubManagerReview__c= 'Legal Approved';
                            this.updateRec();
                         }
                        this.handleSaveCaseQuery();
                    }
                 
                }
                else if(this.technical){
                    if(this.userRole ==='THM'){
                        this.caseWrp.Status = 'Closed';
                        this.caseWrp.HubManagerReview__c= 'Technical Approved';
                        this.updateRec();
                       // this.handleSaveCaseQuery();
                    }else{
                        if(!(this.status === 'Cancelled' || this.status === 'Closed') && this.caseWrp.OverrideByFedFina__c === true){
                            this.caseWrp.Status = 'Closed';
                            this.caseWrp.HubManagerReview__c= 'Technical Review';
                            this.updateRec();
                           //LAK-9771 In absence of LHM or THM updated code  
                        }else if(this.status === 'Closed' && this.caseWrp.OverrideByFedFina__c === true && this.thmList.length === 0){
                           this.caseWrp.Status = 'Closed';
                           this.caseWrp.HubManagerReview__c= 'Technical Approved';
                           this.updateRec();
                        }
                        this.handleSaveCaseQuery();
                    }
                 
                }
                
                else{
                    if((this.status !== 'Cancelled' || this.status !== 'Closed') && this.caseWrp.OverrideByFedFina__c === true){
                        if(this.cpvfi=== true  && this.caseWrp.Final_Status_of_Field_Verification_by_un__c !== ''){
                            this.caseWrp.Status = 'Closed';
                            this.updateRec();
                            
                          
                      }else{
                    this.caseWrp.Status = 'Closed';
                    this.updateRec();
                    this.handleSaveCaseQuery();
                        }                   
                        
                    }
                    this.handleSaveCaseQuery();
        
                } 
                }
                
           })
           .catch((error) => {
             console.log("Erro while upload photos", JSON.stringify(error));
           })

       
        
    } else {
        this.updateRec();
        this.handleSaveCaseQuery();
    }


}

validateForm() {
  
    let isValid = true
    console.log('ERROR CASE DETAILS PhotoCount:::::#877',this.photoCount ,'ReportCount:::',this.reportCount);
    if(!(this.userRole === 'LHM' || this.userRole ==='THM')){
    
    if((this.status === 'New' || this.status === 'Review Requested' || this.status === 'Query' || this.status === 'Query Resolved') && this.caseWrp.OverrideByFedFina__c === true){
        if(this.technical || this.cpvfi){
            if((this.reportCount === undefined || this.reportCount < 1  )  && (this.photoCount === undefined || this.photoCount < 1  )  ){
                isValid=false
                this.ShowToastMessage('Error',this.label.CaseDetailsReportPhotoError,'error','sticky')
            }
            else if(this.reportCount == null || this.reportCount < 1){
                isValid=false
                this.ShowToastMessage('Error',this.label.CaseDetailsReportError,'error','sticky')
            }else if(this.photoCount == null || this.photoCount < 1){
                if(this.cpvfi && !(this.caseWrp.ReportResult__c === 'Negative' && this.caseWrp.Negative_Report_reason__c ==='Difficult to trace the address')){
                    isValid=false
                    this.ShowToastMessage('Error',this.label.CaseDetailsPhotoError,'error','sticky')
                }else if(this.technical){
                    isValid=false
                    this.ShowToastMessage('Error',this.label.CaseDetailsPhotoError,'error','sticky')
                }
               
            }else if(this.technical === true && this.photoCount <= 5){
                isValid=false
                this.ShowToastMessage('Error',this.label.CaseDetailsTechPhotoError,'error','sticky')
            }else if(this.cpvfi === true && (this.caseWrp.Product_Type__c==='Home Loan' || this.caseWrp.Product_Type__c==='Small Ticket LAP') && this.photoCount <= 3){
                isValid=false
                this.ShowToastMessage('Error',this.label.CaseDetailsCpvfiPhotoError,'error','sticky')  
            }else if(this.cpvfi === true && (this.caseWrp.Product_Type__c==='Business Loan' || this.caseWrp.Product_Type__c==='Personal Loan') && this.photoCount <= 1){
                if(this.caseWrp.ReportResult__c === 'Negative' && this.caseWrp.Negative_Report_reason__c ==='Difficult to trace the address'){
                    
                }else{
                    isValid=false
                    this.ShowToastMessage('Error','Please add minimum 2 Photos','error','sticky')  
                }
                
            }
        }
        if(this.tsr || this.vetting || this.legal){
            if(this.reportCount == null || this.reportCount < 1){
                isValid=false
                this.ShowToastMessage('Error',this.label.CaseDetailsReportError,'error','sticky')
            }
        }
      
       
}
  
}

    this.template.querySelectorAll('lightning-input').forEach(element => {
        if(element.reportValidity()){
           // console.log('ERROR CASE DETAILS:::::::#245');
        }else{
            isValid = false;
            this.ShowToastMessage('Error',this.label.CaseDetailsRequiredFieldError,'error','sticky')  
        }


    });
    this.template.querySelectorAll('lightning-combobox').forEach(element => {
        if(element.reportValidity()){
            //
        }else{
            isValid = false;
            this.ShowToastMessage('Error',this.label.CaseDetailsRequiredFieldError,'error','sticky')
        }

    });

    this.template.querySelectorAll('lightning-textarea').forEach(element => {
        if(element.reportValidity()){
            //
        }else{
            isValid = false;
            this.ShowToastMessage('Error',this.label.CaseDetailsRequiredFieldError,'error','sticky')
        }

    });
    return isValid;
}

updateRec() {
    
    if(this.status !== 'Cancelled'){
        this.showSpinner = true;
    let caseArr=[];
    this.caseWrp['Id'] = this.caseId;
    this.caseWrp.sobjectType='Case';
    if(this.caseWrp.ReportResult__c !=='Negative'){
        this.caseWrp.Negative_Report_reason__c='';
    }
    console.log(" this.caseWrp['Id']", JSON.stringify(this.caseWrp));

    caseArr.push(this.caseWrp);

    if(caseArr){
        this.upsertCase(caseArr);
    }
        // const fields = this.caseWrp;
        // const recordInput = { fields };
        // updateRecord(recordInput)
        //     .then(() => {
        //         const selectedEvent = new CustomEvent("select", {
        //             detail: true
        //           });
        //             this.dispatchEvent(selectedEvent);
        //             this.getCaseData();
        //             this.showSpinner = false;
        //         this.ShowToastMessage('Success',this.label.CaseSaveSuccess,'success','sticky')
        //     })
        //     .catch((error) => {
        //         this.showSpinner = false;
        //         console.log(" INSIDE UPDATE RECORD ERROR>>>", error, error.body.message);
        //         this.ShowToastMessage('Error',this.label.CaseQueryRequiredFieldError,'error','sticky')
                
        //     });
        }
}


upsertCase(obj){
    if(obj){   
    console.log('Case Document Detail Records create ##951', obj); 
    
    upsertMultipleRecord({ params: obj })
    .then(result => {     
        const selectedEvent = new CustomEvent("select", {
            detail: true
          });
            this.dispatchEvent(selectedEvent);
            this.getCaseData();
            this.showSpinner = false;
        this.ShowToastMessage('Success',this.label.CaseSaveSuccess,'success','sticky')
        
    })
    .catch(error => {
        this.showSpinner = false;
        console.log(" INSIDE UPDATE RECORD ERROR>>>", error, error.body.message);
        this.ShowToastMessage('Error',this.label.CaseQueryRequiredFieldError,'error','sticky')
    })
  }
}
getCaseDocCount(){
let parameter = {
    ParentObjectName: 'Case',
    ChildObjectRelName: null,
    parentObjFields: ['Id','ReportCount__c','PhotoCount__c','Status'],
    childObjFields: [],
    queryCriteria: ' where id = \'' + this._recordId + '\''
    }


    getSobjectDataNonCacheable({params: parameter})
    .then((result) => {
        if(result.parentRecords[0].PhotoCount__c !== undefined){
          this.photoCount = result.parentRecords[0].PhotoCount__c;
          this.reportCount = result.parentRecords[0].ReportCount__c;
        }
         
       })
       .catch((error) => {
         console.log("Erro while upload photos", JSON.stringify(error));
       });
    }

 //LAK-9771 In absence of LHM or THM updated code   
@track roleList=['LHM','THM','UW','ACM'];
@track thmList=[];
@track lhmList=[];
@track uwList=[];
@track acmList=[];
fetchTeamDetails() {
    let teamHierParam = {
        ParentObjectName: 'TeamHierarchy__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'EmpRole__c', 'Employee__c', 'Employee__r.IsActive'],
        childObjFields: [],
        queryCriteria: ` WHERE EmpRole__c IN ('${this.roleList.join('\', \'')}') AND BranchCode__c = '${this.lanBrchCode}' AND Employee__r.IsActive = true`
    };
    getSobjectDataNonCacheable({ params: teamHierParam })
        .then((result) => {
            console.log("result CASE DETAILS COMP #1282>>>>>", result);
            
            if (result && result.parentRecords && result.parentRecords.length > 0) {
                let arr = result.parentRecords;
                this.thmList = arr.filter(item => item.EmpRole__c === 'THM');
                this.lhmList = arr.filter(item => item.EmpRole__c === 'LHM');
                this.uwList = arr.filter(item => item.EmpRole__c === 'UW');
                this.acmList = arr.filter(item => item.EmpRole__c === 'ACM');
            }
        })
        .catch((error) => {
            console.log("Error in CASE DETAILS COMP #1292", error);
        });
}


ShowToastMessage(title,message,variant,mode){
    const evt = new ShowToastEvent({
        title,
        message,
        variant,
        mode 
    });
    this.dispatchEvent(evt);
}
}