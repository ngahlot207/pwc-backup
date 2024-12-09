import { LightningElement,track,wire,api} from 'lwc';
import getSancionCondition from '@salesforce/apex/ObligationDetailsSummaryController.getSancionCondition';

export default class SanctionCondtionDetails extends LightningElement {

    @track listSanctionCondition =[];
    @api recordId;

    connectedCallback(){
        console.log('recordIdForSanction-->'+this.recordId);

    }
    @wire(getSancionCondition,{ recordId: '$recordId'})
    wiredgetSancionCondition({ data, error }) {
        if (data) {
           // console.log('data-->'+JSON.stringify(data));
            this.listSanctionCondition = data;
            console.log('listSanctionCondition-->'+JSON.stringify(this.listSanctionCondition));
           
            
        } else if (error) {
            console.error('Error loading Sanction Condition: ', error);
        }
    }
}