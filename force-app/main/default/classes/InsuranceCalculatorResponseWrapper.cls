public class InsuranceCalculatorResponseWrapper {

    public class EGIC_Co_App {
		public Double PA_CI_Sum_Assured;
		public Integer Policy_Tenure_Years;
		public Double Gross_Policy_Premium;
	}

	public List<Data> Data;
	public Integer status;
	public String message;

	public class HDFC {
		public Double Sum_Assured;
		public Integer Policy_Tenure_Years;
		public Double Gross_Policy_Premium;
	}

	public class Data {
		public String CustomerName;
		public String DateofBirth;
		public Integer Applicant_Age;
		public Integer LoanAmount;
		public Integer LoanTenure_Months;
		public Double Ins_Penetration;
		public Double Applicant_Insurance_Premium;
		public String PlanName;
		public Integer PolicyTenure;
		public Double PRates_M4;
		public Double Eff_Stax;
		public Double Limited_Funded;
		public Double HDFC_Funded;
		public Double RevisedSumAssured;
		public Double InsurancePrimium;
		public Integer Validations;
		public Double InsurancePrimiumTax;
		public Double PremiumPayable;
		public HDFC HDFC;
		public Double EGIC_Pending_Premium;
		public Double EGIC_Pending_Premium_for_Without_Tax;
		public Double PA_15_CIRate;
		public Double Applicant_Net_Premium;
		public Double Applicant_Balance_Premium;
		public Double PA_15_CI_Sum_Assured;
		public Double Sum_Assured_Without_Tax_Net_Premium;
		public EGIC EGIC;
		public String Co_Applicant_CustomerName;
		public String Co_Applicant_DateofBirth;
		public Integer Co_Applicant_Age;
		public Double Co_Applicant_PA_15_CIRate;
		public Double Co_Applicant_Net_Premium;
		public Double Co_Applicant_InsurancePrimiumTax;
		public Double EGIC_Co_Applicant_PA_15_CI_Sum_Assured;
		public EGIC_Co_App EGIC_Co_App;
		public Double Total_Premium_HI_GI;
		public String RequiredPenetration;
	}

	public class EGIC {
		public Double PA_CI_Sum_Assured;
		public Integer Policy_Tenure_Years;
		public Double InsurancePrimiumTax;
		public Double Gross_Policy_Premium;
		public Double Premium_WithoutTax;
	}

	
	public static InsuranceCalculatorResponseWrapper parse(String json) {
		return (InsuranceCalculatorResponseWrapper) System.JSON.deserialize(json, InsuranceCalculatorResponseWrapper.class);
	}
    
}