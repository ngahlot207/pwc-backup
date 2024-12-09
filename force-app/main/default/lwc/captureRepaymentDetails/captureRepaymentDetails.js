import { LightningElement ,track ,wire,api} from 'lwc';
import fetchSingleObject from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import { deleteRecord,updateRecord,createRecord } from 'lightning/uiRecordApi';
import cometdlwc from "@salesforce/resourceUrl/cometd";
import getSessionId from '@salesforce/apex/SessionUtil.getSessionId';
import { loadScript } from "lightning/platformResourceLoader";
import generateDocument from "@salesforce/apex/GeneratePDFandAttachToLoanApplication.generateDocument";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import RepamentNach_DocDetail_ErrorMessage from '@salesforce/label/c.RepamentNach_DocDetail_ErrorMessage';
import RepamentNach_Update_SuccessMessage from '@salesforce/label/c.RepamentNach_Update_SuccessMessage';
import CSF_Document from '@salesforce/label/c.CSF_Document';
import getAppDetails from '@salesforce/apex/LODDetailsController.getAppDetails';
// Custom labels
import RepaymentDetails_Mode_ErrorMessage from '@salesforce/label/c.RepaymentDetails_Mode_ErrorMessage';
import RepaymentDetails_Account_ErrorMessage from '@salesforce/label/c.RepaymentDetails_Account_ErrorMessage';
import RepaymentDetails_CreateIntegration_ErrorMessage from '@salesforce/label/c.RepaymentDetails_CreateIntegration_ErrorMessage';
import RepaymentDetails_Integration_ErrorMessage from '@salesforce/label/c.RepaymentDetails_Integration_ErrorMessage';
import RepaymentDetails_PennyDrop_SuccessMessage from '@salesforce/label/c.RepaymentDetails_PennyDrop_SuccessMessage';
import RepaymentDetails_PennyDrop_ErrorMessage from '@salesforce/label/c.RepaymentDetails_PennyDrop_ErrorMessage';
import RepaymentDetails_Enach_SuccessMessage from '@salesforce/label/c.RepaymentDetails_Enach_SuccessMessage';
import RepaymentDetails_Enach_ErrorMessage from '@salesforce/label/c.RepaymentDetails_Enach_ErrorMessage';
import RepaymentDetails_Integration_SuccessMessage from '@salesforce/label/c.RepaymentDetails_Integration_SuccessMessage';
import createDocumentDetail from "@salesforce/apex/DocumentDetailController.createDocumentDetail";
import PageURLCSFForm from '@salesforce/label/c.PageURLCSFForm';
export default class CaptureRepaymentDetails extends LightningElement {
        label ={
            RepaymentDetails_Mode_ErrorMessage,
            RepaymentDetails_Account_ErrorMessage,
            RepaymentDetails_CreateIntegration_ErrorMessage,
            RepaymentDetails_Integration_SuccessMessage,
            RepaymentDetails_Integration_ErrorMessage,
            RepaymentDetails_PennyDrop_SuccessMessage,
            RepaymentDetails_PennyDrop_ErrorMessage,
            RepaymentDetails_Enach_SuccessMessage,
            RepaymentDetails_Enach_ErrorMessage

        }

    @api isReadOnly; 
    @track disableMode;
    @api hasEditAccess;
    @api layoutSize; 
    @track FixedOption= false;   
    @track PDCSelected= false;
    @track NACHSelected = false;
    @track PDCChecked=false;
    @track NACHChecked=false;
    @track _wiredRPData
    @track RARecord=[]
    Selected=false;
    @track RPNames=[]
    result
    preSavedResult
    RId
    //value = ''; 
    value
    @track wrpAppReg = {    }
    modeChange=false;

    RVResult;
    @track RVRecord={ }
    chequeInterval
    @api channelName = "/event/IntRespEvent__e";
    @track sessionId;
    cometdlib;
    @track subscription;
    @track PEsubscription;
    @track RepaymentIdfromParentRecord
    
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
        let tempParams = this.params;
        tempParams.queryCriteria = ' where Loan_Application__c	= \'' + this._loanAppId + '\' AND Is_Active__c = true';
        this.params = {...tempParams};
       console.log('this.params',this.params)

       let tempRVParams = this.RepVerifyParam;
       tempRVParams.queryCriteria = ' where RepayAcc__c	= \'' + this.RId + '\' order by CreatedDate  desc limit 1';
       this.RepVerifyParam = {...tempRVParams};

       let tempnachParam = this.nachParam;
       tempnachParam.queryCriteria = ' where LoanAppl__c= \'' + this.loanAppId + '\'';
       this.nachParam = {...tempnachParam};

    }
     //loanAppId='a08C40000063xjHIAQ';
    get options() {
        return [
            { label: 'NACH', value: 'NACH' },
            { label: 'PDC', value: 'PDC' },
        ];
    }

    @track params ={
        ParentObjectName:'Repayment_Account__c',        
        parentObjFields:['Repayment_Mode__c','Id','Feasible__c','Loan_Application__c'],              
        queryCriteria: ' where Loan_Application__c	= \'' + this._loanAppId + '\' AND Is_Active__c = true'

    }

    @track nachParam ={
        ParentObjectName:'NACH__c',        
        parentObjFields:['Id','eNACH_Registration_Status__c','eNACH_Rejection_Reasons__c','LoanAppl__c','Mandate_Type__c'],              
        queryCriteria: ' where LoanAppl__c= \'' + this.loanAppId + '\''

    }

    @track RepVerifyParam ={
        ParentObjectName:'RepayAccVerify__c',        
        parentObjFields:['PennyDropStatus__c','Id','RepayAcc__c','CreatedDate'],              
        queryCriteria: ' where RepayAcc__c	= \'' + this.RId + '\' order by CreatedDate  desc limit 1'

    }

    @wire(fetchSingleObject,{params:'$params'})
    RPData (wiredRPData) {
      const { data, error } = wiredRPData;
      this._wiredRPData = wiredRPData;    
      console.log('this._wiredRPData',this._wiredRPData)    
       
        if (data) {
            let tempholder=JSON.parse(JSON.stringify(data))
           
            if(tempholder.parentRecords!= undefined && tempholder.parentRecords !=null){
            this.RPNames=JSON.parse(JSON.stringify(data.parentRecords));            
            
            // if(data.parentRecords!=undefined && data.parentRecords!=null){
            // this.RPNames=JSON.parse(JSON.stringify(data.parentRecords));
            if(this.RPNames!=undefined && this.RPNames!=null){

            this.RId=this.RPNames[0].Id;
            console.log('RId value',this.RId)
            // if(this.RPNames[0].Repayment_Mode__c){
            //     this.result=this.RPNames[0].Repayment_Mode__c;
            //     this.preSavedResult=this.result;
            //     this.value=this.result;
               
            //     console.log('RId value',this.RId)

            //     if(this.result=='PDC'){
            //         this.PDCSelected = true;
            //          this.NACHSelected = false;
            //          this.Selected=true;
            //         //  this.PDCChecked=true;
            //         //  this.NACHChecked=false;
            //     }
            //     if(this.result=='NACH'){
            //         this.PDCSelected = false;
            //         this.NACHSelected = true;
            //         this.Selected=true;
                    
            //         // this.PDCChecked=false;
            //         //  this.NACHChecked=true;
            //     }
            //     if(this.result!='NACH' && this.result!='PDC'){
            //         this.PDCSelected = false;
            //         this.NACHSelected = false;
            //         this.Selected=false;
            //     }
            // }
            //Feasible__c
            
                if(this.RPNames[0].Repayment_Mode__c){
                this.result=this.RPNames[0].Repayment_Mode__c;
                // this.preSavedResult=this.result;
                // this.value=this.result;
                }
               
                
                // if(this.RPNames[0].Feasible__c =='Yes'){
                    if(this.RPNames[0].Repayment_Mode__c =='NACH'){
                    this.PDCSelected = false;
                    this.NACHSelected = true;
                    this.Selected=true;
                    this.FixedOption=true;
                    this.value='NACH';
                    this.result='NACH';
                }   

                else if(this.RPNames[0].Repayment_Mode__c =='PDC'){ 
                
                    this.PDCSelected = true;
                     this.NACHSelected = false;
                     this.Selected=true;
                     this.FixedOption=true;
                     this.value='PDC';
                     this.result='PDC';
                    //  this.PDCChecked=true;
                    //  this.NACHChecked=false;
                }
                
                else{
                    this.PDCSelected = false;
                    this.NACHSelected = false;
                    this.Selected=false;
                    this.value='';
                    this.result='';
                }
            
            let tempRVParams = this.RepVerifyParam;
            tempRVParams.queryCriteria = ' where RepayAcc__c	= \'' + this.RId + '\' order by CreatedDate  desc limit 1';
            this.RepVerifyParam = {...tempRVParams};

        //     for(var i=0;i< this.RPNames.length;i++){  
        //         let RecordObj={}
        //         RecordObj.Id = this.RPNames[i].Id
        //        // RecordObj.Repayment_Mode__c=this.RPNames[i].Repayment_Mode__c 
        //         RecordObj.Loan_Application__c=this.RPNames[i].Loan_Application__c 
        //         this.RARecord.push(RecordObj)  
        //         console.log('this.RARecord',this.RARecord)      
        // }     
     }}}

        if(error) {
                console.log(error);
            }


    
    }

 //enach=suceess validation
    // @wire(fetchSingleObject,{params:'$nachParam'})
    // NACHData(wiredNACHData) {
    //     const { data, error } = wiredNACHData;
    //     this._wiredNACHData = wiredNACHData;
        
    //     if (data) {
    //         console.log('wiredNACHData',JSON.stringify(data))
    //         let tempholder=JSON.parse(JSON.stringify(data))
    //         console.log('temp holder',tempholder)
    //         console.log('temp holder parent',tempholder.parentRecords)
    //         if(tempholder.parentRecords!= undefined && tempholder.parentRecords !=null){
    //          this.nachRecord=JSON.parse(JSON.stringify(data.parentRecords));
             
    //       // this.nachRecord=JSON.parse(JSON.stringify(data));
    //         console.log('wiredNACHData parent',this.nachRecord)

    //         if(this.nachRecord != undefined &&  this.nachRecord!=null){
    //             for(var i=0;i<this.nachRecord.length;i++)
    //             {
    //                 this.wrpAppReg.eNACH_Registration_Status__c = this.nachRecord[i].eNACH_Registration_Status__c ? this.nachRecord[i].eNACH_Registration_Status__c : '';
    //                 this.wrpAppReg.eNACH_Rejection_Reasons__c = this.nachRecord[i].eNACH_Rejection_Reasons__c ? this.nachRecord[i].eNACH_Rejection_Reasons__c : '';
    //                 this.wrpAppReg.Mandate_Type__c = this.nachRecord[i].Mandate_Type__c ? this.nachRecord[i].Mandate_Type__c : '';
                    
    //                 if(this.wrpAppReg.Mandate_Type__c=='Enach' && this.wrpAppReg.eNACH_Registration_Status__c=='Success'){
    //                     this.modeChange=true;
    //                 }
    //             }
    //         }
               
    //         }
    //     } else if (error) {
    //             console.log(error);
    //         }
            
    //     }
    showToast(title, variant, message,mode) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
            mode: mode
        });
        this.dispatchEvent(evt);
    }


    handleRadioChange(event) {
        const selectedOption = event.detail.value;
        
        console.log('selectedOption ' + selectedOption);
        
        
        // if(this.preSavedResult){
        //    // this.showToast("Error!", "error", this.label.RepaymentDetails_Mode_ErrorMessage,"sticky");
        //    // this.value=this.preSavedResult;
        //    this.value=this.preSavedResult;
        // }
        // else{
        // if (!(this.preSavedResult) && selectedOption == 'PDC'){
            // if(this.modeChange && this.preSavedResult=='NACH'){
            // this.showToast("Error!", "error", this.label.RepaymentDetails_Mode_ErrorMessage,"sticky");
            // return;
           
            //  }
            if(this.FixedOption){
                this.showToast("Error!", "error", this.label.RepaymentDetails_Mode_ErrorMessage,"sticky");
                return;
               
                 }
             
                
            if (selectedOption == 'PDC'){
            this.PDCSelected = true;
            this.NACHSelected = false;
            this.Selected=event.detail.checked;
            console.log('selected option',selectedOption)
            this.result=selectedOption;
            this.value=selectedOption;
            }
        // if (!(this.preSavedResult) && selectedOption == 'NACH'){
            if (selectedOption == 'NACH'){
            this.PDCSelected = false;
            this.NACHSelected = true;
            this.Selected=true;
            console.log('selected option',selectedOption)
            this.result=selectedOption;
            this.value=selectedOption;
            }
        // if(!(this.preSavedResult) && selectedOption!='NACH' && selectedOption!='PDC'){
            if(selectedOption!='NACH' && selectedOption!='PDC'){
            this.PDCSelected = false;
            this.NACHSelected = false;
            this.Selected=false;
            this.result='';
            this.value='';
            }
        
        // }
        
    }
    handleSave(){

        let RecordObj={}
                RecordObj.Id = this.RId;
               RecordObj.Repayment_Mode__c=this.result; 
                RecordObj.Loan_Application__c=this.loanAppId;
                this.RARecord.push(RecordObj) 
                console.log('this.RARecord inside save',this.RARecord)

        upsertMultipleRecord({params:this.RARecord})
        .then(result => {                     
            // this.showToast("Success!", "Success", "Repayment Details updated");
                                          
            
        }).catch(error => {
            console.log(error);
        })
    }

    
    connectedCallback() {

        // console.log("isReadOnly:::::::: ", this.isReadOnly);
        console.log("hasEditAccess in regulatory:::::::: ", this.hasEditAccess);
        console.log("disableMode in regulatory::::::::: ", this.disableMode);
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        }
        this.scribeToMessageChannel();
        this.getLoanAppData();

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

    

    // penny drop
    @wire(fetchSingleObject,{params:'$RepVerifyParam'})
    RVData (wiredRVData) {
      const { data, error } = wiredRVData;
      this._wiredRVData = wiredRVData;        
       
        if (data) {

            // console.log('RV data',JSON.parse(JSON.stringify(data)))
            if(data.parentRecords!=undefined && data.parentRecords!=null){
            if(data.parentRecords[0] ){
            this.RVResult=JSON.parse(JSON.stringify(data.parentRecords[0])); 
            console.log('this.RVResult',this.RVResult) 
            }
            this.RVRecord.PennyDropStatus__c = this.RVResult.PennyDropStatus__c;
           
            this.RVRecord.RepayAcc__c = this.RVResult.RepayAcc__c ;
            this.RVRecord.Id = this.RVResult.Id ;

            console.log('this.RVRecord.PennyDropStatus__c',this.RVRecord.PennyDropStatus__c)


        }} else if (error) {
            console.log(error);
        }
    }


     //  ********************penny drop handle**************************************

     @wire(getSessionId)
     wiredSessionId({ error, data }) {
         if (data) {
             console.log('session Id=', data);
             this.sessionId = data;
             loadScript(this, cometdlwc);
         } else if (error) {
             console.log('Error In getSessionId = ', error);
             this.sessionId = undefined;
         }
     }
 
     handleClick(event) {
         console.log('target name ', event.target.name);
        // this.showSpinner = true;
         this.createRepayAccVer();
     }
 
     createRepayAccVer() {
         const obje = {
             sobjectType: "RepayAccVerify__c",
             LoanAppl__c: this.loanAppId,
             RepayAcc__c: this.RId ? this.RId : ''
         }
         let newArray = [];
         if (obje) {
             newArray.push(obje);
         }
         if (newArray) {
             upsertMultipleRecord({ params: newArray })
                 .then((result) => {
                     console.log('Result after creating Repayment Account Verification is ', JSON.stringify(result));
                     // this.createIntegrationMessageForPennyDrop(result[0].Id);
                     let fields = {};
                     //  fields.sobjectType = 'IntgMsg__c';
                     fields.Name = 'ICICI PennyDrop';
                     fields.Status__c = 'New';
                     fields.Svc__c = 'ICICI PennyDrop';
                     fields.BU__c = 'HL / STL';
                     fields.IsActive__c = true;
                     fields.RefObj__c = 'RepayAccVerify__c';
                     fields.RefId__c = result[0].Id ? result[0].Id : '';
                     this.createIntMsg(fields, 'Pennydrop');
                 })
                 .catch((error) => {
                     
                     console.log('Error In creating Record', error);
                     this.showToast('Error', 'error', this.label.RepaymentDetails_Account_ErrorMessage,"sticky");
                 });
         }
     }
 
         
     showToast(titleVal, variantVal, messageVal,mode) {
         const evt = new ShowToastEvent({
             title: titleVal,
             variant: variantVal,
             message: messageVal,
             mode: mode
         });
         this.dispatchEvent(evt);
     }
 
     createIntMsg(fieldsInt, name) {
         const recordInput = {
             apiName: 'IntgMsg__c',
             fields: fieldsInt
         };
         createRecord(recordInput).then((result) => {
             console.log('Paytm Integration Record Created ##405', result.id, result);
            if (name === 'Enach') {
                 this.eNachIntMsgId = result.id;
                 // this.callSubscribePlatformEve();
                 this.startPolling('Enach');
             }
             else if (name === 'Pennydrop') {
                 this.pennyDropIntMsgId = result.id;
                 this.callSubscribePlatformEve();
             }
         }).catch((error) => {
             this.showSpinner = false
             console.log('Error ##789', error);
             this.showToast('Errpr', 'error', this.label.RepaymentDetails_CreateIntegration_ErrorMessage,"sticky");
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
         if (name === 'Enach') {
             paramsLoanApp = {
                 ParentObjectName: 'IntgMsg__c',
                 parentObjFields: ['Id', 'Status__c', 'Name'],
                 queryCriteria: ' where Id = \'' + this.eNachIntMsgId + '\''
             }
         }
         getSobjectData({ params: paramsLoanApp })
             .then((result) => {
                 console.log('Int Msg data is', JSON.stringify(result));
                 
                 if (result.parentRecords[0].Status__c === 'Responded' && result.parentRecords[0].Name === 'mandate_create_form') {
                     //this.disableLmsUpdate = true;
                     this.showSpinner = false;
                     this.getNachData();
                     this.showToast('Success', 'success', this.label.RepaymentDetails_Integration_SuccessMessage,"sticky");
                     clearInterval(this.chequeInterval);
                     console.log('Cleared ##473');
                 }
                 if (result.parentRecords[0].Status__c === 'Exception' && result.parentRecords[0].Name === 'mandate_create_form') {
                     // this.disableLmsUpdate = false;
                     this.showSpinner = false;
                     this.showToast('Error', 'error', this.label.RepaymentDetails_Integration_ErrorMessage,"sticky");
                     clearInterval(this.chequeInterval);
                     console.log('Cleared ##473');
                 }
             })
             .catch((error) => {
                 this.showSpinner = false;
                 console.log('Error In getting Int Msg Record ', error);
                 //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
             });
     }
 
     callSubscribePlatformEve() {
         //Commnet platform event subscription temproroly
         this.handleSubscribe();
     }
     handleSubscribe() {
         const self = this;
         this.cometdlib = new window.org.cometd.CometD();
         console.log('cometdlib  value ', JSON.stringify(this.cometdlib));
 
         //Calling configure method of cometD class, to setup authentication which will be used in handshaking
         this.cometdlib.configure({
             url: window.location.protocol + '//' + window.location.hostname + '/cometd/50.0/',
             requestHeaders: { Authorization: 'OAuth ' + this.sessionId },
             appendMessageTypeToURL: false,
             logLevel: 'debug'
         });
 
         this.cometdlib.websocketEnabled = false;
         this.cometdlib.handshake(function (status) {
             let tot = self.timeout
             console.log('noIntResponec ', self.noIntResponec);
             self.noIntResponec = true;
             self.startTimerForTimeout(tot);
             if (status.successful) {
                 console.log('Successfully connected to server');
                 self.PEsubscription = self.cometdlib.subscribe(self.channelName, (message) => {
                     console.log('subscribed to message!', JSON.stringify(message));
                     console.log(message.data.payload);
                     self.handlePlatformEventResponce(message.data.payload);
 
                 }
                     ,
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
             if (payload.SvcName__c === 'Pennydrop') {
                 if (payload.RecId__c === this.pennyDropIntMsgId && payload.Success__c) {
                     this.disableIntiatePennyDrop = true;
                     this.getNachData();
                     this.showSpinner = false;
                     this.showToast('Success', 'success', this.label.RepaymentDetails_PennyDrop_SuccessMessage,"sticky");
                 } else {
                     this.showSpinner = false;
                     this.showToast('Error', 'error', this.label.RepaymentDetails_PennyDrop_ErrorMessage,"sticky");
                 }
             } else if (payload.SvcName__c === 'Enach status') {
                 if (payload.RecId__c === this.eNachIntMsgId && payload.Success__c) {
                     //this.disableIntiatePennyDrop = true;
                     this.getNachData();
                     this.showSpinner = false;
                     this.showToast('Success', 'success', this.label.RepaymentDetails_Enach_SuccessMessage,"sticky");
                 } else {
                     this.showSpinner = false;
                     this.showToast('Error', 'error', this.label.RepaymentDetails_Enach_ErrorMessage,"sticky");
                 }
             }
         } else {
             this.showSpinner = false;
         }
 
     }
 
     startTimerForTimeout(timeout) {
         console.log('startTimerForTimeout ', timeout);
         setTimeout(() => {
             this.showSpinner = true;
         }, timeout);
     }
 
 //CSF Document

 //records available

 @track hasSPDCRecords=false;
    spdcrecords(event){
        console.log('event inside super parent  spdc records',event.detail.hasSPDCRecords)
        this.hasSPDCRecords=event.detail.hasSPDCRecords;
        
    }
    @track hasPDCRecords=false;
    pdcrecords(event){
        console.log('event inside super parent  pdc records',event.detail.hasPDCRecords)
        this.hasPDCRecords=event.detail.hasPDCRecords;
        
    }
    
    get disableDoc(){
        if(this.result=='NACH'){
            console.log('return nach mode',this.disableMode || !this.hasSPDCRecords )
            return this.disableMode || !this.hasSPDCRecords ;
        }
        if(this.result=='PDC'){
            console.log('return pdc mode',this.disableMode || !(this.hasPDCRecords && this.hasSPDCRecords) )
            return this.disableMode || !(this.hasPDCRecords && this.hasSPDCRecords) ;
        }
        
      }
 showDocList=false;
 docType = ['CSF'];
    subType = ['CSF'];
    docCategory = ['CSF']

    customlabel ={
        RepamentNach_Update_SuccessMessage,
        RepamentNach_DocDetail_ErrorMessage,
        CSF_Document       

    }

 label = {
    PageURLCSFForm
};

 //applicant id
 @track getApplicantID; 
 @wire(getAppDetails,{ recordId: '$loanAppId'})
 wiredgetAppDetails({ data, error }) {
     if (data) {
         console.log('recordIdForDecision-->'+this.recordId);
         this.getApplicantID = data.Id;
       // this.emailAddress=data.EmailId__c;
         
        
     } else if (error) {
         console.error('Error loading Decision Summary: ', error);
     }
 }
handleGenerateDocuments(){
    this.showSpinner = true;
    this.showDocList = false;
    createDocumentDetail({  applicantId: this.getApplicantID, loanAppId: this.loanAppId, docCategory: 'CSF', docType: 'CSF', docSubType: 'CSF',availableInFile : false })
        .then((result) => {
            console.log('createDocumentDetailRecord result ', result);
            this.DocumentDetaiId = result;
            console.log('createDocumentDetailRecord DocumentDetaiId ', this.DocumentDetaiId);
            
            //here we need to use correct label based on if condition
            //this.label.sanctionLetter;
            //this.label.sanctionLetterBT
            //this.repaymentAccountId
            console.log('loanAppId-->'+this.loanAppId);
            let pageUrl = this.label.PageURLCSFForm+ this.loanAppId;
            const pdfData = {
                pageUrl : pageUrl,
                docDetailId : this.DocumentDetaiId,
                fileName : 'CSF.pdf'
            }
            this.generateDocument(pdfData);
            this.showToast("Success", "Success", this.customlabel.CSF_Document,"sticky");
            
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
                // this.refreshDocTable();
                this.forLatestDocDetailRec();
            }else{
                console.log(result);
            }
            

        })
        .catch((err) => {
            this.showToast("Error", "error", this.customlabel.RepamentNach_DocDetail_ErrorMessage + err,"sticky");
            console.log(" createDocumentDetailRecord error===", err);
        }); 
}

forLatestDocDetailRec() {
    var listOfAllParent = [];
    var paramForIsLatest = {
        ParentObjectName: 'DocDtl__c',
        parentObjFields: ['Id', 'Appl__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c'],
        queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this.loanAppId + '\' AND DocCatgry__c = \'CSF\' AND DocTyp__c = \'CSF\' AND DocSubTyp__c = \'CSF\''   //AND Appl__c = \'' + this.loanApplicationRecord.Applicant__c + '\'
    }
    getSobjectData({ params: paramForIsLatest })
        .then((result) => {
           // console.log('islatestdata 13899999', this.DocumentDetaiId);
            if (result.parentRecords) {
                listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
            }
            let oldRecords = []
            oldRecords = listOfAllParent.filter(record => record.Id !== this.DocumentDetaiId);
            //console.log('oldRecords>>>>>'+JSON.stringify(oldRecords))
            let isLatestFalseRecs = []
            isLatestFalseRecs = oldRecords.map(record => {
                return { ...record, IsLatest__c: false };
                return record;
            });
            let obj = {
                Id: this.DocumentDetaiId,
                NDCDataEntry__c: 'Completed'
            }
            isLatestFalseRecs.push(obj);
            console.log('isLatestFalseRecs>>>>>' + JSON.stringify(isLatestFalseRecs))
            upsertMultipleRecord({ params: isLatestFalseRecs })
                .then(result => {
                    console.log('resultresultresultresultresult' + JSON.stringify(result));
                    this.refreshDocTable();
                    //this.showDocList = true;               

                }).catch(error => {
                    console.log('778' + error)
                })

        })
        .catch((error) => {
            console.log('Error In getting 13899999 ', error);
            //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
        });
}

refreshDocTable(){
    this.showDocList = true;
}

 //get table on refresh
 getLoanAppData() {
    var listOfAllParent = [];
    var paramForIsLatest = {
        ParentObjectName: 'DocDtl__c',
        parentObjFields: ['Id', 'Appl__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c'],
        queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this.loanAppId + '\' AND DocCatgry__c = \'CSF\' AND DocTyp__c = \'CSF\' AND DocSubTyp__c = \'CSF\''   //AND Appl__c = \'' + this.loanApplicationRecord.Applicant__c + '\'
    }
    getSobjectData({ params: paramForIsLatest })
        .then((result) => {
            console.log('islatestdata 13899999 connected', JSON.stringify(result.parentRecords));
            if (result.parentRecords) {
                //listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
                // this.forLatestDocDetailRec()
                //this.showDocList=true;
                let isLatestFalseRecs = JSON.parse(JSON.stringify(result.parentRecords))
                upsertMultipleRecord({ params: isLatestFalseRecs })
                .then(result => {
                    console.log('resultresultresultresultresult connected' + JSON.stringify(result));
                    this.refreshDocTable();
                    //this.showDocList = true;               

                }).catch(error => {
                    console.log('778' + error)
                })
            }
            
        })
        .catch((error) => {
            console.log('Error In getting 13899999 ', error);
            //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
        });
}
}