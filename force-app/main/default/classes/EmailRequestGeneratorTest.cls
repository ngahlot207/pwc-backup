@isTest
public class EmailRequestGeneratorTest {

    @isTest
    static void generateTest(){
         LoanAppl__c loan=new LoanAppl__c();
         insert loan;
         Applicant__c appt=new Applicant__c(LoanAppln__c=loan.Id,DOB__c=System.today());
         insert appt;
        ApplKyc__c apl=new ApplKyc__c(kycDoc__c='Aadhaar',Applicant__c=appt.Id,FileNo__c='123');
         insert apl;
        List<IntgMsg__c> intMsglist =new List<IntgMsg__c>();
         IntgMsg__c intmsg = New IntgMsg__c();
        intmsg.BU__c ='Vehicle Loan';
        intmsg.RefObj__c='intmsg__c';
        intmsg.RefId__c=apl.Applicant__c;
        intmsg.Status__c='New';
        intmsg.IsActive__c=true;
        intmsg.Outbound__c=false;
        intmsg.Svc__c='PAN-PROFILE';
        intmsg.MStatus__c = 'Blank';
       
       
            TriggerBase.bypass('IntgMsg__c');
             insert intmsg;
        intMsglist.add(intmsg);
            EmailRequestGenerator passReq = new EmailRequestGenerator();
            passReq.generate(intMsglist,'','');
            TriggerBase.clearBypass('IntgMsg__c');
            
    } 
}