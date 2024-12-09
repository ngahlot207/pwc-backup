@isTest
private class RackRateControllerTest {
    @testSetup
    static void testValidateData() {
        Lead leadRec = new Lead();
        leadRec.Customer_Profile__c = 'SALARIED';
        leadRec.Requested_loan_amount__c = 120000;
        leadRec.Product__c = 'Small Ticket LAP';
        leadRec.Product_Sub_Type__c = 'LAP Commercial';
        leadRec.IsthisAssessedIncomePrg__c = true;
        leadRec.Property_Category__c = 'CAT A';
        leadRec.Property_Identified__c = 'Yes';
        leadRec.Requested_tenure_in_Months__c = 12;
        leadRec.Branch_Code__c = 'HYC';
        leadRec.LastName = 'Test';
        TriggerBase.bypass('Lead');
        insert leadRec;
        TriggerBase.clearBypass('Lead');
        
        BankBrchMstr__c bankBrancMstr = new BankBrchMstr__c();
        bankBrancMstr.BranchTier__c = 'Tier 2';
        bankBrancMstr.BrchCode__c = 'HYC';
        TriggerBase.bypass('BankBrchMstr__c');
        insert bankBrancMstr;
        TriggerBase.clearBypass('BankBrchMstr__c');
        
        List<MasterData__c> rackRateMstrList = new List<MasterData__c>();
        rackRateMstrList.add(new MasterData__c(
            RackRateCusProfile__c = 'Salaried Regular Income',
            Loc__c = '',
           // MaxTicketAmt__c = ,
           // MinTickerAmt__c =,
           RackRateProd__c = 'LAP Commercial',
           Prop__c ='',
            RackRate__c = 13,
            RackRateType__c = 'Customer Profile',
            Type__c = 'Rack Rate ROI',
            Product__c = 'Small Ticket LAP'
        ));
        TriggerBase.bypass('MasterData__c');
        insert rackRateMstrList;
        TriggerBase.clearBypass('MasterData__c');

    }
    @isTest
    static void testRetrieveLeadROI() {
        Lead leadRec = [SELECT Id,Requested_loan_amount__c,Product__c, Product_Sub_Type__c, Customer_Profile__c, IsthisAssessedIncomePrg__c, Property_Identified__c, Property_Category__c ,Requested_tenure_in_Months__c  FROM Lead LIMIT 1];
        // Create test data
        RackRateController.RackRateInputWrpr inputData = new RackRateController.RackRateInputWrpr();
        inputData.leadId = leadRec.Id;
        inputData.product = leadRec.Product__c;
        inputData.productSubType = leadRec.Product_Sub_Type__c;
        inputData.customerProfile = leadRec.Customer_Profile__c;
        inputData.loanAmount = leadRec.Requested_loan_amount__c;
        inputData.isAssessedIncomePrgrm = leadRec.IsthisAssessedIncomePrg__c;
        inputData.propertyIdentified = leadRec.Property_Identified__c;
        inputData.propertyCat = leadRec.Property_Category__c;

        // Insert test records if needed (e.g., RackRateMstr__c)

        // Call the method to test
        Test.startTest();
        Decimal result = RackRateController.retrieveLeadROI(inputData);
        Test.stopTest();

        // Add assertions
        System.assertEquals(0, result, 'Expected leadROI to be 0');
    }

    @isTest
    static void testRetrieveLeadROIMethod1() {
        Lead leadRec = new Lead();
        leadRec.Customer_Profile__c = 'SALARIED';
        leadRec.Requested_loan_amount__c = 120000;
        leadRec.Product__c = 'Small Ticket LAP';
        leadRec.Product_Sub_Type__c = 'LAP Commercial';
        leadRec.IsthisAssessedIncomePrg__c = false;
        leadRec.Property_Category__c = 'CAT A';
        leadRec.Property_Identified__c = 'Yes';
        leadRec.Requested_tenure_in_Months__c = 12;
        leadRec.Branch_Code__c = 'HYC';
        leadRec.LastName = 'Test';
        TriggerBase.bypass('Lead');
        insert leadRec;
        TriggerBase.clearBypass('Lead');
        
       /* BankBrchMstr__c bankBrancMstr = new BankBrchMstr__c();
        bankBrancMstr.BranchTier__c = 'Tier 2';
        bankBrancMstr.BrchCode__c = 'HYC';
        TriggerBase.bypass('BankBrchMstr__c');
        insert bankBrancMstr;
        TriggerBase.clearBypass('BankBrchMstr__c');*/
        // Create test data
        RackRateController.RackRateInputWrpr inputData = new RackRateController.RackRateInputWrpr();
        inputData.leadId = leadRec.Id;
        inputData.product = leadRec.Product__c;
        inputData.productSubType = leadRec.Product_Sub_Type__c;
        inputData.customerProfile = leadRec.Customer_Profile__c;
        inputData.loanAmount = leadRec.Requested_loan_amount__c;
        inputData.isAssessedIncomePrgrm = leadRec.IsthisAssessedIncomePrg__c;
        inputData.propertyIdentified = leadRec.Property_Identified__c;
        inputData.propertyCat = leadRec.Property_Category__c;

        // Insert test records if needed (e.g., RackRateMstr__c)

        // Call the method to test
        Test.startTest();
        Decimal result = RackRateController.retrieveLeadROI(inputData);
        Test.stopTest();

        // Add assertions
        System.assertEquals(13, result, 'Expected leadROI to be 0');
    }

    @isTest
    static void testRetrieveLeadROIMethod2() {
        Lead leadRec = new Lead();
        leadRec.Customer_Profile__c = 'SELF EMPLOYED NON PROFESSIONAL';
        leadRec.Requested_loan_amount__c = 120000;
        leadRec.Product__c = 'Small Ticket LAP';
        leadRec.Product_Sub_Type__c = 'LAP Commercial';
        leadRec.IsthisAssessedIncomePrg__c = true;
        leadRec.Property_Category__c = 'CAT A';
        leadRec.Property_Identified__c = 'Yes';
        leadRec.Requested_tenure_in_Months__c = 12;
        leadRec.Branch_Code__c = 'HYC';
        leadRec.LastName = 'Test';
        TriggerBase.bypass('Lead');
        insert leadRec;
        TriggerBase.clearBypass('Lead');
        
       /* BankBrchMstr__c bankBrancMstr = new BankBrchMstr__c();
        bankBrancMstr.BranchTier__c = 'Tier 2';
        bankBrancMstr.BrchCode__c = 'HYC';
        TriggerBase.bypass('BankBrchMstr__c');
        insert bankBrancMstr;
        TriggerBase.clearBypass('BankBrchMstr__c');*/
        // Create test data
        RackRateController.RackRateInputWrpr inputData = new RackRateController.RackRateInputWrpr();
        inputData.leadId = leadRec.Id;
        inputData.product = leadRec.Product__c;
        inputData.productSubType = leadRec.Product_Sub_Type__c;
        inputData.customerProfile = leadRec.Customer_Profile__c;
        inputData.loanAmount = leadRec.Requested_loan_amount__c;
        inputData.isAssessedIncomePrgrm = leadRec.IsthisAssessedIncomePrg__c;
        inputData.propertyIdentified = leadRec.Property_Identified__c;
        inputData.propertyCat = leadRec.Property_Category__c;

        // Insert test records if needed (e.g., RackRateMstr__c)

        // Call the method to test
        Test.startTest();
        Decimal result = RackRateController.retrieveLeadROI(inputData);
        Test.stopTest();

        // Add assertions
        System.assertEquals(0, result, 'Expected leadROI to be 0');
    }

    @isTest
    static void testRetrieveLeadROIMethod3() {
        Lead leadRec = new Lead();
        leadRec.Customer_Profile__c = 'SELF EMPLOYED NON PROFESSIONAL';
        leadRec.Requested_loan_amount__c = 120000;
        leadRec.Product__c = 'Small Ticket LAP';
        leadRec.Product_Sub_Type__c = 'LAP Commercial';
        leadRec.IsthisAssessedIncomePrg__c = false;
        leadRec.Property_Category__c = 'CAT A';
        leadRec.Property_Identified__c = 'Yes';
        leadRec.Requested_tenure_in_Months__c = 12;
        leadRec.Branch_Code__c = 'HYC';
        leadRec.LastName = 'Test';
        TriggerBase.bypass('Lead');
        insert leadRec;
        TriggerBase.clearBypass('Lead');
        
       /* BankBrchMstr__c bankBrancMstr = new BankBrchMstr__c();
        bankBrancMstr.BranchTier__c = 'Tier 2';
        bankBrancMstr.BrchCode__c = 'HYC';
        TriggerBase.bypass('BankBrchMstr__c');
        insert bankBrancMstr;
        TriggerBase.clearBypass('BankBrchMstr__c');*/
        // Create test data
        RackRateController.RackRateInputWrpr inputData = new RackRateController.RackRateInputWrpr();
        inputData.leadId = leadRec.Id;
        inputData.product = leadRec.Product__c;
        inputData.productSubType = leadRec.Product_Sub_Type__c;
        inputData.customerProfile = leadRec.Customer_Profile__c;
        inputData.loanAmount = leadRec.Requested_loan_amount__c;
        inputData.isAssessedIncomePrgrm = leadRec.IsthisAssessedIncomePrg__c;
        inputData.propertyIdentified = leadRec.Property_Identified__c;
        inputData.propertyCat = leadRec.Property_Category__c;

        // Insert test records if needed (e.g., RackRateMstr__c)

        // Call the method to test
        Test.startTest();
        Decimal result = RackRateController.retrieveLeadROI(inputData);
        Test.stopTest();

        // Add assertions
        System.assertEquals(0, result, 'Expected leadROI to be 0');
    }
}