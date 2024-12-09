@isTest
public class ValidateRequiredFieldsAndDocTest {
    @isTest
    static  Void testValidateRequiredFieldsAndDoc() {    
             Profile testProfile = [SELECT Id 
                                   FROM profile
                                   WHERE Name = 'System Administrator' 
                                   LIMIT 1 ];
            User testUser = new User(LastName = 'test user 1', 
                                     Username = 'test.user.123@example.com', 
                                     Email = 'test.1@example.com', 
                                     Alias = 'testu1', 
                                     TimeZoneSidKey = 'GMT', 
                                     LocaleSidKey = 'en_GB', 
                                     EmailEncodingKey = 'ISO-8859-1', 
                                     ProfileId = testProfile.Id, 
                                     LanguageLocaleKey = 'en_US'); 
            
            insert testUser;
            
            TeamHierarchy__c teamHieRec = new TeamHierarchy__c();
            teamHieRec.Product_Type__c = 'Home Loan';
            teamHieRec.EmpLevel__c = '1';
            teamHieRec.EmpRole__c = 'RM';
            teamHieRec.Employee__c = testUser.Id;
            insert teamHieRec;
            
            LoanAppl__c loanApp=New LoanAppl__c();
            loanApp.Stage__c = 'QDE';
            loanApp.SubStage__c = 'RM Data Entry';
          	loanApp.Product__c = 'Home Loan';
        
            insert loanApp;
                
            Applicant__c app = new Applicant__c(); 
            app.LoanAppln__c =  loanApp.Id;
            insert app; 
        	       	
        	DocMstr__c docMaster = TestDataFActory.createDocumentMaster(true,'PAN');
            DocDtl__c doc = TestDataFActory.createDocumentDetail(true,'PAN',app.Id,docMaster.Id);
        
            system.runAs(testUser){
              
              
                LoanAppl__c loan= [SELECT Id,  Stage__c, SubStage__c, Stepper__c  FROM loanAppl__c WHERE id=: loanApp.Id];
                system.debug('loan:::::::'+loan);
				try{
                    //system.debug( loanApp.Id +'  ====  ' + listofMeta[0].Stage_Name__c + ' ====  ' +app.Id);
                    ValidateRequiredFieldsAndDoc.getValidationReport(loanApp.Id);    
                }
                catch(Exception e){
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
              
            }
        
    }
    @isTest
    static  Void testValidateRequiredFieldsAndDoc1() {    
             Profile testProfile = [SELECT Id 
                                   FROM profile
                                   WHERE Name = 'System Administrator' 
                                   LIMIT 1 ];
            User testUser = new User(LastName = 'test user 1', 
                                     Username = 'test.user.123@example.com', 
                                     Email = 'test.1@example.com', 
                                     Alias = 'testu1', 
                                     TimeZoneSidKey = 'GMT', 
                                     LocaleSidKey = 'en_GB', 
                                     EmailEncodingKey = 'ISO-8859-1', 
                                     ProfileId = testProfile.Id, 
                                     LanguageLocaleKey = 'en_US'); 
            
            insert testUser;
            
            TeamHierarchy__c teamHieRec = new TeamHierarchy__c();
            teamHieRec.Product_Type__c = 'Home Loan';
            teamHieRec.EmpLevel__c = '1';
            teamHieRec.EmpRole__c = 'RM';
            teamHieRec.Employee__c = testUser.Id;
            insert teamHieRec;
            
            LoanAppl__c loanApp=New LoanAppl__c();
            loanApp.Stage__c = 'QDE';
            loanApp.SubStage__c = 'RM Data Entry';
          	loanApp.Product__c = 'Home Loan';
        
            insert loanApp;
                
            Applicant__c app = new Applicant__c(); 
            app.LoanAppln__c =  loanApp.Id;
        app.ApplType__c =  'N';
            insert app; 
        	       	
        	DocMstr__c docMaster = TestDataFActory.createDocumentMaster(true,'PAN');
            DocDtl__c doc = TestDataFActory.createDocumentDetail(true,'PAN',app.Id,docMaster.Id);
        
            system.runAs(testUser){
              
              
                LoanAppl__c loan= [SELECT Id,  Stage__c, SubStage__c, Stepper__c  FROM loanAppl__c WHERE id=: loanApp.Id];
                system.debug('loan:::::::'+loan);

            
               // test.startTest();
                try{
                    //system.debug( loanApp.Id +'  ====  ' + listofMeta[0].Stage_Name__c + ' ====  ' +app.Id);
                    ValidateRequiredFieldsAndDoc.getValidationReport(loanApp.Id);    
                    
                    
                }
                catch(Exception e){
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
              
            }
        
    }
    
      @isTest
    static void testValidateRequiredFieldsAndDoc34() {
        Profile testProfile = [SELECT Id FROM profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            LastName = 'test user 1',
            Username = 'test.user.123@example.com',
            Email = 'test.1@example.com',
            Alias = 'testu1',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_GB',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = testProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        LoanAppl__c loanApp = new LoanAppl__c(
            Stage__c = 'Post Sanction',
            SubStage__c = 'Data Entry',
            Product__c = 'Home Loan',
            InterestWaiverTaken__c= 'Y'
        );
        insert loanApp;

        Applicant__c app = new Applicant__c(LoanAppln__c = loanApp.Id); 
        insert app;

        ApplAddr__c address = new ApplAddr__c(
            LoanAppl__c = loanApp.Id,
            Applicant__c = app.Id,
            MailAddr__c = true
        );
        insert address;
        
         ApplKyc__c kycRecord = new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = GlobalConstants.AadhaarVariable,
            ValidationStatus__c = ''
        );
        insert kycRecord;

        system.runAs(testUser) {
            Test.startTest();
            ValidateRequiredFieldsAndDoc.getValidationReport(loanApp.Id);
            Test.stopTest();
        }
    }
   
}