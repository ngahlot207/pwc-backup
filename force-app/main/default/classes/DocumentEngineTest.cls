@istest
public class DocumentEngineTest {
    
    @isTest
    static void validateDocumentEngineMethod(){
        User u = TestDataFactory.UserData(true);
        
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
        
        
        try{
            Map<String,Map<String,List<String>>> documentsReqmap = DocumentEngine.fetchAllRequiredDocs(appli.id, loanApp.Id ,'Home Loan','QDE','RM Data Entry');
            system.assertEquals(7, documentsReqmap.size());
            DocumentEngine.fetchAllRequiredDocs(null, null ,null,null,null);
        }catch(NullPointerException ex){
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
        }
        
        List<DocDtl__c> docDetlist = new List<DocDtl__c>();
        
        DocDtl__c docDetailRec = new DocDtl__c();
        docDetailRec.DocCatgry__c = 'KYC Documents';
        docDetailRec.DocTyp__c = 'Identity Proof';
        docDetailRec.DocSubTyp__c = 'Driving License' ;
        docDetailRec.Appl__c = appli.id;
        docDetlist.add(docDetailRec);
        
        DocDtl__c docDetailRecTwo = new DocDtl__c();
        docDetailRecTwo.DocCatgry__c = 'KYC Documents';
        docDetailRecTwo.DocTyp__c = 'Signature Verification proof';
        docDetailRecTwo.DocSubTyp__c = 'Voter ID' ;
        docDetailRecTwo.Appl__c = appli.id;
        docDetlist.add(docDetailRecTwo);
        
        DocDtl__c docDetailRecThre = new DocDtl__c();
        docDetailRecThre.DocCatgry__c = 'KYC Documents';
        docDetailRecThre.DocTyp__c = 'DOB Proof';
        docDetailRecThre.DocSubTyp__c = 'Passport' ;
        docDetailRecThre.Appl__c = appli.id;
        docDetlist.add(docDetailRecThre);
        if(!docDetlist.isEmpty()){
            insert docDetlist;
        }
        
        try{
            list<string> lstDoc = new list<string>{'Income Documents','KYC Documents'};
            DocumentEngine docEng = new DocumentEngine(loanApp.Id);
            List<String> errors = DocumentEngineController.evalAllRequiredDocs(docEng, appli.id, loanApp.Id,'Home Loan','QDE','RM Data Entry',lstDoc);
            Map<String,List<String>> returnValDocss = DocumentEngine.evalAllRequiredDocsAdd(appli.id, loanApp.Id,'Home Loan','QDE','RM Data Entry',lstDoc);
            DocumentEngine.MissingDocRetunWrpr returnValDocs = docEng.evalAllRequiredDocsAddNew(appli.id, loanApp.Id,'Home Loan','QDE','RM Data Entry',lstDoc);
            List<String> returnVal = DocumentEngine.evalAllRequiredDocs(appli.id, loanApp.Id,'Home Loan','QDE','RM Data Entry',lstDoc);
           // system.assertEquals(false, returnVal);
            DocumentEngine.evalAllRequiredDocs(null, null ,null,null,null,null);
        }catch(NullPointerException ex){
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
        }
    }
}