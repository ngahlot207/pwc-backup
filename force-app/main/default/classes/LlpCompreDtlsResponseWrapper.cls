public class LlpCompreDtlsResponseWrapper{

	public String message {get;set;}
	public class Company {
		public String cin {get;set;} 
		public String legal_name {get;set;} 
		public Double paid_up_capital {get;set;} 
		public Double sum_of_charges {get;set;} 
		public String incorporation_date {get;set;} 
		public String city {get;set;} 
		public String status {get;set;} 
		public Integer share_holding_percentage {get;set;} 
		public String active_compliance {get;set;} 

	}
	
	public class Email {
		public String emailId {get;set;} 
		public String status {get;set;} 

	}
	
	public class Rating_details_Z {
		public String rating {get;set;} 
		public String type_of_loan {get;set;} 
		public Double amount {get;set;} 
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
		public Double sale_of_goods_manufactured_domestic {get;set;} 
		public Double sale_of_goods_traded_domestic {get;set;} 
		public Double sale_or_supply_of_services_domestic {get;set;} 
		public Double sale_or_supply_of_services_export {get;set;} 
		public Double sale_of_goods_manufactured_export {get;set;} 
		public Double sale_of_goods_traded_export {get;set;} 

	}
	
	public class SubTotals {
		public Double given_assets_total {get;set;} 
		public Double given_liabilities_total {get;set;} 

	}
	
	public class Credit_rating_rationale {
		public String rating_agency {get;set;} 
		public String financial_year {get;set;} 
		public String doc_id {get;set;} 

	}
	
	public class Liabilities {
		public Double contribution_received {get;set;} 
		public Double reserves_and_surplus {get;set;} 
		public Double secured_loan {get;set;} 
		public Double unsecured_loan {get;set;} 
		public Double short_term_borrowing {get;set;} 
		public Double trade_payables {get;set;} 
		public Double other_liabilities {get;set;} 
		public Double provisions_for_taxation {get;set;} 
		public Double provisions_for_contingencies {get;set;} 
		public Double provisions_for_insurance {get;set;} 
		public Double other_provisions {get;set;} 

	}
	
	public class Statement_of_assets_and_liabilities {
		public Assets assets {get;set;} 
		public Liabilities liabilities {get;set;} 
		public SubTotals subTotals {get;set;} 
		public Metadata_Z metadata {get;set;} 

	}
	
	public class Network {
		public List<Companies> companies {get;set;} 
		public List<Llps> llps {get;set;} 

	}
	
	public class Business_address {
		public String address_line1 {get;set;} 
		public String address_line2 {get;set;} 
		public String city {get;set;} 
		public String pincode {get;set;} 
		public String state {get;set;} 

	}
	
	public class LineItems {
		public Double net_revenue {get;set;} 
		public Double operating_cost {get;set;} 
		public Double total_cost_of_materials_consumed {get;set;} 
		public Double total_purchases_of_stock_in_trade {get;set;} 
		public Double total_changes_in_inventories_or_finished_goods {get;set;} 
		public Double total_employee_benefit_expense {get;set;} 
		public Double total_other_expenses {get;set;} 
		public Double operating_profit {get;set;} 
		public Double other_income {get;set;} 
		public Double depreciation {get;set;} 
		public Double profit_before_interest_and_tax {get;set;} 
		public Double interest {get;set;} 
		public Double profit_before_tax_and_exceptional_items_before_tax {get;set;} 
		public Double exceptional_items_before_tax {get;set;} 
		public Double profit_before_tax {get;set;} 
		public Double income_tax {get;set;} 
		public Double profit_for_period_from_continuing_operations {get;set;} 
		public Double profit_from_discontinuing_operation_after_tax {get;set;} 
		public Double minority_interest_and_profit_from_associates_and_joint_ventures {get;set;} 
		public Double profit_after_tax {get;set;} 

	}
	
	public class Individual_partners {
		public String id {get;set;} 
		public String id_type {get;set;} 
		public String name {get;set;} 
		public String designation {get;set;} 
		public String obligation_contribution {get;set;} 
		public String received_contribution {get;set;} 
}
	
	public class Contribution_details {
		public String financial_year {get;set;} 
		public List<Individual_partners> individual_partners {get;set;} 
		public List<Body_corporates> body_corporates {get;set;} 
		public Metadata_Z metadata {get;set;} 

	}
	
	public class Industry_segments {
		public String industry {get;set;} 
		public List<String> segments {get;set;} 

	}
	
	public class Summary_designated_partners {
		public String financial_year {get;set;} 
		public String category {get;set;} 
		public Integer partner {get;set;} 
		public Integer indian_desig_partner {get;set;} 
		public Integer other_desig_partner {get;set;} 
		public Integer total {get;set;} 

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
	
	public class Rating_details {
		public String rating {get;set;} 
		public String action {get;set;} 
		public String outlook {get;set;} 
		public String remarks {get;set;} 

	}
	
	public class Gst_details {
		public String gstin {get;set;} 
		public String status {get;set;} 
		public String companyName {get;set;} 
		public String tradeName {get;set;} 
		public String state {get;set;} 
		public String stateJurisdiction {get;set;} 
		public String centreJurisdiction {get;set;} 
		public String dateOfRegistration {get;set;} 
		public String taxpayerType {get;set;} 
		public String natureOfBusinessActivities {get;set;} 
		public List<Filings> filings {get;set;} 

	}
	
	public class Description {
		public String desc_thousand_char {get;set;} 

	}
	
	public Metadata metadata {get;set;} 
	public Data data {get;set;} 

	
	
	public class Metadata {
		public String api_version {get;set;} 
		public String last_updated {get;set;} 

	}
	
	public class Llp_Z {
		public String llpin {get;set;} 
		public String legal_name {get;set;} 
		public Integer total_obligation_of_contribution {get;set;} 
		public Double sum_of_charges {get;set;} 
		public String incorporation_date {get;set;} 
		public String city {get;set;} 
		public String status {get;set;} 
		public Integer share_holding_percentage {get;set;} 

	}
	
	public class Open_charges_latest_event {
		public Integer id {get;set;} 
		public Integer amount {get;set;} 
		public String date_Z {get;set;} // in json: date
		public String holder_name {get;set;} 
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
		public Integer total_obligation_of_contribution {get;set;} 
		public String llpin {get;set;} 
		public String efiling_status {get;set;} 
		public String incorporation_date {get;set;} 
		public String last_annual_returns_filed_date {get;set;} 
		public String last_financial_reporting_date {get;set;} 
		public String legal_name {get;set;} 
		public Integer total_contribution_received {get;set;} 
		public Double sum_of_charges {get;set;} 
		public Registered_address registered_address {get;set;} 
		public Business_address business_address {get;set;} 
		public String website {get;set;} 
		public String pan {get;set;} 
		public String classification {get;set;} 
		public String email {get;set;} 
		public Lei lei {get;set;} 

	}
	
	public class Statement_of_income_and_expenditure {
		public LineItems lineItems {get;set;} 
		public Revenue_breakup revenue_breakup {get;set;} 
		public Depreciation_breakup depreciation_breakup {get;set;} 
		public Metadata_Z metadata {get;set;} 

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
	
	public class Directors {
		public String din {get;set;} 
		public String pan {get;set;} 
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

	}
	
	public class Phone {
		public String phoneNumber {get;set;} 
		public String status {get;set;} 

	}
	
	public class Assets {
		public Integer gross_fixed_assets {get;set;} 
		public Integer depreciation_and_amortization {get;set;} 
		public Integer investments {get;set;} 
		public Integer loans_and_advances {get;set;} 
		public Integer inventories {get;set;} 
		public Integer trade_receivables {get;set;} 
		public Integer cash_and_cash_equivalents {get;set;} 
		public Integer other_assets {get;set;} 
		public Integer net_fixed_assets {get;set;} 

	}
	
	public class Charge_sequence {
		public Integer charge_id {get;set;} 
		public String status {get;set;} 
		public String date_Z {get;set;} // in json: date
		public String filing_date {get;set;} 
		public Integer amount {get;set;} 
		public String holder_name {get;set;} 
		public String number_of_holder {get;set;} 
		public String property_type {get;set;} 
		public String property_particulars {get;set;} 

	}
	
	public class Financials {
		public String year {get;set;} 
		public String stated_on {get;set;} 
		public Statement_of_assets_and_liabilities statement_of_assets_and_liabilities {get;set;} 
		public Statement_of_income_and_expenditure statement_of_income_and_expenditure {get;set;} 
		public Certifiers certifiers {get;set;} 

	}
	
	public class Struckoff248_details {
		public String struck_off_status {get;set;} 
		public String restored_status {get;set;} 

	}
	
	public class Name_history {
		public String name {get;set;} 
		public String date_Z {get;set;} // in json: date

	}
	
	public class Contact_details {
		public List<Email> email {get;set;} 
		public List<Phone> phone {get;set;} 

	}
	
	public class Others {
		public String legal_name {get;set;} 
		public Integer share_holding_percentage {get;set;} 

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
		public Llp llp {get;set;} 
		public Description description {get;set;} 
		public List<Name_history> name_history {get;set;} 
		public List<Directors> directors {get;set;} 
		public List<Director_network> director_network {get;set;} 
		public Contact_details contact_details {get;set;} 
		public List<Open_charges> open_charges {get;set;} 
		public List<Open_charges_latest_event> open_charges_latest_event {get;set;} 
		public List<Charge_sequence> charge_sequence {get;set;} 
		public List<Financials> financials {get;set;} 
		public List<Establishments_registered_with_epfo> establishments_registered_with_epfo {get;set;} 
		public List<Industry_segments> industry_segments {get;set;} 
		public List<Principal_business_activities> principal_business_activities {get;set;} 
		public List<Legal_history> legal_history {get;set;} 
		public List<Defaulter_list> defaulter_list {get;set;} 
		public List<Credit_ratings> credit_ratings {get;set;} 
		public List<Credit_rating_rationale> credit_rating_rationale {get;set;} 
		public List<Unaccepted_rating> unaccepted_rating {get;set;} 
		public Holding_entities holding_entities {get;set;} 
		public Holding_entities subsidiary_entities {get;set;} 
		public Contribution_details contribution_details {get;set;} 
		public List<Summary_designated_partners> summary_designated_partners {get;set;} 
		public Struckoff248_details struckoff248_details {get;set;} 
		public List<Gst_details> gst_details {get;set;} 
		public List<Legal_cases_of_financial_disputes> legal_cases_of_financial_disputes {get;set;} 

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
	
	public class Holding_entities {
		public String financial_year {get;set;} 
		public List<Company> company {get;set;} 
		public List<Llp_Z> llp {get;set;} 
		public List<Others> others {get;set;} 

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
	
	public class Certifiers {
		public String type {get;set;} 
		public String name {get;set;} 
		public String id {get;set;} 
		public String address {get;set;} 
		public String firm_id {get;set;} 
		public String firm_name {get;set;} 

	}
	
	public class Credit_ratings {
		public String rating_date {get;set;} 
		public String rating {get;set;} 
		public String rating_agency {get;set;} 
		public String type_of_loan {get;set;} 
		public Integer amount {get;set;} 
		public String currency_Z {get;set;} // in json: currency
		public List<Rating_details> rating_details {get;set;} 

	}
	
	public class Principal_business_activities {
		public Integer year {get;set;} 
		public String business_classification {get;set;} 
		public String principal_business_activities {get;set;} 

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
	
	public class Body_corporates {
		public String id {get;set;} 
		public String id_type {get;set;} 
		public String name {get;set;} 
		public String obligation_contribution {get;set;} 
		public String received_contribution {get;set;} 
		public String nominee_id {get;set;} 
		public String nominee_name {get;set;} 
		public String nominee_id_type {get;set;} 

	}
	
	public class Depreciation_breakup {
		public Integer depreciation_and_amortization {get;set;} 

	}
	
	public class Filing_details {
		public String trrn {get;set;} 
		public String wage_month {get;set;} 
		public String date_of_credit {get;set;} 
		public Integer no_of_employees {get;set;} 
		public Integer amount {get;set;} 

	}
	
	public class Filings {
		public String returnType {get;set;} 
		public String dateOfFilling {get;set;} 
		public String financialYear {get;set;} 
		public String taxPeriod {get;set;} 
		public String status {get;set;} 

	}  


}