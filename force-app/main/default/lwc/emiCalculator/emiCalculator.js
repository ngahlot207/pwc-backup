import { LightningElement,track } from 'lwc';

export default class EmiCalculator extends LightningElement {
    
    @track emiAmount;
    @track eligibilityInLacs;
    @track declaredMonthlyIncome;
    @track declaredMonthlyObligation;
    tenureInMonths =180;
    rateOfInterest=0.1;
    fixedObligationsToIncomeRatio = 0.5;
    isShowshowEMICalculatorModal=false;


    handleEMIChange(event){

        if(event.target.name === 'Declared Monthly Income'){
            this.declaredMonthlyIncome = event.target.value;

        }else if(event.target.name === 'Declared Monthly Obligation'){
            this.declaredMonthlyObligation = event.target.value;
        }

        //this.calculateEMI();
    }
    calculateEMI(){

        if(this.declaredMonthlyIncome>0 && this.declaredMonthlyObligation>0){

            var emiPerLac = (((this.rateOfInterest/12) * Math.pow((1+this.rateOfInterest/12),180)) / (Math.pow((1+this.rateOfInterest/12),180)-1) * Math.pow(10,5)).toFixed(2);
            console.log(':::::::::::',emiPerLac);
            var eligibilityInLacs = ((this.declaredMonthlyIncome * this.fixedObligationsToIncomeRatio - this.declaredMonthlyObligation) / emiPerLac);
            this.eligibilityInLacs = eligibilityInLacs.toFixed(2);
            console.log(':::::::::::',this.eligibilityInLacs);
            this.emiAmount = eligibilityInLacs * emiPerLac;
        }else{

            this.emiAmount=undefined;
        }
        
    }

    
    showEMICalculatorModal(){

        this.declaredMonthlyIncome = undefined;
        this.declaredMonthlyObligation = undefined;
        this.emiAmount = undefined;
        this.eligibilityInLacs=undefined;
        this.isShowshowEMICalculatorModal=true;
    }
    
    hideEMICalculatorModal(){
        this.isShowshowEMICalculatorModal=false;
    }
}