import { LightningElement,track,wire,api } from 'lwc';
import getBorrowerVerificationDetail from '@salesforce/apex/ObligationDetailsSummaryController.getBorrowerVerificationDetail';
import getBorrowerFinalCPVSummaryDetails from '@salesforce/apex/ObligationDetailsSummaryController.getBorrowerFinalCPVSummaryDetails';
import getHunterAndRCUStatus from '@salesforce/apex/ObligationDetailsSummaryController.getHunterAndRCUStatus';
export default class BorrowerVerificatonDetails extends LightningElement {
    listBorrowerVerificationDetails=[];
    listBorrowerFinalCPVSummary=[];
    listHunterandRCUStatus =[];
    @api recordId;
    @wire(getBorrowerVerificationDetail,{ recordId: '$recordId'})
    wiredBorrowerVerificationDetail({ data, error }) {
        if (data) {
           // console.log('data-->'+JSON.stringify(data));
            this.listBorrowerVerificationDetails = data;
            console.log('listBorrowerVerificationDetails-->'+JSON.stringify(this.listBorrowerVerificationDetails));
           
            
        } else if (error) {
            console.error('Error loading Borrower verification Details: ', error);
        }
    }

    @wire(getBorrowerFinalCPVSummaryDetails,{ recordId: '$recordId'})
    wiredBorrowerFinalCPVSummaryDetails({ data, error }) {
        if (data) {
           // console.log('data-->'+JSON.stringify(data));
            this.listBorrowerFinalCPVSummary = data;
            console.log('listBorrowerFinalCPVSummary-->'+JSON.stringify(this.listBorrowerFinalCPVSummary));
           
            
        } else if (error) {
            console.error('Error loading Final CPV Summary: ', error);
        }
    }

    @wire(getHunterAndRCUStatus,{ recordId: '$recordId'})
    wiredgetHunterAndRCUStatus({ data, error }) {
        if (data) {
           // console.log('data-->'+JSON.stringify(data));
            this.listHunterandRCUStatus = data;
            console.log('listHunterandRCUStatus-->'+JSON.stringify(this.listHunterandRCUStatus));
           
            
        } else if (error) {
            console.error('Error loading Hunter and RCU Status: ', error);
        }
    }

}