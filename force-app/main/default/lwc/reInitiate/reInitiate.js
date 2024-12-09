import { LightningElement, api, track, wire } from 'lwc';

import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, MessageContext } from 'lightning/messageService';

import getSessionId from '@salesforce/apex/SessionUtil.getSessionId';
import { loadScript } from "lightning/platformResourceLoader";
import cometdlwc from "@salesforce/resourceUrl/cometd";

import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';

export default class ReInitiate extends LightningElement {

    @api channelName = "/event/RetriggerUpsertCreated__e";

    @api loanAppId;
    @api serviceName;
    @api isTrackwizz = false;
    @api isWatchout = false;
    @api isHunter = false;
    @api isBureau = false;
    @api isDedupe = false;
    @api isEnpa = false;
    @api isLitigation = false;
    @api isQuiclificatiocheck = false;
    @api displayData = [];

    @track appRecordsData = [];
    @track appData;
    @track showModal = false;
    @track selectedRecords = [];
    @track intRecords = [];
    @track showSpinner = false;
    @track intMsgIds = [];
    @track apiRetrgrTrcrData = [];
    @track apiRetrgrTrcrDataAppIds = [];
    @track sessionId;

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
    connectedCallback() {
        // this.isTrackwizz = true;
        this.apiRetrgrTrcrDataAppIds = JSON.parse(JSON.stringify(this.displayData))
        console.log('serviceName ', this.serviceName, 'loanAppId ', this.loanAppId, 'isTrackwizz ', this.isTrackwizz);
        this.showModal = true;
        console.log('apiRetrgrTrcrDataAppIds is ', this.apiRetrgrTrcrDataAppIds);
        this.getLoanApplicationData();
        if (this.apiRetrgrTrcrDataAppIds && this.apiRetrgrTrcrDataAppIds.length > 0) {
            this.getAppKycData();
        }
        // this.getApplicationData();
        // this.getApiRetriggerTrackerData();
        //this.callSubscribePlatformEve();
    }

    getLoanApplicationData() {
        console.log('loanappId in Reintiate component', this.loanAppId);
        let appType = ['P','C','G']; //LAK-10349
        if (this.apiRetrgrTrcrDataAppIds && this.apiRetrgrTrcrDataAppIds.length > 0) {
            let paramsLoanApp = {
                ParentObjectName: 'Applicant__c',
                parentObjFields: ['Id', 'Name', 'Gender__c', 'MobNumber__c', 'TabName__c', 'CustProfile__c', 'PAN__c', 'LoanAppln__c', 'LoanAppln__r.ReqLoanAmt__c', 'LoanAppln__r.Product__c', 'Constitution__c'],
                // queryCriteria: ' where ApplType__c != null AND LoanAppln__c = \'' + this.loanAppId + '\''
                queryCriteria: ` where Id IN ('${this.apiRetrgrTrcrDataAppIds.join("','")}') AND ApplType__c IN ('${appType.join("','")}') AND LoanAppln__c = '${this.loanAppId}' AND ApplType__c != null`
            }
            getSobjectData({ params: paramsLoanApp })
                .then((result) => {
                    this.appData = result;
                    console.log('result is', JSON.stringify(result));
                    if (result.parentRecords && result.parentRecords.length > 0) {
                        // this.apiRetrgrTrcrData = result.parentRecords;
                        result.parentRecords.forEach(item => {
                            item['selectCheckbox'] = false;
                            item['RationalRemarks'] = '';
                            this.apiRetrgrTrcrData.push(item);
                        })
                        console.log('this.apiRetrgrTrcrData after', JSON.stringify(this.apiRetrgrTrcrData));
                    }
                    if (result.error) {
                        console.error('appl result getting error=', result.error);
                    }
                })
        }
    }

    @track totalApplicants = [];
    @track appIdsForAppKyc = [];
    getApplicationData() {
        console.log('loanappId in Reintiate component', this.loanAppId);
        let paramsLoanApp = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'Name', 'Gender__c', 'MobNumber__c', 'TabName__c', 'CustProfile__c', 'PAN__c', 'LoanAppln__c', 'LoanAppln__r.ReqLoanAmt__c', 'LoanAppln__r.Product__c', 'Constitution__c'],
            // queryCriteria: ' where ApplType__c != null AND LoanAppln__c = \'' + this.loanAppId + '\''
            queryCriteria: ` where LoanAppln__c = '${this.loanAppId}' AND ApplType__c != null`
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('result is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    result.parentRecords.forEach(item => {
                        this.totalApplicants.push(item);
                        this.appIdsForAppKyc.push(item.Id);
                    })
                    console.log('total applicants against loan application data ', this.totalApplicants);
                    // if (this.appIdsForAppKyc && this.appIdsForAppKyc.length > 0) {
                    //     this.getAppKycData();
                    // }
                }
                if (result.error) {
                    console.error('appl result getting error=', result.error);
                }
            })
    }
    @track appKycData = [];
    getAppKycData() {
        this.showSpinner = true;
        let params = {
            ParentObjectName: 'ApplKyc__c',
            parentObjFields: ['Id', 'Applicant__c', 'Applicant__r.Id', 'kycDoc__c', 'Pan__c', 'Name__c', 'VotIdEpicNo__c', 'PassNo__c', 'DLNo__c', 'AadharNo__c'],
            queryCriteria: ' Where Applicant__c  IN (\'' + this.apiRetrgrTrcrDataAppIds.join('\', \'') + '\') AND kycDoc__c !=null'
        }
        getSobjectData({ params: params })
            .then((result) => {
                // this.showSpinner = true;
                console.log('Appl Kyc Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.appKycData = result.parentRecords;
                    console.log('Appl Kyc Data again is', this.appKycData);
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Loan Application Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    // getApiRetriggerTrackerData() {
    //     console.log('loanappId in Reintiate component', this.loanAppId);
    //     let paramsLoanApp = {
    //         ParentObjectName: 'APIRetriggerTracker__c',
    //         parentObjFields: ['Id', 'App__c', 'LoanApp__c', 'IsProcessed__c', 'App__r.TabName__c', 'App__r.Id'],
    //         queryCriteria: ' where IsProcessed__c = false AND LoanApp__c = \'' + this.loanAppId + '\''
    //     }

    //     getSobjectData({ params: paramsLoanApp })
    //         .then((result) => {

    //             console.log('apiRetrgrTrcrData is', JSON.stringify(result));
    //             // if (result.parentRecords && result.parentRecords.length > 0) {
    //             //     result.parentRecords.forEach(item => {
    //             //         this.apiRetrgrTrcrDataAppIds.push(item.App__c);
    //             //     })
    //             //     this.apiRetrgrTrcrDataAppIds = [...new Set(this.apiRetrgrTrcrDataAppIds)];
    //             //     console.log('this.apiRetrgrTrcrDataAppIds after', this.apiRetrgrTrcrDataAppIds);
    //             // }
    //             // if (this.apiRetrgrTrcrDataAppIds && this.apiRetrgrTrcrDataAppIds.length > 0) {
    //             //     this.getLoanApplicationData();
    //             // }
    //             this.apiRetrgrTrcrData = [];
    //             if (result.parentRecords && result.parentRecords.length > 0) {
    //                 // this.apiRetrgrTrcrData = JSON.parse(JSON.stringify(result));
    //                 result.parentRecords.forEach(item => {
    //                     item['selectCheckbox'] = false;
    //                     item['RationalRemarks'] = '';
    //                     this.apiRetrgrTrcrData.push(item);
    //                 })
    //             } else {
    //                 const selectEvent = new CustomEvent('fireeventtodisable', {
    //                     detail: { value: true }
    //                 });
    //                 // Fire the custom event
    //                 this.dispatchEvent(selectEvent);
    //             }
    //             console.log('this.apiRetrgrTrcrData after', this.apiRetrgrTrcrData);
    //             if (result.error) {
    //                 console.error('apiRetrgrTrcrData result getting error=', result.error);
    //             }
    //         })
    // }


    closeModal() {
        this.showModal = false;
        //this.showSpinner = true;
        // this.spinnerEvent(null);
        this.fireCustomEvent(null, null, null, null);
    }



    handleClick(event) {
        console.log('record ', event.target.dataset.recordid);
        let selectedRecordId = event.target.dataset.recordid;
        console.log('value is', event.target.checked);
        console.log('All selected Records before ', this.apiRetrgrTrcrData);
        let val = event.target.checked;
        let recordData = {};
        let searchDoc = this.apiRetrgrTrcrData.find((doc) => doc.Id == selectedRecordId);
        if (searchDoc) {
            console.log('searchDoc', searchDoc);
            //searchDoc = { ...searchDoc, selectCheckbox: val }
            searchDoc['selectCheckbox'] = val;
        }
        else {
            recordData['Id'] = selectedRecordId;
            recordData['selectCheckbox'] = val;
            this.apiRetrgrTrcrData.push(recordData);
        }
        console.log('All selected Records', this.apiRetrgrTrcrData);
    }

    handleRationalChange(event) {
        console.log('record ', event.target.dataset.recordid);
        let selectedRecordId = event.target.dataset.recordid;
        console.log('value is', event.target.value);
        let val = event.target.value;
        let recordData = {};
        let searchDoc = this.apiRetrgrTrcrData.find((doc) => doc.Id == selectedRecordId);
        if (searchDoc) {
            console.log('searchDoc', searchDoc);
            searchDoc['RationalRemarks'] = val;
        }
        else {
            recordData['Id'] = selectedRecordId;
            recordData['RationalRemarks'] = val;
            this.selectedRecords.push(recordData);
        }
        console.log('All selected Records', JSON.stringify(this.apiRetrgrTrcrData));
    }
    handleReIntialization() {
        this.fireCustomEvent(null, null, null, true);
        console.log('handle reintialization called');
        let filteredData = this.apiRetrgrTrcrData.filter(item => item.selectCheckbox === true);
        console.log('All filteredData Records', JSON.stringify(filteredData));
        console.log('this.apiRetrgrTrcrData length is ', this.apiRetrgrTrcrData.length);
        console.log('this.filteredData length is ', filteredData.length);
        console.log('isHunter value is ', this.isHunter);
        console.log('isHunter value is ', this.isDedupe);
        if (filteredData.length > 0) {
            this.createIntegrationMsg(filteredData);
        } else {
            this.fireCustomEvent("Error", "error", "Please Select Applicant to Re-Initiate", false);
        }
    }
    createIntegrationMsg(appIds) {
        
        if (this.isTrackwizz) {
            this.createIntMsgForTrackwizz(appIds);
        }
        if (this.isWatchout) {
            this.createIntMsgForWatchOut(appIds);
        }
        if (this.isHunter) {
            this.createIntMsgForHunter(appIds);
        }
        if (this.isBureau) {
            this.createIntMsgForBureau(appIds);
        }
        if (this.isDedupe) {
            this.createIntMsgForDedupe(appIds);
        }
        if (this.isEnpa) {
            this.createIntMsgForEnpa(appIds);
        }
        if (this.isLitigation) {
            
            this.createIntMsgForLitigation(appIds);
        }
        if(this.isQuiclificatiocheck){
            this.createIntMsgForQul(appIds);
        }
    }
    createIntMsgForQul(appIds){
        appIds.forEach(item => {
            let fields = {};
            fields['sobjectType'] = 'IntgMsg__c';
            fields['Name'] = this.serviceName; 
            fields['BU__c'] = 'HL / STL';
            fields['IsActive__c'] = true;
            fields['Svc__c'] = this.serviceName; 
            fields['ExecType__c'] = 'Async';
            fields['Status__c'] = 'New';
            fields['Mresp__c'] = 'Blank';
            fields['Outbound__c'] = true;
            fields['Trigger_Platform_Event__c'] = false;
            fields['RefObj__c'] = 'Applicant__c';
            fields['RefId__c'] = item.Id;
            fields['ParentRefObj__c'] = "LoanAppl__c";
            fields['ParentRefId__c'] = this.loanAppId;
            fields['RetriRatinal__c'] = item.RationalRemarks ? item.RationalRemarks : '';
            this.intRecords.push(fields);
        })
        console.log(JSON.stringify(this.intRecords));
        this.upsertIntRecord(this.intRecords);
    }

    createIntMsgForEnpa(appIds) {
        appIds.forEach(item => {
            let fields = {};
            fields['sobjectType'] = 'IntgMsg__c';
            fields['Name'] = this.serviceName; //serviceName;//'KYC OCR'
            fields['BU__c'] = 'HL / STL';
            fields['IsActive__c'] = true;
            fields['Svc__c'] = this.serviceName; //serviceName;
            fields['ExecType__c'] = 'Async';
            fields['Status__c'] = 'New';
            fields['Mresp__c'] = 'Blank';
            fields['Outbound__c'] = true;
            fields['Trigger_Platform_Event__c'] = false;
            fields['RefObj__c'] = 'Applicant__c';
            fields['RefId__c'] = item.Id;
            fields['ParentRefObj__c'] = "LoanAppl__c";
            fields['ParentRefId__c'] = this.loanAppId;
            fields['RetriRatinal__c'] = item.RationalRemarks;
            this.intRecords.push(fields);
        })
        console.log(JSON.stringify(this.intRecords));
        this.upsertIntRecord(this.intRecords);
    }
    createIntMsgForDedupe(filteredData) {
        console.log('filteredData in Dedupe is ', JSON.stringify(filteredData));
        let fields = {};
        fields['sobjectType'] = 'IntgMsg__c';
        fields['Name'] = 'Dedupe API Token'; //serviceName;//'KYC OCR'v 
        fields['BU__c'] = 'HL / STL';
        fields['IsActive__c'] = true;
        fields['Svc__c'] = 'Dedupe API Token'; //serviceName;
        fields['ExecType__c'] = 'Async';
        fields['Status__c'] = 'New';
        fields['Mresp__c'] = 'Blank';
        fields['Outbound__c'] = true;
        fields['Trigger_Platform_Event__c'] = false;
        fields['ParentRefObj__c'] = "LoanAppl__c";
        fields['ParentRefId__c'] = this.loanAppId;
        if (this.totalApplicants.length === filteredData.length) {
            fields['RefObj__c'] = 'LoanAppl__c';
            fields['RefId__c'] = this.loanAppId;
            let array2 = [];
            filteredData.forEach(item => {
                array2.push(item.RationalRemarks);
            })
            console.log('array2 is ', JSON.stringify(array2));
            let rationalRem = array2.join(",");
            fields['RetriRatinal__c'] = rationalRem;

        } else {
            fields['RefObj__c'] = 'Applicant__c';
            let array = [];
            let array2 = [];
            filteredData.forEach(item => {
                array.push(item.Id);
                array2.push(item.RationalRemarks);

            })
            console.log('array is ', JSON.stringify(array));
            let refIds = array.join(",");
            let rationalRem = array2.join(",");
            fields['RefId__c'] = refIds;
            fields['RetriRatinal__c'] = rationalRem;

        }
        this.intRecords.push(fields);
        console.log(JSON.stringify(this.intRecords));
        this.upsertIntRecord(this.intRecords);
    }

    createIntMsgForLitigation(filteredData){
        console.log('filteredData in Bureau is ', JSON.stringify(filteredData));
        let initRecos=[];
        filteredData.forEach(item => {
            let fieldsWo = {};
            fieldsWo['sobjectType'] = 'IntgMsg__c';
            fieldsWo['Name'] =  item.Constitution__c == 'INDIVIDUAL' || item.Constitution__c == 'PROPERITORSHIP' ? 'Crime Add Report API - Individual': 'Crime Add Report API - Company'; //serviceName;//'KYC OCR'
            fieldsWo['BU__c'] = 'HL / STL';
            fieldsWo['IsActive__c'] = true;
            fieldsWo['Svc__c'] = item.Constitution__c == 'INDIVIDUAL' || item.Constitution__c == 'PROPERITORSHIP' ? 'Crime Add Report API - Individual': 'Crime Add Report API - Company';
            fieldsWo['RefObj__c'] = 'Applicant__c';
            fieldsWo['RefId__c'] = item.Id;
            fieldsWo['Status__c'] = 'New';
            fieldsWo['ApiVendor__c'] = 'CrimeCheck';
            fieldsWo['TriggerType__c'] = 'System';
            initRecos.push(fieldsWo);
                
        })
        this.intRecords=initRecos
        if (this.intRecords.length > 0) {
            console.log('intRecords records are ', JSON.stringify(this.intRecords));
            this.upsertIntRecord(this.intRecords);
        }
    }


    createIntMsgForBureau(filteredData) {
        console.log('filteredData in Bureau is ', JSON.stringify(filteredData));
        filteredData.forEach(item => {
            if (item.Constitution__c === 'INDIVIDUAL') {
                if (item.LoanAppln__r.ReqLoanAmt__c && item.LoanAppln__r.Product__c) {
                    if (item.Gender__c && item.MobNumber__c) {
                        let appKycArr = this.appKycData.filter(itemm => itemm.Applicant__r.Id == item.Id);
                        let count = 0;
                        if (appKycArr && appKycArr.length > 0) {
                            appKycArr.forEach(applkyc => {
                                if (applkyc.kycDoc__c == 'Pan' && applkyc.Pan__c && applkyc.Pan__c != '') {
                                    count++;
                                } else if (applkyc.kycDoc__c == 'Passport' && applkyc.PassNo__c && applkyc.PassNo__c != '') {
                                    count++;
                                }
                                else if (applkyc.kycDoc__c == 'Voter Id' && applkyc.VotIdEpicNo__c && applkyc.VotIdEpicNo__c != '') {
                                    count++;
                                }
                                else if (applkyc.kycDoc__c == 'Driving License' && applkyc.DLNo__c && applkyc.DLNo__c != '') {
                                    count++;
                                }
                                else if (applkyc.kycDoc__c == 'Aadhaar' && applkyc.AadharNo__c && applkyc.AadharNo__c != '') {
                                    count++;
                                }
                            })

                            if (count > 0) {
                                let fields = {};
                                fields['sobjectType'] = 'IntgMsg__c';
                                fields['Name'] = 'Consumer ACK Request'; //serviceName;//'KYC OCR'
                                fields['BU__c'] = 'HL / STL';
                                fields['IsActive__c'] = true;
                                fields['Svc__c'] = 'Consumer ACK Request'; //serviceName;
                                fields['ExecType__c'] = 'Async';
                                fields['Status__c'] = 'New';
                                fields['Mresp__c'] = 'Blank';
                                // fields['Outbound__c'] = true;
                                fields['Trigger_Platform_Event__c'] = false;
                                fields['RefObj__c'] = 'Applicant__c';
                                fields['RefId__c'] = item.Id;
                                fields['ParentRefObj__c'] = "LoanAppl__c";
                                fields['ParentRefId__c'] = this.loanAppId;
                                fields['TriggerType__c'] = 'Manual';
                                let array2 = [];
                                filteredData.forEach(item => {
                                    array2.push(item.RationalRemarks);
                                })
                                console.log('array2 is ', JSON.stringify(array2));
                                let rationalRem = array2.join(",");
                                fields['RetriRatinal__c'] = rationalRem;
                                this.intRecords.push(fields);
                            }
                            else {
                                this.fireCustomEvent("Error", "error", item.TabName__c + ' : Please retry to validate the ID proof document or input the ID details manually in PAN & KYC page', false);
                            }
                        }
                        else {
                            this.fireCustomEvent("Error", "error", item.TabName__c + ' : Please retry to validate the ID proof document or input the ID details manually in PAN & KYC page', false);
                        }
                    } else {
                        this.fireCustomEvent("Error", "error", " Required Data is Missing , Mobile Number or Gender is missing on Loan Applicant  ", false);
                    }
                } else {
                    this.fireCustomEvent("Error", "error", " Required Data is Missing , Product or Request Amount is missing on Loan Application  ", false);
                }
            } else {
                let fields = {};
                fields['sobjectType'] = 'IntgMsg__c';
                fields['Name'] = 'Commercial ACK Request'; //serviceName;//'KYC OCR'
                fields['BU__c'] = 'HL / STL';
                fields['IsActive__c'] = true;
                fields['Svc__c'] = 'Commercial ACK Request'; //serviceName;
                fields['ExecType__c'] = 'Async';
                fields['Status__c'] = 'New';
                fields['Mresp__c'] = 'Blank';
                // fields['Outbound__c'] = true;
                fields['Trigger_Platform_Event__c'] = false;
                fields['RefObj__c'] = 'Applicant__c';
                fields['RefId__c'] = item.Id;
                fields['ParentRefObj__c'] = "LoanAppl__c";
                fields['ParentRefId__c'] = this.loanAppId;
                fields['TriggerType__c'] = 'Manual';
                fields['RetriRatinal__c'] = item.RationalRemarks;
                this.intRecords.push(fields);
            }
        })
        if (this.intRecords.length > 0) {
            console.log('intRecords records are ', JSON.stringify(this.intRecords));
            this.upsertIntRecord(this.intRecords);
        }
    }

    createIntMsgForHunter(filteredData) {
        let fields = {};
        fields['sobjectType'] = 'IntgMsg__c';
        fields['Name'] = this.serviceName; //serviceName;//'KYC OCR'
        fields['BU__c'] = 'HL / STL';
        fields['IsActive__c'] = true;
        fields['Svc__c'] = this.serviceName; //serviceName;
        fields['ExecType__c'] = 'Async';
        fields['Status__c'] = 'New';
        fields['Mresp__c'] = 'Blank';
        fields['Outbound__c'] = true;
        fields['Trigger_Platform_Event__c'] = false;
        fields['ParentRefObj__c'] = "LoanAppl__c";
        fields['ParentRefId__c'] = this.loanAppId;
        if (this.totalApplicants.length === filteredData.length) {
            fields['RefObj__c'] = 'LoanAppl__c';
            fields['RefId__c'] = this.loanAppId;
            let array2 = [];
            filteredData.forEach(item => {
                array2.push(item.RationalRemarks);
            })
            console.log('array2 is ', JSON.stringify(array2));
            let rationalRem = array2.join(",");
            fields['RetriRatinal__c'] = rationalRem;
        } else {
            fields['RefObj__c'] = 'Applicant__c';
            let array = [];
            let array2 = [];
            filteredData.forEach(item => {
                array.push(item.Id);
                array2.push(item.RationalRemarks);
            })
            console.log('array is ', JSON.stringify(array));
            let refIds = array.join(",");
            let rationalRem = array2.join(",");
            fields['RefId__c'] = refIds;
            fields['RetriRatinal__c'] = rationalRem;
        }
        this.intRecords.push(fields);
        this.upsertIntRecord(this.intRecords);
    }

    createIntMsgForWatchOut(appIds) {
        appIds.forEach(item => {
            let fields = {};
            fields['sobjectType'] = 'IntgMsg__c';
            fields['Name'] = this.serviceName; //serviceName;//'KYC OCR'
            fields['BU__c'] = 'HL / STL';
            fields['IsActive__c'] = true;
            fields['Svc__c'] = this.serviceName; //serviceName;
            fields['ExecType__c'] = 'Async';
            fields['Status__c'] = 'New';
            fields['Mresp__c'] = 'Blank';
            fields['Outbound__c'] = true;
            fields['Trigger_Platform_Event__c'] = false;
            fields['RefObj__c'] = 'Applicant__c';
            fields['RefId__c'] = item.Id;
            fields['ParentRefObj__c'] = "LoanAppl__c";
            fields['ParentRefId__c'] = this.loanAppId;
            fields['RetriRatinal__c'] = item.RationalRemarks;
            this.intRecords.push(fields);
        })
        console.log(JSON.stringify(this.intRecords));
        this.upsertIntRecord(this.intRecords);
    }


    createIntMsgForTrackwizz(filteredData) {
        let arra = ['Risk API', 'Screening API'];
        for (let i = 0; i < 2; i++) {
            let fields = {};
            fields['sobjectType'] = 'IntgMsg__c';
            fields['Name'] = arra[i]; //serviceName;//'KYC OCR'
            fields['BU__c'] = 'HL / STL';
            fields['IsActive__c'] = true;
            fields['Svc__c'] = arra[i]; //serviceName;
            fields['ExecType__c'] = 'Async';
            fields['Status__c'] = 'New';
            fields['Mresp__c'] = 'Blank';
            fields['Outbound__c'] = true;
            fields['Trigger_Platform_Event__c'] = false;
            fields['ParentRefObj__c'] = "LoanAppl__c";
            fields['ParentRefId__c'] = this.loanAppId;
            if (this.totalApplicants.length === filteredData.length) {
                fields['RefObj__c'] = '';
                fields['RefId__c'] = '';
                let array2 = [];
                filteredData.forEach(item => {
                    array2.push(item.RationalRemarks);
                })
                console.log('array2 is ', JSON.stringify(array2));
                let rationalRem = array2.join(",");
                fields['RetriRatinal__c'] = rationalRem;
            } else {
                fields['RefObj__c'] = 'Applicant__c';
                let array = [];
                let array2 = [];
                filteredData.forEach(item => {
                    array.push(item.Id);
                    array2.push(item.RationalRemarks);
                })
                console.log('array is ', JSON.stringify(array));
                let refIds = array.join(",");
                let rationalRem = array2.join(",");
                fields['RetriRatinal__c'] = rationalRem;
                fields['RefId__c'] = refIds;
            }
            this.intRecords.push(fields);
        }
        this.upsertIntRecord(this.intRecords);
    }

    upsertIntRecord(intRecords) {
        console.log('int msgs records ', JSON.stringify(intRecords));
        upsertMultipleRecord({ params: intRecords })
            .then((result) => {
                console.log('Result after creating Int Msgs is ', JSON.stringify(result));
                result.forEach(item => {
                    this.intMsgIds.push(item.Id);
                })
                console.log('intMsgIds after creating Int Msgs is ', JSON.stringify(this.intMsgIds));
                this.fireCustomEvent("Success", "success", "Re-Initiated Successfully, Please Click on Refresh Button to See Details on Table", false);
                this.intRecords = [];
                this.fireCustomEvent(null, null, null, false);
            })
            .catch((error) => {
                console.log('Error In creating Record', error);
                this.fireCustomEvent("Error", "error", "Error occured in upsertMultipleRecord " + error, false);
            });
    }

    fireCustomEvent(title, vart, msg, spinnerValue) {
        const selectEvent = new CustomEvent('fireevent', {
            detail: { title: title, variant: vart, message: msg, spinner: spinnerValue }
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }

}