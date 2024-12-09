public class DummyForCalculateAPR {
    //public Decimal generateCashFlows(Decimal monthlyPayment, Decimal netDisbursementAmount, Integer loanPeriodMonths,decimal loanAmount,string businessUnit,String schemeName,string loanAppId) {
	 public static final double GUESS=(double)0.1;
    public static final Integer MAX_ITERATION_COUNT=120;
    public static final double ABSOLUTE_ACCURACY=0.0000001;
    public Decimal generateCashFlows() {
         //16160.00, 1050000.00, 180,1050000.00
        List<Decimal> cashFlows = new List<Decimal>();
    	//Decimal netDisbursementAmount=1027940.00;
    	Decimal netDisbursementAmount=1027940.00;
         Decimal monthlyPayment=16160.00;
         integer loanPeriodMonths=180;
         decimal loanAmount=1050000.00;
         //string businessUnit= 'new Gold Loan';
        Decimal apr;
        Decimal irrMonthly;
        cashFlows.add(-netDisbursementAmount);
        //if(businessUnit == 'Gold Loan'){
            //if(schemeName.containsIgnoreCase(System.Label.Scheme_Name_Monthly)||schemeName.containsIgnoreCase(System.Label.Scheme_Name_Renewal_Monthly)){
                //loanPeriodMonths = loanPeriodMonths-1;
            //}
        //}
        //System.debug('loanPeriodMonths: ' + loanPeriodMonths);
        //if(businessUnit != 'Gold Loan'){
            cashFlows.addAll(generateMonthlyPayments(monthlyPayment, loanPeriodMonths));
        //}
        //else if(!(schemeName.containsIgnoreCase(System.Label.Scheme_Name_Bullet)||schemeName.containsIgnoreCase(System.Label.Scheme_Name_Renewal_Bullet))){
           // cashFlows.addAll(generateMonthlyPayments(monthlyPayment, loanPeriodMonths));
       // }
        
        /*if(businessUnit == 'Gold Loan'){
            if(schemeName.containsIgnoreCase(System.Label.Scheme_Name_Bullet)||schemeName.containsIgnoreCase(System.Label.Scheme_Name_Renewal_Bullet)){
                cashFlows.add(monthlyPayment );
            }
            else if(schemeName.containsIgnoreCase(System.Label.Scheme_Name_Monthly)||schemeName.containsIgnoreCase(System.Label.Scheme_Name_Renewal_Monthly)){
                cashFlows.add(loanAmount + monthlyPayment);
            }
        }*/
        System.debug('cashFlows: ' + cashFlows);
        irrMonthly = calculateIRR(cashFlows,GUESS,'a08C40000082ahBIAQ');
        apr = (irrMonthly * 12 * 100);
        apr= apr.setScale(2, RoundingMode.HALF_UP);
        /*if(businessUnit == 'Gold Loan'){
            if(schemeName.containsIgnoreCase(System.Label.Scheme_Name_Monthly)||schemeName.containsIgnoreCase(System.Label.Scheme_Name_Renewal_Monthly)){
                apr = (irrMonthly * 12 * 100).setScale(2, System.RoundingMode.HALF_UP);
            }
            else if(schemeName.containsIgnoreCase(System.Label.Scheme_Name_Bullet)||schemeName.containsIgnoreCase(System.Label.Scheme_Name_Renewal_Bullet)){
                apr = (irrMonthly * 100).setScale(2, System.RoundingMode.HALF_UP);
            }
            else{
                apr = (irrMonthly * 12 * 100).round(RoundingMode.HALF_UP);
            }
            System.debug('Annual Percentage Rate (APR): ' + apr);
        }
        else{
            apr = (irrMonthly * 12 * 100).round(RoundingMode.HALF_UP);
        }*/
        System.debug('Annual Percentage Rate (APR): ' + apr);
        return apr;
    }
    
    private List<Decimal> generateMonthlyPayments(Decimal monthlyPayment, Integer periods) {
        List<Decimal> payments = new List<Decimal>();
        for (Integer i = 1; i <= periods; i++) {
            payments.add(monthlyPayment.setScale(0, System.RoundingMode.HALF_UP));
        }
        return payments;
    }
    
    // Method to calculate IRR (Internal Rate of Return)
    private Decimal calculateIRR(List<Decimal> cashFlows,double guess,string loanAppId) {
        Decimal irr = guess;
        try {
            Decimal npv = 0;
            Decimal npvDerivative = 0;
            Decimal irrDelta = 0;
            Integer iterations = 0;
            
            while (iterations < MAX_ITERATION_COUNT) {
                npv = 0;
                npvDerivative = 0;
                
                for (Integer i = 0; i < cashFlows.size(); i++) {
                    Decimal base = 1 + irr;
                    npv += cashFlows[i] / Math.pow(base.doubleValue(), i);
                    
                    if (i > 0) {
                        Decimal denominator = Math.pow(base.doubleValue(), i + 1);
                        npvDerivative -= i * cashFlows[i] / denominator;
                    }
                }
                
                irrDelta = npv / npvDerivative;
                irr -= irrDelta;
                iterations++;
                
                // Check for convergence within acceptable tolerance
                if (Math.abs(irrDelta) <= ABSOLUTE_ACCURACY) {
                    break;
                }
            }
            
            return irr;
            
        } catch (Exception ex) {
            //SaveResult result = new SaveResult();
            //result.addError('Error : '+ex.getMessage()+' : '+ex.getStackTraceString()).addErrorToLog(ex,null,loanAppId ,'generateCashFlows','IFB_ALL_KFSUtility');
            System.debug('An error occurred: ' + ex.getMessage());
            return 0; 
        }
    }
}