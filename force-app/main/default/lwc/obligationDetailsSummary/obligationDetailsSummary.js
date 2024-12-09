import { LightningElement,api,wire,track } from 'lwc';
import getObligationDetailsSummary from '@salesforce/apex/ObligationDetailsSummaryController.getObligationDetailsSummary';
import getObligationDetailsSummaryBureau from '@salesforce/apex/ObligationDetailsSummaryController.getObligationDetailsSummaryBureau';

export default class ObligationDetailsSummary extends LightningElement {
@api recordId;
@track listObligationDetails = [];
@track listObligationDetailsBureau = [];
@track obligantAmountField={};
@track totalCurrentOs;
@track totalObligentAmount;
@api isBlPl;
// @track currentOs = 0;

@wire(getObligationDetailsSummary,{ recordId: '$recordId'})
wiredObligationDetails({ data, error }) {
    if (data) {
        this.listObligationDetails = data;
        console.log('listObligationDetails-->'+JSON.stringify(this.listObligationDetails));

        
            var currentOs = 0;
            var obligent = 0;
            

            for ( var i = 0; i < this.listObligationDetails.length; i++ ) {
                console.log('For loop FY Year-->'+this.listObligationDetails[ i ]);

                  //logic is used for if treatment = to continue-obligate then EMI__c should be displayed in obligant amount field on UI but need some changes in this logic 
                if (this.listObligationDetails[ i ].EMI__c && this.listObligationDetails[ i ].Treatment__c === 'To continue - Obligate') 
                {
                    
                    this.obligantAmountField = this.listObligationDetails[ i ].EMI__c;
                    console.log('If for obligantAmountField-->'+this.obligantAmountField);
                    // loanAmount.push( this.listObligationDetails[ i ].CurrentOs__c);
                   
                }
            
            


                if (this.listObligationDetails[ i ].EMI__c) 
                {
                    if (this.listObligationDetails[ i ].Treatment__c === 'To continue - Obligate') {
                    var obligentAmount = this.listObligationDetails[ i ].EMI__c;
                    console.log('If for obligentAmount-->'+obligentAmount);
                    // loanAmount.push( this.listObligationDetails[ i ].CurrentOs__c);
                    if(!isNaN(obligentAmount)){
                        obligent  = obligent + obligentAmount;
                    console.log('currentOs-->'+obligent);
                }
            }
            }
               

           //for temparary calculation on currentOs field
            console.log('cuurent-->'+this.listObligationDetails[ i ].CurrentOs__c);
          
            if (this.listObligationDetails[ i ].CurrentOs__c) 
            {
                var currentOsValue = this.listObligationDetails[ i ].CurrentOs__c;
                console.log('If for currentOsValue-->'+this.currentOsValue);
                // loanAmount.push( this.listObligationDetails[ i ].CurrentOs__c);
                if(!isNaN(currentOsValue)){
                currentOs  = currentOs + currentOsValue;
                console.log('currentOs-->'+currentOs);
            }
            }
        
            
        }

        console.log('Outside for loop this.EMI-->'+obligent);
        this.totalObligentAmount = obligent;
        console.log('this.totalObligentAmount-->'+this.totalObligentAmount);

        console.log('Outside for loop this.currentOs-->'+currentOs);
        this.totalCurrentOs = currentOs;
        console.log('this.totalCurrentOs-->'+this.totalCurrentOs);

        console.log('this.obligantAmountField-->'+JSON.stringify(this.obligantAmountField));
        
    } else if (error) {
        console.error('Error loading Obligation Details: ', error);
    }
}

@wire(getObligationDetailsSummaryBureau,{ recordId: '$recordId'})
wiredObligationDetailsSummaryBureau({ data, error }) {
    if (data) {
        this.listObligationDetailsBureau = data;
        console.log('listObligationDetailsBureau-->'+JSON.stringify(this.listObligationDetailsBureau));

        
            var loanAmount =100;
            

        /* for ( var i = 0; i < this.listObligationDetailsBureau.length; i++ ) {
            console.log('For loop FY Year-->'+this.listObligationDetailsBureau[ i ]);

            if (this.listObligationDetailsBureau[ i ].CurrentOs__c)
            {
                console.log('If for Loan Amount');
                // loanAmount.push( this.listObligationDetails[ i ].CurrentOs__c);
                this.totalLoanAmount  = +this.listObligationDetailsBureau[ i ].CurrentOs__c;
    
            console.log('this.totalLoanAmount-->'+this.totalLoanAmount);
            }
            
        }*/
        
    } else if (error) {
        console.error('Error loading Obligation Details: ', error);
    }
}




}