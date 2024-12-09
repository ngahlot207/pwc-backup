@isTest
public class ComCompreDtlsResponseProcessorTest {
 
	@isTest
    static void testProcessSuccess() {

            LoanAppl__c loanApplication = TestDataFactory.createLoanApplication(true);
            Applicant__c applicant1 =  TestDataFactory.createSingleApplicant(true,loanApplication.id); 

            List<IntgMsg__c> listIntgMsg= new List<IntgMsg__c>();
            
            List<APIVer__c> apiVersions = new List<APIVer__c>();
            for (Integer i = 0; i < 5; i++) {
                APIVer__c apiVer = new APIVer__c(Appl__c = applicant1.Id,IsLatest__c = true,RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId(),Type__c='Probe Comprehensive Company',IntegrationStatus__c = 'Success');
                APIVer__c apiVer1 = new APIVer__c(Appl__c = applicant1.Id,IsLatest__c = true,RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId(),Type__c='Probe Comprehensive Company',IntegrationStatus__c = 'Success');
                APIVer__c apiVer2 = new APIVer__c(Appl__c = applicant1.Id,IsLatest__c = true,RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId(),Type__c='Probe Comprehensive Company',IntegrationStatus__c = 'Success');
                APIVer__c apiVer3 = new APIVer__c(Appl__c = applicant1.Id,IsLatest__c = true,RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId(),Type__c='Probe Comprehensive Company',IntegrationStatus__c = 'Success');

                apiVersions.add(apiVer);
                apiVersions.add(apiVer1);
                apiVersions.add(apiVer2);
                apiVersions.add(apiVer3);
            }
            insert apiVersions;

            TriggerBase.bypass('IntgMsg__c');
            IntgMsg__c intgMsg4 =new IntgMsg__c();
            intgMsg4.Svc__c='Company Comprehensive Details';
            intgMsg4.BU__c = 'HL / STL';
            intgMsg4.MStatus__c='Blank';
            intgMsg4.Status__c = 'New';
            intgMsg4.Resp__c = '';
            intgMsg4.RefId__c = apiVersions[0].Id;
            intgMsg4.RefObj__c='APIVer__c';
            intgMsg4.Name='Company Comprehensive Details';
            intgMsg4.ParentRefObj__c ='Applicant__c';
            intgMsg4.ParentRefId__c =applicant1.Id;  
            listIntgMsg.add(intgMsg4);

            IntgMsg__c intgMsg5 =new IntgMsg__c();
            intgMsg5.Svc__c='Company Comprehensive Details';
            intgMsg5.BU__c = 'HL / STL';
            intgMsg5.MStatus__c='Blank';
            intgMsg5.Status__c = 'New';
            intgMsg5.Resp__c = '';
            intgMsg5.RefId__c = apiVersions[0].Id;
            intgMsg5.RefObj__c='APIVer__c';
            intgMsg5.Name='Company Comprehensive Details';
            intgMsg5.ParentRefObj__c ='Applicant__c';
            intgMsg5.ParentRefId__c =applicant1.Id;  
            listIntgMsg.add(intgMsg5);

            insert listIntgMsg;
            TriggerBase.clearBypass('IntgMsg__c');


            List<ContentVersion> listContVer= new List<ContentVersion>();

            ContentVersion contentVersion3 = new ContentVersion();
            contentVersion3.VersionData =blob.valueof('{"metadata":{"api_version":"1.3","last_updated":"2023-12-28"},"data":{"company":{"cin":"U14294KL2012PTC032514","legal_name":"NPM GRANITES PRIVATE LIMITED","efiling_status":"Active","incorporation_date":"2012-10-31","paid_up_capital":400000,"sum_of_charges":63340000,"authorized_capital":5000000,"active_compliance":"ACTIVE compliant","cirp_status":null,"lei":{"number":null,"status":null,"registration_date":null,"last_updated_date":null,"next_renewal_date":null},"registered_address":{"full_address":"11/165 THEKKENEDUMPLACKAL   MALLAPPALLY WEST P O, MALLAPPALLY, Kerala - 689585","address_line1":"11/165 THEKKENEDUMPLACKAL   MALLAPPALLY WEST P O","address_line2":null,"city":"MALLAPPALLY","pincode":"689585","state":"Kerala"},"business_address":{"address_line1":"Thekkenedumplackal Building,","address_line2":"Mallapally West Post","city":"Pathanamthitta","pincode":689585,"state":"Kerala"},"pan":"AAECN5625P","website":null,"classification":"Private Limited Indian Non-Government Company","status":"Unlisted","next_cin":null,"last_agm_date":"2023-09-30","last_filing_date":"2023-03-31","email":"npmgranites@gmail.com"},"description":{"desc_thousand_char":"NPM Granites"},"name_history":[],"authorized_signatories":[{"pan":"AFAPN5763Q","din":"01691518","name":"NAVEEN MATHEW PHILIP","designation":"Director","din_status":"Approved","gender":"Male","date_of_birth":"1981-11-27","age":43,"date_of_appointment":"2012-10-31","date_of_appointment_for_current_designation":"2012-10-31","date_of_cessation":null,"nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null},"association_history":[]}],"director_network":[{"name":"NAVEEN MATHEW PHILIP","pan":"AFAPN5763Q","din":"01691518","network":{"companies":[{"cin":"U14292KL2007PTC021294","legal_name":"PEEGE AGGREGATES PRIVATE LIMITED","company_status":"ACTIVE","incorporation_date":"2007-10-10","paid_up_capital":7490300,"sum_of_charges":65565000,"city":"PATHANAMTHITTA","active_compliance":"ACTIVE compliant","cirp_status":null,"designation":"Managing Director","date_of_appointment":"2007-10-10","date_of_appointment_for_current_designation":"2009-02-26","date_of_cessation":null}],"llps":[]}},{"name":"MARY PHILIP","pan":"AOIPM2532D","din":"01768546","network":{"companies":[{"cin":"U14294KL2012PTC032514","legal_name":"NPM GRANITES PRIVATE LIMITED","company_status":"ACTIVE","incorporation_date":"2012-10-31","paid_up_capital":400000,"sum_of_charges":63340000,"city":"MALLAPPALLY","active_compliance":"ACTIVE compliant","cirp_status":null,"designation":"Director","date_of_appointment":"2012-10-31","date_of_appointment_for_current_designation":"2012-10-31","date_of_cessation":"2022-12-08"}],"llps":[]}},{"name":"CLEA JOSE","pan":"APAPJ1022J","din":"06515675","network":{"companies":[{"cin":"U14292KL2007PTC021294","legal_name":"PEEGE AGGREGATES PRIVATE LIMITED","company_status":"ACTIVE","incorporation_date":"2007-10-10","paid_up_capital":7490300,"sum_of_charges":65565000,"city":"PATHANAMTHITTA","active_compliance":"ACTIVE compliant","cirp_status":null,"designation":"Director","date_of_appointment":"2022-12-08","date_of_appointment_for_current_designation":"2022-12-08","date_of_cessation":null}],"llps":[]}},{"name":"MATHEW SAJEEV","pan":"CIRPM8961K","din":"06741464","network":{"companies":[{"cin":"U14292KL2007PTC021294","legal_name":"PEEGE AGGREGATES PRIVATE LIMITED","company_status":"ACTIVE","incorporation_date":"2007-10-10","paid_up_capital":7490300,"sum_of_charges":65565000,"city":"PATHANAMTHITTA","active_compliance":"ACTIVE compliant","cirp_status":null,"designation":"Director","date_of_appointment":"2023-12-28","date_of_appointment_for_current_designation":"2023-12-28","date_of_cessation":null}],"llps":[]}},{"name":"MINU JOMY","pan":"ANSPM4504C","din":"07984143","network":{"companies":[{"cin":"U14294KL2012PTC032514","legal_name":"NPM GRANITES PRIVATE LIMITED","company_status":"ACTIVE","incorporation_date":"2012-10-31","paid_up_capital":400000,"sum_of_charges":63340000,"city":"MALLAPPALLY","active_compliance":"ACTIVE compliant","cirp_status":null,"designation":"Managing Director","date_of_appointment":"2023-12-28","date_of_appointment_for_current_designation":"2023-12-28","date_of_cessation":null}],"llps":[]}}],"contact_details":{"email":[{"emailId":"npmgranites@gmail.com","status":null}],"phone":[{"phoneNumber":"9544292777","status":null}]},"open_charges":[{"id":100159253,"date":"2018-02-22","holder_name":"SOUTH INDIAN BANK LIMITED","amount":63340000,"type":"Creation"}],"open_charges_latest_event":[{"id":100159253,"date":"2018-02-22","holder_name":"SOUTH INDIAN BANK LIMITED","amount":63340000,"type":"Creation","property_type":"Immovable property or any interest there in","number_of_chargeholder":1,"instrument_description":"Letter","rate_of_interest":"11.15","terms_of_payment":"LUMP SUM","property_particulars":"LAND","extent_and_operation":"ON COLLATERAL SECURITY OF","other_terms":null,"modification_particulars":null,"joint_holding":"NO","consortium_holding":"NO","filing_date":"2018-03-09"}],"charge_sequence":[{"charge_id":100159253,"status":"Creation","date":"2018-02-22","amount":63340000,"holder_name":"SOUTH INDIAN BANK LIMITED","number_of_holder":1,"property_type":"Immovable property or any interest there in","filing_date":"2018-03-09","property_particulars":"LAND"}],"financials":[{"year":"2023-03-31","nature":"STANDALONE","stated_on":"2023-03-31","filing_type":"PROBE","filing_standard":"Schedule III","bs":{"assets":{"tangible_assets":7485250,"producing_properties":0,"intangible_assets":0,"preproducing_properties":0,"tangible_assets_capital_work_in_progress":0,"intangible_assets_under_development":0,"noncurrent_investments":0,"deferred_tax_assets_net":0,"foreign_curr_monetary_item_trans_diff_asset_account":0,"long_term_loans_and_advances":0,"other_noncurrent_assets":0,"current_investments":0,"inventories":0,"trade_receivables":0,"cash_and_bank_balances":9500,"short_term_loans_and_advances":0,"other_current_assets":0,"given_assets_total":7494750},"liabilities":{"share_capital":400000,"reserves_and_surplus":-350750,"money_received_against_share_warrants":0,"share_application_money_pending_allotment":0,"deferred_government_grants":0,"minority_interest":0,"long_term_borrowings":0,"deferred_tax_liabilities_net":0,"foreign_curr_monetary_item_trans_diff_liability_account":0,"other_long_term_liabilities":4631500,"long_term_provisions":0,"short_term_borrowings":0,"trade_payables":0,"other_current_liabilities":2683000,"short_term_provisions":131000,"given_liabilities_total":7494750},"subTotals":{"total_equity":49250,"total_non_current_liabilities":4631500,"total_current_liabilities":2814000,"net_fixed_assets":7485250,"total_current_assets":9500,"capital_wip":0,"total_debt":0,"total_other_non_current_assets":0},"metadata":{"doc_id":"853/U14294KL2012PTC032514/mca/OtherDocumentsAttachment/c0b08af8326e13d79eb47a09d3489b80v1.pdf"},"notes":{"gross_fixed_assets":7485250,"trade_receivable_exceeding_six_months":null}},"pnl":{"lineItems":{"net_revenue":0,"total_cost_of_materials_consumed":0,"total_purchases_of_stock_in_trade":0,"total_changes_in_inventories_or_finished_goods":0,"total_employee_benefit_expense":0,"total_other_expenses":21500,"operating_profit":-21500,"other_income":0,"depreciation":0,"profit_before_interest_and_tax":-21500,"interest":0,"profit_before_tax_and_exceptional_items_before_tax":-21500,"exceptional_items_before_tax":0,"profit_before_tax":-21500,"income_tax":0,"profit_for_period_from_continuing_operations":-21500,"profit_from_discontinuing_operation_after_tax":0,"minority_interest_and_profit_from_associates_and_joint_ventures":null,"profit_after_tax":-21500},"subTotals":{"total_operating_cost":21500},"depreciation_breakup":{"depreciation":0},"metadata":{"docId":"853/U14294KL2012PTC032514/mca/OtherDocumentsAttachment/c0b08af8326e13d79eb47a09d3489b80v1.pdf"}},"cash_flow":null,"pnl_key_schedule":{"managerial_remuneration":null,"payment_to_auditors":5500,"insurance_expenses":null,"power_and_fuel":null},"auditor":{"auditor_name":"VENKITACHALAM M S","auditor_firm_name":"ABRAHAM & KURIAN","pan":"AAGFA4515J","membership_number":"201186","firm_registration_number":"006800S","address":"Chumathra Road, Muthoor Post, Thiruvalla, Kerala, India, Pin Code-689107"},"auditor_comments":{"report_has_adverse_remarks":false,"disclosures_auditor_report":[],"disclosures_director_report":[]},"auditor_additional":null}],"nbfc_financials":[],"financial_parameters":[{"year":"2023","nature":"STANDALONE","earning_fc":0,"expenditure_fc":0,"transaction_related_parties_as_18":0,"employee_benefit_expense":0,"number_of_employees":null,"prescribed_csr_expenditure":null,"total_amount_csr_spent_for_financial_year":null,"gross_fixed_assets":7485250,"trade_receivable_exceeding_six_months":null,"proposed_dividend":"No"}],"industry_segments":[{"industry":"Metals and Minerals","segments":["Mining"]}],"principal_business_activities":[],"related_party_transactions":[{"financial_year":"2023-03-31","company":[],"llp":[],"individual":[],"others":[]}],"establishments_registered_with_epfo":[],"shareholdings":[{"shareholders":"promoter","year":"2023","financial_year":"2023-03-31","category":"equity","indian_held_no_of_shares":4000,"indian_held_percentage_of_shares":100,"nri_held_no_of_shares":0,"nri_held_percentage_of_shares":0,"foreign_held_other_than_nri_no_of_shares":0,"foreign_held_other_than_nri_percentage_of_shares":0,"central_government_held_no_of_shares":0,"central_government_held_percentage_of_shares":0,"state_government_held_no_of_shares":0,"state_government_held_percentage_of_shares":0,"government_company_held_no_shares":0,"government_company_held_percentage_of_shares":0,"insurance_company_held_no_of_shares":0,"insurance_company_held_percentage_of_shares":0,"bank_held_no_of_shares":0,"bank_held_percentage_of_shares":0,"financial_institutions_held_no_of_shares":0,"financial_institutions_held_percentage_of_shares":0,"financial_institutions_investors_held_no_of_shares":0,"financial_institutions_investors_held_percentage_of_shares":0,"mutual_funds_held_no_of_shares":0,"mutual_funds_held_percentage_of_shares":0,"venture_capital_held_no_of_shares":0,"venture_capital_held_percentage_of_shares":0,"body_corporate_held_no_of_shares":0,"body_corporate_held_percentage_of_shares":0,"others_held_no_of_shares":0,"others_held_percentage_of_shares":0,"total_no_of_shares":4000,"total_percentage_of_shares":100}],"shareholdings_more_than_five_percent":[{"financial_year":"2023-03-31","company":[],"llp":[],"individual":[{"name":"NAVEEN MATHEW .","shareholding_percentage":50,"no_of_shares":2000}],"others":[]}],"shareholdings_summary":[{"year":"2023","financial_year":"2023-03-31","total_equity_shares":4000,"total_preference_shares":0,"promoter":2,"public":null,"total":2,"metadata":{"doc_id":"853/U14294KL2012PTC032514/mca/AnnualReturnsEform/e473064dffc428ec2d6d627199dc0ba8v1.pdf"}}],"director_shareholdings":[{"year":"2023","financial_year":"2023-03-31","din_pan":"06515675","full_name":"CLEA JOSE","designation":"Director","date_of_cessation":null,"no_of_shares":2000,"percentage_holding":50}],"bifr_history":[],"cdr_history":[],"defaulter_list":[],"legal_history":[],"credit_ratings":['+
            '{"rating_date": "2024-08-20","rating": "string","rating_agency": "string","type_of_loan": "string","amount": 0,"currency": "string","rating_details": ['
              +'{"rating": "string","action": "string","outlook": "string","remarks": "string"}]}'+
            '],"credit_rating_rationale":[],"unaccepted_rating":null,"holding_entities":null,"subsidiary_entities":null,"associate_entities":null,"joint_ventures":null,"securities_allotment":[],"peer_comparison":[],"gst_details":['+

            '{"gstin":"string","status":"string","companyName":"string","tradeName":"string","state":"string","stateJurisdiction":"string","centreJurisdiction":"string","dateOfRegistration":"string","taxpayerType":"string","natureOfBusinessActivities":"string","filings":[{"returnType":"string","dateOfFilling":"string","financialYear":"string","taxPeriod":"string","status":"string"}]}'+
            '],"struckoff248_details":{"struck_off_status":"As per our records","restored_status":null},"msme_supplier_payment_delays":[],"legal_cases_of_financial_disputes":[]}}');
            contentVersion3.Title = 'response.json';
            contentVersion3.PathOnClient = 'response.json';
            listContVer.add(contentVersion3);
            

            ContentVersion contentVersion4 = new ContentVersion();
            contentVersion4.VersionData =blob.valueof('{"message":"This is a Company PAN"}');
            contentVersion4.Title = 'response.json';
            contentVersion4.PathOnClient = 'response.json';


            listContVer.add(contentVersion4);

            insert listContVer;


            List<ContentVersion> listConLinks= [SELECT ContentDocumentId FROM ContentVersion LIMIT 2];
            
            Id contentDocumentId3 = listConLinks[0].ContentDocumentId;
            Id contentDocumentId4 = listConLinks[1].ContentDocumentId;
            
            ContentDocumentLink contentLink3 = new ContentDocumentLink();
            contentLink3.ContentDocumentId = contentDocumentId3;
            contentLink3.LinkedEntityId=intgMsg4.id;
            contentLink3.ShareType = 'V';
            insert contentLink3;


            ContentDocumentLink contentLink4 = new ContentDocumentLink();
            contentLink4.ContentDocumentId = contentDocumentId4;
            contentLink4.LinkedEntityId=intgMsg5.id;
            contentLink4.ShareType = 'V';

            insert contentLink4;

            List<IntgMsg__c> responses3 =new List<IntgMsg__c>{intgMsg4};
            List<IntgMsg__c> responses4 =new List<IntgMsg__c>{intgMsg5};




           //

        
        Test.startTest();

        ComCompreDtlsResponseProcessor.process(responses3);
        ComCompreDtlsResponseProcessor.process(responses4);
        Test.StopTest();
    }
    
    
    
     @isTest
    static void testProcessSuccess1() {

            LoanAppl__c loanApplication = TestDataFactory.createLoanApplication(true);
            Applicant__c applicant1 =  TestDataFactory.createSingleApplicant(true,loanApplication.id); 
        	applicant1.PAN__c='AAAFQ4251B';
        applicant1.FName__c='ANIL RAI GUPTA';
        applicant1.ApplType__c ='D';
        update applicant1;
        
        List<Applicant__c> liAppls=new List<Applicant__c>();
Applicant__c appl1=new Applicant__c();
appl1.PAN__c='ADTPG8791J';
appl1.LoanAppln__c=loanApplication.Id;
appl1.FName__c='Example One';
appl1.Gender__c='M';
appl1.ApplType__c='D';
appl1.DOB__c=Date.newInstance(2001, 8, 13);
appl1.Age__c=27;
liAppls.add(appl1);


Applicant__c appl2=new Applicant__c();
appl2.PAN__c='AAECN5625P';
appl2.LoanAppln__c=loanApplication.Id;
appl2.FName__c='Abcd Efgh';
appl2.Gender__c='M';
appl2.ApplType__c='D';
appl2.DOB__c=Date.newInstance(2000, 8, 13);
appl2.Age__c=26;
liAppls.add(appl2);

insert liAppls;
System.debug('Applicant 1 PAN: ' + appl1.PAN__c);
System.debug('Applicant 2 PAN: ' + appl2.PAN__c);
            List<IntgMsg__c> listIntgMsg= new List<IntgMsg__c>();
            
            List<APIVer__c> apiVersions = new List<APIVer__c>();
                APIVer__c apiVer = new APIVer__c(Appl__c = applicant1.Id,IsLatest__c = true,RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId(),Type__c='Probe Basic LLP',IntegrationStatus__c = 'Success',LoanAplcn__c=loanApplication.Id);
                APIVer__c apiVer1 = new APIVer__c(Appl__c = appl1.Id,IsLatest__c = true,RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId(),Type__c='Probe Basic LLP',IntegrationStatus__c = 'Success',LoanAplcn__c=loanApplication.Id);
        		APIVer__c apiVer2 = new APIVer__c(Appl__c = appl2.Id,IsLatest__c = true,RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId(),Type__c='Probe Basic LLP',IntegrationStatus__c = 'Success',LoanAplcn__c=loanApplication.Id);
                apiVersions.add(apiVer1);
        apiVersions.add(apiVer);
        apiVersions.add(apiVer2);
            
            insert apiVersions;
List<Applicant__c> existingAppWIthPans = [SELECT Id,name,PAN__c,LoanAppln__c, FName__c, Gender__c, ApplType__c,DOB__c,Age__c,Nationality__c from Applicant__c where PAN__c =: appl2.PAN__c AND ApplType__c ='D' AND LoanAppln__c =: loanApplication.Id];
    System.debug('existingAppWIthPans test=='+existingAppWIthPans);       
            TriggerBase.bypass('IntgMsg__c');
            IntgMsg__c intgMsg4 =new IntgMsg__c();
            intgMsg4.Svc__c='LLP Comprehensive Details';
            intgMsg4.BU__c = 'HL / STL';
            intgMsg4.MStatus__c='Blank';
            intgMsg4.Status__c = 'New';
            intgMsg4.Resp__c = '';
            intgMsg4.RefId__c = appl1.Id;
            intgMsg4.RefObj__c='Applicant__c';
            intgMsg4.Name='LLP Comprehensive Details';
            intgMsg4.ParentRefObj__c ='LoanAppl__c';
            intgMsg4.ParentRefId__c =loanApplication.Id; 
            listIntgMsg.add(intgMsg4);

            IntgMsg__c intgMsg5 =new IntgMsg__c();
            intgMsg5.Svc__c='LLP Comprehensive Details';
            intgMsg5.BU__c = 'HL / STL';
            intgMsg5.MStatus__c='Blank';
            intgMsg5.Status__c = 'New';
            intgMsg5.Resp__c = '';
            intgMsg5.RefId__c = appl2.Id;
            intgMsg5.RefObj__c='Applicant__c';
            intgMsg5.Name='LLP Comprehensive Details';
            intgMsg5.ParentRefObj__c ='LoanAppl__c';
            intgMsg5.ParentRefId__c =loanApplication.Id; 
            listIntgMsg.add(intgMsg5);

   
        
        
            insert listIntgMsg;
            TriggerBase.clearBypass('IntgMsg__c');


            List<ContentVersion> listContVer= new List<ContentVersion>();

            ContentVersion contentVersion3 = new ContentVersion();
         contentVersion3.VersionData =blob.valueof('{"metadata":{"api_version":"1.3","last_updated":"2023-12-28"},"data":{"company":{"cin":"U14294KL2012PTC032514","legal_name":"NPM GRANITES PRIVATE LIMITED","efiling_status":"Active","incorporation_date":"2012-10-31","paid_up_capital":400000,"sum_of_charges":63340000,"authorized_capital":5000000,"active_compliance":"ACTIVE compliant","cirp_status":null,"lei":{"number":null,"status":null,"registration_date":null,"last_updated_date":null,"next_renewal_date":null},"registered_address":{"full_address":"11/165 THEKKENEDUMPLACKAL   MALLAPPALLY WEST P O, MALLAPPALLY, Kerala - 689585","address_line1":"11/165 THEKKENEDUMPLACKAL   MALLAPPALLY WEST P O","address_line2":null,"city":"MALLAPPALLY","pincode":"689585","state":"Kerala"},"business_address":{"address_line1":"Thekkenedumplackal Building,","address_line2":"Mallapally West Post","city":"Pathanamthitta","pincode":689585,"state":"Kerala"},"pan":"AAECN5625P","website":null,"classification":"Private Limited Indian Non-Government Company","status":"Unlisted","next_cin":null,"last_agm_date":"2023-09-30","last_filing_date":"2023-03-31","email":"npmgranites@gmail.com"},"description":{"desc_thousand_char":"NPM Granites"},"name_history":[],"authorized_signatories":[{"pan":"AFAPN5763Q","din":"01691518","name":"NAVEEN MATHEW PHILIP","designation":"Director","din_status":"Approved","gender":"Male","date_of_birth":"1981-11-27","age":43,"date_of_appointment":"2012-10-31","date_of_appointment_for_current_designation":"2012-10-31","date_of_cessation":null,"nationality":"India","dsc_status":null,"dsc_expiry_date":null,"father_name":null,"address":{"address_line1":null,"address_line2":null,"city":null,"state":null,"pincode":null,"country":null},"association_history":[]}],"director_network":[{"name":"NAVEEN MATHEW PHILIP","pan":"AFAPN5763Q","din":"01691518","network":{"companies":[{"cin":"U14292KL2007PTC021294","legal_name":"PEEGE AGGREGATES PRIVATE LIMITED","company_status":"ACTIVE","incorporation_date":"2007-10-10","paid_up_capital":7490300,"sum_of_charges":65565000,"city":"PATHANAMTHITTA","active_compliance":"ACTIVE compliant","cirp_status":null,"designation":"Managing Director","date_of_appointment":"2007-10-10","date_of_appointment_for_current_designation":"2009-02-26","date_of_cessation":null}],"llps":[]}},{"name":"MARY PHILIP","pan":"AOIPM2532D","din":"01768546","network":{"companies":[{"cin":"U14294KL2012PTC032514","legal_name":"NPM GRANITES PRIVATE LIMITED","company_status":"ACTIVE","incorporation_date":"2012-10-31","paid_up_capital":400000,"sum_of_charges":63340000,"city":"MALLAPPALLY","active_compliance":"ACTIVE compliant","cirp_status":null,"designation":"Director","date_of_appointment":"2012-10-31","date_of_appointment_for_current_designation":"2012-10-31","date_of_cessation":"2022-12-08"}],"llps":[]}},{"name":"CLEA JOSE","pan":"APAPJ1022J","din":"06515675","network":{"companies":[{"cin":"U14292KL2007PTC021294","legal_name":"PEEGE AGGREGATES PRIVATE LIMITED","company_status":"ACTIVE","incorporation_date":"2007-10-10","paid_up_capital":7490300,"sum_of_charges":65565000,"city":"PATHANAMTHITTA","active_compliance":"ACTIVE compliant","cirp_status":null,"designation":"Director","date_of_appointment":"2022-12-08","date_of_appointment_for_current_designation":"2022-12-08","date_of_cessation":null}],"llps":[]}},{"name":"MATHEW SAJEEV","pan":"CIRPM8961K","din":"06741464","network":{"companies":[{"cin":"U14292KL2007PTC021294","legal_name":"PEEGE AGGREGATES PRIVATE LIMITED","company_status":"ACTIVE","incorporation_date":"2007-10-10","paid_up_capital":7490300,"sum_of_charges":65565000,"city":"PATHANAMTHITTA","active_compliance":"ACTIVE compliant","cirp_status":null,"designation":"Director","date_of_appointment":"2023-12-28","date_of_appointment_for_current_designation":"2023-12-28","date_of_cessation":null}],"llps":[]}},{"name":"MINU JOMY","pan":"ANSPM4504C","din":"07984143","network":{"companies":[{"cin":"U14294KL2012PTC032514","legal_name":"NPM GRANITES PRIVATE LIMITED","company_status":"ACTIVE","incorporation_date":"2012-10-31","paid_up_capital":400000,"sum_of_charges":63340000,"city":"MALLAPPALLY","active_compliance":"ACTIVE compliant","cirp_status":null,"designation":"Managing Director","date_of_appointment":"2023-12-28","date_of_appointment_for_current_designation":"2023-12-28","date_of_cessation":null}],"llps":[]}}],"contact_details":{"email":[{"emailId":"npmgranites@gmail.com","status":null}],"phone":[{"phoneNumber":"9544292777","status":null}]},"open_charges":[{"id":100159253,"date":"2018-02-22","holder_name":"SOUTH INDIAN BANK LIMITED","amount":63340000,"type":"Creation"}],"open_charges_latest_event":[{"id":100159253,"date":"2018-02-22","holder_name":"SOUTH INDIAN BANK LIMITED","amount":63340000,"type":"Creation","property_type":"Immovable property or any interest there in","number_of_chargeholder":1,"instrument_description":"Letter","rate_of_interest":"11.15","terms_of_payment":"LUMP SUM","property_particulars":"LAND","extent_and_operation":"ON COLLATERAL SECURITY OF","other_terms":null,"modification_particulars":null,"joint_holding":"NO","consortium_holding":"NO","filing_date":"2018-03-09"}],"charge_sequence":[{"charge_id":100159253,"status":"Creation","date":"2018-02-22","amount":63340000,"holder_name":"SOUTH INDIAN BANK LIMITED","number_of_holder":1,"property_type":"Immovable property or any interest there in","filing_date":"2018-03-09","property_particulars":"LAND"}],"financials":[{"year":"2023-03-31","nature":"STANDALONE","stated_on":"2023-03-31","filing_type":"PROBE","filing_standard":"Schedule III","bs":{"assets":{"tangible_assets":7485250,"producing_properties":0,"intangible_assets":0,"preproducing_properties":0,"tangible_assets_capital_work_in_progress":0,"intangible_assets_under_development":0,"noncurrent_investments":0,"deferred_tax_assets_net":0,"foreign_curr_monetary_item_trans_diff_asset_account":0,"long_term_loans_and_advances":0,"other_noncurrent_assets":0,"current_investments":0,"inventories":0,"trade_receivables":0,"cash_and_bank_balances":9500,"short_term_loans_and_advances":0,"other_current_assets":0,"given_assets_total":7494750},"liabilities":{"share_capital":400000,"reserves_and_surplus":-350750,"money_received_against_share_warrants":0,"share_application_money_pending_allotment":0,"deferred_government_grants":0,"minority_interest":0,"long_term_borrowings":0,"deferred_tax_liabilities_net":0,"foreign_curr_monetary_item_trans_diff_liability_account":0,"other_long_term_liabilities":4631500,"long_term_provisions":0,"short_term_borrowings":0,"trade_payables":0,"other_current_liabilities":2683000,"short_term_provisions":131000,"given_liabilities_total":7494750},"subTotals":{"total_equity":49250,"total_non_current_liabilities":4631500,"total_current_liabilities":2814000,"net_fixed_assets":7485250,"total_current_assets":9500,"capital_wip":0,"total_debt":0,"total_other_non_current_assets":0},"metadata":{"doc_id":"853/U14294KL2012PTC032514/mca/OtherDocumentsAttachment/c0b08af8326e13d79eb47a09d3489b80v1.pdf"},"notes":{"gross_fixed_assets":7485250,"trade_receivable_exceeding_six_months":null}},"pnl":{"lineItems":{"net_revenue":0,"total_cost_of_materials_consumed":0,"total_purchases_of_stock_in_trade":0,"total_changes_in_inventories_or_finished_goods":0,"total_employee_benefit_expense":0,"total_other_expenses":21500,"operating_profit":-21500,"other_income":0,"depreciation":0,"profit_before_interest_and_tax":-21500,"interest":0,"profit_before_tax_and_exceptional_items_before_tax":-21500,"exceptional_items_before_tax":0,"profit_before_tax":-21500,"income_tax":0,"profit_for_period_from_continuing_operations":-21500,"profit_from_discontinuing_operation_after_tax":0,"minority_interest_and_profit_from_associates_and_joint_ventures":null,"profit_after_tax":-21500},"subTotals":{"total_operating_cost":21500},"depreciation_breakup":{"depreciation":0},"metadata":{"docId":"853/U14294KL2012PTC032514/mca/OtherDocumentsAttachment/c0b08af8326e13d79eb47a09d3489b80v1.pdf"}},"cash_flow":null,"pnl_key_schedule":{"managerial_remuneration":null,"payment_to_auditors":5500,"insurance_expenses":null,"power_and_fuel":null},"auditor":{"auditor_name":"VENKITACHALAM M S","auditor_firm_name":"ABRAHAM & KURIAN","pan":"AAGFA4515J","membership_number":"201186","firm_registration_number":"006800S","address":"Chumathra Road, Muthoor Post, Thiruvalla, Kerala, India, Pin Code-689107"},"auditor_comments":{"report_has_adverse_remarks":false,"disclosures_auditor_report":[],"disclosures_director_report":[]},"auditor_additional":null}],"nbfc_financials":[],"financial_parameters":[{"year":"2023","nature":"STANDALONE","earning_fc":0,"expenditure_fc":0,"transaction_related_parties_as_18":0,"employee_benefit_expense":0,"number_of_employees":null,"prescribed_csr_expenditure":null,"total_amount_csr_spent_for_financial_year":null,"gross_fixed_assets":7485250,"trade_receivable_exceeding_six_months":null,"proposed_dividend":"No"}],"industry_segments":[{"industry":"Metals and Minerals","segments":["Mining"]}],"principal_business_activities":[],"related_party_transactions":[{"financial_year":"2023-03-31","company":[],"llp":[],"individual":[],"others":[]}],"establishments_registered_with_epfo":[],"shareholdings":[{"shareholders":"promoter","year":"2023","financial_year":"2023-03-31","category":"equity","indian_held_no_of_shares":4000,"indian_held_percentage_of_shares":100,"nri_held_no_of_shares":0,"nri_held_percentage_of_shares":0,"foreign_held_other_than_nri_no_of_shares":0,"foreign_held_other_than_nri_percentage_of_shares":0,"central_government_held_no_of_shares":0,"central_government_held_percentage_of_shares":0,"state_government_held_no_of_shares":0,"state_government_held_percentage_of_shares":0,"government_company_held_no_shares":0,"government_company_held_percentage_of_shares":0,"insurance_company_held_no_of_shares":0,"insurance_company_held_percentage_of_shares":0,"bank_held_no_of_shares":0,"bank_held_percentage_of_shares":0,"financial_institutions_held_no_of_shares":0,"financial_institutions_held_percentage_of_shares":0,"financial_institutions_investors_held_no_of_shares":0,"financial_institutions_investors_held_percentage_of_shares":0,"mutual_funds_held_no_of_shares":0,"mutual_funds_held_percentage_of_shares":0,"venture_capital_held_no_of_shares":0,"venture_capital_held_percentage_of_shares":0,"body_corporate_held_no_of_shares":0,"body_corporate_held_percentage_of_shares":0,"others_held_no_of_shares":0,"others_held_percentage_of_shares":0,"total_no_of_shares":4000,"total_percentage_of_shares":100}],"shareholdings_more_than_five_percent":[{"financial_year":"2023-03-31","company":[],"llp":[],"individual":[{"name":"NAVEEN MATHEW .","shareholding_percentage":50,"no_of_shares":2000}],"others":[]}],"shareholdings_summary":[{"year":"2023","financial_year":"2023-03-31","total_equity_shares":4000,"total_preference_shares":0,"promoter":2,"public":null,"total":2,"metadata":{"doc_id":"853/U14294KL2012PTC032514/mca/AnnualReturnsEform/e473064dffc428ec2d6d627199dc0ba8v1.pdf"}}],"director_shareholdings":[{"year":"2023","financial_year":"2023-03-31","din_pan":"06515675","full_name":"CLEA JOSE","designation":"Director","date_of_cessation":null,"no_of_shares":2000,"percentage_holding":50}],"bifr_history":[],"cdr_history":[],"defaulter_list":[],"legal_history":[],"credit_ratings":['+
            '{"rating_date": "2024-08-20","rating": "string","rating_agency": "string","type_of_loan": "string","amount": 0,"currency": "string","rating_details": ['
              +'{"rating": "string","action": "string","outlook": "string","remarks": "string"}]}'+
            '],"credit_rating_rationale":[],"unaccepted_rating":null,"holding_entities":null,"subsidiary_entities":null,"associate_entities":null,"joint_ventures":null,"securities_allotment":[],"peer_comparison":[],"gst_details":['+

            '{"gstin":"string","status":"string","companyName":"string","tradeName":"string","state":"string","stateJurisdiction":"string","centreJurisdiction":"string","dateOfRegistration":"string","taxpayerType":"string","natureOfBusinessActivities":"string","filings":[{"returnType":"string","dateOfFilling":"string","financialYear":"string","taxPeriod":"string","status":"string"}]}'+
            '],"struckoff248_details":{"struck_off_status":"As per our records","restored_status":null},"msme_supplier_payment_delays":[],"legal_cases_of_financial_disputes":[]}}');
                
        
        contentVersion3.Title = 'response.json';
            contentVersion3.PathOnClient = 'response.json';
            listContVer.add(contentVersion3);
            

            ContentVersion contentVersion4 = new ContentVersion();
            contentVersion4.VersionData =blob.valueof('{"message":"This is a Company PAN"}');
            contentVersion4.Title = 'response.json';
            contentVersion4.PathOnClient = 'response.json';


            listContVer.add(contentVersion4);

            insert listContVer;


            List<ContentVersion> listConLinks= [SELECT ContentDocumentId FROM ContentVersion LIMIT 2];
            
            Id contentDocumentId3 = listConLinks[0].ContentDocumentId;
            Id contentDocumentId4 = listConLinks[1].ContentDocumentId;
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
        
        
            insert listConVerLn;

            List<IntgMsg__c> responses3 =new List<IntgMsg__c>{intgMsg4};
            List<IntgMsg__c> responses4 =new List<IntgMsg__c>{intgMsg5};




           //

        
        Test.startTest();

        ComBaseDtlsResponseProcessor.process(responses3);
        ComBaseDtlsResponseProcessor.process(responses4);
        Test.StopTest();
    }

    

    

}