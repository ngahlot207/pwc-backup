import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";

import formFactorPropertyName from "@salesforce/client/formFactor";

import LOAN_APPL_FIELD from "@salesforce/schema/LoanAppeal__c.LoanAppl__c";
import COMMENTS_FIELD from "@salesforce/schema/LoanAppeal__c.Comments__c";
import STATUS_FIELD from "@salesforce/schema/LoanAppeal__c.Status__c";
import OWNER_FIELD from "@salesforce/schema/LoanAppeal__c.OwnerId";
import DOCDET_ID_FIELD from "@salesforce/schema/LoanAppeal__c.DocDet__c";
import RECORD_TYPE_FIELD from "@salesforce/schema/LoanAppeal__c.RecordTypeId";

import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import getSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords'
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import upsertMultipleRecord from "@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord";

import RELOOK_CREATE_ROLES from '@salesforce/label/c.Relook_Create_Roles';
import Relook_Approve_Roles from '@salesforce/label/c.Relook_Approve_Roles';
import Relook_Ops_Roles from '@salesforce/label/c.Relook_Ops_Roles';
import CURRENTUSERID from '@salesforce/user/Id';
import { formattedDateTimeWithoutSeconds } from 'c/dateUtility';

export default class ApplicationRelook extends LightningElement {

  @api hasEditAccess
  @track _recordId;
    @api get recordId() {
    return this._recordId;
  }
  set recordId(value) {
    this._recordId = value;
    this.setAttribute("recordId", value);
  //  this.fetchRelookHistory();
    this.fetchLoanDetails();
  }

  @track _applicantId;
  @api get applicantId() {
    return this._applicantId;
  }
  set applicantId(value) {
    this._applicantId = value;
    this.setAttribute("applicantId", value);
  }
  @track loanAppealId;
  @track lanStatus;
  @track branchCode;
  @track enableFields = true;
  @track showSpinner;
  @track remarks;
  @track oldVal;
  @track newVal;
  @track UWPoolId;
  @track docDetId;
  @track documentDetailId;
  @track userRole;
  @track viewReport;
  @track viewTableReport;
  @track hideAttachButton=true;
  @track comments;
  @track decision;
  @track loanAppealStatus;
  @track claimAppeal;
  @track claimApplId;
  @track loanAppealOwner;
  @track showDecisionBts=false;
  @track relookData=[];
  @track deviationRec=[];
@track rolookCretors=[];
@track rolookApprovers=[];
@track rolookOps=[];
@track opsHide=false;
@track rejectReason;
@track rejectDecRemarks;
@track decComments;

@track formFactor = formFactorPropertyName;
desktopBoolean = false;
phoneBolean = false;


  customLable={
    RELOOK_CREATE_ROLES,
    Relook_Approve_Roles,
    Relook_Ops_Roles
  }

  get disbaleMode(){
      return this.poolStages || !(this.lanStatus === 'BRE Soft Reject' || this.lanStatus === 'Rejected') || this.loanAppealStatus ==='Approve' || this.loanAppealStatus ==='New' || this.loanAppealStatus ==='In Progress';
  }

  get disbaleModeRunBre(){
    return this.poolStages || !(this.lanStatus === 'BRE Hard Reject' || this.lanStatus === 'BRE Soft Reject' || this.lanStatus === 'Rejected') || this.loanAppealStatus ==='Approve' || this.loanAppealStatus ==='New' || this.loanAppealStatus ==='In Progress';
}
  
  get filterCondn(){
    let val;
    if(this.loanAppealStatus ==='New' || this.loanAppealStatus ==='In Progress'){
      val= 'EmpRole__c IN (\''+this.rolookApprovers.join('\', \'') + '\') AND Employee__c != \'' + CURRENTUSERID + '\' AND EmpBrch__r.BrchCode__c =\''+this.branchCode+'\' AND Employee__r.IsActive=true';
    }
    return val;
  }

  get forwardAppl(){
    return (this.loanAppealStatus ==='In Progress' || this.loanAppealStatus ==='New') && this.showDecisionBts;
  }

  get poolStages(){
    return this.lanSubStage === 'CPA Pool' || this.lanSubStage === 'Additional Data Entry Pool' || this.lanSubStage === 'UW Pool' || this.lanSubStage ==='Data Entry Pool' || this.lanSubStage ==='UW Approval Pool' || this.lanSubStage ==='Ops Query Pool'
    }
  @api docName = "Relook Document";
  @api docType = "Relook Document";
  @api docCategory = "Relook Document";
  @api allowedFilFormat = ".docx, .pdf, .doc,.jpg,.jpeg";
  @api fileTypeError = "Allowed File Types are : docx, pdf, doc, jpg, jpeg";
  @api fileSizeError = "Maximum file size should be 25Mb.";
  convertToSingleImage = true;
  multipleFileUpload=true;
  @track fileSizeMsz = "Maximum file size should be 25Mb.";
//@track clearFileList;
  get enableRelook() {
    return this.enableFields;
  }
@track rolookInit=false;
  get rmView(){
    return this.rolookInit;
  }

  get disableDecision(){
    return this.loanAppealStatus === 'Approve' || this.loanAppealStatus === 'Reject' || (this.lookupId !== undefined && this.lookupId !==null);
  }

  get enableForward(){
    return (this.lookupId !== undefined && this.lookupId !==null)
  }

  get showRejectFields(){
    return this.lanStatus === 'Rejected';
  }

  @track teamHierParam = {
    ParentObjectName: 'TeamHierarchy__c',
    ChildObjectRelName: '',
    parentObjFields: ['Id','EmpRole__c','Employee__c'],
    childObjFields: [],
    queryCriteria: ' where Employee__c = \'' + CURRENTUSERID + '\' limit 1' 
    }

  @track recordTypeId;
  @wire(getObjectInfo, { objectApiName: "LoanAppeal__c" })
  getObjectInfo({ error, data }) {
    if (data) {
      console.log("DATA in RECORD TYPE ID IN TECHINCAL PROP DET #332", data);
      for (let key in data.recordTypeInfos) {
        let recordType = data.recordTypeInfos[key];
        console.log("recordTypeId.value>>>>>", recordType.name);
        if (recordType.name === "Reject Relook") {
          this.recordTypeId = key;
        }
        console.log(
          "data.recordTypeId in APPL RELOOK::::47",
          this.recordTypeId
        );
      }
    } else if (error) {
      console.error("Error fetching record type Id", error);
    }
  }

  connectedCallback() {
    if (this.formFactor === "Large") {
      this.desktopBoolean = true;
      this.phoneBolean = false;
  } else if (this.formFactor === "Small") {
      this.desktopBoolean = false;
      this.phoneBolean = true;
  } else {
      this.desktopBoolean = false;
      this.phoneBolean = true;
  }

    console.log(
      "RESULT APPLICATION RELOOK LOAN ID API #19>>>>>",
      this.recordId,
      "_applicantId",
      this._applicantId, 'this._recordId::::',this._recordId
    );
    console.log('SALES_USER::::::',this.customLable.RELOOK_CREATE_ROLES, this.rolookCretors);
    //this.getQueueId();
    this.fetchLoanDetails();
    this.getFieldHistory();
    // this.fetchRelookHistory();
    this.getQueueId();
    this.getDeviations();
    this.initializeRoles();
   
  }



  initializeRoles() {
    // Split the roles string into an array
    if (RELOOK_CREATE_ROLES) {
        this.rolookCretors = RELOOK_CREATE_ROLES.split(',');
        console.log('Roles Creator Array:149', this.rolookCretors); // Log to verify
    }
    if (Relook_Approve_Roles) {
      this.rolookApprovers = Relook_Approve_Roles.split(',');
      console.log('Roles Approver Array:152', this.rolookApprovers); // Log to verify
    }
    if (Relook_Ops_Roles) {
      this.rolookOps = Relook_Ops_Roles.split(',');
      console.log('Roles Ops Array:177', this.rolookOps); // Log to verify
    }
    else{
    console.error('RELOOK_CREATE_ROLES is undefined or empty');
  }
        
    
}
  getQueueId(){
      let parameter2 = {
        ParentObjectName: 'Group ',
        ChildObjectRelName: null,
        parentObjFields: ['Id','Name'],
        childObjFields: [],
        queryCriteria: ' where Name = \'' + 'UW Pool' + '\''
      } 

      getSobjDataWIthRelatedChilds({ params: parameter2 })
      .then(result => {
        if(result.parentRecord.Id !== undefined){
            console.log('Queue Record 2  :'+JSON.stringify(result));
            this.UWPoolId = result.parentRecord.Id;
        }
      })
        .catch(error => {
        console.log('QUEUE ERROR 101',error);
      });
  }
  
  @wire(getSobjectData,{params : '$teamHierParam'})
    teamHierHandler({data,error}){
        if(data){
            console.log('DATA IN APPL RELOOK :::: #125>>>>',data);
            if(data.parentRecords !== undefined ){
                this.userRole = data.parentRecords[0].EmpRole__c
                if(this.rolookCretors && this.rolookCretors.length>0){
                  this.rolookCretors.forEach(i=>{
                    if(i===this.userRole){
                      this.rolookInit=true;
                    }
                  })
                }
                if(this.rolookOps && this.rolookOps.length>0){
                  this.rolookOps.forEach(i=>{
                    if(i===this.userRole){
                      this.opsHide=true;
                    }
                  })
                }

                console.log('DATA IN APPL RELOOK :::: #128>>>>',this.userRole);
            }
                      
        }
        if(error){
            console.error('ERROR APPL RELOOK:::::::#133',error)
        }
    }

  fetchLoanDetails() {
    let loanDetParams = {
      ParentObjectName: "LoanAppl__c",
      ChildObjectRelName: "",
      parentObjFields: [
        "Id","Name","ReqLoanAmt__c","OwnerId","Stage__c","SubStage__c","Status__c","Applicant__c","RejectReason__c",
        "BrchCode__c"
      ],
      childObjFields: [],
      queryCriteria: " where Id = '" + this._recordId + "' limit 1"
    };
    getSobjectDataNonCacheable({ params: loanDetParams })
      .then((result) => {
    this.fetchRelookHistory();
    console.log(" LOAN Appl RESULT IN APPLICATION RELOOK LOAN DETAILS #258", result);
        if (
          result.parentRecords !== undefined &&
          result.parentRecords.length > 0
        ) {
          this.loanAmount = result.parentRecords[0].ReqLoanAmt__c;
          this.lanOwner = result.parentRecords[0].OwnerId;
          this.lanStage = result.parentRecords[0].Stage__c;
          this.lanSubStage = result.parentRecords[0].SubStage__c;
          this.lanStatus = result.parentRecords[0].Status__c;
          this.branchCode= result.parentRecords[0].BrchCode__c;
         
          if(this.lanStatus === 'Rejected'){
            this.rejectReason = result.parentRecords[0].RejectReason__c;
            this.getUwDecision(this.lanStatus);
          }
        }
      })
      .catch((error) => {
        console.log(" ERROR IN APPLICATION RELOOK LOAN DETAILS #194", error);
      });
  }

  getUwDecision(decsion) {
    //let decsion ='Rejected'
    let uwDecParams = {
      ParentObjectName: "UWDecision__c",
      ChildObjectRelName: "",
      parentObjFields: [
        "Id","LoanAppl__c","Decision__c","AddationalComm__c"
      ],
      childObjFields: [],
      queryCriteria: ' where LoanAppl__c = \'' + this._recordId + '\' AND Decision__c=\''+decsion+'\' order by CreatedDate desc limit 1'
    };
    getSobjectDataNonCacheable({ params: uwDecParams })
      .then((result) => {
        console.log(" RESULT FOR FIELD HISTORY IN APPLICATION RELOOK LOAN DETAILS #303", result);
        if (
          result.parentRecords !== undefined &&
          result.parentRecords.length > 0
        ) {
          this.rejectDecRemarks = result.parentRecords[0].AddationalComm__c;
        }
      })
      .catch((error) => {
        console.log("ERROR IN APPLICATION RELOOK LOAN DETAILS #311", error);
      });
  }

  getFieldHistory() {
    let field ='Status__c'
    let fieldHistParams = {
      ParentObjectName: "LoanAppl__History",
      ChildObjectRelName: "",
      parentObjFields: [
        "Id",
        "ParentId",
        "Field",
        "OldValue",
        "NewValue",
        "CreatedDate"
      ],
      childObjFields: [],
      queryCriteria: ' where ParentId = \'' + this._recordId + '\' AND Field=\''+field+'\' order by CreatedDate desc limit 1'
    };
    getSobjectDataNonCacheable({ params: fieldHistParams })
      .then((result) => {
        console.log(" RESULT FOR FIELD HISTORY IN APPLICATION RELOOK LOAN DETAILS #127", result);
        if (
          result.parentRecords !== undefined &&
          result.parentRecords.length > 0
        ) {
          this.oldVal = result.parentRecords[0].OldValue;
          this.newVal =result.parentRecords[0].NewValue;
        }
      })
      .catch((error) => {
        console.log(" ERROR IN APPLICATION RELOOK LOAN DETAILS #227", error);
      });
  }

  fetchRelookHistory() {
    let loanAppealType='Reject Relook'
    let loanAppealDetParams = {
      ParentObjectName: "LoanAppeal__c",
      ChildObjectRelName: "",
      parentObjFields: [
        "Id",
        "Name",
        "LoanAppl__c",
        "Status__c",
        "Comments__c",
        "RecordTypeId",
        "OwnerId",
        "Owner.Name",
        "CreatedDate",
        "DocDet__c",
        "UWRemarks__c","RecordType.Name"
      ],
      childObjFields: [],
      queryCriteria: ' where LoanAppl__c = \'' + this._recordId + '\' AND RecordType.Name = \'' + loanAppealType + '\' order by LastModifiedDate desc'
    };
    getSobjectDataNonCacheable({ params: loanAppealDetParams })
      .then((result) => {
        console.log(" RESULT IN APPLICATION RELOOK HISTORY DETAILS #163", result);
        if (
          result.parentRecords !== undefined &&
          result.parentRecords.length > 0
        ) {
         this.relookData = result.parentRecords;
         this.relookData.forEach(item=>{
            if(item.DocDet__c === undefined){
                item.disableView=true;
            }
            if(!(item.Status__c === 'New' && item.Owner.Name === 'UW Pool' && !this.opsHide)){
                item.disableClaim=true
            }
    
            const dateTime1 = new Date(item.CreatedDate);
            const formattedDate1 = formattedDateTimeWithoutSeconds(dateTime1); 
            const dateOfIntiation1 = `${formattedDate1}`;
            item.initatedDate = dateOfIntiation1;

    

         })
         this.comments=result.parentRecords[0].Comments__c;
         this.docDetId=result.parentRecords[0].DocDet__c;
         this.loanAppealId=result.parentRecords[0].Id;
         this.loanAppealStatus=result.parentRecords[0].Status__c;
         this.loanAppealOwner=result.parentRecords[0].OwnerId;
         if(this.loanAppealOwner === CURRENTUSERID){
          this.showDecisionBts=true;
        }

         console.log(" RESULT IN APPLICATION RELOOK HISTORY DETAILS #163",  this.relookData);
        }
      })
      .catch((error) => {
        console.log(" ERROR IN APPLICATION RELOOK LOAN DETAILS #272", error);
      });
  }


  getDeviations() {
    let deviDetParams = {
      ParentObjectName: "Deviation__c",
      ChildObjectRelName: "",
      parentObjFields: [
        "Id",
        "Name",
        "LoanAppln__c",
        "BRE__c",
        "BRE__r.IsLatest__c",
        "LoanAppeal__c"
      ],
      childObjFields: [],
      queryCriteria: ' where LoanAppln__c = \'' + this.recordId + '\' AND BRE__r.IsLatest__c = true AND LoanAppeal__c= null order by CreatedDate desc'
    };
    getSobjectDataNonCacheable({ params: deviDetParams })
      .then((result) => {
        this.deviationRec=[];
        console.log(" RESULT IN APPLICATION RELOOK DEVIATION DATA #291", result);
        if (
          result.parentRecords !== undefined &&
          result.parentRecords.length > 0
        ) {
            this.deviationRec = result.parentRecords; 
         console.log(" RESULT IN APPLICATION RELOOK DEVIATION DATA #298",  result.parentRecords);
        }
      })
      .catch((error) => {
        console.log(" ERROR IN APPLICATION RELOOKDEVIATION DATA #302", error);
      });
  }


  handleInputChange(event) {
    this.remarks = event.detail.value.toUpperCase();
  }
  handleTextAreaChange(event){
    this.decComments = event.detail.value.toUpperCase();
  }

  @track runBre=false;
  handleRelook() {
    this.enableFields = false;
    this.hideAttachButton=false;
  }
  handleRunBre(){
    this.runBre=true;
  }

  //LAK-9775 Pop Up modal used for RUN BRE Button
  handleCloseBre(event){
    this.runBre=event.detail;
  }
  closeModal(){
    this.claimAppeal=false;
    this.runBre=false;
    this.decision=null
    this.openModal=false;
    this.deviData=[];
    this.loanAppealItemList=[];
  }
  handleClaim(event){
    this.claimAppeal=true;
    let label = event.target.label;
    this.claimApplId = event.target.dataset.appealid;
    console.log('claimApplId:::::333',this.claimApplId, label);
    if(label==='Claim'){
      this.decision=label;
    }
   
    
  }

  handleAppealUpdate(){
    let applClaimList=[];
    let obj={};
    obj.sobjectType='LoanAppeal__c';
    obj.Id = this.claimApplId;
    obj.Status__c= 'In Progress';
    obj.OwnerId = CURRENTUSERID;
    console.log('objList:::::271',obj);
    applClaimList.push(obj);
    if(applClaimList){
        this.upsertData(applClaimList);
    }
  }


  handleSubmit() {
    this.showSpinner =true;
    let isInputCorrect = this.validateForm();
    if(isInputCorrect){    
    const fields = [];
    let obj ={}
    obj.sobjectType='LoanAppeal__c';
    obj[COMMENTS_FIELD.fieldApiName] = this.remarks;
    obj[LOAN_APPL_FIELD.fieldApiName] = this.recordId;
    obj[STATUS_FIELD.fieldApiName] = "New";
    obj[OWNER_FIELD.fieldApiName] = this.UWPoolId;
    obj[DOCDET_ID_FIELD.fieldApiName]=this.docDetId;
    obj[RECORD_TYPE_FIELD.fieldApiName]=this.recordTypeId;
    fields.push(obj);

    if(fields){
        console.log('objList:::::271',fields);
        this.upsertData(fields);
      }
    }else{
        this.showSpinner=false;
        this.showToastMessage('Error', "Please fill the required fields", 'error', 'sticky');
    }
  }

get appelDecision(){
  return this.decision === 'Approve' || this.decision === 'Reject' || this.decision === 'Forward';
}

// handleForward(event){
//   let label = event.target.label;
//   this.decision=label;
 
// }
  handleDecision(event){
    let label= event.target.label
    if(label === 'Approve'){
        this.decision='Approve';
    }
    else if(label === 'Reject'){
        this.decision='Reject';
    }else if(label === 'Forward'){
        this.decision='Forward';
    }
    
  }

  handleAppealDecision(){
    let isInputCorrect = this.validateForm();
    if(isInputCorrect){
      if(this.decision==='Approve' || this.decision==='Reject'){
        let applUpdateList=[];
        let obj={};
        obj.sobjectType='LoanAppeal__c';
        obj.Status__c = this.decision;
        obj.Id = this.loanAppealId;
        obj.UWRemarks__c= this.decComments;
        console.log('objList:::::271',obj);
        applUpdateList.push(obj);
        if(applUpdateList){
          this.createLoanAppealItem();
            this.upsertData(applUpdateList);
        }
      }else{
        let applFwdList=[];
        let obj={};
        obj.sobjectType='LoanAppeal__c';
        obj.Id = this.loanAppealId;
        obj.UWRemarks__c= this.decComments;
        obj.OwnerId = this.lookupId;
        console.log('objList:::::421',obj);
        applFwdList.push(obj);
        if(applFwdList){
          this.createLoanAppealItem();
            this.upsertData(applFwdList);
        }
      }
     
    }else{
      this.showToastMessage('Error', 'Please fill the required fields', 'error', 'sticky');
    }
  }

  createLoanAppealItem(){
    let appealItemList=[];
    let obj={};
    obj.sobjectType='LoanAppealItem__c';
    // obj.Status__c = this.decision;
    obj.LoanAppeal__c = this.loanAppealId;
    if(this.decision === 'Forward'){
      obj.Recomended_To__c = this.lookupId;
    }
    obj.Comments__c= this.decComments;
    console.log('objList:::::606',obj);
    appealItemList.push(obj);
    if(appealItemList){
        this.upsertData(appealItemList);
    }
  }
@track lookUpRec;
@track lookupId;
@track forwardTodUser;
  handleLookupFieldChange(event) {
    if (event.detail) {
      this.lookUpRec= event.detail;
      this.lookupId = event.detail.id;
      this.forwardTodUser=event.detail.mainField;
      
    } 
    console.log('lookUpRec::::::',this.lookUpRec, this.lookupId);
}

  updateLoanAppl(){
    let arr=[];
    const objLan = {}
    objLan.sobjectType='LoanAppl__c';
    objLan.Id = this.recordId;
    objLan.Status__c = this.oldVal ? this.oldVal : 'In Progress';
    arr.push(objLan);
    if(arr){
      this.upsertLANData(arr);
    }
   
  }

  upsertLANData(obj){
    if(obj){   
    console.log('LAN Records update ##534', obj); 
    
    upsertMultipleRecord({ params: obj })
    .then(result => {     
        console.log('LAN Records update ##538', result);
        this.showToastMessage('Success', "LOAN APPLICATION STATUS UPDATED SUCCESSFULLY", 'success', 'sticky');
        this.showSpinner =false;
        this.enableFields = true;
        this.fetchLoanDetails();
        this.getFieldHistory();
        this.navigateToLoanPage();
        
    })
    .catch(error => {
      this.showSpinner = false;
      console.log("APPL RELOOK ERROR:::::447", error);
    })
  }
  }

  spinnerStatus(event) {
     this.hideAttachButton = event.detail;
     console.log('this.hideAttachButton::::',this.hideAttachButton);
     this.refreshDocComp();
  }

  get clearFileList(){
   return this.hideAttachButton
  }

  refreshDocComp() {
    this.showSpinner = false;
    let child = this.template.querySelector('c-upload-docs-reusable-component');
    child.clearFiles();
  }
  handleDocumentView(){
    this.viewReport =true;
    this.hasDocumentId = true;
  }

  handlePreview(event){
    console.log('event in preview:::::',event);
    this.viewTableReport =true;
    this.hasDocumentId = true;
    this.documentDetailId= event.currentTarget.dataset.documentid;
  }

  @track openModal;
  handleHistoryPreview(event){
    console.log('event in preview:::::',event);
    let appealId = event.target.dataset.appealid;
    this.getDeviationsLoanAppeal(appealId);
    this.getLoanAppealItem(appealId);
    this.openModal =true;
    this.showSpinnerModal=true;
    // this.hasDocumentId = true;
    // this.documentDetailId= event.currentTarget.dataset.documentid;
  }

  handleCloseModalEvent() {
    this.viewReport=false;
    this.viewTableReport=false;
}

  fromUploadDocsContainer(event) {
    let ev = event.detail;
    console.log("fromUploadDocsContainer::::", JSON.stringify(ev),'ev.docDetailId',ev.docDetailId);
    this.docDetId = ev.docDetailId;
  }
  handleeventAfterUpload(event) {}


  upsertData(obj){
    if(obj){   
    console.log('Document Detail Records update ##334', obj); 
    
    upsertMultipleRecord({ params: obj })
    .then(result => {     
        console.log('Document Detail Records update ##1508', result);
       
        this.enableFields = true;
        let deviArr=[]
        if(this.decision==='Approve'){
            this.updateLoanAppl();
           this.deviationRec.forEach(i=>{
                let devobj={};
                devobj.sobjectType='Deviation__c';
                devobj.Id=i.Id; 
                devobj.LoanAppeal__c = this.loanAppealId;
                deviArr.push(devobj);
            })
            console.log('DEVI REC update ##703', deviArr);
           this.upsertDataDeviation(deviArr);
           this.showToastMessage('Success', "LOAN APPEAL APPROVED SUCCESSFULLY", 'success', 'sticky');
        }
        else if(this.decision==='Reject'){
          this.deviationRec.forEach(i=>{
            let devobj={};
            devobj.sobjectType='Deviation__c';
            devobj.Id=i.Id; 
            devobj.LoanAppeal__c = this.loanAppealId;
            deviArr.push(devobj);
        })
        console.log('DEVI REC update ##716', deviArr);
       this.upsertDataDeviation(deviArr);
            this.showToastMessage('Success', "LOAN APPEAL REJECTED SUCCESSFULLY", 'success', 'sticky');
        }
        else if(this.decision === 'Claim'){
          this.claimAppeal=false;
          this.showToastMessage('Success', "LOAN APPEAL Claimed SUCCESSFULLY", 'success', 'sticky');
        }
        else if(this.decision ==='Forward'){
          this.showToastMessage('Success', "LOAN APPEAL FORWARDED TO "+this.forwardTodUser+" SUCCESSFULLY", 'success', 'sticky');
          this.navigateToLoanPage();
        }
         else{
            this.showToastMessage('Success', "LOAN APPEAL RECORD CREATED SUCCESSFULLY", 'success', 'sticky');
        }
        this.decision='';
        this.forwardTodUser='';
        this.fetchRelookHistory();
        this.showSpinner =false;
        
    })
    .catch(error => {
      this.showSpinner = false;
      console.log("APPL RELOOK ERROR:::::345", error);
    })
  }
  }


  upsertDataDeviation(obj){
    if(obj){   
    console.log('DEVIATION Records update ##436', obj); 
    
    upsertMultipleRecord({ params: obj })
    .then(result => {     
        console.log('Document Detail Records update ##440', result);
        this.showToastMessage('Success', "DEVIATION RECORDS UPDATED SUCCESSFULLY", 'success', 'sticky');
        this.showSpinner =false;
        
    })
    .catch(error => {
      this.showSpinner = false;
      console.log("APPL RELOOK ERROR:::::447", error);
    })
  }
  }

  validateForm() {
    let isValid = true;
   
    if(!this.hideAttachButton){
      isValid = false;
      this.showToastMessage('Error', 'Please Upload Document', 'error', 'sticky');
    }

    this.template.querySelectorAll("lightning-textarea").forEach((element) => {
      if (element.reportValidity()) {
        //console.log('element passed lightning input');
      } else {
        isValid = false;
      }
    });
    return isValid;
  }

  @track deviData=[];
  getDeviationsLoanAppeal(appealId) {
    let deviDetParams = {
      ParentObjectName: "Deviation__c",
      ChildObjectRelName: "",
      parentObjFields: [
        "Id",
        "Name",
        "LoanAppln__c",
        "BRE__c",
        "BRE__r.IsLatest__c",
        "LoanAppeal__c","Devia_Desrp__c"
      ],
      childObjFields: [],
      queryCriteria: ' where LoanAppeal__c = \'' + appealId + '\'  order by CreatedDate desc'
    };
    getSobjectDataNonCacheable({ params: deviDetParams })
      .then((result) => {
        this.deviationRec=[];
        this.showSpinnerModal=false;
        console.log(" RESULT IN APPLICATION RELOOK DEVIATION DATA #808", result);
        if (
          result.parentRecords !== undefined &&
          result.parentRecords.length > 0
        ) {
          
            this.deviData = result.parentRecords; 
         console.log(" RESULT IN APPLICATION RELOOK DEVIATION DATA #814",  result.parentRecords);
        }
      })
      .catch((error) => {
        this.showSpinnerModal=false;
        console.log(" ERROR IN APPLICATION RELOOKDEVIATION DATA #302", error);
      });
  }
@track showSpinnerModal;
  @track loanAppealItemList=[];
  getLoanAppealItem(appealId){
    let deviDetParams = {
      ParentObjectName: "LoanAppealItem__c",
      ChildObjectRelName: "",
      parentObjFields: [
        "Id",
        "Name",
        "LoanAppeal__c",
        "Comments__c",
        "Recomended_To__c",
        "Recomended_To__r.Name","CreatedDate"
      ],
      childObjFields: [],
      queryCriteria: ' where LoanAppeal__c = \'' + appealId + '\'  order by CreatedDate desc'
    };
    getSobjectDataNonCacheable({ params: deviDetParams })
      .then((result) => {
        this.deviationRec=[];
        this.showSpinnerModal=false;
        console.log(" RESULT IN APPLICATION RELOOK APPEAL ITEM DATA #862", result);
        if (
          result.parentRecords !== undefined &&
          result.parentRecords.length > 0
        ) {
         
            this.loanAppealItemList = result.parentRecords; 
            this.loanAppealItemList.forEach(item=>{
              const dateTime1 = new Date(item.CreatedDate);
              const formattedDate1 = formattedDateTimeWithoutSeconds(dateTime1); 
              const dateOfIntiation1 = `${formattedDate1}`;
              item.initatedDate = dateOfIntiation1;
  
      
  
           })
         console.log(" RESULT IN APPLICATION RELOOK APPEAL ITEM DATA #878",  result.parentRecords);
        }
      })
      .catch((error) => {
        this.showSpinnerModal=false;
        console.log(" ERROR IN APPLICATION APPEAL ITEM DATA #882", error);
      });
  }
  navigateToLoanPage() {
    console.log('navigateToListView called ');
    setTimeout(() => {
       location.reload();
    }, 2000
    )
  
   
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