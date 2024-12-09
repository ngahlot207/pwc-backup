@isTest
public class LLPBaseDtlsResponseProcessorTest {
    
    
    @isTest
    static void testProcessSuccess1() {
        
        LoanAppl__c loanApplication = TestDataFactory.createLoanApplication(true);

        
        List<Applicant__c> liAppls=new List<Applicant__c>();
        Applicant__c appl1=new Applicant__c();
        appl1.PAN__c='AALPG6716G';
        appl1.LoanAppln__c=loanApplication.Id;
        appl1.FName__c='Example One';
        appl1.Gender__c='M';
        appl1.ApplType__c='D';
        appl1.DOB__c=Date.newInstance(2001, 8, 13);
        appl1.Age__c=27;
        liAppls.add(appl1);
        
        
            
        Applicant__c appl3=new Applicant__c();
        appl3.PAN__c='AAAPG8092J';
        appl3.LoanAppln__c=loanApplication.Id;
        appl3.FName__c='Example Two';
        appl3.Gender__c='M';
        appl3.ApplType__c='D';
        appl3.DOB__c=Date.newInstance(2001, 8, 13);
        appl3.Age__c=27;
        liAppls.add(appl3);
            
        
        
        Applicant__c appl2=new Applicant__c();
        appl2.PAN__c='AFZCG3995M';
        appl2.LoanAppln__c=loanApplication.Id;
        appl2.FName__c='Abcd Efgh';
        appl2.Gender__c='M';
        appl2.ApplType__c='D';
        appl2.DOB__c=Date.newInstance(2000, 8, 13);
        appl2.Age__c=26;
        liAppls.add(appl2);
        
        insert liAppls;
        
        List<IntgMsg__c> listIntgMsg= new List<IntgMsg__c>();
        
        List<APIVer__c> apiVersions = new List<APIVer__c>();
        //APIVer__c apiVer = new APIVer__c(Appl__c = applicant1.Id,IsLatest__c = true,RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId(),Type__c='Probe Basic LLP',IntegrationStatus__c = 'Success',LoanAplcn__c=loanApplication.Id);
        APIVer__c apiVer1 = new APIVer__c(Appl__c = appl1.Id,IsLatest__c = true,RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId(),Type__c='Probe Basic LLP',IntegrationStatus__c = 'Success',LoanAplcn__c=loanApplication.Id);
        APIVer__c apiVer2 = new APIVer__c(Appl__c = appl2.Id,IsLatest__c = true,RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId(),Type__c='Probe Basic LLP',IntegrationStatus__c = 'Success',LoanAplcn__c=loanApplication.Id);
        apiVersions.add(apiVer1);
        // apiVersions.add(apiVer);
        apiVersions.add(apiVer2);
        
        insert apiVersions;   
        
        
        // TriggerBase.bypass('IntgMsg__c');
        IntgMsg__c intgMsg4 =new IntgMsg__c();
        intgMsg4.Svc__c='LLP Base Details';
        intgMsg4.BU__c = 'HL / STL';
        intgMsg4.MStatus__c='Blank';
        intgMsg4.Status__c = 'New';
        intgMsg4.Resp__c = '';
        intgMsg4.RefId__c = liAppls[0].Id;
        intgMsg4.RefObj__c='Applicant__c';
        intgMsg4.Name='LLP Base Details';
        intgMsg4.ParentRefObj__c ='LoanAppl__c';
        intgMsg4.ParentRefId__c =loanApplication.Id;  
        listIntgMsg.add(intgMsg4);
        
        IntgMsg__c intgMsg5 =new IntgMsg__c();
        intgMsg5.Svc__c='LLP Base Details';
        intgMsg5.BU__c = 'HL / STL';
        intgMsg5.MStatus__c='Blank';
        intgMsg5.Status__c = 'New';
        intgMsg5.Resp__c = '';
        intgMsg5.RefId__c = liAppls[1].Id;
        intgMsg5.RefObj__c='Applicant__c';
        intgMsg5.Name='LLP Base Details';
        intgMsg5.ParentRefObj__c ='LoanAppl__c';
        intgMsg5.ParentRefId__c =loanApplication.Id;  
        listIntgMsg.add(intgMsg5);
        
        IntgMsg__c intgMsg7 =new IntgMsg__c();
        intgMsg7.Svc__c='LLP Comprehensive Details';
        intgMsg7.BU__c = 'HL / STL';
        intgMsg7.MStatus__c='Blank';
        intgMsg7.Status__c = 'New';
        intgMsg7.Resp__c = '';
        intgMsg7.RefId__c = liAppls[1].Id;
        intgMsg7.RefObj__c='Applicant__c';
        intgMsg7.Name='LLP Comprehensive Details';
        intgMsg7.ParentRefObj__c ='LoanAppl__c';
        intgMsg7.ParentRefId__c =loanApplication.Id;  
        listIntgMsg.add(intgMsg7);
        
        insert listIntgMsg;
        //  TriggerBase.clearBypass('IntgMsg__c');
        
        
        List<ContentVersion> listContVer= new List<ContentVersion>();
        
        ContentVersion contentVersion3 = new ContentVersion();
        //contentVersion3.VersionData =blob.valueof('{"metadata":{"api_version":"string","last_updated":"2024-08-20"},"data":{"llp":{"llpin":"string","legal_name":"string","efiling_status":"ACTIVE","incorporation_date":"2024-08-20","sum_of_charges":0,"total_obligation_of_contribution":0,"registered_address":{"full_address":"string","address_line1":"string","address_line2":"string","city":"string","pincode":"string","state":"string"},"classification":"Limited Liability Partnership","last_financial_reporting_date":"2024-08-20","last_annual_returns_filed_date":"2024-08-20","email":"string","lei":{"number":"string","status":"string"}},"open_charges":[{"id":0,"date":"2024-08-20","holder_name":"string","amount":0,"type":"Creation"}],"directors":[{"din":"string","pan":"AFZCG3995M","name":"string","designation":"Director","din_status":"string","gender":"string","date_of_birth":"2024-08-20","age":0,"date_of_appointment":"2024-08-20","date_of_appointment_for_current_designation":"2024-08-20","date_of_cessation":"2024-08-20","nationality":"string","address":{"address_line1":"string","address_line2":"string","city":"string","pincode":"string","state":"string","country":"string"}}]}}');
       contentVersion3.VersionData =blob.valueof('{"metadata":{"api_version":"1.3","last_updated":"2023-12-03"},"data":{"llp":{"llpin":"AAB-8394","legal_name":"QRG WELLNESS LLP","efiling_status":"Amalgamated","cirp_status":null,"incorporation_date":"2013-10-23","sum_of_charges":0,"total_obligation_of_contribution":500000,"registered_address":{"full_address":"904, 9th Floor, Surya Kiran Building,   K G Marg, Connaught Place,New Delhi, Delhi - 110001","address_line1":"904, 9th Floor, Surya Kiran Building,   K G Marg, Connaught Place,","address_line2":null,"city":"New Delhi","pincode":"110001","state":"Delhi"},"classification":"Limited Liability Partnership","last_financial_reporting_date":"2018-03-31","last_annual_returns_filed_date":"2018-03-31","email":"aashi.grover@qrgmedicare.com","lei":{"number":null,"status":null}},"directors":[{"pan":"AAAPG8092J","din":"00011892","name":"ANIL RAI GUPTA","designation":"Designated Partner","din_status":"Approved","gender":"Male","date_of_birth":"1969-04-20","age":55,"date_of_appointment":null,"date_of_appointment_for_current_designation":"2013-10-23","date_of_cessation":null,"nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AALPG6716G","din":"01780014","name":"SANGEETA RAI GUPTA","designation":"Designated Partner","din_status":"Approved","gender":"Female","date_of_birth":"1972-04-27","age":52,"date_of_appointment":null,"date_of_appointment_for_current_designation":"2013-10-23","date_of_cessation":null,"nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}},{"pan":"AEXPG0494H","din":"01780038","name":"SHALINI GUPTA","designation":"Designated Partner","din_status":"Approved","gender":"Female","date_of_birth":"1974-08-28","age":50,"date_of_appointment":null,"date_of_appointment_for_current_designation":"2013-10-23","date_of_cessation":null,"nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null}}],"open_charges":[{"id":100159253,"date":"2018-02-22","holder_name":"SOUTH INDIAN BANK LIMITED","amount":63340000,"type":"Creation"}]}}') ;
        contentVersion3.Title = 'response.json';
        contentVersion3.PathOnClient = 'response.json';
        listContVer.add(contentVersion3);
        
        
        ContentVersion contentVersion4 = new ContentVersion();
        contentVersion4.VersionData =blob.valueof('{"message":"This is a Company PAN"}');
        contentVersion4.Title = 'response.json';
        contentVersion4.PathOnClient = 'response.json';
		listContVer.add(contentVersion4);        
        
        
        
        ContentVersion contentVersion5 = new ContentVersion();
      
          contentVersion5.VersionData =blob.valueof('{"metadata":{"api_version":"string","last_updated":"2024-08-21"},"data":{"llp":{"total_obligation_of_contribution":0,"llpin":"string","efiling_status":"Active","incorporation_date":"2024-08-21","last_annual_returns_filed_date":"2024-08-21","last_financial_reporting_date":"2024-08-21","legal_name":"string","total_contribution_received":0,"sum_of_charges":0,"registered_address":{"full_address":"string","address_line1":"string","address_line2":"string","city":"string","pincode":"string","state":"string"},"business_address":{"address_line1":"string","address_line2":"string","city":"string","pincode":"string","state":"string"},"website":"string","pan":"AALPG6716G","classification":"Limited Liability Partnership","email":"string","lei":{"number":"string","status":"string","registration_date":"2024-08-21","last_updated_date":"2024-08-21","next_renewal_date":"2024-08-21"}},"description":{"desc_thousand_char":"string"},"name_history":[{"name":"string","date":"2024-08-21"}],"directors":[{"din":"string","pan":"string","name":"string","designation":"Director","din_status":"string","gender":"string","date_of_birth":"2024-08-21","age":0,"date_of_appointment":"2024-08-21","date_of_appointment_for_current_designation":"2024-08-21","date_of_cessation":"2024-08-21","nationality":"string","address":{"address_line1":"string","address_line2":"string","city":"string","pincode":"string","state":"string","country":"string"}}],"director_network":[{"name":"string","pan":"string","din":"string","network":{"companies":[{"cin":"string","legal_name":"string","company_status":"ACTIVE","incorporation_date":"2024-08-21","paid_up_capital":0,"sum_of_charges":0,"city":"string","active_compliance":"string","designation":"Director","date_of_appointment":"2024-08-21","date_of_appointment_for_current_designation":"2024-08-21","date_of_cessation":"2024-08-21"}],"llps":[{"llpin":"string","legal_name":"string","status":"ACTIVE","incorporation_date":"2024-08-21","total_obligation_of_contribution":0,"sum_of_charges":0,"city":"string","designation":"Designated Partner","date_of_appointment":"2024-08-21","date_of_appointment_for_current_designation":"2024-08-21","date_of_cessation":"2024-08-21"}]}}],"contact_details":{"email":[{"emailId":"string","status":"string"}],"phone":[{"phoneNumber":"string","status":"string"}]},"open_charges":[{"id":0,"date":"2024-08-21","holder_name":"string","amount":0,"type":"Creation"}],"open_charges_latest_event":[{"id":0,"amount":0,"date":"2024-08-21","holder_name":"string","type":"Creation","filing_date":"string","property_type":"string","number_of_chargeholder":"string","instrument_description":"string","rate_of_interest":"string","terms_of_payment":"string","property_particulars":"string","extent_and_operation":"string","other_terms":"string","modification_particulars":"string","joint_holding":"string","consortium_holding":"string"}],"charge_sequence":[{"charge_id":0,"status":"Creation","date":"2024-08-21","filing_date":"2024-08-21","amount":0,"holder_name":"string","number_of_holder":"string","property_type":"string","property_particulars":"string"}],"financials":[{"year":"2024-08-21","stated_on":"2024-08-21","statement_of_assets_and_liabilities":{"assets":{"gross_fixed_assets":0,"depreciation_and_amortization":0,"investments":0,"loans_and_advances":0,"inventories":0,"trade_receivables":0,"cash_and_cash_equivalents":0,"other_assets":0,"net_fixed_assets":0},"liabilities":{"contribution_received":0,"reserves_and_surplus":0,"secured_loan":0,"unsecured_loan":0,"short_term_borrowing":0,"trade_payables":0,"other_liabilities":0,"provisions_for_taxation":0,"provisions_for_contingencies":0,"provisions_for_insurance":0,"other_provisions":0},"subTotals":{"given_assets_total":0,"given_liabilities_total":0},"metadata":{"doc_id":"string"}},"statement_of_income_and_expenditure":{"lineItems":{"net_revenue":0,"operating_cost":0,"total_cost_of_materials_consumed":0,"total_purchases_of_stock_in_trade":0,"total_changes_in_inventories_or_finished_goods":0,"total_employee_benefit_expense":0,"total_other_expenses":0,"operating_profit":0,"other_income":0,"depreciation":0,"profit_before_interest_and_tax":0,"interest":0,"profit_before_tax_and_exceptional_items_before_tax":0,"exceptional_items_before_tax":0,"profit_before_tax":0,"income_tax":0,"profit_for_period_from_continuing_operations":0,"profit_from_discontinuing_operation_after_tax":0,"minority_interest_and_profit_from_associates_and_joint_ventures":0,"profit_after_tax":0},"revenue_breakup":{"sale_of_goods_manufactured_domestic":0,"sale_of_goods_traded_domestic":0,"sale_or_supply_of_services_domestic":0,"sale_or_supply_of_services_export":0,"sale_of_goods_manufactured_export":0,"sale_of_goods_traded_export":0},"depreciation_breakup":{"depreciation_and_amortization":0},"metadata":{"doc_id":"string"}},"certifiers":{"type":"Auditor","name":"string","id":"string","address":"string","firm_id":"string","firm_name":"string"}}],"establishments_registered_with_epfo":[{"establishment_id":"string","address":"string","city":"string","latest_date_of_credit":"string","date_of_setup":"string","establishment_name":"string","exemption_status_edli":"string","exemption_status_pension":"string","exemption_status_pf":"string","no_of_employees":0,"principal_business_activities":"string","amount":0,"latest_wage_month":"string","working_status":"string","filing_details":[{"trrn":"string","wage_month":"string","date_of_credit":"2024-08-21","no_of_employees":0,"amount":0}]}],"industry_segments":[{"industry":"string","segments":["string"]}],"principal_business_activities":[{"year":0,"business_classification":"string","principal_business_activities":"string"}],"legal_history":[{"petitioner":"string","respondent":"string","court":"string","date":"2024-08-21","case_status":"Pending","case_number":"string","case_category":"string","case_type":"string"}],"defaulter_list":[{"date":"2024-08-21","agency":"string","bank":"string","amount":"string"}],"credit_ratings":[{"rating_date":"2024-08-21","rating":"string","rating_agency":"string","type_of_loan":"string","amount":0,"currency":"string","rating_details":[{"rating":"string","action":"string","outlook":"string","remarks":"string"}]}],"credit_rating_rationale":[{"rating_agency":"string","financial_year":"2024-08-21","doc_id":"string"}],"unaccepted_rating":[{"rating_agency":"string","rating_details":[{"rating":"string","type_of_loan":"string","amount":0,"currency":"string","date_of_non_acceptance":"2024-08-21"}]}],"holding_entities":{"financial_year":"string","company":[{"cin":"string","legal_name":"string","paid_up_capital":0,"sum_of_charges":0,"incorporation_date":"2024-08-21","city":"string","status":"string","share_holding_percentage":0,"active_compliance":"string"}],"llp":[{"llpin":"string","legal_name":"string","total_obligation_of_contribution":0,"sum_of_charges":0,"incorporation_date":"2024-08-21","city":"string","status":"string","share_holding_percentage":0}],"others":[{"legal_name":"string","share_holding_percentage":0}]},"subsidiary_entities":{"financial_year":"string","company":[{"cin":"string","legal_name":"string","paid_up_capital":0,"sum_of_charges":0,"incorporation_date":"2024-08-21","city":"string","status":"string","share_holding_percentage":0,"active_compliance":"string"}],"llp":[{"llpin":"string","legal_name":"string","total_obligation_of_contribution":0,"sum_of_charges":0,"incorporation_date":"2024-08-21","city":"string","status":"string","share_holding_percentage":0}],"others":[{"legal_name":"string","share_holding_percentage":0}]},"contribution_details":{"financial_year":"string","individual_partners":[{"id":"string","id_type":"string","name":"string","designation":"string","obligation_contribution":"string","received_contribution":"string"}],"body_corporates":[{"id":"string","id_type":"string","name":"string","obligation_contribution":"string","received_contribution":"string","nominee_id":"string","nominee_name":"string","nominee_id_type":"string"}],"metadata":{"doc_id":"string"}},"summary_designated_partners":[{"financial_year":"2024-08-21","category":"string","partner":0,"indian_desig_partner":0,"other_desig_partner":0,"total":0}],"struckoff248_details":{"struck_off_status":"string","restored_status":"string"},"gst_details":[{"gstin":"string","status":"string","companyName":"string","tradeName":"string","state":"string","stateJurisdiction":"string","centreJurisdiction":"string","dateOfRegistration":"string","taxpayerType":"string","natureOfBusinessActivities":"string","filings":[{"returnType":"string","dateOfFilling":"string","financialYear":"string","taxPeriod":"string","status":"string"}]}],"legal_cases_of_financial_disputes":[{"receivable":[{"type_of_financial_dispute":"string","currency":"string","amount_under_default":0,"verdict":"ALLOWED","court":"string","litigant":"string","case_no":"string","amount":0,"default_date":"2024-08-21","date_of_judgement":"2024-08-21"}],"payable":[{"type_of_financial_dispute":"string","currency":"string","amount_under_default":0,"verdict":"ALLOWED","court":"string","litigant":"string","case_no":"string","amount":0,"default_date":"2024-08-21","date_of_judgement":"2024-08-21"}]}]}}');
        contentVersion5.Title = 'response.json';
        contentVersion5.PathOnClient = 'response.json';
        listContVer.add(contentVersion5);
        
        
        
        
        
        insert listContVer;
        
        
        List<ContentVersion> listConLinks= [SELECT ContentDocumentId FROM ContentVersion LIMIT 4];
        
        Id contentDocumentId3 = listConLinks[0].ContentDocumentId;
        Id contentDocumentId4 = listConLinks[1].ContentDocumentId;
        Id contentDocumentId5 = listConLinks[2].ContentDocumentId;
        List<ContentDocumentLink> listConVerLn= new List<ContentDocumentLink>();
        ContentDocumentLink contentLink3 = new ContentDocumentLink();
        contentLink3.ContentDocumentId = contentDocumentId3;
        contentLink3.LinkedEntityId=intgMsg4.id;
        contentLink3.ShareType = 'V';
        // insert contentLink3;
        listConVerLn.add(contentLink3);
        
        
        ContentDocumentLink contentLink4 = new ContentDocumentLink();
        contentLink4.ContentDocumentId = contentDocumentId4;
        contentLink4.LinkedEntityId=intgMsg5.id;
        contentLink4.ShareType = 'V';
        listConVerLn.add(contentLink4);
        
        
        
        ContentDocumentLink contentLink5 = new ContentDocumentLink();
        contentLink5.ContentDocumentId = contentDocumentId5;
        contentLink5.LinkedEntityId=intgMsg7.id;
        contentLink5.ShareType = 'V';
        listConVerLn.add(contentLink5);
        
        
        
        insert listConVerLn;
        
        List<IntgMsg__c> responses3 =new List<IntgMsg__c>{intgMsg4};
            List<IntgMsg__c> responses4 =new List<IntgMsg__c>{intgMsg5};
                 List<IntgMsg__c> responses5 =new List<IntgMsg__c>{intgMsg7};
     
        Test.startTest();
        
        LLPBaseDtlsResponseProcessor.process(responses3);
        LLPBaseDtlsResponseProcessor.process(responses4);
        LlpCompreDtlsResponseProcessor.process(responses5);
        LlpCompreDtlsResponseProcessor.process(responses4);
        Test.StopTest();
    }
    
    
    
}