@isTest
public class DedupeAccessTokenTest {

    
    @isTest
   public static void testGenerateMethod() {
            
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        Applicant__c ap = TestDataFactory.createSingleApplicant(true, la.Id);
       
       ApplKyc__c ak=new ApplKyc__c();
       ak.Applicant__c=ap.id;
       ak.kycDoc__c='Aadhaar';
       ak.AadharEncripted__c='492515815873';
       insert ak;
        
        DocDtl__c dd=new DocDtl__c();
        dd.Appl__c=ap.id;
        dd.Applicant_KYC__c=ak.id;
       
       
       insert dd;
       
       
        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name='Aadhar Masking';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='LoanAppl__c';
        intgMsg1.ParentRefId__c=ak.id;
        intgMsg1.ParentRefObj__c='ApplKyc__c';
        intgMsg1.RefId__c = la.Id;
        intgMsg1.Resp__c='{"access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0MTc2NzEsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6ImM2OTczYmY0LWYwZDYtNGMzNy04MGNhLTZiZmRmODhhZjczMiIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXX0.N5lju8qOI6E8r9rytpgeh0ZP6F6Y6NbBSUYn-Tty6E0","token_type": "bearer","refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0Mzg5NzEsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjBhZmEyODEyLTZjYTAtNDMwMy1iODE1LTAwYWE3OWUyMTUyMSIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXSwiYXRpIjoiYzY5NzNiZjQtZjBkNi00YzM3LTgwY2EtNmJmZGY4OGFmNzMyIn0.XiFuzMsyGAReCZIWHD81jAUePgQDjnu51n1KBRyKw8Q","expires_in": 299,"scope": "read write trust","jti": "c6973bf4-f0d6-4c37-80ca-6bfdf88af732","error": "invalid_token","error_description": "Access token expired: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0MTYzOTQsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjljNzQ2NDBmLWIzMTYtNDkzMy04ZDI3LTdjOWQwYzRkMDdmYSIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXX0.hWnVRkm-wqvwKb6GlfuV_QLaBZ9nXeWRAFdHo4UKIyE"}';

       

        IntgMsg__c intgMsg2 = new IntgMsg__c();
        intgMsg2.Name='Aadhar Masking';
        intgMsg2.BU__c='HL / STL';
        intgMsg2.Status__c='New';
        intgMsg2.MStatus__c='Blank';
        intgMsg2.RefObj__c='Applicant__c';
        intgMsg2.ParentRefId__c=ak.id;
        intgMsg2.ParentRefObj__c='ApplKyc__c';
        intgMsg2.RefId__c = ap.Id;
       intgMsg2.Resp__c='{"access_token": " ","token_type": "bearer","refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0Mzg5NzEsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjBhZmEyODEyLTZjYTAtNDMwMy1iODE1LTAwYWE3OWUyMTUyMSIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXSwiYXRpIjoiYzY5NzNiZjQtZjBkNi00YzM3LTgwY2EtNmJmZGY4OGFmNzMyIn0.XiFuzMsyGAReCZIWHD81jAUePgQDjnu51n1KBRyKw8Q","expires_in": 299,"scope": "read write trust","jti": "c6973bf4-f0d6-4c37-80ca-6bfdf88af732","error": "invalid_token","error_description": "Access token expired: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0MTYzOTQsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjljNzQ2NDBmLWIzMTYtNDkzMy04ZDI3LTdjOWQwYzRkMDdmYSIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXX0.hWnVRkm-wqvwKb6GlfuV_QLaBZ9nXeWRAFdHo4UKIyE"}';
 
       
       
       insert new List<IntgMsg__c>{intgMsg1, intgMsg2};
           
         
        List<IntgMsg__c> msgs = new List<IntgMsg__c>{intgMsg1, intgMsg2};
        DedupeAccessTokenRequestGenerator generator = new DedupeAccessTokenRequestGenerator();
        generator.generate(msgs, 'Dedupe', 'Async');
       
       DedupeAccessTokenResponseProcessor.process(msgs);
       
       String jsonString = '{"access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0MTc2NzEsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6ImM2OTczYmY0LWYwZDYtNGMzNy04MGNhLTZiZmRmODhhZjczMiIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXX0.N5lju8qOI6E8r9rytpgeh0ZP6F6Y6NbBSUYn-Tty6E0","token_type": "bearer","refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0Mzg5NzEsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjBhZmEyODEyLTZjYTAtNDMwMy1iODE1LTAwYWE3OWUyMTUyMSIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXSwiYXRpIjoiYzY5NzNiZjQtZjBkNi00YzM3LTgwY2EtNmJmZGY4OGFmNzMyIn0.XiFuzMsyGAReCZIWHD81jAUePgQDjnu51n1KBRyKw8Q","expires_in": 299,"scope": "read write trust","jti": "c6973bf4-f0d6-4c37-80ca-6bfdf88af732","error": "invalid_token","error_description": "Access token expired: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0MTYzOTQsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjljNzQ2NDBmLWIzMTYtNDkzMy04ZDI3LTdjOWQwYzRkMDdmYSIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXX0.hWnVRkm-wqvwKb6GlfuV_QLaBZ9nXeWRAFdHo4UKIyE"}';

        // Call the parse method from DedupeAccessTokenWrapper class
        DedupeAccessTokenWrapper result = DedupeAccessTokenWrapper.parse(jsonString);
       	DedupeRequestWrapper rest = DedupeRequestWrapper.parse(jsonString);
       DedupeResponseWrapper res = DedupeResponseWrapper.parse(jsonString);

   
   }
    
}




//  String jsonString = '{"access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0MTc2NzEsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6ImM2OTczYmY0LWYwZDYtNGMzNy04MGNhLTZiZmRmODhhZjczMiIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXX0.N5lju8qOI6E8r9rytpgeh0ZP6F6Y6NbBSUYn-Tty6E0","token_type": "bearer","refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0Mzg5NzEsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjBhZmEyODEyLTZjYTAtNDMwMy1iODE1LTAwYWE3OWUyMTUyMSIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXSwiYXRpIjoiYzY5NzNiZjQtZjBkNi00YzM3LTgwY2EtNmJmZGY4OGFmNzMyIn0.XiFuzMsyGAReCZIWHD81jAUePgQDjnu51n1KBRyKw8Q","expires_in": 299,"scope": "read write trust","jti": "c6973bf4-f0d6-4c37-80ca-6bfdf88af732","error": "invalid_token","error_description": "Access token expired: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTQ0MTYzOTQsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjljNzQ2NDBmLWIzMTYtNDkzMy04ZDI3LTdjOWQwYzRkMDdmYSIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXX0.hWnVRkm-wqvwKb6GlfuV_QLaBZ9nXeWRAFdHo4UKIyE"}';