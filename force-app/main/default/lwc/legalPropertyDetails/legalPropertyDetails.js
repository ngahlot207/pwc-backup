import { LightningElement,api,track, wire } from 'lwc';
import { getObjectInfo, getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";

import FIELD2_FIELD from '@salesforce/schema/LoanAppl__c.OwnerId';
import CASE_OBJECT from "@salesforce/schema/Case";
import { refreshApex } from '@salesforce/apex';
import {updateRecord ,getRecord} from "lightning/uiRecordApi";
import {
    subscribe,
    publish,
    MessageContext,
    unsubscribe,
    releaseMessageContext,
    createMessageContext
  } from "lightning/messageService";
import updateData from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import DOC_FIELD from "@salesforce/schema/DocDtl__c.Id";
import CASE_FIELD from "@salesforce/schema/DocDtl__c.Case__c";

import APP_ASSET_FIELD from "@salesforce/schema/ApplAsset__c.Id";
import ISMARKEABLE_FIELD from "@salesforce/schema/ApplAsset__c.Is_the_title_clear_markateble__c";

import Legal_Property_Case_Update from '@salesforce/label/c.Legal_Property_Case_Update';
import Legal_Property_Future_Date from '@salesforce/label/c.Legal_Property_Future_Date';
import Legal_Property_File_Req from '@salesforce/label/c.Legal_Property_File_Req';
import LOSSAVEBUTTONDISABLE from "@salesforce/messageChannel/LosSaveButtonDisable__c";
import Id from "@salesforce/user/Id";
export default class LegalPropertyDetails extends LightningElement {

    label = {
        Legal_Property_Case_Update,
        Legal_Property_Future_Date,
        Legal_Property_File_Req
    }
    @api substage;
    @track showSpinner;
    @api stage;
    @track caseId;
    @api recordId
    @track fileSizeMsz='Allowed File Types are : pdf, jpg, jpeg, png'
    @track allowedFilFormat = [".jpg", ".jpeg", ".pdf",".png", ".pneg"];
    @track filterCondnForlegal;
    @track filterCondnForVess;
    @track filterCondnForTSR;
    @track legalTab=false;
    @track TSRTab=false;
    @track vettingTab=false;
    @api layoutSize;
    @track disableMode
    @api hasEditAccess;
    @track WaiveCPV=[];
    @track wrapLegalCaseObj={}
    @track wrapTSRCaseObj={}
    @track wrapVettingCaseObj={}
    @track hideAttachButton
    @track requiredforlegal=false;
    @track requiredForTSR=false;
    @track requiredForVetting=false;
    @track requiredforlegalforNo=false;
    subscription = null;
    @api get loanAppId() {
        return this._loanAppId;
      }
      set loanAppId(value) {
        this._loanAppId = value;
        console.log('this._loanAppId'+this._loanAppId)
        this.setAttribute("loanAppId", value);
    }
    
    
    @api get applicantId() {
        return this._applicantId;
      }
      set applicantId(value) {
        this._applicantId = value;
        console.log('this._applicantId'+this._applicantId)
        this.setAttribute("applicantId", value);
    }
    @track docCategory;
    @track docType;
    @track docSubType;
    @api _tabName;
    @api get tabName() {
        return this._tabName;
    }
    set tabName(value) {
        
        this._tabName = value 
        console.log('lllll'+this._tabName)
        if(this._tabName == 'Legal'){
            this.docCategory='Case Documents'
            this.docType='Legal Verification'
            this.docSubType='Legal Report'
            this.legalTab=true
            this.TSRTab=false
            this.vettingTab=false
        }else if(this._tabName == 'TSR'){
            this.docCategory='Case Documents'
            this.docType='TSR Verification'
            this.docSubType='TSR Report'
            this.legalTab=false
            this.TSRTab=true
            this.vettingTab=false
        }else if(this._tabName == 'Vetting'){
            this.docCategory='Case Documents'
            this.docType='Vetting Verification'
            this.docSubType='Vetting Report'
            this.legalTab=false
            this.TSRTab=false
            this.vettingTab=true
        } 
            
    }
    userId = Id;
    @api get currentTabId() {
        return this._currentTabId;
      }
      set currentTabId(value) {
        this._currentTabId = value;
        console.log('this._currentTabId'+this._currentTabId)
        this.setAttribute("currentTabId", value);
        this.handleRecordIdChange();
        this.getAssetAppliDetails()
        this.handleteamHierIdChange();

    }

    disconnectedCallback() {
        this.unsubscribeMC();
        releaseMessageContext(this.context);
    }
    unsubscribeMC() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    handleRecordIdChange() {
       let tempParams = this.pramForCaseLegal;
        tempParams.queryCriteria =' where ApplAssetId__c= \'' + this._currentTabId + '\' AND RecordType.name = \'Legal\''
        this.pramForCaseLegal = { ...tempParams };
        let tempParams1 = this.pramForCaseTSR;
        tempParams1.queryCriteria =' where ApplAssetId__c= \'' + this._currentTabId + '\' AND RecordType.name = \'TSR\''
        this.pramForCaseTSR = { ...tempParams1 };
        let tempParams2 = this.pramForCaseVetting;
        tempParams2.queryCriteria =' where ApplAssetId__c= \'' + this._currentTabId + '\' AND RecordType.name = \'Vetting\''
        this.pramForCaseVetting = { ...tempParams2 };
    }
    @track showDeleteIcon;
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objInfo;
   
    @track userRole;
    @track teamHierParam = {
        ParentObjectName: 'TeamHierarchy__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id','EmpRole__c','Employee__c'],
        childObjFields: [],
        queryCriteria: ''
        }

    handleteamHierIdChange() {
        let tempParams = this.teamHierParam;
        tempParams.queryCriteria = ' where Employee__c = \'' + this.userId + '\' limit 1' ;
        this.teamHierParam = { ...tempParams };
    
    }
      @wire(getSobjectData,{params : '$teamHierParam'})
      teamHierHandler({data,error}){
          if(data){
              if(data.parentRecords !== undefined ){
                  this.userRole = data.parentRecords[0].EmpRole__c   
              }
                        
          }
          if(error){
              console.error('ERROR CASE DETAILS:::::::#499',error)
          }
      }

    ownerIdOfLoan;
    @wire(getRecord, { recordId: '$_loanAppId', fields: [FIELD2_FIELD] })
    wiredRecord({ error, data }) {
        console.log('??')
        this.showSpinner=true;
        if (data) {
           console.log('datadatadatadata'+JSON.stringify(data))
           this.ownerIdOfLoan=data.fields.OwnerId.value;
           console.log('data.fields.OwnerId.value'+data.fields.OwnerId.value)
           setTimeout(() => {
            console.log('this.label.Legal_Property_Case_Update'+this.ownerIdOfLoan)
            if((this.userId==this.ownerIdOfLoan) && (this.hasEditAccess === true || (this.stage=='Post Sanction' && (this.substage=='Data Entry' || this.substage=='Ops Query' || this.substage=='UW Approval'))) ){
                this.disableMode = false;
                this.hasEditAccess=true;
                this.showDeleteIcon=true;
                const payload = {
                    disableSaveButton: false
                };
                console.log(" Published Event>", JSON.stringify(payload));
                publish(this.MessageContext, LOSSAVEBUTTONDISABLE, payload);
            } else if(this.userRole === 'LHM' || this.userRole==='THM'){
                this.disableMode = false;
                this.hasEditAccess=true;
                this.showDeleteIcon=true;
                const payload = {
                    disableSaveButton: false
                };
                console.log(" Published Event 206 in LEGAL PROPTTY DETAILS>>>", JSON.stringify(payload));
                publish(this.MessageContext, LOSSAVEBUTTONDISABLE, payload);
            }
            else{
                const payload = {
                    disableSaveButton: true
                };
                console.log(" Published Event>", JSON.stringify(payload));
                publish(this.MessageContext, LOSSAVEBUTTONDISABLE, payload);
                this.disableMode = true;
                this.showDeleteIcon=false;
            }
            this.showSpinner=false;
        }, 1000);
        } else if (error) {
            // Handle error
            console.log('errorerrorerrorerrorerrorerror'+error)
            
        }
    }
    
    connectedCallback(){
       
        this.hideAttachButton=true
        
        
        
       /* if(this.hasEditAccess === false){
            this.disableMode = true;
            this.showDeleteIcon=false;
      }else{
             this.disableMode = false;
             this.showDeleteIcon=true;
      }*/
      this.scribeToMessageChannel();
        console.log('this.requiredforlegalconneeee'+this.requiredforlegal)
    }
    @track pramForCaseLegal={
        ParentObjectName:'Case',
        ChildObjectRelName:'',
        parentObjFields:[  'Id','WaiveCPV__c','ApplAssetId__r.CityId__c','ReportResult__c','WaiverReason__c','AllPropertyOwnersArePartOfLoanStru__c','IsTheTitleClearNdMarketable__c','Remarks_regarding_the_case__c','Date_of_Report__c','AccountId','Account.Name','DateofInitiation__c'],
        childObjFields:[ ],
        queryCriteria: ' where ApplAssetId__c= \'' + this._currentTabId + '\' AND RecordType.name = \'Legal\''
    }
    @track pramForCaseTSR={
        ParentObjectName:'Case',
        ChildObjectRelName:'',
        parentObjFields:[  'Id','WaiveCPV__c','ApplAssetId__r.CityId__c','ReportResult__c','WaiverReason__c','IsTSRwaived__c','AccountId','Remarks_regarding_the_case__c','Date_of_Report__c','TSR_EC_for_no_of_Yrs__c','DateofInitiation__c'],
        childObjFields:[ ],
        queryCriteria: ' where ApplAssetId__c= \'' + this._currentTabId + '\' AND RecordType.name = \'TSR\''
    }
    @track pramForCaseVetting={
        ParentObjectName:'Case',
        ChildObjectRelName:'',
        parentObjFields:[  'Id','WaiveCPV__c','ApplAssetId__r.CityId__c','WaiverReason__c','Is_Vetting_waived__c','IsTSRwaived__c','AccountId','ReportResult__c','Remarks_regarding_the_case__c','Date_of_Report__c','TSR_EC_for_no_of_Yrs__c','DateofInitiation__c'],
        childObjFields:[ ],
        queryCriteria: ' where ApplAssetId__c= \'' + this._currentTabId + '\' AND RecordType.name = \'Vetting\''
    }
    @track legalRecordTypeId;
    @track TSRRecordTypeId;
    @track vettingRecordTypeId;
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    getObjectInfo({ error, data }) {
        if (data) {
        console.log("DATA in RECORD TYPE ID IN TECHINCAL PROP DET #332", data);
        for (let key in data.recordTypeInfos) {
            let recordType = data.recordTypeInfos[key];
            console.log("recordTypeId.value>>>>>", recordType.name);
            if (recordType.name === "Legal") {
            this.legalRecordTypeId = key;
            this.wrapLegalCaseObj.RecordTypeId=this.legalRecordTypeId;
            //refreshApex(this._wireforOptions)
            console.log('this.legalRecordTypeId'+this.legalRecordTypeId)
            }
            else if (recordType.name === "TSR") {
                this.TSRRecordTypeId = key;
                this.wrapTSRCaseObj.RecordTypeId=this.TSRRecordTypeId;
                console.log(' this.TSRRecordTypeId'+this.TSRRecordTypeId)
            }
            else if (recordType.name === "Vetting") {
                this.vettingRecordTypeId = key;
                this.wrapVettingCaseObj.RecordTypeId=this.vettingRecordTypeId;
                console.log('this.vettingRecordTypeId'+this.vettingRecordTypeId)
            }
        }
        } else if (error) {
        console.error("Error fetching record type Id", error);
        }
    }
    generatePicklist(data) {
        return data.values.map(item => ({ "label": item.label, "value": item.value }))
    }
    _wireForLeaglRecType;
    @track requLegForpen=false
    @track caseAccName
    @track parentRecForLegal;
    @track caseidyes=true
    @track valOfStatusLegal
    @track valOfStatusYesOrNo
    @wire(getSobjectData,{params:'$pramForCaseLegal'})
    caseDataForLeaglRecType(wireForLeaglRecType) {
        const { data, error } = wireForLeaglRecType;
        this._wireForLeaglRecType = wireForLeaglRecType;
        this.parentRecForLegal={}
        if (data) {
            if(data.parentRecords){
                this.showSpinner = false;
                
                console.log('wiredApplicantRecData>>>>>>1',JSON.stringify(data.parentRecords[0]));
                this.parentRecForLegal=JSON.parse(JSON.stringify(data.parentRecords[0])); 
                this.wrapLegalCaseObj.Id=this.parentRecForLegal.Id
                if(typeof this.parentRecForLegal.Remarks_regarding_the_case__c !== 'undefined'){
                    this.parentRecForLegal.Remarks_regarding_the_case__c=this.parentRecForLegal.Remarks_regarding_the_case__c.toUpperCase();
                }
                if(this._tabName == 'Legal'){
                    this.caseId=this.parentRecForLegal.Id
                    this.caseidyes=true
                    console.log('this.caseId'+this.caseId)
                    console.log('MMMMMMMMMMMM3'+this.template.querySelector('c-show-case-document'))
                    setTimeout(() => {
                        this.template.querySelector('c-show-case-document').handleFilesUploaded();
                    }, 1000);
                    
                   
                }
                console.log('this.caseId'+this.caseId)
                
                if(typeof this.parentRecForLegal.WaiveCPV__c !== 'undefined'){
                    this.valOfStatusYesOrNo=this.parentRecForLegal.WaiveCPV__c
                    this.wrapLegalCaseObj.WaiveCPV__c=this.parentRecForLegal.WaiveCPV__c;
                }
               
                if(typeof this.parentRecForLegal.ReportResult__c !== 'undefined'){
                    this.valOfStatusLegal=this.parentRecForLegal.ReportResult__c
                    this.wrapLegalCaseObj.ReportResult__c=this.parentRecForLegal.ReportResult__c;
                }
                if(typeof this.parentRecForLegal.WaiveCPV__c !== 'undefined' && this.parentRecForLegal.WaiveCPV__c=='Yes'){
                    
                    this.requiredforlegal=true
                    this.requiredforlegalforNo=false
                }else if(typeof this.parentRecForLegal.WaiveCPV__c !== 'undefined' && this.parentRecForLegal.WaiveCPV__c=='No'){
                    this.requiredforlegal=false
                    this.requiredforlegalforNo=true
                }else{
                    this.requiredforlegal=false
                    this.requiredforlegalforNo=false
                }
                if(typeof this.parentRecForLegal.WaiveCPV__c !== 'undefined' && this.parentRecForLegal.WaiveCPV__c=='No' && typeof this.parentRecForLegal.ReportResult__c!=='undefined' && this.parentRecForLegal.ReportResult__c!='Pending'){
                    this.requLegForpen=true
                }else{
                    this.requLegForpen=false
                }
                console.log('this.requiredforlegal'+this.requiredforlegal)
                
            }
            
            
        } else if (error) {
            //this.showSpinner = false;
            console.log(error);
        }
    }
    _wireForTSRRecType;
    @track parentRecForTSR;
    @track caseAccNameTSR
    @track valOfStatusTSRYesOrNo
    @track valOfStatusTSR
    @track requiredForTSRforNo=false
    @track requiredForTSRforpen=false
    @wire(getSobjectData,{params:'$pramForCaseTSR'})
    caseDataForTSRRecType(wireForTSRRecType) {
        const { data, error } = wireForTSRRecType;
        this._wireForTSRRecType = wireForTSRRecType;
        this.parentRecForTSR={}
        if (data) {
            if(data.parentRecords){
                this.showSpinner = false;
                this.parentRecForTSR=JSON.parse(JSON.stringify(data.parentRecords[0]));
                if(this._tabName == 'TSR'){
                    this.caseId=this.parentRecForTSR.Id
                    this.caseidyes=true
                    console.log('this.caseId'+this.caseId)
                    console.log('MMMMMMMMMMMM2'+this.template.querySelector('c-show-case-document'))
                    setTimeout(() => {
                        this.template.querySelector('c-show-case-document').handleFilesUploaded();
                    }, 1000);
                }
                this.wrapTSRCaseObj.Id=this.parentRecForTSR.Id
                if(typeof this.parentRecForTSR.IsTSRwaived__c !== 'undefined'){
                    this.valOfStatusTSRYesOrNo=this.parentRecForTSR.IsTSRwaived__c 
                    this.wrapTSRCaseObj.IsTSRwaived__c=this.parentRecForTSR.IsTSRwaived__c 
                }
                if(typeof this.parentRecForTSR.ReportResult__c !== 'undefined'){
                    this.valOfStatusTSR=this.parentRecForTSR.ReportResult__c 
                    this.wrapTSRCaseObj.ReportResult__c=this.parentRecForTSR.ReportResult__c 
                }
               if(typeof this.parentRecForTSR.IsTSRwaived__c !== 'undefined' && this.parentRecForTSR.IsTSRwaived__c=='Yes'){
                    this.requiredForTSR=true
                    this.requiredForTSRforNo=false
                }else if(typeof this.parentRecForTSR.IsTSRwaived__c !== 'undefined' && this.parentRecForTSR.IsTSRwaived__c=='No'){
                    this.requiredForTSR=false
                    this.requiredForTSRforNo=true
                }else{
                    this.requiredForTSR=false
                    this.requiredForTSRforNo=false
                }
                if(typeof this.parentRecForTSR.IsTSRwaived__c !== 'undefined' && this.parentRecForTSR.IsTSRwaived__c=='No' && typeof this.parentRecForTSR.ReportResult__c!=='undefined' && this.parentRecForTSR.ReportResult__c!='Pending'){
                    this.requiredForTSRforpen=true
                }else{
                    this.requiredForTSRforpen=false
                }


                if(typeof this.parentRecForTSR.Remarks_regarding_the_case__c !== 'undefined'){
                    this.parentRecForTSR.Remarks_regarding_the_case__c=this.parentRecForTSR.Remarks_regarding_the_case__c.toUpperCase();
                }
                
                console.log('wiredApplicantRecData>>>>>>2',JSON.stringify( this.parentRecForTSR));
            }
           
        } else if (error) {
            console.log(error);
        }
    }
    _wireForVettingRecType
    @track parentRecForVetting
    @track caseAccNameVess
    valOfStatusVessOrNo
    valOfStatusVess
    requiredForVettingForNo=false
    requiredForVeeforpen=false
    @wire(getSobjectData,{params:'$pramForCaseVetting'})
    caseDataForVettingRecType(wireForVettingRecType) {
        const { data, error } = wireForVettingRecType;
        this._wireForVettingRecType = wireForVettingRecType;
        this.parentRecForVetting={}
        console.log('JSON.stringify(data.parentRecords[0])'+data)
        if (data) {
            if(data.parentRecords){
                this.parentRecForVetting=JSON.parse(JSON.stringify(data.parentRecords[0])); 
                this.wrapVettingCaseObj.Id=this.parentRecForVetting.Id
                this.showSpinner = false;
                if(this._tabName == 'Vetting'){
                    this.caseId=this.parentRecForVetting.Id
                    this.caseidyes=true
                    console.log('this.caseId'+this.caseId)
                    console.log('MMMMMMMMMMMM1'+this.template.querySelector('c-show-case-document'))
                    setTimeout(() => {
                        this.template.querySelector('c-show-case-document').handleFilesUploaded();
                    }, 1000);
                    
                }
                
        
                if(typeof this.parentRecForVetting.Is_Vetting_waived__c !== 'undefined'){
                    this.valOfStatusVessOrNo=this.parentRecForVetting.Is_Vetting_waived__c 
                    this.wrapVettingCaseObj.Is_Vetting_waived__c=this.parentRecForVetting.Is_Vetting_waived__c 
                }
                if(typeof this.parentRecForVetting.ReportResult__c !== 'undefined'){
                    this.valOfStatusVess=this.parentRecForVetting.ReportResult__c
                     this.wrapVettingCaseObj.ReportResult__c=this.parentRecForVetting.ReportResult__c  
                }
                if(typeof this.parentRecForVetting.Is_Vetting_waived__c !== 'undefined' && this.parentRecForVetting.Is_Vetting_waived__c=='Yes'){
                    this.requiredForVetting=true
                    this.requiredForVettingForNo=false
                }else if(typeof this.parentRecForVetting.Is_Vetting_waived__c !== 'undefined' && this.parentRecForVetting.Is_Vetting_waived__c=='No'){
                    this.requiredForVetting=false
                    this.requiredForVettingForNo=true
                }
                else{
                    this.requiredForVetting=false
                    this.requiredForVettingForNo=false
                }
                if(typeof this.parentRecForVetting.Is_Vetting_waived__c !== 'undefined' && this.parentRecForVetting.Is_Vetting_waived__c=='No' && typeof this.parentRecForVetting.ReportResult__c!=='undefined' && this.parentRecForVetting.ReportResult__c!='Pending'){
                    this.requiredForVeeforpen=true
                }else{
                    this.requiredForVeeforpen=false
                }




                if(typeof this.parentRecForVetting.Remarks_regarding_the_case__c !== 'undefined'){
                    this.parentRecForVetting.Remarks_regarding_the_case__c=this.parentRecForVetting.Remarks_regarding_the_case__c.toUpperCase();
                }
            
                
                console.log('wiredApplicantRecData>>>>>>3',JSON.stringify( this.parentRecForVetting));
            }
                
        } else if (error) {
            console.log(error);
        }
    }
    productType;
    getAssetAppliDetails() {
        let AssetDetParam = {
          ParentObjectName: "ApplAsset__c",
          ChildObjectRelName: "",
          parentObjFields: ["Id", "CityId__c", "LoanAppln__r.Product__c","City__c"],
          childObjFields: [""],
          queryCriteria: " where Id = '" + this._currentTabId + "' limit 1"
        };
        getSobjectData({ params: AssetDetParam })
          .then((result) => {
            console.log("RESULT IN SUB TAB PROP #71", result);
            if (result) {
                var assetAppData=JSON.parse(JSON.stringify(result.parentRecords[0])); 
                console.log('result'+assetAppData.CityId__c)
                console.log('result'+assetAppData.LoanAppln__r.Product__c)
                this.productType=assetAppData.LoanAppln__r.Product__c
                //LocationMaster__c = '" + assetAppData.CityId__c + "'"
              /*  this.filterCondnForlegal="LocationMaster__c = '" + assetAppData.CityId__c + "' AND IsActive__c =true AND ProductType__c='"+assetAppData.LoanAppln__r.Product__c+"' AND AgencyType__c INCLUDES ('Legal')"
                this.filterCondnForVess="LocationMaster__c = '" + assetAppData.CityId__c + "' AND IsActive__c =true AND ProductType__c='"+assetAppData.LoanAppln__r.Product__c+"' AND AgencyType__c INCLUDES ('Vetting')"
                this.filterCondnForTSR="LocationMaster__c = '" + assetAppData.CityId__c + "' AND IsActive__c =true AND ProductType__c='"+assetAppData.LoanAppln__r.Product__c+"' AND AgencyType__c INCLUDES ('TSR')"
               */
                this.filterCondnForlegal="LocationMaster__r.City__c = '" + assetAppData.City__c + "' AND IsActive__c =true AND ProductType__c='"+assetAppData.LoanAppln__r.Product__c+"' AND AgencyType__c INCLUDES ('Legal')"
                this.filterCondnForVess="LocationMaster__r.City__c = '" + assetAppData.City__c + "' AND IsActive__c =true AND ProductType__c='"+assetAppData.LoanAppln__r.Product__c+"' AND AgencyType__c INCLUDES ('Vetting')"
                this.filterCondnForTSR="LocationMaster__r.City__c = '" + assetAppData.City__c + "' AND IsActive__c =true AND ProductType__c='"+assetAppData.LoanAppln__r.Product__c+"' AND AgencyType__c INCLUDES ('TSR')" 
            }
          })
          .catch((error) => {
            
            console.error("Error in line ##50", error);
          });
      }



    @track WaiverReasonOpt=[]
    @track WaiverStatusOpt=[]
    @track allOwnerOpt=[]
    @track allClearNdMarkableOpt=[]
    //legally picklistOptions
    @wire(getPicklistValuesByRecordType, {
        objectApiName: CASE_OBJECT,
        recordTypeId: '$legalRecordTypeId',
    })picklistHandlerForLegal({ data, error }){
        if(data){
            console.log('hh')
            this.WaiveCPV = [...this.generatePicklist(data.picklistFieldValues.WaiveCPV__c)]
            this.WaiverReasonOpt=[...this.generatePicklist(data.picklistFieldValues.WaiverReason__c)]
            this.WaiverStatusOpt=[...this.generatePicklist(data.picklistFieldValues.ReportResult__c)]
            this.allOwnerOpt=[...this.generatePicklist(data.picklistFieldValues.AllPropertyOwnersArePartOfLoanStru__c)]
            this.allClearNdMarkableOpt=[...this.generatePicklist(data.picklistFieldValues.IsTheTitleClearNdMarketable__c)]
            this.WaiverReasonOpt.unshift('')
        }   
        if (error) {
            console.error('error'+error)
        }
    }
    //TSR picklistOptions
    @track isTRWaivedOpt=[];
    @track reasonForTSROpt=[];
    @track ReportStatusOpt=[];
    @track noOfYearsOpt=[];
    @wire(getPicklistValuesByRecordType, {
        objectApiName: CASE_OBJECT,
        recordTypeId: '$TSRRecordTypeId',
    })picklistHandlerforTSR({ data, error }){
        if(data){
            var nullVal=''
            this.isTRWaivedOpt=[...this.generatePicklist(data.picklistFieldValues.IsTSRwaived__c)]
            this.reasonForTSROpt=[...this.generatePicklist(data.picklistFieldValues.WaiverReason__c)]
            this.ReportStatusOpt=[...this.generatePicklist(data.picklistFieldValues.ReportResult__c)]
            this.noOfYearsOpt=[...this.generatePicklist(data.picklistFieldValues.TSR_EC_for_no_of_Yrs__c)]
            this.reasonForTSROpt.unshift(nullVal)
            
            
        }   
        if (error) {
            console.error('error'+error)
        }
    }
    @track reasonForvettingOpt=[]
    //picklistOptionsForVetting
    @track ReportStatusOptVet=[]; //Added by Ripul
    @wire(getPicklistValuesByRecordType, {
        objectApiName: CASE_OBJECT,
        recordTypeId: '$vettingRecordTypeId',
    })picklistHandlerForVetting({ data, error }){
        if(data){
            this.reasonForvettingOpt=[...this.generatePicklist(data.picklistFieldValues.WaiverReason__c)]
            this.ReportStatusOptVet=[...this.generatePicklist(data.picklistFieldValues.ReportResult__c)] //Added by Ripul
            this.reasonForvettingOpt.unshift('')
        }   
        if (error) {
            console.error('error'+error)
        }
    }

    legalBankData;
    handleValueLegalAgency(event){
        console.log('inside handleValueForSDFCBnk1'+JSON.stringify(event.detail));
        this.legalBankData=event.detail
        if(this.legalBankData.id!=null){
            let recId= this.legalBankData.id
            let record= this.legalBankData.record
            console.log("recId>>>", this.legalBankData.record.Account__c);
            this.wrapLegalCaseObj.AccountId=this.legalBankData.record.Account__c
        }else{
            this.wrapLegalCaseObj.AccountId=''
        }
        
    }
    tsrBnkData
    handleValueTSRAgency(event){
        console.log('inside handleValueForSDFCBnk2'+JSON.stringify(event.detail));
        this.tsrBnkData=event.detail
        if(this.tsrBnkData.id!=null){
            let recId= this.tsrBnkData.id
            let record= this.tsrBnkData.record
            console.log("recId>>>", this.tsrBnkData.record.Account__c);
            this.wrapTSRCaseObj.AccountId=this.tsrBnkData.record.Account__c
        }else{
            this.wrapTSRCaseObj.AccountId=''
        }
       

    }
    VessBankData;
    handleValueVettingAgency(event){
        console.log('inside handleValueForSDFCBnk3'+JSON.stringify(event.detail));
        this.VessBankData=event.detail
        if(this.VessBankData.id!=null){
            let recId= this.VessBankData.id
            let record= this.VessBankData.record
            console.log("recId>>>", this.VessBankData.record.Account__c);
            this.wrapVettingCaseObj.AccountId=this.VessBankData.record.Account__c
        }else{
            this.wrapVettingCaseObj.AccountId=''
        }
    }
    forNowDate;
    handleLegalCaseData(event){
        this.wrapLegalCaseObj[event.target.dataset.field] = event.target.value;
        if (event.target.dataset.field === 'string') {
            let strVal = event.target.value;
            this.wrapLegalCaseObj[event.target.dataset.field] = strVal.toUpperCase();
            this.parentRecForLegal[event.target.dataset.field]=strVal.toUpperCase();
        }
        //console.log('this.parentRecForLegal[event.target.dataset.field]'+this.parentRecForLegal[event.target.dataset.field])
        if(event.target.dataset.field=='WaiveCPV__c'){
            this.valOfStatusYesOrNo=event.target.value
            if(this.wrapLegalCaseObj.WaiveCPV__c=='Yes'){
                
                this.requiredforlegal=true
                this.requiredforlegalforNo=false
            }else{
                this.requiredforlegal=false
                this.requiredforlegalforNo=true
            }
            if(this.wrapLegalCaseObj.WaiveCPV__c=='No' && this.valOfStatusLegal !='Pending'){
                this.requLegForpen=true
            }else{
                this.requLegForpen=false
            }
        }
        if(event.target.dataset.field=='ReportResult__c'){
            this.valOfStatusLegal=event.target.value
            if(this.wrapLegalCaseObj.ReportResult__c !='Pending' && this.valOfStatusYesOrNo=='No'){
                this.requLegForpen=true
            }else{
                this.requLegForpen=false
            }
        }
        else if(event.target.dataset.field=='Remarks_regarding_the_case__c'){
           this.parentRecForLegal.Remarks_regarding_the_case__c=event.target.value.toUpperCase()
            this.wrapLegalCaseObj.Remarks_regarding_the_case__c=event.target.value.toUpperCase()
        }
        else if(event.target.dataset.field=='DateofInitiation__c'){
            var selectedDate = event.target.value;
           // const selectedDateTime = new Date(selectedDate);
            const currentDateTime = new Date().toISOString().split('T')[0]
            if (selectedDate > currentDateTime) {
                this.template.querySelector('[data-id="latestMon"]').value = '';
                this.wrapLegalCaseObj.DateofInitiation__c=''
                this.showToast("Error", "error", this.label.Legal_Property_Future_Date,"sticky");
            }
        }
        else if(event.target.dataset.field=='Date_of_Report__c'){
            var selectedDate = event.target.value;
            const selectedDateTime = new Date(selectedDate).getTime();
            //const currentDateTime = new Date().setHours(0, 0, 0, 0);
            const currentDateTime = new Date().toISOString().split('T')[0]
            if (selectedDate > currentDateTime) {
                this.template.querySelector('[data-id="reportDate"]').value = '';
                this.wrapLegalCaseObj.DateofInitiation__c=''
                this.showToast("Error", "error", this.label.Legal_Property_Future_Date,"sticky");
            }
        }
        console.log('this.wrapLegalCaseObj'+JSON.stringify(this.wrapLegalCaseObj))
    }

    handleTSRSCaseData(event){
        this.wrapTSRCaseObj[event.target.dataset.field] = event.target.value;
        if (event.target.dataset.field === 'string') {
            console.log('')
            let strVal = event.target.value;
            this.wrapTSRCaseObj[event.target.dataset.field] = strVal.toUpperCase();
            this.this.parentRecForTSR[event.target.dataset.field] = strVal.toUpperCase();
        }
        if(event.target.dataset.field=='IsTSRwaived__c'){
            this.valOfStatusTSRYesOrNo=event.target.value
            if(this.wrapTSRCaseObj.IsTSRwaived__c=='Yes'){
                this.requiredForTSR=true
                this.requiredForTSRforNo=false
            }else{
                this.requiredForTSR=false
                this.requiredForTSRforNo=true
            }
            if(this.wrapTSRCaseObj.IsTSRwaived__c=='No' && this.valOfStatusTSR !='Pending'){
                this.requiredForTSRforpen=true
            }else{
                this.requiredForTSRforpen=false
            }
        }
        if(event.target.dataset.field=='ReportResult__c'){
            this.valOfStatusTSR=event.target.value
            if(this.wrapTSRCaseObj.ReportResult__c !='Pending' && this.valOfStatusTSRYesOrNo=='No'){
                this.requiredForTSRforpen=true
            }else{
                this.requiredForTSRforpen=false
            }
        }
        else if(event.target.dataset.field=='Remarks_regarding_the_case__c'){
            this.parentRecForTSR.Remarks_regarding_the_case__c=event.target.value.toUpperCase()
            this.wrapTSRCaseObj.Remarks_regarding_the_case__c=event.target.value.toUpperCase()
        }
        else if(event.target.dataset.field=='DateofInitiation__c'){
            var selectedDate = event.target.value;
            const selectedDateTime = new Date(selectedDate).getTime();
            const currentDateTime = new Date().toISOString().split('T')[0]
            //const currentDateTime = new Date().setHours(0, 0, 0, 0);
            if (selectedDate > currentDateTime) {
                this.template.querySelector('[data-id="initiTSR"]').value = '';
                this.wrapTSRCaseObj.DateofInitiation__c=''
                this.showToast("Error", "error", this.label.Legal_Property_Future_Date,"sticky");
            }
        }
        else if(event.target.dataset.field=='Date_of_Report__c'){
            var selectedDate = event.target.value;
            const selectedDateTime = new Date(selectedDate).getTime();
            const currentDateTime = new Date().toISOString().split('T')[0]
            //const currentDateTime = new Date().setHours(0, 0, 0, 0);
            if (selectedDate > currentDateTime) {
                this.template.querySelector('[data-id="repDateTSR"]').value = '';
                this.wrapTSRCaseObj.DateofInitiation__c=''
                this.showToast("Error", "error", this.label.Legal_Property_Future_Date,"sticky");
            }
        }
        console.log('this.wrapLegalCaseObj'+JSON.stringify(this.wrapTSRCaseObj))
    }
    handleVettingCaseData(event){
        console.log('event.target.dataset.field',event.target.dataset.field)
        this.wrapVettingCaseObj[event.target.dataset.field] = event.target.value;
        if (event.target.dataset.fieldtype === 'string') {
            let strVal = event.target.value;
            this.wrapVettingCaseObj[event.target.dataset.field] = strVal.toUpperCase();
            this.parentRecForVetting[event.target.dataset.field] = strVal.toUpperCase();
            console.log('this.wrapVettingCaseObj'+JSON.stringify(this.wrapVettingCaseObj))
        }
        if(event.target.dataset.field=='Is_Vetting_waived__c'){
            this.valOfStatusVessOrNo=event.target.value
            if(this.wrapVettingCaseObj.Is_Vetting_waived__c=='Yes'){
                this.requiredForVetting=true
                this.requiredForVettingForNo=false

            }else{
                this.requiredForVetting=false
                this.requiredForVettingForNo=true
            }
            if(this.wrapVettingCaseObj.Is_Vetting_waived__c=='No' && this.valOfStatusVess !='Pending'){
                this.requiredForVeeforpen=true
            }else{
                this.requiredForVeeforpen=false
            }
        }
        if(event.target.dataset.field=='ReportResult__c'){
            this.valOfStatusVess=event.target.value
            if(this.wrapVettingCaseObj.ReportResult__c !='Pending' && this.valOfStatusVessOrNo=='No'){
                this.requiredForVeeforpen=true
            }else{
                this.requiredForVeeforpen=false
            }
        }
        
        else if(event.target.dataset.field=='Remarks_regarding_the_case__c'){
           // this.parentRecForVetting.Remarks_regarding_the_case__c=event.target.value.toUpperCase()
            this.wrapVettingCaseObj.Remarks_regarding_the_case__c=event.target.value.toUpperCase()
        }
        else if(event.target.dataset.field=='DateofInitiation__c'){
            var selectedDate = event.target.value;
            const selectedDateTime = new Date(selectedDate).getTime();
            //const currentDateTime = new Date().setHours(0, 0, 0, 0);
            const currentDateTime = new Date().toISOString().split('T')[0]
            if (selectedDate > currentDateTime) {
                this.template.querySelector('[data-id="initivee"]').value = '';
                this.wrapVettingCaseObj.DateofInitiation__c=''
                this.showToast("Error", "error", this.label.Legal_Property_Future_Date,"sticky");
            }
        }
        else if(event.target.dataset.field=='Date_of_Report__c'){
            var selectedDate = event.target.value;
            const selectedDateTime = new Date(selectedDate).getTime();
            //const currentDateTime = new Date().setHours(0, 0, 0, 0);
            const currentDateTime = new Date().toISOString().split('T')[0]
            if (selectedDate > currentDateTime) {
                this.template.querySelector('[data-id="repDatevee"]').value = '';
                this.wrapVettingCaseObj.DateofInitiation__c=''
                this.showToast("Error!", "error", this.label.Legal_Property_Future_Date,"sticky");
            }
        }
        console.log('this.wrapVettingCaseObj'+JSON.stringify(this.wrapVettingCaseObj))
    }


    showToast(title, variant, message,mode) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
    @track filesforLegal=[];
    parentFileChangeForLegal(event){
        this.filesforLegal=event.detail.fileList
        console.log('in parentFileChangeforlegal'+this.filesforLegal.length)
    }
    @track docDetailIdForLegal;
    fromUploadDocsContainerForLegal(event){
       // this.showSpinner =true;
        var documentDeatilData=event.detail
        this.docDetailIdForLegal=documentDeatilData.docDetailId;
        console.log('in parennntttt'+documentDeatilData.docDetailId) 
        this.updateDocDetailWithCase(this.docDetailIdForLegal)  
    }
    @track filesForTSR=[];
    parentFileChangeForTSR(event){

        this.filesForTSR=event.detail.fileList
        console.log('in parentFileChangeforlegal'+this.filesForTSR.length)
    }
    @track docDetailIdForTSR;
    fromUploadDocsContainerForTSR(event){
      //  this.showSpinner =true;
        var documentDeatilData=event.detail
        this.docDetailIdForTSR=documentDeatilData.docDetailId;
        this.updateDocDetailWithCase(this.docDetailIdForTSR) 
        console.log('in parennntttt'+documentDeatilData.docDetailId)   
    }
    @track filesForVess=[];
    parentFileChangeForVee(event){

        this.filesForVess=event.detail.fileList
        console.log('in parentFileChangeforlegal'+this.filesForVess.length)
    }
    @track docDetailIdForVess;
    fromUploadDocsContainerForVess(event){
     //   this.showSpinner =true;
        var documentDeatilData=event.detail
        this.docDetailIdForVess=documentDeatilData.docDetailId;
        this.updateDocDetailWithCase(this.docDetailIdForVess) 
        console.log('in parennntttt'+documentDeatilData.docDetailId)   
    }

    @wire(MessageContext)
    MessageContext;        
    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }

    handleSaveThroughLms(values) {
       // this.showSpinner = true;
        console.log('values to save through Lms ', JSON.stringify(values));
        this.handleSaveV(values.validateBeforeSave);

    }
    validate;
    handleSaveV(validate) {
        
        this.validate=validate
        this.fillStatusFiledOfCase();
        if(validate){
            if(this.checkValidation() && this.checkValidityLookup()){
              //  this.handleSave()
            }else{
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: "Please fill all required details.",
                        variant: "error",
                        mode: "sticky"
                    })
                );
            }
        }else{
            
           // this.handleSave()
        }
        
         console.log('this.parentRecForLegal>>>>'+JSON.stringify(this.wrapLegalCaseObj))
    }

    fillStatusFiledOfCase(){
        if(this._tabName == 'Legal'){
            if(this.wrapLegalCaseObj.WaiveCPV__c=='Yes'){
                this.wrapLegalCaseObj["Status"]='Closed';
            }else if(this.wrapLegalCaseObj.WaiveCPV__c=='No' && this.wrapLegalCaseObj.ReportResult__c=='Pending'){
                this.wrapLegalCaseObj["Status"]='New';
            }else if(this.wrapLegalCaseObj.WaiveCPV__c=='No' && this.wrapLegalCaseObj.ReportResult__c!='Pending' && (this.filesforLegal.length >0 || this.documentListofCase.length>0) && this.checkValidation() && this.checkValidityLookup()){
                this.wrapLegalCaseObj["Status"]='Closed';
            }else{
                this.wrapLegalCaseObj["Status"]='New';
            }
           // this.wrapCaseObj=this.wrapLegalCaseObj
        }else if(this._tabName == 'TSR'){
            if(this.wrapTSRCaseObj.IsTSRwaived__c=='Yes'){
                this.wrapTSRCaseObj["Status"]='Closed';
            }else if(this.wrapTSRCaseObj.IsTSRwaived__c=='No' && this.wrapTSRCaseObj.ReportResult__c=='Pending'){
                this.wrapTSRCaseObj["Status"]='New';
            }else if(this.wrapTSRCaseObj.IsTSRwaived__c=='No' && this.wrapTSRCaseObj.ReportResult__c!='Pending' && (this.filesForTSR.length >0 || this.documentListofCase.length>0) && this.checkValidation() && this.checkValidityLookup()){
                this.wrapTSRCaseObj["Status"]='Closed';
            }else{
                this.wrapTSRCaseObj["Status"]='New';
            }
            //this.wrapCaseObj=this.wrapTSRCaseObj
        }else if(this._tabName == 'Vetting'){
            if(this.wrapVettingCaseObj.Is_Vetting_waived__c=='Yes'){
                this.wrapVettingCaseObj["Status"]='Closed';
            }else if(this.wrapVettingCaseObj.Is_Vetting_waived__c=='No' && this.wrapVettingCaseObj.ReportResult__c=='Pending'){
                this.wrapVettingCaseObj["Status"]='New';
            }else if(this.wrapVettingCaseObj.Is_Vetting_waived__c=='No' && this.wrapVettingCaseObj.ReportResult__c!='Pending' && (this.filesForVess.length >0 || this.documentListofCase.length>0) && this.checkValidation() && this.checkValidityLookup()){
                this.wrapVettingCaseObj["Status"]='Closed';
            }else{
                this.wrapVettingCaseObj["Status"]='New';
            }
            //this.wrapCaseObj=this.wrapVettingCaseObj
        }
    }

    checkValidityLookup() {
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
    
    checkValidation(){
        const isRequiredField = [
            ...this.template.querySelectorAll("lightning-input")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        const isComboboxCorrect = [
            ...this.template.querySelectorAll("lightning-combobox")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        console.log('isRequiredField',isRequiredField);
        return  isRequiredField && isComboboxCorrect;
    }
    wrapCaseObj;
    caseId;
    handleSave(){
        this.wrapCaseObj={};
        if(this._tabName == 'Legal'){
           this.wrapCaseObj=this.wrapLegalCaseObj
        }else if(this._tabName == 'TSR'){
            this.wrapCaseObj=this.wrapTSRCaseObj
        }else if(this._tabName == 'Vetting'){
            this.wrapCaseObj=this.wrapVettingCaseObj
        }

        
        
            console.log('jjjjjjjjjjjjjjj')
            this.wrapCaseObj.sobjectType='Case';  
            this.wrapCaseObj["Loan_Application__c"]=this._loanAppId;  
            this.wrapCaseObj["Applicant__c"]=this._applicantId; 
            console.log('this._currentTabId'+this._currentTabId);
            if(this._currentTabId && this._currentTabId !='New' && this._currentTabId !='new'){
                this.wrapCaseObj["ApplAssetId__c"]=this._currentTabId; 
            } 
            
            if(this.productType){
                this.wrapCaseObj["Product_Type__c"]= this.productType
            } 
            
            console.log('this.parentRecForLegal'+JSON.stringify(this.wrapCaseObj))
            let ChildRecords = [];
            
            // let upsertData={                       
            //     parentRecord:this.wrapCaseObj,                       
            //     ChildRecords:ChildRecords,
            //     ParentFieldNameToUpdate:''
            // }
        
        
        // updateData ({upsertData:upsertData})
        // .then(result => {  
        //     console.log('resultresultresultresultresult'+result.parentRecord.Id)  
        //     this.caseId=result.parentRecord.Id;
        //     /*this.wrapVettingCaseObj={}
        //     this.wrapTSRCaseObj={}*/
        //     //this.wrapLegalCaseObj={}
            
            
            
        //     if(this._tabName == 'Vetting'){
        //         if(this.filesForVess.length >0){
        //             this.template.querySelector('c-upload-docs-reusable-component').handleUpload();
        //             //     this.dispatchEvent(
        //             //         new ShowToastEvent({
        //             //             title: "Success",
        //             //             message: this.label.Legal_Property_Case_Update,
        //             //             variant: "success",
        //             //             mode: "sticky"
        //             //     })
        //             // );
        //             this.filesForVess=[];
                    
        //         }else{
        //             refreshApex(this._wireForVettingRecType)
        //             console.log('this.documentListofCase859'+this.documentListofCase.length)
        //             if(this.validate && this.requiredForVeeforpen && this.documentListofCase.length==0){
        //                 this.dispatchEvent(
        //                     new ShowToastEvent({
        //                         title: "Error",
        //                         message: this.label.Legal_Property_File_Req,
        //                         variant: "error",
        //                         mode: "sticky"
        //                     })
        //                 );
        //             }else{
        //                 // this.dispatchEvent(
        //                 //  new ShowToastEvent({
        //                 //         title: "Success",
        //                 //         message: this.label.Legal_Property_Case_Update,
        //                 //         variant: "success",
        //                 //         mode: "sticky"
        //                 //     })
        //                 // );
        //                 /*createDocumentDetail({ applicantId: this._applicantId, loanAppId: this._loanAppId, docCategory: this.docCategory, docType: this.docType, docSubType: this.docSubType,availableInFile : false })
        //                 .then((result) => {
        //                 this.docDetailIdForVess=result
        //                     this.updateDocDetailWithCase(this.docDetailIdForVess)
        //                  this.dispatchEvent(
        //                  new ShowToastEvent({
        //                         title: "Success",
        //                         message: this.label.Legal_Property_Case_Update,
        //                         variant: "success",
        //                         mode: "sticky"
        //                     })
        //                 );
        //              })
        //             .catch((err) => {
                        
        //                 console.log(" createDocumentDetailRecord error===", err);
        //             });*/ 
        //             }
        //         }
                
        //     }
        //     else if(this._tabName == 'TSR'){
        //         if(this.filesForTSR.length >0){
        //             this.template.querySelector('c-upload-docs-reusable-component').handleUpload();
        //             //     this.dispatchEvent(
        //             //         new ShowToastEvent({
        //             //             title: "Success",
        //             //             message: this.label.Legal_Property_Case_Update,
        //             //             variant: "success",
        //             //             mode: "sticky"
        //             //     })
        //             // );
        //             this.filesForTSR=[];
        //         }else{
        //             refreshApex(this._wireForTSRRecType)
        //             if(this.validate && this.requiredForTSRforpen && this.documentListofCase.length==0){
        //                 this.dispatchEvent(
        //                     new ShowToastEvent({
        //                         title: "Error",
        //                         message: this.label.Legal_Property_File_Req,
        //                         variant: "error",
        //                         mode: "sticky"
        //                     })
        //                 );
        //             }else{
        //                 // this.dispatchEvent(
        //                 //     new ShowToastEvent({
        //                 //            title: "Success",
        //                 //            message: this.label.Legal_Property_Case_Update,
        //                 //            variant: "success",
        //                 //            mode: "sticky"
        //                 //        })
        //                 //    );
        //                 /*createDocumentDetail({ applicantId: this._applicantId, loanAppId: this._loanAppId, docCategory: this.docCategory, docType: this.docType, docSubType: this.docSubType,availableInFile : false })
        //                 .then((result) => {
        //                 //this.docDetailIdForVess=result
        //                     this.updateDocDetailWithCase(result)
        //                     this.dispatchEvent(
        //                         new ShowToastEvent({
        //                             title: "Success",
        //                             message: this.label.Legal_Property_Case_Update,
        //                             variant: "success",
        //                             mode: "sticky"
        //                         })
        //                     );
        //                 })
        //                 .catch((err) => {
                            
        //                     console.log(" createDocumentDetailRecord error===", err);
        //                 });*/ 
        //             }
        //         }
                
                
        //     }
        //     else if(this._tabName == 'Legal'){
        //         console.log('this.filesforLegal.length'+this.filesforLegal.length)
        //         if(this.filesforLegal.length >0){
        //             this.template.querySelector('c-upload-docs-reusable-component').handleUpload();
        //                 this.dispatchEvent(
        //                     new ShowToastEvent({
        //                         title: "Success",
        //                         message: this.label.Legal_Property_Case_Update,
        //                         variant: "success",
        //                         mode: "sticky"
        //                 })
        //             );
        //             this.filesforLegal=[];
                    
        //         }else{
        //             refreshApex(this._wireForLeaglRecType)
        //             if(this.validate && this.requLegForpen && this.documentListofCase.length==0){
        //                 this.dispatchEvent(
        //                     new ShowToastEvent({
        //                         title: "Error",
        //                         message: this.label.Legal_Property_File_Req,
        //                         variant: "error",
        //                         mode: "sticky"
        //                     })
        //                 );
        //             }else{
        //                 this.dispatchEvent(
        //                     new ShowToastEvent({
        //                            title: "Success",
        //                            message: this.label.Legal_Property_Case_Update,
        //                            variant: "success",
        //                            mode: "sticky"
        //                        })
        //                    );
        //                 /*createDocumentDetail({ applicantId: this._applicantId, loanAppId: this._loanAppId, docCategory: this.docCategory, docType: this.docType, docSubType: this.docSubType,availableInFile : false })
        //                 .then((result) => {
        //                 //this.docDetailIdForVess=result
        //                     this.updateDocDetailWithCase(result)
        //                 this.dispatchEvent(
        //                     new ShowToastEvent({
        //                         title: "Success",
        //                         message: this.label.Legal_Property_Case_Update,
        //                         variant: "success",
        //                         mode: "sticky"
        //                     })
        //                     );
        //                 })
                        
                        
        //                 .catch((err) => {
                            
        //                     console.log(" createDocumentDetailRecord error===", err);
        //                 }); */
        //             }
        //         }
        //         if(typeof this.wrapLegalCaseObj.IsTheTitleClearNdMarketable__c !=='undefined' && this.wrapLegalCaseObj.IsTheTitleClearNdMarketable__c !=null && this.wrapLegalCaseObj.IsTheTitleClearNdMarketable__c!=undefined &&this.wrapLegalCaseObj.IsTheTitleClearNdMarketable__c !=''){
        //             console.log('this.wrapLegalCaseObj.IsTheTitleClearNdMarketable__c1'+this.wrapLegalCaseObj.IsTheTitleClearNdMarketable__c)
        //             this.updateAppliAssetRecWithLegal();
        //         }else{
        //             console.log('this.wrapLegalCaseObj.IsTheTitleClearNdMarketable__c2'+this.wrapLegalCaseObj.IsTheTitleClearNdMarketable__c)
        //         }
              
                
                
        //     }
        //     this.showSpinner = false;       
            
        // }).catch(error => {
        //     this.showSpinner = false;
        //     console.log(error);
        // })
    }
    documentListofCase=[];
    allListDatahandler(event){
        console.log('inallListDatahandler')
       var DocumentList=[];
       DocumentList=event.detail;
       this.documentListofCase=DocumentList;
       console.log('this.documentListofCase'+this.documentListofCase.length)

    }
    updateDocDetailWithCase(documentDetailId){
     //   this.showSpinner = true;
        const fields = {};           
        fields[DOC_FIELD.fieldApiName] = documentDetailId;
        fields[CASE_FIELD.fieldApiName] =this.caseId ;
        const recordInput = { fields };
        console.log('recordInput--->',recordInput);
        updateRecord(recordInput)
        .then((result) => {             
            console.log('inside update record'+JSON.stringify(result));
            console.log('caseidyes'+this.caseidyes);
            //console.log('hhhhhhhhhhhhhhhhh'+this.template.querySelector('c-show-case-document').handleFilesUploaded())
            this.template.querySelector('c-show-case-document').handleFilesUploaded();
            refreshApex(this._wireForLeaglRecType)
            refreshApex(this._wireForTSRRecType)
            refreshApex(this._wireForVettingRecType)
            this.showSpinner = false;
        })
        .catch(error => {
            this.showSpinner = false;
                   });
    }
    updateAppliAssetRecWithLegal(){
        const fields = {};           
        fields[ISMARKEABLE_FIELD.fieldApiName] = this.wrapLegalCaseObj.IsTheTitleClearNdMarketable__c;
        fields[APP_ASSET_FIELD.fieldApiName] =this._currentTabId ;
        const recordInput = { fields };
        console.log('recordInputforLegal--->',recordInput);
        updateRecord(recordInput)
        .then((result) => {             
            
        })
        .catch(error => {
            this.showSpinner = false
                   });
    }
}