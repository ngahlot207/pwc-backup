import { LightningElement, track, api } from 'lwc';
export default class MultiSelectPickListParent extends LightningElement {

    @track selectedValueList = [];
    @track optionOfApp;

    @api get ownerOp() {

        return this.optionOfApp;
    }
    set ownerOp(value) {
        if (value) {
            console.log('value', value);
            this.optionOfApp = value;
        }
    }

    handleSelectOptionList(event) {
        console.log('event detail ', event.detail);
        this.selectedValueList = event.detail;
        console.log('Parent component onselect option', this.selectedValueList);
    }
}