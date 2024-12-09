import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';

import UserId from '@salesforce/user/Id';
import UserNameFIELD from '@salesforce/schema/User.Name';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, publish, MessageContext, unsubscribe, releaseMessageContext, createMessageContext } from 'lightning/messageService';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getSobjectDatawithRelatedRecords from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords";

import { getObjectInfo, getPicklistValues, getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import DEVIATION_OBJECT from '@salesforce/schema/Deviation__c';
import LOAN_APPLN_OBJECT from '@salesforce/schema/LoanAppl__c';

import APPROV_ACTION_FIELD from "@salesforce/schema/Deviation__c.Appr_Actn__c";
import TYPE_A_DEV_FIELD from "@salesforce/schema/LoanAppl__c.Is_there_TypeA_devia__c";
import TYPW_B_DEV_FIELD from "@salesforce/schema/LoanAppl__c.Is_there_TypeB_devia__c";

import Deviation_Del_SuccesMessage from '@salesforce/label/c.Deviation_Del_SuccesMessage';
import Deviation_Duplicate_Records from '@salesforce/label/c.Deviation_Duplicate_Records';


import { createRecord, updateRecord, deleteRecord } from "lightning/uiRecordApi";
import { getRecord } from "lightning/uiRecordApi";

import prodType from "@salesforce/schema/LoanAppl__c.Product__c";

const userId = UserId;
const npmProdField = prodType;
export default class DeviationDataTable extends LightningElement {
    customLabel = {
        Deviation_Del_SuccesMessage,
        Deviation_Duplicate_Records
    }
    @api hasEditAccess;

    @track _recordId;
    @api get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        this.setAttribute("recordId", value);
        this.handleRecordIdChange(value);
        this.handleRecordAppIdChange(value);
    }
    handleRecordAppIdChange(value) {
        let tempParams = this.loanAppParams;
        tempParams.queryCriteria = " where Id = '" + this._recordId + "'";
        this.loanAppParams = { ...tempParams };
    }
    handleRecordIdChange() {
        let tempParams = this.deviaParams;
        tempParams.queryCriteria = ' where LoanAppln__c = \'' + this._recordId + '\' AND (Dev_Type__c =\'Manual\' OR (Dev_Type__c =\'System\' AND Status__c=\'Active\' AND CallId__c = 4) ) ORDER BY Req_Apprv_Level__c desc' //LAK-8275
        this.deviaParams = { ...tempParams };
    }
    @track activeSection;

    subscription = null;
    context = createMessageContext();
    @track deviaWrapObj = {}

    @api DeviaType = "Underwriter";
    @track isLoading = false;
    @track records = [];
    @track EmpLevel;
    @track deviation;
    @track empNm;
    @track empId;
    @track obj = {
        Status__c: ""
    };

    wiredRecords;
    error;
    @track deleteDeviationIds = "";
    @track resfound = false;
    value = "inProgress";
    @track showfield = false;
    @track isAllDevAppr = false
    @track level;
    @track apprBy;
    @track role;
    @track mode = false;
    @track typeOptions = [];
    @track approvedby = true;
    @track selectedTypeValue;
    @api underwriterId;
    @api applicantId;
    @api LoanRdId;
    @track isModalOpen = false;
    @track delete = false;
    @track removeModalMessage = 'Do you want to delete?';
    @track spddUserId

    @track statusOptions = []
    @track TyADevOp = []
    @track TyBDevOp = []

    @track disableMode
    @wire(MessageContext)
    MessageContext;

    get disbaleMode() {
        if (this.hasEditAccess === true ) {
           // return false;
            //LAK-6471 Start
            if(this.loanApplStage && (this.loanApplStage == "DDE" || this.loanApplStage == "QDE" || (this.uwDecValue && this.uwDecValue == 'Forward for Review'))){
                this.disbApprCheckbox = true;
                return true;
            }else{
                //this.disbApprCheckbox =false; //LAK-8486
                //this.compareDevLevel();
                return false;
            }  
              //LAK-6471 Stop    
        } else {
            return true;
        }
    }

    @track
    deviaMasParam = {
        ParentObjectName: 'DeviaMstr__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'LWDD_Dev_DTL_Id__c', 'LWDD_LWD_DevId__c', 'LWDD_LRRM_RuleId__c', 'LWDD_Prio_N__c',
            'LWDD_LSR_RoleId__c', 'LWDD_Devi_Desc__c', 'LWDD_NPM_Prod__c', 'SchemeId__c', 'IsActive__c'],
        childObjFields: [],
        queryCriteria: ''
    }
    @track
    sPDDApprConfig = {
        ParentObjectName: 'SPDD_Approval_Config__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'Emp__c', 'Emp__r.Name', 'Product__c', 'Sanction_Amt__c', 'PD_Amt__c', 'Role__c', 'Designation__c', 'Dev_Level__c'],
        childObjFields: [],
        queryCriteria: ''
    }

    @track
    deviaParams = {
        ParentObjectName: 'Deviation__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name','DeviationCategory__c', 'LoanAppln__c', 'Applicant__c', 'BRE_Call_Iden__c', 'Dev_Type__c', 'Deviation__c', 'Apprv_By__c', 'Appr_Actn__c', 'Apprv_By__r.Name', 'Req_Apprv_Level__c', 'Devia_Desrp__c', 'Mitigation__c', 'Appr_Remarks__c', 'Dev_DescrId__c', 'Comments__c','Approved_Date__c', 'Format_App_Date__c', 'ApprSubStage__c', 'AppStage__c'],
        // parentObjFields: ['Id', 'Name', 'LoanAppln__c', 'Applicant__c', 'BRE_Call_Iden__c', 'Dev_Type__c', 'Deviation__c', 'Apprv_By__c', 'Appr_Actn__c', 'Apprv_By__r.Name', 'Req_Apprv_Level__c', 'Devia_Desrp__c', 'Mitigation__c', 'Appr_Remarks__c', 'Dev_DescrId__c', 'Comments__c','Approved_Date__c', 'Format_App_Date__c', 'ApprSubStage__c', 'AppStage__c'],
       
        childObjFields: [],
        queryCriteria: ''
    }

    @track
    loanAppParams = {
        ParentObjectName: "LoanAppl__c",
        ChildObjectRelName: "Deviations__r",
        parentObjFields: [
            "Id",
            "Name",
            "Product__c",
            "Stage__c",
            "SubStage__c",
            "ProductSubType__c",
            "Is_there_TypeA_devia__c",
            "Is_there_TypeB_devia__c",
            "Applicant__c",
              "Decision_Value__c"
        ],
        childObjFields: ['Id', 'Name', 'LoanAppln__c', 'Applicant__c', 'BRE_Call_Iden__c','DeviationCategory__c', 'Dev_Type__c', 'Deviation__c', 'Apprv_By__c', 'Appr_Actn__c', 'Apprv_By__r.Name', 'Req_Apprv_Level__c', 'Devia_Desrp__c', 'Mitigation__c', 'Appr_Remarks__c', 'Dev_DescrId__c', 'Comments__c','Approved_Date__c', 'Format_App_Date__c','AppStage__c','ApprSubStage__c'],
      //childObjFields: ['Id', 'Name', 'LoanAppln__c', 'Applicant__c', 'BRE_Call_Iden__c', 'Dev_Type__c', 'Deviation__c', 'Apprv_By__c', 'Appr_Actn__c', 'Apprv_By__r.Name', 'Req_Apprv_Level__c', 'Devia_Desrp__c', 'Mitigation__c', 'Appr_Remarks__c', 'Dev_DescrId__c', 'Comments__c','Approved_Date__c', 'Format_App_Date__c','AppStage__c','ApprSubStage__c'],
       
        queryCriteria: ""
    };

    @track loanApplStage
    @track loanAppSubStage
    @track uwDecValue;
    @track reqFromUW
    @track lookupRec;
    @track devDesrp;
    @track userLevel;
    @track deviaLevel;
    @track _spddConfigData
    @track prodTy
    @track npmIsActive = true
    get filCondnDevDesrp() {
        if (this.prodTy === "Home Loan") {
            return ("LWDD_NPM_Prod__c=" + "'" + this.prodTy + "'" + " AND IsActive__c=" + this.npmIsActive);
        } else if (this.prodTy === "Small Ticket LAP" || this.prodTy === "Loan Against Property"){
            return ("LWDD_NPM_Prod__c=" + "'" + this.prodTy + "'" + " AND IsActive__c=" + this.npmIsActive);
        }
    }

    @track _wiredLoanApplData

    generatePicklist(data) {
        return data.values.map((item) => ({
            label: item.label,
            value: item.value
        }));
    }

    @wire(getObjectInfo, { objectApiName: DEVIATION_OBJECT })
    objInfo;

    @wire(getPicklistValues, {
        recordTypeId: "$objInfo.data.defaultRecordTypeId",
        fieldApiName: APPROV_ACTION_FIELD
    })
    actionApprPicklistHandler({ data, error }) {
        if (data) {
            console.log('status data', data);

            this.statusOptions = [...this.generatePicklist(data)];
            console.log('status Options', this.statusOptions);
        }
        if (error) {
            console.log("error ", error);
        }
    }

    @wire(getObjectInfo, { objectApiName: LOAN_APPLN_OBJECT })
    objInfoTypeADev;

    @wire(getPicklistValues, {
        recordTypeId: "$objInfoTypeADev.data.defaultRecordTypeId",
        fieldApiName: TYPE_A_DEV_FIELD
    })
    typeADevIndentiPicklistHandler({ data, error }) {
        if (data) {
            this.TyADevOp = [...this.generatePicklist(data)];
        }
        if (error) {
            console.log("error ", error);
        }
    }

    @wire(getObjectInfo, { objectApiName: LOAN_APPLN_OBJECT })
    objInfoTypeBDev;

    @wire(getPicklistValues, {
        recordTypeId: "$objInfoTypeBDev.data.defaultRecordTypeId",
        fieldApiName: TYPW_B_DEV_FIELD
    })
    typeBDevPicklistHandler({ data, error }) {
        if (data) {
            this.TyBDevOp = [...this.generatePicklist(data)];
        }
        if (error) {
            console.log("error ", error);
        }
    }


    @wire(getSobjectDatawithRelatedRecords, { params: "$loanAppParams" })
    handleResponse(result) {
        const { data, error } = result;
        this._wiredLoanApplData = result;
        if (data) {
            if (data.parentRecord != undefined) {
                this.loanApplStage = data.parentRecord.Stage__c;
                this.loanAppSubStage = data.parentRecord.SubStage__c;
                this.uwDecValue = data.parentRecord.Decision_Value__c;
                if (this.loanApplStage !== "DDE" && this.loanApplStage !== "QDE") {
                    this.reqFromUW = true;
                }else{
                    this.reqFromUW = false
                }

                //LAK-6471
                if (this.loanApplStage && (this.loanApplStage == "DDE" || this.loanApplStage == "QDE" || (this.uwDecValue && this.uwDecValue == 'Forward for Review'))) {
                    this.disableMode = true;
                    this.disbApprCheckbox = true;
                }else{
                   // this.disbApprCheckbox =false; //LAK-8486
                    //this.compareDevLevel();
                }

                this.deviaWrapObj = { ...data.parentRecord };
                refreshApex(this._wiredDeviationData);
            }
        }
    }

    @wire(getSobjectData, { params: '$sPDDApprConfig' })
    sPDDApprConfigData(wiredSpddConfig) {
        const { data, error } = wiredSpddConfig;
        this._spddConfigData = wiredSpddConfig;

        if (data) {
            if (data.parentRecords) {
                this.userLevel = data.parentRecords[0].Dev_Level__c
                this.userName = data.parentRecords[0].Emp__r.Name
                console.log('user ::',this.userName)
                //add this to get SPDD user id for LAK-7491 (case approver is showing wrong in cam report)
                this.spddUserId=data.parentRecords[0].Emp__c
                
                if (this.userLevel !== undefined) {
                    this.levelCompareOfDev();
                }
            }

        } else if (error) {
            console.log('error ', error);
        }
    }

    @track isActive
    @wire(getRecord, { recordId: "$_recordId", fields: npmProdField })
    recordSchemesHandler({ data, error }) {
        if (data) {
            this.prodTy = data.fields.Product__c.value;
        }
    }

    @track foundelement;
    @track pickVal;
    @track finalRec = [];
    @track deviID;
    @track _wiredDeviationData = [];
    @track existRecords = [];

    @track oldrecords = []
    @track recordsOfOldDev = []
    @track myNewElement
    @track isLoading = false
    @track systDev = false
    @track manualDev = true
    @track updatedRecordsOfOldDev = []
    @track index
    @track commentTemp = false
    @track falseCommentTemp = false
    @track disbApprCheckbox = false
    @track disbComm = true
    @track deviationRec = [];
    @track devId = [];
    @track deviIdList = [];
    @track apprAllDevi = false
    @track numberOfRec = 0;
    @track deleteRecId;
    @track hasDupliDev = false
    @track deleteIndex


    @wire(getSobjectData, { params: '$deviaParams' })
    deviationData(wiredDeviData) {
        const { data, error } = wiredDeviData;
        this._wiredDeviationData = wiredDeviData;
        // this.records = [];

        if (data) {
            // this.apprAllDevi = false
            this.recordsOfOldDev = []
            this.existRecords = []
            if (data.parentRecords !== undefined) {
                this.oldrecords = [...this.records, ...data.parentRecords];
                this.existRecords = data.parentRecords;
                this.records = [];
                if (this.existRecords !== undefined) {
                    this.existRecords.forEach(dev => {
                        this.myNewElement = {
                            Id: dev.Id,
                            Deviation__c: dev.Deviation__c || '',
                            DeviationCategory__c: dev.DeviationCategory__c || '',
                            Dev_DescrId__c: dev.Dev_DescrId__c || '',
                            Req_Apprv_Level__c: dev.Req_Apprv_Level__c || '',
                            Devia_Desrp__c: dev.Devia_Desrp__c || '',
                            Apprv_By__r: dev.Apprv_By__r || {},
                            Appr_Actn__c: dev.Appr_Actn__c || '',
                            Mitigation__c: dev.Mitigation__c || '',
                            Appr_Remarks__c: dev.Appr_Remarks__c || '',
                            Dev_Type__c: dev.Dev_Type__c || '',
                            Comments__c: dev.Comments__c || '',
                            Approved_Date__c : dev.Approved_Date__c  || '',//LAK-8001
                            ApprStage__c : dev.ApprStage__c || '',
                            ApprSubStage__c : dev.ApprSubStage__c || '',
                            Format_App_Date__c : dev.Format_App_Date__c || '',
                            Apprv_By__c : dev.Apprv_By__c || '',//LAK-8275
                            approvedby: true,
                            systDev: false,
                            manualDev: true,
                            delete: false,
                            disbComm: true,
                            isReqComments: false
                        };
                        if (dev.Apprv_By__c) {
                            this.myNewElement.Apprv_By__r.Name = dev.Apprv_By__r.Name;
                            this.myNewElement.Apprv_By__c = dev.Apprv_By__c;//LAK-8275

                        }

                        this.recordsOfOldDev.push(this.myNewElement)

                    });

                }
            }
            let tempSpddParams = this.sPDDApprConfig;
            tempSpddParams.queryCriteria = ' where Emp__c = \'' + userId + '\''
            this.sPDDApprConfig = { ...tempSpddParams };
            this.levelCompareOfDev();
        } else if (error) {
            console.log('error ', error);
        }


    }

      levelCompareOfDev() {
        this.updatedRecordsOfOldDev = [];
        if (this.recordsOfOldDev) {
            for (let i = 0; i < this.recordsOfOldDev.length; i++) {
                if(!this.userLevel){
                    this.recordsOfOldDev[i].approvedby = true;
                    //LAK-7749 - Jayesh
                    this.disbApprCheckbox = true
                }else{
                if (this.recordsOfOldDev[i].Req_Apprv_Level__c !== undefined && this.userLevel !== undefined) {
                    if (this.recordsOfOldDev[i].Req_Apprv_Level__c == "1" && (this.userLevel == "1" || this.userLevel == "2" ||
                        this.userLevel == "3" || this.userLevel == "4" || this.userLevel == "5" || this.userLevel == "6" || this.userLevel == "7")
                    ) {
                        //LAK-8275
                        this.recordsOfOldDev[i].approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : false;
                        if (this.disbApprCheckbox == true) {
                            this.records.forEach(rec => {
                                rec.approvedby = this.hasEditAccess == false ? true : true;
                            });
                        }
                        
                    } else if (
                        this.recordsOfOldDev[i].Req_Apprv_Level__c == "2" &&
                        (this.userLevel == "2" ||
                            this.userLevel == "3" ||
                            this.userLevel == "4" ||
                            this.userLevel == "5" || this.userLevel == "6" || this.userLevel == "7")
                    ) {
                        //LAK-8275
                        this.recordsOfOldDev[i].approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : false;
                        if (this.disbApprCheckbox == true) {
                            this.records.forEach(rec => {
                                rec.approvedby = this.hasEditAccess == false ? true : true;
                            });
                        }
                    } else if (
                        this.recordsOfOldDev[i].Req_Apprv_Level__c == "3" &&
                        (this.userLevel == "3" ||
                            this.userLevel == "4" ||
                            this.userLevel == "5" || this.userLevel == "6" || this.userLevel == "7")
                    ) {
                        //LAK-8275
                        this.recordsOfOldDev[i].approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : false;
                        if (this.disbApprCheckbox == true) {
                            this.records.forEach(rec => {
                                rec.approvedby = this.hasEditAccess == false ? true : true;
                            });
                        }
                        //console.log('this.recordsOfOldDev[i].approvedby',i,this.recordsOfOldDev[i].approvedby);
                    } else if (this.recordsOfOldDev[i].Req_Apprv_Level__c == "4" && (this.userLevel == "4" ||
                        this.userLevel == "5" || this.userLevel == "6" || this.userLevel == "7")
                    ) {
                        //LAK-8275
                        this.recordsOfOldDev[i].approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : false;
                        if (this.disbApprCheckbox == true) {
                            this.records.forEach(rec => {
                                rec.approvedby = this.hasEditAccess == false ? true : true;
                            });
                        }
                    } else if (this.recordsOfOldDev[i].Req_Apprv_Level__c == "5" && (this.userLevel == "5" || this.userLevel == "6"
                        || this.userLevel == "7")
                    ) {
                        //LAK-8275
                        this.recordsOfOldDev[i].approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : false;
                        if (this.disbApprCheckbox == true) {
                            this.records.forEach(rec => {
                                rec.approvedby = this.hasEditAccess == false ? true : true;
                            }); 
                        }
                    } else if (this.recordsOfOldDev[i].Req_Apprv_Level__c == "6" && (this.userLevel == "6" || this.userLevel == "7")) {
                        //LAK-8275
                        this.recordsOfOldDev[i].approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : false;
                        if (this.disbApprCheckbox == true) {
                            this.records.forEach(rec => {
                                rec.approvedby = this.hasEditAccess == false ? true : true;
                            });
                        }

                    } else if (this.recordsOfOldDev[i].Req_Apprv_Level__c == "7" && (this.userLevel == "7")) {
                        //LAK-8275
                        this.recordsOfOldDev[i].approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : false;
                        if (this.disbApprCheckbox == true) {
                            this.records.forEach(rec => {
                                rec.approvedby = this.hasEditAccess == false ? true : true;
                            });
                        }
                    } else {
                        
                        this.recordsOfOldDev[i].approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : true
                        if (this.recordsOfOldDev[i].Req_Apprv_Level__c !== undefined) {
                            this.disbApprCheckbox = true
                            this.records.forEach(rec => {
                                rec.approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : true;
                            });
                        }
                    }
                }
            }

            if(this.recordsOfOldDev[i].DeviationCategory__c === 'Legal'){
                this.recordsOfOldDev[i].delete = true;
            }else{
                this.recordsOfOldDev[i].delete = this.uwDecValue && this.uwDecValue == 'Forward for Review' ? true : false;
            }
            
            // this.recordsOfOldDev[i].delete = this.uwDecValue && this.uwDecValue == 'Forward for Review' ? true : false;
            
                if (this.recordsOfOldDev[i].Dev_Type__c === "System") {

                    if(this.recordsOfOldDev[i].DeviationCategory__c === 'Legal'){
                        this.recordsOfOldDev[i].delete = true;
                    }else{
                        this.recordsOfOldDev[i].delete = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : true;
                    }    
                    //  this.recordsOfOldDev[i].delete = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : true;
                 
                    this.recordsOfOldDev[i].systDev = true;
                    this.recordsOfOldDev[i].manualDev = false

                }
                

                if (this.recordsOfOldDev[i].Devia_Desrp__c === "OTHER DEVIATIONS") {
                    this.commentTemp = true
                    this.recordsOfOldDev[i].disbComm = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : false;
                    this.recordsOfOldDev[i].isReqComments = true
                }
                this.updatedRecordsOfOldDev.push(this.recordsOfOldDev[i]);
            }
        }
        this.records = [...this.updatedRecordsOfOldDev];
        const allRecordsApproved = this.existRecords.every(record => record.Appr_Actn__c === 'Approved');
        if (allRecordsApproved === true) {
            this.apprAll = true
        } else {
            this.apprAll = false
        }
        if (this.recordsOfOldDev.length === 0) {
            this.isAllDevAppr = false
        } else {
            this.isAllDevAppr = true
        }
    }
    @track deleteButton = true;
    connectedCallback() {

        if (this.hasEditAccess === false) {
            this.Apprv_By__c = true;
            this.disableMode = true;
            this.disbApprCheckbox = true;
            this.deleteButton = false;
           

        }
        else {
            this.Apprv_By__c = false;
            this.disableMode = false;
            
        }
        let tempSpddParams = this.sPDDApprConfig;
        tempSpddParams.queryCriteria = ' where Emp__c = \'' + userId + '\''
        this.sPDDApprConfig = { ...tempSpddParams };

        this.scribeToMessageChannel();
    }


    renderedCallback() {
        refreshApex(this._wiredDeviationData);
        // refreshApex(this._spddConfigData);
        refreshApex(this._wiredLoanApplData);
    }

    @api validateForm() {
        let isValid = true
        this.template.querySelectorAll("lightning-combobox").forEach((element) => {
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
        this.template.querySelectorAll('lightning-textarea').forEach(element => {
            if (element.reportValidity()) {
            } else {
                isValid = false;
            }
        });

        const deviationSet = []
        this.hasDupliDev = false
        for (let i = 0; i < this.records.length; i++) {

            var commeField = this.records[i];
            const deviationValue = commeField.Deviation__c;

            if (deviationSet.includes(deviationValue)) {
                this.hasDupliDev = true
            }
            deviationSet.push(deviationValue);
        }

        if (this.hasDupliDev == true) {
            isValid = false;
            this.showToastMessage('Error', this.customLabel.Deviation_Duplicate_Records, 'error', 'sticky')
        }
        return isValid;

    }

    handleValueSelect(event) {
        this.lookupRec = event.detail;
        if (event.target.fieldName === 'Devia_Desrp__c') {
            this.hasDupliDev = false
            this.index = event.target.index
            this.records[this.index].Devia_Desrp__c = this.lookupRec.mainField;
            this.records[this.index].Dev_DescrId__c = this.lookupRec.id;
            this.devDesrp = this.lookupRec.mainField;
            const updatedRecords = [...this.records];
            if (this.devDesrp === null) {
                //LAK-7749 - Jayesh
                this.records[this.index].approvedby = true
                this.records[this.index].Deviation__c = ''
                this.records[this.index].Req_Apprv_Level__c = ''
                this.records[this.index].Appr_Actn__c = ''
                this.records[this.index].Apprv_By__r = {}
                this.records[this.index].Approved_Date__c = ''//LAK-8001
                this.records[this.index].AppStage__c = ''
                this.records[this.index].ApprSubStage__c = ''
            }
            //LAK-8486
            else{
                this.records[this.index].approvedby = false;
            }
            if (this.lookupRec.mainField === 'OTHER DEVIATIONS') {
                this.commentTemp = true
            }
            if (this.lookupRec.mainField !== 'OTHER DEVIATIONS') {
                this.commentTemp = false
            }

            for (let i = 0; i < this.records.length; i++) {
                var commeField = this.records[i];
                if (commeField.Devia_Desrp__c === 'OTHER DEVIATIONS') {
                    this.commentTemp = true
                    this.records[i].disbComm = false
                    commeField.isReqComments = true
                } else {
                    this.records[i].disbComm = true
                    commeField.isReqComments = false
                }
            }


            let productType = 'Home Loan'
            this.deviaMasParam.queryCriteria = ' where LWDD_Devi_Desc__c = \'' + this.devDesrp + '\''
            getSobjectData({ params: this.deviaMasParam }).then((result) => {
                if (result) {
                    if (result.parentRecords) {
                        let DevData = result.parentRecords;
                        this.deviaLevel = DevData[0].LWDD_Prio_N__c;
                        this.records[this.index].Req_Apprv_Level__c = DevData[0].LWDD_Prio_N__c;
                        this.records[this.index].Deviation__c = DevData[0].LWDD_Dev_DTL_Id__c;
                        this.checkDuplicateDeviation();
                        this.compareDevLevel();
                    }
                } else if (error) {
                    console.error('Error', error)
                }
            });

        }
    }

    checkDuplicateDeviation() {
        const deviationSet = []
        for (let i = 0; i < this.records.length; i++) {
            var commeField = this.records[i];
            const deviationValue = commeField.Deviation__c;

            if (deviationSet.includes(deviationValue)) {
                this.hasDupliDev = true
            }
            deviationSet.push(deviationValue);
        }


        if (this.hasDupliDev == true) {
            this.showToastMessage('Error', this.customLabel.Deviation_Duplicate_Records, 'error', 'sticky')
        }
    }

    compareDevLevel() {
        if (this.deviaLevel !== undefined && this.userLevel !== undefined) {
            if (this.deviaLevel == "1" && (this.userLevel == "1" || this.userLevel == "2" || this.userLevel == "3" ||
                this.userLevel == "4" || this.userLevel == "5" || this.userLevel == "6" || this.userLevel == "7")) {
                //LAK-8275
                this.records[this.index].approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : false;
                    if (this.disbApprCheckbox == true) {
                    this.records.forEach(rec => {
                        console.log('this.hasEditAccess1',this.hasEditAccess);
                        rec.approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : true;
                    });
                }
                
            } else if (this.deviaLevel == "2" && (this.userLevel == "2" || this.userLevel == "3" ||
                this.userLevel == "4" || this.userLevel == "5" || this.userLevel == "6" || this.userLevel == "7")) {
                    this.records[this.index].approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : false;
                    if (this.disbApprCheckbox == true) {
                        this.records.forEach(rec => {
                            console.log('this.hasEditAccess2',this.hasEditAccess);
                            rec.approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : true;
                        });
                    }
            } else if (this.deviaLevel == "3" && (this.userLevel == "3" ||
                this.userLevel == "4" || this.userLevel == "5" || this.userLevel == "6" || this.userLevel == "7")) {
                    //LAK-8275
                    this.records[this.index].approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : false;
                    if (this.disbApprCheckbox == true) {
                        this.records.forEach(rec => {
                            console.log('this.hasEditAccess3',this.hasEditAccess);
                            rec.approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : true;
                        });
                    }
            } else if (this.deviaLevel == "4" && (this.userLevel == "4" || this.userLevel == "5" || this.userLevel == "6"
                || this.userLevel == "7")) {
                    this.records[this.index].approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : false;
                    if (this.disbApprCheckbox == true) {
                        this.records.forEach(rec => {
                            console.log('this.hasEditAccess4',this.hasEditAccess);
                            rec.approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : true;
                        });
                    }
            } else if (this.deviaLevel == "5" && (this.userLevel == "5" || this.userLevel == "6" || this.userLevel == "7")) {
                //LAK-8275
                this.records[this.index].approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : false;
                if (this.disbApprCheckbox == true) {
                    this.records.forEach(rec => {
                        console.log('this.hasEditAccess5',this.hasEditAccess);
                        rec.approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : true;
                    });
                }
            } else if (this.deviaLevel == "6" && (this.userLevel == "6" || this.userLevel == "7")) {
                //LAK-8275
                this.records[this.index].approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : false;
                if (this.disbApprCheckbox == true) {
                    this.records.forEach(rec => {
                        console.log('this.hasEditAccess6',this.hasEditAccess);
                        rec.approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : true;
                    });
                }
            } else if (this.deviaLevel == "7" && this.userLevel == "7") {
                //LAK-8275
                this.records[this.index].approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : false;
                if (this.disbApprCheckbox == true) {
                    this.records.forEach(rec => {
                        console.log('this.hasEditAccess7',this.hasEditAccess);
                        rec.approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : true;
                    });
                }
            } else {
                //LAK-8275
                this.records[this.index].approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : true
                
                this.disbApprCheckbox = true
                this.records.forEach(rec => {
                    rec.approvedby = (this.hasEditAccess == false || (this.uwDecValue && this.uwDecValue == 'Forward for Review')) ? true : true;
                    if(!rec.Approved_Date__c){
                        rec.Appr_Actn__c = '';
                        rec.Apprv_By__c = '';
                        rec.AppStage__c = '';
                        rec.ApprSubStage__c = '';
                    }
                });
            }
        }
        
    }

    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }


    handleSaveThroughLms(values) {
        // this.handleSave(values.validateBeforeSave);
    }

    @track _getCurrentDateTime;

    handleStatusChange(event) {
        const index = event.target.dataset.index;
        const fieldName = event.target.dataset.name;
        const value = event.target.value;

        if (fieldName === 'Appr_Actn__c') {
            this.records[index].Appr_Actn__c = value;

            //LAK-8001
            if(value === 'Approved' && this.records[index].Approved_Date__c === ''){
                this._getCurrentDateTime =  new Date().toISOString();
                try{
                this.records[index].Apprv_By__c = this.spddUserId;//LAK-8275
                this.records[index].Apprv_By__r.Name = this.userName;
                //this.records[index].Approved_Date__c = this._getCurrentDateTime;
                this.records[index].AppStage__c = this.loanApplStage;
                this.records[index].ApprSubStage__c = this.loanAppSubStage;
                //console.log('Date of approval', this.records[index].Approved_Date__c);
                }catch(e){
                    console.log(e);
                }
            }
            else if(value=='Rejected'){
                this.records[index].Apprv_By__r =  {};
                this.records[index].Apprv_By__c =  '';//LAK-8275
                this.records[index].Apprv_By__r.Name = '';
                this.records[index].Approved_Date__c = '';
                this.records[index].AppStage__c = '';
                this.records[index].ApprSubStage__c = '';
            }

        } else if (fieldName === 'Mitigation__c') {
            let strVal = value;
            this.records[index].Mitigation__c = strVal.toUpperCase();
        } else if (fieldName === 'Appr_Remarks__c') {
            let strVal = value;
            this.records[index].Appr_Remarks__c = strVal.toUpperCase();
        } else if (fieldName === 'Comments__c') {
            let strVal = value;
            this.records[index].Comments__c = strVal.toUpperCase();
        }

    }

    handleDeleteRecId(delRecId) {
        deleteRecord(delRecId).then((result) => {
            this.showToastMessage('Success', this.customLabel.Deviation_Del_SuccesMessage, 'success', 'sticky')
            this.disbApprCheckbox = false
            refreshApex(this._wiredDeviationData);
            refreshApex(this._spddConfigData);
            refreshApex(this._wiredLoanApplData);

            this.isModalOpen = false;
        }).catch((error) => {
            this.isModalOpen = false;
            console.log('Errror !! ' + JSON.stringify(error));
            this.showToastMessage("Error deleting record",error.body.message,"error","sticky")

        });
    }

    @api handleSave(validate) {

        let returnVariable;
        if (validate) {
            returnVariable = this.handleUpsert();
        }
        else {
            returnVariable = this.handleUpsert();
        }
        return returnVariable;

    }

    @api handleUpsert() {
        var saveStatus = true;

        if (this.isLoading == false) {
            this.isLoading = true;

            this.deviationRec = [];
            for (var i = 0; i < this.records.length; i++) {
                let parentRecord = {};
                var oldDev = this.records[i];

                if (oldDev.Devia_Desrp__c !== undefined && oldDev.Devia_Desrp__c !== "") {

                    parentRecord.Name = oldDev.Name;
                    parentRecord.LoanAppln__c = this._recordId;
                    parentRecord.Deviation__c = oldDev.Deviation__c;
                    parentRecord.Devia_Desrp__c = oldDev.Devia_Desrp__c;
                    parentRecord.Dev_DescrId__c = oldDev.Dev_DescrId__c
                    parentRecord.Req_Apprv_Level__c = oldDev.Req_Apprv_Level__c;
                    parentRecord.Mitigation__c = oldDev.Mitigation__c;
                    parentRecord.Comments__c = oldDev.Comments__c;
                    parentRecord.Approved_Date__c = oldDev.Approved_Date__c;//LAK-8001
                    parentRecord.AppStage__c = oldDev.AppStage__c;
                    parentRecord.ApprSubStage__c = oldDev.ApprSubStage__c;
                    console.log('check approve action', oldDev.Appr_Actn__c );
                    if (oldDev.Appr_Actn__c) {
                         //add this to get SPDD user id for LAK-7491 (case approver is showing wrong in cam report)
                         console.log('oldDev.Apprv_By__c',oldDev.Apprv_By__c);
                         //LAK-8275
                         if(this.spddUserId && oldDev.Apprv_By__c !== null){
                            parentRecord.Apprv_By__c = oldDev.Apprv_By__c;
                            // parentRecord.Apprv_By__r.Name = oldDev.Apprv_By__r.Name;
                         }
                         else if(this.spddUserId && oldDev.Apprv_By__r.Name === null){
                            parentRecord.Apprv_By__c = this.spddUserId;
                        }
                      //  parentRecord.Apprv_By__c = UserId;
                    }
                    if (oldDev.Appr_Actn__c === '' && oldDev.Apprv_By__c === '') {
                        parentRecord.Apprv_By__c = '';
                    }

                    if (oldDev.Dev_Type__c) {
                        parentRecord.Dev_Type__c = oldDev.Dev_Type__c
                    } else {
                        parentRecord.Dev_Type__c = 'System';
                    }
                    parentRecord.Appr_Actn__c = oldDev.Appr_Actn__c;

                    if ((!oldDev.Appr_Actn__c || oldDev.Appr_Actn__c === "Rejected") && (this.apprAllDevi === true)) {

                        parentRecord.Appr_Actn__c = "Approved"
                         //add this to get SPDD user id for LAK-7491 (case approver is showing wrong in cam report)
                         //LAK-8304 and LAK-
                         if(this.spddUserId && oldDev.Apprv_By__r.Name !== null){
                            parentRecord.Apprv_By__c = oldDev.Apprv_By__c;
                            // parentRecord.Apprv_By__r.Name = oldDev.Apprv_By__r.Name;
                         }
                         else if(this.spddUserId && oldDev.Apprv_By__r.Name === null){
                            parentRecord.Apprv_By__c = this.spddUserId;
                        }
                     //   parentRecord.Apprv_By__c = UserId;
                    }
                    // if(this.apprAllDevi === false){
                    //     parentRecord.Appr_Actn__c = "Approved"
                    //     parentRecord.Apprv_By__c = UserId;
                    // }
                    parentRecord.Appr_Remarks__c = oldDev.Appr_Remarks__c;
                    parentRecord.sobjectType = 'Deviation__c';

                    if (oldDev.Id) {
                        parentRecord.Id = oldDev.Id;
                    }

                    this.deviationRec.push(parentRecord);
                }
            }

            let arrayOfSelectedValues = [];
            let alloptOfOwner = [];
            arrayOfSelectedValues = this.deviIdList;
            alloptOfOwner = this.existRecords;
            let resultOfCompareArrays = alloptOfOwner.filter(o => arrayOfSelectedValues.find(x => x.Id === o.Id)).map(o => o.Id);

            /*this.deviaWrapObj.sobjectType = "LoanAppl__c";
            this.deviaWrapObj.Id = this._recordId;
            this.deviaWrapObj.Applicant__c = this.applicantId;*/
            let loanAppObj = {};
            loanAppObj.sobjectType = "LoanAppl__c";
            loanAppObj.Id = this._recordId;

            //LAK--7755 - Jayesh
            loanAppObj.Is_there_TypeB_devia__c = this.deviaWrapObj.Is_there_TypeB_devia__c;
            loanAppObj.Is_there_TypeA_devia__c = this.deviaWrapObj.Is_there_TypeA_devia__c;


            /*let upsertData = {
                parentRecord: this.deviaWrapObj,
                ChildRecords: this.deviationRec,
                ParentFieldNameToUpdate: "LoanAppln__c"
            };*/
            let upsertData = {
                parentRecord: loanAppObj,
                ChildRecords: this.deviationRec,
                ParentFieldNameToUpdate: "LoanAppln__c"
            };
            console.log('upsert data', upsertData);
            upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
                .then(result => {
                    this.recordsOfOldDev = []
                    this.existRecords = []
                    this.isAllDevAppr = false
                    this.apprAllDevi = false
                    if (result.ChildReords.length > 0) {
                        this.isAllDevAppr = true
                    }
                    refreshApex(this._wiredDeviationData);
                    refreshApex(this._spddConfigData);
                    refreshApex(this._wiredLoanApplData);
                    this.isLoading = false;
                })
                .catch(error => {
                    saveStatus = false;
                    this.isLoading = false;
                    console.log('error print deviation', error);
                });

        }

        return saveStatus;
    }
    @track _apprAllDevi

    get _apprAllDevi() {
        if (this.apprAllDevi == false) {
            return false;
        } else {
            return true;
        }
    }

    validateLevel(){
        let isValid = true;
        this.records.forEach(rec => {
            if(!rec.Devia_Desrp__c){
                isValid = false;
            }
        });
        return isValid;
    }

    handleApprvChange(event) {
        if(this.validateLevel()){

       
        this.apprAllDevi = event.detail.checked
        
        if (this.apprAllDevi === true ) {
           
            this.records = this.records.map(record =>  {
                //LAK-8001
                // Check if the Approved_date field of the current record is already populated
                if (!record.Approved_Date__c) {
                    // If not populated, update the current record
                    this._getCurrentDateTime = new Date().toISOString();
                    if(!record.AppStage__c && !record.ApprSubStage__c){
                        return {
                            ...record,
                            Appr_Actn__c: 'Approved',
                            Approved_Date__c: this._getCurrentDateTime,
                            AppStage__c: this.loanApplStage,
                            ApprSubStage__c: this.loanAppSubStage,
                            Apprv_By__c: this.spddUserId
                        };
                    }  
                    else{
                        return {
                            ...record,
                            Appr_Actn__c: 'Approved',
                            Approved_Date__c: this._getCurrentDateTime,
                            Apprv_By__c: this.spddUserId
                        }
                    }
                    
                } else {
                    // If already populated, return the current record without modifying it
                    if(!record.AppStage__c && !record.ApprSubStage__c){
                        return {
                            ...record,
                            Appr_Actn__c: 'Approved',
                            AppStage__c: this.loanApplStage,
                            ApprSubStage__c: this.loanAppSubStage,
                            Apprv_By__c: this.spddUserId            
                        };
                    }
                    else{
                        return {
                            ...record,
                            Appr_Actn__c: 'Approved',
                            Apprv_By__c: this.spddUserId 
                        };
                    }
                }
            });
        } else {
            this.records = this.records.map(record => ({
                ...record,
                Appr_Actn__c: '',
                Apprv_By__c: '',
                Approved_Date__c: '',
                'Apprv_By__r': { 'Name': '' },
                AppStage__c: '',
                ApprSubStage__c: ''  
            }));
        }
        }
        else{
            event.target.checked = false;
            event.preventDefault();
            this.showToastMessage('Error', 'Please select deviation', 'error', 'sticky')
        }
    }


    handleInputChange(event) {
        this.deviaWrapObj[event.target.dataset.name] = event.target.value;

        console.log(event.target.dataset.name + " " + event.target.value);
        
    }

    addRow() {

        this.numberOfRec = this.records.length + 1;
        let myNewElement = {
            Deviation__c: "",
            Devia_Desrp__c: "",
            Req_Apprv_Level__c: "",
            Apprv_By__r: "",
            Apprv_By__c: "",//LAK-8275
            Appr_Actn__c: "",
            Mitigation__c: "",
            Appr_Remarks__c: "",
            LoanAppln__c: this._recordId,
            Dev_Type__c: "Manual",
            approvedby: true,
            systDev: false,
            manualDev: true,
            delete: false,
            isReqComments: false,
            Approved_Date__c: "",//LAK-8001
            AppStage__c: "",
            ApprSubStage__c:""
        };
        let deviaDa = [...this.records, myNewElement];
        this.records = deviaDa;
        this.isAllDevAppr = true
        this.apprAll = false
    }

    handleIsLoading(isLoading) {
        this.isLoading = isLoading;
    }

    handleDeleteAction(event) {
        this.isModalOpen = true;
        this.deleteRecId = event.target.dataset.id;
        this.deleteIndex = event.target.dataset.index
    }

    handleRemoveRecord(event) {
        if (this.deleteRecId) {
            if (this.deleteRecId.length == 18) {
                this.handleDeleteRecId(this.deleteRecId);
            }
        } else {
            this.records.splice(this.deleteIndex, 1);
            this.isModalOpen = false;
            refreshApex(this._wiredDeviationData);
            refreshApex(this._spddConfigData);
            refreshApex(this._wiredLoanApplData);
        }
    }
    closeModal(event) {
        this.isModalOpen = false;
    }

    showToastMessage(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

}