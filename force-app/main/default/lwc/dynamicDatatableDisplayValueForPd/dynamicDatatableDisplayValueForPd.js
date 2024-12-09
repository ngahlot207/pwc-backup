import { LightningElement, api, track } from 'lwc';

export default class DynamicDatatableDisplayValueForPd extends LightningElement {
    // @api object; 
    @api tableConfig;
    //{"id":1,"label":"Type","fieldName":"IncomeType__c","type":"Picklist","Editable":true,"value":"Agricultural Income","options":["Agricultural Income","Bank Credit Salary","Cash Salary","Cashflow Map","Pension Income","Other Income"]}
    // @api type = null;
    // @api editable = false;;
    // @api label = '';
    @api tableaData;//{"Id":"a0oC40000007FwpIAE","Applicant_Income__c":"012C4000000XwWfIAK"}

    @api hasEditAccess;

    get fieldValue() {
        let val = this.tableaData[this.tableConfig.fieldName];
        if (val && (this.stringBoolean || this.emailBooelan || this.stringTextArea)) {
            return val.toUpperCase();
        }
        return val;

    }

    get recordId() {
        return this.tableaData['Id'];
    }

    get isReadOnly() {
        if (this.hasEditAccess) {
            return false;
        } else {
            return true;
        }
    }
    get isRequired() {
        if (this.tableConfig.required) {
            return true;
        } else {
            return false;
        }
    }
    get stringBoolean() {
        // return this.tsbleConfig.type == "Text" ? true : false;
        if (this.tableConfig.type && this.tableConfig.type == "Text") {
            return true;
        } else {
            return false;
        }
        // return this.tableConfig.type == "Text" && !this.tableConfig.type ? true : false;
    }
    get mobileBoolean() {
        // return this.tsbleConfig.type == "Text" ? true : false;
        if (this.tableConfig.type && this.tableConfig.type == "Mobile") {
            return true;
        } else {
            return false;
        }
        // return this.tableConfig.type == "Text" && !this.tableConfig.type ? true : false;
    }

    get stringCurrency() {
        // return this.tsbleConfig.type == "Text" ? true : false;
        if (this.tableConfig.type && this.tableConfig.type == "Currency") {
            return true;
        } else {
            return false;
        }
        // return this.tableConfig.type == "Text" && !this.tableConfig.type ? true : false;
    }


    get numberBoolean() {
        //  return this.tableConfig.type == "Number" ? true : false;
        if (this.tableConfig.type && (this.tableConfig.type == "Number")) {
            return true;
        } else {
            return false;
        }

        //  return this.tableConfig.type == "Number" && !this.tableConfig.type ? true : false;
    }

    get urlBoolean() {
        // return this.type == "url" ? true : false;
        if (this.tableConfig.type && this.tableConfig.type == "Url") {
            return true;
        } else {
            return false;
        }
        //  return this.tableConfig.type == "Url" && !this.tableConfig.type ? true : false;
    }
    get phoneBoolean() {
        // return this.type == "phone" ? true : false;
        if (this.tableConfig.type && this.tableConfig.type == "Phone") {
            return true;
        } else {
            return false;
        }
        //  return this.tableConfig.type == "Phone" && !this.tableConfig.type ? true : false;
    }
    get datetimeBoolean() {
        //    return this.type == "Date" ? true : false;
        //  return this.tableConfig.type == "Date" && !this.tableConfig.type ? true : false;
        if (this.tableConfig.type && this.tableConfig.type == "Date") {
            return true;
        } else {
            return false;
        }
    }

    get stringTextArea() {
        //    return this.type == "Date" ? true : false;
        //  return this.tableConfig.type == "Date" && !this.tableConfig.type ? true : false;
        if (this.tableConfig.type && (this.tableConfig.type == "TextArea" || this.tableConfig.type == "Textarea" || this.tableConfig.type == "Text Area")) {
            return true;
        } else {
            return false;
        }
    }
    get minimumVal() {
        //    return this.type == "Date" ? true : false;
        //  return this.tableConfig.type == "Date" && !this.tableConfig.type ? true : false;
        if (this.tableConfig.min) {
            return this.tableConfig.min;
        } else {
            return '';
        }
    }
    get maximumVal() {
        //    return this.type == "Date" ? true : false;
        //  return this.tableConfig.type == "Date" && !this.tableConfig.type ? true : false;
        if (this.tableConfig.max) {
            return this.tableConfig.max;
        } else {
            return '';
        }
    }
    get pattern() {
        //    return this.type == "Date" ? true : false;
        //  return this.tableConfig.type == "Date" && !this.tableConfig.type ? true : false;
        if (this.tableConfig.pattern) {
            return this.tableConfig.pattern;
        } else {
            return '';
        }
    }

    // get emailBooelan() {
    //     return this.type == "Email" ? true : false;
    // }
    // get nullBoolean() {
    //     return this.type == null ? true : false;
    // }
    // //|| this.type == "boolean"
    // get editBoolean() {
    //     return this.type == "boolean" && this.editable ? true : false;
    // }
    // get readBoolean() {
    //     return this.type == "boolean" && !this.editable ? true : false;
    // }
    get comboboxBoolean() {

        console.log('child table :::', this.tableConfig.type);
        if (this.tableConfig.type && this.tableConfig.type == "Picklist") {
            return true;
        } else {
            return false;
        }
        //  return this.tableConfig.type == "Picklist" && !this.tableConfig.type ? true : false;
    }
    get options() {
        let opt = [];
        if (this.tableConfig.type && this.tableConfig.type == "Picklist" && this.tableConfig.options && this.tableConfig.options.length) {
            this.tableConfig.options.forEach(element => {
                let op = { label: element, value: element }

                if (op.value == this.fieldValue) {
                    op.selected = true;
                } else {
                    op.selected = false;
                }
                opt.push(op);
            });
        }

        console.log('child table  options :::', opt);
        opt.sort(this.compareByLabel);
        return opt;
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



    handleClick(event) {
        console.log('value is', event.target.dataset.value);
    }
    connectedCallback() {
        console.log('child table', JSON.stringify(this.tableaData), '-------------', JSON.stringify(this.tableConfig), 'comboboxBoolean', this.comboboxBoolean, 'numberBoolean', this.numberBoolean);
        console.log('child table optt ', this.numberBoolean, this.options);
        let val = 'no val';


    }
    inputChangeHandler(event) {
        let nm = event.target.name;
        let val;
        if (nm === 'combobox') {
            val = event.detail.value;
        } else {
            val = event.target.value;
        }

        console.log('value is combobox 0 ', nm, event.target.value, this.tableConfig.fieldName,);
        let tbDta = { fieldName: this.tableConfig.fieldName, value: val, Id: this.tableaData.Id }

        console.log('value is combobox 1 ', JSON.stringify(tbDta));
        const selectEvent = new CustomEvent('passtoparent', {
            detail: tbDta
        });
        this.dispatchEvent(selectEvent);
    }

    @api reportValidity() {
        let isValid = true;
        console.log('reportValidity in pd table Display Value Component');
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (this.tableConfig.required && !element.value) {
                element.setCustomValidity("Complete this field.");
                isValid = false;
                console.log('reportValidity in pd table Display Value Component : ', isValid, element.setCustomValidity);
            } else {
                element.setCustomValidity("");
            }
        });
        this.template.querySelectorAll('lightning-textarea').forEach(element => {
            if (this.tableConfig.required && !element.value) {
                element.setCustomValidity("Complete this field.");
                isValid = false;
            } else {
                element.setCustomValidity("");
            }
        });
        // this.template.querySelectorAll('lightning-input').forEach(element => {
        //     if (element.reportValidity()) {
        //         console.log('element passed lightning-textarea');
        //         console.log('element if--' + element.value);
        //     } else {
        //         isValid = false;
        //     }
        // });
        console.log('reportValidity in pd table Display Value Component', isValid);
        return isValid;
    }
}