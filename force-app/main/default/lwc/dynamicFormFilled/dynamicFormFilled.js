import { LightningElement, api, wire, track } from 'lwc';

export default class DynamicFormFilled extends LightningElement {
    @api pdQuestion;
    @api hasEditAccess;
    @api layoutSize;

    get pickListOptions() {
        let options = [];
        if (this.pdQuestion.possibleOptions) {
            this.pdQuestion.possibleOptions.forEach(obj => {
                let pickList = { label: obj, value: obj };
                options = [...options, pickList];

            })
        }
        options.sort(this.compareByLabel);
        return options;
    }
    get isText() {
        return this.pdQuestion.respType == "Text" && this.pdQuestion.visibleOnPortal;
    }
    get isEmail() {

        return this.pdQuestion.respType == "Email" && this.pdQuestion.visibleOnPortal;
    }
    get isFile() {
        return (this.pdQuestion.respType == "File" || this.pdQuestion.respType == "Video") && this.pdQuestion.visibleOnPortal;
    }
    get isTextarea() {
        return (this.pdQuestion.respType == "Textarea" || this.pdQuestion.respType == "TextArea") && this.pdQuestion.visibleOnPortal;
    }
    get isRadio() {
        return this.pdQuestion.respType == "Radio" && this.pdQuestion.visibleOnPortal;
    }
    get isPicklist() {
        return this.pdQuestion.respType == "Picklist" && this.pdQuestion.visibleOnPortal;
    }
    get isLink() {
        return this.pdQuestion.respType == "Link" && this.pdQuestion.visibleOnPortal;
    }
    get isNumber() {
        return this.pdQuestion.respType == "Number" && this.pdQuestion.visibleOnPortal;
    }
    get isNumberDecimal() {
        return this.pdQuestion.respType == "Decimal" && this.pdQuestion.visibleOnPortal;
    }
    get isPhone() {
        return this.pdQuestion.respType == "Phone" && this.pdQuestion.visibleOnPortal;
    }
    get isDate() {
        return this.pdQuestion.respType == "Date" && this.pdQuestion.visibleOnPortal;
    }
    get isCurrency() {
        return this.pdQuestion.respType == "Currency" && this.pdQuestion.visibleOnPortal;
    }
    get isDateTime() {
        return this.pdQuestion.respType == "DateTime" && this.pdQuestion.visibleOnPortal;
    }
    get isReference() {
        return this.pdQuestion.respType == "Reference" && this.pdQuestion.visibleOnPortal;
    }
    get isTable() {
        return this.pdQuestion.respType == "Table" && this.pdQuestion.visibleOnPortal;
    }
    get isMultiLookup() {
        return this.pdQuestion.respType == "Picklist Multiselect" && this.pdQuestion.visibleOnPortal;
    }

    get dateTimeVal() {
        if (this.isDateTime && this.pdQuestion.quesResp) {
            let parsedDate = new Date(this.pdQuestion.quesResp);
            let dt = parsedDate.toISOString();
            return dt;
        }
        return this.pdQuestion.quesResp;
    }
    handleConvertToIST(gmtTime) {
        const gmtDate = new Date(gmtTime);
        const istOffset = 5.5 * 60 * 60 * 1000; // 5 hours 30 minutes in milliseconds
        const istDate = new Date(gmtDate.getTime() + istOffset);
        return istDate.toISOString();
    }

    get isDisabled() {
        if (this.hasEditAccess) {
            return this.hasEditAccess == false ? true : this.pdQuestion.isEditable == false ? true : false;
        } else {
            return true;
        }
    }
    get questionconfig() {
        if (this.pdQuestion.respType == "Picklist Multiselect") {
            return JSON.parse(this.pdQuestion.quesConfig);
        }
    }
    get pattern() {
        if (this.pdQuestion.validationConfig != null) {
            let vall = JSON.parse(this.pdQuestion.validationConfig);
            return vall.pattern;
        }
    }
    get minimumVal() {
        if (this.pdQuestion.validationConfig != null) {
            let vall = JSON.parse(this.pdQuestion.validationConfig);
            return vall.min;
        }
    }
    get maximumVal() {
        if (this.pdQuestion.validationConfig != null) {
            let vall = JSON.parse(this.pdQuestion.validationConfig);
            return vall.max;
        }
    }

    get uppercaseValue() {
        if (this.pdQuestion.quesResp) {
            return this.pdQuestion.quesResp.toUpperCase();
        }
    }

    get minDateVal() {
        if (this.pdQuestion.validationConfig != null) {
            let vall = JSON.parse(this.pdQuestion.validationConfig);
            console.log('minDateVal vall  :: ', vall);
            if (vall.minDate) {
                let minDate = parseInt(vall.minDate, 10);
                console.log('minDateVal  minDate :: ', minDate);
                let currentDate = new Date();
                let newDate = new Date(currentDate);
                if (minDate != 0) {


                    newDate.setDate(currentDate.getDate() + minDate);
                    return newDate.toISOString();
                } else {
                    console.log(vall.minDate + ' is zero.');
                    return currentDate.toISOString();
                }
            } else {
                return null;
            }
        }
    }
    get maxDateVal() {
        if (this.pdQuestion.validationConfig != null) {
            let vall = JSON.parse(this.pdQuestion.validationConfig);

            console.log('maxDateVal vall :: ', vall);

            if (vall.maxDate) {
                let maxDate = parseInt(vall.maxDate, 10);
                console.log('maxDateVal  maxDate :: ', maxDate);
                let currentDate = new Date();
                let newDate = new Date(currentDate);
                if (maxDate != 0) {

                    newDate.setDate(currentDate.getDate() + maxDate);
                    return newDate.toISOString();
                } else {
                    console.log(maxDate + ' is zero.');
                    return currentDate.toISOString();
                }
            } else {
                return null;
            }
        }
    }
    get stepVal() {
        if (this.pdQuestion.validationConfig != null) {
            let vall = JSON.parse(this.pdQuestion.validationConfig);
            return vall.step;
        }
    }
    // get todaysDate() {
    //     const today = new Date();
    //     return today.toISOString();
    // }
    connectedCallback() {
        console.log('dynamic Form Filled ', this.pdQuestion);
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
    handleChange(event) {

    }
    handleInputChange(event) {
        let name = event.target.name;
        let value = event.target.value;
        console.log('PdQId = ', name, 'updated Value ', value);
        let param = { pdRespId: name, respVal: value }
        const selectEvent = new CustomEvent('passtoparent', {
            detail: param
        });
        this.dispatchEvent(selectEvent);

    }
    fromChildComp(event) {

        console.log('fromChildComp in dynamic form filled from reference detailcomp = ', event.detail);
        let param = event.detail;
        const selectEvent = new CustomEvent('passtoparent', {
            detail: param
        });
        this.dispatchEvent(selectEvent);
    }

    @api
    reportValidity() {
        let isValid = true


        this.template.querySelectorAll('c-dynamic-file-upload-for-p-d').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed c-dynamic-file-upload-for-p-d');
                console.log('element if--' + element.value);
            } else {
                console.log('element failed c-dynamic-file-upload-for-p-d');
                isValid = false;

            }
        });
        this.template.querySelectorAll('c-multi-select-lookup-component').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed c-multi-select-lookup-component');
                console.log('element if--' + element.value);
            } else {
                console.log('element failed c-multi-select-lookup-component');
                isValid = false;

            }
        });
        this.template.querySelectorAll('c-reference-det-for-p-d-component').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed c-reference-det-for-p-d-component');
                console.log('element if--' + element.value);
            } else {
                console.log('element failed c-reference-det-for-p-d-component');
                isValid = false;

            }
        });
        this.template.querySelectorAll('c-dynamic-data-table-for-p-d').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed c-dynamic-data-table-for-p-d');
                console.log('element if--' + element.value);
            } else {
                console.log('element failed c-dynamic-data-table-for-p-d');
                isValid = false;

            }
        });

        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed combobox');
                console.log('element if--' + element.value);
            } else {
                console.log('element failed combobox');
                isValid = false;
            }
        });

        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed lightning input');
                console.log('element if--' + element.value);
            } else {
                console.log('element failed lightning input');
                isValid = false;
            }
        });
        this.template.querySelectorAll('lightning-textarea').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed lightning-textarea');
                console.log('element if--' + element.value);
            } else {
                console.log('element failed lightning-textarea');
                isValid = false;
            }
        });
        return isValid;
    }

    handleLookupFieldChange(event) {
        console.log('fromChildComp in dynamic form filled from reference detailcomp = ', event.detail);
        // this.questionconfig.recConfig.objectName
        let pp = {
            respType: this.pdQuestion.respType,
            objName: this.questionconfig.recConfig.objectName,
            val: event.detail
        }
        let param = pp;
        const selectEvent = new CustomEvent('passtoparent', {
            detail: param
        });
        this.dispatchEvent(selectEvent);

    }



}