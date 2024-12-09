/*
  HOTFIX
  LAK-6480:- GST Address spilt and staging to Finnone
  Developed By : Dhananjay Gadekar
*/

import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Apex methods
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";

export default class CaptureGSTAddressDetails extends LightningElement {
    @api addressDetailObj={};
    @api isGstRequired;
    @api tempArr;
    @api index;
    @track wrapGSTAddressObj = {};
    @api hasEditAccess;
    @api layoutSize;
    @track disableMode; 
    @track lookupRec;
    @track filterConditionState;
    @track filterConditionPin;
    @track paramsForApplAddress;
    @track cityName;
    @api localAddressvalue = {};

    //To set disable mode when user dont have edit permission on Application
    get disAddressFlag(){
        return this.disableMode
    }

    // To get Applicant Id from parent comp to child
    @track _applicantId;
    @api get applicantId() {
        return this.appId;
    }
    set applicantId(value) {
        this._applicantId = value;
        this.setAttribute("applicantId", value);
    }
    
    connectedCallback() { 
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        }
        else {
            this.disableMode = false;
        }
    }

    //To get address record id from parent comp to child
    @track _addressRecordId;
    @api get addressRecordId() {
        return this._addressRecordId;
    }
    set addressRecordId(value) {
        this.wrapGSTAddressObj = {City__c:'PUNE',State__c:'MAHARASHTRA',Pincode__c:'411041'};
        this._addressRecordId = value;
        this.setAttribute("addressRecordId", value);
        this.handleWiredAddressData();
    }
   
    //On the basis of Address record change, fetch & process address data to show on UI.
    handleWiredAddressData(){
        if(this._addressRecordId){
            this.paramsForApplAddress = {
                ParentObjectName: 'ApplAddr__c',
                ChildObjectRelName: '',
                parentObjFields: ['Id', 'City__c','AddrTyp__c', 'State__c', 'Pincode__c', 'AddrLine1__c', 'AddrLine2__c','GSTIndex__c', 'HouseNo__c','Landmark__c','Locality__c'],
                childObjFields: [],
                queryCriteria: ' where Id = \'' + this._addressRecordId + '\''
            }

            if(this._addressRecordId &&  this.paramsForApplAddress){
                getSobjectDataNonCacheable({ params: this.paramsForApplAddress })
                    .then(result => {           
                            if (result && result.parentRecords && result.parentRecords.length > 0) {  
                                    const addressData = result.parentRecords;
                                    const foundAddress = addressData.find(item => item.Id === this._addressRecordId);
                                    if (foundAddress) {
                                        if(this.tempArr && this.tempArr.length > 0){   
                                            const matchingRecord = this.tempArr.find(record => record.typeofaddress === foundAddress.AddrTyp__c && this.index == record.index);                                    
                                            if (matchingRecord) {
                                                this.wrapGSTAddressObj = { ...foundAddress, AddrTyp__c: matchingRecord.typeofaddress, GSTIndex__c: matchingRecord.index };
                                                this.addressDetailObj = { ...this.wrapGSTAddressObj };
                                            }
                                        }      
                                    }
                    
                            } else {
                                
                            }
                        
                    }).catch(error => {
                        console.log('Adddress Data error------------>',JSON.stringify(error));
                    })
                }

        }else{
            let tempEmptyObj2=[];
            if(this.tempArr && this.tempArr.length > 0){    
                this.tempArr.forEach(item => {     
                        if(item.index == this.index){
                            if(item.typeofaddress == 'GST Address'){
                                this.wrapGSTAddressObj = {...tempEmptyObj2};     
                            }else{
                                this.wrapGSTAddressObj = {...tempEmptyObj2, AddrTyp__c:item.typeofaddress, GSTIndex__c:this.index};
                                this.addressDetailObj = {...this.wrapGSTAddressObj};
                            }                      
                        }                           
                })
            } 
        }

       
        
    }
  
    //To capture latest changes on UI from user
    inputChangeHandler(event) {

        const { objectname, fieldname } = event.currentTarget.dataset;

        if(event.target.dataset.type === 'string'){
            let strVal = event.target.value;
            this.wrapGSTAddressObj[fieldname] = strVal.toUpperCase();
        }else{
            this.wrapGSTAddressObj[fieldname] = event.target.value;
        }
      
        this.tempArr.forEach(item => {
            if(item.index == this.index){
                this.wrapGSTAddressObj = {...this.wrapGSTAddressObj, AddrTyp__c:item.typeofaddress, GSTIndex__c:this.index};
                this.addressDetailObj = {...this.wrapGSTAddressObj};
            }
        })
      
        this.debouncedInputChange(this.addressDetailObj); 
      
    }

    //To fire custom event to parent with the latest address details.
    debouncedInputChange(updatedAddrData) {
        setTimeout(() => {
         this.dispatchEvent(new CustomEvent('handle', {
            detail: updatedAddrData
        }))
        }, 500);     
    }

    //To handle custom lookup field changes on UI.
    handleValueSelect(event) {
        this.lookupRec = event.detail;
        if (event.target.label === 'City') {
            this.wrapGSTAddressObj.City__c = this.lookupRec.mainField;
            this.wrapGSTAddressObj.CityId__c = this.lookupRec.id;
            this.filterConditionState = 'City__c = ' + "'" + this.wrapGSTAddressObj.City__c + "' " + 'LIMIT 1';
            this.filterConditionPin = 'City__r.City__c = ' + "'" + this.wrapGSTAddressObj.City__c + "' ";
            this.searchstate()
        }
        if (event.target.label === 'State/UT') {
            this.wrapGSTAddressObj.State__c = this.lookupRec.mainField;
            this.wrapGSTAddressObj.StateId__c = this.lookupRec.id;
        }
     
        if (event.target.label === 'Pincode') {
            this.wrapGSTAddressObj.Pincode__c = this.lookupRec.mainField;
            this.wrapGSTAddressObj.PinId__c = this.lookupRec.id;
            this.searchPinCodeMasterRecord()
        }

        this.tempArr.forEach(item => {
            if(item.index == this.index){
                this.wrapGSTAddressObj = {...this.wrapGSTAddressObj, AddrTyp__c:item.typeofaddress, GSTIndex__c:this.index};
                this.addressDetailObj = {...this.wrapGSTAddressObj};
            }
        })

        this.debouncedInputChange(this.addressDetailObj); 
       
    }

 
    @track
    pincodeParams = {
        ParentObjectName: 'PincodeMstr__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'City__r.City__c'],
        childObjFields: [],
        queryCriteria: ' where PIN__c = \'' + this.wrapGSTAddressObj.Pincode__c + '\''
    }

  
    //To search pincode from Pincode Master and populate on UI
    searchPinCodeMasterRecord() {
        this.pincodeParams.queryCriteria = ' where PIN__c = \'' + this.wrapGSTAddressObj.Pincode__c + '\''
        getSobjectData({ params: this.pincodeParams })
            .then((result) => {
                if(result && result.parentRecords && result.parentRecords.length > 0){
                    this.cityName = result.parentRecords[0].City__r.City__c ? result.parentRecords[0].City__r.City__c : null;
                    this.wrapGSTAddressObj.City__c = this.cityName;
                    this.wrapGSTAddressObj.CityId__c = result.parentRecords[0].City__r.Id ? result.parentRecords[0].City__r.Id : null;
                    //this.wrapGSTAddressObj.State__c = result.parentRecords[0].State__c ? result.parentRecords[0].State__c : null;
                    //this.wrapGSTAddressObj.StateId__c = result.parentRecords[0].City__r.Id ? result.parentRecords[0].City__r.Id : null;
                    this.searchCityNstate();
                }
              
            })
            .catch((error) => {
                console.log('Error in searchPinCodeMasterRecord Method', JSON.stringify(error))
            })
    }

    @track
    cityNstateParams = {
        ParentObjectName: 'LocMstr__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'City__c', 'State__c'],
        childObjFields: [],
        queryCriteria: ' where City__c = \'' + this.cityName + '\''
    }

    //To search City & State from Location Master and populate on UI.
    searchCityNstate() {
        this.cityNstateParams.queryCriteria = ' where City__c = \'' + this.cityName + '\''
        getSobjectData({ params: this.cityNstateParams })
            .then((result) => {
                if(result && result.parentRecords && result.parentRecords.length > 0){
                    this.wrapGSTAddressObj.City__c = result.parentRecords[0].City__c ? result.parentRecords[0].City__c : null;
                    this.wrapGSTAddressObj.State__c = result.parentRecords[0].State__c ? result.parentRecords[0].State__c : null;
                    // this.wrapGSTAddressObj.CityId__c = result.parentRecords[0].City__r.Id ? result.parentRecords[0].City__r.Id : null;
                    // this.wrapGSTAddressObj.StateId__c = result.parentRecords[0].City__r.Id ? result.parentRecords[0].City__r.Id : null;
                }    

            })
            .catch((error) => {
                console.log('Error in searchCityNstate Method', JSON.stringify(error))
            })
        this.searchstate();
    }

    @track
    cityParams = {
        ParentObjectName: 'LocMstr__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'State__c'],
        childObjFields: [],
        queryCriteria: ' where City__c = \'' + this.wrapGSTAddressObj.City__c + '\''
    }

    //To search State from Location Master and populate on UI.
    searchstate() {
        this.cityParams.queryCriteria = ' where City__c = \'' + this.cityName + '\''
        getSobjectData({ params: this.cityParams })
            .then((result) => {
                if(result && result.parentRecords && result.parentRecords.length > 0){
                this.wrapGSTAddressObj.StateId__c = result.parentRecords[0].Id ? result.parentRecords[0].Id : null;
                this.wrapGSTAddressObj.State__c = result.parentRecords[0].State__c ? result.parentRecords[0].State__c : null;
            }
            })
            .catch((error) => {
                console.log('Error in searchstate Method', JSON.stringify(error))
            })

    }

    //To validate user inputs as per requirement or not.
    @api validateForm(){
        var isInputCorrect = [
            ...this.template.querySelectorAll("lightning-input"),
            ...this.template.querySelectorAll("lightning-combobox")
        ].reduce((validSoFar, inputField) => {

            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        if (!this.checkCustomLookupValidity()) {
            isInputCorrect = false;
        }

        console.log('Is child details validated', isInputCorrect);
        return isInputCorrect;
    }

    //To validate custom lookup fieldsm data.
    checkCustomLookupValidity() {
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

    //To send address details to save in parent component
    @api handleUpsert(){
        this.localAddressvalue = {...this.wrapGSTAddressObj};
    }


    showToastMessage(title, message, variant, mode) {
        const evt = new ShowToastEvent({ title, message, variant, mode });
        this.dispatchEvent(evt);
    }

    // To update same address type record details getting data from parent after filteration
    @api updateChildData(updatedData){
        this.wrapGSTAddressObj = {...updatedData};
        this.searchPinCodeMasterRecord();
    }
   
}