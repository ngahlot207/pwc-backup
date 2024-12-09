import { LightningElement, track, api, wire } from 'lwc';
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';

import getApexData from '@salesforce/apex/EligibilityScreenDataController.fetchRecords';
import fetchPropRecords from '@salesforce/apex/EligibilityScreenPropertyDetails.fetchPropRecords';
import { getRecord, createRecord, updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import SanctionedLoanAmount_Field from '@salesforce/schema/LoanAppl__c.SanLoanAmt__c';
import ReqLoanAmount_Field from '@salesforce/schema/LoanAppl__c.ReqLoanAmt__c';
import InsuranceAmount_Field from '@salesforce/schema/LoanAppl__c.InsAmt__c';
import Loan_Tenure_Months_Field from '@salesforce/schema/LoanAppl__c.Loan_Tenure_Months__c';
import ReqTenInMonths_Field from '@salesforce/schema/LoanAppl__c.ReqTenInMonths__c';
import EffectiveROI_Field from '@salesforce/schema/LoanAppl__c.EffectiveROI__c';
import RevisedROI from '@salesforce/schema/LoanAppl__c.RevisedROI__c';
import SCHEMECODE from '@salesforce/schema/LoanAppl__c.SchmCode__c';
import LOANPRODUCT from '@salesforce/schema/LoanAppl__c.Product_Code__c';
import ASSESSPROGRAM from '@salesforce/schema/LoanAppl__c.Application_Level_Assessment_Program__c';
import PRODUCT from '@salesforce/schema/LoanAppl__c.Product__c';
import LOAN_APPL_STAGE from '@salesforce/schema/LoanAppl__c.Stage__c';

import { refreshApex } from '@salesforce/apex';

import ApplScorecardRemarkMapping from '@salesforce/label/c.ApplicationScorecardRemarkMapping';
import FINAL_CUST_PROF from '@salesforce/schema/LoanAppl__c.FinalCustProfile__c';

const LoanApplicantionfields = [SanctionedLoanAmount_Field, InsuranceAmount_Field, ReqLoanAmount_Field, Loan_Tenure_Months_Field, ReqTenInMonths_Field, EffectiveROI_Field, FINAL_CUST_PROF, RevisedROI, SCHEMECODE, LOANPRODUCT, ASSESSPROGRAM,PRODUCT,LOAN_APPL_STAGE];
export default class CaptureEligibilityBREComponent extends LightningElement {


  @api hasEditAccess;

  @track lastBre;
  @track custProf;
  @track applScoreRemarkValue;
  @track breResponseDateTime;
  @track applScoreResultValue;
  @track applScorecardRemrk = [];

  @track label = {
    ApplScorecardRemarkMapping
  }

  @track readOnlyMode;
  @track totalAnnualBaseIncm = [];
  @track totalAvrgAnnualBaseIncm;
  @track averagesOfProfitLoss = {};
  @track profitBfrTax;
  @track _loanId;
  @track SanLoanAmt;
  @track InsAmt;
  @track LoanTenureMonths;
  @track EffectiveROI;
  @track TotalProposedLoan;
  @track applName;
  @track wrapObjRec = {};
  @track BREDecision;
  @track isVisibleCombinedLTV;
  @track combinedLTVConditionvalue = [
    'HOME LOAN - BT',
    'HOME LOAN BT - FIXED',
    'TOP UP ON HL BT LOAN',
    'TOP UP ON HL BT LOAN - FIXED',
    'STL - NRP TOP UP',
    'STL - TOP UP',
    'STL - NRP TOP UP - FIXED',
    'STL - TOP UP - FIXED'
  ];

  @api get loanId() {
    return this._loanId;
  }
  set loanId(value) {
    this._loanId = value;
    this.handleBRERecordChange(value);
    this.handleBRELastRunParam(value);

  }
  @track loanApplicationRecord = [];
  @track wrapObjIns;
  @track wrapObjRecomendation = {};

  @track wrapObj = {};
  @track wrapPropObj = {};
  @track wrapApplData = {};
  @track applicantName = [];
  @track applicantLength;
  @track needtoCheckValue = "1000";
  @track totalApproxValue;
  @track ApprMthCashSalary;
  @track sumOfObligation;
  @track sumOfMaxEmiCashSalary;
  @track maxEMICashSalary;
  @track totalAddLTVBsdEliIns;
  @track TotalLoanAmtInclInsurance = 0;
  @track showApplicantEligibility;
  @track loanApplReqLoanAmt;
  @track loanApplStage;
  @track loanApplproduct;
  @track AppScorecardResult;

  @track recomendationTableLength = this.applicantLength + 1;



  connectedCallback() {
    this.eligibiltyMethod();


    if (this.hasEditAccess === false) {
      this.readOnlyMode = true;
    } else {
      this.readOnlyMode = false;
    }

    refreshApex(this.wiredDataProperty);
  }

  @api validateForm() {
    let isValid = true;
    this.template.querySelectorAll('lightning-input').forEach(element => {
      if (element.reportValidity()) {
      } else {
          isValid = false;
      }
    });
    if (!this.checkAssessedIncomeLookup()) {
      isValid = false;
    }
    return isValid;
  }

  renderedCallback() {
    refreshApex(this.wiredDataProperty);
}



  @api handleSave(validate) {
    let returnVariable;
    if (validate) {

      returnVariable = this.handleUpsert();

    }
    else {
      returnVariable = this.handleUpsert();

    }
    return returnVariable;
  }


  @api handleUpsert(validate) {

    var saveStatus = true;
    this.wrapObjRecomendation.sobjectType = "LoanAppl__c";
    this.wrapObjRecomendation.Id = this._loanId;
    let updatedLoanRec = { ...this.wrapObjRecomendation };
    updatedLoanRec.OrgInsAmountLoanAppl__c = this.wrapObjRecomendation.InsAmt__c;
    updatedLoanRec.OrgSanctionLoanAmount__c = this.wrapObjRecomendation.SanLoanAmt__c;
    updatedLoanRec.EffectiveROI__c = this.wrapObjRecomendation.EffectiveROI__c;

    updatedLoanRec.RevisedROI__c = this.wrapObjRecomendation.EffectiveROI__c;

    let newArray = [];
    if (updatedLoanRec) {
      newArray.push(updatedLoanRec);
    }
    if (newArray) {
      upsertSObjectRecord({ params: newArray })
        .then((result) => {
          //console.log('result of upsertSObjectRecord ', result);
        })
        .catch((error) => {
          saveStatus = false;
        });
    }
    return saveStatus;
  }


  eligibiltyMethod() {
    getApexData({ params: this._loanId })
      .then(result => {

        let allEligibiltyWrapDataa = result;
        this.wrapObj = { ...allEligibiltyWrapDataa };

        if (this.wrapObj && this.wrapObj.application && typeof (this.wrapObj.application) != undefined) {
          for (const key in this.wrapObj.application) {
            if (this.wrapObj.application.hasOwnProperty(key)) {

              if (this.wrapObj.application[key] !== null && this.wrapObj.application[key] !== undefined) {

                if (key == "cashFlowAssedIncome") {
                  this.wrapObj.application[key] = this.wrapObj.application[key] + ' %';
                }
                if (key == "businessIncome") {
                  this.wrapObj.application[key] = this.wrapObj.application[key] + ' %';
                } if (key == "grossSalaryBankCredit") {
                  this.wrapObj.application[key] = this.wrapObj.application[key] + ' %';
                } if (key == "netSalaryBankCredit") {
                  this.wrapObj.application[key] = this.wrapObj.application[key] + ' %';
                } if (key == "cashSalary") {
                  this.wrapObj.application[key] = this.wrapObj.application[key] + ' %';
                } if (key == "rentalBankCredit") {
                  this.wrapObj.application[key] = this.wrapObj.application[key] + ' %';
                }
                if (key == "rentalWithoutBankCredit") {
                  this.wrapObj.application[key] = this.wrapObj.application[key] + ' %';
                } if (key == "PensionIncome") {
                  this.wrapObj.application[key] = this.wrapObj.application[key] + ' %';
                } if (key == "AgricultureIncome") {
                  this.wrapObj.application[key] = this.wrapObj.application[key] + ' %';
                } if (key == "OtherIncome") {
                  this.wrapObj.application[key] = this.wrapObj.application[key] + ' %';
                }

              }
            }
          }

        }


        if (this.wrapObj.eligibilityList && this.wrapObj.eligibilityList.length > 0) {
          this.showApplicantEligibility = true;
        }
        if (allEligibiltyWrapDataa.application != null) {

          this.wrapApplData = { ...allEligibiltyWrapDataa.application }
        }

        this.applicantLength = this.wrapObj.eligibilityList.length;

        let allApplicantRecord = this.wrapObj.eligibilityList;

        allApplicantRecord.forEach(element => {
          this.applicantName.push(element.applicantRecord);

        });

        if (this.wrapObj.MaxBreLnEliWoIns != null) {
          this.wrapObj.MaxBreLnEliWoIns = this.wrapObj.MaxBreLnEliWoIns;
        } else {
          this.wrapObj.MaxBreLnEliWoIns = 0;
        }



        let intialSumOfObligation = 0;
        allApplicantRecord.forEach(item => {


          if (item.obligationAMount && item.obligationAMount !== null && item.obligationAMount !== undefined && !isNaN(item.obligationAMount)) {

            intialSumOfObligation += item.obligationAMount;
            this.sumOfObligation = intialSumOfObligation;

          }
        });

      })
      .catch(error => {

      });
  }


  @track roundedDownSumObject = {};
  @track wiredDataProperty;
  propetyArray;

  @wire(fetchPropRecords, { params: '$_loanId' })
  wiredPropertyData(wiredResultProperty) {
    let { error, data } = wiredResultProperty;
    this.wiredDataProperty = wiredResultProperty;
    if (data) {
      console.log()
      let allPropWrapDataa = JSON.parse(data);
      console.log('allPropWrapDataa',JSON.stringify(allPropWrapDataa));
      this.wrapPropObj = { ...allPropWrapDataa };
      
      let propList = allPropWrapDataa.propertyList;
      this.propetyArray = propList.filter(record => record.ApplicantAssetId !== null);
      console.log('propetyArray',JSON.stringify(this.propetyArray));
      let sumOfRownDown = allPropWrapDataa.propertyList;
      let sumObject = {
        LTVBsdEliWOIns: 0,
        AddLTVBsdEliIns: 0,
        TotlLTVBsdLnEliWIns: 0,
        MaxcoltrlLnEliWDeviation: 0,
      };


      sumOfRownDown.forEach(item => {

        sumObject.LTVBsdEliWOIns += item.LTVBsdEliWOIns || 0;
        sumObject.AddLTVBsdEliIns += item.AddLTVBsdEliIns || 0;
        sumObject.TotlLTVBsdLnEliWIns += item.TotlLTVBsdLnEliWIns || 0;
        sumObject.MaxcoltrlLnEliWDeviation += item.MaxcoltrlLnEliWDeviation || 0;
      });


      Object.keys(sumObject).forEach(key => {
        sumObject[key] = Math.floor(sumObject[key] * 1000) / 1000;
      });


      this.roundedDownSumObject = sumObject;

      let initialpropertyValue = 0;
      this.propetyArray.forEach(record => {

        if (record.ApproxValue !== undefined && record.ApproxValue !== null && !isNaN(record.ApproxValue)) {

          initialpropertyValue += record.ApproxValue;
          this.totalApproxValue = initialpropertyValue;

        }
      });


      let financialArray = allPropWrapDataa.applFinanacialObj;

      if (financialArray && typeof financialArray !== 'undefined') {
        const { length } = financialArray;

        financialArray.forEach(obj => {
          Object.keys(obj).forEach(key => {
            if (typeof obj[key] === 'number') {
              this.averagesOfProfitLoss[key] = (this.averagesOfProfitLoss[key] || 0) + obj[key] / length;
            }
          });
        });

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

          // Add the result to the object
          this.totalAnnualBaseIncm.push(result);
        });

      }


      const sum = Object.keys(this.averagesOfProfitLoss)
        .filter(key => key !== "Taxes__c")
        .reduce((acc, key) => acc + this.averagesOfProfitLoss[key], 0);

      // Subtract Taxes__c from the sum
      const resultOfAverage = sum - this.averagesOfProfitLoss["Taxes__c"];
      this.totalAvrgAnnualBaseIncm = resultOfAverage;


      if ((this.TotalLoanAmtInclInsurance != null || this.TotalLoanAmtInclInsurance != undefined) && (this.wrapPropObj.sumFedFinaExpLnAmt != null || this.wrapPropObj.sumFedFinaExpLnAmt != undefined)) {
        this.TotalProposedLoan = parseInt(this.wrapPropObj.sumFedFinaExpLnAmt || 0) + parseInt(this.TotalLoanAmtInclInsurance)
      } else if ((this.wrapPropObj.sumFedFinaExpLnAmt == null || this.wrapPropObj.sumFedFinaExpLnAmt == undefined) && (this.TotalLoanAmtInclInsurance != null || this.TotalLoanAmtInclInsurance != undefined)) {
        this.TotalProposedLoan = parseInt(this.TotalLoanAmtInclInsurance);
      } else if ((this.wrapPropObj.sumFedFinaExpLnAmt != null || this.wrapPropObj.sumFedFinaExpLnAmt != undefined) && (this.TotalLoanAmtInclInsurance == null || this.TotalLoanAmtInclInsurance == undefined)) {
        this.TotalProposedLoan = parseInt(this.wrapPropObj.sumFedFinaExpLnAmt);
      }
    } else if (error) {
    }
  }

  //LAK-10323
  get TotalFedfinaExp(){
    if ((this.TotalLoanAmtInclInsurance != null || this.TotalLoanAmtInclInsurance != undefined) && (this.wrapPropObj.sumFedFinaExpLnAmt != null || this.wrapPropObj.sumFedFinaExpLnAmt != undefined)) {
      this.TotalProposedLoan = parseInt(this.wrapPropObj.sumFedFinaExpLnAmt || 0) + parseInt(this.TotalLoanAmtInclInsurance)
    } else if ((this.wrapPropObj.sumFedFinaExpLnAmt == null || this.wrapPropObj.sumFedFinaExpLnAmt == undefined) && (this.TotalLoanAmtInclInsurance != null || this.TotalLoanAmtInclInsurance != undefined)) {
      this.TotalProposedLoan = parseInt(this.TotalLoanAmtInclInsurance);
    } else if ((this.wrapPropObj.sumFedFinaExpLnAmt != null || this.wrapPropObj.sumFedFinaExpLnAmt != undefined) && (this.TotalLoanAmtInclInsurance == null || this.TotalLoanAmtInclInsurance == undefined)) {
      this.TotalProposedLoan = parseInt(this.wrapPropObj.sumFedFinaExpLnAmt);
    }
    return this.TotalProposedLoan;
  }

  handleInputChange(event) {

    this.wrapObjRecomendation[event.target.dataset.name] = event.target.value;

    if (event.target.name === 'SanLoanAmt__c') {

      let value = parseFloat(event.target.value);

      if (!isNaN(value)) {
        this.wrapObjRecomendation.SanLoanAmt__c = value;
      } else {

        this.wrapObjRecomendation.SanLoanAmt__c = 0;
      }

    }
    if (event.target.name === 'InsAmt__c') {

      let value = parseFloat(event.target.value) || 0;
      if (!isNaN(value)) {
        this.wrapObjRecomendation.InsAmt__c = value;
      } else {

        this.wrapObjRecomendation.InsAmt__c = 0;
      }
    }

    if (!isNaN(this.TotalLoanAmtInclInsurance) && (!isNaN(this.wrapObjRecomendation.SanLoanAmt__c) || !isNaN(this.wrapObjRecomendation.InsAmt__c))) {
      this.TotalLoanAmtInclInsurance = parseInt(this.wrapObjRecomendation.SanLoanAmt__c || 0) + parseInt(this.wrapObjRecomendation.InsAmt__c || 0);

    } else if ((!isNaN(this.wrapObjRecomendation.SanLoanAmt__c) || !isNaN(this.wrapObjRecomendation.InsAmt__c))) {
      this.TotalLoanAmtInclInsurance = parseInt((this.wrapObjRecomendation.SanLoanAmt__c) || (this.wrapObjRecomendation.InsAmt__c));
    }
    else {

      this.TotalLoanAmtInclInsurance = 0;

    }

    if ((this.TotalLoanAmtInclInsurance != null || this.TotalLoanAmtInclInsurance != undefined) && (this.wrapPropObj.sumFedFinaExpLnAmt != null || this.wrapPropObj.sumFedFinaExpLnAmt != undefined)) {
      this.TotalProposedLoan = parseInt(this.wrapPropObj.sumFedFinaExpLnAmt || 0) + parseInt(this.TotalLoanAmtInclInsurance)
    } else if ((this.wrapPropObj.sumFedFinaExpLnAmt == null || this.wrapPropObj.sumFedFinaExpLnAmt == undefined) && (this.TotalLoanAmtInclInsurance != null || this.TotalLoanAmtInclInsurance != undefined)) {
      this.TotalProposedLoan = parseInt(this.TotalLoanAmtInclInsurance);
    } else if ((this.wrapPropObj.sumFedFinaExpLnAmt != null || this.wrapPropObj.sumFedFinaExpLnAmt != undefined) && (this.TotalLoanAmtInclInsurance == null || this.TotalLoanAmtInclInsurance == undefined)) {
      this.TotalProposedLoan = parseInt(this.wrapPropObj.sumFedFinaExpLnAmt);
    }
  }

  showMaxPlotField = false;
  @wire(getRecord, { recordId: '$_loanId', fields: LoanApplicantionfields })
  wiredData(wiredResultLoanApplication) {
    let { error, data } = wiredResultLoanApplication;

    if (data) {

      this.loanApplproduct = data.fields.Product__c.value ? data.fields.Product__c.value : null;
      this.loanApplStage = data.fields.Stage__c.value ? data.fields.Stage__c.value : null;
      this.loanApplReqLoanAmt = data.fields.ReqLoanAmt__c.value ? data.fields.ReqLoanAmt__c.value : 0;

      if (data.fields.SchmCode__c.value != null || data.fields.SchmCode__c.value != undefined) {
        if (data.fields.SchmCode__c.value.includes("PLOT + CONSTRUCTION")) {
          this.showMaxPlotField = true;
        }
        else {
          this.showMaxPlotField = false;
        }
        //   if (this.combinedLTVConditionvalue.some(value => data.fields.SchmCode__c.value.includes(value))) {
        //     this.isVisibleCombinedLTV = true;
        // }else{
        // this.isVisibleCombinedLTV = false;
        // }
      }

      if (data.fields.Product_Code__c.value != null || data.fields.Product_Code__c.value != undefined) {
        this.productCode = data.fields.Product_Code__c.value;
      }

      if (data.fields.Application_Level_Assessment_Program__c.value != null || data.fields.Application_Level_Assessment_Program__c.value != undefined) {
        this.wrapObjRecomendation.Application_Level_Assessment_Program__c = data.fields.Application_Level_Assessment_Program__c.value;
      }

      if (data.fields.SanLoanAmt__c.value != null || data.fields.SanLoanAmt__c.value != undefined) {
        this.wrapObjRecomendation.SanLoanAmt__c = data.fields.SanLoanAmt__c.value
      }

      this.wrapObjRecomendation.InsAmt__c = data.fields.InsAmt__c.value != null ? data.fields.InsAmt__c.value : '';

      if (this.wrapObjRecomendation.SanLoanAmt__c != undefined && this.wrapObjRecomendation.InsAmt__c != undefined) {
        this.TotalLoanAmtInclInsurance = this.wrapObjRecomendation.SanLoanAmt__c + this.wrapObjRecomendation.InsAmt__c
      }

      if (data.fields.Loan_Tenure_Months__c.value != null || data.fields.Loan_Tenure_Months__c.value != undefined) {
        this.wrapObjRecomendation.Loan_Tenure_Months__c = data.fields.Loan_Tenure_Months__c.value;
      }
      else {
        this.wrapObjRecomendation.Loan_Tenure_Months__c = data.fields.ReqTenInMonths__c.value;
      }

      if (data.fields.EffectiveROI__c.value != null || data.fields.EffectiveROI__c.value != undefined) {
        this.wrapObjRecomendation.EffectiveROI = data.fields.EffectiveROI__c.value;
        this.wrapObjRecomendation.EffectiveROI__c = data.fields.EffectiveROI__c.value;//LAK-10003
      } else {
        this.wrapObjRecomendation.EffectiveROI = '';
      }
      this.custProf = data.fields.FinalCustProfile__c.value ? data.fields.FinalCustProfile__c.value : " ";
      // this.handleUpsert(); // sk LAK-6435
    }



  }

  @track islatestTrue = true;
  @track eligibleType = 'Application';
  @track
  //Combined_LTV_And_FOIR_with_Insurance__c
  //LAK-8622
  parameter = {
    ParentObjectName: 'BRE__c ',
    ChildObjectRelName: '',
    parentObjFields: ['Id', 'LoanAppl__c', 'Applicant__c', 'EMI__c', 'Actual_FOIR__c', 'Actual_LTV__c', 'EligibilityType__c', 'CombLTV_FOIR__c', 'Combined_LTV_And_FOIR_without_Insurance__c','Combined_LTV_And_FOIR_with_Insurance__c', 'Combined_LTV__c', 'FinancialLoanEligibilityTotal__c', 'Financial_Loan_Eligibility_other_cash__c', 'MaxBreLnEliWoIns__c', 'MaxBreLnEliWIns__c', 'MaxBreLnEliWDeviation__c', 'Eligible_tenure_in_Months__c', 'RAACROI__c', 'FinaLnEligOthr_Cash_Salary__c', 'FinLoanEligibCashSalary__c', 'Financial_Loan_Eligibility_Total__c', 'MaxFinLnEligblwithDevi__c', 'Application_level_Assessment_program__c', 'CreatedDate', 'IsLatest__c', 'MaxPlotFund__c', 'Decision__c','AppScorecardResult__c'],
    childObjFields: [],
    queryCriteria: ''
  }

  handleBRERecordChange() {
    let tempParams = this.parameter;
    tempParams.queryCriteria = 'WHERE LoanAppl__c=\'' + this._loanId + '\' AND EligibilityType__c=\'' + this.eligibleType + '\'AND IsLatest__c=' + this.islatestTrue;
    this.parameter = { ...tempParams };


  }
  showBREDecision = false;
  @wire(getSobjectData, { params: '$parameter' })
  handleBREResponse(wiredResultBRE) {
    let { error, data } = wiredResultBRE;
    if (data) {
      if (data && data.parentRecords) {
        let breDataArray = data.parentRecords;
        if (breDataArray && breDataArray.length > 0) {
          this.BREDecision = breDataArray[0].Decision__c ? breDataArray[0].Decision__c : null;
          this.AppScorecardResult = breDataArray[0].AppScorecardResult__c ? breDataArray[0].AppScorecardResult__c : null;
          this.showBREDecision = true;
          this.wrapObjRec = breDataArray[0];
        }
      }
      this.getBreDecisionRemark();
    } else if (error) {
    }
  }



  @track
  breParam = {
    ParentObjectName: 'BRE__c ',
    ChildObjectRelName: '',
    parentObjFields: ['Id', 'LoanAppl__c', 'CreatedDate', 'IsLatest__c', 'LastModifiedDate'],
    childObjFields: [],
    queryCriteria: ''
  }

  handleBRELastRunParam() {
    let tempParams = this.breParam;
    tempParams.queryCriteria = 'WHERE LoanAppl__c=\'' + this._loanId + '\' AND IsLatest__c=' + this.islatestTrue + ' order by CreatedDate DESC limit 1';
    this.breParam = { ...tempParams };

  }
  @wire(getSobjectData, { params: '$breParam' })
  handleBRELastRun(result) {
    let { error, data } = result;
    if (data) {
      if (data && data.parentRecords) {
        let breDataArray = data.parentRecords;
        if (breDataArray && breDataArray.length > 0) {
          this.lastBre = breDataArray[0].CreatedDate;

          //LAK-6471 (Response from Call 1, 2 , 3 to be displayed) Start
          this.breResponseDateTime = breDataArray[0].LastModifiedDate ? breDataArray[0].LastModifiedDate : null;
          //to be uncommented
          this.applScoreResultValue = breDataArray[0].DecisionScrecardStg1__c ? breDataArray[0].DecisionScrecardStg1__c : null;
          // this.applScorecardRemrk = JSON.parse(this.label.ApplScorecardRemarkMapping);
          // if (this.applScorecardRemrk && this.applScorecardRemrk.length > 0 && this.applScoreResultValue != null) {
          //   let scorecardRemark = [...this.applScorecardRemrk];

          //   scorecardRemark.forEach(element => {
          //     if (element.scoreResult == this.applScoreResultValue.toLowerCase()) {
          //       this.applScoreRemarkValue = element.scoreRemark;
          //     }
          //   });
          // }
       //LAK-6471 Stop
        }
      }
    } else if (error) {
    }
  }

  getBreDecisionRemark(){
    let breDecisionParameter = {
        ParentObjectName: 'MasterData__c',
        ChildObjectRelName: '',
        parentObjFields: ['Product__c', 'Stage__c','Application_Scorecard_Decision__c', 'Min__c','Max__c', 'Bre_Decision__c','BRE_Remarks__c'],
        childObjFields: [],
        queryCriteria: ' where Type__c = \'Bre Decision Remark\''
    }
    getSobjectData({
            params: breDecisionParameter
        })
        .then((result) => {
            if(result.parentRecords && result.parentRecords.length > 0){
            console.log('result in getBreDecisionRemark method', JSON.stringify(result.parentRecords.length))
            console.log('loanApplStage,loanApplSubStage,loanApplReqLoanAmt,AppScorecardResult,loanApplproduct,BREDecision ', this.loanApplStage,this.loanApplSubStage,this.loanApplReqLoanAmt,this.AppScorecardResult,this.loanApplproduct,this.BREDecision)
            let filteredRecords = result.parentRecords.filter(record => {
                return  record.Product__c.toLowerCase().includes(this.loanApplproduct.toLowerCase()) &&
                        record.Bre_Decision__c.toLowerCase() === this.BREDecision.toLowerCase() &&
                        record.Stage__c.toLowerCase().includes(this.loanApplStage.toLowerCase()) &&
                        record.Application_Scorecard_Decision__c.toLowerCase().includes(this.AppScorecardResult.toLowerCase()) &&
                        record.Min__c < this.loanApplReqLoanAmt &&
                        record.Max__c > this.loanApplReqLoanAmt;
            });

            if (filteredRecords.length > 0) {
                this.applScoreRemarkValue = filteredRecords[0].BRE_Remarks__c;
            }
        }
        })
        .catch((error) => {
            console.log('Error in getFOIR method', JSON.stringify(error))
        })

}



  get assessmentProgramVisibility() {
    if(this.TotalLoanAmtInclInsurance && this.TotalLoanAmtInclInsurance > 2500000){
      return true;
    }else{
      this.wrapObjRecomendation.Application_Level_Assessment_Program__c = null;
      return false;
    }
  }

  @track productCode;

  get filterCondition() {
    if(this.productCode){
      return ' SalesforceCode__c = \''+this.productCode+'\' AND Type__c = \'Assessment Program\'';
    }
  }

  @track selectedRecordId;

  handleValueSelect(event) {
    if (event.detail && event.detail.record && event.detail.record.FinnoneCode__c) {
      this.wrapObjRecomendation.Application_Level_Assessment_Program__c = event.detail.record.FinnoneCode__c;
      this.selectedRecordId = event.detail.id;
    }
  }

  checkAssessedIncomeLookup(){
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
}