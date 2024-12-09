import { LightningElement , track , wire,api} from 'lwc';
import { getObjectInfo , getPicklistValuesByRecordType} from 'lightning/uiObjectInfoApi';
import APPLBANKING_OBJECT from '@salesforce/schema/ApplBanking__c';
import { createRecord,updateRecord } from "lightning/uiRecordApi";
import { refreshApex } from '@salesforce/apex';
import updateData from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord'; //LAK-6742 - Account Aggregator
import BANKID_FIELD from "@salesforce/schema/ApplBanking__c.BankId__c";
import OTHER_BNK_NAME_FIELD from "@salesforce/schema/ApplBanking__c.OtherBankName__c";
import SFDC_BNK_MAS from "@salesforce/schema/ApplBanking__c.SFDCBankMaster__c";
import APPID_FIELD from "@salesforce/schema/ApplBanking__c.Id";
import APPALLDOCNAMES_FIELD from "@salesforce/schema/ApplBanking__c.AllDocumentNames__c";
import FILETYPE_FIELD from "@salesforce/schema/ApplBanking__c.FileType__c";
import DOCDETAIL_FIELD from "@salesforce/schema/ApplBanking__c.DocumentDetail__c";
import ACCTYPE_FIELD from "@salesforce/schema/ApplBanking__c.AccountType__c";
import IS_PASS_REQ_FIELD from "@salesforce/schema/ApplBanking__c.Is_Statement_password_protected__c";
import PASSWORD_FIELD from "@salesforce/schema/ApplBanking__c.Password__c";
import BANKNAME_FIELD from "@salesforce/schema/ApplBanking__c.BankName__c";
import APPLICANT_FIELD from "@salesforce/schema/ApplBanking__c.Appl__c";
import LOANAPPLICATION_FIELD from "@salesforce/schema/ApplBanking__c.LoanAppl__c";
import LIMIT from "@salesforce/schema/ApplBanking__c.Limit__c";
import LIMITTYPE from "@salesforce/schema/ApplBanking__c.IsThereChangeInLimitDuringThePeri__c";
import AVAI_IN_FILE_FIELD from "@salesforce/schema/ApplBanking__c.FileAvalbl__c";
import SOURCE_TYPE from "@salesforce/schema/ApplBanking__c.Source_Type__c";
import SOURCE from "@salesforce/schema/ApplBanking__c.Source__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import {subscribe, publish, MessageContext, APPLICATION_SCOPE} from 'lightning/messageService';
import { NavigationMixin } from 'lightning/navigation';
import DOCDETAILID from "@salesforce/schema/DocDtl__c.Id";
import APPOFDOCDET from "@salesforce/schema/DocDtl__c.ApplBanking__c";
import Doc_IS_LAT from "@salesforce/schema/DocDtl__c.IsLatest__c";
import getDatawithoucah from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataWithoutCacheable';
import getAllSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjDtwithFltrRelatedRecordsWithoutCache";
import getDataForFilterChild from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithFilterRelatedRecords';
import createAggrSMSTask from '@salesforce/apex/PerfiosAAInitiateConsentRespProcessor.createSMSTask'; //LAK-6742 - Account Aggregator

import createDocumentDetail from "@salesforce/apex/DocumentDetailController.createDocumentDetail";
import fetchRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import getSObjData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import BankingDetails_SalaryAcc_ErrorMessage from '@salesforce/label/c.BankingDetails_SalaryAcc_ErrorMessage';
import BankingDetails_update_SuccesssMessage from '@salesforce/label/c.BankingDetails_update_SuccesssMessage';
import BankingDetails_DocDetails_ErrorMessage from '@salesforce/label/c.BankingDetails_DocDetails_ErrorMessage';
import BankingDetails_FileUpload_SuccesssMessage from '@salesforce/label/c.BankingDetails_FileUpload_SuccesssMessage';
import BankingDetails_FileSize_ErrorMessage from '@salesforce/label/c.BankingDetails_FileSize_ErrorMessage';
import BankingDetails_DocName_ErrorMessage from '@salesforce/label/c.BankingDetails_DocName_ErrorMessage';
import BankingDetails_FileType_ErrorMessage from '@salesforce/label/c.BankingDetails_FileType_ErrorMessage';
import BankingDetails_FileTypeDoc_ErrorMessage from '@salesforce/label/c.BankingDetails_FileTypeDoc_ErrorMessage';
import BankingDetails_File_ErrorMessage from '@salesforce/label/c.BankingDetails_File_ErrorMessage';
import BankingDetails_BankRecord_SuccesssMessage from '@salesforce/label/c.BankingDetails_BankRecord_SuccesssMessage';
import BankingDetails_CreateDoc_ErrorMessage from '@salesforce/label/c.BankingDetails_CreateDoc_ErrorMessage';
import BankingDetails_ApplicantBanking_ErrorMessage from '@salesforce/label/c.BankingDetails_ApplicantBanking_ErrorMessage';
import BankingDetails_SelectFiles_ErrorMessage from '@salesforce/label/c.BankingDetails_SelectFiles_ErrorMessage';
import BankingDetails_Del_SuccesssMessage from '@salesforce/label/c.BankingDetails_Del_SuccesssMessage';
import BankingDetails_SummaryData_ErrorMessage from '@salesforce/label/c.BankingDetails_SummaryData_ErrorMessage';
import BankingDetails_ConsolidateData_ErrorMessage from '@salesforce/label/c.BankingDetails_ConsolidateData_ErrorMessage';
import BankingDetails_CreateRecord_ErrorMessage from '@salesforce/label/c.BankingDetails_CreateRecord_ErrorMessage';
import BankingDetailsAccountType_Error from '@salesforce/label/c.BankingDetailsAccountType_Error';
import BankingDetailsSavingAccontError from '@salesforce/label/c.BankingDetailsSavingAccontError';
//LAK-6742 - Account Aggregator
import BankingDetailsApplicantDataSuccessMessage from '@salesforce/label/c.BankingDetailsApplicantDataSaveSuccesssMessage';
import BankingDetailsAASmsSuccessMessage from '@salesforce/label/c.BankingDetailsAASmsSuccessMessage';
import formFactorPropertyName from "@salesforce/client/formFactor";
import BankDataTable_InstitutionID_Error from '@salesforce/label/c.BankDataTable_InstitutionID_Error';
import Aggregator_Message from '@salesforce/label/c.Aggregator_Message'; //LAK-6742 - Account Aggregator

const MAX_FILE_SIZE = 25000000;
let XLS = {};


export default class CaptureBankingDetails extends NavigationMixin(LightningElement) {

    label = {
        BankingDetails_SalaryAcc_ErrorMessage,
        BankingDetails_update_SuccesssMessage,
        BankingDetails_DocDetails_ErrorMessage,
        BankingDetails_FileUpload_SuccesssMessage,
        BankingDetails_FileSize_ErrorMessage,
        BankingDetails_DocName_ErrorMessage,
        BankingDetails_FileType_ErrorMessage,
        BankingDetails_FileTypeDoc_ErrorMessage,
        BankingDetails_File_ErrorMessage,
        BankingDetails_BankRecord_SuccesssMessage,
        BankingDetails_CreateDoc_ErrorMessage,
        BankingDetails_ApplicantBanking_ErrorMessage,
        BankingDetails_SelectFiles_ErrorMessage,
        BankingDetails_Del_SuccesssMessage,
        BankingDetails_SummaryData_ErrorMessage,
        BankingDetails_ConsolidateData_ErrorMessage,
        BankingDetails_CreateRecord_ErrorMessage,
        BankingDetailsAccountType_Error,
        BankingDetailsSavingAccontError,
        BankDataTable_InstitutionID_Error,
        //LAK-6742 - Account Aggregator
        Aggregator_Message,
        BankingDetailsApplicantDataSuccessMessage,
        BankingDetailsAASmsSuccessMessage
    }
    @track fileTypeError;
    @api hasEditAccess;
    @api recordId;
    @api layoutSize;
    @api isReadOnly;
    @track isShowModal = false;
    @track value;
    StageValue ='';
    @track filetype;
    @track disabled= false;
    @track doctype;
    @track wrapBankObj ={};
    @track fileTypeOptions =[];
    //LAK-6742 - Account Aggregator
    get mobileAltOptions (){
        return [
        {label : 'Yes', value: 'Y'},
        {label : 'No', value: 'N'}
    ];
    }
    @track aggregatorMessage;
    @track alternateMobVal;
    @track alternateMobNo;
    @track primaryMobNo;
    @track isAlternateMob = false;
    @track perfiosAAStatus;
    @track accTypeOptions = [];
    @track disabledMode;
  
    @track _applicantId;
    @track showApplicantCmp=false;
    @track showMessga=true;
    @track hideAttachButton;
    @track convertToSingleImage;
    @track _loanAppId;
    additionalCheckShowtable1=false;
    additionalCheckShowtable2=false;
    @api get loanAppId() {
       return this._loanAppId;
    }
    set loanAppId(value) {
         this._loanAppId = value;
        this.setAttribute("loanAppId", value);  
        this.handleLoanAppRecordIdChange(value);          
    }
    
    @api get applicantId() {
        return this._applicantId;
    }
    
    set applicantId(value) {
        
        this._applicantId = value;
        this.setAttribute("applicantId", value);            
        this.handleRecordIdChange(value);  
       
    }
    @api docName = 'Bank Statement';
    @api docType = 'Bank Statement';
    @api docCategory = 'Banking Documents';
    @api allowedFilFormat = ".docx, .pdf, .doc ";

    @track fileSizeMsz = "Maximum file size should be 25Mb.";

    @track isSite = false;
    @track lightningDomainName;
    @track vfUrl;
    @track showSpinner = false;
    @track fileData = [];
    @track fileName = '';
    @track Ext = '';
    @track formFactor = formFactorPropertyName;
    @track DocMasterId;
    @track DocumentType;
    @track DocumentDetailName;
    @track DocumentDetaiId;
    @track applicantBankingId;
    @track _wiredApplicantBanking;
    @track ChildReords = [];
    @track AllChildRecords = [];
    @track documentCategoryList = [];
    @track parentRecord = {};
    @track IsPassReqOptions =[];
    @track reqLoanAmount;
    @track assessedIncApp;
    //LAK-6742 - Account Aggregator
    @track applData = {};
    @track isShowAggrModal = false;
    @track bankDataTableShow=false;
    @track aggrLinkExpiry;
    get options() {
        return [
            { label: 'Manual Upload', value: 'Manual Upload' },
            { label: 'Fetch Online Perfios', value: 'Fetch Online Perfios' }
        ];
    }
    @track params={
        ParentObjectName:'Applicant__c',
        ChildObjectRelName:'Applicant_Banking1__r',
        parentObjFields:['Id','CustProfile__c', 'Constitution__c','BankingMobNumber__c','MobNumber__c','TransactionId__c','AggrLinkExpiryDate__c','isAlternateAggMob__c','Perfios_AA_Status__c'],//LAK-6742 - Account Aggregator
        childObjFields:['OtherBankName__c','Id','Source_Type__c','Source__c', 'DocumentDetail__r.RCUInitiated__c', 
            'AllDocumentNames__c','IntegrationErrorMessage__c','Initiate_Perfios_Status__c',
            'Is_Statement_password_protected__c','Password__c','SFDC_Bank_Master_Name__c','SFDCBankMaster__r.BankName__c','SFDCBankMaster__r.InstitutionId__c','AccountType__c','FileType__c','DocumentDetail__c','DocumentDetail__r.DocTyp__c','SalaryAccount__c','DocumentDetail__r.DocSubTyp__c'],        
        queryCriteriaForChild: ' WHERE Type__c = \'\' AND IsDeleted__c != true',
        queryCriteria: ' where Id= \'' + this.applicantId + '\''

    }
  
    @track paramsForLoanAppRec={
        ParentObjectName:'LoanAppl__c',
        ChildObjectRelName:'Applicant_Banking1__r',
        parentObjFields:['Id','Stage__c','LoginAcceptDate__c','FileAcceptDate__c','AssessedIncAppln__c','AssesIncomeAppl__c','ReqLoanAmt__c'],
        childObjFields:['AccountType__c','Id'],  
        queryCriteriaForChild: ' WHERE IsDeleted__c != true',      
        queryCriteria: ' where Id= \'' + this.loanAppId + '\''

    }

    handleRecordIdChange(){        
        let tempParams = this.params;
        tempParams.queryCriteria = ' where Id = \'' + this.applicantId + '\'';
        this.params = {...tempParams};
    }

    handleLoanAppRecordIdChange(){        
        let tempParams1 = this.paramsForLoanAppRec;
        tempParams1.queryCriteria = ' where Id = \'' + this.loanAppId + '\'';
        this.paramsForLoanAppRec = {...tempParams1};
    }
    
    showModalBox() {   
        this.isShowModal = true; 
        this.disabled =false;
        
    }
    //LAK-6742 - Account Aggregator
    showAggModalBox(){
        this.isShowAggrModal = true;
        this.disabled = false;
    }


    get disAlterMob(){
        let disableAlt = false;
        if(this.aggrLinkExpiry != null || this.aggrLinkExpiry != undefined){
            const dateToCompare = new Date(this.aggrLinkExpiry);
            const today = new Date();
            disableAlt = today < dateToCompare;
        }
        if(this.perfiosAAStatus === 'Success' || this.alternateMobNo == null){
            disableAlt = false;
        }
        return this.disableMode || disableAlt;
    }

    get disableAA(){
        let disAA;
        if(this.parentRecord.Constitution__c === 'INDIVIDUAL' || this.parentRecord.Constitution__c === 'PROPERITORSHIP')
        {
            disAA = false;
        }
        else{
            disAA = true;
        }

        return this.disableMode || disAA;
    }

   @wire(getObjectInfo, { objectApiName:  APPLBANKING_OBJECT})
    objectInfo

    @wire(getPicklistValuesByRecordType, {
        objectApiName: APPLBANKING_OBJECT,
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    })picklistHandler({ data, error }){
        if(data){
            
            this.fileTypeOptions = [...this.generatePicklist(data.picklistFieldValues.FileType__c)]
            this.accTypeOptions = [...this.generatePicklist(data.picklistFieldValues.AccountType__c)]
            this.IsPassReqOptions = [...this.generatePicklist(data.picklistFieldValues.Is_Statement_password_protected__c)]
        }
        if (error) {
            console.error(error)
        }
    }

    generatePicklist(data) {
        return data.values.map(item => ({ "label": item.label, "value": item.value }))
    }
    idsForODACCA;
    idsForSAJACA;
    custProfile;
    allAppliBnkingIds;
   @wire(getDataForFilterChild,{params:'$params'})
    loadApplicantBanking(wiredApplicantBanking) {
        const { data, error } = wiredApplicantBanking;
        this._wiredApplicantBanking = wiredApplicantBanking;
        this.AllChildRecords = [];
        this.bankDataTableShow=false;
        let contentDocumentIds = [];
        this.idsForODACCA=[]
        this.idsForSAJACA=[]
        const contentVersionMap = new Map();
        this.bankDataTableShow = false;
        if (data) {
            console.log('JSON.stringify(data.parentRecord)',JSON.stringify(data))
            this.parentRecord=JSON.parse(JSON.stringify(data.parentRecord));
            //LAK-6742 - Account Aggregator
            this.custProfile=this.parentRecord.CustProfile__c;
            this.alternateMobNo = this.parentRecord.BankingMobNumber__c;
            this.primaryMobNo = this.parentRecord.MobNumber__c;
            this.alternateMobVal = this.parentRecord.isAlternateAggMob__c;
            this.isAlternateMob=this.parentRecord.isAlternateAggMob__c == 'Y' ? true : false;
            this.aggrLinkExpiry = this.parentRecord.AggrLinkExpiryDate__c;
            this.perfiosAAStatus = this.parentRecord.Perfios_AA_Status__c;
            if(data.ChildReords && data.ChildReords !== undefined){
                this.ChildReords=JSON.parse(JSON.stringify(data.ChildReords));
                this.AllChildRecords = [...this.ChildReords];
                this.bankDataTableShow=true;
               let applicantBankingdata=[];
               let idsForSAJACAnew=[];
               let idsForODACCAnew=[];
               let allAppliBnkingIds=[];
               
    
                this.AllChildRecords.forEach(bankId => {
                    if(bankId.AccountType__c ==='JOINT'|| bankId.AccountType__c ==='SAVINGS' || bankId.AccountType__c ==='CURRENT'){
                        idsForSAJACAnew.push(bankId.Id)
                        allAppliBnkingIds.push(bankId.Id);
                        this.idsForSAJACA=idsForSAJACAnew

                    }else if(bankId.AccountType__c ==='CC'|| bankId.AccountType__c ==='OVERDRAFT'){
                        idsForODACCAnew.push(bankId.Id)
                        allAppliBnkingIds.push(bankId.Id);
                        this.idsForODACCA=idsForODACCAnew
                    }

                applicantBankingdata.push(bankId.Id);
               });
               this.allAppliBnkingIds=allAppliBnkingIds;
               console.log('this.allAppliBnkingIds'+this.allAppliBnkingIds)
                this.applicantBankingIds=applicantBankingdata;
      
              
            }else{
                this.bankDataTableShow=true;
                this.ChildReords = [];
                this.AllChildRecords = [];
            }
               
        } else if (error) {
            this.bankDataTableShow=true;
            console.log(error);
        }
    }


    paramsForConVer;
    _conVerWired
    @wire(getSObjData,{params:'$paramsForConVer'})
    conVerWiredData(conVerWired) {
        const { data, error } = conVerWired;
        this._conVerWired = conVerWired;
        const contentVersionMap = new Map();
        this.parRecConVer={}
        if (data) {
            if(data.parentRecords){
              
                data.parentRecords.forEach(item=>{
                contentVersionMap[item.Id] = {'Title':item.Title};
                })
            }
            let AllChildRecordsClone = [];
            AllChildRecordsClone = this.AllChildRecords.map(entity =>{
                let contentVersionTitle = contentVersionMap[entity.DocumentDetail__r.Content_Document_Id__c] === undefined?{Title:''}:contentVersionMap[entity.DocumentDetail__r.Content_Document_Id__c];
                entity.DocumentDetail__r = {...entity.DocumentDetail__r,...contentVersionTitle}
                return {...entity};
            })
          
        
        }else if (error) {
            console.log(error);
        }
    }


    @track _wiredLoanApplication
    @track loanApplicatioRec;
    @track stageOfLoanApp;
    @track loginAcceDate;
    @track fileAcceptanceDate;
    @track allAppliBankRecos;
    @track allLoanApllicantRecIds;


    @wire(getDataForFilterChild,{params:'$paramsForLoanAppRec'})
    loanApplicationRecords(wiredLoanApplication) {
        const { data, error } = wiredLoanApplication;
        this._wiredLoanApplication = wiredLoanApplication;
        if (data) {
            console.log('data::capture appl banking:::331',data);
            
            this.loanApplicatioRec=JSON.parse(JSON.stringify(data.parentRecord));  
            console.log('this.loginAcceDate'+JSON.stringify(data.parentRecord))
            this.stageOfLoanApp= this.loanApplicatioRec.Stage__c; 
            this.loginAcceDate= this.loanApplicatioRec.LoginAcceptDate__c;
            
            this.fileAcceptanceDate=this.loanApplicatioRec.FileAcceptDate__c;
            console.log('this.loginAcceDate'+this.fileAcceptanceDate)
            this.reqLoanAmount=this.loanApplicatioRec.ReqLoanAmt__c
            this.assessedIncApp=this.loanApplicatioRec.AssesIncomeAppl__c
        
            this.showConsoledateButtons = this.stageOfLoanApp !== 'QDE';          
            if(data.ChildReords && data.ChildReords !== undefined){

                this.allAppliBankRecos=JSON.parse(JSON.stringify(data.ChildReords));
                allAppliBankRecos=[];
                allAppliBankRecos = this.allAppliBankRecos;
                var allAppliBankRecos=[];
                var allIdsForODACCAnew=[];
                var allIIdsForSAJACA=[];

                for (const record of this.allAppliBankRecos){
                    //if(record.IsDeleted__c !== true){
                        if(record.AccountType__c ==='JOINT'|| record.AccountType__c ==='SAVINGS' || record.AccountType__c ==='CURRENT'){
                            allIIdsForSAJACA.push(record.Id)
                        }else{
                            allIdsForODACCAnew.push(record.Id)
                        }
                        allAppliBankRecos.push(record.Id);
                    //}
                    this.allIIdsForSAJACA=allIIdsForSAJACA
                    this.allIdsForODACCAnew=allIdsForODACCAnew
                    this.allLoanApllicantRecIds=allAppliBankRecos;
                }
            }else{
                this.ChildReords = [];
               
            }
                
        } else if (error) {
            console.log('error>>>>>>>>>>>>>>>>>'+error);
            console.log('error>>>>>>>>>>>>>>>>>'+JSON.stringify(error));
        }
    }
    allIIdsForSAJACA
    allIdsForODACCAnew
    @wire(MessageContext)
    MessageContext;        
    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }

    handleSaveThroughLms(values) {
        this.handleSaveV(values.validateBeforeSave);

    }

    handleSaveV(validate) {
        if(validate){
            if(this.AllChildRecords.length>0){
               
                if(this.validateBankDetailRecords()){
                  
                    this.handleSave();
                }else{
                   
                    
                        this.showToast("Error!", "error",this.label.BankingDetails_SalaryAcc_ErrorMessage);   
                    
                }
    
            }else{
              
            }
        }else{
            if(this.AllChildRecords.length>0){
                this.handleSave();
            }
            
        }
    }
    validateBankDetailRecords(){
      if(this.parentRecord.CustProfile__c ==='SALARIED' && this.showMessga && this.bankCreditFlag===true){
        
            let numberofsalaryAccount = this.AllChildRecords.filter (record => record.SalaryAccount__c).length;
            return numberofsalaryAccount===1
        }
        return true;
        
    }

    handleSave() {
                 
        let ChildRecords = [];
        let childRecordObj = {};
        for(var i=0;i<this.AllChildRecords.length;i++){
            
            childRecordObj = {...this.AllChildRecords[i]};
            childRecordObj.sobjectType='ApplBanking__c'
            ChildRecords.push(childRecordObj);
        }  
        const excludedFields = ['SFDCBankMaster__c', 'SFDC_Bank_Master_Name__c', 'AccountType__c', 'FileType__c', 'Password__c', 'isCanDis','isFileDis', 'Initiate_Perfios_Status__c'];
        ChildRecords = ChildRecords.map(item => {
            const newItem = {};
            for (const key in item) {
                if (!excludedFields.includes(key)) {
                    newItem[key] = item[key];
                }
            }
            return newItem;
        });
        this.parentRecord.sobjectType='Applicant__c';                    
        let upsertData={                       
            parentRecord:this.parentRecord,                       
            ChildRecords:ChildRecords,
            ParentFieldNameToUpdate:'Appl__c'
        }                   
        
        updateData ({upsertData:upsertData})
        .then(result => {   
                this.showSpinner=false;
                               if(this.showMessga){
                    
                    this.dispatchEvent(
                         new ShowToastEvent({
                             title: "Success",
                             message: "Banking Details updated",
                           variant: "success",
                           mode: "sticky"
                        })
                     );
                }
                setTimeout(() => {
                    refreshApex(this._wiredApplicantBanking);
                    refreshApex(this._wiredLoanApplication);
                    refreshApex(this._conVerWired);
                    this.showApplicantCmp=true;
                    setTimeout(() => {
            this.template.querySelector('c-consolidate-appliant-banking-data').refresewireMethods();
    }, 300);
                }, 3000);
             
                         
            
        }).catch(error => {
          
            console.log('>>>>>>'+error);
        })
            
    }
    showLimitField;
    showPasswordCol=false;
    handleChange(event) {
        this.wrapBankObj[event.target.dataset.fieldname] = event.target.value;
        if (event.target.dataset.fieldtype === 'string') {
            let strVal = event.target.value;
            this.wrapBankObj[event.target.dataset.fieldname] = strVal.toUpperCase();
        }
        if(event.target.dataset.fieldname==='FileType__c'){
            console.log('inahahahah'+event.target.value)
            if(event.target.value==='ePDF'){
               
                this.allowedFilFormat = ".pdf";
                this.fileTypeError='Allowed File Types are : pdf'
                this.fileSizeMsz = "Maximum file size should be 25Mb. Allowed file type is .pdf only";
            }else if(event.target.value==='Manual Upload'){
                console.log('event.target.value'+event.target.value)
              
            }
            else{
               
                this.allowedFilFormat = ".docx, .pdf, .doc ";
                this.fileTypeError='Allowed File Types are : pdf, doc, docx'
                this.fileSizeMsz = "Maximum file size should be 25Mb. Allowed file types are .doc, .docx, .pdf";
            }
        }else if(event.target.dataset.fieldname==='AccountType__c'){
            if(event.target.value === 'SAVINGS'){
                this.docName = 'Saving';
                this.showLimitField=false;
            }else if(event.target.value === 'JOINT'){
                this.docName = 'Joint';
            }else if(event.target.value === 'CURRENT'){
                this.docName = 'Current';
                this.showLimitField=false;
            }else if(event.target.value === 'OVERDRAFT'){
                this.docName = 'OD';
                this.showLimitField=true;
            }else if(event.target.value === 'CC'){
                this.docName = 'CC';
                this.showLimitField=true;
            }
            console.log('this.parentRecord.Constitution__c', this.parentRecord.Constitution__c)
            //logic for LAK-6105- only allow CC/OD/CURRENT bank statement upload for NON INDIVIDUAL customer except PROPERITORSHIP and HUF cases start
           if(typeof this.parentRecord.Constitution__c!=='undefined'){
                if(this.parentRecord.Constitution__c =='HUF' || this.parentRecord.Constitution__c =='INDIVIDUAL' || this.parentRecord.Constitution__c=='PROPERITORSHIP'){
                    if(this.parentRecord.Constitution__c =='HUF' || this.parentRecord.Constitution__c=='PROPERITORSHIP'){
                        /*if(this.docName == 'CC' ||  this.docName == 'OD' || this.docName == 'Current'){
                            this.template.querySelector('[data-id="accType"]').value=''
                            this.docName=''
                            this.wrapBankObj.AccountType__c=''
                            this.showToast("Error!", "error",this.label.BankingDetailsSavingAccontError);
                        }*/
                    }
                }else{
                   
                    if(this.docName == 'CC' ||  this.docName == 'OD' || this.docName == 'Current'){

                    }else{
                        this.template.querySelector('[data-id="accType"]').value=''
                        this.docName=''
                        this.wrapBankObj.AccountType__c=''
                        this.showToast("Error!", "error",this.label.BankingDetailsAccountType_Error);
                    }
                }
           }
           
            //End
        }
       else if(event.target.dataset.fieldname === 'Is_Statement_password_protected__c'){
            if(event.target.value ==='Yes'){
                this.showPasswordCol = true;
            }else{
                this.showPasswordCol = false;
            }
           
        }
 
    }
    //LAK-6742 - Account Aggregator
    handleMobileChange(event){
        if(event.target.dataset.fieldname === 'isAlternateAggMob__c'){
        this.alternateMobVal = event.target.value;
        this.isAlternateMob = this.alternateMobVal == 'Y' ? true : false;
        }
        else if(event.target.dataset.fieldname ==='BankingMobNumber__c'){
            this.alternateMobNo = event.target.value;
        }
    }

    toShowALLConsolidateDataBut=false;
    
    async connectedCallback() {
        this.hideAttachButton = true;
        if(this.hasEditAccess === false){
              this.disableMode = true;
        }else{
               this.disableMode = false;
        }
        this.aggregatorMessage = this.label.Aggregator_Message; //LAK-6742 - Account Aggregator

        this.scribeToMessageChannel();
        this.fetchIncomeDetails();

        //for manual file upload
       
    }

    renderedCallBack(){
        refreshApex(this._wiredApplicantBanking);
        refreshApex(this._wiredLoanApplication);
        
    }
      showConsoledateButtons=true   
    handleUploadCallback(message) {
        
   
        this.hideModalBox();
        
        this.wrapBankObj={};

        
        
        
    }

   handleFileChange(event) {
       
        event.preventDefault();   
        if (
            event.target.files.length > 0
        ) {
            let dt = [];
            
            for (var i = 0; i < event.target.files.length; i++) {  
                
               
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.showToast(
                        "Error!",
                        "error",
                        this.label.BankingDetails_FileSize_ErrorMessage
                    );
                    return;
                }
                

                let file = event.target.files[i];
                
                this.Ext= file.name.split(".").pop();
                if(!this.checkValidationOnFileType()){
                    return;
                }

                
                this.fileName =  file.name;
                let reader = new FileReader();
                        
                reader.onload = (e) => {
                    let fileContents = reader.result.split(",")[1];
                    let self = this;
                    let data = {
                        fileName: file.name + "  ",
                        fileContent: fileContents
                    };
                    dt = [...dt, data];
                    self.fileData = [ data];
                    this.showSpinner =false;
                    
                };
                reader.readAsDataURL(file);
                
            }

        } else {
            this.showToast("Error!", "error",this.label.BankingDetails_DocName_ErrorMessage);
        }
       
    }

   checkValidationOnFileType(){

        if(this.wrapBankObj.FileType__c == 'ePDF' ){           
            if(!this.Ext.includes("pdf")){
                
                this.showToast(
                    "Error!",
                    "error",
                    this.label.BankingDetails_FileType_ErrorMessage
                );
              return false;  
            }else{
                return true;
            }
            
        }else if(this.wrapBankObj.FileType__c === 'Scanned Documents' ){
            if(!this.allowedFilFormat.includes(this.Ext)){
                this.showToast(
                    "Error!",
                    "error",
                    this.label.BankingDetails_FileTypeDoc_ErrorMessage
                );
              return false;  
            }else{
                return true;
            }
        }
        
        
    }
    @track isFileAvailable=false;
    @track wrapdocDetailObj={}
    @track disableFileUpload=false;
    handleInputChange(event){
        this.wrapBankObj[event.target.dataset.fieldname] = event.target.checked;
        console.log('event.target.checked'+event.target.checked)
        if(event.target.checked){
            this.isFileAvailable=true;
            this.disableFileUpload=true

            //Add this condition for LAK-6320
            this.wrapBankObj.Is_Statement_password_protected__c=''
            this.wrapBankObj.Password__c=''
            this.wrapBankObj.FileType__c=''
            
        }else{
            this.isFileAvailable=false
            this.disableFileUpload=false
        }
    }
//LAK-6742 - Account Aggregator
    hideAggModalBox(){
        this.isShowAggrModal=false;
        
    }
    handleAggregator(){
        if(this.checkAggrValidity()){
            this.showSpinner = true;
            this.updateApplicantData();
        }
    }

    checkAggrValidity(){
        const isComboboxCorrect = [
            ...this.template.querySelectorAll("lightning-combobox")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        const isRequiredField = [
            ...this.template.querySelectorAll("lightning-input")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        return isComboboxCorrect && isRequiredField;

    }

    updateApplicantData(){
        this.showSpinner = true;
        this.parentRecord["Id"] = this.applicantId;
        this.parentRecord.isAlternateAggMob__c = this.alternateMobVal;
        this.parentRecord.BankingMobNumber__c = this.alternateMobNo;

        const tempData = this.parentRecord;
        console.log('tempData>>762',tempData);
        let applData = [];
        if(tempData){
            applData.push(tempData);
        }
        upsertSObjectRecord({ params: applData })
          .then((result) => {
            console.log(" INSIDE UPDATE RECORD SUCCESS>>>");
            this.showToast("Success", "success",this.label.BankingDetailsApplicantDataSuccessMessage);
            this.sendLinkForAggregator();
          }).catch((error)=>{
            this.showSpinner = false;
          });

    }

    sendLinkForAggregator(){
        if(this.parentRecord.AggrLinkExpiryDate__c != null || this.parentRecord.AggrLinkExpiryDate__c != undefined){
            const dateToCompare = new Date(this.parentRecord.AggrLinkExpiryDate__c);
            const today = new Date();
            this.isLessThanToday = today < dateToCompare;
            console.log('isLessThanToday',this.isLessThanToday);
        }
        if(this.parentRecord.Perfios_AA_Status__c === 'Pending' && this.isLessThanToday === true){
            refreshApex(this._wiredApplicantBanking);
            this.createAggSMSTsk();
        }
        else{
            this.onClickAccountAggregator();
        }
    }


    createAggSMSTsk(){
        if(this.applicantId){
            console.log('this.applicantId',this.applicantId)
        createAggrSMSTask({ referenceId : this.applicantId })
        .then(result => {
            refreshApex(this._wiredApplicantBanking);
            this.hideAggModalBox();
            this.showToast('Success','success',this.label.BankingDetailsAASmsSuccessMessage);
            this.showSpinner = false;
        }).catch(error => {
        this.showSpinner = false;
            console.error('Error 801', error)
        })
    }
    }


    handleSubmit(){
        if(this.checkValidation()){  
            if(this.showUploadFile==true){
                if(this.checkInstitutionIdForBnk()){
                }
            }else{
                this.showSpinner=true;
                this.createApplicantBankingRecord();
                this.disabled =true;  
            }
            this.showFileAvail=true
                         
            
        }
            
    }
    checkValiforManual(){
       const isComboboxCorrect = [
            ...this.template.querySelectorAll("lightning-combobox")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        return isComboboxCorrect;
        
    }
    checkValidation() {
        let lookUpCorrect = this.checkValidityLookup();
        let checkFile = this.checkFileType();
       

        const isRequiredField = [
            ...this.template.querySelectorAll("lightning-input")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        

        const isComboboxCorrect = [
            ...this.template.querySelectorAll("lightning-combobox")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        const radioButtonReq=[
            ...this.template.querySelectorAll("lightning-radio-group")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        return lookUpCorrect && checkFile && isComboboxCorrect && isRequiredField && radioButtonReq;
    }


    checkFileType(){
        if(this.files.length>0 || this.isFileAvailable===true) {
            return true;
        } else {
            this.showToast(
                "Error!",
                "error",
                this.label.BankingDetails_File_ErrorMessage
            );
            return false;
            
        }
        
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

    createApplicantBankingRecord(){
        console.log('this.wrapBankObj.Limit__c'+this.wrapBankObj.Limit__c)
        const fields = {};        
        fields[OTHER_BNK_NAME_FIELD.fieldApiName] = this.wrapBankObj.OtherBankName__c;
        fields[SFDC_BNK_MAS.fieldApiName] = this.wrapBankObj.SFDCBankMaster__c;
        fields[BANKID_FIELD.fieldApiName] = this.wrapBankObj.BankId__c;
        fields[BANKNAME_FIELD.fieldApiName] = this.wrapBankObj.BankName__c;
        fields[FILETYPE_FIELD.fieldApiName] = this.wrapBankObj.FileType__c;

        fields[IS_PASS_REQ_FIELD.fieldApiName] = this.wrapBankObj.Is_Statement_password_protected__c;
        fields[PASSWORD_FIELD.fieldApiName] = this.wrapBankObj.Password__c;
        
        fields[ACCTYPE_FIELD.fieldApiName] = this.wrapBankObj.AccountType__c;
        fields[APPLICANT_FIELD.fieldApiName] = this.applicantId;
        fields[LOANAPPLICATION_FIELD.fieldApiName] = this.loanAppId;
        fields[AVAI_IN_FILE_FIELD.fieldApiName] = this.wrapBankObj.FileAvalbl__c;
        fields[SOURCE_TYPE.fieldApiName] = this.wrapBankObj.Source_Type__c;
        fields[SOURCE.fieldApiName] = this.wrapBankObj.Source__c;
        if(this.showLimitField==true){
            fields[LIMIT.fieldApiName] = this.wrapBankObj.Limit__c
            fields[LIMITTYPE.fieldApiName] = 'No'
        }

        const recordInput = {
            apiName: APPLBANKING_OBJECT.objectApiName,
            fields: fields
          };
          console.log('recordInput>>>>'+JSON.stringify(recordInput))
        createRecord(recordInput)
        .then((record) => {
            this.applicantBankingId = record.id;
              console.log('this.applicantBankingId'+this.applicantBankingId)     
            if(this.template.querySelector('c-upload-docs-reusable-component')!=''&& this.template.querySelector('c-upload-docs-reusable-component')!=null && typeof this.template.querySelector('c-upload-docs-reusable-component') !=='undefined'){
                this.template.querySelector('c-upload-docs-reusable-component').handleUpload();
            }else{
                this.createDocumentDetailRecord();
                this.showSpinner=false;
            }
            this.showLimitField=false;
               this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: this.label.BankingDetails_BankRecord_SuccesssMessage,
                  variant: "success",
                  mode: "sticky"
               })
            );

        })
        .catch((err) => {
            console.log('err'+JSON.stringify(err))
            this.showToast("Error", "error",this.label.BankingDetails_CreateRecord_ErrorMessage + JSON.stringify(err));
        });
        
          

    }
    createDocumentDetailRecord() {

        if(this.wrapBankObj.AccountType__c === 'SAVINGS'){
            this.docName = 'Saving';
        }else if(this.wrapBankObj.AccountType__c === 'JOINT'){
            this.docName = 'Joint';
        }else if(this.wrapBankObj.AccountType__c === 'CURRENT'){
            this.docName = 'Current';
        }else if(this.wrapBankObj.AccountType__c === 'OVERDRAFT'){
            this.docName = 'OD';
        }else if(this.wrapBankObj.AccountType__c === 'CC'){
            this.docName = 'CC';
        }
         var availableInFile=true;
        createDocumentDetail({ applicantId: this.applicantId, loanAppId: this.loanAppId, docCategory: this.docCategory, docType: this.docType, docSubType: this.docName,availableInFile : availableInFile })
            .then((result) => {
                this.DocumentDetaiId = result;

                this.updateApplicantBanking();
               
            })
            .catch((err) => {
                this.showToast("Error", "error",this.label.BankingDetails_CreateDoc_ErrorMessage + err);
            });                   
    }
    updateApplicantBanking(){
        const fields = {};           
        fields[APPID_FIELD.fieldApiName] = this.applicantBankingId;
        fields[DOCDETAIL_FIELD.fieldApiName] = this.DocumentDetaiId;
        const recordInput = { fields };
        console.log('recordInputrecordInput'+recordInput)
        updateRecord(recordInput)
        .then((result) => {  
            refreshApex(this._wiredApplicantBanking);
            this.isShowModal=false
             //refreshApex(this._wiredApplicantBanking);
             this.isFileAvailable=false;
             this.disableFileUpload=false
             this.wrapBankObj={};
             this.wrapdocDetailObj={}
             console.log('this.showUploadFile==true'+this.showUploadFile)
             setTimeout(() => {
                if( this.showUploadFile==true){
                    this.createIntegrationMessageRec();
                } 
            }, 2000);
            
            
        })
        .catch(error => {
            this.showToast("Error", "error", this.label.BankingDetails_ApplicantBanking_ErrorMessage+ error);
        });
        
        
    }
    @track files=[]
    allFilesNames;
    parentFileChange(event){
        this.files=event.detail.fileList
        var allFilesNames='';
        for(const record of this.files){
            allFilesNames+= record.name+ ', '
        }
        this.allFilesNames = allFilesNames.replace(/,\s*$/, "");
     
    }
    fromUploadDocsContainer(event){
     
        var documentDeatilData=event.detail
        const fields = {};           
        fields[APPID_FIELD.fieldApiName] = this.applicantBankingId;
        fields[DOCDETAIL_FIELD.fieldApiName] = documentDeatilData.docDetailId;
        if(this.allFilesNames.length > 131072){
            this.allFilesNames.substring(0, 131072)
        }
        fields[APPALLDOCNAMES_FIELD.fieldApiName]=this.allFilesNames
        const recordInput = { fields };
        updateRecord(recordInput)
        .then((result) => { 
             this.isShowModal=false
             this.showSpinner=false;
             refreshApex(this._wiredApplicantBanking);
             this.wrapBankObj={};
             this.wrapdocDetailObj={}
            
            
        })
        .catch(error => {
            this.showToast("Error", "error", this.label.BankingDetails_ApplicantBanking_ErrorMessage+ error);
        });

        
    }
    handleeventAfterUpload(event){
        
        
    }


    fileUploadHandler() {
        if (this.fileData == [] || this.fileData.length == 0) {
            this.showSpinner = false;
            this.showToast("Error", "error", this.label.BankingDetails_SelectFiles_ErrorMessage);
            return;
        } else {
            this.uploadFileLargeVf();
            this.showSpinner = true;
        }
    }
    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
            mode: "sticky",
        });
        this.dispatchEvent(evt);
        this.showSpinner =false;
    }

    

    hideModalBox(){
        this.DocumentDetaiId = "";
        this.DocumentType = "";
        this.DocumentDetailName = "";
        this.DocMasterId = "";
        this.fileName = [];
        this.showUploadFile=false
        this.showLimitField=false;
       
     
        this.wrapBankObj={};
        this.wrapdocDetailObj={}
        this.isShowModal=false;
       this.showPasswordCol=false;
       this.isFileAvailable=false;
       this.disableFileUpload=false
       this.showFileAvail=true

        
    }
    
    uploadFileLargeVf() {
       
        this.template.querySelector("iframe").contentWindow.postMessage(
            JSON.parse(
                JSON.stringify({
                    source: "lwc",
                    files: this.fileData,
                    parameters: this.DocumentDetaiId,
                    lightningDomain: this.lightningDomainName
                })
            ),
            this.vfUrl
        );
       
    }
    sfdcBnkMasLookup;
    sfdcBnkMastId
    showOtherbankName=false;
    handleValueForSDFCBnk(event){
        this.sfdcBnkMasLookup=event.detail
        let recId= this.sfdcBnkMasLookup.id
        let lookupAPIName = this.sfdcBnkMasLookup.lookupFieldAPIName;
        const outputObj1 = { [lookupAPIName]: recId };
        Object.assign(this.wrapBankObj, outputObj1);
        if(this.sfdcBnkMasLookup.lookupFieldAPIName === 'SFDCBankMaster__c'){
            if(this.sfdcBnkMasLookup.mainField ==='OTHERS'){
                this.showOtherbankName=true
            }else{
                this.showOtherbankName=false
            }
                this.wrapBankObj.SFDCBankMaster__c = recId;
                this.sfdcBnkMastId =recId;
        }
    }


    handleValueSelect(event) {
        this.lookupRec = event.detail;                             
        let lookupId = this.lookupRec.id;
        let lookupAPIName = this.lookupRec.lookupFieldAPIName;

        const outputObj = { [lookupAPIName]: lookupId };
        Object.assign(this.wrapBankObj, outputObj);
        if(this.lookupRec.lookupFieldAPIName === 'BankName__c'){
            this.wrapBankObj.BankId__c = lookupId;
            this.wrapBankObj.BankName__c = this.lookupRec.mainField;
            this.bankId =lookupId;
        }
    }
    handleDelete(event){
        this.showSpinner = false;
        this.showToast("Success", "success",this.label.BankingDetails_Del_SuccesssMessage);
        this.showMessga=true;
        
        this.showaAllTabsAppliDetailData=false;
        this.showApplicantCmp=true;
        console.log('testtt')
        refreshApex(this._wiredApplicantBanking);
        setTimeout(() => {
            if(this.template.querySelector('c-consolidate-appliant-banking-data')!==''&& this.template.querySelector('c-consolidate-appliant-banking-data')!=null && typeof this.template.querySelector('c-consolidate-appliant-banking-data') !=='undefined'){
            
                this.template.querySelector('c-consolidate-appliant-banking-data').refresewireMethods();
            }
            if(this.template.querySelector('c-show-all-banking-detail-consolidate-data')!==''&& this.template.querySelector('c-show-all-banking-detail-consolidate-data')!=null && typeof this.template.querySelector('c-consolidate-appliant-banking-data') !=='undefined'){
            
                this.template.querySelector('c-show-all-banking-detail-consolidate-data').refresewireMethods();
             }
             this.showSpinner = false;
        }, 1000);
        
        
    }
    toRefreshApex(event){
        this.showSpinner = false;
        refreshApex(this._wiredApplicantBanking);
        this.showApplicantCmp=true;
        setTimeout(() => {
            this.template.querySelector('c-consolidate-appliant-banking-data').refresewireMethods();
            this.template.querySelector('c-show-all-banking-detail-consolidate-data').refresewireMethods();
            this.showSpinner = false;
    }, 400);
    }

    handleBankDetailUpdate(event){
        this.AllChildRecords = [...event.detail];
        
    }
    showMessga=true;
    handleCloseConsolidateTable(event){
       
        if(event.detail){
            this.showMessga=false;
        }else{
            this.showMessga=true;
        }

       
        this.showApplicantCmp=false;
        this.showaAllTabsAppliDetailData=false;
    }
    @track showaAllTabsAppliDetailData = false;
    applicantBankingIds;
    @track showSpinner=false;
   
    showApplicantBank(){
        this.showSpinner=false
        this.showApplicantCmp=true;
        setTimeout(() => {
                this.template.querySelector('c-consolidate-appliant-banking-data').refresewireMethods();
        }, 300);
        this.showaAllTabsAppliDetailData=false;
        this.template.querySelector('c-bank-data-table').toCloseViewButtonData();
        setTimeout(() => {
            const test = this.template.querySelector('c-consolidate-appliant-banking-data').checkShowtable();
            
            this.showSpinner=false
            if(!test){
                this.showApplicantCmp=false;
                this.showToast("Error", "error", this.label.BankingDetails_SummaryData_ErrorMessage);
            }else{
                this.showApplicantCmp=true;
               
            }
           
        }, 3000);
    }
    
    showAllAppliBankDetail(){
        this.showaAllTabsAppliDetailData=true;
        this.showSpinner=true
        setTimeout(() => {
                
                console.log('after refresh'+this.template.querySelector('c-show-all-banking-detail-consolidate-data'));
                this.template.querySelector('c-show-all-banking-detail-consolidate-data').refresewireMethods();
            
        }, 300);
         this.showApplicantCmp=false;
        this.template.querySelector('c-bank-data-table').toCloseViewButtonData();
        setTimeout(() => {
            const test = this.template.querySelector('c-show-all-banking-detail-consolidate-data').checkShowtable();
            
            this.showSpinner=false
            if(!test){
                this.showaAllTabsAppliDetailData=false;
                this.showToast("Error", "error",this.label.BankingDetails_ConsolidateData_ErrorMessage);
            }
        }, 3000);
    }
    handleNewFileUpload(event){
        
        refreshApex(this._wiredApplicantBanking);
        
         
    }
    handleNewFileUpload1(event){
        
        refreshApex(this._wiredApplicantBanking);
        setTimeout(() => {
            if(this.template.querySelector('c-bank-data-table') != null){
               this.template.querySelector('c-bank-data-table').handleDisable();
            }
        }, 1000);
         
    }


    // LAK-6286 Paresh
    @track BankCrSalRecordType = 'BankCrSal';
    @track bankCreditFlag=false;
    fetchIncomeDetails() {
    let incDetParams = {
        ParentObjectName: "Applicant_Income__c",
        ChildObjectRelName: "",
        parentObjFields: ["Id","RecordTypeId","Applicant__c"],
        childObjFields: [],
        queryCriteria:  ' where Applicant__c = \'' + this._applicantId + '\' AND RecordType.DeveloperName =\'' + this.BankCrSalRecordType + '\''
        };

        getSobjectDataNonCacheable({params: incDetParams}).then((result) => {
        if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
            this.bankCreditFlag=true;
        }else{
            this.bankCreditFlag=false;
            console.log("No data in income details #1396", data);
            }    
        })
        .catch((error) => {
            console.log('Banking DETAILS #1398',error);
        });
    }
    //LAK-6742 - Account Aggregator
    onClickAccountAggregator(){
        this.showSpinner = true;
        let fieldsOfIntMess = {};
        fieldsOfIntMess['Name'] = 'Initiate Consent'; //serviceName;//'KYC OCR'
        fieldsOfIntMess['BU__c'] = 'HL / STL';
        fieldsOfIntMess['IsActive__c'] = true;
        fieldsOfIntMess['Svc__c'] = 'Initiate Consent'; //serviceName;
        fieldsOfIntMess['Status__c'] = 'New';
        fieldsOfIntMess['MStatus__c'] = 'Blank';
        fieldsOfIntMess['RefObj__c'] = 'Applicant__c';
        fieldsOfIntMess['ParentRefObj__c'] = 'LoanAppln__c';
        fieldsOfIntMess['ParentRefId__c'] =this.loanAppId;
        fieldsOfIntMess['RefId__c'] = this.applicantId;
        const integrationMsgRec={apiName : "IntgMsg__c", fields : fieldsOfIntMess};

        createRecord(integrationMsgRec)
        .then((record) => {
            console.log('record.id'+record.id)
            this.startPolling();
            this.showToast("Success", "success","Link to the customer has been sent successfully.");
            this.hideAggModalBox();
            })
            .catch((err) => {
                this.showSpinner = false;
                console.log('errerrerr'+JSON.stringify(err))
                this.showToast("Error creating Integration record", "error",  error.body.message);
            });

    }
//LAK-6742 - Account Aggregator
    startPolling() {
        this.counter = 0;
        this.aggrInterval = setInterval(() => {
            this.counter += 5;
            this.waitForAggregatorResponse();
        }, 5000);
    }
    waitForAggregatorResponse() {
        try {
            refreshApex(this._wiredApplicantBanking)
            if (this.counter === 60 && !this.parentRecord.TransactionId__c) {
                this.showToast("Error!", "error",'Account Aggregator Failed'); 

                this.showSpinner = false
                clearInterval(this.aggrInterval);

            }
            //this.showSpinner = false
        } catch (e) {
            console.log(e);
        }

    }

    onClickFetchBanking(){
        let fieldsOfIntMess = {};
        fieldsOfIntMess['Name'] = 'Initiate Perfios'; //serviceName;//'KYC OCR'
        fieldsOfIntMess['BU__c'] = 'HL / STL';
        fieldsOfIntMess['IsActive__c'] = true;
        fieldsOfIntMess['Svc__c'] = 'Initiate Transaction'; //serviceName;
        fieldsOfIntMess['Status__c'] = 'New';
        fieldsOfIntMess['Outbound__c'] = true;
        fieldsOfIntMess['RefObj__c'] = 'DocDtl__c';
        fieldsOfIntMess['ParentRefObj__c'] = 'ApplBanking__c';
        fieldsOfIntMess['ParentRefId__c'] ="";
        fieldsOfIntMess['RefId__c'] = "";
        fieldsOfIntMess['LoanAppln__c'] =this._loanAppId;
        fieldsOfIntMess['Appl__c'] = this._applicantId;
        const integrationMsgRec={apiName : "IntgMsg__c", fields : fieldsOfIntMess};

        createRecord(integrationMsgRec)
        .then((record) => {
            console.log('record.id'+record.id)
            this.showToast("Success", "success","Integration to Fetch Banking Details Started Successfully..");
            })
            .catch((err) => {
                console.log('errerrerr'+JSON.stringify(err))
                
            });
    }
    @track uploadType;
    @track showUploadFile;
    @track showFileAvail=true
    handleChangeForManual(event){
        this.uploadType = event.detail.value;
        this.wrapBankObj[event.target.dataset.fieldname] = event.detail.value;
        if(this.uploadType=='Fetch Online Perfios'){
            this.showUploadFile=true;
            this.disableFileUpload=true
            this.wrapBankObj.Is_Statement_password_protected__c=''
            this.wrapBankObj.Password__c=''
            this.wrapBankObj.FileType__c=''
            this.wrapBankObj.FileAvalbl__c=false
            //wrapBankObj.FileAvalbl__c=
           this.isFileAvailable=true;
           this.showFileAvail=true;
           this.wrapBankObj["Source__c"] = "Fetch Online Perfios";
            
        }else{
            this.showUploadFile=false;
            this.disableFileUpload=false
            this.isFileAvailable=false;
           this.wrapBankObj.FileAvalbl__c=false
           this.showFileAvail=false;
           this.wrapBankObj["Source__c"] = "Manual";
        }
    }
    aaplibnkrec;
    checkInstitutionIdForBnk(){
        var params ={
            ParentObjectName:'SFDCBANKMaster__c',
            ChildObjectRelName:'',
            parentObjFields:[  'Id', 'InstitutionId__c'],
            childObjFields:[],        
            queryCriteria: ' where Id= \'' + this.wrapBankObj.SFDCBankMaster__c + '\''
        }
        getSobjectDataNonCacheable({params: params}).then((result) => {
            console.log('resultresultresult'+JSON.stringify(result))
            if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
                if(typeof result.parentRecords[0].InstitutionId__c !=='undefined' && result.parentRecords[0].InstitutionId__c){
                   // return true
                   this.showSpinner=true;
                   this.showFileAvail=true
                   this.createApplicantBankingRecord();
                   this.disabled =true; 


                }else{
                    this.showToast("Error!", "error",this.label.BankDataTable_InstitutionID_Error); 
                    //return false
                }
            }
            })
           .catch((error) => {
             console.log("TECHNICAL PROP LOAN DETAILS #731", error);
       });
    /* if(this.aaplibnkrec.SFDCBankMaster__r.InstitutionId__c!='' && this.aaplibnkrec.SFDCBankMaster__r.InstitutionId__c!=='undefined' && this.aaplibnkrec.SFDCBankMaster__r.InstitutionId__c!=null){
        
        return true
    }else{
        this.showToast("Error!", "error",this.label.BankDataTable_InstitutionID_Error); 
        return false
        
    }*/
    }
    createIntegrationMessageRec(){
       this.showUploadFile=false;
       let fieldsOfIntMess = {};
                fieldsOfIntMess['sobjectType'] = 'IntgMsg__c';
                fieldsOfIntMess['Name'] = 'Generate Link'; //serviceName;//'KYC OCR'
                fieldsOfIntMess['BU__c'] = 'HL / STL';
                fieldsOfIntMess['Status__c'] = 'New';
                fieldsOfIntMess['IsActive__c'] = true;
                fieldsOfIntMess['Svc__c'] = 'Generate Link'; //serviceName;
                fieldsOfIntMess['MStatus__c'] = 'Blank';
                fieldsOfIntMess['RefObj__c'] = 'ApplBanking__c';
                fieldsOfIntMess['RefId__c'] =this.applicantBankingId;
                
                let ChildRecords = [];            
                let upsertData={                       
                    parentRecord:fieldsOfIntMess,                       
                    ChildRecords:ChildRecords,
                    ParentFieldNameToUpdate:''
                }
                console.log('record of message createddddd')
                updateData ({upsertData:upsertData})
                .then(result => {  
                    console.log('resultresultresultresultresult'+JSON.stringify(result))    
                    this.showToast("Success", "success","SMS/email sent to the borrower to fetch bank statement Successfully.");                
                    //this.showToast('Success', "Integration to Fetch Online Perfio Started Successfully.", 'success', 'sticky');
                 }).catch(error => {
                    
                    console.log(error);
                })
                 
        /*var params ={
            ParentObjectName:'ApplBanking__c',
            ChildObjectRelName:'',
            parentObjFields:[  'Id', 'AllDocumentNames__c', 'Password__c','Is_Statement_password_protected__c','SFDCBankMaster__c','SFDCBankMaster__r.InstitutionId__c','Appl__c'],
            childObjFields:[],        
            queryCriteria: ' where Id= \'' + this.applicantBankingId + '\''
        }
        getSobjectDataNonCacheable({params: params}).then((result) => {
            console.log('resultresultresult'+JSON.stringify(result))
            if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
                this.aaplibnkrec = result.parentRecords[0];
                console.log('aaplibnkrec'+JSON.stringify(this.aaplibnkrec))
               if(this.checkInstitutionIdForBnk()){
                let fieldsOfIntMess = {};
                fieldsOfIntMess['sobjectType'] = 'IntgMsg__c';
                fieldsOfIntMess['Name'] = 'Generate Link'; //serviceName;//'KYC OCR'
                fieldsOfIntMess['BU__c'] = 'HL / STL';
                fieldsOfIntMess['Status__c'] = 'New';
                fieldsOfIntMess['IsActive__c'] = true;
                fieldsOfIntMess['Svc__c'] = 'Generate Link'; //serviceName;
                fieldsOfIntMess['MStatus__c'] = 'Blank';
                fieldsOfIntMess['RefObj__c'] = 'ApplBanking__c';
                fieldsOfIntMess['RefId__c'] =this.applicantBankingId;
                
                let ChildRecords = [];            
                let upsertData={                       
                    parentRecord:fieldsOfIntMess,                       
                    ChildRecords:ChildRecords,
                    ParentFieldNameToUpdate:''
                }
                console.log('record of message createddddd')
                updateData ({upsertData:upsertData})
                .then(result => {  
                    console.log('resultresultresultresultresult'+JSON.stringify(result))    
                    this.showToast("Success", "success","Integration to Fetch Online Perfio Started Successfully.");                
                    //this.showToast('Success', "Integration to Fetch Online Perfio Started Successfully.", 'success', 'sticky');
                 }).catch(error => {
                    
                    console.log(error);
                })
                 }
               
             }
            
           })
           .catch((error) => {
             console.log("TECHNICAL PROP LOAN DETAILS #731", error);
       });*/
        
        
    }
    limitValue
    handleFocus(event){
        this.wrapBankObj[event.target.dataset.fieldname] = event.target.value;
        if(event.target.dataset.field == 'Limit__c'){
            const positiveNumberPattern = /^[1-9]\d*$/;
            if(!positiveNumberPattern.test(event.target.value)){
               
                this.template.querySelector('[data-id="limitVal"]').value = '';
                this.showToast("Error", "error", this.customLabel.BankDetails_Limit_ErrorMessage);
                this.wrapBankObj.Limit__c='';
            }else{
                this.wrapBankObj.Limit__c=event.target.value;
                this.limitValue=event.target.value
                
            }
        }

        
    }
}