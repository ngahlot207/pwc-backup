import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, deleteRecord } from 'lightning/uiRecordApi';
import { getPicklistValues, getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getSessionId from '@salesforce/apex/SessionUtil.getSessionId';
import { loadScript } from "lightning/platformResourceLoader";
import cometdlwc from "@salesforce/resourceUrl/cometd";
import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';
import APPLICANT_ADD_OBJECT from '@salesforce/schema/ApplAddr__c';

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
import Verify_Details_Required_fields_Error_Msg from '@salesforce/label/c.Verify_Details_Required_fields_Error_Msg';
//Apex methods
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getRelationShipDetails from '@salesforce/apex/DataSearchClass.getRelationShipDetails';
import getAddressData from '@salesforce/apex/DataSearchClass.getAddressData';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';
import checkPanNoStatus from "@salesforce/apex/DocumentDetailController.checkPanNoStatus";
import getAssetPropType from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import getAPIsToRun from '@salesforce/apex/APIAutoTriggerCheck.checkAPIToRun';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import CURRENT_USER_ID from "@salesforce/user/Id";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
//Import PicklistValue
import LOAN_APPL_STAGE from '@salesforce/schema/LoanAppl__c.Stage__c';

//LMS details
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, publish, MessageContext, APPLICATION_SCOPE, unsubscribe, createMessageContext, releaseMessageContext } from 'lightning/messageService';
import RECORDCREATE from "@salesforce/messageChannel/RecordCreate__c";

import { refreshApex } from '@salesforce/apex';

import { trimFunction } from 'c/reusableStringTrimComp';

import { CPARoles } from 'c/globalConstant';

import { rejectedEmailAdd } from 'c/globalConstant';//LAK-7889

const customerProfileVisibleOptions = ["SALARIED", "SELF EMPLOYED NON PROFESSIONAL", "SELF EMPLOYED PROFESSIONAL", "HOUSEWIFE", "OTHERS"];

export default class CaptureApplicantDetails extends LightningElement {
    @track apiList = [];
    @track intRecords = [];
    @api channelName = "/event/RetriggerUpsertCreated__e";

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
        Verify_Details_Required_fields_Error_Msg
    }

    @track addTypeName;
    @track deleteAddressMsg;
    @track isModalOpen = false;

    @track ristrictedEmailDomain = rejectedEmailAdd; //LAK-7889

    @track wiredData = {};
    @track wiredAppKycData = {};
    @track _recordId;
    @api get recordId() {
        return this._recordId;
    }

    set recordId(value) {
        this._recordId = value;
        this.setAttribute("recordId", value);
        this.handleRecordIdChange(value);
    }

    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        this.handleLoanAppIdChange(value);
    }
    @track _stepperName;
    @api get stepperName() {
        return this._stepperName;
    }

    set stepperName(value) {
        this._stepperName = value;
        this.setAttribute("stepperName", value);

    }

    @api isReadOnly;
    @api layoutSize;
    @api hasEditAccess;
    @track activeSection = ["A", "B"];
    @track disableMode;

    doiErrMessage
    registrationNumberPattern
    registrationNumberHelpText = "Please Enter Valid Value."
    yearOfRegistrationPattern
    yearOfRegistrationHelpText = "Please Enter Valid Value."
    membershipNumberPattern
    membershipNumberHelpText = "Please Enter Valid Value."
    @track addressValue;
    relationshipValue = ''
    relationShipLabel = 'Relationship';
    relationShipDisabled = true;
    applicantType = 'APPLICANT'
    typeOfBorrower = 'Financial'
    dobErrorMessage
    genderErrorMessage
    messageMismatchError = this.label.ApplicantCapture_Format_ErrorMessage

    @track BorrowerOptions = [];
    @track applicantTypeOptionsModified = [];
    @track applicantTypeOptions = []
    @track customerProfileOptions = []
    @track constitutionOptions = []
    @track titleOptions = []
    @track genderOptions = []
    @track maritalStatusOptions = []
    @track grpTxnOptions = []
    @track isGrpTxn;
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
    @track resiStatusOptions = [];
    @track guarantorSPDCOptions = [];
    @track ChildRecords = [];
    @track showerror = false;
    @track selectedCount;
    @track lookupRec;
    @track conditionallyReqResiStatus = false;
    @track guarantorSPDCVisiblity;
    @track requiredGuarantorSPDC = false;
    is_Per_Add_Visible = false
    isProfessional = true //should be false by default
    isAddressSame = false
    disabledFlag = false
    is_dobError = false
    is_genderError = false

    @track isRegiAddressSame = false;

    checkApplicant = true;
    checkCoApplicant = false;

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
    @track disablePan = false;
    @track disableIdProofType = false;
    @track disableIdNumber = false;
    @track policExpPersonOptions = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ];

    @track customerProfilCatOptions = [];
    @track filterConditionCustomProf = 'Type__c = \'Customer Profile Selection\'';

    @track addFlag = false;
    @track addRegiFlag = false;

    @track disabledTypeOfBorrower = false;

    @track disableBrowPefLan = true;

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

    @wire(getSessionId)
    wiredSessionId({ error, data }) {
        if (data) {
            this.sessionId = data;
            loadScript(this, cometdlwc);
        } else if (error) {
            this.sessionId = undefined;
        }
    }

    @wire(getSobjectData, { params: '$parameterforTeam' })
    handleResponseTeamHierarchy(wiredResultTeam) {
        let { error, data } = wiredResultTeam;
        if (data && data.parentRecords.length > 0) {
            var userTeamRole = data.parentRecords[0].EmpRole__c;
            this.userTeamRoleData = userTeamRole ? userTeamRole : null;
            this.isCINRequired = (userTeamRole && userTeamRole === 'RM') ? false : true;
        } else if (error) {
        }
    }
    //LAK-3181 
    StagePickVal

    //LAK-9244
    get isStageNotQDE() {
        if (this.StagePickVal && this.StagePickVal != 'QDE' && (this.userTeamRoleData && ((CPARoles && CPARoles.includes(this.userTeamRoleData)) || this.userTeamRoleData === 'UW'
            || this.userTeamRoleData === 'RCM' || this.userTeamRoleData === 'ZCM' || this.userTeamRoleData === 'NCM' || this.userTeamRoleData === 'CH'
            || this.userTeamRoleData === 'ACM'))) {
            return true;
        } else {
            return false;
        }
    }

    @wire(getRecord, { recordId: '$loanAppId', fields: [LOAN_APPL_STAGE] })
    StagePicklistValue({ data, error }) {
        if (data) {
            this.StagePickVal = data.fields.Stage__c.value;
            this.conditionallyReqResiStatus = (this.StagePickVal != null && this.StagePickVal !== 'QDE');
            this.guarantorSPDCVisiblity = (this.StagePickVal != null && this.StagePickVal !== 'QDE');
            this.requiredGuarantorSPDC = (this.StagePickVal != null && this.StagePickVal !== 'DDE');
        }
        if (error) {

        }
    }

    @track params = {
        ParentObjectName: 'Applicant__c',
        ChildObjectRelName: 'Applicant_Addresses__r',
        parentObjFields: ['Id', 'ConsentType__c', 'LoanAppln__r.Product__c', 'EmailIDverificationStatus__c', 'CAVerStatus__c', 'DoctorApiVerStatus__c', 'ArchVerStatus__c', 'LoanAppln__r.LMSUpdTrig__c', 'Type_of_Borrower__c', 'CustProfile__c', 'Constitution__c', 'Title__c', 'FName__c', 'MName__c', 'LName__c', 'DOB__c', 'Age__c', 'Gender__c', 'MthrMdnName__c', 'Father_Name__c', 'ApplType__c',
            'MariStatus__c', 'IsGrpExposureTxn__c', 'Nationality__c', 'Religion__c', 'EduQual__c', 'ProfQual__c', 'MediCouncl__c', 'MobNumber__c', 'OTP_Verified__c', 'Is_Physical_Consent_Validated__c', 'EmailId__c', 'RegistrationNumber__c', 'YearOfRegistration__c', 'Listed_Unlisted__c', 'Partnership_registration_no__c',
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

    @track paramsDocKYC = {
        ParentObjectName: 'DocDtl__c',
        parentObjFields: ['Id', 'Appl__c', 'Appl__r.Constitution__c', 'Applicant_KYC__r.DtOfBirth__c', 'Applicant_KYC__r.FatherName__c', 'Applicant_KYC__r.Name__c', 'Applicant_KYC__r.Gender__c', 'Applicant_KYC__r.Pan__c', 'DocTyp__c',
            'Applicant_KYC__r.DLNo__c', 'Applicant_KYC__r.AadharNo__c', 'Applicant_KYC__r.NPRNumber__c', 'Applicant_KYC__r.PassNo__c', 'Applicant_KYC__r.VotIdEpicNo__c', 'Applicant_KYC__r.UUID__c', 'Applicant_KYC__r.DLExpDt__c', 'Applicant_KYC__r.PassExpDt__c', 'DocSubTyp__c'],
        queryCriteria: ' where Appl__c = \'' + this.recordId + '\' AND  (DocSubTyp__c = \'Passport\') OR (DocSubTyp__c = \'Driving license\') '
    }

    @track paramsLoanApplcation = {
        ParentObjectName: 'Applicant__c',
        parentObjFields: ['Id', 'Name', 'Constitution__c', 'ApplType__c', 'LoanAppln__c','LoanAppln__r.Product__c'],
        queryCriteria: ' WHERE LoanAppln__c=\'' + this.loanAppId + '\' AND ApplType__c =\'' + 'P' + '\''
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

    //LAK-6985
    get showGrpTxn() {

        console.log('this. field  wrapObj.ApplType__c =', this.wrapObj.ApplType__c)
        console.log('this. field   productType =', this.productType)
        return this.wrapObj.ApplType__c && this.wrapObj.ApplType__c === 'P' && (this.productType === 'Personal Loan' || this.productType === 'Business Loan')
    }


    //LAK-6985
    get condReqGrpTxn() {
        if (this.userTeamRoleData && ((CPARoles && CPARoles.includes(this.userTeamRoleData)) || this.userTeamRoleData === 'UW'
            || this.userTeamRoleData === 'RCM' || this.userTeamRoleData === 'ZCM' || this.userTeamRoleData === 'NCM' || this.userTeamRoleData === 'CH'
            || this.userTeamRoleData === 'ACM')) {
            return true;
        }
    }

    //

    get listedUnlistedRequiredCondition() {
        //LAK-9244
        if (this.userTeamRoleData && ((CPARoles && CPARoles.includes(this.userTeamRoleData)) || this.userTeamRoleData === 'UW'
            || this.userTeamRoleData === 'RCM' || this.userTeamRoleData === 'ZCM' || this.userTeamRoleData === 'NCM' || this.userTeamRoleData === 'CH'
            || this.userTeamRoleData === 'ACM')) {
            return true;
        } else {
            return false;
        }
    }

    get disbledConstitution() {
        return (this.wrapObj.CustProfile__c === 'SALARIED' || this.wrapObj.CustProfile__c === "HOUSEWIFE" || this.wrapObj.CustProfile__c === "OTHERS" || this.disableMode === true);
    }

    get showRelationshipField() {
        if (this.wrapObj.ApplType__c && (this.wrapObj.ApplType__c === 'G' || this.wrapObj.ApplType__c === 'C') && this.wrapObj.Constitution__c != null) {
            this.relationShipLabel = 'Relationship with Applicant';
            return true;
        } else {
            return false;
        }
    }

    get customerCategorisationCondition() {
        return (this.wrapObj && this.wrapObj.Customer_Profile_Categorisation__c !== 'P');
    }

    get applType() {
        return this.applTypeForG();
    }
    applTypeForG() {
        return !(this.wrapObj && this.wrapObj.ApplType__c !== 'P' && this.wrapObj.CustProfile__c === 'SALARIED' && this.addressValue === 'Office Address');
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
    get handleLLPINVisibilityRequired() {
        return this.userTeamRoleData && this.wrapObj.Constitution__c === 'LIMITED LIABILITY PARTNERSHIP' && (CPARoles && CPARoles.includes(this.userTeamRoleData));  //LAK-9244
    }
    get conditionallyRequiredProfessionalQue() {
        return this.wrapObj.EduQual__c === 'PRF';
    }

    //LAK-9930
    get conditionallyDisableByProfessionalQu() {

        return (this.disableMode && (this.disableMode === true) && (this.wrapObj.EduQual__c === 'DOC'));

    }

    get conditionallyRequiredEducationalQue() {
        return this.wrapObj.EduQual__c === "DOC" || (this.wrapObj.EduQual__c === 'PRF' && this.wrapObj.ProfQual__c === 'DOC'); //|| this.wrapObj.EduQual__c === "CHA"
    }
    get conditionallyRequiredEducationalQueCA(){
        return this.wrapObj.EduQual__c === 'CHA' || (this.wrapObj.EduQual__c === 'PRF' && this.wrapObj.ProfQual__c === 'CA');
    }
    get conditionallyRequiredRegistrationNum() {
        return this.regNumReq()
    }
    get handlePartRegiNoVisibility() {
        return this.wrapObj.Whether_partnership_is_registered__c === 'Yes';
    }
    get handlePartRegiNoVisibilityRequired() {
        return this.userTeamRoleData && this.wrapObj.Whether_partnership_is_registered__c === 'Yes' && (CPARoles && CPARoles.includes(this.userTeamRoleData)); //LAK-9244
    }

    regNumReq() {
        if (this.wrapObj.EduQual__c === 'DOC' || (this.wrapObj.ProfQual__c && (this.wrapObj.ProfQual__c.includes("DOC") || this.wrapObj.ProfQual__c.includes("ART")))) {
            //LAK-9244
            if (CPARoles && CPARoles.includes(this.userTeamRoleData)) {
                return true
            }
            else
                return false
        } else {
            return false
        }
    }

    get conditionallyRequiredYOR() {
        return this.YORReq()
    }

    YORReq() {

        return !!(this.wrapObj.EduQual__c === 'DOC' || (this.wrapObj.ProfQual__c && this.wrapObj.ProfQual__c === "DOC"));
    }
    get conditionallyRequiredYORBL() {
        //debugger
        if (this.StagePickVal === 'QDE' &&
            this.consentType === 'Digital Consent' &&
            (this.productType === 'Personal Loan' || this.productType === 'Business Loan') && this.wrapObj.ProfQual__c &&
            !this.wrapObj.ProfQual__c.includes("DOC")) {
            return true;
        } else if (this.StagePickVal === 'QDE' &&
            this.consentType === 'Physical Consent Upload' &&
            (this.productType === 'Personal Loan' || this.productType === 'Business Loan')) {
            return false;
        } else if (this.StagePickVal === 'QDE' &&
            this.consentType === 'Digital Consent' &&
            (this.productType === 'Personal Loan' || this.productType === 'Business Loan') && this.wrapObj.ProfQual__c &&
            this.wrapObj.ProfQual__c.includes("DOC")) {
            return false;
        }
        else {
            return this.YORReq();
        }
    }

    get conditionallyRequiredMembershipNum() {
        return this.memNumReq()
    }

    memNumReq() {
        if (this.wrapObj.EduQual__c === 'CHA' || (this.wrapObj.ProfQual__c && (this.wrapObj.ProfQual__c === "CA" || this.wrapObj.ProfQual__c === "CS" || this.wrapObj.ProfQual__c === "ICWAI"))) {
            //LAK-9244
            if (CPARoles && CPARoles.includes(this.userTeamRoleData)) {
                return true
            }
            else
                return false
        } else {
            return false
        }
    }


    get handleCINVisibility() {
        return (this.wrapObj && (this.wrapObj.Constitution__c === 'PRIVATE LIMITED COMPANY' || this.wrapObj.Constitution__c === 'PUBLIC LIMITED COMPANY'));
    }

    get handleRegiPartnerVisibility() {
        return (this.wrapObj && (this.wrapObj.Constitution__c === 'PARTNERSHIP' || this.wrapObj.Constitution__c === 'LIMITED LIABILITY PARTNERSHIP'));
    }

    get handleRegiPartnerVisibilityRequired() {
        //LAK-9244
        if ((this.wrapObj.Constitution__c === 'PARTNERSHIP' || this.wrapObj.Constitution__c === 'LIMITED LIABILITY PARTNERSHIP') && this.userTeamRoleData && (CPARoles && CPARoles.includes(this.userTeamRoleData))) {
            return true
        }
        else {
            return false
        }
    }

    get grntrSPDCFieldVisiblity() {
        if (this.wrapObj.ApplType__c && this.wrapObj.ApplType__c === 'G' && this.guarantorSPDCVisiblity && this.guarantorSPDCVisiblity === true) {
            return true;
        }
    }

    get disableApplType() {
        if ((this.wrapObj.Id && this.wrapObj.ApplType__c && (this.wrapObj.ApplType__c === 'G' || this.wrapObj.ApplType__c === 'C')) || (this.disableMode === true)) {
            return true;
        }
    }

    get condReqMariStatsAsPerRole() {
        //LAK-9244
        if (this.userTeamRoleData && ((CPARoles && CPARoles.includes(this.userTeamRoleData)) || this.userTeamRoleData === 'UW'
            || this.userTeamRoleData === 'RCM' || this.userTeamRoleData === 'ZCM' || this.userTeamRoleData === 'NCM' || this.userTeamRoleData === 'CH'
            || this.userTeamRoleData === 'ACM')) {
            return true;
        }
    }


    @wire(MessageContext)
    MessageContext;

    handleRecordIdChange() {
        let tempParams = this.params;
        tempParams.queryCriteria = ' where id = \'' + this._recordId + '\'';
        this.params = { ...tempParams };

        let paramKYCTemp = this.paramsKYC;
        paramKYCTemp.queryCriteria = ' where Appl__c = \'' + this._recordId + '\'  AND ((DocTyp__c  = \'' + 'Identity Proof' + '\'' + ') OR (DocTyp__c  = \'' + 'PAN' + '\'' + ' ) OR (DocTyp__c  = \'' + 'DOB Proof' + '\'' + ' ))' + ' ORDER BY LASTMODIFIEDDATE DESC';
        this.paramsKYC = { ...paramKYCTemp };

        let paramKYCDocTemp = this.paramsDocKYC;
        paramKYCDocTemp.queryCriteria = ' where Appl__c = \'' + this._recordId + '\' AND ((DocSubTyp__c  = \'' + 'Passport' + '\'' + ') OR (DocSubTyp__c  = \'' + 'Driving license' + '\'' + ' ))';
        this.paramsDocKYC = { ...paramKYCDocTemp };

    }


    handleLoanAppIdChange() {
        let tempParams = this.paramsLoanApplcation;
        tempParams.queryCriteria = ' WHERE LoanAppln__c=\'' + this._loanAppId + '\' AND ApplType__c =\'' + 'P' + '\'';
        this.paramsLoanApplcation = { ...tempParams };
    }

    @track showSpinner = true;

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
        }
    }


    get cpaVisibilityCondition() {
        //LAK-9244
        if ((this.userTeamRoleData && this.userTeamRoleData === 'UW' || (CPARoles && CPARoles.includes(this.userTeamRoleData))
            || this.userTeamRoleData === 'RCM' || this.userTeamRoleData === 'ZCM' || this.userTeamRoleData === 'NCM' || this.userTeamRoleData === 'CH'
            || this.userTeamRoleData === 'ACM')) {
            return true;
        } else {
            return false;
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

    get panNumberRequiredCondition() {
        return (this.wrapObj && this.wrapObj.Type_of_Borrower__c === 'Financial');
    }

    @track appKYCDocs = [];
    @track wiredAppKycDocData = [];
    @wire(getSobjectData, { params: '$paramsDocKYC' })
    handleAppKycDoc(result) {
        this.wiredAppKycDocData = result;
        if (result.data) {
            if (result.data.parentRecords && result.data.parentRecords.length > 0) {
                result.data.parentRecords.forEach(item => {
                    let obj = { docSubType: item.DocSubTyp__c, appKycRec: item.Applicant_KYC__r };
                    this.appKYCDocs.push(obj);
                })
            }
        }
        if (result.error) {
        }
    }

    get passExpDateVisbl() {
        let tempExpDateVisbl = false;
        if (this.appKYCDocs) {
            this.appKYCDocs.forEach(item => {
                if (item.appKycRec && item.docSubType && item.docSubType === 'Passport' && this.wrapObj.Constitution__c && this.wrapObj.Constitution__c === 'INDIVIDUAL') {
                    if (item.appKycRec.PassExpDt__c) {
                        this.wrapObj.PassportExpDate__c = item.appKycRec.PassExpDt__c;
                    }
                    tempExpDateVisbl = true;
                }
            });
        }
        return tempExpDateVisbl;
    }


    get drvLicExpDateVisbl() {
        let tempDrLicExpDateVsbl = false;
        if (this.appKYCDocs) {
            this.appKYCDocs.forEach(item => {
                if (item.appKycRec && item.docSubType && item.docSubType === 'Driving license' && this.wrapObj.Constitution__c && this.wrapObj.Constitution__c === 'INDIVIDUAL') {
                    if (item.appKycRec.DLExpDt__c) {
                        this.wrapObj.DrivingLicExpDate__c = item.appKycRec.DLExpDt__c;
                    }
                    tempDrLicExpDateVsbl = true;
                }
            });
        }
        return tempDrLicExpDateVsbl;
    }

    get isOCRPassExpDateAvl() {
        let tempExpDateVisbl = false;
        if (this.appKYCDocs) {
            this.appKYCDocs.forEach(item => {
                if (item.appKycRec && item.docSubType && item.docSubType === 'Passport' && this.wrapObj.Constitution__c && this.wrapObj.Constitution__c === 'INDIVIDUAL') {
                    if (item.appKycRec.PassExpDt__c) {
                        this.wrapObj.PassportExpDate__c = item.appKycRec.PassExpDt__c;
                        tempExpDateVisbl = true;
                    }
                }
            });
        }
        return tempExpDateVisbl || this.disableMode;
    }

    get isOCRDrvLicExpAvl() {
        let tempDrLicExpDateVsbl = false;
        if (this.appKYCDocs) {
            this.appKYCDocs.forEach(item => {
                if (item.appKycRec && item.docSubType && item.docSubType === 'Driving license' && this.wrapObj.Constitution__c && this.wrapObj.Constitution__c === 'INDIVIDUAL') {
                    if (item.appKycRec.DLExpDt__c) {
                        this.wrapObj.DrivingLicExpDate__c = item.appKycRec.DLExpDt__c;
                        tempDrLicExpDateVsbl = true;
                    }
                }
            });
        }
        return tempDrLicExpDateVsbl || this.disableMode;
    }


    handleValueSelect(event) {
        if (event.detail && event.detail.id) {
            this.wrapObj.Customer_Profile_Selection_Id__c = event.detail.id;
            this.selectedRecordId = event.detail.id;
        }
    }
    handleValueSelect1(event) {
        this.lookupRec = event.detail;
        if (this.lookupRec.lookupFieldAPIName === 'Relationship__c') {
            this.wrapObj.Relationship__c = this.lookupRec.mainField;
        }
    }

    @track customerProfSeleMandatory = true;

    get showLEIConditions() {
        return this.wrapObj && this.wrapObj.Constitution__c != 'INDIVIDUAL'
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
        return detailsMacthed || this.disableMode;
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
    get isOCREditFirstName() {
        let detailsMacthed = false;
        let name;
        if (this.appKYC) {
            this.appKYC.forEach(item => {
                if (item.docType === 'Identity Proof' && item.appKyc.Name__c) {
                    let nameTokens = item.appKyc.Name__c.split(' ');
                    if (nameTokens.length >= 1) {
                        name = nameTokens[0];
                    }
                }
            })
            this.appKYC.forEach(item => {
                if (item.docType === 'Identity Proof') {
                    if ((name && this.wrapObj.FName__c.toUpperCase() === name.toUpperCase()) || this.disableMode) {
                        detailsMacthed = true;
                    }
                }
            })
        }
        return detailsMacthed || this.disableMode;
    }

    get isOCREditLastName() {
        let detailsMacthed = false;
        let lName;
        if (this.appKYC) {
            this.appKYC.forEach(item => {
                if (item.docType === 'Identity Proof' && item.appKyc.Name__c) {
                    let nameTokens = item.appKyc.Name__c.split(' ');
                    if (nameTokens.length >= 3) {
                        let mName = nameTokens[1];
                        for (let i = 2; i < nameTokens.length; i++) {
                            if (i == 2) {
                                lName = nameTokens[i];
                            } else {
                                lName += ' ' + nameTokens[i];
                            }
                        }
                    }
                    else if (nameTokens.length == 2) {
                        lName = nameTokens[1];
                    }
                }

            })
            this.appKYC.forEach(item => {
                if (item.docType === 'Identity Proof') {
                    if ((lName && lName.toUpperCase() === this.wrapObj.LName__c.toUpperCase()) || this.disableMode) {
                        detailsMacthed = true;
                    }
                }
            })
        }
        return detailsMacthed || this.disableMode;
    }
    get isOCREditGender() {
        let detailsMacthed = false;
        if (this.appKYC) {

            this.appKYC.forEach(item => {
                if (item.docType === 'Identity Proof') {
                    if ((item.appKyc.Gender__c && this.gender === item.appKyc.Gender__c) || this.disableMode) {
                        detailsMacthed = true;
                    }
                }
            })
        }
        return detailsMacthed || this.disableMode;
    }


    @track consentProvided = false;

    get mobileNumberDisabled() {
        return (this.disableMode === true || this.consentProvided === false);
    }

    @track wiredAppAddressData;

    checkMailingAddressData() {
        getAddressData({ applicationId: this.loanAppId })
            .then(result => {
                var dataReceived = result;
                this.handleCheckMailingAddressPresent(dataReceived);
            })
            .catch(error => {

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

        }
    }

    @track mailingAddressCheckedPresent = 0;

    handleCheckMailingAddressPresent(data) {
        this.mailingAddressCheckedPresent = data.reduce((count, item) => {
            return count + ((item.MailAddr__c && item.MailAddr__c === true) ? 1 : 0);
        }, 0);
    }

    isFinancial = false;
    oldMobileNumber;

    @track oldEmail; //LAK-517
    @track oldProfQual;
    @track emailIdVerStatus; //LAK-517
    @track quaCheckVerStatus; //LAK-223
    @track quaCheckVerStatusDoc; //LAK-223
    @track quaCheckVerStatusArch; //LAK-223
    @track oldCIN; //LAK-9823
    @track oldLLPIN; //LAK-9823
    @wire(getSobjectDatawithRelatedRecords, { params: '$params' })
    handleResponse(wiredApplicantData) {
        let { error, data } = wiredApplicantData;
        this.wiredData = wiredApplicantData;
        this.isCoApplicant = false;
        this.mailingAddCounter = 0;
        this.wrapObj = {};
        if (data) {
            this.wrapObj = {
                ...data.parentRecord, Age__c: this.getNumber(data.parentRecord.DOB__c), InceptionYears__c: this.getNumber(data.parentRecord.DOI__c), Nationality__c: 'INDIA', Type_of_Borrower__c: data.parentRecord.Type_of_Borrower__c ? data.parentRecord.Type_of_Borrower__c : this.typeOfBorrower,
                FName__c: data.parentRecord.FName__c ? data.parentRecord.FName__c.toUpperCase() : '', MName__c: data.parentRecord.MName__c ? data.parentRecord.MName__c.toUpperCase() : '', LName__c: data.parentRecord.LName__c ? data.parentRecord.LName__c.toUpperCase() : '',
                Father_Name__c: data.parentRecord.Father_Name__c ? data.parentRecord.Father_Name__c.toUpperCase() : '', SpName__c: data.parentRecord.SpName__c ? data.parentRecord.SpName__c.toUpperCase() : ''
            };

            console.log('this.wrapObj ==',this.wrapObj)
            if(data.parentRecord.LoanAppln__r.Product__c){
                this.productType = data.parentRecord.LoanAppln__r.Product__c
            }
            console.log('this.productType new :',this.productType)
            
            this.oldMobileNumber = data.parentRecord.MobNumber__c;
            this.oldCIN = data.parentRecord && data.parentRecord.CIN__c ? data.parentRecord.CIN__c : '';//LAK-9823
            this.oldLLPIN = data.parentRecord && data.parentRecord.LLPIN__c ? data.parentRecord.LLPIN__c : '';//LAK-9823
            if (this.wrapObj.ApplType__c && this.wrapObj.Type_of_Borrower__c && this.wrapObj.ApplType__c === 'G' && this.wrapObj.Type_of_Borrower__c === 'Non Financial') {
                this.disabledTypeOfBorrower = true;
            }
            if (this.wrapObj.Type_of_Borrower__c) {
                this.isFinancial = (this.wrapObj.Type_of_Borrower__c === 'Financial');
            } else {
                this.isFinancial = false;
            }

            if (!this.wrapObj.BorrowerPreferredLanguage__c) {
                this.disableBrowPefLan = false;
            }
            if (this.wrapObj.EmailId__c) {
                this.oldEmail = this.wrapObj.EmailId__c;
            }
            if (this.wrapObj.ProfQual__c) {
                this.oldProfQual = this.wrapObj.ProfQual__c;
            }
            //LAK-517
            if (this.wrapObj.EmailIDverificationStatus__c) {
                this.emailIdVerStatus = this.wrapObj.EmailIDverificationStatus__c;
            }
            if (this.wrapObj.CAVerStatus__c) {
                this.quaCheckVerStatus = this.wrapObj.CAVerStatus__c;
            }
            if (this.wrapObj.DoctorApiVerStatus__c) {
                this.quaCheckVerStatusDoc = this.wrapObj.DoctorApiVerStatus__c;
            }
            if (this.wrapObj.ArchVerStatus__c) {
                this.quaCheckVerStatusArch = this.wrapObj.ArchVerStatus__c;
            }
            if (data.parentRecord && data.parentRecord.CustProfile__c) {
                if (data.parentRecord.CustProfile__c === "HOUSEWIFE" || data.parentRecord.CustProfile__c === "OTHERS") {
                    this.disabledTypeOfBorrower = true;
                }
            }

            if (data.parentRecord && data.parentRecord.ApplType__c) {
                this.dob = data.parentRecord.DOB__c;
                this.gender = data.parentRecord.Gender__c;
                this.fathername = data.parentRecord.Father_Name__c;
                if (data.parentRecord.ApplType__c === 'P') {
                    this.applicantType = 'APPLICANT';
                    this.wrapObj.ApplType__c = 'P';
                    this.checkCoApplicant = false;
                } else if (data.parentRecord.ApplType__c === 'C') {
                    this.applicantType = 'CO-APPLICANT';
                    this.checkCoApplicant = true;
                    this.checkApplicant = false;
                    this.wrapObj.ApplType__c = 'C';
                }
                else if (data.parentRecord.ApplType__c === 'G') {
                    this.applicantType = 'GUARANTOR';
                    this.checkCoApplicant = true;
                    this.checkApplicant = false;
                    this.wrapObj.ApplType__c = 'G';
                } else {
                    this.applicantType = 'APPLICANT';
                    this.checkCoApplicant = false;
                    this.checkApplicant = true;
                    this.wrapObj.ApplType__c = 'P';
                }
            }
            if (this.applicantType === 'GUARANTOR' || this.applicantType === 'CO-APPLICANT') {
                this.wrapObj.Relationship__c = data.parentRecord ? data.parentRecord.Relationship__c ? data.parentRecord.Relationship__c : '' : '';
                this.relationshipValue = data.parentRecord ? data.parentRecord.Relationship__c ? data.parentRecord.Relationship__c : '' : '';
                this.relationShipLabel = 'Relationship with Applicant';
                this.relationShipDisabled = false;
            } else {
                this.wrapObj.Relationship__c = 'Self';
                this.relationshipValue = 'Self';
                this.relationShipLabel = 'Relationship';
                this.relationShipDisabled = true;
            }


            if (data.ChildReords) {
                data.ChildReords.forEach(item => {
                    if (item.AddrTyp__c === 'Permanent Address') {
                        this.permanentAddress = { ...item }
                        this.is_Open_Per_add = true;
                        this.addressValue = 'Permanent Address'
                        this.isAddressSame = item.isPerSameAsResi_ADD__c
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
                        this.isRegiAddressSame = item.Same_as_Principal_place_for_business__c;
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
                    if (item.MailAddr__c === true) {

                        this.mailingAddCounter = this.mailingAddCounter + 1;
                    }
                });
            }
            if (this.wrapObj) {
                this.getRelationShipDetailsData();
            }
            if (this.wrapObj && this.addressOptions.length > 0) {
                this.handleAddressOptions(this.wrapObj);
            }
            if (this.wrapObj.Customer_Profile_Selection_Id__c) {
                this.selectedRecordId = this.wrapObj.Customer_Profile_Selection_Id__c;
            }
            this.addFlag = this.isAddressSame
            this.addRegiFlag = this.isRegiAddressSame
            this.checkValidationForBlPl(data.parentRecord.LoanAppln__r.Product__c, data.parentRecord.ConsentType__c, data.parentRecord.Constitution__c);

            this.getProbeDetails();
        }
        if (error) {

            console.error(error);
        }
        this.showSpinner = false;
    }
    @track reqIndiviDetails;
    @track productType;

    // get productTypeVal(){
    //     return this.productType;
    // }

    


    @track consentType;
    @track consitutionType
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

    generatePicklist(data) {
        if (data) {
            return data.values.map(item => ({ "label": item.label, "value": item.value }))
        }
    }

    @wire(getObjectInfo, { objectApiName: APPLICANT_ADD_OBJECT })
    appAddObjectInfo

    @wire(getPicklistValuesByRecordType, {
        objectApiName: APPLICANT_ADD_OBJECT,
        recordTypeId: '$appAddObjectInfo.data.defaultRecordTypeId',
    })
    addressPicklistHandler({ data, error }) {
        if (data) {
            this.addressOptions = [...this.generatePicklist(data.picklistFieldValues.AddrTyp__c)]
            this.addressOptions = this.addressOptions.filter(item => {
                return item.label !== 'GST Address';
            });
            if (this.wrapObj && this.addressOptions.length > 0 && this.isRendered === false) {
                this.handleAddressOptions(this.wrapObj);
                this.isRendered = true;
            }
        }
        if (error) {


        }
    }
    custmoption = [];
    @wire(getObjectInfo, { objectApiName: APPLICANT_OBJECT })
    objectInfo

    @wire(getPicklistValuesByRecordType, {
        objectApiName: APPLICANT_OBJECT,
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    })
    picklistHandler({ data, error }) {
        if (data) {
            this.applicantTypeOptions = [...this.generatePicklist(data.picklistFieldValues.Type_of_Borrower__c)]
            this.grpTxnOptions = [...this.generatePicklist(data.picklistFieldValues.IsGrpExposureTxn__c)]
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
            this.partnershipOptions = [...this.generatePicklist(data.picklistFieldValues.Whether_partnership_is_registered__c)];
            this.resiStatusOptions = [...this.generatePicklist(data.picklistFieldValues.Residential_Status__c)]
            this.guarantorSPDCOptions = [...this.generatePicklist(data.picklistFieldValues.Guarantor_is_bringing_in_SPDC__c)]
            if (data.picklistFieldValues && data.picklistFieldValues.Customer_Profile_Categorisation__c) {
                this.customerProfilCatOptions = [...this.generatePicklist(data.picklistFieldValues.Customer_Profile_Categorisation__c)]
            }
            //logic for customer profile picklist 
            let customerProfileAllOptions = [...this.generatePicklist(data.picklistFieldValues.CustProfile__c)];
            let tempArrayCustProfile = [];

            for (let i = 0; i < customerProfileAllOptions.length; i++) {
                if (customerProfileVisibleOptions.indexOf(customerProfileAllOptions[i].label) > -1) {
                    tempArrayCustProfile.push(customerProfileAllOptions[i]);
                }
            }
            let customerProfileOptionsApp = [...tempArrayCustProfile];
            let customerProfileOptionsApp1 = [...tempArrayCustProfile];
            this.custmoption = customerProfileOptionsApp1;

            if (this.applicantType === 'APPLICANT') {
                let customerProfileAppOptions = customerProfileOptionsApp.filter(item => (item.label != 'HOUSEWIFE') && (item.label != 'OTHERS'));
                this.customerProfileOptions = customerProfileAppOptions;
            }

            if (this.applicantType !== 'APPLICANT') {
                this.checkApplicant = false;
                this.checkCoApplicant = true;
                this.custmoption = customerProfileOptionsApp1;
            }

            let applicantTypeOptions = [...this.generatePicklist(data.picklistFieldValues.ApplType__c)];
            this.applicantTypeOptionsModified = applicantTypeOptions.filter(option => {
                return option.label !== 'APPLICANT';
            });

            this.BorrowerOptions = [...this.generatePicklist(data.picklistFieldValues.Type_of_Borrower__c)];
        }
        if (error) {

        }
    }

    housewife_indi_Options = ['Residence Address', 'Permanent Address', 'Other Address'] //LAK-3201
    sal_indi_Options = ['Residence Address', 'Permanent Address', 'Other Address', 'Office Address']
    self_Emp_P_NP_indi_Options = ['Residence Address', 'Principal place for business', 'Residence Cum office', 'Permanent Address', 'Other Address']
    self_Emp_P_NP_nonIndi_Options = ['Principal place for business', 'Registered place for business', 'Other Address']
    self_Emp_P_NP_nonIndi_R_Options = ['Principal place for business', 'Registered place for business', 'Other Address']

    handleAddressOptions(resultObject) {
        this.options = []
        let tempAddressArray = [];
        for (let i = 0; i < this.addressOptions.length; i++) {
            if (resultObject && resultObject.Type_of_Borrower__c === 'Financial' && resultObject.CustProfile__c === 'SALARIED' && resultObject.Constitution__c === 'INDIVIDUAL') {
                if (this.sal_indi_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);
                    this.isResReq = true;
                    this.isOffice = true
                    this.isPerReq = true; //LAK-1872
                    this.isOtherAddress = true; //LAK-1872
                }
            }
            if (resultObject && resultObject.Type_of_Borrower__c === 'Financial' && (resultObject.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || resultObject.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') && resultObject.Constitution__c === 'INDIVIDUAL') {
                if (this.self_Emp_P_NP_indi_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);
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
                if (this.self_Emp_P_NP_nonIndi_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);
                    this.isPrinciBussiAddress = true;
                    this.isRegiBussiAddress = true;
                    this.isOtherAddress = true; //LAK-1872
                }
            }
            if (resultObject && (resultObject.Type_of_Borrower__c === 'Financial' || resultObject.Type_of_Borrower__c === 'Non Financial') && (resultObject.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || resultObject.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') &&
                (resultObject.Constitution__c === 'HUF' || resultObject.Constitution__c === 'SOCIETY' || resultObject.Constitution__c === 'PROPERITORSHIP')) {
                if (this.self_Emp_P_NP_nonIndi_R_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);
                    this.isPrinciBussiAddress = true
                    this.isRegiBussiAddress = true; //LAK-1872
                    this.isOtherAddress = true; //LAK-1872
                }
            }

            if (resultObject && resultObject.Type_of_Borrower__c === 'Non Financial' && resultObject.CustProfile__c === 'SALARIED' && resultObject.Constitution__c === 'INDIVIDUAL') {
                if (this.sal_indi_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);
                    this.isResReq = true
                    this.isOffice = true; //LAK-1872
                    this.isOtherAddress = true; //LAK-1872
                    this.isPerReq = true; //LAK-1872
                }
            }

            if (resultObject && resultObject.Type_of_Borrower__c === 'Non Financial' && (resultObject.CustProfile__c === "HOUSEWIFE" || resultObject.CustProfile__c === "OTHERS") && resultObject.Constitution__c === 'INDIVIDUAL') {
                if (this.housewife_indi_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);
                    this.isResReq = true;
                    this.isPerReq = true;
                    this.isOtherAddress = true;
                }
            }

            if (resultObject && resultObject.Type_of_Borrower__c === 'Non Financial' && (resultObject.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || resultObject.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') && resultObject.Constitution__c === 'INDIVIDUAL') {
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
    }

    get options() {
        return [...this.options].sort(this.compareByLabel);
    }

    compareByLabel(a, b) {
        const nameA = a.label.toUpperCase();
        const nameB = b.label.toUpperCase();
        if (nameA < nameB) {
            return -1;
        }
        if (nameA > nameB) {
            return 1;
        }
        return 0;
    }

    compareArrays(a, b) {
        return a.length === b.length && a.every((element, index) => element === b[index]);
    }

    connectedCallback() {
        console.log('ristrictedEmailDomain', this.ristrictedEmailDomain);//LAK-7889

        if (this.hasEditAccess === false) {
            this.disableMode = true;
            this.relationShipDisabled = true;
            this.disabledTypeOfBorrower = true;
        }
        else {
            this.disableMode = false;
        }
        this.showSpinner = false;
        this.scribeToMessageChannel();
        this.activeSection = ["A", "B"];
        if (this.wrapObj.DOB__c) {
            this.wrapObj.Age__c = this.dob()
        }
        if (this.wrapObj.DOI__c) {
            this.wrapObj.InceptionYears__c = this.doi()
        }
        if (this._stepperName !== null && this._stepperName === 'CoApplicantDetails') {
            this.applicantType = 'CO-APPLICANT';
        }

        this.checkForMultipleSelection();

        if (this.applicantType === 'APPLICANT' && this.checkNewApplicant === true) {
            this.checkApplicant = true;
        }
        if (this._recordId) {
            let tempParamsApplicant = this.applicantParams;
            tempParamsApplicant.queryCriteria = ' where Id = \'' + this._recordId + '\'';
            this.applicantParams = { ...tempParamsApplicant };
            this.getNonCachedApplicantData();
        }
        if (this.recordId === 'new') {
            this.showToastMessage('Error', this.label.Verify_Details_Required_fields_Error_Msg, 'error', 'sticky');
        }
        this.getEmailMasteData();//LAK-517  
    }

    //LAK-517
    @track basicEmailCodes = [];
    getEmailMasteData() {
        this.showSpinner = true;
        let type = 'Email Providers';
        let params = {
            ParentObjectName: 'MasterData__c',
            parentObjFields: ['Id', 'SalesforceCode__c', 'Name', 'Type__c'],
            queryCriteria: ' where Type__c = \'' + type + '\''
        }
        getAssetPropType({ params: params })
            .then((result) => {

                if (result.parentRecords && result.parentRecords.length > 0) {
                    result.parentRecords.forEach(item => {
                        this.basicEmailCodes.push(item.SalesforceCode__c);
                    })
                }
            })
            .catch((error) => {
                this.showSpinner = false;

            });
    }
    @track applicantParams = {
        ParentObjectName: 'Applicant__c ',
        ChildObjectRelName: null,
        parentObjFields: ['Id', 'OTP_Verified__c', 'DigitalVerified__c', 'Is_Physical_Consent_Validated__c', 'ApplType__c'],
        childObjFields: [],
        queryCriteria: ' where Id = \'' + this._recordId + '\''
    }

    getNonCachedApplicantData() {
        getSobjectDataNonCacheable({ params: this.applicantParams })
            .then(result => {
                if (result) {
                    if (result.parentRecords && result.parentRecords.length > 0) {
                        if (result.parentRecords[0] && result.parentRecords[0].OTP_Verified__c === false && result.parentRecords[0].DigitalVerified__c === false
                            && result.parentRecords[0].Is_Physical_Consent_Validated__c === false &&
                            (result.parentRecords[0].ApplType__c && (result.parentRecords[0].ApplType__c === 'G' || result.parentRecords[0].ApplType__c === 'C' || result.parentRecords[0].ApplType__c === 'P'))) {
                            this.consentProvided = false;
                            this.showToastMessage('Error', this.label.ApplicantDetails_Consent_ErrorMessage, 'error', 'sticky');
                        } else {
                            this.consentProvided = true;
                        }
                    }
                }
            })
            .catch(error => {
            })
    }



    @track isRendered = false;

    renderedCallback() {
        refreshApex(this.wiredData);
        refreshApex(this.wiredAppKycData);
        refreshApex(this.wiredAppAddressData);
        refreshApex(this.wiredAppKycDocData);
        refreshApex(this.wiredLaonApplcantData);

        if (this.wrapObj && this.addressOptions.length > 0 && this.isRendered === false) {
            this.isRendered = true;
        }
        this.checkForMultipleSelection();
    }

    handleAddressSelection(event) {

        this.addressValue = event.target.value
        const selectedValue = event.detail.value;

        let Obj = {};
        Obj.AddrTyp__c = selectedValue;

        const isDuplicate = this.ChildRecords.some(item => item.AddrTyp__c === Obj.AddrTyp__c);
        if (!isDuplicate) {
            this.ChildRecords.push(Obj);
        }

        if (selectedValue === 'Residence Address') {
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

    blurHandler(event) {
        if (event.target.dataset.fieldtype === 'string') {
            let strVal = event.target.value;
            this.wrapObj[event.target.dataset.fieldname] = trimFunction(strVal)
        }
    }

    inputChangeHandler(event) {
        //debugger
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
        if (event.target.dataset.fieldname === 'Gender__c') {
            this.gender = event.target.value;
        }
        if (event.target.dataset.fieldname === 'Father_Name__c') {
            this.fathername = event.target.value;
        }

        if (event.target.dataset.fieldname === 'IsGrpExposureTxn__c') {
            this.isGrpTxn = event.target.value;
        }


        if (event.target.dataset.fieldname === 'CustProfile__c') {
            this.is_Open_Res_add = false;
            this.is_Open_Per_add = false;
            this.is_Open_Res_Cum_add = false;
            this.is_Open_Reg_Bus_add = false;
            this.is_Open_Princi_Bus_add = false;
            this.is_Open_Other_add = false;
            this.is_Open_Office_add = false;
            if (this.wrapObj.CustProfile__c) {
                if (this.wrapObj.CustProfile__c === 'SALARIED' || this.wrapObj.CustProfile__c === "HOUSEWIFE" || this.wrapObj.CustProfile__c === "OTHERS") {
                    this.wrapObj.Constitution__c = 'INDIVIDUAL';
                }
                this.handleAddressOptions(this.wrapObj);
            }
            if (this.wrapObj.CustProfile__c) {
                if (this.wrapObj.CustProfile__c === "HOUSEWIFE" || this.wrapObj.CustProfile__c === "OTHERS") {
                    this.disabledTypeOfBorrower = true;
                    this.wrapObj.Type_of_Borrower__c = 'Non Financial'
                } else {
                    this.disabledTypeOfBorrower = false;
                }
            }
        }

        if (event.target.dataset.fieldname === 'Relationship__c') {
        }
        if (event.target.dataset.fieldname === 'Type_of_Borrower__c') {
            this.handleAddressOptions(this.wrapObj);
        }
        if (event.target.dataset.fieldname === 'Constitution__c') {
            this.wrapObj.MariStatus__c = ''   //for uat and qa fix
            this.is_Open_Res_add = false;
            this.is_Open_Per_add = false;
            this.is_Open_Res_Cum_add = false;
            this.is_Open_Reg_Bus_add = false;
            this.is_Open_Princi_Bus_add = false;
            this.is_Open_Other_add = false;
            this.is_Open_Office_add = false;
            if (this.wrapObj.Constitution__c) {
                if (this.wrapObj.Constitution__c === 'PARTNERSHIP' || this.wrapObj.Constitution__c === 'LIMITED LIABILITY PARTNERSHIP') {
                } else {
                    this.wrapObj.Whether_partnership_is_registered__c = ''
                }
                this.handleAddressOptions(this.wrapObj);
                this.getRelationShipDetailsData();
            }
            this.checkValidationForBlPl(this.productType, this.consentType, data.parentRecord.Constitution__c);
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
        if (event.target.dataset.fieldname === 'Title__c') {
            if (this.wrapObj.Title__c) {
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
                const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
                let emailVal = email.value;
                let emailVer = this.ristrictedEmailDomain.some(domain => emailVal.endsWith(domain));//LAK-7889

                if (emailVal.match(emailRegex) && emailVer == false) {
                    email.setCustomValidity("");
                } else {
                    email.setCustomValidity("Please enter valid email");
                    if (emailVal.length === 0) {
                        email.setCustomValidity("");
                    }
                }
                email.reportValidity();
            } else if (event.target.required) {
                email.setCustomValidity("Complete this field.");
            }
        }
    }

    getNumber(value) {
        var millis = Date.now() - new Date(value).getTime()
        var age = new Date(millis)
        return Math.abs(age.getUTCFullYear() - 1970)
    }

    copyResiObjMethod(event) {
        let perId = this.permanentAddress.Id
        let perAddType = this.permanentAddress.AddrTyp__c ? this.permanentAddress.AddrTyp__c : 'Permanent Address';
        let copy_residenceAddress = { ...event.detail };
        if (this.isAddressSame) {
            copy_residenceAddress.MailAddr__c = false;//LAK-6444
        }
        this.permanentAddress = copy_residenceAddress;
        this.permanentAddress.Id = perId
        this.permanentAddress.AddrTyp__c = perAddType

        this.permanentAddress.isPerSameAsResi_ADD__c = this.isAddressSame;
        this.addFlag = this.isAddressSame;
    }


    copyPrincipalObjMethod(event) {
        let regId = this.regiBussiAddress.Id
        let regAddType = this.regiBussiAddress.AddrTyp__c ? this.regiBussiAddress.AddrTyp__c : 'Registered place for business';
        let copy_princiBussiAddress = { ...event.detail };
        if (this.isRegiAddressSame) {
            copy_princiBussiAddress.MailAddr__c = false;//LAK-6444
        }
        this.regiBussiAddress = copy_princiBussiAddress
        this.regiBussiAddress.Same_as_Principal_place_for_business__c = this.isRegiAddressSame
        this.regiBussiAddress.Id = regId
        this.regiBussiAddress.AddrTyp__c = regAddType
        this.addRegiFlag = this.isRegiAddressSame
    }


    handleChildResidenceData(event) {
        if (this.isAddressSame) {
            this.copyResiObjMethod(event);
        }
        this.residenceAddress = { ...this.residenceAddress, ...event.detail }
        this.residenceAddresscheckbox = event.detail.MailAddr__c;
        this.checkForMultipleSelection();
        if (this.selectedCount > 1 && this.residenceAddresscheckbox) {
            this.showerror = true;
        } else {
            this.showerror = false;
        }
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
    }

    handleChildResiCumOfficeData(event) {
        this.resiCusOfficeAddress = { ...this.resiCusOfficeAddress, ...event.detail }
    }

    handleChildRegiBussiData(event) {
        this.regiBussiAddress = { ...this.regiBussiAddress, ...event.detail }
    }

    handleChildPrinciBussiData(event) {
        if (this.isRegiAddressSame) {
            this.copyPrincipalObjMethod(event);
        }
        this.princiBussiAddress = { ...this.princiBussiAddress, ...event.detail }
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
    }

    handleChildOfficeData(event) {
        this.officeAddress = { ...this.officeAddress, ...event.detail }
        this.officeAddresscheckbox = event.detail.MailAddr__c;
        this.checkForMultipleSelection();
        if (this.selectedCount > 1 && this.officeAddresscheckbox) {
            this.showerror = true;
        } else {
            this.showerror = false;
        }
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

    handleCheckboxSelect(event) {
        this.isAddressSame = event.target.checked
        let perId = this.permanentAddress.Id
        let perAddType = this.permanentAddress.AddrTyp__c ? this.permanentAddress.AddrTyp__c : 'Permanent Address';
        if (this.isAddressSame) {
            if (this.isEmptyObject(this.residenceAddress)) {
                event.target.checked = false;
                this.showToastMessage('Error', this.label.ApplicantDetails_ResidenceAdd_ErrorMessage, 'error', 'sticky');
            } else {
                let copy_residenceAddress = { ...this.residenceAddress };
                copy_residenceAddress.MailAddr__c = false;//LAK-6444
                this.permanentAddress = copy_residenceAddress
            }

        } else {
            this.permanentAddress = {}
        }
        this.permanentAddress.Id = perId
        this.permanentAddress.AddrTyp__c = perAddType
        this.permanentAddress.isPerSameAsResi_ADD__c = this.isAddressSame;
        this.addFlag = this.isAddressSame
    }


    handleCheckboxSelectForRegiAddress(event) {
        this.isRegiAddressSame = event.target.checked;
        let regId = this.regiBussiAddress.Id
        let regAddType = this.regiBussiAddress.AddrTyp__c ? this.regiBussiAddress.AddrTyp__c : 'Registered place for business';
        if (this.isRegiAddressSame) {
            if (this.isEmptyObject(this.princiBussiAddress)) {
                event.target.checked = false;
                this.showToastMessage('Error', this.label.ApplicantDetails_PrincipalBusineesAdd_ErrorMessage, 'error', 'sticky');
            } else {
                let copy_princiBussiAddress = { ...this.princiBussiAddress };
                copy_princiBussiAddress.MailAddr__c = false;//LAK-6444
                this.regiBussiAddress = copy_princiBussiAddress
            }
        } else {
            this.regiBussiAddress = {}
        }
        this.regiBussiAddress.Same_as_Principal_place_for_business__c = this.isRegiAddressSame
        this.regiBussiAddress.Id = regId
        this.regiBussiAddress.AddrTyp__c = regAddType
        this.addRegiFlag = this.isRegiAddressSame
    }

    validateRegistrationNumberPattern() {
        if ((this.wrapObj.ProfQual__c && this.wrapObj.ProfQual__c.includes('ART')) || this.wrapObj.EduQual__c === "ARC") {
            this.registrationNumberPattern = "^[A-Z]{2}/[0-9]{4}/[0-9]{5}$"
            this.registrationNumberHelpText = "Please Enter in this valid ex:- AM/1012/19998 format."
        } else if ((this.wrapObj.ProfQual__c && this.wrapObj.ProfQual__c.includes("DOC")) || this.wrapObj.EduQual__c === "DOC") {
            this.registrationNumberPattern = "^[a-zA-Z0-9]{1,255}$"
            this.registrationNumberHelpText = "Please Enter a Valid Value"
        } else {
            this.registrationNumberPattern = "^[a-zA-Z0-9]+$"
            this.registrationNumberHelpText = "Please Enter a Valid Value"
        }
    }
    @track requiredResgisYear;
    validateYearOfRegistrationPattern() {
        if (this.wrapObj.ProfQual__c && this.wrapObj.ProfQual__c.includes("DOC")) {
            this.yearOfRegistrationPattern = "^(19|20)\\d{2}$"
            this.yearOfRegistrationHelpText = "Please Enter a Valid Value format ex:- 1999."
        } else {
            this.yearOfRegistrationPattern = "^[0-9]{4}$"
            this.yearOfRegistrationHelpText = "Please Enter a Valid 4-digit Number."
        }


    }

    validateMembershipNumberPattern() {
        if (this.wrapObj.ProfQual__c && this.wrapObj.ProfQual__c.includes("CA")) {
            this.membershipNumberPattern = "^[0-9]{6}$"
            this.membershipNumberHelpText = "Please Enter Valid 6-digit Numbers."
        } else if (this.wrapObj.ProfQual__c && this.wrapObj.ProfQual__c.includes("ICWAI")) {
            this.membershipNumberPattern = "^\\d{2,5}$"
            this.membershipNumberHelpText = "Please Enter Valid 2-5 digit Numbers."
        } else {
            this.membershipNumberPattern = "^[a-zA-Z0-9]+$"
            this.membershipNumberHelpText = "Please Enter Valid Value."
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
        return validate
    }

    checkValidityLookup() {
        let isInputCorrect = true;
        let allChilds = this.template.querySelectorAll("c-capture-applicant-address-details");
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

        //LAK-7867
        if (!this.identityProofNumber || !this.identityProofType) {
            this.showToastMessage('Error', 'Please update ID details from the PAN & KYC Page', 'error', 'sticky');
            isValid = false;
        }

        if (this.wrapObj.Type_of_Borrower__c === 'Financial' && this.wrapObj.CustProfile__c === 'SALARIED' && this.wrapObj.Constitution__c === 'INDIVIDUAL') {
            if (this.isEmptyObject(this.residenceAddress) && this.isEmptyObject(this.officeAddress)) {
                this.isResReq = true
                this.isOffice = true
                this.showToastMessage('Error', this.label.ApplicantDetails_ResidenceBusineesAdd_ErrorMessage, 'error', 'sticky');
                isValid = false;
            } else if (this.isEmptyObject(this.officeAddress)) {
                this.isOffice = true
                this.showToastMessage('Error', this.label.ApplicantDetails_OfficeAdd_ErrorMessage, 'error', 'sticky');
                isValid = false;
            } else if (this.isEmptyObject(this.residenceAddress)) {
                this.isResReq = true
                this.showToastMessage('Error', this.label.ApplicantDetails_ResidenceAddMandatory_ErrorMessage, 'error', 'sticky');
                isValid = false;
            }

            else {
                this.isResReq = true
                this.isOffice = true
                //isValid = true;
            }
        }
        if (this.wrapObj.Type_of_Borrower__c === 'Financial' && (this.wrapObj.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || this.wrapObj.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') && this.wrapObj.Constitution__c === 'INDIVIDUAL') {
            if (this.isEmptyObject(this.resiCusOfficeAddress)) {
                if (this.isEmptyObject(this.residenceAddress)) {
                    this.isResReq = true
                    this.showToastMessage('Error', this.label.ApplicantDetails_ResidenceAddMandatory_ErrorMessage, 'error', 'sticky');
                    isValid = false;
                } else if (this.isEmptyObject(this.princiBussiAddress)) {
                    this.isPrinciBussiAddress = true
                    this.showToastMessage('Error', this.label.ApplicantDetails_PrincipalBusineesAddReq_ErrorMessage, 'error', 'sticky');
                    isValid = false;
                } else {
                    this.isResReq = true
                    this.isPrinciBussiAddress = true
                    //isValid = true;
                }
            }
        }
        if ((this.wrapObj.Type_of_Borrower__c === 'Financial' || this.wrapObj.Type_of_Borrower__c === 'Non Financial') && (this.wrapObj.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || this.wrapObj.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') &&
            (this.wrapObj.Constitution__c === 'HUF' || this.wrapObj.Constitution__c === 'SOCIETY' || this.wrapObj.Constitution__c === 'PROPERITORSHIP')) {
            if (this.isEmptyObject(this.princiBussiAddress)) {
                this.isPrinciBussiAddress = true
                this.showToastMessage('Error', this.label.ApplicantDetails_PrincipalBusineesAddReq_ErrorMessage, 'error', 'sticky');
                isValid = false;
            } else {
                this.isPrinciBussiAddress = true
            }
        }
        if (this.wrapObj.Type_of_Borrower__c === 'Non Financial' && this.wrapObj.CustProfile__c === 'SALARIED' && this.wrapObj.Constitution__c === 'INDIVIDUAL') {
            if (this.isEmptyObject(this.residenceAddress)) {
                this.isResReq = true
                this.showToastMessage('Error', this.label.ApplicantDetails_ResidenceAddMandatory_ErrorMessage, 'error', 'sticky');
                isValid = false;
            } else {
                this.isResReq = true
            }
        }
        if (this.wrapObj.Type_of_Borrower__c === 'Non Financial' && (this.wrapObj.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || this.wrapObj.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') && this.wrapObj.Constitution__c === 'INDIVIDUAL') {
            if (this.isEmptyObject(this.resiCusOfficeAddress)) {
                if (this.isEmptyObject(this.residenceAddress)) {
                    this.isResReq = true
                    this.showToastMessage('Error', this.label.ApplicantDetails_ResidenceAddMandatory_ErrorMessage, 'error', 'sticky');
                    isValid = false;
                }
            } else {
                this.isResReq = true
            }
        }
        if ((this.wrapObj.Type_of_Borrower__c === 'Financial' || this.wrapObj.Type_of_Borrower__c === 'Non Financial') && (this.wrapObj.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || this.wrapObj.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') &&
            (this.wrapObj.Constitution__c === 'PRIVATE LIMITED COMPANY' || this.wrapObj.Constitution__c === 'TRUST' || this.wrapObj.Constitution__c === 'PUBLIC LIMITED COMPANY' ||
                this.wrapObj.Constitution__c === 'PARTNERSHIP' || this.wrapObj.Constitution__c === 'LIMITED LIABILITY PARTNERSHIP' || this.wrapObj.Constitution__c === 'ASSOCIATION OF PERSONS')) {
            if (this.isEmptyObject(this.princiBussiAddress)) {
                this.isPrinciBussiAddress = true
                this.showToastMessage('Error', this.label.ApplicantDetails_PrincipalBusineesAddReq_ErrorMessage, 'error', 'sticky');
                isValid = false;
            } else if (this.isEmptyObject(this.regiBussiAddress)) {
                this.isRegiBussiAddress = true
                this.showToastMessage('Error', this.label.ApplicantDetails_BusineesPlaceReq_ErrorMessage, 'error', 'sticky');
                isValid = false;
            }

            else {
                this.isPrinciBussiAddress = true
                this.isRegiBussiAddress = true
            }
        }
        if (this.wrapObj.Type_of_Borrower__c === 'Non Financial' && (this.wrapObj.CustProfile__c === "HOUSEWIFE" || this.wrapObj.CustProfile__c === "OTHERS") && this.wrapObj.Constitution__c === 'INDIVIDUAL') {
            if (this.isEmptyObject(this.residenceAddress)) {
                this.isResReq = true
                this.showToastMessage('Error', this.label.ApplicantDetails_ResidenceAddMandatory_ErrorMessage, 'error', 'sticky');
                isValid = false;
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

        //LAK-9244
        if (this.userTeamRoleData && (CPARoles && CPARoles.includes(this.userTeamRoleData))) {
            if ((!this.wrapObj.PAN__c || !this.wrapObj.ID_proof_type__c || !this.wrapObj.ID_Number__c) && this.wrapObj.Type_of_Borrower__c === 'Financial') {
                this.showToastMessage('Error', this.label.ApplicantDetails_PAN_ErrorMessage, 'error', 'sticky');
                isValid = false
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
            if (this.regiBussiAddress.Same_as_Principal_place_for_business__c) {//LAK-6444
                this.regiBussiAddress.MailAddr__c = false;
            }//LAK-6444
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
        if (adddresRecords && adddresRecords.length > 0) {
            for (var i = 0; i < adddresRecords.length; i++) {
                if (adddresRecords[i].MailAddr__c) {
                    counter++;
                }
            }
        }
        return counter;
    }


    parentRecords = [];
    probeData = [];
    disableCIN = false;
    disableLLP = false;
    getProbeDetails() {
        this.parentRecords = [];
        this.childRecords = [];
        let isprob42 = 'Probe42';
        let params = {
            ParentObjectName: 'APIVer__c',
            ChildObjectRelName: 'API_Verification_Details__r',
            parentObjFields: ['Id', 'Type__c', 'Invalid__c', 'Appl__c', 'Appl__r.CompanyName__c', 'Appl__r.FullName__c', 'toLabel(Appl__r.ApplType__c)', 'Appl__r.Constitution__c', 'Appl__r.PAN__c', 'Name_Match_Score__c', 'Classification__c', 'DataStatus__c', 'EfilingStatus__c', 'DteOfIncorp__c', 'AuthorizedCapital__c', 'PaidupCapital__c', 'Verification_Status__c', 'IntegrationErrorMessage__c', 'RetriggerRationale__c', 'Address__c', 'PanCinDin__c', 'Llpin__c', 'IntegrationStatus__c', 'UW_Manual_Verification__c', 'ActionedDate__c', 'UserName__c', 'UserNameRole__c'],
            childObjFields: ['Id'],
            queryCriteria: ' where Appl__c = \'' + this.recordId + '\' AND RecordType.Name = \'' + isprob42 + '\' AND IsLatest__c = true AND Type__c IN (\'Probe Basic Company\',\'Probe Basic LLP\')'
        }
        getSobjectData({ params: params })
            .then((result) => {
                if (result) {

                    this.probeData = result;
                    console.log(' this.wrapObj.CIN__c.  ::254 ', this.oldCIN);
                    if (this.probeData.parentRecords && this.probeData.parentRecords.length > 0) {
                        if (this.probeData.parentRecords[0].IntegrationStatus__c === 'Success' && this.oldCIN) {
                            this.disableCIN = true;
                        }
                        else {
                            this.disableCIN = false;
                        }

                        if (this.probeData.parentRecords[0].IntegrationStatus__c === 'Success' && this.oldLLPIN) {
                            this.disableLLP = true;
                        }
                        else {
                            this.disableLLP = false;
                        }
                    }
                    else {
                        this.disableCIN = false;
                    }
                    console.log(' this.parentRecords.  ::254 ', result);
                }
            })
            .catch((error) => {
                console.log('Error In getting Api Verification Data is ', JSON.stringify(error));
            });
    }

    expiryDates() {
        const currentDate = new Date();
        const currentDay = currentDate.getDate();
        const currentMonth = currentDate.getMonth();
        const currentYear = currentDate.getFullYear();

        const passportExpDate = this.wrapObj.PassportExpDate__c ? new Date(this.wrapObj.PassportExpDate__c) : null;
        const drivingLicExpDate = this.wrapObj.DrivingLicExpDate__c ? new Date(this.wrapObj.DrivingLicExpDate__c) : null;

        if (this.passExpDateVisbl) {
            if (passportExpDate) {
                const passportDay = passportExpDate.getDate();
                const passportMonth = passportExpDate.getMonth();
                const passportYear = passportExpDate.getFullYear();
                if (passportYear < currentYear ||
                    (passportYear === currentYear && passportMonth < currentMonth) ||
                    (passportYear === currentYear && passportMonth === currentMonth && passportDay < currentDay)) {
                    this.showToastMessage('Error', 'Passport has expired.', 'error', 'sticky');

                    return false;
                }
            }
        }

        if (this.drvLicExpDateVisbl) {
            if (drivingLicExpDate) {
                const drivingLicDay = drivingLicExpDate.getDate();
                const drivingLicMonth = drivingLicExpDate.getMonth();
                const drivingLicYear = drivingLicExpDate.getFullYear();
                if (drivingLicYear < currentYear ||
                    (drivingLicYear === currentYear && drivingLicMonth < currentMonth) ||
                    (drivingLicYear === currentYear && drivingLicMonth === currentMonth && drivingLicDay < currentDay)) {
                    this.showToastMessage('Error', 'Driving License has expired.', 'error', 'sticky');
                    return false;
                }
            }
        }


        return true; // Both dates are in the future or null
    }

    @track intProbRecords = [];

    checkProbeReInt() {

        //LAK-9823 START
        console.log('LAK-9823 START', this.wrapObj.Constitution__c)
        if (this.wrapObj.Constitution__c === 'PRIVATE LIMITED COMPANY' || this.wrapObj.Constitution__c === 'PUBLIC LIMITED COMPANY') {
            if (this.wrapObj.CIN__c && this.oldCIN != this.wrapObj.CIN__c) {
                this.createIntMsg('Company Base Details');
            }
        }
        else if (this.wrapObj.Constitution__c === 'LIMITED LIABILITY PARTNERSHIP') {
            console.log('LAK-9823 this.wrapObj.LLPIN__c ', this.wrapObj.LLPIN__c)
            console.log('LAK-9823 this.oldLLPIN ', this.oldLLPIN)
            if (this.wrapObj.LLPIN__c && this.oldLLPIN != this.wrapObj.LLPIN__c) {
                this.createIntMsg('LLP Base Details');
            }
        }
        //LAK-9823 END
    }
    createIntMsg(serviceName) {

        this.intProbRecords = [];
        let fields = {};
        fields['sobjectType'] = 'IntgMsg__c';
        fields['Name'] = serviceName;
        fields['BU__c'] = 'HL / STL';
        fields['IsActive__c'] = true;
        fields['Svc__c'] = serviceName;
        fields['Status__c'] = 'New';
        fields['Mresp__c'] = 'Blank';
        fields['Trigger_Platform_Event__c'] = false;
        fields['RefObj__c'] = 'Applicant__c';
        fields['RefId__c'] = this.recordId;
        fields['ParentRefObj__c'] = "LoanAppl__c";
        fields['ParentRefId__c'] = this.loanAppId;
        // fields['RetriRatinal__c'] = item.RationalRemarks;
        this.intProbRecords.push(fields);

        console.log('intProbRecords are', JSON.stringify(this.intProbRecords));
        //this.upsertIntRecord(this.intRecords);
        console.log('int msgs records ', JSON.stringify(this.intProbRecords));
        upsertMultipleRecord({ params: this.intProbRecords })
            .then((result) => {
                console.log('Result after creating Int Msgs is ', JSON.stringify(result));
                this.showToastMessage('Success', serviceName + ' Initiated Successfully.', 'Success', 'sticky')
                this.oldLLPIN = this.wrapObj.LLPIN__c;
                this.oldCIN = this.wrapObj.CIN__c;
            })
            .catch((error) => {
                console.log('Error In creating Record', error);
                this.showSpinner = false;
            });
    }

    handleSave(validate) {
        if (validate) {
            let isInputCorrect = this.validateForm();
            if (isInputCorrect === true) {
                //if(this.identityProofNumber && this.identityProofType){

                var totalSelectedMailingAddress = this.formulateChildAddressRecords();

                if (totalSelectedMailingAddress > 1) {
                    this.showToastMessage('Error', this.label.ApplicantDetails_multMailAdd_ErrorMessage, 'error', 'sticky')
                } else if (totalSelectedMailingAddress === 0) {
                    this.showToastMessage('Error', this.label.NoApplicantAddressMailing_ErrorMessage, 'error', 'sticky')
                } else if (this.consentProvided === false) {
                    this.showToastMessage('Error', this.label.ApplicantDetails_Consent_ErrorMessage, 'error', 'sticky');
                }
                else if (this.expiryDates() == false) {
                } else {

                    // this.checkPanNoAccConstitution();// adde  For LAK-7603
                    let checkPanNoStatus = true;
                    this.handleUpsert(checkPanNoStatus);
                }

                if (this.wrapObj.BorrowerPreferredLanguage__c) {
                    this.disableBrowPefLan = true;
                }
            } else {
                this.showToastMessage('Error', this.label.ALL_FIELDS_Label, 'error', 'sticky');
            }

        } else {
            if (this.regiBussiAddress.Same_as_Principal_place_for_business__c) {//LAK-6444
                this.regiBussiAddress.MailAddr__c = false;
            }//LAK-6444

            if (this.wrapObj.BorrowerPreferredLanguage__c) {
                this.disableBrowPefLan = true;
            }

            // this.checkPanNoAccConstitution();// adde  For LAK-7603
            let checkPanNoStatus = false;
            this.handleUpsert(checkPanNoStatus);
            if (this.applicantType) {
                if (this.applicantType === 'APPLICANT') {
                    this.showToastMessage('Success', this.label.APPLICANT_SUCCESS_Label, 'success', 'sticky')
                } else if ((this.applicantType === 'CO-APPLICANT' || this.applicantType === 'GUARANTOR') && this.wrapObj.ApplType__c !== undefined) {
                    this.showToastMessage('Success', this.label.ApplicantDetails_CoApp_SuccesMessage, 'success', 'sticky')
                }
                /*else {
                    this.showToastMessage('Success', this.label.APPLICANT_SUCCESS_Label, 'success', 'sticky')
                }*/
            } else {
                this.showToastMessage('Success', this.label.APPLICANT_SUCCESS_Label, 'success', 'sticky')
            }
        }
    }
    //// adde  For LAK-7603
    checkPanNoAccConstitution() {
        let ApplicantData = {
            Id: this.wrapObj.Id,
        };
        let appList = [];
        appList.push(ApplicantData);
        if (appList[0].Id != null) {
            checkPanNoStatus({ newList: appList })
                .then(data => {
                    if (data) {
                        const subDocList = Object.entries(data).map(([subDocName, subDocValues]) => {
                            return { subDocName, subDocValues };
                        });

                        if (subDocList.length > 0) {
                            subDocList.forEach(element => {
                                this.showToastMessage('Error', element.subDocName + ' : ' + element.subDocValues, 'error', 'sticky');
                            });

                        } else {

                            if (this.applicantType) {
                                if (this.applicantType === 'APPLICANT') {
                                    this.showToastMessage('Success', this.label.APPLICANT_SUCCESS_Label, 'success', 'sticky')
                                } else if ((this.applicantType === 'CO-APPLICANT' || this.applicantType === 'GUARANTOR') && this.wrapObj.ApplType__c !== undefined) {
                                    this.showToastMessage('Success', this.label.ApplicantDetails_CoApp_SuccesMessage, 'success', 'sticky')
                                }
                                this.checkProbeReInt();
                                /*else {
                                    this.showToastMessage('Success', this.label.APPLICANT_SUCCESS_Label, 'success', 'sticky')
                                }*/
                            } else {
                                this.showToastMessage('Success', this.label.APPLICANT_SUCCESS_Label, 'success', 'sticky')
                                this.checkProbeReInt();
                            }
                        }
                    }
                })
                .catch(error => {
                    this.showToastMessage('Error', 'Error in validating rec', 'error', 'sticky');
                })
        }
    }// adde  For LAK-7603

    isEmptyObject(obj) {
        return Object.keys(obj).length === 0;
    }

    context = createMessageContext();
    publishMC(recordId) {
        const messageChannelMessage = {
            recordId: recordId,
            message: "Co Applicant Created"
        };
        publish(this.context, RECORDCREATE, messageChannelMessage);
    }

    unsubscribeMC() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    disconnectedCallback() {
        this.unsubscribeMC();
        releaseMessageContext(this.context);
    }

    childRecordsContainer() {
        this.ChildRecords = [];
        if (!this.isEmptyObject(this.residenceAddress)) {
            this.residenceAddress.sobjectType = 'ApplAddr__c';
            this.residenceAddress.AddrTyp__c = this.residenceAddress.AddrTyp__c ? this.residenceAddress.AddrTyp__c : 'Residence Address';
            this.ChildRecords.push(this.residenceAddress);
        }
        if (!this.isEmptyObject(this.permanentAddress)) {
            this.permanentAddress.sobjectType = 'ApplAddr__c';
            this.permanentAddress.AddrTyp__c = this.permanentAddress.AddrTyp__c ? this.permanentAddress.AddrTyp__c : 'Permanent Address';
            this.ChildRecords.push(this.permanentAddress);
        }
        if (!this.isEmptyObject(this.resiCusOfficeAddress)) {
            this.resiCusOfficeAddress.sobjectType = 'ApplAddr__c';
            this.resiCusOfficeAddress.AddrTyp__c = this.resiCusOfficeAddress.AddrTyp__c ? this.resiCusOfficeAddress.AddrTyp__c : 'Residence Cum office';
            this.ChildRecords.push(this.resiCusOfficeAddress);
        }
        if (!this.isEmptyObject(this.regiBussiAddress)) {
            this.regiBussiAddress.sobjectType = 'ApplAddr__c';
            this.regiBussiAddress.AddrTyp__c = this.regiBussiAddress.AddrTyp__c ? this.regiBussiAddress.AddrTyp__c : 'Registered place for business';
            this.ChildRecords.push(this.regiBussiAddress);
        }
        if (!this.isEmptyObject(this.princiBussiAddress)) {
            this.princiBussiAddress.sobjectType = 'ApplAddr__c';
            this.princiBussiAddress.AddrTyp__c = this.princiBussiAddress.AddrTyp__c ? this.princiBussiAddress.AddrTyp__c : 'Principal place for business';
            this.ChildRecords.push(this.princiBussiAddress);
        }
        if (!this.isEmptyObject(this.otherAddress)) {
            this.otherAddress.sobjectType = 'ApplAddr__c';
            this.otherAddress.AddrTyp__c = this.otherAddress.AddrTyp__c ? this.otherAddress.AddrTyp__c : 'Other Address';
            this.ChildRecords.push(this.otherAddress);
        }
        if (!this.isEmptyObject(this.officeAddress)) {
            this.officeAddress.sobjectType = 'ApplAddr__c';
            this.officeAddress.AddrTyp__c = this.officeAddress.AddrTyp__c ? this.officeAddress.AddrTyp__c : 'Office Address';
            this.ChildRecords.push(this.officeAddress);
        }
    }

    @track isClick = false;

    handleUpsert(checkPanNoStatus) {
        if (this.isClick) {
            return isClick;
        }

        this.isClick = true;
        this.showSpinner = true;
        this.childRecordsContainer();
        this.wrapObj.sobjectType = 'Applicant__c';
        console.log('this.wrapObj ===', this.wrapObj)
        if (this.wrapObj.EmailId__c != null) {
            if (this.wrapObj.EmailId__c) {
                const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
                let emailVal = this.wrapObj.EmailId__c;
                let emailVer = this.ristrictedEmailDomain.some(domain => emailVal.endsWith(domain));//LAK-7889

                if (!(emailVal.match(emailRegex) && emailVer == false)) {
                    console.log("Please enter valid email .......");
                    this.showToastMessage('Error', 'Please enter valid email', 'error', 'sticky');
                    this.showSpinner = false;
                    return;
                }
            }
        }
        console.log('this.wrapObj === 123', this.wrapObj)

        if (this.applicantType !== 'APPLICANT') {
            if (!this.wrapObj.LoanAppln__c) {
                this.wrapObj.LoanAppln__c = this.loanAppId ? this.loanAppId : null;
            }
        }
        //LAK-517
        if (this.emailIdVerStatus && this.emailIdVerStatus !== 'Initiated' && this.oldEmail !== this.wrapObj.EmailId__c) {
            this.wrapObj.EmailIDverificationStatus__c = 'Changed';
        }
        //LAK-223
        if (this.quaCheckVerStatus && this.quaCheckVerStatus !== 'Initiated' && this.oldProfQual !== this.wrapObj.ProfQual__c && this.wrapObj.ProfQual__c === 'CA') {
            this.wrapObj.CAVerStatus__c = 'Changed';
        }
        //LAK-223
        if (this.quaCheckVerStatusDoc && this.quaCheckVerStatusDoc !== 'Initiated' && this.oldProfQual !== this.wrapObj.ProfQual__c && this.wrapObj.ProfQual__c === 'ART') {
            this.wrapObj.ArchVerStatus__c = 'Changed';
        }
        //LAK-223
        if (this.quaCheckVerStatusArch && this.quaCheckVerStatusArch !== 'Initiated' && this.oldProfQual !== this.wrapObj.ProfQual__c && (this.wrapObj.ProfQual__c === 'DOC' || this.wrapObj.ProfQual__c === 'DOCBM' || this.wrapObj.ProfQual__c === 'DOCB')) {
            this.wrapObj.DoctorApiVerStatus__c = 'Changed';
        }
        if (this.oldMobileNumber != this.wrapObj.MobNumber__c) {
            this.wrapObj.OTP_Verified__c = false;
            this.wrapObj.DigitalVerified__c = false;
            this.wrapObj.Is_OTP_Limit_Reached__c = false;
        }
        if (this.ChildRecords && this.ChildRecords.length > 0) {
            this.ChildRecords.forEach(item => {
                if (!item.LoanAppl__c) {
                    item.LoanAppl__c = this.loanAppId ? this.loanAppId : null;
                }
            })
        }
        let upsertData = {
            parentRecord: this.wrapObj,
            ChildRecords: this.ChildRecords,
            ParentFieldNameToUpdate: 'Applicant__c'
        }
        this.callSubscribePlatformEve();
        if ((this.applicantType === 'CO-APPLICANT' || this.applicantType === 'GUARANTOR') && this.wrapObj.ApplType__c === undefined) {
            this.showToastMessage('Error', this.label.Verify_Details_Required_fields_Error_Msg, 'error', 'sticky');
            this.isClick = false;
            this.showSpinner = false;
        }
        else {
            upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
                .then(result => {
                    console.log('this result received==', result)
                    if (this._recordId) {
                        let tempParamsApplicant = this.applicantParams;
                        tempParamsApplicant.queryCriteria = ' where Id = \'' + this._recordId + '\'';
                        this.applicantParams = { ...tempParamsApplicant };
                        console.log('app data ::', this.applicantParams)
                        this.getNonCachedApplicantData();
                    }
                    if (result.parentRecord && result.parentRecord.Id && result.parentRecord.ApplType__c !== 'P') {
                        this.wrapObj.Id = result.parentRecord.Id;
                        this.publishMC(result.parentRecord.Id);
                    }

                    //LAK-9715 changes Start
                    console.log('this.wrapObj.LoanAppln__r.Product__c =',this.wrapObj.LoanAppln__r.Product__c)
                    console.log('result.parentRecord.ApplType__c =',result.parentRecord.ApplType__c)

                    if ((this.wrapObj.LoanAppln__r.Product__c === 'Business Loan' || this.wrapObj.LoanAppln__r.Product__c === 'Personal Loan') && (result.parentRecord.ApplType__c == 'P' || result.parentRecord.ApplType__c == 'C' || result.parentRecord.ApplType__c == 'G')) {
                        this.checkAPIToRun();
                    }
                    else if (this.wrapObj.LoanAppln__r.LMSUpdTrig__c && (result.parentRecord.ApplType__c == 'C' || result.parentRecord.ApplType__c == 'G')) {
                        this.checkAPIToRun();
                    }
                    //LAK-9715 changes End
                    refreshApex(this.wiredData);
                    refreshApex(this.wiredAppAddressData);
                    this.isClick = false;
                    this.showSpinner = false;
                    // this.showSpinner = false
                    if (checkPanNoStatus === true) {
                        this.checkPanNoAccConstitution();// adde  For LAK-7603
                    }
                    console.log('creating intg msg ::')
                    this.createEmailIntegrationMsg();//LAK-517
                })
                .catch(error => {

                    this.isClick = false;
                    this.showSpinner = false;

                })
        }
    }

    @track intRecordsNew = [];
    createEmailIntegrationMsg() {
        console.log('createEmailIntegrationMsg :this.emailIdVerStatus : ', this.emailIdVerStatus)
        if (!this.emailIdVerStatus) {
            let contain = this.basicEmailCodes.some(code => this.wrapObj.EmailId__c != null && this.wrapObj.EmailId__c.includes(code));
            let serviceName;
            if (contain) {
                console.log('createEmailIntegrationMsg :this.emailIdVerStatus : contain true')
                serviceName = 'Email Verification';
            } else {
                serviceName = 'Email Authentication Advanced';
            }
            let fields = {};
            fields['sobjectType'] = 'IntgMsg__c';
            fields['Name'] = serviceName;//'Email Verification'; 
            fields['BU__c'] = 'HL / STL';
            fields['IsActive__c'] = true;
            fields['Svc__c'] = serviceName;//'Email Verification'; 
            fields['Status__c'] = 'New';
            fields['RefObj__c'] = 'Applicant__c';
            fields['RefId__c'] = this.recordId;
            this.intRecordsNew.push(fields);

            let appFields = {};
            appFields['sobjectType'] = 'Applicant__c';
            appFields['Id'] = this.recordId;
            appFields['EmailIDverificationStatus__c'] = 'Initiated';
            this.intRecordsNew.push(appFields);
        }
        if (!this.quaCheckVerStatus && this.wrapObj.ProfQual__c && this.wrapObj.ProfQual__c === 'CA') {
            console.log('createEmailIntegrationMsg : CA')
            let fields = {};
            fields['sobjectType'] = 'IntgMsg__c';
            fields['Name'] = 'CA Membership Authentication';
            fields['BU__c'] = 'HL / STL';
            fields['IsActive__c'] = true;
            fields['Svc__c'] = 'CA Membership Authentication';
            fields['Status__c'] = 'New';
            fields['RefObj__c'] = 'Applicant__c';
            fields['RefId__c'] = this.recordId;
            this.intRecordsNew.push(fields);

            let obj = this.intRecordsNew.find(item => item.Id === this.recordId);
            if (obj) {
                obj.CAVerStatus__c = 'Initiated';
            } else {
                let appFields = {};
                appFields['sobjectType'] = 'Applicant__c';
                appFields['Id'] = this.recordId;
                appFields['CAVerStatus__c'] = 'Initiated';
                //    this.quaCheckVerStatus = 'Initiated';
                this.intRecordsNew.push(appFields);
            }
        } else if (!this.quaCheckVerStatusArch && this.wrapObj.ProfQual__c && this.wrapObj.ProfQual__c === 'ART') {
            console.log('createEmailIntegrationMsg : ARt')
            let fields = {};
            fields['sobjectType'] = 'IntgMsg__c';
            fields['Name'] = 'Architect Authentication';
            fields['BU__c'] = 'HL / STL';
            fields['IsActive__c'] = true;
            fields['Svc__c'] = 'Architect Authentication';
            fields['Status__c'] = 'New';
            fields['RefObj__c'] = 'Applicant__c';
            fields['RefId__c'] = this.recordId;
            this.intRecordsNew.push(fields);

            let obj = this.intRecordsNew.find(item => item.Id === this.recordId);
            if (obj) {
                obj.ArchVerStatus__c = 'Initiated';
            } else {
                let appFields = {};
                appFields['sobjectType'] = 'Applicant__c';
                appFields['Id'] = this.recordId;
                appFields['ArchVerStatus__c'] = 'Initiated';
                //    this.quaCheckVerStatus = 'Initiated';
                this.intRecordsNew.push(appFields);
            }
            //|| this.wrapObj.ProfQual__c === 'DOCS' added for LAK-9864
        } else if (!this.quaCheckVerStatusDoc && this.wrapObj.ProfQual__c && (this.wrapObj.ProfQual__c === 'DOC' || this.wrapObj.ProfQual__c === 'DOCBM' || this.wrapObj.ProfQual__c === 'DOCB' || this.wrapObj.ProfQual__c === 'DOCS')) {
            console.log('createEmailIntegrationMsg : DOC')
            let fields = {};
            fields['sobjectType'] = 'IntgMsg__c';
            fields['Name'] = 'NMC Membership Authentication';
            fields['BU__c'] = 'HL / STL';
            fields['IsActive__c'] = true;
            fields['Svc__c'] = 'NMC Membership Authentication';
            fields['Status__c'] = 'New';
            fields['RefObj__c'] = 'Applicant__c';
            fields['RefId__c'] = this.recordId;
            this.intRecordsNew.push(fields);

            let obj = this.intRecordsNew.find(item => item.Id === this.recordId);
            if (obj) {
                obj.DoctorApiVerStatus__c = 'Initiated';
            } else {
                let appFields = {};
                appFields['sobjectType'] = 'Applicant__c';
                appFields['Id'] = this.recordId;
                appFields['DoctorApiVerStatus__c'] = 'Initiated';
                //    this.quaCheckVerStatus = 'Initiated';
                this.intRecordsNew.push(appFields);
            }
        }
        if (this.intRecordsNew && this.intRecordsNew.length > 0) {
            this.upsertIntRecord(this.intRecordsNew);
        }
    }
    intMsgIds = [];
    upsertIntRecord(intRecords) {
        upsertMultipleRecord({ params: intRecords })
            .then((result) => {
                result.forEach(item => {
                    this.intMsgIds.push(item.Id);
                })
                this.intRecordsNew = [];
            })
            .catch((error) => {
                this.showSpinner = false;

            });
    }

    isResReq = false;
    isPerReq = false;

    closeModal() {
        this.isModalOpen = false;
    }

    deleteResidenceRecord() {
        this.addTypeName = 'Residence'
        this.deleteAddressMsg = `Do you want to delete the ${this.addTypeName} Address?`;
        this.isModalOpen = true;
    }
    deletePermanentRecord() {
        this.addTypeName = 'Permanent'
        this.deleteAddressMsg = `Do you want to delete the ${this.addTypeName} Address?`;
        this.isModalOpen = true;
    }
    deleteResCumOffRecord() {
        this.addTypeName = 'Residence Cum office'
        this.deleteAddressMsg = `Do you want to delete the ${this.addTypeName} Address?`;
        this.isModalOpen = true;
    }
    deleteRegBussRecord() {
        this.addTypeName = 'Registered place for business'
        this.deleteAddressMsg = `Do you want to delete the ${this.addTypeName} Address?`;
        this.isModalOpen = true;
        this.isRegiAddressSame = false;
    }
    deletePrinBussRecord() {
        this.addTypeName = 'Principal place for business'
        this.deleteAddressMsg = `Do you want to delete the ${this.addTypeName} Address?`;
        this.isModalOpen = true;
    }
    deleteOtherAddRecord() {
        this.addTypeName = 'Other'
        this.deleteAddressMsg = `Do you want to delete the ${this.addTypeName} Address?`;
        this.isModalOpen = true;
    }
    deleteOfficeAddRecord() {
        this.addTypeName = 'Office'
        this.deleteAddressMsg = `Do you want to delete the ${this.addTypeName} Address?`;
        this.isModalOpen = true;
    }

    handleRemoveRecord() {
        if (this.addTypeName === 'Residence') {
            this.removeAddressOnDelete(this.ChildRecords, 'AddrTyp__c', 'Residence Address')
            this.deleteAddressRecord(this.residenceAddress.Id)
            this.is_Open_Res_add = false
            this.isResReq = false
            this.residenceAddress = {}
            if (this.isAddressSame) {
                this.removeAddressOnDelete(this.ChildRecords, 'AddrTyp__c', 'Permanent Address')
                this.deleteAddressRecord(this.permanentAddress.Id)
                this.is_Open_Per_add = false
                this.isPerReq = false;
                this.permanentAddress = {}
                this.addFlag = false
                this.isAddressSame = false
                this.handleAddressOptions(this.wrapObj);
            }
            this.handleAddressOptions(this.wrapObj);
        } else if (this.addTypeName === 'Permanent') {
            this.removeAddressOnDelete(this.ChildRecords, 'AddrTyp__c', 'Permanent Address')
            this.deleteAddressRecord(this.permanentAddress.Id)
            this.is_Open_Per_add = false
            this.isPerReq = false;
            this.permanentAddress = {}
            this.addFlag = false
            this.isAddressSame = false
            this.handleAddressOptions(this.wrapObj);
        } else if (this.addTypeName === 'Residence Cum office') {
            this.removeAddressOnDelete(this.ChildRecords, 'AddrTyp__c', 'Residence Cum office')
            this.deleteAddressRecord(this.resiCusOfficeAddress.Id)
            this.is_Open_Res_Cum_add = false
            this.isResiCusOfficeAddress = false
            this.resiCusOfficeAddress = {}
            this.handleAddressOptions(this.wrapObj);
        } else if (this.addTypeName === 'Registered place for business') {
            this.removeAddressOnDelete(this.ChildRecords, 'AddrTyp__c', 'Registered place for business')
            this.deleteAddressRecord(this.regiBussiAddress.Id)
            this.is_Open_Reg_Bus_add = false
            this.isRegiBussiAddress = false
            this.addRegiFlag = false
            this.isRegiAddressSame = false
            this.regiBussiAddress = {}
            this.handleAddressOptions(this.wrapObj);
        } else if (this.addTypeName === 'Principal place for business') {
            this.removeAddressOnDelete(this.ChildRecords, 'AddrTyp__c', 'Principal place for business')
            this.deleteAddressRecord(this.princiBussiAddress.Id)
            this.is_Open_Princi_Bus_add = false
            this.isPrinciBussiAddress = false
            this.princiBussiAddress = {}
            if (this.isRegiAddressSame) {
                this.removeAddressOnDelete(this.ChildRecords, 'AddrTyp__c', 'Registered place for business')
                this.deleteAddressRecord(this.regiBussiAddress.Id)
                this.is_Open_Reg_Bus_add = false
                this.isRegiBussiAddress = false
                this.isRegiAddressSame = false
                this.addRegiFlag = false
                this.regiBussiAddress = {}
                this.handleAddressOptions(this.wrapObj);
            }
            this.handleAddressOptions(this.wrapObj);
        } else if (this.addTypeName === 'Other') {
            this.removeAddressOnDelete(this.ChildRecords, 'AddrTyp__c', 'Other Address')
            this.deleteAddressRecord(this.otherAddress.Id)
            this.is_Open_Other_add = false
            this.isOtherAddress = false
            this.otherAddress = {}
            this.handleAddressOptions(this.wrapObj);
        } else if (this.addTypeName === 'Office') {
            this.removeAddressOnDelete(this.ChildRecords, 'AddrTyp__c', 'Office Address')
            this.deleteAddressRecord(this.officeAddress.Id)
            this.is_Open_Office_add = false
            this.isOffice = false
            this.officeAddress = {}
            this.handleAddressOptions(this.wrapObj);
        }
        this.isModalOpen = false;
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
                    refreshApex(this.wiredData);
                    refreshApex(this.wiredAppAddressData);
                    this.mailingAddressCounter(this.ChildRecords)
                })
                .catch(error => console.error('Error in deleting record ####', error))
        }
    }

    removeAddressOnDelete(arr, attr, value) {
        let tempArr = [];
        tempArr = this.ChildRecords.filter(obj => obj.AddrTyp__c != value);
        if (tempArr && tempArr.length > 0) {
            this.addressValue = tempArr[0].AddrTyp__c;
        } else {
            this.addressValue = ''
        }
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
            })
    }

    //Relationships Values On the basis of Constitution
    @track wiredLaonApplcantData;
    @track applConstitutionType;
    @wire(getSobjectData, { params: '$paramsLoanApplcation' })
    handleLoanApplResp(wiredLoanApplcntData) {
        let { error, data } = wiredLoanApplcntData;
        this.wiredLaonApplcantData = wiredLoanApplcntData;
        if (data) {
            if (data.parentRecords && data.parentRecords.length > 0) {
                if (data.parentRecords[0].ApplType__c && data.parentRecords[0].ApplType__c === 'P' && data.parentRecords[0].Constitution__c && data.parentRecords[0].Constitution__c === 'INDIVIDUAL') {
                    this.applConstitutionType = 'INDIVIDUAL'
                }
                else {
                    this.applConstitutionType = 'NON INDIVIDUAL'
                }
            }
        } else if (error) {
            console.log('Error to get loan Appl Data---------->', JSON.stringify(error))
        }
    }


    get filterCondnRelationship() {
        let coApplConstitutionType;
        if (this.wrapObj && this.wrapObj.Constitution__c && this.wrapObj.Constitution__c !== 'INDIVIDUAL') {
            coApplConstitutionType = 'NON INDIVIDUAL';
        } else if (this.wrapObj && this.wrapObj.Constitution__c && this.wrapObj.Constitution__c === 'INDIVIDUAL') {
            coApplConstitutionType = 'INDIVIDUAL';
        }

        if (coApplConstitutionType != null && coApplConstitutionType === "INDIVIDUAL") {
            console.log('applConstitutionType---->' + this.applConstitutionType + '##      CoapplConstitutionType---->', coApplConstitutionType);
            return (
                "ApplType__c=" +
                "'" +
                this.applConstitutionType +
                "'" +
                " AND CoApplType__c=" +
                "'" +
                coApplConstitutionType +
                "'"
            );
        } else if (coApplConstitutionType != null && coApplConstitutionType === "NON INDIVIDUAL") {
            console.log('applConstitutionType---->' + this.applConstitutionType + '##      CoapplConstitutionType---->', coApplConstitutionType);
            return (
                "ApplType__c=" +
                "'" +
                this.applConstitutionType +
                "'" +
                " AND CoApplType__c=" +
                "'" +
                coApplConstitutionType +
                "'"
            );
        }
    }

    //Platform Event SubScription Part Implemented
    callSubscribePlatformEve() {
        //Commnet platform event subscription temproroly
        this.handleSubscribe();
    }

    PEsubscription;
    @track noIntResponec = true;
    cometdlib
    handleSubscribe() {
        const self = this;
        this.cometdlib = new window.org.cometd.CometD();
        this.cometdlib.configure({
            url: window.location.protocol + '//' + window.location.hostname + '/cometd/50.0/',
            requestHeaders: { Authorization: 'OAuth ' + this.sessionId },
            appendMessageTypeToURL: false,
            logLevel: 'debug'
        });

        this.cometdlib.websocketEnabled = false;
        this.cometdlib.handshake(function (status) {
            self.noIntResponec = true;
            if (status.successful) {
                self.PEsubscription = self.cometdlib.subscribe(self.channelName, (message) => {
                    self.handlePlatformEventResponce(message.data.payload);
                },
                    (error) => {
                        // this.showSpinner = false;
                        console.log('Error In Subscribing ', error);
                    }
                );
            } else {
                // this.showSpinner = false;
                // console.log('spinner turned off //2515')
            }
        });
    }

    handlePlatformEventResponce(payload) {
        if (payload) {
            if (payload.LoanAppId__c === this.loanAppId) {

                let arra = JSON.parse(payload.Mes__c);
                arra.forEach(item => {
                    if (item === 'Email ID has been changed. Kindly Verify the same.') {
                        if (this.emailIdVerStatus) {
                            this.showToastMessage('Warning', item, 'warning', 'sticky');
                            this.emailIdVerStatus = 'Initiated';
                        }
                    } else if (item === 'Professional Qualification has been changed kindly trigger APIs On verification screen: "Input parameter has been changed. Kindly retrigger the API"') {
                        if (this.quaCheckVerStatus || this.quaCheckVerStatusDoc || this.quaCheckVerStatusArch) {
                            this.showToastMessage('Warning', item, 'warning', 'sticky');
                            this.quaCheckVerStatus = 'Initiated';
                            this.quaCheckVerStatusDoc = 'Initiated';
                            this.quaCheckVerStatusArch = 'Initiated';
                        }
                    } else {
                        this.showToastMessage('Warning', item, 'warning', 'sticky');
                    }
                })
            }
            this.handleUnsubscribe();
        } else {
            this.handleUnsubscribe();
            this.showSpinner = false;
            console.log('spinner turned off //2533')
        }
    }

    handleUnsubscribe() {
        if (this.PEsubscription) {
            //Unsubscribing Cometd
            this.noIntResponec = false;
            this.cometdlib.unsubscribe(this.PEsubscription, {}, (unsubResult) => {
                if (unsubResult.successful) {
                    this.cometdlib.disconnect((disResult) => {
                        if (disResult.successful) {
                            this.showSpinner = false;
                            console.log('spinner turned off //2546')
                        }
                        else {
                            this.showSpinner = false;
                            console.log('spinner turned off //2550')
                        }
                    });
                }
                else {
                    this.showSpinner = false;
                    console.log('spinner turned off //2556')
                }
            });
            this.showSpinner = false;
            this.PEsubscription = undefined;
            console.log('spinner turned off //2561')
        }
    }
    
    checkAPIToRun() {
        console.log('inside checkAPIToRun ::',this.productType)
        
        let applicantIds = []
        applicantIds.push(this.wrapObj.Id);
        getAPIsToRun({ applicantId: applicantIds })
            .then(result => {
                this.apiList = result; // Store Which API to Run;
                console.log('inside this.apiList  ==',this.apiList)
                this.intRecords = [];
                for (var i = 0; i < this.apiList.length; i++) {
                    if (this.apiList[i].runAPI == true) {
                        let fieldsWo = {};
                        console.log('inside this.apiList[i].apiName ==',this.apiList[i].apiName)
                        fieldsWo['sobjectType'] = 'IntgMsg__c';
                        if (this.apiList[i].apiName == 'Dedupe') {
                            fieldsWo['Name'] = 'Dedupe API Token';
                            fieldsWo['Svc__c'] = 'Dedupe API Token';
                            fieldsWo['TriggFrmScrn__c'] = 'Applicant Details';
                        } else if (this.apiList[i].apiName == 'Cusomer Issue Request' && this.productType && (this.productType === 'Home Loan' || this.productType === 'Small Ticket LAP' || this.productType === 'Loan Against Property')) {
                            fieldsWo['Name'] = 'Consumer ACK Request';
                            fieldsWo['Svc__c'] = 'Consumer ACK Request';
                            fieldsWo['TriggFrmScrn__c'] = 'Applicant Details';
                        } else {
                            fieldsWo['Name'] = this.apiList[i].apiName; //serviceName;//'KYC OCR'
                            fieldsWo['Svc__c'] = this.apiList[i].apiName;
                            fieldsWo['TriggFrmScrn__c'] = 'Applicant Details';
                        }

                        fieldsWo['BU__c'] = 'HL / STL';
                        fieldsWo['IsActive__c'] = true;
                        fieldsWo['ExecType__c'] = 'Async';
                        fieldsWo['Status__c'] = 'New';
                        fieldsWo['Mresp__c'] = 'Blank';
                        fieldsWo['Outbound__c'] = true;
                        fieldsWo['Trigger_Platform_Event__c'] = false;
                        fieldsWo['TriggerType__c'] = 'System';
                        fieldsWo['RefObj__c'] = 'Applicant__c';
                        fieldsWo['RefId__c'] = this.wrapObj.Id;
                        fieldsWo['ParentRefObj__c'] = "LoanAppl__c";
                        fieldsWo['ParentRefId__c'] = this.loanAppId;
                        this.intRecords.push(fieldsWo);
                    } else {
                        if (this.apiList[i].missingFields) {
                            this.showToastMessage('Error', this.apiList[i].applicantName + ' :' + this.apiList[i].missingFieldDetails, 'info', 'sticky');
                        }
                    }
                }
                if (this.intRecords.length > 0) {
                    this.createIMRecords();
                }
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            })
    }

    createIMRecords() {
        upsertMultipleRecord({ params: this.intRecords })
            .then((result) => {
                this.intRecords = []
            })
            .catch((error) => {
                console.log('Error In creating Record', error);
            });
    }
}