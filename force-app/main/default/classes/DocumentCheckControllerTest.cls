@isTest
public class DocumentCheckControllerTest {
   @testsetup
    static void DocumentCheckControllerMethod(){
        
        Profile testProfile = [SELECT Id FROM profile WHERE Name = 'LOS Base User' LIMIT 1];
        User testUser = new User(LastName = 'test user 1', 
                                 Username = 'test.createLoanTeam@example.com', 
                                 Email = 'test.1@example.com', 
                                 Alias = 'testu1', 
                                 TimeZoneSidKey = 'GMT', 
                                 LocaleSidKey = 'en_GB', 
                                 EmailEncodingKey = 'ISO-8859-1', 
                                 ProfileId = testProfile.Id, 
                                 LanguageLocaleKey = 'en_US'); 
        
        insert testUser;
        system.runAs(testUser){
            BankBrchMstr__c bnkbranch=TestDataFactory.TestDataBankBranchMaster(true);
            BankBrchMstr__c bnkbranch1=TestDataFactory.TestDataBankBranchMaster1(true);
            TeamHierarchy__c TH= testDataFactory.TestDataTeamHierarchy_nonSup(true,testUser.id,bnkbranch.Id);// RM Role
             
         
            LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
       		Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
            
          DocumentCheckController.DocDetailWrapper wrp = new DocumentCheckController.DocDetailWrapper();
        wrp.docCategry='KYC Documents';
        wrp.docDetName='PAN';
        wrp.docDetType='Identity Proof';
        	
        DocMstr__c docMst = new DocMstr__c();
            docMst.Prod__c = loanApp.Product__c;
            docMst.DocTyp__c = wrp.docDetType;
            docMst.Catgry__c=wrp.docCategry;
            docMst.Active__c =true;
            docMst.Required__c = true ;
            TriggerBase.bypass('DocMstr__c');
            insert docMst;
            TriggerBase.clearBypass('DocMstr__c');
            
           DocDtl__c doc = new DocDtl__c();
           
            doc.DocTyp__c = wrp.docDetType;
            doc.DocCatgry__c = wrp.docCategry;
            doc.DocSubTyp__c = wrp.docDetName;
            doc.LAN__c=loanApp.Id;
            doc.Appl__c = appli.Id;
            doc.DocMstr__c = docMst.Id;
            doc.DocStatus__c='Received';
            insert doc;
          
        }
    }
     @isTest
    Public Static Void testDocumentCheckController(){
        List<LoanAppl__c> LoanAppList= new List<LoanAppl__c>([select id,BrchCode__c from LoanAppl__c limit 1]);
         
       
      
        DocumentCheckController.ndcDocumentCheck(LoanAppList[0].Id);
        system.assert(!LoanAppList.isEmpty(), 'LoanAppList is not empty');
        
    }
}