@istest
public class HRMSAPIRequestGeneratorTest {
    @istest
    public static void testmethod1(){
        IntgMsg__c intmsg =new IntgMsg__c();
        intmsg.Name='Get HRMS Details';
        intmsg.Status__c='New';
        intmsg.MStatus__c='Blank';
        intmsg.BU__c='HL / STL';
        intmsg.Svc__c='Get HRMS Details';
        intmsg.ApiVendor__c='HRMS';
        intmsg.IsActive__c=true; 
        
        TriggerBase.bypass('IntgMsg__c');
        Insert intmsg;
        TriggerBase.clearBypass('IntgMsg__c');
        
        List<IntgMsg__c> IntgMsgList =new List<IntgMsg__c>{intmsg};
            
        Test.startTest();
        HRMSIntegrationMessage shed =new HRMSIntegrationMessage();
        shed.execute(null);
        
        HRMSAPIRequestGenerator req =new HRMSAPIRequestGenerator();
        req.generate(IntgMsgList,'Get HRMS Details','Async');
        Test.stopTest();
    }

}