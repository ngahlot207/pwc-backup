import { LightningElement, api, wire, track } from 'lwc';
import fetchRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import fetchSingleObject from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import insertMultipleRecord from '@salesforce/apex/ObligatoryDtls.insertMultipleRecord';
import upsertManualRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleParentsWithMultipleChilds';
import { createRecord,updateRecord ,deleteRecord} from "lightning/uiRecordApi";
import getData from '@salesforce/apex/SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord, getObjectInfo ,getPicklistValues, getPicklistValuesByRecordType} from 'lightning/uiObjectInfoApi';
import BUREAU_OBJECT from '@salesforce/schema/Bureau__c';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import {subscribe, publish, MessageContext, APPLICATION_SCOPE} from 'lightning/messageService';
import updateData from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import { refreshApex } from '@salesforce/apex';
import TREATMENT from '@salesforce/schema/BureauRespDtl__c.Treatment__c';
import LOANCAPACITY from '@salesforce/schema/BureauRespDtl__c.LoanCapacity__c';
import ApplObligation from '@salesforce/schema/BureauRespDtl__c';
// Custom labels
import ObligationBanking_EmiDate_ErrroMessage from '@salesforce/label/c.ObligationBanking_EmiDate_ErrroMessage';
import ObligationBanking_Update_SuccessMessage from '@salesforce/label/c.ObligationBanking_Update_SuccessMessage';
import ObligationBanking_ReqFields_ErrorMessage from '@salesforce/label/c.ObligationBanking_ReqFields_ErrorMessage';
import ObligationBanking_value_ErrorMessage from '@salesforce/label/c.ObligationBanking_value_ErrorMessage';
import ObligationBanking_Del_SuccessMessage from '@salesforce/label/c.ObligationBanking_Del_SuccessMessage';
import LOGIN_DATE from "@salesforce/schema/LoanAppl__c.LoginMonthAndYear__c";
import LOAN_APP_ID from "@salesforce/schema/LoanAppl__c.Id";
const DELAY = 500;
import formFactorPropertyName from "@salesforce/client/formFactor";
export default class ObligationChildDetails extends LightningElement {
    

    customLabel = {
        ObligationBanking_EmiDate_ErrroMessage,
        ObligationBanking_Update_SuccessMessage,
        ObligationBanking_ReqFields_ErrorMessage,
        ObligationBanking_value_ErrorMessage,
        ObligationBanking_Del_SuccessMessage

    }
    //mobile view
    desktopBoolean = false;
    phoneBolean = false;
    @track formFactor = formFactorPropertyName;
    @api title = 'Obligation Details';

    //end
    loginAccepatnceDate;
    @track _wiredAppObliResponse;
    loanAppRec;
    loanStage;
    loanSubstage;
    QDEStageVisible=false;
    manualTenureValue;
    appObligaRecs;
    appObligaList;
    RTConsumerId;
    RTCommercialId;
    @track allRecOfApplObwithDetai;
    BruRecord;
    @track _wiredBruData;
    @track _wiredAppName;
    @track _wiredmdtData;
    @track _wiredRTData;
    @track _wiredStageName;
    @track _wiredManualData;
    @track BRURecords = []
    @track AppNameList = []
    @track mdtNameList = []
    @track newBlankListOfAppObliRec=[];
    @track FinalManualList =[]
    newManualrecord
    applIdfromName= [];

    @track obligArr=[]
    @track obligArr_s=[]
   // @track appObligDetailIds=[];
   @api isReadOnly;
   @track disableMode;
   @api hasEditAccess;

   @track NatureOfLoanValue;
    searchResults
    selectedSearchResult
    @track delayTimeout;
    preventClosingOfSerachPanel=false;

   @api layoutSize;
   @track requiredFlag = false;
  // @track params;
  required=true;
    
    TreatmentOptions=[]
    LoanCapacityOptions=[]
    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        //console.log('Loan App Id ! '+value);
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);            
        this.handleRecordIdChange(value);        
    }
    

    get optionsEmiSource() {
        return [
            { label: 'Bureau', value: 'Bureau' },
            { label: 'Estimated', value: 'Estimated' },
        ];
    }
    ConsumerProduct=['Auto Loan','Housing Loan','Property Loan','Loan Against Shares/Securities','Personal Loan','Consumer Loan','Education Loan','Loan to Professional','Leasing','Overdraft','Two-wheeler Loan','Loan Against Bank Deposits','Commercial Vehicle Loan','GECL Loan Secured','GECL Loan Unsecured','Used Car Loan','Construction Equipment Loan','Tractor Loan','Loan on Credit Card','Mudra Loans – Shishu / Kishor / Tarun','Microfinance – Business Loan','Microfinance – Personal Loan','Microfinance – Housing Loan','Microfinance – Other','P2P Personal Loan','P2P Auto Loan','P2P Education Loan','Business Loan – Secured','Business Loan – General','Business Loan – Priority Sector – Small Business','Business Loan – Priority Sector – Agriculture','Business Loan – Priority Sector – Others','Business Loan - Unsecured','Other']
    CommercialProduct=['Cash credit','Overdraft','Demand loan','Medium term loan (period above 1 year and up to 3 years)','Long term loan (period above 3 years)','Lease finance','Hire purchase','Commercial vehicle loan','Equipment financing (construction office medical)','Unsecured business loan','Short term loan (less than 1 year)','Auto Loan','Property Loan','Gold Loan','HealthCare Finance','Infrastructure Finance','GECL Loan','Others'];
    handleRecordIdChange(){        
        let tempParamManual = this.manualparams;
        console.log('aaaaaaaaaaaaaaaaaaaaa1')
        tempParamManual.queryCriteria = ' where LoanApplication__c= \'' + this.loanAppId + '\' AND Source__c = \'Manual\' AND (RecordType.name = \'Consumer Obligation\' OR RecordType.name = \'Commercial Obligation\' )';
        console.log('aaaaaaaaaaaaaaaaaaaaa2')
        this.manualparams = {...tempParamManual};
        console.log('aaaaaaaaaaaaaaaaaaaaa')
      

        let tempParamsApp = this.AppNameParam;
        tempParamsApp.queryCriteria = ' where id = \'' + this.loanAppId + '\'';
        this.AppNameParam = {...tempParamsApp};

        
        console.log('aaaaaaaaaaaaaaaaaaaaa')
        let tempParamsAppDummy = this.AppNameDetailsParam;
        tempParamsAppDummy.queryCriteria = ' where LoanAppln__c = \'' + this._loanAppId + '\'';
        this.AppNameDetailsParam = {...tempParamsAppDummy};
        console.log('aaaaaaaaaaaaaaaaaaaaa')
        let tempLoanStageParams = this.LoanStageParam;
        tempLoanStageParams.queryCriteria = ' where id = \'' + this.loanAppId + '\'';
        this.LoanStageParam = {...tempLoanStageParams};
        console.log('aaaaaaaaaaaaaaaaaaaaa')
        let tempParamsBru = this.paramsBru;
        tempParamsBru.queryCriteria = ' where LoanApp__c= \'' + this.loanAppId + '\' AND IsLatest__c = true';
        this.paramsBru = {...tempParamsBru};
        console.log('aaaaaaaaaaaaaaaaaaaaa')
        this.handleAppObligDetails(null);

    }
    @track paramsBru={
            
        ParentObjectName:'Bureau__c',          
            parentObjFields:[ 'Id','LoanApp__c','Applicant__r.Total_Live_Loan__c','Applicant__r.FullName__c', 'Source__c','name','Score__c', 'Totalliveloan__c','Totalloanexposure__c','Totalsecuredloan__c','Totalunsecuredloan__c','Totalcreditcardoutstanding__c','Totaloanoverdue__c','Totalcreditcardoverdue__c','MaxcurrentDPDLiveFacilities__c','MaxDPDlast12months__c','TotalEnquiries__c','Report_date__c','IsLatest__c','Trigger_Type__c','TotalEnquirieslast30day__c'],        
            queryCriteria: ' where LoanApp__c= \'' + this.loanAppId + '\' AND IsLatest__c = true'
    
        }

    @track paramsSys={
        ParentObjectName:'LoanAppl__c',
        ChildObjectRelName:'BureauRespDtl__r',
        parentObjFields:['Id','Stage__c','SubStage__c','LoginAcceptDate__c'],
        childObjFields:[ 'Id','Applicant__c', 'Bureau__c', 'CloseDate__c', 'ConsiderObligation__c', 'CurrentOs__c', 'DisbursalDate__c', 'EMISource__c', 'EMI__c', 'Ever90__c', 'FinancierNameID__c', 'FinancierName__c', 'LoanAmount__c', 'LoanApplication__c', 'LoanCapacity__c', 'LoanName__c', 'MaxDPDLst12month__c', 'MaxDPDLst3month__c', 'MaxDPDLst6month__c', 'NatureOfLoan__c', 'NoEMIPaid__c', 'Overdues__c', 'RepayAc__c', 'RepaymentBankID__c', 'Repayment_Bank__c', 'Source__c', 'TenureLeft__c', 'Tenure__c', 'Treatment__c'],        
        queryCriteria: ' where id = \'' + this.loanAppId + '\''

    }

    @track AppNameDetailsParam ={
        ParentObjectName:'Applicant__c',
        parentObjFields:['Id','FullName__c','Constitution__c', 'LoanAppln__c'],
        childObjFields:[],        
        queryCriteria: ' where LoanAppln__c= \'' + this._loanAppId + '\''
    }

    @track AppNameParam ={
        ParentObjectName:'LoanAppl__c',
        ChildObjectRelName:'Applicants__r',
        parentObjFields:['Id'],
        childObjFields:[ 'Id','FullName__c','Constitution__c'],        
        queryCriteria: ' where Id= \'' + this.loanAppId + '\''

    }

    @track mdtParam ={
        ParentObjectName:'MultiBureau_Response_Master__mdt',        
        parentObjFields:['Loan_Type__c'],              
        queryCriteria: ''

    }

    @track LoanStageParam ={
        ParentObjectName:'LoanAppl__c',        
        parentObjFields:['Id','Stage__c','LoginMonthAndYear__c','SubStage__c','LoginAcceptDate__c'],              
        queryCriteria: ' where Id= \'' + this.loanAppId + '\''

    }

    @track RTParam = {
        ParentObjectName:'RecordType',        
        parentObjFields:['Id','Name','DeveloperName','SobjectType'],              
        queryCriteria: ' where SobjectType = \'BureauRespDtl__c\' AND (DeveloperName = \'Consumer_Obligation\' OR DeveloperName = \'Commercial_Obligation\')'
    }
    

    parentIdForObliga;
    //fetching third records
    @track manualparams ={
        ParentObjectName:'BureauRespDtl__c',
        ChildObjectRelName:'Applicant_Obligation_detail__r',
        parentObjFields:[ 'Id', 'Source__c', 'EMIClearanceDate__c','BounceInLast12Months__c','BounceInLast18Months__c','TotalBouncesInRTR__c','RepaymentBankID__c','FinancierNameID__c','LoanName__c', 'EMISource__c', 'NatureOfLoan__c','NatureOfLoanID__c', 'FinancierName__c', 'LoanCapacity__c', 'ConsiderObligation__c', 'RepayAc__c', 'Treatment__c', 'NoEMIPaid__c', 'LoanAmount__c', 'Ever90__c', 'MaxDPDLst12month__c', 'MaxDPDLst6month__c', 'Overdues__c', 'MaxDPDLst3month__c', 'TenureLeft__c', 'Tenure__c', 'Applicant__c', 'LoanApplication__c', 'Bureau__c', 'CloseDate__c', 'DisbursalDate__c', 'CurrentOs__c', 'EMI__c'],
        childObjFields:['Id', 'BureauRespDtl__c', 'EMI_Clearance_Date_Identifier__c', 'EMI_Clearance_Date_IdentifierTest__c','EMI_Clearance_Date__c', 'BureauRespDtl__r.id'],        
        queryCriteria: ' where LoanApplication__c= \'' + this.loanAppId + '\' AND Source__c = \'Manual\' AND (RecordType.name = \'Consumer Obligation\' OR RecordType.name = \'Commercial Obligation\')'
    }
    
    @wire(getData,{params:'$manualparams'})
    ManualData(wiredManualData) {
        const { data, error } = wiredManualData;
        this._wiredManualData = wiredManualData;
        if (data) {
            
           this.newManualrecord=JSON.parse(JSON.stringify(data));
           this.newBureau='Yes';
                this.showNewBureauTable=true;
                this.newManualrecord= this.newManualrecord.map((record, index) => {
                    return {...record,index: index+1,isDirty : false};
                  });
            console.log(' after map newManualrecord',this.newManualrecord)

                  var parentId;
                  
                  for(const record of this.newManualrecord){

                    parentId=record.parentRecord.Id;
                    //this.parentIdForObliga=record.parentRecord.Id;
                    if(record.ChildReords && record.ChildReords != undefined){
                        record.ChildReords = this.handleListChild(record.ChildReords,parentId);
                        //console.log('!!!!!!!!!!!!!!!!!!!'+JSON.stringify(record.ChildReords));
                    }else{
                        record.ChildReords = this.handleListChildnew(record.ChildReords,parentId);
                    }
                    
                }
                let tempManualArr=[...this.newManualrecord] 
                this.newBlankListOfAppObliRec =  JSON.parse(JSON.stringify(tempManualArr));
                console.log('data in manual',JSON.stringify(this.newBlankListOfAppObliRec))
                 this.newBlankListOfAppObliRec =  tempManualArr;

                 this.totalLoanAmount_m =0;
                this.totalCurrentOS_m=0;
                this.totalEMI_m=0;
                this.totalContinueObli_m=0;
                this.obligArr=[];
                //adding total for manual table
                for(const record of this.newBlankListOfAppObliRec){
                    // this.totalLoanCapacity  +=  record.parentRecord.LoanCapacity__c == '' ||  record.parentRecord.LoanCapacity__c == null ||  record.parentRecord.LoanCapacity__c == undefined ? Number(0) :  Number(record.parentRecord.LoanCapacity__c);
                    this.totalLoanAmount_m  +=  record.parentRecord.LoanAmount__c == '' ||  record.parentRecord.LoanAmount__c == null ||  record.parentRecord.LoanAmount__c == undefined ? Number(0) :  Number(record.parentRecord.LoanAmount__c);
                    this.totalCurrentOS_m  +=  record.parentRecord.CurrentOs__c == '' ||  record.parentRecord.CurrentOs__c == null ||  record.parentRecord.CurrentOs__c == undefined ? Number(0) :  Number(record.parentRecord.CurrentOs__c);
                    this.totalEMI_m  +=  record.parentRecord.EMI__c == '' ||  record.parentRecord.EMI__c == null ||  record.parentRecord.EMI__c == undefined ? Number(0) :  Number(record.parentRecord.EMI__c);
                   
                    //this.totalRepayAc  +=  record.parentRecord.RepayAc__c == '' ||  record.parentRecord.RepayAc__c == null ||  record.parentRecord.RepayAc__c == undefined ? Number(0) :  Number(record.parentRecord.RepayAc__c);
                
                    if(record.parentRecord.Treatment__c=='To continue - Obligate'){
                        // record.parentRecord.ConsiderObligation__c ='Yes';
                         this.obligArr.push(record);
                     }                
                     this.totalContinueObli_m=this.obligArr.length  
                }

                console.log('this.totalContinueObli_m retrieve',this.totalContinueObli_m)
            
        } else if (error) {
            console.log(error);
        }
        
    }
    @wire(getData,{params:'$LoanStageParam'})
    StageName(wiredStageName) {
        const { data, error } = wiredStageName;
        this._wiredStageName = wiredStageName;
        let tempName=[]
        let valueStage
        if (data) {
            console.log('datafromAppNameParam'+JSON.stringify(data))
            valueStage=JSON.parse(JSON.stringify(data));
            console.log('value of loan stage', valueStage)
            this.loginAccepatnceDate=valueStage[0].parentRecord.LoginAcceptDate__c;
            if(typeof valueStage[0].parentRecord.LoginMonthAndYear__c!=='undefined'){
                var loginMonthNdYear=valueStage[0].parentRecord.LoginMonthAndYear__c;
                this.handleMonthAndYearHeaderWihRec(loginMonthNdYear);
            }
            console.log('value of loginAccepatnceDate', this.loginAccepatnceDate)
            this.loanStage=valueStage[0].parentRecord.Stage__c;
                  this.loanSubstage=valueStage[0].parentRecord.SubStage__c;
                  console.log('loanStage',this.loanStage);
                  console.log('loansubStage',this.loanSubstage);
                  if(this.loanStage=='QDE' && (this.loanSubstage=='RM Data Entry' || this.loanSubstage=='Pre Login Query' || this.loanSubstage=='Pre login Query')){
                      this.QDEStageVisible=true;
                      console.log('QDEStageVisible',this.QDEStageVisible);
                  }
           
           
        }      

        else if (error) {
            console.log(error);
        }
        
    }
    
      
    
tempArrAppConst=[]
listOfallRecOfApplObwithDetai=[];
   
    handleAppObligDetails(listOfAppOblDetaIds){
        const mapOfAppBankIdWithDetail=new Map();
        //adding let params
        let currentDate= new Date().toISOString().substring(0, 10);
        console.log('current date in manual table',currentDate)
        
        let noOfemiCal
           let params ={
                ParentObjectName:'BureauRespDtl__c',
                ChildObjectRelName:'Applicant_Obligation_detail__r',
                parentObjFields:[ 'Id', 'Source__c','Applicant__r.FullName__c','EMIClearanceDate__c','BounceInLast12Months__c','BounceInLast18Months__c','TotalBouncesInRTR__c','Repayment_Bank__c', 'RepaymentBankID__c','LoanName__c', 'EMISource__c', 'NatureOfLoan__c', 'FinancierName__c', 'LoanCapacity__c', 'ConsiderObligation__c', 'RepayAc__c', 'Treatment__c', 'NoEMIPaid__c', 'LoanAmount__c', 'Ever90__c', 'MaxDPDLst12month__c', 'MaxDPDLst6month__c', 'Overdues__c', 'MaxDPDLst3month__c', 'TenureLeft__c', 'Tenure__c', 'Applicant__c', 'LoanApplication__c', 'Bureau__c', 'CloseDate__c', 'DisbursalDate__c', 'CurrentOs__c', 'EMI__c','Status__c','FinancierNameID__c'],
                childObjFields:['Id', 'BureauRespDtl__c', 'EMI_Clearance_Date_Identifier__c', 'EMI_Clearance_Date__c','EMI_Clearance_Date_IdentifierTest__c', 'BureauRespDtl__r.id'],        
                queryCriteria: ' WHERE LoanApplication__c = \''+this._loanAppId+'\' AND Source__c != \'Manual\' AND ((RecordType.name = \'Consumer Obligation\' AND NatureOfLoan__c IN  (\''+this.ConsumerProduct.join('\', \'') + '\'))OR (RecordType.name = \'Commercial Obligation\' AND  CrdFacType__c = \'Current\'  AND NatureOfLoan__c IN  (\''+this.CommercialProduct.join('\', \'') + '\')))'
          }
          
            getData({ params: params })
            .then((data) => {
                let tempArr=[];
                let Arr=[]
               
                tempArr=JSON.parse(JSON.stringify(data));
                console.log('tempArr',tempArr)

                for(var i = 0; i < tempArr.length; i++){
                    //if(tempArr[i].parentRecord.NatureOfLoan__c =='Credit Card'){
                        let CloseDate__c=tempArr[i].parentRecord.CloseDate__c; 
                        console.log('CloseDate__c',CloseDate__c)                   
                    let c1=new Date(currentDate).getFullYear() - new Date(CloseDate__c).getFullYear();
                     let c2=(new Date(currentDate).getMonth() - new Date(CloseDate__c).getMonth());           
                    let closeCal = (((c1)*12) + (c2));
                    console.log('closeCal',closeCal)
                    console.log('tempArr[i]',tempArr[i])
                  //  console.log('this.allRecOfApplObwithDetai.push(tempArr[i])',this.allRecOfApplObwithDetai.push(tempArr[i]))
                        if(closeCal<=12 || CloseDate__c==undefined){
                            Arr.push(tempArr[i])
                        }
                       else{

                       }
                  
                }
                console.log('Arr',Arr);
                this.allRecOfApplObwithDetai=[...Arr];
                console.log('adding into allRecOfApplObwithDetai',this.allRecOfApplObwithDetai)
                this.allRecOfApplObwithDetai = this.allRecOfApplObwithDetai.map((record, index) => {


                    return {...record,index: index+1};
                  });

                  var parentId;                  
                  console.log('this.allRecOfApplObwithDetai dec'+JSON.stringify(this.allRecOfApplObwithDetai));
                  
                  
                  for(const record of this.allRecOfApplObwithDetai){

                    parentId=record.parentRecord.Id;
                    this.parentIdForObliga=record.parentRecord.Id;
                    
                    console.log('record.parentRecord.NoEMIPaid__c',record.parentRecord.NoEMIPaid__cc)
                    if(record.ChildReords && record.ChildReords != undefined){
                        record.ChildReords = this.handleListChild(record.ChildReords,parentId);
                    }else{
                        record.ChildReords = this.handleListChildnew(record.ChildReords,parentId);
                    }
                    
                }
                this.handleCalculation();
                
                console.log('this.allRecOfApplObwithDetai 05dec23'+JSON.stringify(this.allRecOfApplObwithDetai[0].childRecords));
                console.log('this.allRecOfApplObwithDetai dec'+this.allRecOfApplObwithDetai[0].childRecords.length);
                console.log('this.allRecOfApplObwithDetai dec'+this.allRecOfApplObwithDetai[1].childRecords.length);
                  
                this.listOfallRecOfApplObwithDetai=this.allRecOfApplObwithDetai;
            })
            .catch(error => {
                console.log('Errorured:- '+JSON.stringify(error));
            });

            

    }

    
     monthList=['Month1','Month2','Month3','Month4','Month5','Month6','Month7','Month8','Month9','Month10','Month11','Month12']
        handleListChild( listOfAllChildReco,parentId){
        const mapOfmonthWithRec={};
            //console.log('listOfAllChildReco>>>'+JSON.stringify(listOfAllChildReco));
            for (let i = 0; i < listOfAllChildReco.length; i++) {
                let record = listOfAllChildReco[i];
                let emiIdentifier = record.EMI_Clearance_Date_Identifier__c;
                //console.log('emiIdentifier'+emiIdentifier);
                if (emiIdentifier && emiIdentifier !== "") {
                    mapOfmonthWithRec[emiIdentifier] = record;
                }
            }
            //console.log('mapOfmonthWithRec>>2>'+JSON.stringify(mapOfmonthWithRec));
            var newListOfChilds=[];
           // console.log('keys>>>'+mapOfmonthWithRec.keys());
            for(const record of this.monthList){
                //console.log('record>>>'+record)
                if(mapOfmonthWithRec.hasOwnProperty(record)){
                    newListOfChilds.push(mapOfmonthWithRec[record]);
                }else{
                    let temp = {"BureauRespDtl__c": parentId, "EMI_Clearance_Date_Identifier__c":record, "EMI_Clearance_Date__c":""};
                    newListOfChilds.push(temp);
                }
            }
            //console.log('newListOfChilds>>>'+JSON.stringify(newListOfChilds));
            listOfAllChildReco = newListOfChilds;
            //console.log('listOfAllChildReco>>>'+JSON.stringify(listOfAllChildReco));
            return listOfAllChildReco;
    }

    handleListChildnew( listOfAllChildReco,parentId){
        const mapOfmonthWithRec={};
            var newListOfChilds=[];
           // console.log('keys>>>'+mapOfmonthWithRec.keys());
            for(const record of this.monthList){
                //console.log('record>>>'+record)
                if(mapOfmonthWithRec.hasOwnProperty(record)){
                    newListOfChilds.push(mapOfmonthWithRec[record]);
                }else{
                    let temp = {"BureauRespDtl__c": parentId, "EMI_Clearance_Date_Identifier__c":record, "EMI_Clearance_Date__c":""};
                    newListOfChilds.push(temp);
                }
            }
            //console.log('newListOfChilds>>>'+JSON.stringify(newListOfChilds));
            listOfAllChildReco = newListOfChilds;
            //console.log('listOfAllChildReco>>>'+JSON.stringify(listOfAllChildReco));
            return listOfAllChildReco;
    }

    
    totalLoanCapacity=0;
    totalLoanAmount=0
    totalCurrentOS=0
    totalEMI=0;
   
    grandCurrentOS=0
    grandLoanAmount=0;
    grandEMI=0;
    grandObligatory=0;


    totalLoanAmount_m=0
    totalEMI_m=0;
    totalRepayAc=0;
    totalCurrentOS_m=0;
    totalContinueObli=0;
    totalContinueObli_m=0;

    get LoanAmountCal(){
       return this.grandLoanAmount=this.totalLoanAmount_m + this.totalLoanAmount;
        
    }
    get OSAmountCal(){
        return this.grandCurrentOS=this.totalCurrentOS_m + this.totalCurrentOS;
         
     }
     get EMICal(){
        return this.grandEMI=this.totalEMI_m + this.totalEMI;
         
     }
     get ObligCal(){
        console.log('this.totalContinueObli_m',this.totalContinueObli_m);
        console.log('this.totalContinueObli',this.totalContinueObli);
        console.log('this.grandContinueObli',this.grandObligatory);
        return this.grandObligatory=this.totalContinueObli_m + this.totalContinueObli;       

         
     }
    handleCalculation(){
        //console.log('********');
        
        var ContinueObliList = [];
        for(const record of this.allRecOfApplObwithDetai){
            if(record.parentRecord.Treatment__c=='To continue - Obligate'){
                record.parentRecord.ConsiderObligation__c ='Yes';
                ContinueObliList.push(record);
            }else{
                record.parentRecord.ConsiderObligation__c ='No';
            }

            this.totalContinueObli=ContinueObliList.length
        }
        //console.log('this.allRecOfApplObwithDetai.parentRecord'+JSON.stringify(this.allRecOfApplObwithDetai.parentRecord));
        for(const record of this.allRecOfApplObwithDetai){
            // this.totalLoanCapacity  +=  record.parentRecord.LoanCapacity__c == '' ||  record.parentRecord.LoanCapacity__c == null ||  record.parentRecord.LoanCapacity__c == undefined ? Number(0) :  Number(record.parentRecord.LoanCapacity__c);
            this.totalLoanAmount  +=  record.parentRecord.LoanAmount__c == '' ||  record.parentRecord.LoanAmount__c == null ||  record.parentRecord.LoanAmount__c == undefined ? Number(0) :  Number(record.parentRecord.LoanAmount__c);
            this.totalCurrentOS  +=  record.parentRecord.CurrentOs__c == '' ||  record.parentRecord.CurrentOs__c == null ||  record.parentRecord.CurrentOs__c == undefined ? Number(0) :  Number(record.parentRecord.CurrentOs__c);
            this.totalEMI  +=  record.parentRecord.EMI__c == '' ||  record.parentRecord.EMI__c == null ||  record.parentRecord.EMI__c == undefined ? Number(0) :  Number(record.parentRecord.EMI__c);
            this.totalRepayAc  +=  record.parentRecord.RepayAc__c == '' ||  record.parentRecord.RepayAc__c == null ||  record.parentRecord.RepayAc__c == undefined ? Number(0) :  Number(record.parentRecord.RepayAc__c);
            
            if(record.parentRecord.Treatment__c=='To continue - Obligate'){
                // record.parentRecord.ConsiderObligation__c ='Yes';
                this.obligArr_s.push(record);
             }                
                
          
         this.totalContinueObli=this.obligArr_s.length  
         console.log('this.totalContinueObli update',this.totalContinueObli)

        }
    }
    rowIndex;
    cloumnIndex;
    handleRowClick(event) {
        //console.log('handleRowClick'+event.currentTarget.dataset.rowIndex);
        const rowIndex = event.currentTarget.dataset.rowIndex;
        this.rowIndex = rowIndex;
        //console.log('this.rowIndex'+this.rowIndex);
        
    }
    handleColumnClick(event) {
        //console.log('>>>>>>>>>>>>>>>>>>'+event.currentTarget.dataset.cloumnIndex);
        this.cloumnIndex = event.currentTarget.dataset.cloumnIndex;
        //console.log('this.cloumnIndex'+this.cloumnIndex);
        
    }
    handleLoginAceptanceDate(event){
        let newDate = event.target.value;
        console.log('parentIndex'+event.target.dataset.index)
        const date1 = new Date(newDate);
        var oldDate=this.loginAccepatnceDate
        const date2 = new Date(this.loginAccepatnceDate);
        const monthMap = { 0: 'January', 1: 'February', 2: 'March', 3: 'April', 4: 'May', 5: 'June', 6: 'July', 7: 'August', 8: 'September', 9: 'October', 10: 'November', 11: 'December', };
        const monthName = monthMap[date2.getMonth()];
        console.log('date1.getMonth()'+date1.getMonth())
        console.log('date1.getMonth()>>>>'+date2.getMonth())
        if(date1.getMonth() !== date2.getMonth()){
            console.log('>>>>>>iniffff')
            
            this.showToast("Error!", "error", this.customLabel.ObligationBanking_EmiDate_ErrroMessage +monthName,"sticky");
            //console.log('oldDate'+oldDate);
           this.loginAccepatnceDate=oldDate
        }else{
            console.log('>>>>>>iniffffelse')
            //this.loginAccepatnceDate=newDate
            let obligatoryDetails = this.newBlankListOfAppObliRec[event.target.dataset.index]
            obligatoryDetails.parentRecord[event.target.dataset.field] = event.target.value; 
            obligatoryDetails.isDirty=true;
            this.newBlankListOfAppObliRec[event.target.dataset.index] = obligatoryDetails;  
        }
    }

    showToast(title, variant, message,mode) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
    
    handleDateChange(event){

        let parentIndex = event.target.dataset.parentIndex;
        let childIndex = event.target.dataset.cloumnIndex;
        let parentRecord = this.allRecOfApplObwithDetai[parentIndex];
        let childRecords = parentRecord.ChildReords[childIndex];
        let fieldName = event.target.dataset.field;
        childRecords[fieldName] = event.target.value;
        console.log('childRecords'+JSON.stringify(childRecords))
       // this.allRecOfApplObwithDetai=this.allRecOfApplObwithDetai;
        /*let monthEntered=event.target.value.slice(5,7);
        let monthCheck= childRecords.EMI_Clearance_Date_Identifier__c.slice(-1);              
        let LoginMonth = this.loginAccepatnceDate.slice(5,7);
        let acceptedDate=LoginMonth-monthCheck;*/
            

    }
    
    handleManualDateChange(event){
        
        let parentIndex = event.target.dataset.parentIndex;
        let childIndex = event.target.dataset.cloumnIndex;
        let parentRecord = this.newBlankListOfAppObliRec[parentIndex];
        let childRecords = parentRecord.ChildReords[childIndex];
        let fieldName = event.target.dataset.field;
        // childRecords[fieldName] = event.target.value;
        let monthEntered=event.target.value.slice(5,7);
        let monthCheck= childRecords.EMI_Clearance_Date_Identifier__c.slice(-1);              
        let LoginMonth = this.loginAccepatnceDate.slice(5,7);
        let acceptedDate=LoginMonth-monthCheck;
            if(acceptedDate!=monthEntered ){
                    this.showToast("Error!", "error", "EMI clearnace date (Login Month- "+monthCheck+ ") Can only be in "+acceptedDate+"th month","sticky");
                }
            else{
               
                childRecords[fieldName] = event.target.value;
               
               this.newBlankListOfAppObliRec[parentIndex].isDirty=true;
               //console.log('childRecords>>>>'+ JSON.stringify(this.newBlankListOfAppObliRec[parentIndex]))
            }
            
    }
    connectedCallback(){
        //console.log('inconsole');
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        }
        this.scribeToMessageChannel();

        if (this.formFactor == "Large") {
            this.desktopBoolean = true;
            this.phoneBolean = false;
            console.log("desktopBoolean ", this.desktopBoolean);
        } else if (this.formFactor == "Small") {
            this.desktopBoolean = false;
            this.phoneBolean = true;
            console.log("phoneBolean ", this.phoneBolean);
        } else {

            this.desktopBoolean = false;
            this.phoneBolean = true;
            console.log("phoneBolean ", this.phoneBolean);
        }
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
        console.log('values to save through Lms ', JSON.stringify(values));
        
        this.handleSaveV(values.validateBeforeSave);

    }

    validateForm(){
        let isValid = true
    
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if(element.reportValidity()){
                //console.log('element passed');
            }else{
                isValid = false;
                element.setCustomValidity('Please fill the valid value')
            }
            

        });
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if(element.reportValidity()){
                //console.log('element passed');
            }else{
                isValid = false;
                element.setCustomValidity('Please fill the valid value')
            }
            
        }); 

        let customValidate=this.checkValidityLookup();

        console.log('customValidate',customValidate);


        return isValid && customValidate 
    }
    handleSaveV(validate) {
        if(validate){
            let isInputCorrect = this.validateForm();

            console.log("custom lookup validity if false>>>", isInputCorrect);

            if (isInputCorrect === true) {
                this.handleSave(); 

            }else{
                this.errorMessage();
            }
        }else{
            console.log('682')
            this.handleSave(); 
        }      

    }
    handleSave(event) {
       let DataRecords = [];
        let DataRecordObj = {};
        let ChildRecordObj = {};
        console.log('702')
            for(var i=0;i<this.newBlankListOfAppObliRec.length;i++){
                if(this.newBlankListOfAppObliRec[i].isDirty!=false){

                    DataRecordObj = {};
                    ChildRecordObj = {};
                 
                   DataRecordObj.parentRecord=this.newBlankListOfAppObliRec[i].parentRecord;
                   DataRecordObj.parentRecord.sobjectType ='BureauRespDtl__c';


                   let ChildRecordArr= [];
                   for(var j=0; j<this.newBlankListOfAppObliRec[i].ChildReords.length; j++){
                    ChildRecordObj = this.newBlankListOfAppObliRec[i].ChildReords[j];
                    ChildRecordObj.sobjectType='Applicant_Obligation_detail__c';
                    ChildRecordArr.push(ChildRecordObj);
                   }
                 DataRecordObj.ChildRecords= ChildRecordArr;                    
                    DataRecordObj.ParentFieldNameToUpdate='BureauRespDtl__c';
                    
                    DataRecords.push(DataRecordObj);
                }


            }

           
        
        upsertManualRecord({upsertData:DataRecords})
        .then(result => {                     
           
        this.showMessage();
        refreshApex(this._wiredManualData);
                  
        
    }).catch(error => {
        console.log('739'+JSON.stringify(error));
    })
    
    console.log('742')
       let params=[]
        this.allRecOfApplObwithDetai = this.allRecOfApplObwithDetai.map(record => {
            if (record.parentRecord) {
                record.ChildReords = record.ChildReords.filter(childRecord =>
                    childRecord.EMI_Clearance_Date__c !== "" || !childRecord.isDummy
                );
            }
                return record;
            
        });
        //console.log(' this.allRecOfApplObwithDetai'+JSON.stringify( this.allRecOfApplObwithDetai));
        var parentList=[];
        var childList=[];
        this.allRecOfApplObwithDetai.forEach(record => {
            console.log('record.parentRecord save'+JSON.stringify(record.parentRecord));
            parentList.push(record.parentRecord);
           
            if (record.hasOwnProperty('ChildReords')) {
                childList = childList.concat(record.ChildReords);
             }
            
        });      
        upsertMultipleRecord ({params:parentList})
        .then(result => {                   
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: this.customLabel.ObligationBanking_Update_SuccessMessage,
                        variant: "success",
                        mode: 'sticky'
                    })
                );   
              

              
        }).catch(error => {
            //console.log(error);
            console.log('778'+error)
        })


        const newList = childList.map(item => {
             const newItem = { ...item };
            delete newItem.Applicant_Obligation__r;
            delete newItem.isDummy;
            return newItem;
        });
        console.log('787')
        var recordsWithId=[];
        var recordsWithoutId=[];
        newList.forEach(record => {
            if (record.Id) {
                recordsWithId.push(record);
            } else {
                recordsWithoutId.push(record);
            }
            
        });
        if(recordsWithId.length>0){
            upsertMultipleRecord ({params:recordsWithId})
            .then(result => {                   
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: this.customLabel.ObligationBanking_Update_SuccessMessage,
                            variant: "success",
                            mode: 'sticky'
                        })
                    );        
                // refreshApex(this._wiredApplicantBanking);    
            }).catch(error => {
                //console.log(error);
                console.log('811'+error)
            })
        }
        if(recordsWithoutId.length>0){
            insertMultipleRecord ({params:recordsWithoutId})
            .then(result => { 
                //console.log('resultresultresultresultresult'+result);                     
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: this.customLabel.ObligationBanking_Update_SuccessMessage,
                            variant: "success",
                            mode: 'sticky'
                        })
                    );        
                // refreshApex(this._wiredApplicantBanking);    
            }).catch(error => {
                //console.log(error);
                console.log('835'+error)
            })
        }
        this.updateLoanAppRec();
        this.deleteExtraMonthRec();
        this.liveLoanCal()
            
    }
    deleteExtraMonthRec(){
        console.log('deleteExtraMonthRec')
        var listOfRecWithId=[];
        if(this.listForDelete.length>0){
            for(const record of this.listForDelete){
                if(typeof record.Id!=='undefined' && record.Id){
                    listOfRecWithId.push(record.Id)
                }
            }
            
        }
        if(listOfRecWithId.length>0){
            console.log('inlistOfRecWithId'+listOfRecWithId.length)
            for(const RecWithId of listOfRecWithId){
                deleteRecord(RecWithId)
                .then(result => {
                console.log('resultresultresultresultresult'+result)
                })
                .catch(error => {
                    console.log(error);
                });
            }
            
        }
    }
    updateLoanAppRec(){
            const fields = {}; 
            fields[LOAN_APP_ID.fieldApiName] = this.loanAppId;
            fields[LOGIN_DATE.fieldApiName] =this.monthAndYearvalue ;
            const recordInput = { fields };
            console.log('recordInput--->updateLoanAppRec',recordInput);
            updateRecord(recordInput)
            .then((result) => {             
            console.log('inside update record'+JSON.stringify(result));
            
            
        })
        .catch(error => {
                   });
        
    }
    
    showMessage()
    {
        console.log('835')
    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: this.customLabel.ObligationBanking_Update_SuccessMessage,
                            variant: "success",
                            mode: 'sticky'
                        }))
    }

    errorMessage()
    {
        console.log('835')
    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: this.customLabel.ObligationBanking_ReqFields_ErrorMessage,
                            variant: "error",
                            mode: 'sticky'
                        }))
    }


    
    newBureau;
    showNewBureauTable=false;
    
    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }
handleNewBureauAddition(event){
        this.newBureau=event.target.value;
        if(this.newBureau=='Yes'){
            this.showNewBureauTable=true;
            
            if(this.newManualrecord && this.newManualrecord !=undefined){
                

                let tempManualArr=[...this.newManualrecord] 
               this.newBlankListOfAppObliRec =  JSON.parse(JSON.stringify(tempManualArr));
                this.newBlankListOfAppObliRec =  tempManualArr;
                this.FinalManualList=JSON.stringify(this.newBlankListOfAppObliRec);
              
            }
            else{
                this.handleAddNewRows();

            }
            
        }else{
            this.showNewBureauTable=false;
        }
    }
    handleAddNewRows(){
        
        const newRec={
            "ChildReords": [
              {
                "BureauRespDtl__c": "",
                "EMI_Clearance_Date_Identifier__c": "Month1",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c'
              },
            {
                "BureauRespDtl__c": "",
                
                "EMI_Clearance_Date_Identifier__c": "Month2",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c'
              },
              {
                "BureauRespDtl__c": "",
              
                "EMI_Clearance_Date_Identifier__c": "Month3",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c'
              },
              {
                "BureauRespDtl__c": "",
                
                "EMI_Clearance_Date_Identifier__c": "Month4",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c'
              },
              {
                "BureauRespDtl__c": "",
                
                "EMI_Clearance_Date_Identifier__c": "Month5",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c'
              },
              {
                "BureauRespDtl__c": "",
                
                "EMI_Clearance_Date_Identifier__c": "Month6",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c'
              },
              {
                "BureauRespDtl__c": "",
                
                "EMI_Clearance_Date_Identifier__c": "Month7",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c'
              },
              {
                "BureauRespDtl__c": "",
               
                "EMI_Clearance_Date_Identifier__c": "Month8",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c'
              },
              {
                "BureauRespDtl__c": "",
                
                "EMI_Clearance_Date_Identifier__c": "Month9",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c'
              },
              {
                "BureauRespDtl__c": "",
                
                "EMI_Clearance_Date_Identifier__c": "Month10",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c'
              },
              {
                "BureauRespDtl__c": "",
                
                "EMI_Clearance_Date_Identifier__c": "Month11",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c'
              },
              {
                "BureauRespDtl__c": "",
               
                "EMI_Clearance_Date_Identifier__c": "Month12",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c'   
              },
              
            ],
            "parentRecord": {
              "Source__c": "",
              "LoanName__c": "",
              "EMISource__c": "",
              "NatureOfLoan__c": "",
              "FinancierName__c": "",
              "LoanCapacity__c": "",
              "ConsiderObligation__c": "",
              "RepayAc__c": "",
              "Treatment__c": "",
              "NoEMIPaid__c": "",
              "LoanAmount__c": "",
              "Ever90__c": "",
              "MaxDPDLst12month__c": "",
              "MaxDPDLst6month__c": "",
              "Overdues__c": "",
              "MaxDPDLst3month__c":"" ,
              "TenureLeft__c": "",
              "Tenure__c": "",
              "Applicant__c": "",
              "LoanApplication__c": this.loanAppId,
              "CloseDate__c": "",
              "DisbursalDate__c": "",
              "CurrentOs__c": "",
              "EMI__c": "",
              "RecordTypeId" :"",
              "EMIClearanceDate__c":"",
              "sobjectType" : 'BureauRespDtl__c',
              
              
            },  
               
            "isDirty" : false,
            
            "ParentFieldApiNameToUpdate" : "BureauRespDtl__c"   

        }
        
        var testList=[];
       
        testList.push(newRec);
       
        this.newBlankListOfAppObliRec=testList;
        
        this.newBlankListOfAppObliRec = this.newBlankListOfAppObliRec.map((record, index) => {
            return {...record,index: index+1};
          });

        
 
      
    }
    handleNewDataRec(){

    }

    validateNegative=false;
    handleBounceData(event){

        const inputBox = event.currentTarget;

        inputBox.setCustomValidity('');
        inputBox.reportValidity();

        let tempArr = this.allRecOfApplObwithDetai[event.target.dataset.index];
       
        const positiveNumberPattern = /^[0-9]\d*$/;
        if(event.target.dataset.field =='BounceInLast18Months__c' || event.target.dataset.field =='BounceInLast12Months__c'|| event.target.dataset.field =='TotalBouncesInRTR__c' || event.target.dataset.field =='CurrentOs__c' || event.target.dataset.field =='EMI__c' || event.target.dataset.field =='RepayAc__c' || event.target.dataset.field=='Overdues__c' || event.target.dataset.field =='NoEMIPaid__c' || event.target.dataset.field =='TenureLeft__c' ){
            if (!positiveNumberPattern.test(event.target.value)) {
                
                this.showToast("Error!", "error", this.customLabel.ObligationBanking_value_ErrorMessage,"sticky");
            } else {

                tempArr.parentRecord[event.target.dataset.field] = event.target.value;               
                this.allRecOfApplObwithDetai[event.target.dataset.index] = tempArr;  
                this.totalCurrentOS=0;
                this.totalEMI=0;
                for(const record of this.allRecOfApplObwithDetai){
                    this.totalCurrentOS  +=  record.parentRecord.CurrentOs__c == '' ||  record.parentRecord.CurrentOs__c == null ||  record.parentRecord.CurrentOs__c == undefined ? Number(0) :  Number(record.parentRecord.CurrentOs__c);
                    this.totalEMI  +=  record.parentRecord.EMI__c == '' ||  record.parentRecord.EMI__c == null ||  record.parentRecord.EMI__c == undefined ? Number(0) :  Number(record.parentRecord.EMI__c);
                  
                }        

                 }
        }
        else if(event.target.dataset.field =='Tenure__c' ){
            if (!positiveNumberPattern.test(event.target.value)) {
                
                this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.TenureLeft__c=''
               
                this.showToast("Error!", "error", this.customLabel.ObligationBanking_value_ErrorMessage,"sticky");
            }else{
                if(event.target.value>=0){
                this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.Tenure__c=event.target.value;
                this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.TenureLeft__c=this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.Tenure__c-this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.NoEMIPaid__c;
                }
                
                   
            }
        }
        else {

            tempArr.parentRecord[event.target.dataset.field] = event.target.value;               
            this.allRecOfApplObwithDetai[event.target.dataset.index] = tempArr; 
               
            }

            
    
       console.log('this.allRecOfApplObwithDetai'+JSON.stringify(this.allRecOfApplObwithDetai))
       
    }


    handleInputChange(event) {
        
        const inputBox = event.currentTarget;

        inputBox.setCustomValidity('');
        inputBox.reportValidity();

   
        let obligatoryDetails = this.newBlankListOfAppObliRec[event.target.dataset.index]
        const positiveNumberPattern = /^[0-9]\d*$/;
        if(event.target.dataset.field =='BounceInLast18Months__c' || event.target.dataset.field =='BounceInLast12Months__c'|| event.target.dataset.field =='TotalBouncesInRTR__c' 
        || event.target.dataset.field =='LoanAmount__c' || event.target.dataset.field =='CurrentOs__c' || event.target.dataset.field =='EMI__c' || event.target.dataset.field =='NoEMIPaid__c' || event.target.dataset.field =='TenureLeft__c'){
            if (!positiveNumberPattern.test(event.target.value)) {
                this.showToast("Error!", "error", this.customLabel.ObligationBanking_value_ErrorMessage,"sticky");
            } else {
                obligatoryDetails.parentRecord[event.target.dataset.field] = event.target.value; 
                obligatoryDetails.isDirty=true;
             //   tempupdatedArr.push(obligatoryDetails)
                this.newBlankListOfAppObliRec[event.target.dataset.index] = obligatoryDetails;  
                //adding total
                this.totalLoanAmount_m =0;
                this.totalCurrentOS_m=0;
                this.totalEMI_m=0;
                this.totalContinueObli_m=0;
                if(event.target.dataset.field =='LoanAmount__c' || event.target.dataset.field =='CurrentOs__c' || event.target.dataset.field =='EMI__c' ){
            
                
                for(const record of this.newBlankListOfAppObliRec){
                    // this.totalLoanCapacity  +=  record.parentRecord.LoanCapacity__c == '' ||  record.parentRecord.LoanCapacity__c == null ||  record.parentRecord.LoanCapacity__c == undefined ? Number(0) :  Number(record.parentRecord.LoanCapacity__c);
                    this.totalLoanAmount_m  +=  record.parentRecord.LoanAmount__c == '' ||  record.parentRecord.LoanAmount__c == null ||  record.parentRecord.LoanAmount__c == undefined ? Number(0) :  Number(record.parentRecord.LoanAmount__c);
                    this.totalCurrentOS_m  +=  record.parentRecord.CurrentOs__c == '' ||  record.parentRecord.CurrentOs__c == null ||  record.parentRecord.CurrentOs__c == undefined ? Number(0) :  Number(record.parentRecord.CurrentOs__c);
                    this.totalEMI_m  +=  record.parentRecord.EMI__c == '' ||  record.parentRecord.EMI__c == null ||  record.parentRecord.EMI__c == undefined ? Number(0) :  Number(record.parentRecord.EMI__c);
                   
                   
                    //this.totalRepayAc  +=  record.parentRecord.RepayAc__c == '' ||  record.parentRecord.RepayAc__c == null ||  record.parentRecord.RepayAc__c == undefined ? Number(0) :  Number(record.parentRecord.RepayAc__c);
                } 
                 }
            }
        }
         if(event.target.dataset.field =='DisbursalDate__c'){
            obligatoryDetails.parentRecord[event.target.dataset.field] = event.target.value; 
            obligatoryDetails.isDirty=true;
           let DisbursalDate=event.target.value;
           let currentDate= new Date().toISOString().substring(0, 10);
           console.log('DisbursalDate cal',DisbursalDate);
           console.log('currentDate cal',currentDate);

           let d1=new Date(currentDate).getFullYear() - new Date(DisbursalDate).getFullYear();

           let d2=(new Date(currentDate).getMonth() - new Date(DisbursalDate).getMonth());
           
           let MonthCal = (((d1)*12) + (d2))
            console.log('month cal',MonthCal);

            obligatoryDetails.parentRecord.NoEMIPaid__c=MonthCal
            this.newBlankListOfAppObliRec[event.target.dataset.index] = obligatoryDetails;  

            if(obligatoryDetails.parentRecord.Tenure__c>=0){
            obligatoryDetails.parentRecord.TenureLeft__c=obligatoryDetails.parentRecord.Tenure__c-obligatoryDetails.parentRecord.NoEMIPaid__c;
            this.newBlankListOfAppObliRec[event.target.dataset.index] = obligatoryDetails;  
            }
            
        }
        if(event.target.dataset.field =='Tenure__c'){
            if (!positiveNumberPattern.test(event.target.value)) {
                this.showToast("Error!", "error", this.customLabel.ObligationBanking_value_ErrorMessage,"sticky");
            } else{
            obligatoryDetails.parentRecord[event.target.dataset.field] = event.target.value; 
            obligatoryDetails.isDirty=true;
            
            obligatoryDetails.parentRecord.TenureLeft__c=obligatoryDetails.parentRecord.Tenure__c-obligatoryDetails.parentRecord.NoEMIPaid__c;
            this.newBlankListOfAppObliRec[event.target.dataset.index] = obligatoryDetails;  
            
        }}

        else{
            obligatoryDetails.parentRecord[event.target.dataset.field] = event.target.value; 
            obligatoryDetails.isDirty=true;
        //   tempupdatedArr.push(obligatoryDetails)
            this.newBlankListOfAppObliRec[event.target.dataset.index] = obligatoryDetails;   
        }
        
        //console.log('obligatoryDetails',obligatoryDetails)
        
        console.log('newBlankListOfAppObliRec inside handlechange',JSON.stringify(this.newBlankListOfAppObliRec[event.target.dataset.index]))   
        
    }
    
    handleAddLoan(event){
        let addRec={
            "ChildReords": [
              {
                "BureauRespDtl__c": "",
                "EMI_Clearance_Date_Identifier__c": "Month1",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c',
              },
            {
                "BureauRespDtl__c": "",
                
                "EMI_Clearance_Date_Identifier__c": "Month2",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c',
              },
              {
                "BureauRespDtl__c": "",
              
                "EMI_Clearance_Date_Identifier__c": "Month3",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c',
              },
              {
                "BureauRespDtl__c": "",
                
                "EMI_Clearance_Date_Identifier__c": "Month4",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c',
              },
              {
                "BureauRespDtl__c": "",
                
                "EMI_Clearance_Date_Identifier__c": "Month5",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c',
              },
              {
                "BureauRespDtl__c": "",
                
                "EMI_Clearance_Date_Identifier__c": "Month6",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c',
              },
              {
                "BureauRespDtl__c": "",
                
                "EMI_Clearance_Date_Identifier__c": "Month7",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c',
              },
              {
                "BureauRespDtl__c": "",
               
                "EMI_Clearance_Date_Identifier__c": "Month8",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c',
              },
              {
                "BureauRespDtl__c": "",
                
                "EMI_Clearance_Date_Identifier__c": "Month9",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c',
              },
              {
                "BureauRespDtl__c": "",
                
                "EMI_Clearance_Date_Identifier__c": "Month10",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c',
              },
              {
                "BureauRespDtl__c": "",
                
                "EMI_Clearance_Date_Identifier__c": "Month11",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c',
              },
              {
                "BureauRespDtl__c": "",
               
                "EMI_Clearance_Date_Identifier__c": "Month12",
                "EMI_Clearance_Date__c": "",
                "sobjectType" : 'Applicant_Obligation_detail__c',
          
              }
            ],
            "parentRecord": {
              "Source__c": "Manual",
              "LoanName__c": "",
              "EMISource__c": "",
              "NatureOfLoan__c": "",
              "FinancierName__c": "",
              "LoanCapacity__c": "",
              "ConsiderObligation__c": "",
              "RepayAc__c": "",
              "Treatment__c": "",
              "NoEMIPaid__c": "",
              "LoanAmount__c": "",
              "Ever90__c": "",
              "MaxDPDLst12month__c": "",
              "MaxDPDLst6month__c": "",
              "Overdues__c": "",
              "MaxDPDLst3month__c":"" ,
              "TenureLeft__c": "",
              "Tenure__c": "",
              "Applicant__c": "",
              "LoanApplication__c": this.loanAppId,
              "CloseDate__c": "",
              "DisbursalDate__c": "",
              "CurrentOs__c": "",
              "EMI__c": "",
              "RecordTypeId" :"",
              "sobjectType" : 'BureauRespDtl__c',
              "BounceInLast12Months__c":"",
              "BounceInLast18Months__c":"",
              "TotalBouncesInRTR__c":"",
              
             
            } ,
            "index" : "",
            "isDirty" : false,            
            "ParentFieldApiNameToUpdate" : "BureauRespDtl__c" 
        }         

        let tempArrRec = [...this.newBlankListOfAppObliRec];
        tempArrRec.push(addRec);
        this.newBlankListOfAppObliRec = [...tempArrRec];
      
        //console.log('new blank latest ',this.newBlankListOfAppObliRec)
    }


    handleValueSelect(event) {
        console.log('handleValueSelect'+event.target.value);
        this.lookupRec = event.detail;
        let lookupId = this.lookupRec.id;
        let lookupAPIName = this.lookupRec.lookupFieldAPIName;
        const outputObj = { [lookupAPIName]: lookupId };
        if (event.target.fieldName === 'FinancierName__c') {    
           this.allRecOfApplObwithDetai[event.target.index].parentRecord.FinancierName__c = this.lookupRec.mainField;
            this.allRecOfApplObwithDetai[event.target.index].parentRecord.FinancierNameID__c = lookupId;
         
        }
        if (event.target.fieldName === 'Repayment_Bank__c') {
           
            this.allRecOfApplObwithDetai[event.target.index].parentRecord.Repayment_Bank__c = this.lookupRec.mainField;
            this.allRecOfApplObwithDetai[event.target.index].parentRecord.RepaymentBankID__c = lookupId;
           
        }
       
    }
    

    handleSystemDateChange(event){
    console.log('handleSystemDateChange')
        
        
        let fieldName = event.target.dataset.field;
        //childRecords[fieldName] = event.target.value;
        let monthEntered=event.target.value.slice(5,7);
        console.log('monthEntered'+monthEntered)   
        const monthMap = { 0: 'January', 1: 'February', 2: 'March', 3: 'April', 4: 'May', 5: 'June', 6: 'July', 7: 'August', 8: 'September', 9: 'October', 10: 'November', 11: 'December', };         
        let LoginMonth = this.loginAccepatnceDate.slice(5,7);
        const date2 = new Date(this.loginAccepatnceDate);
        const monthName = monthMap[date2.getMonth()];  

        console.log('monthName',monthName)  
        console.log('LoginMonth',LoginMonth)
        //let acceptedDate=LoginMonth-monthCheck;
            if(monthEntered!=LoginMonth ){
                    this.showToast("Error!", "error", this.customLabel.ObligationBanking_EmiDate_ErrroMessage +monthName+" month","sticky");
                }
            else{
               
                this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.EMIClearanceDate__c=event.target.value;
            }
            
    }

    ///c/handle manual
    handleValuemanualSelect(event) {
       
        this.lookupRec = event.detail;
        let lookupId = this.lookupRec.id;
        let lookupAPIName = this.lookupRec.lookupFieldAPIName;
        const outputObj = { [lookupAPIName]: lookupId };
        console.log('event.target.fieldName',event.target.fieldName)
        if (event.target.fieldName === 'FinancierName__c') {    
            
            this.newBlankListOfAppObliRec[event.target.index].parentRecord.FinancierName__c = this.lookupRec.mainField;
            this.newBlankListOfAppObliRec[event.target.index].parentRecord.FinancierNameID__c = lookupId;

          
        }
        if (event.target.fieldName === 'Repayment_Bank__c') {
            
            this.newBlankListOfAppObliRec[event.target.index].parentRecord.Repayment_Bank__c = this.lookupRec.mainField;
            this.newBlankListOfAppObliRec[event.target.index].parentRecord.RepaymentBankID__c = lookupId;
           
        }
        if (event.target.fieldName === 'Loan_Type__c') {
            
            this.newBlankListOfAppObliRec[event.target.index].parentRecord.NatureOfLoan__c = this.lookupRec.mainField;
            this.newBlankListOfAppObliRec[event.target.index].parentRecord.NatureOfLoanID__c = lookupId;
           
        }

       
       this.newBlankListOfAppObliRec[event.target.index].isDirty=true;
       
    }

    //end
    HandleValueChange(event){
        
         let tempArr = this.allRecOfApplObwithDetai[event.target.dataset.index];
        if(event.target.value == 'To continue - Obligate')
                    {
                       
                       this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.ConsiderObligation__c='Yes';
                      // this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.ConsiderObligation__c='Yes';
                      this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.Treatment__c=event.target.value;
                                             
                    }
                    if(event.target.value != 'To continue - Obligate'){
                  
                   this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.ConsiderObligation__c='No';
                  // this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.ConsiderObligation__c='No';
                    this.allRecOfApplObwithDetai[event.target.dataset.index].parentRecord.Treatment__c=event.target.value;
                         
                    }
              //  }
            
              this.obligArr_s=[];
                        for(const record of this.allRecOfApplObwithDetai){
                            if(record.parentRecord.Treatment__c=='To continue - Obligate'){
                               // record.parentRecord.ConsiderObligation__c ='Yes';
                               this.obligArr_s.push(record);
                            }                
                               
                        }  
                        this.totalContinueObli=this.obligArr_s.length  
                        console.log('this.totalContinueObli update',this.totalContinueObli)
              
                
     }  

     HandleValue(event){
        // this.wrpAppReg.id=this.parentId;

        const inputBox = event.currentTarget;

        inputBox.setCustomValidity('');
        inputBox.reportValidity();
       // var ContinueObliList_m = [];
        //var obligArr = [];
         let tempArry = this.newBlankListOfAppObliRec[event.target.dataset.index];
         this.newBlankListOfAppObliRec[event.target.dataset.index].isDirty=true;
        
         if(event.target.dataset.name == 'Treatment__c')       
      
                 {
                    this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.Treatment__c=event.target.value;
                         
                    if(event.target.value == 'To continue - Obligate')
                        {
                            this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.ConsiderObligation__c='Yes';
                          
                        }
                        if(event.target.value != 'To continue - Obligate'){
                    this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.ConsiderObligation__c='No';
                        
                        }
                        this.obligArr=[];
                        for(const record of this.newBlankListOfAppObliRec){
                            if(record.parentRecord.Treatment__c=='To continue - Obligate'){
                               // record.parentRecord.ConsiderObligation__c ='Yes';
                               this.obligArr.push(record);
                            }                
                               
                        }  
                        this.totalContinueObli_m=this.obligArr.length  
                        console.log('this.totalContinueObli_m update',this.totalContinueObli_m)  
                }
           
                
            
        if(event.target.dataset.name == 'LoanName__c'){
         //   this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.LoanName__c=event.target.value;                                  
         this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.Applicant__c=event.target.value; 
         
         //console.log('event.target',event.target)
         
         let Aid=this.AppNameList.find(opt => opt.value === this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.Applicant__c).label;
        //   this .newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.Applicant__c=Aid
             //console.log('Aid', Aid)
        this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.LoanName__c=Aid;  
        
        //isDirty=true;
        for (let i = 0; i < this.tempArrAppConst.length; i++) {
            if(this.tempArrAppConst[i].FullName__c==Aid){
                if(this.tempArrAppConst[i].Constitution__c=='INDIVIDUAL'){
                    this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.RecordTypeId=this.RTConsumerId;
               
                }
                else{
                    this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.RecordTypeId=this.RTCommercialId;
                    //this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.CrdFacType__c='Current';
                }
            }}

         
        }

        // if(event.target.dataset.name == 'NatureOfLoan__c'){
        //     this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.NatureOfLoan__c=event.target.value;                                  

        // }

        if(event.target.dataset.name == 'LoanCapacity__c'){
            this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.LoanCapacity__c=event.target.value;                                  

        }

       
     }  


     handleDelete(event)
    {
        
        let deleteRecordId=this.newBlankListOfAppObliRec[event.target.dataset.index].parentRecord.Id;

        if(deleteRecordId ==undefined){
                this.newBlankListOfAppObliRec.splice(event.target.dataset.index,1);
                this.totalLoanAmount_m =0;
                this.totalCurrentOS_m=0;
                this.totalEMI_m=0;
                this.totalContinueObli_m=0;
                this.obligArr=[];
           for(const record of this.newBlankListOfAppObliRec){
            // this.totalLoanCapacity  +=  record.parentRecord.LoanCapacity__c == '' ||  record.parentRecord.LoanCapacity__c == null ||  record.parentRecord.LoanCapacity__c == undefined ? Number(0) :  Number(record.parentRecord.LoanCapacity__c);
            this.totalLoanAmount_m  +=  record.parentRecord.LoanAmount__c == '' ||  record.parentRecord.LoanAmount__c == null ||  record.parentRecord.LoanAmount__c == undefined ? Number(0) :  Number(record.parentRecord.LoanAmount__c);
            this.totalCurrentOS_m  +=  record.parentRecord.CurrentOs__c == '' ||  record.parentRecord.CurrentOs__c == null ||  record.parentRecord.CurrentOs__c == undefined ? Number(0) :  Number(record.parentRecord.CurrentOs__c);
            this.totalEMI_m  +=  record.parentRecord.EMI__c == '' ||  record.parentRecord.EMI__c == null ||  record.parentRecord.EMI__c == undefined ? Number(0) :  Number(record.parentRecord.EMI__c);
            if(record.parentRecord.Treatment__c=='To continue - Obligate'){
                // record.parentRecord.ConsiderObligation__c ='Yes';
                 this.obligArr.push(record);
             }                
             this.totalContinueObli_m=this.obligArr.length  
           
            //this.totalRepayAc  +=  record.parentRecord.RepayAc__c == '' ||  record.parentRecord.RepayAc__c == null ||  record.parentRecord.RepayAc__c == undefined ? Number(0) :  Number(record.parentRecord.RepayAc__c);
        } 
        }
        else{
        deleteRecord(deleteRecordId)
        .then(result => {
           refreshApex(this._wiredManualData
            );
          
           
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: this.customLabel.ObligationBanking_Del_SuccessMessage,
                    variant: 'success',
                    mode: 'sticky'
                })
            );
        })
        .catch(error => {
            console.log(error);
        });
    }

    }

    checkValidityLookup() {
        let isInputCorrect = true; 
        let allChilds = this.template.querySelectorAll("c-custom-lookup");
        console.log("custom lookup allChilds>>>", allChilds);
        allChilds.forEach((child) => {
            console.log("custom lookup child>>>", child);
            console.log(
                "custom lookup validity custom lookup >>>",
                isInputCorrect
            );
            if (!child.checkValidityLookup()) {
                child.checkValidityLookup();
                isInputCorrect = false;
                console.log(
                    "custom lookup validity if false>>>",
                    isInputCorrect
                );
            }
        });
        console.log('isInputCorrect',isInputCorrect);
        return isInputCorrect;
    }
   
    totalLiveLoan=0
    loancountArr=[]
    liveLoanCal(){

        let TotalLoanrecords = JSON.parse(JSON.stringify(this.allRecOfApplObwithDetai.concat(this.newBlankListOfAppObliRec)))
       let sum
       let mapOfCount = new Map();
        for(var i=0;i< TotalLoanrecords.length;i++)
        {
            
            if(TotalLoanrecords[i].parentRecord.Treatment__c=="To continue - Obligate"){
                let sum=1
                if(mapOfCount.has(TotalLoanrecords[i].parentRecord.Applicant__c)){
                    sum=mapOfCount.get(TotalLoanrecords[i].parentRecord.Applicant__c)+1
                    mapOfCount.set(TotalLoanrecords[i].parentRecord.Applicant__c,sum);
                  console.log('mapOfCount',mapOfCount)                   
                }
                else{
                    mapOfCount.set(TotalLoanrecords[i].parentRecord.Applicant__c,sum);
                }
            }
        }
        let RARecord=[]
         
         mapOfCount.forEach (function(value, key) {
            let RecordObj={}
            RecordObj.Id=key;
            RecordObj.Total_Live_Loan__c=value; 
            RARecord.push(RecordObj) 
          })
        upsertMultipleRecord({params:RARecord})
        .then(result => {    

          refreshApex(this._wiredBruData);
        }).catch(error => {
            console.log(error);
        })

    }
    
    //******************FOR HANDLING THE HORIZONTAL SCROLL OF TABLE MANUALLY******************//
    tableOuterDivScrolled(event) {
        this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
        if (this._tableViewInnerDiv) {
            if (!this._tableViewInnerDivOffsetWidth || this._tableViewInnerDivOffsetWidth === 0) {
                this._tableViewInnerDivOffsetWidth = this._tableViewInnerDiv.offsetWidth;
            }
            this._tableViewInnerDiv.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth) + "px;" + this.tableBodyStyle;
        }
        
        this.tableScrolled(event);

       

    }

    tableScrolled(event) {
        if (this.enableInfiniteScrolling) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('showmorerecords', {
                    bubbles: true
                }));
            }
        }
        if (this.enableBatchLoading) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('shownextbatch', {
                    bubbles: true
                }));
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
            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            tableThs.forEach(th => {
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
        console.log("handlemousedown._tableThColumn.tagName => ", this._tableThColumn.tagName);
        this._pageX = e.pageX;

        this._padding = this.paddingDiff(this._tableThColumn);

        this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
        console.log("handlemousedown._tableThColumn.tagName => ", this._tableThColumn.tagName);
    }

    handlemousemove(e) {
        console.log("mousemove._tableThColumn => ", this._tableThColumn);
        if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
            this._diffX = e.pageX - this._pageX;

            this.template.querySelector("table").style.width = (this.template.querySelector("table") - (this._diffX)) + 'px';

            this._tableThColumn.style.width = (this._tableThWidth + this._diffX) + 'px';
            this._tableThInnerDiv.style.width = this._tableThColumn.style.width;

            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            let tableBodyRows = this.template.querySelectorAll("table tbody tr");
            let tableBodyTds = this.template.querySelectorAll("table tbody .dv-dynamic-width");
            tableBodyRows.forEach(row => {
                let rowTds = row.querySelectorAll(".dv-dynamic-width");
                rowTds.forEach((td, ind) => {
                    rowTds[ind].style.width = tableThs[ind].style.width;
                });
            });
        }
    }

    handledblclickresizable() {
        let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
        let tableBodyRows = this.template.querySelectorAll("table tbody tr");
        tableThs.forEach((th, ind) => {
            th.style.width = this._initWidths[ind];
            th.querySelector(".slds-cell-fixed").style.width = this._initWidths[ind];
        });
        tableBodyRows.forEach(row => {
            let rowTds = row.querySelectorAll(".dv-dynamic-width");
            rowTds.forEach((td, ind) => {
                rowTds[ind].style.width = this._initWidths[ind];
            });
        });
    }

    paddingDiff(col) {

        if (this.getStyleVal(col, 'box-sizing') === 'border-box') {
            return 0;
        }

        this._padLeft = this.getStyleVal(col, 'padding-left');
        this._padRight = this.getStyleVal(col, 'padding-right');
        return (parseInt(this._padLeft, 10) + parseInt(this._padRight, 10));

    }

    getStyleVal(elm, css) {
        return (window.getComputedStyle(elm, null).getPropertyValue(css))
    }
    //nehacodefortesting
    monthAndYearvalue;
    arrMonYear=[];
    objForEmiDates={"EMIClearancedateLoginMonth":"","EMIClearancedateLoginMonth1":"","EMIClearancedateLoginMonth2":"","EMIClearancedateLoginMonth3":0,"EMIClearancedateLoginMonth4":0,"EMIClearancedateLoginMonth5":0,"EMIClearancedateLoginMonth6":0,"EMIClearancedateLoginMonth7":"","EMIClearancedateLoginMonth8":"","EMIClearancedateLoginMonth9":"","EMIClearancedateLoginMonth10":0,"EMIClearancedateLoginMonth11":0,"EMIClearancedateLoginMonth12":0}; 
    listForDelete;
    listforUI=[];
    handleMonthAndVal(event){
        this.allRecOfApplObwithDetai=this.listOfallRecOfApplObwithDetai
        console.log('this.listOfallRecOfApplObwithDetai'+JSON.stringify(this.allRecOfApplObwithDetai))
        var newMonthAndYearval=event.target.value;
        this.handleMonthAndYearHeaderWihRec(newMonthAndYearval);
      //  this.loginAccepatnceDate
        

    }  
    handleMonthAndYearHeaderWihRec(MonthAndYearval){
        this.allRecOfApplObwithDetai=this.listOfallRecOfApplObwithDetai
        console.log('this.listOfallRecOfApplObwithDetai'+JSON.stringify(this.allRecOfApplObwithDetai.childs))
        this.monthAndYearvalue=MonthAndYearval;
        if(this.monthAndYearvalue!='undefined' && this.monthAndYearvalue !='' && this.monthAndYearvalue!=null ){
            const dateObj = new Date(this.monthAndYearvalue);
            const fileAccDay=dateObj.getDate();
            const firstFullyear=dateObj.getFullYear();
            const fileAccMonth=dateObj.getMonth();
            dateObj.setFullYear(dateObj.getFullYear() - 1);
            let oneYearLessDate = dateObj.toISOString().slice(0, 10);
            const newDate= new Date(MonthAndYearval);
            let dateArray=[];
            this.listforUI=[]

            const newDateMonth=newDate.getMonth();
            for(let i=0;i<=12;i++){
                const iMonthBeforeDate = new Date(this.monthAndYearvalue);
                iMonthBeforeDate.setMonth(fileAccMonth - (i));
                dateArray.push(iMonthBeforeDate);
            }
            
            const monthMap = { 0: 'January', 1: 'February', 2: 'March', 3: 'April', 4: 'May', 5: 'June', 6: 'July', 7: 'August', 8: 'September', 9: 'October', 10: 'November', 11: 'December', };
            console.log('dateArray>>>>>>>>'+dateArray);
            //console.log('oneMonthBeforeDate'+firstFullyear)
          // this.objForEmiDates.EMIClearancedateLoginMonth=monthMap[dateObj.getMonth()] +'-'+firstFullyear;
           var arrMonYear=[];
           for(let i=0;i<dateArray.length;i++){
            const getYear= this.convertToDate(dateArray[i]);
            arrMonYear.push(monthMap[dateArray[i].getMonth()]+'-'+getYear.getFullYear());
            this.arrMonYear=arrMonYear;
           }
           var listoUpdate=this.arrMonYear;
           var newList = listoUpdate.map(item => {
            const [month, year] = item.split('-');
            console.log('[month, year]'+[month, year] +'year'+year)
            console.log('month.substring(0, 3).toUpperCase()'+month.substring(0, 3).toUpperCase())
            var newval =month.substring(0, 3).toUpperCase()+'-'+year;
            this.listforUI.push(newval)
           });
           console.log('this.listforUI'+this.listforUI);
           
          var objOfRecWithMonYear={};
           var ListOfobjOfRecWithMonYear=[];
           for(const record of this.allRecOfApplObwithDetai){
                if(record.ChildReords && record.ChildReords != undefined){
                    console.log('record.ChildReords'+record.ChildReords.length)
                    for(let i=0;i<record.ChildReords.length;i++){
                        if(typeof record.ChildReords[i].EMI_Clearance_Date__c!=='undefined' && record.ChildReords[i].EMI_Clearance_Date__c){

                        }else{
                            console.log('?????????????'+this.arrMonYear[i+1])
                            record.ChildReords[i].EMI_Clearance_Date__c = this.convertToDateFormat(this.arrMonYear[i+1]);
                            
                        }
                    }
                    console.log('<record.ChildReords'+JSON.stringify(record.ChildReords))
                }else{
                    
                }
            }
            var listForDelete=[];
            for(const record of this.allRecOfApplObwithDetai){
                if(record.ChildReords && record.ChildReords != undefined){
                    console.log('record.ChildReords'+record.ChildReords.length)
                    for(const chilRec of record.ChildReords){
                        const date = new Date(chilRec.EMI_Clearance_Date__c);
                        console.log('date')
                        const datenew= this.convertToDate(date);
                      console.log('datenew'+datenew.getFullYear())
                      console.log('datenew1'+monthMap[datenew.getMonth()])
                       const monthNameYearKey = monthMap[datenew.getMonth()]+'-'+datenew.getFullYear();
                       var newarray=this.arrMonYear;
                       if(!newarray.slice(1).includes(monthNameYearKey)){
                        listForDelete.push(chilRec);
                             console.log('monthNameYearKey1826'+monthNameYearKey)
                       }else{
                             console.log('monthNameYearKey1827'+monthNameYearKey)
                       }
                       this.listForDelete=listForDelete;
                       if (!objOfRecWithMonYear[monthNameYearKey]) {
                            objOfRecWithMonYear[monthNameYearKey] = [];
                        }
                        objOfRecWithMonYear[monthNameYearKey].push(chilRec);
                        
                    }
                    ListOfobjOfRecWithMonYear.push(objOfRecWithMonYear);
                    
                }else{
                    
                }
            }
            console.log('listForDelete'+JSON.stringify(listForDelete));
            const idsToRemove = listForDelete.map(record => record.EMI_Clearance_Date_Identifier__c); 
            console.log('idsToRemove'+idsToRemove)
            //this.recordList2.filter(record => !idsToRemove.includes(record.Id));   
            for(let i=0;i<this.allRecOfApplObwithDetai.length;i++){
                console.log('1876')
                if(this.allRecOfApplObwithDetai[i].ChildReords && this.allRecOfApplObwithDetai[i].ChildReords != undefined){
                    console.log('1876')
                    var listoFRec=[];
                    for(const chilRec of this.allRecOfApplObwithDetai[i].ChildReords){
                        if(!idsToRemove.includes(chilRec.EMI_Clearance_Date_Identifier__c)){
                            listoFRec.push(chilRec);
                        }
                    }
                    this.allRecOfApplObwithDetai[i].ChildReords=listoFRec;
                    //this.allRecOfApplObwithDetai[i].ChildReords.filter(record => !idsToRemove.includes(record.Id));
                    console.log('1876')
                }
            } 
            console.log('@@@@@@@record.ChildReords'+JSON.stringify(this.allRecOfApplObwithDetai[0].ChildReords))
            console.log('@@@@@@@record.ChildReords'+this.allRecOfApplObwithDetai[0].ChildReords.length)

            for(let i=0;i<this.allRecOfApplObwithDetai.length;i++){
                this.parentIdForObliga=this.allRecOfApplObwithDetai.parentRecord.Id;
                var listToadd=[];
                for(let j=1;j<this.arrMonYear.length;j++){   
                    if(this.allRecOfApplObwithDetai[i].ChildReords && this.allRecOfApplObwithDetai[i].ChildReords != undefined){
                        
                        if(ListOfobjOfRecWithMonYear[i][this.arrMonYear[j]] && typeof ListOfobjOfRecWithMonYear[i][this.arrMonYear[j]] !=='undefined'){
                            console.log('this.arrMonYear[j]1845'+this.arrMonYear[j]);
                            console.log('iiiiii'+i)
                            console.log('j>>'+j)
                            //console.log('>>>>>>>>>>>>1844'+this.allRecOfApplObwithDetai[i].ChildReords[j-1].EMI_Clearance_Date_Identifier__c);
                            this.allRecOfApplObwithDetai[i].ChildReords[j-1].EMI_Clearance_Date_Identifier__c="Month"+j;
                            this.allRecOfApplObwithDetai[i].ChildReords[j-1].EMI_Clearance_Date__c=this.convertToDateFormat(this.arrMonYear[j]);
                           // listToadd.push(this.allRecOfApplObwithDetai[i].ChildReords[j-1]);
                            //console.log('listToaddlistToadd11111'+listToadd.length);
                            //console.log('>>>>>>>>>>>>1844'+this.allRecOfApplObwithDetai[i].ChildReords[j-1].EMI_Clearance_Date_Identifier__c);
                            //console.log('>>>>>>>>>>>>1844'+this.allRecOfApplObwithDetai[i].ChildReords[j-1].EMI_Clearance_Date__c);
                        }else{
                            console.log('this.arrMonYear[j]1852'+this.arrMonYear[j])
                            
                           console.log('this.parentIdForObliga'+this.parentIdForObliga)
                            let temp = {"BureauRespDtl__c": this.parentIdForObliga, "EMI_Clearance_Date_Identifier__c":"Month"+j, "EMI_Clearance_Date__c":this.convertToDateFormat(this.arrMonYear[j])};
                            //this.allRecOfApplObwithDetai[i].ChildReords[j-1]= temp;
                            //listToadd.push(temp);
                            //console.log('@@@@@@@record.ChildReords1886'+JSON.stringify(this.allRecOfApplObwithDetai[0].ChildReords))
                            this.allRecOfApplObwithDetai[i].ChildReords.unshift(temp)
                        }
                    }
                 }
               // this.allRecOfApplObwithDetai[i].ChildReords=listToadd;
                this.allRecOfApplObwithDetai[i].ChildReords = this.allRecOfApplObwithDetai[i].ChildReords.sort((a, b) => new Date(b.EMI_Clearance_Date__c) - new Date(a.EMI_Clearance_Date__c));
               //this.allRecOfApplObwithDetai[i].ChildReords.slice().sort((a, b) => new Date(b.EMI_Clearance_Date__c) - new Date(b.EMI_Clearance_Date__c));
            }
            console.log('@@@@@@@record.ChildReords>>>>>shorting '+JSON.stringify(this.allRecOfApplObwithDetai[0].ChildReords))
            console.log('@@@@@@@record.ChildReords>>>>'+this.allRecOfApplObwithDetai[0].ChildReords.length)
            
        }else{
            this.showToast("Error", "error", 'testing');
        }
    }
    convertToDateFormat(monthYear) {
        const [year, month] = monthYear.split('-');
        const dateObject = new Date(`${year}-${month}-10`);
        var formattedDate= this.convertToDate(dateObject)
        return formattedDate;
    
    }
    convertToDate(str) {
        var date = new Date(str)
        return date;
    }
}