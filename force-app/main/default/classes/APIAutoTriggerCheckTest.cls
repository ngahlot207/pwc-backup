@isTest
public class APIAutoTriggerCheckTest {
    
    @testsetup
    Public static void insertData(){
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        
        Applicant__c Applicant=TestDataFactory.createSingleApplicant(true,loan.id);
        Applicant.FName__c = '';
        TriggerBase.bypass('Applicant__c');
        Update Applicant;
        TriggerBase.clearBypass('Applicant__c'); 
        
        Applicant__c Applicant2=TestDataFactory.createSingleApplicant(true,loan.id);
        Applicant2.CompanyName__c = '';
        Applicant2.Constitution__c = 'PARTNERSHIP';
        TriggerBase.bypass('Applicant__c');
        Update Applicant2;
        TriggerBase.clearBypass('Applicant__c'); 
        
        ApplAddr__c appAddr  = TestDataFactory.applAddPermanent(true,loan.id,Applicant.Id);
        appAddr.AddrTyp__c = 'Residence Address';
        appAddr.AddrLine1__c  = 'Test';
        appAddr.AddrLine2__c = 'Test';
        appAddr.City__c = 'Pune';
        appAddr.State__c = 'Maharashtra';  
        appAddr.Pincode__c = '414111';
        TriggerBase.bypass('ApplAddr__c');
        Update appAddr;
        TriggerBase.clearBypass('ApplAddr__c'); 
        
        APICoutTrckr__c appCalloutTracker = TestDataFactory.createAPICountTrckr(True,loan.id,Applicant.Id);
        appCalloutTracker.APIName__c ='Dedupe';
        appCalloutTracker.LstSucesDtTime__c = date.today();
        TriggerBase.bypass('APICoutTrckr__c');
        Update appCalloutTracker;
        TriggerBase.clearBypass('APICoutTrckr__c');
        
        ApplKyc__c objAppKyc = new ApplKyc__c();
        objAppKyc.kycDoc__c = 'Passport';
        objAppKyc.Applicant__c = Applicant2.Id;
        objAppKyc.PassNo__c = '123';
        TriggerBase.bypass('ApplKyc__c');
        Insert objAppKyc;
        TriggerBase.clearBypass('ApplKyc__c');
        
    }
    
    @isTest
    Public static void testMethod1(){
        List<String> lstApplicantId = new List<String>();
        List<Applicant__c> lstApplicant = [SELECT ID FROM Applicant__c]; 
        system.assert(!lstApplicant.isEmpty(), 'Applicant list should not empty.');
        for(Applicant__c app : lstApplicant){
            lstApplicantId.add(app.Id);
        }
        APIAutoTriggerCheck.checkAPIToRun(lstApplicantId);
    }
    
}