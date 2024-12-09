import { LightningElement, api, wire, track } from 'lwc';

//Apex Methods
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import { formatDateFunction, formattedDateTimeWithoutSeconds, formattedDate } from 'c/dateUtility';
import formFactorPropertyName from "@salesforce/client/formFactor";
export default class BoTable extends LightningElement {
    @api loanAppId;
    @api appId;
    @api isReadOnly;

    @track formFactor = formFactorPropertyName;
    desktopBoolean = false;
    phoneBolean = false;

    connectedCallback() {
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
        // this.getApplicantConst();
        this.getAppRelDetails();
    }
    @track appData = [];
    @track appIds = [];
    getAppRelDetails() {
        let arra = ['Beneficial Owner', 'ShareHolder'];
        let yesLabel = 'Yes';
        // const relType = 'Beneficial Owner';
        // queryCriteria: ` WHERE Loan_Applicant__c = '${this.appId}' AND Relationship_Type__c = '${relType}'`
        const params = {
            ParentObjectName: 'LoanApplRelationship__c',
            parentObjFields: [
                'Id', 'Related_Person__r.FullName__c',
                'Loan_Applicant__c', 'Related_Person__c', 'Related_Person__r.Id', 'Related_Person__r.Relationship__c', 'Related_Person__r.PAN__c', 'Related_Person__r.DOB__c', 'Related_Person__r.Father_Name__c',
                'toLabel(Related_Person__r.ApplType__c)', 'Related_Person__r.SpName__c', 'Related_Person__r.MthrMdnName__c', 'Related_Person__r.Nationality__c', 'Related_Person__r.Politically_Exposed_Person__c',
                'Related_Person__r.MobNumber__c', 'Related_Person__r.LoanAppln__c', 'Related_Person__r.UCID__c'
            ],
            queryCriteria: ' where Loan_Applicant__c = \'' + this.appId + '\' AND Relationship_Type__c  IN (\'' + arra.join('\', \'') + '\') AND BeneficialOwner__c = \'' + yesLabel + '\''

        };

        getSobjectData({ params: params })
            .then((result) => {
                console.log('Relation Data is ', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    // this.appData = result.parentRecords;
                    this.appData = [];
                    result.parentRecords.forEach(item => {
                        let obj = {};
                        if (item.Related_Person__r) {
                            this.appIds.push(item.Related_Person__r.Id);
                            obj.Id = item.Related_Person__r.Id;
                            obj.FullName__c = item.Related_Person__r.FullName__c ? item.Related_Person__r.FullName__c : '';
                            obj.Relationship__c = item.Related_Person__r.Relationship__c ? item.Related_Person__r.Relationship__c : '';
                            obj.PAN__c = item.Related_Person__r.PAN__c ? item.Related_Person__r.PAN__c : '';
                            obj.Father_Name__c = item.Related_Person__r.Father_Name__c ? item.Related_Person__r.Father_Name__c : '';
                            obj.SpName__c = item.Related_Person__r.SpName__c ? item.Related_Person__r.SpName__c : '';
                            obj.MthrMdnName__c = item.Related_Person__r.MthrMdnName__c ? item.Related_Person__r.MthrMdnName__c : '';
                            obj.Nationality__c = item.Related_Person__r.Nationality__c ? item.Related_Person__r.Nationality__c : '';
                            obj.Politically_Exposed_Person__c = item.Related_Person__r.Politically_Exposed_Person__c ? item.Related_Person__r.Politically_Exposed_Person__c : '';
                            obj.MobNumber__c = item.Related_Person__r.MobNumber__c ? item.Related_Person__r.MobNumber__c : '';
                            obj.UCID__c = item.Related_Person__r.UCID__c ? item.Related_Person__r.UCID__c : '';
                            obj.LoanAppln__c = item.Related_Person__r.LoanAppln__c ? item.Related_Person__r.LoanAppln__c : '';
                        }
                        if (item.Related_Person__r && item.Related_Person__r.DOB__c) {
                            if (item.Related_Person__r.DOB__c) {
                                const dateToPass3 = new Date(item.Related_Person__r.DOB__c);
                                const dateTime3 = formattedDate(dateToPass3);
                                const dateOfApp3 = `${dateTime3}`;
                                obj.DOB__c = dateOfApp3;
                            }
                        }
                        this.appData.push(obj);
                    })
                }

                if (this.appIds && this.appIds.length > 0) {
                    this.getApplKycData();
                }
                // this.showSpinner = false;
                // console.log('NameOptions are ===>>>>>>>>.', this.nameOptions);
                // console.log('tableData is ===>>>>>>>>.', this.tableData);

            })
            .catch((error) => {
                this.showSpinner = false;
                console.error('Error In getting Relation Data is ', error);
            });
    }

    // getApplicantConst() {
    //     //this.showSpinner = true;
    //     let isBo = 'Yes';
    //     let params = {
    //         ParentObjectName: 'Applicant__c',
    //         parentObjFields: ['Id', 'FullName__c', 'Relationship__c', 'PAN__c', 'DOB__c', 'Father_Name__c', 'SpName__c', 'MthrMdnName__c', 'Nationality__c', 'Politically_Exposed_Person__c', 'MobNumber__c', 'UCID__c', 'LoanAppln__c'],
    //         queryCriteria: ' where Id = \'' + this.loanAppId + '\' AND IsBo__c = \'' + isBo + '\''
    //     }
    //     getSobjectData({ params: params })
    //         .then((result) => {
    //             // this.showSpinner = true;
    //             console.log('Applicant Data in child component is ', JSON.stringify(result));
    //             if (result.parentRecords) {
    //                 this.appData = result.parentRecords;
    //                 this.appData.forEach(item => {
    //                     this.appIds.push(item.Id);
    //                     if (item.DOB__c) {
    //                         if (item.DOB__c) {
    //                             const dateToPass3 = new Date(item.DOB__c);
    //                             const dateTime3 = formattedDate(dateToPass3);
    //                             const dateOfApp3 = `${dateTime3}`;
    //                             item.DOB__c = dateOfApp3;
    //                         }
    //                     }
    //                 })
    //             }
    //             if (this.appIds && this.appIds.length > 0) {
    //                 this.getApplKycData();
    //             }
    //             this.showSpinner = false;
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getting Applicant Data is ', error);
    //         });
    // }

    getApplKycData() {
        let params = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'Appl__c', 'Appl__r.Constitution__c', 'Applicant_KYC__r.DtOfBirth__c', 'Applicant_KYC__r.FatherName__c', 'Applicant_KYC__r.Name__c', 'Applicant_KYC__r.Gender__c', 'Applicant_KYC__r.Pan__c', 'DocTyp__c', 'Applicant_KYC__r.DLNo__c', 'Applicant_KYC__r.AadharNo__c', 'Applicant_KYC__r.NPRNumber__c', 'Applicant_KYC__r.PassNo__c', 'Applicant_KYC__r.VotIdEpicNo__c', 'Applicant_KYC__r.UUID__c', 'Applicant_KYC__r.ValidationStatus__c'],
            queryCriteria: ` WHERE Appl__c IN ('${this.appIds.join("', '")}') AND (DocTyp__c = 'Identity Proof' OR DocTyp__c = 'PAN' OR DocTyp__c = 'DOB Proof') ORDER BY LASTMODIFIEDDATE DESC`
        };
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Applicant Kyc Data in child component is ', JSON.stringify(result));
                if (result.parentRecords && result.parentRecords.length > 0) {
                    result.parentRecords.forEach(item => {
                        if (item.Applicant_KYC__r && item.Applicant_KYC__r.ValidationStatus__c && item.Applicant_KYC__r.ValidationStatus__c === 'Success') {
                            let obj = this.appData.find(it => it.Id === item.Appl__c);
                            if (obj) {
                                if (item && item.Constitution__c === 'INDIVIDUAL') {
                                    if (item.DocTyp__c && item.DocTyp__c === 'Identity Proof' && item.Applicant_KYC__r) {
                                        if (item && item.Applicant_KYC__r && item.Applicant_KYC__r.Pan__c) {
                                            obj.idProofNumber = item.Applicant_KYC__r.Pan__c;
                                            obj.idProofType = 'PAN';
                                        }
                                        else if (item && item.Applicant_KYC__r && item.Applicant_KYC__r.DLNo__c) {
                                            obj.idProofNumber = item.Applicant_KYC__r.DLNo__c;
                                            obj.idProofType = 'Driving License';
                                        } else if (item && item.Applicant_KYC__r && item.Applicant_KYC__r.AadharNo__c) {
                                            obj.idProofNumber = item.Applicant_KYC__r.AadharNo__c;
                                            obj.idProofType = 'Aadhaar';
                                        } else if (item && item.Applicant_KYC__r && item.Applicant_KYC__r.NPRNumber__c) {
                                            obj.idProofNumber = item.Applicant_KYC__r.NPRNumber__c;
                                            obj.idProofType = 'Letter issued by the National Population Register';
                                        } else if (item && item.Applicant_KYC__r && item.Applicant_KYC__r.PassNo__c) {
                                            obj.idProofNumber = item.Applicant_KYC__r.PassNo__c;
                                            obj.idProofType = 'Passport';
                                        } else if (item && item.Applicant_KYC__r && item.Applicant_KYC__r.VotIdEpicNo__c) {
                                            obj.idProofNumber = item.Applicant_KYC__r.VotIdEpicNo__c;
                                            obj.idProofType = 'VoterId';
                                        }
                                    }
                                } else {
                                    if (item && item.Applicant_KYC__r && item.Applicant_KYC__r.Pan__c !== undefined && item.Applicant_KYC__r.Pan__c) {
                                        obj.idProofNumber = item.Applicant_KYC__r.Pan__c;
                                        obj.idProofType = 'PAN';
                                    }
                                }
                            }
                        }
                    })
                }
                this.getAppAddrsDetails();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Applicant Data is ', error);
            });
    }
    getAppAddrsDetails() {
        let params = {
            ParentObjectName: 'ApplAddr__c',
            parentObjFields: ['Id', 'Applicant__c', 'FullAdrs__c'],
            queryCriteria: ` WHERE Applicant__c IN ('${this.appIds.join("', '")}')`
        };
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Applicant address data in child component is ', JSON.stringify(result));
                if (result.parentRecords) {
                    result.parentRecords.forEach(item => {
                        let obj = this.appData.find(it => it.Id === item.Applicant__c);
                        if (obj) {
                            obj.applicantAddress = item.FullAdrs__c;
                        }
                    })
                }
                console.log('this.appData final is ', this.appData);

                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Applicant Data is ', error);
            });
    }
}