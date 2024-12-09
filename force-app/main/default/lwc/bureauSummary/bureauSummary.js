import { LightningElement, api, track } from 'lwc';
//Apex Methods
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import getSobjectDataWithoutCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjDtwithFltrRelatedRecordsWithoutCache';


import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class BureauSummary extends LightningElement {
    @api loanAppId = 'a08C4000006Ayh2IAC';//LAN-0143
    @api hasEditAccess = false;
    @track queryParam = [];
    @track params = {};
    @track paramsAppl = {};
    @track showSpinner = false;
    @track activeSections = ["A"];
    @track columnsDataForTable = [
        {
            "label": "Borower Name",
            "fieldName": "Applicant__r.TabName__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Bureau",
            "fieldName": "Source__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Score",
            "fieldName": "Score__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Total No of Live loans",
            "fieldName": "Totalliveloan__c",
            "type": "number",
            "Editable": false
        },
        {
            "label": "Total Live loan exposure",
            "fieldName": "Totalloanexposure__c",
            "type": "number",
            "Editable": false
        },
        {
            "label": "Total Live Secured loan exposure",
            "fieldName": "Totalsecuredloan__c",
            "type": "number",
            "Editable": false
        },
        {
            "label": "Total Live Unsecured loan exposure",
            "fieldName": "Totalunsecuredloan__c",
            "type": "number",
            "Editable": false
        },
        {
            "label": "Total Credit Card Outstanding",
            "fieldName": "Totalcreditcardoutstanding__c",
            "type": "number",
            "Editable": false
        },
        {
            "label": "Total Live Loan Overdue",
            "fieldName": "Totaloanoverdue__c",
            "type": "number",
            "Editable": false
        },
        {
            "label": "Total Live Credit Card Overdue",
            "fieldName": "Totalcreditcardoverdue__c",
            "type": "number",
            "Editable": false
        },
        {
            "label": "Max current DPD of all Live Facilities",
            "fieldName": "MaxcurrentDPDLiveFacilities__c",
            "type": "number",
            "Editable": false
        },
        {
            "label": "Max DPD in last 12 months of all Live Facilities",
            "fieldName": "MaxDPDlast12months__c",
            "type": "number",
            "Editable": false
        },
        {
            "label": "Total Enquiries in last 30 days",
            "fieldName": "TotalEnquirieslast30day__c",
            "type": "number",
            "Editable": false
        },
        {
            "label": "Report date",
            "fieldName": "Report_date__c",
            "type": "Date",
            "Editable": false
        },
        {
            "label": "Trigger type (System/ manual)",
            "fieldName": "Trigger_Type__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Total Live Mortgage loan exposure",
            "fieldName": "TotalMortgageloan__c",
            "type": "number",
            "Editable": false
        },
        {
            "label": "Total Mortgage Enquiries in last 30 days",
            "fieldName": "TotalMortgageEnqlst30days__c",
            "type": "number",
            "Editable": false
        },
        {
            "label": "Total Unsecured Enquiries in last 30 days",
            "fieldName": "TotalUnsecuredEnqlast30day__c",
            "type": "number",
            "Editable": false
        },
        {
            "label": "API Error Message",
            "fieldName": "ErrorMess__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Preview",
            "fieldName": "DocDetail__c",
            "type": "preview",
            "Editable": false
        }
    ];
    @track disableReintiate = false;
    @track isModalOpen = false;
    @track makeModalOpen = false;

    //LAK-9137
    get disableReinitiateAccess(){
        return this.isReadOnly || this.disableReintiate;
    }

    // @track val = null;
    @track queryData = 'SELECT Applicant__r.TabName__c,Source__c,Score__c,Totalliveloan__c,TotalMortgageloan__c,TotalUnsecuredEnqlast30day__c,TotalMortgageEnqlst30days__c,Totalloanexposure__c,Totalsecuredloan__c,Totalunsecuredloan__c,Totalcreditcardoutstanding__c,Totaloanoverdue__c,Totalcreditcardoverdue__c,MaxcurrentDPDLiveFacilities__c,MaxDPDlast12months__c,TotalEnquiries__c,Report_date__c,Id,Trigger_Type__c,TotalEnquirieslast30day__c,ErrorMess__c,DocDetail__c FROM Bureau__c WHERE LoanApp__c =: loanAppId AND (recordtype.name =: recordTypeName1 OR recordtype.name =: recordTypeName2) order by Applicant__r.ApplType__c,CreatedDate DESC';
    connectedCallback() {
        this.disableReintiate = true;
        let paramVal = [];
        paramVal.push({ key: 'loanAppId', value: this.loanAppId });
        paramVal.push({ key: 'recordTypeName1', value: 'Commercial Bureau' });
        paramVal.push({ key: 'recordTypeName2', value: 'Consumer Bureau' });
        // paramVal.push({ key: 'isActiveValue', value: true });
        //paramVal.push({ key: 'errorValue', value: this.val });
        this.queryParam = paramVal;
        console.log('map data:::', this.queryParam);
        this.params = {
            columnsData: this.columnsDataForTable,
            queryParams: this.queryParam,
            query: this.queryData
        }
        //  this.hasEditAccess = false;
        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }
        this.disableReintiate = this.isReadOnly;
        this.getLoanApplicationData();
        // this.getAppWithCallOutData();
    }

    @track loanStage;
    @track loanSubstage;
    getLoanApplicationData() {
        debugger;
        this.showSpinner = true;
        let params = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Id', 'Name', 'NDCAprvd__c', 'Stage__c', 'SubStage__c'],
            queryCriteria: ' where Id = \'' + this.loanAppId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Loan Application Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.loanStage = result.parentRecords[0].Stage__c;
                    this.loanSubstage = result.parentRecords[0].SubStage__c;
                }
                if (this.loanStage) {
                    this.getApiRetriggerTrackerData();
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Document Dispatch Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    @track applIds = [];
    @track apiRetrgrTrcrData = [];

    @track apiRetriggerTrckrDataFalIds = [];
    getApiRetriggerTrackerData() {
        debugger;
        let arra = ['Consumer ACK Request', 'Cusomer Issue Request'];
        console.log('loanappId in Reintiate component', this.loanAppId);
        let paramsLoanApp = {
            ParentObjectName: 'APIRetriggerTracker__c',
            parentObjFields: ['Id', 'App__c', 'App__r.Constitution__c', 'LoanApp__c', 'IsProcessed__c', 'App__r.TabName__c', 'App__r.Id'],
            queryCriteria: ' where IsProcessed__c = false AND LoanApp__c = \'' + this.loanAppId + '\' AND APIName__c  IN (\'' + arra.join('\', \'') + '\')'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('apiRetrgrTrcrData is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.apiRetriggerTrckrDataFal = result.parentRecords;
                    result.parentRecords.forEach(item => {
                        if (item.App__c) {
                            if (item.App__r.Constitution__c === 'INDIVIDUAL') {
                                this.apiRetrgrTrcrData.push(item.App__r.Id);
                            }
                        }

                    })
                    result.parentRecords.forEach(item => {
                        if (item.App__c) {
                            this.apiRetriggerTrckrDataFalIds.push(item.App__r.Id);
                        }
                        // this.apiRetrgrTrcrData.push(item.App__r.Id);
                        //this.applIds.add(item.App__r.Id);
                        console.log('this.apiRetriggerTrckrDataFalIds', this.apiRetriggerTrckrDataFalIds);
                    })
                } else {
                    this.showSpinner = false;
                }
                this.getExpiApiData();
                // console.log('disableReintiate ', this.disableReintiate);
                // console.log('this.apiRetrgrTrcrData after', this.apiRetrgrTrcrData);
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('apiRetrgrTrcrData result getting error= ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    getExpiApiData() {
        let arra = ['ConsumerBureau', 'CommercialBureau'];
        let paramsLoanApp = {
            ParentObjectName: 'Bureau__c',
            parentObjFields: ['Id', 'LoanApp__c', 'IsLatest__c', 'ExpiryDate__c', 'Applicant__c', 'Applicant__r.FullName__c', 'Applicant__r.Id'],
            queryCriteria: ' where IsLatest__c = true AND LoanApp__c = \'' + this.loanAppId + '\' AND RecordType.DeveloperName  IN (\'' + arra.join('\', \'') + '\')'
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
                                if (item.Applicant__c) {
                                    this.apiRetrgrTrcrData.push(item.Applicant__r.Id);
                                }
                            }
                        }
                    })
                } else {
                    this.showSpinner = false;
                }
                this.getCalloutData();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('exp result getting error= ', error);
            });
    }

    @track apiRetrgrTrcrDataProcess = [];
    @track processesAppIds = [];
    getCalloutData() {
        let arra = ['Commercial ACK Request', 'Commercial Issue Request'];
        console.log('loanappId in Reintiate component', this.loanAppId);
        let paramsLoanApp = {
            ParentObjectName: 'APIRetriggerTracker__c',
            parentObjFields: ['Id', 'App__c', 'App__r.Id', 'LoanApp__c', 'IsProcessed__c', 'App__r.TabName__c'],
            queryCriteria: ' where LoanApp__c = \'' + this.loanAppId + '\' AND APIName__c  IN (\'' + arra.join('\', \'') + '\')'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('apiRetrgrTrcrData isprocessed true records are ', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.apiRetrgrTrcrDataProcess = result.parentRecords;
                    let apiFail = false;
                    this.apiRetrgrTrcrDataProcess.forEach(it => {
                        if (it.Appl__c) {
                            let arr = this.apiRetrgrTrcrDataProcess.filter(itm => itm.Appl__c && itm.App__r.Id === it.App__r.Id);
                            arr.forEach(item => {
                                if (!item.IsProcessed__c) {
                                    apiFail = true;
                                }
                            })
                        }
                        if (!apiFail) {
                            if (it.Appl__c) {
                                this.processesAppIds.push(it.Appl__r.Id);
                            }
                        }
                        // if (it.App__c) {
                        //     this.processesAppIds.push(it.App__r.Id);
                        // }
                    })
                    // this.processesAppIds = [...new Set(this.processesAppIds)];
                    console.log('processesAppIds after api retrigger tracker', this.processesAppIds);
                } else {
                    this.showSpinner = false;
                }
                // this.getAppWithCallOutData();
                this.getApiCallOutSuccData();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('apiRetrgrTrcrData is processed result getting error= ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    getApiCallOutSuccData() {
        let arra = ['Commercial ACK Request', 'Commercial Issue Request'];
        //let resp = 'Success';
        console.log('loanappId in Reintiate component', this.loanAppId);
        let paramsLoanApp = {
            ParentObjectName: 'APICoutTrckr__c',
            parentObjFields: ['Id', 'Appl__c', 'Appl__r.Id', 'LAN__c', 'CrntStatus__c', 'LtstRespCode__c', 'Appl__r.TabName__c'],
            queryCriteria: ' where LAN__c = \'' + this.loanAppId + '\' AND APIName__c  IN (\'' + arra.join('\', \'') + '\')'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('apiRetrgrTrcrData isprocessed true records are ', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    // this.apiRetrgrTrcrDataProcess = result.parentRecords;
                    let apiFail = false;
                    result.parentRecords.forEach(it => {
                        if (it.Appl__c) {
                        let arr = result.parentRecords.filter(itm => itm.Appl__r.Id === it.Appl__r.Id);
                        arr.forEach(item => {
                            if (item.LtstRespCode__c === 'Failure' && item.CrntStatus__c === 'Completed') {
                                apiFail = true;
                            }
                        })
                        if (!apiFail) {
                            if (it.Appl__c) {
                                this.processesAppIds.push(it.Appl__r.Id);
                            }
                        }
                    }
                    })
                    console.log('processesAppIds after api callout tracker', this.processesAppIds);
                    
                } else {
                    this.showSpinner = false;
                }
                if (this.processesAppIds && this.processesAppIds.length > 0) {
                    this.processesAppIds = [...new Set(this.processesAppIds)];
                }
                this.getAppWithCallOutData();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('getApiCallOutSuccData getting error= ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    getAppWithCallOutData() {
        // let arra = ['Consumer ACK Request', 'Commercial ACK Request', 'Cusomer Issue Request', 'Commercial Issue Request'];
        let arra = ['Consumer ACK Request', 'Cusomer Issue Request'];
        let appTypes = ['P', 'C', 'G'];
        let paramsLoanApp = {
            ParentObjectName: 'Applicant__c',
            ChildObjectRelName: 'API_Callout_Trackers__r',
            parentObjFields: ['Id', 'Constitution__c'],
            childObjFields: ['Id', 'LtstRespCode__c', 'CrntStatus__c', 'APIName__c', 'Appl__r.Id', 'LAN__c'],
            queryCriteriaForChild: ' Where APIName__c  IN (\'' + arra.join('\', \'') + '\') AND LAN__c = \'' + this.loanAppId + '\'',
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
                                if (ite.LtstRespCode__c != 'Success' && ite.CrntStatus__c === 'Completed') {
                                    if (ite.Appl__c) {
                                        if (item.parentRecord.Constitution__c === 'INDIVIDUAL') {
                                            this.apiRetrgrTrcrData.push(ite.Appl__r.Id);
                                        }
                                        //this.applIds.add(item.Appl__r.Id);
                                    }
                                }
                            })
                        } else {
                            if (item.parentRecord.Constitution__c === 'INDIVIDUAL') {
                                this.apiRetrgrTrcrData.push(item.parentRecord.Id);
                            }
                        }
                    })
                }

                console.log('this.apiRetrgrTrcrData after final is', this.apiRetrgrTrcrData);

                if (this.loanStage === 'UnderWriting') {
                    this.getApplicantData();
                } else {
                    this.apiRetrgrTrcrData = [...new Set(this.apiRetrgrTrcrData)];
                    this.applIds = [...this.apiRetrgrTrcrData];
                    console.log('this.applIds final is ', this.applIds);
                    if (this.applIds.length === 0) {
                        if (this.loanStage != 'UnderWriting') {
                            this.disableReintiate = true;
                            this.showSpinner = false;
                            if (this.makeModalOpen) {
                                this.isModalOpen = true;
                            }
                        }
                    } else {
                        this.disableReintiate = false;
                        if (this.loanStage != 'UnderWriting') {
                            if (this.makeModalOpen) {
                                this.isModalOpen = true;
                            }
                            this.showSpinner = false;
                        }
                    }
                }

            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('api callout data  result getting error= ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    getApplicantData() {
        // this.showSpinner = true;
        // console.log('loanappId in Reintiate component', this.loanAppId);
        let paramsLoanApp = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'Constitution__c'],
            queryCriteria: ' Where LoanAppln__c = \'' + this.loanAppId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('applicant data is', JSON.stringify(result));
                // this.applIds = [];
                console.log('this.applIds after making empty   is ', this.applIds);
                if (result.parentRecords && result.parentRecords.length > 0) {
                    result.parentRecords.forEach(item => {
                        if (item.Constitution__c != 'INDIVIDUAL') {
                            if (this.processesAppIds && this.processesAppIds.length > 0) {
                                let existVal = this.processesAppIds.includes(item.Id);
                                if (!existVal) {
                                    this.apiRetrgrTrcrData.push(item.Id);
                                }
                                if (this.apiRetriggerTrckrDataFalIds.includes(item.Id)) {
                                    this.apiRetrgrTrcrData.push(item.Id);
                                }
                                // this.processesAppIds.forEach(it => {
                                //     if (it != item.Id) {
                                //         this.apiRetrgrTrcrData.push(item.Id);
                                //     }
                                // })
                            } else {
                                this.apiRetrgrTrcrData.push(item.Id);
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
                if (this.makeModalOpen) {
                    this.isModalOpen = true;
                }
                console.log('this.applIds final again  is ', this.applIds);
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('applicant  data  result getting error= ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    handleIntialization() {
        this.showSpinner = true;
        this.makeModalOpen = true;
        this.getLoanApplicationData();
    }



    @track count = 0;
    handleCustomEvent(event) {
        this.isModalOpen = false;
        let spinnerValue = event.detail.spinner;
        let titleVal = event.detail.title;
        let variantVal = event.detail.variant;
        let messageVal = event.detail.message;
        console.log('val from return is', titleVal, 'variantVal', variantVal, 'messageVal', messageVal);
        if (titleVal && variantVal && messageVal) {
            this.count++;
            const evt = new ShowToastEvent({
                title: titleVal,
                variant: variantVal,
                message: messageVal
            });
            this.dispatchEvent(evt);

            this.apiRetrgrTrcrData = [];
            this.disableReintiate = true;
            this.makeModalOpen = false;

        }
        if (spinnerValue) {
            this.showSpinner = true;
        } else {
            if (this.count > 0) {
                this.showSpinner = true;
                this.handleRefreshClick();
            } else {
                this.showSpinner = false;
            }
        }
    }

    handleRefreshClick() {
        this.showSpinner = true;
        let child = this.template.querySelector('c-dynamic-datatable');
        if (child) {
            setTimeout(() => {
                console.log('before');
                child.handleGettingData();
                this.makeModalOpen = false;
                this.getLoanApplicationData();
                console.log('after');
                this.showSpinner = false;
            }, 10000);
        }
    }
}