public class CrifExecuteAPIResponseProcessor  implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses) {
        
        Set<Id> ids = new Set<Id>();
        
        
        for (IntgMsg__c integrationMessage : responses) {
            ids.add(integrationMessage.Id);
            
        }
        
        ContentDocumentLink cdlList = [SELECT ContentDocumentId FROM ContentDocumentLink
                                       WHERE LinkedEntityId = :ids
                                       AND ContentDocument.Title = 'response.json' LIMIT 1];//response.json
        
        
        ContentVersion contentVersion = [SELECT Id, VersionData,FileType FROM ContentVersion
                                         WHERE ContentDocumentId = :cdlList.ContentDocumentId LIMIT 1];
        
        
        try {
            if (contentVersion != null) {
                
                String jsonContent = contentVersion.VersionData.toString();
                
                
                
                CrifExecuteAPIResponseWrapper res = (CrifExecuteAPIResponseWrapper) JSON.deserialize(jsonContent.replace('__considered','_considered'), CrifExecuteAPIResponseWrapper.class);
                
                
                if(res!=null && res.StrategyOneResponse!=null && res.StrategyOneResponse.Body!=null && 
                   res.StrategyOneResponse.Body.APPLICATION!=null)
                {
                    
                    //LAK-8500 Start
                    List<BRE__c> oldbre =[Select id,LoanAppl__c,IsLatest__c from BRE__c where IsLatest__c=true AND LoanAppl__c=:responses[0].RefId__c];
                    if(!oldbre.isempty()){
                        IsLatestFalse(oldbre,'IsLatest__c');
                    }
                    //LAK-8500 End
                    
                    //Getting loan Status
                    LoanAppl__c loan=[Select id,Stage__c from LoanAppl__c Where Id =:responses[0].RefId__c];
                    
                    //Checking response APPLICATION.Variables
                    if(res.StrategyOneResponse.Body.APPLICATION.Variables!=null){
                        applicationvalues(res,responses[0].RefId__c,loan.Stage__c);
                    }
                    
                    //Checking response Categories for Deviation
                    if(res.StrategyOneResponse.Body.APPLICATION.Categories!=null){
                        Deviation(res,responses[0].RefId__c,loan.Stage__c);
                    }
                    
                    //Checking response Categories for Property
                    if(res.StrategyOneResponse.Body.APPLICATION.Categories!=null){
                        Property(res,responses[0].RefId__c);
                    }
                    
                    //Checking response Categories for Applicant Co-Applicant and Gurantor
                    if(res.StrategyOneResponse.Body.APPLICATION.Categories!=null){
                        Applicantvalues(res,responses[0].RefId__c);
                    }
                    
                    //Checking response Categories for Applicant Co-Applicant and Gurantor and APPLICATION.Variables for bre eligibilty
                    if(res.StrategyOneResponse.Body.APPLICATION.Variables!=null && res.StrategyOneResponse.Body.APPLICATION.Categories!=null){
                        BREeligibility(res,responses[0].RefId__c);
                    }
                    APICalloutTracker.update_ApiTrackerWithIntMsg(responses[0].Id,responses[0].Svc__c, responses[0].RefId__c, 'Success');
                }
                
                
                //Checking Response for Error
                if(res!=null && res.StrategyOneResponse.Error!=null ){
                    CrifExecuteAPIResponseWrapper.Error er=res.StrategyOneResponse.Error;
                    errorvalues(er.Description,responses[0].id,responses[0].Resp__c,responses[0].RefId__c);
                    APICalloutTracker.update_ApiTrackerWithIntMsg(responses[0].Id,responses[0].Svc__c, responses[0].RefId__c, 'Failure');
                }
                
            }
            
        } catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIResponseProcessor class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
            String errorMessage =IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':'));
            
            errorvalues(errorMessage,responses[0].id,responses[0].Resp__c,responses[0].RefId__c);
            
            APICalloutTracker.update_ApiTrackerWithIntMsg(responses[0].Id,responses[0].Svc__c, responses[0].RefId__c, 'Failure');
            
        }
        
    }
    //***************************************************************************************************************************
    public static void errorvalues(String errorMessage,Id ids,string priorvalue,Id loanids){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {IntgMsg__c.SObjectType,LoanAppl__c.SObjectType});
        
        if(errorMessage!=null && ids !=null){
            
            try {
                List<IntgMsg__c> updateintmsg=new List<IntgMsg__c>();
                List<LoanAppl__c> loanlist =new List<LoanAppl__c>();
                
                if(!string.isBlank(errorMessage)){
                    IntgMsg__c intmsg =new IntgMsg__c();
                    intmsg.id=ids;
                    intmsg.Resp__c=priorvalue +'\n'+errorMessage;
                    updateintmsg.add(intmsg);
                }
                
                //Updating loan Application
                if(loanids!=null){
                    LoanAppl__c la =new LoanAppl__c();
                    la.id=loanids;
                    la.MaxBreLnEliWIns__c=0;
                    la.MaxBreLnEliWoIns__c=0;
                    la.EMIIcludingInsurance__c=0;
                    //la.EffectiveROI__c=0;
                    la.FinalCustProfile__c='';
                    loanlist.add(la);
                }
                //Checking Bre record 
                List<BRE__c> oldbre =[Select id,LoanAppl__c,IsLatest__c from BRE__c where IsLatest__c=true AND LoanAppl__c=:loanids];
                if(!oldbre.isempty()){
                    IsLatestFalse(oldbre,'IsLatest__c');
                }
                
                if(updateintmsg!=null){
                    List<string> fieldNamesList = New List<string>{'id','Resp__c'};
                        String sObjectName = 'IntgMsg__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                    uow.registerDirty(updateintmsg);
                }
                
                if(loanlist!=null){
                    List<string> fieldNamesList = New List<string>{'MaxBreLnEliWIns__c','MaxBreLnEliWoIns__c','FinalCustProfile__c'};
                        String sObjectName = 'LoanAppl__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkupdate(objType,fieldNamesList); 
                    uow.registerDirty(loanlist);
                }
                
                uow.commitWork();
                
                
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'CrifExecuteAPIResponseProcessor class', 
                                         'errorvalues', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
    }
    //****************************************************************************************************************************
    public static void applicationvalues(CrifExecuteAPIResponseWrapper res,Id ids,String loanStatus){
        
        if(res!=null && ids !=null){
            
            try {
                // String PrimaryApplicantID;
                
                /* Handled in LAK-8500 Start 
                List<BRE__c> BRELatest=[Select id,LoanAppl__c,IsLatest__c from BRE__c Where LoanAppl__c=:ids AND IsLatest__c =true AND EligibilityType__c='Application'];
                
                if(!BRELatest.isempty()){
                    IsLatestFalse(BRELatest,'IsLatest__c');
                }*/
                
                List<BRE__c> brelist =new List<BRE__c>();
                
                List<LoanAppl__c> loanlist =new List<LoanAppl__c>();
                
                LoanAppl__c la=new LoanAppl__c();
                la.Id=ids!=null?ids:'';
                
                CrifExecuteAPIResponseWrapper.Variables var =res.StrategyOneResponse.Body.APPLICATION.Variables;
                
                BRE__c bre =new BRE__c();
                
                bre.LoanAppl__c=ids!=null?ids:'';
                bre.EligibilityType__c='Application';
                bre.IsLatest__c=true;
                if(var.call_id!=null){
                    bre.Call_Id__c =String.valueOf(var.call_id);
                }
                if(String.isNotBlank(var.application_id)){
                    bre.AppId__c =var.application_id;
                }
                if(var.Final_Loan_Amount_Output!=null){
                    bre.FinalLoanAmtOp__c =decimal.valueOf(var.Final_Loan_Amount_Output);
                    
                }
                if(var.Actual_LTV_without_Insurance!=null){
                    bre.ActualLTVWithoutInsur__c =decimal.valueOf(var.Actual_LTV_without_Insurance);
                    
                }
                if(var.Actual_FOIR_without_Insurance!=null){
                    bre.ActualFOIRWithoutInsur__c =decimal.valueOf(var.Actual_FOIR_without_Insurance);
                    
                }
                if(var.eligibile_loan_tenure_months!=null){
                    bre.Eligible_tenure_in_Months__c =decimal.valueOf(var.eligibile_loan_tenure_months);
                    
                }
                if(var.eligible_loan_amount!=null){
                    bre.EligibleLoanAmt__c =decimal.valueOf(var.eligible_loan_amount);
                    
                }
                if(var.dpd60_no_36m!=null){
                    bre.DPD60No36M__c =decimal.valueOf(var.dpd60_no_36m);
                    
                }
                if(var.count_total_tradeline_last6month!=null){
                    bre.TotTradelLst6Mnth__c =decimal.valueOf(var.count_total_tradeline_last6month);
                    
                }
                if(var.dpd_gt30_all_active!=null){
                    bre.DPD_gt30_allActive__c =decimal.valueOf(var.dpd_gt30_all_active);
                    
                }
                if(var.dpd_gt30_last6months!=null){
                    bre.DPDGT30Lst6__c =decimal.valueOf(var.dpd_gt30_last6months);
                    
                }
                if(var.LTV_with_Insurance!=null){
                    bre.LTVInsur__c =decimal.valueOf(var.LTV_with_Insurance);
                    
                }
                
                if(var.LTV_without_Insurance!=null){
                    bre.LTVwithoutInsur__c =decimal.valueOf(var.LTV_without_Insurance);
                    
                }
                if(var.max_current_dpd_of_all_live_facilities!=null){
                    bre.Maxcurrdpdlivefacilities__c =decimal.valueOf(var.max_current_dpd_of_all_live_facilities);
                    
                }
                if(var.max_dpd_in_last_12_months_of_all_live_facilities!=null){
                    bre.MaxDPDlast12monthLive__c =decimal.valueOf(var.max_dpd_in_last_12_months_of_all_live_facilities);
                    
                }
                if(var.max_recent_delq!=null){
                    bre.MaxRecentDelq__c =decimal.valueOf(var.max_recent_delq);
                    
                }
                if(var.newest_tradeline_month!=null){
                    bre.NewTradelinemnth__c =decimal.valueOf(var.newest_tradeline_month);
                    
                }
                if(var.oldest_tradeline_months!=null){
                    bre.Oldtradelinemnth__c =decimal.valueOf(var.oldest_tradeline_months);
                    
                }
                if(String.isNotBlank(var.product_bre)){
                    bre.ProductBre__c = var.product_bre;
                    
                }
                if(var.ratio_current_disb_amt!=null){
                    bre.RatioCurrentdisbamt__c =decimal.valueOf(var.ratio_current_disb_amt);
                    
                }
                if(var.ratio_of_outstanding_amt_to_disbursed_amt_for_pl!=null){
                    bre.Ratio_outstanding_to_disbursed_am__c =decimal.valueOf(var.ratio_of_outstanding_amt_to_disbursed_amt_for_pl);
                    
                }
                if(var.recent_enquiry_days!=null){
                    bre.Rcnt_EnqDys__c =decimal.valueOf(var.recent_enquiry_days);
                    
                }
                if(var.total_active_tradelines_in_last_12_months!=null){
                    bre.Total_active_tradelines_in_last_12_month__c =decimal.valueOf(var.total_active_tradelines_in_last_12_months);
                    
                }
                if(var.total_credit_card_outstanding!=null){
                    bre.totalcrd_card_outstanding__c =decimal.valueOf(var.total_credit_card_outstanding);
                    
                }
                if(var.total_gl_no!=null){
                    bre.Total_GL_No__c =decimal.valueOf(var.total_gl_no);
                    
                }
                if(var.total_live_bl_pl_loan_exposure!=null){
                    bre.Total_Live_PL_loan_exposure__c =decimal.valueOf(var.total_live_bl_pl_loan_exposure);
                    
                }
                if(var.total_live_credit_card_overdue!=null){
                    bre.Total_live_credit_card_overdue__c =decimal.valueOf(var.total_live_credit_card_overdue);
                    
                }
                if(var.total_live_loan_exposure!=null){
                    bre.Total_Live_Loan_Exposure__c =decimal.valueOf(var.total_live_loan_exposure);
                    
                }
                if(var.total_live_loan_overdue!=null){
                    bre.Total_Live_Loan_Overdue__c = decimal.valueOf(var.total_live_loan_overdue);
                    
                }
                if(var.total_live_mortgage_loan_exposure!=null){
                    bre.Total_live_mortgage_loan_exposure__c =decimal.valueOf(var.total_live_mortgage_loan_exposure);
                    
                }
                if(var.total_live_secured_loan_exposure!=null){
                    bre.Total_live_secured_loan_exposure__c =decimal.valueOf(var.total_live_secured_loan_exposure);
                    
                }
                if(var.total_mortgage_enquiries_in_last_30_days!=null){
                    bre.Total_mortgage_enquiries_in_last_30_days__c =decimal.valueOf(var.total_mortgage_enquiries_in_last_30_days);
                    
                }
                if(var.total_no_of_live_loans!=null){
                    bre.Total_no_of_live_loans__c =decimal.valueOf(var.total_no_of_live_loans);
                    
                }
                if(var.total_pl_no!=null){
                    bre.Total_PL_No__c =decimal.valueOf(var.total_pl_no);
                    
                }
                if(var.total_secured_bal!=null){
                    bre.Total_secured_bal__c =decimal.valueOf(var.total_secured_bal);
                    
                }
                if(var.total_unsecured_bal!=null){
                    bre.Total_unsecured_bal__c =decimal.valueOf(var.total_unsecured_bal);
                    
                }
                if(var.total_unsecured_bl_pl_enquiries_in_last_30_days!=null){
                    bre.Total_unsecured_BL_PL_enq_in_last_30_day__c =decimal.valueOf(var.total_unsecured_bl_pl_enquiries_in_last_30_days);
                    
                }
                if(var.monthly_appraised_income!=null){
                    bre.Mnthlyapprincome__c =decimal.valueOf(var.monthly_appraised_income);
                    
                }
                if(String.isNotBlank(var.selected_eligibility_program)){
                    bre.Application_level_Assessment_program__c = var.selected_eligibility_program;
                    
                }
                if(var.RAAC_ROI!=null){
                    bre.RAACROI__c = decimal.valueOf(var.RAAC_ROI);
                    // la.EffectiveROI__c=decimal.valueOf(var.RAAC_ROI);
                }
                if(var.dpd_l12m!=null){
                    bre.DPD_l12_m__c = decimal.valueOf(var.dpd_l12m);
                    
                }
                if(var.dpd_gt30_active_notin_gl_fl_cd_cc_50k!=null){
                    bre.DPD_GT_30_Act_Ntg_50k__c =decimal.valueOf(var.dpd_gt30_active_notin_gl_fl_cd_cc_50k);
                    
                }
                if(var.dpd_gt90_l6m!=null){
                    bre.DPD_GT_90_l6_m__c = decimal.valueOf(var.dpd_gt90_l6m);
                    
                }
                if(var.dpd_l12m_gl_fl_cd_cc_50k!=null){
                    bre.DPD_l_12m_gl_fl_cd_cc_50k__c =decimal.valueOf(var.dpd_l12m_gl_fl_cd_cc_50k);
                    
                }
                if(var.dpd_l12m_notin_gl_fl_cd_cc_50k!=null){
                    bre.DPD_l12m_notingl_fl_cd_cc_50k__c = decimal.valueOf(var.dpd_l12m_notin_gl_fl_cd_cc_50k);
                    
                }
                if(var.dpd_lt30_l6m!=null){
                    bre.DPD_lt30_l6m__c = decimal.valueOf(var.dpd_lt30_l6m);
                    
                }
                if(var.dpd_lt90_l6m!=null){
                    bre.DPD_lt90_l6m__c = decimal.valueOf(var.dpd_lt90_l6m);
                    
                }
                if(var.dpd_lt30_l12m!=null){
                    bre.DPD_lt30_l12m__c = decimal.valueOf(var.dpd_lt30_l12m);
                    
                }
                if(String.isNotBlank(var.Deviation_Reason)){
                    bre.Deviation_Reason__c = var.Deviation_Reason;
                    
                }
                if(String.isNotBlank(var.Reject_Reason)){
                    bre.Reject_Reason__c = var.Reject_Reason;
                    
                }
                if(String.isNotBlank(var.Decision)){
                    bre.Decision__c = var.Decision;
                    
                    if(res.StrategyOneResponse.Body.APPLICATION.Categories!=null){
                        
                        Boolean deviationcheck=false;
                        
                        for(CrifExecuteAPIResponseWrapper.Categories category : res.StrategyOneResponse.Body.APPLICATION.Categories){
                            
                            if(category.DEVIATION!=null && category.DEVIATION.Variables!=null && 
                               String.isblank(category.DEVIATION.Variables.Deviation_BRE_Decision)){
                                deviationcheck=true;
                            }
                            else if(category.DEVIATION!=null && category.DEVIATION.Variables==null){
                                deviationcheck=true;
                            }
                        }
                        
                        if(deviationcheck && breDecisionMap.containsKey(var.Decision.tolowerCase()) && loanStatus=='QDE'){
                            la.Status__c=breDecisionMap.get(var.Decision.tolowerCase());
                        }
                    }
                    
                }
                if(String.isNotBlank(var.selected_eligibility_program_value)){
                    bre.Selected_eligibility_program_value__c = var.selected_eligibility_program_value;
                    
                }
                if(var.Valuation_Considered!=null){
                    bre.Valuation_Considered__c = decimal.valueOf(var.Valuation_Considered);
                    
                }
                if(String.isNotBlank(var.Rejection_Authority)){
                    bre.Rejection_Authority__c = var.Rejection_Authority;
                    
                }
                if(var.EMI!=null){
                    bre.EMI__c = decimal.valueOf(var.EMI);
                    la.EMIIcludingInsurance__c=decimal.valueOf(var.EMI);
                    
                }
                if(var.LTV_RAAC_MV!=null){
                    bre.LTV_RAAC_MV__c =decimal.valueOf(var.LTV_RAAC_MV);
                    
                }
                if(var.LTV_RAAC_Insurance_MV!=null){
                    bre.LTV_RAAC_Insurance_MV__c = decimal.valueOf(var.LTV_RAAC_Insurance_MV);
                    
                }
                if(var.LTV_Deviation!=null){
                    bre.LTV_Deviation__c = decimal.valueOf(var.LTV_Deviation);
                    
                }
                if(var.LTV_Deviation_Insurance_COP!=null){
                    bre.LTV_Deviation_Insur_COP__c = decimal.valueOf(var.LTV_Deviation_Insurance_COP);
                    
                }
                if(var.LTV_Deviation_Insurance_MV!=null){
                    bre.LTV_Deviation_Insurance_MV__c =decimal.valueOf(var.LTV_Deviation_Insurance_MV);
                    
                }
                if(var.LTV_RAAC_COP!=null){
                    bre.LTV_RAAC_COP__c = decimal.valueOf(var.LTV_RAAC_COP);
                    
                }
                if(var.LTV_RAAC_Insurance_COP!=null){
                    bre.LTV_RAAC_Insurance_COP__c = decimal.valueOf(var.LTV_RAAC_Insurance_COP);
                    
                }
                if(var.dpd_gt30_all!=null){
                    bre.DPDGT30all__c = decimal.valueOf(var.dpd_gt30_all);
                    
                }
                if(var.Total_Outstanding_BL!=null){
                    bre.Total_Outstanding_BL__c =decimal.valueOf(var.Total_Outstanding_BL);
                    
                }
                if(var.dpd_lt30_l6m_all_acct!=null){
                    bre.DPD_lt30_l6m_all_acct__c =decimal.valueOf(var.dpd_lt30_l6m_all_acct);
                    
                }
                if(var.dpd_gt90_l6m_all_acct!=null){
                    bre.DPD_gt90_l6m_all_acct__c =decimal.valueOf(var.dpd_gt90_l6m_all_acct);
                    
                }
                if(var.Eligible_EMI_Salaried!=null){
                    bre.Eligible_EMI_Salaried__c = decimal.valueOf(var.Eligible_EMI_Salaried);
                    
                }
                if(var.Combined_LTV_And_FOIR_without_Insurance!=null){
                    bre.Combined_LTV_And_FOIR_without_Insurance__c =decimal.valueOf(var.Combined_LTV_And_FOIR_without_Insurance);
                    
                }
                if(var.Actual_LTV_with_Insurance!=null){
                    bre.Actual_LTV__c=decimal.valueOf(var.Actual_LTV_with_Insurance);
                    
                }
                if(var.Actual_FOIR_with_Insurance!=null){
                    bre.Actual_FOIR__c =decimal.valueOf(var.Actual_FOIR_with_Insurance);
                    
                }
                if(var.Combined_LTV!=null){
                    bre.Combined_LTV__c =decimal.valueOf(var.Combined_LTV);
                    
                }
                if(var.LTV_with_Deviation!=null){
                    bre.LTV_with_Deviation__c =decimal.valueOf(var.LTV_with_Deviation);
                    
                }
                if(var.Max_EMI_other_than_cash_salary!=null){
                    bre.Max_EMI_Other_than_Cash_Salary__c =decimal.valueOf(var.Max_EMI_other_than_cash_salary);
                    
                }
                if(var.Max_EMI_cash_salary!=null){
                    bre.Max_EMI_Cash_Salary__c =decimal.valueOf(var.Max_EMI_cash_salary);
                    
                }
                
                if(var.Max_BRE_Loan_eligiblity_with_deviation!=null){
                    bre.MaxBreLnEliWDeviation__c = decimal.valueOf(var.Max_BRE_Loan_eligiblity_with_deviation);
                    
                }
                if(var.Max_BRE_Loan_eligiblity_with_insurance!=null){
                    bre.MaxBreLnEliWIns__c =decimal.valueOf(var.Max_BRE_Loan_eligiblity_with_insurance);
                    la.MaxBreLnEliWIns__c=decimal.valueOf(var.Max_BRE_Loan_eligiblity_with_insurance);
                    
                }
                if(var.Max_BRE_Loan_eligiblity_without_insurance!=null){
                    bre.MaxBreLnEliWoIns__c = decimal.valueOf(var.Max_BRE_Loan_eligiblity_without_insurance);
                    la.MaxBreLnEliWoIns__c=decimal.valueOf(var.Max_BRE_Loan_eligiblity_without_insurance);
                }
                if(var.Max_collateral_loan_eligibility_with_deviation!=null){
                    bre.MaxcoltrlLnEliWDeviation__c =decimal.valueOf(var.Max_collateral_loan_eligibility_with_deviation);
                    
                }
                if(var.LTV_Applicable_with_deviation!=null){
                    bre.LTVApplWDeviation__c = decimal.valueOf(var.LTV_Applicable_with_deviation);
                    
                }
                if(var.Additional_LTV_based_Eligiblity_towards_Insurance!=null){
                    bre.AddLTVBsdEliIns__c =decimal.valueOf(var.Additional_LTV_based_Eligiblity_towards_Insurance);
                    
                }
                if(var.LTV_based_eligibility_with_insurance!=null){
                    bre.LTV_based_eligibility_with_insurance__c =decimal.valueOf(var.LTV_based_eligibility_with_insurance);
                    
                }
                if(var.LTV_based_eligibility_without_insurance!=null){
                    bre.LTVBsdEliWOIns__c =decimal.valueOf(var.LTV_based_eligibility_without_insurance);
                    
                }
                if(var.LTV_Applicable_for_Loan_with_Insurance!=null){
                    bre.LTVApplLnWtInsurance__c =decimal.valueOf(var.LTV_Applicable_for_Loan_with_Insurance);
                    
                }
                if(var.LTV_Applicable_for_Loan_without_Insurance!=null){
                    bre.LTVApplLnWOInsurance__c =decimal.valueOf(var.LTV_Applicable_for_Loan_without_Insurance);
                    
                }
                if(var.Combined_LTV_And_FOIR_with_Insurance!=null){
                    bre.Combined_LTV_And_FOIR_with_Insurance__c =decimal.valueOf(var.Combined_LTV_And_FOIR_with_Insurance);
                    
                }
                if(var.Considered_perc_Other_Income!=null){
                    bre.Consideredpercothrded__c =decimal.valueOf(var.Considered_perc_Other_Income);
                    
                }
                if(var.Considered_perc_Agriculture_Income!=null){
                    bre.Considered_Perc_Agri_Income__c =decimal.valueOf(var.Considered_perc_Agriculture_Income);
                    
                }
                if(var.Considered_perc_Pension_Income!=null){
                    bre.Considered_Perc_Pension_Income__c =decimal.valueOf(var.Considered_perc_Pension_Income);
                    
                }
                if(var.Considered_perc_Rental_without_Bank_Credit!=null){
                    bre.Considered_Perc_Rental_without_Bank_Cred__c =decimal.valueOf(var.Considered_perc_Rental_without_Bank_Credit);
                    
                }
                if(var.Considered_perc_Rental_Bank_Credit!=null){
                    bre.Considered_Perc_Rental_Bank_Credit__c =decimal.valueOf(var.Considered_perc_Rental_Bank_Credit);
                    
                }
                if(var.Considered_perc_Cash_Salary!=null){
                    bre.Considered_Perc_Cash_Salary__c =decimal.valueOf(var.Considered_perc_Cash_Salary);
                    
                }
                if(var.Considered_perc_Net_Eligible_Salary_with_Bank_Credit!=null){
                    bre.Considered_Perc_Net_Eligible_Salary__c =decimal.valueOf(var.Considered_perc_Net_Eligible_Salary_with_Bank_Credit);
                    
                }
                if(var.Considered_perc_Gross_Eligible_Salary_with_Bank_Credit!=null){
                    bre.Considered_Perc_Gross_Eligible_Salary__c =decimal.valueOf(var.Considered_perc_Gross_Eligible_Salary_with_Bank_Credit);
                    
                }
                if(var.Considered_perc_Business_Income_Regular_Income_Program!=null){
                    bre.Considered_Perc_Business_Income_Regular__c =decimal.valueOf(var.Considered_perc_Business_Income_Regular_Income_Program);
                    
                }
                if(var.Considered_perc_Cash_Flow_Assessed_Income!=null){
                    bre.Considered_Perc_Cash_Flow__c =decimal.valueOf(var.Considered_perc_Cash_Flow_Assessed_Income);
                    
                }
                if(var.Financial_Loan_Eligibility_total!=null){
                    bre.FinancialLoanEligibilityTotal__c =decimal.valueOf(var.Financial_Loan_Eligibility_total);
                    
                }
                
                if(var.Financial_Loan_Eligibility_cash_salary!=null){
                    bre.FinLoanEligibCashSalary__c =decimal.valueOf(var.Financial_Loan_Eligibility_cash_salary);
                    
                }
                if(var.Financial_Loan_Eligibility_other_than_cash_salary!=null){
                    bre.Financial_Loan_Eligibility_other_cash__c= decimal.valueOf(var.Financial_Loan_Eligibility_other_than_cash_salary);
                    
                }
                if(var.Max_Financial_Loan_Eligibility_with_deviation!=null){
                    bre.MaxFinLnEligblwithDevi__c =decimal.valueOf(var.Max_Financial_Loan_Eligibility_with_deviation);
                    
                }
                
                if(string.isNotBlank(var.Final_Customer_Profile)){
                    la.FinalCustProfile__c=var.Final_Customer_Profile;
                    bre.FinalCustProfile__c=var.Final_Customer_Profile;
                }
                //LAK-6157 Changes
                if(var.max_plot_funding!=null){
                    bre.MaxPlotFund__c=var.max_plot_funding;
                }
                
                if(var.max_plot_funding_with_insurance!=null){
                    bre.MaxPlotFundWithInsu__c=var.max_plot_funding_with_insurance;
                }
                
                if(var.max_plot_funding_with_deviation!=null){
                    bre.MaxPlotFundWithDeviation__c=var.max_plot_funding_with_deviation;
                }
                
                if(var.max_funding_home_improvement_without_insurance!=null){
                    bre.Maxfundinghomeimprovementwithoutinsur__c=var.max_funding_home_improvement_without_insurance;
                }
                
                if(var.max_funding_home_improvement_with_insurance!=null){
                    bre.Maxfundinghomeimprovementwithinsur__c=var.max_funding_home_improvement_with_insurance;
                }
                
                if(var.max_funding_home_improvement_with_deviation!=null){
                    bre.Maxfundinghomeimprovementwithdevi__c=var.max_funding_home_improvement_with_deviation;
                }
                
                 /*Commentting Due to LAK-6471 
                if(var.pct_currentBal_all_TL!=null){
                    bre.PctcurrentBalallTL__c=var.pct_currentBal_all_TL;
                }*/
                
                if(var.num_times_60p_dpd!=null){
                    bre.Numtimes60pdpd__c=var.num_times_60p_dpd;
                }
                
                if(var.max_recent_level_of_deliq!=null){
                    bre.Maxrecentleveldeliq__c=var.max_recent_level_of_deliq;
                }
                
                if(var.Gold_TL!=null){
                    bre.GoldTL__c=var.Gold_TL;
                }
                
                /*Commentting Due to LAK-6471 
                if(var.Age_Oldest_TL_Mnths!=null){
                    bre.AgeOldestTLMnths__c=var.Age_Oldest_TL_Mnths;
                }
                */
                
                if(var.Age_Newest_TL_Mnths!=null){
                    bre.AgeNewestTLMnths__c=var.Age_Newest_TL_Mnths;
                }
                
                if(var.Tot_Unsecured_Bal!=null){
                    bre.TotUnsecuredBal__c=var.Tot_Unsecured_Bal;
                }
                
                if(var.Tot_Secured_Bal!=null){
                    bre.TotSecuredBal__c=var.Tot_Secured_Bal;
                }
                
                if(var.Tot_Other_Bal!=null){
                    bre.TotOtherBal__c=var.Tot_Other_Bal;
                }
                
                if(var.Tot_Active_TL_L12M!=null){
                    bre.TotActiveTLL12M__c=var.Tot_Active_TL_L12M;
                }
                
                if(var.time_since_recent_enq!=null){
                    bre.Timesincerecentenq__c=var.time_since_recent_enq;
                }
                
                if(var.RF_Prob!=null){
                    bre.RFProb__c=var.RF_Prob;
                }
                
                if(var.PL_TL!=null){
                    bre.PLTL__c=var.PL_TL;
                }
                
                if(var.PL_cuurbal_highcredit!=null){
                    bre.PLcuurbalhighcredit__c=var.PL_cuurbal_highcredit;
                }
                
                if(var.Total_TL_Open_L6M!=null){
                    bre.TotalTLOpenL6M__c=var.Total_TL_Open_L6M;
                }
                
                if(var.max_delinquency_level_max!=null){
                    bre.Maxdelilvlmax__c=var.max_delinquency_level_max;
                }
                
                if(var.Financial_Loan_Eligibility_other_than_cash_salary_Deviation!=null){
                    bre.FinLoanEligotrcashsaldevi__c=var.Financial_Loan_Eligibility_other_than_cash_salary_Deviation;
                }
                
                if(var.Financial_Loan_Eligibility_cash_salary_Deviation!=null){
                    bre.FinLoanEligcashsalaryDevi__c=var.Financial_Loan_Eligibility_cash_salary_Deviation;
                }
                
                if(String.isNotBlank(var.Decision_Scorecard_Stage_2)){
                    bre.DecisionScrecardStg2__c=var.Decision_Scorecard_Stage_2;
                }
                
                if(String.isNotBlank(var.Decision_Scorecard_Stage_1)){
                    bre.DecisionScrecardStg1__c=var.Decision_Scorecard_Stage_1;
                }
                
                if(var.Avg_Score!=null){
                    bre.AvgScore__c=var.Avg_Score;
                }
                
                if(var.Num_Open_CC_TL_max!=null){
                    bre.NumOpenCCTLmax__c=var.Num_Open_CC_TL_max;
                }
                
                 //LAK-6471 Start
                if(String.isNotblank(var.Deviation_Decision)){
                    bre.DeviationDecision__c=var.Deviation_Decision;
                }
                
                if(var.revised_roi_perc!=null){
                    bre.Revisedroiperc__c=var.revised_roi_perc; 
                }
                
                if(var.Age_Oldest_TL_Mnths_max!=null){
                    bre.AgeOldTLMnthsMax__c=var.Age_Oldest_TL_Mnths_max; 
                }
                
                if(String.isNotblank(var.Final_Decision_Scorecard)){
                    bre.FinalDecisionScorecard__c=var.Final_Decision_Scorecard;
                }
               
                if(String.isNotblank(var.Hard_Policy_Decision)){
                    bre.HardPolicyDecision__c=var.Hard_Policy_Decision;
                }
                
                if(var.time_since_recent_delinquency_min!=null){
                    bre.TimeRecentDelinqMin__c=var.time_since_recent_delinquency_min; 
                }
                
                if(var.pct_of_active_TLs_ever_min!=null){
                    bre.PctOfActiveTLs__c=var.pct_of_active_TLs_ever_min; 
                }
                
                if(var.Unsec_utilization_max!=null){
                    bre.UnsecUtilization__c=var.Unsec_utilization_max; 
                }
                
                if(String.isNotblank(var.Application_Scorecard_Result)){
                    bre.AppScorecardResult__c=var.Application_Scorecard_Result;
                }
                
                if(var.Cumulative_LTV_Pc!=null){
                    bre.CumulativeLTVPc__c=var.Cumulative_LTV_Pc; 
                }
                
                if(var.Max_Plot_Funding_overall_eligibility!=null){
                    bre.MaxPlotFundingOverallElig__c=var.Max_Plot_Funding_overall_eligibility; 
                }
                //LAK-6471 End
                
                brelist.add(bre);
                loanlist.add(la);
                
                if(brelist!=null){
                    Insert brelist;
                }
                
                if(loanlist!=null){
                    Update loanlist;
                }
                
             } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'CrifExecuteAPIResponseProcessor class', 
                                         'applicationvalues', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            
            
        }
        
    }
    //******************************************************************************************************************************
    public static void Deviation(CrifExecuteAPIResponseWrapper res,Id ids,String loanStatus){
        
        if(res!=null && ids!=null){
            
            try {
                List<Deviation__c> insertDeviation = new List<Deviation__c>();
                Set<Integer> setOfDeviationCode =new Set<Integer>();
                
                
                List<BRE__c> BRELatest=[Select id,Applicant_Asset__c,LoanAppl__c,IsLatest__c,EligibilityType__c from BRE__c Where LoanAppl__c=:ids AND IsLatest__c =true AND EligibilityType__c='Application'];
                
                Map<Double, CrifExecuteAPIResponseWrapper.deviationvariable> deviationAuthorities = new Map<Double, CrifExecuteAPIResponseWrapper.deviationvariable>();
               
                Map<String,Deviation__c> existingDevMap= new Map<String,Deviation__c>();
                
                For(Deviation__c deviation : [SELECT ID,Deviation__c FROM Deviation__c WHERE LoanAppln__c=:ids and Dev_Type__c = 'System']){
                    existingDevMap.put(deviation.Deviation__c,deviation);
                }
                for(CrifExecuteAPIResponseWrapper.Categories category : res.StrategyOneResponse.Body.APPLICATION.Categories){
                    
                    if (category.DEVIATION!=null) {
                        
                        CrifExecuteAPIResponseWrapper.deviationvariable dv = category.DEVIATION.Variables;
                        
                        
                        if(dv.Deviation_Code!=null && dv.Deviation_Authority!=null){
                            
                            Double deviationCode = dv.Deviation_Code;
                            
                            setOfDeviationCode.add(Integer.valueOf(dv.Deviation_Code));
                            
                            // Check if the deviation code is already in the map
                            if (deviationAuthorities.containsKey(deviationCode)) {
                                // If the current authority is higher than the stored authority, update it
                                if (compareAuthorities(dv.Deviation_Authority, deviationAuthorities.get(deviationCode).Deviation_Authority) > 0) {
                                    deviationAuthorities.put(deviationCode, dv);
                                }
                            } else {
                                // If the deviation code is not in the map, add it with the current authority
                                deviationAuthorities.put(deviationCode, dv);
                            }
                            
                        }
                        
                        
                    }
                    
                }
                
                
                
                
                for (Double deviationCode : deviationAuthorities.keySet()) {
                    CrifExecuteAPIResponseWrapper.deviationvariable deviation = deviationAuthorities.get(deviationCode);
                    
                    Deviation__c deviationRecord = new Deviation__c();
                    deviationRecord.LoanAppln__c = ids!=null?ids:'';
                    deviationRecord.Dev_Type__c ='System';
                    deviationRecord.Status__c='Active';
                        
                    if(deviation.Deviation_Code!=null){
                        
                        Decimal numericvalue=deviation.Deviation_Code;
                        
                        if(numericvalue.scale()>0 && numericvalue.stripTrailingZeros().scale()>0){
                            
                            deviationRecord.Deviation__c = string.valueof(numericvalue);
                            
                        }else{
                            deviationRecord.Deviation__c = string.valueof((Integer)numericvalue.intValue());
                        }
                        
                        
                    }
                    
                    if(String.isNotblank(deviation.Deviation_BRE_Decision)){
                        deviationRecord.DeviationBREDecision__c=deviation.Deviation_BRE_Decision;
                    }
                    
                    deviationRecord.Devia_Desrp__c = deviation.Deviation_Reason;
                    deviationRecord.Req_Apprv_Level__c = deviation.Deviation_Authority.substring(1);
                    deviationRecord.BRE__c = !BRELatest.isEmpty()?BRELatest[0].Id:'';
                    if(existingDevMap.containsKey(deviationRecord.Deviation__c)){
                        deviationRecord.id = existingDevMap.get(deviationRecord.Deviation__c).Id;
                    }
                    insertDeviation.add(deviationRecord);
                }
                
                if(insertDeviation!=null){
                    upsert insertDeviation;
                    
                    List<Deviation__c> devi=[Select Id,LoanAppeal__c,Status__c,Deviation__c,LoanAppln__c,LoanAppln__r.Status__c,Dev_Type__c,
                                             DeviationBREDecision__c,CallId__c from Deviation__c Where 
                                             LoanAppln__c =:ids AND Dev_Type__c = 'System'];
                    
                    //Updating Loan Applicantion
                    if(!devi.isEmpty() && res.StrategyOneResponse.Body.APPLICATION.Variables!=null && 
                       string.isNotblank(res.StrategyOneResponse.Body.APPLICATION.Variables.Decision)){
                           
                           Boolean anyNull = false;
                           //String DeviationBREDecision='';
                           
                           for(Deviation__c dev:devi){
                              
                               if(dev.LoanAppeal__c==null && string.isNotblank(dev.DeviationBREDecision__c) && dev.DeviationBREDecision__c.tolowerCase().contains('reject')){
                                   anyNull=true;
                                   //DeviationBREDecision=dev.DeviationBREDecision__c.tolowerCase();
                                   break;
                               }
                           }
                           
                           LoanAppl__c la =new LoanAppl__c();
                           la.Id=ids;
                           
                           if(anyNull==true && breDecisionMap.containsKey(res.StrategyOneResponse.Body.APPLICATION.Variables.Decision.tolowerCase()) && loanStatus=='QDE'){
                               
                               la.Status__c= breDecisionMap.get(res.StrategyOneResponse.Body.APPLICATION.Variables.Decision.tolowerCase());
                           }
                           else if(loanStatus=='QDE' && breDecisionMap.containsKey(res.StrategyOneResponse.Body.APPLICATION.Variables.Decision.tolowerCase())){
                               la.Status__c= breDecisionMap.get(res.StrategyOneResponse.Body.APPLICATION.Variables.Decision.tolowerCase());
                           }
                           
                           Update la;
                           
                           
                            
                           //if(res.StrategyOneResponse.Body.APPLICATION.Variables.Decision.tolowerCase().contains('reject') && anyNull==true){
                          //      la.Status__c='BRE Reject'; 
                          // }
                          
                       }
                    
                    //Deviation Upgrade or Downgrade
                    if(!devi.isEmpty()){
                        
                        for(Deviation__c dv:devi){
                            
                            if(!setOfDeviationCode.contains(Integer.valueOf(dv.Deviation__c))){
                                dv.Status__c='Inactive';
                            }
                            else{
                                
                                if(setOfDeviationCode.contains(Integer.valueOf(dv.Deviation__c)) &&
                                   res.StrategyOneResponse.Body.APPLICATION.Variables.call_id>dv.CallId__c){
                                       
                                       if(Integer.valueOf(res.StrategyOneResponse.Body.APPLICATION.Variables.call_id)!=5){
                                           dv.CallId__c=Integer.valueOf(res.StrategyOneResponse.Body.APPLICATION.Variables.call_id);
                                       }
                                       
                                       if(Integer.valueOf(res.StrategyOneResponse.Body.APPLICATION.Variables.call_id)==5 &&
                                          dv.LoanAppeal__c==null){
                                           dv.CallId__c=Integer.valueOf(res.StrategyOneResponse.Body.APPLICATION.Variables.call_id);
                                           
                                       }
                                       //dv.CallId__c=Integer.valueOf(res.StrategyOneResponse.Body.APPLICATION.Variables.call_id);
                                   }
                                else{
                                    dv.CallId__c=Integer.valueOf(res.StrategyOneResponse.Body.APPLICATION.Variables.call_id);
                                }
                            }
                            
                            
                            
                        }
                        
                        update devi;
                    }
                }
                
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'CrifExecuteAPIResponseProcessor class', 
                                         'Deviation', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
    }
    
    //*****************************************************************************************************************************
    public static void Property(CrifExecuteAPIResponseWrapper res,Id ids){
        
         if(res!=null && ids !=null){
            try {
                List<String> appids =new List<String>();
                
                
                //getting all the applicant id using unquieID response fileds
                for(CrifExecuteAPIResponseWrapper.Categories category : res.StrategyOneResponse.Body.APPLICATION.Categories){
                    
                    if(category.PROPERTY!=null){
                        
                        CrifExecuteAPIResponseWrapper.propertyvariables pro =category.PROPERTY.Variables;
                        
                        if(!String.isBlank(pro.unique_id)){
                            appids.add(pro.unique_id);
                        }
                    }
                    
                }
                
                 /* Handled in LAK-8500
                if(appids!=null){
                    
                   
                     List<BRE__c> BRELatest=[Select id,Applicant_Asset__c,LoanAppl__c,IsLatest__c from BRE__c Where LoanAppl__c=:ids AND IsLatest__c =true AND EligibilityType__c='Property'];
                    if(!BRELatest.isempty()){
                        IsLatestFalse(BRELatest,'IsLatest__c');
                    }
                    
                }*/
                
                List<BRE__c> brelist = new List<BRE__c>();
                
                for (CrifExecuteAPIResponseWrapper.Categories category : res.StrategyOneResponse.Body.APPLICATION.Categories) {
                    
                    
                    if (category.PROPERTY!=null) {
                        
                        CrifExecuteAPIResponseWrapper.propertyvariables porvar=category.PROPERTY.Variables;
                        
                        BRE__c bre =new BRE__c();
                        
                        bre.LoanAppl__c=ids!=null?ids:'';
                        bre.EligibilityType__c='Property';
                        bre.IsLatest__c=true;
                        
                        if(!String.isBlank(porvar.unique_id)){
                            bre.Applicant_Asset__c=porvar.unique_id;
                        }
                        
                        if (porvar.Additional_LTV_based_Eligiblity_towards_Insurance!=null) {
                            bre.AddLTVBsdEliIns__c=porvar.Additional_LTV_based_Eligiblity_towards_Insurance;
                        }
                        if (porvar.LTV_Applicable_for_Loan_with_Insurance!=null) {
                            bre.LTVApplLnWtInsurance__c=porvar.LTV_Applicable_for_Loan_with_Insurance;
                        }
                        if (porvar.LTV_Applicable_for_Loan_without_Insurance!=null) {
                            bre.LTVApplLnWOInsurance__c=porvar.LTV_Applicable_for_Loan_without_Insurance;
                        }
                        if (porvar.LTV_Applicable_with_deviation!=null) {
                            bre.LTVApplWDeviation__c=porvar.LTV_Applicable_with_deviation;
                        }
                        if (porvar.LTV_based_eligibility_with_insurance!=null) {
                            bre.TotlLTVBsdLnEliWIns__c=porvar.LTV_based_eligibility_with_insurance;
                        }
                        if (porvar.LTV_based_eligibility_without_insurance!=null) {
                            bre.LTVBsdEliWOIns__c=porvar.LTV_based_eligibility_without_insurance;
                        }
                        if (porvar.Max_collateral_loan_eligibility_with_deviation!=null) {
                            bre.MaxcoltrlLnEliWDeviation__c=porvar.Max_collateral_loan_eligibility_with_deviation;
                        }
                        //LAK-6157 Changes 
                        
                        /*Commentting Due to LAK-6471 
                        if (porvar.max_plot_funding!=null) {
                            bre.MaxPlotFund__c=porvar.max_plot_funding;
                        }
                        
                        if (porvar.max_plot_funding_with_insurance!=null) {
                            bre.MaxPlotFundWithInsu__c=porvar.max_plot_funding_with_insurance;
                        }
                        
                         
                        if (porvar.max_plot_funding_with_deviation!=null) {
                            bre.MaxPlotFundWithDeviation__c=porvar.max_plot_funding_with_deviation;
                        }*/
                        
                        brelist.add(bre);
                        
                    }
                    
                }
                
                
                
                
                
                if(brelist!=null){
                    Insert brelist;
                }
                
             } catch (Exception ex) {
                //system.debug('Error message and line number: ' + ex.getMessage() + ' Line: ' + ex.getLineNumber());
                GlobalUtility.logMessage('Error', 'CrifExecuteAPIResponseProcessor class', 
                                         'Property', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
    }
    //*****************************************************************************************************************************
    public static void Applicantvalues(CrifExecuteAPIResponseWrapper res,Id ids){
        
        if (res !=null && ids !=null) {
            
            try {
                
                List<String> appids =new List<String>();
                
                //getting the Primairy Applicant
                List<Applicant__c> Applicantlist =[Select id,LoanAppln__c,ApplType__c from Applicant__c Where LoanAppln__c =:ids AND ApplType__c='P' LIMIT 1];
                
                //getting all the applicant id using unquieID response fileds
                for(CrifExecuteAPIResponseWrapper.Categories category : res.StrategyOneResponse.Body.APPLICATION.Categories){
                    
                    if(category.COAPPLICANT!=null){
                        
                        CrifExecuteAPIResponseWrapper.co_applicantvariabels coappvar =category.COAPPLICANT.Variables;
                        
                        if(!String.isBlank(coappvar.unique_id)){
                            appids.add(coappvar.unique_id);
                        }
                    }
                    
                    if(category.GUARANTOR!=null){
                        
                        CrifExecuteAPIResponseWrapper.guarantorvariabels guarantor =category.GUARANTOR.Variables;
                        
                        if(!String.isBlank(guarantor.unique_id)){
                            appids.add(guarantor.unique_id);
                        }
                    }
                    
                }
                appids.add(Applicantlist[0].id);
                
               
               /* Handled in LAK-8500 
                 if(appids!=null){
                    
                    List<BRE__c> BRELatest=[Select id,Applicant__c,LoanAppl__c,IsLatest__c from BRE__c Where Applicant__c IN:appids AND LoanAppl__c=:ids AND IsLatest__c =true AND EligibilityType__c='Applicant'];
                    
                    if(!BRELatest.isempty()){
                        IsLatestFalse(BRELatest,'IsLatest__c');
                    }
                    
                }*/
                
                
                List<BRE__c> brelist = new List<BRE__c>();
                
                for (CrifExecuteAPIResponseWrapper.Categories category : res.StrategyOneResponse.Body.APPLICATION.Categories) {
                    
                    //APPLICANT Variables
                    
                    if (category.APPLICANT!=null) {
                        
                        CrifExecuteAPIResponseWrapper.applicantvariabels appvar =category.APPLICANT.Variables;
                        
                        BRE__c bre =new BRE__c();
                        
                        bre.LoanAppl__c=ids!=null?ids:'';
                        bre.EligibilityType__c='Applicant';
                        bre.Applicant__c=Applicantlist!=null?Applicantlist[0].id:'';
                        bre.IsLatest__c=true;
                        
                        /*Commentting Due to LAK-6471 
                        if (!String.isBlank(appvar.Decision)) {
                            bre.Decision__c= appvar.Decision;
                        }*/
                        
                        if (appvar.age!=null) {
                            bre.Age__c=decimal.valueOf(appvar.age);
                        }
                        
                        if (appvar.age_at_loan_maturity!=null) {
                            bre.Loan_Maturity_Age__c= decimal.valueOf(appvar.age_at_loan_maturity);
                        }
                        if (appvar.business_vintage!=null) {
                            bre.Business_Vintage__c= Decimal.valueOf(appvar.business_vintage);
                        }
                        if (appvar.dpd_l12m!=null) {
                            bre.DPD_l12_m__c= Decimal.valueOf(appvar.dpd_l12m);
                        }
                        if (appvar.dpd_gt30_last6months!=null) {
                            bre.DPDGT30Lst6__c= Decimal.valueof(appvar.dpd_gt30_last6months);
                        }
                        if (appvar.dpd_gt30_all_active!=null) {
                            bre.DPD_gt30_allActive__c= Decimal.valueOf(appvar.dpd_gt30_all_active);
                        }
                        if (appvar.ratio_current_disb_amt!=null) {
                            bre.RatioCurrentdisbamt__c= Decimal.valueOf(appvar.ratio_current_disb_amt);
                        }
                        if (appvar.oldest_tradeline_months!=null) {
                            bre.Oldtradelinemnth__c=  Decimal.valueOf(appvar.oldest_tradeline_months);
                        }
                        if (appvar.total_secured_bal!=null) {
                            bre.Total_secured_bal__c= Decimal.valueOf(appvar.total_secured_bal);
                        }
                        if (appvar.count_total_tradeline_last6month!=null) {
                            bre.TotTradelLst6Mnth__c= Decimal.valueOf(appvar.count_total_tradeline_last6month);
                        }
                        if (appvar.max_current_dpd_of_all_live_facilities!=null) {
                            bre.Maxcurrdpdlivefacilities__c= Decimal.valueOf(appvar.max_current_dpd_of_all_live_facilities);
                        }
                        if (appvar.max_dpd_in_last_12_months_of_all_live_facilities!=null) {
                            bre.MaxDPDlast12monthLive__c=  Decimal.valueOf(appvar.max_dpd_in_last_12_months_of_all_live_facilities);
                        }
                        if (appvar.max_recent_delq!=null) {
                            bre.MaxRecentDelq__c= Decimal.valueOf(appvar.max_recent_delq);
                        }
                        if (appvar.newest_tradeline_month!=null) {
                            bre.NewTradelinemnth__c= Decimal.valueOf(appvar.newest_tradeline_month);
                        }
                        if (appvar.ratio_of_outstanding_amt_to_disbursed_amt_for_pl!=null) {
                            bre.Ratio_outstanding_to_disbursed_am__c= Decimal.valueOf(appvar.ratio_of_outstanding_amt_to_disbursed_amt_for_pl);
                        }
                        if (appvar.recent_enquiry_days!=null) {
                            bre.Rcnt_EnqDys__c= Decimal.valueOf(appvar.recent_enquiry_days);
                        }
                        if (appvar.total_active_tradelines_in_last_12_months!=null) {
                            bre.Total_active_tradelines_in_last_12_month__c= Decimal.valueOf(appvar.total_active_tradelines_in_last_12_months);
                        }
                        if (appvar.total_credit_card_outstanding!=null) {
                            bre.totalcrd_card_outstanding__c= Decimal.valueOf(appvar.total_credit_card_outstanding);
                        }
                        if (appvar.total_gl_no!=null) {
                            bre.Total_GL_No__c= Decimal.valueOf(appvar.total_gl_no);
                        }
                        if (appvar.total_live_bl_pl_loan_exposure!=null) {
                            bre.Total_Live_PL_loan_exposure__c= Decimal.valueOf(appvar.total_live_bl_pl_loan_exposure);
                        }
                        if (appvar.total_live_credit_card_overdue!=null) {
                            bre.Total_live_credit_card_overdue__c= Decimal.valueOf(appvar.total_live_credit_card_overdue);
                        }
                        if (appvar.total_live_loan_exposure!=null) {
                            bre.Total_Live_Loan_Exposure__c= Decimal.valueOf(appvar.total_live_loan_exposure);
                        }
                        if (appvar.total_live_loan_overdue!=null) {
                            bre.Total_Live_Loan_Overdue__c= Decimal.valueOf(appvar.total_live_loan_overdue);
                        }
                        if (appvar.total_live_mortgage_loan_exposure!=null) {
                            bre.Total_live_mortgage_loan_exposure__c= Decimal.valueOf(appvar.total_live_mortgage_loan_exposure);
                        }
                        if (appvar.total_live_secured_loan_exposure!=null) {
                            bre.Total_live_secured_loan_exposure__c= Decimal.valueOf(appvar.total_live_secured_loan_exposure);
                        }
                        if (appvar.total_mortgage_enquiries_in_last_30_days!=null) {
                            bre.Total_mortgage_enquiries_in_last_30_days__c=  Decimal.valueOf(appvar.total_mortgage_enquiries_in_last_30_days);
                        }
                        if (appvar.total_no_of_live_loans!=null) {
                            bre.Total_no_of_live_loans__c= Decimal.valueOf(appvar.total_no_of_live_loans);
                        }
                        if (appvar.total_pl_no!=null) {
                            bre.Total_PL_No__c=  Decimal.valueOf(appvar.total_pl_no);
                        }
                        if (appvar.total_unsecured_bal!=null) {
                            bre.Total_unsecured_bal__c= Decimal.valueOf(appvar.total_unsecured_bal);
                        }
                        if (appvar.total_unsecured_bl_pl_enquiries_in_last_30_days!=null) {
                            bre.Total_unsecured_BL_PL_enq_in_last_30_day__c= Decimal.valueOf(appvar.total_unsecured_bl_pl_enquiries_in_last_30_days);
                        }
                        if (appvar.dpd_gt30_active_notin_gl_fl_cd_cc_50k!=null) {
                            bre.DPD_GT_30_Act_Ntg_50k__c= Decimal.valueOf(appvar.dpd_gt30_active_notin_gl_fl_cd_cc_50k);
                        }
                        if (appvar.dpd_gt90_l6m!=null) {
                            bre.DPD_GT_90_l6_m__c= Decimal.valueOf(appvar.dpd_gt90_l6m);
                        }
                        if (appvar.dpd_l12m_gl_fl_cd_cc_50k!=null) {
                            bre.DPD_l_12m_gl_fl_cd_cc_50k__c=  Decimal.valueOf(appvar.dpd_l12m_gl_fl_cd_cc_50k);
                        }
                        if (appvar.dpd_l12m_notin_gl_fl_cd_cc_50k!=null) {
                            bre.DPD_l12m_notingl_fl_cd_cc_50k__c= Decimal.valueOf(appvar.dpd_l12m_notin_gl_fl_cd_cc_50k);
                        }
                        if (appvar.dpd_lt30_l6m!=null) {
                            bre.DPD_lt30_l6m__c= Decimal.valueOf(appvar.dpd_lt30_l6m);
                        }
                        if (appvar.dpd_lt90_l6m!=null) {
                            bre.DPD_lt90_l6m__c= Decimal.valueOf(appvar.dpd_lt90_l6m);
                        }
                        if (appvar.dpd60_no_36m!=null) {
                            bre.DPD60No36M__c=Decimal.valueOf(appvar.dpd60_no_36m);
                        }
                        if (appvar.dpd_lt30_l12m!=null) {
                            bre.DPD_lt30_l12m__c=  Decimal.valueOf(appvar.dpd_lt30_l12m);
                        }
                        if (appvar.max_cash_salary!=null) {
                            bre.MaxCshSal__c=  Decimal.valueOf(appvar.max_cash_salary);
                        }
                        if (appvar.monthly_appraised_income!=null) {
                            bre.Mnthlyapprincome__c=  Decimal.valueOf(appvar.monthly_appraised_income);
                        }
                        if (appvar.monthly_other_income!=null) {
                            bre.MntlyOtrIncome__c=  Decimal.valueOf(appvar.monthly_other_income);
                        }
                        if (!string.isBlank(appvar.income_matrix_output)) {
                            bre.IncomeMtx__c= appvar.income_matrix_output;
                        }
                        if (appvar.dpd_gt30_all!=null) {
                            bre.DPDGT30all__c=Decimal.valueOf(appvar.dpd_gt30_all);
                        }
                        if (appvar.Total_Outstanding_BL!=null) {
                            bre.Total_Outstanding_BL__c= Decimal.valueOf(appvar.Total_Outstanding_BL);
                        }
                        if (appvar.dpd_lt30_l6m_all_acct!=null) {
                            bre.DPD_lt30_l6m_all_acct__c=  Decimal.valueOf(appvar.dpd_lt30_l6m_all_acct);
                        }
                        if (appvar.dpd_gt90_l6m_all_acct!=null) {
                            bre.DPD_gt90_l6m_all_acct__c=  Decimal.valueOf(appvar.dpd_gt90_l6m_all_acct);
                        }
                        if (appvar.monthly_core_income!=null) {
                            bre.Monthly_Core_Income__c= Decimal.valueOf( appvar.monthly_core_income);
                        }
                        if (appvar.Max_EMI_other_than_cash_salary!=null) {
                            bre.Max_EMI_Other_than_Cash_Salary__c= appvar.Max_EMI_other_than_cash_salary;
                        }
                        if (appvar.Max_EMI_cash_salary!=null) {
                            bre.Max_EMI_Cash_Salary__c=appvar.Max_EMI_cash_salary;
                        }
                        if (appvar.Other_Deducation_considered!=null) {
                            bre.OthrDedConsid__c= Decimal.valueOf(appvar.Other_Deducation_considered);
                        }
                        if (appvar.Performance_Bonus_considered!=null) {
                            bre.Performance_Bonus__c= Decimal.valueOf(appvar.Performance_Bonus_considered);
                        }
                        if (appvar.Annual_Benefits_like_LTA_considered!=null) {
                            bre.AnnualBenLike_LTA_Consider__c= Decimal.valueOf(appvar.Annual_Benefits_like_LTA_considered);
                        }
                        if (appvar.Variable_Component_considered!=null) {
                            bre.VarCom__c= Decimal.valueOf(appvar.Variable_Component_considered);
                        }
                        if (appvar.Gross_salary_considered!=null) {
                            bre.GrossSal__c= Decimal.valueOf(appvar.Gross_salary_considered);
                        }
                        if (appvar.Tax_considered!=null) {
                            bre.TaxConside__c=  Decimal.valueOf(appvar.Tax_considered);
                        }
                        if (appvar.Interest_on_Loan_considered!=null) {
                            bre.Interest_on_Loan__c= Decimal.valueOf(appvar.Interest_on_Loan_considered);
                        }
                        if (appvar.Interest_on_Partners_Capital_Renum_Inc_considered!=null) {
                            bre.InterestPartnersCap__c=  Decimal.valueOf(appvar.Interest_on_Partners_Capital_Renum_Inc_considered);
                        }
                        if (appvar.Depreciation_considered!=null) {
                            bre.DepreciationCons__c= Decimal.valueOf(appvar.Depreciation_considered);
                        }
                        if (appvar.Profit_Before_Tax_considered!=null) {
                            bre.ProfiteBfrTax_Cons__c=  Decimal.valueOf(appvar.Profit_Before_Tax_considered);
                        }
                        if (appvar.Net_Eligible_Salary_with_Bank_Credit!=null) {
                            bre.NetEligible_SlryBnkCredit__c=  Decimal.valueOf(appvar.Net_Eligible_Salary_with_Bank_Credit);
                        }
                        if (appvar.Gross_Eligible_Salary_with_Bank_Credit!=null) {
                            bre.GrossEligibleSal__c=  Decimal.valueOf(appvar.Gross_Eligible_Salary_with_Bank_Credit);
                        }
                        if (appvar.Considered_perc_other_deductions!=null) {
                            bre.Consideredpercothrded__c= Decimal.valueOf(appvar.Considered_perc_other_deductions);
                        }
                        if (appvar.Considered_perc_Performance_Bonus!=null) {
                            bre.Considered_perc_Performance_Bonus__c= Decimal.valueOf(appvar.Considered_perc_Performance_Bonus);
                        }
                        if (appvar.Considered_perc_annual_benefits!=null) {
                            bre.Considered_perc_annual_benefits__c= Decimal.valueOf(appvar.Considered_perc_annual_benefits);
                        }
                        if (appvar.Considered_perc_variable_component!=null) {
                            bre.Considered_perc_varcomp__c= Decimal.valueOf(appvar.Considered_perc_variable_component);
                        }
                        if (appvar.Considered_perc_Gross_Salary!=null) {
                            bre.Considered_perc_GrossSal__c= Decimal.valueOf(appvar.Considered_perc_Gross_Salary);
                        }
                        if (appvar.Monthly_Business_Income_Regular_Income_Program!=null) {
                            bre.MnthlyBusIncome_Regular_Income__c= Decimal.valueOf(appvar.Monthly_Business_Income_Regular_Income_Program);
                        }
                        if (appvar.Annual_Business_Income_Regular_Income_Program!=null) {
                            bre.Annual_Business_Income_RegIncome__c= Decimal.valueOf(appvar.Annual_Business_Income_Regular_Income_Program);
                        }
                        if (appvar.Considered_perc_tax!=null) {
                            bre.Consperctax__c= Decimal.valueOf(appvar.Considered_perc_tax);
                        }
                        if (appvar.Applicable_EMI_Net_to_Salary!=null) {
                            bre.AppEMI_NetSal__c= Decimal.valueOf(appvar.Applicable_EMI_Net_to_Salary);
                        }
                        if (appvar.Applicable_FOIR_cash_salary!=null) {
                            bre.Applicable_FOIR_Cash_Salary__c= Decimal.valueOf(appvar.Applicable_FOIR_cash_salary);
                        }
                        if (appvar.Applicable_FOIR!=null) {
                            bre.AppFOIR__c= Decimal.valueOf(appvar.Applicable_FOIR);
                        }
                        if (appvar.Considered_perc_Interest_on_Loan!=null) {
                            bre.Considered_perc_IntLoan__c= Decimal.valueOf(appvar.Considered_perc_Interest_on_Loan);
                        }
                        if (appvar.Considered_perc_Interest_on_Partners_Capital_Renum_Inc!=null) {
                            bre.Considered_perc_Interest_on_Partners_Cap__c= Decimal.valueOf(appvar.Considered_perc_Interest_on_Partners_Capital_Renum_Inc);
                        }
                        if (appvar.Considered_perc_Depreciation!=null) {
                            bre.Considered_perc_Depreciation__c= Decimal.valueOf(appvar.Considered_perc_Depreciation);
                        }
                        if (appvar.Considered_perc_Profit_Before_Tax!=null) {
                            bre.Considered_perc_Profit_Before_Tax__c= Decimal.valueOf(appvar.Considered_perc_Profit_Before_Tax);
                        }
                        
                        //LAK-6157 Changes
                        if (appvar.pct_currentBal_all_TL!=null) {
                            bre.PctcurrentBalallTL__c=appvar.pct_currentBal_all_TL;
                        }
                        
                        if (appvar.Other_Deduction_considered!=null) {
                            bre.OtherDeductionconsidered__c=appvar.Other_Deduction_considered;
                        }
                        
                        if (appvar.num_times_60p_dpd!=null) {
                            bre.Numtimes60pdpd__c=appvar.num_times_60p_dpd;
                        }
                        
                        if (appvar.max_recent_level_of_deliq!=null) {
                            bre.Maxrecentleveldeliq__c=appvar.max_recent_level_of_deliq;
                        }
                        
                        if (appvar.Gold_TL!=null) {
                            bre.GoldTL__c=appvar.Gold_TL;
                        }
                        
                        if (appvar.cust_current_outstanding!=null) {
                            bre.Custcurrentoutstanding__c=appvar.cust_current_outstanding;
                        }
                        
                        if (appvar.Considered_perc_Profit_After_Tax!=null) {
                            bre.ConspercPrftAftrTax__c=appvar.Considered_perc_Profit_After_Tax;
                        }
                        
                        if (appvar.Considered_perc_LIC_Agent_Commisssion_Renewal_Bonus!=null) {
                            bre.ConspercLICAgentCommRenwelbonus__c=appvar.Considered_perc_LIC_Agent_Commisssion_Renewal_Bonus;
                        }
                        
                        if (appvar.Considered_perc_LIC_Agent_Commisssion_NewBusiness_Bonus!=null) {
                            bre.ConspercLICAgtComNewBusinessBonus__c=appvar.Considered_perc_LIC_Agent_Commisssion_NewBusiness_Bonus;
                        }
                        
                        if (appvar.Age_Oldest_TL_Mnths!=null) {
                            bre.AgeOldestTLMnths__c=appvar.Age_Oldest_TL_Mnths;
                        }
                        
                        if (appvar.Age_Newest_TL_Mnths!=null) {
                            bre.AgeNewestTLMnths__c=appvar.Age_Newest_TL_Mnths;
                        }
                        
                        if (appvar.Tot_Unsecured_Bal!=null) {
                            bre.TotUnsecuredBal__c=appvar.Tot_Unsecured_Bal;
                        }
                        
                        if (appvar.Tot_Secured_Bal!=null) {
                            bre.TotSecuredBal__c=appvar.Tot_Secured_Bal;
                        }
                        
                        if (appvar.Tot_Other_Bal!=null) {
                            bre.TotOtherBal__c=appvar.Tot_Other_Bal;
                        }
                        
                        if (appvar.Tot_Active_TL_L12M!=null) {
                            bre.TotActiveTLL12M__c=appvar.Tot_Active_TL_L12M;
                        }
                        
                        if (appvar.time_since_recent_enq!=null) {
                            bre.Timesincerecentenq__c=appvar.time_since_recent_enq;
                        }
                        
                        if (appvar.Time_Since_Last_Payment_inMnths!=null) {
                            bre.TimeLastPaymentMnths__c=appvar.Time_Since_Last_Payment_inMnths;
                        }
                        
                        if (appvar.RF_Prob!=null) {
                            bre.RFProb__c=appvar.RF_Prob;
                        }
                        
                        if (appvar.Profit_After_Tax_considered!=null) {
                            bre.PrfAftrTaxConsidered__c=appvar.Profit_After_Tax_considered;
                        }
                        
                        if (appvar.PL_TL!=null) {
                            bre.PLTL__c=appvar.PL_TL;
                        }
                        
                        if (appvar.PL_cuurbal_highcredit!=null) {
                            bre.PLcuurbalhighcredit__c=appvar.PL_cuurbal_highcredit;
                        }
                        
                        if (String.isNotBlank(appvar.type_of_account_value)) {
                            bre.Typeofaccval__c=appvar.type_of_account_value;
                        }
                        
                        if (appvar.Total_TL_Open_L6M!=null) {
                            bre.TotalTLOpenL6M__c=appvar.Total_TL_Open_L6M;
                        }
                        
                        //LAK-6471 Start
                        if(String.isNotblank(appvar.Deviation_Decision)){
                            bre.DeviationDecision__c=appvar.Deviation_Decision;
                        }
                        
                        if (appvar.Total_currBal_openTLs!=null) {
                            bre.TotalCurrBalOpenTLs__c=appvar.Total_currBal_openTLs;
                        }
                        
                        if (appvar.Unsec_utilization!=null) {
                            bre.UnsecUtilization__c=appvar.Unsec_utilization;
                        }
                        
                        if (appvar.total_num_TLs_Active_and_opened_inLast_6_months!=null) {
                            bre.TotalNumTlsActiveOpenLst6Mnt__c=appvar.total_num_TLs_Active_and_opened_inLast_6_months;
                         }
                        
                        if (appvar.tot_enq_InLast_3months!=null) {
                            bre.TotalEnqLast3Months__c=appvar.tot_enq_InLast_3months;
                        }
                        
                        if (appvar.max_delinquency_level!=null) {
                            bre.Maxdelilvlmax__c=appvar.max_delinquency_level;
                         }
                        
                        if (appvar.Total_limit_openTLs!=null) {
                            bre.TotalLimitOpenTLs__c=appvar.Total_limit_openTLs;
                         }
                        
                        if (appvar.pct_tot_deliq_TLs!=null) {
                            bre.PctTotDeliqTLs__c=appvar.pct_tot_deliq_TLs;
                        }
                        
                        if (appvar.total_PL_open_TLs!=null) {
                            bre.TotalPLOpenTLs__c=appvar.total_PL_open_TLs;
                        }
                        
                        if (appvar.AL_cuurbal_highcredit!=null) {
                            bre.ALCurrBalHighCredit__c=appvar.AL_cuurbal_highcredit;
                        }
                        
                        if (appvar.ratio_unsecCurrBal_SecCurrBal_openTLs!=null) {
                            bre.RatioUnsecCurrBalSecCurrBalOpenTLs__c=appvar.ratio_unsecCurrBal_SecCurrBal_openTLs;
                         }
                        
                        if (appvar.pct_of_active_TLs!=null) {
                            bre.PctOfActiveTLs__c=appvar.pct_of_active_TLs;
                        }
                        //LAK-6471 End
                        brelist.add(bre);
                        
                        
                    }
                    
                    //COAPPLICANT Variables
                    if (category.COAPPLICANT!=null) {
                        
                        CrifExecuteAPIResponseWrapper.co_applicantvariabels coappvar =category.COAPPLICANT.Variables;
                        
                        BRE__c bre =new BRE__c();
                        
                        bre.LoanAppl__c=ids!=null?ids:'';
                        bre.EligibilityType__c='Applicant';
                        bre.IsLatest__c=true;
                        
                        if (coappvar.unique_id!=null) {
                            bre.Applicant__c=coappvar.unique_id;
                        }
                        
                        /*Commentting Due to LAK-6471 
                        if (!String.isBlank(coappvar.Decision)) {
                            bre.Decision__c= coappvar.Decision;
                        }*/
                        
                        if (coappvar.age!=null) {
                            bre.Age__c=decimal.valueOf(coappvar.age);
                        }
                        
                        if (coappvar.age_at_loan_maturity!=null) {
                            bre.Loan_Maturity_Age__c= decimal.valueOf(coappvar.age_at_loan_maturity);
                        }
                        if (coappvar.business_vintage!=null) {
                            bre.Business_Vintage__c= Decimal.valueOf(coappvar.business_vintage);
                        }
                        if (coappvar.dpd_l12m!=null) {
                            bre.DPD_l12_m__c= Decimal.valueOf(coappvar.dpd_l12m);
                        }
                        if (coappvar.dpd_gt30_last6months!=null) {
                            bre.DPDGT30Lst6__c= Decimal.valueof(coappvar.dpd_gt30_last6months);
                        }
                        if (coappvar.dpd_gt30_all_active!=null) {
                            bre.DPD_gt30_allActive__c= Decimal.valueOf(coappvar.dpd_gt30_all_active);
                        }
                        if (coappvar.ratio_current_disb_amt!=null) {
                            bre.RatioCurrentdisbamt__c= Decimal.valueOf(coappvar.ratio_current_disb_amt);
                        }
                        if (coappvar.oldest_tradeline_months!=null) {
                            bre.Oldtradelinemnth__c=  Decimal.valueOf(coappvar.oldest_tradeline_months);
                        }
                        if (coappvar.total_secured_bal!=null) {
                            bre.Total_secured_bal__c= Decimal.valueOf(coappvar.total_secured_bal);
                        }
                        if (coappvar.count_total_tradeline_last6month!=null) {
                            bre.TotTradelLst6Mnth__c= Decimal.valueOf(coappvar.count_total_tradeline_last6month);
                        }
                        if (coappvar.max_current_dpd_of_all_live_facilities!=null) {
                            bre.Maxcurrdpdlivefacilities__c= Decimal.valueOf(coappvar.max_current_dpd_of_all_live_facilities);
                        }
                        if (coappvar.max_dpd_in_last_12_months_of_all_live_facilities!=null) {
                            bre.MaxDPDlast12monthLive__c=  Decimal.valueOf(coappvar.max_dpd_in_last_12_months_of_all_live_facilities);
                        }
                        if (coappvar.max_recent_delq!=null) {
                            bre.MaxRecentDelq__c= Decimal.valueOf(coappvar.max_recent_delq);
                        }
                        if (coappvar.newest_tradeline_month!=null) {
                            bre.NewTradelinemnth__c= Decimal.valueOf(coappvar.newest_tradeline_month);
                        }
                        if (coappvar.ratio_of_outstanding_amt_to_disbursed_amt_for_pl!=null) {
                            bre.Ratio_outstanding_to_disbursed_am__c= Decimal.valueOf(coappvar.ratio_of_outstanding_amt_to_disbursed_amt_for_pl);
                        }
                        if (coappvar.recent_enquiry_days!=null) {
                            bre.Rcnt_EnqDys__c= Decimal.valueOf(coappvar.recent_enquiry_days);
                        }
                        if (coappvar.total_active_tradelines_in_last_12_months!=null) {
                            bre.Total_active_tradelines_in_last_12_month__c= Decimal.valueOf(coappvar.total_active_tradelines_in_last_12_months);
                        }
                        if (coappvar.total_credit_card_outstanding!=null) {
                            bre.totalcrd_card_outstanding__c= Decimal.valueOf(coappvar.total_credit_card_outstanding);
                        }
                        if (coappvar.total_gl_no!=null) {
                            bre.Total_GL_No__c= Decimal.valueOf(coappvar.total_gl_no);
                        }
                        if (coappvar.total_live_bl_pl_loan_exposure!=null) {
                            bre.Total_Live_PL_loan_exposure__c= Decimal.valueOf(coappvar.total_live_bl_pl_loan_exposure);
                        }
                        if (coappvar.total_live_credit_card_overdue!=null) {
                            bre.Total_live_credit_card_overdue__c= Decimal.valueOf(coappvar.total_live_credit_card_overdue);
                        }
                        if (coappvar.total_live_loan_exposure!=null) {
                            bre.Total_Live_Loan_Exposure__c= Decimal.valueOf(coappvar.total_live_loan_exposure);
                        }
                        if (coappvar.total_live_loan_overdue!=null) {
                            bre.Total_Live_Loan_Overdue__c= Decimal.valueOf(coappvar.total_live_loan_overdue);
                        }
                        if (coappvar.total_live_mortgage_loan_exposure!=null) {
                            bre.Total_live_mortgage_loan_exposure__c= Decimal.valueOf(coappvar.total_live_mortgage_loan_exposure);
                        }
                        if (coappvar.total_live_secured_loan_exposure!=null) {
                            bre.Total_live_secured_loan_exposure__c= Decimal.valueOf(coappvar.total_live_secured_loan_exposure);
                        }
                        if (coappvar.total_mortgage_enquiries_in_last_30_days!=null) {
                            bre.Total_mortgage_enquiries_in_last_30_days__c=  Decimal.valueOf(coappvar.total_mortgage_enquiries_in_last_30_days);
                        }
                        if (coappvar.total_no_of_live_loans!=null) {
                            bre.Total_no_of_live_loans__c= Decimal.valueOf(coappvar.total_no_of_live_loans);
                        }
                        if (coappvar.total_pl_no!=null) {
                            bre.Total_PL_No__c=  Decimal.valueOf(coappvar.total_pl_no);
                        }
                        if (coappvar.total_unsecured_bal!=null) {
                            bre.Total_unsecured_bal__c= Decimal.valueOf(coappvar.total_unsecured_bal);
                        }
                        if (coappvar.total_unsecured_bl_pl_enquiries_in_last_30_days!=null) {
                            bre.Total_unsecured_BL_PL_enq_in_last_30_day__c= Decimal.valueOf(coappvar.total_unsecured_bl_pl_enquiries_in_last_30_days);
                        }
                        if (coappvar.dpd_gt30_active_notin_gl_fl_cd_cc_50k!=null) {
                            bre.DPD_GT_30_Act_Ntg_50k__c= Decimal.valueOf(coappvar.dpd_gt30_active_notin_gl_fl_cd_cc_50k);
                        }
                        if (coappvar.dpd_gt90_l6m!=null) {
                            bre.DPD_GT_90_l6_m__c= Decimal.valueOf(coappvar.dpd_gt90_l6m);
                        }
                        if (coappvar.dpd_l12m_gl_fl_cd_cc_50k!=null) {
                            bre.DPD_l_12m_gl_fl_cd_cc_50k__c=  Decimal.valueOf(coappvar.dpd_l12m_gl_fl_cd_cc_50k);
                        }
                        if (coappvar.dpd_l12m_notin_gl_fl_cd_cc_50k!=null) {
                            bre.DPD_l12m_notingl_fl_cd_cc_50k__c= Decimal.valueOf(coappvar.dpd_l12m_notin_gl_fl_cd_cc_50k);
                        }
                        if (coappvar.dpd_lt30_l6m!=null) {
                            bre.DPD_lt30_l6m__c= Decimal.valueOf(coappvar.dpd_lt30_l6m);
                        }
                        if (coappvar.dpd_lt90_l6m!=null) {
                            bre.DPD_lt90_l6m__c= Decimal.valueOf(coappvar.dpd_lt90_l6m);
                        }
                        if (coappvar.dpd60_no_36m!=null) {
                            bre.DPD60No36M__c=Decimal.valueOf(coappvar.dpd60_no_36m);
                        }
                        if (coappvar.dpd_lt30_l12m!=null) {
                            bre.DPD_lt30_l12m__c=  Decimal.valueOf(coappvar.dpd_lt30_l12m);
                        }
                        if (coappvar.max_cash_salary!=null) {
                            bre.MaxCshSal__c=  Decimal.valueOf(coappvar.max_cash_salary);
                        }
                        if (coappvar.monthly_appraised_income!=null) {
                            bre.Mnthlyapprincome__c=  Decimal.valueOf(coappvar.monthly_appraised_income);
                        }
                        if (coappvar.monthly_other_income!=null) {
                            bre.MntlyOtrIncome__c=  Decimal.valueOf(coappvar.monthly_other_income);
                        }
                        
                        if (coappvar.dpd_gt30_all!=null) {
                            bre.DPDGT30all__c=Decimal.valueOf(coappvar.dpd_gt30_all);
                        }
                        if (coappvar.Total_Outstanding_BL!=null) {
                            bre.Total_Outstanding_BL__c= Decimal.valueOf(coappvar.Total_Outstanding_BL);
                        }
                        if (coappvar.dpd_lt30_l6m_all_acct!=null) {
                            bre.DPD_lt30_l6m_all_acct__c=  Decimal.valueOf(coappvar.dpd_lt30_l6m_all_acct);
                        }
                        if (coappvar.dpd_gt90_l6m_all_acct!=null) {
                            bre.DPD_gt90_l6m_all_acct__c=  Decimal.valueOf(coappvar.dpd_gt90_l6m_all_acct);
                        }
                        if (coappvar.monthly_core_income!=null) {
                            bre.Monthly_Core_Income__c= Decimal.valueOf( coappvar.monthly_core_income);
                        }
                        if (coappvar.Max_EMI_other_than_cash_salary!=null) {
                            bre.Max_EMI_Other_than_Cash_Salary__c= coappvar.Max_EMI_other_than_cash_salary;
                        }
                        if (coappvar.Max_EMI_cash_salary!=null) {
                            bre.Max_EMI_Cash_Salary__c=coappvar.Max_EMI_cash_salary;
                        }
                        if (coappvar.Other_Deducation_considered!=null) {
                            bre.OthrDedConsid__c= Decimal.valueOf(coappvar.Other_Deducation_considered);
                        }
                        if (coappvar.Performance_Bonus_considered!=null) {
                            bre.Performance_Bonus__c= Decimal.valueOf(coappvar.Performance_Bonus_considered);
                        }
                        if (coappvar.Annual_Benefits_like_LTA_considered!=null) {
                            bre.AnnualBenLike_LTA_Consider__c= Decimal.valueOf(coappvar.Annual_Benefits_like_LTA_considered);
                        }
                        if (coappvar.Variable_Component_considered!=null) {
                            bre.VarCom__c= Decimal.valueOf(coappvar.Variable_Component_considered);
                        }
                        if (coappvar.Gross_salary_considered!=null) {
                            bre.GrossSal__c= Decimal.valueOf(coappvar.Gross_salary_considered);
                        }
                        if (coappvar.Tax_considered!=null) {
                            bre.TaxConside__c=  Decimal.valueOf(coappvar.Tax_considered);
                        }
                        if (coappvar.Interest_on_Loan_considered!=null) {
                            bre.Interest_on_Loan__c= Decimal.valueOf(coappvar.Interest_on_Loan_considered);
                        }
                        if (coappvar.Interest_on_Partners_Capital_Renum_Inc_considered!=null) {
                            bre.InterestPartnersCap__c=  Decimal.valueOf(coappvar.Interest_on_Partners_Capital_Renum_Inc_considered);
                        }
                        if (coappvar.Depreciation_considered!=null) {
                            bre.DepreciationCons__c= Decimal.valueOf(coappvar.Depreciation_considered);
                        }
                        if (coappvar.Profit_Before_Tax_considered!=null) {
                            bre.ProfiteBfrTax_Cons__c=  Decimal.valueOf(coappvar.Profit_Before_Tax_considered);
                        }
                        if (coappvar.Net_Eligible_Salary_with_Bank_Credit!=null) {
                            bre.NetEligible_SlryBnkCredit__c=  Decimal.valueOf(coappvar.Net_Eligible_Salary_with_Bank_Credit);
                        }
                        if (coappvar.Gross_Eligible_Salary_with_Bank_Credit!=null) {
                            bre.GrossEligibleSal__c=  Decimal.valueOf(coappvar.Gross_Eligible_Salary_with_Bank_Credit);
                        }
                        if (coappvar.Considered_perc_other_deductions!=null) {
                            bre.Consideredpercothrded__c= Decimal.valueOf(coappvar.Considered_perc_other_deductions);
                        }
                        if (coappvar.Considered_perc_Performance_Bonus!=null) {
                            bre.Considered_perc_Performance_Bonus__c= Decimal.valueOf(coappvar.Considered_perc_Performance_Bonus);
                        }
                        if (coappvar.Considered_perc_annual_benefits!=null) {
                            bre.Considered_perc_annual_benefits__c= Decimal.valueOf(coappvar.Considered_perc_annual_benefits);
                        }
                        if (coappvar.Considered_perc_variable_component!=null) {
                            bre.Considered_perc_varcomp__c= Decimal.valueOf(coappvar.Considered_perc_variable_component);
                        }
                        if (coappvar.Considered_perc_Gross_Salary!=null) {
                            bre.Considered_perc_GrossSal__c= Decimal.valueOf(coappvar.Considered_perc_Gross_Salary);
                        }
                        if (coappvar.Monthly_Business_Income_Regular_Income_Program!=null) {
                            bre.MnthlyBusIncome_Regular_Income__c= Decimal.valueOf(coappvar.Monthly_Business_Income_Regular_Income_Program);
                        }
                        if (coappvar.Annual_Business_Income_Regular_Income_Program!=null) {
                            bre.Annual_Business_Income_RegIncome__c= Decimal.valueOf(coappvar.Annual_Business_Income_Regular_Income_Program);
                        }
                        if (coappvar.Considered_perc_tax!=null) {
                            bre.Consperctax__c= Decimal.valueOf(coappvar.Considered_perc_tax);
                        }
                        if (coappvar.Applicable_EMI_Net_to_Salary!=null) {
                            bre.AppEMI_NetSal__c= Decimal.valueOf(coappvar.Applicable_EMI_Net_to_Salary);
                        }
                        if (coappvar.Applicable_FOIR_cash_salary!=null) {
                            bre.Applicable_FOIR_Cash_Salary__c= Decimal.valueOf(coappvar.Applicable_FOIR_cash_salary);
                        }
                        if (coappvar.Applicable_FOIR!=null) {
                            bre.AppFOIR__c= Decimal.valueOf(coappvar.Applicable_FOIR);
                        }
                        if (coappvar.Considered_perc_Interest_on_Loan!=null) {
                            bre.Considered_perc_IntLoan__c= Decimal.valueOf(coappvar.Considered_perc_Interest_on_Loan);
                        }
                        if (coappvar.Considered_perc_Interest_on_Partners_Capital_Renum_Inc!=null) {
                            bre.Considered_perc_Interest_on_Partners_Cap__c= Decimal.valueOf(coappvar.Considered_perc_Interest_on_Partners_Capital_Renum_Inc);
                        }
                        if (coappvar.Considered_perc_Depreciation!=null) {
                            bre.Considered_perc_Depreciation__c= Decimal.valueOf(coappvar.Considered_perc_Depreciation);
                        }
                        if (coappvar.Considered_perc_Profit_Before_Tax!=null) {
                            bre.Considered_perc_Profit_Before_Tax__c= Decimal.valueOf(coappvar.Considered_perc_Profit_Before_Tax);
                        }
                        
                        //LAK-6157 Changes
                        if (coappvar.pct_currentBal_all_TL!=null) {
                            bre.PctcurrentBalallTL__c=coappvar.pct_currentBal_all_TL;
                        }
                        
                        if (coappvar.Other_Deduction_considered!=null) {
                            bre.OtherDeductionconsidered__c=coappvar.Other_Deduction_considered;
                        }
                        
                        if (coappvar.num_times_60p_dpd!=null) {
                            bre.Numtimes60pdpd__c=coappvar.num_times_60p_dpd;
                        }
                        
                        if (coappvar.max_recent_level_of_deliq!=null) {
                            bre.Maxrecentleveldeliq__c=coappvar.max_recent_level_of_deliq;
                        }
                        
                        if (coappvar.Gold_TL!=null) {
                            bre.GoldTL__c=coappvar.Gold_TL;
                        }
                        
                        if (coappvar.cust_current_outstanding!=null) {
                            bre.Custcurrentoutstanding__c=coappvar.cust_current_outstanding;
                        }
                        
                        if (coappvar.Considered_perc_Profit_After_Tax!=null) {
                            bre.ConspercPrftAftrTax__c=coappvar.Considered_perc_Profit_After_Tax;
                        }
                        
                        if (coappvar.Considered_perc_LIC_Agent_Commisssion_Renewal_Bonus!=null) {
                            bre.ConspercLICAgentCommRenwelbonus__c=coappvar.Considered_perc_LIC_Agent_Commisssion_Renewal_Bonus;
                        }
                        
                        if (coappvar.Considered_perc_LIC_Agent_Commisssion_NewBusiness_Bonus!=null) {
                            bre.ConspercLICAgtComNewBusinessBonus__c=coappvar.Considered_perc_LIC_Agent_Commisssion_NewBusiness_Bonus;
                        }
                        
                        if (coappvar.Age_Oldest_TL_Mnths!=null) {
                            bre.AgeOldestTLMnths__c=coappvar.Age_Oldest_TL_Mnths;
                        }
                        
                        if (coappvar.Age_Newest_TL_Mnths!=null) {
                            bre.AgeNewestTLMnths__c=coappvar.Age_Newest_TL_Mnths;
                        }
                        
                        if (coappvar.Tot_Unsecured_Bal!=null) {
                            bre.TotUnsecuredBal__c=coappvar.Tot_Unsecured_Bal;
                        }
                        
                        if (coappvar.Tot_Secured_Bal!=null) {
                            bre.TotSecuredBal__c=coappvar.Tot_Secured_Bal;
                        }
                        
                        if (coappvar.Tot_Other_Bal!=null) {
                            bre.TotOtherBal__c=coappvar.Tot_Other_Bal;
                        }
                        
                        if (coappvar.Tot_Active_TL_L12M!=null) {
                            bre.TotActiveTLL12M__c=coappvar.Tot_Active_TL_L12M;
                        }
                        
                        if (coappvar.time_since_recent_enq!=null) {
                            bre.Timesincerecentenq__c=coappvar.time_since_recent_enq;
                        }
                        
                        if (coappvar.Time_Since_Last_Payment_inMnths!=null) {
                            bre.TimeLastPaymentMnths__c=coappvar.Time_Since_Last_Payment_inMnths;
                        }
                        
                        if (coappvar.RF_Prob!=null) {
                            bre.RFProb__c=coappvar.RF_Prob;
                        }
                        
                        if (coappvar.Profit_After_Tax_considered!=null) {
                            bre.PrfAftrTaxConsidered__c=coappvar.Profit_After_Tax_considered;
                        }
                        
                        if (coappvar.PL_TL!=null) {
                            bre.PLTL__c=coappvar.PL_TL;
                        }
                        
                        if (coappvar.PL_cuurbal_highcredit!=null) {
                            bre.PLcuurbalhighcredit__c=coappvar.PL_cuurbal_highcredit;
                        }
                        
                        if (String.isNotBlank(coappvar.type_of_account_value)) {
                            bre.Typeofaccval__c=coappvar.type_of_account_value;
                        }
                        
                        if (coappvar.Total_TL_Open_L6M!=null) {
                            bre.TotalTLOpenL6M__c=coappvar.Total_TL_Open_L6M;
                        }
                        
                        //LAK-6471 Start
                        if(String.isNotblank(coappvar.Deviation_Decision)){
                            bre.DeviationDecision__c=coappvar.Deviation_Decision;
                        }
                        
                        if (coappvar.Total_currBal_openTLs!=null) {
                            bre.TotalCurrBalOpenTLs__c=coappvar.Total_currBal_openTLs;
                        }
                        
                        if (coappvar.Unsec_utilization!=null) {
                            bre.UnsecUtilization__c=coappvar.Unsec_utilization;
                        }
                        
                        if (coappvar.total_num_TLs_Active_and_opened_inLast_6_months!=null) {
                            bre.TotalNumTlsActiveOpenLst6Mnt__c=coappvar.total_num_TLs_Active_and_opened_inLast_6_months;
                         }
                        
                        if (coappvar.tot_enq_InLast_3months!=null) {
                            bre.TotalEnqLast3Months__c=coappvar.tot_enq_InLast_3months;
                        }
                        
                        if (coappvar.max_delinquency_level!=null) {
                            bre.Maxdelilvlmax__c=coappvar.max_delinquency_level;
                         }
                        
                        if (coappvar.Total_limit_openTLs!=null) {
                            bre.TotalLimitOpenTLs__c=coappvar.Total_limit_openTLs;
                         }
                        
                        if (coappvar.pct_tot_deliq_TLs!=null) {
                            bre.PctTotDeliqTLs__c=coappvar.pct_tot_deliq_TLs;
                        }
                        
                        if (coappvar.total_PL_open_TLs!=null) {
                            bre.TotalPLOpenTLs__c=coappvar.total_PL_open_TLs;
                        }
                        
                        if (coappvar.AL_cuurbal_highcredit!=null) {
                            bre.ALCurrBalHighCredit__c=coappvar.AL_cuurbal_highcredit;
                        }
                        
                        if (coappvar.ratio_unsecCurrBal_SecCurrBal_openTLs!=null) {
                            bre.RatioUnsecCurrBalSecCurrBalOpenTLs__c=coappvar.ratio_unsecCurrBal_SecCurrBal_openTLs;
                         }
                        
                        if (coappvar.pct_of_active_TLs!=null) {
                            bre.PctOfActiveTLs__c=coappvar.pct_of_active_TLs;
                        }
                        //LAK-6471 End
                        
                        brelist.add(bre);
                        
                    }
                    
                    //GUARANTOR Variables
                    if (category.GUARANTOR!=null) {
                        
                        CrifExecuteAPIResponseWrapper.guarantorvariabels guar =category.GUARANTOR.Variables;
                        
                        BRE__c bre =new BRE__c();
                        
                        bre.LoanAppl__c=ids!=null?ids:'';
                        bre.EligibilityType__c='Applicant';
                        bre.IsLatest__c=true;
                        
                        if (guar.unique_id!=null) {
                            bre.Applicant__c=guar.unique_id;
                        }
                        /*Commentting Due to LAK-6471 
                        if (!String.isBlank(guar.Decision)) {
                            bre.Decision__c= guar.Decision;
                        }*/
                        
                        if (guar.age!=null) {
                            bre.Age__c=decimal.valueOf(guar.age);
                        }
                        
                        if (guar.age_at_loan_maturity!=null) {
                            bre.Loan_Maturity_Age__c= decimal.valueOf(guar.age_at_loan_maturity);
                        }
                        if (guar.business_vintage!=null) {
                            bre.Business_Vintage__c= Decimal.valueOf(guar.business_vintage);
                        }
                        if (guar.dpd_l12m!=null) {
                            bre.DPD_l12_m__c= Decimal.valueOf(guar.dpd_l12m);
                        }
                        if (guar.dpd_gt30_last6months!=null) {
                            bre.DPDGT30Lst6__c= Decimal.valueof(guar.dpd_gt30_last6months);
                        }
                        if (guar.dpd_gt30_all_active!=null) {
                            bre.DPD_gt30_allActive__c= Decimal.valueOf(guar.dpd_gt30_all_active);
                        }
                        if (guar.ratio_current_disb_amt!=null) {
                            bre.RatioCurrentdisbamt__c= Decimal.valueOf(guar.ratio_current_disb_amt);
                        }
                        if (guar.oldest_tradeline_months!=null) {
                            bre.Oldtradelinemnth__c=  Decimal.valueOf(guar.oldest_tradeline_months);
                        }
                        if (guar.total_secured_bal!=null) {
                            bre.Total_secured_bal__c= Decimal.valueOf(guar.total_secured_bal);
                        }
                        if (guar.count_total_tradeline_last6month!=null) {
                            bre.TotTradelLst6Mnth__c= Decimal.valueOf(guar.count_total_tradeline_last6month);
                        }
                        if (guar.max_current_dpd_of_all_live_facilities!=null) {
                            bre.Maxcurrdpdlivefacilities__c= Decimal.valueOf(guar.max_current_dpd_of_all_live_facilities);
                        }
                        if (guar.max_dpd_in_last_12_months_of_all_live_facilities!=null) {
                            bre.MaxDPDlast12monthLive__c=  Decimal.valueOf(guar.max_dpd_in_last_12_months_of_all_live_facilities);
                        }
                        if (guar.max_recent_delq!=null) {
                            bre.MaxRecentDelq__c= Decimal.valueOf(guar.max_recent_delq);
                        }
                        if (guar.newest_tradeline_month!=null) {
                            bre.NewTradelinemnth__c= Decimal.valueOf(guar.newest_tradeline_month);
                        }
                        if (guar.ratio_of_outstanding_amt_to_disbursed_amt_for_pl!=null) {
                            bre.Ratio_outstanding_to_disbursed_am__c= Decimal.valueOf(guar.ratio_of_outstanding_amt_to_disbursed_amt_for_pl);
                        }
                        if (guar.recent_enquiry_days!=null) {
                            bre.Rcnt_EnqDys__c= Decimal.valueOf(guar.recent_enquiry_days);
                        }
                        if (guar.total_active_tradelines_in_last_12_months!=null) {
                            bre.Total_active_tradelines_in_last_12_month__c= Decimal.valueOf(guar.total_active_tradelines_in_last_12_months);
                        }
                        if (guar.total_credit_card_outstanding!=null) {
                            bre.totalcrd_card_outstanding__c= Decimal.valueOf(guar.total_credit_card_outstanding);
                        }
                        if (guar.total_gl_no!=null) {
                            bre.Total_GL_No__c= Decimal.valueOf(guar.total_gl_no);
                        }
                        if (guar.total_live_bl_pl_loan_exposure!=null) {
                            bre.Total_Live_PL_loan_exposure__c= Decimal.valueOf(guar.total_live_bl_pl_loan_exposure);
                        }
                        if (guar.total_live_credit_card_overdue!=null) {
                            bre.Total_live_credit_card_overdue__c= Decimal.valueOf(guar.total_live_credit_card_overdue);
                        }
                        if (guar.total_live_loan_exposure!=null) {
                            bre.Total_Live_Loan_Exposure__c= Decimal.valueOf(guar.total_live_loan_exposure);
                        }
                        if (guar.total_live_loan_overdue!=null) {
                            bre.Total_Live_Loan_Overdue__c= Decimal.valueOf(guar.total_live_loan_overdue);
                        }
                        if (guar.total_live_mortgage_loan_exposure!=null) {
                            bre.Total_live_mortgage_loan_exposure__c= Decimal.valueOf(guar.total_live_mortgage_loan_exposure);
                        }
                        if (guar.total_live_secured_loan_exposure!=null) {
                            bre.Total_live_secured_loan_exposure__c= Decimal.valueOf(guar.total_live_secured_loan_exposure);
                        }
                        if (guar.total_mortgage_enquiries_in_last_30_days!=null) {
                            bre.Total_mortgage_enquiries_in_last_30_days__c=  Decimal.valueOf(guar.total_mortgage_enquiries_in_last_30_days);
                        }
                        if (guar.total_no_of_live_loans!=null) {
                            bre.Total_no_of_live_loans__c= Decimal.valueOf(guar.total_no_of_live_loans);
                        }
                        if (guar.total_pl_no!=null) {
                            bre.Total_PL_No__c=  Decimal.valueOf(guar.total_pl_no);
                        }
                        if (guar.total_unsecured_bal!=null) {
                            bre.Total_unsecured_bal__c= Decimal.valueOf(guar.total_unsecured_bal);
                        }
                        if (guar.total_unsecured_bl_pl_enquiries_in_last_30_days!=null) {
                            bre.Total_unsecured_BL_PL_enq_in_last_30_day__c= Decimal.valueOf(guar.total_unsecured_bl_pl_enquiries_in_last_30_days);
                        }
                        if (guar.dpd_gt30_active_notin_gl_fl_cd_cc_50k!=null) {
                            bre.DPD_GT_30_Act_Ntg_50k__c= Decimal.valueOf(guar.dpd_gt30_active_notin_gl_fl_cd_cc_50k);
                        }
                        if (guar.dpd_gt90_l6m!=null) {
                            bre.DPD_GT_90_l6_m__c= Decimal.valueOf(guar.dpd_gt90_l6m);
                        }
                        if (guar.dpd_l12m_gl_fl_cd_cc_50k!=null) {
                            bre.DPD_l_12m_gl_fl_cd_cc_50k__c=  Decimal.valueOf(guar.dpd_l12m_gl_fl_cd_cc_50k);
                        }
                        if (guar.dpd_l12m_notin_gl_fl_cd_cc_50k!=null) {
                            bre.DPD_l12m_notingl_fl_cd_cc_50k__c= Decimal.valueOf(guar.dpd_l12m_notin_gl_fl_cd_cc_50k);
                        }
                        if (guar.dpd_lt30_l6m!=null) {
                            bre.DPD_lt30_l6m__c= Decimal.valueOf(guar.dpd_lt30_l6m);
                        }
                        if (guar.dpd_lt90_l6m!=null) {
                            bre.DPD_lt90_l6m__c= Decimal.valueOf(guar.dpd_lt90_l6m);
                        }
                        if (guar.dpd60_no_36m!=null) {
                            bre.DPD60No36M__c=Decimal.valueOf(guar.dpd60_no_36m);
                        }
                        if (guar.dpd_lt30_l12m!=null) {
                            bre.DPD_lt30_l12m__c=  Decimal.valueOf(guar.dpd_lt30_l12m);
                        }
                        if (guar.max_cash_salary!=null) {
                            bre.MaxCshSal__c=  Decimal.valueOf(guar.max_cash_salary);
                        }
                        if (guar.monthly_appraised_income!=null) {
                            bre.Mnthlyapprincome__c=  Decimal.valueOf(guar.monthly_appraised_income);
                        }
                        if (guar.monthly_other_income!=null) {
                            bre.MntlyOtrIncome__c=  Decimal.valueOf(guar.monthly_other_income);
                        }
                        
                        if (guar.dpd_gt30_all!=null) {
                            bre.DPDGT30all__c=Decimal.valueOf(guar.dpd_gt30_all);
                        }
                        if (guar.Total_Outstanding_BL!=null) {
                            bre.Total_Outstanding_BL__c= Decimal.valueOf(guar.Total_Outstanding_BL);
                        }
                        if (guar.dpd_lt30_l6m_all_acct!=null) {
                            bre.DPD_lt30_l6m_all_acct__c=  Decimal.valueOf(guar.dpd_lt30_l6m_all_acct);
                        }
                        if (guar.dpd_gt90_l6m_all_acct!=null) {
                            bre.DPD_gt90_l6m_all_acct__c=  Decimal.valueOf(guar.dpd_gt90_l6m_all_acct);
                        }
                        if (guar.monthly_core_income!=null) {
                            bre.Monthly_Core_Income__c= Decimal.valueOf( guar.monthly_core_income);
                        }
                        if (guar.Max_EMI_other_than_cash_salary!=null) {
                            bre.Max_EMI_Other_than_Cash_Salary__c= guar.Max_EMI_other_than_cash_salary;
                        }
                        if (guar.Max_EMI_cash_salary!=null) {
                            bre.Max_EMI_Cash_Salary__c=guar.Max_EMI_cash_salary;
                        }
                        
                        if (guar.Considered_perc_Interest_on_Loan!=null) {
                            bre.Considered_perc_IntLoan__c= Decimal.valueOf(guar.Considered_perc_Interest_on_Loan);
                        }
                        if (guar.Considered_perc_Interest_on_Partners_Capital_Renum_Inc!=null) {
                            bre.Considered_perc_Interest_on_Partners_Cap__c= Decimal.valueOf(guar.Considered_perc_Interest_on_Partners_Capital_Renum_Inc);
                        }
                        if (guar.Considered_perc_Depreciation!=null) {
                            bre.Considered_perc_Depreciation__c= Decimal.valueOf(guar.Considered_perc_Depreciation);
                        }
                        if (guar.Considered_perc_Profit_Before_Tax!=null) {
                            bre.Considered_perc_Profit_Before_Tax__c= Decimal.valueOf(guar.Considered_perc_Profit_Before_Tax);
                        }
                        //LAK-6157 Changes
                        if (guar.pct_currentBal_all_TL!=null) {
                            bre.PctcurrentBalallTL__c=guar.pct_currentBal_all_TL;
                        }
                        
                        if (guar.num_times_60p_dpd!=null) {
                            bre.Numtimes60pdpd__c=guar.num_times_60p_dpd;
                        }
                        
                        if (guar.max_recent_level_of_deliq!=null) {
                            bre.Maxrecentleveldeliq__c=guar.max_recent_level_of_deliq;
                        }
                        
                        if (guar.Gold_TL!=null) {
                            bre.GoldTL__c=guar.Gold_TL;
                        }
                        
                        if (guar.cust_current_outstanding!=null) {
                            bre.Custcurrentoutstanding__c=guar.cust_current_outstanding;
                        }
                        
                        if (guar.Age_Oldest_TL_Mnths!=null) {
                            bre.AgeOldestTLMnths__c=guar.Age_Oldest_TL_Mnths;
                        }
                        
                        if (guar.Age_Newest_TL_Mnths!=null) {
                            bre.AgeNewestTLMnths__c=guar.Age_Newest_TL_Mnths;
                        }
                        
                        if (guar.Tot_Unsecured_Bal!=null) {
                            bre.TotUnsecuredBal__c=guar.Tot_Unsecured_Bal;
                        }
                        
                        if (guar.Tot_Secured_Bal!=null) {
                            bre.TotSecuredBal__c=guar.Tot_Secured_Bal;
                        }
                        
                        if (guar.Tot_Other_Bal!=null) {
                            bre.TotOtherBal__c=guar.Tot_Other_Bal;
                        }
                        
                        if (guar.Tot_Active_TL_L12M!=null) {
                            bre.TotActiveTLL12M__c=guar.Tot_Active_TL_L12M;
                        }
                        
                        if (guar.time_since_recent_enq!=null) {
                            bre.Timesincerecentenq__c=guar.time_since_recent_enq;
                        }
                        
                        if (guar.Time_Since_Last_Payment_inMnths!=null) {
                            bre.TimeLastPaymentMnths__c=guar.Time_Since_Last_Payment_inMnths;
                        }
                        
                        if (guar.RF_Prob!=null) {
                            bre.RFProb__c=guar.RF_Prob;
                        }
                        
                        if (guar.PL_TL!=null) {
                            bre.PLTL__c=guar.PL_TL;
                        }
                        
                        if (guar.PL_cuurbal_highcredit!=null) {
                            bre.PLcuurbalhighcredit__c=guar.PL_cuurbal_highcredit;
                        }
                        
                        if (guar.Total_TL_Open_L6M!=null) {
                            bre.TotalTLOpenL6M__c=guar.Total_TL_Open_L6M;
                        }
                        //LAK-6471 Start
                        if(String.isNotblank(guar.Deviation_Decision)){
                            bre.DeviationDecision__c=guar.Deviation_Decision;
                        }
                        
                        if (guar.Total_currBal_openTLs!=null) {
                            bre.TotalCurrBalOpenTLs__c=guar.Total_currBal_openTLs;
                        }
                        
                        if (guar.Unsec_utilization!=null) {
                            bre.UnsecUtilization__c=guar.Unsec_utilization;
                        }
                        
                        if (guar.total_num_TLs_Active_and_opened_inLast_6_months!=null) {
                            bre.TotalNumTlsActiveOpenLst6Mnt__c=guar.total_num_TLs_Active_and_opened_inLast_6_months;
                         }
                        
                        if (guar.tot_enq_InLast_3months!=null) {
                            bre.TotalEnqLast3Months__c=guar.tot_enq_InLast_3months;
                        }
                        
                        if (guar.max_delinquency_level!=null) {
                            bre.Maxdelilvlmax__c=guar.max_delinquency_level;
                         }
                        
                        if (guar.Total_limit_openTLs!=null) {
                            bre.TotalLimitOpenTLs__c=guar.Total_limit_openTLs;
                         }
                        
                        if (guar.pct_tot_deliq_TLs!=null) {
                            bre.PctTotDeliqTLs__c=guar.pct_tot_deliq_TLs;
                        }
                        
                        if (guar.total_PL_open_TLs!=null) {
                            bre.TotalPLOpenTLs__c=guar.total_PL_open_TLs;
                        }
                        
                        if (guar.AL_cuurbal_highcredit!=null) {
                            bre.ALCurrBalHighCredit__c=guar.AL_cuurbal_highcredit;
                        }
                        
                        if (guar.ratio_unsecCurrBal_SecCurrBal_openTLs!=null) {
                            bre.RatioUnsecCurrBalSecCurrBalOpenTLs__c=guar.ratio_unsecCurrBal_SecCurrBal_openTLs;
                         }
                        
                        if (guar.pct_of_active_TLs!=null) {
                            bre.PctOfActiveTLs__c=guar.pct_of_active_TLs;
                        }
                        //LAK-6471 End
                        brelist.add(bre);
                        
                    }
                    
                }
                
                
                if(brelist!=null){
                    Insert brelist;
                  }
               
                
            } catch (Exception ex) {
                // system.debug('Error message and line number: ' + ex.getMessage() + ' Line: ' + ex.getLineNumber());
                GlobalUtility.logMessage('Error', 'CrifExecuteAPIResponseProcessor class', 
                                         'Applicantvalues', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            
        }
        
    }
    //**************************************************************************************************************************
    public static void BREeligibility(CrifExecuteAPIResponseWrapper res,Id ids){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { BRE_Eligibility__c.SObjectType});
        
        if (res !=null && ids !=null) {
            
            try {
                
                List<String> appids =new List<String>();
                
                //getting the Primairy Applicant
                List<Applicant__c> Applicantlist =[Select id,LoanAppln__c,ApplType__c from Applicant__c Where LoanAppln__c =:ids AND ApplType__c='P' LIMIT 1];
                
                //getting all the applicant id using unquieID response fileds
                for(CrifExecuteAPIResponseWrapper.Categories category : res.StrategyOneResponse.Body.APPLICATION.Categories){
                    
                    if(category.COAPPLICANT!=null){
                        
                        CrifExecuteAPIResponseWrapper.co_applicantvariabels coappvar =category.COAPPLICANT.Variables;
                        
                        if(!String.isBlank(coappvar.unique_id)){
                            appids.add(coappvar.unique_id);
                        }
                    }
                    
                    if(category.GUARANTOR!=null){
                        
                        CrifExecuteAPIResponseWrapper.guarantorvariabels guarantor =category.GUARANTOR.Variables;
                        
                        if(!String.isBlank(guarantor.unique_id)){
                            appids.add(guarantor.unique_id);
                        }
                    }
                    
                }
                appids.add(Applicantlist[0].id);
                
                //Checking the old Record Making Them as False based on Loan Application
                if(ids!=null){
                    List<BRE_Eligibility__c> breEligibilitylist=[Select id,Applicant__c,LoanApp__c,IsLatest__c from BRE_Eligibility__c Where LoanApp__c=:ids AND IsLatest__c =true];
                    
                    if(!breEligibilitylist.isempty()){
                        
                        IsLatestFalse(breEligibilitylist,'IsLatest__c');
                    }
                    
                    
                }
                // //Checking old Record for the Applicant
                // if(appids!=null){
                
                //     List<BRE_Eligibility__c> breEligibilitylist=[Select id,Applicant__c,LoanApp__c,IsLatest__c from BRE_Eligibility__c Where Applicant__c IN:appids AND LoanApp__c=:ids AND IsLatest__c =true];
                
                //     IsLatestFalse(breEligibilitylist,'IsLatest__c');
                // }
                //getting BRE id which are linked with co-applicant and Graunter
                Map<Id, BRE__c> bremap = new Map<Id, BRE__c>();
                for(BRE__c brelist:[Select Id,Applicant__c,LoanAppl__c from BRE__c Where Applicant__c IN:appids AND LoanAppl__c=:ids AND IsLatest__c=true]){
                    bremap.put(brelist.Applicant__c,brelist);
                }
                
                //getting BRE id which are linked with Application
                List<BRE__c> bre =[Select id,LoanAppl__c,Applicant__c from BRE__c Where Applicant__c='' AND LoanAppl__c=:ids AND IsLatest__c=true];
                
                //getting BRE id which are linked with Applicant
                List<BRE__c> breapp =[Select id,LoanAppl__c,Applicant__c from BRE__c Where Applicant__c=:Applicantlist[0].id AND LoanAppl__c=:ids AND IsLatest__c=true];
                
                
                List<BRE_Eligibility__c> Eligibilitylist = new List<BRE_Eligibility__c>();
                
                //Application variable from response
                CrifExecuteAPIResponseWrapper.Variables var =res.StrategyOneResponse.Body.APPLICATION.Variables;
                
                //Creating BRE_Eligibility record for Considered_perc_Cash Flow - Assessed income
                if(var.Considered_perc_Cash_Flow_Assessed_Income!=null){
                    
                    BRE_Eligibility__c be =new BRE_Eligibility__c();
                    
                    be.LoanApp__c=ids!=null?ids:'';
                    be.BREResponse__c=bre[0].id!=null?bre[0].id:'';
                    be.IsLatest__c=true;
                    be.Type__c='Application';
                    be.IncomeProgram__c='Cash Flow - Assessed income';
                    be.Consideration__c=Decimal.valueOf(var.Considered_perc_Cash_Flow_Assessed_Income);
                    Eligibilitylist.add(be);
                    
                }
                
                //Creating BRE_Eligibility record for Considered_perc_ Business income - Regular Income Program (P&L)
                if(var.Considered_perc_Business_Income_Regular_Income_Program!=null){
                    
                    BRE_Eligibility__c be =new BRE_Eligibility__c();
                    
                    be.LoanApp__c=ids!=null?ids:'';
                    be.BREResponse__c=bre[0].id!=null?bre[0].id:'';
                    be.IsLatest__c=true;
                    be.Type__c='Application';
                    be.IncomeProgram__c='Business income - Regular Income Program (P&L)';
                    be.Consideration__c=Decimal.valueOf(var.Considered_perc_Business_Income_Regular_Income_Program);
                    Eligibilitylist.add(be);
                    
                }
                
                //Creating BRE_Eligibility record for Considered_perc_Gross_Eligible_Salary_with_Bank_Credit
                if(var.Considered_perc_Gross_Eligible_Salary_with_Bank_Credit!=null){
                    
                    BRE_Eligibility__c be =new BRE_Eligibility__c();
                    
                    be.LoanApp__c=ids!=null?ids:'';
                    be.BREResponse__c=bre[0].id!=null?bre[0].id:'';
                    be.IsLatest__c=true;
                    be.Type__c='Application';
                    be.IncomeProgram__c='Gross Eligible Salary with Bank Credit';
                    be.Consideration__c=Decimal.valueOf(var.Considered_perc_Gross_Eligible_Salary_with_Bank_Credit);
                    Eligibilitylist.add(be);
                    
                }
                
                //Creating BRE_Eligibility record for Considered_perc_Net_Eligible_Salary_with_Bank_Credit
                if(var.Considered_perc_Net_Eligible_Salary_with_Bank_Credit!=null){
                    
                    BRE_Eligibility__c be =new BRE_Eligibility__c();
                    
                    be.LoanApp__c=ids!=null?ids:'';
                    be.BREResponse__c=bre[0].id!=null?bre[0].id:'';
                    be.IsLatest__c=true;
                    be.Type__c='Application';
                    be.IncomeProgram__c='Net Eligible Salary with Bank Credit';
                    be.Consideration__c=Decimal.valueOf(var.Considered_perc_Net_Eligible_Salary_with_Bank_Credit);
                    Eligibilitylist.add(be);
                    
                }
                
                //Creating BRE_Eligibility record for Considered_perc_Cash_Salary
                if(var.Considered_perc_Cash_Salary!=null){
                    
                    BRE_Eligibility__c be =new BRE_Eligibility__c();
                    
                    be.LoanApp__c=ids!=null?ids:'';
                    be.BREResponse__c=bre[0].id!=null?bre[0].id:'';
                    be.IsLatest__c=true;
                    be.Type__c='Application';
                    be.IncomeProgram__c='Cash Salary';
                    be.Consideration__c=Decimal.valueOf(var.Considered_perc_Cash_Salary);
                    Eligibilitylist.add(be);
                    
                }
                
                //Creating BRE_Eligibility record for Considered_perc_Rental_Bank_Credit
                if(var.Considered_perc_Rental_Bank_Credit!=null){
                    
                    BRE_Eligibility__c be =new BRE_Eligibility__c();
                    
                    be.LoanApp__c=ids!=null?ids:'';
                    be.BREResponse__c=bre[0].id!=null?bre[0].id:'';
                    be.IsLatest__c=true;
                    be.Type__c='Application';
                    be.IncomeProgram__c='Rental bank credit';
                    be.Consideration__c=Decimal.valueOf(var.Considered_perc_Rental_Bank_Credit);
                    Eligibilitylist.add(be);
                    
                }
                
                //Creating BRE_Eligibility record for Considered_perc_Rental_without_Bank_Credit
                if(var.Considered_perc_Rental_without_Bank_Credit!=null){
                    
                    BRE_Eligibility__c be =new BRE_Eligibility__c();
                    
                    be.LoanApp__c=ids!=null?ids:'';
                    be.BREResponse__c=bre[0].id!=null?bre[0].id:'';
                    be.IsLatest__c=true;
                    be.Type__c='Application';
                    be.IncomeProgram__c='Rental without bank credit';
                    be.Consideration__c=Decimal.valueOf(var.Considered_perc_Rental_without_Bank_Credit);
                    Eligibilitylist.add(be);
                    
                }
                
                //Creating BRE_Eligibility record for Considered_perc_Pension_Income
                if(var.Considered_perc_Pension_Income!=null){
                    
                    BRE_Eligibility__c be =new BRE_Eligibility__c();
                    
                    be.LoanApp__c=ids!=null?ids:'';
                    be.BREResponse__c=bre[0].id!=null?bre[0].id:'';
                    be.IsLatest__c=true;
                    be.Type__c='Application';
                    be.IncomeProgram__c='Pension Income';
                    be.Consideration__c=Decimal.valueOf(var.Considered_perc_Pension_Income);
                    Eligibilitylist.add(be);
                    
                }
                
                //Creating BRE_Eligibility record for Considered_perc_Agriculture_Income
                if(var.Considered_perc_Agriculture_Income!=null){
                    
                    BRE_Eligibility__c be =new BRE_Eligibility__c();
                    
                    be.LoanApp__c=ids!=null?ids:'';
                    be.BREResponse__c=bre[0].id!=null?bre[0].id:'';
                    be.IsLatest__c=true;
                    be.Type__c='Application';
                    be.IncomeProgram__c='Agriculture Income';
                    be.Consideration__c=Decimal.valueOf(var.Considered_perc_Agriculture_Income);
                    Eligibilitylist.add(be);
                    
                }
                
                //Creating BRE_Eligibility record for Considered_perc_Other_Income
                if(var.Considered_perc_Other_Income!=null){
                    
                    BRE_Eligibility__c be =new BRE_Eligibility__c();
                    
                    be.LoanApp__c=ids!=null?ids:'';
                    be.BREResponse__c=bre[0].id!=null?bre[0].id:'';
                    be.IsLatest__c=true;
                    be.Type__c='Application';
                    be.IncomeProgram__c='Other Income';
                    be.Consideration__c=Decimal.valueOf(var.Considered_perc_Other_Income);
                    Eligibilitylist.add(be);
                    
                }
                
                
                
                //APPLICANT,COAPPLICANT,GUARANTOR variable from response
                for (CrifExecuteAPIResponseWrapper.Categories category : res.StrategyOneResponse.Body.APPLICATION.Categories) {
                    
                    //APPLICANT Variables
                    
                    if (category.APPLICANT!=null) {
                        
                        CrifExecuteAPIResponseWrapper.applicantvariabels appvar =category.APPLICANT.Variables;
                        
                        
                        
                        //Creating BRE_Eligibility record for Business income - Regular Income Program (P&L) 
                        
                        if(appvar.Monthly_Business_Income_Regular_Income_Program !=null){
                            
                            BRE_Eligibility__c be =new BRE_Eligibility__c();
                            
                            be.LoanApp__c=ids!=null?ids:'';
                            be.Applicant__c=Applicantlist[0].id!=null?Applicantlist[0].id:'';
                            be.BREResponse__c=breapp[0].id!=null?breapp[0].id:'';
                            be.IsLatest__c=true;
                            be.Type__c='Applicant';
                            be.IncomeProgram__c='Business income - Regular Income Program (P&L)';
                            be.BREValue__c=Decimal.valueOf(appvar.Monthly_Business_Income_Regular_Income_Program);
                            Eligibilitylist.add(be);
                        }
                        
                        //Creating BRE_Eligibility record for Gross Eligible Salary with Bank Credit
                        
                        if(appvar.Gross_Eligible_Salary_with_Bank_Credit !=null){
                            
                            BRE_Eligibility__c be =new BRE_Eligibility__c();
                            
                            be.LoanApp__c=ids!=null?ids:'';
                            be.Applicant__c=Applicantlist[0].id!=null?Applicantlist[0].id:'';
                            be.BREResponse__c=breapp[0].id!=null?breapp[0].id:'';
                            be.IsLatest__c=true;
                            be.Type__c='Applicant';
                            be.IncomeProgram__c='Gross Eligible Salary with Bank Credit';
                            be.BREValue__c=Decimal.valueOf(appvar.Gross_Eligible_Salary_with_Bank_Credit);
                            Eligibilitylist.add(be);
                        }
                        
                        //Creating BRE_Eligibility record for Net Eligible Salary with Bank Credit
                        
                        if(appvar.Net_Eligible_Salary_with_Bank_Credit !=null){
                            
                            BRE_Eligibility__c be =new BRE_Eligibility__c();
                            
                            be.LoanApp__c=ids!=null?ids:'';
                            be.Applicant__c=Applicantlist[0].id!=null?Applicantlist[0].id:'';
                            be.BREResponse__c=breapp[0].id!=null?breapp[0].id:'';
                            be.IsLatest__c=true;
                            be.Type__c='Applicant';
                            be.IncomeProgram__c='Net Eligible Salary with Bank Credit';
                            be.BREValue__c=Decimal.valueOf(appvar.Net_Eligible_Salary_with_Bank_Credit);
                            Eligibilitylist.add(be);
                        }
                        
                        //Creating BRE_Eligibility record for Profit Before Tax
                        
                        if(appvar.Profit_Before_Tax_considered !=null || appvar.Considered_perc_Profit_Before_Tax !=null){
                            
                            BRE_Eligibility__c be =new BRE_Eligibility__c();
                            
                            be.LoanApp__c=ids!=null?ids:'';
                            be.Applicant__c=Applicantlist[0].id!=null?Applicantlist[0].id:'';
                            be.BREResponse__c=breapp[0].id!=null?breapp[0].id:'';
                            be.IsLatest__c=true;
                            be.Type__c='Applicant';
                            be.IncomeProgram__c='Profit Before Tax';
                            if(appvar.Profit_Before_Tax_considered !=null){
                                be.EligIncome__c=Decimal.valueOf(appvar.Profit_Before_Tax_considered);
                            }
                            if(appvar.Considered_perc_Profit_Before_Tax !=null){
                                be.Eligibilityper__c=Decimal.valueOf(appvar.Considered_perc_Profit_Before_Tax);
                            }
                            Eligibilitylist.add(be);
                        }
                        
                        //Creating BRE_Eligibility record for Depreciation
                        
                        if(appvar.Depreciation_considered !=null || appvar.Considered_perc_Depreciation !=null){
                            
                            BRE_Eligibility__c be =new BRE_Eligibility__c();
                            
                            be.LoanApp__c=ids!=null?ids:'';
                            be.Applicant__c=Applicantlist[0].id!=null?Applicantlist[0].id:'';
                            be.BREResponse__c=breapp[0].id!=null?breapp[0].id:'';
                            be.IsLatest__c=true;
                            be.Type__c='Applicant';
                            be.IncomeProgram__c='Depreciation';
                            if(appvar.Depreciation_considered !=null){
                                be.EligIncome__c=Decimal.valueOf(appvar.Depreciation_considered);
                            }
                            if(appvar.Considered_perc_Depreciation !=null){
                                be.Eligibilityper__c=Decimal.valueOf(appvar.Considered_perc_Depreciation);
                            }
                            Eligibilitylist.add(be);
                        }
                        
                        //Creating BRE_Eligibility record for Interest on Partners Capital & Renumeration Income
                        
                        if(appvar.Interest_on_Partners_Capital_Renum_Inc_considered !=null || appvar.Considered_perc_Interest_on_Partners_Capital_Renum_Inc !=null){
                            
                            BRE_Eligibility__c be =new BRE_Eligibility__c();
                            
                            be.LoanApp__c=ids!=null?ids:'';
                            be.Applicant__c=Applicantlist[0].id!=null?Applicantlist[0].id:'';
                            be.BREResponse__c=breapp[0].id!=null?breapp[0].id:'';
                            be.IsLatest__c=true;
                            be.Type__c='Applicant';
                            be.IncomeProgram__c='Interest on Partners Capital & Renumeration Income';
                            if(appvar.Interest_on_Partners_Capital_Renum_Inc_considered !=null){
                                be.EligIncome__c=Decimal.valueOf(appvar.Interest_on_Partners_Capital_Renum_Inc_considered);
                            }
                            if(appvar.Considered_perc_Interest_on_Partners_Capital_Renum_Inc !=null){
                                be.Eligibilityper__c=Decimal.valueOf(appvar.Considered_perc_Interest_on_Partners_Capital_Renum_Inc);
                            }
                            Eligibilitylist.add(be);
                        }
                        
                        //Creating BRE_Eligibility record for Interest on Loan
                        
                        if(appvar.Interest_on_Loan_considered !=null || appvar.Considered_perc_Interest_on_Loan !=null){
                            
                            BRE_Eligibility__c be =new BRE_Eligibility__c();
                            
                            be.LoanApp__c=ids!=null?ids:'';
                            be.Applicant__c=Applicantlist[0].id!=null?Applicantlist[0].id:'';
                            be.BREResponse__c=breapp[0].id!=null?breapp[0].id:'';
                            be.IsLatest__c=true;
                            be.Type__c='Applicant';
                            be.IncomeProgram__c='Interest on Loan';
                            if(appvar.Interest_on_Loan_considered !=null){
                                be.EligIncome__c=Decimal.valueOf(appvar.Interest_on_Loan_considered);
                            } 
                            if(appvar.Considered_perc_Interest_on_Loan !=null){
                                be.Eligibilityper__c=Decimal.valueOf(appvar.Considered_perc_Interest_on_Loan);
                            }
                            Eligibilitylist.add(be);
                        }
                        
                        
                        //Creating BRE_Eligibility record for Tax
                        
                        if(appvar.Tax_considered !=null || appvar.Considered_perc_tax !=null){
                            
                            BRE_Eligibility__c be =new BRE_Eligibility__c();
                            
                            be.LoanApp__c=ids!=null?ids:'';
                            be.Applicant__c=Applicantlist[0].id!=null?Applicantlist[0].id:'';
                            be.BREResponse__c=breapp[0].id!=null?breapp[0].id:'';
                            be.IsLatest__c=true;
                            be.Type__c='Applicant';
                            be.IncomeProgram__c='Tax';
                            if(appvar.Tax_considered !=null){
                                be.EligIncome__c=Decimal.valueOf(appvar.Tax_considered);
                            }
                            if(appvar.Considered_perc_tax !=null){
                                be.Eligibilityper__c=Decimal.valueOf(appvar.Considered_perc_tax);
                            }
                            Eligibilitylist.add(be);
                        }
                        
                        
                        //Creating BRE_Eligibility record for Annual Business income - Regular Income Program (P&L) - ₹
                        
                        if(appvar.Annual_Business_Income_Regular_Income_Program !=null){
                            
                            BRE_Eligibility__c be =new BRE_Eligibility__c();
                            
                            be.LoanApp__c=ids!=null?ids:'';
                            be.Applicant__c=Applicantlist[0].id!=null?Applicantlist[0].id:'';
                            be.BREResponse__c=breapp[0].id!=null?breapp[0].id:'';
                            be.IsLatest__c=true;
                            be.Type__c='Applicant';
                            be.IncomeProgram__c='Annual Business income - Regular Income Program (P&L) - ₹';
                            be.EligIncome__c=Decimal.valueOf(appvar.Annual_Business_Income_Regular_Income_Program);
                            
                            Eligibilitylist.add(be);
                        }
                        
                        
                        //Creating BRE_Eligibility record for Monthly Business income - Regular Income Program (P&L) - ₹
                        
                        if(appvar.Monthly_Business_Income_Regular_Income_Program !=null){
                            
                            BRE_Eligibility__c be =new BRE_Eligibility__c();
                            
                            be.LoanApp__c=ids!=null?ids:'';
                            be.Applicant__c=Applicantlist[0].id!=null?Applicantlist[0].id:'';
                            be.BREResponse__c=breapp[0].id!=null?breapp[0].id:'';
                            be.IsLatest__c=true;
                            be.Type__c='Applicant';
                            be.IncomeProgram__c='Monthly Business income - Regular Income Program (P&L) - ₹';
                            be.EligIncome__c=Decimal.valueOf(appvar.Monthly_Business_Income_Regular_Income_Program);
                            
                            Eligibilitylist.add(be);
                        }
                        
                        
                        //Creating BRE_Eligibility record for Salaried Eligibility Consideration (%)
                        
                        if(appvar.Considered_perc_Gross_Salary !=null || appvar.Considered_perc_variable_component !=null || appvar.Considered_perc_annual_benefits !=null || appvar.Considered_perc_Performance_Bonus !=null || appvar.Considered_perc_tax !=null || appvar.Considered_perc_other_deductions !=null){
                            
                            BRE_Eligibility__c be =new BRE_Eligibility__c();
                            
                            be.LoanApp__c=ids!=null?ids:'';
                            be.Applicant__c=Applicantlist[0].id!=null?Applicantlist[0].id:'';
                            be.BREResponse__c=breapp[0].id!=null?breapp[0].id:'';
                            be.IsLatest__c=true;
                            be.Type__c='Applicant';
                            be.IncomeProgram__c='Salaried Eligibility Consideration (%)';
                            if(appvar.Considered_perc_Gross_Salary !=null){
                                be.GrossSalMon__c=Decimal.valueOf(appvar.Considered_perc_Gross_Salary);
                            }
                            if(appvar.Considered_perc_variable_component !=null){
                                be.VarComMon__c=Decimal.valueOf(appvar.Considered_perc_variable_component);
                            }
                            if(appvar.Considered_perc_annual_benefits !=null){
                                be.AnulbenLTA_Mon__c=Decimal.valueOf(appvar.Considered_perc_annual_benefits);
                            }
                            if(appvar.Considered_perc_Performance_Bonus !=null){
                                be.PrfBonMon__c=Decimal.valueOf(appvar.Considered_perc_Performance_Bonus);
                            }
                            if(appvar.Considered_perc_tax !=null){
                                be.TaxMon__c=Decimal.valueOf(appvar.Considered_perc_tax);
                            }
                            if(appvar.Considered_perc_other_deductions !=null){
                                be.OtrDedMon__c=Decimal.valueOf(appvar.Considered_perc_other_deductions);
                            }
                            
                            
                            Eligibilitylist.add(be);
                        }
                        
                        //Creating BRE_Eligibility record for Salaried Eligible income (₹)
                        
                        if(appvar.Gross_salary_considered !=null || appvar.Variable_Component_considered !=null || appvar.Annual_Benefits_like_LTA_considered !=null || appvar.Performance_Bonus_considered !=null || appvar.Tax_considered !=null || appvar.Other_Deducation_considered !=null){
                            
                            BRE_Eligibility__c be =new BRE_Eligibility__c();
                            
                            be.LoanApp__c=ids!=null?ids:'';
                            be.Applicant__c=Applicantlist[0].id!=null?Applicantlist[0].id:'';
                            be.BREResponse__c=breapp[0].id!=null?breapp[0].id:'';
                            be.IsLatest__c=true;
                            be.Type__c='Applicant';
                            be.IncomeProgram__c='Salaried Eligible income (₹)';
                            if(appvar.Gross_salary_considered !=null){
                                be.GrossSalMon__c=Decimal.valueOf(appvar.Gross_salary_considered);
                            }
                            if(appvar.Variable_Component_considered !=null){
                                be.VarComMon__c=Decimal.valueOf(appvar.Variable_Component_considered);
                            }
                            if(appvar.Annual_Benefits_like_LTA_considered !=null){
                                be.AnulbenLTA_Mon__c=Decimal.valueOf(appvar.Annual_Benefits_like_LTA_considered);
                            }
                            if(appvar.Performance_Bonus_considered !=null){
                                be.PrfBonMon__c=Decimal.valueOf(appvar.Performance_Bonus_considered);
                            }
                            if(appvar.Tax_considered !=null){
                                be.TaxMon__c=Decimal.valueOf(appvar.Tax_considered);
                            }
                            if(appvar.Other_Deducation_considered !=null){
                                be.OtrDedMon__c=Decimal.valueOf(appvar.Other_Deducation_considered);
                            }
                            
                            
                            Eligibilitylist.add(be);
                        }
                    }
                    
                    //COAPPLICANT Variables
                    
                    if(category.COAPPLICANT!=null){
                        
                        CrifExecuteAPIResponseWrapper.co_applicantvariabels coappvar =category.COAPPLICANT.Variables;
                        
                        //Creating BRE_Eligibility record for Business income - Regular Income Program (P&L) 
                        
                        if(coappvar.Monthly_Business_Income_Regular_Income_Program !=null){
                            
                            if(bremap.containsKey(coappvar.unique_id)){
                                
                                BRE__c brr =bremap.get(coappvar.unique_id);
                                
                                BRE_Eligibility__c be =new BRE_Eligibility__c();
                                
                                be.LoanApp__c=ids!=null?ids:'';
                                be.Applicant__c=coappvar.unique_id!=null?coappvar.unique_id:'';
                                be.BREResponse__c=brr.id;
                                be.IsLatest__c=true;
                                be.Type__c='Applicant';
                                be.IncomeProgram__c='Business income - Regular Income Program (P&L)';
                                be.BREValue__c=Decimal.valueOf(coappvar.Monthly_Business_Income_Regular_Income_Program);
                                Eligibilitylist.add(be);
                                
                                
                            }
                            
                            
                        }
                        
                        //Creating BRE_Eligibility record for Gross Eligible Salary with Bank Credit 
                        
                        if(coappvar.Gross_Eligible_Salary_with_Bank_Credit !=null){
                            
                            if(bremap.containsKey(coappvar.unique_id)){
                                
                                BRE__c brr =bremap.get(coappvar.unique_id);
                                
                                BRE_Eligibility__c be =new BRE_Eligibility__c();
                                
                                be.LoanApp__c=ids!=null?ids:'';
                                be.Applicant__c=coappvar.unique_id!=null?coappvar.unique_id:'';
                                be.BREResponse__c=brr.id;
                                be.IsLatest__c=true;
                                be.Type__c='Applicant';
                                be.IncomeProgram__c='Gross Eligible Salary with Bank Credit';
                                be.BREValue__c=Decimal.valueOf(coappvar.Gross_Eligible_Salary_with_Bank_Credit);
                                Eligibilitylist.add(be);
                                
                                
                            }
                            
                            
                        }
                        
                        //Creating BRE_Eligibility record for Net Eligible Salary with Bank Credit 
                        
                        if(coappvar.Net_Eligible_Salary_with_Bank_Credit !=null){
                            
                            if(bremap.containsKey(coappvar.unique_id)){
                                
                                BRE__c brr =bremap.get(coappvar.unique_id);
                                
                                BRE_Eligibility__c be =new BRE_Eligibility__c();
                                
                                be.LoanApp__c=ids!=null?ids:'';
                                be.Applicant__c=coappvar.unique_id!=null?coappvar.unique_id:'';
                                be.BREResponse__c=brr.id;
                                be.IsLatest__c=true;
                                be.Type__c='Applicant';
                                be.IncomeProgram__c='Net Eligible Salary with Bank Credit';
                                be.BREValue__c=Decimal.valueOf(coappvar.Net_Eligible_Salary_with_Bank_Credit);
                                Eligibilitylist.add(be);
                                
                                
                            }
                            
                            
                        }
                        
                        //Creating BRE_Eligibility record for Profit Before Tax 
                        
                        if(coappvar.Profit_Before_Tax_considered !=null || coappvar.Considered_perc_Profit_Before_Tax !=null){
                            
                            if(bremap.containsKey(coappvar.unique_id)){
                                
                                BRE__c brr =bremap.get(coappvar.unique_id);
                                
                                BRE_Eligibility__c be =new BRE_Eligibility__c();
                                
                                be.LoanApp__c=ids!=null?ids:'';
                                be.Applicant__c=coappvar.unique_id!=null?coappvar.unique_id:'';
                                be.BREResponse__c=brr.id;
                                be.IsLatest__c=true;
                                be.Type__c='Applicant';
                                be.IncomeProgram__c='Profit Before Tax';
                                if(coappvar.Profit_Before_Tax_considered!=null){
                                    be.EligIncome__c=Decimal.valueOf(coappvar.Profit_Before_Tax_considered);
                                }
                                if(coappvar.Considered_perc_Profit_Before_Tax !=null){
                                    be.Eligibilityper__c=Decimal.valueOf(coappvar.Considered_perc_Profit_Before_Tax);
                                }
                                
                                Eligibilitylist.add(be);
                                
                                
                            }
                            
                            
                        }
                        
                        //Creating BRE_Eligibility record for Depreciation
                        
                        if(coappvar.Depreciation_considered !=null || coappvar.Considered_perc_Depreciation !=null){
                            
                            if(bremap.containsKey(coappvar.unique_id)){
                                
                                BRE__c brr =bremap.get(coappvar.unique_id);
                                
                                BRE_Eligibility__c be =new BRE_Eligibility__c();
                                
                                be.LoanApp__c=ids!=null?ids:'';
                                be.Applicant__c=coappvar.unique_id!=null?coappvar.unique_id:'';
                                be.BREResponse__c=brr.id;
                                be.IsLatest__c=true;
                                be.Type__c='Applicant';
                                be.IncomeProgram__c='Depreciation';
                                if(coappvar.Depreciation_considered !=null){
                                    be.EligIncome__c=Decimal.valueOf(coappvar.Depreciation_considered);
                                }
                                if(coappvar.Considered_perc_Depreciation !=null){
                                    be.Eligibilityper__c=Decimal.valueOf(coappvar.Considered_perc_Depreciation);
                                }
                                Eligibilitylist.add(be);
                                
                                
                            }
                            
                            
                        }
                        
                        //Creating BRE_Eligibility record for Interest on Partner's Capital & Renumeration Income
                        
                        if(coappvar.Interest_on_Partners_Capital_Renum_Inc_considered !=null || coappvar.Considered_perc_Interest_on_Partners_Capital_Renum_Inc !=null){
                            
                            if(bremap.containsKey(coappvar.unique_id)){
                                
                                BRE__c brr =bremap.get(coappvar.unique_id);
                                
                                BRE_Eligibility__c be =new BRE_Eligibility__c();
                                
                                be.LoanApp__c=ids!=null?ids:'';
                                be.Applicant__c=coappvar.unique_id!=null?coappvar.unique_id:'';
                                be.BREResponse__c=brr.id;
                                be.IsLatest__c=true;
                                be.Type__c='Applicant';
                                be.IncomeProgram__c='Interest on Partners Capital & Renumeration Income';
                                if(coappvar.Interest_on_Partners_Capital_Renum_Inc_considered !=null){
                                    be.EligIncome__c=Decimal.valueOf(coappvar.Interest_on_Partners_Capital_Renum_Inc_considered);
                                }
                                if(coappvar.Considered_perc_Interest_on_Partners_Capital_Renum_Inc !=null){
                                    be.Eligibilityper__c=Decimal.valueOf(coappvar.Considered_perc_Interest_on_Partners_Capital_Renum_Inc);
                                }
                                Eligibilitylist.add(be);
                                
                                
                            }
                            
                            
                        }
                        
                        //Creating BRE_Eligibility record for Interest on Loan
                        
                        if(coappvar.Interest_on_Loan_considered !=null || coappvar.Considered_perc_Interest_on_Loan !=null){
                            
                            if(bremap.containsKey(coappvar.unique_id)){
                                
                                BRE__c brr =bremap.get(coappvar.unique_id);
                                
                                BRE_Eligibility__c be =new BRE_Eligibility__c();
                                
                                be.LoanApp__c=ids!=null?ids:'';
                                be.Applicant__c=coappvar.unique_id!=null?coappvar.unique_id:'';
                                be.BREResponse__c=brr.id;
                                be.IsLatest__c=true;
                                be.Type__c='Applicant';
                                be.IncomeProgram__c='Interest on Loan';
                                if(coappvar.Interest_on_Loan_considered !=null){
                                    be.EligIncome__c=Decimal.valueOf(coappvar.Interest_on_Loan_considered);
                                }
                                if(coappvar.Considered_perc_Interest_on_Loan !=null){
                                    be.Eligibilityper__c=Decimal.valueOf(coappvar.Considered_perc_Interest_on_Loan);
                                }
                                Eligibilitylist.add(be);
                                
                                
                            }
                            
                            
                        }
                        
                        //Creating BRE_Eligibility record for Tax
                        
                        if(coappvar.Tax_considered !=null || coappvar.Considered_perc_tax !=null){
                            
                            if(bremap.containsKey(coappvar.unique_id)){
                                
                                BRE__c brr =bremap.get(coappvar.unique_id);
                                
                                
                                BRE_Eligibility__c be =new BRE_Eligibility__c();
                                
                                be.LoanApp__c=ids!=null?ids:'';
                                be.Applicant__c=coappvar.unique_id!=null?coappvar.unique_id:'';
                                be.BREResponse__c=brr.id;
                                be.IsLatest__c=true;
                                be.Type__c='Applicant';
                                be.IncomeProgram__c='Tax';
                                if(coappvar.Tax_considered !=null){
                                    be.EligIncome__c=Decimal.valueOf(coappvar.Tax_considered);
                                }
                                if(coappvar.Considered_perc_tax !=null){
                                    be.Eligibilityper__c=Decimal.valueOf(coappvar.Considered_perc_tax);
                                }
                                Eligibilitylist.add(be);
                                
                                
                            }
                            
                        }
                        
                        //Creating BRE_Eligibility record for Annual Business income - Regular Income Program (P&L) - ₹
                        
                        if(coappvar.Annual_Business_Income_Regular_Income_Program !=null){
                            
                            if(bremap.containsKey(coappvar.unique_id)){
                                
                                BRE__c brr =bremap.get(coappvar.unique_id);
                                
                                BRE_Eligibility__c be =new BRE_Eligibility__c();
                                
                                be.LoanApp__c=ids!=null?ids:'';
                                be.Applicant__c=coappvar.unique_id!=null?coappvar.unique_id:'';
                                be.BREResponse__c=brr.id;
                                be.IsLatest__c=true;
                                be.Type__c='Applicant';
                                be.IncomeProgram__c='Annual Business income - Regular Income Program (P&L) - ₹';
                                be.EligIncome__c=Decimal.valueOf(coappvar.Annual_Business_Income_Regular_Income_Program);
                                
                                Eligibilitylist.add(be);
                                
                            }
                            
                            
                        }
                        
                        //Creating BRE_Eligibility record for Monthly Business income - Regular Income Program (P&L) - ₹
                        
                        if(coappvar.Monthly_Business_Income_Regular_Income_Program !=null){
                            
                            
                            if(bremap.containsKey(coappvar.unique_id)){
                                
                                BRE__c brr =bremap.get(coappvar.unique_id);
                                
                                
                                BRE_Eligibility__c be =new BRE_Eligibility__c();
                                
                                be.LoanApp__c=ids!=null?ids:'';
                                be.Applicant__c=coappvar.unique_id!=null?coappvar.unique_id:'';
                                be.BREResponse__c=brr.id;
                                be.IsLatest__c=true;
                                be.Type__c='Applicant';
                                be.IncomeProgram__c='Monthly Business income - Regular Income Program (P&L) - ₹';
                                be.EligIncome__c=Decimal.valueOf(coappvar.Monthly_Business_Income_Regular_Income_Program);
                                
                                Eligibilitylist.add(be);
                            }
                            
                        }
                        
                        //Creating BRE_Eligibility record for Salaried Eligibility Consideration (%)
                        
                        if(coappvar.Considered_perc_Gross_Salary !=null || coappvar.Considered_perc_variable_component !=null || coappvar.Considered_perc_annual_benefits !=null || coappvar.Considered_perc_Performance_Bonus !=null || coappvar.Considered_perc_tax !=null || coappvar.Considered_perc_other_deductions !=null){
                            
                            if(bremap.containsKey(coappvar.unique_id)){
                                
                                BRE__c brr =bremap.get(coappvar.unique_id);
                                
                                BRE_Eligibility__c be =new BRE_Eligibility__c();
                                
                                be.LoanApp__c=ids!=null?ids:'';
                                be.Applicant__c=coappvar.unique_id!=null?coappvar.unique_id:'';
                                be.BREResponse__c=brr.id;
                                be.IsLatest__c=true;
                                be.Type__c='Applicant';
                                be.IncomeProgram__c='Salaried Eligibility Consideration (%)';
                                if(coappvar.Considered_perc_Gross_Salary !=null){
                                    be.GrossSalMon__c=Decimal.valueOf(coappvar.Considered_perc_Gross_Salary);
                                }
                                if(coappvar.Considered_perc_variable_component !=null){
                                    be.VarComMon__c=Decimal.valueOf(coappvar.Considered_perc_variable_component);
                                }
                                if(coappvar.Considered_perc_annual_benefits !=null){
                                    be.AnulbenLTA_Mon__c=Decimal.valueOf(coappvar.Considered_perc_annual_benefits);
                                }
                                if(coappvar.Considered_perc_Performance_Bonus !=null){
                                    be.PrfBonMon__c=Decimal.valueOf(coappvar.Considered_perc_Performance_Bonus);
                                }
                                if(coappvar.Considered_perc_tax !=null){
                                    be.TaxMon__c=Decimal.valueOf(coappvar.Considered_perc_tax);
                                }
                                if(coappvar.Considered_perc_other_deductions !=null){
                                    be.OtrDedMon__c=Decimal.valueOf(coappvar.Considered_perc_other_deductions);
                                }
                                
                                
                                Eligibilitylist.add(be);
                                
                            }
                            
                            
                        }
                        
                        //Creating BRE_Eligibility record for Salaried Eligible income (₹)
                        
                        if(coappvar.Gross_salary_considered !=null || coappvar.Variable_Component_considered !=null || coappvar.Annual_Benefits_like_LTA_considered !=null || coappvar.Performance_Bonus_considered !=null || coappvar.Tax_considered !=null || coappvar.Other_Deducation_considered !=null){
                            
                            if(bremap.containsKey(coappvar.unique_id)){
                                
                                BRE__c brr =bremap.get(coappvar.unique_id);
                                
                                
                                BRE_Eligibility__c be =new BRE_Eligibility__c();
                                
                                be.LoanApp__c=ids!=null?ids:'';
                                be.Applicant__c=coappvar.unique_id!=null?coappvar.unique_id:'';
                                be.BREResponse__c=brr.id;
                                be.IsLatest__c=true;
                                be.Type__c='Applicant';
                                be.IncomeProgram__c='Salaried Eligible income (₹)';
                                if(coappvar.Gross_salary_considered !=null){
                                    be.GrossSalMon__c=Decimal.valueOf(coappvar.Gross_salary_considered);
                                }
                                if(coappvar.Variable_Component_considered !=null){
                                    be.VarComMon__c=Decimal.valueOf(coappvar.Variable_Component_considered);
                                }
                                if(coappvar.Annual_Benefits_like_LTA_considered !=null){
                                    be.AnulbenLTA_Mon__c=Decimal.valueOf(coappvar.Annual_Benefits_like_LTA_considered);
                                }
                                if(coappvar.Performance_Bonus_considered !=null){
                                    be.PrfBonMon__c=Decimal.valueOf(coappvar.Performance_Bonus_considered);
                                }
                                if(coappvar.Tax_considered !=null){
                                    be.TaxMon__c=Decimal.valueOf(coappvar.Tax_considered);
                                }
                                if(coappvar.Other_Deducation_considered !=null){
                                    be.OtrDedMon__c=Decimal.valueOf(coappvar.Other_Deducation_considered);
                                }
                                
                                
                                Eligibilitylist.add(be);
                                
                                
                            }
                            
                        }
                        
                        
                    }
                    
                    
                    //GUARANTOR Variables
                    
                    if(category.GUARANTOR!=null){
                        
                        CrifExecuteAPIResponseWrapper.guarantorvariabels guarantor =category.GUARANTOR.Variables;
                        
                        //Creating BRE_Eligibility record for Profit Before Tax 
                        
                        if(guarantor.Considered_perc_Profit_Before_Tax !=null){
                            
                            if(bremap.containsKey(guarantor.unique_id)){
                                
                                BRE__c brr =bremap.get(guarantor.unique_id);
                                
                                BRE_Eligibility__c be =new BRE_Eligibility__c();
                                
                                be.LoanApp__c=ids!=null?ids:'';
                                be.Applicant__c=guarantor.unique_id!=null?guarantor.unique_id:'';
                                be.BREResponse__c=brr.id;
                                be.IsLatest__c=true;
                                be.Type__c='Applicant';
                                be.IncomeProgram__c='Profit Before Tax';
                                be.Eligibilityper__c=Decimal.valueOf(guarantor.Considered_perc_Profit_Before_Tax);
                                Eligibilitylist.add(be);
                                
                                
                            }
                            
                            
                        }
                        
                        //Creating BRE_Eligibility record for Depreciation 
                        
                        if(guarantor.Considered_perc_Depreciation !=null){
                            
                            if(bremap.containsKey(guarantor.unique_id)){
                                
                                BRE__c brr =bremap.get(guarantor.unique_id);
                                
                                BRE_Eligibility__c be =new BRE_Eligibility__c();
                                
                                be.LoanApp__c=ids!=null?ids:'';
                                be.Applicant__c=guarantor.unique_id!=null?guarantor.unique_id:'';
                                be.BREResponse__c=brr.id;
                                be.IsLatest__c=true;
                                be.Type__c='Applicant';
                                be.IncomeProgram__c='Depreciation';
                                be.Eligibilityper__c=Decimal.valueOf(guarantor.Considered_perc_Depreciation);
                                Eligibilitylist.add(be);
                                
                                
                            }
                            
                            
                        }
                        
                    }
                    
                }
                
                if(Eligibilitylist!=null){
                    List<string> fieldNamesList = New List<string>{'LoanApp__c','Applicant__c','IsLatest__c','Type__c','BREResponse__c',
                        'IncomeProgram__c','RegIncomePrg__c','Consideration__c','BREValue__c',
                        'EligIncome__c','Eligibilityper__c','GrossSalMon__c','VarComMon__c',
                        'AnulbenLTA_Mon__c','PrfBonMon__c','TaxMon__c','OtrDedMon__c'};
                            String sObjectName = 'BRE_Eligibility__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(Eligibilitylist);
                }
                uow.commitWork();
                
            } catch (Exception ex) {
                //system.debug('Error message and line number: ' + ex.getMessage() + ' Line: ' + ex.getLineNumber());
                GlobalUtility.logMessage('Error', 'CrifExecuteAPIResponseProcessor class', 
                                         'BREeligibility', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            
            
            
        }
        
    }
    
    //*************************************************************************************************************************
    public Static void IsLatestFalse(List<SObject> recordList, String fieldName){//List<BureauRespDtl__c> recordList
        
        if(!recordList.isempty()){
            // SObjectType sObjectType = recordList.getSObjectType();
            
            List<SObject> recordsToUpdate = new List<SObject>();
            
            for (SObject record : recordList) {
                if (record.get(fieldName) != null) {
                    record.put(fieldName, false);
                    recordsToUpdate.add(record);
                }
            }
            
            if (!recordsToUpdate.isEmpty()) {
                update recordsToUpdate;
            }
        }
        
        
        
    }
    //*************************************************************************************************************************
    private static Integer compareAuthorities(String authority1, String authority2) {
        Map<String, Integer> authorityPriority = new Map<String, Integer>{
            'L7' => 7,
                'L6' => 6,
                'L5' => 5,
                'L4' => 4,
                'L3' => 3,
                'L2' => 2,
                'L1' => 1
                };
                    
                    return authorityPriority.get(authority1) - authorityPriority.get(authority2);
    }
    //*************************************************************************************************************************
    Private Static Map<String,String> breDecisionMap =new Map<String,String>{
       'reject'=>'BRE Soft Reject',
        'hard reject'=>'BRE Hard Reject',
           'refer'=>'In Progress',
        'review'=>'In Progress',
        'approve'=>'In Progress'
    };
}