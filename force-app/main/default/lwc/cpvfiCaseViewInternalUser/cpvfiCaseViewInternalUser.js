import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import upsertMultipleRecord from "@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord";
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import { getObjectInfo, getPicklistValues,getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';

import CaseQueryUpdateSuccess from '@salesforce/label/c.CaseQueryUpdateSuccess';
import CaseDocCreateSuccess from '@salesforce/label/c.CaseDocCreateSuccess';
import CaseQueryUpdateError from '@salesforce/label/c.CaseQueryUpdateError';
import CaseSaveSuccess from '@salesforce/label/c.CaseSaveSuccess';
import CaseQueryRequiredFieldError from '@salesforce/label/c.CaseQueryRequiredFieldError';

import CaseDetailsCpvfiPhotoError from '@salesforce/label/c.CaseDetailsCpvfiPhotoError';
import CaseDetailsPhotoError from '@salesforce/label/c.CaseDetailsPhotoError';
import CaseDetailsReportError from '@salesforce/label/c.CaseDetailsReportError';
import CaseDetailsReportPhotoError from '@salesforce/label/c.CaseDetailsReportPhotoError';
import CaseDetailsRequiredFieldError from '@salesforce/label/c.CaseDetailsRequiredFieldError';
import CaseDetailsTechPhotoError from '@salesforce/label/c.CaseDetailsTechPhotoError';

import Id from "@salesforce/user/Id";
export default class CpvfiCaseViewInternalUser extends LightningElement {
@api recordId;

label = {
    CaseQueryUpdateSuccess,
    CaseDocCreateSuccess,
    CaseQueryUpdateError,
    CaseSaveSuccess,
    CaseQueryRequiredFieldError,
    CaseDetailsCpvfiPhotoError,
    CaseDetailsPhotoError,
    CaseDetailsReportError,
    CaseDetailsReportPhotoError,
    CaseDetailsRequiredFieldError,
    CaseDetailsTechPhotoError
};
@track accountName;
@track appName;
@track appPhone;
@track loanNumber;
@track cpvRecordTypeId;

@track caseWrp = {}
@track caseQryWrp={}
@track mandtory = false;
@track caseQryList=[] ;
@track caseDocList=[];
@track commentQryList=[];
@track showSpinner=false;

borrowerOptions=[];
addOwnerOptions=[]
maritalOptions=[];
neighbourOptions=[];
negReportOptions=[];
isAddressAccesOptions= [];
productTypeOptions= [];
dedupeOptions = [];
negativeAreaOptions= [];
propertyTypeOptions = [];
negativeDatabaseOptions = [];
finalStatusOptions = [];

get disabled(){
    return this.status === 'Closed' || this.status === 'Cancelled' || this.userRole === 'LHM' ;
}

get enableOverride(){
    return this.status === 'Closed' || this.status === 'Cancelled' || this.caseOwnerId !== Id;
}

get showDeleteIcon(){
    return !this.enableOverride;
}

get negativeDedupe(){
    return this.caseWrp.Dedupe_for_Negative_Database__c === 'Yes';
}

get negDataResult(){
    return this.caseWrp.Negative_Database_Result__c === 'Match Found'
}

get addType(){
    return this.caseWrp.Address_Type__c === 'Residence Address' || this.caseWrp.Address_Type__c === 'Permanent Address' || this.caseWrp.Address_Type__c === 'Residence Cum office';
}

get negativeResult(){
    return this.caseWrp.ReportResult__c === 'Negative';
}

get showFinalStatus(){
return this.statusReport === 'Final';
}

get showQryDesc(){
return this.statusReport === 'Query';
}
connectedCallback(){
    this.getCaseData();
    this.fetchCaseQueryDetails();
    this.fetchCaseCommentsDetails();
}   



getCaseData(){
 let  caseData = {
        ParentObjectName: "Case",
        ChildObjectRelName: "",
        parentObjFields: ["Id", "Address_Type__c",'AddressOwnership__c', "Additional_Co_applicant_Guarantor_Name__c",
        'Mobile_No__c','Product_Type__c','Branch_Name__c','Status','ExpiryDate__c','IsReinitiatedExpired__c',
        'DateTimeInitiation__c','Dedupe_for_Negative_Database__c','Date_of_Report__c','Negative_Database_Result__c',
        'Details_of_the_borrowers_have_been_confi__c','Martial_Status__c','Is_the_address_complete_and_easily_Trace__c',
        'Name_of_the_Business_Employer__c','Distance_from_Fedfina_Branch__c','Negative_Area__c','Property_Type__c',
        'Adverse_Remarks_of_Dedupe__c','Negative_Report_reason__c','Remarks_regarding_the_case__c',
        'Final_Status_of_Field_Verification_by_un__c','Mitigant_for_Change_in_Status__c','Address_Line_1__c',
        'Address_Line_2__c','OverrideByFedFina__c','Land_Area_Sq_Ft__c','Land_Valuation_in_Rs__c',
        'Property_Built_up_area_Sq_Ft__c','Residual_Age_in_Years__c','Built_up_area_Valuation_In_Rs__c',
        'Property_Reconstruction_Cost__c','Total_Valuation_Land_Valuation_B__c','Approx_Age_of_Property_in_Years__c',
        'Stage_of_Construction__c','Recommended_by_Technical_Valuer__c','Approved_Plan_OC_available__c',
        'Plot_is_non_agricultural__c','Neighbour_Reference_Check__c','PropertyUsage__c','ReportResult__c',
        'PhotoCount__c','ReportCount__c','TSRVerification__c','IsTheTitleClearNdMarketable__c',
        'TSR_EC_for_no_of_Yrs__c','Query_description__c','DetailsSearchReport__c','Final_Remarks__c','FinalStatusTSRReportFromHLM__c',
        'FinalStatusOfTSR__c','QueryRevert__c','HubManagerReview__c','Property_owner_Names__c','OwnerId','Account.Name',
    'Applicant__r.FullName__c','Applicant__r.PhoneNumber__c','Applicant__c','AccountId','Owner.Name'],
        childObjFields: [],
        queryCriteria: ' where Id = \'' + this.recordId + '\' limit 1'
      };
getSobjectDataNonCacheable({params: caseData}).then((result) => {
console.log("CASE Details RESULT #397:::", result);
if(result.parentRecords[0] !== undefined){
    this.caseOwnerId = result.parentRecords[0].OwnerId ;
    this.caseWrp.Address_Type__c = result.parentRecords[0].Address_Type__c ? result.parentRecords[0].Address_Type__c : '';
    // this.caseWrp.PhoneNoOfBorrower__c = result.parentRecords[0].PhoneNoOfBorrower__c ? result.parentRecords[0].PhoneNoOfBorrower__c : '';
    this.caseWrp.Additional_Co_applicant_Guarantor_Name__c = result.parentRecords[0].Additional_Co_applicant_Guarantor_Name__c ? result.parentRecords[0].Additional_Co_applicant_Guarantor_Name__c : '';
     this.caseWrp.Mobile_No__c = result.parentRecords[0].Mobile_No__c ? result.parentRecords[0].Mobile_No__c : '';
     this.caseWrp.Product_Type__c = result.parentRecords[0].Product_Type__c ? result.parentRecords[0].Product_Type__c : '';
     this.caseWrp.Branch_Name__c = result.parentRecords[0].Branch_Name__c ? result.parentRecords[0].Branch_Name__c : '';
     this.status = result.parentRecords[0].Status ? result.parentRecords[0].Status : '';
     this.expryDate = result.parentRecords[0].ExpiryDate__c ? result.parentRecords[0].ExpiryDate__c : '';
     this.isRenitExp = result.parentRecords[0].IsReinitiatedExpired__c ? result.parentRecords[0].IsReinitiatedExpired__c : '';

     this.dateTimeInitiation= result.parentRecords[0].DateTimeInitiation__c;
     this.caseWrp.Dedupe_for_Negative_Database__c = result.parentRecords[0].Dedupe_for_Negative_Database__c ? result.parentRecords[0].Dedupe_for_Negative_Database__c : '';
     this.caseWrp.AddressOwnership__c = result.parentRecords[0].AddressOwnership__c ? result.parentRecords[0].AddressOwnership__c : '';
   //  this.caseWrp.Date_of_Report__c = result.parentRecords[0].Date_of_Report__c ? result.parentRecords[0].Date_of_Report__c : '';
   this.reportDate = result.parentRecords[0].Date_of_Report__c
     this.caseWrp.Negative_Database_Result__c = result.parentRecords[0].Negative_Database_Result__c ? result.parentRecords[0].Negative_Database_Result__c : '';
     this.caseWrp.Details_of_the_borrowers_have_been_confi__c = result.parentRecords[0].Details_of_the_borrowers_have_been_confi__c ? result.parentRecords[0].Details_of_the_borrowers_have_been_confi__c : '';
     this.caseWrp.Martial_Status__c = result.parentRecords[0].Martial_Status__c ? result.parentRecords[0].Martial_Status__c : '';
     
     this.caseWrp.Is_the_address_complete_and_easily_Trace__c = result.parentRecords[0].Is_the_address_complete_and_easily_Trace__c ? result.parentRecords[0].Is_the_address_complete_and_easily_Trace__c : '';
     this.caseWrp.Name_of_the_Business_Employer__c = result.parentRecords[0].Name_of_the_Business_Employer__c ? result.parentRecords[0].Name_of_the_Business_Employer__c : '';
     this.caseWrp.Negative_Area__c = result.parentRecords[0].Negative_Area__c ? result.parentRecords[0].Negative_Area__c : '';
     this.caseWrp.Property_Type__c = result.parentRecords[0].Property_Type__c ? result.parentRecords[0].Property_Type__c : '';
     this.caseWrp.Neighbour_Reference_Check__c = result.parentRecords[0].Neighbour_Reference_Check__c ? result.parentRecords[0].Neighbour_Reference_Check__c : '';
     this.caseWrp.Distance_from_Fedfina_Branch__c = result.parentRecords[0].Distance_from_Fedfina_Branch__c ? result.parentRecords[0].Distance_from_Fedfina_Branch__c : '';;
     this.caseWrp.Adverse_Remarks_of_Dedupe__c = result.parentRecords[0].Adverse_Remarks_of_Dedupe__c ? result.parentRecords[0].Adverse_Remarks_of_Dedupe__c : '';
    // this.caseWrp.TAT_of_FI_Report__c = result.parentRecords[0].TAT_of_FI_Report__c ? result.parentRecords[0].TAT_of_FI_Report__c :false ;
     this.caseWrp.Negative_Report_reason__c = result.parentRecords[0].Negative_Report_reason__c ? result.parentRecords[0].Negative_Report_reason__c :'' ;
     this.caseWrp.Remarks_regarding_the_case__c = result.parentRecords[0].Remarks_regarding_the_case__c ? result.parentRecords[0].Remarks_regarding_the_case__c : '';
     this.caseWrp.Final_Status_of_Field_Verification_by_un__c = result.parentRecords[0].Final_Status_of_Field_Verification_by_un__c ? result.parentRecords[0].Final_Status_of_Field_Verification_by_un__c :'' ;
     this.caseWrp.Mitigant_for_Change_in_Status__c = result.parentRecords[0].Mitigant_for_Change_in_Status__c ? result.parentRecords[0].Mitigant_for_Change_in_Status__c :'' ;
    
    this.address = result.parentRecords[0].Address_Line_1__c + ',' + result.parentRecords[0].Address_Line_2__c;

    this.caseWrp.OverrideByFedFina__c = result.parentRecords[0].OverrideByFedFina__c ? result.parentRecords[0].OverrideByFedFina__c :false ;
       this.caseWrp.Approved_Plan_OC_available__c = result.parentRecords[0].Approved_Plan_OC_available__c ? result.parentRecords[0].Approved_Plan_OC_available__c :'' ;
    this.caseWrp.Plot_is_non_agricultural__c = result.parentRecords[0].Plot_is_non_agricultural__c ? result.parentRecords[0].Plot_is_non_agricultural__c : '';
    this.caseWrp.PropertyUsage__c = result.parentRecords[0].PropertyUsage__c ? result.parentRecords[0].PropertyUsage__c :'' ;
    this.caseWrp.ReportResult__c = result.parentRecords[0].ReportResult__c ? result.parentRecords[0].ReportResult__c :'' ;
    this.accountName = result.parentRecords[0].AccountId !== undefined ?  result.parentRecords[0].Account.Name : result.parentRecords[0].Owner.Name ;
    if(result.parentRecords[0].Applicant__c && result.parentRecords[0].Applicant__r !== undefined){
        this.appName = result.parentRecords[0].Applicant__r.FullName__c !== undefined ? result.parentRecords[0].Applicant__r.FullName__c:'';
        this.appPhone = result.parentRecords[0].Applicant__r.PhoneNumber__c !== undefined ? result.parentRecords[0].Applicant__r.PhoneNumber__c:'';
    }
 
}          
 })
 .catch((error) => {
   console.log("CASE DOCUMENT COUNT ERROR #463", error);
 });

}

    @track caseOwnerId;
    // fetchCaseDetails() {     
    //     let caseParams = {
    //         ParentObjectName: 'Case',
    //         ChildObjectRelName: '',
    //         parentObjFields: ['Id', 'Account.Name', 'Applicant__r.TabName__c','Applicant__r.PhoneNumber__c','Loan_Application__c',
    //             'Loan_Application__r.Name', 'caseNumber','CreatedDate','Property_Owner_s_as_per_Technical_Repo__c',
    //             'Applicant__r.FullName__c','Loan_Application__r.BrchCode__c','OwnerId'],
    //         childObjFields: [],
    //         queryCriteria: ' where Id = \'' + this.recordId + '\' limit 1'
    //     };
    //     getSobjectDataNonCacheable({ params: caseParams })
    //         .then((result) => {
    //             console.log("result CASE DETAILS COMP #662>>>>>", result);
                
    //             if (result && result.parentRecords && result.parentRecords.length > 0) {
    //                 this.accountName = result.parentRecords[0].AccountId !== undefined ?  result.parentRecords[0].Account.Name : '' ;
    //                 this.caseOwnerId = result.parentRecords[0].OwnerId ;
    //                 if(result.parentRecords[0].Applicant__c && result.parentRecords[0].Applicant__r !== undefined){
    //                     this.appName = result.parentRecords[0].Applicant__r.FullName__c !== undefined ? result.parentRecords[0].Applicant__r.FullName__c:'';
    //                     this.appPhone = result.parentRecords[0].Applicant__r.PhoneNumber__c !== undefined ? result.parentRecords[0].Applicant__r.PhoneNumber__c:'';
    //                 }
                 
    //                this.getCaseData();
    //             }
    //         })
    //         .catch((error) => {
    //             console.log("Error in CASE DETAILS COMP #681", error);
    //         });
    // }
  


    fetchCaseQueryDetails() {   
        let caseQryParams = {
                 ParentObjectName: 'Case_Query__c',
                 ChildObjectRelName: '',
                 parentObjFields: ['Id', 'Case__c','CaseNumber__c', 'Query__c','Raised_By__c','Response__c','Status__c','Case__r.Status'],
                 childObjFields: [],
                 queryCriteria: ' where Case__c = \'' + this._recordId + '\' order by CreatedDate desc'
             };
             getSobjectDataNonCacheable({ params: caseQryParams })
                 .then((result) => {
                     console.log("result CASE QEURY IN CASE DETAILS COMP #732>>>>>", result);
                     if (result && result.parentRecords && result.parentRecords.length > 0) {
                         let arr=[];
                         arr= result.parentRecords;
                         arr.forEach(item=>{
                             console.log('DATA IN CASE Query ITEM #428 ::::>>>>',JSON.stringify(item));
                             let obj={};
                            // this.caseQryId = result.data.parentRecords.Id
                            obj.sobjectType = 'Case_Query__c';
                            obj.Case__c=item.Case__c;
                            obj.Id= item.Id;
                            obj.CaseNumber__c= item.CaseNumber__c;
                            obj.Query__c= item.Query__c;
                            obj.Response__c=item.Response__c;
                            obj.Status__c=item.Status__c;
                            obj.caseStatus = item.Case__r.Status;
                             if(obj.caseStatus !== undefined && obj.caseStatus === 'Closed'){
                                 obj.disableCaseQry=true;
                                 console.log('DATA IN CASE Query DETAILS #431 ::::>>>>',obj.disableCaseQry);
                             }else{
                                 obj.disableCaseQry=false;
                             }
                            
                             this.caseQryList.push(obj);  
                         })
                     }
                 })
                 .catch((error) => {
                     console.log("Error in CASE DETAILS COMP #760", error);
                 });
         }

         generatePicklist(data) {
            return data.values.map(item => ({ label: item.label, value: item.value }))
        }
    
        @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
        getObjectInfo({ error, data }) {
            if (data) {
                //console.log('DATA in RECORD TYPE ID', data);
                for (let key in data.recordTypeInfos) {
                    let recordType = data.recordTypeInfos[key];
                    console.log("recordType.value>>>>>", recordType.name);
                    if (recordType.name === 'CPVFI') {
                        this.cpvRecordTypeId = key;
                    } 
                    console.log('data.cpvRecordTypeId', key);
                }
               
            } else if (error) {
                console.error('ERROR CASE DETAILS:::::::#318', error);
            }
        }
    
        @wire(getPicklistValuesByRecordType, {
            objectApiName: CASE_OBJECT,
            recordTypeId: '$cpvRecordTypeId',
        })
        picklistHandler({ data, error }) {
            if (data) {         
                 this.borrowerOptions = [...this.generatePicklist(data.picklistFieldValues.Details_of_the_borrowers_have_been_confi__c)]
                 this.maritalOptions=[...this.generatePicklist(data.picklistFieldValues.Martial_Status__c)]
                 this.addOwnerOptions=[...this.generatePicklist(data.picklistFieldValues.AddressOwnership__c)]
                 this.neighbourOptions = [...this.generatePicklist(data.picklistFieldValues.Neighbour_Reference_Check__c)]
                 this.negReportOptions = [...this.generatePicklist(data.picklistFieldValues.Negative_Report_reason__c)]           
                 this.isAddressAccesOptions = [...this.generatePicklist(data.picklistFieldValues.Is_the_address_complete_and_easily_Trace__c)]
                 this.productTypeOptions = [...this.generatePicklist(data.picklistFieldValues.Product_Type__c)]
                 this.dedupeOptions = [...this.generatePicklist(data.picklistFieldValues.Dedupe_for_Negative_Database__c)]
                 this.negativeAreaOptions = [...this.generatePicklist(data.picklistFieldValues.Negative_Area__c)]
                // this.propertyTypeOptions = [...this.generatePicklist(data.picklistFieldValues.Property_Type__c)]
                 this.negativeDatabaseOptions = [...this.generatePicklist(data.picklistFieldValues.Negative_Database_Result__c)]
                 this.finalStatusOptions = [...this.generatePicklist(data.picklistFieldValues.Final_Status_of_Field_Verification_by_un__c)]
                // this.propAgriOptions=[...this.generatePicklist(data.picklistFieldValues.Plot_is_non_agricultural__c)]
                // this.approveLayoutOptions=[...this.generatePicklist(data.picklistFieldValues.Approved_Plan_OC_available__c)]
                // this.propUsageOptions=[...this.generatePicklist(data.picklistFieldValues.PropertyUsage__c)]
                 this.reportResultOptions=[...this.generatePicklist(data.picklistFieldValues.ReportResult__c)]
            }
    
            if (error) {
                console.error('ERROR CASE DETAILS:::::::#344',error)
            }
    
        }
        fetchCaseCommentsDetails() {     
            let commentsQueryParams = {
                ParentObjectName: 'Comments__c',
                ChildObjectRelName: '',
                parentObjFields: [ "Id","CaseNumber__c","Name","ReviewerComments__c","User__c","Case__c","UserName__c"],
                childObjFields: [],
                queryCriteria: ' where Id = \'' + this.recordId + '\' limit 1'
            };
            getSobjectDataNonCacheable({ params: commentsQueryParams })
                .then((result) => {
                    console.log("result COMP #175>>>>>", result);
                    
                    if (result && result.parentRecords && result.parentRecords.length > 0) {
                        this.commentQryList = result.parentRecords;
                       
                    }
                    console.log("DATA IN COMMMENTS Query DETAILS #180 ::::>>>>",this.commentQryList);
                })
                .catch((error) => {
                    console.log("RROR IN CASE COMMENTS fetchCaseCommentsDetails::: #184", error);
                });
        }

        @api handleValueSelect(event){
            let childEvt = event.detail;
            console.log('childEvt::::#476',childEvt );
            this.refreshDocTable();
           // this.getCaseDocCount();
    
        } 

        @api refreshDocTable() {
            this.showSpinner = false;
            let child = this.template.querySelector('c-show-case-document');
            child.handleFilesUploaded();
        
        }

        handleInputChange(event){
   

         if(event.target.type === 'text'){
               this.caseWrp[event.target.dataset.name] = event.target.value.toUpperCase();
             }
             else if(event.target.type === 'textarea'){
               this.caseWrp[event.target.dataset.name] = event.target.value.toUpperCase();
             }else{
           this.caseWrp[event.target.dataset.name] = event.target.value;
           if(event.target.dataset.name === 'Final_Status_of_Field_Verification_by_un__c'){
               this.caseWrp[event.target.dataset.name] = event.target.value;
               if(event.target.value){
               this.mandtory = true;
               } 
               else{
                this.mandtory = false
               }
            }
            if(event.target.dataset.name ==='ReportResult__c'){
               this.statusReport = event.target.value;
            }
       
       }
           
         
       }

       handleValueChange(event) {
        try {
          let currentIndex = event.target.dataset.index;
          let obj = { ...this.caseQryList[event.target.dataset.index] };
    
          obj[event.target.dataset.fieldName] = event.target.value;
        //  console.log("caseQryList ///1326", JSON.stringify(this.caseQryList));
          this.caseQryList = [...this.caseQryList];
          this.caseQryList[currentIndex] = obj;
    
        } catch (e) {
          console.error("'ERROR CASE DETAILS:::::::#398", e);
        }
      }
    
      handlePicklistValues(event) {
        let currentIndex = event.detail.index;
        let fieldName = event.detail.fieldName;
      //  console.log("currentIndex is #780 ", currentIndex, event.detail);
        let obj = { ...this.caseQryList[currentIndex] };
    
        obj[fieldName] = event.detail.val;
        this.caseQryList = [...this.caseQryList];
        this.caseQryList[currentIndex] = obj;
    
      }
    
    handleSaveCaseQuery(){
      //  console.log("case query save called  #811",this.caseQryList);
      if(this.caseQryList && this.caseQryList.length>0){
            this.caseQryList.forEach(item=>{
              delete  item.disableCaseQry;
            })
    
            console.log('THIS CASEQRYLIST::::::655',JSON.stringify(this.caseQryList));
            upsertMultipleRecord({ params: this.caseQryList })
            .then((result) => {
              //console.log("result occured in upsert #816", result);
              this.ShowToastMessage('Success',this.label.CaseQueryUpdateSuccess,'success','dismissable')
              
        
            })
            .catch((error) => {
          
              console.log('ERROR CASE DETAILS:::::::#432', error);
              //console.log("upsertDataMethod");
            });
            
      } 
     
    
      }

       
        @track photoCount;
        @track reportCount;
        @track isInputCorrect=false;
handleSave() {
      let parameter = {
        ParentObjectName: 'Case',
        ChildObjectRelName: null,
        parentObjFields: ['Id','ReportCount__c','PhotoCount__c','Status'],
        childObjFields: [],
        queryCriteria: ' where id = \'' + this.recordId + '\' limit 1'
        }
        getSobjectDataNonCacheable({params: parameter})
        .then((result) => {
            console.log("Result photo and report count 317", JSON.stringify(result));
          

              this.photoCount = result.parentRecords[0] && result.parentRecords[0].PhotoCount__c ? result.parentRecords[0].PhotoCount__c : 0;
              this.reportCount = result.parentRecords[0] && result.parentRecords[0].ReportCount__c ? result.parentRecords[0].ReportCount__c: 0;
        
        
            this.isInputCorrect = this.validateForm();
            if (this.isInputCorrect === true) {              
                    if(!(this.status === 'Cancelled' && this.status === 'Closed')){
                        // if( this.caseWrp.Final_Status_of_Field_Verification_by_un__c !== ''){
                            this.caseWrp.Status = 'Closed';
                            this.updateRec();     
                          
                 //     }                 
                        
                    }
                    this.handleSaveCaseQuery();
        
                }
                
           })
           .catch((error) => {
             console.log("Erro while upload photos", JSON.stringify(error));
           })

}

validateForm() {
    let isValid = true
    console.log('ERROR CASE DETAILS PhotoCount:::::#877',this.photoCount ,'ReportCount:::',this.reportCount);
    
    if(this.status === 'New' || this.status === 'Review Requested' || this.status === 'Query' || this.status === 'Query Resolved' ){
        if(!(this.caseWrp.ReportResult__c === 'Negative' && this.caseWrp.Negative_Report_reason__c ==='Difficult to trace the address')){    
        if((this.reportCount === undefined || this.reportCount < 1  )  && (this.photoCount === undefined || this.photoCount < 1  )  ){
                isValid=false
                this.ShowToastMessage('Error',this.label.CaseDetailsReportPhotoError,'error','sticky')
            }
            else if(this.reportCount == null || this.reportCount < 1){
                isValid=false
                this.ShowToastMessage('Error',this.label.CaseDetailsReportError,'error','sticky')
            }else if(this.photoCount == null || this.photoCount < 1){
                isValid=false
                this.ShowToastMessage('Error','Please add minimum 2 Photos','error','sticky')  

            }
        }
}
  


    this.template.querySelectorAll('lightning-input').forEach(element => {
        if(element.reportValidity()){
           // console.log('ERROR CASE DETAILS:::::::#245');
        }else{
            isValid = false;
            this.ShowToastMessage('Error',this.label.CaseDetailsRequiredFieldError,'error','sticky')  
        }


    });
    this.template.querySelectorAll('lightning-combobox').forEach(element => {
        if(element.reportValidity()){
            //
        }else{
            isValid = false;
            this.ShowToastMessage('Error',this.label.CaseDetailsRequiredFieldError,'error','sticky')
        }

    });

    this.template.querySelectorAll('lightning-textarea').forEach(element => {
        if(element.reportValidity()){
            //
        }else{
            isValid = false;
            this.ShowToastMessage('Error',this.label.CaseDetailsRequiredFieldError,'error','sticky')
        }

    });
    return isValid;
}

updateRec() {
    
    if(this.status !== 'Cancelled'){
        this.showSpinner = true;
    let caseArr=[];
    this.caseWrp['Id'] = this.recordId;
    this.caseWrp.sobjectType='Case';
    if(this.caseWrp.ReportResult__c !=='Negative'){
        this.caseWrp.Negative_Report_reason__c='';
    }
    console.log(" this.caseWrp['Id']", JSON.stringify(this.caseWrp));

    caseArr.push(this.caseWrp);

    if(caseArr){
        this.upsertCase(caseArr);
    }
       
        }
}

upsertCase(obj){
    if(obj){   
    console.log('Case Document Detail Records create ##951', obj); 
    
    upsertMultipleRecord({ params: obj })
    .then(result => {     
            this.showSpinner = false;
        this.ShowToastMessage('Success',this.label.CaseSaveSuccess,'success','sticky')
        location.reload();
        
    })
    .catch(error => {
        this.showSpinner = false;
        console.log(" INSIDE UPDATE RECORD ERROR>>>", error, error.body.message);
        this.ShowToastMessage('Error',this.label.CaseQueryRequiredFieldError,'error','sticky')
    })
  }
}
getCaseDocCount(){
let parameter = {
    ParentObjectName: 'Case',
    ChildObjectRelName: null,
    parentObjFields: ['Id','ReportCount__c','PhotoCount__c','Status'],
    childObjFields: [],
    queryCriteria: ' where id = \'' + this.recordId + '\''
    }


    getSobjectDataNonCacheable({params: parameter})
    .then((result) => {
        if(result.parentRecords[0].PhotoCount__c !== undefined){
          this.photoCount = result.parentRecords[0].PhotoCount__c;
          this.reportCount = result.parentRecords[0].ReportCount__c;
        }
         
       })
       .catch((error) => {
         console.log("Erro while upload photos", JSON.stringify(error));
       });
    }


ShowToastMessage(title,message,variant,mode){
    const evt = new ShowToastEvent({
        title,
        message,
        variant,
        mode 
    });
    this.dispatchEvent(evt);
}
}