import { LightningElement, api, track } from 'lwc';

//Apex Methods
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import getSobjectDataWithoutCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjDtwithFltrRelatedRecordsWithoutCache';


import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ShowQualificationDetails extends LightningElement {
    @api loanAppId = 'a08C4000009C0C1IAK';
    @api hasEditAccess = false;

    @track isReadOnly = false;
    @track disableReintiate = false;
    @track disableReintiateDoctr = false;
    @track disableReintiateArchct = false;
    @track refrshTables = false;
    @track paramsCAApi = [];
    @track queryParam = [];
    @track paramsDoctorApi = [];
    @track queryParamNew = [];
    @track paramsArcthtApi = [];
    @track queryParamArcht = [];
    @track activeSection = ["A"];
    @track columnsDataForCA = [
        {
            "label": "Name",
            "fieldName": "Appl__r.FullName__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Applicant Type",
            "fieldName": "Appl__r.ApplType__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Membership No",
            "fieldName": "Appl__r.MembershipNumber__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Output Name",
            "fieldName": "Name__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Name Match %",
            "fieldName": "Name_Match_Score__c",
            "type": "number",
            "Editable": false
        },
        {
            "label": "Address",
            "fieldName": "Address__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Holding status for Certificate of Practice",
            "fieldName": "COPStatus__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Status of the Membership",
            "fieldName": "MembershipStatus__c",
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

    @track columnsDataForDoctor = [
        {
            "label": "Name",
            "fieldName": "Appl__r.FullName__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Applicant Type",
            "fieldName": "Appl__r.ApplType__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Registration No",
            "fieldName": "Appl__r.RegistrationNumber__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Year of registration",
            "fieldName": "Appl__r.YearOfRegistration__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Medical Council",
            "fieldName": "Appl__r.MediCouncl__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Output Name",
            "fieldName": "Name__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Name Match %",
            "fieldName": "Name_Match_Score__c",
            "type": "number",
            "Editable": false
        },
        {
            "label": "Unique Dr ID",
            "fieldName": "DoctorId__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Date of registration of Doctor",
            "fieldName": "DateOfRegistration__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Registered address of the Doctor",
            "fieldName": "Address__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Degree of Qualification",
            "fieldName": "Qualification__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Year of Qualification",
            "fieldName": "QualificationYear__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "University of Qualification",
            "fieldName": "University__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Status of removal from Membership Register",
            "fieldName": "RemovalStatus__c",
            "type": "boolean",
            "Editable": false
        },
        {
            "label": "Membership restoration date",
            "fieldName": "RestorationDt__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Status of membership restoration",
            "fieldName": "RestorationStatus__c",
            "type": "boolean",
            "Editable": false
        },
        {
            "label": "Whether Doctor is Blacklisted",
            "fieldName": "IsBlacklistedDoctor__c",
            "type": "boolean",
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

    @track columnsDataForArtct = [
        {
            "label": "Name",
            "fieldName": "Appl__r.FullName__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Applicant Type",
            "fieldName": "Appl__r.ApplType__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Membership No",
            "fieldName": "Appl__r.MembershipNumber__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Output Name",
            "fieldName": "Name__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Name Match %",
            "fieldName": "Name_Match_Score__c",
            "type": "number",
            "Editable": false
        },
        {
            "label": "Qualification",
            "fieldName": "Qualification__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Address",
            "fieldName": "Address__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Mobile Number",
            "fieldName": "MobNo__c",
            "type": "number",
            "Editable": false
        },
        {
            "label": "Email Id",
            "fieldName": "Email__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Disciplinary Action",
            "fieldName": "DisciplinaryAction__c",
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

    @track queryDataForCA = 'SELECT Appl__r.FullName__c,toLabel(Appl__r.ApplType__c),Appl__r.MembershipNumber__c,Name__c,Name_Match_Score__c,Address__c,COPStatus__c,MembershipStatus__c,IntegrationStatus__c,IntegrationErrorMessage__c,Id FROM APIVer__c WHERE LoanAplcn__c =: loanAppId AND IsLatest__c =: isActiveValue AND recordtype.name =: recordTypeName AND Prof_Qualification_Check__c =: qualificationCheckName';
    @track queryDataForDoctor = 'SELECT Appl__r.FullName__c,toLabel(Appl__r.ApplType__c),Appl__r.RegistrationNumber__c,Appl__r.YearOfRegistration__c,Appl__r.MediCouncl__c,Name__c,Name_Match_Score__c,DoctorId__c,DateOfRegistration__c,Address__c,Qualification__c,QualificationYear__c,University__c,RemovalStatus__c,RestorationDt__c,RestorationStatus__c,IsBlacklistedDoctor__c,IntegrationStatus__c,IntegrationErrorMessage__c,Id FROM APIVer__c WHERE LoanAplcn__c =: loanAppId AND IsLatest__c =: isActiveValue AND recordtype.name =: recordTypeName AND Prof_Qualification_Check__c =: qualificationCheckName';
    @track queryDataForArcht = 'SELECT Appl__r.FullName__c,toLabel(Appl__r.ApplType__c),Appl__r.MembershipNumber__c,Name__c,Name_Match_Score__c,Qualification__c,Address__c,MobNo__c,Email__c,DisciplinaryAction__c,IntegrationStatus__c,IntegrationErrorMessage__c,Id FROM APIVer__c WHERE LoanAplcn__c =: loanAppId AND IsLatest__c =: isActiveValue AND recordtype.name =: recordTypeName AND Prof_Qualification_Check__c =: qualificationCheckName';
    connectedCallback() {
        let paramVal = [];
        paramVal.push({ key: 'loanAppId', value: this.loanAppId });
        paramVal.push({ key: 'recordTypeName', value: 'Qualification Check' });
        paramVal.push({ key: 'isActiveValue', value: true });
        paramVal.push({ key: 'qualificationCheckName', value: 'CA Membership Check' });
        this.queryParam = paramVal;
        console.log('map data:::', this.queryParam);
        this.paramsCAApi = {
            columnsData: this.columnsDataForCA,
            queryParams: this.queryParam,
            query: this.queryDataForCA
        }

        let paramValNew = [];
        paramValNew.push({ key: 'loanAppId', value: this.loanAppId });
        paramValNew.push({ key: 'recordTypeName', value: 'Qualification Check' });
        paramValNew.push({ key: 'isActiveValue', value: true });
        paramValNew.push({ key: 'qualificationCheckName', value: 'Doctor\'s Registration no Check' });
        this.queryParamNew = paramValNew;
        console.log('map data:::', this.queryParamNew);
        this.paramsDoctorApi = {
            columnsData: this.columnsDataForDoctor,
            queryParams: this.queryParamNew,
            query: this.queryDataForDoctor
        }

        let paramValArcht = [];
        paramValArcht.push({ key: 'loanAppId', value: this.loanAppId });
        paramValArcht.push({ key: 'recordTypeName', value: 'Qualification Check' });
        paramValArcht.push({ key: 'isActiveValue', value: true });
        paramValArcht.push({ key: 'qualificationCheckName', value: 'Architect Registration no Check' });
        this.queryParamArcht = paramValArcht;
        console.log('map data:::', this.queryParamArcht);
        this.paramsArcthtApi = {
            columnsData: this.columnsDataForArtct,
            queryParams: this.queryParamArcht,
            query: this.queryDataForArcht
        }
        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }
        this.isReadOnly = false;
        this.disableReintiate = this.isReadOnly;
        this.disableReintiateDoctr = this.isReadOnly;
        this.disableReintiateArchct = this.isReadOnly;
        this.getApplicantsData();
    }
    @track appData = [];
    getApplicantsData() {
        // this.showSpinner = true;
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'FullName__c', 'ProfQual__c', 'CAVerStatus__c', 'DoctorApiVerStatus__c', 'ArchVerStatus__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Applicants Data is ', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.appData = result.parentRecords;
                }
                this.getApiRetriggerTrackerData();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Api Verification Data is ', error);
            });
    }

    @track applIdsCA = [];
    @track applIdsDoctr = [];
    @track applIdsArcht = [];
    @track apiRetrgrTrcrDataCA = [];
    @track apiRetrgrTrcrDataDoctr = [];
    @track apiRetrgrTrcrDataArcht = [];
    getApiRetriggerTrackerData() {
        let arra = ['NMC Membership Authentication', 'Architect Authentication', 'CA Membership Authentication'];
        console.log('loanappId in Reintiate component', this.loanAppId);
        let paramsLoanApp = {
            ParentObjectName: 'APIRetriggerTracker__c',
            parentObjFields: ['Id', 'APIName__c', 'App__c', 'LoanApp__c', 'IsProcessed__c', 'App__r.TabName__c', 'App__r.Id'],
            queryCriteria: ' where APIName__c  IN (\'' + arra.join('\', \'') + '\') AND  IsProcessed__c = false AND LoanApp__c = \'' + this.loanAppId + '\''
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('apiRetrgrTrcrData is', JSON.stringify(result));
                this.apiRetrgrTrcrDataCA = [];
                this.apiRetrgrTrcrDataDoctr = [];
                this.apiRetrgrTrcrDataArcht = [];
                if (result.parentRecords && result.parentRecords.length > 0) {
                    result.parentRecords.forEach(item => {
                        if (item.App__c && item.APIName__c && item.APIName__c === 'CA Membership Authentication') {
                            this.apiRetrgrTrcrDataCA.push(item.App__r.Id);
                        } else if (item.App__c && item.APIName__c && item.APIName__c === 'Architect Authentication') {
                            this.apiRetrgrTrcrDataArcht.push(item.App__r.Id);
                        } else if (item.App__c && item.APIName__c && item.APIName__c === 'NMC Membership Authentication') {
                            this.apiRetrgrTrcrDataDoctr.push(item.App__r.Id);
                        }
                    })
                }
                this.getAppWithCallOutData();
                // console.log('disableReintiate ', this.disableReintiate);
                console.log('this.apiRetrgrTrcrDataCA after', this.apiRetrgrTrcrDataCA);
                console.log('this.apiRetrgrTrcrDataArcht after', this.apiRetrgrTrcrDataArcht);
                console.log('this.apiRetrgrTrcrDataDoctr after', this.apiRetrgrTrcrDataDoctr);
                if (result.error) {
                    this.showSpinner = false;
                    console.error('apiRetrgrTrcrData result getting error=', result.error);
                }
            })
    }
    getAppWithCallOutData() {
        let arra = ['NMC Membership Authentication', 'Architect Authentication', 'CA Membership Authentication'];
        let appTypes = ['P', 'C', 'G'];
        let paramsLoanApp = {
            ParentObjectName: 'Applicant__c',
            ChildObjectRelName: 'API_Callout_Trackers__r',
            parentObjFields: ['Id', 'ProfQual__c'],
            childObjFields: ['Id', 'LtstRespCode__c', 'APIName__c', 'App__c','Appl__r.Id', 'LAN__c'],
            queryCriteriaForChild: ' where LAN__c = \'' + this.loanAppId + '\' AND APIName__c  IN (\'' + arra.join('\', \'') + '\')',
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND ApplType__c  IN (\'' + appTypes.join('\', \'') + '\')'

        }
        getSobjectDataWithoutCacheable({ params: paramsLoanApp })
            .then((result) => {
                console.log('AppWithCallOutData is', JSON.stringify(result));
                if (result && result.length > 0) {
                    result.forEach(item => {
                        if (item.ChildReords && item.ChildReords.length > 0) {
                            item.ChildReords.forEach(ite => {
                                if (ite.LtstRespCode__c != 'Success') {
                                    if (ite.App__c && ite.APIName__c && ite.APIName__c === 'CA Membership Authentication') {
                                        this.apiRetrgrTrcrDataCA.push(ite.App__r.Id);
                                    } else if (ite.App__c && ite.APIName__c && ite.APIName__c === 'Architect Authentication') {
                                        this.apiRetrgrTrcrDataArcht.push(ite.App__r.Id);
                                    } else if (ite.App__c && ite.APIName__c && ite.APIName__c === 'NMC Membership Authentication') {
                                        this.apiRetrgrTrcrDataDoctr.push(ite.App__r.Id);
                                    }
                                }
                            })
                        } else {
                            if (item.parentRecord.ProfQual__c && item.parentRecord.profQualif === 'CA') {
                                this.apiRetrgrTrcrDataCA.push(item.parentRecord.Id);
                            } else if (item.parentRecord.ProfQual__c && item.parentRecord.profQualif === 'ART') {
                                this.apiRetrgrTrcrDataArcht.push(item.parentRecord.Id);
                            } else if (item.parentRecord.ProfQual__c && (item.parentRecord.ProfQual__c === 'DOC' || item.parentRecord.ProfQual__c === 'DOCBM' || item.parentRecord.ProfQual__c === 'DOCB')) {
                                this.apiRetrgrTrcrDataDoctr.push(item.parentRecord.Id);
                            }
                            // this.apiRetrgrTrcrData.push(item.parentRecord.Id);
                        }
                    })
                }
                if (this.appData && this.appData.length > 0) {
                    this.appData.forEach(item => {
                        if (item.ProfQual__c && item.ProfQual__c === 'CA' && item.CAVerStatus__c && (item.CAVerStatus__c === 'Changed')) {
                            this.apiRetrgrTrcrDataCA.push(item.Id);
                        } else if (item.ProfQual__c && item.ProfQual__c === 'ART' && item.ArchVerStatus__c && (item.ArchVerStatus__c === 'Changed')) {
                            this.apiRetrgrTrcrDataArcht.push(item.Id);
                        } else if (item.ProfQual__c && (item.ProfQual__c === 'DOC' || item.ProfQual__c === 'DOCBM' || item.ProfQual__c === 'DOCB') && item.DoctorApiVerStatus__c && (item.DoctorApiVerStatus__c === 'Changed')) {
                            this.apiRetrgrTrcrDataDoctr.push(item.Id);
                        }
                    })
                }
                this.apiRetrgrTrcrDataCA = [...new Set(this.apiRetrgrTrcrDataCA)];
                this.applIdsCA = [...this.apiRetrgrTrcrDataCA];
                if (this.applIdsCA.length === 0 || this.isReadOnly) {
                    this.disableReintiate = true;
                }

                this.apiRetrgrTrcrDataDoctr = [...new Set(this.apiRetrgrTrcrDataDoctr)];
                this.applIdsDoctr = [...this.apiRetrgrTrcrDataDoctr];
                console.log('this.applIdsDoctr ', this.applIdsDoctr);
                
                if (this.applIdsDoctr.length === 0 || this.isReadOnly) {
                    this.disableReintiateDoctr = true;
                }

                this.apiRetrgrTrcrDataArcht = [...new Set(this.apiRetrgrTrcrDataArcht)];
                this.applIdsArcht = [...this.apiRetrgrTrcrDataArcht];
                if (this.applIdsArcht.length === 0 || this.isReadOnly) {
                    this.disableReintiateArchct = true;
                }
                // else {
                //     this.applIdsCA.forEach(item => {
                //         let obj = this.appData.find(it=>it.Id === item);
                //         if (obj) {
                //             this.appDataDisplay.push(obj);
                //         }
                //     })
                // }
                this.showSpinner = false;
                console.log('this.apiRetrgrTrcrData after second method', this.apiRetrgrTrcrData);
                // console.log('this.appDataDisplay after second method', this.appDataDisplay);
                if (result.error) {
                    this.showSpinner = false;
                    console.error('apiRetrgrTrcrData result getting error=', result.error);
                }
            })
    }
    @track isModalOpen = false;
    @track applIds = [];
    @track serviceName;
    handleIntialization(event) {
        console.log('Event details is ', event);
        let val = event.target.dataset.name;
        if (val === 'CA') {
            this.applIds = [...this.applIdsCA];
            this.serviceName = 'CA Membership Authentication';
        } else if (val === 'Doctor') {
            this.applIds = [...this.applIdsDoctr];
            this.serviceName = 'NMC Membership Authentication';
        } else if (val === 'ARCHITECT') {
            this.applIds = [...this.applIdsArcht];
            this.serviceName = 'Architect Authentication';
        }
        this.isModalOpen = true;
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
            this.getApplicantsData();
            const evt = new ShowToastEvent({
                title: titleVal,
                variant: variantVal,
                message: messageVal
            });
            this.dispatchEvent(evt);

        }
    }
    @track showSpinner = false;
    handleRefreshClick() {

        this.showSpinner = true;
        const childComponent = this.template.querySelector('[data-id="childComponentOne"]');
        if (childComponent) {
            console.log('before');
            childComponent.handleGettingData();
            console.log('after');

            const childComponentTwo = this.template.querySelector('[data-id="childComponentTwo"]');
            if (childComponentTwo) {
                console.log('before');
                childComponentTwo.handleGettingData();
                console.log('after');
            }
            const childComponentThree = this.template.querySelector('[data-id="childComponentThree"]');
            if (childComponentThree) {
                console.log('before');
                childComponentThree.handleGettingData();
                console.log('after');
            }
            //this.showSpinner = false;
        }
        setTimeout(() => {
            this.showSpinner = false;
            this.getApplicantsData();
        }, 6000);
    }
}