import { LightningElement, track, api, wire  } from 'lwc';
import getApexData from '@salesforce/apex/ObligationDetailsSummaryController.fetchRecords';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import gePropertyDetails from '@salesforce/apex/ObligationDetailsSummaryController.propDetails';
import getLoanDetailsSummary from '@salesforce/apex/ObligationDetailsSummaryController.getLoanAppData';
export default class SummaryForEligibilityBREComponent extends LightningElement {
//@api recordId;
@track wrapObj = {};
@track wiredDataeligibility; 
@track wrapApplData=[];  
@track applicantLength;
@track applicantName = [];
@track needtoCheckValue = "1000";
@track totalApproxValue = 0;
@track ApprMthCashSalary;
@track sumOfObligation;
@track sumOfMaxEmiCashSalary;
@track maxEMICashSalary;
@track totalAddLTVBsdEliIns;
@track TotalLoanAmtInclInsurance = 0;
@track showApplicantEligibility;
@track _loanId;
@track totalCTVEligibility =[];
@track listOfLoanDetailsSummaryData={};


@track recomendationTableLength = this.applicantLength + 1;

@track wrapObjRec = {};
  @api get recordId() {
    return this._loanId;
  }
  set recordId(value) {
    this._loanId = value;
    this.handleBRERecordChange(value);
  }

@wire(getApexData, {recordId: '$_loanId'})
wiredEligibilityData(wiredResultEligibility) {
  let { error, data } = wiredResultEligibility;
   this.wiredDataeligibility = wiredResultEligibility;
  if (data) {
    let allEligibiltyWrapDataa = data;
    this.wrapObj = { ...allEligibiltyWrapDataa };

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
    
    const totals = allApplicantRecord.reduce((accumulator, item) => {
      if (item.MaxEMICashSalary !== null && !isNaN(item.MaxEMICashSalary)) {
        accumulator.maxEmiCashSalary = (accumulator.MaxEMICashSalary || 0) + item.MaxEMICashSalary;
        }
      
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
    
    this.ApprMthCashSalary = totals.ApprMthCashSalary;
    if (totals.obligation != null) {
      this.sumOfObligation = totals.obligation;
    }
    this.sumOfMaxEmiOthrCashSalary = totals.maxEmiCashOthrSalary;
    this.maxEMICashSalary = totals.maxEmiCashSalary;
  } else if (error) {
     console.error('Error:', error);
  }
}

@track eligibleType = 'Application';
  @track
  parameter = {
    ParentObjectName: 'BRE__c ',
    ChildObjectRelName: '',
    parentObjFields: ['Id', 'LoanAppl__c', 'Applicant__c', 'EMI__c', 'Actual_FOIR__c', 'Actual_LTV__c', 'EligibilityType__c', 'CombLTV_FOIR__c', 'MaxBreLnEliWoIns__c', 'MaxBreLnEliWIns__c', 'MaxBreLnEliWDeviation__c', 'Eligible_tenure_in_Months__c', 'RAACROI__c', 'FinaLnEligOthr_Cash_Salary__c', 'FinLoanEligibCashSalary__c', 'Financial_Loan_Eligibility_Total__c', 'MaxFinLnEligblwithDevi__c', 'Application_level_Assessment_program__c'],
    childObjFields: [],
    queryCriteria: ''
  }

  handleBRERecordChange() {
    let tempParams = this.parameter;
    tempParams.queryCriteria = 'WHERE LoanAppl__c=\'' + this._loanId + '\' AND EligibilityType__c=\'' + this.eligibleType + '\'';
    this.parameter = { ...tempParams };
  }

  @wire(gePropertyDetails,{ recordId: '$_loanId'})
  wiredGePropertyDetails({ data, error }) {

    if (data) {
        this.totalCTVEligibility = data;
    } if (error) {
        console.log('ERROR:::::::', error);
    }
}

@wire(getSobjectData, { params: '$parameter' })
  handleBREResponse(wiredResultBRE) {
    let { error, data } = wiredResultBRE;
    if (data && data.parentRecords && data.parentRecords.length > 0) {
          this.wrapObjRec = data.parentRecords[0];    
    } else if (error) {
      console.error('Error BRE data ------------->', error.body.message);
    }
  }

  @wire(getLoanDetailsSummary,{ recordId: '$_loanId'})
  wiredGetLoanDetailsSummary({ data, error }) {

    if (data) {
    this.listOfLoanDetailsSummaryData = data;
    } if (error) {
        console.log('ERROR:::::::', error);
    }
}

}