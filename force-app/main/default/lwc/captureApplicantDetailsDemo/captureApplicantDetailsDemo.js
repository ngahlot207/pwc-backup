import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, deleteRecord } from 'lightning/uiRecordApi';
import { getPicklistValues, getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Object Refernce  
import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';
import APPLICANT_ADD_OBJECT from '@salesforce/schema/ApplAddr__c';

// Custom labels 
import APPLICANT_SUCCESS_Label from '@salesforce/label/c.ApplicantCapture_SuccessMessage';
import ApplicantCapture_Format_ErrorMessage from '@salesforce/label/c.ApplicantCapture_Format_ErrorMessage';
import ALL_FIELDS_Label from '@salesforce/label/c.LeadCapture_BasicDetails_RequiredFieldsValidation';
import ApplicantAddressMailing_ErrorMessage from '@salesforce/label/c.ApplicantAddressMailing_ErrorMessage';
import NoApplicantAddressMailing_ErrorMessage from '@salesforce/label/c.NoApplicantAddressMailing_ErrorMessage';
import ApplicantDetails_Consent_ErrorMessage from '@salesforce/label/c.ApplicantDetails_Consent_ErrorMessage';
import ApplicantDetails_ResidenceAdd_ErrorMessage from '@salesforce/label/c.ApplicantDetails_ResidenceAdd_ErrorMessage';
import ApplicantDetails_PrincipalBusineesAdd_ErrorMessage from '@salesforce/label/c.ApplicantDetails_PrincipalBusineesAdd_ErrorMessage';
import ApplicantDetails_ResidenceBusineesAdd_ErrorMessage from '@salesforce/label/c.ApplicantDetails_ResidenceBusineesAdd_ErrorMessage';
import ApplicantDetails_OfficeAdd_ErrorMessage from '@salesforce/label/c.ApplicantDetails_OfficeAdd_ErrorMessage';
import ApplicantDetails_ResidenceAddMandatory_ErrorMessage from '@salesforce/label/c.ApplicantDetails_ResidenceAddMandatory_ErrorMessage';
import ApplicantDetails_PrincipalBusineesAddReq_ErrorMessage from '@salesforce/label/c.ApplicantDetails_PrincipalBusineesAddReq_ErrorMessage';
import ApplicantDetails_BusineesPlaceReq_ErrorMessage from '@salesforce/label/c.ApplicantDetails_BusineesPlaceReq_ErrorMessage';
import ApplicantDetails_PAN_ErrorMessage from '@salesforce/label/c.ApplicantDetails_PAN_ErrorMessage';
import ApplicantDetails_multMailAdd_ErrorMessage from '@salesforce/label/c.ApplicantDetails_multMailAdd_ErrorMessage';
import ApplicantDetails_CoApp_SuccesMessage from '@salesforce/label/c.ApplicantDetails_CoApp_SuccesMessage';
import ApplicantDetails_RegisteredBusineesPlaceReq_ErrorMessage from '@salesforce/label/c.ApplicantDetails_RegisteredBusineesPlaceReq_ErrorMessage';
import ApplicantDetails_PrincipalRegisteredBusineesAddReq_ErrorMessage from '@salesforce/label/c.ApplicantDetails_PrincipalRegisteredBusineesAddReq_ErrorMessage';

//Apex methods
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getRelationShipDetails from '@salesforce/apex/DataSearchClass.getRelationShipDetails';
import getAddressData from '@salesforce/apex/DataSearchClass.getAddressData';

//Fields Mandatory/NonMandatory For RM/CPA 
import CURRENT_USER_ID from "@salesforce/user/Id";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';


//LMS details
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';

//refresh wire adapter
import { refreshApex } from '@salesforce/apex';

const customerProfileVisibleOptions = ["SALARIED", "SELF EMPLOYED NON PROFESSIONAL", "SELF EMPLOYED PROFESSIONAL", "HOUSEWIFE", "OTHERS"];

export default class CaptureApplicantDetailsDemo extends LightningElement {
    label = {
        APPLICANT_SUCCESS_Label,
        ApplicantCapture_Format_ErrorMessage,
        ALL_FIELDS_Label,
        ApplicantAddressMailing_ErrorMessage,
        NoApplicantAddressMailing_ErrorMessage,
        ApplicantDetails_Consent_ErrorMessage,
        ApplicantDetails_ResidenceAdd_ErrorMessage,
        ApplicantDetails_PrincipalBusineesAdd_ErrorMessage,
        ApplicantDetails_ResidenceBusineesAdd_ErrorMessage,
        ApplicantDetails_OfficeAdd_ErrorMessage,
        ApplicantDetails_ResidenceAddMandatory_ErrorMessage,
        ApplicantDetails_PrincipalBusineesAddReq_ErrorMessage,
        ApplicantDetails_BusineesPlaceReq_ErrorMessage,
        ApplicantDetails_PAN_ErrorMessage,
        ApplicantDetails_multMailAdd_ErrorMessage,
        ApplicantDetails_CoApp_SuccesMessage,
        ApplicantDetails_RegisteredBusineesPlaceReq_ErrorMessage,
        ApplicantDetails_PrincipalRegisteredBusineesAddReq_ErrorMessage

    }

    @track wiredData = {};
    @track wiredAppKycData = {};
    @track _recordId = 'a0AC4000000HP5FMAW';
    @track recordId = '	a0AC4000000HP5FMAW';
    @api loanAppId = 'a08C4000007P2aTIAS';
    @track selectedRecordId;;


    //@api recordId  
    @api isReadOnly = false;
    @api layoutSize = {
        "small": "12",
        "medium": "6",
        "large": "4"
    };
    @track hasEditAccess = true;
    @api stepperName;
    //track properties
    @track activeSection = ["A", "B"];
    @track disableMode;

    //normal properties
    doiErrMessage
    registrationNumberPattern = ''
    yearOfRegistrationPattern = ''
    membershipNumberPattern = ''
    addressValue;
    relationshipValue = ''
    relationShipLabel = 'Relationship';
    relationShipDisabled = true;
    applicantType = 'APPLICANT'
    typeOfBorrower = 'Financial'
    dobErrorMessage
    genderErrorMessage
    messageMismatchError = this.label.ApplicantCapture_Format_ErrorMessage

    //array properties
    @track applicantTypeOptions = []
    @track customerProfileOptions = []
    @track constitutionOptions = []
    @track titleOptions = []
    @track genderOptions = []
    @track maritalStatusOptions = []
    @track nationalityOptions = []
    @track religionStatusOptions = []
    @track educationalOptions = []
    @track professionalOptions = []
    @track medicalCouncilOptions = []
    @track categoryOptions = []
    @track partnershipOptions = []
    @track addressOptions = []
    @track options = []
    @track relationShipOptions = [];
    @track ChildRecords = [];
    @track showerror = false;
    @track selectedCount;


    //boolean properties
    is_Per_Add_Visible = false
    isProfessional = true //should be false by default
    isAddressSame = false
    disabledFlag = false
    is_dobError = false
    is_genderError = false
    //prncplAddrsNotPrsnt = false;

    //object to pass data 
    @track wrapObj = {};
    @track childDataWrapper = {};
    @track residenceAddress = {};
    @track permanentAddress = {};
    @track resiCusOfficeAddress = {};
    @track regiBussiAddress = {};
    @track princiBussiAddress = {};
    @track otherAddress = {};
    @track officeAddress = {};
    @track dob;
    @track gender;
    @track fathername;
    @track officeAddresscheckbox = false;
    @track otherAddresscheckbox = false;
    @track permanentAddresscheckbox = false;
    @track residenceAddresscheckbox = false;

    @track policExpPersonOptions = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ];

    @track customerProfilCatOptions = [];


    // Team Hierachy code start

    @track
    parameterforTeam = {
        ParentObjectName: 'TeamHierarchy__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'EmpRole__c '],
        childObjFields: [],
        queryCriteria: 'WHERE Employee__c=\'' + CURRENT_USER_ID + '\'' + 'ORDER BY LastModifiedDate DESC'
    }



    loanappids = this.loanAppId;


    @track userTeamRoleData;
    @wire(getSobjectData, { params: '$parameterforTeam' })
    handleResponseTeamHierarchy(wiredResultTeam) {
        let { error, data } = wiredResultTeam;
        //console.log('in wire team' + wiredResultTeam);
        if (data) {
            //console.log('Data Team------------>' + JSON.stringify(data));
            //console.log('Role of User---------------->' + data.parentRecords[0].EmpRole__c);
            //console.log('Length of Role---------------->' + data.parentRecords.length);
            if (data.parentRecords.length > 0) {
                let userTeamRole = data.parentRecords[0].EmpRole__c;
                if (userTeamRole) {
                    this.userTeamRoleData = userTeamRole;
                }
                if (userTeamRole === 'RM') {
                    this.isCINRequired = false;
                }
                else if (userTeamRole === 'CPA') {
                    this.isCINRequired = true;
                } else {
                    this.isCINRequired = true;
                }

            }
        } else if (error) {
            console.error('Error Team ------------->', error);
        }
    }
    // Team Hierachy code Ended


    @track
    params = {
        ParentObjectName: 'Applicant__c',
        ChildObjectRelName: 'Applicant_Addresses__r',
        parentObjFields: ['Id', 'Type_of_Borrower__c', 'CustProfile__c', 'Constitution__c', 'Title__c', 'FName__c', 'MName__c', 'LName__c', 'DOB__c', 'Age__c', 'Gender__c', 'MthrMdnName__c', 'Father_Name__c', 'ApplType__c',
            'MariStatus__c', 'Nationality__c', 'Religion__c', 'EduQual__c', 'ProfQual__c', 'MediCouncl__c', 'MobNumber__c', 'OTP_Verified__c', 'Is_Physical_Consent_Validated__c', 'EmailId__c', 'RegistrationNumber__c', 'YearOfRegistration__c', 'Listed_Unlisted__c', 'Partnership_registration_no__c',
            'PhoneNumber__c', 'CKYC_Number__c', 'SpName__c', 'CompanyName__c', 'DOI__c', 'KeyManName__c', 'InceptionYears__c', 'CIN__c', 'LLPIN__c', 'MembershipNumber__c', 'Relationship__c', 'Category__c', 'Whether_partnership_is_registered__c', 'LoanAppln__c', 'PAN__c', 'Politically_Exposed_Person__c',
            'Customer_Profile_Categorisation__c', 'Customer_Profile_Selection__c', 'Customer_Profile_Selection_Id__c', 'ID_proof_type__c', 'ID_Number__c'],
        childObjFields: ['Id', 'HouseNo__c', 'AddrLine1__c', 'AddrLine2__c', 'Landmark__c', 'Locality__c', 'OwnType__c', 'DisFrmSrcBrnh__c', 'DisFrmFFBrnh__c', 'Nearest_Fedfina_Branch__c', 'MailAddr__c',
            'City__c', 'State__c', 'Pincode__c', 'AddrStability__c', 'AddrTyp__c'],
        queryCriteria: ' where id = \'' + this.recordId + '\''
    }

    @track
    paramsKYC = {
        ParentObjectName: 'DocDtl__c',
        parentObjFields: ['Id', 'Appl__c', 'Applicant_KYC__r.DtOfBirth__c', 'Applicant_KYC__r.FatherName__c', 'Applicant_KYC__r.Name__c', 'Applicant_KYC__r.Gender__c', 'Applicant_KYC__r.PAN__C', 'DocTyp__c',
            'Applicant_KYC__r.DLNo__c', 'Applicant_KYC__r.AadharNo__c', 'Applicant_KYC__r.PassNo__c', 'Applicant_KYC__r.VotIdEpicNo__c'],
        queryCriteria: ' where Appl__c = \'' + this.recordId + '\' AND Applicant_KYC__r.ValidationStatus__c = \'Success\' AND DocTyp__c = \'Identity Proof\''
    }

    get handleFathersName() {
        return this.wrapObj.MariStatus__c === 'S';
    }

    get handleSpouseName() {
        return this.wrapObj.MariStatus__c === 'M' || this.wrapObj.MariStatus__c === 'W';
    }

    get handleListedVisibility() {
        return this.wrapObj.Constitution__c === 'PUBLIC LIMITED COMPANY';
    }

    get disbledConstitution() {
        return (this.wrapObj.CustProfile__c === 'SALARIED' || this.wrapObj.CustProfile__c === "HOUSEWIFE" || this.wrapObj.CustProfile__c === "OTHERS" || this.disableMode === true);
    }

    get disabledCustomerProfile() {
        if (this.wrapObj.ApplType__c && (this.wrapObj.ApplType__c === 'G' || this.wrapObj.ApplType__c === 'C')) {
            return true;
        } else {
            return false;
        }
    }

    get conditionallyRequiredIndividual() {
        return this.wrapObj.Constitution__c === 'INDIVIDUAL';
    }

    get conditionallyRequiredNonIndividual() {
        return this.wrapObj.Constitution__c != 'INDIVIDUAL';
    }

    get conditionallyRequiredNationality() {
        return this.wrapObj.Nationality__c === 'INDIA';
    }

    get handleLLPINVisibility() {
        return this.wrapObj.Constitution__c === 'LIMITED LIABILITY PARTNERSHIP';
    }

    get conditionallyRequiredProfessionalQue() {
        return this.wrapObj.EduQual__c === 'PRF';
    }

    get conditionallyRequiredRegistrationNum() {
        return this.regNumReq()
    }

    get handlePartRegiNoVisibility() {
        return this.wrapObj.Whether_partnership_is_registered__c === 'Yes';
    }

    regNumReq() {
        if (this.wrapObj.ProfQual__c && (this.wrapObj.ProfQual__c.includes("DOC") || this.wrapObj.ProfQual__c.includes("ART"))) {
            return false
        } else {
            return true
        }
    }

    get conditionallyRequiredYOR() {
        return this.YORReq()
    }

    YORReq() {
        if (this.wrapObj.ProfQual__c && this.wrapObj.ProfQual__c.includes("DOC")) {
            return false
        } else {
            return true
        }
    }

    get conditionallyRequiredMembershipNum() {
        return this.memNumReq()
    }

    memNumReq() {
        if (this.wrapObj.ProfQual__c && (this.wrapObj.ProfQual__c.includes("CA") || this.wrapObj.ProfQual__c.includes("CS") || this.wrapObj.ProfQual__c.includes("ICWAI"))) {
            return false
        } else {
            return true
        }
    }

    get handleCINVisibility() {
        if (this.wrapObj.Constitution__c === 'PRIVATE LIMITED COMPANY' || this.wrapObj.Constitution__c === 'PUBLIC LIMITED COMPANY') {
            return true
        }
        else {
            return false
        }
    }

    get handleRegiPartnerVisibility() {
        if (this.wrapObj.Constitution__c === 'PARTNERSHIP' || this.wrapObj.Constitution__c === 'LIMITED LIABILITY PARTNERSHIP') {
            return true
        }
        else {
            return false
        }
    }

    @wire(MessageContext)
    MessageContext;

    handleRecordIdChange() {
        let tempParams = this.params;
        tempParams.queryCriteria = ' where id = \'' + this._recordId + '\'';
        this.params = { ...tempParams };

        let paramKYCTemp = this.paramsKYC;
        paramKYCTemp.queryCriteria = ' where Appl__c = \'' + this._recordId + '\' AND Applicant_KYC__r.ValidationStatus__c = \'Success\' AND ((DocTyp__c  = \'' + 'Identity Proof' + '\'' + ') OR (DocTyp__c  = \'' + 'PAN' + '\'' + ' ))' + ' ORDER BY LASTMODIFIEDDATE DESC';
        this.paramsKYC = { ...paramKYCTemp };
    }

    @track showSpinner = true;



    @track appKYC = [];
    @wire(getSobjectData, { params: '$paramsKYC' })
    handleAppKyc(result) {
        this.wiredAppKycData = result;
        if (result.data) {
            console.log('Appl kyc data=', JSON.stringify(result.data));
            if (result.data.parentRecords && result.data.parentRecords.length > 0) {
                result.data.parentRecords.forEach(item => {
                    let obj = item.Applicant_KYC__r;
                    this.appKYC.push(obj);
                })
            }
            //console.log('this.appKYC ', JSON.stringify(this.appKYC));
            // if (result.data.parentRecord && result.data.parentRecord.Applicant_KYC__r) {
            //     this.appKYC = result.data.parentRecord.Applicant_KYC__r;
            // }
        }
        if (result.error) {
            console.error('appl kyc error=', result.error);
        }
    }

    // Pratap

    get cpaVisibilityCondition() {
        if (this.userTeamRoleData && this.userTeamRoleData === 'CPA') {
            return true;
        } else {
            return false;
        }
    }

    get identityProofNumber() {
        var idProofNumber;
        if (this.appKYC) {
            this.appKYC.forEach(item => {
                if (item.PAN__c) {
                    idProofNumber = item.PAN__c;
                    return;
                }
                else if (item.DLNo__c) {
                    idProofNumber = item.DLNo__c;
                    return;
                } else if (item.AadharNo__c) {
                    idProofNumber = item.AadharNo__c;
                    return;
                } else if (item.PassNo__c) {
                    idProofNumber = item.PassNo__c;
                    return;
                } else if (item.VotIdEpicNo__c) {
                    idProofNumber = item.VotIdEpicNo__c;
                    return;

                }
            })
            if (idProofNumber) {
                this.wrapObj.ID_Number__c = idProofNumber;
            }
        }
        return idProofNumber;
    }


    get identityProofType() {
        var idProofType;
        if (this.appKYC) {
            this.appKYC.forEach(item => {
                if (item.PAN__c) {
                    idProofType = 'Driving License';
                    return;
                }
                else if (item.DLNo__c) {
                    idProofType = 'Driving License';
                    return;
                } else if (item.AadharNo__c) {
                    idProofType = 'Aadhaar';
                    return;
                } else if (item.PassNo__c) {
                    idProofType = 'Passport';
                    return;
                } else if (item.VotIdEpicNo__c) {
                    idProofType = 'VoterId';
                    return;
                }
            })

            if (idProofType) {
                this.wrapObj.ID_proof_type__c = idProofType;
            }
        }
        return idProofType;
    }

    get panNumber() {
        var panNumberData;
        if (this.appKYC) {
            this.appKYC.forEach(item => {
                if (item.Pan__c) {
                    panNumberData = item.Pan__c;
                    this.wrapObj.PAN__c = item.Pan__c;
                    return;
                }
            })
        }
        return panNumberData;
    }

    get panNumberRequiredCondition() {
        if (this.wrapObj && this.wrapObj.Type_of_Borrower__c && this.wrapObj.Type_of_Borrower__c === 'Financial') {
            return true;
        } else {
            return false;
        }
    }

    handleValueSelect(event) {
        if (event.detail) {
            if (event.detail.id) {
                this.wrapObj.Customer_Profile_Selection_Id__c = event.detail.id;
                this.selectedRecordId = event.detail.id;
            }
            if (event.detail.subField) {
                this.wrapObj.Customer_Profile_Selection__c = event.detail.subField;
            }
        }
    }

    get customerProfSeleMandatory() {
        if (this.wrapObj.Customer_Profile_Categorisation__c && this.wrapObj.Customer_Profile_Categorisation__c === 'C') {
            return true;
        } else {
            return false;
        }

    }

    get isOCREditDOB() {
        let detailsMacthed = false;
        if (this.appKYC) {
            //console.log('this.dob', this.dob);
            // return this.appKYC.DtOfBirth__c ? this.dob != this.appKYC.DtOfBirth__c : false;
            this.appKYC.forEach(item => {
                if ((item.DtOfBirth__c && this.dob === item.DtOfBirth__c) || this.disableMode) {
                    detailsMacthed = true;
                }
            })
        }
        return detailsMacthed;
    }
    get isOCREditFatherName() {
        let detailsMacthed = false;
        if (this.appKYC) {
            //console.log('this.fathername', this.fathername);

            this.appKYC.forEach(item => {
                if ((item.FatherName__c && this.fathername === item.FatherName__c) || this.disableMode) {
                    detailsMacthed = true;
                }
            })
            //  return this.appKYC.FatherName__c ? this.fathername != this.appKYC.FatherName__c : false;

        }
        return detailsMacthed;
    }
    get isOCREditFirstName() {
        let detailsMacthed = false;
        let name;
        if (this.appKYC) {
            //console.log('this.name', name);
            this.appKYC.forEach(item => {
                if (item.Name__c) {
                    let nameTokens = item.Name__c.split(' ');
                    if (nameTokens.length >= 1) {
                        name = nameTokens[0];
                    }
                }
                if ((name && this.wrapObj.FName__c === name) || this.disableMode) {
                    detailsMacthed = true;
                }
            })
        }
        return detailsMacthed;
    }

    get isOCREditLastName() {
        let detailsMacthed = false;
        let name;
        if (this.appKYC) {
            //console.log('this.name', name);
            this.appKYC.forEach(item => {
                if (item.Name__c) {
                    let nameTokens = item.Name__c.split(' ');
                    if (nameTokens.length >= 3) {
                        let mName = nameTokens[1];
                        for (let i = 2; i < nameTokens.length; i++) {
                            if (i == 2) {
                                name = nameTokens[i];
                            } else {
                                name += ' ' + nameTokens[i];
                            }
                        }
                    }
                    else if (nameTokens.length == 2) {
                        name = nameTokens[1];
                    }
                }
                if ((name && name === this.wrapObj.LName__c) || this.disableMode) {
                    detailsMacthed = true;
                }
            })
        }
        return detailsMacthed;
    }
    get isOCREditGender() {
        let detailsMacthed = false;
        if (this.appKYC) {
            //console.log('gender is ', this.gender + ':::::::' + this.appKYC.Gender__c);
            this.appKYC.forEach(item => {
                if ((item.Gender__c && this.gender === item.Gender__c) || this.disableMode) {
                    detailsMacthed = true;
                }
            })
        }
        return detailsMacthed;
    }


    @track consentProvided = false;

    get mobileNumberDisabled() {
        if (this.disableMode === true) {
            return true;
        } else {
            if (this.consentProvided === false) {
                return true;
            } else {
                return false;
            }
        }
    }

    @track wiredAppAddressData;


    checkMailingAddressData() {
        getAddressData({ applicationId: this.loanAppId })
            .then(result => {
                var dataReceived = result;
                this.handleCheckMailingAddressPresent(dataReceived);
            })
            .catch(error => {
                console.error(error)
            })
    }

    @track allAddressData;

    @wire(getAddressData, { applicationId: '$loanAppId' })
    handleAddressData(result) {
        this.wiredAppAddressData = result;
        if (result.data) {
            this.handleCheckMailingAddressPresent(result.data);
            this.allAddressData = result.data;
        }
        if (result.error) {
            console.error('address error=', result.error);
        }
    }

    @track mailingAddressCheckedPresent = 0;

    handleCheckMailingAddressPresent(data) {
        this.mailingAddressCheckedPresent = 0;
        for (var i = 0; i < data.length; i++) {
            if (data[i].MailAddr__c && data[i].MailAddr__c === true) {
                this.mailingAddressCheckedPresent = this.mailingAddressCheckedPresent + 1;
            }
        }
    }


    @wire(getSobjectDatawithRelatedRecords, { params: '$params' })
    handleResponse(result) {
        // //console.log('handleResponse::::::306',result);
        this.isCoApplicant = false;
        this.wiredData = result
        this.mailingAddCounter = 0;
        if (result.data) {
            //console.log('Initial Data Recied!! ' + JSON.stringify(result.data));
            //console.log('result.data.parentRecord.Applicant_Addresses__r----------->' + JSON.stringify(result.data.parentRecord.Applicant_Addresses__r));
            this.wrapObj = { ...result.data.parentRecord, Age__c: this.getNumber(result.data.parentRecord.DOB__c), InceptionYears__c: this.getNumber(result.data.parentRecord.DOI__c), Nationality__c: 'INDIA', Type_of_Borrower__c: result.data.parentRecord.Type_of_Borrower__c ? result.data.parentRecord.Type_of_Borrower__c : this.typeOfBorrower }
            //Mobile Number verification check 
            if (result.data.parentRecord && result.data.parentRecord.OTP_Verified__c === false
                && result.data.parentRecord.Is_Physical_Consent_Validated__c === false &&
                (result.data.parentRecord.ApplType__c === 'G' || result.data.parentRecord.ApplType__c === 'C')) {
                this.consentProvided = false;
                this.showToastMessage('Error', this.label.ApplicantDetails_Consent_ErrorMessage, 'error', 'dismissable');
            } else {
                this.consentProvided = true;
            }

            if (result.data.parentRecord && result.data.parentRecord.ApplType__c) {
                this.dob = result.data.parentRecord.DOB__c;
                this.gender = result.data.parentRecord.Gender__c;
                this.fathername = result.data.parentRecord.Father_Name__c;
                //console.log('this.fathername::::::', this.fathername);
                if (result.data.parentRecord.ApplType__c === 'P') {
                    this.applicantType = 'APPLICANT';
                    this.wrapObj.ApplType__c = 'P';
                } else if (result.data.parentRecord.ApplType__c === 'C') {
                    this.applicantType = 'CO-APPLICANT';
                    this.wrapObj.ApplType__c = 'C';
                }
                else if (result.data.parentRecord.ApplType__c === 'G') {
                    this.applicantType = 'GUARANTOR';
                    this.wrapObj.ApplType__c = 'G';
                } else {
                    this.applicantType = 'APPLICANT';
                    this.wrapObj.ApplType__c = 'P';
                }
            }
            if (this.applicantType === 'GUARANTOR' || this.applicantType === 'CO-APPLICANT') {
                this.wrapObj.Relationship__c = result.data.parentRecord ? result.data.parentRecord.Relationship__c ? result.data.parentRecord.Relationship__c : '' : '';
                this.relationshipValue = result.data.parentRecord ? result.data.parentRecord.Relationship__c ? result.data.parentRecord.Relationship__c : '' : '';
                this.relationShipLabel = 'Relationship with Applicant';
                this.relationShipDisabled = false;
            } else {
                this.wrapObj.Relationship__c = 'Self';
                this.relationshipValue = 'Self';
                this.relationShipLabel = 'Relationship';
                this.relationShipDisabled = true;
            }
            if (result.data.ChildReords) {
                result.data.ChildReords.forEach(item => {
                    //console.log('Address Type-', item.AddrTyp__c)
                    if (item.AddrTyp__c === 'Permanent Address') {
                        this.permanentAddress = { ...item }
                        this.is_Open_Per_add = true;
                        this.addressValue = 'Permanent Address'
                    }
                    if (item.AddrTyp__c === 'Residence Address') {
                        this.residenceAddress = { ...item }
                        this.is_Open_Res_add = true;
                        this.addressValue = 'Residence Address'
                    }
                    if (item.AddrTyp__c === 'Residence Cum office') {
                        this.resiCusOfficeAddress = { ...item }
                        this.is_Open_Res_Cum_add = true;
                        this.addressValue = 'Residence Address'
                    }
                    if (item.AddrTyp__c === 'Registered place for business') {
                        this.regiBussiAddress = { ...item }
                        this.is_Open_Reg_Bus_add = true;
                        this.addressValue = 'Registered place for business'
                    }
                    if (item.AddrTyp__c === 'Principal place for business') {
                        this.princiBussiAddress = { ...item }
                        this.is_Open_Princi_Bus_add = true;
                        this.addressValue = 'Principal place for business'
                    }
                    if (item.AddrTyp__c === 'Other Address') {
                        this.otherAddress = { ...item }
                        this.is_Open_Other_add = true;
                        this.addressValue = 'Other Address'
                    }
                    if (item.AddrTyp__c === 'Office Address') {
                        this.officeAddress = { ...item }
                        this.is_Open_Office_add = true;
                        this.addressValue = 'Office Address'
                    }
                    if (item.MailAddr__c === true) {                       //**********************/

                        this.mailingAddCounter = this.mailingAddCounter + 1;
                    }
                    //console.log('Checking Mailing Add ##253 ', this.mailingAddCounter)
                });
            }

            //console.log('Parent', JSON.stringify(this.permanentAddress))
            //console.log('Wired Data ##303', JSON.stringify(this.wiredData))
            // this.wrapObj = this.wiredData;
            //console.log('Wrap Data!! ', JSON.stringify(this.wrapObj));
            if (this.wrapObj) {
                this.getRelationShipDetailsData();
            }
            if (this.wrapObj && this.addressOptions.length > 0) {
                this.handleAddressOptions(this.wrapObj);
            }

            if (this.wrapObj.Customer_Profile_Selection_Id__c) {
                this.selectedRecordId = this.wrapObj.Customer_Profile_Selection_Id__c;
            }

        }
        if (result.error) {
            console.error(result.error);
        }

    }



    //generate picklist from values 
    generatePicklist(data) {
        return data.values.map(item => ({ "label": item.label, "value": item.value }))
    }


    @wire(getObjectInfo, { objectApiName: APPLICANT_ADD_OBJECT })
    appAddObjectInfo

    @wire(getPicklistValuesByRecordType, {
        objectApiName: APPLICANT_ADD_OBJECT,
        recordTypeId: '$appAddObjectInfo.data.defaultRecordTypeId',
    })
    addressPicklistHandler({ data, error }) {
        if (data) {
            //console.log('Line no ##423 ', data)
            this.addressOptions = [...this.generatePicklist(data.picklistFieldValues.AddrTyp__c)]
            if (this.wrapObj && this.addressOptions.length > 0 && this.isRendered === false) {
                this.handleAddressOptions(this.wrapObj);
                this.isRendered = true;
            }
        }
        if (error) {
            console.error(error)
        }
    }

    @wire(getObjectInfo, { objectApiName: APPLICANT_OBJECT })
    objectInfo

    @wire(getPicklistValuesByRecordType, {
        objectApiName: APPLICANT_OBJECT,
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    })
    picklistHandler({ data, error }) {
        if (data) {
            //console.log(data)
            this.applicantTypeOptions = [...this.generatePicklist(data.picklistFieldValues.Type_of_Borrower__c)]
            this.categoryOptions = [...this.generatePicklist(data.picklistFieldValues.Category__c)]
            this.constitutionOptions = [...this.generatePicklist(data.picklistFieldValues.Constitution__c)]
            this.titleOptions = [...this.generatePicklist(data.picklistFieldValues.Title__c)]
            this.genderOptions = [...this.generatePicklist(data.picklistFieldValues.Gender__c)]
            this.maritalStatusOptions = [...this.generatePicklist(data.picklistFieldValues.MariStatus__c)]
            this.nationalityOptions = [...this.generatePicklist(data.picklistFieldValues.Nationality__c)]
            this.religionStatusOptions = [...this.generatePicklist(data.picklistFieldValues.Religion__c)]
            this.educationalOptions = [...this.generatePicklist(data.picklistFieldValues.EduQual__c)]
            this.professionalOptions = [...this.generatePicklist(data.picklistFieldValues.ProfQual__c)]
            this.medicalCouncilOptions = [...this.generatePicklist(data.picklistFieldValues.MediCouncl__c)]
            this.partnershipOptions = [...this.generatePicklist(data.picklistFieldValues.Whether_partnership_is_registered__c)]
            this.customerProfilCatOptions = [...this.generatePicklist(data.picklistFieldValues.Customer_Profile_Categorisation__c)]

            //logic for customer profile picklist 
            let customerProfileAllOptions = [...this.generatePicklist(data.picklistFieldValues.CustProfile__c)];
            let tempArrayCustProfile = [];

            for (let i = 0; i < customerProfileAllOptions.length; i++) {

                if (customerProfileVisibleOptions.indexOf(customerProfileAllOptions[i].label) > -1) {
                    tempArrayCustProfile.push(customerProfileAllOptions[i]);
                }

            }
            var customerProfileOptionsApp = [...tempArrayCustProfile];

            if (this.applicantType === 'APPLICANT') {
                let customerProfileAppOptions = customerProfileOptionsApp.filter(item => (item.label != 'HOUSEWIFE') && (item.label != 'OTHERS'));
                this.customerProfileOptions = customerProfileAppOptions;
            } else {
                this.customerProfileOptions = [...tempArrayCustProfile];
            }

        }
        if (error) {
            console.error(error)
        }
    }

    housewife_indi_Options = ['Residence Address', 'Permanent Address']

    sal_indi_Options = ['Residence Address', 'Permanent Address', 'Other Address', 'Office Address']
    self_Emp_P_NP_indi_Options = ['Residence Address', 'Principal place for business', 'Residence Cum office', 'Permanent Address', 'Other Address']
    self_Emp_P_NP_nonIndi_Options = ['Principal place for business', 'Registered place for business', 'Other Address']
    self_Emp_P_NP_nonIndi_R_Options = ['Principal place for business', 'Registered place for business', 'Other Address']


    handleAddressOptions(resultObject) {

        this.options = []
        let tempAddressArray = [];
        for (let i = 0; i < this.addressOptions.length; i++) {
            //console.log('resultObject::::::::::485', resultObject);
            if (resultObject && resultObject.Type_of_Borrower__c === 'Financial' && resultObject.CustProfile__c === 'SALARIED' && resultObject.Constitution__c === 'INDIVIDUAL') {
                //console.log('Inside if block ##315:::::>>', this.addressOptions[i].label)
                if (this.sal_indi_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);
                    //console.log('Inside if block ##390:::::', tempAddressArray)
                    this.isResReq = true;
                    this.isOffice = true
                    this.isPerReq = true; //LAK-1872
                    this.isOtherAddress = true; //LAK-1872
                }
            }
            if (resultObject && resultObject.Type_of_Borrower__c === 'Financial' && (resultObject.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || resultObject.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') && resultObject.Constitution__c === 'INDIVIDUAL') {
                //console.log('Inside if block ##321')
                if (this.self_Emp_P_NP_indi_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);
                    //console.log('Inside if block ##399::::::::>>', tempAddressArray)
                    if (this.isEmptyObject(this.resiCusOfficeAddress)) {
                        this.isResReq = true
                        this.isPrinciBussiAddress = true
                        this.isPerReq = true; //LAK-1872
                        this.isOtherAddress = true; //LAK-1872
                        this.isResiCusOfficeAddress = true; //LAK-1872
                    }
                }
            }
            if (resultObject && (resultObject.Type_of_Borrower__c === 'Financial' || resultObject.Type_of_Borrower__c === 'Non Financial') && (resultObject.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || resultObject.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') &&
                (resultObject.Constitution__c === 'PRIVATE LIMITED COMPANY' || resultObject.Constitution__c === 'TRUST' || resultObject.Constitution__c === 'PUBLIC LIMITED COMPANY' ||
                    resultObject.Constitution__c === 'PARTNERSHIP' || resultObject.Constitution__c === 'LIMITED LIABILITY PARTNERSHIP' || resultObject.Constitution__c === 'ASSOCIATION OF PERSONS')) {
                //console.log('Inside if block ##327')
                if (this.self_Emp_P_NP_nonIndi_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);
                    this.isPrinciBussiAddress = true;
                    this.isRegiBussiAddress = true;
                    this.isOtherAddress = true; //LAK-1872

                }
            }
            if (resultObject && (resultObject.Type_of_Borrower__c === 'Financial' || resultObject.Type_of_Borrower__c === 'Non Financial') && (resultObject.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || resultObject.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') &&
                (resultObject.Constitution__c === 'HUF' || resultObject.Constitution__c === 'SOCIETY' || resultObject.Constitution__c === 'PROPRIETORSHIP')) {
                //console.log('Inside if block ##321')
                if (this.self_Emp_P_NP_nonIndi_R_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);
                    this.isPrinciBussiAddress = true
                    this.isRegiBussiAddress = true; //LAK-1872
                    this.isOtherAddress = true; //LAK-1872
                }
            }

            if (resultObject && resultObject.Type_of_Borrower__c === 'Non Financial' && resultObject.CustProfile__c === 'SALARIED' && resultObject.Constitution__c === 'INDIVIDUAL') {
                //console.log('Inside if block ##315')
                if (this.sal_indi_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);
                    this.isResReq = true
                    this.isOffice = true; //LAK-1872
                    this.isOtherAddress = true; //LAK-1872
                    this.isPerReq = true; //LAK-1872

                }
            }
            //Address Detail for HouseWise And Others code Started

            if ((resultObject.CustProfile__c === "HOUSEWIFE" || resultObject.CustProfile__c === "OTHERS") && resultObject.Constitution__c === 'INDIVIDUAL') {
                //console.log('Inside if block ##472')
                if (this.housewife_indi_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);
                    this.isResReq = true
                    // this.isOffice = true; //LAK-1872
                    // this.isOtherAddress = true; //LAK-1872
                    this.isPerReq = true; //LAK-1872

                }
            }

            //Address Detail for HouseWise And Others Code Ended
            if (resultObject && resultObject.Type_of_Borrower__c === 'Non Financial' && (resultObject.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || resultObject.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') && resultObject.Constitution__c === 'INDIVIDUAL') {
                //console.log('Inside if block ##321')
                if (this.self_Emp_P_NP_indi_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);
                    if (this.isEmptyObject(this.resiCusOfficeAddress)) {
                        this.isResReq = true
                        this.isPerReq = true; //LAK-1872
                        this.isPrinciBussiAddress = true; //LAK-1872
                        this.isOtherAddress = true; //LAK-1872
                        this.isResiCusOfficeAddress = true; //LAK-1872

                    }

                }
            }

        }
        this.showSpinner = false;
        this.options = [...tempAddressArray]
        //console.log('Inside if block ##446:::::::', JSON.stringify(tempAddressArray));
    }

    connectedCallback() {
        this.handleRecordIdChange(this.recordId);
        // this.hasEditAccess = false;
        //console.log('this.hasEditAccess disabele IN APPLICANT DETAILS COMP> ::::::::', this.disableMode);
        if (this.hasEditAccess === false) {
            this.disableMode = true;
            this.relationShipDisabled = true;
            //this.disbledConstitution = true;
            // this.mobileNumberDisabled = true;
            //console.log('this.hasEditAccess disabele IN APPLICANT DETAILS COMP>::::::::', this.disableMode);
        }
        else {
            this.disableMode = false;
        }
        this.showSpinner = false;
        this.scribeToMessageChannel();
        //this.getRelationShipDetailsData();
        this.activeSection = ["A", "B"];
        //console.log('data -', JSON.stringify(this.wrapObj))
        if (this.wrapObj.DOB__c) {
            this.wrapObj.Age__c = this.dob()
            //console.log('date of birth',this.wrapObj.DOB__c,this.dob())
        }
        if (this.wrapObj.DOI__c) {
            this.wrapObj.InceptionYears__c = this.doi()
            //console.log('date of inception',this.wrapObj.DOI__c,this.doi())
        }
        //console.log('this.applicantType', this.stepperName);
        if (this.stepperName !== null && this.stepperName === 'CoApplicantDetails') {
            this.applicantType = 'CO-APPLICANT';
            //console.log('this.applicantType', this.stepperName);
        }
        this.checkForMultipleSelection();
        //this.checkMailingAddressData();
    }

    @track isRendered = false;

    renderedCallback() {
        //console.log('rendered callback called', this.isRendered);
        refreshApex(this.wiredData);
        refreshApex(this.wiredAppKycData);
        refreshApex(this.wiredAppAddressData);

        if (this.wrapObj && this.addressOptions.length > 0 && this.isRendered === false) {
            //console.log('this.wrapObj::::', this.wrapObj, 'this.addressOptions.length:::::', this.addressOptions);
            this.handleAddressOptions(this.wrapObj);
            //this.getRelationShipDetailsData();
            this.isRendered = true;
            //console.log('rendered callback inside ife::::', this.isRendered);
        }
        this.checkForMultipleSelection();
        //this.checkMailingAddressData();
    }

    handleAddressSelection(event) {
        //console.log('handleAddressSelection::::::::>>');

        this.addressValue = event.target.value
        //console.log('handleAddressSelection addressValue ::::::::>>', this.addressValue);
        const selectedValue = event.detail.value;

        if (selectedValue === 'Residence Address') {
            // Open the Residence Address accordion section
            this.activeSectionName = 'Res_Add';
        } else if (selectedValue === 'Permanent Address') {
            this.activeSectionName = 'Per_Add';
        } else if (selectedValue === 'Residence Cum office') {
            this.activeSectionName = 'Res_Cum_Off_Add';
        } else if (selectedValue === 'Registered place for business') {
            this.activeSectionName = 'Reg_Bus_Add';
        } else if (selectedValue === 'Principal place for business') {
            this.activeSectionName = 'Pri_Place_Add';
        } else if (selectedValue === 'Other Address') {
            this.activeSectionName = 'Oth_Add';
        } else if (selectedValue === 'Office Address') {
            this.activeSectionName = 'Ofc_Add';
        }
        this.open_res_Res();
        this.open_per_Add();
        this.open_Residence_Cum_office();
        this.open_Registered_place_for_business();
        this.open_Principal_place_for_business();
        this.open_Other_Address();
        this.open_Office_Address();
    }

    is_Open_Res_add = false
    is_Open_Per_add = false
    is_Open_Res_Cum_add = false
    is_Open_Reg_Bus_add = false
    is_Open_Princi_Bus_add = false
    is_Open_Other_add = false
    is_Open_Office_add = false

    open_res_Res() {
        if (this.addressValue === 'Residence Address') {
            this.is_Open_Res_add = true
        }
    }
    open_per_Add() {
        if (this.addressValue === 'Permanent Address') {
            this.is_Open_Per_add = true
        }
    }
    open_Residence_Cum_office() {
        if (this.addressValue === 'Residence Cum office') {
            this.is_Open_Res_Cum_add = true
        }
    }
    open_Registered_place_for_business() {
        if (this.addressValue === 'Registered place for business') {
            this.is_Open_Reg_Bus_add = true
        }
    }
    open_Principal_place_for_business() {
        if (this.addressValue === 'Principal place for business') {
            this.is_Open_Princi_Bus_add = true
        }
    }
    open_Other_Address() {
        if (this.addressValue === 'Other Address') {
            this.is_Open_Other_add = true
        }
    }
    open_Office_Address() {
        if (this.addressValue === 'Office Address') {
            this.is_Open_Office_add = true
        }
    }


    inputChangeHandler(event) {
        this.wrapObj[event.target.dataset.fieldname] = event.target.value

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
        if (event.target.dataset.fieldname === 'Gender__c') {
            this.gender = event.target.value;
        }
        if (event.target.dataset.fieldname === 'Father_Name__c') {
            this.fathername = event.target.value;
        }

        if (event.target.dataset.fieldname === 'CustProfile__c') {
            //LAK-1872 Start
            this.is_Open_Res_add = false;
            this.is_Open_Per_add = false;
            this.is_Open_Res_Cum_add = false;
            this.is_Open_Reg_Bus_add = false;
            this.is_Open_Princi_Bus_add = false;
            this.is_Open_Other_add = false;
            this.is_Open_Office_add = false;
            //LAK-1872 End
            if (this.wrapObj.CustProfile__c) {
                if (this.wrapObj.CustProfile__c === 'SALARIED' || this.wrapObj.CustProfile__c === "HOUSEWIFE" || this.wrapObj.CustProfile__c === "OTHERS") {
                    this.wrapObj.Constitution__c = 'INDIVIDUAL';
                }
                this.handleAddressOptions(this.wrapObj);

            }
        }

        if (event.target.dataset.fieldname === 'Relationship__c') {
        }

        if (event.target.dataset.fieldname === 'Constitution__c') {
            this.wrapObj.MariStatus__c = ''   //for uat and qa fix
            //LAK-1872 Start
            this.is_Open_Res_add = false;
            this.is_Open_Per_add = false;
            this.is_Open_Res_Cum_add = false;
            this.is_Open_Reg_Bus_add = false;
            this.is_Open_Princi_Bus_add = false;
            this.is_Open_Other_add = false;
            this.is_Open_Office_add = false;
            //LAK-1872 End
            if (this.wrapObj.Constitution__c) {
                if (this.wrapObj.Constitution__c === 'PARTNERSHIP' || this.wrapObj.Constitution__c === 'LIMITED LIABILITY PARTNERSHIP') {
                    //console.log('Inside Constitution Line 386**')
                } else {
                    this.wrapObj.Whether_partnership_is_registered__c = ''
                }
                this.handleAddressOptions(this.wrapObj);
                this.getRelationShipDetailsData();
            }
        }

        if (event.target.dataset.fieldname === 'DOI__c') {
            if (this.wrapObj.DOI__c) {
                if (this.validateDOI(this.wrapObj.DOI__c)) {
                    this.wrapObj.InceptionYears__c = this.getNumber(this.wrapObj.DOI__c);
                }
            }
        }
        if (event.target.dataset.fieldname === 'Gender__c') {
            if (this.wrapObj.Gender__c) {
                this.validateGender();
            }
        }
        if (event.target.dataset.fieldname === 'ProfQual__c') {
            if (this.wrapObj.ProfQual__c) {
                this.validateRegistrationNumberPattern();
                this.validateYearOfRegistrationPattern();
                this.validateMembershipNumberPattern();
            }
        }

        if (event.target.dataset.fieldname === 'EmailId__c') {
            let email = this.template.querySelector('[data-id="txtEmailAddress"]');
            if (this.wrapObj.EmailId__c) {
                //const emailRegex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/;
                const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
                let emailVal = email.value;
                if (emailVal.match(emailRegex)) {
                    email.setCustomValidity("");

                } else {
                    email.setCustomValidity("Please enter valid email");
                    if (emailVal.length === 0) {
                        email.setCustomValidity("");
                    }
                }
                email.reportValidity();
            } else {
                email.setCustomValidity("Complete this field.");
            }
        }
    }

    getNumber(value) {
        var millis = Date.now() - new Date(value).getTime()
        var age = new Date(millis)
        return Math.abs(age.getUTCFullYear() - 1970)
    }

    handleChildResidenceData(event) {
        this.residenceAddress = { ...this.residenceAddress, ...event.detail }
        this.residenceAddresscheckbox = event.detail.MailAddr__c;
        this.checkForMultipleSelection();
        if (this.selectedCount > 1 && this.residenceAddresscheckbox) {
            this.showerror = true;
        } else {
            this.showerror = false;
        }
        //console.log('this.showerrorresidenceAddresscheckbox'+ this.showerror);

        //console.log('selected and passed to parent', JSON.stringify(this.residenceAddress))
    }

    handleChildPermanentData(event) {
        this.permanentAddress = { ...this.permanentAddress, ...event.detail }
        this.permanentAddresscheckbox = event.detail.MailAddr__c;
        this.checkForMultipleSelection();
        if (this.selectedCount > 1 && this.permanentAddresscheckbox) {
            this.showerror = true;
        } else {
            this.showerror = false;
        }
        //console.log('this.showerrorpermanentAddresscheckbox'+ this.showerror);

        //console.log('selected and passed to parent', JSON.stringify(this.permanentAddress))
    }

    handleChildResiCumOfficeData(event) {
        this.resiCusOfficeAddress = { ...this.resiCusOfficeAddress, ...event.detail }
        //console.log('selected and passed to parent', JSON.stringify(this.resiCusOfficeAddress))
    }

    handleChildRegiBussiData(event) {
        this.regiBussiAddress = { ...this.regiBussiAddress, ...event.detail }
        //console.log('selected and passed to parent', JSON.stringify(this.regiBussiAddress))
    }

    handleChildPrinciBussiData(event) {
        this.princiBussiAddress = { ...this.princiBussiAddress, ...event.detail }
        //console.log('selected and passed to parent', JSON.stringify(this.princiBussiAddress))

    }

    handleChildOtherData(event) {
        this.otherAddress = { ...this.otherAddress, ...event.detail }
        this.otherAddresscheckbox = event.detail.MailAddr__c;
        this.checkForMultipleSelection();
        if (this.selectedCount > 1 && this.otherAddresscheckbox) {
            this.showerror = true;
        } else {
            this.showerror = false;
        }
        //console.log('this.showerrorotherAddresscheckbox'+ this.showerror);

        //console.log('selected and passed to parent', JSON.stringify(this.otherAddress))
    }

    handleChildOfficeData(event) {
        this.officeAddress = { ...this.officeAddress, ...event.detail }
        //console.log('this.officeAddress'+ JSON.stringify(this.officeAddress));
        this.officeAddresscheckbox = event.detail.MailAddr__c;
        //console.log('this.officeAddresscheckbox'+ this.officeAddresscheckbox);
        this.checkForMultipleSelection();
        if (this.selectedCount > 1 && this.officeAddresscheckbox) {
            this.showerror = true;
        } else {
            this.showerror = false;
        }
        //console.log('this.showerrorofficeAddress'+ this.showerror);
        //console.log('selected and passed to parent', JSON.stringify(this.officeAddress))
    }

    checkForMultipleSelection() {
        //console.log('this.officeAddresscheckboxMultipleSelection'+ this.officeAddresscheckbox);
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

    handleCheckboxSelect(event) {
        this.isAddressSame = event.target.checked
        let perId = this.permanentAddress.Id
        let perAddType = this.permanentAddress.AddrTyp__c ? this.permanentAddress.AddrTyp__c : 'Permanent Address';
        if (this.isAddressSame) {
            if (this.isEmptyObject(this.residenceAddress)) {
                event.target.checked = false;
                this.showToastMessage('Error', this.label.ApplicantDetails_ResidenceAdd_ErrorMessage, 'error', 'dismissable');
            } else {
                let copy_residenceAddress = { ...this.residenceAddress };
                delete copy_residenceAddress.MailAddr__c;
                this.permanentAddress = copy_residenceAddress
            }

        } else {
            this.permanentAddress = {}
        }
        this.permanentAddress.Id = perId
        this.permanentAddress.AddrTyp__c = perAddType
    }

    isRegiAddressSame = false

    handleCheckboxSelectForRegiAddress(event) {
        //console.log('line no ### 811');
        this.isRegiAddressSame = event.target.checked
        let regId = this.regiBussiAddress.Id
        let regAddType = this.regiBussiAddress.AddrTyp__c ? this.regiBussiAddress.AddrTyp__c : 'Registered place for business';
        if (this.isRegiAddressSame) {
            if (this.isEmptyObject(this.princiBussiAddress)) {
                //this.prncplAddrsNotPrsnt  = false;         
                event.target.checked = false;
                this.showToastMessage('Error', this.label.ApplicantDetails_PrincipalBusineesAdd_ErrorMessage, 'error', 'dismissable');
            } else {
                let copy_princiBussiAddress = { ...this.princiBussiAddress };
                delete copy_princiBussiAddress.MailAddr__c;
                this.regiBussiAddress = copy_princiBussiAddress
            }
        } else {
            this.regiBussiAddress = {}
        }
        this.regiBussiAddress.Id = regId
        this.regiBussiAddress.AddrTyp__c = regAddType
    }

    validateRegistrationNumberPattern() {
        if (this.wrapObj.ProfQual__c && this.wrapObj.ProfQual__c.includes('ART')) {
            this.registrationNumberPattern = new RegExp("^[A-Z]{2}/[0-9]{4}/[0-9]{5}$")
        } else if (this.wrapObj.ProfQual__c && this.wrapObj.ProfQual__c.includes("DOC")) {
            this.registrationNumberPattern = new RegExp("^[a-zA-Z0-9]{1,255}$")
        } else {
            this.registrationNumberPattern = new RegExp("^[a-zA-Z0-9]+$")
        }
    }

    validateYearOfRegistrationPattern() {
        if (this.wrapObj.ProfQual__c && this.wrapObj.ProfQual__c.includes("DOC")) {
            this.yearOfRegistrationPattern = "^(19|20)\d{2}$"
        } else {
            this.yearOfRegistrationPattern = "^[a-zA-Z0-9]+$"
        }
    }

    validateMembershipNumberPattern() {
        if (this.wrapObj.ProfQual__c && this.wrapObj.ProfQual__c.includes("CA")) {
            this.membershipNumberPattern = new RegExp("^[0-9]{6}$")
        } else if (this.wrapObj.ProfQual__c && this.wrapObj.ProfQual__c.includes("ICWAI")) {
            this.membershipNumberPattern = new RegExp("^\d{2,5}$")
        } else {
            this.membershipNumberPattern = new RegExp("^[a-zA-Z0-9]+$")
        }
    }

    validateDOI(value) {
        let validate = true
        if (new Date().getTime() - new Date(value).getTime() >= 1) {
            this.doiErrMessage = ''
            validate = true
        } else {
            this.doiErrMessage = "Please enter past date"
            validate = false
        }
        //console.log('DOI ERR MSG',this.doiErrMessage)
        return validate
    }

    checkValidityLookup() {
        let isInputCorrect = true;
        let allChilds = this.template.querySelectorAll("c-capture-applicant-address-details");
        //console.log("custom lookup allChilds>>>", allChilds);
        allChilds.forEach((child) => {
            if (!child.validateForm()) {
                child.validateForm();
                isInputCorrect = false;
            }
        });
        return isInputCorrect
    }

    checkCustomerProfileValidityLookup() {
        let isInputCorrect = true;
        let allChilds = this.template.querySelectorAll("c-custom-lookup");
        allChilds.forEach((child) => {
            if (!child.checkValidityLookup()) {
                child.checkValidityLookup();
                isInputCorrect = false;
            }
        });
        return isInputCorrect;
    }

    validateDOB(dob) {

        const date = new Date(dob);
        // Check if the parsed date is valid
        if (isNaN(date.getTime())) {
            return false; // Invalid date format
        }

        // Get the current date
        const currentDate = new Date();
        const minDate = new Date();
        minDate.setFullYear(minDate.getFullYear() - 18);

        // Compare the parsed date with the minimum date and the current date
        if (date > currentDate || date > minDate) {
            return false; // Date of birth is in the future or less than 18 years old
        }

        // All validations passed, so the date of birth is valid
        return true;
    }

    validateGender() {
        let validate = true
        if (this.wrapObj.Title__c === 'Mr.' && this.wrapObj.Gender__c === 'M') {
            validate = true
            this.is_genderError = false
        } else if ((this.wrapObj.Title__c === 'Mrs.' || this.wrapObj.Title__c === 'Ms.') && this.wrapObj.Gender__c === 'F') {
            validate = true
            this.is_genderError = false
        } else if (this.wrapObj.Title__c === 'Mx.' && this.wrapObj.Gender__c === 'T') {
            validate = true
            this.is_genderError = false
        } else {
            this.is_genderError = true
            this.genderErrorMessage = 'Please select correct gender for title selection'
            validate = false
        }
        return validate
    }

    isOffice = false
    isResiCusOfficeAddress = false
    isRegiBussiAddress = false
    isPrinciBussiAddress = false
    isOtherAddress = false

    @track multipleMailingAddress = false;
    @track noMailingAddress = false;
    validateForm() {
        let isValid = true
        if (this.wrapObj.Type_of_Borrower__c === 'Financial' && this.wrapObj.CustProfile__c === 'SALARIED' && this.wrapObj.Constitution__c === 'INDIVIDUAL') {
            if (this.isEmptyObject(this.residenceAddress) && this.isEmptyObject(this.officeAddress)) {
                //console.log('inside residential and office address if 1016::::');
                this.isResReq = true
                this.isOffice = true
                //Resisdence address not empty
                this.showToastMessage('Error', this.label.ApplicantDetails_ResidenceBusineesAdd_ErrorMessage, 'error', 'dismissable');
                isValid = false;
            } else if (this.isEmptyObject(this.officeAddress)) {
                //console.log('inside residential 1023::::');

                this.isOffice = true
                //office address not empty
                this.showToastMessage('Error', this.label.ApplicantDetails_OfficeAdd_ErrorMessage, 'error', 'dismissable');
                isValid = false;
            } else if (this.isEmptyObject(this.residenceAddress)) {
                //console.log('inside residential address if 1030::::');

                this.isResReq = true
                //office address not empty
                this.showToastMessage('Error', this.label.ApplicantDetails_ResidenceAddMandatory_ErrorMessage, 'error', 'dismissable');
                isValid = false;
            } else {
                this.isResReq = true
                this.isOffice = true
                isValid = true;
            }
        }
        if (this.wrapObj.Type_of_Borrower__c === 'Financial' && (this.wrapObj.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || this.wrapObj.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') && this.wrapObj.Constitution__c === 'INDIVIDUAL') {
            if (this.isEmptyObject(this.resiCusOfficeAddress)) {
                if (this.isEmptyObject(this.residenceAddress)) {
                    this.isResReq = true
                    //Resisdence address not empty
                    this.showToastMessage('Error', this.label.ApplicantDetails_PrincipalBusineesAddReq_ErrorMessage, 'error', 'dismissable');
                    isValid = false;
                } else if (this.isEmptyObject(this.princiBussiAddress)) {
                    this.isPrinciBussiAddress = true
                    this.showToastMessage('Error', this.label.ApplicantDetails_BusineesPlaceReq_ErrorMessage, 'error', 'dismissable');
                    isValid = false;
                } else {
                    this.isResReq = true
                    this.isPrinciBussiAddress = true
                    isValid = true;
                }
            }
        }
        if ((this.wrapObj.Type_of_Borrower__c === 'Financial' || this.wrapObj.Type_of_Borrower__c === 'Non Financial') && (this.wrapObj.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || this.wrapObj.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') &&
            (this.wrapObj.Constitution__c === 'HUF' || this.wrapObj.Constitution__c === 'SOCIETY' || this.wrapObj.Constitution__c === 'PROPRIETORSHIP')) {
            if (this.isEmptyObject(this.princiBussiAddress)) {
                this.isPrinciBussiAddress = true
                //Resisdence address not empty
                this.showToastMessage('Error', this.label.ApplicantDetails_BusineesPlaceReq_ErrorMessage, 'error', 'dismissable');
                isValid = false;
            } else {
                this.isPrinciBussiAddress = true
                isValid = true;
            }
        }
        if (this.wrapObj.Type_of_Borrower__c === 'Non Financial' && this.wrapObj.CustProfile__c === 'SALARIED' && this.wrapObj.Constitution__c === 'INDIVIDUAL') {
            if (this.isEmptyObject(this.residenceAddress)) {
                this.isResReq = true
                //Resisdence address not empty
                this.showToastMessage('Error', this.label.ApplicantDetails_ResidenceAddMandatory_ErrorMessage, 'error', 'dismissable');
                isValid = false;
            } else {
                this.isResReq = true
                isValid = true;
            }
        }
        if (this.wrapObj.Type_of_Borrower__c === 'Non Financial' && (this.wrapObj.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || this.wrapObj.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') && this.wrapObj.Constitution__c === 'INDIVIDUAL') {
            if (this.isEmptyObject(this.resiCusOfficeAddress)) {
                if (this.isEmptyObject(this.residenceAddress)) {
                    this.isResReq = true
                    //Resisdence address not empty
                    this.showToastMessage('Error', this.label.ApplicantDetails_ResidenceAddMandatory_ErrorMessage, 'error', 'dismissable');
                    isValid = false;
                }
            } else {
                this.isResReq = true
                isValid = true;
            }
        }
        if ((this.wrapObj.Type_of_Borrower__c === 'Financial' || this.wrapObj.Type_of_Borrower__c === 'Non Financial') && (this.wrapObj.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || this.wrapObj.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') &&
            (this.wrapObj.Constitution__c === 'PRIVATE LIMITED COMPANY' || this.wrapObj.Constitution__c === 'TRUST' || this.wrapObj.Constitution__c === 'PUBLIC LIMITED COMPANY' ||
                this.wrapObj.Constitution__c === 'PARTNERSHIP' || this.wrapObj.Constitution__c === 'LIMITED LIABILITY PARTNERSHIP' || this.wrapObj.Constitution__c === 'ASSOCIATION OF PERSONS')) {
            if (this.isEmptyObject(this.princiBussiAddress)) {
                this.isPrinciBussiAddress = true
                this.showToastMessage('Error', this.label.ApplicantDetails_PrincipalRegisteredBusineesAddReq_ErrorMessage, 'error', 'dismissable');
                isValid = false;
            } else if (this.isEmptyObject(this.regiBussiAddress)) {
                this.isRegiBussiAddress = true
                this.showToastMessage('Error', this.label.ApplicantDetails_RegisteredBusineesPlaceReq_ErrorMessage, 'error', 'dismissable');
                isValid = false;
            }

            else {
                this.isPrinciBussiAddress = true
                this.isRegiBussiAddress = true
                isValid = true;
            }

        }

        this.multipleMailingAddress = false;
        this.noMailingAddress = false;
        if (this.mailingAddCounter > 1) {
            this.multipleMailingAddress = true;

        }
        if (this.mailingAddCounter < 1) {
            this.noMailingAddress = true;

        }
        if (this.wrapObj.Constitution__c != 'INDIVIDUAL' && this.wrapObj.DOI__c) {
            if (!this.validateDOI(this.wrapObj.DOI__c)) {
                isValid = false;
            }
        }
        if (this.wrapObj.Constitution__c === 'INDIVIDUAL' && this.wrapObj.DOB__c) {
            if (!this.validateDOB(this.wrapObj.DOB__c)) {
                isValid = false;
            }
        }
        if (!this.checkValidityLookup()) {
            isValid = false;
        }
        if (!this.checkCustomerProfileValidityLookup()) {
            isValid = false;
        }
        if (this.wrapObj.Gender__c && !this.validateGender()) {
            isValid = false;
        }

        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if (element.reportValidity()) {
            } else {
                isValid = false;
            }
        });

        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
                //console.log('element passed lightning input');
            } else {
                isValid = false;
            }
        });
        return isValid;
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

    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );

    }

    handleSaveThroughLms(values) {
        //console.log('values to save through Lms ', JSON.stringify(values));
        this.handleSave(values.validateBeforeSave);

    }

    formulateChildAddressRecords() {
        var adddresRecords = [];
        if (!this.isEmptyObject(this.residenceAddress)) {
            this.residenceAddress.sobjectType = 'ApplAddr__c';
            this.residenceAddress.AddrTyp__c = this.residenceAddress.AddrTyp__c ? this.residenceAddress.AddrTyp__c : 'Residence Address';
            adddresRecords.push(this.residenceAddress);
        }
        if (!this.isEmptyObject(this.permanentAddress)) {
            this.permanentAddress.sobjectType = 'ApplAddr__c';
            this.permanentAddress.AddrTyp__c = this.permanentAddress.AddrTyp__c ? this.permanentAddress.AddrTyp__c : 'Permanent Address';
            adddresRecords.push(this.permanentAddress);
        }
        if (!this.isEmptyObject(this.resiCusOfficeAddress)) {
            this.resiCusOfficeAddress.sobjectType = 'ApplAddr__c';
            this.resiCusOfficeAddress.AddrTyp__c = this.resiCusOfficeAddress.AddrTyp__c ? this.resiCusOfficeAddress.AddrTyp__c : 'Residence Cum office';
            adddresRecords.push(this.resiCusOfficeAddress);
        }
        if (!this.isEmptyObject(this.regiBussiAddress)) {
            this.regiBussiAddress.sobjectType = 'ApplAddr__c';
            this.regiBussiAddress.AddrTyp__c = this.regiBussiAddress.AddrTyp__c ? this.regiBussiAddress.AddrTyp__c : 'Registered place for business';
            adddresRecords.push(this.regiBussiAddress);
        }
        if (!this.isEmptyObject(this.princiBussiAddress)) {
            this.princiBussiAddress.sobjectType = 'ApplAddr__c';
            this.princiBussiAddress.AddrTyp__c = this.princiBussiAddress.AddrTyp__c ? this.princiBussiAddress.AddrTyp__c : 'Principal place for business';
            adddresRecords.push(this.princiBussiAddress);
        }
        if (!this.isEmptyObject(this.otherAddress)) {
            this.otherAddress.sobjectType = 'ApplAddr__c';
            this.otherAddress.AddrTyp__c = this.otherAddress.AddrTyp__c ? this.otherAddress.AddrTyp__c : 'Other Address';
            adddresRecords.push(this.otherAddress);
        }
        if (!this.isEmptyObject(this.officeAddress)) {
            this.officeAddress.sobjectType = 'ApplAddr__c';
            this.officeAddress.AddrTyp__c = this.officeAddress.AddrTyp__c ? this.officeAddress.AddrTyp__c : 'Office Address';
            adddresRecords.push(this.officeAddress);
        }

        var counter = 0;

        if (this.allAddressData && this.allAddressData.length > 0) {
            this.allAddressData.forEach(addressRecord => {
                const matchingRecord = adddresRecords.find(record => record.Id === addressRecord.Id);
                if (matchingRecord && matchingRecord.MailAddr__c) {
                    counter++;
                } else if (!matchingRecord && addressRecord.MailAddr__c) {
                    counter++;
                }
            });
        } else {
            if (adddresRecords && adddresRecords.length > 0) {
                for (var i = 0; i < adddresRecords.length; i++) {
                    if (adddresRecords[i].MailAddr__c) {
                        counter++;
                    }
                }
            }
        }

        if (adddresRecords && adddresRecords.length > 0) {
            for (var i = 0; i < adddresRecords.length; i++) {
                if (!adddresRecords[i].Id && adddresRecords[i].MailAddr__c) {
                    counter++;
                }
            }
        }
        return counter;
    }


    handleSave(validate) {
        if (validate) {
            let isInputCorrect = this.validateForm();

            if (isInputCorrect === true) {
                // if (this.multipleMailingAddress === true) {
                //     this.showToastMessage('Error', this.label.ApplicantAddressMailing_ErrorMessage, 'error', 'dismissable')
                // } else if (this.noMailingAddress === true) {
                //     this.showToastMessage('Error', this.label.NoApplicantAddressMailing_ErrorMessage, 'error', 'dismissable')
                // }

                var totalSelectedMailingAddress = this.formulateChildAddressRecords();

                if (totalSelectedMailingAddress > 1) {
                    this.showToastMessage('Error', this.label.ApplicantDetails_multMailAdd_ErrorMessage, 'error', 'dismissable')
                } else if (totalSelectedMailingAddress === 0) {
                    this.showToastMessage('Error', this.label.NoApplicantAddressMailing_ErrorMessage, 'error', 'dismissable')
                } else if (this.consentProvided === false) {
                    this.showToastMessage('Error', this.label.ApplicantDetails_Consent_ErrorMessage, 'error', 'dismissable');
                } else {
                    this.handleUpsert();
                    //console.log('this.applicantType--------->1253' + this.applicantType);
                    if (this.applicantType) {
                        if (this.applicantType === 'APPLICANT') {
                            this.showToastMessage('Success', this.label.APPLICANT_SUCCESS_Label, 'success', 'dismissable')
                        } else if (this.applicantType === 'CO-APPLICANT' || this.applicantType === 'GUARANTOR') {
                            this.showToastMessage('Success', this.label.ApplicantDetails_CoApp_SuccesMessage, 'success', 'dismissable')
                        } else {
                            this.showToastMessage('Success', this.label.APPLICANT_SUCCESS_Label, 'success', 'dismissable')
                        }
                    } else {
                        this.showToastMessage('Success', this.label.APPLICANT_SUCCESS_Label, 'success', 'dismissable')
                    }
                }


            } else {
                this.showToastMessage('Error', this.label.ALL_FIELDS_Label, 'error', 'dismissable');
            }

        } else {
            this.handleUpsert();
            //console.log('this.applicantType--------->1274' + this.applicantType);
            if (this.applicantType) {
                if (this.applicantType === 'APPLICANT') {
                    this.showToastMessage('Success', this.label.APPLICANT_SUCCESS_Label, 'success', 'dismissable')
                } else if (this.applicantType === 'CO-APPLICANT' || this.applicantType === 'GUARANTOR') {
                    this.showToastMessage('Success', this.label.ApplicantDetails_CoApp_SuccesMessage, 'success', 'dismissable')
                } else {
                    this.showToastMessage('Success', this.label.APPLICANT_SUCCESS_Label, 'success', 'dismissable')
                }
            } else {
                this.showToastMessage('Success', this.label.APPLICANT_SUCCESS_Label, 'success', 'dismissable')
            }
        }

    }

    //method used to check empty object 
    isEmptyObject(obj) {
        return Object.keys(obj).length === 0;
    }



    handleUpsert() {
        this.ChildRecords = [];
        if (!this.isEmptyObject(this.residenceAddress)) {
            this.residenceAddress.sobjectType = 'ApplAddr__c';
            // this.residenceAddress.Id = this.residenceAddress.Id ? this.residenceAddress.Id : null;
            this.residenceAddress.AddrTyp__c = this.residenceAddress.AddrTyp__c ? this.residenceAddress.AddrTyp__c : 'Residence Address';
            this.ChildRecords.push(this.residenceAddress);
        }
        if (!this.isEmptyObject(this.permanentAddress)) {
            this.permanentAddress.sobjectType = 'ApplAddr__c';
            // this.permanentAddress.Id = this.permanentAddress.Id ? this.permanentAddress.Id : null;
            this.permanentAddress.AddrTyp__c = this.permanentAddress.AddrTyp__c ? this.permanentAddress.AddrTyp__c : 'Permanent Address';
            this.ChildRecords.push(this.permanentAddress);
        }
        if (!this.isEmptyObject(this.resiCusOfficeAddress)) {
            this.resiCusOfficeAddress.sobjectType = 'ApplAddr__c';
            // this.resiCusOfficeAddress.Id = this.resiCusOfficeAddress.Id ? this.resiCusOfficeAddress.Id : null;
            this.resiCusOfficeAddress.AddrTyp__c = this.resiCusOfficeAddress.AddrTyp__c ? this.resiCusOfficeAddress.AddrTyp__c : 'Residence Cum office';
            this.ChildRecords.push(this.resiCusOfficeAddress);
        }
        if (!this.isEmptyObject(this.regiBussiAddress)) {
            this.regiBussiAddress.sobjectType = 'ApplAddr__c';
            // this.regiBussiAddress.Id = this.regiBussiAddress.Id ? this.regiBussiAddress.Id : null;
            this.regiBussiAddress.AddrTyp__c = this.regiBussiAddress.AddrTyp__c ? this.regiBussiAddress.AddrTyp__c : 'Registered place for business';
            this.ChildRecords.push(this.regiBussiAddress);
        }
        if (!this.isEmptyObject(this.princiBussiAddress)) {
            this.princiBussiAddress.sobjectType = 'ApplAddr__c';
            // this.princiBussiAddress.Id = this.princiBussiAddress.Id ? this.princiBussiAddress.Id : null;
            this.princiBussiAddress.AddrTyp__c = this.princiBussiAddress.AddrTyp__c ? this.princiBussiAddress.AddrTyp__c : 'Principal place for business';
            this.ChildRecords.push(this.princiBussiAddress);
        }
        if (!this.isEmptyObject(this.otherAddress)) {
            this.otherAddress.sobjectType = 'ApplAddr__c';
            // this.otherAddress.Id = this.otherAddress.Id ? this.otherAddress.Id : null;
            this.otherAddress.AddrTyp__c = this.otherAddress.AddrTyp__c ? this.otherAddress.AddrTyp__c : 'Other Address';
            this.ChildRecords.push(this.otherAddress);
        }
        if (!this.isEmptyObject(this.officeAddress)) {
            this.officeAddress.sobjectType = 'ApplAddr__c';
            // this.officeAddress.Id = this.officeAddress.Id ? this.officeAddress.Id : null;
            this.officeAddress.AddrTyp__c = this.officeAddress.AddrTyp__c ? this.officeAddress.AddrTyp__c : 'Office Address';
            this.ChildRecords.push(this.officeAddress);
        }
        this.wrapObj.sobjectType = 'Applicant__c';
        //console.log('childrecord aray -', this.ChildRecords)

        let upsertData = {
            parentRecord: this.wrapObj,
            ChildRecords: this.ChildRecords,
            ParentFieldNameToUpdate: 'Applicant__c'
        }
        //console.log('Childs -', JSON.stringify(this.ChildRecords))
        //console.log('upsert data -', JSON.stringify(upsertData))
        upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
            .then(result => {
                refreshApex(this.wiredData);
                refreshApex(this.wiredAppAddressData);
                //this.checkMailingAddressData();
            })
            .catch(error => {
                console.error(error)
            })
    }

    isResReq = false;
    isPerReq = false;

    deleteResidenceRecord() {
        this.removeAddressOnDelete(this.ChildRecords, 'AddrTyp__c', 'Residence Address')
        this.deleteAddressRecord(this.residenceAddress.Id)
        this.is_Open_Res_add = false
        this.isResReq = false
        this.addressValue = ''
        this.handleAddressOptions(this.wrapObj);
        this.residenceAddress = {}
        //console.log('Child Array ##1075', this.ChildRecords)
    }

    deletePermanentRecord() {
        this.deleteAddressRecord(this.permanentAddress.Id)
        this.is_Open_Per_add = false
        this.isPerReq = false;
        this.addressValue = ''
        this.handleAddressOptions(this.wrapObj);
        this.permanentAddress = {}
        this.removeAddressOnDelete(this.ChildRecords, 'AddrTyp__c', 'Permanent Address')
        //console.log('Child Array ##1085', this.ChildRecords)
    }

    deleteResCumOffRecord() {
        this.deleteAddressRecord(this.resiCusOfficeAddress.Id)
        this.is_Open_Res_Cum_add = false
        this.isResiCusOfficeAddress = false
        this.addressValue = ''
        this.handleAddressOptions(this.wrapObj);
        this.resiCusOfficeAddress = {}
        this.removeAddressOnDelete(this.ChildRecords, 'AddrTyp__c', 'Residence Cum office')
        //console.log('Child Array ##1095', this.ChildRecords)
    }

    deleteRegBussRecord() {
        this.deleteAddressRecord(this.regiBussiAddress.Id)
        this.is_Open_Reg_Bus_add = false
        this.isRegiBussiAddress = false
        this.addressValue = ''
        this.handleAddressOptions(this.wrapObj);
        this.regiBussiAddress = {}
        this.removeAddressOnDelete(this.ChildRecords, 'AddrTyp__c', 'Registered place for business')
        //console.log('Child Array ##1105', this.ChildRecords)
    }

    deletePrinBussRecord() {
        //console.log('In Prici delete ##985')
        this.deleteAddressRecord(this.princiBussiAddress.Id)
        this.is_Open_Princi_Bus_add = false
        this.isPrinciBussiAddress = false
        this.addressValue = ''
        this.handleAddressOptions(this.wrapObj);
        this.princiBussiAddress = {}
        this.removeAddressOnDelete(this.ChildRecords, 'AddrTyp__c', 'Principal place for business')
        //console.log('Cleared Princi ##992')
        //console.log('Child Array ##1117', this.ChildRecords)
    }

    deleteOtherAddRecord() {
        this.deleteAddressRecord(this.otherAddress.Id)
        this.is_Open_Other_add = false
        this.isOtherAddress = false
        this.addressValue = ''
        this.handleAddressOptions(this.wrapObj);
        this.otherAddress = {}
        this.removeAddressOnDelete(this.ChildRecords, 'AddrTyp__c', 'Other Address')
        //console.log('Child Array ##1127', this.ChildRecords)
    }

    deleteOfficeAddRecord() {
        this.removeAddressOnDelete(this.ChildRecords, 'AddrTyp__c', 'Office Address')
        this.deleteAddressRecord(this.officeAddress.Id)
        this.is_Open_Office_add = false
        this.isOffice = false
        this.addressValue = ''
        this.handleAddressOptions(this.wrapObj);
        this.officeAddress = {}
        //console.log('Child Array ##1137', this.ChildRecords)
    }

    mailingAddressCounter(ChildRecords) {
        this.mailingAddCounter = 0
        ChildRecords.forEach((item) => {
            if (item.MailAddr__c === true) {
                this.mailingAddCounter = this.mailingAddCounter + 1;
            }
        })

    }

    deleteAddressRecord(recId) {
        if (recId) {
            deleteRecord(recId)
                .then(() => {
                    //console.log('Record deleted ^^^^^^^', recId)
                    refreshApex(this.wiredData);
                    refreshApex(this.wiredAppAddressData);
                    //this.checkMailingAddressData();
                    // this.mailingAddressCounter(this.wiredData.data.ChildReords)
                    this.mailingAddressCounter(this.ChildRecords)
                    //console.log('Mailing counter ##1149', this.mailingAddCounter)
                    //console.log('Child Array ##1164', JSON.stringify(this.ChildRecords))
                })
                .catch(error => console.error('Error in deleting record ####', error))
        }
    }

    // removeAddressOnDelete(addName){
    //     const index = array.indexOf(addName);
    //     //console.log('index ##1172',index)
    //     if (index > -1) { 
    //         //console.log('Inside #1174')
    //         this.ChildRecords.splice(index, 1); 
    //     }
    // }

    removeAddressOnDelete(arr, attr, value) {
        var i = arr.length;
        while (i--) {
            if (arr[i]
                && arr[i].hasOwnProperty(attr)
                && arr[i][attr] === value) {

                arr.splice(i, 1);

            }
        }
        return arr;
    }

    //mailingAddCounter
    @track mailingAddCounter = 0;
    handleResidenceMailingAdd(event) {
        this.residenceAddress = JSON.parse(JSON.stringify(this.mailingAddCheck_reusable(this.residenceAddress, event)));
    }
    handlePermanentMailingAdd(event) {
        this.permanentAddress = JSON.parse(JSON.stringify(this.mailingAddCheck_reusable(this.permanentAddress, event)));
    }
    handleResCumOffMailingAdd(event) {
        this.resiCusOfficeAddress = JSON.parse(JSON.stringify(this.mailingAddCheck_reusable(this.resiCusOfficeAddress, event)));
    }
    handleRegiBussMailingAdd(event) {
        this.regiBussiAddress = JSON.parse(JSON.stringify(this.mailingAddCheck_reusable(this.regiBussiAddress, event)));
    }
    handlePrinciBussMailingAdd(event) {
        this.princiBussiAddress = JSON.parse(JSON.stringify(this.mailingAddCheck_reusable(this.princiBussiAddress, event)));
    }
    handleOtherMailingAdd(event) {
        this.otherAddress = JSON.parse(JSON.stringify(this.mailingAddCheck_reusable(this.otherAddress, event)));
    }
    handleOfficeMailingAdd(event) {
        this.officeAddress = JSON.parse(JSON.stringify(this.mailingAddCheck_reusable(this.officeAddress, event)));
    }

    mailingAddCheck_reusable(obj, event) {
        if (event.detail === "true") {
            this.mailingAddCounter = this.mailingAddCounter + 1;
            obj.MailAddr__c = true
        } if (event.detail === "false") {
            this.mailingAddCounter = this.mailingAddCounter - 1;
            obj.MailAddr__c = false
        }
        //console.log('counter value^^^^^',this.mailingAddCounter)
        return obj;
    }


    getRelationShipDetailsData() {
        var coApplicantTypeValue;
        if (this.wrapObj.Constitution__c && this.wrapObj.Constitution__c != 'INDIVIDUAL') {
            coApplicantTypeValue = 'NON INDIVIDUAL';
        } else if (this.wrapObj.Constitution__c && this.wrapObj.Constitution__c === 'INDIVIDUAL') {
            coApplicantTypeValue = 'INDIVIDUAL';
        }
        getRelationShipDetails({ loanRecordId: this.loanAppId, coApplicantType: coApplicantTypeValue })
            .then(result => {
                this.relationShipOptions = [];
                var relationRawData = result;
                this.relationShipOptions = Object.entries(relationRawData).map(([key, value]) => ({
                    label: value,
                    value: key
                }));
            })
            .catch(error => {
                //console.log('error Recieved!! !! ' + error);
            })
    }

}