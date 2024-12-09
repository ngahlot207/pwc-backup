@isTest
public class NewNACHFormTest {  
    public static LoanAppl__c loadData(){
    LoanAppl__c loanAppl = TestDataFactory.createLoanApplication(true);
        loanAppl.EMIIcludingInsurance__c = 234; 
        loanAppl.DueDay__c = '1';
        loanAppl.FirstEMIDueMonth__c='December';
        loanAppl.FirstEMIDueYear__c='2024';
        loanAppl.Repayment_Frequency__c = 'M';
        upsert loanAppl;
    return loanAppl;        
    }
    
    public static Repayment_Account__c repayAccData(Id loanApplId){
        Applicant__c appl = TestDataFactory.createSingleApplicant(true,loanApplId); 
        SFDCBANKMaster__c sfdcBankMstr = TestDataFactory.sfdcBankMasterDetails(true); 
        ApplBanking__c applBank= TestDataFactory.applBankingDetails(true,appl.Id,loanApplId,sfdcBankMstr.Id);
        applBank.AccountType__c = 'CC';
        upsert applBank;
        Repayment_Account__c rePayAcc = TestDataFactory.rePayAccData(true,loanApplId);
        rePayAcc.Applicant_Banking__c = applBank.Id;
        rePayACc.IFSC_Code__c = '12345678'; 
        repayAcc.Account_Number__c = '12345678';
        rePayAcc.Debit_Type__c = 'Maximum Amount'; 
        upsert rePayAcc;  
        return rePayAcc;
    } 
     
    @isTest
    static void testNachForm1(){ 
        LoanAppl__c loanAppl = loadData();
        Repayment_Account__c rePayAcc = repayAccData(loanAppl.Id);  
        ApplBanking__c applBank =  new ApplBanking__c(Id=rePayAcc.Applicant_Banking__c,AccountType__c = 'CURRENT');
        update applBank;  
        Test.startTest(); 
                
        // Instantiate the VF page
        PageReference pageRef = Page.NACHFormFedFina;
        Test.setCurrentPage(pageRef); 

        // Set up any necessary parameters or context variables
        pageRef.getParameters().put('recordId', rePayAcc.Id); 

        // Call the controller method (if your VF page has a controller)
        NewNACHFormClass nF = new NewNACHFormClass();
        Test.stopTest();
        List<Repayment_Account__c> RepayAccounts = [SELECT Id FROM Repayment_Account__c WHERE Loan_Application__c =:loanAppl.Id];
        system.assertEquals(1,RepayAccounts.size());

    }   
    
    @isTest
    static void testNachForm2(){ 
        LoanAppl__c loanAppl = loadData();
        loanAppl.Repayment_Frequency__c = 'Q';
        upsert loanAppl;
        Repayment_Account__c rePayAcc = repayAccData(loanAppl.Id); 
        rePayAcc.Debit_Type__c = 'Fixed Amount';
        upsert rePayAcc;
        ApplBanking__c applBank =  new ApplBanking__c(Id=rePayAcc.Applicant_Banking__c,AccountType__c = 'SAVINGS');
        update applBank;  
        
        Test.startTest();
                
        // Instantiate the VF page
        PageReference pageRef = Page.NACHFormFedFina;
        Test.setCurrentPage(pageRef); 

        // Set up any necessary parameters or context variables
        pageRef.getParameters().put('Id', rePayAcc.Id); 

        // Call the controller method (if your VF page has a controller)
        NewNACHFormClass nF = new NewNACHFormClass();
        
        Test.stopTest();
        List<Repayment_Account__c> RepayAccounts = [SELECT Id FROM Repayment_Account__c WHERE Loan_Application__c =:loanAppl.Id];
        system.assertEquals(1,RepayAccounts.size());
    }
    
    @isTest
    static void testNachForm3(){ 
        LoanAppl__c loanAppl = loadData();
        loanAppl.Repayment_Frequency__c = 'H';
        upsert loanAppl;
        Repayment_Account__c rePayAcc = repayAccData(loanAppl.Id);  
        rePayAcc.IFSC_Code__c ='';
        rePayAcc.MICR_Code__c = '123456';
        upsert rePayAcc;
        ApplBanking__c applBank =  new ApplBanking__c(Id=rePayAcc.Applicant_Banking__c,AccountType__c = 'CC');
        update applBank;  
        Test.startTest();
                
        // Instantiate the VF page
        PageReference pageRef = Page.NACHFormFedFina;
        Test.setCurrentPage(pageRef); 

        // Set up any necessary parameters or context variables
        pageRef.getParameters().put('Id', rePayAcc.Id); 

        // Call the controller method (if your VF page has a controller)
        NewNACHFormClass nF = new NewNACHFormClass();
        nF.nachID = 'test';
        nF.rupeeInWord = 'Six Hundred Only';
        Test.stopTest();
        List<Repayment_Account__c> RepayAccounts = [SELECT Id FROM Repayment_Account__c WHERE Loan_Application__c =:loanAppl.Id];
        system.assertEquals(1,RepayAccounts.size());
    }
    
    /*@isTest
    static void testNachForm4(){ 
        LoanAppl__c loanAppl = loadData();
        loanAppl.Repayment_Frequency__c = 'A';
        upsert loanAppl;
        Repayment_Account__c rePayAcc = repayAccData(loanAppl.Id); 
        ApplBanking__c applBank =  new ApplBanking__c(Id=rePayAcc.Applicant_Banking__c,AccountType__c = 'SAVINGS');
        update applBank;  
        
        Test.startTest();
                
        // Instantiate the VF page
        PageReference pageRef = Page.NACHFormFedFina;
        Test.setCurrentPage(pageRef); 

        // Set up any necessary parameters or context variables
        pageRef.getParameters().put('recordId', rePayAcc.Id); 

        // Call the controller method (if your VF page has a controller)
        NewNACHFormClass nF = new NewNACHFormClass();
        Test.stopTest();
        //List<Repayment_Account__c> RepayAccounts = [SELECT Id FROM Repayment_Account__c WHERE Loan_Application__c =:loanAppl.Id];
        //system.assertEquals(1,RepayAccounts.size());
    }*/
    
    @isTest
    static void testNachForm5(){ 
        LoanAppl__c loanAppl = loadData();
        loanAppl.Repayment_Frequency__c = 'B';
        upsert loanAppl;
        Repayment_Account__c rePayAcc = repayAccData(loanAppl.Id);
        ApplBanking__c applBank =  new ApplBanking__c(Id=rePayAcc.Applicant_Banking__c,AccountType__c = 'SAVINGS');
        update applBank; 
        
        Test.startTest(); 
                
        // Instantiate the VF page
        //PageReference pageRef = Page.NACHFormFedFina; 
        //Test.setCurrentPage(pageRef); 

        // Set up any necessary parameters or context variables
        //pageRef.getParameters().put('Id', rePayAcc.Id); 
		//pageRef.getParameters().put('recordId', null); 
        // Call the controller method (if your VF page has a controller)
        NewNACHFormClass nF = new NewNACHFormClass();
        
        Test.stopTest(); 
        List<Repayment_Account__c> RepayAccounts = [SELECT Id FROM Repayment_Account__c WHERE Loan_Application__c =:loanAppl.Id];
        system.assertEquals(1,RepayAccounts.size());
    }

}