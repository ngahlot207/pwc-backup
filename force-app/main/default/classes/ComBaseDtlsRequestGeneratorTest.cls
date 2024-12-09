@isTest
public class ComBaseDtlsRequestGeneratorTest {
    
    @testSetup
    static void setup() {
        
        
        LoanAppl__c loanApplication = TestDataFactory.createLoanApplication(true);
        
        Applicant__c applicant1 =  TestDataFactory.createSingleApplicant(true,loanApplication.id); 
        applicant1.PAN__c='AAAFQ4251B';
        applicant1.CIN__c = 'U12345MH2020PLC123456';
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
        appl2.CIN__c = 'U12345MH2020PLC123123';
        appl2.LoanAppln__c=loanApplication.Id;
        appl2.FName__c='Abcd Efgh';
        appl2.LLPIN__c='LLPIN - AAH-8229';
        appl2.Gender__c='M';
        appl2.ApplType__c='D';
        appl2.DOB__c=Date.newInstance(2000, 8, 13);
        appl2.Age__c=26;
        liAppls.add(appl2);
        
        insert liAppls;
        
        List<IntgMsg__c> listIntgMsg= new List<IntgMsg__c>();        
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
        
        IntgMsg__c intgMsg6 =new IntgMsg__c();
        intgMsg6.Svc__c='LLP Comprehensive Details';
        intgMsg6.BU__c = 'HL / STL';
        intgMsg6.MStatus__c='Blank';
        intgMsg6.Status__c = 'New';
        intgMsg6.Resp__c = '';
        intgMsg6.RefId__c = applicant1.Id;
        intgMsg6.RefObj__c='Applicant__c';
        intgMsg6.Name='LLP Comprehensive Details';
        intgMsg6.ParentRefObj__c ='LoanAppl__c';
        intgMsg6.ParentRefId__c =loanApplication.Id; 
        listIntgMsg.add(intgMsg6);
        
        IntgMsg__c intgMsg7 =new IntgMsg__c();
        intgMsg7.Svc__c='LLP Comprehensive Details';
        intgMsg7.BU__c = 'HL / STL';
        intgMsg7.MStatus__c='Blank';
        intgMsg7.Status__c = 'New';
        intgMsg7.Resp__c = '';
        intgMsg7.RefId__c = applicant1.Id;
        intgMsg7.RefObj__c='Applicant__c';
        intgMsg7.Name='LLP Comprehensive Details';
        intgMsg7.ParentRefObj__c ='LoanAppl__c';
        intgMsg7.ParentRefId__c =loanApplication.Id; 
        listIntgMsg.add(intgMsg7);
        
        insert listIntgMsg;
        
        
    }
    
    @isTest
    static void testGenerate() {
        // Retrieve the test data
        List<IntgMsg__c> msgs = [SELECT Id, RefId__c, Status__c FROM IntgMsg__c];
        
        // Create an instance of the class to test
        ComBaseDtlsRequestGenerator generator = new ComBaseDtlsRequestGenerator();
        
        // Call the generate method
        Test.startTest();
        generator.generate(msgs, 'APIGateway', '');
        new LlpBaseDtlsRequestGenerator().generate(msgs, 'APIGateway', '');
        new ComCompreDtlsRequestGenerator().generate(msgs, 'APIGateway', '');
        new LlpCompreDtlsRequestGenerator().generate(msgs, 'APIGateway', '');
        new CompReportRequestGenerator().generate(msgs, 'APIGateway', '');
        new LlpReportRequestGenerator().generate(msgs, 'APIGateway', '');
        new CompIncorpDocRequestGenerator().generate(msgs, 'APIGateway', '');
        new LlpIncorpDocRequestGenerator().generate(msgs, 'APIGateway', '');
        Test.stopTest();
        
    }
    
}