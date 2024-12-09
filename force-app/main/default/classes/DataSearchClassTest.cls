@isTest
public class DataSearchClassTest {
    @isTest
    static void testGetRMNameDetails() {
        // Create a test user record using the TestDataFactory
        User testUser = TestDataFactory.UserData(true); // The 'true' parameter indicates to insert the user
        
        // Call the getRMNameDetails method with the test user's Id
        User resultUser = DataSearchClass.getRMNameDetails(testUser.Id);
        
        // Verify that the result matches the expected User record
        System.assertEquals(testUser.Id, resultUser.Id);
        
    }
    
    
    @isTest
    static void testGetProducts() {
        // Create a test user record using the TestDataFactory
        User testUser = TestDataFactory.UserData(true);
        
        // Create a test TeamHierarchy__c record with a valid Product_Type__c
        TeamHierarchy__c testTH = new TeamHierarchy__c(
            Employee__c = testUser.Id,
            Product_Type__c = '	Home Loan', // Assuming multiple products separated by ';'
            IsActive__c = true
        );
        insert testTH;
        
        // Call the getProducts method with the test user's Id
        List<String> resultProducts = DataSearchClass.getProducts(testUser.Id);
        
        // Verify that the result matches the expected product values
        List<String> expectedProducts = new List<String>{'Home Loan'};
            System.assertEquals(expectedProducts, resultProducts);
    }
    
    @isTest
    static void testGetProductMappings() {
        // Create test data
        String testProductType = 'Home Loan';
        String testSubType = 'Commercial Property Purchase';
        
        // Create a test ProdMap__c record with the specified product type and subtype
        // Create a test ProdMap__c record with a valid 
        ProdMap__c testTH = new ProdMap__c(
            ProdSubType__c = 'Commercial Property Purchase', // Assuming multiple products separated by ';'
            ProdType__c = 	'Home Loan'
        );
        insert testTH;
        
        // Call the getProductMappings method with the test product type
        List<String> resultSubTypes = DataSearchClass.getProductMappings(testProductType);
        
        // Verify that the result matches the expected subtypes
        List<String> expectedSubTypes = new List<String>{testSubType};
            System.assertEquals(expectedSubTypes, resultSubTypes);
    }
    
    @isTest
    static void testGetPromotions() {
        // Create test data
        String testProductType = 'Home Loan';
        String testPromotion1 = 'Promo A';
        String testPromotion2 = 'Promo B';
        
        // Create test PromoMapping__c records with the specified product type and promotions
        PromoMapping__c testPromo1 = new PromoMapping__c(
            ProductType__c = testProductType,
            PromoDesc__c = testPromotion1
        );
        insert testPromo1;
        
        PromoMapping__c testPromo2 = new PromoMapping__c(
            ProductType__c = testProductType,
            PromoDesc__c = testPromotion2
        );
        insert testPromo2;
        
        // Call the getPromotions method with the test product type
        List<String> resultPromotions = DataSearchClass.getPromotions(testProductType);
        
        // Verify that the result matches the expected promotions
        List<String> expectedPromotions = new List<String>{testPromotion1, testPromotion2};
            System.assertEquals(expectedPromotions, resultPromotions);
    }
    
    @isTest
    static void testGetData() {
        // Create test data
        String testObjectName = 'Account'; // Replace with your object name
        String testInputField = 'Name'; // Replace with your input field
        String testLikeFilter = 'Test'; // Replace with your like filter value
        String testField1 = 'Type'; // Replace with your field1 name
        String testFilter1 = 'Customer'; // Replace with your filter1 value
        String testField2 = 'Industry'; // Replace with your field2 name
        String testFilter2 = 'Finance'; // Replace with your filter2 value
        
        // Create a test Account record with the specified field values
        Account testAccount = new Account(
            Name = 'Test Account',
            Type = 'Customer',
            Industry = 'Finance'
        );
        insert testAccount;
        
        // Call the getData method with the test parameters
        List<Object> resultData = DataSearchClass.getData('Name, Type, Industry', testObjectName, testInputField, testLikeFilter, testField1, testFilter1, testField2, testFilter2);
        
        // Verify that the result contains the expected data
        System.assertEquals(1, resultData.size());
        System.assertEquals(testAccount.Id, ((SObject)resultData[0]).Id);
    }
    
    @isTest
    static void testGetChannelFromDSABranch() {
        // Create test data
        Account account = new Account(Name = 'Test Channel');
        insert account;
        DSABrchJn__c dsaBranch = new DSABrchJn__c(Account__c = account.Id);
        insert dsaBranch;
        
        // Call the method being tested
        Boolean channelFound = DataSearchClass.getChannelFromDSABranch('Test Channel');
    }
    
    @isTest
    static void testGetCityFromLocationMaster() {
        // Create test data
        LocMstr__c location = new LocMstr__c(City__c = 'Test City');
        insert location;
        
        // Call the method being tested
        Boolean cityFound = DataSearchClass.getCityFromLocationMaster('Test City');
    }
    
    @isTest
    static void testLoanApplication_PositiveTesting() {
        //Create test data create Loan Application
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        LoanAppl__c loanAppNew = DataSearchClass.getLoanApplication(loanApp.Id);
        
        // Verify that the result contains the expected data
        System.assertEquals(loanApp.Id, loanAppNew.Id);
    }
    
    @isTest
    static void testLoanApplication_NegativeTesting() {
        //Create test data create Loan Application
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        LoanAppl__c loanApp1 = TestDataFactory.createLoanApplication(true);
        LoanAppl__c loanAppNew = DataSearchClass.getLoanApplication(loanApp.Id);
        
        // Verify that the result contains the expected data
        System.assertNotEquals(loanApp1.Id, loanAppNew.Id);
    }
    
    // has to change class name from here 
    @isTest
    static void testSchemeDetails_PositiveTesting() {
        //Create test data for Scheme Mapping
        SchMapping__c sch = TestDataFactory.createSchemeMapping(true);
        SchMapping__c schNew = DataSearchClass.getSchemeDetails(sch.Id);
        
        // Verify that the result contains the expected data
        System.assertEquals(sch.Id, schNew.Id);
    } 
       
    @isTest
    static void testSchemeDetails_NegativeTesting() { 
         //Create test data for Scheme Mapping
        SchMapping__c sch = TestDataFactory.createSchemeMapping(true);
        SchMapping__c sch1 = new SchMapping__c() ;
        insert sch1;
        SchMapping__c schNew = DataSearchClass.getSchemeDetails(sch.Id);
        
        // Verify that the result contains the expected data
        System.assertNotEquals(sch1.Id, schNew.Id);
    }
    
    @isTest
    static void testAccountDetails_PositiveTesting() {
        //Create test data for Account
        Account acc = TestDataFactory.createAccountDetails(true);
        Account accNew = DataSearchClass.getAccountDetails(acc.Id);
        
        // Verify that the result contains the expected data
        System.assertEquals(acc.Id, accNew.Id);
    } 
       
    @isTest
    static void testAccountDetails_NegativeTesting() { 
         //Create test data for Account
        Account acc = TestDataFactory.createAccountDetails(true);
        Account acc1 = new Account() ;
        acc1.Name = 'Test New';
        insert acc1;
        Account accNew = DataSearchClass.getAccountDetails(acc.Id);
        
        // Verify that the result contains the expected data
        System.assertNotEquals(acc1.Id, accNew.Id);
    }
    
    @isTest
    static void testRelationShipDetails_PositiveTesting() {
        //Create test data for Loan Application
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        
        //Create test data for Account
        Relationship__c rel = TestDataFactory.createRelationShipDetails(true);
        
        // Call the method from DataSearch Apex class
        Test.startTest();
        Map<String, String> result = DataSearchClass.getRelationShipDetails(loanApp.Id,'INDIVIDUAL');
        Test.stopTest();
        
        // Verify that the result contains the expected data
        System.assertEquals(1, result.size());
        System.assertEquals(rel.Name,  result.get(rel.Key__c));
    }  
    
    @isTest
    static void testRelationShipDetails_NegativeTesting() {
        //Create test data for Loan Application
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
         
        //Create test data for Account
        Relationship__c rel = TestDataFactory.createRelationShipDetails(true);
        Relationship__c rel1 = new Relationship__c();
        insert rel1;
         
        // Call the method from DataSearch Apex class
        Test.startTest();
        Map<String, String> result = DataSearchClass.getRelationShipDetails(loanApp.Id,'INDIVIDUAL');
        Test.stopTest();
        
        // Verify that the result contains the expected data
        System.assertNotEquals(0, result.size());
        System.assertNotEquals(rel1.Name,  result.get(rel.Key__c));
    } 
    
    @isTest
    static void testAddressData_PositiveTesting() {
        //Create test data for Loan Application
        LoanAppl__c loanAppl = TestDataFactory.createLoanApplication(true);
        
        //Create test data for Applicant
        Applicant__c appl = TestDataFactory.createSingleApplicant(true,loanAppl.Id);
        
        //Create test data for Applicant Address
        //ApplAddr__c add = TestDataFactory.createAddressData(true,appl.Id);
        //system.debug('add ' + add.Applicant__c + ' & Applicant '+ appl.Id);
        
        ApplAddr__c add = new ApplAddr__c();
        add.MailAddr__c = true;
        add.Applicant__c = appl.Id;
        insert add;
        
        // Call the method from DataSearch Apex class
        Test.startTest();
        List<ApplAddr__c> result = DataSearchClass.getAddressData(loanAppl.Id);
        Test.stopTest();

        // Assert the result
        System.assertEquals(1, result.size());
        System.assertEquals(add.MailAddr__c, result[0].MailAddr__c);
    } 
    
    @isTest
    static void testAddressData_NegativeTesting() { 
        //Create test data for Loan Application
        LoanAppl__c loanAppl = TestDataFactory.createLoanApplication(true);
        
        //Create test data for Applicant
        Applicant__c appl = TestDataFactory.createSingleApplicant(true,loanAppl.Id);
        Applicant__c applNew = TestDataFactory.createSingleApplicant(true,loanAppl.Id);
        
        //Create test data for Applicant Address
        ApplAddr__c add = new ApplAddr__c();
        add.MailAddr__c = true;
        add.Applicant__c = applNew.Id;
        insert add;
        
        // Call the method from DataSearch Apex class
        Test.startTest();
        List<ApplAddr__c> result = DataSearchClass.getAddressData(loanAppl.Id);
        Test.stopTest();

        // Assert the result
        System.assertNotEquals(0, result.size());
    } 
    
    @isTest
    static void testPrinlPlaceforBCheckBox_PositiveTesting() {
        //Create test data for Loan Application
        LoanAppl__c loanAppl = TestDataFactory.createLoanApplication(true);
        
        //Create test data for Applicant
        Applicant__c appl = TestDataFactory.PrinlPlaceforBCheckBox(true,loanAppl.Id,true);
        
        // Call the method from DataSearch Apex class
        Test.startTest();
        DataSearchClass.PrinlPlaceforBCheckBox(loanAppl.Id,true);
        Test.stopTest();
        
        // Assert the result
        System.assertEquals(true, appl.Same_as_Principal_place_for_business__c);
    }
    
    @isTest
    static void testPrinlPlaceforBCheckBox_NegativeTesting() {
        //Create test data for Loan Application
        LoanAppl__c loanAppl = TestDataFactory.createLoanApplication(true);
        
        //Create test data for Applicant
        Applicant__c appl = TestDataFactory.PrinlPlaceforBCheckBox(true,loanAppl.Id,true);
        
        // Call the method from DataSearch Apex class 
        Test.startTest();
        DataSearchClass.PrinlPlaceforBCheckBox(loanAppl.Id,false);
        Test.stopTest();  
        
        // Assert the result
        System.assertNotEquals(false, appl.Same_as_Principal_place_for_business__c);
    }
    
}