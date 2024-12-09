import { LightningElement, api, track } from "lwc";
export default class ConfigCustomChildForm extends LightningElement {
    @api fieldDetail;
    @track iscombobox;
    @track isText;
    @track isRadio;
    @track isLookup;
    selectedLookupValue;
    fieldName;
    @api options;

    @api type;

    @api value;
    @api allField;

    // VALUES FOR CUSTOM LOOKUP COMPONENT
    @api helpText;
    @api selectedIconName;
    @api objectLabel;
    @api objectApiName;
    @api fieldApiName;
    @api selectedRecordId;
    @api selectedRecordName;
    @api allData;
    connectedCallback() {
        console.log("fieldDetails in child:::::::", this.fieldDetail);

        if (
            this.type == "text" ||
            this.type == "number" ||
            this.type == "datetime" ||
            this.type == "date" ||
            this.type == "email" ||
            this.type == "checkbox" ||
            this.type == "toggle" ||
            this.type == "time" ||
            this.type == "url" ||
            this.type == "tel" ||
            this.type == "checkbox-button"
        ) {
            this.isText = true;
        }
        if (this.type == "combobox") {
            this.iscombobox = true;
            this.pickValSelect();
        }
        if (this.type == "radio") {
            this.isRadio = true;
        }
        if (this.type == "lookup") {
            this.isLookup = true;
        }
    }
    handleInputChange(event) {
        console.log(
            "inside handleChange" + event.target.checked,
            ":::::::::",
            event.target.value
        );
        let fieldValue = event.target.value;

        if (
            event.target.type == "checkbox" ||
            event.target.type == "checkbox-button"
        ) {
            fieldValue = event.target.checked;
        }
        if (event.target.type == "toggle") {
            fieldValue = event.target.checked;
        }

        const fieldName = this.fieldDetail.FieldName;
        console.log("inside fieldName", fieldName);
        const changeEvent = new CustomEvent("change", {
            detail: { fieldName, fieldValue }
        });
        this.dispatchEvent(changeEvent);
        console.log("inside handleChange", changeEvent);
    }

    pickValSelect() {
        console.log(
            "this.fieldDetail.parentField= ",
            this.fieldDetail.parentField
        );
        if (this.fieldDetail.parentField != null) {
            let parentVal = this.allData[this.fieldDetail.parentField];
            console.log("parent value= ", parentVal);
            this.options = this.fieldDetail.controllingValue[parentVal];
            console.log(" this.options= ", this.options);
        }
    }
    handleValueSelect(event) {
        this.selectedLookupValue = event.detail;
        console.log(
            " this.selectedLookupValu:::::>>>> ",
            this.selectedLookupValue
        );
        const selectedEvent = new CustomEvent("select", {
            detail: this.selectedLookupValue
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);
    }
    @api reportValidity() {
        this.checkValidityLookup();
        const isInputCorrect = [
            ...this.template.querySelectorAll("lightning-input"),
            ...this.template.querySelectorAll("lightning-combobox"),
            ...this.template.querySelectorAll("lightning-radio-group")
            // ...this.template.querySelectorAll("c-custom-lookup")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        return isInputCorrect;
    }

    checkValidityLookup() {
        let isInputCorrect = true;

        let allChilds = this.template.querySelectorAll("c-custom-lookup");
        console.log("custom lookup allChilds>>>", allChilds);
        allChilds.forEach((child) => {
            console.log("custom lookup child>>>", child);
            //isInputCorrect = child.checkValidityLookup();
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
    }
}