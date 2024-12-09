import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { createRecord } from 'lightning/uiRecordApi';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
// Custom labels
import SendToCpa_SuccessMessage from '@salesforce/label/c.SendToCpa_SuccessMessage';

export default class SendToCpaPool extends LightningElement {
    label = {
        SendToCpa_SuccessMessage
    }
    @api recordId;
    @api objectApiName;
    @track showSpinner = true;
    loanApplicationQueueId;
    arr = [];
    connectedCallback() {

        setTimeout(() => {
            this.showSpinner = false;
        }, 2000);

        let grpName = 'CPA POOL';
        let type = 'Queue';
        let params = {
            ParentObjectName: 'Group',
            parentObjFields: ["Id", "Name"],

            queryCriteria: ' where name = \'' + grpName + '\' AND Type = \'' + type + '\''
        };
        console.log("params", params);
        getSobjectDatawithRelatedRecords({ params: params })
            .then((res) => {

                this.loanApplicationQueueId = res.parentRecord.Id;

            })
    }

    handleSuccess(e) {
        
        // Close the modal window and display a success toast
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: this.label.SendToCpa_SuccessMessage,
                variant: 'success'
            })
            
        );
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            },
        });
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}