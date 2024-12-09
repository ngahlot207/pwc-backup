import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class LoanApplicationNav extends NavigationMixin(LightningElement) {
    @api LoanApplicationId;

    connectedCallback(){
        this.navigateToRecordPage();
    }

    navigateToRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.LoanApplicationId,
                objectApiName: 'LoanAppl__c',
                actionName: 'view'
            }
        });
}
}