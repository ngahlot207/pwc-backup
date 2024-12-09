@isTest
public class UcidAccessTokenResponseProcessorTest {
    @testsetup
    static void testDataMethod(){
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loan.id); 
    }
    
    @isTest
    public static void testGenerateMethod() {
        List<IntgMsg__c> lstIntMsglist = new  List<IntgMsg__c>();
        List<LoanAppl__c> loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        List<Applicant__c> lstapp  =[SELECT Id FROM Applicant__c LIMIT 1];
        
        String json = '{' +
            '"access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0MTc2NzEsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6ImM2OTczYmY0LWYwZDYtNGMzNy04MGNhLTZiZmRmODhhZjczMiIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXX0.N5lju8qOI6E8r9rytpgeh0ZP6F6Y6NbBSUYn-Tty6E0",' +
            '"token_type": "bearer",' +
            '"refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0Mzg5NzEsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjBhZmEyODEyLTZjYTAtNDMwMy1iODE1LTAwYWE3OWUyMTUyMSIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXSwiYXRpIjoiYzY5NzNiZjQtZjBkNi00YzM3LTgwY2EtNmJmZGY4OGFmNzMyIn0.XiFuzMsyGAReCZIWHD81jAUePgQDjnu51n1KBRyKw8Q",' +
            '"expires_in": 299,' +
            '"scope": "read write trust",' +
            '"jti": "c6973bf4-f0d6-4c37-80ca-6bfdf88af732",' +
            '"error": "invalid_token",' +
            '"error_description": "Access token expired: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0MTYzOTQsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjljNzQ2NDBmLWIzMTYtNDkzMy04ZDI3LTdjOWQwYzRkMDdmYSIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXX0.hWnVRkm-wqvwKb6GlfuV_QLaBZ9nXeWRAFdHo4UKIyE"' +
            '}';
        
        List<IntgMsg__c> intMsglist1 =  TestDataFactory.createIntMsg(true, 'KYC OCR', loan[0].id, json);
        for(IntgMsg__c intmes : intMsglist1){
            intmes.RefObj__c = 'LoanAppl__c';
            lstIntMsglist.add(intmes);
        }
        UcidAccessTokenResponseProcessor.process(lstIntMsglist);
    }
    
    @isTest
    public static void testUcidResponse1() {
        List<IntgMsg__c> lstIntMsglist = new  List<IntgMsg__c>();
        List<Applicant__c> lstapp  =[SELECT Id FROM Applicant__c LIMIT 1];
        List<LoanAppl__c> loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        String json = '{' +
            '"access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0MTc2NzEsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6ImM2OTczYmY0LWYwZDYtNGMzNy04MGNhLTZiZmRmODhhZjczMiIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXX0.N5lju8qOI6E8r9rytpgeh0ZP6F6Y6NbBSUYn-Tty6E0",' +
            '"token_type": "bearer",' +
            '"refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0Mzg5NzEsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjBhZmEyODEyLTZjYTAtNDMwMy1iODE1LTAwYWE3OWUyMTUyMSIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXSwiYXRpIjoiYzY5NzNiZjQtZjBkNi00YzM3LTgwY2EtNmJmZGY4OGFmNzMyIn0.XiFuzMsyGAReCZIWHD81jAUePgQDjnu51n1KBRyKw8Q",' +
            '"expires_in": 299,' +
            '"scope": "read write trust",' +
            '"jti": "c6973bf4-f0d6-4c37-80ca-6bfdf88af732",' +
            '"error": "invalid_token",' +
            '"error_description": "Access token expired: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0MTYzOTQsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjljNzQ2NDBmLWIzMTYtNDkzMy04ZDI3LTdjOWQwYzRkMDdmYSIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXX0.hWnVRkm-wqvwKb6GlfuV_QLaBZ9nXeWRAFdHo4UKIyE"' +
            '}';
        
        List<IntgMsg__c> intMsglist1 =  TestDataFactory.createIntMsg(true, 'KYC OCR', lstapp[0].id, json);
        UcidAccessTokenResponseProcessor.process(intMsglist1);
        
    }
    
    @isTest
    static void testProcessMethod_Error() {
        
        List<IntgMsg__c> lstIntMsglist = new  List<IntgMsg__c>();
        List<Applicant__c> lstapp  =[SELECT Id FROM Applicant__c LIMIT 1];
        List<LoanAppl__c> loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        
        String json = '{' +
            '"access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0MTc2NzEsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6ImM2OTczYmY0LWYwZDYtNGMzNy04MGNhLTZiZmRmODhhZjczMiIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXX0.N5lju8qOI6E8r9rytpgeh0ZP6F6Y6NbBSUYn-Tty6E0",' +
            '"token_type": "bearer",' +
            '"refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0Mzg5NzEsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjBhZmEyODEyLTZjYTAtNDMwMy1iODE1LTAwYWE3OWUyMTUyMSIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXSwiYXRpIjoiYzY5NzNiZjQtZjBkNi00YzM3LTgwY2EtNmJmZGY4OGFmNzMyIn0.XiFuzMsyGAReCZIWHD81jAUePgQDjnu51n1KBRyKw8Q",' +
            '"expires_in": 299,' +
            '"scope": "read write trust",' +
            '"jti": "c6973bf4-f0d6-4c37-80ca-6bfdf88af732",' +
            '"error": "invalid_token",' +
            '"error_description": "Access token expired: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0MTYzOTQsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjljNzQ2NDBmLWIzMTYtNDkzMy04ZDI3LTdjOWQwYzRkMDdmYSIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXX0.hWnVRkm-wqvwKb6GlfuV_QLaBZ9nXeWRAFdHo4UKIyE"' +
            '}';
        
        List<IntgMsg__c> intMsglist2 =  TestDataFactory.createIntMsg(true, 'KYC OCR', lstapp[0].id, json);
        
        // Set the error information in the responseWrapper
        
        String jsonWithError = '{"error": "Response Error", "error_description": "Error in response"}';
        
        intMsglist2[0].Resp__c = jsonWithError;
        
        // Test the process method with an error response
        
        Test.startTest();
        try {
            UcidAccessTokenResponseProcessor.process(intMsglist2);
            // Add assertions for any expected outcomes
        } catch (Exception e) {
            
            // Assert if an exception is not expected
            System.assert(false, 'Exception not expected: ' + e.getMessage());
        }
        Test.stopTest();
    }
}