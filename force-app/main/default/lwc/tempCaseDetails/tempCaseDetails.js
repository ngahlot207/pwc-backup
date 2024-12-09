import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue, getFieldDisplayValue } from 'lightning/uiRecordApi';
import getSobjectDatawithRelatedRecords from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData'; 
import { getObjectInfo, getPicklistValues,getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { subscribe, publish, MessageContext } from 'lightning/messageService';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord,updateRecord,deleteRecord } from "lightning/uiRecordApi";
import upsertMultipleRecord from "@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord";
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import UserNameFIELD from '@salesforce/schema/User.Name';
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
import Deviation_Del_SuccesMessage from '@salesforce/label/c.Deviation_Del_SuccesMessage';
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
import DEVIATION_OBJECT from '@salesforce/schema/Deviation__c';
import CASE_DOC_OBJECT from '@salesforce/schema/CaseDoc__c';
import CASE_FIELD from '@salesforce/schema/CaseDoc__c.Case__c';
import DOC_DET_FIELD from '@salesforce/schema/CaseDoc__c.DocDetail__c';

import CaseQueryUpdateSuccess from '@salesforce/label/c.CaseQueryUpdateSuccess';
import CaseDocCreateSuccess from '@salesforce/label/c.CaseDocCreateSuccess';
import CaseQueryUpdateError from '@salesforce/label/c.CaseQueryUpdateError';
import CaseSaveSuccess from '@salesforce/label/c.CaseSaveSuccess';
import CaseQueryRequiredFieldError from '@salesforce/label/c.CaseQueryRequiredFieldError';
import UserId from '@salesforce/user/Id';
import CaseDetailsCpvfiPhotoError from '@salesforce/label/c.CaseDetailsCpvfiPhotoError';
import CaseDetailsPhotoError from '@salesforce/label/c.CaseDetailsPhotoError';
import CaseDetailsReportError from '@salesforce/label/c.CaseDetailsReportError';
import CaseDetailsReportPhotoError from '@salesforce/label/c.CaseDetailsReportPhotoError';
import CaseDetailsRequiredFieldError from '@salesforce/label/c.CaseDetailsRequiredFieldError';
import CaseDetailsTechPhotoError from '@salesforce/label/c.CaseDetailsTechPhotoError';
import Id from "@salesforce/user/Id";
import { refreshApex } from '@salesforce/apex'; 

const fields =[FI_AGENCY,APPLICANT,PHONE,MOBILE,FI_INITIATE_DATE,BRANCH,REPORT_DATE,COMPLETE_ADD,BUSINESS_EMP_NAME,NEGATIVE_AREA,PROPERTY_TYPE,
    NEIGHBOUR_REF_CHK,FED_BRNC_DIST,DEDUPE_NEGATIVE,NEGATIVE_DATABASE,ADVERSE_REMARKS,NEG_REPORT_REASON,
CASE_REMARKS,FINAL_VERF_STATUS,MITIGANT_STATUS,PRODUCT_TYPE,DETAILS_BORROWER,ADDRESS_TYPE,ADDRESS_LINE_1,ADDRESS_LINE_2,STATUS,
LAND_AREA,LAND_VALUE,PROPERTY_AREA,RESI_AGE,PROPRTY_VALUE,RECONST_COST,TOTAL_VALUE,PROP_AGE,PLOT_AGRI_PICK,APPROV_LAYOPT_PICK,
PROP_USAGE_PICK,REPORT_PICK,STAGE_COMLE_PERCENT,RECOMMEND_VALUER,OVERRIDE_BY_FEDFINA,ADDL_APPL_NAME, MARITAL_STATUS,EXPIRY_DATE,IS_REINIT_EXP,
PHOTO_COUNT,REPORT_COUNT];

const userId = UserId;

export default class TempCaseDetails extends LightningElement {

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
    
    @api technical;
    @api cpvfi;
    @api tsr;
    @api legal;
    @api vetting;
    @track _currentTabId;

    @api legalShow;
    @track tatReport;  
    @track prodType;    
    @track isTitlClrNMar;    
    @track reportRes;     
    @track dateOfReport;    
    @track finRemark;
    @track queryDes;
  


    @track currentUserId = Id;
    @track userRole;
    @track cpvRecordTypeId;
    @track tsrRecordTypeId;
    @track vettingRecordTypeId;
    @track legalRecordTypeId;
    @track accountName;
    @track appName;
    @track appPhone;
    @track address;
    @track filterCriteria = 'Property Papers';
    @track deleteIndex
    @track lookupRec;
    @track caseWrp = {}
    @track caseQryWrp={}
    @track mandtory = false;
    @track caseQryList=[] ;
    @track caseDocList=[];
    @track commentQryList=[];
    @track isModalOpen = false;

    // deviation
  @track deletedRecordId;
  @track loanNumber;
  @track propOwners;
  @track deviationMstrId;
 
 
  @track numberOfRec = 0;
  @track commentTemp= false;
  @track isAllDevAppr = false;
  @track apprAll;
  
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

  
    @track manualDev=true;
    @track deviaParams;
    @track wiredDataResult =[];
    @track _wiredDeviationData;
    @track recordsOfOldDev= [];
    @track existRecords = [];
    @track oldrecords= []
    @track records = [];
    @track records1 = [];

    @track updatedRecordsOfOldDev= [];
    @track disbApprCheckbox = false;
    @api hasEditAccess;

    get alldeviationDataList(){
        return this.records1;
    }
    @track myNewElement;
    @track userLevel;
    @track userName;
    @track spddUserId;

    @track _wiredLoanApplData
    @track loanApplStage
    @track reqFromUW;
    @track deviaWrapObj = {};
    @track obj = {
        Status__c: ""
    };

    @track disAppStatus =false;
    @track deleteButton = true;


        @track
        deviaMasParam = {
            ParentObjectName: 'DeviaMstr__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'Name','Deviation_Category__c' ,'LWDD_Dev_DTL_Id__c', 'LWDD_LWD_DevId__c', 'LWDD_LRRM_RuleId__c', 'LWDD_Prio_N__c',
                'LWDD_LSR_RoleId__c', 'LWDD_Devi_Desc__c', 'LWDD_NPM_Prod__c', 'SchemeId__c', 'IsActive__c'],
            childObjFields: [],
            queryCriteria: ''
        }

        @track caseDetails = {
            ParentObjectName: 'Case',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'Account.Name', 'Applicant__r.FullName__c','Applicant__r.PhoneNumber__c','Loan_Application__r.Name', 'caseNumber','CreatedDate','Property_Owner_s_as_per_Technical_Repo__c'],
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


    //
    @api get currentTabId() {
    return this._currentTabId;
    }
    
    @wire(getObjectInfo, { objectApiName: DEVIATION_OBJECT })
    objInfo;

    set currentTabId(value) {
    console.log('setting Id for app asset');    
    this._currentTabId='';
    this._currentTabId = value;
    this.setAttribute("currentTabId", value);

    this.fetchApplAsset(value);
    }

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
    @track hasDupliDev = false
    @track devDesrp;
    @track disbApprCheckbox;
    @track commentTemp;
    @track deviaLevel;
    @track valueDevOption;

    @track index
    @track uploadDoc = true;
    @track systDev = false

    @track
    sPDDApprConfig = {
        ParentObjectName: 'SPDD_Approval_Config__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'Emp__c', 'Emp__r.Name', 'Product__c', 'Sanction_Amt__c', 'PD_Amt__c', 'Role__c', 'Designation__c', 'Dev_Level__c'],
        childObjFields: [],
        queryCriteria: ''
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

    
    get disableMitigant(){
        return this.hasEditAccess === false || this.status !== 'Closed';
    }
    get disabled(){
        return this.hasEditAccess === false || this.status === 'Closed' || this.status === 'Cancelled' || this.userRole === 'LHM' ;
    }

    get disbaleHubManager(){
        return this.hasEditAccess === false || this.hubManagerReview === 'Legal Approved' || this.userRole !== 'LHM' || this.status !=='Closed';
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

     get showLegal(){
        return this.legal;
    }

    get showVetting(){
        return this.vetting;
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


    closeModal(event) {
        this.isModalOpen = false;
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
        return this.hasEditAccess === false || this.userRole === 'CPA' || this.status !== 'Closed';
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
        
        this.setDeviaParams();
        this.activeSection = ["A","B"];
        this.sunscribeToMessageChannel();
        this.fetchDeviationData();
    }


    handleteamHierIdChange() {
        let tempParams = this.teamHierParam;
        tempParams.queryCriteria = ' where Employee__c = \'' + this.currentUserId + '\' limit 1' ;
        this.teamHierParam = { ...tempParams };

    }

     @api
     fetchDeviationData() {
        console.log('fetching deviation data')
        getSobjectDataNonCacheable({ params: this.deviaParams })
            .then((data) => {
                console.log('data found=',data);
                this.wiredDataResult =  data.parentRecords ; // Store the result
                this.records1 =  [...data.parentRecords];
                let arrayTemp =[...data.parentRecords];
                
                if (this.deletedRecordId) {
                    this.records1 = arrayTemp.filter(record => record.Id !== this.deletedRecordId);
                } 
                this.processDeviationData(this.records1);
                return refreshApex(this.records1);

            })
            .catch((error) => {

                console.log('error found=',error);
                this.wiredDataResult = { error }; // Store the error
                console.log('error ', error);
                return refreshApex(this.records1);
            });

            
    }

    processDeviationData(data) {
        // Your existing logic to process the data 
        console.log('processDeviationData enter',data)
        this.recordsOfOldDev = [];
        this.existRecords = [];
        if (data !== undefined) {
            //this.oldrecords = [...this.records1, ...data];
            this.existRecords = data;
            this.records1 = [];
            if (this.existRecords !== undefined) {
                this.existRecords.forEach(dev => {
                    let disTemp=false;
                    this.myNewElement = {
                        Id: dev.Id,
                        Deviation__c: dev.Deviation__c || '',
                        RemarksForInternalLegal__c: dev.RemarksForInternalLegal__c || '',
                        Dev_DescrId__c: dev.Dev_DescrId__c || '',
                        Req_Apprv_Level__c: dev.Req_Apprv_Level__c || '',
                        Devia_Desrp__c: dev.Devia_Desrp__c || '',
                        Apprv_By__r: dev.Apprv_By__r || {},
                        Appr_Actn__c: dev.Appr_Actn__c || '',
                        Mitigation__c: dev.Mitigation__c || '',
                        Appr_Remarks__c: dev.Appr_Remarks__c || '',
                        Dev_Type__c: dev.Dev_Type__c || '',
                        Comments__c: dev.Comments__c || '',
                        DeviationMaster__c: dev.DeviationMaster__c || '',
                        Dev_DescrId__c: dev.DeviationMaster__c || '',
                        approvedby: false,
                        systDev: false,
                        manualDev: true,
                        delete: false,
                        disbComm: true,
                        isReqComments: false,
                        disAppStatus: dev.Appr_Actn__c === 'Approved',
                        disTemp : (dev.Appr_Actn__c === 'Approved')
                    };
                    if (dev.Apprv_By__c) {
                        this.myNewElement.Apprv_By__r.Name = dev.Apprv_By__r.Name;
                    }
                    if(disTemp){
                        this.myNewElement.disTemp = true;
                    }
                    this.recordsOfOldDev.push(this.myNewElement);
                    this.records1.push(this.myNewElement);
                });
            }
        }
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

         handleChangeDev(event) {
            if(event.detail.value === 'Yes'){
                this.valueDevOption = true;
            }
            else if(event.detail.value === 'No'){
                 this.valueDevOption = false;
            }
            
    }

 get optionsForDeviation() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

  

@wire(getSobjectData, { params: '$sPDDApprConfig' })
    sPDDApprConfigData(wiredSpddConfig) {
        const { data, error } = wiredSpddConfig;
        this._spddConfigData = wiredSpddConfig;

        if (data) {
            if (data.parentRecords) {
                this.userLevel = data.parentRecords[0].Dev_Level__c
                this.userName = data.parentRecords[0].Emp__r.Name

                //add this to get SPDD user id for LAK-7491 (case approver is showing wrong in cam report)
                this.spddUserId=data.parentRecords[0].Emp__c
                
                if (this.userLevel !== undefined) {
                    this.levelCompareOfDev();
                }
            }

        } else if (error) {
            console.log('error ', error);
        }
    }


    
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
        queryCriteria: ""
    };


    

    @wire(getSobjectDatawithRelatedRecords, { params: "$loanAppParams" })
    handleResponse(result) {
        const { data, error } = result;
        this._wiredLoanApplData = result;
        if (data) {
            if (data.parentRecord != undefined) {
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


    

    @wire(getSobjectData, { params: '$deviaParams' })
    wiredDeviationDataGet(result) {
        if (result.data) {
            console.log('data got again:',result)
          
        } else if (result.error) {
            console.error('Error:', result.error);
        }
    }



     setDeviaParams() {
        this.deviaParams = {
            ParentObjectName: 'Deviation__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'Name', 'LoanAppln__c','RemarksForInternalLegal__c', 'Applicant__c','DeviationMaster__r.Deviation_Category__c','DeviationMaster__c', 'BRE_Call_Iden__c', 'Dev_Type__c', 'Deviation__c', 'Apprv_By__c', 'Appr_Actn__c', 'Apprv_By__r.Name', 'Req_Apprv_Level__c', 'Devia_Desrp__c', 'Mitigation__c', 'Appr_Remarks__c', 'Dev_DescrId__c', 'Comments__c'],
            childObjFields: [],
            queryCriteria: `  WHERE DeviationMaster__r.Deviation_Category__c= 'Legal' and LoanAppln__c = '${this.loanAppId}'`
        };
       
    }

    
    

    levelCompareOfDev() {
        this.updatedRecordsOfOldDev = [];
        if (this.recordsOfOldDev) {
            for (let i = 0; i < this.recordsOfOldDev.length; i++) {
                if(!this.userLevel){
                    this.recordsOfOldDev[i].approvedby = true;
                }else{
                if (this.recordsOfOldDev[i].Req_Apprv_Level__c !== undefined && this.userLevel !== undefined) {
                    if (this.recordsOfOldDev[i].Req_Apprv_Level__c == "1" && (this.userLevel == "1" || this.userLevel == "2" ||
                        this.userLevel == "3" || this.userLevel == "4" || this.userLevel == "5" || this.userLevel == "6" || this.userLevel == "7")
                    ) {
                        this.recordsOfOldDev[i].approvedby = this.hasEditAccess == false ? true : false;
                        if (this.disbApprCheckbox == true) {
                            this.records1.forEach(rec => {
                                rec.approvedby = this.hasEditAccess == false ? true : true;
                            });
                        }
                    } else if (
                        this.recordsOfOldDev[i].Req_Apprv_Level__c == "2" &&
                        (this.userLevel == "2" ||
                            this.userLevel == "3" ||
                            this.userLevel == "4" ||
                            this.userLevel == "5" || this.userLevel == "6" || this.userLevel == "7")
                    ) {
                        this.recordsOfOldDev[i].approvedby = this.hasEditAccess == false ? true : false;
                        if (this.disbApprCheckbox == true) {
                            this.records1.forEach(rec => {
                                rec.approvedby = this.hasEditAccess == false ? true : true;
                            });
                        }
                    } else if (
                        this.recordsOfOldDev[i].Req_Apprv_Level__c == "3" &&
                        (this.userLevel == "3" ||
                            this.userLevel == "4" ||
                            this.userLevel == "5" || this.userLevel == "6" || this.userLevel == "7")
                    ) {
                        this.recordsOfOldDev[i].approvedby = this.hasEditAccess == false ? true : false;
                        if (this.disbApprCheckbox == true) {
                            this.records1.forEach(rec => {
                                rec.approvedby = this.hasEditAccess == false ? true : true;
                            });
                        }

                    } else if (this.recordsOfOldDev[i].Req_Apprv_Level__c == "4" && (this.userLevel == "4" ||
                        this.userLevel == "5" || this.userLevel == "6" || this.userLevel == "7")
                    ) {
                        this.recordsOfOldDev[i].approvedby = this.hasEditAccess == false ? true : false;
                        if (this.disbApprCheckbox == true) {
                            this.records1.forEach(rec => {
                                rec.approvedby = this.hasEditAccess == false ? true : true;
                            });
                        }
                    } else if (this.recordsOfOldDev[i].Req_Apprv_Level__c == "5" && (this.userLevel == "5" || this.userLevel == "6"
                        || this.userLevel == "7")
                    ) {
                        this.recordsOfOldDev[i].approvedby = this.hasEditAccess == false ? true : false;
                        if (this.disbApprCheckbox == true) {
                            this.records1.forEach(rec => {
                                rec.approvedby = this.hasEditAccess == false ? true : true;
                            });
                        }
                    } else if (this.recordsOfOldDev[i].Req_Apprv_Level__c == "6" && (this.userLevel == "6" || this.userLevel == "7")) {
                        this.recordsOfOldDev[i].approvedby = this.hasEditAccess == false ? true : false;
                        if (this.disbApprCheckbox == true) {
                            this.records1.forEach(rec => {
                                rec.approvedby = this.hasEditAccess == false ? true : true;
                            });
                        }
                    } else if (this.recordsOfOldDev[i].Req_Apprv_Level__c == "7" && (this.userLevel == "7")) {
                        this.recordsOfOldDev[i].approvedby = this.hasEditAccess == false ? true : false;
                        if (this.disbApprCheckbox == true) {
                            this.records1.forEach(rec => {
                                rec.approvedby = this.hasEditAccess == false ? true : true;
                            });
                        }
                    } else {
                        this.recordsOfOldDev[i].approvedby = this.hasEditAccess == false ? true : true

                        if (this.recordsOfOldDev[i].Req_Apprv_Level__c !== undefined) {
                            this.disbApprCheckbox = true
                            this.records1.forEach(rec => {
                                rec.approvedby = this.hasEditAccess == false ? true : true;
                            });
                        }
                    }
                }
            }
                if (this.recordsOfOldDev[i].Dev_Type__c === "System") {
                    this.recordsOfOldDev[i].delete = this.hasEditAccess == false ? true : true;
                    this.recordsOfOldDev[i].systDev = true;
                    this.recordsOfOldDev[i].manualDev = false

                }
                if (this.recordsOfOldDev[i].Devia_Desrp__c === "OTHER DEVIATIONS") {
                    this.commentTemp = true
                    this.recordsOfOldDev[i].disbComm = this.hasEditAccess == false ? true : false;
                    this.recordsOfOldDev[i].isReqComments = true
                }
                this.updatedRecordsOfOldDev.push(this.recordsOfOldDev[i]);
            }
        }
        this.records1 = [...this.updatedRecordsOfOldDev];
        const allRecordsApproved = this.existRecords.every(record => record.Appr_Actn__c === 'Approved');
        if (allRecordsApproved === true) {
            this.apprAll = true
        } else {
            this.apprAll = false
        }
        if (this.recordsOfOldDev.length === 0) {
            this.isAllDevAppr = false
        } else {
            this.isAllDevAppr = true
        }
    }


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
          'FinalStatusOfTSR__c','QueryRevert__c','HubManagerReview__c','TAT__c'],
          childObjFields: [],
          queryCriteria: "  "
        };

getCaseData(){
     getSobjectDataNonCacheable({params: this.caseData}).then((result) => {
        console.log("CASE Details RESULT #397:::", result);
        if(result.parentRecords[0] !== undefined){

            this.dateTimeInitiation= result.parentRecords[0].DateTimeInitiation__c;
            this.prodType = result.parentRecords[0].Product_Type__c ? result.parentRecords[0].Product_Type__c : '';
            this.isTitlClrNMar = result.parentRecords[0].IsTheTitleClearNdMarketable__c ? result.parentRecords[0].IsTheTitleClearNdMarketable__c :'' ;
            this.statusReport=result.parentRecords[0].ReportResult__c;
            this.reportDate = result.parentRecords[0].Date_of_Report__c
            this.tatReport = result.parentRecords[0].TAT__c;
            this.finRemark = result.parentRecords[0].Final_Remarks__c ? result.parentRecords[0].Final_Remarks__c :'' ;
            this.queryDes = result.parentRecords[0].Query_description__c ? result.parentRecords[0].Query_description__c :'' ;
            this.caseWrp.Final_Status_of_Field_Verification_by_un__c = result.parentRecords[0].Final_Status_of_Field_Verification_by_un__c ? result.parentRecords[0].Final_Status_of_Field_Verification_by_un__c :'' ;
             this.caseWrp.OverrideByFedFina__c = result.parentRecords[0].OverrideByFedFina__c ? result.parentRecords[0].OverrideByFedFina__c :false ;
             this.caseWrp.FinalStatusTSRReportFromHLM__c = result.parentRecords[0].FinalStatusTSRReportFromHLM__c ? result.parentRecords[0].FinalStatusTSRReportFromHLM__c :'' ;
             this.caseWrp.FinalStatusOfTSR__c= result.parentRecords[0].FinalStatusOfTSR__c ? result.parentRecords[0].FinalStatusOfTSR__c :'' ;
       
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
    handleStatusChange(event) {
    try {
        console.log('handleStatusChange:', event.detail);

        const index1 = event.target.dataset.index;
        const fieldName = event.target.dataset.name;
        const value = event.target.value;

        console.log('Index:', index1, 'Field Name:', fieldName, 'Value:', value);
        const index = parseInt(index1, 10);

        // Ensure records1 is defined and the index is within bounds
        if (this.records1 && this.records1[index] !== undefined) {
            console.log('records1[index] before update:', this.records1[index]);

            if (fieldName === 'Mitigation__c') {
                this.records1[index].Mitigation__c = value;
            } else if (fieldName === 'RemarksForInternalLegal__c') {
                this.records1[index].RemarksForInternalLegal__c = value;
            }

            console.log('records1[index] after update:', this.records1[index]);

            const allRec = new CustomEvent('getalldeviation', {
                detail: this.records1
            });

            console.log('before dispatch all:', this.records1);
            this.dispatchEvent(allRec);
            console.log('before dispatch all: DONE');
        } else {
            console.error(`Invalid index or records1 is undefined. Index: ${index}, Records1:`, this.records1);
        }
    } catch (error) {
        console.error('Error in handleStatusChange:', error);
    }
}





handleDelete(event) {
        const delRecId = event.target.dataset.id;

        if (delRecId) {
            this.handleDeleteRecId(delRecId);
        }
    }

    handleDeleteRecId(delRecId) {
        console.log('Enter handleDeleteRecId with id:', delRecId);
        
        deleteRecord(delRecId)
            .then(() => {
                this.deletedRecordId=delRecId;
                console.log('deleted id is::',this.deletedRecordId)
                console.log('Record deleted successfully');
                this.ShowToastMessage('Success', 'Record deleted successfully', 'success', 'sticky');
                this.isModalOpen = false;
                if (this.records1) {
                    this.records1 = this.records1.filter(record => {
                        return record.Id !== this.deletedRecordId;
                    });

                    console.log('Updated records after deletion:', this.records1);
                    this.deletedRecordId=undefined;
                }

                if (this.records1) {
                    console.log('Refreshing records:', this.records1);
                    return refreshApex(this.records1);
                    }
                this.fetchDeviationData();
                
            })
            .then(() => {
                return this.fetchDeviationData().then(() => {
                    if (this.records1) {
                        console.log('refreshing rec err ::', this.records1);
                        return refreshApex(this.records1);
                    }
                });

            })
            .catch((error) => {
                this.isModalOpen = false;
                console.error('Error deleting record:', error);
            });
    }




    @wire(getSobjectData,{params : '$teamHierParam'})
    teamHierHandler({data,error}){
        if(data){
            if(data.parentRecords !== undefined ){
                this.userRole = data.parentRecords[0].EmpRole__c
                console.log('DATA IN CASE DETAILS :::: #415>>>>',this.userRole);
            }
        }
        if(error){
            console.error('ERROR CASE DETAILS:::::::#420',error)
        }
    }




    @wire(getSobjectData,{params : '$caseDetails'})
    caseRecordHandler({data,error}){
        if(data){
            if(data.parentRecords !== undefined ){
           }
                      
        }
        if(error){
            console.error('ERROR CASE DETAILS:::::::#262',error)
        }
    }

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
                console.log('DATA IN CASE Query DETAILS #447 ::::>>>>',this.caseQryList);
             
            }}
        if(result.error){
            console.error('ERROR IN CASE DETAILS::::::# 282',result.error)
        }
    }

@wire(getSobjectData,{params : '$docDetParams'})
documentDetailHandler({data,error}){
    if(data){
        this.caseDocList = data.parentRecords;
      }
    if(error){
        console.error('ERROR CASE DETAILS:::::::#295',error);
    }
}

    @wire(getPicklistValuesByRecordType, {
        objectApiName: CASE_OBJECT,
        recordTypeId: '$legalRecordTypeId',
    })


    picklistHandler({ data, error }) {
        if (data) {   
            this.reportStatusOptions=[...this.generatePicklist(data.picklistFieldValues.ReportResult__c)]
            this.titleOptions =[...this.generatePicklist(data.picklistFieldValues.IsTheTitleClearNdMarketable__c)];
        }
        if (error) {
            console.error('ERROR CASE DETAILS:::::::#344',error)
        }
    }

    generatePicklist(data) {
        return data.values.map(item => ({ label: item.label, value: item.value }))
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    getObjectInfo({ error, data }) {
        if (data) {
            for (let key in data.recordTypeInfos) {
                let recordType = data.recordTypeInfos[key];
                console.log("recordType.value>>>>>", recordType.name);
                if (recordType.name === 'CPVFI') {
                    this.cpvRecordTypeId = key;
                } else if(recordType.name === 'TSR'){
                    this.tsrRecordTypeId=key;
                } else if(recordType.name === 'Vetting'){
                    this.vettingRecordTypeId=key;
                }else if(recordType.name == 'Legal'){
                    this.legalRecordTypeId = key;
                }
                console.log('data. record type id', key);
            }
        } else if (error) {
            console.error('ERROR CASE DETAILS:::::::#318', error);
        }
    }

    @wire(getSobjectData, { params: "$commentsQueryParams" })
    commentsQueryRecordHandler({ data, error }) {
      this.wiredDataCaseQry=data;
      if (data) {
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
        this.updateDeviationMasterId(event);
    }
    

    updateDeviationMasterId(event) {
    const index = event.target.dataset.index;

    console.log('called upd id master' +event.detail.id)
    if (this.records1 && this.records1[index]) {
        this.deviationMstrId = event.detail.id;
        this.records1[index].DeviationMaster__c = this.deviationMstrId;
    } else {
        console.error(`Invalid index or records1 is undefined. Index: ${index}, Records1: ${this.records1}`);
    }

    const allRec = new CustomEvent('getalldeviation', {
           detail : this.records1
        });
        console.log('before dispatch lookup=>',this.records1 )
        this.dispatchEvent(allRec);
        console.log('dispatchjed done')
    }

    
   @api refreshDocTable() {
    this.showSpinner = false;
    let child = this.template.querySelector('c-show-case-document');
    child.handleFilesUploaded();
    }

    @wire(getObjectInfo, { objectApiName: 'Case_Query__c' })
    objInfo1;


    @wire(getPicklistValuesByRecordType, {
      objectApiName: 'Case_Query__c',
      recordTypeId: '$objInfo1.data.defaultRecordTypeId',
    })


  dedupePicklistHandler({ data, error }) {
      if (data) {
       this.caseQrystatusOptions = [...this.generatePicklist(data.picklistFieldValues.Status__c)]
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

}}


handleValueChange(event) {
    try {
      let currentIndex = event.target.dataset.index;
      let obj = { ...this.caseQryList[event.target.dataset.index] };

      obj[event.target.dataset.fieldName] = event.target.value;
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

 compareDevLevel() {
        if (this.deviaLevel !== undefined && this.userLevel !== undefined) {
            if (this.deviaLevel == "1" && (this.userLevel == "1" || this.userLevel == "2" || this.userLevel == "3" ||
                this.userLevel == "4" || this.userLevel == "5" || this.userLevel == "6" || this.userLevel == "7")) {
                this.records1[this.index].approvedby = this.hasEditAccess == false ? true : false;
                if (this.disbApprCheckbox == true) {
                    this.records1.forEach(rec => {
                        console.log('this.hasEditAccess1',this.hasEditAccess);
                        rec.approvedby = this.hasEditAccess == false ? true : true;
                    });
                }
            } else if (this.deviaLevel == "2" && (this.userLevel == "2" || this.userLevel == "3" ||
                this.userLevel == "4" || this.userLevel == "5" || this.userLevel == "6" || this.userLevel == "7")) {
                this.records1[this.index].approvedby = this.hasEditAccess == false ? true : false;
                if (this.disbApprCheckbox == true) {
                    this.records1.forEach(rec => {
                        console.log('this.hasEditAccess2',this.hasEditAccess);
                        rec.approvedby = this.hasEditAccess == false ? true : true;
                    });
                }
            } else if (this.deviaLevel == "3" && (this.userLevel == "3" ||
                this.userLevel == "4" || this.userLevel == "5" || this.userLevel == "6" || this.userLevel == "7")) {
                this.records1[this.index].approvedby = this.hasEditAccess == false ? true : false;

                if (this.disbApprCheckbox == true) {
                    this.records1.forEach(rec => {
                        console.log('this.hasEditAccess3',this.hasEditAccess);
                        rec.approvedby = this.hasEditAccess == false ? true : true;
                    });
                }
            } else if (this.deviaLevel == "4" && (this.userLevel == "4" || this.userLevel == "5" || this.userLevel == "6"
                || this.userLevel == "7")) {
                this.records1[this.index].approvedby = this.hasEditAccess == false ? true : false;
                if (this.disbApprCheckbox == true) {
                    this.records1.forEach(rec => {
                        console.log('this.hasEditAccess4',this.hasEditAccess);
                        rec.approvedby = this.hasEditAccess == false ? true : true;
                    });
                }
            } else if (this.deviaLevel == "5" && (this.userLevel == "5" || this.userLevel == "6" || this.userLevel == "7")) {
                this.records1[this.index].approvedby = this.hasEditAccess == false ? true : false;
                if (this.disbApprCheckbox == true) {
                    this.records1.forEach(rec => {
                        console.log('this.hasEditAccess5',this.hasEditAccess);
                        rec.approvedby = this.hasEditAccess == false ? true : true;
                    });
                }
            } else if (this.deviaLevel == "6" && (this.userLevel == "6" || this.userLevel == "7")) {
                this.records1[this.index].approvedby = this.hasEditAccess == false ? true : false;
                if (this.disbApprCheckbox == true) {
                    this.records1.forEach(rec => {
                        console.log('this.hasEditAccess6',this.hasEditAccess);
                        rec.approvedby = this.hasEditAccess == false ? true : true;
                    });
                }
            } else if (this.deviaLevel == "7" && this.userLevel == "7") {
                this.records1[this.index].approvedby = this.hasEditAccess == false ? true : false;
                if (this.disbApprCheckbox == true) {
                    this.records1.forEach(rec => {
                        console.log('this.hasEditAccess7',this.hasEditAccess);
                        rec.approvedby = this.hasEditAccess == false ? true : true;
                    });
                }
            } else {
                this.records1[this.index].approvedby = this.hasEditAccess == false ? true : true
                this.disbApprCheckbox = true
                this.records1.forEach(rec => {
                    rec.approvedby = this.hasEditAccess == false ? true : true;
                });
            }
        }
    }

checkDuplicateDeviation() {
        const deviationSet = []
        for (let i = 0; i < this.records1.length; i++) {
            var commeField = this.records1[i];
            const deviationValue = commeField.Deviation__c;

            if (deviationSet.includes(deviationValue)) {
                this.hasDupliDev = true
            }
            deviationSet.push(deviationValue);
        }
         if (this.hasDupliDev == true) {
            this.ShowToastMessage('Error', this.customLabel.Deviation_Duplicate_records1, 'error', 'sticky')
        }
    }


handleRemoveRecord(event) {
    console.log('id is delete is out:',+this.deleteRecId);
        if (this.deleteRecId) {
            if (this.deleteRecId.length == 18) {
                console.log('id is delete is in:',+this.deleteRecId);
                this.handleDeleteRecId(this.deleteRecId);
            }
        } else {
            this.records.splice(this.deleteIndex, 1);
            this.isModalOpen = false;
        }
    }


    handleDeleteAction(event) {
        this.isModalOpen = true;
        this.deleteRecId = event.target.dataset.id;
        this.deleteIndex = event.target.dataset.index
    }



handleSaveCaseQuery(){
  if(this.caseQryList && this.caseQryList.length>0){
        this.caseQryList.forEach(item=>{
          delete  item.disableCaseQry;
        })
         console.log('THIS CASEQRYLIST::::::655',JSON.stringify(this.caseQryList));
        upsertMultipleRecord({ params: this.caseQryList })
        .then((result) => {
          this.ShowToastMessage('Success',this.label.CaseQueryUpdateSuccess,'success','dismissable')
            refreshApex(this.wiredCaseData);
            refreshApex(this.wiredDataCaseQry);
    
        })
        .catch((error) => {
        console.log('ERROR CASE DETAILS:::::::#432', error);
        });
  }}

handleSaveThroughLms(values) {
   this.handleSave(values.validateBeforeSave);
}

@track selectedRec;
@track docArr = [];

handleRowSelected(event) {
    const selectedRows = event.detail.selectedRows;
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
    const fields = {};
    fields[CASE_FIELD.fieldApiName] = this._recordId;
    this.docArr.forEach(item=>{
        fields[DOC_DET_FIELD.fieldApiName] = item;
        const recordInput = { apiName: CASE_DOC_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(result => {
                this.ShowToastMessage('Success',this.label.CaseDocCreateSuccess,'success','sticky')
                   
            })
            .catch(error => {
                console.log('CASE DOCUMENT RESULT ERRO:::::510',error);
        
            });
    })}


  draftValues = [];

  async handleSaveDataTable(event) {
    const records = event.detail.draftValues.slice().map((draftValue) => {
      const fields = Object.assign({}, draftValue);
      return { fields };
    });
        this.draftValues = [];

    try {
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
            console.log("Error photo and report count 992", JSON.stringify(result));
              this.photoCount = result.parentRecords[0] && result.parentRecords[0].PhotoCount__c ? result.parentRecords[0].PhotoCount__c : 0;
              this.reportCount = result.parentRecords[0] && result.parentRecords[0].ReportCount__c ? result.parentRecords[0].ReportCount__c: 0;
        
            this.isInputCorrect = this.validateForm();
            if (this.isInputCorrect === true) {
                if(this.legal === true || this.vetting === true){
                    if(this.userRole ==='LHM'){
                        this.caseWrp.Status = 'Closed';
                        this.caseWrp.HubManagerReview__c= 'Legal Approved';
                        this.updateRec();
                        this.handleSaveCaseQuery();
                    }else{
                        this.caseWrp.Status = 'Closed';
                        this.caseWrp.HubManagerReview__c= 'Legal Review';
                        this.updateRec();
                        this.handleSaveCaseQuery();
                    }
                 
                }else{
                    if((this.status !== 'Cancelled' || this.status !== 'Closed') && this.caseWrp.OverrideByFedFina__c === true){
                        if(this.legal=== true  && this.caseWrp.Final_Status_of_Field_Verification_by_un__c !== ''){
                            this.caseWrp.Status = 'Closed';
                            this.updateRec();
                          
                      }else{
                    this.caseWrp.Status = 'Closed';
                    this.updateRec();
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
    if(this.userRole !== 'LHM'){
    
    if(this.status === 'New' || this.status === 'Review Requested' || this.status === 'Query' || this.status === 'Query Resolved' ){
        if((this.reportCount === undefined || this.reportCount < 1  )  && (this.photoCount === undefined || this.photoCount < 1  )  ){
            isValid=false
            this.ShowToastMessage('Error',this.label.CaseDetailsReportPhotoError,'error','sticky')
        }
        else if(this.reportCount == null || this.reportCount < 1){
            isValid=false
            this.ShowToastMessage('Error',this.label.CaseDetailsReportError,'error','sticky')
        }else if(this.photoCount == null || this.photoCount < 1){
            isValid=false
            this.ShowToastMessage('Error',this.label.CaseDetailsPhotoError,'error','sticky')
        }else if(this.technical === true && this.photoCount <= 5){
            isValid=false
            this.ShowToastMessage('Error',this.label.CaseDetailsTechPhotoError,'error','sticky')
        }else if(this.cpvfi === true && this.photoCount <= 3){
            isValid=false
            this.ShowToastMessage('Error',this.label.CaseDetailsCpvfiPhotoError,'error','sticky')  
        }
       
}
  
}

    this.template.querySelectorAll('lightning-input').forEach(element => {
        if(element.reportValidity()){
        }else{
            isValid = false;
            this.ShowToastMessage('Error',this.label.CaseDetailsRequiredFieldError,'error','sticky')  
        }


    });
    this.template.querySelectorAll('lightning-combobox').forEach(element => {
        if(element.reportValidity()){
            
        }else{
            isValid = false;
            this.ShowToastMessage('Error',this.label.CaseDetailsRequiredFieldError,'error','sticky')
        }

    });

    this.template.querySelectorAll('lightning-textarea').forEach(element => {
        if(element.reportValidity()){
            
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
    
    this.caseWrp['Id'] = this.caseId;
    console.log(" this.caseWrp['Id']", JSON.stringify(this.caseWrp));

    const fields = this.caseWrp;

        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                const selectedEvent = new CustomEvent("select", {
                    detail: true
                  });
                    this.dispatchEvent(selectedEvent);
                    this.getCaseData();
                    this.showSpinner = false;
                this.ShowToastMessage('Success',this.label.CaseSaveSuccess,'success','sticky')
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log(" INSIDE UPDATE RECORD ERROR>>>", error, error.body.message);
                this.ShowToastMessage('Error',this.label.CaseQueryRequiredFieldError,'error','sticky')
                
            });
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

ShowToastMessage(title,message,variant,mode){
    const evt = new ShowToastEvent({
        title,
        message,
        variant,
        mode 
    });
    this.dispatchEvent(evt);
}
@track npmIsActive = true

//deviation start
 get filCondnDevDesrp() {
    console.log('product:'+this.prodType)
        // if (this.prodType === "Home Loan") {
        //     return (" Deviation_Category__c = 'Legal' AND LWDD_NPM_Prod__c=" + "'" + this.prodType + "'" + " AND IsActive__c=" + this.npmIsActive);
        // } else if (this.prodType === "Small Ticket LAP") {
        //     return (" Deviation_Category__c = 'Legal' AND LWDD_NPM_Prod__c=" + "'" + this.prodType + "'" + " AND IsActive__c=" + this.npmIsActive);
        // }else{
           
        // }
         return (" Deviation_Category__c = 'Legal' ");

    }


handleValueSelect1(event) {
        this.lookupRec = event.detail;
        console.log('hello=>',this.lookupRec.id)
        this.deviationMstrId = this.lookupRec.id;


        console.log('hello main=>',this.lookupRec.mainField)
        if (event.target.fieldName === 'Devia_Desrp__c') {
            this.hasDupliDev = false
            this.index = event.target.index
            this.records1[this.index].Devia_Desrp__c = this.lookupRec.mainField;
            this.records1[this.index].Dev_DescrId__c = this.lookupRec.id;
            this.records1[this.index].masterId = this.lookupRec.id;
            this.devDesrp = this.lookupRec.mainField;
            const updatedrecords1 = [...this.records1];
            if (this.devDesrp === null) {
                this.disbApprCheckbox = false
                this.records1[this.index].approvedby = false
                this.records1[this.index].Deviation__c = ''
                this.records1[this.index].Req_Apprv_Level__c = ''
            }
            if (this.lookupRec.mainField === 'OTHER DEVIATIONS') {
                this.commentTemp = true
            }
            if (this.lookupRec.mainField !== 'OTHER DEVIATIONS') {
                this.commentTemp = false
            }

            for (let i = 0; i < this.records1.length; i++) {
                var commeField = this.records1[i];
                if (commeField.Devia_Desrp__c === 'OTHER DEVIATIONS') {
                    this.commentTemp = true
                    this.records1[i].disbComm = false
                    commeField.isReqComments = true
                } else {
                    this.records1[i].disbComm = true
                    commeField.isReqComments = false
                }
            }
            let legaltemp='Legal';
            let productType = 'Home Loan'
            this.deviaMasParam.queryCriteria = ' where Deviation_Category__c =\''+legaltemp+'\' AND LWDD_Devi_Desc__c = \'' + this.devDesrp + '\''
            console.log('query build:',this.deviaMasParam);
            getSobjectData({ params: this.deviaMasParam }).then((result) => {
                if (result) {
                    if (result.parentrecords1) {
                        let DevData = result.parentrecords1;
                        this.deviaLevel = DevData[0].LWDD_Prio_N__c;
                        this.records1[this.index].Req_Apprv_Level__c = DevData[0].LWDD_Prio_N__c;
                        this.records1[this.index].Deviation__c = DevData[0].LWDD_Dev_DTL_Id__c;
                        this.checkDuplicateDeviation();
                        this.compareDevLevel();
                    }
                } else if (error) {
                    console.error('Error', error)
                }
            });

        }
        this.updateDeviationMasterId(event);
        }

    

     addRow() {
        this.numberOfRec = this.records1.length + 1;
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
            approvedby: true,
            systDev: false,
            manualDev: true,
            delete: false,
            isReqComments: false
        };
        let deviaDa = [...this.records1, myNewElement];
        this.records1 = deviaDa;
        this.isAllDevAppr = true
        this.apprAll = false
    }


     handleDeleteRow(event) {
        const index = event.target.dataset.index;
        this.records1.splice(index, 1); // Remove 1 element at index
        this.records1 = [...this.records1]; // Ensure reactivity
    }
//deviation end

}