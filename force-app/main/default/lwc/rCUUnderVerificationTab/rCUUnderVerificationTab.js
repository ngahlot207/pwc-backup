import { LightningElement,track,api,wire } from 'lwc';
import { getObjectInfo, getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import CASE_OBJECT from "@salesforce/schema/Case";
import { refreshApex } from '@salesforce/apex';
import { createRecord,updateRecord } from "lightning/uiRecordApi";
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
import Id from "@salesforce/user/Id"; //LAK-8568 - Jayesh
import Legal_Property_Case_Update from '@salesforce/label/c.Legal_Property_Case_Update';
import Legal_Property_Future_Date from '@salesforce/label/c.Legal_Property_Future_Date';
import Legal_Property_File_Req from '@salesforce/label/c.Legal_Property_File_Req';

import createDocumentDetail from "@salesforce/apex/DocumentDetailController.createDocumentDetail";
export default class RCUUnderVerificationTab extends LightningElement {

    label = {
        Legal_Property_Case_Update,
        Legal_Property_Future_Date,
        Legal_Property_File_Req
    }
    @track disableMode
    @api hasEditAccess;
    @track fileSizeMsz='Allowed File Types are : pdf, jpg, jpeg, png'
    @track allowedFilFormat = [".jpg", ".jpeg", ".pdf",".png", ".pneg"];
    @track wrapRCUCaseObj={}
    @track hideAttachButton
    @track requiredforRCU=false; 
    @track currentUserId = Id; //LAK-8568 - Jayesh
    @api currentTabId;
    @track caseId
    subscription;
    @track showSpinner;
    @api get loanAppId() {
        return this._loanAppId;
      }
      set loanAppId(value) {
        this._loanAppId = value;
        console.log('this._loanAppId'+this._loanAppId)
        this.setAttribute("loanAppId", value);
        this.handleRecordIdChange();
        this.getLoanAppliData();
    }
    //@track _loanAppId='a08C4000006Ayh2IAC'
    @track docCategory='Case Documents';
    @track docType='RCU Verification';
    @track docSubType='RCU Report';
    @track parentRecForRCU;
    
    handleRecordIdChange() {
        let tempParams = this.pramForCaseRCU;
         tempParams.queryCriteria =' where Loan_Application__c= \'' + this._loanAppId + '\' AND RecordType.name = \'RCU\''
         this.pramForCaseRCU = { ...tempParams };

     }
    @track pramForCaseRCU={
        ParentObjectName:'Case',
        ChildObjectRelName:'',
        parentObjFields:[  'Id','WaiveCPV__c','Date_of_Report__c','RCU_Hold_Reason__c','Final_RCU_status_Reason__c','ApplAssetId__r.CityId__c','ReportResult__c','WaiverReason__c','AllPropertyOwnersArePartOfLoanStru__c','IsTheTitleClearNdMarketable__c','Remarks_regarding_the_case__c','AccountId','Account.Name','DateofInitiation__c'],
        childObjFields:[ ],
        queryCriteria: ' where Loan_Application__c= \'' + this._loanAppId + '\' AND RecordType.name = \'RCU\' ORDER BY Createddate DESC'
    }
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objInfo;
    @track showDeleteIcon;
    disconnectedCallback() {
        this.unsubscribeMC();
        releaseMessageContext(this.context);
    }
    unsubscribeMC() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    connectedCallback(){
        this.hideAttachButton=true
        if(this.hasEditAccess === false){
            this.disableMode = true;
            this.showDeleteIcon=false;
      }else{
             this.disableMode = false;
             this.showDeleteIcon=true;
      }
      this.scribeToMessageChannel();
       
    }
    @track RCURecordTypeId;
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    getObjectInfo({ error, data }) {
        if (data) {
        console.log("DATA in RECORD TYPE ID IN TECHINCAL PROP DET #332", data);
        for (let key in data.recordTypeInfos) {
            let recordType = data.recordTypeInfos[key];
            if (recordType.name === "RCU") {
                this.RCURecordTypeId = key;
                this.wrapRCUCaseObj.RecordTypeId=this.RCURecordTypeId;
                console.log('this.RCURecordTypeId'+this.RCURecordTypeId)
            }
            
        }
        } else if (error) {
        console.error("Error fetching record type Id", error);
        }
    }
    _wireForRCURecType
    @track caseidyes=true
    @track reqHoldRea=false
    @track reqRepData=false
    @wire(getSobjectData,{params:'$pramForCaseRCU'})
    caseDataForLeaglRecType(wireForRCURecType) {
        const { data, error } = wireForRCURecType;
        this._wireForRCURecType = wireForRCURecType;
        this.parentRecForRCU={}
        if (data) {
            if(data.parentRecords){
                console.log('wiredApplicantRecData>>>>>>1',JSON.stringify(data.parentRecords[0]));
                this.parentRecForRCU=JSON.parse(JSON.stringify(data.parentRecords[0])); 
                this.wrapRCUCaseObj.Id=this.parentRecForRCU.Id
                    this.caseId=this.parentRecForRCU.Id
                    this.caseidyes=true
                    setTimeout(() => {
                        this.template.querySelector('c-show-case-document').handleFilesUploaded();
                    }, 1000);
                if(this.parentRecForRCU.ReportResult__c == 'Refer' || this.parentRecForRCU.ReportResult__c == 'Fraud' || this.parentRecForRCU.ReportResult__c == 'Negative'){
                    this.requiredforRCU=true
                    this.reqRepData=true
                }else{
                    this.requiredforRCU=false
                }
                if(this.parentRecForRCU.ReportResult__c == 'Refer' || this.parentRecForRCU.ReportResult__c == 'Fraud' || this.parentRecForRCU.ReportResult__c == 'Negative'){
                    this.requiredforRCU=true
                    this.reqRepData=true
                }
                else if(this.parentRecForRCU.ReportResult__c == 'Hold'){
                    this.reqHoldRea=true
                    this.requiredforRCU=false
                    this.reqRepData=false
                }else if(this.parentRecForRCU.ReportResult__c =='Positive'){
                    this.requiredforRCU=false
                    this.reqHoldRea=false
                    this.reqRepData=false
                }
               
                else{
                    this.requiredforRCU=false
                    this.reqHoldRea=false
                    this.reqRepData=false
                }
                this.showSpinner = false;

            }
            
        } else if (error) {
            this.showSpinner = false;
            console.log(error);
        }
        
    }
    @track applRecId;
    @track filterCondnForRCU;
    @track productType
    getLoanAppliData() {
        let loanAppParam = {
          ParentObjectName: "LoanAppl__c",
          ChildObjectRelName: "",
          parentObjFields: ["Id", "BrchCode__c","Product__c","Applicant__c"],
          childObjFields: [""],
          queryCriteria: " where Id = '" + this._loanAppId + "' limit 1"
        };
        getSobjectData({ params: loanAppParam })
          .then((result) => {
            console.log("RESULT IN SUB TAB PROP #71", result);
            if (result) {
                var loanAppData=JSON.parse(JSON.stringify(result.parentRecords[0])); 
                var barchCode=loanAppData.BrchCode__c;
                this.productType=loanAppData.Product__c
                this.applRecId=loanAppData.Applicant__c
                //this.getLocBrchJnData(barchCode);
                this.getBankBranchMasterData(barchCode); //LAK-8536
            }
          })
          .catch((error) => {
            console.error("Error in line ##50", error);
          });
    }
    
    // getLocBrchJnData(barchCode){
    //     let LocBrnchJnParam = {
    //         ParentObjectName: "LocBrchJn__c",
    //         ChildObjectRelName: "",
    //         parentObjFields: ["Id", "Location__c","Branch__c","Branch__r.BrchCode__c"],
    //         childObjFields: [""],
    //         queryCriteria: " where Branch__r.BrchCode__c = '" + barchCode + "' limit 1"
    //       };
    //       getSobjectData({ params: LocBrnchJnParam })
    //         .then((result) => {
    //           console.log("RESULT IN SUB TAB PROP #71", result);
    //           if (result) {
    //             var LocBnkDataData=JSON.parse(JSON.stringify(result.parentRecords[0])); 
    //             console.log('LocBnkDataData'+JSON.stringify(result.parentRecords[0]))
    //             var locationMasCityId=LocBnkDataData.Location__c
    //             console.log('locationMasCityId'+locationMasCityId)
    //             this.filterCondnForRCU="LocationMaster__c = '" + locationMasCityId + "' AND IsActive__c =true AND ProductType__c='"+this.productType+"' AND AgencyType__c INCLUDES ('RCU')"
    //           }
    //         })
    //         .catch((error) => {
    //           console.error("Error in line ##50", error);
    //         });
    // }

    //LAK-8536
    getBankBranchMasterData(barchCode){
        let LocBrnchJnParam = {
            ParentObjectName: "BankBrchMstr__c",
            ChildObjectRelName: "",
            //parentObjFields: ["Id", "Location__c","Branch__c","Branch__r.BrchCode__c"],
            parentObjFields: ["Id", "LocationMaster__c","BrchCode__c"],
            childObjFields: [""],
            //queryCriteria: " where Branch__r.BrchCode__c = '" + barchCode + "' limit 1"
            queryCriteria: " where BrchCode__c = '" + barchCode + "' limit 1"
          };
          getSobjectData({ params: LocBrnchJnParam })
            .then((result) => {
              console.log("RESULT IN SUB TAB PROP #71", result);
              if (result) {
                var LocBnkDataData=JSON.parse(JSON.stringify(result.parentRecords[0])); 
                console.log('LocBnkDataData'+JSON.stringify(result.parentRecords[0]))
                //var locationMasCityId=LocBnkDataData.Location__c
                var locationMasCityId=LocBnkDataData.LocationMaster__c

                console.log('locationMasCityId'+locationMasCityId)
                if (!locationMasCityId) {
                    // Display the information message in HTML
                    document.getElementById('infoMessage').innerText = "There is no city mapped to this branch on Bank Branch Master";
                    document.getElementById('infoMessage').style.display = "block";
                  } else {
                    // Hide the message if locationMasCityId is not blank
                    document.getElementById('infoMessage').style.display = "none";
                this.filterCondnForRCU="LocationMaster__c = '" + locationMasCityId + "' AND IsActive__c =true AND ProductType__c='"+this.productType+"' AND AgencyType__c INCLUDES ('RCU')"
                  }
            }
            })
            .catch((error) => {
              console.error("Error in line ##50", error);

            });
    }

    RCUBankData;
    handleValueRCUAgency(event){
        console.log('inside handleValueForSDFCBnk1'+JSON.stringify(event.detail));
        this.RCUBankData=event.detail
        if(this.RCUBankData.id!=null){
            let recId= this.RCUBankData.id
            let record= this.RCUBankData.record
            console.log("recId>>>", this.RCUBankData.record.Account__c);
            this.wrapRCUCaseObj.AccountId=this.RCUBankData.record.Account__c
        }else{
            this.wrapRCUCaseObj.AccountId=''
        }
        
    }


    generatePicklist(data) {
        return data.values.map(item => ({ "label": item.label, "value": item.value }))
    }
    @track RcuStaReaOpt=[]
    @track FinalRCUstaOpt=[]
    @wire(getPicklistValuesByRecordType, {
        objectApiName: CASE_OBJECT,
        recordTypeId: '$RCURecordTypeId',
    })picklistHandlerForRCU({ data, error }){
        console.log('ggggggggggggggg')
        if(data){
            console.log('hh')
            this.FinalRCUstaOpt = [...this.generatePicklist(data.picklistFieldValues.ReportResult__c)]
            this.RcuStaReaOpt=[...this.generatePicklist(data.picklistFieldValues.Final_RCU_status_Reason__c)]
            console.log(' this.FinalRCUstaOpt'+ this.FinalRCUstaOpt)
        }   
        if (error) {
            console.error('error'+error)
        }
    }
    documentListofCase=[];
    allListDatahandler(event){
        console.log('inallListDatahandler')
       var DocumentList=[];
       DocumentList=event.detail;
       this.documentListofCase=DocumentList;
       console.log('this.documentListofCase'+this.documentListofCase.length)

    }

    handleRCUCaseData(event){
        this.wrapRCUCaseObj[event.target.dataset.field] = event.target.value;
        if (event.target.dataset.fieldtype === 'string') {
            let strVal = event.target.value;
            this.wrapRCUCaseObj[event.target.dataset.field] = strVal.toUpperCase();
        }
        if(event.target.dataset.field=='ReportResult__c'){
            console.log('event.target.value'+event.target.value)
            if(event.target.value == 'Refer' || event.target.value == 'Fraud' || event.target.value == 'Negative'){
                this.requiredforRCU=true
                this.reqRepData=true
                this.reqHoldRea=false
            }else if(event.target.value == 'Hold'){
                this.reqHoldRea=true
                this.requiredforRCU=false
                this.reqRepData=false
            }else if(event.target.value == 'Positive'){
                console.log('event.target.value>>'+event.target.value)
                this.requiredforRCU=false
                this.reqHoldRea=false
                this.reqRepData=false
            }
           
            else if(event.target.value == 'Pending'){
                this.requiredforRCU=false
                this.reqRepData=false
                this.reqHoldRea=false
            } else if(event.target.value != 'Pending' && event.target.value != 'Hold'){
                this.reqRepData=false
                this.reqHoldRea=false
                this.requiredforRCU=false
            }
            
            console.log('reqRepData'+this.requiredforRCU)
        }else if(event.target.dataset.field=='Remarks_regarding_the_case__c'){
            this.parentRecForRCU.Remarks_regarding_the_case__c=event.target.value.toUpperCase()
            this.wrapRCUCaseObj.Remarks_regarding_the_case__c=event.target.value.toUpperCase()
        }
        else if(event.target.dataset.field=='RCU_Hold_Reason__c'){
            this.parentRecForRCU.RCU_Hold_Reason__c=event.target.value.toUpperCase()
            this.wrapRCUCaseObj.RCU_Hold_Reason__c=event.target.value.toUpperCase()
        }
        else if(event.target.dataset.field=='DateofInitiation__c'){
            var selectedDate = event.target.value;
            const selectedDateTime = new Date(selectedDate).getTime();
            //const currentDateTime = new Date().setHours(0, 0, 0, 0);
            const currentDateTime = new Date().toISOString().split('T')[0]
            if (selectedDate > currentDateTime) {
                this.template.querySelector('[data-id="latestMon"]').value = '';
                this.wrapRCUCaseObj.DateofInitiation__c=''
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
                this.wrapRCUCaseObj.DateofInitiation__c=''
                this.showToast("Error", "error", this.label.Legal_Property_Future_Date,"sticky");
            }
        }
        console.log('this.wrapRCUCaseObj'+JSON.stringify(this.wrapRCUCaseObj))
    }
    @track filesforRCU=[];
    parentFileChangeForLegal(event){
        this.filesforRCU=event.detail.fileList
        console.log('in parentFileChangeforlegal'+this.filesforRCU.length)
    }
    @track docDetailIdForRCU;
    fromUploadDocsContainerForLegal(event){
        this.showSpinner = false;
        var documentDeatilData=event.detail
        this.docDetailIdForRCU=documentDeatilData.docDetailId;
        console.log('in parennntttt'+documentDeatilData.docDetailId) 
        this.updateDocDetailWithCase(this.docDetailIdForRCU)  
    }
    updateDocDetailWithCase(documentDetailId){
        const fields = {};           
        fields[DOC_FIELD.fieldApiName] = documentDetailId;
        fields[CASE_FIELD.fieldApiName] =this.caseId ;
        const recordInput = { fields };
        console.log('recordInput--->',recordInput);
        updateRecord(recordInput)
        .then((result) => {             
            console.log('inside update record'+JSON.stringify(result));
            console.log('hhhhhhhhhhhhhhhhh'+this.template.querySelector('c-show-case-document').handleFilesUploaded())
            this.template.querySelector('c-show-case-document').handleFilesUploaded();
            this.caseidyes=true
            refreshApex(this._wireForRCURecType)
            this.caseidyes=true
            
        })
        .catch(error => {
                   });
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
        this.showSpinner = true;   
        console.log('values to save through Lms ', JSON.stringify(values));
        this.handleSaveV(values.validateBeforeSave);

    }
    validate;
    handleSaveV(validate) {
        this.validate=validate
        if(validate){
            if(this.checkValidation() && this.checkValidityLookup()){
                this.handleSave()
            }else{
                this.showSpinner = false;
                this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: 'Please fill all required values.',
                            variant: "error",
                            mode: "sticky"
                    })
                );
            }
        }else{
            this.handleSave()
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
    handleSave(){
        console.log('this.currentTabId'+this.currentTabId)
        this.wrapCaseObj={}
        this.wrapCaseObj=this.wrapRCUCaseObj
        this.wrapCaseObj.sobjectType='Case';
        //LAK-8568 - Jayesh
        this.wrapCaseObj["OwnerId"] = this.currentUserId;
        this.wrapCaseObj["Loan_Application__c"]=this._loanAppId;
        this.wrapCaseObj["Applicant__c"]=this.applRecId;
        this.wrapCaseObj["Product_Type__c"]=this.productType
        if(this.currentTabId){
            this.wrapCaseObj["ApplAssetId__c"]=this.currentTabId
        }
        
        let ChildRecords = [];
        let upsertData={                       
            parentRecord:this.wrapCaseObj,                       
            ChildRecords:ChildRecords,
            ParentFieldNameToUpdate:''
        }
        console.log('this.wrapCaseObj'+JSON.stringify(this.wrapCaseObj))
        updateData ({upsertData:upsertData})
        .then(result => {  
            console.log('resultresultresultresultresult'+result.parentRecord.Id)
             
            this.caseId=result.parentRecord.Id
            if(this.filesforRCU.length >0){
                this.template.querySelector('c-upload-docs-reusable-component').handleUpload();
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: this.label.Legal_Property_Case_Update,
                            variant: "success",
                            mode: "sticky"
                    })
                );
               
                this.filesforRCU=[];
            }else{
                refreshApex(this._wireForRCURecType) 
                if(this.validate && this.reqRepData && this.documentListofCase.length==0){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: this.label.Legal_Property_File_Req,
                            variant: "error",
                            mode: "sticky"
                        })
                    );
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                               title: "Success",
                               message: this.label.Legal_Property_Case_Update,
                               variant: "success",
                               mode: "sticky"
                           })
                       );
                    /*createDocumentDetail({ loanAppId: this._loanAppId,applicantId: this.applRecId, docCategory: this.docCategory, docType: this.docType, docSubType: this.docSubType,availableInFile : false })
                    .then((result) => {
                    this.docDetailIdForRCU=result
                        this.updateDocDetailWithCase(this.docDetailIdForRCU)
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Success",
                                message: this.label.Legal_Property_Case_Update,
                                variant: "success",
                                mode: "sticky"
                            })
                        );
                        })
                    .catch((err) => {
                        
                        console.log(" createDocumentDetailRecord error===", err);
                    }); */
                }
            }
            
            
            
            
        }).catch(error => {
            
            console.log(error);
        })
    }  
    

}