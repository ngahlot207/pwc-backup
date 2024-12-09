import { LightningElement, wire , api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {subscribe, publish, MessageContext, APPLICATION_SCOPE} from 'lightning/messageService';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import {getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import { createRecord,updateRecord } from "lightning/uiRecordApi";

import getData from '@salesforce/apex/DataSearchClass.getData';

import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';
import ApplicantEmployment_OBJECT from '@salesforce/schema/ApplicantEmployment__c';

import CUSTOMER_PROFILE_FIELD from '@salesforce/schema/Applicant__c.CustProfile__c';
import CONSTITUTION_FIELD from '@salesforce/schema/Applicant__c.Constitution__c';

import ORGANISATION_TYPE_FIELD from '@salesforce/schema/ApplicantEmployment__c.TypeOfOrganisation__c';
import BUSINESS_NATURE_CORPORATE_FIELD from '@salesforce/schema/ApplicantEmployment__c.NatureOfBusinessCorporate__c';
import BUSINESS_NATURE_INDIVIDUAL_FIELD from '@salesforce/schema/ApplicantEmployment__c.NatureOfBusinessIndividual__c';
import DESIGNATION_VALUES_FIELD from '@salesforce/schema/ApplicantEmployment__c.DesignationValues__c';

import CURRENTBUSINESSVINTAGE_MONTHS_FIELD from  '@salesforce/schema/ApplicantEmployment__c.CurrentBusinessVintage_Months__c';
import CURRENTBUSINESSVINTAGE_YEARS_FIELD from  '@salesforce/schema/ApplicantEmployment__c.CurrentBusinessVintage_Years__c';
import LOANAPPLICANT_FIELD from '@salesforce/schema/ApplicantEmployment__c.LoanApplicant__c';
import EMPLOYERNAME_FIELD from '@salesforce/schema/ApplicantEmployment__c.EmployerName__c';
import DESIGNATIONTEXT_FIELD from '@salesforce/schema/ApplicantEmployment__c.DesignationText__c';
import OFFICIALEMAIL_FIELD from '@salesforce/schema/ApplicantEmployment__c.OfficialEmail__c';
import WORKINGWITHCURRENTEMPLOYER_YEARS_FIELD from '@salesforce/schema/ApplicantEmployment__c.WorkingWithCurrentEmployer_Years__c';
import WORKINGWITHCURRENTEMPLOYER_MONTHS_FIELD from '@salesforce/schema/ApplicantEmployment__c.WorkingWithCurrentEmployer_Months__c';
import TOTALWORKEXPERIENCE_YEARS_FIELD from '@salesforce/schema/ApplicantEmployment__c.TotalWorkExperience_Years__c';
import TOTALWORKEXPERIENCE_MONTHS_FIELD from '@salesforce/schema/ApplicantEmployment__c.TotalWorkExperience_Months__c';
import RETIREMENTAGE_FIELD from '@salesforce/schema/ApplicantEmployment__c.RetirementAge__c';
import NATUREOFBUSINESSINDIVIDUAL_FIELD from '@salesforce/schema/ApplicantEmployment__c.NatureOfBusinessIndividual__c';
import NATUREOFBUSINESSCORPORATE_FIELD from '@salesforce/schema/ApplicantEmployment__c.NatureOfBusinessCorporate__c';
import INDUSTRYTYPE_FIELD from '@salesforce/schema/ApplicantEmployment__c.IndustryType__c';
import SUBINDUSTRY_FIELD from '@salesforce/schema/ApplicantEmployment__c.SubIndustry__c';
import INDUSTRYFORRBIREPORTING_FIELD from '@salesforce/schema/ApplicantEmployment__c.IndustryForRBIReporting__c';
import UDYAMREGISTRATIONNUMBER_FIELD from '@salesforce/schema/ApplicantEmployment__c.UdyamRegistrationNumber__c';
import DATEOFUDYAMREGISTRATION_FIELD from '@salesforce/schema/ApplicantEmployment__c.DateOfUdyamRegistration__c';
import TYPEOFENTERPRISE_URC_FIELD from '@salesforce/schema/ApplicantEmployment__c.TypeOfEnterprise_URC__c';
import INDUSTRY_URC_FIELD from '@salesforce/schema/ApplicantEmployment__c.Industry_URC__c';
import SUBSECTOR_URC_FIELD from '@salesforce/schema/ApplicantEmployment__c.SubSector_URC__c';
import ACTIVITY_URC_FIELD from '@salesforce/schema/ApplicantEmployment__c.Activity_URC__c';
import ACTIVITYDESCRIPTION_URC_FIELD from '@salesforce/schema/ApplicantEmployment__c.ActivityDescription_URC__c';
import GST_REGISTERED_FIELD from '@salesforce/schema/ApplicantEmployment__c.GST_Registered__c';
import GSTIN_FIELD from '@salesforce/schema/ApplicantEmployment__c.GSTIN__c';
import GSTIN_STATUS_FIELD from '@salesforce/schema/ApplicantEmployment__c.GSTIN_Status__c';
import REGISTEREDADDRESS_GST_FIELD from '@salesforce/schema/ApplicantEmployment__c.RegisteredAddress_GST__c';
import LEGALNAMEOFBUSINESS_GST_CERTIFICATE_FIELD from '@salesforce/schema/ApplicantEmployment__c.LegalNameOfBusiness_GST_Certificate__c';
import TRADENAME_GST_CERTIFICATE_FIELD from '@salesforce/schema/ApplicantEmployment__c.TradeName_GST_Certificate__c';
import MAIN_GSTIN_FIELD from '@salesforce/schema/ApplicantEmployment__c.Main_GSTIN__c';
import ENTITYNAME_FIELD from '@salesforce/schema/ApplicantEmployment__c.EntityName__c';
import SHARE_HOLDING_ENTITY_FIELD from '@salesforce/schema/ApplicantEmployment__c.ShareholdingInTheEntity__c';
import NIC_URC_FIELD from '@salesforce/schema/ApplicantEmployment__c.NIC_URC__c';

const applicantfields = [CUSTOMER_PROFILE_FIELD,CONSTITUTION_FIELD];
const applicantEmploymentfields = [ACTIVITY_URC_FIELD,ACTIVITYDESCRIPTION_URC_FIELD,BUSINESS_NATURE_CORPORATE_FIELD,BUSINESS_NATURE_INDIVIDUAL_FIELD,CURRENTBUSINESSVINTAGE_MONTHS_FIELD,CURRENTBUSINESSVINTAGE_YEARS_FIELD,DATEOFUDYAMREGISTRATION_FIELD,DESIGNATION_VALUES_FIELD,DESIGNATIONTEXT_FIELD,ENTITYNAME_FIELD,EMPLOYERNAME_FIELD,GST_REGISTERED_FIELD,GSTIN_FIELD,GSTIN_STATUS_FIELD,INDUSTRY_URC_FIELD,INDUSTRYFORRBIREPORTING_FIELD,INDUSTRYTYPE_FIELD,LEGALNAMEOFBUSINESS_GST_CERTIFICATE_FIELD,MAIN_GSTIN_FIELD,NATUREOFBUSINESSCORPORATE_FIELD,NATUREOFBUSINESSINDIVIDUAL_FIELD,OFFICIALEMAIL_FIELD,ORGANISATION_TYPE_FIELD,REGISTEREDADDRESS_GST_FIELD,RETIREMENTAGE_FIELD,SUBINDUSTRY_FIELD,SUBSECTOR_URC_FIELD,TOTALWORKEXPERIENCE_MONTHS_FIELD,TOTALWORKEXPERIENCE_YEARS_FIELD,TRADENAME_GST_CERTIFICATE_FIELD,TYPEOFENTERPRISE_URC_FIELD,UDYAMREGISTRATIONNUMBER_FIELD,WORKINGWITHCURRENTEMPLOYER_MONTHS_FIELD,WORKINGWITHCURRENTEMPLOYER_YEARS_FIELD,SHARE_HOLDING_ENTITY_FIELD,NIC_URC_FIELD];

export default class TestcaptureEmpDetails extends LightningElement {
    @api recordId='a0SC40000005E7B';//3='a0SC40000005E8nMAE';
    @api isReadOnly;
    @api applicantId='a0AC4000000Eqd4MAC';//3='a0AC4000000EVgfMAG';//2='a0AC4000000EoOLMA0';
    @api loanAppId;
    
    employersPicklistOptions;
    industriesPicklistOptions;
    subIndustriesPicklistOptions;
    industryRBIReportingOptions;
    @track selectedIndustryValue;
    @track selectedSubIndustryValue;
    @track selectedindustryRBIReportingValue;
    customerProfileOptions=[];
    organisationTypeOptions=[];
    businessNatureCorporateOptions=[];
    businessNatureIndividualOptions=[];
    designationOptions=[];
    otherEmployerOption;

    @wire(MessageContext)
    MessageContext;

    results={applicant:{},loanApplication:{},applicantEmployment:{WorkingWithCurrentEmployer_Years__c:'',WorkingWithCurrentEmployer_Months__c:'',TotalWorkExperience_Years__c:'',TotalWorkExperience_Months__c:'',CurrentBusinessVintage_Years__c:'',CurrentBusinessVintage_Months__c:''}};

    displayLayout;
    //displayGSTLayout;
    isSalaried;
    isSelfEmployedProfessional;
    isSelfEmployedNonProfessional;
    isIndividualSelfEmployed;
    isNotOtherIndividual;
    isIndividualConstituiton;
    isNonIndividualSelfEmployed;
    @track displayOthersOption;
   
    //this.displayGSTLayout=((this.isGSTRegistered) && ((this.results.applicant.CustProfile__c==='SELF EMPLOYED PROFESSIONAL'|| this.results.applicant.CustProfile__c==='SELF EMPLOYED NON PROFESSIONAL') && this.results.applicant.Constitution__c!='INDIVIDUAL' ) )?true:false;
    
    connectedCallback() {
        
        console.log('EmploymentDetails>>>>>>recordId:',this.recordId,'>>>applicantId:',this.applicantId,'>>>loanAppld:',this.loanAppld,'>>>isReadOnly',this.isReadOnly);
        this.getEmployersPicklistValues();
        this.getIndustriesPicklistValues();
        this.sunscribeToMessageChannel();
        
    }
    sunscribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );

    }
    handleSaveThroughLms(values) {
        console.log('values to save through Lms ', JSON.stringify(values));
        if(values.recordId===this.loanAppId ){
            this.handleSave(values.validateBeforeSave);
        }
        
    }


    // getApplicantDetials(){
    //     getApplicant({applicantId: this.applicantId})
    //     .then(result => {
    //         this.results.applicant=result;
    //         this.header=this.results.applicant.CustProfile__c;
    //         console.log('::::::',JSON.stringify(this.data));
    //     })
    // }

    @wire(getRecord, { recordId : '$applicantId', fields: applicantfields})
    applicantDetailsHandler({data,error}){
        if(data){        
            this.results.applicant.CustProfile__c=data.fields.CustProfile__c.value ? data.fields.CustProfile__c.value: '';
            this.results.applicant.Constitution__c=data.fields.Constitution__c.value ? data.fields.Constitution__c.value: '';
            console.log('applicantDetails::::::::',JSON.stringify(this.results));

            this.isSalaried=(this.results.applicant.CustProfile__c==='SALARIED' && this.results.applicant.Constitution__c==='INDIVIDUAL')?true:false;
            this.isSelfEmployedProfessional=(this.results.applicant.CustProfile__c==='SELF EMPLOYED PROFESSIONAL')?true:false;
            this.isSelfEmployedNonProfessional=(this.results.applicant.CustProfile__c==='SELF EMPLOYED NON PROFESSIONAL')?true:false;
            this.isIndividualSelfEmployed=((this.results.applicant.CustProfile__c==='SELF EMPLOYED PROFESSIONAL'|| this.results.applicant.CustProfile__c==='SELF EMPLOYED NON PROFESSIONAL') && this.results.applicant.Constitution__c==='INDIVIDUAL' )?true:false;
            this.isNotOtherIndividual=(this.results.applicant.CustProfile__c!='OTHERS' && this.results.applicant.Constitution__c==='INDIVIDUAL' )?true:false;
            this.isIndividualConstituiton=this.results.applicant.Constitution__c==='INDIVIDUAL'?true:false;
            this.isNonIndividualSelfEmployed=((this.results.applicant.CustProfile__c==='SELF EMPLOYED PROFESSIONAL'|| this.results.applicant.CustProfile__c==='SELF EMPLOYED NON PROFESSIONAL') && this.results.applicant.Constitution__c!='INDIVIDUAL' )?true:false;
            this.displayLayout=(this.results.applicant.CustProfile__c==='SALARIED' || this.results.applicant.CustProfile__c==='SELF EMPLOYED PROFESSIONAL' || this.results.applicant.CustProfile__c==='SELF EMPLOYED NON PROFESSIONAL')?true:false;

            this.error = undefined;
        }else if(error){
            this.error = error;
            console.log('applicantDetailsError::::::::',error)
        }
    }
    
    @wire(getRecord, { recordId : '$recordId', fields: applicantEmploymentfields})
    applicantEmploymentDetailsHandler({data,error}){
        if(data){        
            console.log('applicantEmploymentDetails::::::::',JSON.stringify(data));
            this.results.applicantEmployment.Activity_URC__c=data.fields.Activity_URC__c.value?data.fields.Activity_URC__c.value:'';
            this.results.applicantEmployment.ActivityDescription_URC__c=data.fields.ActivityDescription_URC__c.value?data.fields.ActivityDescription_URC__c.value:'';
            this.results.applicantEmployment.DateOfUdyamRegistration__c=data.fields.DateOfUdyamRegistration__c.value?data.fields.DateOfUdyamRegistration__c.value:'';
            this.results.applicantEmployment.DesignationText__c=data.fields.DesignationText__c.value?data.fields.DesignationText__c.value:'';
            this.results.applicantEmployment.DesignationValues__c=data.fields.DesignationValues__c.value?data.fields.DesignationValues__c.value:'';
            this.results.applicantEmployment.EmployerName__c=data.fields.EmployerName__c.value?data.fields.EmployerName__c.value:'';
            this.results.applicantEmployment.GST_Registered__c=data.fields.GST_Registered__c.value?data.fields.GST_Registered__c.value:'';
            this.results.applicantEmployment.GSTIN__c=data.fields.GSTIN__c.value?data.fields.GSTIN__c.value:'';
            this.results.applicantEmployment.GSTIN_Status__c=data.fields.GSTIN_Status__c.value?data.fields.GSTIN_Status__c.value:'';
            this.results.applicantEmployment.Industry_URC__c=data.fields.Industry_URC__c.value?data.fields.Industry_URC__c.value:'';
            this.results.applicantEmployment.IndustryForRBIReporting__c=data.fields.IndustryForRBIReporting__c.value?data.fields.IndustryForRBIReporting__c.value:'';
            this.results.applicantEmployment.IndustryType__c=data.fields.IndustryType__c.value?data.fields.IndustryType__c.value:'';
            this.results.applicantEmployment.LegalNameOfBusiness_GST_Certificate__c=data.fields.LegalNameOfBusiness_GST_Certificate__c.value?data.fields.LegalNameOfBusiness_GST_Certificate__c.value:'';
            this.results.applicantEmployment.Main_GSTIN__c=data.fields.Main_GSTIN__c.value?data.fields.Main_GSTIN__c.value:'';
            this.results.applicantEmployment.NatureOfBusinessCorporate__c=data.fields.NatureOfBusinessCorporate__c.value?data.fields.NatureOfBusinessCorporate__c.value:'';
            this.results.applicantEmployment.NatureOfBusinessCorporate__c=data.fields.NatureOfBusinessCorporate__c.value?data.fields.NatureOfBusinessCorporate__c.value:'';
            this.results.applicantEmployment.NatureOfBusinessIndividual__c=data.fields.NatureOfBusinessIndividual__c.value?data.fields.NatureOfBusinessIndividual__c.value:'';
            this.results.applicantEmployment.NatureOfBusinessIndividual__c=data.fields.NatureOfBusinessIndividual__c.value?data.fields.NatureOfBusinessIndividual__c.value:'';
            this.results.applicantEmployment.OfficialEmail__c=data.fields.OfficialEmail__c.value?data.fields.OfficialEmail__c.value:'';
            this.results.applicantEmployment.RegisteredAddress_GST__c=data.fields.RegisteredAddress_GST__c.value?data.fields.RegisteredAddress_GST__c.value:'';
            this.results.applicantEmployment.RetirementAge__c=data.fields.RetirementAge__c.value?data.fields.RetirementAge__c.value:'';
            this.results.applicantEmployment.SubIndustry__c=data.fields.SubIndustry__c.value?data.fields.SubIndustry__c.value:'';
            this.results.applicantEmployment.SubSector_URC__c=data.fields.SubSector_URC__c.value?data.fields.SubSector_URC__c.value:'';
            this.results.applicantEmployment.TotalWorkExperience_Months__c=data.fields.TotalWorkExperience_Months__c.value!=null?data.fields.TotalWorkExperience_Months__c.value.toString().padStart(2, '0'):'';
            this.results.applicantEmployment.TotalWorkExperience_Years__c=data.fields.TotalWorkExperience_Years__c.value!=null?data.fields.TotalWorkExperience_Years__c.value.toString().padStart(2, '0'):'';
            this.results.applicantEmployment.TradeName_GST_Certificate__c=data.fields.TradeName_GST_Certificate__c.value?data.fields.TradeName_GST_Certificate__c.value:'';
            this.results.applicantEmployment.TypeOfEnterprise_URC__c=data.fields.TypeOfEnterprise_URC__c.value?data.fields.TypeOfEnterprise_URC__c.value:'';
            this.results.applicantEmployment.TypeOfOrganisation__c=data.fields.TypeOfOrganisation__c.value?data.fields.TypeOfOrganisation__c.value:'';
            this.results.applicantEmployment.UdyamRegistrationNumber__c=data.fields.UdyamRegistrationNumber__c.value?data.fields.UdyamRegistrationNumber__c.value:'';
            this.results.applicantEmployment.WorkingWithCurrentEmployer_Months__c=data.fields.WorkingWithCurrentEmployer_Months__c.value!=null?data.fields.WorkingWithCurrentEmployer_Months__c.value.toString().padStart(2, '0'):'';
            this.results.applicantEmployment.WorkingWithCurrentEmployer_Years__c=data.fields.WorkingWithCurrentEmployer_Years__c.value!=null?data.fields.WorkingWithCurrentEmployer_Years__c.value.toString().padStart(2, '0'):'';
            this.results.applicantEmployment.CurrentBusinessVintage_Months__c=data.fields.CurrentBusinessVintage_Months__c.value!=null?data.fields.CurrentBusinessVintage_Months__c.value.toString().padStart(2, '0'):'';
            this.results.applicantEmployment.CurrentBusinessVintage_Years__c=data.fields.CurrentBusinessVintage_Years__c.value!=null?data.fields.CurrentBusinessVintage_Years__c.value.toString().padStart(2, '0'):'';
            this.results.applicantEmployment.EntityName__c=data.fields.EntityName__c.value?data.fields.EntityName__c.value:'';
            this.results.applicantEmployment.ShareholdingInTheEntity__c=data.fields.ShareholdingInTheEntity__c.value!=null?data.fields.ShareholdingInTheEntity__c.value.toString():'';
            this.results.applicantEmployment.NIC_URC__c=data.fields.NIC_URC__c.value?data.fields.NIC_URC__c.value:'';
            
            this.GSTRegistered=data.fields.GST_Registered__c.value?data.fields.GST_Registered__c.value:'';
            this.isGSTRegistered=this.GSTRegistered==='Yes'?true:false;
            this.selectedIndustryValue=data.fields.IndustryType__c.value?data.fields.IndustryType__c.value:'';
            if(this.selectedIndustryValue!=''){this.getSubIndustriesPicklistValues();}
            this.selectedSubIndustryValue=data.fields.SubIndustry__c.value?data.fields.SubIndustry__c.value:'';
            if(this.selectedIndustryValue!='' && this.selectedSubIndustryValue!=''){
                this.getRBIReportingIndustryPicklistValues();
                this.selectedindustryRBIReportingValue=data.fields.IndustryForRBIReporting__c.value?data.fields.IndustryForRBIReporting__c.value:'';
            }
            
            console.log('Results::::::::',JSON.stringify(this.results));
            this.error = undefined;
        }else if(error){
            this.error = error;
            console.log('applicantEmploymentError::::::::',error)
        }
    }

    get displayGSTLayout(){
        return ((this.isGSTRegistered) && ((this.results.applicant.CustProfile__c==='SELF EMPLOYED PROFESSIONAL'|| this.results.applicant.CustProfile__c==='SELF EMPLOYED NON PROFESSIONAL') && this.results.applicant.Constitution__c!='INDIVIDUAL' ) )?true:false;
    }

    // get displayLayout(){
    //     return (this.results.applicant.CustProfile__c==='SALARIED' || this.results.applicant.CustProfile__c==='SELF EMPLOYED PROFESSIONAL' || this.results.applicant.CustProfile__c==='SELF EMPLOYED NON PROFESSIONAL')?true:false;
    // }
    // get isSalaried(){
    //     return (this.results.applicant.CustProfile__c==='SALARIED' && this.results.applicant.Constitution__c==='INDIVIDUAL')?true:false
    // }
    // get isSelfEmployedProfessional(){
    //     return (this.results.applicant.CustProfile__c==='SELF EMPLOYED PROFESSIONAL')?true:false
    // }
    // get isSelfEmployedNonProfessional(){
    //     return (this.results.applicant.CustProfile__c==='SELF EMPLOYED NON PROFESSIONAL')?true:false
    // }
    // get isIndividualSelfEmployed(){
    //     return ((this.results.applicant.CustProfile__c==='SELF EMPLOYED PROFESSIONAL'|| this.results.applicant.CustProfile__c==='SELF EMPLOYED NON PROFESSIONAL') && this.results.applicant.Constitution__c==='INDIVIDUAL' )?true:false
    // }
    // get isNotOtherIndividual(){
    //     return (this.results.applicant.CustProfile__c!='OTHERS' && this.results.applicant.Constitution__c==='INDIVIDUAL' )?true:false
    // }
    // get isIndividualConstituiton(){
    //     return this.results.applicant.Constitution__c==='INDIVIDUAL'?true:false;
    // } 
    // get isNonIndividualSelfEmployed(){
    //     return ((this.results.applicant.CustProfile__c==='SELF EMPLOYED PROFESSIONAL'|| this.results.applicant.CustProfile__c==='SELF EMPLOYED NON PROFESSIONAL') && this.results.applicant.Constitution__c!='INDIVIDUAL' )?true:false
    // }

    generatePicklist(data){
        return data.values.map(item =>({ label: item.label, value: item.value }))
    }

    @wire(getObjectInfo,{objectApiName:APPLICANT_OBJECT})
    objInfo

    @wire(getPicklistValues,{recordTypeId : '$objInfo.data.defaultRecordTypeId', fieldApiName : CUSTOMER_PROFILE_FIELD})
    customerProfilePicklistHandler({data,error}){
        if(data){
            this.customerProfileOptions = [...this.generatePicklist(data)]
        }
        if(error){
            console.log(error)
        }
    }

    @wire(getObjectInfo,{objectApiName:ApplicantEmployment_OBJECT})
    ApplicantEmploymentobjInfo
    
    @wire(getPicklistValues,{recordTypeId : '$ApplicantEmploymentobjInfo.data.defaultRecordTypeId', fieldApiName : ORGANISATION_TYPE_FIELD})
    organisationTypePicklistHandler({data,error}){
        if(data){
            this.organisationTypeOptions = [...this.generatePicklist(data)]
        }
        if(error){
            console.log(error)
        }
    }
    
    @wire(getPicklistValues,{recordTypeId : '$ApplicantEmploymentobjInfo.data.defaultRecordTypeId', fieldApiName : BUSINESS_NATURE_CORPORATE_FIELD})
    businessNatureCorporatePicklistHandler({data,error}){
        if(data){
            this.businessNatureCorporateOptions = [...this.generatePicklist(data)]
        }
        if(error){
            console.log(error)
        }
    }
    
    @wire(getPicklistValues,{recordTypeId : '$ApplicantEmploymentobjInfo.data.defaultRecordTypeId', fieldApiName : BUSINESS_NATURE_INDIVIDUAL_FIELD})
    businessNatureIndividualPicklistHandler({data,error}){
        if(data){
            this.businessNatureIndividualOptions = [...this.generatePicklist(data)]
        }
        if(error){
            console.log(error)
        }
    }

    @wire(getPicklistValues,{recordTypeId : '$ApplicantEmploymentobjInfo.data.defaultRecordTypeId', fieldApiName : DESIGNATION_VALUES_FIELD})
    designationPicklistHandler({data,error}){
        if(data){
            this.designationOptions = [...this.generatePicklist(data)]
        }
        if(error){
            console.log(error)
        }
    }

    getEmployersPicklistValues(){
        // getEmployersPicklist()
        getData({fields:"Name",objectName:"Employer__c",inputField:'',likeFilter:'',field1:'', filter1:'',field2:'', filter2:''})
        .then(result => {
            console.log('EmployersPicklistValues',result);
            this.employersPicklistOptions = result.map((record)=>({label: record.Name, value: record.Id})); 
            this.otherEmployerOption= result.find(item => item.Name === "OTHER");

            this.displayOthersOption = this.results.applicantEmployment.EmployerName__c===this.otherEmployerOption.Id?true:false;
        })

    }
    


    getIndustriesPicklistValues(){
        //getIndustriesPicklist()
        getData({fields:"Name",objectName:"Industry__c",inputField:'',likeFilter:'',field1:'', filter1:'',field2:'', filter2:''})
        .then(result => {
            this.industriesPicklistOptions = result.map((record)=>({label: record.Name, value: record.Id}));
        })
    }
   
    getSubIndustriesPicklistValues(){
        //getSubIndustriesPicklist({industryId: this.selectedIndustryValue})
        getData({fields:"Name",objectName:"SubIndustry__c",inputField:'',likeFilter:'',field1:'Industry__c', filter1:this.selectedIndustryValue,field2:'', filter2:''})
        .then(result => {
            this.subIndustriesPicklistOptions = result.map((record)=>({label: record.Name, value: record.Id}));
        })
    };


    getRBIReportingIndustryPicklistValues(){
        console.log('Industry:',this.selectedIndustryValue,'SubIndustry',this.selectedSubIndustryValue);
        //getRBIReportingIndustry({industryId: this.selectedIndustryValue, subIndustryId: this.selectedSubIndustryValue})
        getData({fields:"Name",objectName:"RBI_ReportingIndustry__c",inputField:'',likeFilter:'',field1:'Industry__c', filter1:this.selectedIndustryValue,field2:'SubIndustry__c', filter2:this.selectedSubIndustryValue})
        .then(result => {
            this.industryRBIReportingOptions = result.map((record)=>({label: record.Name, value: record.Id}));
            this.selectedindustryRBIReportingValue=this.industryRBIReportingOptions[0].value;
            this.results.applicantEmployment.IndustryForRBIReporting__c=this.industryRBIReportingOptions[0].value;
            
        })
    };

    get subIndustriesFilterCondition(){
        return 'Industry__c='+"'"+ this.selectedIndustryValue +"'";
    }

    get RBIReportingIndustryFilterCondition(){
        return 'Industry__c='+"'"+ this.selectedIndustryValue +"'" + ' AND SubIndustry__c=' +"'"+this.selectedSubIndustryValue +"'";
    }

    handleInputChange(event) {
       
        this.results[event.target.dataset.objname][event.target.dataset.fieldname] = event.target.value;
        
        console.log('::::::',event.target.name);
                
        switch(event.target.name){
            case 'industryType': 
                this.selectedIndustryValue=event.target.value;
                this.subIndustriesPicklistOptions=undefined;
                this.selectedindustryRBIReportingValue=undefined;
                this.industryRBIReportingOptions=undefined;
                this.getSubIndustriesPicklistValues();
                break;

            case 'subIndustryType':
                this.selectedSubIndustryValue=event.target.value;
                this.selectedindustryRBIReportingValue=undefined;
                this.industryRBIReportingOptions=undefined;
                this.getRBIReportingIndustryPicklistValues();
                break;
            
            case 'officialEmail':
                this.validateEmail(); 
                break;  
            
            case 'workingWithCurrentEmployerYears':
                this.validate_Year(event);
                break;
            
            case 'workingWithCurrentEmployerMonths':
                this.validate_Month(event);
                break;    
                
            case 'totalWorkExperienceYears':
                this.validate_Year(event);
                break;  
            case 'totalWorkExperienceMonths':
                this.validate_Month(event);
                break;
            
            case 'currentBusinessVintageYears':
                this.validate_Year(event);
                break;
            case 'currentBusinessVintageMonths':
                this.validate_Month(event);
                break;   
            
            case 'GSTRegistered':
                this.isGSTRegistered=event.target.value==='Yes'?true:false;
                break;    
            
            case 'GSTIN':
                this.validateGSTIN();
                break;  
            
            case 'udyamRegistrationNumber':
                this.validateUdyam();
                break;   

            case 'retirementAge':
                this.validateRetirementAge();
                break;  
            case 'employerName':
                if(event.target.value!==this.otherEmployerOption.Id){
                    this.results.applicantEmployment.Others__c = '';
                 }
                this.displayOthersOption = event.target.value===this.otherEmployerOption.Id?true:false;
                console.log(JSON.stringify(this.results.applicantEmployment));
                break;
            case 'others':
                console.log(JSON.stringify(this.results.applicantEmployment));
                break;        
                
        }
    }


    validateEmail(){
        const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        let email = this.template.querySelector(".emailValidateCls");
        if (email.value.match(emailRegex)) {
            email.setCustomValidity("");

        } else {
            email.setCustomValidity("Please enter a valid email");
        }
        email.reportValidity();
       
    }

    validateGSTIN(){
        const GSTINRegex =/^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/;
        let GSTIN = this.template.querySelector(".gstValidateCls");
        if (GSTIN.value.match(GSTINRegex) || GSTIN.value==='') {
            GSTIN.setCustomValidity("");

        } else {
            GSTIN.setCustomValidity("Please enter a valid GSTIN");
        }
        GSTIN.reportValidity();

    }

    validateUdyam(){
        const udyamRegex =/^UDYAM-[A-Z]{2}-[0-9]{2}-[0-9]{7}$/;
        let udyam = this.template.querySelector(".udyamValidateCls");
        if (udyam.value.match(udyamRegex)) {
            udyam.setCustomValidity("");

        } else {
            udyam.setCustomValidity("Please enter a valid Udyam Registration Number");
        }
        udyam.reportValidity();

    }

    validateRetirementAge(){
        let age = this.template.querySelector(".retirementAgeValidateCls");
        if(age.value>=21 && age.value<=75){
            age.setCustomValidity("");
        }else{
            age.setCustomValidity("Retirement age should range between 21 to 75");
        }
        age.reportValidity();
    }

    get currentDate() {
        let dt = new Date().toISOString().slice(0, 10);
        return dt;
    }

    // @track invalidTotalWorkExperienceYears=false;
    // @track invalidTotalWorkExperienceMonths=false;
    // @track invalidWorkingWithCurrentEmployerYears=false;
    // @track invalidWorkingWithCurrentEmployerMonths=false;
    // @track invalidCurrentBusinessVintageYears=false;
    // @track invalidCurrentBusinessVintageMonths=false;
    
    // validateWorkingExpYear(){
    //     console.log(':::::::::::::::::validate');
    //     const yearRegex = /^[0-9]{2}$/;
    //     let year = this.template.querySelector('[data-id="input-01"]');
    //     if (year.value.match(yearRegex)) {
    //          this.invalidWorkingWithCurrentEmployerYears=false;
    //          this.template.querySelector('[data-id="divblock-1"]').className='slds-form-element';
    //     } else {
    //          this.invalidWorkingWithCurrentEmployerYears=true;
    //          this.template.querySelector('[data-id="divblock-1"]').className='slds-form-element slds-has-error';
    //     }
        
    // }

    // validatecurrentBusinessVintageYears(){
    //     console.log(':::::::::::::::::validate');
    //     const yearRegex = /^[0-9]{2}$/;
    //     let year = this.template.querySelector('[data-id="input-05"]');
    //     if (year.value.match(yearRegex)) {
    //          this.invalidCurrentBusinessVintageYears=false;
    //          this.template.querySelector('[data-id="divblock-5"]').className='slds-form-element';
    //     } else {
    //          this.invalidCurrentBusinessVintageYears=true;
    //          this.template.querySelector('[data-id="divblock-5"]').className='slds-form-element slds-has-error';
    //     }
        
    // }
    
    
    // validateYear(){
    //     console.log(':::::::::::::::::validate');
    //     const yearRegex = /^[0-9]{2}$/;
    //     let year = this.template.querySelector('[data-id="input-03"]');
    //     if (year.value.match(yearRegex)) {
    //          this.invalidTotalWorkExperienceYears=false;
    //          this.template.querySelector('[data-id="divblock-3"]').className='slds-form-element';
    //     } else {
    //          this.invalidTotalWorkExperienceYears=true;
    //          this.template.querySelector('[data-id="divblock-3"]').className='slds-form-element slds-has-error';
    //     }
        
    // }

    validate_Year(event){
        let dataId=event.target.dataset.id;
        const yearRegex = /^[0-9]{2}$/;
        let year = this.template.querySelector(`[data-id="${dataId}"]`);
        if (year.value.match(yearRegex)) {
            year.setCustomValidity("");

        } else {
            year.setCustomValidity("Please make sure the year is formatted in YY.");
        }
        year.reportValidity();
       
    }

    validate_Month(event){
        let dataId=event.target.dataset.id;
        const monthRegex = /^(0[0-9]|1[0-2])$/;
        let month = this.template.querySelector(`[data-id="${dataId}"]`);
        if (month.value.match(monthRegex)) {
            month.setCustomValidity("");

        } else {
            month.setCustomValidity("Please make sure the month is formatted in MM.");
        }
        month.reportValidity();
    }

    // validateWorkingExpMonth(){
    //     const monthRegex = /^(0[1-9]|1[0-2])$/;
    //     let month = this.template.querySelector('[data-id="input-02"]');
    //     if (month.value.match(monthRegex)) {
    //          this.invalidWorkingWithCurrentEmployerMonths=false;
    //          this.template.querySelector('[data-id="divblock-2"]').className='slds-form-element';
    //     } else {
    //          this.invalidWorkingWithCurrentEmployerMonths=true;
    //          this.template.querySelector('[data-id="divblock-2"]').className='slds-form-element slds-has-error';
    //     }
    // }

    // validatecurrentBusinessVintageMonths(){
    //     const monthRegex = /^(0[1-9]|1[0-2])$/;
    //     let month = this.template.querySelector('[data-id="input-06"]');
    //     if (month.value.match(monthRegex)) {
    //          this.invalidCurrentBusinessVintageMonths=false;
    //          this.template.querySelector('[data-id="divblock-6"]').className='slds-form-element';
    //     } else {
    //          this.invalidCurrentBusinessVintageMonths=true;
    //          this.template.querySelector('[data-id="divblock-6"]').className='slds-form-element slds-has-error';
    //     }
    // }

    // validateMonth(){
    //     const monthRegex = /^(0[1-9]|1[0-2])$/;
    //     let month = this.template.querySelector('[data-id="input-04"]');
    //     if (month.value.match(monthRegex)) {
    //          this.invalidTotalWorkExperienceMonths=false;
    //          this.template.querySelector('[data-id="divblock-4"]').className='slds-form-element';
    //     } else {
    //          this.invalidTotalWorkExperienceMonths=true;
    //          this.template.querySelector('[data-id="divblock-4"]').className='slds-form-element slds-has-error';
    //     }
    // }

    @track GSTRegistered;
    @track isGSTRegistered=false;

    handleSave(validate) {
        console.log(':::::Inside Save',)
        if(validate){         
            
            let isInputCorrect = this.reportValidity();
            console.log(':::::::::::::isInputCorrect',isInputCorrect);
            if (isInputCorrect === true) {
                this.createOrUpdateRecord();
            }
        }
        else{
            this.createOrUpdateRecord();
        }
    }

    @api reportValidity() {
        this.checkValidityLookup();
         const isInputCorrect = [
             ...this.template.querySelectorAll("lightning-input"),
             ...this.template.querySelectorAll("lightning-combobox"),
             ...this.template.querySelectorAll("lightning-radio-group")
              //...this.template.querySelectorAll("c-custom-lookup")
         ].reduce((validSoFar, inputField) => {
             inputField.reportValidity();
             return validSoFar && inputField.checkValidity();
         }, true);
         return isInputCorrect;
     }

    checkValidityLookup() {
        let isInputCorrect = true;

        let allChilds = this.template.querySelectorAll("c-custom-lookup");
        console.log("custom lookup allChilds>>>", allChilds);
        allChilds.forEach((child) => {
            console.log("custom lookup child>>>", child);
            //isInputCorrect = child.checkValidityLookup();
            console.log(
                "custom lookup validity custom lookup >>>",
                isInputCorrect
            );
            if (!child.checkValidityLookup()) {
                child.checkValidityLookup();
                isInputCorrect = false;
                console.log(
                    "custom lookup validity if false>>>",
                    isInputCorrect
                );
            }
        });
    } 

    createOrUpdateRecord(){
        console.log('<<<<<<<<<<<<<<<<<<<<<<<',this.recordId);
        if( this.recordId){
            this.results.applicantEmployment.Id= this.recordId;
            const fields = this.results.applicantEmployment;
            const recordInput = {fields};

            console.log('::::::Inside Update',fields);
            updateRecord(recordInput)
            .then(() => {
                console.log("INSIDE UPDATE RECORD SUCCESS>>>");
                this.dispatchEvent(
                new ShowToastEvent({
                title: "Success",
                message: "Applicant Employment updated",
                variant: "success",
                }),
            );
          
            })
            .catch((error) => {
                console.log("INSIDE UPDATE RECORD ERROR>>>",error, error.body.message);
                this.dispatchEvent(
                new ShowToastEvent({
                title: "Error while updating record",
                message: error.body.message,
                variant: "error",
                }),
            );
            });
        }
        else{
            this.results.applicantEmployment.LoanApplicant__c=this.results.applicantEmployment.LoanApplicant__c!=null?this.results.applicantEmployment.LoanApplicant__c:this.applicantId;
            const fields = this.results.applicantEmployment;
            console.log(':::::Data::::::::>>>>>>>',this.results.applicantEmployment);
            const recordInput = {fields:fields, apiName: ApplicantEmployment_OBJECT.objectApiName};
            createRecord(recordInput)
            .then((result) => {
                console.log("INSIDE Insert RECORD SUCCESS>>>" , result);
                this.recordId = result.id;
                delete this.results.applicantEmployment.LoanApplicant__c;
                this.dispatchEvent(
                new ShowToastEvent({
                title: "Success",
                message: "Applicant Employment Inserted",
                variant: "success",
                }),
               
            );
          
            })
            .catch((error) => {
                console.log("INSIDE RECORD ERROR>>>",error, error.body.message);
                this.dispatchEvent(
                new ShowToastEvent({
                title: "Error while insterting record",
                message: error.body.message,
                variant: "error",
                }),
            );
            });
        
        }     
    }


    @track lookupRec;
    handleValueSelect(event) {
        this.lookupRec = event.detail;
        console.log("this.lookupRec>>>>>", this.lookupRec);
        
        let lookupId = this.lookupRec.id;
        console.log("lookupId>>>", lookupId);
        let lookupAPIName = this.lookupRec.lookupFieldAPIName;

        const outputObj = { [lookupAPIName]: lookupId };
        console.log("outputObj>>>", outputObj);
        if (this.lookupRec.id != null && this.lookupRec.lookupFieldAPIName === 'EmployerName__c') {
            console.log('Selected Id:',this.lookupRec.id);
            this.results.applicantEmployment.EmployerName__c=this.lookupRec.id;
            
        }
        if (this.lookupRec.lookupFieldAPIName === 'IndustryType__c') {
            console.log('Selected Id:',this.lookupRec.id);
            this.selectedIndustryValue=this.lookupRec.id;
            this.selectedSubIndustryValue=undefined;
            this.selectedindustryRBIReportingValue=undefined;  
            this.results.applicantEmployment.IndustryType__c=this.lookupRec.id;
            this.results.applicantEmployment.SubIndustry__c=undefined;
            this.results.applicantEmployment.IndustryForRBIReporting__c=undefined;
        }
        if (this.lookupRec.lookupFieldAPIName === 'SubIndustry__c') {
            console.log('Selected Id:',this.lookupRec.id);
            this.selectedSubIndustryValue=this.lookupRec.id;
            this.selectedindustryRBIReportingValue=undefined;  
            this.results.applicantEmployment.SubIndustry__c=this.lookupRec.id;;
            this.results.applicantEmployment.IndustryForRBIReporting__c=undefined;
            if(this.selectedIndustryValue!=null && this.selectedSubIndustryValue!=null){ 
                this.getRBIReportingIndustryPicklistValues();
            }else{
                this.results.applicantEmployment.IndustryForRBIReporting__c=undefined;
                this.selectedindustryRBIReportingValue=undefined;
            }
           
        }
    }
}