@isTest
Public class EmailResponseProcessorTest {
    
    @TestSetup 
    Public static void inserEmailResponse(){
      LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
      Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id);  
      //appli.AadharSeeding__c = 'Tet';
      ApplAddr__c applAdress = TestDataFactory.applAddData(true,loanApp.Id,appli.Id);
        
    }
    
    @isTest
    Public static void testEmailResponseProcessor(){
     List<LoanAppl__c> LoanAppList = [SELECT Id From LoanAppl__c Limit 1];
     List<Applicant__c> AppList = [SELECT Id From Applicant__c Limit 1];   
     List<ApplAddr__c> AppAddressList = [SELECT Id From ApplAddr__c Limit 1];
     String jsonResponse = '{"request_id":"123","status-code":"200","result":{"meta":{"params":{"email":"test@example.com"}},"data":{"disposable":false,"webmail":true,"result":true,"accept_all":false,"smtp_check":true,"regexp":false,"mx_records":true,"email":"test@example.com"}}}';

     List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'Pan Validation', AppList[0].id, jsonResponse);
     EmailResponseProcessor.process(intMsglist);   
     

         
    }
    
    

   /* @isTest
    static void testEmailResponseProcessor() {
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        
        ApplAddr__c appladdres = new ApplAddr__c();
        appladdres.AddrTyp__c = 'Permanent Address';
        appladdres.Applicant__c = appli.Id;
        insert appladdres;
       
        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();
        
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'DRIVER\'S LICENSE AUTHENTICATION';
        newlit.BU__c = GlobalConstants.INT_MSG_BU_TYPE;
        newlit.Svc__c = GlobalConstants.INT_CONFIG_SERVICE_PAN_PROFILE_DETAILED;
        newlit.BU__c = GlobalConstants.INT_MSG_BU_TYPE;
        newlit.Resp__c = '{"request_id":"123","status-code":"200","result":{"meta":{"params":{"email":"test@example.com"}},"data":{"disposable":false,"webmail":true,"result":true,"accept_all":false,"smtp_check":true,"regexp":false,"mx_records":true,"email":"test@example.com"}}}';
        newlit.IsActive__c = true;
        newlit.RefId__c = appli.Id;
        newlit.Status__c = 'New';
        newlit.MStatus__c = 'Blank';
        newlit.RefObj__c = 'Applicant__c'; 
        newlit.Trigger_Platform_Event__c=true;
        insert newlit;
        intMsglist.add(newlit);
        
       
        // Act
        Test.startTest();
        EmailResponseProcessor.process(intMsglist);

           Test.stopTest();
    }
    

    @isTest
    public static void testUpdateApplicant() {
 
       LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 

           
        String jsonResponse = '{"request_id":"123","status-code":"101","result":{"meta":{"params":{"email":"test@example.com"}},"data":{"disposable":false,"webmail":true,"result":true,"accept_all":false,"smtp_check":true,"regexp":false,"mx_records":true,"email":"test@example.com"}}}';
        JSONParser parser = JSON.createParser(jsonResponse);
        EmailResponseWrapper responseWrapper = new EmailResponseWrapper(parser);
        // 2. Call the updateApplicant method
        EmailResponseProcessor.updateApplicant(appli.Id, responseWrapper);      
    }


       @isTest
    static void testcreatePermanentAddressMethod() {
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        
        ApplAddr__c appladdres = new ApplAddr__c();
        appladdres.AddrTyp__c = 'Permanent Address';
        appladdres.Applicant__c = appli.Id;
        insert appladdres;
       
        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();
        
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'DRIVER\'S LICENSE AUTHENTICATION';
        newlit.BU__c = GlobalConstants.INT_MSG_BU_TYPE;
        newlit.Svc__c = GlobalConstants.INT_CONFIG_SERVICE_PAN_PROFILE_DETAILED;
        newlit.BU__c = GlobalConstants.INT_MSG_BU_TYPE;
        newlit.Resp__c = '{"request_id":"123","status-code":"200","result":{"meta":{"params":{"email":"test@example.com"}},"data":{"disposable":false,"webmail":true,"result":true,"accept_all":false,"smtp_check":true,"regexp":false,"mx_records":true,"email":"test@example.com"}}}';
        newlit.IsActive__c = true;
        newlit.RefId__c = appli.Id;
        newlit.Status__c = 'New';
        newlit.MStatus__c = 'Blank';
        newlit.RefObj__c = 'Applicant__c'; 
        newlit.Trigger_Platform_Event__c=true;
        insert newlit;
        intMsglist.add(newlit);
        
       
        // Act
       Test.startTest(); 
         
        String jsonResponse = '{"request_id":"123","status-code":"200","result":{"meta":{"params":{"email":"test@example.com"}},"data":{"disposable":false,"webmail":true,"result":true,"accept_all":false,"smtp_check":true,"regexp":false,"mx_records":true,"email":"test@example.com"}}}';
         JSONParser parser = JSON.createParser(jsonResponse);
     
        EmailResponseWrapper responseWrapper = new EmailResponseWrapper(parser);
         EmailResponseProcessor.createPermanentAddressMethod(responseWrapper,  appli.Id);
       Test.stopTest();
    }*/
}