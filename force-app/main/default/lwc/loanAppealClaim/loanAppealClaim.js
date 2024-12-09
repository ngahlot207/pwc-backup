import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import getSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords'
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds'
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';

import CURRENTUSERID from '@salesforce/user/Id';
export default class LoanAppealClaim extends NavigationMixin(LightningElement) {

  @track loanAppId;
  @track userRole;
  @track _recordId;
  @track confirmationMessage;
  @track showSpinner;
  @api get recordId() {
    return this._recordId;
  }
  set recordId(value) {
    this._recordId = value;
    this.setAttribute("recordId", value);
  }

  @wire(CurrentPageReference)
  setCurrentPageReference(currentPageReference) {
    this.currentPageReference = currentPageReference;
    if (this.connected) {
      //
    } else {
      if (this.currentPageReference.state.c__recordId !== undefined) {
        this._recordId = this.currentPageReference.state.c__recordId;
        this.listViewFlag = 'ListViewFlag';
        this.confirmationMessage = true;
        //this.getCurrentUserole();
      } else if (this.currentPageReference.state.recordId !== undefined) {
        this._recordId = this.currentPageReference.state.recordId;
        console.log(' this.recordId:', this._recordId);
        this.recordPageFlag = 'RecordPageFlag';
        this.confirmationMessage = true;
        //   this.getCurrentUserole();
      }
    }
  }


  closeAction() {
    this.buttonDisplay = false;
    this.getCurrentUserole();
  }

  noBtn() {
    if (this.listViewFlag === 'ListViewFlag' && this.listViewFlag != undefined) {
      console.log('inside if recordflag');
      history.back(-1);
    } else {
      console.log('inside else recordflag');
      this.dispatchEvent(new CloseActionScreenEvent());
    }
  }


  getCurrentUserole() {
    let parameter1 = {
      ParentObjectName: 'TeamHierarchy__c',
      ChildObjectRelName: null,
      parentObjFields: ['Id', 'Employee__c', 'EmpRole__c'],
      childObjFields: [],
      queryCriteria: ' where Employee__c  = \'' + CURRENTUSERID + '\' LIMIT 1'
    }

    getSobjDataWIthRelatedChilds({ params: parameter1 })
      .then(result => {
        console.log('result of team hir::', JSON.stringify(result));
        if (result.parentRecord.Id !== undefined) {
          console.log('User Detail:' + JSON.stringify(result));
          this.userDetail = result;
          this.userRole = result.parentRecord.EmpRole__c;
          console.log('this.userDetail:' + this.userDetail.parentRecord.EmpRole__c)
          this.initialize();
        }
      })
      .catch(error => {
        console.log('role hierarchay error:', JSON.stringify(error));
      });
  }


  initialize() {
    let parameter = {
      ParentObjectName: 'LoanAppeal__c',
      ChildObjectRelName: null,
      parentObjFields: ['Id', 'Name', 'OwnerId', 'Owner.Name', 'RecordType.Name', 'Status__c', 'LoanAppl__c'],
      childObjFields: [],
      queryCriteria: ' where id = \'' + this._recordId + '\''
    }
    getSobjDataWIthRelatedChilds({ params: parameter })
      .then(result => {
        if (result.parentRecord.Id !== undefined) {
          console.log('Result:' + JSON.stringify(result));
          this.loanApplicationNumber = result.parentRecord.Name;
          this.loanAppId = result.parentRecord.LoanAppl__c;
          this.update(result.parentRecord);
          if (result.parentRecord.RecordType.Name === 'Loan Term Negotiation') {
            // this.updateLoanAppl(this.loanAppId);

          }
        }
      })

      .catch(error => {
        console.log(error);
      });
  }


  // Update Record
  @track errorUserName;
  update(data) {
    console.log('date in update method' + JSON.stringify(data));
    console.log('this.listViewFlag:' + this.listViewFlag);
    console.log('this.recordPage:' + this.recordPageFlag);
    console.log('this.userDetail1:' + this.userDetail.parentRecord.EmpRole__c)
    this.errorUserName = data.Owner.Name;
    //console.log('uw Role:',this.userDetail.parentRecord.EmpRole__c );
    let upsertObjectParams = {
      parentRecord: {},
      ChildRecords: [],
      ParentFieldNameToUpdate: ''
    };

    upsertObjectParams.parentRecord.sobjectType = 'LoanAppeal__c';
    upsertObjectParams.parentRecord.Id = this._recordId;
    upsertObjectParams.parentRecord.LoanAppl__c = this.loanAppId;
    upsertObjectParams.parentRecord.Status__c = 'In Progress';
    if (this.userRole === 'UW') {
      if (data.Status__c == 'Approve' || data.Status__c == 'Reject') {
        const evt = new ShowToastEvent({
          title: 'Error',
          message: 'Loan Appeal already claimed by UW',
          variant: 'error',
          mode: 'sticky'
        });
        this.dispatchEvent(evt);
      } else {
        upsertObjectParams.parentRecord.OwnerId = CURRENTUSERID;
        this.callApexMethod(upsertObjectParams);
      }

    }
    else {
      console.log(' this.errorUserName:' + this.errorUserName);

      const evt = new ShowToastEvent({
        title: 'Error',
        message: 'The loan application is already claimed by another' + ' ' + this.errorUserName + ' ' + 'User',
        variant: 'error',
        mode: 'sticky'
      });
      this.dispatchEvent(evt);
    }


  }

  callApexMethod(params) {
    upsertSobjDataWIthRelatedChilds({ upsertData: params })
      .then((result) => {
        if (result.parentRecord.LoanAppl__c !== undefined) {
          this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
              recordId: result.parentRecord.LoanAppl__c,
              objectApiName: 'LoanAppl__c',
              actionName: 'view'
            }
          });


          const event = new ShowToastEvent({
            title: 'Success!',
            messageData: [
              'LOAN APPEAL CLAIMED SUCCESSFULLY',
              {
                url: '/' + result.parentRecord.Id,
                label: this.loanApplicationNumber,
              },
            ],
            message: '{1} {0}!',
            variant: 'success',
            mode: "sticky"

          });
          this.dispatchEvent(event);

        }

      })
      .catch(error => {
        history.back(-1);
        console.log('error:' + JSON.stringify(error));
        const evt = new ShowToastEvent({
          title: 'Error',
          message: error,
          variant: 'error',
          mode: 'sticky'
        });
        this.dispatchEvent(evt);
      });

  }

  updateLoanAppl(loanAppId) {

    var loanAppl = {};
    loanAppl.sobjectType = 'LoanAppl__c';
    loanAppl.Id = loanAppId;
    loanAppl.Stage__c = 'UnderWriting';
    loanAppl.SubStage__c = 'Credit Appraisal';
    loanAppl.Status__c = 'Relook';
    loanAppl.OwnerId = CURRENTUSERID;
    // 

    let tempRecs = [];
    tempRecs.push(loanAppl);

    upsertMultipleRecord({ params: tempRecs })
      .then(result => {
        console.log('result ==>>>', JSON.stringify(result));
        this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
            recordId: loanAppId,
            objectApiName: 'LoanAppl__c',
            actionName: 'view'
          }
        });
      }).catch(error => {
        console.log('error ==>>>', error);
      })



  }
}