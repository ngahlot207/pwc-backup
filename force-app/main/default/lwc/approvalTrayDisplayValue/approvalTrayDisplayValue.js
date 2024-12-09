import { LightningElement, api, track } from 'lwc';

export default class ApprovalTrayDisplayValue extends LightningElement {
    @api object;
    @api fieldName;
    @api fieldValue;
    @api type = null;
    @api dedupeRsultsOptions = [];
    @api isReadOnly = false;
    @api indexValue;
    @api required;

    @track hasError = false;
    get options() {
        let arr;
        if (this.dedupeRsultsOptions) {
            arr = JSON.parse(JSON.stringify(this.dedupeRsultsOptions));
            if (this.fieldValue) {
                arr.forEach(item => {
                    if (item.value === this.fieldValue) {
                        item.selected = true;
                    } else {
                        item.selected = false;
                    }
                })
            } else {
                let obj = {
                    label: 'Please Choose...',
                    disabled: true,
                    selected: true,
                    hidden: true,
                    value: ''
                }
                let arra = [];
                arra.push(obj);
                arr = [...arra, ...arr];
            }
        }
        return arr;
    }

    get recordId() {
        return this.object['Id'];
    }
    get picklistValue() {
        return this.type == "picklist" ? true : false;
    }
    handleChange(event) {
        let val = event.target.value;
        let deduperRecordId = event.target.dataset.recordid;
        let nameVal = event.target.name;
        console.log('val is ', val, 'deduperRecordId is ', deduperRecordId, ' name is ', nameVal);

        let selectEvent = new CustomEvent('picklistchange', {
            detail: { recordid: deduperRecordId, val: val, nameVal: nameVal, index: this.indexValue, fieldName: this.fieldName }
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);

    }
    get formCls() {
        if (this.hasError) {
            return 'slds-form-element slds-has-error';
        } else {
            return 'slds-form-element';
        }
    }
    handleBlur(event) {
        if (event.target.value) {
            this.hasError = false;
        } else {
            this.hasError = true;
        }
    }
    @api reportValidity() {
        let isValid = true;
        this.template.querySelectorAll('select').forEach(element => {
            if (this.required) {
                if (this.fieldName == 'Appr_Actn__c') {
                    if (!this.fieldValue) {
                        this.hasError = true;
                        isValid = false;
                    } else {
                        this.hasError = false;
                    }
                }
            }
        });
        return isValid;
    }
}