@isTest
public class PerfiosRetrieveReportReqGen_Test {
    @isTest
    public static void generateTest(){
        
    LoanAppl__c La = TestDataFactory.createLoanApplication(true);
    Applicant__c ap = TestDataFactory.createSingleApplicant(true,La.id);
        
        ApplKyc__c ak=new ApplKyc__c();
        ak.Applicant__c=ap.id;
        ak.kycDoc__c='Pan';
        ak.Name__c='test';
        ak.Pan__c='KIOPA1722K';
        insert ak;
        
        ApplBanking__c ab = new ApplBanking__c();
        ab.Appl__c = ap.Id;
        ab.LoanAppl__c = la.Id;
        ab.TransactionId__c = 'PERFIOS1-RSA-SHA256';
        insert ab;
        
        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='PerfiosRetrieveReportRequestGenerator';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='ApplKyc__c';
        intgMsg.RefId__c = ap.Id;
        intgMsg.ParentRefId__c = ab.Id;
        intgMsg.Resp__c = '{"WotJsonResult":{"Table":[{"Record_ID":"123","Regulator_Competent_Authority_Name":"RegAuthName","Order_Date":"31-Jul-1998","Defaulter_Code":"DefCode","Defaulter_Name":"DefName","Defaulter_Type_Company_Person":"DefType","Defaulter_New_Name1":"NewName","Defaulter_Old_Name1":"OldName","Defaulter_Merged_With":"MergedWith","PAN_CIN_DIN":"PanCinDin","Defaulter_Other_Details":"OtherDetails","Not_Defaulter_Infact_Associated_Entity":"AssociatedEntity","Alongwith":"AlongWith","Associated_Entity_Person":"AssocEntity","Regulatory_Charges":"RegCharges","Regulatory_Actions":"RegActions","Regulatory_Action_Source1":"RegSource1","Regulatory_Action_Source2":"RegSource2","Regulatory_Action_Source3":"RegSource3"}]}}';
        intgMsg.Trigger_Platform_Event__c=true;
        insert intgMsg;
        
            //Request Class
            List<IntgMsg__c> msgs = new List<IntgMsg__c>{intgMsg};
            PerfiosRetrieveReportRequestGenerator requestGenerator = new PerfiosRetrieveReportRequestGenerator();
            requestGenerator.generate(msgs, 'PerfiosRetrieveReportRequestGenerator', 'Async');
    }

}