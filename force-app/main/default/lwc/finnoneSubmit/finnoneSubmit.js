import { LightningElement, api, track } from 'lwc';

import { createRecord } from "lightning/uiRecordApi";


import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import finnOneIntiDtTime from '@salesforce/schema/LoanAppl__c.FinnInitiationDtTime__c';
import Stage from '@salesforce/schema/LoanAppl__c.Stage__c';
import subStage from '@salesforce/schema/LoanAppl__c.SubStage__c';
import status from '@salesforce/schema/LoanAppl__c.Status__c';
import OwnerId from '@salesforce/schema/LoanAppl__c.OwnerId';
import checkExpiry from '@salesforce/apex/VerificationExpiryController.checkExpiry';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds'
import getSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';

// Custom labels
import FinnonSubmit_Ndc_ErrorMessage from '@salesforce/label/c.FinnonSubmit_Ndc_ErrorMessage';
import FinnonSubmit_SuccessMessage from '@salesforce/label/c.FinnonSubmit_SuccessMessage';

export default class FinnoneSubmit extends NavigationMixin(LightningElement) {
    label = {
        FinnonSubmit_Ndc_ErrorMessage,
        FinnonSubmit_SuccessMessage

    }
    @api recordId;
    @api objectApiName;
    @track showSpinner = true;
    loanApplicationQueueId;
    arr = [];
    connectedCallback() {

        setTimeout(() => {
            this.showSpinner = false;
        }, 2000);

        let grpName = 'CPA Pool';
        let type = 'Queue';
        let params = {
            ParentObjectName: 'Group',
            parentObjFields: ["Id", "Name"],

            queryCriteria: ' where name = \'' + grpName + '\' AND Type = \'' + type + '\''
        };
        console.log("params", params);
        getSobjectDatawithRelatedRecords({ params: params })
            .then((res) => {

                this.loanApplicationQueueId = res.parentRecord.Id;

            })

        //this.getapplicantData();
    }

    getapplicantData() {

        this.showSpinner = true;
        let returnArr = [];
        let appType = ['P', 'C', 'G'];
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'Name', 'CKYC_Number__c'],
            // queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND ApplType__c = \'' + appType + '\''
            queryCriteria: ' Where LoanAppln__c = \'' + this.recordId + '\'  AND ApplType__c  IN (\'' + appType.join('\', \'') + '\')'
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Applicant Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.appData = result.parentRecords;
                }

                this.showSpinner = false;
                console.log('Applicant Data is ', this.appData);
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Document Dispatch Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    countOpsVer = 0;
    opsVerified = false;
    // handleSubmit(event) {
    //     event.preventDefault();       

    //     let params = {
    //         ParentObjectName: 'NDC__c',
    //         parentObjFields: ['Id', 'OpsVer__c'],
    //         queryCriteria: ' where LoanAppl__c = \'' + this.recordId + '\''
    //     }
    //     getSobjectData({ params: params })
    //         .then((result) => {
    //             console.log('Ndc Recordds Data is ', result);
    //             if (result.parentRecords) {
    //                 console.log('result.parentRecords length is ', result.parentRecords.length);
    //                 result.parentRecords.forEach(item => {
    //                     if (item.OpsVer__c) {
    //                         this.countOpsVer++;
    //                     }
    //                 });

    //                 console.log('countOpsVer  ', this.countOpsVer);
    //                 if (this.countOpsVer === result.parentRecords.length) {
    //                     const fields = event.detail.fields;
    //                     this.template.querySelector('lightning-record-edit-form').submit(fields);
    //                     // this.dispatchEvent(new CloseActionScreenEvent());
    //                 } else {
    //                     this.dispatchEvent(
    //                         new ShowToastEvent({
    //                             title: 'Error',
    //                             message: 'Verify Ndc Records',
    //                             variant: 'error'
    //                         })
    //                     );
    //                     this.dispatchEvent(new CloseActionScreenEvent());
    //                 }
    //             }

    //             this.showSpinner = false;
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getting Ndc records Data is ', error);
    //             //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
    //         });



    // }
    // handleSuccess(e) {
    //     this.dispatchEvent(new CloseActionScreenEvent());
    //     this.dispatchEvent(
    //         new ShowToastEvent({
    //             title: 'Success',
    //             message: 'Loan Application Sent For Approval Successfully!',
    //             variant: 'success'
    //         })

    //     );
    //     this[NavigationMixin.Navigate]({
    //         type: "standard__objectPage",
    //         attributes: {
    //             objectApiName: "LoanAppl__c",
    //             actionName: "list"
    //         }
    //     });
    // }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    @track pendingDisBool = true;
    @track effStrtDtBool = true;
    @track dtOfDisBool = true;
    getLoanAppData() {
        //this.dispatchEvent(new CloseActionScreenEvent());
        this.showSpinner = true;
        let params = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Id', 'PendingDisbursalAmount__c', 'EffectiveNextIntStartDt__c'],
            queryCriteria: ' where Id = \'' + this.recordId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Loan App Data is ', result);
                if (result.parentRecords) {
                    if (result.parentRecords[0].PendingDisbursalAmount__c && result.parentRecords[0].PendingDisbursalAmount__c != 0) {
                        this.pendingDisBool = false;
                    }
                    // this.pendingDisAmt = result.parentRecords[0].PendingDisbursalAmount__c;
                    // if (result.parentRecords[0].EffectiveNextIntStartDt__c && new Date(result.parentRecords[0].EffectiveNextIntStartDt__c).toDateString() < new Date().toDateString()) {
                    //     this.effStrtDtBool = false;
                    // }



                    if (result.parentRecords[0].EffectiveNextIntStartDt__c) {
                        let effectiveDate = new Date(result.parentRecords[0].EffectiveNextIntStartDt__c);
                        let today = new Date();
                        today.setHours(0, 0, 0, 0); // Set time to beginning of the day for comparison
                        if (effectiveDate < today) {
                            this.effStrtDtBool = false;
                        }
                    }
                    // this.effStrtDt = result.parentRecords[0].EffectiveNextIntStartDt__c;
                }
                this.getDisValData();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error in Getting Loan Rec Data is ', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error in Getting Loan Rec Data',
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }

    getDisValData() {
        // this.showSpinner = true;
        let disDesc = 'TRANCHE-1';
        let params = {
            ParentObjectName: 'Disbursement__c',
            parentObjFields: ['Id', 'Date_of_Disbur__c'],
            queryCriteria: ' where Loan_Appli__c = \'' + this.recordId + '\' AND DisbrDiscription__c = \'' + disDesc + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Disbursement Data is ', result);
                if (result.parentRecords) {
                    // if (result.parentRecords[0].Date_of_Disbur__c && new Date(result.parentRecords[0].Date_of_Disbur__c).toDateString() != new Date().toDateString()) {
                    //     this.dtOfDisBool = false;
                    // }

                    if (result.parentRecords[0].Date_of_Disbur__c) {
                        let effectiveDate = new Date(result.parentRecords[0].Date_of_Disbur__c);
                        let today = new Date();
                        today.setHours(0, 0, 0, 0); // Set time to beginning of the day for comparison
                        // Removing time component from effectiveDate
                        effectiveDate.setHours(0, 0, 0, 0);
                        if (effectiveDate.getTime() !== today.getTime()) {
                            this.dtOfDisBool = false;
                        }
                    }
                    // new Date(this.recordData['ReceivedDt__c']) > new Date()
                }

                this.getVerificationExpDet();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error in Getting Loan Rec Data is ', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error in Getting Disbursement Data',
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());

                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }


    @track expDetails = []
    getVerificationExpDet() {
        checkExpiry({ loanApplicationId: this.recordId })
            .then((result) => {
                console.log('VerificationExpiry Details', JSON.stringify(result));
                // let DevApproved = true;
                if (result && result.length > 0) {
                    this.expDetails = result;
                }
                this.handleFinnoneSubmit();

            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting checkExpiry is ', error);
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


    @track screenNames = new Set();
    @track sectionNames = new Set();
    handleFinnoneSubmit() {
        //this.dispatchEvent(new CloseActionScreenEvent());
        // this.showSpinner = true;
        let params = {
            ParentObjectName: 'NDC__c',
            parentObjFields: ['Id', 'OpsVer__c', 'OpsQuery__c', 'ScreenNames__c', 'NDC_Section__c'],
            queryCriteria: ' where LoanAppl__c = \'' + this.recordId + '\' AND IsInvalid__c = false'
        }
        const devSection = ['UW Deviation', 'Legal Deviations', 'Post Sanction Auto Deviation'];
        const deviationSection = new Set(devSection);
        getSobjectData({ params: params })
        .then((result) => {
                console.log('Ndc Recordds Data is ', result);
                if (result.parentRecords) {
                    console.log('result.parentRecords length is ', result.parentRecords.length);
                    result.parentRecords.forEach(item => {
                        if ((item.OpsVer__c && !item.OpsQuery__c ) || deviationSection.has(item.NDC_Section__c)) { //LAK-7478
                            this.countOpsVer++;

                        } else {
                            if (item.ScreenNames__c) {
                                this.screenNames.add(item.ScreenNames__c);
                            } else if (item.NDC_Section__c) {
                                this.sectionNames.add(item.NDC_Section__c);
                            }
                        }
                    });

                    console.log('countOpsVer  ', this.countOpsVer);
                    if (this.countOpsVer === result.parentRecords.length && this.dtOfDisBool && this.effStrtDtBool && this.pendingDisBool && this.expDetails.length == 0) {
                        let fields = {};
                        // fields['sobjectType'] = 'IntgMsg__c';
                        fields['Name'] = 'Loan Boarding'; //serviceName;//'KYC OCR'
                        fields['BU__c'] = 'HL / STL';
                        fields['IsActive__c'] = true;
                        fields['Svc__c'] = 'Loan Boarding'; //serviceName;
                        fields['ExecType__c'] = 'Async';
                        fields['Status__c'] = 'New';
                        fields['Mresp__c'] = 'Blank';
                        fields['Outbound__c'] = true;
                        fields['Trigger_Platform_Event__c'] = false;
                        fields['RefObj__c'] = 'LoanAppl__c';
                        fields['RefId__c'] = this.recordId;
                        fields['ParentRefObj__c'] = "LoanAppl__c";
                        fields['ParentRefId__c'] = this.recordId;
                        // this.upsertIntRecord(fields);
                        this.createIntMsg(fields)
                    } else {
                        this.showSpinner = false;
                        if (this.screenNames && this.screenNames.size > 0) {
                            let strr = Array.from(this.screenNames).join(',');
                            console.log('Screen Names are '.strr);
                            //this.ShowToastEventMe('Error', , 'error', 'sticky');
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Ops Verification Required (' + strr + ')',
                                    variant: 'error',
                                    mode: 'sticky'
                                })
                            );
                        }
                        if (this.sectionNames && this.sectionNames.size > 0) {
                            let str = Array.from(this.sectionNames).join(',');
                            console.log('Section Names Are '.str);
                            // this.ShowToastEventMe('Error', 'Please respond on Query Before Sending the Application back to Ops : (' + str + ')', 'error', 'sticky');
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: this.label.FinnonSubmit_Ndc_ErrorMessage + ': (' + str + ')',
                                    variant: 'error',
                                    mode: 'sticky'
                                })
                            );
                        }
                        if (!this.dtOfDisBool) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'First Tranche Date of Disbursement should be Equal to today date',
                                    variant: 'error',
                                    mode: 'sticky'
                                })
                            );
                        }

                        if (!this.effStrtDtBool) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Effective/interest date should be equal to Today Date/Future Date',
                                    variant: 'error',
                                    mode: 'sticky'
                                })
                            );
                        }
                        if (!this.pendingDisBool) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Pending Disbursal amount should be 0',
                                    variant: 'error',
                                    mode: 'sticky'
                                })
                            );
                        }
                        if (this.expDetails.length > 0) {
                            let str = ' ';
                            this.expDetails.forEach(item => {
                                str = str + item + ',';
                            })
                            if (str.endsWith(',')) {
                                str = str.slice(0, -1);
                            }
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Verification Expired for ' + str,
                                    variant: 'error',
                                    mode: 'sticky'
                                })
                            );

                        }

                        this.dispatchEvent(new CloseActionScreenEvent());
                    }
                }

                //this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Ndc records Data is ', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error in Getting NDC Records',
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());

                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    @track finnoneIntMsgId;
    createIntMsg(fieldsInt) {
        const recordInput = {
            apiName: 'IntgMsg__c',
            fields: fieldsInt
        };
        createRecord(recordInput).then((result) => {
            console.log('Paytm Integration Record Created ##405', result.id, result);

            this.finnoneIntMsgId = result.id;
            // this.startPolling();
            this.updateLoanApp();

        }).catch((error) => {
            // this.showSpinner = false
            console.log('Error ##789', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error Occured in Polling',
                    variant: 'error',
                    mode: 'sticky'
                })
            );
            this.dispatchEvent(new CloseActionScreenEvent());
            // this.showToastMessage('Error creating Integration record', error.body.message, 'error', 'dismissable')
        });
    }
    updateLoanApp() {
        let d = new Date();
        let newD = new Date(d.getTime());
        let currentDateTime = newD.toISOString();
        let upsertObjectParams = {
            parentRecord: {},
            ChildRecords: [],
            ParentFieldNameToUpdate: ''
        };
        upsertObjectParams.parentRecord.sobjectType = 'LoanAppl__c';
        upsertObjectParams.parentRecord.Id = this.recordId;
        upsertObjectParams.parentRecord[finnOneIntiDtTime.fieldApiName] = currentDateTime;
        console.log('upsertObjectParams:', upsertObjectParams);
        upsertSobjDataWIthRelatedChilds({ upsertData: upsertObjectParams })
            .then((result) => {
                console.log('success');
                console.log('result:', JSON.stringify(result));
                console.log('result:', result.parentRecord.Id);
                this.startPolling();
                // this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
                console.log('error while updating record:' + JSON.stringify(error));
            });
    }
    chequeInterval;
    @track respPayload = '';
    startPolling() {
        console.log('Polling has started ##875')
        this.chequeInterval = setInterval(() => {
            this.getIntRecord();
        }, 5000);
    }
    getIntRecord() {
        let paramsLoanApp = {
            ParentObjectName: 'IntgMsg__c',
            parentObjFields: ['Id', 'Status__c', 'Name', 'Resp__c'],
            queryCriteria: ' where Id = \'' + this.finnoneIntMsgId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('Int Msg data is', JSON.stringify(result));
                if (result.parentRecords) {
                    this.respPayload = result.parentRecords[0].Resp__c;
                    console.log('this.respPayload ', result.parentRecords[0].Resp__c);
                    if (result.parentRecords[0].Status__c === 'Responded' && result.parentRecords[0].Name === 'Loan Boarding') {
                        // this.getloanApplicationData();
                        // this.getDisbursemData();
                        //this.startPolling('loanApp')
                        this.getloanApplicationData();

                        console.log('Cleared ##468')
                    }
                    if (result.parentRecords[0].Status__c === 'Exception' && result.parentRecords[0].Name === 'Loan Boarding') {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Finnone Failed',
                                variant: 'error',
                                mode: 'sticky'
                            })
                        );
                        this.dispatchEvent(new CloseActionScreenEvent());
                        this.showSpinner = false;
                        clearInterval(this.chequeInterval);
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
    @track loanStatus;
    getDisbursemData() {
        let params = {
            ParentObjectName: 'Disbursement__c',
            parentObjFields: ['Id', 'Disbur_Status__c'],
            queryCriteria: ' where Loan_Appli__c = \'' + this.recordId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Disbursement Record Data is ', result);
                let count = 0;
                if (result.parentRecords && result.parentRecords.length > 0) {
                    result.parentRecords.forEach(item => {
                        if (item.Disbur_Status__c && item.Disbur_Status__c == 'DISBURSED') {
                            count++;
                        }
                    })
                }
                if (count == result.parentRecords.length) {
                    this.loanStatus = 'Fully Disbursed';
                } else {
                    this.loanStatus = 'Partially Disbursed';
                }
                this.getloanApplicationData();
            })
            .catch((error) => {
                this.showSpinner = false;
                this.dispatchEvent(new CloseActionScreenEvent());
                console.log('Error In getting Disbursement Data is ', error);
            });
    }
    getloanApplicationData() {
        let params = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Id', 'Loan_Boarding_API_Status__c', 'ErrorMessage__c'],
            queryCriteria: ' where Id = \'' + this.recordId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Loan Application Record Data is ', result);
                if (result.parentRecords) {
                    if (result.parentRecords[0].Loan_Boarding_API_Status__c == 'Success') {
                        // let upsertObjectParams = {
                        //     parentRecord: {},
                        //     ChildRecords: [],
                        //     ParentFieldNameToUpdate: ''
                        // };
                        // upsertObjectParams.parentRecord.sobjectType = 'LoanAppl__c';
                        // upsertObjectParams.parentRecord.Id = this.recordId;
                        // upsertObjectParams.parentRecord[Stage.fieldApiName] = 'Disbursed';
                        // upsertObjectParams.parentRecord[subStage.fieldApiName] = 'Additional Processing Pool';
                        // upsertObjectParams.parentRecord[status.fieldApiName] = this.loanStatus;
                        // upsertObjectParams.parentRecord[OwnerId.fieldApiName] = this.loanApplicationQueueId;
                        // console.log('upsertObjectParams:', upsertObjectParams);
                        // this.UpsertData(upsertObjectParams);
                        this.dispatchEvent(new CloseActionScreenEvent());
                        const event = new ShowToastEvent({
                            title: 'Success!',
                            message: this.label.FinnonSubmit_SuccessMessage,
                            variant: 'success',
                            mode: 'sticky'
                        });
                        this.dispatchEvent(event);
                        // this[NavigationMixin.Navigate]({
                        //     type: "standard__objectPage",
                        //     attributes: {
                        //         objectApiName: "LoanAppl__c",
                        //         actionName: "list"
                        //     }
                        // });
                        setTimeout(() => {
                            location.reload();
                        }, 3000);


                    } else {
                        console.log('this.respPayload in toast is ', this.respPayload);
                        // let newVar = this.respPayload.replaceAll('#', '/#').replaceAll('"', '/"').replaceAll(':', '/:').replaceAll(',', '/,').replaceAll('{', '/{').replaceAll('}', '/}');
                        let newVar = JSON.parse(this.respPayload);
                        // console.log('this.respPayload.errorDescription in toast is ', this.respPayload.errorDescription);
                        // console.log('newVar ', newVar);

                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: newVar.errorDescription,
                                // message: '/#/#DME NOT FOUND/#/#LOAN AMOUNT NOT FOUND/#/#tenureInMonths NOT FOUND/#/#loanPurpose NOT IN MASTERS/#/#CATEGORY NOT FOUND/#/#GENDER NOT FOUND/#/#MARITALSTATUS NOT FOUND/#/#Only 1 Mailing address for Primary Applicant is mandatory/#/# NUMBEROFINSTALLMENTS NOT FOUND/#/# RATEEMIFLAG NOT FOUND/#/# INSTRUMENTTYPE NOT FOUND',
                                variant: 'error',
                                mode: 'sticky'
                            })
                        );
                        this.dispatchEvent(new CloseActionScreenEvent());
                    }
                }

            })
            .catch((error) => {
                this.showSpinner = false;
                this.dispatchEvent(new CloseActionScreenEvent());
                console.log('Error In getting loan app record Data is ', error);
            });
    }
    UpsertData(params) {
        upsertSobjDataWIthRelatedChilds({ upsertData: params })
            .then((result) => {
                console.log('success');
                console.log('result:', JSON.stringify(result));
                console.log('result:', result.parentRecord.Id);
                this.showSpinner = false;
                const event = new ShowToastEvent({
                    title: 'Success!',
                    message: this.label.FinnonSubmit_SuccessMessage,
                    variant: 'success',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
                this[NavigationMixin.Navigate]({
                    type: "standard__objectPage",
                    attributes: {
                        objectApiName: "LoanAppl__c",
                        actionName: "list"
                    }
                });
                setTimeout(() => {
                    location.reload();
                }, 3000);
            })

            .catch(error => {
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
                console.log('error while updating record:' + JSON.stringify(error));

            });
    }

    noBtn() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}