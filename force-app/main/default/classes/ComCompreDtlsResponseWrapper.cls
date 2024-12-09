public class ComCompreDtlsResponseWrapper{

	public String message {get;set;} 
	public class Shareholdings {
		public String shareholders {get;set;} 
		public Integer year {get;set;} 
		public String category {get;set;} 
		public String financial_year {get;set;} 
		public Integer indian_held_no_of_shares {get;set;} 
		public Integer indian_held_percentage_of_shares {get;set;} 
		public Integer nri_held_no_of_shares {get;set;} 
		public Integer nri_held_percentage_of_shares {get;set;} 
		public Integer foreign_held_other_than_nri_no_of_shares {get;set;} 
		public Integer foreign_held_other_than_nri_percentage_of_shares {get;set;} 
		public Integer central_government_held_no_of_shares {get;set;} 
		public Integer central_government_held_percentage_of_shares {get;set;} 
		public Integer state_government_held_no_of_shares {get;set;} 
		public Integer state_government_held_percentage_of_shares {get;set;} 
		public Integer government_company_held_no_shares {get;set;} 
		public Integer government_company_held_percentage_of_shares {get;set;} 
		public Integer insurance_company_held_no_of_shares {get;set;} 
		public Integer insurance_company_held_percentage_of_shares {get;set;} 
		public Integer bank_held_no_of_shares {get;set;} 
		public Integer bank_held_percentage_of_shares {get;set;} 
		public Integer financial_institutions_held_no_of_shares {get;set;} 
		public Integer financial_institutions_held_percentage_of_shares {get;set;} 
		public Integer financial_institutions_investors_held_no_of_shares {get;set;} 
		public Integer financial_institutions_investors_held_percentage_of_shares {get;set;} 
		public Integer mutual_funds_held_no_of_shares {get;set;} 
		public Integer mutual_funds_held_percentage_of_shares {get;set;} 
		public Integer venture_capital_held_no_of_shares {get;set;} 
		public Integer venture_capital_held_percentage_of_shares {get;set;} 
		public Integer body_corporate_held_no_of_shares {get;set;} 
		public Integer body_corporate_held_percentage_of_shares {get;set;} 
		public String others_source {get;set;} 
		public Integer others_held_no_of_shares {get;set;} 
		public Integer others_held_percentage_of_shares {get;set;} 
		public Integer total_no_of_shares {get;set;} 
		public Integer total_percentage_of_shares {get;set;} 

	}
	
	public class Company {
		public String cin {get;set;} 
		public String legal_name {get;set;} 
		public String efiling_status {get;set;} 
		public String incorporation_date {get;set;} 
		public Double paid_up_capital {get;set;} 
		public Double sum_of_charges {get;set;} 
		public Double authorized_capital {get;set;} 
		public String active_compliance {get;set;} 
		public Registered_address registered_address {get;set;} 
		public Business_address business_address {get;set;} 
		public String pan {get;set;} 
		public String website {get;set;} 
		public String classification {get;set;} 
		public String status {get;set;} 
		public String last_agm_date {get;set;} 
		public String last_filing_date {get;set;} 
		public String email {get;set;} 
		public Lei lei {get;set;} 

	}
	
	public class Pnl_key_schedule {
		public Integer managerial_remuneration {get;set;} 
		public Integer payment_to_auditors {get;set;} 
		public Integer insurance_expenses {get;set;} 
		public Integer power_and_fuel {get;set;} 

	}
	
	public class Email {
		public String emailId {get;set;} 
		public String status {get;set;} 

	}
	
	public class Rating_details_Z {
		public String rating {get;set;} 
		public String type_of_loan {get;set;} 
		public Integer amount {get;set;} 
		public String currency_Z {get;set;} // in json: currency
		public String date_of_non_acceptance {get;set;} 

	}
	
	public class Address {
		public String address_line1 {get;set;} 
		public String address_line2 {get;set;} 
		public String city {get;set;} 
		public String pincode {get;set;} 
		public String state {get;set;} 
		public String country {get;set;} 

	}
	
	public class Companies {
		public String cin {get;set;} 
		public String legal_name {get;set;} 
		public String company_status {get;set;} 
		public String incorporation_date {get;set;} 
		public Double paid_up_capital {get;set;} 
		public Double sum_of_charges {get;set;} 
		public String city {get;set;} 
		public String active_compliance {get;set;} 
		public String designation {get;set;} 
		public String date_of_appointment {get;set;} 
		public String date_of_appointment_for_current_designation {get;set;} 
		public String date_of_cessation {get;set;} 
}
	
	public class Llps {
		public String llpin {get;set;} 
		public String legal_name {get;set;} 
		public String status {get;set;} 
		public String incorporation_date {get;set;} 
		public Double total_obligation_of_contribution {get;set;} 
		public Double sum_of_charges {get;set;} 
		public String city {get;set;} 
		public String designation {get;set;} 
		public String date_of_appointment {get;set;} 
		public String date_of_appointment_for_current_designation {get;set;} 
		public String date_of_cessation {get;set;} 

	}
	
	public class Revenue_breakup {
		public Integer revenue_from_operations {get;set;} 
		public Integer revenue_from_interest {get;set;} 
		public Integer revenue_from_other_financial_services {get;set;} 
		public Integer revenue_from_sale_of_products {get;set;} 
		public Integer revenue_from_sale_of_services {get;set;} 
		public Integer other_operating_revenues {get;set;} 
		public Integer excise_duty {get;set;} 
		public Integer service_tax_collected {get;set;} 
		public Integer other_duties_taxes_collected {get;set;} 
		public Integer sale_of_goods_manufactured_domestic {get;set;} 
		public Integer sale_of_goods_traded_domestic {get;set;} 
		public Integer sale_or_supply_of_services_domestic {get;set;} 
		public Integer sale_or_supply_of_services_export {get;set;} 
		public Integer sale_of_goods_manufactured_export {get;set;} 
		public Integer sale_of_goods_traded_export {get;set;} 

	}
	
	public class Liabilities_Z {
		public Integer derivative_financial_instruments {get;set;} 
		public Integer dues_of_micro_and_small_enterprises_TP {get;set;} 
		public Integer dues_of_creditors_TP {get;set;} 
		public Integer dues_of_micro_and_small_enterprises_OP {get;set;} 
		public Integer dues_of_creditors_OP {get;set;} 
		public Integer debt_securities {get;set;} 
		public Integer deposits {get;set;} 
		public Integer borrowings_other_than_debt_securities {get;set;} 
		public Integer provisions {get;set;} 
		public Integer other_non_financial_liabilities {get;set;} 
		public Integer equity_share_capital {get;set;} 
		public Integer sh_app_money_pending_allotment {get;set;} 
		public Integer eq_comp_of_compound_fin_instruments {get;set;} 
		public Integer statutory_reserves {get;set;} 
		public Integer capital_reserves {get;set;} 
		public Integer securities_premium {get;set;} 
		public Integer current_tax_liabilities_net {get;set;} 
		public Integer subordinated_liabilities {get;set;} 
		public Integer other_financial_liabilities {get;set;} 
		public Integer other_reserves {get;set;} 
		public Integer deferred_tax_liabilites_net {get;set;} 
		public Integer retained_earnings {get;set;} 
		public Integer debt_through_other_comprehensive_income {get;set;} 
		public Integer equity_through_other_comprehensive_income {get;set;} 
		public Integer effective_portion_of_cash_flow_hedges {get;set;} 
		public Integer exchange_diff_translating_of_foreign_operation {get;set;} 
		public Integer revaluation_surplus {get;set;} 
		public Integer other_items_of_other_comprehensive_income {get;set;} 
		public Integer money_received_against_share_warrants {get;set;} 
		public Integer non_controlling_interest {get;set;} 
		public Integer given_other_equity {get;set;} 
		public Integer given_liabilities_total {get;set;} 

	}
	
	public class SubTotals {
		public Integer total_equity {get;set;} 
		public Integer total_current_liabilities {get;set;} 
		public Integer net_fixed_assets {get;set;} 
		public Integer total_current_assets {get;set;} 
		public Integer capital_wip {get;set;} 
		public Integer total_debt {get;set;} 

	}
	
	public class BenchMarks {
		public String year {get;set;} 
		public Integer no_of_peers_in_sample {get;set;} 
		public Integer revenue {get;set;} 
		public Integer revenue_growth {get;set;} 
		public Integer net_margin {get;set;} 
		public Integer ebitda_margin {get;set;} 
		public Integer return_on_equity {get;set;} 
		public Integer sales_by_net_fixed_assets {get;set;} 
		public Integer inventory_holding_period {get;set;} 
		public Integer debtor_days_outstanding {get;set;} 
		public Integer trade_payable_days {get;set;} 
		public Integer cash_conversion_cycle {get;set;} 
		public Integer debt_by_equity {get;set;} 
		public Integer median_revenue {get;set;} 
		public Integer median_revenue_growth {get;set;} 
		public Integer median_net_margin {get;set;} 
		public Integer median_ebitda_margin {get;set;} 
		public Integer median_return_on_equity {get;set;} 
		public Integer median_sales_by_net_fixed_assets {get;set;} 
		public Integer median_inventory_holding_period {get;set;} 
		public Integer median_debtor_days_outstanding {get;set;} 
		public Integer median_trade_payable_days {get;set;} 
		public Integer median_cash_conversion_cycle {get;set;} 
		public Integer median_debt_by_equity {get;set;} 

	}
	
	public class Peer_comparison {
		public String bizIndustry {get;set;} 
		public String bizSegment {get;set;} 
		public String refYear {get;set;} 
		public List<Peers> peers {get;set;} 
		public List<BenchMarks> benchMarks {get;set;} 

	}
	
	public class Pnl {
		public LineItems lineItems {get;set;} 
		public SubTotals_Z subTotals {get;set;} 
		public Revenue_breakup revenue_breakup {get;set;} 
		public Depreciation_breakup depreciation_breakup {get;set;} 
		public Metadata_Z metadata {get;set;} 

	}
	
	public class Cash_flow {
		public Integer profit_before_tax {get;set;} 
		public Integer adjustment_for_finance_cost_and_depreciation {get;set;} 
		public Integer adjustment_for_current_and_non_current_assets {get;set;} 
		public Integer adjustment_for_current_and_non_current_liabilities {get;set;} 
		public Integer other_adjustments_in_operating_activities {get;set;} 
		public Integer cash_flows_from_used_in_operating_activities {get;set;} 
		public Integer cash_outflow_from_purchase_of_assets {get;set;} 
		public Integer cash_inflow_from_sale_of_assets {get;set;} 
		public Integer income_from_assets {get;set;} 
		public Integer other_adjustments_in_investing_activities {get;set;} 
		public Integer cash_flows_from_used_in_investing_activities {get;set;} 
		public Integer cash_outflow_from_repayment_of_capital_and_borrowings {get;set;} 
		public Integer cash_inflow_from_raisng_capital_and_borrowings {get;set;} 
		public Integer interest_and_dividends_paid {get;set;} 
		public Integer other_adjustments_in_financing_activities {get;set;} 
		public Integer cash_flows_from_used_in_financing_activities {get;set;} 
		public Integer incr_decr_in_cash_cash_equv_before_effect_of_excg_rate_changes {get;set;} 
		public Integer adjustments_to_cash_and_cash_equivalents {get;set;} 
		public Integer incr_decr_in_cash_cash_equv {get;set;} 
		public Integer cash_flow_statement_at_end_of_period {get;set;} 

	}
	
	public class Auditor {
		public String auditor_name {get;set;} 
		public String auditor_firm_name {get;set;} 
		public String pan {get;set;} 
		public String membership_number {get;set;} 
		public String firm_registration_number {get;set;} 
		public String adress {get;set;} 

		
	}
	
	public class SubTotals_Z {
		public Integer total_operating_cost {get;set;} 

	
	}
	
	public class SubTotals_Y {
		public Integer total_equity {get;set;} 
		public Integer total_non_financial_assets {get;set;} 
		public Integer total_financial_assets {get;set;} 
		public Integer total_assets {get;set;} 
		public Integer total_financial_liabilities {get;set;} 
		public Integer total_non_financial_liabilities {get;set;} 
		public Integer total_equity_and_liabilities {get;set;} 

	}
	
	public class Others_Z {
		public String legal_name {get;set;} 
		public Integer share_holding_percentage {get;set;} 

	}
	
	public class Bs_Z {
		public Assets_Z assets {get;set;} 
		public Liabilities_Z liabilities {get;set;} 
		public SubTotals_Y subTotals {get;set;} 
		public Metadata_Z metadata {get;set;} 
		public Notes notes {get;set;} 

		
	}
	
	public class Credit_rating_rationale {
		public String rating_agency {get;set;} 
		public String financial_year {get;set;} 
		public String doc_id {get;set;} 

	
	}
	
	public class Authorized_signatories {
		public String pan {get;set;} 
		public String din {get;set;} 
		public String name {get;set;} 
		public String designation {get;set;} 
		public String din_status {get;set;} 
		public String gender {get;set;} 
		public String date_of_birth {get;set;} 
		public Integer age {get;set;} 
		public String date_of_appointment {get;set;} 
		public String date_of_appointment_for_current_designation {get;set;} 
		public String date_of_cessation {get;set;} 
		public String nationality {get;set;} 
		public Address address {get;set;} 
		public List<Association_history> association_history {get;set;} 
}
	
	public class Liabilities {
		public Integer share_capital {get;set;} 
		public Integer reserves_and_surplus {get;set;} 
		public Integer money_received_against_share_warrants {get;set;} 
		public Integer share_application_money_pending_allotment {get;set;} 
		public Integer deferred_government_grants {get;set;} 
		public Integer minority_interest {get;set;} 
		public Integer long_term_borrowings {get;set;} 
		public Integer deferred_tax_liabilities_net {get;set;} 
		public Integer foreign_curr_monetary_item_trans_diff_liability_account {get;set;} 
		public Integer other_long_term_liabilities {get;set;} 
		public Integer long_term_provisions {get;set;} 
		public Integer short_term_borrowings {get;set;} 
		public Integer trade_payables {get;set;} 
		public Integer other_current_liabilities {get;set;} 
		public Integer short_term_provisions {get;set;} 
		public Integer given_liabilities_total {get;set;} 

	}
	
	public class Network {
		public List<Companies> companies {get;set;} 
		public List<Llps> llps {get;set;} 
}
	
	public class Association_history {
		public String event {get;set;} 
		public String event_date {get;set;} 
		public String designation_after_event {get;set;} 
		public String filing_date {get;set;} 

	}
	
	public Metadata metadata {get;set;} 
	public Data data {get;set;} 


	
	public class Business_address {
		public String address_line1 {get;set;} 
		public String address_line2 {get;set;} 
		public String city {get;set;} 
		public String pincode {get;set;} 
		public String state {get;set;} 

	}
	
	public class LineItems {
		public Integer net_revenue {get;set;} 
		public Integer total_cost_of_materials_consumed {get;set;} 
		public Integer total_purchases_of_stock_in_trade {get;set;} 
		public Integer total_changes_in_inventories_or_finished_goods {get;set;} 
		public Integer total_employee_benefit_expense {get;set;} 
		public Integer total_other_expenses {get;set;} 
		public Integer operating_profit {get;set;} 
		public Integer other_income {get;set;} 
		public Integer depreciation {get;set;} 
		public Integer profit_before_interest_and_tax {get;set;} 
		public Integer interest {get;set;} 
		public Integer profit_before_tax_and_exceptional_items_before_tax {get;set;} 
		public Integer exceptional_items_before_tax {get;set;} 
		public Integer profit_before_tax {get;set;} 
		public Integer income_tax {get;set;} 
		public Integer profit_for_period_from_continuing_operations {get;set;} 
		public Integer profit_from_discontinuing_operation_after_tax {get;set;} 
		public Integer minority_interest_and_profit_from_associates_and_joint_ventures {get;set;} 
		public Integer profit_after_tax {get;set;} 

	}
	
	public class Assets_Z {
		public Integer cash_equivalents {get;set;} 
		public Integer bank_balance_other_than_cash {get;set;} 
		public Integer derivative_financial_assets {get;set;} 
		public Integer trade_receivables {get;set;} 
		public Integer other_receivables {get;set;} 
		public Integer loans {get;set;} 
		public Integer investments {get;set;} 
		public Integer other_financial_assets {get;set;} 
		public Integer inventories {get;set;} 
		public Integer current_tax_assets_net {get;set;} 
		public Integer deferred_tax_assets_net {get;set;} 
		public Integer investment_property {get;set;} 
		public Integer biological_assets {get;set;} 
		public Integer property_plant_and_equipment {get;set;} 
		public Integer capital_work_in_progress {get;set;} 
		public Integer intangible_under_development {get;set;} 
		public Integer goodwill {get;set;} 
		public Integer other_intangibles {get;set;} 
		public Integer other_non_financial_assets {get;set;} 
		public Integer given_assets_total {get;set;} 

	}
	
	public class Peers {
		public String cin {get;set;} 
		public String legalName {get;set;} 
		public String city {get;set;} 
		public Integer revenue {get;set;} 

	}
	
	public class Trend {
		public String period {get;set;} 
		public Integer amount {get;set;} 

	}
	
	public class Industry_segments {
		public String industry {get;set;} 
		public List<String> segments {get;set;} 

	}
	
	public class Securities_allotment {
		public String allotment_type {get;set;} 
		public String allotment_date {get;set;} 
		public String instrument {get;set;} 
		public Integer total_amount_raised {get;set;} 
		public Integer number_of_securities_allotted {get;set;} 
		public Integer nominal_amount_per_security {get;set;} 
		public Integer premium_amount_per_security {get;set;} 

	}
	
	public class Revenue_breakup_Z {
		public Integer interest_income {get;set;} 
		public Integer dividend_income {get;set;} 
		public Integer rental_income {get;set;} 
		public Integer fees_and_commission_income {get;set;} 
		public Integer net_gain_on_fair_value_changes {get;set;} 
		public Integer net_gain_on_derecoginition_of_fin_instruments {get;set;} 
		public Integer sale_of_products {get;set;} 
		public Integer sale_of_services {get;set;} 
		public Integer other {get;set;} 

	}
	
	public class Pnl_key_schedule_Z {
		public Integer managerial_remuneration {get;set;} 
		public Integer paymentToAuditors {get;set;} 
		public Integer insuranceExpenses {get;set;} 
		public Integer powerAndFuel {get;set;} 

	}
	
	public class Open_charges {
		public Integer id {get;set;} 
		public String date_Z {get;set;} // in json: date
		public String holder_name {get;set;} 
		public Integer amount {get;set;} 
		public String type {get;set;} 

	}
	
	public class Legal_cases_of_financial_disputes {
		public List<Receivable> receivable {get;set;} 
		public List<Receivable> payable {get;set;} 

	}
	
	public class Shareholdings_more_than_five_percent {
		public String financial_year {get;set;} 
		public List<Company_Y> company {get;set;} 
		public List<Company_Y> llp {get;set;} 
		public List<Company_Y> individual {get;set;} 
		public List<Company_Y> others {get;set;} 

	}
	
	public class Cdr_history {
		public String date_Z {get;set;} // in json: date
		public String description {get;set;} 

	}
	
	public class Individual {
		public String name {get;set;} 
		public String relationship {get;set;} 
		public String legal_name {get;set;} 
		public String type_of_transaction {get;set;} 
		public String amount {get;set;} 
		public String din {get;set;} 

	}
	
	public class Delays {
		public String supplier_name {get;set;} 
		public String supplier_pan {get;set;} 
		public Integer amount_due {get;set;} 
		public String amount_due_from_date {get;set;} 

	}
	
	public class Rating_details {
		public String rating {get;set;} 
		public String action {get;set;} 
		public String outlook {get;set;} 
		public String remarks {get;set;} 

	}
	
	public class Gst_details {
		public String gstin {get;set;} 
		public String status {get;set;} 
		public String company_name {get;set;} 
		public String trade_name {get;set;} 
		public String state {get;set;} 
		public String state_jurisdiction {get;set;} 
		public String centre_jurisdiction {get;set;} 
		public String date_of_registration {get;set;} 
		public String taxpayer_type {get;set;} 
		public String nature_of_business_activities {get;set;} 
		public List<Filings> filings {get;set;} 

	}
	
	public class Auditor_comments {
		public String report_has_adverse_remarks {get;set;} 
		public List<Disclosures_auditor_report> disclosures_auditor_report {get;set;} 
		public List<Disclosures_director_report> disclosures_director_report {get;set;} 

	}
	
	public class Related_party_transactions {
		public String financial_year {get;set;} 
		public List<Company_Z> company {get;set;} 
		public List<Llp> llp {get;set;} 
		public List<Individual> individual {get;set;} 
		public List<Others> others {get;set;} 

	}
	
	public class Description {
		public String desc_thousand_char {get;set;} 

		}
	
	public class Company_Z {
		public String name {get;set;} 
		public String relationship {get;set;} 
		public String legal_name {get;set;} 
		public String type_of_transaction {get;set;} 
		public Integer amount {get;set;} 
		public String cin {get;set;} 

	}
	
	public class Metadata {
		public String api_version {get;set;} 
		public String last_updated {get;set;} 

	}
	
	public class Company_X {
		public String cin {get;set;} 
		public String legal_name {get;set;} 
		public Double paid_up_capital {get;set;} 
		public Double sum_of_charges {get;set;} 
		public String incorporation_date {get;set;} 
		public Integer share_holding_percentage {get;set;} 
		public String city {get;set;} 
		public String status {get;set;} 
		public String active_compliance {get;set;} 

	}
	
	public class Llp_Z {
		public String llpin {get;set;} 
		public String legal_name {get;set;} 
		public Double total_obligation_of_contribution {get;set;} 
		public Double sum_of_charges {get;set;} 
		public String incorporation_date {get;set;} 
		public String city {get;set;} 
		public String status {get;set;} 
		public Integer share_holding_percentage {get;set;} 

	}
	
	public class Nbfc_financials {
		public String year {get;set;} 
		public String nature {get;set;} 
		public String stated_on {get;set;} 
		public String filing_type {get;set;} 
		public String filing_standard {get;set;} 
		public Bs_Z bs {get;set;} 
		public Pnl_Z pnl {get;set;} 
		public Cash_flow_Z cash_flow {get;set;} 
		public Pnl_key_schedule_Z pnl_key_schedule {get;set;} 
		public Auditor auditor {get;set;} 
		public Auditor_comments auditor_comments {get;set;} 
		public List<Auditor> auditor_additonal {get;set;} 

	}
	
	public class Company_Y {
		public String name {get;set;} 
		public Integer shareholding_percentage {get;set;} 
		public Integer no_of_shares {get;set;} 

	}
	
	public class Open_charges_latest_event {
		public Integer id {get;set;} 
		public String date_Z {get;set;} // in json: date
		public String holder_name {get;set;} 
		public Integer amount {get;set;} 
		public String type {get;set;} 
		public String filing_date {get;set;} 
		public String property_type {get;set;} 
		public String number_of_chargeholder {get;set;} 
		public String instrument_description {get;set;} 
		public String rate_of_interest {get;set;} 
		public String terms_of_payment {get;set;} 
		public String property_particulars {get;set;} 
		public String extent_and_operation {get;set;} 
		public String other_terms {get;set;} 
		public String modification_particulars {get;set;} 
		public String joint_holding {get;set;} 
		public String consortium_holding {get;set;} 

	}
	
	public class Delays_for_period {
		public String latest_period {get;set;} 
		public Integer total_amount_due_for_period {get;set;} 
		public List<Delays> delays {get;set;} 

	}
	
	public class Establishments_registered_with_epfo {
		public String establishment_id {get;set;} 
		public String address {get;set;} 
		public String city {get;set;} 
		public String latest_date_of_credit {get;set;} 
		public String date_of_setup {get;set;} 
		public String establishment_name {get;set;} 
		public String exemption_status_edli {get;set;} 
		public String exemption_status_pension {get;set;} 
		public String exemption_status_pf {get;set;} 
		public Integer no_of_employees {get;set;} 
		public String principal_business_activities {get;set;} 
		public Integer amount {get;set;} 
		public String latest_wage_month {get;set;} 
		public String working_status {get;set;} 
		public List<Filing_details> filing_details {get;set;} 

	}
	
	public class Llp {
		public String name {get;set;} 
		public String relationship {get;set;} 
		public String legal_name {get;set;} 
		public String type_of_transaction {get;set;} 
		public Integer amount {get;set;} 
		public String llpin {get;set;} 

	}
	
	public class Director_network {
		public String name {get;set;} 
		public String pan {get;set;} 
		public String din {get;set;} 
		public Network network {get;set;} 

	}
	
	public class Unaccepted_rating {
		public String rating_agency {get;set;} 
		public List<Rating_details_Z> rating_details {get;set;} 

	}
	
	public class Disclosures_auditor_report {
		public String auditor {get;set;} 
		public String footnotes {get;set;} 

		
	}
	
	public class Phone {
		public String phoneNumber {get;set;} 
		public String status {get;set;} 

	}
	
	public class Assets {
		public Double tangible_assets {get;set;} 
		public Double producing_properties {get;set;} 
		public Double intangible_assets {get;set;} 
		public Double preproducing_properties {get;set;} 
		public Double tangible_assets_capital_work_in_progress {get;set;} 
		public Double intangible_assets_under_development {get;set;} 
		public Double noncurrent_investments {get;set;} 
		public Double deferred_tax_assets_net {get;set;} 
		public Double foreign_curr_monetary_item_trans_diff_asset_account {get;set;} 
		public Double long_term_loans_and_advances {get;set;} 
		public Double other_noncurrent_assets {get;set;} 
		public Double current_investments {get;set;} 
		public Double inventories {get;set;} 
		public Double trade_receivables {get;set;} 
		public Double cash_and_bank_balances {get;set;} 
		public Double short_term_loans_and_advances {get;set;} 
		public Double other_current_assets {get;set;} 
		public Double given_assets_total {get;set;} 

	}
	
	public class Financials {
		public String year {get;set;} 
		public String nature {get;set;} 
		public String stated_on {get;set;} 
		public String filing_type {get;set;} 
		public String filing_standard {get;set;} 
		public Bs bs {get;set;} 
		public Pnl pnl {get;set;} 
		public Cash_flow cash_flow {get;set;} 
		public Pnl_key_schedule pnl_key_schedule {get;set;} 
		public Auditor auditor {get;set;} 
		public Auditor_comments auditor_comments {get;set;} 
		public List<Auditor> auditor_additonal {get;set;} 

	}
	
	public class Charge_sequence {
		public Integer charge_id {get;set;} 
		public String status {get;set;} 
		public String date_Z {get;set;} // in json: date
		public Integer amount {get;set;} 
		public String holder_name {get;set;} 
		public String number_of_holder {get;set;} 
		public String property_type {get;set;} 
		public String filing_date {get;set;} 
		public String property_particulars {get;set;} 

	}
	
	public class Struckoff248_details {
		public String struck_off_status {get;set;} 
		public String restored_status {get;set;} 

	}
	
	public class Depreciation_breakup_Z {
		public Integer depreciation_and_amortization_and_impairment {get;set;} 

	}
	
	public class Name_history {
		public String name {get;set;} 
		public String date_Z {get;set;} // in json: date

	}
	
	public class Notes {
		public Integer gross_fixed_assets {get;set;} 
		public Integer trade_receivable_exceeding_six_months {get;set;} 

	}
	
	public class Contact_details {
		public List<Email> email {get;set;} 
		public List<Phone> phone {get;set;} 

	}
	
	public class Disclosures_director_report {
		public String auditor {get;set;} 
		public String director {get;set;} 
		public String footnotes {get;set;} 

	}
	
	public class Others {
		public String name {get;set;} 
		public String relationship {get;set;} 
		public String legal_name {get;set;} 
		public String type_of_transaction {get;set;} 
		public Integer amount {get;set;} 

	}
	
	public class Defaulter_list {
		public String date_Z {get;set;} // in json: date
		public String agency {get;set;} 
		public String bank {get;set;} 
		public String amount {get;set;} 

	}
	
	public class Metadata_Z {
		public String doc_id {get;set;} 

	}
	
	public class Data {
		public Company company {get;set;} 
		public Description description {get;set;} 
		public List<Name_history> name_history {get;set;} 
		public List<Authorized_signatories> authorized_signatories {get;set;} 
		public List<Director_network> director_network {get;set;} 
		public Contact_details contact_details {get;set;} 
		public List<Open_charges> open_charges {get;set;} 
		public List<Open_charges_latest_event> open_charges_latest_event {get;set;} 
		public List<Financials> financials {get;set;} 
		public List<Nbfc_financials> nbfc_financials {get;set;} 
		public List<Financial_parameters> financial_parameters {get;set;} 
		public List<Industry_segments> industry_segments {get;set;} 
		public List<Principal_business_activities> principal_business_activities {get;set;} 
		public List<Related_party_transactions> related_party_transactions {get;set;} 
		public List<Establishments_registered_with_epfo> establishments_registered_with_epfo {get;set;} 
		public List<Shareholdings> shareholdings {get;set;} 
		public List<Shareholdings_more_than_five_percent> shareholdings_more_than_five_percent {get;set;} 
		public List<Shareholdings_summary> shareholdings_summary {get;set;} 
		public List<Director_shareholdings> director_shareholdings {get;set;} 
		public List<Bifr_history> bifr_history {get;set;} 
		public List<Cdr_history> cdr_history {get;set;} 
		public List<Legal_history> legal_history {get;set;} 
		public List<Defaulter_list> defaulter_list {get;set;} 
		public List<Credit_ratings> credit_ratings {get;set;} 
		public List<Credit_rating_rationale> credit_rating_rationale {get;set;} 
		public List<Unaccepted_rating> unaccepted_rating {get;set;} 
		public Holding_entities holding_entities {get;set;} 
		public Holding_entities subsidiary_entities {get;set;} 
		public Associate_entities associate_entities {get;set;} 
		public Associate_entities joint_ventures {get;set;} 
		public List<Charge_sequence> charge_sequence {get;set;} 
		public List<Securities_allotment> securities_allotment {get;set;} 
		public List<Peer_comparison> peer_comparison {get;set;} 
		public Struckoff248_details struckoff248_details {get;set;} 
		public List<Gst_details> gst_details {get;set;} 
		public List<Msme_supplier_payment_delays> msme_supplier_payment_delays {get;set;} 
		public List<Legal_cases_of_financial_disputes> legal_cases_of_financial_disputes {get;set;} 

	}
	
	public class Associate_entities {
		public List<Company_X> companies {get;set;} 
		public List<Llp_Z> llps {get;set;} 
		public List<Others_Z> others {get;set;} 

	}
	
	public class Legal_history {
		public String petitioner {get;set;} 
		public String respondent {get;set;} 
		public String court {get;set;} 
		public String date_Z {get;set;} // in json: date
		public String case_status {get;set;} 
		public String case_number {get;set;} 
		public String case_category {get;set;} 
		public String case_type {get;set;} 

	}
	
	public class Bifr_history {
		public String date_Z {get;set;} // in json: date
		public String case_number {get;set;} 
		public String status {get;set;} 

	}
	
	public class Holding_entities {
		public String financial_year {get;set;} 
		public List<Company_X> company {get;set;} 
		public List<Llp_Z> llp {get;set;} 
		public List<Others_Z> others {get;set;} 

	}
	
	public class Msme_supplier_payment_delays {
		public List<Trend> trend {get;set;} 
		public Delays_for_period delays_for_period {get;set;} 

	}
	
	public class Registered_address {
		public String full_address {get;set;} 
		public String address_line1 {get;set;} 
		public String address_line2 {get;set;} 
		public String city {get;set;} 
		public String pincode {get;set;} 
		public String state {get;set;} 

	}
	
	public class Lei {
		public String number_Z {get;set;} // in json: number
		public String status {get;set;} 
		public String registration_date {get;set;} 
		public String last_updated_date {get;set;} 
		public String next_renewal_date {get;set;} 

	}
	
	public class Bs {
		public Assets assets {get;set;} 
		public Liabilities liabilities {get;set;} 
		public SubTotals subTotals {get;set;} 
		public Metadata_Z metadata {get;set;} 
		public Notes notes {get;set;} 

	}
	
	public class Credit_ratings {
		public String rating_date {get;set;} 
		public String rating_agency {get;set;} 
		public String rating {get;set;} 
		public String type_of_loan {get;set;} 
		public String currency_Z {get;set;} // in json: currency
		public Integer amount {get;set;} 
		public List<Rating_details> rating_details {get;set;} 

	}
	
	public class Pnl_Z {
		public LineItems_Z lineItems {get;set;} 
		public Revenue_breakup_Z revenue_breakup {get;set;} 
		public Depreciation_breakup_Z depreciation_breakup {get;set;} 
		public Metadata_Z metadata {get;set;} 
}
	
	public class Principal_business_activities {
		public Integer year {get;set;} 
		public String main_activity_group_code {get;set;} 
		public String main_activity_group_description {get;set;} 
		public String business_activity_code {get;set;} 
		public String business_activity_description {get;set;} 
		public Integer percentage_of_turnover {get;set;} 

	}
	
	public class Receivable {
		public String type_of_financial_dispute {get;set;} 
		public String currency_Z {get;set;} // in json: currency
		public Integer amount_under_default {get;set;} 
		public String verdict {get;set;} 
		public String court {get;set;} 
		public String litigant {get;set;} 
		public String case_no {get;set;} 
		public Integer amount {get;set;} 
		public String default_date {get;set;} 
		public String date_of_judgement {get;set;} 

	}
	
	public class LineItems_Z {
		public Integer total_interest_income {get;set;} 
		public Integer total_dividend_income {get;set;} 
		public Integer total_other_operating_income {get;set;} 
		public Integer revenue {get;set;} 
		public Integer other_income {get;set;} 
		public Integer total_income {get;set;} 
		public Integer interest {get;set;} 
		public Integer total_cost_of_materials_consumed {get;set;} 
		public Integer total_purchases_of_stock_in_trade {get;set;} 
		public Integer total_changes_in_inventories_or_finished_goods {get;set;} 
		public Integer total_employee_benefit_expense {get;set;} 
		public Integer depreciation {get;set;} 
		public Integer total_other_expenses {get;set;} 
		public Integer total_expenses {get;set;} 
		public Integer profit_before_tax_and_exceptional_items_before_tax {get;set;} 
		public Integer total_exceptional_items {get;set;} 
		public Integer profit_before_tax {get;set;} 
		public Integer income_tax {get;set;} 
		public Integer profit_Loss_for_the_period_from_continuing_operations {get;set;} 
		public Integer profit_Loss_from_discontinued_operations_after_tax {get;set;} 
		public Integer minority_interest_and_profit_from_associates_and_joint_ventures {get;set;} 
		public Integer profit_after_tax {get;set;} 

	}
	
	public class Financial_parameters {
		public String year {get;set;} 
		public String nature {get;set;} 
		public Integer earning_fc {get;set;} 
		public Integer expenditure_fc {get;set;} 
		public Integer transaction_related_parties_as_18 {get;set;} 
		public Integer employee_benefit_expense {get;set;} 
		public Integer number_of_employees {get;set;} 
		public Integer prescribed_csr_expenditure {get;set;} 
		public Integer total_amount_csr_spent_for_financial_year {get;set;} 
		public Integer gross_fixed_assets {get;set;} 
		public Integer trade_receivable_exceeding_six_months {get;set;} 
		public String proposed_dividend {get;set;} 

	}
	
	public class Depreciation_breakup {
		public Integer depreciation {get;set;} 
		public Integer amortisation {get;set;} 
		public Integer depletion {get;set;} 
		public Integer depreciation_and_amortization {get;set;} 

	}
	
	public class Director_shareholdings {
		public Integer year {get;set;} 
		public String financial_year {get;set;} 
		public String din_pan {get;set;} 
		public String full_name {get;set;} 
		public String designation {get;set;} 
		public String date_of_cessation {get;set;} 
		public Integer no_of_shares {get;set;} 
		public Integer percentage_holding {get;set;} 

	}
	
	public class Filing_details {
		public String trrn {get;set;} 
		public String wage_month {get;set;} 
		public String date_of_credit {get;set;} 
		public Integer no_of_employees {get;set;} 
		public Integer amount {get;set;} 

	}
	
	public class Cash_flow_Z {
		public Integer profit_before_tax {get;set;} 
		public Integer adjustment_for_finance_cost_and_depreciation {get;set;} 
		public Integer adjustment_for_current_and_non_current_assets {get;set;} 
		public Integer adjustment_for_current_and_non_current_liabilities {get;set;} 
		public Integer other_adjustments_in_operating_activities {get;set;} 
		public Integer cash_flows_from_used_in_operating_activities {get;set;} 
		public Integer cash_outflow_from_purchase_of_assets {get;set;} 
		public Integer cash_inflow_from_sale_of_assets {get;set;} 
		public Integer income_from_assets {get;set;} 
		public Integer other_adjustments_in_investing_activities {get;set;} 
		public Integer cash_flows_from_used_in_investing_activities {get;set;} 
		public Integer Cash_outflow_from_repayment_of_capital_and_borrowings {get;set;} 
		public Integer cash_inflow_from_raisng_capital_and_borrowings {get;set;} 
		public Integer interest_and_dividends_paid {get;set;} 
		public Integer other_adjustments_in_financing_activities {get;set;} 
		public Integer cash_flows_from_used_in_financing_activities {get;set;} 
		public Integer incr_decr_in_cash_cash_equv_before_effect_of_excg_rate_changes {get;set;} 
		public Integer adjustments_to_cash_and_cash_equivalents {get;set;} 
		public Integer incr_decr_in_cash_cash_equv {get;set;} 
		public Integer cash_flow_statement_at_end_of_period {get;set;} 

	}
	
	public class Shareholdings_summary {
		public Integer year {get;set;} 
		public String financial_year {get;set;} 
		public Integer total_equity_shares {get;set;} 
		public Integer total_preference_shares {get;set;} 
		public Integer promoter {get;set;} 
		public Integer public_Z {get;set;} // in json: public
		public Integer total {get;set;} 
		public Metadata_Z metadata {get;set;} 

	}
	
	public class Filings {
		public String return_type {get;set;} 
		public String date_of_filing {get;set;} 
		public String financial_year {get;set;} 
		public String tax_period {get;set;} 
		public String status {get;set;} 

	}
	
	

}