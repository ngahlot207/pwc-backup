import { LightningElement,api, wire,track} from 'lwc';
import getSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords'
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds'
import CURRENTUSERID from '@salesforce/user/Id';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Vendor_Upload_Report_Error from '@salesforce/label/c.Vendor_Upload_Report_Error';

export default class CaseDocumentUpload extends LightningElement {
  customeLabel = {
    Vendor_Upload_Report_Error
}

@track showSpinner;
  @api recordId;
  @api layoutSize;
  @api allowedFilFormat = ".jpg, .jpeg, .pdf";
  @api docName;
  @api docType;
  @api docCategory;
  @track disableAgency;
  catValue = 'Case Documents';
  @track convertToSingleImage = false;
  DocumentDetaiId;
  @track hideAttachButton = true;
  @track multipleFileUploadFlag = true;
  DocumentType; 
  applicantId;
  loanAppId;
  caseId;
  @track caseFlag;
  documentMasterFlag;
  profileName;
  fileSizeMsz = "Maximum file size should be 5Mb. Allowed file types are .pdf, .jpg, .jpeg";

 
  @track reportCount;

  connectedCallback(){
    console.log('recordId of upload:',this.recordId);
    this.getprofileName();
  }


getprofileName(){
  let parameter1 = {
      ParentObjectName: 'User',
      ChildObjectRelName: null,
      parentObjFields: ['Id,Profile.Name'],
      childObjFields: [],
      queryCriteria: ' where Id = \'' + CURRENTUSERID + '\''
      }

      getSobjDataWIthRelatedChilds({ params: parameter1 })
      .then(result => {
        
         this.profileName = result.parentRecord.Profile.Name;
         this.initialize(this.recordId);
         console.log('Profile name:',this.profileName);
      })
  
      .catch(error => {
          console.log('INTLIZE error : ',JSON.stringify(error));
      });
}


  initialize(caseId){
  let parameter = {
    ParentObjectName: 'Case',
    ChildObjectRelName: null,
    parentObjFields: ['Id','RecordType.Name','Loan_Application__c','Applicant__c','Product_Type__c','Loan_Application__r.Applicant__c','Status','PhotoCount__c','ReportCount__c'],
    childObjFields: [],
    queryCriteria: ' where id = \'' + caseId + '\''
  }

  getSobjDataWIthRelatedChilds({ params: parameter })
  .then(result => {
    if(result.parentRecord.Id != undefined && result.parentRecord.RecordType.Name === 'CPVFI'){
       console.log('Case Detail :'+JSON.stringify(result));
       console.log('Case record Type :'+JSON.stringify(result.parentRecord.RecordType.Name));
       this.loanAppId = result.parentRecord.Loan_Application__c;
     //  this.reportCount = result.parentRecord.ReportCount__c;
      

      if(result.parentRecord.Applicant__c != undefined){
        this.applicantId = result.parentRecord.Applicant__c;
        console.log('Taking Case Applicant');
      }else{
        this.applicantId = result.parentRecord.Loan_Application__r.Applicant__c;
        console.log('Taking Loan Application Applicant');
      }

      this.docName = 'CPV Report';
      this.docType = 'CPV Documents';
      if(this.applicantId != undefined && this.loanAppId != undefined){

        if(result.parentRecord.Status === 'Closed' && this.profileName === 'Agency Profile'){
          this.disableAgency = true;
         // this.hideAttachButton = true;
        }else{
          this.disableAgency = false;
        }
        this.caseFlag = true;
      }

      console.log('applicantId:',this.applicantId);
      console.log('loanAppId:',this.loanAppId);
    }
    else if(result.parentRecord.Id != undefined && result.parentRecord.RecordType.Name === 'Technical'){
       this.loanAppId = result.parentRecord.Loan_Application__c;
      // this.reportCount = result.parentRecord.ReportCount__c;
     
      if(result.parentRecord.Applicant__c != undefined){
        this.applicantId = result.parentRecord.Applicant__c;
        console.log('Taking Case Applicant');
      }else{
        this.applicantId = result.parentRecord.Loan_Application__r.Applicant__c;
        console.log('Taking Loan Application Applicant');
      }
        this.docName = 'Technical Report';
        this.docType = 'Technical Verification Documents';

      if(this.applicantId != undefined && this.loanAppId != undefined ){
        console.log('disabled');
        if(result.parentRecord.Status === 'Closed' && this.profileName === 'Agency Profile'){
          this.disableAgency = true;
          //this.hideAttachButton = true;
        }else{
          this.disableAgency = false;
        }
        this.caseFlag = true;
      }

      console.log('applicantId:',this.applicantId);
      console.log('loanAppId:',this.loanAppId);
    }
    else if(result.parentRecord.Id !== undefined && result.parentRecord.RecordType.Name === 'TSR'){
      this.loanAppId = result.parentRecord.Loan_Application__c;
     // this.reportCount = result.parentRecord.ReportCount__c;
    
     if(result.parentRecord.Applicant__c !== undefined){
       this.applicantId = result.parentRecord.Applicant__c;
       console.log('Taking Case Applicant');
     }else{
       this.applicantId = result.parentRecord.Loan_Application__r.Applicant__c;
       console.log('Taking Loan Application Applicant');
     }
       this.docName = 'TSR Report';
       this.docType = 'TSR Verification';

     if(this.applicantId !== undefined && this.loanAppId !== undefined ){
       console.log('disabled');
       if(result.parentRecord.Status === 'Closed' && this.profileName === 'Agency Profile'){
         this.disableAgency = true;
         //this.hideAttachButton = true;
       }else{
         this.disableAgency = false;
       }
       this.caseFlag = true;
     }

     console.log('applicantId:',this.applicantId);
     console.log('loanAppId:',this.loanAppId);
   }
   else if(result.parentRecord.Id !== undefined && result.parentRecord.RecordType.Name === 'Vetting'){
    this.loanAppId = result.parentRecord.Loan_Application__c;
   // this.reportCount = result.parentRecord.ReportCount__c;
  
   if(result.parentRecord.Applicant__c !== undefined){
     this.applicantId = result.parentRecord.Applicant__c;
     console.log('Taking Case Applicant');
   }else{
     this.applicantId = result.parentRecord.Loan_Application__r.Applicant__c;
     console.log('Taking Loan Application Applicant');
   }
     this.docName = 'Vetting Report';
     this.docType = 'Vetting Verification';

   if(this.applicantId !== undefined && this.loanAppId !== undefined ){
     console.log('disabled');
     if(result.parentRecord.Status === 'Closed' && this.profileName === 'Agency Profile'){
       this.disableAgency = true;
       //this.hideAttachButton = true;
     }else{
       this.disableAgency = false;
     }
     this.caseFlag = true;
   }

   console.log('applicantId:',this.applicantId);
   console.log('loanAppId:',this.loanAppId);
 }
//LAK-113
 else if(result.parentRecord.Id !== undefined && result.parentRecord.RecordType.Name === 'Legal'){
  this.loanAppId = result.parentRecord.Loan_Application__c;
 // this.reportCount = result.parentRecord.ReportCount__c;

 if(result.parentRecord.Applicant__c !== undefined){
   this.applicantId = result.parentRecord.Applicant__c;
   console.log('Taking Case Applicant');
 }else{
   this.applicantId = result.parentRecord.Loan_Application__r.Applicant__c;
   console.log('Taking Loan Application Applicant');
 }
   this.docName = 'Legal Report';
   this.docType = 'Legal Verification';

 if(this.applicantId !== undefined && this.loanAppId !== undefined ){
   console.log('disabled');
   if(result.parentRecord.Status === 'Closed' && this.profileName === 'Agency Profile'){
     this.disableAgency = true;
     //this.hideAttachButton = true;
   }else{
     this.disableAgency = false;
   }
   this.caseFlag = true;
 }

 console.log('applicantId:',this.applicantId);
 console.log('loanAppId:',this.loanAppId);
}
//LAK-553
 else if(result.parentRecord.Id !== undefined && result.parentRecord.RecordType.Name === 'LIP Vendor case'){
  this.loanAppId = result.parentRecord.Loan_Application__c;
 // this.reportCount = result.parentRecord.ReportCount__c;

 if(result.parentRecord.Applicant__c !== undefined){
   this.applicantId = result.parentRecord.Applicant__c;
   console.log('Taking Case Applicant');
 }else{
   this.applicantId = result.parentRecord.Loan_Application__r.Applicant__c;
   console.log('Taking Loan Application Applicant');
 }
   this.docName = 'LIP Report';
   this.docType = 'LIP Documents';

 if(this.applicantId !== undefined && this.loanAppId !== undefined ){
   console.log('disabled');
   if(result.parentRecord.Status === 'Closed' && this.profileName === 'Agency Profile'){
     this.disableAgency = true;
     //this.hideAttachButton = true;
   }else{
     this.disableAgency = false;
   }
   this.caseFlag = true;
 }

 console.log('applicantId:',this.applicantId);
 console.log('loanAppId:',this.loanAppId);
}
//LAK-162
 else if(result.parentRecord.Id !== undefined && result.parentRecord.RecordType.Name === 'RCU'){
  this.loanAppId = result.parentRecord.Loan_Application__c;
 // this.reportCount = result.parentRecord.ReportCount__c;

 if(result.parentRecord.Applicant__c !== undefined){
   this.applicantId = result.parentRecord.Applicant__c;
   console.log('Taking Case Applicant');
 }else{
   this.applicantId = result.parentRecord.Loan_Application__r.Applicant__c;
   console.log('Taking Loan Application Applicant');
 }
   this.docName = 'RCU Report';
   this.docType = 'RCU Verification';

 if(this.applicantId !== undefined && this.loanAppId !== undefined ){
   console.log('disabled');
   if(result.parentRecord.Status === 'Closed' && this.profileName === 'Agency Profile'){
     this.disableAgency = true;
     //this.hideAttachButton = true;
   }else{
     this.disableAgency = false;
   }
   this.caseFlag = true;
 }

 console.log('applicantId:',this.applicantId);
 console.log('loanAppId:',this.loanAppId);
}
  })
  .catch(error => {
      console.log('INTLIZE error : ',JSON.stringify(error));
  });
}


parentFileChange(event){
  this.files=event.detail.fileList
  console.log('in parentFileChange',this.files.length)

 if(this.files && this.files.length > 0){
    // this.hideAttachButton = false;
   }


  let parameter = {
    ParentObjectName: 'Case',
    ChildObjectRelName: null,
    parentObjFields: ['Id','RecordType.Name','Loan_Application__c','Applicant__c','Product_Type__c','Loan_Application__r.Applicant__c','Status','Owner.Profile.name','ReportCount__c'],
    childObjFields: [],
    queryCriteria: ' where id = \'' + this.recordId + '\''
    }

    getSobjectDataNonCacheable({params: parameter}).then((result) => {
      if(result.parentRecords[0].ReportCount__c != undefined){
        this.reportCount = result.parentRecords[0].ReportCount__c;
      }
       
         console.log("result TECHNICAL PROP DOCUMENT DETAILS #688>>>>>", JSON.stringify(result.parentRecords[0].Status));
         if (result.parentRecords !== undefined && result.parentRecords.length > 0 && this.profileName === 'Agency Profile' && result.parentRecords[0].Status ==='Closed') {
          console.log('Inside if');
         // this.hideAttachButton = true;
            this.showtost(this.customeLabel.Vendor_Upload_Report_Error);
         }
       else if(this.files.length > 0 && this.template.querySelector('c-upload-docs-reusable-component')!=''&& this.template.querySelector('c-upload-docs-reusable-component')!=null && typeof this.template.querySelector('c-upload-docs-reusable-component') !=='undefined'){
           this.template.querySelector('c-upload-docs-reusable-component').handleUpload();
    
       }else{
          
       }
         
       })
       .catch((error) => {
         console.log("TECHNICAL PROP DOCUMENT DETAILS #696", error);
       });
}

spinnerStatus(event) {
  console.log('spinner value ', JSON.stringify(event.detail));
  this.showSpinner = event.detail;
}

@api handleUploadDoc(event){
  const docDetail = event.detail;
//  this.hideAttachButton = true;
  console.log('docDetail id in event :',JSON.stringify(docDetail));
  let upsertObjectParams = {
    parentRecord : {},
    ChildRecords : [],
    ParentFieldNameToUpdate : ''
  };

  if(docDetail.docDetailId != undefined && this.recordId != undefined){
    upsertObjectParams.parentRecord.sobjectType = 'DocDtl__c';
    upsertObjectParams.parentRecord.Id = docDetail.docDetailId;
    upsertObjectParams.parentRecord.Case__c = this.recordId;

    upsertSobjDataWIthRelatedChilds({upsertData:upsertObjectParams})
    .then((result) => {
      console.log('is case id  map?:',result);
      this.showSpinner =false;
      this.updateCaseRecord();

    })
    .catch((error) => {
      this.error = error;
      console.log('is case id  map error:',JSON.stringify(error));
    });
}
}

updateCaseRecord(){
  let upsertObjectParams = {
    parentRecord : {},
    ChildRecords : [],
    ParentFieldNameToUpdate : ''
  };
  var currentDate = new Date().toJSON().slice(0, 10);
  console.log('currentDate:'+currentDate);
  console.log('report count 1:'+ this.reportCount);

  upsertObjectParams.parentRecord.sobjectType = 'Case';
  upsertObjectParams.parentRecord.Id = this.recordId;
  upsertObjectParams.parentRecord.Date_of_Report__c = currentDate;
  if(this.reportCount != undefined){
    upsertObjectParams.parentRecord.ReportCount__c = this.reportCount + 1;
  }else{
    upsertObjectParams.parentRecord.ReportCount__c = 1;
  }
 
  console.log('report count OBJ:'+ upsertObjectParams.parentRecord.ReportCount__c);
  
  upsertSobjDataWIthRelatedChilds({upsertData:upsertObjectParams})
    .then((result) => {
     console.log('Updated Case report date :'+JSON.stringify(result));
     const selectedEvent = new CustomEvent("select", {
      detail: false
    });
      this.dispatchEvent(selectedEvent);
  //   this.handleChildEvent();
    })
    .catch((error) => {
      this.error = error;
      console.log('Error while Update case record:',JSON.stringify(error));
    });

}

showtost(Message){
  const event = new ShowToastEvent({
      title: 'Error',
      message: Message,
      variant: 'error',
      mode: "sticky"
  });
  this.dispatchEvent(event);
}


 handleChildEvent(event){
  let childEvt = event.detail;
  console.log('childEvt::::#143',childEvt );
  const selectedEvent = new CustomEvent("select", {
    detail: false
  });
    this.dispatchEvent(selectedEvent);

} 
}