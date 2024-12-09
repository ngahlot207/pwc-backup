import { LightningElement ,track, wire, api} from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData'; 
import Id from "@salesforce/user/Id";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';

export default class AssignVendorCpa extends LightningElement {

    @track currentUserId = Id; 
    @track userRole;
    @track showSpinnerModal=false;

 @track _recordId;

  @api get recordId() {
    return this._recordId;
}
set recordId(value) {
    this._recordId = value;
    this.setAttribute("recordId", value);
    this.handleteamHierIdChange();
    this.handleRecordIdChange(value);
}
//     @track _loanAppId;
//   @api get loanAppId() {
//     return this._loanAppId;
//   }
//   set loanAppId(value) {
//     this._loanAppId = value;
//     this.setAttribute("loanAppId", value);
//     this.handleteamHierIdChange();
//   }
  handleteamHierIdChange() {
    let tempParams = this.teamHierParam;
    tempParams.queryCriteria = ' where Employee__c = \'' + this.currentUserId + '\' ' ;
    this.teamHierParam = { ...tempParams };


}
handleRecordIdChange() {
  let paramLoanappTemp = this.paramsLoanApp;
  paramLoanappTemp.queryCriteria = ' where id = \'' + this.recordId + '\''
  this.paramsLoanApp = { ...paramLoanappTemp };
}
@track
paramsLoanApp = {
    ParentObjectName: 'LoanAppl__c',
    parentObjFields: ['id','BrchCode__c', 'SubStage__c','Account__c'],
    queryCriteria: ' where id = \'' + this.recordId + '\''
}
@track brchCode
@wire(getSobjectDatawithRelatedRecords, { params: '$paramsLoanApp' })
    handleAppKyc(result) {
        this.wiredLoanData = result;
        console.log('this.loanappid rec',this._loanAppId ,this.recordId)
        if (result.data) {
            if (result.data.parentRecord) {
                this.brchCode = result.data.parentRecord.BrchCode__c;
                console.log('this.brchCode',this.brchCode);
            }

        }
        if (result.error) {
            console.error('Loan app error=', result.error);
        }
    }

@track teamHierParam = {
  ParentObjectName: 'TeamHierarchy__c',
  ChildObjectRelName: '',
  parentObjFields: ['Id','EmpRole__c','Employee__c','Employee__r.Name','BranchCode__c','EmpBrch__r.Name','EmpBrch__r.BrchCode__c'],
  childObjFields: [],
  queryCriteria: ' where Employee__c = \'' + this.currentUserId + '\' ' 
  }
  @wire(getSobjectData,{params : '$teamHierParam'})
  teamHierHandler({data,error}){
      if(data){
          console.log('DATA IN CASE DETAILS :::: #412>>>>',data);
          if(data.parentRecords !== undefined ){
              this.userRole = data.parentRecords[0].EmpRole__c
              console.log('DATA IN CASE DETAILS :::: #415>>>>',this.userRole);
          }
                    
      }
      if(error){
          console.error('ERROR CASE DETAILS:::::::#420',error)
      }
  }

//   get disableMode(){
//     return !this.hasEditAccess;
//   }



@track userId;
@track lookUpRec;
@track lookupId;
@track BrchCode
@track portalAccId
  handleLookupFieldChange(event) { 
    if (event.detail) {
      console.log('event.detail:::::Assign to Vendor CPA:104',JSON.stringify(event.detail));
      this.lookUpRec= event.detail.record;
      this.lookupId = event.detail.id;
      if(this.lookupId!=null){
       this.portalAccId=this.lookUpRec.Employee__r.Contact.AccountId;
       this.BrchCode=this.lookUpRec.EmpBrch__r.BrchCode__c
    //   this.userId=event.detail.record.Employee__c;
      }
    } 
    console.log('lookUpRec::::::',JSON.stringify(this.lookUpRec));
    console.log('lookUpRec::::::', this.portalAccId,this.userId,this.recordId);
}


@track cpaRoles=['VCPA'];
get filterCondn(){
  let val;
   val= 'EmpRole__c IN (\''+this.cpaRoles.join('\', \'') + '\') AND BranchCode__c = \'' + this.brchCode + '\'';
   console.log('val',val);
  return val;
}


handleYES() { 

  this.showSpinnerModal = true;
  this.updateLoanAppRec();
 
}



updateLoanAppRec(){
  let isInputCorrect = this.validateForm();
            console.log("custom lookup validity if false>>>", isInputCorrect);
            if (isInputCorrect === true) {
             let loanAppArr=[]
                let obj={}
                obj.Id = this.recordId;
                // obj.Stage__c='DDE';
                obj.SubStage__c='Vendor Processing Pool';
                obj.Account__c=this.portalAccId;
                loanAppArr.push(obj) 
                console.log('loanAppArr::::#147',loanAppArr)

        upsertMultipleRecord({params:loanAppArr})
              .then((result) => {   
                this.showSpinnerModal=false;
                this.dispatchEvent(new CloseActionScreenEvent());
                this.showToastMessage('Success','LAN Sent to Vendor Procesing Pool successfully','success','sticky')          
              console.log('inside update record'+JSON.stringify(result));  
              
            })
            .catch(error => {
              this.showSpinnerModal=false;
              console.log('error update record',error);
            });          

            } else {
                this.showSpinnerModal=false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please select required fields',
                        variant: 'error',
                        mode: 'sticky'
                    })
                );

            }

}

closeTecnicalModal() {

  
}

noBtn() {
  this.dispatchEvent(new CloseActionScreenEvent());
}



validateForm() {
  let isInputCorrect = true; 
  let allChilds = this.template.querySelectorAll("c-custom-lookup");
  console.log("custom lookup allChilds>>>", allChilds);
  allChilds.forEach((child) => {
      console.log("custom lookup child>>>", child);
      console.log(
          "custom lookup validity custom lookup >>>",
          isInputCorrect
      );
      if (!child.checkValidityLookup()) {
          child.checkValidityLookup();
          isInputCorrect = false;
          console.log(
              "custom lookup validity if false>>>",
              isInputCorrect
          );
      }
  });
  console.log('isInputCorrect',isInputCorrect);
  return isInputCorrect;
}


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