import { LightningElement,api,track } from 'lwc';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import validateData from '@salesforce/apex/UWForwardValidations.validateData';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import Id from "@salesforce/user/Id";

export default class VendorPortalButtons extends LightningElement {
    @api recordId;
@track showSpinner=false;
 
connectedCallback(){
    console.log('recored Id::: ',this.recordId);
    this.fetchLoanDetails();
    this.fetchTeamDetails();
}

get poolStages(){
return this.userRole=== 'VCPA' && (this.lanSubStage === 'CPA Pool' || this.lanSubStage === 'Additional Data Entry Pool' || this.lanSubStage ==='Vendor Processing Pool' || this.lanSubStage ==='Additional Data Entry External Pool' || this.lanSubStage ==='Pre login Query Pool')
}
get forwardLAN(){
  let val;
  if(this.userRole === 'QCPA'){
      val=this.lanStage === 'DDE' && this.lanSubStage === 'Quality Check'
  }else if(this.userRole === 'VCPA'){
      val=this.lanStage === 'Post Sanction' && this.lanSubStage === 'Vendor Processing'
  }
    return  val;
}

get returnLAN(){
  return this.lanStage === 'DDE' && this.lanSubStage === 'Quality Check' && this.userRole === 'QCPA'
}

get showQalityChk(){
  return this.userRole ==='VCPA' && this.showQtChk;
}
get forwardOptions(){
    let opt=[];
    if(this.cpaAvl){
  opt=[{ label: 'CPA', value: 'CPA' },
       { label: 'UW', value: 'UW' }]
   }else{
       opt=[{ label: 'UW', value: 'UW' }]
   }
    return opt;
  }
    @track lanStage;
    @track lanSubStage;
    @track lanOwner;
    @track brchCode;
    @track cpaAvl=false;
    @track showQtChk=false;
    fetchLoanDetails() {
      let loanDetParams = {
          ParentObjectName: "LoanAppl__c",
          ChildObjectRelName: "",
          parentObjFields: ["Id", "Name","OwnerId","Stage__c","SubStage__c","BrchCode__c","Product__c",
            "BrchName__c"],
          childObjFields: [],
          queryCriteria: " where Id = '" + this.recordId + "' limit 1"
        };
        getSobjectDataNonCacheable({params: loanDetParams}).then((result) => {
            console.log("result Vednor Portal DETAILS #35>>>>>", result);
            if (result.parentRecords !== undefined && result.parentRecords[0].Id !== undefined && result.parentRecords.length > 0) {
              this.lanOwner = result.parentRecords[0].OwnerId;
              this.lanStage = result.parentRecords[0].Stage__c;
              this.lanSubStage = result.parentRecords[0].SubStage__c;
              this.brchCode= result.parentRecords[0].BrchCode__c;
              if(this.brchCode){
                this.getTeamHierarchyData();
              }
              if((Id === this.lanOwner) && (this.lanStage === 'DDE' &&  (this.lanSubStage === 'CPA Vendor Data Entry' || this.lanSubStage ==='Vendor Query'))){
                this.showQtChk=true;
              }	
            }
          })
          .catch((error) => {
            console.log("result Vednor Portal Button Details Error#37", error);
          });
      }

      getTeamHierarchyData() {
         let cpaRole='CPA'
        let teamHierParam = {
            ParentObjectName: 'TeamHierarchy__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'EmpRole__c', 'Employee__c','BranchCode__c', 'Employee__r.IsActive'],
            childObjFields: [],
            queryCriteria: ' WHERE EmpRole__c =\''+cpaRole+'\' AND BranchCode__c = \'' + this.brchCode + '\' AND Employee__r.IsActive =true'
        };
        getSobjectDataNonCacheable({ params: teamHierParam })
            .then((result) => {
              console.log('CPA team hierarchy data 74', result);
                if (result && result.parentRecords && result.parentRecords.length > 0) {
                  //console.log('CPA team hierarchy data 76', result.parentRecords);
                  this.cpaAvl=true;
              
                }
            })
            .catch((error) => {
                console.log("Error in CASE DETAILS COMP #1292", error);
            });
    }

     get claimLan(){
        return this.btnName === 'Loan Application Claim'
     }

     get forwardLan(){
        return this.btnName === 'Forward to CPA/UW' && !this.fwUserRole
     }

     get forwardRole(){
        return this.fwUserRole ==='CPA' || this.fwUserRole==='UW';
     }

     get returnTo(){
      return this.btnName === 'Return To';
     }

     get qualityChk(){
      return this.btnName === 'Send to Quality Check';
     }
     get customHeader(){
        let val;
         if(this.btnName === 'Forward to CPA/UW'){
            val= 'Confirm';
         }else if(this.btnName === 'Loan Application Claim'){
            val= 'Loan Application Claim';
         }else if(this.btnName === 'Return To'){
          val= 'Return to Query';
         }else if(this.btnName === 'Send to Quality Check'){
          val= 'Send to Quality Check';
         }
         return val;
     }
     @track btnName;
      handleButton(event){
        this.popUpModal=true;
        this.btnName = event.target.label;
        console.log("Button Name is >>>>>>>>>", this.btnName);
        
      } 

      @track popUpModal;
      handleCloseClaim(event){
        this.popUpModal=event.detail;
        this.fwUserRole='';
      }

      closeModal(){
        this.popUpModal=false;
        this.fwUserRole='';
        this.lookupId='';
      }

      @track fwUserRole;
      handleChange(event){
        console.log("event is >>>>>>>>>", event);
        let role = event.detail.value;
        console.log("role is >>>>>>>>>", role);
        this.fwUserRole=role;
      }

@track userRole;
fetchTeamDetails() {
   let teamHierParam = {
        ParentObjectName: 'TeamHierarchy__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id','EmpRole__c','Employee__c'],
        childObjFields: [],
        queryCriteria: ' where Employee__c=\''+Id+'\''
        }              
    getSobjectDataNonCacheable({params: teamHierParam}).then((result) => {
  
        console.log("result STAGE REVERSAL COMP #482>>>>>", result);
        if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
          this.userRole = result.parentRecords[0].EmpRole__c;
        
        }
      })
      .catch((error) => {
        console.log("Error in STAGE REVERSAL COMP #489", error);
      });
  }


  handleYesClick(){
    let isInputCorrect = this.validateForm();
    console.log("isInputCorrect if false>>>#320", isInputCorrect);
    if (isInputCorrect === true) {

       this.getForwardUwValidationreport();

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
@track lookUpRec;
@track lookupId;
//@track BrchCode
  handleLookupFieldChange(event) {
    if (event.detail) {
        this.lookUpRec= event.detail;
        this.lookupId = event.detail.id;
    } 
      console.log('lookUpRec::::::',JSON.stringify(this.lookUpRec));
  }

//@track brchCode
@track vqcRole=['QCPA'];
get filterCondn(){
      let val;
      val= 'EmpRole__c =\''+this.vqcRole+'\' AND BranchCode__c = \'' + this.brchCode + '\' AND Employee__r.IsActive =true';
      console.log('val',val);
      return val;
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

updateLAN(){
  let tempLanArr=[];
  let obj={};
  obj.sobjectType='LoanAppl__c';
  obj.Id=this.recordId;
  obj.OwnerId=this.lookupId;
  obj.Stage__c ='DDE';
  obj.SubStage__c ='Quality Check';
  tempLanArr.push(obj);
  console.log('tempCaseArr:::::::330',tempLanArr);
 
  upsertMultipleRecord({ params: tempLanArr })
  .then(result => {     
      console.log('Loan Save Btn Status Records Update ##334', result);
      this.popUpModal=false;
      this.showToastMessage('Success', 'Loan Application Sent to Quality Check Successfully', 'success', 'sticky');
      location.reload();
  })
  .catch(error => {
    this.showSpinner = false;
    console.error('SAVE Btn DETAILS ##366', error)
  })
        
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
        this.updateLAN();
      }
    })
    .catch((error) => {
      console.log("error occured in validateData", error);

    });
}

      showToastMessage(title, message, variant, mode) {
            const evt = new ShowToastEvent({
            title,message,variant,mode });
            this.dispatchEvent(evt);
      }
}