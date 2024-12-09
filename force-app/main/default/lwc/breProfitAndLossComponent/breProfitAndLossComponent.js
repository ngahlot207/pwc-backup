import { LightningElement, track, api, wire } from 'lwc';
// import getApexData from '@salesforce/apex/EligibilityCheckDataController.fetchRecords';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, publish, MessageContext, unsubscribe, releaseMessageContext, createMessageContext } from 'lightning/messageService';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';

import getApexData from '@salesforce/apex/EligibilityScreenDataController.fetchRecords';
import fetchPropRecords from '@salesforce/apex/EligibilityScreenPropertyDetails.fetchPropRecords';
import { getRecord, createRecord, updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import SanctionedLoanAmount_Field from '@salesforce/schema/LoanAppl__c.SanLoanAmt__c';
import ReqLoanAmount_Field from '@salesforce/schema/LoanAppl__c.ReqLoanAmt__c';
import InsuranceAmount_Field from '@salesforce/schema/LoanAppl__c.InsAmt__c';
import Loan_Tenure_Months_Field from '@salesforce/schema/LoanAppl__c.Loan_Tenure_Months__c';
import ReqTenInMonths_Field from '@salesforce/schema/LoanAppl__c.ReqTenInMonths__c';
import EffectiveROI_Field from '@salesforce/schema/LoanAppl__c.EffectiveROI__c';
const LoanApplicantionfields = [SanctionedLoanAmount_Field, InsuranceAmount_Field, ReqLoanAmount_Field, Loan_Tenure_Months_Field, ReqTenInMonths_Field, EffectiveROI_Field];
export default class BreProfitAndLossComponent extends LightningElement {

  // profit and loss variables
  @track totalAnnualBaseIncm = [];
  @track totalAvrgAnnualBaseIncm;
  @track averagesOfProfitLoss = {};
  @track profitBfrTax;
  @track _loanAppId = 'a08C4000007x0uSIAQ'//'a08C4000005yfVKIAY'//'';
@api applicantId;
  @track applName;
  @api get loanAppId() {
    return this._loanAppId;
  }
  set loanAppId(value) {
    this._loanAppId = value;

  }
  @track wrapObjRecomendation = {};
  // @track paramValue= 'a08C4000007x0uSIAQ';
  @track wrapObj = {};
  @track wrapPropObj = {};
  @track applicantName = [];
  @track applicantLength;
  @track needtoCheckValue = "1000";
  @track totalApproxValue=0;
  @track ApprMthCashSalary;
  @track sumOfObligation;
  @track sumOfMaxEmiCashSalary;
  @track maxEMICashSalary;
  @track totalAddLTVBsdEliIns;
  @track TotalLoanAmtInclInsurance;

  // @track assesedIncome;
  @track recomendationTableLength = this.applicantLength + 1;

  connectedCallback() {
    this.scribeToMessageChannel();
   // this.eligibiltyMethod();
    this.propertyMethod();
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
    console.log('values', values);

    this.handleSave(values.validateBeforeSave);

  }
 

 
  propertyMethod() {
    fetchPropRecords({ params: this._loanAppId })
      .then(result => {
        console.log('Result of list property', result);
        let allPropWrapDataa = JSON.parse(result);
        console.log('allEligibiltyWrapDataa>>>>', allPropWrapDataa);
        this.wrapPropObj = { ...allPropWrapDataa };
        console.log('this.wrapPropObj>>>>', this.wrapPropObj);

        let propetyArray = allPropWrapDataa.propertyList;
        console.log('propetyArray>>>>>', propetyArray);



        const totalsProperty = propetyArray.reduce((accumulator, item) => {
          // Check if the variables are not null and are valid numbers
          if (item.ApproxValue !== null && !isNaN(item.ApproxValue)) {
            accumulator.Apprvalue = (accumulator.ApproxValue || 0) + item.ApproxValue;
          } else {
            accumulator.Apprvalue = 0;
          }

          if (item.AddLTVBsdEliIns !== null && !isNaN(item.AddLTVBsdEliIns)) {
            accumulator.AddLTVBsdEliIns = (accumulator.AddLTVBsdEliIns || 0) + item.AddLTVBsdEliIns;
          } else {
            accumulator.AddLTVBsdEliIns = 0;
          }


          return accumulator;
        }, {});

        if(totalsProperty.Apprvalue!=undefined){
          this.totalApproxValue = totalsProperty.Apprvalue;
        }else{
          this.totalApproxValue = 0;
        }
        if(totalsProperty.AddLTVBsdEliIns!=undefined){
          this.totalAddLTVBsdEliIns = totalsProperty.AddLTVBsdEliIns;
        }else{
          this.totalAddLTVBsdEliIns  = 0;
        }
      
        console.log('totalsProperty>>>>>>', totalsProperty);
        console.log('  this.totalApproxValue value >>>>', totalsProperty.Apprvalue);

        // for profit and loss table code started 

        this.applName = this.wrapPropObj.applFinanacialObj[0].Applicant_Financial__r.Loan_Applicant__r.FullName__c;
        console.log('this.applName>>>>', this.applName);
        let financialArray = allPropWrapDataa.applFinanacialObj;


        const { length } = financialArray;

        financialArray.forEach(obj => {
          Object.keys(obj).forEach(key => {
            if (typeof obj[key] === 'number') {
              this.averagesOfProfitLoss[key] = (this.averagesOfProfitLoss[key] || 0) + obj[key] / length;
            }
          });
        });
        console.log('averages of>>>>', this.averagesOfProfitLoss);



        financialArray.forEach(obj => {
          // Calculate the total for each property
          const total = (
            obj.Profit_Before_Tax__c +
            obj.Depreciation__c +
            obj.Interest_on_Partner_Capital__c +
            obj.Interest_on_Term_Loans__c
          );

          // Subtract Taxes__c
          const result = total - obj.Taxes__c;
          console.log('result>>>>>>', result);
          // Add the result to the object
          this.totalAnnualBaseIncm.push(result);
        });
        console.log('this.totalResult>>>>>>', this.totalAnnualBaseIncm);
        

        const sum = Object.keys(this.averagesOfProfitLoss)
          .filter(key => key !== "Taxes__c")
          .reduce((acc, key) => acc + this.averagesOfProfitLoss[key], 0);

        // Subtract Taxes__c from the sum
        const resultOfAverage = sum - this.averagesOfProfitLoss["Taxes__c"];
        this.totalAvrgAnnualBaseIncm = resultOfAverage;

      })
      .catch(error => {
        console.error('Error:', error);
      });
  }




}