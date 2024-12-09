import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
export default class ForwardApplication extends LightningElement {
    @api recordId;
    @track returnToRmMessage = "Do u want to Handover this LAN to UW ?";
    @track ishandoverToUw = false;
    @track showSpinnerChild = false;
    connectedCallback() {
        this.ishandoverToUw = true;
    }

    closeModalCPA() {
        this.ishandoverToUw = false;
        this.fireCustomEvent(null, null, null);
    }
    changeSubstagetoPloginQu() {
        // this.ishandoverToUw = false;

        this.spinnerEvent(true);
        let loanAppFields = {};
        loanAppFields['Id'] = this.recordId;
        loanAppFields['Stage__c'] = 'UnderWriting';
        let dt = new Date().toISOString().substring(0, 10);
        console.log('current date ISO is===>>>>>>>', dt);
        loanAppFields['SubStage__c'] = dt;

        let upsertDataFile = {
            parentRecord: loanAppFields,
            ChildRecords: null,
            ParentFieldNameToUpdate: ''
        }
        console.log('upsertData ==>', JSON.stringify(upsertDataFile));

        upsertSobjDataWIthRelatedChilds({ upsertData: upsertDataFile })
            .then(result => {

                this.fireCustomEvent("Success", "success", "Files Accepted Successfully!");
            }).catch(error => {

                this.fireCustomEvent("Error", "error", "Error occured in accepting File  " + error.message);
                console.log(error);
            })

    }

    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(evt);
    }

    fireCustomEvent(title, vart, msg) {
        const selectEvent = new CustomEvent('click', {
            detail: { title: title, variant: vart, message: msg, from: "fileacceptance" }
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }

    spinnerEvent(val) {
        const selectEvent = new CustomEvent('spinner', {
            detail: val
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }
}