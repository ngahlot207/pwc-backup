import { LightningElement, wire, api, track } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord, deleteRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
//  import RegRecord from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import updateRegPer from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
//import createRegRecord from '@salesforce/apex/RegulatoryHandler.createRegulatoryRecord';
import ApplRegltry from '@salesforce/schema/ApplRegltry__c';
 //LAK-7333
import getSobjectData from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData";
import CHARDISCRMTN from '@salesforce/schema/ApplRegltry__c.CharDiscrmtn__c';
import APPL from '@salesforce/schema/ApplRegltry__c.Appl__c';
import NAME from '@salesforce/schema/ApplRegltry__c.Name';
import ISBOROWORRELFFDIR from '@salesforce/schema/ApplRegltry__c.IsBorowrOrRelFFDir__c';
import DEALNGINDSTRY from '@salesforce/schema/ApplRegltry__c.DealngIndstry__c';
//import DESGNTN from '@salesforce/schema/ApplRegltry__c.Desgntn__c';
import FUNDINESGPOL from '@salesforce/schema/ApplRegltry__c.FundInESGPol__c';
import FFDIRRELINTRSTASPART from '@salesforce/schema/ApplRegltry__c.FFDirRelIntrstAsPart__c';
import FFDIRRELINTRSTASSH from '@salesforce/schema/ApplRegltry__c.FFDirRelIntrstAsSH__c';
import LOANAPPLN from '@salesforce/schema/ApplRegltry__c.LoanAppln__c';
import formFactorPropertyName from "@salesforce/client/formFactor";
import DESGNTN from '@salesforce/schema/RegltryPrsonl__c.Desgntn__c';
import DIRNAME from '@salesforce/schema/RegltryPrsonl__c.DirName__c';
import RELTNSHP from '@salesforce/schema/RegltryPrsonl__c.Reltnshp__c';
import APPLICANTREG from '@salesforce/schema/RegltryPrsonl__c.Applicant_Regulatory__c';
import ApplicantCapture_Format_ErrorMessage from '@salesforce/label/c.ApplicantCapture_Format_ErrorMessage';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import UserId from '@salesforce/user/Id';  //LAK-7333
const DELAY = 500;
const fields = [
    CHARDISCRMTN,
    APPL,
    NAME,
    ISBOROWORRELFFDIR,
    DEALNGINDSTRY,
    DESGNTN,
    FUNDINESGPOL,
    FFDIRRELINTRSTASPART,
    FFDIRRELINTRSTASSH,
    LOANAPPLN,
    DIRNAME,
    RELTNSHP
]
const currUserId = UserId;  //LAK-7333
// Custom labels
import Regulatary_ReqFields_ErrorMessage from '@salesforce/label/c.Regulatary_ReqFields_ErrorMessage';
import Regulatary_Update_SuccessMessage from '@salesforce/label/c.Regulatary_Update_SuccessMessage';
import Regulatary_Del_SuccessMessage from '@salesforce/label/c.Regulatary_Del_SuccessMessage';

export default class RegulatoryDetailsCapture extends LightningElement {
    customLabel = {
        Regulatary_ReqFields_ErrorMessage,
        Regulatary_Update_SuccessMessage,
        Regulatary_Del_SuccessMessage

    }
    @track delayTimeout;
    preventClosingOfSerachPanel=false;

    @track DealingIndustryValue;
    searchResults
    selectedSearchResult

    @track directorDetails = [];
    @track _loanAppId;
    @track _wiredRegulatoryDetails;
    @track _wiredLoanData
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        console.log('Loan App Id ! ' + value);
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        this.handleRecordIdChange(value);
    }



    @api isReadOnly;
    @track disableMode;
    @api hasEditAccess;
    // @api get hasEditAccess() {
    //    // console.log("hasEditAccess in regulatory in get :::::::: ", this.hasEditAccess);
    //     return this.disableMode;
    // }
    // set hasEditAccess(value) {

    //     if(value){
    //         console.log("disableMode in regulatory in set:::::::: ", value);
    //         this.disableMode = false;
    //     }else{
    //         this.disableMode = true;
    //     }
    //     this.setAttribute("hasEditAccess", value);               
    // }


    @api layoutSize;
    @track activeSection = ["A", "B"];
    @track isYes = false
    @track AllChildRecords = []
    @track requiredFlag = false;
    disabledFlag = false
    Eligibility
    value
    @track isSpinner = false
    IsBorowrOrRelFFDirValue
    IsBorowrOrRelFFDirOptions = []
    FFDirRelIntrstAsSHOptions=[]
    FFDirRelIntrstAsPartOptions=[]
    customerProfileOptions = []
    discriminationOptions = []
    option1 = false
    option2 = false
    option3 = false
    isAddDirectorRecord = false
    addRows = false;
    parentRecord = []
    ChildReords = []
     LoanParentRecord = []
     LoanChildRecord = []
    isDirty = false
    isDelete = false
    iseligibility = true;
    selectedIndustry = ''
    selectedESG = ''
    childComponent = false;
    isBorowrOrRelFFDir = false;


    label = {
        ApplicantCapture_Format_ErrorMessage,
    }
    messageMismatchError = this.label.ApplicantCapture_Format_ErrorMessage

    @track wrpAppReg = {


    }

    @track wrpRegP = {

    }

     //LAK-7333
    @track teamHierParam = {
        ParentObjectName: 'TeamHierarchy__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id','EmpRole__c','Employee__c'],
        childObjFields: [],
        queryCriteria: 'where Employee__c= \'' + currUserId + '\''
    }


    @track params = {
        ParentObjectName: 'ApplRegltry__c',
        ChildObjectRelName: 'Regulatory_Personnel__r',
        parentObjFields: ['Id', 'IsBorowrOrRelFFDir__c', 'FFDirRelIntrstAsPart__c', 'FFDirRelIntrstAsSH__c', 'DealngIndstry__c', 'CharDiscrmtn__c', 'FundInESGPol__c','IsUwVerified__c'],  //LAK-7333
        childObjFields: ['Desgntn__c', 'DirName__c', 'Reltnshp__c', 'Id'],
        queryCriteria: ' where LoanAppln__c= \'' + this.loanAppId + '\''

    }


    @track loanAppParam = {
        ParentObjectName: 'LoanAppl__c',
        ChildObjectRelName: 'Applicants__r',
        parentObjFields: ['Id', 'Stage__c'],
        childObjFields: ['Constitution__c', 'Id'],
        queryCriteria: ' where id= \'' + this.loanAppId + '\''

    }
 //LAK-7333
    @track userRole;
    @track creditRoles = ['UW','ACM','RCM','ZCM','NCM','CH' ];

    @wire(getSobjectData,{params : '$teamHierParam'})
    teamHierHandler(result){
        if(result.data){
            if(result.data.parentRecords !== undefined ){
                this.userRole = result.data.parentRecords[0].EmpRole__c;
            }
                      
        }
        if(result.error){
            console.error('ERROR TEAM H DETAILS:::::::#190',result.error)
        }
    }
  
    get disableUwVeri(){
        if(this.creditRoles.includes(this.userRole)){
            return false;
        }
        else{
            return true;
        }
    }

    @track wrpRegPer = [
        {
            DirName__c: '',
            Desgntn__c: '',
            Reltnshp__c: ''
        }
    ]


    @wire(getData, { params: '$loanAppParam' })
    loanData(result) {
        // console.log(' Loan id in parent comp', this.loanAppId);
        // console.log(' Loan id in _parent comp', this._loanAppId);
        // const { data, error } = wiredLoanData;
        // this._wiredLoanData = wiredLoanData;
        this._wiredLoanData = result;
        if (result.data) {
            //console.log("result of IniLoan" + JSON.stringify(data.parentRecord))
            // this.LoanParentRecord = JSON.parse(JSON.stringify(data.parentRecord));
            // this.LoanChildRecord = JSON.parse(JSON.stringify(data.ChildReords));
            if(result.data.parentRecord!=undefined){
            this.LoanParentRecord = result.data.parentRecord;
            console.log("result of IniLoan" + JSON.stringify(result.data.parentRecord))
            // if(result.data.ChildReords!=undefined){
            // this.LoanChildRecord = result.data.ChildReords;
            if (this.LoanParentRecord.Stage__c == 'QDE') {
                this.requiredFlag = false;
                this.isBorowrOrRelFFDir = false;
            }
            else {
                this.requiredFlag = true;
                this.childComponent = true;
                this.isBorowrOrRelFFDir = true;
            }
            this.option1 = false;
            this.option2 = false;
            this.option3 = false;
            if(result.data.ChildReords!=undefined){
                this.LoanChildRecord = result.data.ChildReords;
            for (var i = 0; i < this.LoanChildRecord.length; i++) {

                if (this.LoanChildRecord[i].Constitution__c == 'INDIVIDUAL') {
                    this.option1 = true;
                    console.log('this.option1',this.option1)
                }
                if (this.LoanChildRecord[i].Constitution__c != 'INDIVIDUAL' && (this.LoanChildRecord[i].Constitution__c != 'PRIVATE LIMITED COMPANY' && this.LoanChildRecord[i].Constitution__c != 'PUBLIC LIMITED COMPANY')) {
                    this.option2 = true;
                    console.log('this.option2',this.option2)
                }
                if (this.LoanChildRecord[i].Constitution__c != 'INDIVIDUAL' && (this.LoanChildRecord[i].Constitution__c == 'PRIVATE LIMITED COMPANY' || this.LoanChildRecord[i].Constitution__c == 'PUBLIC LIMITED COMPANY')) {
                    this.option3 = true;
                    console.log('this.option3',this.option3)
                }


            }
        } }}if (result.error) {
            console.log("error print", result.error);
          }
    }
    @track parentId
    @wire(getData, { params: '$params' })
    loadRegulatroyDetails(wiredRegulatoryDetails) {
        const { data, error } = wiredRegulatoryDetails;
        this._wiredRegulatoryDetails = wiredRegulatoryDetails;
        this.isSpinner=false;
        if (data) {
            if (data.parentRecord != undefined) {
                this.parentRecord = JSON.parse(JSON.stringify(data.parentRecord));
                this.wrpAppReg.IsBorowrOrRelFFDir__c = data.parentRecord.IsBorowrOrRelFFDir__c ? data.parentRecord.IsBorowrOrRelFFDir__c : '';
                this.wrpAppReg.FFDirRelIntrstAsPart__c = data.parentRecord.FFDirRelIntrstAsPart__c ? data.parentRecord.FFDirRelIntrstAsPart__c : '';
                this.wrpAppReg.FFDirRelIntrstAsSH__c = data.parentRecord.FFDirRelIntrstAsSH__c ? data.parentRecord.FFDirRelIntrstAsSH__c : '';
                this.wrpAppReg.DealngIndstry__c = data.parentRecord.DealngIndstry__c ? data.parentRecord.DealngIndstry__c : '';
                this.wrpAppReg.IsUwVerified__c = data.parentRecord.IsUwVerified__c ;  //LAK-7333
                
                this.wrpAppReg.CharDiscrmtn__c = data.parentRecord.CharDiscrmtn__c ? data.parentRecord.CharDiscrmtn__c : '';
                this.wrpAppReg.FundInESGPol__c = data.parentRecord.FundInESGPol__c ? data.parentRecord.FundInESGPol__c : '';
                this.wrpAppReg.Id = data.parentRecord.Id ? data.parentRecord.Id : '';
                this.parentId = this.wrpAppReg.Id;
                
                console.log('parent Id', this.parentId);
                console.log(this.wrpAppReg);

                if (data.ChildReords && data.ChildReords != undefined) {
                    this.ChildReords = JSON.parse(JSON.stringify(data.ChildReords));
                    this.AllChildRecords = [...this.ChildReords];

                }

                if (this.wrpAppReg.IsBorowrOrRelFFDir__c == 'Yes' || this.wrpAppReg.FFDirRelIntrstAsSH__c == 'Yes' || this.wrpAppReg.FFDirRelIntrstAsPart__c == 'Yes') {
                    if (!(data.ChildReords)) {

                        let regulatoryDetails = {

                            "sobjectType": 'RegltryPrsonl__c',
                            "DirName__c": '',
                            "Desgntn__c": '',
                            "Reltnshp__c": '',
                            "Applicant_Regulatory__c": '',
                            "isDirty": false,
                            "isDelete": false
                        }
                        // this.isDelete=false;                   
                        let emptyArr = [];
                        emptyArr.push(regulatoryDetails);
                        this.AllChildRecords = [...emptyArr];

                    }


                }
                console.log('AllChildRecords ' + JSON.stringify(this.AllChildRecords));
                if(this.wrpAppReg.DealngIndstry__c && this.wrpAppReg.DealngIndstry__c!=undefined){

                    this.DealingIndustryValue=this.wrpAppReg.DealngIndstry__c;
                    this.selectedIndustry=this.wrpAppReg.DealngIndstry__c;
                    this.selectedESG=this.wrpAppReg.CharDiscrmtn__c;
                    
                console.log('this.DealingIndustryValue reretrieve wire',this.DealingIndustryValue)
                }
                this.yesVisibility();
               this.isSpinner=false;
            }

        } else if (error) {
            this.isSpinner=false;
        }
    }


    handleRecordIdChange() {
        let tempParams = this.params;
        tempParams.queryCriteria = ' where LoanAppln__c = \'' + this.loanAppId + '\'';
        this.params = { ...tempParams };


        let tempParamsLoan = this.loanAppParam;
        tempParamsLoan.queryCriteria = ' where id = \'' + this.loanAppId + '\'';
        this.loanAppParam = { ...tempParamsLoan };
        //LAK-7333
        let tempTeamH = this.teamHierParam;
        tempTeamH.queryCriteria = ' where Employee__c = \'' + currUserId + '\'';
        this.teamHierParam = { ...tempTeamH };

    }

    desktopBoolean = false;
    phoneBolean = false;
    @track formFactor = formFactorPropertyName;
    connectedCallback() {

        // console.log("isReadOnly:::::::: ", this.isReadOnly);
        console.log("hasEditAccess in regulatory:::::::: ", this.hasEditAccess);
        console.log("disableMode in regulatory::::::::: ", this.disableMode);
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        }
        this.scribeToMessageChannel();
        refreshApex(this._wiredLoanData);
        if (this.formFactor == "Large") {
            this.desktopBoolean = true;
            this.phoneBolean = false;
            console.log("desktopBoolean ", this.desktopBoolean);
        } else if (this.formFactor == "Small") {
            this.desktopBoolean = false;
            this.phoneBolean = true;
            console.log("phoneBolean ", this.phoneBolean);
        } else {

            this.desktopBoolean = false;
            this.phoneBolean = true;
            console.log("phoneBolean ", this.phoneBolean);
        }

    }
    renderedCallback(){
        refreshApex(this._wiredLoanData); 
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
        this.isSpinner=true;
        console.log('values to save through Lms ', JSON.stringify(values));
        this.handleSaveV(values.validateBeforeSave);

    }
    
    //handlesave

    handleSaveV(validate) {
        if (validate) {
            this.isSpinner=true;
            let isInputCorrect = this.validateForm();
            console.log("custom lookup validity if false>>>", isInputCorrect);
            if (isInputCorrect === true) {
                
                this.handleSave();


            } else {
                this.isSpinner=false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: this.customLabel.Regulatary_ReqFields_ErrorMessage,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );

            }
        } else {
            this.isSpinner=true;
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
        this.template.querySelectorAll('.DealngIndstryCls').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed');
            } else {
                isValid = false;
                element.setCustomValidity('Please fill the valid value')
            }


        });
        return isValid;
    }
 //LAK-7333
    @track isUwChecked;
    @track isNotUwUser = false;
    handleUwCheckbox(event){
        let isInputCorrect = this.validateForm();
        if(isInputCorrect){
            this.wrpAppReg.IsUwVerified__c = event.detail.checked;
        }
        else{
            event.target.checked = false;
            event.preventDefault();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.customLabel.Regulatary_ReqFields_ErrorMessage,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        }
   }

    //update visibility

    yesVisibility() {
        if (this.wrpAppReg.IsBorowrOrRelFFDir__c == 'Yes' || this.wrpAppReg.FFDirRelIntrstAsSH__c == 'Yes' || this.wrpAppReg.FFDirRelIntrstAsPart__c == 'Yes') {

            this.isYes = true;

        } if (this.wrpAppReg.IsBorowrOrRelFFDir__c == 'No' & this.wrpAppReg.FFDirRelIntrstAsSH__c == 'No' & this.wrpAppReg.FFDirRelIntrstAsPart__c == 'No') {

            this.isYes = false;
        }
        // if(this.wrpAppReg.FFDirRelIntrstAsSH__c == 'Yes'){

        //     this.isYes= true;

        // }if(this.wrpAppReg.FFDirRelIntrstAsSH__c == 'No'){
        //         this.isYes= false;
        // }
        // if(this.wrpAppReg.FFDirRelIntrstAsPart__c == 'Yes'){
        //     this.isYes= true;

        // }if(this.wrpAppReg.FFDirRelIntrstAsPart__c == 'No'){

        //     this.isYes= false;
        // }
        if (this.wrpAppReg.CharDiscrmtn__c == 'Yes') {
            this.iseligibility = true;

        } if (this.wrpAppReg.CharDiscrmtn__c == 'No') {

            this.iseligibility = true;
        }
    }


    handleInputChange(event) {

        const inputBox = event.currentTarget;

        //If there was a custom error before, reset it
        inputBox.setCustomValidity('');
        inputBox.reportValidity();

        let regulatoryDetails = this.AllChildRecords[event.target.dataset.index]
        regulatoryDetails[event.target.dataset.name] = event.target.value.toUpperCase();
        regulatoryDetails.isDirty = true;
        this.AllChildRecords[event.target.dataset.index] = regulatoryDetails;

    }

    //adding Director Button Handler

    handleAddDirector(event) {
        let regulatoryDetails = {

            "sobjectType": 'RegltryPrsonl__c',
            "DirName__c": '',
            "Desgntn__c": '',
            "Reltnshp__c": '',
            "Applicant_Regulatory__c": '',
            "isDirty": false,
            "isDelete": true
        }
        //  this.isDelete=true;              
        let tempArr = [...this.AllChildRecords];
        tempArr.push(regulatoryDetails);
        this.AllChildRecords = [...tempArr];

        // this.AllChildRecords[0].isDelete=false;

        console.log('inside add director button' + JSON.stringify(this.AllChildRecords))

    }

    //end of add director button

    @wire(getObjectInfo, { objectApiName: ApplRegltry })
    objInfo

    generatePicklist(data) {
        return data.values.map(item => ({ label: item.label, value: item.value }))
    }

    @wire(getPicklistValues, { recordTypeId: '$objInfo.data.defaultRecordTypeId', fieldApiName: ISBOROWORRELFFDIR })
    IsBorowrOrRelFFDirHandler({ data, error }) {
        if (data) {
            console.log(data);
            this.IsBorowrOrRelFFDirOptions = [...this.generatePicklist(data)]

        }
        if (error) {
            console.log(error)
        }
    }



    // Adding for A
    @wire(getPicklistValues, { recordTypeId: '$objInfo.data.defaultRecordTypeId', fieldApiName: FFDIRRELINTRSTASSH })
    FFDirRelIntrstAsSHHandler({ data, error }) {
        if (data) {
            console.log(data);
            this.FFDirRelIntrstAsSHOptions = [...this.generatePicklist(data)]
        }
        if (error) {
            console.log(error)
        }
    }



    // adding 3rd to A

    @wire(getPicklistValues, { recordTypeId: '$objInfo.data.defaultRecordTypeId', fieldApiName: FFDIRRELINTRSTASPART })
    FFDirRelIntrstAsPartHandler({ data, error }) {
        if (data) {
            console.log(data);
            this.FFDirRelIntrstAsPartOptions = [...this.generatePicklist(data)]
        }
        if (error) {
            console.log(error)
        }
    }

get isDeclartionInputReq() {
        if (this.wrpAppReg) {
            if ( (this.wrpAppReg.IsBorowrOrRelFFDir__c  &&  this.wrpAppReg.IsBorowrOrRelFFDir__c === 'Yes') || (this.wrpAppReg.FFDirRelIntrstAsSH__c  &&  this.wrpAppReg.FFDirRelIntrstAsSH__c === 'Yes') || (this.wrpAppReg.FFDirRelIntrstAsPart__c && this.wrpAppReg.FFDirRelIntrstAsPart__c === 'Yes')) {
                return true;
            }
            else{
                return false;
            }

        }

    }

    //common handler:

    HandleValueChange(event) {
        // this.wrpAppReg.id=this.parentId;
        const inputBox = event.currentTarget;

        //If there was a custom error before, reset it
        inputBox.setCustomValidity('');
        inputBox.reportValidity();

        this.wrpAppReg[event.target.dataset.name] = event.target.value;

        if(event.target.dataset.name === 'IsBorowrOrRelFFDir__c'){
            this.isBorowrOrRelFFDir = true;
        }
        else{
            this.isBorowrOrRelFFDir = false;
        }

        if (event.target.dataset.name === 'FFDirRelIntrstAsPart__c' ||
            event.target.dataset.name === 'FFDirRelIntrstAsSH__c' ||
            event.target.dataset.name === 'IsBorowrOrRelFFDir__c') {
            if (event.target.value === 'Yes') {
                this.isYes = true;
                console.log(this.AllChildRecords);
                if (this.AllChildRecords.length <= 0) {
                    console.log('Inside All Child Records');
                    const directorDetails = {

                        "sobjectType": 'RegltryPrsonl__c',
                        "DirName__c": '',
                        "Desgntn__c": '',
                        "Reltnshp__c": '',
                        "Applicant_Regulatory__c": '',
                        "isDirty": false,
                        "isDelete": false
                    }
                    let tempArr = [...this.AllChildRecords];
                    tempArr.push(directorDetails);
                    this.AllChildRecords = [...tempArr];
                }
            }
            // if(event.target.value === 'No'){    
            //     this.isYes= false;
            // }
            // if(this.wrpAppReg.IsBorowrOrRelFFDir__c == 'No' & this.wrpAppReg.FFDirRelIntrstAsSH__c == 'No' & this.wrpAppReg.FFDirRelIntrstAsPart__c == 'No'){
            else {
                this.isYes = false;
                if (this.wrpAppReg.IsBorowrOrRelFFDir__c == 'Yes' || this.wrpAppReg.FFDirRelIntrstAsSH__c == 'Yes' || this.wrpAppReg.FFDirRelIntrstAsPart__c == 'Yes') {
                    this.isYes = true;
                }


            }

        }

        // if (event.target.dataset.name === 'DealngIndstry__c') {
        //     this.selectedIndustry = event.target.value;
        //     // if (event.target.value==='None of the Above'){
        //     //             this.wrpAppReg.FundInESGPol__c= 'Fundable';                            
        //     //         }
        //     if (event.target.value != 'None of the Above') {
        //         this.wrpAppReg.FundInESGPol__c = 'Non Fundable';
        //     }
        //     if (this.selectedIndustry === 'None of the Above' & this.selectedESG === 'No') {
        //         // if (event.target.value==='Yes' ){
        //         this.wrpAppReg.FundInESGPol__c = 'Fundable';
        //         this.iseligibility = true;


        //     }
        // }

        if (event.target.dataset.name === 'CharDiscrmtn__c') {
            this.selectedESG = event.target.value;
            if (this.selectedIndustry === 'None of the Above' & this.selectedESG === 'No') {
                // if (event.target.value==='Yes' ){
                this.wrpAppReg.FundInESGPol__c = 'FUNDABLE';
                this.iseligibility = true;


            }
            // if (event.target.value==='No'){
            else {
                this.iseligibility = true;
                this.wrpAppReg.FundInESGPol__c = 'NON FUNDABLE';
            }
        }
    }


    @wire(getPicklistValues, { recordTypeId: '$objInfo.data.defaultRecordTypeId', fieldApiName: DEALNGINDSTRY })
    customerProfilePicklistHandler({ data, error }) {
        if (data) {
            console.log(data);
            this.customerProfileOptions = [...this.generatePicklist(data)];
        }
        if (error) {
            console.log(error)
        }
    }


    @wire(getPicklistValues, { recordTypeId: '$objInfo.data.defaultRecordTypeId', fieldApiName: CHARDISCRMTN })
    DiscriminationPicklistHandler({ data, error }) {
        if (data) {
            console.log(data);
            this.discriminationOptions = [...this.generatePicklist(data)];
        }
        if (error) {
            console.log(error)
        }
    }

    //create or update existing record of Regulatory Appln

    handleSave() {
        //this.isSpinner = true;
        let ChildRecords = [];
        let childRecordObj = {};
        for (var i = 0; i < this.AllChildRecords.length; i++) {
            if (this.AllChildRecords[i].isDirty) {
                childRecordObj = {};
                childRecordObj.sobjectType = 'RegltryPrsonl__c',
                    childRecordObj.DirName__c = this.AllChildRecords[i].DirName__c,
                    childRecordObj.Desgntn__c = this.AllChildRecords[i].Desgntn__c,
                    childRecordObj.Reltnshp__c = this.AllChildRecords[i].Reltnshp__c,
                    childRecordObj.Applicant_Regulatory__c = this.AllChildRecords[i].Applicant_Regulatory__c,
                    childRecordObj.Id = this.AllChildRecords[i].Id
                ChildRecords.push(childRecordObj);
                console.log(' final childrecords' + JSON.stringify(ChildRecords));
            }

        }
        this.wrpAppReg.sobjectType = 'ApplRegltry__c';
        this.wrpAppReg.LoanAppln__c = this._loanAppId;
        let upsertData = {
            parentRecord: this.wrpAppReg,
            ChildRecords: ChildRecords,
            ParentFieldNameToUpdate: 'Applicant_Regulatory__c'
        }

        
        updateRegPer({ upsertData: upsertData })
            .then(result => {
                  this.isSpinner = false;
                this.showMessage();
                refreshApex(this._wiredRegulatoryDetails);
                
                //console.log(' parent record in save ' +JSON.stringify(this.parentRecord))
                // this.intitializeLoan();
                //this.intitialize();           

            }).catch(error => {
                console.log(error);
                this.isSpinner = false;
            })

        //adding login if all selected field as NO
        if (this.isYes == false) {
            for (var i = 0; i < this.AllChildRecords.length; i++) {
                let IdToDelete = this.AllChildRecords[i].Id;
                deleteRecord(IdToDelete)
                    .then(result => {
                        refreshApex(this._wiredRegulatoryDetails);
                    })
                    .catch(error => {
                        console.log(error);
                    });
            }
        }

        //till here
    }

    showMessage() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Success",
                message: this.customLabel.Regulatary_Update_SuccessMessage,
                variant: "success",
                mode: 'sticky'
            }))
    }

    //delete record
    deleteRPRecord(event) {
        //let del=this.AllChildRecords.splice(event.target.dataset.index,1);
        // let deleteRecordId=del[0].Id;
        // let del=this.AllChildRecords(event.target.dataset.index);
        let deleteRecordId = this.AllChildRecords[event.target.dataset.index].Id;
        //let deleteRecordId=del[0].Id;
        if (this.deleteRecordId == undefined) {
            this.AllChildRecords.splice(event.target.dataset.index, 1);
        }

        deleteRecord(deleteRecordId)
            .then(result => {
                refreshApex(this._wiredRegulatoryDetails);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: this.customLabel.Regulatary_Del_SuccessMessage,
                        variant: 'success',
                        mode: 'sticky'
                    })
                );
            })
            .catch(error => {
                console.log(error);
            });


    }

    //adding dynamic search for dealing industry

    // handleValueSelect(event) {
    //     this.lookupRec = event.detail;
    //     let lookupId = this.lookupRec.id;
    //     let lookupAPIName = this.lookupRec.lookupFieldAPIName;
    //     const outputObj = { [lookupAPIName]: lookupId };
    //     if (event.target.fieldName === 'DealngIndstry__c') {    
    //         //objArr[0].ChargeCodeDesc__c = this.lookupRec.mainField;
    //         //objArr[0].ChargeCodeDesID__c = lookupId;
    //         this.wrpAppReg.DealngIndstry__c = this.lookupRec.mainField;
    //       //  this.wrpAppReg[event.target.index].FinancierNameID__c = lookupId;
    //       this.selectedIndustry= this.lookupRec.mainField;
    //             // if (event.target.value==='None of the Above'){
    //             //             this.wrpAppReg.FundInESGPol__c= 'Fundable';                            
    //             //         }
    //                     if (this.selectedIndustry!='None of the Above'){
    //                         this.wrpAppReg.FundInESGPol__c='Non Fundable';
    //                     }
    //                     if(this.selectedIndustry === 'None of the Above' & this.selectedESG==='No' ){
    //                         // if (event.target.value==='Yes' ){
    //                              this.wrpAppReg.FundInESGPol__c='Fundable';
    //                              this.iseligibility= true; 


    //                              }

    //     }
    // }

    //searchable picklist
    get selectedValue(){
        return this.selectedSearchResult ?this.selectedSearchResult.label : null;
    }

    search(event){
        
        const inputBox = event.currentTarget;

        inputBox.setCustomValidity('');
        inputBox.reportValidity();

        const input= event.detail.value.toLowerCase();
        const result= this.customerProfileOptions.filter((customerProfileOptions)=>
        customerProfileOptions.label.toLowerCase().includes(input)
        );
        this.searchResults=result;
       
    }

    selectSearchResult(event){

        const selectedValue=event.currentTarget.dataset.value;
        
        this.selectedSearchResult=this.customerProfileOptions.find(
            (customerProfileOptions) => customerProfileOptions.value ===selectedValue
            
            
        );
        this.wrpAppReg.DealngIndstry__c=selectedValue;
        this.DealingIndustryValue= this.wrpAppReg.DealngIndstry__c;
        this.selectedIndustry =selectedValue;
        console.log('selected value',selectedValue)
        console.log('this.DealingIndustryValue handle chane',this.DealingIndustryValue)
        //validation
        
            if (selectedValue != 'None of the Above') {
                this.wrpAppReg.FundInESGPol__c = 'NON FUNDABLE';
            }
            if (selectedValue === 'None of the Above' & this.selectedESG === 'No') {
                // if (event.target.value==='Yes' ){
                this.wrpAppReg.FundInESGPol__c = 'FUNDABLE';
                this.iseligibility = true;


            }
        // }

        //end
        this.clearSearchResults();
        // const inputBox = this.DealingIndustryValue;
        // console.log('inputBox target',inputBox)
            
               let validateDeal= this.template.querySelector('.DealngIndstryCls');
        validateDeal.setCustomValidity('');
        validateDeal.reportValidity();
           
        //     const inputBox = event.currentTarget;

        // inputBox.setCustomValidity('');
        // inputBox.reportValidity()
    }

    showPicklistOptions(){
        if(!this.searchResults){
            this.searchResults=this.customerProfileOptions;
            
        }
    }

    handleInputBlur(){
        // if(this.searchResults.length<=0){
            window.clearTimeout(this.delayTimeout);
            this.delayTimeout = setTimeout(() => {
                if (!this.preventClosingOfSerachPanel) {
                    this.clearSearchResults();

                }
                this.preventClosingOfSerachPanel = false;
              }, DELAY);

        // }
    }

    handleBlur(){
        this.clearSearchResults();
        this.preventClosingOfSerachPanel = false;
    }

    handleDivClick() {
        this.preventClosingOfSerachPanel = true;
      }

    clearSearchResults(){
        this.searchResults=null;
    }

}