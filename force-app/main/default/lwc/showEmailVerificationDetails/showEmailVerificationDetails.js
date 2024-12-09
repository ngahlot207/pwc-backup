import { LightningElement, api, track } from 'lwc';
//Apex Methods
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import getSobjectDataWithoutCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjDtwithFltrRelatedRecordsWithoutCache';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class ShowEmailVerificationDetails extends LightningElement {
    @api loanAppId = 'a08C4000008Zk52IAC';
    @api hasEditAccess;

    @track disableReintiate = false;
    @track isReadOnly;
    @track emailVerData = [];
    @track appData = [];
    @track appDataDisplay = [];

    enableInfiniteScrolling = true;
    enableBatchLoading = true;
    @track showSpinner = false;

    // @track columnsDataForArtct = [
    //     {
    //         "label": "Name",
    //         "fieldName": "Appl__r.FullName__c",
    //         "type": "text",
    //         "Editable": false
    //     },
    //     {
    //         "label": "Applicant Type",
    //         "fieldName": "Appl__r.ApplType__c",
    //         "type": "text",
    //         "Editable": false
    //     },
    //     {
    //         "label": "Email Id",
    //         "fieldName": "Appl__r.MembershipNumber__c",
    //         "type": "number",
    //         "Editable": false
    //     },
    //     {
    //         "label": "Final Email validity",
    //         "fieldName": "Name__c",
    //         "type": "text",
    //         "Editable": false
    //     },
    //     {
    //         "label": "Email id is from a disposable email provider",
    //         "fieldName": "Name_Match_Score__c",
    //         "type": "number",
    //         "Editable": false
    //     },
    //     {
    //         "label": "Mail exchanger records exist",
    //         "fieldName": "Qualification__c",
    //         "type": "text",
    //         "Editable": false
    //     },
    //     {
    //         "label": "Email id follows a valid regular expression",
    //         "fieldName": "Address__c",
    //         "type": "text",
    //         "Editable": false
    //     },
    //     {
    //         "label": "Email id is accessible on the SMTP server",
    //         "fieldName": "MobNo__c",
    //         "type": "number",
    //         "Editable": false
    //     },
    //     {
    //         "label": "The email id is via a free webmail",
    //         "fieldName": "Email__c",
    //         "type": "text",
    //         "Editable": false
    //     },
    //     {
    //         "label": "Mail exchange server connectivity status",
    //         "fieldName": "DisciplinaryAction__c",
    //         "type": "text",
    //         "Editable": false
    //     },
    //     {
    //         "label": "Email domain Blocked status",
    //         "fieldName": "DisciplinaryAction__c",
    //         "type": "text",
    //         "Editable": false
    //     },
    //     {
    //         "label": "The reason for the Email domain Blockage",
    //         "fieldName": "DisciplinaryAction__c",
    //         "type": "text",
    //         "Editable": false
    //     },
    //     {
    //         "label": "API Verification Status",
    //         "fieldName": "IntegrationStatus__c",
    //         "type": "text",
    //         "Editable": false
    //     },
    //     {
    //         "label": "API Error Message",
    //         "fieldName": "IntegrationErrorMessage__c",
    //         "type": "text",
    //         "Editable": false
    //     }
    // ];
    // @track queryDataForCA = 'SELECT Appl__r.FullName__c,toLabel(Appl__r.ApplType__c),Appl__r.MembershipNumber__c,Name__c,Name_Match_Score__c,Address__c,COPStatus__c,MembershipStatus__c,IntegrationStatus__c,IntegrationErrorMessage__c,Id FROM APIVer__c WHERE LoanAplcn__c =: loanAppId AND IsLatest__c =: isActiveValue AND recordtype.name =: recordTypeName AND Prof_Qualification_Check__c =: qualificationCheckName';
    connectedCallback() {
        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }
        this.isReadOnly = false;
        this.disableReintiate = this.isReadOnly;

        // let paramVal = [];
        // paramVal.push({ key: 'loanAppId', value: this.loanAppId });
        // paramVal.push({ key: 'recordTypeName', value: 'Qualification Check' });
        // paramVal.push({ key: 'isActiveValue', value: true });
        // paramVal.push({ key: 'qualificationCheckName', value: 'CA Membership Check' });
        // this.queryParam = paramVal;
        // console.log('map data:::', this.queryParam);
        // this.paramsCAApi = {
        //     columnsData: this.columnsDataForCA,
        //     queryParams: this.queryParam,
        //     query: this.queryDataForCA
        // }

        this.getApplicantsData();
    }

    getApplicantsData() {
        this.showSpinner = true;
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'FullName__c', 'EmailIDverificationStatus__c', 'EmailId__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Applicants Data is ', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.appData = result.parentRecords;
                }
                this.getEmailMasteData();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Api Verification Data is ', error);
            });
    }
    @track basicEmailCodes = [];
    getEmailMasteData() {
        this.showSpinner = true;
        let type = 'Email Providers';
        let params = {
            ParentObjectName: 'MasterData__c',
            parentObjFields: ['Id', 'SalesforceCode__c', 'Name', 'Type__c'],
            queryCriteria: ' where Type__c = \'' + type + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Applicants Data is ', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    result.parentRecords.forEach(item => {
                        this.basicEmailCodes.push(item.SalesforceCode__c);
                    })
                }
                this.getEmailVerDetails();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Api Verification Data is ', error);
            });
    }
    // getEmailVerDetails() {
    //     let isEmail = 'Official Email';
    //     let params = {
    //         ParentObjectName: 'APIVer__c',
    //         parentObjFields: ['Id', 'Invalid__c', 'Appl__c', 'Appl__r.FullName__c', 'toLabel(Appl__r.ApplType__c)', 'Appl__r.EmailId__c', 'Appl__r.PAN__c', 'IntegrationStatus__c', 'GSTIN__c', 'GSTIN_RefId__c', 'GSTIN_Status__c', 'ConstBuisnessGST__c', 'LegalNameOfBusiness_GST_Certificate__c', 'TradeName_GST_Certificate__c', 'DateOfRegistration__c', 'IntegrationErrorMessage__c', 'Verification_Status__c'],
    //         queryCriteria: ' where LoanAplcn__c = \'' + this.loanAppId + '\' AND RecordType.Name = \'' + isEmail + '\' AND Invalid__c = false'
    //     }
    //     getSobjectData({ params: params })
    //         .then((result) => {
    //             console.log('Api Verification Data is ', JSON.stringify(result));
    //             if (result.parentRecords && result.parentRecords.length > 0) {
    //                 this.emailVerData = result.parentRecords;
    //                 // result.parentRecords.forEach(item => {
    //                 //     if (item.Appl__c) {
    //                 //         this.apVerAppIds.push(item.Appl__c);
    //                 //     }
    //                 // })
    //                 // this.apVerAppIds = [...new Set(this.apVerAppIds)];
    //             }
    //             this.getApiRetriggerTrackerData();
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getting Api Verification Data is ', error);
    //         });
    // }

    @track emailVerDataBasic = [];
    getEmailVerDetails() {
        this.emailVerDataBasic = [];
        this.emailVerData = [];
        // let isEmail = 'Official Email';
        let isEmail = ['Email Authentication Advance', 'Official Email'];
        let childType = 'Email Individual Match';
        let params = {
            ParentObjectName: 'APIVer__c',
            ChildObjectRelName: 'API_Verification_Details__r',
            parentObjFields: ['Id', 'ValidEmail__c', 'disposable__c', 'mxRecords__c', 'regexp__c', 'webmail__c', 'SmtpServer__c', 'IsBlocked__c', 'Reason__c', 'Appl__r.FullName__c', 'RecordType.Name', 'toLabel(Appl__r.ApplType__c)', 'Appl__r.EmailId__c', 'Email__c', 'OrgDomainMatch__c', 'Age__c', 'Expired__c', 'Name__c', 'Name_Match_Score__c', 'IntegrationStatus__c', 'IntegrationErrorMessage__c'],
            childObjFields: ['Id', 'Type__c', 'Name__c', 'Match__c'],
            queryCriteriaForChild: ' Where Type__c = \'' + childType + '\' LIMIT 1',
            queryCriteria: ' where LoanAplcn__c = \'' + this.loanAppId + '\' AND RecordType.Name IN (\'' + isEmail.join('\', \'') + '\') AND IsLatest__c = true'
        }
        getSobjectDataWithoutCacheable({ params: params })
            .then((result) => {
                console.log('Api Verification Data is ', JSON.stringify(result));
                if (result) {
                    result.forEach(record => {
                        if (record.parentRecord.RecordType.Name && record.parentRecord.RecordType.Name === 'Email Authentication Advance') {
                            if (record.ChildReords) {
                                record.parentRecord.Match__c = record.ChildReords[0].Match__c;
                                record.parentRecord.IndividualName = record.ChildReords[0].Name__c ? record.ChildReords[0].Name__c : '';
                                // this.emailVerData.push(record.parentRecord);
                            }
                            if(record.parentRecord.ValidEmail__c){
                                record.parentRecord.emailStatus = 'Verified';
                            }else{
                                record.parentRecord.emailStatus = 'Failed';
                            }
                            this.emailVerData.push(record.parentRecord);
                        } else if (record.parentRecord.RecordType.Name && record.parentRecord.RecordType.Name === 'Official Email') {
                            if(record.parentRecord.ValidEmail__c){
                                record.parentRecord.emailStatus = 'Verified';
                            }else{
                                record.parentRecord.emailStatus = 'Failed';
                            }
                            this.emailVerDataBasic.push(record.parentRecord);
                        }
                    });
                    console.log('emailVerData is =====>>>> ', JSON.stringify(this.emailVerData));
                    console.log('emailVerDataBasic is =====>>>> ', JSON.stringify(this.emailVerDataBasic));
                }
                this.getApiRetriggerTrackerData();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Api Verification Data is ', error);
            });
    }

    // applIds = new Set();
    @track applIds = [];
    @track apiRetrgrTrcrData = [];
    getApiRetriggerTrackerData() {
        let apiName = ['Email Verification', 'Email Authentication Advanced'];
        console.log('loanappId in Reintiate component', this.loanAppId);
        let paramsLoanApp = {
            ParentObjectName: 'APIRetriggerTracker__c',
            parentObjFields: ['Id', 'App__c', 'LoanApp__c', 'IsProcessed__c', 'App__r.TabName__c', 'App__r.Id'],
            queryCriteria: ' where IsProcessed__c = false AND LoanApp__c = \'' + this.loanAppId + '\' AND APIName__c IN (\'' + apiName.join('\', \'') + '\')'
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
                this.getAppWithCallOutData();
                //this.getExpiApiData();
                console.log('disableReintiate ', this.disableReintiate);
                console.log('this.apiRetrgrTrcrData after', this.apiRetrgrTrcrData);
                if (result.error) {
                    console.error('apiRetrgrTrcrData result getting error=', result.error);
                }
            })
    }

    getAppWithCallOutData() {
        let apiName = ['Email Verification', 'Email Authentication Advanced'];
        let appTypes = ['P', 'C', 'G'];
        let paramsLoanApp = {
            ParentObjectName: 'Applicant__c',
            ChildObjectRelName: 'API_Callout_Trackers__r',
            parentObjFields: ['Id'],
            childObjFields: ['Id', 'LtstRespCode__c', 'APIName__c', 'Appl__r.Id', 'LAN__c'],
            queryCriteriaForChild: ' where LAN__c = \'' + this.loanAppId + '\' AND APIName__c IN (\'' + apiName.join('\', \'') + '\') ORDER BY LastModifiedDate DESC',
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND ApplType__c  IN (\'' + appTypes.join('\', \'') + '\')'

        }
        getSobjectDataWithoutCacheable({ params: paramsLoanApp })
            .then((result) => {
                console.log('AppWithCallOutData is', JSON.stringify(result));
                if (result && result.length > 0) {
                    result.forEach(item => {
                        if (item.ChildReords && item.ChildReords.length > 0) {
                            // item.ChildReords.forEach(ite => {
                            //     if (ite.LtstRespCode__c != 'Success') {
                            //         if (ite.Appl__c) {
                            //             this.apiRetrgrTrcrData.push(ite.Appl__r.Id);
                            //             //this.applIds.add(item.Appl__r.Id);
                            //         }
                            //     }
                            // })
                                 if (item.ChildReords[0].LtstRespCode__c != 'Success') {
                                    if (item.ChildReords[0].Appl__c) {
                                        this.apiRetrgrTrcrData.push(item.ChildReords[0].Appl__r.Id);
                                        //this.applIds.add(item.Appl__r.Id);
                                    }
                                }
                        } else {
                            this.apiRetrgrTrcrData.push(item.parentRecord.Id);
                        }
                    })
                }
                //|| item.EmailIDverificationStatus__c === 'Failed' For LAK-10004
                if (this.appData && this.appData.length > 0) {
                    this.appData.forEach(item => {
                        if (item.EmailIDverificationStatus__c && (item.EmailIDverificationStatus__c === 'Changed' )) {
                            this.apiRetrgrTrcrData.push(item.Id);
                        }
                    })
                }
                this.appDataDisplay = [];
                this.apiRetrgrTrcrData = [...new Set(this.apiRetrgrTrcrData)];
                this.applIds = [...this.apiRetrgrTrcrData];
                if (this.applIds.length === 0 || this.isReadOnly) {
                    this.disableReintiate = true;
                } else {
                    this.applIds.forEach(item => {
                        let obj = this.appData.find(it => it.Id === item);
                        if (obj) {
                            this.appDataDisplay.push(obj);
                        }
                    })
                }
                this.showSpinner = false;
                console.log('this.apiRetrgrTrcrData after second method', this.apiRetrgrTrcrData);
                console.log('this.appDataDisplay after second method', this.appDataDisplay);
                if (result.error) {
                    this.showSpinner = false;
                    console.error('apiRetrgrTrcrData result getting error=', result.error);
                }
            })
    }


    @track isModalOpen = false;
    handleIntialization() {
        this.isModalOpen = true;
    }
    handleClick(event) {
        console.log('record ', event.target.dataset.recordid);
        let selectedRecordId = event.target.dataset.recordid;
        console.log('value is', event.target.checked);
        console.log('All selected Records before ', this.apiRetrgrTrcrData);
        let val = event.target.checked;
        let recordData = {};
        let searchDoc = this.appDataDisplay.find((app) => app.Id === selectedRecordId);
        if (searchDoc) {
            console.log('searchDoc', searchDoc);
            //searchDoc = { ...searchDoc, selectCheckbox: val }
            searchDoc['selectCheckbox'] = val;
        }
        else {
            recordData['Id'] = selectedRecordId;
            recordData['selectCheckbox'] = val;
            this.appDataDisplay.push(recordData);
        }
        console.log('All selected Records', this.appDataDisplay);
    }

    closeModal() {
        this.isModalOpen = false;
        if (this.appDataDisplay && this.appDataDisplay.length > 0) {
            this.appDataDisplay.forEach(item => {
                item.selectCheckbox = false;
            })
        }
    }
    intRecords = [];
    handleReIntialization() {
        this.showSpinner = true;
        this.isModalOpen = false;
        console.log('handle reintialization called');
        let filteredData = this.appDataDisplay.filter(item => item.selectCheckbox === true);
        console.log('All filteredData Records', JSON.stringify(filteredData));
        if (filteredData.length > 0) {
            this.createIntegrationMsg(filteredData);
        } else {
            this.showSpinner = false;
            this.showToastMessage('Error', 'Please Select Applicant to Re-Initiate', 'Error', 'sticky')
        }
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
    createIntegrationMsg(filteredData) {
        filteredData.forEach(item => {
            let contain = this.basicEmailCodes.some(code => item.EmailId__c.includes(code));
            let serviceName;
            if (contain) {
                serviceName = 'Email Verification';
            } else {
                serviceName = 'Email Authentication Advanced';
            }
            let fields = {};
            fields['sobjectType'] = 'IntgMsg__c';
            fields['Name'] = serviceName;
            fields['BU__c'] = 'HL / STL';
            fields['IsActive__c'] = true;
            fields['Svc__c'] = serviceName;
            fields['ExecType__c'] = 'Async';
            fields['Status__c'] = 'New';
            fields['RefObj__c'] = 'Applicant__c';
            fields['RefId__c'] = item.Id;
            this.intRecords.push(fields);
        })
        console.log(JSON.stringify(this.intRecords));
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
                console.log('before');
                setTimeout(() => {
                    this.showSpinner = false;
                    this.getApplicantsData();
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        variant: 'success',
                        message: 'Re-Initiated Successfully, Please Click on Refresh Button to See Details on Table'
                    });
                    this.dispatchEvent(evt);
                }, 6000);
                console.log('after');
                this.intRecords = [];
            })
            .catch((error) => {
                console.log('Error In creating Record', error);
                this.showSpinner = false;
                // this.fireCustomEvent("Error", "error", "Error occured in upsertMultipleRecord " + error, false);
            });
    }

    handleRefreshClick() {
        this.showSpinner = true;
        setTimeout(() => {
            this.showSpinner = false;
            this.getApplicantsData();
        }, 6000);
        console.log('after');
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