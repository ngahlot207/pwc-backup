import { LightningElement,api,track } from 'lwc';
import getSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords'
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import Vendor_Photo_Upload_Error from '@salesforce/label/c.Vendor_Photo_Upload_Error';

import CURRENTUSERID from '@salesforce/user/Id';
export default class CaseUploadPhotos extends LightningElement {
@api recordId;
@api fileSizeMsz = "Maximum File Size should be 5Mb. Allowed File Types are  .jpg, .jpeg, .pdf ";;
@api allowedFilFormat= [".jpg", ".jpeg", ".pdf"];
@api fileTypeError = 'Allowed File Types are : pdf, jpg, jpeg';
@track caseUploadFileFag;
@track convertToSingleImage = false;

customeLabel = {
    Vendor_Photo_Upload_Error
 
}
docName;
docType;
applicantId;
loanAppId;
catValue = 'Case Documents';
DocumentDetaiId;
@track showSpinner;
minimumPhoto;
files;
message;
photoSize;
disableAgency;
profileName;
status;
photoCount;
@track photoLength;
@track latestRecordId;



@track hideAttachButton = true;

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
    parentObjFields: ['Id','RecordType.Name','Loan_Application__c','Applicant__c','Product_Type__c','Loan_Application__r.Applicant__c','Status','PhotoCount__c'],
    childObjFields: [],
    queryCriteria: ' where id = \'' + caseId + '\''
    }

getSobjDataWIthRelatedChilds({ params: parameter })
    .then(result => {

    //CPV Case
    if(result.parentRecord.Id != undefined && result.parentRecord.RecordType.Name === 'CPVFI'){
        console.log('Case Detail :'+JSON.stringify(result));
        console.log('Case record Type :'+JSON.stringify(result.parentRecord.RecordType.Name));
        this.status = result.parentRecord.Status;
        this.loanAppId = result.parentRecord.Loan_Application__c;
      //  this.photoCount = result.parentRecord.PhotoCount__c;
        if(result.parentRecord.Applicant__c != undefined){
        this.applicantId = result.parentRecord.Applicant__c;
        console.log('Taking Case Applicant');
        }else{
        this.applicantId = result.parentRecord.Loan_Application__r.Applicant__c;
        console.log('Taking Loan Application Applicant');
        }
        this.docName = 'CPV Photos';
        this.docType = 'CPV Photos';
        this.minimumPhoto = 3;
        this.photoSize = 4;
        
        if(this.loanAppId != undefined && this.applicantId != undefined){
           this.caseUploadFileFag = false;

         if(result.parentRecord.Status === 'Closed' && this.profileName === 'Agency Profile'){
            this.disableAgency = true;
          //  this.hideAttachButton = true;
          }else{
            this.disableAgency = false;
          }

        }
        console.log('applicantId:',this.applicantId);
        console.log('loanAppId:',this.loanAppId);
    }
    
    //Techanical Case
    else if(result.parentRecord.Id != undefined && result.parentRecord.RecordType.Name === 'Technical'){
        this.loanAppId = result.parentRecord.Loan_Application__c;
        this.photoCount = result.parentRecord.PhotoCount__c;

        if(result.parentRecord.Applicant__c != undefined){
            this.applicantId = result.parentRecord.Applicant__c;
            console.log('Taking Case Applicant');
        }else{
            this.applicantId = result.parentRecord.Loan_Application__r.Applicant__c;
            console.log('Taking Loan Application Applicant');
        }
            this.docName = 'Technical Photos';
            this.docType = 'Technical Photos';
            this.minimumPhoto = 5;
            this.photoSize = 6;
            if(this.loanAppId != undefined && this.applicantId != undefined){
                if(result.parentRecord.Status === 'Closed' && this.profileName === 'Agency Profile'){
                    this.disableAgency = true;
                   //this.hideAttachButton = true;
                  }else{
                    this.disableAgency = false;
                  }
             this.caseUploadFileFag = false;
        }
            console.log('applicantId:',this.applicantId);
            console.log('loanAppId:',this.loanAppId);
    }
        //TSR Case
        else if(result.parentRecord.Id !== undefined && result.parentRecord.RecordType.Name === 'TSR'){
          this.loanAppId = result.parentRecord.Loan_Application__c;
          this.photoCount = result.parentRecord.PhotoCount__c;
  
          if(result.parentRecord.Applicant__c !== undefined){
              this.applicantId = result.parentRecord.Applicant__c;
              console.log('Taking Case Applicant');
          }else{
              this.applicantId = result.parentRecord.Loan_Application__r.Applicant__c;
              console.log('Taking Loan Application Applicant');
          }
              this.docName = 'TSR Photos';
              this.docType = 'TSR Photos';
              this.minimumPhoto = 5;
              this.photoSize = 6;
              if(this.loanAppId !== undefined && this.applicantId !== undefined){
                  if(result.parentRecord.Status === 'Closed' && this.profileName === 'Agency Profile'){
                      this.disableAgency = true;
                     //this.hideAttachButton = true;
                    }else{
                      this.disableAgency = false;
                    }
               this.caseUploadFileFag = false;
          }
              console.log('applicantId:',this.applicantId);
              console.log('loanAppId:',this.loanAppId);
      }
      else if(result.parentRecord.Id !== undefined && result.parentRecord.RecordType.Name === 'Vetting'){
        this.loanAppId = result.parentRecord.Loan_Application__c;
        this.photoCount = result.parentRecord.PhotoCount__c;

        if(result.parentRecord.Applicant__c !== undefined){
            this.applicantId = result.parentRecord.Applicant__c;
            console.log('Taking Case Applicant');
        }else{
            this.applicantId = result.parentRecord.Loan_Application__r.Applicant__c;
            console.log('Taking Loan Application Applicant');
        }
            this.docName = 'Vetting Photos';
            this.docType = 'Vetting Photos';
            this.minimumPhoto = 5;
            this.photoSize = 6;
            if(this.loanAppId !== undefined && this.applicantId !== undefined){
                if(result.parentRecord.Status === 'Closed' && this.profileName === 'Agency Profile'){
                    this.disableAgency = true;
                   //this.hideAttachButton = true;
                  }else{
                    this.disableAgency = false;
                  }
             this.caseUploadFileFag = false;
        }
            console.log('applicantId:',this.applicantId);
            console.log('loanAppId:',this.loanAppId);
    }
//Legal Case LAK-113
    else if(result.parentRecord.Id !== undefined && result.parentRecord.RecordType.Name === 'Legal'){
      this.loanAppId = result.parentRecord.Loan_Application__c;
      this.photoCount = result.parentRecord.PhotoCount__c;

      if(result.parentRecord.Applicant__c !== undefined){
          this.applicantId = result.parentRecord.Applicant__c;
          console.log('Taking Case Applicant');
      }else{
          this.applicantId = result.parentRecord.Loan_Application__r.Applicant__c;
          console.log('Taking Loan Application Applicant');
      }
          this.docName = 'Legal Photos';
          this.docType = 'Legal Photos';
          this.minimumPhoto = 5;
          this.photoSize = 6;
          if(this.loanAppId !== undefined && this.applicantId !== undefined){
              if(result.parentRecord.Status === 'Closed' && this.profileName === 'Agency Profile'){
                  this.disableAgency = true;
                 //this.hideAttachButton = true;
                }else{
                  this.disableAgency = false;
                }
           this.caseUploadFileFag = false;
      }
          console.log('applicantId:',this.applicantId);
          console.log('loanAppId:',this.loanAppId);
  }
    //LAK-553
    else if(result.parentRecord.Id !== undefined && result.parentRecord.RecordType.Name === 'LIP Vendor case'){
      this.loanAppId = result.parentRecord.Loan_Application__c;
      this.photoCount = result.parentRecord.PhotoCount__c;
      this.allowedFilFormat = [".jpg", ".jpeg"];
      this.fileSizeMsz = "Maximum File Size should be 5Mb. Allowed File Types are  .jpg, .jpeg ";
      this.fileTypeError = 'Allowed File Types are : jpg, jpeg';

      if(result.parentRecord.Applicant__c !== undefined){
          this.applicantId = result.parentRecord.Applicant__c;
          console.log('Taking Case Applicant');
      }else{
          this.applicantId = result.parentRecord.Loan_Application__r.Applicant__c;
          console.log('Taking Loan Application Applicant');
      }
          this.docName = 'LIP Photos';
          this.docType = 'LIP Photos';
          this.minimumPhoto = 3;
          this.photoSize = 4;
          if(this.loanAppId !== undefined && this.applicantId !== undefined){
              if(result.parentRecord.Status === 'Closed' && this.profileName === 'Agency Profile'){
                  this.disableAgency = true;
                 //this.hideAttachButton = true;
                }else{
                  this.disableAgency = false;
                }
           this.caseUploadFileFag = false;
      }
          console.log('applicantId:',this.applicantId);
          console.log('loanAppId:',this.loanAppId);
  }
  //LAK-162
  else if(result.parentRecord.Id !== undefined && result.parentRecord.RecordType.Name === 'RCU'){
    this.loanAppId = result.parentRecord.Loan_Application__c;
    this.photoCount = result.parentRecord.PhotoCount__c;
    this.allowedFilFormat = [".jpg", ".jpeg"];
    this.fileSizeMsz = "Maximum File Size should be 5Mb. Allowed File Types are  .jpg, .jpeg ";
    this.fileTypeError = 'Allowed File Types are : jpg, jpeg';

    if(result.parentRecord.Applicant__c !== undefined){
        this.applicantId = result.parentRecord.Applicant__c;
        console.log('Taking Case Applicant');
    }else{
        this.applicantId = result.parentRecord.Loan_Application__r.Applicant__c;
        console.log('Taking Loan Application Applicant');
    }
        this.docName = 'RCU Photos';
        this.docType = 'RCU Photos';
        this.minimumPhoto = 3;
        this.photoSize = 4;
        if(this.loanAppId !== undefined && this.applicantId !== undefined){
            if(result.parentRecord.Status === 'Closed' && this.profileName === 'Agency Profile'){
                this.disableAgency = true;
               //this.hideAttachButton = true;
              }else{
                this.disableAgency = false;
              }
         this.caseUploadFileFag = false;
    }
        console.log('applicantId:',this.applicantId);
        console.log('loanAppId:',this.loanAppId);
}
    })

    .catch(error => {
        console.log('INTLIZE error : ',JSON.stringify(error));
    });
}


spinnerStatus(event) {
    console.log('spinner value ', JSON.stringify(event.detail));
    this.showSpinner = event.detail;
}


parentFileChange(event){
    this.files=event.detail.fileList
    console.log('in parentFileChange',this.files.length);

    if(this.files && this.files.length > 0){
    // this.hideAttachButton = false;
    }

    let parameter = {
        ParentObjectName: 'Case',
        ChildObjectRelName: null,
        parentObjFields: ['Id','RecordType.Name','Loan_Application__c','Applicant__c','Product_Type__c','Loan_Application__r.Applicant__c','Status','PhotoCount__c'],
        childObjFields: [],
        queryCriteria: ' where id = \'' + this.recordId + '\''
        }


        getSobjectDataNonCacheable({params: parameter}).then((result) => {
            if(result.parentRecords[0].PhotoCount__c != undefined){
              this.photoCount = result.parentRecords[0].PhotoCount__c;
            }
             console.log("result TECHNICAL PROP DOCUMENT DETAILS #688>>>>>", JSON.stringify(result.parentRecords[0].Status));
             
             if (result.parentRecords !== undefined && result.parentRecords.length > 0 && this.profileName === 'Agency Profile' && result.parentRecords[0].Status ==='Closed') {
             // this.hideAttachButton = true;
                this.showtost(this.customeLabel.Vendor_Photo_Upload_Error);
             }else if(this.template.querySelector('c-upload-docs-reusable-component')!=''&& this.template.querySelector('c-upload-docs-reusable-component')!=null && typeof this.template.querySelector('c-upload-docs-reusable-component') !=='undefined'){
              this.photoLength = this.files.length;
              this.template.querySelector('c-upload-docs-reusable-component').handleUpload();
             }else{

             }
             
           })
           .catch((error) => {
             console.log("Erro while upload photos", JSON.stringify(error));
           });
    
}


fromUploadDocsContainer(event) {
    console.log('event after uplaoding is ', JSON.stringify(event.detail));
    const docDetail = event.detail;
    //this.hideAttachButton = true;
    console.log('docDetail:',JSON.stringify(docDetail));
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
        console.log('is case id  map?:',JSON.stringify(result));
        this.showSpinner = false;
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
    console.log('Inside updateCaseRecord method');
    console.log('photoCount 1:'+ this.photoCount);
    upsertObjectParams.parentRecord.sobjectType = 'Case';
    upsertObjectParams.parentRecord.Id = this.recordId;
    if(this.photoCount != undefined){
      upsertObjectParams.parentRecord.PhotoCount__c = this.photoCount + this.photoLength;
    }else{
      upsertObjectParams.parentRecord.PhotoCount__c = this.photoLength;
    }
    
    upsertSobjDataWIthRelatedChilds({upsertData:upsertObjectParams})
      .then((result) => {
       console.log('Updated Case report date :'+JSON.stringify(result));
       this.latestRecordId = result.parentRecord.Id;
      
       const selectedEvent = new CustomEvent("select", {
        detail: false
      });
        this.dispatchEvent(selectedEvent);
      })


      .catch((error) => {
        this.error = error;
        console.log('Error while Update case record:',JSON.stringify(error));
      });
  
  }





// refreshDocTable() {
//     this.showSpinner = false;
//     let child = this.template.querySelector('c-show-case-document');
//     child.handleFilesUploaded();
    
// }

showtost(Message){
    const event = new ShowToastEvent({
        title: 'Error',
        message: Message,
        variant: 'error',
        mode: "sticky"
    });
    this.dispatchEvent(event);
}

}