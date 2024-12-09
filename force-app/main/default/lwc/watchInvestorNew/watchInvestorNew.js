import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';

//Apex Methods
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getSobjectDataWithoutCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjDtwithFltrRelatedRecordsWithoutCache';

import { formattedDate,formattedDateTimeWithoutSeconds } from 'c/dateUtility';
import formFactorPropertyName from "@salesforce/client/formFactor";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
// Custom labels
import WatchInvestor_Save_SuccessMessage from '@salesforce/label/c.WatchInvestor_Save_SuccessMessage';
import DeDupVerf_ReqFields_ErrorMessage from '@salesforce/label/c.DeDupVerf_ReqFields_ErrorMessage';
export default class WatchInvestorNew extends LightningElement {
    customLabel = {
        DeDupVerf_ReqFields_ErrorMessage,
        WatchInvestor_Save_SuccessMessage

    }
    @api loanAppId = 'a08C4000007VLU0IAO';
    @api hasEditAccess;

    enableInfiniteScrolling = true;
    enableBatchLoading = true;
    @track formFactor = formFactorPropertyName;
    @track desktopBoolean = false;
    @track phoneBolean = false;
    @track activeSections = ["A", "B"];
    @track dedupeRecordTypeId;
    @track resultRelevanceOptions = [];
    @track showSpinner = false;
    @track isReadOnly = false;
    @track disableReintiate = false;
    @track saveData = [];
    @track columnsDataForTable = [
        {
            "label": "Applicant Name",
            "fieldName": "ApplNme__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Applicant Type",
            "fieldName": "ApplTyp__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Record ID",
            "fieldName": "RecId__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Regulator Competent Authority Name",
            "fieldName": "RegCompAuthName__c",
            "type": "text",
            "Editable": false   
        },
        {
            "label": "Date of Order",
            "fieldName": "OdrDt__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Defaulter Code",
            "fieldName": "DefCode__c",
            "type": "test",
            "Editable": false
        },
        {
            "label": "Defaulter Name",
            "fieldName": "DefName__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Defaulter Type Company Person",
            "fieldName": "DefTypCmpyPrsn__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Defaulter New Name1",
            "fieldName": "DefNewNme1__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Defaulter Old Name1",
            "fieldName": "DefOldNme1__c	",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Defaulter Merged With",
            "fieldName": "DefMrgWth__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "PAN CIN DIN",
            "fieldName": "PanCinDin__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Defaulter Other Details",
            "fieldName": "DefOthrDtls__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Not Defaulter Infact Associated Entity",
            "fieldName": "OthrEntAssosWthDefEnt__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Associated Entity Person",
            "fieldName": "AssocEntPrsn__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Regulatory Charges",
            "fieldName": "RegChngs__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Regulatory Actions",
            "fieldName": "RegActns__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Regulatory Action Source1",
            "fieldName": "RegActnSrc1__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Regulatory Action Source2",
            "fieldName": "RegActnsSrc2__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Regulatory Action Source3",
            "fieldName": "RegActnsSrc3__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Result Relevance",
            "fieldName": "Result_Relevance__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Internal Dedupe result remark",
            "fieldName": "IntDedRsltRmrks__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Created Date",
            "fieldName": "CreatedDate",
            "type": "Date/Time",
            "Editable": false
        },
        {
            "label": "API Verification Status",
            "fieldName": "IntegrationStatus__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "API Error Message",
            "fieldName": "IntegrationErrorMessage__c",
            "type": "text",
            "Editable": false
        }
    ];
    @track queryDataNoMatch = 'SELECT ApplNme__c,toLabel(ApplTyp__c),RecId__c,RegCompAuthName__c,OdrDt__c,DefCode__c,DefName__c,DefTypCmpyPrsn__c,DefNewNme1__c,DefOldNme1__c,DefMrgWth__c,PanCinDin__c,DefOthrDtls__c,OthrEntAssosWthDefEnt__c,AssocEntPrsn__c,RegChngs__c,RegActns__c,RegActnSrc1__c,RegActnsSrc2__c,RegActnsSrc3__c,Result_Relevance__c,IntDedRsltRmrks__c,CreatedDate,IntegrationStatus__c,IntegrationErrorMessage__c,Id FROM APIVer__c WHERE LoanAplcn__c =: loanAppId AND recordtype.name =: recordTypeName AND IsLatest__c =: isActiveValue AND WatchoutInvestor__c =: watchInvestorValue';
    @wire(getObjectInfo, { objectApiName: 'APIVer__c' })
    dedupeObjectInfo({ error, data }) {
        if (data) {
            console.log('DATA in RECORD TYPE ID', data);
            for (let key in data.recordTypeInfos) {
                let recordType = data.recordTypeInfos[key];
                console.log("recordType.value>>>>>", recordType.name);
                if (recordType.name === 'Watchout') {
                    this.dedupeRecordTypeId = key;
                }
                console.log('data.dedupeRecordTypeId', this.dedupeRecordTypeId);
            }
        } else if (error) {
            console.error('Error fetching record type Id', error);
        }
    }

    generatePicklist(data) {
        console.log('data in generatePicklist ', JSON.stringify(data));
        if (data.values) {
            return data.values.map(item => ({ label: item.label, value: item.value }))
        }
        return null;
    }
    loantobeClosedInternally = []
    @wire(getPicklistValuesByRecordType, {
        objectApiName: 'APIVer__c',
        recordTypeId: '$dedupeRecordTypeId',
    })
    dedupePicklistHandler({ data, error }) {
        if (data) {
            console.log('data in PicklistHandler', JSON.stringify(data));
            this.resultRelevanceOptions = [...this.generatePicklist(data.picklistFieldValues.Result_Relevance__c)]
            console.log('resultRelevanceOptions ', this.resultRelevanceOptions);
        }
        if (error) {
            console.error('error im getting picklist values are', error)
        }
    }


    connectedCallback() {
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
        let paramValNoMatch = [];
        paramValNoMatch.push({ key: 'loanAppId', value: this.loanAppId });
        paramValNoMatch.push({ key: 'recordTypeName', value: 'Watchout' });
        paramValNoMatch.push({ key: 'isActiveValue', value: true });
        paramValNoMatch.push({ key: 'watchInvestorValue', value: false });
        this.paramsNoMatch = {
            columnsData: this.columnsDataForTable,
            queryParams: paramValNoMatch,
            query: this.queryDataNoMatch
        }
        //  this.hasEditAccess = false;
        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }
        this.disableReintiate = this.isReadOnly;
        //this.isReadOnly = false;
        this.getWatchOutDetails();
        this.scribeToMessageChannel();
        this.getApiRetriggerTrackerData();
    }

    // applIds = new Set();
    @track applIds = [];
    @track apiRetrgrTrcrData = [];
    getApiRetriggerTrackerData() {
        let apiName = 'ScreeningWachout';
        console.log('loanappId in Reintiate component', this.loanAppId);
        let paramsLoanApp = {
            ParentObjectName: 'APIRetriggerTracker__c',
            parentObjFields: ['Id', 'App__c', 'LoanApp__c', 'IsProcessed__c', 'App__r.TabName__c', 'App__r.Id'],
            queryCriteria: ' where IsProcessed__c = false AND LoanApp__c = \'' + this.loanAppId + '\' AND APIName__c = \'' + apiName + '\''
        }

        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('apiRetrgrTrcrData is in first method', result);

                this.apiRetrgrTrcrData = [];
                if (result.parentRecords && result.parentRecords.length > 0) {
                    console.log('result.parentRecords', result.parentRecords.length);
                    result.parentRecords.forEach(item => {
                        if (item.App__c) {
                            this.apiRetrgrTrcrData.push(item.App__r.Id);
                        }
                        //this.apiRetrgrTrcrData.push(item.App__r.Id);
                        //this.applIds.add(item.App__r.Id);
                    })
                }
                // this.getAppWithCallOutData();
                this.getExpiApiData();
                console.log('disableReintiate ', this.disableReintiate);
                console.log('this.apiRetrgrTrcrData after', this.apiRetrgrTrcrData);
                if (result.error) {
                    console.error('apiRetrgrTrcrData result getting error=', result.error);
                }
            })
    }

    //START LAK-9108
    @track showHelp = false;
    showHelpText(event) {
        this.showHelp = true;
    }
    hideHelpText(event) {
        this.showHelp = false;
    }
    //END LAK-9108
    getExpiApiData() {
        let arra = ['Watchout'];
        let paramsLoanApp = {
            ParentObjectName: 'APIVer__c',
            parentObjFields: ['Id', 'LoanAplcn__c', 'IsLatest__c', 'ExpiryDate__c', 'Appl__c', 'Appl__r.FullName__c', 'Appl__r.Id'],
            queryCriteria: ' where IsLatest__c = true AND LoanAplcn__c = \'' + this.loanAppId + '\' AND recordType.Name IN (\'' + arra.join('\', \'') + '\')'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('expiry data is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    result.parentRecords.forEach(item => {
                        if (item.ExpiryDate__c) {
                            let expiryDate = new Date(result.parentRecords[0].ExpiryDate__c);
                            let today = new Date();
                            today.setHours(0, 0, 0, 0); // Set time to beginning of the day for comparison
                            // Removing time component from effectiveDate
                            expiryDate.setHours(0, 0, 0, 0);
                            if (expiryDate.getTime() < today.getTime()) {
                                if (item.Appl__c) {
                                    this.apiRetrgrTrcrData.push(item.Appl__r.Id);
                                }
                            }
                        }
                    })
                } else {
                    this.showSpinner = false;
                }
                this.getAppWithCallOutData();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('exp result getting error= ', error);
            });
    }

    getAppWithCallOutData() {
        let apiName = 'ScreeningWachout';
        let appTypes = ['P', 'C', 'G'];
        let paramsLoanApp = {
            ParentObjectName: 'Applicant__c',
            ChildObjectRelName: 'API_Callout_Trackers__r',
            parentObjFields: ['Id'],
            childObjFields: ['Id', 'LtstRespCode__c', 'APIName__c', 'Appl__r.Id', 'LAN__c'],
            queryCriteriaForChild: ' where LAN__c = \'' + this.loanAppId + '\' AND APIName__c = \'' + apiName + '\'',
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND ApplType__c  IN (\'' + appTypes.join('\', \'') + '\')'

        }
        getSobjectDataWithoutCacheable({ params: paramsLoanApp })
            .then((result) => {
                console.log('AppWithCallOutData is', JSON.stringify(result));
                if (result && result.length > 0) {
                    // this.apiRetrgrTrcrData = JSON.parse(JSON.stringify(result));
                    result.forEach(item => {
                        if (item.ChildReords && item.ChildReords.length > 0) {
                            item.ChildReords.forEach(ite => {
                                if (ite.LtstRespCode__c != 'Success') {
                                    if (ite.Appl__c) {
                                        this.apiRetrgrTrcrData.push(ite.Appl__r.Id);
                                        //this.applIds.add(item.Appl__r.Id);
                                    }
                                }
                            })
                        } else {
                            this.apiRetrgrTrcrData.push(item.parentRecord.Id);
                        }
                    })
                }
                this.apiRetrgrTrcrData = [...new Set(this.apiRetrgrTrcrData)];
                this.applIds = [...this.apiRetrgrTrcrData];
                if (this.applIds.length === 0) {
                    this.disableReintiate = true;
                }
                if (this.isReadOnly) {
                    this.disableReintiate = true;
                }
                console.log('this.apiRetrgrTrcrData after second method', this.apiRetrgrTrcrData);
                if (result.error) {
                    this.showSpinner = false;
                    console.error('apiRetrgrTrcrData result getting error=', result.error);
                }
            })
    }
    getCalloutData() {
        console.log('loanappId in Reintiate component', this.loanAppId);
        let apiName = 'ScreeningWachout';
        // let variab = 'Success';
        let paramsLoanApp = {
            ParentObjectName: 'APICoutTrckr__c',
            parentObjFields: ['Id', 'LtstRespCode__c', 'Appl__c', 'Appl__r.Id', 'LAN__c'],
            queryCriteria: ' where LAN__c = \'' + this.loanAppId + '\' AND APIName__c = \'' + apiName + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('apiRetrgrTrcrData is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    // this.apiRetrgrTrcrData = JSON.parse(JSON.stringify(result));
                    result.parentRecords.forEach(item => {
                        if (item.LtstRespCode__c != 'Success') {
                            if (item.Appl__c) {
                                this.apiRetrgrTrcrData.push(item.Appl__r.Id);
                                //this.applIds.add(item.Appl__r.Id);
                            }
                        }
                    })
                }
                this.apiRetrgrTrcrData = [...new Set(this.apiRetrgrTrcrData)];
                this.applIds = [...this.apiRetrgrTrcrData];
                if (this.applIds.length === 0) {
                    this.disableReintiate = true;
                }
                if (this.isReadOnly) {
                    this.disableReintiate = true;
                }
                console.log('this.apiRetrgrTrcrData after second method', this.apiRetrgrTrcrData);
                if (result.error) {
                    console.error('apiRetrgrTrcrData result getting error=', result.error);
                }
            })
    }

    getWatchOutDetails() {
        this.showSpinner = true;
        let recordTypeName = 'Watchout';
        let params = {
            ParentObjectName: 'APIVer__c',
            parentObjFields: ['ApplNme__c', 'toLabel(ApplTyp__c)', 'IntegrationStatus__c', 'IntegrationErrorMessage__c', 'RecId__c', 'RegCompAuthName__c', 'OdrDt__c', 'DefCode__c', 'DefName__c', 'DefTypCmpyPrsn__c', 'DefNewNme1__c', 'DefOldNme1__c', 'DefMrgWth__c', 'PanCinDin__c', 'DefOthrDtls__c', 'OthrEntAssosWthDefEnt__c', 'AssocEntPrsn__c', 'RegChngs__c', 'RegActns__c', 'RegActnSrc1__c', 'RegActnsSrc2__c', 'RegActnsSrc3__c', 'Result_Relevance__c', 'IntDedRsltRmrks__c', 'CreatedDate', 'Id'],
            queryCriteria: ' where LoanAplcn__c = \'' + this.loanAppId + '\' AND recordtype.name = \'' + recordTypeName + '\' AND IsLatest__c = true AND WatchoutInvestor__c = true'
        }
        // WHERE LoanAplcn__c =: loanAppId AND recordtype.name =: recordTypeName AND IsLatest__c =: isActiveValue AND WatchoutInvestor__c =: watchInvestorValue
        getSobjectData({ params: params })
            .then((result) => {
                console.log('WatchOut Data is ', result);
                if (result && result.parentRecords && result.parentRecords.length) {
                    this.watchOutData = result.parentRecords;
                        this.watchOutData = result.parentRecords.map(record => {
                            let modifiedRecord = { ...record };       
                            if (modifiedRecord && modifiedRecord.OdrDt__c) {
                                const formattedDate1 = formattedDate(modifiedRecord.OdrDt__c); 
                                const orderDate = `${formattedDate1}`;
                                modifiedRecord.OdrDt__c =  orderDate;
                            }
                            if (modifiedRecord && modifiedRecord.CreatedDate) {
                                const formattedDate2 = formattedDateTimeWithoutSeconds(modifiedRecord.CreatedDate); 
                                const createdDate2 = `${formattedDate2}`;
                                modifiedRecord.CreatedDate = createdDate2;
                            }
    
                            return modifiedRecord; // Return the modified record
                        });
                    
                }
                this.makeFieldsRequired();
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting  Watchout  Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }


    @track isWatch = false;
    makeFieldsRequired() {
        this.isWatch = false
        if (this.watchOutData) {
            let tempArr = JSON.parse(JSON.stringify(this.watchOutData));
            this.watchOutData = [];
            tempArr.forEach(item => {
                if (item.Result_Relevance__c == 'Accurate Match found') {
                    item.isRequired = true;
                } else {
                    item.isRequired = false;
                }
            })
            this.watchOutData = tempArr;
            // this.isWatch = true;
            tempArr = [];
            console.log('this.watchOutData ', JSON.stringify(this.watchOutData));
        }
        this.isWatch = true;
    }
    handleChange(event) {
        let val = event.target.value;
        let watchOutRecordId = event.target.dataset.recordid;
        let nameVal = event.target.name;
        console.log('val is ', val, 'watchOutRecordId is ', watchOutRecordId, ' name is ', nameVal);
        let obj = this.watchOutData.find(item => item.Id === watchOutRecordId);
        if (obj) {
            console.log('obj is ', JSON.stringify(obj));
            obj[nameVal] = val.toUpperCase();
            obj['isChanged'] = true;
            //this.callEnpaMethod();
        }
    }
    // handleChange(event) {
    //     let val = event.target.value;
    //     let watchOutRecordId = event.target.dataset.recordid;
    //     let nameVal = event.target.name;
    //     console.log('val is ', val, 'deduperRecordId is ', watchOutRecordId, ' name is ', nameVal);
    //     let obj = this.saveData.find(item => item.Id === watchOutRecordId);
    //     if (obj) {
    //         console.log('obj is ', JSON.stringify(obj));
    //         obj[nameVal] = event.target.value.toUpperCase();
    //     } else {
    //         let objNew = {};
    //         objNew.Id = watchOutRecordId;
    //         objNew.nameVal = event.target.value.toUpperCase();
    //         objNew.isChanged = true;
    //         this.saveData.push(objNew);
    //     }

    //     let objj = this.watchOutData.find(item => item.Id === watchOutRecordId);
    //     if (objj) {
    //         console.log('obj is ', JSON.stringify(obj));
    //         objj[nameVal] = event.target.value.toUpperCase();
    //     }
    //     console.log('this.savedata  ', this.saveData);
    // }
    handlePicklistValues(event) {
        let val = event.detail.val;
        let watchOutRecordId = event.detail.recordid;
        let nameVal = event.detail.nameVal;
        console.log('val is in watchOutinvestor ', val, 'watchOutRecordId is ', watchOutRecordId, ' name is ', nameVal);
        let obj = this.watchOutData.find(item => item.Id === watchOutRecordId);
        if (obj) {
            console.log('obj is ', JSON.stringify(obj));
            obj[nameVal] = val;
            obj['isChanged'] = true;
            // if (nameVal == 'Result_Relevance__c' && val == 'Accurate Match found') {
            //     obj.isRequired = true;
            // } else {
            //     obj.isRequired = false;
            // }
            // obj.isRequired = true;
            console.log('this.watchOutRecordId ', JSON.stringify(this.watchOutData));
        }
        this.makeFieldsRequired();
    }

    // handlePicklistValues(event) {
    //     let val = event.detail.val;
    //     let watchOutRecordId = event.detail.recordid;
    //     let nameVal = event.detail.nameVal;
    //     console.log('val is in watchOutData ', val, 'watchOutData is ', watchOutRecordId, ' name is ', nameVal);
    //     let obj = this.saveData.find(item => item.Id === watchOutRecordId);
    //     if (obj) {
    //         console.log('obj is ', JSON.stringify(obj));
    //         obj[nameVal] = val;
    //     } else {
    //         let objNew = {};
    //         objNew.Id = watchOutRecordId;
    //         objNew[nameVal] = val;
    //         objNew.isChanged = true;
    //         this.saveData.push(objNew);
    //     }
    //     let objj = this.watchOutData.find(item => item.Id === watchOutRecordId);
    //     if (objj) {
    //         console.log('obj is ', JSON.stringify(obj));
    //         objj[nameVal] = event.target.value;
    //         if (nameVal == 'Result_Relevance__c' && val == 'Accurate Match found') {
    //             objj.isRequired = true;
    //         }
    //     }
    //     // this.makeFieldsRequired();
    //     console.log('this.savedata  ', this.saveData);
    //     // this.makeFieldsRequired();
    // }


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
        this.makeFieldsRequired();
        console.log('values to save through Lms ', JSON.stringify(values));
        this.handleSave(values.validateBeforeSave);
    }

    handleSave(validate) {
        console.log('valid ', validate);
        console.log('watchOutData ', this.watchOutData);
        if (validate) {
            let valid = this.checkReportValidity();
            console.log('valid ', valid);
            if (valid) {
                this.handlevSubmit();
            }
            else {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: this.customLabel.DeDupVerf_ReqFields_ErrorMessage,
                    mode: 'sticky'

                });
                this.dispatchEvent(evt);
            }
        } else {
            this.handlevSubmit();
        }
    }
    checkReportValidity() {
        let isValid = true
        this.template.querySelectorAll('lightning-textarea').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed lightning-textarea');
                console.log('element if--', element.value);
            } else {
                isValid = false;
            }
        });
        return isValid;
    }
    handlevSubmit(validate) {
        this.showSpinner = true;
        console.log('valid ', validate);
        
        if(this.watchOutData && this.watchOutData.length > 0){
            let filterdData = this.watchOutData.filter(item => item.isChanged === true);

            if (filterdData && filterdData.length > 0) {
                filterdData.forEach(item => {
                    delete item.ApplTyp__c;
                    delete item.CreatedDate; //LAK-9109
                    delete item.OdrDt__c ;//LAK-9109
                })
            }
            if (filterdData && filterdData.length > 0) {
                console.log('filterdData is =========>', JSON.stringify(filterdData));
                upsertMultipleRecord({ params: filterdData })
                    .then((result) => {
                        console.log('Result after creating Int Msgs is ', JSON.stringify(result));
                        this.showSpinner = false;
                        const evt = new ShowToastEvent({
                            title: 'Success',
                            variant: 'success',
                            message: this.customLabel.WatchInvestor_Save_SuccessMessage,
                            mode: 'sticky'
        
                        });
                        this.dispatchEvent(evt);
                        this.getWatchOutDetails();
                        filterdData = [];
        
                    })
                    .catch((error) => {
                        this.showSpinner = false;
                        console.log('Error In creating Record', error);
                        // this.fireCustomEvent("Error", "error", "Error occured in accepting File  " + error, false);
                    });
            }else{
                //LAK-9109
                this.showSpinner = false;
                const evt = new ShowToastEvent({
                    title: 'Info',
                    variant: 'info',
                    message: 'Data is not modified',
                    mode: 'sticky'
    
                });
                this.dispatchEvent(evt);
            }
        }else{
             //LAK-9109
             this.showSpinner = false;
             const evt = new ShowToastEvent({
                 title: 'Info',
                 variant: 'info',
                 message: 'Data is not modified',
                 mode: 'sticky'
 
             });
             this.dispatchEvent(evt);
        }
       
       
    }


    @track isModalOpen = false;
    handleIntialization() {
        this.isModalOpen = true;

    }

    handleCustomEvent(event) {
        this.isModalOpen = false;
        let spinnerValue = event.detail.spinner;
        if (spinnerValue) {
            this.showSpinner = true;
        } else {
            this.showSpinner = false;
        }
        let titleVal = event.detail.title;
        let variantVal = event.detail.variant;
        let messageVal = event.detail.message;
        console.log('val from return is', titleVal, 'variantVal', variantVal, 'messageVal', messageVal);
        if (titleVal && variantVal && messageVal) {
            this.handleRefreshClick();

            const evt = new ShowToastEvent({
                title: titleVal,
                variant: variantVal,
                message: messageVal
            });
            this.dispatchEvent(evt);

        }
    }


    handleRefreshClick() {
        // const childComponent = this.template.querySelector('[data-id="childComponent"]');
        // if (childComponent) {
        //     console.log('before');
        //     childComponent.handleGettingData();
        //     console.log('after');
        // }
        this.showSpinner = true;
        // const childComponent = this.template.querySelector('[data-id="childComponentOne"]');
        // if (childComponent) {
        // console.log('before');
        // childComponent.handleGettingData();
        // console.log('after');
        this.getWatchOutDetails();
        this.getApiRetriggerTrackerData();
        const childComponentTwo = this.template.querySelector('[data-id="childComponentTwo"]');
        if (childComponentTwo) {
            console.log('before');
            childComponentTwo.handleGettingData();
            console.log('after');
        }
        //this.showSpinner = false;
        setTimeout(() => {
            this.showSpinner = false;
        }, 6000);
        // }

    }


    //******************FOR HANDLING THE HORIZONTAL SCROLL OF TABLE MANUALLY******************//
    tableOuterDivScrolled(event) {
        this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
        if (this._tableViewInnerDiv) {
            if (!this._tableViewInnerDivOffsetWidth || this._tableViewInnerDivOffsetWidth === 0) {
                this._tableViewInnerDivOffsetWidth = this._tableViewInnerDiv.offsetWidth;
            }
            this._tableViewInnerDiv.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth) + "px;" + this.tableBodyStyle;
        }
        this.tableScrolled(event);
    }

    tableScrolled(event) {
        if (this.enableInfiniteScrolling) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('showmorerecords', {
                    bubbles: true
                }));
            }
        }
        if (this.enableBatchLoading) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('shownextbatch', {
                    bubbles: true
                }));
            }
        }
    }

    //******************************* RESIZABLE COLUMNS *************************************//
    handlemouseup(e) {
        this._tableThColumn = undefined;
        this._tableThInnerDiv = undefined;
        this._pageX = undefined;
        this._tableThWidth = undefined;
    }

    handlemousedown(e) {
        if (!this._initWidths) {
            this._initWidths = [];
            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            tableThs.forEach(th => {
                this._initWidths.push(th.style.width);
            });
        }

        this._tableThColumn = e.target.parentElement;
        this._tableThInnerDiv = e.target.parentElement;
        while (this._tableThColumn.tagName !== "TH") {
            this._tableThColumn = this._tableThColumn.parentNode;
        }
        while (!this._tableThInnerDiv.className.includes("slds-cell-fixed")) {
            this._tableThInnerDiv = this._tableThInnerDiv.parentNode;
        }
        console.log("handlemousedown._tableThColumn.tagName => ", this._tableThColumn.tagName);
        this._pageX = e.pageX;

        this._padding = this.paddingDiff(this._tableThColumn);

        this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
        console.log("handlemousedown._tableThColumn.tagName => ", this._tableThColumn.tagName);
    }

    handlemousemove(e) {
        console.log("mousemove._tableThColumn => ", this._tableThColumn);
        if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
            this._diffX = e.pageX - this._pageX;

            this.template.querySelector("table").style.width = (this.template.querySelector("table") - (this._diffX)) + 'px';

            this._tableThColumn.style.width = (this._tableThWidth + this._diffX) + 'px';
            this._tableThInnerDiv.style.width = this._tableThColumn.style.width;

            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            let tableBodyRows = this.template.querySelectorAll("table tbody tr");
            let tableBodyTds = this.template.querySelectorAll("table tbody .dv-dynamic-width");
            tableBodyRows.forEach(row => {
                let rowTds = row.querySelectorAll(".dv-dynamic-width");
                rowTds.forEach((td, ind) => {
                    rowTds[ind].style.width = tableThs[ind].style.width;
                });
            });
        }
    }

    handledblclickresizable() {
        let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
        let tableBodyRows = this.template.querySelectorAll("table tbody tr");
        tableThs.forEach((th, ind) => {
            th.style.width = this._initWidths[ind];
            th.querySelector(".slds-cell-fixed").style.width = this._initWidths[ind];
        });
        tableBodyRows.forEach(row => {
            let rowTds = row.querySelectorAll(".dv-dynamic-width");
            rowTds.forEach((td, ind) => {
                rowTds[ind].style.width = this._initWidths[ind];
            });
        });
    }

    paddingDiff(col) {

        if (this.getStyleVal(col, 'box-sizing') === 'border-box') {
            return 0;
        }

        this._padLeft = this.getStyleVal(col, 'padding-left');
        this._padRight = this.getStyleVal(col, 'padding-right');
        return (parseInt(this._padLeft, 10) + parseInt(this._padRight, 10));

    }

    getStyleVal(elm, css) {
        return (window.getComputedStyle(elm, null).getPropertyValue(css))
    }
}