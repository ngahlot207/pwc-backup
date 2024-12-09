import { LightningElement,api,track,wire } from 'lwc';
import getCollateralVisitDetails from '@salesforce/apex/ObligationDetailsSummaryController.getCollateralVisitDetails';
import getCollateralVerificationDetails from '@salesforce/apex/ObligationDetailsSummaryController.getCollateralVerificationDetails';
export default class CollateralVisitDetails extends LightningElement {
    @track listCollateralDetails =[];
    listCollateralVerificationDetails=[];
    @api recordId;

    multiTenantFlag=false;
    @wire(getCollateralVisitDetails,{ recordId: '$recordId'})
    wiredgetCollateralVisitDetails({ data, error }) {
        if (data) {
            this.listCollateralDetails = data;
            console.log('listCollateralDetails-->'+JSON.stringify(this.listCollateralDetails));
            console.log('this.listCollateralDetails[0].Is_the_property_Multi_Tenanted__c',this.listCollateralDetails[0].Is_the_property_Multi_Tenanted__c)
            if(this.listCollateralDetails[0].Is_the_property_Multi_Tenanted__c=='Yes'){
            this.multiTenantFlag=true;
            }
            
        } else if (error) {
            console.error('Error loading Collateral Verification Details: ', error);
        }
    }

    @wire(getCollateralVerificationDetails,{ recordId: '$recordId'})
    wiredgetCollateralVerificationDetails({ data, error }) {
        if (data) {
          //  console.log('data-->'+JSON.stringify(data));
            this.listCollateralVerificationDetails = data;
            console.log('listCollateralVerificationDetails-->'+JSON.stringify(this.listCollateralVerificationDetails));
            
            
        } else if (error) {
            console.error('Error loading Collateral Verification Details: ', error);
        }
    }
}