import { LightningElement, api } from 'lwc';

export default class DynamicPicklistComponent extends LightningElement {
    @api label;
    @api options;
    @api selectedValue;

    handleChange(event) {
        // Dispatch event to notify parent component of value change
        const selectedValue = event.detail.value;
        this.dispatchEvent(new CustomEvent('picklistchange', { detail: { selectedValue } }));
    }

}