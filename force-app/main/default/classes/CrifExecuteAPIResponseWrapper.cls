public class CrifExecuteAPIResponseWrapper {

    public StrategyOneResponse StrategyOneResponse;

    public class StrategyOneResponse {
        public Header Header;
        public Body Body;
		public Error Error;
    }
    public class Header {
        public String InquiryCode;	//REQUESTID
        public String ProcessCode;	//Fedfina_MSE
        public String OrganizationCode;	//ORGID
        
    }
	public class Error{
		public String InquiryDate;
		public String Code;
		public String Description;
		public String EngineVersion;

	}
    public class Body {
       public application APPLICATION;
    }

    public class application{
        public Variables Variables;
        public List<Categories> Categories;
    }

    public class Variables{

        public Double call_id;
		public String application_id;
		public String login_acceptance_date;
		public Double Final_Loan_Amount_Output;
		public Double Actual_LTV_without_Insurance;
		public Double Actual_FOIR_without_Insurance;
		public Double eligibile_loan_tenure_months;
		public Double eligible_loan_amount;
		public Double dpd60_no_36m;
		public Double count_total_tradeline_last6month;
		public Double dpd_gt30_all_active;
		public Double dpd_gt30_last6months;
		public Double LTV_with_Insurance;
		public Double LTV_without_Insurance;
		public Double max_current_dpd_of_all_live_facilities;
		public Double max_dpd_in_last_12_months_of_all_live_facilities;
		public Double max_recent_delq;
		public Double newest_tradeline_month;
		public Double oldest_tradeline_months;
		public String product_bre;
		public Double ratio_current_disb_amt;
		public Double ratio_of_outstanding_amt_to_disbursed_amt_for_pl;
		public Double recent_enquiry_days;
		public Double total_active_tradelines_in_last_12_months;
		public Double total_credit_card_outstanding;
		public Double total_gl_no;
		public Double total_live_bl_pl_loan_exposure;
		public Double total_live_credit_card_overdue;
		public Double total_live_loan_exposure;
		public Double total_live_loan_overdue;
		public Double total_live_mortgage_loan_exposure;
		public Double total_live_secured_loan_exposure;
		public Double total_mortgage_enquiries_in_last_30_days;
		public Double total_no_of_live_loans;
		public Double total_pl_no;
		public Double total_secured_bal;
		public Double total_unsecured_bal;
		public Double total_unsecured_bl_pl_enquiries_in_last_30_days;
		public Double monthly_appraised_income;
		public String selected_eligibility_program;
		public Double RAAC_ROI;
		public Double dpd_l12m;
		public Double dpd_gt30_active_notin_gl_fl_cd_cc_50k;
		public Double dpd_gt90_l6m;
		public Double dpd_l12m_gl_fl_cd_cc_50k;
		public Double dpd_l12m_notin_gl_fl_cd_cc_50k;
		public Double dpd_lt30_l6m;
		public Double dpd_lt90_l6m;
		public Double dpd_lt30_l12m;
		public String Deviation_Reason;
		public String Reject_Reason;
		public String Decision;
		public String selected_eligibility_program_value;
		public Double Valuation_Considered;
		public String Rejection_Authority;
		public Double EMI;
		public Double LTV_RAAC_MV;
		public Double LTV_RAAC_Insurance_MV;
		public Double LTV_Deviation;
		public Double LTV_Deviation_Insurance_COP;
		public Double LTV_Deviation_Insurance_MV;
		public Double LTV_RAAC_COP;
		public Double LTV_RAAC_Insurance_COP;
		public Double dpd_gt30_all;
		public Double Total_Outstanding_BL;
		public Double dpd_lt30_l6m_all_acct;
		public Double dpd_gt90_l6m_all_acct;
		public Double Eligible_EMI_Salaried;
		public Double Combined_LTV_And_FOIR_without_Insurance;
		public Double Actual_LTV_with_Insurance;
		public Double Actual_FOIR_with_Insurance;
		public Double Combined_LTV;
		public Double LTV_with_Deviation;
		public Double Max_EMI_other_than_cash_salary;
		public Double Max_EMI_cash_salary;
		public Double Max_BRE_Loan_eligiblity_with_deviation;
		public Double Max_BRE_Loan_eligiblity_with_insurance;
		public Double Max_BRE_Loan_eligiblity_without_insurance;
		public Double Max_collateral_loan_eligibility_with_deviation;
		public Double LTV_Applicable_with_deviation;
		public Double Additional_LTV_based_Eligiblity_towards_Insurance;
		public Double LTV_based_eligibility_with_insurance;
		public Double LTV_based_eligibility_without_insurance;
		public Double LTV_Applicable_for_Loan_with_Insurance;
		public Double LTV_Applicable_for_Loan_without_Insurance;
		public Double Combined_LTV_And_FOIR_with_Insurance;
		public Double Considered_perc_Other_Income;
		public Double Considered_perc_Agriculture_Income;
		public Double Considered_perc_Pension_Income;
		public Double Considered_perc_Rental_without_Bank_Credit;
		public Double Considered_perc_Rental_Bank_Credit;
		public Double Considered_perc_Cash_Salary;
		public Double Considered_perc_Net_Eligible_Salary_with_Bank_Credit;
		public Double Considered_perc_Gross_Eligible_Salary_with_Bank_Credit;
		public Double Considered_perc_Business_Income_Regular_Income_Program;
		public Double Considered_perc_Cash_Flow_Assessed_Income;
		public Double Financial_Loan_Eligibility_total;
		public Double Financial_Loan_Eligibility_cash_salary;
		public Double Financial_Loan_Eligibility_other_than_cash_salary;
		public Double Max_Financial_Loan_Eligibility_with_deviation;
        public string Final_Customer_Profile;
        //LAK-6157 Changes
		public Double max_plot_funding;
		public Double max_plot_funding_with_insurance;
		public Double max_plot_funding_with_deviation;
		public Double max_funding_home_improvement_without_insurance;
        public Double max_funding_home_improvement_with_insurance;
        public Double max_funding_home_improvement_with_deviation;
		//public Double pct_currentBal_all_TL; 
		public Double num_times_60p_dpd;
		public Double max_recent_level_of_deliq;
		public Double Gold_TL; 
        //public Double Age_Oldest_TL_Mnths;
		public Double Age_Newest_TL_Mnths;
		public Double Tot_Unsecured_Bal;
		public Double Tot_Secured_Bal;
		public Double Tot_Other_Bal;
		public Double Tot_Active_TL_L12M;
		public Double time_since_recent_enq;
		public Double RF_Prob;
		public Double PL_TL;
		public Double PL_cuurbal_highcredit;
		public Double Total_TL_Open_L6M;
		public Double max_delinquency_level_max;
		public Double Financial_Loan_Eligibility_other_than_cash_salary_Deviation;
		public Double Financial_Loan_Eligibility_cash_salary_Deviation;
		public String Decision_Scorecard_Stage_2;
		public String Decision_Scorecard_Stage_1;
		public Double Avg_Score;
		public Double Num_Open_CC_TL_max;
        
        //LAK-6471 Start
        public string Deviation_Decision;
        public Double revised_roi_perc;
        public Double Age_Oldest_TL_Mnths_max;
        public string Final_Decision_Scorecard;
        public string Hard_Policy_Decision;
        public Double time_since_recent_delinquency_min;
        public Double pct_of_active_TLs_ever_min;
        public Double Unsec_utilization_max;
        public string Application_Scorecard_Result;
        public Double Cumulative_LTV_Pc;
        public Double Max_Plot_Funding_overall_eligibility;
        //LAK-6471 End
    }

    public class Categories{
      public DEVIATION DEVIATION;
      public PROPERTY PROPERTY;
      public APPLICANT APPLICANT;
      public COAPPLICANT COAPPLICANT;
      public GUARANTOR GUARANTOR;
    }

    public class DEVIATION{
     
        public deviationvariable Variables;

    }
    public class deviationvariable{
        public Double Deviation_Code;
		public String Deviation_Reason;
		public String Deviation_Authority;
        Public String Deviation_BRE_Decision;

    }

    public class PROPERTY{
     
        public propertyvariables Variables;
    }

    public class propertyvariables{

        public Double Max_collateral_loan_eligibility_with_deviation;
		public Double LTV_Applicable_with_deviation;
		public Double Additional_LTV_based_Eligiblity_towards_Insurance;
		public Double LTV_based_eligibility_with_insurance;
		public Double LTV_based_eligibility_without_insurance;
		public Double LTV_Applicable_for_Loan_with_Insurance;
		public Double LTV_Applicable_for_Loan_without_Insurance;
        public string unique_id;
		//LAK-6157 Changes
		//public Double max_plot_funding;
		//public Double max_plot_funding_with_insurance;
		//public Double max_plot_funding_with_deviation;
    }

    public class APPLICANT{

        public applicantvariabels Variables;
    }

    public class applicantvariabels{

        //public String Decision;
		public Double age;
		public Double age_at_loan_maturity;
		public Double business_vintage;
		public Double dpd_l12m;
		public Double dpd_gt30_last6months;
		public Double dpd_gt30_all_active;
		public Double ratio_current_disb_amt;
		public Double oldest_tradeline_months;
		public Double total_secured_bal;
		public Double count_total_tradeline_last6month;
		public Double max_current_dpd_of_all_live_facilities;
		public Double max_dpd_in_last_12_months_of_all_live_facilities;
		public Double max_recent_delq;
		public Double newest_tradeline_month;
		public Double ratio_of_outstanding_amt_to_disbursed_amt_for_pl;
		public Double recent_enquiry_days;
		public Double total_active_tradelines_in_last_12_months;
		public Double total_credit_card_outstanding;
		public Double total_gl_no;
		public Double total_live_bl_pl_loan_exposure;
		public Double total_live_credit_card_overdue;
		public Double total_live_loan_exposure;
		public Double total_live_loan_overdue;
		public Double total_live_mortgage_loan_exposure;
		public Double total_live_secured_loan_exposure;
		public Double total_mortgage_enquiries_in_last_30_days;
		public Double total_no_of_live_loans;
		public Double total_pl_no;
		public Double total_unsecured_bal;
		public Double total_unsecured_bl_pl_enquiries_in_last_30_days;
		public Double dpd_gt30_active_notin_gl_fl_cd_cc_50k;
		public Double dpd_gt90_l6m;
		public Double dpd_l12m_gl_fl_cd_cc_50k;
		public Double dpd_l12m_notin_gl_fl_cd_cc_50k;
		public Double dpd_lt30_l6m;
		public Double dpd_lt90_l6m;
		public Double dpd60_no_36m;
		public Double dpd_lt30_l12m;
		public Double max_cash_salary;
		public Double monthly_appraised_income;
		public Double monthly_other_income;
		public String income_matrix_output;
		public Double dpd_gt30_all;
		public Double Total_Outstanding_BL;
		public Double dpd_lt30_l6m_all_acct;
		public Double dpd_gt90_l6m_all_acct;
		public Double monthly_core_income;
		public Double Max_EMI_other_than_cash_salary;
		public Double Max_EMI_cash_salary;
		public Double Other_Deducation_considered;
		public Double Performance_Bonus_considered;
		public Double Annual_Benefits_like_LTA_considered;
		public Double Variable_Component_considered;
		public Double Gross_salary_considered;
		public Double Tax_considered;
		public Double Interest_on_Loan_considered;
		public Double Interest_on_Partners_Capital_Renum_Inc_considered;
		public Double Depreciation_considered;
		public Double Profit_Before_Tax_considered;
		public Double Net_Eligible_Salary_with_Bank_Credit;
		public Double Gross_Eligible_Salary_with_Bank_Credit;
		public Double Considered_perc_other_deductions;
		public Double Considered_perc_Performance_Bonus;
		public Double Considered_perc_annual_benefits;
		public Double Considered_perc_variable_component;
		public Double Considered_perc_Gross_Salary;
		public Double Monthly_Business_Income_Regular_Income_Program;
		public Double Annual_Business_Income_Regular_Income_Program;
		public Double Considered_perc_tax;
		public Double Applicable_EMI_Net_to_Salary;
		public Double Applicable_FOIR_cash_salary;
		public Double Applicable_FOIR;
		public Double Considered_perc_Interest_on_Loan;
		public Double Considered_perc_Interest_on_Partners_Capital_Renum_Inc;
		public Double Considered_perc_Depreciation;
		public Double Considered_perc_Profit_Before_Tax;
        //LAK-6157 Changes
		public Double pct_currentBal_all_TL;
		public Double Other_Deduction_considered;
		public Double num_times_60p_dpd;
		public Double max_recent_level_of_deliq;
		public Double Gold_TL;
		public Double cust_current_outstanding;
		public Double Considered_perc_Profit_After_Tax;
		public Double Considered_perc_LIC_Agent_Commisssion_Renewal_Bonus;
		public Double Considered_perc_LIC_Agent_Commisssion_NewBusiness_Bonus;
		public Double Age_Oldest_TL_Mnths;
		public Double Age_Newest_TL_Mnths;
		public Double Tot_Unsecured_Bal;
		public Double Tot_Secured_Bal;
		public Double Tot_Other_Bal;
		public Double Tot_Active_TL_L12M;
		public Double time_since_recent_enq;
		public Double Time_Since_Last_Payment_inMnths;
		public Double RF_Prob;
		public Double Profit_After_Tax_considered;
		public Double PL_TL;
		public Double PL_cuurbal_highcredit;
		public String type_of_account_value; 
		public Double Total_TL_Open_L6M;
        
        //LAK-6471 Start
        public string Deviation_Decision;
        public Double Total_currBal_openTLs;
        public Double Unsec_utilization;
        public Double total_num_TLs_Active_and_opened_inLast_6_months;
        public Double tot_enq_InLast_3months;
        public Double max_delinquency_level;
        public Double Total_limit_openTLs;
        public Double pct_tot_deliq_TLs;
        public Double total_PL_open_TLs;
        public Double AL_cuurbal_highcredit;
        public Double ratio_unsecCurrBal_SecCurrBal_openTLs;
        public Double pct_of_active_TLs;
        //LAK-6471 End
	}
   
    public class COAPPLICANT{

        public co_applicantvariabels Variables;
    }

    public class co_applicantvariabels{

        //public String Decision;
		public Double age;
		public Double age_at_loan_maturity;
		public Double business_vintage;
		public Double dpd_l12m;
		public Double dpd_gt30_last6months;
		public Double dpd_gt30_all_active;
		public Double ratio_current_disb_amt;
		public Double oldest_tradeline_months;
		public Double total_secured_bal;
		public Double count_total_tradeline_last6month;
		public Double max_current_dpd_of_all_live_facilities;
		public Double max_dpd_in_last_12_months_of_all_live_facilities;
		public Double max_recent_delq;
		public Double newest_tradeline_month;
		public Double ratio_of_outstanding_amt_to_disbursed_amt_for_pl;
		public Double recent_enquiry_days;
		public Double total_active_tradelines_in_last_12_months;
		public Double total_credit_card_outstanding;
		public Double total_gl_no;
		public Double total_live_bl_pl_loan_exposure;
		public Double total_live_credit_card_overdue;
		public Double total_live_loan_exposure;
		public Double total_live_loan_overdue;
		public Double total_live_mortgage_loan_exposure;
		public Double total_live_secured_loan_exposure;
		public Double total_mortgage_enquiries_in_last_30_days;
		public Double total_no_of_live_loans;
		public Double total_pl_no;
		public Double total_unsecured_bal;
		public Double total_unsecured_bl_pl_enquiries_in_last_30_days;
		public Double dpd_gt30_active_notin_gl_fl_cd_cc_50k;
		public Double dpd_gt90_l6m;
		public Double dpd_l12m_gl_fl_cd_cc_50k;
		public Double dpd_l12m_notin_gl_fl_cd_cc_50k;
		public Double dpd_lt30_l6m;
		public Double dpd_lt90_l6m;
		public Double dpd60_no_36m;
		public Double dpd_lt30_l12m;
		public Double max_cash_salary;
		public Double monthly_appraised_income;
		public Double monthly_other_income;
		public Double dpd_gt30_all;
		public Double Total_Outstanding_BL;
		public Double dpd_lt30_l6m_all_acct;
		public Double dpd_gt90_l6m_all_acct;
		public Double monthly_core_income;
		public Double Max_EMI_other_than_cash_salary;
		public Double Max_EMI_cash_salary;
		public Double Other_Deducation_considered;
		public Double Performance_Bonus_considered;
		public Double Annual_Benefits_like_LTA_considered;
		public Double Variable_Component_considered;
		public Double Gross_salary_considered;
		public Double Tax_considered;
		public Double Interest_on_Loan_considered;
		public Double Interest_on_Partners_Capital_Renum_Inc_considered;
		public Double Depreciation_considered;
		public Double Profit_Before_Tax_considered;
		public Double Net_Eligible_Salary_with_Bank_Credit;
		public Double Gross_Eligible_Salary_with_Bank_Credit;
		public Double Considered_perc_other_deductions;
		public Double Considered_perc_Performance_Bonus;
		public Double Considered_perc_annual_benefits;
		public Double Considered_perc_variable_component;
		public Double Considered_perc_Gross_Salary;
		public Double Monthly_Business_Income_Regular_Income_Program;
		public Double Annual_Business_Income_Regular_Income_Program;
		public Double Considered_perc_tax;
		public Double Applicable_EMI_Net_to_Salary;
		public Double Applicable_FOIR_cash_salary;
		public Double Applicable_FOIR;
		public Double Considered_perc_Interest_on_Loan;
		public Double Considered_perc_Interest_on_Partners_Capital_Renum_Inc;
		public Double Considered_perc_Depreciation;
		public Double Considered_perc_Profit_Before_Tax;
        public string unique_id;
		//LAK-6157 Changes
		public Double pct_currentBal_all_TL;
	    public Double Other_Deduction_considered;
		public Double num_times_60p_dpd;
		public Double max_recent_level_of_deliq;
		public Double Gold_TL;
		public Double cust_current_outstanding;
		public Double Considered_perc_Profit_After_Tax;
		public Double Considered_perc_LIC_Agent_Commisssion_Renewal_Bonus;
		public Double Considered_perc_LIC_Agent_Commisssion_NewBusiness_Bonus;
		public Double Age_Oldest_TL_Mnths;
		public Double Age_Newest_TL_Mnths;
		public Double Tot_Unsecured_Bal;
		public Double Tot_Secured_Bal;
		public Double Tot_Other_Bal;
		public Double Tot_Active_TL_L12M;
		public Double time_since_recent_enq;
		public Double Time_Since_Last_Payment_inMnths;
		public Double RF_Prob;
		public Double Profit_After_Tax_considered;
		public Double PL_TL;
		public Double PL_cuurbal_highcredit;
		public String type_of_account_value;
		public Double Total_TL_Open_L6M;
        
        //LAK-6471 Start
        public string Deviation_Decision;
        public Double Total_currBal_openTLs;
        public Double Unsec_utilization;
        public Double total_num_TLs_Active_and_opened_inLast_6_months;
        public Double tot_enq_InLast_3months;
        public Double max_delinquency_level;
        public Double Total_limit_openTLs;
        public Double pct_tot_deliq_TLs;
        public Double total_PL_open_TLs;
        public Double AL_cuurbal_highcredit;
        public Double ratio_unsecCurrBal_SecCurrBal_openTLs;
        public Double pct_of_active_TLs;
        //LAK-6471 End
	}

    public class GUARANTOR{

        public guarantorvariabels Variables;

    }

    public class guarantorvariabels{
        //public String Decision;
		public Double age;
		public Double age_at_loan_maturity;
		public Double business_vintage;
		public Double dpd_l12m;
		public Double dpd_gt30_last6months;
		public Double dpd_gt30_all_active;
		public Double ratio_current_disb_amt;
		public Double oldest_tradeline_months;
		public Double total_secured_bal;
		public Double count_total_tradeline_last6month;
		public Double max_current_dpd_of_all_live_facilities;
		public Double max_dpd_in_last_12_months_of_all_live_facilities;
		public Double max_recent_delq;
		public Double newest_tradeline_month;
		public Double ratio_of_outstanding_amt_to_disbursed_amt_for_pl;
		public Double recent_enquiry_days;
		public Double total_active_tradelines_in_last_12_months;
		public Double total_credit_card_outstanding;
		public Double total_gl_no;
		public Double total_live_bl_pl_loan_exposure;
		public Double total_live_credit_card_overdue;
		public Double total_live_loan_exposure;
		public Double total_live_loan_overdue;
		public Double total_live_mortgage_loan_exposure;
		public Double total_live_secured_loan_exposure;
		public Double total_mortgage_enquiries_in_last_30_days;
		public Double total_no_of_live_loans;
		public Double total_pl_no;
		public Double total_unsecured_bal;
		public Double total_unsecured_bl_pl_enquiries_in_last_30_days;
		public Double dpd_gt30_active_notin_gl_fl_cd_cc_50k;
		public Double dpd_gt90_l6m;
		public Double dpd_l12m_gl_fl_cd_cc_50k;
		public Double dpd_l12m_notin_gl_fl_cd_cc_50k;
		public Double dpd_lt30_l6m;
		public Double dpd_lt90_l6m;
		public Double dpd60_no_36m;
		public Double dpd_lt30_l12m;
		public Double max_cash_salary;
		public Double monthly_appraised_income;
		public Double monthly_other_income;
		public Double dpd_gt30_all;
		public Double Total_Outstanding_BL;
		public Double dpd_lt30_l6m_all_acct;
		public Double dpd_gt90_l6m_all_acct;
		public Double monthly_core_income;
		public Double Max_EMI_other_than_cash_salary;
		public Double Max_EMI_cash_salary;
		public Double Considered_perc_Interest_on_Loan;
		public Double Considered_perc_Interest_on_Partners_Capital_Renum_Inc;
		public Double Considered_perc_Depreciation;
		public Double Considered_perc_Profit_Before_Tax;
        public string unique_id;
		//LAK-6157 Changes
		public Double pct_currentBal_all_TL;
		public Double num_times_60p_dpd;
		public Double max_recent_level_of_deliq;
		public Double Gold_TL;
		public Double cust_current_outstanding;
		public Double Age_Oldest_TL_Mnths;
		public Double Age_Newest_TL_Mnths;
		public Double Tot_Unsecured_Bal;
		public Double Tot_Secured_Bal;
		public Double Tot_Other_Bal;
		public Double Tot_Active_TL_L12M;
		public Double time_since_recent_enq;
		public Double Time_Since_Last_Payment_inMnths;
		public Double RF_Prob;
		public Double PL_TL;
		public Double PL_cuurbal_highcredit;
		public Double Total_TL_Open_L6M;
        
        //LAK-6471 Start
        public string Deviation_Decision;
        public Double Total_currBal_openTLs;
        public Double Unsec_utilization;
        public Double total_num_TLs_Active_and_opened_inLast_6_months;
        public Double tot_enq_InLast_3months;
        public Double max_delinquency_level;
        public Double Total_limit_openTLs;
        public Double pct_tot_deliq_TLs;
        public Double total_PL_open_TLs;
        public Double AL_cuurbal_highcredit;
        public Double ratio_unsecCurrBal_SecCurrBal_openTLs;
        public Double pct_of_active_TLs;
        //LAK-6471 End
	 }
    public static CrifExecuteAPIResponseWrapper parse(String json){
        return (CrifExecuteAPIResponseWrapper) System.JSON.deserialize(json, CrifExecuteAPIResponseWrapper.class);
    }
}