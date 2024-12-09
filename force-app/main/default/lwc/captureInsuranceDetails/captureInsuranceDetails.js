import { LightningElement, track, api, wire } from 'lwc';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, publish, MessageContext, unsubscribe, releaseMessageContext, createMessageContext } from 'lightning/messageService';
import { getRecord, createRecord, updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import { refreshApex } from '@salesforce/apex';
import LOANaPPL_OBJECT from '@salesforce/schema/LoanAppl__c';
import isAssessedIncomeProgram_Field from '@salesforce/schema/LoanAppl__c.AssesIncomeAppl__c';
// import SanctionedLoanAmount_Field from '@salesforce/schema/LoanAppl__c.SanLoanAmt__c';
// import InsuranceAmount_Field from '@salesforce/schema/LoanAppl__c.InsAmt__c';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";

// custom Lable
import Inasurance_Detail_ErrorMessage from '@salesforce/label/c.Inasurance_Detail_ErrorMessage';
import Insurance_Details_SuccessMessage from '@salesforce/label/c.Insurance_Details_SuccessMessage';

// new additionn
// import getApexData from '@salesforce/apex/EligibilityScreenDataController.fetchRecords';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import SanctionedLoanAmount_Field from '@salesforce/schema/LoanAppl__c.SanLoanAmt__c';
import ReqLoanAmount_Field from '@salesforce/schema/LoanAppl__c.ReqLoanAmt__c';
import InsuranceAmount_Field from '@salesforce/schema/LoanAppl__c.InsAmt__c';
import Loan_Tenure_Months_Field from '@salesforce/schema/LoanAppl__c.Loan_Tenure_Months__c';
import ReqTenInMonths_Field from '@salesforce/schema/LoanAppl__c.ReqTenInMonths__c';
import EffectiveROI_Field from '@salesforce/schema/LoanAppl__c.EffectiveROI__c';
const LoanApplicantionfields = [SanctionedLoanAmount_Field, InsuranceAmount_Field, ReqLoanAmount_Field, Loan_Tenure_Months_Field, ReqTenInMonths_Field, EffectiveROI_Field];

// const LoanApplicantionfields = [isAssessedIncomeProgram_Field, SanctionedLoanAmount_Field, InsuranceAmount_Field];
export default class CaptureInsuranceDetails extends LightningElement {
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  label = {
    Inasurance_Detail_ErrorMessage,
    Insurance_Details_SuccessMessage
    
}
  @track wrapObjRecomendation = {};
  @track wrapObj = {};
  @track TotalLoanAmtInclInsurance = 0;


  @track _loanAppId;
  @api get loanAppId() {
    return this._loanAppId;
  }
  set loanAppId(value) {
    this._loanAppId = value;
    //  this.setAttribute("loanAppId", value);

    this.handleRecordAppIdChange(value);
    this.handleBRERecordChange(value);
    // this.handleLeadRecord(value);
  }

  // insDetailMethod() {
  //   getApexData({ params: this._loanAppId })
  //     .then(result => {
  //       console.log('Result of list', result);
  //       console.log('list of list', JSON.parse(result));
  //       let allEligibiltyWrapDataa = JSON.parse(result);
  //       this.wrapObj = { ...allEligibiltyWrapDataa };

  //     }).catch(error => {
  //       console.error('Error:', error);
  //     });
  // }

  //SELECT Id, LoanAppl__c, Applicant__c,EMI__c,Actual_FOIR__c, Actual_LTV__c,EligibilityType__c,
  // CombLTV_FOIR__c FROM BRE__c where EligibilityType__c='Application' AND LoanAppl__c='a08C40000084aMrIAI'

  @track eligibleType = 'Application';

  @track
  parameter = {
    ParentObjectName: 'BRE__c ',
    ChildObjectRelName: '',
    parentObjFields: ['Id', 'LoanAppl__c', 'Applicant__c', 'EMI__c', 'Actual_FOIR__c', 'Actual_LTV__c', 'EligibilityType__c', 'CombLTV_FOIR__c'],
    childObjFields: [],
    queryCriteria: ''
  }

  handleBRERecordChange() {
    let tempParams = this.parameter;
    tempParams.queryCriteria = 'WHERE LoanAppl__c=\'' + this._loanAppId + '\' AND EligibilityType__c=\'' + this.eligibleType + '\'';
    this.parameter = { ...tempParams };

  }
  @wire(getSobjectData, { params: '$parameter' })
  handleBREResponse(wiredResultBRE) {
    let { error, data } = wiredResultBRE;
    if (data) {
      console.log('bre data>>>>>>>>>', data.parentRecords.length);
      if (data.parentRecords.length > 0) {
        console.log('bre response data available>>>>');
        let breDataArray = data.parentRecords;
        console.log('breDataArray>>>>>', breDataArray);
        this.wrapObj = breDataArray[0];
        console.log('this.wrapObj>>>>', this.wrapObj);
        // let userTeamRole = data.parentRecords[0].EmpRole__c;
        // this.userTeamRoleData = data.parentRecords[0].EmpRole__c;
        // if (userTeamRole === 'RM') {
        //   this.isGSTRequired = false;
        // }
        // else if (userTeamRole === 'CPA') {
        //   this.isGSTRequired = true;
        // } else {
        //   this.isGSTRequired = true;
        // }

      }
    } else if (error) {
      console.error('Error BRE data ------------->', error);
    }
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

    } else if ((!isNaN(this.wrapObjRecomendation.SanLoanAmt__c) || !isNaN(this.wrapObjRecomendation.InsAmt__c))) {
      this.TotalLoanAmtInclInsurance = parseInt((this.wrapObjRecomendation.SanLoanAmt__c) || (this.wrapObjRecomendation.InsAmt__c));
    }
    else {

      this.TotalLoanAmtInclInsurance = 0;

    }

    // if (!isNaN(this.TotalLoanAmtInclInsurance && (!isNaN(this.wrapObjRecomendation.SanLoanAmt__c) || !isNaN(this.wrapObjRecomendation.InsAmt__c)))) {
    //   // this.TotalLoanAmtInclInsurance = parseInt(this.wrapObjRecomendation.SanLoanAmt__c) + parseInt(this.wrapObjRecomendation.InsAmt__c);
    //   this.TotalLoanAmtInclInsurance = parseInt(this.wrapObjRecomendation.SanLoanAmt__c || 0) + parseInt(this.wrapObjRecomendation.InsAmt__c || 0);
    //   console.log('this.TotalLoanAmtInclInsurance>>>>', this.TotalLoanAmtInclInsurance);
    //   console.log('this.wrapObjRecomendation if>>>>', this.wrapObjRecomendation);
    // } else {
    //   this.TotalLoanAmtInclInsurance = 0;
    //   console.log('this.wrapObjRecomendation inside else>>>>');
    // }
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
  //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  disableMode = false;
  @track activeSection;
  @api hasEditAccess;
  @track isinsuranceDetails = false;
  // @track TotalLoanAmtInclInsurance = 0;

  // @track wrapObj = {};


  // @track _loanAppId;
  // @api get loanAppId() {
  //     return this._loanAppId;
  // }
  // set loanAppId(value) {
  //     this._loanAppId = value;
  //     //  this.setAttribute("loanAppId", value);

  //     this.handleRecordAppIdChange(value);
  //     // this.handleLeadRecord(value);
  // }

  // @wire(getRecord, { recordId: '$_loanAppId', fields: LoanApplicantionfields })

  // applicantDetailsHandler(wiredResultLoanApplication) {
  //     console.log('applicantDetailsHandler:::::::::', wiredResultLoanApplication);
  //     let { error, data } = wiredResultLoanApplication;
  //     // this.wiredDataLoanApplication = wiredResultLoanApplication;

  //     if (data) {

  //         this.wrapObj.InsAmt__c = data.fields.InsAmt__c.value!=null ? data.fields.InsAmt__c.value : '';
  //         this.wrapObj.SanLoanAmt__c = data.fields.SanLoanAmt__c.value!=null ? data.fields.SanLoanAmt__c.value : '';
  //         if (this.wrapObj.SanLoanAmt__c != undefined && this.wrapObj.InsAmt__c != undefined) {
  //             this.TotalLoanAmtInclInsurance = this.wrapObj.SanLoanAmt__c + this.wrapObj.InsAmt__c
  //         }

  //     }

  // }
  connectedCallback() {
     this.scribeToMessageChannel();
    // this.insDetailMethod();
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

  @api validateForm() {

    // const allValid = [
    //     ...this.template.querySelectorAll('lightning-input'),
    // ].reduce((validSoFar, inputCmp) => {
    //     inputCmp.reportValidity();
    //     return validSoFar && inputCmp.checkValidity();
    // }, true);

    let isValid = true
    this.template.querySelectorAll('lightning-input').forEach(element => {
      if (element.reportValidity()) {
      } else {
        isValid = false;
      }
    });
    return isValid;

  }


  @api handleSave(validate) {
    // if (validate) {
    // if (allValid) {
    // alert('All form entries look valid. Ready to submit!');
    var saveStatus = true;


    // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    this.wrapObjRecomendation.sobjectType = "LoanAppl__c";
    this.wrapObjRecomendation.Id = this._loanAppId;
    console.log('in Reject end and loanApplicationRecord => ', this.wrapObjRecomendation);

    let newArray = [];
    if (this.wrapObjRecomendation) {
      newArray.push(this.wrapObjRecomendation);
    }
    // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    // console.log('in Reject end and loanApplicationRecord => ', this.wrapObj);
    // this.wrapObj.sobjectType = "LoanAppl__c";
    // this.wrapObj.Id = this._loanAppId;


    // let newArray = [];
    // if (this.wrapObj) {
    //     newArray.push(this.wrapObj);
    // }
    if (newArray) {
      console.log('new array is ', JSON.stringify(newArray));
      upsertSObjectRecord({ params: newArray })
        .then((result) => {
          //console.log('saveStatus => ', saveStatus);
          console.log('result => ', result);
          this.showToastMessage('Success', this.label.Insurance_Details_SuccessMessage, 'success', 'sticky');

          // this.dispatchEvent(
          //     new ShowToastEvent({
          //         title: "Success",
          //         message: "Insurance Details saved Successfullly",
          //         variant: "success",
          //     }),

          // );

        })
        .catch((error) => {
          console.log('error ', JSON.stringify(error));
          console.table(error);

          // this.dispatchEvent(
          //   new ShowToastEvent({
          //     title: "Error while updating the record",
          //     message: error.body.message,
          //     variant: "error",
          //   }),
          // );
           this.showToastMessage('Error', this.label.Inasurance_Detail_ErrorMessage, 'error', 'sticky');
          saveStatus = false;


        });
    }
    return saveStatus;
    //  } 

    // else {
    //     // alert('Please update the invalid form entries and try again.');
    //     this.dispatchEvent(
    //         new ShowToastEvent({

    //             title: "Error",
    //             message: "Please fill all required fields in Insurance Details",
    //             variant: "error",
    //         }),
    //     );
    // }


    // console.log('validate', validate);

    // this.template.querySelectorAll('lightning-input')

    // let isInputCorrect;// this.reportValidity();


    // this.template.querySelectorAll('lightning-input').forEach(element => {
    //     console.log('element passed lightning input line 85>>', element.reportValidity());
    //     if (element.reportValidity()) {
    //         isInputCorrect = true;
    //         console.log('element passed lightning input');


    //         if (isInputCorrect === true) {
    //         //////////////////////////////////////////////////////////////////////////
    //         this.wrapObj.sobjectType = "LoanAppl__c";
    //         this.wrapObj.Id = this._loanAppId;
    //         console.log('in Reject end and loanApplicationRecord => ', this.wrapObj);

    //         let newArray = [];
    //         if (this.wrapObj) {
    //             newArray.push(this.wrapObj);
    //         }
    //         if (newArray) {
    //             console.log('new array is ', JSON.stringify(newArray));
    //             upsertSObjectRecord({ params: newArray })
    //                 .then((result) => {

    //                     console.log('result => ', result);
    //                     this.dispatchEvent(
    //                         new ShowToastEvent({
    //                             title: "Success",
    //                             message: "Loan Applications Details saved Successfullly",
    //                             variant: "success",
    //                         }),

    //                     );

    //                 })
    //                 .catch((error) => {
    //                     console.log('error ', JSON.stringify(error));
    //                     console.table(error);

    //                     this.dispatchEvent(
    //                         new ShowToastEvent({
    //                             title: "Error while updating the record",
    //                             message: error.body.message,
    //                             variant: "error",
    //                         }),
    //                     );

    //                 });
    //         }

    //         }
    //     } 
    //     else {
    //         console.log('element  not passed lightning input');
    //         isInputCorrect = true;
    //         //  isValid = false;
    //         // this.dispatchEvent(
    //         //     new ShowToastEvent({

    //         //         title: "Error",
    //         //         message: "Please fill all required fields",
    //         //         variant: "error",
    //         //     }),
    //         // );

    //     }
    // });

    //}
  }

  @track
  params = {
    ParentObjectName: 'LoanAppl__c',
    ChildObjectRelName: 'Applicants__r',
    parentObjFields: ['Id', 'Name', 'Product__c', 'Stage__c', 'SubStage__c', 'ProductSubType__c'],
    childObjFields: ['Id'],
    queryCriteria: ''
  }

  handleRecordAppIdChange() {
    let tempParams = this.params;
    tempParams.queryCriteria = ' where Id = \'' + this._loanAppId + '\''
    this.params = { ...tempParams };
    console.log('loan appl data ', this.params);
  }
  @wire(getSobjectDatawithRelatedRecords, { params: '$params' })
  handleResponse(wiredResult) {
    let { error, data } = wiredResult;
    console.log('applicantion result>>>>', data);
    if (data) {
      let StageData = data;
      if (StageData.parentRecord != undefined) {
        console.log('inside line 43:::::', StageData.parentRecord);
        let stage = StageData.parentRecord.Stage__c;
        console.log('stage print ', stage);

        if (stage != 'QDE' || stage != 'DDE') {

          this.isinsuranceDetails = true;
        }

      }
    }


    // const { data, error } = result;
    //  this._wiredPropOwnerData = result;
    //       if(result.data.parentRecord!=undefined){
    //    let stage = result.data.parentRecord.Stage__c;
    //      console.log('stage print ', stage);
    //   }
    // let stage =  this._wiredPropOwnerData .data.parentRecord.Stage__c;
    // let stage = result.data.parentRecord.Stage__c;
    // console.log('stage print ', stage);
  };
  // handleInputChange(event) {
  //     console.log('event.target.value>>>>>',event.target.value);
  //   //  this.wrapObj[event.target.dataset.name] = event.target.value;
  //   //  this.results[event.target.dataset.objname][event.target.dataset.fieldname] = event.target.value;

  //   this.wrapObj.TotalLoanAmtInclInsurance__c = this.InsAmt__c + this.wrapObj.SanLoanAmt__c;
  //   console.log('this.wrapObj.TotalLoanAmtInclInsurance__c>>>>',this.wrapObj.TotalLoanAmtInclInsurance__c);
  //   console.log('insurance detail object>>>',this.wrapObj);

  // }
  // connectedCallback(){
  //     console.log('insurance detail object>>>',this.wrapObj);

  // }
  // handleInputChange(event) {
  //     if (event.target.name === 'SanLoanAmt__c') {

  //         let value = parseFloat(event.target.value);

  //         if (!isNaN(value)) {
  //             console.log('inside if::::');
  //             this.wrapObj.SanLoanAmt__c = value;
  //         } else {
  //             console.log('inside else::::');

  //             this.wrapObj.SanLoanAmt__c = 0;
  //         }

  //     }
  //     if (event.target.name === 'InsAmt__c') {

  //         let value = parseFloat(event.target.value) || 0;
  //         if (!isNaN(value)) {
  //             console.log('inside if::::');
  //             this.wrapObj.InsAmt__c = value;
  //         } else {
  //             console.log('inside else::::');

  //             this.wrapObj.InsAmt__c = 0;
  //         }
  //     }


  //     if (!isNaN(this.TotalLoanAmtInclInsurance && (!isNaN(this.wrapObj.SanLoanAmt__c) || !isNaN(this.wrapObj.InsAmt__c)))) {
  //         this.TotalLoanAmtInclInsurance = parseInt(this.wrapObj.SanLoanAmt__c) + parseInt(this.wrapObj.InsAmt__c);
  //         console.log('this.TotalLoanAmtInclInsurance>>>>', this.TotalLoanAmtInclInsurance);
  //         console.log('this.wrapObj if>>>>', this.wrapObj);
  //     } else {
  //         this.TotalLoanAmtInclInsurance = 0;
  //         console.log('this.wrapObj inside else>>>>');
  //     }


  // }


  showToastMessage(title, message, variant, mode) {
    const evt = new ShowToastEvent({
        title,
        message,
        variant,
        mode
    });
    this.dispatchEvent(evt);
}
}