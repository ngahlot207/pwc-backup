@IsTest
public class ComCompreDtlsResponseWrapperTest {

    @IsTest
    public static void testComCompreDtlsResponseWrapper() {
        // Instantiate the main class
        ComCompreDtlsResponseWrapper wrapper = new ComCompreDtlsResponseWrapper();
        wrapper.message = 'Test message';

        // Instantiate and test the nested Shareholdings class
        ComCompreDtlsResponseWrapper.Shareholdings shareholding = new ComCompreDtlsResponseWrapper.Shareholdings();
        shareholding.shareholders = 'Test Shareholder';
        shareholding.year = 2023;
        shareholding.category = 'Category A';

        // Instantiate and test the nested Company class
        ComCompreDtlsResponseWrapper.Company company = new ComCompreDtlsResponseWrapper.Company();
        company.cin = 'CIN12345';
        company.legal_name = 'Test Company';
        company.efiling_status = 'Active';

        // Instantiate and test the nested Pnl_key_schedule class
        ComCompreDtlsResponseWrapper.Pnl_key_schedule pnlKeySchedule = new ComCompreDtlsResponseWrapper.Pnl_key_schedule();
        pnlKeySchedule.managerial_remuneration = 100000;
        pnlKeySchedule.payment_to_auditors = 50000;

        // Instantiate and test the nested Email class
        ComCompreDtlsResponseWrapper.Email email = new ComCompreDtlsResponseWrapper.Email();
        email.emailId = 'test@example.com';
        email.status = 'Active';

        // Instantiate and test the nested Rating_details_Z class
        ComCompreDtlsResponseWrapper.Rating_details_Z ratingDetailsZ = new ComCompreDtlsResponseWrapper.Rating_details_Z();
        ratingDetailsZ.rating = 'AAA';
        ratingDetailsZ.type_of_loan = 'Term Loan';

        // Instantiate and test the nested Address class
        ComCompreDtlsResponseWrapper.Address address = new ComCompreDtlsResponseWrapper.Address();
        address.address_line1 = '123 Main St';
        address.address_line2 = 'Apt 4B';

        // Instantiate and test the nested Companies class
        ComCompreDtlsResponseWrapper.Companies companies = new ComCompreDtlsResponseWrapper.Companies();
        companies.cin = 'CIN67890';
        companies.legal_name = 'Another Test Company';

        // Instantiate and test the nested Llps class
        ComCompreDtlsResponseWrapper.Llps llps = new ComCompreDtlsResponseWrapper.Llps();
        llps.llpin = 'LLP12345';
        llps.legal_name = 'Test LLP';
        llps.status = 'Active';

        // Instantiate and test the nested Revenue_breakup class
        ComCompreDtlsResponseWrapper.Revenue_breakup revenueBreakup = new ComCompreDtlsResponseWrapper.Revenue_breakup();
        revenueBreakup.revenue_from_operations = 200000;
        revenueBreakup.revenue_from_interest = 50000;

        // Instantiate and test the nested Liabilities_Z class
        ComCompreDtlsResponseWrapper.Liabilities_Z liabilitiesZ = new ComCompreDtlsResponseWrapper.Liabilities_Z();
        liabilitiesZ.derivative_financial_instruments = 10000;
        liabilitiesZ.dues_of_micro_and_small_enterprises_TP = 20000;

        // Instantiate and test the nested SubTotals class
        ComCompreDtlsResponseWrapper.SubTotals subTotals = new ComCompreDtlsResponseWrapper.SubTotals();
        subTotals.total_equity = 300000;

        // Instantiate and test the nested BenchMarks class
        ComCompreDtlsResponseWrapper.BenchMarks benchMarks = new ComCompreDtlsResponseWrapper.BenchMarks();
        benchMarks.year = '2022';

        // Instantiate and test the nested Peer_comparison class
        ComCompreDtlsResponseWrapper.Peer_comparison peerComparison = new ComCompreDtlsResponseWrapper.Peer_comparison();
        peerComparison.bizIndustry = 'Technology';

        // Instantiate and test the nested Pnl class
        ComCompreDtlsResponseWrapper.Pnl pnl = new ComCompreDtlsResponseWrapper.Pnl();
        pnl.lineItems = new ComCompreDtlsResponseWrapper.LineItems();
        pnl.lineItems.net_revenue = 400000;
        pnl.lineItems.total_cost_of_materials_consumed = 150000;

        // Instantiate and test the nested Cash_flow class
        ComCompreDtlsResponseWrapper.Cash_flow cashFlow = new ComCompreDtlsResponseWrapper.Cash_flow();
        cashFlow.profit_before_tax = 100000;
        cashFlow.adjustment_for_finance_cost_and_depreciation = 5000;

        // Instantiate and test the nested Auditor class
        ComCompreDtlsResponseWrapper.Auditor auditor = new ComCompreDtlsResponseWrapper.Auditor();
        auditor.auditor_name = 'Test Auditor';
        auditor.auditor_firm_name = 'Test Auditor Firm';

        // Instantiate and test the nested SubTotals_Z class
        ComCompreDtlsResponseWrapper.SubTotals_Z subTotalsZ = new ComCompreDtlsResponseWrapper.SubTotals_Z();
        subTotalsZ.total_operating_cost = 200000;

        // Instantiate and test the nested Others_Z class
        ComCompreDtlsResponseWrapper.Others_Z othersZ = new ComCompreDtlsResponseWrapper.Others_Z();
        othersZ.legal_name = 'Test Other Entity';
        othersZ.share_holding_percentage = 25;

        // Instantiate and test the nested Bs_Z class
        ComCompreDtlsResponseWrapper.Bs_Z bsZ = new ComCompreDtlsResponseWrapper.Bs_Z();
        bsZ.assets = new ComCompreDtlsResponseWrapper.Assets_Z();
        bsZ.assets.cash_equivalents = 50000;
        bsZ.assets.bank_balance_other_than_cash = 25000;

        // Instantiate and test the nested Credit_rating_rationale class
        ComCompreDtlsResponseWrapper.Credit_rating_rationale creditRatingRationale = new ComCompreDtlsResponseWrapper.Credit_rating_rationale();
        creditRatingRationale.rating_agency = 'Test Agency';
        creditRatingRationale.financial_year = '2023';
        creditRatingRationale.doc_id = 'DOC123';

        // Instantiate and test the nested Authorized_signatories class
        ComCompreDtlsResponseWrapper.Authorized_signatories authorizedSignatories = new ComCompreDtlsResponseWrapper.Authorized_signatories();
        authorizedSignatories.pan = 'PAN12345';
        authorizedSignatories.nationality = 'Indian';
        authorizedSignatories.address = address;
        authorizedSignatories.association_history = new List<ComCompreDtlsResponseWrapper.Association_history>();
        authorizedSignatories.association_history.add(new ComCompreDtlsResponseWrapper.Association_history());
        authorizedSignatories.association_history[0].event = 'Test Event';

        // Instantiate and test the nested Liabilities class
        ComCompreDtlsResponseWrapper.Liabilities liabilities = new ComCompreDtlsResponseWrapper.Liabilities();
        liabilities.share_capital = 500000;
        liabilities.reserves_and_surplus = 200000;
        liabilities.money_received_against_share_warrants = 100000;

        // Instantiate and test the nested Network class
        ComCompreDtlsResponseWrapper.Network network = new ComCompreDtlsResponseWrapper.Network();
        network.companies = new List<ComCompreDtlsResponseWrapper.Companies>();
        network.companies.add(companies);
        network.llps = new List<ComCompreDtlsResponseWrapper.Llps>();
        network.llps.add(llps);

        // Instantiate and test the Metadata class
        ComCompreDtlsResponseWrapper.Metadata metadata = new ComCompreDtlsResponseWrapper.Metadata();
        metadata.api_version = '1.0';
        metadata.last_updated = '2023-08-21';

        // Instantiate and test the Data class and set properties
        ComCompreDtlsResponseWrapper.Data data = new ComCompreDtlsResponseWrapper.Data();
        data.company = company;
        data.description = new ComCompreDtlsResponseWrapper.Description();
        data.description.desc_thousand_char = 'Company Description';

        // Set data and metadata in the wrapper
        wrapper.data = data;
        wrapper.metadata = metadata;

        // Assertions to ensure values are correctly set
        System.assertEquals('Test message', wrapper.message);
        System.assertEquals('Test Company', wrapper.data.company.legal_name);
        System.assertEquals('AAA', ratingDetailsZ.rating);
        System.assertEquals('123 Main St', address.address_line1);
        System.assertEquals('CIN12345', wrapper.data.company.cin);
        System.assertEquals(100000, pnlKeySchedule.managerial_remuneration);
        System.assertEquals('Active', llps.status);
        System.assertEquals(5000, cashFlow.adjustment_for_finance_cost_and_depreciation);
    }
}