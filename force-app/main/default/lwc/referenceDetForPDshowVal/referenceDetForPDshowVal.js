import { LightningElement, api, track } from 'lwc';

export default class ReferenceDetForPDshowVal extends LightningElement {
    @api formConfig
    @api record;
    @api hasEditAccess;
    @api objectName;

    get isText() {
        return this.formConfig.type == "Text";
    }
    get isPhone() {
        return this.formConfig.type == "Phone";
    }
    get isTextarea() {
        return this.formConfig.type == "Textarea" || this.formConfig.type == "TextArea" || this.formConfig.type == "Text Area";
    }
    get isPicklist() {
        return this.formConfig.type == "Picklist";
    }
    get isNumber() {
        return this.formConfig.type == "Number";
    }
    get isDate() {
        return this.formConfig.type == "Date";
    }
    get pickListOptions() {
        let options = [];
        if (this.formConfig.options) {
            this.formConfig.options.forEach(obj => {
                let pickList = { label: obj, value: obj };
                options = [...options, pickList];
            })
        }
        options.sort(this.compareByLabel);
        return options;
    }
    get value() {
        if (this.record) {
            let val = this.record[this.formConfig.fieldName];
            if (val && (this.isText || this.isTextarea)) {
                return val.toUpperCase();
            } else {
                return val;
            }
        }
        return '';
    }
    get isDisabled() {
        if (this.hasEditAccess) {
            if (this.formConfig.editable) {
                return false;
            } else {
                return true;
            }
        } else {
            return true;
        }
    }
    @track isPatternPresent = false;
    get pattern() {
        if (this.formConfig.pattern) {
            this.isPatternPresent = true;
            return this.formConfig.pattern;
        }
        return '';
    }

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
    //{"label":"Full Name","fieldName":"FName__c","type":"Text","required":true,"editable":true}
    handleInputChange(event) {
        let name = event.target.name;
        let value = event.target.value;
        console.log('name = ', name, 'updated Value ', value);
        let param = { field: name, respVal: value, Id: this.record.Id, objectName: this.objectName }
        const selectEvent = new CustomEvent('passtoparent', {
            detail: param
        });
        this.dispatchEvent(selectEvent);
    }
    @api reportValidity() {
        let isValid = true
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed lightning input');
            } else {
                isValid = false;
            }
        });
        this.template.querySelectorAll('lightning-textarea').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed lightning input');
            } else {
                isValid = false;
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

}