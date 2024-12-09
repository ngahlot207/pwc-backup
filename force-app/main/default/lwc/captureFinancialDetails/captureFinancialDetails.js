import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue, createRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import Applicant_Financial_Object from "@salesforce/schema/Applicant_Financial__c";
import Applicant_GST_Object from "@salesforce/schema/ApplGST__c";
import ITR_INC_DOC_FIELD from '@salesforce/schema/Applicant_Financial__c.Income_Documents__c';
import GST_INC_DOC_FIELD from '@salesforce/schema/ApplGST__c.Income_Documents__c';
import getGSTINValue from '@salesforce/apex/FinancialFileUploadClass.getGSTINValue';
import getRelatedFilesByRecordIdWire from '@salesforce/apex/FinancialFileUploadClass.getRelatedFilesByRecordIdWire';
import getFinancialDocumentDetails from '@salesforce/apex/FinancialFileUploadClass.getFinancialDocumentDetails';
import getRelatedFilesFinancialByRecordIdWire from '@salesforce/apex/FinancialFileUploadClass.getRelatedFilesFinancialByRecordIdWire';
import getUiTheme from "@salesforce/apex/UiThemeController.getUiTheme";
import getVisualforceDomain from "@salesforce/apex/DomainNameProvider.getVisualforceDomain";
import getLightningHostname from "@salesforce/apex/DomainNameProvider.getLightningHostname";
import PicklistController from '@salesforce/apex/FinancialFileUploadClass.getPicklistValues';
import deleteDocRecord from '@salesforce/apex/DocumentDetailController.deleteDocDetWithCdl';
import UploadDocDisply_Del_SuccessMessage from '@salesforce/label/c.UploadDocDisply_Del_SuccessMessage';
import processDefunctRecordsFinancial from '@salesforce/apex/FinancialRecordProcessor.processDefunctRecordsFinancial';
import createDocumentDetail from "@salesforce/apex/DocumentDetailController.createDocDetailwithApplicantAsset";
//Appl GST
import getAllSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords';

import { CPARoles } from 'c/globalConstant';

//Integration Message Obj Fields Refernces\
import INTEGRATION_MSG_OBJECT from "@salesforce/schema/IntgMsg__c";
import REFERENCE_ID_FIELD from "@salesforce/schema/IntgMsg__c.RefId__c";
import REFERENCE_OBJ_API_FIELD from "@salesforce/schema/IntgMsg__c.RefObj__c";
import INTEGRATION_MSG_NAME_FIELD from "@salesforce/schema/IntgMsg__c.Name";
import BU_FIELD from "@salesforce/schema/IntgMsg__c.BU__c";
import SERVICE_NAME_FIELD from "@salesforce/schema/IntgMsg__c.Svc__c";
import API_VENDOR__NAME_FIELD from "@salesforce/schema/IntgMsg__c.ApiVendor__c";
import IS_ACTIVE_FIELD from "@salesforce/schema/IntgMsg__c.IsActive__c";
import STATUS_FIELD from "@salesforce/schema/IntgMsg__c.Status__c";
import RESPONSE_PAYLOAD_FIELD from "@salesforce/schema/IntgMsg__c.Resp__c";
import API_STATUS_FIELD from "@salesforce/schema/IntgMsg__c.APIStatus__c";


//Message channel section
import { publish, subscribe, unsubscribe, createMessageContext, releaseMessageContext } from 'lightning/messageService';

//LMS details
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import CURRENT_USER_ID from "@salesforce/user/Id";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';

// Custom Labels
import Financial_DocName_ErrorMessage from '@salesforce/label/c.Financial_DocName_ErrorMessage';
import Financial_DocType_ErrorMessage from '@salesforce/label/c.Financial_DocType_ErrorMessage';
import Financial_SelFile_ErrorMessage from '@salesforce/label/c.Financial_SelFile_ErrorMessage';
import Financial_DocDetail_ErrorMessage from '@salesforce/label/c.Financial_DocDetail_ErrorMessage';
import Financial_Uploading_ErrorMessage from '@salesforce/label/c.Financial_Uploading_ErrorMessage';
import Financial_Filesize_ErrorMessage from '@salesforce/label/c.Financial_Filesize_ErrorMessage';

import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';

const APPLICANTFIELDS = ['Applicant__c.CustProfile__c', 'Applicant__c.Type_of_Borrower__c', 'Applicant__c.Constitution__c', 
                            'Applicant__c.LatestyearforwhichITRisavailable__c','Applicant__c.Provisional_Financials_Available__c',
                            'Applicant__c.Provisional_Financials_Year__c','Applicant__c.ApplType__c', 'Applicant__c.AssessmentProgram__c'];
const LOANAPPFIELDS = ['LoanAppl__c.AssesIncomeAppl__c', 'LoanAppl__c.CreatedDate', 'LoanAppl__c.LoginAcceptDate__c', 'LoanAppl__c.Stage__c'];


export default class CaptureFinancialDetails extends NavigationMixin(LightningElement) {

    customLabel = {
        Financial_DocName_ErrorMessage,
        Financial_DocType_ErrorMessage,
        Financial_SelFile_ErrorMessage,
        Financial_DocDetail_ErrorMessage,
        Financial_Uploading_ErrorMessage,
        Financial_Filesize_ErrorMessage,
        UploadDocDisply_Del_SuccessMessage
    };

    @api loanAppId;
    //@api applicantIdOnTabset;
    @api hasEditAccess;
    @api layoutSize;
    @api objectApiName;
    showGSTFields;
    stageVal;
    @api dateFile;
    @api obj = {};
    @track _applicantIdOnTabset;

    @api get applicantIdOnTabset() {
        return this._applicantIdOnTabset;
    }
    set applicantIdOnTabset(value) {
        this._applicantIdOnTabset = value;
        this.setAttribute("applicantIdOnTabset", value);
        let tempParams = this.financialParams;
        tempParams.queryCriteria = 'WHERE Loan_Applicant__c=\'' + this.applicantIdOnTabset + '\'' + 'AND RecordType.name=\'' + this.financialRecName + '\'' + 'AND IsLatest__c = true';
        this.financialParams = { ...tempParams };

        let tempParams1 = this.parametersAppGST;
        tempParams1.queryCriteria = ' where Applicant__c = \'' + this.applicantIdOnTabset + '\'';
        this.parametersAppGST = { ...tempParams1 };

    }
    
    @track itrDocTypevalue;
    gstinValue = false;
    gstinValues = [];
    gstPicklistValue;
    gstTextFieldValue;
    objectInfo;
    assesIncomeVal;
    showITR = false;
    showGST = false;
    custProfile;
    borrower;
    constitution;
    uploadOptionValue = '';
    uploadOptions =
        [
            { label: 'Upload ePDF', value: 'Upload ePDF' },
            { label: 'Upload Scan Docs', value: 'Upload Scan Docs' },
        ];

    @track documentTypeOptions = [{ label: 'Financials - P&L and BL', value: 'Financials - P&L and BL' }];
    @track documentTypeValue = 'Financials - P&L and BL';
    @track documentNameOptions = [
        { label: 'Latest year Financials - P&L and BS', value: 'Latest year Financials - P&L and BS' },
        { label: 'Previous year Financials - P&L and BS', value: 'Previous year Financials - P&L and BS' },
        { label: 'Provisional Financials - P&L and BS', value: 'Provisional Financials - P&L and BS' }
    ];

    @track documentNameValue;
    @track incomeValue = '';
    showModal = false;
    popupHeaderName;
    @track showITRincDoc = true;
    showGSTincDoc = false;
    gstPicklistOptions = [];
    @track disableFetchITR = false;
    disableUploadOptions;
    @track disableFetchGST = false;
    deleteIconDisabled;
    isFileUploadDisable = true;
    subscription = null;
    context = createMessageContext();
    @track wiredDataApplicant;
    @track wiredDataAppGST;
    @track wiredDataApplication;
    @track themeType;
    @track vfUrl;
    @track vfUrlFinancial;
    @track lightningDomainName;
    @track documentDetailId;
    @track showSpinner = false;
    @track fileData;
    @track removeModalMessage = "Do you really want to delete this file";
    @track isEligibleToView = false;
    @track filesList = [];
    @track validGST;
    @track helpText;
    @track showHelpText = false;
    @track cdlIdToDelete;
    @track docIdToDelete;
    @track isDeleteModalOpen = false;
    @track wiredFileData;
    picklistValues = [];
    @track latestYearOptionValue;
    @track showLatestYearSelectionOption = false;
    @track provisionalFinancialSelection;
    @track provisionalFinancialOptions =[{label: 'Yes', value:'Yes'}, {label:'No', value:'No'}];
    @track IsPassReqOptions =[{label: 'Yes', value:'Yes'}, {label:'No', value:'No'}];
    @track convertToSingleImage = false;

    @track userTeamRoleData;
    @track fileDataFinancial;

    @wire(getObjectInfo, { objectApiName: Applicant_Financial_Object })
    objectInfoAppFin;

    @wire(getObjectInfo, { objectApiName: Applicant_GST_Object })
    objectInfoAppGST;

    @wire(getPicklistValues, { recordTypeId: '$objectInfoAppFin.data.defaultRecordTypeId', fieldApiName: ITR_INC_DOC_FIELD })
    ITRIncomePicklistValues;

    @wire(getPicklistValues, { recordTypeId: '$objectInfoAppGST.data.defaultRecordTypeId', fieldApiName: GST_INC_DOC_FIELD })
    GSTIncomePicklistValues;

    @track
    parameterforTeam = {
        ParentObjectName: 'TeamHierarchy__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'EmpRole__c '],
        childObjFields: [],
        queryCriteria: 'WHERE Employee__c=\'' + CURRENT_USER_ID + '\'' + 'ORDER BY LastModifiedDate DESC'
    }


    @wire(getSobjectData, { params: '$parameterforTeam' })
    handleResponseTeamHierarchy(wiredResultTeam) {
        let { error, data } = wiredResultTeam;
        if (data) {
            if (data.parentRecords.length > 0) {
                let userTeamRole = data.parentRecords[0].EmpRole__c;
                if (userTeamRole) {
                    this.userTeamRoleData = userTeamRole;
                    this.processApplicantData();
                }
            }
        } else if (error) {
            console.error('Error ------------->', error);
        }
    }

    @track applicationDate;

    @wire(getRecord, { recordId: '$loanAppId', fields: LOANAPPFIELDS })
    loanData(wiredResultApplication) {
        let { error, data } = wiredResultApplication;
        this.wiredDataApplication = wiredResultApplication;
        if (error) {
            console.error('Error fetching loan data:', error);
        } else if (data) {
            this.assesIncomeVal = getFieldValue(data, 'LoanAppl__c.AssesIncomeAppl__c');
            this.applicationDate = getFieldValue(data, 'LoanAppl__c.CreatedDate');
                this.dateFile = getFieldValue(data, 'LoanAppl__c.LoginAcceptDate__c');
            this.stageVal = getFieldValue(data, 'LoanAppl__c.Stage__c');
            this.processApplicantData();
        }
    }

    @track isApplicant = false;
    @track applicntType;
    @track assesmentIncomeProgram;
    @track  appBrowPreLang;
    appliData
    @wire(getRecord, { recordId: '$applicantIdOnTabset', fields: APPLICANTFIELDS })
    applicantData(wiredResultApplicant) {
        let { error, data } = wiredResultApplicant;
        this.wiredDataApplicant = wiredResultApplicant;
        this.appliData={}
        if (error) {
            console.error('Error fetching applicant data:', error);
        } else if (data) {
            this.appliData=data
            this.borrower = data.fields.Type_of_Borrower__c.value;
            this.custProfile = data.fields.CustProfile__c.value;
            this.constitution = data.fields.Constitution__c.value;
            this.latestYearOptionValue = data.fields.LatestyearforwhichITRisavailable__c.value ? (data.fields.LatestyearforwhichITRisavailable__c.value) : null;
            this.provisionalFinancialSelection = data.fields.Provisional_Financials_Available__c.value ? data.fields.Provisional_Financials_Available__c.value : undefined; 
            this.provisionalFinancialYearSelectionValue = data.fields.Provisional_Financials_Year__c.value ? data.fields.Provisional_Financials_Year__c.value : undefined; 
            this.applicntType = data.fields.ApplType__c.value ? data.fields.ApplType__c.value : undefined; 
            this.assesmentIncomeProgram = data.fields.AssessmentProgram__c.value ? data.fields.AssessmentProgram__c.value : undefined; 
            this.processITRPicklistOptions();
            this.processApplicantData();
        }
    }


    gstRegisteredEmployments = 0;
    @wire(getRelatedListRecords, {
        parentRecordId: '$applicantIdOnTabset',
        relatedListId: 'Applicant_Employments__r',
        fields: ['Id', 'GST_Registered__c'],
        where: '{GST_Registered__c : {eq : "Yes"}}'
    })
    applicantEmploymentDetails(wiredEmploymentResult) {
        let { error, data } = wiredEmploymentResult;
        if (data) {
            this.gstRegisteredEmployments = data.count;
            this.processApplicantData();
        }
        else if (error) {
            console.error('Error fetching employment data:', error);
        }
    }

    @wire(getGSTINValue, { applicantId: '$applicantIdOnTabset' })
    wiredapplicantDataGST(wiredResultAppGST) {
        let { error, data } = wiredResultAppGST;
        this.wiredDataAppGST = wiredResultAppGST;
        if (data) {
            this.gstinValues = data;
            if (this.gstinValues.length > 0) {
                this.gstinValues.forEach((obj) => {
                    // Access the GSTIN property of each object and push it into the array
                    this.gstPicklistOptions.push({ label: obj.GSTIN__c, value: obj.Id });
                });
                this.gstinValue = true;
            } else {
                this.gstinValue = false;
            }
        }
    }

    @track showBalanceSheet = false;
    @track showProfitAndLoss = false;
    @track showFinancialRatio = false;

    processApplicantData() {
        
        if(this.custProfile && this.constitution && this.borrower && this.gstRegisteredEmployments && this.gstRegisteredEmployments > 0 && this.custProfile == 'SELF EMPLOYED PROFESSIONAL' && this.borrower == 'Financial') {
            this.showGST = true;
        }else if (this.custProfile && this.constitution && this.borrower  && this.gstRegisteredEmployments && this.gstRegisteredEmployments > 0 && this.custProfile == 'SELF EMPLOYED NON PROFESSIONAL' && this.borrower == 'Financial') {
            this.showGST = true;
        }else {
            this.showGST = false;
        }
        if (this.applicntType && this.applicntType === 'P') {
            this.isApplicant = true;
        }
        if(this.stageVal && this.stageVal !== 'QDE'){
                      this.showGSTFields = true;
                    }
                    else{
                     this.showGSTFields = false;
                    }
                    setTimeout(() => {
                        this.performTabVisibilityHandler();
                    }, 1000);
        
    }

    
    processITRPicklistOptions(){
        this.picklistValues = [];
        if (this.custProfile && this.constitution && (this.custProfile == 'SELF EMPLOYED PROFESSIONAL' || this.custProfile == 'SELF EMPLOYED NON PROFESSIONAL') 
            && this.constitution === 'INDIVIDUAL') 
        {
            this.picklistValues.push({ label: 'Latest year ITR & computation', value: 'Latest year ITR & computation' });
            this.picklistValues.push({ label: 'Previous year ITR & computation', value: 'Previous year ITR & computation' });
        }

        if (this.custProfile && this.constitution && this.borrower && (this.custProfile == 'SELF EMPLOYED PROFESSIONAL' || this.custProfile == 'SELF EMPLOYED NON PROFESSIONAL') 
            && this.constitution != 'INDIVIDUAL' && this.borrower === 'Financial') 
        {
            this.picklistValues.push({ label: 'Latest year ITR & computation', value: 'Latest year ITR & computation' });
            this.picklistValues.push({ label: 'Previous year ITR & computation', value: 'Previous year ITR & computation' });
        }

        if (this.custProfile && this.constitution && this.assesmentIncomeProgram && (this.custProfile == 'SALARIED') 
            && this.constitution === 'INDIVIDUAL' && this.assesmentIncomeProgram != 'Assessed Income Program') 
        {
            this.picklistValues.push({ label: 'Latest Year Form 16', value: 'Latest Year Form 16' });
            this.picklistValues.push({ label: 'Latest year ITR & computation', value: 'Latest year ITR & computation' });
            this.picklistValues.push({ label: 'Previous year ITR & computation', value: 'Previous year ITR & computation' });
        }
    }


    @track financialDocUploadVisibility = false;

    performTabVisibilityHandler() {
        this.showLatestYearSelectionOption = true;
        if (this.latestYearOptionValue && this.latestYearOptionValue != 'ITR Not Available' && this.stageVal && this.stageVal !== 'QDE') {
            this.financialDocUploadVisibility = true;
            this.showFinancialRatio=true;
        } else {
            if(this.stageVal == 'QDE' && this.latestYearOptionValue != 'ITR Not Available'){
                this.financialDocUploadVisibility = true;
            }else{
                this.financialDocUploadVisibility = false;
                this.showFinancialRatio=false;
            }
           // 
        }

        if (this.latestYearOptionValue && this.latestYearOptionValue != 'ITR Not Available') {
            if (this.custProfile && this.borrower && this.custProfile === 'SELF EMPLOYED PROFESSIONAL' && this.borrower === 'Financial') {
                this.showITR = true;
            } else if (this.custProfile && this.borrower && this.custProfile == 'SELF EMPLOYED NON PROFESSIONAL' && this.borrower == 'Financial') {
                this.showITR = true;
            }
            else {
                this.showITR = false;
            }
        } else {
            this.showITR = false;
        }
        
        //LAK-9244
        if (this.userTeamRoleData && ( this.userTeamRoleData === 'UW' || ((CPARoles && CPARoles.includes(this.userTeamRoleData)))
        || this.userTeamRoleData === 'RCM' || this.userTeamRoleData === 'ZCM'|| this.userTeamRoleData === 'NCM' || this.userTeamRoleData === 'CH'
        || this.userTeamRoleData === 'ACM' || this.userTeamRoleData === 'CBO')) {
            if (this.latestYearOptionValue && this.latestYearOptionValue != 'ITR Not Available') {
                if (this.custProfile && this.borrower && this.custProfile === 'SELF EMPLOYED PROFESSIONAL' && this.borrower === 'Financial') {
                    this.showBalanceSheet = true;
                    this.showProfitAndLoss = true;
                } else if (this.custProfile && this.borrower && this.custProfile == 'SELF EMPLOYED NON PROFESSIONAL' && this.borrower == 'Financial') {
                    this.showBalanceSheet = true;
                    this.showProfitAndLoss = true;                    
                }else {
                    this.showBalanceSheet = false;
                    this.showProfitAndLoss = false;
                }
            } else {
                this.showBalanceSheet = false;
                this.showProfitAndLoss = false;
            }
        }


        if(this.custProfile && this.borrower && this.custProfile === 'SELF EMPLOYED PROFESSIONAL' && this.borrower === 'Financial'){
            this.showLatestYearSelectionOption=true;
        }else if(this.custProfile && this.borrower && this.custProfile == 'SELF EMPLOYED NON PROFESSIONAL' && this.borrower == 'Financial'){
            this.showLatestYearSelectionOption=true;
        }else{
            this.showLatestYearSelectionOption=false;
        }


        if (this.borrower && this.borrower === 'Non Financial') {
            this.isEligibleToView = false;
            this.showLatestYearSelectionOption=false;
        }else if (this.showITR === false && this.showGST === false && this.showBalanceSheet === false && this.showProfitAndLoss === false) {
            this.isEligibleToView = false;
            //this.showLatestYearSelectionOption=false;
        } else {
            this.isEligibleToView = true;
        }
        
    }

    get latestYearITROptions() {
        const currentDate = this.applicationDate ? new Date(this.applicationDate) : new Date();
        const currentMonth = currentDate.getMonth(); // Months are zero-based (0 = January, 11 = December)
        const currentYear = currentDate.getFullYear();

        const selectOptions = [];

        const previousYear = currentYear - 1;
        const previousYearMinusOne = previousYear - 1;

        if (currentMonth >= 4) {
            selectOptions.push({ label: `FY ${previousYearMinusOne}-${previousYear}`, value: `${previousYearMinusOne}-${previousYear}` });
            selectOptions.push({ label: `FY ${previousYear}-${currentYear}`, value: `${previousYear}-${currentYear}` });
            selectOptions.push({ label: 'ITR Not Available', value: 'ITR Not Available' });
        } else {
            selectOptions.push({ label: `FY${previousYearMinusOne}-${previousYear}`, value: `${previousYearMinusOne}-${previousYear}` });
            selectOptions.push({ label: 'ITR Not Available', value: 'ITR Not Available' });
        }

        return selectOptions;
    }

  
    inputChangeHandler(event) {
        if (event.detail.value) {
            this.latestYearOptionValue = event.detail.value;
            this.provisionalFinancialSelection = undefined;
            this.provisionalFinancialYearSelectionValue = undefined;
            this.performTabVisibilityHandler();
        }

    }

    inputChangeHandlerProvisional(event){
        if (event.detail.value) {
            this.provisionalFinancialSelection = event.detail.value;
        }

        if(this.provisionalFinancialSelection && this.provisionalFinancialSelection === 'No'){
            this.provisionalFinancialYearSelectionValue = undefined;
        }
    }
    //LAK-9890 -START
    documentId;
    showUploadModal = false;
    handleFileUpload(event) {
        this.documentId = event.currentTarget.dataset.documentid;
        this.showUploadModal = true;
    }
    closeUploadModal() {
        this.showUploadModal = false;
    }

    handleUploadFinished(event) {
        this.showUploadModal = false;
        
        //this.handleFilesUploaded("uf");
    }
    //LAK-9890 -END


    @wire(getRelatedFilesByRecordIdWire, { loanAppId: '$loanAppId', applicantId: '$applicantIdOnTabset', isITRTab: '$showITRincDoc',docDetIdITR:'$otherDocDetailId'})
    wiredResult(wiredResultFile) {
        let { error, data } = wiredResultFile;
        this.wiredFileData = wiredResultFile;
        if (data) {
            let tempFiles = [];
            console.log('data files: ',JSON.stringify(data))
            tempFiles = data.map(file => ({
                ContentDocumentId: file.cDId,
                ContentDocumentLinkId: file.cdlId,
                ContentVersionId: file.cvId,
                docId: file.docId,
                incomeDocumentType: file.incomeDocumentType,
                fileType: file.fileType,
                fileExtension: file.fileExtension,
                LinkedEntityId: file.LinkedEntityId,
                CreatedDate: this.dateFormat(file.cDcrtdDate),
                FileAvailable:file.FileAvalbl,
                isAvailableInFileDisabled: (file.cDId || this.hasEditAccess == false) ? true: false
            }));
            this.filesList = [...tempFiles];

            if(this.filesList && this.filesList.length>0){
                var docDetailMap = [];
                for(var i=0; i<this.filesList.length; i++){
                    docDetailMap.push({key: this.filesList[i].incomeDocumentType, value: this.filesList[i].docId});
                }

                if(this.showITRincDoc && this.showITRincDoc === true){
                    this.formulatedocDetailMappingITRMap(docDetailMap);
                }
                if(this.showGSTincDoc && this.showGSTincDoc === true){
                    this.formulatedocDetailMappingGSTMap(docDetailMap);
                }
            }else{
                if(this.showITRincDoc && this.showITRincDoc === true){
                    this.formulatedocDetailMappingITRMap(null);
                }
                if(this.showGSTincDoc && this.showGSTincDoc === true){
                    this.formulatedocDetailMappingGSTMap(null);
                }
            }
        } else {
            this.filesList = [];
        }
    }


    ///LAK-8843
        getFinancialPLBLFiles(){
        this.fileDataFinancial= [];
        getFinancialDocumentDetails( { loanAppId: this.loanAppId, applicantId: this.applicantIdOnTabset})
        .then((result) => {
            this.fileDataFinancial = result;
            console.log('File fileDataFinancial: ',JSON.stringify(this.fileDataFinancial))
            if((!this.fileDataFinancial || this.fileDataFinancial.length === 0) && this.showLatestYearSelectionOption === true){
            this.showToastMessage('Atleast One Document is required for Financials - P&L and BL :(Latest year Financials - P&L and BS, Previous year Financials - P&L and BS, Provisional Financials - P&L and BS)', '', 'error', 'sticky');
            console.log('Atleast One Document is required for Financials - P&L and BL :(Latest year Financials - P&L and BS, Previous year Financials - P&L and BS, Provisional Financials - P&L and BS)')
        }
        })
        .catch((error) => {
            console.log('Error in getRelatedFilesByRecordIdWire: ',JSON.stringify(error))
        });

        }
 

    @track wiredFileDataFin;
    @track filesListFinancial = [];


    @wire(getRelatedFilesFinancialByRecordIdWire, { loanAppId: '$loanAppId', applicantId: '$applicantIdOnTabset', docDetailId: '$docmntDetId' })
    wiredResultFin(wiredResultFileFin) {
        let { error, data } = wiredResultFileFin;
        this.wiredFileDataFin = wiredResultFileFin;
        if (data) {
            let tempFilesFin = [];
            tempFilesFin = data.map(file => ({
                ContentDocumentId: file.cDId,
                ContentDocumentLinkId: file.cdlId,
                ContentVersionId: file.cvId,
                docId: file.docId,
                incomeDocumentType: file.incomeDocumentType,
                fileType: file.fileType,
                fileExtension: file.fileExtension,
                incomeDocumentName: 'Financials - P&L and BL',
                LinkedEntityId: file.LinkedEntityId,
                CreatedDate: this.dateFormat(file.cDcrtdDate),
                FileAvailable:file.FileAvalbl,
                isAvailableInFileDisabled: (file.cDId || this.hasEditAccess == false) ? true: false
            }));
            this.filesListFinancial = [...tempFilesFin];
            if(this.filesListFinancial && this.filesListFinancial.length>0){
                var docDetailMap = [];
                for(var i=0; i<this.filesListFinancial.length; i++){
                    docDetailMap.push({key: this.filesListFinancial[i].incomeDocumentType, value: this.filesListFinancial[i].docId});
                }
                this.formulatedocDetailMappingFinMap(docDetailMap);
            }else{
                this.formulatedocDetailMappingFinMap(null);
            }
            
        } else {
            this.filesListFinancial = [];
        }
    }

    dateFormat(DateValue){
        
        const [day, month, year] = DateValue.split('-');
        const monthAbbreviation = new Date(Date.parse(`${month}/01/2000`)).toLocaleString('en-us', { month: 'short' });
        const formattedDate = `${day}-${monthAbbreviation}-${year}`;
        console.log(formattedDate);
        return formattedDate;
    }

    
    get showFinancialDocUploadSection() {
        if (this.documentNameValue) {  
            if(this.isDocPassProtected === 'Yes')   {
                if(this.documentPassword  && this.documentPassword != '') {
                    return true;
                }else{
                    return false;
                }         
            }else if(this.isDocPassProtected === 'No'){
                return true;
            }
           
        } else {       
            return false;
        }
    }


    @track activetab;
    @track showFileSection = false;
    @track currentTabName;

    handleActiveTab(event) {
        this.currentTabName = '';
        this.showFileSection = false;
        this.showITRDocUpload = false;
        this.showGSTDocUpload = false;
        
        if(event.target.label){
            this.currentTabName = event.target.label;
        }
        if (event.target.label == 'ITR') {
            this.showITRincDoc = true;
            this.showGSTincDoc = false;
            this.showFileSection = true;
            this.showSpinner = true;
            this.showPasswordFieldITR = false;
            refreshApex(this.wiredFileData);
            refreshApex(this.wiredFileDataFin);
            this.showSpinner = false;
            this.activetab = 'ITR';
        }
        else if (event.target.label == 'GST') {
            this.showITRincDoc = false;
            this.showGSTincDoc = true;
            this.showFileSection = true;
            this.showSpinner = true;
            this.showPasswordFieldITR = false;
            refreshApex(this.wiredFileData);
            refreshApex(this.wiredFileDataFin);
            this.showSpinner = false;
            this.activetab = 'GST';
        }
        else if (event.target.label == 'Balance Sheet') {
            console.log('balance sheet active')
            this.activetab = 'Balance Sheet';
            this.showFileSection = false;
            refreshApex(this.wiredFileDataFin);
            if(this.template.querySelector('c-capture-balance-sheet-details') != null){
                           
                this.template.querySelector('c-capture-balance-sheet-details').handleRefreshAllData();
            }
            

        }
        else if (event.target.label == 'Profit & Loss') {
            this.activetab = 'Profit & Loss';
            this.showFileSection = false;
            refreshApex(this.wiredFileDataFin);
            if(this.template.querySelector('c-capture-profit-and-loss-details') != null){
                this.template.querySelector('c-capture-profit-and-loss-details').handleRefreshAllData();
            }
        }
        else if(event.target.label == 'Consolidated Profit & Loss'){
            this.activetab = 'Consolidated Profit & Loss';
            
            if(this.template.querySelector('c-show-consolidate-profitand-loss-data') != null){
                this.template.querySelector('c-show-consolidate-profitand-loss-data').handleRefreshAllData();
            }
        }
        else if(event.target.label == 'Consolidated Balance Sheet'){
            this.activetab = 'Consolidated Balance Sheet';
            
        }
        else if(event.target.label == 'Financial Ratio'){
            this.activetab = 'Financial Ratio';
        }
    }


    connectedCallback() {
        if (this.hasEditAccess === false) {
            this.disableFetchITR = true;
            this.disableMode = true;
            this.disableUploadOptions = true;
            this.disableFetchGST = true;
            this.deleteIconDisabled = true;
            this.disableFileUpload = true;
            this.disableDocumentUpload = true;
            this.disableITRDocumentUpload=true;
            this.disableGSTDocumentUpload = true;
            this.disableAvialbleInFileFin = true;
            this.disableAvialbleInFileITR = true;
            this.disableAvialbleInFileGST = true;
        }

        this.scribeToMessageChannel();
        this.getUIThemeDetails();

        getVisualforceDomain({}).then((result) => {
            this.vfUrl = result;
            this.vfUrlFinancial = result;
        });

        getLightningHostname({}).then((result) => {
            this.lightningDomainName = result;
        });
        this.showSpinner = true;
        refreshApex(this.wiredFileData);
        refreshApex(this.wiredFileDataFin);
        this.showSpinner = false;
    }

    getUIThemeDetails() {
        getUiTheme()
            .then((result) => {
                this.themeType = result;
            })
            .catch((error) => {
            });
    }

    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.context,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }


    handleSaveThroughLms(values) {
        if (values.tabId && values.tabId === this.applicantIdOnTabset) {
            this.handleSave(values.validateBeforeSave, false);
        }
    }

    handleSave(validate, isFileUploadCondition) {
        
        let isMissingDocumentType = false;
        var applicantDataSObject = {};
        let tempRecs = [];
        if(this.documentList.length>0)
        {
            this.upsertApplicantRecord(this.documentList, 'Document');
        }
        if (validate) {
            //LAK-8843
            if(this.latestYearOptionValue && this.latestYearOptionValue != 'ITR Not Available'){
                this.getFinancialPLBLFiles();
                }
            console.log('filesList: ',JSON.stringify(this.filesList));
                ///LAK-6111
                if(this.showGST && this.activetab === 'GST' && this.stageVal !== 'QDE'){
                console.log('parent captureFinancialGST inside validateForm');
                let isValid = this.template.querySelector('c-capture-financial-g-s-t-details').validateForm();
                console.log('isValid isValid-->' + JSON.stringify(isValid));
                if (isValid === false) {
                    console.log('inside false-->' + JSON.stringify(isValid));
                    return;
                } else if (isValid && isValid === true) {
                    console.log('isValid isValid True-->' + JSON.stringify(isValid));
                    this.template.querySelector('c-capture-financial-g-s-t-details').handleUpsert(validate);
                }
            }
                ///LAK-6111
            if (!this.latestYearOptionValue) {
                var validateComponent1 = this.validateDataForm();
                if(!validateComponent1){
                    this.showToastMessage('Please fill all required fields.', '', 'error', 'sticky');
                    return;
                }
            } else {
                if(this.latestYearOptionValue && this.latestYearOptionValue != 'ITR Not Available'){
                    var validateComponent = this.validateDataForm();
                    if(!validateComponent){
                        this.showToastMessage('Please fill all required fields.', '', 'error', 'sticky');
                        return;
                    }else{
                        if (this.showBalanceSheet && this.activetab == 'Balance Sheet') {
                            let isValid = this.template.querySelector('c-capture-balance-sheet-details').validateForm();
                            if (isValid && isValid === false) {
                                return;
                            } else if (isValid && isValid === true) {
                                this.template.querySelector('c-capture-balance-sheet-details').handleUpsert(validate);
                            }
                        } else if (this.showITR && this.activetab == 'ITR') {
                            const documentTypes = []; 
                            for(let item of this.filesList) {
                                documentTypes.push(item.incomeDocumentType);
                            }
                            console.log('documentTypes: ',JSON.stringify(documentTypes));
                            console.log('filesList: ',JSON.stringify(this.filesList));

                            if (this.showITRincDoc) {
                                if (this.custProfile && this.constitution && (this.custProfile == 'SELF EMPLOYED PROFESSIONAL' || this.custProfile == 'SELF EMPLOYED NON PROFESSIONAL') 
                                    && this.constitution === 'INDIVIDUAL') 
                                {
                                    if(this.assesmentIncomeProgram != 'Assessed Income Program'){
                                        if (!documentTypes.includes('Latest year ITR & computation') && !documentTypes.includes('Previous year ITR & computation')) {
                                            this.showToastMessage('Please upload Latest year ITR & computation and Previous year ITR & computation documents.', '', 'error', 'sticky');
                                            return;
                                        }
                                        if (!documentTypes.includes('Previous year ITR & computation')) {
                                            this.showToastMessage('Please upload Previous year ITR & computation document.', '', 'error', 'sticky');
                                            return;
                                        }
                                        if (!documentTypes.includes('Latest year ITR & computation')) {
                                            this.showToastMessage('Please upload Latest year ITR & computation document.', '', 'error', 'sticky');
                                            return;
                                        }
                                    }
                                }

                                if (this.custProfile && this.constitution && this.borrower && (this.custProfile == 'SELF EMPLOYED PROFESSIONAL' || this.custProfile == 'SELF EMPLOYED NON PROFESSIONAL') 
                                    && this.constitution != 'INDIVIDUAL' && this.borrower === 'Financial') 
                                {
                                    if(this.assesmentIncomeProgram != 'Assessed Income Program'){
                                        if (!documentTypes.includes('Latest year ITR & computation') && !documentTypes.includes('Previous year ITR & computation')) {
                                            this.showToastMessage('Please upload Latest year ITR & computation and Previous year ITR & computation documents.', '', 'error', 'sticky');
                                            return;
                                        }
                                        if (!documentTypes.includes('Previous year ITR & computation')) {
                                            this.showToastMessage('Please upload Previous year ITR & computation document.', '', 'error', 'sticky');
                                            return;
                                        }
                                        if (!documentTypes.includes('Latest year ITR & computation')) {
                                            this.showToastMessage('Please upload Latest year ITR & computation document.', '', 'error', 'sticky');
                                            return;
                                        }
                                    }
                                }
                            }
                            applicantDataSObject = {};
                            tempRecs = [];
                            applicantDataSObject.sobjectType = 'Applicant__c';
                            applicantDataSObject.LatestyearforwhichITRisavailable__c = this.latestYearOptionValue;
                            applicantDataSObject.Provisional_Financials_Available__c = this.provisionalFinancialSelection ? this.provisionalFinancialSelection : null;
                            applicantDataSObject.Provisional_Financials_Year__c = this.provisionalFinancialYearSelectionValue ? this.provisionalFinancialYearSelectionValue : '';
                            applicantDataSObject.Id = this.applicantIdOnTabset;
                            tempRecs.push(applicantDataSObject);
                            this.showSpinner = true;
                            this.upsertApplicantRecord(tempRecs, null);
                            if(this.latestYearOptionValue){
                                this.deleteAdditionalRecords(this.latestYearOptionValue, this.provisionalFinancialSelection, this.provisionalFinancialYearSelectionValue);
                            }
                        } else if (this.showProfitAndLoss && this.activetab == 'Profit & Loss') {
                            let isValid = this.template.querySelector('c-capture-profit-and-loss-details').validateForm();
                            if (isValid && isValid === false) {
                                return;
                            } else if (isValid && isValid === true) {
                                this.template.querySelector('c-capture-profit-and-loss-details').handleUpsert();
                            }
                        }else if(this.showGST && this.activetab === 'GST'){
                            applicantDataSObject = {};
                            tempRecs = [];
                            applicantDataSObject.sobjectType = 'Applicant__c';
                            applicantDataSObject.LatestyearforwhichITRisavailable__c = this.latestYearOptionValue ? this.latestYearOptionValue : '';
                            applicantDataSObject.Provisional_Financials_Available__c = this.provisionalFinancialSelection ? this.provisionalFinancialSelection : null;
                            applicantDataSObject.Provisional_Financials_Year__c = this.provisionalFinancialYearSelectionValue ? this.provisionalFinancialYearSelectionValue : '';
                            applicantDataSObject.Id = this.applicantIdOnTabset;
                            
                            tempRecs.push(applicantDataSObject);
                            this.showSpinner = true;
                            this.upsertApplicantRecord(tempRecs, null);
                            if(this.latestYearOptionValue){
                                this.deleteAdditionalRecords(this.latestYearOptionValue, this.provisionalFinancialSelection, this.provisionalFinancialYearSelectionValue);
                            }
                        }
                    }
                }else if ((this.latestYearOptionValue && this.latestYearOptionValue === 'ITR Not Available') || (this.showGST && this.activetab === 'GST')) {
                    applicantDataSObject = {};
                    tempRecs = [];
                    applicantDataSObject.sobjectType = 'Applicant__c';
                    applicantDataSObject.LatestyearforwhichITRisavailable__c = this.latestYearOptionValue;
                    applicantDataSObject.Provisional_Financials_Available__c = this.provisionalFinancialSelection ? this.provisionalFinancialSelection : null;
                    applicantDataSObject.Provisional_Financials_Year__c = this.provisionalFinancialYearSelectionValue ? this.provisionalFinancialYearSelectionValue : '';
                    applicantDataSObject.Id = this.applicantIdOnTabset;
                    tempRecs.push(applicantDataSObject);
                    this.showSpinner = true;
                    this.upsertApplicantRecord(tempRecs, null);
                    if(this.latestYearOptionValue){
                        this.deleteAdditionalRecords(this.latestYearOptionValue, this.provisionalFinancialSelection, this.provisionalFinancialYearSelectionValue);
                    }
                }
            }
            this.documentNameValue = undefined;
            this.incomeValue = undefined;
            this.gstDocTypevalue = undefined;
        } else {
            ///LAK-6111
            console.log('parent captureFinancialGST inside validateForm');
            console.log('this.showGST && this.activetab ===',this.showGST ,this.activetab);
            if (this.showGST && this.activetab === 'GST' && this.stageVal !== 'QDE') {
                this.template.querySelector('c-capture-financial-g-s-t-details').handleUpsert(validate);
            }
            ///LAK-6111
            if (this.showBalanceSheet && this.activetab == 'Balance Sheet') {
                //Fire the api method for handlesave in the child balance sheet component
                this.template.querySelector('c-capture-balance-sheet-details').handleUpsert(validate);
            } else if (this.showProfitAndLoss && this.activetab == 'Profit & Loss') {
                //Fire the api method for handlesave in the child balance sheet component
                this.template.querySelector('c-capture-profit-and-loss-details').handleUpsert();
            } else {
                applicantDataSObject = {};
                tempRecs = [];
                applicantDataSObject.sobjectType = 'Applicant__c';
                applicantDataSObject.LatestyearforwhichITRisavailable__c = this.latestYearOptionValue ? this.latestYearOptionValue : '';
                applicantDataSObject.Provisional_Financials_Available__c = this.provisionalFinancialSelection ? this.provisionalFinancialSelection : null;
                applicantDataSObject.Provisional_Financials_Year__c = this.provisionalFinancialYearSelectionValue ? this.provisionalFinancialYearSelectionValue : '';
                applicantDataSObject.Id = this.applicantIdOnTabset;
                tempRecs.push(applicantDataSObject);
                this.showSpinner = true;
                this.upsertApplicantRecord(tempRecs, null);
                if(this.latestYearOptionValue){
                    this.deleteAdditionalRecords(this.latestYearOptionValue, this.provisionalFinancialSelection, this.provisionalFinancialYearSelectionValue);
                }
            }
            this.documentNameValue = undefined;
            this.incomeValue = undefined;
            this.gstDocTypevalue = undefined;
        }
      
          
    }


    deleteAdditionalRecords(currentFinYear, provisonalAvailable, provisionalYear){
        if(currentFinYear){
            const [startYear, endYear] = this.latestYearOptionValue.split('-');
            const startYearNum = parseInt(startYear);
            const endYearNum = parseInt(endYear);
            const previousStartYear = startYearNum - 1;
            const previousEndYear = endYearNum - 1;
            var previousFinYear = `${previousStartYear}-${previousEndYear}`;

            if(this.activetab !== 'GST'){
            processDefunctRecordsFinancial({ previousFinYear: previousFinYear, currentFinYear: currentFinYear, provisionalAvailable : provisonalAvailable, provisionalYear : provisionalYear, applicantId: this.applicantIdOnTabset})
            .then(result => {
                this.showSpinner = false;
            }).catch(error => {
                this.showSpinner = false;
            })
        }
        }
    }

    validateDataForm(){
        const isInputCorrect1 = [
            ...this.template.querySelectorAll("lightning-input"),
            ...this.template.querySelectorAll("lightning-combobox")
        ].reduce((validSoFar, inputField) => {

            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        return isInputCorrect1;
        
    }

    upsertApplicantRecord(applicantData, isDocument) {
        if (applicantData && applicantData.length > 0) {
            var upsertdataRecords = [...applicantData];
            upsertMultipleRecord({ params: upsertdataRecords })
                .then(result => {
                    this.showSpinner = false;
                    if(!isDocument){
                        refreshApex(this.wiredDataApplicant);
                    }
                    refreshApex(this.wiredFileDataFin);
                    console.log('Inside upsertApplicantRecord' + JSON.stringify(result));
                    this.showToastMessage('Details saved successfully.', '', 'success', 'sticky');
                }).catch(error => {
                    console.log('error ==>>>' + JSON.stringify(error));
                    this.showSpinner = false;
                    this.showToastMessage('Unexpected error occurred. Please try again.', '', 'error', 'sticky');
                })
        } else {
            this.showSpinner = false;
        }

    }

    handlePicklistChange(event) {
        this.gstPicklistValue = event.detail.value;
        if (this.showGSTincDoc) {
            if (this.incomeValue && this.gstPicklistValue) {
                this.isFileUploadDisable = false;
            } else {
                this.isFileUploadDisable = true;
            }
        }
    }

    handleTextFieldChange(event) {
        this.gstTextFieldValue = event.target.value;
        this.validGST = this.validateGST(this.gstTextFieldValue);
        if (this.showGSTincDoc) {
            if (this.incomeValue && this.validGST) {
                this.isFileUploadDisable = false;
            } else {
                this.isFileUploadDisable = true;
            }
        }
        if (this.validGST === false) {
            this.template.querySelector("lightning-input[data-id=gstTextInput]").setCustomValidity('Please enter a valid GSTIN');
            this.template.querySelector("lightning-input[data-id=gstTextInput]").reportValidity();
            return;
        } else if (this.validGST === true) {
            this.template.querySelector("lightning-input[data-id=gstTextInput]").setCustomValidity('');
            this.template.querySelector("lightning-input[data-id=gstTextInput]").reportValidity()
        }
    }

    openModal() {
        this.showModal = true;
        if (this.showGSTincDoc) {
            if (this.incomeValue && (this.gstPicklistValue || this.validGST)) {
                this.isFileUploadDisable = false;
            } else {
                this.isFileUploadDisable = true;
            }
        }
        if (this.showITRincDoc) {
            if (this.incomeValue) {
                this.isFileUploadDisable = false;
            } else {
                this.isFileUploadDisable = true;
            }
        }
    }

    closeModal() {
        this.showModal = false;
        this.uploadOptionValue = '';
        this.gstTextFieldValue = '';
        this.incomeValue = '';
        this.helpText = undefined;
        refreshApex(this.wiredDataApplication);
        refreshApex(this.wiredDataApplicant);
        refreshApex(this.wiredDataAppGST);
        refreshApex(this.wiredFileData);
    }

    handleITROnChange(event) {
        this.uploadOptionValue = event.detail.value;
        if (this.uploadOptionValue === 'Upload ePDF' || this.uploadOptionValue === 'Upload Scan Docs') {
            this.popupHeaderName = 'Manual ITR Upload';
            this.openModal();
            this.showITRDocUpload = false;
            this.showGSTDocUpload = false;
        }
    }

    @track gstDocTypevalue;
    handleDocumentsTypeChange(event) {
        this.helpText = undefined;
        this.incomeValue = event.detail.value;
        this.showGSTDocUpload = false;
        this.showITRDocUpload = false;
        this.availableInFileITR = false;
        this.disableAvialbleInFileITR = true;
        this.availableInFileGST = false;
        this.disableAvialbleInFileGST = true;

        if (this.showGSTincDoc) {
            if (this.incomeValue && (this.gstPicklistValue || this.validGST)) {
                // this.showGSTDocUpload = true;
                this.showITRDocUpload = false;
                this.isDocPassProtectedITR = undefined;
            }
            if (this.incomeValue) {
                this.selectedDocDetailIdGST = undefined;
                var matchingDocDetailId;
                if(this.docDetailMappingGSTMap && this.docDetailMappingGSTMap.length >0){
                    matchingDocDetailId = this.docDetailMappingGSTMap.find(item => item.key === this.incomeValue);
                }
                if(matchingDocDetailId && matchingDocDetailId.value){
                    this.selectedDocDetailIdGST = matchingDocDetailId.value;
                }else{
                    this.selectedDocDetailIdGST = undefined;
                }

                if (this.incomeValue === 'Latest Year Audit report along with schedules') {
                    this.helpText = 'Mandatory if business turnover is greater than ₹1 crores';
                    this.gstDocTypevalue = 'Financials - P&L and BL';
                } else if (this.incomeValue === 'Previous Year Audit report along with schedules') {
                    this.helpText = 'Mandatory if business turnover is greater than ₹1 crores';
                    this.gstDocTypevalue = 'Financials - P&L and BL';
                } else if (this.incomeValue === 'Latest year Financials - P&L and BS') {
                    this.helpText = 'Mandatory for all except those filed under presumptive income i.e. 44 AD/AE/ADA cases';
                    this.gstDocTypevalue = 'Financials - P&L and BL';
                } else if (this.incomeValue === 'Previous year Financials - P&L and BS') {
                    this.helpText = 'Mandatory for all except those filed under presumptive income i.e. 44 AD/AE/ADA cases';
                    this.gstDocTypevalue = 'Financials - P&L and BL';
                }else if (this.incomeValue === 'GST returns for last 12 months') {
                    this.helpText = 'Mandatory for all except those filed under presumptive income i.e. 44 AD/AE/ADA cases';
                    this.gstDocTypevalue = 'GST Returns';
                }if (this.incomeValue === 'Provisional Financials - P&L and BS') {
                    this.helpText = 'Mandatory for all except those filed under presumptive income i.e. 44 AD/AE/ADA cases';
                    this.gstDocTypevalue = 'Financials - P&L and BL';
                }

                const matchingRecordGST = this.filesList.find(record => record.incomeDocumentType === this.incomeValue);
                if (matchingRecordGST) {
                    this.availableInFileGST = matchingRecordGST.FileAvailable;
                    this.disableAvialbleInFileGST = matchingRecordGST.isAvailableInFileDisabled;
                    if(this.availableInFileGST === true){
                        this.disableAvialbleInFileGST = true;
                    }
                }else{
                    this.availableInFileGST = false;
                    this.disableAvialbleInFileGST = false;
                }
            }   
        } else if (this.showITRincDoc) {
            if(this.incomeValue){
                this.isDocPassProtectedITR = undefined;
                this.selectedDocDetailIdITR = undefined;
                var matchingDocDetailId;
                if(this.docDetailMappingITRMap && this.docDetailMappingITRMap.length >0){
                    matchingDocDetailId = this.docDetailMappingITRMap.find(item => item.key === this.incomeValue);
                }
                if(matchingDocDetailId && matchingDocDetailId.value){
                    this.selectedDocDetailIdITR = matchingDocDetailId.value;
                }else{
                    this.selectedDocDetailIdITR = undefined;
                }
                 
                // this.showITRDocUpload = true;    
                this.showGSTDocUpload = false;
                if (this.incomeValue  == 'Latest Year Form 16') {
                    this.itrDocTypevalue='Income Documents';
                }else if(this.incomeValue  == 'Latest year ITR & computation'){
                    this.itrDocTypevalue='Income Tax Returns';
                }else if(this.incomeValue  == 'Previous year ITR & computation'){
                    this.itrDocTypevalue='Income Tax Returns';
                }

                const matchingRecordITR = this.filesList.find(record => record.incomeDocumentType === this.incomeValue);
                if (matchingRecordITR) {
                    this.availableInFileITR = matchingRecordITR.FileAvailable;
                    this.disableAvialbleInFileITR = matchingRecordITR.isAvailableInFileDisabled;
                    if(this.availableInFileITR === true){
                        this.disableAvialbleInFileITR = true;
                    }
                }else{
                    this.availableInFileITR = false;
                    this.disableAvialbleInFileITR = false;
                }
            }
        }
    }

    handleAvailableChangeITR(event){
        if(event.target.checked === true){
            this.showSpinner = true;
            if(this.selectedDocDetailIdITR){
                this.upsertMatchingDocumentDetailRecord(this.selectedDocDetailIdITR, 'ITRsection');
            }else{
                this.createMatchingDocumentDetailRecord(this.financialDocCategory, this.itrDocTypevalue, this.incomeValue, true, 'ITRsection');
            }
        }
    }

    handleAvailableChangeGST(){
        if(event.target.checked === true){
            this.showSpinner = true;
            if(this.selectedDocDetailIdGST){
                this.upsertMatchingDocumentDetailRecord(this.selectedDocDetailIdGST, 'GSTsection');
            }else{
                this.createMatchingDocumentDetailRecord(this.financialDocCategory, this.gstDocTypevalue, this.incomeValue, true, 'GSTsection');
            }
        }
    }


    handleGSTOnChange(event) {
        console.log('handleGSTOnChange: ', event.detail.value)
        this.uploadOptionValue = event.detail.value;
        console.log('handleGSTOnChange: ', this.uploadOptionValue)
        if (this.uploadOptionValue === 'Upload ePDF' || this.uploadOptionValue === 'Upload Scan Docs') {
            console.log('inside handleGSTOnChange: ', this.uploadOptionValue)
            this.popupHeaderName = 'Manual GST Upload';
            this.openModal();
            this.showGSTDocUpload = false;
        }
    }

    handleCancelPopUp() {
        this.uploadOptionValue = '';
        this.incomeValue = '';
        this.isFileUploadDisable = true;
        this.showModal = false;
        this.showGSTDocUpload = false;
        this.showITRDocUpload = false;
    }

    showToastMessage(title, message, variant, mode) {
        const evt = new ShowToastEvent({ title, message, variant, mode });
        this.dispatchEvent(evt);
    }


    @track showModalForFilePre = false;
    @track hasDocumentId = false;
    @track documentDetailIdPreview;


    handleDocumentViewPreview(event){
        var documentIdPreview = event.currentTarget.dataset.documentid;
        this.documentDetailIdPreview = documentIdPreview;
        this.hasDocumentId = true;
        this.showModalForFilePre = true;
    }


    handleCloseModalEvent(event) {
        this.showModalForFilePre = false;
    }

    @track parentSection;

    handleDocumentDelete(event) {
        this.parentSection = '';
        this.docIdToDelete = event.currentTarget.dataset.documentid;
        this.cdlIdToDelete = event.currentTarget.dataset.cdlid;
        this.parentSection = event.currentTarget.dataset.parentsection;
        this.isDeleteModalOpen = true;
    }

    closeModalDelete() {
        this.isDeleteModalOpen = false;
    }

    handleRemoveRecord(event) {
        this.showSpinner = true;
        this.deleteDocDet(this.docIdToDelete);
        this.isDeleteModalOpen = false;
    }

    deleteDocDet(docIdToDelete) {
        if(docIdToDelete){
            deleteDocRecord({ docDtlId: docIdToDelete })
            .then((result) => {
                this.showToastMessage(this.customLabel.UploadDocDisply_Del_SuccessMessage, '','success' ,"sticky");
                if(this.parentSection && this.parentSection === 'ITR'){
                    this.otherDocDetailId = '';
                    this.docDetailMappingITRMap = [];
                    refreshApex(this.wiredFileData);
                }else if(this.parentSection && this.parentSection === 'Financial'){
                    this.docmntDetId = '';
                    this.docDetailMappingFinMap = [];
                    this.docDetailMappingGSTMap = [];
                    refreshApex(this.wiredFileDataFin);
                    refreshApex(this.wiredFileData);
                }else if(this.parentSection && this.parentSection === 'GST'){
                    this.otherDocDetailId = '';
                    this.docDetailMappingGSTMap = [];
                    this.docDetailMappingFinMap = [];
                    refreshApex(this.wiredFileData);
                    refreshApex(this.wiredFileDataFin);
                }               
                this.showSpinner = false;
                this.isDeleteModalOpen = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                this.isDeleteModalOpen = false;
                this.showToastMessage('Unexpected error occurred. Please try again!! ', '','error' ,"sticky");
            });
        }else{
            this.showSpinner = false;
            this.isDeleteModalOpen = false;
        }
    }


    renderedCallback() {
       // refreshApex(this.wiredDataApplication);
        //refreshApex(this.wiredDataApplicant);
        refreshApex(this.wiredDataAppGST);
        refreshApex(this.wiredFileData);
        refreshApex(this.wiredFileDataFin);
    }

    validateGST(gstNumber) {
        var pattern = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/;
        if (!pattern.test(gstNumber)) {
            return false;
        }
        return true;
    }


    @track
    recordTypeparameter = {
        ParentObjectName: 'RecordType  ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'DeveloperName', 'SobjectType'],
        childObjFields: [],
        queryCriteria: 'where SobjectType=\'' + 'Applicant_Financial__c' + '\''
    }

    @track ProfitLossRecordTypeId;
    @wire(getSobjectData, { params: '$recordTypeparameter' })
    handleRecordType(wiredResult) {
        let { error, data } = wiredResult;
        if (data) {
            // console.error('data recordtypes------------->', JSON.stringify(data));
            for (let i = 0; i < data.parentRecords.length; i++) {
                if (data.parentRecords[i].DeveloperName == 'Profit_Loss') {
                    this.ProfitLossRecordTypeId = data.parentRecords[i].Id;
                }
            }
        } else if (error) {
            console.error('Error ------------->', error);
        }
    }

    handleParentUpdate(event) {
        
        if (event.detail) {
           
            refreshApex(this.wiredDataApplicant);
        }
    }

    @track helpTextFinancialDoc;

    documentNameChangeHandler(event) {
        this.documentNameValue = event.target.value;
        this.availableInFileFin = false;
        this.disableAvialbleInFileFin = true;
        this.selectedDocDetailIdFinancial = undefined;
        if (this.documentNameValue) {
           
            this.disableFileUpload = false;
            var matchingDocDetailId;
            if(this.docDetailMappingFinMap && this.docDetailMappingFinMap.length >0){
                matchingDocDetailId = this.docDetailMappingFinMap.find(item => item.key === this.documentNameValue);
            }
            if(matchingDocDetailId && matchingDocDetailId.value){
                this.selectedDocDetailIdFinancial = matchingDocDetailId.value;
            }else{
                this.selectedDocDetailIdFinancial = undefined;
            }

            if (this.documentNameValue === 'Latest year Financials - P&L and BS') {
                this.helpTextFinancialDoc = 'Mandatory for all except those filed under presumptive income i.e. 44 AD/AE/ADA cases';
            } else if (this.documentNameValue === 'Previous year Financials - P&L and BS') {
                this.helpTextFinancialDoc = 'Mandatory for all except those filed under presumptive income i.e. 44 AD/AE/ADA cases';
            } else {
                this.helpTextFinancialDoc = undefined;
            }
            const matchingRecordFin = this.filesListFinancial.find(record => record.incomeDocumentType === this.documentNameValue);
            if (matchingRecordFin) {
                this.availableInFileFin = matchingRecordFin.FileAvailable;
                this.disableAvialbleInFileFin = matchingRecordFin.isAvailableInFileDisabled;
                if(this.availableInFileFin === true){
                    this.disableAvialbleInFileFin = true;
                }
            }else{
                this.availableInFileFin = false;
                this.disableAvialbleInFileFin = false;
            }
        }else {
            this.disableFileUpload = true;
        }
    }


    handleAvailableChangeFin(event){
        if(event.target.checked === true){
            this.showSpinner = true;
            if(this.selectedDocDetailIdFinancial){
                this.upsertMatchingDocumentDetailRecord(this.selectedDocDetailIdFinancial, 'financialSection');
            }else{
                this.createMatchingDocumentDetailRecord(this.financialDocCategory, this.documentTypeValue, this.documentNameValue, true, 'financialSection');
            }
        }
    }


    upsertMatchingDocumentDetailRecord(docDetailId, sectionCategory){
        var upsertedDocumentDetailRecords = [];
        var upsertedDocumentDetail = {};
        upsertedDocumentDetail.sobjectType = 'DocDtl__c';
        upsertedDocumentDetail.FileAvalbl__c = true;
        upsertedDocumentDetail.Id = docDetailId;
        upsertedDocumentDetailRecords.push(upsertedDocumentDetail);
        upsertMultipleRecord({ params: upsertedDocumentDetailRecords })
        .then(result => {
            if(sectionCategory && sectionCategory === 'financialSection'){
                refreshApex(this.wiredFileDataFin);
                this.documentNameValue = undefined;
            }
            if(sectionCategory && (sectionCategory === 'ITRsection' || sectionCategory === 'GSTsection')){
                this.handleCancelPopUp();
                refreshApex(this.wiredFileData);
                this.incomeValue = undefined;
            }
            this.showSpinner = false;
        }).catch(error => {
            console.log('error ==>>>' + JSON.stringify(error));
            this.showSpinner = false;
        })
    }

    createMatchingDocumentDetailRecord(documentCategory, documentType, documentSubType, availableinFile, sectionCategory){
        createDocumentDetail({ applicantId: this.applicantIdOnTabset, loanAppId: this.loanAppId, docCategory: documentCategory, docType: documentType, docSubType: documentSubType, availableInFile: availableinFile, applicantAssetId: null })
        .then((result) => {
            if(sectionCategory && sectionCategory === 'financialSection'){
                refreshApex(this.wiredFileDataFin);
                this.documentNameValue = undefined;
            }
            if(sectionCategory && (sectionCategory === 'ITRsection' || sectionCategory === 'GSTsection')){
                this.handleCancelPopUp();
                refreshApex(this.wiredFileData);
                this.incomeValue = undefined;
            }
            this.showSpinner = false;
        })
        .catch((err) => {
            this.showSpinner = false;
            console.log(" createDocumentDetailRecord error===", JSON.stringify(err));
        });
    }

    


    @api allowedFilFormat = [".jpeg", ".jpg", ".pdf"];
    @track disableFileUpload = false;


    spinnerStatus(event) {
        this.showSpinner = false;
        this.showSpinner = event.detail;    
    }

    @track isMultiFileUpload=true;
    @track disableDocumentUpload = false;
    @track docmntDetId = '';

    @track selectedDocDetailIdFinancial;

    @track docDetailMappingFinMap = [];

    docUploadRespHandler(event) {
        let isFileUploaded = event.detail.fileUploaded;
        let fileUploadData = event.detail;
        this.docmntDetId = '';
        if(isFileUploaded == true){    
            this.showSpinner = false;
            this.documentNameValue= undefined;
            refreshApex(this.wiredFileDataFin);
            this.docmntDetId = fileUploadData.docDetailId;
            var docDetailMap = [];
            docDetailMap.push({key: fileUploadData.docName, value: fileUploadData.docDetailId});
            this.formulatedocDetailMappingFinMap(docDetailMap);
            this.helpTextFinancialDoc = undefined;
        }else{
            this.showSpinner = false;
        }

            if(this.docmntDetId && this.documentPassword){
                this.upsertDocumentDetailRecord(this.docmntDetId, this.documentPassword);       
             }
   
     }

    formulatedocDetailMappingFinMap(dataMap){
        this.docDetailMappingFinMap = [];
        if(dataMap){
            dataMap.forEach(({ key, value }) => {
                const keyExistsFin = this.docDetailMappingFinMap.some(item => item.key === key);
                if (!keyExistsFin) {
                    this.docDetailMappingFinMap.push({ key, value });
                }
            });
            this.docDetailMappingFinMap = [...this.docDetailMappingFinMap];
        }else{
            this.docDetailMappingFinMap = [];
        }
    }


    @track hideAttachButtn;

 
    @track showITRDocUpload = false;

    itrSpinnerStatus(event){
        this.showSpinner = false;
        this.showSpinner = event.detail;
    }

    @track otherDocDetailId = '';
    @track selectedDocDetailIdITR;
    @track selectedDocDetailIdGST;

    @track disableITRDocumentUpload= false;

    handleITRDocUploadResp(event){
        let isFileUploaded = event.detail.fileUploaded;
        let fileUploadData = event.detail;
        this.otherDocDetailId = '';
        if(isFileUploaded == true){      
            this.showSpinner = false;
            this.incomeValue = undefined;
            refreshApex(this.wiredFileData);
            this.otherDocDetailId = fileUploadData.docDetailId;            
            var docDetailMap = [];
            docDetailMap.push({key: fileUploadData.docName, value: fileUploadData.docDetailId});
            this.formulatedocDetailMappingITRMap(docDetailMap);
            this.closeModal();
        }else{
            this.showSpinner = false;
        }

        if(this.otherDocDetailId && this.documentPasswordITR){
            this.upsertDocumentDetailRecord(this.otherDocDetailId, this.documentPasswordITR);       
         }
    }

    //Appl GST
    @track parametersAppGST = {
        ParentObjectName: 'ApplGST__c ',
        ChildObjectRelName: 'Applicant_Financials__r',
        parentObjFields: ['Id','GSTIN__c','Applicant__r.Month_Year_For_Location_Wise_GST__c'],
        childObjFields: ['Id','TypeOfFinancial__c','Applicant_GST__c'],
        queryCriteriaForChild: '',
        queryCriteria: ' where Applicant__c = \'' + this.applicantIdOnTabset + '\''
    }
    @track wiredDataGST;
    @api applGST;
    @wire(getAllSobjectDatawithRelatedRecords, {
        params: '$parametersAppGST'
    })
    handleFinancialgst(wiredDataRecords) {
        this.wiredDataGST = wiredDataRecords;
        let { error, data } = this.wiredDataGST;
        if (data) {
            this.applGST = data;
            console.log('applGST:: ',JSON.stringify(this.applGST));
        } else if (error) {
            console.error('Error applGST', error);
        }
            //this.formulateApplGSTMap(data);
    }




    @track docDetailMappingITRMap = [];

    formulatedocDetailMappingITRMap(dataMap){
        this.docDetailMappingITRMap = [];
        if(dataMap){
            dataMap.forEach(({ key, value }) => {
                const keyExistsITR = this.docDetailMappingITRMap.some(item => item.key === key);
                if (!keyExistsITR) {
                    this.docDetailMappingITRMap.push({ key, value });
                }
            });
            this.docDetailMappingITRMap = [...this.docDetailMappingITRMap];
        }else{
            this.docDetailMappingITRMap = [];
        }
    }


    @track disableGSTDocumentUpload= false;

    handleGSTDocUploadResp(event){
        let isFileUploaded = event.detail.fileUploaded;
        let fileUploadData = event.detail;
        this.otherDocDetailId = '';
        if(isFileUploaded == true){      
            this.showSpinner = false;
            this.incomeValue = undefined;
            refreshApex(this.wiredFileData);
            this.otherDocDetailId = fileUploadData.docDetailId;            
            var docDetailMap = [];
            docDetailMap.push({key: fileUploadData.docName, value: fileUploadData.docDetailId});
            this.formulatedocDetailMappingGSTMap(docDetailMap);
            var gstInputValue = this.gstTextFieldValue;
            this.closeModal();
            this.checkGSTRecordsUpsertCondition(gstInputValue);
        }else{
            this.showSpinner = false;
        }

        if(this.otherDocDetailId && this.documentPasswordITR){
            this.upsertDocumentDetailRecord(this.otherDocDetailId, this.documentPasswordITR);       
         }
    }

    @track docDetailMappingGSTMap = [];

    formulatedocDetailMappingGSTMap(dataMap){
        this.docDetailMappingGSTMap = [];
        if(dataMap){
            dataMap.forEach(({ key, value }) => {
                const keyExistsGST = this.docDetailMappingGSTMap.some(item => item.key === key);
                if (!keyExistsGST) {
                    this.docDetailMappingGSTMap.push({ key, value });
                }
            });
            this.docDetailMappingGSTMap = [...this.docDetailMappingGSTMap];
        }else{
            this.docDetailMappingGSTMap = [];
        }
    }

    @track showGSTDocUpload = false;
    GSTspinnerStatus(event){
        this.showSpinner = false;
        this.showSpinner = event.detail;
    }

    checkGSTRecordsUpsertCondition(gstValue){
        if(this.gstinValue === false && gstValue){
            var GSTDataSObject = {};
            var tempRecsGST = [];
            GSTDataSObject.sobjectType = 'ApplGST__c';
            GSTDataSObject.Applicant__c = this.applicantIdOnTabset;
            GSTDataSObject.GSTIN__c = gstValue;
            GSTDataSObject.GSTIN_Status__c = 'active';
            tempRecsGST.push(GSTDataSObject);
            this.showSpinner = true;
            this.upsertGSTRecord(tempRecsGST);
        }
    }

    upsertGSTRecord(gstData) {
        if (gstData && gstData.length > 0) {
            var upsertdataRecordsGST = [...gstData];
            upsertMultipleRecord({ params: upsertdataRecordsGST })
            .then(result => {
                this.showSpinner = false;
                refreshApex(this.wiredDataAppGST);
            }).catch(error => {
                console.log('error ==>>>' + error);
                this.showSpinner = false;
            })
        } else {
            this.showSpinner = false;
        }
    }
  

    @track financialDocCategory = 'Income Documents';


    get financialFileDataPresent() {
        if (this.filesListFinancial && this.filesListFinancial.length > 0) {
            return true;
        } else {
            return false;
        }
    }

    get provisionalFinancialYear(){
        if(this.latestYearOptionValue && this.latestYearOptionValue != 'ITR Not Available'){
            let [upcomingfirstPart, upcomingsecondPart] = this.latestYearOptionValue.split('-');
            upcomingfirstPart = parseInt(upcomingfirstPart);
            upcomingsecondPart = parseInt(upcomingsecondPart);
            const upcomingFinancialYear = `${(upcomingfirstPart+1)}-${(upcomingsecondPart+1)}`;
            return upcomingFinancialYear;
        }else{
            return null;
        }
    }

    @track provisionalFinancialYearOptions = [];
    @track provisionalFinancialYearSelectionValue;

    get provisionalFinancialYearSelection(){
        if(this.provisionalFinancialSelection && this.provisionalFinancialSelection === 'Yes'){
            this.provisionalFinancialYearOptions = [{label: this.provisionalFinancialYear , value: this.provisionalFinancialYear}];
            return true;
        }else{
            return false;
        }
    }

    inputChangeHandlerYear(event){
        if(event.detail.value){
            this.provisionalFinancialYearSelectionValue = event.detail.value;
        }
        
    }
    @track documentList=[];
    changeCheckBox(event) {    
        // Check if the document with the specified Id exists in the documentList
        let tempDocIndex = this.documentList.findIndex(item => item.Id == event.target.dataset.docid);
    
        if (tempDocIndex !== -1) {
            // If the document exists, update its FileAvalbl__c field
            this.documentList[tempDocIndex].FileAvalbl__c = event.target.checked;
        } else {
            // If the document doesn't exist, create a new object and push it into the documentList
            let tempObj = {
                sobjectType: 'DocDtl__c',
                Id: event.target.dataset.docid,
                FileAvalbl__c: event.target.checked
            };
            this.documentList.push(tempObj);
        }
    }


    @track availableInFileFin;
    @track disableAvialbleInFileFin;
    @track availableInFileITR;
    @track disableAvialbleInFileITR;
    @track availableInFileGST;
    @track disableAvialbleInFileGST;


    get isPassFieldsVisible(){
        if(this.documentNameValue){
            return true;
        }else{
            return false;
        }
        
    }

    @track showPasswordField=false;
    @track documentPassword;
    @track isDocPassProtected;
    passwordChangeHandler(event){          
            if (event.target.dataset.fieldname === 'Is_Document_Password_Protected__c') {
                if(event.target.value === 'Yes'){
                    this.showPasswordField = true;
                    this.isDocPassProtected = 'Yes';
                }else if(event.target.value === 'No'){
                    this.showPasswordField = false;
                    this.isDocPassProtected = 'No';
                    this.documentPassword = undefined;
                }
            }

            if (event.target.dataset.fieldname === 'DocPass__c') {
                this.documentPassword = event.target.value;
            }
    }

    upsertDocumentDetailRecord(docDetailId, documentPassword){
    
        var upsertedDocumentDetailRecords = [];
        var upsertedDocumentDetail = {};
        upsertedDocumentDetail.sobjectType = 'DocDtl__c';
        upsertedDocumentDetail.DocPass__c = documentPassword;
        upsertedDocumentDetail.Id = docDetailId;
        upsertedDocumentDetailRecords.push(upsertedDocumentDetail);
        upsertMultipleRecord({ params: upsertedDocumentDetailRecords })
        .then(result => {
            this.showPasswordField = false;
            this.showPasswordFieldITR = false;
            this.documentPasswordITR = '';
            this.documentPassword = '';
            this.isDocPassProtectedITR = '';
            this.isDocPassProtected = '';
            this.showGSTDocUpload = false;
            this.showITRDocUpload = false;
            this.showSpinner = false;
        }).catch(error => {
            console.log('error ==>>>' + JSON.stringify(error));
            this.showSpinner = false;
        })
    }
     

    get isPassFieldsVisibleForITR(){
        if(this.incomeValue){
            return true;
        }else{
            return false;
        }
    }

 
    @track showPasswordFieldITR=false;
    @track documentPasswordITR;
    @track isDocPassProtectedITR 
    passwordChangeHandlerITR(event){          
            if (event.target.dataset.fieldname === 'Is_Document_Password_Protected__c') {
                if(event.target.value === 'Yes'){
                    this.documentPasswordITR = undefined;
                    this.showGSTDocUpload = false;
                    this.showITRDocUpload = false;
                    this.showPasswordFieldITR = true;
                    this.isDocPassProtectedITR = 'Yes';
                }else if(event.target.value === 'No'){
                    this.documentPasswordITR = undefined;
                    this.showGSTDocUpload = false;
                    this.showITRDocUpload = false;
                    this.showPasswordFieldITR = false;
                    this.isDocPassProtectedITR = 'No';
                    if(this.isDocPassProtectedITR === 'No' && this.incomeValue && this.activetab && this.activetab === 'ITR'){
                           this.showITRDocUpload = true;
                           this.showGSTDocUpload = false;
                    }else
                    if (this.isDocPassProtectedITR === 'No' && this.incomeValue && (this.gstPicklistValue || this.validGST) && this.activetab && this.activetab === 'GST') { 
                        this.showGSTDocUpload = true;
                        this.showITRDocUpload = false;
                    }
                }
            }

            if (event.target.dataset.fieldname === 'DocPass__c') {
                this.documentPasswordITR = event.target.value;
                if (this.isDocPassProtectedITR === 'Yes' && this.incomeValue && (this.gstPicklistValue || this.validGST) && this.activetab && this.activetab === 'GST') { 
                        if(this.documentPasswordITR  && this.documentPasswordITR != '') {
                            this.showGSTDocUpload = true;
                            this.showITRDocUpload = false;
                        }else{
                            this.showGSTDocUpload = false;
                        } 
                }else      
                    if(this.isDocPassProtectedITR === 'Yes' && this.incomeValue && this.activetab && this.activetab === 'ITR')   {
                    if(this.documentPasswordITR  && this.documentPasswordITR != '') {
                        this.showITRDocUpload = true;
                        this.showGSTDocUpload = false;
                    }else{
                        this.showITRDocUpload = false;
                    }         
                }
            }
    }

    //LAK-452 START Integration

    @track counter1;
    chequeInterval1;
    startPollingFetchTrans() {
        this.counter1 = 0;
        this.chequeInterval1 = setInterval(() => {
            this.counter1 += 5;
            this.waitForImdStatus();
        }, 5000);
    }
    waitForImdStatus(){
        try {
            if (this.counter1 === 10) {
                refreshApex(this.wiredIMRecord)
                //refreshApex(this.wiredfinancialRec)

            }
        } catch (e) {
            console.log(e);
        }
    }

    @track intMsgId = '';
    @track wiredIMRecord;
    @track statusCode;
    @track msg;
    @track triggerITR = false;
    @track appId = 'a0cC4000000ITTNIA4';
    @track ImessageFields = [STATUS_FIELD, INTEGRATION_MSG_NAME_FIELD, RESPONSE_PAYLOAD_FIELD, API_STATUS_FIELD];
    @wire(getRecord, { recordId: '$intMsgId', fields: '$ImessageFields' })
    loadIM(result) {
        this.wiredIMRecord = result
        if (result.error) {
            this.showSpinner = false;
        } else if (result.data) {
            //refreshApex(this.wiredData);
        if(result.data.fields.Status__c.value === 'Responded' && result.data.fields.Name.value === 'FinFort Auth Token - ITR'){
            refreshApex(this.wiredData);
            const data = JSON.parse(result.data.fields.Resp__c.value);
            this.statusCode = data.statusCode;
            this.msg = data.msg;
            let tempParams = this.financialParams;
            tempParams.queryCriteria = 'WHERE Loan_Applicant__c=\'' + this.applicantIdOnTabset + '\'' + 'AND RecordType.name=\'' + this.financialRecName + '\'' + 'AND IsLatest__c = true';
            this.financialParams = { ...tempParams };
            if(this.statusCode !== 1){
                this.showToastMessage('Error', 'Authentication Failed.', 'error', 'sticky');

            }
            //refreshApex(this.wiredfinancialRec)
        }
        if(result.data.fields.Status__c.value === 'Responded' && result.data.fields.Name.value === 'FinFort Auth Token - GST'){
            refreshApex(this.wiredData);
            const data = JSON.parse(result.data.fields.Resp__c.value);
            this.statusCode = data.statusCode;
            this.msg = data.msg;
            let tempParams = this.financialParams;
            tempParams.queryCriteria = 'WHERE Loan_Applicant__c=\'' + this.applicantIdOnTabset + '\'' + 'AND RecordType.name=\'' + this.financialRecName + '\'' + 'AND IsLatest__c = true';
            this.financialParams = { ...tempParams };
            if(this.statusCode !== 1){
                this.showToastMessage('Error', 'Authentication Failed.', 'error', 'sticky');

            }
        }
    }
    }
    financialRecName;
    financialRecStatus;
    @track wiredfinancialRec;
    //getITRFinancialRecrod(){

        @track financialParams ={
                ParentObjectName: 'Applicant_Financial__c ',
                ChildObjectRelName: '',
                parentObjFields: ['id','RecordType.name','IsLatest__c'],
                childObjFields: [],
                queryCriteria: 'WHERE Loan_Applicant__c=\'' + this.applicantIdOnTabset + '\'' + 'AND RecordType.name=\'' + this.financialRecName + '\'' + 'AND IsLatest__c = true'
            }
         @track recData;
        @wire(getSobjectData,{params: '$financialParams'})
        handleWiredFinacialData(wiredFinancialData){
            let {error,data} = wiredFinancialData;
            this.wiredfinancialRec = wiredFinancialData;
            if(data){
                this.recData = data;
                console.log('data.parentRecords[0]',JSON.stringify(data));
                if(data.parentRecords && data.parentRecords.size > 0){
                if(data.parentRecords[0].FinFortAPIStatus__c === 'Success'){
                    this.showToastMessage('Success', 'Fetch ITR Successful', 'success', 'sticky');
    
                }
                if(data.parentRecords[0].FinFortAPIStatus__c === 'In Progress'){
                    this.showToastMessage('Info', 'Fetch is In Progress', 'info', 'sticky');
    
                }
                if(data.parentRecords[0].FinFortAPIStatus__c === 'Failure'){
                    this.showToastMessage('Error', 'Fetch ITR Failed', 'error', 'sticky');
                }
            }
            this.showSpinner = false
            clearInterval(this.chequeInterval1);

            //}
        }
            if(error){
                console.error('Error FinfortITR------------->', JSON.stringify(error));
            }
            //if(result.length > 0){
            //}
            

        }
    //}

    handleFetchITR(){
        this.financialRecName = 'ITR Finfort';
        console.log('this.applicantIdOnTabset',this.applicantIdOnTabset)
        if(this.appBrowPreLang === undefined){
            this.showToastMessage('Error','Please fill Borrower Preferred Language field in Applicant Details','error','sticky')
        }
        else{
        this.showSpinner = true;

                       const fields = {};
               
                       fields[INTEGRATION_MSG_NAME_FIELD.fieldApiName] = 'FinFort Auth Token - ITR';
                       fields[BU_FIELD.fieldApiName] = 'HL / STL';
                       fields[REFERENCE_ID_FIELD.fieldApiName] = this.applicantIdOnTabset;
                       fields[STATUS_FIELD.fieldApiName] = 'New';
                       fields[REFERENCE_OBJ_API_FIELD.fieldApiName] = 'Applicant__c';
                       fields[SERVICE_NAME_FIELD.fieldApiName] = 'FinFort Auth Token - ITR';
                       fields[API_VENDOR__NAME_FIELD.fieldApiName] = 'FinFort';
                       fields[IS_ACTIVE_FIELD.fieldApiName] = true;
               
               
                       const recordInput = {
                           apiName: INTEGRATION_MSG_OBJECT.objectApiName,
                           fields: fields
                       };
               
                       createRecord(recordInput).then((result) => {
                           this.intMsgId = result.id
                           this.startPollingFetchTrans();
                       }).catch((error) => {
                           console.log('Error ##1025', error)
                           //refreshApex(this.wiredData);
                           this.showSpinner = false
                           this.showToastMessage('Error creating Integration record', error.body.message, 'error', 'sticky')
                       });
                    }
   }

   handleFetchGST(){
    console.log('this.applicantIdOnTabset',this.applicantIdOnTabset)
    this.financialRecName = 'GST Finfort';
    console.log('this.applicantIdOnTabset',this.applicantIdOnTabset)
    if(this.appBrowPreLang === undefined){
        this.showToastMessage('Error','Please fill Borrower Preferred Language field in Applicant Details','error','sticky')
    }
    else{
    this.showSpinner = true;

                   const fields = {};
           
                   fields[INTEGRATION_MSG_NAME_FIELD.fieldApiName] = 'FinFort Auth Token - GST';
                   fields[BU_FIELD.fieldApiName] = 'HL / STL';
                   fields[REFERENCE_ID_FIELD.fieldApiName] = this.applicantIdOnTabset;
                   fields[STATUS_FIELD.fieldApiName] = 'New';
                   fields[REFERENCE_OBJ_API_FIELD.fieldApiName] = 'Applicant__c';
                   fields[SERVICE_NAME_FIELD.fieldApiName] = 'FinFort Auth Token - GST';
                   fields[API_VENDOR__NAME_FIELD.fieldApiName] = 'FinFort';
                   fields[IS_ACTIVE_FIELD.fieldApiName] = true;
           
           
                   const recordInput = {
                       apiName: INTEGRATION_MSG_OBJECT.objectApiName,
                       fields: fields
                   };
           
                   createRecord(recordInput).then((result) => {
                       this.intMsgId = result.id
                       this.startPollingFetchTrans();
                   }).catch((error) => {
                       console.log('Error ##1025', error)
                       //refreshApex(this.wiredData);
                       this.showSpinner = false
                       this.showToastMessage('Error creating Integration record', error.body.message, 'error', 'sticky')
                   });
}
   }
   //LAK-452 END Integration
  


    unsubscribeMC() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    disconnectedCallback() {
        this.unsubscribeMC();
        releaseMessageContext(this.context);
    }
    // to download the excel file  lak-119
    handleDownExcelOfFinan(){
        this.showUploadComp=true
        this.openPopuP=false
        setTimeout(() => {
            if(this.template.querySelector('c-financial-sheet-upload-nd-download') != null){
               console.log('inside Download file'+ this.template.querySelector('c-financial-sheet-upload-nd-download'))
                this.template.querySelector('c-financial-sheet-upload-nd-download').downloadExcelFile();
            }
        }, 1000);

    }
    //upload manual profit and balance sheet lak-119
    @track showUploadComp;
    @track openPopuP;
    handleUploadExcelSheet(){
        console.log('inhandleUploadExcelSheet')
        this.showUploadComp=true
        this.openPopuP=true
        

    }
    hideModalBox(event){
        this.showUploadComp=false;
        if(this.template.querySelector('c-capture-balance-sheet-details') != null){
            this.template.querySelector('c-capture-balance-sheet-details').handleRefreshAllData();
        }
        if(this.template.querySelector('c-capture-profit-and-loss-details') != null){
            this.template.querySelector('c-capture-profit-and-loss-details').handleRefreshAllData();
        }
    }
}