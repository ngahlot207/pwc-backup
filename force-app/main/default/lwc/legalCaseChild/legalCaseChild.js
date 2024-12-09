import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue, getFieldDisplayValue } from 'lightning/uiRecordApi';
import getSobjectDatawithRelatedRecords from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData'; 
import { getObjectInfo, getPicklistValues,getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { subscribe, publish, MessageContext } from 'lightning/messageService';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord, updateRecord, deleteRecord } from "lightning/uiRecordApi";
import upsertMultipleRecord from "@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord";
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import DEVIATION_OBJECT from '@salesforce/schema/Deviation__c';
import LOAN_APPLN_OBJECT from '@salesforce/schema/LoanAppl__c';

import APPROV_ACTION_FIELD from "@salesforce/schema/Deviation__c.Appr_Actn__c";
import TYPE_A_DEV_FIELD from "@salesforce/schema/LoanAppl__c.Is_there_TypeA_devia__c";
import TYPW_B_DEV_FIELD from "@salesforce/schema/LoanAppl__c.Is_there_TypeB_devia__c";

import Deviation_Del_SuccesMessage from '@salesforce/label/c.Deviation_Del_SuccesMessage';
import Deviation_Duplicate_Records from '@salesforce/label/c.Deviation_Duplicate_Records';
import CASE_OBJECT from '@salesforce/schema/Case';
// CPVFI TEMPLATE FIELDS

import UserId from '@salesforce/user/Id';

// TECHNICAL TEMPLATE FIELDS
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import CASE_DOC_OBJECT from '@salesforce/schema/CaseDoc__c';
import CASE_FIELD from '@salesforce/schema/CaseDoc__c.Case__c';
import DOC_DET_FIELD from '@salesforce/schema/CaseDoc__c.DocDetail__c';

import CaseQueryUpdateSuccess from '@salesforce/label/c.CaseQueryUpdateSuccess';
import CaseDocCreateSuccess from '@salesforce/label/c.CaseDocCreateSuccess';
import CaseQueryUpdateError from '@salesforce/label/c.CaseQueryUpdateError';
import CaseSaveSuccess from '@salesforce/label/c.CaseSaveSuccess';
import CaseQueryRequiredFieldError from '@salesforce/label/c.CaseQueryRequiredFieldError';
import deleteDeviationRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import CaseDetailsCpvfiPhotoError from '@salesforce/label/c.CaseDetailsCpvfiPhotoError';
import CaseDetailsPhotoError from '@salesforce/label/c.CaseDetailsPhotoError';
import CaseDetailsReportError from '@salesforce/label/c.CaseDetailsReportError';
import CaseDetailsReportPhotoError from '@salesforce/label/c.CaseDetailsReportPhotoError';
import CaseDetailsRequiredFieldError from '@salesforce/label/c.CaseDetailsRequiredFieldError';
import CaseDetailsTechPhotoError from '@salesforce/label/c.CaseDetailsTechPhotoError';
import Id from "@salesforce/user/Id";

import { CPARoles } from 'c/globalConstant';

import { refreshApex } from '@salesforce/apex'; 
const userId = UserId;


export default class LegalCaseChild extends LightningElement {

    customLabel = {
        Deviation_Del_SuccesMessage,
        Deviation_Duplicate_Records
    }

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

   @api legal;
   @api hasEditAccess;

   @track currentUserId = Id;
   @track userRole;
   //  recordTypeName = 'CPVFI'; // Pass the Record Type Name from the parent component
    @track cpvRecordTypeId;
    @track tsrRecordTypeId;
    @track vettingRecordTypeId;
    @track legalRecordTypeId;
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
  @track legalDevOptions =[];
  //@track disabled;
  @track uploadDoc = true;

  @track legalDevYesNo;
    get valueDevOption(){
        return (this.legalDevYesNo === 'Y' && this.userRole ==='LHM') ;
    }


  get enableForLHM(){
        return this.userRole ==='LHM';
    }

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


@wire(getObjectInfo, { objectApiName: DEVIATION_OBJECT })
objInfo;

get disableMitigant(){
    return this.hasEditAccess === false || this.status !== 'Closed';
}
get disabled(){
    return this.hasEditAccess === false || this.status === 'Closed' || this.status === 'Cancelled' || this.userRole === 'LHM' ;
}

get disbaleHubManager(){
    return this.hasEditAccess === false || this.hubManagerReview === 'Legal Approved' || this.userRole !== 'LHM' || this.status !=='Closed';
}



get showLegal(){
    return this.legal;
}

get addDeviation(){
    return this.legalDevYesNo==='Y';
}

    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        this.handleCaseDocIdChange();
        console.log('set attribute this._loanAppId :',this._loanAppId)
       
    }

    


    handleRecordAppIdChange(value) {
        let tempParams = this.loanAppParams;
        tempParams.queryCriteria = " where Id = '" + this.loanAppId + "'";
      //  this.loanAppParams = { ...tempParams };
    }
    handleRecordIdChange1() {
        let tempParams = this.deviaParams;
        tempParams.queryCriteria = ' where LoanAppln__c = \'' + this.loanAppId + '\' AND DeviationCategory__c =\'Legal\''
        this.deviaParams = { ...tempParams };
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
        return this.hasEditAccess === false || (CPARoles && CPARoles.includes(this.userRole)) || this.status !== 'Closed';  //LAK-9244
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

    @track disableMode
    @track Apprv_By__c;


    connectedCallback(){
        console.log('this.hasEditAccess:::::392 in legalCaseDetails',this.hasEditAccess,    this.disbaleHubManager);
        // if (this.hasEditAccess === false) {
        //     this.disabled = true;
        //   }
        this.activeSection = ["A","B"];
        
        this.fetchDeviationData();

         if (this.hasEditAccess === false) {
            this.Apprv_By__c = true;
            this.disableMode = true;
            this.disbApprCheckbox = true;
            //this.deleteButton = false;
           

        }
        else {
            this.Apprv_By__c = false;
            this.disableMode = false;
            
        }



         
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
        parentObjFields: ['Id', 'Account.Name', 'Applicant__r.TabName__c','Applicant__r.PhoneNumber__c','Loan_Application__r.Name', 'caseNumber','CreatedDate','Property_Owner_s_as_per_Technical_Repo__c','Applicant__r.FullName__c'],
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
          'FinalStatusOfTSR__c','QueryRevert__c','HubManagerReview__c','AreThereAnyLegalDeviations__c'],
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
             
             this.legalDevYesNo =result.parentRecords[0].AreThereAnyLegalDeviations__c;
             this.dateTimeInitiation= result.parentRecords[0].DateTimeInitiation__c;
             this.caseWrp.Dedupe_for_Negative_Database__c = result.parentRecords[0].Dedupe_for_Negative_Database__c ? result.parentRecords[0].Dedupe_for_Negative_Database__c : '';
             this.caseWrp.AddressOwnership__c = result.parentRecords[0].AddressOwnership__c ? result.parentRecords[0].AddressOwnership__c : '';
           //  this.caseWrp.Date_of_Report__c = result.parentRecords[0].Date_of_Report__c ? result.parentRecords[0].Date_of_Report__c : '';
            this.reportDate = result.parentRecords[0].Date_of_Report__c;
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
            this.hubManagerReview=result.parentRecords[0].HubManagerReview__c ? result.parentRecords[0].HubManagerReview__c : '';
            this.statusReport=result.parentRecords[0].ReportResult__c;
            this.caseWrp.TSRVerification__c = result.parentRecords[0].TSRVerification__c ? result.parentRecords[0].TSRVerification__c : '';
            this.caseWrp.IsTheTitleClearNdMarketable__c = result.parentRecords[0].IsTheTitleClearNdMarketable__c ? result.parentRecords[0].IsTheTitleClearNdMarketable__c :'' ;
            this.caseWrp.Final_Remarks__c = result.parentRecords[0].Final_Remarks__c ? result.parentRecords[0].Final_Remarks__c :'' ;
            this.caseWrp.Query_description__c = result.parentRecords[0].Query_description__c ? result.parentRecords[0].Query_description__c :'' ;
            this.caseWrp.DetailsSearchReport__c= result.parentRecords[0].DetailsSearchReport__c ? result.parentRecords[0].DetailsSearchReport__c :'' ;
            this.caseWrp.QueryRevert__c = result.parentRecords[0].QueryRevert__c ? result.parentRecords[0].QueryRevert__c :'' ;
            this.caseWrp.FinalStatusTSRReportFromHLM__c = result.parentRecords[0].FinalStatusTSRReportFromHLM__c ? result.parentRecords[0].FinalStatusTSRReportFromHLM__c :'' ;
            this.caseWrp.FinalStatusOfTSR__c= result.parentRecords[0].FinalStatusOfTSR__c ? result.parentRecords[0].FinalStatusOfTSR__c :'' ;
             
           // this.caseWrp.Remarks_regarding_the_case__c = result.parentRecords[0].Remarks_regarding_the_case__c ? result.parentRecords[0].Remarks_regarding_the_case__c :'' ;
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
    
@track showDeleteIcon=false;
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
               this.propOwners = data.parentRecords[0].Property_Owner_s_as_per_Technical_Repo__c;
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
                if(recordType.name === 'Legal'){
                    this.legalRecordTypeId=key;
                }
               
            }
            console.log('data.legalRecordTypeId::::::682', this.legalRecordTypeId);
           
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
    
   


    @track lookupRec;
    @track devDesc;
    @track deviaLevel;

    @track
    deviaMasParam = {
        ParentObjectName: 'DeviaMstr__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'LWDD_Dev_DTL_Id__c', 'LWDD_LWD_DevId__c', 'LWDD_LRRM_RuleId__c', 'LWDD_Prio_N__c',
        'LWDD_LSR_RoleId__c', 'LWDD_Devi_Desc__c', 'LWDD_NPM_Prod__c', 'SchemeId__c', 'IsActive__c'],
        childObjFields: [],
        queryCriteria: ''
    }



    @api handleValueSelect(event) {
        this.lookupRec = event.detail;
        console.log('lookup :',this.lookupRec)
        console.log('event.target.fieldName ==>',event.target.fieldName,  this.records)
        if (event.target.fieldName === 'Devia_Desrp__c') {
            this.devDesc = this.lookupRec.mainField;
            if(this.devDesc){
                console.log(' this.records:::::817', JSON.stringify(this.records));
                if(this.checkDuplicateDevi(this.devDesc)){
                    this.ShowToastMessage('Error', this.customLabel.Deviation_Duplicate_Records, 'error', 'sticky')
                    //this.devDesc= ''
                    this.index = event.target.index
                    this.records[this.index].Devia_Desrp__c = '';
                    this.records[this.index].Dev_DescrId__c = '';
                    this.records[this.index].DeviationMaster__c ='';
                    this.records[this.index].devMstRec='';
                    this.records[this.index].DeviationCategory__c='';
                    this.records[this.index].Req_Apprv_Level__c = '';
                    this.records[this.index].Deviation__c = '';
                    

                }else{
                    this.hasDupliDev = false
                    this.index = event.target.index
                    this.records[this.index].Devia_Desrp__c = this.lookupRec.mainField;
                    this.records[this.index].Dev_DescrId__c = this.lookupRec.id;
                    this.records[this.index].DeviationMaster__c = this.lookupRec.id;
                    this.records[this.index].devMstRec=this.lookupRec.mainField;
                    this.records[this.index].DeviationCategory__c='Legal'
                    console.log('this.devDesc ==',this.devDesc)
                    console.log('value setting Lw Id::',this.lookupRec.record.LWDD_Prio_N__c)
                    console.log('value setting dev id::',this.lookupRec.record.LWDD_Dev_DTL_Id__c)
                    this.records[this.index].Req_Apprv_Level__c = this.lookupRec.record.LWDD_Prio_N__c ;  
                    this.records[this.index].Deviation__c = this.lookupRec.record.LWDD_Dev_DTL_Id__c;
                //     this.records.forEach(item => {
                //         if(item.DeviationMaster__c !==""){
                //           let obj={...item}
                //           this.tempArr.push(obj);
                //       }          
                //       })
                //   this.records=[];
                //  this.records=[...this.tempArr]

                }
                
            }
          
            if (this.devDesc === null) {
                console.log('inside if')
                this.disbApprCheckbox = false
                this.records[this.index].approvedby = false
                this.records[this.index].Deviation__c = ''
                this.records[this.index].Req_Apprv_Level__c = ''
            }
                   
    }

    }

    handleValueSelect1(){
        this.getCaseDocCount();
        this.refreshDocTable();
    }

    checkDuplicateDevi(deviDesc){
        let flag= false
        console.log('deviDesc',deviDesc );
        if(this.records && this.records.length>0){
            this.records.forEach(i=>{
                if(i.DeviationMaster__c !== null && i.devMstRec !== null){
                    if(i.devMstRec === deviDesc){
                        flag=true;                  
                    }   
                }
                          
            })
        }   
        return flag;
    }


   @api refreshDocTable() {
    this.showSpinner = false;
    let child = this.template.querySelector('c-show-case-document');
    child.handleFilesUploaded();

    
}

    @wire(getPicklistValuesByRecordType, {
        objectApiName: CASE_OBJECT,
        recordTypeId: '$legalRecordTypeId',
    })
    LegalPicklistHandler({ data, error }) {
        if (data) {       
            console.log('data:::::804',data);  
            this.legalDevOptions =[...this.generatePicklist(data.picklistFieldValues.AreThereAnyLegalDeviations__c)] 
            this.finalStatusHLMOptions=[...this.generatePicklist(data.picklistFieldValues.FinalStatusTSRReportFromHLM__c)]
            this.titleOptions=[...this.generatePicklist(data.picklistFieldValues.IsTheTitleClearNdMarketable__c)]
            this.finalStatusTSROptions=[...this.generatePicklist(data.picklistFieldValues.FinalStatusOfTSR__c)]
            this.reportStatusOptions=[...this.generatePicklist(data.picklistFieldValues.ReportResult__c)]
        }

        if (error) {
            console.error('ERROR CASE DETAILS:::::::#344',error)
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
      if(event.target.dataset.name ==='AreThereAnyLegalDeviations__c'){
        this.legalDevYesNo = event.target.value;
        console.log('values ',this.legalDevYesNo)
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

// createCaseDocument() {
//     //console.log('this.caseId ROW ID IS #412::::::',this._recordId);
//     const fields = {};
//     fields[CASE_FIELD.fieldApiName] = this._recordId;

    
//     this.docArr.forEach(item=>{
//         fields[DOC_DET_FIELD.fieldApiName] = item;
//         const recordInput = { apiName: CASE_DOC_OBJECT.objectApiName, fields };
//         createRecord(recordInput)
//             .then(result => {
//                // console.log('CASE DOCUMENT RESULT:::::421',result);
//                 this.ShowToastMessage('Success',this.label.CaseDocCreateSuccess,'success','sticky')
                   
//             })
//             .catch(error => {
//                 console.log('CASE DOCUMENT RESULT ERRO:::::510',error);
        
//             });
//     })
   

//     }

createCaseDocument() {
    let caseDocDtl=[];
    this.docArr.forEach(item=>{
        const fields = {};
        fields[CASE_FIELD.fieldApiName] = this._recordId;
        fields[DOC_DET_FIELD.fieldApiName] = item;
        fields.sobjectType='CaseDoc__c'
        caseDocDtl.push(fields);
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


  draftValues = [];

  async handleSaveDataTable(event) {
    // Convert datatable draft values into record objects
    const records = event.detail.draftValues.slice().map((draftValue) => {
      const fields = Object.assign({}, draftValue);
      return { fields };
    });

    // Clear all datatable draft values
    this.draftValues = [];

    try {
      // Update all records in parallel thanks to the UI API
      const recordUpdatePromises = records.map((record) => updateRecord(record));
      await Promise.all(recordUpdatePromises);

      refreshApex(this.wiredData);
    } catch (error) {
        this.ShowToastMessage('Error',this.label.CaseQueryUpdateError,'error','sticky')
     
    }
}
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
            console.log("Result photo and report count 992", JSON.stringify(result));
           
              this.photoCount = result.parentRecords[0] && result.parentRecords[0].PhotoCount__c ? result.parentRecords[0].PhotoCount__c : 0;
              this.reportCount = result.parentRecords[0] && result.parentRecords[0].ReportCount__c ? result.parentRecords[0].ReportCount__c: 0;
        
            this.isInputCorrect = this.validateForm();
            if (this.isInputCorrect === true) {
        //        if(this.tsr === true || this.vetting === true || this.legal === true){
                    if(this.userRole ==='LHM'){
                        this.caseWrp.Status = 'Closed';
                        this.caseWrp.HubManagerReview__c= 'Legal Approved';
                        this.updateRec();
                        this.handleSaveCaseQuery();
                        if (!this.hasDupliDev) {
                            console.log('hasDupliDev upserting')
                            this.handleUpsert();
                            }else{
                                this.fetchDeviationData();
                            }
                    }else{
                       

                        if(!(this.status === 'Cancelled' || this.status === 'Closed') && this.reportCount > 0 && this.caseWrp.OverrideByFedFina__c === true){
                            this.caseWrp.Status = 'Closed';
                            this.caseWrp.HubManagerReview__c= 'Legal Review';
                            this.updateRec();
                            
                        }else{
                            // this.caseWrp.Status = 'Closed';
                             this.updateRec();
                        }
                        this.handleSaveCaseQuery();
                    }
                 
               // }
                }
                
           })
           .catch((error) => {
             console.log("Erro while upload photos", JSON.stringify(error));
           })

            //let returnVariable;
            console.log('this.hasDupliDev =='+this.hasDupliDev)
            console.log('this.hasDupliDev not=='+ !this.hasDupliDev)
            
           
            

       
        
    } else {
        this.caseWrp.Status=this.status;
        this.updateRec();
        this.handleSaveCaseQuery();
        if (!this.hasDupliDev) {
            console.log('hasDupliDev upserting')
            this.handleUpsert();
            }else{
                this.fetchDeviationData();
            }
    }


}

validateForm() {
  
    let isValid = true
    console.log('ERROR CASE DETAILS PhotoCount:::::#877',this.photoCount ,'ReportCount:::',this.reportCount);
    if(this.userRole !== 'LHM'){
    console.log('this.caseWrp.OverrideByFedFina__c ==',this.caseWrp.OverrideByFedFina__c);
    if(this.status === 'New' || this.status === 'Review Requested' || this.status === 'Query' || this.status === 'Query Resolved' ){
        if(this.tsr || this.vetting || this.legal){
            if((this.reportCount == null || this.reportCount < 1)  && this.caseWrp.OverrideByFedFina__c === true){
                isValid=false
                this.ShowToastMessage('Error',this.label.CaseDetailsReportError,'error','sticky')
            }
        }
      
       
}
  
}
if(this.userRole === 'LHM' && this.addDeviation){
    if(this.records && this.records.length>0){
            //
    }else{
        isValid = false;
        this.ShowToastMessage('Error','Please add at least 1 deviation record','error','sticky') 
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

    let customValidate=this.checkValidityLookup();


    return isValid && customValidate 
    
}


checkValidityLookup() {
    let isInputCorrect = true; 
    let allChilds = this.template.querySelectorAll("c-custom-lookup");
    allChilds.forEach((child) => {
        if (!child.checkValidityLookup()) {
            child.checkValidityLookup();
            isInputCorrect = false;
        }
    });
    return isInputCorrect;
}

updateRec() {
    
    // if(this.status !== 'Cancelled'){
    //     this.showSpinner = true;
    
    // this.caseWrp['Id'] = this.caseId;
    // console.log(" this.caseWrp['Id']", JSON.stringify(this.caseWrp));

    // const fields = this.caseWrp;

    //     const recordInput = { fields };
    //     updateRecord(recordInput)
    //         .then(() => {
    //             const selectedEvent = new CustomEvent("select", {
    //                 detail: true
    //               });
    //                 this.dispatchEvent(selectedEvent);
    //                 this.getCaseData();
    //                 this.showSpinner = false;
    //             this.ShowToastMessage('Success',this.label.CaseSaveSuccess,'success','sticky')
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log(" INSIDE UPDATE RECORD ERROR>>>", error, error.body.message);
    //             //this.ShowToastMessage('Error',this.label.CaseQueryRequiredFieldError,'error','sticky')
                
    //         });
    //     }

        //

        if(this.status !== 'Cancelled'){
            this.showSpinner = true;
        let caseArr=[];
        this.caseWrp['Id'] = this.caseId;
        this.caseWrp.sobjectType='Case';
        console.log(" this.caseWrp['Id']", JSON.stringify(this.caseWrp));
    
        caseArr.push(this.caseWrp);
    
        if(caseArr){
            this.upsertCase(caseArr);
        }

        }

        //
}

//

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

//

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

    // Deviation  
    @track records = [];
    @track numberOfRec = 0;
    @track isAllDevAppr = false
    @track apprAll;
    @track systDev = false
    @track manualDev = true
    @track updatedRecordsOfOldDev = []
    @track index
    @track _wiredDeviationData = [];
    @track recordsOfOldDev = []
    @track existRecords = [];
     @track oldrecords = []
    @track myNewElement
    @track userLevel;
    @track approvedby = true;
    @track commentTemp = false
    @track falseCommentTemp = false

    @track isModalOpen = false;

    strLegal1='Legal'
    
      @track deviaParams;

        //imperative for deviation
@track wiredDataResult=[]
     @api
     fetchDeviationData() {
        let deviaParams = {  
            ParentObjectName: 'Deviation__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'Name', 'LoanAppln__c','RemarksForInternalLegal__c', 'Applicant__c',
                'DeviationMaster__r.Deviation_Category__c','DeviationMaster__c',
                 'BRE_Call_Iden__c', 'Dev_Type__c', 'Deviation__c', 'Apprv_By__c',
                  'Appr_Actn__c', 'Apprv_By__r.Name', 'Req_Apprv_Level__c', 'Devia_Desrp__c',
                   'Mitigation__c', 'Appr_Remarks__c', 'Dev_DescrId__c', 'Comments__c','DeviationCategory__c',
                   'DeviationMaster__r.Devia_Desc_Text__c'
                ],
            childObjFields: [],
             //queryCriteria: ''
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND DeviationCategory__c =\'Legal\''
        };
        console.log('fetching deviation data')
        getSobjectDataNonCacheable({ params: deviaParams })
            .then((data) => {
                this.records=[];
                console.log('data deviation = 1390',data);
                this.wiredDataResult =  data.parentRecords ; // Store the result
                this.records =  [...this.wiredDataResult];
                let arrayTemp =[...data.parentRecords];
               // let arr=[]
                // if(this.disbaleHubManager){
                //     let obj={}
                //     arrayTemp.forEach(i=>{
                //        obj={...i,disTemp:true};
                //        arr.push(obj);
                //     })
                // }

                // this.records=[...arr];
                console.log(' this.records deviation = 1286', this.records);
                if (this.deletedRecordId) {
                    this.records = arrayTemp.filter(record => record.Id !== this.deletedRecordId);
                } 
                this.processDeviationData(this.records);
              console.log(' this.records deviation = 1291', this.records);
            })
            .catch((error) => {

                console.log('error found=',error);
                console.log('error ', error);
            });

            
    }

    @track reqDev=true;


    processDeviationData(data) {
        // Your existing logic to process the data 
        console.log('processDeviationData enter',data)
        this.recordsOfOldDev = [];
        this.existRecords = [];
        if (data !== undefined) {
            //this.oldrecords = [...this.records1, ...data];
            this.existRecords = data;
            this.records = [];
            if (this.existRecords !== undefined) {
                this.existRecords.forEach(dev => {
                  //  let disTemp=false;
                    this.myNewElement = {
                            Id: dev.Id,
                            Deviation__c: dev.Deviation__c || '',
                            Dev_DescrId__c:  dev.Dev_DescrId__c ,
                            Req_Apprv_Level__c: dev.Req_Apprv_Level__c || '',
                            RemarksForInternalLegal__c: dev.RemarksForInternalLegal__c || '',
                            Devia_Desrp__c: dev.Devia_Desrp__c || '',
                            Apprv_By__r: dev.Apprv_By__r || {},
                            Appr_Actn__c: dev.Appr_Actn__c || '',
                            Mitigation__c: dev.Mitigation__c || '',
                            Appr_Remarks__c: dev.Appr_Remarks__c || '',
                            Dev_Type__c: dev.Dev_Type__c || '',
                            Comments__c: dev.Comments__c || '',
                            DeviationMaster__c:dev.DeviationMaster__c || '',
                            devMstRec : dev.DeviationMaster__r.Devia_Desc_Text__c || '',
                            approvedby: false,
                            systDev: false,
                            manualDev: true,
                            delete: false,
                            disbComm: true,
                            isReqComments: false,
                            // disAppStatus: dev.Appr_Actn__c === 'Approved',
                            // disTemp : (dev.Appr_Actn__c === 'Approved'),
                            isPinReq : true,
                           
                        ///
                    };
                    if (dev.Apprv_By__c) {
                        this.myNewElement.Apprv_By__r.Name = dev.Apprv_By__r.Name;
                    }
                    // if(disTemp){
                    //     this.myNewElement.disTemp = true;
                    // }
                    this.recordsOfOldDev.push(this.myNewElement);
                   
                });
                this.records=[];
                this.records=[...this.recordsOfOldDev]
                console.log(' this.records:::::1461', this.records);
            }
        }
    }




    @track deleteButton = true;
    @track disbApprCheckbox = false
    @track _spddConfigData
    @track _wiredLoanApplData
    
    
    handleDeleteRecIdRemoveThis(delRecId) {
        console.log('inside delete id :',delRecId)
        deleteRecord(delRecId).then((result) => {
            this.ShowToastMessage('Success', this.customLabel.Deviation_Del_SuccesMessage, 'success', 'sticky');
            this.fetchDeviationData();
            this.disbApprCheckbox = false;        
            this.isModalOpen = false;
        }).catch((error) => {
            this.isModalOpen = false;
            console.log('Errror !! ' + JSON.stringify(error));
            this.ShowToastMessage("Error deleting record",error.body.message,"error","sticky")

        });
    }

    //my method


            @track del_recIds = []

            ///new delete method

            handleDeleteRecId(delRecId) {

                 
                let fields = {};
                fields.Id = delRecId;
                this.deletedRecordId=delRecId;
                this.del_recIds = []
                this.del_recIds.push(fields)
                console.log("deleteRec_Array ", this.del_recIds);
               
                deleteDeviationRecord({ rcrds: this.del_recIds })
                .then((result) => {
                console.log('Delete result:', result);
                this.ShowToastMessage('Success', this.customLabel.Deviation_Del_SuccesMessage, 'success', 'sticky')
                this.fetchDeviationData();
                this.disbApprCheckbox = false;
                return Promise.all([
                    refreshApex(this._wiredDeviationData),
                    refreshApex(this._spddConfigData),
                    refreshApex(this._wiredLoanApplData)
                    ]);
                })
                .then(() => {
                    this.isModalOpen = false;
                    console.log('Refreshed all apex data.');
                    
                })
            .catch((error) => {
                this.isModalOpen = false;
                this.ShowToastMessage('Success', this.customLabel.Deviation_Del_SuccesMessage, 'success', 'sticky');
            
                console.error('Error in deleteDeviationRecord:', JSON.stringify(error));
               // this.ShowToastMessage('Error deleting record', error.body.message, 'error', 'sticky');
            });
                //
            }

    //my method

    @track isLoading = false;
    @track deviationRec = [];
    @track removeModalMessage = 'Do you want to delete?';
    @track spddUserId;
    @track apprAllDevi = false
    @track deviIdList = [];
    
    strLegal='Legal';
    @track
    loanAppParams = {
        ParentObjectName: "LoanAppl__c",
        ChildObjectRelName: "Deviations__r",
        parentObjFields: [
            "Id",
            "Name",
            "Product__c",
            "Stage__c",
            "SubStage__c",
            "ProductSubType__c",
            "Is_there_TypeA_devia__c",
            "Is_there_TypeB_devia__c",
            "Applicant__c"
        ],
        childObjFields: ['Id', 'Name', 'LoanAppln__c', 'Applicant__c', 'BRE_Call_Iden__c', 'Dev_Type__c', 'Deviation__c', 'Apprv_By__c', 'Appr_Actn__c', 'Apprv_By__r.Name', 'Req_Apprv_Level__c', 'Devia_Desrp__c', 'Mitigation__c', 'Appr_Remarks__c', 'Dev_DescrId__c', 'Comments__c'],
        //queryCriteria: " WHERE Id IN (SELECT LoanAppln__c FROM Deviation__c where DeviationMaster__r.Deviation_Category__c = 'Legal') "
        //queryCriteria: ' WHERE Id IN (SELECT LoanAppln__c FROM Deviation__c where DeviationMaster__r.Deviation_Category__c = \'' + this.strLegal + '\') '
       queryCriteria: ""
    };

     
     

    handleDeleteAction(event) {
        this.isModalOpen = true;
        this.deleteRecId = event.target.dataset.id;
        this.deleteIndex = event.target.dataset.index
    }


    @api handleUpsert() {
        var saveStatus = true;

        if (this.isLoading == false) {
            this.isLoading = true;

            console.log('handleUpsert enter with :',this.records)
            this.deviationRec = [];
            for (var i = 0; i < this.records.length; i++) {
                console.log('dev loop :'+i+'num',this.records[i].Devia_Desrp__c)
                let parentRecord = {};
                var oldDev = this.records[i];

                if (oldDev.Devia_Desrp__c !== undefined && oldDev.Devia_Desrp__c !== "") {

                    parentRecord.Name = oldDev.Name;
                    parentRecord.LoanAppln__c = this.loanAppId;
                    parentRecord.Deviation__c = oldDev.Deviation__c;
                    parentRecord.Devia_Desrp__c = oldDev.Devia_Desrp__c;
                    parentRecord.Dev_DescrId__c = oldDev.Dev_DescrId__c;
                    parentRecord.Req_Apprv_Level__c = oldDev.Req_Apprv_Level__c;
                   // parentRecord.DeviationCategory__c = 'Legal';
                    parentRecord.Mitigation__c = oldDev.Mitigation__c;
                    parentRecord.RemarksForInternalLegal__c = oldDev.RemarksForInternalLegal__c;
                    //new added change
                    //parentRecord.Dev_DescrId__c= oldDev.DeviationMaster__c;
                    parentRecord.DeviationMaster__c = oldDev.DeviationMaster__c;
                    console.log('check approve master :', oldDev.DeviationMaster__c);
                    console.log('check approve action', oldDev.Appr_Actn__c);
                  
                    if (oldDev.Dev_Type__c) {
                        parentRecord.Dev_Type__c = oldDev.Dev_Type__c
                    } else {
                        parentRecord.Dev_Type__c = 'System';
                    }
                    parentRecord.Appr_Actn__c = oldDev.Appr_Actn__c;
                  
                    parentRecord.sobjectType = 'Deviation__c';

                    if (oldDev.Id) {
                        parentRecord.Id = oldDev.Id;
                    }

                    this.deviationRec.push(parentRecord);
                }
            }

            let arrayOfSelectedValues = [];
            let alloptOfOwner = [];
            arrayOfSelectedValues = this.deviIdList;
            alloptOfOwner = this.existRecords;
            let resultOfCompareArrays = alloptOfOwner.filter(o => arrayOfSelectedValues.find(x => x.Id === o.Id)).map(o => o.Id);

            /*this.deviaWrapObj.sobjectType = "LoanAppl__c";
            this.deviaWrapObj.Id = this._recordId;
            this.deviaWrapObj.Applicant__c = this.applicantId;*/
            let loanAppObj = {};
            loanAppObj.sobjectType = "LoanAppl__c";
            loanAppObj.Id = this.loanAppId;

            let upsertData = {
                parentRecord: loanAppObj,
                ChildRecords: this.deviationRec,
                ParentFieldNameToUpdate: "LoanAppln__c"
            };
            console.log('upsert data', upsertData);
            upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
                .then(result => {
                    this.recordsOfOldDev = []
                    this.existRecords = []
                    this.isAllDevAppr = false
                    this.apprAllDevi = false
                    if (result.ChildReords.length > 0) {
                        this.isAllDevAppr = true
                    }
                    if(this.userRole === 'LHM' && this.legalDevYesNo){
                    this.ShowToastMessage('Success', 'The Deviation records Created Successfully', 'success', 'sticky');
                    this.fetchDeviationData();
                    }
                    
                    refreshApex(this._wiredDeviationData);
                    refreshApex(this._spddConfigData);
                    refreshApex(this._wiredLoanApplData);
                    
                    this.isLoading = false;
                })
                .catch(error => {
                    saveStatus = false;
                    this.isLoading = false;
                    console.log('error print deviation', error);
                });

        }

        return saveStatus;
    }
    @track deleteRecId;
    @track hasDupliDev = false
    @track deleteIndex
    closeModal(event) {
        this.isModalOpen = false;
    }

    handleRemoveRecord(event) {
        console.log('delete start :',this.deleteRecId)
        if (this.deleteRecId) {
            if (this.deleteRecId.length == 18) {
                this.handleDeleteRecId(this.deleteRecId);
                this.fetchDeviationData();
            }
        } else {
            this.records.splice(this.deleteIndex, 1);
            this.isModalOpen = false;
            this.fetchDeviationData();
        }
    }
    
    addRow() {

        console.log('add row called')
        this.numberOfRec = this.records.length + 1;
        let myNewElement = {
            Deviation__c: "",
            Devia_Desrp__c: "",
            Req_Apprv_Level__c: "",
            Apprv_By__r: "",
            Appr_Actn__c: "",
            Mitigation__c: "",
            Appr_Remarks__c: "",
            LoanAppln__c: this.loanAppId,
            Dev_Type__c: "Manual",
            DeviationCategory__c:'Legal',
            approvedby: true,
            systDev: false,
            manualDev: true,
            delete: false,
            isReqComments: false
        };
        let deviaDa = [...this.records, myNewElement];
        this.records = deviaDa;
        console.log('deviation:',this.records)
        this.isAllDevAppr = true
        this.apprAll = false
    }


    handleStatusChange(event) {
        const index = event.target.dataset.index;
        const fieldName = event.target.dataset.name;
        const value = event.target.value;

        if (fieldName === 'Appr_Actn__c') {
            this.records[index].Appr_Actn__c = value;
            this.records[index].Apprv_By__r = this.records[index].Apprv_By__r || {};
            this.records[index].Apprv_By__r.Name = this.userName;

        } else if (fieldName === 'Mitigation__c') {
            let strVal = value;
            this.records[index].Mitigation__c = strVal.toUpperCase();
        }else if (fieldName === 'RemarksForInternalLegal__c') {
                this.records[index].RemarksForInternalLegal__c = value;
        }
        // else if (fieldName === 'Devia_Desrp__c') {
        //         this.records[index].RemarksForInternalLegal__c = value;
        // }

    }


    @track loanApplStage
    @track reqFromUW
    @track prodTy
    @track npmIsActive = true
    @track deviaWrapObj = {}

    get filCondnDevDesrp() {
        // console.log('product:'+this.prodType)
        return (" Deviation_Category__c = 'Legal' ");

        // if (this.prodTy === "Home Loan") {
        //     return ("LWDD_NPM_Prod__c=" + "'" + this.prodTy + "'" + " AND IsActive__c=" + this.npmIsActive);
        // } else if (this.prodTy === "Small Ticket LAP") {
        //     return ("LWDD_NPM_Prod__c=" + "'" + this.prodTy + "'" + " AND IsActive__c=" + this.npmIsActive);
        // }

    }

    @wire(getSobjectDatawithRelatedRecords, { params: "$loanAppParams" })
    handleResponse(result) {
        console.log('loanAppParam query:',this.loanAppParams)
        const { data, error } = result;
        this._wiredLoanApplData = result;
        if (data) {
            if (data.parentRecord != undefined) {
                console.log('loanAppParams ==',data.parentRecord)
                this.loanApplStage = data.parentRecord.Stage__c;
                if (this.loanApplStage !== "DDE" && this.loanApplStage !== "QDE") {
                    this.reqFromUW = true;
                }else{
                    this.reqFromUW = false
                }

                //LAK-6471
                // if (this.loanApplStage && (this.loanApplStage == "DDE" || this.loanApplStage == "QDE")) {
                //     this.disableMode = true;
                // }

                this.deviaWrapObj = { ...data.parentRecord };
            }
        }
    }




    // Deviation END




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