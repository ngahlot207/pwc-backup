@isTest
public class APICalloutTrackerTest {

    @isTest
    static void testCreateApiTracker() {
        // Create test data
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loan.Id);

        IntgMsg__c intgMsg = new IntgMsg__c(
            Appl__c = applicant.Id,
            LoanAppln__c = loan.Id,
            Svc__c = 'Hunter API',
            RefId__c = loan.id,
            Name = 'Test IntgMsg',
            Status__c = 'New',
            ParentRefId__c=loan.id,
            ParentRefObj__c='LoanAppl__c'
            // Add other required fields
        );
        insert intgMsg;
        
                IntgMsg__c intgMsg1 = new IntgMsg__c(
            Appl__c = applicant.Id,
            LoanAppln__c = loan.Id,
            Svc__c = 'Hunter API',
            Name = 'Test IntgMsg',
            Status__c = 'New',
            ParentRefId__c=loan.id,
            ParentRefObj__c='LoanAppl__c'
            // Add other required fields
        );
        insert intgMsg1;
        
        APICoutTrckr__c apiTracker1 = new APICoutTrckr__c(
            APIName__c = intgMsg.Svc__c,
            RefId__c = loan.id,
            IntgMsgName__c=intgMsg.Name
            
            // Add other required fields
        );
        insert apiTracker1;

        // Call the create_ApiTracker method
        Test.startTest();
        APICalloutTracker.create_ApiTracker(new List<IntgMsg__c>{ intgMsg ,intgMsg1});
        Test.stopTest();

        // Verify the expected behavior
        APICoutTrckr__c apiTracker = [SELECT Id, APIName__c, RefId__c, APITriggerCount__c FROM APICoutTrckr__c WHERE APIName__c =:intgMsg.Svc__c AND RefId__c = :loan.id LIMIT 1];
        //System.assertNotEquals(null, apiTracker);
        //System.assertEquals(1, apiTracker.APITriggerCount__c);
    }

    @isTest
    static void testUpdateApiTracker() {
        // Create test data
        // 
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loan.Id);

        IntgMsg__c intgMsg = new IntgMsg__c(
            Appl__c = applicant.Id,
            LoanAppln__c = loan.Id,
            Svc__c = 'Hunter API',
            RefId__c = loan.id,
            Name = 'Test IntgMsg',
            Status__c = 'New'
            // Add other required fields
        );
        insert intgMsg;

        APICoutTrckr__c apiTracker = new APICoutTrckr__c(
            APIName__c = intgMsg.Svc__c,
            RefId__c = loan.id,
            IntgMsgName__c=intgMsg.Name
            // Add other required fields
        );
        insert apiTracker;

        // Call the update_ApiTracker method
        Test.startTest();
        APICalloutTracker.update_ApiTracker(intgMsg.Svc__c, loan.id, 'Success');
        Test.stopTest();

        // Verify the expected behavior
        apiTracker = [SELECT Id, LtstRespCode__c FROM APICoutTrckr__c WHERE APIName__c = :intgMsg.Svc__c AND RefId__c = :loan.id LIMIT 1];
        //System.assertNotEquals(null, apiTracker);
        //System.assertEquals('Success', apiTracker.LtstRespCode__c);
    }

    @isTest
    static void testUpdateApiTrackerWithIntMsg() {
        // Create test data
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loan.Id);

        IntgMsg__c intgMsg = new IntgMsg__c(
            Appl__c = applicant.Id,
            LoanAppln__c = loan.Id,
            Svc__c = 'Hunter API',
            RefId__c = loan.id,
            Name = 'Test IntgMsg',
            Status__c = 'New'
            // Add other required fields
        );
        insert intgMsg; // Assign the actual Id of your IntgMsg__c record

        APICoutTrckr__c apiTracker = new APICoutTrckr__c(
            APIName__c = intgMsg.Svc__c,
            RefId__c = loan.Id,
            IntgMsgName__c=intgMsg.Name
            // Add other required fields
        );
        insert apiTracker;

        // Call the update_ApiTrackerWithIntMsg method
        Test.startTest();
        APICalloutTracker.update_ApiTrackerWithIntMsg(intgMsg.Id, intgMsg.Svc__c, loan.Id, 'Success');
        APICalloutTracker.update_ApiTrackerWithIntMsg(intgMsg.Id, intgMsg.Svc__c, loan.Id, 'Failure');
        Test.stopTest();

        // Verify the expected behavior
        apiTracker = [SELECT Id, LtstRespCode__c FROM APICoutTrckr__c WHERE APIName__c = :intgMsg.Svc__c AND RefId__c = :loan.Id LIMIT 1];
        //System.assertNotEquals(null, apiTracker);
        //System.assertEquals('Success', apiTracker.LtstRespCode__c);
    }
    
    @istest
    static void  testupdate_ApiTrackerWithIntMsg(){
        //Dedupe API Token
         LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loan.Id);
        
        IntgMsg__c intgMsg = new IntgMsg__c(
            Appl__c = applicant.Id,
            LoanAppln__c = loan.Id,
            Svc__c = 'Dedupe API Token',
            RefId__c = applicant.Id,
            Name = 'Dedupe API Token',
            Status__c = 'New'
            // Add other required fields
        );
        insert intgMsg;
        
         APICoutTrckr__c apiTracker = new APICoutTrckr__c(
            APIName__c = 'Dedupe API Token',
            RefId__c = intgMsg.RefId__c,
            IntgMsgName__c=intgMsg.Name
            // Add other required fields
        ); 
        insert apiTracker;
        
        //Dedupe
         IntgMsg__c intgMsg1 = new IntgMsg__c(
            Appl__c = applicant.Id,
            LoanAppln__c = loan.Id,
            Svc__c = 'Dedupe',
            RefId__c = applicant.Id,
            Name = 'Dedupe',
            Status__c = 'New'
            // Add other required fields
        );
        insert intgMsg1;
        
        APICoutTrckr__c apiTracker1 = new APICoutTrckr__c(
            APIName__c = intgMsg1.Svc__c,
            RefId__c = intgMsg1.RefId__c,
            IntgMsgName__c=intgMsg1.Name
            // Add other required fields
        ); 
        insert apiTracker1;
        
        APICoutTrckr__c apiTracker4 = new APICoutTrckr__c(
            APIName__c = 'Hunter API',
            RefId__c = loan.Id,
            IntgMsgName__c='Hunter API',
            LtstRespCode__c='Failure',
            IsInvalid__c=false,
            Retry__c=false
           
        );
        insert apiTracker4;
        
        APICoutTrckr__c apiTracker2 = new APICoutTrckr__c(
            APIName__c = 'Hunter Token',
            RefId__c = loan.Id,
            IntgMsgName__c='Hunter Token',
            LtstRespCode__c='Failure',
            IsInvalid__c=false,
            Retry__c=false
           
        ); 
        insert apiTracker2;
        
        
        //Hunter API
        IntgMsg__c intgMsg2 = new IntgMsg__c(
            Appl__c = applicant.Id,
            LoanAppln__c = loan.Id,
            Svc__c = 'Hunter API',
            RefId__c = loan.Id,
            Name = 'Hunter API',
            Status__c = 'New'
            // Add other required fields
        );
        insert intgMsg2;
        
        
        //UCIC
        IntgMsg__c intgMsg3 = new IntgMsg__c(
            Appl__c = applicant.Id,
            LoanAppln__c = loan.Id,
            Svc__c = 'UCIC',
            RefId__c = applicant.Id,
            Name = 'UCIC',
            Status__c = 'New'
            
        );
        insert intgMsg3;
        
        APICoutTrckr__c apiTracker3 = new APICoutTrckr__c(
            APIName__c = 'Dedupe API Token',
            RefId__c = intgMsg3.RefId__c,
            IntgMsgName__c='UCIC API Token',
            LtstRespCode__c='Failure',
            IsInvalid__c=false,
            Retry__c=false
           
        ); 
        insert apiTracker3;
        
        APICoutTrckr__c apiTracker5 = new APICoutTrckr__c(
            APIName__c = 'UCIC',
            RefId__c = intgMsg3.RefId__c,
            IntgMsgName__c='UCIC',
            LtstRespCode__c='Failure',
            IsInvalid__c=false,
            Retry__c=false
           
        ); 
        insert apiTracker5;
        
        //Consumer API
        APICoutTrckr__c apiTracker6 = new APICoutTrckr__c(
            APIName__c = 'Consumer ACK Request',
            RefId__c = applicant.Id,
            ParentRefId__c=loan.Id,
            IntgMsgName__c='Consumer ACK Request',
            LtstRespCode__c='Failure',
            IsInvalid__c=false,
            Retry__c=false
           
        ); 
        insert apiTracker6;
        
        APICoutTrckr__c apiTracker7 = new APICoutTrckr__c(
            APIName__c = 'Cusomer Issue Request',
            RefId__c = applicant.Id,
            ParentRefId__c=loan.Id,
            IntgMsgName__c='Cusomer Issue Request',
            LtstRespCode__c='Failure',
            IsInvalid__c=false,
            Retry__c=false
           
        ); 
        insert apiTracker7;
		
		IntgMsg__c intgMsg4 = new IntgMsg__c(
            Appl__c = applicant.Id,
            LoanAppln__c = loan.Id,
            Svc__c = 'Cusomer Issue Request',
            RefId__c = applicant.Id,
            Name = 'Cusomer Issue Request',
            Status__c = 'New',
            ParentRefId__c=loan.Id
        );
        insert intgMsg4;
        
        
        
        //Commercial API
        APICoutTrckr__c apiTracker8 = new APICoutTrckr__c(
            APIName__c = 'Commercial ACK Request',
            RefId__c = applicant.Id,
            ParentRefId__c=loan.Id,
            IntgMsgName__c='Commercial ACK Request',
            LtstRespCode__c='Failure',
            IsInvalid__c=false,
            Retry__c=false
           
        ); 
        insert apiTracker8;
        
        APICoutTrckr__c apiTracker9 = new APICoutTrckr__c(
            APIName__c = 'Commercial Issue Request',
            RefId__c = applicant.Id,
            ParentRefId__c=loan.Id,
            IntgMsgName__c='Commercial Issue Request',
            LtstRespCode__c='Failure',
            IsInvalid__c=false,
            Retry__c=false
           
        ); 
        insert apiTracker9;
		
		IntgMsg__c intgMsg5 = new IntgMsg__c(
            Appl__c = applicant.Id,
            LoanAppln__c = loan.Id,
            Svc__c = 'Commercial Issue Request',
            RefId__c = applicant.Id,
            Name = 'Commercial Issue Request',
            Status__c = 'New',
            ParentRefId__c=loan.Id
        );
        insert intgMsg5;
        
        //update_ApiTrackerWithIntMsg(Id intmsgid,string code,List<ApiTrackerWrapper> apiTrackerRecords)
        APICalloutTracker.ApiTrackerWrapper apiTrack = new APICalloutTracker.ApiTrackerWrapper();
        apiTrack.intMsgName =apiTracker9.IntgMsgName__c;
        apiTrack.apiName =apiTracker9.APIName__c;
        apiTrack.refId =apiTracker9.RefId__c;
        apiTrack.parentRefId =apiTracker9.ParentRefId__c;
        apiTrack.statusCode ='Success';
        List<APICalloutTracker.ApiTrackerWrapper> apiList =new List<APICalloutTracker.ApiTrackerWrapper>{apiTrack};
            
        Test.starttest();
        APICalloutTracker.update_ApiTrackerWithIntMsg(intgMsg.id,intgMsg.Svc__c,intgMsg.RefId__c,'Failure');
        APICalloutTracker.update_ApiTrackerWithIntMsg(intgMsg1.id,intgMsg1.Svc__c,intgMsg1.RefId__c,'Failure');
        APICalloutTracker.update_ApiTrackerWithIntMsg(intgMsg2.id,intgMsg2.Svc__c,intgMsg2.RefId__c,'Failure');
        APICalloutTracker.update_ApiTrackerWithIntMsg(intgMsg3.id,intgMsg3.Svc__c,intgMsg3.RefId__c,'Failure');
        APICalloutTracker.update_ApiTrackerWithIntMsg(intgMsg4.id,intgMsg4.Svc__c,intgMsg4.RefId__c,'Failure');
        APICalloutTracker.update_ApiTrackerWithIntMsg(intgMsg5.id,intgMsg5.Svc__c,intgMsg5.RefId__c,'Failure');
        APICalloutTracker.update_ApiTrackerWithIntMsg(intgMsg5.id,'Success',apiList);
        Test.stopTest();
    }
    
    
    
}