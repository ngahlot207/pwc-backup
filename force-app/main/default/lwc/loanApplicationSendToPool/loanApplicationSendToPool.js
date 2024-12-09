import { LightningElement,api,track,wire } from 'lwc';
import Stage from '@salesforce/schema/LoanAppl__c.Stage__c';
import subStage from '@salesforce/schema/LoanAppl__c.SubStage__c';
import OwnerId from '@salesforce/schema/LoanAppl__c.OwnerId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds'
import getSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords'
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
// Custom labels
import SendToCpaPool_ErrorMessage from '@salesforce/label/c.SendToCpaPool_ErrorMessage';
import SendToCpaPool_SuccessMessage from '@salesforce/label/c.SendToCpaPool_SuccessMessage';

export default class LoanApplicationSendToPool extends NavigationMixin(LightningElement) {
  customLabel = {
    SendToCpaPool_ErrorMessage,
    SendToCpaPool_SuccessMessage

  }
CPAPoolId;
UWPoolId;
opsPoolId;
loanApplicationNumber;
@api recordId;
@track showSpinner = true;
@track buttonDisplay = true;

connectedCallback(){
setTimeout(() => {
  this.showSpinner = false;
}, 2000);
}

closeAction(){
this.buttonDisplay = false;
this.queueRecord();
}

noBtn(){
this.dispatchEvent(new CloseActionScreenEvent());
}

queueRecord(){
  let parameter1 = {
      ParentObjectName: 'Group ',
      ChildObjectRelName: null,
      parentObjFields: ['Id','Name'],
      childObjFields: [],
      queryCriteria: ' where Name = \'' + 'CPA Pool' + '\''
    }

    let parameter2 = {
      ParentObjectName: 'Group ',
      ChildObjectRelName: null,
      parentObjFields: ['Id','Name'],
      childObjFields: [],
      queryCriteria: ' where Name = \'' + 'UW Pool' + '\''
    }

    let parameter3 = {
      ParentObjectName: 'Group ',
      ChildObjectRelName: null,
      parentObjFields: ['Id','Name'],
      childObjFields: [],
      queryCriteria: ' where Name = \'' + 'Ops Pool' + '\''
    }

    getSobjDataWIthRelatedChilds({ params: parameter1 })
    .then(result => {
      if(result.parentRecord.Id != undefined){
          console.log('Queue Record 1 :'+JSON.stringify(result));
          this.CPAPoolId = result.parentRecord.Id
      }
    })

    getSobjDataWIthRelatedChilds({ params: parameter2 })
    .then(result => {
      if(result.parentRecord.Id != undefined){
          console.log('Queue Record 2  :'+JSON.stringify(result));
          this.UWPoolId = result.parentRecord.Id;
      }
    })

    getSobjDataWIthRelatedChilds({ params: parameter3 })
    .then(result => {
      if(result.parentRecord.Id != undefined){
          console.log('Queue Record 2  :'+JSON.stringify(result));
          this.opsPoolId = result.parentRecord.Id;
      }
      this.initialize();
    })
    .catch(error => {
      console.log(error);
    });
}


initialize(){
  let parameter = {
    ParentObjectName: 'LoanAppl__c',
    ChildObjectRelName: null,
    parentObjFields: ['Id','Stage__c','SubStage__c','Name'],
    childObjFields: [],
    queryCriteria: ' where id = \'' + this.recordId + '\''
  }
  getSobjDataWIthRelatedChilds({ params: parameter })
  .then(result => {
    if(result.parentRecord.Id != undefined){
      console.log('Result of loan application :'+JSON.stringify(result));
      this.loanApplicationNumber = result.parentRecord.Name;
      this.update(result.parentRecord);
    }
  })
  .catch(error => {
    console.log(error);
  });
}

update(data){
  console.log('date in update method'+JSON.stringify(data));
  console.log(' this.UWPoolId:', this.UWPoolId);
  console.log(' this.CPAPoolId:', this.CPAPoolId);
  
  let upsertObjectParams = {
    parentRecord : {},
    ChildRecords : [],
    ParentFieldNameToUpdate : ''
  };

  upsertObjectParams.parentRecord.sobjectType = 'LoanAppl__c';
  upsertObjectParams.parentRecord.Id = this.recordId;

  if(data.Stage__c === 'QDE' && data.SubStage__c === 'Additional Data Entry'){
    console.log('1 if');
    upsertObjectParams.parentRecord[Stage.fieldApiName] = 'QDE';
    upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Additional Data Entry Pool';
    upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.CPAPoolId;
    console.log('upsertObjectParams:',upsertObjectParams);
    this.callApexMethod(upsertObjectParams);

  }
    else if(data.Stage__c === 'DDE' && data.SubStage__c === 'CPA Data Entry' ){
    upsertObjectParams.parentRecord[Stage.fieldApiName] = 'DDE';
    upsertObjectParams.parentRecord[subStage.fieldApiName] = 'CPA Pool';
    upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.CPAPoolId;
    this.callApexMethod(upsertObjectParams);
  
  } else if(data.Stage__c === 'DDE' && data.SubStage__c === 'Query' ){
    upsertObjectParams.parentRecord[Stage.fieldApiName] = 'DDE';
    upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Query Pool';
    upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.CPAPoolId;
    this.callApexMethod(upsertObjectParams);
  
  } else if(data.Stage__c === 'UnderWriting' && data.SubStage__c === 'Credit Appraisal'){
    upsertObjectParams.parentRecord[Stage.fieldApiName] = 'UnderWriting';
    upsertObjectParams.parentRecord[subStage.fieldApiName] = 'UW Pool';
    upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.UWPoolId;
    this.callApexMethod(upsertObjectParams);
  }

    else if(data.Stage__c === 'Soft Sanction' && data.SubStage__c === 'Additional Data Entry'){
    upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Soft Sanction';
    upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Additional Data Entry Pool';
    upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.CPAPoolId;
    this.callApexMethod(upsertObjectParams);
  }
    else if(data.Stage__c === 'Soft Sanction' && data.SubStage__c === 'UW Approval'){
    upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Soft Sanction';
    upsertObjectParams.parentRecord[subStage.fieldApiName] = 'UW Approval Pool';
    upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.UWPoolId;
    this.callApexMethod(upsertObjectParams);
  }

    else if(data.Stage__c === 'Post Sanction' && data.SubStage__c === 'Data Entry' ){
    upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Post Sanction';
    upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Data Entry Pool';
    upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.CPAPoolId;
    this.callApexMethod(upsertObjectParams);
  }
    else if(data.Stage__c === 'Post Sanction' && data.SubStage__c === 'UW Approval' ){
    upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Post Sanction';
    upsertObjectParams.parentRecord[subStage.fieldApiName] = 'UW Approval Pool';
    upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.UWPoolId;
    this.callApexMethod(upsertObjectParams);
  }

    else if(data.Stage__c === 'Post Sanction' && data.SubStage__c === 'Ops Query'){
    upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Post Sanction';
    upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Ops Query Pool';
    upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.opsPoolId;
    this.callApexMethod(upsertObjectParams);
  }

    else if(data.Stage__c === 'Disbursement Initiation' && data.SubStage__c === 'DI Check'){
    upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Disbursement Initiation';
    upsertObjectParams.parentRecord[subStage.fieldApiName] = 'DI Pool';
    upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.opsPoolId;
    this.callApexMethod(upsertObjectParams);
  }


    else if(data.Stage__c === 'Disbursed' && data.SubStage__c === 'Additional Processing'){
    console.log('disbursed');
    upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Disbursed';
    upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Additional processing Pool';
    upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.opsPoolId;
    this.callApexMethod(upsertObjectParams);
  }

    else if(data.Stage__c === 'Disbursed' && data.SubStage__c === 'UW Approval'){
    upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Disbursed';
    upsertObjectParams.parentRecord[subStage.fieldApiName] = 'UW Approval Pool';
    upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.UWPoolId;
    this.callApexMethod(upsertObjectParams);
  }

    else if(data.Stage__c === 'Disbursed' && data.SubStage__c === 'DI Check'){
    upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Disbursed';
    upsertObjectParams.parentRecord[subStage.fieldApiName] = 'DI Pool';
    upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.opsPoolId;
    this.callApexMethod(upsertObjectParams);
  }
  else{
    console.log('else');
    history.back(-1);
    const evt = new ShowToastEvent({
      title: 'Error',
      message: this.customLabel.SendToCpaPool_ErrorMessage,
      variant: 'error',
      mode: 'sticky'
    });
    this.dispatchEvent(evt);
  }
}

callApexMethod(params){
  upsertSobjDataWIthRelatedChilds({upsertData:params})
  .then((result) => {
    console.log('success');
    console.log('result:',JSON.stringify(result));
    console.log('result:',result.parentRecord.Id);
    console.log('this.loanApplicationNumber:',this.loanApplicationNumber);

      const event = new ShowToastEvent({
      title: 'Success!',
      messageData: [
        this.customLabel.SendToCpaPool_SuccessMessage,
        {
            url: '/'+result.parentRecord.Id,
            label: this.loanApplicationNumber,
        },
    ],
      message: '{1} {0}!',
      variant: 'success',
      mode: "sticky"
  });
  this.dispatchEvent(event);
  this[NavigationMixin.Navigate]({
    type: 'standard__recordPage',
    attributes: {
        recordId: this.recordId,
        actionName: 'view'
    },
    });
    //eval("$A.get('e.force:refreshView').fire();");
    setTimeout(() => {
      location.reload();
    }, 3000);
})

  .catch(error => {
    console.log('error while updating record:' +JSON.stringify(error));
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
          recordId: this.recordId,
          actionName: 'view'
      },
  });

    const evt = new ShowToastEvent({
      title: 'Error',
      message: this.customLabel.SendToCpaPool_ErrorMessage,
      variant: 'error',
      mode: 'sticky'
    });
    this.dispatchEvent(evt);
  });
}

}