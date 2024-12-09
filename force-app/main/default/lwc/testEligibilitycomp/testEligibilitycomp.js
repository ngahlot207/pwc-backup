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
export default class TestEligibilitycomp extends LightningElement {

  // profit and loss variables
  @track totalAnnualBaseIncm = [];
  @track totalAvrgAnnualBaseIncm;
  @track averagesOfProfitLoss = {};
  @track profitBfrTax;
  @track _loanAppId = 'a08C4000007x0uSIAQ'//'a08C4000005yfVKIAY'//'';
  @track SanLoanAmt;
  @track InsAmt;
  @track LoanTenureMonths;
  @track EffectiveROI;
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
  // connectedCallback(){
  //     this.eligibiltyMethod();
  //     this.propertyMethod();
  // }

  // handleClick(){
  // this.handleSave();
  // }
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
  handleSave(validate) {
    // if (validate) {


    const allValid = [
      ...this.template.querySelectorAll('lightning-input'),
    ].reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);
    if (allValid) {
      // alert('All form entries look valid. Ready to submit!');
      this.wrapObjRecomendation.sobjectType = "LoanAppl__c";
      this.wrapObjRecomendation.Id = this._loanAppId;
      console.log('in Reject end and loanApplicationRecord => ', this.wrapObjRecomendation);

      let newArray = [];
      if (this.wrapObjRecomendation) {
        newArray.push(this.wrapObjRecomendation);
      }
      if (newArray) {
        console.log('new array is ', JSON.stringify(newArray));
        upsertSObjectRecord({ params: newArray })
          .then((result) => {

            console.log('result => ', result);
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Success",
                message: " Record saved Successfullly",
                variant: "success",
              }),

            );

          })
          .catch((error) => {
            console.log('error ', JSON.stringify(error));
            console.table(error);

            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error while updating the record",
                message: error.body.message,
                variant: "error",
              }),
            );

          });
      }
    } else {
      // alert('Please update the invalid form entries and try again.');
      this.dispatchEvent(
        new ShowToastEvent({

          title: "Error",
          message: "Please fill all required fields in Insurance Details",
          variant: "error",
        }),
      );
    }



    // }
  }

  eligibiltyMethod() {
    getApexData({ params: this._loanAppId })
      .then(result => {
        console.log('Result of list', result);
        console.log('list of list', JSON.parse(result));
        let allEligibiltyWrapDataa = JSON.parse(result);
        this.wrapObj = { ...allEligibiltyWrapDataa };
        this.applicantLength = this.wrapObj.eligibilityList.length;
        console.log(' this.applicantLength', this.applicantLength);
        console.log('this.wrapObj>>>>>>>', this.wrapObj);

        let allApplicantRecord = this.wrapObj.eligibilityList;

        allApplicantRecord.forEach(element => {
          this.applicantName.push(element.applicantRecord);

        });

        if(this.wrapObj.MaxBreLnEliWoIns!=null){
          this.wrapObj.MaxBreLnEliWoIns =this.wrapObj.MaxBreLnEliWoIns;
        }else{
          this.wrapObj.MaxBreLnEliWoIns =0;
        }
        console.log('all applicant >>>', this.applicantName);
        console.log('allApplicantRecord>>>', allApplicantRecord);


        const totals = allApplicantRecord.reduce((accumulator, item) => {
          // Check if the variables are not null and are valid numbers

          if (item.MaxEMICashSalary !== null && !isNaN(item.MaxEMICashSalary)) {
            
            accumulator.maxEmiCashSalary = (accumulator.MaxEMICashSalary || 0) + item.MaxEMICashSalary;
            console.log('item.MaxEMICashSalary>>>>',accumulator.maxEmiCashSalary);
          }
          //  else {
          //   accumulator.maxEmiCashSalary = 0;
          // }

          if (item.MaxEMIOtherCashSalary !== null && !isNaN(item.MaxEMIOtherCashSalary)) {
            accumulator.maxEmiCashOthrSalary = (accumulator.MaxEMIOtherCashSalary || 0) + item.MaxEMIOtherCashSalary;
          } else {
            accumulator.maxEmiCashOthrSalary = 0;
          }

          if (item.ApprMonthIncOtherthanCashSalary !== null && !isNaN(item.ApprMonthIncOtherthanCashSalary)) {
            accumulator.ApprMthCashSalary = (accumulator.ApprMonthIncOtherthanCashSalary || 0) + item.ApprMonthIncOtherthanCashSalary;
          }

          if (item.obligationAMount !== null && !isNaN(item.obligationAMount)) {
            accumulator.obligation = (accumulator.obligationAMount || 0) + item.obligationAMount;
          } else {
            accumulator.obligation = 0;
          }

         

          

          return accumulator;
        }, {});
        // this.assesedIncome = this.wrapObj.showcashFlowAssessedIncome;

        this.ApprMthCashSalary = totals.ApprMthCashSalary;
        if (totals.obligation != null) {
          this.sumOfObligation = totals.obligation;
        }
        this.sumOfMaxEmiOthrCashSalary = totals.maxEmiCashOthrSalary;
        this.maxEMICashSalary = totals.maxEmiCashSalary;
        console.log('totals>>>>>>',totals.maxEmiCashSalary);
        console.log('totals>>>>>>', totals);
      })
      .catch(error => {
        console.error('Error:', error);
      });
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
        // Object.keys(this.averagesOfProfitLoss).forEach(obj => {
        //   console.log('obj>>>>', obj);
        //   const total = (
        //     this.averagesOfProfitLoss[obj].Profit_Before_Tax__c +
        //     this.averagesOfProfitLoss[obj].Depreciation__c +
        //     this.averagesOfProfitLoss[obj].Interest_on_Partner_Capital__c +
        //     this.averagesOfProfitLoss[obj].Interest_on_Term_Loans__c
        //   );

        //   // Subtract Taxes__c
        //   const result = total - this.averagesOfProfitLoss[obj].Taxes__c;
        //   console.log('result totalAvrgAnnualBaseIncm>>>>>>', result);
        //   // Add the result to the object
        //   // this.totalAvrgAnnualBaseIncm.push(result);
        // });

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


  handleInputChange(event) {

    this.wrapObjRecomendation[event.target.dataset.name] = event.target.value;
    console.log('event of wrapobj>>>>>>>', this.wrapObjRecomendation[event.target.dataset.name]);
    console.log('wrapObjRecomendation>>>>', this.wrapObjRecomendation);


    if (event.target.name === 'SanLoanAmt__c') {

      let value = parseFloat(event.target.value);

      if (!isNaN(value)) {
        console.log('inside if::::');
        this.wrapObjRecomendation.SanLoanAmt__c = value;
      } else {
        console.log('inside else::::');

        this.wrapObjRecomendation.SanLoanAmt__c = 0;
      }

    }
    if (event.target.name === 'InsAmt__c') {

      let value = parseFloat(event.target.value) || 0;
      if (!isNaN(value)) {
        console.log('inside if::::');
        this.wrapObjRecomendation.InsAmt__c = value;
      } else {
        console.log('inside else::::');

        this.wrapObjRecomendation.InsAmt__c = 0;
      }
    }

    if (!isNaN(this.TotalLoanAmtInclInsurance) && (!isNaN(this.wrapObjRecomendation.SanLoanAmt__c) || !isNaN(this.wrapObjRecomendation.InsAmt__c))) {
      this.TotalLoanAmtInclInsurance = parseInt(this.wrapObjRecomendation.SanLoanAmt__c || 0) + parseInt(this.wrapObjRecomendation.InsAmt__c || 0);

    }else if((!isNaN(this.wrapObjRecomendation.SanLoanAmt__c) || !isNaN(this.wrapObjRecomendation.InsAmt__c))){
      this.TotalLoanAmtInclInsurance = parseInt((this.wrapObjRecomendation.SanLoanAmt__c)||(this.wrapObjRecomendation.InsAmt__c));
    }
    else {
    
      this.TotalLoanAmtInclInsurance = 0;
     
    }
  }
  @wire(getRecord, { recordId: '$_loanAppId', fields: LoanApplicantionfields })
  wiredData(wiredResultLoanApplication) {
    console.log('applicantDetailsHandler:::::::::', wiredResultLoanApplication);
    let { error, data } = wiredResultLoanApplication;
    // this.wiredDataLoanApplication = wiredResultLoanApplication;

    if (data) {
      console.log('data', JSON.stringify(data));

      if (data.fields.SanLoanAmt__c.value != null || data.fields.SanLoanAmt__c.value != undefined) {
        this.wrapObjRecomendation.SanLoanAmt__c = data.fields.SanLoanAmt__c.value
      }


      this.wrapObjRecomendation.InsAmt__c = data.fields.InsAmt__c.value != null ? data.fields.InsAmt__c.value : '';

      if (this.wrapObjRecomendation.SanLoanAmt__c != undefined && this.wrapObjRecomendation.InsAmt__c != undefined) {
        this.TotalLoanAmtInclInsurance = this.wrapObjRecomendation.SanLoanAmt__c + this.wrapObjRecomendation.InsAmt__c
      }

      if (data.fields.Loan_Tenure_Months__c.value != null || data.fields.Loan_Tenure_Months__c.value != undefined) {
        this.wrapObjRecomendation.LoanTenureMonths = data.fields.Loan_Tenure_Months__c.value;
      } else {
        this.wrapObjRecomendation.LoanTenureMonths = data.fields.ReqTenInMonths__c.value;
      }
      if (data.fields.EffectiveROI__c.value != null || data.fields.EffectiveROI__c.value != undefined) {
        this.wrapObjRecomendation.EffectiveROI = data.fields.EffectiveROI__c.value;
      } else {
        this.wrapObjRecomendation.EffectiveROI = '';
      }
    }


  }


}