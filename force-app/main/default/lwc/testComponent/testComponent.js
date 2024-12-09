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
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import {subscribe, publish, MessageContext, APPLICATION_SCOPE} from 'lightning/messageService';
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
const DELAY = 500;
import formFactorPropertyName from "@salesforce/client/formFactor";


export default class TestComponent extends LightningElement {

@track allRecOfApplObwithDetai;

@track _loanAppId = 'a0G9H000000ckJZUAY';





tempArrAppConst=[]


@track _wiredAppNameDetail;

connectedCallback(){
    this.handleAppObligDetails();
}

handleAppObligDetails(listOfAppOblDetaIds){
    const mapOfAppBankIdWithDetail=new Map();
    //adding let params
    let currentDate= new Date().toISOString().substring(0, 10);
    
    let noOfemiCal
       let params ={
            ParentObjectName:'BureauRespDtl__c',
            ChildObjectRelName:'Applicant_Obligation_detail__r',
            parentObjFields:[ 'Id', 'Source__c','Applicant__r.FullName__c','EMIClearanceDate__c','BounceInLast12Months__c','BounceInLast18Months__c','TotalBouncesInRTR__c','Repayment_Bank__c', 'RepaymentBankID__c','LoanName__c', 'EMISource__c', 'NatureOfLoan__c', 'FinancierName__c', 'LoanCapacity__c', 'ConsiderObligation__c', 'RepayAc__c', 'Treatment__c', 'NoEMIPaid__c', 'LoanAmount__c', 'Ever90__c', 'MaxDPDLst12month__c', 'MaxDPDLst6month__c', 'Overdues__c', 'MaxDPDLst3month__c', 'TenureLeft__c', 'Tenure__c', 'Applicant__c', 'LoanApplication__c', 'Bureau__c', 'CloseDate__c', 'DisbursalDate__c', 'CurrentOs__c', 'EMI__c','Status__c','FinancierNameID__c'],
            childObjFields:['Id', 'BureauRespDtl__c', 'EMI_Clearance_Date_Identifier__c', 'EMI_Clearance_Date__c', 'BureauRespDtl__r.id'],        
            queryCriteria: ' WHERE LoanApplication__c = \''+this._loanAppId+'\''
      }
      console.log('params',params)
        getData({ params: params })
        .then((data) => {
            let tempArr=[];
            let Arr=[]
            tempArr=JSON.parse(JSON.stringify(data));

            for(var i = 0; i < tempArr.length; i++){
                let CloseDate__c=tempArr[i].parentRecord.CloseDate__c; 
                let c1=new Date(currentDate).getFullYear() - new Date(CloseDate__c).getFullYear();
                let c2=(new Date(currentDate).getMonth() - new Date(CloseDate__c).getMonth());           
                let closeCal = (((c1)*12) + (c2));
                if(closeCal<=12 || CloseDate__c==undefined){
                    Arr.push(tempArr[i])
                }
                else{

                }
            }

            this.allRecOfApplObwithDetai=[...Arr];
          
        })
        .catch(error => {
            console.log('Errorured:- '+JSON.stringify(error));
        });

        

}


}