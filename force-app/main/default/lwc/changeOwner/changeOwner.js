import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import changeOwner from '@salesforce/resourceUrl/changeOwner';
export default class ChangeOwner extends LightningElement {



    connectedCallback(){
        loadStyle(this, changeOwner)
        .then(result => {
            // Possibly do something when load is complete.
        })
        .catch(reason => {
            // Checkout why it went wrong.
    });
    }
    
}