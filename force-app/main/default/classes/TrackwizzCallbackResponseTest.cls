@istest
public class TrackwizzCallbackResponseTest {
    
    @istest
    public static void testGenerateMethod() {//
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app = TestDataFactory.createSingleApplicant(true,la.id);
        Id riskRatingRecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('RiskRating').getRecordTypeId();
        
        APIVer__c apiver=new APIVer__c();
        apiver.Appl__c=app.Id;
        apiver.IsLatest__c=true;
        apiver.LoanAplcn__c=la.Id;
        apiver.RecordTypeId=riskRatingRecordTypeId;
        insert apiver;
        
        List<Applicant__c> applist=[Select id,Name from Applicant__c Where id=:app.Id];
        
        
         IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name = 'Trackwizz Callback';
        intgMsg.BU__c = 'HL / STL';
        intgMsg.Status__c = 'New';
        intgMsg.MStatus__c = 'Blank';
        intgMsg.RefObj__c = '';
        intgMsg.RefId__c = '';
        intgMsg.Trigger_Platform_Event__c = true;
        intgMsg.Req__c = '<?xml version="1.0" encoding="utf-16"?><CustomerLevelRiskRatingStatusRequest xmlns:xsd="http://www.w3.org/2001/XMLSchema"xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><RequestId>c4ed528c-a026-445c-a1d9-eb94b4fd01b7</RequestId><ApiToken>8d557611-6e73-4d86-ab74-614a70048743</ApiToken><ParentCompany>TSSCPL</ParentCompany><SourceSystem>Finacle</SourceSystem><CustomerRequestDetails><CustomerRequestDetail><TransactionId>03905d94-41e6-4734-9fb1-e6ab0b1d0240</TransactionId><RecordIdentifier>'+applist[0].Name+'</RecordIdentifier><CustomerSegmentDetails><CustomerSegmentDetail><CustomerSegment>Retail</CustomerSegment><StartDate>09-Oct-2020</StartDate><EndDate /></CustomerSegmentDetail></CustomerSegmentDetails><FinalDecision>Accept Business</FinalDecision><Risk>High</Risk><NextReviewDate>27-Jun-2020</NextReviewDate><ReviewCompletionDate>11-Jun-2021</ReviewCompletionDate><ApprovedRiskSetBy>Nisarg Mehta</ApprovedRiskSetBy><ApprovedRiskRemarks>Approved</ApprovedRiskRemarks><CaseUrl>http://appprod1:44321/crm/crmmenu/menu#/riskrating/actionable/edit/RiskRatingF989/3344</CaseUrl><CaseId>3344</CaseId></CustomerRequestDetail><CustomerRequestDetail><TransactionId>03905d94-41e6-4734-9fb1-e6ab0b1d0240</TransactionId><RecordIdentifier>DHFHFIIO656L565</RecordIdentifier><CustomerSegmentDetails><CustomerSegmentDetail><CustomerSegment>Retail</CustomerSegment><StartDate>09-Oct-2020</StartDate><EndDate /></CustomerSegmentDetail></CustomerSegmentDetails><FinalDecision>Accept Business</FinalDecision><Risk>High</Risk><NextReviewDate>27-Jun-2020</NextReviewDate><ReviewCompletionDate>11-Jun-2021</ReviewCompletionDate><ApprovedRiskSetBy>Nisarg Mehta</ApprovedRiskSetBy><ApprovedRiskRemarks>Approved</ApprovedRiskRemarks><CaseUrl>http://appprod1:44321/crm/crmmenu/menu#/riskrating/actionable/edit/RiskRatingF989/3344</CaseUrl><CaseId>3344</CaseId></CustomerRequestDetail></CustomerRequestDetails></CustomerLevelRiskRatingStatusRequest>';
        insert intgMsg;
                  
        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name = 'Trackwizz Callback';
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
            
            
        Test.startTest();
            
        TrackwizzCallbackResponseProcessor.process(msgs);
        TrackwizzCallbackResponseProcessor.process(msgs1);
        Test.stopTest();    
        
    }

}