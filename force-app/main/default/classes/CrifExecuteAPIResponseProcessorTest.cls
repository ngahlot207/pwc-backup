@isTest
public class CrifExecuteAPIResponseProcessorTest {
    @isTest
    public static void testGenerateMethod() {
        
        
        LoanAppl__c La = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,La.id);
        
        BRE__c bre = new BRE__c();
        bre.LoanAppl__c = La.id;
        bre.EligibilityType__c= 'Application';
        bre.IsLatest__c = TRUE;
        insert bre;
        
        Deviation__c dev = new Deviation__c();
        dev.Dev_Type__c = 'System';
        dev.LoanAppln__c= la.id;
        dev.Applicant__c = app.id;
        dev.Deviation__c = dev.id;
        insert dev;
        
        List<Deviation__c> devList = new List<Deviation__c>();
        devList.add(dev);
        devList[0].id = dev.id;
        devList[0].Dev_Type__c = 'System';
        update devList;
        
        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='Crif Execute API';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefId__c=La.id;
        intgMsg.RefObj__c='LoanAppl__c';
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg.LoanAppln__c = la.id;
        insert intgMsg;
        
        
        List<BRE__c> breList = new List<BRE__c>();
        breList.add(bre);
        
        String filename = 'response.json';
        
        ContentVersion newContentVersion = new ContentVersion();
        newContentVersion.Title = filename;
        newContentVersion.PathOnClient = filename;  
        newContentVersion.Title = 'response.json';
        newContentVersion.VersionData = blob.valueof('{"StrategyOneResponse":{"Header":{"InquiryCode":"REQUESTID","ProcessCode":"MSE_Call12","OrganizationCode":"ORGID"},"Body":{"APPLICATION":{"Variables":{"call_id":999.99,"application_id":"TTTTT","login_acceptance_date":"2023-11-10","Final_Loan_Amount_Output":999.99,"Actual_LTV_without_Insurance":999.99,"Actual_FOIR_without_Insurance":999.99,"eligibile_loan_tenure_months":999.99,"eligible_loan_amount":999.99,"dpd60_no_36m":999.99,"count_total_tradeline_last6month":999.99,"dpd_gt30_all_active":999.99,"dpd_gt30_last6months":999.99,"LTV_with_Insurance":999.99,"LTV_without_Insurance":999.99,"max_current_dpd_of_all_live_facilities":999.99,"max_dpd_in_last_12_months_of_all_live_facilities":999.99,"max_recent_delq":999.99,"newest_tradeline_month":999.99,"oldest_tradeline_months":999.99,"product_bre":"TTTTT","ratio_current_disb_amt":999.99,"ratio_of_outstanding_amt_to_disbursed_amt_for_pl":999.99,"recent_enquiry_days":999.99,"total_active_tradelines_in_last_12_months":999.99,"total_credit_card_outstanding":999.99,"total_gl_no":999.99,"total_live_bl_pl_loan_exposure":999.99,"total_live_credit_card_overdue":999.99,"total_live_loan_exposure":999.99,"total_live_loan_overdue":999.99,"total_live_mortgage_loan_exposure":999.99,"total_live_secured_loan_exposure":999.99,"total_mortgage_enquiries_in_last_30_days":999.99,"total_no_of_live_loans":999.99,"total_pl_no":999.99,"total_secured_bal":999.99,"total_unsecured_bal":999.99,"total_unsecured_bl_pl_enquiries_in_last_30_days":999.99,"monthly_appraised_income":999.99,"selected_eligibility_program":"TTTTT","RAAC_ROI":999.99,"dpd_l12m":999.99,"dpd_gt30_active_notin_gl_fl_cd_cc_50k":999.99,"dpd_gt90_l6m":999.99,"dpd_l12m_gl_fl_cd_cc_50k":999.99,"dpd_l12m_notin_gl_fl_cd_cc_50k":999.99,"dpd_lt30_l6m":999.99,"dpd_lt90_l6m":999.99,"dpd_lt30_l12m":999.99,"Deviation_Reason":"TTTTT","Reject_Reason":"TTTTT","Decision":"TTTTT","selected_eligibility_program_value":"TTTTT","Valuation_Considered":999.99,"Rejection_Authority":"TTTTT","EMI":999.99,"LTV_RAAC_MV":999.99,"LTV_RAAC_Insurance_MV":999.99,"LTV_Deviation":999.99,"LTV_Deviation_Insurance_COP":999.99,"LTV_Deviation_Insurance_MV":999.99,"LTV_RAAC_COP":999.99,"LTV_RAAC_Insurance_COP":999.99,"dpd_gt30_all":999.99,"Total_Outstanding_BL":999.99,"dpd_lt30_l6m_all_acct":999.99,"dpd_gt90_l6m_all_acct":999.99,"Eligible_EMI_Salaried":999.99,"Combined_LTV_And_FOIR_without_Insurance":999.99,"Actual_LTV_with_Insurance":999.99,"Actual_FOIR_with_Insurance":999.99,"Combined_LTV":999.99,"LTV_with_Deviation":999.99,"Max_EMI_other_than_cash_salary":999.99,"Max_EMI_cash_salary":999.99,"Max_BRE_Loan_eligiblity_with_deviation":999.99,"Max_BRE_Loan_eligiblity_with_insurance":999.99,"Max_BRE_Loan_eligiblity_without_insurance":999.99,"Max_collateral_loan_eligibility_with_deviation":999.99,"LTV_Applicable_with_deviation":999.99,"Additional_LTV_based_Eligiblity_towards_Insurance":999.99,"LTV_based_eligibility_with_insurance":999.99,"LTV_based_eligibility_without_insurance":999.99,"LTV_Applicable_for_Loan_with_Insurance":999.99,"LTV_Applicable_for_Loan_without_Insurance":999.99,"Combined_LTV_And_FOIR_with_Insurance":999.99,"Considered_perc_Other_Income":999.99,"Considered_perc_Agriculture_Income":999.99,"Considered_perc_Pension_Income":999.99,"Considered_perc_Rental_without_Bank_Credit":999.99,"Considered_perc_Rental_Bank_Credit":999.99,"Considered_perc_Cash_Salary":999.99,"Considered_perc_Net_Eligible_Salary_with_Bank_Credit":999.99,"Considered_perc_Gross_Eligible_Salary_with_Bank_Credit":999.99,"Considered_perc_Business_Income_Regular_Income_Program":999.99,"Considered_perc_Cash_Flow_Assessed_Income":999.99,"Financial_Loan_Eligibility_total":999.99,"Financial_Loan_Eligibility_cash_salary":999.99,"Financial_Loan_Eligibility_other_than_cash_salary":999.99,"Max_Financial_Loan_Eligibility_with_deviation":999.99,"Final_Customer_Profile":"SELF EMPLOYED NON PROFESSIONAL","max_plot_funding":999.99,"max_plot_funding_with_insurance":999.99,"max_plot_funding_with_deviation":999.99,"max_funding_home_improvement_without_insurance":999.99,"max_funding_home_improvement_with_insurance":999.99,"max_funding_home_improvement_with_deviation":999.99,"pct_currentBal_all_TL":999.99,"num_times_60p_dpd":999.99,"max_recent_level_of_deliq":999.99,"Gold_TL":999.99,"Age_Oldest_TL_Mnths":999.99,"Age_Newest_TL_Mnths":999.99,"Tot_Unsecured_Bal":999.99,"Tot_Secured_Bal":999.99,"Tot_Other_Bal":999.99,"Tot_Active_TL_L12M":999.99,"time_since_recent_enq":999.99,"RF_Prob":999.99,"PL_TL":999.99,"PL_cuurbal_highcredit":999.99,"Total_TL_Open_L6M":999.99,"max_delinquency_level_max":999.99,"Financial_Loan_Eligibility_other_than_cash_salary_Deviation":999.99,"Financial_Loan_Eligibility_cash_salary_Deviation":999.99,"Decision_Scorecard_Stage_2":"TTTTT","Decision_Scorecard_Stage_1":"TTTTT","Avg_Score":999.99,"Num_Open_CC_TL_max":999.99},"Categories":[{"DEVIATION":{"Variables":{"Deviation_Code":999.99,"Deviation_Reason":"TTTTT","Deviation_Authority":"L7"}}},{"DEVIATION":{"Variables":{"Deviation_Code":999.99,"Deviation_Reason":"TTTTT","Deviation_Authority":"L6"}}},{"PROPERTY":{"Variables":{"Max_collateral_loan_eligibility_with_deviation":999.99,"LTV_Applicable_with_deviation":999.99,"Additional_LTV_based_Eligiblity_towards_Insurance":999.99,"LTV_based_eligibility_with_insurance":999.99,"LTV_based_eligibility_without_insurance":999.99,"LTV_Applicable_for_Loan_with_Insurance":999.99,"LTV_Applicable_for_Loan_without_Insurance":999.99,"max_plot_funding":999.99,"max_plot_funding_with_insurance":999.99,"max_plot_funding_with_deviation":999.99}}},{"APPLICANT":{"Variables":{"Decision":"TTTTT","age":999.99,"age_at_loan_maturity":999.99,"business_vintage":999.99,"dpd_l12m":999.99,"dpd_gt30_last6months":999.99,"dpd_gt30_all_active":999.99,"ratio_current_disb_amt":999.99,"oldest_tradeline_months":999.99,"total_secured_bal":999.99,"count_total_tradeline_last6month":999.99,"max_current_dpd_of_all_live_facilities":999.99,"max_dpd_in_last_12_months_of_all_live_facilities":999.99,"max_recent_delq":999.99,"newest_tradeline_month":999.99,"ratio_of_outstanding_amt_to_disbursed_amt_for_pl":999.99,"recent_enquiry_days":999.99,"total_active_tradelines_in_last_12_months":999.99,"total_credit_card_outstanding":999.99,"total_gl_no":999.99,"total_live_bl_pl_loan_exposure":999.99,"total_live_credit_card_overdue":999.99,"total_live_loan_exposure":999.99,"total_live_loan_overdue":999.99,"total_live_mortgage_loan_exposure":999.99,"total_live_secured_loan_exposure":999.99,"total_mortgage_enquiries_in_last_30_days":999.99,"total_no_of_live_loans":999.99,"total_pl_no":999.99,"total_unsecured_bal":999.99,"total_unsecured_bl_pl_enquiries_in_last_30_days":999.99,"dpd_gt30_active_notin_gl_fl_cd_cc_50k":999.99,"dpd_gt90_l6m":999.99,"dpd_l12m_gl_fl_cd_cc_50k":999.99,"dpd_l12m_notin_gl_fl_cd_cc_50k":999.99,"dpd_lt30_l6m":999.99,"dpd_lt90_l6m":999.99,"dpd60_no_36m":999.99,"dpd_lt30_l12m":999.99,"max_cash_salary":999.99,"monthly_appraised_income":999.99,"monthly_other_income":999.99,"income_matrix_output":"TTTTT","dpd_gt30_all":999.99,"Total_Outstanding_BL":999.99,"dpd_lt30_l6m_all_acct":999.99,"dpd_gt90_l6m_all_acct":999.99,"monthly_core_income":999.99,"Max_EMI_other_than_cash_salary":999.99,"Max_EMI_cash_salary":999.99,"Other_Deducation__considered":999.99,"Performance_Bonus_considered":999.99,"Annual_Benefits_like_LTA__considered":999.99,"Variable_Component__considered":999.99,"Gross_salary__considered":999.99,"Tax_considered":999.99,"Interest_on_Loan_considered":999.99,"Interest_on_Partners_Capital_Renum_Inc_considered":999.99,"Depreciation_considered":999.99,"Profit_Before_Tax_considered":999.99,"Net_Eligible_Salary_with_Bank_Credit":999.99,"Gross_Eligible_Salary_with_Bank_Credit":999.99,"Considered_perc_other_deductions":999.99,"Considered_perc_Performance_Bonus":999.99,"Considered_perc_annual_benefits":999.99,"Considered_perc_variable_component":999.99,"Considered_perc_Gross_Salary":999.99,"Monthly_Business_Income_Regular_Income_Program":999.99,"Annual_Business_Income_Regular_Income_Program":999.99,"Considered_perc_tax":999.99,"Applicable_EMI_Net_to_Salary":999.99,"Applicable_FOIR_cash_salary":999.99,"Applicable_FOIR":999.99,"Considered_perc_Interest_on_Loan":999.99,"Considered_perc_Interest_on_Partners_Capital_Renum_Inc":999.99,"Considered_perc_Depreciation":999.99,"Considered_perc_Profit_Before_Tax":999.99,"pct_currentBal_all_TL":999.99,"Other_Deduction_considered":999.99,"num_times_60p_dpd":999.99,"max_recent_level_of_deliq":999.99,"Gold_TL":999.99,"cust_current_outstanding":999.99,"Considered_perc_Profit_After_Tax":999.99,"Considered_perc_LIC_Agent_Commisssion_Renewal_Bonus":999.99,"Considered_perc_LIC_Agent_Commisssion_NewBusiness_Bonus":999.99,"Age_Oldest_TL_Mnths":999.99,"Age_Newest_TL_Mnths":999.99,"Tot_Unsecured_Bal":999.99,"Tot_Secured_Bal":999.99,"Tot_Other_Bal":999.99,"Tot_Active_TL_L12M":999.99,"time_since_recent_enq":999.99,"Time_Since_Last_Payment_inMnths":999.99,"RF_Prob":999.99,"Profit_After_Tax_considered":999.99,"PL_TL":999.99,"PL_cuurbal_highcredit":999.99,"type_of_account_value":"TTTTT","Total_TL_Open_L6M":999.99}}},{"COAPPLICANT":{"Variables":{"Decision":"TTTTT","age":999.99,"age_at_loan_maturity":999.99,"business_vintage":999.99,"dpd_l12m":999.99,"dpd_gt30_last6months":999.99,"dpd_gt30_all_active":999.99,"ratio_current_disb_amt":999.99,"oldest_tradeline_months":999.99,"total_secured_bal":999.99,"count_total_tradeline_last6month":999.99,"max_current_dpd_of_all_live_facilities":999.99,"max_dpd_in_last_12_months_of_all_live_facilities":999.99,"max_recent_delq":999.99,"newest_tradeline_month":999.99,"ratio_of_outstanding_amt_to_disbursed_amt_for_pl":999.99,"recent_enquiry_days":999.99,"total_active_tradelines_in_last_12_months":999.99,"total_credit_card_outstanding":999.99,"total_gl_no":999.99,"total_live_bl_pl_loan_exposure":999.99,"total_live_credit_card_overdue":999.99,"total_live_loan_exposure":999.99,"total_live_loan_overdue":999.99,"total_live_mortgage_loan_exposure":999.99,"total_live_secured_loan_exposure":999.99,"total_mortgage_enquiries_in_last_30_days":999.99,"total_no_of_live_loans":999.99,"total_pl_no":999.99,"total_unsecured_bal":999.99,"total_unsecured_bl_pl_enquiries_in_last_30_days":999.99,"dpd_gt30_active_notin_gl_fl_cd_cc_50k":999.99,"dpd_gt90_l6m":999.99,"dpd_l12m_gl_fl_cd_cc_50k":999.99,"dpd_l12m_notin_gl_fl_cd_cc_50k":999.99,"dpd_lt30_l6m":999.99,"dpd_lt90_l6m":999.99,"dpd60_no_36m":999.99,"dpd_lt30_l12m":999.99,"max_cash_salary":999.99,"monthly_appraised_income":999.99,"monthly_other_income":999.99,"dpd_gt30_all":999.99,"Total_Outstanding_BL":999.99,"dpd_lt30_l6m_all_acct":999.99,"dpd_gt90_l6m_all_acct":999.99,"monthly_core_income":999.99,"Max_EMI_other_than_cash_salary":999.99,"Max_EMI_cash_salary":999.99,"Other_Deducation__considered":999.99,"Performance_Bonus_considered":999.99,"Annual_Benefits_like_LTA__considered":999.99,"Variable_Component__considered":999.99,"Gross_salary__considered":999.99,"Tax_considered":999.99,"Interest_on_Loan_considered":999.99,"Interest_on_Partners_Capital_Renum_Inc_considered":999.99,"Depreciation_considered":999.99,"Profit_Before_Tax_considered":999.99,"Net_Eligible_Salary_with_Bank_Credit":999.99,"Gross_Eligible_Salary_with_Bank_Credit":999.99,"Considered_perc_other_deductions":999.99,"Considered_perc_Performance_Bonus":999.99,"Considered_perc_annual_benefits":999.99,"Considered_perc_variable_component":999.99,"Considered_perc_Gross_Salary":999.99,"Monthly_Business_Income_Regular_Income_Program":999.99,"Annual_Business_Income_Regular_Income_Program":999.99,"Considered_perc_tax":999.99,"Applicable_EMI_Net_to_Salary":999.99,"Applicable_FOIR_cash_salary":999.99,"Applicable_FOIR":999.99,"Considered_perc_Interest_on_Loan":999.99,"Considered_perc_Interest_on_Partners_Capital_Renum_Inc":999.99,"Considered_perc_Depreciation":999.99,"Considered_perc_Profit_Before_Tax":999.99,"pct_currentBal_all_TL":999.99,"Other_Deduction_considered":999.99,"num_times_60p_dpd":999.99,"max_recent_level_of_deliq":999.99,"Gold_TL":999.99,"cust_current_outstanding":999.99,"Considered_perc_Profit_After_Tax":999.99,"Considered_perc_LIC_Agent_Commisssion_Renewal_Bonus":999.99,"Considered_perc_LIC_Agent_Commisssion_NewBusiness_Bonus":999.99,"Age_Oldest_TL_Mnths":999.99,"Age_Newest_TL_Mnths":999.99,"Tot_Unsecured_Bal":999.99,"Tot_Secured_Bal":999.99,"Tot_Other_Bal":999.99,"Tot_Active_TL_L12M":999.99,"time_since_recent_enq":999.99,"Time_Since_Last_Payment_inMnths":999.99,"RF_Prob":999.99,"Profit_After_Tax_considered":999.99,"PL_TL":999.99,"PL_cuurbal_highcredit":999.99,"type_of_account_value":"TTTTT","Total_TL_Open_L6M":999.99}}},{"GUARANTOR":{"Variables":{"Decision":"TTTTT","age":999.99,"age_at_loan_maturity":999.99,"business_vintage":999.99,"dpd_l12m":999.99,"dpd_gt30_last6months":999.99,"dpd_gt30_all_active":999.99,"ratio_current_disb_amt":999.99,"oldest_tradeline_months":999.99,"total_secured_bal":999.99,"count_total_tradeline_last6month":999.99,"max_current_dpd_of_all_live_facilities":999.99,"max_dpd_in_last_12_months_of_all_live_facilities":999.99,"max_recent_delq":999.99,"newest_tradeline_month":999.99,"ratio_of_outstanding_amt_to_disbursed_amt_for_pl":999.99,"recent_enquiry_days":999.99,"total_active_tradelines_in_last_12_months":999.99,"total_credit_card_outstanding":999.99,"total_gl_no":999.99,"total_live_bl_pl_loan_exposure":999.99,"total_live_credit_card_overdue":999.99,"total_live_loan_exposure":999.99,"total_live_loan_overdue":999.99,"total_live_mortgage_loan_exposure":999.99,"total_live_secured_loan_exposure":999.99,"total_mortgage_enquiries_in_last_30_days":999.99,"total_no_of_live_loans":999.99,"total_pl_no":999.99,"total_unsecured_bal":999.99,"total_unsecured_bl_pl_enquiries_in_last_30_days":999.99,"dpd_gt30_active_notin_gl_fl_cd_cc_50k":999.99,"dpd_gt90_l6m":999.99,"dpd_l12m_gl_fl_cd_cc_50k":999.99,"dpd_l12m_notin_gl_fl_cd_cc_50k":999.99,"dpd_lt30_l6m":999.99,"dpd_lt90_l6m":999.99,"dpd60_no_36m":999.99,"dpd_lt30_l12m":999.99,"max_cash_salary":999.99,"monthly_appraised_income":999.99,"monthly_other_income":999.99,"dpd_gt30_all":999.99,"Total_Outstanding_BL":999.99,"dpd_lt30_l6m_all_acct":999.99,"dpd_gt90_l6m_all_acct":999.99,"monthly_core_income":999.99,"Max_EMI_other_than_cash_salary":999.99,"Max_EMI_cash_salary":999.99,"Considered_perc_Interest_on_Loan":999.99,"Considered_perc_Interest_on_Partners_Capital_Renum_Inc":999.99,"Considered_perc_Depreciation":999.99,"Considered_perc_Profit_Before_Tax":999.99,"pct_currentBal_all_TL":999.99,"num_times_60p_dpd":999.99,"max_recent_level_of_deliq":999.99,"Gold_TL":999.99,"cust_current_outstanding":999.99,"Age_Oldest_TL_Mnths":999.99,"Age_Newest_TL_Mnths":999.99,"Tot_Unsecured_Bal":999.99,"Tot_Secured_Bal":999.99,"Tot_Other_Bal":999.99,"Tot_Active_TL_L12M":999.99,"time_since_recent_enq":999.99,"Time_Since_Last_Payment_inMnths":999.99,"RF_Prob":999.99,"PL_TL":999.99,"PL_cuurbal_highcredit":999.99,"Total_TL_Open_L6M":999.99}}}]}}}}');
        insert  newContentVersion; 
                                                     
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:newContentVersion.Id].ContentDocumentId;
        ContentDocumentLink newContentLink = new ContentDocumentLink();
        newContentLink.ContentDocumentId = conDocId;
        newContentLink.LinkedEntityId = intgMsg.id; 
        newContentLink.ShareType = 'V';   
        insert newContentLink; 
                                                                
                                                     
         List<IntgMsg__c> msgs = new List<IntgMsg__c>{intgMsg};
                                                    
        Test.startTest();
         CrifExecuteAPIResponseProcessor.process(msgs);
        Test.stopTest();
        
    }
                                                     
 @isTest
public static void testGenerateMethod2() {
       
    LoanAppl__c La = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,La.id);
        
       BRE__c bre = new BRE__c();
        bre.LoanAppl__c = La.id;
        bre.EligibilityType__c= 'Application';
        bre.IsLatest__c = TRUE;
        insert bre;
        
       /*  Deviation__c dev = new Deviation__c();
        dev.Dev_Type__c = 'System';
        dev.LoanAppln__c= la.id;
        dev.Applicant__c = app.id;
        dev.Deviation__c = dev.id;
        insert dev;
        
        List<Deviation__c> devList = new List<Deviation__c>();
        devList.add(dev);
        devList[0].id = dev.id;
        devList[0].Dev_Type__c = 'System';
        update devList;*/
    
    
         //intgMsg 2  for error response
        IntgMsg__c intgMsg2 = new IntgMsg__c();
        intgMsg2.Name='Crif Execute API';
        intgMsg2.BU__c='HL / STL';
        intgMsg2.Status__c='New';
        intgMsg2.MStatus__c='Blank';
        intgMsg2.RefId__c=La.id;
        intgMsg2.RefObj__c='LoanAppl__c';
        intgMsg2.Trigger_Platform_Event__c=true;
        intgMsg2.LoanAppln__c = la.id;
        insert intgMsg2;                                             
          
    String filename = 'response.json';
          
        ContentVersion newContentVersion2 = new ContentVersion();
        newContentVersion2.Title = filename;
        newContentVersion2.PathOnClient = filename;  
        newContentVersion2.Title = 'response.json';
        newContentVersion2.VersionData = blob.valueof('{"StrategyOneResponse":{"Header":{"InquiryCode":"REQUESTID","ProcessCode":"FEDFINA_STL","ProcessVersion":20,"LayoutVersion":8},"Error":{"InquiryDate":"2024-02-24T11:27:54.385","Code":"20","Description":"Configuration Error. No conditions satisfied for values [PROPERTY.prop_state_ut_value=[MAHARASHTRA], PROPERTY.prop_property_type_value=[RESIDENTIAL], PROPERTY.property_subtype=[CHCA], APPLICATION.pdt_product=[HL], APPLICATION.product_sub_type_value=[Home Improvement Loan], PROPERTY.Flag_Self_Occ=[1], PROPERTY.Flag_Self_Occ_Rent=[1], PROPERTY.Flag_Self_Occ_Rent_Vac=[1]]","EngineVersion":"7.1.10.2307","EngineStackTrace":" - Processing Table HL_LTV_all_prog_except_plotConstsubtype VarsRTextVariable prop_state_ut_value Value : MAHARASHTRA (path=APPLICATION.PROPERTY[1].prop_state_ut_value)TextVariable prop_property_type_value Value : RESIDENTIAL (path=APPLICATION.PROPERTY[1].prop_property_type_value)TextVariable property_subtype Value : CHCA (path=APPLICATION.PROPERTY[1].property_subtype)TextVariable pdt_product Value : HL (path=APPLICATION.pdt_product)TextVariable product_sub_type_value Value : Home Improvement Loan (path=APPLICATION.product_sub_type_value)NumericVariable Flag_Self_Occ Value : 1 (path=APPLICATION.PROPERTY[1].Flag_Self_Occ)NumericVariable Flag_Self_Occ_Rent Value : 1 (path=APPLICATION.PROPERTY[1].Flag_Self_Occ_Rent)NumericVariable Flag_Self_Occ_Rent_Vac Value : 1 (path=APPLICATION.PROPERTY[1].Flag_Self_Occ_Rent_Vac) - Processing SubStrategy HL_LTV  - Processing Strategy MSE_Call4  - Processing Subsegment 1-100  - Processing Area AREA_4  - Processing Segment SEGMENT_1  - Processing DecisionProcess FEDFINA_STL "}}}');
        insert  newContentVersion2; 
                                                      
        Id conDocId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:newContentVersion2.Id].ContentDocumentId;
                                                      
        ContentDocumentLink newContentLink2 = new ContentDocumentLink();
        newContentLink2.ContentDocumentId = conDocId2;
        newContentLink2.LinkedEntityId = intgMsg2.id; 
        newContentLink2.ShareType = 'V';   
        insert newContentLink2;  
    
    List<IntgMsg__c> msgs2 = new List<IntgMsg__c>{intgMsg2}; 
        
         Test.startTest();
         CrifExecuteAPIResponseProcessor.process(msgs2);
        Test.stopTest();
}                                               
}