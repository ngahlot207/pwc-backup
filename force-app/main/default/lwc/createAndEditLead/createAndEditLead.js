import { LightningElement } from 'lwc';

export default class CreateAndEditLead extends LightningElement {

    handleStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            // set behavior after a finished flow interview
        }
    } 
}