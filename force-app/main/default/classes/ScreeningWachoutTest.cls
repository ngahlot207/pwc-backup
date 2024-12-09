@isTest
public class ScreeningWachoutTest{
    
    
     @testsetup
    static void testDataMethod(){
        
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
            
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loan.id); 
        
    }

    @isTest
    static void testGenerateMethod() {
       
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM  Applicant__c LIMIT 1];
        
        ApplKyc__c apl=new ApplKyc__c(kycDoc__c='Pan',Applicant__c=appli.Id,FileNo__c='123');
         insert apl;
        
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'KYC OCR', appli.id, null);
        IntgMsg__c intgMsg = new IntgMsg__c();
        
        intgMsg.ParentRefId__c=appli.id;
       
        intMsglist.add(intgMsg);  
        
        Test.startTest();
        ScreeningWachoutRequestGenerator generator= new ScreeningWachoutRequestGenerator();
        generator.generate(intMsglist, 'TestService', 'TestProcessType');
        
        String jsonresponse = '{"requestId":"8eb39778-4d34-4a75-83a3-d986ddae3aee","result":{"name":{"nameFromPassport":"SRIDEVI","surnameFromPassport":"GUNTUPALLI","nameMatch":true,"nameScore":1},"passportNumber":{"passportNumberFromSource":"S9265723","passportNumberMatch":true},"dateOfIssue":{"dispatchedOnFromSource":"30/01/2019","dateOfIssueMatch":null},"typeOfApplication":"Normal","applicationDate":"28/01/2019"},"statusCode":101,"clientData":{"caseId":"746650859"}}';
        ScreeningWachoutResponseWrapper wrapperresponse = ScreeningWachoutResponseWrapper.parse(jsonresponse);
             
        
        ScreeningResponseWrapper responseWrapper = new ScreeningResponseWrapper();
      
        Test.stopTest();
        
    }  
    @isTest
    static void testGenerateMethodNew() {
       
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM  Applicant__c LIMIT 1];
        
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'KYC OCR', appli.id, null);
        IntgMsg__c intgMsg = new IntgMsg__c();
        
        intgMsg.ParentRefId__c=loan.id;
        intgMsg.RefId__c =appli.Id;
        
        intMsglist.add(intgMsg);  
        Test.startTest();
        ScreeningWachoutRequestGenerator generator= new ScreeningWachoutRequestGenerator();
        generator.generate(intMsglist, 'TestService', 'TestProcessType');
        Test.stopTest();
        
    }   
    
    @isTest
    static void testProcess() {
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM  Applicant__c LIMIT 1];
        
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'KYC OCR', appli.id, null);
        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Id=intMsglist[0].id;
        intgMsg.ParentRefId__c=loan.id;
        intgMsg.RefId__c =appli.id;
        intgMsg.Trigger_Platform_Event__c =true;
       // intgMsg.Resp__c='{"requestId":"8eb39778-4d34-4a75-83a3-d986ddae3aee","result":{"name":{"nameFromPassport":"SRIDEVI","surnameFromPassport":"GUNTUPALLI","nameMatch":true,"nameScore":1},"passportNumber":{"passportNumberFromSource":"S9265723","passportNumberMatch":true},"dateOfIssue":{"dispatchedOnFromSource":"30/01/2019","dateOfIssueMatch":null},"typeOfApplication":"Normal","applicationDate":"28/01/2019"},"statusCode":101,"clientData":{"caseId":"746650859"}}';
       //intgMsg.Resp__c='{"WotJsonResult":{"Table":[{"Field1":"Value1","Field2":"Value2"}]}}';
       intgMsg.Resp__c='{"WotJsonResult":{"Table":[{"Record_ID":"COMP13060","Regulator_Competent_Authority_Name":"SEBI","Order_Date":"31-Jul-2020","Defaulter_Code":"C0539749","Defaulter_Name":"AVENUE SUPERMARTS LTD.","Defaulter_Type_Company_Person":"C","Defaulter_New_Name1":"","Defaulter_New_Name2":"","Defaulter_New_Name3":"","Defaulter_New_Name4":"","Defaulter_Old_Name1":"","Defaulter_Old_Name2":"","Defaulter_Old_Name3":"","Defaulter_Old_Name4":"","Defaulter_Merged_With":"","PAN_CIN_DIN":"PAN:AACCA8432H","Not_Defaulter_Infact_Associated_Entity":"","Defaulter_Other_Details":"","Alongwith":"","Associated_Entity_Person":"","Regulatory_Charges":"DELAY IN MAKING DISCLOSURE OF SHAREHOLDING/CHANGES IN SHAREHOLDING TO STOCK EXCHANGES AS REQUIRED UNDER REGULATION 7(2) (B) OF SEBI (PIT) REGULATIONS, 2015","Regulatory_Actions":"IMPOSED PENALTY RS.3,00,000; (ORDER DATED:31-JUL-2020)","Regulatory_Action_Source1":"http://www.watchoutinvestors.com/Press_Rel-T/sebi/AO_1596212403003_1.pdf?cntrl_no=COMP13060","Regulatory_Action_Source2":"","Regulatory_Action_Source3":"","Further_Development1":"SAT: SAT VIDE ITS ORDER DATED 29/09/2020 GRANTED FOUR WEEKS TIME TO RESPONDENT TO FILE AFFIDAVIT IN REPLY AND TWO WEEKS THEREAFTER FOR FILING AFFIDAVIT IN REJOINDER, IF ANY AND PLACED THE APPEAL FOR FINAL DISPOSAL ON 25/11/2020. IN THE MEANTIME, THE EFFECT AND OPERATION OF IMPUGNED ORDER DIRECTED TO BE STAYED UPON DEPOSIT OF AMOUNT EQUAL TO PENALTY WITH RESPONDENT WITHIN THREE WEEKS FROM DATE OF THIS ORDER","Further_Development1_Source":"http://www.watchoutinvestors.com/Press_Rel-T/sat/ST3356.pdf","Further_Development2":"SAT: SAT VIDE ITS ORDER DATED 10/06/2021 DIRECTED RESPONDENT TO FILE ADDITIONAL AFFIDAVITS WITHIN TWO WEEKS FROM DATE OF THIS ORDER AND APPELLANT TO FILE REJOINDER TEN DAYS THEREAFTER","Further_Development2_Source":"http://www.watchoutinvestors.com/Press_Rel-T/sat/ST3773.pdf","Further_Development3":"SAT: SAT VIDE ITS ORDER DATED 17/01/2022 DISMISSED THE APPEAL. NO COSTS","Further_Development3_Source":"http://www.watchoutinvestors.com/Press_Rel-T/sat/ST4338.pdf"}]}}';

       update intgMsg;
        List<IntgMsg__c> intMsglist1=new List<IntgMsg__c>();
        intMsglist1.add(intgMsg);
     
        
        // Call the process method
        Test.startTest();
        ScreeningWachoutResponseProcessor.process(intMsglist1);
        Test.stopTest();

    }
    @isTest
    static void testProcess1() {
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM  Applicant__c LIMIT 1];
        
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'KYC OCR', appli.id, null);
        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Id=intMsglist[0].id;
        intgMsg.ParentRefId__c=loan.id;
        intgMsg.RefId__c =appli.id;
        intgMsg.Trigger_Platform_Event__c =true;
       // intgMsg.Resp__c='{"requestId":"8eb39778-4d34-4a75-83a3-d986ddae3aee","result":{"name":{"nameFromPassport":"SRIDEVI","surnameFromPassport":"GUNTUPALLI","nameMatch":true,"nameScore":1},"passportNumber":{"passportNumberFromSource":"S9265723","passportNumberMatch":true},"dateOfIssue":{"dispatchedOnFromSource":"30/01/2019","dateOfIssueMatch":null},"typeOfApplication":"Normal","applicationDate":"28/01/2019"},"statusCode":101,"clientData":{"caseId":"746650859"}}';
       intgMsg.Resp__c='{"WotJsonResult":""}';
       update intgMsg;
        List<IntgMsg__c> intMsglist1=new List<IntgMsg__c>();
        intMsglist1.add(intgMsg);
     
        
        // Call the process method
        Test.startTest();
        ScreeningWachoutResponseProcessor.process(intMsglist1);
        Test.stopTest();

    }
    @isTest
    static void testScreeningSuccessErr() {
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id,LoanAppln__c FROM  Applicant__c LIMIT 1];
        
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'KYC OCR', appli.id, null);
        IntgMsg__c intgMsg = new IntgMsg__c();
        
        intgMsg.ParentRefId__c=loan.id;
        intgMsg.RefId__c =appli.id;
        
        intMsglist.add(intgMsg);
        
        List<APIVer__c> responses = new List<APIVer__c>();
        APIVer__c ap= new APIVer__c();
        ap.LoanAplcn__c=loan.Id;
        ap.ApplNme__c='test';
        ap.Appl__c=appli.id;
        //ap.RecordTypeId='';
        ap.ApplTyp__c='';
        ap.IsLatest__c=true;
        responses.add(ap);
        
        insert responses;

        // Create test response wrapper
        ScreeningWachoutResponseWrapper responseWrapper = new ScreeningWachoutResponseWrapper();
        /*List<ScreeningWachoutResponseWrapper.table> tabList = new List<ScreeningWachoutResponseWrapper.table>();
        ScreeningWachoutResponseWrapper.table tab = new ScreeningWachoutResponseWrapper.table();
        tabList.add(tab);
        WotJson wotJson = new WotJson();
        wotJson.Table = tabList;*/
        //responseWrapper.WotJsonResult = new WotJson();
        //responseWrapper.WotJsonResult.Table='<?xml version=\"1.0\" encoding=\"utf-16\"?>\r\n<ScreeningApiResults xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\r\n <ScreeningResult>\r\n <SystemName>Support1</SystemName>\r\n <RequestId>123412488</RequestId>\r\n <RecordIdentifier>TestRec1</RecordIdentifier>\r\n <Matched>NotMatch</Matched>\r\n <RejectionMessage>Msg</RejectionMessage>\r\n <CaseId xsi:nil=\"true\" />\r\n <AlertCount xsi:nil=\"true\" />\r\n <Alerts>\r\n <Alert>\r\n <CaseId xsi:nil=\"true\" />\r\n <AlertId xsi:nil=\"true\" />\r\n <WatchlistChangeLogActionableId xsi:nil=\"true\" />\r\n <AmlWatchlistId>0</AmlWatchlistId>\r\n <MatchTypeRefEnumValueId xsi:nil=\"true\" />\r\n </Alert>\r\n </Alerts>\r\n </ScreeningResult>\r\n <ScreeningResult>\r\n <SystemName>Support1</SystemName>\r\n <RequestId>123412489</RequestId>\r\n <RecordIdentifier>A-101426</RecordIdentifier>\r\n <Matched>NotMatch</Matched>\r\n <CaseId xsi:nil=\"true\" />\r\n <AlertCount xsi:nil=\"true\" />\r\n <Alerts>\r\n <Alert>\r\n <CaseId xsi:nil=\"true\" />\r\n <AlertId xsi:nil=\"true\" />\r\n <WatchlistChangeLogActionableId xsi:nil=\"true\" />\r\n <AmlWatchlistId>0</AmlWatchlistId>\r\n <MatchTypeRefEnumValueId xsi:nil=\"true\" />\r\n </Alert>\r\n </Alerts>\r\n </ScreeningResult>\r\n</ScreeningApiResults>';
        
        // Create referenceId for the loan application
        Id referenceId = [SELECT Id FROM LoanAppl__c LIMIT 1].Id;
        Id refId = [SELECT Id FROM Applicant__c LIMIT 1].Id;

        // Call the processScreeningResponse method
        Test.startTest();
        ScreeningWachoutResponseProcessor.ScreeningSuccess(responseWrapper, referenceId);
        ScreeningWachoutResponseProcessor.ScreeningEmpty(refId);
        Test.stopTest();


    }
    
     @isTest
    static void testIsLatestFalse() {
       
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM  Applicant__c LIMIT 1];
        
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'KYC OCR', appli.id, null);
        IntgMsg__c intgMsg = new IntgMsg__c();
        
        intgMsg.ParentRefId__c=loan.id;
        intgMsg.RefId__c =appli.id;
        
        intMsglist.add(intgMsg);  
        
        // Create test responses
        List<APIVer__c> responses = new List<APIVer__c>();
        APIVer__c ap= new APIVer__c();
        ap.LoanAplcn__c=loan.Id;
        ap.ApplNme__c='test';
        ap.Appl__c=appli.id;
        responses.add(ap);
        
        insert responses;

        // Call the updateExisitngResposnes method
        Test.startTest();
        ScreeningWachoutResponseProcessor.IsLatestFalse(responses);
        Test.stopTest();

        // Verify the changes
        // Query the updated records and verify the changes based on your assertions

        // Add assertions as needed
    }
    
  /*  private static Id getAPIVerRecordTypeId() {
        String recordTypeDevName = 'Watchout';
        Schema.RecordTypeInfo rtInfo = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get(recordTypeDevName);

        if (rtInfo == null) {
            // Create the record type if it doesn't exist
            rtInfo = new RecordType(Name = 'Watchout', DeveloperName = 'Watchout', SObjectType = 'APIVer__c');
            insert rtInfo;
        }

        return rtInfo.getRecordTypeId();
            }*/
    
}