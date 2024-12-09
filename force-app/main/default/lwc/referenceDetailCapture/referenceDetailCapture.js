import { LightningElement, api, track, wire } from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import deletebtLoanRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { subscribe, MessageContext, APPLICATION_SCOPE } from "lightning/messageService";
import CURRENTUSERID from '@salesforce/user/Id';

import { CPARoles } from 'c/globalConstant';

export default class ReferenceDetailCapture extends LightningElement {

    @api recordId;
    @api isReadOnly;
    @api hasEditAccess;
    @api product;
    @api loanAppId;
    @api layoutSize = {
        "large": "4",
        "medium": "6",
        "small": "12"
    }
    @track showSpinner = false;
    relationOpt = [
        { "label": "BUSINESS PARTNER", "value": "BUSINESS PARTNER" },
        { "label": "BUYER", "value": "BUYER" },
        { "label": "FRIEND", "value": "FRIEND" },
        { "label": "RELATIVE", "value": "RELATIVE" },
        { "label": "FAMILY MEMBER", "value": "FAMILY MEMBER" },
        { "label": "SUPPLIER", "value": "SUPPLIER" },
        { "label": "NEIGHBOUR", "value": "NEIGHBOUR" },
        { "label": "COLLEAGUE", "value": "COLLEAGUE" },
        { "label": "OTHER", "value": "OTHER" }
    ]
    get refRequired() {
        if (CPARoles && CPARoles.includes(this.userRole) || this.ConsentType == 'Digital Consent') {  //LAK-9244

            return true;
        }
        else {
            return false;

        }
    }
    saveSubscription = null;
    @wire(MessageContext)
    MessageContext;
    //select Id,  Loan_Application__c, Add__c,  Comments__c, ContactNo__c, FName__c, RelationWthApp__c, PrsnlDis__c, Title__c, OtherRelation__c  from Ref__c 
    @track refData = [
        { tempId: 1, title: 'Reference 1', FName__c: '', RelationWthApp__c: '', ContactNo__c: '', OtherRelation__c: '', Add__c: '', showDelete: false },
        { tempId: 2, title: 'Reference 2', FName__c: '', RelationWthApp__c: '', ContactNo__c: '', OtherRelation__c: '', Add__c: '', showDelete: false }];

    @track userRole;
    @track teamHierParam = {
        ParentObjectName: 'TeamHierarchy__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'EmpRole__c', 'Employee__c'],
        childObjFields: [],
        queryCriteria: ' where Employee__c = \'' + CURRENTUSERID + '\' limit 1'
    }
    @wire(getSobjectData, { params: '$teamHierParam' })
    teamHierHandler({ data, error }) {
        if (data) {
            console.log('DATA IN APPL RELOOK :::: #125>>>>', data);
            if (data.parentRecords !== undefined) {
                this.userRole = data.parentRecords[0].EmpRole__c
                console.log('DATA IN APPL RELOOK :::: #128>>>>', this.userRole);
            }

        }
        if (error) {
            console.error('ERROR APPL RELOOK:::::::#133', error)
        }
    }



    ConsentType;
    getApplicantDetails() {
        let applicantParam = {
            ParentObjectName: 'Applicant__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'ConsentType__c'],
            childObjFields: [],
            queryCriteria: ' where   ApplType__c = \'' + 'P' + '\' AND LoanAppln__c = \'' + this.loanAppId + '\' limit 1'
        }
        getSobjectDataNonCacheable({ params: applicantParam })
            .then((result) => {
                if (result.parentRecords !== undefined) {
                    this.ConsentType = result.parentRecords[0].ConsentType__c
                    console.log('DATA IN getApplicantDetails>>>>', this.ConsentType);
                }
            })
            .catch(error => {
                console.log("error in getApplicantDetails", error);
                this.showSpinner = false;
            })
    }


    get isDisabled() {

        return this.isReadOnly || !this.hasEditAccess;
    }
    connectedCallback() {
        console.log('in ReferenceCapture ==  ', this.hasEditAccess, this.isReadOnly, this.loanAppId);

        this.sunscribeToSaveMessageChannel();
        this.getReference();
        this.getApplicantDetails();
    }
    getReference() {
        let params = {
            ParentObjectName: 'Ref__c',
            parentObjFields: ["Id", "Loan_Application__c", "Add__c", "Comments__c", "ContactNo__c", "FName__c", "RelationWthApp__c", "PrsnlDis__c", "Title__c", "Landmark__c", "OtherRelation__c", "AddrLine1__c", "AddrLine2__c", "HouseNo__c", "City__c", "Pincode__c", "PinId__c", "CityId__c", "StateId__c", "State__c", "Locality__c"],
            queryCriteria: ' where Loan_Application__c = \'' + this.loanAppId + '\''
        };
        console.log(' ref data params = ', params);
        this.showSpinner = true;
        getSobjectDataNonCacheable({ params: params })
            .then((result) => {
                console.log(' ref data = ', result);
                if (result.parentRecords && result.parentRecords.length > 0) {
                    let res = JSON.parse(JSON.stringify(result.parentRecords))
                    console.log(' ref data 1= ', res);
                    this.refData = [];
                    let i = 1;
                    res.forEach(ele => {

                        ele['tempId'] = i;
                        ele['title'] = 'Reference ' + i;
                        ele['sobjectType'] = 'Ref__c';
                        if (ele.RelationWthApp__c === 'OTHER') {
                            ele['otherRelation'] = true;
                        }
                        console.log("refData I", i, this.refData);
                        if (i == 1 || i == 2) {
                            ele['showDelete'] = false;
                        } else {
                            ele['showDelete'] = true;
                        }
                        i++;

                        this.refData.push(ele);
                    });

                    //  this.refData = result.parentRecords;
                    console.log("refData I last", this.refData);


                }
                this.showSpinner = false;
            })
            .catch(error => {
                console.log("get applicantKyc error ", error);
                this.showSpinner = false;
            })
    }

    handleInputChangeRef(event) {
        let name = event.target.name;
        let value = event.target.value;
        let selectedRecordId = event.currentTarget.dataset.recordid;
        let resp = this.refData.find(rec => rec.tempId == selectedRecordId);
        resp[name] = value.toUpperCase();
        if (name === 'RelationWthApp__c') {
            if (value == 'OTHER') {
                resp['otherRelation'] = true;
            } else {
                resp['otherRelation'] = false;
                resp['OtherRelation__c'] = '';
            }

        }
    }
    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }
    sunscribeToSaveMessageChannel() {
        this.saveSubscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveLms(values)
        );
    }
    handleSaveLms(values) {
        console.log('this.draftvalues onclick of save ', values);
        if (values.validateBeforeSave) {
            let valid = this.checkValidation();
            if (valid) {
                if ((CPARoles && CPARoles.includes(this.userRole)) && this.refData.length < 2) {  //LAK-9244
                    this.showToast("Error", "error", 'At least two reference is mandatory');
                    return;
                } else {
                    this.saveReference();
                }

            } else {
                this.showToast("Error ", "error", 'Required field Missing');
                console.log('validation failed ');
            }
        }
        else {
            this.saveReference();
        }

    }
    checkValidation() {
        let isValid = true
        this.template.querySelectorAll('lightning-textarea').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed textarea');
            } else {
                isValid = false;
                console.log('element else--', element);
            }
        });
        this.template.querySelectorAll('lightning-combobox').forEach(element => {

            if (element.reportValidity()) {
                console.log('element passed lightning-combobox');
            } else {
                isValid = false;
                console.log('element else--', element);
            }
        });
        this.template.querySelectorAll('lightning-input').forEach(element => {

            if (element.reportValidity()) {
                console.log('element passed lightning-input');
            } else {
                isValid = false;
                console.log('element else--', element);
            }
        });

        return isValid;
    }
    saveReference() {
        // let param = this.refData;
        let param = this.refData.map(({ tempId, ...rest }) => rest);
        param = param.map(({ title, ...rest }) => rest);
        param = param.map(({ otherRelation, ...rest }) => rest);
        param = param.map(({ showDelete, ...rest }) => rest);
        console.log('saveReference before clean', param);
        const cleanedData = param.filter(item => {
            return Object.values(item).some(value => value !== "");
        });
        cleanedData.forEach(ele => {
            ele['Loan_Application__c'] = this.loanAppId;
            ele['sobjectType'] = 'Ref__c';

        });
        console.log('saveReference clean', cleanedData);
        //  this.saveSubscription.unsubscribe();
        upsertMultipleRecord({ params: cleanedData })
            .then((result) => {
                console.log(' upadated  result', result);
                this.showToast("Success", "success", ' Reference Details Added Successfully');
                this.getReference();
            })
            .catch((error) => {
                console.log('Error In creating Record', error);
            });

    }
    handleAddRef() {
        let size = this.refData.length + 1;
        let rec = { tempId: size, title: 'Reference ' + size, FName__c: '', RelationWthApp__c: '', ContactNo__c: '', OtherRelation__c: '', Add__c: '', Loan_Application__c: '', showDelete: true };
        this.refData.push(rec);
        console.log('after adding ', JSON.stringify(this.refData));


    }
    @track recordDelId;
    handleRemoveRef(event) {
        this.showDeleteConfirmation = true;

        let selectedRecordId = event.currentTarget.dataset.recordid;
        let resp = this.refData.find(rec => rec.tempId == selectedRecordId);
        if (resp.Id) {
            this.recordDelId = resp.Id
        } else {

            this.refData = this.refData.filter(obj => obj.tempId !== resp.tempId);
            let i = 0;
            this.refData.forEach(ele => {
                ele.tempId = i + 1;
                ele.title = 'Reference ' + (i + 1)
                i++;
            });
        }

        console.log('after removing ', JSON.stringify(this.refData));


    }

    @track showDeleteConfirmation = false;

    @track accessKeyForDeletion;


    hideModalBox() {
        this.showDeleteConfirmation = false;
    }

    handleConfirmDelete() {
        this.handleDeleteRecId(this.recordDelId);
        this.showDeleteConfirmation = false;
    }
    handleCancelDelete() {
        this.showDeleteConfirmation = false;
    }

    handleDeleteRecId(delRecId) {
        this.showSpinner = true;
        let fields = {};
        fields.Id = delRecId
        this.del_recIds = []
        this.del_recIds.push(fields)
        console.log("deleteRec_Array ", this.del_recIds);
        deletebtLoanRecord({ rcrds: this.del_recIds })
            .then((result) => {
                this.showToast("Success", "success", ' Reference Deleted ');
                this.recordDelId = '';

                this.showDeleteConfirmation = false;
                console.log('Reference Deleted ', result);
                this.getReference();
            })
            .catch((error) => {
                console.log('Error In Deleting Reference', error);
                this.showDeleteConfirmation = false;
                this.showSpinner = false;
            });
    }
    @track filterConditionState;
    @track filterConditionPin;
    @track lookupRec;
    @track
    pincodeParams = {
        ParentObjectName: 'PincodeMstr__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'City__r.City__c'],
        childObjFields: [],
        queryCriteria: ''//' where PIN__c = \'' + this.wrapAddressObj.Pincode__c + '\''
    }

    @track cityName

    searchPinCodeMasterRecord(add) {
        let pincode;
        if (add.isAppointee) {
            pincode = add.appointee.pincode;
        } else {
            pincode = add.pincode;
        }

        this.pincodeParams.queryCriteria = ' where PIN__c = \'' + pincode + '\''
        getSobjectData({ params: this.pincodeParams })
            .then((result) => {
                console.log('searchPinCodeMasterRecord O', add, result.parentRecords[0]);
                add.city = result.parentRecords[0].City__r.City__c;
                add.cityId = result.parentRecords[0].City__r.Id;
                console.log('searchPinCodeMasterRecord city', add, result.parentRecords[0]);
                // this.wrapAddressObj.City__c = this.cityName;
                // this.wrapAddressObj.CityId__c = result.parentRecords[0].City__r.Id;
                // this.wrapAddressObj.State__c = result.parentRecords[0].State__c;
                // this.wrapAddressObj.StateId__c = result.parentRecords[0].City__r.Id;

                this.searchCityNstate(add);
            })
            .catch((error) => {
                console.error('Error in line ##189', error)
            })
    }

    //parameter to find the City and State for pincode
    @track
    cityNstateParams = {
        ParentObjectName: 'LocMstr__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'City__c', 'State__c'],
        childObjFields: [],
        queryCriteria: ''// ' where City__c = \'' + this.cityName + '\''
    }


    searchCityNstate(add) {

        let city;

        city = add.city

        this.cityNstateParams.queryCriteria = ' where City__c = \'' + city + '\''
        getSobjectData({ params: this.cityNstateParams })
            .then((result) => {
                console.log('Line ##207', result)


                add.state = result.parentRecords[0].State__c
                add.stateId = result.parentRecords[0].Id;
                this.addressSelected = add;
                console.log('searchPinCodeMasterRecord state', result.parentRecords[0], this.addressSelected);
                console.log('record present  0', JSON.stringify(this.refData), JSON.stringify(this.addressSelected));
                let rec = this.refData.find(item => item.tempId == add.tempId);
                console.log('record present  1', JSON.stringify(rec));

                if (rec) {
                    rec['Pincode__c'] = add.pincode;
                    rec['PinId__c'] = add.pincodeId;
                    rec['City__c'] = add.city;
                    rec['CityId__c'] = add.cityId;
                    rec['State__c'] = add.state;
                    rec['StateId__c'] = add.stateId;
                }
                console.log('record present  final 2', JSON.stringify(rec));



            })
            .catch((error) => {
                console.error('Error in line ##185', error)
            })
        //this.searchstate(add);
    }
    @track
    addressObj = {
        tempId: null,
        pincode: '',
        pincodeId: '',
        city: '',
        cityId: '',
        state: '',
        stateId: ''
    };

    handleValueSelect(event) {
        let lookupRec = event.detail;
        let recId = event.target.dataset.recordid;
        let label = event.target.label;
        console.log('lookupRec', recId, lookupRec);
        if (label === 'City') {

        }
        if (label === 'State/UT') {

        }

        if (label === 'Pincode') {

            if (lookupRec.mainField) {
                let add = this.addressObj;
                add.tempId = recId;
                add.pincode = lookupRec.mainField;
                add.pincodeId = lookupRec.id;


                this.searchPinCodeMasterRecord(add);
            } else {
                let add = this.addressObj;
                add.tempId = recId;

                let rec = this.refData.find(item => item.tempId == add.tempId);
                console.log(' record present ', JSON.stringify(rec));

                if (rec) {
                    rec['Pincode__c'] = '';
                    rec['PinId__c'] = '';
                    rec['City__c'] = '';
                    rec['CityId__c'] = '';
                    rec['State__c'] = '';
                    rec['StateId__c'] = '';
                }
                console.log(' record present final ', JSON.stringify(rec));



            }
        }
    }
}