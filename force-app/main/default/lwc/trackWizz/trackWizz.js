import { LightningElement, api, track } from 'lwc';

//Apex Methods
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import getSobjectDataWithoutCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjDtwithFltrRelatedRecordsWithoutCache';


import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class TrackWizz extends LightningElement {
    @api loanAppId = 'a08C4000007Kw2EIAS';
    @api hasEditAccess = false;

    @track isReadOnly = false;
    @track disableReintiate = false;
    @track queryParam = [];
    @track queryParamRisk = [];
    @track paramsScrAPI = {};
    @track paramsRiskAPI = {};
    @track paramsAppl = {};
    @track refrshTables = false;

    @track activeSection = ["A", "B"];
    @track columnsDataForScreening = [
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
            "label": "Source",
            "fieldName": "Source__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Screening Results",
            "fieldName": "ScrRes__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Screening Decision",
            "fieldName": "ScrDec__c",
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

    @track columnsDataForRisk = [
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
            "label": "Risk Rating System",
            "fieldName": "Risk_Rating_System__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Risk Rating Final",
            "fieldName": "Risk_Rating_Final__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Risk Rating Decision",
            "fieldName": "Risk_Rating_Decision__c",
            "type": "text",
            "Editable": false,

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
    @track isModalOpen = false;
    @track queryDataForScreening = 'SELECT ApplNme__c,toLabel(ApplTyp__c),Source__c,ScrRes__c,ScrDec__c,CreatedDate,IntegrationStatus__c,IntegrationErrorMessage__c,Id FROM APIVer__c WHERE LoanAplcn__c =: loanAppId AND IsLatest__c =: isActiveValue AND recordtype.name =: recordTypeName';
    @track queryDataForRisk = 'SELECT ApplNme__c,toLabel(ApplTyp__c),Risk_Rating_System__c,Risk_Rating_Final__c,Risk_Rating_Decision__c,CreatedDate,IntegrationStatus__c,IntegrationErrorMessage__c,Id FROM APIVer__c WHERE LoanAplcn__c =: loanAppId AND IsLatest__c =: isActiveValue AND recordtype.name =: recordTypeName';

    connectedCallback() {
        let paramVal = [];
        paramVal.push({ key: 'loanAppId', value: this.loanAppId });
        paramVal.push({ key: 'recordTypeName', value: 'Screening' });
        paramVal.push({ key: 'isActiveValue', value: true });
        this.queryParam = paramVal;
        let paramValRisk = [];
        paramValRisk.push({ key: 'loanAppId', value: this.loanAppId });
        paramValRisk.push({ key: 'recordTypeName', value: 'Risk Rating' });
        paramValRisk.push({ key: 'isActiveValue', value: true });
        this.queryParam = paramVal;
        console.log('map data:::', this.queryParam);
        this.paramsScrAPI = {
            columnsData: this.columnsDataForScreening,
            queryParams: this.queryParam,
            query: this.queryDataForScreening
        }

        this.queryParamRisk = paramValRisk;
        this.paramsRiskAPI = {
            columnsData: this.columnsDataForRisk,
            queryParams: this.queryParamRisk,
            query: this.queryDataForRisk
        }

        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }
        this.disableReintiate = this.isReadOnly;
        this.getApiRetriggerTrackerData();
    }
    @track applIds = [];
    @track apiRetrgrTrcrData = [];
    getApiRetriggerTrackerData() {
        let arra = ['Risk API', 'Screening API'];
        console.log('loanappId in Reintiate component', this.loanAppId);
        let paramsLoanApp = {
            ParentObjectName: 'APIRetriggerTracker__c',
            parentObjFields: ['Id', 'App__c', 'LoanApp__c', 'IsProcessed__c', 'App__r.TabName__c', 'App__r.Id'],
            queryCriteria: ' where APIName__c  IN (\'' + arra.join('\', \'') + '\') AND  IsProcessed__c = false AND LoanApp__c = \'' + this.loanAppId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('apiRetrgrTrcrData is', JSON.stringify(result));
                this.apiRetrgrTrcrData = [];
                if (result.parentRecords && result.parentRecords.length > 0) {
                    result.parentRecords.forEach(item => {
                        if (item.App__c) {
                            this.apiRetrgrTrcrData.push(item.App__r.Id);
                        }
                    })
                }
                this.getAppWithCallOutData();
                console.log('disableReintiate ', this.disableReintiate);
                console.log('this.apiRetrgrTrcrData after', this.apiRetrgrTrcrData);
                if (result.error) {
                    console.error('apiRetrgrTrcrData result getting error=', result.error);
                }
            })
    }

    // async getCalloutData() {
    //     let arr = await this.getapplicantData();
    //     console.log('loanappId in Reintiate component', this.loanAppId);
    //     let arra = ['Risk API', 'Screening API'];
    //     let paramsLoanApp = {
    //         ParentObjectName: 'APICoutTrckr__c',
    //         parentObjFields: ['Id', 'LtstRespCode__c', 'Appl__c', 'Appl__r.Id', 'LAN__c'],
    //         // queryCriteria: ' where LAN__c = \'' + this.loanAppId + '\''
    //         queryCriteria: ` where APIName__c IN ('${arra.join("','")}') AND LAN__c = '${this.loanAppId}'`
    //     }
    //     getSobjectData({ params: paramsLoanApp })
    //         .then((result) => {
    //             console.log('api callout tracker data is', JSON.stringify(result));
    //             if (result.parentRecords && result.parentRecords.length > 0) {
    //                 // this.apiRetrgrTrcrData = JSON.parse(JSON.stringify(result));
    //                 result.parentRecords.forEach(item => {
    //                     if (item.LtstRespCode__c != 'Success') {
    //                         if (item.Appl__c) {
    //                             this.apiRetrgrTrcrData.push(item.Appl__r.Id);
    //                             //this.applIds.add(item.Appl__r.Id);
    //                         }
    //                         else {
    //                             this.apiRetrgrTrcrData = [...this.apiRetrgrTrcrData, ...arr];
    //                         }
    //                     }
    //                 })
    //             }
    //             this.apiRetrgrTrcrData = [...new Set(this.apiRetrgrTrcrData)];
    //             this.applIds = [...this.apiRetrgrTrcrData];
    //             if (this.applIds.length === 0) {
    //                 this.disableReintiate = true;
    //             }

    //             if (this.isReadOnly) {
    //                 this.disableReintiate = true;
    //             }
    //             console.log('this.applIds are ', this.applIds);
    //             console.log('this.applIds length is are ', this.applIds.length);
    //             console.log('this.apiRetrgrTrcrData after final is', this.apiRetrgrTrcrData);
    //             if (result.error) {
    //                 console.error('apiRetrgrTrcrData result getting error=', result.error);
    //             }
    //         })
    // }

    @track loanApiCalOutSuccIds = [];
    async getAppWithCallOutData() {
        // let arr = await this.getapplicantData();
        // let apiCalOutsSuccesIds = await this.getApiCallOutData(arr);
        console.log('loanappId in Reintiate component', this.loanAppId);
        let arra = ['Risk API', 'Screening API'];
        let appTypes = ['P', 'C', 'G'];
        let paramsLoanApp = {
            ParentObjectName: 'Applicant__c',
            ChildObjectRelName: 'API_Callout_Trackers__r',
            parentObjFields: ['Id', 'LoanAppln__c', 'LoanAppln__r.Id'],
            childObjFields: ['Id', 'LtstRespCode__c', 'APIName__c', 'Appl__r.Id', 'LAN__c'],
            queryCriteriaForChild: ` where APIName__c IN ('${arra.join("','")}') AND LAN__c = '${this.loanAppId}'`,
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
                                    else {
                                        this.apiRetrgrTrcrData = [...this.apiRetrgrTrcrData, ...arr];
                                    }
                                }
                            })
                        } else {
                            // if (!this.loanApiCalOutSuccIds.includes(item.parentRecord.LoanAppln__r.Id)) {

                            //     if (!apiCalOutsSuccesIds.includes(item.parentRecord.Id)) {
                            this.apiRetrgrTrcrData.push(item.parentRecord.Id);
                            //     }

                            // }
                        }
                    })
                    //  this.getApiVer();

                    this.apiRetrgrTrcrData = [...new Set(this.apiRetrgrTrcrData)];
                    this.applIds = [...this.apiRetrgrTrcrData];
                    if (this.applIds.length === 0) {
                        this.disableReintiate = true;
                    }
                    if (this.isReadOnly) {
                        this.disableReintiate = true;
                    }
                    console.log('this.applIds are ', this.applIds);
                    console.log('this.applIds length is are ', this.applIds.length);
                    console.log('this.apiRetrgrTrcrData after final is', this.apiRetrgrTrcrData);
                    this.showSpinner = false;
                }

                if (result.error) {
                    this.showSpinner = false;
                    console.error('apiRetrgrTrcrData result getting error=', result.error);
                }
            })
    }

    getApiVer() {
        let recordTypes = ['Risk Rating', 'Screening'];
        let params = {
            ParentObjectName: 'APIVer__c',
            parentObjFields: ['Id', 'IntegrationStatus__c', 'Appl__c', 'Appl__r.Id'],
            // queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND ApplType__c = \'' + appType + '\''
            queryCriteria: ' Where LoanAplcn__c = \'' + this.loanAppId + '\'  AND RecordType.Name  IN (\'' + recordTypes.join('\', \'') + '\') AND IsLatest__c = true'
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('api verification Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    result.parentRecords.forEach(item => {
                        if (item.IntegrationStatus__c == 'Failure') {
                            if (item.Appl__c) {
                                this.apiRetrgrTrcrData.push(item.Appl__r.Id);
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
                console.log('this.applIds are ', this.applIds);
                console.log('this.applIds length is are ', this.applIds.length);
                console.log('this.apiRetrgrTrcrData after final is', this.apiRetrgrTrcrData);
                this.showSpinner = false;
                // console.log('apicallOutData is ', JSON.stringify(apicallOutData));
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Document Dispatch Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    getApiCallOutData(appIds) {
        return new Promise((resolve, reject) => {
            this.showSpinner = true;
            let appIdsSucs = [];
            let apiName = ['Risk API', 'Screening API'];
            let params = {
                ParentObjectName: 'APICoutTrckr__c',
                parentObjFields: ['Id', 'LtstRespCode__c', 'APIName__c', 'ParentRefId__c', 'RefId__c', 'LAN__c', 'LAN__r.Id'],
                // queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND ApplType__c = \'' + appType + '\''
                queryCriteria: ' Where LAN__c = \'' + this.loanAppId + '\'  AND APIName__c  IN (\'' + apiName.join('\', \'') + '\')'
            }
            getSobjectData({ params: params })
                .then((result) => {
                    console.log('apicallOutData is ', JSON.stringify(result));
                    if (result.parentRecords) {
                        result.parentRecords.forEach(item => {
                            if (item.LtstRespCode__c == 'Success') {
                                if (item.RefId__c) {
                                    let splittedValues = item.RefId__c.split(',');
                                    splittedValues.forEach(it => {
                                        appIdsSucs.push(it);
                                    })
                                } else if (item.ParentRefId__c) {
                                    if (!this.loanApiCalOutSuccIds.includes(item.ParentRefId__c)) {
                                        this.loanApiCalOutSuccIds.push(item.ParentRefId__c);
                                    }
                                }
                            }
                        })
                    }
                    this.showSpinner = false;
                    resolve(appIdsSucs);
                    // console.log('apicallOutData is ', JSON.stringify(apicallOutData));
                })
                .catch((error) => {
                    this.showSpinner = false;
                    reject(error);
                    console.log('Error In getting Document Dispatch Data is ', error);
                    //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
                });
        });
    }
    getapplicantData() {
        return new Promise((resolve, reject) => {
            this.showSpinner = true;
            let returnArr = [];
            let appType = ['P', 'C', 'G'];
            let params = {
                ParentObjectName: 'Applicant__c',
                parentObjFields: ['Id', 'Name'],
                // queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND ApplType__c = \'' + appType + '\''
                queryCriteria: ' Where LoanAppln__c = \'' + this.loanAppId + '\'  AND ApplType__c  IN (\'' + appType.join('\', \'') + '\')'
            }
            getSobjectData({ params: params })
                .then((result) => {
                    console.log('Applicant Data is ', JSON.stringify(result));
                    if (result.parentRecords) {
                        result.parentRecords.forEach(item => {
                            returnArr.push(item.Id);
                        })
                    }

                    this.showSpinner = false;
                    resolve(returnArr);
                    console.log('Applicant Ids is ', JSON.stringify(returnArr));
                })
                .catch((error) => {
                    this.showSpinner = false;
                    reject(error);
                    console.log('Error In getting Document Dispatch Data is ', error);
                    //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
                });

        });
    }
    handleIntialization() {
        this.isModalOpen = true;
    }
    @track showSpinner = false;
    // handleSpinner(event) {
    //   this.isModalOpen = false;

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
            this.getApiRetriggerTrackerData();
            const evt = new ShowToastEvent({
                title: titleVal,
                variant: variantVal,
                message: messageVal
            });
            this.dispatchEvent(evt);

        }
    }

    handleRefreshClick() {

        this.showSpinner = true;
        const childComponent = this.template.querySelector('[data-id="childComponentOne"]');
        if (childComponent) {
            console.log('before');
            childComponent.handleGettingData();
            console.log('after');

            const childComponentTwo = this.template.querySelector('[data-id="childComponentTwo"]');
            if (childComponentTwo) {
                console.log('before');
                childComponentTwo.handleGettingData();
                console.log('after');
            }
            //this.showSpinner = false;
            setTimeout(() => {
                this.showSpinner = false;
                this.getApiRetriggerTrackerData();
            }, 6000);

        }
    }
}