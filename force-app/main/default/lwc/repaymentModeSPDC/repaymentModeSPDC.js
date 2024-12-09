import { LightningElement,api,wire,track} from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord,updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchSingleObject from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import updateRegPer from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getData from '@salesforce/apex/SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords';
import upsertManualRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleParentsWithMultipleChilds';
import { getRecord, getObjectInfo ,getPicklistValues, getPicklistValuesByRecordType} from 'lightning/uiObjectInfoApi';
import PDCObj from '@salesforce/schema/PDC__c';
import PURPOSE from '@salesforce/schema/PDC__c.Cheque_Purpose__c';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
// Custom labels
import RepaymentSpdc_Update_SuccessMessage from '@salesforce/label/c.RepaymentSpdc_Update_SuccessMessage';
import RepaymentSpdc_Del_SuccessMessage from '@salesforce/label/c.RepaymentSpdc_Del_SuccessMessage';
import Repayment_PastDateError from '@salesforce/label/c.Repayment_PastDateError';
import Repayment_ChequeNumber from '@salesforce/label/c.Repayment_ChequeNumber';
import Repayment_ChequeFrom from '@salesforce/label/c.Repayment_ChequeFrom';
import Repayment_Du from '@salesforce/label/c.Repayment_Du';
import SPDCMinThreeCheque from '@salesforce/label/c.SPDCMinThreeCheque';
export default class RepaymentModeSPDC extends LightningElement {
    customLabel = {
        RepaymentSpdc_Update_SuccessMessage,
        RepaymentSpdc_Del_SuccessMessage,
        Repayment_PastDateError,
        Repayment_ChequeNumber,
        Repayment_ChequeFrom,
        Repayment_Du,
        SPDCMinThreeCheque

    }
    @track _loanAppId;
    required=true;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        console.log('Loan App Id in spdc ! '+value);
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);            
        this.handleRecordIdChange(value);        
    }

   // loanAppId='a08C40000063xjHIAQ';

    @api isReadOnly;
    @track disableMode;
    @api hasEditAccess;
    @track _wiredRepayData;
    @track RepayResult=[]
    @track AllPDCRecords=[]
    @track AllSPDCRecords=[]
    RepayParentRecord=[]
    RepayChildRecord=[]
    spdcParentRecord=[]
    spdcChildRecord=[]
    mdtNames=[]
    isCheck= false;
    @track lookupRec
    @track RepaymentIdfromParentRecord
    ChequePurposeOptions=[]
    @track _wiredRepaySPDCData;
    @track _wiredmdtData;
    @track _wirePDC
    @track MICRValue;
    MICRIndex;
    EnteredDate;
    currentDate;
    @track parentDetails={ }

   
    @track SPDCType = 'SPDC'
    handleRecordIdChange(){        
        let tempParams = this.params;
        tempParams.queryCriteria = ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Is_Active__c = true';
        this.params = {...tempParams};

        let tempspdcParams = this.spdcParam;
        tempspdcParams.queryCriteria = ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Repayment_Account__c	= \'' + this.RepaymentIdfromParentRecord + '\'AND PDC_Type__c = \''+this.SPDCType +'\' ';
        this.spdcParam = {...tempspdcParams};

       
    }
    @track mdtParam ={
        ParentObjectName:'MICRCodeMstr__c',        
        parentObjFields:['MICRCode__c','Id','BrchName__c','IFSCCode__c','BanckBrchId__c'],              
        queryCriteria: ''

    }
    @track params={
        ParentObjectName:'Repayment_Account__c',
        ChildObjectRelName:'PDC__r',
        parentObjFields:['Id','SameASRepayment__c','Applicant_Banking__r.Appl__r.FullName__c','Loan_Application__c','Bank_Name__c','Bank_Branch__c','IFSC_Code__c','Account_Number__c','Is_Active__c','MICR_Code__c','Repayment_Mode__c'],
        childObjFields:['Id','Cheque_Number_From__c','Cheque_Number_To__c','PDC_Type__c','No_of_Cheques__c','Name','Loan_Application__c','Repayment_Account__c','Cheque_Purpose__c','Cheque_Amount__c','Cheque_Available_EMI__c','Pending_Cheque__c'],        
        queryCriteria: ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Is_Active__c = true '

    }

   

    @track spdcParam ={
        ParentObjectName:'PDC__c',        
        parentObjFields:['Id','Repayment_Account__c','Repayment_Account__r.Account_Number__c','Account_No__c','Same_As_Repayment_Account__c','Bank_Name__c','Bank_Branch__c','IFSC_Code__c','MICR_Code__c','Cheque_Number_From__c','Cheque_Number_To__c','PDC_Type__c','No_of_Cheques__c','Name','Loan_Application__c','Cheque_Purpose__c','Cheque_Amount__c','Cheque_Available_EMI__c','Pending_Cheque__c','Repayment_Account__r.Applicant_Banking__r.Appl__r.FullName__c'],              
        queryCriteria: ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Repayment_Account__c	= \'' + this.RepaymentIdfromParentRecord + '\' AND PDC_Type__c = \''+this.SPDCType +'\' '

    }
    
//fetching  repayment details
    @wire(getData,{params:'$params'})
    RepayData(wiredRepayData) {
        console.log(' Loan id in parent comp' ,this.loanAppId);       
        const { data, error } = wiredRepayData;
        this._wiredRepayData = wiredRepayData;
        
        if (data) {
            //if(data!=undefined && data!=null)
        //    if(data[0].parentRecord!=undefined && data[0].parentRecord!=null){
           
            // this.RepayResult=JSON.stringify(data)
            this.RepayResult=JSON.parse(JSON.stringify(data))
            console.log('repay spdc 123',this.RepayResult)
            if(this.RepayResult[0] !=undefined && this.RepayResult[0]!=null){
                if(this.RepayResult[0].parentRecord!=undefined && this.RepayResult[0].parentRecord!=null){
            this.RepayParentRecord=JSON.parse(JSON.stringify(data[0].parentRecord));            
           
           
            this.RepaymentIdfromParentRecord = this.RepayParentRecord.Id
            this.parentDetails.MICR_Code__c = this.RepayParentRecord.MICR_Code__c ? this.RepayParentRecord.MICR_Code__c : '';
            this.parentDetails.Bank_Name__c = this.RepayParentRecord.Bank_Name__c ? this.RepayParentRecord.Bank_Name__c : '';
            this.parentDetails.Bank_Branch__c = this.RepayParentRecord.Bank_Branch__c ? this.RepayParentRecord.Bank_Branch__c : '';
            this.parentDetails.Id = this.RepayParentRecord.Id;
            if(this.RepayParentRecord.Applicant_Banking__r){
                      if(this.RepayParentRecord.Applicant_Banking__r.Appl__r){
            this.parentDetails.PDCbyName = this.RepayParentRecord.Applicant_Banking__r.Appl__r.FullName__c ? this.RepayParentRecord.Applicant_Banking__r.Appl__r.FullName__c : '';
                      }}
            this.parentDetails.IFSC_Code__c = this.RepayParentRecord.IFSC_Code__c ? this.RepayParentRecord.IFSC_Code__c : '';
            this.parentDetails.Account_Number__c = this.RepayParentRecord.Account_Number__c ?  this.RepayParentRecord.Account_Number__c  : '';
            this.parentDetails.Loan_Application__c = this.RepayParentRecord.Loan_Application__c;
            this.parentDetails.Repayment_Account__c = this.RepayParentRecord.Id;

            // let temppdcParams = this.pdcParam;
            // temppdcParams.queryCriteria = ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Repayment_Account__c	= \'' + this.RepaymentIdfromParentRecord + '\' AND PDC_Type__c = \'PDC\' ';
            // this.pdcParam = {...temppdcParams};
    
            let tempspdcParams = this.spdcParam;
            tempspdcParams.queryCriteria = ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Repayment_Account__c	= \'' + this.RepaymentIdfromParentRecord + '\' AND PDC_Type__c = \'SPDC\' ';
            this.spdcParam = {...tempspdcParams};

            console.log(' this.spdcParam', this.spdcParam)
    
        } }}else if (error) {
            console.log(error);
        }
    }

    @track hasSPDCRecords=false;
    @wire(fetchSingleObject,{params:'$spdcParam'})
    RepaySPDCData(wiredRepaySPDCData) {
        console.log(' Loan id in parent comp' ,this.loanAppId);       
        const { data, error } = wiredRepaySPDCData;
        this._wiredRepaySPDCData = wiredRepaySPDCData;
        this.hasSPDCRecords=false;
        this.AllSPDCRecords=[]
        if (data && data.parentRecords)  {
            if(data.parentRecords!=undefined && data.parentRecords!=null){
            console.log('inside spdc _wiredRepaySPDCData',this._wiredRepaySPDCData)
            this.hasSPDCRecords=true;
            const tospdcrecords = new CustomEvent('tospdcrecords', {
                detail: { hasSPDCRecords: this.hasSPDCRecords }  // Boolean value
            });
            this.dispatchEvent(tospdcrecords);
                      
            this.spdcChildRecord=JSON.parse(JSON.stringify(data.parentRecords));
           
            for(var i=0;i< this.spdcChildRecord.length;i++){  

                    let spdcRecordObj={}
                    spdcRecordObj.Same_As_Repayment_Account__c =  this.spdcChildRecord[i].Same_As_Repayment_Account__c;
                spdcRecordObj.Cheque_Number_From__c = this.spdcChildRecord[i].Cheque_Number_From__c;
                spdcRecordObj.Cheque_Number_To__c = this.spdcChildRecord[i].Cheque_Number_To__c;
                spdcRecordObj.No_of_Cheques__c = this.spdcChildRecord[i].No_of_Cheques__c;

                spdcRecordObj.MICR_Code__c =  this.spdcChildRecord[i].MICR_Code__c ;
                spdcRecordObj.Bank_Name__c =  this.spdcChildRecord[i].Bank_Name__c;
                spdcRecordObj.Bank_Branch__c =  this.spdcChildRecord[i].Bank_Branch__c;
                if(this.spdcChildRecord[i].Repayment_Account__r){
                    // spdcRecordObj.Account_Number__c = this.spdcChildRecord[i].Repayment_Account__r.Account_Number__c;
                    if(this.spdcChildRecord[i].Repayment_Account__r.Applicant_Banking__r){
                        if(this.spdcChildRecord[i].Repayment_Account__r.Applicant_Banking__r.Appl__r){
                spdcRecordObj.PDCbyName =  this.spdcChildRecord[i].Repayment_Account__r.Applicant_Banking__r.Appl__r.FullName__c;
                    }}}
                spdcRecordObj.IFSC_Code__c =  this.spdcChildRecord[i].IFSC_Code__c;
                 spdcRecordObj.Account_Number__c = this.spdcChildRecord[i].Account_No__c ;

                spdcRecordObj.Cheque_Purpose__c = this.spdcChildRecord[i].Cheque_Purpose__c;
                spdcRecordObj.Cheque_Amount__c = this.spdcChildRecord[i].Cheque_Amount__c;
                spdcRecordObj.Cheque_Available_EMI__c = this.spdcChildRecord[i].Cheque_Available_EMI__c;
                spdcRecordObj.Pending_Cheque__c = this.spdcChildRecord[i].Pending_Cheque__c;
                spdcRecordObj.Loan_Application__c =  this.spdcChildRecord[i].Loan_Application__c;
                // spdcRecordObj.Repayment_Account__c = this.spdcChildRecord[i].Repayment_Account__c;
                spdcRecordObj.Repayment_Account__c= this.spdcChildRecord[i].Repayment_Account__c;
                spdcRecordObj.Id = this.spdcChildRecord[i].Id;
              

                this.AllSPDCRecords.push(spdcRecordObj);
                
                

            }
        console.log('AllPDCRecords',this.AllPDCRecords)
        console.log('AllSPDCRecords spdc',this.AllSPDCRecords)
        }
    } else if (error) {
            console.log(error);
            const tospdcrecords = new CustomEvent('tospdcrecords', {
                detail: { hasSPDCRecords: this.hasSPDCRecords }  // Boolean value
            });
            this.dispatchEvent(tospdcrecords);
        }
        else{
            const tospdcrecords = new CustomEvent('tospdcrecords', {
                detail: { hasSPDCRecords: this.hasSPDCRecords }  // Boolean value
            });
            this.dispatchEvent(tospdcrecords);
        }
    }

    //Records Availability
    
    // values for unchecked

    handleValueSelect(event) {
        console.log('handleValueSelect');
        this.lookupRec = event.detail;
        let lookupId = this.lookupRec.id;
        let lookupAPIName = this.lookupRec.lookupFieldAPIName;
        const outputObj = { [lookupAPIName]: lookupId };
        if (event.target.fieldName === 'MICR_Code__c') {    
           
             this.AllSPDCRecords[event.target.index].MICR_Code__c = this.lookupRec.mainField;
            this.AllSPDCRecords[event.target.index].MICRCodeID__c =lookupId; 
            //this.AllSPDCRecords[event.target.index].MICR_Code__c = lookupId;

            this.MICRValue= this.AllSPDCRecords[event.target.index].MICR_Code__c;
            this.AllSPDCRecords[event.target.index].isDirty=true;
           // this.AllSPDCRecords[event.target.index].MICRCode__c= this.MICRValue
            //this.AllSPDCRecords[event.target.index].MICRCodeID__c = lookupId; 
            this.MICRIndex =event.target.index;


            // if(this.AllSPDCRecords[event.target.index].Cheque_Number_To__c!='' & this.AllSPDCRecords[event.target.index].Cheque_Number_From__c!=''){  
            //     if(this.AllSPDCRecords[event.target.index].Cheque_Number_To__c - this.AllSPDCRecords[event.target.index].Cheque_Number_From__c +1 <3){
            //         this.AllSPDCRecords[event.target.index].isDirty=false;
            //         console.log('dirty',this.AllSPDCRecords[event.target.index].isDirty)
            //     }}
            

            let tempvalueParams = this.valueParam;
            tempvalueParams.queryCriteria = ' where MICRCode__c	= \'' + this.MICRValue + '\'';
            this.valueParam = {...tempvalueParams};
        console.log('MICRValue',this.MICRValue)
        }
        
        console.log('--handle change--------'+JSON.stringify(this.AllSPDCRecords))
    }

    @track  valueParam ={
        ParentObjectName:'MICRCodeMstr__c',        
        parentObjFields:['MICRCode__c','Id','BrchName__c','IFSCCode__c','BanckBrchId__c','Bank__c','Bank__r.Name'],              
        queryCriteria: ' where MICRCode__c	= \'' + this.MICRValue + '\''

    }

    @wire(fetchSingleObject,{params:'$valueParam'})
    mdtData (wiredmdtData) {
      const { data, error } = wiredmdtData;
      this._wiredmdtData = wiredmdtData;        
       
        if (data) {
            if(data.parentRecords!=undefined && data.parentRecords!=null){
            this.mdtNames=JSON.parse(JSON.stringify(data.parentRecords));
            console.log('customlookup  this.mdtNames', data)
                    
                     if(this.mdtNames[0].Bank__c){   
                        console.log('bank name',this.mdtNames[0].Bank__r.Name)                     
                        this.AllSPDCRecords[this.MICRIndex].Bank_Name__c=this.mdtNames[0].Bank__r.Name;
                        console.log('bank name',this.mdtNames[0].Bank__r.Name)
                        }
                        if(this.mdtNames[0].BrchName__c){
                            this.AllSPDCRecords[this.MICRIndex].Bank_Branch__c=this.mdtNames[0].BrchName__c;
                        }
                            if(this.mdtNames[0].IFSC_Code__c){
                            this.AllSPDCRecords[this.MICRIndex].IFSC_Code__c=this.mdtNames[0].IFSC_Code__c;
                        }

                        // if(this.mdtNames[0].MICRCode__c){
                        //     this.AllSPDCRecords[this.MICRIndex].MICRCode__c=this.mdtNames[0].MICRCode__c;
                        // }

                       
                }   }   

        if(error) {
                console.log(error);
            }
    
    }
    
    //picklist value for cheque purpose

    @wire(getObjectInfo,{objectApiName:PDCObj})
    objInfo

    generatePicklist(data){
        return data.values.map(item =>({ label: item.label, value: item.value }))
    } 
    
    @wire(getPicklistValues,{recordTypeId : '$objInfo.data.defaultRecordTypeId', fieldApiName : PURPOSE})
    TreatmentHandler({data,error}){
        if(data){
            console.log('picklist data',data);
            // this.ChequePurposeOptions = [...this.generatePicklist(data)]
            
            
            let tempOptions =[...this.generatePicklist(data)]
            console.log('tempOptions',tempOptions);

            this.ChequePurposeOptions=[...tempOptions]
        }
        if(error){
            console.log(error)
        }
    }
    
    handleInputChangeSPDC(event)
    {
        const inputBox = event.currentTarget;
        inputBox.setCustomValidity('');
        inputBox.reportValidity();
        let IndexRow = event.target.dataset.index
        console.log('IndexRow',IndexRow)
        let SPDCRepayDetails = this.AllSPDCRecords[event.target.dataset.index]
        console.log('SPDCRepayDetails',SPDCRepayDetails)
        
        const positiveNumberPattern = /^\d{6}$/;
        if(event.target.dataset.name === 'Cheque_Number_To__c' || event.target.dataset.name === 'Cheque_Number_From__c' )

        {
            if(event.target.dataset.name === 'Cheque_Number_From__c'){
                if (!positiveNumberPattern.test(event.target.value)) {
                
                    this.showToast("Error!", "error", this.customLabel.Repayment_ChequeNumber,"sticky");
    
                    const items =this.template.querySelectorAll('[data-id="chequeFrom"]');
                        if(items.length>0){
                            const firstItem=items[event.target.dataset.index];
                            firstItem.value='';
                        }
                        
                    return;
                }  
            }

            if(event.target.dataset.name === 'Cheque_Number_To__c'){
                if (!positiveNumberPattern.test(event.target.value) ) {
                
                    this.showToast("Error!", "error", this.customLabel.Repayment_ChequeNumber,"sticky");
                                   
                    const itemsTo =this.template.querySelectorAll('[data-id="chequeTo"]');
                    if(itemsTo.length>0){
                        const lastItem=itemsTo[event.target.dataset.index];
                        lastItem.value='';
                    }
                    return;
                }  
            }
            
            
            if(event.target.dataset.name === 'Cheque_Number_To__c'){
               // let eventNumber=parseInt(event.target.value)
               if(event.target.value< SPDCRepayDetails.Cheque_Number_From__c){
                const itemsTo =this.template.querySelectorAll('[data-id="chequeTo"]');
                    if(itemsTo.length>0){
                        const lastItem=itemsTo[event.target.dataset.index];
                        lastItem.value='';
                    }
                    this.showToast("Error!", "error", this.customLabel.Repayment_ChequeFrom,"sticky");
                    return;
                }
                
            }
            if(event.target.dataset.name === 'Cheque_Number_To__c' || event.target.dataset.name === 'Cheque_Number_From__c')
        {
            for (let i = 0; i < this.AllSPDCRecords.length; i++){
                if(i!=IndexRow){
                    if(event.target.value>=this.AllSPDCRecords[i].Cheque_Number_From__c && event.target.value<=this.AllSPDCRecords[i].Cheque_Number_To__c ){
                        const items =this.template.querySelectorAll('[data-id="chequeFrom"]');
                        if(items.length>0){
                            const firstItem=items[event.target.dataset.index];
                            firstItem.value='';
                        }
                        this.showToast("Error!", "error", this.customLabel.Repayment_Du,"sticky");
                        return;  
                    }
                    
                }               

            }
        }
        console.log('this.minCheckFlag',this.minCheckFlag)
        SPDCRepayDetails[event.target.dataset.name] = event.target.value; 
        
        //let countOfCheque = (SPDCRepayDetails.Cheque_Number_To__c -SPDCRepayDetails.Cheque_Number_From__c)+1;
        
        // if(SPDCRepayDetails.Cheque_Number_To__c!='' & SPDCRepayDetails.Cheque_Number_From__c!=''){
        // if(countOfCheque!= null & countOfCheque<3){
        //     this.showToast("Error!", "error", 'No Of Cheques should be atleast 3',"sticky");
        //     SPDCRepayDetails.No_of_Cheques__c = (SPDCRepayDetails.Cheque_Number_To__c -SPDCRepayDetails.Cheque_Number_From__c)+1;
        //     SPDCRepayDetails.isDirty=false;
        //     return;
        // }}

        
        SPDCRepayDetails.isDirty=true;     
       // if(SPDCRepayDetails.Cheque_Number_To__c!='' & SPDCRepayDetails.Cheque_Number_From__c!=''){   
         SPDCRepayDetails.No_of_Cheques__c = (SPDCRepayDetails.Cheque_Number_To__c -SPDCRepayDetails.Cheque_Number_From__c)+1;
       // }
    }


        if(event.target.dataset.name === 'Cheque_Available_EMI__c'){
            SPDCRepayDetails[event.target.dataset.name] = event.target.value; 
        SPDCRepayDetails.isDirty=true;
            this.EnteredDate=event.target.value;
          this.currentDate= new Date().toISOString().substring(0, 10);
            if(this.checkDate()){
                SPDCRepayDetails.Cheque_Available_EMI__c=this.EnteredDate
            }
           
            
        }

        SPDCRepayDetails[event.target.dataset.name] = event.target.value; 

        SPDCRepayDetails.isDirty=true;
        this.AllSPDCRecords[event.target.dataset.index] = SPDCRepayDetails;

        // if(SPDCRepayDetails.Cheque_Number_To__c!='' & SPDCRepayDetails.Cheque_Number_From__c!=''){  
        // if(SPDCRepayDetails.No_of_Cheques__c<3){
        //     SPDCRepayDetails.isDirty=false;
        //     console.log('dirty spdc',SPDCRepayDetails.isDirty)
        // }}
       // this.handleDispatch();

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
    checkDate(){
        if(this.EnteredDate < this.currentDate){
            // this.showToast("Error", "error", "should not be past date");
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.customLabel.Repayment_PastDateError,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
            return false 
        }else{

           return true;
        }
    }


     //handle check for prepopulate data
     checkboxHandler(event){

        this.isCheck=event.target.checked;
        let RepayDetails = this.AllSPDCRecords[event.target.dataset.index]
        RepayDetails[event.target.dataset.name] = event.target.checked; 
        this.AllSPDCRecords[event.target.dataset.index] = RepayDetails;
       RepayDetails.isDirty=true;
       console.log('event check',this.isCheck)
       console.log('event ',event.target.checked)
       if(this.isCheck==true)
       {
        this.AllSPDCRecords[event.target.dataset.index].MICR_Code__c=this.parentDetails.MICR_Code__c
        this.AllSPDCRecords[event.target.dataset.index].Bank_Name__c=this.parentDetails.Bank_Name__c
        this.AllSPDCRecords[event.target.dataset.index].Bank_Branch__c=this.parentDetails.Bank_Branch__c
        this.AllSPDCRecords[event.target.dataset.index].IFSC_Code__c=this.parentDetails.IFSC_Code__c
        this.AllSPDCRecords[event.target.dataset.index].Account_Number__c=this.parentDetails.Account_Number__c
        this.AllSPDCRecords[event.target.dataset.index].SameASRepayment__c=this.isCheck
       }
       if(this.isCheck==false)
       {
        this.AllSPDCRecords[event.target.dataset.index].MICR_Code__c=''
        this.AllSPDCRecords[event.target.dataset.index].Bank_Name__c=''
        this.AllSPDCRecords[event.target.dataset.index].Bank_Branch__c=''
        this.AllSPDCRecords[event.target.dataset.index].IFSC_Code__c=''
        this.AllSPDCRecords[event.target.dataset.index].Account_Number__c=''
        this.AllSPDCRecords[event.target.dataset.index].SameASRepayment__c=this.isCheck
       }

    }



    //dispatch

     handleDispatch()
     {
        
        let sum=0;
 
     let SPDCChildRecords = [];
         let spdcchildRecordObj = {};
         for(var i=0;i<this.AllSPDCRecords.length;i++){
            sum += this.AllSPDCRecords[i].No_of_Cheques__c;
             if(this.AllSPDCRecords[i].isDirty){
                 spdcchildRecordObj = {};
                 spdcchildRecordObj.sobjectType='PDC__c';
                 spdcchildRecordObj.Cheque_Number_From__c=this.AllSPDCRecords[i].Cheque_Number_From__c;
                 spdcchildRecordObj.Cheque_Number_To__c=this.AllSPDCRecords[i].Cheque_Number_To__c;
                 spdcchildRecordObj.No_of_Cheques__c=this.AllSPDCRecords[i].No_of_Cheques__c;
                 spdcchildRecordObj.Cheque_Purpose__c=this.AllSPDCRecords[i].Cheque_Purpose__c;
                 spdcchildRecordObj.Cheque_Amount__c=this.AllSPDCRecords[i].Cheque_Amount__c;
                 spdcchildRecordObj.Cheque_Available_EMI__c=this.AllSPDCRecords[i].Cheque_Available_EMI__c;
                 spdcchildRecordObj.Pending_Cheque__c=this.AllSPDCRecords[i].Pending_Cheque__c;
                // childRecordObj.Loan_Application__c=this.AllPDCRecords[i].Loan_Application__c;
                spdcchildRecordObj.Loan_Application__c=this.loanAppId;
                spdcchildRecordObj.Repayment_Account__c=this.AllSPDCRecords[i].Repayment_Account__c;
                spdcchildRecordObj.Id=this.AllSPDCRecords[i].Id;
 
                spdcchildRecordObj.PDC_Type__c='SPDC';
 
                spdcchildRecordObj.MICR_Code__c=this.AllSPDCRecords[i].MICR_Code__c;
                spdcchildRecordObj.Bank_Name__c=this.AllSPDCRecords[i].Bank_Name__c;
                spdcchildRecordObj.Bank_Branch__c=this.AllSPDCRecords[i].Bank_Branch__c;
                spdcchildRecordObj.IFSC_Code__c=this.AllSPDCRecords[i].IFSC_Code__c;
                spdcchildRecordObj.Account_No__c =this.AllSPDCRecords[i].Account_Number__c;
                spdcchildRecordObj.PDCbyName=this.AllSPDCRecords[i].PDCbyName;
                spdcchildRecordObj.Same_As_Repayment_Account__c=this.AllSPDCRecords[i].Same_As_Repayment_Account__c;
                
                SPDCChildRecords.push(spdcchildRecordObj);
             }

         }
         const noOFChequeCount = new CustomEvent('noOFChequeCount', {
            detail:  sum
        });
        console.log('before dispatch sum',sum)
        this.dispatchEvent(noOFChequeCount);

        const SPDCData = new CustomEvent('SPDCData', {
            detail:  SPDCChildRecords
        });
        console.log('before dispatch spdcdata',SPDCChildRecords)
        this.dispatchEvent(SPDCData);
         
        //  if(sum<3){
        //     this.showToast("Error!", "error", this.customLabel.SPDCMinThreeCheque,"sticky");
        //     this.ErrorFlag=true;
        //     this.dispatchEvent(new CustomEvent('flag',{detail:{value:this.ErrorFlag}}));
        //  }
        //  else{
        //  upsertMultipleRecord({params:SPDCChildRecords})
        //  .then(result => {                     
            
        //      this.showMessage();
        //      refreshApex(this._wiredRepaySPDCData);    
                              
             
        //  }).catch(error => {
        //      console.log(error);
        //  })
        // }
     }
    
    // handle save
    @track ErrorFlag=false;
    @api 
     handlechildSave()
     {
        console.log('spdc record in child method',JSON.stringify(this.AllSPDCRecords));
    //     let sum=0;
 
    //  let SPDCChildRecords = [];
    //      let spdcchildRecordObj = {};
    //      for(var i=0;i<this.AllSPDCRecords.length;i++){
    //         sum += this.AllSPDCRecords[i].No_of_Cheques__c;
    //          if(this.AllSPDCRecords[i].isDirty){
    //              spdcchildRecordObj = {};
    //              spdcchildRecordObj.sobjectType='PDC__c';
    //              spdcchildRecordObj.Cheque_Number_From__c=this.AllSPDCRecords[i].Cheque_Number_From__c;
    //              spdcchildRecordObj.Cheque_Number_To__c=this.AllSPDCRecords[i].Cheque_Number_To__c;
    //              spdcchildRecordObj.No_of_Cheques__c=this.AllSPDCRecords[i].No_of_Cheques__c;
    //              spdcchildRecordObj.Cheque_Purpose__c=this.AllSPDCRecords[i].Cheque_Purpose__c;
    //              spdcchildRecordObj.Cheque_Amount__c=this.AllSPDCRecords[i].Cheque_Amount__c;
    //              spdcchildRecordObj.Cheque_Available_EMI__c=this.AllSPDCRecords[i].Cheque_Available_EMI__c;
    //              spdcchildRecordObj.Pending_Cheque__c=this.AllSPDCRecords[i].Pending_Cheque__c;
    //             // childRecordObj.Loan_Application__c=this.AllPDCRecords[i].Loan_Application__c;
    //             spdcchildRecordObj.Loan_Application__c=this.loanAppId;
    //             spdcchildRecordObj.Repayment_Account__c=this.AllSPDCRecords[i].Repayment_Account__c;
    //             spdcchildRecordObj.Id=this.AllSPDCRecords[i].Id;
 
    //             spdcchildRecordObj.PDC_Type__c='SPDC';
 
    //             spdcchildRecordObj.MICR_Code__c=this.AllSPDCRecords[i].MICR_Code__c;
    //             spdcchildRecordObj.Bank_Name__c=this.AllSPDCRecords[i].Bank_Name__c;
    //             spdcchildRecordObj.Bank_Branch__c=this.AllSPDCRecords[i].Bank_Branch__c;
    //             spdcchildRecordObj.IFSC_Code__c=this.AllSPDCRecords[i].IFSC_Code__c;
    //             spdcchildRecordObj.Account_No__c =this.AllSPDCRecords[i].Account_Number__c;
    //             spdcchildRecordObj.PDCbyName=this.AllSPDCRecords[i].PDCbyName;
    //             spdcchildRecordObj.Same_As_Repayment_Account__c=this.AllSPDCRecords[i].Same_As_Repayment_Account__c;
                
    //             SPDCChildRecords.push(spdcchildRecordObj);
    //          }
    //      }
         return this.AllSPDCRecords;
        //  if(sum<3){
        //     this.showToast("Error!", "error", this.customLabel.SPDCMinThreeCheque,"sticky");
        //     this.ErrorFlag=true;
        //     this.dispatchEvent(new CustomEvent('flag',{detail:{value:this.ErrorFlag}}));
        //  }
        //  else{
        //  upsertMultipleRecord({params:SPDCChildRecords})
        //  .then(result => {                     
            
        //      this.showMessage();
        //      refreshApex(this._wiredRepaySPDCData);    
                              
             
        //  }).catch(error => {
        //      console.log(error);
        //  })
        // }
     }
     @api 
     handleRefreshchildSave()
     {
        console.log('refresh method in child this._wiredRepaySPDCData',this._wiredRepaySPDCData)
        return refreshApex(this._wiredRepaySPDCData);
     }   

     showMessage()
     {
     this.dispatchEvent(
                         new ShowToastEvent({
                             title: "Success",
                             message: this.customLabel.RepaymentSpdc_Update_SuccessMessage,
                             variant: "success",
                             mode: "sticky"
                         }))
     }
 
     //add row spdc
     handleSPDCAddRow(){
         let SPDCAdd ={
             "Cheque_Number_From__c" : '',
             "Cheque_Number_To__c" : '',
             "No_of_Cheques__c" : '',
             // "MICR_Code__c":this.spdcParentRecord.MICR_Code__c,
             // "Bank_Name__c":this.spdcParentRecord.Bank_Name__c,
             // "Bank_Branch__c":this.spdcParentRecord.Bank_Branch__c,
             "MICR_Code__c":'',
             "Bank_Name__c":'',
             "Bank_Branch__c":'',
             "PDCbyName" :this.parentDetails.PDCbyName,
             // "IFSC_Code__c" : this.spdcParentRecord.IFSC_Code__c,
             "IFSC_Code__c" :'',
             "Account_Number__c" : this.parentDetails.Account_Number__c,
             "Loan_Application__c" : this.parentDetails.Loan_Application__c,
             "Repayment_Account__c": this.parentDetails.Repayment_Account__c,
             // "Account_Number__c" : this.spdcParentRecord.Account_Number__c,
             "Cheque_Purpose__c" : '',
             "Cheque_Amount__c" : '',
             "Cheque_Available_EMI__c" : '',
             "Pending_Cheque__c" : '',
             "sobjectType" : 'PDC__c	',
             "Same_As_Repayment_Account__c" :false,
             "isDirty" : false
             
             // "isChecked":false
 
         }
 
         let tempArr = [...this.AllSPDCRecords];
         tempArr.push(SPDCAdd);
         this.AllSPDCRecords = [...tempArr];
     }
 
     //delete spdc records
     @track isModalOpen= false;
     @track removeModalMessage = "Do you really want to delete this Record.";
     @track deleteRecordId;
     @track indexToDeleteModal;
     isCloseModal() {
        console.log('isModalOpen ', this.isModalOpen);
        this.isModalOpen = false;
    }


     handleDeleteSPDC(event){
        this.deleteRecordId=this.AllSPDCRecords[event.target.dataset.index].Id;
        this.indexToDeleteModal=event.target.dataset.index;
        console.log('this.indexToDeleteModal',this.indexToDeleteModal)
        // if(this.deleteRecordId ==undefined){
        //     this.AllSPDCRecords.splice(event.target.dataset.index,1);
        // }
        // else{
        this.isModalOpen = true;
        // }
     }
        handleRemoveRecord(){
        // let deleteRecordId=this.AllSPDCRecords[event.target.dataset.index].Id;
         //let deleteRecordId=del[0].Id;
         if(this.deleteRecordId ==undefined){
                 this.AllSPDCRecords.splice(this.indexToDeleteModal,1);
                 this.isModalOpen = false;
                 this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: this.customLabel.RepaymentSpdc_Del_SuccessMessage,
                        variant: 'success',
                        mode: "sticky"
                    })
                );
         }
         console.log('this.AllSPDCRecords modal',this.AllSPDCRecords)
         deleteRecord(this.deleteRecordId)
         .then(result => {
             refreshApex(this._wiredRepaySPDCData);
             this.dispatchEvent(
                 new ShowToastEvent({
                     title: 'Success',
                     message: this.customLabel.RepaymentSpdc_Del_SuccessMessage,
                     variant: 'success',
                     mode: "sticky"
                 })
             );
             this.isModalOpen = false;
         })
         .catch(error => {
             console.log(error);
         });
         
 
     }
 
     connectedCallback() {
 
         // console.log("isReadOnly:::::::: ", this.isReadOnly);
         console.log("hasEditAccess in regulatory spdc 596:::::::: ", this.hasEditAccess);
         console.log("disableMode in regulatory::::::::: ", this.disableMode);
         if (this.hasEditAccess === false) {
             this.disableMode = true;
         }
         this.scribeToMessageChannel();
 
 
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
 
     handleSaveV(validate) {
         if (validate) {
             let isInputCorrect = this.validateForm();
 
             console.log("custom lookup validity if false>>>", isInputCorrect);
 
             if (isInputCorrect === true) {
                 this.handleSave();
 
             } else {
 
             }
         } else {
             this.handleSave();
         }
 
     }
 
     //validation
 
     @api validateForm() {
         let isValid = true
 
         this.template.querySelectorAll('lightning-input').forEach(element => {
             if (element.reportValidity()) {
                 console.log('element passed');
             } else {
                 isValid = false;
                 element.setCustomValidity('Please fill the valid value')
             }
 
 
         });
         this.template.querySelectorAll('lightning-combobox').forEach(element => {
             if (element.reportValidity()) {
                 console.log('element passed');
             } else {
                 isValid = false;
                 element.setCustomValidity('Please fill the valid value')
             }
 
         });
         let pastdatecheck = this.checkDate();
         let customValidate=this.checkValidityLookup();
         //let minChequeVal=this.chequeValidate();
         console.log('customValidate',customValidate);
        // return isValid && pastdatecheck && customValidate ;
         return isValid  && customValidate ;
     }
 
    //min check validation on save
    // @track minChequeFlag=false;
    // chequeValidate(){
    //    // let chequeArr=this.AllSPDCRecords;

    //     let positiveNumberPattern = /^\d{6}$/;
    //     console.log('this.AllSPDCRecords chequevalidate',JSON.stringify(this.AllSPDCRecords))
    //     for(var i=0;i< this.AllSPDCRecords.length;i++){
    //         console.log('this.AllSPDCRecords[i].Cheque_Number_From__c',this.AllSPDCRecords[i].Cheque_Number_From__c)
    //     if (!positiveNumberPattern.test(this.AllSPDCRecords[i].Cheque_Number_From__c) && !positiveNumberPattern.test(this.AllSPDCRecords[i].Cheque_Number_To__c)) {
    //         this.minChequeFlag=true;
    //     }  
    //     if (this.AllSPDCRecords[i].Cheque_Number_From__c< this.AllSPDCRecords[i].Cheque_Number_To__c) {
    //         this.minChequeFlag=true;
    //     }     
        
    //     if (i + 1 < this.AllSPDCRecords.length) {
    //         if(this.AllSPDCRecords[i+1].Cheque_Number_From__c>=this.AllSPDCRecords[i].Cheque_Number_From__c && this.AllSPDCRecords[i+1].Cheque_Number_To__c<=this.AllSPDCRecords[i].Cheque_Number_To__c ){
    //             this.minChequeFlag=true;
                
    //         }
            
    //     }
            

    //     }
    //     console.log('minChequeFlag',this.minChequeFlag);
    //     return this.minChequeFlag
        
    // }
     //lookup validation

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
   
 
    //add row

    //******************FOR HANDLING THE HORIZONTAL SCROLL OF TABLE MANUALLY******************//
    // tableOuterDivScrolled(event) {
    //     this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
    //     if (this._tableViewInnerDiv) {
    //         if (!this._tableViewInnerDivOffsetWidth || this._tableViewInnerDivOffsetWidth === 0) {
    //             this._tableViewInnerDivOffsetWidth = this._tableViewInnerDiv.offsetWidth;
    //         }
    //         this._tableViewInnerDiv.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth) + "px;" + this.tableBodyStyle;
    //     }
        
    //     this.tableScrolled(event);

       

    // }

    // tableScrolled(event) {
    //     if (this.enableInfiniteScrolling) {
    //         if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
    //             this.dispatchEvent(new CustomEvent('showmorerecords', {
    //                 bubbles: true
    //             }));
    //         }
    //     }
    //     if (this.enableBatchLoading) {
    //         if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
    //             this.dispatchEvent(new CustomEvent('shownextbatch', {
    //                 bubbles: true
    //             }));
    //         }
    //     }
    // }

    

    

    // //******************************* RESIZABLE COLUMNS *************************************//
    // handlemouseup(e) {
    //     this._tableThColumn = undefined;
    //     this._tableThInnerDiv = undefined;
    //     this._pageX = undefined;
    //     this._tableThWidth = undefined;
    // }

    // handlemousedown(e) {
    //     if (!this._initWidths) {
    //         this._initWidths = [];
    //         let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
    //         tableThs.forEach(th => {
    //             this._initWidths.push(th.style.width);
    //         });
    //     }

    //     this._tableThColumn = e.target.parentElement;
    //     this._tableThInnerDiv = e.target.parentElement;
    //     while (this._tableThColumn.tagName !== "TH") {
    //         this._tableThColumn = this._tableThColumn.parentNode;
    //     }
    //     while (!this._tableThInnerDiv.className.includes("slds-cell-fixed")) {
    //         this._tableThInnerDiv = this._tableThInnerDiv.parentNode;
    //     }
    //     console.log("handlemousedown._tableThColumn.tagName => ", this._tableThColumn.tagName);
    //     this._pageX = e.pageX;

    //     this._padding = this.paddingDiff(this._tableThColumn);

    //     this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
    //     console.log("handlemousedown._tableThColumn.tagName => ", this._tableThColumn.tagName);
    // }

    // handlemousemove(e) {
    //     console.log("mousemove._tableThColumn => ", this._tableThColumn);
    //     if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
    //         this._diffX = e.pageX - this._pageX;

    //         this.template.querySelector("table").style.width = (this.template.querySelector("table") - (this._diffX)) + 'px';

    //         this._tableThColumn.style.width = (this._tableThWidth + this._diffX) + 'px';
    //         this._tableThInnerDiv.style.width = this._tableThColumn.style.width;

    //         let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
    //         let tableBodyRows = this.template.querySelectorAll("table tbody tr");
    //         let tableBodyTds = this.template.querySelectorAll("table tbody .dv-dynamic-width");
    //         tableBodyRows.forEach(row => {
    //             let rowTds = row.querySelectorAll(".dv-dynamic-width");
    //             rowTds.forEach((td, ind) => {
    //                 rowTds[ind].style.width = tableThs[ind].style.width;
    //             });
    //         });
    //     }
    // }

    // handledblclickresizable() {
    //     let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
    //     let tableBodyRows = this.template.querySelectorAll("table tbody tr");
    //     tableThs.forEach((th, ind) => {
    //         th.style.width = this._initWidths[ind];
    //         th.querySelector(".slds-cell-fixed").style.width = this._initWidths[ind];
    //     });
    //     tableBodyRows.forEach(row => {
    //         let rowTds = row.querySelectorAll(".dv-dynamic-width");
    //         rowTds.forEach((td, ind) => {
    //             rowTds[ind].style.width = this._initWidths[ind];
    //         });
    //     });
    // }

    // paddingDiff(col) {

    //     if (this.getStyleVal(col, 'box-sizing') === 'border-box') {
    //         return 0;
    //     }

    //     this._padLeft = this.getStyleVal(col, 'padding-left');
    //     this._padRight = this.getStyleVal(col, 'padding-right');
    //     return (parseInt(this._padLeft, 10) + parseInt(this._padRight, 10));

    // }

    // getStyleVal(elm, css) {
    //     return (window.getComputedStyle(elm, null).getPropertyValue(css))
    // }

    // /* handleSelectAll(event){
    //     this.selectedRows
    //     const isChecked = event.target.checked;
    //     const checkboxes = this.template.querySelectorAll('input[type="checkbox"][data-row-checkbox]');
    //     checkboxes.forEach(checkbox =>{
    //         checkbox.checked = isChecked;
    //     })
    // } */    
}