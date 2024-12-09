import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//LMS details
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, publish, MessageContext, APPLICATION_SCOPE, unsubscribe, createMessageContext, releaseMessageContext } from 'lightning/messageService';

import ApplicantCapture_Format_ErrorMessage from '@salesforce/label/c.ApplicantCapture_Format_ErrorMessage';
import ALL_FIELDS_Label from '@salesforce/label/c.LeadCapture_BasicDetails_RequiredFieldsValidation';
import ApplicantDetails_ResidenceBusineesAdd_ErrorMessage from '@salesforce/label/c.ApplicantDetails_ResidenceBusineesAdd_ErrorMessage';
//Apex Methods
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';

import { trimFunction } from 'c/reusableStringTrimComp';
import { refreshApex } from '@salesforce/apex';
export default class CaptureBoDetails extends LightningElement {

    label = {
        ApplicantCapture_Format_ErrorMessage,
        ALL_FIELDS_Label,
        ApplicantDetails_ResidenceBusineesAdd_ErrorMessage
    }
    @api loanAppId;
    @api hasEditAccess;
    @api layoutSize = {
        "large": "4",
        "medium": "6",
        "small": "12"
    };
    @track _recordId;
    @api get recordId() {
        return this._recordId;
    }

    set recordId(value) {
        this._recordId = value;
        // this._recordId = 'a0AC4000000alYHMAY';
        this.setAttribute("recordId", value);
        this.handleRecordIdChange(value);
    }

    messageMismatchError = this.label.ApplicantCapture_Format_ErrorMessage
    @track residenceAddress = {};
    // @track options = ['Residence Address'];
    @track options = [
        { label: 'Residence Address', value: 'Residence Address' }
    ];
    @track addressValue = 'Residence Address';
    @track params = {
        ParentObjectName: 'Applicant__c',
        ChildObjectRelName: 'Applicant_Addresses__r',
        parentObjFields: ['Id', 'FullName__c', 'ConsentType__c', 'LoanAppln__r.Product__c', 'EmailIDverificationStatus__c', 'CAVerStatus__c', 'DoctorApiVerStatus__c', 'ArchVerStatus__c', 'LoanAppln__r.LMSUpdTrig__c', 'Type_of_Borrower__c', 'CustProfile__c', 'Constitution__c', 'Title__c', 'FName__c', 'MName__c', 'LName__c', 'DOB__c', 'Age__c', 'Gender__c', 'MthrMdnName__c', 'Father_Name__c', 'ApplType__c',
            'MariStatus__c', 'Nationality__c', 'Religion__c', 'EduQual__c', 'ProfQual__c', 'MediCouncl__c', 'MobNumber__c', 'OTP_Verified__c', 'Is_Physical_Consent_Validated__c', 'EmailId__c', 'RegistrationNumber__c', 'YearOfRegistration__c', 'Listed_Unlisted__c', 'Partnership_registration_no__c',
            'PhoneNumber__c', 'CKYC_Number__c', 'SpName__c', 'CompanyName__c', 'DOI__c', 'KeyManName__c', 'InceptionYears__c', 'CIN__c', 'LLPIN__c', 'MembershipNumber__c', 'Relationship__c', 'Category__c', 'Whether_partnership_is_registered__c', 'LoanAppln__c', 'PAN__c', 'AadhaarNo__c', 'Politically_Exposed_Person__c',
            'Customer_Profile_Categorisation__c', 'Customer_Profile_Selection_Id__c', 'ID_proof_type__c', 'ID_Number__c', 'LEI_Number__c', 'Residential_Status__c', 'Guarantor_is_bringing_in_SPDC__c', 'isPerSameAsResi_ADD__c', 'UCID__c', 'Same_as_Principal_place_for_business__c', 'DrivingLicExpDate__c', 'PassportExpDate__c', 'BorrowerPreferredLanguage__c'],
        childObjFields: ['Id', 'HouseNo__c', 'AddrLine1__c', 'AddrLine2__c', 'Landmark__c', 'Locality__c', 'OwnType__c', 'DisFrmSrcBrnh__c', 'DisFrmFFBrnh__c', 'Nearest_Fedfina_Branch__c', 'MailAddr__c', 'NearestFedBrnchID__c', 'Same_as_Principal_place_for_business__c', 'isPerSameAsResi_ADD__c',
            'City__c', 'State__c', 'Pincode__c', 'LoanAppl__c ', 'AddrStability__c', 'AddrTyp__c', 'Negative_Caution_Area__c', 'StabAtAddressMnth__c', 'StabAtAddressYr__c'],
        queryCriteria: ' where id = \'' + this.recordId + '\''
    }

    @track paramsKYC = {
        ParentObjectName: 'DocDtl__c',
        parentObjFields: ['Id', 'Appl__c', 'Appl__r.Constitution__c', 'Applicant_KYC__r.DtOfBirth__c', 'Applicant_KYC__r.FatherName__c', 'Applicant_KYC__r.Name__c', 'Applicant_KYC__r.Gender__c', 'Applicant_KYC__r.Pan__c', 'DocTyp__c',
            'Applicant_KYC__r.DLNo__c', 'Applicant_KYC__r.AadharNo__c', 'Applicant_KYC__r.NPRNumber__c', 'Applicant_KYC__r.PassNo__c', 'Applicant_KYC__r.VotIdEpicNo__c', 'Applicant_KYC__r.UUID__c', 'Applicant_KYC__r.ValidationStatus__c'],
        queryCriteria: ' where Appl__c = \'' + this.recordId + '\' AND Applicant_KYC__r.ValidationStatus__c = \'Success\' AND  (DocTyp__c = \'Identity Proof\')'
    }

    handleRecordIdChange() {
        let tempParams = this.params;
        tempParams.queryCriteria = ' where id = \'' + this._recordId + '\'';
        this.params = { ...tempParams };

        let paramKYCTemp = this.paramsKYC;
        paramKYCTemp.queryCriteria = ' where Appl__c = \'' + this._recordId + '\'  AND ((DocTyp__c  = \'' + 'Identity Proof' + '\'' + ') OR (DocTyp__c  = \'' + 'PAN' + '\'' + ' ) OR (DocTyp__c  = \'' + 'DOB Proof' + '\'' + ' ))' + ' ORDER BY LASTMODIFIEDDATE DESC';
        this.paramsKYC = { ...paramKYCTemp };
    }

    @track isReadOnly = false;
    @track appId;
    //object to pass data 
    @track wrapObj = {};
    @track activeSection = ["A", "B"];
    @track activeSectionName = ['Res_Add'];
    @track nationalityOptions = [];
    @track policExpPersonOptions = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ];
    @track isResReq = true;

    @wire(getObjectInfo, { objectApiName: APPLICANT_OBJECT })
    objectInfo

    @wire(getPicklistValuesByRecordType, {
        objectApiName: APPLICANT_OBJECT,
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    })
    picklistHandler({ data, error }) {
        if (data) {
            this.nationalityOptions = [...this.generatePicklist(data.picklistFieldValues.Nationality__c)]
            console.log('nationalityOptions ', this.nationalityOptions);

        }
        if (error) {

        }
    }

    generatePicklist(data) {
        if (data) {
            return data.values.map(item => ({ "label": item.label, "value": item.value }))
        }
        return null;
    }
    @track wiredData = {};
    @track oldMobileNumber;
    @track applicantType;
    @track appUCID;
    @wire(getSobjectDatawithRelatedRecords, { params: '$params' })
    handleResponse(wiredApplicantData) {
        let { error, data } = wiredApplicantData;
        this.wiredData = wiredApplicantData;
        this.wrapObj = {};
        if (data) {
            this.wrapObj = {
                ...data.parentRecord, Age__c: this.getNumber(data.parentRecord.DOB__c), Nationality__c: 'INDIA',
                Father_Name__c: data.parentRecord.Father_Name__c ? data.parentRecord.Father_Name__c.toUpperCase() : '', SpName__c: data.parentRecord.SpName__c ? data.parentRecord.SpName__c.toUpperCase() : ''
            };
            this.applicantType = data.parentRecord.ApplType__c ? data.parentRecord.ApplType__c : '';
            this.oldMobileNumber = data.parentRecord.MobNumber__c;
            this.appUCID = data.parentRecord.UCID__c;
            if (data.ChildReords) {
                data.ChildReords.forEach(item => {
                    if (item.AddrTyp__c === 'Residence Address') {
                        this.residenceAddress = { ...item }
                        this.is_Open_Res_add = true;
                        this.addressValue = 'Residence Address'
                    }
                    // if (item.AddrTyp__c === 'Residence Cum office') {
                    //     this.resiCusOfficeAddress = { ...item }
                    //     this.is_Open_Res_Cum_add = true;
                    //     this.addressValue = 'Residence Address'
                    // }
                    // if (item.MailAddr__c === true) {
                    //     this.mailingAddCounter = this.mailingAddCounter + 1;
                    // }
                });
            }
            this.isClick = false;
            this.checkValidationForBlPl(data.parentRecord.LoanAppln__r.Product__c, data.parentRecord.ConsentType__c, data.parentRecord.Constitution__c);
        }
        if (error) {
            console.error('error in getting bo applicant data ', error);
        }
        this.showSpinner = false;
    }

    @track productType;
    @track consentType;
    @track consitutionType
    @track reqIndiviDetails = false;
    checkValidationForBlPl(productType, consentType, ConsitutionType) {
        this.productType = productType
        this.consentType = consentType
        this.consitutionType = ConsitutionType;
        if (this.consentType == 'Digital Consent' && (this.productType == 'Personal Loan' || this.productType == 'Business Loan') && ConsitutionType == 'INDIVIDUAL') {
            this.reqIndiviDetails = true;
        } else if (this.consentType == 'Physical Consent Upload' && (this.productType == 'Personal Loan' || this.productType == 'Business Loan') && ConsitutionType == 'INDIVIDUAL') {
            this.reqIndiviDetails = false;
        } else if (ConsitutionType == 'INDIVIDUAL') {
            this.reqIndiviDetails = true;
        }
    }

    // get handleFathersName() {
    //     return this.wrapObj.MariStatus__c === 'S';
    // }

    // get handleSpouseName() {
    //     return this.wrapObj.MariStatus__c === 'M' || this.wrapObj.MariStatus__c === 'W';
    // }

    @track wiredAppKycData = {};
    @track appKYC = [];
    @track appKYCAll = [];
    @wire(getSobjectData, { params: '$paramsKYC' })
    handleAppKyc(result) {
        this.wiredAppKycData = result;
        if (result.data) {
            this.appKYC = [];
            this.appKYCAll = [];
            if (result.data.parentRecords && result.data.parentRecords.length > 0) {
                result.data.parentRecords.forEach(item => {
                    let obj = { docType: item.DocTyp__c, appKyc: item.Applicant_KYC__r, constitution: item.Appl__r.Constitution__c };
                    if (item.Applicant_KYC__r && item.Applicant_KYC__r.ValidationStatus__c && item.Applicant_KYC__r.ValidationStatus__c === 'Success') {
                        this.appKYC.push(obj);
                    }
                    this.appKYCAll.push(obj);
                })
            }
        }
        if (result.error) {
            console.error('error in getting bo applicant kyc data ', result.error);
        }
    }

    get identityProofNumber() {
        var idProofNumber;
        if (this.appKYCAll) {
            this.appKYCAll.forEach(item => {
                if (item && item.constitution === 'INDIVIDUAL') {
                    if (item.docType && item.docType == 'Identity Proof' && item.appKyc) {
                        if (item && item.appKyc && item.appKyc.Pan__c) {
                            idProofNumber = item.appKyc.Pan__c;
                        }
                        else if (item && item.appKyc && item.appKyc.DLNo__c) {
                            idProofNumber = item.appKyc.DLNo__c;
                        } else if (item && item.appKyc && item.appKyc.AadharNo__c) {
                            idProofNumber = item.appKyc.AadharNo__c;
                        } else if (item && item.appKyc && item.appKyc.NPRNumber__c) {
                            idProofNumber = item.appKyc.NPRNumber__c;
                        } else if (item && item.appKyc && item.appKyc.PassNo__c) {
                            idProofNumber = item.appKyc.PassNo__c;
                        } else if (item && item.appKyc && item.appKyc.VotIdEpicNo__c) {
                            idProofNumber = item.appKyc.VotIdEpicNo__c;
                        }
                    }
                } else {
                    if (item && item.appKyc && item.appKyc.Pan__c != undefined && item.appKyc.Pan__c) {
                        idProofNumber = item.appKyc.Pan__c;
                    }
                }
            })
            if (idProofNumber) {
                this.wrapObj.ID_Number__c = idProofNumber;
            }
        }
        if (!idProofNumber) {
            idProofNumber = this.wrapObj.ID_Number__c;
            if (this.disableMode) {
                this.disableIdNumber = true;
            }
        } else {
            this.disableIdNumber = true;
        }
        return idProofNumber;
    }


    get identityProofType() {
        var idProofType;
        if (this.appKYCAll) {
            this.appKYCAll.forEach(item => {
                if (item && item.constitution === 'INDIVIDUAL') {
                    if (item.docType === 'Identity Proof' && item.appKyc) {
                        if (item && item.appKyc && item.appKyc.Pan__c) {
                            idProofType = 'PAN';
                            return;
                        }
                        else if (item && item.appKyc && item.appKyc.DLNo__c) {
                            idProofType = 'Driving License';
                            return;
                        } else if (item && item.appKyc && item.appKyc.AadharNo__c) {
                            idProofType = 'Aadhaar';
                            return;
                        }
                        else if (item && item.appKyc && item.appKyc.NPRNumber__c) {
                            idProofType = 'Letter issued by the National Population Register';
                            return;
                        }
                        else if (item && item.appKyc && item.appKyc.PassNo__c) {
                            idProofType = 'Passport';
                            return;
                        } else if (item && item.appKyc && item.appKyc.VotIdEpicNo__c) {
                            idProofType = 'VoterId';
                            return;
                        }
                    }
                } else {
                    idProofType = 'PAN';
                }
            })
            if (idProofType) {
                let idProofTypeUppCase = idProofType.toUpperCase();
                idProofType = idProofTypeUppCase;
                this.wrapObj.ID_proof_type__c = idProofType;
            }
        }
        if (!idProofType) {
            idProofType = this.wrapObj.ID_proof_type__c;
            if (this.disableMode) {
                this.disableIdProofType = true;
            }
        } else {
            this.disableIdProofType = true;
        }
        return idProofType;
    }

    get panNumber() {
        var panNumberData;
        if (this.appKYCAll) {
            this.appKYCAll.forEach(item => {
                if (item.appKyc && item.appKyc.Pan__c) {
                    panNumberData = item.appKyc.Pan__c;
                    this.wrapObj.PAN__c = item.appKyc.Pan__c;
                    return;
                }

            })
        }
        return panNumberData;
    }
    get isOCREditFatherName() {
        let detailsMacthed = false;
        if (this.hasEditAccess) {
            if (this.appKYC) {
                this.appKYC.forEach(item => {
                    if (item.docType === 'Identity Proof') {
                        if ((item.appKyc.FatherName__c && this.fathername === item.appKyc.FatherName__c) || this.disableMode) {
                            detailsMacthed = true;
                        }
                    }

                })

            }
        } else {
            detailsMacthed = true;
        }
        return detailsMacthed;
    }

    connectedCallback() {
        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }

        if (this.applicantIdOnTabset) {
            this.appId = this.applicantIdOnTabset;
        } else if (this.primaryapplicantId) {
            this.appId = this.primaryapplicantId;
        }

        this.activeSection = ["A", "B"];
        this.scribeToMessageChannel();
    }


    @track dob;
    @track is_dobError = false;
    @track dobErrorMessage;
    @track fathername;

    inputChangeHandler(event) {
        this.isClick = true;
        this.wrapObj[event.target.dataset.fieldname] = event.target.value
        if (event.target.dataset.fieldtype === 'string') {
            let strVal = event.target.value;
            this.wrapObj[event.target.dataset.fieldname] = strVal.toUpperCase();
        }
        if (event.target.dataset.fieldname === 'DOB__c') {
            this.dob = event.target.value;
            if (this.validateDOB(this.wrapObj.DOB__c) == false) {
                this.is_dobError = true
                this.dobErrorMessage = 'Please enter valid date of birth'
            } else {
                this.is_dobError = false
                this.dobErrorMessage = ''
                this.wrapObj.Age__c = this.getNumber(this.wrapObj.DOB__c);
            }
        }
        if (event.target.dataset.fieldname === 'Father_Name__c') {
            this.fathername = event.target.value;
        }
    }

    getNumber(value) {
        var millis = Date.now() - new Date(value).getTime()
        var age = new Date(millis)
        return Math.abs(age.getUTCFullYear() - 1970)
    }
    validateDOB(dob) {
        const date = new Date(dob);
        if (isNaN(date.getTime())) {
            return false; // Invalid date format
        }
        const currentDate = new Date();
        const minDate = new Date();
        minDate.setFullYear(minDate.getFullYear() - 18);

        if (date > currentDate || date > minDate) {
            return false; // Date of birth is in the future or less than 18 years old
        }
        return true;
    }

    // handleAddressSelection(event) {

    //     this.addressValue = event.target.value
    //     const selectedValue = event.detail.value;

    //     let Obj = {};
    //     Obj.AddrTyp__c = selectedValue;

    //     const isDuplicate = this.ChildRecords.some(item => item.AddrTyp__c === Obj.AddrTyp__c);
    //     if (!isDuplicate) {
    //         this.ChildRecords.push(Obj);
    //     }

    //     if (selectedValue === 'Residence Address') {
    //         this.activeSectionName = 'Res_Add';
    //     }
    //     // else if (selectedValue === 'Permanent Address') {
    //     //     this.activeSectionName = 'Per_Add';
    //     // } else if (selectedValue === 'Residence Cum office') {
    //     //     this.activeSectionName = 'Res_Cum_Off_Add';
    //     // } else if (selectedValue === 'Registered place for business') {
    //     //     this.activeSectionName = 'Reg_Bus_Add';
    //     // } else if (selectedValue === 'Principal place for business') {
    //     //     this.activeSectionName = 'Pri_Place_Add';
    //     // } else if (selectedValue === 'Other Address') {
    //     //     this.activeSectionName = 'Oth_Add';
    //     // } else if (selectedValue === 'Office Address') {
    //     //     this.activeSectionName = 'Ofc_Add';
    //     // }
    //     // this.open_res_Res();
    //     // this.open_per_Add();
    //     // this.open_Residence_Cum_office();
    //     // this.open_Registered_place_for_business();
    //     // this.open_Principal_place_for_business();
    //     // this.open_Other_Address();
    //     // this.open_Office_Address();
    // }

    handleChildResidenceData(event) {
        // if (this.isAddressSame) {
        //     this.copyResiObjMethod(event);
        // }
        this.isClick = true;
        console.log('event.detail in adress is ', event.detail);

        this.residenceAddress = { ...this.residenceAddress, ...event.detail }
        //this.residenceAddresscheckbox = event.detail.MailAddr__c;
        // this.checkForMultipleSelection();
        // if (this.selectedCount > 1 && this.residenceAddresscheckbox) {
        //     this.showerror = true;
        // } else {
        //     this.showerror = false;
        // }
    }

    @track mailingAddCounter = 0;
    handleResidenceMailingAdd(event) {
        this.residenceAddress = JSON.parse(JSON.stringify(this.mailingAddCheck_reusable(this.residenceAddress, event)));
    }

    mailingAddCheck_reusable(obj, event) {
        if (event.detail === "true") {
            this.mailingAddCounter = this.mailingAddCounter + 1;
            obj.MailAddr__c = true
        } if (event.detail === "false") {
            this.mailingAddCounter = this.mailingAddCounter - 1;
            obj.MailAddr__c = false
        }
        return obj;
    }
    checkForMultipleSelection() {
        this.selectedCount = [
            this.officeAddresscheckbox,
            this.otherAddresscheckbox,
            this.permanentAddresscheckbox,
            this.residenceAddresscheckbox
        ].filter(selected => selected).length;
        if (this.selectedCount < 2) {
            this.showerror = false;
        }
    }

    blurHandler(event) {
        if (event.target.dataset.fieldtype === 'string') {
            let strVal = event.target.value;
            this.wrapObj[event.target.dataset.fieldname] = trimFunction(strVal)
        }
    }

    get conditionallyRequiredIndividual() {
        return this.wrapObj.Constitution__c === 'INDIVIDUAL';
    }
    get conditionallyRequiredNationality() {
        return this.wrapObj.Nationality__c === 'INDIA';
    }

    get isOCREditDOB() {
        let detailsMacthed = false;
        if (this.appKYC) {
            this.appKYC.forEach(item => {
                if (item.docType === 'DOB Proof') {
                    if ((item.appKyc.DtOfBirth__c && this.dob === item.appKyc.DtOfBirth__c) || this.disableMode) {
                        detailsMacthed = true;
                    }
                }
                if (item.docType === 'Identity Proof') {
                    if ((item.appKyc.DtOfBirth__c && this.dob === item.appKyc.DtOfBirth__c) || this.disableMode) {
                        detailsMacthed = true;
                    }
                }

            })
        }
        return detailsMacthed || this.isReadOnly;
    }

    @wire(MessageContext)
    MessageContext;

    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }

    handleSaveThroughLms(values) {
        this.handleSave(values.validateBeforeSave);
    }

    handleSave(validate) {
        if (validate) {
            let isInputCorrect = this.validateForm();
            if (isInputCorrect === true) {
                this.handleUpsert();
            } else {
                this.showToastMessage('Error', this.label.ALL_FIELDS_Label, 'error', 'sticky');
            }

        } else {
            this.handleUpsert();
        }
    }
    validateForm() {
        let isValid = true
        //LAK-7867
        if (!this.identityProofNumber || !this.identityProofType) {
            this.showToastMessage('Error', 'Please update ID details from the PAN & KYC Page', 'error', 'sticky');
            isValid = false;
        }

        if (this.wrapObj.Type_of_Borrower__c === 'Financial' && this.wrapObj.CustProfile__c === 'SALARIED' && this.wrapObj.Constitution__c === 'INDIVIDUAL') {
            if (this.isEmptyObject(this.residenceAddress)) {
                this.isResReq = true
                this.showToastMessage('Error', this.label.ApplicantDetails_ResidenceBusineesAdd_ErrorMessage, 'error', 'sticky');
                isValid = false;
            }
        }
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if (element.reportValidity()) {
            } else {
                isValid = false;
            }
        });

        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
            } else {
                isValid = false;
            }
        });
        return isValid;
    }

    @track isClick = false;
    handleUpsert() {
        if (this.isClick) {
            //   return this.isClick;


            this.isClick = true;
            this.showSpinner = true;
            this.childRecordsContainer();
            this.wrapObj.sobjectType = 'Applicant__c';
            if (this.applicantType !== 'APPLICANT') {
                if (!this.wrapObj.LoanAppln__c) {
                    this.wrapObj.LoanAppln__c = this.loanAppId ? this.loanAppId : null;
                }
            }
            let upsertData = {
                parentRecord: this.wrapObj,
                ChildRecords: this.ChildRecords,
                ParentFieldNameToUpdate: 'Applicant__c'
            }
            upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
                .then(result => {
                    if (this._recordId) {
                        console.log('reslt is ', result);
                    }
                    this.showToastMessage('Success', 'Bo Details saved successfully', 'success', 'sticky')
                    refreshApex(this.wiredData);
                    if (!this.appUCID) {
                        this.generateUCIDForApp();
                    }
                    this.isClick = false;
                    this.showSpinner = false;
                })
                .catch(error => {
                    this.isClick = false;
                    this.showSpinner = false;

                })
        } else {
            this.showToastMessage('Error', 'No Change in input data', 'error', 'sticky');
        }
    }

    @track intRecords = [];
    generateUCIDForApp() {
        let fieldsWo = {};
        fieldsWo['sobjectType'] = 'IntgMsg__c';
        fieldsWo['Name'] = 'UCIC API Token'; //serviceName;//'KYC OCR'
        fieldsWo['BU__c'] = 'HL / STL';
        fieldsWo['IsActive__c'] = true;
        fieldsWo['Svc__c'] = 'Dedupe API Token'; //serviceName;
        fieldsWo['ExecType__c'] = 'Async';
        fieldsWo['Status__c'] = 'New';
        fieldsWo['Mresp__c'] = 'Blank';
        fieldsWo['Outbound__c'] = true;
        fieldsWo['Trigger_Platform_Event__c'] = false;
        fieldsWo['RefObj__c'] = 'Applicant__c';
        fieldsWo['RefId__c'] = this.recordId;
        fieldsWo['ParentRefObj__c'] = "LoanAppl__c";
        fieldsWo['ParentRefId__c'] = this.loanAppId;
        this.intRecords.push(fieldsWo);
        this.upsertIntRecord(this.intRecords);
    }

    upsertIntRecord(intRecords) {
        console.log('int msgs records ', JSON.stringify(intRecords));
        upsertMultipleRecord({ params: intRecords })
            .then((result) => {
                console.log('###upsertMultipleRecord###' + result);
                // if (this.appIDsforUCID.length > 0) {
                //     this.fireCustomEvent("Hunter:", "success", "UCID Creation Initiated Successfully");
                // }
                this.intRecords = [];
            })
            .catch((error) => {
                console.log('Error In creating Record', error);
                // this.fireCustomEvent("Error", "error", "Error occured in accepting File  " + error.message, false);
            });
    }
    childRecordsContainer() {
        this.ChildRecords = [];
        if (!this.isEmptyObject(this.residenceAddress)) {
            this.residenceAddress.sobjectType = 'ApplAddr__c';
            this.residenceAddress.AddrTyp__c = this.residenceAddress.AddrTyp__c ? this.residenceAddress.AddrTyp__c : 'Residence Address';
            this.ChildRecords.push(this.residenceAddress);
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
    isEmptyObject(obj) {
        return Object.keys(obj).length === 0;
    }
}