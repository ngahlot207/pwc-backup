import { LightningElement, wire, api, track } from 'lwc';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
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

export default class ShopEstVerifTableOnOccupation extends LightningElement {
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
    @track isReadOnly = false;
    @track disableButtons = false


    @track loanStage;
    getLoanApplicationData1() {
        this.showSpinner = true;
        let params = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Id', 'Stage__c', 'SubStage__c'],
            queryCriteria: ' where Id = \'' + this.loanAppId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
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
            });
    }
    
    connectedCallback() {
        console.log('loanAppId : ', this.loanAppId);
        console.log('hasEditAccess : ', this.hasEditAccess);
        console.log('borrowers : ', this.borrowers);
        this.showSpinner = true;
        this.getLoanApplicationData1();
        this.getEmploymentRec();

        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }

        //this.disableReintiate = this.isReadOnly;

    }
    getEmpAndRetData() {
        this.getApiRetriggerTrackerData();
    }
    getEmploymentRec() {

        this.data = [];
        if (this.borrowers.length > 0) {
            let borrowersId = [];
            this.borrowers.forEach(element => {
                borrowersId.push(element.value)
            });
            let params = {
                ParentObjectName: 'ApplKyc__c',
                parentObjFields: ["Id", "Applicant__c", "Name_Match_Score__c", "ShopEstEntityname__c", "ShopEstCat__c", "ShopEstOwnername__c", "Applicant__r.FullName__c", "tolabel(Applicant__r.ApplType__c)", "Applicant__r.Constitution__c", "ShopEstNatureBus__c", "kycDoc__c", "Address__c", "Email__c", "ShopEstTotWorkers__c", "ShopEstCon__c", "DtOfShopEstReg__c", "ShopEstValidFrom__c", "FatherName__c", "Validation_Error_Message__c", "DtOfExp__c", "ValidationStatus__c", "DteOfComm__c"],
                queryCriteria: ' Where kycDoc__c = \'' + 'Shop and Establishment' + '\'AND Applicant__r.LoanAppln__c = \'' + this.loanAppId + '\' '// AND Applicant__c   IN (\'' + borrowersId.join('\', \'') + '\') '

            };
            console.log('params in shop', params);
            getSobjectDataNonCacheable({ params: params })
                .then((result) => {
                    this.disableReintiate = true;
                    let applicantDetails = [];
                    let appKyc = result.parentRecords;
                    if (appKyc) {
                        for (let index = 0; index < appKyc.length; index++) {
                            const res = appKyc[index];
                            console.log('appKyc:', appKyc);

                            // let appEmpRec = appEmpRecList.find((doc) => doc.LoanApplicant__c === res.Applicant__r.Id);
                            if (res) {


                                let localData = {
                                    id: res.Id,
                                    applicantId: res.Applicant__r.Id,
                                    // applicantEmployment: appEmpRec && appEmpRec.Id ? appEmpRec.Id : '',
                                    name: res.Applicant__r && res.Applicant__r.FullName__c ? res.Applicant__r.FullName__c : '',
                                    applicantType: res.Applicant__r && res.Applicant__r.ApplType__c ? res.Applicant__r.ApplType__c : '',

                                    nameMatchPercent: res.Name_Match_Score__c,
                                    //  dateOfIncorporation: res.DteOfIncorp__c,
                                    typeOfEnterprise: res.TypeOfEnterprise_URC__c,
                                    natureOfbusiness: res.ShopEstNatureBus__c ? res.ShopEstNatureBus__c : '',///ShopEstNatureBus__c
                                    commenceDate: res.DteOfComm__c ? res.DteOfComm__c : '',
                                    category: res.ShopEstCat__c ? res.ShopEstCat__c : '',
                                    applicantName: res.Applicant__r && res.Applicant__r.FullName__c ? res.Applicant__r.FullName__c : '',
                                    ownerName: res.ShopEstOwnername__c ? res.ShopEstOwnername__c : '',
                                    entityName: res.ShopEstEntityname__c ? res.ShopEstEntityname__c : '',

                                    // addressAsPerURC: address,
                                    // emailId: res.Email__c,
                                    // certificate: 'URL to certificate',
                                    apiVerStatus: res.ValidationStatus__c && res.ValidationStatus__c == 'Success' ? 'Success' : 'Failure',//this.apiRetrgrTrcrData.length > 0 && this.apiRetrgrTrcrData.includes(res.Applicant__r.Id) ? 'Failure' : 'Success',   //appEmpRec.UdyamAPIStatus__c == null ? 'Failure' : appEmpRec.UdyamAPIStatus__c,
                                    // errorMessage: appEmpRec.UdyamErrorMess__c ? appEmpRec.UdyamErrorMess__c : '',
                                    seAPIStatus: res.ValidationStatus__c && res.ValidationStatus__c == 'Success' ? true : false,//this.apiRetrgrTrcrData.length > 0 && this.apiRetrgrTrcrData.includes(res.Applicant__r.Id) ? false : true, //appEmpRec.UdyamAPIStatus__c == 'Success' ? true : false,
                                    //  retriggerButton: 'Retrigger'
                                    registrationDate: res.DtOfShopEstReg__c,
                                    validFrom: res.ShopEstValidFrom__c,
                                    validTo: res.DtOfExp__c,
                                    totalWorkers: res.ShopEstTotWorkers__c,
                                    fatherNameOccupier: res.FatherName__c,
                                    email: res.Email__c,
                                    contact: res.ShopEstCon__c,
                                    website: '',

                                    errorMessage: res.Validation_Error_Message__c,
                                    address: res.Address__c,

                                }
                                if ((localData.seAPIStatus === false)) {
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
    dateFormat(DateValue) {

        const [day, month, year] = DateValue.split('-');
        const monthAbbreviation = new Date(Date.parse(`${month}/01/2000`)).toLocaleString('en-us', { month: 'short' });
        const formattedDate = `${day}-${monthAbbreviation}-${year}`;
        console.log(formattedDate);
        return formattedDate;
    }

    handleRefreshClick() {
        this.showSpinner = true;
        setTimeout(() => {
            this.showSpinner = false;
            this.getEmpAndRetData();
        }, 6000);
        console.log('after');
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
            console.log(' udyamAPIStatus: ', element.seAPIStatus);
            if (element.seAPIStatus == false) {
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
                // let applicantId = ele.applicantId;
                let appKycId = ele.id;

                //console.log('appKyc :: ', appkyc, ' :: applicantId :: ', applicantId);
                if (appKycId) {
                    console.log('inside if')
                    let serviceName = "Shop and Establishment";
                    this.createIntegrationMsg(appKycId, serviceName);

                } else {
                    console.log('inside else')
                    this.showSpinner = false;
                    this.showSpinnerPopUp = false;

                }
            });

        } else {
            this.closeModal();
            this.showSpinnerPopUp = false;
        }

    }

    //LAK-8903
    createIntegrationMsg(appKycId, serviceName) {
        //console.log('createIntegrationMsg ', appKycId, applicantId, serviceName);
        //const fields = this.createIntegrationMsgField(appKycId, applicantId, serviceName);
        //4. Prepare config object with object and field API names
        //

        let params = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ["Id", "Applicant_KYC__c"],
            queryCriteria: ' Where Applicant_KYC__c = \'' + appKycId + '\' '

        };
        getSobjectDataNonCacheable({ params: params })
            .then((result) => {
                let docDetId = result.parentRecords[0].Id;
                console.log('rec docdetail id  is', docDetId);

                const fields = this.createIntegrationMsgField(appKycId, docDetId, serviceName);


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


            })

    }

    //LAK-8903
    createIntegrationMsgField(appKycId, docDtlsId, serviceName) {
        const ingMsgFields = {};
        console.log('createIntegrationMsgField  method', ingMsgFields);
        ingMsgFields[BU.fieldApiName] = 'HL / STL';
        ingMsgFields[IS_ACTIVE.fieldApiName] = true;
        ingMsgFields[EXUC_TYPE.fieldApiName] = 'Async';
        ingMsgFields[STATUS.fieldApiName] = 'New';
        ingMsgFields[DOC_API.fieldApiName] = false;
        ingMsgFields[OUTBOUND.fieldApiName] = true;
        ingMsgFields[TRIGGER_PLATFORM_EVENT.fieldApiName] = true;

        ingMsgFields[REF_OBJ.fieldApiName] = "DocDtl__c";
        ingMsgFields[REF_ID.fieldApiName] = docDtlsId;
        ingMsgFields[PARENT_REF_OBJ.fieldApiName] = 'ApplKyc__c';
        ingMsgFields[PARENT_REF_ID.fieldApiName] = appKycId;
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
            queryCriteria: ' Where Applicant_KYC__c = \'' + selectedRecordId + '\' '

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
        let apiName = "Shop and Establishment";
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
        let apiName = ["Shop and Establishment"];
        let params = {
            ParentObjectName: 'APICoutTrckr__c',
            parentObjFields: ['Id', 'LtstRespCode__c', 'Appl__c', 'LAN__c', 'LAN__r.Id', 'APIName__c', 'RefId__c'],
            // queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND ApplType__c = \'' + appType + '\''
            queryCriteria: ' Where LAN__c = \'' + this.loanAppId + '\'  AND APIName__c  IN (\'' + apiName.join('\', \'') + '\')'
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
                //this.applIds = [...this.apiRetrgrTrcrData];
                // if (this.applIds.length === 0) {
                //     this.disableReintiate = true;
                // }
                // if (this.isReadOnly) {
                //     this.disableReintiate = true;
                // }
                console.log('this.apiRetrgrTrcrData after', this.apiRetrgrTrcrData);
                // this.getAppWithCallOutDatas();
                this.getEmploymentRec();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('exp result getting error= ', error);
            });
    }
}