import { LightningElement, track } from 'lwc';

export default class TryComp extends LightningElement {
    @track selectedValues = [];
    @track recordOptions = [
        { label: 'Option 1', value: 'option1' },
        { label: 'Option 2', value: 'option2' },
        { label: 'Option 3', value: 'option3' },
    ];

    handleSelection(event) {
        this.selectedValues = event.detail.value;
        // You can now use this.selectedValues in your code
    }
}