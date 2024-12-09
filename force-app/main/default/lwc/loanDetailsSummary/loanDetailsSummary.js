import { LightningElement, api, wire, track } from 'lwc';

import APPLICANT_ID from '@salesforce/schema/LoanAppl__c.Name';
import CHANNEL_CODE from '@salesforce/schema/LoanAppl__c.ChannelCode__c';
import CHANNEL_NAME from '@salesforce/schema/LoanAppl__c.ChannelName__c';
import PRODUCT from '@salesforce/schema/LoanAppl__c.Product__c';
import LOGIN_DATE from '@salesforce/schema/LoanAppl__c.LoginAcceptDate__c';
import BRANCH_NAME from '@salesforce/schema/LoanAppl__c.BrchName__c';
import BRANCH_CODE from '@salesforce/schema/LoanAppl__c.BrchCode__c';
import CITY from '@salesforce/schema/LoanAppl__c.City__c';
import SCHEME from '@salesforce/schema/LoanAppl__c.SchemeId__c';
import SCHEME_CODE from '@salesforce/schema/LoanAppl__c.SchmCode__c';
import LOAN_PURPOSE from '@salesforce/schema/LoanAppl__c.LoanPurpose__c';
import RM_NAME from '@salesforce/schema/LoanAppl__c.RMSMName__c';
import LOAN_AMOUNT from '@salesforce/schema/LoanAppl__c.ReqLoanAmt__c';
import LOAN_TENURE from '@salesforce/schema/LoanAppl__c.ReqTenInMonths__c';
import EFFECTIVE_ROI from '@salesforce/schema/LoanAppl__c.EffectiveROI__c';
import BT_FINANCIER from '@salesforce/schema/LoanAppl__c.BTFinancr__c';
import MAIN_APPLICANT from '@salesforce/schema/LoanAppl__c.Final_MSME__c';
import ASSESS_INCOME_APPL from '@salesforce/schema/LoanAppl__c.AssesIncomeAppl__c';
import SANCTION_LOAN_AMT from '@salesforce/schema/LoanAppl__c.SanLoanAmt__c';
import INSURANCE_AMT from '@salesforce/schema/LoanAppl__c.Insurance_Amount__c';
import INSU_AMT from '@salesforce/schema/LoanAppl__c.InsAmt__c';
import SCHEME_NAME from '@salesforce/schema/SchMapping__c.Name';
import SCHEME_DESCRIPTION from '@salesforce/schema/SchMapping__c.SchemeDesc__c';
import LOAN_TENURE_MONTH from '@salesforce/schema/LoanAppl__c.Loan_Tenure_Months__c';
import fetchRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi'
import getLoanDetailsSummary from '@salesforce/apex/ObligationDetailsSummaryController.getLoanDetailsSummary';
import { formatDateFunction  } from 'c/dateUtility';


const fields = [APPLICANT_ID, LOGIN_DATE, BRANCH_NAME, CITY, PRODUCT, SCHEME, SCHEME_CODE, LOAN_PURPOSE, RM_NAME,BRANCH_CODE,
    CHANNEL_CODE, CHANNEL_NAME, LOAN_AMOUNT, LOAN_TENURE, EFFECTIVE_ROI, BT_FINANCIER, MAIN_APPLICANT,ASSESS_INCOME_APPL,SANCTION_LOAN_AMT,INSURANCE_AMT,INSU_AMT,LOAN_TENURE_MONTH];


const SchemeFields = [SCHEME_NAME, SCHEME_DESCRIPTION];

export default class LoanDetailsSummary extends LightningElement {
linkedLoans;
//@api recordId; // for this Loan Appln Id shcmeId is a07C4000004JE8wIAG, old loan appln Id=a08C4000005ynpNIAQ
@api objectApiName="LoanAppl__c";

@track applicationId;
@track loginDate;
@track branchName;
@track branchCode;
@track city;
@track product;
@track schemeId;
@track schemeCode;
@track loanPurpose;
@track rMName;
@track channelCode;
@track channelName;
@track ChannelRName;
@track loanAmount;
@track loanTenure;
@track effectiveROI;
@track bTFinancierId;
@track mainApplicant;
@track schemeNameee;
@track schemeDescription;
@track assessIncomeApp;
@track sanctionLoanAmt;
@track insuranceAmount;
@track insuAmount;
@track listOfLoanDetailsSummary =[];
@track appLvlAssmPro;
@track isVisibleCombinedLTV;
@api applicantId;
@track _loanAppId;
@track discrimination;
@api get recordId() {
       return this._loanAppId;
}
set recordId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);  
        this.handleLoanAppRecordIdChange(value);          
}

 handleLoanAppRecordIdChange(){  

        let tempParams1 = this.paramsForBreRec;
        tempParams1.queryCriteria = ' where LoanAppl__c= \'' + this._loanAppId + '\'  AND EligibilityType__c=\'Application\' AND IsLatest__c = true order by LastModifiedDate desc limit 1'
        this.paramsForBreRec = {...tempParams1};
        //LAK-7316 BIL - UW Summary

        let tempParams2 = this.paramsForAppl;
        tempParams1.queryCriteria = ' where Id= \'' + this.applicantId + '\'';
        this.paramsForAppl = {...tempParams2};

        let tempParams3 = this.paramsForApplReg;
        tempParams1.queryCriteria = ' where LoanAppln__c= \'' + this._loanAppId + '\'';
        this.paramsForApplReg = {...tempParams3};

        
}

@track paramsForBreRec={
        ParentObjectName:'BRE__c',
        ChildObjectRelName:'',
        parentObjFields:['Id', 'LoanAppl__c', 'IsLatest__c','Application_level_Assessment_program__c'],
        childObjFields:[],        
        queryCriteria: ""

}


@track paramsForSM={
    ParentObjectName:'TeamHierarchy__c',
    ChildObjectRelName:'',
    parentObjFields:['Id', 'EmpRole__c', 'Employee__c','Employee__r.Name', 'EmpBrch__r.BrchCode__c', 'Product_Type__c'],
    childObjFields:[],        
    queryCriteria: ""

}

//LAK-7316 BIL - UW Summary
@track paramsForAppl={
    ParentObjectName:'Applicant__c',
        ChildObjectRelName:'',
        parentObjFields:['Id', 'Investment_in_Plant_and_Machinery__c'],
        childObjFields:[],        
        queryCriteria: ""
}


@track paramsForApplReg={
    ParentObjectName:'ApplRegltry__c',
        ChildObjectRelName:'',
        parentObjFields:['Id', 'CharDiscrmtn__c'],
        childObjFields:[],        
        queryCriteria: ""
}

@track isBLorPL = false;

connectedCallback(){
    refreshApex(this.applicationData);
}

@wire(getRecord, { recordId: '$recordId', fields: fields })
recordLoadDetailsHandler({ data, error }) {

    if (data) {
        this.applicationId = data.fields.Name.value;
        this.loginDate = formatDateFunction(data.fields.LoginAcceptDate__c.value);
        console.log('loginDate:::::::', this.loginDate);
        this.branchName = data.fields.BrchName__c.value;
        this.branchCode = data.fields.BrchCode__c.value;
        this.city = data.fields.City__c.value;
        this.product = data.fields.Product__c.value;
        this.schemeId = data.fields.SchemeId__c.value;
        this.schemeCode = data.fields.SchmCode__c.value;
        this.loanPurpose = data.fields.LoanPurpose__c.value;
        this.rMName = data.fields.RMSMName__c.value;
        this.channelCode = data.fields.ChannelCode__c.value;
        this.channelName = data.fields.ChannelName__c.value;
        this.loanAmount = data.fields.ReqLoanAmt__c.value;
        this.loanTenure = data.fields.ReqTenInMonths__c.value;
        this.effectiveROI = data.fields.EffectiveROI__c.value;
        this.mainApplicant = data.fields.Final_MSME__c.value;
        this.assessIncomeApp = data.fields.AssesIncomeAppl__c.value;
        this.sanctionLoanAmt = data.fields.SanLoanAmt__c.value;
        this.insuranceAmount = data.fields.Insurance_Amount__c.value;
        this.insuAmount = data.fields.InsAmt__c.value;

        let smRole = 'SM';
        let tempParams4 = this.paramsForSM;
        tempParams4.queryCriteria = ' where EmpRole__c = \'' + smRole + '\' AND EmpBrch__r.BrchCode__c = \'' + this.branchCode + '\' AND Product_Type__c Includes (\'' + this.product + '\') AND IsActive__c = true '
        this.paramsForSM = tempParams4;

//LAK-7316 BIL - UW Summary
        if(this.product != null && (this.product == 'Business Loan' || this.product == 'Personal Loan')){
            this.isBLorPL = true; 
        }
    //    this.CombinedLTVVisibility();
    } if (error) {
        console.log('ERROR:::::::', error);
    }
}

// CombinedLTVVisibility(){

//     let schemeCode = this.schemeCode;
//     if (schemeCode && [
//         'HOME LOAN - BT',
//         'HOME LOAN BT - FIXED',
//         'TOP UP ON HL BT LOAN',
//         'TOP UP ON HL BT LOAN - FIXED',
//         'STL - NRP TOP UP',
//         'STL - TOP UP',
//         'STL - NRP TOP UP - FIXED',
//         'STL - TOP UP - FIXED'
//     ].some(value => schemeCode.includes(value))) {
//         this.isVisibleCombinedLTV = true;
//     }else{
//     this.isVisibleCombinedLTV = false;
//     }
//     }

@wire(getRecord, { recordId: '$schemeId', fields: SchemeFields })
recordSchemesHandler({ data, error }) {
   
    if (data) {
        this.schemeNameee = data.fields.Name.value;
        this.schemeDescription = data.fields.SchemeDesc__c.value;
       
    } if (error) {
        console.log('ERROR:::::::', error);
    }
}
//LAK-7316 BIL - UW Summary
@track applicantData;
@wire(fetchRecords, {params: '$paramsForAppl'})
    getApplicantData(result){
        const {data,error} = result;
        this.applicantData = result;
        if (data && data.parentRecords && data.parentRecords.length >0) {
            this.investmentInPlant = data.parentRecords[0].Investment_in_Plant_and_Machinery__c  ? data.parentRecords[0].Investment_in_Plant_and_Machinery__c :''; 
            
        } else if (error) {
            console.log(error);
        }
    }

@track applicantRegData;
    @wire(fetchRecords, {params: '$paramsForApplReg'})
        getApplicantRegData(result){
            const {data,error} = result;
            this.applicantRegData = result;
            if (data && data.parentRecords && data.parentRecords.length >0) {
                for(let i=0; i<data.parentRecords.length; i++){ 
                    if (data.parentRecords[i].CharDiscrmtn__c == 'Yes') {
                        this.discrimination = 'Yes';
                        break;
                    }
                    else {
                        this.discrimination = 'No';
                    }
                }
                
            } else if (error) {
                console.log(error);
            }
}


@wire(getLoanDetailsSummary,{ recordId: '$recordId'})
wiredGetLoanDetailsSummary({ data, error }) {

    if (data) {
        this.listOfLoanDetailsSummary = data;
        console.log('listOfLoanDetailsSummary in loanDetailsSummary:::::::', this.listOfLoanDetailsSummary);
       
    } if (error) {
        console.log('ERROR:::::::', error);
    }
}
@track applicationData;

@wire(fetchRecords,{params:'$paramsForBreRec'})
    getAppAssmProRecords(result) {
        const { data, error } = result;
        this.applicationData=result;
        if (data && data.parentRecords && data.parentRecords.length >0) {
            this.appLvlAssmPro = data.parentRecords[0].Application_level_Assessment_program__c  ? data.parentRecords[0].Application_level_Assessment_program__c :'';
            
        } else if (error) {
            console.log(error);
        }
    }

@track smName;
@wire(fetchRecords,{params:'$paramsForSM'})
    getTeamHieararchy(result) {
        const { data, error } = result;
        if (data && data.parentRecords && data.parentRecords.length >0) {
            this.smName = data.parentRecords[0].Employee__r.Name  ? data.parentRecords[0].Employee__r.Name :'';
            
        } else if (error) {
            console.log(error);
        }
    }

}