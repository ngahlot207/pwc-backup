import { LightningElement, track, wire, api } from 'lwc';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getRecord, createRecord, updateRecord, deleteRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import formFactorPropertyName from "@salesforce/client/formFactor";

// Resources
import QUE_IMAGE from "@salesforce/resourceUrl/QuestionMarkImage";

// Object Refernce
import APP_IMD_OBJECT from '@salesforce/schema/ApplIMD__c';
import INTEGRATION_MSG_OBJECT from "@salesforce/schema/IntgMsg__c";
import LOAN_APP_CHARGE_OBJECT from '@salesforce/schema/LonaApplCharges__c';

//Custom label required for charges calculation
import LOAN_AMT_Label from '@salesforce/label/c.RequestedLoanAmount';
import BELOW_AMT_Label from '@salesforce/label/c.Below5LakhCharges';
import ABOVE_AMT_Label from '@salesforce/label/c.Above5LakhCharges';
import GST_Label from '@salesforce/label/c.GST';

//Fields Refernce required for Loan Application Record
import CHARGE_CODE_FIELD from "@salesforce/schema/LonaApplCharges__c.ChargeCodeDesID__c";
import CHARGE_CODE_DESC_FIELD from "@salesforce/schema/LonaApplCharges__c.ChargeCodeDesc__c";
import REMARK_FIELD from "@salesforce/schema/LonaApplCharges__c.Remark__c";
import AMOUNT_FIELD from "@salesforce/schema/LonaApplCharges__c.Amount__c";
import LOAN_APP_CHG_FIELD from "@salesforce/schema/LonaApplCharges__c.LoanApplication__c";

//Fields Refernce
import BANK_ID_FIELD from "@salesforce/schema/BankCityMapping__c.Bank__r.Id";
import DOCDETAILCONTENTDOCUMENTID_FIELD from "@salesforce/schema/DocDtl__c.Content_Document_Id__c";
import DOCDETAILID_FIELD from "@salesforce/schema/DocDtl__c.Id";

//Integration Message Obj Fields Refernces
import REFERENCE_ID_FIELD from "@salesforce/schema/IntgMsg__c.RefId__c";
import REFERENCE_OBJ_API_FIELD from "@salesforce/schema/IntgMsg__c.RefObj__c";
import PARENT_REFERENCE_OBJ_API_FIELD from "@salesforce/schema/IntgMsg__c.ParentRefObj__c";
import PARENT_REFERENCE_ID_FIELD from "@salesforce/schema/IntgMsg__c.ParentRefId__c";
import INTEGRATION_MSG_NAME_FIELD from "@salesforce/schema/IntgMsg__c.Name";
import BU_FIELD from "@salesforce/schema/IntgMsg__c.BU__c";
import SERVICE_NAME_FIELD from "@salesforce/schema/IntgMsg__c.Svc__c";
import API_VENDOR__NAME_FIELD from "@salesforce/schema/IntgMsg__c.ApiVendor__c";
import IS_DOC_API_FIELD from "@salesforce/schema/IntgMsg__c.DocApi__c";
import IS_OUTBOUND_FIELD from "@salesforce/schema/IntgMsg__c.Outbound__c";
import IS_ACTIVE_FIELD from "@salesforce/schema/IntgMsg__c.IsActive__c";
import STATUS_FIELD from "@salesforce/schema/IntgMsg__c.Status__c";
import RESPONSE_PAYLOAD_FIELD from "@salesforce/schema/IntgMsg__c.Resp__c";
import API_STATUS_FIELD from "@salesforce/schema/IntgMsg__c.APIStatus__c";


//Apex methods
import validateAmount from '@salesforce/apex/IMDController.validateAmount';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import getSobjectDataWithoutCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataWithoutCacheable';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import deleteRecord_Charges from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getAPIsToRun from '@salesforce/apex/APIAutoTriggerCheck.checkAPIToRun';
import createPaytmSMSTask from '@salesforce/apex/PaytmResponseProcessor.createPaytmSMSTask';
import createSMSTask from '@salesforce/apex/IntegrationUtility.sendSMS';
//LMS details
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';


//refresh wire adapter
import { refreshApex } from '@salesforce/apex';

const MAX_FILE_SIZE = 5242880; //in bytes 5 MB now
//200 Mb max can go upto 2 Gb 

const bankMasterfields = [BANK_ID_FIELD];

// Custom labels
import PaytmDealingBankCode from '@salesforce/label/c.PaytmDealingBankCode';
import IMD_InstrumentNo from '@salesforce/label/c.IMD_InstrumentNo';
import IMD_DateToOps_ErrMsg from '@salesforce/label/c.IMD_DateToOps_ErrMsg';
import DetailsCapture_Format_ErrorMessage from '@salesforce/label/c.ApplicantCapture_Format_ErrorMessage';
import ALL_FIELDS_Label from '@salesforce/label/c.LeadCapture_BasicDetails_RequiredFieldsValidation';
import IMD_SUCCESS_Label from '@salesforce/label/c.IMD_Capture_SuccessMessage';
import LMS_update_Fail_MSG from '@salesforce/label/c.LMS_update_Failed_Message';//added by Gajendra for LAK-3124
import DATA_NOT_MODIFIED_Label from '@salesforce/label/c.DATA_NOT_MODIFIED';
import Imd_InstrumentAmt_ErrorMessage from '@salesforce/label/c.Imd_InstrumentAmt_ErrorMessage';
import Imd_UploadDoc_ErrorMessage from '@salesforce/label/c.Imd_UploadDoc_ErrorMessage';
import Imd_Payment_ErrorMessage from '@salesforce/label/c.Imd_Payment_ErrorMessage';
import Imd_Payment_SuccessMessage from '@salesforce/label/c.Imd_Payment_SuccessMessage';
import Imd_Del_SuccessMessage from '@salesforce/label/c.Imd_Del_SuccessMessage';
import IMD_Charge_DeleteMessage from '@salesforce/label/c.IMDChargeDeleteMessage';
import Imd_Charge_ErrorMessage from '@salesforce/label/c.Imd_Charge_ErrorMessage';
import Imd_DuplicateCharge_ErrorMessage from '@salesforce/label/c.Imd_DuplicateCharge_ErrorMessage';
import Imd_Charges_SuccessMessage from '@salesforce/label/c.Imd_Charges_SuccessMessage';
import Imd_Amount_ErrorMessage from '@salesforce/label/c.Imd_Amount_ErrorMessage';
import Imd_PositiveVal_ErrorMessage from '@salesforce/label/c.Imd_PositiveVal_ErrorMessage';
import Imd_DocDetails_ErrorMessage from '@salesforce/label/c.Imd_DocDetails_ErrorMessage';

import IMD_Instrument_Amt_Error_Message from '@salesforce/label/c.IMD_Instrument_Amt_Error_Message';
import IMD_Instrument_Date_Future_Err_Message from '@salesforce/label/c.IMD_Instrument_Date_Future_Err_Message';
import IMD_Instrument_Date_Before_75_Days_Err_Msg from '@salesforce/label/c.IMD_Instrument_Date_Before_75_Days_Err_Msg';
import IMD_HandoverDate_Future_Date_Err_Message from '@salesforce/label/c.IMD_HandoverDate_Future_Date_Err_Message';
import IMD_Handover_Date_Validation_Before_Ins_Date_Err_Msg from '@salesforce/label/c.IMD_Handover_Date_Validation_Before_Ins_Date_Err_Msg';
import IMD_Instrument_Date from '@salesforce/label/c.IMD_Instrument_Date';
import Id from "@salesforce/user/Id";

import IMD_DealingBank_PaytmFinnoneCode from '@salesforce/label/c.IMD_DealingBank_PaytmFinnoneCode';

export default class CaptureImdDetails extends NavigationMixin(LightningElement) {

    label = {
        DetailsCapture_Format_ErrorMessage,
        ALL_FIELDS_Label,
        IMD_SUCCESS_Label,
        LMS_update_Fail_MSG,
        DATA_NOT_MODIFIED_Label,
        Imd_InstrumentAmt_ErrorMessage,
        Imd_UploadDoc_ErrorMessage,
        Imd_Payment_ErrorMessage,
        Imd_Payment_SuccessMessage,
        Imd_Del_SuccessMessage,
        Imd_Charge_ErrorMessage,
        Imd_DuplicateCharge_ErrorMessage,
        Imd_Charges_SuccessMessage,
        Imd_Amount_ErrorMessage,
        Imd_PositiveVal_ErrorMessage,
        Imd_DocDetails_ErrorMessage,
        IMD_Charge_DeleteMessage,
        IMD_Instrument_Amt_Error_Message,
        IMD_Instrument_Date_Future_Err_Message,
        IMD_Instrument_Date_Before_75_Days_Err_Msg,
        IMD_HandoverDate_Future_Date_Err_Message,
        IMD_Handover_Date_Validation_Before_Ins_Date_Err_Msg,
        IMD_Instrument_Date,
        PaytmDealingBankCode,
        IMD_InstrumentNo,
        IMD_DateToOps_ErrMsg,
        IMD_DealingBank_PaytmFinnoneCode
    }

    @track userId = Id;
    @track userRole=['CPA','UW','ACM','RCM','ZCM','NCM','CH'];
    @track creditTeamcounter = 0 ;

    @track formFactor = formFactorPropertyName;
    desktopBoolean = false;
    phoneBolean = false;

    image = QUE_IMAGE;

    //track properties
    @track wiredData = {};
    @track isShowModal = false;
    @track isIMDTransferVisible = false
    @track showSpinner = false;
    @track parentWrapObj = {}
    @track imdWrapObj = {}
    @track lightningDomainName;
    @track vfUrl;
    @track fileData = [];
    @track fileName = '';
    @track DocumentDetaiId;
    @track callPaymentGatewayAPI = false;
    @track callSequenceAPIFlag = false;
    // @track DocumentType;
    @track DocumentDetailName;
    @track DocMasterId;
    @track _recordId
    @track _loanAppId;
    @track bankId = ''
    @track bankNameId = ''
    @track state = ''
    @track imdMasterObj = {}
    @track _documentDetail = [];
    @track micrMasterObj = {}
    @track mainBankBranchData = []
    @track apiStatusFlag = false
    @track ChildRecords = []
    @track responseWrapper;
    @track uploadDocData = {}
    @track isRendered = false;
    @track disableMode = false;
    @track isDataChanged = false;
    @track isdocFlag = false;

    //arrays for picklist options
    @track paymentModeOptions = []
    @track bankBranchOptions = []
    @track paymentGateWayOptions = []

    fileSizeMsz = "Maximum file size should be 5Mb. Allowed file types are .pdf, .jpg, .jpeg";

    //normal properties
    messageMismatchError = this.label.DetailsCapture_Format_ErrorMessage;

    //filter condition properties for custom lookup search
    filterConditionForBank

    //boolean properties
    transactionDetailsFlag = false 
    disableLink = false
    @track hasAddIMDEditAccess = false

    get disLink() {
        return this.disableLink || this.disableMode
    }
    get disFthTras(){
        //this.imdWrapObj.PaymentGateway__c === 'Billdesk' added for Bill Desk Api
        if(this.imdWrapObj.PaymentGateway__c === 'Paytm'){
            return (this.imdWrapObj.PaytmOrderId__c != undefined && this.imdWrapObj.TransStatus__c != 'Success' && this.imdWrapObj.PaytmAPIStatus__c === 'Success');//|| this.imdWrapObj.PaymentGateway__c === 'Billdesk'  disabled as of now
        }
        else if(this.imdWrapObj.PaymentGateway__c === 'Billdesk'){
            return (this.imdWrapObj.OrderId__c != undefined && this.imdWrapObj.TransStatus__c != 'Success' && this.imdWrapObj.BillDeskAPIStatus__c === 'Success');
        }
        else{
            return false;
        }
    }

    get addImdDisable(){
        return this.hasAddIMDEditAccess === false 
    }

    get refreshDisable(){
        return (this.imdWrapObj && this.imdWrapObj.PaymentGateway__c != undefined && this.imdWrapObj.PaymentGateway__c === 'Billdesk')
    }

    creditTeamCount(){
    let  creditTeamParams = {
            ParentObjectName: 'TeamHierarchy__c',
            ChildObjectRelName: '',
            parentObjFields: ['id','FullName__c', 'EmpRole__c' ],
            childObjFields: [],
            queryCriteria: ' WHERE Employee__c = \''+this.userId+'\' AND EmpRole__c IN  (\''+this.userRole.join('\', \'') + '\')'
        }
        getSobjectData({ params: creditTeamParams })
            .then((result) => {
                    if(result.parentRecords && result.parentRecords.length > 0) {
                        this.hasAddIMDEditAccess = this.hasEditAccess ? true : false
                    }else{
                        this.hasAddIMDEditAccess = false
                    }
            })
            .catch(error => console.log('Error -210 '+ error))
    }


    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;

        let tempParams = this.params;
        tempParams.queryCriteria = ' where id = \'' + this._loanAppId + '\'';
        this.params = { ...tempParams };
        this.setAttribute("loanAppId", value);
        this.handleLoanRecordIdChange();
        this.getApplicants();

    }
    //api properties
    @api isReadOnly;
    @api layoutSize;
    @api docName;
    @api docType;
    @api docCategory;
    @api allowedFilFormat = ".jpg, .jpeg, .pdf";
    @api hasEditAccess


    @track cvId;
    @track contDocType;
    @track contDocId;
    @track showModalForFilePre = false;

    @wire(MessageContext)
    MessageContext;

    connectedCallback() {
        this.getSobjectDataWithoutCacheable();
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
        this.activeSection = ["A"];
        this.scribeToMessageChannel();
        this.isIMDTransferVisible = true
        this.imdWrapObj.IsIMDTransCase__c = 'No'
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        }
        else {
            this.disableMode = false;
        }
        this.creditTeamCount();
    }

    renderedCallback() {
        if (this.imdWrapObj.BankId__c && this.isRendered === false) {
            this.bankNameId = this.imdWrapObj.BankId__c
            this.isRendered = true;
        }
        //LAK-8061
    }

    //generate picklist from values 
    generatePicklist(data) {
        return data.values.map(item => ({ "label": item.label, "value": item.value }))
    }

    @track paymentOptionsDisable = false;

    get choiceOptiopns() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    get paymentModeVisible() {
        return this.imdWrapObj.IsIMDTransCase__c === 'No'
    }

    get lmsUpdateEnable() {
        return !this.hasEditAccess || this.lmsButton_Enable() || this.imdWrapObj.FinnoneChequeId__c
    }

    get success_FinnOneChequeId() {
        return this.imdWrapObj.FinnoneChequeId__c
    }

    lmsButton_Enable() {
        let tempFlag = true
        //this.imdWrapObj.PaymentGateway__c === 'Billdesk' added for Bill Desk Api
        if (this.imdWrapObj.IsIMDTransCase__c === 'No' && !this.imdWrapObj.FinnoneChequeId__c && ((this._documentDetail && this.imdWrapObj.DocDetail__r && (this.imdWrapObj.PaymentMode__c === 'DD' || this.imdWrapObj.PaymentMode__c === 'Cheque') && (this.disabled_mode() == false))
            || (this.imdWrapObj.PaymentMode__c === 'Payment Gateway' && (this.imdWrapObj.PaymentGateway__c === 'Paytm' || this.imdWrapObj.PaymentGateway__c === 'Billdesk') && this.imdWrapObj.PaymentRefNo__c != null && this.imdWrapObj.TransStatus__c === 'Success' ))) {
            tempFlag = false
        }
        else {
            tempFlag = true
        }
        return tempFlag
    }

    disabled_mode() {
        let tempFlag = true
        if (this.imdWrapObj.PaymentMode__c === 'DD') {
            if (this._documentDetail) {
                if (this.imdWrapObj.DocDetail__r) {
                    if (this.imdWrapObj.InstrumentAmt__c && this.imdWrapObj.InstrumentNo__c && this.imdWrapObj.InstrumentDt__c 
                        && this.imdWrapObj.City__c && this.imdWrapObj.BankName__c && this.imdWrapObj.BankBrch__c && this.imdWrapObj.MICRCode__c && this.imdWrapObj.DealingBank__c) {
                        tempFlag = false
                    }
                }
            }
        }else if (this.imdWrapObj.PaymentMode__c === 'Cheque') {
            if (this._documentDetail) {
                if (this.imdWrapObj.DocDetail__r) {
                    if (this.imdWrapObj.InstrumentAmt__c && this.imdWrapObj.InstrumentNo__c && this.imdWrapObj.InstrumentDt__c && this.imdWrapObj.BankAccountNo__c
                        && this.imdWrapObj.City__c && this.imdWrapObj.BankName__c && this.imdWrapObj.BankBrch__c && this.imdWrapObj.MICRCode__c && this.imdWrapObj.DealingBank__c) {
                        tempFlag = false
                    }
                }
            }
        } else if (this.imdWrapObj.PaymentMode__c === 'Payment Gateway' && (this.imdWrapObj.PaymentGateway__c === 'Paytm' || this.imdWrapObj.PaymentGateway__c === 'Billdesk') && this.imdWrapObj.PaymentRefNo__c != null) {
            tempFlag = false
        } else {
            tempFlag = true
        }
        return tempFlag
    }
    //this.imdWrapObj.PaymentGateway__c === 'Billdesk' added for Bill Desk Api
    get transAmtField_disable(){
        return (this.imdWrapObj.PaymentMode__c === 'Payment Gateway' && (this.imdWrapObj.PaymentGateway__c === 'Paytm' || this.imdWrapObj.PaymentGateway__c === 'Billdesk')) || this.disableMode
    }

    get transAmtValue(){
        return this.imdWrapObj.TransAmt__c;
    }

    get checkOrDDSectionVisible() {
        return this.imdWrapObj.PaymentMode__c === 'DD' || this.imdWrapObj.PaymentMode__c === 'Cheque'
    }

    // LAK-3076 (Bank Account No. visibility condition for cheque only) - made by Prasanna Kawle
    get checkSectionVisible() {
        return  this.imdWrapObj.PaymentMode__c === 'Cheque'
    }
    // LAK-3076

    get DocumentType() {
        return this.imdWrapObj.PaymentMode__c === 'DD' ? 'DD' : this.imdWrapObj.PaymentMode__c === 'Cheque' ? 'Cheque' : ''
    }

    get paymentGatewayVisible() {
        return this.imdWrapObj.PaymentMode__c === 'Payment Gateway'
    }

    get showLinkButton() {
        return this.imdWrapObj.PaymentGateway__c === 'Paytm' || this.imdWrapObj.PaymentGateway__c === 'Billdesk'
    }

    get transactionDetails() {
        return this.transactionDetailsFlag 
    }

    get docDet() {
        return this._documentDetail && (this.imdWrapObj.PaymentMode__c === 'DD' || this.imdWrapObj.PaymentMode__c === 'Cheque')
    }

    get chargeDisAccess() {
        return this.hasEditAccess === false
    }

    paymentGateWayVisibleOptions = ['Paytm','Billdesk']

    @wire(getObjectInfo, { objectApiName: APP_IMD_OBJECT })
    objectInfo

    @wire(getPicklistValuesByRecordType, {
        objectApiName: APP_IMD_OBJECT,
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    })
    addressPicklistHandler({ data, error }) {
        if (data) {
            this.paymentModeOptions = [...this.generatePicklist(data.picklistFieldValues.PaymentMode__c)]

            //logic for Payment Gateway picklist
            let paymentGateWayAllOptions = [...this.generatePicklist(data.picklistFieldValues.PaymentGateway__c)]
            let tempArray = [];
            for (let i = 0; i < paymentGateWayAllOptions.length; i++) {

                if (this.paymentGateWayVisibleOptions.indexOf(paymentGateWayAllOptions[i].label) > -1) {
                    tempArray.push(paymentGateWayAllOptions[i]);
                }
            }
            this.paymentGateWayOptions = [...tempArray]
        }
        if (error) {
            console.error(error)
        }
    }

    @track
    paytmDealingBankParams = {
        ParentObjectName: 'MasterData__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'FinnoneCode__c'],
        childObjFields: [],
        queryCriteria: ' where FinnoneCode__c = \'' + this.label.PaytmDealingBankCode+ '\''
    }

    searchPaytmDealingBank(){
        this.paytmDealingBankParams.queryCriteria = ' where FinnoneCode__c = \'' + this.label.PaytmDealingBankCode+ '\''
        getSobjectData({ params: this.paytmDealingBankParams })
            .then((result) => {
                if (result.parentRecords) {
                    this.imdWrapObj.DealingBank__c = result.parentRecords[0].Id;
                }
            })
            .catch((error) => {
                console.error('Error in line ##436', error)
            })
    }

    inputChangeHandler(event) {
        this.imdWrapObj[event.target.dataset.fieldname] = event.target.value
        this.isDataChanged = true;
        if (event.target.dataset.fieldname === 'PaymentMode__c') {
            this.imdWrapObj.InstrumentAmt__c = '';
            this.imdWrapObj.InstrumentNo__c = '';
            this.imdWrapObj.InstrumentDt__c = '';
            this.imdWrapObj.BankAccountNo__c = '';
            this.imdWrapObj.MICRCode__c = '';
            this.imdWrapObj.InstrHandvrDateToOps__c = '';
            this.imdWrapObj.DealingBank__c = null;
            if (!this.imdWrapObj.MICRCode__c) {
                this.imdWrapObj.City__c = '';
                this.imdWrapObj.BankName__c = '';
                this.imdWrapObj.BankBrch__c = '';
            }
            if (this.imdWrapObj.PaymentMode__c) {
                if (this.imdWrapObj.PaymentMode__c === 'Cheque' || this.imdWrapObj.PaymentMode__c === 'DD') {
                    this.imdWrapObj.PaymentGateway__c = ''
                    this.transactionDetailsFlag = false
                    this.disableLink = false
                }
            }
        }
        
        if (event.target.dataset.fieldname === 'IsIMDTransCase__c') {
            if (this.imdWrapObj.IsIMDTransCase__c === 'No') {
                this.isIMDTransferVisible = true
            }
        }
        if (event.target.dataset.fieldname === 'InstrHandvrDateToOps__c') {
            if (this.imdWrapObj.InstrHandvrDateToOps__c) {
                this.validateInsHandoverDate();
            }
        }
        if (event.target.dataset.fieldname === 'InstrumentDt__c') {
            if (this.imdWrapObj.InstrumentDt__c) {
                this.validateInsDate();
            }
        }
    }

    get stageValidation() {
        return this.parentWrapObj.Stage__c != 'QDE' && (this.imdWrapObj.PaymentMode__c === 'Cheque' || this.imdWrapObj.PaymentMode__c === 'DD')
    }

    get errorMessageVisible() {
        return this.imdWrapObj.IntegrationStatus__c === 'Failure'
    }

    get chartTable_visibility() {
        return this.parentWrapObj.Stage__c != 'QDE' 
    }
    get bounced_chartTable_visibility() {
        return this.parentWrapObj.Stage__c != 'QDE' && this.bouncedIMDArr.length > 0
    }

    get reInitiateIMDButton(){
        return this.imdWrapObj.IMDStatus__c === 'Bounced' || this.imdWrapObj.IMDStatus__c === 'Cancelled'
    }

    get handOverDate_enable(){
        return !((this.parentWrapObj.Stage__c === 'QDE' || this.parentWrapObj.Stage__c === 'DDE' || this.parentWrapObj.Stage__c === 'UnderWriting' || this.parentWrapObj.Stage__c === 'Post Sanction'|| this.parentWrapObj.Stage__c === 'Soft Sanction' ) && this.hasEditAccess)
    }

    //LAK-8443
    get checkDDInst_enable(){
        return !this.hasEditAccess
    }

    //parameter to find the state for same loan application branch code from Location Branch Junction
    @track
    stateParams = {
        ParentObjectName: 'LocBrchJn__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Location__r.State__c'],
        childObjFields: [],
        queryCriteria: ' where Branch__r.BrchCode__c = \'' + this.parentWrapObj.BrchCode__c + '\''
    }

    stateSearch() {
        this.stateParams.queryCriteria = ' where Branch__r.BrchCode__c = \'' + this.parentWrapObj.BrchCode__c + '\''
        getSobjectData({ params: this.stateParams })
            .then((result) => {
                if (result.parentRecords) {
                    this.state = result.parentRecords[0].Location__r.State__c;
                }
            })
            .catch((error) => {
                console.error('Error in line ##213', error)
            })
    }

    @track wiredImdTracker;
    imdValue = 'IMD'
    //parameter to find the IMD Master record based on State 
    @track
    imdParams = {
        ParentObjectName: 'IMDMstr__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'State__c', 'Tax__c', 'IMDAmt__c', 'Customer_Profile__c', 'EligibilityProgram__c', 'LeadSource__c', 'MaxLoanAmt__c', 'MinLoanAmt__c', 'PrdType__c', 'PromoCode__c', 'ChargeType__c'],
        childObjFields: [],
        queryCriteria: ' where State__c = \'' + this.state + '\'' + ' AND PrdType__c = \'' + this.parentWrapObj.Product__c + '\'' + ' AND ChargeType__c = \'' + this.imdValue + '\''
    }

    @track
    applParams = {
        ParentObjectName: 'Applicant__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'ApplType__c', 'Constitution__c'],
        childObjFields: [],
        queryCriteria: ' '
    }
    applicantList = [];
    getApplicants() {
        this.applParams.queryCriteria = '  where LoanAppln__c = \'' + this._loanAppId + '\' AND ( ApplType__c = \'' + 'P' + '\'' + ' OR ApplType__c = \'' + 'G' + '\'' + ' OR ApplType__c = \'' + 'C' + '\')'
        getSobjectData({ params: this.applParams })
            .then((result) => {
                // let intRecArr = []
                this.applicantList = result.parentRecords;
                
            })
            .catch((error) => {
                console.error('Error in line ##468', error)
            })
    }

    //parameter to find the loan application and IMD record
    @track errorMsg = '';
    @track
    params = {
        ParentObjectName: 'LoanAppl__c',
        ChildObjectRelName: 'Applicant_IMD__r',
        parentObjFields: ['Id','CreatedDate','IMDAmount__c','SanLoanAmt__c','BrchCode__c', 'PromotionId__c', 'Product__c', 'AssessedIncAppln__c', 'ReqLoanAmt__c', 'LeadSource__c', 'Applicant__r.CustProfile__c', 'Stage__c', 'SubStage__c', 'LMSUpdTrig__c','FinnoneAppid__c','TotalIMDAmount__c','SchemeId__c'],
        childObjFields: ['Id','CreatedDate','IMDStatus__c', 'InstrumentAmt__c', 'AppId__c', 'BankAccountNo__c', 'BankBrch__c', 'BankName__c', 'CustId__c', 'DocDetail__c', 'IMDAmt__c', 'LMSUpdateStatus__c', 'City__c',
            'InstrumentDt__c', 'InstrumentNo__c', 'LoanAppln__c', 'MICRCode__c', 'PaymentGateway__c', 'PaymentMode__c', 'TransferDt__c', 'Transferred__c', 'PaymentRefNo__c', 'IMDReceived__c','PaytmOrderId__c','BillDeskAPIStatus__c','OrderId__c',
            'IsIMDTransCase__c', 'BankId__c', 'CityId__c', 'DocDetail__r.DocSubTyp__c', 'DocDetail__r.Content_Document_Id__c', 'ChequeOCRStatus__c', 'FinnoneChequeId__c', 'TransStatus__c','PaytmAPIStatus__c','PaytmErrMess__c','BillDeskAPIErrorMessage__c',
            'BRECheqClrStatus__c', 'CheqBounceReason__c', 'CheqClrDate__c', 'IntegrationStatus__c', 'ErrorMessage__c','InstrHandvrDateToOps__c','DealingBank__c','TransAmt__c','PaytmLinkExpiryDate__c','BillDeskLinkExpiryDate__c'],
        queryCriteria: ' where id = \'' + this._loanAppId + '\''
    }

    getSobjectDataWithoutCacheable() {
        getSobjectDataWithoutCacheable({params: this.params})
        .then((result) => {
            this.showSpinner = false;
            this.isDataChanged = false; 
            if (result[0].parentRecord) {
                this.parentWrapObj = { ...result[0].parentRecord}
                this.stateSearch();
                if (result[0].ChildReords) {
                    this.bouncedIMDArr = [];
                    this.IMDArray = [];
                    result[0].ChildReords.forEach(item => {
                        if(item.IMDStatus__c === 'Bounced' || item.IMDStatus__c === 'Cancelled') this.bouncedIMDArr.push(item);
                        this.IMDArray.push(item);
                    });

                    let tempBouncedArr = [...this.bouncedIMDArr];
                    this.bouncedIMDArr = [];
                    tempBouncedArr.forEach(item =>{
                        let Obj = {...item };
                        if(item.InstrumentDt__c) Obj.InstrumentDt__c = this.formattedDate(item.InstrumentDt__c);
                        if(item.InstrHandvrDateToOps__c) Obj.InstrHandvrDateToOps__c= this.formattedDate(item.InstrHandvrDateToOps__c);
                        this.bouncedIMDArr.push(Obj);
                    })

                    this.IMDArray.sort((a, b) => new Date(b.CreatedDate) - new Date(a.CreatedDate));

                    this.imdWrapObj = { ...this.IMDArray[0], IsIMDTransCase__c: 'No' }
                    let tempArray=[];
                    tempArray.push(this.imdWrapObj);
                    this._documentDetail = [...tempArray];
                    
                    if (this.imdWrapObj.PaymentMode__c === 'Payment Gateway') {
                        this.transactionDetailsFlag = true;
                    }
                    if (this.imdWrapObj.PaymentRefNo__c && this.imdWrapObj.TransStatus__c === 'Success') {
                        this.disableLink = true
                    }
                    if (this.imdWrapObj.FinnoneChequeId__c) {
                        this.disableMode = true
                    }
                }
                this.imdWrapObj = {...this.imdWrapObj,IMDAmt__c:this.parentWrapObj.IMDAmount__c,IsIMDTransCase__c : 'No'};
                if(this.disableMode || this.imdWrapObj.TransStatus__c === 'Success'){
                    this.paymentOptionsDisable =true;
        
                }else{
                    this.paymentOptionsDisable =false;
                }
                if(this.imdWrapObj.PaymentGateway__c){
                if(this.imdWrapObj.BillDeskAPIErrorMessage__c && this.imdWrapObj.PaymentGateway__c === 'Billdesk'){
                    this.errorMsg = this.imdWrapObj.BillDeskAPIErrorMessage__c;
                }
                else if(this.imdWrapObj.PaytmErrMess__c){
                    this.errorMsg = this.imdWrapObj.PaytmErrMess__c;
                }
                else{
                    this.errorMsg ='';
                }
                }
            }
        })
        .catch((error) => {
            console.log('ERROR IN HOST CONTAINER RECORD ACCEESS', error);
        });
    }

    @track bouncedIMDArr = [];
    @track IMDArray = [];
    @wire(getSobjectDatawithRelatedRecords, { params: '$params' })
    handleResponse(result) {
        //this.showSpinner = false;
        this.isDataChanged = false; 
        this.wiredData = result
        if (result.data) {
            this.parentWrapObj = { ...result.data.parentRecord }
            this.stateSearch();
            if (result.data.ChildReords) {
                this.bouncedIMDArr = [];
                this.IMDArray = [];
                result.data.ChildReords.forEach(item => {
                    if(item.IMDStatus__c === 'Bounced' || item.IMDStatus__c === 'Cancelled') this.bouncedIMDArr.push(item);
                    this.IMDArray.push(item);
                });

                let tempBouncedArr = [...this.bouncedIMDArr];
                this.bouncedIMDArr = [];
                tempBouncedArr.forEach(item =>{
                    let Obj = {...item };
                    if(item.InstrumentDt__c) Obj.InstrumentDt__c = this.formattedDate(item.InstrumentDt__c);
                    if(item.InstrHandvrDateToOps__c) Obj.InstrHandvrDateToOps__c= this.formattedDate(item.InstrHandvrDateToOps__c);
                    this.bouncedIMDArr.push(Obj);
                })

                this.IMDArray.sort((a, b) => new Date(b.CreatedDate) - new Date(a.CreatedDate));

                this.imdWrapObj = { ...this.IMDArray[0], IsIMDTransCase__c: 'No' }
                let tempArray=[];
                tempArray.push(this.imdWrapObj);
                this._documentDetail = [...tempArray];
                
                if (this.imdWrapObj.PaymentMode__c === 'Payment Gateway') {
                    this.transactionDetailsFlag = true;
                }
                if (this.imdWrapObj.PaymentRefNo__c && this.imdWrapObj.TransStatus__c === 'Success') {
                    this.disableLink = true
                }
                if (this.imdWrapObj.FinnoneChequeId__c) {
                    this.disableMode = true
                }
            }
            this.imdWrapObj = {...this.imdWrapObj,IMDAmt__c:this.parentWrapObj.IMDAmount__c,IsIMDTransCase__c : 'No'};
            if(this.disableMode || this.imdWrapObj.TransStatus__c === 'Success'){
                this.paymentOptionsDisable =true;
    
            }else{
                this.paymentOptionsDisable =false;
            }

            if(this.imdWrapObj.PaymentGateway__c){
                if(this.imdWrapObj.BillDeskAPIErrorMessage__c && this.imdWrapObj.PaymentGateway__c === 'Billdesk'){
                    this.errorMsg = this.imdWrapObj.BillDeskAPIErrorMessage__c;
                }
                else if(this.imdWrapObj.PaytmErrMess__c){
                    this.errorMsg = this.imdWrapObj.PaytmErrMess__c;
                }
                else{
                    this.errorMsg ='';
                }
                }
            this.showSpinner = false;
        }
        if (result.error) {
            this.showSpinner = false;
            console.error(result.error);
        }
    }

    formattedDate(originalDate) {
        const dateObj = new Date(originalDate);
        const day = dateObj.getDate().toString().padStart(2, '0');
        const month = (dateObj.getMonth() + 1).toString().padStart(2, '0'); // Month is zero-based
        const year = dateObj.getFullYear().toString();
 
        return `${day}-${month}-${year}`;
    }
    

    @track dealingBankError =''
    @track lookupRec_DealingBank
    handleDealingBank(event){
        this.lookupRec_DealingBank = event.detail;
        this.isDataChanged = true;
        if (event.target.label === 'Dealing Bank') {
            this.imdWrapObj.DealingBank__c = this.lookupRec_DealingBank.id;
            if (!this.lookupRec_DealingBank.id) {
                this.dealingBankError = 'Please select correct Dealing Bank'
            } else {
                this.dealingBankError = ''
            }
        }
    } 
    
    get filterCondnDealingBank(){
        return 'Type__c = '+
        "'" +
        "Dealing Bank" +
        "'" +' AND FinnoneCode__c != ' + "'" +
        this.label.IMD_DealingBank_PaytmFinnoneCode +
        "'" 
    }
    

    //parameter to find the bank branch
    @track
    branchNameparams = {
        ParentObjectName: 'MICRCodeMstr__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'BrchName__c', 'MICRCode__c', 'Bank__r.Name', 'City__r.Name', 'City__r.CityId__c'],
        childObjFields: [],
        queryCriteria: ' where MICRCode__c = \'' + this.imdWrapObj.MICRCode__c + '\''
    }

    @track micrError = ''

    handleMICRSelect(event) {
        this.lookupRec = event.detail;
        this.isDataChanged = true;
        if (event.target.label === 'MICR Code') {
            this.imdWrapObj.MICRCode__c = this.lookupRec.mainField;
            if (!this.lookupRec.mainField) {
                this.micrError = 'Please select correct MICR Code'
            } else {
                this.micrError = ''
                this.searchBankDetails();
            }
        }
    }

    searchBankDetails() {
        let tempParams = this.branchNameparams;
        tempParams.queryCriteria = ' where MICRCode__c = \'' + this.imdWrapObj.MICRCode__c + '\'' + ' LIMIT 1'
        this.branchNameparams = { ...tempParams };
        getSobjectData({ params: this.branchNameparams })
            .then((result) => {
                if (result.parentRecords) {
                    this.imdWrapObj.City__c = result.parentRecords[0].City__r.Name
                    this.imdWrapObj.CityId__c = result.parentRecords[0].City__r.CityId__c
                    this.imdWrapObj.BankName__c = result.parentRecords[0].Bank__r.Name
                    this.imdWrapObj.BankBrch__c = result.parentRecords[0].BrchName__c
                }
            })
            .catch((error) => {
                console.error('Error in line ##385', error)
            })
    }

    mismatchAmountPatter = 'Please enter only positive values'

    validateInsAmt(){
        let isValid = true ;
        if(this.imdWrapObj.InstrumentAmt__c < this.imdWrapObj.IMDAmt__c){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.label.IMD_Instrument_Amt_Error_Message,
                    variant: 'error',
                    mode:'sticky'
                })
            );
            isValid = false ;
        }
        return isValid;
    }

    validateInsDate(){
        let isValid = true ;
        const currentDate = new Date().toISOString().slice(0, 10);
        const differenceInDays = this.calculateDateDifference(this.imdWrapObj.InstrumentDt__c);
        if (this.imdWrapObj.InstrumentDt__c > currentDate) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.label.IMD_Instrument_Date_Future_Err_Message,
                    variant: 'error',
                    mode:'sticky'
                })
            );
            isValid = false ;
        }else if (differenceInDays > this.label.IMD_Instrument_Date) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.label.IMD_Instrument_Date_Before_75_Days_Err_Msg,
                    variant: 'error',
                    mode:'sticky'
                })
                );
            isValid = false;
        }else{
            isValid = true ;
        }
        return isValid;
    }

    calculateDateDifference(startDate) {
        const startDateObj = new Date(startDate);
        const differenceMs = new Date().getTime() - startDateObj.getTime();

        const differenceDays = Math.ceil(differenceMs / (1000 * 60 * 60 * 24));
    
        return differenceDays;
    }

    validateInsHandoverDate(){
        let isValid = true ;
        const currentDate = new Date().toISOString().slice(0, 10);

        if (this.imdWrapObj.InstrHandvrDateToOps__c > currentDate) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.label.IMD_HandoverDate_Future_Date_Err_Message,
                    variant: 'error',
                    mode:'sticky'
                })
            );
            isValid = false ;
        }else if (this.imdWrapObj.InstrHandvrDateToOps__c < this.imdWrapObj.InstrumentDt__c) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.label.IMD_Handover_Date_Validation_Before_Ins_Date_Err_Msg +' '+ this.imdWrapObj.InstrumentDt__c,
                    variant: 'error',
                    mode:'sticky'
                })
                );
            isValid = false;
        }else{
            isValid = true ;
        }
        return isValid;
    }

    validateForm() {
        let isValid = true

        if(this.imdWrapObj.InstrHandvrDateToOps__c){
            if(!this.validateInsHandoverDate()) {
                isValid = false;
            }
        }
        if(!this.validateInsDate() && this.imdWrapObj.InstrumentDt__c){
            isValid = false;
        }
        if(this.imdWrapObj.PaymentMode__c === 'DD' || this.imdWrapObj.PaymentMode__c === 'Cheque'){
            if(this.imdWrapObj.InstrumentAmt__c){
                if(!this.validateInsAmt()){
                    isValid = false;
                }
            }
        }

        if (this.imdWrapObj.PaymentMode__c === 'DD' || this.imdWrapObj.PaymentMode__c === 'Cheque') {
            if (this.imdWrapObj.InstrumentAmt__c && this.imdWrapObj.InstrumentAmt__c < 0) {
                isValid = false;
                this.showToastMessage('Error', this.label.Imd_InstrumentAmt_ErrorMessage, 'error', 'sticky');
            }

            if (!this.imdWrapObj.MICRCode__c) { //LAK-3823
                isValid = false;
            }
            if (!this.imdWrapObj.DealingBank__c) { 
                isValid = false;
            }
        }

        if (this.parentWrapObj.Stage__c != 'QDE' && !this.handleChargeAmt_validity()) {
            isValid = false
        }

        if (!this.checkValidityLookup()) {
            isValid = false;
        } 

        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if (element.reportValidity()) {
            } else {
                isValid = false;
            }
        });

        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
            } else {
                isValid = false;
            }
        });
        return isValid;
    }

    checkValidityLookup() {
        let isInputCorrect = true;
        let allChilds = this.template.querySelectorAll("c-custom-lookup");
        allChilds.forEach((child) => {
          if (!child.checkValidityLookup()) {
            child.checkValidityLookup();
            isInputCorrect = false;
          }
        });
        return isInputCorrect;
    }

    handleIMDReinitiate(event){
        this.imdWrapObj = {};
        this._documentDetail = [];
        let obj = {};
        obj.IsIMDTransCase__c = 'No';
        obj.IMDAmt__c = this.parentWrapObj.IMDAmount__c;
        this.imdWrapObj = {...obj};       
        this.paymentOptionsDisable =false;
        this.disableMode = false;
    }

    handleCustomerLink(event) {
        this.transactionDetailsFlag = true
        this.disableLink = true
        this.createIntegration_sendLink()
    }

    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(evt);
    }

    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }

    handleSaveThroughLms(values) {
        this.handleSave(values.validateBeforeSave);
    }

    handleSave(validate) {
        if (validate) {
            let isInputCorrect = this.validateForm();

            if (isInputCorrect === true) {
                if (!this.imdWrapObj.DocDetail__c && (this.imdWrapObj.PaymentMode__c === 'DD' || this.imdWrapObj.PaymentMode__c === 'Cheque')) {
                    this.showToastMessage('Error', this.label.Imd_UploadDoc_ErrorMessage, 'error', 'sticky');
                    this.showSpinner = false;
                } else {
                    if (this.isDataChanged) {
                        this.showSpinner = true;
                        this.handleUpsert();
                    }
                    if (this.parentWrapObj.Stage__c != 'QDE' && this.isChargeChanged) {
                        this.createLoanApplications_Charge();
                    }
                    if (!this.isDataChanged && !this.isChargeChanged) {
                        this.showToastMessage('Info', this.label.DATA_NOT_MODIFIED_Label, 'info', 'dismissable')
                    }
                }

            } else {
                this.showToastMessage('Error', this.label.ALL_FIELDS_Label, 'error', 'sticky');
                this.showSpinner = false;
            }
        }
        else {
            if (this.isDataChanged) {
                this.showSpinner = true;
                this.handleUpsert();
             
            }
            if (this.parentWrapObj.Stage__c != 'QDE' && this.isChargeChanged) {
                this.createLoanApplications_Charge();
            }
            if (!this.isDataChanged && !this.isChargeChanged) {
                this.showToastMessage('Info', this.label.DATA_NOT_MODIFIED_Label, 'info', 'dismissable')
            }
        }

    }

    //method used to check empty object 
    isEmptyObject(obj) {
        return Object.keys(obj).length === 0;
    }

    handleUpsert() {
        let imdDetailRecord = [];
        this.loanApplObj.Id = this._loanAppId;
        if (!this.isEmptyObject(this.imdWrapObj)) {
            this.imdWrapObj.sobjectType = 'ApplIMD__c';

            imdDetailRecord.push(this.imdWrapObj);
        }
        this.parentWrapObj.sobjectType = 'LoanAppl__c';
        this.imdWrapObj.LoanAppln__c = this._loanAppId;
        if(this.imdWrapObj.PaymentMode__c === 'Payment Gateway'  && this.imdWrapObj.TransAmt__c == null){ //LAK-10325
                this.imdWrapObj.InstrumentAmt__c = this.imdWrapObj.IMDAmt__c;
            }
        let childRecords = [];
        //LAK-8539 --- Removed fields that are readonly before Save
        let IMDRec = this.imdWrapObj;
        console.log('IMDRec outside',JSON.stringify(IMDRec))
        const { IMDStatus__c, PaytmAPIStatus__c,BillDeskAPIStatus__c,PaytmOrderId__c,IntegrationStatus__c,OrderId__c, ...rest } = IMDRec;
        IMDRec = rest;
        console.log('IMDRec inside',JSON.stringify(IMDRec))
        //LAK-8539
        childRecords.push(IMDRec)
        
        validateAmount({ imdRecords : childRecords , loanAppl : this.loanApplObj})
            .then(result => {
                console.log('childRecords',JSON.stringify(childRecords));
                console.log('result:: ',JSON.stringify(result));
                console.log('result.imdWrapObj:: ',JSON.stringify(this.imdWrapObj));
                if (result && result.length > 0) {
                    this.imdWrapObj = { ...this.imdWrapObj, Id: result[0].Id };
                    
                    console.log('Updated this.imdWrapObj:: ', JSON.stringify(this.imdWrapObj));
                }
                if (this.callPaymentGatewayAPI) {
                    this.senLink_MessageAPIMessage()
                }
                if (this.callSequenceAPIFlag && (this.parentWrapObj.FinnoneAppid__c === null || this.parentWrapObj.FinnoneAppid__c === undefined )) {
                    this.sequence_apiCall();
                }else if(this.callSequenceAPIFlag && (this.parentWrapObj.FinnoneAppid__c !== null || this.parentWrapObj.FinnoneAppid__c !== undefined ) ){
                    this.imd_apiCall();
                }
                if(!this.callPaymentGatewayAPI && !this.callSequenceAPIFlag){
                    refreshApex(this.wiredData); 
                }
                this.showToastMessage('Success', this.label.IMD_SUCCESS_Label, 'success', 'sticky')
            })
            .catch(error => {
                console.error('Line no ##1109', error.body.message)
                refreshApex(this.wiredData);
                this.showSpinner = false ;
                this.showToastMessage('Error', error.body.message , 'error', 'sticky');
            })
    }

    ddCheckValidation(){
        let validate = true;
        if(this.imdWrapObj.InstrumentNo__c.length != 6){
            validate = false;
            this.showToastMessage('Error', this.label.IMD_InstrumentNo , 'error', 'sticky');
        }else if (this.imdWrapObj.InstrumentDt__c) {
            if(!this.validateInsDate()){
                validate = false;
                return validate;
            }
            if(this.parentWrapObj.Stage__c === 'QDE'){
                if (this.imdWrapObj.InstrHandvrDateToOps__c) { 
                    if(!this.validateInsHandoverDate()){
                        validate = false;
                    }
                }
            }else if(this.parentWrapObj.Stage__c !== 'QDE'){
                if (this.imdWrapObj.InstrHandvrDateToOps__c) { 
                    if(!this.validateInsHandoverDate()){
                        validate = false;
                    }
                }else{
                    validate = false;
                    this.showToastMessage('Error', this.label.IMD_DateToOps_ErrMsg , 'error', 'sticky');
                }
            }
        }
        return validate;
    }
    IntgMsgFetchDetails;
    handleFetchStatus(){
         this.showSpinner = true;
         let serviceName = '';
         if(this.imdWrapObj.PaymentGateway__c === 'Paytm'){
            serviceName = 'Transaction Status API';
         }
         else{
            serviceName = 'Retrieve Transaction';
         }


                        const fields = {};
                
                        fields[INTEGRATION_MSG_NAME_FIELD.fieldApiName] = serviceName; //'Transaction Status API';
                        fields[BU_FIELD.fieldApiName] = 'HL / STL';
                        fields[REFERENCE_ID_FIELD.fieldApiName] = this.imdWrapObj.Id;
                        fields[STATUS_FIELD.fieldApiName] = 'New';
                        fields[REFERENCE_OBJ_API_FIELD.fieldApiName] = 'ApplIMD__c';
                        fields[SERVICE_NAME_FIELD.fieldApiName] = serviceName; //'Transaction Status API';
                        //fields[API_VENDOR__NAME_FIELD.fieldApiName] = 'Paytm';
                        fields[IS_ACTIVE_FIELD.fieldApiName] = true;
                
                
                        const recordInput = {
                            apiName: INTEGRATION_MSG_OBJECT.objectApiName,
                            fields: fields
                        };
                
                        createRecord(recordInput).then((result) => {
                            this.intMsgId = result.id
                            this.startPollingFetchTrans();
                        }).catch((error) => {
                            console.log('Error ##1025', error)
                            refreshApex(this.wiredData);
                            this.showSpinner = false
                            this.showToastMessage('Error creating Integration record', error.body.message, 'error', 'sticky')
                        });
    }


    lmsUpdateCanbeRun = true;
    bureauCanbeRun = false;
    handleLMSUpdate(event) {
        this.showSpinner = true
        
        if(this.imdWrapObj.PaymentMode__c && (this.imdWrapObj.PaymentMode__c === 'DD' || this.imdWrapObj.PaymentMode__c === 'Cheque')){
            if(!this.ddCheckValidation()) {
                this.showSpinner = false
                return;
            }else{
                this.showSpinner = true
            }
        } 
        if(this.parentWrapObj.SchemeId__c === undefined){
            this.showToastMessage('Error', 'SchemeId not present on the Loan Applicant', 'error', 'sticky');
            this.showSpinner = false;
            return;
        }
        else if (this.imdWrapObj.InstrumentAmt__c && this.imdWrapObj.InstrumentAmt__c < 0) {
            this.showSpinner = false
            this.showToastMessage('Error', this.label.Imd_InstrumentAmt_ErrorMessage, 'error', 'sticky');
            return;
            
        }else if(this.imdWrapObj.InstrumentAmt__c && !this.validateInsAmt()){
            this.showSpinner = false;
            return;
        }      
        else {
            let applicantIds = [];
            for(var i=0; i<this.applicantList.length;i++){
                //collectApplicantIds
                applicantIds.push(this.applicantList[i].Id);
                
            }
            getAPIsToRun({ applicantId: applicantIds})
            .then(result => {
                this.apiList = result; // Store Which API to Run;
                this.intRecords = [];
                for (var i = 0; i < this.apiList.length; i++) {
                    
                    if(this.apiList[i].missingFieldDetails && this.apiList[i].apiName == 'Consumer ACK Request'){
                        this.showToastMessage('Error', this.apiList[i].applicantName+' :'+this.apiList[i].missingFieldDetails, 'error', 'sticky');
                        this.lmsUpdateCanbeRun = this.apiList[i].runlmstoUpdate = null? this.apiList[i].runlmstoUpdate : false;
                        this.showSpinner = false
                        
                    }
                    if(this.apiList[i].runAPI && this.apiList[i].apiName == 'Consumer ACK Request'){
                        this.bureauCanbeRun = true;
                    }
                    //
                    
                    
                    
                }
                if(this.lmsUpdateCanbeRun){
                    this.runLMSUpdate();
                }
                
                
                
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            })
            
            
        }

    }

    handleRefreshClick(){
        this.showSpinner = true;
        refreshApex(this.wiredData);

        setTimeout(() => {
            if (this.imdWrapObj.TransStatus__c === 'Failure') {
                this.disableLink = false;
            }
            this.showSpinner = false;
      }, 3000);
        //refreshApex(this.wiredIMRecord);
    }

    createPytmSMSTsk()
        {
            if(this.imdWrapObj.Id){
                console.log('this.imdWrapObj.Id',this.imdWrapObj.Id)
                //Class createPaytmSMSTask replaced with createSMSTask
                createSMSTask({ referenceId : this.imdWrapObj.Id })
            .then(result => {
                refreshApex(this.wiredData);
            this.showSpinner = false;
            }).catch(error => {
            this.showSpinner = false;
                console.error('Error 824', error)
            })
        }
        }

    @track loanApplObj = {}

    runLMSUpdate(){
        this.parentWrapObj.LMSUpdTrig__c = true;
        this.loanApplObj.LMSUpdTrig__c = true;
        this.callSequenceAPIFlag = true;
        this.handleUpsert();
        this.createAPIIntegMsgs();
    }

    //Added logic to dispaly toast meassage on LMS Update by Gajendra
    imdSuccessToastMessage() {
        const event = new ShowToastEvent({
            title: 'LMS Updated',
            message: 'IMD update to Finnone is successful',
            variant: 'success',
        })
        this.dispatchEvent(event);

    }
    //Added logic to dispaly toast meassage on LMS Update by Gajendra

    imdErrorToastMessage() {
        const event = new ShowToastEvent({
            title: 'LMS failure',
            message: 'IMD update to the Finnone has failed. Kindly try again',
            variant: 'error',
        })
        this.dispatchEvent(event);

    }
    
    applSearch() {
        //LAK-8790
        let intRecArr = []
        if (this.applicantList && this.bureauCanbeRun) {
            this.applicantList.forEach(item => {
                let Obj = {}
                Obj.BU__c = 'HL / STL';
                Obj.RefId__c = item.Id;
                Obj.RefObj__c = 'Applicant__c';
                Obj.Status__c = 'New';
                Obj.ParentRefObj__c = 'LoanAppl__c';
                Obj.ParentRefId__c = this.loanAppId;
                Obj.IsActive__c = true;
                Obj.sobjectType = 'IntgMsg__c';
                Obj.TriggerType__c = 'System';
                if (item.Constitution__c === 'INDIVIDUAL') {
                    Obj.Name = 'Consumer ACK Request';
                    Obj.Svc__c = 'Consumer ACK Request';
                    intRecArr.push(Obj);
                } 
            }
            )
            if (intRecArr.length > 0) {
                upsertMultipleRecord({ params: intRecArr })
                    .then(result => {
                    }).catch(error => {
                        console.error('Error 824', error)
                    })
            }
        }else if ( this.lmsUpdateCanbeRun && !this.bureauCanbeRun){
            let Obj = {}
            Obj.BU__c = 'HL / STL';
            Obj.RefId__c = this.loanAppId;
            Obj.RefObj__c = 'LoanAppl__c';
            Obj.Status__c = 'New';
            Obj.ParentRefObj__c = 'LoanAppl__c';
            Obj.ParentRefId__c = this.loanAppId;
            Obj.IsActive__c = true;
            Obj.sobjectType = 'IntgMsg__c';
            Obj.TriggerType__c = 'System';
            Obj.Name = 'Crif Auth Login';
            Obj.Svc__c = 'Crif Auth Login';
            Obj.ApiVendor__c=  'Crif'
            intRecArr.push(Obj);
            
        
        
        if (intRecArr.length > 0) {
            upsertMultipleRecord({ params: intRecArr })
                .then(result => {
                }).catch(error => {
                    console.error('Error 824', error)
                })
        }

        }
        
    }


    reqCall_consumer_commercial() {
        this.applSearch();
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

    createAPIIntegMsgs() {
        const fields = {};

        fields[INTEGRATION_MSG_NAME_FIELD.fieldApiName] = 'Dedupe API Token';
        fields[STATUS_FIELD.fieldApiName] = 'New';
        fields[SERVICE_NAME_FIELD.fieldApiName] = 'Dedupe API Token';
        fields[BU_FIELD.fieldApiName] = 'HL / STL';
        fields[IS_ACTIVE_FIELD.fieldApiName] = true;
        fields[REFERENCE_ID_FIELD.fieldApiName] = this._loanAppId;
        fields[REFERENCE_OBJ_API_FIELD.fieldApiName] = 'LoanAppl__c';

        const recordInput = {
            apiName: INTEGRATION_MSG_OBJECT.objectApiName,
            fields: fields
        };

        createRecord(recordInput).then((result) => {
        }).catch((error) => {
            refreshApex(this.wiredData);
            this.showSpinner = false
        });
    }

    handleUploadDoc(event) {
       // this.startSpinner();
        if (event.detail) {
            this.showSpinner = true;
            this.uploadDocData = event.detail
            this.imdWrapObj.DocDetail__c = this.uploadDocData.docDetailId;
            let contentVersionId = this.uploadDocData.uploadedFileId[0];
            const fields = {};
            fields[DOCDETAILID_FIELD.fieldApiName] = this.imdWrapObj.DocDetail__c;
            fields[DOCDETAILCONTENTDOCUMENTID_FIELD.fieldApiName] = contentVersionId;
            const recordInput = { fields };
            this.handleUpsert();
            updateRecord(recordInput)
                .then((result) => {
                    //this.stopSpinner();
                })
                .catch(error => {
                    this.showToast("Error", "error", this.label.Imd_DocDetails_ErrorMessage + error);
                    this.showSpinner = false;
                    console.log(error);
                    //this.stopSpinner();
                });

        }

    }

    stopSpinner() {
        let child = this.template.querySelector('c-upload-docs-reusable-component');
        child.spinnerStatus(false);

    }
    //Added for LAK-8443
    startSpinner() {
        let child = this.template.querySelector('c-upload-docs-reusable-component');
        child.spinnerStatus(true);

    }

    spinnerStatus(event) {
        console.log('spinner value ', event.detail);
        this.showSpinner = event.detail;
    }

    @track _documentDetailId;

    handleDocumentDelete(event) {
        this.isShowModal = true;
        let documentDetailRecord = this._documentDetail[event.target.dataset.index];
        this._documentDetailId = documentDetailRecord.DocDetail__c;
    }

    @track documentDetailId
    @track contVersDataList;
    @track hasDocumentId=false
    @track showModalForFilePreBouncedIMD = false;

    handleDocumentViewBouncedIMD(event) {
        let docIdName = this.bouncedIMDArr[event.target.dataset.index];
        if(docIdName.DocDetail__r){
            this.docccId = docIdName.DocDetail__r.Id;
        }
        this.hasDocumentId=true
        this.showModalForFilePreBouncedIMD = true;
    }

    @track docccId;
    handleDocumentView(event) {
        this.hasDocumentId=true
        this.showModalForFilePre = true;

    }
    handleCloseModalEvent(event) {
        this.showModalForFilePre = false;
        this.showModalForFilePreBouncedIMD = false;
    }


    @track intMsgId = ''
    chequeInterval;
    chequeInterval1;
    @track ImessageFields = [STATUS_FIELD, INTEGRATION_MSG_NAME_FIELD, RESPONSE_PAYLOAD_FIELD, API_STATUS_FIELD];
    @track responded = true;
    wiredIMRecord;

    @track counter1;
    startPollingFetchTrans() {
        this.counter1 = 0;
        this.chequeInterval1 = setInterval(() => {
            this.counter1 += 5;
            this.waitForImdStatus();
        }, 5000);
    }
    waitForImdStatus(){
        try {
            if (this.counter1 === 10) {
                refreshApex(this.wiredData);
                refreshApex(this.wiredIMRecord)
               
                console.log('inside StartPolling',this.imdWrapObj.TransStatus__c)
                console.log('inside StartPolling',this.imdWrapObj.PaytmAPIStatus__c)
                // this.showSpinner = false;
                // clearInterval(this.chequeInterval1);

            }
            if(counter1 ===5){
                refreshApex(this.wiredData);
            }
            //this.showSpinner = false
        } catch (e) {
            console.log(e);
        }
    }


    startPolling() {
        this.counter = 0;
        this.chequeInterval = setInterval(() => {
            this.counter += 5;
            this.waitForChequeResponse();
        }, 5000);
    }
    waitForChequeResponse() {
        try {
            refreshApex(this.wiredIMRecord)
            if (this.counter === 60 && !this.imdWrapObj.FinnoneChequeId__c) {
                //this.showToastMessage('Error', this.label.LMS_update_Fail_MSG, 'error', 'sticky');//added by Gajendra for LAK-3124
                this.showSpinner = false
                clearInterval(this.chequeInterval);

            }
            //this.showSpinner = false
        } catch (e) {
            console.log(e);
        }

    }

    @wire(getRecord, { recordId: '$intMsgId', fields: '$ImessageFields' })
    loadIM(result) {
        this.wiredIMRecord = result
        if (result.error) {
            this.showSpinner = false
        } else if (result.data) {
            //refreshApex(this.wiredData);
        if(result.data.fields.Status__c.value === 'Responded' && (result.data.fields.Name.value === 'Transaction Status API' || result.data.fields.Name.value === 'Retrieve Transaction')){
           refreshApex(this.wiredData);
            if(this.imdWrapObj.TransStatus__c === 'Success'){
                this.showToastMessage('Success', 'Transaction is Successful.', 'Success', 'sticky');
            }
            else if(this.imdWrapObj.TransStatus__c === 'Pending'){
                if(this.imdWrapObj.PaytmErrMess__c && result.data.fields.Name.value === 'Transaction Status API'){
                    this.showToastMessage('Info',this.imdWrapObj.PaytmErrMess__c, 'info', 'sticky');
                }
                else if(this.imdWrapObj.BillDeskAPIErrorMessage__c){
                    this.showToastMessage('Info',this.imdWrapObj.BillDeskAPIErrorMessage__c, 'info', 'sticky');
                }
            }
            else{
                this.showToastMessage('Error', 'Transaction is Failed.', 'error', 'sticky');
            }
            this.showSpinner = false
            clearInterval(this.chequeInterval1);
        }
        //result.data.fields.Name.value === 'Billdesk' added for Bill Desk api
            if (result.data.fields.Status__c.value === 'Responded' && (result.data.fields.Name.value === 'Paytm' || result.data.fields.Name.value === 'Billdesk')) {
                
                this.showSpinner = false
                clearInterval(this.chequeInterval);
                refreshApex(this.wiredData);
                if (this.imdWrapObj.TransStatus__c === 'Failure') {
                    this.disableLink = false;
                    this.showToastMessage('Error', this.label.Imd_Payment_ErrorMessage, 'error', 'sticky');
                } else if (this.imdWrapObj.TransStatus__c === 'Success') {
                    this.showToastMessage('Success', this.label.Imd_Payment_SuccessMessage, 'success', 'sticky');
                }
            }
            if (result.data.fields.Status__c.value === 'Responded' && result.data.fields.Name.value === 'Sequence API') {
                clearInterval(this.chequeInterval);
                this.imd_apiCall();
                this.reqCall_consumer_commercial();
            }
            if (result.data.fields.Status__c.value === 'Responded' && result.data.fields.Name.value === 'IMD') {
                let status = result.data.fields.APIStatus__c.value;
                if (status === 'Failure') {
                    this.imdErrorToastMessage();
                    refreshApex(this.wiredData);
                    this.showSpinner = false
                } else {
                    this.imdSuccessToastMessage();
                    clearInterval(this.chequeInterval);
                    refreshApex(this.wiredData);
                    this.showSpinner = false
                }
            }
        }
    }

    //used to create integration record for 'Check' Payment mode
    createIntegration_sendLink() {
        this.showSpinner = true
        this.callPaymentGatewayAPI = true;
        this.handleUpsert();
    }


    isLessThanTodayPaytmLink =false;
    isLessThanTodayBillLink =false;
    senLink_MessageAPIMessage() {
        console.log('this.imdWrapObj.Id:: ',JSON.stringify(this.imdWrapObj));
        if(this.imdWrapObj.PaytmLinkExpiryDate__c != null || this.imdWrapObj.PaytmLinkExpiryDate__c != undefined){
            const dateToCompare = new Date(this.imdWrapObj.PaytmLinkExpiryDate__c);
            const today = new Date();
            this.isLessThanTodayPaytmLink = today < dateToCompare;
            console.log('isLessThanTodayPaytmLink',this.isLessThanTodayPaytmLink);
        }
        if(this.imdWrapObj.BillDeskLinkExpiryDate__c != null || this.imdWrapObj.BillDeskLinkExpiryDate__c != undefined){
            const dateToCompare = new Date(this.imdWrapObj.BillDeskLinkExpiryDate__c);
            const today = new Date();
            this.isLessThanTodayBillLink = today < dateToCompare;
            console.log('isLessThanTodayBillLink',this.isLessThanTodayBillLink);
        }
        if(this.imdWrapObj.TransStatus__c != 'Failure' && this.imdWrapObj.PaytmAPIStatus__c === 'Success' && this.isLessThanTodayPaytmLink === true && this.imdWrapObj.PaymentGateway__c === 'Paytm'){
            refreshApex(this.wiredData);
            this.createPytmSMSTsk();
        this.callPaymentGatewayAPI = false;
        }
        else if(this.imdWrapObj.TransStatus__c != 'Failure' && this.imdWrapObj.BillDeskAPIStatus__c === 'Success' && this.isLessThanTodayBillLink === true && this.imdWrapObj.PaymentGateway__c === 'Billdesk'){
            refreshApex(this.wiredData);
            this.createPytmSMSTsk();
        this.callPaymentGatewayAPI = false;
        }
        else{
        this.callPaymentGatewayAPI = false;
        //Added for Bill Desk APi
        let serviceName;
        if (this.imdWrapObj.PaymentGateway__c && this.imdWrapObj.PaymentGateway__c === 'Paytm') {
            serviceName = 'Paytm';
        } else if (this.imdWrapObj.PaymentGateway__c && this.imdWrapObj.PaymentGateway__c === 'Billdesk') {
            serviceName = 'Payment Gateway';//Bill Desk replaced with Payment Gateway
        }
         //Ended changes for Bill Desk APi
        const fields = {};

        fields[INTEGRATION_MSG_NAME_FIELD.fieldApiName] = serviceName;
        fields[STATUS_FIELD.fieldApiName] = 'New';
        fields[SERVICE_NAME_FIELD.fieldApiName] = serviceName;
        fields[BU_FIELD.fieldApiName] = 'HL / STL';
        fields[IS_ACTIVE_FIELD.fieldApiName] = true;
        fields[REFERENCE_ID_FIELD.fieldApiName] = this.imdWrapObj.Id;
        fields[REFERENCE_OBJ_API_FIELD.fieldApiName] = 'ApplIMD__c';
        
        const recordInput = {
            apiName: INTEGRATION_MSG_OBJECT.objectApiName,
            fields: fields
        };

        createRecord(recordInput).then((result) => {
            this.intMsgId = result.id
            this.startPolling();
        }).catch((error) => {
            this.showSpinner = false;
            refreshApex(this.wiredData);
            console.log('Error ##789', error)
            this.showToastMessage('Error creating Integration record', error.body.message, 'error', 'sticky')
        });
    }
    }

    sequence_apiCall() {
        const fields = {};

        fields[INTEGRATION_MSG_NAME_FIELD.fieldApiName] = 'Sequence API';
        fields[STATUS_FIELD.fieldApiName] = 'New';
        fields[SERVICE_NAME_FIELD.fieldApiName] = 'Sequence API';
        fields[BU_FIELD.fieldApiName] = 'HL / STL';
        fields[IS_ACTIVE_FIELD.fieldApiName] = true;
        fields[REFERENCE_ID_FIELD.fieldApiName] = this._loanAppId;
        fields[REFERENCE_OBJ_API_FIELD.fieldApiName] = 'LoanAppl__c';
    
        const recordInput = {
            apiName: INTEGRATION_MSG_OBJECT.objectApiName,
            fields: fields
        };

        createRecord(recordInput).then((result) => {
            this.intMsgId = result.id
            this.startPolling();
            //LAK-9245 - Duplicate IMD Request
            this.callSequenceAPIFlag = false;
        })
        .catch((error) => {
            console.log('Error ##990', error)
            refreshApex(this.wiredData);
            this.showSpinner = false
            this.showToastMessage('Error creating Integration record', error.body.message, 'error', 'sticky')
        });

    }

    imd_apiCall() {
        const fields = {};

        fields[INTEGRATION_MSG_NAME_FIELD.fieldApiName] = 'IMD';
        fields[BU_FIELD.fieldApiName] = 'HL / STL';
        fields[REFERENCE_ID_FIELD.fieldApiName] = this.imdWrapObj.Id;
        fields[STATUS_FIELD.fieldApiName] = 'New';
        fields[REFERENCE_OBJ_API_FIELD.fieldApiName] = 'ApplIMD__c';
        fields[SERVICE_NAME_FIELD.fieldApiName] = 'IMD';
        fields[PARENT_REFERENCE_ID_FIELD.fieldApiName] = this._loanAppId;
        fields[PARENT_REFERENCE_OBJ_API_FIELD.fieldApiName] = 'LoanAppl__c';
        fields[IS_ACTIVE_FIELD.fieldApiName] = true;


        const recordInput = {
            apiName: INTEGRATION_MSG_OBJECT.objectApiName,
            fields: fields
        };

        createRecord(recordInput).then((result) => {
            this.intMsgId = result.id
            this.startPolling();
            //LAK-9245 - Duplicate IMD Request
            this.callSequenceAPIFlag = false;
        }).catch((error) => {
            console.log('Error ##1025', error)
            refreshApex(this.wiredData);
            this.showSpinner = false
            this.showToastMessage('Error creating Integration record', error.body.message, 'error', 'sticky')
        });

    }

    open_Modal() {
        this.showSpinner = true;
        try {
            deleteRecord(this._documentDetailId)
                .then(() => {
                    this.showToastMessage('Success', this.label.Imd_Del_SuccessMessage, 'success', 'sticky');
                    refreshApex(this.wiredData);
                    this.showSpinner = false;
                    this.isShowModal = false;
                })
                .catch((error) => {

                });
        } catch (e) {
            console.error('Error 1143', e)
        }
    }

    closeModal() {
        this.isShowModal = false;
    }

    //// Code for Charges starts from here ////

    @track activeSection = ["A", "B"];



    @track records = [];
    @track initialLoad_Arr = [];

    @track loanApplCharges_Obj = {
    };

    handleLoanRecordIdChange() {
        let tempParams = this.params_loanAppCharge;
        tempParams.queryCriteria = ' where Id = \'' + this._loanAppId + '\' limit 1';
        this.params_loanAppCharge = { ...tempParams };

    }

    //parameter to find the loan application charge data
    @track
    params_loanAppCharge = {
        ParentObjectName: 'LoanAppl__c',
        ChildObjectRelName: 'Loan_Application_Charges__r',
        parentObjFields: ['Id'],
        childObjFields: ['Id', 'Amount__c', 'ChargeCodeDesc__c', 'ChargeCodeID__c', 'LoanApplication__c', 'Remark__c', 'ChargeCodeDesID__c', 'ActualAmt__c', 'GST_Amount__c','EffeChrgeAmt__c','CreatedDate'],
        queryCriteria: ' '
    }

    @track initialLoad_Arr_tempArray = []; 
    @track records_tempArray = [];
    @track wiredTableData = []

    handleLoanAppChargeResponse() {
        getSobjectDataWithoutCacheable({params: this.params_loanAppCharge }).then((result) => {
            if (result) {
                this.wiredTableData = result
                this.isChargeChanged = false;
                this.wiredLoanAppChargeData = result[0].ChildReords
                if (result[0].ChildReords != undefined && result[0].ChildReords.length > 0) {
                    this.initialLoad_Arr_tempArray = [];
                    this.records_tempArray = [];
                    this.initialLoad_Arr = [];
                    this.records = []
                    result[0].ChildReords.forEach(item => {
                        let Obj = {}
                        Obj.Id = item.Id;
                        Obj.Remark__c = item.Remark__c;
                        Obj.ChargeCodeID__c= item.ChargeCodeID__c;
                        Obj.ChargeCodeDesc__c = item.ChargeCodeDesc__c;
                        Obj.ChargeCodeDesID__c = item.ChargeCodeDesID__c;
                        Obj.LoanApplication__c = item.LoanApplication__c;
                        Obj.Amount__c = item.EffeChrgeAmt__c;
                        Obj.CreatedDate = item.CreatedDate;
                        if (item.ChargeCodeDesc__c === 'CERSAI CHARGES' || item.ChargeCodeDesc__c === 'PF RECD FRM CUST-IRR-NDED' || item.ChargeCodeDesc__c === 'Pre EMI charges') {
                            this.initialLoad_Arr_tempArray = [...this.initialLoad_Arr_tempArray, Obj];
                        } else {
                            this.records_tempArray = [...this.records_tempArray, Obj];
                        }
    
                    });
                    this.initialLoad_Arr = [...this.initialLoad_Arr_tempArray];
                    this.initialLoad_Arr.sort((a, b) => new Date(b.CreatedDate) - new Date(a.CreatedDate));
                    this.records = [...this.records_tempArray];
                
                    this.records.forEach(item =>{
                        if(item.Amount__c !== null || item.Amount__c !== undefined){
                            item.Amount__c = this.customRoundCall(item.Amount__c);
                        }
                    })
                    this.calculateTotalAmount([...this.records,...this.initialLoad_Arr]);
                    this.calculate_TotalAmount();
                }
                this.showSpinner = false;
            }
          })
          .catch((error) => {
            this.showSpinner = false;
            console.error('error ##1530',error);
          });
      }

      @wire(getSobjectDatawithRelatedRecords, { params: '$params_loanAppCharge' })
      handleLoanAppChargeResponseWire(result) {
          if (result.data) {
            this.handleLoanAppChargeResponse();
          }
          if (result.error) {
              console.error(result.error);
          }
      }


    @track _applicantId;
    @api get applicantId() {
        return this._applicantId;
    }
    set applicantId(value) {
        this._applicantId = value;
        this.setAttribute("applicantId", value);

        this.handleRecordIdChange(value);
    }

    handleRecordIdChange() {
        let tempParams = this.assetParams;
        tempParams.queryCriteria = ' where Appl__c = \'' + this._applicantId + '\' ';
        this.assetParams = { ...tempParams };
    }

    @track
    assetParams = {
        ParentObjectName: 'ApplAsset__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'Appl__c', 'LoanAppln__c', 'Appl__r.TabName__c',
            'AddrLn1__c', 'AddrLn2__c', 'City__c', 'Pin_Code__c', 'Appl__r.PhoneNumber__c', 'PropType__c', 'PropSubType__c',
            'CityId__c', 'PinId__c', 'StateId__c', 'Prop_Sub_TyId__c'],
        childObjFields: [],
        queryCriteria: ''
    }

    @track propertyLength
    @track initialAmount = 0;
    @track assetWiredData;


    calculateTotalAmount(objArr) {
        this.totalAmt = 0
        let sum = 0
        let tempObj = objArr.reduce(function (acc, curr) {
            return { "Amount__c": parseInt(acc.Amount__c) + parseInt(curr.Amount__c) };
        }, { "Amount__c": 0 })

        this.totalAmt += tempObj.Amount__c;
        sum = this.totalAmt

        return sum
    }
    
    calculate_TotalAmount() {
        this._totalAmt = this.totalAmt - this.parentWrapObj.TotalIMDAmount__c;
    }

    @track finalArr = []
    addRow() {
        let numberOfRec = this.records.length;
        let myNewElement = {
            ChargeCodeDesID__c: "",
            ChargeCodeDesc__c: "",
            Remark__c: "",
            Amount__c: "",
            LoanApplication__c: this.loanAppId,
        };
        let deviaDa = [...this.records, myNewElement];
        this.records = deviaDa;
    }

    @track isShowChargeModal = false;
    @track deleteChargeRecId;
    @track currTarIndex;
    handleDeleteAction(event) {
        this.isShowChargeModal = true ;
        this.currTarIndex = event.currentTarget.dataset.index ;
        this.deleteChargeRecId = event.target.dataset.id;

    }

    delete_ChargeRecHandler() {
        this.showSpinner = true;
        if (this.deleteChargeRecId !== undefined) {
            if(this.deleteChargeRecId.length == 18) {
                this.records.splice(this.currTarIndex, 1);
                this.handleDeleteRecId(this.deleteChargeRecId);
            }
        }else{
            this.records.splice(this.currTarIndex, 1);
            this.showSpinner = false;
            this.isShowChargeModal = false;
            this.calculateTotalAmount([...this.records,...this.initialLoad_Arr]);
			this.calculate_TotalAmount();
        }
    }

    closeChargeModal() {
        this.isShowChargeModal = false;
        this.showSpinner = false;
    }


    @track ChargeCodeDescValue
    @track totalAmt = 0
    @track _totalAmt = 0
    @track lookupRec
    @track index
    @track isReadOnlyCondition = false;
    @track deleteBttnVisibile = false;
    @track isChargeChanged = false;
    @track filterCondition = 'Type__c = \'Charge Master\'';

    handleBlur(event) {
        if(event.target.label === 'Remarks'){
            let loanAppCharges = { ...this.records[event.target.dataset.index] }
            loanAppCharges[event.target.dataset.name] = event.target.value.toUpperCase();
            this.records[event.target.dataset.index] = loanAppCharges;
        }
        if(event.target.label === 'Amount mentioned on instrument'){
            this.validateInsAmt()
        }
    }

    handleInputChange(event) {
        if (this.parentWrapObj.Stage__c != 'QDE') {
            try {
                this.isChargeChanged = true
                let loanAppCharges = { ...this.records[event.target.dataset.index] }
                loanAppCharges[event.target.dataset.name] = event.target.value;
                this.records[event.target.dataset.index] = loanAppCharges;
                if (event.target.dataset.name === 'Amount__c') { 
                    if (event.target.value) {
                        this.records[event.target.dataset.index].Amount__c = this.customRoundCall(this.records[event.target.dataset.index].Amount__c);
                    }
                }

                this.records.forEach(item => {
                    if (item.Amount__c == "") {
                        item.Amount__c = 0
                    }
                })

                if (event.target.label === 'Amount') {
                    this.totalAmt = 0
                    let finalTempArr = [...this.initialLoad_Arr, ...this.records];
                    this.totalAmt = this.calculateTotalAmount(finalTempArr);
                    this.calculate_TotalAmount();
                }
            } catch (e) {
                console.error('Error1318', e)
            }
        }
    }

    handleValueSelect(event) {
        if (this.parentWrapObj.Stage__c != 'QDE') {
            this.isChargeChanged = true
            this.lookupRec = event.detail;
            let lookupId = this.lookupRec.id;
            let lookupAPIName = this.lookupRec.lookupFieldAPIName;
            const outputObj = { [lookupAPIName]: lookupId };
            if (event.target.fieldName === 'ChargeCodeDesc__c') {
                if (this.duplicateChargeCheck(lookupId, this.lookupRec.mainField)) {
                    this.showToastMessage('Error', this.label.Imd_Charge_ErrorMessage, 'error', 'sticky');
                }
                this.index = event.target.index
                let objArr = {}
                this.ChargeCodeDescValue = this.lookupRec.mainField
                this.records[this.index].ChargeCodeDesc__c = this.lookupRec.mainField;
                this.records[this.index].ChargeCodeDesID__c = lookupId;
                this.searchChargeCodeId(lookupId);
            }
        }
    }

    duplicateChargeCheck(lookupId, label) {
        let isDupliacte = false
        let filteredInitArray = this.initialLoad_Arr.filter(item => {
            return item.ChargeCodeDesc__c === label
        })
        let filteredRecordArray = this.records.filter(item => {
            return item.ChargeCodeDesID__c === lookupId
        })
        if (filteredRecordArray.length > 0 || filteredInitArray.length > 0) {
            isDupliacte = true
        }
        return isDupliacte
    }

    @track
    chargeCodeIdParamerters = {
        ParentObjectName: 'MasterData__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'SalesforceCode__c', 'Name', 'FinnoneCode__c', 'Type__c','ChargeID__c'],
        childObjFields: [],
        queryCriteria: ' '
    }

    searchChargeCodeId(chargeCodeId) {
        let type = 'Charge Master'
        this.chargeCodeIdParamerters.queryCriteria = ' where Id = \'' + chargeCodeId + '\'' + ' AND Type__c = \'' + type + '\''
        getSobjectData({ params: this.chargeCodeIdParamerters })
            .then((result) => {
                if (result.parentRecords) {
                    this.records[this.index].ChargeCodeDesID__c = result.parentRecords[0].ChargeID__c;
                    this.records[this.index].ChargeCodeID__c = result.parentRecords[0].FinnoneCode__c;
                }
            })
            .catch((error) => {
                console.error('Error in line ##1235', error)
            })
    }

    customRoundCall(number) {
        let roundedNumber = Math.round(number);
        
        return roundedNumber;
    }

    pfValue = 'PF'
    @track pfAmount = 0



    @track wiredLoanAppChargeData = {}
    @track refreshTable

    createLoanApplications_Charge() {
        if (this.handleChargeAmt_validity()) {
            try {
                this.showSpinner = true;

                this.finalArr = [...this.records]

                let chargesArray = [];
                let chargeObj = {};

                if(this.finalArr && this.finalArr.length > 0){
                    for (var i = 0; i < this.finalArr.length; i++) {
                        chargeObj = {};
                        chargeObj.sobjectType = 'LonaApplCharges__c',
                            chargeObj.ChargeCodeDesID__c = this.finalArr[i].ChargeCodeDesID__c,
                            chargeObj.ChargeCodeDesc__c = this.finalArr[i].ChargeCodeDesc__c,
                            chargeObj.Remark__c = this.finalArr[i].Remark__c,
                            chargeObj.Amount__c = this.finalArr[i].Amount__c,
                            chargeObj.ActualAmt__c = this.finalArr[i].ActualAmt__c,
                            chargeObj.GST_Amount__c = this.finalArr[i].GST_Amount__c,
                            chargeObj.ChargeType__c = 'Charge',
                            chargeObj.LoanApplication__c = this._loanAppId,
                            chargeObj.ChargeCodeID__c = this.finalArr[i].ChargeCodeID__c,
                            chargeObj.Id = this.finalArr[i].Id;
                        chargeObj.Processing_Fees__c = this.finalArr[i].Processing_Fees__c;
                        chargesArray.push(chargeObj);
                    }
                }

                if(chargesArray && chargesArray.length > 0){
                    let valueArr = chargesArray.map(function (item) { return item.ChargeCodeDesc__c });
                    let isDuplicate = valueArr.some(function (item, idx) {
                        return valueArr.indexOf(item) != idx
                    });
                    if (isDuplicate == true) {
                        this.showToastMessage('Error', this.label.Imd_DuplicateCharge_ErrorMessage, 'error', 'sticky');
                        this.showSpinner = false;
                    } else {
                        let upsertData = {
                            parentRecord: { "Id": this._loanAppId },
                            ChildRecords: chargesArray,
                            ParentFieldNameToUpdate: 'LoanApplication__c'
                        }

                        upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
                            .then(result => {
                                this.refreshTable = result
                                this.handleLoanAppChargeResponse();                          
                                this.showToastMessage('Success', this.label.Imd_Charges_SuccessMessage, 'success', 'sticky')
                            })
                            .catch(error => {
                                this.showSpinner = false;
                                console.error('Line no ##1542', error)
                            })

                    }
                }

            } catch (e) {
                this.showSpinner = false;
                console.error('Final Error', e)
            }
        }
    }
    @track del_recIds = []
    handleDeleteRecId(delRecId) {
        let fields = {};
        fields['Id'] = delRecId
        this.del_recIds = []
        this.del_recIds.push(fields)
        deleteRecord_Charges({ rcrds: this.del_recIds }).then((result) => {
            this.showToastMessage('Success', this.label.IMD_Charge_DeleteMessage, 'success', 'sticky');
            refreshApex(this.assetWiredData);
            refreshApex(this.wiredTableData);
            this.calculateTotalAmount([...this.records,...this.initialLoad_Arr]);
			this.calculate_TotalAmount();
            this.showSpinner = false;
            this.isShowChargeModal = false;
        })
        .catch((error) => {
            console.error('error ##2090',error);
        });
    }

    handleChargeAmt_validity() {
        let valid = true;
        this.records.forEach(item => {
            if (item.Amount__c === '' || item.Amount__c === undefined) {
                this.showToastMessage('Error', this.label.Imd_Amount_ErrorMessage, 'error', 'sticky');
                item.Amount__c.setCustomValidity('Please complete this field.')
                item.Amount__c.reportValidity();
                valid = false
            } else {
                valid = true
            }
        })
        this.records.forEach(item => {
            if (parseInt(item.Amount__c) > 0) {
                valid = true
            } else {
                valid = false;
                this.showToastMessage('Error', this.label.Imd_PositiveVal_ErrorMessage, 'error', 'sticky');
                item.Amount__c.setCustomValidity("Please enter only positive values");
                item.Amount__c.reportValidity();
            }
        })
        return valid
    }   

}