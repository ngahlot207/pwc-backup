import { LightningElement, wire, api, track } from 'lwc';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import { createRecord, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import INTG_MSG from "@salesforce/schema/IntgMsg__c";
import NAME from "@salesforce/schema/IntgMsg__c.Name";
import REF_ID from "@salesforce/schema/IntgMsg__c.RefId__c";
import BU from "@salesforce/schema/IntgMsg__c.BU__c";
import IS_ACTIVE from "@salesforce/schema/IntgMsg__c.IsActive__c";
import SVC from "@salesforce/schema/IntgMsg__c.Svc__c";
import EXUC_TYPE from "@salesforce/schema/IntgMsg__c.ExecType__c";
import STATUS from "@salesforce/schema/IntgMsg__c.Status__c";
import REF_OBJ from "@salesforce/schema/IntgMsg__c.RefObj__c";
import DOC_API from "@salesforce/schema/IntgMsg__c.DocApi__c";
import OUTBOUND from "@salesforce/schema/IntgMsg__c.Outbound__c";
import PARENT_REF_ID from "@salesforce/schema/IntgMsg__c.ParentRefId__c";
import PARENT_REF_OBJ from "@salesforce/schema/IntgMsg__c.ParentRefObj__c";
import TRIGGER_PLATFORM_EVENT from "@salesforce/schema/IntgMsg__c.Trigger_Platform_Event__c";

export default class UrcVerificationTableOnOccupation extends LightningElement {
    @track showSpinner = false;
    @api loanAppId;
    @api hasEditAccess;
    @api borrowers;
    @track data = [];
    @track showModal = false;
    @track appDataDisplay = [];
    @track showSpinnerPopUp = false;
    @track initiateIntegrationFor = [];
    @track hasDocumentId;
    @track documentDetailId;
    @track showModalForFilePre = false;
    @track disableInitiatinAction = true;
    @track disableReintiate = false;
    @track InitateRetrigger = false; // tocheck retrigger 
    connectedCallback() {
        console.log('loanAppId : ', this.loanAppId);
        console.log('hasEditAccess : ', this.hasEditAccess);
        console.log('borrowers : ', this.borrowers);
        this.showSpinner = true;
        this.getEmpAndRetData();
    }
    getEmpAndRetData() {
        this.getApiRetriggerTrackerData();
    }
    getEmploymentRec() {

        this.data = [];
        if (this.borrowers.length >= 0) {
            let borrowersId = [];
            this.borrowers.forEach(element => {
                borrowersId.push(element.value)
            });
            let params = {
                ParentObjectName: 'ApplKyc__c',
                parentObjFields: ["Id", "Applicant__c", "Name_Match_Score__c", "Address__c", "HouseNo__c", "AddrLine1__c", "AddrLine2__c", "VillageTownCity__c", "State__c", "Pincode__c", "District__c", "Applicant__r.FullName__c", "tolabel(Applicant__r.ApplType__c)", "Applicant__r.Constitution__c", "Activity_URC__c", "ActivityDescription_URC__c", "URC_Number__c", "Industry_URC__c", "NIC_URC__c", "SubSector_URC__c", "TypeOfEnterprise_URC__c", "UdyamPrfName__c", "DateOfUdyamRegistration__c", "DteOfIncorp__c", "DteOfComm__c", "kycDoc__c"],
                //queryCriteria: ' Where kycDoc__c = \'' + 'Udyam Registration Certificate' + '\' AND Applicant__c  IN (\'' + borrowersId.join('\', \'') + '\') '
                queryCriteria: ' Where kycDoc__c = \'' + 'Udyam Registration Certificate' + '\' AND  Applicant__r.LoanAppln__c = \'' + this.loanAppId + '\''
            };

            getSobjectDataNonCacheable({ params: params })
                .then((result) => {
                    let appKycLoc = result.parentRecords;
                    let borrowersIdLoc = [];
                    if (appKycLoc) {
                        appKycLoc.forEach(ele => {
                            console.log('appKycLoc ==  ', ele.Applicant__c);
                            borrowersIdLoc.push(ele.Applicant__c);
                        });

                    }
                    console.log('borrowersIdLoc ==  ', borrowersIdLoc);
                    this.disableReintiate = true;
                    let empParams = {
                        ParentObjectName: 'ApplicantEmployment__c',
                        parentObjFields: ["Id", "LoanApplicant__c", "UdyamAPIStatus__c", "UdyamRegistrationNumber__c", "URC_UAC_application_ref_no__c", "Industry_URC__c"],
                        queryCriteria: ' Where  LoanApplicant__c  IN (\'' + borrowersIdLoc.join('\', \'') + '\') '
                    };
                    getSobjectDataNonCacheable({ params: empParams })
                        .then((res) => {
                            console.log('ApplicantEmployment__c data in val', res);
                            let appEmpRecList = res.parentRecords;
                            let applicantDetails = [];
                            let appKyc = result.parentRecords;
                            if (appKyc) {
                                for (let index = 0; index < appKyc.length; index++) {
                                    const res = appKyc[index];
                                    console.log('appkyc rec  == ', index, ' ', res);

                                    let appEmpRec = appEmpRecList.find((doc) => doc.LoanApplicant__c === res.Applicant__r.Id);
                                    if (appEmpRec) {

                                        let address = '';
                                        address = res.HouseNo__c ? res.HouseNo__c : '';
                                        address = address + (res.AddrLine1__c ? ' ' + res.AddrLine1__c : '');
                                        address = address + (res.AddrLine2__c ? ' ' + res.AddrLine2__c : '');
                                        address = address + (res.VillageTownCity__c ? ' ' + res.VillageTownCity__c : '');
                                        address = address + (res.State__c ? ' ' + res.State__c : '');
                                        address = address + (res.Pincode__c ? ' ' + res.Pincode__c : '');
                                        address = address + (res.District__c ? ' ' + res.District__c : '');

                                        let udyamStatusVal = false;
                                        if (res.URC_Number__c && appEmpRec.UdyamRegistrationNumber__c) {
                                            udyamStatusVal = this.removeSpecialCharsAndSpaces(res.URC_Number__c) == this.removeSpecialCharsAndSpaces(appEmpRec.UdyamRegistrationNumber__c) ? appEmpRec.UdyamAPIStatus__c == 'Success' ? true : false : false;
                                            console.log('appEmpRec.UdyamRegistrationNumber__c == ', appEmpRec.UdyamRegistrationNumber__c);
                                            console.log('res.URC_Number__c == ', res.URC_Number__c);
                                            console.log('appEmpRec.UdyamAPIStatus__c  == ', appEmpRec.UdyamAPIStatus__c);
                                            console.log('udyamStatusVal == ', udyamStatusVal);
                                        }
                                        //  udyamStatusVal = removeSpecialCharsAndSpaces(res.URC_Number__c) == (removeSpecialCharsAndSpaces(appEmpRec && appEmpRec.UdyamRegistrationNumber__c ? appEmpRec.UdyamRegistrationNumber__c : '')) ? appEmpRec.UdyamAPIStatus__c == 'Success' ? true : false : false;
                                        let localData = {
                                            id: res.Id,
                                            applicantId: res.Applicant__r.Id,
                                            applicantEmployment: appEmpRec && appEmpRec.Id ? appEmpRec.Id : '',
                                            name: res.Applicant__r && res.Applicant__r.FullName__c ? res.Applicant__r.FullName__c : '',
                                            applicantType: res.Applicant__r && res.Applicant__r.ApplType__c ? res.Applicant__r.ApplType__c : '',
                                            constitution: res.Applicant__r && res.Applicant__r.Constitution__c ? res.Applicant__r.Constitution__c : '',
                                            udyamRegistrationNumber: appEmpRec && appEmpRec.UdyamRegistrationNumber__c ? appEmpRec.UdyamRegistrationNumber__c : '',//res.URC_Number__c,
                                            udyamRegistrationNumberOld: appEmpRec && appEmpRec.UdyamRegistrationNumber__c ? appEmpRec.UdyamRegistrationNumber__c : '',
                                            documentUsedFor: res.kycDoc__c ? res.kycDoc__c : '',
                                            dateOfUdyamRegistration: res.DateOfUdyamRegistration__c,
                                            nameAsFilledInApplication: res.UdyamPrfName__c,
                                            nameMatchPercent: res.Name_Match_Score__c,
                                            dateOfIncorporation: res.DteOfIncorp__c,
                                            typeOfEnterprise: res.TypeOfEnterprise_URC__c,
                                            registeredNatureOfBusiness: res.Activity_URC__c,///ShopEstNatureBus__c

                                            addressAsPerURC: address,
                                            emailId: res.Email__c,
                                            certificate: 'URL to certificate',
                                            apiVerificationStatus: this.apiRetrgrTrcrData.length > 0 && this.apiRetrgrTrcrData.includes(res.Applicant__r.Id) ? 'Failure' : 'Success',   //appEmpRec.UdyamAPIStatus__c == null ? 'Failure' : appEmpRec.UdyamAPIStatus__c,
                                            errorMessage: appEmpRec.UdyamErrorMess__c ? appEmpRec.UdyamErrorMess__c : '',
                                            udyamAPIStatus: udyamStatusVal,// removeSpecialCharsAndSpaces(res.URC_Number__c) == (removeSpecialCharsAndSpaces(appEmpRec && appEmpRec.UdyamRegistrationNumber__c ? appEmpRec.UdyamRegistrationNumber__c : '')) ? appEmpRec.UdyamAPIStatus__c == 'Success' ? true : false : false,
                                            // udyamAPIStatus: this.apiRetrgrTrcrData.length > 0 && this.apiRetrgrTrcrData.includes(res.Applicant__r.Id) ? false : true, //appEmpRec.UdyamAPIStatus__c == 'Success' ? true : false,
                                            retriggerButton: 'Retrigger'

                                        }

                                        if ((localData.udyamAPIStatus === false)) {
                                            this.disableReintiate = false;
                                        }



                                        console.log('localData == ', localData);
                                        applicantDetails.push(localData);

                                        console.log('applicantDetails == ', applicantDetails);
                                    }
                                };
                            }
                            this.data = [];
                            this.data = applicantDetails;
                            this.showSpinner = false;
                        })
                        .catch((error) => {

                            this.showSpinner = false;
                            console.log('Error In upserting  ApplicantEmployment Details is ', error);
                        });
                    this.showSpinner = false;
                })
                .catch((error) => {

                    this.showSpinner = false;
                    console.log('Error In upserting  appKyc Details is ', error);
                });
        } else {
            this.showSpinner = false;
        }
    }

    handleRefreshClick() {
        this.showSpinner = true;
        this.getEmpAndRetData();
    }

    handleIntializationUrc() {
        this.showSpinner = true;
        this.initiateIntegrationFor = [];
        this.appDataDisplay = [];
        this.appDataDisplay = this.getLoanApplicationData();
        this.disableInitiatinAction = this.appDataDisplay.length > 0 ? false : true;
        this.showModal = true;
    }

    getLoanApplicationData() {
        this.appDataDisplay = [];
        let dataForReinitate = [];
        this.data.forEach(element => {
            console.log(' udyamAPIStatus: ', element.udyamAPIStatus);
            if (element.udyamAPIStatus == false) {
                dataForReinitate.push(element);
            }
        });
        return dataForReinitate;
    }

    handleReIntialization() {

        this.handleRetrigger();

    }

    handleClick(event) {
        console.log('record ', event.target.dataset.recordid);
        let selectedRecordId = event.target.dataset.recordid;
        console.log('value is', event.target.checked);
        console.log('All selected Records before ', this.appDataDisplay);
        let val = event.target.checked;
        let recordData = {};
        let searchDoc = this.appDataDisplay.find((doc) => doc.Id === selectedRecordId);
        let searchDocav = this.initiateIntegrationFor.find((doc) => doc.Id === selectedRecordId);
        if (searchDoc && searchDocav == null) {
            this.initiateIntegrationFor.push(searchDoc);
            console.log('searchDoc', searchDoc);
            //searchDoc = { ...searchDoc, selectCheckbox: val }

        }

        console.log('All selected Records', this.initiateIntegrationFor);
    }
    closeModal() {
        this.showModal = false;
        this.showSpinner = false;
    }

    handleRetrigger() {
        this.showSpinnerPopUp = true;
        console.log('handleRetrigger called ', this.initiateIntegrationFor);
        if (this.initiateIntegrationFor.length > 0) {
            this.initiateIntegrationFor.forEach(ele => {
                console.log('handleRetrigger called  ele', ele);
                let appkyc = ele;
                let applicantId = ele.applicantId;
                let appKycId = ele.id;
                let appEmploymentid = ele.applicantEmployment;
                // let urcNo = ele.udyamRegistrationNumber;
                console.log('appKyc :: ', appkyc, ' :: applicantId :: ', applicantId, ' :: appEmploymentid :: ', appEmploymentid);
                if (appKycId && applicantId && appEmploymentid) {
                    let serviceName = "Udyam Registration Check";
                    this.createIntegrationMsg(appKycId, applicantId, serviceName);

                } else {
                    this.showSpinner = false;
                    this.showSpinnerPopUp = false;
                    console.log('Please upload URC certificate');
                }
            });

        } else {
            this.closeModal();
            this.showSpinnerPopUp = false;
        }

    }
    createIntegrationMsg(appKycId, applicantId, serviceName) {
        console.log('createIntegrationMsg ', appKycId, applicantId, serviceName);
        const fields = this.createIntegrationMsgField(appKycId, applicantId, serviceName);
        //4. Prepare config object with object and field API names 

        console.log('createIntegrationMsgField ', fields);
        const recordInput = {
            apiName: INTG_MSG.objectApiName,
            fields: fields
        };

        //5. Invoke createRecord by passing the config object
        //this.callSubscribePlatformEve();

        createRecord(recordInput).then((record) => {
            this.showSpinner = false;
            this.showModal = false;
            this.showSpinnerPopUp = false;
            console.log('Integration msz created ', record);
            const evt = new ShowToastEvent({
                title: 'Success',
                variant: 'success',
                message: 'Re-Initiated Successfully, Please Click on Refresh Button to See Details on Table'
            });
            this.dispatchEvent(evt);

        });
    }
    createIntegrationMsgField(appKycId, applicantId, serviceName) {
        const ingMsgFields = {};
        console.log('createIntegrationMsgField  method', ingMsgFields);
        ingMsgFields[BU.fieldApiName] = 'HL / STL';
        ingMsgFields[IS_ACTIVE.fieldApiName] = true;
        ingMsgFields[EXUC_TYPE.fieldApiName] = 'Async';
        ingMsgFields[STATUS.fieldApiName] = 'New';
        ingMsgFields[DOC_API.fieldApiName] = false;
        ingMsgFields[OUTBOUND.fieldApiName] = true;
        ingMsgFields[TRIGGER_PLATFORM_EVENT.fieldApiName] = true;

        ingMsgFields[REF_OBJ.fieldApiName] = "ApplKyc__c";
        ingMsgFields[REF_ID.fieldApiName] = appKycId;
        ingMsgFields[PARENT_REF_OBJ.fieldApiName] = 'Applicant__c';
        ingMsgFields[PARENT_REF_ID.fieldApiName] = applicantId;
        ingMsgFields[SVC.fieldApiName] = serviceName;
        ingMsgFields[NAME.fieldApiName] = serviceName;
        console.log('from helper methods ', ingMsgFields);
        return ingMsgFields;
    }
    handlePreview(event) {
        console.log('record ', event.target.dataset.id);
        let selectedRecordId = event.target.dataset.id;
        let searchDoc = this.data.find((doc) => doc.id === selectedRecordId);
        console.log('record ', searchDoc);
        //select id , Applicant_KYC__c from DocDtl__c where Applicant_KYC__c  ='a0PC4000001ArKDMA0'
        let params = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ["Id", "Applicant_KYC__c"],
            queryCriteria: ' Where Applicant_KYC__c = \'' + selectedRecordId + '\''

        };
        getSobjectDataNonCacheable({ params: params })
            .then((result) => {
                console.log('recdoc detail id  ', result.parentRecords);
                let docDetId = result.parentRecords[0].Id;
                this.showModalForFilePre = true;
                this.documentDetailId = docDetId;
                this.hasDocumentId = true;
                console.log('rec docdetail id  is', docDetId);
            })
    }
    handleCloseModalEvent(event) {
        this.showModalForFilePre = false;
    }




    getApiRetriggerTrackerData() {
        let apiName = "Udyam Registration Check";
        console.log('loanappId in Reintiate component', this.loanAppId);
        let paramsLoanApp = {
            ParentObjectName: 'APIRetriggerTracker__c',
            parentObjFields: ['Id', 'App__c', 'LoanApp__c', 'LoanApp__r.Id', 'IsProcessed__c', 'App__r.TabName__c', 'App__r.Id'],
            queryCriteria: ' where IsProcessed__c = false AND LoanApp__c = \'' + this.loanAppId + '\' AND APIName__c = \'' + apiName + '\''
        }

        getSobjectDataNonCacheable({ params: paramsLoanApp })
            .then((result) => {
                console.log('apiRetrgrTrcrData is', JSON.stringify(result));
                this.apiRetrgrTrcrData = [];
                if (result.parentRecords && result.parentRecords.length > 0) {
                    result.parentRecords.forEach(item => {
                        if (item.App__c) {
                            this.apiRetrgrTrcrData.push(item.App__c);
                        }
                    })
                }
                // this.getAppWithCallOutData();
                this.getApiCallOutData();
                console.log('disableReintiate ', this.disableReintiate);
                console.log('this.apiRetrgrTrcrData after', this.apiRetrgrTrcrData);
                if (result.error) {
                    console.error('apiRetrgrTrcrData result getting error=', result.error);
                }
            })
    }
    @track apiRetrgrTrcrData = [];
    getApiCallOutData() {
        let apiName = ["Udyam Registration Check"];
        let params = {
            ParentObjectName: 'APICoutTrckr__c',
            parentObjFields: ['Id', 'LtstRespCode__c', 'Appl__c', 'LAN__c', 'LAN__r.Id', 'APIName__c', 'RefId__c'],
            // queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND ApplType__c = \'' + appType + '\''
            queryCriteria: ' Where LAN__c = \'' + this.loanAppId + '\'  AND APIName__c  IN (\'' + apiName.join('\', \'') + '\') order by LastModifiedDate desc limit 1'
        }
        getSobjectDataNonCacheable({ params: params })
            .then((result) => {
                console.log('Api CallOutData is', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {

                    result.parentRecords.forEach(item => {
                        if (item.LtstRespCode__c != 'Success') {
                            this.apiRetrgrTrcrData.push(item.Appl__c);
                        }
                    })
                } else {
                    this.showSpinner = false;
                }

                this.apiRetrgrTrcrData = [...new Set(this.apiRetrgrTrcrData)];
                this.applIds = [...this.apiRetrgrTrcrData];
                if (this.applIds.length === 0) {
                    this.disableReintiate = true;
                } else {
                    this.disableReintiate = false;
                }
                if (this.isReadOnly) {
                    this.disableReintiate = true;
                }
                console.log('this.apiRetrgrTrcrData after', this.apiRetrgrTrcrData);
                // this.getAppWithCallOutDatas();
                this.getEmploymentRec();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('exp result getting error= ', error);
            });
    }
    removeSpecialCharsAndSpaces(input) {
        if (typeof input !== 'string') {
            throw new Error('Input must be a string');
        }

        // Regular expression pattern to match anything that is not a letter or a digit
        const pattern = /[^a-zA-Z0-9]/g;

        // Replace all non-alphanumeric characters with an empty string
        const cleanedString = input.replace(pattern, '');
        console.log('in removeSpecialCharsAndSpaces ', cleanedString);
        return cleanedString;
    }
}