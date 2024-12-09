import { LightningElement, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';
export default class Trigger_CKYC_Button extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track showSpinner = true;

    connectedCallback() {

        setTimeout(() => {
            this.showSpinner = false;
            this.getApplicants();
        }, 2000);


    }
    getApplicants() {
        console.log("get applicant called", this.recordId, this.objectApiName);
        this.applParams.queryCriteria = '  where LoanAppln__c = \'' + this.recordId + '\' AND ( ApplType__c = \'' + 'P' + '\'' + ' OR ApplType__c = \'' + 'G' + '\'' + ' OR ApplType__c = \'' + 'C' + '\')'
        getSobjectDataNonCacheable({ params: this.applParams })
            .then((result) => {
                console.log('result Applicant__c', result);
                let res = JSON.parse(JSON.stringify(result.parentRecords))
                // this.applicantList = result.parentRecords;
                let appList = [];
                res.forEach(element => {
                    let appdata = element;
                    appdata['selectCheckbox'] = false;
                    appdata['disable'] = false;
                    appList.push(appdata);
                });

                console.log('result applicantList', appList);
                this.getCkycStatus(appList);
            })
            .catch((error) => {
                console.error('Error in get Applicant__c', error)
            })


    }
    @track initiateCkycFor = [];
    handleAddForCKYC(event) {
        let name = event.target.name;
        let selectedRecordId = event.target.dataset.recordid;
        let val = event.target.checked;

        if (name === 'ckyc' && selectedRecordId) {
            let searchDocNew = this.applicantList.find((doc) => doc.Id == selectedRecordId);
            if (searchDocNew) {
                searchDocNew['selectCheckbox'] = val;
                if (val == false) {
                    this.initiateCkycFor = this.initiateCkycFor.filter(obj => !(obj.Id == selectedRecordId));
                } else {
                    this.initiateCkycFor.push(searchDocNew)
                }
            }
        }
        console.log('initiateCkycFor', JSON.stringify(this.initiateCkycFor));
    }
    @track
    applParams = {
        ParentObjectName: 'Applicant__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'TabName__c', 'toLabel(ApplType__c)', 'Constitution__c'],
        childObjFields: [],
        queryCriteria: ' '
    }
    applicantList = [];
    triggerCKYC() {
        this.showSpinner = true;
        //   getApplicants() { }


        let createCkycINtMszList = [];
        if (this.initiateCkycFor && this.initiateCkycFor.length > 0) {
            this.initiateCkycFor.forEach(applicant => {
                let fields = {};
                // fields.sobjectType = 'IntgMsg__c';
                fields.Name = 'CKYC API';
                fields.BU__c = 'HL / STL';
                fields.RefId__c = applicant.Id;
                fields.Status__c = 'New';
                fields.MStatus__c = 'Blank';
                fields.RefObj__c = 'Applicant__c';
                fields.Svc__c = 'CKYC API';
                fields.IsActive__c = true;
                fields.Trigger_Platform_Event__c = true;
                fields.sobjectType = "IntgMsg__c";
                createCkycINtMszList.push(fields);
                //  this.createIntMsg(fields, 'CKYC API');

                fields = {};
                // fields.sobjectType = 'IntgMsg__c';
                fields.Name = 'CKYC ATTACHMENT';
                fields.BU__c = 'HL / STL';
                fields.RefId__c = applicant.Id;
                fields.Status__c = 'New';
                fields.MStatus__c = 'Blank';
                fields.RefObj__c = 'Applicant__c';
                fields.Svc__c = 'CKYC ATTACHMENT';
                fields.IsActive__c = true;
                fields.Trigger_Platform_Event__c = true;
                fields.sobjectType = "IntgMsg__c";
                createCkycINtMszList.push(fields);
                // this.createIntMsg(fields, 'CKYC ATTACHMENT');
            });
            this.upsertMultipleRec(createCkycINtMszList);
        } else {
            this.showSpinner = false;
            // this.noBtn();
            this.showToastMessage('Error', 'Please select at least One applicant', 'error', 'sticky');
        }

    }

    createIntMsg(fieldsInt, name) {
        const recordInput = {
            apiName: 'IntgMsg__c',
            fields: fieldsInt
        };
        console.log('integration msg ', recordInput);
        createRecord(recordInput).then((result) => {
            console.log('createIntMsg Record Created :: ', result.id, result);
            if (name === 'CKYC ATTACHMENT') {
                console.log('CKYC ATTACHMENT Record Created :: ', result.id, result);
            }
            if (name === 'CKYC API') {
                console.log('CKYC API Record Created :: ', result.id, result);
            }
        }).catch((error) => {
            console.log('Error  in createIntMsg ', error);
            this.showToastMessage('Error', 'Error in creting integration Message ', 'error', 'sticky');

            // this.showToastMessage('Error creating Integration record', error.body.message, 'error', 'dismissable')
        });
    }

    noBtn() {
        this.dispatchEvent(new CloseActionScreenEvent());
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
    upsertMultipleRec(newArray) {
        upsertSObjectRecord({ params: newArray })
            .then((result) => {
                console.log('upsertMultipleRec ', newArray, result);
                this.startPollingForInt();
                this.startCountForTimeOut();
                // this.showSpinner = false;
                // this.noBtn();
            })
            .catch((error) => {
                this.showSpinner = false;
                this.noBtn();
                this.showToastMessage('Error', 'Error in creting integration Message ', 'error', 'sticky');
            });
    }
    startPollingForInt() {
        console.log('Polling has started ')
        this.poolingInterval = setInterval(() => {
            this.getAppRecForCkycStatus();
        }, 5000);
    }
    timeoutInterval;
    startCountForTimeOut() {
        this.timeoutInterval = setTimeout(() => {
            this.showSpinner = false;
            this.showFinalErrorMsz();
        }, 30000);
    }

    poolingInterval;
    applParamsCKYC = {
        ParentObjectName: 'Applicant__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'TabName__c', 'CKYC_Attachment_ErrorMessage__c', 'CKYC_Attachment_API_Status__c', 'CKYC_API_Status__c', 'CKYC_API_ErrorMessage__c'],
        childObjFields: [],
        queryCriteria: ' '
    }
    mszAfterCKWCList = [];
    @track finalStatus;
    getAppRecForCkycStatus() {
        this.applParamsCKYC.queryCriteria = '  where LoanAppln__c = \'' + this.recordId + '\' AND ( ApplType__c = \'' + 'P' + '\'' + ' OR ApplType__c = \'' + 'G' + '\'' + ' OR ApplType__c = \'' + 'C' + '\')'
        getSobjectDataNonCacheable({ params: this.applParamsCKYC })
            .then((result) => {
                console.log('result Applicant__c CKYC ', result);

                if (result.parentRecords && result.parentRecords.length > 0) {
                    let res = JSON.parse(JSON.stringify(result.parentRecords))
                    this.finalStatus = res;
                    console.log('result Applicant__c CKYC ', JSON.stringify(res));
                    let applicantLength = res.length;
                    let totalExpSuccessmszCnt = applicantLength * 2;
                    res.forEach(ele => {
                        let sucessCnt = 0;
                        let failureCount = 0;
                        let mszAfterCKWC = { appId: ele.Id, tabName: ele.TabName__c };
                        if (ele.CKYC_API_Status__c) {
                            mszAfterCKWC['CKYC_API_Status'] = ele.CKYC_API_Status__c;
                            if (ele.CKYC_API_Status__c == 'Success') {
                                sucessCnt = sucessCnt + 1;
                                // let searchDocNew = this.mszAfterCKWCList.find((doc) => doc.appId && doc.appId == ele.Id && doc.CKYC_API_Status != 'Success');
                                // if (searchDocNew) {
                                //     searchDocNew.CKYC_API_Status = ele.CKYC_API_Status__c;

                                //     //  this.mszAfterCKWCList.push(mszAfterCKWC);
                                // } else {
                                //     this.mszAfterCKWCList.push(searchDocNew);
                                // }
                            } else if (ele.CKYC_API_Status__c == 'Failure') {

                                if (ele.CKYC_API_ErrorMessage__c) {
                                    failureCount = failureCount + 1;
                                    // let searchDocNew = this.mszAfterCKWCList.find((doc) => doc.appId && doc.appId == ele.Id && doc.CKYC_API_Status != 'Success');
                                    // if (searchDocNew) {
                                    //     searchDocNew.CKYC_ErrorMessage = ele.CKYC_API_ErrorMessage__c;
                                    //     // searchDocNew['CKYC_ErrorMessage'] = ele.CKYC_API_ErrorMessage__c;
                                    // } else {
                                    //     this.mszAfterCKWCList.push(searchDocNew);
                                    // }
                                }
                            }

                        }
                        // else {
                        //     let searchDocNew = this.mszAfterCKWCList.find((doc) => doc.appId && doc.appId == ele.Id);
                        //     if (searchDocNew) {
                        //         searchDocNew['CKYC_API_Status'] = 'Error';
                        //         searchDocNew['CKYC_ErrorMessage'] = 'No Resp ';
                        //     } else {
                        //         mszAfterCKWC['CKYC_API_Status'] = 'Error';
                        //         mszAfterCKWC['CKYC_ErrorMessage'] = 'No Resp ';
                        //         this.mszAfterCKWCList.push(mszAfterCKWC);
                        //     }

                        // }
                        if (ele.CKYC_Attachment_API_Status__c) {
                            mszAfterCKWC['CKYC_Attachment_API_Status__c'] = ele.CKYC_Attachment_API_Status__c;
                            if (ele.CKYC_Attachment_API_Status__c == 'Success') {
                                sucessCnt = sucessCnt + 1;
                                // let searchDocNew = this.mszAfterCKWCList.find((doc) => doc.appId && doc.appId == ele.Id && doc.CKYC_Attachment_API_Status != 'Success');
                                // if (searchDocNew) {
                                //     mszAfterCKWC['CKYC_Attachment_API_Status__c'] = ele.CKYC_Attachment_API_Status__c;
                                // } else {
                                //     this.mszAfterCKWCList.push(searchDocNew);
                                // }
                            } else if (ele.CKYC_Attachment_API_Status__c == 'Failure') {
                                if (ele.CKYC_Attachment_ErrorMessage__c) {
                                    failureCount = failureCount + 1;
                                    // let searchDocNew = this.mszAfterCKWCList.find((doc) => doc.appId && doc.appId == ele.Id && doc.CKYC_Attachment_API_Status != 'Success');
                                    // if (searchDocNew) {
                                    //     searchDocNew['CKYC_Attachment_ErrorMessage'] = ele.CKYC_API_ErrorMessage__c;
                                    // } else {
                                    //     this.mszAfterCKWCList.push(searchDocNew);
                                    // }
                                }
                            }

                        }
                        // else {
                        //     let searchDocNew = this.mszAfterCKWCList.find((doc) => doc.appId && doc.appId == ele.Id);
                        //     if (searchDocNew) {
                        //         searchDocNew['CKYC_Attachment_API_Status'] = 'Error';
                        //         searchDocNew['CKYC_Attachment_ErrorMessage'] = 'No Resp ';
                        //     } else {
                        //         mszAfterCKWC['CKYC_Attachment_API_Status'] = 'Error';
                        //         mszAfterCKWC['CKYC_Attachment_ErrorMessage'] = 'No Resp ';
                        //         this.mszAfterCKWCList.push(mszAfterCKWC);
                        //     }


                        // }
                        if (sucessCnt === totalExpSuccessmszCnt || (totalExpSuccessmszCnt === failureCount + sucessCnt)) {
                            clearTimeout(this.timeoutInterval);
                            this.showFinalErrorMsz();
                        }
                    });
                }

            })
            .catch((error) => {
                console.error('Error in get Applicant__c', error)
                this.showSpinner = false;
                this.noBtn();
            })
    }
    showFinalErrorMsz() {
        this.showSpinner = false;
        this.noBtn();
        clearInterval(this.poolingInterval);
        console.log(' Timeout Error Msz ', this.finalStatus, this.initiateCkycFor);

        this.finalStatus.forEach(ele => {

            if (this.initiateCkycFor.find(element => element.Id === ele.Id)) {
                if (ele.CKYC_API_Status__c) {
                    if (ele.CKYC_API_Status__c === "Success") {

                        this.showToastMessage('Success', ele.TabName__c + ' : CKYC  Success  ', 'Success', 'sticky');


                    } else if (ele.CKYC_API_Status__c === "Failure") {
                        if (ele.CKYC_API_ErrorMessage__c) {
                            this.showToastMessage('Error', ele.TabName__c + ' : Error Occured in CKYC : ' + ele.CKYC_API_ErrorMessage__c, 'error', 'sticky');
                        } else {
                            this.showToastMessage('Error', ele.TabName__c + ' : Error Occured in CKYC  ', 'error', 'sticky');
                        }

                    }
                }

                if (ele.CKYC_Attachment_API_Status__c) {
                    if (ele.CKYC_Attachment_API_Status__c === "Success") {

                        this.showToastMessage('Success', ele.TabName__c + ' : CKYC  Attachment Success  ', 'Success', 'sticky');


                    } else if (ele.CKYC_Attachment_API_Status__c === "Failure") {
                        if (ele.CKYC_Attachment_ErrorMessage__c) {
                            this.showToastMessage('Error', ele.TabName__c + ' : Error Occured in CKYC Attachment: ' + ele.CKYC_Attachment_ErrorMessage__c, 'error', 'sticky');
                        } else {
                            this.showToastMessage('Error', ele.TabName__c + ' : Error Occured in CKYC Attachment: ', 'error', 'sticky');
                        }

                    }
                }
            }

        });


    }

    getCkycStatus(appList) {
        this.applParamsCKYC.queryCriteria = '  where LoanAppln__c = \'' + this.recordId + '\' AND ( ApplType__c = \'' + 'P' + '\'' + ' OR ApplType__c = \'' + 'G' + '\'' + ' OR ApplType__c = \'' + 'C' + '\')'
        getSobjectDataNonCacheable({ params: this.applParamsCKYC })
            .then((result) => {
                console.log('result Applicant__c CKYC ', result);

                if (result.parentRecords && result.parentRecords.length > 0) {
                    let res = JSON.parse(JSON.stringify(result.parentRecords))
                    this.finalStatus = res;
                    console.log('result Applicant__c CKYC ', JSON.stringify(res));
                    res.forEach(ele => {
                        if (ele.CKYC_API_Status__c == 'Success' && ele.CKYC_Attachment_API_Status__c == 'Success') {
                            appList.forEach(element => {
                                if (element.Id === ele.Id) {
                                    element.disable = true; // to desable whose report is generated 
                                }
                            });
                        }
                    });
                }
                this.applicantList = appList;

            })
            .catch((error) => {
                console.error('Error in get Applicant__c', error)
                this.showSpinner = false;
                this.noBtn();
            })
    }



}