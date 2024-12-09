@Istest
public class ConsumerIssueTest {
    @isTest
    public static void testGenerateMethod() {
        
        
    LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        
    Applicant__c app = TestDataFactory.createSingleApplicant(true,la.id);  
        
        Bureau__c br=new Bureau__c();
        br.LoanApp__c=La.id;
        br.Applicant__c=app.id;
        br.AckId__c=123456;
        br.IsLatest__c=true;
        br.BureauAPI__c='Consumer';
        insert br;
        
        DocMstr__c dm=new DocMstr__c();
        dm.Active__c=true;
        dm.DocTyp__c='Bureau Report';
        dm.Catgry__c='Bureau Report';
        dm.Prod__c='Home Loan';
        insert dm;
        
       
        
        
        IntgMsg__c intgMsg =new IntgMsg__c();
        intgMsg.Name='Cusomer Issue Request';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='Applicant__c';
        intgMsg.RefId__c = app.Id;
        intgMsg.Resp__c='';
        insert intgMsg;
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.VersionData =blob.valueof('{"STATUS":"COMPLETED","ACKNOWLEDGEMENT-ID":9113988,"MERGED_RESPONSE_OBJECT":{"issuedDate":"28112023","bureauFeeds":{"cibilScore":[{"score":"730","scoringFactor":["HIGH BALANCE BUILD-UP ON SECURED LOANS"],"referenceNumber":"002159539701","scoreType":"CIBILTUSC3","status":"SUCCESS"}]},"secSummary":{"percentageUsed":0,"overdueAmount":0,"balance":1426244,"days90Overdue":0,"days60Overdue":0,"payments":0,"days30Overdue":0,"openAccount":3},"totalNumCreditLines":"27","activeTradelines":[{"suitFiled":"","paymentHistory":"000","accountOpenDate":"06062022","creditInstitution":"NOT DISCLOSED","reportedDate":"30062022","lastPaymentDate":"06062022","lastPaymentAmount":"","monthlyInstallmentAmount":"","tenure":"","interestRate":"","writeOff":"","overdueAmount":"","accountType":"CONSUMER LOAN","currentBalance":"13070","active":"true","paymentHistoryEndDate":"01062022","accountNumber":"","paymentHistoryArr":[" ","0"," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "],"paymentHistoryStartDate":"01062022","assetClassHistory":"XXX","ownership":"INDIVIDUAL","month":[{"suitFiledStatus":"XXX","assetClassificationStatus":"XXX","paymentStatus":"000","key":"06-22"}],"paymentHistoryStartDateTemp":"062022","settlementAmount":"","secured":"UNSECURED","sanctionedAmount":"","reportedBureaus":"TU","bureauName":"CIBIL"}],"revcSummary":{"percentageUsed":0,"overdueAmount":0,"balance":0,"days90Overdue":0,"days60Overdue":0,"payments":0,"days30Overdue":0,"openAccount":1},"totalNumEnquiries":"999","enquiryData":{"gender":"male","dob":"15121993","addressList":["SHIVAJI NAGAR, WAKDEWADI PUNE SHIVAJI NAGAR, WAKDEWADI PUNE PUNE 411005  [RESIDENCE]"],"name":"LAV SHAW","idList":["EHEPS6295G [PAN]"]},"pastEnquiry":[{"amount":"700000","bureuReported":"TU","enquiryDate":"28112023","enqConvBySameInstFlag":"0","enqConvertedFlag":"0","enquiryReason":"Internal Maintenance, Dispute","enquiryBy":"NOT DISCLOSED"}],"bureauReported":"CIBIL (TU)","disparateCredentials":{"emailList":[{"idType":"EMAIL","value":"LOVSHAW742@GMAIL.COM","bureauReported":"TU"}],"addressList":[{"addressType":"02","dateReported":"13072023","bureauReported":"TU","value":"TEST ONE SOUTH DELHI XGES YBVAU DELHI 110019"}],"dobList":[{"value":"15121993","bureauReported":"TU"}],"nameList":[{"value":"LAV SHAW BHAGWAN SHAW WFKNWFNWFNWF","bureauReported":"TU"}],"phoneList":[{"value":"9044691379","bureauReported":"TU"}],"kycIDList":[{"idType":"01","value":"EHEPS6295G","bureauReported":"TU"}]},"refNumber":"9113988","unSecSummary":{"percentageUsed":0,"overdueAmount":0,"balance":13070,"days90Overdue":0,"days60Overdue":0,"payments":0,"days30Overdue":0,"openAccount":1}},"HEADER":{"CUST-ID":"A-001843","APPLICATION-ID":"LAN-0143","RESPONSE-TYPE":"RESPONSE","REQUEST-RECEIVED-TIME":"28112023 15:55:24"},"FINISHED":[{"TRACKING-ID":7318213,"STATUS":"SUCCESS","PRODUCT":"CIR","JSON-RESPONSE-OBJECT":{"scoreList":[{"score":"00730","reasonCode1":"09","scoreCardVersion":"10","scoreCardName":"08","scoreDate":"28112023","scoreName":"CIBILTUSC3"}],"employmentList":[{"occupationCode":"03","accountType":"10","dateReported":"30042021"}],"addressList":[{"addressCategory":"03","pinCode":"411005","dateReported":"19062023","addressLine1":"LOKESH CHOUDARY LOKESH CBKJC HHJHKG","addressLine2":"LOKESH CHOUDARY LOKESH CBKJC HHJHKG","residenceCode":"02","stateCode":"27","addressLine3":"LOKESH CHOUDARY LOKESH CBKJC HHJHKG","addressLine4":"LOKESH CHOUDARY LOKESH CBKJC HHJHKG","addressLine5":"LOKESH CHOUDARY LOKESH CBKJC HHJHKG","enrichedThroughtEnquiry":"Y"}],"accountList":[{"dateReportedAndCertified":"30062022","dateOpenedOrDisbursed":"22032022","accountType":"03","currentBalance":"960881","paymentHistoryEndDate":"01052022","rateOfInterest":"16.150","paymentHistoryStartDate":"01062022","ownershipIndicator":"4","emiAmount":"14823","paymentHistory1":"000000","reportingMemberShortName":"CEASE-TERMINATED","repaymentTenure":"181","dateOfLastPayment":"05062022","typeOfCollateral":"01","highCreditOrSanctionedAmount":"963182"}],"name":{"name3":"WFKNWFNWFNWF","gender":"2","dob":"15121993","name1":"LAV SHAW BHAGWAN SHAW"},"header":{"memberReferenceNumber":"5189678","timeProceed":"154246","enquiryMemberUserID":"NB68428888_UATC2C","dateProceed":"28112023","subjectReturnCode":"1","version":"12","enquiryControlNumber":"002159539701"},"phoneList":[{"enrichEnquiryForPhone":"Y","telephoneNumber":"9044691379","telephoneType":"01"}],"enquiryList":[{"enquiryPurpose":"34","dateReported":"28112023","reportingMemberShortName":"NOT DISCLOSED","enquiryAmount":"700000"}],"idList":[{"idType":"01","idValue":"EHEPS6295G"}]},"BUREAU":"CIBIL"}]}');
        contentVersion.Title = 'response.json';
        contentVersion.PathOnClient = 'response.json';
        insert contentVersion;
        
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1].ContentDocumentId;
        
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.ContentDocumentId = contentDocumentId;
        contentLink.LinkedEntityId=intgMsg.id;
        contentLink.ShareType = 'V';
        insert contentLink;
        
       List<IntgMsg__c> msg =new List<IntgMsg__c>{intgMsg};
        ConsumerIssueRequestGenerator req=new ConsumerIssueRequestGenerator();
        req.generate(msg,'Cusomer Issue Request','Async');
        
        List<IntgMsg__c> responses =new List<IntgMsg__c>{intgMsg};
        ConsumerIssueResponseProcessor.process(responses);
        
        //creating integration message for reject
        IntgMsg__c intgMsg1 =new IntgMsg__c();
        intgMsg1.Name='Cusomer Issue Request';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='Applicant__c';
        intgMsg1.RefId__c = app.Id;
        intgMsg1.Resp__c='';
        insert intgMsg1;
        
        ContentVersion contentVersion1 = new ContentVersion();
        contentVersion1.VersionData =blob.valueof('{"STATUS":"COMPLETED","ACKNOWLEDGEMENT-ID":9151645,"REJECT":[{"TRACKING-ID":7360800,"STATUS":"ERROR","ERRORS":[{"CODE":"E000","DESCRIPTION":"Unexpected error occurred. Please contact your support team."}],"PRODUCT":"CIR","BUREAU":"CIBIL"}],"MERGED_RESPONSE_OBJECT":{"issuedDate":"19122023","bureauFeeds":{},"secSummary":{"percentageUsed":0,"overdueAmount":0,"balance":0,"days90Overdue":0,"days60Overdue":0,"payments":0,"days30Overdue":0,"openAccount":0},"refNumber":"9151645","totalNumCreditLines":"0","unSecSummary":{"percentageUsed":0,"overdueAmount":0,"balance":0,"days90Overdue":0,"days60Overdue":0,"payments":0,"days30Overdue":0,"openAccount":0},"revcSummary":{"percentageUsed":0,"overdueAmount":0,"balance":0,"days90Overdue":0,"days60Overdue":0,"payments":0,"days30Overdue":0,"openAccount":0},"totalNumEnquiries":"0","enquiryData":{"gender":"male","dob":"15121993","addressList":["MAHUHWAHA ADDA POST ADDA BAZAR DIS MAHUHWAHA ADDA POST ADDA BAZAR DIS MAHARAJGANJ 273162  [RESIDENCE]"],"name":"GANESH","idList":["AUQPG9814Q [PAN]"]},"bureauReported":""},"HEADER":{"CUST-ID":"A-002258","APPLICATION-ID":"LAN-0143","RESPONSE-TYPE":"RESPONSE","REQUEST-RECEIVED-TIME":"19122023 21:49:53"}}');
        contentVersion1.Title = 'response.json';
        contentVersion1.PathOnClient = 'response.json';
        insert contentVersion1;
        
        Id contentDocumentId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion1.Id LIMIT 1].ContentDocumentId;
        
        ContentDocumentLink contentLink1 = new ContentDocumentLink();
        contentLink1.ContentDocumentId = contentDocumentId1;
        contentLink1.LinkedEntityId=intgMsg1.id;
        contentLink1.ShareType = 'V';
        insert contentLink1;

        List<IntgMsg__c> responses1 =new List<IntgMsg__c>{intgMsg1};
        ConsumerIssueResponseProcessor.process(responses1);
        
        
        //creating integration message for Inprogress
        IntgMsg__c intgMsg2 =new IntgMsg__c();
        intgMsg2.Name='Cusomer Issue Request';
        intgMsg2.BU__c='HL / STL';
        intgMsg2.Status__c='New';
        intgMsg2.MStatus__c='Blank';
        intgMsg2.RefObj__c='Applicant__c';
        intgMsg2.RefId__c = app.Id;
        intgMsg2.Resp__c='';
        insert intgMsg2;
        
        ContentVersion contentVersion2 = new ContentVersion();
        contentVersion2.VersionData =blob.valueof('{"STATUS":"IN-PROCESS","ACKNOWLEDGEMENT-ID":9123806,"MERGED_RESPONSE_OBJECT":{"issuedDate":"05122023","bureauFeeds":{},"secSummary":{"percentageUsed":0,"overdueAmount":0,"balance":0,"days90Overdue":0,"days60Overdue":0,"payments":0,"days30Overdue":0,"openAccount":0},"refNumber":"9123806","totalNumCreditLines":"0","unSecSummary":{"percentageUsed":0,"overdueAmount":0,"balance":0,"days90Overdue":0,"days60Overdue":0,"payments":0,"days30Overdue":0,"openAccount":0},"revcSummary":{"percentageUsed":0,"overdueAmount":0,"balance":0,"days90Overdue":0,"days60Overdue":0,"payments":0,"days30Overdue":0,"openAccount":0},"totalNumEnquiries":"0","enquiryData":{"gender":"male","dob":"15121993","addressList":["SHIVAJI NAGAR, WAKDEWADI SHIVAJI NAGAR, WAKDEWADI PUNE 411005  [RESIDENCE]"],"name":"LAV SHAW","idList":["EHEPS6295G [PAN]"]},"bureauReported":""},"HEADER":{"CUST-ID":"A-000895","APPLICATION-ID":"LAN-0504","RESPONSE-TYPE":"RESPONSE","REQUEST-RECEIVED-TIME":"05122023 13:02:28"},"IN-PROCESS":[{"TRACKING-ID":7329435,"STATUS":"WAITING","PRODUCT":"CIR","BUREAU":"CIBIL"}]}');
        contentVersion2.Title = 'response.json';
        contentVersion2.PathOnClient = 'response.json';
        insert contentVersion2;
        
        Id contentDocumentId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion2.Id LIMIT 1].ContentDocumentId;
        
        ContentDocumentLink contentLink2 = new ContentDocumentLink();
        contentLink2.ContentDocumentId = contentDocumentId2;
        contentLink2.LinkedEntityId=intgMsg2.id;
        contentLink2.ShareType = 'V';
        insert contentLink2;

       List<IntgMsg__c> responses2 =new List<IntgMsg__c>{intgMsg2};
        ConsumerIssueResponseProcessor.process(responses2);
        
        
        
        //creating integration message for Bureau-error
        IntgMsg__c intgMsg3 =new IntgMsg__c();
        intgMsg3.Name='Cusomer Issue Request';
        intgMsg3.BU__c='HL / STL';
        intgMsg3.Status__c='New';
        intgMsg3.MStatus__c='Blank';
        intgMsg3.RefObj__c='Applicant__c';
        intgMsg3.RefId__c = app.Id;
        intgMsg3.Resp__c='';
        insert intgMsg3;
        
        ContentVersion contentVersion3 = new ContentVersion();
        contentVersion3.VersionData =blob.valueof('{"STATUS":"COMPLETED","ACKNOWLEDGEMENT-ID":9023781,"HEADER":{"CUST-ID":"A-000126","APPLICATION-ID":"LAN-0143","RESPONSE-TYPE":"RESPONSE","REQUEST-RECEIVED-TIME":"05102023 18:13:40"},"FINISHED":[{"TRACKING-ID":7222425,"STATUS":"BUREAU-ERROR","PRODUCT":"CIR","JSON-RESPONSE-OBJECT":{"mbrRefNbr":"4930449","invIpOpMedia":"11","timeProcessed":"181338","dateProcessed":"05102023","errorDomainList":[{"errorDescription":"Invalid input/output media","errorCategory":"CR-CIBIL-CIR","errorCode":"E011"}]},"BUREAU":"CIBIL"}]}');
        contentVersion3.Title = 'response.json';
        contentVersion3.PathOnClient = 'response.json';
        insert contentVersion3;
        
        Id contentDocumentId3 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion3.Id LIMIT 1].ContentDocumentId;
        
        ContentDocumentLink contentLink3 = new ContentDocumentLink();
        contentLink3.ContentDocumentId = contentDocumentId3;
        contentLink3.LinkedEntityId=intgMsg3.id;
        contentLink3.ShareType = 'V';
        insert contentLink3;

       List<IntgMsg__c> responses3 =new List<IntgMsg__c>{intgMsg3};
        ConsumerIssueResponseProcessor.process(responses3);
        CommercialIssueResponseProcessor.process(responses3);
          ConsumerIssueResponseWrapper res=ConsumerIssueResponseWrapper.parse(contentVersion3.VersionData.tostring());
        
        
        
        //creating integration message for DL-Queue
        IntgMsg__c intgMsg4 =new IntgMsg__c();
        intgMsg4.Name='Cusomer Issue Request';
        intgMsg4.BU__c='HL / STL';
        intgMsg4.Status__c='New';
        intgMsg4.MStatus__c='Blank';
        intgMsg4.RefObj__c='Applicant__c';
        intgMsg4.RefId__c = app.Id;
        intgMsg4.Resp__c='';
        insert intgMsg4;
        
        ContentVersion contentVersion4 = new ContentVersion();
        contentVersion4.VersionData =blob.valueof('{"STATUS":"COMPLETED","ACKNOWLEDGEMENT-ID":9276256,"REJECT":[{"TRACKING-ID":7482906,"STATUS":"DL-QUEUE","PRODUCT":"CIR","BUREAU":"CIBIL"}],"MERGED_RESPONSE_OBJECT":{"issuedDate":"29022024","bureauFeeds":{},"secSummary":{"percentageUsed":0,"overdueAmount":0,"balance":0,"days90Overdue":0,"days60Overdue":0,"payments":0,"days30Overdue":0,"openAccount":0},"refNumber":"9276256","totalNumCreditLines":"0","unSecSummary":{"percentageUsed":0,"overdueAmount":0,"balance":0,"days90Overdue":0,"days60Overdue":0,"payments":0,"days30Overdue":0,"openAccount":0},"revcSummary":{"percentageUsed":0,"overdueAmount":0,"balance":0,"days90Overdue":0,"days60Overdue":0,"payments":0,"days30Overdue":0,"openAccount":0},"totalNumEnquiries":"0","enquiryData":{"gender":"male","dob":"21051982","addressList":["HNO FLAT NO 33053 3D BLOCK DHULE 424001  [RESIDENCE]"],"name":"SACHIN OBHAN","idList":["AAHPO7310C [PAN]"]},"bureauReported":""},"HEADER":{"CUST-ID":"A-005701","APPLICATION-ID":"L0000002974","RESPONSE-TYPE":"RESPONSE","REQUEST-RECEIVED-TIME":"29022024 13:29:05"}}');
        contentVersion4.Title = 'response.json';
        contentVersion4.PathOnClient = 'response.json';
        insert contentVersion4;
        
        Id contentDocumentId4 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion4.Id LIMIT 1].ContentDocumentId;
        
        ContentDocumentLink contentLink4 = new ContentDocumentLink();
        contentLink4.ContentDocumentId = contentDocumentId4;
        contentLink4.LinkedEntityId=intgMsg4.id;
        contentLink4.ShareType = 'V';
        insert contentLink4;

        List<IntgMsg__c> responses4 =new List<IntgMsg__c>{intgMsg4};
        ConsumerIssueResponseProcessor.process(responses4);
        CommercialIssueResponseProcessor.process(responses4);
        
        // Create an instance of the BureauQueueable class
        String jsonData = '{"Name": "Cusomer Issue Request", "Status": "New", "MStatus": "Blank", "BU": "HL / STL", "RefId": "a0GC4000000XcBNMA0", "RefObj": "IntgMsg__c", "Svc": "Cusomer Issue Request", "ApiVendor": "Lentra", "IsActive": "true"}';
        BureauQueueable bq = new BureauQueueable(jsonData);
        //BureauPdfQueueable br1 = new BureauPdfQueueable(jsonData,intgMsg3,'Commercial API');
        System.enqueueJob(bq);
    }
    
    
    
}