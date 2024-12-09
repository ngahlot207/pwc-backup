import { LightningElement, api, track, wire } from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from "lightning/uiRecordApi";
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import AppStage from "@salesforce/schema/LoanAppl__c.Stage__c";
import AppSubstage from "@salesforce/schema/LoanAppl__c.SubStage__c";
import ProductType from "@salesforce/schema/LoanAppl__c.Product__c";
import getSobjectDat from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import generateDocument from "@salesforce/apex/GeneratePDFandAttachToLoanApplication.generateDocument";
import createDocumentDetail from "@salesforce/apex/DocumentDetailController.createDocumentDetail";
import disbursementMemo from '@salesforce/label/c.PageURLDisbusementMemo';
import UserNameFIELD from '@salesforce/schema/User.Name';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import checkExpiry from "@salesforce/apex/VerificationExpiryController.checkExpiry";
import { RefreshEvent } from 'lightning/refresh';
import PICKLIST_FIELD from '@salesforce/schema/DocDtl__c.Appr_Actn__c';
import { subscribe, publish, MessageContext, unsubscribe, releaseMessageContext, createMessageContext } from 'lightning/messageService';
import getSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords'
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import DOCUMENT_DETAIL_OBJECT from "@salesforce/schema/DocDtl__c";
import DEVIATION_OBJECT from "@salesforce/schema/Deviation__c";
import DEV_PICKLIST_FIELD from '@salesforce/schema/Deviation__c.Appr_Actn__c';

// Custom labels
import ApprovalTray_Authority_ErrorMessage from '@salesforce/label/c.ApprovalTray_Authority_ErrorMessage';
import ApprovalTray_Authority_SuccesMessage from '@salesforce/label/c.ApprovalTray_Authority_SuccesMessage';
import ApprovalTray_LAN_Update_ErrorMessage from '@salesforce/label/c.ApprovalTray_LAN_Update_ErrorMessage';
import ApprovalTray_Forward_SuccesMessage from '@salesforce/label/c.ApprovalTray_Forward_SuccesMessage';
import ApprovalTray_ForwardLAN_Update_ErrorMessage from '@salesforce/label/c.ApprovalTray_ForwardLAN_Update_ErrorMessage';
import ApprovalTray_SendToCPA_SuccesMessage from '@salesforce/label/c.ApprovalTray_SendToCPA_SuccesMessage';
import ApprovalTray_Remarks_Update_ErrorMessage from '@salesforce/label/c.ApprovalTray_Remarks_Update_ErrorMessage';
import ApprovalTray_CreateDoc_ErrorMessage from '@salesforce/label/c.ApprovalTray_CreateDoc_ErrorMessage';
import ApprovalTray_GenDoc_ErrorMessage from '@salesforce/label/c.ApprovalTray_GenDoc_ErrorMessage';
import ForwardToUW_RemarkError from '@salesforce/label/c.ForwardToUW_RemarkError';
import Send_to_Oops_BRE_Error_Message from '@salesforce/label/c.Send_to_Oops_BRE_Error_Message';
import PageURLCAMReporrt from '@salesforce/label/c.PageURLCAMReporrt';
//LAK-8001
import { getDeviationColumns, getPostdeviationColumns, getcreditdeviationColumns,getEDeviationColumns, getEPostdeviationColumns, getEcreditdeviationColumns } from './approvalTrayHelper';

export default class ApprovalTray extends NavigationMixin(LightningElement) {
    Customlabel = {
        ApprovalTray_Authority_ErrorMessage,
        ApprovalTray_Authority_SuccesMessage,
        ApprovalTray_LAN_Update_ErrorMessage,
        ApprovalTray_Forward_SuccesMessage,
        ApprovalTray_ForwardLAN_Update_ErrorMessage,
        ApprovalTray_SendToCPA_SuccesMessage,
        ApprovalTray_Remarks_Update_ErrorMessage,
        ApprovalTray_CreateDoc_ErrorMessage,
        ApprovalTray_GenDoc_ErrorMessage,
        ForwardToUW_RemarkError,
        Send_to_Oops_BRE_Error_Message

    }
    saveSubscription = null;
    @wire(MessageContext)
    MessageContext;

    @track showFalse = false;
    @track showTrue = true;
    @track currentDateTime;
    @track currentUserName;
    @track ForwardToUserName;
    @api objectApiName = 'LoanAppl__c';
    @track showSpinner = false;
    @track userId = Id;
    @api hasEditAccess;
    @track isReadOnly = false;
    @track loanApplicationRecord = [];
    @track showDocList = true;
    @track pickListOptions;
    @track isDisabledRow;
    
    @track contDocType;
    @track contDocId;
    @track cvId;
    @track listOfConVerDocIds = [];
    @track isOpenModal = false;
    @track isShowPopup = false;
    @track isShowModal = false;
    @track apprAllDevi = false
    docType = ['CAM Report'];
    subType = ['CAM Report'];
    docCategory = ['CAM Report'];
    opsPoolId;
    lookupId;
    emprole = 'UW';
    acmrole = 'ACM';
    rcmrole = 'RCM';
    zcmrole = 'ZCM';
    ncmrole = 'NCM';
    chrole = 'CH';
    updatedColumns;
    deviationColumns;
    PostdeviationColumns;
    creditdeviationColumns;//LAK-8001
    approvalActionOptions = [];
    disbursementMemoType = ['Disbursement Memo'];
    disbursementMemoSubType = ['Disbursement Memo'];
    disbursementMemoCategory = ['Disbursement Memo'];
    filterConditionForLookup = 'EmpRole__c IN(\'' + this.emprole + '\',\'' + this.chrole + '\',\'' + this.acmrole + '\',\'' + this.rcmrole + '\',\'' + this.zcmrole + '\',\'' + this.ncmrole + '\') ' + 'AND Employee__c != \'' + this.userId + '\''
    label = {
        disbursementMemo
    };

    @wire(getRecord, { recordId: Id, fields: [UserNameFIELD] })
    currentUserInfo({ error, data }) {
        if (data) {
            console.log('currentUserInfo ', data);
            console.table(data);
            this.currentUserName = data.fields.Name.value;
        } else if (error) {
            this.error = error;
        }
    }


    // For Document Records
    @wire(getObjectInfo, {
        objectApiName: DOCUMENT_DETAIL_OBJECT
    })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: PICKLIST_FIELD
    })
    wirePickList({ data, error }) {
        if (data) {
            this.approvalActionOptions = data.values;
        } else if (error) {
            console.log("Error while loading data", error);
        }
    }
    // FOR Deviation Records
    @wire(getObjectInfo, {
        objectApiName: DEVIATION_OBJECT
    })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: DEV_PICKLIST_FIELD
    })
    wirePickList({ data, error }) {
        if (data) {
            this.approvalActionOptions = data.values;
        } else if (error) {
            console.log("Error while loading data", error);
        }
    }
    // Method to get Current Date & Time
    updateCurrentDateTime() {
        let d = new Date();
        let newD = new Date(d.getTime());
        this.currentDateTime = newD.toISOString();
        console.log('currentDateTime===', this.currentDateTime);

    }

    connectedCallback() {
        this.getLatestMemoReport();
        this.getLatestCamReport();
        this.sunscribeToSaveMessageChannel();
        this.updateCurrentDateTime();
        console.log('UserId', this.userId);
        this.getSPDDuser();
        if (this.hasEditAccess === false) {
            this.isReadOnly = true;
            // This for Disable Mode
            this.updatedColumns = [
                {
                    label: 'Document Type /SC',
                    fieldName: 'DocTyp__c',
                    type: 'text',

                },
                {
                    label: 'Document Name/SC Details',
                    fieldName: 'DocSubTyp__c',
                    type: 'text',

                },
                {
                    label: 'Critical/Non-critical',
                    fieldName: 'Criticality__c',
                    type: 'text',

                },
                {
                    label: 'Document Status/Reason/Mitigants',
                    fieldName: 'DocStatus__c',
                    type: 'text',

                },
                {
                    label: 'Deviation Level',
                    fieldName: 'DevLvl__c',
                    type: 'text',

                },

                {
                    label: 'Document Description',
                    fieldName: 'Rmrk__c',
                    type: 'textarea',
                },
                {
                    label: 'View',
                    type: 'button-icon',
                    initialWidth: 50,
                    editable: true,
                    typeAttributes: {
                        iconName: 'utility:preview',
                        title: 'Preview',
                        variant: 'brand',
                        name: 'view',
                        disabled: { fieldName: 'isDocAvailable' },
                        
                    }
                },
                {
                    label: 'Approver Action',
                    fieldName: 'Appr_Actn__c',
                    type: 'customPicklist',
                    editable: false,
                    typeAttributes: {
                        options: { fieldName: 'pickListOptions' },
                        value: { fieldName: 'Appr_Actn__c' },
                        context: { fieldName: 'Id' },
                        isDisabledRow : {fieldname : 'isDisabledRow'}
                    }
                },
                {
                    label: '*Remarks (Input Text)',
                    fieldName: 'AppvdRmrks__c',
                    type: 'Text',
                }

            ];
            this.deviationColumns = getDeviationColumns();
            this.PostdeviationColumns = getPostdeviationColumns();
            //LAK-8001
            this.creditdeviationColumns = getcreditdeviationColumns();

        } else {
            // This is for Edit Mode
            this.updatedColumns = [
                {
                    label: 'Document Type /SC',
                    fieldName: 'DocTyp__c',
                    type: 'text',

                },
                {
                    label: 'Document Name/SC Details',
                    fieldName: 'DocSubTyp__c',
                    type: 'text',

                },
                {
                    label: 'Critical/Non-critical',
                    fieldName: 'Criticality__c',
                    type: 'text',

                },
                {
                    label: 'Document Status/Reason/Mitigants',
                    fieldName: 'DocStatus__c',
                    type: 'text',

                },
                {
                    label: 'Deviation Level',
                    fieldName: 'DevLvl__c',
                    type: 'text',

                },

                {
                    label: 'Document Description',
                    fieldName: 'Rmrk__c',
                    type: 'textarea',
                },
                {
                    label: 'View',
                    type: 'button-icon',
                    initialWidth: 50,
                    editable: true,
                    typeAttributes: {
                        iconName: 'utility:preview',
                        title: 'Preview',
                        variant: 'brand',
                        name: 'view',
                        disabled: { fieldName: 'isDocAvailable' }
                    }
                },
                {
                    label: 'Approver Action',
                    fieldName: 'Appr_Actn__c',
                    type: 'customPicklist',
                    editable: true,
                    typeAttributes: {
                        options: { fieldName: 'pickListOptions' },
                        value: { fieldName: 'Appr_Actn__c' },
                        context: { fieldName: 'Id' },
                        isDisabledRow : {fieldname : 'isDisabledRow'}
                    }
                },
                {
                    label: '*Remarks (Input Text)',
                    fieldName: 'AppvdRmrks__c',
                    type: 'Text',
                    editable: "true",
                    required: "true",

                }

            ];
            this.deviationColumns = getEDeviationColumns();
            this.PostdeviationColumns = getEPostdeviationColumns();
            //LAK-8001
            this.creditdeviationColumns = getEcreditdeviationColumns();
        }

        
        this.queueRecord();
        setTimeout(() => {
            this.showSpinner = false;
        }, 2000);

    }
    // Method to handle the picklist values of Approval Action
    handlePicklistChange(event) {
        const { selectedValue } = event.detail;
    }
    @track showfile = false;

    handleRowAction(event) {
        let action = event.detail.action;
        let row = event.detail.row;
        switch (action.name) {
            case 'view':
                this.viewDocument(row);
                break;
            default:
                break;
        }
    }
    async viewDocument(row) {
        this.recordIdForDoc = row.Id;
        this.showfile = true;
        this.hasDocumentId = true;

    }
    @track hasDocumentId = false;
    @track recordIdForDoc;

    handleCloseModalEvent(event) {
        this.showfile = false;

    }
    contentVerRecords() {
        let paramsForCon = {
            ParentObjectName: 'ContentVersion',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'ContentDocumentId', 'FileExtension'],
            childObjFields: [],
            queryCriteria: ' where ContentDocumentId= \'' + this.parentRecords[0].ContentDocumentId + '\''
        }
        getSobjectData({ params: paramsForCon })
            .then((data) => {
                this.parentRecsOfConVer = JSON.parse(JSON.stringify(data.parentRecords));
                this.contDocId = this.parentRecsOfConVer[0].ContentDocumentId;
                this.contDocType = this.parentRecsOfConVer[0].FileExtension;
                this.cvId = this.parentRecsOfConVer[0].Id;

            })
            .catch(error => {
                console.log('Errorured33:- ' + error);
            });
    }

    CPAPoolId;
    // Method to get Queue Records
    queueRecord() {
        let parameter1 = {
            ParentObjectName: 'Group ',
            ChildObjectRelName: null,
            parentObjFields: ['Id', 'Name'],
            childObjFields: [],
            queryCriteria: ' where Name = \'' + 'CPA Pool' + '\''
        }

        let parameter2 = {
            ParentObjectName: 'Group ',
            ChildObjectRelName: null,
            parentObjFields: ['Id', 'Name'],
            childObjFields: [],
            queryCriteria: ' where Name = \'' + 'Ops Pool' + '\''
        }

        getSobjDataWIthRelatedChilds({ params: parameter1 })
            .then(result => {
                if (result.parentRecord.Id != undefined) {
                    this.CPAPoolId = result.parentRecord.Id;
                }
            })

        getSobjDataWIthRelatedChilds({ params: parameter2 })
            .then(result => {
                if (result.parentRecord.Id != undefined) {
                    this.opsPoolId = result.parentRecord.Id;
                }
            })
            .catch(error => {
                console.log(error);

            });
    }

    showModalBox() {
        this.isShowModal = true;
    }
    openModalBox() {
        this.isOpenModal = true;
    }
    closeModalBox() {
        this.isOpenModal = false;
    }
    hideModalBox() {
        this.isShowModal = false;
    }
    showModal() {
        this.isShowPopup = true;

    }
    hideModal() {
        this.isShowPopup = false;
    }

    handleLookupFieldChange(event) {
        this.lookupId = event.detail;
        let lookupIds = this.lookupId.id;
        this.lookupId = lookupIds;
        let tempevent = JSON.parse(JSON.stringify(event.detail));
        this.ForwardToUserName = tempevent.mainField;

    }

    onChange(event) {
        let val = event.detail.value;
        this.memoRemarks = val.toUpperCase();
    }
    onChanged(event) {
        let val = event.target.value;
        this.camRemarks = val.toUpperCase();
    }
    @track frwdUWRemarks;
    FrwdChange(event) {
        let val = event.detail.value;
        this.frwdUWRemarks = val.toUpperCase();
    }

    devLevel;
    retval;
    homeLone = 'Home Loan';
    stLAP = 'Small Ticket LAP';
    LAP = 'Loan Against Property';

    // Method to get User Level
    getSPDDuser() {
        let paramsLoanApp = {
            ParentObjectName: 'SPDD_Approval_Config__c',
            parentObjFields: ['Id', 'Emp__c', 'Dev_Level__c'],
            queryCriteria: ' where Emp__c = \'' + this.userId + '\' AND Product__c INCLUDES(\'' + this.homeLone + '\',\'' + this.LAP + '\',\'' + this.stLAP + '\') '
        }
        
        getSobjectDat({ params: paramsLoanApp })
            .then((result) => {
                if (result.parentRecords && result.parentRecords.length > 0) { //For LAK-8257
                    this.devLevel = result.parentRecords[0].Dev_Level__c;
                    console.log('this.devLevel', this.devLevel);
                }
                
                // PDD
                let tempParams = this.prodocParams;
                tempParams.queryCriteria = ' where DocCatgry__c = \'' + this.docCat + '\' AND DocStatus__c = \'' + this.docStatus1 + '\' AND LAN__c = \'' + this._loanAppId + '\'';
                this.prodocParams = { ...tempParams };

                let tempParams2 = this.mandatory;
                tempParams2.queryCriteria = ' where DocCatgry__c = \'' + this.docCat2 + '\' AND DocStatus__c = \'' + this.docStatus2 + '\' AND LAN__c = \'' + this._loanAppId + '\'';
                this.mandatory = { ...tempParams2 };
                console.log('this.mandatory', this.mandatory);
                let tempParams3 = this.additional;
                tempParams3.queryCriteria = ' where DocCatgry__c = \'' + this.docCat3 + '\' AND DocStatus__c = \'' + this.docStatus2 + '\' AND LAN__c = \'' + this._loanAppId + '\'';
                this.additional = { ...tempParams3 };

                let tempParams11 = this.manual;
                tempParams11.queryCriteria = ' where DocCatgry__c = \'' + this.docCat4 + '\' AND DocStatus__c = \'' + this.docStatus2 + '\' AND LAN__c = \'' + this._loanAppId + '\'';
                this.manual = { ...tempParams11 };

                //OTC
                let tempParams4 = this.otcperms;
                tempParams4.queryCriteria = ' where DocCatgry__c = \'' + this.docCat + '\' AND DocStatus__c = \'' + this.otcdocStatus1 + '\' AND LAN__c = \'' + this._loanAppId + '\'';
                this.otcperms = { ...tempParams4 };

                let tempParams5 = this.otcperms2;
                tempParams5.queryCriteria = ' where DocCatgry__c = \'' + this.docCat2 + '\' AND DocStatus__c = \'' + this.otcdocStatus2 + '\' AND LAN__c = \'' + this._loanAppId + '\'';
                this.otcperms2 = { ...tempParams5 };

                let tempParams6 = this.otcperms3;
                tempParams6.queryCriteria = ' where DocCatgry__c = \'' + this.docCat3 + '\' AND DocStatus__c = \'' + this.otcdocStatus3 + '\' AND LAN__c = \'' + this._loanAppId + '\'';
                this.otcperms3 = { ...tempParams6 };

                let tempParams12 = this.otcperms4;
                tempParams12.queryCriteria = ' where DocCatgry__c = \'' + this.docCat4 + '\' AND DocStatus__c = \'' + this.otcdocStatus3 + '\' AND LAN__c = \'' + this._loanAppId + '\'';
                this.otcperms4 = { ...tempParams12 };

                //Wavier
                let tempParams7 = this.wavierperms;
                tempParams7.queryCriteria = ' where DocCatgry__c = \'' + this.docCat + '\' AND DocStatus__c = \'' + this.wavierdocStatus1 + '\' AND LAN__c = \'' + this._loanAppId + '\'';
                this.wavierperms = { ...tempParams7 };

                let tempParams8 = this.wavierperms2;
                tempParams8.queryCriteria = ' where DocCatgry__c = \'' + this.docCat2 + '\' AND DocStatus__c = \'' + this.wavierdocStatus2 + '\' AND LAN__c = \'' + this._loanAppId + '\'';
                this.wavierperms2 = { ...tempParams8 };

                let tempParams9 = this.wavierperms3;
                tempParams9.queryCriteria = ' where DocCatgry__c = \'' + this.docCat3 + '\' AND DocStatus__c = \'' + this.wavierdocStatus3 + '\' AND LAN__c = \'' + this._loanAppId + '\'';
                this.wavierperms3 = { ...tempParams9 };

                let tempParams13 = this.wavierperms4;
                tempParams13.queryCriteria = ' where DocCatgry__c = \'' + this.docCat4 + '\' AND DocStatus__c = \'' + this.wavierdocStatus3 + '\' AND LAN__c = \'' + this._loanAppId + '\'';
                this.wavierperms4 = { ...tempParams13 };

                this.getDocDevLevel();
                this.getDivDevLevel();
                //Deviation
                let tempParams10 = this.deviationperms;
                tempParams10.queryCriteria = ' where DeviationCategory__c IN(\'' + this.divCat1 + '\',\'' + this.divCat2 + '\',\'' + this.divCat3 + '\') ' + 'AND LoanAppln__c = \'' + this._loanAppId + '\' order by DeviationCategory__c ';
                this.deviationperms = { ...tempParams10 };

                // Post Sanction Deviation
                let tempParams14 = this.postdeviationperms;
                tempParams14.queryCriteria = ' where CallId__c = 5 AND  Status__c=\'Active\' AND LoanAppln__c = \'' + this._loanAppId + '\' ORDER BY Req_Apprv_Level__c DESC';
                this.postdeviationperms = { ...tempParams14 };

                //LAK-8001
                //Credit Deviation
                let tempParams15 = this.creddeviationperms;
                tempParams15.queryCriteria = ' where LoanAppln__c = \'' + this._loanAppId + '\' AND (Dev_Type__c =\'Manual\' OR (Dev_Type__c =\'System\' AND Status__c=\'Active\' AND  CallId__c= 4) ) AND (Appr_Actn__c = \'\' OR (Appr_Actn__c != \'\' AND  AppStage__c = \'Post Sanction\')) ORDER BY Req_Apprv_Level__c DESC';
                this.creddeviationperms = { ...tempParams15 };

                //LAK-7446 BIL Approval Tray
                let tempParams16 = this.paramsSplitDis;
                tempParams16.queryCriteria = ' where DisburseRela__r.Loan_Appli__c = \'' + this._loanAppId +  '\'';
                this.paramsSplitDis = {...tempParams16};
                
                //LAK-10242
                let tempParams17 = this.breParams;
                tempParams17.queryCriteria = ' where IsLatest__c = true AND EligibilityType__c = \'' + this.eligibType + '\' AND LoanAppl__c = \'' + this._loanAppId + '\'';
                this.breParams = {...tempParams17};
            })
            .catch((error) => {
                console.log("error occured in getting user", error);
            });
    }


    docdevLevel;
    cat1 = 'Property Documents';
    cat2 = 'Mandatory Post Sanction Documents';
    cat3 = 'Additional Post Sanction Documents';
    cat4 = 'Sanction Condition Documents';

    // Method to get Document Deviations
    getDocDevLevel() {
        let paramsLoanApp = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'DevLvl__c'],
            queryCriteria: ' where LAN__c = \'' + this._loanAppId + '\' AND DocCatgry__c IN(\'' + this.cat1 + '\',\'' + this.cat2 + '\',\'' + this.cat3 + '\',\'' + this.cat4 + '\') AND DocStatus__c IN(\'' + this.docStatus1 + '\',\'' + this.wavierdocStatus1 + '\',\'' + this.otcdocStatus1 + '\') ORDER BY DevLvl__c DESC LIMIT 1'
        }
        getSobjectDat({ params: paramsLoanApp })
            .then((result) => {
                if (result?.parentRecords?.length != undefined && result?.parentRecords?.length > 0) {
                    this.docdevLevel = result.parentRecords[0].DevLvl__c;
                    console.log('this.docdevLevel', this.docdevLevel);
                    if (this.devLevel >= this.docdevLevel) {
                        this.retval = true;
                    } else {
                        this.retval = false;
                    }
                } else {
                    this.retval = true;
                }
            })
            .catch((error) => {
                console.log("error occured in getting Doctdt", error);
            });

    }
    retval2;
    divdevLevel;

    // Method to get Deviation Rec Deviations
    getDivDevLevel() {
        let paramsLoanApp = {
            ParentObjectName: 'Deviation__c',
            parentObjFields: ['Id', 'Req_Apprv_Level__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this._loanAppId + '\' AND DeviationCategory__c IN(\'' + this.divCat1 + '\',\'' + this.divCat2 + '\',\'' + this.divCat3 + '\')  ORDER BY Req_Apprv_Level__c DESC LIMIT 1'
        }
        getSobjectDat({ params: paramsLoanApp })
            .then((result) => {
                if (result?.parentRecords?.length != undefined && result?.parentRecords?.length > 0) {
                    this.divdevLevel = result.parentRecords[0].Req_Apprv_Level__c;
                    console.log('this.divdevLevel', this.divdevLevel);
                    if (this.devLevel >= this.divdevLevel) {
                        this.retval2 = true;
                    } else {
                        this.retval2 = false;
                    }
                } else {
                    this.retval2 = true;
                }
            })
            .catch((error) => {
                console.log("error occured in getting Divdevlev", error);
            });

    }
    

  

    @track missingRemarkRec = [];
    @track missingActionRec = [];
    @track remark1;
    @track docAction;
    @track docRec = [];
    docRemarks;
    @track allDocAppordActn = true;

    // Method to get Document Remarks
    getDocRemarks() {
        this.allDocAppordActn = true;
        return new Promise((resolve, reject) => {
            let paramsLoanApp = {
                ParentObjectName: 'DocDtl__c',
                parentObjFields: ['Id', 'AppvdRmrks__c', 'Appr_Actn__c'],
                queryCriteria: ' where LAN__c = \'' + this._loanAppId + '\' AND DocCatgry__c IN(\'' + this.cat1 + '\',\'' + this.cat2 + '\',\'' + this.cat3 + '\',\'' + this.cat4 + '\') AND DocStatus__c IN(\'' + this.docStatus1 + '\',\'' + this.wavierdocStatus1 + '\',\'' + this.otcdocStatus1 + '\')'
            }
            getSobjectDat({ params: paramsLoanApp })
                .then((result) => {
                    let count = 0;
                    let cnt = 0;
                    if (result?.parentRecords?.length != undefined && result?.parentRecords?.length > 0) {
                        this.docRec = result.parentRecords;
                        result.parentRecords.forEach(element => {
                            if (element.AppvdRmrks__c == undefined || element.AppvdRmrks__c == null || element.AppvdRmrks__c == '') {
                                this.missingRemarkRec.push(element.Id);
                            }
                            else {
                                count++


                            }
                            if (element.Appr_Actn__c == undefined || element.Appr_Actn__c == null || element.Appr_Actn__c == '') {
                                this.missingActionRec.push(element.Id);
                            }
                            else {
                                cnt++
                            }
                            if (element.Appr_Actn__c == 'Rejected') {
                                this.allDocAppordActn = false;
                            }

                        });
                        if (count === result.parentRecords.length) {
                            this.remark1 = true;

                        } else {
                            this.remark1 = false;
                        }
                        if (cnt === result.parentRecords.length) {
                            this.docAction = true;

                        } else {
                            this.docAction = false;
                        }
                    }
                    else {
                        this.remark1 = true;
                        this.docAction = true;
                    }
                    resolve(this.remark1);

                })
                .catch((error) => {
                    console.log("error occured in getting Doc Remarks", error);
                    reject(error);
                });
        });
    }
    @track postdivRec = [];
    @track remark3;
    @track postdivAction;
    divRemarks3;
    // Method to get Divation Rec Remarks
    postgetDivRemarks() {
        return new Promise((resolve, reject) => {
            let paramsLoanApp = {
                ParentObjectName: 'Deviation__c',
                parentObjFields: ['Id', 'Appr_Remarks__c', 'Mitigation__c', 'Appr_Actn__c'],
                queryCriteria: ' where LoanAppln__c = \'' + this._loanAppId + '\' AND BRE__r.Call_Id__c = \'5.0\' AND BRE__r.IsLatest__c = TRUE  '
            }
            getSobjectDat({ params: paramsLoanApp })
                .then((result) => {
                    let count = 0;
                    let cnt = 0;
                    if (result?.parentRecords?.length != undefined && result?.parentRecords?.length > 0) {
                        this.postdivRec = result.parentRecords;
                        result.parentRecords.forEach(element => {
                            console.log('element.Mitigation__c ', element.Mitigation__c);
                            if (element.Appr_Remarks__c == null || element.Appr_Remarks__c == '' || element.Appr_Remarks__c == undefined || element.Mitigation__c == null || element.Mitigation__c == '' || element.Mitigation__c == undefined) {
                                this.missingRemarkRec.push(element.Id);
                            }
                            else {
                                count++
                            }
                            if (element.Appr_Actn__c == undefined || element.Appr_Actn__c == null || element.Appr_Actn__c == '') {
                                this.missingActionRec.push(element.Id);
                            }
                            else {
                                cnt++
                            }
                            if (element.Appr_Actn__c == 'Rejected') {
                                this.allDevAppordActn = false;
                            }
                        });
                        if (count === result.parentRecords.length) {
                            this.remark3 = true;

                        } else {
                            this.remark3 = false;
                        }
                        if (cnt === result.parentRecords.length) {
                            this.postdivAction = true;

                        } else {
                            this.postdivAction = false;
                        }
                    }
                    else {
                        this.remark3 = true;
                        this.postdivAction = true;
                    }
                    resolve(this.remark3);
                })
                .catch((error) => {
                    console.log("error occured in getting Div Remarks", error);
                    reject(error);
                });
        });

    }
    //LAK-8001
    @track creditdivRec = [];
    @track remark4;
    @track creditdivAction;
    divRemarks4;
    // Method to get Divation Rec Remarks
    creditDivRemarks() {
        return new Promise((resolve, reject) => {
            let paramsLoanApp = {
                ParentObjectName: 'Deviation__c',
                parentObjFields: ['Id', 'Appr_Remarks__c', 'Mitigation__c', 'Appr_Actn__c','Apprv_By__c'],
                queryCriteria: ' where LoanAppln__c = \'' + this._loanAppId +  '\' AND (Dev_Type__c =\'Manual\' OR (Dev_Type__c =\'System\' AND BRE__r.IsLatest__c=TRUE AND BRE__r.Call_Id__c = \'4.0\') ) AND (Appr_Actn__c = \'\' OR (Appr_Actn__c != \'\' AND  AppStage__c = \'Post Sanction\')) ORDER BY Req_Apprv_Level__c DESC'
            }
            getSobjectDat({ params: paramsLoanApp })
                .then((result) => {
                    let count = 0;
                    let cnt = 0;
                    if (result?.parentRecords?.length != undefined && result?.parentRecords?.length > 0) {
                        this.creditdivRec = result.parentRecords;
                        result.parentRecords.forEach(element => {
                            console.log('element.Mitigation__c ', element.Mitigation__c);
                            if (element.Appr_Remarks__c == null || element.Appr_Remarks__c == '' || element.Appr_Remarks__c == undefined || element.Mitigation__c == null || element.Mitigation__c == '' || element.Mitigation__c == undefined) {
                                this.missingRemarkRec.push(element.Id);
                            }
                            else {
                                count++
                            }
                            if (element.Appr_Actn__c == undefined || element.Appr_Actn__c == null || element.Appr_Actn__c == '') {
                                this.missingActionRec.push(element.Id);
                            }
                            else {
                                cnt++
                            }
                            if (element.Appr_Actn__c == 'Rejected') {
                                this.allDevAppordActn = false;
                            }
                        });
                        if (count === result.parentRecords.length) {
                            this.remark4 = true;

                        } else {
                            this.remark4 = false;
                        }
                        if (cnt === result.parentRecords.length) {
                            this.creditdivAction = true;

                        } else {
                            this.creditdivAction = false;
                        }
                    }
                    else {
                        this.remark4 = true;
                        this.creditdivAction = true;
                    }
                    resolve(this.remark4);
                })
                .catch((error) => {
                    console.log("error occured in getting Div Remarks", error);
                    reject(error);
                });
        });

    }

    @track divRec = [];
    @track remark2;
    divRemarks2;
    @track allDevAppordActn = true;

    // Method to get Deviation Rec Remarks
    getDivRemarks() {
        this.allDevAppordActn = true;
        return new Promise((resolve, reject) => {
            let paramsLoanApp = {
                ParentObjectName: 'Deviation__c',
                parentObjFields: ['Id', 'Appr_Remarks__c', 'Appr_Actn__c'],
                queryCriteria: ' where LoanAppln__c = \'' + this._loanAppId + '\' AND DeviationCategory__c IN(\'' + this.divCat1 + '\',\'' + this.divCat2 + '\',\'' + this.divCat3 + '\') '
            }
            getSobjectDat({ params: paramsLoanApp })
                .then((result) => {
                    let count = 0;
                    let cnt = 0;
                    if (result?.parentRecords?.length != undefined && result?.parentRecords?.length > 0) {
                        this.divRec = result.parentRecords;
                        result.parentRecords.forEach(element => {
                            if (element.Appr_Remarks__c == null || element.Appr_Remarks__c == '' || element.Appr_Remarks__c == undefined) {
                                this.missingRemarkRec.push(element.Id);
                            }
                            else {
                                count++
                            }
                            if (element.Appr_Actn__c == undefined || element.Appr_Actn__c == null || element.Appr_Actn__c == '') {
                                this.missingActionRec.push(element.Id);
                            }
                            else {
                                cnt++
                            }
                            if (element.Appr_Actn__c == 'Rejected') {
                                this.allDevAppordActn = false;
                            }
                        });
                        if (count === result.parentRecords.length) {
                            this.remark2 = true;

                        } else {
                            this.remark2 = false;
                        }
                        if (cnt === result.parentRecords.length) {
                            this.divAction = true;

                        } else {
                            this.divAction = false;
                        }
                    }
                    else {
                        this.remark2 = true;
                        this.divAction = true;
                    }
                    resolve(this.remark2);
                })
                .catch((error) => {
                    console.log("error occured in getting Div Remarks", error);
                    reject(error);
                });
        });

    }

    @track stage;
    @track substage;
    @track isBlPl = false;

    @wire(getRecord, { recordId: '$_loanAppId', fields: [AppStage, AppSubstage, ProductType] })
    currentRecordInfo({ error, data }) {
        if (data) {
            console.log('currentRecordInfo ', data);
            console.table(data);
            this.stage = data.fields.Stage__c.value;
            this.substage = data.fields.SubStage__c.value;
            this.product = data.fields.Product__c.value;
            if(this.product && (this.product === 'Business Loan' || this.pro  === 'Personal Loan')){
                this.isBlPl = true
            }

        } else if (error) {
            this.error = error;
        }

    }

    // Method to get LAN Details 
    getLoanAppData() {
        this.showDocList = false;
        let paramsLoanApp = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Id', 'EMIOptionsintranchedisbursementCase__c','Total_PF_Amount__c', 'RemPFDeductFromDisbursementAmount__c', 'FirstEMIDate__c', 'Applicant__c', ''],
            queryCriteria: ' where Id = \'' + this._loanAppId + '\' '
        }
        getSobjectDat({ params: paramsLoanApp })
            .then((result) => {
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.loanApplicationRecord = { ...result.parentRecords[0] };
                    this.showDocList = true;
                }

            })
            .catch((error) => {
                console.log('Error In getting Loan Application Data ', error);
            });
    }
    handleSendtoCPAS() {
        if (this.stage == 'Post Sanction' && this.substage == 'UW Approval') {
            const obj = {
                sobjectType: "LoanAppl__c",
                Id: this._loanAppId,
                SubStage__c: 'Data Entry Pool',
                OwnerId: this.CPAPoolId
            }
            this.showSpinner = true;
            this.upsertLan(obj);
        }
        else if (this.stage == 'Disbursed' && this.substage == 'UW Approval') {
            const obj = {
                sobjectType: "LoanAppl__c",
                Id: this._loanAppId,
                SubStage__c: 'Additional Processing Pool',
                OwnerId: this.CPAPoolId
            }
            this.showSpinner = true;
            this.upsertLan(obj);
        }
    }
    upsertLan(obj) {
        let newArr = [];
        if (obj) {
            newArr.push(obj);
        }
        if (newArr.length > 0) {
            console.log('new array is in cpa ', JSON.stringify(newArr));
            upsertSObjectRecord({ params: newArr })
                .then((result) => {
                    this.showToastMessage('Success', this.Customlabel.ApprovalTray_SendToCPA_SuccesMessage, 'success', 'sticky');
                    this[NavigationMixin.Navigate]({
                        type: 'standard__objectPage',
                        attributes: {
                            objectApiName: "LoanAppl__c",
                            actionName: "list"
                        },
                    });

                })
                .catch((error) => {
                    console.log('error in upserting a LAN in cpa ', JSON.stringify(error));

                });
        }
    }
    validateForm() {
        let isValid = true
        this.template.querySelectorAll('lightning-textarea').forEach(element => {
            if (element.reportValidity()) {
            } else {
                isValid = false;
                console.log('isValid ', isValid);

            }
        });

        return isValid;


    }
    //LAK-8001
    updateErrors = [];
    @track doc = [];
    async handleYesButton() {
        this.showSpinner = true;
        let val3 = await this.runBRE();
        let val2 = await this.getVerificationExpDet();
        let val = await this.getDivRemarks();
        let val1 = await this.getDocRemarks();
        let val4 = await this.postgetDivRemarks();
        let val5 = await this.creditDivRemarks();
        console.log('allDevAppordActn', this.allDevAppordActn);
        console.log('allDocAppordActn', this.allDocAppordActn);
        if (!this.validateForm()) {
            this.showSpinner = false;
            this.isOpenModal = false;
            this.showToastMessage('Error', 'Please fill the Remarks', 'error', 'sticky');
        }
        if (this.retval && this.retval2 && this.retval3 && this.retval4 && this.remark1 && this.remark2 && this.remark3 && this.remark4 && this.allDevAppordActn && this.allDocAppordActn && this.docAction && this.postdivAction && this.divAction && this.creditdivAction && !this.isFoirMiss && !this.isLtvMiss ) {//LAK-8001

            if (!this.validateForm()) {
                this.showSpinner = false;
                this.isOpenModal = false;
                this.showToastMessage('Error', 'Please fill the Remarks', 'error', 'sticky');
                return;
            }
            else {
                if (this.stage == 'Post Sanction' && this.substage == 'UW Approval' && !this.verfExp && !this.breVal) {
                    const obj = {
                        sobjectType: "LoanAppl__c",
                        Id: this._loanAppId,
                        Stage__c: 'Disbursement Initiation',
                        SubStage__c: 'DI Pool',
                        NDCAprvd__c: 'true',
                   
                        OwnerId: this.opsPoolId
                    }
                    this.showSpinner = true;
                    this.upsertData(obj);
                    if (this.memoRemarks && this.camRemarks) {

                        this.updateMemoRecord('approve');
                    }
                }
                else if ((this.verfExp || this.breVal) && this.stage != 'Disbursed') {
                    if (this.verfExp == true) {

                        if (this.expDetails.length > 0) {
                            let str = ' ';
                            this.expDetails.forEach(item => {
                                str = str + item + ',';
                            })
                            if (str.endsWith(',')) {
                                str = str.slice(0, -1);
                            }
                            this.showToastMessage('Error', 'Verification Expired for ' + str, 'error', 'sticky');
                            this.showSpinner = false;
                            this.isOpenModal = false;
                        }
                    }
                    if (this.breVal) {
                        this.showToastMessage('Error', 'Kindly please run the BRE', 'error', 'sticky');
                        this.showSpinner = false;
                        this.isOpenModal = false;
                    }
                }

                else if (this.stage == 'Disbursed' && this.substage == 'UW Approval') {
                    const obj = {
                        sobjectType: "LoanAppl__c",
                        Id: this._loanAppId,
                        SubStage__c: 'DI Pool',
                        NDCAprvd__c: 'true',
                        OwnerId: this.opsPoolId
                    }
                    this.showSpinner = true;
                    this.upsertData(obj);
                    if (this.memoRemarks && this.camRemarks) {

                        this.updateMemoRecord('approve');
                    }
                }
            }
        }
        if (this.retval !== true || this.retval2 !== true || this.retval3 !== true || this.retval4!==true) {
            this.showToastMessage('Error', this.Customlabel.ApprovalTray_Authority_ErrorMessage, 'error', 'sticky');
            this.showSpinner = false;
            this.isOpenModal = false;
        }
        //LAK-10242
        if(this.isLtvMiss){
            this.showToastMessage('Error', 'Actual LTV is Missing on Eligibility, Kindly Re-run the BRE', 'error', 'sticky');
            this.showSpinner = false;
            this.isOpenModal = false;
        }
        if(this.isFoirMiss){
            this.showToastMessage('Error', 'Actual FOIR is Missing on Eligibility, Kindly Re-run the BRE', 'error', 'sticky');
            this.showSpinner = false;
            this.isOpenModal = false;
        }
        if (!this.allDevAppordActn) {
            this.showToastMessage('Error', 'Deviations Rejected', 'error', 'sticky');
            this.showSpinner = false;
            this.isOpenModal = false;
        }
        if (!this.allDocAppordActn) {
            this.showToastMessage('Error', 'Documents Rejected', 'error', 'sticky');
            this.showSpinner = false;
            this.isOpenModal = false;
        }
        if (this.remark1 !== true || this.remark2 !== true || this.remark3 !== true || this.remark4!==true || !this.docAction || !this.divAction || !this.postdivAction || !this.creditdivAction) {//LAK-8001
            // let updatedErrors = JSON.parse(JSON.stringify(this.errors));
            this.updateErrors.rows = this.updateErrors.rows || {};
            this.errors = { rows: {}, table: {} };
 
            if (this.missingRemarkRec && this.missingRemarkRec.length > 0) {

                let valid = this.checkReportValidity();
                console.log('valid ', valid);
                if (!valid) {
                    this.showToastMessage('Error', 'Required Fields are missing', 'error', 'sticky');
                }
                this.missingRemarkRec.forEach(Id => {
                    if (!this.updateErrors.rows[Id]) {
                        this.updateErrors.rows[Id] = {
                            title: 'Error',
                            messages: ['Required Fields are missing'],
                            fieldNames: ['AppvdRmrks__c', 'Appr_Remarks__c', 'Remarks__c', 'Mitigation__c']
                        };
                    } else {
                        // If the row already has errors, append missing field names
                        this.updateErrors.rows[Id].fieldNames = [
                            ...new Set([...this.updateErrors.rows[Id].fieldNames, 'AppvdRmrks__c', 'Appr_Remarks__c', 'Remarks__c', 'Mitigation__c'])
                        ];
                    }
                });
            }
            if (!this.docAction || !this.divAction || !this.postdivAction|| !this.creditdivAction) {//LAK-8001
                let valid = this.checkReportValidityOps();
                console.log('valid ', valid);
                if (!valid) {
                    this.showToastMessage('Error', 'Required Fields are missing', 'error', 'sticky');
                }
                this.missingActionRec.forEach(Id => {
                    if (!this.updateErrors.rows[Id]) {
                        this.updateErrors.rows[Id] = {
                            title: 'Error',
                            messages: ['Required Fields are missing'],
                            fieldNames: ['Appr_Actn__c']
                        };
                    } else {
                        // If the row already has errors, append missing field name
                        this.updateErrors.rows[Id].fieldNames = [
                            ...new Set([...this.updateErrors.rows[Id].fieldNames, 'Appr_Actn__c'])
                        ];
                    }
                });
            }
            this.errors = this.updateErrors;
            this.showToastMessage('Error', 'Required Fields are missing', 'error', 'sticky');
            this.showSpinner = false;
            this.isOpenModal = false;

        }



        this.isOpenModal = false;

    }

    checkReportValidity() {
        let isValid = true
        this.template.querySelectorAll('c-approval-tray-data-table').forEach(element => {
            if (element.reportValidity()) {
                console.log('c-approval-tray-data-table');
                console.log('element if--' + element.value);
            } else {
                isValid = false;
                console.log('element else--' + element.value);
            }
        });
        return isValid;
    }

    checkReportValidityOps() {
        let isValid = true
        this.template.querySelectorAll('c-approval-tray-data-table').forEach(element => {
            if (element.reportValidityOps()) {
                console.log('c-approval-tray-data-table');
                console.log('element if--' + element.value);
            } else {
                isValid = false;
                console.log('element else--' + element.value);
            }
        });
        return isValid;
    }

    upsertData(obj) {
        this.showSpinner = true;

        this.createUWDecesionRecord();
        let newArra = [];
        if (obj) {
            newArra.push(obj);
        }
        if (newArra) {
            console.log('new array is ', JSON.stringify(newArra));
            upsertSObjectRecord({ params: newArra })
                .then((result) => {
                    this.refreshPage = result;
                    this.showToastMessage('Success', this.Customlabel.ApprovalTray_Authority_SuccesMessage, 'success', 'sticky');
                    this.handleGenerateCamReport();
                    this[NavigationMixin.Navigate]({
                        type: 'standard__objectPage',
                        attributes: {
                            objectApiName: "LoanAppl__c",
                            actionName: "list"
                        }
                    });
                })
                .catch((error) => {
                    this.showToastMessage('Error', this.Customlabel.ApprovalTray_LAN_Update_ErrorMessage, 'error', 'sticky');
                    this.showSpinner = false;
                });
        }
    }

    validatefrwdForm() {
        let isValid = true

        if (this.frwdUWRemarks == undefined || this.frwdUWRemarks == '') {
            isValid = false;
        }
        return isValid;

    }
    async handleSubmit() {
        let val = await this.getVerificationExpDet();
        console.log('expiry val', val);
        if (this.stage == 'Post Sanction' && this.substage == 'UW Approval') {

            if (this.validatefrwdForm() && this.verfExp == false) {
                const obje = {
                    sobjectType: "LoanAppl__c",
                    Id: this._loanAppId,
                    OwnerId: this.lookupId,

                }
                this.upsertDataMethod(obje);
            }
            if (!this.validatefrwdForm()) {
                this.showToastMessage('Error', this.Customlabel.ForwardToUW_RemarkError, 'error', 'sticky');
                return
            }
        } else if (this.stage == 'Disbursed' && this.substage == 'UW Approval') {

            if (this.validatefrwdForm()) {
                const obje = {
                    sobjectType: "LoanAppl__c",
                    Id: this._loanAppId,
                    OwnerId: this.lookupId,

                }
                this.upsertDataMethod(obje);
            }
            if (!this.validatefrwdForm()) {
                this.showToastMessage('Error', this.Customlabel.ForwardToUW_RemarkError, 'error', 'sticky');
                return
            }
        }
        if (this.verfExp == true && this.stage != 'Disbursed') {
            if (this.expDetails.length > 0) {
                let str = ' ';
                this.expDetails.forEach(item => {

                    str = str + item + ',';
                })
                if (str.endsWith(',')) {
                    str = str.slice(0, -1);
                }
                this.showToastMessage('Error', 'Verification Expired for ' + str, 'error', 'sticky');

            }
        }
    }

    upsertDataMethod(obje) {
        this.createUWDecesionRecordNew();
        let newArray = [];
        if (obje) {
            newArray.push(obje);
        }
        if (newArray) {
            upsertSObjectRecord({ params: newArray })
                .then((result) => {
                    this.createFeed();
                    this.refreshPage = result;
                    this.showToastMessage('Success', this.Customlabel.ApprovalTray_Forward_SuccesMessage, 'success', 'sticky');
                    this[NavigationMixin.Navigate]({
                        type: 'standard__objectPage',
                        attributes: {
                            objectApiName: "LoanAppl__c",
                            actionName: "list"
                        },
                        state: {

                            filterName: "Recent"
                        }
                    });

                })
                .catch((error) => {
                    this.showToastMessage('Error', this.Customlabel.ApprovalTray_ForwardLAN_Update_ErrorMessage, 'error', 'sticky');
                    this.showSpinner = false;
                });
        }
    }

    handleError(event) {
    }
    handleCellChange(event) {
        let draftValues = event.detail.draftValues;
        let tempObj = {};

        draftValues.forEach(item => {
            let objIndex = this.draftValues.findIndex(ite => ite.Id === item.Id);
            if (objIndex !== -1) {
                this.draftValues[objIndex] = { ...this.draftValues[objIndex], ...item };
            } else {
                this.draftValues.push(item);
            }
        });


        console.log('this.draftValues', this.draftValues);

    }

    handleValueChange(event) {
        let recordid = event.detail.recordid;
        let fieldName = event.detail.fieldname;
        let value = event.detail.val;
        let obj = this.draftValues.find(ite => ite.Id === recordid);
        if (obj) {
            console.log('obj is ', JSON.stringify(obj));
            obj[fieldName] = value;
            if(fieldName === 'Appr_Actn__c' && value === 'Approved'){
            obj['Apprv_By__c'] = this.userId;
            obj['Approved_Date__c']= this.currentDateTime;
            obj['AppStage__c'] = this.stage;
            console.log('Approved in handlevaluechange',obj['Apprv_By__c'] ,obj['Approved_Date__c'] );
        }   
        else if(fieldName === 'Appr_Actn__c' && value === 'Rejected') {
            obj['Apprv_By__c'] = '';
            obj['Approved_Date__c']= '';
            obj['AppStage__c'] = '';
            console.log('rejected in handlevaluechange',obj['Apprv_By__c'] ,obj['Approved_Date__c'] );
        }
        } else {
            let objNew = {};
            objNew.Id = recordid;
            objNew[fieldName] = value;
            if(fieldName === 'Appr_Actn__c' && value === 'Approved'){
                objNew['Apprv_By__c'] = this.userId;
                objNew['Approved_Date__c']= this.currentDateTime;
                objNew['AppStage__c'] = this.stage;
                console.log('Approved in handlevaluechange',objNew['Apprv_By__c'] ,objNew['Approved_Date__c'] );
            }   
            else if(fieldName === 'Appr_Actn__c' && value === 'Rejected') {
                objNew['Apprv_By__c'] = '';
                objNew['Approved_Date__c']= '';
                objNew['AppStage__c'] = '';
                console.log('rejected in handlevaluechange',objNew['Apprv_By__c'] ,objNew['Approved_Date__c'] );
            }
            this.draftValues.push(objNew);
        }
        console.log('this.draftValues ', this.draftValues);
    }
    @track errors = {};
    @track DocDetail;
    @track draftValues = [];
    @track saveDraftValues = [];
    @track wiredDataResult = {};
    
    manualColumns = [
        {
            label: 'Sanction Condition',
            fieldName: 'Condition__c',
            type: 'Text',

        },
        {
            label: 'Approver Remarks (Input Text)',
            fieldName: 'Remarks__c',
            type: 'Text',
        }

    ];

    @track _recordId
    @api get recordId() {
        return this._recordId;
    }

    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        this.handleRecordIdChange();
        this.getLoanAppData();


    }

    //LAK-10242
    eligibType = 'Application';
    isFoirMiss = false;
    isLtvMiss = false;
    actualFoir;
    actualLtv;
    @track breParams = {
        ParentObjectName: 'BRE__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Actual_FOIR__c','Actual_LTV__c'],
        childObjFields: [],
        queryCriteria: ' where IsLatest__c = true AND EligibilityType__c = \'' + this.eligibType + '\' AND LoanAppl__c = \'' + this._loanAppId + '\''
    }

    @wire(getSobjectData, {params : '$breParams'})
    getBreData(result){
        if(result.data && result.data.parentRecords){
            this.actualFoir = result.data.parentRecords[0].Actual_FOIR__c ;
            this.actualLtv = result.data.parentRecords[0].Actual_LTV__c;
            this.isFoirMiss = (this.actualFoir!=null && this.actualFoir!=undefined) ? false : true;
            this.isLtvMiss = (this.actualLtv!=null && this.actualLtv!=undefined) ? false : true;
        }
        if(result.error){
            console.log('Error in BRE Data', result.error);
        }
    }

    docCat = 'Property Documents';
    docStatus1 = 'PDD';
    @track prodocParams = {
        ParentObjectName: 'DocDtl__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'DocTyp__c', 'Appr_Actn__c', 'Rmrk__c', 'DocSubTyp__c', 'Criticality__c', 'DocStatus__c', 'DevLvl__c', 'AppvdRmrks__c'],
        childObjFields: [],
        queryCriteria: ' where DocCatgry__c = \'' + this.docCat + '\' AND DocStatus__c = \'' + this.docStatus1 + '\' AND LAN__c = \'' + this._loanAppId + '\''
    }
    handleRecordIdChange() {
        this.getSPDDuser();
    }
    caalerId = '5.0';
    isLatest = 'true';
    @track DocDetail;
    @track DocDetailDev = false;
    @track showDocDetail = false;
    @track wiredDataResultPddProp = {};
    @wire(getSobjectData, { params: '$prodocParams', picklist: '$approvalActionOptions' })
    pddpropertyHandler(result) {
        this.DocDetail = [];
        this.DocDetailDev = false;
        this.showSpinner = true;
        this.wiredDataResultPddProp = result;
        if (result.data && result.data.parentRecords) {
            let count = 0;
            let docIds = [];
            console.log('DATA IN OTC Property ::::>>>>', result.data);
            this.DocDetail = result.data.parentRecords.map(currItem => {
                docIds.push(currItem.Id);
                if (currItem.Appr_Actn__c == 'Approved') {
                    count++;
                }
                let pickListOptions = this.approvalActionOptions;
                console.log('In line 1673', result.data.parentRecords);
                let isDisabledRow = false;
                if(currItem.DevLvl__c > this.devLevel || this.isReadOnly){
                    isDisabledRow = true;
                }
                return {
                    ...currItem,
                    pickListOptions: pickListOptions,
                    isDisabledRow : isDisabledRow
                }
            })
            console.log('count pro', count);
            console.log('DocDetail ::::>>>>', this.DocDetail);
            console.log('result.data.parentRecords.length prop', result.data.parentRecords.length)
            if (count == result.data.parentRecords.length) {
                this.DocDetailDev = true;
            }
            // this.getContentDoc(docIds, 'pddpropertyHandler');
            this.refreshUi = true;
            this.showDocDetail = true;
            this.showSpinner = false;
        } else {
            this.DocDetailDev = true;
            this.showDocDetail = false;
            this.showSpinner = false;
        }
        if (result.error) {
            console.error(result.error);
            this.error = result.error;
            this.showSpinner = false;


        }
    }

    docCat2 = 'Mandatory Post Sanction Documents';
    docStatus2 = 'PDD';
    @track postDocDetail;
    @track postDocDetailDev = false;
    @track mandatory = {
        ParentObjectName: 'DocDtl__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'DocTyp__c', 'Appr_Actn__c', 'Rmrk__c', 'DocSubTyp__c', 'Criticality__c', 'DocStatus__c', 'DevLvl__c', 'AppvdRmrks__c'],
        childObjFields: [],
        queryCriteria: ' where DocCatgry__c = \'' + this.docCat2 + '\' AND DocStatus__c = \'' + this.docStatus2 + '\' AND LAN__c = \'' + this._loanAppId + '\''
    }
    @track showPostDocDetail = false;
    @track wiredDataResultPddMan = {};
    @wire(getSobjectData, { params: '$mandatory', picklist: '$approvalActionOptions' })
    pddmandatoryHandler(result) {
        this.postDocDetail = [];
        this.postDocDetailDev = false;
        this.wiredDataResultPddMan = {};
        if (result.data && result.data.parentRecords) {
            let count = 0;
            let docIds = [];
            console.log('DATA IN OTC Property ::::>>>>', result.data);
            this.postDocDetail = result.data.parentRecords.map(currItem => {
                docIds.push(currItem.Id);
                if (currItem.Appr_Actn__c == 'Approved') {
                    count++;
                }
                let pickListOptions = this.approvalActionOptions;
                console.log('In line 1673', result.data.parentRecords);
                let isDisabledRow = false;
                if(currItem.DevLvl__c > this.devLevel || this.isReadOnly){
                    isDisabledRow = true;
                }
                return {
                    ...currItem,
                    pickListOptions: pickListOptions,
                    isDisabledRow : isDisabledRow
                }
            })
            if (count == result.data.parentRecords.length) {
                this.postDocDetailDev = true;
            }
            // this.getContentDoc(docIds, 'pddmandatoryHandler');
            this.refreshUi = true;
            this.showPostDocDetail = true;
        } else {
            this.postDocDetailDev = true;
            this.showPostDocDetail = false;
        }
        if (result.error) {
            console.error(result.error);
        }
    }

    docCat3 = 'Additional Post Sanction Documents';
    docStatus3 = 'PDD';
    @track addDocDetail;
    @track addDocDetailDev = false;
    @track additional = {
        ParentObjectName: 'DocDtl__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'DocTyp__c', 'Appr_Actn__c', 'Rmrk__c', 'DocSubTyp__c', 'Criticality__c', 'DocStatus__c', 'DevLvl__c', 'AppvdRmrks__c'],
        childObjFields: [],
        queryCriteria: ' where DocCatgry__c = \'' + this.docCat3 + '\' AND DocStatus__c = \'' + this.docStatus2 + '\' AND LAN__c = \'' + this._loanAppId + '\''
    }
    @track showAddDocDetail = false;
    @track wiredDataResultPddAdd = {};
    @wire(getSobjectData, { params: '$additional', picklist: '$approvalActionOptions' })
    pddadditionalHandler(result) {
        this.addDocDetail = [];
        this.addDocDetailDev = false;
        this.wiredDataResultPddAdd = result;
        if (result.data && result.data.parentRecords) {
            let count = 0;
            let docIds = [];
            console.log('DATA IN OTC Property ::::>>>>', result.data);
            this.addDocDetail = result.data.parentRecords.map(currItem => {
                docIds.push(currItem.Id);
                if (currItem.Appr_Actn__c == 'Approved') {
                    count++;
                }
                let pickListOptions = this.approvalActionOptions;
                console.log('In line 1673', result.data.parentRecords);
                let isDisabledRow = false;
                if(currItem.DevLvl__c > this.devLevel || this.isReadOnly){
                    isDisabledRow = true;
                }
                return {
                    ...currItem,
                    pickListOptions: pickListOptions,
                    isDisabledRow : isDisabledRow
                }
            })
            if (count == result.data.parentRecords.length) {
                this.addDocDetailDev = true;
            }
            // this.getContentDoc(docIds, 'pddadditionalHandler');
            this.refreshUi = true;
            this.showAddDocDetail = true;
        } else {
            this.addDocDetailDev = true;
            this.showAddDocDetail = false;
        }
        if (result.error) {
            console.error(result.error);
        }
    }

    //LAK-6458
    docCat4 = 'Sanction Condition Documents';
    docStatus3 = 'PDD';
    @track manualDocDetail;
    @track manualDocDetailDev = false;
    @track manual = {
        ParentObjectName: 'DocDtl__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'DocTyp__c', 'Appr_Actn__c', 'Rmrk__c', 'DocSubTyp__c', 'Criticality__c', 'DocStatus__c', 'DevLvl__c', 'AppvdRmrks__c'],
        childObjFields: [],
        queryCriteria: ' where DocCatgry__c = \'' + this.docCat4 + '\' AND DocStatus__c = \'' + this.docStatus2 + '\' AND LAN__c = \'' + this._loanAppId + '\''
    }
    @track showManualDocDetail = false;
    @track wiredDataResultPddSan = {};
    @wire(getSobjectData, { params: '$manual', picklist: '$approvalActionOptions' })
    pddsanctionHandler(result) {
        this.manualDocDetail = [];
        this.manualDocDetailDev = false;
        this.wiredDataResultPddSan = result;
        if (result.data && result.data.parentRecords) {
            let count = 0;
            let docIds = [];
            console.log('DATA IN OTC Property ::::>>>>', result.data);
            this.manualDocDetail = result.data.parentRecords.map(currItem => {
                docIds.push(currItem.Id);
                if (currItem.Appr_Actn__c == 'Approved') {
                    count++;
                }
                let pickListOptions = this.approvalActionOptions;
                console.log('In line 1673', result.data.parentRecords);
                let isDisabledRow = false;
                if(currItem.DevLvl__c > this.devLevel || this.isReadOnly){
                    isDisabledRow = true;
                }
                return {
                    ...currItem,
                    pickListOptions: pickListOptions,
                    isDisabledRow : isDisabledRow
                }
            })
            if (count == result.data.parentRecords.length) {
                this.manualDocDetailDev = true;
            }
            this.refreshUi = true;
            this.showManualDocDetail = true;
        } else {
            this.manualDocDetailDev = true;
            this.showManualDocDetail = false;
        }
        if (result.error) {
            console.error(result.error);
        }
    }

    //OTC starts Here
    docCat = 'Property Documents';
    otcdocStatus1 = 'OTC';
    @track DocDetailotc;
    @track DocDetailotcDev = false;
    @track otcperms = {
        ParentObjectName: 'DocDtl__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'DocTyp__c', 'Appr_Actn__c', 'Rmrk__c', 'DocSubTyp__c', 'Criticality__c', 'DocStatus__c', 'DevLvl__c', 'AppvdRmrks__c'],
        childObjFields: [],
        queryCriteria: ' where DocCatgry__c = \'' + this.docCat + '\' AND DocStatus__c = \'' + this.otcdocStatus1 + '\' AND LAN__c = \'' + this._loanAppId + '\''
    }
    @track refreshUi = false;
    @track showDocDetailotc = false;

    @wire(getSobjectData, {
        params: '$otcperms',
        picklist: '$approvalActionOptions'
    })
    otcpropertyHandler(result) {
        this.DocDetailotc = [];
        this.DocDetailotcDev = false;
        this.wiredDataResult = result;
        if (result.data && result.data.parentRecords) {
            let count = 0;
            let docIds = [];
            console.log('DATA IN OTC Property ::::>>>>', result.data);
            //this.DocDetailotc = result.data.parentRecords;
            this.DocDetailotc = result.data.parentRecords.map(currItem => {
                docIds.push(currItem.Id);
                if (currItem.Appr_Actn__c == 'Approved') {
                    count++;
                }
                let pickListOptions = this.approvalActionOptions;
                let isDisabledRow = false;
                if(currItem.DevLvl__c > this.devLevel || this.isReadOnly){
                    isDisabledRow = true;
                }
                return {
                    ...currItem,
                    pickListOptions: pickListOptions,
                    isDisabledRow : isDisabledRow
                }
            })
            if (count == result.data.parentRecords.length) {
                this.DocDetailotcDev = true;
            }
            this.showDocDetailotc = true;//LAK-7496
            // this.getContentDoc(docIds, 'otcpropertyHandler');
            console.log('DocDetailotc ::::>>>>', this.DocDetailotc);
            this.refreshUi = true;
        } else {
            this.DocDetailotcDev = true;
            this.showDocDetailotc = false;//LAK-7496
        } if (result.error) {
            console.error(result.error);
        }
    }
    docCat2 = 'Mandatory Post Sanction Documents';
    otcdocStatus2 = 'OTC';
    @track postDocDetailotc;
    @track postDocDetailotcDev = false;
    @track otcperms2 = {
        ParentObjectName: 'DocDtl__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'DocTyp__c', 'Appr_Actn__c', 'Rmrk__c', 'DocSubTyp__c', 'Criticality__c', 'DocStatus__c', 'DevLvl__c', 'AppvdRmrks__c'],
        childObjFields: [],
        queryCriteria: ' where DocCatgry__c = \'' + this.docCat2 + '\' AND DocStatus__c = \'' + this.otcdocStatus2 + '\' AND LAN__c = \'' + this._loanAppId + '\''
    }

    @track wiredDataResultMandaOtcPost = {};
    @track showPostDocDetailotc = false;
    @wire(getSobjectData, {
        params: '$otcperms2',
        picklist: '$approvalActionOptions'
    })
    otcmandatoryHandler(result) {
        this.postDocDetailotc = [];
        this.postDocDetailotcDev = false;
        this.wiredDataResultMandaOtcPost = result;
        if (result.data && result.data.parentRecords) {
            let count = 0;
            let docIds = [];
            console.log('DATA IN OTC Property ::::>>>>', result.data);
            this.postDocDetailotc = result.data.parentRecords.map(currItem => {
                docIds.push(currItem.Id);
                if (currItem.Appr_Actn__c == 'Approved') {
                    count++;
                }
                let pickListOptions = this.approvalActionOptions;
                let isDisabledRow = false;
                if(currItem.DevLvl__c > this.devLevel || this.isReadOnly){
                    isDisabledRow = true;
                }
                return {
                    ...currItem,
                    pickListOptions: pickListOptions,
                    isDisabledRow : isDisabledRow
                }
            })
            if (count == result.data.parentRecords.length) {
                this.postDocDetailotcDev = true;
            }
            // this.getContentDoc(docIds, 'otcmandatoryHandler');
            this.refreshUi = true;
            this.showPostDocDetailotc = true;//LAK-7496
        } else {
            this.showPostDocDetailotc = false;//LAK-7496
            this.postDocDetailotcDev = true;
        } if (result.error) {
            console.error(result.error);
        }
    }

    docCat3 = 'Additional Post Sanction Documents';
    otcdocStatus3 = 'OTC';
    @track addDocDetailotc;
    @track addDocDetailotcDev = false;
    @track otcperms3 = {
        ParentObjectName: 'DocDtl__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'DocTyp__c', 'Appr_Actn__c', 'Rmrk__c', 'DocSubTyp__c', 'Criticality__c', 'DocStatus__c', 'DevLvl__c', 'AppvdRmrks__c'],
        childObjFields: [],
        queryCriteria: ' where DocCatgry__c = \'' + this.docCat3 + '\' AND DocStatus__c = \'' + this.otcdocStatus3 + '\' AND LAN__c = \'' + this._loanAppId + '\''
    }
    @track showAddDocDetailotc = false;
    @track wiredDataResultOtcAdd = {};
    @wire(getSobjectData, {
        params: '$otcperms3',
        picklist: '$approvalActionOptions'
    })
    otcadditionalHandler(result) {
        this.addDocDetailotc = [];
        this.addDocDetailotcDev = false;
        this.wiredDataResultOtcAdd = result;
        if (result.data && result.data.parentRecords) {
            let count = 0;
            let docIds = [];
            console.log('DATA IN  OTC Add Post Sanction ::::>>>>', result.data);
            this.addDocDetailotc = result.data.parentRecords.map(currItem => {
                docIds.push(currItem.Id);
                if (currItem.Appr_Actn__c == 'Approved') {
                    count++;
                }
                let pickListOptions = this.approvalActionOptions;
                let isDisabledRow = false;
                if(currItem.DevLvl__c > this.devLevel || this.isReadOnly){
                    isDisabledRow = true;
                }
                return {
                    ...currItem,
                    pickListOptions: pickListOptions,
                    isDisabledRow : isDisabledRow
                }
            })
            if (count == result.data.parentRecords.length) {
                this.addDocDetailotcDev = true;
            }
            this.refreshUi = true;
            this.showAddDocDetailotc = true;//LAK-7496

        } else {
            this.showAddDocDetailotc = false;//LAK-7496
            this.addDocDetailotcDev = true;
        }
        if (result.error) {
            console.error(result.error);
        }
    }

    //LAK-6458
    docCat4 = 'Sanction Condition Documents';
    otcdocStatus3 = 'OTC';
    @track manualDocDetailotc;
    @track manualDocDetailotcDev = false;
    @track otcperms4 = {
        ParentObjectName: 'DocDtl__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'DocTyp__c', 'Appr_Actn__c', 'Rmrk__c', 'DocSubTyp__c', 'Criticality__c', 'DocStatus__c', 'DevLvl__c', 'AppvdRmrks__c'],
        childObjFields: [],
        queryCriteria: ' where DocCatgry__c = \'' + this.docCat4 + '\' AND DocStatus__c = \'' + this.otcdocStatus3 + '\' AND LAN__c = \'' + this._loanAppId + '\''
    }
    @track showManualDocDetailotc = false;
    @track wiredDataResultOtcSan = {};
    @wire(getSobjectData, {
        params: '$otcperms4',
        picklist: '$approvalActionOptions'
    })
    otcsanctionHandler(result) {
        this.manualDocDetailotc = [];
        this.manualDocDetailotcDev = false;
        this.wiredDataResultOtcSan = result;
        if (result.data && result.data.parentRecords) {
            let count = 0;
            let docIds = [];
            console.log('DATA IN  OTC manual Sanction ::::>>>>', result.data);
            //this.manualDocDetailotc = result.data.parentRecords;
            this.manualDocDetailotc = result.data.parentRecords.map(currItem => {
                docIds.push(currItem.Id);
                if (currItem.Appr_Actn__c == 'Approved') {
                    count++;
                }
                let pickListOptions = this.approvalActionOptions;
                let isDisabledRow = false;
                if(currItem.DevLvl__c > this.devLevel || this.isReadOnly){
                    isDisabledRow = true;
                }
                return {
                    ...currItem,
                    pickListOptions: pickListOptions,
                    isDisabledRow : isDisabledRow
                }
            })
            if (count == result.data.parentRecords.length) {
                this.manualDocDetailotcDev = true;
            }
            // this.getContentDoc(docIds, 'otcsanctionHandler');
            this.refreshUi = true;
            this.showManualDocDetailotc = true;

        } else {
            this.showManualDocDetailotc = false;
            this.manualDocDetailotcDev = true;
        }
        if (result.error) {
            console.error(result.error);

        }
    }

    //Wavier starts Here

    docCat = 'Property Documents';
    wavierdocStatus1 = 'Waiver';
    @track DocDetailWavier;
    @track DocDetailWavierDev = false;
    @track wavierperms = {
        ParentObjectName: 'DocDtl__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'DocTyp__c', 'Appr_Actn__c', 'Rmrk__c', 'DocSubTyp__c', 'Criticality__c', 'DocStatus__c', 'DevLvl__c', 'AppvdRmrks__c'],
        childObjFields: [],
        queryCriteria: ' where DocCatgry__c = \'' + this.docCat + '\' AND DocStatus__c = \'' + this.wavierdocStatus1 + '\' AND LAN__c = \'' + this._loanAppId + '\''
    }
    @track wiredDataResultWavProp = {};
    @track showDocDetailWavier = false;
    @wire(getSobjectData, {
        params: '$wavierperms',
        picklist: '$approvalActionOptions'
    })
    wavierpropertyHandler(result) {
        this.DocDetailWavier = [];
        this.DocDetailWavierDev = false;
        this.wiredDataResultWavProp = result;
        if (result.data && result.data.parentRecords) {
            let count = 0;
            let docIds = [];
            console.log('DATA IN Wavier Property ::::>>>>', result.data);
            // this.DocDetailWavier = result.data.parentRecords;
            this.DocDetailWavier = result.data.parentRecords.map(currItem => {
                docIds.push(currItem.Id);
                if (currItem.Appr_Actn__c == 'Approved') {
                    count++;
                }
                let pickListOptions = this.approvalActionOptions;
                let isDisabledRow = false;
                if(currItem.DevLvl__c > this.devLevel || this.isReadOnly){
                    isDisabledRow = true;
                }
                return {
                    ...currItem,
                    pickListOptions: pickListOptions,
                    isDisabledRow : isDisabledRow
                }
            })
            if (count == result.data.parentRecords.length) {
                this.DocDetailWavierDev = true;
            }
            // this.getContentDoc(docIds, 'wavierpropertyHandler');
            this.refreshUi = true;
            this.showDocDetailWavier = true;

        } else {
            this.DocDetailWavierDev = true;
            this.showDocDetailWavier = false;
        }
        if (result.error) {
            console.error(result.error);
        }
    }

    docCat2 = 'Mandatory Post Sanction Documents';
    wavierdocStatus2 = 'Waiver';
    @track postDocDetailWavier;
    @track postDocDetailWavierDev = false;
    @track wavierperms2 = {
        ParentObjectName: 'DocDtl__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'DocTyp__c', 'Appr_Actn__c', 'Rmrk__c', 'DocSubTyp__c', 'Criticality__c', 'DocStatus__c', 'DevLvl__c', 'AppvdRmrks__c'],
        childObjFields: [],
        queryCriteria: ' where DocCatgry__c = \'' + this.docCat2 + '\' AND DocStatus__c = \'' + this.wavierdocStatus2 + '\' AND LAN__c = \'' + this._loanAppId + '\''
    }
    @track wiredDataResultWavPost = {};
    @track showPostDocDetailWavier = false;
    @wire(getSobjectData, {
        params: '$wavierperms2',
        picklist: '$approvalActionOptions'
    })
    waviermandatoryHandler(result) {
        this.postDocDetailWavier = [];
        this.postDocDetailWavierDev = false;
        this.wiredDataResultWavPost = result;
        if (result.data && result.data.parentRecords) {
            let count = 0;
            let docIds = [];
            console.log('DATA IN Wavier Post Sanction ::::>>>>', result.data);
            //this.postDocDetailWavier = result.data.parentRecords;
            this.postDocDetailWavier = result.data.parentRecords.map(currItem => {
                docIds.push(currItem.Id);
                if (currItem.Appr_Actn__c == 'Approved') {
                    count++;
                }
                let pickListOptions = this.approvalActionOptions;
                let isDisabledRow = false;
                if(currItem.DevLvl__c > this.devLevel || this.isReadOnly){
                    isDisabledRow = true;
                }
                return {
                    ...currItem,
                    pickListOptions: pickListOptions,
                    isDisabledRow : isDisabledRow
                }
            })
            if (count == result.data.parentRecords.length) {
                this.postDocDetailWavierDev = true;
            }
            // this.getContentDoc(docIds, 'waviermandatoryHandler');
            this.refreshUi = true;
            this.showPostDocDetailWavier = true;

        } else {
            this.postDocDetailWavierDev = true;
            this.showPostDocDetailWavier = false;
        }
        if (result.error) {
            console.error(result.error);
        }
    }

    docCat3 = 'Additional Post Sanction Documents';
    wavierdocStatus3 = 'Waiver';
    @track addDocDetailWavier;
    @track addDocDetailWavierDev = false;
    @track wavierperms3 = {
        ParentObjectName: 'DocDtl__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'DocTyp__c', 'Appr_Actn__c', 'Rmrk__c', 'DocSubTyp__c', 'Criticality__c', 'DocStatus__c', 'DevLvl__c', 'AppvdRmrks__c'],
        childObjFields: [],
        queryCriteria: ' where DocCatgry__c = \'' + this.docCat3 + '\' AND DocStatus__c = \'' + this.wavierdocStatus3 + '\' AND LAN__c = \'' + this._loanAppId + '\''
    }
    @track showAddDocDetailWavier = false;
    @track wiredDataResultWavAdd = {};
    @wire(getSobjectData, {
        params: '$wavierperms3',
        picklist: '$approvalActionOptions'
    })
    wavieradditionalHandler(result) {
        this.addDocDetailWavier = [];
        this.addDocDetailWavierDev = false;
        this.wiredDataResultWavAdd = result;
        if (result.data && result.data.parentRecords) {
            let count = 0;
            let docIds = [];
            console.log('DATA IN  Wavier Add Post Sanction ::::>>>>', result.data);
            //this.addDocDetailWavier = result.data.parentRecords;
            this.addDocDetailWavier = result.data.parentRecords.map(currItem => {
                docIds.push(currItem.Id);
                if (currItem.Appr_Actn__c == 'Approved') {
                    count++;
                }
                let pickListOptions = this.approvalActionOptions;
                let isDisabledRow = false;
                if(currItem.DevLvl__c > this.devLevel || this.isReadOnly){
                    isDisabledRow = true;
                }
                return {
                    ...currItem,
                    pickListOptions: pickListOptions,
                    isDisabledRow : isDisabledRow
                }
            })
            if (count == result.data.parentRecords.length) {
                this.addDocDetailWavierDev = true;
            }
            // this.getContentDoc(docIds, 'wavieradditionalHandler');
            this.refreshUi = true;
            this.showAddDocDetailWavier = true;

        } else {
            this.showAddDocDetailWavier = false;
            this.addDocDetailWavierDev = true;
        }
        if (result.error) {
            console.error(result.error);
        }
    }

    // LAK-6458
    docCat4 = 'Sanction Condition Documents';
    wavierdocStatus3 = 'Waiver';
    @track manualDocDetailWavier;
    @track manualDocDetailWavierDev = false;
    @track wavierperms4 = {
        ParentObjectName: 'DocDtl__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'DocTyp__c', 'Appr_Actn__c', 'Rmrk__c', 'DocSubTyp__c', 'Criticality__c', 'DocStatus__c', 'DevLvl__c', 'AppvdRmrks__c'],
        childObjFields: [],
        queryCriteria: ' where DocCatgry__c = \'' + this.docCat4 + '\' AND DocStatus__c = \'' + this.wavierdocStatus3 + '\' AND LAN__c = \'' + this._loanAppId + '\''
    }
    @track showManualDocDetailWavier = false;
    @track wiredDataResultWavSan = {};
    @wire(getSobjectData, {
        params: '$wavierperms4',
        picklist: '$approvalActionOptions'
    })
    waviersanctionHandler(result) {
        this.manualDocDetailWavier = [];
        this.manualDocDetailWavierDev = false;
        this.wiredDataResultWavSan = result;

        if (result.data && result.data.parentRecords) {
            let count = 0;
            let docIds = [];
            console.log('DATA IN  Wavier Manual ::::>>>>', result.data);
            this.manualDocDetailWavier = result.data.parentRecords.map(currItem => {
                docIds.push(currItem.Id);
                if (currItem.Appr_Actn__c == 'Approved') {
                    count++;
                }
                let pickListOptions = this.approvalActionOptions;
                let isDisabledRow = false;
                if(currItem.DevLvl__c > this.devLevel || this.isReadOnly){
                    isDisabledRow = true;
                }
                return {
                    ...currItem,
                    pickListOptions: pickListOptions,
                    isDisabledRow : isDisabledRow
                }
            })
            if (count == result.data.parentRecords.length) {
                this.manualDocDetailWavierDev = true;
            }
            // this.getContentDoc(docIds, 'waviersanctionHandler');
            this.refreshUi = true;
            this.showManualDocDetailWavier = true;

        } else {
            this.showManualDocDetailWavier = false;
            this.manualDocDetailWavierDev = true;
        }
        if (result.error) {
            console.error(result.error);
        }
    }

    //Deviation starts here
    divCat1 = 'Legal';
    divCat2 = 'Post Sanction Auto Deviation';
    divCat3 = 'Disbursal';
    @track deviationData;
    @track deviationDataDev = false;
    @track deviationperms = {
        ParentObjectName: 'Deviation__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Appr_Actn__c', 'Devia_Desrp__c', 'DocDesc__c', 'Appr_Remarks__c', 'Req_Apprv_Level__c', 'Mitigation__c', 'DeviationCategory__c', 'IntLegalRem__c'],
        childObjFields: [],
        queryCriteria: ' where DeviationCategory__c IN(\'' + this.divCat1 + '\',\'' + this.divCat2 + '\',\'' + this.divCat3 + '\') ' + 'AND LoanAppln__c = \'' + this._loanAppId + '\' order by DeviationCategory__c '
    }
    @track showDeviationData = false;
    @track wiredDataResultDiv = {};
    @wire(getSobjectData, {
        params: '$deviationperms',
        picklist: '$approvalActionOptions'
    })
    deviationHandler(result) {
        this.deviationData = [];
        this.deviationDataDev = false;
        this.wiredDataResultDiv = result;
        if (result.data && result.data.parentRecords) {
            let count = 0;
            console.log('DATA IN  Deviation ::::>>>>', result.data);
            this.deviationData = result.data.parentRecords;
            this.divdevLevel = result.data.parentRecords[0].Req_Apprv_Level__c;
            console.log('this.divdevLevel', this.divdevLevel);
            if (this.devLevel >= this.divdevLevel) {
                this.retval2 = true;
            } else {
                this.retval2 = false;
            }
            this.deviationData = result.data.parentRecords.map(currItem => {
                if (currItem.Appr_Actn__c == 'Approved') {
                    count++;
                }
                let isDisabledRow = false;
                if(currItem.Req_Apprv_Level__c > this.devLevel || this.isReadOnly){
                    isDisabledRow = true;
                }
                let pickListOptions = this.approvalActionOptions;
                return {
                    ...currItem,
                    pickListOptions: pickListOptions,
                    isDisabledRow : isDisabledRow
                }
            })
            if (count == result.data.parentRecords.length) {
                this.deviationDataDev = true;
            }
            this.refreshUi = true;
            this.showDeviationData = true;
        } else {
            this.showDeviationData = false;
            this.deviationDataDev = true;
        }
        if (result.error) {
            console.error(result.error);
        }
    }

    //Post Sanction Deviation starts here
    retval3;
    postdivdevLevel;
    @track PostSandeviationData;
    @track showPostSandeviationData = false;
    @track PostSandeviationDataDev = false;
    @track postdeviationperms = {
        ParentObjectName: 'Deviation__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Appr_Actn__c', 'Deviation__c', 'DocDesc__c', 'ApprovedByName__c', 'Apprv_By__c', 'Devia_Desrp__c', 'Appr_Remarks__c', 'Req_Apprv_Level__c', 'Mitigation__c', 'BRE__c', 'IntLegalRem__c', 'BRE__r.Call_Id__c', 'BRE__r.IsLatest__c', 'BRE__r.LoanAppl__c,Format_App_Date__c'],
        childObjFields: [],
        queryCriteria: 'where CallId__c = 5 AND  Status__c=\'Active\' AND LoanAppln__c = \'' + this._loanAppId + '\' ORDER BY Req_Apprv_Level__c DESC'
    }
    @track wiredDataResultPostDiv = {};
    @wire(getSobjectData, {
        params: '$postdeviationperms',
        picklist: '$approvalActionOptions'
    })
    PostdeviationHandler(result) {
        this.PostSandeviationData = [];
        this.PostSandeviationDataDev = false;
        this.wiredDataResultPostDiv = result;
        if (result.data && result.data.parentRecords) {
            let count = 0;
            console.log('DATA IN Post Deviation ::::>>>>', result.data);
            this.PostSandeviationData = result.data.parentRecords;
            this.postdivdevLevel = result.data.parentRecords[0].Req_Apprv_Level__c;
            if (this.devLevel >= this.postdivdevLevel) {
                this.retval3 = true;
            } else {
                this.retval3 = false;
            }

            this.PostSandeviationData = result.data.parentRecords.map(currItem => {
                if (currItem.Appr_Actn__c == 'Approved') {
                    count++;
                }
                let pickListOptions = this.approvalActionOptions;
                let isDisabledRow = false;
                if(currItem.Req_Apprv_Level__c > this.devLevel || this.isReadOnly){
                    isDisabledRow = true;
                }
                return {
                    ...currItem,
                    pickListOptions: pickListOptions,
                    isDisabledRow : isDisabledRow
                }
            })
            if (count == result.data.parentRecords.length) {
                this.PostSandeviationDataDev = true;
            }
            this.refreshUi = true;
            this.showPostSandeviationData = true;
            console.log('this.PostSandeviationData ::::>>>>', this.PostSandeviationData);
        } else {
            this.PostSandeviationDataDev = true;
            this.showPostSandeviationData = false;
            this.retval3 = true;
        }
        if (result.error) {
            console.error(result.error);
        }
    }

    //LAK-7446 - BIL Approval Tray 
    @track splitDisData;
    @track showSplitDisTable = false;
    @track paramsSplitDis = {
        ParentObjectName: 'Split_Disbur__c',
        parentObjFields: ['Id', 'Name', 'Split_Cheque_Amt__c', 'Date_of_Disbur__c', 'Pay_Mode__c', 'Cheq_Favor_Dets__c', 'Disbur_To__c', 'DisburseRela__r.DisbrDiscription__c'],
        queryCriteria: ' where DisburseRela__r.Loan_Appli__c = \'' + this._loanAppId +  '\''
    }
    
    @wire(getSobjectData, {params: '$paramsSplitDis'})
    getSplitDisData(result){
        if(result.data && result.data.parentRecords){
            console.log('Split Dis Data', result.data);
            this.showSplitDisTable = true;
            this.splitDisData = result.data.parentRecords;
        }
        else if(result.error){
            console.log('Error in getting Split Disb Data',)
        }
    }


    //LAK-8001
    //Credit Deviations
    retval4;
    creditdivdevLevel;
    @track CreditdeviationData;
    @track showCreditdeviationData = false;
    @track CreditdeviationDataDev = false;
    @track creddeviationperms = {
        ParentObjectName: 'Deviation__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Appr_Actn__c', 'Deviation__c', 'DocDesc__c', 'ApprovedByName__c', 'Apprv_By__c', 'Devia_Desrp__c', 'Appr_Remarks__c', 'Dev_Type__c','Req_Apprv_Level__c', 'Mitigation__c', 'BRE__c', 'IntLegalRem__c', 'BRE__r.Call_Id__c', 'BRE__r.IsLatest__c', 'BRE__r.LoanAppl__c, Format_App_Date__c'],
        childObjFields: [],
        queryCriteria:  ' where LoanAppln__c = \'' + this._loanAppId + '\' AND (Dev_Type__c =\'Manual\' OR (Dev_Type__c =\'System\' AND Status__c=\'Active\' AND  CallId__c= 4) ) AND (Appr_Actn__c = \'\' OR (Appr_Actn__c != \'\' AND  AppStage__c = \'Post Sanction\')) ORDER BY Req_Apprv_Level__c DESC'
    }
    
    @track wiredDataResultCredDiv = {};
    @wire(getSobjectData, {
        params: '$creddeviationperms',
        picklist: '$approvalActionOptions'
    })
    //LAK-8001
    CreditdeviationHandler(result) {
        this.CreditdeviationData = [];
        this.CreditdeviationDataDev = false;
        this.wiredDataResultCredDiv = result;
        if (result.data && result.data.parentRecords) {
            let count = 0;
            console.log('DATA IN Credit Deviation ::::>>>>', result.data);
            this.CreditdeviationData = result.data.parentRecords;
            this.creditdivdevLevel = result.data.parentRecords[0].Req_Apprv_Level__c;
            if (this.devLevel >= this.creditdivdevLevel) {
                this.retval4 = true;
            } else {
                this.retval4 = false;
            }
            

            this.CreditdeviationData = result.data.parentRecords.map(currItem => {
                if (currItem.Appr_Actn__c == 'Approved') {
                    count++;
                }
                let pickListOptions = this.approvalActionOptions;
                let isDisabledRow = false;
                if(currItem.Req_Apprv_Level__c > this.devLevel || this.isReadOnly){
                    isDisabledRow = true;
                }
                return {
                    ...currItem,
                    pickListOptions: pickListOptions,
                    isDisabledRow : isDisabledRow
                }
            })
            if (count == result.data.parentRecords.length) {
                this.CreditdeviationDataDev = true;
            }
            this.refreshUi = true;
            this.showCreditdeviationData = true;
            console.log('this.CreditdeviationData ::::>>>>', this.CreditdeviationData);
        } else {
            this.CreditdeviationDataDev = true;
            this.showCreditdeviationData = false;
            this.retval4 = true;
            
        }
        if (result.error) {
            console.error(result.error);
        }
    }


    //create fee

    createFeed() {
        let fields = {};
        fields['sobjectType'] = 'FeedItem';
        fields['ParentId'] = this.loanApplicationRecord.Id;
        fields['Body'] = 'Loan forwarded to ' + this.ForwardToUserName + ' with remarks: ' + this.frwdUWRemarks;
        this.upsertFeed(fields);

    }

    upsertFeed(obj) {
        let newArr = [];
        if (obj) {
            newArr.push(obj);
        }
        if (newArr.length > 0) {
            console.log('new array is ', JSON.stringify(newArr));
            upsertSObjectRecord({ params: newArr })
                .then((result) => {
                })
                .catch((error) => {
                    console.log('error in creating feed ', JSON.stringify(error));

                });
        }
    }

    DocumentDetaiId;
    handleGenerateDocuments() {
        this.showSpinner = true;
        this.showDocList = false;
        console.log('applicant', this.loanApplicationRecord.Applicant__c);
        console.log('loanId', this.loanApplicationRecord.Id);
        createDocumentDetail({ applicantId: this.loanApplicationRecord.Applicant__c, loanAppId: this.loanApplicationRecord.Id, docCategory: 'Disbursement Memo', docType: 'Disbursement Memo', docSubType: 'Disbursement Memo', availableInFile: false })
            .then((result) => {
                console.log('createDocumentDetailRecord result ', result);
                this.DocumentDetaiId = result;
                console.log('createDocumentDetailRecord DocumentDetaiId ', this.DocumentDetaiId);
                let pageUrl = this.label.disbursementMemo + this.loanApplicationRecord.Id;
                const pdfData = {
                    pageUrl: pageUrl,
                    docDetailId: this.DocumentDetaiId,
                    fileName: 'Disbursement Memo.pdf'
                }
                this.generateDocument(pdfData);

            })
            .catch((err) => {
                this.showToast("Error", err, "error", "sticky");
                console.log(" createDocumentDetailRecord error===", err);
            });
    }

    generateDocument(pdfData) {
        generateDocument({ wrapObj: pdfData })
            .then((result) => {
                this.showSpinner = false;
                if (result == 'success') {
                    this.forLatestDocDetailRec();
                } else {
                    console.log('doc Result', result);
                }
            })
            .catch((err) => {
                this.showToast("Error", err, "error", "sticky");
                console.log(" createDocumentDetailRecord error===", err);
            });
    }
    forLatestDocDetailRec() {
        let docCat = 'Disbursement Memo';
        let listOfAllParent = [];
        let paramForIsLatest = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'Appl__c', 'AppvdRmrks__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c'],
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this.loanApplicationRecord.Id + '\' AND Appl__c = \'' + this.loanApplicationRecord.Applicant__c + '\' AND DocCatgry__c = \'' + docCat + '\' AND DocTyp__c = \'' + docCat + '\' AND DocSubTyp__c = \'' + docCat + '\''
        }
        getSobjectDat({ params: paramForIsLatest })
            .then((result) => {
                if (result.parentRecords) {
                    listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
                }
                let oldRecords = []
                oldRecords = listOfAllParent.filter(record => record.Id !== this.DocumentDetaiId);
                let isLatestFalseRecs = []
                isLatestFalseRecs = oldRecords.map(record => {
                    return { ...record, IsLatest__c: false };
                });
                let obj = {
                    Id: this.DocumentDetaiId,
                    AppvdRmrks__c: isLatestFalseRecs && isLatestFalseRecs.length > 0 ? isLatestFalseRecs[0].AppvdRmrks__c : ''
                }
                isLatestFalseRecs.push(obj);
                upsertSObjectRecord({ params: isLatestFalseRecs })
                    .then(result => {
                        this.refreshDocTable();
                        console.log('result ' + JSON.stringify(result));
                    }).catch(error => {
                        this.showSpinner = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Error while getting Latest DM Records',
                                variant: 'error',
                                mode: 'sticky'
                            })
                        );
                        console.log('778' + error)
                    })
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log(" Getting doc dtl data error===", error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error while getting Latest DM Records',
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                console.log('Error In getting Document Details  ', error);
            });
    }
    ApprovalTray_GenDoc_ErrorMessage

    CamDocumentDetaiId;
    handleGenerateCamReport() {
        console.log('applicant', this.loanApplicationRecord.Applicant__c);
        console.log('loanId', this.loanApplicationRecord.Id);
        createDocumentDetail({ applicantId: this.loanApplicationRecord.Applicant__c, loanAppId: this.loanApplicationRecord.Id, docCategory: 'CAM Report', docType: 'CAM Report', docSubType: 'CAM Report', availableInFile: false })
            .then((result) => {
                this.CamDocumentDetaiId = result;
                console.log('createCamRecord CamDocumentDetaiId ', this.CamDocumentDetaiId);
                let pageUrl = PageURLCAMReporrt + this.loanApplicationRecord.Id;
                console.log('pageurl', pageUrl);
                const pdfData = {
                    pageUrl: pageUrl,
                    docDetailId: this.CamDocumentDetaiId,
                    fileName: 'CAM Report.pdf'
                }
                this.generateCamDocument(pdfData);

            })
            .catch((err) => {
                this.showToast("Error", err, "error", "sticky");
                console.log(" createDocumentDetailRecord error===", err);
            });
    }


    generateCamDocument(pdfData) {
        generateDocument({ wrapObj: pdfData })
            .then((result) => {
                if (result == 'success') {
                    this.forLatestDocDetailRecCAM();
                } else {
                    console.log('doc Result', result);
                }
            })
            .catch((err) => {
                this.showToast("Error", err, "error", "sticky");
                console.log(" createCam Report error===", err);
            });
    }
    forLatestDocDetailRecCAM() {
        let docCategory = 'CAM Report';
        console.log('document details in forLatestDocDetailRecCAM');
        let listOfAllParent = [];
        let paramForIsLatest = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'Appl__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c'],
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this.loanApplicationRecord.Id + '\' AND Appl__c = \'' + this.loanApplicationRecord.Applicant__c + '\' AND DocCatgry__c = \'' + docCategory + '\' AND DocTyp__c = \'' + docCategory + '\' AND DocSubTyp__c = \'' + docCategory + '\''
        }
        getSobjectDat({ params: paramForIsLatest })
            .then((result) => {
                console.log('islatestdata 13899999', this.CamDocumentDetaiId);
                if (result.parentRecords) {
                    listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
                }
                let oldRecords = []
                oldRecords = listOfAllParent.filter(record => record.Id !== this.CamDocumentDetaiId);
                let isLatestFalseRecs = []
                isLatestFalseRecs = oldRecords.map(record => {
                    return { ...record, IsLatest__c: false };
                });
                let obj = {
                    Id: this.CamDocumentDetaiId,
                    NDCDataEntry__c: 'Completed',
                    AppvdRmrks__c: this.camRemarks

                }
                isLatestFalseRecs.push(obj);
                console.log('isLatestFalseRecs>>>>>' + JSON.stringify(isLatestFalseRecs))
                upsertSObjectRecord({ params: isLatestFalseRecs })
                    .then(result => {
                        console.log('result ' + JSON.stringify(result));
                    }).catch(error => {
                        this.showSpinner = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Error in getting Latest CAM',
                                variant: 'error',
                                mode: 'sticky'
                            })
                        );
                        this.dispatchEvent(new CloseActionScreenEvent());
                    })

            })
            .catch((error) => {
                this.showSpinner = false;
                console.log(" createDocumentDetailRecord error===", error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error while create a Document',
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                console.log('Error In getting Document Details  ', error);
            });
    }


    refreshDocTable() {
        this.showDocList = true;
        this.showSpinner = false;
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
    createUWDecesionRecord() {
        let fields = {};
        fields['sobjectType'] = 'UWDecision__c';
        fields['LoanAppl__c'] = this._loanAppId;
        fields['Date_Time__c'] = this.currentDateTime;
        fields['User__c'] = this.userId;
        fields['DecisionRmrks__c'] = this.memoRemarks ? this.memoRemarks : '';
        fields['AddationalComm__c'] = this.camRemarks ? this.camRemarks : '';
        fields['Decision_Type__c'] = 'Approval Remarks';
        this.upsertUwDecision(fields);
    }

    createUWDecesionRecordNew() {
        let fields = {};
        fields['sobjectType'] = 'UWDecision__c';
        fields['LoanAppl__c'] = this._loanAppId;
        fields['Date_Time__c'] = this.currentDateTime;
        fields['User__c'] = this.userId;
        fields['DecisionRmrks__c'] = this.frwdUWRemarks ? this.frwdUWRemarks : '';
        fields['Decision_Type__c'] = 'Forward To UW';
        fields['Stage__c'] = 'Post Sanction';
        fields['SubStage__c'] = 'UW Approval';
        this.upsertUwDecision(fields);
    }
    upsertUwDecision(obj) {
        let newArr = [];
        if (obj) {
            newArr.push(obj);
        }
        if (newArr.length > 0) {
            console.log('new array is ', JSON.stringify(newArr));
            upsertSObjectRecord({ params: newArr })
                .then((result) => {
                    console.log('resultprinted ');
                })
                .catch((error) => {
                    console.log('error in upserting uw decision ', JSON.stringify(error));

                });
        }
    }

    sunscribeToSaveMessageChannel() {
        this.saveSubscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveLms(values)
        );
    }
    handleSaveLms(values) {
        console.log('values to save through Lms  ', JSON.stringify(values));
        console.log('this.draftvalues onclick of save ', this.draftValues);
        this.saveRemarks();

    }
    docCamType = 'CAM Report';
    camRec = [];
    @track camRemarks;
    getLatestCamReport() {

        let params = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'AppvdRmrks__c'],
            queryCriteria: ' where LAN__c = \'' + this._loanAppId + '\' AND DocTyp__c = \'' + this.docCamType + '\' order by createdDate desc'
        }
        getSobjectDat({ params: params })
            .then((result) => {
                this.camRec = result.parentRecords;
                console.log('result is get Cam Remarks latest', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.camRemarks = result.parentRecords[0].AppvdRmrks__c;
                    console.log('camRemarks===>', this.camRemarks);
                }
            })
            .catch((error) => {

                console.log("error occured in getting camRec", error);

            });
    }
    docMemoType = 'Disbursement Memo';
    MemoRec = [];
    @track memoRemarks;
    getLatestMemoReport() {

        let params = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'AppvdRmrks__c'],
            queryCriteria: ' where LAN__c = \'' + this._loanAppId + '\' AND DocTyp__c = \'' + this.docMemoType + '\' order by createdDate desc'
        }
        getSobjectDat({ params: params })
            .then((result) => {
                this.MemoRec = result.parentRecords;
                console.log('result is get doc Remarks latest ', JSON.stringify(result));

                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.memoRemarks = result.parentRecords[0].AppvdRmrks__c;
                }
                console.log('memoRemarks===>', this.memoRemarks);

            })
            .catch((error) => {
                console.log("error occured in getting MemoRec", error);

            });
    }

    async saveRemarks() {
        this.showSpinner = true;
        let val = await this.getDivRemarks();
        let val1 = await this.getDocRemarks();
        let val4 = await this.postgetDivRemarks();
        let val5 = await this.creditDivRemarks();//LAK-8001
        let valid = this.checkReportValidity();
        console.log('valid ', valid);
       
        if (!this.validateForm()) {
            this.showSpinner = false;
            this.showToastMessage('Error', 'Please fill the Remarks', 'error', 'sticky');
            return;

        }
        else if (!valid) {
            this.showSpinner = false;
            this.showToastMessage('Error', 'Required Fields are missing', 'error', 'sticky');
            return;
        }
        else if (this.memoRemarks && this.camRemarks) {

            this.updateMemoRecord('save');
        }
    }
    updateMemoRecord(val) {

        let arr = [];
        if (this.MemoRec && this.MemoRec.length > 0) {
            let obj = {
                Id: this.MemoRec[0].Id,
                sobjectType: "DocDtl__c",
                AppvdRmrks__c: this.memoRemarks,

            }
            arr.push(obj);
        }
        if (arr && arr.length > 0) {
            this.upsertDocData2(arr, val);
        }
    }
    upsertDocData2(arr, val) {
        console.log('arr ', arr);
        if (arr) {
            upsertSObjectRecord({ params: arr })
                .then((result) => {
                    this.updateCAMRecord(val);
                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log('error in upserting Document ', JSON.stringify(error));

                });
        }
    }
    updateCAMRecord(val) {
        let arr = [];
        if (this.camRec && this.camRec.length > 0) {
            let obj = {
                Id: this.camRec[0].Id,
                sobjectType: "DocDtl__c",
                AppvdRmrks__c: this.camRemarks,

            }
            arr.push(obj);
        }
        if (arr && arr.length > 0) {
            this.upsertDocData1(arr, val);
        }
    }
    upsertDocData1(arr, val) {
        console.log('arr ', arr);
        if (arr) {
            upsertSObjectRecord({ params: arr })
                .then((result) => {
                    console.log('Document resultprinted in ');
                    if (val == 'save') {

                        if (this.draftValues && this.draftValues.length > 0) {
                            this.updatedTablesData();
                        } else {
                            this.showSpinner = false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: "Success",
                                    message: "Data Saved Successfully",
                                    variant: "success",
                                    mode: "sticky"
                                })
                            );
                        }

                    }
                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log('error in upserting Document ', JSON.stringify(error));

                });
        }
    }
    updatedTablesData() {
        if (this.draftValues && this.draftValues.length > 0) {
            this.draftValues.forEach(item => {
                if (item.AppvdRmrks__c) {
                    item.AppvdRmrks__c = item.AppvdRmrks__c.toUpperCase();
                }
                if (item.Appr_Remarks__c) {
                    item.Appr_Remarks__c = item.Appr_Remarks__c.toUpperCase();
                }
                if (item.Mitigation__c) {
                    item.Mitigation__c = item.Mitigation__c.toUpperCase();
                }
            })
        }
        if (this.draftValues && this.draftValues.length > 0) {
            const recordInputs = this.draftValues.slice().map(draft => {
                const fields = Object.assign({}, draft);
                return { fields };
            });
            const promises = recordInputs.map(recordInput => updateRecord(recordInput));
            Promise.all(promises).then(() => {
                this.showSpinner = false;
                this.draftValues = [];
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Data Saved Successfully",
                        variant: "success",
                        mode: "sticky"
                    }),
                );
                this.showSpinner = true;
                this.errors = {};
                this.dispatchEvent(new RefreshEvent());
                this.refreshUi = false;
                setTimeout(() => {
                    this.showSpinner = false;
                }, 2000);

                //otc

                refreshApex(this.wiredDataResultPddProp);
                refreshApex(this.wiredDataResultPddSan);
                refreshApex(this.wiredDataResultPddAdd);
                refreshApex(this.wiredDataResultPddMan);
                //pdd
                refreshApex(this.wiredDataResult);
                refreshApex(this.wiredDataResultOtcSan);
                refreshApex(this.wiredDataResultOtcAdd);
                refreshApex(this.wiredDataResultMandaOtcPost);
                //wavier
                refreshApex(this.wiredDataResultWavSan);
                refreshApex(this.wiredDataResultWavAdd);
                refreshApex(this.wiredDataResultWavPost);
                refreshApex(this.wiredDataResultWavProp);
                //deviation & postsanction
                refreshApex(this.wiredDataResultDiv);
                refreshApex(this.wiredDataResultPostDiv);
                refreshApex(this.wiredDataResultCredDiv);

                //Added for LAK-7496
                this.showDocDetailotc = false;
                this.showPostDocDetailotc = false;
                this.showAddDocDetailotc = false;
                this.showManualDocDetailotc = false;
                //pdd
                this.showDocDetail = false;
                this.showPostDocDetail = false;
                this.showAddDocDetail = false;
                this.showManualDocDetail = false;
                //wavier
                this.showDocDetailWavier = false;
                this.showPostDocDetailWavier = false;
                this.showAddDocDetailWavier = false;
                this.showManualDocDetailWavier = false;

                //Deviation
                this.showDeviationData = false;
                this.showPostSandeviationData = false;
                this.showCreditdeviationData = false;//LAK-8001
                return refreshApex(this.wiredDataResult);
            }).catch(error => {
                console.log('error at 2817', error);
                this.showToastMessage('Error', this.Customlabel.ApprovalTray_Remarks_Update_ErrorMessage, 'error', 'Sticky');
            });
        }
    }
    @track expDetails = [];
    verfExp;
    getVerificationExpDet() {
        return new Promise((resolve, reject) => {
            checkExpiry({ loanApplicationId: this._loanAppId })
                .then((result) => {
                    console.log('VerificationExpiry Details', JSON.stringify(result));
                    if (result && result.length > 0) {
                        this.expDetails = result;
                        this.verfExp = true;
                    }
                    else {
                        this.verfExp = false;
                    }

                    resolve(this.verfExp);

                })
                .catch((error) => {
                    reject(error);
                    this.showSpinner = false;
                    console.log('Error In getting checkExpiry is ', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: error.body.message,
                            variant: 'error',
                            mode: 'sticky'
                        })
                    );

                });
        });
    }
    @track breVal;
    runBRE() {
        return new Promise((resolve, reject) => {
            let apiName = 'Crif Auth Login';
            let paramsLoanApp = {
                ParentObjectName: 'APICoutTrckr__c',
                parentObjFields: ['Id', 'LtstRespCode__c', 'IsInvalid__c'],
                queryCriteria: ' where LAN__c = \'' + this._loanAppId + '\' AND APIName__c = \'' + apiName + '\''
            }
            getSobjectData({ params: paramsLoanApp })
                .then((result) => {
                    console.log('api callout tracker data is', JSON.stringify(result));
                    if (result.parentRecords && result.parentRecords.length > 0) {
                        if (result.parentRecords[0].IsInvalid__c) {
                            this.breVal = true;
                        } else {
                            this.breVal = false;
                        }
                    }
                    else {
                        this.breVal = false;
                    }
                    resolve(this.breVal);
                })
                .catch((error) => {
                    reject(error);
                    console.log('Error In getting api callout tracker data is ', error);
                });
        });

    }
    // @track disbApprCheckbox = false;
    get disbApprCheckbox() {
        if ((this.DocDetailotc && this.DocDetailotc.length > 0) || (this.postDocDetailotc && this.postDocDetailotc.length > 0) || (this.addDocDetailotc && this.addDocDetailotc.length > 0) || (this.manualDocDetailotc && this.manualDocDetailotc.length > 0) || (this.manualDocDetailotc && this.manualDocDetailotc.length > 0) || (this.DocDetail && this.DocDetail.length > 0) || (this.postDocDetail && this.postDocDetail.length > 0) || (this.addDocDetail && this.addDocDetail.length > 0) || (this.manualDocDetail && this.manualDocDetail.length > 0) || (this.DocDetailWavier && this.DocDetailWavier.length > 0) || (this.postDocDetailWavier && this.postDocDetailWavier.length > 0) || (this.addDocDetailWavier && this.addDocDetailWavier.length > 0) || (this.manualDocDetailWavier && this.manualDocDetailWavier.length > 0) || (this.deviationData && this.deviationData.length > 0) || (this.PostSandeviationData && this.PostSandeviationData.length > 0) || (this.CreditdeviationData && this.CreditdeviationData.length > 0)) {//LAK-8001
            if (this.isReadOnly == false && (this.DocDetailDev == false || this.postDocDetailDev == false || this.addDocDetailotcDev == false || this.manualDocDetailDev == false || this.DocDetailotcDev == false || this.postDocDetailotcDev == false || this.addDocDetailotcDev == false || this.manualDocDetailotcDev == false || this.DocDetailWavierDev == false || this.postDocDetailWavierDev == false || this.addDocDetailWavierDev == false || this.manualDocDetailWavierDev == false || this.deviationDataDev == false || this.PostSandeviationDataDev == false || this.CreditdeviationDataDev == false)) {
                return false;
            }
            return true;
        }
        return true;
    }
    // @track _apprAllDevi

    get _apprAllDevi() {
        if ((this.DocDetailDev == true && this.postDocDetailDev == true && this.addDocDetailotcDev == true && this.manualDocDetailDev == true && this.DocDetailotcDev == true && this.postDocDetailotcDev == true && this.addDocDetailotcDev == true && this.manualDocDetailotcDev == true && this.DocDetailWavierDev == true && this.postDocDetailWavierDev == true && this.addDocDetailWavierDev == true && this.manualDocDetailWavierDev == true && this.deviationDataDev == true && this.PostSandeviationDataDev == true && this.CreditdeviationDataDev==true) || this.isReadOnly) {//LAK-8001
            return true;
        }
        return false;
    }
    @track apprAllDevi;
    async handleApprvChange(event) {
        this.apprAllDevi = event.detail.checked;
        let val = await this.getDivRemarks();
        let val1 = await this.getDocRemarks();
        let val4 = await this.postgetDivRemarks();
        //LAK-8001
        let val5 = await this.creditDivRemarks();
        console.log('this.apprAllDevi', this.apprAllDevi);
        console.log('this.divRec', this.divRec);
        if (this.apprAllDevi === true) {
            if (this.divRec && this.divRec.length > 0 || this.docRec && this.docRec.length > 0 || this.postdivRec && this.postdivRec.length > 0 ||  this.creditdivRec && this.creditdivRec.length > 0) {//LAK-8001
                if(this.retval !== true || this.retval2 !== true || this.retval3 !== true || this.retval4!==true){
                    this.showToastMessage('Error', this.Customlabel.ApprovalTray_Authority_ErrorMessage, 'error', 'sticky');
          
                }
                else{
                if (this.divRec && this.divRec.length > 0) {
                    this.updateDeviationRecord();
                }
                if (this.docRec && this.docRec.length > 0) {
                    this.updateDocRecord();
                }
                if (this.postdivRec && this.postdivRec.length > 0) {
                    this.updatePostDeviationRecord();
                }
                //LAK-8001
                if (this.creditdivRec && this.creditdivRec.length > 0){
                    this.updateCreditDeviationRecord();
                }
            }
            }
        }
    }
    updateDeviationRecord() {
        this.showSpinner = true;
        let arr = [];
        if (this.divRec && this.divRec.length > 0 && (this.allDevAppordActn == false || this.divAction == false)) {
            this.divRec.forEach(item => {
                let obj = {
                    sobjectType: "Deviation__c",
                    Id: item.Id,
                    Apprv_By__c: this.userId,
                    Appr_Actn__c: 'Approved',
                    Approved_Date__c: this.currentDateTime,
                    AppStage__c: this.stage
                }
                arr.push(obj);
            })
        }
        if (arr && arr.length > 0) {
            this.upsertDeviationData(arr);
        }
    }
    upsertDeviationData(arr) {
        console.log('arr ', arr);
        if (arr) {
            upsertSObjectRecord({ params: arr })
                .then((result) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Disbursal Deviations Approved Successfully',
                            variant: 'success',
                            mode: 'sticky'
                        })
                    );
                    this.showSpinner = false;
                    //deviation 
                    this.showDeviationData = false;
                    refreshApex(this.wiredDataResultDiv);

                })
                .catch((error) => {
                    console.log('error in upserting Deviation ', JSON.stringify(error));
                    this.showSpinner = false;
                });
        }
    }
    updatePostDeviationRecord() {
        this.showSpinner = true;
        let arr = [];
        if (this.postdivRec && this.postdivRec.length > 0 && (this.postdivAction == false || this.allDevAppordActn == false)) {
            this.postdivRec.forEach(item => {
                let obj = {
                    sobjectType: "Deviation__c",
                    Id: item.Id,
                    Apprv_By__c: this.userId,
                    Appr_Actn__c: 'Approved',
                    Approved_Date__c: this.currentDateTime,
                    AppStage__c: this.stage
                }
                arr.push(obj);
            })
        }
        if (arr && arr.length > 0) {
            this.upsertPostDeviationData(arr);
        }
    }
    upsertPostDeviationData(arr) {
        console.log('arr ', arr);
        if (arr) {
            upsertSObjectRecord({ params: arr })
                .then((result) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Post Sanction Deviations Approved Successfully',
                            variant: 'success',
                            mode: 'sticky'
                        })
                    );
                    this.showSpinner = false;
                    // Postsanction
                    this.showPostSandeviationData = false;
                    refreshApex(this.wiredDataResultPostDiv);

                })
                .catch((error) => {
                    console.log('error in upserting Deviation ', JSON.stringify(error));
                    this.showSpinner = false;
                });
        }
    }
    //LAK-8001
    updateCreditDeviationRecord() {
        this.showSpinner = true;
        let arr = [];
        if (this.creditdivRec && this.creditdivRec.length > 0 && (this.creditdivAction == false || this.allDevAppordActn == false)) {
            this.creditdivRec.forEach(item => {
                let obj = {
                    sobjectType: "Deviation__c",
                    Id: item.Id,
                    Apprv_By__c: this.userId,
                    Appr_Actn__c: 'Approved',
                    Approved_Date__c: this.currentDateTime,
                    AppStage__c: this.stage
                }
                arr.push(obj);
            })
        }
        if (arr && arr.length > 0) {
            this.upsertCreditDeviationData(arr);
        }
    }
    upsertCreditDeviationData(arr) {
        console.log('arr ', arr);
        if (arr) {
            upsertSObjectRecord({ params: arr })
                .then((result) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Credit Deviations Approved Successfully',
                            variant: 'success',
                            mode: 'sticky'
                        })
                    );
                    this.showSpinner = false;
                    // Credit
                    this.showCreditdeviationData = false;
                    refreshApex(this.wiredDataResultCredDiv);

                })
                .catch((error) => {
                    console.log('error in upserting Deviation ', JSON.stringify(error));
                    this.showSpinner = false;
                });
        }
    }

    updateDocRecord() {
        this.showSpinner = true;
        let arr = [];
        if (this.docRec && this.docRec.length > 0 && (this.docAction == false || this.allDocAppordActn == false)) {
            this.docRec.forEach(item => {
                let obj = {
                    sobjectType: "DocDtl__c",
                    Id: item.Id,
                    Apprv_By__c: this.userId,
                    Appr_Actn__c: 'Approved',
                    Approved_Date__c: this.currentDateTime
                }
                arr.push(obj);
            })
        }

        if (arr && arr.length > 0) {
            this.upsertDocData(arr);
        }
    }
    upsertDocData(arr) {
        console.log('arr ', arr);
        if (arr) {
            upsertSObjectRecord({ params: arr })
                .then((result) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'PDD/OTC/Wavier deviations Approved Successfully',
                            variant: 'success',
                            mode: 'sticky'
                        })
                    );
                    this.showSpinner = false;
                    //otc
                    this.showDocDetailotc = false;
                    refreshApex(this.wiredDataResultPddProp);
                    this.showPostDocDetailotc = false;
                    refreshApex(this.wiredDataResultPddSan);
                    this.showAddDocDetailotc = false;
                    refreshApex(this.wiredDataResultPddAdd);
                    this.showManualDocDetailotc = false;
                    refreshApex(this.wiredDataResultPddMan);
                    //pdd
                    this.showDocDetail = false;
                    refreshApex(this.wiredDataResult);
                    this.showPostDocDetail = false;
                    refreshApex(this.wiredDataResultOtcSan);
                    this.showAddDocDetail = false;
                    refreshApex(this.wiredDataResultOtcAdd);
                    this.showManualDocDetail = false;
                    refreshApex(this.wiredDataResultMandaOtcPost);
                    //wavier
                    this.showDocDetailWavier = false;
                    refreshApex(this.wiredDataResultWavSan);
                    this.showPostDocDetailWavier = false;
                    refreshApex(this.wiredDataResultWavAdd);
                    this.showAddDocDetailWavier = false;
                    refreshApex(this.wiredDataResultWavPost);
                    this.showManualDocDetailWavier = false;
                    refreshApex(this.wiredDataResultWavProp);
                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log('error in upserting Document ', JSON.stringify(error));

                });
        }
    }

}