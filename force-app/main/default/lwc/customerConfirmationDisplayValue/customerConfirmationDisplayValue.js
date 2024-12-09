import { LightningElement, api } from 'lwc';

export default class CustomerConfirmationDisplayValue extends LightningElement {
    @api object;
    @api fieldName;
    @api fieldValue;
    @api type = null;
    @api passedOptions = [];
    @api isReadOnly = false;

    connectedCallback() {
        console.log('isReadOnly in customer confirmation display value is ', this.isReadOnly);
    }
    get options() {
        console.log('Field value in child component ', this.fieldValue);
        let arr = JSON.parse(JSON.stringify(this.passedOptions));
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
        return arr;
    }

    get recordId() {
        return this.object.Id;
    }
    get picklistValue() {
        return this.type === "picklist" ? true : false;
    }
    handleChange(event) {
        console.log('object in child is ', this.object);
        let val = event.target.value;
        let selectedRecordId = event.target.dataset.recordid;
        let nameVal = event.target.name;
        console.log('val is ', val, 'deduperRecordId is ', selectedRecordId, ' name is ', nameVal);

        let selectEvent = new CustomEvent('picklistchange', {
            detail: { recordid: selectedRecordId, val: val, nameVal: nameVal }
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);

    }
}