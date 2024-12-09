import { LightningElement ,track, wire, api} from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData'; 
import Id from "@salesforce/user/Id";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';
import RMSMName__c from "@salesforce/schema/LoanAppl__c.RMSMName__c";
import BrchCode__c from "@salesforce/schema/LoanAppl__c.BrchCode__c";
import BrchName__c  from "@salesforce/schema/LoanAppl__c.BrchName__c";
import LOAN_APP_ID from "@salesforce/schema/LoanAppl__c.Id";
import { updateRecord, deleteRecord } from "lightning/uiRecordApi";
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';

export default class ChangeRM extends LightningElement {


    //Current user role
    @track currentUserId = Id; 
    @track userRole;
    @track CurrentUserBranch= [];
    @track showSpinnerModal=false;
    @track ValidUser;

  _recordId;

  @api get recordId() {
    return this._recordId;
}
set recordId(value) {
    this._recordId = value;
    this.setAttribute("recordId", value);
    this.handleteamHierIdChange();
    this.handleRecordIdChange(value);
}
    @track _loanAppId;
  @api get loanAppId() {
    return this._loanAppId;
  }
  set loanAppId(value) {
    this._loanAppId = value;
    this.setAttribute("loanAppId", value);
    this.handleteamHierIdChange();
  }
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
    parentObjFields: ['id','BrchName__c', 'SubStage__c'],
    queryCriteria: ' where id = \'' + this.recordId + '\''
}
@track LoanBranchName
@wire(getSobjectDatawithRelatedRecords, { params: '$paramsLoanApp' })
    handleAppKyc(result) {
        this.wiredLoanData = result;
        console.log('this.loanappid rec',this._loanAppId ,this.recordId)
        if (result.data) {
            console.log('Loan app data=', result.data);
            if (result.data.parentRecord) {
                //  this.loanAppId = result.data.parentRecord.Id;

                this.LoanBranchName = result.data.parentRecord.BrchName__c;
                console.log('this.LoanBranchName',this.LoanBranchName)
                

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
              this.userValidation();
              for (var i = 0; i < data.parentRecords.length; i++) {
                this.CurrentUserBranch.push(data.parentRecords[i].EmpBrch__r.Name);
              }
              console.log('DATA IN CASE DETAILS :::: this.CurrentUserBranch',JSON.stringify(this.CurrentUserBranch));

          }
                    
      }
      if(error){
          console.error('ERROR CASE DETAILS:::::::#420',error)
      }
  }


  connectedCallback() {
   
    if (this.hasEditAccess === false) {
      this.disableMode = true;
    }

    // this.userValidation(); 
     
  }

  userValidation(){
   
    if(this.userRole== 'BBH' || this.userRole== 'CBH' || this.userRole== 'ABH' || this.userRole== 'RBH' ||
    this.userRole== 'DBH' || this.userRole== 'CBO' || this.userRole== 'NBH'){
      this.ValidUser=true;
      console.log('ValidUser', this.ValidUser)
    }
    else{
      this.dispatchEvent(new CloseActionScreenEvent());
        this.showToastMessage('Error','You are not allowed to take the action','error','sticky')
    }
  }

  @track lookUpRec;
@track lookupId;
@track forwardTodUser;
@track RMSMName
@track BrchCode
@track BrchName
  handleLookupFieldChange(event) {
    if (event.detail) {
      this.lookUpRec= event.detail;
      this.lookupId = event.detail.id;
      //let lookupAPIName = this.lookupRec.lookupFieldAPIName;
      if(this.lookupId!=null){
      this.BrchName=event.detail.record.EmpBrch__r.Name
      this.BrchCode=event.detail.record.EmpBrch__r.BrchCode__c
     // this.RMSMName=this.lookUpRec.record.Employee__c
      this.RMSMName=event.detail.id;
      }
    } 
    console.log('lookUpRec::::::',JSON.stringify(this.lookUpRec), this.lookupId);
    console.log('lookUpRec::::::', this.lookupId);
    console.log('lookUpRec::::::', this.BrchName,this.BrchCode,this.RMSMName,this._loanAppId,this.recordId);
}


RMSMRole=['RM','SM']
get filterCondn(){
  let val;
 
   // val= 'EmpRole__c IN (\''+this.RMSMRole.join('\', \'') + '\') AND EmpBrch__r.Name IN (\''+this.CurrentUserBranch.join('\', \'') + '\')';
   val= 'EmpRole__c IN (\''+this.RMSMRole.join('\', \'') + '\') AND EmpBrch__r.Name = \'' + this.LoanBranchName + '\'';
  
   console.log('val',this.val);
  return val;
}


handleYES() { 

  this.showSpinnerModal = true;
  // this.checkInitiate=false;
  this.updateLoanAppRec();
 
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

// updateLoanAppRec(){


//   let isInputCorrect = this.validateForm();
//             console.log("custom lookup validity if false>>>", isInputCorrect);
//             if (isInputCorrect === true) {
//               const fields = {}; 
//               fields[LOAN_APP_ID.fieldApiName] = this.recordId;
//               fields[RMSMName__c.fieldApiName] =this.RMSMName ;
//               fields[BrchCode__c.fieldApiName] =this.BrchCode ;
//               fields[BrchName__c.fieldApiName] =this.BrchName ;
//               const recordInput = { fields };
//               console.log('recordInput--->updateLoanAppRec',JSON.stringify(recordInput));
//               updateRecord(recordInput)
//               .then((result) => {   
//                 this.ValidUser=false;
//                 this.showSpinnerModal=false;
//                 this.dispatchEvent(new CloseActionScreenEvent());
//                 this.showToastMessage('Success','RM Changes successfully','success','sticky')          
//               console.log('inside update record'+JSON.stringify(result));
              
              
//             })
//             .catch(error => {
//               this.showSpinnerModal=false;
              
//                      });
            
                     

//             } else {
//                 this.showSpinnerModal=false;
//                 this.dispatchEvent(
//                     new ShowToastEvent({
//                         title: 'Error',
//                         message: 'Please select required fields',
//                         variant: 'error',
//                         mode: 'sticky'
//                     })
//                 );

//             }

 

// }
@track RARecord=[]
updateLoanAppRec(){


  let isInputCorrect = this.validateForm();
            console.log("custom lookup validity if false>>>", isInputCorrect);
            if (isInputCorrect === true) {
              // const fields = {}; 
              // fields[LOAN_APP_ID.fieldApiName] = this.recordId;
              // fields[RMSMName__c.fieldApiName] =this.RMSMName ;
              // fields[BrchCode__c.fieldApiName] =this.BrchCode ;
              // fields[BrchName__c.fieldApiName] =this.BrchName ;
              // const recordInput = { fields };
              // console.log('recordInput--->updateLoanAppRec',JSON.stringify(recordInput));


              let RecordObj={}
                RecordObj.Id = this.recordId;
               RecordObj.RMSMName__c=this.RMSMName; 
                RecordObj.BrchCode__c=this.BrchCode;
                RecordObj.BrchName__c=this.BrchName;
                this.RARecord.push(RecordObj) 
                console.log('this.RARecord inside save',this.RARecord)

        upsertMultipleRecord({params:this.RARecord})
             
              .then((result) => {   
                this.ValidUser=false;
                this.showSpinnerModal=false;
                this.dispatchEvent(new CloseActionScreenEvent());
                this.showToastMessage('Success','RM Changes successfully','success','sticky')          
              console.log('inside update record'+JSON.stringify(result));
              
              
            })
            .catch(error => {
              this.showSpinnerModal=false;
              
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
  this.ValidUser = false;
  
}

noBtn() {
  this.dispatchEvent(new CloseActionScreenEvent());
}

// validateForm() {
//   let isValid = true

 
//   this.template.querySelectorAll('lightning-combobox').forEach(element => {
//       if (element.reportValidity()) {
//           console.log('element passed');
//       } else {
//           isValid = false;
//           element.setCustomValidity('Please fill the valid value')
//       }

//   });
 
//   return isValid;
// }

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
}