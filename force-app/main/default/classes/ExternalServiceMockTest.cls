@isTest
public class ExternalServiceMockTest {
    
    @isTest
    Public static void insertData(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id);
        ApplKyc__c applKyc1 = new ApplKyc__c(kycDoc__c = 'Aadhaar', Applicant__c =appli.Id );
        TriggerBase.bypass('ApplKyc__c');
        insert applKyc1; 
        TriggerBase.clearBypass('ApplKyc__c');
        
        ApplKyc__c applKyc2 = new ApplKyc__c(kycDoc__c = 'Voter Id', Applicant__c =appli.Id );
        TriggerBase.bypass('ApplKyc__c');
        insert applKyc2;
        TriggerBase.clearBypass('ApplKyc__c');
        
        ApplKyc__c applKyc3 = new ApplKyc__c(kycDoc__c = 'Passport', Applicant__c =appli.Id );
        TriggerBase.bypass('ApplKyc__c');
        insert applKyc3;
        TriggerBase.clearBypass('ApplKyc__c');
        
        ApplKyc__c applKyc4 = new ApplKyc__c(kycDoc__c = 'Driving License', Applicant__c =appli.Id );
        TriggerBase.bypass('ApplKyc__c');
        insert applKyc4;
        TriggerBase.clearBypass('ApplKyc__c');
        
        ApplKyc__c applKyc5 = new ApplKyc__c(kycDoc__c = 'Pan', Applicant__c =appli.Id );
        TriggerBase.bypass('ApplKyc__c');
        insert applKyc5;
        TriggerBase.clearBypass('ApplKyc__c');
        
        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Status__c='New';
        intgMsg1.RefId__c=applKyc2.Id;
        intgMsg1.RefObj__c='ApplKyc__c';
        intgMsg1.Svc__c = 'KYC OCR';
        intgMsg1.ParentRefId__c = applKyc2.Id;
        TriggerBase.bypass('IntgMsg__c');
        Insert intgMsg1;
        TriggerBase.clearBypass('IntgMsg__c'); 
        
        IntgMsg__c intgMsg2 = new IntgMsg__c();
        intgMsg2.Status__c='New';
        intgMsg2.RefId__c=applKyc1.Id;
        intgMsg2.RefObj__c='ApplKyc__c';
        intgMsg2.Svc__c = 'KYC OCR';
        intgMsg2.ParentRefId__c = applKyc1.Id;
        TriggerBase.bypass('IntgMsg__c');
        Insert intgMsg2;
        TriggerBase.clearBypass('IntgMsg__c');  
        
        IntgMsg__c intgMsg3 = new IntgMsg__c();
        intgMsg3.Status__c='New';
        intgMsg3.RefId__c=applKyc3.Id;
        intgMsg3.RefObj__c='ApplKyc__c';
        intgMsg3.Svc__c = 'KYC OCR';
        intgMsg3.ParentRefId__c = applKyc3.Id;
        TriggerBase.bypass('IntgMsg__c');
        Insert intgMsg3;
        TriggerBase.clearBypass('IntgMsg__c');  
        
        IntgMsg__c intgMsg4 = new IntgMsg__c();
        intgMsg4.Status__c='New';
        intgMsg4.RefId__c=applKyc4.Id;
        intgMsg4.RefObj__c='ApplKyc__c';
        intgMsg4.Svc__c = 'KYC OCR';
        intgMsg4.ParentRefId__c = applKyc4.Id;
        TriggerBase.bypass('IntgMsg__c');
        Insert intgMsg4;
        TriggerBase.clearBypass('IntgMsg__c');  
        
        IntgMsg__c intgMsg5 = new IntgMsg__c();
        intgMsg5.Status__c='New';
        intgMsg5.RefId__c=applKyc5.Id;
        intgMsg5.RefObj__c='ApplKyc__c';
        intgMsg5.Svc__c = 'KYC OCR';
        intgMsg5.ParentRefId__c = applKyc5.Id;
        TriggerBase.bypass('IntgMsg__c');
        Insert intgMsg5;
        TriggerBase.clearBypass('IntgMsg__c'); 
        
      /*   StaticResource mockStaticResources = new StaticResource();
        mockStaticResources.Name = 'Integration_Mock';
        mockStaticResources.Body = blob.valueOf('{"Key":"Value"}');
        StaticResource static_resource = [SELECT Id, Name, SystemModStamp
                                          FROM StaticResource 
                                          WHERE Name = 'Integration_Mock'
                                          LIMIT 1];
       String serviceName = 'AADHAR';
        system.debug('static_resource:'+static_resource);
        string newServiceName = serviceName.replace(' ','_');
        String url_file_ref = '/resource/'
            + String.valueOf(((DateTime)static_resource.get('SystemModStamp')).getTime())
            + '/' 
            + static_resource.get('Name')
            + '/'+ newServiceName +'.json';
        
        PageReference file_ref = new PageReference(url_file_ref);*/
        
        List<Id> IntgMsgid1 =new List<Id>{intgMsg1.id};
        List<Id> IntgMsgid2 =new List<Id>{intgMsg2.id};
        List<Id> IntgMsgid3 =new List<Id>{intgMsg3.id};
        List<Id> IntgMsgid4 =new List<Id>{intgMsg4.id};
        List<Id> IntgMsgid5 =new List<Id>{intgMsg5.id};
                            
        Test.StartTest();
        ExternalServiceMock.postMock(IntgMsgid1);
        ExternalServiceMock.postMock(IntgMsgid2);
        ExternalServiceMock.postMock(IntgMsgid3);
        ExternalServiceMock.postMock(IntgMsgid4);
        ExternalServiceMock.postMock(IntgMsgid5);
        Test.StopTest();
        
    } 
}