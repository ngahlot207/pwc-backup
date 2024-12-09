@isTest
public class APIGatewayServiceTest {
    @isTest
    static void  TestHandler(){
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c Applicant=TestDataFactory.createSingleApplicant(true,loan.id);
        ApplAddr__c ApplicantAddress =TestDataFactory.applAddData(true,loan.id,Applicant.Id);
        
        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='CompositePaymentRequestGenerator';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='LoanAppl__c';
        intgMsg.ParentRefId__c = loan.id;
        //intgMsg.RefId__c = Applicant.Id;
        intgMsg.Svc__c = 'Consumer ACK Request';
        intgMsg.ApiVendor__c = 'karza';
        intgMsg.Resp__c = '{"AccountAnalysis":[{"accountNo":"50200007224952","accountType":"","complete":true,"institutionId":20,"missingMonths":["2023-11","2023-12"]}]}';
        intgMsg.Req__c = '{"Payload":{"payload":{"password":"","fileId":"4f3ee786b9611f28a8b055fff87f3f12485f818a"}},"Header":{"transactionID":"6YPT1706786719181","sha256Content":"1d26f8348133aa631031a4be69529bcbda50db4f7bdc738ca387a22ca47e3f4b","perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"7aedc08894f19adb8c6793b6be2905236fc227472ab7437006ad6c4536c0432b861b7bccd1f6fe44e4e8f70667b619281d5dc7841f5cc46b7f22c4071f124f5159ad476ca5ddbcf3faa75005c7f14e97c121d9085e28aa59809e4f410293a32574732b70da5a597a93601ae6100cf5e098e096c6444463318baf1f5b3b67abe3026b6ef4c90c9d4a3c803d6e235287b6a528ab77e0ab4b5cb0c3cc3c78bdd21cb1dc0e87b52464d2390252d969f4744f1b88c96bec0bdc298377477c183d037c63a235d21d23c3ee302eb26436924869a092c0e23ecd8e75c8ac84f742835acf6aff0cae5a6415d0279edf1988bfe02c456a02250b008bbace60bbc571db2ecd1fdfd38580b6ded53a15f8f0c9d96d59e47f777ce7eb5b3a30abdbead75795334325da26fe7d1aa419c690efed6362c15e43fa9973e6e31e20e9ac7a64833b05f1cb478fd6a0a9bcc1e7174798881cc99dfea5894116ff652264b3564531996ddce548cccdd1870908638c2558df7052fbacd63056e78a0842121052e03ebc0c715e5f6861dbcea78777374fb6d3ce29ca1de873dac37d94e279c71408289f9018fdaa4f7292421f7f69a9f41e3a627ed9da156b6f4b7a06f42b63f85cbe162aa67e099b6dd3014bb131e89eedf9e4dbacef72e80031b24942c4f9488f8cd26971416b455654877bb88b69fa0611e9570b56ce0cc1226630d3bcbcb721d8d9ab","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20240201T165523Z","fileId":null}}';
        intgMsg.Trigger_Platform_Event__c=true;
        insert intgMsg;
        
        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.ParentRefId__c = intgMsg.id;
        intgMsg1.Status__c='New';
        TriggerBase.bypass('IntgMsg__c');
        insert intgMsg1;
        TriggerBase.clearBypass('IntgMsg__c'); 
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMock1());
        
        list<Id> intgMsgId = new list<Id>{intgMsg.id};
            APIGatewayService.post( intgMsgId );
        APIGatewayService.getAuthorizationToken(intgMsg1.id,intgMsg.Svc__c);
        APIGatewayService.getAuthorizationToken(intgMsg1.id,'Dedupe');
        APIGatewayService.getAuthorizationToken(intgMsg1.id,'Hunter API');
        APIGatewayService.getAuthorizationToken(intgMsg1.id,'Crif Execute API');
        /////
        APIGatewayService.postSvc(intgMsg.id);
        APIGatewayService.postSvc(createIntegrationMessage('ICICI PennyDrop', 'HL / STL', 'ICICI PennyDrop',true,'New', null,'',null,'','ICICI').Id);
        APIGatewayService.postSvc(createIntegrationMessage('Test', 'HL / STL', 'ICICI PennyDrop',true,'New', null,'',null,'','Signdesk').Id);
        APIGatewayService.postSvc(createIntegrationMessage('Dedupe API Token', 'HL / STL', 'Dedupe API Token',true,'New', null,'',null,'','FedENPA').Id);
        APIGatewayService.postSvc(createIntegrationMessage('Hunter Token', 'HL / STL', 'Hunter Token',true,'New', null,'',null,'','Experian').Id);
        APIGatewayService.postSvc(createIntegrationMessage('Hunter API', 'HL / STL', 'Hunter API',true,'New', null,'',null,'','Experian').Id);
        APIGatewayService.postSvc(createIntegrationMessage('Dedupe', 'HL / STL', 'Dedupe',true,'New', null,'',null,'','Leobrix').Id);
        APIGatewayService.postSvc(createIntegrationMessage('Crif Execute API', 'HL / STL', 'Crif Execute API',true,'New', null,'',null,'','Crif').Id);
        APIGatewayService.postSvc(createIntegrationMessage('ScreeningWachout', 'HL / STL', 'ScreeningWachout',true,'New', null,'',null,'','WatchoutInvestor').Id);
        APIGatewayService.postSvc(createIntegrationMessage('Initiate Transaction', 'HL / STL', 'Initiate Transaction',true,'New', null,'',null,'','Perfios').Id);
        APIGatewayService.postSvc(createIntegrationMessage('Upload Files', 'HL / STL', 'Upload Files',true,'New', null,'',null,'','Perfios').Id);
        APIGatewayService.postSvc(createIntegrationMessage('Process Files', 'HL / STL', 'Process Files',true,'New', null,'',null,'','Perfios').Id);
        APIGatewayService.postSvc(createIntegrationMessage('Report generation', 'HL / STL', 'Report generation',true,'New', null,'',null,'','Perfios').Id);
        APIGatewayService.postSvc(createIntegrationMessage('Enach', 'HL / STL', 'mandate_create_form',true,'New', null,'',null,'','Digio').Id);
        APIGatewayService.postSvc(createIntegrationMessage('Get Multi Tranch', 'HL / STL', 'Get Multi Tranch',true,'New', null,'',null,'','Internal').Id);
        APIGatewayService.postSvc(createIntegrationMessage('Commercial ACK Request', 'HL / STL', 'Commercial ACK Request',true,'New', null,'',null,'','Lentra').Id);
        APIGatewayService.postSvc(createIntegrationMessage('SFDC Aadhar Vault', 'HL / STL', 'SFDC Aadhar Vault',true,'New', null,'',null,'','Syntizen').Id);
        APIGatewayService.postSvc(createIntegrationMessage('Get HRMS Details', 'HL / STL', 'Get HRMS Details',true,'New', null,'',null,'','HRMS').Id);
        APIGatewayService.postSvc(createIntegrationMessage('LLP Comprehensive Details', 'HL / STL', 'LLP Comprehensive Details',true,'New', null,'',null,'','Probe').Id);
        APIGatewayService.postSvc(createIntegrationMessage('Create Order - GST', 'HL / STL', 'Create Order - GST',true,'New', null,'',null,'','FinFort').Id);
        APIGatewayService.postSvc(createIntegrationMessage('FinFort Auth Token - GST', 'HL / STL', 'FinFort Auth Token - GST',true,'New', null,'',null,'','FinFort').Id);
        APIGatewayService.postSvc(createIntegrationMessage('Crime Add Report API - Individual', 'HL / STL', 'Crime Add Report API - Individual',true,'New', null,'',null,'','CrimeCheck').Id);
        
        /////
        
    }
    public class HttpCalloutMock1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'content-disposition');
            res.setBody('{"mockResponseKey": "mockResponseValue"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public static IntgMsg__c createIntegrationMessage(String Name, String Bu, String Svc, Boolean isActive,String Status, String refID,String refObj,String parentRefId,String parentRefObj,String ApiVendor) {
        
		IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name = Name;
        intgMsg.BU__c = Bu;
        intgMsg.Svc__c = Svc;
        intgMsg.IsActive__c = isActive;
        intgMsg.RefId__c = refId;
        intgMsg.Status__c = Status;
        intgMsg.MStatus__c = 'Blank';
        intgMsg.RefObj__c = refObj;
        intgMsg.ApiVendor__c = ApiVendor;
        intgMsg.ParentRefId__c = parentRefId;
        intgMsg.ParentRefObj__c = parentRefObj;
        intgMsg.Resp__c = '{"AccountAnalysis":[{"accountNo":"50200007224952","accountType":"","complete":true,"institutionId":20,"missingMonths":["2023-11","2023-12"]}]}';
        intgMsg.Req__c = '{"Payload":{"payload":{"password":"","fileId":"4f3ee786b9611f28a8b055fff87f3f12485f818a"}},"Header":{"transactionID":"6YPT1706786719181","sha256Content":"1d26f8348133aa631031a4be69529bcbda50db4f7bdc738ca387a22ca47e3f4b","perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"7aedc08894f19adb8c6793b6be2905236fc227472ab7437006ad6c4536c0432b861b7bccd1f6fe44e4e8f70667b619281d5dc7841f5cc46b7f22c4071f124f5159ad476ca5ddbcf3faa75005c7f14e97c121d9085e28aa59809e4f410293a32574732b70da5a597a93601ae6100cf5e098e096c6444463318baf1f5b3b67abe3026b6ef4c90c9d4a3c803d6e235287b6a528ab77e0ab4b5cb0c3cc3c78bdd21cb1dc0e87b52464d2390252d969f4744f1b88c96bec0bdc298377477c183d037c63a235d21d23c3ee302eb26436924869a092c0e23ecd8e75c8ac84f742835acf6aff0cae5a6415d0279edf1988bfe02c456a02250b008bbace60bbc571db2ecd1fdfd38580b6ded53a15f8f0c9d96d59e47f777ce7eb5b3a30abdbead75795334325da26fe7d1aa419c690efed6362c15e43fa9973e6e31e20e9ac7a64833b05f1cb478fd6a0a9bcc1e7174798881cc99dfea5894116ff652264b3564531996ddce548cccdd1870908638c2558df7052fbacd63056e78a0842121052e03ebc0c715e5f6861dbcea78777374fb6d3ce29ca1de873dac37d94e279c71408289f9018fdaa4f7292421f7f69a9f41e3a627ed9da156b6f4b7a06f42b63f85cbe162aa67e099b6dd3014bb131e89eedf9e4dbacef72e80031b24942c4f9488f8cd26971416b455654877bb88b69fa0611e9570b56ce0cc1226630d3bcbcb721d8d9ab","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20240201T165523Z","fileId":null}}';
        TriggerBase.bypass('IntgMsg__c');
        insert intgMsg;
        TriggerBase.clearBypass('IntgMsg__c');
        
        return intgMsg;
    }
    
}