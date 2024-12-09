import { LightningElement,wire,api,track } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import NACHobj from '@salesforce/schema/NACH__c';
import { formattedDateTimeWithoutSeconds } from 'c/dateUtility';
import MANDATETYPE from '@salesforce/schema/NACH__c.Mandate_Type__c';
import DEBITTYPE from '@salesforce/schema/NACH__c.Debit_Type__c';
import fetchSingleObject from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import createDocumentDetail from "@salesforce/apex/DocumentDetailController.createDocumentDetail";
import convertToWords from "@salesforce/apex/NumberToStringConverter.convertToWords";
import { refreshApex } from '@salesforce/apex';
import { deleteRecord,updateRecord,createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import fetchSingleObject from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import updateRegPer from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getData from '@salesforce/apex/SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords';
import upsertManualRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleParentsWithMultipleChilds';
//import { getRecord, getObjectInfo ,getPicklistValues, getPicklistValuesByRecordType} from 'lightning/uiObjectInfoApi';
import PDCObj from '@salesforce/schema/PDC__c';
import PURPOSE from '@salesforce/schema/PDC__c.Cheque_Purpose__c';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import PageURLNACHForm from '@salesforce/label/c.PageURLNACHForm';
import generateDocument from "@salesforce/apex/GeneratePDFandAttachToLoanApplication.generateDocument";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";

import cometdlwc from "@salesforce/resourceUrl/cometd";
import getSessionId from '@salesforce/apex/SessionUtil.getSessionId';
import { loadScript } from "lightning/platformResourceLoader";
// Custom labels
import RepamentNach_Update_SuccessMessage from '@salesforce/label/c.RepamentNach_Update_SuccessMessage';
import RepamentNach_DocDetail_ErrorMessage from '@salesforce/label/c.RepamentNach_DocDetail_ErrorMessage';
import Repayment_NACHDocument from '@salesforce/label/c.Repayment_NACHDocument';
import SPDCMinThreeCheque from '@salesforce/label/c.SPDCMinThreeCheque';
Repayment_NACHDocument

export default class RepaymentModeNACH extends LightningElement {
    customlabel ={
        RepamentNach_Update_SuccessMessage,
        RepamentNach_DocDetail_ErrorMessage,
        Repayment_NACHDocument,
        SPDCMinThreeCheque

    }

    label = {
        PageURLNACHForm
    };
    @track showSpinner = false;
    @api isReadOnly;
    @track disableMode;
    @api hasEditAccess;
    @api layoutSize;
    @track RepaymentIdPreview = ''
    IsMandateTypeOptions
    IsDebitTypeOptions
    @track _wiredNACHData
    @track _wiredIntMsgData
    nachRecord=[]
    isRequired=true;
    //disableMode=true
    disable=true;
    enachRetrigger=false;
    isEnachVisible =false;
    isStatusSuccess=false;
    isPhysicalNachButton=false;
    @track wrpAppReg = {
    }
    @track _wiredRVData;
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
    repaymentAccountId;
    @track lookupRec
    @track RepaymentIdfromParentRecord
    @track ChequePurposeOptions=[]
    @track _wiredRepaySPDCData;
    @track _wiredmdtData;
    @track _wirePDC
    @track MICRValue;
    MICRIndex;
    RVResult;
    @track parentDetails={ }
    @track RVRecord={ }

    @track PDCType = 'PDC'
    @track SPDCType = 'SPDC'

    chequeInterval
    @api channelName = "/event/IntRespEvent__e";
    @track sessionId;
    cometdlib;
    @track subscription;
    @track PEsubscription;
    initiationDateTimeVaue
    responseDateTimeValue
    showDocList=false;
    IsrequiredUMRN=false;
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
    handleRecordIdChange(){        
        let tempParams = this.nachParam;
        tempParams.queryCriteria = ' where LoanAppl__c= \'' + this.loanAppId + '\' AND IsActive__c = true';
        this.nachParam = {...tempParams};

        let tempPar = this.params;
        tempPar.queryCriteria = ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Is_Active__c = true';
        this.params = {...tempPar};

        let tempIntMsgPar = this.IntMsgparams;
        tempIntMsgPar.queryCriteria = ' where LoanAppln__c= \'' + this.loanAppId + '\' AND Name = \'mandate_create_form\' AND RefObj__c = \'NACH__c\'';
        this.IntMsgparams = {...tempIntMsgPar};

        // let tempspdcParams = this.spdcParam;
        // tempspdcParams.queryCriteria = ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Repayment_Account__c	= \'' + this.RepaymentIdfromParentRecord + '\'AND PDC_Type__c = \''+this.SPDCType +'\' ';
        // this.spdcParam = {...tempspdcParams};

        // let tempRVParams = this.RepVerifyParam;
        // tempRVParams.queryCriteria = ' where RepayAcc__c	= \'' + this.RepaymentIdfromParentRecord + '\' order by CreatedDate  desc limit 1';
        // this.RepVerifyParam = {...tempRVParams};

       
    }

   // loanAppId='a08C40000063xjHIAQ';
    //retriving data based on loan id

    // @track mdtParam ={
    //     ParentObjectName:'MICRCodeMstr__c',        
    //     parentObjFields:['MICRCode__c','Id','BrchName__c','IFSCCode__c','BanckBrchId__c'],              
    //     queryCriteria: ''

    // }

    // @track RepVerifyParam ={
    //     ParentObjectName:'RepayAccVerify__c',        
    //     parentObjFields:['PennyDropStatus__c','Id','RepayAcc__c','CreatedDate'],              
    //     queryCriteria: ' where RepayAcc__c	= \'' + this.RepaymentIdfromParentRecord + '\' order by CreatedDate  desc limit 1'

    // }
    // @track params={
    //     ParentObjectName:'Repayment_Account__c',
    //     ChildObjectRelName:'PDC__r',
    //     parentObjFields:['Id','SameASRepayment__c','Applicant_Banking__r.Appl__r.FullName__c','Loan_Application__c','Bank_Name__c','Bank_Branch__c','IFSC_Code__c','Account_Number__c','Is_Active__c','MICR_Code__c','Repayment_Mode__c'],
    //     childObjFields:['Id','Cheque_Number_From__c','Cheque_Number_To__c','PDC_Type__c','No_of_Cheques__c','Name','Loan_Application__c','Repayment_Account__c','Cheque_Purpose__c','Cheque_Amount__c','Cheque_Available_EMI__c','Pending_Cheque__c'],        
    //     queryCriteria: ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Is_Active__c = true '

    // }
    @track params={
        ParentObjectName:'Repayment_Account__c', 
        ChildObjectRelName: '',       
        parentObjFields:['Id','Loan_Application__c','IFSC_Code__c','Account_Number__c','Is_Active__c','MICR_Code__c','Repayment_Mode__c'],
        childObjFields: [],
        queryCriteria: ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Is_Active__c = true '

    }
    // @track spdcParam ={
    //     ParentObjectName:'PDC__c',        
    //     parentObjFields:['Id','Repayment_Account__c','Account_No__c','Same_As_Repayment_Account__c','Bank_Name__c','Bank_Branch__c','IFSC_Code__c','MICR_Code__c','Cheque_Number_From__c','Cheque_Number_To__c','PDC_Type__c','No_of_Cheques__c','Name','Loan_Application__c','Cheque_Purpose__c','Cheque_Amount__c','Cheque_Available_EMI__c','Pending_Cheque__c','Repayment_Account__r.Applicant_Banking__r.Appl__r.FullName__c'],              
    //     queryCriteria: ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Repayment_Account__c	= \'' + this.RepaymentIdfromParentRecord + '\' AND PDC_Type__c = \''+this.SPDCType +'\' '

    // }
    @track nachParam ={
        ParentObjectName:'NACH__c',        
        parentObjFields:['Id','Account_Type__c','amount_numbers__c','amt_rupees_words__c','Authorise__c','Bank_Account_Number__c','Bank_Branch__c','Bank_City__c','Bank_Code__c','Bank_Name__c','Date__c','Debit_Type__c','Email_Id__c','eNACH_Registration_Status__c','EnachInitiationDateTime__c','EnachResponseDateTime__c','eNACH_Rejection_Reasons__c','Frequency__c','From_Date__c','IFSC_Code__c','LoanAppl__c','LoanAppl__r.Applicant__c','Mandate_Type__c','MICR_Code__c','Name_Acc_Holder__c','Mobile_Number__c','Reference_1__c','RepayAcc__c','Spnsr_Bank__c','UMRN__c','Utility_Code__c','With_Bank__c'],              
        queryCriteria: ' where LoanAppl__c= \'' + this.loanAppId + '\' AND IsActive__c = true'

    }

    @track IntMsgparams={
        ParentObjectName:'IntgMsg__c', 
        ChildObjectRelName: '',       
        parentObjFields:['Id','LoanAppln__c','Status__c','RefObj__c','Name'],
        childObjFields: [],
        queryCriteria: ' where LoanAppln__c= \'' + this.loanAppId + '\' AND Name = \'mandate_create_form\' AND RefObj__c = \'NACH__c\''

    }
    @track amtInWords = 0;
    convertToWords(value){
        convertToWords({num : value}).
        then(result => {
            console.log('result ###166',result);
            this.amtInWords = result 
            console.log('result ###168',this.amtInWords);
            if(this.amtInWords){
                this.wrpAppReg.amt_rupees_words__c = this.amtInWords ;
            }
        }).catch( error => console.log('Error ## 169',error));
    }

    @wire(fetchSingleObject,{params:'$nachParam'})
    NACHData(wiredNACHData) {
        const { data, error } = wiredNACHData;
        this._wiredNACHData = wiredNACHData;
        
        if (data) {
            console.log('wiredNACHData',JSON.stringify(data))
            let tempholder=JSON.parse(JSON.stringify(data))
            console.log('temp holder',tempholder)
            console.log('temp holder parent',tempholder.parentRecords)
            if(tempholder.parentRecords!= undefined && tempholder.parentRecords !=null){
             this.nachRecord=JSON.parse(JSON.stringify(data.parentRecords));
             
          // this.nachRecord=JSON.parse(JSON.stringify(data));
            console.log('wiredNACHData parent',this.nachRecord,this.nachRecord.length)

            if(this.nachRecord != undefined &&  this.nachRecord!=null){
                for(var i=0;i<this.nachRecord.length;i++)
                {
                    this.wrpAppReg.ApplicantId =   this.nachRecord[i].LoanAppl__r.Applicant__c;
                    
                    console.log('this.nachRecord[i].LoanAppl__r.Applicant__c',this.nachRecord[i].LoanAppl__r.Applicant__c)
                    this.wrpAppReg.Account_Type__c = this.nachRecord[i].Account_Type__c ? this.nachRecord[i].Account_Type__c : ''; ;
                    this.wrpAppReg.amount_numbers__c = this.nachRecord[i].amount_numbers__c ? this.nachRecord[i].amount_numbers__c : '';
                    if(this.nachRecord[i].amount_numbers__c != '' ||  this.nachRecord[i].amount_numbers__c != undefined){
                        this.convertToWords(this.nachRecord[i].amount_numbers__c);
                        if(this.amtInWords){
                            this.wrpAppReg.amt_rupees_words__c = this.amtInWords ;
                        }
                        console.log('this.wrpAppReg.amt_rupees_words__c ##280', this.amtInWords,this.wrpAppReg.amt_rupees_words__c); 
                    }                   
                    this.wrpAppReg.Authorise__c = this.nachRecord[i].Authorise__c ? this.nachRecord[i].Authorise__c : '';
                    this.wrpAppReg.Bank_Account_Number__c = this.nachRecord[i].Bank_Account_Number__c ? this.nachRecord[i].Bank_Account_Number__c : '';
                    this.wrpAppReg.Bank_Branch__c = this.nachRecord[i].Bank_Branch__c ? this.nachRecord[i].Bank_Branch__c : '';
                    
                    this.wrpAppReg.Bank_City__c = this.nachRecord[i].Bank_City__c ? this.nachRecord[i].Bank_City__c : '';
                    this.wrpAppReg.Bank_Code__c = this.nachRecord[i].Bank_Code__c ? this.nachRecord[i].Bank_Code__c : '';
                    this.wrpAppReg.Bank_Name__c = this.nachRecord[i].Bank_Name__c ? this.nachRecord[i].Bank_Name__c : '';
                    this.wrpAppReg.Date__c = this.nachRecord[i].Date__c ? this.nachRecord[i].Date__c : '';
                    if(this.nachRecord[i].Debit_Type__c){
                        this.wrpAppReg.Debit_Type__c = this.nachRecord[i].Debit_Type__c 
                    }else{
                        this.wrpAppReg.Debit_Type__c = 'Maximum Amount' 
                    }
                    this.wrpAppReg.Email_Id__c = this.nachRecord[i].Email_Id__c ? this.nachRecord[i].Email_Id__c : '';
                    
                    this.wrpAppReg.eNACH_Registration_Status__c = this.nachRecord[i].eNACH_Registration_Status__c ? this.nachRecord[i].eNACH_Registration_Status__c : '';
                    this.wrpAppReg.eNACH_Rejection_Reasons__c = this.nachRecord[i].eNACH_Rejection_Reasons__c ? this.nachRecord[i].eNACH_Rejection_Reasons__c : '';
                    this.wrpAppReg.Frequency__c = this.nachRecord[i].Frequency__c ? this.nachRecord[i].Frequency__c : '';
                    this.wrpAppReg.From_Date__c = this.nachRecord[i].From_Date__c ? this.nachRecord[i].From_Date__c : '';
                    this.wrpAppReg.IFSC_Code__c = this.nachRecord[i].IFSC_Code__c ? this.nachRecord[i].IFSC_Code__c : '';
                    this.wrpAppReg.LoanAppl__c = this.nachRecord[i].LoanAppl__c ? this.nachRecord[i].LoanAppl__c : '';
                    
                    this.wrpAppReg.Mandate_Type__c = this.nachRecord[i].Mandate_Type__c ? this.nachRecord[i].Mandate_Type__c : '';
                    this.wrpAppReg.MICR_Code__c = this.nachRecord[i].MICR_Code__c ? this.nachRecord[i].MICR_Code__c : '';
                    this.wrpAppReg.Name_Acc_Holder__c = this.nachRecord[i].Name_Acc_Holder__c ? this.nachRecord[i].Name_Acc_Holder__c : '';
                    this.wrpAppReg.Mobile_Number__c = this.nachRecord[i].Mobile_Number__c ? this.nachRecord[i].Mobile_Number__c : '';
                    this.wrpAppReg.Reference_1__c = this.nachRecord[i].Reference_1__c ? this.nachRecord[i].Reference_1__c : '';
                    this.wrpAppReg.RepayAcc__c = this.nachRecord[i].RepayAcc__c ? this.nachRecord[i].RepayAcc__c : '';
                    this.repaymentAccountId = this.nachRecord[i].RepayAcc__c;
                    console.log('repaymentAccountId',this.repaymentAccountId)
                    this.wrpAppReg.Id = this.nachRecord[i].Id ? this.nachRecord[i].Id : '';
                    this.wrpAppReg.Spnsr_Bank__c = this.nachRecord[i].Spnsr_Bank__c ? this.nachRecord[i].Spnsr_Bank__c : '';
                    this.wrpAppReg.UMRN__c = this.nachRecord[i].UMRN__c ? this.nachRecord[i].UMRN__c : '';
                    this.wrpAppReg.Utility_Code__c = this.nachRecord[i].Utility_Code__c ? this.nachRecord[i].Utility_Code__c : '';
                    this.wrpAppReg.With_Bank__c = this.nachRecord[i].Utility_Code__c ? this.nachRecord[i].With_Bank__c : '';
                    this.wrpAppReg.eNACH_Registration_Status__c = this.nachRecord[i].eNACH_Registration_Status__c ? this.nachRecord[i].eNACH_Registration_Status__c : '';
                    this.wrpAppReg.eNACH_Rejection_Reasons__c = this.nachRecord[i].eNACH_Rejection_Reasons__c ? this.nachRecord[i].eNACH_Rejection_Reasons__c : '';
                    this.wrpAppReg.sobjectType='NACH__c';
                    this.wrpAppReg.EnachInitiationDateTime__c = this.nachRecord[i].EnachInitiationDateTime__c ? this.nachRecord[i].EnachInitiationDateTime__c : '';
                    this.wrpAppReg.EnachResponseDateTime__c = this.nachRecord[i].EnachResponseDateTime__c ? this.nachRecord[i].EnachResponseDateTime__c : '';
                    this.initiationDateTimeVaue=this.wrpAppReg.EnachInitiationDateTime__c;
                    this.responseDateTimeValue=this.wrpAppReg.EnachResponseDateTime__c;
                    console.log(' this.wrpAppReg.Id', this.wrpAppReg.Id)

                    // if(this.wrpAppReg.eNACH_Registration_Status__c=='Authentication pending at customer end'){
                    //     this.enachRetrigger=true;
                    // }
                    if(this.wrpAppReg.Mandate_Type__c=='Enach'){
                        this.IsrequiredUMRN=true;
                        this.isEnachVisible =true;
                        if(this.wrpAppReg.eNACH_Registration_Status__c =='Success'){
                            this.isStatusSuccess=true;
                        }else{
                            if(this.disableMode==true){
                                this.isStatusSuccess=true;
                            }
                            else{
                            this.isStatusSuccess=false;
                            }
                        }
                        //added this.wrpAppReg.eNACH_Registration_Status__c === 'register_success' for LAK-8109
                        if(this.wrpAppReg.eNACH_Registration_Status__c ==='Authentication pending at customer end' || this.wrpAppReg.eNACH_Registration_Status__c ==='success' || this.wrpAppReg.eNACH_Registration_Status__c === 'register_success'){
                            this.enachRetrigger=true;
                        }else{
                            if(this.disableMode==true){
                                this.enachRetrigger=true;
                            }
                            else{
                            this.enachRetrigger=false;
                            }
                        }
                    }
                    if(this.wrpAppReg.Mandate_Type__c=='Physical Nach'){
                        this.IsrequiredUMRN=false;
                        this.isEnachVisible =false;
                        this.isPhysicalNachButton=true;
                        this.showDocList=true;
                    }

                }
                console.log('this.wrpAppReg.ApplicantId',this.wrpAppReg.ApplicantId)
                this.RepaymentIDMethod();
            }
        }
           
        } else if (error) {
            console.log(error);
        }
       
    }
    RepaymentIDMethod(){
        console.log('inside imperative')
        getSobjectData({ params: this.params })
        .then((result) => {
            console.log('tahura result', result)
            if (result.parentRecords) {
                this.RepaymentIdPreview = result.parentRecords[0].Id;
                console.log('RepaymentIdPreview',this.RepaymentIdPreview)
                
            }
        })
        .catch((error) => {
            console.error('Error in line ##213', error)
        })
    }

    get _disable(){
        return this.hasEditAccess===false;
    }

    responseDateTimeValue=this.wrpAppReg.EnachResponseDateTime__c;
    get formattedResponseDateTime() {
        let value = formattedDateTimeWithoutSeconds(this.responseDateTimeValue);
        return value;
        /*if (!this.dateTimeValue) {
            return '';
        }
        const dateTime = new Date(this.dateTimeValue);
        const options = { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' };
        // const formattedDate = dateTime.toLocaleDateString('en-US', options);
        const formattedDate = `${dateTime.getMonth() + 1}/${dateTime.getDate()}/${dateTime.getFullYear()}`;

        const ampm = dateTime.getHours() >= 12 ? 'PM' : 'AM';
        const hours = dateTime.getHours() % 12 || 12;
        const minutes = ('0' + dateTime.getMinutes()).slice(-2);
         return `${formattedDate}, ${hours}:${minutes} ${ampm}`;
        //return `${formattedDate}`;*/
    }
    initiationDateTimeVaue=this.wrpAppReg.EnachInitiationDateTime__c;
    get formattedInitiationDateTime(){
        let value = formattedDateTimeWithoutSeconds(this.initiationDateTimeVaue);
        return value;
    }

    formatDateTime(dateTimeValue){
        
        if (!dateTimeValue) {
            return '';
        }
        const months = [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];

        const dateTime = new Date(dateTimeValue);
        const month = months[dateTime.getMonth()];
        const options = { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' };
        // const formattedDate = dateTime.toLocaleDateString('en-US', options);
        // const formattedDate = `${dateTime.getMonth() + 1}/${dateTime.getDate()}/${dateTime.getFullYear()}`;
        const formattedDate = `${dateTime.getDate()}-${month}-${dateTime.getFullYear()}`;
        const ampm = dateTime.getHours() >= 12 ? 'PM' : 'AM';
        const hours = dateTime.getHours() % 12 || 12;
        const minutes = ('0' + dateTime.getMinutes()).slice(-2);
        return `${formattedDate}, ${hours}:${minutes} ${ampm}`;
    }


    connectedCallback() {

        // console.log("isReadOnly:::::::: ", this.isReadOnly);
        console.log("hasEditAccess in regulatory 329:::::::: ", this.hasEditAccess);
        console.log("disableMode in regulatory::::::::: ", this.disableMode);
        if (this.hasEditAccess === false) {
            this.disableMode = true;
            this.isStatusSuccess=true;
            this.enachRetrigger=true;
        }
        this.scribeToMessageChannel();     
        
        if(this.nachRecord.length === 0){
            this.wrpAppReg.Debit_Type__c = 'Maximum Amount'
        }
       // this.IntMsgData();
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
        console.log("this.validateFlag>>>", this.validateFlag);
       
       

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

        return isValid;
    }

    //enach field visibility

    HandleValueChange(event)
    {
        this.wrpAppReg.Mandate_Type__c = event.target.value;
        if(this.wrpAppReg.Mandate_Type__c=='Enach'){
            this.IsrequiredUMRN=true;
            this.isEnachVisible =true;
            this.isPhysicalNachButton=false;
            this.showDocList=false;
            if(this.wrpAppReg.eNACH_Registration_Status__c =='Success'){
                this.isStatusSuccess=true;
            }else{
                this.isStatusSuccess=false;
            }
            if(this.wrpAppReg.eNACH_Registration_Status__c =='Authentication pending at customer end' || this.wrpAppReg.eNACH_Registration_Status__c ==='success' || this.wrpAppReg.eNACH_Registration_Status__c ==='register_success'){
                this.enachRetrigger=true;
            }else{
                if(this.disableMode==true){
                    this.enachRetrigger=true;
                }
                else{
                this.enachRetrigger=false;
                }
            }
        }
        if(this.wrpAppReg.Mandate_Type__c=='Physical Nach'){
            this.IsrequiredUMRN=false;
            this.isEnachVisible =false;
            this.isPhysicalNachButton=true;
            this.showDocList=true;
        }
    }

    HandleDebitChange(event){
        this.wrpAppReg.Debit_Type__c = event.target.value;
    }
    //disable mandate type based on enach status

    // handleEnachStatus(event){
    //     this.wrpAppReg.eNACH_Registration_Status__c = event.target.value;
    //     if(this.wrpAppReg.eNACH_Registration_Status__c =='Success'){
    //         this.isStatusSuccess=true;
    //     }else{
    //         this.isStatusSuccess=false;
    //     }
    // }


    //mandate picklist and debit type

    @wire(getObjectInfo, { objectApiName: NACHobj })
    objInfo

    generatePicklist(data) {
        return data.values.map(item => ({ label: item.label, value: item.value }))
    }

    @wire(getPicklistValues, { recordTypeId: '$objInfo.data.defaultRecordTypeId', fieldApiName: MANDATETYPE })
    IsMandateTypeHandler({ data, error }) {
        if (data) {
            console.log(data);
            this.IsMandateTypeOptions = [...this.generatePicklist(data)]

        }
        if (error) {
            console.log(error)
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objInfo.data.defaultRecordTypeId', fieldApiName: DEBITTYPE })
    IsDebitTypeHandler({ data, error }) {
        if (data) {
            console.log(data);
            this.IsDebitTypeOptions = [...this.generatePicklist(data)]

        }
        if (error) {
            console.log(error)
        }
    }


    //pendy drop logic
    // @wire(fetchSingleObject,{params:'$RepVerifyParam'})
    // RVData (wiredRVData) {
    //   const { data, error } = wiredRVData;
    //   this._wiredRVData = wiredRVData;        
       
    //     if (data) {

    //         console.log('RV data',JSON.parse(JSON.stringify(data)))
    //         this.RVResult=JSON.parse(JSON.stringify(data.parentRecords[0])); 
    //         console.log('this.RVResult',this.RVResult) 
    //         this.RVRecord.PennyDropStatus__c = this.RVResult.PennyDropStatus__c ? this.RVResult.PennyDropStatus__c:'';
    //         this.RVRecord.RepayAcc__c = this.RVResult.RepayAcc__c ? this.RVResult.RepayAcc__c:'';
    //         this.RVRecord.Id = this.RVResult.Id ? this.RVResult.Id:'';

    //         console.log('this.RVRecord.PennyDropStatus__c',this.RVRecord.PennyDropStatus__c)


    //     } else if (error) {
    //         console.log(error);
    //     }
    // }


    //end penny drop
    //spdc logic

    //fetching  repayment details
    // @wire(getData,{params:'$params'})
    // RepayData(wiredRepayData) {
    //     console.log(' Loan id in parent comp' ,this.loanAppId);       
    //     const { data, error } = wiredRepayData;
    //     this._wiredRepayData = wiredRepayData;
    //     if (data) {
           
    //         console.log("data repay stringify "+(JSON.stringify(data)))
    //         this.RepayResult=JSON.stringify(data)
    //         this.RepayParentRecord=JSON.parse(JSON.stringify(data[0].parentRecord));            
           
           
    //         this.RepaymentIdfromParentRecord = this.RepayParentRecord.Id
    //         this.parentDetails.MICR_Code__c = this.RepayParentRecord.MICR_Code__c ? this.RepayParentRecord.MICR_Code__c : '';
    //         this.parentDetails.Bank_Name__c = this.RepayParentRecord.Bank_Name__c ? this.RepayParentRecord.Bank_Name__c : '';
    //         this.parentDetails.Bank_Branch__c = this.RepayParentRecord.Bank_Branch__c ? this.RepayParentRecord.Bank_Branch__c : '';
    //         this.parentDetails.Id = this.RepayParentRecord.Id;
    //         if(this.RepayParentRecord.Applicant_Banking__r){
    //                   if(this.RepayParentRecord.Applicant_Banking__r.Appl__r){
    //         this.parentDetails.PDCbyName = this.RepayParentRecord.Applicant_Banking__r.Appl__r.FullName__c ? this.RepayParentRecord.Applicant_Banking__r.Appl__r.FullName__c : '';
    //                   }}
    //         this.parentDetails.IFSC_Code__c = this.RepayParentRecord.IFSC_Code__c ? this.RepayParentRecord.IFSC_Code__c : '';
    //         this.parentDetails.Account_Number__c = this.RepayParentRecord.Account_Number__c ?  this.RepayParentRecord.Account_Number__c  : '';
    //         this.parentDetails.Loan_Application__c = this.RepayParentRecord.Loan_Application__c;
    //         this.parentDetails.Repayment_Account__c = this.RepayParentRecord.Id;

           
    //         let tempspdcParams = this.spdcParam;
    //         tempspdcParams.queryCriteria = ' where Loan_Application__c	= \'' + this.loanAppId + '\' AND Repayment_Account__c	= \'' + this.RepaymentIdfromParentRecord + '\' AND PDC_Type__c = \'SPDC\' ';
    //         this.spdcParam = {...tempspdcParams};

    //         let tempRVParams = this.RepVerifyParam;
    //         tempRVParams.queryCriteria = ' where RepayAcc__c	= \'' + this.RepaymentIdfromParentRecord + '\' order by CreatedDate  desc limit 1';
    //         this.RepVerifyParam = {...tempRVParams};
    
    
    //     } else if (error) {
    //         console.log(error);
    //     }
    // }

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
    // // values for unchecked

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
    
    //  //picklist value for cheque purpose

    //  @wire(getObjectInfo,{objectApiName:PDCObj})
    //  objInfo
 
    //  generatePicklist(data){
    //      return data.values.map(item =>({ label: item.label, value: item.value }))
    //  } 
     
    //  @wire(getPicklistValues,{recordTypeId : '$objInfo.data.defaultRecordTypeId', fieldApiName : PURPOSE})
    //  TreatmentHandler({data,error}){
    //      if(data){
    //          console.log('picklist data',data);
    //         //  this.ChequePurposeOptions = [...this.generatePicklist(data)]
           

    //          let tempOptions =[...this.generatePicklist(data)]
    //          console.log('tempOptions',tempOptions);

    //          this.ChequePurposeOptions=[...tempOptions]
             
    //      }
    //      if(error){
    //          console.log(error)
    //      }
    //  }

    //  handleInputChange(event){

    //     this.wrpAppReg[event.target.dataset.name] = event.target.value;
    //     console.log('this.wrpAppReg inside handlechange', this.wrpAppReg)

    //  }

    //  //spdc change
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

    // //add row spdc
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
    showMessage()
    {
    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: this.customlabel.RepamentNach_Update_SuccessMessage,
                            variant: "success",
                            mode: "sticky"
                        }))
    }

    //spdc records available event handler
    @track hasSPDCRecords=false;
    spdcrecords(event){
        console.log('event inside nach spdc records',event.detail.hasSPDCRecords)
        this.hasSPDCRecords=event.detail.hasSPDCRecords;
        const tospdcrecords = new CustomEvent('tospdcrecords', {
            detail: { hasSPDCRecords: this.hasSPDCRecords }  // Boolean value
        });
        this.dispatchEvent(tospdcrecords);
    }
    // @track ErrorFlag=false;
    // ErrorFlag(event){
    //     console.log('event.details'+event.detail)
    //     if(event.detail.value){
    //         this.ErrorFlag=true;
    //         console.log('inside parent event.details'+this.ErrorFlag)
    //     }
    //     else{
    //         console.log('else part inside parent event.details'+this.ErrorFlag)
    //     }
    // }

    //child data
    // @track SPDCChequeCount

    // noofchequecount(event){    
    //     this.SPDCChequeCount=event.detail
    //     console.log('this.SPDCChequeCount inside parent event.details'+this.SPDCChequeCount)
        
    // }

    // spdcdata(event){
    //     console.log('spdc record inside parent event.details'+event.detail)

    // }
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
     handleSave(event)
     {
        this.showSpinner=true;
        this.handleChildData();
        console.log('SPDCChildRecords inside save parnt',JSON.stringify(this.SPDCChildRecords));
        console.log('SPDCChildRecords count',this.sum);
        
        if(this.sum<3 && this.validateFlag==true){
            this.showSpinner=false;
            this.showToast("Error!", "error", this.customlabel.SPDCMinThreeCheque,"sticky");
        }
        else{

            //nach save
        let nachRecord = [];
        let nachRecordObj = {};     
    //     this.wrpAppReg.sobjectType='NACH__c';
    //     this.wrpAppReg.LoanAppl__c=this.loanAppId;       
    //    this.wrpAppReg.RepayAcc__c=this.repaymentAccountId;
    //nachRecord.push(this.wrpAppReg);
    nachRecordObj.sobjectType='NACH__c';
    nachRecordObj.LoanAppl__c=this.loanAppId;       
    nachRecordObj.RepayAcc__c=this.repaymentAccountId;
    nachRecordObj.Debit_Type__c=this.wrpAppReg.Debit_Type__c;
    nachRecordObj.ApplicantId=this.wrpAppReg.ApplicantId;
    nachRecordObj.Account_Type__c=this.wrpAppReg.Account_Type__c;
    nachRecordObj.amount_numbers__c=this.wrpAppReg.amount_numbers__c;
    nachRecordObj.Authorise__c=this.wrpAppReg.Authorise__c;
    nachRecordObj.Bank_Account_Number__c=this.wrpAppReg.Bank_Account_Number__c;
    nachRecordObj.Bank_Branch__c=this.wrpAppReg.Bank_Branch__c;
    nachRecordObj.Bank_City__c=this.wrpAppReg.Bank_City__c;
    nachRecordObj.Bank_Code__c=this.wrpAppReg.Bank_Code__c;
    nachRecordObj.Bank_Name__c=this.wrpAppReg.Bank_Name__c;
    nachRecordObj.Email_Id__c=this.wrpAppReg.Email_Id__c;
    nachRecordObj.Frequency__c=this.wrpAppReg.Frequency__c;
    nachRecordObj.From_Date__c=this.wrpAppReg.From_Date__c;
    nachRecordObj.IFSC_Code__c=this.wrpAppReg.IFSC_Code__c;
    nachRecordObj.Mandate_Type__c=this.wrpAppReg.Mandate_Type__c;
    nachRecordObj.MICR_Code__c=this.wrpAppReg.MICR_Code__c;
    nachRecordObj.Name_Acc_Holder__c=this.wrpAppReg.Name_Acc_Holder__c;
    nachRecordObj.Mobile_Number__c=this.wrpAppReg.Mobile_Number__c;
    nachRecordObj.Reference_1__c=this.wrpAppReg.Reference_1__c;
    nachRecordObj.Spnsr_Bank__c=this.wrpAppReg.Spnsr_Bank__c;
    nachRecordObj.Utility_Code__c=this.wrpAppReg.Utility_Code__c;
    nachRecordObj.Date__c=this.wrpAppReg.Date__c;        
    nachRecordObj.Id=this.wrpAppReg.Id;
    nachRecordObj.RepayAcc__c=this.wrpAppReg.RepayAcc__c
    nachRecordObj.With_Bank__c=this.wrpAppReg.With_Bank__c
       console.log(' 980 this.wrpAppReg inside save',JSON.stringify(this.wrpAppReg))
       console.log(' 980 this.nachRecordObj inside save',JSON.stringify(nachRecordObj))
       
        nachRecord.push(nachRecordObj);
        upsertMultipleRecord({params:nachRecord})
        .then(result => {                    
                       this.showMessage();
            refreshApex(this._wiredNACHData);    
                            
           
        }).catch(error => {
            console.log(error);
        })
        
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
         

    //  let SPDCChildRecords = [];
    //      let spdcchildRecordObj = {};
    //      for(var i=0;i<this.AllSPDCRecords.length;i++){
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
    //             spdcchildRecordObj.Account_Number__c=this.AllSPDCRecords[i].Account_Number__c;
    //             spdcchildRecordObj.PDCbyName=this.AllSPDCRecords[i].PDCbyName;
    //             spdcchildRecordObj.Same_As_Repayment_Account__c=this.AllSPDCRecords[i].Same_As_Repayment_Account__c;
    //             //Same_As_Repayment_Account__c
                 
 
 
 
    //             SPDCChildRecords.push(spdcchildRecordObj);
    //          }
    //      }
    //      upsertMultipleRecord({params:SPDCChildRecords})
    //      .then(result => {                     
            
    //          this.showMessage();
    //          refreshApex(this._wiredRepaySPDCData);    
                              
             
    //      }).catch(error => {
    //          console.log(error);
    //      })
    
     }
    }
 

    // //  ********************penny drop handle**************************************

    // @wire(getSessionId)
    // wiredSessionId({ error, data }) {
    //     if (data) {
    //         console.log('session Id=', data);
    //         this.sessionId = data;
    //         loadScript(this, cometdlwc);
    //     } else if (error) {
    //         console.log('Error In getSessionId = ', error);
    //         this.sessionId = undefined;
    //     }
    // }

    // handleClick(event) {
    //     console.log('target name ', event.target.name);
    //    // this.showSpinner = true;
    //     this.createRepayAccVer();
    // }

    // createRepayAccVer() {
    //     const obje = {
    //         sobjectType: "RepayAccVerify__c",
    //         LoanAppl__c: this.loanAppId,
    //         RepayAcc__c: this.RepaymentIdfromParentRecord ? this.RepaymentIdfromParentRecord : ''
    //     }
    //     let newArray = [];
    //     if (obje) {
    //         newArray.push(obje);
    //     }
    //     if (newArray) {
    //         upsertMultipleRecord({ params: newArray })
    //             .then((result) => {
    //                 console.log('Result after creating Repayment Account Verification is ', JSON.stringify(result));
    //                 // this.createIntegrationMessageForPennyDrop(result[0].Id);
    //                 let fields = {};
    //                 //  fields.sobjectType = 'IntgMsg__c';
    //                 fields.Name = 'Pennydrop';
    //                 fields.Status__c = 'New';
    //                 fields.Svc__c = 'Pennydrop';
    //                 fields.BU__c = 'HL / STL';
    //                 fields.IsActive__c = true;
    //                 fields.RefObj__c = 'RepayAccVerify__c';
    //                 fields.RefId__c = result[0].Id ? result[0].Id : '';
    //                 this.createIntMsg(fields, 'Penny Drop');
    //             })
    //             .catch((error) => {
                    
    //                 console.log('Error In creating Record', error);
    //                 this.showToast('Error', 'error', 'Error creating Repayment Account Verification record');
    //             });
    //     }
    // }

        
    // showToast(titleVal, variantVal, messageVal) {
    //     const evt = new ShowToastEvent({
    //         title: titleVal,
    //         variant: variantVal,
    //         message: messageVal
    //     });
    //     this.dispatchEvent(evt);
    // }

    // createIntMsg(fieldsInt, name) {
    //     const recordInput = {
    //         apiName: 'IntgMsg__c',
    //         fields: fieldsInt
    //     };
    //     createRecord(recordInput).then((result) => {
    //         console.log('Paytm Integration Record Created ##405', result.id, result);
    //        if (name === 'Enach') {
    //             this.eNachIntMsgId = result.id;
    //             // this.callSubscribePlatformEve();
    //             this.startPolling('Enach');
    //         }
    //         else if (name === 'Penny Drop') {
    //             this.pennyDropIntMsgId = result.id;
    //             this.callSubscribePlatformEve();
    //         }
    //     }).catch((error) => {
    //         this.showSpinner = false
    //         console.log('Error ##789', error);
    //         this.showToast('Errpr', 'error', 'Error creating Integration record');
    //         // this.showToastMessage('Error creating Integration record', error.body.message, 'error', 'dismissable')
    //     });
    // }

    // startPolling(name) {
    //     console.log('Polling has started ##875')
    //     this.chequeInterval = setInterval(() => {
    //         this.getIntRecord(name);
    //     }, 5000);
    // }

    // getIntRecord(name) {
    //     let paramsLoanApp;
    //     if (name === 'Enach') {
    //         paramsLoanApp = {
    //             ParentObjectName: 'IntgMsg__c',
    //             parentObjFields: ['Id', 'Status__c', 'Name'],
    //             queryCriteria: ' where Id = \'' + this.eNachIntMsgId + '\''
    //         }
    //     }
    //     getSobjectData({ params: paramsLoanApp })
    //         .then((result) => {
    //             console.log('Int Msg data is', JSON.stringify(result));
                
    //             if (result.parentRecords[0].Status__c === 'Responded' && result.parentRecords[0].Name === 'mandate_create_form') {
    //                 //this.disableLmsUpdate = true;
    //                 this.showSpinner = false;
    //                 this.getNachData();
    //                 this.showToast('Success', 'success', 'Integration is Successful');
    //                 clearInterval(this.chequeInterval);
    //                 console.log('Cleared ##473');
    //             }
    //             if (result.parentRecords[0].Status__c === 'Exception' && result.parentRecords[0].Name === 'mandate_create_form') {
    //                 // this.disableLmsUpdate = false;
    //                 this.showSpinner = false;
    //                 this.showToast('Error', 'error', 'Integration is failed, Please Retry Again');
    //                 clearInterval(this.chequeInterval);
    //                 console.log('Cleared ##473');
    //             }
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getting Int Msg Record ', error);
    //             //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
    //         });
    // }

    // callSubscribePlatformEve() {
    //     //Commnet platform event subscription temproroly
    //     this.handleSubscribe();
    // }
    // handleSubscribe() {
    //     const self = this;
    //     this.cometdlib = new window.org.cometd.CometD();
    //     console.log('cometdlib  value ', JSON.stringify(this.cometdlib));

    //     //Calling configure method of cometD class, to setup authentication which will be used in handshaking
    //     this.cometdlib.configure({
    //         url: window.location.protocol + '//' + window.location.hostname + '/cometd/50.0/',
    //         requestHeaders: { Authorization: 'OAuth ' + this.sessionId },
    //         appendMessageTypeToURL: false,
    //         logLevel: 'debug'
    //     });

    //     this.cometdlib.websocketEnabled = false;
    //     this.cometdlib.handshake(function (status) {
    //         let tot = self.timeout
    //         console.log('noIntResponec ', self.noIntResponec);
    //         self.noIntResponec = true;
    //         self.startTimerForTimeout(tot);
    //         if (status.successful) {
    //             console.log('Successfully connected to server');
    //             self.PEsubscription = self.cometdlib.subscribe(self.channelName, (message) => {
    //                 console.log('subscribed to message!', JSON.stringify(message));
    //                 console.log(message.data.payload);
    //                 self.handlePlatformEventResponce(message.data.payload);

    //             }
    //                 ,
    //                 (error) => {
    //                     this.showSpinner = false;
    //                     console.log('Error In Subscribing ', error);
    //                 }
    //             );
    //             console.log(window.location.protocol + '//' + window.location.hostname + '/cometd/50.0/',);
    //         } else {

    //             /// Cannot handshake with the server, alert user.
    //             console.error('Error in handshaking: ' + JSON.stringify(status));
    //             //self.stopSpinner();
    //             this.showSpinner = false;
    //         }
    //     });
    //     console.log('SUBSCRIPTION ENDED');
    // }

    // handlePlatformEventResponce(payload) {
    //     console.log('responce From PlatformEvent ', payload);
    //     if (payload) {
    //         if (payload.SvcName__c === 'Pennydrop') {
    //             if (payload.RecId__c === this.pennyDropIntMsgId && payload.Success__c) {
    //                 this.disableIntiatePennyDrop = true;
    //                 this.getNachData();
    //                 this.showSpinner = false;
    //                 this.showToast('Success', 'success', 'Success! Penny drop on a repayment account has been successful');
    //             } else {
    //                 this.showSpinner = false;
    //                 this.showToast('Error', 'error', 'Error! Penny drop has been failed. Please Retry!');
    //             }
    //         } else if (payload.SvcName__c === 'Enach status') {
    //             if (payload.RecId__c === this.eNachIntMsgId && payload.Success__c) {
    //                 //this.disableIntiatePennyDrop = true;
    //                 this.getNachData();
    //                 this.showSpinner = false;
    //                 this.showToast('Success', 'success', 'Enach is Successful');
    //             } else {
    //                 this.showSpinner = false;
    //                 this.showToast('Error', 'error', 'Error! Enach has been failed. Please Retry!');
    //             }
    //         }
    //     } else {
    //         this.showSpinner = false;
    //     }

    // }

    // startTimerForTimeout(timeout) {
    //     console.log('startTimerForTimeout ', timeout);
    //     setTimeout(() => {
    //         this.showSpinner = true;
    //     }, timeout);
    // }

     // ***********************Enach Retrigger Button********************************
     handleEnachbutton(event) {
        this.showSpinner = true;
      //  this.getNachDataNew();
      let fieldNach = {};
                        //fieldNach.sobjectType = 'NACH__c';
                        fieldNach.Name = 'mandate_create_form';
                        fieldNach.Status__c = 'New';
                        fieldNach.Svc__c = 'mandate_create_form';
                        fieldNach.BU__c = 'HL / STL';
                        fieldNach.IsActive__c = true;
                        fieldNach.RefObj__c = 'NACH__c';
                        fieldNach.RefId__c = this.wrpAppReg.Id ? this.wrpAppReg.Id : '';
      this.createIntMsg(fieldNach, 'Enach');
       

    }
    
    createIntMsg(fieldsInt, name) {
        const recordInput = {
            apiName: 'IntgMsg__c',
            fields: fieldsInt
        };
        createRecord(recordInput).then((result) => {
            console.log('Paytm Integration Record Created ##405', result.id, result);
            if (name === 'paytm') {
                this.paytmIntMsgId = result.id;
                this.startPolling('paytm');
            } else if (name === 'Sequence API') {
                this.lmsUpdateIntMsgId = result.id;
                this.startPolling('Sequence API');
            } else if (name === 'Enach') {
                this.eNachIntMsgId = result.id;
                // this.callSubscribePlatformEve();
                this.startPolling('Enach');
            }
            else if (name === 'Penny Drop') {
                this.pennyDropIntMsgId = result.id;
                this.callSubscribePlatformEve();
            }
        }).catch((error) => {
            this.showSpinner = false
            console.log('Error ##789', error);
            this.showToast('Errpr', 'error', this.label.CustomerConf_PlatformEvent_ErrorMessage);
            // this.showToastMessage('Error creating Integration record', error.body.message, 'error', 'dismissable')
        });
    }

    startPolling(name) {
        console.log('Polling has started ##875')
        this.chequeInterval = setInterval(() => {
            this.getIntRecord(name);
        }, 5000);
    }

    getIntRecord(name) {
        let paramsLoanApp;
        if (name === 'paytm') {
            paramsLoanApp = {
                ParentObjectName: 'IntgMsg__c',
                parentObjFields: ['Id', 'Status__c', 'Name'],
                queryCriteria: ' where Id = \'' + this.paytmIntMsgId + '\''
            }
        } else if (name === 'Sequence API') {
            paramsLoanApp = {
                ParentObjectName: 'IntgMsg__c',
                parentObjFields: ['Id', 'Status__c', 'Name'],
                queryCriteria: ' where Id = \'' + this.lmsUpdateIntMsgId + '\''
            }
        } else if (name === 'Enach') {
            paramsLoanApp = {
                ParentObjectName: 'IntgMsg__c',
                parentObjFields: ['Id', 'Status__c', 'Name'],
                queryCriteria: ' where Id = \'' + this.eNachIntMsgId + '\''
            }
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Int Msg data is', JSON.stringify(result));
                
                if (result.parentRecords[0].Status__c === 'Responded' && result.parentRecords[0].Name === 'Paytm') {
                    this.disableSendLinkToCustmerDis = true;
                    this.disableLmsUpdateDis = false;
                    // this.showSpinner = false;
                    this.showToast('Success', 'success', this.label.CustomerConf_Integration_SuccessMessage);
                    clearInterval(this.chequeInterval);
                    console.log('Cleared ##468')
                    this.getPaymentRecordData();
                }
                if (result.parentRecords[0].Status__c === 'Exception' && result.parentRecords[0].Name === 'Paytm') {
                    this.disableSendLinkToCustmerDis = false;
                    this.disableLmsUpdateDis = false;
                    this.showSpinner = false;
                    this.showToast('Error', 'error', this.label.CustomerConf_Integration_ErrorMessage);
                    clearInterval(this.chequeInterval);
                    console.log('Cleared ##468')
                }
                if (result.parentRecords[0].Status__c === 'Responded' && result.parentRecords[0].Name === 'Sequence API') {
                    this.disableLmsUpdate = true;
                    this.disableLmsUpdateDis = true;
                    this.showSpinner = false;
                    this.showToast('Success', 'success', 'Integration is Successful');
                    clearInterval(this.chequeInterval);
                    console.log('Cleared ##473');
                }
                if (result.parentRecords[0].Status__c === 'Exception' && result.parentRecords[0].Name === 'Sequence API') {
                    this.disableLmsUpdate = false;
                    this.disableLmsUpdateDis = false;
                    this.showSpinner = false;
                    this.showToast('Error', 'error', 'Integration is failed, Please Retry Again');
                    clearInterval(this.chequeInterval);
                    console.log('Cleared ##473');
                }
                if (result.parentRecords[0].Status__c === 'Responded' && result.parentRecords[0].Name === 'mandate_create_form') {
                    //this.disableLmsUpdate = true;
                    this.showSpinner = false;
                  //  this.getNachData();
                    this.showToast('Success', 'success', 'Integration is Successful',"sticky");
                    clearInterval(this.chequeInterval);
                    console.log('Cleared ##473');
                    console.log('Cleared tahura ##473');
                }
                if (result.parentRecords[0].Status__c === 'Exception' && result.parentRecords[0].Name === 'mandate_create_form') {
                    // this.disableLmsUpdate = false;
                    this.showSpinner = false;
                    this.showToast('Error', 'error', 'Integration is failed, Please Retry Again',"sticky");
                    clearInterval(this.chequeInterval);
                    console.log('Cleared ##473');
                }
                // this.IntMsgData();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Int Msg Record ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    nachData = [];
    getNachData() {
        let paramsLoanApp = {
            ParentObjectName: 'NACH__c',
            parentObjFields: ['Id', 'LoanAppl__c', 'RepayAcc__c', 'eNACH_Registration_Status__c'],
            queryCriteria: ' where RepayAcc__c = \'' + this.RepaymentIdPreview + '\' AND LoanAppl__c = \'' + this.loanAppId + '\' AND IsActive__c = true ORDER BY createddate DESC'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Nach data is', JSON.stringify(result));
                if (result.parentRecords) {
                    this.nachData = result.parentRecords;
                } else {
                    this.nachButtonVisible = false;
                }
                this.getRepayAccVerData();
            })
            .catch((error) => {
                console.log('Error In getting nach data ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    getRepayAccVerData() {
        let paramsLoanApp = {
            ParentObjectName: 'RepayAccVerify__c',
            parentObjFields: ['Id', 'PennyDropStatus__c', 'MatchwithAccHolderName__c', 'PennyDropDateTime__c', 'NameRetuFromPennyDrop__c', 'RepayAcc__r.AccHolderName__c', 'RepayAcc__r.Account_Number__c', 'RepayAcc__r.Applicant_Banking__r.Id', 'RepayAcc__r.Applicant_Banking__r.eNACH_feasible__c', 'RepayAcc__r.Applicant_Banking__r.eNACHFeasible__c'],
            queryCriteria: ' where RepayAcc__c = \'' + this.RepaymentIdPreview + '\' AND LoanAppl__c = \'' + this.loanAppId + '\' ORDER BY createddate DESC'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                if (result.parentRecords) {
                    console.log('Repayment Account Verification Records Count ', result.parentRecords.length);
                    if (result.parentRecords.length < 3) {
                        this.repayAccVerDqata = result.parentRecords;
                        this.repayAccVerifiLogic();
                    } else {
                        this.repayAccVerDqata = result.parentRecords;
                        this.disableIntiatePennyDrop = true;
                        this.repayAccVerifiLogic();
                    }
                } else {
                    this.disableIntiatePennyDrop = false;
                }

                if (this.isReadOnly === true) {
                    this.disableIntiatePennyDrop = true;
                    this.disableLmsUpdate = true;
                    this.disableLmsUpdateDis = true;
                    this.disableSendLinkToCustmerDis = true;
                    this.disableSendLinkToCustmer = true;
                    this.repayAccVerDqata.forEach(item => {
                        item.nachButtonVisible = true;
                        item.failureDisable = true;
                    });
                }

            })
            .catch((error) => {
                console.log('Error In getRepayAccVerData  ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    showEnach
    @track repayAccVerDqata = [];
    repayAccVerifiLogic() {
        this.repayAccVerDqata.forEach(item => {
            if (item.RepayAcc__r.Applicant_Banking__r.eNACHFeasible__c && item.RepayAcc__r.Applicant_Banking__r.eNACHFeasible__c === 'Yes') {
                item.showEnach = true;
                item.nachButtonVisible = this.nachButtonVisible;
            } else {
                item.showEnach = false;
                item.nachButtonVisible = this.nachButtonVisible;
            }
            if (item.PennyDropStatus__c === 'Failure' || item.MatchwithAccHolderName__c === 'Yes') {
                item.nachButtonVisible = true;
                item.failureDisable = true;
            } else {
                item.failureDisable = false;
            }
            console.log('result of Repayment Account Verification is===>>> ', JSON.stringify(this.repayAccVerDqata));
        })
        let count = 0;
        this.repayAccVerDqata.forEach(item => {
            if (item.PennyDropStatus__c === 'Success') {
                count++;
            } else if (item.PennyDropStatus__c === 'Failure') {
                item.errorDisable = true;
                count--;
            }
        })
        if (count > 0) {
            this.disableIntiatePennyDrop = true;
        } else {
            if (this.repayAccVerDqata.length < 3) {
                this.disableIntiatePennyDrop = false;
            } else {
                this.disableIntiatePennyDrop = true;
            }
            //  this.disableIntiatePennyDrop = false;
        }

        this.repayAccVerDqata.forEach(item => {
            this.nachData.forEach(ite => {
                if (ite.eNACH_Registration_Status__c === 'success' || ite.eNACH_Registration_Status__c === 'Authentication pending at customer end') {
                    item.nachButtonVisible = true;
                }
                // else {
                //     item.nachButtonVisible = false;
                // }
            })
        })

    }

    getPaymentRecordData() {
        let paramsLoanApp = {
            ParentObjectName: 'Payment__c',
            parentObjFields: ['Id', 'TransStatus__c', 'PaymentRefNo__c', 'PaytmAPIStatus__c', 'PaytmAPIMessage__c'],
            queryCriteria: ' where Id = \'' + this.paymentId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('payment data data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    if (result.parentRecords[0].PaytmAPIStatus__c == 'Success') {
                        this.showToast('Success', 'success', this.label.CustomerConf_Integration_SuccessMessage);
                        this.paymentRefNumberDis = result.parentRecords[0].PaymentRefNo__c;
                        this.transcStatusDis = result.parentRecords[0].TransStatus__c;
                    } else {
                        this.showToast('Error', 'error', result.parentRecords[0].PaytmAPIMessage__c);
                    }
                    // this.paymentRefNumberDis = result.parentRecords[0].PaymentRefNo__c;
                    // this.transcStatusDis = result.parentRecords[0].TransStatus__c;
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting payment Record ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    callSubscribePlatformEve() {
        //Commnet platform event subscription temproroly
        this.handleSubscribe();
    }
    PEsubscription;
    cometdlib;
    @track noIntResponec = true;
    handleSubscribe() {
        const self = this;
        this.showSpinner = true;
        this.cometdlib = new window.org.cometd.CometD();
        console.log('cometdlib  value ', this.cometdlib);

        //Calling configure method of cometD class, to setup authentication which will be used in handshaking
        this.cometdlib.configure({
            url: window.location.protocol + '//' + window.location.hostname + '/cometd/50.0/',
            requestHeaders: { Authorization: 'OAuth ' + this.sessionId },
            appendMessageTypeToURL: false,
            logLevel: 'debug'
        });

        this.cometdlib.websocketEnabled = false;
        this.cometdlib.handshake(function (status) {
            // let tot = self.timeout
            console.log('noIntResponec ', self.noIntResponec);
            self.noIntResponec = true;
            // self.startTimerForTimeout(tot);
            if (status.successful) {
                console.log('Successfully connected to server');
                self.PEsubscription = self.cometdlib.subscribe(self.channelName, (message) => {
                    console.log('subscribed to message!', JSON.stringify(message));
                    console.log(message.data.payload);
                    self.handlePlatformEventResponce(message.data.payload);

                },
                    (error) => {
                        this.showSpinner = false;
                        console.log('Error In Subscribing ', error);
                    }
                );
                console.log(window.location.protocol + '//' + window.location.hostname + '/cometd/50.0/',);
            } else {

                /// Cannot handshake with the server, alert user.
                console.error('Error in handshaking: ' + JSON.stringify(status));
                //self.stopSpinner();
                this.showSpinner = false;
            }
        });
        console.log('SUBSCRIPTION ENDED');
    }

    handlePlatformEventResponce(payload) {
        console.log('responce From PlatformEvent ', payload);
        if (payload) {
            if (payload.SvcName__c === 'ICICI PennyDrop') {
                if (payload.IntMsgId__c === this.pennyDropIntMsgId && payload.Success__c) {
                    this.disableIntiatePennyDrop = true;
                    this.getRepayAccVerData();
                    this.getNachData();
                    this.showSpinner = false;
                    this.showToast('Success', 'success', this.label.CustomerConf_pennyDrop_SuccessMessage);
                } else {
                    this.getRepayAccVerData();
                    this.getNachData();
                    this.showSpinner = false;
                    this.showToast('Error', 'error', this.label.CustomerConf_PennyDrop_ErrorMessage);
                }
            } else if (payload.SvcName__c === 'Enach status') {
                if (payload.RecId__c === this.eNachIntMsgId && payload.Success__c) {
                    //this.disableIntiatePennyDrop = true;
                    this.getNachData();
                    this.showSpinner = false;
                    this.showToast('Success', 'success', this.label.CustomerConf_Enach_SuccessMessage);
                } else {
                    this.showSpinner = false;
                    this.showToast('Error', 'error', this.label.CustomerConf_Enach_ErrorMessage);
                }
            }
            this.handleUnsubscribe();
        } else {
            this.showSpinner = false;
        }

    }
    // ***********************form generation********************************
    //lak-9467
    @track IntHit=false;
    IntMsgData(){
        console.log('inside imperative')
        getSobjectData({ params: this.IntMsgparams })
        .then((result) => {
            console.log(' result', result)
            if (result && result.parentRecords && result.parentRecords.length > 0) {
                
                    this.IntHit=true;
                    console.log(' tahura result.parentRecords',result.parentRecords,this.IntHit)
               
                
                
            }
        })
        .catch((error) => {
            console.error('Error in line ##213', error)
        })
    }

    // @wire(fetchSingleObject,{params:'$IntMsgparams'})
    // IntMsgData(wiredIntMsgData) {
    //     const { data, error } = wiredIntMsgData;
    //     this._wiredIntMsgData = wiredIntMsgData;
        
    //     if (data) {
    //         if(data.parentRecords && data.parentRecords.length>0){
    //             this.IntHit=true;
    //             console.log(' tahura result.parentRecords',data.parentRecords,this.IntHit)
    //         }
    //     }
    //     else if (error) {
    //         console.log(error);
    //     }
       
    // }

    docType = ['NACH Form'];
    subType = ['NACH Form'];
    docCategory = ['NACH Form']
    showToast(titleVal, variantVal, messageVal,mode) {
        const evt = new ShowToastEvent({
            title: titleVal,
            variant: variantVal,
            message: messageVal,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
    
    BlankFieldCheck(){
        const requiredFields = [
            { value: this.wrpAppReg.Account_Type__c, label: 'Account Type' },
            { value: this.wrpAppReg.amount_numbers__c, label: 'An amount of rupees in numbers' },
            { value: this.wrpAppReg.Bank_Account_Number__c, label: 'Bank Account Number' },
            { value: this.wrpAppReg.MICR_Code__c, label: 'MICR Code' },
            { value: this.wrpAppReg.Bank_City__c, label: 'Bank City' },
            { value: this.wrpAppReg.With_Bank__c, label: 'With Bank' },
            { value: this.wrpAppReg.Bank_Code__c, label: 'Bank Code' },
            { value: this.wrpAppReg.Bank_Branch__c, label: 'Bank Branch' },
            { value: this.wrpAppReg.IFSC_Code__c, label: 'IFSC Code' },            
            { value: this.wrpAppReg.Mobile_Number__c, label: 'Mobile Number' },
            { value: this.wrpAppReg.Email_Id__c, label: 'Email Id' }
        ];

        const missingFields = requiredFields
            .filter(field => !field.value)
            .map(field => field.label);

            if (missingFields.length > 0) {
                 let errorMessage = `Please enter value in ${missingFields.join(', ')}`;
                 this.showToast("Error", "error", errorMessage,"sticky");
               
            } else {
                //this.errorMessage = '';
                this.createDoc()
               
            }
    }
    handleGenerateDocuments(){
        //  this.IntMsgData();
       //refreshApex(this._wiredIntMsgData); 
       getSobjectDataNonCacheable({ params: this.IntMsgparams })
        .then((result) => {
            console.log(' result', result)
            if (result && result.parentRecords && result.parentRecords.length > 0) {
                
                   // this.IntHit=true;
                    console.log(' tahura result.parentRecords',result.parentRecords,this.IntHit)
                    // this.createDoc()
                    this.BlankFieldCheck();
                
            }
            else{
                this.showToast("Error", "error", "Please trigger ENACH before generating Physical NACH form","sticky");
               
            }
            
        })
        .catch((error) => {
            console.error('Error in line ##213', error)
        })

        // if(!this.IntHit){
        //     this.showToast("Error", "error", "Please trigger ENACH before generating Physical NACH form","sticky");
                
        // }
        // else{
        // this.showSpinner = true;
        // this.showDocList = false;
        // createDocumentDetail({  applicantId: this.wrpAppReg.ApplicantId, loanAppId: this.loanAppId, docCategory: 'NACH Form', docType: 'NACH Form', docSubType: 'NACH Form',availableInFile : false })
        //     .then((result) => {
        //         console.log('createDocumentDetailRecord result ', result);
        //         this.DocumentDetaiId = result;
        //         console.log('createDocumentDetailRecord DocumentDetaiId ', this.DocumentDetaiId);
                
        //         //here we need to use correct label based on if condition
        //         //this.label.sanctionLetter;
        //         //this.label.sanctionLetterBT
        //         //this.repaymentAccountId
        //         let pageUrl = this.label.PageURLNACHForm+ this.RepaymentIdPreview;
        //         const pdfData = {
        //             pageUrl : pageUrl,
        //             docDetailId : this.DocumentDetaiId,
        //             fileName : 'NACH Form.pdf'
        //         }
        //         this.generateDocument(pdfData);
        //         this.showToast("Success", "Success", this.customlabel.Repayment_NACHDocument,"sticky");
                
        //         //this.updateApplicantBanking();
        //         //this.fileUploadHandler();

        //     })
        //     .catch((err) => {
        //         this.showToast("Error", "error", this.customlabel.RepamentNach_DocDetail_ErrorMessage + err,"sticky");
        //         console.log(" createDocumentDetailRecord error===", err);
        //     });  
        // }
    }
    createDoc(){
        this.showSpinner = true;
        this.showDocList = false;
        createDocumentDetail({  applicantId: this.wrpAppReg.ApplicantId, loanAppId: this.loanAppId, docCategory: 'NACH Form', docType: 'NACH Form', docSubType: 'NACH Form',availableInFile : false })
            .then((result) => {
                console.log('createDocumentDetailRecord result ', result);
                this.DocumentDetaiId = result;
                console.log('createDocumentDetailRecord DocumentDetaiId ', this.DocumentDetaiId);
                
                //here we need to use correct label based on if condition
                //this.label.sanctionLetter;
                //this.label.sanctionLetterBT
                //this.repaymentAccountId
                let pageUrl = this.label.PageURLNACHForm+ this.RepaymentIdPreview;
                const pdfData = {
                    pageUrl : pageUrl,
                    docDetailId : this.DocumentDetaiId,
                    fileName : 'NACH Form.pdf'
                }
                this.generateDocument(pdfData);
                this.showToast("Success", "Success", this.customlabel.Repayment_NACHDocument,"sticky");
                
                //this.updateApplicantBanking();
                //this.fileUploadHandler();

            })
            .catch((err) => {
                this.showToast("Error", "error", this.customlabel.RepamentNach_DocDetail_ErrorMessage + err,"sticky");
                console.log(" createDocumentDetailRecord error===", err);
            });
    }
    generateDocument(pdfData){
        generateDocument({ wrapObj: pdfData })
            .then((result) => {
                this.showSpinner = false;
                if(result == 'success'){
                    this.refreshDocTable();
                }else{
                    console.log(result);
                }
                //this.updateApplicantBanking();
                //this.fileUploadHandler();

            })
            .catch((err) => {
                this.showToast("Error", "error", this.customlabel.RepamentNach_DocDetail_ErrorMessage + err,"sticky");
                console.log(" createDocumentDetailRecord error===", err);
            }); 
    }

    refreshDocTable(){
        this.showDocList = true;
    }

    // //******************FOR HANDLING THE HORIZONTAL SCROLL OF TABLE MANUALLY******************//
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