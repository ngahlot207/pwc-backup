import { LightningElement,api,track,wire } from 'lwc';
import CURRENTUSERID from '@salesforce/user/Id';
import Stage from '@salesforce/schema/LoanAppl__c.Stage__c';
import subStage from '@salesforce/schema/LoanAppl__c.SubStage__c';
import OwnerId from '@salesforce/schema/LoanAppl__c.OwnerId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds'
import getSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords'
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { CloseActionScreenEvent } from 'lightning/actions';

import { CPAClaimRoles } from 'c/globalConstant';

// Custom labels
import LoanAppClaim_Rights_ErrorMessage from '@salesforce/label/c.LoanAppClaim_Rights_ErrorMessage';
import LoanAppClaim_Claim_SuccessMessage from '@salesforce/label/c.LoanAppClaim_Claim_SuccessMessage';

export default class LoanApplicationClaim extends NavigationMixin(LightningElement) {
 customeLabel = {
  LoanAppClaim_Rights_ErrorMessage,
  LoanAppClaim_Claim_SuccessMessage
  
 }
currentPageReference;
loanApplicationNumber;
recordPageFlag;
listViewFlag;
@track userDetail = [];
@track confirmationMessage = false;
@track showSpinner = false;
@track buttonDisplay = true;
@track errorUserName;

@track _recordId;
@api get recordId() {
  return this._recordId;
}
set recordId(value) {
  this._recordId = value;
  this.setAttribute("recordId", value);
  console.log('this._recordId:::::38',this.recordId);
  this.getCurrentUserole();
}

get confirMsg(){
  return this.confirmationMessage || this.userRole ==='VCPA'
}

@wire(CurrentPageReference)
setCurrentPageReference(currentPageReference) {
  this.currentPageReference = currentPageReference;
  if (this.connected) {
  } else {
    console.log('this._recordId:::::47',this.currentPageReference.state.c__recordId);
    if(this.currentPageReference.state.c__recordId !== undefined){
      this._recordId = this.currentPageReference.state.c__recordId;
      console.log('this._recordId:::::47',this._recordId);
      this.listViewFlag = 'ListViewFlag';
      this.confirmationMessage = true;
      //this.getCurrentUserole();
    }else if(this.currentPageReference.state.recordId !== undefined){
      this._recordId = this.currentPageReference.state.recordId;
      console.log(' this.recordId:', this._recordId);
      this.recordPageFlag = 'RecordPageFlag';
      this.confirmationMessage = true;
   //   this.getCurrentUserole();
    }
  }
}


closeAction(){
  this.buttonDisplay = false;
  this.initialize();
}

noBtn(){
  if( this.listViewFlag === 'ListViewFlag' && this.listViewFlag !=undefined){
    console.log('inside if recordflag');
    history.back(-1);
  }else{
    console.log('inside else recordflag');
    this.dispatchEvent(new CloseActionScreenEvent());
     //dispatching the custom event
     const selectedEvent = new CustomEvent("select", {
      detail: false
    });
    this.dispatchEvent(selectedEvent);
  }
}
@track userRole;
@track portalAccId;
getCurrentUserole(){
  let parameter1 = {
    ParentObjectName: 'TeamHierarchy__c',
    ChildObjectRelName: null,
    parentObjFields: ['Id','Employee__c','EmpRole__c','Employee__r.AccountId'],
    childObjFields: [],
    queryCriteria: ' where Employee__c  = \'' + CURRENTUSERID + '\' LIMIT 1'
  }
  getSobjDataWIthRelatedChilds({ params: parameter1 })
  .then(result => {
    console.log('result of team hir::',JSON.stringify(result));
    if(result.parentRecord.Id != undefined){
      console.log('User Detail:'+JSON.stringify(result));
      this.userDetail = result;
      this.userRole=this.userDetail.parentRecord.EmpRole__c;
      this.portalAccId=this.userDetail.parentRecord.Employee__r.AccountId;
      console.log('this.userDetail:'+this.userDetail.parentRecord.EmpRole__c, this.userRole)
     
    }
  })
  .catch(error => {
    console.log('role hierarchay error:',JSON.stringify(error));
  });
}



initialize(){
  let parameter = {
    ParentObjectName: 'LoanAppl__c',
    ChildObjectRelName: null,
    parentObjFields: ['Id','Stage__c','SubStage__c','Name','OwnerId'],
    childObjFields: [],
    queryCriteria: ' where id = \'' + this._recordId + '\''
  }
  getSobjDataWIthRelatedChilds({ params: parameter })
  .then(result => {
    if(result.parentRecord.Id != undefined){
      console.log('Result:'+JSON.stringify(result));
      this.loanApplicationNumber = result.parentRecord.Name;
      this.update(result.parentRecord);
    }
  })
    
  .catch(error => {
    console.log(error);
  });
}


// Update Record
  update(data){
    console.log('date in update method'+JSON.stringify(data));
    console.log('this.listViewFlag:'+this.listViewFlag);
    console.log('this.recordPage:'+this.recordPageFlag);
    console.log('this.userDetail1:'+this.userRole)
   
    //console.log('uw Role:',this.userRole );
    let upsertObjectParams = {
      parentRecord : {},
      ChildRecords : [],
      ParentFieldNameToUpdate : ''
    };

    upsertObjectParams.parentRecord.sobjectType = 'LoanAppl__c';
    upsertObjectParams.parentRecord.Id = this._recordId;

    if(data.Stage__c === 'QDE' && data.SubStage__c === 'Additional Data Entry Pool'){
      console.log('1 if');
      if(CPAClaimRoles.includes(this.userRole)){  //LAK-9244
        upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Additional Data Entry';
      }else if(this.userRole === 'VCPA'){
        upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Additional Data Entry Vendor Processing';
        upsertObjectParams.parentRecord.Account__c = this.portalAccId;
        upsertObjectParams.parentRecord.VendorCPA__c = CURRENTUSERID;
       }
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'QDE';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = CURRENTUSERID;
      this.callApexMethod(upsertObjectParams);

    }
    else if(data.Stage__c === 'QDE' && data.SubStage__c === 'Additional Data Entry Internal Pool' && CPAClaimRoles.includes(this.userRole)){
      console.log('2 if');
      upsertObjectParams.parentRecord.sobjectType = 'LoanAppl__c';
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'QDE';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Additional Data Entry';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = CURRENTUSERID;
      this.callApexMethod(upsertObjectParams);
      
    }
    else if(data.Stage__c === 'QDE' && data.SubStage__c === 'Additional Data Entry External Pool' && this.userRole === 'VCPA'){
      console.log('3 if');
      upsertObjectParams.parentRecord.sobjectType = 'LoanAppl__c';
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'QDE';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Additional Data Entry Vendor Processing';
      upsertObjectParams.parentRecord.Account__c = this.portalAccId;
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = CURRENTUSERID;
      upsertObjectParams.parentRecord.VendorCPA__c = CURRENTUSERID;
      this.callApexMethod(upsertObjectParams);
      
    }
    
    else if(data.Stage__c === 'QDE' && data.SubStage__c === 'Pre login Query Pool' && CPAClaimRoles.includes(this.userRole)){  //LAK-9244
      console.log('4 if');
      upsertObjectParams.parentRecord.sobjectType = 'LoanAppl__c';
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'QDE';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Additional Data Entry';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = CURRENTUSERID;
      this.callApexMethod(upsertObjectParams);
      
    }else if(data.Stage__c === 'DDE' && data.SubStage__c === 'CPA Pool' && CPAClaimRoles.includes(this.userRole)){  //LAK-9244
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'DDE';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'CPA Data Entry';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = CURRENTUSERID;
      this.callApexMethod(upsertObjectParams);
    }else if(data.Stage__c === 'DDE' && data.SubStage__c === 'Query Pool' && CPAClaimRoles.includes(this.userRole)){  //LAK-9244
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'DDE';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Query';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = CURRENTUSERID;
      this.callApexMethod(upsertObjectParams);
    }else if(data.Stage__c === 'UnderWriting' && data.SubStage__c === 'UW Pool' && (this.userRole === 'UW' || this.userRole === 'ACM' || this.userRole === 'RCM' || this.userRole === 'ZCM' || this.userRole === 'CH' ||  this.userRole === 'NCM')){
      console.log('Inside Uw Pool');
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'UnderWriting';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Credit Appraisal';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = CURRENTUSERID;
      this.callApexMethod(upsertObjectParams);
    }
    //Soft Sanction	
    else if(data.Stage__c === 'Soft Sanction' && data.SubStage__c === 'Additional Data Entry Pool' && CPAClaimRoles.includes(this.userRole)){  //LAK-9244
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Soft Sanction';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Additional Data Entry';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = CURRENTUSERID;
      this.callApexMethod(upsertObjectParams);
    }
    else if(data.Stage__c === 'Soft Sanction' && data.SubStage__c === 'UW Approval Pool' && (this.userRole === 'UW' || this.userRole === 'ACM' || this.userRole === 'RCM' || this.userRole === 'ZCM' || this.userRole === 'CH' ||  this.userRole === 'NCM')){
      console.log('Inside Uw Pool');
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Soft Sanction';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'UW Approval';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = CURRENTUSERID;
      this.callApexMethod(upsertObjectParams);
    }

    else if(data.Stage__c === 'Post Sanction' && data.SubStage__c === 'Data Entry Pool' && CPAClaimRoles.includes(this.userRole)){  //LAK-9244
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Post Sanction';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Data Entry';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = CURRENTUSERID;
      this.callApexMethod(upsertObjectParams);
    }

    else if(data.Stage__c === 'Post Sanction' && data.SubStage__c === 'UW Approval Pool' && (this.userRole === 'UW' || this.userRole === 'ACM' || this.userRole === 'RCM' || this.userRole === 'ZCM' || this.userRole === 'CH' ||  this.userRole === 'NCM')){
      console.log('Inside Uw Pool');
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Post Sanction';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'UW Approval';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = CURRENTUSERID;
      this.callApexMethod(upsertObjectParams);
    }

    else if(data.Stage__c === 'Post Sanction' && data.SubStage__c === 'Ops Query Pool' && CPAClaimRoles.includes(this.userRole)){  //LAK-9244
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Post Sanction';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Ops Query';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = CURRENTUSERID;
      this.callApexMethod(upsertObjectParams);
    }

    else if(data.Stage__c === 'Disbursement Initiation' && data.SubStage__c === 'DI Pool' && (this.userRole === 'BOM' || this.userRole === 'AOM' || this.userRole === 'ZOM' || this.userRole === 'NOM' || this.userRole === 'ROM')){
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Disbursement Initiation';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'DI Check';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = CURRENTUSERID;
      this.callApexMethod(upsertObjectParams);
    }


    else if(data.Stage__c === 'Disbursed' && data.SubStage__c === 'Additional Processing Pool' && CPAClaimRoles.includes(this.userRole)){  //LAK-9244
      console.log('disbursed');
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Disbursed';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Additional processing';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = CURRENTUSERID;
      this.callApexMethod(upsertObjectParams);
    }

    else if(data.Stage__c === 'Disbursed' && data.SubStage__c === 'UW Approval Pool' && (this.userRole === 'UW' || this.userRole === 'ACM' || this.userRole === 'RCM' || this.userRole === 'ZCM' || this.userRole === 'CH' ||  this.userRole === 'NCM')){
      console.log('Inside Uw Pool');
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Disbursed';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'UW Approval';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = CURRENTUSERID;
      this.callApexMethod(upsertObjectParams);
    }

    else if(data.Stage__c === 'Disbursed' && data.SubStage__c === 'DI Pool'  && (this.userRole === 'BOM' || this.userRole === 'AOM' || this.userRole === 'ZOM' || this.userRole === 'NOM' || this.userRole === 'ROM')){
      upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Disbursed';
      upsertObjectParams.parentRecord[subStage.fieldApiName] = 'DI Check';
      upsertObjectParams.parentRecord[OwnerId.fieldApiName] = CURRENTUSERID;
      this.callApexMethod(upsertObjectParams);
    }else if(!data.OwnerId.startsWith('00G')){
      history.back(-1);

      if(this.userRole === 'BOM' || this.userRole === 'AOM' || this.userRole === 'ZOM' || this.userRole === 'NOM' || this.userRole === 'ROM'){
        this.errorUserName = 'OPS';
      }

      if(this.userRole === 'UW' || this.userRole === 'ACM' || this.userRole === 'RCM' || this.userRole === 'ZCM' || this.userRole === 'CH' ||  this.userRole === 'NCM'){
        this.errorUserName = 'UW';
      }

      if(this.userRole === 'CPA'){
        this.errorUserName = 'CPA';
      }    
       console.log(' this.errorUserName:'+this.errorUserName);

      const evt = new ShowToastEvent({
        title: 'Error',
        message: 'The loan application is already claimed by another' +' '+  this.errorUserName  + ' '+'User',
        variant: 'error',
        mode: 'sticky'
    });
    this.dispatchEvent(evt);

    }
    else{
      console.log('else');
      history.back(-1);
      const evt = new ShowToastEvent({
        title: 'Error',
        message: this.customeLabel.LoanAppClaim_Rights_ErrorMessage,
        variant: 'error',
        mode: 'sticky'
      });
      this.dispatchEvent(evt);
    }
  }

  callApexMethod(params){
    upsertSobjDataWIthRelatedChilds({upsertData:params})
    .then((result) => {
      if( this.listViewFlag === 'ListViewFlag' && this.listViewFlag !==undefined){
        history.back(-1);
      }else if( this.recordPageFlag === 'RecordPageFlag' && this.recordPageFlag !==undefined){
              this[NavigationMixin.Navigate]({
              type: 'standard__recordPage',
              attributes: {
              recordId: this._recordId,
              actionName: 'view'
          },
          });
          
          setTimeout(() => {
            location.reload();
          }, 3000);
      }else if(this.userRole=== 'VCPA'){
        this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
          recordId: this._recordId,
          actionName: 'view'
      },
      });
      setTimeout(() => {
        location.reload();
      }, 3000)
      }
      console.log('success');
      console.log('result:',JSON.stringify(result));
      console.log('result:',result.parentRecord.Id);
      const event = new ShowToastEvent({
        title: 'Success!',
        messageData: [
          this.customeLabel.LoanAppClaim_Claim_SuccessMessage,
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
    })
    .catch(error => {
      history.back(-1);
      console.log('error:' +JSON.stringify(error));
      const evt = new ShowToastEvent({
        title: 'Error',
        message: error,
        variant: 'error',
        mode: 'sticky'
      });
      this.dispatchEvent(evt);
    });
  }
}