import { LightningElement, wire, api, track } from 'lwc';
import APPLICANT_ADD_OBJECT from '@salesforce/schema/ApplAddr__c';
import { getPicklistValues, getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';

// Custom labels
import ApplicantAddress_Format_ErrorMessage from '@salesforce/label/c.ApplicantCapture_Format_ErrorMessage';

//Apex methods
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';

//Loan Application
import LOAN_APPL_STAGE from '@salesforce/schema/LoanAppl__c.Stage__c';
import { getRecord, deleteRecord } from 'lightning/uiRecordApi';

//JS file to trim string inputs
import { trimFunction } from 'c/reusableStringTrimComp';

export default class CaptureApplicantAddressDetails extends LightningElement {

    label = { ApplicantAddress_Format_ErrorMessage }

    messageMismatchError = this.label.ApplicantAddress_Format_ErrorMessage

    @api loanAppId;
    @api hasEditAccess;
    @api hideMailAddr = false;
    @track disableMode; 
    @track lookupRec;
    @track filterConditionState;
    @track filterConditionPin;
    @track wrapAddressObj = {}
    @api layoutSize;
    @api isRequired = false;
    @api isNotRequired = false;
    @api isRequiredCheck = false;
    @api addTypeSection;
    @api consentType
    @api productType

    @track cautionAreaOptions = [];

    @api disableflag;

    get requiredCheck(){
       if(this.addTypeSection && this.addTypeSection === 'Office Address') return false
       else return true
    }

    // reqCheck(){
    //     let reqFlag = false;
    //     if(!this.isRequiredCheck && this.addType === 'Office Address'){
    //         reqFlag = this.isRequiredCheck;
    //     }else if(this.isRequired){
    //         reqFlag = this.isRequired;
    //     }
    //     return reqFlag;
    // }

    get disAddressFlag(){
        return this.disableflag || this.disableMode
    }

    @api
    get childData() {
        return this.wrapAddressObj
    }

    set childData(value) {
        this.setAttribute('childData', value);
        this.wrapAddressObj = { ...value, HouseNo__c: value.HouseNo__c ? value.HouseNo__c.toUpperCase() : '', AddrLine1__c: value.AddrLine1__c ? value.AddrLine1__c.toUpperCase() : '', AddrLine2__c: value.AddrLine2__c ? value.AddrLine2__c.toUpperCase() : '', Landmark__c: value.Landmark__c ? value.Landmark__c.toUpperCase() : '', Locality__c: value.Locality__c ? value.Locality__c.toUpperCase() : ''};
        if (this.wrapAddressObj && Object.keys(this.wrapAddressObj).includes('DisFrmSrcBrnh__c')) {
            if (typeof this.wrapAddressObj.DisFrmSrcBrnh__c === 'number') {
                this.wrapAddressObj.DisFrmSrcBrnh__c = this.wrapAddressObj.DisFrmSrcBrnh__c;
            }
        }
        if (this.wrapAddressObj && Object.keys(this.wrapAddressObj).includes('DisFrmFFBrnh__c')) {
            if (typeof this.wrapAddressObj.DisFrmFFBrnh__c === 'number') {
                this.wrapAddressObj.DisFrmFFBrnh__c = this.wrapAddressObj.DisFrmFFBrnh__c;
            }
        }
        if (this.wrapAddressObj && Object.keys(this.wrapAddressObj).includes('AddrStability__c')) {
            if (typeof this.wrapAddressObj.AddrStability__c === 'number') {
                this.wrapAddressObj.AddrStability__c = this.wrapAddressObj.AddrStability__c;
            }
        }
        console.log('Data in cheild!! ' + (this.wrapAddressObj.MailAddr__c === 'true'));
    }

    get isLocationLocalityReq() {
        debugger
        if (this.StagePickVal === 'QDE' &&
            this.consentType === 'Digital Consent' &&
            (this.productType === 'Personal Loan' || this.productType === 'Business Loan')) {
            return true;
        } else if (this.StagePickVal === 'QDE' &&
                   this.consentType === 'Physical Consent Upload' &&
                   (this.productType === 'Personal Loan' || this.productType === 'Business Loan')) {
            return false;
        } 
        else {
            return false
        }
    }


    @track isRequiredCautionArea;
    @track visibltyNegCautionArea;
    @wire(getRecord, { recordId: '$loanAppId', fields: [LOAN_APPL_STAGE] })
    StagePicklistValue({ data, error }) {
        if (data) {
            //console.log('StageValue',data)
            this.StagePickVal = data.fields.Stage__c.value;
            console.log('StagePickVal', this.StagePickVal);
            if (this.StagePickVal !== 'DDE') {
                this.isRequiredCautionArea = true;
            } else {
                this.isRequiredCautionArea = false;
            }
            if (this.StagePickVal !== 'QDE') {
                this.visibltyNegCautionArea = true;
            } else {
                this.visibltyNegCautionArea = false;
            }
        }
    }

    //array properties
    ownershipTypeOptions = []

    //generate picklist from values 
    generatePicklist(data) {
        return data.values.map(item => ({ "label": item.label, "value": item.value }))
    }

    //wire methods

    @wire(getObjectInfo, { objectApiName: APPLICANT_ADD_OBJECT })
    objectInfo

    @wire(getPicklistValuesByRecordType, {
        objectApiName: APPLICANT_ADD_OBJECT,
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    })
    picklistHandler({ data, error }) {
        if (data) {
            console.log(data)
            this.ownershipTypeOptions = [...this.generatePicklist(data.picklistFieldValues.OwnType__c)]
            this.cautionAreaOptions = [...this.generatePicklist(data.picklistFieldValues.Negative_Caution_Area__c)]
        }
        if (error) {
            console.error(error)
        }
    }

    connectedCallback() {
        console.log('child connected callback', JSON.stringify(this.wrapAddressObj))
        if (this.hasEditAccess === false) {
            this.disableMode = true;
            console.log('this.hasEditAccess disabele>::::::::', this.disableMode, 'in epplyment dddd');
        }
        else {
            this.disableMode = false;

        }
    }

    handleFocus(event) {
        let fieldName = event.target.dataset.fieldname;
        if (fieldName === 'AddrStability__c') {
            if (this.wrapAddressObj[fieldName] && this.wrapAddressObj[fieldName].endsWith('Y')) {
                this.wrapAddressObj[fieldName] = this.wrapAddressObj[fieldName].substring(0, this.wrapAddressObj[fieldName].length - 2);
            }
        }
        else {
            if (this.wrapAddressObj[fieldName] && this.wrapAddressObj[fieldName].endsWith('KM')) {
                this.wrapAddressObj[fieldName] = this.wrapAddressObj[fieldName].substring(0, this.wrapAddressObj[fieldName].length - 3);
            }
        } 

    }

    handleBlur(event) {
        let fieldName = event.target.dataset.fieldname;

        if (fieldName === 'AddrStability__c') {
            if (this.wrapAddressObj[fieldName] && !this.wrapAddressObj[fieldName].endsWith('Y')) {
                this.wrapAddressObj[fieldName] += ' Y';

            }
        }
        else {
            if (this.wrapAddressObj[fieldName] && !this.wrapAddressObj[fieldName].endsWith('KM')) {
                this.wrapAddressObj[fieldName] += ' KM';
            }
        }
    }

    blurHandler(event){
        if(event.target.dataset.type === 'string'){
            let strVal = event.target.value;
            this.wrapAddressObj[event.target.dataset.fieldname] = trimFunction(strVal)
        }
    }

    //Mailing Address Checkebox
    inputChangeHandler(event) {
        const { objectname, fieldname } = event.currentTarget.dataset
        if(event.target.dataset.type === 'string'){
            let strVal = event.target.value;
            this.wrapAddressObj[fieldname] = strVal.toUpperCase();
        }else{
            this.wrapAddressObj[fieldname] = event.target.value;
        }
        if (event.target.dataset.fieldname === 'MailAddr__c') {
            this.wrapAddressObj.MailAddr__c = event.target.checked ? true : false; 
        }
        console.log('selected', JSON.stringify(this.wrapAddressObj))
        this.dispatchEvent(new CustomEvent('handle', {
            detail: this.wrapAddressObj
        })) 
        if (event.target.dataset.fieldname === 'MailAddr__c') {
            if (event.target.checked) {
                //this.wrapAddressObj.MailAddr__c = true
                console.log('Mailing Address Checkebox checked on chhild cmp &&&&', this.wrapAddressObj.MailAddr__c)
                this.dispatchEvent(new CustomEvent('mailaddcheck', {
                    detail: "true"
                }))
            } else {
                //this.wrapAddressObj.MailAddr__c= false
                console.log('Mailing Address Checkebox unchecked on chhild cmp &&&&', this.wrapAddressObj.MailAddr__c)
                this.dispatchEvent(new CustomEvent('mailaddcheck', {
                    detail: "false"
                }))
            }
        }
    }

    handleValueSelect(event) {
        this.lookupRec = event.detail;
        if (event.target.label === 'City') {
            this.wrapAddressObj.City__c = this.lookupRec.mainField;
            this.wrapAddressObj.CityId__c = this.lookupRec.id;
            console.log('selected city -', this.wrapAddressObj.City__c)
            this.filterConditionState = 'City__c = ' + "'" + this.wrapAddressObj.City__c + "' " + 'LIMIT 1';
            this.filterConditionPin = 'City__r.City__c = ' + "'" + this.wrapAddressObj.City__c + "' ";
            this.searchstate()
        }
        if (event.target.label === 'State/UT') {
            this.wrapAddressObj.State__c = this.lookupRec.mainField;
            this.wrapAddressObj.StateId__c = this.lookupRec.id;
            console.log('selected state -', this.wrapAddressObj.State__c)
        }
        if (event.target.label === 'Nearest Fedfina Branch') {
            console.log('this.lookupRec',this.lookupRec);
            this.wrapAddressObj.Nearest_Fedfina_Branch__c = this.lookupRec.mainField;
            this.wrapAddressObj.NearestFedBrnchID__c = this.lookupRec.id;
            console.log('selected state -', this.wrapAddressObj.Nearest_Fedfina_Branch__c,this.wrapAddressObj.NearestFedBrnchID__c);
            this.dispatchEvent(new CustomEvent('handle', {
                detail: this.wrapAddressObj
            }))
        }
        if (event.target.label === 'Pincode') {
            this.wrapAddressObj.Pincode__c = this.lookupRec.mainField;
            this.wrapAddressObj.PinId__c = this.lookupRec.id;
            console.log('selected pincode -', this.wrapAddressObj.Pincode__c,this.wrapAddressObj.PinId__c)
            this.searchPinCodeMasterRecord()
        }

        this.dispatchEvent(new CustomEvent('handle', {
            detail: this.wrapAddressObj
        }))
    }

    checkValidityLookup() {
        let isInputCorrect = true;
        let allChilds = this.template.querySelectorAll("c-custom-lookup");
        console.log("custom lookup allChilds>>>", allChilds);
        allChilds.forEach((child) => {
            console.log("custom lookup child>>>", child);
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
        return isInputCorrect;
    }

    @api
    validateForm() {
        let isValid = true
        if (!this.checkValidityLookup()) {
            isValid = false;
        }

        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed combobox');
                console.log('element if--' + element.value);
            } else {
                isValid = false;
                console.log('element else--' + element.value);
            }
        });

        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed lightning input');
            } else {
                isValid = false;
            }
        });
        return isValid;
    }

    //parameter to find the pincode master record
    @track
    pincodeParams = {
        ParentObjectName: 'PincodeMstr__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'City__r.City__c','City__r.State__c'],
        childObjFields: [],
        queryCriteria: ' where PIN__c = \'' + this.wrapAddressObj.Pincode__c + '\''
    }

    @track cityName

    searchPinCodeMasterRecord() {
        this.pincodeParams.queryCriteria = ' where PIN__c = \'' + this.wrapAddressObj.Pincode__c + '\''
        getSobjectData({ params: this.pincodeParams })
            .then((result) => {
                console.log('Line ##320', result)
                this.cityName = result.parentRecords[0].City__r.City__c
                this.wrapAddressObj.City__c = this.cityName;
                this.wrapAddressObj.CityId__c = result.parentRecords[0].City__r.Id;
                this.wrapAddressObj.State__c = result.parentRecords[0].City__r.State__c;
                this.wrapAddressObj.StateId__c = result.parentRecords[0].City__r.Id;
                this.dispatchEvent(new CustomEvent('handle', {
                    detail: this.wrapAddressObj
                }))
                //this.searchCityNstate();
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
        queryCriteria: ' where City__c = \'' + this.cityName + '\''
    }


    searchCityNstate() {
        this.cityNstateParams.queryCriteria = ' where City__c = \'' + this.cityName + '\''
        getSobjectData({ params: this.cityNstateParams })
            .then((result) => {
                console.log('Line ##207', result)
                this.wrapAddressObj.City__c = result.parentRecords[0].City__c;
                this.wrapAddressObj.State__c = result.parentRecords[0].State__c;
                this.wrapAddressObj.CityId__c = result.parentRecords[0].Id;
                this.wrapAddressObj.StateId__c = result.parentRecords[0].Id;
                this.dispatchEvent(new CustomEvent('handle', {
                    detail: this.wrapAddressObj
                }))
            })
            .catch((error) => {
                console.error('Error in line ##185', error)
            })
        //this.searchstate();
    }

    //parameter to find the State for City
    @track
    cityParams = {
        ParentObjectName: 'LocMstr__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'State__c'],
        childObjFields: [],
        queryCriteria: ' where City__c = \'' + this.wrapAddressObj.City__c + '\''
    }

    searchstate() {
        this.cityParams.queryCriteria = ' where City__c = \'' + this.cityName + '\''
        getSobjectData({ params: this.cityParams })
            .then((result) => {
                console.log('Line ##235', result)
                this.wrapAddressObj.StateId__c = result.parentRecords[0].Id;
                this.wrapAddressObj.State__c = result.parentRecords[0].State__c;
                this.dispatchEvent(new CustomEvent('handle', {
                    detail: this.wrapAddressObj
                }))

            })
            .catch((error) => {
                console.error('Error in line ##236', error)
            })

    }

    


}