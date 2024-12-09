public class CrifExecuteAPIRequestWrapper {
    
    public StrategyOneRequest StrategyOneRequest;
    
    public class StrategyOneRequest {
        public String Header;
        public Body Body;
    }
    
    public class Body {
        public Application APPLICATION;
    }
    
    public class Application {
        public ApplicationVariables Variables;
        public List<Map<String,Object>> Categories;
    }
    
    public class ApplicationVariables {
        public Double call_id;  
        public String application_id;   
        public String login_acceptance_date;    
        public String pdt_product;  
        public Double pdt_requested_loan_amount;    
        public String product_sub_type; 
        public String authstatus;   
        public String balance_transfer_financier;   
        public Double balance_transfer_loan_outstanding_value;  
        public Double balance_transfer_original_loan_amount;    
        public Double biil_desk_txnamount;  
        public String eligible_for_funding_under_esg_policy_norms_or_not;   
        public String existing_fedfina_loan_account_number; 
        public Double eligibility_insurance_amount; 
        public String is_there_any_discrimination_basis_gender_caste_religion_race; 
        public String is_this_assesed_income_program;   
        public String loan_purpose; 
        public Double other_salary_component_outside_payslip;   
        public Double pdt_channel_code; 
        public String pdt_channel_name; 
        public String promotion;    
        public Double revised_pf_perc;  
        public Double scheme;   
        public String specify_other_balance_transfer_financier;
        public Double Loan_Amount;  
        public String pdt_all_seller_bt_norms_met;  
        public String pdt_balance_transfer_financier_status;    
        public String pdt_branch_tier;  
        public String pdt_is_it_a_refinance_transaction;    
        public String pdt_is_it_a_seller_balance_transfer_transaction;  
        public Double pdt_payment_done_in_last_12_months_bank;  
        public Double pdt_payment_done_in_last_12_months_cash;  
        public Double pdt_payment_done_in_last_6_months_bank;   
        public Double pdt_payment_done_in_last_6_months_cash;   
        public Double pdt_period_since_sale_agreement_is_executed_month;    
        public Double pdt_refinance_sale_agreement_amount;  
        public String pdt_refinance_sale_agreement_date;    
        public String guarantor_is_bringing_in_spdc;    
        public Double own_contribution_in_cash; 
        public Double own_contribution_bank;    
        public String is_there_a_TypeA_deviation;   
        public String is_there_a_TypeB_deviation;   
        public String borrower_is_director_relative_or_senior_officer_at_fedfina;   
        public String final_rcu_hunter_status;  
        public String final_rcu_sampling_status;    
        public String final_rcu_status; 
        public String final_rcu_status_reason;      
        public String fedfina_director_relative_interested_as_a_partner;    
        public String fedfina_director_relative_interested_as_major_shareholder;    
        //public String hunterStaRepl;  
        //public String hunter_status__match_or_not_match;  
        public Double imd_amount;   
        public String is_it_matching_with_the_repayment_account_holder_name;
        public Double lead_roi; 
        public String pdt_lead_source;  
        public Double pdt_branch_code;  
        public String pdt_branch_name;  
        public String psl_tagging;      
        public Double requested_tenure_in_months;   
        public Double revised_roi_perc; 
        public String status_of_reportrcu;  
        public Double summary_total_loan_amount_including_insurance;    
        public String summary_rate_type_floating_flag;  
        public Double loan_tenure_months;  
        public Double summary_emi_loan_amount_including_insurance;
        public String cheque_bounce_reason; 
        public String product_sub_field;
        public String Repayment_Mode;   
        public Double Previous_Exposure_with_Fedfina;   
        public String cust_hunter_type; 
        public Double cust_hunter_score;  
        public String cust_hunter_name; 
        public String cust_hunter_decisiontext; 
        public String cust_hunter_decisionreasons;  
        public String cust_hunter_decision; 
        public Double no_of_emi_bounce_for_bt_loan;  
        public Double no_of_emi_paid_for_bt_loan;  
        public String bt_loan;  
        public String location;
        public String Cheque_bounce_reason_2;   
        public String Cheque_bounce_reason_1;
        public String IMD_CLEARANCE_STATUS2;    
        public String IMD_CLEARANCE_STATUS1;
        public Double Bounce_in_BT_Loan_with_Seasoning_less_than_12_Months; 
        public Double Bounce_in_BT_Loan_with_Seasoning_greater_than_equal_to_12_Months; 
        public Double Bounce_in_BT_Loan_with_Seasoning_greater_than_equal_to_18_Months;
        
        //LAK-6471 Start
        Public String hunter_status_match_or_not_match;
        Public String date_of_rcu_report;
        Public String first_sanction_date;
        Public Decimal Existing_Fedfina_Loan_Exposure_Total;
        Public Decimal Existing_Fedfina_Loan_Exposure_Same_Product;
        public string Is_Top_Up_being_processed_parallelly_along_with_HL_BT;
        public string Status_of_Proposed_Top_up_loan;
        public string HL_Top_up_loan_has_been_added_in_obligation;
        public string Status_of_Parallel_HL_BT_loan_application;
        public string HL_BT_loan_has_been_added_in_obligation;
        public string Income_ownership_norms_met_as_per_policy;
        public Decimal HL_Top_up_loan_amount;
        public Decimal HL_Top_up_EMI;
        public Decimal HL_BT_loan_amount;
        public Decimal HL_BT_loan_EMI;
        public Decimal Cumulative_HL_BT_plus_Top_Up_loan_amount;
        public Decimal Total_of_Existing_continuing_Fedfina_Loan_amount;//
        public Decimal Total_of_Existing_continuing_Fedfina_Loan_Principal_outstanding;
        public Decimal Total_of_Existing_continuing_Fedfina_EMI;
        //LAK-6471 Stop
        
        //LAK-9870 Start
        public string Stage;
        public string Sub_Stage;
        //LAK-9870 Stop
    }
    
    public class Property {
        public PropertyVariables Variables;
    }
    
    public class PropertyVariables{
        public String unique_id;
        public Double property_city;    
        public String property_nature_of_property;  
        public String property_pin_code;    
        public String prop_property_type;   
        public Double prop_state_ut;    
        public Double property_address_distance_from_nearest_fedfina_branch;    
        public Double property_address_distance_from_the_sourcing_branch;   
        public String property_category;    
        public String property_identified;  
        public String property_in_serviceable_city; 
        public String property_sub_type_description;    
        public String property_subtype; 
        //public String property_ownership_proof_documented;  Commenting Due to LAK -9870
        public String property_all_property_general_norms_met;  
        public String property_all_property_subtype_norms_met;  
        public Double property_average_net_monthly_rental_as_per_banking_credit;    
        public Double property_carpet_area; 
        public String property_details_negative_caution_area;   
        public Double property_improvement_construction_estimate_documented;    
        public String property_is_the_property_multi_tenanted;  
        public Double property_per_sq_ft_approved_cost_of_construction; 
        public Double property_per_sq_ft_rate_built_up_area;    
        public Double property_per_sq_ft_rate_land_area;    
        public Double property_prop_no_of_tenants;  
        public Double property_stage_of_construction_percentage;    
        public String property_usage;   
        public Double technical_total_valuation_land_valuation_built_up_area_valuation; 
        public Double total_property_cost;  
        public Double technical_built_up_area_valuation_in_rs;  
        public Double technical_land_valuation_in_rs;   
        public Double technical_property_built_up_area_sq_ft;   
        public Double technical_approx_age_of_property_in_years;    
        public Double Registration_Charges; 
        public Double Stamp_Duty;   
        public String technical_status_of_technical_report; 
        public Double residAge; //public Double technical_residual_age__in_years;   
        public Double technical_property_reconstruction_cost;   
        public Double technical_land_area_sq_ft;    
        public String technical_approved_plan_oc_available; 
        public Double stage_of_construction;    
        public Double perc_recommended_by_technical_valuer; 
        public Double distance_captured_by_technical_agency_from_fedfina_branch;    
        public String marketables;  //public String tsr_is_the_title_clear__marketable;
        public String final_technical_status;   
        //public Double assPatAn;  //public Double assessed_pat__annual_in_lacs;// commiting LAK-9282
        //public String status_of_reporttsr;  
        //public Double assessed_turnover_annual_in_lacs; //commiting LAK-9282
        public String final_status_of_vetting;  
        //public String vetting_is_the_title_clear_marketable;    
        public String legal_is_the_title_clear_marketable;  
        public String legal_final_status_of_legal_report;   
        public String technical_plot_is_non_agricultural;   
        public String final_status_of_technical_report_from_internal_technical_manager; 
        public Double Total_construction_estimate_as_per_architect_agreement;   
        public Double Registered_Agreement_Value;   
        public String property_owner;   
        public String Property_Document;    
        public String Document_Type;    
        public String final_status_of_legal_report_from_internal_legal; 
        public Double Total_Valuation_1;    
        public Double Total_Valuation_2;    
        public Double Total_Valuation_3;    
        public String Change_required_in_Valuation_as_per_policy_norms; 
        public String TSR_report_status;
        
        //LAK-6471 Start
        public String date_of_technical_report;
        public String date_of_legal_report;
        public string Recent_title_document_Gift_deed;
        public String copy_existing_address;
        //LAK-6471 End
        
        //LAK-9870 Start
        public String Collateral_visit_report_date;
        //LAK-9870 End
    }
    
    public class Customer {
        public Variables Variables;
        public List<Map<String,Object>> Categories;
    }
    
    public class Variables {
        public String unique_id;
        public String cust_applicant_type;  
        public Double CIBIL_Score;  
        public String cust_date_of_birth_date_of_incorporation; 
        public Double cust_constitution;    
        public Double cust_customer_profile;    
        public String cust_consider_income; 
        public String cust_accept_all;  
        public String cust_activitydescription; 
        public String cust_address_match;   
        public Double cust_address_match_score; 
        public Double cust_ageyear; 
        public Double cust_alertcount;  
        public Double cust_amt_namaste_credit_itr;  
        public Double cust_amt_payable; 
        public String cust_applicantname;   
        public String cust_applicationdate; 
        public String cust_asset_classification;    
        public String cust_asset_classification_date;   
        public Double cust_associateyear;   
        public Double cust_auf; 
        public Double cust_aum; 
        public Double cust_balancesheetcheck_amt;   
        public Double cust_balancesheetcheck_inc_decrease_over_prev_yr; 
        public String cust_beneficial_owner;    
        public String cust_beneficial_owner_related_details;    
        public Double cust_bill_amt;    
        public Double cust_bounce;  
        public String cust_ca_membership_authentication_name;   
        public String cust_category;    
        public Double cust_closing_stock_amt;   
        public Double cust_closing_stock_growth_perc;   
        public String cust_commencedate;    
        public String cust_company_name;    
        public Double cust_controlling_ownership_interest_perc; 
        public String cust_copstatus;   
        public String cust_cpvfi_dedupe_for_negative_database;  
        public String cust_cpvfi_details_of_the_borrowers_have_been_confirmed;  
        public Double cust_cpvfi_distance_from_fedfina_fi_initiated_branch; 
        public String cust_cpvfi_marital_status;    
        public String cust_cpvfi_negative_area; 
        public String cust_cpvfi_negative_database_result;  
        public String cust_cpvfi_negative_report_reason;    
        public String cust_cpvfi_neighbour_reference_check; 
        public String cust_cpvfi_property_type; 
        public String cust_crimewatch;  
        public Double cust_current_business_vintage_year;
        public String cust_customer_profile_categorisation; 
        public String cust_customer_profile_selection;  
        public String cust_date_of_udyam_registration;  
        public String cust_dateofcommencement;  
        public String cust_dateofincorporation; 
        public String cust_dateofregistration;  
        public Double cust_debtors_period_in_days;  
        public String cust_dedupe_customername; 
        public String cust_dedupe_lan;  
        public Double cust_dedupe_loanamt;  
        public String cust_dedupe_source;   
        public Double cust_deferred_tax_liability_assets_amt;   
        public Double cust_deferred_tax_liability_assets_inc_decrease_over_prev_yr; 
        public Double cust_depreciation_amt;    
        public Double cust_depreciation_growth_perc;    
        public String cust_details_of_the_borrowers_have_been_confirmed;    
        public String cust_disciplinaryaction;  
        public String cust_dobmatch;    
        public Double cust_dpd_datalake_dedupe_enpa;    
        public String cust_dpdstring;   
        public String cust_driver_license_authentication;   
        public String cust_duplicate_pan;   
        public String cust_education_qualification; 
        public String cust_email_authentication_disposable; 
        public String cust_email_authentication_email;  
        public String cust_email_authentication_regexp; 
        public String cust_email_authentication_result; 
        public String cust_email_authentication_webmail;    
        public Double cust_employer_emplrscore; 
        public String cust_employer_name;   
        public String cust_enpa_rejection_reason;   
        public String cust_enterprisetype;  
        public String cust_entity_name; 
        public String cust_entityname;  
        public Double cust_estinfo_confidence;  
        public String cust_estinfo_epfhistory;  
        public String cust_estinfo_isemployed;  
        public String cust_estinfo_isnameexact; 
        public Double cust_existingFedfinaTenure;   
        public String cust_fi_report_result;    
        public String cust_finalassetclass; 
        public Double cust_finance_cost_amt;    
        public Double cust_finance_cost_growth_perc;    
        public String cust_first_name;  
        public Double cust_for_how_many_years_user_want_to_enter_itr_values;    
        public String cust_gst_registered;  
        public String cust_gstin_status;    
        public String cust_gstnstatus;  
        public Double cust_income_details_amt;  
        public Double cust_income_details_growth_perc;  
        public String cust_individualmatch; 
        public String cust_individualmatch_name;    
        public Double cust_individualmatch_score;   
        public String cust_individualmatchmatch;    
        public String cust_industry_type;   
        public String cust_industrycode;    
        public Double cust_inerest_paid_cash_credit_or_over_draft_amt;  
        public Double cust_inerest_paid_cash_credit_or_over_draft_growth_perc;  
        public Double cust_interest_paid_on_term_loan_amt;  
        public Double cust_interest_paid_on_term_loan_growth_perc;  
        public Double cust_interest_paid_to_partners_or_directors_growth_perc;  
        public String cust_internal_dedupe_result;  
        public Double cust_intersest_paid_on_term_loan_amt; 
        public Double cust_intersest_paid_on_term_loan_growth_perc; 
        public String cust_is_the_prorietorship_firm_part_of_the_proposal;  
        public String cust_is_urc_uac_available;    
        public String cust_isactive;    
        public String cust_kyc_details; 
        public String cust_kyc_udyam_registration_cert_or_udyam_assist_cert;    
        public String cust_last_name;   
        public Double cust_latest_year_for_which_itr_is_available;  
        public String cust_lei_no;  
        public String cust_linked_ucic; 
        public String cust_listed_unlisted; 
        //public String cust_litigation_crime_check_individual_status;  //
        public String custLigitgCrimeChk;
        public String cust_litigation_crimecheck_company_status;    
        public String cust_loandisbdate;    
        public String cust_loanstatus;  
        public String cust_loantype;    
        public String cust_majoractivity;   
        public String cust_marital_status;  
        public String cust_matched; 
        public Double cust_matchingperc;    
        public String cust_medical_council; 
        public String cust_memberstatus;    
        public Double cust_mob; 
        public Double cust_month1_epfo_data;    
        public Double cust_month2_epfo_data;    
        public Double cust_month3_epfo_data;    
        public String cust_mx_records;  
        public String cust_name_namastecredit_itr;  
        public String cust_name_of_employer;    
        public String cust_name_similarity_result;  
        public Double cust_name_similarity_score;   
        public String cust_namelookup_formatted_wage_month; 
        public Double cust_namelookup_totamt;   
        public Double cust_namelookup_totmembers;   
        public String cust_namelookup_wagemonth;    
        public Double cust_namematch;   
        public Double cust_nationality; 
        public String cust_nature_of_business;  
        public String cust_natureofbusiness;    
        public String cust_negative_area;   
        public String cust_negative_database_result;    
        public String cust_negative_list;   
        public String cust_negative_unservicable_city_check;    
        public String cust_neighbour_reference_check;   
        public String cust_niccode; 
        public String cust_nmc_membership_qualification;    
        public String cust_npa_date;    
        public Double cust_numberofcases;   
        public Double cust_numberoffaces_imgae1;    
        public Double cust_numberoffaces_imgae2;    
        public String cust_occ_customer_profile;    
        public String cust_occ_designation; 
        public String cust_official_email_id;   
        public Double cust_opening_stock_amt;   
        public Double cust_opening_stock_growth_perc;   
        public String cust_org_domain_match_domain; 
        public String cust_org_domain_match_match;  
        public String cust_org_domain_match_orgname;    
        public String cust_org_domain_match_source; 
        public String cust_org_email_match; 
        public String cust_org_email_match_companyemail;    
        public String cust_org_email_match_match;   
        public String cust_org_email_match_orgname; 
        public String cust_org_email_match_source;  
        public String cust_organization;    
        public String cust_organizationname;    
        public String cust_organizationtype;    
        public String cust_ownername;   
        public Double cust_pan_authentication_status_code;  
        public String cust_pan_check_result;    
        public String cust_pan_check_status;    
        public String cust_pan_check_status_code;   
        public Double cust_pbdit_excluding_other_income_amt;    
        public Double cust_pbdit_excluding_other_income_growth_perc;    
        public Double cust_percent_shareholding_in_the_entity;     
        public String cust_politically_exposed_person;  
        public String cust_professional_qualification;  
        public Double cust_purchases_amt;   
        public Double cust_purchases_growth_perc;   
        public String cust_qualification_proof; 
        public Double cust_qualificationyear;   
        public Double cust_ratios;  
        public String cust_registrationdate;    
        public String cust_relationship;    
        public String cust_religion;    
        public String cust_restorationdate; 
        public Double cust_retirement_age;  
        public String cust_risktype;    
        public String cust_rule;    
        public String cust_rulename;    
        public Double cust_rulescore;   
        public String cust_ruletext;    
        public String cust_securitisation_status;   
        public String cust_securitizationflag;  
        public String cust_shop_category;   
        public String cust_shop_ownername;  
        public String cust_shop_status; 
        public String cust_smtp_check;  
        public String cust_spamemail;   
        public String cust_spamrecord_ipblacklist;  
        public Double cust_spamrecord_reportcount;  
        public String cust_status_datalake_dedupe_enpa; 
        public String cust_sub_industry;    
        public String cust_subindustry; 
        public String cust_subsector;   
        public String cust_subsectorcode;   
        public String cust_suspensiondate;  
        public Double cust_tot_amt; 
        public Double cust_tot_loan_funds_amt;  
        public Double cust_tot_loan_funds_inc_decrease_over_prev_year;  
        public Double cust_tot_unsecured_loans_amt; 
        public Double cust_tot_unsecured_loans_inc_decrease_over_prev_yr;   
        public Double cust_tot_work_experience_month;   
        public Double cust_totworkers;  
        public String cust_trackwizzscreeningalertcreate_source;    
        public String cust_transactionstatus;   
        public String cust_type_of_address; 
        public String cust_type_of_enterprise_as_per_urc;   
        public String cust_type_of_organisation;    
        public String cust_ucic;    
        public String cust_udyam_registration_check_activity;   
        public String cust_udyam_registration_check_industry;   
        public String cust_udyam_registration_check_name;   
        public String cust_udyam_registration_checkpan; 
        public String cust_validfrom;   
        public String cust_validto; 
        public String cust_validupto;   
        public String cust_watchlistname;   
        public String cust_whether_partnership_is_registered;   
        public String cust_whether_politically_exposed_person;  
        public String cust_whoisinfo_creationdate;  
        public String cust_whoisinfo_expirationdate;    
        public String cust_whoisinfo_expired;   
        public String cust_whoisinfo_updatedate;    
        public String cust_whoisorgname_epfhistory; 
        public String cust_whoisorgname_namelookup; 
        public Double cust_working_with_current_employer_month; 
        public Double cust_year_of_registration;    
        public Double cust_working_with_current_employer_year;  
        public Double cust_tot_work_experience_year;    
        public Double cust_current_business_vintage_month;      
        //public String cust_negative_caution_area;   
        public String cust_internal_top_up_original_loan;   
        public Double average_monthly_cash_salary;  
        public Double average_monthly_gross_salary; 
        public String ownership_relation;   
        public String gender;   
        public String selected_eligibility_program;     
        public Double obligation;   
        public Double average_salary;   
        public Double annual_benefits_like_lta; 
        public Double average_monthly_pension;  
        public Double performance_bonus;    
        public Double bank_rental_credit_month; 
        public Double gross_salary_rs;  
        public Double LIC_Agent_Commisssion_RenewalBusiness;
        public Double inc_total_monthly_rental_credit_per_month_rs; 
        public Double LIC_Agent_Commisssion_NewBusiness_Bonus;
        public String Constitution_wise_Mandatory_documents;    
        public Double net_salary_rs;    
        public Double avg_variable_component_last_4_months; 
        public String last_3_month_payslip; 
        public String final_status_of_lip;  
        public Double inc_taxes;    
        public String inform_applicantcoapp_is_dealing_in_any_mentioned_industry;   
        public String latest_year_audit_report_along_with_schedules;    
        public String latest_year_financials_pl_bs_except_44_ad_ae_ada_cases;   
        public String latest_year_form_16;  
        public String multi_tenanted;   
        public Double no_of_tenants;    
        public Double other_deductions; 
        public String previous_year_audit_report_along_with_schedules;  
        public String previous_year_financials_pl_bs_except_44_ad_ae_ada_cases; 
        public String previous_year_itr_computation;    
        public String latest_year_itr_computation;  
        public String rent_agreement_documented;    
        public String rental_verification_done; 
        public Double total_bounces_in_rtr; 
        public Double approximate_margin_in_the_business;   
        public Double average_yearly_income;    
        public Double cost_of_materials;    
        public Double details_of_expenses_total_expenses;   
        public String docu_chk_udyam_registration_cert_urc_or_udyam_assist_cert;    
        public Double inc_average_monthly_rental;   
        public Double monthly_rental_credit_amt_rs; 
        public Double monthly_rental_credit_amt;    
        public Double net_cash_profitloss;  
        public Double operating_activity_receipts;  
        public String PD_Authority; 
        public String lip_vendor_status_of_report;  
        public Double salary_credit_count;  
        public Double bounce_in_last_12_months; 
        public Double bounce_in_last_18_months; 
        public Double rental_in_bank_credit;    
        public Double rental_with_no_bank_credit;
        public Double Cash_Flow_Assessd_Income;
        public Double other_income;
        //public Double total_monthly_agricultural_income_rs;
        public Double Average_Agriculture_Income;
        public String cust_residential_status;
        public String PAN;
        public String Internal_Dedupe_Result;
        public String Internal_Dedupe_Relevance;
        public String Is_PDD_Pending;
        public String Securitisation_Status;
        public Double UCID_level_DPD;
        public Integer UCID;
        public String Result_Relevance_Watchout;
        public String cust_cpvfi_resi_negative_report_reason;
        public String cust_cpvfi_resicumoffice_negative_report_reason;
        public String cust_cpvfi_office_negative_report_reason;
        public String general_insurance;
        public String life_insurance;
        public Double Insurance_coverage_amount;
        public String Risk_Rating_Final;
        public String Screening_Results_Trackwizz;
        public String Negative_list_dedupe;
        public String Business_Proof_Available;
        
        //LAK-6471 Start
        public String date_of_FI_report;
        public String Form_26AS;
        public string cust_litigation_crime_check_individual_status;
        public string property_ownership; 
        //LAK-6471 Start
        Public String Is_proprietorship_firm_part_of_proposal;
        
        //LAK -9282 start
        public Double assPatAn;
        public Double assessed_turnover_annual_in_lacs;
        //LAK -9282 stop
        
        //LAK -9870 start
        public String property_ownership_proof_documented;
        public Double name_match_DL;
        public Double name_match_passport;
        public Double name_match_Aadhaar;
        public Double name_match_Voter_id;
        public String document_aoa;
        public String document_certificate_of_incorporation;
        public String document_cert_regist_doc_issued_by_competent_authorities;
        public String document_electricity_bill;
        public String document_gst_certificate;
        public String document_moa;
        public String document_patnership_deed;
        public String document_piped_gas_bill;
        public String document_post_paid_mobile_phone_bill;
        public String document_shop_and_establishment;
        public String document_telephone_bill;
        public String document_trust_society_deed;
        public String document_udyam_registration_certificate;
        public String document_water_bill;
        
        //LAK-9870 END
    }
    
    public class ConsBuAccount{
        public ConsBUAccountVariables Variables;
    }
    
    public class ConsBUAccountVariables{
        public Double candidate_id; 
        public String bureau_name;  
        public String cons_accountnumber_accountlist;   
        public String cons_accounttypeaccountlist;  
        public String cons_dateopenedordisbursed;   
        public String cons_dateclosed;  
        public Double cons_currentbalance;  
        public Double cons_highcreditorsanctionedamount;    
        public String cons_paymenthistory1; 
        public String cons_paymenthistory2;     
        public Double cons_actualpaymentamount; 
        public Double cons_emiamount;   
        public Double cons_overdueamount;   
        public String cons_paymenthistoryenddate;   
        public String cons_paymenthistorystartdate; 
        public Double cons_repaymentTenure; 
        public Double cons_settlementamount;
        public Double cons_valueofcollateral;   
        public Double cons_writtenoffamounttotal;   
        public Double cons_cashlimit;
        public Double cons_creditlimit;
        public String cons_dateoflastpayment;
        public String cons_datereportedandcertified;
        public Double cons_rateofinterest;
        public Double cons_writtenoffamountprincipal;
        public String cons_credit_faccility_status; //New
        public String cons_suitfiledorwilfuldefault; //New
        public Double cons_ownershipindicator; //New
        public String cons_writtenoffsettledstatus; //New
    }
    
    public class EnquiryCons{
        public EnquiryConsVariables Variables;
    }
    
    public class EnquiryConsVariables {
        public Double candidate_id; 
        public String cons_datereportedenquirylist; 
        public Double cons_enquiryamount;   
        public String cons_enquirypurposeenquirylist;   
        public String cons_reportingmembershortnameenquirylist;
    }
    
    public class AppBurCons {
        public AppBurConsVariables Variables;
    }
    
    public class AppBurConsVariables {
        public String bureau_name;
        public String cons_accountnumberenqactnolist;
        public String cons_accounttypecibil_guide;
        public Decimal cons_actualpaymentamount;
        public String cons_addresscategory_bureau;
        public String cons_addressline2addresslist;
        public String cons_addressline1addresslist;
        public String cons_addressline3addresslist;
        public String cons_addressline4addresslist;
        public String cons_addressline5addresslist;
        public String cons_exclusioncode2;
        public String cons_exclusioncode9;
        public String cons_exclusioncode10;
        public String cons_exclusioncode1;
        public String cons_disputeremarksline1;
        public String cons_datereported_consumer;
        public String cons_datereported_addresslist;
        public String cons_dateoflastpayment;
        public String cons_dateofentry;
        public String cons_cibilremarkcode_consumer;
        public String cons_idvaluephonelist;
        public String cons_idtypephonelist;
        public String cons_expirydatephonelist;
        public String cons_exclusioncode8;
        public String cons_exclusioncode7;
        public String cons_exclusioncode6;
        public String cons_exclusioncode5;
        public String cons_exclusioncode4;
        public String cons_exclusioncode3;
        public String cons_reasoncode2;
        public String cons_reasoncode1;
        public String cons_pincodeaddresslist;
        public String cons_paymentfrequence;
        public String cons_occupationcode;
        public String cons_netgrossindicator;
        public String cons_name1secname;
        public String cons_monthlyannuallyindicator;
        public String cons_issuedatephonelist;
        public String cons_income;
        public String cons_secaddresslist;
        public String cons_scorename;
        public String cons_scorelist_score;
        public String cons_scoredate;
        public String cons_scorecardversion;
        public String cons_scorecardname;
        public String cons_residencecode_bureau;
        public String cons_reasoncode5;
        public String cons_reasoncode4;
        public String cons_reasoncode3;
        public String cons_dateproceed;
        public String cons_writtenoffandsettledstatus;
        public String cons_typeofcollateral;
        public String cons_statecodeaddresslist;
        public String cons_secphonelist;
        public String cons_secname;
        public String cons_secidlist;
    }
    
    public class AppAddress{
        public AppAddressVariables Variables;
    }
    
    public class AppAddressVariables {
        public String cust_type_of_address; 
        public Double cust_state_ut;    
        public Double cust_stability_at_given_address_month;    
        public Double cust_stability_at_given_address_year; 
        public Double cust_pin_code;    
        public String cust_ownership_type;  
        public String cust_nearest_fedfina_branch;  
        public Double cust_dist_from_nearest_fedfina;   
        public Double cust_dist_from_sourcing_branch;   
        public Double cust_city;
        public String cust_negative_caution_area;
        
        //LAK=9870 Start
        public string CPVFI_report_date;
        //LAK=9870 End
    }
    
    public class GstData{
        public GstDataVariables Variables;
    }
    
    public class GstDataVariables {
        public Double gst_annualised_to;    
        public String gst_gdes; 
        public String gst_hsncd;    
        public String gst_industry; 
        public String gst_lastupdateddate;  
        public String gst_name; 
        public String gst_ntr;  
        //public Double gst_percentage__of_growth_in_to_for_current_fy; 
        public Double gstPercGrowth;
        public String gst_returns_for_last_12_months;   
        public String gst_saccd;    
        public String gst_sdes; 
        public Double gst_total_turnover_for_current_financial_year_fy; 
        public Double gst_turnover_profit_growth;
        
        
        //LAK-9870 Start
        public String gstgspapi_GST_status;
        public String gstgspapi_GST_registration_rgdt;
            //LAK-9870 END
    }
    
    public class FinancialData{
        public FinancialDataVariables Variables;
    }
    
    public class FinancialDataVariables {
        public Double fin_adjusted_net_worth;   
        public Double fin_adjusted_tangible_networth;   
        public Double fin_advances_from_customers;  
        public Double fin_advances_to_group_cofriends;  
        public Double fin_advances_to_suppliers;    
        public String fin_balance_sheet_source; 
        public Double fin_bank_borrowing_working_capital_odcc;  
        public Double fin_cash_bank_balances;   
        public Double fin_cash_profit;  
        public Double fin_creditors_payment_period_days;    
        public Double fin_current_ratio;    
        public Double fin_debt_equity_ratio;    
        public Double fin_debtors_collection_period_days;   
        public Double fin_deffered_tax_liabilityassets; 
        public Double fin_direct_expenses;  
        public Double fin_directororpartners_interest_on_partners_capital_for_clubbing; 
        public Double fin_ebitda;   
        public Double fin_fd_closing_stock; 
        public Double fin_fd_depreciation;  
        public String fin_fd_financial_year;    
        public Double fin_fd_investments;   
        public Double fin_fd_opening_stock; 
        public Double fin_fd_pat;   
        public Double fin_fd_purchases; 
        public Double fin_fd_total_loan_funds;  
        public Double fin_greaterthan_6_months_debtors; 
        public Double fin_gross_profit; 
        public Double fin_gross_profit_margin;  
        public Double fin_interest_coverage_ratio;  
        public Double fin_interest_on_cc_od_limits; 
        public Double fin_interest_on_partners_capital; 
        public Double fin_interest_on_term_loans;   
        public Double fin_inventory_turnover;   
        public Double fin_itr_filing_gap_days;  
        public Double fin_lessthan_6_months_debtors;    
        public Double fin_leverage_ratio_total; 
        public Double fin_misc_exp_not_written_off; 
        public Double fin_net_income_considered_for_eligibility;    
        public Double fin_net_intangible_fixed_assets;  
        public Double fin_net_profit_margin;    
        public Double fin_net_tangible_fixed_assets_including_capital_wip;  
        public Double fin_net_working_capital;  
        public Double fin_net_worth;    
        public Double fin_non_business_income;  
        public Double fin_non_operating_expenses_fx_loss_loss_on_sale_of_assets;    
        public Double fin_non_operating_income; 
        public Double fin_office_administrative_expenses;   
        public Double fin_other_current_assets; 
        public Double fin_other_current_liabilities;    
        public Double fin_other_indirect_expenses;  
        public Double fin_other_loans_advances; 
        public Double fin_other_loans_from_private_parties; 
        public Double fin_other_non_current_assets_security_deposits;   
        public Double fin_other_operating_income_which_is_incidental_to_business;   
        public Double fin_prepaid_expenses; 
        public Double fin_profit_before_depreciation_tax_pbdt;  
        public Double fin_profit_before_tax_pbt;    
        public String fin_profit_n_loss_account_source; 
        public Double fin_provisions_for_exps_tax_etc;  
        public Double fin_quick_ratio;  
        public Double fin_revaluation_reserves_notional_reserves;
        public Double finSalToPartDirect;  //public Double fin_salary_to_partnersdirectors_;
        public Double fin_secured_debts_banks_nbfc; 
        public Double fin_share_capital_partners_capital;   
        public Double fin_stock;    
        public Double fin_stock_replenishment_period_days;  
        public Double fin_sundry_creditors; 
        public Double fin_tax_on_the_above_income;  
        public Double fin_taxes;    
        public Double fin_total_asset;  
        public Double fin_total_current_assets; 
        public Double fin_total_current_liabilities;    
        public Double fin_total_debt;
        public Double finTotDebt;  //public Double fin_total_debtors_;
        public Double fin_total_liabilities;    
        public Double fin_total_sales;  
        public Double fin_transferred_value_from_p_n_l_ac;  
        public Double fin_turnover_growth_rate; 
        public String fin_type_of_accounts; 
        public Double fin_unsecured_debt_banks_nbfc;    
        public Double fin_unsecured_loans_from_promoters_family_members;    
        public Double Depreciation_Unaudited_Financials;    
        public Double Depreciation_Audited_Financials;
        public Double cust_interest_paid_to_partners_or_directors_amt;  
        public Double Net_Profit_After_Tax;
        public Double Interest_Dividend_Income; 
        public Double variable_component;   
        public Double Reimbursements;  
        public Double annual_net_rental_income_bank_credit;   
    }
    
    public class BankingData{
        public BankingDataVariables Variables;
    }
    
    public class BankingDataVariables {
        public Double bnk_abb_of_bankings_considered_for_12_months; 
        public Double bnk_abb_of_bankings_considered_for_6_months;  
        public Double bnk_abb_programnumber_of_bankings_considered; 
        public Double bnk_average_monthly_credit_transaction_count; 
        public Double bnk_average_monthly_credit_value_summation;   
        public Double bnk_average_monthly_debit_transaction_count;  
        public Double bnk_average_monthly_inward_return_count;  
        public Double bnk_average_monthly_outward_return_count; 
        public Double bnk_average_monthly_stop_payment_counts;  
        public Double bnk_average_monthy_debit_value_summation; 
        public Double bnk_avg_eod_balance_of_latest_12_months;  
        public Double bnk_avg_eod_balance_of_latest_3_months;   
        public Double bnk_avg_eod_balance_of_latest_6_months;   
        public Double bnk_emi_bounce_in_last_12_months; 
        public Double bnk_emi_bounce_in_last_18_months; 
        public Double bnk_emi_bounce_in_last_6_months;  
        public Double bnk_limit_utilisation;    
        public Double bnk_monthly_average_balance;  
        public Double bnk_sum_of_monthly_average_balance;   
        public Double bnk_total_credit_transaction_count;   
        public Double bnk_total_credit_value_summation; 
        public Double bnk_total_debit_transaction_count;    
        public Double bnk_total_debit_value_summation;  
        public Double bnk_total_inward_return_count;    
        public Double bnk_total_minimum_balance_changes_count;  
        public Double bnk_total_outward_return_count;   
        public Double bnk_total_stop_payment_counts;    
        public String bnk_account_open_date;    
        public String bt_loan;  
        public Double iw_return_ratio; 
        
        //LAK-9870 Start
        public String cust_perfios_name;    
        public String cust_perfios_statementstatus;
        public String cust_perfios_xnsenddate;    
        public String cust_perfios_xnsstartdate; 
        
        //LAK-9870 End
        
    }
    
    public class EnquiryComm{
        public EnquiryCommVariables Variables;
    }
    
    public class EnquiryCommVariables {
        public Double candidate_id; 
        public String m_enqamtenqdetailsinlast24month;  
        public String m_enqdetailsinlast24monthenqdetailsinlast24monthvec;  
        public String m_enq_date_enqdetailsinlast24month;   
        public Double m_enqoutside_insti_enqsummarysec; 
        public String m_enqpurposeenqdetailsinlast24month;  
        public String m_enqsummarysec_productsec;   
        public Double m_enqtotalenqsummarysec;  
        public String m_enquiriesdispute_enqdetailsinlast24monthvec;    
    }
    
    public class CommBuAccount{
        public CommBuAccountVariables Variables;
    }
    
    public class CommBuAccountVariables {
        public Double candidate_id; 
        public String bureau_name;  
        public String m_accountnumber_creditfacilitycurrentdetails; 
        public String m_acordpdcfhistory_upto24M;   
        public String m_amount_creditfacilitycurrentdetails;    
        public String m_amtsettled_writtenoff_invoked_suitfilled_overduecf; 
        public String m_assetclassificationdpddpdcreditfacilitycurrentdetails;  
        public String m_cfhistoryforacordpdupt_24M_vec; 
        public String m_cfhistoryforacordpdupto24M_vec_brwsec;  
        public String m_cfmemberdatescreditfacilitycurrentdetails;  
        public String m_cfserialnumbercreditfacilitycurrentdetails; 
        public String m_cftypecreditfacilitycurrentdetails; 
        public String m_chequedishounoured_duetoinsufficientfunds_brwsec;   
        public String m_creditfacilitycurrentdetailsvec;    
        public String m_creditfacilitycurrentdetailsvec_brwsec; 
        public String m_creditfacilitydetailsas_brwsec; 
        public String m_creditfacilitydetailsas_brwsecproductsecproductsec; 
        public String m_creditfacilitydetailsasguarantorvecproductsec;  
        public String m_creditfacilitydisputecreditfacilitycurrentdetails;  
        public Double m_creditfacilityoverduedetailsvec;    
        public String m_creditfacilityoverduedetailsvec_brwsec; 
        public String m_currencyamountamount;   
        public String m_derivativecreditfacilitycurrentdetails;
        public String m_disputeremark_creditfacilitydispute;
        public Double m_dpd1to30amtcreditfacilityoverduedetails;
        public String m_drawingpoweramount; 
        public String m_loanexpirydtotherdetails;   
        public String m_message_creditfacilitydetailsas_brwsec; 
        public String m_message_creditfacilityguarantordetailsvec;  
        public String m_message_creditfacilitysecuritydetailsvec;   
        public String m_messagecreditfacilitydetailsas_brwsec;  
        public String m_num_ofsuitfiledsettled_writoff_suitfilled_overduecf;    
        public String m_osbalanceamount;    
        public String m_otherdetailscreditfacilitycurrentdetails;   
        public String m_sanctionedamtamount;    
        public String m_sanctioneddtotherdetails;   
        public String m_lastreporteddate_creditfacilitycurrentdetails;  
        public String m_osamountcfhistory_upto24M;  
        public String m_overdueamount;  
        public String m_status_creditfacilitycurrentdetails;    
    }
    
    public class AppBurSummComm {
        public AppBurSummCommVariables Variables;
    }
    
    public class AppBurSummCommVariables {
        public String m_brwdelinquencyreportedon_brw_brwprofilesec;
        public String m_brwdelinquencyreported_brwprofilesec;
        public String m_borrweriddetailsvec_brwprofilesec;
        public String m_borrweriddetailsborrweriddetailsvec;
        public String m_borrwerdetails_brwprofilesec;
        public String m_borrweraddresscontactdetails_brwprofilesec;
        public String m_banknoofcreditgrantors_noofcreditfacilities;
        public String m_applicationreferencenumberreportheaderrec;
        public String m_addressvec_enqinfo_rec;
        public String m_addresscount_enqinfo_rec;
        public String m_cin_borrweriddetailsborrweriddetails;
        public String m_businessindustrytypeborrwerdetails;
        public String m_businesscategoryborrwerdetails;
        public String m_brwtotal_os_totalcf_delinquent_os_delinquentcf;
        public String m_brwslegalconstitutionborrwerdetails;
        public String m_brwprofilesecproductsec;
        public String m_brwperc_total_os_totalcf_delinquent_os_delinquentcf;
        //public String m_brwoffice_locationtypelocationinfo_;
        public String m_brwname_enqinfo_rec;
        public String m_brwdispute_brwprofilesec;
        public String m_countofcreditfacilitiessummary;
        public String m_com_dpd61to90;
        public String m_com_dpd31to60;
        public String m_com_dpd1to30;
        public String m_com_dpd0;
        public String m_com_count;
        public String m_classofactivityvecborrwerdetails;
        public String m_classofactivityclassofactivityvec;
        public String m_cityaddressvecaddressvec;
        public String m_cin_enqinfo_recenqinfo_rec;
        public String m_creditvisionnamecreditvision;
        public String m_creditvisiondesccreditvision;
        public String m_creditvisioncreditvisionsec;
        public String m_creditratingsummaryvec_productsec;
        public String m_creditprofilesummarysecproductsec;
        public String m_creditlenderenqdetailsinlast24month;
        public String m_creditfacilitysecuritydetailsvec_brwsec;
        public String m_creditfacilityguarantordetailsvec_brwsec;
        public String m_creditfacilitiessummary_productsec;
        public String m_countsub_loss_dpd_total;
        public String m_derogatoryinfo_onderogatoryinfo_sec;
        public String m_derogatoryinfo_brwderogatoryinfo_sec;
        public String m_delinquency_PSB_otherprivateforeignbanks_nbfcothers;
        public String m_dbtnonstdvec;
        public String m_dateofregistrationenqinfo_recenqinfo_rec;
        public String m_dateofincorporationborrwerdetailsborrwerdetails;
        //public String m_currentinsti_outside_insti_;
        public String m_crn_enqinfo_rec;
        public String m_creditvisionvaluecreditvision;
        public String m_creditvisionsec_productsec;
        public String m_enq_date_enqdetailsinlast24month;
        public String m_dpd91to180nonstdvec;
        public String m_dpd61to90stdvec;
        public String m_dpd31to60_stdvec;
        public String m_dpd1to30stdvec;
        public String m_dpd0stdvec;
        public String m_dpd_otherinsti_outside_total_PSB_privateforeignbanks;
        public String m_disputeremarksdate_creditfacilitydispute;
        //public String m_dishonoredchequetotal_insti_outside_insti_;
        public String m_derogatoryinfo_secproductsec;
        public String m_greaterthan24monthnoofenquiries;
        //public String m_forexinsti_outside_insti_;
        //public String m_exclusionreasonrankvec;
        public String m_enquiriesdispute_enqdetailsinlast24monthvec;
        public String m_enqtotalenqsummarysec;
        public String m_enqsummarysec_productsec;
        public String m_enqpurposeenqdetailsinlast24month;
        public String m_enqoutside_insti_enqsummarysec;
        public String m_enqdetailsinlast24monthenqdetailsinlast24monthvec;
        public String m_enqamtenqdetailsinlast24month;
        //public String m_last24M_insti_outside_insti_;
        public String m_last_rep_date_brwrid_detailsvecborrweriddetailsvec;
        //public String m_invoked_total_insti_outside_insti_;
        public String m_insti_oustandingbalancebycfandassetclasificationsec;
        public String m_insti_derogatoryinfo_brw;
        public String m_insti_brwdelinquencyreportedon_brw;
        public String m_inquirypurpose_reportheaderrec;
        public String m_guarantortotal_os_totalcf_delinquent_os_delinquentcf;
        public String m_guarantorperc_total_os_totalcf_delinquent_os_dpdcf;
        public String m_insti_derogatoryinfo_secderogatoryinfo_sec;
        public String m_message_enqsummarysecenqsummarysec;
        public String m_message_creditratingsummaryvec;
        public String m_message_creditfacilityoverduedetailsvec;
        public String m_message_creditfacilitydetailsasguarantorvec;
        public String m_message_chequedishounouredduetoinsufficientfunds;
        public String m_message_brw_dpd_reported_on_brwin24M;
        public String m_locationdetailssec_productsec;
        public String m_latestcfopeneddatetotaltotal;
        public String m_latestcfopeneddateInstitute_publicsector_foreignbank;
        public String m_messageofrelatedparties_derogatoryinfo_sec;
        public String m_messageenqdetailsinlast24month;
        public String m_messagederogatoryinfo_sec;
        public String m_message_relationshipdetailsvec;
        public String m_message_oustandingbalancebycfandassetclasificationsec;
        public String m_message_ofguarantedpartiesderogatoryinfo_sec;
        public String m_message_of_brwoutside_insti_derogatoryinfo_sec;
        public String m_message_of_brwinsti_derogatoryinfo_sec;
        public String m_message_of_brwderogatoryinfo_sec;
        public String m_message_insti_PSB_privateforeignbanks;
        //public String m_nbfcothers_outside_insti_;
        public String m_nameborrwerdetails_brwdelinquencyreportedon_brw;
        public String m_mostrecentdatenoofenquiries;
        public String m_month7to12_noofenquiries;
        public String m_month4to6noofenquiries;
        public String m_month2to3noofenquiries;
        public String m_month1noofenquiries;
        public String m_month12to24noofenquiries;
        public String m_month_cfhistoryforacordpdupto24month;
        public String m_messagesuitfiledvecsuitfiledvec;
        public String m_others_noofcreditgrantors_noofcreditfacilities;
        //public String m_otherprivateforeignbanksoutside_insti_;
        public String m_opencf_PSB_otherprivateforeignbanks_nbfcothers;
        public String m_numberofemployeesborrwerdetails;
        public String m_noofenquiriesenqoutside_insti_enqinsti_enqtotal;
        public String m_noofcreditgrantorscountofcreditfacilities;
        public String m_noofcreditfacilitiescountofcreditfacilities;
        public String m_nonstdvectotaltotal;
        public String m_nonstdvectermloan_workingcapital_forex_nonfunded;
        //public String m_nonfundedinsti_outside_insti_;
        public String m_pan_borrweriddetailsborrwerdetails;
        public String m_pan_borrweriddetails;
        //public String m_overduecftotal_insti_outside_insti_;
        //public String m_outside_totaloutside_insti_;
        public String m_outside_insti_derogatoryinfo_secderogatoryinfo_sec;
        public String m_outside_insti_derogatoryinfo_brw;
        public String m_outside_insti_creditprofilesummarysec;
        public String m_outside_insti_brwdelinquencyreportedon_brw_24M_vec;
        public String m_oustandingbal_bycfandassetclasificationsecproductsec;
        public String m_oustanding_bal_cf_assetclasificationsec_outside_insti;
        public String m_relationshipdisputerelationshipdetailsvec;
        public String m_relationshipdetailsvec_productsec;
        public String m_relatedpartiesorguarantorsof_brwsecderogatoryinfo_sec;
        public String m_rankvecranksec;
        public String m_rankValue;
        public String m_ranksec_productsec;
        public String m_rankName;
        //public String m_PSBoutside_insti_;
        public String m_pincodeaddressvecaddressvec;
        public String m_pan_enqinfo_recenqinfo_rec;
        //public String m_suitfilledtotal_insti_outside_insti_;
        public String m_suitfiledvecproductsec;
        public String m_subnonstdvec;
        public String m_stdvectotaltotal;
        public String m_stdvectermloan_workingcapital_forex_nonfunded;
        public String m_stateaddressvecaddressvec;
        //public String m_settled_total_insti_outside_insti_;
        public String m_salesfigureborrwerdetails;
        public String m_reportorderdate_reportheaderrec;
        public String m_repaymentfrequencyotherdetails;
        public String m_total_termloan_workingcapital_forex_nonfundedTL;
        public String m_total_ostotaltotal;
        public String m_total_os_PSB_otherprivateforeignbanks_nbfcothers;
        public String m_total_noofenquiriesnoofenquiries;
        public String m_total_noofcreditgrantors_noofcreditfacilities;
        public String m_total_derogatoryinfo_brw_derogatoryinfo_brw;
        public String m_total_delinquentcftotal;
        public String m_total_delinquent_ostotal;
        public String m_tin_enqinfo_rec;
        //public String m_termloaninsti_outside_insti_;
        //public String m_workingcapitalinsti_outside_insti_;
        //public String m_wilfuldefaulttotal_insti_outside_insti_;
        public String m_value_sub_loss_tot_dpd;
        public String m_totaltotallenderstotal;
        public String m_totalopencftotal;
        //public String m_totalmessageoutside_insti_;
        public String m_totallenders_PSB_otherprivateforeignbanks_nbfcothers;
        //public String m_totalinsti_outside_insti_insti_outside_insti_;
        public String m_totalcf_insti_PSB_otherprivateforeignbanks_nbfcothers;
        public String m_total_totalcftotal;
        //public String m_writtenofftotal_insti_outside_insti_;
        public String m_yearborrwerDetails;
    }
    
    public static CrifExecuteAPIRequestWrapper parse(String json){
        return (CrifExecuteAPIRequestWrapper) System.JSON.deserialize(json, CrifExecuteAPIRequestWrapper.class);
    }
}