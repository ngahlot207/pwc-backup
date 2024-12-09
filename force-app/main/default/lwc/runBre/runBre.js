import { LightningElement, api, track, wire } from 'lwc';
import CURRENTUSERID from '@salesforce/user/Id';
import Stage from '@salesforce/schema/LoanAppl__c.Stage__c';
import subStage from '@salesforce/schema/LoanAppl__c.SubStage__c';
import OwnerId from '@salesforce/schema/LoanAppl__c.OwnerId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds'
import getSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords'
import getAllSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataWithoutCacheable';
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { CloseActionScreenEvent } from 'lightning/actions';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
//import CustomLabels
import BRETriggerMessage from '@salesforce/label/c.RUNBREBUTTONMESSAGE';
import BRETriggerFailedMessage from '@salesforce/label/c.BRETRIGGERFAILEDMESSAGE';
import APIInternalServerErrorMessage from '@salesforce/label/c.APIInternalServerError';
import BRESlowServerErrorMessage from '@salesforce/label/c.BRESlowServerMessage';
export default class LoanApplicationClaim extends NavigationMixin(LightningElement) {

    label = {
        BRETriggerMessage,
        BRETriggerFailedMessage,
        APIInternalServerErrorMessage,
        BRESlowServerErrorMessage
    }
    currentPageReference;
    loanApplicationNumber;
    recordPageFlag;
    listViewFlag;
    @track breIntMsgId = '';
    @track userDetail = [];
    @track confirmationMessage = false;
    @track showSpinner = false;
    @track buttonDisplay = true;
    intRecords = [];
    @track _recordId;
    @api get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        this.setAttribute("recordId", value);
    }

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        if (this.connected) {
        } else {
            if (this.currentPageReference.state.c__recordId != undefined) {
                this._recordId = this.currentPageReference.state.c__recordId;
                this.listViewFlag = 'ListViewFlag';
                this.confirmationMessage = true;
                //this.getCurrentUserole();
            } else if (this.currentPageReference.state.recordId != undefined) {
                this._recordId = this.currentPageReference.state.recordId;
                console.log(' this.recordId:', this._recordId);
                this.recordPageFlag = 'RecordPageFlag';
                this.confirmationMessage = true;
                //   this.getCurrentUserole();
            }
        }
    }


    closeAction() {
        // this.createIntegrationMessage();
        this.getLoanApplicationData();
        
    }

    noBtn() {
        console.log('inside else recordflag');
        this.dispatchEvent(new CloseActionScreenEvent());

       // LAK-9775 for using in Parent Modal pop up in Application Relook
        //dispatching the custom event
        const selectedEvent = new CustomEvent("select", {
            detail: false
          });
          this.dispatchEvent(selectedEvent);
    }

    @track loanStage;
    getLoanApplicationData() {
        this.showSpinner = true;
        let params = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Id', 'Name', 'Stage__c', 'SubStage__c'],
            queryCriteria: ' where Id = \'' + this._recordId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                this.loanStage = result.parentRecords[0].Stage__c;
                console.log('Loan Application Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    if (result.parentRecords[0].Stage__c == 'UnderWriting' && result.parentRecords[0].SubStage__c == 'Credit Appraisal') {
                        this.getMatchingCriteriaData('Credit Appraisal');
                    } else if (result.parentRecords[0].Stage__c == 'Post Sanction' && result.parentRecords[0].SubStage__c == 'UW Approval') {
                        this.getMatchingCriteriaData('UW Approval');
                    } else {
                        this.createIntegrationMessage();
                    }
                } else {
                    this.showSpinner = false;
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Loan Application Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    @track appIds = [];
    @track deduperRecordTypeName = 'Dedupe';
    @track enpaData = [];
    @track enpaRecordTypeName = 'ENPA';
    getMatchingCriteriaData(flag) {
        debugger;
        let paramsData = {
            ParentObjectName: 'DedupeResponse__c',
            ChildObjectRelName: 'Dedupe_Responses__r',
            parentObjFields: ['Id', 'LoanAppln__c', 'Dedupe__r.UCID__c', 'Lan__c', 'DedupeMatchName__c', 'Applicant__c', 'Applicant__r.Id', 'Applicant__r.UCID__c', 'Applicant__r.TabName__c', 'InternalDedupeResponse__c', 'Dedupe__c', 'Dedupe__r.MatchCriteria__c', 'MatchSource__c', 'PastAppId__c', 'AppId__c', 'PastAppDate__c', 'LoanType__c', 'LoanStatus__c', 'RejectionReason__c', 'LoanDisbDate__c', 'LoanAmount__c', 'Tenure__c', 'CurrentOutstanding__c', 'SystemDPD__c', 'SecuritisationStatus__c', 'IntnlDeduRelevance__c', 'IntrnlDeduperes__c', 'IntnalDeduperesremark__c', 'IsAddMatchingCr__c', 'NoMatchFound__c'],
            childObjFields: ['Id', 'LoanAppln__c', 'Dedupe__r.UCID__c', 'Dedupe__r.InternalDedupeResponse__c', 'Lan__c', 'DedupeMatchName__c', 'Applicant__c', 'Applicant__r.Id', 'Applicant__r.UCID__c', 'Applicant__r.TabName__c', 'InternalDedupeResponse__c', 'Dedupe__c', 'Dedupe__r.MatchCriteria__c', 'MatchSource__c', 'PastAppId__c', 'AppId__c', 'PastAppDate__c', 'LoanType__c', 'LoanStatus__c', 'RejectionReason__c', 'LoanDisbDate__c', 'LoanAmount__c', 'Tenure__c', 'CurrentOutstanding__c', 'SystemDPD__c', 'SecuritisationStatus__c', 'IntnlDeduRelevance__c', 'IntrnlDeduperes__c', 'IntnalDeduperesremark__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this._recordId + '\' AND recordtype.name = \'' + this.deduperRecordTypeName + '\' AND IsLatest__c = true ORDER BY Applicant__r.ApplType__c'
        }
        getAllSobjectDatawithRelatedRecords({ params: paramsData })
            .then((result) => {
                console.log('Dedupe result Data is ', JSON.stringify(result));
                //For LAK-4247
                result.forEach(item => {
                    if (item.parentRecord) {
                        if (item.parentRecord.IntnlDeduRelevance__c === 'Accurate Match found') {
                            this.appIds.push(item.parentRecord.Applicant__r.Id);
                        }
                    }
                })
                result.forEach(item => {
                    if (item.ChildReords) {
                        item.ChildReords.forEach(it => {
                            if (it.IntnlDeduRelevance__c === 'Accurate Match found') {
                                this.appIds.push(it.Applicant__r.Id);
                            }
                        })
                    }
                })
                this.appIds = [...new Set(this.appIds)];
                this.callEnpaMethod(flag);
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting matchingCriteriaData', error);
            });
    }
    callEnpaMethod(flag) {
        debugger;
        if (this.appIds && this.appIds.length > 0) {
            if (flag == 'Credit Appraisal') {
                let paramsLoanApp = {
                    ParentObjectName: 'DedupeResponse__c',
                    parentObjFields: ['Id', 'LoanAppln__r.Name', 'AppId__c', 'AUM__c', 'LoanType__c', 'Lan__c', 'UCID__c', 'CustomerName__c', 'Applicant__c', 'Applicant__r.Id', 'LoanDisbDate__c', 'LoanAmount__c', 'Tenure__c', 'SystemDPD__c', 'DPD__c', 'FinalAssetClass__c', 'NPADate__c', 'SecuritisationStatus__c', 'Internal_Top_up_Original_loan__c', 'Loan_to_be_closed_internally__c', 'IsPDDpending__c', 'LoantobeconsideredinLTVcal__c', 'Loantobelinkedwithproposedloan__c'],
                    queryCriteria: ` where Applicant__r.Id IN ('${this.appIds.join("','")}') AND recordtype.name = '${this.enpaRecordTypeName}' AND LoanAppln__c = '${this._recordId}' AND IsLatest__c = true ORDER BY Applicant__r.ApplType__c`
                }
                getSobjectData({ params: paramsLoanApp })
                    .then((result) => {
                        console.log('result of ENPA details is', JSON.stringify(result));
                        if (result.parentRecords && result.parentRecords.length > 0) {
                            this.enpaData = result.parentRecords;
                            console.log('this.enpaData ', this.enpaData);
                        }
                        this.getApplicantsData();
                    })
                    .catch((error) => {
                        this.showSpinner = false;
                        console.log('Error In getting ENPA Data', error);
                    });
            } else if (flag == 'UW Approval') {
                this.handleReIntialization(this.appIds);
            }

        } else {
            // this.showSpinner = false;
            this.createIntegrationMessage();
        }
    }
    getApplicantsData() {
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'IsENPSRunAtUW__c', 'TabName__c'],
            queryCriteria: ' Where  Id IN (\'' + this.appIds.join('\', \'') + '\')'
        }
        getSobjectData({ params: params })
            .then((result) => {
                this.showSpinner = true;
                let allSatisfied = true;
                console.log('Applicants Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    result.parentRecords.forEach(item => {
                        if (item.IsENPSRunAtUW__c == false && this.loanStage == 'UnderWriting') {
                            allSatisfied = false;
                            this.showSpinner = false;
                            this.showToastMessage('Error', item.TabName__c + ': Please Run ENPA', 'Error', 'sticky');
                        } else {
                            let arr = this.enpaData.filter(ite => ite.Applicant__r.Id === item.Id);
                            if (arr && arr.length > 0) {
                                arr.forEach(it => {
                                    if (it) {
                                        if (!it.Internal_Top_up_Original_loan__c || !it.Loan_to_be_closed_internally__c
                                            || !it.IsPDDpending__c
                                            || !it.Loantobelinkedwithproposedloan__c
                                            || !it.LoantobeconsideredinLTVcal__c) {
                                            allSatisfied = false;
                                            this.showSpinner = false;
                                            this.showToastMessage('Error', 'Please Fill ENPA Inputs ', 'Error', 'sticky');
                                            return;
                                        }
                                    }
                                })
                            }
                        }
                    })
                }
                if (allSatisfied) {
                    this.createIntegrationMessage();
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Loan Application Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    @track intRecordsEnpa = [];
    handleReIntialization(filteredData) {
        debugger;
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
                fields['RefId__c'] = item;
                fields['ParentRefObj__c'] = "LoanAppl__c";
                fields['ParentRefId__c'] = this._recordId;
                this.intRecordsEnpa.push(fields);
            })
            console.log(JSON.stringify(this.intRecordsEnpa));
            this.upsertIntRecord(this.intRecordsEnpa);
        }
    }
    upsertIntRecord(intRecordsEnpa) {
        console.log('int msgs records ', JSON.stringify(intRecordsEnpa));
        upsertMultipleRecord({ params: intRecordsEnpa })
            .then((result) => {
                this.createIntegrationMessage();
            })
            .catch((error) => {
                console.log('Error In creating Record', error);
                this.showSpinner = false;
                // this.fireCustomEvent("Error", "error", "Error occured in upsertMultipleRecord " + error, false);
            });
    }
    createIntegrationMessage() {
        let params = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Id', 'Name', 'Stage__c', 'SubStage__c'],
            queryCriteria: ' where Id = \'' + this._recordId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                this.loanStage = result.parentRecords[0].Stage__c;
                if(this.loanStage != 'Disbursement Initiation' && this.loanStage != 'Disbursed'){
                    let fieldsWo = {};
                    fieldsWo['sobjectType'] = 'IntgMsg__c';
                    fieldsWo['Name'] = 'Crif Auth Login'; //serviceName;//'KYC OCR'
                    fieldsWo['BU__c'] = 'HL / STL';
                    fieldsWo['IsActive__c'] = true;
                    fieldsWo['Svc__c'] = 'Crif Auth Login'; //serviceName;
                    fieldsWo['Status__c'] = 'New';
                    fieldsWo['Outbound__c'] = true;
                    fieldsWo['RefObj__c'] = 'LoanAppl__c';
                    fieldsWo['ApiVendor__c'] = 'Crif';
                    fieldsWo['RefId__c'] = this._recordId;
                    this.intRecords.push(fieldsWo);
                    this.createRecords(this.intRecords);
                }
                else{
                    this.showToastMessage('Error', 'BRE can not be run in the current stage', 'Error', 'sticky');
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
            });
        
    }

    createRecords(intRecords) {
        this.showSpinner = true;
        upsertMultipleRecord({ params: intRecords })
            .then((result) => {
                //this.showToastMessage('Success',this.label.BRETriggerMessage,'Success','sticky')
                //this.dispatchEvent(new CloseActionScreenEvent());
                this.intRecords = [];
                this.breIntMsgId = result[0].Id;
                //this.startPolling();
                this.startFirstIntPolling();
            })
            .catch((error) => {
                this.showToastMessage('Error', error, 'Error', 'sticky');
                this.dispatchEvent(new CloseActionScreenEvent());
                console.log('Error In creating Record', error);
                // this.fireCustomEvent("Error", "error", "Error occured in accepting File  " + error.message, false);
            });
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
    chequeInterval;
    @track respPayload = '';

    startPolling() {
        console.log('Polling has started ##875')
        this.chequeInterval = setInterval(() => {
            this.getIntRecord();
        }, 5000);
    }

    @track counter;
    startFirstIntPolling(){
        this.counter = 0;
        this.chequeInterval = setInterval(() => {
            this.counter += 5;

            if(this.counter % 50 ===0){
                this.showToastMessage('Info', this.label.BRESlowServerErrorMessage,'Info','sticky');
            }
            this.getFirstIntRecord();
            /*if (this.counter === 50) {
                this.showToastMessage('Error', this.label.APIInternalServerErrorMessage, 'Error', 'sticky');
                clearInterval(this.chequeInterval);
                this.showSpinner = false
                this.dispatchEvent(new CloseActionScreenEvent());
                        setTimeout(() => {
                            location.reload();
                        }, 2000);
                
            }else{
                this.getFirstIntRecord();
            }*/
            
        }, 3000);

    }
    getIntRecord() {
        let paramsLoanApp = {
            ParentObjectName: 'IntgMsg__c',
            parentObjFields: ['Id', 'Status__c', 'Name', 'Resp__c', 'APIStatus__c'],
            queryCriteria: ' where ParentRefId__c = \'' + this.breIntMsgId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Int Msg data is', JSON.stringify(result));
                if (result.parentRecords) {
                    this.respPayload = result.parentRecords[0].Resp__c;
                    console.log('this.respPayload ', result.parentRecords[0].Resp__c);
                    if (result.parentRecords[0].APIStatus__c === 'Success') {

                        //this.getloanApplicationData();
                        this.showToastMessage('Success', this.label.BRETriggerMessage, 'Success', 'sticky')
                        //this.startPolling('loanApp')
                        console.log('Cleared ##468')
                        clearInterval(this.chequeInterval);
                        this.showSpinner = false;
                        this.dispatchEvent(new CloseActionScreenEvent());
                        setTimeout(() => {
                            location.reload();
                        }, 2000);
                    }
                    if (result.parentRecords[0].APIStatus__c === 'Failure') {
                        //let errorResp = JSON.parse(result.parentRecords[0].Resp__c);

                        this.showToastMessage('Error', this.label.BRETriggerFailedMessage + ': ' + result.parentRecords[0].Resp__c, 'Error', 'sticky')
                        clearInterval(this.chequeInterval);
                        this.dispatchEvent(new CloseActionScreenEvent());
                        this.showSpinner = false;

                        console.log('Cleared ##468')
                    }
                }

            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Int Msg Record ', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }


    getFirstIntRecord() {
        
        let paramsLoanApp = {
            ParentObjectName: 'IntgMsg__c',
            parentObjFields: ['Id', 'Status__c', 'Name', 'Resp__c', 'APIStatus__c'],
            queryCriteria: ' where Id = \'' + this.breIntMsgId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Int Msg data is', JSON.stringify(result));
                if (result.parentRecords) {
                    this.respPayload = result.parentRecords[0].Resp__c;
                    console.log('this.respPayload ', result.parentRecords[0].Resp__c);
                    if (result.parentRecords[0].APIStatus__c === 'Success') {

                        clearInterval(this.chequeInterval);
                        this.startPolling();
                    }
                    if (result.parentRecords[0].APIStatus__c === 'Failure') {
                        //let errorResp = JSON.parse(result.parentRecords[0].Resp__c);

                        this.showToastMessage('Error', this.label.APIInternalServerErrorMessage, 'Error', 'sticky')
                        clearInterval(this.chequeInterval);
                        this.showSpinner = false;
                        this.dispatchEvent(new CloseActionScreenEvent());
                        setTimeout(() => {
                            location.reload();
                        }, 2000);
                    }
                }

            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Int Msg Record ', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }





}