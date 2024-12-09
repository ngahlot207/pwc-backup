import { LightningElement,track,wire,api} from 'lwc';
import getDeviationDetail from '@salesforce/apex/ObligationDetailsSummaryController.getDeviationDetail';
export default class DeviationRiskDetails extends LightningElement {
    
    listDeviationDeail =[];
    @api recordId;
    @wire(getDeviationDetail,{ recordId: '$recordId'})
    wiredgetDeviationDetail({ data, error }) {
        if (data) {
           // console.log('data-->'+JSON.stringify(data));
            this.listDeviationDeail = data;
            console.log('listDeviationDeail-->'+JSON.stringify(this.listDeviationDeail));
            
        } else if (error) {
            console.error('Error loading Deviaton, Risk and Mitigation: ', error);
        }
    }
}