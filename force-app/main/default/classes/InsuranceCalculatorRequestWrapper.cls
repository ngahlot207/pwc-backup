public class InsuranceCalculatorRequestWrapper {
    
    public String CustomerName;
	public String DateofBirth;
	public Integer LoanAmount;
	public Integer LoanTenure_Months;
	public Integer Ins_Penetration;
	public String PlanName;
	public Integer PolicyTenure;
	public Double PRates_M4;
	public Integer Eff_Stax;
	public Integer Validations;
	public Integer HDFC_Policy_Tenure_Years;
	public Integer EGIC_Policy_Tenure_Years;
	public Integer EGIC_CO_Applicant_Policy_Tenure_Years;
	public String Co_Applicant_CustomerName;
	public String Co_Applicant_DateofBirth;

	
	public static InsuranceCalculatorRequestWrapper parse(String json) {
		return (InsuranceCalculatorRequestWrapper) System.JSON.deserialize(json, InsuranceCalculatorRequestWrapper.class);
	}

}