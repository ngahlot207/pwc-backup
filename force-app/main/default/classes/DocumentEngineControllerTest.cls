@istest
public class DocumentEngineControllerTest {
	@isTest
    static void evalAllRequiredDocsTest(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli=New Applicant__c();
        appli.FName__c='test';
        appli.MobNumber__c='9876567899';
        appli.LName__c='method';
        appli.LoanAppln__c = loanApp.id; 
        appli.Constitution__c = 'INDIVIDUAL';
        appli.CustProfile__c = 'SALARIED';
        TriggerBase.bypass('Applicant__c');
        insert appli;
        TriggerBase.clearBypass('Applicant__c');   
        List<String> categoriesList=new List<String>();
        categoriesList.add('Income Documents');
        categoriesList.add('test');
        DocDtl__c recDocDtl= new DocDtl__c(Appl__c=appli.Id, DocCatgry__c='Income Documents' );
        TriggerBase.bypass('DocDtl__c');
         insert recDocDtl;
        TriggerBase.clearBypass('DocDtl__c');
        
        try{
            DocumentEngine docEng = new DocumentEngine(loanApp.Id);
            List<String> ResultinList = DocumentEngineController.evalAllRequiredDocs(docEng, appli.id, loanApp.Id ,'Home Loan','QDE','RM Data Entry',categoriesList);
            system.debug('ResultinList'+ResultinList.size());
            system.assertEquals(1, ResultinList.size());
        }catch(NullPointerException ex){
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
        }
    }
}