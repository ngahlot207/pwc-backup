import { LightningElement, api, track, wire } from 'lwc';

import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import getSobjDtwithFltrRelatedRecordsWithoutCache from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjDtwithFltrRelatedRecordsWithoutCache';

import { ShowToastEvent } from "lightning/platformShowToastEvent";

// Custom labels
import ReturnTo_SuccessMessage from '@salesforce/label/c.ReturnTo_SuccessMessage';
import ReturnTo_ErrorMessage from '@salesforce/label/c.ReturnTo_ErrorMessage';

export default class ReturnToRM extends LightningElement {
    //@api recordId;
    @track returnToRmMessage = "Do you want to return this Application to RM?";
    @track isReturnToRM = false;
    @track showSpinnerChild = false;
    @track wiredLoanData;
    _recordId
    @track rmSMName;
    @track DSAName;
    @track RMDSAName;
    @track JourneyType;
    @api returnToRmOptions = [];
    @api selectedValue = [];
    @track
    paramsLoanApp = {
        ParentObjectName: 'LoanAppl__c',
        parentObjFields: ['RMSMName__c', 'Lead__r.LeadJuryBY__c', 'Lead__r.DSAContact__r.OwnerId', 'SubStage__c', 'Product__c', 'Lead__r.OwnerId'],
        queryCriteria: ' where id = \'' + this.recordId + '\''
    }

    @api get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        this.setAttribute("recordId", value);
        this.handleRecordIdChange(value);
    }

    handleRecordIdChange() {
        let paramLoanappTemp = this.paramsLoanApp;
        paramLoanappTemp.queryCriteria = ' where id = \'' + this.recordId + '\''
        this.paramsLoanApp = { ...paramLoanappTemp };
    }
    @wire(getSobjectDatawithRelatedRecords, { params: '$paramsLoanApp' })
    handleAppKyc(result) {
        this.wiredLoanData = result;
        if (result.data) {
            console.log('Loan app data=', result.data);
            if (result.data.parentRecord) {
                //  this.loanAppId = result.data.parentRecord.Id;

                this.rmSMName = result.data.parentRecord.RMSMName__c;
                this.JourneyType = result.data.parentRecord.Lead__r.LeadJuryBY__c;
                if (this.JourneyType == 'DSA') {
                    this.RMDSAName = result.data.parentRecord.Lead__r.OwnerId;
                }
                else {
                    this.RMDSAName = result.data.parentRecord.RMSMName__c;
                }
            }

        }
        if (result.error) {
            console.error('Loan app error=', result.error);
        }
    }

    connectedCallback() {
        if(this.selectedValue && this.selectedValue.length > 0){
            this.selectedValueList = [...this.selectedValueList,...this.selectedValue]
        }
        this.isReturnToRM = true;
        console.log('returnToRmOptions ', this.returnToRmOptions);

    }
    @track propFields = true;
    @track propOwnerSelectList = [];
    @track selectedValueList = [];

    handleSelectPropertOwners(event) {
        this.selectedValueList = event.detail;
        this.propOwnerSelectList = event.detail;
        console.log('kfasfk', this.propOwnerSelectList);
        this.propOnwerSaveHandler();
    }

    @track resultOfCompareArrays = [];
    propOnwerSaveHandler() {
        let arrayOfSelectedValues = [];
        let alloptOfOwner = [];
        arrayOfSelectedValues = this.propOwnerSelectList;
        alloptOfOwner = this.returnToRmOptions;

        this.resultOfCompareArrays = alloptOfOwner
            .filter((o) => arrayOfSelectedValues.find((x) => x === o.value))
            .map((o) => o.label);
        console.log('property owner save handler', this.resultOfCompareArrays);
    }
    handleDeletedPillValue(event) {
        let deletedApplValue = event.detail;
        console.log('deletedApplValue is ' , deletedApplValue);
        
        if (this.selectedValueList) {
            this.selectedValueList = this.selectedValueList.filter(item => item !== deletedApplValue);
            console.log('Updated Return RM Remarks Array:', this.selectedValueList);
        }
    }
    
    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(evt);
    }

    closeModalCPA() {
        this.isReturnToRM = false;
        console.log('before');
        // this.showToast("Success", "success", "popup closed");
        console.log('after');
         this.fireCustomEvent(null, null, null);
    }

    @track applicantId;
    getApplicantDetails() {
        if(this.selectedValueList && this.selectedValueList.length > 0){
            this.spinnerEvent(true);
            let arra = ['P'];
            let params = {
                ParentObjectName: 'Applicant__c',
                parentObjFields: ['Id', 'ApplType__c'],
                queryCriteria: ` where ApplType__c IN ('${arra.join("','")}') AND LoanAppln__c = '${this.recordId}'`,
            }
            getSobjectData({ params: params })
                .then((result) => {
                    console.log('applicant data ', JSON.stringify(result));
                    if (result.parentRecords) {
                        this.applicantId = result.parentRecords[0].Id;
                    }
                    // this.showSpinner = false;
                    if (this.applicantId) {
                        this.getDocumentDetails();
                    }
                })
                .catch((error) => {
                    this.fireCustomEvent('Error', 'error', 'Error Occured in getting Document Details Data');
                    console.log('Error In getting Applicant Data is ', error);
                    //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
                });
        }else{
            this.fireCustomEvent('Error', 'error', 'Select Reason for returning applciation to RM');
        }
    }
    getDocumentDetails() {
        // let currApplId = localStorage.getItem("currentApplTabId");

        let count = 0;

        /*let params = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'DocTyp__c', 'MrkErr__c', 'Rmrk__c'],
            queryCriteria: ' where Appl__c = \'' + currApplId + '\''
        }
        
        // Appl__c
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Document Details Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    result.parentRecords.forEach(item => {
                        if (item.Rmrk__c && item.Rmrk__c != '') {
                            count += 1;
                        }
                    })
                    if (count > 0) {
                        console.log('Count at end is ', count);
                        this.changeSubstagetoPloginQu();
                    } else {
                        this.fireCustomEvent('Error', 'error', ReturnTo_ErrorMessage);
                    }
                    console.log('Count at end is ', count);
                }
                // this.showSpinner = false;
            })

            .catch((error) => {
                this.fireCustomEvent('Error', 'error', 'Error Occured in getting Document Details Data');
                console.log('Error In getting Document Detail Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });*/


        let applParams = {
            ParentObjectName: 'Applicant__c',
            ChildObjectRelName: 'Applicant_Document_Details__r',
            parentObjFields: ['Id', 'REMARK__c'],
            childObjFields: ['Id', 'DocTyp__c', 'MrkErr__c', 'Rmrk__c'],
            queryCriteria: ' where Id = \'' + this.applicantId + '\'',
        }
        getSobjDtwithFltrRelatedRecordsWithoutCache({ params: applParams })
            .then(data => {
                if (data) {
                    let currApplData = data[0].parentRecord;
                    let docDetails = data[0].ChildReords;
                    console.log('currApplData', currApplData)
                    console.log('docDetails', docDetails)
                    let isRemarkPresent = false;
                    if (currApplData.REMARK__c) {
                        isRemarkPresent = true;
                    }
                    else {
                        if (docDetails) {
                            docDetails.forEach(item => {
                                if (item.Rmrk__c && item.Rmrk__c != '') {
                                    isRemarkPresent = true;
                                }
                            })
                        }

                    }

                    if (isRemarkPresent) {
                        console.log('Count at end is ', count);
                        this.changeSubstagetoPloginQu();
                    } else {
                        this.fireCustomEvent('Error', 'error', ReturnTo_ErrorMessage);
                    }
                }
            })

    }

    @track parentRecord = {};
    changeSubstagetoPloginQu() {

        this.spinnerEvent(true);

        // this.fireCustomEvent(false);
        // let parentRecord = {};
        // parentRecord['Id'] = this.recordId;
        // parentRecord.sobjectType = 'LoanAppl__c';
        // parentRecord['SubStage__c'] = 'Pre login Query';
        // parentRecord['OwnerId'] = this.rmSMName ? this.rmSMName : '';
        // parentRecord['CPASubSt__c'] = 'FTNR';

        if (this.JourneyType == 'DSA') {
            // let parentRecord = {};
            this.parentRecord['Id'] = this.recordId;
            this.parentRecord.sobjectType = 'LoanAppl__c';
            this.parentRecord['SubStage__c'] = 'DSA Pre Login Query';
            this.parentRecord['OwnerId'] = this.RMDSAName ? this.RMDSAName : '';
           // Ensure selectedValueList is an array and has values
            this.parentRecord['ReturnRMRemarks__c'] = this.selectedValueList && this.selectedValueList.length > 0 
              ? this.selectedValueList.join(';') 
             : '';

            // this.parentRecord['CPASubSt__c'] = 'FTNR';
        } else {
            //let parentRecord = {};
            this.parentRecord['Id'] = this.recordId;
            this.parentRecord.sobjectType = 'LoanAppl__c';
            this.parentRecord['SubStage__c'] = 'Pre Login Query';
            this.parentRecord['OwnerId'] = this.RMDSAName ? this.RMDSAName : '';
            this.parentRecord['ReturnRMRemarks__c'] = this.selectedValueList && this.selectedValueList.length > 0 
            ? this.selectedValueList.join(';') 
           : '';
            // this.parentRecord['CPASubSt__c'] = 'FTNR';
        }
        console.log('this.parentRecord', JSON.stringify(this.parentRecord))
        let upsertData = {
            parentRecord: this.parentRecord,
            ChildRecords: null,
            ParentFieldNameToUpdate: ''
        }
        console.log('upsertData ==>', JSON.stringify(upsertData));

        upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
            .then(result => {
                //this.showToast("Success", "success", "Loan application Return Successfully!");
                console.log('toast completed');
                this.closeModalCPA();
                this.fireCustomEvent('Success', 'success', ReturnTo_SuccessMessage);

            }).catch(error => {
                //this.showToast("Error", "error", "Error Returning Loan Application" + error.message);
                this.fireCustomEvent('Error', 'error', 'Error Returning Loan Application');

                console.log(error);
            })

    }
    fireCustomEvent(title, vart, msg) {
        const selectEvent = new CustomEvent('customaction', {
            detail: { title: title, variant: vart, message: msg, from: "ReturnToRM" }
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }

    spinnerEvent(val) {
        const selectEvent = new CustomEvent('spinner', {
            detail: val
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }
}