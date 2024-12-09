import { LightningElement, api, track, wire } from 'lwc';

import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';

//apex methods
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getAllSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataWithoutCacheable';

import formFactorPropertyName from "@salesforce/client/formFactor";
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import { formatDateFunction ,formattedDateTimeWithoutSeconds ,formattedDate } from 'c/dateUtility';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

// Custom labels
import DeDupVerf_ReqFields_ErrorMessage from '@salesforce/label/c.DeDupVerf_ReqFields_ErrorMessage';
import DeDupVerf_Save_SuccessMessage from '@salesforce/label/c.DeDupVerf_Save_SuccessMessage';
import DedupeVerIntMsg_Save_SuccessMessage from '@salesforce/label/c.DedupeVerIntMsg_Save_SuccessMessage';

export default class DedupeVerification extends LightningElement {
    label = {
        DeDupVerf_ReqFields_ErrorMessage,
        DeDupVerf_Save_SuccessMessage,
        DedupeVerIntMsg_Save_SuccessMessage
    }

    //@api loanAppId = 'a08C4000007VLU0IAO';
    @api loanAppId
    @api hasEditAccess;
    @track isReadOnly = false;
    @track showSpinner = false;
    @track formFactor = formFactorPropertyName;
    @track desktopBoolean = false;
    @track phoneBolean = false;
    @track deduperRecordTypeName = 'Dedupe';
    @track enpaRecordTypeName = 'ENPA';
    @track dedupeData = [];
    @track enpaData = [];
    @track activeSections = ["A", "B"];
    enableInfiniteScrolling = true;
    enableBatchLoading = true;
    @track dedupeResponseOptions = [];
    @track dedupeRelevanceOptions = [];
    @track dedupeRsultsOptions = [];
    @track internalTopUpOptions = [];
    @track pddPendingOptions = [];
    @track loanLTVOptions = [];
    @track loanProposedLanOptions = [];
    @track dedupeRecordTypeId;
    @track showEnpaData = false;
    @track isModalOpen = false;
    @track isModalOpenENPA = false;
    @track dedupeResponseIds = [];
    @track disableReintiate = false;

    @api stage
    @wire(getObjectInfo, { objectApiName: 'DedupeResponse__c' })
    dedupeObjectInfo({ error, data }) {
        if (data) {
            console.log('DATA in RECORD TYPE ID', data);
            for (let key in data.recordTypeInfos) {
                let recordType = data.recordTypeInfos[key];
                console.log("recordType.value>>>>>", recordType.name);
                if (recordType.name === 'Dedupe') {
                    this.dedupeRecordTypeId = key;
                }
                console.log('data.dedupeRecordTypeId', this.dedupeRecordTypeId);
            }
        } else if (error) {
            console.error('Error fetching record type Id', error);
        }
    }

    statusOptions = [
        { value: 'new', label: 'New', description: 'A new item' },
        {
            value: 'in-progress',
            label: 'In Progress',
            description: 'Currently working on this item',
        },
        {
            value: 'finished',
            label: 'Finished',
            description: 'Done working on this item',
        },
    ];
    generatePicklist(data) {
        console.log('data in generatePicklist ', JSON.stringify(data));
        if (data.values) {
            return data.values.map(item => ({ label: item.label, value: item.value }))
        }
        return null;
    }
    loantobeClosedInternally = []
    @wire(getPicklistValuesByRecordType, {
        objectApiName: 'DedupeResponse__c',
        recordTypeId: '$dedupeRecordTypeId',
    })
    dedupePicklistHandler({ data, error }) {
        if (data) {
            console.log('data in PicklistHandler', JSON.stringify(data));
            this.dedupeResponseOptions = [...this.generatePicklist(data.picklistFieldValues.InternalDedupeResponse__c)]
            this.dedupeRelevanceOptions = [...this.generatePicklist(data.picklistFieldValues.IntnlDeduRelevance__c)]
            this.dedupeRsultsOptions = [...this.generatePicklist(data.picklistFieldValues.IntrnlDeduperes__c)]
            this.internalTopUpOptions = [...this.generatePicklist(data.picklistFieldValues.Internal_Top_up_Original_loan__c)]
            this.loantobeClosedInternally = [...this.generatePicklist(data.picklistFieldValues.Loan_to_be_closed_internally__c)]
            this.pddPendingOptions = [...this.generatePicklist(data.picklistFieldValues.IsPDDpending__c)]
            this.loanLTVOptions = [...this.generatePicklist(data.picklistFieldValues.LoantobeconsideredinLTVcal__c)]
            this.loanProposedLanOptions = [...this.generatePicklist(data.picklistFieldValues.Loantobelinkedwithproposedloan__c)]
        }
        if (error) {
            console.error('error im getting picklist values are', error)
        }
    }



    @track showHelp = false;

    showHelpText(event) {
        this.showHelp = true;
    }

    hideHelpText(event) {
        this.showHelp = false;
    }
    
    connectedCallback() {
        console.log('stageNamestageName' + this.stageName)
        console.log('formFactor is ', this.formFactor);
        if (this.formFactor == "Large") {
            this.desktopBoolean = true;
            this.phoneBolean = false;
        } else if (this.formFactor == "Small") {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        } else {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        }
        //  this.hasEditAccess = false;
        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }

        //this.getDedupeData();
        this.getMatchingCriteriaData();
        this.scribeToMessageChannel();

        this.disableReintiate = this.isReadOnly;
        this.getapplicantData();
        this.getLoanApplicationData();
        this.getRecordTypeForEnpa();
    }

    //For LAK-5091
    @track disableButtons = false
    @track loanStage;
    getLoanApplicationData() {
        this.showSpinner = true;
        let params = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Id', 'Stage__c', 'SubStage__c'],
            queryCriteria: ' where Id = \'' + this.loanAppId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                // this.showSpinner = true;
                console.log('Loan Application Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.loanStage = result.parentRecords[0].Stage__c;
                    if (this.loanStage == 'QDE') {
                        this.disableButtons = true;
                    } else {
                        this.disableButtons = this.isReadOnly;
                    }
                }

            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Loan Application Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    getDedupeUcidData(ucidPassed) {
        this.showSpinner = true;
        let params = {
            ParentObjectName: 'DedupeResponse__c',
            parentObjFields: ['Id', 'Name' ,'UCID__c'],
            queryCriteria: ' where UCID__c = \'' + ucidPassed + '\' AND GroupEnpa__c =true order by CreatedDate desc limit 1'
        }
        getSobjectData({ params: params })
            .then((result) => {
                // this.showSpinner = true;
                console.log('DedupeResponse__c Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    return result.parentRecords[0].Id;
                }

            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting DEDUPE Data is ', error);
            });
    }


    //For LAK-5091
    @track applIds = [];
    @track apiRetrgrTrcrData = [];
    @track appDataForUdid = [];
    @track disableGenUcid = false;
    @track primaryApplId='';

    @track isGrpTxnY = false;
    

    getapplicantData() {
        this.appDataForUdid = [];
        this.showSpinner = true;
        let returnArr = [];
        let appType = ['P', 'C', 'G'];
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'Name', 'TabName__c', 'FullName__c', 'UCID__c','ApplType__c','IsGrpExposureTxn__c'],
            // queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND ApplType__c = \'' + appType + '\''
            queryCriteria: ' Where LoanAppln__c = \'' + this.loanAppId + '\'  AND ApplType__c  IN (\'' + appType.join('\', \'') + '\')'
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Applicant Data is ::', JSON.stringify(result));
                if (result.parentRecords) {
                    result.parentRecords.forEach(item => {
                        this.apiRetrgrTrcrData.push(item.Id);
                        if (!item.UCID__c) {
                            item.selectCheckbox = false;
                            this.appDataForUdid.push(item);
                        }
                        if(item.ApplType__c && item.ApplType__c === 'P'){
                            this.primaryApplId=item.Id;

                            if(item.IsGrpExposureTxn__c === 'Yes'){
                                this.isGrpTxnY =true;
                            }
                        }
                    })
                }
                this.apiRetrgrTrcrData = [...new Set(this.apiRetrgrTrcrData)];
                this.applIds = [...this.apiRetrgrTrcrData];
                this.showSpinner = false;
                if (this.appDataForUdid.length === 0 || this.isReadOnly) {
                    this.disableGenUcid = true;
                }
                console.log('Applicant Ids is ', JSON.stringify(returnArr));
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Document Dispatch Data is ', error);
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
    //             this.apiRetrgrTrcrData = [];
    //             if (result.parentRecords && result.parentRecords.length > 0) {
    //                 result.parentRecords.forEach(item => {
    //                     this.apiRetrgrTrcrData.push(item.App__r.Id);
    //                     //this.apiRetrgrTrcrData.push(item.App__r.Id);
    //                     //this.applIds.add(item.App__r.Id);
    //                 })
    //             }
    //             this.getCalloutData();
    //             console.log('disableReintiate ', this.disableReintiate);
    //             console.log('this.apiRetrgrTrcrData after', this.apiRetrgrTrcrData);
    //             if (result.error) {
    //                 console.error('apiRetrgrTrcrData result getting error=', result.error);
    //             }
    //         })
    // }

    // getCalloutData() {
    //     console.log('loanappId in Reintiate component', this.loanAppId);
    //     let apiName = 'Dedupe API Token';
    //     let paramsLoanApp = {
    //         ParentObjectName: 'APICoutTrckr__c',
    //         parentObjFields: ['Id', 'LtstRespCode__c', 'Appl__c', 'Appl__r.Id', 'LAN__c'],
    //         queryCriteria: ' where LAN__c = \'' + this.loanAppId + '\' AND APIName__c = \'' + apiName + '\''
    //     }
    //     getSobjectData({ params: paramsLoanApp })
    //         .then((result) => {
    //             console.log('apiRetrgrTrcrData is', JSON.stringify(result));
    //             if (result.parentRecords && result.parentRecords.length > 0) {
    //                 // this.apiRetrgrTrcrData = JSON.parse(JSON.stringify(result));
    //                 result.parentRecords.forEach(item => {
    //                     if (item.LtstRespCode__c != 'Success') {
    //                         if (item.Appl__c) {
    //                             this.apiRetrgrTrcrData.push(item.Appl__r.Id);
    //                             //this.applIds.add(item.Appl__r.Id);
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
    //             console.log('this.apiRetrgrTrcrData after', this.apiRetrgrTrcrData);
    //             if (result.error) {
    //                 console.error('apiRetrgrTrcrData result getting error=', result.error);
    //             }
    //         })
    // }
    // getDedupeData() {
    //     console.log('loanappId in DedupeData component', this.loanAppId);
    //     let paramsLoanApp = {
    //         ParentObjectName: 'DedupeResponse__c',
    //         parentObjFields: ['Id', 'LoanAppln__c', 'UCID__c', 'DedupeMatchName__c', 'Applicant__c', 'Applicant__r.TabName__c', 'InternalDedupeResponse__c', 'MatchCriteria__c', 'MatchSource__c', 'PastAppId__c', 'PastAppDate__c', 'LoanType__c', 'LoanStatus__c', 'RejectionReason__c', 'LoanDisbDate__c', 'LoanAmount__c', 'Tenure__c', 'CurrentOutstanding__c', 'SystemDPD__c', 'SecuritisationStatus__c', 'IntnlDeduRelevance__c', 'IntrnlDeduperes__c', 'IntnalDeduperesremark__c'],
    //         queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND recordtype.name = \'' + this.deduperRecordTypeName + '\' AND IsLatest__c = true'
    //     }
    //     //recordtype.name =: recordTypeName
    //     getSobjectData({ params: paramsLoanApp })
    //         .then((result) => {
    //             console.log('result of dedupe details is', JSON.stringify(result));
    //             if (result.parentRecords && result.parentRecords.length > 0) {
    //                 this.dedupeData = result.parentRecords;
    //                 this.makeFieldsRequired();
    //                 console.log('this.dedupeData ', JSON.stringify(this.dedupeData));
    //                 this.callEnpaMethod();
    //             }
    //         })
    //         .catch((error) => {
    //             console.log('Error In getting DedupeData', error);
    //         });
    // }

    @track
    recordTypeparameter = {
        ParentObjectName: 'RecordType  ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'DeveloperName', 'SobjectType'],
        childObjFields: [],
        queryCriteria: 'where SobjectType=\'' + 'DedupeResponse__c ' + '\''
    }

    @track enpaRecordTypeId;


    getRecordTypeForEnpa() {

        let recordTypeparameters = {
            ParentObjectName: 'RecordType',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'Name', 'DeveloperName', 'SobjectType'],
            childObjFields: [],
          //  queryCriteria: ' where SObjectType = \'' + 'DedupeResponse__c ' + ' AND  '  + '\'  DeveloperName =\'' + 'ENPA' + '\''  
            queryCriteria: ' WHERE SObjectType = \'' + 'DedupeResponse__c' + '\' AND DeveloperName = \'' + 'ENPA' + '\''

        }
        getSobjectData({ params: recordTypeparameters })
            .then((result) => {
                console.log('RecordType Data is ', JSON.stringify(result));
                if (result.parentRecords) { 
                    for (let i = 0; i < result.parentRecords.length; i++) {
                        console.log('recordTypeparameter out ==',result.parentRecords[i].Id)
                        if (result.parentRecords[i].DeveloperName == 'ENPA') {
                            console.log('recordTypeparameter ==',result.parentRecords[i].Id)
                            this.enpaRecordTypeId = result.parentRecords[i].Id;
                        }
                    }
                }
            })
            .catch((error) => {
                console.log('Error In getting Applicant Data for Enpa is ', error);
            });

    }


    getMatchingCriteriaData() {
        let paramsData = {
            ParentObjectName: 'DedupeResponse__c',
            ChildObjectRelName: 'Dedupe_Responses__r',
            parentObjFields: ['Id', 'LoanAppln__c', 'LatestReportTime__c', 'UCID__c', 'Dedupe__r.UCID__c', 'Lan__c', 'DedupeMatchName__c', 'Applicant__c', 'Applicant__r.Id', 'Applicant__r.UCID__c', 'Applicant__r.TabName__c', 'InternalDedupeResponse__c', 'Dedupe__c', 'Dedupe__r.MatchCriteria__c', 'MatchSource__c', 'PastAppId__c', 'AppId__c', 'PastAppDate__c', 'LoanType__c', 'LoanStatus__c', 'RejectionReason__c', 'LoanDisbDate__c', 'LoanAmount__c', 'Tenure__c', 'CurrentOutstanding__c', 'SystemDPD__c', 'SecuritisationStatus__c', 'IntnlDeduRelevance__c', 'IntrnlDeduperes__c', 'IntnalDeduperesremark__c', 'IsAddMatchingCr__c', 'NoMatchFound__c'],
            childObjFields: ['Id', 'LoanAppln__c', 'LatestReportTime__c', 'Dedupe__r.UCID__c', 'Dedupe__r.InternalDedupeResponse__c', 'Lan__c', 'DedupeMatchName__c', 'Applicant__c', 'Applicant__r.Id', 'Applicant__r.UCID__c', 'Applicant__r.TabName__c', 'InternalDedupeResponse__c', 'Dedupe__c', 'Dedupe__r.MatchCriteria__c', 'MatchSource__c', 'PastAppId__c', 'AppId__c', 'PastAppDate__c', 'LoanType__c', 'LoanStatus__c', 'RejectionReason__c', 'LoanDisbDate__c', 'LoanAmount__c', 'Tenure__c', 'CurrentOutstanding__c', 'SystemDPD__c', 'SecuritisationStatus__c', 'IntnlDeduRelevance__c', 'IntrnlDeduperes__c', 'IntnalDeduperesremark__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND recordtype.name = \'' + this.deduperRecordTypeName + '\' AND IsLatest__c = true ORDER BY Applicant__r.ApplType__c'
        }
        getAllSobjectDatawithRelatedRecords({ params: paramsData })
            .then((result) => {
                let arr = [];
                result.forEach(item => {
                    if (item.ChildReords) {
                        // arr = [...arr, item.ChildReords];
                        item.ChildReords.forEach(ite => {
                            ite.UCID__c = item.parentRecord.UCID__c;
                            arr.push(ite);
                        })
                    }
                })
                //For LAK-4247
                result.forEach(item => {
                    if (item.parentRecord) {
                        if (item.parentRecord.NoMatchFound__c === true) {
                            arr.push(item.parentRecord);
                            return;
                        }
                        if (item.parentRecord.IsAddMatchingCr__c === false) {
                            arr.push(item.parentRecord);
                        }
                        
                    }
                })
                //For LAK-4247
                this.dedupeData = JSON.parse(JSON.stringify(arr));
                         
                
                this.dedupeData.forEach(item => {
                    console.log('item.PastAppDate__c 1'+ item.PastAppDate__c);
                    console.log('item.LatestReportTime__c 1'+ item.LatestReportTime__c);
                   
                    if(item.PastAppDate__c){
                        const dateTime1 = item.PastAppDate__c;
                        const formattedDate1 = formatDateFunction(dateTime1);
                        const dateOfApp1 = `${formattedDate1}`;
                        item.PastAppDate__c = dateOfApp1;
                    }

                    if(item.LatestReportTime__c){
                        const dateToPass =new Date(item.LatestReportTime__c);
                        const dateTime2 = formattedDateTimeWithoutSeconds(dateToPass);
                        const dateOfApp2 = `${dateTime2}`;
                        item.LatestReportTime__c = dateOfApp2;
                    }
                    if(item.LoanDisbDate__c){
                        const dateToPass3 =new Date(item.LoanDisbDate__c);
                        const dateTime3 = formattedDate(dateToPass3);
                        const dateOfApp3 = `${dateTime3}`;
                        item.LoanDisbDate__c = dateOfApp3;
                    }
                    console.log('item.LoanDisbDate__c '+item.LoanDisbDate__c);
                    console.log('item.PastAppDate__c 2 '+item.PastAppDate__c);
                    console.log('item.LatestReportTime__c 2'+ item.LatestReportTime__c);

                })
               
                this.makeFieldsRequired();
                this.callEnpaMethod();

            })
            .catch((error) => {
                console.log('Error In getting matchingCriteriaData', error);
            });
    }
    // getrequired(dedupeData) {
    //     dedupeData.forEach(item => {
    //         if (item.IntnlDeduRelevance__c == 'Accurate Match found') {
    //             item.isRequired = true;
    //         } else {
    //             item.isRequired = false;
    //         }
    //     })
    // }

    handleIntialization() {
        this.isModalOpen = true;

    }
    @track appRecordsData = [];
    @track appIdsForENpa = [];

    


    handleENPAIntialization() {
        this.isModalOpenENPA =true;
        //this.modalFlag =true;
       // this.showUcidBox =true;
        // this.isModalOpenENPA = true;
        this.showSpinner = true;
        this.appRecordsData = this.dedupeData.filter(item => item.IntnlDeduRelevance__c === 'Accurate Match found');
        
        // this.appRecordsData = [...new Set(this.appRecordsData)];

        this.appRecordsData.forEach(item => {
            this.appIdsForENpa.push(item.Applicant__r.Id);
        });
        this.appIdsForENpa = [...new Set(this.appIdsForENpa)];
        
        this.getapplicantDataNewForENpa();
    }
    @track appDataForEnpa = [];
    getapplicantDataNewForENpa() {
        this.appDataForUdid = [];
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'Name', 'TabName__c', 'FullName__c', 'UCID__c','IsGrpExposureTxn__c' ],
            queryCriteria: ' Where Id  IN (\'' + this.appIdsForENpa.join('\', \'') + '\')'
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Applicant Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.appDataForEnpa = result.parentRecords;
                    this.appDataForEnpa.forEach(item => {
                        item['selectCheckbox'] = false;
                    })
                    console.log('Applicant Data for enpa is ', JSON.stringify(this.appDataForEnpa));
                    this.showSpinner = false;
                    this.isModalOpenENPA = true;
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Applicant Data for Enpa is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });

    }
    handleClick(event) {
        let selectedRecordId = event.target.dataset.recordid;
        let val = event.target.checked;
        let recordData = {};
        let searchDoc = this.appDataForEnpa.find((doc) => doc.Id == selectedRecordId);
        if (searchDoc) {
            console.log('searchDoc', searchDoc);
            searchDoc['selectCheckbox'] = val;
        }
        else {
            recordData['Id'] = selectedRecordId;
            recordData['selectCheckbox'] = val;
            this.appDataForEnpa.push(recordData);
        }
        console.log('All selected Records', JSON.stringify(this.appDataForEnpa));
    }


    @track showModalForUCID = false;
    handleUcid() {
        this.showModalForUCID = true;
        this.showUcidBox =true;
    }
    closeModalUcid() {
        this.showModalForUCID = false;
        this.showUcidBox =false;
        this.appDataForUdid.forEach(item => {
            item['selectCheckbox'] = false;
        });
    }

    handleClickUcid(event) {
        // console.log('record ', event.target.dataset.recordid);
        let selectedRecordId = event.target.dataset.recordid;
        let val = event.target.checked;
        let recordData = {};
        let searchDoc = this.appDataForUdid.find((doc) => doc.Id === selectedRecordId);
        if (searchDoc) {
            console.log('searchDoc', searchDoc);
            //searchDoc = { ...searchDoc, selectCheckbox: val }
            searchDoc.selectCheckbox = val;
        }
        else {
            recordData.Id = selectedRecordId;
            recordData.selectCheckbox = val;
            this.appDataForUdid.push(recordData);
        }
    }

    handleUcidCre() {
        this.showSpinner = true;
        this.showModalForUCID = false;
        let filteredData = this.appDataForUdid.filter(item => item.selectCheckbox === true);
        this.createIntForUCID(filteredData);
    }
    @track intRecordsUcid = [];
    createIntForUCID(filteredData) {
        if (filteredData && filteredData.length > 0) {
            filteredData.forEach(item => {
                let fieldsWo = {};
                fieldsWo['sobjectType'] = 'IntgMsg__c';
                fieldsWo['Name'] = 'UCIC API Token'; //serviceName;//'KYC OCR'
                fieldsWo['BU__c'] = 'HL / STL';
                fieldsWo['IsActive__c'] = true;
                fieldsWo['Svc__c'] = 'Dedupe API Token'; //serviceName;
                fieldsWo['ExecType__c'] = 'Async';
                fieldsWo['Status__c'] = 'New';
                fieldsWo['Mresp__c'] = 'Blank';
                fieldsWo['Outbound__c'] = true;
                fieldsWo['Trigger_Platform_Event__c'] = false;
                fieldsWo['RefObj__c'] = 'Applicant__c';
                fieldsWo['RefId__c'] = item.Id;
                fieldsWo['ParentRefObj__c'] = "LoanAppl__c";
                fieldsWo['ParentRefId__c'] = this.loanAppId;
                this.intRecordsUcid.push(fieldsWo);
            })
        }
        this.upsertIntRecordUcid(this.intRecordsUcid);
    }

    upsertIntRecordUcid(passedRecordsUcid) {

        console.log('Creating ucid rec');
        let tempRecs = [];
        var dedupeResDataSObject = {};
        dedupeResDataSObject.sobjectType = 'Applicant__c';
        dedupeResDataSObject.LatestyearforwhichITRisavailable__c = this._currentBlock;
        dedupeResDataSObject.Provisional_Financials_Available__c = this._provisionalOption ? this._provisionalOption : '';
        dedupeResDataSObject.Provisional_Financials_Year__c = latestYearValue ;
        dedupeResDataSObject.Id = this._applicantId;
        tempRecs.push(dedupeResDataSObject);

        upsertMultipleRecord({ params: tempRecs })
            .then((result) => {
                const evt = new ShowToastEvent({
                    title: 'Success',
                    variant: 'success',
                    message: 'Created Dedupe  Response Record',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                this.showSpinner = false;
            })
            .catch((error) => {
                console.log('Error In creating Record', error);
                this.showSpinner = false;
            });
    }


    closeModal() {
        this.isModalOpenENPA = false;
        this.showUcidBox=false;
        this.modalFlag =true;
        this.appDataForEnpa.forEach(item => {
            item['selectCheckbox'] = false;
        });
    }
    @track intRecords = [];
    handleReIntialization() {
        this.showUcidBox=false;
        this.isModalOpenENPA = false;
        //this.modalFlag =true;
        let filteredData = this.appDataForEnpa.filter(item => item.selectCheckbox === true);
        if (filteredData.length > 0) {
            this.showSpinner = true;
            filteredData.forEach(item => {
                let fields = {};
                fields['sobjectType'] = 'IntgMsg__c';
                fields['Name'] = 'ENPADeatils'; //serviceName;//'KYC OCR'
                fields['BU__c'] = 'HL / STL';
                fields['IsActive__c'] = true;
                fields['Svc__c'] = 'ENPADeatils'; //serviceName;
                fields['ExecType__c'] = 'Async';
                fields['Status__c'] = 'New';
                fields['Mresp__c'] = 'Blank';
                fields['Outbound__c'] = true;
                fields['Trigger_Platform_Event__c'] = false;
                fields['RefObj__c'] = 'Applicant__c';
                fields['RefId__c'] = item.Id;
                fields['ParentRefObj__c'] = "LoanAppl__c";
                fields['ParentRefId__c'] = this.loanAppId;
                this.intRecords.push(fields);
            })
            console.log(JSON.stringify(this.intRecords));
            this.upsertIntRecord(this.intRecords);
        } else {
            const evt = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'Please Select Applicant',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            // this.isModalOpenENPA = false;
        }


    }


    //Ucid Call

    @track showUcidBox=false;
    @track ucidValue ;
    @track showError = false;
    @track modalFlag =false;


    get ucidValueText(){
        return this.ucidValue;
    }

    get showEnterUcid(){
        return this.isGrpTxnY === true && this.showUcidBox === false
    }
    get showUcidBoxNGrpTxn(){
        console.log('this.equal isGrpTxnY ==',this.isGrpTxnY)
        console.log('this.equal ithis.showUcidBox ==',this.showUcidBox) 
        console.log('this.equal this.modalFlag ==',this.modalFlag)
        if(this.isGrpTxnY === true && this.showUcidBox === true && this.modalFlag === false){


            return true
        }else{
            return false
        }
    }

    handleUcidChange(event){
        
        console.log('ucid value is ::',this.ucidValue)

        this.ucidValue = event.target.value;

        // // Validate the field
        // const inputField = event.target;
    
        // // Check if the UCID length is correct
        // if (this.ucidValue.length <= 8 || !/^[A-Za-z0-9]{12}$/.test(this.ucidValue)) {
        //     inputField.setCustomValidity("Please enter a valid UCID.");
        // } else {
        //     inputField.setCustomValidity(''); 
        // }
    
        // // Report validity so the form shows error messages
        // inputField.reportValidity();

    }


    handleUcidCall() {  
        this.showUcidBox=true;
        this.modalFlag = false;

        console.log('make true this.showUcidBox :',this.showUcidBox)
        console.log('make true this.isModalOpenENPA :',this.isModalOpenENPA)
     //   this.isModalOpenENPA = false;


        // if (!this.showError && this.ucid.length === 12) {
        //     // Process the UCID (e.g., make an API call, save data, etc.)
        //     console.log('UCID submitted:', this.ucid);
        // } else {
        //     this.showError = true;  // Ensure error is shown if UCID is invalid
        // }
    }
    handleUcidBackBtn() {  
        this.showUcidBox=false;
        this.modalFlag === false
    }
    @track dedupeRespRecords=[];
    
    handleUcidCallUpsert() {
        console.log('handleUcidCallUpsert called ==', this.ucidValue);
        console.log('this.enpaRecordTypeId ==',this.enpaRecordTypeId);
        if (this.ucidValue && this.ucidValue.length <=8) { 
            console.log('UCID length is valid');
    
            this.showError = false;
            if (this.ucidValue) {
                console.log('this.primaryApplId ==', this.primaryApplId);
                console.log('Creating dedupe with UCID ==', this.ucidValue);
                let fields = {
                    'sobjectType': 'DedupeResponse__c',
                    'Applicant__c': this.primaryApplId,
                    'LoanAppln__c': this.loanAppId,
                    'UCID__c': this.ucidValue,  
                    'RecordTypeId': this.enpaRecordTypeId,
                    'GroupEnpa__c': true,
                    'IsLatest__c' : true 
                };
    
                this.dedupeRespRecords.push(fields);
                upsertMultipleRecord({ params: this.dedupeRespRecords })
                    .then((result) => {
                        console.log('Dedupe record created successfully');
    
                        let arrIntMsg = [];
                        let fieldsInt = {
                            'sobjectType': 'IntgMsg__c',
                            'Name': 'ENPADeatils',
                            'BU__c': 'HL / STL',
                            'IsActive__c': true,
                            'Svc__c': 'ENPADeatils',
                            'ExecType__c': 'Async',
                            'Status__c': 'New',
                            'Mresp__c': 'Blank',
                            'Outbound__c': true,
                            'Trigger_Platform_Event__c': false,
                            'RefObj__c': 'DedupeResponse__c',
                            'RefId__c': result[0].Id,   
                            'ParentRefObj__c': "Applicant__c",
                            'ParentRefId__c': this.primaryApplId
                        };
                        arrIntMsg.push(fieldsInt);
                        upsertMultipleRecord({ params: arrIntMsg })
                            .then((result) => {
                                const evt1 = new ShowToastEvent({
                                    title: 'Success',
                                    variant: 'success',
                                    message: 'ENPA API has been Initiated Successfully',
                                    mode: 'sticky'
                                });
                                this.dispatchEvent(evt1);
                                console.log('Integration message record created successfully');
                                arrIntMsg = [];
    
                                // Close modal and hide spinner
                                this.isModalOpenENPA = false;
                                this.showSpinner = false;
                                this.showError = false;
                            })
                            .catch((error) => {
                                console.log('Error creating Integration Message Record:', error);
                                this.showSpinner = false;
                                this.showError = false;
                            });
    
                        // Clear dedupe record array and hide modal/spinner
                        this.dedupeRespRecords = [];
                        this.isModalOpenENPA = false;
                        this.showSpinner = false;
                    })
                    .catch((error) => {
                        console.log('Error creating Dedupe Record:', error);
                        this.showSpinner = false;
                    });
            } else {
                this.showError = true;  
                console.log('UCID is not valid');
            }
    
            this.ucidValue = ''; 
        }else{
            const evt2 = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'Ucid is Mandatory , Kindly Enter Ucid',
                mode: 'sticky'
            });
            this.dispatchEvent(evt2);
            console.log('Invalid UCID length:', this.ucidValue.length);
            this.showError = true;  
            this.ucidValue = '';  

            

        }
    }
    

    upsertIntRecord(intRecords) {
        console.log('int msgs records ', JSON.stringify(intRecords));
        upsertMultipleRecord({ params: intRecords })
            .then((result) => {
                 const evt = new ShowToastEvent({
                    title: 'Success',
                    variant: 'success',
                    message: this.label.DedupeVerIntMsg_Save_SuccessMessage,
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                this.intRecords = [];
                this.appDataForEnpa.forEach(item => {
                    item['selectCheckbox'] = false;
                });
                this.isModalOpenENPA = false;
                this.showSpinner = false;
                // this.fireCustomEvent(null, null, null, false);
            })
            .catch((error) => {
                console.log('Error In creating Record', error);
                this.showSpinner = false;
                // this.fireCustomEvent("Error", "error", "Error occured in upsertMultipleRecord " + error, false);
            });
    }



    //Create Dedupe Res For Ucid
    upsertUcidRecord(intRecords) {
        console.log('int upsertUcidRecord records ', JSON.stringify(intRecords));
        upsertMultipleRecord({ params: intRecords })
            .then((result) => {
                const evt = new ShowToastEvent({
                    title: 'Success',
                    variant: 'success',
                    message: this.label.DedupeVerIntMsg_Save_SuccessMessage,
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                this.intRecords = [];
                this.appDataForEnpa.forEach(item => {
                    item['selectCheckbox'] = false;
                });
                this.isModalOpenENPA = false;
                this.showSpinner = false;
            })
            .catch((error) => {
                console.log('Error In creating Record', error);
                this.showSpinner = false;
            });
    }

    handleCustomEvent(event) {
        this.isModalOpen = false;
        this.isModalOpenENPA = false;
        let spinnerValue = event.detail.spinner;
        if (spinnerValue) {
            this.showSpinner = true;
        } else {
            this.showSpinner = false;
        }
        let titleVal = event.detail.title;
        let variantVal = event.detail.variant;
        let messageVal = event.detail.message;
        if (titleVal && variantVal && messageVal) {
            const evt = new ShowToastEvent({
                title: titleVal,
                variant: variantVal,
                message: messageVal
            });
            this.dispatchEvent(evt);
            this.getMatchingCriteriaData();
        }
    }
    handleChange(event) {
        let val = event.target.value;
        let deduperRecordId = event.target.dataset.recordid;
        let nameVal = event.target.name;
        let obj = this.dedupeData.find(item => item.Id === deduperRecordId);
        if (obj) {
            console.log('obj is ', JSON.stringify(obj));
            obj[nameVal] = val.toUpperCase();
            obj['isChanged'] = true;
            //this.callEnpaMethod();
        }
    }
    handlePicklistValues(event) {
        
        let val = event.detail.val;
        let deduperRecordId = event.detail.recordid;
        let nameVal = event.detail.nameVal;
        console.log('val is in dedupeverification ', val, 'deduperRecordId is ', deduperRecordId, ' name is ', nameVal);
        let obj = this.dedupeData.find(item => item.Id === deduperRecordId);
        if (obj) {
            console.log('obj is ', JSON.stringify(obj));
            obj[nameVal] = val;
            obj['isChanged'] = true;
            console.log('this.dedupeData ', JSON.stringify(this.dedupeData));
            if (nameVal === 'IntnlDeduRelevance__c') {
                this.callEnpaMethod();
            }
        }
        this.makeFieldsRequired();
    }
    required=true;
    makeFieldsRequired() {
        this.dedupeData.forEach(item => {
            if (item.IntnlDeduRelevance__c === 'Accurate Match found') {
                item.isRequired = true;
            } else {
                item.isRequired = false;
            }
        })
        console.log('this.dedupeData ', JSON.stringify(this.dedupeData));
    }
    handleEnpaDataChange(event) {
        console.log('enpa data indedupeverification component is ', JSON.stringify(this.enpaData));
        let val = event.detail.val;
        let enpaRecordId = event.detail.recordid;
        let nameVal = event.detail.nameVal;
        console.log('val is in dedupeverification ', val, 'enpaRecordId is ', enpaRecordId, ' name is ', nameVal);
        let obj = this.enpaData.find(item => item.Id === enpaRecordId);
        if (obj) {
            console.log('obj is ', JSON.stringify(obj));
            obj[nameVal] = val;
            obj['isChanged'] = true;
            console.log('this.enpadata upadted one ', JSON.stringify(this.enpaData));
            // this.callEnpaMethod();
        }

    }
    callEnpaMethod() {
        this.enpaData = [];
        let AppIdsForEnpa = [];
        this.dedupeData.forEach(item => {
            if (item.IntnlDeduRelevance__c === 'Accurate Match found') {
                AppIdsForEnpa.push(item.Applicant__c)
            }
        })
        if (AppIdsForEnpa.length > 0) {
            this.showEnpaData = true;
            console.log('loanAppIdsForEnpa ', AppIdsForEnpa);
            console.log('dedupeData is ', this.dedupeData);

            let paramsLoanApp = {
                ParentObjectName: 'DedupeResponse__c',
                parentObjFields: ['Id', 'LoanAppln__r.Name', 'AppId__c', 'AUM__c', 'LoanType__c', 'Lan__c', 'UCID__c', 'CustomerName__c', 'Applicant__c', 'LoanDisbDate__c', 'LoanAmount__c', 'Tenure__c', 'SystemDPD__c', 'DPD__c', 'FinalAssetClass__c', 'NPADate__c', 'SecuritisationStatus__c', 'Internal_Top_up_Original_loan__c', 'Loan_to_be_closed_internally__c', 'IsPDDpending__c', 'LoantobeconsideredinLTVcal__c', 'Loantobelinkedwithproposedloan__c','FraudFlag__c','WriteOffFlag__c','WriteoffDate__c','Settled__c','SettledDate__c'],
                // queryCriteria: ' where LoanAppln__c = \'' + loanAppIdsForEnpa + '\' AND recordtype.name = \'' + this.enpaRecordTypeName + '\' AND IsLatest__c = true'
                queryCriteria: ` where Applicant__c IN ('${AppIdsForEnpa.join("','")}') AND recordtype.name = '${this.enpaRecordTypeName}' AND LoanAppln__c = '${this.loanAppId}' AND IsLatest__c = true ORDER BY Applicant__r.ApplType__c`
            }

            getSobjectData({ params: paramsLoanApp })
                .then((result) => {
                    console.log('result of ENPA details is', JSON.stringify(result));
                    if (result.parentRecords && result.parentRecords.length > 0) {
                        this.enpaData = result.parentRecords;

                        this.enpaData.forEach(row1 => {
                            if(row1.LoanDisbDate__c){
                        const dateTime1 = new Date(row1.LoanDisbDate__c);
                        const formattedDate1 = formattedDate(dateTime1); 
                        const disbDate1 = `${formattedDate1}`;
                        row1.LoanDisbDate__c = disbDate1;
                            }
                        if(row1.NPADate__c){
                            const dateTime2 = new Date(row1.NPADate__c);
                            const formattedDate2 = formattedDate(dateTime2); 
                            const disbDate2 = `${formattedDate2}`;
                            row1.NPADate__c = disbDate2;
                        }

                        if(row1.WriteoffDate__c){
                            const dateTime2 = new Date(row1.WriteoffDate__c);
                            const formattedDate2 = formattedDate(dateTime2); 
                            const disbDate2 = `${formattedDate2}`;
                            row1.WriteoffDate__c = disbDate2;
                        }

                        if(row1.SettledDate__c){
                            const dateTime2 = new Date(row1.SettledDate__c);
                            const formattedDate2 = formattedDate(dateTime2); 
                            const disbDate2 = `${formattedDate2}`;
                            row1.SettledDate__c = disbDate2;
                        }

                });

                        console.log('this.enpaData ', this.enpaData);
                    }
                })
                .catch((error) => {
                    console.log('Error In getting ENPA Data', error);
                });
        } else {
            this.showEnpaData = false;
        }
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

    handleRefreshClick() {
        this.showSpinner = true;
        setTimeout(() => {
            this.showSpinner = false;
            this.getMatchingCriteriaData();
            this.callEnpaMethod();
            this.getapplicantData();
        }, 6000);

    }

    handleSaveThroughLms(values) {
        console.log('values to save through Lms ', JSON.stringify(values));
        this.showSpinner = true;
        // this.handlevSubmit(values.validateBeforeSave);
        this.handleSave(values.validateBeforeSave);

    }

    handleSave(validate) {
        console.log('valid ', validate);
        if (validate) {
            let valid = this.checkReportValidity();
            console.log('valid ', valid);
            if (valid) {
                let requiredData = true;
                if (this.enpaData && this.enpaData.length > 0) {
                    requiredData = this.template.querySelector('c-enpa-verification').validateForm();
                }
                console.log('RequireData>>>>>' + requiredData);
                if (!requiredData) {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: 'Please fill Required Data for ENPA',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                    this.showSpinner = false;
                } else {
                    this.handlevSubmit();
                }
            }
            else {
                let j=0;
                for (let i = 0; i < this.dedupeData.length; i++) {                    
                    let record = this.dedupeData[i];    
                    console.log('record.IntnlDeduRelevance__c',record.IntnlDeduRelevance__c)                
                    if(record.IntnlDeduRelevance__c=='Inaccurate match found'
                    || (record.IntnlDeduRelevance__c=='Accurate Match found' && record.IntrnlDeduperes__c!=undefined && (record.IntnalDeduperesremark__c!=undefined  && record.IntnalDeduperesremark__c!=""))){
                    // || (record.IntnlDeduRelevance__c=='Accurate Match found' && record.IntrnlDeduperes__c!=undefined && record.IntnalDeduperesremark__c.length!= )
                       
                    }
                    else{
                        // if(record.IntnlDeduRelevance__c=='Accurate Match found' && (!record.IntrnlDeduperes__c || !record.IntnalDeduperesremark__c) ){
                            j++
                        
                        
                    }
                }
                if(j==0){
                        let requiredData = true;
                    if (this.enpaData && this.enpaData.length > 0) {
                        requiredData = this.template.querySelector('c-enpa-verification').validateForm();
                    }
                    console.log('RequireData>>>>>' + requiredData);
                    if (!requiredData) {
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            variant: 'error',
                            message: 'Please fill Required Data for ENPA',
                            mode: 'sticky'
                        });
                        this.dispatchEvent(evt);
                        this.showSpinner = false;
                    } else {
                        this.handlevSubmit();
                    }
                
                }
                else{
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: this.label.DeDupVerf_ReqFields_ErrorMessage,
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                    
                }
                this.showSpinner = false;
            }
        } else {
            this.handlevSubmit();
        }
    }
    handlevSubmit(validate) {
        console.log('valid ', validate);
        let newarray = [...this.dedupeData, ...this.enpaData];
        console.log('newarray is =========>', JSON.stringify(newarray));
        let filterdData = newarray.filter(item => item.isChanged === true);
        console.log('filterdData is =========>', JSON.stringify(filterdData));

        if (filterdData && Array.isArray(filterdData)) {
            console.log('tetsingggg')
            filterdData.forEach(item => {
                delete item.LatestReportTime__c;
                delete item.PastAppDate__c;
                delete item.LoanDisbDate__c;
                delete item.NPADate__c;
            });
        }
        
        upsertMultipleRecord({ params: filterdData })
            .then((result) => {
                console.log('Result after Saving Dedupe Data is ', JSON.stringify(result));
                // result.forEach(item => {
                //     this.dedupeResponseIds.push(item.Id);
                // })
                console.log('dedupeResponseIds after creating Int Msgs is ', JSON.stringify(this.dedupeResponseIds));
                this.showSpinner = false;
                const evt = new ShowToastEvent({
                    title: 'Success',
                    variant: 'success',
                    message: this.label.DeDupVerf_Save_SuccessMessage,
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                this.getMatchingCriteriaData();
                filterdData = [];
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In creating Record', JSON.stringify(error.body));
                // this.fireCustomEvent("Error", "error", "Error occured in accepting File  " + error, false);
            });
    }

    @track hasError = false;
    checkReportValidity() {
        let isValid = true
        this.template.querySelectorAll('c-dedupe-display-value').forEach(element => {
            if (element.reportValidity()) {
                console.log('c-dedupe-display-value');
                console.log('element if--' + element.value);
               
            } else {
                isValid = false;
                console.log('element else--' + element.value);
            }
        });
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed lightning input');
                console.log('element if--', element.value);
            } else {
                isValid = false;
            }
        });
        console.log('inside parent isValid',isValid)
        return isValid;
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