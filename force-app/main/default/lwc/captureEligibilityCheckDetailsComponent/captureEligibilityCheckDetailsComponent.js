import { LightningElement, track, api, wire } from 'lwc';
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';//LAK-9874

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
import ApplScorecardRemarkMapping from '@salesforce/label/c.ApplicationScorecardRemarkMapping';
import PRODUCT from '@salesforce/schema/LoanAppl__c.Product__c';
import LOAN_APPL_STAGE from '@salesforce/schema/LoanAppl__c.Stage__c';

import FINAL_CUST_PROF from '@salesforce/schema/LoanAppl__c.FinalCustProfile__c';

const LoanApplicantionfields = [SanctionedLoanAmount_Field, InsuranceAmount_Field, ReqLoanAmount_Field, Loan_Tenure_Months_Field, ReqTenInMonths_Field, EffectiveROI_Field, FINAL_CUST_PROF, RevisedROI, SCHEMECODE,PRODUCT,LOAN_APPL_STAGE];
export default class CaptureEligibilityBREComponent extends LightningElement {

  @track label = {
    ApplScorecardRemarkMapping
  }

  @api hasEditAccess;
  @track lastBre;
  @track custProf;
  @track applScoreRemarkValue;
  @track breResponseDateTime;
  @track applScoreResultValue;
  @track applScorecardRemrk=[];
  @track loanApplReqLoanAmt;
  @track loanApplStage;
  @track loanApplproduct;
  @track AppScorecardResult;

  @track readOnlyMode;
  @track totalAnnualBaseIncm = [];
  @track totalAvrgAnnualBaseIncm;
  @track averagesOfProfitLoss = {};
  @track profitBfrTax;
  @track _loanAppId;
  @track SanLoanAmt;
  @track InsAmt;
  @track LoanTenureMonths;
  @track EffectiveROI;
  @track TotalProposedLoan;
  @track applName;
  @track wrapObjRec = {};
  @track BREDecision;
  @track MaxPlotFund;
  @track isVisibleCombinedLTV;
  @track combinedLTVConditionvalue=[
    'HOME LOAN - BT',
    'HOME LOAN BT - FIXED',
    'TOP UP ON HL BT LOAN',
    'TOP UP ON HL BT LOAN - FIXED',
    'STL - NRP TOP UP',
    'STL - TOP UP',
    'STL - NRP TOP UP - FIXED',
    'STL - TOP UP - FIXED'
    ];

  @api get loanAppId() {
    return this._loanAppId;
  }
  set loanAppId(value) {
    this._loanAppId = value;
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
  @track deviationRecords=[];//LAK-9874
  
  @track recomendationTableLength = this.applicantLength + 1;
  

 
  connectedCallback() {
    
    this.eligibiltyMethod();
    

    if (this.hasEditAccess === false) {
      this.readOnlyMode = true;
    } else {
      this.readOnlyMode = false;
    }

    
  }
  
  @api validateForm() {


    let isValid = true
    const isInputCorrect = [
      ...this.template.querySelectorAll("lightning-input"),
    ].reduce((validSoFar, inputField) => {
      inputField.reportValidity();
      return validSoFar && inputField.checkValidity();
    }, true);

    if (isInputCorrect && isInputCorrect === false) {
    }
    
    return isInputCorrect;

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
    this.wrapObjRecomendation.Id = this._loanAppId;
    let updatedLoanRec = { ...this.wrapObjRecomendation };
    updatedLoanRec.OrgInsAmountLoanAppl__c = this.wrapObjRecomendation.InsAmt__c;
    updatedLoanRec.OrgSanctionLoanAmount__c = this.wrapObjRecomendation.SanLoanAmt__c;
    updatedLoanRec.EffectiveROI__c = this.wrapObjRecomendation.EffectiveROI__c;

    updatedLoanRec.RevisedROI__c = this.wrapObjRecomendation.EffectiveROI;

    let newArray = [];
    if (updatedLoanRec) {
      newArray.push(updatedLoanRec);
    }
    if (newArray) {
      
      upsertSObjectRecord({ params: newArray })
        .then((result) => {
        })
        .catch((error) => {
          saveStatus = false;
        });
    }
    return saveStatus;
  }


  eligibiltyMethod() {
    getApexData({ params: this._loanAppId })
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

  @wire(fetchPropRecords, { params: '$_loanAppId' })
  wiredPropertyData(wiredResultProperty) {
    let { error, data } = wiredResultProperty;
    this.wiredDataProperty = wiredResultProperty;
    if (data) {
      
      let allPropWrapDataa = JSON.parse(data);
      
      this.wrapPropObj = { ...allPropWrapDataa };

      let propetyArray = allPropWrapDataa.propertyList;
      
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
      propetyArray.forEach(record => {

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

  showMaxPlotField = false;
  @wire(getRecord, { recordId: '$_loanAppId' , fields: LoanApplicantionfields })
  wiredData(wiredResultLoanApplication) {
    let { error, data } = wiredResultLoanApplication;

    if (data) {

      this.loanApplproduct = data.fields.Product__c.value ? data.fields.Product__c.value : null;
      this.loanApplStage = data.fields.Stage__c.value ? data.fields.Stage__c.value : null;
      this.loanApplReqLoanAmt = data.fields.ReqLoanAmt__c.value ? data.fields.ReqLoanAmt__c.value : 0;

      if (data.fields.SchmCode__c.value != null || data.fields.SchmCode__c.value != undefined) {
        if(data.fields.SchmCode__c.value.includes("PLOT + CONSTRUCTION")){
        this.showMaxPlotField = true;
      }
        else{
        this.showMaxPlotField = false;
      }
    //   if (this.combinedLTVConditionvalue.some(value => data.fields.SchmCode__c.value.includes(value))) {
    //     this.isVisibleCombinedLTV = true;
    // }else{
    // this.isVisibleCombinedLTV = false;
    // }
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
      } else {
        this.wrapObjRecomendation.Loan_Tenure_Months__c = data.fields.ReqTenInMonths__c.value;
      }
     
      if (data.fields.EffectiveROI__c.value != null || data.fields.EffectiveROI__c.value != undefined) {
        this.wrapObjRecomendation.EffectiveROI = data.fields.EffectiveROI__c.value;
      } else {
        this.wrapObjRecomendation.EffectiveROI = '';
      }
      this.custProf = data.fields.FinalCustProfile__c.value ? data.fields.FinalCustProfile__c.value : " ";
      //this.handleUpsert(); (Changes Done By Shekhar under LAK-6435)
    }



  }

  @track islatestTrue = true;
  @track eligibleType = 'Application';
  @track
  //Combined_LTV_And_FOIR_with_Insurance__c
  parameter = {
    ParentObjectName: 'BRE__c ',
    ChildObjectRelName: 'Deviations__r',//LAK-9874
    parentObjFields: ['Id', 'LoanAppl__c', 'Applicant__c', 'EMI__c', 'Actual_FOIR__c', 'Actual_LTV__c', 'EligibilityType__c', 'CombLTV_FOIR__c', 'Combined_LTV_And_FOIR_without_Insurance__c', 'Combined_LTV__c', 'FinancialLoanEligibilityTotal__c', 'Financial_Loan_Eligibility_other_cash__c', 'MaxBreLnEliWoIns__c', 'MaxBreLnEliWIns__c', 'MaxBreLnEliWDeviation__c', 'Eligible_tenure_in_Months__c', 'RAACROI__c', 'FinaLnEligOthr_Cash_Salary__c', 'FinLoanEligibCashSalary__c', 'Financial_Loan_Eligibility_Total__c', 'MaxFinLnEligblwithDevi__c', 'Application_level_Assessment_program__c', 'CreatedDate', 'IsLatest__c', 'MaxPlotFund__c', 'Decision__c','AppScorecardResult__c'],
    childObjFields: ['Id', 'Deviation__c', 'Req_Apprv_Level__c', 'Devia_Desrp__c', 'Dev_DescrId__c'],//LAK-9874
    queryCriteria: ''
  }

  handleBRERecordChange() {
    let tempParams = this.parameter;
    tempParams.queryCriteria = 'WHERE LoanAppl__c=\'' + this._loanAppId + '\' AND EligibilityType__c=\'' + this.eligibleType + '\'AND IsLatest__c=' + this.islatestTrue;
    this.parameter = { ...tempParams };


  }
  showBREDecision = false;
  //LAK-9874
  showDeviationTable =false;
  @wire(getSobjectDatawithRelatedRecords, { params: '$parameter' })
  handleBREResponse(wiredResultBRE) {
    let { error, data } = wiredResultBRE;
    console.log('Wired Data in handleBRELastRun------------>', JSON.stringify(wiredResultBRE));
    if (data) {
      if (data && data.parentRecord) {
        let breDataArray = data.parentRecord;
        console.log('v------------>', JSON.stringify(breDataArray));
        if(breDataArray){
          this.BREDecision = breDataArray.Decision__c ? breDataArray.Decision__c : null;
          this.AppScorecardResult = breDataArray.AppScorecardResult__c ? breDataArray.AppScorecardResult__c : null;
          this.showBREDecision = true;
          this.wrapObjRec = breDataArray;
        }
        if (breDataArray && breDataArray.Deviations__r && breDataArray.Deviations__r.length > 0) {
          this.showDeviationTable = true;
          this.deviationRecords = breDataArray.Deviations__r;
      } 
      //LAK-9874 END
      }
      this.getBreDecisionRemark();
    } else if (error) {
      console.log('Error Ind handleBREResponse------------>', JSON.stringify(error))
    }
  }


  @track
  breParam = {
    ParentObjectName: 'BRE__c ',
    ChildObjectRelName: '',
    parentObjFields: ['Id', 'LoanAppl__c', 'CreatedDate','LastModifiedDate', 'IsLatest__c', 'MaxPlotFund__c', 'Decision__c'],
    childObjFields: [],
    queryCriteria: ''
  }

  handleBRELastRunParam() {
    let tempParams = this.breParam;
    tempParams.queryCriteria = 'WHERE LoanAppl__c=\'' + this._loanAppId + '\' AND IsLatest__c=' + this.islatestTrue + ' order by CreatedDate DESC limit 1';
    this.breParam = { ...tempParams };

  }
  @wire(getSobjectData, { params: '$breParam' })
  handleBRELastRun(result) {
    let { error, data } = result;
    console.log('Wired Data in handleBRELastRun---------------->',JSON.stringify(result));
    if (data) {
      if (data && data.parentRecords) {
        let breDataArray = data.parentRecords;
      if(breDataArray && breDataArray.length>0)
      {
        this.lastBre = breDataArray[0].CreatedDate;
        //this.BREDecision = breDataArray[0].Decision__c;
        this.MaxPlotFund = breDataArray[0].MaxPlotFund__c;

        //LAK-6471 (Response from Call 1, 2 , 3 to be displayed) start
        this.breResponseDateTime = breDataArray[0].LastModifiedDate ? breDataArray[0].LastModifiedDate: null;
        this.applScoreResultValue = breDataArray[0].DecisionScrecardStg1__c ? breDataArray[0].DecisionScrecardStg1__c : null;

        // this.applScorecardRemrk = JSON.parse(this.label.ApplScorecardRemarkMapping);
        // if(this.applScorecardRemrk && this.applScorecardRemrk.length > 0 && this.applScoreResultValue !=null){
        //     let scorecardRemark = [...this.applScorecardRemrk];
             
        //     scorecardRemark.forEach(element => {
        //         if(element.scoreResult == this.applScoreResultValue.toLowerCase()){
        //             this.applScoreRemarkValue = element.scoreRemark;
        //         }
        //     });
        // }
       //LAK-6471 Stop
      }
      }
    } else if (error) {
      console.log('Error In handleBRELastRun------------>', JSON.stringify(error));
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


}