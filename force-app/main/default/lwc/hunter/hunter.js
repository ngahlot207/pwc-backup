import { LightningElement, wire, api, track } from 'lwc';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
//Apex Methods
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getSobjectDataWithoutCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjDtwithFltrRelatedRecordsWithoutCache';


import formFactorPropertyName from "@salesforce/client/formFactor";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import { formattedDateTimeWithoutSeconds } from 'c/dateUtility';
import Id from '@salesforce/user/Id';

//custome labels
import DeDupVerf_ReqFields_ErrorMessage from '@salesforce/label/c.DeDupVerf_ReqFields_ErrorMessage';
import WatchInvestor_Save_SuccessMessage from '@salesforce/label/c.WatchInvestor_Save_SuccessMessage';
export default class Hunter extends LightningElement {
    @api loanAppId = 'a08C4000007Kw2EIAS';
    @api hasEditAccess = false;


    customLabel = {
        DeDupVerf_ReqFields_ErrorMessage,
        WatchInvestor_Save_SuccessMessage

    }

    enableInfiniteScrolling = true;
    enableBatchLoading = true;
    @track formFactor = formFactorPropertyName;
    @track desktopBoolean = false;
    @track phoneBolean = false;
    @track disableReintiate = false;
    @track isReadOnly = false;
    @track queryParam = [];
    @track showSpinner = false;
    @track loanStage;
    @track loanSubstage;
    @track params = {};
    @track paramsAppl = {};
    @track activeSection = ["A"];
    @track hunterStaWhereMatchFondOptions = [];

    @track columnsDataForTable = [
        {
            "label": "Request time",
            "fieldName": "ReqTime__c",
            "type": "Date/Time",
            "Editable": false
        },
        {
            "label": "Response time",
            "fieldName": "ResTime__c",
            "type": "Date/Time",
            "Editable": false
        },

        {
            "label": "Hunter match status",
            "fieldName": "HunMatchSta__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Client Reference Id",
            "fieldName": "ClientReferenceId__c",
            "type": "text",
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
    @track queryData = 'SELECT ReqTime__c,ResTime__c,HunMatchSta__c,ClientReferenceId__c,IntegrationStatus__c,IntegrationErrorMessage__c,Id FROM HunterVer__c WHERE LoanAplcn__c =: loanAppId AND IsLatest__c =: isActiveValue';

    @track recordTypeId;
    @wire(getObjectInfo, { objectApiName: 'HunterVer__c' })
    objectInfo({ data, error }) {
        if (data) {
            // Retrieve the default record type ID
            this.recordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            console.error('Error fetching object info', error);
        }
    }

    @wire(getPicklistValuesByRecordType, {
        objectApiName: 'HunterVer__c',
        recordTypeId: '$recordTypeId',
    })
    hunterPicklistHandler({ data, error }) {
        if (data) {
            console.log('data in PicklistHandler', JSON.stringify(data));
            this.hunterStaWhereMatchFondOptions = [...this.generatePicklist(data.picklistFieldValues.HunterStatWhereMatchFound__c)]
        }
        if (error) {
            console.error('error im getting picklist values are', error)
        }
    }
    generatePicklist(data) {
        console.log('data in generatePicklist ', JSON.stringify(data));
        if (data.values) {
            return data.values.map(item => ({ label: item.label, value: item.value }))
        }
        return null;
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
        // let paramVal = [];
        // paramVal.push({ key: 'loanAppId', value: this.loanAppId });
        // paramVal.push({ key: 'isActiveValue', value: true });
        // this.queryParam = paramVal;
        // console.log('map data:::', this.queryParam);
        // this.params = {
        //     columnsData: this.columnsDataForTable,
        //     queryParams: this.queryParam,
        //     query: this.queryData
        // }

        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }
        this.disableReintiate = this.isReadOnly;
        this.getProduct();
        // this.getRole();

        // console.log('######this.loanproducttt', this.loanProductType);
        // console.log('######this.employeeroleee', this.this.employeeRole);
        // if ((this.loanProductType == 'Business Loan' || this.loanProductType == 'Personal Loan') && this.employeeRole != 'UW' && this.employeeRole != 'ACM' && this.employeeRole != 'RCM' && this.employeeRole != 'ZCM' && this.employeeRole != 'NCM' && this.employeeRole != 'CH') {
        //     this.blplView = true;
        // }
        // console.log('########this.blplView', this.blplView);
        this.getApiRetriggerTrackerData();
        this.getLoanApplicationData();
        this.scribeToMessageChannel();
    }

    @track loanProductType;
    blplView = false;
    @track userId = Id;
    @track employeeRole;
    getProduct(){
        let parameterLoanApplication = {
            ParentObjectName: 'LoanAppl__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'Product__c'],
            childObjFields: [],
            queryCriteria: ' where Id = \'' + this.loanAppId + '\''
        }
        let loanProductPromise = getSobjectData({ params: parameterLoanApplication })
            .then((result) => {
                
                console.log('result is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.loanProductType = result.parentRecords[0].Product__c ? result.parentRecords[0].Product__c : null;
                    console.log('????????this.productType ', this.loanProductType);
                    
                }              
            })
            .catch((error) => {

                console.log("error occured in product type", error);

            });

            let paramsLoanApp = {
                ParentObjectName: 'TeamHierarchy__c',
                parentObjFields: ['Id', 'EmpRole__c', 'Employee__c'],
                queryCriteria: ' where Employee__c = \'' + this.userId + '\''
            }
            let employeeRolePromise = getSobjectData({ params: paramsLoanApp })
                .then((result) => {
                    console.log('result is get Role ', JSON.stringify(result));
                    if (result.parentRecords) {
                        this.employeeRole = result.parentRecords[0].EmpRole__c;
                        console.log('???????this.employeeRole is ', this.employeeRole);
                        console.log('this.user id is ',this.userId);
                        
                        
                    }
                })
                .catch((error) => {
    
                    //this.showSpinner = false;
                    console.log("error occured in employeeRole", error);
    
                });

                // Use Promise.all() to wait for both promises
    Promise.all([loanProductPromise, employeeRolePromise]).then(() => {
        // Now both loanProductType and employeeRole are available
        if ((this.loanProductType === 'Business Loan' || this.loanProductType === 'Personal Loan') &&
            (this.loanStage !== 'UnderWriting' && this.loanStage !== 'Post Sanction')){  //LAK-10343
            // && this.employeeRole !== 'UW' && this.employeeRole !== 'ACM' && this.employeeRole !== 'RCM' &&
            // this.employeeRole !== 'ZCM' && this.employeeRole !== 'NCM' && this.employeeRole !== 'CH') {
            this.blplView = true;
        }

        console.log('??????blplView after both conditions:', this.blplView);
    }).catch((error) => {
        console.log("Error occurred in Promise.all", error);
    });

                // console.log('??????this.blplView before', this.blplView);
                // // if ((this.loanProductType == 'Business Loan' || this.loanProductType == 'Personal Loan') && this.employeeRole != 'UW' && this.employeeRole != 'ACM' && this.employeeRole != 'RCM' && this.employeeRole != 'ZCM' && this.employeeRole != 'NCM' && this.employeeRole != 'CH') {
                // //     this.blplView = true;
                // // }
                // if ((this.loanProductType == 'Business Loan' || this.loanProductType == 'Personal Loan')) {
                //     this.blplView = true;
                // }
                // console.log('??????this.blplView after', this.blplView);

            

    }

    // @track userId = Id;
    // @track employeeRole;
    // getRole() {
    //     let paramsLoanApp = {
    //         ParentObjectName: 'TeamHierarchy__c',
    //         parentObjFields: ['Id', 'EmpRole__c', 'Employee__c'],
    //         queryCriteria: ' where Employee__c = \'' + this.userId + '\''
    //     }
    //     getSobjectData({ params: paramsLoanApp })
    //         .then((result) => {
    //             console.log('result is get Role ', JSON.stringify(result));
    //             if (result.parentRecords) {
    //                 this.employeeRole = result.parentRecords[0].EmpRole__c;
    //                 console.log('this.employeeRole is ', this.employeeRole);
    //                 console.log('this.user id is ',this.userId);
                    
                    
    //             }
    //         })
    //         .catch((error) => {

    //             //this.showSpinner = false;
    //             console.log("error occured in employeeRole", error);

    //         });
    // }

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
                    this.loanSubstage = result.parentRecords[0].SubStage__c;
                    this.getHunterData();
                }

            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Loan Application Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    @track hunterData = [];
    getHunterData() {
        this.showSpinner = true;
        let params = {
            ParentObjectName: 'HunterVer__c',
            parentObjFields: ['ReqTime__c', 'ResTime__c', 'HunMatchSta__c', 'ClientReferenceId__c', 'IntegrationStatus__c', 'IntegrationErrorMessage__c', 'Id', 'Rem__c', 'RCUmanagerfeedback__c', 'HunterStatWhereMatchFound__c','FraudStatusDescription__c','WorkStatusDescription__c'],
            queryCriteria: ' where LoanAplcn__c = \'' + this.loanAppId + '\' AND IsLatest__c = true'
        }
        getSobjectData({ params: params })
            .then((result) => {
                // this.showSpinner = true;
                console.log('Loan Application Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    result.parentRecords.forEach(item => {
                        if (item.HunMatchSta__c && item.HunMatchSta__c.toLowerCase() === 'match') {
                            item.required = true;
                        } else {
                            item.required = false;
                        }
                        // this.isReadOnly = true;
                        if ((this.loanStage === 'DDE' || this.loanStage === 'UnderWriting' || this.loanStage === 'Post Sanction') && !this.isReadOnly) {
                            item.isReadOnly = false;
                        } else {
                            item.isReadOnly = true;
                        }
                        if (item.ReqTime__c) {
                            item.ReqTime__c = formattedDateTimeWithoutSeconds(item.ReqTime__c);
                        }
                        if (item.ResTime__c) {
                            item.ResTime__c = formattedDateTimeWithoutSeconds(item.ResTime__c);
                        }
                    })
                    this.hunterData = result.parentRecords;
                    console.log('this.hunterData ', this.hunterData);
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Hunter Verification Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    @track applIds = [];
    @track apiRetrgrTrcrData = [];
    getApiRetriggerTrackerData() {
        let apiName = 'Hunter Token';
        console.log('loanappId in Reintiate component', this.loanAppId);
        let paramsLoanApp = {
            ParentObjectName: 'APIRetriggerTracker__c',
            parentObjFields: ['Id', 'App__c', 'LoanApp__c', 'LoanApp__r.Id', 'IsProcessed__c', 'App__r.TabName__c', 'App__r.Id'],
            queryCriteria: ' where IsProcessed__c = false AND LoanApp__c = \'' + this.loanAppId + '\' AND APIName__c = \'' + apiName + '\''
        }

        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('apiRetrgrTrcrData is', JSON.stringify(result));
                this.apiRetrgrTrcrData = [];
                if (result.parentRecords && result.parentRecords.length > 0) {
                    result.parentRecords.forEach(item => {
                        if (item.LoanApp__c) {
                            this.apiRetrgrTrcrData.push(item.LoanApp__r.Id);
                        }
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

    @track noHunterData = false; //LAK-8458
    getExpiApiData() {
        // let arra = ['Watchout'];
        let paramsLoanApp = {
            ParentObjectName: 'HunterVer__c',
            parentObjFields: ['Id', 'LoanAplcn__c', 'LoanAplcn__r.Id', 'ExpiryDate__c', 'Appl__c', 'Appl__r.FullName__c', 'Appl__r.Id'],
            queryCriteria: ' where IsLatest__c = true AND LoanAplcn__c = \'' + this.loanAppId + '\''
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
                                    this.apiRetrgrTrcrData.push(item.LoanAplcn__r.Id);
                                }
                            }
                        }
                    })
                }
                //LAK-8458
                 else {
                    this.noHunterData = true;
                }
                //  else {
                //     this.showSpinner = false;
                // }
                this.getApiCallOutData();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('exp result getting error= ', error);
            });
    }

    getApiCallOutData() {
        let apiName = ['Hunter Token', 'Hunter API'];
        let params = {
            ParentObjectName: 'APICoutTrckr__c',
            parentObjFields: ['Id', 'LtstRespCode__c', 'LAN__c', 'LAN__r.Id', 'APIName__c', 'RefId__c'],
            // queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND ApplType__c = \'' + appType + '\''
            queryCriteria: ' Where LAN__c = \'' + this.loanAppId + '\'  AND APIName__c  IN (\'' + apiName.join('\', \'') + '\')'
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Api CallOutData is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    result.parentRecords.forEach(item => {
                        if (item.LtstRespCode__c != 'Success') {
                            this.apiRetrgrTrcrData.push(item.LAN__r.Id);
                        }
                    })
                } else {
                    this.showSpinner = false;
                }

                this.apiRetrgrTrcrData = [...new Set(this.apiRetrgrTrcrData)];
                this.applIds = [...this.apiRetrgrTrcrData];
                if (this.applIds.length === 0) {
                    this.disableReintiate = true;
                }
                if (this.isReadOnly) {
                    this.disableReintiate = true;
                }
                //LAK-8458
                if(this.noHunterData){
                    this.disableReintiate = false;
                }
                console.log('this.apiRetrgrTrcrData after', this.apiRetrgrTrcrData);
                // this.getAppWithCallOutDatas();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('exp result getting error= ', error);
            });
    }
    getAppWithCallOutData() {
        let apiName = 'Hunter Token';
        let variab = 'Success';
        let paramsLoanApp = {
            ParentObjectName: 'Applicant__c',
            ChildObjectRelName: 'API_Callout_Trackers__r',
            parentObjFields: ['Id', 'LoanAppln__c', 'LoanAppln__r.Id'],
            childObjFields: ['Id', 'LtstRespCode__c', 'APIName__c', 'Appl__r.Id', 'LAN__c', 'LAN__r.Id'],
            queryCriteriaForChild: ' where LAN__c = \'' + this.loanAppId + '\' AND APIName__c = \'' + apiName + '\'',
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\''

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
                                    if (ite.LAN__c) {
                                        this.apiRetrgrTrcrData.push(ite.LAN__r.Id);
                                        //this.applIds.add(item.Appl__r.Id);
                                    }
                                }
                            })
                        } else {
                            this.apiRetrgrTrcrData.push(item.parentRecord.LoanAppln__r.Id);
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
                console.log('this.apiRetrgrTrcrData after', this.apiRetrgrTrcrData);
                if (result.error) {
                    this.showSpinner = false;
                    console.error('apiRetrgrTrcrData result getting error=', result.error);
                }
            })
    }
    // getCalloutData() {
    //     console.log('loanappId in Reintiate component', this.loanAppId);
    //     let apiName = 'ScreeningWachout';
    //     let variab = 'Success';
    //     let paramsLoanApp = {
    //         ParentObjectName: 'APICoutTrckr__c',
    //         parentObjFields: ['Id', 'LtstRespCode__c', 'Appl__c', 'Appl__r.Id', 'LAN__c'],
    //         queryCriteria: ' where LAN__c = \'' + this.loanAppId + '\' AND APIName__c = \'' + apiName + '\' AND LtstRespCode__c != \'' + variab + '\''
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

    RationalRemarks;
    handleRationalChange(event) {
        this.RationalRemarks = event.target.value;
    }
    handleIntialization() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    intRecords = [];
    creatIntMsgRecord() {
        this.isModalOpen = false;
        this.showSpinner = true;
        let fields = {};
        fields['sobjectType'] = 'IntgMsg__c';
        fields['Name'] = 'Hunter Token'; //serviceName;//'KYC OCR'
        fields['BU__c'] = 'HL / STL';
        fields['IsActive__c'] = true;
        fields['Svc__c'] = 'Hunter Token'; //serviceName;
        fields['ExecType__c'] = 'Async';
        fields['Status__c'] = 'New';
        fields['Mresp__c'] = 'Blank';
        fields['Outbound__c'] = true;
        fields['Trigger_Platform_Event__c'] = false;
        fields['ParentRefObj__c'] = "LoanAppl__c";
        fields['ParentRefId__c'] = this.loanAppId;
        // if (this.apiRetrgrTrcrData.length === filteredData.length) {
        fields['RefObj__c'] = 'LoanAppl__c';
        fields['RefId__c'] = this.loanAppId;
        fields['RetriRatinal__c'] = this.RationalRemarks;
        //     let array2 = [];
        //     filteredData.forEach(item => {
        //         array2.push(item.RationalRemarks);
        //     })
        //     console.log('array2 is ', JSON.stringify(array2));
        //     let rationalRem = array2.join(",");
        //     fields['RetriRatinal__c'] = rationalRem;
        // } else {
        //     fields['RefObj__c'] = 'Applicant__c';
        //     let array = [];
        //     let array2 = [];
        //     filteredData.forEach(item => {
        //         array.push(item.Id);
        //         array2.push(item.RationalRemarks);
        //     })
        //     console.log('array is ', JSON.stringify(array));
        //     let refIds = array.join(",");
        //     let rationalRem = array2.join(",");
        //     fields['RefId__c'] = refIds;
        //     fields['RetriRatinal__c'] = rationalRem;
        // }
        this.intRecords.push(fields);
        this.upsertIntRecord(this.intRecords);
    }

    intMsgIds = [];
    upsertIntRecord(intRecords) {
        console.log('int msgs records ', JSON.stringify(intRecords));
        upsertMultipleRecord({ params: intRecords })
            .then((result) => {
                console.log('Result after creating Int Msgs is ', JSON.stringify(result));
                result.forEach(item => {
                    this.intMsgIds.push(item.Id);
                })
                console.log('intMsgIds after creating Int Msgs is ', JSON.stringify(this.intMsgIds));


                // let child = this.template.querySelector('c-dynamic-datatable');
                // if (child) {
                console.log('before');
                setTimeout(() => {
                    this.showSpinner = false;
                    this.getHunterData();
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        variant: 'success',
                        message: 'Re-Initiated Successfully, Please Click on Refresh Button to See Details on Table'
                    });
                    this.dispatchEvent(evt);
                }, 6000);
                this.RationalRemarks = '';
                console.log('after');
                // this.showSpinner = false;
                // }
                // this.fireCustomEvent("Success", "success", "Re-Initiated Successfully, Please Click on Refresh Button to See Details on Table", false);
                this.intRecords = [];

            })
            .catch((error) => {
                console.log('Error In creating Record', error);
                this.showSpinner = false;
                // this.fireCustomEvent("Error", "error", "Error occured in upsertMultipleRecord " + error, false);
            });
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
        // const childComponent = this.template.querySelector('[data-id="childComponent"]');
        // if (childComponent) {
        //     console.log('before');
        //     childComponent.handleGettingData();
        //     console.log('after');
        // }
        this.showSpinner = true;

        // let child = this.template.querySelector('c-dynamic-datatable');
        // if (child) {
        //     console.log('before');
        setTimeout(() => {
            this.showSpinner = false;
            this.getHunterData();
            this.getApiRetriggerTrackerData();
        }, 6000);
        console.log('after');
        // this.showSpinner = false;
        // }
    }

    @track saveData = [];
    handlePicklistValues(event) {
        let val = event.detail.val;
        let hunterRecordId = event.detail.recordid;
        let nameVal = event.detail.nameVal;
        console.log('val is in hunter ', val, 'hunter id is ', hunterRecordId, ' name is ', nameVal);
        let obj = this.hunterData.find(item => item.Id === hunterRecordId);
        if (obj) {
            console.log('obj is ', JSON.stringify(obj));
            obj[nameVal] = val;
            obj.isChanged = true;
        } else {
            let objNew = {};
            objNew.Id = hunterRecordId;
            objNew[nameVal] = val;
            objNew.isChanged = true;
            this.saveData.push(objNew);
        }
        console.log('this.savedata  ', this.saveData);
        console.log('this.hunterdata  ', this.hunterData);
        // this.makeFieldsRequired();
    }

    handleChange(event) {
        let val = event.target.value;
        let hunterRecordId = event.target.dataset.recordid;
        let nameVal = event.target.name;
        console.log('val is ', val, 'hunterRecordId is ', hunterRecordId, ' name is ', nameVal);
        let obj = this.hunterData.find(item => item.Id === hunterRecordId);
        if (obj) {
            console.log('obj is ', JSON.stringify(obj));
            obj[nameVal] = val.toUpperCase();
            obj.isChanged = true;
        } else {
            let objNew = {};
            objNew.Id = hunterRecordId;
            objNew.nameVal = val.toUpperCase();
            objNew.isChanged = true;
            this.saveData.push(objNew);
        }
        console.log('this.savedata  ', this.saveData);
        console.log('this.hunterdata  ', this.hunterData);
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
        console.log('values to save through Lms ', JSON.stringify(values));
        if (values.validateBeforeSave) {
            let valid = this.checkReportValidity();
            if (valid) {
                this.handlevSubmit(values.validateBeforeSave);
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
        }
    }

    handlevSubmit(validate) {
        console.log('valid ', validate);
        let filterdData = this.hunterData.filter(item => item.isChanged === true);
        console.log('filterdData is =========>', JSON.stringify(filterdData));
        if (filterdData && filterdData.length > 0) {
            this.showSpinner = true;
            filterdData.forEach(item => {
                delete item.ResTime__c;
                delete item.ReqTime__c;
            })
            upsertMultipleRecord({ params: filterdData })
                .then((result) => {
                    console.log('Result after updating hunter verification records is ', JSON.stringify(result));
                    this.showSpinner = false;
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        variant: 'success',
                        message: this.customLabel.WatchInvestor_Save_SuccessMessage,
                        mode: 'sticky'

                    });
                    this.dispatchEvent(evt);
                    this.getHunterData();
                    filterdData = [];

                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log('Error In updating hunter Records', error);
                    // this.fireCustomEvent("Error", "error", "Error occured in accepting File  " + error, false);
                });
        }

    }

    checkReportValidity() {
        let isValid = true
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