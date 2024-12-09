import { LightningElement, api, track } from 'lwc';

export default class DependentCombobox extends LightningElement {
    @api comboboxConfig;

    // comboboxConfig = {
    //     comboID: '', isParent: true, childId: 'cId', label: 'label', value: ''
    //     , required: true, pickListOptions: [], isDisabled: false,
    // }
    get comboID() {
        return this.comboboxConfig.comboID;
    };
    isParent() {
        return this.comboboxConfig.isParent;
    };
    childId() {
        return this.comboboxConfig.childId;
    };
    label() {
        return this.comboboxConfig.label;
    };
    value() {
        return this.comboboxConfig.value;
    };
    required() {
        return this.comboboxConfig.required;
    };
    pickListOptions() {
        return this.comboboxConfig.pickListOptions;
    };
    isDisabled() {
        return this.comboboxConfig.isDisabled;
    };

    connectedCallback() {
        console.log('in DependentCombobox cc ', this.comboboxConfig);

    }
    handleInputChange(event) {
        let name = event.target.name;
        let value = event.target.value;
    }
    passToParent(event) {
        if (childId) {
            // to publish options for child
            let param = event.detail;
        } else {
            // for selected value in parent
        }

        console.log('from DependentCombobox = ');

        const selectEvent = new CustomEvent('passtoparent', {
            detail: param
        });
        this.dispatchEvent(selectEvent);
    }

}