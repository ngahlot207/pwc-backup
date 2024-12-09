import { LightningElement,track,api } from 'lwc';

export default class EmiCalculatorOnLead extends LightningElement {

    @track declredMontlyIncVal;
    @track declredMontlyOblVal;
    @track isCalculatorOpen = false;

    // Function to open the EMI calculator modal
    openCalculator() {
        this.isCalculatorOpen = true;
    }

    @api openPopup() {
        // Code to open the popup
        this.isCalculatorOpen = true;
    }

    handleCloseClick() {
        // Code to close the popup
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleValueChange(event){
        if(event.target.name === 'declMonthInc')
        {
            this.declredMontlyIncVal = event.target.value;
        }
        if(event.target.name === 'declMonthObl')
        {
            this.declredMontlyOblVal = event.target.value;
        }
    }
    resetValues(){
        this.declredMontlyIncVal = '';
        this.declredMontlyOblVal = '';
    }
    calculateEMI(){
        
    }
}