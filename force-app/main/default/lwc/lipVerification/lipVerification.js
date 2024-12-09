import { LightningElement, api, track, wire } from 'lwc';

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import CASE_OBJECT from '@salesforce/schema/Case';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import {deleteRecord} from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";

//Apex methods
import getAllSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataWithoutCacheable';
import getSobjectData from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData";
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getAgency from "@salesforce/apex/GetAgencyController.getAgency";
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";


import WAIVER_REASON from "@salesforce/schema/Case.WaiverReason__c";
// Custom labels
import CpvVerf_ReInitiate_SuccessMessage from '@salesforce/label/c.CpvVerf_ReInitiate_SuccessMessage';
import CpvVerf_Initiate_SuccessMessage from '@salesforce/label/c.LIP_Initiation_Success';
import CpvVerf_FileAccpt_ErrorMessage from '@salesforce/label/c.CpvVerf_FileAccpt_ErrorMessage';
import LIP_Verification_Loan_Amount_Condition from '@salesforce/label/c.LIP_Verification_Loan_Amount_Condition';

export default class LipVerification extends LightningElement {
    label = {
        CpvVerf_ReInitiate_SuccessMessage,
        CpvVerf_Initiate_SuccessMessage,
        CpvVerf_FileAccpt_ErrorMessage,
        LIP_Verification_Loan_Amount_Condition
    }
    @api loanAppId = 'a08C4000007Kw2EIAS';
    @api hasEditAccess = false;
    @track isModalOpen = false;
    @track appData = [];
    @track appModalData = [];
    @track caseRecords = [];
    @track showSpinner = false;
    @track disableMode;
    @track typeOfBorrower = 'Financial';
    @track cpvRecordTypeId = '';
    @track applIds = [];
    @track waiverReasonOptions=[];
    @track cpvRecordTypeId;
    @track agencyOptions1=[];
    
    
    PropIdentified
    disInitiate

    @track _applicantIdOnTabset;
    @api get applicantIdOnTabset() {
        return this._applicantIdOnTabset;
    }
    set applicantIdOnTabset(value) {
        this._applicantIdOnTabset = value;
       // this.applicantIdtemp = value;

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
                if (recordType.name === 'LIP Vendor case') {
                    this.cpvRecordTypeId = key;
                } 
                console.log('data.cpvRecordTypeId', key);
            }
           
        } else if (error) {
            console.error('ERROR CASE DETAILS:::::::#318', error);
        }
    }

    @wire(getPicklistValuesByRecordType, {
      objectApiName: 'Case',
      recordTypeId: '$cpvRecordTypeId',
  })
  waiverReasonPicklistHandler({ data, error }) {
      if (data) {
         // console.log('data in PicklistHandler', JSON.stringify(data));
          this.waiverReasonOptions = [...this.generatePicklist(data.picklistFieldValues.WaiverReason__c)]
         // console.log('data in  this.caseQrystatusOptions',  this.caseQrystatusOptions);
      }
      if (error) {
          console.error('ERROR CASE DETAILS:::::::#361', error)
      }
  }




    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    getObjectInfo({ error, data }) {
        if (data) {
            console.log('DATA in RECORD TYPE ID', data);
            for (let key in data.recordTypeInfos) {
                let recordType = data.recordTypeInfos[key];
                console.log("recordType.value>>>>>", recordType.name);
                if (recordType.name === 'LIP Vendor case') {
                    this.cpvRecordTypeId = key;
                }
                console.log('data.cpvRecordTypeId', key);
                console.log('this.cpvRecordTypeId', this.cpvRecordTypeId);
            }

        } else if (error) {
            console.error('Error fetching record type Id', error);
        }
    }

    @track applicantIds = '';
    @track locMstId=[];
    connectedCallback() {
        
        if (this.hasEditAccess === false) {
            this.disableMode = true;
            this.disInitiate = true;
        }else{
            this.disableMode = false;
        }
        this.fetchLoanDetails();
        this.getCaseStatus();
        //this.getCoApplData();
        this.getMandatoryAddrMetaata();
        //this.fetchApplAsset();
      //  this.getAgencyLocMapp('','ONGOLE','');

        // this.getApplicaWithAddressDetails();
    }
    Agency;
    handleInputChange(event){
        this.Agency = event.target.value;
    }


    getApplicaWithAddressDetails() {
        let paramsData = {
            ParentObjectName: 'Applicant__c',
            ChildObjectRelName: 'Applicant_Addresses__r',
            parentObjFields: ['Id', 'LoanAppln__c','LoanAppln__r.Product__c', 'TabName__c','LoanAppln__r.ApplicantName__c','FullName__c', 'MobNumber__c', 'PhoneNumber__c', 'Type_of_Borrower__c','ApplType__c','Constitution__c','CustProfile__c','AssessmentProgram__c'],
            childObjFields: ['Id', 'AddrLine1__c', 'AddrLine2__c', 'AddrTyp__c', 'City__c', 'CityId__c','Landmark__c','Pincode__c','State__c','HouseNo__c','Locality__c'],
            queryCriteria: '  where Id = \'' + this._applicantIdOnTabset + '\''
        }
        // queryCriteria: '  where Type_of_Borrower__c = \'' + this.typeOfBorrower + '\' AND LoanAppln__c = \'' + this.loanAppId + '\''
        getAllSobjectDatawithRelatedRecords({ params: paramsData })
            .then((result) => {
                this.appData = result;
                console.log('result is', JSON.stringify(result));
                //console.log('child Rcecord', JSON.stringify(result.ChildReords))
                if (this.appData) {
                    this.appData.forEach(item => {
                        
                        if (item.parentRecord && item.parentRecord.Type_of_Borrower__c && item.parentRecord.Type_of_Borrower__c === 'Financial') {
                            //if (item.parentRecord && item.parentRecord.AssessmentProgram__c && item.parentRecord.AssessmentProgram__c === 'Regular Income Program'){
                            console.log('Parent Rcecord' ,JSON.stringify(item.parentRecord) )
                            if (item.ChildReords) {
                                console.log('child Rcecord' ,JSON.stringify(item.ChildReords) )
                                item.ChildReords.forEach(childitem => {
                                if(childitem.AddrTyp__c === 'Office Address' || childitem.AddrTyp__c === 'Residence Cum office' || childitem.AddrTyp__c === 'Principal place for business'){
                                console.log('AddType',childitem.AddrTyp__c)
                                    let obj = {};
                                    obj.appId = item.parentRecord.Id;
                                    obj.loanAppId = this.loanAppId;
                                    obj.appName = item.parentRecord.FullName__c;
                                    obj.mainApp = item.parentRecord.LoanAppln__r.ApplicantName__c;
                                    obj.prodType = item.parentRecord.LoanAppln__r.Product__c;
                                    obj.mobileNumber = item.parentRecord.MobNumber__c;
                                    obj.phoneNumber = item.parentRecord.PhoneNumber__c;
                                    obj.appAdrrsId = childitem.Id;
                                    obj.appAddrType = childitem.AddrTyp__c;
                                    obj.appAddrLine1 = childitem.AddrLine1__c;
                                    obj.appAddrLine2 = childitem.AddrLine2__c;
                                    obj.cityId = childitem.CityId__c;
                                    obj.addrCity = childitem.City__c;
                                    obj.landMark = childitem.Landmark__c;
                                    obj.pinCode = childitem.Pincode__c;
                                    obj.state = childitem.State__c;
                                    obj.houseNo = childitem.HouseNo__c;
                                    obj.locality = childitem.Locality__c;
                                    obj.selectCheckbox = false;
                                    let tempArr=[];
                                    let selectList=[] 
                                    console.log('this.optionOfApp',JSON.stringify(this.optionOfApp))
                                    for(var i=0; i<this.optionOfApp.length;i++){
                                            if(childitem.City__c === this.optionOfApp[i].cityNam){
                                            tempArr.push(this.optionOfApp[i]);
                                    }
                                    }
                                                                   
                                    obj.appList=[...tempArr];

                                    tempArr.forEach(i=>{
                                        selectList.push(i.value) ;
                                     })
                                     obj.selectedList=[...selectList];
                                   

                                    if (this.caseStatusArr && this.caseStatusArr.length > 0) {
                                        this.caseStatusArr.forEach(Element => {
                                            if (Element.appId === obj.appId && Element.addrType === obj.appAddrType ) {
                                                obj.isDisable = true;
                                                obj.isDisableWaive = true;
                                            } else if(Element.appId === obj.appId && Element.addrType === obj.appAddrType){
                                                obj.isDisableWaive = true;
                                                obj.isDisable = false;
                                            }
                                        })
                                    }


                                    if (obj.cityId) {
                                        this.appModalData.push(obj);
                                    }


                            }
                        })
                            }
                        

                        }
                    //}
                    });
                    
                console.log('this.appModalData #260', JSON.stringify(this.appModalData));
                this.appModalData.forEach(childitem => {
                    console.log('this.appModalData #260 loop', JSON.stringify(childitem.addrCity));
                this.getCoApplData(childitem.addrCity);
                })
               
                    console.log('Location master Ids in CPV::::::>#210', JSON.stringify(this.appModalData));
                }
                if (result.error) {
                    console.error('appl result getting error=', result.error);
                }
            })

    }


    @track caseData = []
    @track caseStatusArr = [];
    getCaseStatus() {
        let casepPramsData = {
            ParentObjectName: 'Applicant__c',
            ChildObjectRelName: 'Cases__r',
            parentObjFields: ['Id'],
            childObjFields: ['Applicant__c','RecordType.Name', 'Status', 'CaseNumber', 'Address_Type__c', 'ApplAddr__c','WaiveCPV__c','RecordTypeId'],
            queryCriteria: '   WHERE Id = \'' + this._applicantIdOnTabset + '\''
            // queryCriteria: '   WHERE ID IN (\''+this.applIds.join('\', \'') + '\')'

        }
        getAllSobjectDatawithRelatedRecords({ params: casepPramsData })
            .then((result) => {
                
                this.caseData = JSON.parse(JSON.stringify(result));
                console.log('this.caseData is #238', JSON.stringify(this.caseData[0]));
                this.caseStatusArr = [];


                if (this.caseData && this.caseData[0] && this.caseData[0].ChildReords) {
                    let newArray = [];

                    this.caseData.forEach(record => {
                        if (record.ChildReords && record.ChildReords[0]) {
                            record.ChildReords.forEach(childRecord => {
                                if (childRecord.Status && childRecord.Status === 'New' && childRecord.RecordType.Name === 'LIP Vendor case') {
                                    var newObj = {
                                        appId: childRecord.Applicant__c,
                                        addrType: childRecord.Address_Type__c,
                                        waiveCpv: childRecord.WaiveCPV__c
                                    };
                                    newArray.push(newObj);
                                }


                            });
                        }

                    });
                    console.log('this.caseData is #224', JSON.stringify(newArray));
                    this.caseStatusArr = [...newArray]
                }
               this.getApplicaWithAddressDetails();
                if (result.error) {
                    console.error('appl result getting error=', result.error);
                }
            })
    }
    handleCpvIntialization() {

        this.isModalOpen = true;
        this.appModalData = [];
        this.getCaseStatus();
        // if(this.lanCity){
        //     this.getAgencyLocMapp('',this.lanCity,'');
        // }
       
    }

    handleClick(event) {
        console.log('HANDLE CLICK IN CV ', JSON.stringify(event.target.dataset));
        console.log('DocDetails', JSON.stringify(event.target.dataset));
        let searchDoc = {};
        
        let val =event.target.checked;
        let applId = event.target.dataset.appid;
        let appAddreID = event.target.dataset.addressid;
        let cityId = event.target.dataset.cityid;
        let cityName = event.target.dataset.cityname;
        let indexId = event.target.dataset.index;
        let agency = event.target.dataset.selectList;
        console.log('val ', val, 'appId ', applId,'cityId',cityId,'cityName',cityName,'indexId',indexId, 'Agency', agency);
        if (appAddreID) {
            console.log('appAddreID ', appAddreID);
            searchDoc = this.appModalData.find((doc) => doc.appAdrrsId === appAddreID);
        } else {
            searchDoc = this.appModalData.find((doc) => doc.appId === applId);
        }
        if (searchDoc && !searchDoc.isDisable) {
            console.log('searchDoc', JSON.stringify(searchDoc));
           
            if(event.target.dataset.label==='Initiate LIP'){
                if(searchDoc.appList.length === 0 || searchDoc.appList === undefined){
                    
                console.log('searchDoc inside ', JSON.stringify(searchDoc));
                    this.showToastMessage('Error', 'No Agency Mapped To Selected Location.', 'error', 'sticky');
                    event.target.checked = false;
                }else{
                searchDoc.selectCheckbox = val;
                console.log('searchDoc #312', JSON.stringify(searchDoc));
                console.log('AppList :::::#312',JSON.stringify(searchDoc.appList));
                searchDoc.reqWaiveRsn=false;
            }
            }
            else if(event.target.dataset.label==='Remarks for agency'){
                searchDoc.Remarks_for_Technical_Agency__c=event.target.value.toUpperCase();
            }
            else if(event.target.dataset.label==='agency'){
                searchDoc.selectList=event.target.value;
                console.log('event.target.value',event.target.value)
                console.log('searchDoc.selectList=event.target.value',searchDoc.selectList)
            }

           
        }
        console.log('this.appModalData is', JSON.stringify(this.appModalData));
    }
   
    closeModal() {
        this.caseRecords = [];
        this.appModalData.forEach(item => {
            item['selectCheckbox'] = false;
        });
        console.log('this.appModalData ', this.appModalData);
        console.log('this.caseRecords ', this.caseRecords);
        this.isModalOpen = false;
    }

    @track checkList=[]
    handleIntialization() {
    //let isInputCorrect = this.validateForm();
    //if(!isInputCorrect){
        this.showSpinner = true;
        console.log('this.appModalData inside handleInit',JSON.stringify(this.appModalData))
        let filteredData = this.appModalData.filter(item => item.selectCheckbox === true );
        console.log('filteredData for case creation ', JSON.stringify(filteredData));
        
                let contact = '';
                filteredData.forEach(record => {
                    const selectListValue = record.selectList;
                    const matchingApp = record.appList.find(app => app.value === selectListValue);
                    if (matchingApp) {
                        record.contact = matchingApp.contact;
                    }
                    });
                    console.log('filteredData for case creation 2', JSON.stringify(filteredData));

        filteredData.forEach(item => {
            if(item.selectList === null || item.selectList === undefined){
                this.showToastMessage('Error', 'Please select Agency for LIP Initiation ', 'error', 'sticky');
            }
            else{
            let fields = {};
            fields['sobjectType'] = 'Case';
            fields['AccountId'] = item.selectList != null ? item.selectList : '';
            fields['ContactId'] = item.contact != null ? item.contact : '';
            fields['Applicant__c'] = item.appId != null ? item.appId : '';
            fields['ApplAddr__c'] = item.appAdrrsId != null ? item.appAdrrsId : '';
            fields['Loan_Application__c'] = item.loanAppId != null ? item.loanAppId : '';
            fields['Address_Line_1__c'] = item.appAddrLine1 != null ? item.appAddrLine1 : '';
            fields['Address_Line_2__c'] = item.appAddrLine2 != null ? item.appAddrLine2 : '';
            fields['Main_Applicant_Name__c'] = item.mainApp != null ? item.mainApp : '';
            fields['Product_Type__c'] = item.prodType != null ? item.prodType : '';

            fields['FlatNo__c'] = item.houseNo != null ? item.houseNo : '';
            fields['State__c'] = item.state != null ? item.state : '';
            
            fields['Pincode__c'] = item.pinCode != null ? item.pinCode : '';
            fields['Landmark__c'] = item.landMark != null ? item.landMark : '';
            fields['Area_of_Locality__c'] = item.locality != null ? item.locality : '';

            fields['Address_Type__c'] = item.appAddrType != null ? item.appAddrType : '';
            fields['Mobile_No__c'] = item.mobileNumber != null ? item.mobileNumber : '';
            fields['Phone_No__c'] = item.phoneNumber != null ? item.phoneNumber : '';
           // fields['CityId__c'] = item.cityId != null ? item.cityId : '';
            fields['City__c'] = item.addrCity != null ? item.addrCity : '';
            fields['RecordTypeId'] = this.cpvRecordTypeId;
            fields['Status'] = 'New';
            fields['Origin'] = 'Web';
            
            fields['Branch_Name__c'] =  this.branchName;
            fields['Branch_City__c'] =  this.branchCity;


            this.caseRecords.push(fields);
        }
        })
    //}
        console.log('caseRecords ', JSON.stringify(this.caseRecords));
        if(this.caseRecords && this.caseRecords.length>0){
            upsertMultipleRecord({ params: this.caseRecords })
            .then((result) => {

                const evt = new ShowToastEvent({
                    title: 'Success',
                    variant: 'success',
                    message: this.label.CpvVerf_Initiate_SuccessMessage,
                    mode: 'sticky'
                });
                this.caseRecords = [];
                this.appModalData.forEach(item => {
                    item['selectCheckbox'] = false;
                });
                this.dispatchEvent(evt);
                this.refreshDocTable();
                this.showSpinner = false;
                this.isModalOpen = false;
            })
            .catch((error) => {
                console.log('Error In creating Record', error);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: error.body.message,
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                this.showSpinner = false;
                this.isModalOpen = false;
                
            });
        }
        
        else{

            const evt = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'Please fill the required fields',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            this.showSpinner = false;
        }    

    }

  @track agcAvl;
  @track agencyData=[];
    getAgencyLocMapp(cityId,cityName,indexId) {
        let agencyType= 'LIP';
        console.log('loanappId in LIP component', this.loanAppId);
     //   if (this.locMstId && this.locMstId.length > 0) {
            let paramsLoanApp = {
                ParentObjectName: 'AgncLocMap__c',
                parentObjFields: ['Id', 'Name', 'LocationMaster__c','LocationMaster__r.City__c','Account__r.Name'],
                queryCriteria: ' where Account__c != null AND Contact__c != null AND LocationMaster__r.City__c =\''+cityName+'\' AND AgencyType__c =\''+agencyType+'\''
                // queryCriteria: ' where ApplType__c != null AND LoanAppln__c = \'' + this.loanAppId + '\''
                // queryCriteria: ` where LocationMaster__c IN ('${this.locMstId.join("','")}')`
            }
            getSobjectData({ params: paramsLoanApp })
                .then((result) => {
                    this.agencyData = result;
                    console.log('Agencies avl for location::::>#456',this.agencyData );
                    if(this.agencyData && this.agencyData.length>0){
                        this.agencyData.parentRecords.forEach(record => {
                            this.agencyOptions1.push({
                                label: record.Account__r.Name, // Use the Name field as the label
                                value: record.Account__r.Id    // Use the Id field as the value
                            });
                        });
                    }
              
                    console.log('this.agencyOptions1', JSON.stringify(this.agencyOptions1));

                    // if (result.parentRecords && result.parentRecords.length > 0) {
                    //   //  this.agcAvl=true;
                       
                    // }
                    // else{
                    //     if(this.appModalData[indexId]){
                    //         this.appModalData[indexId].selectCheckbox = true;
                    //     }
                    //    // this.agcAvl=false;
                    //     this.showToastMessage('Error', 'No Agency is available for '+cityName, 'error', 'sticky');
                    // }
                    if (result.error) {
                        console.error('appl result getting error=', result.error);
                    }
                    // return this.agcAvl;
                })
      //  }
    }

    validateForm() {
        let isValid = true;

        this.template.querySelectorAll("lightning-combobox").forEach((element) => {
          if (element.reportValidity()) {
          } else {
            isValid = false;
          }
        });
      
        this.template.querySelectorAll("lightning-input").forEach((element) => {
          if (element.reportValidity()) {
          } else {
            isValid = false;
          }
        });
        this.template.querySelectorAll("lightning-textarea").forEach((element) => {
          if (element.reportValidity()) {
          } else {
            isValid = false;
          }
        });
        return isValid;
      }

@track selectList=[]
getCoApplData(cityName){

      let agencyType= 'LIP';
      console.log('loanappId in LIP component', this.loanAppId);
   //   if (this.locMstId && this.locMstId.length > 0) {
          let paramsLoanApp = {
              ParentObjectName: 'AgncLocMap__c',
              parentObjFields: ['Id', 'Name', 'LocationMaster__c','LocationMaster__r.City__c','Account__r.Name','Contact__c'],
              queryCriteria: ' where Account__c != null AND Contact__c != null AND LocationMaster__r.City__c =\''+cityName+'\' AND AgencyType__c =\''+agencyType+'\''
              // queryCriteria: ' where ApplType__c != null AND LoanAppln__c = \'' + this.loanAppId + '\''
              // queryCriteria: ` where LocationMaster__c IN ('${this.locMstId.join("','")}')`
          }
    getSobjectData({ params: paramsLoanApp }).then((data) => {
        if (data) {
          let applList = [];
          if (data.parentRecords) {
            data.parentRecords.forEach((element) => {
                applList.push({
                label: element.Account__r.Name,
                value: element.Account__r.Id,
                cityNam: cityName,
                contact: element.Contact__c
              });
            });
        
         this.optionOfApp= applList;
         let tempArr=[...applList];
            tempArr.forEach(item=>{
               this.selectedValueList.push(item.value);
            })
            //this.getApplicaWithAddressDetails();
            console.log("co-applicant options while query #302", this.optionOfApp,applList);
          }
        } else if (error) {
          console.error("Error", error);
        }
      });
    }
    @track applAssetJnParams = {
        ParentObjectName: 'Applicant__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'ApplType__c', 'LoanAppln__c'],
        childObjFields: [],
        queryCriteria: ''
      }
    @track optionOfApp = [];
    @track selectedValueList = [];
    @track propOwnerSelectList = [];
    @track propOwners;

    handleSelectPropertOwners(event) {
      console.log("select property owners event detail ", event.detail);
      this.selectedValueList = event.detail;
    //   let ownName= this.selectedValueList.filter((item, 
    //     index) => this.selectedValueList.indexOf(item) === index); 
     
    //     this.propOwners = ownName.toString();
    //     console.log("select property owners event detail #457 ", this.propOwners);

    
    }

    branchName
    branchAddress
    branchCity
    getBranchDetails(){
        let branchParams = {
            ParentObjectName: "BankBrchMstr__c",
            ChildObjectRelName: "",
            parentObjFields: ["Id","Name","Address__c","BrchCode__c","City__c" ],
            childObjFields: [],
            queryCriteria: " where BrchCode__c = '" + this.branchCode + "' limit 1"
          };

          getSobjectDataNonCacheable({params: branchParams}).then((result) => {
            console.log('result.parentRecords',JSON.stringify(result.parentRecords ))
             if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
                this.branchName = result.parentRecords[0].Name?result.parentRecords[0].Name : '';
                this.branchAddress = result.parentRecords[0].Address__c?result.parentRecords[0].Address__c : '';
                this.branchCity = result.parentRecords[0].City__c?result.parentRecords[0].City__c : '';
             
             }
           })
           .catch((error) => {
             console.log("ERROR in 585#", error);
           });
    }
    branchCode;
    @track lanCity;
    fetchLoanDetails() {
        let assetParams = {
           ParentObjectName: "LoanAppl__c",
           ChildObjectRelName: "",
           parentObjFields: ["Id","AssesIncomeAppl__c","ReqLoanAmt__c","LoginAcceptDate__c","BrchCode__c","Stage__c","BrchName__c" ],
           childObjFields: [],
           queryCriteria: " where Id = '" + this.loanAppId + "' limit 1"
         };
    
    
    
         getSobjectDataNonCacheable({params: assetParams}).then((result) => {
            console.log('result.parentRecords',JSON.stringify(result.parentRecords ))
             if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
                    this.branchCode = result.parentRecords[0].BrchCode__c?result.parentRecords[0].BrchCode__c:'';
                    this.lanCity = result.parentRecords[0].BrchCode__c?result.parentRecords[0].BrchName__c:'';
                    console.log('branchCode',this.lanCity)
                    this.getBranchDetails();
                    if(result.parentRecords[0].Stage__c !== 'DDE' && result.parentRecords[0].Stage__c !== 'UnderWriting'){
                        this.disInitiate = true
                    }
                else if( result.parentRecords[0].ReqLoanAmt__c > this.label.LIP_Verification_Loan_Amount_Condition && this.hasEditAccess === true && result.parentRecords[0].LoginAcceptDate__c != undefined){
                    this.disInitiate = false
                }
                else{
                    this.disInitiate = true
                }
             
             }
           })
           .catch((error) => {
             console.log("ERROR in 585#", error);
           });
       }
  
   
    handleDeletedPillValue(event) {
        console.log('deleted property owner value', event.detail);
        //SELECT Id, Name, Appl__c, ApplAsset__c FROM ApplAssetJn__c where Appl__c = 'a0AC4000000KDAnMAO'
        let deletedApplValue = event.detail;
        this.applAssetJnParams.queryCriteria = " where Id = '" + deletedApplValue + "";
        console.log('query criteria for delete pill', this.applAssetJnParams.queryCriteria);
        getSobjectData({ params: this.applAssetJnParams })
          .then((result) => {
            console.log("result print ", result);
            if (result.parentRecords !== undefined) {
              let assetJnId = result.parentRecords[0].Id;
              console.log('junction object Id', assetJnId);
              deleteRecord(assetJnId)
                .then(() => {
                    console.log('deleted object Id', result);
               
                })
                .catch((error) => {
                  console.log(error);
                });
            }
    
          })
          .catch((error) => {
            console.error("Error", error);
          });
    
      }

      





@track metaList=[]

getMandatoryAddrMetaata(){
  
    let mandtAddrParams = {
        ParentObjectName: 'MandatoryAddrList__mdt',
        ChildObjectRelName: '',
        parentObjFields: ['Id','AddrType__c','TypeOfAppl__c', 'Constitution__c','CustProf__c'],
        childObjFields: [],
        queryCriteria: ''
      }
    getSobjectData({ params: mandtAddrParams }).then((data) => {
        if (data) {
            console.log("MANDATORY ADDR LIST CPV VERIFICATION #422", data);
          if (data.parentRecords) {
    
          this.metaList=data.parentRecords;
            console.log("MANDATORY ADDR LIST CPV #426", this.metaList);
          }
        } else if (error) {
          console.error("Error", error);
        }
      });
    }
    refreshDocTable() {
        this.showSpinner = false;
        let child = this.template.querySelector('c-lip-verification-data-table');
        child.getCaseData();
        //child.getWaivedCaseData();
    }

    fireCustomEvent(title, variant, message) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: variant,
            variant: message,
        });
        this.dispatchEvent(toastEvent);
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
}