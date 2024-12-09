import { LightningElement,api,track, wire } from 'lwc';
import getAllData from '@salesforce/apex/SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords';
import getDataForFilterChild from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithFilterRelatedRecords';
import getData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import deleteRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import getDataWithoutCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataWithoutCacheable';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import {subscribe, publish, MessageContext, APPLICATION_SCOPE} from 'lightning/messageService';
import updateData from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import { refreshApex } from '@salesforce/apex';
import APPLBANKING_OBJECT from '@salesforce/schema/ApplBanking__c';
import DOCDETAILID from "@salesforce/schema/DocDtl__c.Id";
import APPOFDOCDET from "@salesforce/schema/DocDtl__c.ApplBanking__c";
import Doc_IS_LAT from "@salesforce/schema/DocDtl__c.IsLatest__c";
import APPID_FIELD from "@salesforce/schema/ApplBanking__c.Id";
import DOCDETAIL_FIELD from "@salesforce/schema/ApplBanking__c.DocumentDetail__c";

import Id from "@salesforce/user/Id";
import { createRecord,updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord, getObjectInfo , getPicklistValuesByRecordType} from 'lightning/uiObjectInfoApi';
// Custom labels
import BankDetails_AccNumCode_ErrorMessage from '@salesforce/label/c.BankDetails_AccNumCode_ErrorMessage';
import BankDetails_RepaymentAcc_ErrorMessage from '@salesforce/label/c.BankDetails_RepaymentAcc_ErrorMessage';
import BankDetails_FileAccptDate_ErrorMessage from '@salesforce/label/c.BankDetails_FileAccptDate_ErrorMessage';
import BankDetails_Limit_ErrorMessage from '@salesforce/label/c.BankDetails_Limit_ErrorMessage';
import BankDetails_BankingDate_ErrorMessage from '@salesforce/label/c.BankDetails_BankingDate_ErrorMessage';
import BankDetails_SalaryAcc_ErrorMessage from '@salesforce/label/c.BankDetails_SalaryAcc_ErrorMessage';
import BankDetails_StartPeriod_ErrorMessage from '@salesforce/label/c.BankDetails_StartPeriod_ErrorMessage';
import BankDetails_EndPeriod_ErrorMessage from '@salesforce/label/c.BankDetails_EndPeriod_ErrorMessage';
import BankDetails_Statement_ErrorMessage from '@salesforce/label/c.BankDetails_Statement_ErrorMessage';
import BankDetails_ReqFields_ErrorMessage from '@salesforce/label/c.BankDetails_ReqFields_ErrorMessage';
import BankDetails_EndDate_ErrorMessage from '@salesforce/label/c.BankDetails_EndDate_ErrorMessage';
import BankDetails_Update_SuccessMessage from '@salesforce/label/c.BankDetails_Update_SuccessMessage';
import BankDetails_RepaymentAcc_ReqErrorMessage from '@salesforce/label/c.BankDetails_RepaymentAcc_ReqErrorMessage';
import Legal_Property_Future_Date from '@salesforce/label/c.Legal_Property_Future_Date';
import showAllDetailsNoFileError from '@salesforce/label/c.showAllDetailsNoFileError';
import BankingDetailsAccountType_Error from '@salesforce/label/c.BankingDetailsAccountType_Error';
import BankingDetailsSavingAccontError from '@salesforce/label/c.BankingDetailsSavingAccontError';
import { NavigationMixin } from 'lightning/navigation';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import SheetJS1 from '@salesforce/resourceUrl/SheetJS1';
import getJsonToExcelMetadata from '@salesforce/apex/ExcelDataToJsonApexClass.getJsonToExcelMetadataForAppliBank';
import jsonExcelMetadataForAppliDetail from '@salesforce/apex/ExcelDataToJsonApexClass.MetadataForAppliBankDetail';
import CreateDocumentLink from '@salesforce/apex/ExcelDataToJsonApexClass.CreateDocumentLink';
import createDocumentDetail from "@salesforce/apex/DocumentDetailController.createDocumentDetail";
import uploadExcelFile from '@salesforce/apex/ExcelDataToJsonApexClass.uploadExcelFile';
import getAllDocDetaRecs from '@salesforce/apex/ExcelDataToJsonApexClass.getAllDocDetaRecs';
let XLS = {};
import DOCID from "@salesforce/schema/DocDtl__c.Id";
import DOCNAME from "@salesforce/schema/DocDtl__c.DocSubTyp__c";

export default class ShowAllBankDetails extends NavigationMixin(LightningElement) {
    customLabel ={
        BankDetails_AccNumCode_ErrorMessage,
        BankDetails_RepaymentAcc_ErrorMessage,
        BankDetails_FileAccptDate_ErrorMessage,
        BankDetails_Limit_ErrorMessage,
        BankDetails_BankingDate_ErrorMessage,
        BankDetails_SalaryAcc_ErrorMessage,
        BankDetails_StartPeriod_ErrorMessage,
        BankDetails_EndPeriod_ErrorMessage,
        BankDetails_Statement_ErrorMessage,
        BankDetails_ReqFields_ErrorMessage,
        BankDetails_EndDate_ErrorMessage,
        BankDetails_Update_SuccessMessage,
        BankDetails_RepaymentAcc_ReqErrorMessage,
        Legal_Property_Future_Date,
        showAllDetailsNoFileError,
        BankingDetailsAccountType_Error,
        BankingDetailsSavingAccontError

    }
    userId = Id;
   
    @track activeSection = ["A", "C"];
    @track showSpinner = false;
    @api hasEditAccess;
    @track parentRecord = {};
    wrapBankObj={};
    @track accountTypeCCndOD=false;
    _applicantRecordId;
    repaymentOptions

    limitValue=0;
    changeinLimitOptions
    periodBankingStart
    bankingDetailDataList;
    periodBankingEnd
    @api loginAcceDate;
    @api fileAcceptanceDate;
    @api bankCreditFlag;
    eNACHfeasibleReqOptions
    repaymentAccList;
    _allAppliBnkRecs;
    _stageOfLoanApp
    changeLimitInPeriVal='No'

    _custProfile
    @api get custProfile() {
        return this._custProfile;
    }
    set custProfile(value) {
       
        this._custProfile = value;    
                 
    }

    @api get allAppliBnkRecs() {
        return this._allAppliBnkRecs;
    }
    set allAppliBnkRecs(value) {
        
        this._allAppliBnkRecs = value;  
                         
    }

    @api get stageOfLoanApp() {
        return this._stageOfLoanApp;
    }
    set stageOfLoanApp(value) {
        this._stageOfLoanApp = value; 

    }

    
    _reqLoanAmount;
    _assessedIncApp
    @api get reqLoanAmount() {
        return this._reqLoanAmount;
    }
    set reqLoanAmount(value) {
        
        this._reqLoanAmount = value;                   
    }
    @api get assessedIncApp() {
        return this._assessedIncApp;
    }
    set assessedIncApp(value) {
       
        this._assessedIncApp = value;                   
    }
    sisCompanyShow=false;
    

    _loanApplicantId;
    @api
    get loanApplicantId(){
        return this._loanApplicantId;
    }

    set loanApplicantId(value){
        this._loanApplicantId = JSON.parse(JSON.stringify(value));
        
            this.paramsforRep ={
                ParentObjectName:'LoanAppl__c',
                ChildObjectRelName:'Applicant_Banking1__r',
                parentObjFields:[  'Id','SubStage__c','Stage__c', 'OwnerId'],
                childObjFields:[  'Id', 'Appl__c','eNACHFeasible__c','ConsideredForABBProgram__c','NACHFeasible__c','SFDCBankMaster__r.BankName__c','LoanAppl__c','IFSC_Code__c','Limit__c', 'Name_of_the_Primary_Account_Holder_s__c', 'OtherBankName__c', 'AccountType__c', 'FileType__c', 'SalaryAccount__c', 'DocumentDetail__c', 'BankName__c', 'BankId__c', 'JointAccountHoldersName__c', 'AC_No__c', 'IsThereChangeInLimitDuringThePeri__c', 'AverageLimitDuringThePeriod__c', 'LatestMonthForWhichBankStatementIs__c', 'PeriodOfBankingStart__c', 'PeriodOfBankingEnd__c','Bank_City__c', 'Repayment_bank_A_c__c', 'Bank_Branch__c', 'MICR_Code__c','Appl__r.CustProfile__c', 'eNACH_feasible__c'],
                queryCriteria: ' where Id= \'' + this._loanApplicantId + '\''
        }
    }
    @track paramsforRep    
 
    @api get applicantRecordId() {
        return this._applicantRecordId;
    }
    
    set applicantRecordId(value) {
        
        this._applicantRecordId = value;
        this.setAttribute("applicantRecordId", value);            
        this.handleRecordIdChange(); 
        this.handleRecordIdChange1();
        this.showBankingSummaryData = false;   
    }
    
    get monthLimitDis() {
        return this.monthlyLimitReDis || this.disableMode;
    }
    accTypeOptions=[]
    FileTypeOptions=[];
    isPassProtecOpt=[];
    considerABBOptions=[]
    @track showDocuPassCol;
    @wire(getObjectInfo, { objectApiName:  APPLBANKING_OBJECT})
    objectInfo

    @wire(getPicklistValuesByRecordType, {
        objectApiName: APPLBANKING_OBJECT,
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    })picklistHandler({ data, error }){
        if(data){
            this.accTypeOptions = [...this.generatePicklist(data.picklistFieldValues.AccountType__c)]
            this.repaymentOptions = [...this.generatePicklist(data.picklistFieldValues.Repayment_bank_A_c__c)]
            this.changeinLimitOptions = [...this.generatePicklist(data.picklistFieldValues.IsThereChangeInLimitDuringThePeri__c)]
            this.considerABBOptions = [...this.generatePicklist(data.picklistFieldValues.ConsideredForABBProgram__c)]
            this.eNACHfeasibleReqOptions = [...this.generatePicklist(data.picklistFieldValues.eNACH_feasible__c)]
            this.FileTypeOptions = [...this.generatePicklist(data.picklistFieldValues.FileType__c)]
            this.isPassProtecOpt=[...this.generatePicklist(data.picklistFieldValues.Is_Statement_password_protected__c)]
            
        }
        if (error) {
           
        }
    }

    @track params ={

        ParentObjectName:'ApplBanking__c',
        ChildObjectRelName:'Applicant_Banking_Detail__r',
        parentObjFields:[  'Id','Source_Type__c', 'Source__c','EMIPaidFromThisAccount__c','AccountOf__c','AllDocumentNames__c','FileAvalbl__c','Appl__c','Appl__r.FullName__c', 'Password__c','Is_Statement_password_protected__c','Appl__r.Constitution__c','SisterCompanyName__c','AccountOpenDate__c','ConsideredForABBProgram__c','Bank_Code__c','MICRId__c','PDC_by_Name__c','eNACHFeasible__c','SFDC_Bank_Master_Name__c','NACHFeasible__c','SFDCBankMaster__r.BankName__c','SFDCBankMaster__r.NACHFeasible__c','SFDCBankMaster__r.ENACHFeasible__c','LoanAppl__c','IFSC_Code__c','Limit__c', 'Name_of_the_Primary_Account_Holder_s__c', 'OtherBankName__c', 'AccountType__c', 'FileType__c', 'SalaryAccount__c', 'DocumentDetail__c','BankName__c', 'BankId__c', 'JointAccountHoldersName__c', 'AC_No__c', 'IsThereChangeInLimitDuringThePeri__c', 'AverageLimitDuringThePeriod__c', 'LatestMonthForWhichBankStatementIs__c', 'PeriodOfBankingStart__c', 'PeriodOfBankingEnd__c','Bank_City__c', 'Repayment_bank_A_c__c', 'Bank_Branch__c', 'MICR_Code__c','Appl__r.CustProfile__c', 'eNACH_feasible__c'],
        childObjFields:['ApplBanking__c','Monthend__c','Average_Daily_Bank_Balance__c', 'DailyABBBalance__c','MonthlyLimit__c','Utilization__c','Id', 'Name', 'Month__c', 'Year__c', 'ValueSummationCredit__c', 'ValueSummationDebit__c', 'CountofCredit__c', 'CountofDebit__c', 'InwardReturnsCount__c', 'OutwardReturnsCount__c', 'StopPaymentCount__c', 'MinBalanceCharges__c', 'BalanceAt_1st__c', 'BalanceAt_5th__c', 'BalanceAt_10th__c', 'BalanceAt_15th__c', 'BalanceAt_20th__c', 'BalanceAt_25th__c', 'AverageBankBalance__c'],        
        queryCriteriaForChild: ' WHERE Type__c IN (\'\', \'Account Analysis\') AND SubType__c IN (\'\', \'Monthly Details\')',
        queryCriteria: ' where Id= \'' + this._applicantRecordId + '\' AND IsDeleted__c != true'
    }
    @track paramForLatDoc={
        ParentObjectName:'DocDtl__C',
        ChildObjectRelName:null,
        parentObjFields:['Id', 'ApplBanking__c','DocCatgry__c','IsLatest__c'],
        childObjFields:[],        
        queryCriteria: ' where ApplBanking__c= \'' + this._applicantRecordId + '\' AND DocCatgry__c = \'Perfios Report\' AND IsLatest__c  = True'
    }
    
    
    handleRecordIdChange(){        
        let tempParams = this.params;
        tempParams.queryCriteria = ' where Id = \'' + this._applicantRecordId + '\'';
        this.params = {...tempParams};
        

    }
    handleRecordIdChange1(){        
        let tempParams1 = this.paramForLatDoc;
        tempParams1.queryCriteria = ' where ApplBanking__c= \'' + this._applicantRecordId + '\' AND DocCatgry__c = \'Perfios Report\' AND IsLatest__c  = True'
        this.paramForLatDoc = {...tempParams1};

    }

    _wiredApplicantBanking
    AllChildRecords
    ChildReords
    showOtherField=false;
    
    RepaymentValYes=false;
    isRequired =false;
    showConiForAbb=false;
    monthlyLimitReDis=false;
    ContentDocId;
    documentPassReq=false;
    repaymentPareVal;
    @track sourceOfAppliBank;
    @track showSorceTypeFields;
    @api layoutSize
    nachVal;
    enachVal;
    considerAbbVal
    @api toRefreshApexMethod(){
        refreshApex(this._wiredApplicantBanking);
    }
    DocumentDetailId;
    
    @wire(getDataForFilterChild,{params:'$params'})
    loadApplicantBanking(wiredApplicantBanking) {
        const { data, error } = wiredApplicantBanking;
        this._wiredApplicantBanking = wiredApplicantBanking;
       
        this.parentRecord={}
        this.parRecConVer={}
        if (data) {
            
            this.wrapBankObj.Id = this._applicantRecordId;
           
            this.parentRecord=JSON.parse(JSON.stringify(data.parentRecord)); 
            this.sourceOfAppliBank=this.parentRecord.Source__c;
            this.DocumentDetailId=this.parentRecord.DocumentDetail__c;
            if(this.parentRecord.Source_Type__c !=='Account Aggregator'  && this.parentRecord.Source__c!='Fetch Online Perfios' &&  this.parentRecord.Source_Type__c!='Fetch Online Perfios'){
                this.showSorceTypeFields=false;
            }else{
                this.showSorceTypeFields=true;
            }
            this.template.querySelector('[data-id="repayCombo"]').value=this.parentRecord.Repayment_bank_A_c__c
            this.repaymentPareVal=this.parentRecord.Repayment_bank_A_c__c
            this.wrapBankObj.Repayment_bank_A_c__c=this.parentRecord.Repayment_bank_A_c__c
            
           //this.template.querySelector('[data-id="consiBbb"]').value=this.parentRecord.ConsideredForABBProgram__c
            this.considerAbbVal=this.parentRecord.ConsideredForABBProgram__c
            this.wrapBankObj.ConsideredForABBProgram__c=this.parentRecord.ConsideredForABBProgram__c
            this.wrapBankObj.LatestMonthForWhichBankStatementIs__c=this.parentRecord.LatestMonthForWhichBankStatementIs__c
            
            if(typeof this.parentRecord.SFDCBankMaster__c !== 'undefined'){
                if(typeof this.parentRecord.SFDCBankMaster__r.ENACHFeasible__c !== 'undefined'){
                    this.enachVal=this.parentRecord.SFDCBankMaster__r.ENACHFeasible__c
                   
                }
                if(typeof this.parentRecord.SFDCBankMaster__r.NACHFeasible__c !== 'undefined'){
                    this.nachVal=this.parentRecord.SFDCBankMaster__r.NACHFeasible__c
                    
                }
            }
            
            if(this.parentRecord.Is_Statement_password_protected__c =='Yes'){
                this.documentPassReq=true
                this.showDocuPassCol=true
            }else{
                this.documentPassReq=false
                this.showDocuPassCol=false
            }
            if(typeof this.parentRecord.PDC_by_Name__c !== 'undefined'){
                this.parentRecord.PDC_by_Name__c=this.parentRecord.PDC_by_Name__c.toUpperCase();
            }
            if(typeof this.parentRecord.SisterCompanyName__c !== 'undefined'){
                this.parentRecord.SisterCompanyName__c=this.parentRecord.SisterCompanyName__c.toUpperCase();
            }
            if(typeof this.parentRecord.OtherBankName__c !== 'undefined'){
                this.parentRecord.OtherBankName__c=this.parentRecord.OtherBankName__c.toUpperCase();
            }
            if(typeof this.parentRecord.Password__c !== 'undefined'){
              
            }
            if(typeof this.parentRecord.MICR_Code__c !== 'undefined'){
                this.wrapBankObj.MICR_Code__c=this.parentRecord.MICR_Code__c
            }
            
            if(typeof this.parentRecord.Name_of_the_Primary_Account_Holder_s__c !== 'undefined'){
                this.parentRecord.Name_of_the_Primary_Account_Holder_s__c=this.parentRecord.Name_of_the_Primary_Account_Holder_s__c.toUpperCase();
            }
            else{
                
                if(typeof this.parentRecord.Appl__r.FullName__c !== 'undefined'){
                    this.parentRecord.Name_of_the_Primary_Account_Holder_s__c=this.parentRecord.Appl__r.FullName__c.toUpperCase();
                    this.wrapBankObj.Name_of_the_Primary_Account_Holder_s__c=this.parentRecord.Appl__r.FullName__c.toUpperCase();
                }else{
                    this.parentRecord.Name_of_the_Primary_Account_Holder_s__c='';
                    this.wrapBankObj.Name_of_the_Primary_Account_Holder_s__c='';
                }
            }
            if(typeof this.parentRecord.JointAccountHoldersName__c !== 'undefined'){
                this.parentRecord.JointAccountHoldersName__c=this.parentRecord.JointAccountHoldersName__c.toUpperCase();
            }
            if(this.parentRecord.Appl__r.Constitution__c!='INDIVIDUAL' && (this.parentRecord.Appl__r.CustProfile__c == 'SELF EMPLOYED NON PROFESSIONAL'|| this.parentRecord.Appl__r.CustProfile__c == 'SELF EMPLOYED PROFESSIONAL')){
                this.sisCompanyShow=true
            }else{
                this.sisCompanyShow=false
            }
            if(this.parentRecord.Repayment_bank_A_c__c =='Yes'){
                this.RepaymentValYes=true
            }else{
                this.RepaymentValYes=false
            }
           
            if(this.parentRecord.SFDC_Bank_Master_Name__c=='OTHERS'){
                this.showOtherField=true
            }else{
                this.showOtherField=false
            }
            
            if(this.parentRecord.AccountType__c === 'CC' || this.parentRecord.AccountType__c === 'OVERDRAFT' ){
                this.accountTypeCCndOD=true;
                this.monthlyLimitReDis=true
                if(typeof this.parentRecord.Limit__c !== 'undefined'){
                    this.limitValue=this.parentRecord.Limit__c;
                   
                }else{
                    this.limitValue=0
                }
            }else{
                this.accountTypeCCndOD=false;
                this.monthlyLimitReDis=false
                
            } 
            if(typeof this.parentRecord.PeriodOfBankingStart__c !== 'undefined'){
                this.periodBankingStart=this.parentRecord.PeriodOfBankingStart__c
            }else{
                this.periodBankingStart='';
            }
            if(typeof this.parentRecord.PeriodOfBankingEnd__c !== 'undefined'){
                this.periodBankingEnd=this.parentRecord.PeriodOfBankingEnd__c
                this.wrapBankObj.PeriodOfBankingEnd__c=this.periodBankingEnd
            }else{
                this.periodBankingEnd='';
                this.wrapBankObj.PeriodOfBankingEnd__c=this.periodBankingEnd
            }
            if(this.parentRecord.AccountType__c === 'SAVINGS' || this.parentRecord.AccountType__c === 'CURRENT' ){
               
                this.checkReqAmouAsseIncApp();
            }else{
                
                this.showConiForAbb=false;
            }
            
            this.changeLimitInPeriVal=this.parentRecord.IsThereChangeInLimitDuringThePeri__c
            if(this.changeLimitInPeriVal=='No'){
                this.limitShow=true
            }else{
                this.limitShow=false
            }
            
            if(data.ChildReords && data.ChildReords != undefined){
                this.ChildReords=JSON.parse(JSON.stringify(data.ChildReords));
                
               this.AllChildRecords = [...this.ChildReords];
               this.bankingDetailDataList=this.AllChildRecords;
               
            }else{
                this.ChildReords = [];
                this.AllChildRecords = [];
                this.bankingDetailDataList=this.AllChildRecords
                
            }
            this.getAllDataOfBanking();
        } else if (error) {
          
        }
    }
    checkReqAmouAsseIncApp(){
        if(this._reqLoanAmount>2500000 && this._assessedIncApp=='No'){
            
            this.showConiForAbb=true;
        }else{
            
            this.showConiForAbb=false;
        }
    }
    
    getAllDataOfBanking(){
        var paramForBnking ={
            ParentObjectName:'Applicant__c',
            ChildObjectRelName:'Applicant_Banking1__r',
            parentObjFields:['Id','CustProfile__c', 'Constitution__c'],
            childObjFields:['Id','AccountType__c'],        
            queryCriteria: ' where Id= \'' + this.parentRecord.Appl__c + '\''
        }
        let allBnkingIds=[];
        getDataWithoutCacheable({ params: paramForBnking })
            .then((result) => {
                //console.log('result>>>>>>>>>>>>>>'+JSON.stringify(result))
                result.forEach(item => {
                    if(item.ChildReords && item.ChildReords !== undefined){
                        item.ChildReords.forEach(chiRec => {
                            if(chiRec.IsDeleted__c != true){
                                if(chiRec.AccountType__c ==='CC'|| chiRec.AccountType__c ==='OVERDRAFT' || chiRec.AccountType__c ==='JOINT'|| chiRec.AccountType__c ==='SAVINGS' || chiRec.AccountType__c ==='CURRENT'){
                                    allBnkingIds.push(chiRec.Id);
                                }
                            }
                           
                        }) 
                    }
                }) 
               // console.log('allBnkingIdsallBnkingIds'+allBnkingIds)
                this.getbnkingDetail(allBnkingIds);
                
                
            })
            .catch((err) => {
                console.log('result'+err)
            })
    }
    listOfAllBnkDetRec;
    getbnkingDetail(allBnkingIds){
        var paramForBnking ={
            ParentObjectName:'ApplBanking__c',
            ChildObjectRelName:'Applicant_Banking_Detail__r',
            parentObjFields:[  'Id'],
            childObjFields:['ApplBanking__c', 'Month__c', 'Year__c'],        
            queryCriteria:' WHERE ID IN (\''+allBnkingIds.join('\', \'') + '\') AND Type__c = \'\''
        }
        let allBnkingDetailData=[];
        getDataWithoutCacheable({ params: paramForBnking })
            .then((result) => {
               // console.log('result>>>>>>>>>>>>>>'+JSON.stringify(result))
                result.forEach(item => {
                    if(item.ChildReords && item.ChildReords !== undefined){
                        item.ChildReords.forEach(chiRec => {
                            const key = `${chiRec.Month__c}-${chiRec.Year__c}-${chiRec.Id}`;
                            allBnkingDetailData.push(key);
                        }) 
                    }
                }) 
               /* const uniqueValues = Object.keys(uniqueValuesMap);
                console.log('uniqueValuesSet'+JSON.stringify(uniqueValues))*/
                this.listOfAllBnkDetRec=allBnkingDetailData
                
                
                
            })
            .catch((err) => {
                console.log('result'+err)
            })
    }

    
    _wiredDocDetailData;
    DocDetailRecLat;
    fileToDownload=false;
    @wire(getData,{params:'$paramForLatDoc'})
    DocDetailDataWireMethod(wiredDocDetailData) {
        const { data, error } = wiredDocDetailData;
        this._wiredDocDetailData = wiredDocDetailData;
       
        if (data) {
            
            if(typeof data.parentRecord!=='undefined'){
                this.DocDetailRecLat=JSON.parse(JSON.stringify(data.parentRecord)); 
               
                var docDetailId=this.DocDetailRecLat.Id
                let params ={
                    ParentObjectName:'ContentDocumentLink',
                    ChildObjectRelName:'',
                    parentObjFields:['ContentDocumentId','LinkedEntityId'],
                    childObjFields:[],        
                    queryCriteria: ' where LinkedEntityId= \'' + docDetailId + '\''
                    }
                getSobjectData({ params: params })
                .then((data) => {
                   
                    var docDeailReConDoc=JSON.parse(JSON.stringify(data.parentRecords));
                    var listOfContentDocumentIds=[]
                    for(const record of docDeailReConDoc){
                        listOfContentDocumentIds.push(record.ContentDocumentId);
                    }
                    
                    if(listOfContentDocumentIds.length>0){
                        this.contentVerRecords(listOfContentDocumentIds)
                    }
                })
                .catch(error => {
                   
                    
                });
            }else{
               
                this.fileToDownload=false
            }
            
        } else if (error) {
           
        }
    }
    parentRecsOfConVer;
    ContentDocumentId;
    contentVerRecords(listOfContentDocumentIds){
        let paramsForCon ={
            ParentObjectName:'ContentVersion',
            ChildObjectRelName:'',
            parentObjFields:['Id','ContentDocumentId','FileExtension'],
            childObjFields:[],        
            queryCriteria: ' WHERE ContentDocumentId IN (\''+listOfContentDocumentIds.join('\', \'') + '\')'
        }
        getSobjectData({ params: paramsForCon })
        .then((data) => {
            
            this.parentRecsOfConVer=JSON.parse(JSON.stringify(data.parentRecords));
            if(this.parentRecsOfConVer.length > 0){
                this.ContentDocumentId=this.parentRecsOfConVer[0].ContentDocumentId;
                this.fileToDownload=true;
            }
        })
        .catch(error => {
          
        });
    }


    _wiredApplicantRecData;
    downloadFileDis
    considerForABBList
    @wire(getData,{params:'$paramsforRep'})
    applicanRecorDataBanking(wiredApplicantRecData) {
        const { data, error } = wiredApplicantRecData;
        this._wiredApplicantRecData = wiredApplicantRecData;
       
        const repayAccYesList=[]

        if (data) {
           const allRecoAppBn=[]
           
           const parentRecord=JSON.parse(JSON.stringify(data.parentRecord));
           this.downloadFileDis= this.hasEditAccess ? true: false;//LAK-10716
           this.repaymentAccList=data.ChildReords && data.ChildReords != undefined ? data.ChildReords.filter (record => record.Repayment_bank_A_c__c=== 'Yes' && record.IsDeleted__c !=true) : []
            this.considerForABBList=data.ChildReords && data.ChildReords != undefined ? data.ChildReords.filter (record => record.ConsideredForABBProgram__c=== 'Yes' && record.IsDeleted__c !=true) : []
            console.log(' this.considerForABBList'+ this.considerForABBList)
           
           
        } else if (error) {
           console.log('errorerrorerrorerror',error)
        }
    }
    
    


    generatePicklist(data) {
        return data.values.map(item => ({ "label": item.label, "value": item.value }))
    }
    requiredForIfsc;
    reuiredforRepay=false;
    IfStageIsDDE=false;

    async connectedCallback(){

        await loadScript(this, SheetJS1); // load the library
        // At this point, the library is accessible with the `XLSX` variable
        this.version = XLSX.version;
        console.log('version: '+this.version);  
        this.activeSection = ["A", "C"];

      
       
        if(this.hasEditAccess === false){
            this.disableMode = true;

      }else{
             this.disableMode = false;
      }
        
        if(this._stageOfLoanApp == 'DDE' ){
            this.IfStageIsDDE=true
          
        }else{
            this.IfStageIsDDE=false
        }
        if(this._stageOfLoanApp == 'UnderWriting' ){
            this.reuiredforRepay=true
            //this.isRequired=true;
        }else{
            this.reuiredforRepay=false
            
        }
        if(this._stageOfLoanApp != 'QDE' && this._stageOfLoanApp != 'DDE' ){
            this.requiredForIfsc=true
        }else{
            this.requiredForIfsc=false
        }
       this.scribeToMessageChannel();

       /* setTimeout(() => {
                        this.handleBankingSummaryData()
                    }, 1000);*/
        refreshApex(this._wiredApplicantRecData); 
    }
    
    showBankingSummaryData = false;
    @track serPeriodBankingStart;
  
       handleBankingSummaryData(){
        
        this.showBankingSummaryData = true;
        let lengthOfList = this.bankingDetailDataList.length;
        
        if(this.periodBankingStart && this.periodBankingEnd){
            
                if(this.checkValidationForStartDate()&& this.checkValidationForEndDate()){
                   
                    this.calculateDateDifference();
                    
                    setTimeout(() => {
                        if(this.template.querySelector('c-banking-summary-data') != null){
                           
                            this.template.querySelector('c-banking-summary-data').addAppliBankRow( this.applicantRecordId,this.monthandYearList);
                        }
                    }, 1000);
                       
                }else{
                    
                    this.showBankingSummaryData = false;
                }
            }else{
                    this.calculateDateDifference();
                     
                     setTimeout(() => {
                        if(this.template.querySelector('c-banking-summary-data') != null){
                            this.template.querySelector('c-banking-summary-data').addAppliBankRow( this.applicantRecordId,this.monthandYearList);
                        }
                    }, 500);
        }
        
    }
    @api toClosebankingSummary(){
        this.showBankingSummaryData=false;
    }
    handleConVerData(event){
        this.wrapObjConver[event.target.dataset.field] = event.target.value;
       
    }
    @track limitShow=false;
    handleAccountData(event) {
       
        this.wrapBankObj[event.target.dataset.field] = event.target.value;
        if (event.target.dataset.fieldtype === 'string') {
            let strVal = event.target.value;
            this.wrapBankObj[event.target.dataset.field] = strVal.toUpperCase();
            this.parentRecord[event.target.dataset.field] = strVal.toUpperCase();
        }
        
        
        if(event.target.dataset.field == 'AC_No__c'){
            if(event.target.value !=''&& event.target.value !=null){
                var valueForTest=parseFloat(event.target.value)
                 if(!isNaN(valueForTest)){
                }else{
                    
                    this.wrapBankObj.AC_No__c='';
                    this.parentRecord.AC_No__c='';
                    this.showToast("Error", "error", this.customLabel.BankDetails_AccNumCode_ErrorMessage,"sticky");
                }
                
            }
        }else if(event.target.dataset.field == 'AccountOpenDate__c'){
            var selectedDate = event.target.value;
            const selectedDateTime = new Date(selectedDate).getTime();
           
            const currentDateTime = new Date().toISOString().split('T')[0]
            if (selectedDate > currentDateTime) {
                this.template.querySelector('[data-id="opendata"]').value = '';
                this.wrapBankObj.AccountOpenDate__c=''
                this.showToast("Error", "error", this.customLabel.Legal_Property_Future_Date,"sticky");
            }
        }
        else if(event.target.dataset.field == 'AccountType__c'){
            
            var accountTypeVal=event.target.value;
            //logic for LAK-6105- only allow CC/OD/CURRENT bank statement upload for NON INDIVIDUAL customer except PROPERITORSHIP and HUF cases start
            if(this.parentRecord.Appl__c && typeof this.parentRecord.Appl__r.Constitution__c !=='undefined'){
                if(this.parentRecord.Appl__r.Constitution__c =='HUF' || this.parentRecord.Appl__r.Constitution__c =='INDIVIDUAL' || this.parentRecord.Appl__r.Constitution__c=='PROPERITORSHIP'){
                   if(this.parentRecord.Appl__r.Constitution__c =='HUF' || this.parentRecord.Appl__r.Constitution__c=='PROPERITORSHIP'){
                      /* if(accountTypeVal == 'CC' ||  accountTypeVal == 'OVERDRAFT' || accountTypeVal== 'CURRENT'){
                           this.template.querySelector('[data-id="accType"]').value=this.parentRecord.AccountType__c
                           accountTypeVal=this.parentRecord.AccountType__c
                            this.wrapBankObj.AccountType__c=this.parentRecord.AccountType__c
                            this.showToast("Error!", "error",this.customLabel.BankingDetailsSavingAccontError);
                           }*/
                    }
                }else{
                   
                    
                    if(accountTypeVal == 'CC' ||  accountTypeVal == 'OVERDRAFT' || accountTypeVal== 'CURRENT'){
    
                    }else{
                        this.template.querySelector('[data-id="accType"]').value=this.parentRecord.AccountType__c
                        accountTypeVal=this.parentRecord.AccountType__c
                        this.wrapBankObj.AccountType__c=this.parentRecord.AccountType__c
                        this.showToast("Error!", "error",this.customLabel.BankingDetailsAccountType_Error);
                    }
                }
            }
           
            //End



            if(accountTypeVal === 'CC' || accountTypeVal === 'OVERDRAFT' ){
                this.accountTypeCCndOD=true;
                this.monthlyLimitReDis=true
            }else{
                this.accountTypeCCndOD=false;
                this.monthlyLimitReDis=false
                
            }
            if(accountTypeVal === 'SAVINGS' || accountTypeVal === 'CURRENT'){
                this.checkReqAmouAsseIncApp();
            }else{
                this.showConiForAbb=false;
            }
            if(this.RepaymentValYes==true && this.accountTypeCCndOD==true){
                this.parentRecord.eNACHFeasible__c='No';
                this.parentRecord.NACHFeasible__c='No'
            }else{
                this.parentRecord.eNACHFeasible__c=this.enachVal;
                this.parentRecord.NACHFeasible__c=this.nachVal;
            }
        }
        else if(event.target.dataset.field == 'Name_of_the_Primary_Account_Holder_s__c'){
            this.parentRecord.Name_of_the_Primary_Account_Holder_s__c=event.target.value.toUpperCase()
            this.wrapBankObj.Name_of_the_Primary_Account_Holder_s__c=event.target.value.toUpperCase();
            
        }
        else if(event.target.dataset.field == 'Is_Statement_password_protected__c'){
            if(event.target.value === 'Yes'){
                this.documentPassReq=true;
                this.showDocuPassCol=true
            }else{
                this.documentPassReq=false;
                this.showDocuPassCol=false;
                
            }
            
        }
        else if(event.target.dataset.field == 'JointAccountHoldersName__c'){
            this.parentRecord.JointAccountHoldersName__c=event.target.value.toUpperCase()
            this.wrapBankObj.JointAccountHoldersName__c=event.target.value.toUpperCase();
            
        }
        else if(event.target.dataset.field == 'PDC_by_Name__c'){
            this.parentRecord.PDC_by_Name__c=event.target.value.toUpperCase()
            this.wrapBankObj.PDC_by_Name__c=event.target.value.toUpperCase();
            
        }
        else if(event.target.dataset.field == 'SisterCompanyName__c'){
            this.parentRecord.SisterCompanyName__c=event.target.value.toUpperCase()
            this.wrapBankObj.SisterCompanyName__c=event.target.value.toUpperCase();
            
        }
        else if(event.target.dataset.field == 'OtherBankName__c'){
            this.parentRecord.OtherBankName__c=event.target.value.toUpperCase()
            this.wrapBankObj.OtherBankName__c=event.target.value.toUpperCase();
            
        }
        else if(event.target.dataset.field == 'Password__c'){
          
            
        }
        else if(event.target.dataset.field == 'PeriodOfBankingStart__c'){
            
            this.periodBankingStart=event.target.value;
            this.handlePeriodBankingStart();
        }
        else if(event.target.dataset.field == 'PeriodOfBankingEnd__c'){
            this.periodBankingEnd=event.target.value;
            this.handlePeriodBankingEnd();
        }
        else if(event.target.dataset.field == 'Repayment_bank_A_c__c'){
            
            if(event.target.value =='Yes' &&  this.repaymentAccList.length>0 && this.repaymentPareVal=='No'){
                this.wrapBankObj.Repayment_bank_A_c__c='No';
                this.parentRecord.Repayment_bank_A_c__c='No';
                this.showToast("Error", "error", this.customLabel.BankDetails_RepaymentAcc_ErrorMessage);
                this.template.querySelector('[data-id="repayCombo"]').value = 'No';
                this.RepaymentValYes=false
            }
            else if(event.target.value =='Yes' &&  this.repaymentAccList.length==0){
                this.RepaymentValYes=true
            }
            else if(event.target.value =='Yes' &&  this.repaymentAccList.length>0 && this.repaymentPareVal=='Yes'){
                this.RepaymentValYes=true
            }
            else{
                this.RepaymentValYes=false
            }
            if(this.RepaymentValYes==true && this.accountTypeCCndOD==true){
                this.parentRecord.eNACHFeasible__c='No';
                this.parentRecord.NACHFeasible__c='No'
            }else{
                this.parentRecord.eNACHFeasible__c=this.enachVal;
                this.parentRecord.NACHFeasible__c=this.nachVal;
            }
            
        }
        else if(event.target.dataset.field == 'ConsideredForABBProgram__c'){
            
            if(event.target.value =='Yes' &&  this.considerForABBList.length > 2 && (this.considerAbbVal=='No' || typeof this.considerAbbVal ==='undefined')){
                this.wrapBankObj.ConsideredForABBProgram__c='No';
                this.parentRecord.ConsideredForABBProgram__c='No';
                this.showToast("Error", "error", 'Only 3 Accounts can be selected as Consider for Abb Program.');
                this.template.querySelector('[data-id="consiBbb"]').value = 'No';
            }else if(event.target.value =='Yes' &&  this.considerForABBList.length==2){
                
            }
            else if(event.target.value =='Yes' &&  this.repaymentAccList.length>2 && this.repaymentPareVal=='Yes'){
            }
            else{
            }
            
        }
        else if(event.target.dataset.field == 'IsThereChangeInLimitDuringThePeri__c'){
            this.changeLimitInPeriVal=event.target.value;
            if(this.changeLimitInPeriVal=='No'){
                this.limitShow=true
            }else{
                this.limitShow=false
            }
        }
        else if(event.target.dataset.field == 'LatestMonthForWhichBankStatementIs__c'){
           console.log('this.fileAcceptanceDate'+this.fileAcceptanceDate)
            if(this.fileAcceptanceDate!='undefined' && this.fileAcceptanceDate !='' && this.fileAcceptanceDate!=null ){
                const dateObj = new Date(this.fileAcceptanceDate);
                const fileAccDay=dateObj.getDate();
                const fileAccMonth=dateObj.getMonth();
                dateObj.setFullYear(dateObj.getFullYear() - 1);
                
                let oneYearLessDate = dateObj.toISOString().slice(0, 10);
                const newDate= new Date(event.target.value);
                
                const newDateMonth=newDate.getMonth();
                const twoMonthsBeforeDate = new Date(this.fileAcceptanceDate);
                twoMonthsBeforeDate.setMonth(fileAccMonth - 2);
                const oneMonthBeforeDate = new Date(this.fileAcceptanceDate);
                oneMonthBeforeDate.setMonth(fileAccMonth - 1);
               
                const monthMap = { 0: 'January', 1: 'February', 2: 'March', 3: 'April', 4: 'May', 5: 'June', 6: 'July', 7: 'August', 8: 'September', 9: 'October', 10: 'November', 11: 'December', };
                if(fileAccDay <=15 && (newDateMonth != oneMonthBeforeDate.getMonth() && newDateMonth != twoMonthsBeforeDate.getMonth() && newDateMonth !=fileAccMonth )){
                   

                    this.showToast("Error", "error", "You can only select date from "+ monthMap[twoMonthsBeforeDate.getMonth()] + ", "+ monthMap[oneMonthBeforeDate.getMonth()] +" and "+ monthMap[fileAccMonth]+" Months.");
                    this.template.querySelector('[data-id="latestMon"]').value = '';
                    this.wrapBankObj.LatestMonthForWhichBankStatementIs__c=''
                }else if(fileAccDay >15 && newDateMonth != oneMonthBeforeDate.getMonth() && newDateMonth !=fileAccMonth){
                    
                    this.showToast("Error", "error", "You can only select date from "+ monthMap[oneMonthBeforeDate.getMonth()]+ " and " + monthMap[fileAccMonth] +" Month.");
                    this.template.querySelector('[data-id="latestMon"]').value = '';
                    this.wrapBankObj.LatestMonthForWhichBankStatementIs__c=''
                }
                else{
                    
                    this.periodBankingEnd=this.wrapBankObj.LatestMonthForWhichBankStatementIs__c
                    this.handlePeriodBankingEnd();
                    

                }
                
            }else{
                this.showToast("Error", "error", this.customLabel.BankDetails_ReqFields_ErrorMessage);
            }
           
              
        }
    
    }
    handleFocus(event){

        this.wrapBankObj[event.target.dataset.field] = event.target.value;
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
    handleMICRSelect(event) { 
        this.lookupRec = event.detail;
      
        if(event.target.label==='MICR Code'){
            this.wrapBankObj.MICR_Code__c = this.lookupRec.mainField;
            if(this.lookupRec.mainField ==null || this.lookupRec.mainField==''){
                this.wrapBankObj.MICRId__c=''
            }
            
            if(!this.lookupRec.mainField){
                this.validMicrode=true;
                this.wrapBankObj.MICR_Code__c='';
               
            }else{
                this.validMicrode=false;
               
                this.searchBankDetails(this.wrapBankObj.MICR_Code__c);
            }
            
        }
    }
    

    handleBlurforLookup(event){
       
        var Searchstring=event.detail
        
        this.searchBankDetails(Searchstring)

    }

    @track validMicrode=false;
    searchBankDetails(SerMICRCodeVal){
       
        let branchNameparams = {
            ParentObjectName: 'MICRCodeMstr__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id','BrchName__c','MICRCode__c','BankCode__c','IFSCCode__c','Bank__r.Name','City__r.Name','Bank__r.Id'],
            childObjFields: [],
            queryCriteria: ' where MICRCode__c = \'' + SerMICRCodeVal + '\''  + ' LIMIT 1'
        }
        getSobjectData({params: branchNameparams})
        .then((result)=>{
           

            if (result.parentRecords && result.parentRecords.length>0) {
                this.validMicrode=false;
                this.wrapBankObj.BankName__c = result.parentRecords[0].Bank__r.Name
                this.wrapBankObj.BankId__c = result.parentRecords[0].Bank__r.Id
                this.wrapBankObj.Bank_City__c = result.parentRecords[0].City__r.Name
                this.wrapBankObj.Bank_Branch__c = result.parentRecords[0].BrchName__c
                this.wrapBankObj.IFSC_Code__c=result.parentRecords[0].IFSCCode__c
                this.wrapBankObj.MICR_Code__c=result.parentRecords[0].MICRCode__c
                this.wrapBankObj.MICRId__c=result.parentRecords[0].Id
                this.wrapBankObj.Bank_Code__c=result.parentRecords[0].BankCode__c
               
               
                    
                    this.parentRecord.BankName__c=result.parentRecords[0].Bank__r.Name
                    this.parentRecord.Bank_Branch__c=result.parentRecords[0].BrchName__c;
                    this.parentRecord.BankId__c=result.parentRecords[0].City__r.Name
                    this.parentRecord.Bank_City__c=result.parentRecords[0].City__r.Name
                    this.parentRecord.IFSC_Code__c=result.parentRecords[0].IFSCCode__c
                   
                    this.parentRecord.Bank_Code__c=result.parentRecords[0].BankCode__c
                    
               
                
            }else{
                this.validMicrode=true
                
                this.wrapBankObj.MICR_Code__c = ''

            }
        })
        .catch((error)=>{
            console.error('Error in line ##385',error)
        })
      }
    @track yearAndMonthList;
    handlePeriodBankingStart(){
      
       if(this.periodBankingStart && this.periodBankingEnd){
        
            if(this.checkValidationForStartDate()){
                
                this.calculateDateDifference();
                if(this.template.querySelector('c-banking-summary-data') != null){
                    this.template.querySelector('c-banking-summary-data').addAppliBankRow( this.applicantRecordId,this.monthandYearList);
                }   
            }
        }else{
            if(this.checkValidationForStartDate()){
                this.calculateDateDifference();
                if(this.template.querySelector('c-banking-summary-data') != null){
                    this.template.querySelector('c-banking-summary-data').addAppliBankRow( this.applicantRecordId,this.monthandYearList);
                
                } 
       
            }
        }    
    }
   
    handlePeriodBankingEnd(){
     
       if (this.periodBankingStart && this.periodBankingEnd){
            if(this.checkValidationForEndDate()){
                this.calculateDateDifference();
                if(this.template.querySelector('c-banking-summary-data') != null){
                    this.template.querySelector('c-banking-summary-data').addAppliBankRow( this.applicantRecordId,this.monthandYearList);
                    
                }
            }
       }
       else{
            if(this.checkValidationForEndDate()){
                this.calculateDateDifference();
                if(this.template.querySelector('c-banking-summary-data') != null){
                    this.template.querySelector('c-banking-summary-data').addAppliBankRow( this.applicantRecordId,this.monthandYearList);
                    
                } 
            }    
        }
       
    }

    checkValidationForStartDate(){
        let checkStartDateWithLoginAcce = this.checkStartDateWithLoginAcce();
       
        let checkStartNdEndDate = this.checkStartNdEndDate();
        
        if(checkStartDateWithLoginAcce){
            if(checkStartNdEndDate ){
                this.monthandYearList=[];
            }else{
                
                this.periodBankingStart=this.parentRecord.PeriodOfBankingStart__c
                this.wrapBankObj.PeriodOfBankingStart__c=''
                this.template.querySelector('[data-id="startDate"]').value = '';
            }
        }else{
            this.periodBankingStart=this.parentRecord.PeriodOfBankingStart__c
       
        }
        
        
        return checkStartDateWithLoginAcce && checkStartNdEndDate;
    }

    checkStartDateWithLoginAcce(){
        if(this.wrapBankObj.LatestMonthForWhichBankStatementIs__c!='undefined' && this.wrapBankObj.LatestMonthForWhichBankStatementIs__c !='' && this.wrapBankObj.LatestMonthForWhichBankStatementIs__c!=null ){   
           const dateObj = new Date(this.wrapBankObj.LatestMonthForWhichBankStatementIs__c);
            dateObj.setFullYear(dateObj.getFullYear() - 1);
            let oneYearLessDate = dateObj.toISOString().slice(0, 10);
            if(this.periodBankingStart < oneYearLessDate){
                this.periodBankingStart=this.parentRecord.PeriodOfBankingStart__c
                this.showToast("Error", "error", this.customLabel.BankDetails_BankingDate_ErrorMessage);
                this.template.querySelector('[data-id="startDate"]').value = '';
                return false 
            }else{
            return true;
            }
        }else{
           
           this.periodBankingStart=this.parentRecord.PeriodOfBankingStart__c
           this.wrapBankObj.PeriodOfBankingStart__c=''
           this.template.querySelector('[data-id="startDate"]').value = '';
            this.showToast("Error", "error", this.customLabel.BankDetails_Statement_ErrorMessage);
            return false 
        }
       
        
    }

    checkValidationForEndDate(){
      
        let checkStartNdEndDate = this.checkStartNdEndDate();
       
        if(checkStartNdEndDate ){
            this.monthandYearList=[];
            this.parentRecord.PeriodOfBankingEnd__c=this.periodBankingEnd
            this.wrapBankObj.PeriodOfBankingEnd__c=this.periodBankingEnd
            
        }else{
            
            this.template.querySelector('[data-id="endDate"]').value = '';
            this.wrapBankObj.PeriodOfBankingEnd__c=''
        }
        
        return checkStartNdEndDate;
    }
    checkStartNdEndDate(){
        if(this.periodBankingStart > this.periodBankingEnd){
            this.showToast("Error", "error", this.customLabel.BankDetails_StartPeriod_ErrorMessage);
            return false 
        }else{
           return true;
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
    monthandYearList;
    calculateDateDifference() {
        
        if (this.periodBankingStart && this.periodBankingEnd) {
            const startDate = new Date(this.periodBankingStart);
            const endDate = new Date(this.periodBankingEnd);
            const differenceInMilliseconds = endDate - startDate;
            this.dateDifference = differenceInMilliseconds;
            const months = this.getMonthsBetweenDates(startDate, endDate);
            this.monthYearList = this.generateMonthYearList(startDate, months);
            this.monthandYearList=this.monthYearList;
           
         }else{
                
               this.monthandYearList=[];
        }
    }
    getMonthsBetweenDates(startDate, endDate) {
            return (endDate.getFullYear() - startDate.getFullYear()) * 12 + (endDate.getMonth() - startDate.getMonth());
    
    }
    generateMonthYearList(startDate, months) {
    const monthYearList = [];
    for (let i = 0; i <= months; i++) {
        const currentMonth = startDate.getMonth() + i;
        const currentYear = startDate.getFullYear() + Math.floor(currentMonth / 12);
        const month = (currentMonth % 12) + 1; // Months are 0-indexed
        monthYearList.push(`${this.getMonthName(month)}-${currentYear}`);
    }
        
        this.monthandYearList=monthYearList;
        return this.monthandYearList;
    
    }
    getMonthName(month) {
        const monthNames = [
        'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
        ];
        return monthNames[month - 1];
    
    }
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
          
           var newTestr=this.accountTypeCCndOD;
            if(this.handleSalariedAccount()){
                if(this.checkForRepayment()){
                   var RequireData1= this.template.querySelector('c-banking-summary-data').validateForm();
                    if(this.checkValidation() && this.handleEndDateValidation() && this.checkValidityLookup()){
                        
                                this.showSpinner=true;
                                setTimeout(() => {
                                    
                                    var MonNdYear=[];
                                   
                                        setTimeout(() => {
                                            if(this.template.querySelector('c-banking-summary-data') != null){
                                               
                                               var RequireData= this.template.querySelector('c-banking-summary-data').validateForm();
                                              
                                                if(RequireData==false){
                                                    this.showToast("Error", "error", "Please Fill values for banking summary.");
                                                }else{
                                                    this.handleSaveWithChild();
                                                    this.handleDeleteAppDetail();
                                            }
                                            }
                                        }, 500)
                                        
                                    
                                }, 2000);
                           // }
                            
                        }else{
                            this.showToast("Error", "error", this.customLabel.BankDetails_ReqFields_ErrorMessage);
                        }
                }
                
                 
            }else{
               
                this.showToast("Error!", "error", this.customLabel.BankDetails_SalaryAcc_ErrorMessage);
            }
        }else{
           
                this.showSpinner=true;
                setTimeout(() => {
                   
                    this.handleSaveWithChild();
                    this.handleDeleteAppDetail();
                }, 2000);
            
        }    
         
    }

    handleValueForSDFCBnk(event){
       
        this.sfdcBnkMasLookup=event.detail
        let recId= this.sfdcBnkMasLookup.id
        let lookupFieldAPIName=this.sfdcBnkMasLookup.lookupFieldAPIName
       
        this.wrapBankObj[lookupFieldAPIName] = recId;
        if(this.sfdcBnkMasLookup.mainField ==='OTHERS'){
            this.showOtherField=true
            this.wrapBankObj[lookupFieldAPIName] = recId;

        }else{
            this.showOtherField=false
        }
    }
    checkValidation(){
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
       
        return  isRequiredField && isComboboxCorrect;
    }

    handleSalariedAccount(){
        if(this._custProfile ==='SALARIED' && this.bankCreditFlag===true){
            
            var numberofSalaryAccount = 0;
                for(var i=0;i< this._allAppliBnkRecs.length;i++){
                    if(this._allAppliBnkRecs[i].SalaryAccount__c){
                       
                        numberofSalaryAccount++;
                    }
                }
                if(numberofSalaryAccount==1){
                   
                    return true;
                }else{
                    return false;
                }
            }else{
                return true;
            }
            
    }
    checkForRepayment(){
        
        if(this.wrapBankObj.Repayment_bank_A_c__c =='No' && this.repaymentAccList.length==0){
            this.showToast("Error", "error", this.customLabel.BankDetails_RepaymentAcc_ReqErrorMessage);
            return false
        }else if(this.wrapBankObj.Repayment_bank_A_c__c =='No' && this.repaymentAccList.length==1 && this.repaymentPareVal=='Yes'){
            this.showToast("Error", "error", this.customLabel.BankDetails_RepaymentAcc_ReqErrorMessage);
            return false
        }
        else{
            return true;
        }

    }
   
    handleEndDateValidation(){
        if(this.wrapBankObj.PeriodOfBankingEnd__c!= '' && this.wrapBankObj.PeriodOfBankingEnd__c!= null && this.wrapBankObj.PeriodOfBankingEnd__c!= 'undefined'){
            return true
        }else{
            this.showToast("Error", "error", this.customLabel.BankDetails_EndDate_ErrorMessage);
            return false
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
        
    
            return isInputCorrect ;

        
    }

    handleSave() {
                    
        let ChildRecords = [];
        let childRecordObj = {};
            
        this.wrapBankObj.sobjectType='ApplBanking__c';     
        
        if(typeof this.wrapBankObj.AccountType__c!=='undefined' &&(this.wrapBankObj.AccountType__c =='JOINT' || this.wrapBankObj.AccountType__c =='SAVINGS' || this.wrapBankObj.AccountType__c =='CURRENT')){
           
            this.wrapBankObj.Limit__c=''
            this.wrapBankObj.AverageLimitDuringThePeriod__c=''
        }       
        let upsertData={                       
            parentRecord:this.wrapBankObj,                       
            ChildRecords:ChildRecords,
            ParentFieldNameToUpdate:''
        }                   
            
        
        updateData ({upsertData:upsertData})
        .then(result => {  
            
                          
                this.showSpinner=false;
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: this.customLabel.BankDetails_Update_SuccessMessage,
                        variant: "success",
                        mode: "sticky"
                    })
                );
                refreshApex(this._wiredApplicantBanking); 
                refreshApex(this._wiredApplicantRecData); 
                
                const toRefreshApex = new CustomEvent('torefreshapex', {
                });
                
                this.dispatchEvent(toRefreshApex);
                
        }).catch(error => {
            
           
        })
            
    }
    // added  isClick flag for Lak-8135 to monthly details reflect twice when save as draft & save the details
    @track isClick = false;
    @track _foreditableTableData
    handleSaveWithChild() {
        if (this.isClick) {
            return isClick;
        }

        this.isClick = true;
       
        let ChildRecords = [];
        let childRecordObj = {};
        console.log('this._foreditableTableData', this._foreditableTableData)
        if(this._foreditableTableData){
            for(var i=0;i<this._foreditableTableData.length;i++){
            
            childRecordObj = {...this._foreditableTableData[i]};
            childRecordObj.sobjectType='ApplBankDetail__c',
            ChildRecords.push(childRecordObj);
           }  
        }
        
        
        this.wrapBankObj.sobjectType='ApplBanking__c'; 
        if(typeof this.wrapBankObj.AccountType__c!=='undefined' &&(this.wrapBankObj.AccountType__c =='JOINT' || this.wrapBankObj.AccountType__c =='SAVINGS' || this.wrapBankObj.AccountType__c =='CURRENT')){
            this.wrapBankObj.Limit__c=''
            this.wrapBankObj.AverageLimitDuringThePeriod__c=''
            ChildRecords = ChildRecords.map(record => ({ ...record, MonthlyLimit__c: 0 }));
        }   
        
        let upsertData={                       
            parentRecord:this.wrapBankObj,                       
            ChildRecords:ChildRecords,
            ParentFieldNameToUpdate:'ApplBanking__c'
        }   
                  
        updateData ({upsertData:upsertData})
        .then(result => {   
            this.isClick = false;     
                this.showSpinner=false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: this.customLabel.BankDetails_Update_SuccessMessage,
                        variant: "success",
                        mode: "sticky"
                    })
                );        
                refreshApex(this._wiredApplicantBanking); 
                refreshApex(this._wiredApplicantRecData);  
               // this.handleFileCreation();
                
                this._foreditableTableData=[]
                const toRefreshApex = new CustomEvent('torefreshapex', {
                });
                this.dispatchEvent(toRefreshApex);
                debugger
                let docName='';
                if(typeof this.wrapBankObj.AccountType__c !=='undefined' && this.DocumentDetailId){
                    if(this.wrapBankObj.AccountType__c === 'SAVINGS'){
                        docName = 'Saving';
                    }else if(this.wrapBankObj.AccountType__c === 'JOINT'){
                        docName = 'Joint';
                    }else if(this.wrapBankObj.AccountType__c === 'CURRENT'){
                       docName = 'Current';
                    }else if(this.wrapBankObj.AccountType__c === 'OVERDRAFT'){
                        docName = 'OD';
                    }else if(this.wrapBankObj.AccountType__c === 'CC'){
                        docName = 'CC';
                    }
                    const fields = {};           
                    fields[DOCID.fieldApiName] = this.DocumentDetailId;
                    fields[DOCNAME.fieldApiName] = docName;
                    const recordInput = { fields };
                    updateRecord(recordInput)
                    .then((result) => {  
                        console.log('resultresultresultresult>>>'+this.DocumentDetailId)
                    })
                    .catch(error => {
                        
                    });
                }


                
               
        }).catch(error => {
            this.isClick = false;
        })
            
    }
    saveConVerData(){
        let ChildReForConVer = [];
        let ChildReForConVerobj = {};
            
        this.wrapObjConver.sobjectType='ContentVersion';     
        let upsertData={                       
            parentRecord:this.wrapObjConver,                       
            ChildRecords:ChildReForConVer,
            ParentFieldNameToUpdate:''
        }                   
         updateData ({upsertData:upsertData})
        .then(result => {  
                              
            refreshApex(this._wiredApplicantBanking); 
            refreshApex(this._wiredApplicantRecData);
                
        }).catch(error => {
            
           
        })
    }


    averLimitVal=0
    listForDeleteAppDetail;
    diabledMonLimit;
    listOfAllAverage;
    listOfAllTotal;
    handleBankDetailChildUpdate(event){
        
        var listForDelete=[]
        var listOfPareNdChild=[];
         
        listOfPareNdChild = [...event.detail.variable1];
        this.averLimitVal=event.detail.variable2
      
        listForDelete=[...event.detail.listForDelete]
        
        this.listForDeleteAppDetail=listForDelete;
        
        this._foreditableTableData=listOfPareNdChild
        
        if(this.accountTypeCCndOD==true){
            this.parentRecord.AverageLimitDuringThePeriod__c=this.averLimitVal
            this.wrapBankObj.AverageLimitDuringThePeriod__c=this.averLimitVal
        }
        this.listOfAllTotal=[...event.detail.listOfAllTotal]
        this.listOfAllAverage=[...event.detail.listOfAllAverage]
     }
    handleLimitValue(event){
        
        if(this.accountTypeCCndOD==true){
            this.parentRecord.AverageLimitDuringThePeriod__c=event.detail
           this.wrapBankObj.AverageLimitDuringThePeriod__c=event.detail
        }
    }

    handleDeleteAppDetail(){
        const newList = this.listForDeleteAppDetail.map(item => {
            const newItem = { ...item };
            delete newItem.MonthlyLimit; // Remove MonthlyLimit property
            return newItem;
        })
        deleteRecord({ rcrds: newList })
            .then(result => {
                this.showSpinner=false
               refreshApex(this._wiredApplicantBanking); 
                refreshApex(this._wiredApplicantRecData);
            })
            .catch(error => {
                console.error(error);
            });
    }
    downloadBankDetailFile(event){
        
        const salesforceBaseUrl = this.getSalesforceBaseUrl();
        if(this.fileToDownload){
            var downloadUrl = salesforceBaseUrl + '/sfc/servlet.shepherd/document/download/' + encodeURIComponent(this.ContentDocumentId);
            // Use the NavigationMixin to open the PDF URL in a new tab
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: downloadUrl
                }
            });
        }else{
            this.showToast("Error", "error", this.customLabel.showAllDetailsNoFileError,"sticky");
        }
        
    }
    getSalesforceBaseUrl() {
        // Use window.location.origin to get the protocol, hostname, and port
        const { protocol, hostname, port } = window.location;

        // Construct the Salesforce base URL
        let baseUrl = `${protocol}//${hostname}`;

        // Check if the port is not the default HTTP/HTTPS port (80/443)
        if (port && !['80', '443'].includes(port)) {
            baseUrl += `:${port}`;
        }

        return baseUrl;
    }
    periodOfBnk
    //drop-2 download excel file for applicant banking and applicant banking detail data
    handleExcelDownFileseconbutton(){
        if(this._foreditableTableData !=='undefined' && this._foreditableTableData){

        }else{
            this.showToast("Error", "error", 'There are no records for download',"sticky");
        }
        const bankName=this.parentRecord.SFDC_Bank_Master_Name__c
        if(typeof this.parentRecord.PeriodOfBankingEnd__c !== 'undefined' && typeof this.parentRecord.PeriodOfBankingStart__c !== 'undefined'){
             this.periodOfBnk=this.periodBankingStart +' to '+ this.periodBankingEnd;
        }else{
            this.periodOfBnk=''
        }
       
        let data = [
            {"Banking -1":"Name of the Account Holder:","__EMPTY":"","__EMPTY_1":"","__EMPTY_2":this.parentRecord.Name_of_the_Primary_Account_Holder_s__c,"__EMPTY_3":"","__EMPTY_4":"","__EMPTY_5":"","__EMPTY_6":"","__EMPTY_7":"","__EMPTY_8":"","__EMPTY_9":"","__EMPTY_10":"","__EMPTY_11":"","__EMPTY_12":"","__EMPTY_13":"","__EMPTY_14":""},
            {"Banking -1":"A/c of","__EMPTY_1":this.parentRecord.AccountOf__c,"__EMPTY_6":"Bank","__EMPTY_8":bankName},
            {"Banking -1":"A/c No.","__EMPTY_1":this.parentRecord.AC_No__c,"__EMPTY_6":"Type","__EMPTY_8":this.parentRecord.AccountType__c},
            {"Banking -1":"Period","__EMPTY_1":this.periodOfBnk},
            {"Banking -1":"EMI Paid from this Account","__EMPTY_2":this.parentRecord.EMIPaidFromThisAccount__c},
          //  {"Banking -1":"Particular","__EMPTY":"Value Summation","__EMPTY_2":"Count of Debits and Credits","__EMPTY_4":"Inward Returns (Count)","__EMPTY_5":"Outward Returns (Count)","__EMPTY_6":"Stop Pymt. (Count)","__EMPTY_7":"Minimum Balance Charges (Y/N)","__EMPTY_8":"Balance at Specific Date In Month","__EMPTY_14":"Average Bank Balance"},
          //  {"Banking -1":"Months","__EMPTY":"Debits","__EMPTY_1":"Credits","__EMPTY_2":"Debits","__EMPTY_3":"Credits","__EMPTY_8":"1st","__EMPTY_9":"5th","__EMPTY_10":"10th","__EMPTY_11":"15th","__EMPTY_12":"20th","__EMPTY_13":"25th"},
        ]
        console.log('test1')
        if(this.parentRecord.AccountType__c== 'OVERDRAFT' || this.parentRecord.AccountType__c== 'CC'){
            const rec= {"Banking -1":"Particular","__EMPTY":"Value Summation","__EMPTY_2":"Count of Debits and Credits","__EMPTY_4":"Inward Returns (Count)","__EMPTY_5":"Outward Returns (Count)","__EMPTY_6":"Stop Pymt. (Count)","__EMPTY_7":"Minimum Balance Charges (Y/N)","__EMPTY_8":"Balance at Specific Date In Month","__EMPTY_15":"Average Bank Balance", "__EMPTY_16":"Average Daily Bank Balance", "__EMPTY_17":"Monthly Limit", "__EMPTY_18":"Utilization %"}
            const recForMon= {"Banking -1":"Months","__EMPTY":"Debits","__EMPTY_1":"Credits","__EMPTY_2":"Debits","__EMPTY_3":"Credits","__EMPTY_8":"1st","__EMPTY_9":"5th","__EMPTY_10":"10th","__EMPTY_11":"15th","__EMPTY_12":"20th","__EMPTY_13":"25th", "__EMPTY_14":"Monthend"}
           data.push(rec)
         data.push(recForMon)
        }else{
            const rec= {"Banking -1":"Particular","__EMPTY":"Value Summation","__EMPTY_2":"Count of Debits and Credits","__EMPTY_4":"Inward Returns (Count)","__EMPTY_5":"Outward Returns (Count)","__EMPTY_6":"Stop Pymt. (Count)","__EMPTY_7":"Minimum Balance Charges (Y/N)","__EMPTY_8":"Balance at Specific Date In Month","__EMPTY_15":"Average Bank Balance","__EMPTY_16":"Average Daily Bank Balance"}
            const recForMon= {"Banking -1":"Months","__EMPTY":"Debits","__EMPTY_1":"Credits","__EMPTY_2":"Debits","__EMPTY_3":"Credits","__EMPTY_8":"1st","__EMPTY_9":"5th","__EMPTY_10":"10th","__EMPTY_11":"15th","__EMPTY_12":"20th","__EMPTY_13":"25th",  "__EMPTY_14":"Monthend"}
            data.push(rec)
            data.push(recForMon)
        }
        console.log('test2')
        if(this.parentRecord.AccountType__c== 'OVERDRAFT' || this.parentRecord.AccountType__c== 'CC'){
            for(const record of this._foreditableTableData){
                // console.log('record'+JSON.stringify(record))
                 let monthNdYear=record.Month__c +'-'+record.Year__c
                 let bnkRec= {"Banking -1": monthNdYear, "__EMPTY": record.ValueSummationDebit__c,"__EMPTY_1": record.ValueSummationCredit__c, "__EMPTY_2": record.CountofDebit__c,"__EMPTY_3": record.CountofCredit__c,
                     "__EMPTY_4": record.InwardReturnsCount__c, "__EMPTY_5": record.OutwardReturnsCount__c,"__EMPTY_6": record.StopPaymentCount__c,"__EMPTY_7": record.MinBalanceCharges__c,"__EMPTY_8": record.BalanceAt_1st__c,"__EMPTY_9": record.BalanceAt_5th__c,
                     "__EMPTY_10": record.BalanceAt_10th__c, "__EMPTY_11": record.BalanceAt_15th__c,"__EMPTY_12": record.BalanceAt_20th__c,"__EMPTY_13": record.BalanceAt_25th__c,"__EMPTY_14": record.Monthend__c,"__EMPTY_15": record.AverageBankBalance__c, "__EMPTY_16": record.Average_Daily_Bank_Balance__c,"__EMPTY_17": record.MonthlyLimit__c, "__EMPTY_18": record.Utilization__c+'%'
                 }
                 data.push(bnkRec)
            }
           console.log('this.listOfAllTotal[0]'+this.listOfAllTotal[0])
           let bnkTot= {"Banking -1": "Total", "__EMPTY": this.listOfAllTotal[0],"__EMPTY_1": this.listOfAllTotal[1], "__EMPTY_2": this.listOfAllTotal[2],"__EMPTY_3": this.listOfAllTotal[3],
            "__EMPTY_4": this.listOfAllTotal[4], "__EMPTY_5": this.listOfAllTotal[5],"__EMPTY_6": this.listOfAllTotal[6],"__EMPTY_7": this.listOfAllTotal[7],"__EMPTY_8": this.listOfAllTotal[8],"__EMPTY_9": this.listOfAllTotal[9],
            "__EMPTY_10": this.listOfAllTotal[10], "__EMPTY_11": this.listOfAllTotal[11],"__EMPTY_12": this.listOfAllTotal[12],"__EMPTY_13": this.listOfAllTotal[13],"__EMPTY_14": this.listOfAllTotal[14], "__EMPTY_15": this.listOfAllTotal[15],"__EMPTY_16": this.listOfAllTotal[16], "__EMPTY_17": this.listOfAllTotal[17] 
            }
            let bnkAve= {"Banking -1": "Average", "__EMPTY": this.listOfAllAverage[0],"__EMPTY_1": this.listOfAllAverage[1], "__EMPTY_2": this.listOfAllAverage[2],"__EMPTY_3": this.listOfAllAverage[3],
            "__EMPTY_4": this.listOfAllAverage[4], "__EMPTY_5": this.listOfAllAverage[5],"__EMPTY_6": this.listOfAllAverage[6],"__EMPTY_7": this.listOfAllAverage[7],"__EMPTY_8": this.listOfAllAverage[8],"__EMPTY_9": this.listOfAllAverage[9],
            "__EMPTY_10": this.listOfAllAverage[10], "__EMPTY_11": this.listOfAllAverage[11],"__EMPTY_12": this.listOfAllAverage[12],"__EMPTY_13": this.listOfAllAverage[13],"__EMPTY_14": this.listOfAllAverage[14], "__EMPTY_15": this.listOfAllAverage[15],"__EMPTY_16": this.listOfAllAverage[16], "__EMPTY_17": this.listOfAllAverage[17]
            }
           data.push(bnkTot)
            data.push(bnkAve)
        }else{
            console.log('test4')
            for(const record of this._foreditableTableData){
                 console.log('record'+JSON.stringify(record))
                 let monthNdYear=record.Month__c +'-'+record.Year__c
                 let bnkRec= {"Banking -1": monthNdYear, "__EMPTY": record.ValueSummationDebit__c,"__EMPTY_1": record.ValueSummationCredit__c, "__EMPTY_2": record.CountofDebit__c,"__EMPTY_3": record.CountofCredit__c,
                     "__EMPTY_4": record.InwardReturnsCount__c, "__EMPTY_5": record.OutwardReturnsCount__c,"__EMPTY_6": record.StopPaymentCount__c,"__EMPTY_7": record.MinBalanceCharges__c,"__EMPTY_8": record.BalanceAt_1st__c,"__EMPTY_9": record.BalanceAt_5th__c,
                     "__EMPTY_10": record.BalanceAt_10th__c, "__EMPTY_11": record.BalanceAt_15th__c,"__EMPTY_12": record.BalanceAt_20th__c,"__EMPTY_13": record.BalanceAt_25th__c,"__EMPTY_14": record.Monthend__c,"__EMPTY_15": record.AverageBankBalance__c, "__EMPTY_16": record.Average_Daily_Bank_Balance__c
                 }
                 data.push(bnkRec)
             }
             console.log('test4')
             let bnkTot= {"Banking -1": "Total", "__EMPTY": this.listOfAllTotal[0],"__EMPTY_1": this.listOfAllTotal[1], "__EMPTY_2": this.listOfAllTotal[2],"__EMPTY_3": this.listOfAllTotal[3],
             "__EMPTY_4": this.listOfAllTotal[4], "__EMPTY_5": this.listOfAllTotal[5],"__EMPTY_6": this.listOfAllTotal[6],"__EMPTY_7": this.listOfAllTotal[7],"__EMPTY_8": this.listOfAllTotal[8],"__EMPTY_9": this.listOfAllTotal[9],
             "__EMPTY_10": this.listOfAllTotal[10], "__EMPTY_11": this.listOfAllTotal[11],"__EMPTY_12": this.listOfAllTotal[12],"__EMPTY_13": this.listOfAllTotal[13],"__EMPTY_14": this.listOfAllTotal[14],"__EMPTY_15": this.listOfAllTotal[15],"__EMPTY_16": this.listOfAllTotal[16]
             }
             let bnkAve= {"Banking -1": "Average", "__EMPTY": this.listOfAllAverage[0],"__EMPTY_1": this.listOfAllAverage[1], "__EMPTY_2": this.listOfAllAverage[2],"__EMPTY_3": this.listOfAllAverage[3],
             "__EMPTY_4": this.listOfAllAverage[4], "__EMPTY_5": this.listOfAllAverage[5],"__EMPTY_6": this.listOfAllAverage[6],"__EMPTY_7": this.listOfAllAverage[7],"__EMPTY_8": this.listOfAllAverage[8],"__EMPTY_9": this.listOfAllAverage[9],
             "__EMPTY_10": this.listOfAllAverage[10], "__EMPTY_11": this.listOfAllAverage[11],"__EMPTY_12": this.listOfAllAverage[12],"__EMPTY_13": this.listOfAllAverage[13],"__EMPTY_14": this.listOfAllAverage[14],"__EMPTY_15": this.listOfAllAverage[15],"__EMPTY_15": this.listOfAllAverage[15]
             }
             data.push(bnkTot)
             data.push(bnkAve)
        }
        
       
        /*let bnkTot= {"Banking -1": "Total", "__EMPTY": this.listOfAllTotal[0],"__EMPTY_1": this.listOfAllTotal[1], "__EMPTY_2": this.listOfAllTotal[2],"__EMPTY_3": this.listOfAllTotal[3],
            "__EMPTY_4": this.listOfAllTotal[4], "__EMPTY_5": this.listOfAllTotal[5],"__EMPTY_6": this.listOfAllTotal[6],"__EMPTY_7": this.listOfAllTotal[7],"__EMPTY_8": this.listOfAllTotal[8],"__EMPTY_9": this.listOfAllTotal[9],
            "__EMPTY_10": this.listOfAllTotal[10], "__EMPTY_11": this.listOfAllTotal[11],"__EMPTY_12": this.listOfAllTotal[12],"__EMPTY_13": this.listOfAllTotal[13],"__EMPTY_14": this.listOfAllTotal[14]
        }
        let bnkAve= {"Banking -1": "Average", "__EMPTY": this.listOfAllAverage[0],"__EMPTY_1": this.listOfAllAverage[1], "__EMPTY_2": this.listOfAllAverage[2],"__EMPTY_3": this.listOfAllAverage[3],
        "__EMPTY_4": this.listOfAllAverage[4], "__EMPTY_5": this.listOfAllAverage[5],"__EMPTY_6": this.listOfAllAverage[6],"__EMPTY_7": this.listOfAllAverage[7],"__EMPTY_8": this.listOfAllAverage[8],"__EMPTY_9": this.listOfAllAverage[9],
        "__EMPTY_10": this.listOfAllAverage[10], "__EMPTY_11": this.listOfAllAverage[11],"__EMPTY_12": this.listOfAllAverage[12],"__EMPTY_13": this.listOfAllAverage[13],"__EMPTY_14": this.listOfAllAverage[14]
        }
        data.push(bnkTot)
        data.push(bnkAve)*/
      
        
      //.modifyAndDownload(formateddata)
        const worksheet = XLSX.utils.json_to_sheet(data);
        
        worksheet["A1"].v = "Banking -1"; // Change A1 cell (Name column header)
        worksheet["B1"].v = ""; // Change B1 cell (Age column header)
        worksheet["C1"].v = "";
        worksheet["D1"].v = "";
        worksheet["E1"].v = ""; // Change E1 cell
        worksheet["F1"].v = ""; // Change F1 cell
        worksheet["G1"].v = ""; // Change G1 cell
        worksheet["H1"].v = ""; // Change H1 cell
        worksheet["I1"].v = ""; // Change I1 cell
        worksheet["J1"].v = ""; // Change J1 cell
        worksheet["K1"].v = ""; // Change K1 cell
        worksheet["L1"].v = ""; // Change L1 cell
        worksheet["M1"].v = ""; // Change M1 cell
        worksheet["N1"].v = ""; // Change N1 cell
        worksheet["O1"].v = ""; // Change O1 cell
        worksheet["P1"].v = ""; // Change P1 cell
        worksheet["Q1"].v = "";
            worksheet["R1"].v = "";
        if(this.parentRecord.AccountType__c== 'OVERDRAFT' || this.parentRecord.AccountType__c== 'CC'){
            worksheet["S1"].v = "";
            worksheet["T1"].v = "";
        }
        
        const merge = [
            { s: { r: 6, c: 1 }, e: { r: 6, c: 2 } },{ s: { r: 6, c: 3 }, e: { r: 6, c: 4 } }, { s: { r: 6, c: 9 }, e: { r: 6, c: 15 } }, { s: { r: 1, c: 0 }, e: { r: 1, c: 2 } }, {s:{ r: 2, c: 0 }, e: { r: 2, c: 1 } },
            {s:{ r: 2, c: 7 }, e: { r: 2, c: 8 } }, {s:{ r: 2, c: 7 }, e: { r: 2, c: 8 } }, {s:{ r: 3, c: 0 }, e: { r: 3, c: 1 } }, {s:{ r: 3, c: 7 }, e: { r: 3, c: 8 } }, {s:{ r: 4, c: 0 }, e: { r: 4, c: 1 } }	,
            {s:{ r: 5, c: 0 }, e: { r: 5, c: 1 } }	
            
          ];
          worksheet["!merges"] = merge;
          let rowsToCreate=9+this._foreditableTableData.length;
          console.log('rowsToCreate'+rowsToCreate)
        for (let i = 9; i <= rowsToCreate; i++) {
            const formula = `SUM(J${i}:K${i}:L${i}:M${i}:N${i}:O${i}: P${i})/7`;
            const cell = `Q${i}`;
            XLSX.utils.sheet_set_array_formula(worksheet, cell, formula);
            
        }
        for (let i = 9; i < rowsToCreate; i++) {
            const rangeForB = `B9:B${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `B${rowsToCreate}`, `SUM(${rangeForB})`);
            const rangeForC = `C9:C${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `C${rowsToCreate}`, `SUM(${rangeForC})`);
            const rangeForD = `D9:D${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `D${rowsToCreate}`, `SUM(${rangeForD})`);
            const rangeForE = `E9:E${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `E${rowsToCreate}`, `SUM(${rangeForE})`);
            const rangeForF = `F9:F${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `F${rowsToCreate}`, `SUM(${rangeForF})`);
            const rangeForG = `G9:G${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `G${rowsToCreate}`, `SUM(${rangeForG})`);
            const rangeForH = `H9:H${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `H${rowsToCreate}`, `SUM(${rangeForH})`);
            const rangeForJ = `J9:J${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `J${rowsToCreate}`, `SUM(${rangeForJ})`);
            const rangeForK = `K9:K${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `K${rowsToCreate}`, `SUM(${rangeForK})`);
            const rangeForL = `L9:L${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `L${rowsToCreate}`, `SUM(${rangeForL})`);
            const rangeForM = `M9:M${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `M${rowsToCreate}`, `SUM(${rangeForM})`);
            const rangeForN = `N9:N${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `N${rowsToCreate}`, `SUM(${rangeForN})`);
            const rangeForO = `O9:O${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `O${rowsToCreate}`, `SUM(${rangeForO})`);
            const rangeForP = `P9:P${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `P${rowsToCreate}`, `SUM(${rangeForP})`);
            const rangeForQ = `Q9:Q${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `Q${rowsToCreate}`, `SUM(${rangeForQ})`);
            const rangeForR = `R9:R${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `R${rowsToCreate}`, `SUM(${rangeForR})`);
            if(this.parentRecord.AccountType__c== 'OVERDRAFT' || this.parentRecord.AccountType__c== 'CC'){
                const rangeForS = `S9:S${rowsToCreate-1}`;
                XLSX.utils.sheet_set_array_formula(worksheet, `S${rowsToCreate}`, `SUM(${rangeForS})`);
            }
           
        }
        for (const column of ['B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R']) {
            const formula = `=${column}${rowsToCreate}/${this._foreditableTableData.length}`;
            worksheet[`${column}${rowsToCreate+1}`] = { t: "n", f: formula, F: `${column}${rowsToCreate+1}:${column}${rowsToCreate+1}` };
        }
        if(this.parentRecord.AccountType__c== 'OVERDRAFT' || this.parentRecord.AccountType__c== 'CC'){
            let column="S"
            const formula = `=${column}${rowsToCreate}/${this._foreditableTableData.length}`;
            worksheet[`${column}${rowsToCreate+1}`] = { t: "n", f: formula, F: `${column}${rowsToCreate+1}:${column}${rowsToCreate+1}` };

            worksheet[`T${rowsToCreate}`] =  { t: "n", f: formula, F: `Q${rowsToCreate+1}*100/S${rowsToCreate+1}` }
            for (let i = 9; i <= rowsToCreate; i++) {
                const columnR = `T${i}`;
                const columnP = `Q${i}`;
                const columnQ = `S${i}`;
                worksheet[columnR] = { t: "n", f: `=IFERROR(ROUND(${columnP}*100/${columnQ}, 2),"")`, F: `${columnR}:${columnR}` };

            }
        }
       
       const workbook = XLSX.utils.book_new();
       XLSX.utils.book_append_sheet(workbook, worksheet, 'Sheet1');
      // XLSX.utils.book_append_sheet(workbook, worksheet, 'Sheet2');
        XLSX.writeFile(workbook, 'Banking_Details.xlsx');
       
    }
    handleFileCreation() {
        const bankName=this.parentRecord.SFDC_Bank_Master_Name__c
        if(typeof this.parentRecord.PeriodOfBankingEnd__c !== 'undefined' && typeof this.parentRecord.PeriodOfBankingStart__c !== 'undefined'){
             this.periodOfBnk=this.periodBankingStart +' to '+ this.periodBankingEnd;
        }else{
            this.periodOfBnk=''
        }
       
        let data = [
            {"Banking -1":"Name of the Account Holder:","__EMPTY":"","__EMPTY_1":"","__EMPTY_2":this.parentRecord.Name_of_the_Primary_Account_Holder_s__c,"__EMPTY_3":"","__EMPTY_4":"","__EMPTY_5":"","__EMPTY_6":"","__EMPTY_7":"","__EMPTY_8":"","__EMPTY_9":"","__EMPTY_10":"","__EMPTY_11":"","__EMPTY_12":"","__EMPTY_13":"","__EMPTY_14":""},
            {"Banking -1":"A/c of","__EMPTY_1":this.parentRecord.AccountOf__c,"__EMPTY_6":"Bank","__EMPTY_8":bankName},
            {"Banking -1":"A/c No.","__EMPTY_1":this.parentRecord.AC_No__c,"__EMPTY_6":"Type","__EMPTY_8":this.parentRecord.AccountType__c},
            {"Banking -1":"Period","__EMPTY_1":this.periodOfBnk},
            {"Banking -1":"EMI Paid from this Account","__EMPTY_2":this.parentRecord.EMIPaidFromThisAccount__c},
          //  {"Banking -1":"Particular","__EMPTY":"Value Summation","__EMPTY_2":"Count of Debits and Credits","__EMPTY_4":"Inward Returns (Count)","__EMPTY_5":"Outward Returns (Count)","__EMPTY_6":"Stop Pymt. (Count)","__EMPTY_7":"Minimum Balance Charges (Y/N)","__EMPTY_8":"Balance at Specific Date In Month","__EMPTY_14":"Average Bank Balance"},
          //  {"Banking -1":"Months","__EMPTY":"Debits","__EMPTY_1":"Credits","__EMPTY_2":"Debits","__EMPTY_3":"Credits","__EMPTY_8":"1st","__EMPTY_9":"5th","__EMPTY_10":"10th","__EMPTY_11":"15th","__EMPTY_12":"20th","__EMPTY_13":"25th"},
        ]
        console.log('test1')
        if(this.parentRecord.AccountType__c== 'OVERDRAFT' || this.parentRecord.AccountType__c== 'CC'){
            const rec= {"Banking -1":"Particular","__EMPTY":"Value Summation","__EMPTY_2":"Count of Debits and Credits","__EMPTY_4":"Inward Returns (Count)","__EMPTY_5":"Outward Returns (Count)","__EMPTY_6":"Stop Pymt. (Count)","__EMPTY_7":"Minimum Balance Charges (Y/N)","__EMPTY_8":"Balance at Specific Date In Month","__EMPTY_14":"Average Bank Balance", "__EMPTY_15":"Monthly Limit", "__EMPTY_16":"Utilization %"}
            const recForMon= {"Banking -1":"Months","__EMPTY":"Debits","__EMPTY_1":"Credits","__EMPTY_2":"Debits","__EMPTY_3":"Credits","__EMPTY_8":"1st","__EMPTY_9":"5th","__EMPTY_10":"10th","__EMPTY_11":"15th","__EMPTY_12":"20th","__EMPTY_13":"25th"}
           data.push(rec)
         data.push(recForMon)
        }else{
            const rec= {"Banking -1":"Particular","__EMPTY":"Value Summation","__EMPTY_2":"Count of Debits and Credits","__EMPTY_4":"Inward Returns (Count)","__EMPTY_5":"Outward Returns (Count)","__EMPTY_6":"Stop Pymt. (Count)","__EMPTY_7":"Minimum Balance Charges (Y/N)","__EMPTY_8":"Balance at Specific Date In Month","__EMPTY_14":"Average Bank Balance"}
            const recForMon= {"Banking -1":"Months","__EMPTY":"Debits","__EMPTY_1":"Credits","__EMPTY_2":"Debits","__EMPTY_3":"Credits","__EMPTY_8":"1st","__EMPTY_9":"5th","__EMPTY_10":"10th","__EMPTY_11":"15th","__EMPTY_12":"20th","__EMPTY_13":"25th"}
            data.push(rec)
            data.push(recForMon)
        }
        console.log('test2')
        if(this.parentRecord.AccountType__c== 'OVERDRAFT' || this.parentRecord.AccountType__c== 'CC'){
            for(const record of this._foreditableTableData){
                // console.log('record'+JSON.stringify(record))
                 let monthNdYear=record.Month__c +'-'+record.Year__c
                 let bnkRec= {"Banking -1": monthNdYear, "__EMPTY": record.ValueSummationDebit__c,"__EMPTY_1": record.ValueSummationCredit__c, "__EMPTY_2": record.CountofDebit__c,"__EMPTY_3": record.CountofCredit__c,
                     "__EMPTY_4": record.InwardReturnsCount__c, "__EMPTY_5": record.OutwardReturnsCount__c,"__EMPTY_6": record.StopPaymentCount__c,"__EMPTY_7": record.MinBalanceCharges__c,"__EMPTY_8": record.BalanceAt_1st__c,"__EMPTY_9": record.BalanceAt_5th__c,
                     "__EMPTY_10": record.BalanceAt_10th__c, "__EMPTY_11": record.BalanceAt_15th__c,"__EMPTY_12": record.BalanceAt_20th__c,"__EMPTY_13": record.BalanceAt_25th__c,"__EMPTY_14": record.AverageBankBalance__c, "__EMPTY_15": record.MonthlyLimit__c, "__EMPTY_16": record.Utilization__c+'%'
                 }
                 data.push(bnkRec)
            }
            console.log('test3')
           console.log('this.listOfAllTotal[0]'+this.listOfAllTotal[0])
           let bnkTot= {"Banking -1": "Total", "__EMPTY": this.listOfAllTotal[0],"__EMPTY_1": this.listOfAllTotal[1], "__EMPTY_2": this.listOfAllTotal[2],"__EMPTY_3": this.listOfAllTotal[3],
            "__EMPTY_4": this.listOfAllTotal[4], "__EMPTY_5": this.listOfAllTotal[5],"__EMPTY_6": this.listOfAllTotal[6],"__EMPTY_7": this.listOfAllTotal[7],"__EMPTY_8": this.listOfAllTotal[8],"__EMPTY_9": this.listOfAllTotal[9],
            "__EMPTY_10": this.listOfAllTotal[10], "__EMPTY_11": this.listOfAllTotal[11],"__EMPTY_12": this.listOfAllTotal[12],"__EMPTY_13": this.listOfAllTotal[13],"__EMPTY_14": this.listOfAllTotal[14], "__EMPTY_16": this.listOfAllTotal[16], 
            }
            let bnkAve= {"Banking -1": "Average", "__EMPTY": this.listOfAllAverage[0],"__EMPTY_1": this.listOfAllAverage[1], "__EMPTY_2": this.listOfAllAverage[2],"__EMPTY_3": this.listOfAllAverage[3],
            "__EMPTY_4": this.listOfAllAverage[4], "__EMPTY_5": this.listOfAllAverage[5],"__EMPTY_6": this.listOfAllAverage[6],"__EMPTY_7": this.listOfAllAverage[7],"__EMPTY_8": this.listOfAllAverage[8],"__EMPTY_9": this.listOfAllAverage[9],
            "__EMPTY_10": this.listOfAllAverage[10], "__EMPTY_11": this.listOfAllAverage[11],"__EMPTY_12": this.listOfAllAverage[12],"__EMPTY_13": this.listOfAllAverage[13],"__EMPTY_14": this.listOfAllAverage[14], "__EMPTY_15": this.listOfAllAverage[15]
            }
           data.push(bnkTot)
            data.push(bnkAve)
        }else{
            console.log('test4')
            for(const record of this._foreditableTableData){
                 console.log('record'+JSON.stringify(record))
                 let monthNdYear=record.Month__c +'-'+record.Year__c
                 let bnkRec= {"Banking -1": monthNdYear, "__EMPTY": record.ValueSummationDebit__c,"__EMPTY_1": record.ValueSummationCredit__c, "__EMPTY_2": record.CountofDebit__c,"__EMPTY_3": record.CountofCredit__c,
                     "__EMPTY_4": record.InwardReturnsCount__c, "__EMPTY_5": record.OutwardReturnsCount__c,"__EMPTY_6": record.StopPaymentCount__c,"__EMPTY_7": record.MinBalanceCharges__c,"__EMPTY_8": record.BalanceAt_1st__c,"__EMPTY_9": record.BalanceAt_5th__c,
                     "__EMPTY_10": record.BalanceAt_10th__c, "__EMPTY_11": record.BalanceAt_15th__c,"__EMPTY_12": record.BalanceAt_20th__c,"__EMPTY_13": record.BalanceAt_25th__c,"__EMPTY_14": record.AverageBankBalance__c
                 }
                 data.push(bnkRec)
             }
             console.log('test4')
             let bnkTot= {"Banking -1": "Total", "__EMPTY": this.listOfAllTotal[0],"__EMPTY_1": this.listOfAllTotal[1], "__EMPTY_2": this.listOfAllTotal[2],"__EMPTY_3": this.listOfAllTotal[3],
             "__EMPTY_4": this.listOfAllTotal[4], "__EMPTY_5": this.listOfAllTotal[5],"__EMPTY_6": this.listOfAllTotal[6],"__EMPTY_7": this.listOfAllTotal[7],"__EMPTY_8": this.listOfAllTotal[8],"__EMPTY_9": this.listOfAllTotal[9],
             "__EMPTY_10": this.listOfAllTotal[10], "__EMPTY_11": this.listOfAllTotal[11],"__EMPTY_12": this.listOfAllTotal[12],"__EMPTY_13": this.listOfAllTotal[13],"__EMPTY_14": this.listOfAllTotal[14]
             }
             let bnkAve= {"Banking -1": "Average", "__EMPTY": this.listOfAllAverage[0],"__EMPTY_1": this.listOfAllAverage[1], "__EMPTY_2": this.listOfAllAverage[2],"__EMPTY_3": this.listOfAllAverage[3],
             "__EMPTY_4": this.listOfAllAverage[4], "__EMPTY_5": this.listOfAllAverage[5],"__EMPTY_6": this.listOfAllAverage[6],"__EMPTY_7": this.listOfAllAverage[7],"__EMPTY_8": this.listOfAllAverage[8],"__EMPTY_9": this.listOfAllAverage[9],
             "__EMPTY_10": this.listOfAllAverage[10], "__EMPTY_11": this.listOfAllAverage[11],"__EMPTY_12": this.listOfAllAverage[12],"__EMPTY_13": this.listOfAllAverage[13],"__EMPTY_14": this.listOfAllAverage[14]
             }
             data.push(bnkTot)
             data.push(bnkAve)
        }
        
       
        /*let bnkTot= {"Banking -1": "Total", "__EMPTY": this.listOfAllTotal[0],"__EMPTY_1": this.listOfAllTotal[1], "__EMPTY_2": this.listOfAllTotal[2],"__EMPTY_3": this.listOfAllTotal[3],
            "__EMPTY_4": this.listOfAllTotal[4], "__EMPTY_5": this.listOfAllTotal[5],"__EMPTY_6": this.listOfAllTotal[6],"__EMPTY_7": this.listOfAllTotal[7],"__EMPTY_8": this.listOfAllTotal[8],"__EMPTY_9": this.listOfAllTotal[9],
            "__EMPTY_10": this.listOfAllTotal[10], "__EMPTY_11": this.listOfAllTotal[11],"__EMPTY_12": this.listOfAllTotal[12],"__EMPTY_13": this.listOfAllTotal[13],"__EMPTY_14": this.listOfAllTotal[14]
        }
        let bnkAve= {"Banking -1": "Average", "__EMPTY": this.listOfAllAverage[0],"__EMPTY_1": this.listOfAllAverage[1], "__EMPTY_2": this.listOfAllAverage[2],"__EMPTY_3": this.listOfAllAverage[3],
        "__EMPTY_4": this.listOfAllAverage[4], "__EMPTY_5": this.listOfAllAverage[5],"__EMPTY_6": this.listOfAllAverage[6],"__EMPTY_7": this.listOfAllAverage[7],"__EMPTY_8": this.listOfAllAverage[8],"__EMPTY_9": this.listOfAllAverage[9],
        "__EMPTY_10": this.listOfAllAverage[10], "__EMPTY_11": this.listOfAllAverage[11],"__EMPTY_12": this.listOfAllAverage[12],"__EMPTY_13": this.listOfAllAverage[13],"__EMPTY_14": this.listOfAllAverage[14]
        }
        data.push(bnkTot)
        data.push(bnkAve)*/
      
        
      //.modifyAndDownload(formateddata)
        const worksheet = XLSX.utils.json_to_sheet(data);
        
        worksheet["A1"].v = "Banking -1"; // Change A1 cell (Name column header)
        worksheet["B1"].v = ""; // Change B1 cell (Age column header)
        worksheet["C1"].v = "";
        worksheet["D1"].v = "";
        worksheet["E1"].v = ""; // Change E1 cell
        worksheet["F1"].v = ""; // Change F1 cell
        worksheet["G1"].v = ""; // Change G1 cell
        worksheet["H1"].v = ""; // Change H1 cell
        worksheet["I1"].v = ""; // Change I1 cell
        worksheet["J1"].v = ""; // Change J1 cell
        worksheet["K1"].v = ""; // Change K1 cell
        worksheet["L1"].v = ""; // Change L1 cell
        worksheet["M1"].v = ""; // Change M1 cell
        worksheet["N1"].v = ""; // Change N1 cell
        worksheet["O1"].v = ""; // Change O1 cell
        worksheet["P1"].v = ""; // Change P1 cell
        if(this.parentRecord.AccountType__c== 'OVERDRAFT' || this.parentRecord.AccountType__c== 'CC'){
            worksheet["Q1"].v = "";
            worksheet["R1"].v = "";
        }
        
        const merge = [
            { s: { r: 6, c: 1 }, e: { r: 6, c: 2 } },{ s: { r: 6, c: 3 }, e: { r: 6, c: 4 } }, { s: { r: 6, c: 9 }, e: { r: 6, c: 14 } }, { s: { r: 1, c: 0 }, e: { r: 1, c: 2 } }, {s:{ r: 2, c: 0 }, e: { r: 2, c: 1 } },
            {s:{ r: 2, c: 7 }, e: { r: 2, c: 8 } }, {s:{ r: 2, c: 7 }, e: { r: 2, c: 8 } }, {s:{ r: 3, c: 0 }, e: { r: 3, c: 1 } }, {s:{ r: 3, c: 7 }, e: { r: 3, c: 8 } }, {s:{ r: 4, c: 0 }, e: { r: 4, c: 1 } }	,
            {s:{ r: 5, c: 0 }, e: { r: 5, c: 1 } }	
            
          ];
          worksheet["!merges"] = merge;
          let rowsToCreate=9+this._foreditableTableData.length;
          console.log('rowsToCreate'+rowsToCreate)
        for (let i = 9; i <= rowsToCreate; i++) {
            const formula = `SUM(J${i}:K${i}:L${i}:M${i}:N${i}:O${i})/6`;
            const cell = `P${i}`;
            XLSX.utils.sheet_set_array_formula(worksheet, cell, formula);
            
        }
        for (let i = 9; i < rowsToCreate; i++) {
            const rangeForB = `B9:B${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `B${rowsToCreate}`, `SUM(${rangeForB})`);
            const rangeForC = `C9:C${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `C${rowsToCreate}`, `SUM(${rangeForC})`);
            const rangeForD = `D9:D${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `D${rowsToCreate}`, `SUM(${rangeForD})`);
            const rangeForE = `E9:E${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `E${rowsToCreate}`, `SUM(${rangeForE})`);
            const rangeForF = `F9:F${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `F${rowsToCreate}`, `SUM(${rangeForF})`);
            const rangeForG = `G9:G${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `G${rowsToCreate}`, `SUM(${rangeForG})`);
            const rangeForH = `H9:H${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `H${rowsToCreate}`, `SUM(${rangeForH})`);
            const rangeForJ = `J9:J${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `J${rowsToCreate}`, `SUM(${rangeForJ})`);
            const rangeForK = `K9:K${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `K${rowsToCreate}`, `SUM(${rangeForK})`);
            const rangeForL = `L9:L${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `L${rowsToCreate}`, `SUM(${rangeForL})`);
            const rangeForM = `M9:M${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `M${rowsToCreate}`, `SUM(${rangeForM})`);
            const rangeForN = `N9:N${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `N${rowsToCreate}`, `SUM(${rangeForN})`);
            const rangeForO = `O9:O${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `O${rowsToCreate}`, `SUM(${rangeForO})`);
            const rangeForP = `P9:P${rowsToCreate-1}`;
            XLSX.utils.sheet_set_array_formula(worksheet, `P${rowsToCreate}`, `SUM(${rangeForP})`);
            if(this.parentRecord.AccountType__c== 'OVERDRAFT' || this.parentRecord.AccountType__c== 'CC'){
                const rangeForQ = `Q9:Q${rowsToCreate-1}`;
                XLSX.utils.sheet_set_array_formula(worksheet, `Q${rowsToCreate}`, `SUM(${rangeForQ})`);
            }
           
        }
        for (const column of ['B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'O', 'P']) {
            const formula = `=${column}${rowsToCreate}/${this._foreditableTableData.length}`;
            worksheet[`${column}${rowsToCreate+1}`] = { t: "n", f: formula, F: `${column}${rowsToCreate+1}:${column}${rowsToCreate+1}` };
        }
        if(this.parentRecord.AccountType__c== 'OVERDRAFT' || this.parentRecord.AccountType__c== 'CC'){
            let column="Q"
            const formula = `=${column}${rowsToCreate}/${this._foreditableTableData.length}`;
            worksheet[`${column}${rowsToCreate+1}`] = { t: "n", f: formula, F: `${column}${rowsToCreate+1}:${column}${rowsToCreate+1}` };

            worksheet[`R${rowsToCreate}`] =  { t: "n", f: formula, F: `P${rowsToCreate+1}*100/Q${rowsToCreate+1}` }
            for (let i = 9; i <= rowsToCreate; i++) {
                const columnR = `R${i}`;
                const columnP = `P${i}`;
                const columnQ = `Q${i}`;
                worksheet[columnR] = { t: "n", f: `=${columnP}*100/${columnQ}`, F: `${columnR}:${columnR}` };
            }
        }
       

        const workbook = XLSX.utils.book_new();
       XLSX.utils.book_append_sheet(workbook, worksheet, 'Sheet1');
     
        const excelData = XLSX.write(workbook, { bookType: 'xlsx', type: 'binary' });
        const base64Data = btoa(excelData)
        const toRefreshApex = new CustomEvent('torefreshapex', {
        });
        
        this.dispatchEvent(toRefreshApex);
        /*CreateDocumentLink({ parentId: this.parentRecord.DocumentDetail__c, excelData:base64Data})
                .then(result => {
                    console.log('result'+result)
                })
                .catch(error => {
                    console.error('Error fetching account:', error);
                });*/
        
    }
    
    @track showPopForManBnk;
    @track acceptedFormats = ['.xls', '.xlsx'];
    @track uploadedExcFile;
    @track wrapBankObjByExc;
    @track ChildAppBnkDetaByExc;
    @track fieldAPIToSourceColumnMap;
    //@track fieldAPIToSourceColumnMap;
    @track metadataForAppliDetail;
    @track uploadedFiles=[];
    handleFileRemove(){
        this.uploadedFiles=''
    }
    showUploadExcelFile(){
        this.showPopForManBnk=true;

    }
    handleExcelUpload(){
       // console.log('inhandleExcelUpload'+this.uploadedFiles)
        if(this.uploadedFiles.length > 0) {   
          //  console.log('uploadedFiles.length'+this.uploadedFiles.length)
            this.ExcelToJSON(this.uploadedFiles[0]);
        }else{
            console.log('inelseeeee')
            this.showToast("Error!", "error","please select File First.");
        }
    }

    hideManualUplModalBox(){
        this.showPopForManBnk=false;
        this.uploadedFiles='';
    }
    handleUploadFinished(event){
        this.uploadedFiles = event.detail.files;
        const file=this.uploadedFiles[0]
        const fileType = '.' + file.name.split('.').pop();
       
        if(fileType=='.xls' ||fileType=='.xlsx'){
           
        }else{
            this.showToast("Error!", "error","You can only upload excel format type file."); 
            this.uploadedFiles=[];
        }
    }
    ExcelToJSON(file){
        this.showSpinner=true;
        //console.log('this.uploadedFiles'+this.uploadedFiles.length)
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                const workbook = XLSX.read(reader.result, { type: 'binary' });
                const sheetName = workbook.SheetNames[0]; // Assuming the first sheet
                const sheet = workbook.Sheets[sheetName];
               console.log('sheet'+sheet);
               console.log('sheet'+JSON.stringify(sheet));
                const jsonData = XLSX.utils.sheet_to_row_object_array(sheet);
               console.log('jsonData'+JSON.stringify(jsonData)); // Output JSON data to console
               var data = JSON.stringify(jsonData);
               const records = JSON.parse(data);
             console.log('objobjobjobj>>>>>>>>>jsonStr',JSON.stringify(records));
             
              for (const rec of records) {
                for (const key of Object.keys(rec)) {
                    if (key === "") {
                        rec['__EMPTY'] = rec[key];
                        delete rec[key];
                    } if (key === "_1") {
                        rec['__EMPTY_1'] = rec[key];
                        delete rec[key];
                    }
                    if (key === "_2") {
                        rec['__EMPTY_2'] = rec[key];
                        delete rec[key];
                    }
                    if (key === "_3") {
                        rec['__EMPTY_3'] = rec[key];
                        delete rec[key];
                    }
                    
                    if (key === "_4") {
                        rec['__EMPTY_4'] = rec[key];
                        delete rec[key];
                    }
                    if (key === "_5") {
                        rec['__EMPTY_5'] = rec[key];
                        delete rec[key];
                    }
                    if (key === "_6") {
                        rec['__EMPTY_6'] = rec[key];
                        delete rec[key];
                    }
                    if (key === "_7") {
                        rec['__EMPTY_7'] = rec[key];
                        delete rec[key];
                    }
                    if (key === "_8") {
                        rec['__EMPTY_8'] = rec[key];
                        delete rec[key];
                    }
                    if (key === "_9") {
                        rec['__EMPTY_9'] = rec[key];
                        delete rec[key];
                    }
                    if (key === "_10") {
                        rec['__EMPTY_10'] = rec[key];
                        delete rec[key];
                    }
                    if (key === "_11") {
                        rec['__EMPTY_11'] = rec[key];
                        delete rec[key];
                    }
                    if (key === "_12") {
                        rec['__EMPTY_12'] = rec[key];
                        delete rec[key];
                    }
                    if (key === "_13") {
                        rec['__EMPTY_13'] = rec[key];
                        delete rec[key];
                    }
                    if (key === "_14") {
                        rec['__EMPTY_14'] = rec[key];
                        delete rec[key];
                    }
                    if (key === "_15") {
                        rec['__EMPTY_15'] = rec[key];
                        delete rec[key];
                    }
                    if (key === "_16") {
                        rec['__EMPTY_16'] = rec[key];
                        delete rec[key];
                    }
                    if (key === "_17") {
                        rec['__EMPTY_17'] = rec[key];
                        delete rec[key];
                    }
                    if (key === "_18") {
                        rec['__EMPTY_18'] = rec[key];
                        delete rec[key];
                    }
                    
                   /* else if (key.includes('_')) {
                        const newKey = '__EMPTY_' + key.slice(1);
                        rec[newKey] = rec[key];
                        delete rec[key];
                    }*/
                }
            }
            
           // console.log('records'+JSON.stringify(records));
            
            
               this.createRecordForSave(records);
                
             };
            reader.readAsBinaryString(file);
            
        }
    }
    monthNDyEar
    createRecordForSave(records){
        
        const listAllbnkDetailRec=[];
        const appBnkDtailRec=[{"ApplBanking__c":"","Month__c":"","Year__c":"","ValueSummationCredit__c":'',"ValueSummationDebit__c":'',"CountofCredit__c":'',"CountofDebit__c":'',"InwardReturnsCount__c":'',"OutwardReturnsCount__c":'',"StopPaymentCount__c":'',"MinBalanceCharges__c":"","BalanceAt_1st__c":'',"BalanceAt_5th__c":'',"BalanceAt_10th__c":'',"BalanceAt_15th__c":'',"BalanceAt_20th__c":'',"BalanceAt_25th__c":'',"AverageBankBalance__c":''}];
        //console.log('records[jjjj]'+records[3]['__EMPTY_1'])
        /*this.wrapBankObj["Name_of_the_Primary_Account_Holder_s__c"] = records[0]['__EMPTY_2'] !=='undefined' ?  records[0]['__EMPTY_2']: "";
        this.wrapBankObj["AccountName__c"] = records[1]['__EMPTY_1'] !=='undefined' ?  records[1]['__EMPTY_1']: "";
        this.wrapBankObj["AC_No__c"] = records[2]['__EMPTY_1'] !=='undefined' ?  records[2]['__EMPTY_1']: "";

        this.wrapBankObj["PeriodOfBanking__c"] = records[3]['__EMPTY_1'] !=='undefined' ?  records[3]['__EMPTY_1']: "";
        this.wrapBankObj["BankName__c"] = records[1]['__EMPTY_8'] !=='undefined' ?  records[1]['__EMPTY_8']: "";
        this.wrapBankObj["AccountType__c"] = records[2]['__EMPTY_8'] !=='undefined' ?  records[2]['__EMPTY_8']: "";
        this.wrapBankObj["EMIPaidfromthisAccount__c"] = records[4]['__EMPTY_2'] !=='undefined' ?  records[4]['__EMPTY_2']: "";
        console.log(' this.wrapBankObj'+ JSON.stringify(this.wrapBankObj))*/
        let wrapBankObjByExc={};
        if(records[0][this.fieldAPIToSourceColumnMap["Name_of_the_Primary_Account_Holder_s__c"]]){
            wrapBankObjByExc["Name_of_the_Primary_Account_Holder_s__c"]=records[0][this.fieldAPIToSourceColumnMap["Name_of_the_Primary_Account_Holder_s__c"]];
        }else{
            wrapBankObjByExc["Name_of_the_Primary_Account_Holder_s__c"]='';
        }
        if(records[2][this.fieldAPIToSourceColumnMap["AC_No__c"]]){
            wrapBankObjByExc["AC_No__c"]=records[2][this.fieldAPIToSourceColumnMap["AC_No__c"]];
        }else{
            wrapBankObjByExc["AC_No__c"]='';
        }

       
       // wrapBankObjnew["AccountName__c"]=records[1][this.fieldAPIToSourceColumnMap["AccountName__c"]];
       //wrapBankObjnew["EMIPaidfromthisAccount__c"]=records[4][this.fieldAPIToSourceColumnMap["EMIPaidfromthisAccount__c"]];
       //wrapBankObjnew["PeriodOfBanking__c"]=records[3][this.fieldAPIToSourceColumnMap["PeriodOfBanking__c"]];
        //wrapBankObjnew["BankName__c"]=records[1][this.fieldAPIToSourceColumnMap["BankName__c"]];
      // wrapBankObjByExc["AC_No__c"]=records[2][this.fieldAPIToSourceColumnMap["AC_No__c"]];
       const periodOfBankingValue = records[3][this.fieldAPIToSourceColumnMap["PeriodOfBanking__c"]];
        if (periodOfBankingValue && periodOfBankingValue.includes('to')) {
            //console.log('The value contains "to"');
            const [startDateString, endDateString] = records[3][this.fieldAPIToSourceColumnMap["PeriodOfBanking__c"]].split(" to ");
            wrapBankObjByExc["PeriodOfBankingStart__c"]=new Date(startDateString);
            wrapBankObjByExc["PeriodOfBankingEnd__c"]=new Date(endDateString);
        }else {
           // console.log('The value does not contain "to"');
            
        }
        if(records[2][this.fieldAPIToSourceColumnMap["AccountType__c"]]== 'Savings Account'){
            wrapBankObjByExc["AccountType__c"]='Savings';
        }else if(records[2][this.fieldAPIToSourceColumnMap["AccountType__c"]]== 'CASH CREDIT'){
            wrapBankObjByExc["AccountType__c"]='CC';
        }else if(records[2][this.fieldAPIToSourceColumnMap["AccountType__c"]]== 'OVERDRAFT ACCOUNT'){
            wrapBankObjByExc["AccountType__c"]='OVERDRAFT';
        }else if(records[2][this.fieldAPIToSourceColumnMap["AccountType__c"]]== 'CURRENT ACCOUNT'){
            wrapBankObjByExc["AccountType__c"]='CURRENT';
        }else{
            wrapBankObjByExc["AccountType__c"]=records[2][this.fieldAPIToSourceColumnMap["AccountType__c"]];
        }
        
        wrapBankObjByExc["EMIPaidFromThisAccount__c"] = records[4]['__EMPTY_1'] !=='undefined' ?  records[4]['__EMPTY_1']: "";
        wrapBankObjByExc["AccountOf__c"] = records[1]['__EMPTY_1'] !=='undefined' ?  records[1]['__EMPTY_1']: "";
        //const [startDateString, endDateString] = records[3][this.fieldAPIToSourceColumnMap["PeriodOfBanking__c"]].split(" to ");
        /*if(records[2][this.fieldAPIToSourceColumnMap["AccountType__c"]]== 'Savings Account'){
            wrapBankObjByExc["AccountType__c"]='Savings';
        }*/
        
        wrapBankObjByExc["Appl__c"]=this.parentRecord.Appl__c;
        wrapBankObjByExc["LoanAppl__c"]=this._loanApplicantId;
        wrapBankObjByExc["Id"]=this.parentRecord.Id;
        this.wrapBankObjByExc=wrapBankObjByExc;
      // console.log('this.wrapBankObjByExc'+JSON.stringify(wrapBankObjByExc))
        let ChildAppBnkDetaByExc=[];
        //console.log('testttttt1')
        //this.ChildAppBnkDetaByExc=[];           
       for(let i=7; i<records.length-2; i++){
            const newRecord = { ...appBnkDtailRec[0], Month__c: "", Year__c: "", ValueSummationDebit__c: "", ValueSummationCredit__c: "", CountofDebit__c: "", CountofCredit__c:"",InwardReturnsCount__c:"",OutwardReturnsCount__c:"", StopPaymentCount__c:"", MinBalanceCharges__c:"", BalanceAt_1st__c:"", BalanceAt_5th__c:"", BalanceAt_10th__c:"",BalanceAt_15th__c:"", BalanceAt_20th__c:"", BalanceAt_25th__c:"",MonthlyLimit__c:"",Utilization__c:""};
            for(const rec of this.metadataForAppliDetail){
                if(rec.Field_API_Name__c =='Month__c,Year__c'){
                    const dateOfPeriod = records[i][rec.SourceColumn__c];
                    const monthNdYear='';
                    if(this.isMonthYearFormat(dateOfPeriod)){
                       // console.log('dateOfPeriod'+dateOfPeriod)
                        this.monthNDyEar=dateOfPeriod
                       
                    }else{
                        var dateFormat=this.convertDate(dateOfPeriod);
                        this.monthNDyEar=this.getFormattedDate(dateFormat);
                    }
                    const [month, year] = this.monthNDyEar.split('-');
                    newRecord.Month__c=month;
                    newRecord.Year__c=year;
                }else if(rec.Field_API_Name__c =='CountofDebit__c' || rec.Field_API_Name__c =='CountofCredit__c'){
                    newRecord[rec.Field_API_Name__c]= parseFloat(records[i][rec.SourceColumn__c]);
                }
                else{
                    newRecord[rec.Field_API_Name__c]= records[i][rec.SourceColumn__c] !=='undefined'? records[i][rec.SourceColumn__c]:"" ;
                }
            }
            ChildAppBnkDetaByExc.push(newRecord)
            this.ChildAppBnkDetaByExc=ChildAppBnkDetaByExc;
          //  console.log('this.ChildAppBnkDetaByExc>>'+this.ChildAppBnkDetaByExc)
            
        }
        this.handleSaveData();
    }
    isMonthYearFormat(dateString) {
        return /^[A-Z]{3}-\d{4}$/.test(dateString);
    }
    convertDate(originalDate) {
        const excelSerialDate = parseInt(originalDate);
        const millisecondsInDay = 24 * 60 * 60 * 1000; // Number of milliseconds in a day
        const dateOffset = (excelSerialDate - 25569) * millisecondsInDay; // Offset from 1/1/1970
        const targetDate = new Date(dateOffset);
        const month = targetDate.getMonth() + 1; // Month is zero-based, so add 1
        const day = targetDate.getDate();
        const year = targetDate.getFullYear();
        const formattedDate = `${month.toString().padStart(2, '0')}/${day.toString().padStart(2, '0')}/${year}`;
        return formattedDate;
    }
    getFormattedDate(dateFormat) {
        const dateParts = dateFormat.split('/');
        const monthNumber = parseInt(dateParts[0]);
        const year = dateParts[2];
        const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
        const monthAbbreviation = months[monthNumber - 1];
        return `${monthAbbreviation}-${year}`;
    }
    handleSaveData(){
      
        let ChildRecords = [];
        let DataRecords = [];
        let upsertDataList=[];
        let childRecordObj = {};
        this.wrapBankObjByExc.sobjectType='ApplBanking__c'; 
        
        if(this.ChildAppBnkDetaByExc){
            for(var i=0;i<this.ChildAppBnkDetaByExc.length;i++){
            childRecordObj = {...this.ChildAppBnkDetaByExc[i]};
            childRecordObj.sobjectType='ApplBankDetail__c',
            ChildRecords.push(childRecordObj);
           }  
        }
        
        let upsertData={                       
            parentRecord:this.wrapBankObjByExc,                       
            ChildRecords:ChildRecords,
            ParentFieldNameToUpdate:'ApplBanking__c'
        }
       
        updateData ({upsertData:upsertData})
            .then(result => {  
                console.log('inhandleSaveeee')
                this.showSpinner=false;
                this.showPopForManBnk=false;
                this.uploadedFiles='';
                this.showSpinner=false;
                this.showToast("Success!", "success","Manual Banking Upload Successfully.");
                //if(this._foreditableTableData){
                    this.handleDelAppDetAfterUpload();
                //}
                //this.handleFileCreation();
            }).catch(error => {
                
                console.log('errorerrorerrorerror'+JSON.stringify(error));
                if(error.body && error.body.message.includes("Unable to read SObject")){
                    this.showToast("Error!", "error","Please Upload correct file format of Manual Banking Upload.");
                }
                this.showSpinner=false;

        })
    }
    
    @wire(getJsonToExcelMetadata)
    wiredJsonToExcelMetadata({ error, data }) {
        if (data) {
           // console.log('Metadata Retrieved: ', data);
            let fieldAPIToSourceColumnMap = {};
            data.forEach(record => {
                fieldAPIToSourceColumnMap[record.Field_API_Name__c] = record.SourceColumn__c;
            });
            this.fieldAPIToSourceColumnMap=fieldAPIToSourceColumnMap;
         //   console.log('fieldAPIToSourceColumnMap'+JSON.stringify(this.fieldAPIToSourceColumnMap))

        } else if (error) {
            console.error('Error retrieving metadata: ', error);
        }
    }
    @wire(jsonExcelMetadataForAppliDetail)
    wiredMetadataForAppBnkDetail({ error, data }) {
        if (data) {
            console.log('Metadata Retrieved for applibnkdeatil: ', data);
            this.metadataForAppliDetail=data;
            
        } else if (error) {
            console.error('Error retrieving metadata: ', error);
        }
    }
    handleDelAppDetAfterUpload(){
        const newList = this._foreditableTableData.map(item => {
            const newItem = { ...item };
            delete newItem.MonthlyLimit; // Remove MonthlyLimit property
            return newItem;
        })
        deleteRecord({ rcrds: newList })
            .then(result => {
                this.showSpinner=false;
                refreshApex(this._wiredApplicantBanking); 
                refreshApex(this._wiredApplicantRecData);
            })
            .catch(error => {
                console.error(error);
            });
    }
    

}