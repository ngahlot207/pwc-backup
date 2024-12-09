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

import WAIVER_REASON from "@salesforce/schema/Case.WaiverReason__c";
// Custom labels
import CpvVerf_ReInitiate_SuccessMessage from '@salesforce/label/c.CpvVerf_ReInitiate_SuccessMessage';
import CpvVerf_Initiate_SuccessMessage from '@salesforce/label/c.CpvVerf_Initiate_SuccessMessage';
import CpvVerf_FileAccpt_ErrorMessage from '@salesforce/label/c.CpvVerf_FileAccpt_ErrorMessage';

export default class LIPDetails extends LightningElement {
    label = {
        CpvVerf_ReInitiate_SuccessMessage,
        CpvVerf_Initiate_SuccessMessage,
        CpvVerf_FileAccpt_ErrorMessage
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
                if (recordType.name === 'LIP_Vendor_case') {
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
                if (recordType.name === 'LIP_Vendor_case') {
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
        }else{
            this.disableMode = false;
        }
        this.getCaseStatus();
        //this.getCoApplData();
        this.getMandatoryAddrMetaata();

        // this.getApplicaWithAddressDetails();
    }

    getApplicaWithAddressDetails() {
        let paramsData = {
            ParentObjectName: 'Applicant__c',
            ChildObjectRelName: 'Applicant_Addresses__r',
            parentObjFields: ['Id', 'LoanAppln__c', 'TabName__c','FullName__c', 'MobNumber__c', 'PhoneNumber__c', 'Type_of_Borrower__c','ApplType__c','Constitution__c','CustProfile__c'],
            childObjFields: ['Id', 'AddrLine1__c', 'AddrLine2__c', 'AddrTyp__c', 'City__c', 'CityId__c'],
            queryCriteria: '  where LoanAppln__c = \'' + this.loanAppId + '\''
        }
        // queryCriteria: '  where Type_of_Borrower__c = \'' + this.typeOfBorrower + '\' AND LoanAppln__c = \'' + this.loanAppId + '\''
        getAllSobjectDatawithRelatedRecords({ params: paramsData })
            .then((result) => {
                this.appData = result;
                console.log('result is', JSON.stringify(result));
                //console.log('child Rcecord', JSON.stringify(result.ChildReords))
                if (this.appData) {
                    this.appData.forEach(item => {
                        if (item.parentRecord) {
                            if (item.ChildReords) {
                                console.log('child Rcecord' ,JSON.stringify(item.ChildReords) )
                                item.ChildReords.forEach(childitem => {
                                if(childitem.AddrTyp__c === 'Office Address'){
                                console.log('AddType',childitem.AddrTyp__c)
                                    let obj = {};
                                    obj.appId = item.parentRecord.Id;
                                    obj.loanAppId = this.loanAppId;
                                    obj.appName = item.parentRecord.FullName__c;
                                    obj.mobileNumber = item.parentRecord.MobNumber__c;
                                    obj.phoneNumber = item.parentRecord.PhoneNumber__c;
                                    obj.appAdrrsId = childitem.Id;
                                    obj.appAddrType = childitem.AddrTyp__c;
                                    obj.appAddrLine1 = childitem.AddrLine1__c;
                                    obj.appAddrLine2 = childitem.AddrLine2__c;
                                    obj.cityId = childitem.CityId__c;
                                    obj.addrCity = childitem.City__c;
                                    obj.selectCheckbox = false;
                                    obj.showWaiveRsn = true;
                                    if(obj.WaiveCPV__c===true){
                                        obj.showWaiveRsn = false;
                                    }
                                    
                                    let tempArr=[];
                                    let selectList=[]
                                    for(var i=0; i<this.optionOfApp.length;i++){
                                        if(item.parentRecord.FullName__c !== this.optionOfApp[i].value){
                                            tempArr.push(this.optionOfApp[i]);
                                        }
                                        
                                    }
                                                                   
                                    obj.appList=[...tempArr];

                                    tempArr.forEach(i=>{
                                        selectList.push(i.value) ;
                                     })
                                     obj.selectedList=[...selectList];

                                    if(this.metaList && this.metaList.length>0){
                                        this.metaList.forEach(m => {
                                                if((item.parentRecord.Type_of_Borrower__c=== m.TypeOfAppl__c && item.parentRecord.CustProfile__c=== m.CustProf__c 
                                                    && item.parentRecord.Constitution__c===m.Constitution__c && childitem.AddrTyp__c===m.AddrType__c) 
                                                   ) {
                                                    obj.mandtoryCheckbox=true;
                                                }
                                        })

                                        
                                    }
                                   

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
                    });
               
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
            queryCriteria: '   WHERE LoanAppln__c = \'' + this.loanAppId + '\''
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
                                if (childRecord.Status && childRecord.Status === 'New' && childRecord.RecordType.Name === 'LIP_Vendor_case') {
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
                this.getCoApplData();
               // this.getApplicaWithAddressDetails();
                if (result.error) {
                    console.error('appl result getting error=', result.error);
                }
            })
    }
    handleCpvIntialization() {

        this.isModalOpen = true;
        this.appModalData = [];
        this.getCaseStatus();
    }

    handleClick(event) {
        console.log('HANDLE CLICK IN CV ', JSON.stringify(event.target.dataset));
        let searchDoc = {};
        
        let val =event.target.checked;
        let applId = event.target.dataset.appid;
        let appAddreID = event.target.dataset.addressid;
        let cityId = event.target.dataset.cityid;
        let cityName = event.target.dataset.cityname;
        let indexId = event.target.dataset.index;
        console.log('val ', val, 'appId ', applId,'cityId',cityId,'cityName',cityName,'indexId',indexId);
        if (appAddreID) {
            console.log('appAddreID ', appAddreID);
            searchDoc = this.appModalData.find((doc) => doc.appAdrrsId === appAddreID);
        } else {
            searchDoc = this.appModalData.find((doc) => doc.appId === applId);
        }
        if (searchDoc && !searchDoc.isDisable) {
            console.log('searchDoc', JSON.stringify(searchDoc));
           
            if(event.target.dataset.label==='Initiate LIP'){
                searchDoc.selectCheckbox = val;
                searchDoc.WaiveCPV__c= !val;
                searchDoc.showWaiveRsn=val;
                this.getAgencyLocMapp(cityId,cityName,indexId);
                console.log('searchDoc #312', JSON.stringify(searchDoc));
                console.log('agcAvl :::::#312',this.agcAvl);
                searchDoc.reqWaiveRsn=false;
            }else if(event.target.dataset.label==='Waive CPV'){
                if(!val){
                    this.getAgencyLocMapp(cityId,cityName,indexId);
                }else{
                    searchDoc.selectCheckbox= !val;
                } 
               
                searchDoc.WaiveCPV__c= val;
                searchDoc.showWaiveRsn=!val;
                searchDoc.reqWaiveRsn=true;
            }else if(event.target.dataset.label==='Waiver Reason'){
                searchDoc.WaiverReason__c=event.target.value;
            }
            else if(event.target.dataset.label==='Remarks for agency'){
                searchDoc.Remarks_for_Technical_Agency__c=event.target.value.toUpperCase();
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
    let isInputCorrect = this.validateForm();
    if(isInputCorrect){
        this.showSpinner = true;
        console.log('this.appModalData',JSON.stringify(this.appModalData))
        let filteredData = this.appModalData.filter(item => item.selectCheckbox === true || item.WaiveCPV__c===true);
        console.log('filteredData for case creation ', JSON.stringify(filteredData));
        filteredData.forEach(item => {
            let fields = {};
            fields['sobjectType'] = 'Case';
            fields['Applicant__c'] = item.appId != null ? item.appId : '';
            fields['ApplAddr__c'] = item.appAdrrsId != null ? item.appAdrrsId : '';
            fields['Loan_Application__c'] = item.loanAppId != null ? item.loanAppId : '';
            fields['Address_Line_1__c'] = item.appAddrLine1 != null ? item.appAddrLine1 : '';
            fields['Address_Line_2__c'] = item.appAddrLine2 != null ? item.appAddrLine2 : '';
            fields['Address_Type__c'] = item.appAddrType != null ? item.appAddrType : '';
            fields['Mobile_No__c'] = item.mobileNumber != null ? item.mobileNumber : '';
            fields['Phone_No__c'] = item.phoneNumber != null ? item.phoneNumber : '';
           // fields['CityId__c'] = item.cityId != null ? item.cityId : '';
            fields['City__c'] = item.addrCity != null ? item.addrCity : '';
            fields['RecordTypeId'] = this.cpvRecordTypeId;
            fields['Status'] = 'New';
            fields['Origin'] = 'Web';
            if(item.mandtoryCheckbox){
                fields.IsMandatory__c= true;
            }
          
            if(this.selectedValueList && this.selectedValueList.length>0){
                let ownName= this.selectedValueList.filter((item, 
                    index) => this.selectedValueList.indexOf(item) === index); 
                 
                    this.propOwners = ownName.toString();
            }
       

        fields.Additional_Co_applicant_Guarantor_Name__c=this.propOwners ? this.propOwners : '';
        fields.Remarks_for_Technical_Agency__c=item.Remarks_for_Technical_Agency__c;

            if(item.WaiveCPV__c){
                fields['IsRouRobAllowd__c'] = false;
                fields['WaiveCPV__c'] = 'Yes';
                fields['WaiverReason__c'] = item.WaiverReason__c != null ? item.WaiverReason__c : '';
            }else{
                fields['IsRouRobAllowd__c'] = true;
                fields['WaiveCPV__c'] = 'No';
            }


            this.caseRecords.push(fields);
        })
    }
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
    getAgencyLocMapp(cityId,cityName,indexId) {
        let agencyType= 'CPVFI';
        console.log('loanappId in CPV component', this.loanAppId);
     //   if (this.locMstId && this.locMstId.length > 0) {
            let paramsLoanApp = {
                ParentObjectName: 'AgncLocMap__c',
                parentObjFields: ['Id', 'Name', 'LocationMaster__c','LocationMaster__r.City__c'],
                queryCriteria: ' where Account__c != null AND Contact__c != null AND LocationMaster__r.City__c =\''+cityName+'\' AND AgencyType__c =\''+agencyType+'\''
                // queryCriteria: ' where ApplType__c != null AND LoanAppln__c = \'' + this.loanAppId + '\''
                // queryCriteria: ` where LocationMaster__c IN ('${this.locMstId.join("','")}')`
            }
            getSobjectData({ params: paramsLoanApp })
                .then((result) => {
                    this.appData = result;
                    console.log('Agencies avl for location::::>#456', JSON.stringify(result));
                    if (result.parentRecords && result.parentRecords.length > 0) {
                      //  this.agcAvl=true;
                       
                    }
                    else{
                        this.appModalData[indexId].selectCheckbox = false;
                       // this.agcAvl=false;
                        this.showToastMessage('Error', 'No Agency is available for '+cityName, 'error', 'sticky');
                    }
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
getCoApplData(){
    let appType=['P','C','G'];
     let applParams = {
        ParentObjectName: 'Applicant__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id','TabName__c','ApplType__c','Constitution__c','CustProfile__c','FullName__c', 'LoanAppln__c'],
        childObjFields: [],
        queryCriteria: ' Where LoanAppln__c = \''+this.loanAppId +'\'  AND ApplType__c  IN (\''+appType.join('\', \'') + '\') order by ApplType__c '
      }
    getSobjectData({ params: applParams }).then((data) => {
        if (data) {
          let applList = [];
          if (data.parentRecords) {
            data.parentRecords.forEach((element) => {
                applList.push({
                label: element.TabName__c,
                value: element.FullName__c,
                selected: false
              });
            });
        
         this.optionOfApp= applList;
         let tempArr=[...applList];
            tempArr.forEach(item=>{
               this.selectedValueList.push(item.value);
            })
            this.getApplicaWithAddressDetails();
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
        let child = this.template.querySelector('c-cpv-data-table');
        child.getCaseData();
        child.getWaivedCaseData();
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