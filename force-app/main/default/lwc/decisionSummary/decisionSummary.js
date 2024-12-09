import { LightningElement,track,wire,api} from 'lwc';
import getDecisionSummary from '@salesforce/apex/ObligationDetailsSummaryController.getDecisionSummary';
import getLoanDetailsSummary from '@salesforce/apex/ObligationDetailsSummaryController.getLoanDetailsSummary';
import getUwAndApprover from '@salesforce/apex/ObligationDetailsSummaryController.getUwAndApprover';


export default class DecisionSummary extends LightningElement {

    @track listDecisionSummaryDetails;
    @track @track listOfLoanDetailsSummary =[];
    @api recordId;
    fedfinaUnderwriter;
    fedfinaApprover;

    BDApplicantCoapp
    IncomerelateComm
    AddationalComm
    PrsnldetailsofPromotrs
    
    connectedCallback(){
        console.log('recordIdForDecision-->'+this.recordId);

    }
    @wire(getDecisionSummary,{ recordId: '$recordId'})
    wiredgetDecisionSummary({ data, error }) {
        if (data) {
            console.log('recordIdForDecision-->'+this.recordId);
            this.listDecisionSummaryDetails = data;
            //console.log('this.fedfinaUnderwriter-->'+this.listDecisionSummaryDetails.fedfinaUnderwriterWrapp);
           // Commented for a while after we have to add those fields
            // this.listDecisionSummaryDetails.forEach(decision => {
              
            //   console.log('call');
            //     if(decision.fedfinaUnderwriterWrapp !=null && decision.fedfinaUnderwriterWrapp != undefined){
            //         this.fedfinaUnderwriter = decision.fedfinaUnderwriterWrapp;
            //         console.log('this.fedfinaUnderwriter-->'+this.fedfinaUnderwriter);
            //       //  break;
            //     }
            //     if(decision.fedfinaApproverWrap !=null && decision.fedfinaApproverWrap != undefined){
            //         this.fedfinaApprover = decision.fedfinaApproverWrap;
            //         console.log('this.fedfinaApprover-->'+this.fedfinaApprover);
            //       //  break;
            //     }
                
            // });
          /*  for(var i =0; i<this.listDecisionSummaryDetails; i++){
                if(this.listDecisionSummaryDetails.fedfinaUnderwriterWrapp !=null){
                    this.fedfinaUnderwriter = this.listDecisionSummaryDetails.fedfinaUnderwriterWrapp;
                    console.log('this.fedfinaUnderwriter-->'+this.fedfinaUnderwriter);
                    break;
                }
                if(this.listDecisionSummaryDetails.fedfinaApproverWrap !=null){
                    this.fedfinaApprover = this.listDecisionSummaryDetails.fedfinaApproverWrap;
                    console.log('this.fedfinaApprover-->'+this.fedfinaApprover);
                    break;
                }
            } */
            
            
            console.log('listDecisionSummaryDetails-->'+JSON.stringify(this.listDecisionSummaryDetails));
            // if(this.listDecisionSummaryDetails[0].LoanAppl__r!=undefined || this.listDecisionSummaryDetails[0].LoanAppl__r!=null ){

            //     this.BDApplicantCoapp=this.listDecisionSummaryDetails[0].LoanAppl__r.BDApplicantCoapp__c?this.listDecisionSummaryDetails[0].LoanAppl__r.BDApplicantCoapp__c:'';
            //     this.IncomerelateComm=this.listDecisionSummaryDetails[0].LoanAppl__r.BDApplicantCoapp__c?this.listDecisionSummaryDetails[0].LoanAppl__r.IncomerelateComm__c:'';
            //     this.AddationalComm=this.listDecisionSummaryDetails[0].LoanAppl__r.AddationalComm__c?this.listDecisionSummaryDetails[0].LoanAppl__r.AddationalComm__c:'';
            //     this.PrsnldetailsofPromotrs=this.listDecisionSummaryDetails[0].LoanAppl__r.PrsnldetailsofPromotrs__c?this.listDecisionSummaryDetails[0].LoanAppl__r.PrsnldetailsofPromotrs__c:'';
            // }

           
           
            
        } else if (error) {
            console.error('Error loading Decision Summary: ', error);
        }
    }

    @wire(getUwAndApprover,{ recordId: '$recordId'})
    wiredgetUwAndApprover({ data, error }) {
        if (data) {
            console.log('recordIdForDecision-->'+this.recordId);
            this.uwAndApprover = data;
            console.log('Approver data-->'+JSON.stringify(this.uwAndApprover));
            this.fedfinaUnderwriter = this.uwAndApprover[0];
            this.fedfinaApprover = this.uwAndApprover[1]
            
        } else if (error) {
            console.error('Error loading Uw and Approver: ', error);
        }
    }

    @wire(getLoanDetailsSummary,{ recordId: '$recordId'})
wiredGetLoanDetailsSummary({ data, error }) {

    if (data) {
       // console.log('RECORDS:::::::',data);
        this.listOfLoanDetailsSummary = data;
      //  this.linkedLoans = this.listOfLoanDetailsSummary.linkedLoans.joint(',');
       // system.debug('linkedLoans-->'+this.linkedLoans);
        console.log('listOfLoanDetailsSummary decision-->'+JSON.stringify(this.listOfLoanDetailsSummary));
    } if (error) {
        console.log('ERROR:::::::', error);
    }
}

}