import { LightningElement, api, wire, track } from 'lwc';
import SCHEME_NAME from '@salesforce/schema/SchMapping__c.Name';
//
import fetchRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi'
import getLoanDetailsSummary from '@salesforce/apex/ObligationDetailsSummaryController.getLoanDetailsSummary';
import getDecisionSummary from '@salesforce/apex/ObligationDetailsSummaryController.getDecisionSummary';
import { formatDateFunction  } from 'c/dateUtility';


const SchemeFields = [SCHEME_NAME];

export default class DedupeLoanDetailsSummary extends LightningElement {
linkedLoans;
//@api recordId; // for this Loan Appln Id shcmeId is a07C4000004JE8wIAG, old loan appln Id=a08C4000005ynpNIAQ
@api objectApiName="LoanAppl__c";

@track applicationId;
@track loginDate;

@track branchName;
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
@track assessIncomeApp;
@track sanctionLoanAmt;
@track insuranceAmount;
@track insuAmount;
@track listOfLoanDetailsSummary =[];
@track appLvlAssmPro;
@track isVisibleCombinedLTV;

//
@track disDate
@track totalAmtInc
@track loanProp
@track prodtSubTyp
@track stae
@track staus
@track subStat
@track stag

@track _loanAppId;
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

        let tempParams = this.paramsForLoanAppl;
        tempParams.queryCriteria = ' where Id = \'' + this.recordId + '\''
        this.paramsForLoanAppl = {...tempParams};
}

@track paramsForBreRec={
        ParentObjectName:'BRE__c',
        ChildObjectRelName:'',
        parentObjFields:['Id', 'LoanAppl__c', 'IsLatest__c','Application_level_Assessment_program__c'],
        childObjFields:[],        
        queryCriteria: ""

}
@track decDate;
@wire(getDecisionSummary,{ recordId: '$recordId'})
wiredgetDecisionSummary({ data, error }) {
    if (data) {
        console.log('Decision-Data->',JSON.stringify(data));
        this.decDate = formatDateFunction(data[0].DecisionDt__c);
    } else if (error) {
        console.error('Error loading Decision Summary: ', error);
    }
}

connectedCallback(){
    refreshApex(this.applicationData);
}

@track paramsForLoanAppl={
    ParentObjectName:'LoanAppl__c',
    ChildObjectRelName:'',
    parentObjFields:['Id', 'Name','Status__c','State__c', 'ChannelCode__c','ChannelName__c','SubStage__c','Product__c', 'LoginAcceptDate__c', 'BrchName__c', 'City__c','SchemeId__c','SchmCode__c','SanLoanAmt__c', 'Insurance_Amount__c', 'InsAmt__c','Loan_Tenure_Months__c','Stage__c', 'ProductSubType__c', 'LoanPurposeId__c', 'TotalLoanAmtInclInsurance__c','DisbursementDate__c', 'LoanPurpose__c', 'RMSMName__c','ReqLoanAmt__c','ReqTenInMonths__c', 'EffectiveROI__c', 'BTFinancr__c','Final_MSME__c','AssesIncomeAppl__c'],
    childObjFields:[],        
    queryCriteria: ' where Id = \'' + this.recordId + '\''
    
    }
    @track application =[];
    @wire(fetchRecords, { params: '$paramsForLoanAppl' })
    applicationData(wiredLoanApplData) {
        const { data, error } = wiredLoanApplData;
        console.log('applic--->',JSON.stringify(wiredLoanApplData));
        if(data){
            this.application = data;
            console.log('applicData--->',JSON.stringify(this.application));
            console.log('applionData--->',JSON.stringify(this.application.parentRecords));
            if(this.application.parentRecords && this.application.parentRecords.length > 0){

            this.applicationId = this.application.parentRecords[0].Name ? this.application.parentRecords[0].Name : '';//ok
            this.loginDate = this.application.parentRecords[0].LoginAcceptDate__c ? formatDateFunction(this.application.parentRecords[0].LoginAcceptDate__c) : '';//ok
            console.log('loginDate:::::::', this.loginDate);
            this.branchName = this.application.parentRecords[0].BrchName__c ? this.application.parentRecords[0].BrchName__c : '';//ok
            this.city = this.application.parentRecords[0].City__c ? this.application.parentRecords[0].City__c : '';//ok
            this.product = this.application.parentRecords[0].Product__c ? this.application.parentRecords[0].Product__c : '';//ok
            this.schemeId = this.application.parentRecords[0].SchemeId__c ? this.application.parentRecords[0].SchemeId__c : '';//ok
            this.schemeCode = this.application.parentRecords[0].SchmCode__c ? this.application.parentRecords[0].SchmCode__c : '';//ok
            this.loanPurpose = this.application.parentRecords[0].LoanPurpose__c ? this.application.parentRecords[0].LoanPurpose__c : '';//ok
            this.rMName = this.application.parentRecords[0].RMSMName__c ? this.application.parentRecords[0].RMSMName__c : '';//ok
            this.channelCode = this.application.parentRecords[0].ChannelCode__c ? this.application.parentRecords[0].ChannelCode__c : '';//ok
            this.channelName = this.application.parentRecords[0].ChannelName__c ? this.application.parentRecords[0].ChannelName__c : '';//ok
            this.loanAmount = this.application.parentRecords[0].ReqLoanAmt__c ? this.application.parentRecords[0].ReqLoanAmt__c : '';//ok
            //
            this.disDate = this.application.parentRecords[0].DisbursementDate__c ? formatDateFunction(this.application.parentRecords[0].DisbursementDate__c) : '';
            this.totalAmtInc = this.application.parentRecords[0].TotalLoanAmtInclInsurance__c ? this.application.parentRecords[0].TotalLoanAmtInclInsurance__c : '';
            this.loanProp = this.application.parentRecords[0].LoanPurposeId__c ? this.application.parentRecords[0].LoanPurposeId__c : '';
            this.prodtSubTyp = this.application.parentRecords[0].ProductSubType__c ? this.application.parentRecords[0].ProductSubType__c : '';
            this.stae = this.application.parentRecords[0].State__c ? this.stae = this.application.parentRecords[0].State__c : '';
            this.staus = this.application.parentRecords[0].Status__c ? this.staus = this.application.parentRecords[0].Status__c : '';
            this.subStat = this.application.parentRecords[0].SubStage__c ? this.application.parentRecords[0].SubStage__c : '';
            this.stag = this.application.parentRecords[0].Stage__c ? this.application.parentRecords[0].Stage__c : '';
            //
            this.loanTenure = this.application.parentRecords[0].ReqTenInMonths__c ? this.application.parentRecords[0].ReqTenInMonths__c : '';
            this.effectiveROI = this.application.parentRecords[0].EffectiveROI__c ? this.application.parentRecords[0].EffectiveROI__c : '';
            this.mainApplicant = this.application.parentRecords[0].Final_MSME__c ? this.application.parentRecords[0].Final_MSME__c : '';
            this.assessIncomeApp = this.application.parentRecords[0].AssesIncomeAppl__c ? this.application.parentRecords[0].AssesIncomeAppl__c : '';
            this.sanctionLoanAmt = this.application.parentRecords[0].SanLoanAmt__c ? this.application.parentRecords[0].SanLoanAmt__c : '';
            this.insuranceAmount = this.application.parentRecords[0].Insurance_Amount__c ? this.application.parentRecords[0].Insurance_Amount__c : '';
            this.insuAmount = this.application.parentRecords[0].InsAmt__c ? this.application.parentRecords[0].InsAmt__c : '';
        }
        }
        if(error){
            console.log('error;;;;',JSON.stringify(error));
        }

}


@wire(getRecord, { recordId: '$schemeId', fields: SchemeFields })
recordSchemesHandler({ data, error }) {
   
    if (data) {
        this.schemeNameee = data.fields.Name.value;
       
    } if (error) {
        console.log('ERROR::::::: SchemeFields', error);
    }
}


@wire(getLoanDetailsSummary,{ recordId: '$recordId'})
wiredGetLoanDetailsSummary({ data, error }) {

    if (data) {
        this.listOfLoanDetailsSummary = data;
       
    } if (error) {
        console.log('ERROR::::::: summaryData', error);
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

}