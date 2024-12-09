import { LightningElement, api,track } from 'lwc';


export default class DedupeDisplayValue extends LightningElement {
    @api object;
    @api fieldName;
    @api fieldValue;
    @api type = null;
    @api dedupeRsultsOptions = [];
    @api isReadOnly = false;
    @api indexValue;
    @api required;

    get options() {
        if(this.dedupeRsultsOptions){
            let arr = JSON.parse(JSON.stringify(this.dedupeRsultsOptions));
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
        // let arr = JSON.parse(JSON.stringify(this.dedupeRsultsOptions));
        // arr.forEach(item => {
        //     if (item.value == this.fieldValue) {
        //         item.selected = true;
        //     } else {
        //         item.selected = false;
        //     }
        // })
        // return arr;
        }  
    }

    get recordId() {
        return this.object['Id'];
    }
    get picklistValue() {
        return this.type == "picklist" ? true : false;
    }
    handleChange(event) {
        this.hasError=false;
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

    // @api checkValidityDeupeDisplay() {
    //     let isInputCorrect;
    //     if(this.onChangeValue){
    //       isInputCorrect = [...this.template.querySelectorAll("select")].reduce((validSoFar, inputField) => {
    //         if (!this.fieldValue) {
    //           inputField.setCustomValidity("Please Enter Valid Input");
    //         } else {
    //           inputField.setCustomValidity("");
    //         }
    //         inputField.reportValidity();
    //         return validSoFar && inputField.checkValidity();
    //       }, true);
    //     }
    //     // else{
    //     //   isInputCorrect = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, inputField) => {
    //     //     inputField.setCustomValidity("");
    //     //     inputField.reportValidity();
    //     //     return validSoFar && inputField.checkValidity();
    //     //   }, true);
    //     // }
    //     return isInputCorrect;



    //   }
    @track hasError = false;
    @api reportValidity() {
        let isValid = true;
        // this.template.querySelectorAll('select').forEach(element => {
        //     if (element.reportValidity()) {
        //         console.log('element passed lightning input');
        //         console.log('element if--', element.value);
        //     } else {
        //         isValid = false;
        //     }
        // });

        this.template.querySelectorAll('select').forEach(element => {
            console.log('element if--', element.value);
            console.log('required--', this.required);

                if (!element.value) {
                    if(this.required==false){
                        this.hasError = false;
                        
                    }
                    else{
                    this.hasError = true;
                    }
                    isValid = false;
                } else {
                    this.hasError = false;
                    
                }
            
        });
        console.log('inside child isValid',isValid)
        return isValid;
    }

    get formCls() {
        if (this.hasError) {
            return 'slds-form-element slds-has-error';
        } else {
            return 'slds-form-element';
        }
    }

}