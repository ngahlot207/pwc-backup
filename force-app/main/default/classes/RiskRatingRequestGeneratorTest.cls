@isTest
public class RiskRatingRequestGeneratorTest {
    
    @isTest
    public static void testGenerateMethod() {
        
       List<RecordType> listAPIVer=[select Id ,name from RecordType where name ='Risk Rating' and SobjectType ='APIVer__c'];
        
        
       LoanAppl__c la=new LoanAppl__c();
       la.ChannelName__c='test';
        
       //la.RecordTypeId=listAPIVer[0].ID; 
       insert la;
       
       Applicant__c ap=new Applicant__c();
       ap.LoanAppln__c=la.id;
      // ap.Constitution__c='HUF';
       ap.FName__c='Test Fname';
       ap.MobNumber__c='999999999'; 
       ap.EmailId__c='abcd@gmail.com'; 
       ap.Constitution__c = 'INDIVIDUAL'; 
       insert ap;
       List<ApplKyc__c> li=new List<ApplKyc__c>();
        
       ApplKyc__c ak=new ApplKyc__c();
       ak.Applicant__c=ap.id;
       ak.kycDoc__c='Aadhaar';
       ak.AadharEncripted__c='492515815873';
       //insert ak;
       li.add(ak); 
       ApplKyc__c ak1=new ApplKyc__c();
       ak1.Applicant__c=ap.id;
       ak1.kycDoc__c='Passport';
       ak1.PassExpDt__c =Date.newInstance(2025, 12, 9); 
       ak1.AadharEncripted__c='492515815873'; 
       ak1.PassNo__c='54321'; 
       li.add(ak1); 
        
       ApplKyc__c ak2=new ApplKyc__c();
       ak2.Applicant__c=ap.id;
       ak2.kycDoc__c='Voter Id';
       ak2.VotIdEpicNo__c='492515815873';
       li.add(ak2);
       
        
       ApplKyc__c ak3=new ApplKyc__c();
       ak3.Applicant__c=ap.id;
       ak3.kycDoc__c='Driving License';
       ak3.DLNo__c='492515815873';
       li.add(ak3);
        
       ApplKyc__c ak4=new ApplKyc__c();
       ak4.Applicant__c=ap.id;
       ak4.kycDoc__c='Pan';
       ak4.Pan__c='49253';
       li.add(ak4); 
       
       
        
        
       //insert ak1;
       //System.debug('ap::::'+ap);
       insert li; 
        
       
       ApplAddr__c addApp=TestDataFactory.applAddData(true,la.Id,ap.Id); 
       
       
      
        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name='Risk API';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='Applicant__c';
        intgMsg1.ParentRefId__c=la.id;
        intgMsg1.ParentRefObj__c='LoanAppl__c';
        intgMsg1.RefId__c = ap.Id;
       
       

        
       insert new List<IntgMsg__c>{intgMsg1};
           
        
        List<IntgMsg__c> msgs = new List<IntgMsg__c>{intgMsg1};
        RiskRatingRequestGenerator generator = new RiskRatingRequestGenerator();
        generator.generate(msgs, 'Risk API', 'Async');
        
        

 
        
        
    }
    
}