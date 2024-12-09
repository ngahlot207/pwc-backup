@isTest
public class AadharVaultTest {

    @isTest
   public static void testGenerateMethod() {
        
       LoanAppl__c la=new LoanAppl__c();
       la.ChannelName__c='test';
       
       TriggerBase.bypass('LoanAppl__c');
       insert la;
       TriggerBase.clearBypass('LoanAppl__c');
       
       Applicant__c ap=new Applicant__c();
       ap.LoanAppln__c=la.id;
       
       TriggerBase.bypass('Applicant__c');
       insert ap;
       TriggerBase.clearBypass('Applicant__c');
       
       ApplKyc__c ak=new ApplKyc__c();
       ak.Applicant__c=ap.id;
       ak.kycDoc__c='Aadhaar';
       ak.AadharEncripted__c='492515815873';
       insert ak;
       
        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='Aadhar Vault';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='ApplKyc__c';
        intgMsg.RefId__c = ak.Id;
        intgMsg.Resp__c = '{"RESPONSE": {"STATUS": "1", "UUID": "TestUUID"}}';
       insert intgMsg;

       
       string json='{"RESPONSE": {"STATUS": "1", "UUID": "123456", "ERRORMSG": null}}';
        
        AadharVaultResponseWrapper wrapper=AadharVaultResponseWrapper.parser(json);
       
       
        List<IntgMsg__c> msgs = new List<IntgMsg__c>{intgMsg};
        AadharVaultRequestGenerator generator = new AadharVaultRequestGenerator();
        generator.generate(msgs, 'SFDC Aadhar Vault', 'Async');
       
       List<IntgMsg__c> responses = new List<IntgMsg__c>{intgMsg};
        AadharVaultResponseProcessor.process(responses);
        
       // IntgMsg__c updatedMsg = [SELECT Id, Req__c, Status__c FROM IntgMsg__c WHERE Id = :intgMsg.Id];
       // ApplKyc__c updMsg = [SELECT Id, UUID_Error__c FROM ApplKyc__c WHERE Id = :ak.Id];
       
    }
}