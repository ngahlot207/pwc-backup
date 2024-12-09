import { LightningElement, track} from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import horizontalRadioCSS from '@salesforce/resourceUrl/horizontalRadioCSS';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
// Custom labels
import PropQues_NA_ErrorMessage from '@salesforce/label/c.PropQues_NA_ErrorMessage';

export default class PropertyQuestionnaire extends LightningElement {

    customLabel = {
        PropQues_NA_ErrorMessage
    }

    @track selectedValue1a;
    @track selectedValue1b;
    @track selectedValue1c;
    @track selectedValue1d;
    @track selectedValue2a;
    @track selectedValue2b;
    @track generalCheckboxValue;
    @track subtypeCheckboxValue;
    fields=['field1a','field1b','field1c','field1d','field2a','field2b'];
    
    @track option= [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ];

    @track optionNA= [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' },
        { label: 'NA', value: 'NA' }
    ];

    renderedCallback() {
        Promise.all([
            loadStyle(this, horizontalRadioCSS)
        ]);
}


    handleRadioChange(event){
        const fieldName = event.target.name;
        const selectedValue = event.detail.value;
        //this[fieldName] = selectedValue;
        console.log('fieldname:===>>>'+ fieldName );
        console.log('selectedValue:===>>>'+ selectedValue);
        /* const fieldToUpdate = this.fields.find((field) => field.fieldName === fieldName);
        console.log('fieldToUpdate:'+ fieldToUpdate );
        if(fieldToUpdate){
            fieldToUpdate.selectedValue = selectedValue;
        } */
        const generalNormsFields = this.fields.slice(0,4);
        console.log('generalNormsFields===>>>:'+ generalNormsFields );
        /* let allYes = generalNormsFields.every(field => field.selectedValue === 'Yes');
        console.log('allYes===>>>:'+ allYes );
        this.generalCheckboxValue = allYes ? 'Yes' : 'No';*/

        if(fieldName === 'field1a'){
            this.selectedValue1a = selectedValue;
        }
        else if(fieldName === 'field1b'){
            this.selectedValue1b = selectedValue;
        }
        else if(fieldName === 'field1c'){
            this.selectedValue1c = selectedValue;
        }
        else if(fieldName === 'field1d'){
            this.selectedValue1d = selectedValue;
        }
        else if(fieldName === 'field2a'){
            this.selectedValue2a = selectedValue;
        }
        else if(fieldName === 'field2b'){
            this.selectedValue2b = selectedValue;
        }
        this.updateCheckboxField();
    }

    updateCheckboxField(){
        if(this.selectedValue1a === 'Yes' && this.selectedValue1b === 'Yes' && this.selectedValue1c === 'Yes' && this.selectedValue1d === 'Yes'){
            this.generalCheckboxValue = true;
        } else {
            this.generalCheckboxValue = false;
        }
        if((this.selectedValue2a === 'Yes' && this.selectedValue2b === 'Yes') || (this.selectedValue2a === 'Yes' && this.selectedValue2b === 'NA') || (this.selectedValue2a === 'NA' && this.selectedValue2b === 'Yes')){
            this.subtypeCheckboxValue = true;
        } else if((this.selectedValue2a === 'Yes' && this.selectedValue2b === 'No') || (this.selectedValue2a === 'No' && this.selectedValue2b === 'Yes') || (this.selectedValue2a === 'No' && this.selectedValue2b === 'No')){
            this.subtypeCheckboxValue = false;
        }else if(this.selectedValue2a === 'NA' && this.selectedValue2b === 'NA'){
            console.log('Error====>>>:');
            this.subtypeCheckboxValue = false;
            this.showToast("Error", "error", this.customLabel.PropQues_NA_ErrorMessage);
            
        }
    }
    
    handleCheckboxChange(event){
        this.generalCheckboxValue = event.target.checked;
        this.subtypeCheckboxValue = event.target.checked;
        console.log('generalCheckboxValue:===>>>'+ generalCheckboxValue);
        console.log('subtypeCheckboxValue:===>>>'+ subtypeCheckboxValue);
    }

    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(evt);
        this.showSpinner =false;
    }
}