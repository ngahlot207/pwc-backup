import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
export default class ReturnToCpaUw extends NavigationMixin(LightningElement) {

    @api recordId;
    @api objectApiName;
    @track showSpinner = true;
    @track isReadOnly = false;
    cpaQueueId;
    uwQueueId;
    arr = [];
    stageOpt=[{ value: "Return to DDE", label: "Return to DDE" },
    { value: "Return to UW", label: "Return to UW" }
    ];

    connectedCallback() {
        if (this.hasEditAccess === false) {
            this.isReadOnly = true;
        }
        setTimeout(() => {
            this.showSpinner = false;
        }, 2000);

        
        let type = 'Queue';
        let params = {
            ParentObjectName: 'Group',
            parentObjFields: ["Id", "Name"],

            queryCriteria: ' where Type = \'' + type + '\''
        };
        console.log("params", params);
        getSobjectDatawithRelatedRecords({ params: params })
            .then((res) => {
                let cpaQueueId;
                let resultNew = res.parentRecords;
                if (resultNew.length > 0) {
                    // cpaQueueId = resultNew.filter(item => == 'Collateral Visit')
                }
                this.cpaQueueId = res.parentRecord.Id;
               // this.uwQueueId 

            })
            
    }
    handleChange(event) {
        this.stageVal = event.detail.value;
    }

    handleSuccess(e) {
        if (this.stageVal == 'Return to DDE') {
            const obje = {
                sobjectType: "LoanAppl__c",
                Id: this.recordId,
                Stage__c: 'DDE',
                SubStage__c: 'CPA Pool',
                // OwnerId: this.cpaQueueId,

            }
            console.log('in Return to DDE => ', obje);
            this.upsertDataMethod(obje);
        }
        else if (this.Decisionvalue == 'Return to UW') {
            const obje = {
                sobjectType: "LoanAppl__c",
                Id: this.recordId,
                Stage__c: 'Underwriting',
                SubStage__c: 'UW Pool',
                // OwnerId: this.loanApplicationQueueId,

            }
            console.table(obje);
            console.log('in Return to UW => ', obje);
            this.upsertDataMethod(obje);

        }        
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    upsertDataMethod(obje) {
        console.log('objec ', obje);
        console.table(obje);
        let newArray = [];
        if (obje) {
            newArray.push(obje);
        }
        if (newArray) {
            console.log('new array is ', JSON.stringify(newArray));
            upsertSObjectRecord({ params: newArray })
                .then((result) => {
                    this.refreshPage = result;
                    console.log('result => ', result);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: "Loan Applications was Returned Successfully!",
                            variant: "success",
                        }),

                    );
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recordId,
                            actionName: 'view'
                        },
                    });
                })
                .catch((error) => {
                    console.log('error ', JSON.stringify(error));
                    console.table(error);

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error while updating the record",
                            message: error.body.message,
                            variant: "error",
                        }),
                    );
                    this.showSpinner = false;
                });
        }
    }


}