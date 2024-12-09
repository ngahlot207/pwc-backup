import { LightningElement, wire , api,track } from 'lwc';
import ApplicantCapture_Format_ErrorMessage from '@salesforce/label/c.ApplicantCapture_Format_ErrorMessage';
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
import Repayment_Del_SuccessMessage from '@salesforce/label/c.Repayment_Del_SuccessMessage';
import Repayment_Update_SuccessMessage from '@salesforce/label/c.Repayment_Update_SuccessMessage';
import Repayment_PastDateError from '@salesforce/label/c.Repayment_PastDateError';
import Repayment_ChequeNumber from '@salesforce/label/c.Repayment_ChequeNumber';
import Repayment_ChequeFrom from '@salesforce/label/c.Repayment_ChequeFrom';
import Repayment_Du from '@salesforce/label/c.Repayment_Du';
import SPDCMinThreeCheque from '@salesforce/label/c.SPDCMinThreeCheque';
export default class RepaymentMode extends LightningElement {
    CustomLabel = {
        Repayment_Del_SuccessMessage,
        Repayment_Update_SuccessMessage,
        Repayment_PastDateError,
        Repayment_ChequeNumber,
        Repayment_ChequeFrom,
        Repayment_Du,
        SPDCMinThreeCheque

    }
    EnteredDate;
    isUpdate=false;
    required=true;
    @api layoutSize;
    @track showSpinner = false;
    @track RARecord=[]
    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        console.log('Loan App Id ! '+value);
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);            
        this.handleRecordIdChange(value);        
    }

    // loanAppId='a08C40000063xjHIAQ';
    LengthError= 'Please Enter 6 Digit Number';
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
    pendingChequeValue;
    @track parentDetails={ }

    @track PDCType = 'PDC'

    @track LoanProductType;
    // @track SPDCType = 'SPDC'
    handleRecordIdChange(){        
        let tempParams = this.params;
        tempParams.queryCriteria = ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Is_Active__c = true';
        this.params = {...tempParams};

        let temppdcParams = this.pdcParam;
        temppdcParams.queryCriteria = ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Repayment_Account__c	= \'' + this.RepaymentIdfromParentRecord + '\'AND PDC_Type__c = \''+this.PDCType +'\' ';
        this.pdcParam = {...temppdcParams};

        // let tempspdcParams = this.spdcParam;
        // tempspdcParams.queryCriteria = ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Repayment_Account__c	= \'' + this.RepaymentIdfromParentRecord + '\'AND PDC_Type__c = \''+this.SPDCType +'\' ';
        // this.spdcParam = {...tempspdcParams};

       
    }
    @track mdtParam ={
        ParentObjectName:'MICRCodeMstr__c',        
        parentObjFields:['MICRCode__c','Id','BrchName__c','IFSCCode__c','BanckBrchId__c'],              
        queryCriteria: ''

    }
    @track params={
        ParentObjectName:'Repayment_Account__c',
        ChildObjectRelName:'PDC__r',
        parentObjFields:['Id','Pending_Cheques__c','SameASRepayment__c','Applicant_Banking__r.Appl__r.FullName__c','Loan_Application__c','Loan_Application__r.Product__c','Loan_Application__r.FirstEMIDate__c','Bank_Name__c','Bank_Branch__c','IFSC_Code__c','Account_Number__c','Is_Active__c','MICR_Code__c','Repayment_Mode__c'],
        childObjFields:['Id','Cheque_Number_From__c','Cheque_Number_To__c','PDC_Type__c','No_of_Cheques__c','Name','Loan_Application__c','Repayment_Account__c','Cheque_Purpose__c','Cheque_Amount__c','Cheque_Available_EMI__c','Pending_Cheque__c'],        
        queryCriteria: ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Is_Active__c = true '

    }

    @track pdcParam ={
        ParentObjectName:'PDC__c',        
        parentObjFields:['Id','Repayment_Account__c','Repayment_Account__r.Account_Number__c','Account_No__c','Same_As_Repayment_Account__c','Loan_Application__c','Bank_Name__c','Bank_Branch__c','IFSC_Code__c','MICR_Code__c','Cheque_Number_From__c','Cheque_Number_To__c','PDC_Type__c','No_of_Cheques__c','Name','Cheque_Purpose_PDC__c','Cheque_Purpose__c','Cheque_Amount__c','Cheque_Available_EMI__c','Pending_Cheque__c','Repayment_Account__r.Applicant_Banking__r.Appl__r.FullName__c'],              
        queryCriteria: ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Repayment_Account__c	= \'' + this.RepaymentIdfromParentRecord + '\' AND PDC_Type__c = \''+this.PDCType +'\' '

    }

    // @track spdcParam ={
    //     ParentObjectName:'PDC__c',        
    //     parentObjFields:['Id','Repayment_Account__c','Account_No__c','Same_As_Repayment_Account__c','Bank_Name__c','Bank_Branch__c','IFSC_Code__c','MICR_Code__c','Cheque_Number_From__c','Cheque_Number_To__c','PDC_Type__c','No_of_Cheques__c','Name','Loan_Application__c','Cheque_Purpose__c','Cheque_Amount__c','Cheque_Available_EMI__c','Pending_Cheque__c','Repayment_Account__r.Applicant_Banking__r.Appl__r.FullName__c'],              
    //     queryCriteria: ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Repayment_Account__c	= \'' + this.RepaymentIdfromParentRecord + '\' AND PDC_Type__c = \''+this.SPDCType +'\' '

    // }
    
//fetching  repayment details
    @wire(getData,{params:'$params'})
    RepayData(wiredRepayData) {
        console.log(' Loan id in parent comp' ,this.loanAppId);       
        const { data, error } = wiredRepayData;
        this._wiredRepayData = wiredRepayData;
        console.log("this._wiredRepayData "+JSON.stringify(this._wiredRepayData))
        if (data) {
        //    if(data.parentRecord!=undefined && data.parentRecord != null){
            //if(data!=undefined && data != null){
                this.RepayResult=JSON.parse(JSON.stringify(data))
                if(this.RepayResult[0] !=undefined && this.RepayResult[0]!=null){
                if(this.RepayResult[0].parentRecord!=undefined && this.RepayResult[0].parentRecord!=null){
            console.log("data repay stringify pdc "+(JSON.stringify(data)))
            // this.RepayResult=JSON.stringify(data)
            this.RepayParentRecord=JSON.parse(JSON.stringify(data[0].parentRecord));            
           
           this.parentDetails.Pending_Cheque__c=this.RepayParentRecord.Pending_Cheques__c ? this.RepayParentRecord.Pending_Cheques__c:'';
           this.pendingChequeValue=this.parentDetails.Pending_Cheque__c;
           this.RepaymentIdfromParentRecord = this.RepayParentRecord.Id
           console.log('this.RepayParentRecord.Id',this.RepayParentRecord.Id)
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
            if(this.RepayParentRecord.Loan_Application__r){
                this.parentDetails.FirstEMIDate = this.RepayParentRecord.Loan_Application__r.FirstEMIDate__c ? this.RepayParentRecord.Loan_Application__r.FirstEMIDate__c : '';
                this.LoanProductType=this.RepayParentRecord.Loan_Application__r.Product__c ? this.RepayParentRecord.Loan_Application__r.Product__c : '';
                console.log('this.parentDetails.FirstEMIDate',this.parentDetails.FirstEMIDate)              
            }
            this.parentDetails.Repayment_Account__c = this.RepayParentRecord.Id;
           // this.RID=this.parentDetails.Repayment_Account__c;
            let temppdcParams = this.pdcParam;
            temppdcParams.queryCriteria = ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Repayment_Account__c	= \'' + this.RepaymentIdfromParentRecord + '\' AND PDC_Type__c = \'PDC\' ';
            this.pdcParam = {...temppdcParams};
    
            // let tempspdcParams = this.spdcParam;
            // tempspdcParams.queryCriteria = ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Repayment_Account__c	= \'' + this.RepaymentIdfromParentRecord + '\' AND PDC_Type__c = \'SPDC\' ';
            // this.spdcParam = {...tempspdcParams};
    
        }}} else if (error) {
            console.log(error);
        }
    }

    //pdc data from pdc__c

    @track hasSPDCRecords=false;
    spdcrecords(event){
        console.log('event inside nach spdc records',event.detail.hasSPDCRecords)
        this.hasSPDCRecords=event.detail.hasSPDCRecords;
        const tospdcrecords = new CustomEvent('tospdcrecords', {
            detail: { hasSPDCRecords: this.hasSPDCRecords }  // Boolean value
        });
        this.dispatchEvent(tospdcrecords);
    }
    @track hasPDCRecords=false;
    @wire(fetchSingleObject,{params:'$pdcParam'})
    PDC (wirePDC) {
      const { data, error } = wirePDC;
      this._wirePDC = wirePDC;        
      this.AllPDCRecords=[]
      this.hasPDCRecords=false;
        if (data && data.parentRecords) {
             if(data.parentRecords!=undefined && data.parentRecords!=null){
              //  if(data!=undefined && data!=null){
                this.hasPDCRecords=true;
                const topdcrecords = new CustomEvent('topdcrecords', {
                    detail: { hasPDCRecords: this.hasPDCRecords }  // Boolean value
                });
                this.dispatchEvent(topdcrecords);

            this.RepayChildRecord=JSON.parse(JSON.stringify(data.parentRecords));
            console.log('RepayChildRecord',this.RepayChildRecord)
            
            for(var i=0;i< this.RepayChildRecord.length;i++){  
                
                if(this.RepayChildRecord[i].PDC_Type__c== 'PDC'){               
                    
                        let pdcRecordObj={}

                        pdcRecordObj.Cheque_Number_From__c = this.RepayChildRecord[i].Cheque_Number_From__c;
                        pdcRecordObj.Cheque_Number_To__c = this.RepayChildRecord[i].Cheque_Number_To__c;
                        pdcRecordObj.No_of_Cheques__c = this.RepayChildRecord[i].No_of_Cheques__c;

                        pdcRecordObj.MICR_Code__c = this.RepayChildRecord[i].MICR_Code__c ;
                        pdcRecordObj.Bank_Name__c = this.RepayChildRecord[i].Bank_Name__c;
                        pdcRecordObj.Bank_Branch__c = this.RepayChildRecord[i].Bank_Branch__c;

                       // pdcRecordObj.Name = this.RepayChildRecord[i].Name;
                       if(this.RepayChildRecord[i].Repayment_Account__r){
                        pdcRecordObj.Account_Number__c = this.RepayChildRecord[i].Repayment_Account__r.Account_Number__c;
                        console.log('pdcRecordObj.Account_Number__c',pdcRecordObj.Account_Number__c)
                        if(this.RepayChildRecord[i].Repayment_Account__r.Applicant_Banking__r){  
                                              
                        if(this.RepayChildRecord[i].Repayment_Account__r.Applicant_Banking__r.Appl__r){
                       pdcRecordObj.PDCbyName = this.RepayChildRecord[i].Repayment_Account__r.Applicant_Banking__r.Appl__r.FullName__c;
                       }}}
                        pdcRecordObj.IFSC_Code__c = this.RepayChildRecord[i].IFSC_Code__c;
                    //       if(this.RepayParentRecord.Repayment_Account__r){
                    // this.parentDetails.Account_Number__c=this.RepayParentRecord.Repayment_Account__r.Account_Number__c
                    //         }
                      //  pdcRecordObj.Account_Number__c = this.RepayChildRecord[i].Account_Number__c;

                        // pdcRecordObj.Cheque_Purpose__c = this.RepayChildRecord[i].Cheque_Purpose__c;
                        pdcRecordObj.Cheque_Purpose_PDC__c = 'EMI';
                        pdcRecordObj.Cheque_Amount__c = this.RepayChildRecord[i].Cheque_Amount__c;
                        pdcRecordObj.Cheque_Available_EMI__c = this.RepayChildRecord[i].Cheque_Available_EMI__c;
                       //this.parentDetails.FirstEMIDate
                       
                        pdcRecordObj.Pending_Cheque__c = this.RepayChildRecord[i].Pending_Cheque__c;
                        pdcRecordObj.Loan_Application__c = this.RepayChildRecord[i].Loan_Application__c;
                        pdcRecordObj.Repayment_Account__c = this.RepayChildRecord[i].Repayment_Account__c;
                        pdcRecordObj.SameASRepayment__c = this.RepayChildRecord[i].SameASRepayment__c;
                        pdcRecordObj.Id = this.RepayChildRecord[i].Id;
                      //  pdcRecordObj.Repayment_Account__c = this.RepayParentRecord.Id;
                        this.AllPDCRecords.push(pdcRecordObj);
                      
                        
                    }
            }
            

        }} else if (error) {
            console.log(error);
            const topdcrecords = new CustomEvent('topdcrecords', {
                detail: { hasPDCRecords: this.hasPDCRecords }  // Boolean value
            });
            this.dispatchEvent(topdcrecords);
        }
        else{
            const topdcrecords = new CustomEvent('topdcrecords', {
                detail: { hasPDCRecords: this.hasPDCRecords }  // Boolean value
            });
            this.dispatchEvent(topdcrecords);
        }
    }
    //spdc data

    // @wire(fetchSingleObject,{params:'$spdcParam'})
    // RepaySPDCData(wiredRepaySPDCData) {
    //     console.log(' Loan id in parent comp' ,this.loanAppId);       
    //     const { data, error } = wiredRepaySPDCData;
    //     this._wiredRepaySPDCData = wiredRepaySPDCData;
        
    //     this.AllSPDCRecords=[]
    //     if (data) {
    //         console.log('inside spdc _wiredRepaySPDCData',this._wiredRepaySPDCData)
                      
    //         this.spdcChildRecord=JSON.parse(JSON.stringify(data.parentRecords));
           
    //         for(var i=0;i< this.spdcChildRecord.length;i++){  

    //                 let spdcRecordObj={}
    //                 spdcRecordObj.Same_As_Repayment_Account__c =  this.spdcChildRecord[i].Same_As_Repayment_Account__c;
    //             spdcRecordObj.Cheque_Number_From__c = this.spdcChildRecord[i].Cheque_Number_From__c;
    //             spdcRecordObj.Cheque_Number_To__c = this.spdcChildRecord[i].Cheque_Number_To__c;
    //             spdcRecordObj.No_of_Cheques__c = this.spdcChildRecord[i].No_of_Cheques__c;

    //             spdcRecordObj.MICR_Code__c =  this.spdcChildRecord[i].MICR_Code__c ;
    //             spdcRecordObj.Bank_Name__c =  this.spdcChildRecord[i].Bank_Name__c;
    //             spdcRecordObj.Bank_Branch__c =  this.spdcChildRecord[i].Bank_Branch__c;
    //             if(this.spdcChildRecord[i].Repayment_Account__r){
    //                 if(this.spdcChildRecord[i].Repayment_Account__r.Applicant_Banking__r){
    //                     if(this.spdcChildRecord[i].Repayment_Account__r.Applicant_Banking__r.Appl__r){
    //             spdcRecordObj.PDCbyName =  this.spdcChildRecord[i].Repayment_Account__r.Applicant_Banking__r.Appl__r.FullName__c;
    //                 }}}
    //             spdcRecordObj.IFSC_Code__c =  this.spdcChildRecord[i].IFSC_Code__c;
    //             spdcRecordObj.Account_Number__c = this.spdcChildRecord[i].Account_Number__c;

    //             spdcRecordObj.Cheque_Purpose__c = this.spdcChildRecord[i].Cheque_Purpose__c;
    //             spdcRecordObj.Cheque_Amount__c = this.spdcChildRecord[i].Cheque_Amount__c;
    //             spdcRecordObj.Cheque_Available_EMI__c = this.spdcChildRecord[i].Cheque_Available_EMI__c;
    //             spdcRecordObj.Pending_Cheque__c = this.spdcChildRecord[i].Pending_Cheque__c;
    //             spdcRecordObj.Loan_Application__c =  this.spdcChildRecord[i].Loan_Application__c;
    //             // spdcRecordObj.Repayment_Account__c = this.spdcChildRecord[i].Repayment_Account__c;
    //             spdcRecordObj.Repayment_Account__c= this.spdcChildRecord[i].Repayment_Account__c;
    //             spdcRecordObj.Id = this.spdcChildRecord[i].Id;
              

    //             this.AllSPDCRecords.push(spdcRecordObj);
                
                

    //         }
    //     console.log('AllPDCRecords',this.AllPDCRecords)
    //     console.log('AllSPDCRecords spdc',this.AllSPDCRecords)
    //     } else if (error) {
    //         console.log(error);
    //     }
    // }
    // values for unchecked

    // handleValueSelect(event) {
    //     console.log('handleValueSelect');
    //     this.lookupRec = event.detail;
    //     let lookupId = this.lookupRec.id;
    //     let lookupAPIName = this.lookupRec.lookupFieldAPIName;
    //     const outputObj = { [lookupAPIName]: lookupId };
    //     if (event.target.fieldName === 'MICR_Code__c') {    
           
    //          this.AllSPDCRecords[event.target.index].MICR_Code__c = this.lookupRec.mainField;
    //         this.AllSPDCRecords[event.target.index].MICRCodeID__c =lookupId; 
    //         //this.AllSPDCRecords[event.target.index].MICR_Code__c = lookupId;

    //         this.MICRValue= this.AllSPDCRecords[event.target.index].MICR_Code__c;
    //         this.AllSPDCRecords[event.target.index].isDirty=true;
    //        // this.AllSPDCRecords[event.target.index].MICRCode__c= this.MICRValue
    //         //this.AllSPDCRecords[event.target.index].MICRCodeID__c = lookupId; 
    //         this.MICRIndex =event.target.index;


            
            

    //         let tempvalueParams = this.valueParam;
    //         tempvalueParams.queryCriteria = ' where MICRCode__c	= \'' + this.MICRValue + '\'';
    //         this.valueParam = {...tempvalueParams};
    //     console.log('MICRValue',this.MICRValue)
    //     }
        
    //     console.log('--handle change--------'+JSON.stringify(this.AllSPDCRecords))
    // }

    // @track  valueParam ={
    //     ParentObjectName:'MICRCodeMstr__c',        
    //     parentObjFields:['MICRCode__c','Id','BrchName__c','IFSCCode__c','BanckBrchId__c','Bank__c','Bank__r.Name'],              
    //     queryCriteria: ' where MICRCode__c	= \'' + this.MICRValue + '\''

    // }

    // @wire(fetchSingleObject,{params:'$valueParam'})
    // mdtData (wiredmdtData) {
    //   const { data, error } = wiredmdtData;
    //   this._wiredmdtData = wiredmdtData;        
       
    //     if (data) {
    //         this.mdtNames=JSON.parse(JSON.stringify(data.parentRecords));
    //         console.log('customlookup  this.mdtNames', this.mdtNames)
                    
    //                  if(this.mdtNames[0].Bank__c){   
    //                     console.log('bank name',this.mdtNames[0].Bank__r.Name)                     
    //                     this.AllSPDCRecords[this.MICRIndex].Bank_Name__c=this.mdtNames[0].Bank__r.Name;
    //                     console.log('bank name',this.mdtNames[0].Bank__r.Name)
    //                     }
    //                     if(this.mdtNames[0].BrchName__c){
    //                         this.AllSPDCRecords[this.MICRIndex].Bank_Branch__c=this.mdtNames[0].BrchName__c;
    //                     }
    //                         if(this.mdtNames[0].IFSC_Code__c){
    //                         this.AllSPDCRecords[this.MICRIndex].IFSC_Code__c=this.mdtNames[0].IFSC_Code__c;
    //                     }

    //                     // if(this.mdtNames[0].MICRCode__c){
    //                     //     this.AllSPDCRecords[this.MICRIndex].MICRCode__c=this.mdtNames[0].MICRCode__c;
    //                     // }

                       
    //             }      

    //     if(error) {
    //             console.log(error);
    //         }
    
    // }
    
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
    //add row

    handlePDCAddRow(){
        let PDCAdd ={
            "Cheque_Number_From__c" : '',
            "Cheque_Number_To__c" : '',
            "No_of_Cheques__c" : '',
            "MICR_Code__c":this.parentDetails.MICR_Code__c,
            "Bank_Name__c":this.parentDetails.Bank_Name__c,
            "Bank_Branch__c":this.parentDetails.Bank_Branch__c,
            "PDCbyName" :this.parentDetails.PDCbyName,
            "IFSC_Code__c" : this.parentDetails.IFSC_Code__c,
            "Account_Number__c" : this.parentDetails.Account_Number__c,
            "Loan_Application__c" : this.parentDetails.Loan_Application__c,
            "Repayment_Account__c": this.parentDetails.Repayment_Account__c,
            // "Account_Number__c" : this.RepayParentRecord.Account_Number__c,
            "Cheque_Purpose_PDC__c" : 'EMI',
            "Cheque_Amount__c" : '',
            "Cheque_Available_EMI__c" : '',
            "Pending_Cheque__c" : '',
            "sobjectType" : 'PDC__c',
            "isDirty" : false
            

        }

        let tempArr = [...this.AllPDCRecords];
        tempArr.push(PDCAdd);
        this.AllPDCRecords = [...tempArr];
        console.log('inside add pdc row',JSON.stringify(this.AllPDCRecords))
    }
    //handle pdc change
    
    timer
    handleInputChange(event)
    {
        const inputBox = event.currentTarget;
        inputBox.setCustomValidity('');
        inputBox.reportValidity();
        let IndexRow = event.target.dataset.index
        let RepayDetails = this.AllPDCRecords[event.target.dataset.index]
        // RepayDetails[event.target.dataset.name] = event.target.value; 
        // RepayDetails.isDirty=true;
       
        const positiveNumberPattern = /^\d{6}$/;
        if(event.target.dataset.name === 'Cheque_Number_To__c' || event.target.dataset.name === 'Cheque_Number_From__c')
         {
        // if (!positiveNumberPattern.test(event.target.value)) {
                
        //     this.showToast("Error!", "error", this.CustomLabel.Repayment_ChequeNumber,"sticky");
        //     return;
        // }  
        if(event.target.dataset.name === 'Cheque_Number_From__c'){
            if (!positiveNumberPattern.test(event.target.value)) {
                const items =this.template.querySelectorAll('[data-id="chequeFrom"]');
                    if(items.length>0){
                        const firstItem=items[event.target.dataset.index];
                        firstItem.value='';
                    }
                    this.showToast("Error!", "error", this.CustomLabel.Repayment_ChequeNumber,"sticky");   
                return;
            }  
        }

        if(event.target.dataset.name === 'Cheque_Number_To__c'){
            if (!positiveNumberPattern.test(event.target.value) ) {      
                const itemsTo =this.template.querySelectorAll('[data-id="chequeTo"]');
                if(itemsTo.length>0){
                    const lastItem=itemsTo[event.target.dataset.index];
                    lastItem.value='';
                }
                this.showToast("Error!", "error", this.CustomLabel.Repayment_ChequeNumber,"sticky");
                return;
            }  
         }


        if(event.target.dataset.name === 'Cheque_Number_To__c'){
        
            if(event.target.value< RepayDetails.Cheque_Number_From__c){
                const itemsTo =this.template.querySelectorAll('[data-id="chequeTo"]');
                    if(itemsTo.length>0){
                        const lastItem=itemsTo[event.target.dataset.index];
                        lastItem.value='';
                    }
                this.showToast("Error!", "error", this.CustomLabel.Repayment_ChequeFrom,"sticky");
                return;
            }
        }
    // }
        if(event.target.dataset.name === 'Cheque_Number_To__c' || event.target.dataset.name === 'Cheque_Number_From__c')
        {
            for (let i = 0; i < this.AllPDCRecords.length; i++){
                if(i!=IndexRow){
                if(event.target.value>=this.AllPDCRecords[i].Cheque_Number_From__c && event.target.value<=this.AllPDCRecords[i].Cheque_Number_To__c ){
                    const items =this.template.querySelectorAll('[data-id="chequeFrom"]');
                    if(items.length>0){
                        const firstItem=items[event.target.dataset.index];
                        firstItem.value='';
                    }
                    this.showToast("Error!", "error", this.CustomLabel.Repayment_Du,"sticky");
                    return;  
                }
            }
            }
        }
    }
        
            RepayDetails[event.target.dataset.name] = event.target.value; 
            RepayDetails.isDirty=true;
    
            RepayDetails.No_of_Cheques__c = (RepayDetails.Cheque_Number_To__c -RepayDetails.Cheque_Number_From__c)+1;
            if(this.parentDetails.FirstEMIDate!=undefined && this.parentDetails.FirstEMIDate !=null){
                console.log('inside handler firstdate',this.parentDetails.FirstEMIDate);
               // let dt = new Date(this.parentDetails.FirstEMIDate);
                let numberOfMonthsToAdd=RepayDetails.No_of_Cheques__c;
                let newDate = new Date(this.parentDetails.FirstEMIDate);
                console.log('New Date before:', newDate);
                let newMonth = newDate.getMonth() + numberOfMonthsToAdd;
                let newYear = newDate.getFullYear();

                while (newMonth >= 12) {
                    newMonth -= 12;
                    newYear++;
                }
                newDate.setMonth(newMonth);
                 newDate.setFullYear(newYear);

                 //console.log('Original Date:', this.originalDate);
                 console.log('New Date:', newDate);
                RepayDetails.Cheque_Available_EMI__c=newDate;
            
            
        }

        // if(event.target.dataset.name === 'Cheque_Available_EMI__c'){
            
        //     RepayDetails[event.target.dataset.name] = event.target.value; 
        //     RepayDetails.isDirty=true;
        //     this.EnteredDate=event.target.value;
        //   this.currentDate= new Date().toISOString().substring(0, 10);
        //     if(this.checkDate()){
        //         RepayDetails.Cheque_Available_EMI__c=this.EnteredDate
        //     }
           
        // }
    
        this.AllPDCRecords[event.target.dataset.index] = RepayDetails;

    }

    checkDate(){
        if(this.EnteredDate < this.currentDate){
            // this.showToast("Error", "error", "should not be past date");
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.CustomLabel.Repayment_PastDateError,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
            return false 
        }else{

           return true;
        }
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

    handleChequeChange(event){
        const inputBox = event.currentTarget;

        inputBox.setCustomValidity('');
        inputBox.reportValidity();
      
        // this.pendingChequeValue=event.target.value;
        // console.log('this.pendingChequeValue',this.pendingChequeValue)
        // this.isUpdate=true;

        this.EnteredDate=event.target.value;
          this.currentDate= new Date().toISOString().substring(0, 10);
            if(this.checkDate()){
                this.pendingChequeValue=this.EnteredDate;
                this.isUpdate=true;
            }

    }

    // checkDate(){
    //     if(this.EnteredDate < this.currentDate){
    //         // this.showToast("Error", "error", "should not be past date");
            
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Error',
    //                 message: this.customLabel.Repayment_PastDateError,
    //                 variant: 'error',
    //                 mode: 'sticky'
    //             })
    //         );
    //         return false 
    //     }else{

    //        return true;
    //     }
    // }
    //spdc change
    // handleInputChangeSPDC(event)
    // {
        
    //     let SPDCRepayDetails = this.AllSPDCRecords[event.target.dataset.index]
    //     SPDCRepayDetails[event.target.dataset.name] = event.target.value; 
    //     SPDCRepayDetails.isDirty=true;

    //     if(event.target.dataset.name === 'Cheque_Number_To__c' || event.target.dataset.name === 'Cheque_Number_From__c')

    //     {
    //         SPDCRepayDetails.No_of_Cheques__c = (SPDCRepayDetails.Cheque_Number_To__c -SPDCRepayDetails.Cheque_Number_From__c)+1;
    //     }
    //     this.AllSPDCRecords[event.target.dataset.index] = SPDCRepayDetails;

    // }

    //  //handle check for prepopulate data
    //  checkboxHandler(event){

    //     this.isCheck=event.target.checked;
    //     let RepayDetails = this.AllSPDCRecords[event.target.dataset.index]
    //     RepayDetails[event.target.dataset.name] = event.target.checked; 
    //     this.AllSPDCRecords[event.target.dataset.index] = RepayDetails;
    //    RepayDetails.isDirty=true;
    //    console.log('event check',this.isCheck)
    //    console.log('event ',event.target.checked)
    //    if(this.isCheck==true)
    //    {
    //     this.AllSPDCRecords[event.target.dataset.index].MICR_Code__c=this.parentDetails.MICR_Code__c
    //     this.AllSPDCRecords[event.target.dataset.index].Bank_Name__c=this.parentDetails.Bank_Name__c
    //     this.AllSPDCRecords[event.target.dataset.index].Bank_Branch__c=this.parentDetails.Bank_Branch__c
    //     this.AllSPDCRecords[event.target.dataset.index].SameASRepayment__c=this.isCheck
    //    }
    //    if(this.isCheck==false)
    //    {
    //     this.AllSPDCRecords[event.target.dataset.index].MICR_Code__c=''
    //     this.AllSPDCRecords[event.target.dataset.index].Bank_Name__c=''
    //     this.AllSPDCRecords[event.target.dataset.index].Bank_Branch__c=''
    //     this.AllSPDCRecords[event.target.dataset.index].SameASRepayment__c=this.isCheck
    //    }

    // }

    @track isModalOpen= false;
     @track removeModalMessage = "Do you really want to delete this Record.";
     @track deleteRecordId;
     @track indexToDeleteModal;
     isCloseModal() {
        console.log('isModalOpen ', this.isModalOpen);
        this.isModalOpen = false;
    }


    handleDelete(event){
        this.deleteRecordId=this.AllPDCRecords[event.target.dataset.index].Id;
        this.indexToDeleteModal=event.target.dataset.index;
        this.isModalOpen = true;
    }
    handleRemoveRecord(){
       // let deleteRecordId=this.AllPDCRecords[event.target.dataset.index].Id;
        //let deleteRecordId=del[0].Id;
        if(this.deleteRecordId ==undefined){
                this.AllPDCRecords.splice(this.indexToDeleteModal,1);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: this.CustomLabel.Repayment_Del_SuccessMessage,
                        variant: 'success',
                        mode: "sticky"
                    })
                );
                this.isModalOpen = false;
        }
        
        deleteRecord(this.deleteRecordId)
        .then(result => {
            refreshApex(this._wirePDC);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: this.CustomLabel.Repayment_Del_SuccessMessage,
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
    //spdc data
    sum=0;
    @track  SPDCChildRecords = [];
    @track AllSPDCRecords=[]
    handleChildData() {
         const childComponent = this.template.querySelector('c-repayment-mode-s-p-d-c').handlechildSave();
        if (childComponent) {
            this.AllSPDCRecords=childComponent;
           console.log("inside parent child data");
           console.log("inside parent child data ",JSON.stringify(childComponent));
           console.log("inside parent child data spdcrecord ",JSON.stringify(this.AllSPDCRecords));
            this.sum=0;
          this.SPDCChildRecords = [];
         let spdcchildRecordObj = {};
         for(var i=0;i<this.AllSPDCRecords.length;i++){
            this.sum += this.AllSPDCRecords[i].No_of_Cheques__c;
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
                
                this.SPDCChildRecords.push(spdcchildRecordObj);
             }
         }
         console.log('SPDCChildRecords isdirty',JSON.stringify(this.SPDCChildRecords));
        }
    }
    //handle save
    sumPDC=0;
    handleSave(event)
    {
        this.showSpinner=true;
            //pdc save
        let ChildRecords = [];
        let childRecordObj = {};
        this.sumPDC=0;
        for(var i=0;i<this.AllPDCRecords.length;i++){
            this.sumPDC += this.AllPDCRecords[i].No_of_Cheques__c;
            console.log('this.sumPDC',this.sumPDC);
            if(this.AllPDCRecords[i].isDirty){
                childRecordObj = {};
                childRecordObj.sobjectType='PDC__c';
                childRecordObj.Cheque_Number_From__c=this.AllPDCRecords[i].Cheque_Number_From__c;
                childRecordObj.Cheque_Number_To__c=this.AllPDCRecords[i].Cheque_Number_To__c;
                childRecordObj.No_of_Cheques__c=this.AllPDCRecords[i].No_of_Cheques__c;
                // childRecordObj.Cheque_Purpose_PDC__c=this.AllPDCRecords[i].Cheque_Purpose_PDC__c;
                childRecordObj.Cheque_Purpose__c='EMI';
                childRecordObj.Cheque_Amount__c=this.AllPDCRecords[i].Cheque_Amount__c;
                childRecordObj.Cheque_Available_EMI__c=this.AllPDCRecords[i].Cheque_Available_EMI__c;
                childRecordObj.Pending_Cheque__c=this.AllPDCRecords[i].Pending_Cheque__c;
               // childRecordObj.Loan_Application__c=this.AllPDCRecords[i].Loan_Application__c;
               childRecordObj.Loan_Application__c=this.loanAppId;
                childRecordObj.Repayment_Account__c=this.AllPDCRecords[i].Repayment_Account__c;
                childRecordObj.Id=this.AllPDCRecords[i].Id;

                childRecordObj.PDC_Type__c='PDC';

                childRecordObj.MICR_Code__c=this.AllPDCRecords[i].MICR_Code__c;
                childRecordObj.Bank_Name__c=this.AllPDCRecords[i].Bank_Name__c;
                childRecordObj.Bank_Branch__c=this.AllPDCRecords[i].Bank_Branch__c;
                childRecordObj.IFSC_Code__c=this.AllPDCRecords[i].IFSC_Code__c;
                // childRecordObj.Account_Number__c=this.AllPDCRecords[i].Account_Number__c;
                childRecordObj.Account_No__c=this.AllPDCRecords[i].Account_Number__c;
                childRecordObj.PDCbyName=this.AllPDCRecords[i].PDCbyName;
                



                ChildRecords.push(childRecordObj);
                console.log('ChildRecords 784',ChildRecords);
            }
        }
        this.handleChildData();
        console.log('SPDCChildRecords inside save parnt',JSON.stringify(this.SPDCChildRecords));
        console.log('SPDCChildRecords count',this.sum);
        if((this.sum<3 && this.validateFlag==true) || (this.sumPDC<3 && this.validateFlag==true && (this.LoanProductType=='Business Loan' || this.LoanProductType=='Personal Loan'))){
            this.showSpinner=false;
            if(this.sum<3 && this.validateFlag==true){
                this.showToast("Error!", "error", this.CustomLabel.SPDCMinThreeCheque,"sticky");
            }
            if(this.sumPDC<3 && this.validateFlag==true && (this.LoanProductType=='Business Loan' || this.LoanProductType=='Personal Loan')){
                this.showToast("Error!", "error", 'Atleast 3 No Of Cheques should be in PDC',"sticky");
            }
            
            
        }
        else{
            //pdc save
        upsertMultipleRecord({params:ChildRecords})
        .then(result => {                     
           // this.showSpinner=false;
            this.showMessage();
            refreshApex(this._wirePDC);                      
            
        }).catch(error => {
            console.log(error);
        })

        if(this.isUpdate){
           this.RARecord=[]
            let RecordObj={}
                RecordObj.Id = this.RepaymentIdfromParentRecord;
                console.log(' RecordObj.Id', RecordObj.Id)
               RecordObj.Pending_Cheques__c=this.pendingChequeValue; 
                RecordObj.Loan_Application__c=this.loanAppId;
                this.RARecord.push(RecordObj) 
                console.log(' inside save cheque',this.RARecord)

        upsertMultipleRecord({params:this.RARecord})
        .then(result => {    
            refreshApex(this._wiredRepayData)                 
            // this.showToast("Success!", "Success", "Repayment Details updated");
                                          
            
        }).catch(error => {
            console.log(error);
            
        })

        }



    //     //upsert spdc records
        //spdc save

        upsertMultipleRecord({params:this.SPDCChildRecords})
        .then(result => {                     
            this.showSpinner=false;
            this.showMessage();
          //  refreshApex(this._wiredRepaySPDCData);    
          this.template.querySelector('c-repayment-mode-s-p-d-c').handleRefreshchildSave();                
            
        }).catch(error => {
            console.log(error);
            this.showSpinner=false;
        })
        
    // let SPDCChildRecords = [];
    //     let spdcchildRecordObj = {};
    //     for(var i=0;i<this.AllSPDCRecords.length;i++){
    //         if(this.AllSPDCRecords[i].isDirty){
    //             spdcchildRecordObj = {};
    //             spdcchildRecordObj.sobjectType='PDC__c';
    //             spdcchildRecordObj.Cheque_Number_From__c=this.AllSPDCRecords[i].Cheque_Number_From__c;
    //             spdcchildRecordObj.Cheque_Number_To__c=this.AllSPDCRecords[i].Cheque_Number_To__c;
    //             spdcchildRecordObj.No_of_Cheques__c=this.AllSPDCRecords[i].No_of_Cheques__c;
    //             spdcchildRecordObj.Cheque_Purpose__c=this.AllSPDCRecords[i].Cheque_Purpose__c;
    //             spdcchildRecordObj.Cheque_Amount__c=this.AllSPDCRecords[i].Cheque_Amount__c;
    //             spdcchildRecordObj.Cheque_Available_EMI__c=this.AllSPDCRecords[i].Cheque_Available_EMI__c;
    //             spdcchildRecordObj.Pending_Cheque__c=this.AllSPDCRecords[i].Pending_Cheque__c;
    //            // childRecordObj.Loan_Application__c=this.AllPDCRecords[i].Loan_Application__c;
    //            spdcchildRecordObj.Loan_Application__c=this.loanAppId;
    //            spdcchildRecordObj.Repayment_Account__c=this.AllSPDCRecords[i].Repayment_Account__c;
    //            spdcchildRecordObj.Id=this.AllSPDCRecords[i].Id;

    //            spdcchildRecordObj.PDC_Type__c='SPDC';

    //            spdcchildRecordObj.MICR_Code__c=this.AllSPDCRecords[i].MICR_Code__c;
    //            spdcchildRecordObj.Bank_Name__c=this.AllSPDCRecords[i].Bank_Name__c;
    //            spdcchildRecordObj.Bank_Branch__c=this.AllSPDCRecords[i].Bank_Branch__c;
    //            spdcchildRecordObj.IFSC_Code__c=this.AllSPDCRecords[i].IFSC_Code__c;
    //            spdcchildRecordObj.Account_Number__c=this.AllSPDCRecords[i].Account_Number__c;
    //            spdcchildRecordObj.PDCbyName=this.AllSPDCRecords[i].PDCbyName;
    //            spdcchildRecordObj.Same_As_Repayment_Account__c=this.AllSPDCRecords[i].Same_As_Repayment_Account__c;
    //            //Same_As_Repayment_Account__c
                



    //            SPDCChildRecords.push(spdcchildRecordObj);
    //         }
    //     }
    //     upsertMultipleRecord({params:SPDCChildRecords})
    //     .then(result => {                     
           
    //         this.showMessage();
    //         refreshApex(this._wiredRepaySPDCData);    
                             
            
    //     }).catch(error => {
    //         console.log(error);
    //     })
    
    }}

    showMessage()
    {
    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message:this.CustomLabel.Repayment_Update_SuccessMessage,
                            variant: "success",
                            mode: "sticky"
                        }))
    }

    //add row spdc
    // handleSPDCAddRow(){
    //     let SPDCAdd ={
    //         "Cheque_Number_From__c" : '',
    //         "Cheque_Number_To__c" : '',
    //         "No_of_Cheques__c" : '',
    //         // "MICR_Code__c":this.spdcParentRecord.MICR_Code__c,
    //         // "Bank_Name__c":this.spdcParentRecord.Bank_Name__c,
    //         // "Bank_Branch__c":this.spdcParentRecord.Bank_Branch__c,
    //         "MICR_Code__c":'',
    //         "Bank_Name__c":'',
    //         "Bank_Branch__c":'',
    //         "PDCbyName" :this.parentDetails.PDCbyName,
    //         // "IFSC_Code__c" : this.spdcParentRecord.IFSC_Code__c,
    //         "IFSC_Code__c" :'',
    //         "Account_Number__c" : this.parentDetails.Account_Number__c,
    //         "Loan_Application__c" : this.parentDetails.Loan_Application__c,
    //         "Repayment_Account__c": this.parentDetails.Repayment_Account__c,
    //         // "Account_Number__c" : this.spdcParentRecord.Account_Number__c,
    //         "Cheque_Purpose__c" : '',
    //         "Cheque_Amount__c" : '',
    //         "Cheque_Available_EMI__c" : '',
    //         "Pending_Cheque__c" : '',
    //         "sobjectType" : 'PDC__c	',
    //         "Same_As_Repayment_Account__c" :false,
    //         "isDirty" : false
            
    //         // "isChecked":false

    //     }

    //     let tempArr = [...this.AllSPDCRecords];
    //     tempArr.push(SPDCAdd);
    //     this.AllSPDCRecords = [...tempArr];
    // }

    // //delete spdc records
    // handleDeleteSPDC(event){
    //     let deleteRecordId=this.AllSPDCRecords[event.target.dataset.index].Id;
    //     //let deleteRecordId=del[0].Id;
    //     if(this.deleteRecordId ==undefined){
    //             this.AllSPDCRecords.splice(event.target.dataset.index,1);
    //     }
        
    //     deleteRecord(deleteRecordId)
    //     .then(result => {
    //         refreshApex(this._wiredRepaySPDCData);
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Success',
    //                 message: 'Record deleted successfully',
    //                 variant: 'success'
    //             })
    //         );
    //     })
    //     .catch(error => {
    //         console.log(error);
    //     });
        

    // }

    connectedCallback() {

        // console.log("isReadOnly:::::::: ", this.isReadOnly);
        console.log("hasEditAccess in regulatory:::::::: ", this.hasEditAccess);
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
    @track validateFlag=false;
    handleSaveV(validate) {
        this.validateFlag=validate;
        
        if (validate) {
            let isInputCorrect = this.validateForm();
            let childValidate = this.template.querySelector('c-repayment-mode-s-p-d-c').validateForm();
            console.log("custom lookup validity if false>>>", isInputCorrect);

            if (isInputCorrect === true && childValidate===true) {
                this.handleSave();

            } else {
                this.showToast("Error!", "error", "Please fill the required fields","sticky");
            }
        } else {
            this.handleSave();
        }

    }

    //validation

    validateForm() {
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

        return isValid && pastdatecheck;
    }



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