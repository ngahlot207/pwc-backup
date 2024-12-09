public class ApplicantEligibility implements Comparable{
        
        //These are BRE Eligibility data
        @auraEnabled public String ApplicantId{get;set;}
        @auraEnabled public string applicantRecord{get;set;}
        
        @auraEnabled public decimal obligationAMount{get;set;}
        
        //  @auraEnabled public string breApplicantRecord{get;set;}
        // @auraEnabled public Applicant__c applicantRecord{get;set;}
        @auraEnabled public decimal cashFlowAssedIncome{get;set;}
        @auraEnabled public decimal businessIncome{get;set;}
        @auraEnabled public decimal grossSalaryBankCredit{get;set;}
        @auraEnabled public decimal netSalaryBankCredit{get;set;}
        
        //These are Applicant data
        @auraEnabled public string assesmentProgram{get;set;}
        @auraEnabled public decimal cashSalary{get;set;}
        @auraEnabled public decimal rentalBankCredit{get;set;}
        @auraEnabled public  boolean showRentalWBankCredit{get;set;}
        @auraEnabled public decimal rentalWithoutBankCredit{get;set;}
        @auraEnabled public decimal PensionIncome{get;set;}
        @auraEnabled public decimal AgricultureIncome{get;set;}
        @auraEnabled public decimal OtherIncome{get;set;}
   		@auraEnabled Public DateTime applicantCreatedDate{get;set;}
        
        //These Are BRE Respnse data
        
          @auraEnabled public decimal MaxEMIOtherCashSalaryAppltn{get;set;}
         @auraEnabled public decimal MaxEMICashSalaryAppltn{get;set;}
        @auraEnabled public decimal ApprMonthIncOtherthanCashSalaryAppltn{get;set;}
        
        @auraEnabled public decimal RAACROI{get;set;}
        @auraEnabled public decimal ApprMonthIncOtherthanCashSalary{get;set;}
        @auraEnabled public decimal ApplFOIR{get;set;}
        @auraEnabled public decimal ApplEMINetSalary {get;set;}
        @auraEnabled public decimal MaxEMIOtherCashSalary{get;set;}
        @auraEnabled public decimal ApplFOIRCashSalary{get;set;}
        @auraEnabled public decimal MaxEMICashSalary{get;set;}
        @auraEnabled public decimal EliTenureMonths{get;set;}
        @auraEnabled public decimal LoanEliOtherCashSalary{get;set;}
        @auraEnabled public decimal FinLoanEliCashSalary{get;set;}
        @auraEnabled public decimal FinLoanEliTotal{get;set;}
        @auraEnabled public decimal MaxFinLoanElideviation{get;set;}
        @auraEnabled public string ApplLevelAssprogram{get;set;}
        
        @auraEnabled public decimal MaxBreLnEliWoIns{get;set;}
        @auraEnabled public decimal MaxBreLnEliWIns{get;set;}
        @auraEnabled public decimal MaxBreLnEliWDeviation{get;set;}
        
        //Recommandation Table Fields data 
        @auraEnabled public decimal EMI{get;set;}
        @auraEnabled public decimal ActuaFOIR{get;set;}
        @auraEnabled public decimal ActualLTV{get;set;}
        @auraEnabled public decimal CombLTVFOIR{get;set;}
        
        //These Are BRE data for Type Property
        @auraEnabled public decimal LTVApplLnWOInsurance{get;set;}
        @auraEnabled public decimal LTVApplLnWtInsurance{get;set;}
        @auraEnabled public decimal LTVBsdEliWOIns{get;set;}
        @auraEnabled public decimal AddLTVBsdEliIns{get;set;}      
        @auraEnabled public decimal TotlLTVBsdLnEliWIns{get;set;}
        @auraEnabled public decimal LTVApplWDeviation{get;set;}
        @auraEnabled public decimal MaxcoltrlLnEliWDeviation{get;set;}
        //These Are SFDC data for Type Property
        @auraEnabled public string PropAddrs{get;set;} 
        @auraEnabled public string PropType{get;set;}
        @auraEnabled public string PropSubType{get;set;}
        @auraEnabled public string PropertyUsage{get;set;}
        @auraEnabled public decimal ApproxValue{get;set;}
        
    	public DateTime getApplicantCreatedDate() {
        	return applicantCreatedDate;
		}
    	public Integer compareTo(Object obj) {
            if (obj == null || !(obj instanceof ApplicantEligibility)) {
                return 0; // Handle the case where obj is not an instance of ApplicantEligibility
            }
    
            ApplicantEligibility otherApplicant = (ApplicantEligibility)obj;
    
            // Compare applicantCreatedDate of the current instance with the other instance
            if (this.applicantCreatedDate > otherApplicant.getApplicantCreatedDate()) {
                return 1;
            } else if (this.applicantCreatedDate < otherApplicant.getApplicantCreatedDate()) {
                return -1;
            } else {
                return 0;
            }
    	}
        
}