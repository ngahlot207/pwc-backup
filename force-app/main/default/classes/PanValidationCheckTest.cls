@isTest
public class PanValidationCheckTest {
	@isTest
    public static void testGetPanValiStatus(){
        user u=TestDataFactory.UserData(true);
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loanApp.Id);
        DocMstr__c docMastRec=TestDataFactory.createDocumentMaster(true, 'test');
        ApplKyc__c apliKYC= new ApplKyc__c();
        apliKYC.Applicant__c=applicant.Id;
        apliKYC.kycDoc__c='Pan';
        apliKYC.Pan__c='123456';
        apliKYC.Validation_Error_Message__c = 'No records found for the given ID or combination of inputs';
        apliKYC.ValidationStatus__c = 'Failure';
        insert apliKYC;
        DocDtl__c docDetail = TestDataFactory.createDocumentDetail(true, 'Test',applicant.Id,docMastRec.Id);
        DocDtl__c decRecToUpdate=new DocDtl__c();
        decRecToUpdate.Id=docDetail.Id;
        decRecToUpdate.DocTyp__c ='PAN';
        decRecToUpdate.LAN__c=loanApp.Id;
        decRecToUpdate.Applicant_KYC__c=apliKYC.Id;
        update decRecToUpdate;
        List<String> result=PanValidationCheck.getPanValidationStatus(loanApp.Id);
        system.debug('result'+result);
        System.assertEquals('test method', result[0]);
    }
}