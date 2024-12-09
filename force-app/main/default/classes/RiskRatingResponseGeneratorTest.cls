@isTest
public class RiskRatingResponseGeneratorTest {
    @isTest
    public static void testProcessMethod() {
        LoanAppl__c la = new LoanAppl__c();
        la.ChannelName__c = 'test';
        insert la;

        Applicant__c ap = new Applicant__c();
        ap.LoanAppln__c = la.id;
        ap.Constitution__c = 'HUF';
        ap.FName__c = 'Test Fname';
        ap.MobNumber__c = '999999999';
        insert ap;

        List<Applicant__c> applist = [
            SELECT id, Name
            FROM Applicant__c
            WHERE id = :ap.id
        ];

        ApplKyc__c ak = new ApplKyc__c();
        ak.Applicant__c = ap.id;
        ak.kycDoc__c = 'Aadhaar';
        ak.AadharEncripted__c = '492515815873';
        insert ak;

        String res =
            '<?xml version="1.0" encoding="utf-8"?>' +
            '<RiskProfilingResponse xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
            ' <RequestId>753678933</RequestId>' +
            ' <RequestStatus>AcceptedByTW</RequestStatus>' +
            ' <RecordResponseDetails>' +
            '  <RecordResponseDetail>' +
            '   <TransactionId>775366740</TransactionId>' +
            '   <RecordIdentifier>' +
            applist[0].Name +
            '</RecordIdentifier>' +
            '   <FinalDecision />' +
            '   <Risk>Test Risk Response</Risk>' +
            '  <CaseURL />' +
            '  <CaseId xsi:nil="true" />' +
            '  <NextReviewDate />' +
            '  <TransactionStatus>AcceptedByTW</TransactionStatus>' +
            '  <TransactionRejectionCode />' +
            '  <TransactionRejectionDescription />' +
            '  </RecordResponseDetail>' +
            ' </RecordResponseDetails>' +
            '</RiskProfilingResponse>';

        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name = 'Risk API';
        intgMsg.BU__c = 'HL / STL';
        intgMsg.Svc__c = 'Risk API';
        intgMsg.Status__c = 'New';
        intgMsg.MStatus__c = 'Blank';
        intgMsg.RefObj__c = 'Applicant__c';
        intgMsg.ParentRefId__c = la.id;
        intgMsg.ParentRefObj__c = 'LoanAppl__c';
        intgMsg.RefId__c = ap.Id;
        //intgMsg.Resp__c ='An Unique Identifier';
        intgMsg.Resp__c = res;
        insert intgMsg;

        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name = 'Risk API';
        intgMsg1.BU__c = '';
        intgMsg1.Svc__c = 'Risk API';
        intgMsg1.Status__c = 'New';
        intgMsg1.MStatus__c = 'Blank';
        intgMsg1.RefObj__c = 'Applicant__c';
        intgMsg1.ParentRefId__c = la.id;
        intgMsg1.ParentRefObj__c = 'LoanAppl__c';
        intgMsg1.RefId__c = ap.Id;
        //intgMsg.Resp__c ='An Unique Identifier';
        intgMsg1.Resp__c = res;
        insert intgMsg1;

        List<IntgMsg__c> responses = new List<IntgMsg__c>{ intgMsg, intgMsg1 };
        RiskRatingResponseGenerator.process(responses);

        //List<Attachment> attachments = [SELECT Id FROM Attachment WHERE ParentId = :ak.Id];
    }

    @isTest
    public static void testProcessMethodNew() {
        LoanAppl__c la = new LoanAppl__c();
        la.ChannelName__c = 'test';
        insert la;

        Applicant__c ap = new Applicant__c();
        ap.LoanAppln__c = la.id;
        ap.Constitution__c = 'HUF';
        ap.FName__c = 'Test Fname';
        ap.MobNumber__c = '999999999';
        insert ap;

        List<Applicant__c> applist = [
            SELECT id, Name
            FROM Applicant__c
            WHERE id = :ap.id
        ];

        ApplKyc__c ak = new ApplKyc__c();
        ak.Applicant__c = ap.id;
        ak.kycDoc__c = 'Aadhaar';
        ak.AadharEncripted__c = '492515815873';
        insert ak;

        String res =
            '<?xml version="1.0" encoding="utf-8"?>' +
            '<RiskProfilingResponse xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
            ' <RequestId>753678933</RequestId>' +
            ' <RequestStatus>AcceptedByTWMN</RequestStatus>' +
            ' <RecordResponseDetails>' +
            '  <RecordResponseDetail>' +
            '   <TransactionId>775366740</TransactionId>' +
            '   <RecordIdentifier>' +
            applist[0].Name +
            '</RecordIdentifier>' +
            '   <FinalDecision />' +
            '   <Risk>Test Risk Response</Risk>' +
            '  <CaseURL />' +
            '  <CaseId xsi:nil="true" />' +
            '  <NextReviewDate />' +
            '  <TransactionStatus>AcceptedByTWMN</TransactionStatus>' +
            '  <TransactionRejectionCode />' +
            '  <TransactionRejectionDescription />' +
            '  </RecordResponseDetail>' +
            ' </RecordResponseDetails>' +
            '</RiskProfilingResponse>';

        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name = 'Risk API';
        intgMsg.BU__c = 'HL / STL';
        intgMsg.Svc__c = 'Risk API';
        intgMsg.Status__c = 'New';
        intgMsg.MStatus__c = 'Blank';
        intgMsg.RefObj__c = 'Applicant__c';
        intgMsg.ParentRefId__c = la.id;
        intgMsg.ParentRefObj__c = 'LoanAppl__c';
        intgMsg.RefId__c = ap.Id;
        //intgMsg.Resp__c ='An Unique Identifier';
        intgMsg.Resp__c = res;
        insert intgMsg;

        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name = 'Risk API';
        intgMsg1.BU__c = '';
        intgMsg1.Svc__c = 'Risk API';
        intgMsg1.Status__c = 'New';
        intgMsg1.MStatus__c = 'Blank';
        intgMsg1.RefObj__c = 'Applicant__c';
        intgMsg1.ParentRefId__c = la.id;
        intgMsg1.ParentRefObj__c = 'LoanAppl__c';
        intgMsg1.RefId__c = ap.Id;
        //intgMsg.Resp__c ='An Unique Identifier';
        intgMsg1.Resp__c = res;
        insert intgMsg1;

        List<IntgMsg__c> responses = new List<IntgMsg__c>{ intgMsg, intgMsg1 };
        RiskRatingResponseGenerator.process(responses);
    }
}