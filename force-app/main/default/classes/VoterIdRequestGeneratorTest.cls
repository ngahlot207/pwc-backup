@istest
public class VoterIdRequestGeneratorTest {
   
    
    static testmethod void AdharRequestGenTestMetho(){
        User user = [SELECT id FROM User where Profile.Name='System Administrator' AND isActive = true LIMIT 1 ];
        LoanAppl__c loanApp=TestDataFactory.createLoanApplication(true);
        Applicant__c appl=TestDataFactory.createSingleApplicant(true,loanApp.Id);
        List<IntgMsg__c> IntgMsgData=TestDataFactory.createIntegrationMessage(true,appl.Id);
        //system.runAs(user){
            ApplKyc__c appKyc = new ApplKyc__c();
            appKyc.kycDoc__c = 'Voter Id';
            appKyc.Applicant__c = appl.id;
            appKyc.VotIdEpicNo__c = 'CEEPM6433B';     
            insert appKyc;
            IntgMsg__c amessRec=new IntgMsg__c(id=IntgMsgData[0].id, ParentRefId__c=appKyc.Id);
            if (true) {
            TriggerBase.bypass('IntgMsg__c');
            update amessRec;
            TriggerBase.clearBypass('IntgMsg__c');
            }
            
            List<IntgMsg__c> intMsglist = [SELECT id,RefId__c,ParentRefId__c FROM IntgMsg__c where Id=: amessRec.id];
            List<IntgMsg__c> intMsglist1 = [SELECT id,RefId__c,ParentRefId__c FROM IntgMsg__c where Id=: amessRec.id];

            
            try{
                TriggerBase.bypass('IntgMsg__c');
                VoterIdRequestGenerator voterIdReqGen = new VoterIdRequestGenerator();
                voterIdReqGen.generate(intMsglist,'','');
                 voterIdReqGen.generate(intMsglist1,'','');
                TriggerBase.clearBypass('IntgMsg__c');
                VoterIdRequestGenerator voterIdReqGenn = new VoterIdRequestGenerator();
                voterIdReqGenn.generate(null,'','');   
            }catch(NullPointerException ex){
                system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
            }
            
           
        
    }
    
     /*
    @testsetup
    static void AdharRequestGenTestMethod(){
        User user =  UserTestDataFactory.UserTestDataFactoryMethod('Standard User', 'DSA_user');
        system.runAs(user){
            
         LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
            
         	Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id);  
             
             ApplKyc__c appKyc = new ApplKyc__c();
            appKyc.kycDoc__c = 'Voter Id';
    		appKyc.Applicant__c = appli.id;
            appKyc.VotIdEpicNo__c = 'CEEPM6433B';     
            insert appKyc;
            
         string appId = appli.id;
            
            List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'VOTER ID AUTHENTICATION', appId, null);
            
        LoanAppl__c loanApp1 = TestDataFactory.createLoanApplication(true);
            
         Applicant__c app =  TestDataFactory.createSingleAppl(true,loanApp1.id);  
            
             ApplKyc__c appKycOne = new ApplKyc__c();
            appKycOne.kycDoc__c = 'Voter Id';
   			appKycOne.Applicant__c = app.id;
            appKycOne.VotIdEpicNo__c = 'CEEPM6433B';     
            insert appKycOne; 
       		List<IntgMsg__c> intMsglist1 =  TestDataFactory.createIntMsg(true, 'VOTER ID AUTHENTICATION', app.id, null);
            
            
        }
    }*/

}