import { LightningElement, api, track, wire } from 'lwc';

//Apex Methods
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import retrieveNdcData from '@salesforce/apex/NdcController.retrieveNdcData';
import deleteDocRecord from '@salesforce/apex/DocumentDetailController.deleteDocDetWithCdlToNdc';
import ndcDocumentCheck from '@salesforce/apex/DocumentCheckController.ndcDocumentCheck';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
// import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import saveNdcData from '@salesforce/apex/NdcController.saveNdcData';
import deleteDocDispatchRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import formFactorPropertyName from "@salesforce/client/formFactor";

import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, MessageContext } from 'lightning/messageService';
import { NavigationMixin } from "lightning/navigation";
import { RefreshEvent } from 'lightning/refresh';
// Custom labels
import NdcDetails_scheduledDate_ErrorMessage from '@salesforce/label/c.NdcDetails_scheduledDate_ErrorMessage';
import NdcDetails_Save_SuccesMessage from '@salesforce/label/c.NdcDetails_Save_SuccesMessage';
import NdcDetails_DocUpload_SuccesMessage from '@salesforce/label/c.NdcDetails_DocUpload_SuccesMessage';
import NdcDetails_DocDelete_SuccesMessage from '@salesforce/label/c.NdcDetails_DocDelete_SuccesMessage';
import Id from "@salesforce/user/Id";
export default class CaptureNdcDetails extends NavigationMixin(LightningElement) {
    @track userId = Id;
    label = {
        NdcDetails_scheduledDate_ErrorMessage,
        NdcDetails_Save_SuccesMessage,
        NdcDetails_DocUpload_SuccesMessage,
        NdcDetails_DocDelete_SuccesMessage

    }
    @api loanAppId = 'a08C4000007WjlxIAC';
    @api hasEditAccess = false;
    @api layoutSize = {
        "large": "4",
        "medium": "6",
        "small": "12"
    }

    @track primaryAppId;
    //LAK-2368
    @track removeModalMessage = "Do you really want to delete this file";
    @track removeModalMessageDoc = "Do you really want to delete this file";
    @track removeModalMessageDocDis = "Do you really want to delete this POD Details";
    @track removeModalMessageAllDocs = "Do you really want to check?";
    //LAK-2368
    @track formFactor = formFactorPropertyName;
    @track desktopBoolean = false;
    @track phoneBolean = false;
    @track isReadOnly = false;
    @track mandatoryUw = true;
    //@track maxFileSize = 5242880; // 5mb 25 * 1024 * 1024;
    @track maxFileSize = 25 * 1024 * 1024;
    @track fileSizeMsz = "Maximum File Size should be 25Mb. Allowed File Types are  .jpg, .jpeg, .pdf ";
    // @track disableDisbType = false;
    @track disTypeOptions = [];
    @track typeOptions = [];
    @track courierNameOptions = [];
    @track phyFileRecOptions = [];
    enableInfiniteScrolling = true;
    enableBatchLoading = true;
    @track documentDispatchRecords = [];
    @track disObj = {};
    @track disObjDet = [];
    @track showSpinner = false;
    @track showdDocDispatch = false;
    @track ndcSectionData = [];
    @track activeSections = [];
    @track isModalOpen = false;
    @track showButton = false;
    @track disableDocumentDispatch = false;
    @track showTables = false;
    @track ndcAprv;
    @track loanStage;
    @track loanSubstage;
    @track product;
    @track finnoneSubmitDate;
    // @track disableReceiptdate = false;
    // @track disableDispatchInputs = false;
    @track ndcDisType = '';
    @wire(getObjectInfo, { objectApiName: 'DocDispatch__c' })
    objectInfo;

    @wire(getPicklistValuesByRecordType, {
        objectApiName: 'DocDispatch__c',
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    })
    paymentPicklistHandler({ data, error }) {
        if (data) {
            console.log('data in paymentPicklistHandler', JSON.stringify(data));
            this.disTypeOptions = [...this.generatePicklist(data.picklistFieldValues.DisType__c)];
            this.typeOptions = [...this.generatePicklist(data.picklistFieldValues.Type__c)];
            this.courierNameOptions = [...this.generatePicklist(data.picklistFieldValues.CourierComName__c)];
            this.phyFileRecOptions = [...this.generatePicklist(data.picklistFieldValues.PhyFileRec__c)];
        }
        if (error) {
            console.error('error im getting picklist values are', error)
        }
    }
    generatePicklist(data) {
        if (data.values) {
            return data.values.map(item => ({ label: item.label, value: item.value }))
        }
        return null;
    }

    connectedCallback() {
        this.scribeToMessageChannel();
        console.log('formFactor is ', this.formFactor);
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

        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }
        // this.isReadOnly = false;

        this.getApplicantDetails();
        this.getSalesHierMetadat();
        // this.getDocDtls();
        this.getLoanTatData(); //LAK-8619
    }
    //LAK-8619
    @track queryEnable = false;
    getLoanTatData(){
        //this.showSpinner  = true;
            let params = {
                ParentObjectName: 'LoanTAT__c',
                parentObjFields: ['Id', 'Stage__c','Sub_Stage__c'],
                queryCriteria: ' where LoanApplication__c = \'' + this.loanAppId + '\''
            }
            getSobjectData({ params: params })
                .then((result) => {
                    // this.showSpinner = true;
                    console.log('Loan TAT Data is ', JSON.stringify(result));
                    let isOpsThere = false;
                    if (result.parentRecords) {
                        result.parentRecords.forEach(item => {
                            if (item.Stage__c && item.Stage__c === 'Post Sanction' && item.Sub_Stage__c && item.Sub_Stage__c === 'Ops Query') {
                                isOpsThere = true;
                            }
                        })
                    }
                    if (isOpsThere) {
                        // if (this.col.type === "Query") {
                            // if (this.ndcId && this.loanStage === 'Post Sanction' && this.loanSubstage === 'Ops Query') {
                                this.queryEnable = true;
                    } 
                })
                .catch((error) => {
                   // this.showSpinner = false;
                    console.log('Error In getting Loan TAT Data is ', error);
                    //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
                });
        
    }
    @track creditHierNewArr = [];
    @track opsHierNewArr = [];
    getSalesHierMetadat() {
        this.showSpinner = true;
        let develoeprNames = ['Credit', 'Ops'];
        let paramsLoanApp = {
            ParentObjectName: 'SharingHierarchy__mdt',
            parentObjFields: ['Id', 'BrchRoleSharing__c', 'SupervisoreRoleSharing__c', 'DeveloperName'],
            queryCriteria: ' where DeveloperName  IN (\'' + develoeprNames.join('\', \'') + '\')'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('credit and ops hierarchy metadata is', JSON.stringify(result));
                if (result.parentRecords) {
                    let credArr = result.parentRecords.find(item => item.DeveloperName === 'Credit');
                    let opsArr = result.parentRecords.find(item => item.DeveloperName === 'Ops');
                    if (credArr) {
                        let arrayFromString = credArr.BrchRoleSharing__c.split(',');
                        let arrayFromStringNew = [];
                        if (credArr.SupervisoreRoleSharing__c) {
                            arrayFromStringNew = credArr.SupervisoreRoleSharing__c.split(',');
                        }
                        let setFromArray = new Set([...arrayFromString, ...arrayFromStringNew]);
                        this.creditHierNewArr = Array.from(setFromArray);
                        console.log('this.creditHierNewArr', this.creditHierNewArr);
                    }
                    if (opsArr) {
                        let arrayFromStringOps = opsArr.BrchRoleSharing__c.split(',');
                        // let arrayFromStringNew = opsArr.SupervisoreRoleSharing__c.split(',');
                        let arrayFromStringNewOps = [];
                        if (opsArr.SupervisoreRoleSharing__c) {
                            arrayFromStringNewOps = opsArr.SupervisoreRoleSharing__c.split(',');
                        }
                        let setFromArrayOps = new Set([...arrayFromStringOps, ...arrayFromStringNewOps]);
                        this.opsHierNewArr = Array.from(setFromArrayOps);
                        console.log('this.opsHierNewArr', this.opsHierNewArr);
                    }
                    this.getTeamHierarchyData();
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting sales hierarchy details ', error);
            });
    }



    @track empRole;
    @track isOpsUser = false;
    @track isCpaUser = false;
    getTeamHierarchyData() {
        //Added AND EmpRole__c != null for LAK-8022
        let paramsLoanApp = {
            ParentObjectName: 'TeamHierarchy__c',
            parentObjFields: ['Id', 'Employee__c', 'EmpRole__c'],
            queryCriteria: ' where Employee__c = \'' + this.userId + '\' AND EmpRole__c != null ORDER BY LastModifiedDate DESC'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('team hierarchy data is', JSON.stringify(result.parentRecords));
                // if (result.parentRecord) {
                //     this.empRole = result.parentRecord.EmpRole__c;
                // }
                if (result.parentRecords) {
                    this.empRole = result.parentRecords[0].EmpRole__c;
                    console.log('empRole', this.empRole);
                }
                if (this.empRole) {
                    if (this.opsHierNewArr.includes(this.empRole)) {
                        this.isOpsUser = true;
                    } else if (this.creditHierNewArr.includes(this.empRole)) {
                        this.isCpaUser = true;
                    }
                }
                console.log('this.isOpsUser', this.isOpsUser);
                console.log('this.isCpaUser', this.isCpaUser);
                this.getDocumentDispatchDet();
                // this.getDocDtls();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting team hierarchy details ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }


    // @track docDetails = [];
    // @track disableAllDocsCheck = true;
    // getDocDtls() {
    //     let params = {
    //         ParentObjectName: 'DocDtl__c',
    //         parentObjFields: ['Id', 'PhyFileRec__c', 'DocCatgry__c', 'IsLatest__c', 'Case__r.CaseType__c', 'Case__c', 'ApplAsset__c', 'Case__r.ApplAssetId__c'],
    //         queryCriteria: ' where LAN__c = \'' + this.loanAppId + '\' AND DocCatgry__c  IN (\'' + docCat.join('\', \'') + '\')'
    //     }
    //     getSobjectData({ params: params })
    //         .then((result) => {
    //             console.log('Document Details Recordds Data is ', JSON.stringify(result));
    //             if (result.parentRecords) {
    //                 this.docDetails = result.parentRecords;
    //                 let count = 0;
    //                 result.parentRecords.forEach(ite => {
    //                     if ((ite.DocCatgry__c === 'PAN Documents' || ite.DocCatgry__c === 'KYC Documents') && (ite.PhyFileRec__c === 'Query' || ite.PhyFileRec__c == '')) {
    //                         count++;
    //                     } else if (ite.DocCatgry__c === 'Case Documents' && (ite.PhyFileRec__c === 'Query' || ite.PhyFileRec__c == '') && ite.Case__c && (ite.Case__r.CaseType__c === 'Technical' || ite.Case__r.CaseType__c === 'Vetting' || ite.Case__r.CaseType__c === 'Legal' || ite.Case__r.CaseType__c === 'TSR')) {
    //                         count++;
    //                     } else if ((ite.DocCatgry__c === 'Sanction Letter' || ite.DocCatgry__c === 'CAM Report' || ite.DocCatgry__c === 'Application Form') && (ite.PhyFileRec__c === 'Query' || ite.PhyFileRec__c == '') && ite.IsLatest__c) {
    //                         count++;
    //                     } else if (ite.DocCatgry__c === 'Property Documents' && (ite.PhyFileRec__c === 'Query' || ite.PhyFileRec__c == '') && ite.ApplAsset__c) {
    //                         count++;
    //                     } else if ((ite.DocCatgry__c === 'Mandatory Post Sanction Documents' || ite.DocCatgry__c === 'Sanction Condition Documents' || ite.DocCatgry__c === 'Additional Post Sanction Documents') && (ite.PhyFileRec__c === 'Query' || ite.PhyFileRec__c == '')) {
    //                         count++;
    //                     }
    //                 });
    //                 if (count > 0 || this.isReadOnly || !this.isOpsUser) {
    //                     this.disableAllDocsCheck = true;
    //                 } else {
    //                     this.disableAllDocsCheck = false;
    //                 }
    //             }
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getting Document Details records Data is ', error);
    //         });
    // }

    handleSelectAll(event) {
        let sectionName = event.target.dataset.section;
        let appAssetId = event.target.dataset.asset;
        let fieldName = event.target.dataset.name;

        let allRecords = [];
        let obj = this.ndcSectionData.find(item => item.ndcSection === sectionName);
        if (obj) {
            if (appAssetId) {
                let arr = obj.tablConfig;
                let ndcRecordObj = arr.find(item => item.applicantAssetId === appAssetId);
                allRecords = ndcRecordObj.ndcRecords;
            } else {
                allRecords = obj.tablConfig[0].ndcRecords;
            }
        }
        if (allRecords.length) {
            const isChecked = event.target.checked;
            console.log("inside handleSelectAll ==> " + isChecked);

            let selectedRows = this.template.querySelectorAll('lightning-input');
            for (let i = 0; i < allRecords.length; i++) {
                if (allRecords[i].opsQuery == false) {
                    allRecords[i].record[fieldName] = event.target.checked;
                }
                let obj = this.saveData.find(item => item.record.Id === allRecords[i].record['Id']);
                if (obj) {
                    // if (obj.record && obj.record.sobjectType == 'Applicant__c') {
                    //     delete record.ApplType__c;
                    //     delete record.Gender__c;
                    // }
                    if (allRecords[i].opsQuery == false) {
                        obj[fieldName] = event.target.checked;
                    }
                } else {
                    // if (allRecords[i].record && allRecords[i].record.sobjectType == 'Applicant__c') {
                    //     delete record.ApplType__c;
                    //     delete record.Gender__c;
                    // }
                    this.saveData.push(allRecords[i]);
                    console.log('this.saveData in select all ', this.saveData)
                }
            }
        }
    }

    getApplicantDetails() {
        this.showSpinner = true;
        let appType = 'P';
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'Name'],
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND ApplType__c = \'' + appType + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Applicant Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.primaryAppId = result.parentRecords[0].Id;
                    console.log('primaryAppId', this.primaryAppId);
                }
                this.showSpinner = false;
            })

            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Document Dispatch Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    handleDocumentDispatch() {
        let numberOfRec = this.disObjDet.length;
        console.log("numberOfRec", numberOfRec);
        let myNewElement = {
            CourierComName__c: "",
            OthrCourierComName__c: "",
            PODNum__c: "",
            DateofDispatch__c: "",
            CPARemarks__c: "",
            DateofReceiptbyOps__c: "",
            OperationRem__c: "",
            Type__c: "",
            PhyFileRec__c: "",
            isDirty: false,
            CreatedByName: "",
            UserRole__c: this.empRole ?? "",
            isCpaUser: this.isCpaUser,
            isOpsUser: this.isOpsUser,
            isNew: true,
            disableOthrCurComName: true
        };
        console.log("myNewElement++++++ = ", myNewElement);

        let disObjDet = [...this.disObjDet, myNewElement];
        this.disObjDet = disObjDet;
    }
    handlChange(event) {
        let currentIndex = event.target.dataset.index;
        let obj = { ...this.disObjDet[event.target.dataset.index] };
        let name = event.target.name;
        let val = event.target.value;
        console.log('name is ', name, 'val is ', val);
        if (name === 'DateofDispatch__c') {
            let currentDate = new Date();
            let pastDate = new Date();
            pastDate.setDate(currentDate.getDate() - 3);
            let futureDate = new Date();
            futureDate.setDate(currentDate.getDate() + 3);
            //LAK-8022
            let selectedDate = new Date(val);
            console.log('Current Date => ' + currentDate + ' Selected Date => ' + selectedDate);
            console.log('Past Date => ' + pastDate + ' Future Date => ' + futureDate);

            if (selectedDate <= pastDate || selectedDate >= futureDate) {
                if (selectedDate <= pastDate) {
                    obj[name] = '';
                    this.showToastMessage('Error', this.label.NdcDetails_scheduledDate_ErrorMessage, 'error', 'sticky');
                    obj[name] = null;
                }
                //LAK-8022
                if (selectedDate >= futureDate) {
                    obj[name] = '';
                    this.showToastMessage('Error', 'Scheduled Date should be current or future date up to 3 days', 'error', 'sticky');
                    obj[name] = null;
                }
            } else {
                obj[name] = val;
                obj.isDirty = true;
            }
        }
        else if (name === 'DateofReceiptbyOps__c') {
            console.log('date of receipt ', new Date(val));
            console.log('date of dispatch ', new Date(obj.DateofDispatch__c));
            let dateofReceipt = new Date(val);
            dateofReceipt.setHours(0, 0, 0, 0);
            let dateOfDispatch = new Date(obj.DateofDispatch__c);
            dateOfDispatch.setHours(0, 0, 0, 0);
            console.log('dateofReceipt > dateOfDispatch', dateofReceipt > dateOfDispatch);
            // LAK-8022
            let currentDateTime = new Date(dateofReceipt);
            let futureDateTime = new Date();
            futureDateTime.setHours(0, 0, 0, 0);
            let maxAllowedDateTime = new Date();
            maxAllowedDateTime.setDate(futureDateTime.getDate() + 3);
            console.log('Current Date Time: ' + currentDateTime);
            console.log('Max Allowed Date Time: ' + maxAllowedDateTime);
            if (currentDateTime >= maxAllowedDateTime) {
                obj[name] = '';
                this.showToastMessage('Error', 'Date of receipt should be current or future date up to 3 days', 'error', 'sticky');
                obj[name] = null;
            } else {
                if (dateofReceipt > dateOfDispatch) {
                    obj[name] = val;
                    obj.isDirty = true;
                } else {
                    obj[name] = '';
                    this.showToastMessage('Error', 'Date of receipt should be greater than Date of Dispatch', 'error', 'sticky');
                    obj[name] = null;
                }
            }

        } else if (name == 'OperationRem__c' || name == 'CPARemarks__c') {
            if (name && val) {
                obj[name] = val.toUpperCase();
                obj.isDirty = true;
            } else {
                obj[name] = val;
                obj.isDirty = true;
            }
        } else if (name === 'PODNum__c') {
            obj[name] = val.toUpperCase();
            obj.isDirty = true;
        } else if (name === 'OthrCourierComName__c') {
            obj[name] = val.toUpperCase();
            obj.isDirty = true;
        } else {
            obj[name] = val;
            obj.isDirty = true;
        }
        this.disObjDet[currentIndex] = obj;
        this.disObjDet = [...this.disObjDet];
        console.log('this.disObjDet  ', this.disObjDet);
    }

    // For LAK-5816
    handleKeyPress(event) {
        const chatCode = event.charCode;
        console.log('chatCode', chatCode);
        if (!((chatCode >= 48 && chatCode <= 57) || (chatCode >= 65 && chatCode <= 90) || (chatCode >= 97 && chatCode <= 122))) {
            event.preventDefault();
        }
    }

    // For LAK-5308
    handleKeyPressNew(event) {
        const chatCode = event.charCode;
        console.log('chatCode', chatCode);
        if (!((chatCode >= 65 && chatCode <= 90) || (chatCode >= 97 && chatCode <= 122) || chatCode === 32)) {
            event.preventDefault();
        }
    }




    //For LAK-5816
    handlePicklistValues(event) {
        let currentIndex = event.detail.index;
        let fieldName = event.detail.fieldName;
        let obj = { ...this.disObjDet[currentIndex] };
        obj.isDirty = true;
        obj[fieldName] = event.detail.val;
        if (fieldName === 'PhyFileRec__c' && event.detail.val === 'Received') {
            obj.isDoRReq = true;
            obj.isOpsRem = false;
            obj.isCpaRem = false;
        } else if (fieldName === 'PhyFileRec__c' && event.detail.val === 'Query' && this.isOpsUser) {
            obj.isOpsRem = true;
            obj.isDoRReq = false;
            obj.isCpaRem = false;
        } else if (fieldName === 'PhyFileRec__c' && event.detail.val === 'Query' && this.isCpaUser) {
            obj.isCpaRem = true;
            obj.isDoRReq = false;
            obj.isOpsRem = false;
        }
        //LAK-5308
        if (fieldName === 'CourierComName__c' && event.detail.val === 'Others') {
            obj.disableOthrCurComName = false;
        } else {
            obj.disableOthrCurComName = true;
        }
        //LAK-5308
        this.disObjDet = [...this.disObjDet];
        this.disObjDet[currentIndex] = obj;
        console.log('this.disObjDet  ', this.disObjDet);
    }

    // handlePicklistValues(event) {
    //     let val = event.detail.val;
    //     let hunterRecordId = event.detail.recordid;
    //     let nameVal = event.detail.nameVal;
    //     console.log('val is in hunter ', val, 'disObjDet id is ', disObjDet, ' name is ', nameVal);
    //     let obj = this.disObjDet.find(item => item.Id === hunterRecordId);
    //     if (obj) {
    //         console.log('obj is ', JSON.stringify(obj));
    //         obj[nameVal] = val;
    //         obj.isChanged = true;
    //     } else {
    //         let objNew = {};
    //         objNew.Id = hunterRecordId;
    //         objNew[nameVal] = val;
    //         objNew.isChanged = true;
    //         this.saveData.push(objNew);
    //     }
    //     console.log('this.savedata  ', this.saveData);
    //     console.log('this.hunterdata  ', this.hunterData);
    //     // this.makeFieldsRequired();
    // }

    @track deleteRecId;
    @track showDocumentDispatchDelete = false;
    @track indexToDelDocDis;
    handleDeleteAction(event) {
        this.deleteRecId = this.disObjDet[event.target.dataset.index].Id;
        this.indexToDelDocDis = event.target.dataset.index;
        // if (deleteRecId === undefined) {
        //     this.disObjDet.splice(event.target.dataset.index, 1);
        // }
        // else {
        //     console.log("delete initated");
        //     this.handleDeleteRecId(deleteRecId);
        // }
        this.showDocumentDispatchDelete = true;
    }
    closeModalDeleteDocDis() {
        this.showDocumentDispatchDelete = false;
    }
    handleDeleteDocDis() {
        this.showDocumentDispatchDelete = false;
        this.showSpinner = true;
        if (this.deleteRecId === undefined) {
            this.disObjDet.splice(this.indexToDelDocDis, 1);
            this.showSpinner = false;
        }
        else {
            console.log("delete initated");
            this.handleDeleteRecId(this.deleteRecId);
        }
    }

    @track del_recIds = []
    handleDeleteRecId(delRecId) {
        let fields = {};
        fields.Id = delRecId
        this.del_recIds = []
        this.del_recIds.push(fields)
        console.log("deleteRec_Array ", this.del_recIds);
        deleteDocDispatchRecord({ rcrds: this.del_recIds }).then((result) => {
            // this.showToastMessage('Success', '', 'success', 'sticky');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: 'POD Details Deleted Successfully',
                    variant: "success",
                    mode: 'sticky'
                })
            );
            this.showSpinner = false;
            this.disObjDet = [];
            this.getDocumentDispatchDet();

        });
    }

    handleNdcTypeChange(event) {
        let name = event.target.name;
        let val = event.target.value;
        console.log('name is ', name, 'val is ', val);
        if (name === 'DisType__c') {
            this.showSpinner = true;
            // this.getNdcSectionDetails();
            if (val === 'Scan Based Disbursement') {
                console.log('this.disObj ', this.disObj);
                // if (this.ndcAprv) {
                this.showdDocDispatch = true;
                // } else { this.showdDocDispatch = false; }
                if (name && val) {
                    this.ndcDisType = val;
                    console.log('obj is ', this.ndcDisType);
                }

            } else {
                if (name && val) {
                    this.showdDocDispatch = false;
                    this.ndcDisType = val;
                    console.log('obj is ', this.ndcDisType);
                }
                // this.showdDocDispatch = false;
                // this.showButton = false;

            }
            this.getNdcSectionDetails();
        }
    }
    @track ndcData = [];
    getNdcRecords() {
        this.showSpinner = true;
        let params = {
            ParentObjectName: 'NDC__c',
            parentObjFields: ['Id', 'NDC_Type__c', 'OpsQuery__c', 'NDC_Section__c', 'ShowOpsQuery__c'],
            queryCriteria: ' where LoanAppl__c = \'' + this.loanAppId + '\' AND IsInvalid__c = false'
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Ndc Recordds Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.ndcData = result.parentRecords;
                    result.parentRecords.forEach(item => {
                        if (item.NDC_Type__c) {
                            this.ndcDisType = item.NDC_Type__c;
                            return;
                        }
                    })
                    // this.ndcDisType = result.parentRecords[0].NDC_Type__c ? result.parentRecords[0].NDC_Type__c : result.parentRecords[1].NDC_Type__c;
                    // this.getNdcSectionDetails();
                    if (this.ndcDisType === 'Scan Based Disbursement') {
                        // if (this.ndcAprv) {
                        this.showdDocDispatch = true;
                        // } else { this.showdDocDispatch = false; }
                        this.getNdcSectionDetails();
                    } else if (this.ndcDisType === 'Physical Disbursement') {
                        this.showdDocDispatch = false;
                        this.getNdcSectionDetails();
                    }
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Ndc records Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    getDocumentDispatchDet() {
        // this.showSpinner = true;
        let params = {
            ParentObjectName: 'DocDispatch__c',
            parentObjFields: ['Id', 'OthrCourierComName__c', 'PhyFileRec__c', 'Type__c', 'CourierComName__c', 'CPARemarks__c', 'DateofDispatch__c', 'DateofReceiptbyOps__c', 'OperationRem__c', 'PODNum__c', 'CreatedBy.Name', 'UserRole__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Document Dispatch Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.disObjDet = result.parentRecords;
                    // Added for LAK-6245
                    if (this.disObjDet && this.disObjDet.length > 0) {
                        this.disObjDet.forEach(item => {
                            item.CreatedByName = item.CreatedBy.Name ?? "";
                            item.isNew = false;
                            if (this.opsHierNewArr.includes(item.UserRole__c)) {
                                item.isOpsUser = true;
                                item.isCpaUser = false;
                            } else if (this.creditHierNewArr.includes(item.UserRole__c)) {
                                item.isCpaUser = true;
                                item.isOpsUser = false;
                            } else {
                                item.isCpaUser = true;
                                item.isOpsUser = false;
                            }
                            if (item.PhyFileRec__c && item.PhyFileRec__c === 'Received') {
                                item.isDoRReq = true;
                                item.isOpsRem = false;
                                item.isCpaRem = false;
                            } else if (item.PhyFileRec__c && item.PhyFileRec__c === 'Query' && item.isOpsUser) {
                                item.isOpsRem = true;
                                item.isDoRReq = false;
                                item.isCpaRem = false;
                            } else if (item.PhyFileRec__c && item.PhyFileRec__c === 'Query' && item.isCpaUser) {
                                item.isCpaRem = true;
                                item.isDoRReq = false;
                                item.isOpsRem = false;
                            }
                            if (item.PhyFileRec__c && (item.PhyFileRec__c === 'Received' && item.DateofReceiptbyOps__c) || (item.PhyFileRec__c === 'Query' && ((item.CPARemarks__c && item.isOpsUser) || (item.OperationRem__c && item.isCpaUser)))) {
                                item.reqFilled = true;
                            } else {
                                item.reqFilled = false;
                            }
                        })

                    }
                    console.log('Document Dispatch Data new is ', this.disObjDet);
                    // End for Changes for LAK-6245
                    this.documentDispatchRecords = result.parentRecords;
                    this.disObj.CourierComName__c = result.parentRecords[0].CourierComName__c ? result.parentRecords[0].CourierComName__c : '';
                    this.disObj.CPARemarks__c = result.parentRecords[0].CPARemarks__c ? result.parentRecords[0].CPARemarks__c : '';
                    this.disObj.DateofDispatch__c = result.parentRecords[0].DateofDispatch__c ? result.parentRecords[0].DateofDispatch__c : '';
                    this.disObj.DateofReceiptbyOps__c = result.parentRecords[0].DateofReceiptbyOps__c ? result.parentRecords[0].DateofReceiptbyOps__c : '';
                    // this.disObj.DisType__c = result.parentRecords[0].DisType__c ? result.parentRecords[0].DisType__c : '';
                    this.disObj.OperationRem__c = result.parentRecords[0].OperationRem__c ? result.parentRecords[0].OperationRem__c : '';
                    this.disObj.PODNum__c = result.parentRecords[0].PODNum__c ? result.parentRecords[0].PODNum__c : '';
                    this.disObj.Type__c = result.parentRecords[0].PODNum__c ? result.parentRecords[0].Type__c : '';
                    this.disObj.Id = result.parentRecords[0].Id;
                    // if (this.disObj.DisType__c === 'Scan Based Disbursement') {
                    //     this.showdDocDispatch = true;
                    //     this.getNdcSectionDetails();
                    // } else if (this.disObj.DisType__c === 'Physical Disbursement') {
                    //     this.showdDocDispatch = false;
                    //     this.getNdcSectionDetails();
                    // }
                }
                this.getLoanApplicationData();
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Document Dispatch Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    @track showAllDocsModal = false;
    handleAllDocsChanged(event) {
        this.allDocsReceived = event.target.checked;
        this.showAllDocsModal = true;
        console.log('this.allDocsReceived', this.allDocsReceived);
    }
    closeModalDeleteAllDocs() {
        this.allDocsReceived = false;
        this.showAllDocsModal = false;
    }
    handleAllDocsSelected() {
        this.showAllDocsModal = false;
        this.showSpinner = true;
        // this.checkAllFilesRec();
        this.checkAllAwbDetRec();
    }
    @track allDocsRec = true;
    checkAllAwbDetRec() {
        if (this.disObjDet && this.disObjDet.length > 0) {
            this.disObjDet.forEach(item => {
                if (item.PhyFileRec__c !== 'Received' && item.PhyFileRec__c !== 'Query') {
                    this.allDocsRec = false;
                }
            })
        }
        this.checkAllFilesRec();
    }
    checkAllFilesRec() {
        let params = {
            ParentObjectName: 'NDC__c',
            parentObjFields: ['Id', 'DocDtl__c', 'NDC_Section__c', 'DocDtl__r.PhyFileRec__c', 'IsInvalid__c'],
            queryCriteria: ' where LoanAppl__c = \'' + this.loanAppId + '\' AND IsInvalid__c = false AND DocDtl__c != null'
        }
        getSobjectData({ params: params })
            .then((result) => {
                this.showSpinner = true;
                console.log('NDC Data is ', JSON.stringify(result));
                let sectionNames = new Set();
                if (result.parentRecords) {
                    result.parentRecords.forEach(item => {
                        if (item.DocDtl__c && (item.DocDtl__r.PhyFileRec__c === 'Query' || !item.DocDtl__r.PhyFileRec__c)) {
                            sectionNames.add(item.NDC_Section__c);
                        }
                    })
                }
                if (!this.allDocsRec) {
                    this.showSpinner = false;
                    this.allDocsReceived = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: 'Physical File not Received for AWB Details',
                            variant: "error",
                            mode: 'sticky'
                        }),
                    );
                }

                if (sectionNames && sectionNames.size > 0) {
                    this.showSpinner = false;
                    this.allDocsReceived = false;
                    let strr = Array.from(sectionNames).join(',');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: 'Physical File not Received for : (' + strr + ')',
                            variant: "error",
                            mode: 'sticky'
                        }),
                    );
                }

                if (sectionNames.size === 0 && this.allDocsRec && this.disbursalType === 'SINGLE') {
                    this.updateLoanAppAllDocs();
                } else if (sectionNames.size === 0 && this.allDocsRec && this.disbursalType === 'MULTIPLE') {
                    this.getDisbursalDetails();
                } else {
                    this.showSpinner = false;
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Document Dispatch Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    getDisbursalDetails() {
        let params = {
            ParentObjectName: 'Disbursement__c',
            parentObjFields: ['Id', 'Disbur_Status__c'],
            queryCriteria: ' where Loan_Appli__c = \'' + this.loanAppId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                this.showSpinner = true;
                console.log('NDC Data is ', JSON.stringify(result));
                let allDis = true;
                if (result.parentRecords) {
                    result.parentRecords.forEach(item => {
                        // && item.Disbur_Status__c !== 'INITIATED' && item.Disbur_Status__c !== 'PARTIALLY DISBURSED'
                        if (item.Disbur_Status__c !== 'DISBURSED') {
                            allDis = false;
                            return;
                        }
                    })
                }
                if (!allDis) {
                    this.showSpinner = false;
                    this.allDocsReceived = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: 'All Tranches are not Disbursed',
                            variant: "error",
                            mode: 'sticky'
                        }),
                    );
                } else if (allDis) {
                    this.updateLoanAppAllDocs();
                }

            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Document Dispatch Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    updateLoanAppAllDocs() {
        let obje = {
            sobjectType: "LoanAppl__c",
            Id: this.loanAppId,
            AllDocRec__c: this.allDocsReceived,
            SubStage__c: 'Completed',
            Status__c: 'Fully Disbursed' //LAK-7307
        }
        let newArray = [];
        if (obje) {
            newArray.push(obje);
        }

        if (newArray) {
            console.log('new array is ', JSON.stringify(newArray));
            upsertMultipleRecord({ params: newArray })
                .then((result) => {
                    console.log('Result after update loan application is ', result);
                    this.showSpinner = false;
                    this[NavigationMixin.Navigate]({
                        type: "standard__objectPage",
                        attributes: {
                            objectApiName: "LoanAppl__c",
                            actionName: "list"
                        },
                        state: {
                            filterName: "Recent"
                        }
                    });
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: 'Loan Application Updated Successfully!',
                            variant: "success",
                            mode: 'sticky'
                        }),
                    );
                })
                .catch((error) => {
                    console.log('error ', JSON.stringify(error));
                    console.table(error);
                    this.showSpinner = false;
                });
        }

    }
    get disableAllDocsCheck() {
        if (this.loanStage === 'Disbursed' && (this.loanSubstage === 'Additional Processing' || this.loanSubstage === 'DI Check') && !this.isReadOnly && this.isOpsUser && !this.allDocsReceived) {
            return false;
        }
        return true;
    }
    get disableDisbType() {
        if ((this.loanStage === 'Disbursement Initiation' && (this.loanSubstage === 'DI Check' || this.loanSubstage === 'DI Pool')) || this.isReadOnly || this.allDocsReceived || this.loanStatus === 'Fully Disbursed') {
            return true;
        }
        return false;
    }
    get disableDisbTypeVal() {
        if ((this.loanStage === 'Disbursement Initiation' && (this.loanSubstage === 'DI Check' || this.loanSubstage === 'DI Pool')) || this.isReadOnly || this.allDocsReceived) {
            return true;
        }
        return false;
    }
    //Added for LAK-7293
    get disableDisbTypeNew() {
        let returnVal = false;
        if (((this.loanStage === 'Disbursement Initiation' || this.loanStage === 'Disbursed') && (this.loanSubstage === 'DI Check' || this.loanSubstage === 'DI Pool')) || this.allDocsReceived) {
            returnVal = true;
        } else if (this.loanStage === 'Disbursed' && this.loanSubstage === 'Additional Processing') {
            returnVal = true;
        } else if (this.isReadOnly) {
            returnVal = true;
        } else {
            returnVal = false;
        }
        return returnVal;
    }
    get disableDisbTy() {
        let returnVal = false;
        if (((this.loanStage === 'Disbursement Initiation' || this.loanStage === 'Disbursed') && (this.loanSubstage === 'DI Check' || this.loanSubstage === 'DI Pool')) || this.allDocsReceived) {
            returnVal = true;
        } else if (this.loanStage === 'Disbursed' && this.loanSubstage === 'Additional Processing' && this.isCpaUser && !this.isReadOnly && this.loanStatus !== 'Fully Disbursed') {
            returnVal = false;
        } else if (this.loanStage === 'Disbursed' && this.loanSubstage === 'Additional Processing' && this.isCpaUser && (this.isReadOnly || this.loanStatus === 'Fully Disbursed')) {
            returnVal = true;
        } else if (this.loanStage === 'Disbursed' && this.loanSubstage === 'Additional Processing' && this.isOpsUser && (this.isReadOnly || !this.isReadOnly)) {
            returnVal = true;
        } else if (this.isReadOnly || this.loanStatus === 'Fully Disbursed') { //LAK-8216
            returnVal = true;
        } else {
            returnVal = false;
        }
        return returnVal;
    }
    //Ended for LAK-7293
    get disableDispatchInputs() {
        let returnVal = false;
        if (((this.loanStage === 'Disbursement Initiation') && (this.loanSubstage === 'DI Check' || this.loanSubstage === 'DI Pool'))) {
            if (this.isReadOnly) {
                returnVal = true;
            } else {
                returnVal = true;
            }
        } else {
            if (this.isReadOnly || this.allDocsReceived) {
                returnVal = true;
            } else {
                returnVal = false;
            }
        }
        return returnVal;
    }
    get disableReceiptdate() {
        let returnVal = false;
        if (((this.loanStage === 'Disbursement Initiation') && (this.loanSubstage === 'DI Check' || this.loanSubstage === 'DI Pool'))) {
            if (this.isReadOnly) {
                returnVal = true;
            } else {
                returnVal = false;
            }
        } else {
            if (this.isReadOnly || this.allDocsReceived) {
                returnVal = true;
            } else {
                returnVal = false;
            }
        }
        return returnVal;
    }

    @track disableOopsVer = false;
    @track disablePhyscFilSend = false;
    @track hideDeleteBrn = false;
    @track allDocsReceived = false;
    @track disbursalType = false;
    @track loanStatus;
    @track creditUserName; // LAK-7525
    @track opsUserName; // LAK-7525
    // @track disableAllDocsCheck = true;
    getLoanApplicationData() {
        let params = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Id', 'Name', 'Status__c', 'NDCAprvd__c', 'Stage__c', 'SubStage__c', 'Product__c', 'AllDocRec__c', 'DisbursalType__c','CPA_User__c','CPA_User__r.Name','OpsUser__c','OpsUser__r.Name','FinnSubDtTime__c'],
            queryCriteria: ' where Id = \'' + this.loanAppId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                this.showSpinner = true;
                console.log('Loan Application Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    // if (result.parentRecords[0].NDCAprvd__c === true) {
                    //     this.showdDocDispatch = true;
                    //     this.getDocumentDispatchDet();
                    // }
                    this.ndcAprv = result.parentRecords[0].NDCAprvd__c;
                    this.loanStage = result.parentRecords[0].Stage__c;
                    this.loanSubstage = result.parentRecords[0].SubStage__c;
                    this.product = result.parentRecords[0].Product__c;
                    this.allDocsReceived = result.parentRecords[0].AllDocRec__c;
                    this.disbursalType = result.parentRecords[0].DisbursalType__c;
                    this.loanStatus = result.parentRecords[0].Status__c; // LAK-8216
                    this.creditUserName = result.parentRecords[0].CPA_User__c ? result.parentRecords[0].CPA_User__r.Name : ''; // LAK-7525
                    this.opsUserName = result.parentRecords[0].OpsUser__c ? result.parentRecords[0].OpsUser__r.Name : ''; // LAK-7525
                    this.finnoneSubmitDate = result.parentRecords[0].FinnSubDtTime__c;
                    // if (((this.loanStage === 'Disbursement Initiation' || this.loanStage === 'Disbursed') && (this.loanSubstage === 'DI Check' || this.loanSubstage === 'DI Pool'))) {
                    //     if (this.isReadOnly) {
                    //         this.disableReceiptdate = true;
                    //         this.disableDispatchInputs = true;
                    //     } else {
                    //         this.disableReceiptdate = false;
                    //         this.disableDispatchInputs = true;

                    //     }
                    // } else {
                    //     if (this.isReadOnly || this.allDocsReceived) {
                    //         this.disableReceiptdate = true;
                    //         this.disableDispatchInputs = true;
                    //     } else {
                    //         this.disableReceiptdate = false;
                    //         this.disableDispatchInputs = false;
                    //     }
                    // }

                    if (this.loanStage === 'Disbursement Initiation' && this.loanSubstage === 'DI Check' && !this.isReadOnly) {
                        this.disableOopsVer = false;
                    } else {
                        this.disableOopsVer = true;
                    }

                    //LAk-6245
                    if (this.loanStage === 'Disbursed' && (this.loanSubstage === 'Additional Processing' || this.loanSubstage === 'DI Check') && !this.isReadOnly && this.isCpaUser) {
                        this.disablePhyscFilSend = false;
                    } else {
                        this.disablePhyscFilSend = true;
                    }
                    // if (this.loanStage === 'Disbursed' && this.loanSubstage === 'Additional Processing' && !this.isReadOnly && this.isOpsUser && !this.allDocsReceived) {
                    //     this.disableAllDocsCheck = false;
                    // } else {
                    //     this.disableAllDocsCheck = true;
                    // }
                    //LAk-6245
                    //FOR LAK-4391
                    // if (((this.loanStage === 'Disbursement Initiation' || this.loanStage === 'Disbursed') && (this.loanSubstage === 'DI Check' || this.loanSubstage === 'DI Pool')) || this.isReadOnly || this.allDocsReceived) {
                    //     this.disableDisbType = true;

                    // } else {
                    //     this.disableDisbType = false;
                    // }
                    //FOR LAK-4391

                    //FOR LAK-5534 && LAK-5533 && LAK-5530
                    if ((this.loanStage === 'Post Sanction' && (this.loanSubstage === 'Data Entry' || this.loanSubstage === 'Ops Query')) || (this.loanStage === 'Disbursed' && this.loanSubstage === 'Additional Processing')) {
                        //         rec.disbaleDelete = true;) {
                        this.hideDeleteBrn = true;

                    } else {
                        this.hideDeleteBrn = false;
                    }
                    //Start LAK-5308
                    if (this.disObjDet && this.disObjDet.length > 0) {
                        this.disObjDet.forEach(item => {
                            if (item.CourierComName__c === 'Others') {
                                if (((this.loanStage === 'Disbursement Initiation') && (this.loanSubstage === 'DI Check' || this.loanSubstage === 'DI Pool'))) {
                                    item.disableOthrCurComName = true;
                                } else {
                                    if (this.isReadOnly || this.allDocsReceived) {
                                        item.disableOthrCurComName = true;
                                    } else {
                                        item.disableOthrCurComName = false;
                                    }
                                }
                                item.disableOthrCurComName = false;
                            } else {
                                item.disableOthrCurComName = false;
                            }

                        })
                    }
                    //End LAK-5308

                    //FOR LAK-5534 && LAK-5533 && LAK-5530
                    this.getNdcRecords();
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Document Dispatch Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }



    getNdcSectionDetails() {
        this.showSpinner = true;
        retrieveNdcData({ loanAppId: this.loanAppId, ndcType: this.ndcDisType })
            .then((result) => {
                console.log('NDC Sections Data is ', result);
                console.log('NDC Sections Data is ', JSON.stringify(result));
                this.ndcSectionData = JSON.parse(JSON.stringify(result));
                let sections = []
                this.ndcSectionData.forEach(item => {
                    let allNdcRecords = this.ndcData.filter(ndcItem => ndcItem.NDC_Section__c === item.ndcSection);
                    item.secCls = 'accClass';
                    allNdcRecords.forEach(ndc => {
                        //OpsQuery__c
                        if (ndc.ShowOpsQuery__c) {
                            item.secCls = 'accClassQuery';
                        }
                    });
                    sections.push(item.ndcSection);
                    let hasNdcRecords = false;
                    item.tablConfig.forEach(ite => {

                        if (ite.ndcRecords && ite.ndcRecords.length > 0) {
                            hasNdcRecords = true;
                            ite.selectAll = this.returnSelectAllOps(ite.ndcRecords);
                            ite.selectAllPhyFU = this.returnSelectAllPhysFilUplod(ite.ndcRecords);
                            ite.disablePhyscFilSend = this.disablePhyFileSendMethod(ite.ndcRecords);
                            ite.hidePhyFileSend = this.hidePhyFileSend(ite.ndcRecords);
                            ite.showSelectAll = true;
                            ite.ndcRecords.forEach(rec => {
                                rec.displayRow = true;
                            })


                            // ite.ndcRecords.forEach(rec => {
                            //     if (((this.loanStage === 'Post Sanction' && (this.loanSubstage === 'Data Entry' || this.loanSubstage === 'Ops Query')) || (this.loanStage === 'Disbursed' && this.loanSubstage === 'Additional Processing')) && !rec.record.OpsVer__c) {
                            //         rec.disbaleDelete = true;
                            //     } else {
                            //         rec.disbaleDelete = false;
                            //     }
                            // })
                        } else {
                            if (item.ndcSection !== 'APF Details') {
                                hasNdcRecords = true;
                            }
                            ite.selectAll = false;
                            ite.showSelectAll = false;
                        }


                        ite.columnConfig.forEach(col => {
                            if (col.width) {
                                col.style = 'width: ' + col.width;
                            }
                             //LAK-8619
                             if (col.type === 'Query') {
                                col.isVisible = ((this.loanStage === 'Post Sanction' && this.loanSubstage === 'Data Entry' && !this.queryEnable) || (this.loanStage === 'Post Sanction' && this.loanSubstage === 'UW Approval')) ? false : true;
                            } 

                            //col.type === 'Query' removed for LAK-8619
                            if (col.fieldName === 'OpsVer__c') {
                                col.isVisible = ((this.loanStage === 'Post Sanction' && this.loanSubstage === 'Data Entry') || (this.loanStage === 'Post Sanction' && this.loanSubstage === 'UW Approval')) ? false : true;
                            } else if(col.type !== 'Query'){ //LAK-8619
                                col.isVisible = true;
                            }
                           
                            //Start added for LAK-6245
                            if (col.fieldName === 'PhyFileSend__c' && ((this.loanStage !== 'Disbursed' && (this.loanSubstage !== 'Additional Processing' || this.loanSubstage !== 'DI Check')) || (this.loanStage === 'Disbursed' && (this.loanSubstage === 'Additional Processing' || this.loanSubstage === 'DI Check') && this.ndcDisType === 'Physical Disbursement'))) {
                                col.isVisible = false;
                            }
                            if (col.fieldName === 'PhyFileRec__c' && ((this.loanStage !== 'Disbursed' && (this.loanSubstage !== 'Additional Processing' || this.loanSubstage !== 'DI Check')) || (this.loanStage === 'Disbursed' && (this.loanSubstage === 'Additional Processing' || this.loanSubstage === 'DI Check') && this.ndcDisType === 'Physical Disbursement'))) {
                                col.isVisible = false;
                            }
                            // End added for LAK-6245

                            // if (col.fieldName === 'PhyFileSend__c' && this.loanStage === 'Disbursed' && this.loanSubstage === 'Additional Processing' && !this.isOpsUser && this.isCpaUser && !this.readOnlyNew) {
                            //     col.disableOopsVer = false;
                            // } else if (this.col.fieldName === 'PhyFileSend__c' && this.loanStage === 'Disbursed' && this.loanSubstage === 'Additional Processing' && this.isOpsUser && !this.isCpaUser) {
                            //     col.disableOopsVer = true;
                            // }

                        })
                    })
                    item.showSection = hasNdcRecords;
                })
                this.activeSections = [...this.activeSections, ...sections];
                this.showTables = true;
                console.log('sections are ', sections);
                console.log('active sections are ', this.activeSections);
                console.log('ndc section data final is ', this.ndcSectionData);

                this.showSpinner = false;
            })
            .catch((error) => {
                this.showTables = false;
                this.showSpinner = false;
                console.log('Error In getting getNdcSectionDetails Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    returnSelectAllOps(ndcRecords) {
        let allSelected = true;
        ndcRecords.forEach(item => {
            if (!item.record.OpsVer__c) {
                allSelected = false
            }
        })
        return allSelected;
    }
    returnSelectAllPhysFilUplod(ndcRecords) {
        let allSelected = true;
        ndcRecords.forEach(item => {
            if (!item.record.PhyFileSend__c) {
                allSelected = false
            }
        })
        return allSelected;
    }
    disablePhyFileSendMethod(ndcRecords) {
        // if (this.loanStage === 'Disbursed' && (this.loanSubstage === 'Additional Processing' || this.loanSubstage === 'DI Check') && !this.isReadOnly && this.isCpaUser) {
        //     this.disablePhyscFilSend = false;
        // } else {
        //     this.disablePhyscFilSend = true;
        // }
        let count = 0;
        ndcRecords.forEach(item => {
            if (item.record.PhyFileSend__c) {
                count++;
            }
        });
        if (count > 0) {
            return true;
        } else if (this.loanStage === 'Disbursed' && (this.loanSubstage === 'Additional Processing' || this.loanSubstage === 'DI Check') && !this.isReadOnly && !this.isCpaUser) {
            return true;
        }
        return false;
    }
    hidePhyFileSend(ndcRecords) {
        let count = 0;
        ndcRecords.forEach(item => {
            if (item.record.PhyFileSend__c) {
                count++;
            }
        });
        if (count === ndcRecords.length) {
            return false;
        } else if (count > 0) {
            return true;
        }
        return false;
    }
    @track showModalForFilePre = false;
    cdId;
    cvid;
    url;
    fileType;
    docIdToPreview;
    @track hasDocumentId;
    handlePreview(event) {
        this.hasDocumentId = true;
        console.log('preview details ', event.detail);
        this.cdId = event.detail.cdId;
        this.cvid = event.detail.cvId;
        this.fileType = event.detail.fileType;
        this.url = event.detail.url;
        this.docIdToPreview = event.detail.docId;
        this.showModalForFilePre = true;
        console.log('this.url' + this.url);
        console.log('this.cvid  ' + this.cvId, 'fileType ', this.fileType, 'this.cdId ', this.cdId);

    }

    handleCloseModalEvent(event) {
        this.showModalForFilePre = false;
    }
    ndcId;
    showQuery = false;

    handleQueryAdd(event) {
        let ndcRecord = event.detail;
        let tempArr = JSON.parse(JSON.stringify(this.ndcSectionData));
        this.ndcSectionData = [];
        let saveObjId;
        // this.ndcSectionData
        tempArr.forEach(item => {
            if (ndcRecord.NDC_Section__c === item.ndcSection) {
                let allNdcRecords = this.ndcData.filter(ndcItem => ndcItem.NDC_Section__c === item.ndcSection);
                item.secCls = 'accClass';
                allNdcRecords.forEach(ndc => {
                    if (ndc.Id == ndcRecord.Id) {
                        ndc.OpsQuery__c = ndcRecord.OpsQuery__c;
                        ndc.ShowOpsQuery__c = ndcRecord.ShowOpsQuery__c;
                    }
                    if (ndc.ShowOpsQuery__c) {
                        item.secCls = 'accClassQuery';
                        return;
                    }
                });
                item.tablConfig.forEach(ite => {
                    ite.ndcRecords.forEach(ndc => {
                        if (ndc.ndcId == ndcRecord.Id) {
                            ndc.opsQuery = ndcRecord.OpsQuery__c;
                            ndc.showOpsQuery = ndcRecord.ShowOpsQuery__c;
                            ndc.record['OpsVer__c'] = false;
                            saveObjId = ndc.record.Id;
                            return;
                        }
                    });
                })
            }
        })

        if (saveObjId) {
            let obj = this.saveData.find(item => item.record.Id === saveObjId);
            if (obj) {
                obj.record['OpsVer__c'] = false;;
            }
            console.log('this.save data is ', this.saveData);
        }

        this.ndcSectionData = tempArr;
        this.showQuery = false;
        console.log('this.ndcSectionData after adding query', this.ndcSectionData);
    }
    handleQueryRemarks(event) {
        console.log('Query details ', event.detail);
        this.ndcId = event.detail.ndcId;
        this.showQuery = true;
    }
    handleCloseRem(event) {
        console.log('handleCloseRem ', event.detail);
        this.showQuery = false;
    }
    handleCloseModalEvent() {
        this.showModalForFilePre = false;
    }

    handleDocumentUpload(event) {
        const tempArray = JSON.parse(JSON.stringify(this.ndcSectionData));
        console.log('Document  Detail Record event details ', event.detail);
        let recordDet = event.detail.record;
        // recordDet.displayRow = true;
        let sectionName = event.detail.sectionName;
        let appAssetId = event.detail.appAssetId;
        console.log('recordDetrecordDet', recordDet, sectionName, appAssetId);
        if (recordDet && sectionName && appAssetId) {
            let obj = tempArray.find(item => item.ndcSection === sectionName);
            if (obj) {
                let arr = obj.tablConfig;
                let ndcRecordObj = arr.find(item => item.applicantAssetId === appAssetId);
                if (ndcRecordObj) {
                    // ndcRecordObj.ndcRecords.push({ "record": recordDet });
                    if (ndcRecordObj.ndcRecords) {
                        ndcRecordObj.ndcRecords.push({ "record": recordDet, "displayRow": true });
                    } else {
                        let ndcRecordsData = [];
                        ndcRecordsData.push({ "record": recordDet, "displayRow": true });
                        console.log('ndcRecordsData ', ndcRecordsData);
                        ndcRecordObj.ndcRecords = [...ndcRecordsData];
                        console.log('ndcRecordObj.ndcRecords ', ndcRecordObj.ndcRecords);
                    }

                }

                // arr.push({ "record": recordDet[0] });
            }
        }
        // For LAK-4013
        else {
            let obj = tempArray.find(item => item.ndcSection === sectionName);
            if (obj) {
                // let arr = obj.tablConfig[0].ndcRecords;
                if (obj.tablConfig[0].ndcRecords && obj.tablConfig[0].ndcRecords.length > 0) {
                    obj.tablConfig[0].ndcRecords.push({ "record": recordDet, "displayRow": true });
                } else {
                    obj.tablConfig[0].ndcRecords.push({ "record": recordDet, "displayRow": true });
                    // let ndcRecordsData = [];
                    // ndcRecordsData.push({ "record": recordDet });
                    // console.log('ndcRecordsData ', ndcRecordsData);
                    // arr = [...ndcRecordsData];
                    // console.log('arr ', arr);
                }
            }
        }
        this.ndcSectionData = tempArray;
        // For LAK-4013
        console.log('this.ndcSectionData  ', this.ndcSectionData);
        // this.getNdcSectionDetails();
    }
    handleDevRecCreation(event) {
        console.log('Deviation Record event details ', event.detail);
        let recordDet = event.detail.record;
        let sectionName = event.detail.sectionName;
        if (recordDet && sectionName) {
            let obj = this.ndcSectionData.find(item => item.ndcSection === sectionName);
            if (obj) {
                let arr = obj.tablConfig[0].ndcRecords;
                arr.push({ "record": recordDet[0], "displayRow": true });
            }
        }
        console.log('this.ndcSectionData  ', this.ndcSectionData);
    }
    @track saveData = [];
    handleSaveData(event) {
        console.log('event details for save is ', event.detail);
        if(event.detail.colType && event.detail.colType !== 'textarea'){ //LAK-9175
            if (event.detail.sectionName) {
                let obj = this.ndcSectionData.find(item => item.ndcSection === event.detail.sectionName);
                if (obj) {
                    if (event.detail.appAssetId) {
                        let arr3 = obj.tablConfig;
                        let ndcRecordObj = arr3.find(item => item.applicantAssetId === event.detail.appAssetId);
                        let arr = ndcRecordObj.ndcRecords;
                        if (arr) {
                            let obj2 = arr.find(item => item.record.Id === event.detail.recordId);
                            if (obj2) {
                                event.detail.fieldNames.forEach(field => {
                                    obj2.record[field] = event.detail.record[field];
                                })
                            }
                            console.log('this.ndcSectionData in changing values ', this.ndcSectionData);
                        }
                    } else {
                        let arr = obj.tablConfig[0].ndcRecords;
                        if (arr) {
                            let obj2 = arr.find(item => item.record.Id === event.detail.recordId);
                            if (obj2) {
                                event.detail.fieldNames.forEach(field => {
                                    obj2.record[field] = event.detail.record[field];
                                })
                            }
                            console.log('this.ndcSectionData in changing values ', this.ndcSectionData);
                        }
                    }
                }
            }
        }
       


        let obj = this.saveData.find(item => item.record.Id === event.detail.recordId);
        if (obj) {
            event.detail.fieldNames.forEach(field => {
                obj.record[field] = event.detail.record[field];
            })
        } else {
            let objNew = {};
            let record = event.detail.record;
            objNew.record = record;
            objNew.ndcId = event.detail.ndcId;
            this.saveData.push(objNew);
        }
        console.log('this.save data is ', this.saveData);
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
    async handleSaveThroughLms(values) {
        console.log('values to save through Lms ', JSON.stringify(values));

        if (values.validateBeforeSave) {
            // let child = this.template.querySelector('c-ndc-datatable-display-value');
            // let returnVal = child.validateForm();

            let returnVal = this.checkReportValidity('save');
            let docAv = await this.getPropDocDetails();
           
            console.log('return val from data iss ', returnVal);
            if (!docAv) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: 'Atleast One Property Document is required',
                        variant: "error",
                        mode: 'sticky'
                    }),
                );
            }   
            if (returnVal === true && docAv) {
                this.handlevSubmit(values.validateBeforeSave);
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: 'Required Fields Missing',
                        variant: "error",
                        mode: 'sticky'
                    }),
                );
            }

        } else {
            let returnVal = this.checkReportValidity('saveAsDraft');
            if (returnVal) {
                this.handlevSubmit(values.validateBeforeSave);
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: 'Required Fields Missing in AWB Details',
                        variant: "error",
                        mode: 'sticky'
                    }),
                );
            }
            // this.handlevSubmit(values.validateBeforeSave);
        }



    }
    //LAK-9348
    getMissingDocs() {
            this.showSpinner  = true;
            ndcDocumentCheck({ loanAppId : this.loanAppId })
                    .then((result) => {
            if(result && result.length > 0){
                this.showSpinner = false;
                result.forEach(item=>{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: item.docCategry +' : Please Upload Document For ' +item.docDetName +' on Ndc Screen.',
                            variant: "error",
                            mode: 'sticky'
                        }),
                    );
                    
                })
                }else{
                    this.showSpinner = false;
                    this.showToastMessage('Success', this.label.NdcDetails_Save_SuccesMessage, 'success', 'sticky');
                    this.getNdcSectionDetails();
                    this.getDocumentDispatchDet();
                    // this.dispatchEvent(new RefreshEvent());
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.loanAppId,
                            objectApiName: 'LoanAppl__c',
                            actionName: 'edit'
                        },
                    });
                }
                    })
                    .catch((error) => {
                        this.showSpinner = false;
                        console.log('Error In getting Missing Docs Data is ', error);
                        //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
                    });
            
    }

    getPropDocDetails() {
        return new Promise((resolve, reject) => {
            this.showSpinner = true;
            let docAvi;
            let docCat = 'Property Documents';
            let params = {
                ParentObjectName: 'DocDtl__c',
                parentObjFields: ['Id', 'DocCatgry__c'],
                queryCriteria: ' where LAN__c = \'' + this.loanAppId + '\' AND DocCatgry__c = \'' + docCat + '\''
            }
            getSobjectData({ params: params })
                .then((result) => {
                    this.showSpinner = false;
                    console.log('Doc Dtl Data is ', JSON.stringify(result));
                    if (result.parentRecords && result.parentRecords.length > 0) {
                        docAvi = true;
                    } else {
                        docAvi = false;
                    }
                    resolve(docAvi);
                })
                .catch((error) => {
                    reject(error);
                    this.showSpinner = false;
                    console.log('Error In getting Document Detail Data is ', error);
                    //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
                });
        });
    }
    checkReportValidity(val) {
        let isValid = true;
        if (val === 'save') {
            this.template.querySelectorAll('c-ndc-datatable-display-value').forEach(element => {
                if (element.reportValidity()) {
                    console.log('c-ndc-datatable-display-value');
                    console.log('element if--' + element.value);
                } else {
                    isValid = false;
                    console.log('element else--' + element.value);
                }
            });
        }
        this.template.querySelectorAll('c-hunter-displayvalue').forEach(element => {
            if (element.reportValidity()) {
                console.log('c-hunter-displayvalue');
                console.log('element if--' + element.value);
            } else {
                isValid = false;
                // element.setCustomValidity("Received Date can not be future date");
                console.log('element else--' + element.value);
            }
            // element.reportValidity("");
        });
        this.template.querySelectorAll('lightning-textarea').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed');
            } else {
                isValid = false;
            }
        });
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed');
            } else {
                isValid = false;
            }
        });
        return isValid;
    }

     handlevSubmit(validate) {
        this.showSpinner = true;
        if (this.disObjDet.length > 0) {
            this.disObjDet.forEach(item => {
                item.sobjectType = 'DocDispatch__c';
            })
        }
        this.saveData.forEach(item => {
            if (item.record.ApplType__c) {
                delete item.record.ApplType__c;
            }
            if (item.record.Gender__c) {
                delete item.record.Gender__c;
            }
        });
        console.log('loanAppId ', this.loanAppId, 'ndcType ', this.disObj, 'ndcSaveData ', this.saveData, ' this.disObjDet ', this.disObjDet);
        console.log('validate ', validate);
        saveNdcData({ loanAppId: this.loanAppId, ndcType: this.ndcDisType, ndcSaveData: this.saveData, recordsToDelete: this.recordToDelete, ndcIdsToDelete: this.ndcIdsToDelete, disObjDet: this.disObjDet })
            .then((result) => {
                // console.log('result ');
                this.showSpinner = false;
                if(validate && this.loanStage && this.loanStage === 'Post Sanction'){
                 this.getMissingDocs(); //LAK-9348
                }else{
                    this.showToastMessage('Success', this.label.NdcDetails_Save_SuccesMessage, 'success', 'sticky');
                    this.getNdcSectionDetails();
                    this.getDocumentDispatchDet();
                    // this.dispatchEvent(new RefreshEvent());
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.loanAppId,
                            objectApiName: 'LoanAppl__c',
                            actionName: 'edit'
                        },
                    });
                }
               

                // const evt = new ShowToastEvent({
                //     title: 'Success',
                //     variant: 'success',
                //     message: 'Records Saved Successfully!'
                // });
                // this.dispatchEvent(evt);
               
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In Saving Records', error);
                const evtt = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: error.body.message,
                    mode: 'sticky'
                });
                this.dispatchEvent(evtt);
                // this.fireCustomEvent("Error", "error", "Error occured in accepting File  " + error, false);
            });
    }


    @track showUploadModal = false;
    @track showModalForDelete = false;
    @track documentId;
    @track cldId;

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpeg', '.jpg'];
    }
    handleUploadingDocument(event) {
        console.log('event details ', event.detail);
        this.showUploadModal = true;
        this.documentId = event.detail.recordId;
        this.sectionName = event.detail.sectionName;
        this.appAssetIdForUp = event.detail.appAssetId;
    }

    handleDeletingDocument(event) {
        this.showModalForDelete = true;
        this.cldId = event.detail.cdlId;
        this.documentId = event.detail.recordId;
        this.sectionName = event.detail.sectionName;
        this.appAssetIdForUp = event.detail.appAssetId;
    }
    handleRemoveRecord() {
        // let arr = [];
        // if (this.documentId) {
        //     let obj = {};
        //     obj.Id = this.documentId;
        //     // obj.sobjectType = 'IntgMsg__c';
        //     arr.push(obj);
        // }
        if (this.documentId) {
            // console.log('arr is ', arr);
            deleteDocRecord({ docDtlId: this.documentId })
                .then((result) => {
                    this.showModalForDelete = false;
                    //console.log('Result after Deleteing Doc Cdl is ', JSON.stringify(result));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: this.label.NdcDetails_DocDelete_SuccesMessage,
                            variant: "success",
                            mode: 'sticky'
                        })
                    );
                    let currtEmpYears = this.template.querySelector(`c-ndc-datatable-display-value[data-fieldname="Id"][data-recordid="${this.documentId}"]`);
                    if (currtEmpYears) {
                        // Calling the method if the element is found
                        currtEmpYears.getDocDetToPreview();
                    } else {
                        console.error('Element not found.');
                    }
                })
                .catch((error) => {
                    console.log('Error In creating Record', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: error.body.message,
                            variant: "error",
                            mode: 'sticky'
                        })
                    );
                });
        }
    }
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.showUploadModal = false;
        this.showToastMessage('Success', this.label.NdcDetails_DocUpload_SuccesMessage, 'success', 'sticky');

        // const evt = new ShowToastEvent({
        //     title: 'Success',
        //     variant: 'success',
        //     message: 'Document Uploaded Successfully'
        // });
        this.dispatchEvent(evt);
        console.log('sectionname ', event.target.dataset.sectionname, 'appassetid ', event.target.dataset.appaseetid);
        let currtEmpYears = this.template.querySelector(`c-ndc-datatable-display-value[data-fieldname="Id"][data-recordid="${this.documentId}"]`);
        if (currtEmpYears) {
            // Calling the method if the element is found
            currtEmpYears.getDocDetToPreview();
        } else {
            console.error('Element not found.');
        }
    }

    handleUploadDoc(event) {
        console.log('event details are ', event.detail);
        this.showUploadModal = false;
        let currtEmpYears = this.template.querySelector(`c-ndc-datatable-display-value[data-fieldname="Id"][data-recordid="${this.documentId}"]`);
        if (currtEmpYears) {
            // Calling the method if the element is found
            currtEmpYears.getDocDetToPreview();
        } else {
            console.error('Element not found.');
        }
    }
    @track showSpinnerNew = false;
    fromUploadDocsContainer() {
        this.showSpinnerNew = false;
        this.showUploadModal = false;
        let currtEmpYears = this.template.querySelector(`c-ndc-datatable-display-value[data-fieldname="Id"][data-recordid="${this.documentId}"]`);
        if (currtEmpYears) {
            // Calling the method if the element is found
            currtEmpYears.getDocDetToPreview();
        } else {
            console.error('Element not found.');
        }
    }
    spinnerStatus(event) {
        console.log('spinner value ', event.detail);
        this.showSpinnerNew = event.detail;
        this.showUploadModal = event.detail;
    }
    @track recordToDelete = [];
    @track ndcIdsToDelete = [];
    @track sectionNameDel;
    @track recordDetDel;
    @track appAssetIdDel;
    @track showModalForDeleteDoc = false;
    handleDelete(event) {
        this.sectionNameDel = event.target.dataset.section;
        this.recordDetDel = event.target.dataset.id;
        this.appAssetIdDel = event.target.dataset.appassetid;
        this.showModalForDeleteDoc = true;
        console.log('sectionName For Del ', this.sectionNameDel, 'recordId ', this.recordDetDel, 'appAssetId ', this.appAssetIdDel);
    }

    handleRemoveRecordDel() {
        this.showModalForDeleteDoc = false;
        console.log('sectionName', this.sectionNameDel, 'recordId ', this.recordDetDel, 'appAssetId ', this.appAssetIdDel);
        if (this.recordDetDel && this.sectionNameDel && this.appAssetIdDel) {
            let obj = this.ndcSectionData.find(item => item.ndcSection === this.sectionNameDel);
            if (obj) {
                let arr = obj.tablConfig;
                let ndcRecordObj = arr.find(item => item.applicantAssetId === this.appAssetIdDel);
                if (ndcRecordObj) {
                    // ndcRecordObj.ndcRecords.push({ "record": recordDet });
                    if (ndcRecordObj.ndcRecords) {

                        let obj = ndcRecordObj.ndcRecords.find(ite => ite.record.Id === this.recordDetDel);
                        console.log('obj is ', obj);
                        if (obj) {
                            obj.displayRow = false;
                            this.recordToDelete.push(obj.record);
                            if (obj.ndcId) {
                                this.ndcIdsToDelete.push(obj.ndcId);
                            }
                            console.log('recordToDelete ', this.recordToDelete);
                        }
                        console.log('recordToDelete ', this.recordToDelete);

                        // let indexToRemove = ndcRecordObj.ndcRecords.findIndex(item => item.record.Id === this.recordDetDel);
                        // console.log('indexToRemove ', indexToRemove);
                        // if (indexToRemove !== -1) {
                        //     // Remove the element at the found index
                        //     ndcRecordObj.ndcRecords.splice(indexToRemove, 1);
                        // }
                        console.log('ndcRecordObj.ndcRecords  ', ndcRecordObj.ndcRecords);

                    }
                }
            }
        }

        if (this.recordDetDel && this.sectionNameDel) {
            let obj = this.ndcSectionData.find(item => item.ndcSection === this.sectionNameDel);
            if (obj) {
                let arr = obj.tablConfig[0].ndcRecords;
                if (arr) {
                    // ndcRecordObj.ndcRecords.push({ "record": recordDet });
                    let obj = arr.find(item => item.record.Id === this.recordDetDel);
                    if (obj) {
                        obj.displayRow = false;
                        this.recordToDelete.push(obj.record);
                        if (obj.ndcId) {
                            this.ndcIdsToDelete.push(obj.ndcId);
                        }
                        console.log('recordToDelete ', this.recordToDelete);
                    }
                    // let indexToRemove = arr.findIndex(item => item.record.Id === this.recordDetDel);
                    // console.log('indexToRemove ', indexToRemove);
                    // if (indexToRemove !== -1) {
                    //     // Remove the element at the found index
                    //     arr.splice(indexToRemove, 1);
                    // }
                }
            }
        }
        console.log('this.ndcSectionData ', this.ndcSectionData);

    }
    closeModalDeleteDoc() {
        this.showModalForDeleteDoc = false;
    }
    closeUploadModal() {
        this.showUploadModal = false;
    }
    closeModalDelete() {
        this.showModalForDelete = false;
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
}