@isTest
public class BillDeskAPITest {

    class BillDeskCalloutMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HTTPResponse response = new HTTPResponse();
            response.setStatusCode(204);
            response.setHeader('Content-Type','application/json');
            return response;
        }
    }
    
    @isTest
    static void testBillDeskPaymentGateway(){
        LoanAppl__c loanApp=TestDataFactory.createLoanApplication(true);
        ApplIMD__c applIMD = new ApplIMD__c(InstrumentAmt__c = 1000,LoanAppln__c=loanApp.Id);
        insert applIMD;
        Payment__c payment = new Payment__c(InstrumentAmt__c = 500,LoanAppl__c=loanApp.Id);
        insert payment;
        List<IntgMsg__c> intgMsgList = new List<IntgMsg__c>();
        intgMsgList.add(new IntgMsg__c(Name='Payment Gateway',Svc__c='Payment Gateway',IsActive__c=true,Status__c='New',BU__c='HL / STL',MStatus__c='Blank',RefId__c = applIMD.Id,RefObj__c = 'ApplIMD__c',Trigger_Platform_Event__c=true));
        intgMsgList.add(new IntgMsg__c(Name='Payment Gateway',Svc__c='Payment Gateway',IsActive__c=true,Status__c='New',BU__c='HL / STL',MStatus__c='Blank',RefId__c = payment.Id,RefObj__c = 'Payment__c',Trigger_Platform_Event__c=true));
        String successResponse = 'eyJhbGciOiJIUzI1NiIsImNsaWVudGlkIjoiYmR1YXR2MmswNiIsImtpZCI6IkhNQUMifQ.eyJvYmplY3RpZCI6Im9yZGVyIiwib3JkZXJpZCI6IklNMDAwMDAyMTI0OTE3MzA3MjEwMDQiLCJiZG9yZGVyaWQiOiJPQUJJMTlYVUY5REFESyIsIm1lcmNpZCI6IkJEVUFUVjJLMDYiLCJvcmRlcl9kYXRlIjoiMjAyNC0xMS0wNFQxNzoyMDowNCswNTozMCIsImFtb3VudCI6IjIzNjAiLCJjdXJyZW5jeSI6IjM1NiIsInJ1IjoiaHR0cHM6Ly9mZWRiYW5rLS1kZXYuc2FuZGJveC5teS5zYWxlc2ZvcmNlLXNpdGVzLmNvbS9CaWxsRGVzayIsImFkZGl0aW9uYWxfaW5mbyI6eyJhZGRpdGlvbmFsX2luZm8xIjoiTkEiLCJhZGRpdGlvbmFsX2luZm8yIjoiTkEiLCJhZGRpdGlvbmFsX2luZm8zIjoiTkEiLCJhZGRpdGlvbmFsX2luZm80IjoiTkEiLCJhZGRpdGlvbmFsX2luZm81IjoiTkEiLCJhZGRpdGlvbmFsX2luZm82IjoiTkEiLCJhZGRpdGlvbmFsX2luZm83IjoiTkEiLCJhZGRpdGlvbmFsX2luZm84IjoiTkEiLCJhZGRpdGlvbmFsX2luZm85IjoiTkEiLCJhZGRpdGlvbmFsX2luZm8xMCI6Ik5BIn0sIml0ZW1jb2RlIjoiRElSRUNUIiwiY3JlYXRlZG9uIjoiMjAyNC0xMS0wNFQxNzoyMDowNSswNTozMCIsIm5leHRfc3RlcCI6InJlZGlyZWN0IiwibGlua3MiOlt7ImhyZWYiOiJodHRwczovL3d3dy5iaWxsZGVzay5jb20vcGdpL3ZlMV8yL29yZGVycy9JTTAwMDAwMjEyNDkxNzMwNzIxMDA0IiwicmVsIjoic2VsZiIsIm1ldGhvZCI6IkdFVCJ9LHsiaHJlZiI6Imh0dHBzOi8vcGd1YXR3ZWIuYmlsbGRlc2suaW8vcGd0eG5zaW11bGF0b3IvdjFfMi9lbWJlZGRlZHNkayIsInJlbCI6InJlZGlyZWN0IiwibWV0aG9kIjoiUE9TVCIsInBhcmFtZXRlcnMiOnsibWVyY2lkIjoiQkRVQVRWMkswNiIsImJkb3JkZXJpZCI6Ik9BQkkxOVhVRjlEQURLIiwicmRhdGEiOiI3MjZhMDQyYzc2NmU0YjVlYTI3NjAyOTYxNDYwYjI1ZjJmMTg3MGZmOGI0ZDhlNDE1YjViY2I5NzYzMmRjOThjY2I5MjBmYjY3YzU4YjcxMTcwYzFkYTA3Y2RmZjcyODdlOTc2NTQ4NmE1MmJmN2YyMmMzMDM5OTQ3YzAxM2IwZDJhLjQxNDU1MzVmNTU0MTU0MzEifSwidmFsaWRfZGF0ZSI6IjIwMjQtMTEtMDRUMjI6MjA6MDUrMDU6MzAiLCJoZWFkZXJzIjp7ImF1dGhvcml6YXRpb24iOiJPVG9rZW4gNDQ1ZTMxZGZmNmFjNDkwOTVlYWY3OWY4NTIzZDVjZDQyZTI4MTNhZDhkNmY0MGU2NDAxOTNjYzNmNWNmNmE2YTEwZWYyMzE3ZGUzNWNmM2E1Y2RiZDA3Y2MxYzM0M2NkNzAxZGJlMDFjODQ2OTE3NzQxODM0NjZjY2Q1OGJiYTFmMDc2NThmN2Q0OWJhODM4NTNiMGMyZjUzOTRiM2MxMjU4YzY4MjFhYTIzMmMzNmY5MTJhNjk1YWUxNmRmMDViM2RhNDAxNGUzM2VlZTNkNjJlZTBhYThkMzA2ZmVlMDFmNTRhNDY3M2NjNDhkMGQ4NjkwNzY3NjVmOThjOWNlMTcwOGQ4OTM3MDZjNjdhYWNiMWJmNGM2YzNmYjg3Y2E1ODgyNjMzMzI4OTZlZDE0ZDg1NmRlYi40MTQ1NTM1ZjU1NDE1NDMxIn19XSwic3RhdHVzIjoiQUNUSVZFIn0.0C5q0mHv-H56AzuN8XFlw016ficCXJB9AgNJh5iiRbE';
        String failureResponse = 'eyJhbGciOiJIUzI1NiIsImNsaWVudGlkIjoiYmR1YXR2MmswNiIsImtpZCI6IkhNQUMifQ.eyJzdGF0dXMiOjUwMCwiZXJyb3JfdHlwZSI6ImFwaV9wcm9jZXNzaW5nX2Vycm9yIiwiZXJyb3JfY29kZSI6IkdOQVBFMDAwNCIsIm1lc3NhZ2UiOiJFcnJvciBjb25uZWN0aW5nIHRvIGludGVybmFsIEFQSSJ9.AK-Xxl0oN4hR82MGAaSWB40Yb_LwiOnwEt0x-Nbrhwg';
        Test.setMock(HttpCalloutMock.class, new BillDeskCalloutMock());
		Test.startTest();
        insert intgMsgList;
        intgMsgList[0].Status__c = 'Responded';
        intgMsgList[0].Resp__c = successResponse;
        intgMsgList[1].Status__c = 'Responded';
        intgMsgList[1].Resp__c = failureResponse;
        update intgMsgList;
        Test.stopTest();
    }
    
    @isTest
    static void testBillDeskRetrieveTransaction(){
        LoanAppl__c loanApp=TestDataFactory.createLoanApplication(true);
        ApplIMD__c applIMD = new ApplIMD__c(InstrumentAmt__c = 1000,LoanAppln__c=loanApp.Id,OrderId__c='Test1');
        insert applIMD;
        Payment__c payment = new Payment__c(InstrumentAmt__c = 500,LoanAppl__c=loanApp.Id,OrderId__c='Test2');
        insert payment;
        List<IntgMsg__c> intgMsgList = new List<IntgMsg__c>();
        intgMsgList.add(new IntgMsg__c(Name='Retrieve Transaction',Svc__c='Retrieve Transaction',IsActive__c=true,Status__c='New',BU__c='HL / STL',MStatus__c='Blank',RefId__c = applIMD.Id,RefObj__c = 'ApplIMD__c',Trigger_Platform_Event__c=true));
        intgMsgList.add(new IntgMsg__c(Name='Retrieve Transaction',Svc__c='Retrieve Transaction',IsActive__c=true,Status__c='New',BU__c='HL / STL',MStatus__c='Blank',RefId__c = payment.Id,RefObj__c = 'Payment__c',Trigger_Platform_Event__c=true));
        intgMsgList.add(new IntgMsg__c(Name='Retrieve Transaction',Svc__c='Retrieve Transaction',IsActive__c=true,Status__c='New',BU__c='HL / STL',MStatus__c='Blank',RefId__c = payment.Id,RefObj__c = 'ApplIMD__c',Trigger_Platform_Event__c=true));
        intgMsgList.add(new IntgMsg__c(Name='Retrieve Transaction',Svc__c='Retrieve Transaction',IsActive__c=true,Status__c='New',BU__c='HL / STL',MStatus__c='Blank',RefId__c = payment.Id,RefObj__c = 'Payment__c',Trigger_Platform_Event__c=true));
        String successResponse = 'eyJhbGciOiJIUzI1NiIsImNsaWVudGlkIjoiYmR1YXR2MmswNiIsImtpZCI6IkhNQUMifQ.eyJtZXJjaWQiOiJCRFVBVFYySzA2IiwidHJhbnNhY3Rpb25fZGF0ZSI6IjIwMjQtMTEtMDRUMTc6MjM6MTIrMDU6MzAiLCJzdXJjaGFyZ2UiOiIwLjAwIiwicGF5bWVudF9tZXRob2RfdHlwZSI6Im5ldGJhbmtpbmciLCJhbW91bnQiOiIyMzYwLjAwIiwicnUiOiJodHRwczovL2ZlZGJhbmstLWRldi5zYW5kYm94Lm15LnNhbGVzZm9yY2Utc2l0ZXMuY29tL0JpbGxEZXNrIiwib3JkZXJpZCI6IklNMDAwMDAyMTI0OTE3MzA3MjEwMDQiLCJ0cmFuc2FjdGlvbl9lcnJvcl90eXBlIjoic3VjY2VzcyIsImRpc2NvdW50IjoiMC4wMCIsInBheW1lbnRfY2F0ZWdvcnkiOiIwMSIsInRyYW5zYWN0aW9uaWQiOiJVMTIzWU5HMDAwMUc2WSIsInR4bl9wcm9jZXNzX3R5cGUiOiJuYiIsImJhbmtpZCI6IjEyMyIsIml0ZW1jb2RlIjoiRElSRUNUIiwidHJhbnNhY3Rpb25fZXJyb3JfY29kZSI6IlRSUzAwMDAiLCJjdXJyZW5jeSI6IjM1NiIsImF1dGhfc3RhdHVzIjoiMDMwMCIsInRyYW5zYWN0aW9uX2Vycm9yX2Rlc2MiOiJUcmFuc2FjdGlvbiBTdWNjZXNzZnVsIiwib2JqZWN0aWQiOiJ0cmFuc2FjdGlvbiIsImNoYXJnZV9hbW91bnQiOiIyMzYwLjAwIn0.3FrEpiEBz3cxmOT3AFx6MQAiYDeZrZ-MfxmC4RleCnk';
        String pendingResponse = 'eyJhbGciOiJIUzI1NiIsImNsaWVudGlkIjoiYmR1YXR2MmswNiIsImtpZCI6IkhNQUMifQ.eyJzdGF0dXMiOjQwNCwiZXJyb3JfdHlwZSI6Im5vdF9mb3VuZF9lcnJvciIsImVycm9yX2NvZGUiOiJUUk5GRTAwMDEiLCJtZXNzYWdlIjoiVHJhbnNhY3Rpb24gbm90IGZvdW5kIn0.TIh0LHADltTqanDYNVBHEWdWegbwZDHPIxaYdzstP6E';
        String failureResponse = 'eyJhbGciOiJIUzI1NiIsImNsaWVudGlkIjoiYmR1YXR2MmswNiIsImtpZCI6IkhNQUMifQ.eyJvYmplY3RpZCI6InRyYW5zYWN0aW9uIiwidHJhbnNhY3Rpb25pZCI6IlUxMjNLNzkwMDAxRzA5Iiwib3JkZXJpZCI6IklNMDAwMDAyMTIyODE3MzA3MDU1ODMiLCJtZXJjaWQiOiJCRFVBVFYySzA2IiwidHJhbnNhY3Rpb25fZGF0ZSI6IjIwMjQtMTEtMDRUMTM6MDQ6MzkrMDU6MzAiLCJhbW91bnQiOiIyMzYwLjAwIiwic3VyY2hhcmdlIjoiMC4wMCIsImRpc2NvdW50IjoiMC4wMCIsImNoYXJnZV9hbW91bnQiOiIyMzYwLjAwIiwiY3VycmVuY3kiOiIzNTYiLCJydSI6Imh0dHBzOi8vZmVkYmFuay0tZGV2LnNhbmRib3gubXkuc2FsZXNmb3JjZS1zaXRlcy5jb20vQmlsbERlc2siLCJ0eG5fcHJvY2Vzc190eXBlIjoibmIiLCJiYW5raWQiOiIxMjMiLCJpdGVtY29kZSI6IkRJUkVDVCIsImF1dGhfc3RhdHVzIjoiMDM5OSIsInRyYW5zYWN0aW9uX2Vycm9yX2NvZGUiOiJUUlBBRTAwMDEiLCJ0cmFuc2FjdGlvbl9lcnJvcl9kZXNjIjoiVHJhbnNhY3Rpb24gbm90IGF1dGhvcml6ZWQiLCJ0cmFuc2FjdGlvbl9lcnJvcl90eXBlIjoicGF5bWVudF9hdXRob3JpemF0aW9uX2Vycm9yIiwicGF5bWVudF9tZXRob2RfdHlwZSI6Im5ldGJhbmtpbmciLCJwYXltZW50X2NhdGVnb3J5IjoiMDEifQ.msbJhPe_IGjiWhB3O8qEgirHHl8-pOyVsNFfPawq3HI';
        String errorReponse = 'eyJhbGciOiJIUzI1NiIsImNsaWVudGlkIjoiYmR1YXR2MmswNiIsImtpZCI6IkhNQUMifQ.e0AibWVyY2lkIjoiQkRVQVRWMkswNiIsInRyYW5zYWN0aW9uX2RhdGUiOiIyMDI0LTExLTA0VDE3OjIzOjEyKzA1OjMwIiwic3VyY2hhcmdlIjoiMC4wMCIsInBheW1lbnRfbWV0aG9kX3R5cGUiOiJuZXRiYW5raW5nIiwiYW1vdW50IjoiMjM2MC4wMCIsInJ1IjoiaHR0cHM6Ly9mZWRiYW5rLS1kZXYuc2FuZGJveC5teS5zYWxlc2ZvcmNlLXNpdGVzLmNvbS9CaWxsRGVzayIsIm9yZGVyaWQiOiJJTTAwMDAwMjEyNDkxNzMwNzIxMDA0IiwidHJhbnNhY3Rpb25fZXJyb3JfdHlwZSI6InN1Y2Nlc3MiLCJkaXNjb3VudCI6IjAuMDAiLCJwYXltZW50X2NhdGVnb3J5IjoiMDEiLCJ0cmFuc2FjdGlvbmlkIjoiVTEyM1lORzAwMDFHNlkiLCJ0eG5fcHJvY2Vzc190eXBlIjoibmIiLCJiYW5raWQiOiIxMjMiLCJpdGVtY29kZSI6IkRJUkVDVCIsInRyYW5zYWN0aW9uX2Vycm9yX2NvZGUiOiJUUlMwMDAwIiwiY3VycmVuY3kiOiIzNTYiLCJhdXRoX3N0YXR1cyI6IjAzMDAiLCJ0cmFuc2FjdGlvbl9lcnJvcl9kZXNjIjoiVHJhbnNhY3Rpb24gU3VjY2Vzc2Z1bCIsIm9iamVjdGlkIjoidHJhbnNhY3Rpb24iLCJjaGFyZ2VfYW1vdW50IjoiMjM2MC4wMCJ9.3FrEpiEBz3cxmOT3AFx6MQAiYDeZrZ-MfxmC4RleCnk';
        Test.setMock(HttpCalloutMock.class, new BillDeskCalloutMock());
		Test.startTest();
        insert intgMsgList;
        intgMsgList[0].Status__c = 'Responded';
        intgMsgList[0].Resp__c = successResponse;
        intgMsgList[1].Status__c = 'Responded';
        intgMsgList[1].Resp__c = pendingResponse;
        intgMsgList[2].Status__c = 'Responded';
        intgMsgList[2].Resp__c = failureResponse;
        intgMsgList[3].Status__c = 'Responded';
        intgMsgList[3].Resp__c = errorReponse;
        update intgMsgList;
        Test.stopTest();
    }
}