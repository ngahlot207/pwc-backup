import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { createRecord } from 'lightning/uiRecordApi';
export default class ReturnToDDE extends NavigationMixin(LightningElement) {
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
        // this.createUWRecord();
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Application has been successfully return to DDE',
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