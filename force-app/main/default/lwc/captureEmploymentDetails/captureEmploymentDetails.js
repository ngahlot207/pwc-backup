import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { getObjectInfo, getPicklistValues, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { refreshApex } from '@salesforce/apex';
import APPLICANT_ADD_OBJECT from '@salesforce/schema/ApplAddr__c';
import { getRecord, getFieldValue, createRecord } from "lightning/uiRecordApi";

import getSobjectDataWithMultipleChildRelation from '@salesforce/apex/incomeDetailsController.getSobjectDataWithMultipleChildRelation';
import getData from '@salesforce/apex/DataSearchClass.getData';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';
import ApplicantEmployment_OBJECT from '@salesforce/schema/ApplicantEmployment__c';

import CUSTOMER_PROFILE_FIELD from '@salesforce/schema/Applicant__c.CustProfile__c';
import BUSINESSPROOFAVAILABLE from '@salesforce/schema/Applicant__c.Businessproofavailable__c';
import ORGANISATION_TYPE_FIELD from '@salesforce/schema/ApplicantEmployment__c.TypeOfOrganisation__c';
import BUSINESS_NATURE_CORPORATE_FIELD from '@salesforce/schema/ApplicantEmployment__c.NatureOfBusinessCorporate__c';
import BUSINESS_NATURE_INDIVIDUAL_FIELD from '@salesforce/schema/ApplicantEmployment__c.NatureOfBusinessIndividual__c';
import DESIGNATION_VALUES_FIELD from '@salesforce/schema/ApplicantEmployment__c.DesignationValues__c';


import GST_REGISTERED_FIELD from '@salesforce/schema/ApplicantEmployment__c.GST_Registered__c';
import URC_UAC_AVAILABLE_FIELD from '@salesforce/schema/ApplicantEmployment__c.Is_URC_UAC_available__c';
import URC_UAC_APPLICABILITY_FIELD from '@salesforce/schema/ApplicantEmployment__c.Select_applicability_for_URC_UAC__c';
import MSME_INDUSTRY from '@salesforce/schema/ApplicantEmployment__c.MSME_Industry_selection__c';
import getSobjectDataWithoutCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjDtwithFltrRelatedRecordsWithoutCache';


import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import deleteRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';

import CURRENT_USER_ID from "@salesforce/user/Id";

import { CPARoles } from 'c/globalConstant';

// Custom labels
import EmploymentDetails_SelectGst_ErrorMessage from '@salesforce/label/c.EmploymentDetails_SelectGst_ErrorMessage';
import EmploymentDetails_Consent_ErrorMessage from '@salesforce/label/c.EmploymentDetails_Consent_ErrorMessage';
import EmploymentDetails_FillReqFields_ErrorMessage from '@salesforce/label/c.EmploymentDetails_FillReqFields_ErrorMessage';
import EmploymentDetails_Save_SuccessMessage from '@salesforce/label/c.EmploymentDetails_Save_SuccessMessage';
import EmploymentDetails_Update_ErrorMessage from '@salesforce/label/c.EmploymentDetails_Update_ErrorMessage';
import EmploymentDetails_Save_ErrorMessage from '@salesforce/label/c.EmploymentDetails_Save_ErrorMessage';
import EmploymentDetails_Del_SuccessMessage from '@salesforce/label/c.EmploymentDetails_Del_SuccessMessage';
import BusinessDetails_Save_SuccessMessage from '@salesforce/label/c.Business_Details_success_save_message';

//Integration Message Obj Fields Refernces\
import INTEGRATION_MSG_OBJECT from "@salesforce/schema/IntgMsg__c";
import REFERENCE_ID_FIELD from "@salesforce/schema/IntgMsg__c.RefId__c";
import REFERENCE_OBJ_API_FIELD from "@salesforce/schema/IntgMsg__c.RefObj__c";
import INTEGRATION_MSG_NAME_FIELD from "@salesforce/schema/IntgMsg__c.Name";
import BU_FIELD from "@salesforce/schema/IntgMsg__c.BU__c";
import SERVICE_NAME_FIELD from "@salesforce/schema/IntgMsg__c.Svc__c";
import API_VENDOR__NAME_FIELD from "@salesforce/schema/IntgMsg__c.ApiVendor__c";
import IS_ACTIVE_FIELD from "@salesforce/schema/IntgMsg__c.IsActive__c";
import STATUS_FIELD from "@salesforce/schema/IntgMsg__c.Status__c";
import MSTATUS from "@salesforce/schema/IntgMsg__c.MStatus__c";
import API_STATUS_FIELD from "@salesforce/schema/IntgMsg__c.APIStatus__c";
import HL_SSTLAP_view from "./captureEmploymentDetails.html";
import BL_view from "./captureEmploymentDetailsBL.html";

export default class CaptureEmploymentDetails extends LightningElement {
    label = {
        EmploymentDetails_SelectGst_ErrorMessage,
        EmploymentDetails_Consent_ErrorMessage,
        EmploymentDetails_FillReqFields_ErrorMessage,
        EmploymentDetails_Save_SuccessMessage,
        EmploymentDetails_Update_ErrorMessage,
        EmploymentDetails_Save_ErrorMessage,
        EmploymentDetails_Del_SuccessMessage,
        BusinessDetails_Save_SuccessMessage

    }
    @track helpText = "Plese Select Industry Type value First";

    //Modal Popup variable
    @track gstinIDValue;
    @track isModalOpen = false;
    @track removeModalMessage = 'Do You Want To Delete GST Record?';
    @track isLoading = false;
    @api recordId;
    @api isReadOnly;
    @api applicantIdOnTabset;
    // @api applicantId;
    @track EmploymentDataId;

    @track applicantGSTId;
    @track actualGSTData = [];
    employersPicklistOptions;
    industriesPicklistOptions;
    subIndustriesPicklistOptions;
    industryRBIReportingOptions;
    mainRBIIndustryOptions;

    // @track addressTypeOptions = [];
    @api layoutSize;
    @track isfinancialBorrwer = false;
    @track selectedIndustryValue;
    @track selectedSubIndustryName;
    @track selectedIndustryName;
    @track selectedSubIndustryValue;
    @track selectedindustryRBIReportingValue;
    @track selectedclassofActivityValue;
    @track selectedMainRBIIndustryValue;
    customerProfileOptions = [];
    organisationTypeOptions = [];
    businessNatureCorporateOptions = [];
    businessNatureIndividualOptions = [];
    designationOptions = [];
    otherEmployerOption;
    GSTRegisteredOptions = [];
    applicabilityOptions = [];
    URC_UAC_AvailableOptions = [];
    employmentFinancialGSTDetails = [];
    @track gstFinDetails = [];
    @track wiredDataFinancial = [];
    newGSTRec = [];
    classOfActivityOptions = [];
    cretSucc = false;

    proprietorshipProposalOptions = [
        { label: 'YES', value: 'YES' },
        { label: 'NO', value: 'NO' }
    ];

    ///START-LAK-6166
    isBusinessproofAvailOptins = [
        { label: 'YES', value: 'YES' },
        { label: 'NO', value: 'NO' }
    ];
    ///END-LAK-6166
    strUserId = CURRENT_USER_ID;
    isGSTRequired = false;
    count = 0;

    @wire(MessageContext)
    MessageContext;

    @track results = { applicant: {}, applicantGST: {}, loanApplication: {}, applicantEmployment: { WorkingWithCurrentEmployer_Years__c: '', WorkingWithCurrentEmployer_Months__c: '', TotalWorkExperience_Years__c: '', TotalWorkExperience_Months__c: '', CurrentBusinessVintage_Years__c: '', CurrentBusinessVintage_Months__c: '', Is_URC_UAC_available__c: '', Select_applicability_for_URC_UAC__c: '' } };

    displayLayout;
    //displayGSTLayout;
    isSalaried;
    isEPFOTriggered;
    isSelfEmployedProfessional;
    isSelfEmployedNonProfessional;
    isIndividualSelfEmployed;
    isNotOtherIndividual;
    isIndividualConstituiton;

    isNonIndividualSelfEmployed;
    @track displayOthersOption;
    @track isNotAvailableURCUAC = false;
    @track isNotAvailableURCUACNew = false;
    @track isAvailableURCUAC = false;
    @track isAvailableURCUACNew = false;
    @track isURCAvailable = false;
    @track isURCAvailableNew = false;
    @track isUACAvailable = false;
    @track isUACAvailableNew = false;
    @track selectedAvailableURCUAC;
    @track selectedAvailableURCUACNew;
    @track selectedApplicability;
    @track selectedApplicabilityNew;
    @api hasEditAccess;
    @track disableMode;
    @track isPhysicalConsentValidated;
    @track isApplMobileverification;
    @track applicantType;
    @track appId;
    //LAK-3051
    @track disableShareholding;

    @track wiredDataGST;
    @track wiredDataEmployment;
    @track wiredDataApplicant;
    @track wiredDataOfApplTypeEmp;
    @track isGSTRegisteredNo;
    @track borrowerType;

    // label={
    //     MainRBIIndustryToastMessage
    // }

    @track designationReqrdCondition = true;

    @api get applicantId() {
        return this.appId;
    }
    set applicantId(value) {
        this.appId = value;
        this.setAttribute("applicantId", value);
        this.handleRecordIdChange(value);
    }

    @track _loanAppId;

    @api get loanAppId() {
        return this._loanAppId;
    }

    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        this.handleRecordLoanIdChange(value);
    }

    get msmeVisibilityCondition() {
        //LAK-9244
        if (this.userTeamRoleData &&  this.userTeamRoleData === 'UW' //((CPARoles && CPARoles.includes(this.userTeamRoleData)) || getting error plz check
            || this.userTeamRoleData === 'RCM' || this.userTeamRoleData === 'ZCM' || this.userTeamRoleData === 'NCM'
            || this.userTeamRoleData === 'CH' || this.userTeamRoleData === 'ACM')//)
             {
            return true;
        } else {
            return false;
        }
    }

    get CPARole() {
        //LAK-9244
        if (this.userTeamRoleData && (CPARoles && CPARoles.includes(this.userTeamRoleData))) {
            return true;
        } else {
            return false;
        }
    }
    get udyamDisableMode() {
        if (this.disableMode) {
            return true;
        } else {
            return this.results.applicantEmployment.UdyamAPIStatus__c === 'Success' ? true : false;
        }
    }

    get propietershipVisibilityCondition() {
        if (this.isIndividualSelfEmployed === true
            && (this.designation && this.designation === 'PROPRIETOR')
            && (this.userTeamRoleData && (this.userTeamRoleData === 'RM' || this.userTeamRoleData === 'SM' || (CPARoles && CPARoles.includes(this.userTeamRoleData)) || this.userTeamRoleData === 'UW'  //LAK-9244
                || this.userTeamRoleData === 'RCM' || this.userTeamRoleData === 'ZCM' || this.userTeamRoleData === 'NCM'
                || this.userTeamRoleData === 'CH' || this.userTeamRoleData === 'ACM'))) {
            return true;
        } else {
            return false;
        }
    }

    get noPropietershipMsmeVisibilityCondition() {
        if (this.userTeamRoleData && (this.userTeamRoleData === 'RM' || this.userTeamRoleData === 'SM' || (CPARoles && CPARoles.includes(this.userTeamRoleData)) || this.userTeamRoleData === 'UW'  //LAK-9244
            || this.userTeamRoleData === 'RCM' || this.userTeamRoleData === 'ZCM' || this.userTeamRoleData === 'NCM'
            || this.userTeamRoleData === 'CH' || this.userTeamRoleData === 'ACM')
            && ((this.isProprietorship && this.isProprietorship === 'NO' && this.designation && this.designation === 'PROPRIETOR') || (((this.results.applicant.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || this.results.applicant.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') && this.results.applicant.CustProfile__c != 'SALARIED')))) {
            return true;
        } else {
            return false;
        }
    }

    get requiredFlag() {     //LAK-3199
        if ((this.results.applicant.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || this.results.applicant.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL' || this.results.applicant.CustProfile__c === 'SALARIED') && this.borrowerType === 'Non Financial') {
            return false;
        } else {
            return true;
        }
    }

    get requiredUrcDetails() {
        if ((this.results.applicant.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || this.results.applicant.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL' || this.results.applicant.CustProfile__c === 'SALARIED') && this.borrowerType === 'Non Financial' && this.StagePickVal != 'UnderWriting') {
            return false;
        } else {
            return true;
        }
    }


    get isNotSalaried() {// bl build
        if ((this.results.applicant.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || this.results.applicant.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL')) {
            return true;
        } else {
            return false;
        }
    }

    // get requiredFlagForIndAndRBIReletedFields() {     //LAK-4983
    //     if ((this.results.applicant.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || this.results.applicant.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL' || this.results.applicant.CustProfile__c === 'SALARIED') 
    //         && (this.borrowerType === 'Non Financial' || this.borrowerType === 'Financial' ) 
    //         && (this.userTeamRoleData && (this.userTeamRoleData === 'RM' || this.userTeamRoleData === 'SM'))
    //     ) {
    //         return false;
    //     } else {
    //         return true;
    //     }
    // }

    get requiredFlagForIndAndRBIReletedFields() {     //LAK-4983 // LAK-5729
        if ((this.results.applicant.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || this.results.applicant.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL' || this.results.applicant.CustProfile__c === 'SALARIED')
            && (this.borrowerType === 'Non Financial' || this.borrowerType === 'Financial')
            && (this.StagePickVal && this.StagePickVal === 'QDE')
        ) {
            return false;
        } else {
            return true;
        }
    }

    //For Display class of Activity Fields>>>>>>
    get displayClassOfActivity() {
        if (this.results.applicant.Constitution__c == 'INDIVIDUAL' || this.results.applicant.Constitution__c == 'HUF') {
            return false;
        } else {
            return true;
        }


    }

    connectedCallback() {

        this.getEmployersPicklistValues();
        this.getIndustriesPicklistValues();
        this.sunscribeToMessageChannel();

        if (this.addApplicantGSTRows.length <= 1) {
            this.deleteButtonDisabled = true;
        }

        if (this.hasEditAccess === false) {
            this.disableMode = true;
            this.disableShareholding = true;
            this.industrySubTypedisabled = true;
        }
        else {
            this.disableMode = false;
            this.disableShareholding = false;
        }

        this.handleRefreshAllData();

    }

    sunscribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );

    }

    handleSaveThroughLms(values) {
        this.isLoading = true;
        if (values.recordId === this._loanAppId) {
            this.handleSave(values.validateBeforeSave);
        }

    }


    //For custom lookupMaster Class of activity Object
    @track lookupRec;
    handleValueSelect(event) {
        this.lookupRec = event.detail;

        let lookupId = this.lookupRec.id;
        let lookupAPIName = this.lookupRec.lookupFieldAPIName;

        const outputObj = { [lookupAPIName]: lookupId };
        Object.assign(this.results.applicantEmployment, outputObj);

        if (event.target.label === "Name of Employer") {
            this.results.applicantEmployment.EmployerName__c = this.lookupRec.mainField;
            this.results.applicantEmployment.EmployerName__c = this.lookupRec.id;
            if (this.lookupRec.id !== this.otherEmployerOption.Id) {
                this.results.applicantEmployment.Others__c = '';
            }
            this.displayOthersOption = this.lookupRec.id === this.otherEmployerOption.Id ? true : false;
            this.designationReqrdCondition = this.lookupRec.id === this.otherEmployerOption.Id ? false : true;
        }

    }

    @track lookupRecDetails;
    @track gstRowIndex = '';
    @track filterConditionState;
    @track filterConditionPin;
    @track pincode;
    @track cityName;

    //LAK-6480: To select pincode from Pincode Master & populate on UI
    handleValueSelectGST(event) {
        this.gstRowIndex = event.currentTarget.dataset.index;
        this.lookupRecDetails = event.detail;

        if (event.target.label === "Pincode") {
            this.addApplicantGSTRows[event.target.dataset.index].Pincode__c = this.lookupRecDetails.mainField;
            this.addApplicantGSTRows[event.target.dataset.index].PinId__c = this.lookupRecDetails.id;
            this.pincode = this.lookupRecDetails.mainField;
            this.searchPinCodeMasterRecord();
        }

        if (event.target.label === 'City') {
            this.addApplicantGSTRows[event.target.dataset.index].City__c = this.lookupRecDetails.mainField;
            this.addApplicantGSTRows[event.target.dataset.index].CityId__c = this.lookupRecDetails.id;
            this.filterConditionState = 'City__c = ' + "'" + this.addApplicantGSTRows[event.target.dataset.index].City__c + "' " + 'LIMIT 1';
            this.filterConditionPin = 'City__r.City__c = ' + "'" + this.addApplicantGSTRows[event.target.dataset.index].City__c + "' ";
            this.searchstate();
        }

        if (event.target.label === 'State/UT') {
            this.addApplicantGSTRows[event.target.dataset.index].State__c = this.lookupRecDetails.mainField;
            this.addApplicantGSTRows[event.target.dataset.index].StateId__c = this.lookupRecDetails.id;
        }

    }

    //LAK-6480: To search Pincode from pincode master & show on UI.
    searchPinCodeMasterRecord() {
        let pincodeParams = {
            ParentObjectName: 'PincodeMstr__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'City__r.City__c'],
            childObjFields: [],
            queryCriteria: ' where PIN__c = \'' + this.pincode + '\''
        }

        getSobjectData({ params: pincodeParams })
            .then((result) => {
                if (result && result.parentRecords && result.parentRecords.length > 0) {
                    this.cityName = result.parentRecords[0].City__r.City__c ? result.parentRecords[0].City__r.City__c : null;
                    this.addApplicantGSTRows[this.gstRowIndex].City__c = this.cityName;
                    this.addApplicantGSTRows[this.gstRowIndex].CityId__c = result.parentRecords[0].City__r.Id ? result.parentRecords[0].City__r.Id : null;
                    this.searchCityNstate();
                }

            })
            .catch((error) => {
                console.log('Error in searchPinCodeMasterRecord method', JSON.stringify(error));
            })
    }

    //LAK-6480: To search City & State from Location master and populate on UI.
    searchCityNstate() {
        let cityNstateParams = {
            ParentObjectName: 'LocMstr__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'City__c', 'State__c'],
            childObjFields: [],
            queryCriteria: ' where City__c = \'' + this.cityName + '\''
        }

        getSobjectData({ params: cityNstateParams })
            .then((result) => {

                if (result && result.parentRecords && result.parentRecords.length > 0) {
                    this.addApplicantGSTRows[this.gstRowIndex].City__c = result.parentRecords[0].City__c ? result.parentRecords[0].City__c : null;
                    this.addApplicantGSTRows[this.gstRowIndex].State__c = result.parentRecords[0].State__c ? result.parentRecords[0].State__c : null;
                    // this.addApplicantGSTRows[this.gstRowIndex].CityId__c = result.parentRecords[0].City__r.Id ? result.parentRecords[0].City__r.Id : null;
                    // this.addApplicantGSTRows[this.gstRowIndex].StateId__c = result.parentRecords[0].City__r.Id ? result.parentRecords[0].City__r.Id : null;

                }
            })
            .catch((error) => {
                console.log('Error in searchCityNstate method', JSON.stringify(error))
            })

        this.searchstate();
    }

    //LAK-6480: To search State from Location master and populate on UI.
    searchstate() {
        let cityParams = {
            ParentObjectName: 'LocMstr__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'State__c'],
            childObjFields: [],
            queryCriteria: ' where City__c = \'' + this.cityName + '\''
        }
        getSobjectData({ params: cityParams })
            .then((result) => {
                if (result && result.parentRecords && result.parentRecords.length > 0) {
                    this.addApplicantGSTRows[this.gstRowIndex].StateId__c = result.parentRecords[0].Id ? result.parentRecords[0].Id : null;
                    this.addApplicantGSTRows[this.gstRowIndex].State__c = result.parentRecords[0].State__c ? result.parentRecords[0].State__c : null;
                }

            })
            .catch((error) => {
                console.log('Error in searchstate method', JSON.stringify(error))
            })

    }

    @track
    parametersAppGST = {
        ParentObjectName: 'Applicant__c',
        ChildObjectRelName: 'Applicant_GST__r',
        parentObjFields: ['Id'],
        childObjFields: ['TradeName_GST_Certificate__c', 'Main_GSTIN__c', 'FetchFromSource__c', 'GSTIN__c', 'GSTIN_Status__c',
            'RegisteredAddress_GST__c', 'LegalNameOfBusiness_GST_Certificate__c', 'LastSelectedAddrType__c', 'Applicant_Address__c', 'AddrLine1__c',
            'AddrLine2__c', 'Pincode__c', 'City__c', 'State__c', 'HouseNo__c', 'Locality__c', 'Landmark__c'],
        queryCriteria: ' where id = \'' + this.appId + '\''
    }

    get formCombinedQueryData() {
        if (this.appId) {
            var combinedQuery = 'SELECT Id, Constitution__c, CustProfile__c, Type_of_Borrower__c, ' +
                '(SELECT Id, HouseNo__c, AddrLine1__c, AddrLine2__c, Locality__c, Landmark__c, City__c, Country__c, Pincode__c, GSTIndex__c, State__c, AddrTyp__c FROM Applicant_Addresses__r), ' +
                '(SELECT Id, TradeName_GST_Certificate__c, Main_GSTIN__c,FetchFromSource__c, GSTIN__c, ' +
                'GSTIN_Status__c, RegisteredAddress_GST__c, LegalNameOfBusiness_GST_Certificate__c,AddrLine1__c, AddrLine2__c, ' +
                'Pincode__c, HouseNo__c, Locality__c, Landmark__c, City__c, CityId__c, PinId__c, StateId__c, State__c, LastSelectedAddrType__c, Applicant_Address__c, Applicant__c FROM Applicant_GST__r) ' +
                'FROM Applicant__c ' +
                'WHERE Id = \'' + this.appId + '\'';

            return combinedQuery;
        } else {
            return '';
        }
    }

    @track applicantAllData;
    @track actualAddressData;
    @wire(getSobjectDataWithMultipleChildRelation, { query: '$formCombinedQueryData' })
    handleMultipleResponse(wiredResultAllData) {
        let { error, data } = wiredResultAllData;
        this.wiredDataGST = wiredResultAllData;
        if (data) {
            this.actualAddressData = data;
            console.log('GST Data ', JSON.stringify(data))
            this.handleDataProcessor(data);

        } else if (error) {
            console.log('Error in Getting GST Details ------------->', JSON.stringify(error));
        }
    }

    //LAK-6111
    @track
    parametersAppFinancialGST = {
        ParentObjectName: 'Applicant_Financial__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Loan_Applicant__c', 'RecordTypeId', 'RecordType.DeveloperName'],
        childObjFields: [],
        queryCriteria: ' where Loan_Applicant__c = \'' + this.appId + '\''
    }
    //LAK-6111
    //LAK-6480
    @track parameterApplicant = {
        ParentObjectName: 'Applicant__c',
        ChildObjectRelName: 'Applicant_Addresses__r',
        parentObjFields: ['Id', 'ApplType__c', 'OTP_Verified__c', 'Is_Physical_Consent_Validated__c', 'Type_of_Borrower__c', 'CustProfile__c', 'Constitution__c', 'Businessproofavailable__c'],
        childObjFields: ['Id', 'City__c', 'State__c', 'Pincode__c', 'AddrLine1__c', 'AddrLine2__c', 'HouseNo__c', 'Locality__c', 'Landmark__c'],
        queryCriteria: ' where id = \'' + this.appId + '\''
    }

    @track parameterApplicantEmpData = {
        ParentObjectName: 'ApplicantEmployment__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'EPFOTriggered__c', 'LoanApplicant__c', 'Activity_URC__c', 'ActivityDescription_URC__c', 'UdyamAPIStatus__c', 'DateOfUdyamRegistration__c', 'DesignationText__c', 'DesignationValues__c',
            'EmployerName__c', 'ClassOfAct__c', 'GST_Registered__c', 'Industry_URC__c', 'IndustryForRBIReporting__c', 'IndustryType__c', 'NatureOfBusinessCorporate__c',
            'NatureOfBusinessIndividual__c', 'OfficialEmail__c', 'RetirementAge__c', 'SubIndustry__c', 'SubSector_URC__c', 'TotalWorkExperience_Months__c',
            'TotalWorkExperience_Years__c', 'TypeOfEnterprise_URC__c', 'TypeOfOrganisation__c', 'UdyamRegistrationNumber__c', 'WorkingWithCurrentEmployer_Months__c',
            'WorkingWithCurrentEmployer_Years__c', 'CurrentBusinessVintage_Months__c', 'CurrentBusinessVintage_Years__c', 'EntityName__c', 'ShareholdingInTheEntity__c', 'NIC_URC__c',
            'MSME_Industry_selection__c', 'Others__c', 'Is_URC_UAC_available__c', 'Select_applicability_for_URC_UAC__c', 'UdyamAssistCertificate__c', 'URC_UAC_application_ref_no__c',
            'URC_UAC_ApplicationDate__c', 'Proprietorship_firm_part_of_the_proposal__c', 'MainRBIIndustry__c', 'SubIndustry__r.Name', 'IndustryType__r.Name', 'TurnoverYear1__c', 'TurnoverYear2__c', 'IsMSME__c'],
        childObjFields: [],
        queryCriteria: ' where LoanApplicant__c = \'' + this.appId + '\' ORDER BY LASTMODIFIEDDATE DESC LIMIT 1 '
    }

    @track
    parameterforTeam = {
        ParentObjectName: 'TeamHierarchy__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'EmpRole__c '],
        childObjFields: [],
        queryCriteria: 'WHERE Employee__c=\'' + CURRENT_USER_ID + '\'' + 'ORDER BY LastModifiedDate DESC'
    }

    @track parameterLoanApplication = {
        ParentObjectName: 'LoanAppl__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Stage__c', 'Product__c'],
        childObjFields: [],
        queryCriteria: ' where Id = \'' + this._loanAppId + '\''
    }

    handleRecordIdChange() {

        let tempParams = this.parametersAppGST;
        tempParams.queryCriteria = ' where id = \'' + this.appId + '\'';
        this.parametersAppGST = { ...tempParams };

        //LAK-6111
        let tempParamsFinGst = this.parametersAppFinancialGST;
        tempParamsFinGst.queryCriteria = ' where Loan_Applicant__c = \'' + this.appId + '\'';
        this.parametersAppFinancialGST = { ...tempParamsFinGst };

        let tempParamsApplicant = this.parameterApplicant;
        tempParamsApplicant.queryCriteria = ' where id = \'' + this.appId + '\'';
        this.parameterApplicant = { ...tempParamsApplicant };

        let tempParamsApplAddr = this.paramsForApplAddress;
        tempParamsApplAddr.queryCriteria = ' where Applicant__c = \'' + this.appId + '\'';
        this.paramsForApplAddress = { ...tempParamsApplAddr };

        let tempParamsEmploymentData = this.parameterApplicantEmpData;
        tempParamsEmploymentData.queryCriteria = ' where LoanApplicant__c = \'' + this.appId + '\'  ORDER BY LASTMODIFIEDDATE DESC LIMIT 1 ';
        this.parameterApplicantEmpData = { ...tempParamsEmploymentData };
    }

    handleRecordLoanIdChange() {
        let tempParamLaon = this.parameterLoanApplication;
        tempParamLaon.queryCriteria = ' where Id = \'' + this._loanAppId + '\'';
        this.parameterLoanApplication = { ...tempParamLaon };
    }

    @wire(getSobjectData, { params: '$parameterApplicant' })
    applicantDetailsHandler(wiredResultApplicant) {
        this.isLoading=true;
        let { error, data } = wiredResultApplicant;
        this.wiredDataApplicant = wiredResultApplicant;
        console.log('wiredDataApplicant', JSON.stringify(this.wiredDataApplicant))
        if (data && data.parentRecords && data.parentRecords.length > 0) {
            this.BusinssProfAvail = data.parentRecords[0].Businessproofavailable__c;
            this.applicantType = data.parentRecords[0].ApplType__c;
            this.isApplMobileverification = data.parentRecords[0].OTP_Verified__c;
            this.isPhysicalConsentValidated = data.parentRecords[0].Is_Physical_Consent_Validated__c;
            this.borrowerType = data.parentRecords[0].Type_of_Borrower__c;
            this.results.applicant.CustProfile__c = data.parentRecords[0].CustProfile__c != null ? data.parentRecords[0].CustProfile__c : '';
            this.results.applicant.Constitution__c = data.parentRecords[0].Constitution__c ? data.parentRecords[0].Constitution__c : '';

            this.results.applicant.Type_of_Borrower__c = data.parentRecords[0].Type_of_Borrower__c ? data.parentRecords[0].Type_of_Borrower__c : '';
            this.isSalaried = (this.results.applicant.CustProfile__c === 'SALARIED') ? true : false;
            this.isSelfEmployedProfessional = (this.results.applicant.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') ? true : false;
            this.isSelfEmployedNonProfessional = (this.results.applicant.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL') ? true : false;
            this.isIndividualSelfEmployed = ((this.results.applicant.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL' || this.results.applicant.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL') && this.results.applicant.Constitution__c === 'INDIVIDUAL') ? true : false;
            this.isNotOtherIndividual = (this.results.applicant.CustProfile__c != 'OTHERS' && this.results.applicant.Constitution__c === 'INDIVIDUAL') ? true : false;
            this.isIndividualConstituiton = this.results.applicant.Constitution__c === 'INDIVIDUAL' ? true : false;
            this.isNonIndividualSelfEmployed = ((this.results.applicant.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL' || this.results.applicant.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL') && this.results.applicant.Constitution__c != 'INDIVIDUAL') ? true : false;
            this.displayLayout = (this.results.applicant.CustProfile__c === 'SALARIED' || this.results.applicant.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL' || this.results.applicant.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL') ? true : false;
            this.isfinancialBorrwer = (this.results.applicant.Type_of_Borrower__c && this.results.applicant.Type_of_Borrower__c === 'Financial') ? true : false;
            this.error = undefined;
            this.isLoading=false;
        } else if (error) {
            this.error = error;
            this.isLoading = false;
        }

        this.isLoading = false;
    }
    get showUrc() {
        if (this.blView) {
            return this.isMSME === 'YES';
        } else {
            return true;
        }
    }
    get showProprietorship() {
        return this.isProprietorship === 'NO' && this.isMSME;
    }

    @wire(getSobjectData, { params: '$parameterApplicantEmpData' })
    handleResponseForEmployment(wiredResultApplEmp) {
        this.isLoading = true;
        let { error, data } = wiredResultApplEmp;
        this.wiredDataOfApplTypeEmp = wiredResultApplEmp;
        if (data && data.parentRecords && data.parentRecords.length > 0) {

            this.EmploymentDataId = data.parentRecords[0].Id;
            this.results.applicantEmployment.UdyamAPIStatus__c = data.parentRecords[0].UdyamAPIStatus__c && data.parentRecords[0].UdyamAPIStatus__c === 'Success' ? data.parentRecords[0].UdyamAPIStatus__c : 'Failure';
            this.results.applicantEmployment.Activity_URC__c = data.parentRecords[0].Activity_URC__c ? data.parentRecords[0].Activity_URC__c : '';
            this.results.applicantEmployment.ActivityDescription_URC__c = data.parentRecords[0].ActivityDescription_URC__c ? data.parentRecords[0].ActivityDescription_URC__c : '';
            this.results.applicantEmployment.DateOfUdyamRegistration__c = data.parentRecords[0].DateOfUdyamRegistration__c ? data.parentRecords[0].DateOfUdyamRegistration__c : '';
            this.results.applicantEmployment.DesignationText__c = data.parentRecords[0].DesignationText__c ? data.parentRecords[0].DesignationText__c : '';
            this.results.applicantEmployment.DesignationValues__c = data.parentRecords[0].DesignationValues__c ? data.parentRecords[0].DesignationValues__c : '';
            this.designation = data.parentRecords[0].DesignationValues__c ? data.parentRecords[0].DesignationValues__c : '';
            this.results.applicantEmployment.EmployerName__c = data.parentRecords[0].EmployerName__c ? data.parentRecords[0].EmployerName__c : '';
            if (this.results.applicantEmployment.EmployerName__c && this.otherEmployerOption) {
                this.displayOthersOption = this.results.applicantEmployment.EmployerName__c === this.otherEmployerOption.Id ? true : false;
                this.designationReqrdCondition = this.results.applicantEmployment.EmployerName__c === this.otherEmployerOption.Id ? false : true;
            }
            //For Class Of Activity Master Data
            this.results.applicantEmployment.ClassOfAct__c = data.parentRecords[0].ClassOfAct__c ? data.parentRecords[0].ClassOfAct__c : '';

            this.results.applicantEmployment.GST_Registered__c = data.parentRecords[0].GST_Registered__c ? data.parentRecords[0].GST_Registered__c : '';

            this.results.applicantEmployment.Industry_URC__c = data.parentRecords[0].Industry_URC__c ? data.parentRecords[0].Industry_URC__c : '';
            this.results.applicantEmployment.IndustryForRBIReporting__c = data.parentRecords[0].IndustryForRBIReporting__c ? data.parentRecords[0].IndustryForRBIReporting__c : '';
            this.results.applicantEmployment.IndustryType__c = data.parentRecords[0].IndustryType__c ? data.parentRecords[0].IndustryType__c : '';

            this.results.applicantEmployment.NatureOfBusinessCorporate__c = data.parentRecords[0].NatureOfBusinessCorporate__c ? data.parentRecords[0].NatureOfBusinessCorporate__c : '';
            this.results.applicantEmployment.NatureOfBusinessCorporate__c = data.parentRecords[0].NatureOfBusinessCorporate__c ? data.parentRecords[0].NatureOfBusinessCorporate__c : '';
            this.results.applicantEmployment.NatureOfBusinessIndividual__c = data.parentRecords[0].NatureOfBusinessIndividual__c ? data.parentRecords[0].NatureOfBusinessIndividual__c : '';
            this.results.applicantEmployment.NatureOfBusinessIndividual__c = data.parentRecords[0].NatureOfBusinessIndividual__c ? data.parentRecords[0].NatureOfBusinessIndividual__c : '';
            this.results.applicantEmployment.OfficialEmail__c = data.parentRecords[0].OfficialEmail__c ? data.parentRecords[0].OfficialEmail__c : '';

            this.results.applicantEmployment.RetirementAge__c = data.parentRecords[0].RetirementAge__c ? data.parentRecords[0].RetirementAge__c : '';
            this.results.applicantEmployment.SubIndustry__c = data.parentRecords[0].SubIndustry__c ? data.parentRecords[0].SubIndustry__c : '';
            this.results.applicantEmployment.SubSector_URC__c = data.parentRecords[0].SubSector_URC__c ? data.parentRecords[0].SubSector_URC__c : '';
            this.results.applicantEmployment.TotalWorkExperience_Months__c = data.parentRecords[0].TotalWorkExperience_Months__c != null ? data.parentRecords[0].TotalWorkExperience_Months__c.toString().padStart(2, '0') : '';
            this.results.applicantEmployment.TotalWorkExperience_Years__c = data.parentRecords[0].TotalWorkExperience_Years__c != null ? data.parentRecords[0].TotalWorkExperience_Years__c.toString().padStart(2, '0') : '';

            this.results.applicantEmployment.TypeOfEnterprise_URC__c = data.parentRecords[0].TypeOfEnterprise_URC__c ? data.parentRecords[0].TypeOfEnterprise_URC__c : '';
            this.results.applicantEmployment.TypeOfOrganisation__c = data.parentRecords[0].TypeOfOrganisation__c ? data.parentRecords[0].TypeOfOrganisation__c : '';
            this.typeOfOrganisation = data.parentRecords[0].TypeOfOrganisation__c ? data.parentRecords[0].TypeOfOrganisation__c : '';
            this.results.applicantEmployment.UdyamRegistrationNumber__c = data.parentRecords[0].UdyamRegistrationNumber__c ? data.parentRecords[0].UdyamRegistrationNumber__c : '';
            this.results.applicantEmployment.WorkingWithCurrentEmployer_Months__c = data.parentRecords[0].WorkingWithCurrentEmployer_Months__c != null ? data.parentRecords[0].WorkingWithCurrentEmployer_Months__c.toString().padStart(2, '0') : '';
            this.results.applicantEmployment.WorkingWithCurrentEmployer_Years__c = data.parentRecords[0].WorkingWithCurrentEmployer_Years__c != null ? data.parentRecords[0].WorkingWithCurrentEmployer_Years__c.toString().padStart(2, '0') : '';
            this.results.applicantEmployment.CurrentBusinessVintage_Months__c = data.parentRecords[0].CurrentBusinessVintage_Months__c != null ? data.parentRecords[0].CurrentBusinessVintage_Months__c.toString().padStart(2, '0') : '';
            this.results.applicantEmployment.CurrentBusinessVintage_Years__c = data.parentRecords[0].CurrentBusinessVintage_Years__c != null ? data.parentRecords[0].CurrentBusinessVintage_Years__c.toString().padStart(2, '0') : '';
            this.results.applicantEmployment.EntityName__c = data.parentRecords[0].EntityName__c ? data.parentRecords[0].EntityName__c : '';
            this.results.applicantEmployment.ShareholdingInTheEntity__c = data.parentRecords[0].ShareholdingInTheEntity__c != null ? data.parentRecords[0].ShareholdingInTheEntity__c.toString() : '';
            this.results.applicantEmployment.NIC_URC__c = data.parentRecords[0].NIC_URC__c ? data.parentRecords[0].NIC_URC__c : '';
            this.results.applicantEmployment.MSME_Industry_selection__c = data.parentRecords[0].MSME_Industry_selection__c ? data.parentRecords[0].MSME_Industry_selection__c : '';

            this.results.applicantEmployment.Others__c = data.parentRecords[0].Others__c ? data.parentRecords[0].Others__c : '';
            this.results.applicantEmployment.Is_URC_UAC_available__c = data.parentRecords[0].Is_URC_UAC_available__c ? data.parentRecords[0].Is_URC_UAC_available__c : '';
            this.results.applicantEmployment.Select_applicability_for_URC_UAC__c = data.parentRecords[0].Select_applicability_for_URC_UAC__c ? data.parentRecords[0].Select_applicability_for_URC_UAC__c : '';
            this.results.applicantEmployment.UdyamAssistCertificate__c = data.parentRecords[0].UdyamAssistCertificate__c ? data.parentRecords[0].UdyamAssistCertificate__c : '';
            this.results.applicantEmployment.URC_UAC_application_ref_no__c = data.parentRecords[0].URC_UAC_application_ref_no__c ? data.parentRecords[0].URC_UAC_application_ref_no__c : '';
            this.results.applicantEmployment.URC_UAC_ApplicationDate__c = data.parentRecords[0].URC_UAC_ApplicationDate__c ? data.parentRecords[0].URC_UAC_ApplicationDate__c : '';
            //blfield
            this.results.applicantEmployment.TurnoverYear1__c = data.parentRecords[0].TurnoverYear1__c ? data.parentRecords[0].TurnoverYear1__c : '';
            this.results.applicantEmployment.TurnoverYear2__c = data.parentRecords[0].TurnoverYear2__c ? data.parentRecords[0].TurnoverYear2__c : '';
            this.results.applicantEmployment.IsMSME__c = data.parentRecords[0].IsMSME__c ? data.parentRecords[0].IsMSME__c : '';
            this.isMSME = data.parentRecords[0].IsMSME__c ? data.parentRecords[0].IsMSME__c : '';
            //blfield
            this.results.applicantEmployment.Proprietorship_firm_part_of_the_proposal__c = data.parentRecords[0].Proprietorship_firm_part_of_the_proposal__c ? data.parentRecords[0].Proprietorship_firm_part_of_the_proposal__c : '';
            this.isProprietorship = data.parentRecords[0].Proprietorship_firm_part_of_the_proposal__c ? data.parentRecords[0].Proprietorship_firm_part_of_the_proposal__c : undefined;

            this.GSTRegistered = data.parentRecords[0].GST_Registered__c ? data.parentRecords[0].GST_Registered__c : '';
            this.isGSTRegistered = this.GSTRegistered === 'YES' ? true : false;

            this.isEPFOTriggered = data.parentRecords[0].EPFOTriggered__c && data.parentRecords[0].EPFOTriggered__c === 'YES' ? true : false; //LAK-8730

            this.selectedApplicability = data.parentRecords[0].Select_applicability_for_URC_UAC__c ? data.parentRecords[0].Select_applicability_for_URC_UAC__c : '';
            this.selectedApplicabilityNew = data.parentRecords[0].Select_applicability_for_URC_UAC__c ? data.parentRecords[0].Select_applicability_for_URC_UAC__c : '';
            this.selectedAvailableURCUAC = data.parentRecords[0].Is_URC_UAC_available__c ? data.parentRecords[0].Is_URC_UAC_available__c : '';
            this.selectedAvailableURCUACNew = data.parentRecords[0].Is_URC_UAC_available__c ? data.parentRecords[0].Is_URC_UAC_available__c : '';

            this.isAvailableURCUAC = this.selectedAvailableURCUAC === 'YES' ? true : false;
            this.isNotAvailableURCUAC = this.selectedAvailableURCUAC === 'NO' ? true : false;

            this.isAvailableURCUACNew = this.selectedAvailableURCUACNew === 'YES' ? true : false;
            this.isNotAvailableURCUACNew = this.selectedAvailableURCUACNew === 'NO' ? true : false;

            this.isUACAvailable = (this.isAvailableURCUAC && this.selectedApplicability === 'UDYAM ASSIST CERTIFICATE (UAC)') ? true : false;
            this.isURCAvailable = (this.isAvailableURCUAC && this.selectedApplicability === 'UDYAM REGISTRATION NUMBER (URC)') ? true : false;

            this.isUACAvailableNew = (this.isAvailableURCUACNew && this.selectedApplicabilityNew === 'UDYAM ASSIST CERTIFICATE (UAC)') ? true : false;
            this.isURCAvailableNew = (this.isAvailableURCUACNew && this.selectedApplicabilityNew === 'UDYAM REGISTRATION NUMBER (URC)') ? true : false;

            this.selectedIndustryValue = data.parentRecords[0].IndustryType__c ? data.parentRecords[0].IndustryType__c : '';
            this.selectedIndustryName = data.parentRecords[0].IndustryType__c && data.parentRecords[0].IndustryType__r.Name ? data.parentRecords[0].IndustryType__r.Name : '';
            if (this.selectedIndustryValue != '') { this.getSubIndustriesPicklistValues(); }
            this.selectedSubIndustryValue = data.parentRecords[0].SubIndustry__c ? data.parentRecords[0].SubIndustry__c : '';
            this.selectedSubIndustryName = data.parentRecords[0].SubIndustry__c && data.parentRecords[0].SubIndustry__r.Name ? data.parentRecords[0].SubIndustry__r.Name : '';
            if (this.selectedIndustryValue != '' && this.selectedSubIndustryValue != '') {
                this.getRBIReportingIndustryPicklistValues();
                this.getClassOfActivityPicklistValues();
                this.selectedindustryRBIReportingValue = data.parentRecords[0].IndustryForRBIReporting__c ? data.parentRecords[0].IndustryForRBIReporting__c : '';
                this.selectedclassofActivityValue = data.parentRecords[0].ClassOfAct__c ? data.parentRecords[0].ClassOfAct__c : '';
                this.selectedMainRBIIndustryValue = data.parentRecords[0].MainRBIIndustry__c ? data.parentRecords[0].MainRBIIndustry__c : '';
            }
            //LAK-3051 -START
            if (this.designation === 'PROPRIETOR') {
                this.results.applicantEmployment.ShareholdingInTheEntity__c = 100;
                this.disableShareholding = true;
            }
            else {
                this.disableShareholding = false;
            }
            //LAK-3051 -END
            this.error = undefined;
            this.isLoading=false;
            
        } else if (error) {
            this.isLoading=false;
            console.error('Error:', error);
        }
        this.isLoading = false;
    }

    @track userTeamRoleData;
    @wire(getSobjectData, { params: '$parameterforTeam' })
    handleResponseTeamHierarchy(wiredResultTeam) {
        let { error, data } = wiredResultTeam;
        if (data) {
            if (data.parentRecords.length > 0) {
                let userTeamRole = data.parentRecords[0].EmpRole__c;
                this.userTeamRoleData = data.parentRecords[0].EmpRole__c;
                if (userTeamRole === 'RM') {
                    this.isGSTRequired = false;
                }
                else if (CPARoles && CPARoles.includes(userTeamRole)) {
                    this.isGSTRequired = true;
                } else {
                    this.isGSTRequired = true;
                }
            }
        } else if (error) {
            console.error('Error Team ------------->', error);
        }
    }
    get blView() {
        return this.loanProductType == 'Business Loan';
    }
    render() {
        return this.loanProductType == 'Business Loan' ? BL_view : HL_SSTLAP_view;
    }
    @track loanProductType;
    @track StagePickVal;
    @track reqFlagNaturOfBuss = false;
    @track wiredApplicationData;
    @track showBusinessAProfAvailField = false;
    @track gstAddressRequired = false;
    @wire(getSobjectData, { params: '$parameterLoanApplication' })
    loanApplicationDataHandler(wiredResultApplication) {
        let { error, data } = wiredResultApplication;
        this.wiredApplicationData = wiredResultApplication;
        if (data && data.parentRecords && data.parentRecords.length > 0) {
            this.StagePickVal = data.parentRecords[0].Stage__c ? data.parentRecords[0].Stage__c : null;
            this.loanProductType = data.parentRecords[0].Product__c ? data.parentRecords[0].Product__c : null; // BIL LAK-6716
            if (this.StagePickVal !== null && this.StagePickVal !== 'QDE') {
                this.showBusinessAProfAvailField = true;
                this.reqFlagNaturOfBuss = true;
                this.gstAddressRequired = true;
            } else {
                this.gstAddressRequired = false;
            }
        }
    }


    @track isProprietorship;
    @track isMSME;

    get displayGSTLayout() {
        if ((this.isGSTRegistered === true) && (this.results.applicant.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL' || this.results.applicant.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL')) {
            if (this.results.applicant.Constitution__c != 'INDIVIDUAL') {
                return true;
            } else if (this.results.applicant.Constitution__c === 'INDIVIDUAL' && this.isProprietorship && this.isProprietorship === 'NO') {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }

    }


    generatePicklist(data) {
        return data.values.map(item => ({ label: item.label, value: item.value }))
    }

    @wire(getObjectInfo, { objectApiName: APPLICANT_OBJECT })
    objInfo

    @wire(getPicklistValues, { recordTypeId: '$objInfo.data.defaultRecordTypeId', fieldApiName: CUSTOMER_PROFILE_FIELD })
    customerProfilePicklistHandler({ data, error }) {
        if (data) {
            this.customerProfileOptions = [...this.generatePicklist(data)]
            console.log('customerProfileOptions', this.customerProfileOptions)
        }
        if (error) {
            console.error('PicklistError', JSON.stringify(error))
        }
    }

    @wire(getObjectInfo, { objectApiName: ApplicantEmployment_OBJECT })
    ApplicantEmploymentobjInfo

    @wire(getPicklistValues, { recordTypeId: '$ApplicantEmploymentobjInfo.data.defaultRecordTypeId', fieldApiName: ORGANISATION_TYPE_FIELD })
    organisationTypePicklistHandler({ data, error }) {
        if (data) {
            this.organisationTypeOptions = [...this.generatePicklist(data)];
        }
        if (error) {
            console.log(error)
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$ApplicantEmploymentobjInfo.data.defaultRecordTypeId', fieldApiName: BUSINESS_NATURE_CORPORATE_FIELD })
    businessNatureCorporatePicklistHandler({ data, error }) {
        if (data) {
            this.businessNatureCorporateOptions = [...this.generatePicklist(data)];
        }
        if (error) {
            console.log(error)
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$ApplicantEmploymentobjInfo.data.defaultRecordTypeId', fieldApiName: BUSINESS_NATURE_INDIVIDUAL_FIELD })
    businessNatureIndividualPicklistHandler({ data, error }) {
        if (data) {
            this.businessNatureIndividualOptions = [...this.generatePicklist(data)];
        }
        if (error) {
            console.log(error)
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$ApplicantEmploymentobjInfo.data.defaultRecordTypeId', fieldApiName: DESIGNATION_VALUES_FIELD })
    designationPicklistHandler({ data, error }) {
        if (data) {
            this.designationOptions = [...this.generatePicklist(data)];
        }
        if (error) {
            console.log(error)
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$ApplicantEmploymentobjInfo.data.defaultRecordTypeId', fieldApiName: GST_REGISTERED_FIELD })
    GSTRegisteredHandler({ data, error }) {
        if (data) {
            this.GSTRegisteredOptions = [...this.generatePicklist(data)];
        }
        if (error) {
            console.log(error)
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$ApplicantEmploymentobjInfo.data.defaultRecordTypeId', fieldApiName: URC_UAC_APPLICABILITY_FIELD })
    applicabilityOptionsHandler({ data, error }) {
        if (data) {
            this.applicabilityOptions = [...this.generatePicklist(data)];
        }
        if (error) {
            console.log(error)
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$ApplicantEmploymentobjInfo.data.defaultRecordTypeId', fieldApiName: URC_UAC_AVAILABLE_FIELD })
    URC_UAC_AvailableHandler({ data, error }) {
        if (data) {
            this.URC_UAC_AvailableOptions = [...this.generatePicklist(data)];
        }
        if (error) {
            console.log(error)
        }
    }

    @track msmeIndustryOptions = [];

    @wire(getPicklistValues, { recordTypeId: '$ApplicantEmploymentobjInfo.data.defaultRecordTypeId', fieldApiName: MSME_INDUSTRY })
    msmeIndustryOptionsHandler({ data, error }) {
        if (data) {
            this.msmeIndustryOptions = [...this.generatePicklist(data)]
        }
        if (error) {
            console.log(error)
        }
    }

    getEmployersPicklistValues() {
        getData({ fields: "Name", objectName: "Employer__c", inputField: '', likeFilter: '', field1: '', filter1: '', field2: '', filter2: '' })
            .then(result => {
                this.employersPicklistOptions = result.map((record) => ({ label: record.Name, value: record.Id }));
                this.employersPicklistOptions.sort(this.compareByLabel);
                this.otherEmployerOption = result.find(item => item.Name === "OTHER");
                this.displayOthersOption = this.results.applicantEmployment.EmployerName__c === this.otherEmployerOption.Id ? true : false;
            })

    }

    //method to sort array of objects alphabetically
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



    getIndustriesPicklistValues() {
        getData({ fields: "Name", objectName: "Industry__c", inputField: '', likeFilter: '', field1: '', filter1: '', field2: '', filter2: '' })
            .then(result => {
                this.industriesPicklistOptions = result.map((record) => ({ label: record.Name, value: record.Id }));
                this.industriesPicklistOptions.sort(this.compareByLabel);
            })
    }

    getSubIndustriesPicklistValues() {
        getData({ fields: "Name", objectName: "SubIndustry__c", inputField: '', likeFilter: '', field1: 'Industry__c', filter1: this.selectedIndustryValue, field2: '', filter2: '' })
            .then(result => {
                this.subIndustriesPicklistOptions = result.map((record) => ({ label: record.Name, value: record.Id }));
                this.subIndustriesPicklistOptions.sort(this.compareByLabel);
            })
    };


    getRBIReportingIndustryPicklistValues() {
        if (this.selectedIndustryValue && this.selectedSubIndustryValue) {
            var rbiIndParameter = {
                ParentObjectName: 'RBI_ReportingIndustry__c',
                ChildObjectRelName: '',
                parentObjFields: ['Id', 'Name', 'MainRBIIndustry__c'],
                childObjFields: [],
                queryCriteria: ' where Industry__c = \'' + this.selectedIndustryValue + '\'' + ' AND SubIndustry__c = \'' + this.selectedSubIndustryValue + '\''
            }

        }

        getSobjectDataNonCacheable({ params: rbiIndParameter })
            .then(result => {
                if (result.length === 0) {
                }
                else {
                    if (result.parentRecords && result.parentRecords.length > 0) {
                        this.industryRBIReportingOptions = result.parentRecords.map((record) => ({ label: record.Name, value: record.Id }));
                        this.selectedindustryRBIReportingValue = this.industryRBIReportingOptions[0].value;
                        this.results.applicantEmployment.IndustryForRBIReporting__c = this.industryRBIReportingOptions[0].value;

                        this.mainRBIIndustryOptions = result.parentRecords.map((record) => ({ label: record.MainRBIIndustry__c, value: record.MainRBIIndustry__c }));
                        this.selectedMainRBIIndustryValue = this.mainRBIIndustryOptions[0].value;
                        this.results.applicantEmployment.MainRBIIndustry__c = this.mainRBIIndustryOptions[0].value;

                    }

                }
            }).catch(error => {
                console.log('RBI MAIN INDUSTRY error------------>', JSON.stringify(error));
            })
    };


    ////LAK-6270

    getClassOfActivityPicklistValues() {
        if (this.selectedIndustryValue && this.selectedSubIndustryValue) {
            var classofActivityParameter = {
                ParentObjectName: 'ClassOfActivity__c',
                ChildObjectRelName: '',
                parentObjFields: ['Id', 'ClassActName__c', 'Industry__c', 'Sub_Industry__c'],
                childObjFields: [],
                queryCriteria: ' where Industry__c = \'' + this.selectedIndustryValue + '\'' + ' AND Sub_Industry__c = \'' + this.selectedSubIndustryValue + '\''
            }

        }

        getSobjectDataNonCacheable({ params: classofActivityParameter })
            .then(result => {
                console.log('Data in ClassOfActiv', JSON.stringify(result))
                console.log('selectedIndustryName', JSON.stringify(this.selectedIndustryName))
                console.log('selectedSubIndustryValue', JSON.stringify(this.selectedSubIndustryValue))
                if (result.length === 0) {
                }
                else {

                    if (result.parentRecords && result.parentRecords.length > 0) {
                        this.classOfActivityOptions = result.parentRecords.map((record) => ({ label: record.ClassActName__c, value: record.Id }));
                        console.log('classOfActivityOptions', JSON.stringify(this.classOfActivityOptions))
                        this.selectedclassofActivityValue = this.classOfActivityOptions[0].value;
                        this.results.applicantEmployment.ClassOfAct__c = this.classOfActivityOptions[0].value;

                    }

                }
            }).catch(error => {
                console.log('RBI MAIN INDUSTRY error------------>', JSON.stringify(error));
            })
    };
    ///LAK-6270 END


    get subIndustriesFilterCondition() {
        return 'Industry__c=' + "'" + this.selectedIndustryValue + "'";
    }

    get RBIReportingIndustryFilterCondition() {
        return 'Industry__c=' + "'" + this.selectedIndustryValue + "'" + ' AND SubIndustry__c=' + "'" + this.selectedSubIndustryValue + "'";
    }

    get ClassOfActivityCondition() {
        return 'Industry__c=' + "'" + this.selectedIndustryValue + "'" + ' AND SubIndustry__c=' + "'" + this.selectedSubIndustryValue + "'";
    }

    triggerEPFO() {
        this.financialRecName = 'EPF UAN Lookup';
        this.showSpinner = true;

        const fields = {};

        fields[INTEGRATION_MSG_NAME_FIELD.fieldApiName] = 'EPF UAN Lookup';
        fields[BU_FIELD.fieldApiName] = 'HL / STL';
        fields[REFERENCE_ID_FIELD.fieldApiName] = this.appId;
        fields[STATUS_FIELD.fieldApiName] = 'New';
        fields[REFERENCE_OBJ_API_FIELD.fieldApiName] = 'Applicant__c';
        fields[SERVICE_NAME_FIELD.fieldApiName] = 'EPF UAN Lookup';
        fields[API_VENDOR__NAME_FIELD.fieldApiName] = 'Karza';
        fields[IS_ACTIVE_FIELD.fieldApiName] = true;
        fields[MSTATUS.fieldApiName] = 'Blank';


        const recordInput = {
            apiName: INTEGRATION_MSG_OBJECT.objectApiName,
            fields: fields
        };

        createRecord(recordInput).then((result) => {
        }).catch((error) => {
            console.log('Error ##1025', error)
            //refreshApex(this.wiredData);
            this.showSpinner = false
            this.showToastMessage('Error creating Integration record', error.body.message, 'error', 'sticky')
        });
    }


    @track typeOfOrganisation;
    @track designation;

    //LAK-6111
    @wire(getSobjectData, { params: '$parametersAppFinancialGST' })
    handleFinancialResponseGST(wiredFinancialGST) {
        let { error, data } = wiredFinancialGST;
        this.wiredDataFinancial = wiredFinancialGST;
        if (data) {
            if (data.parentRecords) {
                let gstFinResult = data.parentRecords;
                gstFinResult.forEach(gstRecord => {
                    /*if (gstRecord.RecordType && gstRecord.RecordType.DeveloperName === 'GST') {
                       this.gstFinDetails.push(gstRecord);
                    }*/
                    if (gstRecord.RecordType && gstRecord.RecordType.DeveloperName === 'GST') {
                        this.gstFinDetails.push(gstRecord);
                    } else if (!gstRecord.RecordType) {
                        this.gstFinDetails.push(gstRecord);
                    }
                });
            }
            else if (error) {
                console.log('Error employmentFinancialGSTDetails-->' + error);
            }
        }
    }

    @track
    recordTypeparameter = {
        ParentObjectName: 'RecordType  ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'DeveloperName', 'SobjectType'],
        childObjFields: [],
        queryCriteria: 'where SobjectType=\'' + 'Applicant_Financial__c' + '\''
    }

    @track GSTRecordTypeId;
    @wire(getSobjectData, { params: '$recordTypeparameter' })
    handleRecordType(wiredResult) {
        let { error, data } = wiredResult;
        if (data) {
            for (let i = 0; i < data.parentRecords.length; i++) {
                if (data.parentRecords[i].DeveloperName == 'GST') {
                    this.GSTRecordTypeId = data.parentRecords[i].Id;
                }
            }
        } else if (error) {
            console.error('Error ------------->', error);
        }
    }
    //LAK-6111
    ///START-LAK-6166
    @track BusinssProfAvail;
    handleInputBusinessProofChange(event) {
        this.BusinssProfAvail = event.target.value;

    }
    ///END-LAK-6166
    handleInputChange(event) {

        if (event.target.dataset.type === 'string') {
            let strVal = event.target.value;
            this.results[event.target.dataset.objname][event.target.dataset.fieldname] = strVal.toUpperCase();
        } else {
            this.results[event.target.dataset.objname][event.target.dataset.fieldname] = event.target.value;
        }

        if (event.target.value == 'NO' && event.target.dataset.fieldname == 'GST_Registered__c') {
            this.deleteAllGSTRecords();
            this.newGSTRec = [];
        }
        if (event.target.dataset.fieldname == 'IsMSME__c') {
            this.isMSME = event.target.value;

        }

        if (event.target.value == 'YES' && event.target.dataset.fieldname == 'GST_Registered__c') {
            if (this.addApplicantGSTRows.length === 0) {
                this.addApplicantGSTRows.push({
                    GSTIN__c: '',
                    GSTIN_Status__c: '',
                    RegisteredAddress_GST__c: '',
                    LegalNameOfBusiness_GST_Certificate__c: '',
                    HouseNo__c: '',
                    AddrLine1__c: '',
                    AddrLine2__c: '',
                    Landmark__c: '',
                    Locality__c: '',
                    Pincode__c: '',
                    City__c: '',
                    PinId__c: '',
                    CityId__c: '',
                    StateId__c: '',
                    State__c: '',
                    TradeName_GST_Certificate__c: '',
                    Main_GSTIN__c: false,
                    FetchFromSource__c: false,
                    LastSelectedAddrType__c: null,
                    Applicant_Address__c: null,
                    isAddrTypeMatch: false,
                    isAddrTypeSelected: false,
                    isGSTAddressSelected: false,
                    addressRecordId: null
                });
                this.deleteButtonDisabled = true;
            }
            this.newGSTRec.push({
                RecordTypeId: this.GSTRecordTypeId,
                Loan_Applicant__c: this.appId,
                sobjectType: 'Applicant_Financial__c'
            });
        }


        switch (event.target.name) {

            case 'designation':
                this.designation = event.target.value;
                //LAK-3051 -START
                if (this.designation === 'PROPRIETOR') {
                    this.results.applicantEmployment.ShareholdingInTheEntity__c = 100;
                    this.disableShareholding = true;
                }
                else {
                    this.disableShareholding = false;
                }
                //LAK-3051 -END
                break;

            case 'typeOfOrganisation':
                this.typeOfOrganisation = event.target.value;
                break;

            case 'proprietorshipProposal':
                this.isProprietorship = event.target.value ? event.target.value : undefined;
                if (this.isProprietorship && this.isProprietorship === 'YES') {
                }
                break;

            case 'industryType':

                this.selectedIndustryValue = event.target.value;
                this.selectedIndustryName = this.industriesPicklistOptions.find(option => option.value === this.selectedIndustryValue).label;
                this.subIndustriesPicklistOptions = undefined;
                this.selectedindustryRBIReportingValue = undefined;
                this.selectedclassofActivityValue = undefined;
                this.industryRBIReportingOptions = undefined;
                this.classOfActivityOptions = undefined;
                this.selectedMainRBIIndustryValue = undefined;
                this.mainRBIIndustryOptions = undefined;
                this.selectedSubIndustryValue = '';
                this.results[event.target.dataset.objname]['SubIndustry__c'] = '';
                this.getSubIndustriesPicklistValues();
                break;

            case 'subIndustryType':
                this.selectedSubIndustryValue = event.target.value;
                this.selectedSubIndustryName = this.subIndustriesPicklistOptions.find(option => option.value === this.selectedSubIndustryValue).label;
                this.selectedindustryRBIReportingValue = undefined;
                this.selectedclassofActivityValue = undefined;
                this.industryRBIReportingOptions = undefined;
                this.classOfActivityOptions = undefined;
                this.selectedMainRBIIndustryValue = undefined;
                this.mainRBIIndustryOptions = undefined;
                this.getRBIReportingIndustryPicklistValues();
                this.getClassOfActivityPicklistValues();
                break;

            case 'officialEmail':
                this.validateEmail();
                break;

            case 'workingWithCurrentEmployerYears':
                this.validate_Year(event);
                if (event.target.validity.valid) {
                    this.validateEmploymentYears();
                }
                break;

            case 'workingWithCurrentEmployerMonths':
                this.validate_Month(event);
                if (event.target.validity.valid) {
                    this.validateEmploymentYears();
                }
                break;

            case 'totalWorkExperienceYears':
                this.validate_Year(event);
                if (event.target.validity.valid) {
                    this.validateEmploymentYears();
                }
                break;
            case 'totalWorkExperienceMonths':
                this.validate_Month(event);
                if (event.target.validity.valid) {
                    this.validateEmploymentYears();
                }
                break;

            case 'currentBusinessVintageYears':
                this.validate_Year(event);
                if (event.target.validity.valid) {
                    this.validateEmploymentYears();
                }
                break;
            case 'currentBusinessVintageMonths':
                this.validate_Month(event);
                if (event.target.validity.valid) {
                    this.validateEmploymentYears();
                }
                break;

            case 'GSTRegistered':
                this.isGSTRegistered = event.target.value === 'YES' ? true : false;
                this.GSTRegistered = event.target.value;
                break;

            case 'udyamRegistrationNumber':
                this.validateUdyam();
                break;

            case 'udyamAssistCertificate':
                this.validateUdyamAssCert();
                break;

            case 'retirementAge':
                this.validateRetirementAge();
                break;

            case 'designationText':
                this.validateDesignationText();
                break;

            case 'others':
                break;

            case 'isURCUACAvailable':
                this.isAvailableURCUAC = event.target.value === 'YES' ? true : false;
                if (this.isAvailableURCUAC) {
                    this.isUACAvailable = (this.isAvailableURCUAC && this.selectedApplicability === 'UDYAM ASSIST CERTIFICATE (UAC)') ? true : false;
                    this.isURCAvailable = (this.isAvailableURCUAC && this.selectedApplicability === 'UDYAM REGISTRATION NUMBER (URC)') ? true : false;
                }
                this.isNotAvailableURCUAC = event.target.value === 'NO' ? true : false;
                if (event.target.value === 'NO') {
                    this.isURCAvailable = false;
                    this.isUACAvailable = false;
                }
                break;

            case 'isURCUACAvailableNew':
                this.isAvailableURCUACNew = event.target.value === 'YES' ? true : false;
                if (this.isAvailableURCUACNew) {
                    this.isUACAvailableNew = (this.isAvailableURCUACNew && this.selectedApplicabilityNew === 'UDYAM ASSIST CERTIFICATE (UAC)') ? true : false;
                    this.isURCAvailableNew = (this.isAvailableURCUACNew && this.selectedApplicabilityNew === 'UDYAM REGISTRATION NUMBER (URC)') ? true : false;
                }
                this.isNotAvailableURCUACNew = event.target.value === 'NO' ? true : false;
                if (event.target.value === 'NO') {
                    this.isURCAvailableNew = false;
                    this.isUACAvailableNew = false;
                }
                break;

            case 'applicabilityforURCUAC':
                this.isUACAvailable = (this.isAvailableURCUAC && event.target.value === 'UDYAM ASSIST CERTIFICATE (UAC)') ? true : false;
                this.isURCAvailable = (this.isAvailableURCUAC && event.target.value === 'UDYAM REGISTRATION NUMBER (URC)') ? true : false;
                break;


            case 'applicabilityforURCUACNew':
                this.isUACAvailableNew = (this.isAvailableURCUACNew && event.target.value === 'UDYAM ASSIST CERTIFICATE (UAC)') ? true : false;
                this.isURCAvailableNew = (this.isAvailableURCUACNew && event.target.value === 'UDYAM REGISTRATION NUMBER (URC)') ? true : false;
                break;
        }
    }



    validateEmploymentYears() {
        let currtEmpYears = this.template.querySelector('lightning-input[data-fieldname="WorkingWithCurrentEmployer_Years__c"]');
        let currtBussVinYears = this.template.querySelector('lightning-input[data-fieldname="CurrentBusinessVintage_Years__c"]');

        let isValidEmploymentYears = false;
        let totalExperienceMonths;
        let totalExperienceYears;
        let currentExpYears;
        let currentExpMonths;
        let message;

        if (currtEmpYears && this.results.applicantEmployment.WorkingWithCurrentEmployer_Years__c && this.results.applicantEmployment.TotalWorkExperience_Years__c &&
            this.results.applicantEmployment.WorkingWithCurrentEmployer_Months__c && this.results.applicantEmployment.TotalWorkExperience_Months__c) {
            currentExpYears = this.results.applicantEmployment.WorkingWithCurrentEmployer_Years__c;
            currentExpMonths = this.results.applicantEmployment.WorkingWithCurrentEmployer_Months__c;
            totalExperienceMonths = this.results.applicantEmployment.TotalWorkExperience_Months__c;
            totalExperienceYears = this.results.applicantEmployment.TotalWorkExperience_Years__c;
            message = 'Current Employer Experience should be less than or equal to Total Experience.';
        }
        else if (currtBussVinYears && this.results.applicantEmployment.CurrentBusinessVintage_Years__c && this.results.applicantEmployment.TotalWorkExperience_Years__c &&
            this.results.applicantEmployment.CurrentBusinessVintage_Months__c && this.results.applicantEmployment.TotalWorkExperience_Months__c) {
            currentExpMonths = this.results.applicantEmployment.CurrentBusinessVintage_Months__c;
            currentExpYears = this.results.applicantEmployment.CurrentBusinessVintage_Years__c;
            totalExperienceMonths = this.results.applicantEmployment.TotalWorkExperience_Months__c;
            totalExperienceYears = this.results.applicantEmployment.TotalWorkExperience_Years__c;
            message = 'Current Business Vintage Experience should be less than Total Experience';
        }
        else {
            if (this.isIndividualConstituiton === true) {
                return true;
            }
            return isValidEmploymentYears;
        }



        let totalExperience = (parseInt(totalExperienceYears) * 12) + parseInt(totalExperienceMonths);
        let currentExperience = (parseInt(currentExpYears) * 12) + parseInt(currentExpMonths);
        if (currentExperience > totalExperience) {
            try {
                isValidEmploymentYears = false;

                const event = new ShowToastEvent({
                    title: 'Error',
                    message: message,
                    variant: 'error',
                    mode: 'sticky'
                });

                this.dispatchEvent(event);
            }
            catch (exp) {
                console.log('Exception during employment experience validation ' + exp);
            }

        }
        else {
            isValidEmploymentYears = true;
        }

        return isValidEmploymentYears;
    }

    validateEmail() {
        const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        let email = this.template.querySelector(".emailValidateCls");
        if (email.value.match(emailRegex)) {
            email.setCustomValidity("");

        } else {
            email.setCustomValidity("Please enter a valid email");
        }
        email.reportValidity();

    }

    validateGSTIN() {
        const GSTINRegex = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/;
        let GSTIN = this.template.querySelector(".gstValidateCls");
        if (GSTIN.value.match(GSTINRegex) || GSTIN.value === '') {
            GSTIN.setCustomValidity("");

        } else {
            GSTIN.setCustomValidity("Please enter a valid GSTIN");
        }
        GSTIN.reportValidity();

    }

    validateUdyam() {
        const udyamRegex = /^UDYAM-[A-Z]{2}-[0-9]{2}-[0-9]{7}$/;
        let udyam = this.template.querySelector(".udyamValidateCls");
        if (udyam.value.match(udyamRegex)) {
            udyam.setCustomValidity("");

        } else {
            udyam.setCustomValidity("Please enter a valid Udyam Registration Number (i.e. UDYAM-AA-00-0000000)");
        }
        udyam.reportValidity();

    }

    validateUdyamAssCert() {
        const udyamRegex = /^UDYAM-[A-Z]{2}-[0-9]{2}-[0-9]{7}$/;
        let udyam = this.template.querySelector(".udyamAssiValdtCls");
        if (udyam.value.match(udyamRegex)) {
            udyam.setCustomValidity("");

        } else {
            udyam.setCustomValidity("Please enter a valid Udyam Assist Certificate Number (i.e. UDYAM-AA-00-0000000)");
        }
        udyam.reportValidity();

    }

    validateRetirementAge() {
        let age = this.template.querySelector(".retirementAgeValidateCls");
        if (age.value >= 21 && age.value <= 75) {
            age.setCustomValidity("");
        } else {
            age.setCustomValidity("Retirement age should range between 21 to 75");
        }
        age.reportValidity();
    }

    get currentDate() {
        let dt = new Date().toISOString().slice(0, 10);
        return dt;
    }

    validate_Year(event) {
        let dataId = event.target.dataset.id;
        const yearRegex = /^(0?[0-9]|[1-9][0-9])$/;
        const yearRegexForTwoDigits = /^\d{2}$/;
        let year = this.template.querySelector(`[data-id="${dataId}"]`);
        if (year.value.match(yearRegex)) {
            year.setCustomValidity("");

        } else {
            year.setCustomValidity("Please enter a valid Number.");
        }
        year.reportValidity();

    }

    validate_Month(event) {
        let dataId = event.target.dataset.id;
        const monthRegex = /^(0?[0-9]|1[0-2])$/;
        const yearRegexForTwoDigits = /^\d{2}$/;
        let month = this.template.querySelector(`[data-id="${dataId}"]`);
        if (month.value.match(monthRegex)) {
            month.setCustomValidity("");

        } else {
            month.setCustomValidity("Please enter a valid Number.");
        }
        month.reportValidity();
    }

    validateDesignationText() {

        const textRegex = /^[a-zA-Z][A-Za-z\s]*$/;
        let designation = this.template.querySelector(".designationTextValidateCls");
        if (designation.value.match(textRegex)) {
            designation.setCustomValidity("");

        } else {
            designation.setCustomValidity("Please enter a valid input");
        }
        designation.reportValidity();
    }

    initiateEPFOMsg(){
        if (this.isSalaried && !this.isEPFOTriggered && (this.isPhysicalConsentValidated == true || this.isApplMobileverification == true)) {
            console.log('this.isPhysicalConsentValidated :: this.isApplMobileverification:: this.isEPFOTriggered:: this.isSalaried:: ',this.isPhysicalConsentValidated,this.isApplMobileverification,this.isEPFOTriggered,this.isSalaried)
            this.triggerEPFO();
        }
    }



    @track GSTRegistered;
    @track isGSTRegistered = false;

    handleSave(validate) {
        if (this.borrowerType && this.borrowerType != 'Non Financial') {
            if (validate) {
                let isInputCorrect = (this.reportValidity() && this.checkclassOfActivityLookupValidity());
                if (isInputCorrect === true) {
                    if (this.isIndividualConstituiton === true) {
                        let isValidExperience = this.validateEmploymentYears();
                        if (isValidExperience) {
                            this.createOrUpdateRecord();
                        }
                        this.handleFinancialGSTSave();
                        this.childDataSaveHandler();
                        this.initiateEPFOMsg();
                    }
                    else {
                        if (this.displayGSTLayout === true) {
                            if (this.addApplicantGSTRows) {
                                var mainGSTRecord = 0;
                                for (var i = 0; i < this.addApplicantGSTRows.length > 0; i++) {
                                    if (this.addApplicantGSTRows[i].Main_GSTIN__c === true) {
                                        mainGSTRecord = mainGSTRecord + 1;
                                    }
                                }
                                if (mainGSTRecord > 1) {
                                    this.showToastMessage('Error', this.label.EmploymentDetails_SelectGst_ErrorMessage, 'error', 'sticky');

                                }
                                else if (mainGSTRecord == 0) {
                                    this.showToastMessage('Error', 'Please select one GST as Main GSTIN.', 'error', 'sticky');
                                }
                                else {
                                    if ((this.applicantType === 'C' || this.applicantType === 'G') && (this.isPhysicalConsentValidated == true || this.isApplMobileverification == true)) {
                                        this.createOrUpdateRecord();
                                        this.handleFinancialGSTSave();
                                        this.initiateEPFOMsg();
                                    } else if (this.applicantType === 'P') {
                                        this.createOrUpdateRecord();
                                        this.handleFinancialGSTSave();
                                        this.initiateEPFOMsg();
                                    } else {
                                        this.showToastMessage('Error', this.label.EmploymentDetails_Consent_ErrorMessage, 'error', 'sticky');

                                    }
                                    this.childDataSaveHandler();
                                }

                            } else {
                                if ((this.applicantType === 'C' || this.applicantType === 'G') && (this.isPhysicalConsentValidated == true || this.isApplMobileverification == true)) {
                                    this.createOrUpdateRecord();
                                    this.handleFinancialGSTSave();
                                    this.initiateEPFOMsg();
                                } else if (this.applicantType === 'P') {
                                    this.createOrUpdateRecord();
                                    this.handleFinancialGSTSave();
                                    this.initiateEPFOMsg();
                                } else {
                                    this.showToastMessage('Error', this.label.EmploymentDetails_Consent_ErrorMessage, 'error', 'sticky');
                                }
                                this.childDataSaveHandler();
                            }
                        } else {
                            if ((this.applicantType === 'C' || this.applicantType === 'G') && (this.isPhysicalConsentValidated == true || this.isApplMobileverification == true)) {
                                this.createOrUpdateRecord();
                                this.handleFinancialGSTSave();
                                this.initiateEPFOMsg();
                            } else if (this.applicantType === 'P') {
                                this.createOrUpdateRecord();
                                this.handleFinancialGSTSave();
                                this.initiateEPFOMsg();
                            } else {
                                this.showToastMessage('Error', this.label.EmploymentDetails_Consent_ErrorMessage, 'error', 'sticky');
                            }
                            this.childDataSaveHandler();
                        }
                    }
                    // if(this.isSalaried && !this.isEPFOTriggered){
                    //     this.isEPFOTriggered = true;
                    //     this.results.applicantEmployment.EPFOTriggered__c='YES';
                    // }
                }
                else {
                    this.showToastMessage('Error', this.label.EmploymentDetails_FillReqFields_ErrorMessage, 'error', 'sticky');
                }
            }
            else {
                this.createOrUpdateRecord();
                this.handleFinancialGSTSave();
                this.childDataSaveHandler();
            }
        }
        else{
            this.isLoading = false;
        }
    }

    handleFinancialGSTSave() {
        console.log('INSIDE handleFinancialGSTSave')
        if (this.isGSTRegistered === false) {
            let paramDisbSplitDisb = {
                ParentObjectName: 'Applicant_Financial__c ',
                ChildObjectRelName: 'Applicant_Financial_Summary_s__r',
                parentObjFields: ['Id'],
                childObjFields: ['Id'],
                queryCriteria: ' where Loan_Applicant__c = \'' + this.appId + '\' and RecordType.DeveloperName = \'GST\''

            }
            let gstFinDetailsdel = [];
            getSobjectDataWithoutCacheable({ params: paramDisbSplitDisb })
                .then((result) => {
                    if (result) {
                        result.forEach(item => {
                            gstFinDetailsdel.push(item.parentRecord);
                        })
                        console.log('GST Recordss--------->', JSON.stringify(gstFinDetailsdel));

                        if (gstFinDetailsdel && gstFinDetailsdel.length > 0) {
                            var deleteAllRecordsJSON = [];
                            gstFinDetailsdel.forEach(element => {
                                if (element.hasOwnProperty("Id")) {
                                    var deleteRecordData = { Id: element.Id, sobjectType: 'Applicant_Financial__c' };
                                    deleteAllRecordsJSON.push(deleteRecordData);
                                }
                            });

                            if (deleteAllRecordsJSON && deleteAllRecordsJSON.length > 0) {
                                deleteRecord({ rcrds: deleteAllRecordsJSON })
                                    .then(() => {
                                        gstFinDetailsdel = [];
                                        deleteAllRecordsJSON = [];
                                    })
                                    .catch(error => {
                                    })
                            } else if (gstFinDetailsdel && gstFinDetailsdel.length > 0) {
                                this.gstFinDetailsdel = [];
                            }
                        }
                    }
                })
                .catch(error => {
                    this.showToastMessage('Error', 'An unexpected error occurred. Please try again.', 'error', 'sticky');
                    console.log('Error In deleteGSTRecord---------->', JSON.stringify(error));
                    this.showSpinner = false;

                });
            this.handleSaveBusinessProofAvai();
        }
        else {
            refreshApex(this.wiredDataFinancial);
            var gstDataRecords = this.gstFinDetails;
            let paramDisbSplitDisb = {
                ParentObjectName: 'Applicant_Financial__c ',
                ChildObjectRelName: 'Applicant_Financial_Summary_s__r',
                parentObjFields: ['Id'],
                childObjFields: ['Id'],
                queryCriteria: ' where Loan_Applicant__c = \'' + this.appId + '\' and RecordType.DeveloperName = \'GST\''

            }
            let gstFinDetailsdel = [];
            getSobjectDataWithoutCacheable({ params: paramDisbSplitDisb })
                .then((result) => {
                    if (result) {
                        result.forEach(item => {
                            gstFinDetailsdel.push(item.parentRecord);
                        })
                    }

                    if (gstFinDetailsdel.length === 0 && this.newGSTRec.length !== 0) {
                        let fields;
                        fields = {
                            Id: this.appId,
                            Businessproofavailable__c: this.BusinssProfAvail,
                            sobjectType: 'Applicant__c'
                        }
                        const UpsertRecordData = [...this.newGSTRec, fields]

                        upsertMultipleRecord({ params: UpsertRecordData })
                            .then(result => {
                                refreshApex(this.gstFinDetails);
                                this.count++;
                            })
                            .catch(error => {
                                this.showToastMessage('Error', this.label.EmploymentDetails_Save_ErrorMessage, 'error', 'sticky');
                                console.log('ERROR 3')
                                console.error('Error updating record with Id ' + error.body.message);
                                console.log('Error In handleFinancialGSTSave ' + JSON.stringify(error));
                            })
                    }
                    else {
                        this.handleSaveBusinessProofAvai();
                    }
                })
                .catch(error => {
                    this.showToastMessage('Error', 'An unexpected error occurred. Please try again.', 'error', 'sticky');
                    console.log('Error In deleteGSTRecord---------->', JSON.stringify(error));
                    this.showSpinner = false;

                });
        }
    }

    handleSaveBusinessProofAvai() {
        let fields;
        fields = {
            Id: this.appId,
            Businessproofavailable__c: this.BusinssProfAvail
        }
        let fieldsSave = [fields]
        upsertMultipleRecord({
            params: fieldsSave
        })
            .then(result => {
                refreshApex(this.wiredDataFinancial);
                this.cretSucc = true;
                //this.handleFinancialGSTSave;
            }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    })

                );
            })
    }

    //This is for Class of Activity master value check
    checkclassOfActivityLookupValidity() {
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

    @api reportValidity() {
        let isInputCorrect = [
            ...this.template.querySelectorAll("lightning-input"),
            ...this.template.querySelectorAll("lightning-combobox"),
            ...this.template.querySelectorAll("lightning-radio-group")
        ].reduce((validSoFar, inputField) => {

            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);


        if (this.template.querySelectorAll("c-capture-g-s-t-address-details")) {
            let validateAddressDetails = this.template.querySelectorAll("c-capture-g-s-t-address-details");
            if (validateAddressDetails) {
                validateAddressDetails.forEach(component => {
                    if (component.validateForm() == false) {
                        isInputCorrect = false;
                        return
                    }
                });
            }
        }

        return isInputCorrect;
    }


    createOrUpdateRecord() {
        this.isLoading = true;
        if (this.EmploymentDataId) {
            this.results.applicantEmployment.Id = this.EmploymentDataId;
            //LAK-8730
            if (this.isSalaried && !this.isEPFOTriggered) {
                this.results.applicantEmployment.EPFOTriggered__c = 'YES';
            }
            var employmentDetailsJSON = this.results.applicantEmployment;
            employmentDetailsJSON.LoanApplicant__c = this.appId;
            employmentDetailsJSON.sobjectType = 'ApplicantEmployment__c';

            let upsertDataJSON = {
                parentRecord: employmentDetailsJSON,
                ChildRecords: [],
                ParentFieldNameToUpdate: 'ApplicantEmployment__c'
            }

            upsertSobjDataWIthRelatedChilds({ upsertData: upsertDataJSON })
                .then(result => {
                    // Check if loan product type is 'Business Loan' or 'Personal Loan'
                    if (this.loanProductType === 'Business Loan' || this.loanProductType === 'Personal Loan') {
                        this.showToastMessage('Success', this.label.BusinessDetails_Save_SuccessMessage, 'success', 'sticky');
                    } else {
                        // Default success message for other loan types
                        this.showToastMessage('Success', this.label.EmploymentDetails_Save_SuccessMessage, 'success', 'sticky');
                    }

                    this.handleRefreshAllData();
                    console.log('Success', this.label.EmploymentDetails_Save_SuccessMessage);
                    this.isLoading = false;
                })
                .catch(error => {
                    this.showToastMessage('Error', this.label.EmploymentDetails_Update_ErrorMessage, 'error', 'sticky');
                    console.log('ERROR 2', error);
                    this.isLoading = false;
                });

        }
        else {

            var employmentDetailsJSONNew = this.results.applicantEmployment;
            employmentDetailsJSONNew.LoanApplicant__c = this.appId;
            employmentDetailsJSONNew.sobjectType = 'ApplicantEmployment__c';

            let upsertDataJSONNew = {
                parentRecord: employmentDetailsJSONNew,
                ChildRecords: [],
                ParentFieldNameToUpdate: 'ApplicantEmployment__c'
            }

            upsertSobjDataWIthRelatedChilds({ upsertData: upsertDataJSONNew })
                .then(result => {
                    var employmentRecordId = result.parentRecord ? result.parentRecord.Id : null;
                    this.EmploymentDataId = employmentRecordId;
                    this.handleRefreshAllData();
                    this.showToastMessage('Success', this.label.EmploymentDetails_Save_SuccessMessage, 'success', 'sticky');
                    console.log('Success22222',EmploymentDetails_Save_SuccessMessage);
                    this.isLoading = false;
                })
                .catch(error => {
                    this.showToastMessage('Error', this.label.EmploymentDetails_Save_ErrorMessage, 'error', 'sticky');
                    console.log('ERROR 1')
                    this.isLoading = false;
                })
        }

    }


    handleRefreshAllData() {
        refreshApex(this.wiredDataApplicant);
        refreshApex(this.wiredDataGST);
        refreshApex(this.wiredDataOfApplTypeEmp);
        refreshApex(this.wiredApplicationData);
        refreshApex(this.wiredFinancialGST);
    }

    @track deleteButtonDisabled = false;
    @track moreThanOneGSTAvailable;
    @track rows = [];
    @track multipleFilter;
    @track newIndex;
    @track originalData = [];

    @track keyIndex = 0;
    @track addApplicantGSTRows = [
        {
            GSTIN__c: '',
            GSTIN_Status__c: '',
            RegisteredAddress_GST__c: '',
            LegalNameOfBusiness_GST_Certificate__c: '',
            HouseNo__c: '',
            AddrLine1__c: '',
            AddrLine2__c: '',
            Locality__c: '',
            Landmark__c: '',
            Pincode__c: '',
            City__c: '',
            PinId__c: '',
            CityId__c: '',
            StateId__c: '',
            State__c: '',
            TradeName_GST_Certificate__c: '',
            Main_GSTIN__c: false,
            FetchFromSource__c: false,
            LastSelectedAddrType__c: null,
            Applicant_Address__c: null,
            isAddrTypeMatch: false,
            isAddrTypeSelected: false,
            isGSTAddressSelected: false
        }
    ];


    @track GSTIN__c;

    //For Adding  GST Row  
    rowHandle() {
        this.multipleFilter = true;
        this.keyIndex + 1;
        this.addApplicantGSTRows.push({
            GSTIN__c: '',
            GSTIN_Status__c: '',
            RegisteredAddress_GST__c: '',
            LegalNameOfBusiness_GST_Certificate__c: '',
            HouseNo__c: '',
            AddrLine1__c: '',
            AddrLine2__c: '',
            Locality__c: '',
            Landmark__c: '',
            Pincode__c: '',
            City__c: '',
            PinId__c: '',
            CityId__c: '',
            StateId__c: '',
            State__c: '',
            TradeName_GST_Certificate__c: '',
            Main_GSTIN__c: false,
            FetchFromSource__c: false,
            LastSelectedAddrType__c: null,
            Applicant_Address__c: null,
            isAddrTypeMatch: false,
            isAddrTypeSelected: false,
            isGSTAddressSelected: false,
            addressRecordId: null
        });

        if (this.addApplicantGSTRows.length > 1) {
            this.deleteButtonDisabled = false;
        }
    }


    handleRemoveRecord(event) {
        this.isLoading = true;
        if (this.gstinIDValue) {
            var deleteRecordJson = [{
                Id: this.gstinIDValue,
                sobjectType: 'ApplGST__c'
            }];

            deleteRecord({ rcrds: deleteRecordJson })
                .then(() => {
                    this.showToastMessage('Success', this.label.EmploymentDetails_Del_SuccessMessage, 'success', 'sticky');
                    this.isModalOpen = false;

                    if (this.addApplicantGSTRows && this.addApplicantGSTRows.length >= 1) {
                        this.addApplicantGSTRows.splice(this.searchIndexGSTData, 1);
                        this.keyIndex - 1;
                        let len = this.addApplicantGSTRows.length;
                        if (len <= 1) {
                            this.deleteButtonDisabled = true;
                            this.moreThanOneGSTAvailable = false;
                        }
                        this.gstinIDValue = undefined;
                        this.searchIndexGSTData = undefined;
                    }
                    this.isLoading = false;
                });

        } else {

            if (this.addApplicantGSTRows.length >= 1) {
                this.addApplicantGSTRows.splice(this.searchIndexGSTData, 1);
                this.keyIndex - 1
            };
            let len = this.addApplicantGSTRows.length;
            if (len <= 1) {
                this.deleteButtonDisabled = true;
                this.moreThanOneGSTAvailable = false;
            }
            this.isModalOpen = false;
            this.isLoading = false;

        }

    }

    closeModal() {
        this.isModalOpen = false;
    }

    @track searchIndexGSTData;

    rowDeletHandle(event) {
        this.isModalOpen = true;
        this.searchIndexGSTData = undefined;
        this.gstinIDValue = undefined;
        this.searchIndexGSTData = event.target.accessKey;
        let searchIndex = event.target.accessKey;
        if (searchIndex >= 0 && searchIndex < this.addApplicantGSTRows.length) {
            this.gstinIDValue = this.addApplicantGSTRows[searchIndex].Id;
        }


    }

    handleGSTInputChange(event) {

        const fieldName = event.target.getAttribute('data-fieldname');
        const checkBoxValue = event.target.checked;
        const index = event.target.accessKey;

        const fieldValue = event.target.value;
        if (fieldName === 'GSTIN__c') {
            this.addApplicantGSTRows[index].GSTIN__c = fieldValue.toUpperCase();
        } else if (fieldName === 'GSTIN_Status__c') {
            this.addApplicantGSTRows[index].GSTIN_Status__c = fieldValue.toUpperCase();
        }
        else if (fieldName === 'RegisteredAddress_GST__c') {
            this.addApplicantGSTRows[index].RegisteredAddress_GST__c = fieldValue.toUpperCase();
        }
        else if (fieldName === 'LegalNameOfBusiness_GST_Certificate__c') {
            this.addApplicantGSTRows[index].LegalNameOfBusiness_GST_Certificate__c = fieldValue.toUpperCase();
        }
        else if (fieldName === 'TradeName_GST_Certificate__c') {
            this.addApplicantGSTRows[index].TradeName_GST_Certificate__c = fieldValue.toUpperCase();
        }
        else if (fieldName === 'Main_GSTIN__c') {
            this.addApplicantGSTRows[index].Main_GSTIN__c = checkBoxValue;
        }
        else if (fieldName === 'FetchFromSource__c') {
            this.addApplicantGSTRows[index].FetchFromSource__c = checkBoxValue;
        }
        else if (fieldName === 'LastSelectedAddrType__c') {
            if (fieldValue) {
                this.addApplicantGSTRows[index].LastSelectedAddrType__c = fieldValue;
                this.handleAddressTypeChange(event.target.accessKey, fieldValue);
            }
        } else if (fieldName === 'AddrLine1__c') {
            this.addApplicantGSTRows[index].AddrLine1__c = fieldValue.toUpperCase();
        } else if (fieldName === 'AddrLine2__c') {
            this.addApplicantGSTRows[index].AddrLine2__c = fieldValue.toUpperCase();
        } else if (fieldName === 'Locality__c') {
            this.addApplicantGSTRows[index].Locality__c = fieldValue.toUpperCase();
        } else if (fieldName === 'HouseNo__c') {
            this.addApplicantGSTRows[index].HouseNo__c = fieldValue.toUpperCase();
        } else if (fieldName === 'Landmark__c') {
            this.addApplicantGSTRows[index].Landmark__c = fieldValue.toUpperCase();
        }
        else if (error) {
            console.log(error)
        }

    }

    //LAK-6480: Getting child data & GST details & GST address.
    childDataSaveHandler() {
        if (this.isGSTRegistered) {
            let addressDataToSave = [];
            if (this.template.querySelectorAll("c-capture-g-s-t-address-details")) {
                let saveAddressDetails = this.template.querySelectorAll("c-capture-g-s-t-address-details");
                if (saveAddressDetails) {
                    saveAddressDetails.forEach(component => {
                        component.handleUpsert();
                        addressDataToSave.push(component.localAddressvalue);

                    });
                }
            }

            if (addressDataToSave && addressDataToSave.length > 0) {
                this.handleSaveAddressRecords(addressDataToSave);
            } else {
                this.handleGSTInputSave(addressDataToSave);
            }
        }

    }

    //LAK-6480: To save address details. And filter address record if address type is similar.
    handleSaveAddressRecords(updatedAddrRecord) {
        if (updatedAddrRecord && updatedAddrRecord.length > 0) {
            if (updatedAddrRecord && updatedAddrRecord.length > 0) {
                updatedAddrRecord.forEach(addrRecord => {
                    addrRecord.Applicant__c = this.appId;
                    addrRecord.sobjectType = 'ApplAddr__c';
                });
            }

            let finalAddressData = [];
            const indexValues = {};
            updatedAddrRecord.forEach(item => {
                const index = item.AddrTyp__c;
                indexValues[index] = item;
            });
            const updatedArray = Object.values(indexValues);
            finalAddressData = [...updatedArray];
            if (finalAddressData && finalAddressData.length > 0) {
                upsertMultipleRecord({ params: finalAddressData })
                    .then(addrRecords => {
                        this.handleGSTInputSave(addrRecords);
                    })
                    .catch(error => {
                        this.showToastMessage('Error', 'An unexpected error occurred. Please try again.', 'error', 'sticky');
                        this.isLoading = false;
                    })
            }
        }
    }

    //LAK-6480: To save GST details. 
    handleGSTInputSave(addrRecords) {
        if (addrRecords && addrRecords.length > 0) {
            let applAddressRecords = [...addrRecords]
            let updatedGSTArray = [];
            if (this.addApplicantGSTRows && this.addApplicantGSTRows.length > 0) {
                for (let i = 0; i < this.addApplicantGSTRows.length; i++) {
                    let tempAddrRecord = applAddressRecords.find(record =>
                        record.AddrTyp__c === this.addApplicantGSTRows[i].LastSelectedAddrType__c);

                    if (tempAddrRecord) {
                        this.addApplicantGSTRows[i].Applicant_Address__c = tempAddrRecord.Id;
                    }
                }
                updatedGSTArray = [...this.addApplicantGSTRows];

            }

            if (updatedGSTArray && updatedGSTArray.length > 0) {
                updatedGSTArray.forEach(gstRecord => {
                    gstRecord.Applicant__c = this.appId;
                    gstRecord.sobjectType = 'ApplGST__c';
                });
            }

            let updatedGSTRec = [];
            if (updatedGSTArray && updatedGSTArray.length > 0) {
                updatedGSTRec = updatedGSTArray.map(item => {
                    const { isAddrTypeSelected, addressRecordId, isAddrTypeMatch, isGSTAddressSelected, ...rest } = item;
                    return rest;
                });
            }

            if (updatedGSTRec && updatedGSTRec.length > 0) {
                upsertMultipleRecord({ params: updatedGSTRec })
                    .then(result => {
                        this.handleRefreshAllData();
                        this.isLoading = false;
                    })
                    .catch(error => {
                        this.showToastMessage('Error', 'An unexpected error occurred. Please try again.', 'error', 'sticky');
                        this.isLoading = false;
                    })


            }
        }
        else {
            if (this.addApplicantGSTRows && this.addApplicantGSTRows.length > 0) {

                let finalGSTData = [...this.addApplicantGSTRows];
                if (finalGSTData && finalGSTData.length > 0) {
                    finalGSTData.forEach(gstRecord => {
                        gstRecord.Applicant__c = this.appId;
                        gstRecord.sobjectType = 'ApplGST__c';
                    });
                }

                let updatedGSTRec1 = [];
                if (finalGSTData && finalGSTData.length > 0) {
                    updatedGSTRec1 = finalGSTData.map(item => {
                        const { isAddrTypeSelected, addressRecordId, isAddrTypeMatch, isGSTAddressSelected, ...rest } = item;
                        return rest;
                    });
                }

                if (updatedGSTRec1 && updatedGSTRec1.length > 0) {
                    upsertMultipleRecord({ params: updatedGSTRec1 })
                        .then(result => {
                            this.handleRefreshAllData();
                            this.isLoading = false;
                        })
                        .catch(error => {
                            this.showToastMessage('Error', 'An unexpected error occurred. Please try again.', 'error', 'sticky');
                            this.isLoading = false;
                        })
                }
            }

        }


    }


    //Add Row Functionality Ended Here>>>>>>>>>>>>>>>>>>>>>>>>>>> 

    handleActualGSTData() {
        if (this.actualGSTData && this.actualGSTData.length > 0) {
            this.addApplicantGSTRows = [];
            let count = -1;
            this.actualGSTData.forEach(newItem => {
                count++
                let newObj = {
                    Id: newItem.Id,
                    GSTIN__c: newItem.GSTIN__c || '',
                    GSTIN_Status__c: newItem.GSTIN_Status__c || '',
                    LegalNameOfBusiness_GST_Certificate__c: newItem.LegalNameOfBusiness_GST_Certificate__c || '',
                    HouseNo__c: newItem.HouseNo__c || '',
                    AddrLine1__c: newItem.AddrLine1__c || '',
                    AddrLine2__c: newItem.AddrLine2__c || '',
                    Landmark__c: newItem.Landmark__c || '',
                    Locality__c: newItem.Locality__c || '',
                    Pincode__c: newItem.Pincode__c || '',
                    City__c: newItem.City__c || '',
                    State__c: newItem.State__c || '',
                    TradeName_GST_Certificate__c: newItem.TradeName_GST_Certificate__c || '',
                    Main_GSTIN__c: newItem.Main_GSTIN__c || false,
                    FetchFromSource__c: newItem.FetchFromSource__c || false,
                    RegisteredAddress_GST__c: newItem.RegisteredAddress_GST__c || '',
                    LastSelectedAddrType__c: newItem.LastSelectedAddrType__c ? newItem.LastSelectedAddrType__c : null,
                    isAddrTypeSelected: newItem.LastSelectedAddrType__c ? true : false,
                    isGSTAddressSelected: (newItem.LastSelectedAddrType__c && newItem.LastSelectedAddrType__c === 'GST Address') ? true : false,
                    Applicant_Address__c: newItem.Applicant_Address__c ? newItem.Applicant_Address__c : null,
                    addressRecordId: newItem.Applicant_Address__c ? newItem.Applicant_Address__c : null,


                };

                this.addApplicantGSTRows.push(newObj);

                //LAK-6480: Forming array to store index wise address type to send child component
                this.addrDetailObj = { index: count, typeofaddress: newItem.LastSelectedAddrType__c };
                this.tempArr = [...this.tempArr, this.addrDetailObj];

                const indexValues = {};
                this.tempArr.forEach(item => {
                    const index = item.index;
                    indexValues[index] = item;
                });
                const updatedArray = Object.values(indexValues);
                this.addressTypeData = [...updatedArray];
                //LAK-6480

            });

            console.log('addApplicantGSTRows-------------->', JSON.stringify(this.addApplicantGSTRows));

            if (this.addApplicantGSTRows.length <= 1) {
                this.deleteButtonDisabled = true;
            } else {
                this.deleteButtonDisabled = false;
            }

        }

    }


    //Code for If GST Registered value is selected as NO  then Delete All GST Records
    deleteAllGSTRecords() {
        this.isLoading = true;
        if (this.addApplicantGSTRows && this.addApplicantGSTRows.length > 0) {
            var deleteAllRecordsJSON = [];
            this.addApplicantGSTRows.forEach(element => {
                if (element.hasOwnProperty("Id")) {
                    var deleteRecordData = { Id: element.Id, sobjectType: 'ApplGST__c' };
                    deleteAllRecordsJSON.push(deleteRecordData);
                }
            });

            if (deleteAllRecordsJSON && deleteAllRecordsJSON.length > 0) {
                deleteRecord({ rcrds: deleteAllRecordsJSON })
                    .then(() => {
                        refreshApex(this.wiredDataGST);
                        this.addApplicantGSTRows = [];
                        deleteAllRecordsJSON = [];
                        this.isLoading = false;
                    })
                    .catch(error => {
                        this.isLoading = false;
                    })
            } else if (this.addApplicantGSTRows && this.addApplicantGSTRows.length > 0) {
                this.addApplicantGSTRows = [];
                this.isLoading = false;
            }
        }
    }


    renderedCallback() {
        this.handleRefreshAllData();
    }

    showToastMessage(title, message, variant, mode) {
        const evt = new ShowToastEvent({ title, message, variant, mode });
        this.dispatchEvent(evt);
    }

    //LAK-6480
    @track paramsForApplAddress = {
        ParentObjectName: 'ApplAddr__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'City__c', 'AddrTyp__c', 'State__c', 'Pincode__c', 'AddrLine1__c', 'AddrLine2__c', 'HouseNo__c', 'Locality__c', 'Landmark__c'],
        childObjFields: [],
        queryCriteria: ' where Applicant__c = \'' + this.appId + '\''
    }

    @track wiredDataForApplAddr;
    @track applAddressRecs = [];
    @track applWrapData;
    @track requiresFlagForGST = true;
    @track accessKeyForGST;
    @track addrDetailObj;
    @track tempArr = [];
    @track addressTypeData = [];
    @track addrDataFromChild = {};

    //LAK-6480: To get GST details & Address details from wire. And Process data further to show on UI.
    handleDataProcessor(data) {
        if (data) {
            if (data && data.Applicant_Addresses__r && data.Applicant_Addresses__r.length > 0) {
                this.applAddressRecs = [];
                for (let i = 0; i < data.Applicant_Addresses__r.length; i++) {
                    if (data.Applicant_Addresses__r[i].AddrTyp__c) {
                        let addrTypeOptWithId = { ...data.Applicant_Addresses__r[i] };
                        this.applAddressRecs.push(addrTypeOptWithId);
                    }
                }
                if (data && data.Applicant_GST__r && data.Applicant_GST__r.length > 0) {
                    let tempGSTArr1 = data.Applicant_GST__r;
                    this.actualGSTData = [...tempGSTArr1];
                    this.handleActualGSTData();
                }

            } else {
                if (data && data.Applicant_GST__r && data.Applicant_GST__r.length > 0) {
                    let tempGSTArr2 = data.Applicant_GST__r;
                    this.actualGSTData = [...tempGSTArr2];
                    this.handleActualGSTData();
                }
            }

            if (data && data.Constitution__c && data.CustProfile__c && data.Type_of_Borrower__c) {
                this.applWrapData = {
                    Constitution__c: data.Constitution__c,
                    CustProfile__c: data.CustProfile__c,
                    Type_of_Borrower__c: data.Type_of_Borrower__c
                }
                if (this.applWrapData) {
                    this.handleAddressOptions(this.applWrapData);
                }

            }

        }
    }


    //LAK-6480: To find any existing address present or not For selected address type
    handleAddressTypeChange(accessKey, selectedValue) {
        let currentIndex = accessKey;
        if (currentIndex) {
            for (let i = 0; i < this.addApplicantGSTRows.length; i++) {
                if (i == currentIndex) {
                    let addressTypeRecord;
                    if (this.applAddressRecs && this.applAddressRecs.length > 0) {
                        addressTypeRecord = this.applAddressRecs.find(record => record.AddrTyp__c === this.addApplicantGSTRows[i].LastSelectedAddrType__c);
                    }

                    if (addressTypeRecord) {
                        this.addApplicantGSTRows[i].addressRecordId = addressTypeRecord.Id;
                    } else {
                        this.addApplicantGSTRows[i].addressRecordId = null;
                    }

                    var updatedObject = {};
                    if (selectedValue && selectedValue === 'GST Address') {
                        updatedObject = { ...this.addApplicantGSTRows[i], ['isAddrTypeSelected']: true, ['isGSTAddressSelected']: true, ['Applicant_Address__c']: null };
                    } else {
                        updatedObject = { ...this.addApplicantGSTRows[i], ['isAddrTypeSelected']: true, ['isGSTAddressSelected']: false };
                    }

                    const newArray = [...this.addApplicantGSTRows.slice(0, i), updatedObject, ...this.addApplicantGSTRows.slice(i + 1)];
                    this.addApplicantGSTRows = newArray;

                }

            }


        }

        //LAK-6480: To find current index stamped with the type of address to send child.
        if (currentIndex) {
            this.addrDetailObj = { index: currentIndex, typeofaddress: this.addApplicantGSTRows[currentIndex].LastSelectedAddrType__c };
            this.tempArr = [...this.tempArr, this.addrDetailObj];
            const indexValues = {};
            this.tempArr.forEach(item => {
                const index = item.index;
                indexValues[index] = item;
            });
            const updatedArray = Object.values(indexValues);
            this.addressTypeData = [...updatedArray];
        }

    }


    //LAK-6480: Handling child data to reflect same address details on another address details where address type is same. 
    handleChildData(event) {
        this.addrDataFromChild = event.detail;
        if (this.template.querySelectorAll("c-capture-g-s-t-address-details")) {
            let childData = this.template.querySelectorAll("c-capture-g-s-t-address-details");
            if (childData) {
                childData.forEach(component => {
                    let tempAddrObj = { ...component.addressDetailObj };
                    if (tempAddrObj.AddrTyp__c === this.addrDataFromChild.AddrTyp__c && tempAddrObj.GSTIndex__c != this.addrDataFromChild.GSTIndex__c) {
                        component.updateChildData(this.addrDataFromChild);
                    }

                });
            }
        }

    }

    //LAK-6480: Address picklist handler logic
    @track addressOptions = [];
    @track addressTypeOptions;
    @wire(getObjectInfo, { objectApiName: APPLICANT_ADD_OBJECT })
    appAddObjectInfo

    @wire(getPicklistValuesByRecordType, {
        objectApiName: APPLICANT_ADD_OBJECT,
        recordTypeId: '$appAddObjectInfo.data.defaultRecordTypeId',
    })
    addressPicklistHandler({ data, error }) {
        if (data) {
            this.addressOptions = [...this.generatePicklist(data.picklistFieldValues.AddrTyp__c)];
            if (this.applWrapData && this.addressOptions.length > 0) {
                this.handleAddressOptions(this.applWrapData);
            }
        }
        if (error) {
            console.error(error)
        }
    }

    housewife_indi_Options = ['Residence Address', 'Permanent Address', 'Other Address', 'GST Address'] //LAK-3201
    sal_indi_Options = ['Residence Address', 'Permanent Address', 'Other Address', 'Office Address', 'GST Address']
    self_Emp_P_NP_indi_Options = ['Residence Address', 'Principal place for business', 'Residence Cum office', 'Permanent Address', 'Other Address', 'GST Address']
    self_Emp_P_NP_nonIndi_Options = ['Principal place for business', 'Registered place for business', 'Other Address', 'GST Address']
    self_Emp_P_NP_nonIndi_R_Options = ['Principal place for business', 'Registered place for business', 'Other Address', 'GST Address']


    //LAK-6480: To form picklist options
    handleAddressOptions(resultObject) {
        this.addressTypeOptions = [];
        let tempAddressArray = [];
        for (let i = 0; i < this.addressOptions.length; i++) {
            if (resultObject && resultObject.Type_of_Borrower__c === 'Financial' && resultObject.CustProfile__c === 'SALARIED' && resultObject.Constitution__c === 'INDIVIDUAL') {
                if (this.sal_indi_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);
                }
            }
            if (resultObject && resultObject.Type_of_Borrower__c === 'Financial' && (resultObject.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || resultObject.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') && resultObject.Constitution__c === 'INDIVIDUAL') {
                if (this.self_Emp_P_NP_indi_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);
                }
            }
            if (resultObject && (resultObject.Type_of_Borrower__c === 'Financial' || resultObject.Type_of_Borrower__c === 'Non Financial') && (resultObject.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || resultObject.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') &&
                (resultObject.Constitution__c === 'PRIVATE LIMITED COMPANY' || resultObject.Constitution__c === 'TRUST' || resultObject.Constitution__c === 'PUBLIC LIMITED COMPANY' ||
                    resultObject.Constitution__c === 'PARTNERSHIP' || resultObject.Constitution__c === 'LIMITED LIABILITY PARTNERSHIP' || resultObject.Constitution__c === 'ASSOCIATION OF PERSONS')) {
                if (this.self_Emp_P_NP_nonIndi_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);
                }
            }
            if (resultObject && (resultObject.Type_of_Borrower__c === 'Financial' || resultObject.Type_of_Borrower__c === 'Non Financial') && (resultObject.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || resultObject.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') &&
                (resultObject.Constitution__c === 'HUF' || resultObject.Constitution__c === 'SOCIETY' || resultObject.Constitution__c === 'PROPERITORSHIP')) {
                if (this.self_Emp_P_NP_nonIndi_R_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);


                }
            }

            if (resultObject && resultObject.Type_of_Borrower__c === 'Non Financial' && resultObject.CustProfile__c === 'SALARIED' && resultObject.Constitution__c === 'INDIVIDUAL') {
                if (this.sal_indi_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);

                }
            }

            if ((resultObject.CustProfile__c === "HOUSEWIFE" || resultObject.CustProfile__c === "OTHERS") && resultObject.Constitution__c === 'INDIVIDUAL') {
                if (this.housewife_indi_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);

                }
            }

            if (resultObject && resultObject.Type_of_Borrower__c === 'Non Financial' && (resultObject.CustProfile__c === 'SELF EMPLOYED NON PROFESSIONAL' || resultObject.CustProfile__c === 'SELF EMPLOYED PROFESSIONAL') && resultObject.Constitution__c === 'INDIVIDUAL') {
                if (this.self_Emp_P_NP_indi_Options.indexOf(this.addressOptions[i].label) > -1) {
                    tempAddressArray.push(this.addressOptions[i]);

                }
            }
        }

        if (tempAddressArray && tempAddressArray.length > 0) {
            tempAddressArray = [...tempAddressArray].sort(this.compareByLabel);
        }
        this.addressTypeOptions = [...tempAddressArray];

    }

}

/* HOTFIX
   LAK-6480: GST Address details 
   Developer: Dhananjay Gadekar
*/