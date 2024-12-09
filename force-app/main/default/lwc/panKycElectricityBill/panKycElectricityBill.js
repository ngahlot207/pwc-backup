import { LightningElement, api, track } from 'lwc';
import getAssetPropType from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';
import { createRecord, updateRecord } from "lightning/uiRecordApi";


import INTG_MSG from "@salesforce/schema/IntgMsg__c";
import NAME from "@salesforce/schema/IntgMsg__c.Name";
import REF_ID from "@salesforce/schema/IntgMsg__c.RefId__c";
import BU from "@salesforce/schema/IntgMsg__c.BU__c";
import IS_ACTIVE from "@salesforce/schema/IntgMsg__c.IsActive__c";
import SVC from "@salesforce/schema/IntgMsg__c.Svc__c";
import EXUC_TYPE from "@salesforce/schema/IntgMsg__c.ExecType__c";
import STATUS from "@salesforce/schema/IntgMsg__c.Status__c";
import REF_OBJ from "@salesforce/schema/IntgMsg__c.RefObj__c";
import DOC_API from "@salesforce/schema/IntgMsg__c.DocApi__c";
import OUTBOUND from "@salesforce/schema/IntgMsg__c.Outbound__c";
import PARENT_REF_ID from "@salesforce/schema/IntgMsg__c.ParentRefId__c";
import PARENT_REF_OBJ from "@salesforce/schema/IntgMsg__c.ParentRefObj__c";
import TRIGGER_PLATFORM_EVENT from "@salesforce/schema/IntgMsg__c.Trigger_Platform_Event__c";

import APP_KYC_ID from "@salesforce/schema/ApplKyc__c.Id";
import Date_Of_Expiry from "@salesforce/schema/ApplKyc__c.DtOfExp__c";
import AREA from "@salesforce/schema/ApplKyc__c.Area__c";
import AREA_CODE from "@salesforce/schema/ApplKyc__c.AreaCode__c";
import REG_NUMBER from "@salesforce/schema/ApplKyc__c.RegNo__c";
import SVC_PROVIDER from "@salesforce/schema/ApplKyc__c.SvcProvider__c";
import SVC_PROVIDER_CODE from "@salesforce/schema/ApplKyc__c.ScvProviderCode__c";
import CONSUMER_ID from "@salesforce/schema/ApplKyc__c.ConsumerId__c";
import BILL_DIST from "@salesforce/schema/ApplKyc__c.BillDist__c";

import DocDet_ID from "@salesforce/schema/DocDtl__c.Id";
import Utility_Bill_Date from "@salesforce/schema/DocDtl__c.UtilityBillDate__c";

export default class PanKycElectricityBill extends LightningElement {
    @api showElectricityBill;
    @api layoutSize;
    @api disableMode;
    @track appKycId;
    @track documentDetId;
    @api retriggerClickedVal;
    //  @api createIntMsz;
    @track showValidateBtn = false;
    @api retrigger = false;

    //  @track _createIntMsz;
    @api createIntMsz;
    // @api get createIntMsz() {
    //     return this._createIntMsz;
    // }
    // set createIntMsz(value) {
    //     console.log(' createIntMsz  ! ' + value);
    //     this._createIntMsz = value;
    //     this.setAttribute("createIntMsz", value);
    // }

    get filtercondition() {
        let type = 'Electricity Service Provider';
        return 'Type__c = \'' + type + '\'';
    }
    get filterconditionDist() {
        let type = 'Electricity Service Provider District';
        if (this.spValue != null) {
            return 'Type__c = \'' + type + '\'' + ' AND ScvProviderCode__c = \'' + this.spValue + '\'';
        } else {
            return '';
        }
    }
    @track utilityBillDate;
    get utilityBillMinDate() {
        // Set the minimum date to 60 days ago
        const minDate = new Date();
        minDate.setDate(minDate.getDate() - 60);
        return minDate.toISOString().split('T')[0];
    }
    get todayDateValueForUB() {
        const today = new Date();
        today.setDate(today.getDate() - 1);
        return today.toISOString().split('T')[0];
    }
    handleForwardClicked(event) {
        console.log('handleForwardClicked child == ', event.detail);
    }
    connectedCallback() {
        setTimeout(() => {

        }, 2000);
        this.retrigger = false;
        console.log('this.retriggerClickedVal : in cc', this.retriggerClickedVal, this.createIntMsz);
        if (this.retriggerClickedVal != null) {
            this.retrigger = true;
            this.appKycId = this.retriggerClickedVal.appKycId;
            this.utilityBillDate = this.retriggerClickedVal.cDUtilBillDate;
            let vall = { value: this.retriggerClickedVal.cDUtilBillDate };
            let eve = { target: vall };
            this.handleInputChangeUtilityBillDate(eve);
            console.log('retriggerClickedVal in child ', eve, JSON.stringify(this.retriggerClickedVal));

            if (this.appKycId) {
                console.log('appKycId in child = ', this.appKycId);
                let params = {
                    ParentObjectName: 'ApplKyc__c',
                    parentObjFields: ["Id", "ScvProviderCode__c", "SvcProvider__c", "ConsumerId__c", "BillDist__c"],
                    queryCriteria: ' where Id = \'' + this.appKycId + '\''
                };
                getSobjectDataNonCacheable({ params: params })
                    .then((result) => {
                        if (result && result.parentRecords && result.parentRecords.length > 0) {
                            let res = result.parentRecords[0];
                            console.log('Electricity Bill details ', res);
                            this.spValue = res.ScvProviderCode__c;
                            this.spLabel = res.SvcProvider__c;
                            this.billDist = res.BillDist__c;
                            this.consumerIdValue = res.ConsumerId__c;
                        }
                    })
                    .catch(error => {
                        console.log("get applicantKyc error ", error);
                    })
            }
        }
        // if (this.createIntMsz != null) {
        //     console.log('in cc for createIntMsz ', this.createIntMsz);
        //     this.fromUploadDocsContainer(this.createIntMsz);
        // }
    }
    @api fromUploadDocsContainer(ev) {// after uploading file by parent 
        console.log('fromUploadDocsContainer in child', ev, this.spValue);

        if (ev.docName === 'Electricity Bill') {

            this.appKycId = ev.appKycId;
            this.documentDetId = ev.docDetailId;
            this.selectedDocName = ev.docName;
            const appKyc = {};
            appKyc[APP_KYC_ID.fieldApiName] = ev.appKycId;
            appKyc[SVC_PROVIDER.fieldApiName] = this.spLabel;
            appKyc[SVC_PROVIDER_CODE.fieldApiName] = this.spValue;
            appKyc[CONSUMER_ID.fieldApiName] = this.consumerIdValue;
            appKyc[BILL_DIST.fieldApiName] = this.billDist;
            const recordInput = {
                fields: appKyc
            };

            this.updateRecordMethodNew(recordInput, 'Electricity Bill Authentication', ev.appKycId, ev.docDetailId);
            console.log('fromUploadDocsContainer after update');
            if (ev.docDetailId) {

                const docDetail = {};
                docDetail[DocDet_ID.fieldApiName] = ev.docDetailId;
                docDetail[Utility_Bill_Date.fieldApiName] = this.utilityBillDate;
                const recordInput = {
                    fields: docDetail
                };
                this.updateRecordMethod(recordInput, 'Utility Bill Date');
            }
        }
        // else if (ev.docName === 'Electricity Bill' && this.spValue === 'Others') {
        //     this.stopSpinner();
        // }
    }

    updateRecordMethodNew(recordInput, msz, appKycId, docDtlId) {
        let data = { startSpinner: true }
        this.callParent(data);
        updateRecord(recordInput)
            .then((record) => {
                if (msz === 'Electricity Bill Authentication' && this.spLabel != 'Others') {
                    this.createIntegrationMsg(appKycId, docDtlId, "Electricity Bill Authentication");
                    console.log('fromUploadDocsContainer after update updateRecordMethodNew');
                } else {

                }
            })
            .catch((err) => {
                console.log(" Error In " + msz + " update", err.body.message);
            })
    }


    createIntegrationMsg(appKycId, ddId, serviceName) {

        let data2 = { startSpinner: true }
        this.callParent(data2);
        const fields = {};

        fields[NAME.fieldApiName] = serviceName; //serviceName;//'KYC OCR'
        fields[BU.fieldApiName] = 'HL / STL';
        fields[IS_ACTIVE.fieldApiName] = true;
        fields[SVC.fieldApiName] = serviceName; //serviceName;
        fields[EXUC_TYPE.fieldApiName] = 'Async';
        fields[STATUS.fieldApiName] = 'New';
        fields[DOC_API.fieldApiName] = true;
        fields[OUTBOUND.fieldApiName] = true;
        fields[TRIGGER_PLATFORM_EVENT.fieldApiName] = true;
        fields[REF_OBJ.fieldApiName] = 'DocDtl__c';
        fields[REF_ID.fieldApiName] = ddId;
        fields[PARENT_REF_OBJ.fieldApiName] = "ApplKyc__c";
        fields[PARENT_REF_ID.fieldApiName] = appKycId;
        //4. Prepare config object with object and field API names 
        const recordInput = {
            apiName: INTG_MSG.objectApiName,
            fields: fields
        };

        //5. Invoke createRecord by passing the config object


        createRecord(recordInput).then((record) => {
            let data = { subscribePlatEve: true };
            this.callParent(data);
            let data1 = { startSpinner: true }
            this.callParent(data1);

            console.log('fromUploadDocsContainer after update updateRecordMethodNew', record.id);
        });
    }
    callParent(data) {
        let selectEvent = new CustomEvent('fromchild', {
            detail: data
        });
        this.dispatchEvent(selectEvent);
    }
    handleLookupFieldChangeDist(event) {
        if (event.detail) {
            console.log('Event detail District ====> ', event.detail);
            this.billDist = event.detail.mainField;
        }
    }

    //@track spLabel;
    handleLookupFieldChange(event) {
        if (event.detail) {
            this.billDist = '';
            console.log('Event detail spLabel====> ', event.detail);
            let spId = event.detail.id;
            this.showBillDist = false;
            this.spLabel = event.detail.mainField;
            if (this.spLabel !== null) {
                if (this.spLabel == 'Others') {
                    this.consumerIdRequired = false;
                    this.showUpload = false;
                    this.isPanKyc = false;
                } else {
                    this.getSPCode(spId);
                    this.consumerIdRequired = true;
                    this.showUpload = true;
                    this.isPanKyc = true;
                }
            }
            console.log("spLabel>>>", this.spLabel);
        }
    }
    getSPCode(spId) {
        let paramsForApp = {
            ParentObjectName: 'MasterData__c',
            ChildObjectRelName: '',
            parentObjFields: ["Id", "Name", "SalesforceCode__c"],
            childObjFields: [],
            queryCriteria: ' where Id = \'' + spId + '\''
        }
        getAssetPropType({ params: paramsForApp })
            .then((res) => {
                if (res.parentRecords.length > 0) {
                    console.log('Selected SP Data is :: ', res.parentRecords);
                    this.spValue = res.parentRecords[0].SalesforceCode__c;
                    if (this.askForDistList.includes(this.spValue)) {
                        this.showBillDist = true;
                        //this.getSPCode(spId);
                        this.showUpload = true;
                    }
                }
            })
            .catch((err) => {
                console.log(" getSobjectDatawithRelatedRecords error fro getting getSPCode===", err);
            });
    }
    getAreaValues(type) {
        let paramsForApp = {
            ParentObjectName: 'MasterData__c',
            ChildObjectRelName: '',
            parentObjFields: ["Id", "Name", "SalesforceCode__c"],
            childObjFields: [],
            queryCriteria: ' where type__c = \'' + type + '\''
        }
        getAssetPropType({ params: paramsForApp })
            .then((res) => {
                if (res.parentRecords.length > 0) {
                    let options = [];
                    res.parentRecords.forEach(item => {
                        if (item.Name != 'Others') {
                            let step = {
                                label:
                                    item.Name,
                                value: item.SalesforceCode__c
                            };
                            //subStepsLocal.push(step);
                            options.push(step);
                        } else {
                            let step = {
                                label:
                                    item.Name,
                                value: item.Name
                            };
                            //subStepsLocal.push(step);
                            options.push(step);
                        }

                    })
                    if (type === 'Shop & Establishment Area Code') {
                        if (options && options.length > 0) {
                            this.shopEstAreCodeOptions = options;
                            this.showEstablishmentDate = true;
                            this.showUpload = false;
                        }
                        console.log('this.shopEstAreCodeOptions', this.shopEstAreCodeOptions);
                    }
                    else if (type === 'Electricity Service Provider') {
                        if (options && options.length > 0) {
                            this.spOptions = options;
                            this.showUtilityBillDate = true;
                            this.showElectricityBill = true;
                            this.showUpload = false;
                        }
                        console.log('this.shopEstAreCodeOptions', this.shopEstAreCodeOptions);
                    }

                }

            })
            .catch((err) => {
                this.showSpinner = false;
                this.showToast("Error", "error", err.message);
                console.log(" getSobjectDatawithRelatedRecords error fro getting area codes===", err);
            });
    }

    @track spValue;
    @track spLabel;
    @track spOptions;
    @track showElectricityBill = false;
    @track consumerIdRequired = false;
    @track consumerIdValue;
    @track billDist = '';
    @track showBillDist = false;
    @track askForDistList = ["JBVNL", "UPPCL"];
    handleInputChangeConsumerId(event) {
        this.consumerIdValue = event.target.value;
        if (this.consumerIdValue && this.consumerIdRequired && this.spValue != null) {
            this.isPanKyc = true;
            if (this.showBillDist && this.billDist != null) {
                this.showUpload = true;
            } else {
                this.showUpload = true;
            }
        }
    }

    handleSPChange(event) {
        this.spValue = event.target.value;
        this.showBillDist = false;
        if (this.askForDistList.includes(this.spValue)) {
            this.showBillDist = true;
        }
        if (this.spValue && this.spValue != 'Others') {
            this.consumerIdRequired = true;
            this.showUpload = false;
            this.isPanKyc = false;

        } else {
            this.consumerIdRequired = false;
            //this.showUpload = true;
            this.isPanKyc = true;
        }
        console.log('  electricity bill options ', this.spOptions, ' :: spValue is :', this.spValue, "  spLabel is  : ", this.spLabel);
    }
    handleInputChangeUtilityBillDate(event) {
        console.log('handleInputChangeUtilityBillDate : ', event.target.value);
        let dateVal = event.target.value;
        const selectedDateObj = new Date(dateVal);
        const minDateObj = new Date(this.utilityBillMinDate);
        const maxDateObj = new Date(this.todayDateValueForUB);

        selectedDateObj.setHours(0, 0, 0, 0);
        minDateObj.setHours(0, 0, 0, 0);
        maxDateObj.setHours(0, 0, 0, 0);

        if (selectedDateObj >= minDateObj && selectedDateObj <= maxDateObj) {
            // Date is within the allowed range, show success toast
            if (this.addDocEnabled) {
                this.showAddDoc = true;
            } else {
                this.showUpload = true;
                this.isPanKyc = true;
            }
            this.utilityBillDate = dateVal;
            if (this.retrigger == false) {
                let data = { enableUpload: true }
                this.callParent(data);
            } else {
                this.showValidateBtn = true;
            }

        } else {
            // Date is outside the allowed range, show error toast
            this.showAddDoc = false;
            this.showUpload = false;
            this.utilityBillDate = null;
            // let data = { disableUpload: true }
            // this.callParent(data);
            if (this.appKycId == null) {
                let data = { disableUpload: true }
                this.callParent(data);
            } else {
                this.showValidateBtn = false;
            }
        }

    }
    handleValidateClick(event) {
        let nm = event.target.name;
        if (nm = 'electricityBillVal') {
            if (this.utilityBillDate) {
                if (this.documentDetId) {

                    const docDetail = {};
                    docDetail[DocDet_ID.fieldApiName] = this.documentDetId;
                    docDetail[Utility_Bill_Date.fieldApiName] = this.utilityBillDate;
                    const recordInput = {
                        fields: docDetail
                    };
                    this.updateRecordMethod(recordInput, 'Utility Bill Date');
                }
                this.createIntMszForValidation();
            } else {
                console.log('cant update');
            }
        }


    }
    createIntMszForValidation() {


        const appKyc = {};

        appKyc[APP_KYC_ID.fieldApiName] = this.appKycId;
        appKyc[SVC_PROVIDER.fieldApiName] = this.spLabel;
        appKyc[SVC_PROVIDER_CODE.fieldApiName] = this.spValue;
        appKyc[CONSUMER_ID.fieldApiName] = this.consumerIdValue;
        appKyc[BILL_DIST.fieldApiName] = this.billDist;
        const recordInput = {
            fields: appKyc
        };

        this.updateRecordMethodNew(recordInput, 'Electricity Bill Authentication', this.appKycId, this.documentDetId);
        console.log('fromUploadDocsContainer after update');
    }
    updateRecordMethod(recordInput, msz) {
        updateRecord(recordInput)
            .then((record) => {
                if (msz === 'Utility Bill Date') {
                    // this.showUtilityBillDate = false;
                    // this.utilityBillDate = null;
                    // this.stopSpinner();
                }
            })
            .catch((err) => {
                console.log(" Error In " + msz + " update", err.body.message);
            })
    }
}