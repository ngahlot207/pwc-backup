import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { createRecord } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';
import AppStage from "@salesforce/schema/LoanAppl__c.Stage__c";
import AppSubstage from "@salesforce/schema/LoanAppl__c.SubStage__c";
import getSobjectDat from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import validateData from '@salesforce/apex/UWForwardValidations.validateData';
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';

import Stage from '@salesforce/schema/LoanAppl__c.Stage__c';
import subStage from '@salesforce/schema/LoanAppl__c.SubStage__c';
import OwnerId from '@salesforce/schema/LoanAppl__c.OwnerId';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds'
import getSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords'
import upsertMultipleRecords from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import createDocumentDetail from "@salesforce/apex/DocumentDetailController.createDocumentDetail";
import generateDocument from "@salesforce/apex/GeneratePDFandAttachToLoanApplication.generateDocument";

// Custom labels
import ForwardToUW_ErrorMessage from '@salesforce/label/c.ForwardToUW_ErrorMessage';
import ForwardToCPA_SuccessMessage from '@salesforce/label/c.ForwardToCPA_SuccessMessage';
import ForwardToUW_SuccessMessage from '@salesforce/label/c.ForwardToUW_SuccessMessage';
import HostContainer_CoAppl_ErrorMessage from '@salesforce/label/c.HostContainer_CoAppl_ErrorMessage';
import PageURLCAMReporrt from '@salesforce/label/c.PageURLCAMReporrt';
import disbursementMemo from '@salesforce/label/c.PageURLDisbusementMemo';

export default class ForwardApplicationToUW extends NavigationMixin(LightningElement) {
  CustomLabel = {
    ForwardToUW_ErrorMessage,
    ForwardToCPA_SuccessMessage,
    ForwardToUW_SuccessMessage,
    HostContainer_CoAppl_ErrorMessage,
    disbursementMemo

  }
  @api recordId;
  @api objectApiName;
  @api qcpaForward;
  stageVal;
  substageVal;

  @wire(getRecord, { recordId: '$recordId', fields: [AppStage, AppSubstage] })
  currentRecordInfo({ error, data }) {
    if (data) {
      console.log('currentRecordInfo ', data);
      console.table(data);
      this.stageVal = data.fields.Stage__c.value;
      this.substageVal = data.fields.SubStage__c.value;

    } else if (error) {
      this.error = error;
    }

  }


  CPAPoolId;
  UWPoolId;
  opsPoolId;
  @track userDetail = [];
  loanApplicationNumber;
  @track showSpinner = true;
  @track buttonDisplay = true;
  isDeviationPresent=false;
  deviationLevel;


  connectedCallback() {
    this.queueRecord();
    this.queueCPAPool();
    this.queueOpsPool();
    setTimeout(() => {
      this.showSpinner = false;
      this.checkDeviations();
    }, 2000);
  }

  closeAction() {
    this.buttonDisplay = false;
    // this.queueRecord();
    // this.queueCPAPool();
    // this.queueOpsPool();
    this.initialize();
  }

  noBtn() {
    this.dispatchEvent(new CloseActionScreenEvent());
      //dispatching the custom event
      const selectedEvent = new CustomEvent("select", {
        detail: false
      });
      this.dispatchEvent(selectedEvent);
  }
  getForwardUwValidationreport() {
    validateData({ loanId: this.recordId })
      .then((result) => {
        console.log('result after calling validateData method ', result);
        
        if (result && result.length > 0) {
          result.forEach(item => {
            this.showToastMessage("Error", item, 'error', 'sticky');
          })
        } else {
          this.closeAction();
        }
      })
      .catch((error) => {
        console.log("error occured in validateData", error);

      });
  }
  queueRecord() {
    let parameter2 = {
      ParentObjectName: 'Group ',
      ChildObjectRelName: null,
      parentObjFields: ['Id', 'Name'],
      childObjFields: [],
      queryCriteria: ' where Name = \'' + 'UW Pool' + '\''
    }
    getSobjDataWIthRelatedChilds({ params: parameter2 })
      .then(result => {
        if (result.parentRecord.Id != undefined) {
          console.log('Queue Record 2  :' + JSON.stringify(result));
          this.UWPoolId = result.parentRecord.Id;
        }
      //  this.initialize();
      }).catch(error => {
        console.log(error);
      });
  }
  
  checkDeviations() {
    let parameter = {
      ParentObjectName: 'Deviation__c ',
      ChildObjectRelName: null,
      parentObjFields: ['Id', 'Name', 'Req_Apprv_Level__c', 'LoanAppln__r.Id', 'LoanAppln__r.Stage__c'],
      childObjFields: [],
      queryCriteria: ' Where LoanAppln__r.Id = \'' + this.recordId + '\' AND LoanAppln__r.Stage__c = \'' + 'Post Sanction' + '\' AND Appr_Actn__c!=\'' + 'Approved' +'\' ORDER BY Req_Apprv_Level__c DESC'
    }
    getSobjDataWIthRelatedChilds({ params: parameter })
      .then(result => {
        if (result.parentRecord.Id != undefined) {
          this.isDeviationPresent=true;
          this.deviationLevel=result.parentRecord.Req_Apprv_Level__c;
        }
      }).catch(error => {
        console.log(error);
      });
  }
  
  
  queueCPAPool() {
    let parameter2 = {
      ParentObjectName: 'Group ',
      ChildObjectRelName: null,
      parentObjFields: ['Id', 'Name'],
      childObjFields: [],
      queryCriteria: ' where Name = \'' + 'CPA Pool' + '\''
    }
    getSobjDataWIthRelatedChilds({ params: parameter2 })
      .then(result => {
        if (result.parentRecord.Id != undefined) {
          console.log('Queue CPA pool Record 2  :' + JSON.stringify(result));
          this.CPAPoolId = result.parentRecord.Id;
        }
       //  this.initialize();
      }).catch(error => {
        console.log(error);
      });
  }

  queueOpsPool() {
    let parameter3 = {
      ParentObjectName: 'Group ',
      ChildObjectRelName: null,
      parentObjFields: ['Id', 'Name'],
      childObjFields: [],
      queryCriteria: ' where Name = \'' + 'Ops Pool' + '\''
    }
    getSobjDataWIthRelatedChilds({ params: parameter3 })
      .then(result => {
        if (result.parentRecord.Id != undefined) {
          console.log('Queue CPA pool Record 2  :' + JSON.stringify(result));
          this.opsPoolId = result.parentRecord.Id;
        }
       //  this.initialize();
      }).catch(error => {
        console.log(error);
      });
  }
  
@track loanStatus;
  initialize() {
    let parameter = {
      ParentObjectName: 'LoanAppl__c',
      ChildObjectRelName: null,
      parentObjFields: ['Id', 'Stage__c', 'SubStage__c', 'Name','Status__c'],
      childObjFields: [],
      queryCriteria: ' where id = \'' + this.recordId + '\''
    }
    getSobjDataWIthRelatedChilds({ params: parameter })
      .then(result => {
        if (result.parentRecord.Id != undefined) {
          console.log('Result of loan application :' + JSON.stringify(result));
          this.loanApplicationNumber = result.parentRecord.Name;
          this.loanStatus = result.parentRecord.Status__c;
          if(this.loanStatus !== 'BRE Soft Reject'){
            this.update(result.parentRecord);
          }else{
            this.showToastMessage("Error", 'Loan Application Status is '+this.loanStatus, 'error', 'sticky');
          }
         
        }
      })
      .catch(error => {
        console.log(error);
      });
  }
  update(data) {
    console.log('date in update method' + JSON.stringify(data));
    console.log(' this.UWPoolId:', this.UWPoolId);
    let upsertObjectParams = {
      parentRecord: {},
      ChildRecords: [],
      ParentFieldNameToUpdate: ''
    };

    upsertObjectParams.parentRecord.sobjectType = 'LoanAppl__c';
    upsertObjectParams.parentRecord.Id = this.recordId;

    if (data.Stage__c === 'Soft Sanction' && data.SubStage__c === 'Additional Data Entry') {
      console.log('1 if');
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Soft Sanction';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'UW Approval Pool';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.UWPoolId;
      console.log('upsertObjectParams:', upsertObjectParams);
      this.UpsertData(upsertObjectParams);

    }
    else if (data.Stage__c === 'Post Sanction' && (data.SubStage__c === 'Data Entry' || data.SubStage__c === 'Ops Query')) {
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Post Sanction';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'UW Approval Pool';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.UWPoolId;
      this.UpsertData(upsertObjectParams);
      this.getLoanAppData();


    } else if (data.Stage__c === 'DDE' && data.SubStage__c === 'Query') {
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'UnderWriting';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'UW Pool';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.UWPoolId;
      this.UpsertData(upsertObjectParams);

    }
    else if (data.Stage__c === 'DDE' && data.SubStage__c === 'CPA Data Entry') {
      console.log('data.SubStage__c'+data.SubStage__c)
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'UnderWriting';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'UW Pool';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.UWPoolId;
      //this.getApplicantIds();
      this.UpsertData(upsertObjectParams);

    } else if (data.Stage__c === 'Disbursed' && data.SubStage__c === 'Additional Processing') {
      // upsertObjectParams.parentRecord[Stage.fieldApiName] = 'UnderWriting';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'UW Approval Pool';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.UWPoolId;
      this.UpsertData(upsertObjectParams);

    }else if (data.Stage__c === 'DDE' && data.SubStage__c === 'Quality Check' && this.qcpaForward === 'CPA') {
       upsertObjectParams.parentRecord[Stage.fieldApiName] = 'DDE';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'CPA Pool';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.CPAPoolId;
      this.UpsertData(upsertObjectParams);

    }else if (data.Stage__c === 'DDE' && data.SubStage__c === 'Quality Check' && this.qcpaForward === 'UW') {
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'UnderWriting';
     upsertObjectParams.parentRecord[subStage.fieldApiName] = 'UW Pool';
     upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.UWPoolId;
     this.UpsertData(upsertObjectParams);

   }else if (data.Stage__c === 'Post Sanction' && data.SubStage__c === 'Vendor Processing' && this.qcpaForward === 'CPA') {
    upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Post Sanction';
   upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Data Entry Pool';
   upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.CPAPoolId;
   this.UpsertData(upsertObjectParams);

  }else if (data.Stage__c === 'Post Sanction' && data.SubStage__c === 'Vendor Processing' && this.qcpaForward === 'UW') {
    upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Post Sanction';
    upsertObjectParams.parentRecord[subStage.fieldApiName] = 'UW Approval Pool';
    upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.UWPoolId;
    this.UpsertData(upsertObjectParams);
   }else if (data.Stage__c === 'Post Sanction' && data.SubStage__c === 'Vendor Processing' && this.qcpaForward === 'OPS') {
    upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Post Sanction';
    upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Ops Query Pool';
    upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.opsPoolId;
    this.UpsertData(upsertObjectParams);
   }

    else {
      console.log('else');
      history.back(-1);
      const evt = new ShowToastEvent({
        title: 'Error',
        message: this.CustomLabel.ForwardToUW_ErrorMessage,
        variant: 'error',
        mode: 'dismissable'
      });
      this.dispatchEvent(evt);
    }
  }

  UpsertData(params) {
    upsertSobjDataWIthRelatedChilds({ upsertData: params })
      .then((result) => {
        console.log('success');
        console.log('result:', JSON.stringify(result));
        console.log('result:', result.parentRecord.Id);
        console.log('this.loanApplicationNumber:', this.loanApplicationNumber);
if(this.qcpaForward === 'CPA'){
  const event = new ShowToastEvent({
    title: 'Success!',
    messageData: [
      this.CustomLabel.ForwardToCPA_SuccessMessage,
      {
        url: '/' + result.parentRecord.Id,
        label: this.loanApplicationNumber,
      },
    ],
    message: '{1} {0}!',
    variant: 'success',
  });
  this.dispatchEvent(event);
}else{
  const event = new ShowToastEvent({
    title: 'Success!',
    messageData: [
      this.CustomLabel.ForwardToUW_SuccessMessage,
      {
        url: '/' + result.parentRecord.Id,
        label: this.loanApplicationNumber,
      },
    ],
    message: '{1} {0}!',
    variant: 'success',
  });
  this.dispatchEvent(event);

}
      
       
        this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
            recordId: this.recordId,
            actionName: 'view'
          },
        });
        setTimeout(() => {
          location.reload();
        }, 3000);
      })

      .catch(error => {
        console.log('error while updating record:' + JSON.stringify(error));
        this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
            recordId: this.recordId,
            actionName: 'view'
          },
        });

        const evt = new ShowToastEvent({
          title: 'Error',
          message: this.CustomLabel.ForwardToUW_ErrorMessage,
          variant: 'error',
          mode: 'dismissable'
        });
        this.dispatchEvent(evt);
      });
  }
  ///
  fireCustomEvent(title, vart, msg) {
    const selectEvent = new CustomEvent('click', {
      detail: { title: title, variant: vart, message: msg }

    });
    // Fire the custom event
    this.dispatchEvent(selectEvent);
  }

  showToastMessage(title, message, variant, mode) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: mode
    });
    this.dispatchEvent(evt);
  }
  ///
  @track loanApplicationRecord = [];
  getLoanAppData() {
    let paramsLoanApp = {
      ParentObjectName: 'LoanAppl__c',
      parentObjFields: ['Id', 'EMIOptionsintranchedisbursementCase__c', 'Total_PF_Amount__c', 'RemPFDeductFromDisbursementAmount__c', 'FirstEMIDate__c', 'Applicant__c', ''],
      queryCriteria: ' where Id = \'' + this.recordId + '\' '
    }
    getSobjectDat({ params: paramsLoanApp })
      .then((result) => {
        console.log('Loan application data is', JSON.stringify(result));
        if (result.parentRecords && result.parentRecords.length > 0) {
          this.loanApplicationRecord = { ...result.parentRecords[0] };
          console.log('this.loanApplicationRecord-->' + JSON.stringify(this.loanApplicationRecord));
          this.handleGenerateCamReport();
          this.handleGenerateDocumentsForDM();
        }


      })
      .catch((error) => {
        console.log('Error In getting Loan Application Data ', error);
      });
  }
  DocumentDetaiId;
  handleGenerateCamReport() {
    console.log('applicant', this.loanApplicationRecord.Applicant__c);
    console.log('loanId', this.loanApplicationRecord.Id);
    createDocumentDetail({ applicantId: this.loanApplicationRecord.Applicant__c, loanAppId: this.loanApplicationRecord.Id, docCategory: 'CAM Report', docType: 'CAM Report', docSubType: 'CAM Report', availableInFile: false })
      .then((result) => {
        console.log('createCamReport result ', result);
        this.DocumentDetaiId = result;
        console.log('createCamRecord DocumentDetaiId ', this.DocumentDetaiId);
        let pageUrl = PageURLCAMReporrt + this.loanApplicationRecord.Id;
        console.log('pageurl', pageUrl);
        const pdfData = {
          pageUrl: pageUrl,
          docDetailId: this.DocumentDetaiId,
          fileName: 'CAM Report.pdf'
        }
        this.generateDocument(pdfData);

      })
      .catch((err) => {
        this.showToast("Error", err, "error", "sticky");
        console.log(" createDocumentDetailRecord error===", err);
      });
  }


  generateDocument(pdfData) {
    generateDocument({ wrapObj: pdfData })
      .then((result) => {
        if (result == 'success') {
          this.forLatestDocDetailRec();
        } else {
          console.log('doc Result', result);
        }
      })
      .catch((err) => {
        this.showToast("Error", err, "error", "sticky");
        console.log(" createCam Report error===", err);
      });
  }
  forLatestDocDetailRec() {
    let docCategory = 'CAM Report';
    console.log('document details in forLatestDocDetailRec ###1456');
    let listOfAllParent = [];
    let paramForIsLatest = {
      ParentObjectName: 'DocDtl__c',
      parentObjFields: ['Id', 'Appl__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c', 'AppvdRmrks__c'],
      queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this.loanApplicationRecord.Id + '\' AND Appl__c = \'' + this.loanApplicationRecord.Applicant__c + '\' AND DocCatgry__c = \'' + docCategory + '\' AND DocTyp__c = \'' + docCategory + '\' AND DocSubTyp__c = \'' + docCategory + '\''
    }
    getSobjectDat({ params: paramForIsLatest })
      .then((result) => {
        console.log('islatestdata 13899999', this.DocumentDetaiId);
        if (result.parentRecords) {
          listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
        }
        let oldRecords = []
        oldRecords = listOfAllParent.filter(record => record.Id !== this.DocumentDetaiId);
        //console.log('oldRecords>>>>>'+JSON.stringify(oldRecords))

        let isLatestFalseRecs = [];
        if (oldRecords && oldRecords.length > 0) {
          isLatestFalseRecs = oldRecords.map(record => {
            return { ...record, IsLatest__c: false };
          });
        }
        let obj = {
          Id: this.DocumentDetaiId,
          NDCDataEntry__c: 'Completed',
          AppvdRmrks__c: isLatestFalseRecs && isLatestFalseRecs.length > 0 ? isLatestFalseRecs[0].AppvdRmrks__c : ''
        }
        isLatestFalseRecs.push(obj);
        console.log('isLatestFalseRecs>>>>>' + JSON.stringify(isLatestFalseRecs))
        upsertMultipleRecords({ params: isLatestFalseRecs })
          .then(result => {
            // this.updateLoanApplicationDetails();
            console.log('result ' + JSON.stringify(result));
          }).catch(error => {
            this.showSpinner = false;
            this.dispatchEvent(
              new ShowToastEvent({
                title: 'Error',
                message: 'Error in getting Latest CAM',
                variant: 'error',
                mode: 'sticky'
              })
            );
            this.dispatchEvent(new CloseActionScreenEvent());
            console.log('778' + error)
          })

      })
      .catch((error) => {
        this.showSpinner = false;
        console.log(" createDocumentDetailRecord error===", error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: 'Error while create a Document',
            variant: 'error',
            mode: 'sticky'
          })
        );
        this.dispatchEvent(new CloseActionScreenEvent());
        console.log('Error In getting Document Details  ', error);
        //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
      });
  }

  DocumentDetaiIdForDM;
  handleGenerateDocumentsForDM() {
    // this.showCAMReports = false;
    this.showSpinner = true;
    this.showDocList = false;
    console.log('applicant', this.loanApplicationRecord.Applicant__c);
    console.log('loanId', this.loanApplicationRecord.Id);
    createDocumentDetail({ applicantId: this.loanApplicationRecord.Applicant__c, loanAppId: this.loanApplicationRecord.Id, docCategory: 'Disbursement Memo', docType: 'Disbursement Memo', docSubType: 'Disbursement Memo', availableInFile: false })
      .then((result) => {
        console.log('createDocumentDetailRecord result ', result);
        this.DocumentDetaiIdForDM = result;
        console.log('createDocumentDetailRecord DocumentDetaiId ', this.DocumentDetaiIdForDM);
        let pageUrl = this.CustomLabel.disbursementMemo + this.loanApplicationRecord.Id;
        // window.location.open(pageUrl);
        console.log('pageurl', pageUrl);
        const pdfData = {
          pageUrl: pageUrl,
          docDetailId: this.DocumentDetaiIdForDM,
          fileName: 'Disbursement Memo.pdf'
        }
        this.generateDocumentForDM(pdfData);

      })
      .catch((err) => {
        this.showToast("Error", err, "error", "sticky");
        console.log(" createDocumentDetailRecord error===", err);
      });
  }
  //ApprovalTray_CreateDoc_ErrorMessage

  generateDocumentForDM(pdfData) {
    generateDocument({ wrapObj: pdfData })
      .then((result) => {
        this.showSpinner = false;
        if (result == 'success') {
          this.forLatestDocDetailRecForDM();
        } else {
          console.log('doc Result', result);
        }
      })
      .catch((err) => {
        this.showToast("Error", err, "error", "sticky");
        console.log(" createDocumentDetailRecord error===", err);
      });
  }
  forLatestDocDetailRecForDM() {
    let docCat = 'Disbursement Memo';
    // console.log('document details in forLatestDocDetailRec ###1456', docTyp, docCat, docSubTyp, docId);
    let listOfAllParent = [];
    let paramForIsLatest = {
      ParentObjectName: 'DocDtl__c',
      parentObjFields: ['Id', 'Appl__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c', 'AppvdRmrks__c'],
      queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this.loanApplicationRecord.Id + '\' AND Appl__c = \'' + this.loanApplicationRecord.Applicant__c + '\' AND DocCatgry__c = \'' + docCat + '\' AND DocTyp__c = \'' + docCat + '\' AND DocSubTyp__c = \'' + docCat + '\''
    }
    getSobjectDat({ params: paramForIsLatest })
      .then((result) => {
        console.log('islatestdata 13899999', this.DocumentDetaiIdForDM);
        if (result.parentRecords) {
          listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
          let oldRecords = []
          oldRecords = listOfAllParent.filter(record => record.Id !== this.DocumentDetaiIdForDM);
          //console.log('oldRecords>>>>>'+JSON.stringify(oldRecords))
          if (oldRecords && oldRecords.length > 0) {
            let isLatestFalseRecs = []
            isLatestFalseRecs = oldRecords.map(record => {
              return { ...record, IsLatest__c: false };
            });
            let obj = {
              Id: this.DocumentDetaiIdForDM,
              AppvdRmrks__c: isLatestFalseRecs && isLatestFalseRecs.length > 0 ? isLatestFalseRecs[0].AppvdRmrks__c : ''
            }
            isLatestFalseRecs.push(obj);
            console.log('isLatestFalseRecs>>>>>' + JSON.stringify(isLatestFalseRecs))
            upsertSObjectRecord({ params: isLatestFalseRecs })
              .then(result => {
                this.refreshDocTable();
                console.log('result ' + JSON.stringify(result));
              }).catch(error => {
                this.showSpinner = false;
                this.dispatchEvent(
                  new ShowToastEvent({
                    title: 'Error',
                    message: 'Error while getting Latest DM Records',
                    variant: 'error',
                    mode: 'sticky'
                  })
                );
                // this.dispatchEvent(new CloseActionScreenEvent());
                console.log('778' + error)
              })
          }
        }
      })
      .catch((error) => {
        this.showSpinner = false;
        console.log(" Getting doc dtl data error===", error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: 'Error while getting Latest DM Records',
            variant: 'error',
            mode: 'sticky'
          })
        );
        // this.dispatchEvent(new CloseActionScreenEvent());
        console.log('Error In getting Document Details  ', error);
        //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
      });
  }
  appIds=[];
  appData;
  intRecords=[];
  getApplicantIds() {
    let paramsLoanApp = {
        ParentObjectName: 'Applicant__c',
        parentObjFields: ['Id','Constitution__c', 'Name', 'IntegrationStatus__c', 'UCID__c'],
        queryCriteria: ' where LoanAppln__c = \'' + this.recordId + '\''
    }
    console.log('test####');
    getSobjectDat({ params: paramsLoanApp })
        .then((result) => {
            this.appData = result;
            console.log('result is', JSON.stringify(result));
            if (result.parentRecords && result.parentRecords.length > 0) {
                result.parentRecords.forEach(item => {
                    this.appIds.push(item.Id);
                    
                })

                this.createIntForLitigation(this.appIds);
                console.log('this.appRecordsData after', JSON.stringify(this.appIds));
            }
            if (result.error) {
                console.error('appl result getting error=', result.error);
            }
        })
    }
    createIntForLitigation() {
      this.appIds.forEach(item => {
          let fieldsWo = {};
          fieldsWo['sobjectType'] = 'IntgMsg__c';
          fieldsWo['Name'] =  item.Constitution__c == 'INDIVIDUAL' || item.Constitution__c == 'PROPERITORSHIP' ? 'Crime Add Report API - Individual': 'Crime Add Report API - Company'; //serviceName;//'KYC OCR'
          fieldsWo['BU__c'] = 'HL / STL';
          fieldsWo['IsActive__c'] = true;
          fieldsWo['Svc__c'] = item.Constitution__c == 'INDIVIDUAL' || item.Constitution__c == 'PROPERITORSHIP' ? 'Crime Add Report API - Individual': 'Crime Add Report API - Company';
          fieldsWo['RefObj__c'] = 'Applicant__c';
          fieldsWo['RefId__c'] = item;
          fieldsWo['Status__c'] = 'New';
          fieldsWo['ApiVendor__c'] = 'CrimeCheck';
          fieldsWo['TriggerType__c'] = 'System';
          this.intRecords.push(fieldsWo);
      })
      this.upsertIntRecord(this.intRecords);
  }
  upsertIntRecord(intRecords) {
        console.log('int msgs records ', JSON.stringify(intRecords));
        upsertSObjectRecord({ params: intRecords })
            .then((result) => {
                console.log('###upsertMultipleRecord###'+result);
                this.fireCustomEvent("Hunter:", "success", "Litigation Integration Initiated Successfully!");//LAK-3368
              })
            .catch((error) => {
                console.log('Error In creating Record', error);
            });
    }
}