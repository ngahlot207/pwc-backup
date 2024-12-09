@isTest
public class IntegrationUtilityTest {
    
    @isTest
    public static void Testmethod1(){
        
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app = TestDataFactory.createSingleApplicant(true,la.id);
        
        Bureau__c br=new Bureau__c();
        br.LoanApp__c=La.id;
        br.Applicant__c=app.id;
        br.AckId__c=123456;
        br.IsLatest__c=true;
        br.BureauAPI__c='Consumer';
        insert br;
        
        List<Bureau__c> bur =[Select id,Applicant__c,IsLatest__c from Bureau__c Where Applicant__c=:app.id AND IsLatest__c=true];
        
        Test.StartTest();
        IntegrationUtility.updateBooleanFlag(bur,'IsLatest__c',false);
        IntegrationUtility.getCustomErrorMessage('Unexpected character');
        IntegrationUtility.getCustomErrorMessage('Illegal unquoted character');
        IntegrationUtility.getCustomErrorMessage('Illegal');
        IntegrationUtility.getCustomErrorMessage('');
        Test.StopTest();
        
    }

}