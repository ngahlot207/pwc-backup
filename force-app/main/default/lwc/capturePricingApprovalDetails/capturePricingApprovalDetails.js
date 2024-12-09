import { LightningElement,api,track,wire } from 'lwc';
import fetchRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import { getRecord, getObjectInfo , getPicklistValuesByRecordType} from 'lightning/uiObjectInfoApi';
import LOANAPP_OBJECT from '@salesforce/schema/LoanAppl__c';
import { refreshApex } from '@salesforce/apex';
import { createRecord,updateRecord } from "lightning/uiRecordApi";
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import {subscribe, publish, MessageContext, APPLICATION_SCOPE} from 'lightning/messageService';
import updateData from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import getSobjectDataFoDetail from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Legal_Property_File_Req from '@salesforce/label/c.Legal_Property_File_Req';
import Approval_PriciPFMaxPe_Error from '@salesforce/label/c.Approval_PriciPFMaxPe_Error';
import ApprovalPricLoanAppRecUpdated from '@salesforce/label/c.ApprovalPricLoanAppRecUpdated';
import getDataForFilterChild from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithFilterRelatedRecords';
import REVIPF_VAL_FIELD from "@salesforce/schema/LonaApplCharges__c.Revised_PF__c";
import CHARGE_ID_FIELD from "@salesforce/schema/LonaApplCharges__c.Id";
import ROI_VAL_FIELD from "@salesforce/schema/LoanAppl__c.EffectiveROI__c";
import LOAN_APP_ID from "@salesforce/schema/LoanAppl__c.Id";
//import MetadataForROIndPF from '@salesforce/apex/PricingApprovalController.MetadataForROIndPF';
export default class CapturePricingApprovalDetails extends LightningElement {
    label = {
        Legal_Property_File_Req,
        ApprovalPricLoanAppRecUpdated,
        Approval_PriciPFMaxPe_Error
    }
    @track _loanAppId;
    @track parentRecord;
    @track _wiredLoanApplication;
    @track showPricingFields=false;
    @track showSpinner=false;
    @api layoutSize;
    @track disableMode
    @track fileSizeMsz='Allowed File Types are : pdf, jpg, jpeg, png'
    @track allowedFilFormat = [".jpg", ".jpeg", ".pdf",".png", ".pneg"];
    @track hideAttachButton
    @api hasEditAccess
    @track ApprovalPricingOption=[];
    @track wrapLoanAppObj={};
    @api recordId
    @track docCategory='Pricing Approval Document';
    @track docType='Pricing Approval Document';
    @track docSubType='Pricing Approval Document';

    @track applicantId;
    @api get loanAppId() {
        return this._loanAppId;
     }
     set loanAppId(value) {
         console.log(' LoanApp Id111 ! ', +value);
          this._loanAppId = value;
         //this.setAttribute("loanAppId", value);  
         console.log(' this._loanAppIdthis._loanAppIdthis._loanAppId', this._loanAppId);
         setTimeout(() => {
            this.handleLoanAppRecordIdChange();
            this.handleBRERecordChange();
         }, 500);
                   
    }
    @track forLoanAppli='35';
    @track eligibleType = 'Application';
    @track islatestTrue=true;
    handleLoanAppRecordIdChange(){        
        let tempParams1 = this.paramsForLoanAppRec;
        tempParams1.queryCriteriaForChild = ' where ChargeCodeID__c= \'' + this.forLoanAppli + '\' AND LoanApplication__c=\'' + this.recordId + '\'';
        tempParams1.queryCriteria = ' where Id = \'' + this.recordId + '\'';
        this.paramsForLoanAppRec = {...tempParams1};
        console.log('Applicantid-->', this.paramsForLoanAppRec );
    }
    @track paramsForLoanAppRec={
        ParentObjectName:'LoanAppl__c',
        ChildObjectRelName:'Loan_Application_Charges__r',
        parentObjFields:['Id','Stage__c','RevisedPF__c','Product__c', 'ApproverName__c','Applicant__c','PricingApprovalDate__c','RevisedROI__c','PricingApprovalApplicable__c','LoginAcceptDate__c','FileAcceptDate__c','AssessedIncAppln__c','AssesIncomeAppl__c','ReqLoanAmt__c'],
        childObjFields:['Id','PF__c','Revised_PF__c'],  
        queryCriteriaForChild: ' where ChargeCodeID__c= \'' + this.forLoanAppli + '\' AND LoanApplication__c=\'' + this.recordId + '\'',      
        queryCriteria: ' where Id= \'' + this.recordId + '\''

    }
    handleBRERecordChange() {
        let tempParams = this.parameter;
        tempParams.queryCriteria = ' WHERE LoanAppl__c=\'' + this.recordId + '\' AND EligibilityType__c=\'' + this.eligibleType + '\'AND IsLatest__c=' + this.islatestTrue;
        this.parameter = { ...tempParams };
        
      }
    @track parameter = {
    ParentObjectName: 'BRE__c ',
    ChildObjectRelName: null,
    parentObjFields: ['Id', 'LoanAppl__c', 'Applicant__c',  'RAACROI__c','EligibilityType__c', 'CombLTV_FOIR__c'],
    childObjFields: [],
    queryCriteria: ' WHERE LoanAppl__c=\'' + this.recordId + '\' AND EligibilityType__c=\'' + this.eligibleType + '\'AND IsLatest__c=' + this.islatestTrue
  }
  @track metadataPOIndPF = {
    ParentObjectName: 'pricingApprovalMaxROIndPF__mdt ',
    ChildObjectRelName: null,
    parentObjFields: ['Product_Name__c', 'Maximum_ROI__c', 'Maximum_PF__c'],
    childObjFields: [],
    queryCriteria: ' '
  }
    connectedCallback(){
        //this.hideAttachButton=false
        if(this.hasEditAccess === false){
            this.disableMode = true;
            this.hideAttachButton=true
        }else{
                this.disableMode = false;
                this.hideAttachButton=false
        }
        this.scribeToMessageChannel();
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
    generatePicklist(data) {
        return data.values.map(item => ({ "label": item.label, "value": item.value }))
    }
    @wire(getObjectInfo, { objectApiName:  LOANAPP_OBJECT})
    objectInfo

    @wire(getPicklistValuesByRecordType, {
        objectApiName: LOANAPP_OBJECT,
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    })picklistHandler({ data, error }){
        if(data){
            this.ApprovalPricingOption = [...this.generatePicklist(data.picklistFieldValues.PricingApprovalApplicable__c)];
            console.log('this.ApprovalPricingOption'+JSON.stringify(this.ApprovalPricingOption))
        }
        if (error) {
            console.error(error)
        }
    }
    ChildReords;
    @track loanAppChargeId;
    RAACRofVal;
    product;
    @wire(getDataForFilterChild,{params:'$paramsForLoanAppRec'})
    loanApplicationRecords(wiredLoanApplication) {
        const { data, error } = wiredLoanApplication;
        this._wiredLoanApplication = wiredLoanApplication;
        console.log('this._wiredLoanApplication',this._wiredLoanApplication);
        this.parentRecord={}
        if (data) {
            console.log('this.parentRecord.PricingApprovalApplicable__c'+JSON.stringify(data));
            this.parentRecord=JSON.parse(JSON.stringify(data.parentRecord)); 
            this.wrapLoanAppObj.Id=this.parentRecord.Id;
            this.applicantId=this.parentRecord.Applicant__c;
            this.product=this.parentRecord.Product__c;
            console.log('this.product'+this.product)
            
            
            if(this.parentRecord.PricingApprovalApplicable__c=='Y'){
                this.showPricingFields=true
            }else{
                this.showPricingFields=false
            }
            setTimeout(() => {
                this.template.querySelector('c-uploded-document-display').handleFilesUploaded('cc');
            }, 1000);
            if(data.ChildReords && data.ChildReords != undefined){
                this.ChildReords=JSON.parse(JSON.stringify(data.ChildReords));
               // this.wrapLoanAppObj.RAAC_PF__c=this.ChildReords[0].PF__c;
               this.RAACRofVal=this.ChildReords[0].PF__c;
                this.loanAppChargeId=this.ChildReords[0].Id;
            }    
                
        } else if (error) {
            console.log(error);
        }
    }
    productWithROI
    productWithPF
    @wire(getSobjectData,{params:'$metadataPOIndPF'})
    wiredForMaxROIndPF({ error, data }) {
        if (data) {
           console.log('Metadata Retrieved: ', JSON.stringify(data.parentRecords));
            let productWithROI = {};
            let productWithPF = {};
            data.parentRecords.forEach(record => {
                productWithROI[record.Product_Name__c] = record.Maximum_ROI__c;
                productWithPF[record.Product_Name__c] = record.Maximum_PF__c;
            });
            this.productWithROI=productWithROI;
            this.productWithPF=productWithPF;
            console.log('productWithROINdPF'+JSON.stringify(this.productWithROI))

        } else if (error) {
            console.error('Error retrieving metadata: ', error);
        }
    }

    @track _wiredBRERec;
    @track BRERecParent;
    @track ROIVal;
    @wire(fetchRecords,{params:'$parameter'})
    BRERelatedToLoanAppRecord(wiredBRERec) {
        const { data, error } = wiredBRERec;
        this._wiredBRERec = wiredBRERec;
        console.log('this._wiredBRERec',this._wiredBRERec);
        this.BRERecParent={}
        if (data) {
            console.log('this.BRERecParent.....'+JSON.stringify(data));
            if(typeof data.parentRecord!=='undefined'){
                this.BRERecParent=JSON.parse(JSON.stringify(data.parentRecord)); 
                console.log('this.BRERecParent'+JSON.stringify(data.parentRecord))
                if(typeof this.BRERecParent.RAACROI__c !=='undefined'){
                    //this.wrapLoanAppObj.RAAC_ROI__c=this.BRERecParent.RAACROI__c;   
                    this.ROIVal=this.BRERecParent.RAACROI__c
                }else{
                    this.ROIVal='';
                }
            }else{
                this.ROIVal=''
            }
           
            
                
        } else if (error) {
            console.log(error);
        }
    }
    @track revisedPFVal;
    handleLoanAppliData(event){
        console.log('event.target.value'+event.target.dataset.field)
        this.wrapLoanAppObj[event.target.dataset.field] = event.target.value;
        if(event.target.dataset.field=='PricingApprovalApplicable__c'){
            if(event.target.value=='Y'){
                this.showPricingFields=true
            }else{
                this.showPricingFields=false;
                //LAK-8614
                this.wrapLoanAppObj.RevisedPF__c = '';
                this.wrapLoanAppObj.PricingApprovalDate__c = '';
                this.wrapLoanAppObj.RevisedROI__c = this.wrapLoanAppObj.RAAC_ROI__c;
            }
            
        }
        
    }
    handleLoanAppliDataForBlur(event){
        this.wrapLoanAppObj[event.target.dataset.field] = event.target.value;

        //ADD THIS CODE FOR LAK-7404 TO FIX THE LIMIT FOR ROI AND PF
        let maxValOfROI=this.productWithROI[this.product]
        let MaxValOfPF= this.productWithPF[this.product]
        console.log('maxValOfROI'+maxValOfROI)
        console.log('MaxValOfPF'+MaxValOfPF)
        if(event.target.dataset.field=='RevisedROI__c'){
            if(event.target.value > maxValOfROI){
                this.showToast("Error", "error", "Revised ROI can not be more then " + maxValOfROI +'%',"sticky");
                this.template.querySelector('[data-id="ROIVal"]').value = '';
            }else{
                this.wrapLoanAppObj[event.target.dataset.field] = event.target.value;
            }
        }
        else if(event.target.dataset.field=='RevisedPF__c'){
            if(event.target.value >MaxValOfPF){
                this.showToast("Error", "error",  "Revised PF can not be more then " + MaxValOfPF +'%',"sticky");
                this.template.querySelector('[data-id="PFVal"]').value = '';
            }else{
                this.revisedPFVal=event.target.value;
                this.wrapLoanAppObj[event.target.dataset.field] = event.target.value;
            }
           
        }
    }
    handleValApproName(event){
        console.log('event.detail'+JSON.stringify(event.detail));
        var ApproverRecData=event.detail
        let recId= ApproverRecData.id
        let lookupFieldAPIName=ApproverRecData.lookupFieldAPIName
        console.log('this.sfdcBnkMasLookup.mainField'+ApproverRecData.mainField);
        console.log('event.target.dataset.field'+lookupFieldAPIName);
        this.wrapLoanAppObj[lookupFieldAPIName] = recId;
        console.log('event.target.dataset.field'+JSON.stringify(this.wrapLoanAppObj));

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
        
        console.log('values to save through Lms ', JSON.stringify(values));
        this.handleSaveV(values.validateBeforeSave);

    }
    validate;
    handleSaveV(validate) {
        this.validate=validate
       //add this for LAK-7766 (check document details record present or not)
        this.forLatestDocDetail();
        
        if(validate){
            if(this.checkValidation() && this.checkValidityLookup()){
                setTimeout(() => {
                    if(this.showPricingFields && this.FileInDisplay.length==0){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Error",
                                message: this.label.Legal_Property_File_Req,
                                variant: "error",
                                mode: "sticky"
                            })
                        );
                    }else{
                        this.handleSave()
                    }
                }, 1000);
                
              
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
    handleSave() {
        this.showSpinner=true;         
        let ChildRecords = [];
        //let childRecordObj = {};
            
        this.wrapLoanAppObj.sobjectType='LoanAppl__c';     
        console.log('insavemethod'+JSON.stringify(this.wrapLoanAppObj));       
        let upsertData={                       
            parentRecord:this.wrapLoanAppObj,                       
            ChildRecords:ChildRecords,
            ParentFieldNameToUpdate:''
        }
                          
        updateData ({upsertData:upsertData})
        .then(result => {  
            console.log('resultresultresultresultresult'+JSON.stringify(result))  
            this.dispatchEvent(
                new ShowToastEvent({
                       title: "Success",
                       message: this.label.ApprovalPricLoanAppRecUpdated,
                       variant: "success",
                       mode: "sticky"
                   })
               );
            //this.saveConVerData();
            /*if(this.filesForApp.length >0){
                
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: this.label.ApprovalPricLoanAppRecUpdated,
                            variant: "success",
                            mode: "sticky"
                    })
                );
            }else{
                if(this.validate && this.showPricingFields && this.FileInDisplay.length==0){
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
                               message: this.label.ApprovalPricLoanAppRecUpdated,
                               variant: "success",
                               mode: "sticky"
                           })
                       );
                }
            }*/                  
            this.showSpinner=false;
            this.updateloanAppChargeRec();
           this.updateloanAppRec();
            refreshApex(this._wiredLoanApplication); 
            
                
                
        }).catch(error => {
            
            console.log(error);
        })
            
    }
    updateloanAppChargeRec(){
        if(typeof this.loanAppChargeId!=='undefined' && typeof this.wrapLoanAppObj.RevisedPF__c !=='undefined'){
            const fields = {}; 
            fields[CHARGE_ID_FIELD.fieldApiName] = this.loanAppChargeId;
            fields[REVIPF_VAL_FIELD.fieldApiName] =this.wrapLoanAppObj.RevisedPF__c;
            const recordInput = { fields };
            console.log('recordInput--->',recordInput);
            updateRecord(recordInput)
            .then((result) => {             
            console.log('inside update record'+JSON.stringify(result));
            
            
        })
        .catch(error => {
                   });
        }
    }
    updateloanAppRec(){
        if(typeof this.recordId !=='undefined' && typeof this.wrapLoanAppObj.RevisedROI__c !=='undefined'){
            const fields = {}; 
            fields[LOAN_APP_ID.fieldApiName] = this.recordId;
            fields[ROI_VAL_FIELD.fieldApiName] =this.wrapLoanAppObj.RevisedROI__c;
            const recordInput = { fields };
            console.log('recordInput--->>>>>>>>>>>>>',recordInput);
            updateRecord(recordInput)
            .then((result) => {             
            console.log('inside update record>>>>>>>.'+JSON.stringify(result));
            
            
        })
        .catch(error => {
                   });
        }
    }

    fromUploadDocsContainer(event){
        var documentDeatilData=event.detail
        this.docDetailIdForApp=documentDeatilData.docDetailId;
        var docId= documentDeatilData.docDetailId;
        console.log('in parennntttt'+documentDeatilData.docDetailId) 
        this.forLatestDocDetailRec(this.docCategory, this.docType, this.docSubType, docId);
        //this.updateDocDetailWithLoanApp(this.docDetailIdForApp)  
    }
    forLatestDocDetailRec(docCat, docTyp, docSubTyp, docId) {
        console.log('document details in forLatestDocDetailRec ###1456', docTyp, docCat, docSubTyp, docId);
        var listOfAllParent = [];
        var paramForIsLatest = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'Appl__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c'],
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this.recordId + '\' AND Appl__c = \'' + this.applicantId + '\' AND DocCatgry__c = \'' + docCat + '\' AND DocTyp__c = \'' + docTyp + '\' AND DocSubTyp__c = \'' + docSubTyp + '\''
        }
        getSobjectDataFoDetail({ params: paramForIsLatest })
            .then((result) => {
                console.log('islatestdata 13899999', docId);
                if (result.parentRecords) {
                    listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
                }
                let oldRecords = []
                oldRecords = listOfAllParent.filter(record => record.Id !== docId);
                //console.log('oldRecords>>>>>'+JSON.stringify(oldRecords))
                let isLatestFalseRecs = []
                isLatestFalseRecs = oldRecords.map(record => {
                    return { ...record, IsLatest__c: false };
                    return record;
                });
                console.log('isLatestFalseRecs>>>>>' + JSON.stringify(isLatestFalseRecs))
                upsertMultipleRecord({ params: isLatestFalseRecs })
                    .then(result => {
                        setTimeout(() => {
                            this.template.querySelector('c-uploded-document-display').handleFilesUploaded('cc');
                        }, 1000);

                    }).catch(error => {
                        console.log('778' + error)
                    })

            })
            .catch((error) => {
                console.log('Error In getting 13899999 ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    //updateDocDetailWithLoanApp(documentDetailId){
        //const fields = {};           
        /*fields[DOC_FIELD.fieldApiName] = documentDetailId;
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
                   });*/
    //}
    @track filesForApp=[];
    parentFileChange(event){
       this.filesForApp=event.detail.fileList
        console.log('il'+this.filesForApp.length)
    
    }
    @track FileInDisplay=[]
    handleFileUploadList(event){
        console.log('<<><><><'+event.detail)
        
            this.FileInDisplay=event.detail;
            console.log('in parentFileChangeforlegal'+this.FileInDisplay.length)    
        
        
    }
    //add this for LAK-7766 (check document details record present or not)
    forLatestDocDetail() {
        console.log('document details in forLatestDocDetailRec ###1456'+this.docCategory, this.docType, this.docSubType);
        var listOfAllParent = [];
        var paramForIsLatest = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'Appl__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c'],
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this.recordId + '\' AND Appl__c = \'' + this.applicantId + '\' AND DocCatgry__c = \'' + this.docCategory + '\' AND DocTyp__c = \'' + this.docType + '\' AND DocSubTyp__c = \'' + this.docSubType + '\''
        }
        getSobjectDataFoDetail({ params: paramForIsLatest })
            .then((result) => {
               
                if (result.parentRecords) {
                    listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
                }
                
                if(listOfAllParent.length>0){

                }else{
                    this.FileInDisplay=''
                }
                
                

            })
            .catch((error) => {
                console.log('Error In getting 13899999 ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

}