@isTest
public class MasterDataSyncProcessorTest {
    
    @isTest
    public static void testGenerateMethod() {
        
        IntgMsg__c intmsg =new IntgMsg__c();
        intmsg.Name='Master data Sync';
        intmsg.BU__c='HL / STL';
        intmsg.Svc__c='Master Data Sync';
        intmsg.ApiVendor__c='Fedfina';
        intmsg.Status__c='New';
        intmsg.Req__c='{"identifier":"46092012","masterbody":[{"masterDataType":"RCUAGENCYEMASTER","asyncProcessing":"false","masterData":[{"record":[{"LFAM_AGENCYCODE_C":"MANDRURAJENDRA","LFAM_AGENCYNAME_C":"MANDRU RAJENDRA","LFABPMM_PRODCODE_C":"STL","BRANCHID":"382","BRANCH":"ELURU","AUTHORID":"IT018235","AUTHORDATE":"2022-04-12T10:44:03"},{"LFAM_AGENCYCODE_C":"Test","LFAM_AGENCYNAME_C":"","LFABPMM_PRODCODE_C":"HL","BRANCHID":"370","BRANCH":"JHUNJHUNU","AUTHORID":"IT012709","AUTHORDATE":"2021-09-28T11:45:40"}]}]}]}';
        insert intmsg;
        
        List<IntgMsg__c> intmsglist=new List<IntgMsg__c>{intmsg};
            
            Test.StartTest();
        MasterDataSyncProcessor.process(intmsglist);
            Test.StopTest();
    }

}