@istest
public class TrackwizzCKYCCallbackResponseTest {

@istest
    public static void testGenerateMethod() {
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app = TestDataFactory.createSingleApplicant(true,la.id);
        
        List<Applicant__c> applist=[Select id,Name from Applicant__c where id=:app.Id];
        
        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name = 'Trackwizz CKYC Callback';
        intgMsg.BU__c = 'HL / STL';
        intgMsg.Status__c = 'New';
        intgMsg.MStatus__c = 'Blank';
        intgMsg.RefObj__c = '';
        intgMsg.RefId__c = '';
        intgMsg.Trigger_Platform_Event__c = true;
        intgMsg.Req__c = '<?xml version="1.0" encoding="utf-8"?><CustomerNewCKYCStatusRequest><RequestId>RequestId1</RequestId><APIToken>APIToken1</APIToken><CustomerNewCKYCStatusRequestDetails><CustomerNewCKYCStatusRequestDetail><TransactionId>'+applist[0].Name+'</TransactionId><SourceSystemName>SourceSystemName1</SourceSystemName><SourceSystemCoustomerCode>SourceSystemCoustomerCode1</SourceSystemCoustomerCode><StepCode>StepCode1</StepCode><StepName>StepName1</StepName><StepCategory>StepCategory1</StepCategory><CKYCID>CKYCID1</CKYCID><CKYCAccountType>CKYCAccountType1</CKYCAccountType><CaseURL>CaseURL1</CaseURL><CaseID>12345</CaseID></CustomerNewCKYCStatusRequestDetail><CustomerNewCKYCStatusRequestDetail><TransactionId>TransactionId2</TransactionId><SourceSystemName>SourceSystemName2</SourceSystemName><SourceSystemCoustomerCode>SourceSystemCoustomerCode2</SourceSystemCoustomerCode><StepCode>StepCode2</StepCode><StepName>StepName2</StepName><StepCategory>StepCategory2</StepCategory><CaseURL>CaseURL2</CaseURL><CaseID>1234</CaseID></CustomerNewCKYCStatusRequestDetail></CustomerNewCKYCStatusRequestDetails></CustomerNewCKYCStatusRequest>';
        insert intgMsg;
                  
        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name = 'Trackwizz CKYC Callback';
        intgMsg1.BU__c = 'HL / STL';
        intgMsg1.Status__c = 'New';
        intgMsg1.MStatus__c = 'Blank';
        intgMsg1.RefObj__c = '';
        intgMsg1.RefId__c ='';
        intgMsg1.Trigger_Platform_Event__c = true;
        intgMsg1.Req__c =''; 
        insert intgMsg1;
        
        List<IntgMsg__c> msgs = new List<IntgMsg__c>{ intgMsg };
        List<IntgMsg__c> msgs1 = new List<IntgMsg__c>{ intgMsg1 };
        string resjson='{"TransactionId":"123","SourceSystemName":"SourceSystemName1","SourceSystemCoustomerCode":"SourceSystemCoustomerCode1","StepCode":"StepCode1","StepName":"StepName1","StepCategory":"StepCategory1","CKYCID":"CKYCID1","CKYCAccountType":"CKYCAccountType1","CaseURL":"CaseURL1","CaseID":"12345"}';   
        
        Test.startTest();
            
        TrackwizzCKYCCallbackResponseProcessor.process(msgs);
        TrackwizzCKYCCallbackResponseProcessor.process(msgs1);
        TrackwizzCKYCCallbackResponseProcessor.CustomerNewCKYCStatusWrapper res = TrackwizzCKYCCallbackResponseProcessor.CustomerNewCKYCStatusWrapper.parse(resjson);

        Test.stopTest();
    }

}