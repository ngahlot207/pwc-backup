public class FinfortOrderDeliveryResponseWrapper {
    
    public HeaderInfo headerInfo;//Both(ITR,GST)

	public List<ItrPl> PL;//ITR
    public List<ItrBs> BS;//ITR
    public List<RatiosAnalysis> Ratios_Analysis;//ITR
    public List<WorkingCapitalAnalysis> Working_Capital_Analysis;//ITR
    public List<gstMonth> GST_Colated;//ITR
    public gstMonth GST_last12Months;//ITR
    public List<gstMonth> GST_or_Sales_Register_for_CFY;//ITR
    public List<gstMonth> GST_Location1;//ITR
    public List<gstMonth> GST_Location2;//ITR
    public List<gstMonth> GST_Location3;//ITR
    public List<gstMonth> GST_Location4;//ITR
    public List<gstMonth> GST_Location5;//ITR
    public List<gstMonth> GST_Location6;//ITR
    
	public DATA data;//GST

    public Class HeaderInfo{
        
        public String ffOrderNumber;//Both(ITR,GST)
        public String lenderRefNumber;//Both(ITR,GST)
        public String legalName;//ITR
        public String taxpayerType;//ITR
        public String constitution;//ITR
        public String registrationDate;//ITR
        public String pan;//Both(ITR,GST)
        public String state;
		//public string order_number;
    }

	/***************************************************ITR*********************************************************************/
    public class ItrPl{
        
        public String FY;	//Mar-22
		public String Date_of_Filing;	//19-09-2022
		public String Total_Sales;	//57748015
		public String Other_Operating_Income;	//0
		public String Non_Business_Income;	//90967
		public String Opening_Stock;	//11511479
		public String Closing_Stock;	//10042189
		public String Purchases;	//54334394
		public String Direct_Expenses;	//169139
		public String Gross_Profit;	//1775192
		public String Office_And_Administrative_Expenses;	//900276
		public String Other_Indirect_Expenses;	//261506
		public String Non_Operating_Expenses;	//0
		public String Salary_To_Partners_or_Directors;	//0
		public String EBITDA;	//613410
		public String Interest_On_Term_Loans;	//0
		public String Interest_On_CC_or_OD_Limits;	//0
		public String Interest_On_Partners_Capital;	//0
		public String Profit_Before_Depreciation_and_Tax;	//704377
		public String Depreciation;	//103389
		public String Profit_Before_Tax;	//600988
		public String Taxes;	//29222
		public String PAT;	//571766
    }
    
    public class ItrBs{
        
        public String FY;	//Mar-22
		public String Share_Capital_or_Partners_Capital;	//13036840//replace
		public String PL_AC;	//0
		public String Revaluation_Reserves_Notional_Reserves;	//0
		public String Net_Worth;	//13036840
		public String Advances_To_Group_Co_Or_Friends;	//0
		public String Unsecured_Loans_From_Promoters_And_Family_Members;	//0
		public String Misc_Exp_Not_Written_Off;	//0
		public String Adjusted_Tangible_Networth;	//13036840
		public String Bank_Borrowing_Working_Capital;	//0
		public String Secured_Debts_Banks_And_Nbfc;	//262601
		public String Unsecured_Debt_Banks_And_Nbfc;	//4984437
		public String Other_Loans;	//6957647
		public String Total_Loan_Funds;	//12204685
		public String Sundry_Creditors;	//279936
		public String Advances_From_Customers;	//0
		public String Other_Current_Liabilities;	//0
		public String Provisions;	//0
		public String Deffered_Tax_Liability;	//0
		public String Total_Liabilities;	//25521461
		public String Assets;	//0
		public String Net_Tangible_Fixed_Assets;	//2609369
		public String Net_Intangible_Fixed_Assets;	//0
		public String Stock;	//10042189
		public String Debtors_Less_Than_6_Months;	//5096327
		public String Debtors_Greater_Than_6_Months;	//0
		public String Advances_To_Suppliers;	//0
		public String Investments;	//73200
		public String Other_Loans_And_Advances;	//0
		public String Prepaid_Expenses;	//0
		public String Other_Current_Assets;	//6152456
		public String Other_Non_Current_Assets_Security_Deposits;	//0 replace
		public String Cash_And_Bank_Balances;	//1547920
		public String Total_Assets;	//25521461
		public String Difference;
    }

    public class RatiosAnalysis{

        public String Particulars;	//Mar-22
		public String Turnover;	//577
		public String Turnover_Growth_Rate_Percent;	//0.00
		public String EBIDTA_Or_PBDIT;	//6
		public String PBDT;	//7
		public String PBT;	//6
		public String PAT;	//6
		public String Cash_Profit;	//7
		public String Gross_Profit_Margin_Percent;	//3.07
		public String Net_Profit_Margin_Percent;	//1.04
		public String Total_Current_Liabilities;	//3
		public String Total_Current_Assets;	//229
		public String Total_Debt;	//122
		public String Adjusted_Net_Worth;	
    }

   public class WorkingCapitalAnalysis{

        public String Particulars;	//Mar-22
		public String Debtors;	//51
		public String Creditors;	//3
		public String Stock_Value;	//100
		public String Debtors_Collection_Period;	//32
		public String Creditors_Payment_Period;	//2
		public String Stock_Replenishment_Period;	//65
		public String Inventory_Turnover;	//5
		public String Net_Working_Capital;	//226
		public String Current_Ratio;	//82
		public String Quick_Ratio;	//46
		public String Interest_Coverage_Ratio;	// 
		public String Debt_Equity_Ratio;	//1
		public String Leverage_Ratio;

   }
 
   public class gstMonth{

    public string FY;
    public string Jan;
    public string Feb;
    public string Mar;
    public string Apr;
    public string May;
    public string Jun;
    public string Jul;
    public string Aug;
    public string Sep;
    public string Oct;
    public string Nov;
    public string Dec;
    public string gst_total;
    public string Total_Turnover;
   }


/***************************************************GST*********************************************************************/

 public class DATA{
   
	public List<GST> gst;

 }


 public class GST {
   
	public META meta;
	public List<innerCommanTags> summary_analysis_data;
	public List<innerCommanTags> summary_data;
	public List<innerCommanTags> customer_supplier_data;
	public List<innerCommanTags> hsn_chapter_data;
	//public List<circulartransactiondata> circular_transaction_data;
	public List<profileexceldata> profile_excel_data;
	public List<filingdata> filing_data;
	public List<innerCommanTags> sales_bifurcation_data;
	public List<innerCommanTags> purchase_bifurcation_data;
	public List<innerCommanTags> gstr3b_data;
 }

 public class META{
   
	public String key;
	public Integer order_detail_id;
	public String status;
 }

 public class innerCommanTags{
 
	public string fy;
	public string quarter;
	public string month;
	public string startDate;
	public string endDate;
	public string period_type;
	public string cs_type;
	public innerData data;
 }

 //public class circulartransactiondata{

 //}
 public class profileexceldata{

	public string legal_name;
	public string trade_name;
	public string pan;
	public string gstin;
	public string registration_date;
	public string cancellation_date;
	public string ctb;
	public string taxpayer_type;
	public string gst_status;
	public string nature_of_core_business;
	public string nba;
	public string adadr;
	public string pr_adr_loc;
	public string pr_adr_stcd;
	public string state_juisdiction;
	public string state_juisdiction_code;
	public string central_juisdiction;
	public string central_juisdiction_code;
	public Double pr_adr_lt;
	public Double pr_adr_lg;
	public string last_updated_date;

 }
 public class filingdata{

	public string gstin;
	public string financialYear;
	public string taxPeriod;
	public string returnType;
	public string dueDate;
	public string filingDate;
	public integer delayedDays;
	public string modify_date;

 }

 public class innerData{

	//summary_analysis_data Tags
	//public Double id;
	//public Double workorder_type_id;
	//public Double company_master_id;
	 public string gstin;//summary_data Tags,summary_analysis_data Tags,customer_supplier_data,sales_bifurcation_data
	//public string fy;
	//public string period_type;
	//public string period_start_date;
	//public string period_end_date;
	//public string lull_months;
	public Double total_adjusted_revenue;//summary_data Tags,summary_analysis_data Tags,customer_supplier_data,gstr3b_data
	public Double total_adjusted_revenue_monthly_average;
	public Double total_adjusted_revenue_quarterly_average;
	public Double revenue_growth_YoY;
	public Double total_purchase_and_expenses;//summary_data Tags,summary_analysis_data Tags
	public Double total_purchase_and_expenses_monthly_average;
	public Double total_purchase_and_expenses_quarterly_average;
	public Double margin;//summary_data Tags,summary_analysis_data Tags
	public Double margin_percentage;//summary_data Tags,summary_analysis_data Tags
	public Double margin_growth_YoY;
    public Double margin_monthly_average;
	public Double margin_quarterly_average;
	//public Double top_20_customers_revenue_percentage;
	//public Double customers_gt_5_percent_revenue;
	//public Double customers_gt_2_percent_revenue;
	//public Double customers_gt_1_percent_revenue;
	//public Double total_active_customers;
	//public Double top_20_new_customers_added_count;
	//public Double top_20_new_customers_added_revenue;
	//public Double top_20_new_customers_added_revenue_percentage;
	//public Double customer_attrition;
	//public Double top_20_existing_customers_added_count;
	//public Double top_20_existing_customers_added_revenue;
	//public Double top_20_existing_customers_added_revenue_percentage;
	//public Double monthly_active_customers_count;
	//public Double monthly_active_customers_revenue_percentage;
	//public Double quarterly_active_customers_count;
	//public Double quarterly_active_customers_revenue_percentage;
	//public Double annually_active_customers_count;
	//public Double sporadic_active_customers_count;
	//public Double annually_active_customers_revenue_percentage;
	//public Double sporadic_active_customers_revenue_percentage;
	//public Double growing_trend_customers_count;
	//public Double growing_trend_customers_revenue_percentage;
	//public Double degrowing_trend_customers_count;
	//public Double degrowing_trend_customers_revenue_percentage;
	//public Double stagnant_customers_count;
	//public Double stagnant_customers_revenue_percentage;
	public Double top_10_products_revenue_percentage;
	public Integer products_gt_5_percent_revenue;
	public Integer products_gt_2_percent_revenue;
	public Integer products_gt_1_percent_revenue;
	public Integer growing_trend_products_count;
	public Double growing_trend_products_revenue_percentage;
	public Integer degrowing_trend_products_count;
	public Double degrowing_trend_products_revenue_percentage;
	public Integer stagnant_products_count;
	public Double stagnant_products_revenue_percentage;
	public Integer top_10_new_products_added_count;
	public Double top_10_new_products_added_revenue;
	public Double top_10_new_products_added_revenue_percentage;
    //public Double top_10_chapters_revenue_percentage;
	//public Double chapters_gt_5_percent_revenue;
	//public Double chapters_gt_2_percent_revenue;
	//public Double chapters_gt_1_percent_revenue;
	//public Double growing_trend_chapters_count;
	//public Double growing_trend_chapters_revenue_percentage;
	//public Double degrowing_trend_chapters_count;
	//public Double degrowing_trend_chapters_revenue_percentage;
	//public Double stagnant_chapters_count;
	//public Double stagnant_chapters_revenue_percentage;
	//public Double top_10_new_chapters_added_count;
	//public Double top_10_new_chapters_added_revenue;
	//public Double top_10_new_chapters_added_revenue_percentage;
	public Double top_20_suppliers_revenue_percentage;
	public Integer suppliers_gt_5_percent_purchases;
	public Integer suppliers_gt_2_percent_purchases;
	public Integer suppliers_gt_1_percent_purchases;
	public Double gst_paid_through_cash;
	public Double average_gst_blocked_for_month;
	public Double average_wc_blocked_gst;
	public Double circular_transactions;
	public Double circular_transactions_revenue_percentage;
	

	//summary_data Tags
	public string peak_or_lull;

	//customer_supplier_data Tags
	public Integer rank_no;
	public string trade_name;
	public string cs_active_type;
	public integer no_of_months_active;
	public Double tax_val;
	public Double tax_val_percentage;
	public Double avg_invoice_value;
	public Double avg_monthly_value;
	public string category_flag;
	public string is_new;
	public Double sub_total;
	public Double others;
	public Double except_b2b;
	public Double total_adjusted_purchases_and_expenses;
	public string legal_name;
	public string ctb;
	public string nba;
	public string address;
	public string pr_adr_loc;
	public string pr_adr_stcd;
	public string taxpayer_type;
	public string gst_status;
	public string registration_date;
	public string cancellation_date;
	public string filing_regularity;

	//hsn_chapter_data Tags
	public string hsn_chapter;
	public Integer ranking_of_revenue_from_sale_of_products;
	public Integer hsn_of_goods;
	public String system_description;
	public Double revenue_from_sale_product;
	public Double product_revenue_percentage;
	public string peak_months;
	public Double monthly_avg_product_revenue;

	//sales_bifurcation_data Tags
	public double b2b_tax_val;//purchase_bifurcation_data
	public double dnr_tax_val;
	public double cnr_tax_val;
	public double b2ba_tax_val;//purchase_bifurcation_data
	public double adj_rev_b2b_tax_val;
	public double b2b_total_revenue_percentage;
	public double b2cl_tax_val;
	public double dnur_b2cl_tax_val;
	public double cnur_b2cl_tax_val;
	public double b2cla_tax_val;
	public double adj_rev_b2cl_tax_val;
	public double b2cl_total_revenue_percentage;
	public double b2cs_tax_val;
	public double dnur_b2cs_tax_val;
	public double cnur_b2cs_tax_val;
	public double b2csa_tax_val;
	public double adj_rev_b2cs_tax_va;
	public double b2cs_total_revenue_percentage;
	public double exempted_tax_val;
	public double exempted_total_revenue_percentage;
	public double nil_rated_tax_val;
	public double nil_rated_total_revenue_percentage;
	public double non_gst_tax_val;
	public double non_gst_total_revenue_percentage;
	public double total_domestic_sales_tax_val;
	public double dnur_total_tax_val;
	public double cnur_total_tax_val;
	public double amd_tax_val;
	public double adj_rev_domestic_val;
	public double total_domestic_sales_total_revenue_percentage;
	public double exports_tax_val;
	public double exportsa_tax_val;
	public double adj_rev_exports_val;
	public double rev_of_domestic_and_exports;
	public double dnur_total_tax_val2;
	public double cnur_total_tax_val2;
	public double amd_total_tax_val2;
	public double total_operational_revenue_tax_val;
	public double advances_received;

	//purchase_bifurcation_data
	public Double debit_notes_tax_val;
	public double credit_notes_tax_val;
	public Double b2b_adjusted_inward_supplies;
	public Double b2b_total_pur_exp_per;
	public Double b2b_rchrg_tax_val;
	public Double debit_notes_rcharg_tax_val;
	public Double credit_notes_rcharg_tax_val;
	public Double b2ba_rchrg_tax_val;
	public Double b2b_adjusted_rcharg_inward_supplies;
	public Double b2b_rchrg_total_pur_exp_per;
	public Double purchase_and_expenses_total;
	public Double debit_notes_tax_val_total;
	public Double credit_notes_tax_val_total;
	public Double amendment_purchase_invoice;
	public Double adjusted_purchase_and_expenses;
	public Double purchase_expense_percentage;

	//gstr3b_data
     public Double total_taxable_value;
	 public Double diff_gstr1_gstr3b;
	 public Double out_tax_supplies;
	 public Double out_tax_supplies_zero_rated;
	 public Double out_tax_supplies_nil_rated_exempted;
	 public Double out_tax_supplies_non_gst;

 }
 
/***************************************************Callback Response Wrapper*********************************************************************/

    public class CallbackWrapper{
        
        public Integer code;
        public String lender_name;
        public String lender_referenceNumber;
        public String ffOrderId;
        public String borrower_pan;
        public String dataTransferStatus;
        public String failureReason;
    }

}