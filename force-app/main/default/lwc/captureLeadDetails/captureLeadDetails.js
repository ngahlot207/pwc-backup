import { LightningElement, wire, api, track } from 'lwc';
import getRMNameDetails from '@salesforce/apex/DataSearchClass.getRMNameDetails';
import getCityIdFromLocMstr from '@salesforce/apex/DataSearchClass.getCityIdFromLocMstr';
import getProducts from '@salesforce/apex/DataSearchClass.getProducts';
import getProductMappings from '@salesforce/apex/DataSearchClass.getProductMappings';
import getLeadEmiData from '@salesforce/apex/DataSearchClass.getLeadEmiData';
import getLeadSepEmiData from '@salesforce/apex/DataSearchClass.getLeadSepEmiData';
import getLeadSeNonpEmiData from '@salesforce/apex/DataSearchClass.getLeadSeNonpEmiData';
import retrieveLeadROI from '@salesforce/apex/RackRateController.retrieveLeadROI';
import LEADDATAMC from '@salesforce/messageChannel/LeadDataMessageChannel__c';
import {
    subscribe,
    publish,
    MessageContext,
    APPLICATION_SCOPE
} from 'lightning/messageService';
import createLeadRecord from '@salesforce/apex/LeadHandler.createLeadRecord';
import LightningAlert from 'lightning/alert'
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent
} from 'lightning/flowSupport';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    getObjectInfo,
    getPicklistValues
} from 'lightning/uiObjectInfoApi';
import {
    RefreshEvent
} from "lightning/refresh";
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';

//JS file to trim string inputs
import {
    trimFunction
} from 'c/reusableStringTrimComp';

import LEAD_OBJECT from '@salesforce/schema/Lead';

import LEAD_SOURCE from '@salesforce/schema/Lead.LeadSource';
import RM_SM_FIELD from '@salesforce/schema/Lead.RM_SM_Name__c';
import CITY_CHECK_FIELD from '@salesforce/schema/Lead.UnservicableCityCheck__c';
import CASE_NO from '@salesforce/schema/Lead.Case_No__c';
import CASE_OWNER from '@salesforce/schema/Lead.Case_Owner_Name__c';
import APPROVEREJECTSTATUS from '@salesforce/schema/Lead.Approved_Rejected__c';


import CUSTOMER_PROFILE from '@salesforce/schema/Lead.Customer_Profile__c';
import PROF_QUAL from '@salesforce/schema/Lead.ProfQual__c';
import NATURE_OF_BUSINESS from '@salesforce/schema/Lead.NatureofBusiness__c';
import PROGRAM from '@salesforce/schema/Lead.Program__c';
import CONSTITUTION from '@salesforce/schema/Lead.Constitution__c';
import MOBILE_FIELD from '@salesforce/schema/Lead.MobilePhone';


import DISPO_STATUS from '@salesforce/schema/Lead.Disposition_Status__c';
import LEAD_CLOS_REASON from '@salesforce/schema/Lead.Lead_Closure_Reason__c';

import {
    NavigationMixin
} from 'lightning/navigation';
import {
    getRecord
} from 'lightning/uiRecordApi'
import {
    createRecord
} from "lightning/uiRecordApi";
// custom Labels
import DOB_Label from '@salesforce/label/c.LeadCapture_BasicDetails_Date_of_Birth';
import LAST_NAME_Label from '@salesforce/label/c.LeadCapture_BasicDetails_LastName';
import EMAIL_ID_ERR_Label from '@salesforce/label/c.LeadCapture_BasicDetails_EmailIDError';
import CUST_PROFILE_Label from '@salesforce/label/c.LeadCapture_BasicDetails_CustomerProfile';
import COMPANY_NAME_Label from '@salesforce/label/c.LeadCapture_BasicDetails_CompanyName';
import ALL_FIELDS_Label from '@salesforce/label/c.LeadCapture_BasicDetails_RequiredFieldsValidation';
import LEAD_SUCCESS_Label from '@salesforce/label/c.LeadCapture_BasicDetails_LeadSuccessMessage';
import OFFICE_ADDRESS_CITY_Label from '@salesforce/label/c.LeadCapture_BasicDetails_OfficeAddressCity';
import CURRENT_RESIDENCE_CITY_Label from '@salesforce/label/c.LeadCapture_BasicDetails_CurrentResidenceCity';
import LEAD_CLOSURE_Label from '@salesforce/label/c.LeadCapture_BasicDetails_LeadClosureReason';
import SMALL_Ticket_LAP_Label from '@salesforce/label/c.LeadCapture_BasicDetails_TenureErrorMessage_SmallTicket_LAP';
import HL_Label from '@salesforce/label/c.LeadCapture_BasicDetails_TenureErrorMessage_HL';
import TENURE_LABEL from '@salesforce/label/c.Tenure_Limit';

// import LOAN_AMOUNT_Label from '@salesforce/label/c.LeadCapture_BasicDetails_LoanAmountMessage';
import LEAD_AMOUNT_LIMIT from '@salesforce/label/c.Lead_Amount_Limit';
import UNSERVICEABLE_CITY_Label from '@salesforce/label/c.LeadCapture_BasicDetails_UnserviceableCityMessage';
import COMMENT_VAL_Label from '@salesforce/label/c.LeadCapture_BasicDetails_CommentValidation';
import CHANNEL_NAME_Label from '@salesforce/label/c.LeadCapture_BasicDetails_ChannelNameValidation';
import LeadCapture_ChannelName_ErrorMessage from '@salesforce/label/c.LeadCapture_ChannelName_ErrorMessage';
import LeadCapture_CityName_ErrorMessage from '@salesforce/label/c.LeadCapture_CityName_ErrorMessage';
import LeadCapture_Close_SuccessMessage from '@salesforce/label/c.LeadCapture_Close_SuccessMessage';
import EligibilityCalculatorMsg from '@salesforce/label/c.eligibilityCalculatorMsg';

import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import getAssetPropType from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';

import {
    refreshApex
} from '@salesforce/apex';
import QUE_IMAGE from "@salesforce/resourceUrl/QuestionMarkImage";

//import createORupdateLeadRecord from '@salesforce/apex/LeadHandler.createORupdateLeadRecord';

import getData from '@salesforce/apex/DataSearchClass.getData'
import getCity from '@salesforce/apex/DataSearchClass.getCityFromLocationMaster'
import getChannel from '@salesforce/apex/DataSearchClass.getChannelFromDSABranch';

export default class CaptureLeadDetails extends NavigationMixin(LightningElement) {

    image = QUE_IMAGE
    @api isEMIButtonClicked;
    showEMICalculator;
    disableEMIButton = true
    //to handle all custom labels
    label = {
        DOB_Label,
        LAST_NAME_Label,
        COMPANY_NAME_Label,
        ALL_FIELDS_Label,
        LEAD_SUCCESS_Label,
        OFFICE_ADDRESS_CITY_Label,
        CURRENT_RESIDENCE_CITY_Label,
        LEAD_CLOSURE_Label,
        SMALL_Ticket_LAP_Label,
        HL_Label,
        TENURE_LABEL,
        //LOAN_AMOUNT_Label,
        UNSERVICEABLE_CITY_Label,
        COMMENT_VAL_Label,
        CUST_PROFILE_Label,
        CHANNEL_NAME_Label,
        LeadCapture_ChannelName_ErrorMessage,
        LeadCapture_CityName_ErrorMessage,
        LeadCapture_Close_SuccessMessage,
        EMAIL_ID_ERR_Label,
        EligibilityCalculatorMsg,
        LEAD_AMOUNT_LIMIT//LAK-8345
    };

    tempRM_Val
    rmNameValue
    currentCityData
    currentCity
    currCityId
    officeCityData
    officeCity
    officeCityId
    officeCity
    timer
    loanAmountErrorMessage
    loanAmountLimitMessage
    TenureAmountLimitMessage
    tenureErrorMessage
    currentUserName


    loanAmountFlag = false
    tenureErrorFlag = false
    digitalValue = false
    directValue = false
    fedFinaEmpValue = false
    dsaValue = false
    searchResult1 = false
    errorMessage1 = false
    searchResult2 = false
    errorMessage2 = false
    searchResult = false
    errorMessage = false
    requiredFlag = true
    isIndividual = false
    isNonIndividual = false
    isShowModal = false
    leadClosureVisibilty = false
    proIdentifiedFlag = false
    cityCheck = false
    channelFlag = false
    modalFieldFlag = false
    errorMessage3 = false
    searchResult3 = false
    errorMessage4 = false
    searchResult4 = false
    otherSelected = false

    promotionData = []
    leadValueOptions = []
    customerProfileOptions = []
    constitutionOptions = []
    profQuaOptions = [];
    programOptions = [];
    natureOfBusinessOptions = [];
    picklistOptions = []
    depStatusOptions = []
    leadClosureOptions = []
    resultData = []
    productOptions = []
    productSubTypeOptions = []

    @api cityService
    @api searchInput = ''
    @api constiFlag = false
    @api disabledFlag = false
    @api recordId = ''
    @api leadRecordId
    @api lastName
    @api mobile
    @api leadValue
    @api productValue
    @api productSubTypeValue
    @api loanAmount
    @api assessedIncomeProgramValue = false
    @api assessedIncomeProgramValue1 = 'No';
    @api propertyIdentifiedValue
    @api tenure
    @api propertyCategoryValue
    @api depStatusValue
    @api depositionRemark
    @api leadClosureValue
    @api customerProfileValue
    @api constitutionValue
    @api rmNameId 
    @api DSAUserId
    @api channelName
    @api firstName
    @api testCityv1
    @api currentCitySearch
    @api officeCitySearch
    @api lmsLeadId
    @api referralCode
    @api emailId
    @api doiValue
    @api doiValue1
    @api companyChange
    @api dob
    @api dob1
    @api keyManName
    @api promotionCode
    @api otherReason
    @api empRole;
    // @api currentUserId
    @api leadStatus = ''

    @api pvCityVerified
    @api pvChannelVerified
    @api CityValue_Bkp
    @api isChannelverified
    @api isCityVerified

    @api leadROI;
    @track wiredRefData;
    @api EMIperLac;
    @api eligibilityinlacs;
    @api emi;
    @api declredMontlyIncVal;
    @api declredMontlyOblVal;
    @track isCalculatorOpen = false;
    @track filterConditionPromotion;


    @track showSpinner = false;
    @track activeSection = ["A", "B", "C", "D", "E"];
    @track currentCityonclick;
    @track ofcCityOnClick;
    @track searchInputOnClick;
    @track isChannelSuccess;
    @track isCitySuccess;
    @track productAmountLimits = [];
    customerProfileVisibleOptions = ["SALARIED", "SELF EMPLOYED NON PROFESSIONAL", "SELF EMPLOYED PROFESSIONAL"];
    @track EMIperLacVal;
    @track eligibilityinlacsVal;
    @api leadFOIR;
    MontlyIncdeclval = null;
    MontlyObldeclval = null;

    @track _currentUserId;
    @api get currentUserId() {
        return this._currentUserId;
    }
    set currentUserId(value) {
        this._currentUserId = value;
        this.setAttribute("currentUserId", value);
        this.handleteamHierIdChange();
    }

    handleteamHierIdChange() {
        let tempParams = this.teamHierParam;
        tempParams.queryCriteria = ' where Employee__c = \'' + this._currentUserId + '\' AND IsActive__c = true limit 1';
        this.teamHierParam = { ...tempParams };

    }
    caseNo;
    caseOwner;
    @wire(getRecord, {
        recordId: '$leadRecordId',
        fields: [MOBILE_FIELD, RM_SM_FIELD, CITY_CHECK_FIELD, CASE_NO, CASE_OWNER, APPROVEREJECTSTATUS]
    })
    handleMobile(result) {
        this.wiredRefData = result;
        if (result.data) {
            console.log('handleMobileData ' + JSON.stringify(result.data))
            this.mobile = result.data.fields.MobilePhone.value
            this.tempRM_Val = result.data.fields.RM_SM_Name__c.value
            this.cityService = result.data.fields.UnservicableCityCheck__c.value
            this.caseNo = result.data.fields.Case_No__c.value
            this.caseOwner = result.data.fields.Case_Owner_Name__c.value
            this.approverejectStuts = result.data.fields.Approved_Rejected__c.value
            if (this.cityService) {
                this.cityCheck = false
            } else {
                this.cityCheck = true
            }
        }
        if (result.error) {
            console.log(result.error)
        }
    }

    handleRMDetails() {
        if (this.rmNameId) {
            getRMNameDetails({
                rmNameId: this.rmNameId
            })
                .then(result => {
                    console.log('RM Data -' + JSON.stringify(result))
                    //this.rmNameValue = result.Name 
                    console.log('this.empRole ', this.empRole)
                    if (result.Name) {
                        this.rmNameValue = this.convertToUppercase(result.Name);
                    } else {
                        this.rmNameId = null;
                        this.rmNameValue = '';
                    }

                    //this.rmNameId = result.Id
                })
                .catch(error => {
                    console.log(error)
                })
        }

    }



    //reusable piclist generator method
    generatePicklist(data) {
        return data.values.map(item => ({
            label: item.label,
            value: item.value
        }))
    }

    @wire(MessageContext)
    context

    @wire(getObjectInfo, {
        objectApiName: LEAD_OBJECT
    })
    objInfo

    @wire(getPicklistValues, {
        recordTypeId: '$objInfo.data.defaultRecordTypeId',
        fieldApiName: LEAD_SOURCE
    })
    leadSourcePicklistHandler({
        data,
        error
    }) {
        //LAK-9291
        if (data && this.leadRecordId) {
            this.leadValueOptions = [...this.generatePicklist(data)]
        }
        //LAK-9291
        else{
            this.leadValueOptions =  [
                { label: 'Connector', value: 'Connector' },
                { label: 'DSA', value: 'DSA' },
                { label: 'Fedfina Emp', value: 'Fedfina Emp' },
                { label: 'Direct', value: 'Direct' },
            ];
        }
        if (error) {
            console.log(error)
        }
    }

    @track teamHierParam = {
        ParentObjectName: 'TeamHierarchy__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'EmpRole__c', 'Product_Type__c', 'Employee__c', 'IsActive__c'],
        childObjFields: [],
        queryCriteria: ''
    }

    @wire(getSobjectData, { params: '$teamHierParam' })
    teamHierHandler({ data, error }) {
        if (data) {
            console.log('DATA IN Lead DETAILS :::: #343>>>>', data);
            if (data.parentRecords !== undefined) {
                let pdt = data.parentRecords[0].Product_Type__c;
                console.log('DATA IN Lead DETAILS :::: #343>>>> pdt', pdt);
                if (pdt) {
                    let pdtlist = pdt.split(';');
                    this.productOptions = [];
                    pdtlist.forEach(ele => {
                        let val = {
                            'label': ele,
                            'value': ele
                        };
                        this.productOptions.push(val);

                    });


                }
                console.log('DATA IN Lead DETAILS :::: #343>>>>  this.productOptions', this.productOptions);
                //  this.productOptions = [...this.generatePicklist(data.picklistFieldValues.Product_Type__c)]
                console.log('DATA IN LEAD DETAILS :::: #346>>>>', this.productOptions);
            }

        }
        if (error) {
            console.error('ERROR CASE DETAILS:::::::#420', error)
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objInfo.data.defaultRecordTypeId',
        fieldApiName: CUSTOMER_PROFILE
    })
    customerProfilePicklistHandler({
        data,
        error
    }) {
        if (data) {
            let customerProfileAllOptions = [...this.generatePicklist(data)];
            let tempArrayCustProfile = [];
            for (let i = 0; i < customerProfileAllOptions.length; i++) {

                if (this.customerProfileVisibleOptions.indexOf(customerProfileAllOptions[i].label) > -1) {
                    tempArrayCustProfile.push(customerProfileAllOptions[i]);
                }

            }
            this.customerProfileOptions = [...tempArrayCustProfile]
        }
        if (error) {
            console.log(error)
        }
    }


    @wire(getPicklistValues, {
        recordTypeId: '$objInfo.data.defaultRecordTypeId',
        fieldApiName: CONSTITUTION
    })
    constitutionPicklistHandler({
        data,
        error
    }) {
        if (data) {
            this.constitutionOptions = [...this.generatePicklist(data)]
        }
        if (error) {
            console.log(error)
        }
    }
    @wire(getPicklistValues, {
        recordTypeId: '$objInfo.data.defaultRecordTypeId',
        fieldApiName: PROGRAM
    })
    programPicklistHandler({
        data,
        error
    }) {
        if (data) {
            this.programOptions = [...this.generatePicklist(data)]
            console.log('programOptions' , this.programOptions);
            
        }
        if (error) {
            console.log(error)
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objInfo.data.defaultRecordTypeId',
        fieldApiName: NATURE_OF_BUSINESS
    })
    natureOfBusinessPicklistHandler({
        data,
        error
    }) {
        if (data) {
            this.natureOfBusinessOptions = [...this.generatePicklist(data)]
            console.log('natureOfBusinessOptions' , this.natureOfBusinessOptions);
            
        }
        if (error) {
            console.log(error)
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objInfo.data.defaultRecordTypeId',
        fieldApiName: PROF_QUAL
    })
    profQualPicklistHandler({
        data,
        error
    }) {
        if (data) {
            this.profQuaOptions = [...this.generatePicklist(data)]
            console.log('profQuaOptions' , this.profQuaOptions);
            
        }
        if (error) {
            console.log(error)
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objInfo.data.defaultRecordTypeId',
        fieldApiName: DISPO_STATUS
    })
    dispositionStatusPicklistHandler({
        data,
        error
    }) {
        if (data) {
            let depStatusAllOptions = [...this.generatePicklist(data)]
            let tempArray = [];
            for (let i = 0; i < depStatusAllOptions.length; i++) {

                if (depStatusAllOptions[i].label != 'Lead converted' || this.disabledFlag) {
                    tempArray.push(depStatusAllOptions[i]);
                }

            }
            this.depStatusOptions = [...tempArray]
        }
        if (error) {
            console.log(error)
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objInfo.data.defaultRecordTypeId',
        fieldApiName: LEAD_CLOS_REASON
    })
    leadClosurePicklistHandler({
        data,
        error
    }) {
        if (data) {
            this.leadClosureOptions = [...this.generatePicklist(data)]
        }
        if (error) {
            console.log(error)
        }
    }

    @wire(getProductMappings, {
        product: '$productValue'
    })
    productSubTypesHandler({
        data,
        error
    }) {
        if (data) {
            this.productSubTypeOptions = data.map(item => ({
                label: item,
                value: item
            }))
            this.productSubTypeOptions.sort(this.compareByLabel);
        }
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

    // @wire(getProducts, {
    //     rmName: '$currentUserId'
    // })
    // productHandler({
    //     data,
    //     error
    // }) {
    //     if (data) {
    //         console.log('data for get products ', data);

    //         this.productOptions = data.map(item => ({
    //             label: item,
    //             value: item
    //         }))
    //     }
    //     if (error) {
    //         console.error('getting erorr in product options == >', error)
    //     }
    // }

    get rmNameValueFilter() {
        return this.rmNameValue;
    }

    get leadValueFilter() {
        return this.leadValue;

    }

    get visibleOption() {
        return true;
    }

    get proCategoryFlag() {
        if ((this.productValue == 'Small Ticket LAP' || this.productValue == 'Loan Against Property') && (this.productSubTypeValue !== 'Commercial Property Purchase' || (this.productSubTypeValue === 'Commercial Property Purchase' && this.propertyIdentifiedValue == 'Yes'))) {
            return true
        } else if (this.productValue == 'Home Loan' && this.propertyIdentifiedValue == 'Yes') {
            return true
        } else {
            return false
        }
    }

    get globalTrueFalseOptions() {
        return [{
            label: 'Yes',
            value: 'Yes'
        },
        {
            label: 'No',
            value: 'No'
        },
        ];
    }

    get propertyCategoryOptions() {
        return [{
            label: 'CAT A',
            value: 'CAT A'
        },
        {
            label: 'CAT B',
            value: 'CAT B'
        },
        {
            label: 'CAT C',
            value: 'CAT C'
        },
        ];
    }


    leadClosureCheck() {
        if (this.depStatusValue === 'Lead closed') {
            this.leadClosureVisibilty = true
        } else {
            this.leadClosureVisibilty = false
        }
    }

    convertToUppercase(inputVal) {
        if (inputVal) {
            return inputVal.toUpperCase();
        }
    }

    emailHandler(event) {
        this.emailId = event.target.value;
        if (this.emailId) {
            this.emailId = this.convertToUppercase(event.target.value);
            if (this.emailId && this.emailId.length > 0) {
                this.validateEmail();
            }
        } else if (this.emailId.length === 0) {
            let email = this.template.querySelector('[data-id="txtEmailAddress"]');
            email.setCustomValidity("");
            email.reportValidity();
        }
        this.dispatchEvent(new FlowAttributeChangeEvent('emailId', this.emailId))
    }

    validateEmail() {
        let flag = true;
        let email;
        if (this.emailId && this.emailId.length > 0) {
            const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
            email = this.template.querySelector('[data-id="txtEmailAddress"]');
            let emailVal = this.emailId;
            if (emailVal.match(emailRegex)) {
                email.setCustomValidity("");
                flag = true;
            } else {
                flag = false;
                email.setCustomValidity("Please enter valid email");
                if (this.emailId.length === 0) {
                    flag = true;
                    email.setCustomValidity("");
                }
            }
            email.reportValidity();
        }
        return flag;
    }

    firstNameHandler(event) {
        this.firstName = this.convertToUppercase(event.target.value);
        this.dispatchEvent(new FlowAttributeChangeEvent('firstName', this.firstName))
    }

    handleBlur(event) {
        if (event.target.label === "LMS Lead ID" && this.lmsLeadId) {
            this.lmsLeadId = trimFunction(this.lmsLeadId)
        }
        if (event.target.label === "First Name" && this.firstName) {
            this.firstName = trimFunction(this.firstName)
        }
        if (event.target.label === "Referral Employee Code" && this.referralCode) {
            this.referralCode = trimFunction(this.referralCode)
        }
        if (event.target.label === "Last Name" && this.lastName) {
            this.lastName = trimFunction(this.lastName)
        }
        if (event.target.label === "Email ID" && this.emailId != null) {
            this.emailId = trimFunction(this.emailId)
        }
        if (event.target.label === "Company Name" && this.companyChange) {
            this.companyChange = trimFunction(this.companyChange)
        }
        if (event.target.label === "Name of the Keyman/Authorised Individual" && this.keyManName) {
            this.keyManName = trimFunction(this.keyManName)
        }
        if (event.target.label === "Additional Comments" && this.otherReason) {
            this.otherReason = trimFunction(this.otherReason)
        }
    }


    lastNameHandler(event) {
        this.lastName = this.convertToUppercase(event.target.value);
        this.dispatchEvent(new FlowAttributeChangeEvent('lastName', this.lastName))
    }

    mobileHandler(event) {
        this.mobile = this.convertToUppercase(event.target.value);
    }

    handleProductChange(event) {
        this.productValue = event.detail.value;
        this.propertyIden_method()
        this.serviceableSearch();

        //Added for LAK-321
        this.retriveLeadROIMethod();
        this.checkMadtryFieldsforEMI();
        this.filterConditionPromotion = ' ProductType__c  = \'' + this.productValue + '\' AND EndDate__c >=TODAY AND StartDate__c <= TODAY';

        if (this.productValue == 'Business Loan' || this.productValue == 'Personal Loan') {
            this.selectedDsaRm = '';
            this.teamHierId = '';
            this.selectedDsaRmId = '';
            if(this.empRole && this.empRole == 'DSA' && this.leadValue && this.leadValue === 'DSA'){
                this.DSAUserId = this.DSAUserId ? this.DSAUserId : this.rmNameId;
                this.rmNameId = ''; 
            }  
            this.assessedIncomeProgramValue1 = '';
            this.propertyIdentifiedValue = '';
            this.disableFieldsOnProd = true;
            // this.assessedIncomeProgramValue = n;
        } else {
            this.disableFieldsOnProd = false;
        }
    }

    clearLoanDetails() {
        this.promotionCode = ''
        this.loanAmount = null;
        this.tenure = null
        this.assessedIncomeProgramValue1 = false
        this.propertyCategoryValue = ''
        this.depositionRemark = ''
        this.leadClosureValue = ''
    }

    //used to capture product-sub-type value
    handleProductSubTypeChange(event) {
        this.productSubTypeValue = event.detail.value;
        this.propertyIdenSub_method();

        //Added for LAK-321
        this.retriveLeadROIMethod();
    }

    propertyIden_method() {
        if (this.productValue == 'Small Ticket LAP' || this.productValue == 'Loan Against Property') {
            this.productSubTypeValue = '';
            // this.productSubTypeValue = 'LAP Commercial' //Commented by Bhima to fix UAT Bugs 
            this.clearLoanDetails()
            this.propertyIdentifiedValue = 'Yes'
            this.proIdentifiedFlag = true
        } else {
            this.productSubTypeValue = 'Home Loan'
            this.propertyIdentifiedValue = 'Yes' //Changed by Bhima to fix UAT Bugs 
            //  this.propertyIdentifiedValue = 'No' 
            this.proIdentifiedFlag = false
            this.clearLoanDetails()
        }
    }

    //Commented by Prasanna to fix LAK-1930 & 2409
    propertyIdenSub_method() {
        if ((this.productValue == 'Small Ticket LAP' || this.productValue == 'Loan Against Property') && this.productSubTypeValue === 'Commercial Property Purchase') {
            this.proIdentifiedFlag = false
        } else if ((this.productValue == 'Small Ticket LAP' || this.productValue == 'Loan Against Property') && this.productSubTypeValue != 'Commercial Property Purchase') {
            this.propertyIdentifiedValue = 'Yes'
            this.proIdentifiedFlag = true
        }
    }


    //used to capture loan amount/////////////////////
   loanAmountHandler(event) {
        this.loanAmount = event.target.value;

        this.loanAmountValid()
        var charCode = (event.which) ? event.which : event.keyCode;
        if ((charCode == 46)) {
           if (event.preventDefault) {
               event.preventDefault();
            }
        }
        //Added for LAK-321
       this.retriveLeadROIMethod();
    }
   
    //validate loan amount 
    loanAmountValid() {
        this.getProductLimits();//LAK-8345
        let validate = true
        if (this.loanAmount < this.minLimit || this.loanAmount > this.maxLimit) {
            this.loanAmountErrorMessage = this.loanAmountLimitMessage;
            this.loanAmountFlag = true
            validate = false
        } else {
            this.loanAmountErrorMessage = ''
            this.loanAmountFlag = false
            validate = true
        }
        if (!this.loanAmount) {
            this.loanAmountErrorMessage = ''
            this.loanAmountFlag = false
        }
        return validate
    }
    tenureValid() {
        this.getProductTenure();
        let validate = true
            if (this.tenure <  this.minTenure || this.tenure > this.maxTenure) {
                this.tenureErrorMessage = this.TenureAmountLimitMessage;
                validate = false
                this.tenureErrorFlag = true
            } else {
                this.tenureErrorMessage = ''
                this.tenureErrorFlag = false
                validate = true
            }
            if (!this.tenure) {
                this.tenureErrorMessage = ''
                this.tenureErrorFlag = false
            }
        return validate
    }



    handleAssesIncomeChange(event) {
        if (event.detail.value == 'Yes') {
            this.assessedIncomeProgramValue = true;
        } else {
            this.assessedIncomeProgramValue = false;
        }
        this.assessedIncomeProgramValue1 = event.detail.value;
        //Added for LAK-321
        this.retriveLeadROIMethod();
        this.getFOIR();
    }

    handlePropertyIdentifiedChange(event) {
        this.propertyIdentifiedValue = event.detail.value;
        //Added for LAK-321
        this.retriveLeadROIMethod();
    }

    //used to capture tenure
    tenureHandler(event) {
        this.tenure = event.target.value;
        this.checkMadtryFieldsforEMI();
        this.tenureValid();
        this.getFOIR();
    }

    //validate tenure code///////////////////////////////

    handlePropertyCategoryChange(event) {
        this.propertyCategoryValue = event.detail.value;
        //Added for LAK-321
        this.retriveLeadROIMethod();
    }

    handleDepStatusChange(event) {
        this.depStatusValue = event.detail.value
        console.log('Selected depStatusValue:', this.depStatusValue);
        this.leadClosureCheck()
        if (this.depStatusValue != 'Lead closed') {
            this.leadClosureValue = ''
            this.otherSelected = false
        }
        this.dispatchEvent(new FlowAttributeChangeEvent('depStatusValue', this.depStatusValue))
        console.log('FlowAttributeChangeEvent dispatched for depStatusValue:', this.depStatusValue);
    }

    remarkHandler(event) {
        this.depositionRemark = this.convertToUppercase(event.target.value);
    }

    handleLeadClosureChange(event) {
        console.log('Lead Closure Changed: ', event.detail.value);
        this.leadClosureValue = event.detail.value
        if (this.leadClosureValue == 'Others') {
            this.otherReason = ''

        }
        this.otherFlagVisibility()
    }

    otherFlagVisibility() {
        if (this.leadClosureValue == 'Others') {
            this.otherSelected = true
        } else {
            this.otherSelected = false
        }
    }

    handleCustomerProfileChange(event) {
        this.customerProfileValue = event.detail.value;
        if (this.customerProfileValue == 'SALARIED') {
            this.constitutionValue = 'INDIVIDUAL';
            this.handleConsti();
            this.constiFlag = true;

        } else {
            this.constiFlag = false;
        }
        this.dispatchEvent(new FlowAttributeChangeEvent('customerProfileValue', this.customerProfileValue))

        //Added for LAK-321
        this.retriveLeadROIMethod();
        this.checkMadtryFieldsforEMI();
        this.getFOIR();
    }


    handleConstitutionChange(event) {
        this.constitutionValue = event.detail.value
        this.dispatchEvent(new FlowAttributeChangeEvent('constitutionValue', this.constitutionValue))
        this.handleConsti();
        this.currentCitySearch = '';
        this.officeCitySearch = '';

    }
    handleConsti() {
        if (this.constitutionValue === 'INDIVIDUAL') {
            this.isIndividual = true
            this.isNonIndividual = false
            if (this.customerProfileValue == 'SALARIED') {
                this.constiFlag = true
            }
        } else if (this.constitutionValue !== 'INDIVIDUAL') {
            this.isIndividual = false
            this.isNonIndividual = true
            this.lastName = ''
            this.firstName = ''
            this.constiFlag = false
        }
    }


    validDispoStatus() {
        let isValid = true
        let inputField = this.template.querySelector('.depStatusValue')

        if (!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false
        }
        this.depStatusValue = inputField.value

        return isValid
    }

    validTenure() {
        let isValid = true
        let inputField = this.template.querySelector('.tenure')

        if (!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false
        }
        this.tenure = inputField.value

        return isValid
    }

    validDeclMonly() {
        let isValid = true;

        // Get references to the input fields
        let incomeInput = this.template.querySelector('.declMonthInc');
        let obligationInput = this.template.querySelector('.declMonthObl');

        // Check validity of both input fields
        if (!incomeInput.checkValidity()) {
            incomeInput.reportValidity();
            isValid = false;
        }
        if (!obligationInput.checkValidity()) {
            obligationInput.reportValidity();
            isValid = false;
        }

        // If both fields are valid, update the values
        if (isValid) {
            this.declaredMonthlyIncVal = incomeInput.value;
            this.declaredMonthlyOblVal = obligationInput.value;
        }

        return isValid;
    }
    validEmiFields() {
        let isValid = true;
        // Get references to the input fields
        let salExVarPayInput = this.template.querySelector('.salExclVarPay');
        let avgVarPayInput = this.template.querySelector('.avgVarPay');
        let dedIncomTaxInput = this.template.querySelector('.dedInclIncomeTax');
        let avgAddIncomeInput = this.template.querySelector('.avgAddIncome');
        let consultIncomeInput = this.template.querySelector('.consultIncome');
        let monthlyOblInput = this.template.querySelector('.monthlyObl');

        // Check validity of both input fields
        if (!salExVarPayInput.checkValidity()) {
            salExVarPayInput.reportValidity();
            isValid = false;
        }
        if (!avgVarPayInput.checkValidity()) {
            avgVarPayInput.reportValidity();
            isValid = false;
        }
        if (!dedIncomTaxInput.checkValidity()) {
            dedIncomTaxInput.reportValidity();
            isValid = false;
        }
        if (!avgAddIncomeInput.checkValidity()) {
            avgAddIncomeInput.reportValidity();
            isValid = false;
        }
        if (!consultIncomeInput.checkValidity()) {
            consultIncomeInput.reportValidity();
            isValid = false;
        }
        if (!monthlyOblInput.checkValidity()) {
            monthlyOblInput.reportValidity();
            isValid = false;
        }
        // If both fields are valid, update the values
        if (isValid) {
            this.salExclVarPay = salExVarPayInput.value;
            this.avgVarPay = avgVarPayInput.value;
            this.dedInclIncomeTax = dedIncomTaxInput.value;
            this.avgAddIncome = avgAddIncomeInput.value;
            this.consultIncome = consultIncomeInput.value;
            this.monthlyObl = monthlyOblInput.value;
        }

        return isValid;
    }
    validLoan() {
        let isValid = true
        let inputField = this.template.querySelector('.loanAmount')

        if (!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false
        }
        this.loanAmount = inputField.value

        return isValid
    }


    validProduct() {
        let isValid = true
        let inputField = this.template.querySelector('.productValue')

        if (!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false
        }
        this.productValue = inputField.value

        return isValid
    }

    validDOB() {
        let isValid = true
        let inputField = this.template.querySelector('.dob1')

        if (!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false
        }
        this.dob1 = inputField.value

        return isValid
    }

    validCurrCity() {
        let isValid = true
        let inputField = this.template.querySelector('.currentCitySearch')

        if (!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false
        }
        this.currentCitySearch = inputField.value

        return isValid
    }

    validFirstName() {
        let isValid = true
        let inputField = this.template.querySelector('.firstName')

        if (!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false
        }
        this.firstName = inputField.value

        return isValid
    }

    validKeyMan() {
        let isValid = true
        let inputField = this.template.querySelector('.keyManName')

        if (!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false
        }
        this.keyManName = inputField.value

        return isValid
    }

    validOfficeCity() {
        let isValid = true
        let inputField = this.template.querySelector('.officeCitySearch')

        if (!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false
        }
        this.officeCitySearch = inputField.value

        return isValid
    }

    validCompany() {
        let isValid = true
        let inputField = this.template.querySelector('.companyChange')

        if (!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false
        }
        this.companyChange = inputField.value

        return isValid
    }

    validDOI() {
        let isValid = true
        let inputField = this.template.querySelector('.doiValue1')

        if (!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false
        }
        this.doiValue1 = inputField.value

        return isValid
    }



    validLastName() {
        let isValid = true
        let inputField = this.template.querySelector('.lastName')

        if (!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false
        }
        this.lastName = inputField.value

        return isValid
    }

    validConstitution() {
        let isValid = true
        let inputField = this.template.querySelector('.constitutionValue')

        if (!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false
        }
        this.constitutionValue = inputField.value

        return isValid
    }

    validCustomerProfile() {
        let isValid = true
        let inputField = this.template.querySelector('.customerProfileValue')

        if (!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false
        }
        this.customerProfileValue = inputField.value

        return isValid
    }

    validLeadSource() {
        let isValid = true
        let inputField = this.template.querySelector('.leadSource')

        if (!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false
        }
        this.leadValue = inputField.value

        return isValid
    }

    checkEmailValid() {
        let isValid = true
        let inputField = this.template.querySelector('.validate2')

        if (!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false
        }
        this.emailId = inputField.value

        return isValid
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

    dobHandler(event) {
        this.dob1 = event.target.value
        this.dispatchEvent(new FlowAttributeChangeEvent('dob1', this.dob1))
        // if(this.validateDOB(this.dob1)==false){
        //     this.showToastMessage('Error',this.label.DOB_Label,'error','sticky')
        // }
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
        minDate.setFullYear(minDate.getFullYear() - 21);

        // Compare the parsed date with the minimum date and the current date
        if (date > currentDate || date > minDate) {
            return false; // Date of birth is in the future or less than 18 years old
        }

        // All validations passed, so the date of birth is valid
        return true;
    }

    // validateFutureDate(dob){
    //     return new Date(dob).getTime() < Date.now()  
    // }

    // validateAge(dob){
    //     return this.getAge(dob) > 21 
    // }

    // getAge(birthday) {
    //     var millis = Date.now() - new Date(birthday).getTime()
    //     var age = new Date(millis) 
    //     return Math.abs(age.getUTCFullYear()-1970)
    // }


    handleLeadSourceVisibility() {
        if (this.leadValue === 'Direct') {
            this.directValue = true;
        } else if (this.leadValue === 'Digital') {
            this.digitalValue = true;
        } else if (this.leadValue === 'DSA' || this.leadValue === 'Connector') {
            this.dsaValue = true
        } else if (this.leadValue === 'Fedfina Emp') {
            this.fedFinaEmpValue = true;
        }

    }

    handleLeadSourceChange(event) {
        this.leadValue = event.detail.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('leadValue', this.leadValue))
        if (event.detail.value === 'Direct') {
            this.directValue = true;
            this.dsaValue = false;
            this.digitalValue = false;
            this.fedFinaEmpValue = false;
            this.channelFlag = false;
        } else if (event.detail.value === 'DSA' || event.detail.value === 'Connector') {
            this.searchInput = ''
            this.directValue = false;
            this.dsaValue = true;
            this.digitalValue = false;
            this.fedFinaEmpValue = false;
            this.channelFlag = true;
        } else if (event.detail.value === 'Digital') {
            this.directValue = false;
            this.dsaValue = false;
            this.digitalValue = true;
            this.fedFinaEmpValue = false;
            this.channelFlag = false
        } else if (event.detail.value === 'Fedfina Emp') {
            this.directValue = false;
            this.dsaValue = false;
            this.digitalValue = false;
            this.fedFinaEmpValue = true;
            this.channelFlag = false
        } else {
            this.directValue = false;
            this.dsaValue = false;
            this.digitalValue = false;
            this.fedFinaEmpValue = false;
            this.channelFlag = false
        }

    }

    constructor() {
        super()
    }

    //LAK-8345
    @track productType;
    @track minLimit;
    @track maxLimit;
    @track minTenure;
    @track maxTenure;


    getProductLimits() {
        console.log('check lead amount 1197', this.label.LEAD_AMOUNT_LIMIT);
        let arr = JSON.parse(this.label.LEAD_AMOUNT_LIMIT);
        console.log('arr 1199', arr);
        try {
            if (arr && arr.productLimit) {
                arr.productLimit.forEach(product => {
                    if (product.productType == this.productValue) {
                        ;
                        this.minLimit = Number(product.minLimit);
                        this.maxLimit = Number(product.maxLimit);
                        this.loanAmountLimitMessage = product.limitMessage;
                    }
                    //console.log('min and max',this.minLimit, this.maxLimit);
                });
            }

        }
        catch (error) {
            console.error('Error fetching product limits', error);
        }
    }
    getProductTenure() {
        console.log('check tenure 1198', this.label.TENURE_LABEL);
        let tenureArr = JSON.parse(this.label.TENURE_LABEL);
        console.log('tenureArr 1200', tenureArr);
        try {
            if (tenureArr && tenureArr.productLimit) {
                tenureArr.productLimit.forEach(product => {
                    if (product.productType == this.productValue){
                        ;
                        this.minTenure = Number(product.minTenure);
                        this.maxTenure = Number(product.maxTenure);
                        this.TenureAmountLimitMessage = product.tenureMessage;
                        console.log('Tenure Limits - Min:', this.minTenure, 'Max:', this.maxTenure);
                    }
                    //console.log('min and max',this.minLimit, this.maxLimit);
                });
            }
 
        }
        catch (error) {
            console.error('Error fetching tenure limits', error);
        }
    }

    // get disableLMSId(){
    //     return (this.lmsLeadId && this.leadRecordId && this.leadValue === 'Digital')
    // }


    @track disableFieldsOnProd = true;
    //LAK-9291
    @track disableLMSId = false;
    async connectedCallback() {
        //LAK-9291
        if(this.lmsLeadId && this.leadRecordId && this.leadValue === 'Digital'){
            this.disableLMSId = true;
        }

        //this.disableFieldsOnProd = true;
        console.log('selectDSACityId ==> ', this.selectDSACityId);
        console.log('selectDSABranchId ==> ', this.selectDSABranchId);
        if (this.rmNameId) {
            this.selectedDsaRmId = this.rmNameId;
           // this.DSAUserId = this.rmNameId;
        }
        console.log('selectedDsaRmId ==> ', this.selectedDsaRmId);
        if (this.selectDSABranchId) {
            this.getteamHierarchyId();
        }
        let retVal = await this.getisLoggedinUserDSA();
        refreshApex(this.wiredRefData);
        this.dispatchEvent(new RefreshEvent());
        this.handleRMDetails()
        this.subscribeHandler();
        this.activeSection = ["A", "B", "C", "D", "E"];

        this.otherFlagVisibility()
        this.leadClosureCheck()

        if (this.assessedIncomeProgramValue) {
            this.assessedIncomeProgramValue1 = 'Yes';
        } else {
            this.assessedIncomeProgramValue1 = 'No';
        }
        if (this.productValue && (this.productValue === 'Personal Loan' || this.productValue === 'Business Loan')) {
            this.assessedIncomeProgramValue1 = '';
            this.propertyIdentifiedValue = '';
            this.disableFieldsOnProd = true;
        } else if (this.productValue) {
            this.disableFieldsOnProd = false;
        }
        this.handleConsti()
        this.handleLeadSourceVisibility()
        this.proValueCheck()
        if (!this.constitutionValue && !this.customerProfileValue) {
            this.isIndividual = false
            this.isNonIndividual = false
        }

        if (this.leadStatus == 'Closed' || this.leadStatus == 'Rejected' || this.leadStatus == 'Converted' || this.leadStatus == 'Referred to BBH') {
            this.disabledFlag = true
            this.constiFlag = true
            this.proIdentifiedFlag = true
            this.disableLMSId = true;
            
        }
        if (!this.productValue) {

            this.propertyIdentifiedValue = ''

        } else {
            if (this.productValue == 'Small Ticket LAP' || this.productValue == 'Loan Against Property') {
                this.proIdentifiedFlag = true
            } else if (this.leadStatus == 'Closed' || this.leadStatus == 'Rejected' || this.leadStatus == 'Converted' || this.leadStatus == 'Referred to BBH') {
                this.proIdentifiedFlag = true
            }
            else {
                this.proIdentifiedFlag = false
            }
        }
        this.currentCityonclick = this.currentCitySearch;
        this.ofcCityOnClick = this.officeCitySearch;

        this.searchInputOnClick = this.searchInput;
        if (this.leadValue === 'DSA' || this.leadValue === 'Connector') {
            this.channelFlag = true;
        } else {
            this.channelFlag = false;
        }
        if (this.leadValue === 'DSA' || this.leadValue === 'Connector') {
            if (this.leadRecordId != '' && this.leadRecordId != undefined &&
                ((this.currentCitySearch != '' && this.currentCitySearch != undefined) ||
                    (this.officeCitySearch != '' && this.officeCitySearch != undefined)) &&
                this.searchInput != '' && this.searchInput != undefined) {
                this.isCitySuccess = true;
                this.isChannelSuccess = true;
            }
        } else if (this.leadRecordId != '' && this.leadRecordId != undefined &&
            ((this.currentCitySearch != '' && this.currentCitySearch != undefined) ||
                (this.officeCitySearch != '' && this.officeCitySearch != undefined))) {
            this.isCitySuccess = true;
        }

        if (!this.depStatusValue) {
            this.depStatusValue = 'New'
        }
        if (this.currentCitySearch) {
            if (this.cityIdSearch(this.currentCitySearch)) this.handleCurCitySelection()
        } else if (this.officeCitySearch) {
            if (this.cityIdSearch(this.officeCitySearch)) this.handleOffCitySelection()
        }

        this.MontlyIncdeclval = this.declredMontlyIncVal
        this.MontlyObldeclval = this.declredMontlyOblVal
        this.checkMadtryFieldsforEMI();
        this.getFOIR();

        if(this.empRole && this.empRole == 'DSA' && this.leadValue && this.leadValue === 'DSA'){
            this.DSAUserId = this.DSAUserId ? this.DSAUserId : this.rmNameId;
            this.rmNameId = ''; 
        }
    }

    @track isDSA = false;
    @api dsaContactId;
    @track loggedInUserRole;
    @track loggedInUSerCityId;
    @track searchInputName;
    // getisLoggedinUserDSA(){
    //     // this.showSpinner = true;
    //     let params = {
    //         ParentObjectName: 'TeamHierarchy__c',
    //         parentObjFields: ['Id', 'EmpRole__c','BranchCode__c','EmpLoc__c','EmpBrch__c','Employee__c','Employee__r.ContactId','Employee__r.Contact.AccountId','Employee__r.Contact.Account.Name'],
    //         queryCriteria: ' where Employee__c = \'' + this.currentUserId + '\''
    //     }
    //     getAssetPropType({ params: params })
    //         .then((result) => {
    //             console.log('Team Hierarchy Data is ', JSON.stringify(result));
    //             if (result.parentRecords) {
    //                 this.loggedInUserRole = result.parentRecords[0].EmpRole__c;
    //                 this.loggedInUSerCityId = result.parentRecords[0].EmpLoc__c;
    //                 result.parentRecords.forEach(item => {
    //                     if (item.EmpRole__c && item.EmpRole__c === 'DSA') {
    //                         this.isDSA = true;
    //                         this.dsaContactId = item.Employee__r.ContactId ? item.Employee__r.ContactId : '';
    //                         this.searchInput = item.Employee__r.Contact.AccountId ? item.Employee__r.Contact.AccountId : '';
    //                         this.searchInputName = item.Employee__r.Contact.AccountId ? item.Employee__r.Contact.Account.Name : '';
    //                         this.channelName = item.Employee__r.Contact.AccountId ? item.Employee__r.Contact.AccountId : '';
    //                     }
    //                 })
    //             }
    //             if(this.isDSA){
    //                 this.leadValue = 'DSA';
    //                 console.log('current logged in User role is ' , this.isDSA);
    //                 console.log('current logged in User ContactId is ' , this.dsaContactId);
    //                 console.log('current logged in User searchInput is ' , this.searchInput);
    //             }else{
    //                 this.disableBranch = false;
    //             }
    //             this.showSpinner = false;

    //             resolve(true);
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getting Team Hierarchy Data is ', error);
    //             reject(error);

    //             //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
    //         });
    // }
    @track teamHierId;
    getteamHierarchyId() {
        this.showSpinner = true;
        if (this.selectedDsaRmId) {
            let params = {
                ParentObjectName: 'TeamHierarchy__c',
                parentObjFields: [
                    'Id'
                ],
                queryCriteria: ` WHERE Employee__c = '${this.selectedDsaRmId}'`
            };
            // Call the Apex method and handle the result
            getAssetPropType({ params: params })
                .then((result) => {
                    console.log('Team Hierarchy Data is ', JSON.stringify(result));
                    if (result.parentRecords) {
                        this.teamHierId = result.parentRecords[0].Id;
                    }
                    this.getLocBranJunId();
                    // this.showSpinner = false;
                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log('Error in getting Team Hierarchy Data is ', error);
                });
        } else {
            this.getLocBranJunId();
        }

    }
    @track locationBranJnId;
    getLocBranJunId() {
        let params = {
            ParentObjectName: 'LocBrchJn__c',
            parentObjFields: ['Id'],
            queryCriteria: ` WHERE Branch__c = '${this.selectDSABranchId}'`
        };
        // Call the Apex method and handle the result
        getAssetPropType({ params: params })
            .then((result) => {
                console.log(' Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.locationBranJnId = result.parentRecords[0].Id;
                }
                // this.getLocBranJunId();
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error in getting Team Hierarchy Data is ', error);
            });
    }
    getisLoggedinUserDSA() {
        return new Promise((resolve, reject) => {
            // Optionally show a spinner or loading indicator
            this.showSpinner = true;
            // Define parameters for the Apex method
            let params = {
                ParentObjectName: 'TeamHierarchy__c',
                parentObjFields: [
                    'Id', 'EmpRole__c', 'BranchCode__c', 'EmpLoc__c', 'EmpBrch__c',
                    'Employee__c', 'Employee__r.ContactId', 'Employee__r.Contact.AccountId',
                    'Employee__r.Contact.Account.Name'
                ],
                queryCriteria: ` WHERE Employee__c = '${this.currentUserId}'`
            };
            // Call the Apex method and handle the result
            getAssetPropType({ params: params })
                .then((result) => {
                    console.log('Team Hierarchy Data is ', JSON.stringify(result));
                    if (result.parentRecords) {
                        this.loggedInUserRole = result.parentRecords[0].EmpRole__c;
                        this.loggedInUSerCityId = result.parentRecords[0].EmpBrch__c;

                        result.parentRecords.forEach(item => {
                            if (item.EmpRole__c === 'DSA') {
                                this.isDSA = true;
                                this.dsaContactId = item.Employee__r.ContactId || '';
                                this.searchInput = item.Employee__r.Contact.AccountId || '';
                                this.searchInputName = item.Employee__r.Contact.Account?.Name || '';
                                this.channelName = item.Employee__r.Contact.AccountId || '';
                                this.DSAUserId = item.Employee__c;
                            }
                        });
                    }

                    if (this.isDSA) {
                        this.leadValue = 'DSA';
                        this.assessedIncomeProgramValue1 = '';
                        this.isChannelSuccess = true;
                        console.log('Current logged-in User role is ', this.isDSA);
                        console.log('Current logged-in User ContactId is ', this.dsaContactId);
                        console.log('Current logged-in User Id is ', this.DSAUserId);
                        console.log('Current logged-in User searchInput is ', this.searchInput);
                    } else {
                        this.disableBranch = false;
                    }

                    this.showSpinner = false;
                    resolve(true); // Resolve the Promise successfully
                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log('Error in getting Team Hierarchy Data is ', error);
                    reject(error); // Reject the Promise with an error
                });
        });
    }
    @track selectDSACity;
    @api selectDSACityId;
    @track disableBranch = true;
    handleLookupFieldChange(event) {
        if (event.detail) {
            console.log('currentUserId====> ', this.currentUserId);
            console.log('Event detail in Sourcing Location Change====> ', event.detail);
            this.selectDSACity = event.detail.mainField;
            this.selectDSACityId = event.detail.id;
            this.disableBranch = false;
            this.selectDSABranch = '';
            this.locationBranJnId = '';
            this.selectDSABranchId = '';
            console.log("selectDSACity>>>", this.selectDSACity);
            this.dispatchEvent(new FlowAttributeChangeEvent('selectDSACityId', this.selectDSACityId))
        }
    }
    get filterConditionForBranc() {
        let returVal;
        if (this.loggedInUserRole && this.loggedInUserRole === 'DSA') {
            returVal = ' Location__c = \'' + this.selectDSACityId + '\'';
        } else {
            returVal = ' Branch__c = \'' + this.loggedInUSerCityId + '\'';
        }
        // return ' Location__c = \'' + this.selectDSACityId + '\'';
        return returVal;
    }

    get disableEMIButtonNew(){
        if(this.loanAmount && this.leadROI && this.tenure){
            return false;
        }
        return true;
    }
    @track salariedEl = false;
    @track selfEmpNonEl = false;
    @track selfEmpEl = false;
    @track defaultEl = false;
    get showEligibilityDetails() {
        if (this.productValue && (this.productValue === 'Personal Loan' || this.productValue === 'Business Loan') && this.customerProfileValue && this.customerProfileValue === 'SALARIED') {
            this.salariedEl = true;
            this.selfEmpNonEl = false;
            this.selfEmpEl = false;
            return true;
        } else if (this.productValue && (this.productValue === 'Personal Loan' || this.productValue === 'Business Loan') && this.customerProfileValue && this.customerProfileValue === 'SELF EMPLOYED NON PROFESSIONAL') {
            this.selfEmpNonEl = true;
            this.salariedEl = false;
            this.selfEmpEl = false;
            return true;
        } else if (this.productValue && (this.productValue === 'Personal Loan' || this.productValue === 'Business Loan') && this.customerProfileValue && this.customerProfileValue === 'SELF EMPLOYED PROFESSIONAL') {
            this.selfEmpEl = true;
            this.selfEmpNonEl = false;
            this.salariedEl = false;
            return true;
        } else {
            this.defaultEl = true;
            this.salariedEl = false;
            this.selfEmpEl = false;
            this.selfEmpNonEl = false;
        }
        this.defaultEl = true;
        return false;
    }
    // get disableFieldsOnProd(){
    //     if(this.productValue && (this.productValue === 'Personal Loan' || this.productValue === 'Business Loan')){
    //         return true;
    //     }
    //     return false;
    // }
    @track selectDSABranch;
    @api selectDSABranchId;
    handleBranchChange(event) {
        if (event.detail) {
            console.log('Event detail in Branch Change====> ', event.detail);
            this.selectDSABranch = event.detail.mainField;
            this.locationBranJnId = event.detail.id;
            this.selectDSABranchId = event.detail.record.Branch__c;
            this.selectedDsaRm = '';
            this.teamHierId = '';
            this.selectedDsaRmId = '';
          if(this.empRole && this.empRole == 'DSA' && this.leadValue && this.leadValue === 'DSA'){
            this.rmNameId = '';
          } 
            console.log("selectDSABranch>>>", this.selectDSABranch);
            console.log("selectDSABranchId>>>", this.selectDSABranchId);
            this.dispatchEvent(new FlowAttributeChangeEvent('selectDSABranchId', this.selectDSABranchId))
        }
    }
    get disableDSARM() {
        if (this.productValue && this.selectDSABranchId) {
            return false;
        }
        return true;
    }
    // get filterConditionForRM() {
    //     return 'EmpBrch__c = \'' + this.selectDSABranchId + '\' AND Product_Type__c INCLUDES (\'' + this.productValue + '\')';
    // }
    get filterConditionForRM() {
        return `EmpBrch__c = '${this.selectDSABranchId}' 
                AND Product_Type__c INCLUDES ('${this.productValue}') 
                AND (EmpRole__c = 'RM' OR EmpRole__c = 'SM')`;
    }

    @track selectedDsaRmId;
    @track selectedDsaRm;
    handleRmSelection(event) {
        if (event.detail) {
            console.log('Event detail in handleRmSelection====> ', event.detail);
            this.selectedDsaRm = event.detail.mainField;
            this.teamHierId = event.detail.id;
            this.selectedDsaRmId = event.detail.record.Employee__c;
            this.rmNameId = this.selectedDsaRmId;
            console.log("selectedDsaRmId>>>", this.selectedDsaRmId);
            this.dispatchEvent(new FlowAttributeChangeEvent('rmNameId', this.rmNameId))
        }
    }
    /*get disableLeadSource() {
        if (this.isDSA) {
            return true;
        }
        return this.disabledFlag;
    }*/
    cityIdSearch(cityName) {
        let cityFlag = false
        getCityIdFromLocMstr({
            cityName: cityName
        }).then(result => {
            this.cityId = result;
            cityFlag = true;
        }).catch(error => {
            console.error('error', error)
            cityFlag = false
        })
    }

    subscribeHandler() {
        subscribe(this.context, LEADDATAMC, (message) => {
            this.handleMessage(message)
        }, {
            scope: APPLICATION_SCOPE
        })
    }

    //used to upsert lead 
    handleSave() {
        let leadWrapObj = {
            lastName: this.lastName ? this.lastName : '',
            accountId: this.channelName,
            rmNameId: this.rmNameId,
            dispositionStatus: this.depStatusValue ? this.depStatusValue : '',
            productValue: this.productValue ? this.productValue : '',
            productSubTypeValue: this.productSubTypeValue ? this.productSubTypeValue : '',
            promotionCode: this.promotionCode ? this.promotionCode : '',
            promCodeId: this.promCodeId ? this.promCodeId : '',
            leadValue: this.leadValue ? this.leadValue : '',
            emailId: this.emailId ? this.emailId : '',
            firstName: this.firstName ? this.firstName : '',
            dob: this.dob1,
            companyChange: this.companyChange ? this.companyChange : '',
            doiValue: this.doiValue1,
            keyManName: this.keyManName ? this.keyManName : '',
            loanAmount: this.loanAmount ? this.loanAmount : null,
            assessedIncomeProgramValue: this.assessedIncomeProgramValue ? this.assessedIncomeProgramValue : false,
            propertyIdentifiedValue: this.propertyIdentifiedValue ? this.propertyIdentifiedValue : '',
            tenure: this.tenure ? this.tenure : null,
            propertyCategoryValue: this.propertyCategoryValue ? this.propertyCategoryValue : '',
            depositionRemark: this.depositionRemark ? this.depositionRemark : '',
            currentCitySearch: this.currentCitySearch ? this.currentCitySearch : '',
            officeCitySearch: this.officeCitySearch ? this.officeCitySearch : '',
            leadRecordId: this.leadRecordId,
            leadClosureValue: this.leadClosureValue ? this.leadClosureValue : '',
            lmsLeadId: this.lmsLeadId ? this.lmsLeadId : '',
            referralCode: this.referralCode ? this.referralCode : '',
            constitutionValue: this.constitutionValue ? this.constitutionValue : ' ',
            mobile: this.mobile ? this.mobile : ' ',
            customerProfileValue: this.customerProfileValue ? this.customerProfileValue : ' ',
            leadStatus: 'In Progress',
            cityService: this.cityService ? true : false,
            leadROI: this.leadROI ? this.leadROI : null,
            leadFOIR: this.leadFOIR ? this.leadFOIR : null,
            EMIperLac: this.EMIperLac ? this.EMIperLac : null,
            eligibilityinlacs: this.eligibilityinlacs ? this.eligibilityinlacs : null,
            emi: this.emi ? this.emi : null,
            declredMontlyIncVal: this.declredMontlyIncVal ? this.declredMontlyIncVal : null,
            declredMontlyOblVal: this.declredMontlyOblVal ? this.declredMontlyOblVal : null,
            selectDSACityId: this.selectDSACityId ? this.selectDSACityId : '',
            selectDSABranchId: this.selectDSABranchId ? this.selectDSABranchId : '',
            DSAUserId : this.DSAUserId ? this.DSAUserId : '',
            salExclVarPay : this.salExclVarPay ? this.salExclVarPay : null,
            avgVarPay : this.avgVarPay ? this.avgVarPay : null,
            dedInclIncomeTax : this.dedInclIncomeTax ? this.dedInclIncomeTax : null,
            avgAddIncome : this.avgAddIncome ? this.avgAddIncome : null,
            consultIncome : this.consultIncome ? this.consultIncome : null,
            netTakHomeSal : this.netTakHomeSal ? this.netTakHomeSal : null,
            totalNetMonthluInc : this.totalNetMonthluInc ? this.totalNetMonthluInc : null,
            grossRecipts : this.grossRecipts ? this.grossRecipts : null,
            patValue : this.patValue ? this.patValue : null,
            depreciation : this.depreciation ? this.depreciation : null,
            intrstExp : this.intrstExp ? this.intrstExp : null,
            OtheIcnme : this.OtheIcnme ? this.OtheIcnme : null,
            profQual : this.profQual ? this.profQual : '',
            applicableFOIR : this.applicableFOIR ? this.applicableFOIR : null,
            maxEligibleEMI : this.maxEligibleEMI ? this.maxEligibleEMI : null,
            maxLoanBasisFOIR : this.maxLoanBasisFOIR ? this.maxLoanBasisFOIR : null,
            maxLoanBasisNMIBand : this.maxLoanBasisNMIBand ? this.maxLoanBasisNMIBand : null,
            maxLoanEligibility : this.maxLoanEligibility ? this.maxLoanEligibility : null,
            netProfit : this.netProfit ? this.netProfit : null,
            grossProfReceipts : this.grossProfReceipts ? this.grossProfReceipts : null,
            program : this.program ? this.program : '',
            natureOfBusiness : this.natureOfBusiness ? this.natureOfBusiness : '',
            turnover : this.turnover ? thisturnover : null,
            last12MonthsTurnover : this.last12MonthsTurnover ? this.last12MonthsTurnover : null,
            intonEMIloanAddBack : this.intonEMIloanAddBack ? this.intonEMIloanAddBack : null,
            patCapital  :this.patCapital ? this.patCapital : null,
            abbValue : this.abbValue ? this.abbValue : null,
            emiGoingFrmOthrAcnt : this.emiGoingFrmOthrAcnt ? this.emiGoingFrmOthrAcnt : null
        }
        console.log('leadWrapObj ', leadWrapObj);
        this.leadStatus = 'In Progress'
        this.showSpinner = true;
        if (!this.constitutionValue) {
            this.showToastMessage('Error', this.label.CUST_PROFILE_Label, 'error', 'sticky')
            this.showSpinner = false;
        } else if (this.constitutionValue == 'INDIVIDUAL') {
            if (!this.lastName) {
                this.showToastMessage('Error', this.label.LAST_NAME_Label, 'error', 'sticky')
                this.showSpinner = false;
                return;
            } else {
                if (this.validateEmail()) {
                    this.createUpdateLead(leadWrapObj);
                } else {
                    this.showToastMessage('Error', this.label.EMAIL_ID_ERR_Label, 'error', 'sticky')
                    this.showSpinner = false;
                }
            }
        } else if (this.constitutionValue != 'INDIVIDUAL') {
            if (!this.companyChange) {
                this.showToastMessage('Error', this.label.COMPANY_NAME_Label, 'error', 'sticky')
                this.showSpinner = false;
                return;
            } else {
                this.lastName = this.companyChange
                if (this.validateEmail()) {
                    this.createUpdateLead(leadWrapObj);
                } else {
                    this.showToastMessage('Error', this.label.EMAIL_ID_ERR_Label, 'error', 'sticky')
                    this.showSpinner = false;
                }
            }
        }

    }


    //used to close lead from Closed Lead button
    handleMessage(message) {
        let leadWrapObj = {
            lastName: this.lastName ? this.lastName : '',
            accountId: this.channelName,
            rmNameId: this.rmNameId,
            dispositionStatus: this.depStatusValue ? this.depStatusValue : '',
            productValue: this.productValue ? this.productValue : '',
            productSubTypeValue: this.productSubTypeValue ? this.productSubTypeValue : '',
            promotionCode: this.promotionCode ? this.promotionCode : '',
            promCodeId: this.promCodeId ? this.promCodeId : '',
            leadValue: this.leadValue ? this.leadValue : '',
            emailId: this.emailId ? this.emailId : '',
            firstName: this.firstName ? this.firstName : '',
            dob: this.dob1,
            companyChange: this.companyChange ? this.companyChange : '',
            doiValue: this.doiValue1,
            keyManName: this.keyManName ? this.keyManName : '',
            loanAmount: this.loanAmount ? this.loanAmount : null,
            assessedIncomeProgramValue: this.assessedIncomeProgramValue ? this.assessedIncomeProgramValue : false,
            propertyIdentifiedValue: this.propertyIdentifiedValue ? this.propertyIdentifiedValue : '',
            tenure: this.tenure ? this.tenure : null,
            propertyCategoryValue: this.propertyCategoryValue ? this.propertyCategoryValue : '',
            depositionRemark: this.depositionRemark ? this.depositionRemark : '',
            currentCitySearch: this.currentCitySearch ? this.currentCitySearch : '',
            officeCitySearch: this.officeCitySearch ? this.officeCitySearch : '',
            leadRecordId: this.leadRecordId,
            leadClosureValue: this.leadClosureValue ? this.leadClosureValue : '',
            lmsLeadId: this.lmsLeadId ? this.lmsLeadId : '',
            referralCode: this.referralCode ? this.referralCode : '',
            constitutionValue: this.constitutionValue ? this.constitutionValue : ' ',
            mobile: this.mobile ? this.mobile : ' ',
            customerProfileValue: this.customerProfileValue ? this.customerProfileValue : ' ',
            leadStatus: 'In Progress',
            cityService: this.cityService ? true : false,
            leadROI: this.leadROI ? this.leadROI : null,
            leadFOIR: this.leadFOIR ? this.leadFOIR : null,
            EMIperLac: this.EMIperLac ? this.EMIperLac : null,
            eligibilityinlacs: this.eligibilityinlacs ? this.eligibilityinlacs : null,
            emi: this.emi ? this.emi : null,
            declredMontlyIncVal: this.declredMontlyIncVal ? this.declredMontlyIncVal : null,
            declredMontlyOblVal: this.declredMontlyOblVal ? this.declredMontlyOblVal : null,
            selectDSACityId: this.selectDSACityId ? this.selectDSACityId : '',
            selectDSABranchId: this.selectDSABranchId ? this.selectDSABranchId : '',
            DSAUserId : this.DSAUserId ? this.DSAUserId : '',
            salExclVarPay : this.salExclVarPay ? this.salExclVarPay : null,
            avgVarPay : this.avgVarPay ? this.avgVarPay : null,
            dedInclIncomeTax : this.dedInclIncomeTax ? this.dedInclIncomeTax : null,
            avgAddIncome : this.avgAddIncome ? this.avgAddIncome : null,
            consultIncome : this.consultIncome ? this.consultIncome : null,
            netTakHomeSal : this.netTakHomeSal ? this.netTakHomeSal : null,
            totalNetMonthluInc : this.totalNetMonthluInc ? this.totalNetMonthluInc : null,
            grossRecipts : this.grossRecipts ? this.grossRecipts : null,
            patValue : this.patValue ? this.patValue : null,
            depreciation : this.depreciation ? this.depreciation : null,
            intrstExp : this.intrstExp ? this.intrstExp : null,
            OtheIcnme : this.OtheIcnme ? this.OtheIcnme : null,
            profQual : this.profQual ? this.profQual : '',
            applicableFOIR : this.applicableFOIR ? this.applicableFOIR : null,
            maxEligibleEMI : this.maxEligibleEMI ? this.maxEligibleEMI : null,
            maxLoanBasisFOIR : this.maxLoanBasisFOIR ? this.maxLoanBasisFOIR : null,
            maxLoanBasisNMIBand : this.maxLoanBasisNMIBand ? this.maxLoanBasisNMIBand : null,
            maxLoanEligibility : this.maxLoanEligibility ? this.maxLoanEligibility : null,
            netProfit : this.netProfit ? this.netProfit : null,
            grossProfReceipts : this.grossProfReceipts ? this.grossProfReceipts : null,
            program : this.program ? this.program : '',
            natureOfBusiness : this.natureOfBusiness ? this.natureOfBusiness : '',
            turnover : this.turnover ? thisturnover : null,
            last12MonthsTurnover : this.last12MonthsTurnover ? this.last12MonthsTurnover : null,
            intonEMIloanAddBack : this.intonEMIloanAddBack ? this.intonEMIloanAddBack : null,
            patCapital  :this.patCapital ? this.patCapital : null,
            abbValue : this.abbValue ? this.abbValue : null,
            emiGoingFrmOthrAcnt : this.emiGoingFrmOthrAcnt ? this.emiGoingFrmOthrAcnt : null
        }

        if (message.lmsData.value === 'Save as draft') {

            // Set leadStatus based on Disposition Status using if-else
            if (this.dispositionStatus === 'New') {
                this.leadStatus = 'New';
            } else if (this.dispositionStatus === 'Customer Not Contactable' || 
                       this.dispositionStatus === 'Call Back Requested' || 
                       this.dispositionStatus === 'Details or Documents Awaited') {
                this.leadStatus = 'In Progress';
            } else if (this.dispositionStatus === 'Lead Converted') {
                this.leadStatus = 'Converted';
            } else if (this.dispositionStatus === 'Lead Closed') {
                this.leadStatus = 'Closed';
            } else {
                this.leadStatus = 'In Progress'; // Default status if disposition status is not matched
            }
            this.showSpinner = true;
            if (!this.constitutionValue) {
                this.showToastMessage('Error', this.label.CUST_PROFILE_Label, 'error', 'sticky')
                this.showSpinner = false;
            } else if (this.constitutionValue == 'INDIVIDUAL') {
                if (!this.lastName) {
                    this.showToastMessage('Error', this.label.LAST_NAME_Label, 'error', 'sticky')
                    this.showSpinner = false;
                    return;
                } else {
                    if (this.validateEmail()) {
                        this.createUpdateLead(leadWrapObj);
                    } else {
                        this.showToastMessage('Error', this.label.EMAIL_ID_ERR_Label, 'error', 'sticky')
                        this.showSpinner = false;
                    }
                }
            } else if (this.constitutionValue != 'INDIVIDUAL') {
                if (!this.companyChange) {
                    this.showToastMessage('Error', this.label.COMPANY_NAME_Label, 'error', 'sticky')
                    this.showSpinner = false;
                    return;
                } else {
                    this.lastName = this.companyChange
                    if (this.validateEmail()) {
                        this.createUpdateLead(leadWrapObj);
                    } else {
                        this.showToastMessage('Error', this.label.EMAIL_ID_ERR_Label, 'error', 'sticky')
                        this.showSpinner = false;
                    }
                }

            }


        }

        if (message.lmsData.value === 'Close Lead') {
            if (this.validateForm()) {
                this.isShowModal = true;
                this.modalFieldFlag = true
            } else {
                this.showToastMessage('Error', this.label.ALL_FIELDS_Label, 'error', 'sticky');
                this.modalFieldFlag = false
            }
        }

        /////////////////
        if (message.lmsData.value === 'emi calculator') {
            this.showEMICalculator = true;
        }
        ////////////////
    }

    createUpdateLead(leadWrapObj) {
        createLeadRecord({
            wrapObj: leadWrapObj
        })
            .then(result => {
                this.leadRecordId = result;
                this.showToastMessage('Success', this.label.LEAD_SUCCESS_Label, 'success', 'sticky')
                this.showSpinner = false;
                this.enableClosedButton()
                //  this.navigateToListView()
                refreshApex(this.wiredRefData)
                //LAK-9291
                if(this.lmsLeadId && this.leadRecordId && this.leadValue === 'Digital'){
                    this.disableLMSId = true;
                }
            }).catch(error => {
                console.error(error);
                this.showSpinner = false;
            })
    }


    toastMessage(message, label, theme) {
        LightningAlert.open({
            message,
            label,
            theme
        })
    }


    handleEmiCalculator(){
        this.showEMICalculator = true;
    }
@track showEMICalculatorNew = false;
    handleEmiCalculatorNew(){
        this.showEMICalculatorNew = true;
        if(this.customerProfileValue && this.customerProfileValue === 'SALARIED'){
           this.salariedEl = true;
           this.emiNew = this.emi;
           this.monthlyObl = this.declredMontlyOblVal;
           this.selfEmpEl = false;
           this.selfEmpNonEl = false;
        }else if(this.customerProfileValue && this.customerProfileValue === 'SELF EMPLOYED PROFESSIONAL'){
            this.salariedEl = false;
            this.selfEmpEl = true;
            this.selfEmpNonEl = false;
            this.emiSEP = this.emi;
           this.monthlyObli = this.declredMontlyOblVal;
         }else if(this.customerProfileValue && this.customerProfileValue === 'SELF EMPLOYED NON PROFESSIONAL'){
            this.salariedEl = false;
            this.selfEmpEl = false;
            this.selfEmpNonEl = true;
         }
    }
    // handleFocus(){
    //     this.errorMessage = false
    // }


    // handlePromotionCode(event) {
    //     this.promotionCode = event.target.value
    //     if (this.promotionCode && this.productValue) {
    //         this.promotionCodeFunction()
    //     } else {
    //         this.searchResult3 = false
    //     }
    // }

    @api promCodeId;
    // promotionCodeFunction() {

    // getData({
    //         fields: "PromoDesc__c",
    //         objectName: "PromoMapping__c",
    //         inputField: 'PromoDesc__c',
    //         likeFilter: this.promotionCode,
    //         field1: 'ProductType__c',
    //         filter1: this.productValue,
    //         field2: '',
    //         filter2: ''
    //     })
    //     .then(result => {
    //         this.promCodeId = result[0].Id;
    //         this.promotionData = result.map(item => ({
    //             label: item.Id,
    //             value: item.PromoDesc__c
    //         }))
    //         this.errorMessage3 = result.length === 0 && this.promotionCode != ' '
    //         this.searchResult3 = result.length > 0
    //     }).catch(error => {
    //         console.log(error)
    //     })
    // }


    handlePromotionSelection(event) {
        this.lookupRec = event.detail;
        console.log("this.lookupRec>>>>>", this.lookupRec);

        let lookupId = this.lookupRec.id;
        this.promotionCode = lookupId;
        this.promCodeId = lookupId;
        this.dispatchEvent(new FlowAttributeChangeEvent('promotionCode', this.promotionCode))
        this.searchResult3 = false;
    }


    lmsLeadIdHandler(event) {
        this.lmsLeadId = this.convertToUppercase(event.target.value);
        this.dispatchEvent(new FlowAttributeChangeEvent('lmsLeadId', this.lmsLeadId))
    }
    referralCodeHandler(event) {
        this.referralCode = this.convertToUppercase(event.target.value);
        if (this.referralCode) {
            this.referralCode = trimFunction(this.referralCode)
        }
        this.dispatchEvent(new FlowAttributeChangeEvent('referralCode', this.referralCode))
    }

    doiErrMessage
    doiHandler(event) {
        this.doiValue1 = event.target.value
        // if(new Date().getTime() - new Date(this.doiValue1).getTime() >= 1){
        //     this.doiErrMessage =''
        // }else{
        //     this.doiErrMessage = "Please enter past date"
        // }      

    }

    companyChangeHandler(event) {
        this.companyChange = this.convertToUppercase((event.target.value));
    }
    keyManHandler(event) {
        this.keyManName = this.convertToUppercase(event.target.value);
    }

    handleCurrentCityResponse(event) {
        this.currentCityonclick = '';
        this.currentCitySearch = event.target.value
        if (this.currentCitySearch) {
            this.currentCityFunction();
        } else {
            this.searchResult1 = false
        }
        this.isCitySuccess = false;

    }

    handleChannelResponse(event) {
        this.searchInputOnClick = '';
        this.searchInput = event.target.value
        if (this.searchInput) {
            this.picklistFunction()
        } else {
            this.searchResult4 = false
        }
        this.isChannelSuccess = false;
    }


    picklistFunction() {
        let accData = []
        getData({
            fields: "Account__r.Id,Account__r.Name",
            objectName: "DSABrchJn__c",
            inputField: "Account__r.Name",
            likeFilter: this.searchInput,
            field1: "RMUsr__r.Name",
            filter1: this.rmNameValue,
            field2: "Account__r.RecordType.Name",
            filter2: this.leadValue
        })
            .then(result => {
                accData = result.map(item => {
                    return item.Account__r
                })
                this.resultData = accData.map(item => ({
                    label: item.Id,
                    value: item.Name
                }))
                this.errorMessage4 = result.length === 0 && this.searchInput != ' '
                this.searchResult4 = result.length > 0
            }).catch(error => {
                console.log(error)
            })
    }

    handleChannelSelection(event) {
        this.channelName = event.currentTarget.dataset.value
        this.searchInput = event.currentTarget.dataset.label

        this.searchInputOnClick = this.searchInput;
        getChannel({
            Channelname: this.searchInput
        })
            .then(result => {
                if (result === false) {
                    if (this.searchInput != null) {
                        this.errorMessage4 = true;
                        this.showToastMessage('Error', this.label.LeadCapture_ChannelName_ErrorMessage, 'error', 'sticky');
                    } else {
                        this.errorMessage4 = false;
                    }
                } else {
                    this.isChannelSuccess = true;
                    this.errorMessage4 = false;
                }
            });

        this.searchResult4 = false
    }

    handleOfficeCityResponse(event) {
        this.ofcCityOnClick = '';
        this.officeCitySearch = event.target.value
        if (this.officeCitySearch) {
            this.officeCityFunction();
        } else {
            this.searchResult2 = false
        }
        this.isCitySuccess = false;
    }


    officeCityFunction() {
        getData({
            fields: "City__c,IsServiceable__c",
            objectName: "LocMstr__c",
            inputField: 'City__c',
            likeFilter: this.officeCitySearch,
            field1: '',
            filter1: '',
            field2: '',
            filter2: ''
        })
            .then(result => {
                const ids = JSON.parse(JSON.stringify(result)).map(({
                    City__c
                }) => City__c);
                const filtered = JSON.parse(JSON.stringify(result)).filter(({
                    City__c
                }, index) =>
                    !ids.includes(City__c, index + 1));
                this.officeCityData = filtered.map(item => ({
                    label: item.Id,
                    value: item.City__c,
                    subfield: item.IsServiceable__c
                }))
                this.errorMessage2 = result.length === 0 && this.currentCitySearch != ' '
                this.searchResult2 = result.length > 0
            }).catch(error => {
                console.log(error)
            })
    }

    currentCityFunction() {
        getData({
            fields: "City__c,IsServiceable__c",
            objectName: "LocMstr__c",
            inputField: 'City__c',
            likeFilter: this.currentCitySearch,
            field1: '',
            filter1: '',
            field2: '',
            filter2: ''
        })
            .then(result => {
                const ids = JSON.parse(JSON.stringify(result)).map(({
                    City__c
                }) => City__c);
                const filtered = JSON.parse(JSON.stringify(result)).filter(({
                    City__c
                }, index) =>
                    !ids.includes(City__c, index + 1));
                this.currentCityData = filtered.map(item => ({
                    label: item.Id,
                    value: item.City__c,
                    subfield: item.IsServiceable__c
                }))
                this.errorMessage1 = result.length === 0 && this.currentCitySearch != ' '
                this.searchResult1 = result.length > 0
            }).catch(error => {
                console.log(error)
            })
    }

    @track cityId

    handleOffCitySelection(event) {
        this.cityId = event.currentTarget.dataset.value
        this.officeCitySearch = event.currentTarget.dataset.label
        this.ofcCityOnClick = this.officeCitySearch;
        getCity({
            Cityname: this.officeCitySearch
        })
            .then(result => {
                if (result === false) {
                    if (this.currentCitySearch != null) {
                        this.errorMessage2 = true;
                        this.showToastMessage('Error', this.label.LeadCapture_CityName_ErrorMessage, 'error', 'sticky');
                    } else {
                        this.errorMessage2 = false;
                    }
                } else {
                    this.isCitySuccess = true;
                    this.errorMessage2 = false;
                }
            });
        this.serviceableSearch();
        this.searchResult2 = false
    }


    handleCurCitySelection(event) {
        this.cityId = event.currentTarget.dataset.value
        this.currentCitySearch = event.currentTarget.dataset.label
        this.currentCityonclick = this.currentCitySearch;
        getCity({
            Cityname: this.currentCitySearch
        })
            .then(result => {
                if (result === false) {
                    if (this.currentCitySearch != null) {
                        this.errorMessage1 = true;
                        this.showToastMessage('Error', this.label.LeadCapture_CityName_ErrorMessage, 'error', 'sticky');
                    } else {
                        this.errorMessage1 = false;
                    }
                } else {
                    this.isCitySuccess = true;
                    this.errorMessage1 = false;
                }
            });
        this.serviceableSearch();
        this.searchResult1 = false
    }

    @track
    locBranJunParams = {
        ParentObjectName: 'LocBrchJn__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Location__c', 'ProductType__c', 'IsActive__c'],
        childObjFields: [],
        queryCriteria: ' where Location__c = \'' + this.cityId + '\'' + ' AND ProductType__c = \'' + this.productValue + '\''
    }

    serviceableSearch() {
        this.locBranJunParams.queryCriteria = ' where Location__c = \'' + this.cityId + '\'' + ' AND ProductType__c INCLUDES (\'' + this.productValue + '\') LIMIT 1'
        getSobjectData({
            params: this.locBranJunParams
        })
            .then((result) => {
                if (result.parentRecords) {
                    if (result.parentRecords != 'undefined' && result.parentRecords.length > 0) {
                        this.cityCheck = result.parentRecords[0].IsActive__c;
                        this.cityService = !result.parentRecords[0].IsActive__c;
                    }
                } else {
                    this.cityCheck = false
                    this.cityService = true
                }
            })
            .catch((error) => {
                console.error('Error in line ##213', error)
            })
    }


    leadClosureReason() {
        if (this.leadClosureVisibilty && this.leadClosureValue) {
            return true
        } else {
            return false
        }
    }

    proValueCheck() {
        if ((this.productValue == 'Small Ticket LAP' || this.productValue == 'Loan Against Property') || (this.productValue == 'Home Loan' && this.propertyIdentifiedValue == 'Yes')) {
            if (this.propertyCategoryValue) {
                return true
            }
        }
    }

    //used to validate all validation 
    validateForm() {
        let isValid = true
        if (this.isDSA) {
            if (!this.checkValidityLookup()) {
                isValid = false;
            }
        }
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if (element.reportValidity()) { } else {
                isValid = false;
            }
        });
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) { } else {
                isValid = false;
            }
        });

        if ((this.leadValue === 'Connector' || this.leadValue === 'DSA') && !this.channelName) {
            isValid = false
        }

        if (!this.loanAmountValid()) {
            isValid = false
        }
        if (!this.tenureValid()) {
            isValid = false
        }
        if (this.constitutionValue == 'INDIVIDUAL') {
            if (this.validateDOB(this.dob1) == false) {
                this.showToastMessage('Error', this.label.DOB_Label, 'error', 'sticky')
                isValid = false
            }
        }
        if (this.constitutionValue != 'INDIVIDUAL') {
            if (new Date().getTime() - new Date(this.doiValue1).getTime() >= 1) {
                this.doiErrMessage = ''
            } else {
                this.doiErrMessage = "Please enter past date"
                isValid = false
            }
        }
        return isValid;
    }

    checkValidityLookup() {
        let isInputCorrect = true;
        let allChilds = this.template.querySelectorAll("c-custom-lookup");
        console.log("custom lookup allChilds>>>", allChilds);
        allChilds.forEach((child) => {
            console.log("custom lookup child>>>", child);
            console.log("custom lookup validity custom lookup >>>", isInputCorrect);
            if (!child.checkValidityLookup()) {
                child.checkValidityLookup();
                isInputCorrect = false;
                console.log("custom lookup validity if false>>>", isInputCorrect);
            }
        });
        return isInputCorrect;
    }

    //used to go to next screen component after checking validation
    handleNext() {
        var cityName;
        if (this.currentCityonclick) {
            cityName = this.currentCityonclick;
        }
        if (this.ofcCityOnClick) {
            cityName = this.ofcCityOnClick;
        }
        getCity({
            Cityname: cityName
        })
            .then(result => {
                if (result === false) {
                    if (this.currentCityonclick != null) {
                        this.showToastMessage('Error', this.label.LeadCapture_CityName_ErrorMessage, 'error', 'sticky');
                    }
                    if (this.ofcCityOnClick != null) {
                        this.showToastMessage('Error', this.label.LeadCapture_CityName_ErrorMessage, 'error', 'sticky');
                    }
                    this.validateInputFields();
                    return;
                }
            }).catch(error => {
                console.log(error)
            })
        if (this.leadValue === 'DSA' || this.leadValue === 'Connector') {
            var channel = this.searchInputOnClick;
            getChannel({
                Channelname: channel
            })
                .then(result => {
                    if (result === false) {
                        if (this.searchInputOnClick != null) {
                            // this.errorMessage1 = true;
                            // this.showToastMessage('Error','Please select the channel name','error','sticky');
                        }
                        this.validateInputFields();
                        return;
                    }
                }).catch(error => {
                    console.log(error)
                })
        }
        if (this.leadValue === 'DSA' || this.leadValue === 'Connector') {
            if (this.isCitySuccess == true && this.isChannelSuccess == true) {
                this.handleNextAction();
                this.errorMessage4 = false;
                this.errorMessage1 = false;
            }
        } else if (this.isCitySuccess == true) {
            this.handleNextAction();
            this.errorMessage4 = false;
            this.errorMessage1 = false;
        }

        //to check validations on Next Button 
        if (!this.validateForm()) {
            if ((this.leadValue === 'Connector' || this.leadValue === 'DSA') && !this.channelName) {
                this.showToastMessage('Error', this.label.CHANNEL_NAME_Label, 'error', 'sticky')
            } else {
                console.log('inside handleNext')
                this.showToastMessage('Error', this.label.ALL_FIELDS_Label, 'error', 'sticky');
            }

        }
    }


    validateInputFields() {
        if (this.validateForm() && this.otherValidityForm()) {
            if (!this.cityCheck) {
                this.showToastMessage('Error', this.label.UNSERVICEABLE_CITY_Label, 'error', 'sticky');
                return;
            } else if (this.errorMessage1 == true || this.errorMessage2 == true || this.errorMessage4 == true) {
                return;
            }
            if (this.constitutionValue != 'INDIVIDUAL') {
                this.lastName = this.companyChange
            }
            var fields = {
                'LastName': this.lastName,
                'MobilePhone': this.mobile,
                'Status': this.leadStatus ? this.leadStatus : 'In Progress',
                //'UnservicableCityCheck__c' : this.cityService == "false" ? true : false
            }
        }
    }

    handleNextAction() {
        if (this.validateForm() && this.otherValidityForm()) {
            if (this.validateEmail()) {
                if (!this.cityCheck) {
                    this.showToastMessage('Error', this.label.UNSERVICEABLE_CITY_Label, 'error', 'sticky');
                    return;
                } else if (this.errorMessage1 == true || this.errorMessage2 == true || this.errorMessage4 == true) {
                    return;
                }
                if (this.constitutionValue != 'INDIVIDUAL') {
                    this.lastName = this.companyChange
                }
                var fields = {
                    'LastName': this.lastName,
                    'MobilePhone': this.mobile,
                    'Status': this.leadStatus ? this.leadStatus : 'In Progress',
                    'Lead_ROI__c': this.leadROI ? this.leadROI : null,
                    'DSAContact__c': this.dsaContactId ? this.dsaContactId : null,
                    'LeadJuryBY__c': this.empRole && this.empRole === 'DSA' ? 'DSA' : 'RM/SM',
                    'DSAUserId__c': this.DSAUserId ? this.DSAUserId : '',
                    // 'RM_SM_Name__c' : this.rmNameId ? this.rmNameId : ''
                    //'UnservicableCityCheck__c' : this.cityService == "false" ? true : false
                }
                if (!this.leadRecordId) {

                    const recordInput = {
                        apiName: LEAD_OBJECT.objectApiName,
                        fields: fields
                    };

                    createRecord(recordInput).then((record) => {
                        this.leadRecordId = record.id;
                        const nextNavigationEvent = new FlowNavigationNextEvent();
                        this.dispatchEvent(nextNavigationEvent);

                    }).catch(error => {
                        console.log('Error from Next button -' + JSON.stringify(error))
                    })
                } else {
                    const nextNavigationEvent = new FlowNavigationNextEvent();
                    this.dispatchEvent(nextNavigationEvent);
                }
            } else {
                this.showToastMessage('Error', this.label.EMAIL_ID_ERR_Label, 'error', 'sticky')
                this.showSpinner = false;
            }
        } else {
            console.log('inside handleNextAction')
            this.showToastMessage('Error', this.label.ALL_FIELDS_Label, 'error', 'sticky');
        }
    }

    closeLeadHandler() {
        let leadWrapObj = {
            lastName: this.lastName ? this.lastName : '',
            accountId: this.channelName,
            rmNameId: this.rmNameId,
            dispositionStatus: 'Lead closed',
            productValue: this.productValue ? this.productValue : '',
            productSubTypeValue: this.productSubTypeValue ? this.productSubTypeValue : '',
            promotionCode: this.promotionCode ? this.promotionCode : '',
            promCodeId: this.promCodeId ? this.promCodeId : '',
            leadValue: this.leadValue ? this.leadValue : '',
            emailId: this.emailId ? this.emailId : '',
            firstName: this.firstName ? this.firstName : '',
            dob: this.dob1,
            companyChange: this.companyChange ? this.companyChange : '',
            doiValue: this.doiValue1,
            keyManName: this.keyManName ? this.keyManName : '',
            loanAmount: this.loanAmount ? this.loanAmount : null,
            assessedIncomeProgramValue: this.assessedIncomeProgramValue ? this.assessedIncomeProgramValue : false,
            propertyIdentifiedValue: this.propertyIdentifiedValue ? this.propertyIdentifiedValue : '',
            tenure: this.tenure ? this.tenure : null,
            propertyCategoryValue: this.propertyCategoryValue ? this.propertyCategoryValue : '',
            depositionRemark: this.depositionRemark ? this.depositionRemark : '',
            currentCitySearch: this.currentCitySearch ? this.currentCitySearch : '',
            officeCitySearch: this.officeCitySearch ? this.officeCitySearch : '',
            leadRecordId: this.leadRecordId,
            leadClosureValue: this.leadClosureValue ? this.leadClosureValue : '',
            lmsLeadId: this.lmsLeadId ? this.lmsLeadId : '',
            referralCode: this.referralCode ? this.referralCode : '',
            constitutionValue: this.constitutionValue ? this.constitutionValue : ' ',
            mobile: this.mobile ? this.mobile : ' ',
            customerProfileValue: this.customerProfileValue ? this.customerProfileValue : ' ',
            leadStatus: 'Closed',
            otherReason: this.otherReason ? this.otherReason : '',
            cityService: this.cityService ? true : false,
            leadROI: this.leadROI ? this.leadROI : null,
            leadFOIR: this.leadFOIR ? this.leadFOIR : null,
            EMIperLac: this.EMIperLac ? this.EMIperLac : null,
            eligibilityinlacs: this.eligibilityinlacs ? this.eligibilityinlacs : null,
            emi: this.emi ? this.emi : null,
            declredMontlyIncVal: this.declredMontlyIncVal ? this.declredMontlyIncVal : null,
            declredMontlyOblVal: this.declredMontlyOblVal ? this.declredMontlyOblVal : null,
            selectDSACityId: this.selectDSACityId ? this.selectDSACityId : '',
            selectDSABranchId: this.selectDSABranchId ? this.selectDSABranchId : '',
            DSAUserId : this.DSAUserId ? this.DSAUserId : '',
            salExclVarPay : this.salExclVarPay ? this.salExclVarPay : null,
            avgVarPay : this.avgVarPay ? this.avgVarPay : null,
            dedInclIncomeTax : this.dedInclIncomeTax ? this.dedInclIncomeTax : null,
            avgAddIncome : this.avgAddIncome ? this.avgAddIncome : null,
            consultIncome : this.consultIncome ? this.consultIncome : null,
            netTakHomeSal : this.netTakHomeSal ? this.netTakHomeSal : null,
            totalNetMonthluInc : this.totalNetMonthluInc ? this.totalNetMonthluInc : null,
            grossRecipts : this.grossRecipts ? this.grossRecipts : null,
            patValue : this.patValue ? this.patValue : null,
            depreciation : this.depreciation ? this.depreciation : null,
            intrstExp : this.intrstExp ? this.intrstExp : null,
            OtheIcnme : this.OtheIcnme ? this.OtheIcnme : null,
            profQual : this.profQual ? this.profQual : '',
            applicableFOIR : this.applicableFOIR ? this.applicableFOIR : null,
            maxEligibleEMI : this.maxEligibleEMI ? this.maxEligibleEMI : null,
            maxLoanBasisFOIR : this.maxLoanBasisFOIR ? this.maxLoanBasisFOIR : null,
            maxLoanBasisNMIBand : this.maxLoanBasisNMIBand ? this.maxLoanBasisNMIBand : null,
            maxLoanEligibility : this.maxLoanEligibility ? this.maxLoanEligibility : null,
            netProfit : this.netProfit ? this.netProfit : null,
            grossProfReceipts : this.grossProfReceipts ? this.grossProfReceipts : null,
            program : this.program ? this.program : '',
            natureOfBusiness : this.natureOfBusiness ? this.natureOfBusiness : '',
            turnover : this.turnover ? thisturnover : null,
            last12MonthsTurnover : this.last12MonthsTurnover ? this.last12MonthsTurnover : null,
            intonEMIloanAddBack : this.intonEMIloanAddBack ? this.intonEMIloanAddBack : null,
            patCapital  :this.patCapital ? this.patCapital : null,
            abbValue : this.abbValue ? this.abbValue : null,
            emiGoingFrmOthrAcnt : this.emiGoingFrmOthrAcnt ? this.emiGoingFrmOthrAcnt : null
        }
        if (this.leadClosureValue) {
            if (this.leadClosureValue == 'Others') {
                if (!this.validateOther()) {
                    this.showToastMessage('Error', this.label.COMMENT_VAL_Label, 'error', 'sticky')
                    return;
                }
            }

            this.leadStatus = 'Closed'
            createLeadRecord({
                wrapObj: leadWrapObj
            }).then(result => {
                this.constiFlag = true
                this.disabledFlag = true
                //this.constiFlag = true
                this.leadRecordId = result
                this.showToastMessage('Success', this.label.LeadCapture_Close_SuccessMessage, 'success', 'sticky')
                this.showSpinner = false;
                this.navigateToLeadDetailPage(result)
            }).catch(error => {
                console.error(error);
                this.showSpinner = false;
                this.disabledFlag = false;
                this.constiFlag = false
            })
            this.isShowModal = false;
        } else {
            this.showToastMessage('Error', this.label.LEAD_CLOSURE_Label, 'error', 'sticky')
        }
    }

    enableClosedButton() {
        const message = {
            lmsData: {
                value: 'Enable Close Lead Button'
            }
        }
        publish(this.context, LEADDATAMC, message);
    }

    enableEMICalculatorButton() {
        // const message = {
        //     lmsData: {
        //         value: 'Enable EMI Calculator Button'
        //     }
        // }
        // publish(this.context, LEADDATAMC, message);
        this.disableEMIButton = false;
    }

    disableEMICalculatorButton() {
        // const message = {
        //     lmsData: {
        //         value: 'Disable EMI Calculator Button'
        //     }
        // }
        // publish(this.context, LEADDATAMC, message);
        this.disableEMIButton = true;
    }

    //used to close the modal
    cancelHandler() {
        this.isShowModal = false;
        this.otherSelected = false
        this.leadClosureValue = ''
    }
    //used to close the EMI Calculator modal
    closeEMICalculator() {
        this.showEMICalculator = false;
    }
    closeEMICalculatorNew() {
        this.showEMICalculatorNew = false;
        this.salariedEmi = false;
    }
    closeEMICalculatorSEP() {
        this.showEMICalculatorNew = false;
        this.sepEmi = false;
    }
    closeEMICalculatorSEPNon(){
        this.showEMICalculatorNew = false;
        this.sepEmi = false;
    }

    handleCancel() {
        this.navigateToListView();
    }

    navigateToListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Lead',
                actionName: 'list'
            },
            // state : {
            //     filterName : 'Recent'
            // }
        })
    }

    navigateToLeadDetailPage(leadId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: leadId,
                objectApiName: 'Lead',
                actionName: 'view'
            }
        })
    }

    otherCommentsHandler(event) {
        this.otherReason = this.convertToUppercase(event.target.value);
        this.validateOther()
    }

    validateOther() {
        let flag = true
        if (!this.otherReason) {
            this.showToastMessage('Error', this.label.COMMENT_VAL_Label, 'error', 'sticky')
            flag = false
        } else {
            flag = true
        }
        return flag
    }

    otherValidityForm() {
        let flag = true
        if (this.leadClosureValue == 'Others' && !this.validateOther()) {
            flag = false
        } else {
            flag = true
        }

        return flag
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
    //Start Changes for LAK-321 this.leadRecordId

    get leadROINew() {
        return this.leadROI;
    }

    get isthisAssIncom() {
        return this.assessedIncomeProgramValue;
    }

    retriveLeadROIMethod() {
        if (this.productValue && (((this.productValue == 'Small Ticket LAP' || this.productValue == 'Home Loan') && this.customerProfileValue && this.productSubTypeValue && this.loanAmount && this.assessedIncomeProgramValue1 && this.propertyIdentifiedValue && ((this.propertyCategoryValue && this.propertyIdentifiedValue && this.propertyIdentifiedValue == 'Yes') || (this.propertyIdentifiedValue && this.propertyIdentifiedValue == 'No'))) || ((this.productValue == 'Business Loan' || this.productValue == 'Personal Loan') && this.loanAmount))) {
            let obj = {
                leadId: this.leadRecordId,
                rmSmId: this.rmNameId,
                product: this.productValue,
                productSubType: this.productSubTypeValue,
                customerProfile: this.customerProfileValue,
                loanAmount: this.loanAmount,
                isAssessedIncomePrgrm: this.isthisAssIncom,
                propertyIdentified: this.propertyIdentifiedValue,
                propertyCat: this.propertyCategoryValue
            }
            if (obj) {
                retrieveLeadROI({
                    inputData: obj
                })
                    .then(result => {
                        this.leadROI = result;
                        this.checkMadtryFieldsforEMI();
                    }).catch(error => {
                        console.error(error);
                        this.showSpinner = false;
                    })
            }
        } else {
            this.leadROI = null;
        }
    }
    //End Changes for LAK-321 

    //EMI Calculator on Lead Start
    // Function to open the EMI calculator modal
    openCalculator() {
        this.isCalculatorOpen = true;
    }

    @api openPopup() {
        // Code to open the popup
        this.isCalculatorOpen = true;
    }


    ///Enable or Disable EMI Calculator
    checkMadtryFieldsforEMI() {
        if ((this.tenure != null || this.tenure != undefined || this.tenure != '') && (this.customerProfileValue != null || this.customerProfileValue != undefined) && (this.leadROINew != null || this.leadROINew != undefined)) {
            this.enableEMICalculatorButton();
        } else {
            this.disableEMICalculatorButton();
        }
    }

    handleCloseClick() {
        // Code to close the popup
        this.dispatchEvent(new CustomEvent('close'));
    }

    ///Handle Data change LAK-46
    handleValueChange(event) {
        console.log('inside handleEventChange')
        if (event.target.name === 'declMonthInc') {
            this.declredMontlyIncVal = event.target.value;
            this.MontlyIncdeclval = this.declredMontlyIncVal
        }
        if (event.target.name === 'declMonthObl') {
            this.declredMontlyOblVal = event.target.value;
            this.MontlyObldeclval = this.declredMontlyOblVal
        }
        this.getFOIR();
    }
    //Reset Calculator LAK-46
    resetValues() {
        this.MontlyIncdeclval = null;
        this.MontlyObldeclval = null;
        this.showcalculation = false;
    }
    showcalculation = false;

    @api salExclVarPay;
    @api avgVarPay;
    @api dedInclIncomeTax;
    @api avgAddIncome;
    @api consultIncome;
    @api monthlyObl;
    @api netTakHomeSal;
    @api totalNetMonthluInc;
    @api grossRecipts;
    @api patValue;
    @api depreciation;
    @api intrstExp;
    @api OtheIcnme;
    @api monthlyObli;
    @api profQual;
    @api program;
    @api natureOfBusiness;
    @api turnover;
    @api last12MonthsTurnover;
    @api intonEMIloanAddBack;
    @api patCapital;
    @api abbValue;
    @api emiGoingFrmOthrAcnt;
    handleValueChangeNew(event) {
        // Convert input values to numbers
        const value = parseFloat(event.target.value) || 0;
    
        if (event.target.name === 'salExclVarPay') {
            this.salExclVarPay = value;
        } else if (event.target.name === 'avgVarPay') {
            this.avgVarPay = value;
        } else if (event.target.name === 'dedInclIncomeTax') {
            this.dedInclIncomeTax = value;
        } else if (event.target.name === 'avgAddIncome') {
            this.avgAddIncome = value;
        } else if (event.target.name === 'consultIncome') {
            this.consultIncome = value;
        } else if (event.target.name === 'monthlyObl') {
            this.monthlyObl = value;
        }else if (event.target.name === 'grossRecipts') {
            this.grossRecipts = value;
        }else if (event.target.name === 'pat') {
            this.patValue = value;
        }else if (event.target.name === 'depreciation') {
            this.depreciation = value;
        }else if (event.target.name === 'intrstExp') {
            this.intrstExp = value;
        }else if (event.target.name === 'OtheIcnme') {
            this.OtheIcnme = value;
        }else if (event.target.name === 'monthlyObli') {
            this.monthlyObli = value;
        }else if (event.target.name === 'profQual') {
            this.profQual = event.target.value;
        }else if (event.target.name === 'program') {
            this.program = event.target.value;
        }else if (event.target.name === 'natureOfBusiness') {
            this.natureOfBusiness = event.target.value;
        }else if (event.target.name === 'turnover') {
            this.turnover = event.target.value;
        }else if (event.target.name === 'last12MonthsTurnover') {
            this.last12MonthsTurnover = event.target.value;
        }else if (event.target.name === 'intonEMIloanAddBack') {
            this.intonEMIloanAddBack = event.target.value;
        }else if (event.target.name === 'patCapital') {
            this.patCapital = event.target.value;
        }else if (event.target.name === 'abbValue') {
            this.abbValue = event.target.value;
        }else if (event.target.name === 'emiGoingFrmOthrAcnt') {
            this.emiGoingFrmOthrAcnt = event.target.value;
        }
        // Calculate net take-home salary
        if (this.salExclVarPay || this.avgVarPay || this.dedInclIncomeTax) {
            this.netTakHomeSal = (this.salExclVarPay + this.avgVarPay - this.dedInclIncomeTax);
        }
    
        // Calculate total net monthly income
        if (this.netTakHomeSal || this.avgAddIncome || this.consultIncome) {
            this.totalNetMonthluInc = (this.netTakHomeSal + this.avgAddIncome + this.consultIncome);
        }
    }
    @track showcalculationNew = false;
    resetValuesNew() {
        this.salExclVarPay = null;
        this.avgVarPay = null;
        this.dedInclIncomeTax = null;
        this.avgAddIncome = null;
        this.consultIncome = null;
        this.monthlyObl = null;
        this.netTakHomeSal = null;
        this.totalNetMonthluInc = null;
        this.showcalculationNew = false;
    }
    @track showcalculationSEP = false;
    resetValuesSEP(){
        this.grossRecipts = null;
        this.patValue = null;
        this.depreciation = null;
        this.intrstExp = null;
        this.OtheIcnme = null;
        this.monthlyObli = null;
        this.showcalculationSEP = false;
        this.profQual = null;
    }
    @track showcalculationSEPNon = false;
    resetValuesSEPNon(){
            this.program = null;
            this.natureOfBusiness = null;
            this.turnover= null;
            this.last12MonthsTurnover= null;
            this.patValue = null;
            this.depreciation = null;    
            this.intonEMIloanAddBack = null;  
            this.patCapital = null;     
            this.monthlyObli = null;
            this.abbValue = null;
            this.emiGoingFrmOthrAcnt = null;
            this.showcalculationSEPNon = false;
    }
    //isValid = true;
    // validateForm() {
    //     this.template.querySelectorAll('lightning-input').forEach(element => {
    //         if (element.reportValidity()) {} else {
    //             this.isValid = false;
    //         }
    //     });

    //     return this.isValid;
    // }
    /// Get FOIR LAK-46
    filterRecod = [];
    getFOIR() {
        let Params = {
            ParentObjectName: 'MasterData__c',
            ChildObjectRelName: '',
            parentObjFields: ['FOIR__c', 'Assessment_program_type__c', 'CustomerProfile__c', 'Min__c', 'Max__c', 'Type__c'],
            childObjFields: [],
            queryCriteria: ' where Type__c = \'Lead FOIR\''
        }
        getSobjectData({
            params: Params
        })
            .then((result) => {
                if (result.parentRecords && result.parentRecords.length > 0) {
                    console.log('result in getFOIR method', JSON.stringify(result.parentRecords.length))
                    let filteredRecords = result.parentRecords.filter(record => {
                        return record.Assessment_program_type__c === this.assessedIncomeProgramValue1 &&
                            record.CustomerProfile__c === this.customerProfileValue &&
                            this.declredMontlyIncVal >= record.Min__c &&
                            (record.Max__c === undefined || this.declredMontlyIncVal <= record.Max__c);
                    });

                    if (filteredRecords.length > 0) {
                        this.leadFOIR = filteredRecords[0].FOIR__c;
                    }
                }
            })
            .catch((error) => {
                console.log('Error in getFOIR method', JSON.stringify(error))
            })
    }
    fields = {};
    Datafied;

    //// Function used to Calculate the EMI -LAK-46
    calculateEMI() {
        if (this.validDeclMonly()) {
            this.getFOIR();
            this.showcalculation = true;
            const numerator = ((this.leadROINew / 100) / 12 * Math.pow(1 + (this.leadROINew / 100) / 12, this.tenure));
            const denominator = Math.pow(1 + (this.leadROINew / 100) / 12, this.tenure) - 1;
            //this.EMIperLacVal = ((numerator / denominator) * Math.pow(10, 5));
            this.EMIperLac = Math.round(Number(((numerator / denominator) * Math.pow(10, 5)).toFixed(2)));
            this.EMIperLacVal = this.EMIperLac;
            //this.eligibilityinlacsVal = (((this.declredMontlyIncVal * (this.leadFOIR / 100) - this.declredMontlyOblVal) / this.EMIperLacVal));
            this.eligibilityinlacs = Math.round(Number((((this.declredMontlyIncVal * (this.leadFOIR / 100) - this.declredMontlyOblVal) / this.EMIperLac)).toFixed(2)));
            this.eligibilityinlacsVal = this.eligibilityinlacs;
            //this.emi = this.eligibilityinlacsVal*this.EMIperLacVal;
            this.emi = Math.round(Number((this.eligibilityinlacsVal * this.EMIperLacVal).toFixed(2)));

            if (this.leadRecordId) {
                this.fields = {
                    Id: this.leadRecordId,
                    DeclaredMonthlyIncome__c: this.declredMontlyIncVal,
                    DeclaredMonthlyObligation__c: this.declredMontlyOblVal,
                    EMI__c: this.emi,
                    EMI_per_Lac__c: this.EMIperLac,
                    Eligibility_in_lacs__c: this.eligibilityinlacs,
                    Lead_FOIR__c: this.leadFOIR,
                    sobjectType: 'Lead'
                }
                this.Datafied = [this.fields];
                upsertSObjectRecord({
                    params: this.Datafied
                })
                    .then((result) => {
                        console.log('upsert success')
                    })
                    .catch((error) => {
                        console.log('Error In creating Record', error);
                    });
            }
        } else {
            this.showToastMessage('Error', 'Please fill required fields', 'error', 'sticky');
        }
    }
    //EMI Calculator on Lead End

    @track showSpinnerNew = false;
    @api applicableFOIR;
    @api maxEligibleEMI;
    @api maxLoanBasisFOIR;
    @api maxLoanBasisNMIBand;
    @api maxLoanEligibility;
    @track emiNew;
    calculateEMINew() {
        if (this.validEmiFields()) {
            this.showSpinnerNew = true;
            let inputdataNew = {
                leadId: this.leadRecordId ? this.leadRecordId : '',
                loanAmount: this.loanAmount ? this.loanAmount : 0.00,
                loanTenure: this.tenure ? this.tenure : 0,
                leadROI: this.leadROI ? this.leadROI : 0.00,
                totalNetMonthlyIncome: this.totalNetMonthluInc ? this.totalNetMonthluInc : 0.00,
                monthlyObligations: this.monthlyObl ? this.monthlyObl : 0.00,
                salaryExclVarPay: this.salExclVarPay ? this.salExclVarPay : 0.00,
                avgVarPay: this.avgVarPay ? this.avgVarPay : 0.00,
                dedInclIncmeTax: this.dedInclIncomeTax ? this.dedInclIncomeTax : 0.00,
                netTakeHomeSalery: this.netTakHomeSal ? this.netTakHomeSal : 0.00,
                avgAdditionalIncome: this.avgAddIncome ? this.avgAddIncome : 0.00,
                consuIncme: this.consultIncome ? this.consultIncome : 0.00
            }
            if (inputdataNew) {
                getLeadEmiData({
                    inputdata: inputdataNew
                })
                    .then((result) => {
                        this.showSpinnerNew = false;
                        this.showcalculationNew = true;
                        this.applicableFOIR = result.applicableFOIR ? (result.applicableFOIR*100) : 0;
                        this.maxEligibleEMI = result.maxEligibleEmi ? result.maxEligibleEmi : 0;
                        this.maxLoanBasisFOIR = result.maxLoanBasisFOIR ? result.maxLoanBasisFOIR : 0;
                        this.maxLoanBasisNMIBand = result.maxLoanBasisNMIBand ? result.maxLoanBasisNMIBand : 0;
                        this.maxLoanEligibility = result.maxLoanEligibility ? result.maxLoanEligibility : 0;
                        this.emiNew =  result.emi ? result.emi : 0;
                        console.log('upsert success', result);
                    })
                    .catch((error) => {
                        this.showSpinnerNew = false;
                        console.log('Error In updatin EMI ', error);
                    });
            }
        } else {
            this.showToastMessage('Error', 'Please fill required fields', 'error', 'sticky');
        }
    }

    validEmiSEPFields() {
        let isValid = true;
        // Get references to the input fields
        let grossReciptsInput = this.template.querySelector('.grossRecipts');
        let patValueInput = this.template.querySelector('.pat');
        let depreciationInput = this.template.querySelector('.depreciation');
        let intrstExpInput = this.template.querySelector('.intrstExp');
        let OtheIcnmeInput = this.template.querySelector('.OtheIcnme');
        let monthlyObliInput = this.template.querySelector('.monthlyObli');
        let profQualInput = this.template.querySelector('.profQual');
        // Check validity of both input fields
        if (!grossReciptsInput.checkValidity()) {
            grossReciptsInput.reportValidity();
            isValid = false;
        }
        if (!patValueInput.checkValidity()) {
            patValueInput.reportValidity();
            isValid = false;
        }
        if (!depreciationInput.checkValidity()) {
            depreciationInput.reportValidity();
            isValid = false;
        }
        if (!intrstExpInput.checkValidity()) {
            intrstExpInput.reportValidity();
            isValid = false;
        }
        if (!OtheIcnmeInput.checkValidity()) {
            OtheIcnmeInput.reportValidity();
            isValid = false;
        }
        if (!monthlyObliInput.checkValidity()) {
            monthlyObliInput.reportValidity();
            isValid = false;
        }
        if (!profQualInput.checkValidity()) {
            profQualInput.reportValidity();
            isValid = false;
        }
        // If both fields are valid, update the values
        if (isValid) {
            this.grossRecipts = grossReciptsInput.value;
            this.patValue = patValueInput.value;
            this.depreciation = depreciationInput.value;
            this.intrstExp = intrstExpInput.value;
            this.OtheIcnme = OtheIcnmeInput.value;
            this.monthlyObli = monthlyObliInput.value;
            this.profQual = profQualInput.value;
        }

        return isValid;
    }
    @track showSpinnerSEP = false;
    @api netProfit;
    @api grossProfReceipts;
    @track emiSEP;
    calculateEMISEP() {
        if (this.validEmiSEPFields()) {
            this.showSpinnerSEP = true;
            let inputdataNew = {
                leadId: this.leadRecordId ? this.leadRecordId : '',
                loanAmount: this.loanAmount ? this.loanAmount : 0.00,
                loanTenure: this.tenure ? this.tenure : 0,
                leadROI: this.leadROI ? this.leadROI : 0.00,
                grossRecipts: this.grossRecipts ? this.grossRecipts : 0.00,
                patValue: this.patValue ? this.patValue : 0.00,
                depreciation: this.depreciation ? this.depreciation : 0.00,
                intrstExp: this.intrstExp ? this.intrstExp : 0.00,
                OtheIcnme: this.OtheIcnme ? this.OtheIcnme : 0.00,
                monthlyObli: this.monthlyObli ? this.monthlyObli : 0.00,
                qualificationValue: this.profQual ? this.profQual : ''
            }
            if (inputdataNew) {
                getLeadSepEmiData({
                    inputdata: inputdataNew
                })
                    .then((result) => {
                        this.showSpinnerSEP = false;
                        this.showcalculationSEP = true;
                        this.netProfit = result.netProfit ? result.netProfit : 0;
                        this.grossProfReceipts = result.grossProfReceipts ? result.grossProfReceipts : 0;
                        this.emiSEP =  result.emi ? result.emi : 0;
                        console.log('upsert success', result);
                    })
                    .catch((error) => {
                        this.showSpinnerSEP = false;
                        console.log('Error In updatin EMI ', error);
                    });
            }
        } else {
            this.showToastMessage('Error', 'Please fill required fields', 'error', 'sticky');
        }
    }
    
    validEmiSEPNonFields() {
        let isValid = true;
        // Get references to the input fields
        let programInput = this.template.querySelector('.program');
        let natureOfBusinessInput = this.template.querySelector('.natureOfBusiness');
        let turnoverInput = this.template.querySelector('.turnover');
        let last12MonthsTurnoverInput = this.template.querySelector('.last12MonthsTurnover');
        let patValueInput = this.template.querySelector('.pat');
        let depreciationInput = this.template.querySelector('.depreciation');
        let intonEMIloanAddBackInput = this.template.querySelector('.intonEMIloanAddBack');
        let patCapitalInput = this.template.querySelector('.patCapital');
        let monthlyObliInput = this.template.querySelector('.monthlyObli');
        let abbValueInput = this.template.querySelector('.abbValue');
        let emiGoingFrmOthrAcntInput = this.template.querySelector('.emiGoingFrmOthrAcnt');
        // Check validity of both input fields
        if (!programInput.checkValidity()) {
            programInput.reportValidity();
            isValid = false;
        }
        if (!patValueInput.checkValidity()) {
            patValueInput.reportValidity();
            isValid = false;
        }
        if (!natureOfBusinessInput.checkValidity()) {
            natureOfBusinessInput.reportValidity();
            isValid = false;
        }
        if (!turnoverInput.checkValidity()) {
            turnoverInput.reportValidity();
            isValid = false;
        }
        if (!last12MonthsTurnoverInput.checkValidity()) {
            last12MonthsTurnoverInput.reportValidity();
            isValid = false;
        }
        if (!intonEMIloanAddBackInput.checkValidity()) {
            intonEMIloanAddBackInput.reportValidity();
            isValid = false;
        }
        if (!monthlyObliInput.checkValidity()) {
            monthlyObliInput.reportValidity();
            isValid = false;
        }
        if (!patCapitalInput.checkValidity()) {
            patCapitalInput.reportValidity();
            isValid = false;
        }
        if (!abbValueInput.checkValidity()) {
            abbValueInput.reportValidity();
            isValid = false;
        }
        if (!emiGoingFrmOthrAcntInput.checkValidity()) {
            emiGoingFrmOthrAcntInput.reportValidity();
            isValid = false;
        }
        if (!depreciationInput.checkValidity()) {
            depreciationInput.reportValidity();
            isValid = false;
        }
        // If both fields are valid, update the values
        if (isValid) {
            this.program = programInput.value;
            this.patValue = patValueInput.value;
            this.natureOfBusiness = natureOfBusinessInput.value;
            this.turnover = turnoverInput.value;
            this.last12MonthsTurnover = last12MonthsTurnoverInput.value;
            this.intonEMIloanAddBack = intonEMIloanAddBackInput.value;
            this.monthlyObli = monthlyObliInput.value;
            this.patCapital = patCapitalInput.value;
            this.abbValue = abbValueInput.value;
            this.emiGoingFrmOthrAcnt = emiGoingFrmOthrAcntInput.value;
            this.depreciation = depreciationInput.value;
        }

        return isValid;
    }
    @api eligibility;
    @api emiSEPNon;
    @track showSpinnerSEPNon = false;
    calculateEMISEPNon(){
        if (this.validEmiSEPNonFields()) {
            this.showSpinnerSEPNon = true;
            let inputdataNew = {
                leadId: this.leadRecordId ? this.leadRecordId : '',
                loanAmount: this.loanAmount ? this.loanAmount : 0.00,
                loanTenure: this.tenure ? this.tenure : 0,
                leadROI: this.leadROI ? this.leadROI : 0.00,
                last12MonthsTurnover: this.last12MonthsTurnover ? this.last12MonthsTurnover : 0.00,
                patValue: this.patValue ? this.patValue : 0.00,
                depreciation: this.depreciation ? this.depreciation : 0.00,
                turnover: this.turnover ? this.turnover : 0.00,
                intonEMIloanAddBack: this.intonEMIloanAddBack ? this.intonEMIloanAddBack : 0.00,
                monthlyObli: this.monthlyObli ? this.monthlyObli : 0.00,
                patCapital: this.patCapital ? this.patCapital : 0.00,
                abbValue: this.abbValue ? this.abbValue : 0.00,
                emiGoingFrmOthrAcnt: this.emiGoingFrmOthrAcnt ? this.emiGoingFrmOthrAcnt : 0.00,
                program: this.program ? this.program : '',
                natureOfBusiness: this.natureOfBusiness ? this.natureOfBusiness : ''
            }

            if (inputdataNew) {
                getLeadSeNonpEmiData({
                    inputdata: inputdataNew
                })
                    .then((result) => {
                        this.showSpinnerSEPNon = false;
                        this.showcalculationSEPNon = true;
                        this.eligibility = result.eligibility ? result.eligibility : 0;
                        this.emiSEPNon =  result.emi ? result.emi : 0;
                        console.log('upsert success', result);
                    })
                    .catch((error) => {
                        this.showSpinnerSEPNon = false;
                        console.log('Error In updatin EMI ', error);
                    });
            }
        } else {
            this.showToastMessage('Error', 'Please fill required fields', 'error', 'sticky');
        }
    }
}