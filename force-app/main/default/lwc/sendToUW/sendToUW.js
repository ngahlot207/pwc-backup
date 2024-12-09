import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
export default class SendToUW extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @track showSpinner = true;
    loanApplicationQueueId;
    arr = [];
    connectedCallback() {

        setTimeout(() => {
            this.showSpinner = false;
        }, 2000);

        let grpName = 'UW POOL';
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
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Loan Application Sent For Approval Successfully!',
                variant: 'success'
            })

        );
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: this.recordId,
        //         actionName: 'view'
        //     },
        // });
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "LoanAppl__c",
                actionName: "list"
            },
            // state: {
            //     filterName: "Recent" 
            // }
        });
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}